import { defineStore } from 'pinia'

type AuthState = {
  token: string | null
  email: string | null
  role: string | null
}

export const useAuthStore = defineStore('auth', {
  state: (): AuthState => ({
    token: null,
    email: null,
    role: null,
  }),
  actions: {
    loadFromStorage(){
      if (typeof window !== 'undefined'){
        const t = localStorage.getItem('auth_token')
        const e = localStorage.getItem('auth_email')
        const r = localStorage.getItem('auth_role')
        if (t) this.token = t
        if (e) this.email = e
        if (r) this.role = r
      }
    },
    setToken(token: string){
      this.token = token
      if (typeof window !== 'undefined'){
        localStorage.setItem('auth_token', token)
      }
    },
    setUser(email: string|null, role: string|null){
      this.email = email
      this.role = role
      if (typeof window !== 'undefined'){
        if (email) localStorage.setItem('auth_email', email)
        if (role) localStorage.setItem('auth_role', role)
      }
    },
    clear(){
      this.token = null
      this.email = null
      this.role = null
      if (typeof window !== 'undefined'){
        localStorage.removeItem('auth_token')
        localStorage.removeItem('auth_email')
        localStorage.removeItem('auth_role')
      }
    }
  }
})


