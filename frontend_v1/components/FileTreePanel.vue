<template>
  <div>
    <FileTree
      :tree="tree"
      :base-path="''"
      :selected-file="selectedFile"
      @file-click="p=>emit('file-select',p)"
      @directory-create="d=>emit('directory-create',d)"
      @directory-rename="d=>emit('directory-rename',d)"
      @directory-delete="d=>emit('directory-delete',d)"
      @file-move="d=>emit('file-move',d)"
    />
  </div>
</template>
<script setup lang="ts">
import FileTree from '~/components/FileTree.vue'
const props = defineProps<{ tree: any; selectedFile?: string | null }>()
const emit = defineEmits(['file-select','directory-create','directory-rename','directory-delete','file-move'])
</script>
