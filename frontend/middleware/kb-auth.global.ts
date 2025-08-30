export default defineNuxtRouteMiddleware((to) => {
  // KB 경로에만 적용: 비로그인 사용자는 /login 으로 리디렉트
  if (!to.path.startsWith('/knowledge-base')) return
  const user = useState<any>('user')
  if (!user.value) {
    return navigateTo({ path: '/login', query: { redirect: to.fullPath } })
  }
})


