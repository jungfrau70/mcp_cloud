<template>
  <div class="prose max-w-none">
    <div class="flex justify-between items-center mb-6">
      <h3>이론 학습</h3>
      <div class="flex gap-3">
        <!-- Textbook 버튼 -->
        <button
          @click="showTextbook = !showTextbook"
          :class="[
            'px-4 py-2 rounded-lg font-medium transition-colors',
            showTextbook 
              ? 'bg-blue-600 text-white hover:bg-blue-700' 
              : 'bg-gray-200 text-gray-700 hover:bg-gray-300'
          ]"
        >
          {{ showTextbook ? '이론 숨기기' : 'Textbook 보기' }}
        </button>
        
        <!-- 다운로드 슬라이드 버튼 -->
        <button
          @click="downloadSlide"
          class="px-4 py-2 bg-green-600 text-white rounded-lg font-medium hover:bg-green-700 transition-colors"
        >
          다운로드 슬라이드
        </button>
      </div>
    </div>

    <!-- Textbook 내용 -->
    <div v-if="showTextbook" class="mb-8 p-6 bg-gray-50 rounded-lg border">
      <h4 class="text-xl font-semibold mb-4 text-gray-800">📚 Textbook 내용</h4>
      <div v-if="textbookContent" class="prose prose-sm max-w-none">
        <div v-html="textbookContent"></div>
      </div>
      <div v-else-if="loading" class="text-center py-8">
        <div class="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600 mx-auto"></div>
        <p class="mt-2 text-gray-600">Textbook을 불러오는 중...</p>
      </div>
      <div v-else class="text-center py-8 text-gray-500">
        <p>Textbook 내용을 불러올 수 없습니다.</p>
      </div>
    </div>

    <!-- 기존 이론 내용 -->
    <div v-if="!showTextbook">
      <p>
        클라우드 컴퓨팅에서 가상 머신(VM)은 물리적 하드웨어의 소프트웨어 에뮬레이션입니다. 
        이를 통해 단일 물리적 머신에서 여러 운영 체제를 동시에 실행할 수 있습니다.
      </p>
      <p>
        주요 클라우드 제공업체는 이 서비스를 핵심으로 제공합니다.
      </p>
      <ul>
        <li><b>AWS:</b> EC2 (Elastic Compute Cloud)</li>
        <li><b>GCP:</b> Compute Engine</li>
      </ul>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, watch } from 'vue'

// Props
const props = defineProps({
  slidePath: {
    type: String,
    default: ''
  },
  textbookPath: {
    type: String,
    default: 'part1/day1/1-1_introduction_to_cloud.md'
  }
})

// Reactive data
const showTextbook = ref(false)
const textbookContent = ref('')
const loading = ref(false)

// Methods
const downloadSlide = async () => {
  if (!props.slidePath) {
    alert('다운로드할 슬라이드가 없습니다.')
    return
  }

  try {
    const response = await fetch(`/api/v1/curriculum/slide/${encodeURIComponent(props.slidePath)}`, {
      headers: {
        'X-API-Key': 'my_mcp_eagle_tiger'
      }
    })
    
    if (response.ok) {
      const blob = await response.blob()
      const url = window.URL.createObjectURL(blob)
      const a = document.createElement('a')
      a.href = url
      a.download = `${props.slidePath.split('/').pop().replace('.md', '.pdf')}`
      document.body.appendChild(a)
      a.click()
      document.body.removeChild(a)
      window.URL.revokeObjectURL(url)
    } else {
      alert('슬라이드 다운로드에 실패했습니다.')
    }
  } catch (error) {
    console.error('Download error:', error)
    alert('슬라이드 다운로드 중 오류가 발생했습니다.')
  }
}

const loadTextbook = async () => {
  if (!props.textbookPath) return
  
  loading.value = true
  try {
    const response = await fetch(`/api/v1/curriculum/content?path=${encodeURIComponent(props.textbookPath)}`, {
      headers: {
        'X-API-Key': 'my_mcp_eagle_tiger'
      }
    })
    
    if (response.ok) {
      const content = await response.text()
      // Markdown을 HTML로 변환 (간단한 변환)
      textbookContent.value = convertMarkdownToHtml(content)
    } else {
      console.error('Failed to load textbook content')
    }
  } catch (error) {
    console.error('Error loading textbook:', error)
  } finally {
    loading.value = false
  }
}

const convertMarkdownToHtml = (markdown) => {
  // 간단한 Markdown to HTML 변환
  return markdown
    .replace(/^### (.*$)/gim, '<h3 class="text-lg font-semibold mt-4 mb-2">$1</h3>')
    .replace(/^## (.*$)/gim, '<h2 class="text-xl font-semibold mt-6 mb-3">$1</h2>')
    .replace(/^# (.*$)/gim, '<h1 class="text-2xl font-bold mt-8 mb-4">$1</h1>')
    .replace(/\*\*(.*?)\*\*/g, '<strong>$1</strong>')
    .replace(/\*(.*?)\*/g, '<em>$1</em>')
    .replace(/`(.*?)`/g, '<code class="bg-gray-200 px-1 py-0.5 rounded text-sm">$1</code>')
    .replace(/```([\s\S]*?)```/g, '<pre class="bg-gray-100 p-3 rounded overflow-x-auto"><code>$1</code></pre>')
    .replace(/\n/g, '<br>')
}

// Watch for textbook path changes
watch(() => props.textbookPath, (newPath) => {
  if (newPath && showTextbook.value) {
    loadTextbook()
  }
})

// Load textbook when component mounts or when showTextbook changes
watch(showTextbook, (show) => {
  if (show && !textbookContent.value) {
    loadTextbook()
  }
})

onMounted(() => {
  // Initial load if textbook should be shown
  if (showTextbook.value) {
    loadTextbook()
  }
})
</script>

<style scoped>
.prose h1, .prose h2, .prose h3 {
  @apply text-gray-800;
}

.prose p {
  @apply text-gray-700 leading-relaxed;
}

.prose ul {
  @apply list-disc list-inside space-y-1;
}

.prose li {
  @apply text-gray-700;
}

.prose code {
  @apply font-mono;
}

.prose pre {
  @apply font-mono text-sm;
}
</style>
