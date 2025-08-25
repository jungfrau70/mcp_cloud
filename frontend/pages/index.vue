<template>
  <div class="h-full flex flex-col">
    <div class="flex-1 overflow-hidden">
      <ContentView :content="content" :path="path" :readonly="true" />
    </div>
  </div>
</template>

<script setup>
import ContentView from '~/components/ContentView.vue'
import { resolveApiBase } from '~/composables/useKbApi'

definePageMeta({ layout: 'default', title: 'Home' })

const content = ref('')
const path = ref('index.md')

onMounted(async () => {
  const apiBase = resolveApiBase()
  try{
    const r = await fetch(`${apiBase}/api/v1/knowledge-base/item?path=${encodeURIComponent(path.value)}`, {
      headers: { 'X-API-Key': 'my_mcp_eagle_tiger' }
    })
    if(!r.ok) throw new Error('failed')
    const d = await r.json()
    content.value = d?.content || ''
  }catch{
    content.value = '# Welcome\n\nindex.md not found. Create it under mcp_knowledge_base/index.md.'
  }
})
</script>