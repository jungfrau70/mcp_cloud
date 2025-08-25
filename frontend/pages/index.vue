<template>
  <div class="h-full"></div>
  <!-- Root redirects to Knowledge Base so index.md opens by default -->
</template>

<script setup>
definePageMeta({ layout: 'default', title: 'Home' })
onMounted(() => { try { navigateTo('/knowledge-base?home=1') } catch {} })
</script>