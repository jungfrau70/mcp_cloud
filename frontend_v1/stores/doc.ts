import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import { useKbApi } from '~/composables/useKbApi'

export const useDocStore = defineStore('doc', () => {
  const api = useKbApi()
  const path = ref<string>('')
  const content = ref<string>('')
  const loading = ref(false)
  const dirty = ref(false)
  const version = ref<number|undefined>()
  const baseVersion = ref<number|undefined>()
  const error = ref<string|undefined>()

  async function open(p: string){
    loading.value = true
    error.value = undefined
    try {
      path.value = p
      const data: any = await api.getItem(p)
      content.value = data.content || ''
      version.value = data.version_no
      baseVersion.value = data.version_no
      dirty.value = false
    } catch(e: any){
      error.value = e.message || 'load failed'
    } finally { loading.value = false }
  }

  function update(newContent: string){
    dirty.value = newContent !== content.value
    content.value = newContent
  }

  async function save(message?: string){
    if(!path.value) return
    try {
      const res = await api.saveItem(path.value, content.value, message, version.value)
      version.value = res.version_no
      baseVersion.value = res.version_no
      dirty.value = false
      return { conflict: false, version: res.version_no }
    } catch(e:any){
      if(e.message?.includes('409')){
        return { conflict: true }
      }
      error.value = e.message
      return { conflict: false, error: e.message }
    }
  }

  const status = computed(()=> loading.value ? 'loading' : (dirty.value ? 'modified' : 'clean'))

  return { path, content, version, baseVersion, loading, dirty, error, status, open, update, save }
})
