import { describe, it, expect, beforeEach, vi } from 'vitest'
import { mount, flushPromises } from '@vue/test-utils'
import { nextTick } from 'vue'
import ContentView from '../../components/ContentView.vue'

async function mountWithContent(md: string){
  const wrapper = mount(ContentView, {
    props: { content: md, path: 'index.md', readonly: true }
  })
  await nextTick()
  await flushPromises()
  return wrapper
}

describe('ContentView link interception', () => {
  beforeEach(() => {
    // remove any listeners between tests
    // happy-dom resets between runs, but ensure no residual state
  })

  it('dispatches kb:open for mdc: scheme links (normalized to /mcp_knowledge_base)', async () => {
    const md = '링크: [공통](mdc:mcp_knowledge_base/cloud_basic/prerequisite/2_공통사항.md)'
    const wrapper = await mountWithContent(md)

    let received: any = null
    const handler = (e: any) => { received = e?.detail }
    window.addEventListener('kb:open', handler)

    const a = wrapper.find('a[href*="/mcp_knowledge_base/"]')
    expect(a.exists()).toBe(true)
    await a.trigger('click')
    await flushPromises()

    expect(received).toBeTruthy()
    expect(received.path).toBe('cloud_basic/prerequisite/2_공통사항.md')
    window.removeEventListener('kb:open', handler)
  })

  it('dispatches kb:open for mcp_knowledge_base/ links without scheme', async () => {
    const md = '링크: [공통](mcp_knowledge_base/cloud_basic/prerequisite/2_공통사항.md)'
    const wrapper = await mountWithContent(md)

    let received: any = null
    const handler = (e: any) => { received = e?.detail }
    window.addEventListener('kb:open', handler)

    const a = wrapper.find('a[href^="mcp_knowledge_base/"]')
    expect(a.exists()).toBe(true)
    await a.trigger('click')
    await flushPromises()

    expect(received).toBeTruthy()
    expect(received.path).toBe('cloud_basic/prerequisite/2_공통사항.md')
    window.removeEventListener('kb:open', handler)
  })

  it('dispatches kb:open for /mcp_knowledge_base/ links starting with slash', async () => {
    const md = '링크: [공통](/mcp_knowledge_base/cloud_basic/prerequisite/2_공통사항.md)'
    const wrapper = await mountWithContent(md)

    let received: any = null
    const handler = (e: any) => { received = e?.detail }
    window.addEventListener('kb:open', handler)

    const a = wrapper.find('a[href^="/mcp_knowledge_base/"]')
    expect(a.exists()).toBe(true)
    await a.trigger('click')
    await flushPromises()

    expect(received).toBeTruthy()
    expect(received.path).toBe('cloud_basic/prerequisite/2_공통사항.md')
    window.removeEventListener('kb:open', handler)
  })

  it('opens external links in a new tab', async () => {
    const md = '외부: [공홈](https://example.com)'
    const wrapper = await mountWithContent(md)

    const a = wrapper.find('a[href^="https://example.com"]')
    expect(a.exists()).toBe(true)
    // attribute applied by enhancement
    expect(a.attributes('target')).toBe('_blank')
    expect(a.attributes('rel')).toContain('noopener')
  })
})


