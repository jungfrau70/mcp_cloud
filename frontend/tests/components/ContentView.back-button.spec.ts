import { describe, it, expect, vi, beforeEach } from 'vitest'
import { mount } from '@vue/test-utils'
import ContentView from '~/components/ContentView.vue'

// Mock window.history.back
const mockHistoryBack = vi.fn()
Object.defineProperty(window, 'history', {
  value: {
    back: mockHistoryBack
  },
  writable: true
})

describe('ContentView Back Button', () => {
  beforeEach(() => {
    vi.clearAllMocks()
  })

  it('should render back button when path is provided', () => {
    const wrapper = mount(ContentView, {
      props: {
        content: '# Test Content',
        path: 'test/path.md'
      }
    })

    const backButton = wrapper.find('button')
    expect(backButton.exists()).toBe(true)
    expect(backButton.text()).toBe('이전')
  })

  it('should not render back button when path is not provided', () => {
    const wrapper = mount(ContentView, {
      props: {
        content: '# Test Content'
        // path is not provided
      }
    })

    const backButton = wrapper.find('button')
    expect(backButton.exists()).toBe(false)
  })

  it('should call window.history.back when back button is clicked', async () => {
    const wrapper = mount(ContentView, {
      props: {
        content: '# Test Content',
        path: 'test/path.md'
      }
    })

    const backButton = wrapper.find('button')
    await backButton.trigger('click')

    expect(mockHistoryBack).toHaveBeenCalledTimes(1)
  })

  it('should have correct CSS classes for back button', () => {
    const wrapper = mount(ContentView, {
      props: {
        content: '# Test Content',
        path: 'test/path.md'
      }
    })

    const backButton = wrapper.find('button')
    expect(backButton.classes()).toContain('px-3')
    expect(backButton.classes()).toContain('py-1')
    expect(backButton.classes()).toContain('text-sm')
    expect(backButton.classes()).toContain('rounded')
    expect(backButton.classes()).toContain('bg-gray-200')
    expect(backButton.classes()).toContain('hover:bg-gray-300')
    expect(backButton.classes()).toContain('transition-colors')
  })

  it('should render PDF button when not in slide view', () => {
    const wrapper = mount(ContentView, {
      props: {
        content: '# Test Content',
        path: 'test/path.md'
      }
    })

    const buttons = wrapper.findAll('button')
    expect(buttons).toHaveLength(2)
    
    const pdfButton = buttons.find(button => button.text() === 'PDF')
    expect(pdfButton.exists()).toBe(true)
  })

  it('should not render PDF button when in slide view', () => {
    const wrapper = mount(ContentView, {
      props: {
        content: '# Test Content',
        path: 'test/path.md',
        slide: { content: 'slide content' }
      }
    })

    const buttons = wrapper.findAll('button')
    // Should have back button and potentially other buttons, but PDF should be conditional
    const pdfButton = buttons.find(button => button.text() === 'PDF')
    expect(pdfButton.exists()).toBe(false)
  })

  it('should have correct action row layout', () => {
    const wrapper = mount(ContentView, {
      props: {
        content: '# Test Content',
        path: 'test/path.md'
      }
    })

    const actionRow = wrapper.find('.flex.items-center.justify-end.gap-2.px-4.pt-3')
    expect(actionRow.exists()).toBe(true)
    
    const buttons = actionRow.findAll('button')
    expect(buttons).toHaveLength(2)
    
    // Back button should be first
    expect(buttons[0].text()).toBe('이전')
    // PDF button should be second
    expect(buttons[1].text()).toBe('PDF')
  })
})
