<template>
  <div id="app">
    <NuxtLayout>
      <NuxtPage />
    </NuxtLayout>
  </div>
</template>

<script setup>
// App-level setup
import { useAuthStore } from '~/stores/auth'

// 앱 시작 시 인증 상태 로드
const auth = useAuthStore()
auth.loadFromStorage()
</script>

<style>
#app {
  font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
}
</style>
