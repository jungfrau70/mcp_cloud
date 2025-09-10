<template>
  <div class="p-4">
    <!-- 중앙 콘텐츠는 레이아웃의 WorkspaceView가 렌더링합니다. -->
  </div>
</template>

<script setup>
definePageMeta({
  title: '커리큘럼'
})
// Legacy route: redirect to /curriculum on client-side
if (process.client) {
  try{ window.location.replace('/curriculum') }catch{}
}
</script>


