import { ref } from 'vue'
import { useKbApi } from './useKbApi'
import { cleanApiPath, prepareApiPath, decodeKoreanPath } from '../utils/path'

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
      // 한글 파일명을 포함한 경로 정리 및 인코딩
      const preparedPath = prepareApiPath(targetPath)
      console.log('Loading path:', { original: targetPath, prepared: preparedPath })
      const res = await fetch(`${apiBase()}/v1/knowledge-base/item?path=${preparedPath}`, { headers: headers(), signal: currentAbort.signal })
      if(!res.ok) {
        const errorText = await res.text()
        console.error('API Error:', res.status, errorText)
        throw new Error(`Load failed: ${res.status} ${errorText}`)
      }
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
    const configured = (config.public as any)?.apiBaseUrl || '/api'
    // 이미 /api가 포함되어 있으면 그대로 사용, 아니면 추가
    const baseUrl = configured.includes('/api') ? configured : `${configured}/api`
    
    if (typeof window !== 'undefined'){
      try{
        const u = new URL(baseUrl)
        const browserHost = window.location.hostname
        if (u.origin === 'null') return baseUrl
        if (u.hostname !== 'localhost' && u.hostname !== '127.0.0.1' && u.hostname !== 'api.goldencircle.us' && u.hostname !== browserHost){
          const port = u.port || '8000'
          const scheme = u.protocol.replace(':','') || 'https'
          return `${scheme}://${browserHost}:${port}/api`
        }
      }catch{/* ignore */}
    }
    return baseUrl
  }
  function headers(){ return { 'X-API-Key': 'my_mcp_eagle_tiger', 'Content-Type': 'application/json' } }

  async function save(newContent: string, opts: SaveOptions = {}){
    const expected = opts.force ? undefined : lastVersion.value
    const preparedPath = prepareApiPath(path.value)
    console.log('Saving path:', { original: path.value, prepared: preparedPath })
    const res = await fetch(`${apiBase()}/v1/knowledge-base/item`, {
      method: 'PATCH',
      headers: headers(),
      body: JSON.stringify({ path: preparedPath, content: newContent, message: opts.message, expected_version_no: expected })
    })
    if(res.status === 409){
      return { conflict: true }
    }
    if(!res.ok) {
      const errorText = await res.text()
      console.error('Save API Error:', res.status, errorText)
      throw new Error(`Save failed: ${res.status} ${errorText}`)
    }
    const data = await res.json()
    lastVersion.value = data.version_no
    content.value = newContent
    return { conflict: false, data }
  }

  return { content, path, loading, error, lastVersion, load, save }
}
