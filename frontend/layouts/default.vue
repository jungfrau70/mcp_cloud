<template>
  <div class="h-screen flex flex-col">
    <!-- Top Navigation Bar -->
    <nav class="bg-white shadow-sm border-b z-10">
      <div class="max-w-full mx-auto px-4 sm:px-6 lg:px-8">
        <div class="flex justify-between h-16">
          <div class="flex items-center">
            <button @click="toggleSidebar" class="mr-3 p-2 rounded hover:bg-gray-100 focus:outline-none" title="Toggle sidebar">
              <svg class="w-5 h-5 text-gray-700" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16" />
              </svg>
            </button>
            <NuxtLink to="/" class="text-xl font-bold text-gray-900">
              m-Learning
            </NuxtLink>
          </div>
          <div class="flex items-center space-x-4">
            <NuxtLink to="/" class="text-gray-700 hover:text-gray-900 px-3 py-2 rounded-md text-sm font-medium">
              홈
            </NuxtLink>
            <NuxtLink to="/ai-assistant" class="text-gray-700 hover:text-gray-900 px-3 py-2 rounded-md text-sm font-medium">
              AI 어시스턴트
            </NuxtLink>
            <NuxtLink to="/knowledge-base" class="text-gray-700 hover:text-gray-900 px-3 py-2 rounded-md text-sm font-medium">
              Curriculum
            </NuxtLink>
            <NuxtLink to="/datasources" class="text-gray-700 hover:text-gray-900 px-3 py-2 rounded-md text-sm font-medium">
              데이터소스
            </NuxtLink>
            <button @click="openInteractiveCLI" class="text-gray-700 hover:text-gray-900 px-3 py-2 rounded-md text-sm font-medium">
              대화형 CLI
            </button>
            <NuxtLink to="/cli" class="text-gray-700 hover:text-gray-900 px-3 py-2 rounded-md text-sm font-medium">
              CLI 명령어
            </NuxtLink>
          </div>
        </div>
      </div>
    </nav>

    <!-- Main IDE Layout -->
    <div class="flex flex-grow overflow-hidden bg-gray-100">
      <!-- Left Panel: Syllabus Explorer -->
      <aside
        class="bg-white border-r border-gray-200 flex-shrink-0 overflow-y-auto shadow-md transition-all duration-200"
        :style="{ width: isSidebarCollapsed ? '0px' : sidebarWidth + 'px' }"
      >
        <div v-show="!isSidebarCollapsed">
          <SyllabusExplorer @file-click="handleFileClick" />
        </div>
      </aside>
      <!-- Resizer -->
      <div
        v-if="!isSidebarCollapsed"
        class="w-1 cursor-col-resize bg-gray-200 hover:bg-gray-300"
        @mousedown="onResizeStart"
      ></div>

      <!-- Center Panel: Workspace Tabs -->
      <main class="flex-grow overflow-hidden" ref="workspaceMain">
        <WorkspaceView :active-content="activeContent" :active-slide="activeSlide" :active-path="activePath" ref="workspaceView">
          <slot /> <!-- Nuxt page content will be injected here -->
        </WorkspaceView>
      </main>

      <!-- Right Panel: AI Assistant -->
      <aside class="w-80 bg-white border-l border-gray-200 flex-shrink-0 overflow-y-auto shadow-md">
        <AIAssistantPanel />
      </aside>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import { useRoute } from 'vue-router';
import SyllabusExplorer from '~/components/SyllabusExplorer.vue';
import WorkspaceView from '~/components/WorkspaceView.vue';
import AIAssistantPanel from '~/components/AIAssistantPanel.vue';

const activeContent = ref('');
const activeSlide = ref(null);
const activePath = ref('');

// Sidebar state
const isSidebarCollapsed = ref(false);
const sidebarWidth = ref(256); // default ~ w-64
const minSidebarWidth = 200;
const maxSidebarWidth = 500;

// Workspace refs
const workspaceMain = ref(null);
const workspaceView = ref(null);

const toggleSidebar = () => {
  isSidebarCollapsed.value = !isSidebarCollapsed.value;
};

const onResizeStart = (e) => {
  const startX = e.clientX;
  const startWidth = sidebarWidth.value;
  const onMouseMove = (ev) => {
    const dx = ev.clientX - startX;
    let next = startWidth + dx;
    if (next < minSidebarWidth) next = minSidebarWidth;
    if (next > maxSidebarWidth) next = maxSidebarWidth;
    sidebarWidth.value = next;
  };
  const onMouseUp = () => {
    window.removeEventListener('mousemove', onMouseMove);
    window.removeEventListener('mouseup', onMouseUp);
  };
  window.addEventListener('mousemove', onMouseMove);
  window.addEventListener('mouseup', onMouseUp);
};

// API configuration
const config = useRuntimeConfig();
const apiBase = config.public.apiBaseUrl || 'http://localhost:8000';
const apiKey = 'my_mcp_eagle_tiger';

// Load default content: textbook/index.md when on knowledge-base route
const route = useRoute();
onMounted(() => {
  // 기본 본문을 Curriculum으로 로드
  if (!activeContent.value) {
    handleFileClick('Curriculum.md');
  }
  
  // 대화형 CLI 이벤트 리스너 설정
  if (workspaceMain.value) {
    workspaceMain.value.addEventListener('navigate-tool', (event) => {
      if (workspaceView.value && event.detail.tool === 'cli') {
        workspaceView.value.handleNavigation({ tool: 'cli' });
      }
    });
  }
});

const handleFileClick = async (path) => {
  try {
    activePath.value = path;
    
    // Fetch textbook content
    const contentResponse = await fetch(`${apiBase}/api/v1/curriculum/content?path=${path}`, {
      headers: { 'X-API-Key': apiKey },
    });
    if (!contentResponse.ok) throw new Error('Failed to fetch content');
    const contentData = await contentResponse.json();
    activeContent.value = contentData.content;

    // Slide download is handled client-side from ContentView using the same path
    activeSlide.value = null;

  } catch (error) {
    console.error('Error fetching curriculum data:', error);
    activeContent.value = 'Error loading content.';
    activeSlide.value = null;
  }
};

// 대화형 CLI 열기 함수
const openInteractiveCLI = () => {
  // WorkspaceView에 CLI 컴포넌트로 전환하도록 이벤트 발생
  if (workspaceView.value) {
    workspaceView.value.handleNavigation({ tool: 'cli' });
  }
};

// Default layout for the IDE-style interface.
</script>

<style>
html, body, #__nuxt {
  height: 100%;
  margin: 0;
  padding: 0;
  overflow: hidden; /* Prevent scrollbars on html/body */
}
</style>