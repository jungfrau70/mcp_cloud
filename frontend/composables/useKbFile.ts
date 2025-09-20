import { ref } from 'vue'
import { useKbApi, resolveApiBase } from './useKbApi'
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
      console.log('Loading path:', { 
        original: targetPath, 
        prepared: preparedPath,
        isAbsolute: preparedPath.startsWith('mcp_knowledge_base/')
      })
      const apiUrl = `${resolveApiBase()}/v1/knowledge-base/item?path=${preparedPath}`
      console.log('DEBUG: useKbFile API URL:', apiUrl)
      const res = await fetch(apiUrl, { headers: headers(), signal: currentAbort.signal })
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

  function headers(){ return { 'X-API-Key': 'my_mcp_eagle_tiger', 'Content-Type': 'application/json' } }

  async function save(newContent: string, opts: SaveOptions = {}){
    const expected = opts.force ? undefined : lastVersion.value
    const preparedPath = prepareApiPath(path.value)
    console.log('Saving path:', { original: path.value, prepared: preparedPath })
    const res = await fetch(`${resolveApiBase()}/v1/knowledge-base/item`, {
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
