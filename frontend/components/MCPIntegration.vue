<template>
  <div class="mcp-integration">
    <!-- MCP 서비스 상태 대시보드 -->
    <UCard class="mb-8">
      <template #header>
        <div class="flex items-center justify-between">
          <h3 class="text-xl font-semibold text-gray-900 dark:text-white">
            🤖 MCP 서비스 상태
          </h3>
          <UButton
            @click="refreshServices"
            :loading="loading"
            size="sm"
            variant="ghost"
            icon="i-lucide-refresh-cw"
          >
            새로고침
          </UButton>
        </div>
      </template>

      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
        <div
          v-for="service in mcpServices"
          :key="service.name"
          class="p-4 border rounded-lg"
          :class="service.status === 'active' ? 'border-green-200 bg-green-50 dark:border-green-800 dark:bg-green-900/20' : 'border-gray-200 bg-gray-50 dark:border-gray-700 dark:bg-gray-800/50'"
        >
          <div class="flex items-center gap-3 mb-2">
            <UIcon
              :name="service.icon"
              class="w-5 h-5"
              :class="service.status === 'active' ? 'text-green-600 dark:text-green-400' : 'text-gray-400'"
            />
            <span class="font-medium text-gray-900 dark:text-white">
              {{ service.name }}
            </span>
          </div>
          <p class="text-sm text-gray-600 dark:text-gray-300 mb-2">
            {{ service.description }}
          </p>
          <UBadge
            :color="service.status === 'active' ? 'green' : 'gray'"
            variant="soft"
            size="sm"
          >
            {{ service.status === 'active' ? '연결됨' : '연결 안됨' }}
          </UBadge>
        </div>
      </div>
    </UCard>

    <!-- MCP 기능 데모 섹션 -->
    <UCard class="mb-8">
      <template #header>
        <h3 class="text-xl font-semibold text-gray-900 dark:text-white">
          🚀 MCP 기능 데모
        </h3>
      </template>

      <div class="space-y-6">
        <!-- GitHub 리포지토리 검색 -->
        <div class="p-4 border rounded-lg bg-gray-50 dark:bg-gray-800/50">
          <h4 class="font-semibold text-gray-900 dark:text-white mb-3">
            GitHub 리포지토리 검색
          </h4>
          <div class="flex gap-2 mb-3">
            <UInput
              v-model="githubQuery"
              placeholder="리포지토리 이름을 입력하세요 (예: nuxt/ui)"
              class="flex-1"
            />
            <UButton
              @click="searchGitHub"
              :loading="githubLoading"
              color="primary"
            >
              검색
            </UButton>
          </div>
          <div v-if="githubResults.length > 0" class="space-y-2">
            <UCard
              v-for="repo in githubResults"
              :key="repo.id"
              class="p-3"
            >
              <div class="flex items-center justify-between">
                <div>
                  <h5 class="font-medium text-gray-900 dark:text-white">
                    {{ repo.full_name }}
                  </h5>
                  <p class="text-sm text-gray-600 dark:text-gray-300">
                    {{ repo.description || '설명 없음' }}
                  </p>
                </div>
                <div class="flex items-center gap-2 text-sm text-gray-500">
                  <UIcon name="i-lucide-star" class="w-4 h-4" />
                  {{ repo.stargazers_count }}
                </div>
              </div>
            </UCard>
          </div>
        </div>

        <!-- 데이터베이스 쿼리 -->
        <div class="p-4 border rounded-lg bg-gray-50 dark:bg-gray-800/50">
          <h4 class="font-semibold text-gray-900 dark:text-white mb-3">
            데이터베이스 쿼리
          </h4>
          <div class="flex gap-2 mb-3">
            <UInput
              v-model="dbQuery"
              placeholder="SQL 쿼리를 입력하세요 (예: SELECT * FROM users LIMIT 5)"
              class="flex-1"
            />
            <UButton
              @click="executeQuery"
              :loading="dbLoading"
              color="primary"
            >
              실행
            </UButton>
          </div>
          <div v-if="dbResults.length > 0" class="overflow-x-auto">
            <table class="w-full text-sm">
              <thead class="bg-gray-100 dark:bg-gray-700">
                <tr>
                  <th
                    v-for="column in dbColumns"
                    :key="column"
                    class="px-3 py-2 text-left font-medium text-gray-900 dark:text-white"
                  >
                    {{ column }}
                  </th>
                </tr>
              </thead>
              <tbody>
                <tr
                  v-for="(row, index) in dbResults"
                  :key="index"
                  class="border-b border-gray-200 dark:border-gray-700"
                >
                  <td
                    v-for="column in dbColumns"
                    :key="column"
                    class="px-3 py-2 text-gray-600 dark:text-gray-300"
                  >
                    {{ row[column] }}
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>

        <!-- 파일 시스템 탐색 -->
        <div class="p-4 border rounded-lg bg-gray-50 dark:bg-gray-800/50">
          <h4 class="font-semibold text-gray-900 dark:text-white mb-3">
            파일 시스템 탐색
          </h4>
          <div class="flex gap-2 mb-3">
            <UInput
              v-model="filePath"
              placeholder="파일 경로를 입력하세요 (예: /frontend/components)"
              class="flex-1"
            />
            <UButton
              @click="exploreFiles"
              :loading="fileLoading"
              color="primary"
            >
              탐색
            </UButton>
          </div>
          <div v-if="fileResults.length > 0" class="space-y-1">
            <div
              v-for="file in fileResults"
              :key="file.name"
              class="flex items-center gap-2 p-2 hover:bg-gray-100 dark:hover:bg-gray-700 rounded"
            >
              <UIcon
                :name="file.type === 'directory' ? 'i-lucide-folder' : 'i-lucide-file'"
                class="w-4 h-4 text-gray-500"
              />
              <span class="text-sm text-gray-900 dark:text-white">
                {{ file.name }}
              </span>
              <span class="text-xs text-gray-500 ml-auto">
                {{ file.type === 'file' ? formatFileSize(file.size) : '' }}
              </span>
            </div>
          </div>
        </div>

        <!-- Context7 라이브러리 검색 -->
        <div class="p-4 border rounded-lg bg-gray-50 dark:bg-gray-800/50">
          <h4 class="font-semibold text-gray-900 dark:text-white mb-3">
            Context7 라이브러리 검색
          </h4>
          <div class="flex gap-2 mb-3">
            <UInput
              v-model="context7Query"
              placeholder="라이브러리 이름을 입력하세요 (예: nuxt/ui)"
              class="flex-1"
            />
            <UButton
              @click="searchContext7"
              :loading="context7Loading"
              color="primary"
            >
              검색
            </UButton>
          </div>
          <div v-if="context7Results" class="space-y-3">
            <UCard class="p-4">
              <div class="flex items-center justify-between mb-2">
                <h5 class="font-medium text-gray-900 dark:text-white">
                  {{ context7Results.name }}
                </h5>
                <UBadge color="blue" variant="soft">
                  Trust Score: {{ context7Results.trustScore }}
                </UBadge>
              </div>
              <p class="text-sm text-gray-600 dark:text-gray-300 mb-3">
                {{ context7Results.description }}
              </p>
              <div class="flex items-center gap-4 text-sm text-gray-500">
                <span>Code Snippets: {{ context7Results.codeSnippets }}</span>
                <span>Library ID: {{ context7Results.libraryId }}</span>
              </div>
              <div v-if="context7Results.versions" class="mt-2">
                <span class="text-sm text-gray-500">Versions: </span>
                <UBadge
                  v-for="version in context7Results.versions.slice(0, 3)"
                  :key="version"
                  color="gray"
                  variant="soft"
                  size="sm"
                  class="mr-1"
                >
                  {{ version }}
                </UBadge>
              </div>
            </UCard>
          </div>
        </div>
      </div>
    </UCard>

    <!-- MCP 통계 섹션 -->
    <UCard class="mb-8">
      <template #header>
        <h3 class="text-xl font-semibold text-gray-900 dark:text-white">
          📊 MCP 서비스 통계
        </h3>
      </template>

      <div class="grid grid-cols-1 md:grid-cols-4 gap-6">
        <div class="text-center p-4 bg-blue-50 dark:bg-blue-900/20 rounded-lg">
          <div class="text-2xl font-bold text-blue-600 dark:text-blue-400">
            {{ statistics.totalServices }}
          </div>
          <div class="text-sm text-gray-600 dark:text-gray-300">총 서비스</div>
        </div>
        <div class="text-center p-4 bg-green-50 dark:bg-green-900/20 rounded-lg">
          <div class="text-2xl font-bold text-green-600 dark:text-green-400">
            {{ statistics.activeServices }}
          </div>
          <div class="text-sm text-gray-600 dark:text-gray-300">활성 서비스</div>
        </div>
        <div class="text-center p-4 bg-purple-50 dark:bg-purple-900/20 rounded-lg">
          <div class="text-2xl font-bold text-purple-600 dark:text-purple-400">
            {{ statistics.totalLogs }}
          </div>
          <div class="text-sm text-gray-600 dark:text-gray-300">총 로그</div>
        </div>
        <div class="text-center p-4 bg-orange-50 dark:bg-orange-900/20 rounded-lg">
          <div class="text-2xl font-bold text-orange-600 dark:text-orange-400">
            {{ statistics.successRate }}%
          </div>
          <div class="text-sm text-gray-600 dark:text-gray-300">성공률</div>
        </div>
      </div>
    </UCard>

    <!-- MCP 로그 섹션 -->
    <UCard>
      <template #header>
        <div class="flex items-center justify-between">
          <h3 class="text-xl font-semibold text-gray-900 dark:text-white">
            📋 MCP 활동 로그
          </h3>
          <UButton
            @click="clearLogs"
            size="sm"
            variant="ghost"
            color="red"
          >
            로그 지우기
          </UButton>
        </div>
      </template>

      <div class="space-y-2 max-h-64 overflow-y-auto">
        <div
          v-for="(log, index) in mcpLogs"
          :key="index"
          class="p-3 text-sm border rounded"
          :class="getLogClass(log.level)"
        >
          <div class="flex items-center gap-2 mb-1">
            <UIcon
              :name="getLogIcon(log.level)"
              class="w-4 h-4"
            />
            <span class="font-medium">{{ log.service }}</span>
            <span class="text-xs text-gray-500">{{ log.timestamp }}</span>
          </div>
          <p class="text-gray-700 dark:text-gray-300">{{ log.message }}</p>
        </div>
        <div v-if="mcpLogs.length === 0" class="text-center text-gray-500 py-8">
          MCP 활동 로그가 없습니다.
        </div>
      </div>
    </UCard>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useMCP } from '~/composables/useMCP'

// MCP composable 사용
const {
  mcpServices,
  mcpLogs,
  statistics,
  activeServices,
  checkMCPServices,
  searchGitHubRepositories,
  executeDatabaseQuery,
  exploreFileSystem,
  searchContext7Library,
  addLog,
  clearLogs
} = useMCP()

// GitHub 검색
const githubQuery = ref('')
const githubResults = ref([])
const githubLoading = ref(false)

// 데이터베이스 쿼리
const dbQuery = ref('')
const dbResults = ref([])
const dbColumns = ref([])
const dbLoading = ref(false)

// 파일 시스템 탐색
const filePath = ref('')
const fileResults = ref([])
const fileLoading = ref(false)

// Context7 라이브러리 검색
const context7Query = ref('')
const context7Results = ref(null)
const context7Loading = ref(false)

// 로딩 상태
const loading = ref(false)

// GitHub 리포지토리 검색
const searchGitHub = async () => {
  if (!githubQuery.value.trim()) return
  
  githubLoading.value = true
  
  try {
    githubResults.value = await searchGitHubRepositories(githubQuery.value)
  } catch (error) {
    console.error('GitHub 검색 실패:', error)
  } finally {
    githubLoading.value = false
  }
}

// 데이터베이스 쿼리 실행
const executeQuery = async () => {
  if (!dbQuery.value.trim()) return
  
  dbLoading.value = true
  
  try {
    const results = await executeDatabaseQuery(dbQuery.value)
    dbResults.value = results
    dbColumns.value = results.length > 0 ? Object.keys(results[0]) : []
  } catch (error) {
    console.error('데이터베이스 쿼리 실패:', error)
  } finally {
    dbLoading.value = false
  }
}

// 파일 시스템 탐색
const exploreFiles = async () => {
  if (!filePath.value.trim()) return
  
  fileLoading.value = true
  
  try {
    fileResults.value = await exploreFileSystem(filePath.value)
  } catch (error) {
    console.error('파일 시스템 탐색 실패:', error)
  } finally {
    fileLoading.value = false
  }
}

// Context7 라이브러리 검색
const searchContext7 = async () => {
  if (!context7Query.value.trim()) return
  
  context7Loading.value = true
  
  try {
    context7Results.value = await searchContext7Library(context7Query.value)
  } catch (error) {
    console.error('Context7 검색 실패:', error)
  } finally {
    context7Loading.value = false
  }
}

// MCP 서비스 새로고침
const refreshServices = async () => {
  loading.value = true
  
  try {
    await checkMCPServices()
  } catch (error) {
    console.error('MCP 서비스 상태 확인 실패:', error)
  } finally {
    loading.value = false
  }
}

// 로그 클래스 반환
const getLogClass = (level) => {
  switch (level) {
    case 'success':
      return 'border-green-200 bg-green-50 dark:border-green-800 dark:bg-green-900/20'
    case 'error':
      return 'border-red-200 bg-red-50 dark:border-red-800 dark:bg-red-900/20'
    case 'warning':
      return 'border-yellow-200 bg-yellow-50 dark:border-yellow-800 dark:bg-yellow-900/20'
    default:
      return 'border-gray-200 bg-gray-50 dark:border-gray-700 dark:bg-gray-800/50'
  }
}

// 로그 아이콘 반환
const getLogIcon = (level) => {
  switch (level) {
    case 'success':
      return 'i-lucide-check-circle'
    case 'error':
      return 'i-lucide-x-circle'
    case 'warning':
      return 'i-lucide-alert-triangle'
    default:
      return 'i-lucide-info'
  }
}

// 파일 크기 포맷팅
const formatFileSize = (bytes) => {
  if (bytes === 0) return '0 B'
  const k = 1024
  const sizes = ['B', 'KB', 'MB', 'GB']
  const i = Math.floor(Math.log(bytes) / Math.log(k))
  return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i]
}

onMounted(() => {
  addLog('System', 'info', 'MCP 통합 컴포넌트가 초기화되었습니다')
  checkMCPServices()
})
</script>

<style scoped>
.mcp-integration {
  @apply space-y-6;
}
</style>
