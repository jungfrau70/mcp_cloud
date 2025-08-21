import { ref, onBeforeUnmount } from 'vue'

export function useSidebarResize(initial = 256, min = 200, max = 500){
  const isCollapsed = ref(false)
  const width = ref(initial)
  let resizing = false

  const toggle = () => { isCollapsed.value = !isCollapsed.value }

  const onMouseMove = (ev: MouseEvent) => {
    if(!resizing) return
    const next = Math.min(max, Math.max(min, ev.clientX))
    width.value = next
  }
  const onMouseUp = () => { resizing = false }

  const start = () => { resizing = true }

  window.addEventListener('mousemove', onMouseMove)
  window.addEventListener('mouseup', onMouseUp)
  onBeforeUnmount(()=>{
    window.removeEventListener('mousemove', onMouseMove)
    window.removeEventListener('mouseup', onMouseUp)
  })

  return { isCollapsed, width, toggle, start }
}
