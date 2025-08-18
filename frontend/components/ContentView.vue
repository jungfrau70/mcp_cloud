<template>
  <div v-if="content" class="prose max-w-none" ref="contentContainer">
    <!-- Title row with right-aligned buttons -->
    <div v-if="titleText" class="flex items-center justify-between mb-4">
      <h1 class="m-0">{{ titleText }}</h1>
      <div class="flex gap-3">
        <!-- Textbook 버튼 -->
        <button 
          @click="showTextbook = !showTextbook"
          :class="[
            'px-3 py-1 text-sm rounded font-medium transition-colors',
            showTextbook 
              ? 'bg-blue-600 text-white hover:bg-blue-700' 
              : 'bg-gray-200 text-gray-700 hover:bg-gray-300'
          ]"
        >
          {{ showTextbook ? 'Textbook 숨기기' : '📚 Textbook' }}
        </button>
        
        <!-- Download slide 버튼 -->
        <button 
          v-if="path" 
          @click="downloadSlide"
          class="px-3 py-1 text-sm bg-green-600 text-white rounded hover:bg-green-700 transition-colors"
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
      <div v-else-if="loadingTextbook" class="text-center py-8">
        <div class="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600 mx-auto"></div>
        <p class="mt-2 text-gray-600">Textbook을 불러오는 중...</p>
      </div>
      <div v-else class="text-center py-8 text-gray-500">
        <p>Textbook 내용을 불러올 수 없습니다.</p>
      </div>
    </div>

    <!-- 기존 콘텐츠 -->
    <div v-html="renderedMarkdown"></div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, watch } from 'vue';
import { useRuntimeConfig } from '#app';
import { marked } from 'marked';

const props = defineProps({
  content: String,
  slide: Object,
  path: String,
});

const emit = defineEmits(['navigate-tool']);
const contentContainer = ref(null);

// Textbook 관련 상태
const showTextbook = ref(false)
const textbookContent = ref('')
const loadingTextbook = ref(false)

// Title (first heading) extraction
const titleText = computed(() => {
  if (!props.content) return '';
  const match = props.content.match(/^\s*#{1,6}\s+(.+)$/m);
  if (match) return match[1].trim();
  return props.path ? props.path.split('/').pop().replace(/_/g, ' ').replace(/\.md$/i, '') : '';
});

// Render content without the first heading line
const renderedMarkdown = computed(() => {
  if (!props.content) return '';
  const lines = props.content.split(/\r?\n/);
  let removed = false;
  const rest = [];
  for (const line of lines) {
    if (!removed && /^\s*#{1,6}\s+.+$/.test(line)) {
      removed = true;
      continue;
    }
    rest.push(line);
  }
  const body = removed ? rest.join('\n') : props.content;
  return marked(body);
});

const apiBase = useRuntimeConfig().public.apiBaseUrl || 'http://localhost:8000';
const API_KEY = process.env.MCP_API_KEY || 'my_mcp_eagle_tiger';
const downloadFileName = computed(() => props.path ? props.path.split('/').pop() : 'slide');

// Textbook 로드 함수
const loadTextbook = async () => {
  if (!props.path) return
  
  loadingTextbook.value = true
  try {
    const response = await fetch(`${apiBase}/api/v1/curriculum/content?path=${encodeURIComponent(props.path)}`, {
      headers: {
        'X-API-Key': API_KEY
      }
    })
    
    if (response.ok) {
      const content = await response.text()
      // Markdown을 HTML로 변환 (더 나은 옵션 설정)
      marked.setOptions({
        breaks: true,
        gfm: true,
        headerIds: true,
        mangle: false
      })
      textbookContent.value = marked(content)
    } else {
      console.error('Failed to load textbook content')
    }
  } catch (error) {
    console.error('Error loading textbook:', error)
  } finally {
    loadingTextbook.value = false
  }
}

const downloadSlide = async () => {
  console.log('downloadSlide called with props.path:', props.path);
  if (!props.path) {
    console.error('No path provided for slide download');
    alert('파일 경로가 없습니다.');
    return;
  }
  try {
    const url = `${apiBase}/api/v1/curriculum/slide?textbook_path=${encodeURIComponent(props.path)}`;
    console.log('Making API request to:', url);
    const res = await fetch(url, {
      headers: { 'X-API-Key': API_KEY }
    });
    console.log('Response status:', res.status);
    if (!res.ok) throw new Error(`Download failed: ${res.status}`);
    const blob = await res.blob();
    console.log('Blob received, size:', blob.size);
    // Try to read filename from Content-Disposition
    const cd = res.headers.get('content-disposition') || '';
    const match = cd.match(/filename\*=UTF-8''([^;]+)|filename="?([^";]+)"?/i);
    const filename = match ? decodeURIComponent(match[1] || match[2]) : downloadFileName.value;
    console.log('Downloading file:', filename);
    const a = document.createElement('a');
    a.href = URL.createObjectURL(blob);
    a.download = filename;
    document.body.appendChild(a);
    a.click();
    a.remove();
    URL.revokeObjectURL(a.href);
    console.log('Download completed successfully');
  } catch (e) {
    console.error('Slide download error:', e);
    alert('다운로드 중 오류가 발생했습니다.');
  }
};

const setupLinkIntercepts = () => {
  if (contentContainer.value) {
    contentContainer.value.querySelectorAll('a[href^="mcp://"]').forEach(link => {
      link.addEventListener('click', (event) => {
        event.preventDefault();
        const url = new URL(link.href);
        const tool = url.hostname;
        emit('navigate-tool', { tool });
      });
    });
  }
};

// Textbook 표시 상태 변경 감지
watch(showTextbook, (show) => {
  if (show && !textbookContent.value) {
    loadTextbook()
  }
})

onMounted(setupLinkIntercepts);
watch(() => props.content, setupLinkIntercepts);
</script>
