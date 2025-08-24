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
              MentorAi
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
      <!-- Left Panel: hidden entirely on knowledge-base -->
      <aside
        v-if="!isKnowledgeBase"
        class="bg-white border-r border-gray-200 flex-shrink-0 overflow-y-auto shadow-md transition-all duration-200"
        :style="{ width: isSidebarCollapsed ? '0px' : sidebarWidth + 'px' }"
      >
        <div v-show="!isSidebarCollapsed">
          <SyllabusExplorer @file-click="handleFileClick" />
        </div>
      </aside>
      <!-- Resizer -->
      <div
        v-if="!isKnowledgeBase && !isSidebarCollapsed"
        class="w-1 cursor-col-resize bg-gray-200 hover:bg-gray-300"
        @mousedown="startResize"
      ></div>
      
      <!-- 사이드바 토글 버튼 -->
      <div
        v-if="!isKnowledgeBase"
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
        <div class="flex-1 overflow-hidden">
          <WorkspaceView v-if="!isKnowledgeBase" :active-content="activeContent" :active-slide="activeSlide" :active-path="activePath" ref="workspaceView">
            <slot />
          </WorkspaceView>
          <div v-else class="h-full flex flex-col">
            <div class="border-b bg-white p-2 text-sm flex items-center gap-2" role="tablist" aria-label="KB editor tabs">
              <button role="tab" :aria-selected="kbTab==='tree'" @click="kbTab='tree'" :class="kbTab==='tree' ? 'px-3 py-1 rounded bg-indigo-600 text-white' : 'px-3 py-1 rounded bg-gray-200'">FileTree</button>
              <button role="tab" :aria-selected="kbTab==='tiptap'" @click="switchKbTab('tiptap')" :class="kbTab==='tiptap' ? 'px-3 py-1 rounded bg-indigo-600 text-white' : 'px-3 py-1 rounded bg-gray-200'">WYSIWYG</button>
              <button role="tab" :aria-selected="kbTab==='markdown'" @click="switchKbTab('markdown')" :class="kbTab==='markdown' ? 'px-3 py-1 rounded bg-indigo-600 text-white' : 'px-3 py-1 rounded bg-gray-200'">Markdown</button>
              <div class="flex-1"></div>
              <span class="text-xs text-gray-500" v-if="activePath">{{ activePath }}</span>
            </div>
            <div class="flex-1 overflow-hidden">
              <div v-if="kbTab==='tree'" class="h-full">
                <KnowledgeBaseExplorer mode="full" :selected-file="activePath" @file-select="onTreeSelect" @file-open="onTreeSelect" />
              </div>
              <div v-else-if="kbTab==='tiptap'" class="h-full">
                <div v-if="activePath" class="h-full"><TipTapKbEditor :key="editorKeyFull" :path="activePath" :content="activeContent" /></div>
                <div v-else class="p-6 text-sm text-gray-500">좌측 FileTree 탭에서 문서를 선택해 주세요.</div>
              </div>
              <div v-else class="h-full">
                <div v-if="activePath" class="h-full"><SplitEditor :key="editorKeyFull" :path="activePath" :content="activeContent" ref="splitEditor" @save="handleKbSave" /></div>
                <div v-else class="p-6 text-sm text-gray-500">좌측 FileTree 탭에서 문서를 선택해 주세요.</div>
              </div>
            </div>
          </div>
        </div>
      </main>

      <!-- Right Panel: AI Assistant -->
      <aside v-if="!isKnowledgeBase" class="w-80 bg-white border-l border-gray-200 flex-shrink-0 overflow-y-auto shadow-md">
        <AIAssistantPanel />
      </aside>
    </div>
  <TaskStatusBar v-if="isKnowledgeBase" />
  <ToastStack />
  </div>
</template>

<script setup>
import { ref, onMounted, computed, watch } from 'vue'
import { useRoute } from 'vue-router'
import { useRuntimeConfig } from '#app'
import SyllabusExplorer from '~/components/SyllabusExplorer.vue'
import KnowledgeBaseExplorer from '~/components/KnowledgeBaseExplorer.vue'
import WorkspaceView from '~/components/WorkspaceView.vue'
import AIAssistantPanel from '~/components/AIAssistantPanel.vue'
import SplitEditor from '~/components/SplitEditor.vue'
import TipTapKbEditor from '~/components/TipTapKbEditor.client.vue'
import TaskStatusBar from '~/components/TaskStatusBar.vue'
import ToastStack from '~/components/ToastStack.vue'
import { useToastStore } from '~/stores/toast'
const toast = useToastStore()
import { useSidebarResize } from '~/composables/useSidebarResize'
import { useDocStore } from '~/stores/doc'

const activeSlide = ref(null)
const docStore = useDocStore()
const activeContent = computed(()=> docStore.content)
const activePath = computed(()=> docStore.path)
const lastVersion = computed(()=> docStore.version)
const kbTab = ref('tree')
const editorKey = computed(()=> `${kbTab.value}`)
const editorKeyFull = computed(()=> `${kbTab.value}:${activePath.value || ''}:${lastVersion.value || 0}:${(activeContent.value||'').length}`)

// Sidebar state via composable
const { isCollapsed: isSidebarCollapsed, width: sidebarWidth, toggle: toggleSidebar, start: startResize } = useSidebarResize(256, 200, 500)

// Workspace refs
const workspaceMain = ref(null)
const workspaceView = ref(null)
const splitEditor = ref(null)

// API configuration
const config = useRuntimeConfig();
const apiBase = config.public.apiBaseUrl || 'http://localhost:8000';
const apiKey = 'my_mcp_eagle_tiger';

// Load default content: textbook/index.md when on knowledge-base route
const route = useRoute();
const isKnowledgeBase = computed(() => route.path.startsWith('/knowledge-base'))
onMounted(() => {
  if (isKnowledgeBase.value) {
    try{
      const lastTab = typeof window !== 'undefined' ? localStorage.getItem('kb_last_tab') : null
      if(lastTab && ['tree','tiptap','markdown'].includes(lastTab)) kbTab.value = lastTab
    }catch{}
  } else {
    // Restore last opened textbook path if available, otherwise open first slide
    try {
      const last = typeof window !== 'undefined' ? localStorage.getItem('textbook_last_path') : null
      if (last) {
        handleFileClick(last)
      } else {
        handleFileClick('1-1_introduction_to_cloud.md')
      }
    } catch { handleFileClick('1-1_introduction_to_cloud.md') }
  }
  
  // 대화형 CLI 이벤트 리스너 설정
  if (workspaceMain.value) {
    workspaceMain.value.addEventListener('navigate-tool', (event) => {
      if (workspaceView.value && event.detail.tool === 'cli') {
        workspaceView.value.handleNavigation({ tool: 'cli' });
      }
    });
  }

  // 토스트 링크로 전달된 KB 경로 열기
  if (typeof window !== 'undefined'){
    window.addEventListener('kb:open', (e) => {
      const p = e?.detail?.path
      if(p){ handleKbFileSelect(p) }
    })
    window.addEventListener('kb:mode', (e) => {
      if(e?.detail?.to === 'view'){
        // simply no-op here; content view is default when not directly using WorkspaceView
      }
    })
  }
});

// 라우트 변경 시 커리큘럼 페이지로 전환되면 마지막 경로 복원
watch(() => route.path, (p) => {
  if (p.startsWith('/textbook')) {
    try {
      const last = typeof window !== 'undefined' ? localStorage.getItem('textbook_last_path') : null
      if (last) {
        handleFileClick(last)
      }
    } catch {}
    isSidebarCollapsed.value = false
  }
})

const handleFileClick = async (path) => {
  try {
    activePath.value = path;
    // persist last opened textbook file
    try { if (typeof window !== 'undefined') localStorage.setItem('textbook_last_path', path) } catch {}
    
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
  activeSlide.value = null
  await docStore.open(path)
  if(docStore.error) toast.push('error','로드 실패: ' + docStore.error)
}

const handleKbSave = async ({ path, content, message, force }) => {
  if(force){
    // force bypass optimistic (call API directly)
    try {
      const config = useRuntimeConfig();
      const apiBase = config.public.apiBaseUrl || 'http://localhost:8000';
      await fetch(`${apiBase}/api/v1/knowledge-base/item`, { method:'PATCH', headers:{ 'Content-Type':'application/json','X-API-Key':'my_mcp_eagle_tiger' }, body: JSON.stringify({ path, content, message }) })
      toast.push('success','강제 저장 완료')
    } catch(e){ toast.push('error','강제 저장 실패') }
    return
  }
  const res = await docStore.save(message)
  if(res?.conflict){
    await docStore.open(path || docStore.path)
    if(splitEditor.value?.handleConflict){
      splitEditor.value.handleConflict(docStore.content, docStore.version)
    }
    toast.push('warn','버전 충돌 발생: 병합 필요')
  } else if(!res?.error){
    splitEditor.value?.setSaved({ version_no: docStore.version })
    toast.push('success','저장 완료')
  } else if(res.error){
    toast.push('error','저장 실패: ' + res.error)
  }
}


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

async function onTreeSelect(p){ await handleKbFileSelect(p); kbTab.value = 'tiptap' }

async function switchKbTab(next){
  if(next === kbTab.value) return
  if(!activePath.value){ kbTab.value = next; return }
  // ensure the current doc is loaded before switching to an editor tab
  try { await docStore.whenLoaded(activePath.value) } catch {}
  // force re-render editors to avoid stale content when switching quickly
  kbTab.value = next
}

// remember kb tab
watch(kbTab, (v) => {
  try{ if(typeof window !== 'undefined') localStorage.setItem('kb_last_tab', v) }catch{}
})

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