<template>
  <div class="h-screen flex flex-col">
    <!-- Top Navigation Bar -->
    <nav class="bg-white shadow-sm border-b z-10">
      <div class="max-w-full mx-auto px-4 sm:px-6 lg:px-8">
        <div class="flex justify-between h-16">
          <div class="flex items-center">
            <a href="/" class="text-xl font-bold text-gray-900">
              Mirae
            </a>
          </div>
          <div class="flex items-center space-x-4">
            <a href="/textbook" class="text-gray-700 hover:text-gray-900 px-3 py-2 rounded-md text-sm font-medium">
              커리큘럼
            </a>
            <a href="/knowledge-base" class="text-gray-700 hover:text-gray-900 px-3 py-2 rounded-md text-sm font-medium">
              지식베이스
            </a>
            <a href="/login" class="text-gray-700 hover:text-gray-900 px-3 py-2 rounded-md text-sm font-medium">
              로그인
            </a>
          </div>
        </div>
      </div>
    </nav>

    <!-- Main Content -->
    <div class="flex h-full bg-gray-100">
      <!-- Left Sidebar: File Tree -->
      <div class="w-1/4 bg-white border-r overflow-y-auto p-4">
        <h2 class="text-lg font-bold mb-4">지식베이스 탐색기</h2>
        
        <div v-if="isInitialLoading" class="text-center py-8">
          <div class="animate-spin rounded-full h-6 w-6 border-b-2 border-blue-500 mx-auto mb-2"></div>
          <p class="text-sm text-gray-500">로딩 중...</p>
        </div>
        
        <div v-else>
          <!-- Textbook Section -->
          <div class="mb-6">
            <h3 class="text-md font-semibold mb-2 text-blue-600">📚 Textbook</h3>
                         <FileTree 
               :tree="treeData?.textbook || {}" 
               :base-path="'textbook'" 
               @file-click="handleFileSelect" 
               :selected-file="selectedFile?.path"
               @directory-create="handleDirectoryCreate"
               @directory-rename="handleDirectoryRename"
               @directory-delete="handleDirectoryDelete"
               @file-move="handleFileMove"
             />
          </div>
          
          <!-- Slides Section -->
          <div class="mb-6">
            <h3 class="text-md font-semibold mb-2 text-green-600">📊 Slides</h3>
                         <FileTree 
               :tree="treeData?.slides || {}" 
               :base-path="'slides'" 
               @file-click="handleFileSelect" 
               :selected-file="selectedFile?.path"
               @directory-create="handleDirectoryCreate"
               @directory-rename="handleDirectoryRename"
               @directory-delete="handleDirectoryDelete"
               @file-move="handleFileMove"
             />
          </div>
          
                     <!-- Documents Section -->
           <div class="mb-6">
             <h3 class="text-md font-semibold mb-2 text-purple-600">📄 Documents</h3>
                          <FileTree 
                :tree="treeData?.documents || {}" 
                :base-path="'documents'" 
                @file-click="handleFileSelect" 
                :selected-file="selectedFile?.path"
                @directory-create="handleDirectoryCreate"
                @directory-rename="handleDirectoryRename"
                @directory-delete="handleDirectoryDelete"
                @file-move="handleFileMove"
              />
           </div>
           
           <!-- Other Files Section -->
           <div class="mb-6">
             <h3 class="text-md font-semibold mb-2 text-gray-600">📁 기타 파일</h3>
                          <FileTree 
                :tree="treeData || {}" 
                :base-path="''" 
                @file-click="handleFileSelect" 
                :selected-file="selectedFile?.path" 
                :exclude-dirs="['textbook', 'slides', 'documents']"
                @directory-create="handleDirectoryCreate"
                @directory-rename="handleDirectoryRename"
                @directory-delete="handleDirectoryDelete"
                @file-move="handleFileMove"
              />
           </div>
        </div>
      </div>

      <!-- Right Panel: Content Viewer -->
      <div class="w-3/4 flex flex-col">
        <!-- Action Bar -->
        <div class="bg-white border-b p-2 flex items-center space-x-4">
          <!-- Search Panel -->
          <div class="flex-1 flex items-center space-x-2">
            <div class="flex-1 relative">
              <input
                v-model="searchQuery"
                @input="debouncedSearch"
                @keyup.enter="performSearch"
                type="text"
                placeholder="파일명 또는 내용으로 검색..."
                class="w-full px-3 py-1 border border-gray-300 rounded text-sm focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
              />
              <div v-if="isSearching" class="absolute right-2 top-1/2 transform -translate-y-1/2">
                <div class="animate-spin rounded-full h-3 w-3 border-b-2 border-blue-500"></div>
              </div>
            </div>
            
            <select
              v-model="searchType"
              @change="performSearch"
              class="px-2 py-1 border border-gray-300 rounded text-sm focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
            >
              <option value="both">전체</option>
              <option value="filename">파일명</option>
              <option value="content">내용</option>
            </select>
            
            <button
              @click="performSearch"
              :disabled="!searchQuery.trim() || isSearching"
              class="px-3 py-1 bg-blue-500 text-white rounded text-sm hover:bg-blue-600 disabled:bg-gray-400 disabled:cursor-not-allowed"
            >
              검색
            </button>
            
            <button
              v-if="searchQuery"
              @click="clearSearch"
              class="px-2 py-1 text-gray-500 hover:text-gray-700 text-sm"
            >
              ✕
            </button>
          </div>
          
          <button @click="createNewDoc" class="px-3 py-1 bg-blue-500 text-white rounded text-sm hover:bg-blue-600">새 문서</button>
          <button v-if="!editMode" @click="editCurrentDoc" :disabled="!selectedFile?.path" class="px-3 py-1 bg-yellow-500 text-white rounded text-sm hover:bg-yellow-600 disabled:bg-gray-400">편집</button>
          <button v-if="editMode" @click="cancelEdit" class="px-3 py-1 bg-gray-500 text-white rounded text-sm hover:bg-gray-600">취소</button>
          <button @click="saveContent" :disabled="!isDirty" class="px-3 py-1 bg-green-500 text-white rounded text-sm hover:bg-green-600 disabled:bg-gray-400">저장</button>
          <button @click="deleteCurrentDoc" :disabled="!selectedFile?.path" class="px-3 py-1 bg-red-500 text-white rounded text-sm hover:bg-red-600 disabled:bg-gray-400">삭제</button>
          <span v-if="statusMessage" class="text-sm text-gray-600">{{ statusMessage }}</span>
        </div>

        <!-- Main Content Area -->
        <div class="flex-grow relative">
          <!-- Search Results Overlay -->
          <div 
            v-if="searchResults.length > 0" 
            class="absolute inset-0 bg-white z-10 flex flex-col"
          >
            <!-- Search Results Header -->
            <div class="flex items-center justify-between p-4 border-b">
              <h3 class="text-lg font-medium text-gray-700">
                검색 결과 ({{ searchResults.length }}개) - "{{ searchQuery }}"
              </h3>
              <button
                @click="clearSearch"
                class="px-3 py-1 text-sm text-gray-500 hover:text-gray-700 border border-gray-300 rounded hover:bg-gray-50"
              >
                검색 초기화
              </button>
            </div>
            
            <!-- Search Results Grid -->
            <div class="flex-grow p-4 overflow-y-auto">
              <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
                <div
                  v-for="result in searchResults"
                  :key="result.path"
                  @click="selectFileFromSearch(result.path)"
                  class="p-4 border border-gray-200 rounded-lg hover:bg-gray-50 cursor-pointer transition-all duration-200 hover:shadow-md"
                >
                  <div class="flex items-start justify-between mb-3">
                    <div class="flex-1">
                      <div class="flex items-center space-x-2 mb-2">
                        <span class="font-medium text-blue-600 truncate">{{ result.name }}</span>
                        <div class="flex space-x-1">
                          <span
                            v-if="result.match_type.includes('filename')"
                            class="px-2 py-1 text-xs bg-blue-100 text-blue-800 rounded"
                          >
                            파일명
                          </span>
                          <span
                            v-if="result.match_type.includes('content')"
                            class="px-2 py-1 text-xs bg-green-100 text-green-800 rounded"
                          >
                            내용
                          </span>
                        </div>
                      </div>
                      <div class="text-sm text-gray-500 mb-3">{{ result.path }}</div>
                      <div
                        v-if="result.context"
                        class="text-sm text-gray-700 bg-gray-100 p-3 rounded max-h-32 overflow-y-auto"
                        v-html="highlightQuery(result.context)"
                      ></div>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
          
          <!-- No Results -->
          <div v-else-if="hasSearched && searchQuery" class="absolute inset-0 bg-white z-10 flex items-center justify-center">
            <div class="text-center text-gray-500">
              <div class="text-4xl mb-4">🔍</div>
              <h3 class="text-lg font-medium mb-2">검색 결과가 없습니다</h3>
              <p class="text-sm mb-4">"{{ searchQuery }}"에 대한 검색 결과를 찾을 수 없습니다.</p>
              <button
                @click="clearSearch"
                class="px-4 py-2 bg-blue-500 text-white rounded hover:bg-blue-600"
              >
                검색 초기화
              </button>
            </div>
          </div>

          <!-- Content Area (fade out when searching) -->
          <div 
            class="h-full transition-opacity duration-300"
            :class="{ 'opacity-30': searchResults.length > 0 || (hasSearched && searchQuery) }"
          >
            <div v-if="editMode" class="h-full flex flex-col p-6">
              <div class="flex-shrink-0 mb-4">
                <label class="block text-sm font-medium text-gray-700 mb-2">파일 경로</label>
                <input v-model="editablePath" type="text" placeholder="파일 경로 (예: part1/new-doc.md)" class="w-full px-3 py-2 border rounded focus:ring-2 focus:ring-blue-500 focus:border-blue-500" />
              </div>
              <div class="flex-grow flex flex-col">
                <label class="block text-sm font-medium text-gray-700 mb-2">마크다운 내용</label>
                <textarea 
                  v-model="editableContent" 
                  class="flex-grow w-full p-3 border rounded font-mono resize-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500" 
                  placeholder="# 여기에 마크다운 내용을 입력하세요...

## 제목 2

```python
print('Hello, World!')
```"
                ></textarea>
              </div>
            </div>
            <div v-else class="h-full p-6 overflow-y-auto">
              <div v-if="isInitialLoading" class="text-center">
                <div class="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-500 mx-auto mb-4"></div>
                <p>지식베이스를 로딩 중...</p>
              </div>
              <div v-else-if="isLoading" class="text-center">
                <p>파일을 로딩 중...</p>
              </div>
              <div v-else-if="selectedFile?.path" class="prose max-w-none" v-html="renderedMarkdown"></div>
              <div v-else class="text-center text-gray-500">
                <p>왼쪽에서 파일을 선택하여 내용을 확인하세요.</p>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
definePageMeta({
  layout: false
});

const config = useRuntimeConfig();
const apiBase = config.public.apiBaseUrl || 'http://localhost:8000';
const apiKey = 'my_mcp_eagle_tiger';

// State
const treeData = ref({});
const selectedFile = ref(null);
const isInitialLoading = ref(true);
const isLoading = ref(false);
const editMode = ref(false);
const isDirty = ref(false);
const statusMessage = ref('');

// Edit state
const editableContent = ref('');
const editablePath = ref('');

// Search state
const searchQuery = ref('');
const searchType = ref('both');
const searchResults = ref([]);
const isSearching = ref(false);
const hasSearched = ref(false);

// Computed
const renderedMarkdown = computed(() => {
  if (!selectedFile.value?.content) return '';
  // Simple markdown rendering - replace with proper markdown parser if needed
  return selectedFile.value.content
    .replace(/^# (.+)$/gm, '<h1>$1</h1>')
    .replace(/^## (.+)$/gm, '<h2>$1</h2>')
    .replace(/^### (.+)$/gm, '<h3>$1</h3>')
    .replace(/\*\*(.+?)\*\*/g, '<strong>$1</strong>')
    .replace(/\*(.+?)\*/g, '<em>$1</em>')
    .replace(/`(.+?)`/g, '<code>$1</code>')
    .replace(/\n/g, '<br>');
});

// Methods
const loadKnowledgeBaseStructure = async () => {
  try {
    const response = await fetch(`${apiBase}/api/kb/tree`, {
      headers: { 'X-API-Key': apiKey }
    });
    
    if (!response.ok) throw new Error('Failed to load structure');
    
    const data = await response.json();
    treeData.value = data;
  } catch (error) {
    console.error('Error loading structure:', error);
    statusMessage.value = '구조 로딩 실패';
  } finally {
    isInitialLoading.value = false;
  }
};

const handleFileSelect = async (path) => {
  try {
    isLoading.value = true;
    statusMessage.value = '';
    
    const response = await fetch(`${apiBase}/api/kb/item?path=${encodeURIComponent(path)}`, {
      headers: { 'X-API-Key': apiKey }
    });
    
    if (!response.ok) throw new Error('Failed to load file');
    
    const data = await response.json();
    selectedFile.value = data;
    editMode.value = false;
    editableContent.value = data.content;
    editablePath.value = data.path;
    isDirty.value = false;
  } catch (error) {
    console.error('Error loading file:', error);
    statusMessage.value = '파일 로딩 실패';
  } finally {
    isLoading.value = false;
  }
};

const createNewDoc = () => {
  selectedFile.value = null;
  editMode.value = true;
  editableContent.value = '';
  editablePath.value = '';
  isDirty.value = false;
  statusMessage.value = '';
};

const editCurrentDoc = () => {
  if (!selectedFile.value?.path) return;
  editMode.value = true;
  editableContent.value = selectedFile.value.content;
  editablePath.value = selectedFile.value.path;
  isDirty.value = false;
  statusMessage.value = '';
};

const cancelEdit = () => {
  editMode.value = false;
  editableContent.value = selectedFile.value?.content || '';
  editablePath.value = selectedFile.value?.path || '';
  isDirty.value = false;
  statusMessage.value = '';
};

const saveContent = async () => {
  try {
    const method = selectedFile.value?.path ? 'PUT' : 'POST';
    const response = await fetch(`${apiBase}/api/kb/item`, {
      method,
      headers: {
        'Content-Type': 'application/json',
        'X-API-Key': apiKey
      },
      body: JSON.stringify({
        path: editablePath.value,
        type: 'file',
        content: editableContent.value
      })
    });
    
    if (!response.ok) {
      const errorData = await response.json();
      throw new Error(`Failed to save: ${response.status} ${errorData.detail || 'Unknown error'}`);
    }
    
    const data = await response.json();
    selectedFile.value = data;
    editMode.value = false;
    isDirty.value = false;
    statusMessage.value = '저장 완료';
    
    // Reload structure to reflect changes
    await loadKnowledgeBaseStructure();
  } catch (error) {
    console.error('Error saving file:', error);
    statusMessage.value = `저장 실패: ${error.message}`;
  }
};

const deleteCurrentDoc = async () => {
  if (!selectedFile.value?.path) return;
  
  if (!confirm('정말로 이 파일을 삭제하시겠습니까?')) return;
  
  try {
    const response = await fetch(`${apiBase}/api/kb/item?path=${encodeURIComponent(selectedFile.value.path)}`, {
      method: 'DELETE',
      headers: { 'X-API-Key': apiKey }
    });
    
    if (!response.ok) throw new Error('Failed to delete');
    
    statusMessage.value = '삭제 완료';
    selectedFile.value = null;
    editMode.value = false;
    
    // Reload structure
    await loadKnowledgeBaseStructure();
  } catch (error) {
    console.error('Error deleting file:', error);
    statusMessage.value = '삭제 실패';
  }
};

// Directory management functions
const handleDirectoryCreate = async (data) => {
  try {
    console.log('Creating directory:', data);
    
    const response = await fetch(`${apiBase}/api/kb/directory`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-API-Key': apiKey
      },
      body: JSON.stringify({
        path: data.path,
        type: 'directory'
      })
    });
    
    if (!response.ok) {
      const errorData = await response.json();
      throw new Error(`Failed to create directory: ${response.status} ${errorData.detail || 'Unknown error'}`);
    }
    
    const result = await response.json();
    console.log('Directory created:', result);
    
    statusMessage.value = '디렉토리 생성 완료';
    
    // Reload structure
    await loadKnowledgeBaseStructure();
  } catch (error) {
    console.error('Error creating directory:', error);
    statusMessage.value = `디렉토리 생성 실패: ${error.message}`;
  }
};

const handleDirectoryRename = async (data) => {
  try {
    console.log('Renaming directory:', data);
    
    const response = await fetch(`${apiBase}/api/kb/directory`, {
      method: 'PUT',
      headers: {
        'Content-Type': 'application/json',
        'X-API-Key': apiKey
      },
      body: JSON.stringify({
        path: data.oldPath,
        new_path: data.newPath
      })
    });
    
    if (!response.ok) {
      const errorData = await response.json();
      throw new Error(`Failed to rename directory: ${response.status} ${errorData.detail || 'Unknown error'}`);
    }
    
    const result = await response.json();
    console.log('Directory renamed:', result);
    
    statusMessage.value = '디렉토리 이름 변경 완료';
    
    // Reload structure
    await loadKnowledgeBaseStructure();
  } catch (error) {
    console.error('Error renaming directory:', error);
    statusMessage.value = `디렉토리 이름 변경 실패: ${error.message}`;
  }
};

const handleDirectoryDelete = async (data) => {
  try {
    console.log('Deleting item:', data);
    
    if (data.type === 'file') {
      // Delete file
      const response = await fetch(`${apiBase}/api/kb/item?path=${encodeURIComponent(data.path)}`, {
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
      const response = await fetch(`${apiBase}/api/kb/directory?path=${encodeURIComponent(data.path)}&recursive=true`, {
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
    console.log('Moving file:', data);
    
    const requestBody = {
      path: data.oldPath,
      new_path: data.newPath
    };
    console.log('Request body:', requestBody);
    
    const response = await fetch(`${apiBase}/api/kb/move`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-API-Key': apiKey
      },
      body: JSON.stringify(requestBody)
    });
    
    console.log('Response status:', response.status);
    
    if (!response.ok) {
      const errorData = await response.json();
      console.error('Error response:', errorData);
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

// Debounce function implementation
const useDebounceFn = (fn, delay) => {
  let timeoutId;
  return (...args) => {
    clearTimeout(timeoutId);
    timeoutId = setTimeout(() => fn(...args), delay);
  };
};

const debouncedSearch = useDebounceFn(() => {
  if (searchQuery.value.trim()) {
    performSearch();
  } else {
    clearSearch();
  }
}, 300);

const performSearch = async () => {
  if (!searchQuery.value.trim()) return;
  
  try {
    isSearching.value = true;
    hasSearched.value = true;
    
    const response = await fetch(`${apiBase}/api/kb/search?query=${encodeURIComponent(searchQuery.value)}&search_type=${searchType.value}`, {
      headers: { 'X-API-Key': apiKey }
    });
    
    if (!response.ok) throw new Error('Search failed');
    
    const data = await response.json();
    searchResults.value = data.results;
  } catch (error) {
    console.error('Search error:', error);
    searchResults.value = [];
  } finally {
    isSearching.value = false;
  }
};

const clearSearch = () => {
  searchQuery.value = '';
  searchResults.value = [];
  hasSearched.value = false;
};

const selectFileFromSearch = (path) => {
  handleFileSelect(path);
  clearSearch();
};

const highlightQuery = (text) => {
  if (!searchQuery.value) return text;
  const regex = new RegExp(`(${searchQuery.value})`, 'gi');
  return text.replace(regex, '<mark class="bg-yellow-200">$1</mark>');
};

// Watchers
watch(editableContent, () => {
  isDirty.value = true;
});

watch(editablePath, () => {
  isDirty.value = true;
});

// Lifecycle
onMounted(() => {
  loadKnowledgeBaseStructure();
});
</script>

<style scoped>
.prose {
  line-height: 1.6;
}

.prose h1, .prose h2, .prose h3, .prose h4, .prose h5, .prose h6 {
  margin-top: 1.5em;
  margin-bottom: 0.5em;
  font-weight: 600;
}

.prose h1 {
  font-size: 2em;
  border-bottom: 2px solid #e5e7eb;
  padding-bottom: 0.5em;
}

.prose h2 {
  font-size: 1.5em;
  border-bottom: 1px solid #e5e7eb;
  padding-bottom: 0.3em;
}

.prose h3 {
  font-size: 1.25em;
}

.prose p {
  margin-bottom: 1em;
}

.prose ul, .prose ol {
  margin-bottom: 1em;
  padding-left: 1.5em;
}

.prose li {
  margin-bottom: 0.25em;
}

.prose code {
  background-color: #f3f4f6;
  padding: 0.125em 0.25em;
  border-radius: 0.25em;
  font-family: 'Courier New', monospace;
  font-size: 0.875em;
}

.prose pre {
  background-color: #1f2937;
  color: #f9fafb;
  padding: 1em;
  border-radius: 0.5em;
  overflow-x: auto;
  margin: 1em 0;
}

.prose pre code {
  background-color: transparent;
  padding: 0;
  color: inherit;
}

.prose blockquote {
  border-left: 4px solid #e5e7eb;
  padding-left: 1em;
  margin: 1em 0;
  color: #6b7280;
}

.prose table {
  width: 100%;
  border-collapse: collapse;
  margin: 1em 0;
}

.prose th, .prose td {
  border: 1px solid #e5e7eb;
  padding: 0.5em;
  text-align: left;
}

.prose th {
  background-color: #f9fafb;
  font-weight: 600;
}

.prose a {
  color: #3b82f6;
  text-decoration: none;
}

.prose a:hover {
  text-decoration: underline;
}

.prose img {
  max-width: 100%;
  height: auto;
  border-radius: 0.5em;
  margin: 1em 0;
}

/* Custom scrollbar for content area */
.overflow-y-auto::-webkit-scrollbar {
  width: 6px;
}

.overflow-y-auto::-webkit-scrollbar-track {
  background: #f1f1f1;
}

.overflow-y-auto::-webkit-scrollbar-thumb {
  background: #c1c1c1;
  border-radius: 3px;
}

.overflow-y-auto::-webkit-scrollbar-thumb:hover {
  background: #a8a8a8;
}
</style>
