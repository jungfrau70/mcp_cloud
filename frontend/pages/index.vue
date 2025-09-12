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
import { cleanApiPath, deepCleanApiPath } from '~/utils/path'

definePageMeta({ layout: 'default', title: 'Home' })

const content = ref('')
const path = ref('index.md')

onMounted(async () => {
  // 클라이언트 사이드에서만 실행
  if (typeof window === 'undefined') return;
  
  const apiBase = resolveApiBase()
  try{
    const r = await fetch(`${apiBase}/v1/curriculum/item?path=${encodeURIComponent(deepCleanApiPath(path.value))}`, {
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