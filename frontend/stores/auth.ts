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
      if (process.client){
        const t = localStorage.getItem('auth_token')
        if (t) this.token = t
      }
    },
    setToken(token: string){
      this.token = token
      if (process.client){
        localStorage.setItem('auth_token', token)
      }
    },
    setUser(email: string|null, role: string|null){
      this.email = email
      this.role = role
    },
    clear(){
      this.token = null
      this.email = null
      this.role = null
      if (process.client){
        localStorage.removeItem('auth_token')
      }
    }
  }
})


