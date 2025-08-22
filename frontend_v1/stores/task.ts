import { defineStore } from 'pinia'
import { ref } from 'vue'
import { useTaskEvents } from '~/composables/useTaskEvents'

interface TaskItem { id: string; type: string; status: string; stage?: string; progress?: number; error?: string }

export const useTaskStore = defineStore('task', () => {
  const tasks = ref<TaskItem[]>([])
  let subscribed = false

  function upsert(patch: TaskItem){
    const idx = tasks.value.findIndex(t=>t.id===patch.id)
    if(idx>=0) tasks.value[idx] = { ...tasks.value[idx], ...patch }
    else tasks.value.unshift(patch)
    if(tasks.value.length > 100) tasks.value.pop()
  }

  function subscribe(){
    if(subscribed) return
    subscribed = true
    const { on } = useTaskEvents()
    on('generation', (evt) => {
      upsert({ id: evt.task_id, type: 'generation', status: evt.status, stage: evt.stage, progress: evt.progress, error: evt.error })
    })
  }

  return { tasks, subscribe }
})
