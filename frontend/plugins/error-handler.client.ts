export default defineNuxtPlugin((nuxtApp) => {
  // 클라이언트 사이드에서만 실행
  if (process.server) return

  // 전역 에러 핸들러
  nuxtApp.hook('app:error', (error) => {
    console.error('App error:', error)
    
    // 401 Unauthorized 에러인 경우에만 로그인 페이지로 리다이렉트
    if (error.statusCode === 401) {
      // 현재 페이지가 이미 로그인 페이지가 아닌 경우에만 리다이렉트
      if (!window.location.pathname.includes('/login')) {
        navigateTo('/login')
      }
    }
  })

  // 라우터 에러 핸들러
  nuxtApp.hook('app:chunkError', (error) => {
    console.error('Chunk error:', error)
  })

  // 네트워크 에러 핸들러
  nuxtApp.hook('app:error:cleared', () => {
    console.log('Error cleared')
  })
})
