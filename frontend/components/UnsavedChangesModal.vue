<template>
  <div v-if="show" class="fixed inset-0 z-50 flex items-center justify-center">
    <!-- Backdrop -->
    <div class="absolute inset-0 bg-black bg-opacity-50" @click="handleCancel"></div>
    
    <!-- Modal -->
    <div class="relative bg-white dark:bg-gray-800 rounded-lg shadow-xl max-w-md w-full mx-4 transform transition-all">
      <!-- Header -->
      <div class="px-6 py-4 border-b border-gray-200 dark:border-gray-700">
        <div class="flex items-center">
          <div class="flex-shrink-0">
            <svg class="h-6 w-6 text-amber-500" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-2.5L13.732 4c-.77-.833-1.964-.833-2.732 0L3.732 16.5c-.77.833.192 2.5 1.732 2.5z" />
            </svg>
          </div>
          <div class="ml-3">
            <h3 class="text-lg font-medium text-gray-900 dark:text-white">
              저장되지 않은 변경사항
            </h3>
          </div>
        </div>
      </div>
      
      <!-- Body -->
      <div class="px-6 py-4">
        <p class="text-sm text-gray-600 dark:text-gray-300 mb-4">
          현재 편집 중인 내용에 저장되지 않은 변경사항이 있습니다.
        </p>
        <p class="text-sm text-gray-600 dark:text-gray-300 mb-6">
          이동하기 전에 어떻게 하시겠습니까?
        </p>
        
        <!-- Options -->
        <div class="space-y-3">
          <div class="flex items-start">
            <div class="flex-shrink-0">
              <div class="w-2 h-2 bg-blue-500 rounded-full mt-2"></div>
            </div>
            <div class="ml-3">
              <p class="text-sm font-medium text-gray-900 dark:text-white">저장 후 이동</p>
              <p class="text-xs text-gray-500 dark:text-gray-400">변경사항을 저장하고 새 파일로 이동합니다</p>
            </div>
          </div>
          
          <div class="flex items-start">
            <div class="flex-shrink-0">
              <div class="w-2 h-2 bg-orange-500 rounded-full mt-2"></div>
            </div>
            <div class="ml-3">
              <p class="text-sm font-medium text-gray-900 dark:text-white">저장하지 않고 이동</p>
              <p class="text-xs text-gray-500 dark:text-gray-400">변경사항을 버리고 새 파일로 이동합니다</p>
            </div>
          </div>
          
          <div class="flex items-start">
            <div class="flex-shrink-0">
              <div class="w-2 h-2 bg-gray-400 rounded-full mt-2"></div>
            </div>
            <div class="ml-3">
              <p class="text-sm font-medium text-gray-900 dark:text-white">이동 취소</p>
              <p class="text-xs text-gray-500 dark:text-gray-400">현재 파일에서 계속 편집합니다</p>
            </div>
          </div>
        </div>
      </div>
      
      <!-- Footer -->
      <div class="px-6 py-4 bg-gray-50 dark:bg-gray-700 rounded-b-lg">
        <div class="flex justify-end space-x-3">
          <button
            @click="handleCancel"
            class="px-4 py-2 text-sm font-medium text-gray-700 dark:text-gray-300 bg-white dark:bg-gray-600 border border-gray-300 dark:border-gray-500 rounded-md hover:bg-gray-50 dark:hover:bg-gray-500 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-gray-500 transition-colors"
          >
            취소
          </button>
          <button
            @click="handleNavigateWithoutSave"
            class="px-4 py-2 text-sm font-medium text-orange-700 dark:text-orange-300 bg-orange-100 dark:bg-orange-900 border border-orange-300 dark:border-orange-700 rounded-md hover:bg-orange-200 dark:hover:bg-orange-800 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-orange-500 transition-colors"
          >
            저장하지 않고 이동
          </button>
          <button
            @click="handleSaveAndNavigate"
            class="px-4 py-2 text-sm font-medium text-white bg-blue-600 dark:bg-blue-500 border border-transparent rounded-md hover:bg-blue-700 dark:hover:bg-blue-600 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 transition-colors"
          >
            저장 후 이동
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted } from 'vue'

const props = defineProps({
  show: {
    type: Boolean,
    default: false
  }
})

const emit = defineEmits(['save-and-navigate', 'navigate-without-save', 'cancel'])

const handleSaveAndNavigate = () => {
  emit('save-and-navigate')
}

const handleNavigateWithoutSave = () => {
  emit('navigate-without-save')
}

const handleCancel = () => {
  emit('cancel')
}

// ESC 키로 취소
const handleKeydown = (event) => {
  if (event.key === 'Escape') {
    handleCancel()
  }
}

onMounted(() => {
  document.addEventListener('keydown', handleKeydown)
})

onUnmounted(() => {
  document.removeEventListener('keydown', handleKeydown)
})
</script>
