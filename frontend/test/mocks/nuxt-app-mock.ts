// frontend/test/mocks/nuxt-app-mock.ts
import { vi } from 'vitest';

export const useRuntimeConfig = vi.fn(() => ({
  public: {
    apiBaseUrl: 'http://localhost:8000', // Default mock value
  },
}));

// Add other Nuxt mocks here if needed by other composables
