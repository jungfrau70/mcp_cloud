<template>
  <div class="min-h-screen flex items-center justify-center bg-gray-50 py-12 px-4 sm:px-6 lg:px-8">
    <div class="max-w-md w-full space-y-8">
      <div>
        <h2 class="mt-6 text-center text-3xl font-extrabold text-gray-900">
          새 비밀번호 설정
        </h2>
        <p class="mt-2 text-center text-sm text-gray-600">
          새로운 비밀번호를 입력해주세요.
        </p>
      </div>
      <form class="mt-8 space-y-6" @submit.prevent="handleResetPassword">
        <div>
          <label for="password" class="sr-only">새 비밀번호</label>
          <input
            id="password"
            name="password"
            type="password"
            autocomplete="new-password"
            required
            v-model="password"
            class="appearance-none rounded-md relative block w-full px-3 py-2 border border-gray-300 placeholder-gray-500 text-gray-900 focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 focus:z-10 sm:text-sm"
            placeholder="새 비밀번호"
          />
        </div>

        <div>
          <label for="confirmPassword" class="sr-only">비밀번호 확인</label>
          <input
            id="confirmPassword"
            name="confirmPassword"
            type="password"
            autocomplete="new-password"
            required
            v-model="confirmPassword"
            class="appearance-none rounded-md relative block w-full px-3 py-2 border border-gray-300 placeholder-gray-500 text-gray-900 focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 focus:z-10 sm:text-sm"
            placeholder="비밀번호 확인"
          />
        </div>

        <div v-if="password && confirmPassword && password !== confirmPassword" class="text-red-600 text-sm">
          비밀번호가 일치하지 않습니다.
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
            :disabled="isLoading || !password || !confirmPassword || password !== confirmPassword"
            class="group relative w-full flex justify-center py-2 px-4 border border-transparent text-sm font-medium rounded-md text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500 disabled:opacity-50 disabled:cursor-not-allowed"
          >
            <span v-if="isLoading" class="absolute left-0 inset-y-0 flex items-center pl-3">
              <svg class="animate-spin h-5 w-5 text-white" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
              </svg>
            </span>
            {{ isLoading ? '처리 중...' : '비밀번호 변경' }}
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
import { ref, onMounted } from 'vue'
import { $fetch } from 'ofetch'
import { useRoute, useRouter } from 'vue-router'

// SEO 메타데이터
useHead({
  title: '비밀번호 재설정 | GoldenCircle',
  meta: [
    { name: 'description', content: 'GoldenCircle 계정의 비밀번호를 재설정하세요.' }
  ]
})

const route = useRoute()
const router = useRouter()

const password = ref('')
const confirmPassword = ref('')
const isLoading = ref(false)
const message = ref('')
const messageType = ref('')
const token = ref('')

onMounted(() => {
  token.value = route.query.token
  if (!token.value) {
    message.value = '유효하지 않은 링크입니다.'
    messageType.value = 'error'
  }
})

async function handleResetPassword() {
  if (!token.value) {
    message.value = '유효하지 않은 링크입니다.'
    messageType.value = 'error'
    return
  }

  if (!password.value || !confirmPassword.value) {
    message.value = '비밀번호를 입력해주세요.'
    messageType.value = 'error'
    return
  }

  if (password.value !== confirmPassword.value) {
    message.value = '비밀번호가 일치하지 않습니다.'
    messageType.value = 'error'
    return
  }

  isLoading.value = true
  message.value = ''

  try {
    const base = config.public.apiBaseUrl || 'http://localhost:8000'
    
    await $fetch(`${base}/api/v1/auth/reset-password`, {
      method: 'POST',
      body: {
        token: token.value,
        new_password: password.value
      }
    })

    message.value = '비밀번호가 성공적으로 변경되었습니다. 로그인 페이지로 이동합니다.'
    messageType.value = 'success'
    
    // 3초 후 로그인 페이지로 이동
    setTimeout(() => {
      router.push('/login')
    }, 3000)
  } catch (error) {
    console.error('Reset password error:', error)
    if (error.data?.detail === 'Invalid or expired token') {
      message.value = '유효하지 않거나 만료된 링크입니다. 비밀번호 찾기를 다시 시도해주세요.'
    } else {
      message.value = '오류가 발생했습니다. 다시 시도해주세요.'
    }
    messageType.value = 'error'
  } finally {
    isLoading.value = false
  }
}
</script>
