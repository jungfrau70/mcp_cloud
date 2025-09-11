<template>
  <div>
    <FileTree
      :tree="tree"
      :base-path="''"
      :selected-file="selectedFile || undefined"
      :show-hidden-files="showHiddenFiles"
      :enable-upload="enableUpload"
      :upload-path="uploadPath"
      @file-click="(p: string) => emit('file-select', p)"
      @file-open="(p: string) => emit('file-open', p)"
      @directory-create="(d: any) => emit('directory-create', d)"
      @directory-rename="(d: any) => emit('directory-rename', d)"
      @directory-delete="(d: any) => emit('directory-delete', d)"
      @file-move="(d: any) => emit('file-move', d)"
      @file-upload="(d: any) => emit('file-upload', d)"
    />
  </div>
</template>
<script setup lang="ts">
import FileTree from '~/components/FileTree.vue'
const props = defineProps<{ 
  tree: any; 
  selectedFile?: string | null; 
  showHiddenFiles?: boolean;
  enableUpload?: boolean;
  uploadPath?: string;
}>()

const emit = defineEmits<{
  'file-select': [path: string]
  'file-open': [path: string]
  'directory-create': [data: any]
  'directory-rename': [data: any]
  'directory-delete': [data: any]
  'file-move': [data: any]
  'file-upload': [data: any]
}>()
</script>
