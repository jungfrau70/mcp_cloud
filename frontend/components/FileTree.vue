<template>
  <div 
    class="file-tree" 
    :class="{ 'upload-enabled': enableUpload }"
    @dragover="handleUploadDragOver"
    @dragenter="handleUploadDragEnter"
    @drop="handleUploadDrop"
  >
    <!-- Upload Area (only show when upload is enabled and no files are selected) -->
    <div v-if="enableUpload && depth === 0" class="upload-area">
      <input 
        ref="fileInput"
        type="file" 
        multiple 
        @change="handleFileSelect"
        style="display: none"
        accept="*/*"
      />
      <button 
        @click="$refs.fileInput.click()" 
        class="upload-button"
        title="파일 업로드"
      >
        📁 파일 업로드
      </button>
    </div>
    
    <ul>
      <li v-for="(item, name) in sortedTree" :key="name">
        <div 
          @click="toggle(name)" 
          @contextmenu="showDirectoryMenu($event, name, item)"
          @dragover="handleDragOver($event, name, item)"
          @drop="handleDrop($event, name, item)"
          @dragenter="handleDragEnter($event, name, item)"
          @dragleave="handleDragLeave($event, name, item)"
          @dragstart="handleDirectoryDragStart($event, name, item)"
          :class="['tree-item', { 'is-directory': isDirectory(item), 'is-open': isOpen(name), 'drag-over': dragOverTarget === name }]"
          :style="{ 'padding-left': (depth * 15) + 'px' }"
          :draggable="isDirectory(item)"
        >
          <span v-if="isDirectory(item)" class="icon">{{ isOpen(name) ? '▼' : '▶' }}</span>
          <span v-else class="icon">📄</span>
          <span class="name" :class="{ 'hidden-item': name.startsWith('.') }">{{ name }}</span>
          <div v-if="isDirectory(item)" class="directory-actions">
            <button @click.stop="showCreateContextMenu($event, name)" class="action-btn" title="새 항목 생성">+</button>
          </div>
        </div>
        <FileTree 
          v-if="isDirectory(item) && isOpen(name)" 
          :tree="item" 
          :depth="depth + 1"
          :base-path="constructPath(name)"
          :selected-file="selectedFile"
          @file-click="emitFileClick"
          @directory-create="handleDirectoryCreate"
          @directory-rename="handleDirectoryRename"
          @directory-delete="handleDirectoryDelete"
          @file-move="handleFileMove"
        />
      </li>
      <li v-for="file in files" :key="file.name || file">
        <div 
          @click="emitFileClick(file.path || constructPath(file))" 
          @dblclick="emit('file-open', (file.path || constructPath(file)))"
          @contextmenu="showFileMenu($event, file)"
          @dragstart="handleDragStart($event, file)"
          @dragover="handleDragOver($event, null, null)"
          @drop="handleDrop($event, null, null)"
          :class="['tree-item', 'is-file', { 'is-selected': selectedFile === (file.path || constructPath(file)) }]"
          :data-path="(file.path || constructPath(file))"
          :style="{ 'padding-left': (depth * 15) + 'px' }"
          draggable="true"
        >
          <span class="icon">📄</span>
          <span class="name" :class="{ 'hidden-item': (file.name || file).startsWith('.') }">{{ file.name || file }}</span>
        </div>
      </li>
    </ul>

    <!-- Directory Context Menu -->
    <div v-if="showDirectoryContextMenu" 
         :style="{ left: contextMenuX + 'px', top: contextMenuY + 'px' }" 
         class="context-menu">
      <div @click="createDirectory" class="context-menu-item">📁 새 디렉토리</div>
      <div @click="createFile" class="context-menu-item">📄 새 파일</div>
      <div class="context-menu-divider"></div>
      <div @click="renameDirectory" class="context-menu-item">✏️ 이름 변경</div>
      <div @click="deleteDirectory" class="context-menu-item text-red-600">🗑️ 삭제</div>
    </div>

    <!-- File Context Menu -->
    <div v-if="showFileContextMenu" 
         :style="{ left: contextMenuX + 'px', top: contextMenuY + 'px' }" 
         class="context-menu">
      <div v-if="!isSelectedInTrash" @click="renameFile" class="context-menu-item">✏️ 이름 변경</div>
      <div v-if="!isSelectedInTrash" @click="deleteFile" class="context-menu-item text-red-600">🗑️ 삭제(휴지통으로)</div>
      <div v-if="isSelectedInTrash" @click="restoreFile" class="context-menu-item">↩️ 복구</div>
      <div v-if="isSelectedInTrash" @click="purgeFile" class="context-menu-item text-red-600">❌ 영구 삭제</div>
    </div>

    <!-- Create Menu -->
    <div v-if="showCreateMenu" 
         :style="{ left: contextMenuX + 'px', top: contextMenuY + 'px' }" 
         class="context-menu">
      <div @click="createDirectory" class="context-menu-item">📁 새 디렉토리</div>
      <div @click="createFile" class="context-menu-item">📄 새 파일</div>
    </div>

    <!-- Rename Dialog -->
    <div v-if="showRenameDialog" class="modal-overlay" @click="closeRenameDialog">
      <div class="modal-content" @click.stop>
        <h3 class="modal-title">이름 변경</h3>
        <input 
          v-model="newName" 
          @keyup.enter="confirmRename"
          @keyup.esc="closeRenameDialog"
          class="modal-input" 
          placeholder="새 이름을 입력하세요"
          ref="renameInput"
        />
        <div class="modal-actions">
          <button @click="confirmRename" class="btn-primary">확인</button>
          <button @click="closeRenameDialog" class="btn-secondary">취소</button>
        </div>
      </div>
    </div>

    <!-- Create Dialog -->
    <div v-if="showCreateDialog" class="modal-overlay" @click="closeCreateDialog">
      <div class="modal-content" @click.stop>
        <h3 class="modal-title">{{ createType === 'directory' ? '새 디렉토리' : '새 파일' }}</h3>
        <input 
          v-model="newName" 
          @keyup.enter="confirmCreate"
          @keyup.esc="closeCreateDialog"
          class="modal-input" 
          :placeholder="createType === 'directory' ? '디렉토리 이름' : '파일 이름'"
          ref="createInput"
        />
        <div class="modal-actions">
          <button @click="confirmCreate" class="btn-primary">생성</button>
          <button @click="closeCreateDialog" class="btn-secondary">취소</button>
        </div>
      </div>
    </div>

    <!-- Upload Dialog -->
    <div v-if="showUploadDialog" class="modal-overlay" @click="cancelUpload">
      <div class="modal-content upload-dialog" @click.stop>
        <h3 class="modal-title">파일 업로드</h3>
        
        <!-- Upload Path -->
        <div class="upload-section">
          <label class="upload-label">업로드 경로:</label>
          <input 
            v-model="uploadPath" 
            class="modal-input" 
            placeholder="업로드할 디렉토리 경로"
          />
        </div>
        
        <!-- File List -->
        <div class="upload-section">
          <label class="upload-label">선택된 파일 ({{ uploadFiles.length }}개):</label>
          <div class="file-list">
            <div v-for="(file, index) in uploadFiles" :key="index" class="file-item">
              <span class="file-name">{{ file.name }}</span>
              <span class="file-size">({{ formatFileSize(file.size) }})</span>
            </div>
          </div>
        </div>
        
        <!-- Options -->
        <div class="upload-section">
          <label class="checkbox-label">
            <input 
              type="checkbox" 
              v-model="overwriteFiles"
            />
            기존 파일 덮어쓰기
          </label>
        </div>
        
        <!-- Progress -->
        <div v-if="isUploading" class="upload-section">
          <div class="progress-bar">
            <div class="progress-fill" :style="{ width: uploadProgress + '%' }"></div>
          </div>
          <div class="progress-text">{{ uploadProgress }}% 업로드 중...</div>
        </div>
        
        <!-- Actions -->
        <div class="modal-actions">
          <button 
            @click="uploadFilesToServer" 
            class="btn-primary"
            :disabled="isUploading || uploadFiles.length === 0"
          >
            {{ isUploading ? '업로드 중...' : '업로드' }}
          </button>
          <button @click="cancelUpload" class="btn-secondary" :disabled="isUploading">취소</button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, watch, nextTick, onMounted, onUnmounted } from 'vue';

const props = defineProps({
  tree: {
    type: Object,
    required: true
  },
  depth: {
    type: Number,
    default: 0
  },
  basePath: {
    type: String,
    default: ''
  },
  selectedFile: {
    type: String,
    default: null
  },
  excludeDirs: {
    type: Array,
    default: () => []
  },
  showHiddenFiles: {
    type: Boolean,
    default: true
  },
  enableUpload: {
    type: Boolean,
    default: false
  },
  uploadPath: {
    type: String,
    default: ''
  }
});

const emit = defineEmits(['file-click', 'file-open', 'directory-create', 'directory-rename', 'directory-delete', 'file-move', 'file-upload']);

const openDirectories = ref({});
const expandedBySelectionOnce = ref(false)

// Context menu state
const showDirectoryContextMenu = ref(false);
const showFileContextMenu = ref(false);
const showCreateMenu = ref(false);
const contextMenuX = ref(0);
const contextMenuY = ref(0);
const selectedItem = ref(null);
const isSelectedInTrash = computed(() => {
  try{
    if(!selectedItem.value) return false
    const p = (selectedItem.value.item?.path) || constructPath(selectedItem.value.name)
    return typeof p === 'string' && /(^|\/)\.trash(\/|$)/.test(p)
  }catch{ return false }
})

// Dialog state
const showRenameDialog = ref(false);
const showCreateDialog = ref(false);
const newName = ref('');
const createType = ref('file');
const renameInput = ref(null);
const createInput = ref(null);

// Drag and drop state
const dragOverTarget = ref(null);
const draggedItem = ref(null);

// Upload state
const isUploading = ref(false);
const uploadProgress = ref(0);
const uploadFiles = ref([]);
const showUploadDialog = ref(false);
const uploadPath = ref('');
const overwriteFiles = ref(false);

const isDirectory = (item) => {
  return typeof item === 'object' && item !== null && !Array.isArray(item);
};

const files = computed(() => {
  const fileList = props.tree.files || [];
  return fileList.filter(file => {
    const fileName = file.name || file;
    return props.showHiddenFiles || !fileName.startsWith('.');
  });
});

const directories = computed(() => {
  const dirs = { ...props.tree };
  delete dirs.files;
  return dirs;
});

const sortedTree = computed(() => {
    const dirs = { ...props.tree };
    delete dirs.files;
    return Object.keys(dirs)
      .filter(key => props.showHiddenFiles || !key.startsWith('.'))
      .sort()
      .reduce((acc, key) => {
        acc[key] = dirs[key];
        return acc;
      }, {});
});

const toggle = (name) => {
  if (isDirectory(props.tree[name])) {
    openDirectories.value[name] = !openDirectories.value[name];
  }
};

const isOpen = (name) => {
  return !!openDirectories.value[name];
};

const constructPath = (fileName) => {
  return props.basePath ? `${props.basePath}/${fileName}` : fileName;
};

// Drag and drop functions
const handleDragStart = (event, file) => {
  const filePath = file.path || constructPath(file);
  console.log('Drag start (file):', { file, filePath });
  event.dataTransfer.setData('text/plain', filePath);
  event.dataTransfer.effectAllowed = 'move';
  draggedItem.value = { type: 'file', data: file };
};

const handleDirectoryDragStart = (event, name, item) => {
  if (!isDirectory(item)) return;
  const dirPath = constructPath(name);
  console.log('Drag start (directory):', { name, dirPath });
  event.dataTransfer.setData('text/plain', dirPath);
  event.dataTransfer.effectAllowed = 'move';
  draggedItem.value = { type: 'directory', data: { name, path: dirPath } };
};

const handleDragOver = (event, name, item) => {
  event.preventDefault();
  event.dataTransfer.dropEffect = 'move';
  
  // Only allow dropping on directories
  if (isDirectory(item)) {
    dragOverTarget.value = name;
  }
};

const handleDragEnter = (event, name, item) => {
  event.preventDefault();
  if (isDirectory(item)) {
    dragOverTarget.value = name;
  }
};

const handleDragLeave = (event, name, item) => {
  event.preventDefault();
  if (dragOverTarget.value === name) {
    dragOverTarget.value = null;
  }
};

const handleDrop = (event, name, item) => {
  event.preventDefault();
  dragOverTarget.value = null;
  
  const draggedPath = event.dataTransfer.getData('text/plain');
  console.log('Drop event:', { draggedPath, name, item, isDirectory: isDirectory(item) });
  
  // Only allow dropping on directories
  if (isDirectory(item) && draggedPath) {
    const targetPath = constructPath(name);
    // Prevent dropping a directory into itself or its descendants
    if (draggedItem.value?.type === 'directory'){
      if (targetPath === draggedPath || targetPath.startsWith(draggedPath + '/')){
        console.warn('Drop prevented: cannot move a directory into itself or its descendant');
        return;
      }
    }
    const leafName = draggedPath.split('/').pop();
    const newPath = `${targetPath}/${leafName}`;
    
    console.log('Emitting file-move event:', { oldPath: draggedPath, newPath: newPath });
    
    // Emit the move event
    emit('file-move', {
      oldPath: draggedPath,
      newPath: newPath
    });
  } else {
    console.log('Drop not allowed:', { isDirectory: isDirectory(item), draggedPath });
  }
};

const emitFileClick = (path) => {
    // path가 이미 전체 경로인 경우 그대로 사용
    if (typeof path === 'string' && path.includes('/')) {
        emit('file-click', path);
    } else if (typeof path === 'object' && path.path) {
        // file 객체에서 path 속성을 사용
        emit('file-click', path.path);
    } else {
        // fallback: 현재 basePath와 결합
        const fullPath = props.basePath ? `${props.basePath}/${path}` : path;
        emit('file-click', fullPath);
    }
}

// Context menu handlers
const showDirectoryMenu = (event, name, item) => {
  event.preventDefault();
  selectedItem.value = { name, type: 'directory', item };
  contextMenuX.value = event.clientX;
  contextMenuY.value = event.clientY;
  showDirectoryContextMenu.value = true;
  showFileContextMenu.value = false;
  showCreateMenu.value = false;
};

const showFileMenu = (event, file) => {
  event.preventDefault();
  selectedItem.value = { name: file.name || file, type: 'file', item: file };
  contextMenuX.value = event.clientX;
  contextMenuY.value = event.clientY;
  showFileContextMenu.value = true;
  showDirectoryContextMenu.value = false;
  showCreateMenu.value = false;
};

const showCreateContextMenu = (event, dirName) => {
  event.preventDefault();
  selectedItem.value = { name: dirName, type: 'create' };
  contextMenuX.value = event.clientX;
  contextMenuY.value = event.clientY;
  showCreateMenu.value = true;
  showDirectoryContextMenu.value = false;
  showFileContextMenu.value = false;
};

// Close all context menus
const closeContextMenus = () => {
  showDirectoryContextMenu.value = false;
  showFileContextMenu.value = false;
  showCreateMenu.value = false;
};

// Dialog handlers
const createDirectory = () => {
  closeContextMenus();
  createType.value = 'directory';
  newName.value = '';
  showCreateDialog.value = true;
  nextTick(() => createInput.value?.focus());
};

const createFile = () => {
  closeContextMenus();
  createType.value = 'file';
  newName.value = '';
  showCreateDialog.value = true;
  nextTick(() => createInput.value?.focus());
};

const renameDirectory = () => {
  closeContextMenus();
  newName.value = selectedItem.value.name;
  showRenameDialog.value = true;
  nextTick(() => renameInput.value?.focus());
};

const renameFile = () => {
  closeContextMenus();
  newName.value = selectedItem.value.name;
  showRenameDialog.value = true;
  nextTick(() => renameInput.value?.focus());
};

const deleteDirectory = () => {
  closeContextMenus();
  if (confirm(`정말로 '${selectedItem.value.name}' 디렉토리를 삭제하시겠습니까?`)) {
    const path = constructPath(selectedItem.value.name);
    emit('directory-delete', { path, type: 'directory' });
  }
};

const deleteFile = () => {
  closeContextMenus();
  if (confirm(`정말로 '${selectedItem.value.name}' 파일을 삭제하시겠습니까?`)) {
    const path = selectedItem.value.item.path || constructPath(selectedItem.value.name);
    emit('directory-delete', { path, type: 'file' });
  }
};

const restoreFile = () => {
  closeContextMenus();
  try{
    const orig = selectedItem.value?.item?.original_path
    const cur = selectedItem.value?.item?.path || constructPath(selectedItem.value?.name)
    if(!cur){ return }
    // '/.trash/<timestamp>/' 세그먼트를 제거하여 원래 경로로 복구
    const dest = orig || cur.replace(/(^|\/)\.trash\/[^\/]+\//, '$1')
    emit('directory-rename', { oldPath: cur, newPath: dest, type: 'file' })
  }catch{}
}

const purgeFile = () => {
  closeContextMenus();
  try{
    const cur = selectedItem.value?.item?.path || constructPath(selectedItem.value?.name)
    if(!cur) return
    if(!confirm('이 항목을 영구 삭제하시겠습니까? (되돌릴 수 없음)')) return
    emit('directory-delete', { path: cur, type: 'file' })
  }catch{}
}

const confirmCreate = () => {
  const raw = newName.value.trim()
  if (!raw) return

  // Determine target directory based on selected directory (if any)
  const selectedDirPath = (selectedItem.value && (selectedItem.value.type === 'directory' || selectedItem.value.type === 'create'))
    ? constructPath(selectedItem.value.name)
    : (props.basePath || '')

  if (createType.value === 'file') {
    // Enforce single .md extension (strip any existing or duplicate extensions)
    // 1) remove trailing .md repetitions
    let base = raw.replace(/(\.md)+$/i, '')
    // 2) if another extension exists at the end, strip it
    base = base.replace(/\.[^\\/.]+$/i, '')
    const finalName = `${base}.md`

    const path = selectedDirPath ? `${selectedDirPath}/${finalName}` : finalName
    emit('directory-create', { path, type: 'file' })
  } else {
    // Directory creation: create inside selected directory if provided
    const path = selectedDirPath ? `${selectedDirPath}/${raw}` : raw
    emit('directory-create', { path, type: 'directory' })
  }
  closeCreateDialog()
};

const confirmRename = () => {
  const raw = newName.value.trim();
  if (!raw) return;
  // allow no-op rename
  if (raw === selectedItem.value.name) { closeRenameDialog(); return; }

  const oldPath = selectedItem.value.type === 'file' 
    ? (selectedItem.value.item.path || constructPath(selectedItem.value.name))
    : constructPath(selectedItem.value.name);

  let finalName = raw;
  if (selectedItem.value.type === 'file') {
    let base = raw.replace(/(\.md)+$/i, '');
    base = base.replace(/\.[^\\/.]+$/i, '');
    finalName = `${base}.md`;
    const dirPrefix = oldPath.substring(0, oldPath.lastIndexOf('/') + 1);
    const newPath = `${dirPrefix}${finalName}`;
    emit('directory-rename', { oldPath, newPath, type: 'file' });
  } else {
    const newPath = constructPath(finalName);
    emit('directory-rename', { oldPath, newPath, type: selectedItem.value.type });
  }
  closeRenameDialog();
};

const closeCreateDialog = () => {
  showCreateDialog.value = false;
  newName.value = '';
};

const closeRenameDialog = () => {
  showRenameDialog.value = false;
  newName.value = '';
};

// Upload functions
const handleFileSelect = (event) => {
  const files = Array.from(event.target.files);
  if (files.length > 0) {
    uploadFiles.value = files;
    uploadPath.value = props.uploadPath || props.basePath;
    showUploadDialog.value = true;
  }
};

const handleUploadDragOver = (event) => {
  if (!props.enableUpload) return;
  event.preventDefault();
  event.dataTransfer.dropEffect = 'copy';
};

const handleUploadDragEnter = (event) => {
  if (!props.enableUpload) return;
  event.preventDefault();
};

const handleUploadDrop = (event) => {
  if (!props.enableUpload) return;
  event.preventDefault();
  
  const files = Array.from(event.dataTransfer.files);
  if (files.length > 0) {
    uploadFiles.value = files;
    uploadPath.value = props.uploadPath || props.basePath;
    showUploadDialog.value = true;
  }
};

const uploadFilesToServer = async () => {
  if (uploadFiles.value.length === 0) return;
  
  isUploading.value = true;
  uploadProgress.value = 0;
  
  try {
    const formData = new FormData();
    uploadFiles.value.forEach(file => {
      formData.append('files', file);
    });
    formData.append('path', uploadPath.value);
    formData.append('overwrite', overwriteFiles.value.toString());
    
    const response = await fetch('/api/v1/knowledge-base/upload-multiple', {
      method: 'POST',
      body: formData,
      headers: {
        'X-API-Key': 'my_mcp_eagle_tiger' // TODO: Get from config
      }
    });
    
    if (!response.ok) {
      throw new Error(`Upload failed: ${response.status}`);
    }
    
    const result = await response.json();
    uploadProgress.value = 100;
    
    // Emit upload success event
    emit('file-upload', {
      success: true,
      result: result,
      path: uploadPath.value
    });
    
    // Close dialog and reset
    showUploadDialog.value = false;
    uploadFiles.value = [];
    uploadPath.value = '';
    overwriteFiles.value = false;
    
  } catch (error) {
    console.error('Upload error:', error);
    emit('file-upload', {
      success: false,
      error: error.message,
      path: uploadPath.value
    });
  } finally {
    isUploading.value = false;
    uploadProgress.value = 0;
  }
};

const cancelUpload = () => {
  showUploadDialog.value = false;
  uploadFiles.value = [];
  uploadPath.value = '';
  overwriteFiles.value = false;
  isUploading.value = false;
  uploadProgress.value = 0;
};

const formatFileSize = (bytes) => {
  if (bytes === 0) return '0 Bytes';
  const k = 1024;
  const sizes = ['Bytes', 'KB', 'MB', 'GB'];
  const i = Math.floor(Math.log(bytes) / Math.log(k));
  return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
};

// Event handlers for child components
const handleDirectoryCreate = (data) => {
  emit('directory-create', data);
};

const handleDirectoryRename = (data) => {
  emit('directory-rename', data);
};

const handleDirectoryDelete = (data) => {
  emit('directory-delete', data);
};

const handleFileMove = (data) => {
  emit('file-move', data);
};

// Close context menus when clicking outside
const handleClickOutside = (event) => {
  if (!event.target.closest('.context-menu') && !event.target.closest('.tree-item')) {
    closeContextMenus();
  }
};

function expandBySelected(newPath){
  if (!newPath) return
  const base = props.basePath ? props.basePath + '/' : ''
  if (base && newPath.indexOf(base) !== 0) return
  const remaining = base ? newPath.slice(base.length) : newPath
  const parts = remaining.split('/').filter(Boolean)
  if (parts.length > 1) {
    const first = parts[0]
    if (directories.value[first]) {
      openDirectories.value[first] = true
    }
  }
  nextTick(() => {
    try{
      const el = document.querySelector(`.tree-item.is-file[data-path="${CSS.escape(newPath)}"]`)
      if(el && typeof el.scrollIntoView === 'function'){
        el.scrollIntoView({ block: 'nearest' })
      }
    }catch{}
  })
}

// Auto-open nested directories so that selected file becomes visible
watch(() => props.selectedFile, (newPath) => { expandBySelected(newPath) }, { immediate: true })
// Re-expand after tree data changes (e.g., initial load or refresh)
watch(() => props.tree, () => { expandBySelected(props.selectedFile) }, { deep: true })

// Add global click listener
onMounted(() => {
  document.addEventListener('click', handleClickOutside);
});

onUnmounted(() => {
  document.removeEventListener('click', handleClickOutside);
});
</script>

<style scoped>
.file-tree ul {
  list-style: none;
  padding: 0;
  margin: 0;
}

.tree-item {
  padding: 4px 8px;
  cursor: pointer;
  display: flex;
  align-items: center;
  border-radius: 4px;
  position: relative;
}

.tree-item:hover {
  background-color: #f0f4f8;
}

.tree-item .icon {
  margin-right: 8px;
  width: 16px;
  text-align: center;
}

.tree-item.is-directory .name {
  font-weight: 500;
}

.tree-item.is-file.is-selected {
  background-color: #e0e7ff;
  font-weight: 600;
}

.tree-item.drag-over {
  background-color: #dbeafe;
  border: 2px dashed #3b82f6;
  border-radius: 4px;
}

.tree-item.is-file {
  cursor: grab;
}

.tree-item.is-file:active {
  cursor: grabbing;
}

.hidden-item {
  opacity: 0.6;
  font-style: italic;
  color: #6b7280;
}

.directory-actions {
  margin-left: auto;
  opacity: 0;
  transition: opacity 0.2s;
}

.tree-item:hover .directory-actions {
  opacity: 1;
}

.action-btn {
  background: none;
  border: none;
  cursor: pointer;
  padding: 2px 6px;
  border-radius: 3px;
  font-size: 12px;
  color: #6b7280;
}

.action-btn:hover {
  background-color: #e5e7eb;
  color: #374151;
}

.context-menu {
  position: fixed;
  background: white;
  border: 1px solid #d1d5db;
  border-radius: 6px;
  box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
  z-index: 1000;
  min-width: 150px;
}

.context-menu-item {
  padding: 8px 12px;
  cursor: pointer;
  font-size: 14px;
}

.context-menu-item:hover {
  background-color: #f3f4f6;
}

.context-menu-divider {
  height: 1px;
  background-color: #e5e7eb;
  margin: 4px 0;
}

.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background-color: rgba(0, 0, 0, 0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1001;
}

.modal-content {
  background: white;
  padding: 24px;
  border-radius: 8px;
  min-width: 300px;
  box-shadow: 0 10px 25px rgba(0, 0, 0, 0.2);
}

.modal-title {
  margin: 0 0 16px 0;
  font-size: 18px;
  font-weight: 600;
}

.modal-input {
  width: 100%;
  padding: 8px 12px;
  border: 1px solid #d1d5db;
  border-radius: 4px;
  font-size: 14px;
  margin-bottom: 16px;
}

.modal-input:focus {
  outline: none;
  border-color: #3b82f6;
  box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.1);
}

.modal-actions {
  display: flex;
  gap: 8px;
  justify-content: flex-end;
}

.btn-primary {
  background-color: #3b82f6;
  color: white;
  border: none;
  padding: 8px 16px;
  border-radius: 4px;
  cursor: pointer;
  font-size: 14px;
}

.btn-primary:hover {
  background-color: #2563eb;
}

.btn-secondary {
  background-color: #6b7280;
  color: white;
  border: none;
  padding: 8px 16px;
  border-radius: 4px;
  cursor: pointer;
  font-size: 14px;
}

.btn-secondary:hover {
  background-color: #4b5563;
}

/* Upload styles */
.upload-enabled {
  position: relative;
}

.upload-area {
  padding: 16px;
  border: 2px dashed #d1d5db;
  border-radius: 8px;
  margin-bottom: 16px;
  text-align: center;
  background-color: #f9fafb;
  transition: all 0.2s ease;
}

.upload-area:hover {
  border-color: #3b82f6;
  background-color: #eff6ff;
}

.upload-button {
  background-color: #3b82f6;
  color: white;
  border: none;
  padding: 8px 16px;
  border-radius: 6px;
  cursor: pointer;
  font-size: 14px;
  transition: background-color 0.2s ease;
}

.upload-button:hover {
  background-color: #2563eb;
}

.upload-dialog {
  max-width: 500px;
  width: 90vw;
}

.upload-section {
  margin-bottom: 16px;
}

.upload-label {
  display: block;
  font-weight: 500;
  margin-bottom: 8px;
  color: #374151;
}

.file-list {
  max-height: 200px;
  overflow-y: auto;
  border: 1px solid #d1d5db;
  border-radius: 4px;
  padding: 8px;
  background-color: #f9fafb;
}

.file-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 4px 0;
  border-bottom: 1px solid #e5e7eb;
}

.file-item:last-child {
  border-bottom: none;
}

.file-name {
  font-weight: 500;
  color: #374151;
  flex: 1;
  margin-right: 8px;
  word-break: break-all;
}

.file-size {
  color: #6b7280;
  font-size: 12px;
  white-space: nowrap;
}

.checkbox-label {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 14px;
  color: #374151;
  cursor: pointer;
}

.checkbox-label input[type="checkbox"] {
  margin: 0;
}

.progress-bar {
  width: 100%;
  height: 8px;
  background-color: #e5e7eb;
  border-radius: 4px;
  overflow: hidden;
  margin-bottom: 8px;
}

.progress-fill {
  height: 100%;
  background-color: #3b82f6;
  transition: width 0.3s ease;
}

.progress-text {
  text-align: center;
  font-size: 12px;
  color: #6b7280;
}
</style>