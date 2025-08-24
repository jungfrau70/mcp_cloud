import { ref, onMounted, onBeforeUnmount } from 'vue'

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

  // Register listeners on client only
  onMounted(() => {
    if (typeof window === 'undefined') return
    window.addEventListener('mousemove', onMouseMove)
    window.addEventListener('mouseup', onMouseUp)
  })
  onBeforeUnmount(()=>{
    if (typeof window === 'undefined') return
    window.removeEventListener('mousemove', onMouseMove)
    window.removeEventListener('mouseup', onMouseUp)
  })

  return { isCollapsed, width, toggle, start }
}
