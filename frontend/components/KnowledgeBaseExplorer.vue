<template>
  <div class="p-4 space-y-4">
    <template v-if="mode !== 'search'">
      <h2 class="text-lg font-semibold" v-if="mode!=='search'">지식베이스</h2>
    </template>
    <template v-if="mode==='tree'">
      <div v-if="isInitialLoading" class="text-center py-8 text-sm text-gray-500">로딩 중…</div>
      <FileTreePanel
        v-else
        :tree="treeData"
        :selected-file="selectedFile?.path"
        @file-select="handleFileSelect"
        @directory-create="handleDirectoryCreate"
        @directory-rename="handleDirectoryRename"
        @directory-delete="handleDirectoryDelete"
        @file-move="handleFileMove"
      />
    </template>
    <template v-else>
      <div class="border-b mb-2 flex gap-4 text-sm">
        <button @click="activeTab='internal'" :class="tabBtnClass('internal')">내부 검색</button>
        <button @click="activeTab='external'" :class="tabBtnClass('external')">AI 생성</button>
      </div>
      <div v-if="activeTab==='internal'">
        <SearchPanel :api-base="apiBase" :api-key="apiKey" @open="emit('file-select',$event)" />
      </div>
      <div v-else>
        <ExternalGeneratePanel @open="emit('file-select',$event)" />
        <div class="mt-4">
          <h3 class="text-xs font-semibold text-gray-600 mb-1">최근 생성 작업</h3>
          <ul class="max-h-40 overflow-auto text-[11px] divide-y bg-white border rounded">
            <li v-for="t in taskStore.tasks" :key="t.id" class="px-2 py-1 flex items-center gap-2">
              <span class="text-gray-500" :title="t.id">{{ t.id.slice(0,8) }}</span>
              <span class="px-1 rounded" :class="taskStatusClass(t.status)">{{ t.status }}</span>
              <span>{{ t.stage || '-' }}</span>
              <span class="ml-auto text-gray-400">{{ t.progress||0 }}%</span>
              <span v-if="t.error" class="text-red-500" title="t.error">⚠</span>
            </li>
            <li v-if="!taskStore.tasks.length" class="py-2 text-center text-gray-400">기록 없음</li>
          </ul>
        </div>
      </div>
    </template>
  </div>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue'
import { useTaskStore } from '~/stores/task'
import FileTreePanel from '~/components/FileTreePanel.vue'
import SearchPanel from '~/components/SearchPanel.vue'
import ExternalGeneratePanel from '~/components/ExternalGeneratePanel.vue'

const emit = defineEmits(['file-select']);

const props = defineProps({
  // mode: 'full' (검색+트리), 'search' (검색 패널), 'tree' (파일 트리만)
  mode: { type: String, default: 'full' }
});

const config = useRuntimeConfig()
const apiBase = config.public.apiBaseUrl || 'http://localhost:8000'
const apiKey = 'my_mcp_eagle_tiger'
const taskStore = useTaskStore()

// 탭 상태
const activeTab = ref('internal')

// State (공통)
const treeData = ref({});
const selectedFile = ref(null);
const isInitialLoading = ref(true);
const statusMessage = ref('');

// removed legacy search & generation state (handled by child panels)

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

// 탭 버튼 클래스 헬퍼
const tabBtnClass = (tab) => [
  'py-2 px-3 -mb-px border-b-2 font-medium text-sm transition-colors',
  activeTab.value === tab
    ? 'border-blue-500 text-blue-600'
    : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
]

// legacy search handlers removed

// generation now handled by ExternalGeneratePanel

function taskStatusClass(st){
  if(st==='done') return 'bg-green-100 text-green-700'
  if(st==='error') return 'bg-red-100 text-red-600'
  if(st==='running') return 'bg-blue-100 text-blue-600'
  return 'bg-gray-100 text-gray-600'
}

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
onMounted(()=>{
  if (props.mode === 'tree' || props.mode === 'full') loadKnowledgeBaseStructure(); else isInitialLoading.value = false
  taskStore.subscribe()
})
</script>