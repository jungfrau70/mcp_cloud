// Nuxt runtime import (type may be unresolved in isolated TS tooling outside Nuxt context)
// @ts-ignore - Nuxt provides this at runtime / via nuxt.d.ts generation
import { useRuntimeConfig } from '#app'

// Types for KB API responses (aligned with backend models)
export interface KbSaveResponse { success?: boolean; version_id?: number; version_no: number; updated_at?: string }
export interface KbVersion { id: number; version_no: number; message?: string; created_at?: string }
export interface KbVersionsResponse { versions: KbVersion[] }
export interface KbOutlineItem { level: number; text: string; line: number }
export interface KbOutlineResponse { outline: KbOutlineItem[] }
export interface KbTask { id: string; type: string; status: string; stage?: string; progress?: number; error?: string; updated_at?: string; [k: string]: any }
export interface KbTaskList { tasks: KbTask[] }
export interface KbUnifiedDiff { diff_format: string; hunks: { header: string; lines: string[] }[] }
export interface KbStructuredDiffHunk { header: string; lines: { type: string; old_line: number|null; new_line: number|null; text?: string; old_text?: string; new_text?: string }[] }
export interface KbStructuredDiff { diff_format: string; hunks: KbStructuredDiffHunk[]; v1: number; v2: number }

export function resolveApiBase(): string {
  const config = useRuntimeConfig()
  const configured = (config.public as any)?.apiBaseUrl || 'https://api.gostock.us'
  if (typeof window !== 'undefined'){
    try{
      const u = new URL(configured)
      const browserHost = window.location.hostname
      if (u.hostname !== 'localhost' && u.hostname !== '127.0.0.1' && u.hostname !== 'api.gostock.us' && u.hostname !== browserHost){
        const port = u.port || '8000'
        // When using https backend, keep https scheme even if frontend runs on http
        const scheme = u.protocol.replace(':','') || 'https'
        return `${scheme}://${browserHost}:${port}`
      }
    }catch{/* ignore */}
  }
  return configured
}

export function useKbApi(){
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
    // Use content-saving endpoint (v1 alias is rename-only)
    return request<KbSaveResponse>(`${apiBase}/api/_deprecated/kb/item`, {
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

  async function uploadAsset(file: File, subdir = 'assets'): Promise<{ path: string }>{
    const form = new FormData()
    form.append('file', file)
    form.append('subdir', subdir)
    const r = await fetch(`${apiBase}/api/v1/assets/upload`, { method: 'POST', headers: { 'X-API-Key': apiKey }, body: form })
    if(!r.ok){
      let detail: string|undefined
      try{ const d = await r.json(); detail = (d as any)?.detail }catch{}
      throw new Error(detail || `upload failed: ${r.status}`)
    }
    return r.json()
  }

  async function transform(text: string, kind: 'table'|'mermaid'|'summary', opts?: { cols?: number; diagramType?: 'flow'|'sequence'|'gantt'; summaryLen?: number; use_rag?: boolean }): Promise<{ result: string }>{
    return request<{ result: string }>(`${apiBase}/api/v1/knowledge-base/transform`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json', 'X-API-Key': apiKey },
      body: JSON.stringify({ text, kind, ...(opts||{}) })
    }, 'transform failed')
  }

  async function lint(text: string): Promise<{ issues: { line:number; column:number; message:string; rule?:string }[] }>{
    return request<{ issues: { line:number; column:number; message:string; rule?:string }[] }>(`${apiBase}/api/v1/knowledge-base/lint`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json', 'X-API-Key': apiKey },
      body: JSON.stringify({ text })
    }, 'lint failed')
  }

  // Trending categories
  async function listTrending(): Promise<{ categories: { name:string; query:string; enabled:boolean }[] }>{
    return request(`${apiBase}/api/v1/trending/categories`, { headers: { 'X-API-Key': apiKey }}, 'trending list failed')
  }
  async function upsertTrending(item: { name:string; query:string; enabled?: boolean }): Promise<{ ok: boolean }>{
    return request(`${apiBase}/api/v1/trending/categories`, {
      method: 'POST', headers: { 'Content-Type': 'application/json', 'X-API-Key': apiKey }, body: JSON.stringify(item)
    }, 'trending upsert failed')
  }
  async function deleteTrending(name: string): Promise<{ ok: boolean }>{
    return request(`${apiBase}/api/v1/trending/categories/${encodeURIComponent(name)}`, {
      method: 'DELETE', headers: { 'X-API-Key': apiKey }
    }, 'trending delete failed')
  }
  async function runTrendingNow(): Promise<{ ok: boolean }>{
    return request(`${apiBase}/api/v1/trending/run-now`, { method: 'POST', headers: { 'X-API-Key': apiKey } }, 'trending run failed')
  }

  return { getItem, saveItem, listVersions, outline, startCompose, getTask, diff, structuredDiff, recentTasks, uploadAsset, transform, lint, listTrending, upsertTrending, deleteTrending, runTrendingNow, request }
}
