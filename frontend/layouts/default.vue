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
            <a href="/" class="text-xl font-bold text-gray-900">
              Dr. Cloud
            </a>
          </div>
          <div class="flex items-center space-x-4">
            <a href="/textbook" class="text-gray-700 hover:text-gray-900 px-3 py-2 rounded-md text-sm font-medium">
              커리큘럼
            </a>
            <a href="/knowledge-base" class="text-gray-700 hover:text-gray-900 px-3 py-2 rounded-md text-sm font-medium">
              지식베이스
            </a>
            <a href="/login" class="text-gray-700 hover:text-gray-900 px-3 py-2 rounded-md text-sm font-medium">
              로그인
            </a>
          </div>
        </div>
      </div>
    </nav>

    <!-- Main IDE Layout -->
    <div class="flex flex-grow overflow-hidden bg-gray-100 relative">
      <!-- Left Panel -->
      <aside
        class="bg-white border-r border-gray-200 flex-shrink-0 overflow-y-auto shadow-md transition-all duration-200"
        :style="{ width: isSidebarCollapsed ? '0px' : sidebarWidth + 'px' }"
      >
        <div v-show="!isSidebarCollapsed">
          <SyllabusExplorer v-if="!isKnowledgeBase" @file-click="handleFileClick" />
          <KnowledgeBaseExplorer v-else mode="tree" @file-select="handleKbFileSelect" />
        </div>
      </aside>
      <!-- Resizer -->
      <div
        v-if="!isSidebarCollapsed"
        class="w-1 cursor-col-resize bg-gray-200 hover:bg-gray-300"
        @mousedown="onResizeStart"
      ></div>
      
      <!-- 사이드바 토글 버튼 -->
      <div
        class="absolute left-0 top-1/2 transform -translate-y-1/2 z-10"
        :style="{ left: isSidebarCollapsed ? '0px' : sidebarWidth + 'px' }"
      >
        <button
          @click="toggleSidebar"
          class="bg-white border border-gray-200 rounded-r-lg p-2 shadow-md hover:bg-gray-50 transition-colors"
          :title="isSidebarCollapsed ? '사이드바 열기' : '사이드바 닫기'"
        >
          <svg class="w-4 h-4 text-gray-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" />
          </svg>
        </button>
      </div>

      <!-- Center Panel: Workspace Tabs -->
      <main class="flex-grow overflow-hidden flex flex-col" ref="workspaceMain">
        <div v-if="isKnowledgeBase" class="bg-white border-b shadow-sm">
          <KnowledgeBaseExplorer mode="search" @file-select="handleKbFileSelect" />
        </div>
        <div class="flex-1 overflow-hidden">
          <WorkspaceView :active-content="activeContent" :active-slide="activeSlide" :active-path="activePath" ref="workspaceView">
            <slot /> <!-- Nuxt page content will be injected here -->
          </WorkspaceView>
        </div>
      </main>

      <!-- Right Panel: AI Assistant -->
      <aside v-if="!isKnowledgeBase" class="w-80 bg-white border-l border-gray-200 flex-shrink-0 overflow-y-auto shadow-md">
        <AIAssistantPanel />
      </aside>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue';
import { useRoute } from 'vue-router';
import SyllabusExplorer from '~/components/SyllabusExplorer.vue';
import KnowledgeBaseExplorer from '~/components/KnowledgeBaseExplorer.vue';
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
const isKnowledgeBase = computed(() => route.path.startsWith('/knowledge-base'))
onMounted(() => {
  if (isKnowledgeBase.value) {
    // Load initial KB content if any
  } else {
    // 기본 본문을 첫 번째 슬라이드로 로드
    if (!activeContent.value) {
      handleFileClick('1-1_introduction_to_cloud.md');
    }
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

// 라우트 변경 시 커리큘럼 페이지로 전환되면 첫 번째 슬라이드 로드
watch(() => route.path, (p) => {
  if (p.startsWith('/textbook')) {
    // 첫 번째 슬라이드 파일을 찾아서 로드
    handleFileClick('1-1_introduction_to_cloud.md')
    isSidebarCollapsed.value = false
  }
})

const handleFileClick = async (path) => {
  try {
    activePath.value = path;
    
    // 슬라이드 내용을 가져오기 위해 슬라이드 API 사용
    const contentResponse = await fetch(`${apiBase}/api/v1/slides?textbook_path=${encodeURIComponent(path)}`, {
      headers: { 'X-API-Key': apiKey },
    });
    if (!contentResponse.ok) throw new Error('Failed to fetch slide content');
    
    const contentType = contentResponse.headers.get('content-type') || '';
    if (contentType.includes('application/pdf')) {
      // PDF인 경우 blob으로 처리
      const blob = await contentResponse.blob();
      activeContent.value = `# ${path}\n\nPDF 슬라이드가 로드되었습니다.`;
      activeSlide.value = { type: 'pdf', url: URL.createObjectURL(blob) };
    } else {
      // 마크다운인 경우 텍스트로 처리
      const content = await contentResponse.text();
      activeContent.value = content;
      activeSlide.value = null;
    }

  } catch (error) {
    console.error('Error fetching slide data:', error);
    activeContent.value = 'Error loading slide content.';
    activeSlide.value = null;
  }
};

const handleKbFileSelect = async (path) => {
  try {
    activePath.value = path;
    
    const response = await fetch(`${apiBase}/api/kb/item?path=${encodeURIComponent(stripBasePath(path))}`, {
      headers: { 'X-API-Key': apiKey }
    });
    
    if (!response.ok) throw new Error('Failed to load file');
    
    const data = await response.json();
    activeContent.value = data.content;
    activeSlide.value = null;

  } catch (error) {
    console.error('Error loading file:', error);
    activeContent.value = 'Error loading content.';
    activeSlide.value = null;
  }
};

const stripBasePath = (path) => {
  const basePath = 'mcp_knowledge_base/';
  if (path.startsWith(basePath)) {
    return path.substring(basePath.length);
  }
  return path;
};

// 대화형 CLI 열기 함수
const openInteractiveCLI = () => {
  // WorkspaceView에 CLI 컴포넌트로 전환하도록 이벤트 발생
  if (workspaceView.value) {
    workspaceView.value.handleNavigation({ tool: 'cli' });
  }
};

// 지식베이스 본문 전환
const openKnowledgeBase = async () => {
  try {
    // 기본 소개 문서가 있다면 로드, 없으면 리스트 안내
    await handleFileClick('textbook/Curriculum.md');
    // 경로가 다를 경우 지식베이스 인덱스 문서를 시도
  } catch (e) {
    activeContent.value = '# 지식베이스\n좌측 상단 메뉴에서 지식베이스 페이지로 이동해 문서를 관리하세요.';
    activeSlide.value = null;
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