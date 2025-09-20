<template>
  <div class="max-w-md mx-auto mt-16 bg-white p-6 rounded shadow">
    <h1 class="text-xl font-semibold mb-4">로그인</h1>
    <form @submit.prevent="onSubmit" class="space-y-4">
      <div>
        <label class="block text-sm mb-1">이메일</label>
        <input 
          v-model="email" 
          type="email" 
          :class="[
            'w-full border rounded px-3 py-2',
            loginError ? 'border-red-300 focus:border-red-500 focus:ring-red-500' : 'border-gray-300 focus:border-blue-500 focus:ring-blue-500'
          ]"
          required 
        />
      </div>
      <div>
        <label class="block text-sm mb-1">비밀번호</label>
        <input 
          v-model="password" 
          type="password" 
          :class="[
            'w-full border rounded px-3 py-2',
            loginError ? 'border-red-300 focus:border-red-500 focus:ring-red-500' : 'border-gray-300 focus:border-blue-500 focus:ring-blue-500'
          ]"
          required 
        />
      </div>
      <button type="submit" :disabled="isLoading" class="w-full bg-black text-white py-2 rounded disabled:opacity-50 disabled:cursor-not-allowed">
        {{ isLoading ? '로그인 중...' : '로그인' }}
      </button>
    </form>
    <!-- 이메일 인증 안내 -->
    <div v-if="showVerifyNotice" class="mt-4 p-3 rounded border border-amber-300 bg-amber-50 text-amber-800 text-sm">
      이메일 인증이 필요합니다. 받은 메일의 링크를 클릭하거나,
      <button class="ml-1 underline" @click="resendVerification" :disabled="sending">{{ sending ? '재전송 중...' : '인증 메일 재전송' }}</button>
    </div>
    
    <!-- 로그인 실패 메시지 -->
    <div v-if="loginError" class="mt-4 p-4 rounded border border-red-300 bg-red-50 text-red-800">
      <div class="flex items-start">
        <svg class="w-5 h-5 text-red-400 mt-0.5 mr-2 flex-shrink-0" fill="currentColor" viewBox="0 0 20 20">
          <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z" clip-rule="evenodd" />
        </svg>
        <div class="flex-1">
          <h3 class="font-medium text-red-800 mb-1">로그인에 실패했습니다</h3>
          <p class="text-sm text-red-700 mb-3">{{ loginError }}</p>
          <div class="flex flex-col sm:flex-row gap-2">
            <button 
              @click="retryLogin" 
              :disabled="isLoading || retryCount >= 3"
              class="px-4 py-2 bg-red-600 text-white text-sm rounded hover:bg-red-700 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
            >
              {{ retryCount >= 3 ? '재시도 제한' : '다시 시도' }}
              <span v-if="retryCount > 0 && retryCount < 3" class="ml-1 text-xs">({{ retryCount }}/3)</span>
            </button>
            <button 
              @click="clearError" 
              class="px-4 py-2 bg-gray-200 text-gray-700 text-sm rounded hover:bg-gray-300 transition-colors"
            >
              닫기
            </button>
          </div>
        </div>
      </div>
    </div>
    
    <!-- 도움말 섹션 -->
    <div v-if="loginError" class="mt-3 p-3 rounded border border-blue-200 bg-blue-50 text-blue-800 text-sm">
      <h4 class="font-medium mb-2">💡 도움말</h4>
      <ul class="space-y-1 text-xs">
        <li>• 이메일과 비밀번호를 다시 확인해주세요</li>
        <li>• 비밀번호는 대소문자를 구분합니다</li>
        <li>• 계정이 없다면 <NuxtLink to="/register" class="underline font-medium">회원가입</NuxtLink>을 해주세요</li>
        <li>• 비밀번호를 잊으셨다면 <button @click="showPasswordReset" class="underline font-medium">비밀번호 재설정</button>을 이용하세요</li>
      </ul>
    </div>
    
    <p class="text-sm mt-4 text-gray-600">계정이 없나요? <NuxtLink class="text-blue-600" to="/register">회원가입</NuxtLink></p>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { useRuntimeConfig } from '#app'
import { useRouter } from 'vue-router'
import { useAuthStore } from '~/stores/auth'

const email = ref('')
const password = ref('')
const router = useRouter()
const config = useRuntimeConfig()
const auth = useAuthStore()
// 중복 토큰 로드 방지: auth.loadFromStorage() 제거

const showVerifyNotice = ref(false)
const sending = ref(false)
const isLoading = ref(false)
const loginError = ref('')
const retryCount = ref(0)

async function onSubmit(){
  if (isLoading.value) return // 중복 요청 방지
  
  const base = process.env.NODE_ENV === 'production' ? 'https://api.goldencircle.us' : 'http://localhost:8000'
  showVerifyNotice.value = false
  loginError.value = '' // 이전 오류 메시지 초기화
  isLoading.value = true
  
  // Defensive: clear any previous token to avoid stale Authorization on parallel requests
  try { auth.clear() } catch {}
  
  try{
    console.log('로그인 시도:', { email: email.value, base, retryCount: retryCount.value })
    
    const res = await $fetch(`${base}/api/v1/auth/login`, {
      method: 'POST',
      body: { email: email.value, password: password.value },
      headers: {
        'Content-Type': 'application/json',
        'X-API-Key': (config.public as any)?.apiKey || 'my_mcp_eagle_tiger'
      },
      timeout: 10000 // 10초 타임아웃 설정
    }) as { access_token: string }
    
    console.log('로그인 성공:', res)
    auth.setToken(res.access_token)
    retryCount.value = 0 // 성공 시 재시도 카운트 초기화
    await router.push('/curriculum')
  } catch(e: any) {
    console.error('Login error:', e)
    retryCount.value++
    
    // 네트워크 오류 처리
    if (e.name === 'FetchError' || e.message?.includes('Failed to fetch')) {
      loginError.value = '네트워크 연결에 실패했습니다. 인터넷 연결을 확인하고 다시 시도해주세요.'
      return
    }
    
    // 타임아웃 오류 처리
    if (e.name === 'TimeoutError' || e.message?.includes('timeout')) {
      loginError.value = '서버 응답이 지연되고 있습니다. 잠시 후 다시 시도해주세요.'
      return
    }
    
    const detail = e?.data?.detail || e?.data || {}
    if (detail?.code === 'EMAIL_NOT_VERIFIED'){
      showVerifyNotice.value = true
      return
    }
    
    // 구체적인 에러 메시지 설정
    let errorMessage = '로그인에 실패했습니다.'
    
    if (detail?.message) {
      errorMessage = detail.message
    } else if (e?.message) {
      errorMessage = e.message
    } else if (e?.status === 401) {
      errorMessage = '이메일 또는 비밀번호가 올바르지 않습니다.'
    } else if (e?.status === 429) {
      errorMessage = '너무 많은 로그인 시도가 있었습니다. 잠시 후 다시 시도해주세요.'
    } else if (e?.status >= 500) {
      errorMessage = '서버에 일시적인 문제가 발생했습니다. 잠시 후 다시 시도해주세요.'
    }
    
    loginError.value = errorMessage
  } finally {
    isLoading.value = false
  }
}

// 재시도 함수
function retryLogin() {
  if (retryCount.value >= 3) {
    loginError.value = '너무 많은 시도가 있었습니다. 잠시 후 다시 시도해주세요.'
    return
  }
  onSubmit()
}

// 오류 메시지 초기화
function clearError() {
  loginError.value = ''
  retryCount.value = 0
}

// 비밀번호 재설정 안내
function showPasswordReset() {
  router.push('/forgot-password')
}

async function resendVerification(){
  try{
    sending.value = true
    const base = process.env.NODE_ENV === 'production' ? 'https://api.goldencircle.us' : 'http://localhost:8000'
    await $fetch(`${base}/api/v1/auth/resend-verification`, {
      method: 'POST',
      body: { email: email.value }
    })
    alert('인증 메일이 재전송되었습니다.')
  }catch{
    alert('재전송에 실패했습니다. 잠시 후 다시 시도해 주세요.')
  } finally { sending.value = false }
}
</script>

