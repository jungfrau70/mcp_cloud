<template>
  <div class="p-6 h-full w-full">
    <h1 class="text-xl font-semibold mb-2">지식베이스</h1>
    <p v-if="loading">Loading...</p>
    <p v-else-if="!isAdmin" class="text-red-600">관리자 전용 페이지입니다.</p>
    <div v-else class="h-full w-full">
      <KnowledgeBaseExplorer mode="full" />
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import KnowledgeBaseExplorer from '~/components/KnowledgeBaseExplorer.vue'

definePageMeta({ title: '지식베이스' })

const loading = ref(true)
const isAdmin = ref(false)

onMounted(async () => {
  try {
    const me = await $fetch<{ role?: string }>('/api/v1/users/me')
    isAdmin.value = me?.role === 'admin'
  } catch (error) {
    console.warn('사용자 정보를 가져올 수 없습니다:', error)
    // API 호출 실패 시에도 페이지를 표시하되, 관리자 권한이 없다고 표시
    isAdmin.value = false
  }
  loading.value = false
})
</script>
