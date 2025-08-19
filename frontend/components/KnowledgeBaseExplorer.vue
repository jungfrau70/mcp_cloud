<template>
  <div class="p-4">
    <h2 class="text-lg font-bold mb-4">지식베이스 탐색기</h2>
    
    <div v-if="isInitialLoading" class="text-center py-8">
      <div class="animate-spin rounded-full h-6 w-6 border-b-2 border-blue-500 mx-auto mb-2"></div>
      <p class="text-sm text-gray-500">로딩 중...</p>
    </div>
    
    <div v-else>
      <FileTree 
        :tree="treeData" 
        :base-path="''" 
        @file-click="handleFileSelect" 
        :selected-file="selectedFile?.path"
        @directory-create="handleDirectoryCreate"
        @directory-rename="handleDirectoryRename"
        @directory-delete="handleDirectoryDelete"
        @file-move="handleFileMove"
      />
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import FileTree from '~/components/FileTree.vue';

const emit = defineEmits(['file-select']);

const config = useRuntimeConfig();
const apiBase = config.public.apiBaseUrl || 'http://localhost:8000';
const apiKey = 'my_mcp_eagle_tiger';

// State
const treeData = ref({});
const selectedFile = ref(null);
const isInitialLoading = ref(true);
const statusMessage = ref('');

const stripBasePath = (path) => {
  const basePath = 'mcp_knowledge_base/';
  if (path.startsWith(basePath)) {
    return path.substring(basePath.length);
  }
  return path;
};

// Methods
const loadKnowledgeBaseStructure = async () => {
  try {
    const response = await fetch(`${apiBase}/api/kb/tree`, {
      headers: { 'X-API-Key': apiKey }
    });
    
    if (!response.ok) throw new Error('Failed to load structure');
    
    const data = await response.json();
    treeData.value = { 'mcp_knowledge_base': data };
  } catch (error) {
    console.error('Error loading structure:', error);
    statusMessage.value = '구조 로딩 실패';
  } finally {
    isInitialLoading.value = false;
  }
};

const handleFileSelect = (path) => {
  emit('file-select', path);
};

// Directory management functions
const handleDirectoryCreate = async (data) => {
  try {
    console.log('Creating item:', data);
    
    const response = await fetch(`${apiBase}/api/kb/item`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-API-Key': apiKey
      },
      body: JSON.stringify({
        path: stripBasePath(data.path),
        type: data.type,
        content: data.type === 'file' ? '' : undefined
      })
    });
    
    if (!response.ok) {
      const errorData = await response.json();
      throw new Error(`Failed to create ${data.type}: ${response.status} ${errorData.detail || 'Unknown error'}`);
    }
    
    const result = await response.json();
    console.log(`${data.type} created:`, result);
    
    statusMessage.value = `${data.type === 'file' ? '파일' : '디렉토리'} 생성 완료`;
    
    // Reload structure
    await loadKnowledgeBaseStructure();
  } catch (error) {
    console.error(`Error creating ${data.type}:`, error);
    statusMessage.value = `${data.type === 'file' ? '파일' : '디렉토리'} 생성 실패: ${error.message}`;
  }
};

const handleDirectoryRename = async (data) => {
  try {
    console.log('Renaming item:', data);
    
    const response = await fetch(`${apiBase}/api/kb/item`, {
      method: 'PATCH',
      headers: {
        'Content-Type': 'application/json',
        'X-API-Key': apiKey
      },
      body: JSON.stringify({
        path: stripBasePath(data.oldPath),
        new_path: stripBasePath(data.newPath)
      })
    });
    
    if (!response.ok) {
      const errorData = await response.json();
      throw new Error(`Failed to rename item: ${response.status} ${errorData.detail || 'Unknown error'}`);
    }
    
    const result = await response.json();
    console.log('Item renamed:', result);
    
    statusMessage.value = '이름 변경 완료';
    
    // Reload structure
    await loadKnowledgeBaseStructure();
  } catch (error) {
    console.error('Error renaming item:', error);
    statusMessage.value = `이름 변경 실패: ${error.message}`;
  }
};

const handleDirectoryDelete = async (data) => {
  try {
    console.log('Deleting item:', data);
    
    if (data.type === 'file') {
      // Delete file
      const response = await fetch(`${apiBase}/api/kb/item?path=${encodeURIComponent(stripBasePath(data.path))}`, {
        method: 'DELETE',
        headers: { 'X-API-Key': apiKey }
      });
      
      if (!response.ok) {
        const errorData = await response.json();
        throw new Error(`Failed to delete file: ${response.status} ${errorData.detail || 'Unknown error'}`);
      }
      
      statusMessage.value = '파일 삭제 완료';
    } else {
      // Delete directory
      const response = await fetch(`${apiBase}/api/kb/directory?path=${encodeURIComponent(stripBasePath(data.path))}&recursive=true`, {
        method: 'DELETE',
        headers: { 'X-API-Key': apiKey }
      });
      
      if (!response.ok) {
        const errorData = await response.json();
        throw new Error(`Failed to delete directory: ${response.status} ${errorData.detail || 'Unknown error'}`);
      }
      
      statusMessage.value = '디렉토리 삭제 완료';
    }
    
    // Reload structure
    await loadKnowledgeBaseStructure();
  } catch (error) {
    console.error('Error deleting item:', error);
    statusMessage.value = `삭제 실패: ${error.message}`;
  }
};

const handleFileMove = async (data) => {
  try {
    console.log('Moving file (original data):', data);

    const oldPath = stripBasePath(data.oldPath);
    const newPath = stripBasePath(data.newPath);

    console.log('Moving file (stripped paths):', { oldPath, newPath });
    
    const requestBody = {
      path: oldPath,
      new_path: newPath
    };
    
    const response = await fetch(`${apiBase}/api/kb/move`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-API-Key': apiKey
      },
      body: JSON.stringify(requestBody)
    });
    
    if (!response.ok) {
      const errorData = await response.json();
      throw new Error(`Failed to move file: ${response.status} ${errorData.detail || 'Unknown error'}`);
    }
    
    const result = await response.json();
    console.log('File moved:', result);
    
    statusMessage.value = '파일 이동 완료';
    
    // Reload structure
    await loadKnowledgeBaseStructure();
  } catch (error) {
    console.error('Error moving file:', error);
    statusMessage.value = `파일 이동 실패: ${error.message}`;
  }
};

// Lifecycle
onMounted(() => {
  loadKnowledgeBaseStructure();
});
</script>