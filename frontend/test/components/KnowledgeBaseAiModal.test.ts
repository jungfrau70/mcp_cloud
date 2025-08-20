import { mount } from '@vue/test-utils'
import { describe, it, expect, vi, beforeEach } from 'vitest'
import KnowledgeBase from '@/components/KnowledgeBase.vue'

// Mock Nuxt runtime config composable
;(global as any).useRuntimeConfig = () => ({ public: { apiBaseUrl: 'http://localhost:8000' } })

// Mock localStorage
const localStorageMock = {
  getItem: vi.fn().mockReturnValue('[]'),
  setItem: vi.fn(),
  removeItem: vi.fn(),
  clear: vi.fn()
}
Object.defineProperty(window, 'localStorage', { value: localStorageMock })

// Mock fetch globally
const mockFetch = vi.fn()
;(global as any).fetch = mockFetch

describe('KnowledgeBase AI Generation Modal', () => {
  const apiSuccessResponse = {
    success: true,
    message: 'Document generated and saved',
    document_path: 'ai-generated/sample.md',
    generated_doc_data: {
      title: 'AWS S3 버킷 생성 가이드',
      slug: 'aws-s3-bucket-guide',
      content: '# AWS S3 버킷 생성 가이드\n\n내용...'
    }
  }

  beforeEach(() => {
    vi.clearAllMocks()
    localStorageMock.getItem.mockReturnValue('[]')
  })

  function openModal(wrapper: any) {
    const btn = wrapper.findAll('button').find(b => b.text() === 'AI 문서 생성')
    if (!btn) throw new Error('AI 문서 생성 button not found')
    return btn.trigger('click')
  }

  it('opens modal and validates input requirement', async () => {
    const wrapper = mount(KnowledgeBase, { attachTo: document.body })
    await openModal(wrapper)
    const generateBtn = wrapper.get('[data-testid="ai-generate-btn"]')
    expect(generateBtn.attributes('disabled')).toBeDefined()
    const input = wrapper.get('[data-testid="ai-query-input"]')
    await input.setValue('AWS S3 버킷 생성 방법')
    expect(generateBtn.attributes('disabled')).toBeUndefined()
  })

  it('handles successful AI generation flow', async () => {
    mockFetch.mockResolvedValueOnce({
      ok: true,
      json: async () => apiSuccessResponse
    })
    const wrapper = mount(KnowledgeBase, { attachTo: document.body })
    await openModal(wrapper)
    await wrapper.get('[data-testid="ai-query-input"]').setValue('AWS S3 버킷 생성 방법')
    await wrapper.get('[data-testid="ai-generate-btn"]').trigger('click')
    await wrapper.vm.$nextTick(); await wrapper.vm.$nextTick()
    const status = wrapper.get('[data-testid="ai-status-msg"]').text()
    expect(status).toContain('문서 생성 성공')
    const titleInput = wrapper.get('input[placeholder="제목"]')
    expect((titleInput.element as HTMLInputElement).value).toContain('AWS S3')
  })

  it('handles failure in AI generation', async () => {
    mockFetch.mockResolvedValueOnce({
      ok: false,
      json: async () => ({ success: false, message: 'Backend error' })
    })
    const wrapper = mount(KnowledgeBase, { attachTo: document.body })
    await openModal(wrapper)
    await wrapper.get('[data-testid="ai-query-input"]').setValue('invalid')
    await wrapper.get('[data-testid="ai-generate-btn"]').trigger('click')
    await wrapper.vm.$nextTick(); await wrapper.vm.$nextTick()
    const status = wrapper.get('[data-testid="ai-status-msg"]').text()
    expect(status).toContain('문서 생성 실패')
  })
})
