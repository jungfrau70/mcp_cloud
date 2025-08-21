<template>
  <div class="space-y-3">
    <textarea v-model="topic" rows="3" placeholder="생성할 문서 주제" class="w-full px-2 py-1 border rounded" />
    <input v-model="targetPath" type="text" placeholder="저장 경로(optional)" class="w-full px-2 py-1 border rounded" />
    <div class="flex items-center gap-2 text-xs text-gray-500">
      <span>실패 스테이지</span>
      <select v-model="failStage" class="border rounded px-1 py-0.5 bg-white">
        <option value="">--</option>
        <option v-for="s in stages" :key="s">{{ s }}</option>
      </select>
      <button v-if="failStage" @click="failStage=''" class="text-gray-400 hover:text-gray-600">초기화</button>
    </div>
    <div class="flex items-center gap-2">
      <button @click="start" :disabled="!canStart || running" class="px-4 py-2 bg-blue-600 text-white text-sm rounded disabled:opacity-50 flex items-center gap-2">
        <span v-if="running" class="animate-spin h-4 w-4 border-2 border-white border-t-transparent rounded-full" />
        {{ running ? '생성 중...' : 'AI 문서 생성' }}
      </button>
      <button v-if="!running && (errorMsg || successMsg)" @click="retry" class="px-2 py-1 text-xs bg-gray-200 rounded">Retry</button>
      <div v-if="running" class="flex items-center gap-2 text-xs text-blue-600">
        <span>{{ status }}</span>
        <div class="w-28 h-2 bg-gray-200 rounded overflow-hidden">
          <div class="h-full bg-blue-500" :style="{ width: progress + '%' }" />
        </div>
      </div>
    </div>
    <div v-if="errorMsg" class="text-xs text-red-600">{{ errorMsg }}</div>
    <div v-if="successMsg" class="text-xs text-green-600">{{ successMsg }}</div>
  </div>
</template>
<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useKbApi } from '~/composables/useKbApi'
import { useTaskStore } from '~/stores/task'
import { useToastStore } from '~/stores/toast'

const emit = defineEmits(['open'])
const api = useKbApi()
const taskStore = useTaskStore()
const toast = useToastStore()

const topic = ref('')
const targetPath = ref('')
const failStage = ref('')
const stages = ['collect','extract','cluster','summarize','compose','validate']
const taskId = ref<string|undefined>()
const running = ref(false)
const status = ref('')
const errorMsg = ref('')
const successMsg = ref('')

const progress = computed(()=>{
  const m = status.value.match(/(\d+)%/)
  return m ? Number(m[1]) : 0
})
const canStart = computed(()=> topic.value.trim().length > 2)

onMounted(()=>{ taskStore.subscribe() })

async function start(){
  if(!canStart.value) return
  running.value = true
  status.value = '대기 중'
  errorMsg.value = ''
  successMsg.value = ''
  try {
    const t = await api.startCompose(topic.value, failStage.value || undefined)
    taskId.value = t.id
    status.value = 'collect (0%)'
    toast.push('info','생성 시작: '+topic.value)
    poll() // lightweight stage reflection via polling fallback
  } catch(e:any){
    running.value = false
    errorMsg.value = e.message || '시작 실패'
  }
}

async function poll(){
  if(!taskId.value) return
  try {
    const info = await api.getTask(taskId.value)
    status.value = `${info.stage || info.status} (${info.progress||0}%)`
    if(info.status === 'error'){
      running.value = false
      errorMsg.value = info.error || '실패'
      toast.push('error','생성 실패')
      return
    }
    if(info.status === 'done'){
      running.value = false
      successMsg.value = '생성 완료'
      toast.push('success','문서 생성 완료')
      // open generated doc (path derived server side in finalize step, we attempt standard naming fallback)
      // Optional: could fetch output for metadata here
      return
    }
  } catch(e){ /* ignore intermittent */ }
  if(running.value) setTimeout(poll, 1200)
}

function retry(){ start() }
</script>
