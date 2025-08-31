<template>
  <div class="max-w-md mx-auto mt-16 bg-white p-6 rounded shadow text-center">
    <h1 class="text-xl font-semibold mb-4">이메일 인증</h1>
    <div v-if="status==='pending'" class="text-gray-600">인증 중입니다...</div>
    <div v-else-if="status==='success'" class="text-green-700">인증이 완료되었습니다. 이제 로그인할 수 있습니다.</div>
    <div v-else class="text-red-700">인증 링크가 유효하지 않거나 만료되었습니다.</div>
    <div class="mt-6 flex justify-center gap-4">
      <NuxtLink to="/login" class="px-4 py-2 bg-black text-white rounded">로그인</NuxtLink>
      <NuxtLink to="/" class="px-4 py-2 bg-gray-200 rounded">홈으로</NuxtLink>
    </div>
  </div>
</template>

<script setup lang="ts">
import { useRoute, useRuntimeConfig } from '#app'
import { onMounted, ref } from 'vue'

const route = useRoute()
const config = useRuntimeConfig()
const status = ref<'pending'|'success'|'error'>('pending')

onMounted(async () => {
  try{
    const token = String((route.query?.token as string) || '')
    if(!token){ status.value = 'error'; return }
    const base = (config.public?.apiBaseUrl) || '/api'
    const res = await $fetch(`${base}/v1/auth/verify-email`, {
      method: 'POST',
      body: { token }
    }) as any
    status.value = res?.ok ? 'success' : 'error'
  }catch{ status.value = 'error' }
})
</script>


