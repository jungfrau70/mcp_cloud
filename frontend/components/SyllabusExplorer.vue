<template>
  <div class="p-4 select-none">
    <h3 class="text-lg font-semibold mb-4 whitespace-nowrap">
      <a href="#" @click.prevent="openCurriculum" class="hover:underline text-blue-700">
        Curriculum
      </a>
    </h3>
    <div v-if="loading">Loading...</div>
    <div v-if="error">{{ error }}</div>
    <ul v-if="tree" class="space-y-2">
      <TreeItem :item="tree" :path="''" @file-click="onFileClick" />
    </ul>

    <!-- 채팅 섹션 -->
    <div class="mt-6">
      <div class="flex items-center justify-between mb-2">
        <h4 class="text-sm font-semibold text-gray-800">채팅</h4>
        <button class="text-xs px-2 py-1 bg-blue-600 text-white rounded" @click="startNewChat">새 채팅</button>
      </div>
      <div class="mb-2">
        <input
          v-model="search"
          type="text"
          placeholder="채팅 검색"
          class="w-full px-2 py-1 border rounded text-sm"
        />
      </div>
      <ul class="space-y-1">
        <li v-for="t in filteredTopics" :key="t.id" class="flex items-center justify-between group">
          <button class="text-left text-sm w-full truncate px-2 py-1 rounded hover:bg-gray-100" @click="selectTopic(t.id)" :title="t.name">
            {{ shortTitle(t.name) }}
          </button>
          <button class="opacity-0 group-hover:opacity-100 text-gray-500 hover:text-red-600 px-2" title="삭제" @click="deleteTopic(t.id)">×</button>
        </li>
      </ul>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import TreeItem from './TreeItem.vue';

const tree = ref(null);
const loading = ref(false);
const error = ref(null);

// 통합터미널 주제 관리 동기화 (guest 기준)
const userKey = 'guest'
const storageKey = `mcp_terminal_topics_${userKey}`
const topics = ref([])
const search = ref('')

const filteredTopics = computed(() => {
  const q = (search.value || '').toLowerCase()
  if (!q) return topics.value
  return topics.value.filter(t => (t.name || '').toLowerCase().includes(q))
})

function loadTopics() {
  try {
    const saved = localStorage.getItem(storageKey)
    topics.value = saved ? JSON.parse(saved) : []
  } catch {
    topics.value = []
  }
}

function persistTopics() {
  localStorage.setItem(storageKey, JSON.stringify(topics.value))
}

function shortTitle(name) {
  if (!name) return '제목 없음'
  return name.length > 18 ? name.slice(0, 18) + '…' : name
}

function deleteTopic(id) {
  const idx = topics.value.findIndex(t => t.id === id)
  if (idx >= 0) topics.value.splice(idx, 1)
  persistTopics()
}

function selectTopic(id) {
  if (typeof window !== 'undefined') {
    window.dispatchEvent(new CustomEvent('mcp:terminal:select-topic', { detail: { id } }))
  }
}

function startNewChat() {
  const newTopic = { id: crypto.randomUUID(), name: '새 대화', conversationId: null, messages: [] }
  topics.value.unshift(newTopic)
  persistTopics()
  selectTopic(newTopic.id)
  // 우측 패널 입력창 포커스 및 목록 싱크를 위해 이벤트 발행
  if (typeof window !== 'undefined') {
    window.dispatchEvent(new Event('mcp:terminal:topics-updated'))
  }
}

const emit = defineEmits(['file-click']);

const onFileClick = (path) => {
  emit('file-click', path);
};

onMounted(async () => {
  loading.value = true;
  try {
    const apiKey = 'my_mcp_eagle_tiger';
    const response = await fetch('http://localhost:8000/api/v1/curriculum/tree', {
      headers: {
        'X-API-Key': apiKey,
      },
    });
    if (!response.ok) {
      throw new Error(`Failed to fetch curriculum tree: ${response.statusText}`);
    }
    const data = await response.json();
    // Ensure root-level Curriculum.md is hidden from the sidebar
    if (data && Array.isArray(data.files)) {
      data.files = data.files.filter((f) => f.toLowerCase() !== 'curriculum.md');
    }
    tree.value = data;
  } catch (e) {
    error.value = e.message;
  } finally {
    loading.value = false;
  }

  loadTopics()
  // 우측 패널에서 변경 시 동기화
  if (typeof window !== 'undefined') {
    window.addEventListener('mcp:terminal:topics-updated', loadTopics)
  }
});

// Open root Curriculum.md when clicking the title
const openCurriculum = () => {
  emit('file-click', 'Curriculum.md');
};
</script>
