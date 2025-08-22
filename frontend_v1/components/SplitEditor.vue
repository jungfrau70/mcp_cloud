<template>
  <div class="flex h-full w-full overflow-hidden">
    <!-- Outline Panel -->
        <div class="w-56 border-r bg-gray-50 flex flex-col" v-if="showOutline">
          <div class="p-2 font-semibold text-xs tracking-wide text-gray-600 border-b">OUTLINE</div>
          <div class="flex-1 overflow-auto text-sm" role="tree" aria-label="Document outline">
            <ul>
              <li v-for="item in outline" :key="item.line" role="none">
                <button
                  role="treeitem"
                  :aria-current="activeOutlineLine && item.line === activeOutlineLine ? 'true' : 'false'"
                  class="block w-full text-left px-2 py-1 hover:bg-indigo-50 rounded focus:outline-none focus:ring-1 focus:ring-indigo-400"
                  :class="[ 'pl-' + (item.level * 2), activeOutlineLine && item.line === activeOutlineLine ? 'bg-indigo-100 text-indigo-700' : '' ]"
                  @click="scrollToLine(item.line)"
                  :title="`Line ${item.line}`"
                >
                  <span :class="{'font-semibold': item.level === 1}">#{{ item.level }} {{ item.text }}</span>
                </button>
              </li>
            </ul>
          </div>
        </div>

    <!-- Editor & Preview -->
    <div class="flex-1 flex flex-col">
      <!-- Toolbar -->
      <div class="flex items-center gap-2 p-2 border-b bg-white text-sm">
        <button @click="emitSave" class="px-2 py-1 rounded bg-indigo-600 text-white hover:bg-indigo-500" :disabled="saving">Save</button>
        <input v-model="saveMessage" placeholder="commit message" class="px-2 py-1 text-xs border rounded w-48 focus:outline-none focus:ring" />
  <button @click="toggleOutline" class="px-2 py-1 rounded bg-gray-200 hover:bg-gray-300">Outline</button>
        <button @click="toggleVersions" class="px-2 py-1 rounded bg-gray-200 hover:bg-gray-300">Versions</button>
  <button @click="toggleDiff" class="px-2 py-1 rounded bg-gray-200 hover:bg-gray-300" :disabled="!versions.length">Diff</button>
        <button @click="requestOutline" class="px-2 py-1 rounded bg-gray-200 hover:bg-gray-300" :disabled="outlineLoading">Refresh Outline</button>
        <span v-if="saving" class="text-gray-500 text-xs">Saving...</span>
        <span v-if="lastSaved" class="text-gray-400 text-xs">v{{ lastVersion }} @ {{ lastSaved }}</span>
        <div class="flex-1"></div>
        <button @click="togglePreview" class="px-2 py-1 rounded bg-gray-200 hover:bg-gray-300">{{ showPreview ? 'Editor Only' : 'Split' }}</button>
      </div>

      <div class="flex flex-1 min-h-0">
        <!-- Conflict Resolution Panel (overlay) -->
        <div v-if="conflictActive" class="absolute inset-0 z-20 flex">
          <div class="w-96 h-full border-r bg-white flex flex-col shadow-xl">
            <div class="p-3 border-b bg-amber-50 flex items-center gap-2 text-xs font-semibold text-amber-700">
              Conflict Detected
              <span class="ml-auto text-[10px] text-amber-600">local vs upstream v{{ conflictLatestVersion }}</span>
            </div>
            <div class="p-3 flex-1 overflow-auto text-xs space-y-3">
              <div class="space-y-1">
                <div class="font-semibold text-gray-700">Stats</div>
                <ul class="list-disc ml-4 text-gray-600">
                  <li>Local changed lines: {{ conflictStats.changedLocal }}</li>
                  <li>Upstream changed lines: {{ conflictStats.changedUpstream }}</li>
                  <li>Potential conflicts: {{ conflictStats.conflicts }}</li>
                </ul>
              </div>
              <div>
                <div class="font-semibold text-gray-700 mb-1">Preview (first 40 lines diff)</div>
                <pre class="bg-gray-900 text-gray-100 p-2 rounded max-h-60 overflow-auto text-[11px] leading-snug"><span v-for="(l,i) in conflictPreview" :key="i" :class="diffClass(l)">{{ l }}
</span></pre>
              </div>
              <div class="space-y-2">
                <button @click="attemptMerge" class="w-full px-2 py-1 text-xs rounded bg-indigo-600 text-white hover:bg-indigo-500">Auto Merge (Trivial)</button>
                <button @click="overwriteWithMine" class="w-full px-2 py-1 text-xs rounded bg-red-600 text-white hover:bg-red-500">Overwrite With Mine</button>
                <button @click="() => { draft = conflictLatestContent; conflictActive = false }" class="w-full px-2 py-1 text-xs rounded bg-blue-600 text-white hover:bg-blue-500">Accept Upstream</button>
                <button @click="dismissConflict" class="w-full px-2 py-1 text-xs rounded bg-gray-200 hover:bg-gray-300 text-gray-700">Dismiss</button>
              </div>
              <div v-if="mergeResultMsg" class="text-[10px] text-indigo-700 whitespace-pre-line border border-indigo-200 bg-indigo-50 px-2 py-1 rounded">{{ mergeResultMsg }}</div>
              <p class="text-[10px] text-gray-500 leading-relaxed">자동 병합은 줄 배열이 동일할 때만 수행합니다. 충돌 마커(<<<<<<< >>>>>>>)가 남아 있다면 수동 편집 후 다시 저장하세요.</p>
            </div>
          </div>
          <div class="flex-1 h-full relative bg-white/70 backdrop-blur-sm"></div>
        </div>
        <div class="flex-1 flex flex-col">
          <textarea
            ref="editorEl"
            v-model="draft"
            class="flex-1 font-mono text-sm p-3 outline-none resize-none"
            @input="onInput"
            @scroll="onEditorScroll"
          ></textarea>
        </div>
        <div v-if="showPreview && !showDiff" class="flex-1 border-l overflow-auto p-4 prose max-w-none bg-white">
          <div ref="previewEl" v-html="rendered"></div>
        </div>
        <div v-if="showDiff" class="flex-1 border-l bg-white">
          <DiffViewer
            v-if="versions.length"
            :key="diffKey"
            :path="path"
            :versions="versionsSorted"
            :default-left="diffLeft"
            :default-right="diffRight"
            @close="showDiff=false"
          />
        </div>
        <div v-if="showVersions" class="w-64 border-l bg-gray-50 flex flex-col">
          <div class="p-2 font-semibold text-xs tracking-wide text-gray-600 border-b flex items-center">VERSIONS
            <button @click="loadVersions" class="ml-auto text-[10px] px-1 py-0.5 bg-white border rounded">↻</button>
          </div>
          <div class="flex-1 overflow-auto text-xs">
            <ul>
              <li v-for="v in versions" :key="v.id" class="border-b px-2 py-1 hover:bg-indigo-50 cursor-pointer group" @click="pickVersionForDiff(v.version_no)">
                <div class="flex items-center justify-between">
                  <div class="font-mono">v{{ v.version_no }}</div>
                  <span v-if="v.version_no===diffLeft" class="text-[10px] text-indigo-600">LEFT</span>
                  <span v-else-if="v.version_no===diffRight" class="text-[10px] text-green-600">RIGHT</span>
                </div>
                <div class="truncate text-[11px]" :title="v.message">{{ v.message || '—' }}</div>
                <div class="text-[10px] text-gray-400">{{ formatTs(v.created_at) }}</div>
              </li>
              <li v-if="!versions.length" class="px-2 py-4 text-center text-gray-400">No versions</li>
            </ul>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, watch, computed, onBeforeUnmount } from 'vue'
import { merge3 } from '~/utils/threeWayMerge.js'
import { useKbApi } from '~/composables/useKbApi'
import { marked } from 'marked'
import DiffViewer from '~/components/DiffViewer.vue'

const props = defineProps({
  path: { type: String, required: false },
  content: { type: String, required: false, default: '' }
})
const emit = defineEmits(['save'])

import { useDocStore } from '~/stores/doc'
const docStore = useDocStore()
const draft = ref(props.content)
// Sync with central store if same path
watch(() => props.content, c => { if (c !== draft.value) draft.value = c })
watch(() => docStore.path, p => { if(p === props.path && docStore.content !== draft.value) draft.value = docStore.content })
watch(draft, v => { if(docStore.path === props.path) docStore.update(v) })

const showPreview = ref(true)
const showOutline = ref(true)
const showVersions = ref(false)
const showDiff = ref(false)
const outline = ref([])
const outlineLoading = ref(false)
const activeOutlineLine = ref(null)
const editorEl = ref(null)
const previewEl = ref(null)
let lineOffsets = [] // character start positions for each line (1-based logical lines mapped to 0-based indices)
let totalChars = 0
let previewObserver = null
const prefersReducedMotion = typeof window !== 'undefined' && window.matchMedia ? window.matchMedia('(prefers-reduced-motion: reduce)').matches : false
const smoothScrollEnabled = computed(() => !prefersReducedMotion)
const saving = ref(false)
const lastSaved = ref('')
const lastVersion = ref(0)
const baseContent = ref('') // content at last successful load/save (merge base)
const baseVersion = ref(0)
const saveMessage = ref('')
const versions = ref([])
const versionsLoading = ref(false)
const versionsSorted = computed(() => [...versions.value].sort((a,b) => b.version_no - a.version_no))
// Diff selection state
const diffLeft = ref(null)
const diffRight = ref(null)
const diffKey = computed(() => `${diffLeft.value||''}-${diffRight.value||''}`)

const rendered = computed(() => marked.parse(draft.value || ''))

function togglePreview(){ showPreview.value = !showPreview.value }
function toggleOutline(){ showOutline.value = !showOutline.value }
function toggleVersions(){ if(!showVersions.value){ loadVersions() } showVersions.value = !showVersions.value }
async function toggleDiff(){
  if(!versions.value.length){
    await loadVersions()
    if(!versions.value.length) return
  }
  if(!showDiff.value){
    // refresh versions before opening for accuracy
    await loadVersions()
    // initialize default pair if not chosen
    if(versionsSorted.value.length >= 2 && (!diffLeft.value || !diffRight.value)){
      diffRight.value = versionsSorted.value[0].version_no
      diffLeft.value = versionsSorted.value[1].version_no
    }
  }
  showDiff.value = !showDiff.value
}

function pickVersionForDiff(vno){
  // First click sets left if absent, second sets right and opens diff.
  if(diffLeft.value===null){
    diffLeft.value = vno
  } else if(diffRight.value===null){
    if(vno === diffLeft.value){
      // ignore selecting same version
      return
    }
    diffRight.value = vno
    showDiff.value = true
  } else {
    // rotate: shift right to left, set new right
    diffLeft.value = diffRight.value
    diffRight.value = vno
  }
}

let outlineTimer
function onInput(){
  clearTimeout(outlineTimer)
  // rebuild line offsets soon after input
  outlineTimer = setTimeout(() => { buildLineOffsets(); requestOutline(); schedulePreviewScan() }, 500)
}

async function requestOutline(){
  if(!draft.value) { outline.value = []; return }
  outlineLoading.value = true
  try {
    const api = useKbApi()
    const data = await api.outline(draft.value)
    outline.value = data.outline || []
  } finally {
    outlineLoading.value = false
  }
}

function emitSave(){
  saving.value = true
  emit('save', { path: props.path, content: draft.value, message: saveMessage.value || undefined })
}

function scrollToLine(line){
  if(!editorEl.value) return
  buildLineOffsets()
  const totalLines = lineOffsets.length
  const target = Math.max(1, Math.min(line, totalLines))
  // compute char offset of target line and map to scroll position
  const charOffset = lineOffsets[target-1] || 0
  const ratio = totalChars ? (charOffset / totalChars) : 0
  editorEl.value.scrollTop = ratio * (editorEl.value.scrollHeight - editorEl.value.clientHeight)
  activeOutlineLine.value = target
  // also scroll preview to corresponding heading if exists
  scrollPreviewToLine(target)
}

// external update hook
function setSaved(meta){
  saving.value = false
  lastSaved.value = new Date().toLocaleTimeString()
  lastVersion.value = meta?.version_no || lastVersion.value + 1
  baseContent.value = draft.value
  baseVersion.value = lastVersion.value
  saveMessage.value = ''
  if(showVersions.value) loadVersions()
}

async function loadVersions(){
  if(!props.path) return
  versionsLoading.value = true
  try {
    const api = useKbApi()
    const data = await api.listVersions(props.path)
    versions.value = data.versions || []
  } finally {
    versionsLoading.value = false
  }
}

function formatTs(ts){
  if(!ts) return ''
  try { return new Date(ts).toLocaleString() } catch(e){ return ts }
}

watch(() => props.path, () => { requestOutline(); buildLineOffsets(); schedulePreviewScan() })
watch(rendered, () => { schedulePreviewScan() })

// Initialize base when first mounted / content provided
if(props.content){
  baseContent.value = props.content
  baseVersion.value = lastVersion.value
}

// -----------------------------
// Conflict Resolution (Optimistic Lock)
// -----------------------------
const conflictActive = ref(false)
const conflictLatestContent = ref('')
const conflictLatestVersion = ref(0)
const conflictStats = ref({ changedLocal: 0, changedUpstream: 0, conflicts: 0 })
const conflictPreview = ref([])
const mergeResultMsg = ref('')

function handleConflict(latestContent, latestVersion){
  conflictActive.value = true
  conflictLatestContent.value = latestContent
  conflictLatestVersion.value = latestVersion
  // compute simple stats (line count diffs)
  const baseLines = baseContent.value.split('\n')
  const localLines = draft.value.split('\n')
  const upstreamLines = latestContent.split('\n')
  const max = Math.max(baseLines.length, localLines.length, upstreamLines.length)
  let changedLocal = 0, changedUpstream = 0, conflicts = 0
  for(let i=0;i<max;i++){
    const b = baseLines[i] ?? ''
    const l = localLines[i] ?? ''
    const u = upstreamLines[i] ?? ''
    const localChanged = b !== l
    const upstreamChanged = b !== u
    if(localChanged) changedLocal++
    if(upstreamChanged) changedUpstream++
    if(localChanged && upstreamChanged && l !== u) conflicts++
  }
  conflictStats.value = { changedLocal, changedUpstream, conflicts }
  buildConflictPreview(baseLines, localLines, upstreamLines)
}

function attemptMerge(){
  if(!conflictActive.value) return
  mergeResultMsg.value = ''
  const { merged, conflicts } = merge3(baseContent.value, draft.value, conflictLatestContent.value)
  draft.value = merged
  conflictStats.value.conflicts = conflicts
  baseContent.value = conflictLatestContent.value
  baseVersion.value = conflictLatestVersion.value
  lastVersion.value = conflictLatestVersion.value
  if(conflicts === 0){
    mergeResultMsg.value = 'Auto merge succeeded (no conflicts). Review & Save.'
    conflictActive.value = false
  } else {
    mergeResultMsg.value = `Auto merge produced ${conflicts} conflict block(s). Resolve manually then Save.`
  }
}

function overwriteWithMine(){
  // force save without optimistic check
  saving.value = true
  emit('save', { path: props.path, content: draft.value, message: saveMessage.value || undefined, force: true })
  conflictActive.value = false
}

function dismissConflict(){
  conflictActive.value = false
}

function buildConflictPreview(baseLines, localLines, upstreamLines){
  const preview = []
  const limit = 40
  for(let i=0;i<limit;i++){
    const b = baseLines[i] ?? ''
    const l = localLines[i] ?? ''
    const u = upstreamLines[i] ?? ''
    if(l === u && b === l){
      preview.push('  ' + (l || ''))
    } else if(l === u && b !== l){
      preview.push('~ ' + (l || ''))
    } else if(l !== u){
      preview.push('- ' + (l || ''))
      preview.push('+ ' + (u || ''))
    } else if(l !== b){
      preview.push('- ' + (l || ''))
    } else if(u !== b){
      preview.push('+ ' + (u || ''))
    }
  }
  conflictPreview.value = preview
}

function diffClass(line){
  if(line.startsWith('+')) return 'text-green-600'
  if(line.startsWith('-')) return 'text-red-600'
  if(line.startsWith('~')) return 'text-indigo-600'
  return 'text-gray-500'
}

requestOutline()
buildLineOffsets()
schedulePreviewScan()

function buildLineOffsets(){
  const text = draft.value || ''
  // Large documents: offload to idle callback if available to prevent jank
  const compute = () => {
    const lines = text.split('\n')
    lineOffsets = new Array(lines.length)
    let acc = 0
    for(let i=0;i<lines.length;i++){
      lineOffsets[i] = acc
      acc += lines[i].length + 1
    }
    totalChars = acc
  }
  if(text.length > 20000 && typeof window !== 'undefined' && 'requestIdleCallback' in window){
    window.requestIdleCallback(() => compute(), { timeout: 200 })
  } else {
    compute()
  }
}

let lastScrollTs = 0
function onEditorScroll(){
  const now = performance.now()
  if(now - lastScrollTs < 33) return // ~30fps
  lastScrollTs = now
  if(!editorEl.value) return
  const el = editorEl.value
  const ratio = el.scrollTop / Math.max(1, el.scrollHeight - el.clientHeight)
  // derive approximate char position then find line via binary search
  const charPos = Math.floor(ratio * totalChars)
  let lo = 0, hi = lineOffsets.length -1, mid
  while(lo < hi){
    mid = Math.floor((lo+hi+1)/2)
    if(lineOffsets[mid] <= charPos) {
      lo = mid
    } else {
      hi = mid - 1
    }
  }
  const approxLine = lo + 1
  // nearest heading at or before approxLine
  let nearest = null
  for(const item of outline.value){
    if(item.line <= approxLine) {
      nearest = item.line
    } else {
      break
    }
  }
  if(nearest) activeOutlineLine.value = nearest
}

// Preview heading sync
function schedulePreviewScan(){
  requestAnimationFrame(() => scanPreviewHeadings())
}

function scanPreviewHeadings(){
  if(!previewEl.value) return
  if(previewObserver){ previewObserver.disconnect(); previewObserver = null }
  const headings = Array.from(previewEl.value.querySelectorAll('h1, h2, h3, h4, h5, h6'))
  if(!headings.length) return
  // Build index by text with queue of lines for duplicates
  const buckets = new Map()
  for(const item of outline.value){
    const key = item.text.trim()
    if(!buckets.has(key)) buckets.set(key, [])
    buckets.get(key).push(item.line)
  }
  const occurCounter = new Map()
  for(const h of headings){
    const t = (h.textContent || '').trim()
    if(buckets.has(t) && buckets.get(t).length){
      const lineNo = buckets.get(t).shift()
      const occ = (occurCounter.get(t) || 0) + 1
      occurCounter.set(t, occ)
      h.dataset.line = String(lineNo)
      h.dataset.occ = String(occ)
    }
  }
  previewObserver = new IntersectionObserver(entries => {
    const visibles = entries.filter(e => e.isIntersecting)
    if(!visibles.length) return
    let topEntry = visibles[0]
    for(const e of visibles){
      if(e.boundingClientRect.top < topEntry.boundingClientRect.top) topEntry = e
    }
    const ln = Number(topEntry.target.dataset.line)
    if(ln) activeOutlineLine.value = ln
  }, { root: previewEl.value, rootMargin: '0px 0px -70% 0px', threshold: [0, 1] })
  headings.forEach(h => previewObserver.observe(h))
}

function scrollPreviewToLine(line){
  if(!previewEl.value) return
  const target = previewEl.value.querySelector(`[data-line="${line}"]`)
  if(target){
    target.scrollIntoView({ block: 'start', behavior: smoothScrollEnabled.value ? 'smooth' : 'auto' })
  }
}

onBeforeUnmount(() => {
  if(previewObserver){ previewObserver.disconnect(); previewObserver = null }
})

defineExpose({ setSaved, lastVersion, draft, handleConflict })
</script>

<style scoped>
textarea { line-height: 1.4; }
</style>
