import { describe, it, expect, vi } from 'vitest';
import { resolveApiBase, useKbApi } from '../../composables/useKbApi';
import { useRuntimeConfig } from '#app';

// Mock Nuxt's useRuntimeConfig
vi.mock('#app', () => ({
  useRuntimeConfig: vi.fn(),
}));

describe('resolveApiBase', () => {
  it('should return the configured apiBaseUrl when no window is defined', () => {
    // Mock useRuntimeConfig to return a specific config
    (useRuntimeConfig as vi.Mock).mockReturnValue({
      public: { apiBaseUrl: 'http://test-api.com:8000' },
    });

    // Temporarily set window to undefined to simulate SSR or non-browser environment
    const originalWindow = global.window;
    // @ts-ignore
    delete global.window;

    const result = resolveApiBase();
    expect(result).toBe('http://test-api.com:8000');

    // Restore window
    global.window = originalWindow;
  });

  it('should return the configured apiBaseUrl when hostname is localhost', () => {
    (useRuntimeConfig as vi.Mock).mockReturnValue({
      public: { apiBaseUrl: 'http://localhost:8000' },
    });

    // Use vi.stubGlobal for window.location
    vi.stubGlobal('window', {
      location: { hostname: 'localhost', protocol: 'http:', port: '3000' },
    });

    const result = resolveApiBase();
    expect(result).toBe('http://localhost:8000');
  });

  it('should return the configured apiBaseUrl when hostname is 127.0.0.1', () => {
    (useRuntimeConfig as vi.Mock).mockReturnValue({
      public: { apiBaseUrl: 'http://127.0.0.1:8000' },
    });

    vi.stubGlobal('window', {
      location: { hostname: '127.0.0.1', protocol: 'http:', port: '3000' },
    });

    const result = resolveApiBase();
    expect(result).toBe('http://127.0.0.1:8000');
  });

  it('should return the browser\'s hostname and port if apiBaseUrl is different and not localhost', () => {
    (useRuntimeConfig as vi.Mock).mockReturnValue({
      public: { apiBaseUrl: 'http://remote-api.com:8000' },
    });

    vi.stubGlobal('window', {
      location: { hostname: 'my-app.com', protocol: 'https:', port: '443' },
    });

    const result = resolveApiBase();
    expect(result).toBe('https://my-app.com:8000'); // Should use configured port
  });

  it('should handle apiBaseUrl without a port and use default 8000', () => {
    (useRuntimeConfig as vi.Mock).mockReturnValue({
      public: { apiBaseUrl: 'http://remote-api.com' },
    });

    vi.stubGlobal('window', {
      location: { hostname: 'my-app.com', protocol: 'https:', port: '443' },
    });

    const result = resolveApiBase();
    expect(result).toBe('https://my-app.com:8000'); // Default port 8000 should be used
  });

  it('should use the configured port if browser port is different', () => {
    (useRuntimeConfig as vi.Mock).mockReturnValue({
      public: { apiBaseUrl: 'http://remote-api.com:8080' },
    });

    vi.stubGlobal('window', {
      location: { hostname: 'my-app.com', protocol: 'https:', port: '443' },
    });

    const result = resolveApiBase();
    expect(result).toBe('https://my-app.com:8080'); // Configured port 8080 should be used
  });
});

describe('request', () => {
  // Mock the global fetch function
  let mockFetch: ReturnType<typeof vi.fn>;

  beforeEach(() => {
    mockFetch = vi.fn();
    vi.stubGlobal('fetch', mockFetch);

    // Explicitly mock useRuntimeConfig for request tests
    (useRuntimeConfig as vi.Mock).mockReturnValue({
      public: { apiBaseUrl: 'http://localhost:8000' }, // Default value for request tests
    });
  });

  afterEach(() => {
    vi.unstubAllGlobals(); // Restore global fetch
    vi.restoreAllMocks();
  });

  it('should successfully make an API call and return JSON data', async () => {
    const mockResponseData = { message: 'Success!' };
    mockFetch.mockResolvedValueOnce({
      ok: true,
      status: 200,
      json: () => Promise.resolve(mockResponseData),
    });

    const { request } = useKbApi(); // Get the request function from the composable
    const result = await request('/test-url');

    expect(mockFetch).toHaveBeenCalledWith('/test-url', undefined);
    expect(result).toEqual(mockResponseData);
  });

  it('should throw an error for a non-OK response with generic message', async () => {
    mockFetch.mockResolvedValueOnce({
      ok: false,
      status: 404,
      json: () => Promise.resolve({}), // Empty JSON for generic message
    });

    const { request } = useKbApi();
    await expect(request('/test-url')).rejects.toThrow('request failed: 404');
  });

  it('should throw an error for a non-OK response with detail message', async () => {
    const mockErrorDetail = 'Item not found.';
    mockFetch.mockResolvedValueOnce({
      ok: false,
      status: 400,
      json: () => Promise.resolve({ detail: mockErrorDetail }),
    });

    const { request } = useKbApi();
    await expect(request('/test-url')).rejects.toThrow(mockErrorDetail);
  });

  it('should throw an error for a non-OK response with invalid JSON', async () => {
    mockFetch.mockResolvedValueOnce({
      ok: false,
      status: 500,
      json: () => Promise.reject(new Error('Invalid JSON')),
      text: () => Promise.resolve('Internal Server Error'), // Fallback for text
    });

    const { request } = useKbApi();
    await expect(request('/test-url')).rejects.toThrow('request failed: 500');
  });
});
