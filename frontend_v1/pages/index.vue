<template>
  <div class="h-full flex flex-col items-center justify-center p-4">
    <h1 class="text-4xl font-bold text-gray-900 mb-4">Welcome to MCP Cloud Platform</h1>
    <p class="text-lg text-gray-600 mb-8">Your integrated learning and management environment.</p>
    
    <div class="space-x-4">
      <NuxtLink to="/knowledge-base" class="px-6 py-3 bg-blue-600 text-white rounded-lg shadow hover:bg-blue-700">
        Start Learning
      </NuxtLink>
      <NuxtLink to="/datasources" class="px-6 py-3 bg-gray-200 text-gray-800 rounded-lg shadow hover:bg-gray-300">
        Explore Data Sources
      </NuxtLink>
    </div>
  </div>
</template>

<script setup>
definePageMeta({
  layout: 'default', // Use the new default layout
  title: 'Home'
})
</script>