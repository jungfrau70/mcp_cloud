import { defineStore } from 'pinia'

export interface Toast { id: string; type: 'info'|'success'|'warn'|'error'; msg: string; ts: number; ttl?: number; link?: { label: string; path: string } }

export const useToastStore = defineStore('toast', {
  state: () => ({ items: [] as Toast[] }),
  actions: {
    push(type: Toast['type'], msg: string, ttl = 4000){
      const id = (typeof crypto !== 'undefined' && crypto.randomUUID) ? crypto.randomUUID() : String(Date.now())
      this.items.push({ id, type, msg, ts: Date.now(), ttl })
      setTimeout(()=> this.remove(id), ttl)
    },
    pushWithLink(type: Toast['type'], msg: string, link: { label: string; path: string }, ttl = 6000){
      const id = (typeof crypto !== 'undefined' && crypto.randomUUID) ? crypto.randomUUID() : String(Date.now())
      this.items.push({ id, type, msg, ts: Date.now(), ttl, link })
      setTimeout(()=> this.remove(id), ttl)
    },
    remove(id: string){ this.items = this.items.filter(t=>t.id!==id) }
  }
})
