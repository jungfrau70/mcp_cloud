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
              GoldenCicle
            </a>
          </div>
          <div class="flex items-center space-x-4 relative">
            <NuxtLink
              to="/curriculum"
              :class="['px-3 py-2 rounded-md text-sm', route.path.startsWith('/curriculum') ? 'font-bold text-gray-900' : 'text-gray-700 hover:text-gray-900']"
            >
              커리큘럼
            </NuxtLink>
            <NuxtLink
              v-if="isAdmin"
              to="/knowledge-base"
              :class="['px-3 py-2 rounded-md text-sm', route.path.startsWith('/knowledge-base') ? 'font-bold text-gray-900' : 'text-gray-700 hover:text-gray-900']"
            >
              지식베이스
            </NuxtLink>
            <!-- Auth Status -->
            <div v-if="isLoggedIn" class="relative" ref="userMenuRef">
              <button @click="userMenuOpen = !userMenuOpen" class="px-3 py-2 rounded-md text-sm text-gray-700 hover:text-gray-900 flex items-center gap-2" aria-haspopup="menu" :aria-expanded="userMenuOpen ? 'true':'false'">
                <span class="truncate max-w-[180px]">{{ displayName }}</span>
                <svg class="w-4 h-4" viewBox="0 0 20 20" fill="currentColor"><path fill-rule="evenodd" d="M5.23 7.21a.75.75 0 011.06.02L10 11.188l3.71-3.957a.75.75 0 111.08 1.04l-4.25 4.53a.75.75 0 01-1.08 0l-4.25-4.53a.75.75 0 01.02-1.06z" clip-rule="evenodd"/></svg>
              </button>
              <div v-if="userMenuOpen" class="absolute right-0 mt-2 w-48 bg-white border rounded-md shadow-lg z-30" role="menu">
                <button @click="() => { window.profileModalClicked = true; openProfileModal(); }" class="w-full text-left px-3 py-2 text-sm text-gray-700 hover:bg-gray-100" role="menuitem">프로파일</button>
                <button @click="onLogout" class="w-full text-left px-3 py-2 text-sm text-gray-700 hover:bg-gray-100" role="menuitem">로그아웃</button>
              </div>
            </div>
            <div v-else class="flex items-center space-x-2">
              <NuxtLink to="/login" :class="['px-3 py-2 rounded-md text-sm', route.path.startsWith('/login') ? 'font-bold text-gray-900' : 'text-gray-700 hover:text-gray-900']">로그인</NuxtLink>
              <NuxtLink to="/register" :class="['px-3 py-2 rounded-md text-sm', route.path.startsWith('/register') ? 'font-bold text-gray-900' : 'text-gray-700 hover:text-gray-900']">회원가입</NuxtLink>
            </div>
          </div>
        </div>
      </div>
    </nav>

    <!-- Main IDE Layout -->
    <div class="flex flex-grow overflow-hidden bg-gray-100 relative">
      <!-- Left Panel: hidden entirely on knowledge-base when Markdown tab active -->
      <aside
        v-if="!isKnowledgeBase"
        class="bg-white border-r border-gray-200 flex-shrink-0 overflow-y-auto shadow-md transition-all duration-200"
        :style="{ width: isSidebarCollapsed ? '0px' : sidebarWidth + 'px' }"
      >
        <div v-show="!isSidebarCollapsed">
          <SyllabusExplorer 
            @file-click="handleFileClick" 
            :selected-file="tbPath"
          />
        </div>
      </aside>
      <!-- Resizer -->
      <div
        v-if="!isKnowledgeBase && !isSidebarCollapsed"
        class="w-1 cursor-col-resize bg-gray-200 hover:bg-gray-300"
        @mousedown="startResize"
      ></div>
      
      <!-- 왼쪽 사이드바 토글 핸들 (회색) -->
      <div
        v-if="!isKnowledgeBase"
        class="absolute top-1/2 -translate-y-1/2 z-20"
        :style="{ left: isSidebarCollapsed ? '0px' : (sidebarWidth + 'px') }"
      >
        <button @click="toggleSidebar"
                class="sidebar-handle"
                :aria-label="isSidebarCollapsed ? '사이드바 열기' : '사이드바 닫기'"
                :aria-expanded="isSidebarCollapsed ? 'false' : 'true'">
          <span v-if="isSidebarCollapsed">›</span>
          <span v-else>‹</span>
        </button>
      </div>

      <!-- Center Panel: Workspace Tabs -->
      <main class="flex-grow overflow-hidden flex flex-col" ref="workspaceMain">
        <div class="flex-1 overflow-hidden">
          <div v-if="isKnowledgeBase" class="h-full flex flex-col">
            <div class="border-b bg-white p-2 text-sm flex items-center gap-2" role="tablist" aria-label="KB editor tabs">
              <button role="tab" :aria-selected="kbTab==='tree'" @click="kbTab='tree'" :class="kbTab==='tree' ? 'px-3 py-1 rounded bg-indigo-600 text-white' : 'px-3 py-1 rounded bg-gray-200'">FileTree</button>
              <button role="tab" :aria-selected="kbTab==='tiptap'" @click="switchKbTab('tiptap')" :class="kbTab==='tiptap' ? 'px-3 py-1 rounded bg-indigo-600 text-white' : 'px-3 py-1 rounded bg-gray-200'">WYSIWYG</button>
              <button role="tab" :aria-selected="kbTab==='markdown'" @click="switchKbTab('markdown')" :class="kbTab==='markdown' ? 'px-3 py-1 rounded bg-indigo-600 text-white' : 'px-3 py-1 rounded bg-gray-200'">Markdown</button>
              <div class="flex-1"></div>
              <button @click="goKbBack" :disabled="!kbHistory.length" class="px-2 py-1 rounded bg-gray-200 disabled:opacity-50">뒤로</button>
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
              <div v-else class="h-full flex flex-col">
                <!-- Markdown view: full-width container view with scroll -->
                <div v-if="activePath" class="h-full overflow-y-auto">
                  <SplitEditor :key="editorKeyFull" :path="activePath" :content="activeContent" ref="splitEditor" @save="handleKbSave" />
                </div>
                <div v-else class="p-6 text-sm text-gray-500">좌측 FileTree 탭에서 문서를 선택해 주세요.</div>
              </div>
            </div>
          </div>
          <div v-else-if="isHome || isAuthRoute" class="h-full">
            <slot />
          </div>
          <template v-else>
            <transition name="fade" mode="out-in">
              <WorkspaceView :active-content="tbContent" :active-slide="tbSlide" :active-path="tbPath" :readonly="true" ref="workspaceView" />
            </transition>
          </template>
        </div>
      </main>

      <!-- Right Panel: AI Assistant -->
      <!-- Chat reveal handle -->
      <div v-if="!isKnowledgeBase && (!isCurriculumRoute || isTutorOrAdmin)"
           class="absolute top-1/2 -translate-y-1/2 right-0 z-20">
        <button @click="chatVisible = !chatVisible"
                class="chat-handle"
                :aria-label="chatVisible ? '채팅 숨김' : '채팅 표시'"
                :aria-expanded="chatVisible ? 'true' : 'false'">
          <span v-if="chatVisible">›</span>
          <span v-else>‹</span>
        </button>
      </div>

      <!-- Chat resizer (visible only when chat is open) -->
      <div v-if="!isKnowledgeBase && chatVisible && (!isCurriculumRoute || isTutorOrAdmin)"
           class="chat-resizer"
           @mousedown="startChatResize"
           :style="{ right: (chatWidth + 'px') }"></div>

      <transition name="fade" mode="out-in">
        <aside v-if="!isKnowledgeBase && chatVisible && (!isCurriculumRoute || isTutorOrAdmin)" class="bg-white border-l border-gray-200 flex-shrink-0 overflow-y-auto shadow-md"
               :style="{ width: chatWidth + 'px' }">
          <AIAssistantPanel />
        </aside>
      </transition>

      <!-- Profile Modal -->
      <div v-if="showProfile" class="fixed inset-0 z-40 bg-black/30 flex items-center justify-center" @click.self="showProfile=false">
        <div class="bg-white rounded-lg shadow-xl w-[440px] max-w-[92vw] p-4">
          <div class="text-lg font-semibold mb-2">프로파일</div>
          <div class="space-y-3">
            <div>
              <div class="text-xs text-gray-500">이메일</div>
              <div class="text-sm">{{ profile.email || auth.email || user?.email }}</div>
            </div>
            <div>
              <label class="text-xs text-gray-500">이름</label>
              <input v-model="profile.full_name" type="text" class="mt-1 w-full border rounded px-2 py-1" />
            </div>
            <div class="text-xs text-gray-500">역할: <span class="font-medium">{{ profile.role || auth.role || user?.role || 'student' }}</span></div>
          </div>
          <div class="mt-4 flex justify-end gap-2">
            <button class="px-3 py-1 border rounded" @click="showProfile=false">닫기</button>
            <button class="px-3 py-1 bg-indigo-600 text-white rounded" @click="saveProfile" :disabled="savingProfile">{{ savingProfile ? '저장 중...' : '저장' }}</button>
          </div>
        </div>
      </div>
    </div>
  <TaskStatusBar v-if="isKnowledgeBase" />
  <ToastStack />
  </div>
</template>

<script setup>
import { ref, onMounted, computed, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useRuntimeConfig } from '#app'
import SyllabusExplorer from '~/components/SyllabusExplorer.vue'
import KnowledgeBaseExplorer from '~/components/KnowledgeBaseExplorer.vue'
import WorkspaceView from '~/components/WorkspaceView.vue'
import AIAssistantPanel from '~/components/AIAssistantPanel.vue'
import SplitEditor from '~/components/SplitEditor.vue'
import TaskStatusBar from '~/components/TaskStatusBar.vue'
import ToastStack from '~/components/ToastStack.vue'
import { useToastStore } from '~/stores/toast'
import { useAuthStore } from '~/stores/auth'
import { useProgressStore } from '~/stores/progress'
import { cleanApiPath, deepCleanApiPath, preventPathDuplication, prepareApiPath, prepareSafeApiPath, makeUriDisplayFriendly } from '~/utils/path'
const toast = useToastStore()

// User authentication state
const user = ref(null)
const auth = useAuthStore()
const progressStore = useProgressStore()
const userMenuOpen = ref(false)

// 디버깅: userMenuOpen 상태 모니터링
watch(userMenuOpen, (newVal) => {
  console.log('userMenuOpen changed:', newVal)
}, { immediate: true })
// 중복 토큰 로드 방지: auth.loadFromStorage() 제거

// Hydration 불일치 방지를 위한 클라이언트 사이드 체크
const isClient = process.client && typeof window !== 'undefined'

async function fetchCurrentUser(){
  // 클라이언트 사이드에서만 실행
  if (!isClient) return;
  
  // 프로필 모달 자동 열림 방지
  if (typeof window !== 'undefined') {
    window.profileModalClicked = false
  }
  
  try {
    if (!auth.token) { 
      user.value = null; 
      // 토큰이 없으면 auth 스토어도 초기화
      auth.setUser(null, null);
      return; 
    }

    console.log('Fetching user with token:', auth.token);

    const headers = {
      'X-API-Key': apiKey,
      'Authorization': `Bearer ${auth.token}`
    }

    const { data: fetchedUser, error } = await useFetch('/api/v1/users/me', {
      key: auth.token,
      lazy: false,
      headers: headers,
      server: false,
      retry: 0
    });
    if (error.value){ 
      user.value = null; 
      auth.setUser(null, null);
      return; 
    }
    if (fetchedUser.value){
      user.value = fetchedUser.value
      // auth 스토어도 함께 업데이트하여 동기화
      auth.setUser(fetchedUser.value.email || null, fetchedUser.value.role || null)
    }
  } catch { 
    user.value = null; 
    auth.setUser(null, null);
  }
}

function redirectToLogin() {
  // Redirect to Authelia portal with return destination (rd) back to app
  try {
    const dest = typeof window !== 'undefined' ? `${window.location.origin}/knowledge-base` : '/knowledge-base'
    window.location.href = `/login?rd=${encodeURIComponent(dest)}`
  } catch {
    window.location.href = '/knowledge-base'
  }
}

async function onLogout(){
  try{
    const base = (config.public?.apiBaseUrl) || '/api'
    await $fetch(`${base}/v1/auth/logout`, { method: 'POST' })
  }catch{}
  // Ensure local token/email/role are fully cleared and in-memory user reset
  try { auth.clear() } catch {}
  user.value = null
  try{ await router.push('/') }catch{}
}
// Fetch current user status on client-side mount
onMounted(async () => {
  try {
    // 사용자 상태는 watcher(immediate)에서 처리
    // 진도 스토어 초기화
    progressStore.loadProgress()
    
    // 드롭다운 메뉴가 자동으로 열리지 않도록 보장
    userMenuOpen.value = false
    console.log('onMounted: userMenuOpen set to false')
    
    // 프로필 모달 자동 열림 방지
    if (typeof window !== 'undefined') {
      window.profileModalClicked = false
    }
  } catch (e) {
    user.value = null;
  }
});

// Update user state when token changes (e.g., after login/logout)
watch(() => auth.token, async (newToken, oldToken) => {
  // 토큰이 변경되면 기존 사용자 정보 초기화
  if (newToken !== oldToken) {
    user.value = null
    auth.setUser(null, null)
  }
  
  if (newToken) {
    await fetchCurrentUser()
  } else {
    user.value = null
    auth.setUser(null, null)
  }
}, { immediate: true })
// Guard KB when user role changes
watch(() => user.value?.role, async () => {
  if (route.path.startsWith('/knowledge-base') && !isAdmin.value) {
    try { await router.replace('/curriculum') } catch {}
  }
})
// Close user menu when clicking outside the menu
const userMenuRef = ref(null)
onMounted(() => {
  try{
    const onDocClick = (e) => {
      if(!userMenuOpen.value) return
      const el = userMenuRef.value
      if(el && !el.contains(e.target)) userMenuOpen.value = false
    }
    window.addEventListener('click', onDocClick)
    // cleanup
    onUnmounted(() => { try{ window.removeEventListener('click', onDocClick) }catch{} })
  }catch{}
})
import { useSidebarResize } from '~/composables/useSidebarResize'
import { useDocStore } from '~/stores/doc'

const activeSlide = ref(null)
const docStore = useDocStore()
const activeContent = computed(()=> docStore.content)
const activePath = computed(()=> docStore.path)
const lastVersion = computed(()=> docStore.version)
const kbTab = ref('tree')
const kbHistory = ref([])
const editorKey = computed(()=> `${kbTab.value}`)
const chatVisible = ref(true)
const chatWidth = ref(320)
let chatDrag = false
let chatStartX = 0
let chatStartWidth = 320

function startChatResize(ev){
  chatDrag = true
  chatStartX = ev.clientX
  chatStartWidth = chatWidth.value
  window.addEventListener('mousemove', onChatResize)
  window.addEventListener('mouseup', stopChatResize)
}
function onChatResize(ev){
  if(!chatDrag) return
  const dx = chatStartX - ev.clientX
  let next = chatStartWidth + dx
  next = Math.max(240, Math.min(600, next))
  chatWidth.value = next
}
function stopChatResize(){
  chatDrag = false
  window.removeEventListener('mousemove', onChatResize)
  window.removeEventListener('mouseup', stopChatResize)
}
// Avoid re-mounting editors on each keystroke: do not include content length in key
// 안정적인 레이아웃 유지: 저장 시 버전 갱신으로 에디터가 재마운트되지 않도록 key에서 버전을 제외
const editorKeyFull = computed(()=> `${kbTab.value}:${activePath.value || ''}`)

// Sidebar state via composable
const { isCollapsed: isSidebarCollapsed, width: sidebarWidth, toggle: toggleSidebar, start: startResize } = useSidebarResize(256, 200, 500)

// Workspace refs
const workspaceMain = ref(null)
const workspaceView = ref(null)
const splitEditor = ref(null)

// Textbook display state (separate from KB doc store)
const tbContent = ref('')
const tbSlide = ref(null)
const tbPath = ref('')

// API configuration (browser-safe host resolution)
const config = useRuntimeConfig();
function resolveApiBase(){
  const configured = (config.public?.apiBaseUrl) || '/api'
  if (typeof window !== 'undefined'){
    try{
      const u = new URL(configured)
      const browserHost = window.location.hostname
      if (u.origin === 'null') return configured
      if (u.hostname !== 'localhost' && u.hostname !== '127.0.0.1' && u.hostname !== 'api.goldencircle.us' && u.hostname !== browserHost){
        const port = u.port || '8000'
        const scheme = u.protocol.replace(':','') || 'https'
        return `${scheme}://${browserHost}:${port}`
      }
    }catch{ /* ignore */ }
  }
  return configured
}
const apiBase = resolveApiBase()
const apiKey = (config.public?.apiKey) || 'my_mcp_eagle_tiger';

const displayName = computed(() => {
  // auth 스토어를 우선으로 사용하여 일관성 보장
  const nm = (auth.email ? (user.value?.full_name || '').trim() : '') || auth.email || '사용자'
  return nm ? nm : (auth.email || '사용자')
})

const isAdmin = computed(() => {
  // auth 스토어를 우선으로 사용하여 일관성 보장
  const r = String(auth.role || user.value?.role || '').toLowerCase()
  return r === 'admin' || r === 'administrator'
})
const isTutor = computed(() => String(auth.role || user.value?.role || '').toLowerCase() === 'tutor')
const isTutorOrAdmin = computed(() => isTutor.value || isAdmin.value)

// Profile modal state
const showProfile = ref(false)
const profile = ref({ email: '', full_name: '', role: '' })
const savingProfile = ref(false)

async function openProfileModal(){
  console.log('openProfileModal called', new Error().stack)
  console.log('openProfileModal called from:', new Error().stack?.split('\n')[2])
  
  // 자동 호출 방지 - 사용자가 직접 클릭한 경우만 허용
  if (typeof window !== 'undefined' && !window.profileModalClicked) {
    console.log('Profile modal auto-called, preventing...')
    return
  }
  
  // 플래그 리셋
  if (typeof window !== 'undefined') {
    window.profileModalClicked = false
  }
  
  try{
    const base = (config.public?.apiBaseUrl) || '/api'
    const data = await $fetch(`${base}/v1/profile/me`, {
      headers: {
        'X-API-Key': apiKey,
        ...(auth.token ? { 'Authorization': `Bearer ${auth.token}` } : {})
      }
    })
    profile.value = { email: data.email, full_name: data.full_name || '', role: data.role || '' }
    showProfile.value = true
  }catch{
    // fallback to auth store first, then user state
    profile.value = { email: auth.email || user.value?.email || '', full_name: user.value?.full_name || '', role: auth.role || user.value?.role || '' }
    showProfile.value = true
  }
}

async function saveProfile(){
  try{
    savingProfile.value = true
    const base = (config.public?.apiBaseUrl) || '/api'
    const res = await $fetch(`${base}/v1/profile`, {
      method: 'PATCH',
      body: { full_name: profile.value.full_name },
      headers: {
        'X-API-Key': apiKey,
        ...(auth.token ? { 'Authorization': `Bearer ${auth.token}` } : {})
      }
    })
    // sync state: auth 스토어를 우선으로 업데이트
    auth.setUser(res.email || auth.email, res.role || auth.role)
    user.value = { ...(user.value||{}), full_name: res.full_name, email: res.email, role: res.role }
    showProfile.value = false
  }catch{
    // ignore
  } finally {
    savingProfile.value = false
  }
}

// Load default content: textbook/index.md when on knowledge-base route
const route = useRoute();
const router = useRouter();
const isKnowledgeBase = computed(() => route.path.startsWith('/knowledge-base'))
const isLoggedIn = computed(() => {
  if (!isClient) return false;
  return !!auth.token;
})
const isCurriculumRoute = computed(() => {
  if (!isClient) return false;
  return route.path.startsWith('/curriculum') || route.path.startsWith('/textbook');
})
const isHomeRedirect = computed(() => {
  if (!isClient) return false;
  try{ return String((route.query||{}).force||'') === '1' }catch{ return false }
})
const homePathParam = computed(() => {
  if (!isClient) return '';
  try{ return String((route.query||{}).path||'') }catch{ return '' }
})
const isHome = computed(() => {
  if (!isClient) return false;
  return route.path === '/';
})
const isAuthRoute = computed(() => {
  if (!isClient) return false;
  return route.path.startsWith('/login') || route.path.startsWith('/register') || route.path.startsWith('/verify-email');
})
onMounted(async () => {
  // 클라이언트 사이드에서만 실행
  if (!isClient) return;
  
  // 드롭다운 메뉴가 자동으로 열리지 않도록 보장
  userMenuOpen.value = false
  console.log('second onMounted: userMenuOpen set to false')
  
  // 프로필 모달 자동 열림 방지
  if (typeof window !== 'undefined') {
    window.profileModalClicked = false
  }
  
  if (isKnowledgeBase.value) {
    if (!isAdmin.value) {
      try { await router.replace('/curriculum') } catch {}
      return
    }
    try{
      const lastTab = typeof window !== 'undefined' ? localStorage.getItem('kb_last_tab') : null
      if(lastTab && ['tree','tiptap','markdown'].includes(lastTab)) kbTab.value = lastTab
    }catch{}
    // 지식베이스 초기 화면: 파일 자동 열기 없이 FileTree 전체 화면 유지
  } else if (route.path.startsWith('/curriculum') || route.path.startsWith('/textbook')) {
    // Guard: curriculum/textbook require login
    if (!isLoggedIn.value) {
      try { await router.replace({ path: '/login', query: { rd: encodeURIComponent(route.fullPath) } }) } catch {}
      return
    }
    // Restore last opened curriculum path if available unless forced path in query
    try {
      const q = route.query || {}
      const forced = String(q.force || '') === '1'
      const target = String(q.path || '')
      const lastNew = typeof window !== 'undefined' ? localStorage.getItem('curriculum_last_path') : null
      const lastOld = typeof window !== 'undefined' ? localStorage.getItem('textbook_last_path') : null
      const last = lastNew || lastOld
      if (forced && target){ await handleFileClick(target) }
      else if (last) { handleFileClick(last) }
      else { ;(async ()=>{ await showCurriculumIndex() })() }
    } catch { ;(async ()=>{ await showCurriculumIndex() })() }
  } // else: home('/') — index.vue handles index.md

  // Global guest guard: allow only home and auth routes when not logged in
  if (!isLoggedIn.value && !(isHome.value || isAuthRoute.value)) {
    try { await router.replace('/login') } catch {}
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
      const container = e?.detail?.container
      const isDirectory = e?.detail?.isDirectory
      const originalPath = e?.detail?.originalPath
      
      if(!p) return
      
      // Handle directory links
      if (isDirectory) {
        // For directories, try to load the directory content or show in FileTree
        if (container === 'curriculum' || container === 'textbook') {
          // Try to load README.md first, if that fails, show directory in FileTree
          handleFileClick(p).catch(() => {
            // If README.md doesn't exist, show directory structure
            showDirectoryInFileTree(originalPath || p)
          })
        } else {
          showDirectoryInFileTree(originalPath || p)
        }
        return
      }
      
      // If caller specifies container, respect it
      if(container === 'curriculum' || container === 'textbook'){
        if(route.path.startsWith('/curriculum') || route.path.startsWith('/textbook')) handleFileClick(p)
        else try{ router.push({ path: '/curriculum', query: { path: p, force: '1' } }) }catch{ handleFileClick(p) }
        return
      }
      // Default: open based on current route
      if(isKnowledgeBase.value){ handleKbFileSelect(p) }
      else if(route.path.startsWith('/curriculum') || route.path.startsWith('/textbook')){ handleFileClick(p) }
      else { try{ router.push({ path: '/curriculum', query: { path: p, force: '1' } }) }catch{ handleFileClick(p) } }
    })
    window.addEventListener('kb:mode', (e) => {
      if(e?.detail?.to === 'view'){
        // 취소 동작 시 FileTree 탭으로 전환
        kbTab.value = 'tree'
      }
    })
    // 파일 삭제(휴지통 이동) 후 처리: FileTree 탭으로 전환하고 상태 정리
    window.addEventListener('kb:deleted', (e) => {
      try{
        kbTab.value = 'tree'
        if(docStore){ docStore.path = ''; docStore.content = '' }
        toast.push('success','문서가 휴지통으로 이동되었습니다')
      }catch{}
    })
  }
});

// 라우트 변경 시 커리큘럼 페이지로 전환되면 마지막 경로 복원
watch(() => route.path, async (p) => {
  // 클라이언트 사이드에서만 실행
  if (!isClient) return;
  
  // Scroll to top when route changes
  if (typeof window !== 'undefined') {
    window.scrollTo({ top: 0, behavior: 'smooth' });
  }
  
  // Global guest guard
  if (!isLoggedIn.value && !(isHome.value || isAuthRoute.value)) {
    try { await router.replace('/login') } catch {}
    return
  }
  if (p.startsWith('/curriculum') || p.startsWith('/textbook')) {
    // curriculum/textbook require login
    if (!isLoggedIn.value) {
      try { await router.replace({ path: '/login', query: { rd: encodeURIComponent(route.fullPath) } }) } catch {}
      return
    }
    try {
      const q = route.query || {}
      const forced = String(q.force || '') === '1'
      const target = String(q.path || '')
      const lastNew = typeof window !== 'undefined' ? localStorage.getItem('curriculum_last_path') : null
      const lastOld = typeof window !== 'undefined' ? localStorage.getItem('textbook_last_path') : null
      const last = lastNew || lastOld
      // 우선순위: 강제 대상 -> 최근 문서 -> 기본 인덱스
      if (forced && target && tbPath.value !== target) {
        await handleFileClick(target)
      } else if (!forced && last && tbPath.value !== last) {
        await handleFileClick(last)
      } else if (!tbPath.value) {
        await showCurriculumIndex()
      }
    } catch {}
    isSidebarCollapsed.value = false
  }
})
async function showCurriculumIndex(){
  // 1) Try curriculum.md first, then fallback to index.md
  try {
    const s = await fetch(`${apiBase}/v1/curriculum?curriculum_path=${encodeURIComponent(cleanApiPath('curriculum'))}`, { headers: { 'X-API-Key': apiKey } })
    if (s.ok) {
      const ct = (s.headers.get('content-type')||'').toLowerCase()
      if (ct.includes('application/pdf')){
        const blob = await s.blob();
        tbContent.value = '# curriculum\n\nPDF 슬라이드가 로드되었습니다.'
        tbSlide.value = { type: 'pdf', url: URL.createObjectURL(blob) }
      } else {
        tbContent.value = await s.text()
        tbSlide.value = null
      }
      tbPath.value = 'curriculum.md'
      return
    }
  } catch { /* ignore */ }
  
  // 2) Fallback to index.md
  try {
    const s = await fetch(`${apiBase}/v1/curriculum?curriculum_path=${encodeURIComponent(cleanApiPath('index'))}`, { headers: { 'X-API-Key': apiKey } })
    if (s.ok) {
      const ct = (s.headers.get('content-type')||'').toLowerCase()
      if (ct.includes('application/pdf')){
        const blob = await s.blob();
        tbContent.value = '# index\n\nPDF 슬라이드가 로드되었습니다.'
        tbSlide.value = { type: 'pdf', url: URL.createObjectURL(blob) }
      } else {
        tbContent.value = await s.text()
        tbSlide.value = null
      }
      tbPath.value = 'index.md'
      return
    }
  } catch { /* ignore */ }
  
  // 3) Public-only: no fallback to KB; show guidance
  tbContent.value = '# 공개 커리큘럼\n\n관리자가 공개한 자료가 없습니다.'
  tbSlide.value = null
  tbPath.value = ''
}

const handleFileClick = async (path) => {
  // Clean the path to prevent duplication and handle Korean filenames
  const cleanPath = preventPathDuplication(path)
  const preparedPath = prepareSafeApiPath(cleanPath) // 개선된 한글 URI 처리 사용
  
  // 진도 업데이트: 과정별 진도 관리
  updateProgressForFile(preparedPath)
  
  // 홈('/') 등에서는 '/textbook'로 전환하여 가운데 패널이 WorkspaceView를 렌더하도록 함
  try {
    if (!route.path.startsWith('/curriculum') && !route.path.startsWith('/textbook')) {
      await router.push({ path: '/curriculum', query: { path: preparedPath, force: '1' } })
      return
    }
  } catch { /* ignore navigation errors */ }
  try {
    tbPath.value = preparedPath;
    // persist last opened textbook file
    try {
      if (typeof window !== 'undefined') {
        localStorage.setItem('curriculum_last_path', path)
        localStorage.setItem('textbook_last_path', path) // legacy for compatibility
      }
    } catch {}

    const ext = getExt(path)
    // KB와 동일 정책: 미디어/문서는 새 탭(Blob URL)으로 열기
    if(['pdf','ppt','pptx','png','jpg','jpeg','gif','svg','webp','mp4','webm','mp3','wav'].includes(ext)){
      await openKbBinary(path)
      tbContent.value = ''
      tbSlide.value = null
      return
    }
    // 텍스트 계열은 중앙 패널에 표시
    if(ext === 'md' || ['txt','log','json','yaml','yml','csv'].includes(ext) || ext === ''){
      const s = await fetch(`${apiBase}/v1/curriculum?curriculum_path=${encodeURIComponent(cleanPath)}`, { headers: { 'X-API-Key': apiKey } })
      if (s.ok){
        tbContent.value = await s.text()
        tbSlide.value = null
      } else {
        tbContent.value = '# 공개되지 않은 자료입니다.'
        tbSlide.value = null
      }
      return
    }
    // 나머지(예: sh 등)는 다운로드
    await downloadKbFile(path)

  } catch (error) {
    console.error('Error fetching textbook content:', error);
    const msg = String(error?.message||'');
    if (msg.includes('403') || msg.toLowerCase().includes('forbidden')){
      tbContent.value = '# 읽기 권한이 필요한 문서입니다.'
      tbSlide.value = null
    } else {
      tbContent.value = `Error loading content. ${msg}`
      tbSlide.value = null
    }
  }
};

// 진도 업데이트 함수
function updateProgressForFile(filePath) {
  try {
    // 파일 경로에서 과정 정보 추출
    const pathParts = filePath.split('/').filter(Boolean)
    
    // 과정별 진도 관리 로직
    if (pathParts.length >= 2) {
      const courseId = pathParts[0] // 예: 'cloud_basic', 'cloud_master' 등
      const courseName = getCourseDisplayName(courseId)
      
      // 과정이 아직 초기화되지 않았다면 초기화
      if (!progressStore.userProgress[courseId]) {
        // 기본 총 단계 수 (실제로는 동적으로 계산해야 함)
        const totalSteps = getTotalStepsForCourse(courseId)
        progressStore.initializeCourseProgress(courseId, courseName, totalSteps)
      }
      
      // 현재 단계 설정
      const stepId = `${courseId}_${pathParts.join('_')}`
      progressStore.setCurrentStep(stepId)
      
      // 과정 전환
      progressStore.switchCourse(courseId)
    }
  } catch (error) {
    console.warn('Failed to update progress:', error)
  }
}

// 과정 표시 이름 매핑
function getCourseDisplayName(courseId) {
  const courseNames = {
    'cloud_basic': '클라우드 기초',
    'cloud_master': '클라우드 마스터',
    'cloud_container': '클라우드 컨테이너',
    'curriculum': '커리큘럼',
    'textbook': '교재'
  }
  return courseNames[courseId] || courseId
}

// 과정별 총 단계 수 (실제로는 동적으로 계산해야 함)
function getTotalStepsForCourse(courseId) {
  const stepCounts = {
    'cloud_basic': 30,
    'cloud_master': 40,
    'cloud_container': 35,
    'curriculum': 20,
    'textbook': 15
  }
  return stepCounts[courseId] || 10
}

// 디렉토리를 FileTree에서 보여주는 함수
const showDirectoryInFileTree = (directoryPath) => {
  console.log('Showing directory in FileTree:', directoryPath)
  
  // FileTree에서 해당 디렉토리로 이동
  // 이 부분은 SyllabusExplorer 컴포넌트의 기능을 활용
  window.dispatchEvent(new CustomEvent('filetree:navigate', {
    detail: { path: directoryPath }
  }))
  
  // 사용자에게 알림
  toast.push('info', `디렉토리 "${directoryPath}"를 FileTree에서 확인하세요`)
}

const handleKbFileSelect = async (path) => {
  activeSlide.value = null
  if(activePath.value && activePath.value !== path){ kbHistory.value.push(activePath.value) }
  await docStore.open(path)
  if(docStore.error) toast.push('error','로드 실패: ' + docStore.error)
}

function goKbBack(){
  const prev = kbHistory.value.pop()
  if(!prev) return
  handleKbFileSelect(prev)
}

const handleKbSave = async ({ path, content, message, force }) => {
  if(force){
    // force bypass optimistic (call API directly)
    try {
      const config = useRuntimeConfig();
      const apiBase = config.public.apiBaseUrl || '/api';
      await fetch(`${apiBase}/v1/knowledge-base/item`, { method:'PATCH', headers:{ 'Content-Type':'application/json','X-API-Key':'my_mcp_eagle_tiger' }, body: JSON.stringify({ path, content, message }) })
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

function getExt(p){
  const i = p.lastIndexOf('.')
  return i >= 0 ? p.slice(i+1).toLowerCase() : ''
}

async function openKbBinary(path){
  try{
    const r = await fetch(`${apiBase}/v1/knowledge-base/file?path=${encodeURIComponent(path)}`, { headers: { 'X-API-Key': apiKey } })
    if(!r.ok){ toast.push('error', '파일 열기 실패: ' + r.status); return }
    const blob = await r.blob()
    const url = URL.createObjectURL(blob)
    // 새 탭에서 열기
    window.open(url, '_blank', 'noopener,noreferrer')
  }catch(e){ toast.push('error','파일 로드 오류') }
}

async function downloadKbFile(path){
  try{
    const r = await fetch(`${apiBase}/v1/knowledge-base/file?path=${encodeURIComponent(path)}`, { headers: { 'X-API-Key': apiKey } })
    if(!r.ok){ toast.push('error', '다운로드 실패: ' + r.status); return }
    const blob = await r.blob()
    const url = URL.createObjectURL(blob)
    const a = document.createElement('a')
    a.href = url
    a.download = path.split('/').pop() || 'download'
    document.body.appendChild(a)
    a.click()
    a.remove()
    URL.revokeObjectURL(url)
  }catch(e){ toast.push('error','다운로드 오류') }
}

async function onTreeSelect(p){
  const ext = getExt(p)
  // md: 편집기로 열기, 텍스트 계열: 읽기 뷰(마크다운 탭)로 열기
  if(ext === 'md'){
    await handleKbFileSelect(p)
    kbTab.value = 'tiptap'
    return
  }
  if(['txt','log','json','yaml','yml','csv'].includes(ext)){
    await handleKbFileSelect(p)
    kbTab.value = 'markdown'
    return
  }
  // 미디어/문서: 바이너리로 열기 또는 다운로드
  if(['pdf','ppt','pptx','png','jpg','jpeg','gif','svg','webp','mp4','webm','mp3','wav'].includes(ext)){
    await openKbBinary(p)
    return
  }
  // 나머지는 다운로드만
  await downloadKbFile(p)
}
// KB 인덱스 문서 보장: index.md 우선 시도, 없으면 생성
async function ensureKbIndex(){
  try{
    await handleKbFileSelect('index.md')
    if(docStore.error){ throw new Error(docStore.error) }
  }catch{
    try{
      await fetch(`${apiBase}/v1/knowledge-base/item`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json', 'X-API-Key': apiKey },
        body: JSON.stringify({ path: 'index.md', type: 'file', content: '# Knowledge Base\n\n시작 문서입니다.' })
      })
      await handleKbFileSelect('index.md')
      kbTab.value = 'tiptap'
    }catch{
      // 최후 수단: 안내 메시지
      activeSlide.value = null
      docStore.content = '# Knowledge Base\n\n좌측에서 문서를 선택하거나 index.md를 생성하세요.'
      docStore.path = 'index.md'
    }
  }
}

async function switchKbTab(next){
  if(next === kbTab.value) return
  if(!activePath.value){ kbTab.value = next; return }
  // ensure the current doc is loaded before switching to an editor tab
  try { await docStore.whenLoaded(activePath.value) } catch {}
  // force re-render editors to avoid stale content when switching quickly
  kbTab.value = next
  // focus into the editor after tab switch
  try{ setTimeout(()=>{ if(typeof window!=='undefined') window.dispatchEvent(new CustomEvent('kb:focus', { detail:{ tab: next, path: activePath.value }})) }, 0) }catch{}
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