<template>
  <div class="h-full flex flex-col bg-white">
    <div class="border-b p-2 flex items-center gap-2 text-sm">
      <button @click="save" class="px-2 py-1 rounded bg-indigo-600 text-white" :disabled="saving">저장</button>
      <button @click="cancel" class="px-2 py-1 rounded bg-gray-200">취소</button>
      <span v-if="saving" class="text-gray-500">저장 중…</span>
      <div class="flex-1"></div>
    </div>
    <div class="flex-1 overflow-auto p-3">
      <div class="mb-2 flex flex-wrap items-center gap-2 text-sm">
        <button class="px-2 py-1 border rounded" @click="cmd('toggleBold')"><b>B</b></button>
        <button class="px-2 py-1 border rounded italic" @click="cmd('toggleItalic')">I</button>
        <button class="px-2 py-1 border rounded" @click="cmd('toggleStrike')">S</button>
        <button class="px-2 py-1 border rounded" @click="cmd('toggleBulletList')">• List</button>
        <button class="px-2 py-1 border rounded" @click="cmd('toggleOrderedList')">1. List</button>
        <button class="px-2 py-1 border rounded" @click="cmd('setParagraph')">P</button>
        <button class="px-2 py-1 border rounded" @click="cmd('toggleHeading',{ level: 2 })">H2</button>
        <button class="px-2 py-1 border rounded" @click="cmd('toggleCodeBlock')">Code</button>
      </div>
      <EditorContent :editor="editor" class="tiptap-editor" />
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, onBeforeUnmount, watch } from 'vue'
import { marked } from 'marked'
import Turndown from 'turndown'
import { Editor, EditorContent } from '@tiptap/vue-3'
import StarterKit from '@tiptap/starter-kit'
import { useDocStore } from '~/stores/doc'
import { useKbApi } from '~/composables/useKbApi'
import { useToastStore } from '~/stores/toast'

const props = defineProps({ path: String, content: String })
const api = useKbApi()
const toast = useToastStore()
const docStore = useDocStore()
const saving = ref(false)
const html = ref('')
const editor = ref<Editor|null>(null)
const turndown = new Turndown()
let selfUpdating = false

async function save(){
  try{
    saving.value = true
    const markdown = turndown.turndown(html.value || '')
    await api.saveItem(props.path || '', markdown, 'Edit via TipTap')
    try{ docStore.update(markdown) }catch{}
    toast.push('success','저장 완료')
    // go back to content view
    try{ window.dispatchEvent(new CustomEvent('kb:mode', { detail:{ to:'view' } })) }catch{}
  } catch(e){ toast.push('error','저장 실패') } finally{ saving.value = false }
}
function cancel(){ try{ window.dispatchEvent(new CustomEvent('kb:mode', { detail:{ to:'view' } })) }catch{} }

function onKey(e: KeyboardEvent){
  if((e.ctrlKey || e.metaKey) && e.key.toLowerCase()==='s'){
    e.preventDefault(); void save()
  }
}

onMounted(()=>{
  html.value = marked.parse(props.content || '')
  editor.value = new Editor({
    content: html.value,
    extensions: [StarterKit],
    onUpdate({ editor }){
      html.value = editor.getHTML()
      if(selfUpdating) return
      // 실시간 동기화: Markdown으로 변환해 중앙 스토어 갱신 → 탭 전환 시 내용 공유
      try{ const md = turndown.turndown(html.value || ''); docStore.update(md) }catch{}
    }
  })
  // 콘텐츠가 비동기로 도착할 때 에디터에 반영
  // 콘텐츠 또는 경로 변경 시 에디터에 반영 (탭 역방향 전환 포함)
  watch(() => [props.path, props.content], async ([p, c]) => {
    // 보장: 선택 파일이 로드된 이후 업데이트
    try { await docStore.whenLoaded(p || docStore.path) } catch {}
    const next = marked.parse((c ?? docStore.content) || '')
    html.value = next
    // TipTap은 내부 상태가 있을 수 있으므로 약간 지연 후 주입 (탭 스위칭 시 초기화 타이밍 보정)
    setTimeout(() => { try{ selfUpdating = true; editor.value?.commands?.setContent(next, false) }catch{} finally{ selfUpdating = false } }, 0)
  }, { immediate: true })
  try{ window.addEventListener('keydown', onKey) }catch{}
})
onBeforeUnmount(()=>{ try{ window.removeEventListener('keydown', onKey) }catch{} editor.value?.destroy?.() })

function cmd(name: string, args: any = {}){
  try{ (editor.value as any)?.chain().focus()?.[name](args).run() }catch{}
}
</script>

<style scoped>
</style>


