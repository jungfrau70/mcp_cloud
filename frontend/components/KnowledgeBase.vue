<template>
  <div class="grid grid-cols-1 lg:grid-cols-4 gap-6">
    <!-- Sidebar: 문서 관리 뷰 -->
    <div class="lg:col-span-1">
      <div class="bg-white rounded-lg shadow p-6 sticky top-6">
        <div class="mb-6">
          <label for="search" class="block text-sm font-medium text-gray-700 mb-2">
            검색
          </label>
          <input
            id="search"
            v-model="searchQuery"
            type="text"
            placeholder="문서 검색..."
            class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-transparent"
          />
        </div>

        <div class="mb-6">
          <h3 class="text-lg font-medium text-gray-900 mb-3">카테고리</h3>
          <div class="space-y-2">
            <button
              v-for="category in categories"
              :key="category.id"
              @click="selectCategory(category.id)"
              :class="[
                'w-full text-left px-3 py-2 rounded-md text-sm transition-colors',
                selectedCategory === category.id
                  ? 'bg-primary-100 text-primary-700'
                  : 'text-gray-600 hover:bg-gray-100'
              ]"
            >
              {{ category.name }}
              <span class="ml-2 text-xs text-gray-400">({{ category.count }})</span>
            </button>
          </div>
        </div>

        <div>
          <h3 class="text-lg font-medium text-gray-900 mb-3">최근 문서</h3>
          <div class="space-y-2">
            <button
              v-for="doc in recentDocs"
              :key="doc.id"
              @click="selectDocument(doc)"
              class="w-full text-left px-3 py-2 rounded-md text-sm text-gray-600 hover:bg-gray-100 transition-colors"
            >
              {{ doc.title }}
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- 메인 콘텐츠 영역 -->
    <div class="lg:col-span-3">
      <div class="bg-white rounded-lg shadow">
        <div class="p-6">
          <!-- 헤더/버튼 -->
          <div class="mb-6 flex items-center gap-2">
            <input v-model="titleHint" type="text" placeholder="힌트 입력(예: AWS CLI 사용법)" class="px-3 py-2 border rounded w-60" />
            <button class="px-3 py-2 bg-indigo-600 text-white rounded" @click="suggestTitle">AI 제목 제안</button>
            <button class="px-3 py-2 bg-blue-600 text-white rounded" @click="newDoc">새 문서</button>
            <button class="px-3 py-2 bg-green-600 text-white rounded" :disabled="!dirty" @click="saveDoc">저장</button>
            <button class="px-3 py-2 bg-red-600 text-white rounded" :disabled="!selectedDoc" @click="deleteDoc">삭제</button>
            <span v-if="saveMsg" class="text-sm text-gray-500">{{ saveMsg }}</span>
          </div>

          <div v-if="editMode" class="space-y-3">
            <input v-model="editor.title" type="text" placeholder="제목" class="w-full px-3 py-2 border rounded" />
            <input v-model="editor.category" type="text" placeholder="카테고리(예: aws, gcp)" class="w-full px-3 py-2 border rounded" />
            <textarea v-model="editor.content" rows="12" placeholder="내용 입력" class="w-full px-3 py-2 border rounded font-mono"></textarea>
          </div>

          <!-- 미리보기 -->
          <div v-else-if="selectedDoc" class="prose max-w-none">
            <h1 class="text-2xl font-bold text-gray-900 mb-4">{{ selectedDoc.title }}</h1>
            <div class="flex items-center text-sm text-gray-500 mb-6">
              <span>카테고리: {{ selectedDoc.category }}</span>
              <span class="mx-2">|</span>
              <span>최근 수정: {{ selectedDoc.updatedAt || '최근' }}</span>
            </div>
            
            <div v-html="selectedDoc.content"></div>
            
            <div class="mt-8 pt-6 border-t border-gray-200">
              <h3 class="text-lg font-medium text-gray-900 mb-3">관련 문서</h3>
              <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div
                  v-for="related in relatedDocs"
                  :key="related.id"
                  @click="selectDocument(related)"
                  class="p-4 border border-gray-200 rounded-lg hover:border-primary-300 cursor-pointer transition-colors"
                >
                  <h4 class="font-medium text-gray-900">{{ related.title }}</h4>
                  <p class="text-sm text-gray-600 mt-1">{{ related.excerpt }}</p>
                </div>
              </div>
            </div>
          </div>

          <div v-else class="text-center py-12">
            <svg class="mx-auto h-12 w-12 text-gray-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
            </svg>
            <h3 class="mt-2 text-sm font-medium text-gray-900">문서가 선택되지 않았습니다</h3>
            <p class="mt-1 text-sm text-gray-500">
              왼쪽 사이드바에서 카테고리나 문서를 선택하거나 검색하여 문서를 확인하세요.
            </p>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, watch, onMounted } from 'vue';

const config = useRuntimeConfig()
const apiBase = config.public.apiBaseUrl || 'http://localhost:8000'
const apiKey = 'my_mcp_eagle_tiger'

const searchQuery = ref('')
const selectedCategory = ref('all')
const selectedDoc = ref(null)
const editMode = ref(false)
const dirty = ref(false)
const saveMsg = ref('')
const editor = reactive({ id: null, title: '', category: '', content: '' })
const titleHint = ref('')

// 카테고리 데이터
const categories = ref([
  { id: 'all', name: '전체', count: 25 },
  { id: 'aws', name: 'AWS', count: 8 },
  { id: 'gcp', name: 'GCP', count: 7 },
  { id: 'azure', name: 'Azure', count: 5 },
  { id: 'terraform', name: 'Terraform', count: 3 },
  { id: 'best-practices', name: '모범 사례', count: 2 }
])

// 최근 문서 데이터
const recentDocs = ref([
  { id: 1, title: 'AWS VPC 설계 및 구성 방법', category: 'aws', content: '<p>AWS VPC를 설계깊 諛⑸  명 媛대.</p>' },
  { id: 2, title: 'GCP GKE 클러스터 구성', category: 'gcp', content: '<p>Google Kubernetes Engine 클러스터 구성에 대한 설명입니다.</p>' },
  { id: 3, title: 'Terraform 모듈 작성법', category: 'terraform', content: '<p>Terraform 모듈 작성법에 대한 설명입니다.</p>' },
  { id: 4, title: '코드 리뷰 문화 확산 방안', category: 'best-practices', content: '<p>코드 리뷰 문화 확산 방안에 대한 설명입니다.</p>' }
])

// 관련 문서 데이터
const relatedDocs = ref([
  { id: 5, title: 'AWS EC2 인스턴스 생성', category: 'aws', excerpt: 'EC2 인스턴스 생성에 대한 설명입니다.' },
  { id: 6, title: 'GCP Cloud Storage 구성', category: 'gcp', excerpt: 'Cloud Storage 구성에 대한 설명입니다.' }
])

const selectCategory = (categoryId) => {
  selectedCategory.value = categoryId
  // TODO: 카테고리별 문서 필터링 구현
}

const selectDocument = (doc) => {
  selectedDoc.value = doc
  editMode.value = true
  Object.assign(editor, { id: doc.id, title: doc.title, category: doc.category, content: doc.content })
  dirty.value = false
}

// 검색 처리
watch(searchQuery, (newQuery) => {
  if (newQuery.length > 2) {
    // TODO: 검색 로직 구현
    console.log('Searching for:', newQuery)
  }
})

// CRUD (localStorage 기반 MVP)
const STORAGE_KEY = 'kb_docs_mvp'

function loadDocs() {
  const raw = localStorage.getItem(STORAGE_KEY)
  if (raw) {
    try {
      const docs = JSON.parse(raw)
      if (Array.isArray(docs) && docs.length) {
        recentDocs.value = docs.slice(0, 10)
      }
    } catch {}
  }
}

function persistDocs() {
  const all = [...recentDocs.value]
  localStorage.setItem(STORAGE_KEY, JSON.stringify(all))
}

function newDoc() {
  editMode.value = true
  Object.assign(editor, { id: null, title: '', category: '', content: '' })
  selectedDoc.value = null
  dirty.value = true
}

async function suggestTitle() {
  if (!titleHint.value.trim()) return
  try {
    const resp = await fetch(`${apiBase}/api/v1/ai/knowledge/suggest-title`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json', 'X-API-Key': apiKey },
      body: JSON.stringify({ hint: titleHint.value })
    })
    const data = await resp.json()
    if (data.success) {
      editor.title = data.title
      if (!editor.category) editor.category = 'misc'
      if (!editor.content) editor.content = `# ${data.title}\n\n` 
      dirty.value = true
    }
  } catch (e) {
    console.warn('제목 제안 실패', e)
  }
}

async function saveDoc() {
  const id = editor.id || Date.now()
  const existingIdx = recentDocs.value.findIndex(d => d.id === id)
  const doc = { id, title: editor.title || '제목 없음', category: editor.category || 'misc', content: editor.content || '' }
  if (existingIdx >= 0) recentDocs.value.splice(existingIdx, 1, doc)
  else recentDocs.value.unshift(doc)
  try {
    // 서버 저장 (실제로는 카테고리/제목 경로 생성)
    const relPath = `${editor.category || 'misc'}/${(editor.title || 'untitled').replace(/\s+/g,'_')}.md`
    const method = editor.id ? 'PUT' : 'POST'
    const url = `${apiBase}/api/v1/knowledge/docs`
    const body = editor.id ? { path: relPath, content: editor.content, refresh_vector: false } : { path: relPath, content: editor.content, refresh_vector: false }
    await fetch(url, { method, headers: { 'Content-Type': 'application/json', 'X-API-Key': apiKey }, body: JSON.stringify(body) })
  } catch (e) {
    console.warn('Server save failed, fallback to localStorage only.', e)
  }
  persistDocs()
  selectedDoc.value = doc
  editMode.value = false
  dirty.value = false
  saveMsg.value = '저장 완료'
  setTimeout(() => saveMsg.value = '', 1500)
}

async function deleteDoc() {
  if (!selectedDoc.value && !editor.id) return
  const id = editor.id || selectedDoc.value?.id
  const idx = recentDocs.value.findIndex(d => d.id === id)
  if (idx >= 0) recentDocs.value.splice(idx, 1)
  try {
    const relPath = `${(editor.category || selectedDoc.value?.category || 'misc')}/${((editor.title || selectedDoc.value?.title) || 'untitled').replace(/\s+/g,'_')}.md`
    await fetch(`${apiBase}/api/v1/knowledge/docs`, { method: 'DELETE', headers: { 'Content-Type': 'application/json', 'X-API-Key': apiKey }, body: JSON.stringify({ path: relPath, refresh_vector: false }) })
  } catch (e) {
    console.warn('Server delete failed, fallback to local only.', e)
  }
  persistDocs()
  selectedDoc.value = null
  editMode.value = false
  dirty.value = false
}

watch(editor, () => { dirty.value = true }, { deep: true })

onMounted(loadDocs)
</script>
