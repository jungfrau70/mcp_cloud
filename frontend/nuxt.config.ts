// https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({
  devtools: { enabled: false },
  ssr: false, // SPA 모드로 변경하여 hydration 문제 해결
  modules: [
    ['nuxt-tiptap-editor', { prefix: 'Tiptap' }]
  ],
  components: [
    {
      path: '~/components',
      pathPrefix: false,
      ignore: ['**/StepCli.*']
    }
  ],
  css: ['~/assets/css/main.css'],
  app: {
    buildAssetsDir: '/_nuxt/',
    head: {
      title: 'Bigs',
      meta: [
        { charset: 'utf-8' },
        { name: 'viewport', content: 'width=device-width, initial-scale=1' },
        { name: 'description', content: 'AI 기반 멀티클라우드 관리 플랫폼' }
      ]
    }
  },
  router: {
    options: {
      scrollBehaviorType: 'smooth'
    }
  },
  runtimeConfig: {
    public: {
      // 환경별 API URL 설정
      apiBaseUrl: process.env.NUXT_PUBLIC_API_BASE_URL || (process.env.NODE_ENV === 'production' ? 'https://api.goldencircle.us/api' : 'http://localhost:8000/api'),
      wsBaseUrl: process.env.NUXT_PUBLIC_WS_BASE_URL || (process.env.NODE_ENV === 'production' ? 'wss://api.goldencircle.us' : 'ws://localhost:8000/api'),
      // 환경 설정
      env: process.env.NUXT_PUBLIC_ENV || process.env.NODE_ENV || 'development',
      debug: process.env.NUXT_PUBLIC_DEBUG === 'true' || process.env.NODE_ENV === 'development',
      // Public API Key for X-API-Key header (fallback to MCP_API_KEY if present)
      apiKey: process.env.NUXT_PUBLIC_API_KEY || process.env.MCP_API_KEY || 'my_mcp_eagle_tiger'
    }
  },
  nitro: {
    // 프록시 설정 제거 - 직접 API URL 사용
  },
  // 개발 서버 설정
  devServer: {
    port: 3000,
    host: '0.0.0.0'
  },
  // Vite 설정 (타임아웃 문제 해결)
  vite: {
    server: {
      hmr: {
        timeout: 30000
      }
    },
    build: {
      chunkSizeWarningLimit: 2400
    },
    css: {
      postcss: {
        plugins: [
          require('tailwindcss'),
          require('autoprefixer')
        ]
      }
    }
  }
})
