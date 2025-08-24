<template>
  <div class="w-72 border-l bg-gray-50 flex flex-col min-h-0">
    <div class="p-2 font-semibold text-xs tracking-wide text-gray-700 border-b flex items-center gap-2">
      <button @click="active='outline'; if(!outline.length) refreshOutline()" :class="tabClass('outline')">Outline</button>
      <button @click="active='versions'; if(!versions.length) loadVersions()" :class="tabClass('versions')">Versions</button>
      <button @click="active='diff'; if(!versions.length) loadVersions()" :class="tabClass('diff')">Diff</button>
      <div class="ml-auto"></div>
      <button v-if="active==='outline'" @click="refreshOutline" class="text-[10px] px-1 py-0.5 bg-white border rounded" :disabled="outlineLoading">↻</button>
      <button v-if="active!=='outline'" @click="loadVersions" class="text-[10px] px-1 py-0.5 bg-white border rounded" :disabled="versionsLoading">↻</button>
    </div>
    <div class="flex-1 overflow-auto text-sm">
      <!-- Outline -->
      <div v-if="active==='outline'" class="p-2">
        <ul>
          <li v-for="item in outline" :key="item.line">
            <button class="block w-full text-left px-2 py-1 hover:bg-indigo-50 rounded" :class="'pl-' + (item.level * 2)" @click="$emit('goto-line', item.line)">
              <span :class="{'font-semibold': item.level === 1}">#{{ item.level }} {{ item.text }}</span>
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
import { ref, computed, watch } from 'vue'
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
async function refreshOutline(){
  if(!props.content){ outline.value = []; return }
  outlineLoading.value = true
  try{ const data = await api.outline(props.content); outline.value = data.outline || [] } finally { outlineLoading.value = false }
}
watch(() => props.content, () => { if(active.value==='outline') refreshOutline() })

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


