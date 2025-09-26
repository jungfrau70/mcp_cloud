// frontend/composables/useGeminiApiKey.ts
import { ref, computed } from 'vue'
import { useAuthStore } from '~/stores/auth'
import { $fetch } from 'ofetch'

export const useGeminiApiKey = () => {
  const auth = useAuthStore()
  const userProfile = ref<any>(null)
  const isLoading = ref(false)
  const error = ref<string | null>(null)
  
  // 사용자 프로필에서 Gemini API 키 가져오기
  const fetchUserProfile = async () => {
    console.log('fetchUserProfile called, auth.token:', !!auth.token)
    if (!auth.token) {
      userProfile.value = null
      return
    }

    try {
      isLoading.value = true
      error.value = null
      
      const base = config.public.apiBaseUrl || 'http://localhost:8000'
      
      console.log('Fetching profile from:', `${base}/api/v1/profile/me`)
      const response = await $fetch(`${base}/api/v1/profile/me`, {
        headers: {
          'Authorization': `Bearer ${auth.token}`,
          'X-API-Key': 'my_mcp_eagle_tiger'
        }
      })
      
      console.log('Profile response:', response)
      userProfile.value = response
    } catch (err) {
      console.error('Failed to fetch user profile:', err)
      error.value = '프로필을 불러올 수 없습니다.'
      userProfile.value = null
    } finally {
      isLoading.value = false
    }
  }

  // Gemini API 키가 있는지 확인
  const hasGeminiApiKey = computed(() => {
    return !!(userProfile.value?.gemini_api_key?.trim())
  })

  // API 키가 유효한지 확인 (간단한 형식 검증)
  const isValidGeminiApiKey = computed(() => {
    const apiKey = userProfile.value?.gemini_api_key?.trim()
    if (!apiKey) return false
    
    // Gemini API 키는 보통 AIzaSy로 시작
    return apiKey.startsWith('AIzaSy') && apiKey.length > 20
  })

  // 채팅 기능을 사용할 수 있는지 확인
  const canUseChat = computed(() => {
    const result = hasGeminiApiKey.value && isValidGeminiApiKey.value
    console.log('canUseChat computed:', {
      hasGeminiApiKey: hasGeminiApiKey.value,
      isValidGeminiApiKey: isValidGeminiApiKey.value,
      canUseChat: result,
      userProfile: userProfile.value
    })
    return result
  })

  // API 키 상태 메시지
  const apiKeyStatus = computed(() => {
    if (!userProfile.value) return '프로필을 불러오는 중...'
    if (!hasGeminiApiKey.value) return 'Gemini API 키가 설정되지 않았습니다.'
    if (!isValidGeminiApiKey.value) return 'API 키 형식이 올바르지 않습니다.'
    return 'API 키가 설정되어 있습니다.'
  })

  // 초기 로드 시 프로필 가져오기
  if (process.client && auth.token && !userProfile.value) {
    fetchUserProfile()
  }

  return {
    userProfile,
    isLoading,
    error,
    hasGeminiApiKey,
    isValidGeminiApiKey,
    canUseChat,
    apiKeyStatus,
    fetchUserProfile
  }
}
