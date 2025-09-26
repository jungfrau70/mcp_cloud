<template>
  <div class="min-h-screen flex items-center justify-center bg-gray-50 py-12 px-4 sm:px-6 lg:px-8">
    <div class="max-w-md w-full space-y-8">
      <div>
        <h2 class="mt-6 text-center text-3xl font-extrabold text-gray-900">
          비밀번호 찾기
        </h2>
        <p class="mt-2 text-center text-sm text-gray-600">
          가입하신 이메일 주소를 입력하시면 비밀번호 재설정 링크를 보내드립니다.
        </p>
      </div>
      <form class="mt-8 space-y-6" @submit.prevent="handleForgotPassword">
        <div>
          <label for="email" class="sr-only">이메일 주소</label>
          <input
            id="email"
            name="email"
            type="email"
            autocomplete="email"
            required
            v-model="email"
            class="appearance-none rounded-md relative block w-full px-3 py-2 border border-gray-300 placeholder-gray-500 text-gray-900 focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 focus:z-10 sm:text-sm"
            placeholder="이메일 주소"
          />
        </div>

        <div v-if="message" class="rounded-md p-4" :class="messageType === 'success' ? 'bg-green-50' : 'bg-red-50'">
          <div class="flex">
            <div class="flex-shrink-0">
              <svg v-if="messageType === 'success'" class="h-5 w-5 text-green-400" viewBox="0 0 20 20" fill="currentColor">
                <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd" />
              </svg>
              <svg v-else class="h-5 w-5 text-red-400" viewBox="0 0 20 20" fill="currentColor">
                <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z" clip-rule="evenodd" />
              </svg>
            </div>
            <div class="ml-3">
              <p class="text-sm font-medium" :class="messageType === 'success' ? 'text-green-800' : 'text-red-800'">
                {{ message }}
              </p>
            </div>
          </div>
        </div>

        <div>
          <button
            type="submit"
            :disabled="isLoading"
            class="group relative w-full flex justify-center py-2 px-4 border border-transparent text-sm font-medium rounded-md text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500 disabled:opacity-50 disabled:cursor-not-allowed"
          >
            <span v-if="isLoading" class="absolute left-0 inset-y-0 flex items-center pl-3">
              <svg class="animate-spin h-5 w-5 text-white" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
              </svg>
            </span>
            {{ isLoading ? '처리 중...' : '비밀번호 재설정 링크 보내기' }}
          </button>
        </div>

        <div class="text-center">
          <NuxtLink to="/login" class="font-medium text-indigo-600 hover:text-indigo-500">
            로그인 페이지로 돌아가기
          </NuxtLink>
        </div>
      </form>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { $fetch } from 'ofetch'

// SEO 메타데이터
useHead({
  title: '비밀번호 찾기 | GoldenCircle',
  meta: [
    { name: 'description', content: 'GoldenCircle 계정의 비밀번호를 재설정하세요. 이메일로 재설정 링크를 받을 수 있습니다.' }
  ]
})

const email = ref('')
const isLoading = ref(false)
const message = ref('')
const messageType = ref('')

async function handleForgotPassword() {
  if (!email.value) {
    message.value = '이메일 주소를 입력해주세요.'
    messageType.value = 'error'
    return
  }

  isLoading.value = true
  message.value = ''

  try {
    const base = config.public.apiBaseUrl || 'http://localhost:8000'
    
    await $fetch(`${base}/api/v1/auth/forgot-password`, {
      method: 'POST',
      body: {
        email: email.value
      }
    })

    message.value = '비밀번호 재설정 링크가 이메일로 전송되었습니다. 이메일을 확인해주세요.'
    messageType.value = 'success'
    email.value = ''
  } catch (error) {
    console.error('Forgot password error:', error)
    message.value = '오류가 발생했습니다. 다시 시도해주세요.'
    messageType.value = 'error'
  } finally {
    isLoading.value = false
  }
}
</script>
