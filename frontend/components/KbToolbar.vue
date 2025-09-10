<template>
  <div class="border-b p-2 flex items-center gap-2 text-sm overflow-x-auto whitespace-nowrap" role="toolbar" :aria-label="ariaLabel">
    <button @click="$emit('save')" class="px-2 py-1 rounded bg-indigo-600 text-white" :disabled="saving" :aria-label="saveAriaLabel">{{ saveLabel }}</button>
    <button @click="$emit('cancel')" class="px-2 py-1 rounded bg-gray-200" :aria-label="cancelAriaLabel">{{ cancelLabel }}</button>
    <button @click="$emit('delete')" class="px-2 py-1 rounded bg-red-600 text-white" :aria-label="deleteAriaLabel">{{ deleteLabel }}</button>
    <span v-if="saving" class="text-gray-500">{{ savingText }}</span>
    <div class="w-px h-5 bg-gray-200 mx-1"></div>
    <slot />
    <div class="flex-1"></div>
    <slot name="right" />
  </div>
</template>

<script setup lang="ts">
const props = defineProps({
  saving: { type: Boolean, default: false },
  saveLabel: { type: String, default: 'Save' },
  cancelLabel: { type: String, default: 'Cancel' },
  deleteLabel: { type: String, default: 'Delete' },
  savingText: { type: String, default: 'Saving…' },
  ariaLabel: { type: String, default: 'Editor toolbar' },
  saveAriaLabel: { type: String, default: 'Save (Ctrl+S)' },
  cancelAriaLabel: { type: String, default: 'Cancel' },
  deleteAriaLabel: { type: String, default: 'Delete current file' }
})
defineEmits(['save','cancel','delete'])
</script>

<style scoped>
</style>


