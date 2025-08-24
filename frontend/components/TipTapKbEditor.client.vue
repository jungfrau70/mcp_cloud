<template>
  <div class="h-full flex flex-col bg-white">
    <div class="border-b p-2 flex items-center gap-2 text-sm">
      <button @click="save" class="px-2 py-1 rounded bg-indigo-600 text-white" :disabled="saving">저장</button>
      <button @click="cancel" class="px-2 py-1 rounded bg-gray-200">취소</button>
      <span v-if="saving" class="text-gray-500">저장 중…</span>
      <div class="flex-1"></div>
    </div>
    <div class="flex-1 overflow-auto p-3">
      <client-only>
        <TiptapEditor v-model="html" />
      </client-only>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, onBeforeUnmount } from 'vue'
import { marked } from 'marked'
import Turndown from 'turndown'
import { useKbApi } from '~/composables/useKbApi'
import { useToastStore } from '~/stores/toast'

const props = defineProps({ path: String, content: String })
const api = useKbApi()
const toast = useToastStore()
const saving = ref(false)
const html = ref('')
const turndown = new Turndown()

async function save(){
  try{
    saving.value = true
    const markdown = turndown.turndown(html.value || '')
    await api.save(props.path || '', markdown, 'Edit via TipTap')
    toast.push('success','저장 완료')
    // go back to content view
    try{ window.dispatchEvent(new CustomEvent('kb:mode', { detail:{ to:'view' } })) }catch{}
  } catch(e){ toast.push('error','저장 실패') } finally{ saving.value = false }
}
function cancel(){ try{ window.dispatchEvent(new CustomEvent('kb:mode', { detail:{ to:'view' } })) }catch{} }

function onKey(e){
  if((e.ctrlKey || e.metaKey) && e.key.toLowerCase()==='s'){
    e.preventDefault(); void save()
  }
}

onMounted(()=>{
  html.value = marked.parse(props.content || '')
  try{ window.addEventListener('keydown', onKey) }catch{}
})
onBeforeUnmount(()=>{ try{ window.removeEventListener('keydown', onKey) }catch{} })
</script>

<style scoped>
</style>


