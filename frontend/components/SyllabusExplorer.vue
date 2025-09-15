<template>
  <div class="p-4 select-none">
    <div class="flex items-center justify-between mb-4">
      <h3 class="text-lg font-semibold whitespace-nowrap text-gray-800">
        카테고리
      </h3>
      <!-- <button @click="toggleHiddenFiles" class="px-2 py-1 text-xs border rounded" :class="showHiddenFiles ? 'bg-blue-100 text-blue-700' : 'bg-gray-100 text-gray-700'" title="숨김 파일 표시/숨김">
        {{ showHiddenFiles ? '숨김 파일 숨기기' : '숨김 파일 보기' }}
      </button> -->
    </div>
    <div v-if="loading">Loading...</div>
    <div v-if="error">{{ error }}</div>
    <!-- 최근 오픈파일 섹션 -->
    <div class="mb-6" v-if="recentFiles.length > 0">
      <div class="flex items-center justify-between mb-2">
        <h4 class="text-sm font-semibold text-gray-800">최근 파일</h4>
        <button class="text-xs px-2 py-1 bg-gray-100 text-gray-700 rounded hover:bg-gray-200" @click="clearRecentFiles" title="최근 파일 목록 지우기">
          지우기
        </button>
      </div>
      <ul class="space-y-1">
        <li v-for="file in recentFiles.slice(0, 3)" :key="file.path" class="flex items-center justify-between group">
          <button 
            class="text-left text-sm w-full truncate px-2 py-1 rounded hover:bg-gray-100 flex items-center" 
            @click="onFileClick(file.path)" 
            :title="file.path"
          >
            <span class="mr-2">📄</span>
            <span class="truncate">{{ getFileName(file.path) }}</span>
          </button>
          <button 
            class="opacity-0 group-hover:opacity-100 text-gray-500 hover:text-red-600 px-2" 
            title="최근 목록에서 제거" 
            @click="removeFromRecentFiles(file.path)"
          >
            ×
          </button>
        </li>
      </ul>
    </div>

    <!-- 커리큘럼 설정 상태 표시 -->
    <div v-if="selectedDirs.length === 0" class="mb-4 p-3 bg-yellow-50 border border-yellow-200 rounded-lg">
      <div class="flex items-center justify-between">
        <div class="flex items-center space-x-2">
          <div class="w-2 h-2 bg-yellow-400 rounded-full"></div>
          <span class="text-sm text-yellow-800">커리큘럼 디렉토리가 설정되지 않았습니다.</span>
        </div>
        <button 
          @click="openCurriculumSettings" 
          class="text-xs px-2 py-1 bg-yellow-100 text-yellow-700 rounded hover:bg-yellow-200"
        >
          설정하기
        </button>
      </div>
    </div>

    <!-- 학습 진척률 표시 -->
    <div v-if="displayTree && selectedDirs.length > 0" class="mb-4 p-3 bg-blue-50 border border-blue-200 rounded-lg">
      <div class="flex items-center justify-between mb-2">
        <h4 class="text-sm font-semibold text-blue-800">학습 진척률</h4>
        <span class="text-xs text-blue-600">{{ overallProgress }}% 완료</span>
      </div>
      <div class="w-full bg-blue-200 rounded-full h-2">
        <div 
          class="bg-blue-600 h-2 rounded-full transition-all duration-300 ease-in-out" 
          :style="{ width: `${overallProgress}%` }"
        ></div>
      </div>
      <div class="mt-2 text-xs text-blue-700">
        <span>{{ completedFiles }}개 파일 완료 / {{ totalFiles }}개 파일</span>
      </div>
    </div>

    <div v-if="displayTree">
      <FileTreePanel
        :tree="displayTree"
        :selected-file="props.selectedFile"
        :show-hidden-files="showHiddenFiles"
        @file-select="onFileClick"
        @file-open="onFileClick"
      />
    </div>

    

    <!-- 채팅 섹션 (커리큘럼/텍스트북에서는 Tutor/Admin만 표시) -->
    <div class="mt-6" v-if="showChatSection">
      <div class="flex items-center justify-between mb-2">
        <h4 class="text-sm font-semibold text-gray-800">채팅</h4>
        <button class="text-xs px-2 py-1 bg-blue-600 text-white rounded" @click="startNewChat">새 채팅</button>
      </div>
      <div class="mb-2">
        <input
          v-model="search"
          type="text"
          placeholder="채팅 검색"
          class="w-full px-2 py-1 border rounded text-sm"
        />
      </div>
      <ul class="space-y-1">
        <li v-for="t in filteredTopics" :key="t.id" class="flex items-center justify-between group">
          <button class="text-left text-sm w-full truncate px-2 py-1 rounded hover:bg-gray-100" @click="selectTopic(t.id)" :title="t.name">
            {{ shortTitle(t.name) }}
          </button>
          <button class="opacity-0 group-hover:opacity-100 text-gray-500 hover:text-red-600 px-2" title="삭제" @click="deleteTopic(t.id)">×</button>
        </li>
      </ul>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, computed, watch } from 'vue';
import { useRoute } from 'vue-router'
import { useAuthStore } from '~/stores/auth'
import FileTreePanel from './FileTreePanel.vue';
import { useRuntimeConfig } from '#app'
import { makeUriDisplayFriendly, handleKoreanFilename } from '~/utils/path'

const kbTree = ref(null);
const curriculumTree = ref(null);
const loading = ref(false);
const error = ref(null);
const showHiddenFiles = ref(true); // 기본값을 true로 설정하여 숨김파일이 기본적으로 보이도록 함
// 관리자 설정 UI는 지식베이스로 이동

const config = useRuntimeConfig()
const apiBase = (config.public?.apiBaseUrl) || '/api'
const apiKey = (useRuntimeConfig().public?.apiKey) || 'my_mcp_eagle_tiger'
const curriculumLoading = ref(false)

// 통합터미널 주제 관리 동기화 (guest 기준)
const userKey = 'guest'
const storageKey = `mcp_terminal_topics_${userKey}`
const topics = ref([])
const search = ref('')

// 최근 오픈파일 관리
const recentFilesKey = `recent_files_${userKey}`
const recentFiles = ref([])

// 커리큘럼 선택된 디렉토리 관리
const selectedCurriculumDirs = ref([])
const curriculumDirsLoading = ref(false)

// 학습 진척률 관리
const completedFiles = ref(new Set())
const totalFiles = ref(0)

const filteredTopics = computed(() => {
  const q = (search.value || '').toLowerCase()
  const base = (topics.value || []).filter(t => Array.isArray(t?.messages) && t.messages.length > 0)
  if (!q) return base
  return base.filter(t => (t.name || '').toLowerCase().includes(q))
})

// 학습 진척률 계산
const overallProgress = computed(() => {
  if (totalFiles.value === 0) return 0
  return Math.round((completedFiles.value.size / totalFiles.value) * 100)
})

// Visibility guard for chat section
const route = useRoute()
const auth = useAuthStore()
try { auth.loadFromStorage?.() } catch {}
const isCurriculum = computed(() => {
  try { return typeof route?.path === 'string' && (route.path.startsWith('/curriculum') || route.path.startsWith('/textbook')) } catch { return false }
})
const isTutorOrAdmin = computed(() => {
  const r = String(auth.role || '').toLowerCase()
  return r === 'tutor' || r === 'admin' || r === 'administrator'
})
const showChatSection = computed(() => !isCurriculum.value || isTutorOrAdmin.value)

function loadTopics() {
  try {
    if (typeof window !== 'undefined' && typeof localStorage !== 'undefined') {
      const saved = localStorage.getItem(storageKey)
      topics.value = saved ? JSON.parse(saved) : []
    } else {
      topics.value = []
    }
  } catch {
    topics.value = []
  }
}

function persistTopics() {
  if (typeof window !== 'undefined' && typeof localStorage !== 'undefined') {
    localStorage.setItem(storageKey, JSON.stringify(topics.value))
  }
}

function shortTitle(name) {
  if (!name) return '제목 없음'
  return name.length > 18 ? name.slice(0, 18) + '…' : name
}

// 최근 오픈파일 관련 함수들
function loadRecentFiles() {
  try {
    if (typeof window !== 'undefined' && typeof localStorage !== 'undefined') {
      const saved = localStorage.getItem(recentFilesKey)
      recentFiles.value = saved ? JSON.parse(saved) : []
    } else {
      recentFiles.value = []
    }
  } catch {
    recentFiles.value = []
  }
}

function saveRecentFiles() {
  if (typeof window !== 'undefined' && typeof localStorage !== 'undefined') {
    localStorage.setItem(recentFilesKey, JSON.stringify(recentFiles.value))
  }
}

function addToRecentFiles(filePath) {
  if (!filePath) return
  
  // 기존 항목 제거 (중복 방지)
  recentFiles.value = recentFiles.value.filter(file => file.path !== filePath)
  
  // 새 항목을 맨 앞에 추가
  const fileName = getFileName(filePath)
  recentFiles.value.unshift({
    path: filePath,
    name: fileName,
    timestamp: Date.now()
  })
  
  // 최대 10개까지만 유지
  if (recentFiles.value.length > 10) {
    recentFiles.value = recentFiles.value.slice(0, 10)
  }
  
  saveRecentFiles()
}

function removeFromRecentFiles(filePath) {
  recentFiles.value = recentFiles.value.filter(file => file.path !== filePath)
  saveRecentFiles()
}

function clearRecentFiles() {
  recentFiles.value = []
  saveRecentFiles()
}

// 커리큘럼 설정 열기
function openCurriculumSettings() {
  // 지식베이스 탐색기로 이동하여 커리큘럼 설정 모달 열기
  if (typeof window !== 'undefined') {
    window.dispatchEvent(new CustomEvent('open-curriculum-settings'))
  }
}

// 커리큘럼 선택된 디렉토리 로딩
async function loadSelectedCurriculumDirs() {
  curriculumDirsLoading.value = true
  try {
    const response = await fetch(`${apiBase}/v1/curriculum/selection`, {
      headers: { 'X-API-Key': apiKey }
    })
    if (response.ok) {
      const data = await response.json()
      selectedCurriculumDirs.value = Array.isArray(data?.selected_dirs) ? data.selected_dirs : []
    } else {
      selectedCurriculumDirs.value = []
    }
  } catch (error) {
    console.error('커리큘럼 디렉토리 로딩 실패:', error)
    selectedCurriculumDirs.value = []
  } finally {
    curriculumDirsLoading.value = false
  }
}

// 파일 트리에서 파일 개수 계산
function countFilesInTree(tree) {
  let count = 0
  if (!tree || typeof tree !== 'object') return count
  
  for (const key in tree) {
    if (key === 'files' && Array.isArray(tree[key])) {
      count += tree[key].length
    } else if (typeof tree[key] === 'object') {
      count += countFilesInTree(tree[key])
    }
  }
  return count
}

// 학습 진척률 업데이트
function updateProgress() {
  if (curriculumTree.value) {
    totalFiles.value = countFilesInTree(curriculumTree.value)
    // localStorage에서 완료된 파일 목록 로드
    loadCompletedFiles()
  }
}

// 완료된 파일 목록 로드
function loadCompletedFiles() {
  try {
    if (typeof window !== 'undefined' && typeof localStorage !== 'undefined') {
      const saved = localStorage.getItem(`completed_files_${userKey}`)
      if (saved) {
        const completed = JSON.parse(saved)
        completedFiles.value = new Set(completed)
      }
    }
  } catch (error) {
    console.error('완료된 파일 목록 로드 실패:', error)
    completedFiles.value = new Set()
  }
}

// 완료된 파일 목록 저장
function saveCompletedFiles() {
  try {
    if (typeof window !== 'undefined' && typeof localStorage !== 'undefined') {
      localStorage.setItem(`completed_files_${userKey}`, JSON.stringify([...completedFiles.value]))
    }
  } catch (error) {
    console.error('완료된 파일 목록 저장 실패:', error)
  }
}

// 파일 완료 상태 토글
function toggleFileCompletion(filePath) {
  if (completedFiles.value.has(filePath)) {
    completedFiles.value.delete(filePath)
  } else {
    completedFiles.value.add(filePath)
  }
  saveCompletedFiles()
}

function getFileName(filePath) {
  if (!filePath) return 'Unknown'
  const parts = filePath.split('/')
  const filename = parts[parts.length - 1] || filePath
  // 한글 파일명을 읽기 쉽게 디코딩
  return handleKoreanFilename(filename, 'decode')
}

function deleteTopic(id) {
  const idx = topics.value.findIndex(t => t.id === id)
  if (idx >= 0) {
    // 삭제되는 채팅이 현재 활성 채팅인지 확인
    const isCurrentActive = typeof window !== 'undefined' ? id === window.currentActiveTopicId : false
    
    topics.value.splice(idx, 1)
    persistTopics()
    
    // 삭제된 채팅이 현재 활성 채팅이었다면 새 채팅 화면으로 전환
    if (isCurrentActive) {
      // 새 채팅 생성 및 선택
      const newId = (typeof crypto !== 'undefined' && crypto.randomUUID) ? crypto.randomUUID() : String(Date.now())
      const newTopic = { id: newId, name: '새 대화', conversationId: null, messages: [] }
      topics.value.unshift(newTopic)
      persistTopics()
      
      // 새 채팅으로 전환
      selectTopic(newTopic.id)
      
      // 우측 패널에 새 채팅 전환 알림
      if (typeof window !== 'undefined') {
        window.dispatchEvent(new CustomEvent('mcp:terminal:topic-deleted-and-refresh', { 
          detail: { deletedId: id, newTopicId: newTopic.id } 
        }))
      }
    }
  }
}

function selectTopic(id) {
  // 전역적으로 현재 활성 채팅 ID 업데이트
  if (typeof window !== 'undefined') {
    window.currentActiveTopicId = id
  }
  
  if (typeof window !== 'undefined') {
    window.dispatchEvent(new CustomEvent('mcp:terminal:select-topic', { detail: { id } }))
  }
}

function startNewChat() {
  const newId = (typeof crypto !== 'undefined' && crypto.randomUUID) ? crypto.randomUUID() : String(Date.now())
  const newTopic = { id: newId, name: '새 대화', conversationId: null, messages: [] }
  topics.value.unshift(newTopic)
  persistTopics()
  
  // 전역적으로 현재 활성 채팅 ID 업데이트
  if (typeof window !== 'undefined') {
    window.currentActiveTopicId = newTopic.id
  }
  
  selectTopic(newTopic.id)
  // 우측 패널 입력창 포커스 및 목록 싱크를 위해 이벤트 발행
  if (typeof window !== 'undefined') {
    window.dispatchEvent(new Event('mcp:terminal:topics-updated'))
  }
}

const props = defineProps({
  selectedFile: {
    type: String,
    default: null
  }
});

const emit = defineEmits(['file-click']);

const onFileClick = (path) => {
  // 최근 파일 목록에 추가 (읽기 쉬운 형태로 저장)
  const displayPath = makeUriDisplayFriendly(path);
  addToRecentFiles(displayPath);
  
  // 파일 완료 상태 토글 (Ctrl+클릭으로 완료 표시)
  if (event && event.ctrlKey) {
    event.preventDefault();
    toggleFileCompletion(path);
    return;
  }
  
  emit('file-click', path);
};

// Toggle hidden files visibility - 제거됨 (버튼이 제거되어 더 이상 사용되지 않음)
// const toggleHiddenFiles = async () => {
//   showHiddenFiles.value = !showHiddenFiles.value;
//   loading.value = true;
//   try {
//     // KB 전체 트리 다시 로드
//     const r1 = await fetch(`${apiBase}/v1/curriculum/tree?show_hidden=${showHiddenFiles.value}`, { headers: { 'X-API-Key': apiKey } });
//     if (r1.ok) {
//       kbTree.value = await r1.json();
//     }
//     
//     // 커리큘럼 트리도 다시 로드
//     await loadcurriculumTreeIfCurriculum();
//   } catch (e) {
//     error.value = e.message;
//   } finally {
//     loading.value = false;
//   }
// };

async function loadcurriculumTreeIfCurriculum(){
  if (curriculumLoading.value) return
  try{
    const route = useRoute()
    const p = String(route?.path || '')
    if (!(p.startsWith('/curriculum') || p.startsWith('/textbook'))) return
    curriculumLoading.value = true
    console.log('🔍 커리큘럼 트리 로드 시작...')
    
    // 선택 디렉토리
    const r2 = await fetch(`${apiBase}/v1/curriculum/selection`, { headers: { 'X-API-Key': apiKey } });
    const sel = await r2.json();
    selectedDirs.value = Array.isArray(sel?.selected_dirs) ? sel.selected_dirs : []
    console.log('📁 선택된 디렉토리:', selectedDirs.value)
    
    // 선택 디렉토리를 기준으로 서버가 머지한 트리 가져오기 (중첩 경로 지원)
    const r3 = await fetch(`${apiBase}/v1/curriculum/tree?show_hidden=${showHiddenFiles.value}`, { headers: { 'X-API-Key': apiKey } });
    if (r3.ok) {
      curriculumTree.value = await r3.json();
      console.log('🌳 커리큘럼 트리 로드 완료:', curriculumTree.value)
      // 진척률 업데이트
      updateProgress();
    } else {
      console.error('❌ 커리큘럼 트리 로드 실패:', r3.status, r3.statusText)
    }
  } finally { curriculumLoading.value = false }
}

onMounted(async () => {
  loading.value = true;
  try {
    // 슬라이드 관련 호출은 커리큘럼 페이지에서만 수행
    let isTextbookPage = false
    let currentPath = ''
    try {
      const route = useRoute()
      currentPath = typeof route?.path === 'string' ? route.path : ''
      isTextbookPage = currentPath.startsWith('/curriculum') || currentPath.startsWith('/textbook')
    } catch {}

    // KB 전체 트리
    const r1 = await fetch(`${apiBase}/v1/curriculum/tree?show_hidden=${showHiddenFiles.value}`, { headers: { 'X-API-Key': apiKey } });
    if (!r1.ok) throw new Error('Failed to fetch KB tree');
    kbTree.value = await r1.json();

    if (isTextbookPage) { await loadcurriculumTreeIfCurriculum() }
  } catch (e) {
    error.value = e.message;
  } finally {
    loading.value = false;
  }

  loadTopics()
  loadRecentFiles()
  // 우측 패널에서 변경 시 동기화
  if (typeof window !== 'undefined') {
    window.addEventListener('mcp:terminal:topics-updated', loadTopics)
    // 커리큘럼 설정 변경 시 트리 새로고침
    window.addEventListener('curriculum-settings-changed', () => {
      curriculumTree.value = null // 캐시 초기화
      loadcurriculumTreeIfCurriculum()
    })
  }
});

// 라우트가 커리큘럼으로 전환될 때 슬라이드 트리/선택 갱신
try{
  const route = useRoute()
  watch(() => route.path, async (p) => {
    try{
      if (typeof p === 'string' && (p.startsWith('/curriculum') || p.startsWith('/textbook'))){ await loadcurriculumTreeIfCurriculum() }
    }catch{ /* ignore */ }
  })
}catch{ /* ignore */ }

// FileTree 네비게이션 이벤트 처리
const handleFileTreeNavigate = (event) => {
  const targetPath = event?.detail?.path;
  if (!targetPath) return;
  
  // FileTree에서 해당 경로로 스크롤 및 하이라이트
  nextTick(() => {
    try {
      // curriculum tree에서 해당 파일 찾기
      const findFileInTree = (tree, path) => {
        if (!tree || typeof tree !== 'object') return null;
        
        // files 배열에서 찾기
        if (tree.files && Array.isArray(tree.files)) {
          const file = tree.files.find(f => f.path === path);
          if (file) return file;
        }
        
        // 하위 디렉토리에서 재귀적으로 찾기
        for (const [key, value] of Object.entries(tree)) {
          if (key !== 'files' && typeof value === 'object') {
            const found = findFileInTree(value, path);
            if (found) return found;
          }
        }
        
        return null;
      };
      
      const file = findFileInTree(displayTree.value, targetPath);
      if (file) {
        // 해당 파일 요소 찾기 및 스크롤
        const fileElement = document.querySelector(`.tree-item.is-file[data-path="${CSS.escape(targetPath)}"]`);
        if (fileElement) {
          fileElement.scrollIntoView({ 
            behavior: 'smooth', 
            block: 'center' 
          });
          
          // 하이라이트 효과
          fileElement.classList.add('bg-blue-100', 'border-blue-300');
          setTimeout(() => {
            fileElement.classList.remove('bg-blue-100', 'border-blue-300');
          }, 2000);
        }
      }
    } catch (error) {
      console.warn('Failed to navigate to file in FileTree:', error);
    }
  });
};

// FileTree 네비게이션 이벤트 리스너 등록
onMounted(() => {
  if (typeof window !== 'undefined') {
    window.addEventListener('filetree:navigate', handleFileTreeNavigate);
  }
});

onUnmounted(() => {
  if (typeof window !== 'undefined') {
    window.removeEventListener('filetree:navigate', handleFileTreeNavigate);
  }
});

// Open root Curriculum when clicking the title
const openCurriculum = () => {
  // 표시 트리의 첫 파일 열기
  const t = displayTree.value
  if (t && t.files && t.files.length > 0) {
    emit('file-click', t.files[0].path);
  }
};

// 선택된 디렉토리만 필터링해 표시
const selectedDirs = ref([])
const displayTree = computed(() => {
  console.log('🔄 displayTree 계산 중...')
  console.log('📊 curriculumTree:', curriculumTree.value)
  console.log('📊 kbTree:', kbTree.value)
  console.log('📊 selectedDirs:', selectedDirs.value)
  
  // curriculumTree가 있으면 우선 사용 (서버에서 중첩 경로 포함 머지된 결과)
  if (curriculumTree.value) {
    console.log('✅ curriculumTree 사용')
    return curriculumTree.value
  }
  
  // fallback: 기존 KB 트리 + 1레벨 필터
  const t = kbTree.value || {}
  const picked = selectedDirs.value || []
  if(!picked.length) {
    console.log('⚠️ 선택된 디렉토리 없음, 전체 KB 트리 사용')
    return t
  }
  
  console.log('🔧 KB 트리에서 필터링 적용')
  const filtered = {}
  for(const key of picked){ if(t[key]) filtered[key] = t[key] }
  console.log('📋 필터링된 트리:', filtered)
  return filtered
})
</script>
