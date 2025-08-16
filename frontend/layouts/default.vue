<template>
  <div class="min-h-screen bg-gray-50">
    <nav class="bg-white shadow-sm border-b">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="flex justify-between h-16">
          <div class="flex items-center">
            <NuxtLink to="/" class="text-xl font-bold text-gray-900">
              MCP Cloud Platform
            </NuxtLink>
          </div>
          <div class="flex items-center space-x-4">
            <NuxtLink to="/" class="text-gray-700 hover:text-gray-900 px-3 py-2 rounded-md text-sm font-medium">
              홈
            </NuxtLink>
            <NuxtLink to="/ai-assistant" class="text-gray-700 hover:text-gray-900 px-3 py-2 rounded-md text-sm font-medium">
              AI 어시스턴트
            </NuxtLink>
            <NuxtLink to="/knowledge-base" class="text-gray-700 hover:text-gray-900 px-3 py-2 rounded-md text-sm font-medium">
              지식베이스
            </NuxtLink>
            <NuxtLink to="/datasources" class="text-gray-700 hover:text-gray-900 px-3 py-2 rounded-md text-sm font-medium">
              데이터소스
            </NuxtLink>
            <NuxtLink to="/cli" class="text-gray-700 hover:text-gray-900 px-3 py-2 rounded-md text-sm font-medium">
              CLI
            </NuxtLink>
          </div>
        </div>
      </div>
    </nav>
    
    <main class="max-w-7xl mx-auto py-6 sm:px-6 lg:px-8">
      <slot />
    </main>
  </div>
</template>

<script setup>
// Layout setup
</script>
