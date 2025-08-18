<template>
  <div v-if="content" class="prose max-w-none relative" ref="contentContainer">
    <!-- Title row with slide link -->
    <div v-if="titleText" class="flex items-center justify-between mb-4">
      <h1 class="m-0">{{ titleText }}</h1>
      <button
        v-if="path"
        @click="openSlides"
        class="px-3 py-1 text-sm rounded bg-indigo-600 text-white hover:bg-indigo-700 transition-colors"
      >
        Slides 보기
      </button>
    </div>

    <!-- 기존 콘텐츠 -->
    <div v-html="renderedMarkdown"></div>

    <!-- Fullscreen slide overlay -->
    <transition name="fade">
      <div v-if="isSlideView" class="fixed inset-0 bg-white z-50 flex flex-col">
        <div class="h-14 flex items-center justify-between px-4 border-b">
          <h2 class="text-lg font-semibold">{{ slideTitle }}</h2>
          <button @click="closeSlides" class="text-sm px-3 py-1 rounded bg-gray-200 hover:bg-gray-300">Textbook으로</button>
        </div>
        <div class="flex-1 overflow-auto">
          <div v-if="slidePdfUrl" class="w-full h-full">
            <iframe :src="slidePdfUrl" class="w-full h-[calc(100vh-56px)]" />
          </div>
          <div v-else class="prose max-w-none p-6">
            <div v-html="slideHtml"></div>
          </div>
        </div>
      </div>
    </transition>
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

onMounted(setupLinkIntercepts);
watch(() => props.content, setupLinkIntercepts);

// Slides overlay logic
const isSlideView = ref(false);
const slideHtml = ref('');
const slidePdfUrl = ref('');
const config = useRuntimeConfig();
const apiBase = config.public.apiBaseUrl || 'http://localhost:8000';
const API_KEY = 'my_mcp_eagle_tiger';

const slideTitle = computed(() => {
  if (!props.path) return 'Slides';
  return props.path.split('/').pop()?.replace(/_/g, ' ').replace(/\.md$/i, '') + ' - Slides';
});

const openSlides = async () => {
  if (!props.path) return;
  try {
    const url = `${apiBase}/api/v1/slides?textbook_path=${encodeURIComponent(props.path)}`;
    const res = await fetch(url, { headers: { 'X-API-Key': API_KEY } });
    if (!res.ok) throw new Error(`Failed to load slides: ${res.status}`);
    const ct = (res.headers.get('content-type') || '').toLowerCase();
    if (ct.includes('application/pdf')) {
      const blob = await res.blob();
      slidePdfUrl.value = URL.createObjectURL(blob);
      slideHtml.value = '';
    } else {
      const md = await res.text();
      marked.setOptions({ breaks: true, gfm: true, headerIds: true, mangle: false });
      slideHtml.value = marked(md);
      slidePdfUrl.value = '';
    }
    isSlideView.value = true;
  } catch (e) {
    console.error(e);
    alert('슬라이드를 불러오는 중 오류가 발생했습니다.');
  }
};

const closeSlides = () => {
  if (slidePdfUrl.value) {
    URL.revokeObjectURL(slidePdfUrl.value);
  }
  slidePdfUrl.value = '';
  slideHtml.value = '';
  isSlideView.value = false;
};
</script>

<style>
.fade-enter-active, .fade-leave-active { transition: opacity 0.2s ease; }
.fade-enter-from, .fade-leave-to { opacity: 0; }
</style>
