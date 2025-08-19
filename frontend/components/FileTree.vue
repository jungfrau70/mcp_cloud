<template>
  <div class="file-tree">
    <ul>
      <li v-for="(item, name) in sortedTree" :key="name">
        <div 
          @click="toggle(name)" 
          @contextmenu="showDirectoryMenu($event, name, item)"
          @dragover="handleDragOver($event, name, item)"
          @drop="handleDrop($event, name, item)"
          @dragenter="handleDragEnter($event, name, item)"
          @dragleave="handleDragLeave($event, name, item)"
          :class="['tree-item', { 'is-directory': isDirectory(item), 'is-open': isOpen(name), 'drag-over': dragOverTarget === name }]"
          :style="{ 'padding-left': (depth * 15) + 'px' }"
        >
          <span v-if="isDirectory(item)" class="icon">{{ isOpen(name) ? '▼' : '▶' }}</span>
          <span v-else class="icon">📄</span>
          <span class="name">{{ name }}</span>
          <div v-if="isDirectory(item)" class="directory-actions">
            <button @click.stop="showCreateContextMenu($event, name)" class="action-btn" title="새 항목 생성">+</button>
          </div>
        </div>
        <FileTree 
          v-if="isDirectory(item) && isOpen(name)" 
          :tree="item" 
          :depth="depth + 1"
          :base-path="constructPath(name)"
          @file-click="emitFileClick"
          @directory-create="handleDirectoryCreate"
          @directory-rename="handleDirectoryRename"
          @directory-delete="handleDirectoryDelete"
        />
      </li>
      <li v-for="file in files" :key="file.name || file">
        <div 
          @click="emitFileClick(file.path || constructPath(file))" 
          @contextmenu="showFileMenu($event, file)"
          @dragstart="handleDragStart($event, file)"
          @dragover="handleDragOver($event, null, null)"
          @drop="handleDrop($event, null, null)"
          :class="['tree-item', 'is-file', { 'is-selected': selectedFile === (file.path || constructPath(file)) }]"
          :style="{ 'padding-left': (depth * 15) + 'px' }"
          draggable="true"
        >
          <span class="icon">📄</span>
          <span class="name">{{ file.name || file }}</span>
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
      <div @click="renameFile" class="context-menu-item">✏️ 이름 변경</div>
      <div @click="deleteFile" class="context-menu-item text-red-600">🗑️ 삭제</div>
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
  </div>
</template>

<script setup>
import { ref, computed, watch, nextTick } from 'vue';

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
  }
});

const emit = defineEmits(['file-click', 'directory-create', 'directory-rename', 'directory-delete', 'file-move']);

const openDirectories = ref({});

// Context menu state
const showDirectoryContextMenu = ref(false);
const showFileContextMenu = ref(false);
const showCreateMenu = ref(false);
const contextMenuX = ref(0);
const contextMenuY = ref(0);
const selectedItem = ref(null);

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

const isDirectory = (item) => {
  return typeof item === 'object' && item !== null && !Array.isArray(item);
};

const files = computed(() => {
  return props.tree.files || [];
});

const directories = computed(() => {
  const dirs = { ...props.tree };
  delete dirs.files;
  return dirs;
});

const sortedTree = computed(() => {
    const dirs = { ...props.tree };
    delete dirs.files;
    // excludeDirs에 있는 디렉토리 제외
    const filteredDirs = {};
    Object.keys(dirs).forEach(key => {
        if (!props.excludeDirs.includes(key)) {
            filteredDirs[key] = dirs[key];
        }
    });
    return Object.keys(filteredDirs).sort().reduce((acc, key) => {
        acc[key] = filteredDirs[key];
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
  console.log('Drag start:', { file, filePath });
  event.dataTransfer.setData('text/plain', filePath);
  event.dataTransfer.effectAllowed = 'move';
  draggedItem.value = file;
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
    const fileName = draggedPath.split('/').pop();
    const newPath = `${targetPath}/${fileName}`;
    
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

const confirmCreate = () => {
  if (newName.value.trim()) {
    const path = constructPath(newName.value.trim());
    emit('directory-create', { path, type: createType.value });
    closeCreateDialog();
  }
};

const confirmRename = () => {
  if (newName.value.trim() && newName.value.trim() !== selectedItem.value.name) {
    const oldPath = selectedItem.value.type === 'file' 
      ? (selectedItem.value.item.path || constructPath(selectedItem.value.name))
      : constructPath(selectedItem.value.name);
    const newPath = selectedItem.value.type === 'file'
      ? (oldPath.substring(0, oldPath.lastIndexOf('/') + 1) + newName.value.trim())
      : constructPath(newName.value.trim());
    
    emit('directory-rename', { oldPath, newPath, type: selectedItem.value.type });
    closeRenameDialog();
  }
};

const closeCreateDialog = () => {
  showCreateDialog.value = false;
  newName.value = '';
};

const closeRenameDialog = () => {
  showRenameDialog.value = false;
  newName.value = '';
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

// Close context menus when clicking outside
const handleClickOutside = (event) => {
  if (!event.target.closest('.context-menu') && !event.target.closest('.tree-item')) {
    closeContextMenus();
  }
};

// Auto-open directories if there's a selected file path within them
watch(() => props.selectedFile, (newPath) => {
    if (newPath) {
        const pathParts = newPath.split('/');
        if (pathParts.length > 1) {
            const dirName = pathParts[0];
            if (directories.value[dirName]) {
                openDirectories.value[dirName] = true;
            }
        }
    }
}, { immediate: true });

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
</style>