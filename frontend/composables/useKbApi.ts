// Nuxt runtime import (type may be unresolved in isolated TS tooling outside Nuxt context)
// @ts-ignore - Nuxt provides this at runtime / via nuxt.d.ts generation
import { useRuntimeConfig } from '#app'

// Common API response shapes (extend as needed)
export interface KbSaveResponse { version_no: number; version_id?: number; updated_at?: string }
export interface KbVersion { id: number; version_no: number; message?: string; created_at?: string }
export interface KbVersionsResponse { versions: KbVersion[] }
export interface KbOutlineItem { level: number; text: string; line: number }
export interface KbOutlineResponse { outline: KbOutlineItem[] }
export interface KbTask { id: string; type: string; status: string; stage?: string; progress?: number; error?: string; updated_at?: string; [k: string]: any }
export interface KbTaskList { tasks: KbTask[] }
export interface KbStructuredDiffLine { type: string; old_line: number|null; new_line: number|null; text?: string; old_text?: string; new_text?: string }
export interface KbStructuredDiffHunk { header: string; lines: KbStructuredDiffLine[] }
export interface KbStructuredDiff { diff_format: string; hunks: KbStructuredDiffHunk[]; v1: number; v2: number }
export interface KbUnifiedDiff { diff_format: string; hunks: { header: string; lines: string[] }[] }

export function useKbApi(){
  const config = useRuntimeConfig()
  function resolveApiBase(): string {
    const configured = (config.public as any)?.apiBaseUrl || 'http://localhost:8000'
    if (typeof window !== 'undefined'){
      try{
        const u = new URL(configured)
        const browserHost = window.location.hostname
        if (u.hostname !== 'localhost' && u.hostname !== '127.0.0.1' && u.hostname !== browserHost){
          const port = u.port || '8000'
          return `${window.location.protocol}//${browserHost}:${port}`
        }
      }catch{/* ignore */}
    }
    return configured
  }
  const apiBase: string = resolveApiBase()
  // NOTE: For production, inject apiKey via runtime config / cookie / header
  const apiKey: string = 'my_mcp_eagle_tiger'

  async function request<T>(url: string, init?: RequestInit, errorMessage = 'request failed'): Promise<T> {
    const r = await fetch(url, init)
    if(!r.ok){
      // Attempt to extract server error detail
      let detail: string|undefined
      try { const data = await r.json(); detail = data?.detail } catch { /* ignore */ }
      throw new Error(detail || `${errorMessage}: ${r.status}`)
    }
    return r.json() as Promise<T>
  }

  async function getItem(path: string): Promise<any>{
    return request<any>(`${apiBase}/api/v1/knowledge-base/item?path=${encodeURIComponent(path)}`, { headers: { 'X-API-Key': apiKey }}, 'getItem failed')
  }

  async function saveItem(path: string, content: string, message?: string, expectedVersion?: number): Promise<KbSaveResponse>{
    return request<KbSaveResponse>(`${apiBase}/api/v1/knowledge-base/item`, {
      method: 'PATCH',
      headers: { 'Content-Type': 'application/json', 'X-API-Key': apiKey },
      body: JSON.stringify({ path, content, message, expected_version_no: expectedVersion })
    }, 'saveItem failed')
  }

  async function listVersions(path: string): Promise<KbVersionsResponse>{
    return request<KbVersionsResponse>(`${apiBase}/api/v1/knowledge-base/versions?path=${encodeURIComponent(path)}`, { headers: { 'X-API-Key': apiKey }}, 'listVersions failed')
  }

  async function outline(content: string): Promise<KbOutlineResponse>{
    return request<KbOutlineResponse>(`${apiBase}/api/v1/knowledge-base/outline`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json', 'X-API-Key': apiKey },
      body: JSON.stringify({ content })
    }, 'outline failed')
  }

  async function startCompose(topic: string, failStage?: string): Promise<KbTask>{
    const qs = new URLSearchParams({ topic })
    if(failStage) qs.append('fail_stage', failStage)
    return request<KbTask>(`${apiBase}/api/v1/knowledge-base/compose/external?${qs.toString()}`, { method: 'POST', headers: { 'X-API-Key': apiKey }}, 'compose failed')
  }

  async function getTask(id: string): Promise<KbTask>{
    return request<KbTask>(`${apiBase}/api/v1/knowledge-base/tasks/${id}`, { headers: { 'X-API-Key': apiKey }}, 'task failed')
  }

  async function diff(path: string, v1: number, v2: number): Promise<KbUnifiedDiff>{
    return request<KbUnifiedDiff>(`${apiBase}/api/v1/knowledge-base/diff?path=${encodeURIComponent(path)}&v1=${v1}&v2=${v2}`, { headers: { 'X-API-Key': apiKey }}, 'diff failed')
  }

  async function structuredDiff(path: string, v1: number, v2: number): Promise<KbStructuredDiff>{
    return request<KbStructuredDiff>(`${apiBase}/api/v1/knowledge-base/diff/structured?path=${encodeURIComponent(path)}&v1=${v1}&v2=${v2}`, { headers: { 'X-API-Key': apiKey }}, 'structured diff failed')
  }

  async function recentTasks(limit = 20): Promise<KbTaskList>{
    return request<KbTaskList>(`${apiBase}/api/v1/knowledge-base/tasks/recent?limit=${limit}`, { headers: { 'X-API-Key': apiKey }}, 'recent tasks failed')
  }

  return { getItem, saveItem, listVersions, outline, startCompose, getTask, diff, structuredDiff, recentTasks }
}
