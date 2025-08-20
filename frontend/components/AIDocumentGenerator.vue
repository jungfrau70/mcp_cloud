<template>
  <div class="ai-document-generator">
    <!-- 모달 오버레이 -->
    <div v-if="isOpen" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div class="bg-white rounded-lg shadow-xl w-full max-w-4xl max-h-[90vh] overflow-hidden">
        <!-- 헤더 -->
        <div class="flex items-center justify-between p-6 border-b">
          <h2 class="text-xl font-semibold text-gray-900">AI 문서 생성</h2>
          <button @click="closeModal" class="text-gray-400 hover:text-gray-600">
            <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
            </svg>
          </button>
        </div>

        <!-- 진행 상태 표시 -->
        <div v-if="isGenerating" class="p-4 bg-blue-50 border-b">
          <div class="flex items-center space-x-3">
            <div class="animate-spin rounded-full h-6 w-6 border-b-2 border-blue-600"></div>
            <div>
              <p class="text-sm font-medium text-blue-900">{{ currentStep }}</p>
              <div class="w-full bg-gray-200 rounded-full h-2 mt-1">
                <div class="bg-blue-600 h-2 rounded-full transition-all duration-300" :style="{ width: progress + '%' }"></div>
              </div>
            </div>
          </div>
        </div>

        <!-- 메인 콘텐츠 -->
        <div class="p-6 overflow-y-auto max-h-[calc(90vh-200px)]">
          <!-- 입력 폼 -->
          <div v-if="!isGenerating && !generatedDocument" class="space-y-6">
            <!-- 쿼리 입력 -->
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">
                문서 주제 *
              </label>
              <textarea
                v-model="form.query"
                rows="3"
                placeholder="예: AWS Lambda를 사용한 서버리스 애플리케이션 배포 방법"
                class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                :disabled="isGenerating"
              ></textarea>
            </div>

            <!-- 문서 타입 선택 -->
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">
                문서 타입
              </label>
              <select
                v-model="form.docType"
                class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                :disabled="isGenerating"
              >
                <option value="guide">기술 가이드</option>
                <option value="tutorial">단계별 튜토리얼</option>
                <option value="reference">참조 문서</option>
                <option value="comparison">비교 분석</option>
              </select>
            </div>

            <!-- 검색 소스 선택 -->
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">
                검색 소스
              </label>
              <div class="space-y-2">
                <label class="flex items-center">
                  <input
                    type="checkbox"
                    v-model="form.searchSources"
                    value="web"
                    class="rounded border-gray-300 text-blue-600 focus:ring-blue-500"
                    :disabled="isGenerating"
                  >
                  <span class="ml-2 text-sm text-gray-700">웹 검색</span>
                </label>
                <label class="flex items-center">
                  <input
                    type="checkbox"
                    v-model="form.searchSources"
                    value="news"
                    class="rounded border-gray-300 text-blue-600 focus:ring-blue-500"
                    :disabled="isGenerating"
                  >
                  <span class="ml-2 text-sm text-gray-700">뉴스 검색</span>
                </label>
                <label class="flex items-center">
                  <input
                    type="checkbox"
                    v-model="form.searchSources"
                    value="docs"
                    class="rounded border-gray-300 text-blue-600 focus:ring-blue-500"
                    :disabled="isGenerating"
                  >
                  <span class="ml-2 text-sm text-gray-700">문서 검색</span>
                </label>
              </div>
            </div>

            <!-- 저장 경로 -->
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">
                저장 경로 (선택사항)
              </label>
              <input
                v-model="form.targetPath"
                type="text"
                placeholder="예: aws/lambda-deployment"
                class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                :disabled="isGenerating"
              >
              <p class="mt-1 text-xs text-gray-500">
                비워두면 루트 디렉토리에 저장됩니다
              </p>
            </div>

            <!-- 최대 결과 수 -->
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">
                최대 검색 결과 수
              </label>
              <input
                v-model.number="form.maxResults"
                type="number"
                min="1"
                max="10"
                class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                :disabled="isGenerating"
              >
            </div>
          </div>

          <!-- 생성된 문서 미리보기 -->
          <div v-if="generatedDocument && !isGenerating" class="space-y-4">
            <div class="bg-green-50 border border-green-200 rounded-md p-4">
              <div class="flex items-center">
                <svg class="w-5 h-5 text-green-400 mr-2" fill="currentColor" viewBox="0 0 20 20">
                  <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd" />
                </svg>
                <span class="text-green-800 font-medium">문서가 성공적으로 생성되었습니다!</span>
              </div>
              <p class="text-green-700 mt-1">{{ generatedDocument.message }}</p>
            </div>

            <!-- 문서 정보 -->
            <div class="bg-gray-50 rounded-md p-4">
              <h3 class="text-lg font-medium text-gray-900 mb-2">{{ generatedDocument.generated_doc_data?.title }}</h3>
              <div class="text-sm text-gray-600 space-y-1">
                <p><strong>파일 경로:</strong> {{ generatedDocument.document_path }}</p>
                <p><strong>슬러그:</strong> {{ generatedDocument.generated_doc_data?.slug }}</p>
                <p><strong>생성 시간:</strong> {{ formatDate(generatedDocument.generated_doc_data?.metadata?.generated_at) }}</p>
              </div>
            </div>

            <!-- 문서 내용 미리보기 -->
            <div class="border rounded-md">
              <div class="bg-gray-50 px-4 py-2 border-b">
                <h4 class="text-sm font-medium text-gray-700">문서 내용 미리보기</h4>
              </div>
              <div class="p-4 prose max-w-none max-h-96 overflow-y-auto">
                <div v-html="renderMarkdown(generatedDocument.generated_doc_data?.content || '')"></div>
              </div>
            </div>
          </div>

          <!-- 에러 메시지 -->
          <div v-if="error" class="bg-red-50 border border-red-200 rounded-md p-4">
            <div class="flex items-center">
              <svg class="w-5 h-5 text-red-400 mr-2" fill="currentColor" viewBox="0 0 20 20">
                <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z" clip-rule="evenodd" />
              </svg>
              <span class="text-red-800 font-medium">오류가 발생했습니다</span>
            </div>
            <p class="text-red-700 mt-1">{{ error }}</p>
          </div>
        </div>

        <!-- 푸터 -->
        <div class="flex items-center justify-end space-x-3 p-6 border-t bg-gray-50">
          <button
            @click="closeModal"
            class="px-4 py-2 text-sm font-medium text-gray-700 bg-white border border-gray-300 rounded-md hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-blue-500"
            :disabled="isGenerating"
          >
            {{ generatedDocument ? '닫기' : '취소' }}
          </button>
          
          <button
            v-if="!generatedDocument"
            @click="generateDocument"
            :disabled="!canGenerate || isGenerating"
            class="px-4 py-2 text-sm font-medium text-white bg-blue-600 border border-transparent rounded-md hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-500 disabled:opacity-50 disabled:cursor-not-allowed"
          >
            {{ isGenerating ? '생성 중...' : '문서 생성' }}
          </button>
          
          <button
            v-if="generatedDocument"
            @click="saveToKnowledgeBase"
            class="px-4 py-2 text-sm font-medium text-white bg-green-600 border border-transparent rounded-md hover:bg-green-700 focus:outline-none focus:ring-2 focus:ring-green-500"
          >
            지식베이스에 저장
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, watch } from 'vue'
import { marked } from 'marked'

// Props
const props = defineProps({
  isOpen: {
    type: Boolean,
    default: false
  }
})

// Emits
const emit = defineEmits(['close', 'document-generated'])

// Reactive data
const form = ref({
  query: '',
  docType: 'guide',
  searchSources: ['web', 'news'],
  targetPath: '',
  maxResults: 5
})

const isGenerating = ref(false)
const currentStep = ref('')
const progress = ref(0)
const generatedDocument = ref(null)
const error = ref('')

// Computed
const canGenerate = computed(() => {
  return form.value.query.trim().length > 0 && form.value.searchSources.length > 0
})

// Methods
const closeModal = () => {
  emit('close')
  resetForm()
}

const resetForm = () => {
  form.value = {
    query: '',
    docType: 'guide',
    searchSources: ['web', 'news'],
    targetPath: '',
    maxResults: 5
  }
  isGenerating.value = false
  currentStep.value = ''
  progress.value = 0
  generatedDocument.value = null
  error.value = ''
}

const updateProgress = (step, progressValue) => {
  currentStep.value = step
  progress.value = progressValue
}

const generateDocument = async () => {
  if (!canGenerate.value) return

  isGenerating.value = true
  error.value = ''
  generatedDocument.value = null

  try {
    updateProgress('검색 중...', 20)
    
    const response = await $fetch('/api/v1/knowledge/generate-from-external-enhanced', {
      method: 'POST',
      headers: {
        'X-API-Key': 'test_api_key' // 실제로는 환경변수나 스토어에서 가져와야 함
      },
      body: {
        query: form.value.query,
        doc_type: form.value.docType,
        search_sources: form.value.searchSources,
        target_path: form.value.targetPath || undefined,
        max_results: form.value.maxResults
      }
    })

    updateProgress('문서 생성 중...', 80)

    if (response.success) {
      generatedDocument.value = response
      updateProgress('완료!', 100)
      emit('document-generated', response)
    } else {
      throw new Error(response.message || '문서 생성에 실패했습니다')
    }

  } catch (err) {
    error.value = err.message || '알 수 없는 오류가 발생했습니다'
    console.error('Document generation error:', err)
  } finally {
    isGenerating.value = false
  }
}

const saveToKnowledgeBase = () => {
  // 지식베이스에 저장하는 로직
  // 실제로는 부모 컴포넌트에서 처리하거나 별도 API 호출
  closeModal()
}

const formatDate = (dateString) => {
  if (!dateString) return ''
  return new Date(dateString).toLocaleString('ko-KR')
}

const renderMarkdown = (content) => {
  if (!content) return ''
  return marked(content)
}

// Watch for modal state changes
watch(() => props.isOpen, (newValue) => {
  if (!newValue) {
    resetForm()
  }
})
</script>

<style scoped>
.ai-document-generator {
  /* Component styles */
}

.prose {
  @apply text-gray-900;
}

.prose h1 {
  @apply text-2xl font-bold mb-4;
}

.prose h2 {
  @apply text-xl font-semibold mb-3 mt-6;
}

.prose h3 {
  @apply text-lg font-medium mb-2 mt-4;
}

.prose p {
  @apply mb-3;
}

.prose ul {
  @apply list-disc list-inside mb-3;
}

.prose ol {
  @apply list-decimal list-inside mb-3;
}

.prose code {
  @apply bg-gray-100 px-1 py-0.5 rounded text-sm;
}

.prose pre {
  @apply bg-gray-100 p-3 rounded mb-3 overflow-x-auto;
}

.prose blockquote {
  @apply border-l-4 border-gray-300 pl-4 italic mb-3;
}
</style>
