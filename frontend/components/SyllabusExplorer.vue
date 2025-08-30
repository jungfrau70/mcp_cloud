<template>
  <div class="p-4 select-none">
    <h3 class="text-lg font-semibold mb-4 whitespace-nowrap text-gray-800">
      카테고리
    </h3>
    <div v-if="loading">Loading...</div>
    <div v-if="error">{{ error }}</div>
    <div v-if="displayTree">
      <FileTreePanel
        :tree="displayTree"
        :selected-file="null"
        @file-select="onFileClick"
        @file-open="onFileClick"
      />
    </div>

    

    <!-- 채팅 섹션 -->
    <div class="mt-6">
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
import { ref, onMounted, computed } from 'vue';
import FileTreePanel from './FileTreePanel.vue';
import { useRuntimeConfig } from '#app'

const kbTree = ref(null);
const slidesTree = ref(null);
const loading = ref(false);
const error = ref(null);
// 관리자 설정 UI는 지식베이스로 이동

const config = useRuntimeConfig()
function resolveApiBase(){
  const configured = (config.public?.apiBaseUrl) || '/api'
  if (typeof window !== 'undefined'){
    try{ const u = new URL(configured); if(u.origin==='null') return configured; const host = window.location.hostname; const port = u.port || '8000'; if(!['localhost','127.0.0.1','api.gostock.us',host].includes(u.hostname)) { const scheme = u.protocol.replace(':','') || 'https'; return `${scheme}://${host}:${port}` } }catch{}
  }
  return configured
}
const apiBase = resolveApiBase()
const apiKey = 'my_mcp_eagle_tiger'

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

const emit = defineEmits(['file-click']);

const onFileClick = (path) => {
  emit('file-click', path);
};

onMounted(async () => {
  loading.value = true;
  try {
    // KB 전체 트리
    const r1 = await fetch(`${apiBase}/api/v1/knowledge-base/tree`, { headers: { 'X-API-Key': apiKey } });
    if (!r1.ok) throw new Error('Failed to fetch KB tree');
    kbTree.value = await r1.json();
    // 선택 디렉토리
    const r2 = await fetch(`${apiBase}/api/v1/slides/selection`, { headers: { 'X-API-Key': apiKey } });
    const sel = await r2.json();
    selectedDirs.value = Array.isArray(sel?.selected_dirs) ? sel.selected_dirs : []
    // 선택 디렉토리를 기준으로 서버가 머지한 트리 가져오기 (중첩 경로 지원)
    const r3 = await fetch(`${apiBase}/api/v1/slides/tree`, { headers: { 'X-API-Key': apiKey } });
    if (r3.ok) {
      slidesTree.value = await r3.json();
    }
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

// Open root slide when clicking the title
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
  // slidesTree가 있으면 우선 사용 (서버에서 중첩 경로 포함 머지된 결과)
  if (slidesTree.value) return slidesTree.value
  // fallback: 기존 KB 트리 + 1레벨 필터
  const t = kbTree.value || {}
  const picked = selectedDirs.value || []
  if(!picked.length) return t
  const filtered = {}
  for(const key of picked){ if(t[key]) filtered[key] = t[key] }
  return filtered
})
</script>
