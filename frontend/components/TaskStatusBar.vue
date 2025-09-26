<template>
  <div class="fixed bottom-0 left-0 right-0 text-xs flex items-center gap-4 px-3 border-t bg-white/90 backdrop-blur z-40" :style="{ height: barHeight + 'px' }">
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
import { ref, onMounted, onUnmounted, computed } from 'vue'
import { useTaskEvents } from '~/composables/useTaskEvents'

const tasks = ref([])

// 창 크기 변경 감지를 위한 상태
const windowHeight = ref(0)

// 창 크기 업데이트 함수
const updateWindowHeight = () => {
  if (typeof window !== 'undefined') {
    windowHeight.value = window.innerHeight
  }
}

// 동적 바 높이 계산
const barHeight = computed(() => {
  if (typeof window === 'undefined') return 24;
  
  const viewportHeight = windowHeight.value || window.innerHeight;
  
  // 화면이 작을 때 높이 조정
  if (viewportHeight <= 500) {
    return 16; // 1rem
  } else if (viewportHeight <= 600) {
    return 20; // 1.25rem
  }
  
  return 24; // 기본 높이
})

onMounted(() => {
  // 초기 창 크기 설정
  updateWindowHeight()
  
  // 창 크기 변경 이벤트 리스너 추가
  window.addEventListener('resize', updateWindowHeight)
  
  const { on } = useTaskEvents()
  on('generation', (data) => {
    const idx = tasks.value.findIndex(t => t.task_id === data.task_id)
    if(idx === -1) tasks.value.push(data)
    else tasks.value[idx] = { ...tasks.value[idx], ...data }
    tasks.value = tasks.value.filter(t => t.status !== 'done')
  })
})

// 컴포넌트 언마운트 시 이벤트 리스너 정리
onUnmounted(() => {
  if (typeof window !== 'undefined') {
    window.removeEventListener('resize', updateWindowHeight)
  }
})
</script>
<style scoped>
</style>
