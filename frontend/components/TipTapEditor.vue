<template>
  <div v-if="mounted" class="tiptap-editor">
    <div class="toolbar flex items-center gap-2 mb-2 text-sm">
      <button class="btn" @click="cmd('toggleBold')" :class="{active:isActive('bold')}">B</button>
      <button class="btn" @click="cmd('toggleItalic')" :class="{active:isActive('italic')}"><i>I</i></button>
      <button class="btn" @click="cmd('toggleStrike')" :class="{active:isActive('strike')}">S</button>
      <button class="btn" @click="cmd('toggleBulletList')">• List</button>
      <button class="btn" @click="cmd('toggleOrderedList')">1. List</button>
      <button class="btn" @click="insertTable">Table</button>
    </div>
    <div ref="editorEl" />
  </div>
</template>

<script setup>
import { ref, onMounted, watch, onBeforeUnmount } from 'vue'

const props = defineProps({ modelValue: { type: String, default: '' } })
const emit = defineEmits(['update:modelValue'])

let editor
let turndown
const mounted = ref(false)
const editorEl = ref(null)

function mdToHtml(md){
  try {
    // late import to keep it client-only
    const { marked } = window as any
    if (marked && marked.parse) return marked.parse(md || '')
  } catch {}
  return (md || '')
}

onMounted(async () => {
  if (typeof window === 'undefined') return
  const [{ Editor }, StarterKit, tablePkg, Turndown, markedMod] = await Promise.all([
    import('@tiptap/vue-3'),
    import('@tiptap/starter-kit').then(m=>m.default),
    import('@tiptap/extension-table'),
    import('turndown').then(m=>m.default || m),
    import('marked')
  ])

  // setup helpers
  turndown = new Turndown()
  const Table = tablePkg.Table, TableRow = tablePkg.TableRow, TableCell = tablePkg.TableCell, TableHeader = tablePkg.TableHeader
  const initialHTML = markedMod.marked.parse(props.modelValue || '')

  editor = new Editor({
    element: editorEl.value,
    content: initialHTML,
    extensions: [
      StarterKit.configure({ codeBlock: true }),
      Table.configure({ resizable: true }),
      TableRow, TableHeader, TableCell,
    ],
    onUpdate({ editor }) {
      const html = editor.getHTML()
      const md = turndown.turndown(html)
      emit('update:modelValue', md)
    }
  })
  mounted.value = true
})

onBeforeUnmount(() => { try{ editor && editor.destroy() }catch{} })

function cmd(name){ try{ editor?.chain().focus()[name]().run() }catch{} }
function isActive(type){ try{ return !!editor?.isActive(type) }catch{ return false } }
function insertTable(){ try{ editor?.chain().focus().insertTable({ rows: 3, cols: 4, withHeaderRow: true }).run() }catch{} }

watch(() => props.modelValue, (val) => {
  try{
    if (!editor) return
    const html = editor.getHTML()
    const md = turndown ? turndown.turndown(html) : ''
    if ((val || '') !== md) editor.commands.setContent(mdToHtml(val || ''), false)
  }catch{}
})
</script>

<style scoped>
.btn{ padding:2px 6px; border-radius:4px; background:#f3f4f6; }
.btn.active{ background:#e5e7eb; font-weight:600 }
.tiptap-editor :deep(.ProseMirror){ min-height: 50vh; padding:12px; border:1px solid #e5e7eb; border-radius:6px; background:#fff }
</style>


