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
      apiBaseUrl: process.env.NUXT_PUBLIC_API_BASE_URL || 'http://localhost:8000'
    }
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
