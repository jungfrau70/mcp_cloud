<template>
  <div class="space-y-3">
    <div class="flex items-center space-x-2">
      <input v-model="query" @keyup.enter="search" type="text" placeholder="파일/내용 검색" class="flex-1 px-2 py-1 border rounded" />
      <button @click="search" :disabled="loading" class="px-3 py-1 text-sm bg-blue-600 text-white rounded disabled:opacity-50">검색</button>
      <button v-if="searched" @click="reset" class="px-2 py-1 text-xs bg-gray-200 rounded">초기화</button>
    </div>
    <div v-if="loading" class="text-xs text-gray-500">검색 중...</div>
    <div v-else-if="searched" class="border rounded divide-y max-h-72 overflow-auto bg-white">
      <div v-if="!results.length" class="p-3 text-xs text-gray-500">결과 없음</div>
      <div v-for="r in results" :key="r.id + r.path" class="p-2 hover:bg-blue-50 cursor-pointer" @click="open(r)">
        <div class="text-xs font-medium" v-html="r.highlighted_title || r.title" />
        <div class="text-[10px] text-gray-500">{{ r.path }}</div>
        <div class="text-[11px] text-gray-600" v-html="r.highlighted_content || (r.content ? r.content.slice(0,100)+'…' : '')" />
      </div>
    </div>
  </div>
</template>
<script setup lang="ts">
import { ref } from 'vue'
const emit = defineEmits(['open'])
const props = defineProps<{ apiBase: string; apiKey: string }>()
const query = ref('')
const loading = ref(false)
const searched = ref(false)
const results = ref<any[]>([])
async function search(){
  try{ if(typeof window!=='undefined') localStorage.setItem('kb_search_query', query.value) }catch{}
  if(!query.value.trim()) return
  loading.value = true
  searched.value = true
  results.value = []
  try {
    const resp = await fetch(`${props.apiBase}/api/v1/knowledge/search-enhanced`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json', 'X-API-Key': props.apiKey },
      body: JSON.stringify({ query: query.value, category: null, limit: 20, search_type: 'both' })
    })
    if(resp.ok){
      const data = await resp.json();
      results.value = data.results || []
    }
  } finally { loading.value = false }
}
// Restore last search query on mount
try{
  if(typeof window!=='undefined'){
    const saved = localStorage.getItem('kb_search_query')
    if(saved){ query.value = saved }
  }
}catch{}
function reset(){ query.value=''; searched.value=false; results.value=[] }
function open(r: any){ if((r as any).path) emit('open', (r as any).path) }
</script>
