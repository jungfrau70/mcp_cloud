<template>
  <div class="max-w-md mx-auto mt-16 bg-white p-6 rounded shadow">
    <h1 class="text-xl font-semibold mb-4">회원가입</h1>
    <div v-if="done" class="space-y-4">
      <div class="p-4 rounded border bg-gray-50 text-sm text-gray-700">
        가입이 접수되었습니다. 이메일로 인증 링크를 보냈습니다.<br/>
        받은 편지함(또는 스팸함)을 확인하고 링크를 클릭해 인증을 완료해 주세요.
      </div>
      <div class="flex gap-2">
        <NuxtLink to="/login" class="flex-1 text-center px-4 py-2 rounded bg-black text-white">로그인</NuxtLink>
        <a href="https://mail.google.com/" target="_blank" class="flex-1 text-center px-4 py-2 rounded border">Gmail 열기</a>
      </div>
    </div>
    <form v-else @submit.prevent="onSubmit" class="space-y-4">
      <div>
        <label class="block text-sm mb-1">이메일</label>
        <input v-model="email" type="email" class="w-full border rounded px-3 py-2" required />
      </div>
      <div>
        <label class="block text-sm mb-1">이름(선택)</label>
        <input v-model="fullName" type="text" class="w-full border rounded px-3 py-2" />
      </div>
      <div>
        <label class="block text-sm mb-1">비밀번호</label>
        <input v-model="password" type="password" class="w-full border rounded px-3 py-2" required />
      </div>
      <div>
        <label class="block text-sm mb-1">비밀번호 확인</label>
        <input v-model="passwordConfirm" type="password" class="w-full border rounded px-3 py-2" required />
      </div>
      <p v-if="error" class="text-sm text-red-600">{{ error }}</p>
      <button type="submit" class="w-full bg-black text-white py-2 rounded">회원가입</button>
      <p class="text-xs text-gray-500">가입 후 이메일 인증을 완료해야 로그인할 수 있습니다.</p>
    </form>
    <p v-if="!done" class="text-sm mt-4 text-gray-600">이미 계정이 있나요? <NuxtLink class="text-blue-600" to="/login">로그인</NuxtLink></p>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { useRuntimeConfig } from '#app'
import { useRouter } from 'vue-router'
import { useAuthStore } from '~/stores/auth'

const email = ref('')
const password = ref('')
const passwordConfirm = ref('')
const fullName = ref('')
const error = ref('')
const done = ref(false)
const router = useRouter()
const config = useRuntimeConfig()
const auth = useAuthStore()
auth.loadFromStorage()

async function onSubmit(){
  error.value = ''
  if (password.value !== passwordConfirm.value){
    error.value = '비밀번호가 일치하지 않습니다.'
    return
  }
  if ((password.value||'').length < 6){
    error.value = '비밀번호는 6자 이상이어야 합니다.'
    return
  }
  
  try {
    const base = config.public.apiBaseUrl || 'http://localhost:8000'
    const res = await $fetch(`${base}/api/v1/auth/register`, {
      method: 'POST',
      body: { email: email.value, password: password.value, full_name: fullName.value || null },
    }) as { access_token: string }
    
    // 회원가입 성공
    try{ auth.clear() }catch{}
    done.value = true
  } catch (e: any) {
    console.error('회원가입 오류:', e)
    
    const detail = e?.data?.detail || e?.data || {}
    
    if (detail?.code === 'EMAIL_ALREADY_EXISTS') {
      error.value = detail.message || '이미 등록된 이메일입니다. 로그인을 시도해보세요.'
      // 로그인 페이지로 리다이렉트 제안
      setTimeout(() => {
        if (confirm('로그인 페이지로 이동하시겠습니까?')) {
          router.push('/login')
        }
      }, 2000)
    } else if (detail?.message) {
      error.value = detail.message
    } else if (e?.message) {
      error.value = e.message
    } else {
      error.value = '회원가입에 실패했습니다. 다시 시도해주세요.'
    }
  }
}
</script>


