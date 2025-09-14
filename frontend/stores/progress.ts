import { defineStore } from 'pinia'
import { ref, computed } from 'vue'

export interface CourseProgress {
  courseId: string
  courseName: string
  currentStep: number
  totalSteps: number
  completedSteps: number[]
  lastAccessed: string
  progressPercentage: number
}

export interface StepInfo {
  stepId: string
  stepName: string
  stepPath: string
  isCompleted: boolean
  completedAt?: string
}

export const useProgressStore = defineStore('progress', () => {
  const userProgress = ref<Record<string, CourseProgress>>({})
  const currentCourse = ref<string | null>(null)
  const currentStep = ref<string | null>(null)

  // 현재 과정의 진도 정보
  const currentCourseProgress = computed(() => {
    if (!currentCourse.value) return null
    return userProgress.value[currentCourse.value] || null
  })

  // 현재 과정의 진도율
  const currentProgressPercentage = computed(() => {
    const progress = currentCourseProgress.value
    if (!progress) return 0
    return Math.round((progress.completedSteps.length / progress.totalSteps) * 100)
  })

  // 과정별 진도 정보 초기화
  function initializeCourseProgress(courseId: string, courseName: string, totalSteps: number) {
    if (!userProgress.value[courseId]) {
      userProgress.value[courseId] = {
        courseId,
        courseName,
        currentStep: 1,
        totalSteps,
        completedSteps: [],
        lastAccessed: new Date().toISOString(),
        progressPercentage: 0
      }
    }
    currentCourse.value = courseId
    saveProgress()
  }

  // 단계 완료 처리
  function completeStep(stepId: string) {
    if (!currentCourse.value) return

    const progress = userProgress.value[currentCourse.value]
    if (!progress) return

    if (!progress.completedSteps.includes(stepId)) {
      progress.completedSteps.push(stepId)
      progress.progressPercentage = Math.round((progress.completedSteps.length / progress.totalSteps) * 100)
      progress.lastAccessed = new Date().toISOString()
      saveProgress()
    }
  }

  // 현재 단계 설정
  function setCurrentStep(stepId: string) {
    currentStep.value = stepId
    if (currentCourse.value) {
      const progress = userProgress.value[currentCourse.value]
      if (progress) {
        progress.lastAccessed = new Date().toISOString()
        saveProgress()
      }
    }
  }

  // 과정 전환
  function switchCourse(courseId: string) {
    currentCourse.value = courseId
    if (userProgress.value[courseId]) {
      userProgress.value[courseId].lastAccessed = new Date().toISOString()
      saveProgress()
    }
  }

  // 진도 저장 (localStorage)
  function saveProgress() {
    if (typeof window !== 'undefined' && typeof localStorage !== 'undefined') {
      try {
        localStorage.setItem('user_progress', JSON.stringify(userProgress.value))
        localStorage.setItem('current_course', currentCourse.value || '')
        localStorage.setItem('current_step', currentStep.value || '')
      } catch (error) {
        console.warn('Failed to save progress:', error)
      }
    }
  }

  // 진도 로드 (localStorage)
  function loadProgress() {
    if (typeof window !== 'undefined' && typeof localStorage !== 'undefined') {
      try {
        const savedProgress = localStorage.getItem('user_progress')
        if (savedProgress) {
          userProgress.value = JSON.parse(savedProgress)
        }

        const savedCourse = localStorage.getItem('current_course')
        if (savedCourse) {
          currentCourse.value = savedCourse
        }

        const savedStep = localStorage.getItem('current_step')
        if (savedStep) {
          currentStep.value = savedStep
        }
      } catch (error) {
        console.warn('Failed to load progress:', error)
      }
    }
  }

  // 진도 초기화
  function resetProgress(courseId?: string) {
    if (courseId) {
      delete userProgress.value[courseId]
      if (currentCourse.value === courseId) {
        currentCourse.value = null
        currentStep.value = null
      }
    } else {
      userProgress.value = {}
      currentCourse.value = null
      currentStep.value = null
    }
    saveProgress()
  }

  // 과정별 진도 통계
  const courseStats = computed(() => {
    const stats: Record<string, {
      courseName: string
      progressPercentage: number
      completedSteps: number
      totalSteps: number
      lastAccessed: string
    }> = {}

    Object.values(userProgress.value).forEach(progress => {
      stats[progress.courseId] = {
        courseName: progress.courseName,
        progressPercentage: progress.progressPercentage,
        completedSteps: progress.completedSteps.length,
        totalSteps: progress.totalSteps,
        lastAccessed: progress.lastAccessed
      }
    })

    return stats
  })

  // 전체 진도 통계
  const overallStats = computed(() => {
    const courses = Object.values(userProgress.value)
    if (courses.length === 0) {
      return {
        totalCourses: 0,
        averageProgress: 0,
        totalCompletedSteps: 0,
        totalSteps: 0
      }
    }

    const totalCompletedSteps = courses.reduce((sum, course) => sum + course.completedSteps.length, 0)
    const totalSteps = courses.reduce((sum, course) => sum + course.totalSteps, 0)
    const averageProgress = totalSteps > 0 ? Math.round((totalCompletedSteps / totalSteps) * 100) : 0

    return {
      totalCourses: courses.length,
      averageProgress,
      totalCompletedSteps,
      totalSteps
    }
  })

  return {
    userProgress,
    currentCourse,
    currentStep,
    currentCourseProgress,
    currentProgressPercentage,
    courseStats,
    overallStats,
    initializeCourseProgress,
    completeStep,
    setCurrentStep,
    switchCourse,
    saveProgress,
    loadProgress,
    resetProgress
  }
})
