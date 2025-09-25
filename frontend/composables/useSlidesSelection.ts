// frontend/composables/useSlidesSelection.ts
import { ref, computed } from 'vue'

interface SlidesSelectionResponse {
  success: boolean
  slides_selection: string[]
  message: string
  file_path?: string
}

export const useSlidesSelection = () => {
  const slidesSelection = ref<string[]>([])
  const loading = ref(false)
  const error = ref<string | null>(null)

  /**
   * 슬라이드 선택 정보를 서버에서 가져옵니다.
   */
  const fetchSlidesSelection = async (): Promise<void> => {
    loading.value = true
    error.value = null

    try {
      const response = await $fetch<SlidesSelectionResponse>('/api/v1/curriculum/slides-selection')
      
      if (response.success) {
        slidesSelection.value = response.slides_selection
      } else {
        error.value = response.message
        slidesSelection.value = []
      }
    } catch (err) {
      console.error('슬라이드 선택 정보 로드 실패:', err)
      error.value = '슬라이드 선택 정보를 불러올 수 없습니다.'
      slidesSelection.value = []
    } finally {
      loading.value = false
    }
  }

  /**
   * 특정 슬라이드가 선택되어 있는지 확인합니다.
   */
  const isSlideSelected = (slideName: string): boolean => {
    return slidesSelection.value.includes(slideName)
  }

  /**
   * 선택된 슬라이드 개수를 반환합니다.
   */
  const selectedCount = computed(() => slidesSelection.value.length)

  /**
   * 선택된 슬라이드가 있는지 확인합니다.
   */
  const hasSelection = computed(() => slidesSelection.value.length > 0)

  /**
   * 선택된 슬라이드 목록을 문자열로 반환합니다.
   */
  const selectionText = computed(() => {
    if (slidesSelection.value.length === 0) {
      return '선택된 슬라이드가 없습니다.'
    }
    return slidesSelection.value.join(', ')
  })

  return {
    // 상태
    slidesSelection: readonly(slidesSelection),
    loading: readonly(loading),
    error: readonly(error),
    
    // 계산된 속성
    selectedCount,
    hasSelection,
    selectionText,
    
    // 메서드
    fetchSlidesSelection,
    isSlideSelected
  }
}
