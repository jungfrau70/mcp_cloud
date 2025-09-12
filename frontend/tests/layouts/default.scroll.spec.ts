import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest'
import { mount } from '@vue/test-utils'
import { createRouter, createWebHistory } from 'vue-router'
import DefaultLayout from '~/layouts/default.vue'

// Mock window.scrollTo
const mockScrollTo = vi.fn()
Object.defineProperty(window, 'scrollTo', {
  value: mockScrollTo,
  writable: true
})

// Mock localStorage
const mockLocalStorage = {
  getItem: vi.fn(),
  setItem: vi.fn(),
  removeItem: vi.fn(),
  clear: vi.fn()
}
Object.defineProperty(window, 'localStorage', {
  value: mockLocalStorage,
  writable: true
})

// Mock fetch
global.fetch = vi.fn()

// Mock router
const router = createRouter({
  history: createWebHistory(),
  routes: [
    { path: '/', component: { template: '<div>Home</div>' } },
    { path: '/curriculum', component: { template: '<div>Curriculum</div>' } },
    { path: '/textbook', component: { template: '<div>Textbook</div>' } }
  ]
})

describe('Default Layout Scroll Behavior', () => {
  beforeEach(() => {
    vi.clearAllMocks()
    mockLocalStorage.getItem.mockReturnValue(null)
  })

  afterEach(() => {
    vi.restoreAllMocks()
  })

  it('should scroll to top when route changes', async () => {
    const wrapper = mount(DefaultLayout, {
      global: {
        plugins: [router],
        stubs: {
          'SyllabusExplorer': { template: '<div>SyllabusExplorer</div>' },
          'WorkspaceView': { template: '<div>WorkspaceView</div>' },
          'AIAssistantPanel': { template: '<div>AIAssistantPanel</div>' },
          'TaskStatusBar': { template: '<div>TaskStatusBar</div>' },
          'ToastStack': { template: '<div>ToastStack</div>' }
        }
      }
    })

    // Simulate route change
    await router.push('/curriculum')
    await wrapper.vm.$nextTick()

    expect(mockScrollTo).toHaveBeenCalledWith({ 
      top: 0, 
      behavior: 'smooth' 
    })
  })

  it('should scroll to top on multiple route changes', async () => {
    const wrapper = mount(DefaultLayout, {
      global: {
        plugins: [router],
        stubs: {
          'SyllabusExplorer': { template: '<div>SyllabusExplorer</div>' },
          'WorkspaceView': { template: '<div>WorkspaceView</div>' },
          'AIAssistantPanel': { template: '<div>AIAssistantPanel</div>' },
          'TaskStatusBar': { template: '<div>TaskStatusBar</div>' },
          'ToastStack': { template: '<div>ToastStack</div>' }
        }
      }
    })

    // Simulate multiple route changes
    await router.push('/curriculum')
    await wrapper.vm.$nextTick()
    
    await router.push('/textbook')
    await wrapper.vm.$nextTick()

    expect(mockScrollTo).toHaveBeenCalledTimes(2)
    expect(mockScrollTo).toHaveBeenNthCalledWith(1, { 
      top: 0, 
      behavior: 'smooth' 
    })
    expect(mockScrollTo).toHaveBeenNthCalledWith(2, { 
      top: 0, 
      behavior: 'smooth' 
    })
  })

  it('should handle window undefined gracefully', () => {
    // Mock window as undefined
    const originalWindow = global.window
    // @ts-ignore
    delete global.window

    const wrapper = mount(DefaultLayout, {
      global: {
        plugins: [router],
        stubs: {
          'SyllabusExplorer': { template: '<div>SyllabusExplorer</div>' },
          'WorkspaceView': { template: '<div>WorkspaceView</div>' },
          'AIAssistantPanel': { template: '<div>AIAssistantPanel</div>' },
          'TaskStatusBar': { template: '<div>TaskStatusBar</div>' },
          'ToastStack': { template: '<div>ToastStack</div>' }
        }
      }
    })

    // Should not throw error
    expect(() => {
      wrapper.vm.$options.watch['route.path'].handler('/curriculum')
    }).not.toThrow()

    // Restore window
    global.window = originalWindow
  })

  it('should use smooth scrolling behavior', async () => {
    const wrapper = mount(DefaultLayout, {
      global: {
        plugins: [router],
        stubs: {
          'SyllabusExplorer': { template: '<div>SyllabusExplorer</div>' },
          'WorkspaceView': { template: '<div>WorkspaceView</div>' },
          'AIAssistantPanel': { template: '<div>AIAssistantPanel</div>' },
          'TaskStatusBar': { template: '<div>TaskStatusBar</div>' },
          'ToastStack': { template: '<div>ToastStack</div>' }
        }
      }
    })

    await router.push('/curriculum')
    await wrapper.vm.$nextTick()

    expect(mockScrollTo).toHaveBeenCalledWith({
      top: 0,
      behavior: 'smooth'
    })
  })
})
