<template>
  <UPage>
    <UPageHeader
      title="MCP 서비스 데모"
      description="다양한 MCP 서버들을 통합하여 강력한 AI 기반 클라우드 관리 기능을 체험해보세요"
    >
      <template #headline>
        <div class="flex items-center gap-2 text-sm font-medium text-primary-600 dark:text-primary-400">
          <UIcon name="i-lucide-robot" class="w-4 h-4" />
          <span>AI 기반 MCP 통합 플랫폼</span>
        </div>
      </template>
    </UPageHeader>

    <UPageBody>
      <UContainer>
        <MCPIntegration />
      </UContainer>
    </UPageBody>
  </UPage>
</template>

<script setup>
import MCPIntegration from '~/components/MCPIntegration.vue'

definePageMeta({ 
  layout: 'default', 
  title: 'MCP 서비스 데모 - AI 기반 클라우드 관리',
  description: '다양한 MCP 서버들을 통합하여 강력한 AI 기반 클라우드 관리 기능을 체험해보세요'
})
</script>
