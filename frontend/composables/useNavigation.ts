export const useNavigation = () => {
  const router = useRouter()
  const route = useRoute()
  
  // 네비게이션 히스토리를 추적하는 배열
  const navigationHistory = ref<string[]>([])
  
  // 현재 경로를 히스토리에 추가
  const addToHistory = (path: string) => {
    if (navigationHistory.value.length === 0 || 
        navigationHistory.value[navigationHistory.value.length - 1] !== path) {
      navigationHistory.value.push(path)
      
      // 히스토리 크기 제한 (최대 10개)
      if (navigationHistory.value.length > 10) {
        navigationHistory.value.shift()
      }
    }
  }
  
  // 안전한 뒤로가기 함수
  const safeGoBack = () => {
    // 브라우저 히스토리 확인
    if (window.history.length > 1) {
      // referrer 확인
      const referrer = document.referrer
      const currentOrigin = window.location.origin
      
      // referrer가 있고, 현재 도메인과 같으며, 로그인/회원가입 페이지가 아닌 경우
      if (referrer && 
          referrer.startsWith(currentOrigin) && 
          !referrer.includes('/login') && 
          !referrer.includes('/register') &&
          !referrer.includes('/verify-email')) {
        window.history.back()
        return
      }
    }
    
    // 로그인/회원가입 페이지는 제외하고 이전 페이지 찾기
    const validHistory = navigationHistory.value
      .slice(0, -1) // 현재 페이지 제외
      .filter(path => 
        !path.includes('/login') && 
        !path.includes('/register') &&
        !path.includes('/verify-email')
      )
    
    if (validHistory.length > 0) {
      const previousPath = validHistory[validHistory.length - 1]
      navigationHistory.value.pop() // 현재 페이지 제거
      router.push(previousPath)
    } else {
      // 유효한 이전 페이지가 없으면 지식베이스 홈으로
      router.push('/knowledge-base')
    }
  }
  
  // 현재 경로를 히스토리에 추가 (라우트 변경 시)
  watch(() => route.path, (newPath) => {
    addToHistory(newPath)
  }, { immediate: true })
  
  return {
    navigationHistory: readonly(navigationHistory),
    safeGoBack,
    addToHistory
  }
}
