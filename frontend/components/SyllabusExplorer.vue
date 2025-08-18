<template>
  <div class="p-4 select-none">
    <h3 class="text-lg font-semibold mb-4 whitespace-nowrap">
      <a href="#" @click.prevent="openCurriculum" class="hover:underline text-blue-700">
        Curriculum
      </a>
    </h3>
    <div v-if="loading">Loading...</div>
    <div v-if="error">{{ error }}</div>
    <ul v-if="tree" class="space-y-2">
      <TreeItem :item="tree" :path="''" @file-click="onFileClick" />
    </ul>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import TreeItem from './TreeItem.vue';

const tree = ref(null);
const loading = ref(false);
const error = ref(null);

const emit = defineEmits(['file-click']);

const onFileClick = (path) => {
  emit('file-click', path);
};

onMounted(async () => {
  loading.value = true;
  try {
    const apiKey = 'my_mcp_eagle_tiger';
    const response = await fetch('http://localhost:8000/api/v1/curriculum/tree', {
      headers: {
        'X-API-Key': apiKey,
      },
    });
    if (!response.ok) {
      throw new Error(`Failed to fetch curriculum tree: ${response.statusText}`);
    }
    const data = await response.json();
    // Ensure root-level Curriculum.md is hidden from the sidebar
    if (data && Array.isArray(data.files)) {
      data.files = data.files.filter((f) => f.toLowerCase() !== 'curriculum.md');
    }
    tree.value = data;
  } catch (e) {
    error.value = e.message;
  } finally {
    loading.value = false;
  }
});

// Open root Curriculum.md when clicking the title
const openCurriculum = () => {
  emit('file-click', 'Curriculum.md');
};
</script>
