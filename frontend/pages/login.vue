<template>
  <div class="min-h-screen flex items-center justify-center p-6">
    <div class="w-full max-w-sm bg-white border rounded-lg p-6 shadow-sm">
      <h1 class="text-xl font-semibold mb-4">로그인</h1>
      <p class="text-sm text-gray-600">현재는 인증을 사용하지 않습니다. 홈으로 이동하세요.</p>
      <div class="mt-4">
        <NuxtLink to="/" class="px-4 py-2 bg-blue-600 text-white rounded">홈으로</NuxtLink>
      </div>
    </div>
  </div>
</template>

<script setup>
definePageMeta({ title: '로그인' })
</script>


