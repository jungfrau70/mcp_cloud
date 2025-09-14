<template>
  <div class="p-4" v-if="showProgress">
    <!-- 진행률 바 -->
    <div class="w-full bg-gray-200 rounded-full h-2.5 dark:bg-gray-700">
      <div 
        class="bg-blue-600 h-2.5 rounded-full transition-all duration-300 ease-in-out" 
        :style="{ width: `${progressPercentage}%` }"
      ></div>
    </div>
    
    <!-- 진행률 텍스트 -->
    <div class="mt-2 flex justify-between items-center text-sm">
      <span class="text-gray-600">
        {{ currentStepName || `Step ${currentStepNumber} of ${totalSteps}` }}
      </span>
      <span class="font-semibold text-blue-600">
        {{ progressPercentage }}%
      </span>
    </div>
    
    <!-- 과정 정보 (선택적) -->
    <div v-if="showCourseInfo && courseName" class="mt-1 text-xs text-gray-500">
      {{ courseName }}
    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import { useProgressStore } from '~/stores/progress'

const props = defineProps({
  courseId: {
    type: String,
    default: null
  },
  courseName: {
    type: String,
    default: null
  },
  currentStepName: {
    type: String,
    default: null
  },
  currentStepNumber: {
    type: Number,
    default: 1
  },
  totalSteps: {
    type: Number,
    default: 1
  },
  showCourseInfo: {
    type: Boolean,
    default: false
  },
  showProgress: {
    type: Boolean,
    default: true
  }
})

const progressStore = useProgressStore()

// 현재 과정의 진도 정보
const currentProgress = computed(() => {
  if (props.courseId) {
    return progressStore.userProgress[props.courseId]
  }
  return progressStore.currentCourseProgress.value
})

// 진행률 계산
const progressPercentage = computed(() => {
  if (currentProgress.value) {
    return currentProgress.value.progressPercentage
  }
  
  // props로 전달된 값이 있으면 사용
  if (props.totalSteps > 0) {
    return Math.round((props.currentStepNumber / props.totalSteps) * 100)
  }
  
  return 0
})

// 현재 단계 설정
if (props.courseId && props.currentStepNumber) {
  progressStore.setCurrentStep(`${props.courseId}_step_${props.currentStepNumber}`)
}
</script>
