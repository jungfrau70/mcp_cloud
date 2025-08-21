<template>
  <div class="h-full flex flex-col">
    <div class="flex items-center gap-2 p-2 border-b bg-white text-sm">
      <select v-model.number="leftVersion" class="border rounded px-2 py-1 text-xs">
        <option v-for="v in versions" :key="v.id" :value="v.version_no">v{{ v.version_no }}</option>
      </select>
      <span class="text-gray-500">→</span>
      <select v-model.number="rightVersion" class="border rounded px-2 py-1 text-xs">
        <option v-for="v in versions" :key="'r'+v.id" :value="v.version_no">v{{ v.version_no }}</option>
      </select>
      <button @click="loadDiff" :disabled="loading || !leftVersion || !rightVersion" class="px-2 py-1 bg-indigo-600 text-white rounded text-xs hover:bg-indigo-500 disabled:opacity-50">Diff</button>
      <span v-if="loading" class="text-xs text-gray-500">Loading...</span>
      <button v-if="displayHunks.length" @click="copyPatch" class="px-2 py-1 text-xs border rounded hover:bg-gray-100">Copy Patch</button>
      <select v-model="viewMode" class="border rounded px-1 py-1 text-[11px]">
        <option value="unified">Unified</option>
        <option value="side">Side-by-Side</option>
      </select>
      <label class="flex items-center gap-1 text-[11px] cursor-pointer select-none">
        <input type="checkbox" v-model="showLineNumbers" class="accent-indigo-600" /> LN
      </label>
      <div class="flex-1"></div>
      <button @click="$emit('close')" class="px-2 py-1 text-xs border rounded hover:bg-gray-100">Close</button>
    </div>
    <div class="flex-1 overflow-auto font-mono text-[12px] leading-snug bg-gray-50 p-3" v-if="viewMode==='unified'">
      <template v-if="displayHunks.length">
        <div v-for="(h,i) in displayHunks" :key="'u'+i" class="mb-4">
          <div class="bg-gray-200 text-gray-700 px-1 py-0.5 text-xs">{{ h.header }}</div>
          <pre class="whitespace-pre-wrap"><span v-for="(line,li) in h.lines" :key="li" :class="lineClassUnified(line)"><span class="inline-block w-10 pr-2 text-right text-gray-400 select-none" v-if="showLineNumbers">{{ line.old_line ?? line.new_line ?? '' }}</span><template v-if="line.type==='change'">{{ unifiedPrefix(line) }}<span v-html="inlineDiff(line.old_text||line.text, line.new_text||line.text).newHtml"></span></template><template v-else>{{ unifiedPrefix(line) }}{{ line.text }}</template>
</span></pre>
        </div>
      </template>
      <div v-else class="text-gray-400 text-xs">No diff</div>
    </div>
    <div v-else class="flex-1 overflow-auto bg-white text-[12px]">
      <template v-if="displayHunks.length">
        <div v-for="(h,i) in displayHunks" :key="'s'+i" class="mb-6 border rounded">
          <div class="bg-gray-100 text-gray-700 px-2 py-1 text-xs font-mono">{{ h.header }}</div>
          <table class="w-full text-[11px] font-mono">
            <tbody>
              <tr v-for="row in sideRows(h)" :key="row.key" :class="rowClass(row)">
                <td class="w-12 text-right pr-2 text-gray-400 align-top" v-if="showLineNumbers">{{ row.old_line || '' }}</td>
                <td class="w-1 align-top text-red-600" v-if="showLineNumbers">{{ row.type==='del' || row.type==='change' ? '-' : '' }}</td>
                <td class="align-top whitespace-pre-wrap w-1/2 px-1"><span v-if="row.type==='change'" v-html="inlineDiff(row.old_text||'', row.new_text||'').oldHtml"></span><span v-else>{{ row.old_text || '' }}</span></td>
                <td class="w-12 text-right pr-2 text-gray-400 align-top" v-if="showLineNumbers">{{ row.new_line || '' }}</td>
                <td class="w-1 align-top text-green-600" v-if="showLineNumbers">{{ row.type==='add' || row.type==='change' ? '+' : '' }}</td>
                <td class="align-top whitespace-pre-wrap w-1/2 px-1"><span v-if="row.type==='change'" v-html="inlineDiff(row.old_text||'', row.new_text||'').newHtml"></span><span v-else>{{ row.new_text || '' }}</span></td>
              </tr>
            </tbody>
          </table>
        </div>
      </template>
      <div v-else class="text-gray-400 text-xs p-4">No diff</div>
    </div>
  </div>
</template>
<script setup>
import { ref, watch, onMounted, computed } from 'vue'
import { useKbApi } from '~/composables/useKbApi'

const props = defineProps({
  path: { type: String, required: true },
  versions: { type: Array, required: true },
  defaultLeft: { type: Number, required: false },
  defaultRight: { type: Number, required: false }
})

const leftVersion = ref(props.defaultLeft || (props.versions[1]?.version_no || props.versions[0]?.version_no))
const rightVersion = ref(props.defaultRight || (props.versions[0]?.version_no))

const structured = ref([]) // structured hunks (lines: {type, old_line, new_line, text})
const loading = ref(false)
const showLineNumbers = ref(true)
const viewMode = ref('unified')
const displayHunks = computed(() => structured.value)

function lineClassUnified(line){
  if(line.type==='add') return 'text-green-700'
  if(line.type==='del') return 'text-red-600'
  if(line.type==='context') return 'text-gray-700'
  return 'text-gray-700'
}
function unifiedPrefix(line){
  if(line.type==='add') return '+'
  if(line.type==='del') return '-'
  return ' '
}

async function loadDiff(){
  if(!leftVersion.value || !rightVersion.value || leftVersion.value === rightVersion.value) return
  loading.value = true
  try {
    const api = useKbApi()
    try {
      const data = await api.structuredDiff(props.path, leftVersion.value, rightVersion.value)
      structured.value = (data.hunks || []).map(h => ({...h, lines: postProcessChangeLines(h.lines) }))
    } catch(err){
      // fallback to unified diff API converting result
      const uni = await api.diff(props.path, leftVersion.value, rightVersion.value)
      structured.value = buildStructuredFromUnified(uni)
    }
  } catch(e){
    structured.value = []
  } finally {
    loading.value = false
  }
}

watch(() => [leftVersion.value, rightVersion.value], () => { structured.value = [] })

function copyPatch(){
  const text = structured.value.map(h => {
    const body = h.lines.map(l => (l.type==='add'?'+':l.type==='del'?'-':' ') + l.text).join('\n')
    return h.header + '\n' + body
  }).join('\n\n')
  navigator.clipboard?.writeText(text)
}

function sideRows(h){
  const rows = []
  let adds = []
  let dels = []
  for(const ln of h.lines){
    if(ln.type==='context'){
      while(dels.length || adds.length){
        const d = dels.shift() || { old_line:null, text:'', type:'del' }
        const a = adds.shift() || { new_line:null, text:'', type:'add' }
        rows.push({ key: h.header+'-'+rows.length, type: (d.type==='del' && a.type==='add') ? 'change' : (d.type==='del' ? 'del' : 'add'), old_line: d.old_line, old_text: d.text, new_line: a.new_line, new_text: a.text })
      }
      rows.push({ key: h.header+'-ctx-'+rows.length, type:'context', old_line: ln.old_line, old_text: ln.text, new_line: ln.new_line, new_text: ln.text })
    } else if(ln.type==='del') {
      dels.push(ln)
    } else if(ln.type==='add') {
      adds.push(ln)
    }
  }
  while(dels.length || adds.length){
    const d = dels.shift() || { old_line:null, text:'', type:'del' }
    const a = adds.shift() || { new_line:null, text:'', type:'add' }
    rows.push({ key: h.header+'-'+rows.length, type: (d.type==='del' && a.type==='add') ? 'change' : (d.type==='del' ? 'del' : 'add'), old_line: d.old_line, old_text: d.text, new_line: a.new_line, new_text: a.text })
  }
  return rows
}
function rowClass(row){
  if(row.type==='add') return 'bg-green-50'
  if(row.type==='del') return 'bg-red-50'
  if(row.type==='change') return 'bg-yellow-50'
  return ''
}

// --- Inline token diff (word-level) ---
function tokenize(str){
  if(!str) return []
  return str.split(/(\s+)/) // keep whitespace tokens
}
function inlineDiff(oldText, newText){
  if(oldText===newText) return { oldHtml: escapeHtml(oldText), newHtml: escapeHtml(newText) }
  if((oldText.length + newText.length) > 800) return { oldHtml: escapeHtml(oldText), newHtml: escapeHtml(newText) }
  const a = tokenize(oldText)
  const b = tokenize(newText)
  if(a.length + b.length > 300) return { oldHtml: escapeHtml(oldText), newHtml: escapeHtml(newText) }
  const m = a.length, n = b.length
  const dp = Array.from({length:m+1}, () => new Array(n+1).fill(0))
  for(let i=1;i<=m;i++){
    for(let j=1;j<=n;j++){
      if(a[i-1] === b[j-1]) dp[i][j] = dp[i-1][j-1] + 1
      else dp[i][j] = dp[i-1][j] >= dp[i][j-1] ? dp[i-1][j] : dp[i][j-1]
    }
  }
  let i=m, j=n
  const chunks = []
  while(i>0 || j>0){
    if(i>0 && j>0 && a[i-1] === b[j-1]){ chunks.push({type:'eq', text:a[i-1]}); i--; j--; }
    else if(j>0 && (i===0 || dp[i][j-1] >= dp[i-1][j])){ chunks.push({type:'add', text:b[j-1]}); j--; }
    else if(i>0){ chunks.push({type:'del', text:a[i-1]}); i--; }
  }
  chunks.reverse()
  let oldHtml='', newHtml=''
  for(const c of chunks){
    if(c.type==='eq') { oldHtml+=escapeHtml(c.text); newHtml+=escapeHtml(c.text) }
    else if(c.type==='del'){ oldHtml+=`<span class="bg-red-200/70 line-through">${escapeHtml(c.text)}</span>` }
    else if(c.type==='add'){ newHtml+=`<span class="bg-green-200/70">${escapeHtml(c.text)}</span>` }
  }
  return { oldHtml, newHtml }
}
function escapeHtml(s){
  return (s||'').replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;')
}

function postProcessChangeLines(lines){
  const out = []
  let dels = []
  let adds = []
  const flush = () => {
    if(!dels.length && !adds.length) return
    const maxLen = Math.max(dels.length, adds.length)
    for(let i=0;i<maxLen;i++){
      const d = dels[i]
      const a = adds[i]
      if(d && a){
        out.push({ type:'change', old_line: d.old_line, new_line: a.new_line, old_text: d.text, new_text: a.text, text: a.text })
      } else if(d){
        out.push(d)
      } else if(a){
        out.push(a)
      }
    }
    dels = []; adds = []
  }
  for(const ln of lines){
    if(ln.type==='del'){ dels.push(ln); continue }
    if(ln.type==='add'){ adds.push(ln); continue }
    flush();
    out.push(ln)
  }
  flush()
  return out
}

function buildStructuredFromUnified(unified){
  if(!unified || !Array.isArray(unified.hunks)) return []
  return unified.hunks.map(h => {
    const lines = []
    let oldBase=0, newBase=0, oldOff=0, newOff=0
    const m = /@@ -(\d+),(\d+) \+(\d+),(\d+) @@/.exec(h.header || '')
    if(m){ oldBase=parseInt(m[1],10); newBase=parseInt(m[3],10) }
    for(const raw of h.lines){
      const tag = raw[0]
      const text = raw.slice(1)
      if(tag===' '){ oldOff++; newOff++; lines.push({ type:'context', old_line: oldBase+oldOff-1, new_line: newBase+newOff-1, text }) }
      else if(tag==='+'){ newOff++; lines.push({ type:'add', old_line:null, new_line:newBase+newOff-1, text }) }
      else if(tag==='-'){ oldOff++; lines.push({ type:'del', old_line:oldBase+oldOff-1, new_line:null, text }) }
    }
    return { header: h.header, lines: postProcessChangeLines(lines) }
  })
}

onMounted(() => {
  // auto-load initial diff if both versions resolved
  if(leftVersion.value && rightVersion.value && leftVersion.value !== rightVersion.value){
    loadDiff()
  }
})

</script>
<style scoped>
</style>
