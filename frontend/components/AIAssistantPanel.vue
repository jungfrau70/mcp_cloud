<template>
  <div class="h-full flex flex-col bg-white">

    <!-- 메시지/출력 영역 -->
    <div class="flex-grow overflow-y-auto p-4 space-y-2" ref="messagesEl">
      <template v-if="activeMessages.length">
        <div v-for="(m, i) in activeMessages" :key="i" :class="m.role === 'user' ? 'text-right' : 'text-left'">
          <div :class="m.role === 'user' ? 'inline-block bg-blue-100 rounded px-3 py-2' : 'inline-block bg-gray-100 rounded px-3 py-2'">
            <pre v-if="m.mode==='cli'" class="whitespace-pre-wrap font-mono text-xs">{{ m.text }}</pre>
            <div v-else v-html="formatMessage(m.text)" class="text-sm"></div>
          </div>
        </div>
      </template>
      <template v-else>
        <div v-if="!canUseChat" class="h-full flex flex-col items-center justify-center text-center text-gray-500 select-none p-4">
          <div class="text-2xl font-semibold mb-2 text-orange-600">AI 채팅을 사용하려면</div>
          <div class="text-sm mb-4">Gemini API 키가 필요합니다.</div>
          <div class="bg-orange-50 border border-orange-200 rounded-lg p-4 mb-4 max-w-sm">
            <div class="text-sm text-orange-800 mb-2">
              <strong>API 키 설정 방법:</strong>
            </div>
            <ol class="text-xs text-orange-700 text-left space-y-1">
              <li>1. 프로필 페이지로 이동</li>
              <li>2. "Gemini API 키 설정" 섹션에서 키 입력</li>
              <li>3. <a href="https://makersuite.google.com/app/apikey" target="_blank" class="text-blue-600 underline">Google AI Studio</a>에서 무료 발급</li>
            </ol>
          </div>
          <button @click="goToProfile" class="px-4 py-2 bg-orange-600 text-white rounded-lg hover:bg-orange-700 text-sm">
            프로필로 이동
          </button>
        </div>
        <div v-else class="h-full flex flex-col items-center justify-center text-center text-gray-500 select-none">
          <div class="text-2xl font-semibold mb-2">준비되면 얘기해 주세요.</div>
          <div class="text-sm mb-4">/cli 로 시작하면 시스템 명령을 실행합니다.</div>
          <div class="flex gap-2">
            <button class="px-3 py-1 border rounded-full text-xs" @click="quick('/cli gcloud auth list')">gcloud auth list</button>
            <button class="px-3 py-1 border rounded-full text-xs" @click="quick('AWS와 GCP 비교 요약해줘')">AWS vs GCP</button>
            <button class="px-3 py-1 border rounded-full text-xs" @click="quick('VPC 기본 설계 알려줘')">VPC 설계</button>
          </div>
        </div>
      </template>
    </div>

    <!-- 입력 영역 -->
    <div v-if="canUseChat" class="border-t border-gray-200 p-5 flex-shrink-0">
      <form @submit.prevent="send" class="flex items-center gap-2">
        <div class="flex-1 relative">
          <input
            v-model="input"
            type="text"
            :placeholder="placeholderText"
            class="w-full px-4 py-3 border border-gray-300 rounded-full focus:outline-none focus:ring-2 focus:ring-blue-500"
            :disabled="loading"
            ref="inputEl"
          />
          <!-- 마이크/첨부 아이콘은 이후 확장 대비 자리만 유지 -->
          <div class="absolute right-3 top-1/2 -translate-y-1/2 flex items-center gap-2 text-gray-400">
            <span title="음성 입력(향후)">🎤</span>
          </div>
        </div>
        <button class="px-4 py-2 bg-blue-600 text-white rounded-full" :disabled="loading || !input.trim()">전송</button>
      </form>
      <p v-if="loading" class="text-xs text-gray-500 mt-2">처리 중...</p>
    </div>
  </div>
  
</template>

<script setup>
import { ref, computed, nextTick, onMounted, watch } from 'vue'
import { useRuntimeConfig } from '#app'
import { resolveApiBase } from '~/composables/useKbApi'
import { useGeminiApiKey } from '~/composables/useGeminiApiKey'

const config = useRuntimeConfig()
const apiBase = resolveApiBase()
const apiKey = process.env.MCP_API_KEY || 'my_mcp_eagle_tiger'
const userKey = 'guest' // TODO: 인증 연동 시 사용자 ID로 치환
const storageKey = `mcp_terminal_topics_${userKey}`

// Gemini API 키 상태 확인
const { canUseChat } = useGeminiApiKey()

const input = ref('')
const inputEl = ref(null)
const messagesEl = ref(null)
const loading = ref(false)
const newTopicName = ref('')

const topics = ref([])
const activeTopicId = ref('')
const placeholderText = computed(() => `/cli gcloud auth list 또는 AI에게 질문`)

function load() {
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
  if (!Array.isArray(topics.value)) {
    topics.value = []
  }
  if (topics.value.length === 0) {
    const newId = (typeof crypto !== 'undefined' && crypto.randomUUID) ? crypto.randomUUID() : String(Date.now())
    topics.value = [{ id: newId, name: '기본', conversationId: null, messages: [] }]
  }
  activeTopicId.value = topics.value[0].id
}
function persist() {
  if (typeof window !== 'undefined' && typeof localStorage !== 'undefined') {
    localStorage.setItem(storageKey, JSON.stringify(topics.value))
  }
  // 사이드바(왼쪽)와 동기화
  if (typeof window !== 'undefined') {
    window.dispatchEvent(new Event('mcp:terminal:topics-updated'))
  }
}

const activeTopic = computed(() => topics.value.find(t => t.id === activeTopicId.value))
const activeMessages = computed(() => activeTopic.value ? activeTopic.value.messages : [])

function deleteTopic(id = null) {
  const targetId = id || activeTopicId.value
  const idx = topics.value.findIndex(t => t.id === targetId)
  if (idx >= 0) {
    // 삭제되는 채팅이 현재 활성 채팅인지 확인
    const isCurrentActive = targetId === activeTopicId.value
    
    topics.value.splice(idx, 1)
    
    // 삭제된 채팅이 현재 활성 채팅이었다면 새 채팅 화면으로 전환
    if (isCurrentActive) {
      if (!topics.value.length) {
        const newId = (typeof crypto !== 'undefined' && crypto.randomUUID) ? crypto.randomUUID() : String(Date.now())
        topics.value = [{ id: newId, name: '기본', conversationId: null, messages: [] }]
      }
      activeTopicId.value = topics.value[0].id
      
      // 전역적으로 현재 활성 채팅 ID 업데이트
      if (typeof window !== 'undefined') {
        window.currentActiveTopicId = activeTopicId.value
      }
      
      // 새 채팅 화면으로 리플레쉬
      nextTick(() => {
        // 입력창 초기화
        if (inputEl.value) {
          inputEl.value.value = ''
          inputEl.value.focus()
        }
        
        // 메시지 영역 스크롤을 맨 위로
        if (typeof document !== 'undefined') {
          const container = document.scrollingElement || document.documentElement
          if (container) {
            container.scrollTop = 0
          }
        }
      })
    }
  }
  persist()
}

function pushMessage(role, text, mode='chat') {
  if (!activeTopic.value) return
  activeTopic.value.messages.push({ role, text, mode })
  persist()
  nextTick(() => {
    try{
      if(messagesEl.value){ messagesEl.value.scrollTop = messagesEl.value.scrollHeight }
      if(inputEl.value && inputEl.value.focus) inputEl.value.focus()
    }catch{}
  })
}

function formatMessage(text) {
  return text
    .replace(/\*\*(.*?)\*\*/g, '<strong>$1</strong>')
    .replace(/\*(.*?)\*/g, '<em>$1</em>')
    .replace(/`(.*?)`/g, '<code class="bg-gray-200 px-1 py-0.5 rounded text-sm">$1</code>')
    .replace(/\n/g, '<br>')
}

function quick(text) {
  input.value = text
  // 즉시 전송
  setTimeout(() => {
    if (typeof document !== 'undefined') {
      const form = document.querySelector('form')
      if (form) form.dispatchEvent(new Event('submit', { cancelable: true, bubbles: true }))
    }
  })
}

async function send() {
  const value = input.value.trim()
  if (!value || !activeTopic.value || loading.value) return

  const isCli = value.startsWith('/cli') || value.startsWith('/c')
  pushMessage('user', value, isCli ? 'cli' : 'chat')

  input.value = ''
  loading.value = true
  try {
    const res = await fetch(`${apiBase}/v1/terminal/agent`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json', 'X-API-Key': apiKey },
      body: JSON.stringify({ user_input: value, conversation_id: activeTopic.value.conversationId })
    })
    // JSON 우선, 실패 시 텍스트로 폴백
    let text = ''
    try {
      const ct = (res.headers.get('content-type') || '').toLowerCase()
      if (ct.includes('application/json')) {
        const data = await res.json()
        if (data && data.conversation_id && !activeTopic.value.conversationId) {
          activeTopic.value.conversationId = data.conversation_id
        }
        // 첫 질문으로 자동 제목 지정
        if (activeTopic.value && (activeTopic.value.name === '새 대화' || activeTopic.value.name === '기본' || !activeTopic.value.name)) {
          const base = value.replace(/^\/(cli|c)\s*/i, '').trim()
          activeTopic.value.name = base.slice(0, 30) || '새 대화'
          persist()
        }
        text = (data?.result || data?.error || JSON.stringify(data))
      } else {
        // HTML/텍스트 등은 그대로 표시
        text = await res.text()
      }
    } catch {
      // JSON 파싱 에러 시에도 텍스트로 폴백
      try { text = await res.text() } catch { text = '응답 처리 오류' }
    }
    pushMessage('assistant', text, isCli ? 'cli' : 'chat')
  } catch (e) {
    pushMessage('assistant', `오류: ${e.message}`, isCli ? 'cli' : 'chat')
  } finally {
    loading.value = false
  }
}

onMounted(load)

// activeTopicId 변경 시 전역 변수 업데이트
watch(activeTopicId, (newId) => {
  if (typeof window !== 'undefined' && newId) {
    window.currentActiveTopicId = newId
  }
})

// 왼쪽 사이드바에서 주제 선택 이벤트 수신
if (typeof window !== 'undefined') {
  window.addEventListener('mcp:terminal:select-topic', (e) => {
    try {
      const detail = (e && e.detail) || {}
      if (detail && detail.id) {
        // 선택된 ID가 현재 목록에 없으면 저장소에서 재로딩
        const exists = topics.value.some(t => t.id === detail.id)
        if (!exists) {
          try {
            const saved = localStorage.getItem(storageKey)
            const parsed = saved ? JSON.parse(saved) : []
            if (Array.isArray(parsed) && parsed.length) {
              topics.value = parsed
            }
          } catch {}
        }
        activeTopicId.value = detail.id
        
        // 전역적으로 현재 활성 채팅 ID 업데이트
        window.currentActiveTopicId = activeTopicId.value
        
        nextTick(() => {
          if (inputEl.value) inputEl.value.focus()
        })
      }
    } catch {}
  })
  
  // 사이드바에서 채팅 삭제 후 새 채팅 전환 이벤트 처리
  window.addEventListener('mcp:terminal:topic-deleted-and-refresh', (e) => {
    try {
      const detail = (e && e.detail) || {}
      if (detail && detail.newTopicId) {
        // 새 채팅으로 전환
        activeTopicId.value = detail.newTopicId
        
        // 전역적으로 현재 활성 채팅 ID 업데이트
        window.currentActiveTopicId = activeTopicId.value
        
        // 새 채팅 화면으로 리플레쉬
        nextTick(() => {
          // 입력창 초기화
          if (inputEl.value) {
            inputEl.value.value = ''
            inputEl.value.focus()
          }
          
          // 메시지 영역 스크롤을 맨 위로
          const container = document.scrollingElement || document.documentElement
          if (container) {
            container.scrollTop = 0
          }
        })
      }
    } catch {}
  })
  
  // 외부에서 목록 갱신 시 재로딩
  window.addEventListener('mcp:terminal:topics-updated', () => {
    try {
      const saved = localStorage.getItem(storageKey)
      const parsed = saved ? JSON.parse(saved) : []
      if (Array.isArray(parsed)) topics.value = parsed
    } catch {}
  })
}

// 프로필 페이지로 이동
function goToProfile() {
  if (typeof window !== 'undefined') {
    // 로그인 상태 확인
    const auth = useAuthStore()
    if (!auth.token) {
      // 로그인하지 않은 경우 로그인 페이지로 이동
      window.location.href = '/login'
    } else {
      // 로그인한 경우 프로필 페이지로 이동
      window.location.href = '/profile'
    }
  }
}
</script>
