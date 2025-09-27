<template>
  <div v-if="message" :class="['global-message', messageType]">
    <div class="message-content">
      <span class="message-text">{{ message }}</span>
      <button @click="closeMessage" class="close-btn">×</button>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, onUnmounted } from 'vue'

const message = ref('')
const messageType = ref<'success' | 'error' | 'info'>('info')

const showMessage = (msg: string, type: 'success' | 'error' | 'info' = 'info') => {
  message.value = msg
  messageType.value = type
  
  // 3초 후 자동 숨김
  setTimeout(() => {
    message.value = ''
  }, 3000)
}

const closeMessage = () => {
  message.value = ''
}

// 전역 이벤트 리스너
const handleShowMessage = (event: CustomEvent) => {
  showMessage(event.detail.message, event.detail.type)
}

onMounted(() => {
  window.addEventListener('show-message', handleShowMessage as EventListener)
})

onUnmounted(() => {
  window.removeEventListener('show-message', handleShowMessage as EventListener)
})

defineExpose({ showMessage })
</script>

<style scoped>
.global-message {
  position: fixed;
  top: 20px;
  right: 20px;
  z-index: 1000;
  max-width: 400px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
  border-radius: 8px;
  overflow: hidden;
  animation: slideIn 0.3s ease-out;
}

.message-content {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 16px;
}

.message-text {
  flex: 1;
  font-weight: 500;
}

.close-btn {
  background: none;
  border: none;
  font-size: 20px;
  cursor: pointer;
  margin-left: 12px;
  opacity: 0.7;
  transition: opacity 0.2s;
}

.close-btn:hover {
  opacity: 1;
}

/* 메시지 타입별 스타일 */
.global-message.success {
  background: linear-gradient(135deg, #d4edda 0%, #c3e6cb 100%);
  color: #155724;
  border-left: 4px solid #28a745;
}

.global-message.error {
  background: linear-gradient(135deg, #f8d7da 0%, #f5c6cb 100%);
  color: #721c24;
  border-left: 4px solid #dc3545;
}

.global-message.info {
  background: linear-gradient(135deg, #d1ecf1 0%, #bee5eb 100%);
  color: #0c5460;
  border-left: 4px solid #17a2b8;
}

@keyframes slideIn {
  from {
    transform: translateX(100%);
    opacity: 0;
  }
  to {
    transform: translateX(0);
    opacity: 1;
  }
}
</style>
