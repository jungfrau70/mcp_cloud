<template>
  <div class="h-full flex flex-col bg-white">
    <KbToolbar :saving="saving" save-label="저장" cancel-label="취소" delete-label="삭제" saving-text="저장 중…" aria-label="WYSIWYG toolbar" save-aria-label="문서 저장 (Ctrl+S)" cancel-aria-label="편집 취소" delete-aria-label="현재 문서 삭제" @save="save" @cancel="cancel" @delete="deleteCurrent">
      <input v-model="saveMessage" placeholder="commit message" class="px-2 py-1 text-xs border rounded w-48 focus:outline-none focus:ring" />
      <button class="px-2 py-1 border rounded" aria-label="굵게" @click="cmd('toggleBold')"><b>B</b></button>
      <button class="px-2 py-1 border rounded italic" aria-label="기울임" @click="cmd('toggleItalic')">I</button>
      <button class="px-2 py-1 border rounded" aria-label="밑줄" @click="cmd('toggleUnderline')">U</button>
      <button class="px-2 py-1 border rounded" aria-label="취소선" @click="cmd('toggleStrike')">S</button>
      <button class="px-2 py-1 border rounded" aria-label="인라인 코드" @click="cmd('toggleCode')">`code`</button>
      <button class="px-2 py-1 border rounded" aria-label="서식 지우기" @click="clearFormatting">Clear</button>
      <div class="w-px h-5 bg-gray-200 mx-1"></div>
      <button class="px-2 py-1 border rounded" aria-label="문단" @click="cmd('setParagraph')">P</button>
      <button class="px-2 py-1 border rounded" aria-label="제목 H1" @click="cmd('toggleHeading',{ level: 1 })">H1</button>
      <button class="px-2 py-1 border rounded" aria-label="제목 H2" @click="cmd('toggleHeading',{ level: 2 })">H2</button>
      <button class="px-2 py-1 border rounded" aria-label="제목 H3" @click="cmd('toggleHeading',{ level: 3 })">H3</button>
      <button class="px-2 py-1 border rounded" aria-label="제목 H4" @click="cmd('toggleHeading',{ level: 4 })">H4</button>
      <button class="px-2 py-1 border rounded" aria-label="제목 H5" @click="cmd('toggleHeading',{ level: 5 })">H5</button>
      <button class="px-2 py-1 border rounded" aria-label="제목 H6" @click="cmd('toggleHeading',{ level: 6 })">H6</button>
      <button class="px-2 py-1 border rounded" aria-label="인용문" @click="cmd('toggleBlockquote')">❝ ❞</button>
      <button class="px-2 py-1 border rounded" aria-label="수평선" @click="cmd('setHorizontalRule')">HR</button>
      <div class="w-px h-5 bg-gray-200 mx-1"></div>
      <button class="px-2 py-1 border rounded" aria-label="왼쪽 정렬" @click="align('left')">⟸</button>
      <button class="px-2 py-1 border rounded" aria-label="가운데 정렬" @click="align('center')">⇔</button>
      <button class="px-2 py-1 border rounded" aria-label="오른쪽 정렬" @click="align('right')">⟹</button>
      <button class="px-2 py-1 border rounded" aria-label="양쪽 정렬" @click="align('justify')">⟷</button>
      <div class="w-px h-5 bg-gray-200 mx-1"></div>
      <button class="px-2 py-1 border rounded" aria-label="불릿 리스트" @click="cmd('toggleBulletList')">• List</button>
      <button class="px-2 py-1 border rounded" aria-label="번호 리스트" @click="cmd('toggleOrderedList')">1. List</button>
      <button class="px-2 py-1 border rounded" aria-label="태스크 리스트" @click="cmd('toggleTaskList')">☐ Task</button>
      <button class="px-2 py-1 border rounded" aria-label="체크 토글" @click="toggleTaskChecked">☑︎</button>
      <button class="px-2 py-1 border rounded" aria-label="목록 들여쓰기" @click="indentList">→</button>
      <button class="px-2 py-1 border rounded" aria-label="목록 내어쓰기" @click="outdentList">←</button>
      <div class="w-px h-5 bg-gray-200 mx-1"></div>
      <button class="px-2 py-1 border rounded" aria-label="코드 블록" @click="cmd('toggleCodeBlock')">Code</button>
      <button class="px-2 py-1 border rounded" aria-label="코드 언어 설정" @click="setCodeLang">Lang</button>
      <button class="px-2 py-1 border rounded" aria-label="하이퍼링크" @click="insertLink">Link</button>
      <button class="px-2 py-1 border rounded" aria-label="링크 해제" @click="unlink">Unlink</button>
      <button class="px-2 py-1 border rounded" aria-label="표 삽입" @click="insertTable">Table</button>
      <div class="flex items-center gap-1">
        <button class="px-2 py-1 border rounded" aria-label="열 추가" @click="tableCmd('addColumnAfter')">+Col</button>
        <button class="px-2 py-1 border rounded" aria-label="행 추가" @click="tableCmd('addRowAfter')">+Row</button>
        <button class="px-2 py-1 border rounded" aria-label="열 삭제" @click="tableCmd('deleteColumn')">-Col</button>
        <button class="px-2 py-1 border rounded" aria-label="행 삭제" @click="tableCmd('deleteRow')">-Row</button>
        <button class="px-2 py-1 border rounded" aria-label="셀 병합" @click="tableCmd('mergeCells')">Merge</button>
        <button class="px-2 py-1 border rounded" aria-label="셀 분할" @click="tableCmd('splitCell')">Split</button>
        <button class="px-2 py-1 border rounded" aria-label="표 삭제" @click="tableCmd('deleteTable')">DelTbl</button>
      </div>
      <label class="px-2 py-1 border rounded bg-white cursor-pointer" aria-label="이미지 업로드">
        Image<input ref="imagePicker" type="file" accept="image/*" class="hidden" @change="onPickImage" />
      </label>
      <div class="w-px h-5 bg-gray-200 mx-1"></div>
      <button class="px-2 py-1 border rounded" aria-label="텍스트 색상" @click="toggleColorPalette">Color</button>
      <div v-if="showColorPalette" class="flex items-center gap-1">
        <button v-for="c in colorPreset" :key="'c'+c" class="w-5 h-5 border rounded" :style="{ backgroundColor: c }" :title="c" @click="setColorPreset(c)"></button>
      </div>
      <button class="px-2 py-1 border rounded" aria-label="하이라이트" @click="toggleHighlightPalette">Mark</button>
      <div v-if="showHighlightPalette" class="flex items-center gap-1">
        <button v-for="c in highlightPreset" :key="'h'+c" class="w-5 h-5 border rounded" :style="{ backgroundColor: c }" :title="c" @click="setHighlightPreset(c)"></button>
    </div>
      <button class="px-2 py-1 border rounded" aria-label="색상 초기화" @click="clearColor">NoColor</button>
      <div class="w-px h-5 bg-gray-200 mx-1"></div>
      <button class="px-2 py-1 border rounded" aria-label="실행 취소" @click="cmd('undo')">Undo</button>
      <button class="px-2 py-1 border rounded" aria-label="다시 실행" @click="cmd('redo')">Redo</button>
      <button class="px-2 py-1 rounded bg-indigo-50 hover:bg-indigo-100 text-indigo-700" aria-label="AI 변환" @click="openAiMenu">AI</button>
    </KbToolbar>
    <div class="flex-1 overflow-auto p-3">
      <div class="h-full grid grid-cols-[18rem_1fr] min-h-0">
        <KbSidePanel v-if="path" :key="`${path}:${(currentMarkdown||'').length}`" :path="path" :content="currentMarkdown" />
        <div class="min-h-0 h-full overflow-auto">
          <EditorContent v-if="editor" :editor="editor as unknown as Editor" class="tiptap-editor prose max-w-none h-full" />
          <div v-else class="p-4 text-sm text-gray-500">에디터 로딩 중…</div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, onBeforeUnmount, watch } from 'vue'
import { marked } from 'marked'
import Turndown from 'turndown'
import { Editor, EditorContent } from '@tiptap/vue-3'
import StarterKit from '@tiptap/starter-kit'
import Underline from '@tiptap/extension-underline'
import TextAlign from '@tiptap/extension-text-align'
import Link from '@tiptap/extension-link'
import Image from '@tiptap/extension-image'
import { Table } from '@tiptap/extension-table'
import TableRow from '@tiptap/extension-table-row'
import TableHeader from '@tiptap/extension-table-header'
import TableCell from '@tiptap/extension-table-cell'
import TaskList from '@tiptap/extension-task-list'
import TaskItem from '@tiptap/extension-task-item'
import * as lowlight from 'lowlight'
import CodeBlockLowlight from '@tiptap/extension-code-block-lowlight'
import Placeholder from '@tiptap/extension-placeholder'
import Typography from '@tiptap/extension-typography'
import { TextStyle } from '@tiptap/extension-text-style'
import Color from '@tiptap/extension-color'
import Highlight from '@tiptap/extension-highlight'
import javascript from 'highlight.js/lib/languages/javascript'
import typescript from 'highlight.js/lib/languages/typescript'
import python from 'highlight.js/lib/languages/python'
import bash from 'highlight.js/lib/languages/bash'
import jsonLang from 'highlight.js/lib/languages/json'
import yamlLang from 'highlight.js/lib/languages/yaml'
import markdownLang from 'highlight.js/lib/languages/markdown'
import { useDocStore } from '../stores/doc'
import { resolveApiBase } from '../composables/useKbApi'
import { useKbApi } from '../composables/useKbApi'
import { useToastStore } from '../stores/toast'
import KbToolbar from './KbToolbar.vue'
import KbSidePanel from './KbSidePanel.vue'

const props = defineProps({ path: String, content: String })
const api = useKbApi()
const toast = useToastStore()
const docStore = useDocStore()
const saving = ref(false)
const html = ref('')
const editor = ref<Editor|null>(null)
const isEditorEmpty = ref(true)
const turndown = new Turndown()
let selfUpdating = false
const imagePicker = ref<HTMLInputElement|null>(null)
const currentMarkdown = ref('')
const saveMessage = ref('')
const initError = ref('')
const showColorPalette = ref(false)
const showHighlightPalette = ref(false)
const colorPreset = ['#000000','#e11d48','#ef4444','#f59e0b','#10b981','#06b6d4','#3b82f6','#8b5cf6','#ec4899']
const highlightPreset = ['#fff59d','#fde68a','#fca5a5','#bbf7d0','#bae6fd','#ddd6fe']

// simple debounce utility
function debounce(fn: (...args:any[])=>void, delay:number){
  let timer: any
  return (...args:any[]) => { clearTimeout(timer); timer = setTimeout(() => fn(...args), delay) }
}
const updateMarkdownDebounced = debounce((htmlStr: string) => {
  try{
    const md = turndown.turndown(htmlStr || '')
    currentMarkdown.value = md
    docStore.update(md)
  }catch{}
}, 150)

async function save(){
  try{
    saving.value = true
    const markdown = turndown.turndown(html.value || '')
    // 저장 경로 통일: docStore.save 경유로 충돌 처리 재사용
    try{ docStore.update(markdown) }catch{}
    const res = await docStore.save(saveMessage.value || 'Edit via TipTap')
    if(res?.conflict){ toast.push('warn','버전 충돌 발생: 병합 필요 (Markdown 탭에서 처리)') }
    try{ docStore.update(markdown) }catch{}
    toast.push('success','저장 완료')
    // go back to content view
    try{ window.dispatchEvent(new CustomEvent('kb:mode', { detail:{ to:'view' } })) }catch{}
  } catch(e){ toast.push('error','저장 실패') } finally{ saving.value = false }
}
function cancel(){ try{ window.dispatchEvent(new CustomEvent('kb:mode', { detail:{ to:'view' } })) }catch{} }

async function deleteCurrent(){
  try{
    if(!props.path){ return }
    const ok = window.confirm('이 문서를 휴지통으로 이동할까요?')
    if(!ok) return
    const p = props.path
    const ts = new Date().toISOString().replace(/[-:T.Z]/g,'').slice(0,14)
    const trashPath = `.trash/${ts}/${p}`
    await fetch(`${resolveApiBase()}/api/v1/knowledge-base/move`, { method:'POST', headers:{ 'Content-Type':'application/json','X-API-Key':'my_mcp_eagle_tiger' }, body: JSON.stringify({ path: p, new_path: trashPath }) })
    try{ window.dispatchEvent(new CustomEvent('kb:deleted', { detail:{ path: p, trashPath } })) }catch{}
  }catch{ alert('삭제 실패') }
}

function onKey(e: KeyboardEvent){
  if((e.ctrlKey || e.metaKey) && e.key.toLowerCase()==='s'){
    e.preventDefault(); void save()
  }
}

onMounted(async ()=>{
  html.value = marked.parse(props.content || '')
  // register lowlight languages (best-effort)
  try{ (lowlight as any).register?.('javascript', javascript) }catch{}
  try{ (lowlight as any).register?.('typescript', typescript) }catch{}
  try{ (lowlight as any).register?.('python', python) }catch{}
  try{ (lowlight as any).register?.('bash', bash) }catch{}
  try{ (lowlight as any).register?.('json', jsonLang) }catch{}
  try{ (lowlight as any).register?.('yaml', yamlLang) }catch{}
  try{ (lowlight as any).register?.('markdown', markdownLang) }catch{}

  async function initEditor(extensions: any[]){
  editor.value = new Editor({
    content: html.value,
      extensions,
      editorProps: {
        attributes: { class: 'outline-none focus:outline-none min-h-[600px] p-4' },
        handlePaste: (view, event) => {
          const dt = (event as ClipboardEvent).clipboardData
          if(!dt) return false
          const file = Array.from(dt.items).map(i=>i.getAsFile()).find(f=>f && f.type.startsWith('image/'))
          if(file){
            event.preventDefault()
            api.uploadAsset(file as File, 'assets')
              .then(({ path }) => { try{ (editor.value as any)?.chain().focus().setImage({ src: path }).run() }catch{} })
              .catch(() => { toast.push('error','이미지 업로드 실패') })
            return true
          }
          return false
        },
        handleDrop: (view, event) => {
          const dt = (event as DragEvent).dataTransfer
          if(!dt || !dt.files?.length) return false
          const file = Array.from(dt.files).find(f => f.type.startsWith('image/'))
          if(file){
            event.preventDefault()
            api.uploadAsset(file, 'assets')
              .then(({ path }) => { try{ (editor.value as any)?.chain().focus().setImage({ src: path }).run() }catch{} })
              .catch(() => { toast.push('error','이미지 업로드 실패') })
            return true
          }
          return false
        }
      },
    onUpdate({ editor }){
      html.value = editor.getHTML()
      if(selfUpdating) return
        const len = (html.value||'').length
        ;(updateMarkdownDebounced as any).delay = len > 20000 ? 400 : 150
        updateMarkdownDebounced(html.value || '')
        try{ isEditorEmpty.value = (editor as any)?.isEmpty?.() }catch{}
      },
      onCreate(){
        try{ currentMarkdown.value = turndown.turndown(html.value || '') }catch{}
        try{ isEditorEmpty.value = (editor.value as any)?.isEmpty?.() }catch{}
      }
    })
  }

  try{
    await initEditor([
      StarterKit.configure({ codeBlock: false }),
      Underline,
      TextAlign.configure({ types: ['heading','paragraph','taskItem'] }),
      Link.configure({ openOnClick: true, autolink: true, HTMLAttributes: { rel: 'noopener nofollow', target: '_blank' } }),
      Image.configure({ inline: false, allowBase64: false }),
      TextStyle,
      Color,
      Highlight,
      Table.configure({ resizable: true }),
      TableRow,
      TableHeader,
      TableCell,
      TaskList,
      TaskItem.configure({ nested: true }),
      CodeBlockLowlight.extend({
        addKeyboardShortcuts(){
          return { 'Mod-Alt-c': () => (this as any).editor.commands.toggleCodeBlock() }
        }
      }).configure({ lowlight }),
      Placeholder.configure({ placeholder: '여기에 내용을 입력하세요…' }),
      Typography
    ])
  } catch(e){
    try{ console.error('TipTap full init failed, fallback...', e); initError.value = 'fallback' }catch{}
    try{
      await initEditor([
        StarterKit,
        Placeholder.configure({ placeholder: '여기에 내용을 입력하세요…' })
      ])
    }catch(e2){ try{ console.error('TipTap fallback init failed', e2) }catch{} }
  }
  // tab focus event → focus editor
  try{
    window.addEventListener('kb:focus', (e:any)=>{
      if(e?.detail?.tab !== 'tiptap') return
      setTimeout(()=>{ try{ (editor.value as any)?.chain().focus().run() }catch{} }, 0)
    })
  }catch{}
  // 콘텐츠가 비동기로 도착할 때 에디터에 반영
  // 콘텐츠 또는 경로 변경 시 에디터에 반영 (탭 역방향 전환 포함)
  watch(() => [props.path, props.content], async ([p, c]) => {
    // 보장: 선택 파일이 로드된 이후 업데이트
    try { await docStore.whenLoaded(p || docStore.path) } catch {}
    const nextMd = (c ?? docStore.content) || ''
    // 편집기에서 발생한 변경이라면 재주입하지 않아 커서 점프를 방지
    if(nextMd === currentMarkdown.value){ return }
    const next = marked.parse(nextMd)
    html.value = next
    currentMarkdown.value = nextMd
    // TipTap은 내부 상태가 있을 수 있으므로 약간 지연 또는 idle 후 주입 (대용량 최적화)
    const setter = () => {
      try{
        selfUpdating = true
        editor.value?.commands?.setContent(next, false)
        // 강제 리프레시로 뷰 업데이트 보장
        try{ (editor.value as any)?.view?.dispatch?.((editor.value as any)?.state?.tr) }catch{}
      }catch{} finally{ selfUpdating = false }
    }
    if (typeof window !== 'undefined' && 'requestIdleCallback' in window && nextMd.length > 20000){
      ;(window as any).requestIdleCallback(() => setter(), { timeout: 200 })
    } else {
      // selection 업데이트 후에 content 교체하여 커서 점프 완화
      setTimeout(() => setter(), 16)
    }
  }, { immediate: true })
  try{ window.addEventListener('keydown', onKey) }catch{}
})
onBeforeUnmount(()=>{ try{ window.removeEventListener('keydown', onKey) }catch{} editor.value?.destroy?.() })

function cmd(name: string, args: any = {}){
  try{ (editor.value as any)?.chain().focus()?.[name](args).run() }catch{}
}

function align(dir: 'left'|'center'|'right'|'justify'){
  try{
    const m = (editor.value as any)?.chain().focus()
    if(dir==='left') m.setTextAlign('left').run()
    else if(dir==='center') m.setTextAlign('center').run()
    else if(dir==='right') m.setTextAlign('right').run()
    else m.setTextAlign('justify').run()
  }catch{}
}

function toggleTaskChecked(){
  try{
    // toggle between [ ] and [x] if selection is on a task item
    const api = (editor.value as any)
    if(!api) return
    const state = api.state
    const { $from } = state.selection
    const node = $from?.node($from.depth)
    if(node && node.type?.name === 'taskItem'){
      const checked = !!node?.attrs?.checked
      api.chain().focus().updateAttributes('taskItem', { checked: !checked }).run()
    } else {
      // if not on task, create a task list item
      api.chain().focus().toggleTaskList().run()
    }
  }catch{}
}

function insertTable(){
  try{ (editor.value as any)?.chain().focus().insertTable({ rows: 3, cols: 3, withHeaderRow: true }).run() }catch{}
}

function insertLink(){
  try{
    const url = window.prompt('링크 URL 입력 (빈칸=해제):')
    if(url === null) return
    if(url && !/^https?:\/\//i.test(url)){ alert('http(s):// 로 시작하는 유효한 URL을 입력하세요.'); return }
    const chain = (editor.value as any)?.chain().focus()
    if(!url){ chain.extendMarkRange('link').unsetLink().run(); return }
    chain.extendMarkRange('link').setLink({ href: url }).run()
  }catch{}
}

function unlink(){ try{ (editor.value as any)?.chain().focus().unsetLink().run() }catch{} }

function tableCmd(cmd: string){ try{ (editor.value as any)?.chain().focus()?.[cmd]().run() }catch{} }

function clearFormatting(){
  try{
    (editor.value as any)?.chain().focus()
      .unsetAllMarks()
      .clearNodes()
      .run()
  }catch{}
}

function indentList(){ try{ (editor.value as any)?.chain().focus().sinkListItem('listItem').run() }catch{} }
function outdentList(){ try{ (editor.value as any)?.chain().focus().liftListItem('listItem').run() }catch{} }

function pickColor(){
  try{
    const color = window.prompt('텍스트 색상 (예: #ff0000 또는 red):')
    if(!color) return
    ;(editor.value as any)?.chain().focus().setColor(color).run()
  }catch{}
}
function clearColor(){ try{ (editor.value as any)?.chain().focus().unsetColor().run() }catch{} }
function pickHighlight(){
  try{
    const color = window.prompt('하이라이트 색상 (예: yellow):')
    if(!color) return
    ;(editor.value as any)?.chain().focus().setHighlight({ color }).run()
  }catch{}
}

function setCodeLang(){
  try{
    const lang = window.prompt('코드 블록 언어(예: javascript, typescript, python, bash, json, yaml, markdown):')
    if(!lang) return
    // TipTap CodeBlockLowlight는 언어를 class로 판단하므로 setContent를 사용하거나 selection 내 코드블록 업데이트 필요
    // 간단히: 코드블록 노드에 language attribute 설정 시도
    ;(editor.value as any)?.chain().focus().updateAttributes('codeBlock', { language: lang }).run()
  }catch{}
}

function toggleColorPalette(){ showColorPalette.value = !showColorPalette.value }
function toggleHighlightPalette(){ showHighlightPalette.value = !showHighlightPalette.value }
function setColorPreset(c: string){ try{ (editor.value as any)?.chain().focus().setColor(c).run(); showColorPalette.value=false }catch{} }
function setHighlightPreset(c: string){ try{ (editor.value as any)?.chain().focus().setHighlight({ color: c }).run(); showHighlightPalette.value=false }catch{} }

async function onPickImage(e: Event){
  const input = e?.target as HTMLInputElement
  const file = input?.files?.[0]
  if(!file) return
  try{
    const { path } = await api.uploadAsset(file, 'assets')
    ;(editor.value as any)?.chain().focus().setImage({ src: path }).run()
  }catch{ toast.push('error','이미지 업로드 실패') }
  if(imagePicker.value) imagePicker.value.value = ''
}

async function openAiMenu(){
  const choice = window.prompt('AI 작업 선택: table / mermaid / summary / rewrite')
  if(!choice) return
  const kindRaw = choice.trim().toLowerCase()
  const kind = ['table','mermaid','summary'].includes(kindRaw) ? kindRaw : 'summary'
  try{
    const currentMd = turndown.turndown(html.value || '')
    const out = await api.transform(currentMd, kind as any, {})
    const injected = marked.parse('\n'+(out?.result || '')+'\n')
    ;(editor.value as any)?.chain().focus().insertContent(injected).run()
  }catch{ toast.push('error','AI 변환 실패') }
}
</script>

<style scoped>
</style>


