<template>
  <div class="max-w-md mx-auto mt-16 bg-white p-6 rounded shadow">
    <h1 class="text-xl font-semibold mb-4">로그인</h1>
    <form @submit.prevent="onSubmit" class="space-y-4">
      <div>
        <label class="block text-sm mb-1">이메일</label>
        <input v-model="email" type="email" class="w-full border rounded px-3 py-2" required />
      </div>
      <div>
        <label class="block text-sm mb-1">비밀번호</label>
        <input v-model="password" type="password" class="w-full border rounded px-3 py-2" required />
      </div>
      <button type="submit" class="w-full bg-black text-white py-2 rounded">로그인</button>
    </form>
    <div v-if="showVerifyNotice" class="mt-4 p-3 rounded border border-amber-300 bg-amber-50 text-amber-800 text-sm">
      이메일 인증이 필요합니다. 받은 메일의 링크를 클릭하거나,
      <button class="ml-1 underline" @click="resendVerification" :disabled="sending">{{ sending ? '재전송 중...' : '인증 메일 재전송' }}</button>
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
auth.loadFromStorage()

const showVerifyNotice = ref(false)
const sending = ref(false)

async function onSubmit(){
  const base = (config.public?.apiBaseUrl) || '/api'
  showVerifyNotice.value = false
  // Defensive: clear any previous token to avoid stale Authorization on parallel requests
  try { auth.clear() } catch {}
  try{
    const res = await $fetch(`${base}/v1/auth/login`, {
      method: 'POST',
      body: { email: email.value, password: password.value },
    }) as { access_token: string }
    auth.setToken(res.access_token)
    const apiKey = ((config.public as any)?.apiKey) || 'my_mcp_eagle_tiger'
    const me = await $fetch(`${base}/v1/users/me`, {
      headers: {
        'X-API-Key': apiKey,
        'Authorization': `Bearer ${res.access_token}`
      }
    }) as { email: string, role: string }
    auth.setUser(me.email, me.role)
    if (String(me.role).toLowerCase() === 'admin') {
      await router.push('/knowledge-base')
    } else {
      await router.push('/curriculum')
    }
  } catch(e: any) {
    const detail = e?.data?.detail || e?.data || {}
    if (detail?.code === 'EMAIL_NOT_VERIFIED'){
      showVerifyNotice.value = true
      return
    }
    alert('로그인에 실패했습니다.')
  }
}

async function resendVerification(){
  try{
    sending.value = true
    const base = (config.public?.apiBaseUrl) || '/api'
    await $fetch(`${base}/v1/auth/resend-verification`, {
      method: 'POST',
      body: { email: email.value }
    })
    alert('인증 메일이 재전송되었습니다.')
  }catch{
    alert('재전송에 실패했습니다. 잠시 후 다시 시도해 주세요.')
  } finally { sending.value = false }
}
</script>

