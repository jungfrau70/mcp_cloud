<template>
  <div class="p-4 bg-white rounded-lg shadow-sm border">
    <div class="flex items-center justify-between mb-4">
      <h3 class="text-lg font-semibold text-gray-800">학습 진도</h3>
      <button 
        @click="refreshProgress" 
        class="text-sm px-3 py-1 bg-blue-100 text-blue-700 rounded hover:bg-blue-200"
        :disabled="isLoading"
      >
        {{ isLoading ? '새로고침 중...' : '새로고침' }}
      </button>
    </div>

    <!-- 전체 진도 요약 -->
    <div class="mb-6 p-4 bg-gray-50 rounded-lg">
      <h4 class="text-sm font-medium text-gray-700 mb-2">전체 진도 요약</h4>
      <div class="grid grid-cols-2 gap-4 text-sm">
        <div>
          <span class="text-gray-600">수강 과정:</span>
          <span class="font-semibold ml-2">{{ overallStats.totalCourses }}개</span>
        </div>
        <div>
          <span class="text-gray-600">평균 진도:</span>
          <span class="font-semibold ml-2 text-blue-600">{{ overallStats.averageProgress }}%</span>
        </div>
        <div>
          <span class="text-gray-600">완료 단계:</span>
          <span class="font-semibold ml-2">{{ overallStats.totalCompletedSteps }}개</span>
        </div>
        <div>
          <span class="text-gray-600">전체 단계:</span>
          <span class="font-semibold ml-2">{{ overallStats.totalSteps }}개</span>
        </div>
      </div>
    </div>

    <!-- 과정별 진도 목록 -->
    <div v-if="Object.keys(courseStats).length > 0">
      <h4 class="text-sm font-medium text-gray-700 mb-3">과정별 진도</h4>
      <div class="space-y-3">
        <div 
          v-for="(stats, courseId) in courseStats" 
          :key="courseId"
          class="p-3 border rounded-lg hover:bg-gray-50 transition-colors"
          :class="{ 'border-blue-300 bg-blue-50': currentCourse === courseId }"
        >
          <div class="flex items-center justify-between mb-2">
            <h5 class="font-medium text-gray-800">{{ stats.courseName }}</h5>
            <span class="text-sm text-blue-600 font-semibold">{{ stats.progressPercentage }}%</span>
          </div>
          
          <!-- 진행률 바 -->
          <div class="w-full bg-gray-200 rounded-full h-2 mb-2">
            <div 
              class="bg-blue-600 h-2 rounded-full transition-all duration-300"
              :style="{ width: `${stats.progressPercentage}%` }"
            ></div>
          </div>
          
          <div class="flex justify-between text-xs text-gray-600">
            <span>{{ stats.completedSteps }} / {{ stats.totalSteps }} 단계 완료</span>
            <span>{{ formatDate(stats.lastAccessed) }}</span>
          </div>
        </div>
      </div>
    </div>

    <!-- 진도가 없는 경우 -->
    <div v-else class="text-center py-8 text-gray-500">
      <div class="text-4xl mb-2">📚</div>
      <p>아직 시작한 과정이 없습니다.</p>
      <p class="text-sm mt-1">커리큘럼에서 과정을 시작해보세요!</p>
    </div>

    <!-- 진도 초기화 버튼 (관리자용) -->
    <div v-if="isAdmin" class="mt-6 pt-4 border-t">
      <button 
        @click="showResetDialog = true"
        class="text-sm px-3 py-1 bg-red-100 text-red-700 rounded hover:bg-red-200"
      >
        진도 초기화
      </button>
    </div>

    <!-- 진도 초기화 확인 다이얼로그 -->
    <div v-if="showResetDialog" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div class="bg-white rounded-lg p-6 max-w-md w-full mx-4">
        <h3 class="text-lg font-semibold text-gray-800 mb-4">진도 초기화</h3>
        <p class="text-gray-600 mb-6">정말로 모든 학습 진도를 초기화하시겠습니까? 이 작업은 되돌릴 수 없습니다.</p>
        <div class="flex justify-end space-x-3">
          <button 
            @click="showResetDialog = false"
            class="px-4 py-2 text-gray-600 border border-gray-300 rounded hover:bg-gray-50"
          >
            취소
          </button>
          <button 
            @click="resetAllProgress"
            class="px-4 py-2 bg-red-600 text-white rounded hover:bg-red-700"
          >
            초기화
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useProgressStore } from '~/stores/progress'
import { useAuthStore } from '~/stores/auth'

const progressStore = useProgressStore()
const authStore = useAuthStore()

const isLoading = ref(false)
const showResetDialog = ref(false)

// 현재 과정
const currentCourse = computed(() => progressStore.currentCourse)

// 과정별 진도 통계
const courseStats = computed(() => progressStore.courseStats)

// 전체 진도 통계
const overallStats = computed(() => progressStore.overallStats)

// 관리자 여부 확인
const isAdmin = computed(() => {
  const role = authStore.role?.toLowerCase()
  return role === 'admin' || role === 'administrator'
})

// 날짜 포맷팅
function formatDate(dateString) {
  try {
    const date = new Date(dateString)
    return date.toLocaleDateString('ko-KR', {
      year: 'numeric',
      month: 'short',
      day: 'numeric',
      hour: '2-digit',
      minute: '2-digit'
    })
  } catch {
    return '알 수 없음'
  }
}

// 진도 새로고침
async function refreshProgress() {
  isLoading.value = true
  try {
    // 진도 스토어에서 데이터 다시 로드
    progressStore.loadProgress()
    
    // 잠시 대기 (UI 피드백용)
    await new Promise(resolve => setTimeout(resolve, 500))
  } catch (error) {
    console.error('Failed to refresh progress:', error)
  } finally {
    isLoading.value = false
  }
}

// 모든 진도 초기화
function resetAllProgress() {
  progressStore.resetProgress()
  showResetDialog.value = false
}

// 컴포넌트 마운트 시 진도 로드
onMounted(() => {
  progressStore.loadProgress()
})
</script>
