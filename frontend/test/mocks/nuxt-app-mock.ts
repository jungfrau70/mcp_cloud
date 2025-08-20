// Minimal mock for Nuxt 3 composables used in unit tests.
export function useRuntimeConfig() {
  return {
    public: {
      apiBaseUrl: 'http://localhost:8000'
    }
  }
}

// Add any other composables if future tests require them.
