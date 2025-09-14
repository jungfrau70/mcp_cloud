<template>
  <div v-if="content || slide" class="h-full overflow-y-auto bg-white" ref="contentContainer">
    <!-- Header with path navigation and actions -->
    <div class="flex items-center justify-between px-4 pt-3 pb-2 border-b border-gray-200" v-if="path">
      <!-- Path breadcrumb -->
      <div class="flex items-center space-x-2 text-sm text-gray-600">
        <button
          @click="navigateToFileTree"
          class="flex items-center space-x-1 hover:text-blue-600 transition-colors"
          :title="`FileTree에서 '${path}' 위치로 이동`"
        >
          <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 7v10a2 2 0 002 2h14a2 2 0 002-2V9a2 2 0 00-2-2H5a2 2 0 00-2-2z"></path>
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 5a2 2 0 012-2h4a2 2 0 012 2v2H8V5z"></path>
          </svg>
          <span class="font-medium">{{ path }}</span>
        </button>
      </div>
      
      <!-- Action buttons -->
      <div class="flex items-center gap-2">
        <button
          v-if="path && !isSlideView"
          @click="downloadPdf"
          class="px-3 py-1 text-sm rounded bg-emerald-600 text-white hover:bg-emerald-700 transition-colors"
        >
          PDF
        </button>
      </div>
    </div>

    <!-- Loading indicator -->
    <div v-if="isLoading" class="flex items-center justify-center p-8">
      <div class="flex items-center space-x-2 text-gray-600">
        <div class="animate-spin rounded-full h-6 w-6 border-b-2 border-blue-600"></div>
        <span>문서를 불러오는 중...</span>
      </div>
    </div>

    <!-- Fade between content and slides in-place -->
    <transition name="fade" mode="out-in">
      <div v-if="!isSlideView && !isLoading" key="content-view" class="prose max-w-none p-4">
        <div v-html="renderedContent"></div>
      </div>
      <div v-else-if="isSlideView && !isLoading" key="slides-view">
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
import { ref, computed, onMounted, watch, nextTick } from 'vue';
import { useRuntimeConfig } from '#app';
import { marked } from 'marked';
import mermaid from 'mermaid';
import embedVega from 'vega-embed';
import DOMPurify from 'dompurify'
import { cleanApiPath, deepCleanApiPath, isDirectoryPath, normalizeDirectoryPath, preventPathDuplication } from '~/utils/path'

const props = defineProps({
  content: String,
  slide: Object,
  path: String,
  readonly: { type: Boolean, default: false }
});

const emit = defineEmits(['navigate-tool']);
const contentContainer = ref(null);
const isLoading = ref(false);

// Title (first heading) extraction
const titleText = computed(() => {
  if (!props.content) return '';
  const match = props.content.match(/^\s*#{1,6}\s+(.+)$/m);
  if (match) return match[1].trim();
  return props.path ? props.path.split('/').pop().replace(/_/g, ' ').replace(/\.md$/i, '') : '';
});

// Render content (preserve first heading so titles are visible)
const renderedContent = computed(() => {
  if (!props.content) return '';
  let body = props.content;
  // Preprocess: auto-tag mermaid code fences without language
  try{
    body = body.replace(/```(?!\w)[ \t]*\n([\s\S]*?)```/g, (m, code) => {
      const first = (code.split(/\r?\n/).find(l => l.trim().length>0) || '').trim()
      return /^\s*(graph|flowchart|sequenceDiagram|classDiagram|stateDiagram|erDiagram|gantt)\b/.test(first)
        ? '```mermaid\n' + code + '```'
        : m
    })
    // Strip Marp/slide front-matter or metadata lines at top
    body = body.replace(/^---\s*[\r\n]+[\s\S]*?[\r\n]---\s*[\r\n]*/m, '')
               .replace(/^(?:\s*(?:marp|theme|size|header|footer)\s*:[^\n]*\n)+/i, '')
    // Normalize KB links: convert mdc:mcp_knowledge_base/... → /mcp_knowledge_base/...
    body = body.replace(/\]\(mdc:mcp_knowledge_base\//g, '](\/mcp_knowledge_base/')
  }catch{ /* ignore */ }
  // KB Markdown 탭과 동일한 marked 옵션
  marked.setOptions({ 
    breaks: true, 
    gfm: true, 
    headerIds: true, 
    mangle: false,
    headerPrefix: '' // Remove any prefix from generated IDs
  })
  
  // Custom renderer for Korean header IDs and table styling
  const renderer = new marked.Renderer()
  renderer.heading = function(text, level) {
    // VS Code 마크다운 미리보기와 동일한 슬러그 생성 방식
    // 이모지를 유지하고 공백을 하이픈으로 변환
    let id = text
      .trim() // 앞뒤 공백 제거
      .replace(/\s+/g, '-') // 공백을 하이픈으로 변환
      .replace(/-+/g, '-') // 연속된 하이픈을 하나로 변환
      .replace(/^-+|-+$/g, '') // 앞뒤 하이픈 제거
      .toLowerCase() // 소문자로 변환
    
    // 빈 ID인 경우 fallback 생성
    if (!id) {
      id = `heading-${level}-${Math.random().toString(36).substr(2, 9)}`;
    }
    
    return `<h${level} id="${id}">${text}</h${level}>`
  }
  
  // Custom table renderer for better styling
  renderer.table = function(header, body) {
    return `<div class="table-scroll"><table class="table-auto w-full border-collapse border border-gray-300">${header}${body}</table></div>`
  }
  
  renderer.tablerow = function(content) {
    return `<tr class="border-b border-gray-200">${content}</tr>`
  }
  
  renderer.tablecell = function(content, flags) {
    const tag = flags.header ? 'th' : 'td'
    const align = flags.align ? ` style="text-align: ${flags.align}"` : ''
    const className = flags.header ? 'px-4 py-2 bg-gray-50 font-semibold text-left border border-gray-300' : 'px-4 py-2 border border-gray-300'
    return `<${tag} class="${className}"${align}>${content}</${tag}>`
  }
  
  marked.use({ renderer })
  
  // Allow custom KB scheme 'mdc:' so hrefs are preserved for interception
  return DOMPurify.sanitize(marked.parse(body), { ADD_URI_SAFE: ['mdc'] });
});

let mermaidInitialized = false

// Setup details/summary interaction handlers
const setupDetailsHandlers = () => {
  if (!contentContainer.value) return;

  const detailsElements = contentContainer.value.querySelectorAll('details');
  detailsElements.forEach((details, index) => {
    // Add click handler to summary elements
    const summary = details.querySelector('summary');
    if (summary) {
      // Make summary focusable for keyboard navigation
      summary.setAttribute('tabindex', '0');
      summary.setAttribute('role', 'button');
      summary.setAttribute('aria-expanded', details.hasAttribute('open') ? 'true' : 'false');

      // Click handler
      summary.addEventListener('click', (e) => {
        e.preventDefault();
        details.toggleAttribute('open');
        summary.setAttribute('aria-expanded', details.hasAttribute('open') ? 'true' : 'false');

        // Save state to localStorage
        const path = props.path || 'default';
        const key = `details-state-${path}-${index}`;
        localStorage.setItem(key, details.hasAttribute('open') ? 'open' : 'closed');
      });

      // Keyboard handler
      summary.addEventListener('keydown', (e) => {
        if (e.key === 'Enter' || e.key === ' ') {
          e.preventDefault();
          details.toggleAttribute('open');
          summary.setAttribute('aria-expanded', details.hasAttribute('open') ? 'true' : 'false');

          // Save state to localStorage
          const path = props.path || 'default';
          const key = `details-state-${path}-${index}`;
          localStorage.setItem(key, details.hasAttribute('open') ? 'open' : 'closed');
        }
      });

      // Restore state from localStorage
      const path = props.path || 'default';
      const key = `details-state-${path}-${index}`;
      const savedState = localStorage.getItem(key);
      if (savedState === 'open') {
        details.setAttribute('open', '');
        summary.setAttribute('aria-expanded', 'true');
      } else if (savedState === 'closed') {
        details.removeAttribute('open');
        summary.setAttribute('aria-expanded', 'false');
      }
    }
  });
};

// Setup code block copy functionality
const setupCodeBlockHandlers = () => {
  if (!contentContainer.value) return;

  const codeBlocks = contentContainer.value.querySelectorAll('pre code');
  codeBlocks.forEach((codeBlock) => {
    const pre = codeBlock.parentElement;
    if (!pre || pre.querySelector('.copy-button')) return;

    // Create copy button
    const copyButton = document.createElement('button');
    copyButton.className = 'copy-button';
    copyButton.innerHTML = 'Copy';

    // Copy functionality
    copyButton.addEventListener('click', async (e) => {
      e.preventDefault();
      e.stopPropagation();
      
      try {
        const text = codeBlock.textContent || '';
        await navigator.clipboard.writeText(text);
        
        // Visual feedback
        const originalText = copyButton.innerHTML;
        copyButton.innerHTML = 'Copied!';
        copyButton.style.background = '#10b981';
        
        setTimeout(() => {
          copyButton.innerHTML = originalText;
          copyButton.style.background = '#374151';
        }, 2000);
      } catch (err) {
        console.error('Failed to copy text: ', err);
        // Fallback for older browsers
        const textArea = document.createElement('textarea');
        textArea.value = codeBlock.textContent || '';
        document.body.appendChild(textArea);
        textArea.select();
        document.execCommand('copy');
        document.body.removeChild(textArea);
        
        // Visual feedback
        const originalText = copyButton.innerHTML;
        copyButton.innerHTML = 'Copied!';
        copyButton.style.background = '#10b981';
        
        setTimeout(() => {
          copyButton.innerHTML = originalText;
          copyButton.style.background = '#374151';
        }, 2000);
      }
    });

    pre.appendChild(copyButton);
  });
};

// FileTree로 네비게이션하는 함수
const navigateToFileTree = () => {
  if (!props.path) return;
  
  // FileTree에서 해당 파일 위치로 이동하는 이벤트 발생
  window.dispatchEvent(new CustomEvent('filetree:navigate', {
    detail: { path: props.path }
  }));
  
  // 사용자에게 피드백 제공
  if (typeof window !== 'undefined') {
    // 간단한 토스트 메시지 (toast가 없는 경우를 대비)
    const toast = document.createElement('div');
    toast.className = 'fixed top-4 right-4 bg-blue-500 text-white px-4 py-2 rounded shadow-lg z-50';
    toast.textContent = `FileTree에서 "${props.path}" 위치로 이동합니다`;
    document.body.appendChild(toast);
    
    setTimeout(() => {
      if (toast.parentNode) {
        toast.parentNode.removeChild(toast);
      }
    }, 3000);
  }
};

const setupLinkIntercepts = async () => {
  await nextTick();
  if (!contentContainer.value) return;

  // Delegated event listener for all clicks within the content area
  contentContainer.value.addEventListener('click', (event) => {
    const link = event.target.closest('a');
    if (!link) return;

    const href = link.getAttribute('href');
    if (!href) return;

    // Add visual feedback for link clicks
    link.style.opacity = '0.6';
    link.style.transform = 'scale(0.98)';
    setTimeout(() => {
      link.style.opacity = '';
      link.style.transform = '';
    }, 150);

    // Handle tool links
    if (href.startsWith('mcp://')) {
      event.preventDefault();
      const url = new URL(href);
      const tool = url.hostname;
      emit('navigate-tool', { tool });
      return;
    }

    // Handle anchor links
    if (href.startsWith('#')) {
      event.preventDefault();
      const targetId = href.substring(1);
      
      // Try to find the target element
      let targetElement = document.getElementById(targetId);
      
      // If not found, try to find by exact match first
      if (!targetElement) {
        const allElements = document.querySelectorAll('h1, h2, h3, h4, h5, h6');
        for (const el of allElements) {
          if (el.id === targetId) {
            targetElement = el;
            break;
          }
        }
      }
      
      // If still not found, try to find by text content match (for emoji headers)
      if (!targetElement) {
        const allElements = document.querySelectorAll('h1, h2, h3, h4, h5, h6');
        for (const el of allElements) {
          const textContent = el.textContent || '';
          // VS Code 스타일 슬러그 생성으로 매칭 시도
          const expectedId = textContent
            .trim()
            .replace(/\s+/g, '-')
            .replace(/-+/g, '-')
            .replace(/^-+|-+$/g, '')
            .toLowerCase();
          
          if (expectedId === targetId) {
            targetElement = el;
            break;
          }
        }
      }
      
      // If still not found, try partial match (for Korean headers)
      if (!targetElement) {
        const allElements = document.querySelectorAll('h1, h2, h3, h4, h5, h6');
        for (const el of allElements) {
          if (el.id && el.id.includes(targetId)) {
            targetElement = el;
            break;
          }
        }
      }
      
      if (targetElement) {
        // Add highlight effect to the target element
        targetElement.style.backgroundColor = '#fef3c7';
        targetElement.style.border = '2px solid #f59e0b';
        targetElement.style.borderRadius = '4px';
        targetElement.style.padding = '8px';
        targetElement.style.margin = '4px 0';
        targetElement.style.transition = 'all 0.3s ease';
        
        // Use scrollIntoView with proper options
        targetElement.scrollIntoView({ 
          behavior: 'smooth', 
          block: 'start',
          inline: 'nearest'
        });
        
        // Additional scroll adjustment for better positioning
        setTimeout(() => {
          const container = contentContainer.value;
          if (container) {
            const containerRect = container.getBoundingClientRect();
            const elementRect = targetElement.getBoundingClientRect();
            
            // If element is too close to top, adjust scroll position
            if (elementRect.top < containerRect.top + 80) {
              container.scrollBy({
                top: elementRect.top - containerRect.top - 80,
                behavior: 'smooth'
              });
            }
          }
        }, 100);
        
        // Remove highlight after 3 seconds
        setTimeout(() => {
          targetElement.style.backgroundColor = '';
          targetElement.style.border = '';
          targetElement.style.borderRadius = '';
          targetElement.style.padding = '';
          targetElement.style.margin = '';
        }, 3000);
      }
      return;
    }

    // Handle external links
    if (href.startsWith('http://') || href.startsWith('https://')) {
      link.setAttribute('target', '_blank');
      link.setAttribute('rel', 'noopener noreferrer');
      return;
    }

    // Handle internal knowledge base links
    event.preventDefault();
    let targetPath = href;

    // Resolve relative paths
    if (!targetPath.startsWith('/')) {
      targetPath = resolveRelativePath(props.path || '', targetPath);
    }

    // Clean the path to prevent duplication using the new comprehensive function
    targetPath = preventPathDuplication(targetPath);

    // Set loading state
    isLoading.value = true;

    // Check if the target is a directory
    if (isDirectoryPath(targetPath)) {
      // For directories, try to find README.md first
      const normalizedPath = normalizeDirectoryPath(targetPath);
      
      // Dispatch navigation event with directory flag
      window.dispatchEvent(new CustomEvent('kb:open', {
        detail: { 
          path: normalizedPath, 
          container: 'curriculum',
          isDirectory: true,
          originalPath: targetPath
        }
      }));
    } else {
      // For files, proceed normally
      window.dispatchEvent(new CustomEvent('kb:open', {
        detail: { path: targetPath, container: 'curriculum' }
      }));
    }
  });
};

onMounted(() => {
  setupLinkIntercepts()
  setupDetailsHandlers()
  setupCodeBlockHandlers()
})
watch(() => props.content, () => {
  setupLinkIntercepts()
  setupDetailsHandlers()
  setupCodeBlockHandlers()
  // Clear loading state when content changes
  isLoading.value = false
})

watch(() => props.path, () => {
  // Clear loading state when path changes
  isLoading.value = false
})

// Slides overlay logic
const isSlideView = ref(false);
const slideHtml = ref('');
const slidePdfUrl = ref('');
const config = useRuntimeConfig();
function resolveApiBase(){
  const configured = (config.public?.apiBaseUrl) || '/api'
  if (typeof window !== 'undefined'){
    try{
      const u = new URL(configured)
      const browserHost = window.location.hostname
      if (u.origin === 'null') return configured
      if (u.hostname !== 'localhost' && u.hostname !== '127.0.0.1' && u.hostname !== 'api.goldencircle.us' && u.hostname !== browserHost){
        const port = u.port || '8000'
        const scheme = u.protocol.replace(':','') || 'https'
        return `${scheme}://${browserHost}:${port}`
      }
    }catch{ /* ignore */ }
  }
  return configured
}
const apiBase = resolveApiBase()
const API_KEY = 'my_mcp_eagle_tiger';

const slideTitle = computed(() => {
  if (!props.path) return 'Slides';
  return props.path.split('/').pop()?.replace(/_/g, ' ').replace(/\.md$/i, '') + ' - Slides';
});

const openSlides = async () => {
  if (!props.path) return;
  try {
    const url = `${apiBase}/v1/slides?curriculum_path=${encodeURIComponent(cleanApiPath(props.path))}`;
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
      slideHtml.value = DOMPurify.sanitize(marked(md));
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
    try { URL.revokeObjectURL(slidePdfUrl.value); } catch {}
  }
  slidePdfUrl.value = '';
  slideHtml.value = '';
  isSlideView.value = false;
};

const downloadPdf = async () => {
  if (!props.path) return;
  try {
    // Normalize path for backend (strip leading mdc:, ensure textbook-relative when needed)
    const raw = String(props.path||'')
    let normalized = raw.replace(/^mdc:/,'').replace(/^\/+/, '')
    // Remove repository-root prefixes if present to send path relative to textbook root
    normalized = normalized.replace(/^mcp_knowledge_base\//,'')
    normalized = normalized.replace(/^cloud_basic\/textbook\//,'')
    normalized = normalized.replace(/^textbook\//,'')
    const url = `${apiBase}/v1/curriculum/pdf?path=${encodeURIComponent(cleanApiPath(normalized))}`;
    const res = await fetch(url, { headers: { 'X-API-Key': API_KEY } });
    if (!res.ok) throw new Error(`Failed to export PDF: ${res.status}`);
    const ct = (res.headers.get('content-type') || '').toLowerCase();
    const blob = await res.blob();
    const a = document.createElement('a');
    const objectUrl = URL.createObjectURL(blob);
    a.href = objectUrl;
    const base = props.path.split('/').pop()?.replace(/\.md$/i,'') || 'document';
    a.download = base + (ct.includes('application/pdf') ? '.pdf' : '.md');
    document.body.appendChild(a);
    a.click();
    a.remove();
    setTimeout(() => URL.revokeObjectURL(objectUrl), 1500);
  } catch (e) {
    console.error(e);
    alert('PDF 생성 중 오류가 발생했습니다.');
  }
};

// React to slide prop: show provided PDF/HTML slides without requiring openSlides()
watch(() => props.slide, (s) => {
  // Reset previous view
  closeSlides();
  if (s && typeof s === 'object') {
    if (s.type === 'pdf' && s.url) {
      // Use provided object URL; do not recreate
      slidePdfUrl.value = String(s.url);
      slideHtml.value = '';
      isSlideView.value = true;
      return;
    }
    if (s.html) {
      slideHtml.value = String(s.html);
      slidePdfUrl.value = '';
      isSlideView.value = true;
      return;
    }
  }
  // Fallback: when content exists, show content view
  isSlideView.value = false;
}, { immediate: true, deep: false })

// When content switches to non-empty, prefer content view
watch(() => props.content, (c) => {
  if (c && String(c).length > 0) {
    isSlideView.value = false;
  }
})
</script>

<style>
.fade-enter-active, .fade-leave-active { transition: opacity 0.2s ease; }
.fade-enter-from, .fade-leave-to { opacity: 0; }

/* 링크 가시성 및 상호작용 개선 */
.prose a {
  cursor: pointer;
  text-decoration: underline;
}
.prose a:hover {
  text-decoration: underline;
}

/* 표(Table) 렌더링 및 가독성 개선 */
.table-scroll { 
  overflow-x: auto; 
  margin: 1rem 0;
  border-radius: 8px;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
}

.prose table { 
  width: 100%; 
  border-collapse: collapse; 
  table-layout: auto; 
  background: white;
}

.prose thead th { 
  background: #f9fafb; 
  font-weight: 600;
  color: #374151;
}

.prose th, .prose td { 
  border: 1px solid #e5e7eb; 
  padding: 0.75rem 1rem; 
  vertical-align: top; 
  text-align: left;
}

.prose tbody tr:nth-child(odd) { 
  background: #fafafa; 
}

.prose tbody tr:hover {
  background: #f3f4f6;
}

/* 마크다운 접기 기능 스타일링 */
.prose details {
  margin: 1rem 0;
  border: 1px solid #e5e7eb;
  border-radius: 8px;
  background: #f9fafb;
  overflow: hidden;
  transition: all 0.3s ease;
}

.prose details[open] {
  box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
}

.prose details summary {
  padding: 0.75rem 1rem;
  background: #f3f4f6;
  border-bottom: 1px solid #e5e7eb;
  cursor: pointer;
  font-weight: 600;
  color: #374151;
  user-select: none;
  transition: background-color 0.2s ease;
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.prose details summary:hover {
  background: #e5e7eb;
}

.prose details summary:focus {
  outline: 2px solid #3b82f6;
  outline-offset: 2px;
  background: #e5e7eb;
}

.prose details summary::before {
  content: '▶';
  font-size: 0.75rem;
  color: #6b7280;
  transition: transform 0.2s ease;
  margin-right: 0.25rem;
}

.prose details[open] summary::before {
  transform: rotate(90deg);
}

.prose details[open] summary {
  border-bottom: 1px solid #e5e7eb;
}

.prose details > *:not(summary) {
  padding: 1rem;
  margin: 0;
}

.prose details pre {
  margin: 0;
  border-radius: 0;
  border: none;
  background: #1f2937;
}

.prose details code {
  background: #f3f4f6;
  padding: 0.125rem 0.25rem;
  border-radius: 0.25rem;
  font-size: 0.875em;
}

.prose details pre code {
  background: transparent;
  padding: 0;
}

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

/* 코드 블록 스타일링 개선 */
.prose pre {
  background: #1f2937;
  color: #f9fafb;
  padding: 1rem;
  border-radius: 8px;
  overflow-x: auto;
  font-family: 'Monaco', 'Menlo', 'Ubuntu Mono', monospace;
  font-size: 0.875rem;
  line-height: 1.5;
  margin: 1rem 0;
  border: 1px solid #374151;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

.prose code {
  background: #f3f4f6;
  color: #1f2937;
  padding: 0.125rem 0.375rem;
  border-radius: 4px;
  font-family: 'Monaco', 'Menlo', 'Ubuntu Mono', monospace;
  font-size: 0.875em;
  font-weight: 500;
}

.prose pre code {
  background: transparent;
  color: inherit;
  padding: 0;
  border-radius: 0;
  font-size: inherit;
  font-weight: inherit;
}

/* 인라인 코드와 블록 코드 구분 */
.prose p code {
  background: #f3f4f6;
  color: #dc2626;
  padding: 0.125rem 0.375rem;
  border-radius: 4px;
  font-size: 0.875em;
}

/* 코드 블록 내부 스타일링 */
.prose pre code {
  display: block;
  white-space: pre;
  overflow-x: auto;
}

/* 코드 블록 복사 버튼 스타일 */
.prose pre {
  position: relative;
}

.prose pre .copy-button {
  position: absolute;
  top: 0.5rem;
  right: 0.5rem;
  background: #374151;
  color: #f9fafb;
  padding: 0.25rem 0.5rem;
  border-radius: 4px;
  font-size: 0.75rem;
  cursor: pointer;
  opacity: 0;
  transition: opacity 0.2s ease;
  border: none;
  z-index: 10;
}

.prose pre:hover .copy-button {
  opacity: 0.7;
}

.prose pre .copy-button:hover {
  opacity: 1;
}

/* 코드 블록 내부 링크 스타일 */
.prose pre a {
  color: #60a5fa;
  text-decoration: underline;
}

.prose pre a:hover {
  color: #93c5fd;
}

/* 코드 블록 내부 주석 스타일 */
.prose pre .comment {
  color: #6b7280;
  font-style: italic;
}

/* 코드 블록 내부 키워드 스타일 */
.prose pre .keyword {
  color: #f472b6;
  font-weight: bold;
}

/* 코드 블록 내부 문자열 스타일 */
.prose pre .string {
  color: #34d399;
}

/* 코드 블록 내부 숫자 스타일 */
.prose pre .number {
  color: #fbbf24;
}

/* 코드 블록 내부 키워드 스타일 */
.prose pre .keyword {
  color: #f472b6;
  font-weight: bold;
}

/* 코드 블록 내부 문자열 스타일 */
.prose pre .string {
  color: #34d399;
}

/* 코드 블록 내부 숫자 스타일 */
.prose pre .number {
  color: #fbbf24;
}
</style>
