<template>
  <div class="max-w-md mx-auto mt-16 bg-white p-6 rounded shadow">
    <h1 class="text-xl font-semibold mb-4">회원가입</h1>
    <form @submit.prevent="onSubmit" class="space-y-4">
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
      <button type="submit" class="w-full bg-black text-white py-2 rounded">회원가입</button>
    </form>
    <p class="text-sm mt-4 text-gray-600">이미 계정이 있나요? <NuxtLink class="text-blue-600" to="/login">로그인</NuxtLink></p>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { useRuntimeConfig } from '#app'
import { useRouter } from 'vue-router'
import { useAuthStore } from '~/stores/auth'

const email = ref('')
const password = ref('')
const fullName = ref('')
const router = useRouter()
const config = useRuntimeConfig()
const auth = useAuthStore()
auth.loadFromStorage()

async function onSubmit(){
  const base = (config.public?.apiBaseUrl) || '/api'
  const res = await $fetch(`${base}/v1/auth/register`, {
    method: 'POST',
    body: { email: email.value, password: password.value, full_name: fullName.value || null },
  }) as { access_token: string }
  auth.setToken(res.access_token)
  await router.push('/verify-email')
}
</script>


