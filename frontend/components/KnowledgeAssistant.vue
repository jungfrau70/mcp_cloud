<template>
  <div class="fixed bottom-6 right-6 z-50">
    <!-- FAB 버튼 -->
    <button
      @click="toggleAssistant"
      class="bg-primary-600 hover:bg-primary-700 text-white rounded-full p-4 shadow-lg transition-all duration-200 hover:scale-110"
      :class="{ 'rotate-45': isOpen }"
    >
      <svg v-if="!isOpen" class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8.228 9c.549-1.165 2.03-2 3.772-2 2.21 0 4 1.343 4 3 0 1.4-1.278 2.575-3.006 2.907-.542.104-.994.54-.994 1.093m0 3h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
      </svg>
      <svg v-else class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
      </svg>
    </button>

    <!-- 어시스턴트 창 -->
    <Transition
      enter-active-class="transition ease-out duration-200"
      enter-from-class="opacity-0 scale-95"
      enter-to-class="opacity-100 scale-100"
      leave-active-class="transition ease-in duration-150"
      leave-from-class="opacity-100 scale-100"
      leave-to-class="opacity-0 scale-95"
    >
      <div
        v-if="isOpen"
        class="absolute bottom-20 right-0 w-96 h-[500px] bg-white rounded-lg shadow-xl border border-gray-200 flex flex-col"
      >
        <!-- 헤더 -->
        <div class="flex items-center justify-between p-4 border-b border-gray-200 bg-gradient-to-r from-primary-600 to-primary-700 text-white rounded-t-lg">
          <div class="flex items-center space-x-2">
            <div class="w-8 h-8 bg-white bg-opacity-20 rounded-full flex items-center justify-center">
              <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9.663 17h4.673M12 3v1m6.364 1.636l-.707.707M21 12h-1M4 12H3m3.343-5.657l-.707-.707m2.828 9.9a5 5 0 117.072 0l-.548.547A3.374 3.374 0 0014 18.469V19a2 2 0 11-4 0v-.531c0-.895-.356-1.754-.988-2.386l-.548-.547z" />
              </svg>
            </div>
            <div>
              <h3 class="font-semibold">MCP AI 어시스턴트</h3>
              <p class="text-xs text-primary-100">지식베이스 도우미</p>
            </div>
          </div>
          <button @click="toggleAssistant" class="text-white hover:text-primary-100">
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
            </svg>
          </button>
        </div>

        <!-- 메시지 영역 -->
        <div class="flex-1 overflow-y-auto p-4 space-y-4" ref="messagesContainer">
          <div
            v-for="(message, index) in messages"
            :key="index"
            :class="[
              'flex',
              message.sender === 'user' ? 'justify-end' : 'justify-start'
            ]"
          >
            <div
              :class="[
                'max-w-xs lg:max-w-md px-4 py-2 rounded-lg',
                message.sender === 'user'
                  ? 'bg-primary-600 text-white'
                  : 'bg-gray-100 text-gray-900'
              ]"
            >
              <div class="text-sm">
                <div v-if="message.sender === 'assistant' && message.isTyping" class="flex space-x-1">
                  <div class="w-2 h-2 bg-gray-400 rounded-full animate-bounce"></div>
                  <div class="w-2 h-2 bg-gray-400 rounded-full animate-bounce" style="animation-delay: 0.1s"></div>
                  <div class="w-2 h-2 bg-gray-400 rounded-full animate-bounce" style="animation-delay: 0.2s"></div>
                </div>
                <div v-else v-html="formatMessage(message.text)"></div>
              </div>
            </div>
          </div>
        </div>

        <!-- 입력 영역 -->
        <div class="p-4 border-t border-gray-200">
          <form @submit.prevent="sendMessage" class="flex space-x-2">
            <input
              v-model="inputMessage"
              type="text"
              placeholder="지식베이스에 대해 질문하세요..."
              class="flex-1 px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-transparent text-sm"
              :disabled="isLoading"
            />
            <button
              type="submit"
              :disabled="!inputMessage.trim() || isLoading"
              class="px-4 py-2 bg-primary-600 text-white rounded-md hover:bg-primary-700 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
            >
              <svg v-if="isLoading" class="w-4 h-4 animate-spin" fill="none" viewBox="0 0 24 24">
                <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
              </svg>
              <svg v-else class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 19l9 2-9-18-9 18 9-2zm0 0v-8" />
              </svg>
            </button>
          </form>
        </div>
      </div>
    </Transition>
  </div>
</template>

<script setup>
const isOpen = ref(false)
const inputMessage = ref('')
const messages = ref([])
const isLoading = ref(false)
const messagesContainer = ref(null)

// 초기 메시지
onMounted(() => {
  messages.value = [
    {
      sender: 'assistant',
      text: '안녕하세요! MCP 클라우드 플랫폼의 지식베이스 어시스턴트입니다. AWS, GCP, Azure, Terraform 등에 대해 무엇이든 물어보세요. 🚀'
    }
  ]
})

const toggleAssistant = () => {
  isOpen.value = !isOpen.value
}

const sendMessage = async () => {
  if (!inputMessage.value.trim() || isLoading.value) return

  const userMessage = inputMessage.value
  inputMessage.value = ''
  
  // 사용자 메시지 추가
  messages.value.push({
    sender: 'user',
    text: userMessage
  })

  // 어시스턴트 응답 준비
  const assistantMessage = {
    sender: 'assistant',
    text: '',
    isTyping: true
  }
  messages.value.push(assistantMessage)

  isLoading.value = true

  try {
    // TODO: 실제 Gemini API 연동
    await simulateGeminiResponse(userMessage, assistantMessage)
  } catch (error) {
    console.error('Error getting response:', error)
    assistantMessage.text = '죄송합니다. 응답을 가져오는 중 오류가 발생했습니다. 다시 시도해주세요.'
  } finally {
    assistantMessage.isTyping = false
    isLoading.value = false
    scrollToBottom()
  }
}

const simulateGeminiResponse = async (userMessage, assistantMessage) => {
  // 실제 Gemini API 호출을 시뮬레이션
  const responses = {
    'aws': 'AWS 서비스에 대해 질문하셨군요! AWS는 Amazon Web Services의 약자로, 클라우드 컴퓨팅 서비스입니다. EC2, S3, RDS 등 다양한 서비스를 제공합니다. 구체적으로 어떤 AWS 서비스에 대해 알고 싶으신가요?',
    'gcp': 'Google Cloud Platform(GCP)에 대해 질문하셨군요! GCP는 Google이 제공하는 클라우드 플랫폼으로, Compute Engine, Cloud Storage, BigQuery 등 강력한 서비스를 제공합니다. 어떤 GCP 서비스에 대해 더 자세히 알고 싶으신가요?',
    'terraform': 'Terraform에 대해 질문하셨군요! Terraform은 HashiCorp에서 개발한 Infrastructure as Code(IaC) 도구입니다. 클라우드 인프라를 코드로 정의하고 관리할 수 있어 일관성과 재현 가능성을 보장합니다. Terraform의 어떤 부분에 대해 더 알고 싶으신가요?',
    'default': '좋은 질문이네요! MCP 클라우드 플랫폼에서는 AWS, GCP, Azure 등 다양한 클라우드 서비스와 Terraform을 통한 인프라 관리에 대해 도움을 드릴 수 있습니다. 더 구체적인 질문이 있으시면 언제든 물어보세요!'
  }

  // 키워드 기반 응답 선택
  let response = responses.default
  if (userMessage.toLowerCase().includes('aws')) {
    response = responses.aws
  } else if (userMessage.toLowerCase().includes('gcp') || userMessage.toLowerCase().includes('google')) {
    response = responses.gcp
  } else if (userMessage.toLowerCase().includes('terraform')) {
    response = responses.terraform
  }

  // 타이핑 효과 시뮬레이션
  const words = response.split(' ')
  for (let i = 0; i < words.length; i++) {
    await new Promise(resolve => setTimeout(resolve, 100))
    assistantMessage.text = words.slice(0, i + 1).join(' ')
  }
}

const formatMessage = (text) => {
  // 마크다운 스타일 포맷팅 (간단한 버전)
  return text
    .replace(/\*\*(.*?)\*\*/g, '<strong>$1</strong>')
    .replace(/\*(.*?)\*/g, '<em>$1</em>')
    .replace(/`(.*?)`/g, '<code class="bg-gray-200 px-1 py-0.5 rounded text-sm">$1</code>')
    .replace(/\n/g, '<br>')
}

const scrollToBottom = () => {
  nextTick(() => {
    if (messagesContainer.value) {
      messagesContainer.value.scrollTop = messagesContainer.value.scrollHeight
    }
  })
}

// 메시지가 추가될 때마다 스크롤
watch(messages, () => {
  scrollToBottom()
}, { deep: true })
</script>

<style scoped>
.animate-bounce {
  animation: bounce 1s infinite;
}

@keyframes bounce {
  0%, 80%, 100% {
    transform: scale(0);
  }
  40% {
    transform: scale(1);
  }
}
</style>
