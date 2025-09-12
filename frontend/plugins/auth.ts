import { useAuthStore } from '~/stores/auth'

export default defineNuxtPlugin(async (nuxtApp) => {
  if (process.server) return
  const auth = useAuthStore(nuxtApp.$pinia)
  try {
    auth.loadFromStorage()
  } catch (e) {
    console.warn('Failed to load auth state from storage', e)
  }
})
