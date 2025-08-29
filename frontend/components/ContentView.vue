<template>
  <div v-if="content" class="h-full overflow-y-auto bg-white" ref="contentContainer">
    <!-- Action row (optional) -->
    <div class="flex items-center justify-end gap-2 px-4 pt-3" v-if="path">
      <button
        v-if="path && !isSlideView"
        @click="downloadPdf"
        class="px-3 py-1 text-sm rounded bg-emerald-600 text-white hover:bg-emerald-700 transition-colors"
      >
        PDF
      </button>
    </div>

    <!-- Fade between content and slides in-place -->
    <transition name="fade" mode="out-in">
      <div v-if="!isSlideView" key="content-view" class="prose max-w-none p-4">
        <div v-html="renderedContent"></div>
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
import { ref, computed, onMounted, watch, nextTick } from 'vue';
import { useRuntimeConfig } from '#app';
import { marked } from 'marked';
import mermaid from 'mermaid';
import embedVega from 'vega-embed';
import DOMPurify from 'dompurify'

const props = defineProps({
  content: String,
  slide: Object,
  path: String,
  readonly: { type: Boolean, default: false }
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
  marked.setOptions({ breaks: true, gfm: true, headerIds: true, mangle: false })
  // Allow custom KB scheme 'mdc:' so hrefs are preserved for interception
  return DOMPurify.sanitize(marked.parse(body), { ADD_URI_SAFE: ['mdc'] });
});

let mermaidInitialized = false
const setupLinkIntercepts = async () => {
  await nextTick()
  if (contentContainer.value) {
    // render mermaid
    try{
      const allCodeBlocks = contentContainer.value.querySelectorAll('pre code, code')
      allCodeBlocks.forEach(async (node) => {
        const cls = String(node.className||'')
        const text = String(node.textContent||'').trim()
        const isMermaid = cls.includes('language-mermaid') || /^(graph|flowchart|sequenceDiagram|classDiagram|stateDiagram|erDiagram|gantt)\b/.test(text)
        if(!isMermaid) return
        const parent = (node.parentElement && node.parentElement.tagName.toLowerCase() === 'pre') ? node.parentElement : node
        if(parent.getAttribute('data-rendered-mermaid') === '1') return
        const mount = document.createElement('div')
        parent.replaceWith(mount)
        mount.setAttribute('data-rendered-mermaid','1')
        try{
          if(!mermaidInitialized){ mermaid.initialize({ startOnLoad:false, theme:'default' }); mermaidInitialized = true }
          const out = await mermaid.render('m'+Math.random().toString(36).slice(2), text)
          mount.innerHTML = out.svg
        }catch{}
      })
      // vega-lite
      const vegaNodes = contentContainer.value.querySelectorAll('pre code.language-json, pre code.language-vega-lite, code.language-vega-lite')
      vegaNodes.forEach(async (node) => {
        const text = (node.textContent||'').trim()
        if(!/vega-lite/i.test(text) && !((node.className||'').includes('vega-lite'))) return
        const pre = node.closest('pre')
        const mount = document.createElement('div')
        if(pre) pre.replaceWith(mount); else (node).replaceWith(mount)
        try{
          const jsonText = text.replace(/^[\/\s]*vega-lite\s*/i,'')
          const spec = JSON.parse(jsonText.replace(/^\/\/.*$/gm,''))
          await embedVega(mount, spec, { actions:false })
        }catch{}
      })
      // Easy Copy buttons on code blocks
      const codeBlocks = contentContainer.value.querySelectorAll('pre > code')
      codeBlocks.forEach((codeEl) => {
        const pre = codeEl.closest('pre')
        if(!pre || pre.dataset.kbCopyBound === '1') return
        pre.style.position = pre.style.position || 'relative'
        const btn = document.createElement('button')
        btn.type = 'button'
        btn.className = 'kb-copy-btn'
        btn.textContent = 'Copy'
        btn.title = 'Copy code to clipboard'
        btn.addEventListener('click', async (e) => {
          e.preventDefault(); e.stopPropagation()
          try{
            const text = (codeEl.textContent||'')
            await navigator.clipboard.writeText(text)
            const old = btn.textContent
            btn.textContent = 'Copied'
            setTimeout(()=>{ btn.textContent = old || 'Copy' }, 1200)
          }catch{}
        })
        pre.appendChild(btn)
        pre.dataset.kbCopyBound = '1'
      })
    }catch{}
    // Open tool links (mcp://)
    contentContainer.value.querySelectorAll('a[href^="mcp://"]').forEach(link => {
      link.addEventListener('click', (event) => {
        event.preventDefault();
        const url = new URL(link.href);
        const tool = url.hostname;
        emit('navigate-tool', { tool });
      });
    });
    // Auto-linkify plain URLs and .md references in text nodes
    try{
      const basePathFull = props && props.path ? String(props.path) : ''
      const baseRel = basePathFull.replace(/^mdc:/,'').replace(/^\//,'').replace(/^mcp_knowledge_base\//,'')
      const baseDirParts = baseRel.split('/').slice(0,-1)
      const urlRegex = /(https?:\/\/[^\s)\]\}]+)(?=[\s)\]\}.]|$)/g
      const mdRegex = /(?<![\w/.-])([\w\-./]+\.md)(?![\w/.-])/g
      const walker = document.createTreeWalker(contentContainer.value, NodeFilter.SHOW_TEXT, {
        acceptNode: (node) => {
          const text = node && node.nodeValue ? String(node.nodeValue) : ''
          if(!text) return NodeFilter.FILTER_REJECT
          const parent = (node.parentElement || node.parentNode)
          const tag = parent && parent.tagName ? String(parent.tagName).toLowerCase() : ''
          if(['a','script','style','code','pre'].includes(tag)) return NodeFilter.FILTER_REJECT
          if(!(urlRegex.test(text) || mdRegex.test(text))) return NodeFilter.FILTER_REJECT
          return NodeFilter.FILTER_ACCEPT
        }
      })
      const resolveRelative = (rel) => {
        const parts = []
        for(const p of baseDirParts){ if(p && p!=='.') parts.push(p) }
        for(const seg of String(rel).split('/')){
          if(!seg || seg==='.') continue
          if(seg==='..'){ if(parts.length) parts.pop(); continue }
          parts.push(seg)
        }
        return parts.join('/')
      }
      const nodesToProcess = []
      while(walker.nextNode()) nodesToProcess.push(walker.currentNode)
      for(const textNode of nodesToProcess){
        const text = String(textNode.nodeValue||'')
        if(!(urlRegex.test(text) || mdRegex.test(text))) continue
        const frag = document.createDocumentFragment()
        let idx = 0
        const pushText = (s) => { if(s) frag.appendChild(document.createTextNode(s)) }
        const matches = []
        text.replace(urlRegex, (m, url, off) => { matches.push({ off, len: m.length, type:'url', val:url }); return m })
        text.replace(mdRegex, (m, md, off) => { matches.push({ off, len: m.length, type:'md', val:md }); return m })
        matches.sort((a,b)=> a.off - b.off)
        const merged = []
        for(const cur of matches){ if(!merged.length || cur.off >= merged[merged.length-1].off + merged[merged.length-1].len){ merged.push(cur) } }
        for(const m of merged){
          pushText(text.slice(idx, m.off))
          if(m.type==='url'){
            const a = document.createElement('a')
            a.href = m.val; a.textContent = m.val
            a.setAttribute('target','_blank'); a.setAttribute('rel','noopener noreferrer')
            frag.appendChild(a)
          }else{
            const rawMd = String(m.val)
            let resolved
            if(rawMd.includes('/')){
              const first = rawMd.split('/')[0]
              if(['cloud_basic','textbook','slides','mcp_knowledge_base'].includes(first)) resolved = rawMd.replace(/^mcp_knowledge_base\//,'')
              else resolved = resolveRelative(rawMd)
            }else{
              resolved = resolveRelative(rawMd)
            }
            const a = document.createElement('a')
            a.href = 'mcp_knowledge_base/' + resolved
            a.textContent = m.val
            try{ a.classList.add('kb-link') }catch{}
            frag.appendChild(a)
          }
          idx = m.off + m.len
        }
        pushText(text.slice(idx))
        if(textNode.parentNode){ textNode.parentNode.replaceChild(frag, textNode) }
      }
    }catch{}
    // Responsive tables: wrap tables with a horizontal scroll container
    try{
      const tables = contentContainer.value.querySelectorAll('table')
      tables.forEach((tbl) => {
        if((tbl.parentElement && tbl.parentElement.classList.contains('table-scroll'))) return
        const wrapper = document.createElement('div')
        wrapper.className = 'table-scroll'
        if(tbl.parentNode){ tbl.parentNode.insertBefore(wrapper, tbl); wrapper.appendChild(tbl) }
      })
    }catch{}
    // Intercept KB links (mdc:mcp_knowledge_base/.. or sanitized to mcp_knowledge_base/...)
    contentContainer.value.querySelectorAll('a[href^="mdc:mcp_knowledge_base/"], a[href^="mcp_knowledge_base/"], a[href^="/mcp_knowledge_base/"]').forEach(link => {
      try{ link.classList.add('kb-link') }catch{}
      link.addEventListener('click', (event) => {
        event.preventDefault()
        try{
          const raw = link.getAttribute('href') || ''
          // normalize: remove mdc: scheme if present, and any leading '/'
          const noScheme = raw.replace(/^mdc:/,'').replace(/^\//,'')
          // strip leading root 'mcp_knowledge_base/'
          const rel = noScheme.replace(/^mcp_knowledge_base\//,'')
          const decoded = decodeURIComponent(rel)
          window.dispatchEvent(new CustomEvent('kb:open', { detail:{ path: decoded, container: 'textbook' } }))
        }catch{}
      })
    })
    // External http(s) links → open in new tab (avoid internal KB absolute links)
    contentContainer.value.querySelectorAll('a[href^="http://"], a[href^="https://"]').forEach(link => {
      try{
        const href = link.getAttribute('href') || ''
        try{
          const u = new URL(href, window.location.origin)
          if(u.origin === window.location.origin && /^\/mcp_knowledge_base\//.test(u.pathname)){
            // internal absolute KB link: let delegated handler process
            return
          }
        }catch{}
        link.setAttribute('target','_blank')
        link.setAttribute('rel','noopener noreferrer')
      }catch{}
    })
    // Delegate click: robust fallback to catch all anchors
    const onClick = (ev) => {
      try{
        const a = ev.target && (ev.target.closest ? ev.target.closest('a') : null)
        if(!a) return
        const href = a.getAttribute('href') || ''
        let isKb = /^mdc:/.test(href) || /^mcp_knowledge_base\//.test(href) || /^\/mcp_knowledge_base\//.test(href)
        if(!isKb && /^https?:\/\//i.test(href)){
          try{
            const u = new URL(href, window.location.origin)
            if(u.origin === window.location.origin && /^\/mcp_knowledge_base\//.test(u.pathname)) isKb = true
          }catch{}
        }
        if(isKb){
          ev.preventDefault()
          const noScheme = href.replace(/^mdc:/,'').replace(/^\//,'')
          const rel = noScheme.replace(/^mcp_knowledge_base\//,'')
          const decoded = decodeURIComponent(rel)
          const originPath = props && props.path ? String(props.path) : ''
          const originRel = originPath.replace(/^mdc:/,'').replace(/^\//,'').replace(/^mcp_knowledge_base\//,'')
          const originDir = originRel.split('/').slice(0,-1).join('/')
          window.dispatchEvent(new CustomEvent('kb:open', { detail:{ path: decoded, container: 'textbook', originDir } }))
          return
        }
        // Handle relative links like './a.md', '../b.md', 'c.md'
        const isHash = /^#/.test(href)
        const hasScheme = /^[a-zA-Z][a-zA-Z0-9+.-]*:/.test(href)
        const isAbsolutePath = /^\//.test(href)
        if(!isHash && !hasScheme && !isAbsolutePath && href){
          ev.preventDefault()
          const basePath = props && props.path ? String(props.path) : ''
          const baseParts = basePath.split('/').slice(0,-1)
          const hrefParts = href.split('/')
          const stack = []
          for(const part of baseParts){ if(part && part!=='.') stack.push(part) }
          for(const part of hrefParts){ if(!part || part==='.') continue; if(part==='..'){ if(stack.length) stack.pop(); continue } stack.push(part) }
          const resolved = stack.join('/')
          const decoded = decodeURIComponent(resolved)
          const originRel = basePath.replace(/^mdc:/,'').replace(/^\//,'').replace(/^mcp_knowledge_base\//,'')
          const originDir = originRel.split('/').slice(0,-1).join('/')
          window.dispatchEvent(new CustomEvent('kb:open', { detail:{ path: decoded, container: 'textbook', originDir } }))
          return
        }
        if(/^https?:\/\//i.test(href)){
          a.setAttribute('target','_blank'); a.setAttribute('rel','noopener noreferrer')
        }
      }catch{}
    }
    contentContainer.value.addEventListener('click', onClick)
  }
};

onMounted(() => { setupLinkIntercepts() })
watch(() => props.content, () => { setupLinkIntercepts() })

// Slides overlay logic
const isSlideView = ref(false);
const slideHtml = ref('');
const slidePdfUrl = ref('');
const config = useRuntimeConfig();
function resolveApiBase(){
  const configured = (config.public?.apiBaseUrl) || 'http://localhost:8000'
  if (typeof window !== 'undefined'){
    try{
      const u = new URL(configured)
      const browserHost = window.location.hostname
      if (u.hostname !== 'localhost' && u.hostname !== '127.0.0.1' && u.hostname !== browserHost){
        const port = u.port || '8000'
        return `${window.location.protocol}//${browserHost}:${port}`
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
    URL.revokeObjectURL(slidePdfUrl.value);
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
    const url = `${apiBase}/api/v1/curriculum/pdf?path=${encodeURIComponent(normalized)}`;
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
.table-scroll { overflow-x: auto; }
.prose table { width: 100%; border-collapse: collapse; table-layout: auto; }
.prose thead th { background: #f9fafb; }
.prose th, .prose td { border: 1px solid #e5e7eb; padding: 0.5rem 0.75rem; vertical-align: top; }
.prose tbody tr:nth-child(odd) { background: #fafafa; }

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
