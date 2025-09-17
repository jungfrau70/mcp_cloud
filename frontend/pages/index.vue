<template>
  <div class="min-h-screen bg-gradient-to-br from-slate-50 via-blue-50 to-indigo-100 dark:from-gray-900 dark:via-slate-900 dark:to-indigo-900">
    <!-- Hero Section -->
    <section class="relative overflow-hidden bg-gradient-to-br from-blue-600 via-purple-600 to-indigo-700 text-white">
      <!-- Background Pattern -->
      <div class="absolute inset-0 opacity-20">
        <div class="w-full h-full bg-dot-pattern"></div>
        </div>
      
      <div class="relative z-10">
        <UContainer class="py-24 lg:py-32">
          <div class="text-center max-w-4xl mx-auto">
            <!-- Badge -->
            <div class="inline-flex items-center gap-2 px-4 py-2 rounded-full bg-white/10 backdrop-blur-sm border border-white/20 text-sm font-medium mb-8 animate-fade-in">
              <UIcon name="i-lucide-sparkles" class="w-4 h-4 text-yellow-300" />
              <span>{{ heroData.headline }}</span>
        </div>

            <!-- Main Title -->
            <h1 class="text-5xl lg:text-7xl font-bold mb-6 bg-gradient-to-r from-white to-blue-100 bg-clip-text text-transparent animate-slide-up">
              {{ heroData.title }}
            </h1>
            
            <!-- Description -->
            <p class="text-xl lg:text-2xl text-blue-100 mb-12 max-w-3xl mx-auto leading-relaxed animate-slide-up animation-delay-200">
              {{ heroData.description }}
            </p>

          <!-- CTA Buttons -->
            <div class="flex flex-col sm:flex-row gap-4 justify-center animate-slide-up animation-delay-400">
            <UButton 
                v-for="link in heroData.links"
                :key="link.label"
                :to="link.to"
                :target="link.target"
                :color="link.color || 'white'"
                :variant="link.variant || 'solid'"
                :size="link.size || 'xl'"
                :icon="link.icon"
                class="px-8 py-4 text-lg font-semibold shadow-2xl hover:shadow-3xl transform hover:-translate-y-1 transition-all duration-300"
              >
                {{ link.label }}
            </UButton>
          </div>
          </div>
        </UContainer>
        </div>

      <!-- Floating Elements -->
      <div class="absolute top-20 left-10 w-20 h-20 bg-white/10 rounded-full blur-xl animate-float"></div>
      <div class="absolute bottom-20 right-10 w-32 h-32 bg-blue-400/20 rounded-full blur-2xl animate-float animation-delay-1000"></div>
      <div class="absolute top-1/2 left-1/4 w-16 h-16 bg-purple-400/20 rounded-full blur-lg animate-float animation-delay-2000"></div>
      </section>
      
    <!-- Features Section -->
    <section class="py-24 bg-white dark:bg-gray-900">
      <UContainer>
          <div class="text-center mb-20">
          <div class="inline-flex items-center gap-2 px-4 py-2 rounded-full bg-blue-100 dark:bg-blue-900/30 text-blue-700 dark:text-blue-300 text-sm font-medium mb-6">
            <UIcon name="i-lucide-rocket" class="w-4 h-4" />
            <span>핵심 기능</span>
          </div>
          <h2 class="text-4xl lg:text-5xl font-bold text-gray-900 dark:text-white mb-6">
            강사와 학생을 위한 교육 플랫폼
            </h2>
          <p class="text-xl text-gray-600 dark:text-gray-300 max-w-3xl mx-auto leading-relaxed">
            강사는 교육 기획 도구로, 학생은 실습 중심 학습으로 클라우드 & AI 전문가가 되세요
            </p>
          </div>
          
          <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
            <div
              v-for="(feature, index) in features"
              :key="feature.title"
            class="group relative"
            :style="{ animationDelay: `${index * 100}ms` }"
          >
            <div class="absolute inset-0 bg-gradient-to-r from-blue-500 to-purple-600 rounded-2xl blur opacity-0 group-hover:opacity-20 transition-opacity duration-300"></div>
            <UCard class="relative bg-white dark:bg-gray-800 border-0 shadow-lg hover:shadow-2xl transition-all duration-500 hover:-translate-y-2 group-hover:scale-105">
              <template #header>
                <div class="flex items-center gap-4">
                  <div class="p-3 bg-gradient-to-br from-blue-500 to-purple-600 rounded-xl shadow-lg">
                    <UIcon :name="feature.icon" class="w-6 h-6 text-white" />
                </div>
                  <h3 class="text-xl font-bold text-gray-900 dark:text-white group-hover:text-blue-600 dark:group-hover:text-blue-400 transition-colors">
                  {{ feature.title }}
                </h3>
                </div>
              </template>

              <p class="text-gray-600 dark:text-gray-300 mb-6 leading-relaxed">
                  {{ feature.description }}
                </p>

              <UButton
                v-if="feature.action"
                :to="feature.action.to"
                :target="feature.action.target"
                variant="ghost"
                color="primary"
                size="sm"
                class="w-full group-hover:bg-blue-50 dark:group-hover:bg-blue-900/20 transition-colors"
              >
                {{ feature.action.label }}
                <UIcon name="i-lucide-arrow-right" class="w-4 h-4 ml-1 group-hover:translate-x-1 transition-transform" />
              </UButton>
            </UCard>
              </div>
            </div>
      </UContainer>
      </section>

    <!-- Course Overview Section -->
    <section class="py-24 bg-gradient-to-br from-slate-50 via-blue-50 to-indigo-100 dark:from-gray-900 dark:via-slate-900 dark:to-indigo-900">
      <UContainer>
          <div class="text-center mb-20">
          <div class="inline-flex items-center gap-2 px-4 py-2 rounded-full bg-indigo-100 dark:bg-indigo-900/30 text-indigo-700 dark:text-indigo-300 text-sm font-medium mb-6">
            <UIcon name="i-lucide-graduation-cap" class="w-4 h-4" />
            <span>교육 과정</span>
          </div>
          <h2 class="text-4xl lg:text-5xl font-bold text-gray-900 dark:text-white mb-6">
            클라우드 실무력 강화 과정
            </h2>
          <p class="text-xl text-gray-600 dark:text-gray-300 max-w-3xl mx-auto leading-relaxed">
            3단계 체계적 학습으로 클라우드 전문가가 되세요
            </p>
          </div>
          
          <div class="grid grid-cols-1 lg:grid-cols-3 gap-8">
            <div
              v-for="(course, index) in courses"
              :key="course.name"
            class="group relative"
            :style="{ animationDelay: `${index * 200}ms` }"
          >
            <div class="absolute inset-0 rounded-3xl blur-xl opacity-0 group-hover:opacity-30 transition-opacity duration-500" :class="course.gradient"></div>
            <UCard class="relative overflow-hidden border-0 shadow-2xl hover:shadow-3xl transition-all duration-500 hover:-translate-y-3 group-hover:scale-105" :class="course.gradient">
              <!-- Decorative Elements -->
              <div class="absolute top-0 right-0 w-32 h-32 bg-white/10 rounded-full -translate-y-16 translate-x-16"></div>
              <div class="absolute bottom-0 left-0 w-24 h-24 bg-white/5 rounded-full translate-y-12 -translate-x-12"></div>
              
              <template #header>
                <div class="text-center relative z-10">
                  <div class="inline-flex items-center justify-center w-20 h-20 bg-white/20 backdrop-blur-sm rounded-2xl mb-6 shadow-lg">
                    <UIcon :name="course.icon" class="w-10 h-10 text-white" />
                  </div>
                  <h3 class="text-3xl font-bold text-white mb-3">{{ course.name }}</h3>
                  <div class="inline-flex items-center gap-2 px-4 py-2 bg-white/20 backdrop-blur-sm rounded-full text-white/90 text-sm font-medium">
                    <UIcon name="i-lucide-clock" class="w-4 h-4" />
                    {{ course.duration }}
                  </div>
                </div>
              </template>

              <div class="space-y-6 relative z-10">
                <div class="text-white/95">
                  <h4 class="font-bold text-lg mb-4 flex items-center gap-2">
                    <UIcon name="i-lucide-book-open" class="w-5 h-5" />
                    주요 내용
                  </h4>
                  <ul class="space-y-3">
                    <li v-for="item in course.topics" :key="item" class="flex items-start gap-3">
                      <div class="flex-shrink-0 w-5 h-5 bg-green-400 rounded-full flex items-center justify-center mt-0.5">
                        <UIcon name="i-lucide-check" class="w-3 h-3 text-white" />
                      </div>
                      <span class="text-sm leading-relaxed">{{ item }}</span>
                    </li>
                  </ul>
                </div>
                
                <div class="text-white/95">
                  <h4 class="font-bold text-lg mb-3 flex items-center gap-2">
                    <UIcon name="i-lucide-server" class="w-5 h-5" />
                    실습 환경
                  </h4>
                  <p class="text-sm leading-relaxed bg-white/10 backdrop-blur-sm rounded-lg p-3">{{ course.environment }}</p>
                </div>

                <UButton
                  :to="course.link"
                  variant="solid"
                  color="white"
                  size="lg"
                  class="w-full mt-8 font-bold text-lg py-4 shadow-xl hover:shadow-2xl transform hover:-translate-y-1 transition-all duration-300"
                >
                  과정 상세보기
                  <UIcon name="i-lucide-arrow-right" class="w-5 h-5 ml-2 group-hover:translate-x-1 transition-transform" />
                </UButton>
              </div>
            </UCard>
            </div>
          </div>
      </UContainer>
      </section>
      
    <!-- MCP Services Section -->
    <section class="py-24 bg-white dark:bg-gray-900">
      <UContainer>
        <div class="text-center mb-20">
          <div class="inline-flex items-center gap-2 px-4 py-2 rounded-full bg-purple-100 dark:bg-purple-900/30 text-purple-700 dark:text-purple-300 text-sm font-medium mb-6">
            <UIcon name="i-lucide-robot" class="w-4 h-4" />
            <span>AI 교육 도구</span>
        </div>
          <h2 class="text-4xl lg:text-5xl font-bold text-gray-900 dark:text-white mb-6">
            AI 교육 도구 통합
            </h2>
          <p class="text-xl text-gray-600 dark:text-gray-300 max-w-3xl mx-auto leading-relaxed">
            다양한 AI 도구들을 통합하여 강력한 교육 지원 기능을 제공합니다
            </p>
          </div>
          
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-8">
          <div
            v-for="(service, index) in mcpServices"
            :key="service.name"
            class="group relative"
            :style="{ animationDelay: `${index * 150}ms` }"
          >
            <div class="absolute inset-0 bg-gradient-to-br from-purple-500 to-pink-500 rounded-2xl blur opacity-0 group-hover:opacity-10 transition-opacity duration-300"></div>
            <UCard class="relative text-center border-0 shadow-lg hover:shadow-2xl transition-all duration-500 hover:-translate-y-2 group-hover:scale-105 bg-white dark:bg-gray-800">
              <div class="p-8">
                <div class="inline-flex items-center justify-center w-16 h-16 bg-gradient-to-br from-purple-500 to-pink-500 rounded-2xl mb-6 shadow-lg group-hover:scale-110 transition-transform duration-300">
                  <UIcon :name="service.icon" class="w-8 h-8 text-white" />
                </div>
                <h3 class="text-xl font-bold text-gray-900 dark:text-white mb-4 group-hover:text-purple-600 dark:group-hover:text-purple-400 transition-colors">
                  {{ service.name }}
                </h3>
                <p class="text-gray-600 dark:text-gray-300 mb-6 leading-relaxed">
                  {{ service.description }}
                </p>
                <UBadge
                  :color="service.status === 'active' ? 'green' : 'gray'"
                  variant="soft"
                  size="lg"
                  class="font-semibold"
                >
                  <UIcon :name="service.status === 'active' ? 'i-lucide-check-circle' : 'i-lucide-clock'" class="w-4 h-4 mr-1" />
                  {{ service.status === 'active' ? '활성' : '준비중' }}
                </UBadge>
              </div>
            </UCard>
          </div>
        </div>
      </UContainer>
    </section>

    <!-- Statistics Section -->
    <section class="py-24 bg-gradient-to-r from-blue-600 via-purple-600 to-indigo-700 text-white relative overflow-hidden">
      <!-- Background Pattern -->
      <div class="absolute inset-0 opacity-20">
        <div class="w-full h-full bg-dot-pattern"></div>
              </div>
              
      <UContainer class="relative z-10">
        <div class="grid grid-cols-1 md:grid-cols-4 gap-8 text-center">
          <div
            v-for="(stat, index) in statistics"
            :key="stat.label"
            class="group"
            :style="{ animationDelay: `${index * 200}ms` }"
          >
            <div class="bg-white/10 backdrop-blur-sm rounded-2xl p-8 hover:bg-white/20 transition-all duration-300 hover:scale-105">
              <div class="text-5xl lg:text-6xl font-bold mb-4 bg-gradient-to-r from-white to-blue-100 bg-clip-text text-transparent">
                {{ stat.value }}
                </div>
              <div class="text-white/90 text-lg font-medium">{{ stat.label }}</div>
              </div>
            </div>
          </div>
      </UContainer>
      </section>
      
      <!-- CTA Section -->
    <section class="py-24 bg-gradient-to-br from-slate-50 via-blue-50 to-indigo-100 dark:from-gray-900 dark:via-slate-900 dark:to-indigo-900">
      <UContainer>
        <div class="text-center max-w-4xl mx-auto">
          <div class="inline-flex items-center gap-2 px-4 py-2 rounded-full bg-green-100 dark:bg-green-900/30 text-green-700 dark:text-green-300 text-sm font-medium mb-6">
            <UIcon name="i-lucide-target" class="w-4 h-4" />
            <span>지금 시작하세요</span>
        </div>
          <h2 class="text-4xl lg:text-5xl font-bold text-gray-900 dark:text-white mb-6">
            지금 시작하세요!
            </h2>
          <p class="text-xl text-gray-600 dark:text-gray-300 mb-12 max-w-3xl mx-auto leading-relaxed">
            강사는 교육 기획 도구로, 학생은 실습 중심 학습으로 클라우드 & AI 전문가가 되세요
            </p>
          <div class="flex flex-col sm:flex-row gap-6 justify-center">
              <UButton
                to="/curriculum"
                size="xl"
              color="primary"
              class="px-10 py-5 text-lg font-bold shadow-2xl hover:shadow-3xl transform hover:-translate-y-1 transition-all duration-300"
            >
              <UIcon name="i-lucide-chalkboard-teacher" class="w-6 h-6 mr-3" />
              강사용 도구 시작하기
            </UButton>
            <UButton
              to="/knowledge-base"
              size="xl"
              variant="outline"
              color="primary"
              class="px-10 py-5 text-lg font-bold border-2 hover:bg-primary-50 dark:hover:bg-primary-900/20 transform hover:-translate-y-1 transition-all duration-300"
            >
              <UIcon name="i-lucide-graduation-cap" class="w-6 h-6 mr-3" />
              학생용 실습 시작하기
            </UButton>
            <UButton
              to="/ai-assistant"
              size="xl"
              variant="outline"
              color="purple"
              class="px-10 py-5 text-lg font-bold border-2 hover:bg-purple-50 dark:hover:bg-purple-900/20 transform hover:-translate-y-1 transition-all duration-300"
            >
              <UIcon name="i-lucide-robot" class="w-6 h-6 mr-3" />
              AI 어시스턴트 체험
              </UButton>
              </div>
            </div>
      </UContainer>
      </section>

      <!-- Footer -->
    <footer class="bg-gradient-to-r from-gray-900 via-slate-900 to-gray-900 text-white py-16 relative overflow-hidden">
      <!-- Background Pattern -->
      <div class="absolute inset-0 opacity-50">
        <div class="w-full h-full bg-dot-pattern"></div>
      </div>
      
      <UContainer class="relative z-10">
        <div class="grid grid-cols-1 md:grid-cols-4 gap-8 mb-12">
            <div class="md:col-span-1">
              <div class="flex items-center gap-3 mb-6">
              <div class="w-10 h-10 bg-gradient-to-br from-blue-500 to-purple-600 rounded-xl flex items-center justify-center">
                <UIcon name="i-lucide-cloud" class="w-6 h-6 text-white" />
                </div>
              <h3 class="text-xl font-bold">클라우드 & AI 교육 플랫폼</h3>
              </div>
              <p class="text-gray-400 leading-relaxed mb-6">
              강사와 학생을 위한 스마트 교육 솔루션으로 클라우드 & AI 전문가를 양성합니다
              </p>
              <div class="flex gap-4">
              <a href="#" class="w-10 h-10 bg-gray-800 rounded-lg flex items-center justify-center hover:bg-blue-600 transition-colors">
                <UIcon name="i-simple-icons-github" class="w-5 h-5" />
                </a>
              <a href="#" class="w-10 h-10 bg-gray-800 rounded-lg flex items-center justify-center hover:bg-blue-600 transition-colors">
                <UIcon name="i-simple-icons-twitter" class="w-5 h-5" />
                </a>
              <a href="#" class="w-10 h-10 bg-gray-800 rounded-lg flex items-center justify-center hover:bg-blue-600 transition-colors">
                <UIcon name="i-simple-icons-linkedin" class="w-5 h-5" />
                </a>
              </div>
            </div>
            <div>
            <h4 class="font-bold text-lg mb-6 flex items-center gap-2">
              <UIcon name="i-lucide-graduation-cap" class="w-5 h-5 text-blue-400" />
              과정
            </h4>
              <ul class="space-y-3">
              <li><NuxtLink to="/curriculum?path=cloud_basic" class="text-gray-400 hover:text-white transition-colors flex items-center gap-2 group">
                <UIcon name="i-lucide-arrow-right" class="w-4 h-4 group-hover:translate-x-1 transition-transform" />
                Cloud Basic
              </NuxtLink></li>
              <li><NuxtLink to="/curriculum?path=cloud_master" class="text-gray-400 hover:text-white transition-colors flex items-center gap-2 group">
                <UIcon name="i-lucide-arrow-right" class="w-4 h-4 group-hover:translate-x-1 transition-transform" />
                Cloud Master
              </NuxtLink></li>
              <li><NuxtLink to="/curriculum?path=cloud_container" class="text-gray-400 hover:text-white transition-colors flex items-center gap-2 group">
                <UIcon name="i-lucide-arrow-right" class="w-4 h-4 group-hover:translate-x-1 transition-transform" />
                Cloud Container
              </NuxtLink></li>
              </ul>
            </div>
            <div>
            <h4 class="font-bold text-lg mb-6 flex items-center gap-2">
              <UIcon name="i-lucide-folder" class="w-5 h-5 text-purple-400" />
              리소스
            </h4>
              <ul class="space-y-3">
              <li><NuxtLink to="/knowledge-base" class="text-gray-400 hover:text-white transition-colors flex items-center gap-2 group">
                <UIcon name="i-lucide-arrow-right" class="w-4 h-4 group-hover:translate-x-1 transition-transform" />
                지식베이스
              </NuxtLink></li>
              <li><NuxtLink to="/billing" class="text-gray-400 hover:text-white transition-colors flex items-center gap-2 group">
                <UIcon name="i-lucide-arrow-right" class="w-4 h-4 group-hover:translate-x-1 transition-transform" />
                요금제
              </NuxtLink></li>
              <li><NuxtLink to="/cli" class="text-gray-400 hover:text-white transition-colors flex items-center gap-2 group">
                <UIcon name="i-lucide-arrow-right" class="w-4 h-4 group-hover:translate-x-1 transition-transform" />
                CLI 도구
              </NuxtLink></li>
              </ul>
            </div>
            <div>
            <h4 class="font-bold text-lg mb-6 flex items-center gap-2">
              <UIcon name="i-lucide-help-circle" class="w-5 h-5 text-green-400" />
              지원
            </h4>
              <ul class="space-y-3">
              <li><a href="#" class="text-gray-400 hover:text-white transition-colors flex items-center gap-2 group">
                <UIcon name="i-lucide-arrow-right" class="w-4 h-4 group-hover:translate-x-1 transition-transform" />
                문의하기
              </a></li>
              <li><a href="#" class="text-gray-400 hover:text-white transition-colors flex items-center gap-2 group">
                <UIcon name="i-lucide-arrow-right" class="w-4 h-4 group-hover:translate-x-1 transition-transform" />
                도움말
              </a></li>
              <li><a href="#" class="text-gray-400 hover:text-white transition-colors flex items-center gap-2 group">
                <UIcon name="i-lucide-arrow-right" class="w-4 h-4 group-hover:translate-x-1 transition-transform" />
                커뮤니티
              </a></li>
              </ul>
            </div>
          </div>
        <div class="border-t border-gray-800 pt-8 flex flex-col md:flex-row justify-between items-center gap-4">
          <p class="text-gray-400 text-sm">&copy; 2024 클라우드 & AI 교육 플랫폼. All rights reserved.</p>
          <div class="flex gap-6 text-sm text-gray-400">
            <a href="#" class="hover:text-white transition-colors">개인정보처리방침</a>
            <a href="#" class="hover:text-white transition-colors">이용약관</a>
            <a href="#" class="hover:text-white transition-colors">쿠키정책</a>
          </div>
        </div>
      </UContainer>
      </footer>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'

definePageMeta({
  layout: 'default',
  title: '클라우드 & AI 교육 플랫폼 - 강사와 학생을 위한 스마트 교육 솔루션',
  description: '강사를 위한 교육 기획 도구와 학생을 위한 실습 중심 학습 환경을 제공하는 통합 교육 플랫폼입니다.'
})

// Hero Section Data
const heroData = ref({
  title: '클라우드 & AI 교육 플랫폼',
  description: '강사를 위한 교육 기획 도구와 학생을 위한 실습 중심 학습 환경을 제공하는 통합 교육 플랫폼입니다.',
  headline: '강사와 학생을 위한 스마트 교육 솔루션',
  links: [
    {
      label: '학생용 실습',
      to: '/curriculum',
      icon: 'i-lucide-chalkboard-teacher',
      color: 'primary',
      variant: 'solid'
    },
    {
      label: '강사용 도구',
      to: '/knowledge-base',
      icon: 'i-lucide-graduation-cap',
      color: 'white',
      variant: 'outline'
    }
  ]
})

// Features Data
const features = ref([
  {
    title: '강사용 교육 기획 도구',
    description: 'AI 기반 교육 자료 생성, 커리큘럼 설계, 실습 환경 구축을 자동화합니다.',
    icon: 'i-lucide-chalkboard-teacher',
    action: {
      label: '실습 시작하기',
      to: '/knowledge-base',
      target: '_self'
    }
  },
  {
    title: '학생용 실습 환경',
    description: '실습 중심 학습(이론:실습 = 2:8)을 위한 안전한 클라우드 실습 환경을 제공합니다.',
    icon: 'i-lucide-graduation-cap',
    action: {
      label: '강사 도구 사용하기',
      to: '/curriculum',
      target: '_self'
    }
  },
  {
    title: 'AI 교육 어시스턴트',
    description: '학생 질문 답변, 학습 진도 관리, 개인화된 학습 경로 추천을 제공합니다.',
    icon: 'i-lucide-brain',
    action: {
      label: 'AI 어시스턴트 체험',
      to: '/ai-assistant',
      target: '_self'
    }
  },
  {
    title: '실시간 학습 모니터링',
    description: '학생의 실습 진행 상황과 이해도를 실시간으로 추적하고 피드백을 제공합니다.',
    icon: 'i-lucide-bar-chart-3',
    action: {
      label: '모니터링 대시보드',
      to: '/billing',
      target: '_self'
    }
  },
  {
    title: '자동화된 평가 시스템',
    description: '실습 결과 자동 검증, 성과 측정, 학습 효과 분석을 통한 객관적 평가를 제공합니다.',
    icon: 'i-lucide-award',
    action: {
      label: '평가 시스템 보기',
      to: '/curriculum?path=cloud_master',
      target: '_self'
    }
  },
  {
    title: '협업 학습 도구',
    description: '팀 프로젝트, 피어 리뷰, 실시간 협업을 통한 효과적인 학습 환경을 구축합니다.',
    icon: 'i-lucide-users',
    action: {
      label: '협업 도구 사용하기',
      to: '/knowledge-base',
      target: '_self'
    }
  }
])

// Courses Data
const courses = ref([
  {
    name: 'Cloud Basic',
    duration: '2일 과정',
    icon: 'i-lucide-book-open',
    gradient: 'bg-gradient-to-br from-blue-500 to-blue-600',
    topics: [
      'AWS/GCP 기초 서비스',
      'IAM 사용자 및 권한 관리',
      'EC2/Compute Engine 인스턴스',
      'S3/Cloud Storage 버킷 관리'
    ],
    environment: 'AWS Free Tier + GCP Free Tier',
    link: '/curriculum?path=cloud_basic'
  },
  {
    name: 'Cloud Master',
    duration: '3일 과정',
    icon: 'i-lucide-graduation-cap',
    gradient: 'bg-gradient-to-br from-purple-500 to-purple-600',
    topics: [
      'Docker 컨테이너 기술',
      'Git/GitHub 버전 관리',
      'GitHub Actions CI/CD',
      'VM 기반 웹 애플리케이션 배포'
    ],
    environment: 'AWS Free Tier + GCP Free Tier + GitHub',
    link: '/curriculum?path=cloud_master'
  },
  {
    name: 'Cloud Container',
    duration: '2일 과정',
    icon: 'i-lucide-container',
    gradient: 'bg-gradient-to-br from-green-500 to-green-600',
    topics: [
      'Kubernetes 클러스터 아키텍처',
      'GKE 클러스터 관리',
      'ECS/Fargate 서버리스 컨테이너',
      '고가용성 아키텍처 설계'
    ],
    environment: 'AWS Free Tier + GCP Free Tier + GitHub',
    link: '/curriculum?path=cloud_container'
  }
])

// AI Education Tools Data
const mcpServices = ref([
  {
    name: '교육 자료 생성 AI',
    description: '강사용 커리큘럼 및 실습 가이드 자동 생성',
    icon: 'i-lucide-file-text',
    status: 'active'
  },
  {
    name: '학습 진도 관리',
    description: '학생별 학습 진행 상황 추적 및 분석',
    icon: 'i-lucide-trending-up',
    status: 'active'
  },
  {
    name: '실습 환경 자동화',
    description: '클라우드 실습 환경 자동 구축 및 관리',
    icon: 'i-lucide-server',
    status: 'active'
  },
  {
    name: 'AI 튜터링 시스템',
    description: '개인화된 학습 지원 및 질문 답변',
    icon: 'i-lucide-message-circle',
    status: 'active'
  }
])

// Statistics Data
const statistics = ref([
  { value: '3+', label: '교육 과정' },
  { value: '50+', label: '실습 가이드' },
  { value: '100+', label: 'AI 교육 도구' },
  { value: '24/7', label: '학습 지원' }
])

// MCP 서비스 상태 확인
const checkMCPStatus = async () => {
  try {
    // 실제 MCP 서비스 상태를 확인하는 로직을 여기에 추가
    // 예: API 호출을 통한 서비스 상태 확인
    console.log('MCP 서비스 상태 확인 중...')
  } catch (error) {
    console.error('MCP 서비스 상태 확인 실패:', error)
  }
}

onMounted(() => {
  checkMCPStatus()
})
</script>

<style scoped>
/* 애니메이션 정의 */
@keyframes fade-in {
  from {
    opacity: 0;
    transform: translateY(20px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

@keyframes slide-up {
  from {
    opacity: 0;
    transform: translateY(40px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

@keyframes float {
  0%, 100% {
    transform: translateY(0px);
  }
  50% {
    transform: translateY(-20px);
  }
}

/* 애니메이션 클래스 */
.animate-fade-in {
  animation: fade-in 0.8s ease-out forwards;
}

.animate-slide-up {
  animation: slide-up 1s ease-out forwards;
  opacity: 0;
}

.animate-float {
  animation: float 6s ease-in-out infinite;
}

/* 애니메이션 지연 */
.animation-delay-200 {
  animation-delay: 0.2s;
}

.animation-delay-400 {
  animation-delay: 0.4s;
}

.animation-delay-1000 {
  animation-delay: 1s;
}

.animation-delay-2000 {
  animation-delay: 2s;
}

/* 호버 효과 개선 */
.group:hover .group-hover\:translate-x-1 {
  transform: translateX(0.25rem);
}

.group:hover .group-hover\:scale-110 {
  transform: scale(1.1);
}

/* 그라데이션 텍스트 */
.bg-clip-text {
  -webkit-background-clip: text;
  background-clip: text;
}

/* 백드롭 블러 지원 */
.backdrop-blur-sm {
  backdrop-filter: blur(4px);
}

/* 커스텀 그림자 */
.shadow-3xl {
  box-shadow: 0 35px 60px -12px rgba(0, 0, 0, 0.25);
}

/* 반응형 개선 */
@media (max-width: 768px) {
  .text-5xl {
    font-size: 2.5rem;
  }
  
  .text-7xl {
    font-size: 3.5rem;
  }
  
  .py-24 {
    padding-top: 3rem;
    padding-bottom: 3rem;
  }
}

/* 다크 모드 개선 */
@media (prefers-color-scheme: dark) {
  .bg-gradient-to-br {
    background-image: linear-gradient(to bottom right, var(--tw-gradient-stops));
  }
}

/* 스크롤 애니메이션을 위한 Intersection Observer 지원 */
.animate-on-scroll {
  opacity: 0;
  transform: translateY(30px);
  transition: all 0.6s ease-out;
}

.animate-on-scroll.visible {
  opacity: 1;
  transform: translateY(0);
}

/* 배경 패턴 */
.bg-dot-pattern {
  background-image: radial-gradient(circle, rgba(255, 255, 255, 0.1) 1px, transparent 1px);
  background-size: 20px 20px;
}
</style>