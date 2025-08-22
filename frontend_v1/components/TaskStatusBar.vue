<template>
  <div class="h-6 text-xs flex items-center gap-4 px-3 border-t bg-white/90 backdrop-blur">
    <div v-for="t in tasks" :key="t.task_id" class="flex items-center gap-1">
      <span class="text-gray-500">{{ t.type }}:</span>
      <div class="w-40 bg-gray-200 h-2 rounded overflow-hidden">
        <div class="h-full bg-indigo-500 transition-all" :style="{ width: (t.progress||0) + '%' }"></div>
      </div>
      <span class="text-gray-500">{{ t.progress || 0 }}%</span>
    </div>
    <div v-if="!tasks.length" class="text-gray-400">No active tasks</div>
  </div>
</template>
<script setup>
import { ref, onMounted } from 'vue'
import { useTaskEvents } from '~/composables/useTaskEvents'

const tasks = ref([])

onMounted(() => {
  const { on } = useTaskEvents()
  on('generation', (data) => {
    const idx = tasks.value.findIndex(t => t.task_id === data.task_id)
    if(idx === -1) tasks.value.push(data)
    else tasks.value[idx] = { ...tasks.value[idx], ...data }
    tasks.value = tasks.value.filter(t => t.status !== 'done')
  })
})
</script>
<style scoped>
</style>
