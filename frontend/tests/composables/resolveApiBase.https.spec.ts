import { describe, it, expect, vi } from 'vitest'
import { resolveApiBase } from '../../composables/useKbApi'

vi.mock('#app', () => ({
  useRuntimeConfig: () => ({ public: { apiBaseUrl: 'https://api.gostock.us' } })
}))

describe('resolveApiBase over https', () => {
  it('keeps https backend even when frontend is http://localhost:3000', () => {
    vi.stubGlobal('window', { location: { hostname: 'localhost', protocol: 'http:', port: '3000' } })
    const base = resolveApiBase()
    expect(base.startsWith('https://')).toBe(true)
    expect(base).toContain('api.gostock.us')
  })
})


