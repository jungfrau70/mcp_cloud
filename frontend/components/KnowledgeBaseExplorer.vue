<template>
  <div class="p-4 space-y-4">
    <template v-if="mode !== 'search'">
      <h2 class="text-lg font-semibold" v-if="mode!=='search'">지식베이스</h2>
    </template>
    <template v-if="mode==='tree'">
      <div class="flex items-center justify-between">
        <div></div>
        <button @click="showTrending=true" class="mb-2 px-2 py-1 text-xs border rounded">관심 카테고리</button>
      </div>
      <div v-if="isInitialLoading" class="text-center py-8 text-sm text-gray-500">로딩 중…</div>
      <FileTreePanel
        v-else
        :tree="treeData"
        :selected-file="props.selectedFile ? ('mcp_knowledge_base/' + stripBasePath(props.selectedFile)) : null"
        @file-select="handleFileSelect"
        @file-open="handleFileOpen"
        @directory-create="handleDirectoryCreate"
        @directory-rename="handleDirectoryRename"
        @directory-delete="handleDirectoryDelete"
        @file-move="handleFileMove"
      />
    </template>
    <template v-else>
        <SearchPanel :api-base="apiBase" :api-key="apiKey" @open="emit('file-select',$event)" />
      <div class="border rounded bg-white overflow-hidden">
        <div v-if="isInitialLoading" class="text-center py-8 text-sm text-gray-500">로딩 중…</div>
        <FileTreePanel
          v-else
          :tree="treeData"
          :selected-file="props.selectedFile ? ('mcp_knowledge_base/' + stripBasePath(props.selectedFile)) : null"
          @file-select="handleFileSelect"
          @file-open="handleFileOpen"
          @directory-create="handleDirectoryCreate"
          @directory-rename="handleDirectoryRename"
          @directory-delete="handleDirectoryDelete"
          @file-move="handleFileMove"
        />
      </div>
      <button
        class="fixed bottom-6 right-6 z-20 rounded-full w-14 h-14 bg-blue-600 text-white shadow-lg hover:bg-blue-700"
        title="외부자료 기반 문서 생성"
        @click="showGenModal=true"
      >
        +
      </button>
      <ExternalGeneratePanel v-if="showGenModal" @open="onExternalGenerated" @close="showGenModal=false" />
    </template>
  </div>
  <TrendingCategoriesModal v-if="showTrending" @close="showTrending=false" />
</template>

<script setup>
import { ref, onMounted, computed } from 'vue'
import { stripBasePath } from '~/utils/path'
import { useTaskStore } from '~/stores/task'
import FileTreePanel from '~/components/FileTreePanel.vue'
import SearchPanel from '~/components/SearchPanel.vue'
import ExternalGeneratePanel from '~/components/ExternalGeneratePanel.vue'
import TrendingCategoriesModal from '~/components/TrendingCategoriesModal.vue'

const emit = defineEmits(['file-select']);

const props = defineProps({
  // mode: 'full' (검색+트리), 'search' (검색 패널), 'tree' (파일 트리만)
  mode: { type: String, default: 'full' },
  selectedFile: { type: String, default: '' }
});

const config = useRuntimeConfig()
function resolveApiBase(){
  const configured = (config.public?.apiBaseUrl) || 'http://localhost:8000'
  if (typeof window !== 'undefined'){
    try{
      const u = new URL(configured)
      const browserHost = window.location.hostname
      if (u.hostname !== 'localhost' && u.hostname !== '127.0.0.1' && u.hostname !== browserHost){
        const port = u.port || '8000'
        return `${window.location.protocol}//${browserHost}:${port}`
      }
    }catch{ /* ignore */ }
  }
  return configured
}
const apiBase = resolveApiBase()
const apiKey = 'my_mcp_eagle_tiger'
const taskStore = useTaskStore()
const showGenModal = ref(false)
const showTrending = ref(false)

// 탭 제거 (검색 + 플로팅 버튼만 유지)

// State (공통)
const treeData = ref({ 'mcp_knowledge_base': { files: [] } });
const selectedFile = ref(null);
// 외부에서 활성 경로가 바뀌면 내부 선택 상태도 동기화해 트리 강조 및 펼침 유도
watch(() => props.selectedFile, (p)=>{ selectedFile.value = p ? ('mcp_knowledge_base/' + stripBasePath(p)) : null }, { immediate: true })
const isInitialLoading = ref(true);
const statusMessage = ref('');

// removed legacy search & generation state (handled by child panels)

// Methods
const loadKnowledgeBaseStructure = async () => {
  try {
    const response = await fetch(`${apiBase}/api/v1/knowledge-base/tree`, {
      headers: { 'X-API-Key': apiKey }
    });
    
    if (!response.ok) throw new Error('Failed to load structure');
    
    const data = await response.json();
    treeData.value = { 'mcp_knowledge_base': data };
  } catch (error) {
    console.error('Error loading structure:', error);
    statusMessage.value = '구조 로딩 실패';
    // keep default root so FileTree is visible even when backend is down
    if(!treeData.value || !Object.keys(treeData.value).length){
      treeData.value = { 'mcp_knowledge_base': { files: [] } }
    }
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
  const p = stripBasePath(path)
  emit('file-select', p);
};

// 더블클릭으로 파일 열기 → 전체 화면에 문서 표시 요청
const handleFileOpen = (path) => {
  const p = stripBasePath(path)
  emit('file-select', p)
};

function onExternalGenerated(path){
  showGenModal.value = false
  if(path) emit('file-select', stripBasePath(path))
}

// Directory management functions
const handleDirectoryCreate = async (data) => {
  try {
    console.log('Creating item:', data);
    
    const response = await fetch(`${apiBase}/api/v1/knowledge-base/item`, {
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
    
    const response = await fetch(`${apiBase}/api/v1/knowledge-base/item`, {
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
      const response = await fetch(`${apiBase}/api/v1/knowledge-base/item?path=${encodeURIComponent(stripBasePath(data.path))}`, {
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
      const response = await fetch(`${apiBase}/api/v1/knowledge-base/directory?path=${encodeURIComponent(stripBasePath(data.path))}&recursive=true`, {
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
    
    const response = await fetch(`${apiBase}/api/v1/knowledge-base/move`, {
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
  // 검색 모드에서도 트리 로드 필요
  if (props.mode === 'tree' || props.mode === 'full' || props.mode === 'search') loadKnowledgeBaseStructure(); else isInitialLoading.value = false
  taskStore.subscribe()
})
</script>
