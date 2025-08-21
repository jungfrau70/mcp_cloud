import { defineStore } from 'pinia'

export interface Toast { id: string; type: 'info'|'success'|'warn'|'error'; msg: string; ts: number; ttl?: number }

export const useToastStore = defineStore('toast', {
  state: () => ({ items: [] as Toast[] }),
  actions: {
    push(type: Toast['type'], msg: string, ttl = 4000){
      const id = crypto.randomUUID()
      this.items.push({ id, type, msg, ts: Date.now(), ttl })
      setTimeout(()=> this.remove(id), ttl)
    },
    remove(id: string){ this.items = this.items.filter(t=>t.id!==id) }
  }
})
