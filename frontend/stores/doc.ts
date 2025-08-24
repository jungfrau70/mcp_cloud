import { defineStore } from 'pinia'
import { ref, computed, watch } from 'vue'
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
      // persist last opened KB path
      try{ if(typeof window!=='undefined') localStorage.setItem('kb_last_path', p) }catch{}
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

  // Wait until the current document is fully loaded (and optionally matches expected path)
  function whenLoaded(expectedPath?: string): Promise<void> {
    return new Promise((resolve) => {
      if (!loading.value && (!expectedPath || path.value === expectedPath)) {
        resolve();
        return;
      }
      const stop = watch([loading, path], () => {
        if (!loading.value && (!expectedPath || path.value === expectedPath)) {
          stop();
          resolve();
        }
      });
    })
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

  return { path, content, version, baseVersion, loading, dirty, error, status, open, update, save, whenLoaded }
})
