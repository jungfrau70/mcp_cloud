<template>
  <div class="p-4">
    <!-- 헤더 (트리 전용 모드에서는 간단한 제목만) -->
    <template v-if="mode !== 'search'">
      <h2 class="text-lg font-bold mb-4" v-if="mode !== 'search'">지식베이스 탐색기</h2>
    </template>

    <!-- 검색 UI (mode !== 'tree') -->
    <template v-if="mode !== 'tree'">
      <div class="mb-4 border-b border-gray-200">
        <nav class="flex space-x-4">
          <button @click="activeTab = 'internal'" :class="tabBtnClass('internal')">내부자료 검색</button>
          <button @click="activeTab = 'external'" :class="tabBtnClass('external')">외부자료 검색 및 문서 생성</button>
        </nav>
      </div>

      <!-- 로딩 -->
      <div v-if="isInitialLoading" class="text-center py-8">
        <div class="animate-spin rounded-full h-6 w-6 border-b-2 border-blue-500 mx-auto mb-2"></div>
        <p class="text-sm text-gray-500">로딩 중...</p>
      </div>

      <!-- 내부자료 검색 탭 -->
      <div v-else-if="activeTab === 'internal'" class="space-y-4">
        <div class="flex items-center space-x-2">
          <input v-model="internalSearchQuery" type="text" placeholder="파일/내용 검색..." class="flex-1 px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500" @keyup.enter="performInternalSearch" />
          <button @click="performInternalSearch" :disabled="internalSearchLoading" class="px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700 disabled:opacity-50 flex items-center">
            <svg v-if="internalSearchLoading" class="animate-spin -ml-1 mr-2 h-4 w-4 text-white" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24"><circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4" /><path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z" /></svg>
            검색
          </button>
          <button v-if="internalSearchPerformed" @click="resetInternalSearch" class="px-3 py-2 bg-gray-100 text-gray-700 rounded-md hover:bg-gray-200">전체 보기</button>
        </div>
        <div v-if="internalSearchPerformed" class="bg-white border rounded-md divide-y max-h-80 overflow-auto">
          <div v-if="internalSearchResults.length === 0" class="p-4 text-sm text-gray-500">검색 결과가 없습니다.</div>
          <div v-for="res in internalSearchResults" :key="res.id + res.path" class="p-3 hover:bg-blue-50 cursor-pointer" @click="openSearchResult(res)">
            <div class="flex items-start justify-between">
              <div class="flex-1">
                <h4 class="text-sm font-medium" v-html="res.highlighted_title || res.title" />
                <p class="text-xs text-gray-500 mb-1">{{ res.category }} • {{ res.path }}</p>
                <p class="text-xs text-gray-600" v-html="res.highlighted_content || (res.content ? res.content.slice(0,120)+'...' : '')" />
              </div>
              <div class="ml-2 space-x-1">
                <span v-for="tag in res.tags" :key="tag" class="inline-block px-2 py-0.5 bg-gray-100 rounded text-[10px] text-gray-700">{{ tag }}</span>
              </div>
            </div>
          </div>
        </div>
        <!-- 파일 트리는 검색 패널 모드에서는 숨김 -->
      </div>

      <!-- 외부자료 검색 및 문서 생성 탭 -->
      <div v-else-if="activeTab === 'external'" class="space-y-4">
        <div class="space-y-3 bg-white p-4 border rounded-md">
          <textarea v-model="externalQuery" rows="3" placeholder="생성할 문서 주제 (예: AWS Lambda 서버리스 아키텍처)" class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500" />
          <input v-model="externalTargetPath" type="text" placeholder="저장 경로 (예: aws/lambda/lambda-architecture) - 선택" class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500" />
          <div class="flex items-center space-x-2">
            <button @click="generateExternalDocument" :disabled="!canGenerateExternal || externalGenerating" class="px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700 disabled:opacity-50 flex items-center">
              <svg v-if="externalGenerating" class="animate-spin -ml-1 mr-2 h-4 w-4 text-white" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24"><circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4" /><path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z" /></svg>
              {{ externalGenerating ? '생성 중...' : 'AI 문서 생성' }}
            </button>
            <div v-if="externalGenerating" class="text-sm text-blue-600">{{ externalStatus }}</div>
          </div>
          <div v-if="externalError" class="text-sm text-red-600">{{ externalError }}</div>
          <div v-if="externalSuccess" class="text-sm text-green-600">{{ externalSuccess }}</div>
        </div>
      </div>
    </template>

    <!-- 트리 전용 모드 (mode === 'tree') -->
    <template v-if="mode === 'tree'">
      <div v-if="isInitialLoading" class="text-center py-8">
        <div class="animate-spin rounded-full h-6 w-6 border-b-2 border-blue-500 mx-auto mb-2" />
        <p class="text-sm text-gray-500">로딩 중...</p>
      </div>
      <FileTree
        v-else
        :tree="treeData"
        :base-path="''"
        @file-click="handleFileSelect"
        :selected-file="selectedFile?.path"
        @directory-create="handleDirectoryCreate"
        @directory-rename="handleDirectoryRename"
        @directory-delete="handleDirectoryDelete"
        @file-move="handleFileMove"
      />
    </template>
  </div>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue';
import { defineProps } from 'vue';
import FileTree from '~/components/FileTree.vue';

const emit = defineEmits(['file-select']);

const props = defineProps({
  // mode: 'full' (검색+트리), 'search' (검색 패널), 'tree' (파일 트리만)
  mode: { type: String, default: 'full' }
});

const config = useRuntimeConfig();
const apiBase = config.public.apiBaseUrl || 'http://localhost:8000';
const apiKey = 'my_mcp_eagle_tiger';

// 탭 상태
const activeTab = ref('internal')

// State (공통)
const treeData = ref({});
const selectedFile = ref(null);
const isInitialLoading = ref(true);
const statusMessage = ref('');

// 내부 검색 상태
const internalSearchQuery = ref('')
const internalSearchLoading = ref(false)
const internalSearchResults = ref([])
const internalSearchPerformed = ref(false)

// 외부 문서 생성 상태
const externalQuery = ref('')
const externalTargetPath = ref('')
const externalGenerating = ref(false)
const externalStatus = ref('')
const externalError = ref('')
const externalSuccess = ref('')
const canGenerateExternal = computed(() => externalQuery.value.trim().length > 2)

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

// 내부 검색 실행
const performInternalSearch = async () => {
  if (!internalSearchQuery.value.trim()) return
  internalSearchLoading.value = true
  internalSearchPerformed.value = true
  internalSearchResults.value = []
  try {
    const resp = await fetch(`${apiBase}/api/v1/knowledge/search-enhanced`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json', 'X-API-Key': apiKey },
      body: JSON.stringify({ query: internalSearchQuery.value, category: null, limit: 20, search_type: 'both' })
    })
    if (resp.ok) {
      const data = await resp.json()
      internalSearchResults.value = data.results || []
    }
  } catch (e) {
    console.error('Internal search failed', e)
  } finally {
    internalSearchLoading.value = false
  }
}

const resetInternalSearch = () => {
  internalSearchPerformed.value = false
  internalSearchResults.value = []
  internalSearchQuery.value = ''
}

const openSearchResult = (res) => {
  if (res.path) {
    emit('file-select', res.path)
  } else {
    console.log('Open search result (no path)', res)
  }
}

// 외부 문서 생성
const generateExternalDocument = async () => {
  if (!canGenerateExternal.value) return
  externalGenerating.value = true
  externalStatus.value = '외부 자료 검색 중...'
  externalError.value = ''
  externalSuccess.value = ''
  try {
    const resp = await fetch(`${apiBase}/api/v1/knowledge/generate-from-external`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json', 'X-API-Key': apiKey },
      body: JSON.stringify({ query: externalQuery.value, target_path: externalTargetPath.value || undefined })
    })
    if (!resp.ok) {
      const err = await resp.json().catch(() => ({}))
      throw new Error(err.detail || '생성 실패')
    }
    externalStatus.value = '문서 생성 중...'
    const data = await resp.json()
    if (data.success) {
      externalSuccess.value = data.message
      externalStatus.value = '완료'
      // 트리 갱신
      await loadKnowledgeBaseStructure()
      if (data.document_path) {
        console.log('Generated document path:', data.document_path)
      }
    } else {
      throw new Error(data.message || '실패')
    }
  } catch (e) {
    externalError.value = e.message || '알 수 없는 오류'
  } finally {
    externalGenerating.value = false
  }
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
onMounted(() => {
  // 트리 모드이거나 전체 모드일 때만 구조 로딩
  if (props.mode === 'tree' || props.mode === 'full') {
    loadKnowledgeBaseStructure();
  } else {
    isInitialLoading.value = false;
  }
});
</script>