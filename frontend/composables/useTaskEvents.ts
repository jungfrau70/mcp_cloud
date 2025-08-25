import { onBeforeUnmount } from 'vue'
import { resolveApiBase } from '~/composables/useKbApi'

type TaskEvent = {
  task_id: string
  type: string
  status?: string
  stage?: string
  progress?: number
  error?: string
}

let socket: WebSocket | null = null
let listeners: { [type: string]: ((e: TaskEvent) => void)[] } = {}
let manualClose = false
let reconnectAttempts = 0
let heartbeatTimer: any = null
let pongTimeout: any = null

function scheduleHeartbeat(){
  clearTimeout(heartbeatTimer)
  heartbeatTimer = setTimeout(() => {
    if(socket && socket.readyState === WebSocket.OPEN){
      try { socket.send('ping') } catch(e){}
      clearTimeout(pongTimeout)
      pongTimeout = setTimeout(() => { try { socket?.close() } catch(e){} }, 5000)
    }
  }, 15000) // 15s
}

function connect(){
  const base = resolveApiBase()
  const wsBase = base.replace(/^http/,'ws')
  socket = new WebSocket(`${wsBase}/api/v1/knowledge-base/tasks/ws`)
  socket.onopen = () => {
    reconnectAttempts = 0
    scheduleHeartbeat()
  }
  socket.onmessage = ev => {
    if(ev.data === 'pong'){
      // heartbeat reply
      scheduleHeartbeat()
      return
    }
    try {
      const data = JSON.parse(ev.data)
      if(data?.type && listeners[data.type]){
        listeners[data.type].forEach(cb => cb(data))
      }
    } catch(e){/* ignore */}
  }
  socket.onclose = () => {
    clearTimeout(heartbeatTimer)
    clearTimeout(pongTimeout)
    if(!manualClose){
      const delay = Math.min(1000 * Math.pow(2, reconnectAttempts), 15000)
      reconnectAttempts++
      setTimeout(connect, delay)
    }
  }
  socket.onerror = () => {
    try { socket?.close() } catch(e){}
  }
}

if(typeof window !== 'undefined'){
  connect()
}

export function useTaskEvents(){
  function on(type: string, cb: (e: TaskEvent) => void){
    if(!listeners[type]) listeners[type] = []
    listeners[type].push(cb)
    return () => {
      listeners[type] = listeners[type].filter(f => f !== cb)
    }
  }
  function close(){
    manualClose = true
    try { socket?.close() } catch(e){}
  }
  onBeforeUnmount(() => { /* component-level cleanup left to caller via returned disposer */ })
  return { on, close }
}
