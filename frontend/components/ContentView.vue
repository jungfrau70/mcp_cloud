<template>
  <div v-if="content" class="prose max-w-none h-full overflow-y-auto" ref="contentContainer">
    <!-- Title row with toggle link -->
    <div v-if="titleText" class="flex items-center justify-between mb-4">
      <h1 class="m-0">{{ titleText }}</h1>
      <button
        v-if="path && !isSlideView"
        @click="openSlides"
        class="px-3 py-1 text-sm rounded bg-indigo-600 text-white hover:bg-indigo-700 transition-colors"
      >
        Slides 보기
      </button>
      <button
        v-if="path && !isSlideView"
        @click="emit('navigate-tool',{ tool:'content-edit' })"
        class="ml-2 px-3 py-1 text-sm rounded bg-gray-200 hover:bg-gray-300 transition-colors"
      >
        편집
      </button>
      <button
        v-if="isSlideView"
        @click="closeSlides"
        class="px-3 py-1 text-sm rounded bg-gray-200 hover:bg-gray-300 transition-colors"
      >
        Textbook으로
      </button>
    </div>

    <!-- Fade between content and slides in-place -->
    <transition name="fade" mode="out-in">
      <div v-if="!isSlideView" key="content-view">
        <div v-html="renderedMarkdown"></div>
      </div>
      <div v-else key="slides-view">
        <div v-if="slidePdfUrl" class="w-full">
          <iframe :src="slidePdfUrl" class="w-full min-h-[60vh]"></iframe>
        </div>
        <div v-else class="prose max-w-none">
          <div v-html="slideHtml"></div>
        </div>
      </div>
    </transition>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, watch } from 'vue';
import { useRuntimeConfig } from '#app';
import { marked } from 'marked';
import mermaid from 'mermaid';
import embedVega from 'vega-embed';

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
    // render mermaid
    try{
      const blocks = contentContainer.value.querySelectorAll('pre code.language-mermaid, code.language-mermaid')
      blocks.forEach(async (el:any)=>{
        const parent = el.parentElement?.tagName.toLowerCase() === 'pre' ? el.parentElement! : el as HTMLElement
        const code = (el.textContent||'').trim()
        const mount = document.createElement('div')
        parent.replaceWith(mount)
        try{ mermaid.initialize({ startOnLoad:false, theme:'default' }); const out = await mermaid.render('m'+Math.random().toString(36).slice(2), code); mount.innerHTML = out.svg }catch{}
      })
      // vega-lite
      const vegaBlocks = contentContainer.value.querySelectorAll('pre code.language-json, pre code.language-vega-lite, code.language-vega-lite')
      vegaBlocks.forEach(async (el:any)=>{
        const text = (el.textContent||'').trim()
        if(!/vega-lite/i.test(text) && !(el.className||'').includes('vega-lite')) return
        const pre = el.closest('pre')
        const mount = document.createElement('div')
        if(pre) pre.replaceWith(mount); else (el as HTMLElement).replaceWith(mount)
        try{
          const jsonText = text.replace(/^[\/\s]*vega-lite\s*/i,'')
          const spec = JSON.parse(jsonText.replace(/^\/\/.*$/gm,''))
          await embedVega(mount, spec, { actions:false })
        }catch{}
      })
    }catch{}
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

/* 스크롤바 스타일링 */
.overflow-y-auto::-webkit-scrollbar {
  width: 8px;
}

.overflow-y-auto::-webkit-scrollbar-track {
  background: #f1f1f1;
  border-radius: 4px;
}

.overflow-y-auto::-webkit-scrollbar-thumb {
  background: #c1c1c1;
  border-radius: 4px;
}

.overflow-y-auto::-webkit-scrollbar-thumb:hover {
  background: #a8a8a8;
}

/* Firefox 스크롤바 스타일링 */
.overflow-y-auto {
  scrollbar-width: thin;
  scrollbar-color: #c1c1c1 #f1f1f1;
}
</style>
