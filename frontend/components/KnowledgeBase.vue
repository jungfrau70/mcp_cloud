<template>
  <div class="knowledge-base">
    <!-- 헤더 -->
    <div class="bg-white shadow-sm border-b">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="flex justify-between items-center py-4">
          <div class="flex items-center space-x-4">
            <h1 class="text-2xl font-bold text-gray-900">지식베이스</h1>
            <div class="flex items-center space-x-2">
              <span class="text-sm text-gray-500">총 {{ categories.find(c => c.id === 'all')?.count || 0 }}개 문서</span>
            </div>
          </div>
        </div>

        <!-- 서브 메뉴 -->
        <div class="border-t border-gray-200">
          <nav class="flex space-x-8">
            <button
              @click="activeTab = 'internal'"
              :class="[
                'py-2 px-1 border-b-2 font-medium text-sm',
                activeTab === 'internal'
                  ? 'border-blue-500 text-blue-600'
                  : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
              ]"
            >
              내부자료 검색
            </button>
            <button
              @click="activeTab = 'external'"
              :class="[
                'py-2 px-1 border-b-2 font-medium text-sm',
                activeTab === 'external'
                  ? 'border-blue-500 text-blue-600'
                  : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
              ]"
            >
              외부자료 기반 문서생성
            </button>
          </nav>
        </div>
      </div>
    </div>

    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-6">
      <!-- 내부자료 검색 탭 -->
      <div v-if="activeTab === 'internal'" class="flex gap-6">
        <!-- 사이드바 -->
        <div class="w-64 flex-shrink-0">
          <div class="bg-white rounded-lg shadow-sm border p-4">
            <h3 class="text-lg font-medium text-gray-900 mb-4">카테고리</h3>
            <div class="space-y-2">
            <button 
                v-for="category in categories"
                :key="category.id"
                @click="selectCategory(category.id)"
                :class="[
                  'w-full text-left px-3 py-2 rounded-md text-sm',
                  selectedCategory === category.id
                    ? 'bg-blue-100 text-blue-700'
                    : 'text-gray-700 hover:bg-gray-100'
                ]"
              >
                {{ category.name }}
                <span class="float-right text-gray-500">{{ category.count }}</span>
            </button>
            </div>
          </div>

          <div class="mt-6 bg-white rounded-lg shadow-sm border p-4">
            <h3 class="text-lg font-medium text-gray-900 mb-4">최근 문서</h3>
            <div class="space-y-3">
              <div
                v-for="doc in recentDocs"
                :key="doc.id"
                @click="selectDocument(doc)"
                class="cursor-pointer p-3 rounded-md hover:bg-gray-50"
              >
                <h4 class="text-sm font-medium text-gray-900">{{ doc.title }}</h4>
                <p class="text-xs text-gray-500 mt-1">{{ doc.category }}</p>
              </div>
            </div>
          </div>
        </div>

        <!-- 메인 콘텐츠 -->
        <div class="flex-1">
          <div class="bg-white rounded-lg shadow-sm border">
            <!-- 검색 및 필터 -->
            <div class="p-4 border-b">
              <div class="flex items-center space-x-4">
                <div class="flex-1">
                  <input
                    v-model="searchQuery"
                    type="text"
                    placeholder="문서 검색..."
                    class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                    @keyup.enter="performSearch"
                  />
                </div>
                <button
                  @click="performSearch"
                  :disabled="searchLoading"
                  class="px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-500 disabled:opacity-50 disabled:cursor-not-allowed flex items-center"
                >
                  <svg v-if="searchLoading" class="animate-spin -ml-1 mr-2 h-4 w-4 text-white" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                    <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                    <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                  </svg>
                  {{ searchLoading ? '검색 중...' : '검색' }}
                </button>
                <button
                  @click="createNewDocument"
                  class="px-4 py-2 bg-green-600 text-white rounded-md hover:bg-green-700 focus:outline-none focus:ring-2 focus:ring-green-500"
                >
                  새 문서
                </button>
              </div>
            </div>

            <!-- 검색 결과 또는 문서 목록 -->
            <div v-if="searchPerformed && searchResults.length > 0" class="p-4 border-b bg-blue-50">
              <div class="flex items-center justify-between mb-3">
                <h3 class="text-lg font-medium text-gray-900">
                  검색 결과 ({{ searchResults.length }}개)
                </h3>
                <button
                  @click="searchPerformed = false; loadDocumentsByCategory(selectedCategory)"
                  class="text-sm text-blue-600 hover:text-blue-800"
                >
                  전체 보기
                </button>
              </div>
              <div class="space-y-3">
                <div
                  v-for="doc in searchResults"
                  :key="doc.id"
                  @click="selectDocument(doc)"
                  class="p-3 bg-white rounded-md border border-gray-200 hover:border-blue-300 cursor-pointer transition-colors"
                >
                  <div class="flex items-start justify-between">
                    <div class="flex-1">
                      <h4 class="text-sm font-medium text-gray-900 mb-1" v-html="doc.highlighted_title || doc.title"></h4>
                      <p class="text-xs text-gray-500 mb-2">{{ doc.category }} • {{ new Date(doc.updated_at).toLocaleDateString() }}</p>
                      <p class="text-sm text-gray-600" v-html="doc.highlighted_content || doc.content"></p>
                    </div>
                    <div class="ml-3 flex space-x-1">
                      <span
                        v-for="tag in doc.tags"
                        :key="tag"
                        class="inline-flex items-center px-2 py-1 rounded-full text-xs font-medium bg-gray-100 text-gray-800"
                      >
                        {{ tag }}
                      </span>
                    </div>
                  </div>
                </div>
              </div>
            </div>

            <!-- 일반 문서 목록 -->
            <div v-else-if="!searchPerformed && searchResults.length > 0" class="p-4 border-b">
              <div class="flex items-center justify-between mb-3">
                <h3 class="text-lg font-medium text-gray-900">
                  {{ selectedCategory === 'all' ? '전체 문서' : categories.find(c => c.id === selectedCategory)?.name + ' 문서' }}
                </h3>
                <span class="text-sm text-gray-500">{{ searchResults.length }}개 문서</span>
              </div>
              <div class="space-y-3">
                <div
                  v-for="doc in searchResults"
                  :key="doc.id"
                  @click="selectDocument(doc)"
                  class="p-3 bg-gray-50 rounded-md hover:bg-gray-100 cursor-pointer transition-colors"
                >
                  <div class="flex items-start justify-between">
                    <div class="flex-1">
                      <h4 class="text-sm font-medium text-gray-900 mb-1">{{ doc.title }}</h4>
                      <p class="text-xs text-gray-500 mb-2">{{ doc.category }} • {{ new Date(doc.updated_at).toLocaleDateString() }}</p>
                      <p class="text-sm text-gray-600">{{ doc.content.substring(0, 150) }}{{ doc.content.length > 150 ? '...' : '' }}</p>
                    </div>
                    <div class="ml-3 flex space-x-1">
                      <span
                        v-for="tag in doc.tags"
                        :key="tag"
                        class="inline-flex items-center px-2 py-1 rounded-full text-xs font-medium bg-blue-100 text-blue-800"
                      >
                        {{ tag }}
                      </span>
                    </div>
                  </div>
                </div>
              </div>
            </div>

            <!-- 빈 상태 -->
            <div v-else-if="searchPerformed && searchResults.length === 0" class="p-8 text-center">
              <svg class="mx-auto h-12 w-12 text-gray-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9.172 16.172a4 4 0 015.656 0M9 12h6m-6-4h6m2 5.291A7.962 7.962 0 0112 15c-2.34 0-4.47-.881-6.08-2.33" />
              </svg>
              <h3 class="mt-2 text-sm font-medium text-gray-900">검색 결과가 없습니다</h3>
              <p class="mt-1 text-sm text-gray-500">
                "{{ searchQuery }}"에 대한 검색 결과를 찾을 수 없습니다.
              </p>
              <div class="mt-6">
                <button
                  @click="searchPerformed = false; loadDocumentsByCategory(selectedCategory)"
                  class="inline-flex items-center px-4 py-2 border border-transparent shadow-sm text-sm font-medium rounded-md text-white bg-blue-600 hover:bg-blue-700"
                >
                  전체 문서 보기
                </button>
              </div>
            </div>

            <!-- 문서 내용 -->
            <div v-if="selectedDoc || editMode" class="p-6">
              <!-- 문서 헤더 -->
              <div class="flex items-center justify-between mb-4">
                <div class="flex items-center space-x-3">
                  <h2 class="text-xl font-bold text-gray-900">
                    {{ editMode ? (editor.id ? '문서 편집' : '새 문서 작성') : selectedDoc?.title }}
                  </h2>
                  <span v-if="selectedDoc" class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-blue-100 text-blue-800">
                    {{ selectedDoc.category }}
                  </span>
                </div>
                <div class="flex items-center space-x-2">
                  <div v-if="saveMsg" class="text-sm text-green-600">{{ saveMsg }}</div>
                  <button
                    v-if="!editMode"
                    @click="editMode = true; Object.assign(editor, { id: selectedDoc.id, title: selectedDoc.title, category: selectedDoc.category, content: selectedDoc.content })"
                    class="px-3 py-1 bg-gray-100 text-gray-700 rounded hover:bg-gray-200 text-sm"
                  >
                    편집
                  </button>
                  <button
                    v-if="editMode"
                    @click="saveDocument"
                    :disabled="!dirty"
                    class="px-3 py-1 bg-blue-600 text-white rounded hover:bg-blue-700 disabled:opacity-50 disabled:cursor-not-allowed text-sm"
                  >
                    저장
                  </button>
                  <button
                    v-if="editMode"
                    @click="cancelEdit"
                    class="px-3 py-1 bg-gray-100 text-gray-700 rounded hover:bg-gray-200 text-sm"
                  >
                    취소
                  </button>
                  <button
                    v-if="editMode && editor.id"
                    @click="deleteDocument"
                    class="px-3 py-1 bg-red-600 text-white rounded hover:bg-red-700 text-sm"
                  >
                    삭제
                  </button>
                </div>
              </div>

              <!-- 문서 편집 모드 -->
              <div v-if="editMode" class="space-y-4">
                <div>
                  <label class="block text-sm font-medium text-gray-700 mb-2">제목</label>
                  <input
                    v-model="editor.title"
                    @input="dirty = true"
                    type="text"
                    class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                    placeholder="문서 제목을 입력하세요"
                  />
                </div>
                <div>
                  <label class="block text-sm font-medium text-gray-700 mb-2">카테고리</label>
                  <select
                    v-model="editor.category"
                    @change="dirty = true"
                    class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                  >
                    <option value="aws">AWS</option>
                    <option value="gcp">GCP</option>
                    <option value="azure">Azure</option>
                    <option value="terraform">Terraform</option>
                    <option value="best-practices">모범 사례</option>
                  </select>
                </div>
                <div>
                  <label class="block text-sm font-medium text-gray-700 mb-2">내용</label>
                  <textarea
                    v-model="editor.content"
                    @input="dirty = true"
                    rows="15"
                    class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                    placeholder="마크다운 형식으로 문서 내용을 입력하세요"
                  ></textarea>
                </div>
              </div>

              <!-- 문서 표시 모드 -->
              <div v-else-if="selectedDoc" class="prose max-w-none" v-html="selectedDoc.content"></div>
            </div>

            <!-- 빈 상태 -->
            <div v-else class="p-8 text-center">
              <svg class="mx-auto h-12 w-12 text-gray-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
              </svg>
              <h3 class="mt-2 text-sm font-medium text-gray-900">문서를 선택하세요</h3>
              <p class="mt-1 text-sm text-gray-500">
                왼쪽에서 문서를 선택하거나 새 문서를 작성하세요.
              </p>
            </div>
          </div>
        </div>
      </div>

      <!-- 외부자료 기반 문서생성 탭 -->
      <div v-if="activeTab === 'external'" class="space-y-6">
        <div class="bg-white rounded-lg shadow-sm border p-6">
          <div class="text-center mb-8">
            <div class="mx-auto h-16 w-16 text-blue-600 mb-4">
              <svg fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9.663 17h4.673M12 3v1m6.364 1.636l-.707.707M21 12h-1M4 12H3m3.343-5.657l-.707-.707m2.828 9.9a5 5 0 117.072 0l-.548.547A3.374 3.374 0 0014 18.469V19a2 2 0 11-4 0v-.531c0-.895-.356-1.754-.988-2.386l-.548-.547z" />
              </svg>
            </div>
            <h2 class="text-2xl font-bold text-gray-900 mb-2">외부자료 기반 문서생성</h2>
            <p class="text-gray-600 max-w-2xl mx-auto">
              AI가 외부 웹사이트와 기술 문서를 검색하여 지식베이스 문서를 자동으로 생성합니다.
              원하는 주제를 입력하고 문서 타입을 선택하면 AI가 관련 정보를 수집하여 문서를 만들어드립니다.
            </p>
          </div>

          <div class="max-w-2xl mx-auto">
            <div class="space-y-6">
              <!-- 문서 주제 입력 -->
              <div>
                <label class="block text-sm font-medium text-gray-700 mb-2">
                  문서 주제 *
                </label>
                <textarea
                  v-model="externalQuery"
                  rows="3"
                  placeholder="예: AWS Lambda를 사용한 서버리스 애플리케이션 배포 방법"
                  class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                ></textarea>
              </div>

              <!-- 문서 타입 선택 -->
              <div>
                <label class="block text-sm font-medium text-gray-700 mb-2">
                  문서 타입
                </label>
                <select
                  v-model="externalDocType"
                  class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                >
                  <option value="guide">기술 가이드</option>
                  <option value="tutorial">단계별 튜토리얼</option>
                  <option value="reference">참조 문서</option>
                  <option value="comparison">비교 분석</option>
                </select>
              </div>

              <!-- 검색 소스 선택 -->
              <div>
                <label class="block text-sm font-medium text-gray-700 mb-2">
                  검색 소스
                </label>
                <div class="space-y-2">
                  <label class="flex items-center">
                    <input
                      type="checkbox"
                      v-model="externalSearchSources"
                      value="web"
                      class="rounded border-gray-300 text-blue-600 focus:ring-blue-500"
                    >
                    <span class="ml-2 text-sm text-gray-700">웹 검색</span>
                  </label>
                  <label class="flex items-center">
                    <input
                      type="checkbox"
                      v-model="externalSearchSources"
                      value="news"
                      class="rounded border-gray-300 text-blue-600 focus:ring-blue-500"
                    >
                    <span class="ml-2 text-sm text-gray-700">뉴스 검색</span>
                  </label>
                  <label class="flex items-center">
                    <input
                      type="checkbox"
                      v-model="externalSearchSources"
                      value="docs"
                      class="rounded border-gray-300 text-blue-600 focus:ring-blue-500"
                    >
                    <span class="ml-2 text-sm text-gray-700">문서 검색</span>
                  </label>
                </div>
              </div>

              <!-- 저장 경로 -->
              <div>
                <label class="block text-sm font-medium text-gray-700 mb-2">
                  저장 경로 (선택사항)
                </label>
                <input
                  v-model="externalTargetPath"
                  type="text"
                  placeholder="예: aws/lambda-deployment"
                  class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                >
                <p class="mt-1 text-xs text-gray-500">
                  비워두면 루트 디렉토리에 저장됩니다
                </p>
              </div>

              <!-- 최대 결과 수 -->
              <div>
                <label class="block text-sm font-medium text-gray-700 mb-2">
                  최대 검색 결과 수
                </label>
                <input
                  v-model.number="externalMaxResults"
                  type="number"
                  min="1"
                  max="10"
                  class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                >
              </div>

              <!-- 생성 버튼 -->
              <div class="pt-4">
                <button
                  @click="generateExternalDocument"
                  :disabled="!canGenerateExternal || externalGenerating"
                  class="w-full px-4 py-3 bg-blue-600 text-white rounded-md hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-500 disabled:opacity-50 disabled:cursor-not-allowed flex items-center justify-center"
                >
                  <svg v-if="externalGenerating" class="animate-spin -ml-1 mr-3 h-5 w-5 text-white" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                    <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                    <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                  </svg>
                  {{ externalGenerating ? '문서 생성 중...' : 'AI 문서 생성 시작' }}
                </button>
              </div>

              <!-- 진행 상태 표시 -->
              <div v-if="externalGenerating" class="bg-blue-50 border border-blue-200 rounded-md p-4">
                <div class="flex items-center space-x-3">
                  <div class="animate-spin rounded-full h-6 w-6 border-b-2 border-blue-600"></div>
                  <div>
                    <p class="text-sm font-medium text-blue-900">{{ externalCurrentStep }}</p>
                    <div class="w-full bg-gray-200 rounded-full h-2 mt-1">
                      <div class="bg-blue-600 h-2 rounded-full transition-all duration-300" :style="{ width: externalProgress + '%' }"></div>
                    </div>
                  </div>
                </div>
              </div>

              <!-- 에러 메시지 -->
              <div v-if="externalError" class="bg-red-50 border border-red-200 rounded-md p-4">
                <div class="flex items-center">
                  <svg class="w-5 h-5 text-red-400 mr-2" fill="currentColor" viewBox="0 0 20 20">
                    <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z" clip-rule="evenodd" />
                  </svg>
                  <span class="text-red-800 font-medium">오류가 발생했습니다</span>
                </div>
                <p class="text-red-700 mt-1">{{ externalError }}</p>
              </div>

              <!-- 성공 메시지 -->
              <div v-if="externalSuccess" class="bg-green-50 border border-green-200 rounded-md p-4">
                <div class="flex items-center">
                  <svg class="w-5 h-5 text-green-400 mr-2" fill="currentColor" viewBox="0 0 20 20">
                    <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd" />
                  </svg>
                  <span class="text-green-800 font-medium">문서가 성공적으로 생성되었습니다!</span>
                </div>
                <p class="text-green-700 mt-1">{{ externalSuccess }}</p>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- AI 문서 생성 모달 -->
    <AIDocumentGenerator 
      :is-open="showAiGenerateModal"
      @close="closeAiModal"
      @document-generated="handleDocumentGenerated"
    />
  </div>
</template>

<script setup>
import { ref, reactive, watch, onMounted, computed } from 'vue';
import AIDocumentGenerator from './AIDocumentGenerator.vue';

const config = useRuntimeConfig()
const apiBase = config.public.apiBaseUrl || 'https://api.gostock.us'
const apiKey = 'my_mcp_eagle_tiger'

// 탭 상태
const activeTab = ref('internal')

// 내부자료 검색 관련
const searchQuery = ref('')
const selectedCategory = ref('all')
const selectedDoc = ref(null)
const editMode = ref(false)
const dirty = ref(false)
const saveMsg = ref('')
const editor = reactive({ id: null, title: '', category: '', content: '' })
const titleHint = ref('')
const sidebarCollapsed = ref(false)

// 검색 결과 관련
const searchResults = ref([])
const searchLoading = ref(false)
const searchPerformed = ref(false)

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
  { id: 1, title: 'AWS VPC 설계 및 구성 방법', category: 'aws', content: '<p>AWS VPC를 설계하고 구성하는 방법에 대한 설명입니다.</p>' },
  { id: 2, title: 'GCP GKE 클러스터 구성', category: 'gcp', content: '<p>Google Kubernetes Engine 클러스터 구성에 대한 설명입니다.</p>' },
  { id: 3, title: 'Terraform 모듈 작성법', category: 'terraform', content: '<p>Terraform 모듈 작성법에 대한 설명입니다.</p>' },
  { id: 4, title: '코드 리뷰 문화 확산 방안', category: 'best-practices', content: '<p>코드 리뷰 문화 확산 방안에 대한 설명입니다.</p>' }
])

// 외부자료 기반 문서생성 관련
const externalQuery = ref('')
const externalDocType = ref('guide')
const externalSearchSources = ref(['web', 'news'])
const externalTargetPath = ref('')
const externalMaxResults = ref(5)
const externalGenerating = ref(false)
const externalCurrentStep = ref('')
const externalProgress = ref(0)
const externalError = ref('')
const externalSuccess = ref('')

// AI 모달 관련
const aiGenerateQuery = ref('')
const aiGenerateLoading = ref(false)
const aiGenerateMessage = ref('')
const showAiGenerateModal = ref(false)
const aiGeneratedPreview = ref('')

// Computed
const canGenerateExternal = computed(() => {
  return externalQuery.value.trim().length > 0 && externalSearchSources.value.length > 0
})

function closeAiModal() {
  showAiGenerateModal.value = false
  aiGenerateQuery.value = ''
  aiGenerateMessage.value = ''
  aiGeneratedPreview.value = ''
}

async function handleDocumentGenerated(documentData) {
  // 생성된 문서를 에디터에 로드
  editor.id = null
  editor.title = documentData.generated_doc_data.title
  editor.category = documentData.generated_doc_data.category || 'ai-generated'
  editor.content = documentData.generated_doc_data.content
  dirty.value = true
  editMode.value = true
  selectedDoc.value = null
  
  // 성공 메시지 표시
  saveMsg.value = `AI 문서 생성 완료: ${documentData.message}`
  setTimeout(() => saveMsg.value = '', 3000)
}

// 외부자료 기반 문서생성 함수
async function generateExternalDocument() {
  if (!canGenerateExternal.value) return

  externalGenerating.value = true
  externalError.value = ''
  externalSuccess.value = ''
  externalProgress.value = 0

  try {
    externalCurrentStep.value = '검색 중...'
    externalProgress.value = 20
    
    const response = await $fetch('/api/v1/knowledge/generate-from-external-enhanced', {
      method: 'POST',
      headers: {
        'X-API-Key': apiKey
      },
      body: {
        query: externalQuery.value,
        doc_type: externalDocType.value,
        search_sources: externalSearchSources.value,
        target_path: externalTargetPath.value || undefined,
        max_results: externalMaxResults.value
      }
    })

    externalCurrentStep.value = '문서 생성 중...'
    externalProgress.value = 80

    if (response.success) {
      externalProgress.value = 100
      externalSuccess.value = `문서가 성공적으로 생성되었습니다: ${response.message}`
      
      // 생성된 문서를 에디터에 로드
      editor.id = null
      editor.title = response.generated_doc_data.title
      editor.category = response.generated_doc_data.category || 'ai-generated'
      editor.content = response.generated_doc_data.content
      dirty.value = true
      editMode.value = true
      selectedDoc.value = null
      
      // 내부자료 검색 탭으로 이동
      activeTab.value = 'internal'
    } else {
      throw new Error(response.message || '문서 생성에 실패했습니다')
    }

  } catch (err) {
    externalError.value = err.message || '알 수 없는 오류가 발생했습니다'
    console.error('External document generation error:', err)
  } finally {
    externalGenerating.value = false
  }
}

// 내부자료 검색 함수
async function performSearch() {
  if (!searchQuery.value.trim()) return
  
  searchLoading.value = true
  searchPerformed.value = true
  
  try {
    const response = await $fetch('/api/v1/knowledge/search-enhanced', {
      method: 'POST',
      headers: {
        'X-API-Key': apiKey
      },
      body: {
        query: searchQuery.value,
        category: selectedCategory.value === 'all' ? null : selectedCategory.value,
        limit: 10,
        search_type: 'both'
      }
    })
    
    if (response.success) {
      searchResults.value = response.results
    } else {
      searchResults.value = []
    }
  } catch (err) {
    console.error('Search error:', err)
    searchResults.value = []
  } finally {
    searchLoading.value = false
  }
}

// 카테고리별 문서 로드
async function loadDocumentsByCategory(categoryId) {
  try {
    const response = await $fetch(`/api/v1/knowledge/documents?category=${categoryId}&limit=20`, {
      headers: {
        'X-API-Key': apiKey
      }
    })
    
    if (response.success) {
      searchResults.value = response.documents
      searchPerformed.value = false
    }
  } catch (err) {
    console.error('Category load error:', err)
  }
}

// 카테고리 데이터 로드
async function loadCategories() {
  try {
    const response = await $fetch('/api/v1/knowledge/categories', {
      headers: {
        'X-API-Key': apiKey
      }
    })
    
    if (response.success) {
      categories.value = response.categories
    }
  } catch (err) {
    console.error('Categories load error:', err)
  }
}

// 최근 문서 로드
async function loadRecentDocuments() {
  try {
    const response = await $fetch('/api/v1/knowledge/recent-documents?limit=5', {
      headers: {
        'X-API-Key': apiKey
      }
    })
    
    if (response.success) {
      recentDocs.value = response.documents
    }
  } catch (err) {
    console.error('Recent documents load error:', err)
  }
}

// 문서 저장
async function saveDocument() {
  if (!editor.title.trim() || !editor.content.trim()) {
    saveMsg.value = '제목과 내용을 입력해주세요.'
    setTimeout(() => saveMsg.value = '', 3000)
    return
  }
  
  try {
    if (editor.id) {
      // 기존 문서 업데이트
      const response = await $fetch(`/api/v1/knowledge/documents/${editor.id}`, {
        method: 'PUT',
        headers: {
          'X-API-Key': apiKey
        },
        body: {
          title: editor.title,
          category: editor.category,
          content: editor.content
        }
      })
      
      saveMsg.value = '문서가 업데이트되었습니다.'
    } else {
      // 새 문서 생성
      const response = await $fetch('/api/v1/knowledge/documents', {
        method: 'POST',
        headers: {
          'X-API-Key': apiKey
        },
        body: {
          title: editor.title,
          category: editor.category,
          content: editor.content
        }
      })
      
      editor.id = response.id
      saveMsg.value = '새 문서가 생성되었습니다.'
    }
    
    dirty.value = false
    setTimeout(() => saveMsg.value = '', 3000)
    
    // 카테고리 및 최근 문서 새로고침
    await loadCategories()
    await loadRecentDocuments()
    
  } catch (err) {
    console.error('Save error:', err)
    saveMsg.value = '저장 중 오류가 발생했습니다.'
    setTimeout(() => saveMsg.value = '', 3000)
  }
}

// 문서 삭제
async function deleteDocument() {
  if (!editor.id) return
  
  if (!confirm('정말로 이 문서를 삭제하시겠습니까?')) return
  
  try {
    await $fetch(`/api/v1/knowledge/documents/${editor.id}`, {
      method: 'DELETE',
      headers: {
        'X-API-Key': apiKey
      }
    })
    
    // 편집 모드 종료
    editMode.value = false
    selectedDoc.value = null
    editor.id = null
    editor.title = ''
    editor.category = ''
    editor.content = ''
    dirty.value = false
    
    saveMsg.value = '문서가 삭제되었습니다.'
    setTimeout(() => saveMsg.value = '', 3000)
    
    // 카테고리 및 최근 문서 새로고침
    await loadCategories()
    await loadRecentDocuments()
    
  } catch (err) {
    console.error('Delete error:', err)
    saveMsg.value = '삭제 중 오류가 발생했습니다.'
    setTimeout(() => saveMsg.value = '', 3000)
  }
}

// 새 문서 생성
function createNewDocument() {
  editMode.value = true
  selectedDoc.value = null
  editor.id = null
  editor.title = ''
  editor.category = selectedCategory.value === 'all' ? 'aws' : selectedCategory.value
  editor.content = ''
  dirty.value = false
  saveMsg.value = ''
}

// 컴포넌트 마운트 시 데이터 로드
onMounted(async () => {
  try {
    await loadCategories()
    await loadRecentDocuments()
    await loadDocumentsByCategory('all')
  } catch (error) {
    console.error('Initial data loading failed:', error)
    // API 호출이 실패해도 기본 UI는 표시되도록 함
  }
})

const selectCategory = (categoryId) => {
  selectedCategory.value = categoryId
  loadDocumentsByCategory(categoryId)
}

const selectDocument = (doc) => {
  selectedDoc.value = doc
  editMode.value = false
  dirty.value = false
  if (doc) {
    Object.assign(editor, { 
      id: doc.id, 
      title: doc.title, 
      category: doc.category, 
      content: doc.content 
    })
  }
}

const cancelEdit = () => {
  editMode.value = false
  dirty.value = false
  if (selectedDoc.value) {
    Object.assign(editor, { 
      id: selectedDoc.value.id, 
      title: selectedDoc.value.title, 
      category: selectedDoc.value.category, 
      content: selectedDoc.value.content 
    })
  }
}

// 검색 처리
watch(searchQuery, (newQuery) => {
  if (newQuery.length > 2) {
    // TODO: 검색 로직 구현
    console.log('Searching for:', newQuery)
  }
})
</script>

<style scoped>
.prose {
  @apply text-gray-900;
}

.prose h1 {
  @apply text-2xl font-bold mb-4;
}

.prose h2 {
  @apply text-xl font-semibold mb-3 mt-6;
}

.prose h3 {
  @apply text-lg font-medium mb-2 mt-4;
}

.prose p {
  @apply mb-3;
}

.prose ul {
  @apply list-disc list-inside mb-3;
}

.prose ol {
  @apply list-decimal list-inside mb-3;
}

.prose code {
  @apply bg-gray-100 px-1 py-0.5 rounded text-sm;
}

.prose pre {
  @apply bg-gray-100 p-3 rounded mb-3 overflow-x-auto;
}

.prose blockquote {
  @apply border-l-4 border-gray-300 pl-4 italic mb-3;
}
</style>
