import { describe, it, expect, vi } from 'vitest'
import { mount } from '@vue/test-utils'
import ContentView from '../../components/ContentView.vue'

describe('ContentView', () => {
  it('renders a back button', () => {
    const wrapper = mount(ContentView, {
      props: { content: '# Hello', path: 'index.md' }
    })
    const backButton = wrapper.find('button.bg-gray-200')
    expect(backButton.exists()).toBe(true)
    expect(backButton.text()).toBe('이전')
  })

  it('calls window.history.back when back button is clicked', async () => {
    const back = vi.spyOn(window.history, 'back')
    const wrapper = mount(ContentView, {
      props: { content: '# Hello', path: 'index.md' }
    })
    const backButton = wrapper.find('button.bg-gray-200')
    await backButton.trigger('click')
    expect(back).toHaveBeenCalled()
  })
})
