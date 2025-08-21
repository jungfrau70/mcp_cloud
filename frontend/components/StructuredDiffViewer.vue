<template>
  <div class="space-y-4">
    <div class="flex items-center space-x-2 text-sm">
      <label>보기 모드:</label>
      <select v-model="mode" class="border rounded px-2 py-1 text-sm">
        <option value="unified">Unified</option>
        <option value="side">Side-by-Side</option>
      </select>
    </div>
    <div v-if="loading" class="text-sm text-gray-500">로딩 중...</div>
    <div v-else>
      <template v-if="mode==='unified'">
        <pre class="text-xs bg-gray-900 text-gray-100 p-3 overflow-auto" v-for="h in hunks" :key="h.header">
@@ {{ h.header }}
<template v-for="line in h.lines" :key="line.__key">
<span :class="lineClass(line)">
<span class="inline-block w-6 text-right pr-1 text-gray-500">{{ line.old_line || '' }}</span>
<span class="inline-block w-6 text-right pr-1 text-gray-500">{{ line.new_line || '' }}</span>
{{ linePrefix(line) }}{{ line.text }}
</span>
</template>
        </pre>
      </template>
      <template v-else>
        <div v-for="h in hunks" :key="h.header" class="border rounded mb-4">
          <div class="bg-gray-100 text-xs px-2 py-1 font-mono">{{ h.header }}</div>
          <table class="w-full text-xs font-mono">
            <tbody>
              <tr v-for="row in sideRows(h)" :key="row.key" :class="row.type==='add' ? 'bg-green-50' : row.type==='del' ? 'bg-red-50' : ''">
                <td class="w-10 text-right pr-1 text-gray-500 align-top">{{ row.old_line || '' }}</td>
                <td class="w-1 align-top">{{ row.type==='del' ? '-' : '' }}</td>
                <td class="w-1/2 align-top whitespace-pre-wrap">{{ row.old_text || '' }}</td>
                <td class="w-10 text-right pr-1 text-gray-500 align-top">{{ row.new_line || '' }}</td>
                <td class="w-1 align-top">{{ row.type==='add' ? '+' : '' }}</td>
                <td class="w-1/2 align-top whitespace-pre-wrap">{{ row.new_text || '' }}</td>
              </tr>
            </tbody>
          </table>
        </div>
      </template>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, watch } from 'vue'
import { useKbApi, type KbStructuredDiff, type KbStructuredDiffHunk, type KbStructuredDiffLine } from '../composables/useKbApi'

interface ViewLine extends KbStructuredDiffLine { __key?: string }
interface ViewHunk extends KbStructuredDiffHunk { lines: ViewLine[] }
interface SideRow { key: string; type: string; old_line: number|null; new_line: number|null; old_text?: string; new_text?: string }

const props = defineProps<{ path: string; v1: number; v2: number }>()
const api = useKbApi()
const hunks = ref<ViewHunk[]>([])
const loading = ref(false)
const mode = ref<'unified'|'side'>('unified')

async function load(): Promise<void>{
  loading.value = true
  try {
    const data: KbStructuredDiff = await api.structuredDiff(props.path, props.v1, props.v2)
    hunks.value = (data.hunks||[] as KbStructuredDiffHunk[]).map((h: KbStructuredDiffHunk) => ({
      ...h,
      lines: (h.lines as KbStructuredDiffLine[]).map((l: KbStructuredDiffLine, i: number)=> ({...l, __key: h.header+'-'+i}))
    })) as ViewHunk[]
  } finally {
    loading.value = false
  }
}

watch(()=>[props.path, props.v1, props.v2], () => { void load() }, { immediate: true })

function lineClass(line: ViewLine): string {
  if(line.type==='add') return 'text-green-300'
  if(line.type==='del') return 'text-red-300'
  return 'text-gray-200'
}
function linePrefix(line: ViewLine): string {
  if(line.type==='add') return '+'
  if(line.type==='del') return '-'
  return ' '
}

// Side-by-side row assembly: naive pairing with simple queue logic
function sideRows(h: ViewHunk): SideRow[] {
  const rows: SideRow[] = []
  let adds: ViewLine[] = []
  let dels: ViewLine[] = []
  const pushPair = (d?: ViewLine, a?: ViewLine) => {
    if(d && a){
      rows.push({ key: h.header+'-pair-'+rows.length, type: 'change', old_line: d.old_line, new_line: a.new_line, old_text: d.text, new_text: a.text })
    } else if(d){
      rows.push({ key: h.header+'-pair-'+rows.length, type: 'del', old_line: d.old_line, new_line: null, old_text: d.text, new_text: '' })
    } else if(a){
      rows.push({ key: h.header+'-pair-'+rows.length, type: 'add', old_line: null, new_line: a.new_line, old_text: '', new_text: a.text })
    }
  }
  const flush = () => {
    const n = Math.max(dels.length, adds.length)
    for(let i=0;i<n;i++) pushPair(dels[i], adds[i])
    dels = []; adds = []
  }
  for(const ln of h.lines){
    if(ln.type==='context'){
      flush()
      rows.push({ key: h.header+'-ctx-'+rows.length, type: 'context', old_line: ln.old_line, new_line: ln.new_line, old_text: ln.text, new_text: ln.text })
    } else if(ln.type==='del') {
      dels.push(ln)
    } else if(ln.type==='add') {
      adds.push(ln)
    } else if(ln.type==='change') {
      flush()
      rows.push({ key: h.header+'-chg-'+rows.length, type: 'change', old_line: ln.old_line, new_line: ln.new_line, old_text: (ln as any).old_text || ln.text, new_text: (ln as any).new_text || ln.text })
    }
  }
  flush()
  return rows
}
</script>

<style scoped>
pre { line-height: 1.2; }
</style>
