<template>
  <div class="min-h-screen flex items-center justify-center bg-gray-50">
    <div class="max-w-md w-full bg-white shadow-lg rounded-lg p-6">
      <div class="flex items-center justify-center w-12 h-12 mx-auto bg-red-100 rounded-full">
        <svg class="w-6 h-6 text-red-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-2.5L13.732 4c-.77-.833-1.964-.833-2.732 0L3.732 16.5c-.77.833.192 2.5 1.732 2.5z" />
        </svg>
      </div>
      <div class="mt-4 text-center">
        <h1 class="text-lg font-medium text-gray-900">오류가 발생했습니다</h1>
        <p class="mt-2 text-sm text-gray-500">
          페이지를 새로고침하거나 잠시 후 다시 시도해주세요.
        </p>
        <div v-if="error" class="mt-4 p-3 bg-gray-100 rounded text-xs text-left">
          <strong>에러 정보:</strong><br>
          {{ error.message || '알 수 없는 오류' }}
        </div>
        <div class="mt-6 space-x-3">
          <button
            @click="handleRefresh"
            class="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md shadow-sm text-white bg-blue-600 hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500"
          >
            새로고침
          </button>
          <button
            @click="handleHome"
            class="inline-flex items-center px-4 py-2 border border-gray-300 text-sm font-medium rounded-md shadow-sm text-gray-700 bg-white hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500"
          >
            홈으로
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
const props = defineProps({
  error: Object
})

const handleRefresh = () => {
  if (typeof window !== 'undefined') {
    window.location.reload()
  }
}

const handleHome = () => {
  if (typeof window !== 'undefined') {
    window.location.href = '/'
  }
}
</script>
