<template>
  <div v-if="content || slide" class="h-full overflow-y-auto bg-white" ref="contentContainer">
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
  marked.setOptions({ 
    breaks: true, 
    gfm: true, 
    headerIds: true, 
    mangle: false,
    headerPrefix: '' // Remove any prefix from generated IDs
  })
  
  // Custom renderer for Korean header IDs
  const renderer = new marked.Renderer()
  renderer.heading = function(text, level) {
    // Create Korean-friendly ID by converting to lowercase and replacing spaces with hyphens
    const id = text.toLowerCase()
      .replace(/[^\w\s-]/g, '') // Remove special characters except word chars, spaces, and hyphens
      .replace(/\s+/g, '-') // Replace spaces with hyphens
      .replace(/-+/g, '-') // Replace multiple hyphens with single hyphen
      .replace(/^-|-$/g, '') // Remove leading/trailing hyphens
    
    return `<h${level} id="${id}">${text}</h${level}>`
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
              if(['cloud_basic','curriculum','textbook','slides','mcp_knowledge_base'].includes(first)) resolved = rawMd.replace(/^mcp_knowledge_base\//,'')
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
          window.dispatchEvent(new CustomEvent('kb:open', { detail:{ path: decoded, container: 'curriculum' } }))
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
          window.dispatchEvent(new CustomEvent('kb:open', { detail:{ path: decoded, container: 'curriculum', originDir } }))
          return
        }
        // Handle anchor links like '#학습-목표'
        const isHash = /^#/.test(href)
        if(isHash){
          ev.preventDefault()
          const targetId = href.substring(1) // Remove the # symbol
          
          // Try to find the element by exact ID first
          let targetElement = document.getElementById(targetId)
          
          // If not found, try to find by Korean-friendly ID conversion
          if(!targetElement){
            const koreanId = targetId.toLowerCase()
              .replace(/[^\w\s-]/g, '') // Remove special characters except word chars, spaces, and hyphens
              .replace(/\s+/g, '-') // Replace spaces with hyphens
              .replace(/-+/g, '-') // Replace multiple hyphens with single hyphen
              .replace(/^-|-$/g, '') // Remove leading/trailing hyphens
            
            targetElement = document.getElementById(koreanId)
          }
          
          if(targetElement){
            targetElement.scrollIntoView({ 
              behavior: 'smooth', 
              block: 'start',
              inline: 'nearest'
            })
            // Add a temporary highlight effect
            targetElement.style.backgroundColor = '#fef3c7'
            setTimeout(() => {
              targetElement.style.backgroundColor = ''
            }, 2000)
          } else {
            console.warn(`Target element with id "${targetId}" not found`)
            // Try to find by partial match in all headings
            const headings = document.querySelectorAll('h1, h2, h3, h4, h5, h6')
            for(const heading of headings){
              const headingText = heading.textContent || ''
              const headingId = heading.id || ''
              if(headingText.includes(targetId) || headingId.includes(targetId)){
                heading.scrollIntoView({ 
                  behavior: 'smooth', 
                  block: 'start',
                  inline: 'nearest'
                })
                heading.style.backgroundColor = '#fef3c7'
                setTimeout(() => {
                  heading.style.backgroundColor = ''
                }, 2000)
                break
              }
            }
          }
          return
        }
        
        // Handle relative links like './a.md', '../b.md', 'c.md'
        const hasScheme = /^[a-zA-Z][a-zA-Z0-9+.-]*:/.test(href)
        const isAbsolutePath = /^\//.test(href)
        if(!hasScheme && !isAbsolutePath && href){
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
          window.dispatchEvent(new CustomEvent('kb:open', { detail:{ path: decoded, container: 'curriculum', originDir } }))
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

onMounted(() => {
  setupLinkIntercepts()
  setupDetailsHandlers()
  setupCodeBlockHandlers()
})
watch(() => props.content, () => {
  setupLinkIntercepts()
  setupDetailsHandlers()
  setupCodeBlockHandlers()
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
    const url = `${apiBase}/v1/slides?curriculum_path=${encodeURIComponent(props.path)}`;
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
    const url = `${apiBase}/v1/curriculum/pdf?path=${encodeURIComponent(normalized)}`;
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
.table-scroll { overflow-x: auto; }
.prose table { width: 100%; border-collapse: collapse; table-layout: auto; }
.prose thead th { background: #f9fafb; }
.prose th, .prose td { border: 1px solid #e5e7eb; padding: 0.5rem 0.75rem; vertical-align: top; }
.prose tbody tr:nth-child(odd) { background: #fafafa; }

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
</style>
