export default defineNuxtRouteMiddleware((to) => {
  // 지식베이스는 공개 열람 허용: 앱 내에서는 로그인 리다이렉트하지 않음
  // (서버 측 Authelia 정책으로 보호되는 API만 접근 제한)
  return
})


