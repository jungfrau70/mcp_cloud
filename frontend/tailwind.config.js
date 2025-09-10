/** @type {import('tailwindcss').Config} */
module.exports = {
  content: {
    files: [
      "./components/**/*.{js,vue,ts}",
      "./layouts/**/*.vue",
      "./pages/**/*.vue",
      "./plugins/**/*.{js,ts}",
      "./nuxt.config.{js,ts}",
      "./app.vue",
    ],
    // Vue 파일에서 <script> 블록 제거하여 정규식 패턴이 임의 클래스명으로 인식되는 문제 방지
    transform: {
      vue: (content) => content.replace(/<script[\s\S]*?<\/script>/g, ''),
    }
  },
  theme: {
    extend: {
      colors: {
        primary: {
          50: '#eff6ff',
          500: '#3b82f6',
          600: '#2563eb',
          700: '#1d4ed8',
        }
      }
    },
  },
  plugins: [],
}
