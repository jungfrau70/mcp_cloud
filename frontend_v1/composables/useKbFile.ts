import { ref } from 'vue'
import { useKbApi } from './useKbApi'
import { stripBasePath } from '../utils/path'

interface SaveOptions { message?: string; force?: boolean }

export function useKbFile(){
  const api = useKbApi()
  const content = ref('')
  const path = ref('')
  const loading = ref(false)
  const error = ref<string|undefined>()
  const lastVersion = ref<number|undefined>()
  let currentAbort: AbortController | null = null

  async function load(targetPath: string){
    if(currentAbort){ currentAbort.abort() }
    currentAbort = new AbortController()
    loading.value = true
    error.value = undefined
    try {
      path.value = targetPath
      const res = await fetch(`${apiBase()}/api/kb/item?path=${encodeURIComponent(stripBasePath(targetPath))}`, { headers: headers(), signal: currentAbort.signal })
      if(!res.ok) throw new Error('Load failed')
      const data = await res.json()
      content.value = data.content || ''
      lastVersion.value = data.version_no
    } catch(e:any){
      if(e.name === 'AbortError') return
      error.value = e.message || 'Load error'
    } finally {
      if(currentAbort?.signal.aborted) return
      loading.value = false
    }
  }

  function apiBase(){
    // @ts-ignore Nuxt runtime
    const config = useRuntimeConfig()
    return config.public.apiBaseUrl || 'http://localhost:8000'
  }
  function headers(){ return { 'X-API-Key': 'my_mcp_eagle_tiger', 'Content-Type': 'application/json' } }

  async function save(newContent: string, opts: SaveOptions = {}){
    const expected = opts.force ? undefined : lastVersion.value
    const res = await fetch(`${apiBase()}/api/kb/item`, {
      method: 'PATCH',
      headers: headers(),
      body: JSON.stringify({ path: stripBasePath(path.value), content: newContent, message: opts.message, expected_version_no: expected })
    })
    if(res.status === 409){
      return { conflict: true }
    }
    if(!res.ok) throw new Error('Save failed')
    const data = await res.json()
    lastVersion.value = data.version_no
    content.value = newContent
    return { conflict: false, data }
  }

  return { content, path, loading, error, lastVersion, load, save }
}
