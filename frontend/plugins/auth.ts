import { useAuthStore } from '~/stores/auth'

export default defineNuxtPlugin(async (nuxtApp) => {
  if (process.server) return
  
  // 클라이언트 사이드에서만 실행
  if (typeof window === 'undefined') return
  
  try {
    const auth = useAuthStore(nuxtApp.$pinia)
    auth.loadFromStorage()
  } catch (e) {
    console.warn('Failed to load auth state from storage', e)
  }
})
