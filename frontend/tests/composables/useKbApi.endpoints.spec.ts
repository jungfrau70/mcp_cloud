import { describe, it, expect, vi, beforeEach, afterEach, type Mock } from 'vitest'
import { useKbApi } from '../../composables/useKbApi'
// In tests, #app is aliased to a local mock via vitest.config
import { useRuntimeConfig } from '#app'

vi.mock('#app', () => ({ useRuntimeConfig: vi.fn(() => ({ public: { apiBaseUrl: 'http://localhost:8000' } })) }))

describe('useKbApi endpoints', () => {
  let mockFetch: ReturnType<typeof vi.fn>

  beforeEach(() => {
    mockFetch = vi.fn()
    vi.stubGlobal('fetch', mockFetch)
    ;(useRuntimeConfig as unknown as Mock).mockReturnValue({ public: { apiBaseUrl: 'http://localhost:8000' } })
  })

  afterEach(() => {
    vi.unstubAllGlobals()
    vi.restoreAllMocks()
  })

  it('saveItem should PATCH to deprecated endpoint (content save)', async () => {
    const { saveItem } = useKbApi()
    mockFetch.mockResolvedValueOnce({ ok: true, json: () => Promise.resolve({ version_no: 2 }) })
    await saveItem('/foo/bar.md', '# hello', 'msg', 1)
    expect(mockFetch).toHaveBeenCalledTimes(1)
    const [url, init] = mockFetch.mock.calls[0]
    expect(url).toBe('http://localhost:8000/api/_deprecated/kb/item')
    expect(init?.method).toBe('PATCH')
    const body = JSON.parse(String((init as any).body))
    expect(body).toMatchObject({ path: '/foo/bar.md', content: '# hello', message: 'msg', expected_version_no: 1 })
  })

  it('listVersions should call v1 versions endpoint', async () => {
    const { listVersions } = useKbApi()
    mockFetch.mockResolvedValueOnce({ ok: true, json: () => Promise.resolve({ versions: [] }) })
    await listVersions('/foo/bar.md')
    const [url] = mockFetch.mock.calls[0]
    expect(url).toBe('http://localhost:8000/api/v1/knowledge-base/versions?path=%2Ffoo%2Fbar.md')
  })

  it('outline should POST v1 outline endpoint', async () => {
    const { outline } = useKbApi()
    mockFetch.mockResolvedValueOnce({ ok: true, json: () => Promise.resolve({ outline: [] }) })
    await outline('# Title')
    const [url, init] = mockFetch.mock.calls[0]
    expect(url).toBe('http://localhost:8000/api/v1/knowledge-base/outline')
    expect(init?.method).toBe('POST')
  })

  it('diff should GET v1 unified diff endpoint', async () => {
    const { diff } = useKbApi()
    mockFetch.mockResolvedValueOnce({ ok: true, json: () => Promise.resolve({ diff_format: 'unified', hunks: [] }) })
    await diff('/foo/bar.md', 1, 2)
    const [url] = mockFetch.mock.calls[0]
    expect(url).toBe('http://localhost:8000/api/v1/knowledge-base/diff?path=%2Ffoo%2Fbar.md&v1=1&v2=2')
  })
})


