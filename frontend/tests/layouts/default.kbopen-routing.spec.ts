import { describe, it, expect, vi, beforeEach } from 'vitest'
import { mount } from '@vue/test-utils'

// Runtime config
vi.mock('#app', () => ({ useRuntimeConfig: () => ({ public: { apiBaseUrl: 'http://localhost:8000' } }) }))

// Router mock that we can control per test
const pushSpy = vi.fn()
let currentPath = '/textbook'
vi.mock('vue-router', () => ({
  useRoute: () => ({ path: currentPath, query: {} }),
  useRouter: () => ({ push: pushSpy })
}))

// Doc store & toast
const openSpy = vi.fn()
vi.mock('~/stores/doc', () => ({
  useDocStore: () => ({ content: '', path: '', version: 0, open: openSpy, whenLoaded: vi.fn(() => Promise.resolve()) })
}))
vi.mock('~/stores/toast', () => ({ useToastStore: () => ({ push: vi.fn() }) }))
vi.mock('~/composables/useSidebarResize', () => ({ useSidebarResize: () => ({ isCollapsed: { value: false }, width: 240, toggle: vi.fn(), start: vi.fn() }) }))
vi.mock('~/composables/useTaskEvents', () => ({ useTaskEvents: () => ({ subscribe: vi.fn(), unsubscribe: vi.fn() }) }))

// Stubs
const stub = { template: '<div></div>' }
import DefaultLayout from '~/layouts/default.vue'

describe('kb:open routing behavior', () => {
  beforeEach(() => { openSpy.mockClear(); pushSpy.mockClear(); currentPath = '/textbook' })

  function mountLayout(){
    return mount(DefaultLayout, {
      global: {
        stubs: { SyllabusExplorer: stub, KnowledgeBaseExplorer: stub, WorkspaceView: stub, AIAssistantPanel: stub, SplitEditor: stub, TipTapKbEditor: stub, TaskStatusBar: stub, ToastStack: stub }
      }
    })
  }

  it('on /textbook → kb:open opens in curriculum via handleFileClick (no router push)', async () => {
    currentPath = '/textbook'
    mountLayout()
    // dispatch event
    window.dispatchEvent(new CustomEvent('kb:open', { detail: { path: 'cloud_basic/prerequisite/2_공통사항.md' } }))
    await new Promise(r=>setTimeout(r,0))
    expect(pushSpy).not.toHaveBeenCalled()
    // openSpy is for KB doc store; when opening in textbook we won't call docStore.open
    expect(openSpy).not.toHaveBeenCalled()
  })

  it('on /knowledge-base → kb:open opens in KB via docStore.open', async () => {
    currentPath = '/knowledge-base'
    mountLayout()
    window.dispatchEvent(new CustomEvent('kb:open', { detail: { path: 'index.md' } }))
    await new Promise(r=>setTimeout(r,0))
    expect(openSpy).toHaveBeenCalledWith('index.md')
  })

  it('on other route → kb:open pushes to /textbook with force=1', async () => {
    currentPath = '/'
    mountLayout()
    window.dispatchEvent(new CustomEvent('kb:open', { detail: { path: 'index.md' } }))
    await new Promise(r=>setTimeout(r,0))
    expect(pushSpy).toHaveBeenCalled()
    const arg = pushSpy.mock.calls[0][0]
    expect(arg.path).toBe('/textbook')
    expect(arg.query.path).toBe('index.md')
  })
})


