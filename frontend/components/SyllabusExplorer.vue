<template>
  <div class="p-4 select-none">
    <div class="flex items-center justify-between mb-4">
      <h3 class="text-lg font-semibold whitespace-nowrap text-gray-800">
        카테고리
      </h3>
      <button @click="toggleHiddenFiles" class="px-2 py-1 text-xs border rounded" :class="showHiddenFiles ? 'bg-blue-100 text-blue-700' : 'bg-gray-100 text-gray-700'" title="숨김 파일 표시/숨김">
        {{ showHiddenFiles ? '숨김 파일 숨기기' : '숨김 파일 보기' }}
      </button>
    </div>
    <div v-if="loading">Loading...</div>
    <div v-if="error">{{ error }}</div>
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

const filteredTopics = computed(() => {
  const q = (search.value || '').toLowerCase()
  const base = (topics.value || []).filter(t => Array.isArray(t?.messages) && t.messages.length > 0)
  if (!q) return base
  return base.filter(t => (t.name || '').toLowerCase().includes(q))
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
  emit('file-click', path);
};

// Toggle hidden files visibility
const toggleHiddenFiles = async () => {
  showHiddenFiles.value = !showHiddenFiles.value;
  loading.value = true;
  try {
    // KB 전체 트리 다시 로드
    const r1 = await fetch(`${apiBase}/v1/knowledge-base/tree?show_hidden=${showHiddenFiles.value}`, { headers: { 'X-API-Key': apiKey } });
    if (r1.ok) {
      kbTree.value = await r1.json();
    }
    
    // 커리큘럼 트리도 다시 로드
    await loadcurriculumTreeIfCurriculum();
  } catch (e) {
    error.value = e.message;
  } finally {
    loading.value = false;
  }
};

async function loadcurriculumTreeIfCurriculum(){
  if (curriculumLoading.value) return
  try{
    const route = useRoute()
    const p = String(route?.path || '')
    if (!(p.startsWith('/curriculum') || p.startsWith('/textbook'))) return
    curriculumLoading.value = true
    // 선택 디렉토리
    const r2 = await fetch(`${apiBase}/v1/curriculum/selection`, { headers: { 'X-API-Key': apiKey } });
    const sel = await r2.json();
    selectedDirs.value = Array.isArray(sel?.selected_dirs) ? sel.selected_dirs : []
    // 선택 디렉토리를 기준으로 서버가 머지한 트리 가져오기 (중첩 경로 지원)
    const r3 = await fetch(`${apiBase}/v1/curriculum/tree?show_hidden=${showHiddenFiles.value}`, { headers: { 'X-API-Key': apiKey } });
    if (r3.ok) {
      curriculumTree.value = await r3.json();
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
    const r1 = await fetch(`${apiBase}/v1/knowledge-base/tree?show_hidden=${showHiddenFiles.value}`, { headers: { 'X-API-Key': apiKey } });
    if (!r1.ok) throw new Error('Failed to fetch KB tree');
    kbTree.value = await r1.json();

    if (isTextbookPage) { await loadcurriculumTreeIfCurriculum() }
  } catch (e) {
    error.value = e.message;
  } finally {
    loading.value = false;
  }

  loadTopics()
  // 우측 패널에서 변경 시 동기화
  if (typeof window !== 'undefined') {
    window.addEventListener('mcp:terminal:topics-updated', loadTopics)
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
  // curriculumTree가 있으면 우선 사용 (서버에서 중첩 경로 포함 머지된 결과)
  if (curriculumTree.value) return curriculumTree.value
  // fallback: 기존 KB 트리 + 1레벨 필터
  const t = kbTree.value || {}
  const picked = selectedDirs.value || []
  if(!picked.length) return t
  const filtered = {}
  for(const key of picked){ if(t[key]) filtered[key] = t[key] }
  return filtered
})
</script>
