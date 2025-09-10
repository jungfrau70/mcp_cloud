<template>
  <div class="w-72 flex-none bg-gray-50 flex flex-col min-h-0">
    <div class="p-2 font-semibold text-xs tracking-wide text-gray-700 border-b flex items-center gap-2">
      <button @click="active='outline'; if(!outline.length) refreshOutline()" :class="tabClass('outline')">Outline</button>
      <button @click="active='versions'; if(!versions.length) loadVersions()" :class="tabClass('versions')">Versions</button>
      <button @click="active='diff'; if(!versions.length) loadVersions()" :class="tabClass('diff')">Diff</button>
      <div class="ml-auto"></div>
      <button v-if="active==='outline'" @click="refreshOutline" class="text-[10px] px-1 py-0.5 bg-white border rounded" :disabled="outlineLoading">↻</button>
      <button v-if="active!=='outline'" @click="loadVersions" class="text-[10px] px-1 py-0.5 bg-white border rounded" :disabled="versionsLoading">↻</button>
    </div>
    <div class="px-2 py-1 text-[10px] text-gray-500 truncate" :title="path || ''" v-if="path">{{ path }}</div>
    <div class="flex-1 overflow-auto text-sm">
      <!-- Outline -->
      <div v-if="active==='outline'" class="p-2">
        <ul>
          <li v-for="item in outline" :key="item.line">
            <button class="block w-full text-left px-2 py-1 hover:bg-indigo-50 rounded" :style="{ paddingLeft: ((item.level - 1) * 12) + 'px' }" @click="$emit('goto-line', item.line)">
              <span :class="{'font-semibold': item.level === 1}">{{ item.text }}</span>
            </button>
          </li>
        </ul>
        <div v-if="!outline.length && !outlineLoading" class="text-gray-400 text-xs p-2">No outline</div>
      </div>
      <!-- Versions -->
      <div v-else-if="active==='versions'">
        <ul>
          <li v-for="v in versionsSorted" :key="v.id" class="border-b px-2 py-1 hover:bg-indigo-50 cursor-pointer group" @click="pickVersionForDiff(v.version_no)">
            <div class="flex items-center justify-between">
              <div class="font-mono">v{{ v.version_no }}</div>
              <span v-if="v.version_no===diffLeft" class="text-[10px] text-indigo-600">LEFT</span>
              <span v-else-if="v.version_no===diffRight" class="text-[10px] text-green-600">RIGHT</span>
            </div>
            <div class="truncate text-[11px]" :title="v.message">{{ v.message || '—' }}</div>
            <div class="text-[10px] text-gray-400">{{ formatTs(v.created_at) }}</div>
          </li>
          <li v-if="!versions.length && !versionsLoading" class="px-2 py-4 text-center text-gray-400">No versions</li>
        </ul>
      </div>
      <!-- Diff -->
      <div v-else class="p-2">
        <DiffViewer v-if="versions.length && diffLeft && diffRight" :key="diffKey" :path="path" :versions="versionsSorted" :default-left="diffLeft" :default-right="diffRight" @close="diffLeft=null; diffRight=null" />
        <div v-else class="text-xs text-gray-500">Select two versions in Versions tab.</div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, watch, onMounted } from 'vue'
import { useKbApi } from '~/composables/useKbApi'
import DiffViewer from '~/components/DiffViewer.vue'

const props = defineProps({
  path: { type: String, required: false },
  content: { type: String, required: false, default: '' }
})
defineEmits(['goto-line'])

const api = useKbApi()
const active = ref('outline')

// Outline
const outline = ref([])
const outlineLoading = ref(false)
function buildLocalOutline(md){
  const out = []
  if(!md) return out
  const lines = String(md).split(/\r?\n/)
  let inCode = false
  let inFrontmatter = false
  // detect frontmatter at top
  if(lines.length && /^\s*---\s*$/.test(lines[0])){
    inFrontmatter = true
  }
  for(let i=0;i<lines.length;i++){
    const line = lines[i]
    if(inFrontmatter){
      if(/^\s*---\s*$/.test(line) && i!==0){ inFrontmatter = false }
      continue
    }
    // skip fenced code blocks
    if(/^\s*```/.test(line) || /^\s*~~~/.test(line)) { inCode = !inCode; continue }
    if(inCode) continue
    // ATX style: allow optional space after hashes and trim trailing hashes
    const m = line.match(/^\s{0,3}(#{1,6})\s*(.*?)\s*#*\s*$/)
    if(m && m[2]){
      let text = String(m[2]).trim()
      // inline cleanup: strip md links, emphasis, code spans
      text = text
        .replace(/\[([^\]]+)\]\([^\)]+\)/g, '$1') // [text](url)
        .replace(/[*_]{1,3}([^*_]+)[*_]{1,3}/g, '$1')  // *em* _em_ **strong**
        .replace(/`([^`]+)`/g, '$1')                   // `code`
        .replace(/<[^>]+>/g, '')                       // inline html
        .trim()
      if(text){ out.push({ level: m[1].length, text, line: i+1 }) }
      continue
    }
    // Setext style (underline with === or ---) for H1/H2
    if(i+1 < lines.length){
      const next = lines[i+1]
      if(/^=+\s*$/.test(next) && line.trim()){
        let text = line.trim()
        text = text
          .replace(/\[([^\]]+)\]\([^\)]+\)/g, '$1')
          .replace(/[*_]{1,3}([^*_]+)[*_]{1,3}/g, '$1')
          .replace(/`([^`]+)`/g, '$1')
          .replace(/<[^>]+>/g, '')
          .trim()
        out.push({ level: 1, text, line: i+1 })
        i++
        continue
      } else if(/^-+\s*$/.test(next) && line.trim()){
        let text = line.trim()
        text = text
          .replace(/\[([^\]]+)\]\([^\)]+\)/g, '$1')
          .replace(/[*_]{1,3}([^*_]+)[*_]{1,3}/g, '$1')
          .replace(/`([^`]+)`/g, '$1')
          .replace(/<[^>]+>/g, '')
          .trim()
        out.push({ level: 2, text, line: i+1 })
        i++
        continue
      }
    }
  }
  return out
}

async function refreshOutline(){
  if(props.content === undefined || props.content === null){ outline.value = []; return }
  outlineLoading.value = true
  const local = buildLocalOutline(props.content)
  try{
    const data = await api.outline(props.content)
    let server = (data && Array.isArray(data.outline)) ? data.outline : []
    server = server.map((it) => ({
      level: it?.level,
      line: it?.line,
      text: typeof it?.text === 'string' ? it.text.trim() : ''
    })).filter(it => it.level && it.line)
    // merge: prefer local text; add any server items not present by line
    const byLine = new Map()
    for(const it of local){ byLine.set(it.line, { ...it }) }
    for(const it of server){ if(!byLine.has(it.line)){ byLine.set(it.line, { ...it }) } }
    outline.value = Array.from(byLine.values()).sort((a,b)=> a.line - b.line)
  } catch{
    outline.value = local
  } finally { outlineLoading.value = false }
}
// Always refresh when content changes; panel may mount after content is ready
watch(() => props.content, () => { refreshOutline() })
// 경로가 바뀌면 즉시 아웃라인/버전을 갱신해 다른 문서의 정보가 남지 않도록 함
watch(() => props.path, () => { refreshOutline(); diffLeft.value = null; diffRight.value = null; loadVersions() })
// Initial refresh on mount in case content is already available
onMounted(() => { if(props.content) refreshOutline() })

// Versions & Diff
const versions = ref([])
const versionsLoading = ref(false)
const versionsSorted = computed(() => [...versions.value].sort((a,b)=> b.version_no - a.version_no))
const diffLeft = ref(null)
const diffRight = ref(null)
const diffKey = computed(() => `${diffLeft.value||''}-${diffRight.value||''}`)
async function loadVersions(){
  if(!props.path) { versions.value = []; return }
  versionsLoading.value = true
  try{ const data = await api.listVersions(props.path); versions.value = data.versions || [] } finally { versionsLoading.value = false }
}
function pickVersionForDiff(vno){
  if(diffLeft.value===null){ diffLeft.value = vno }
  else if(diffRight.value===null){ if(vno !== diffLeft.value){ diffRight.value = vno } }
  else { diffLeft.value = diffRight.value; diffRight.value = vno }
}

function formatTs(ts){ try { return ts ? new Date(ts).toLocaleString() : '' } catch(e){ return ts } }

function tabClass(name){
  return name===active.value ? 'px-2 py-1 rounded bg-white border text-gray-800' : 'px-2 py-1 rounded bg-gray-200 text-gray-700'
}
</script>

<style scoped>
</style>


