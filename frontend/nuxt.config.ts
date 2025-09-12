// https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({
  devtools: { enabled: false },
  ssr: true,
  modules: [
    '@nuxtjs/tailwindcss',
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
      scrollBehavior(to, from, savedPosition) {
        if (savedPosition) {
          return savedPosition
        } else {
          return { top: 0 }
        }
      }
    }
  },
  runtimeConfig: {
    public: {
      // 브라우저에서 접근 가능한 호스트로 기본값 설정
      // 로컬 개발 서버를 기본으로 하고, 환경변수가 있으면 원래 URL 사용
      apiBaseUrl: process.env.NUXT_PUBLIC_API_BASE_URL || '/api',
      wsBaseUrl: process.env.NUXT_PUBLIC_WS_BASE_URL || 'ws://localhost:8000/api',
      // Public API Key for X-API-Key header (fallback to MCP_API_KEY if present)
      apiKey: process.env.NUXT_PUBLIC_API_KEY || process.env.MCP_API_KEY || 'my_mcp_eagle_tiger'
    }
  },
  nitro: {
    routeRules: {
      '/api/**': { proxy: process.env.NUXT_PUBLIC_API_BASE_URL ? `${process.env.NUXT_PUBLIC_API_BASE_URL}/api/**` : 'http://localhost:8000/api/**' },
    },
    devProxy: {
      '/api': { 
        target: process.env.NUXT_PUBLIC_API_BASE_URL || 'http://localhost:8000', 
        changeOrigin: true, 
        secure: process.env.NUXT_PUBLIC_API_BASE_URL?.startsWith('https') || false 
      },
    },
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
    }
  }
})
