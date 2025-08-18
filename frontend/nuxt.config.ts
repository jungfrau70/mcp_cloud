// https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({
  devtools: { enabled: true },
  modules: [
    '@nuxtjs/tailwindcss'
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
      title: 'MCP Cloud Platform',
      meta: [
        { charset: 'utf-8' },
        { name: 'viewport', content: 'width=device-width, initial-scale=1' },
        { name: 'description', content: 'AI 기반 멀티클라우드 관리 플랫폼' }
      ]
    }
  },
  runtimeConfig: {
    public: {
      apiBaseUrl: process.env.NUXT_PUBLIC_API_BASE_URL || 'http://mcp_backend:8000'
    }
  }
})
