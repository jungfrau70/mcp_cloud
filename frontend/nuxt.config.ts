// https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({
  devtools: { enabled: false },
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
    head: {
      title: 'Bigs',
      meta: [
        { charset: 'utf-8' },
        { name: 'viewport', content: 'width=device-width, initial-scale=1' },
        { name: 'description', content: 'AI 기반 멀티클라우드 관리 플랫폼' }
      ]
    }
  },
  runtimeConfig: {
    public: {
      // 브라우저에서 접근 가능한 호스트로 기본값 설정
      // 동일 오리진 프록시 사용: 기본 '/api' → 서버에서 https://api.goldencircle.us 로 프록시
      apiBaseUrl: process.env.NUXT_PUBLIC_API_BASE_URL || '/api',
      // WebSocket 전용 베이스(선택). 설정 시 우선 사용. 기본은 공개 API 도메인 사용
      wsBaseUrl: process.env.NUXT_PUBLIC_WS_BASE_URL || 'wss://api.goldencircle.us/api',
      // Public API Key for X-API-Key header (fallback to MCP_API_KEY if present)
      apiKey: process.env.NUXT_PUBLIC_API_KEY || process.env.MCP_API_KEY || 'my_mcp_eagle_tiger'
    }
  },
  nitro: {
    routeRules: {
      '/api/**': { proxy: 'https://api.goldencircle.us/**' },
    },
    devProxy: {
      '/api': { target: 'https://api.goldencircle.us', changeOrigin: true, secure: true },
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
    }
  }
})
