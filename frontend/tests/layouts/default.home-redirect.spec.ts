import { describe, it, expect, vi, beforeEach } from 'vitest'
import { mount } from '@vue/test-utils'

vi.mock('#app', () => ({
  useRuntimeConfig: () => ({ public: { apiBaseUrl: 'http://localhost:8000' } })
}))

// Mock router to emulate /knowledge-base?force=1&path=index.md
vi.mock('vue-router', () => ({
  useRoute: () => ({ path: '/knowledge-base', query: { force: '1', path: 'index.md' } })
}))

// Spyable doc store
const openSpy = vi.fn()
vi.mock('~/stores/doc', () => ({
  useDocStore: () => ({
    content: '',
    path: '',
    version: 0,
    open: openSpy,
    whenLoaded: vi.fn(() => Promise.resolve()),
  })
}))

vi.mock('~/stores/toast', () => ({
  useToastStore: () => ({ push: vi.fn() })
}))

vi.mock('~/composables/useSidebarResize', () => ({
  useSidebarResize: () => ({ isCollapsed: { value: false }, width: 240, toggle: vi.fn(), start: vi.fn() })
}))

// Prevent WebSocket usage in task store during layout mount
vi.mock('~/composables/useTaskEvents', () => ({
  useTaskEvents: () => ({ subscribe: vi.fn(), unsubscribe: vi.fn() })
}))

// Stub child components used by the layout
const stub = { template: '<div></div>' }

import DefaultLayout from '~/layouts/default.vue'

describe('Default layout home redirect → opens index.md', () => {
  beforeEach(() => { openSpy.mockClear() })

  it('calls docStore.open("index.md") on KB home redirect', async () => {
    mount(DefaultLayout, {
      global: {
        stubs: {
          SyllabusExplorer: stub,
          KnowledgeBaseExplorer: stub,
          WorkspaceView: stub,
          AIAssistantPanel: stub,
          SplitEditor: stub,
          TipTapKbEditor: stub,
          TaskStatusBar: stub,
          ToastStack: stub,
        }
      }
    })
    // onMounted async tasks should trigger quickly; allow microtasks to flush
    await new Promise((r) => setTimeout(r, 0))
    expect(openSpy).toHaveBeenCalledWith('index.md')
  })
})


