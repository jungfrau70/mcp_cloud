<template>
  <div class="p-4 space-y-4 h-full flex flex-col">
    <template v-if="mode !== 'search'">
      <h2 class="text-lg font-semibold" v-if="mode!=='search'">지식베이스</h2>
    </template>
    <template v-if="mode==='tree'">
      <div class="flex items-center justify-between">
        <div></div>
        <div class="flex items-center gap-2">
          <button @click="showAdmin=true; loadAdminPanel()" class="mb-2 px-2 py-1 text-xs border rounded" title="슬라이드 디렉토리 설정">설정</button>
          <button @click="showTrending=true" class="mb-2 px-2 py-1 text-xs border rounded">관심 카테고리</button>
        </div>
      </div>
      <div class="flex-1 min-h-0 overflow-auto">
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
    </template>
    <template v-else>
        <div class="flex items-center justify-between mb-2">
          <div></div>
          <div class="flex items-center gap-2">
            <button @click="showAdmin=true; loadAdminPanel()" class="px-2 py-1 text-xs border rounded" title="슬라이드 디렉토리 설정">설정</button>
            <button @click="showTrending=true" class="px-2 py-1 text-xs border rounded">관심 카테고리</button>
          </div>
        </div>
        <SearchPanel :api-base="apiBase" :api-key="apiKey" @open="emit('file-select',$event)" />
      <div class="border rounded bg-white flex-1 min-h-0 overflow-hidden">
        <div class="h-full min-h-0 overflow-auto">
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
  <!-- Admin Selection Modal -->
  <div v-if="showAdmin" class="fixed inset-0 bg-black/30 flex items-center justify-center z-50">
    <div class="bg-white rounded shadow-lg w-[520px] max-w-[92vw] p-4">
      <div class="flex items-center justify-between mb-2">
        <h4 class="text-sm font-semibold">슬라이드 디렉토리 선택</h4>
        <button class="text-gray-500 hover:text-black" @click="showAdmin=false">✕</button>
      </div>
      <div class="text-xs text-gray-600 mb-3">mcp_knowledge_base 하위의 디렉토리 중 슬라이드로 사용할 루트를 선택하세요.</div>
      <div v-if="allDirsLoading" class="text-sm text-gray-500">불러오는 중…</div>
      <div v-else class="max-h-60 overflow-auto border rounded p-2 space-y-1">
        <label v-for="dir in allKbDirs" :key="dir" class="flex items-center gap-2 text-sm">
          <input type="checkbox" :value="dir" v-model="selectedDirs" />
          <span class="font-mono">{{ dir }}</span>
        </label>
        <div v-if="!allKbDirs.length" class="text-xs text-gray-400">선택 가능한 디렉토리가 없습니다.</div>
      </div>
      <div class="mt-3 flex items-center justify-end gap-2">
        <button class="px-3 py-1 text-xs border rounded" @click="showAdmin=false">취소</button>
        <button class="px-3 py-1 text-xs bg-blue-600 text-white rounded disabled:opacity-50" :disabled="saving" @click="saveSelection">저장</button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, computed, watch } from 'vue'
import { useRuntimeConfig } from '#app'
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
  const configured = (config.public?.apiBaseUrl) || '/api'
  if (typeof window !== 'undefined'){
    try{
      const u = new URL(configured)
      const browserHost = window.location.hostname
      if (u.origin === 'null') return configured
      if (u.hostname !== 'localhost' && u.hostname !== '127.0.0.1' && u.hostname !== 'api.gostock.us' && u.hostname !== browserHost){
        const port = u.port || '8000'
        const scheme = u.protocol.replace(':','') || 'https'
        return `${scheme}://${browserHost}:${port}`
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
const showAdmin = ref(false)
const allKbDirs = ref([])
const allDirsLoading = ref(false)
const selectedDirs = ref([])
const saving = ref(false)

// 탭 제거 (검색 + 플로팅 버튼만 유지)

// State (공통)
const treeData = ref({ 'mcp_knowledge_base': { files: [] } });
// 지식베이스는 전체 트리를 그대로 표시
const selectedFile = ref(null);
// 외부에서 활성 경로가 바뀌면 내부 선택 상태도 동기화해 트리 강조 및 펼침 유도
watch(() => props.selectedFile, (p)=>{ selectedFile.value = p ? ('mcp_knowledge_base/' + stripBasePath(p)) : null }, { immediate: true })
const isInitialLoading = ref(true);
const statusMessage = ref('');

// removed legacy search & generation state (handled by child panels)

// Methods
const loadKnowledgeBaseStructure = async () => {
  try {
    const response = await fetch(`${apiBase}/v1/knowledge-base/tree`, {
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

// Admin helpers
async function loadAdminPanel(){
  await Promise.all([loadAllKbDirs(), loadSelection()])
}
async function loadAllKbDirs(){
  allDirsLoading.value = true
  try{
    const r = await fetch(`${apiBase}/v1/knowledge-base/tree`, { headers: { 'X-API-Key': apiKey }})
    const data = await r.json()
    // 재귀적으로 모든 하위 디렉토리 경로 수집 (files 키 제외)
    const collected = []
    function walk(node, prefix = ''){
      if(!node || typeof node !== 'object') return
      for(const key of Object.keys(node)){
        if(key === 'files') continue
        const next = prefix ? `${prefix}/${key}` : key
        collected.push(next)
        walk(node[key], next)
      }
    }
    walk(data)
    allKbDirs.value = collected.sort()
  } finally { allDirsLoading.value = false }
}
async function loadSelection(){
  try{
    const r = await fetch(`${apiBase}/v1/slides/selection`, { headers: { 'X-API-Key': apiKey }})
    const d = await r.json()
    selectedDirs.value = Array.isArray(d?.selected_dirs) ? d.selected_dirs : []
  } catch { selectedDirs.value = [] }
}
async function saveSelection(){
  saving.value = true
  try{
    await fetch(`${apiBase}/v1/slides/selection`, { method: 'POST', headers: { 'Content-Type': 'application/json', 'X-API-Key': apiKey }, body: JSON.stringify({ selected_dirs: selectedDirs.value }) })
    showAdmin.value = false
  } finally { saving.value = false }
}
</script>
