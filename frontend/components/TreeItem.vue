<template>
  <li v-for="(value, key) in item" :key="key" class="list-none">
    <!-- Directory Row -->
    <template v-if="key !== 'files'">
      <div class="flex items-center cursor-pointer select-none" @click="toggle(key)">
        <svg class="w-3 h-3 text-gray-600 transform transition-transform" :class="{ 'rotate-90': isOpen(key) }" viewBox="0 0 20 20" fill="currentColor">
          <path fill-rule="evenodd" d="M6 6l6 4-6 4V6z" clip-rule="evenodd" />
        </svg>
        <span class="font-semibold whitespace-nowrap ml-1">{{ key }}</span>
      </div>
      <ul v-show="isOpen(key)" class="ml-4 space-y-1">
        <TreeItem :item="value" :path="path + key + '/'" @file-click="(p) => $emit('file-click', p)" />
      </ul>
    </template>

    <!-- Files under current directory -->
    <template v-else>
      <ul class="ml-6 space-y-1">
        <li v-for="file in value" :key="file" class="whitespace-nowrap">
          <a href="#" @click.prevent="$emit('file-click', path + file)" class="text-blue-600 hover:underline">{{ file.replace('.md', '') }}</a>
        </li>
      </ul>
    </template>
  </li>
</template>

<script>
// Using a standard script block to define the component name for recursion.
export default {
  name: 'TreeItem'
}
</script>

<script setup>
// Using setup script for props and emits for better composition API experience.
defineProps({
  item: Object,
  path: String,
});
defineEmits(['file-click']);

import { reactive } from 'vue';

// Local open-state map for child directories. Default: collapsed (false)
const openMap = reactive({});
const isOpen = (key) => openMap[key] === true;
const toggle = (key) => {
  openMap[key] = !isOpen(key);
};
</script>