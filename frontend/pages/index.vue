<template>
  <div class="bg-slate-900 text-white font-sans">
    <!-- Header/Nav Placeholder -->
    <header class="sticky top-0 z-50 bg-slate-900/80 backdrop-blur-sm">
      <UContainer class="py-4 flex justify-between items-center">
        <div class="flex items-center gap-3">
          <UIcon name="i-lucide-layers" class="w-7 h-7 text-primary-400" />
          <span class="text-xl font-bold">MCP Cloud Platform</span>
        </div>
        <nav class="hidden md:flex items-center gap-6 text-sm">
          <NuxtLink to="#features" class="hover:text-primary-400 transition-colors">주요 기능</NuxtLink>
          <NuxtLink to="#curriculum" class="hover:text-primary-400 transition-colors">교육 과정</NuxtLink>
          <NuxtLink to="#how-it-works" class="hover:text-primary-400 transition-colors">동작 방식</NuxtLink>
          <NuxtLink to="/knowledge-base" class="hover:text-primary-400 transition-colors">지식베이스</NuxtLink>
        </nav>
        <UButton to="/curriculum" variant="outline" color="white" trailing-icon="i-lucide-arrow-right" class="hidden md:inline-flex">
          지금 시작하기
        </UButton>
      </UContainer>
    </header>

    <main>
      <!-- Hero Section -->
      <UPageSection>
        <UContainer class="text-center py-20 lg:py-28 relative">
           <div class="absolute inset-0 -z-10 bg-[radial-gradient(ellipse_80%_80%_at_50%_-20%,rgba(120,119,198,0.3),rgba(255,255,255,0))]"></div>
          <h1 class="text-4xl md:text-6xl font-extrabold tracking-tighter bg-clip-text text-transparent bg-gradient-to-br from-white to-gray-400">
            AI 에이전트와 함께하는<br>차세대 클라우드 관리 플랫폼
          </h1>
          <p class="mt-6 max-w-2xl mx-auto text-lg text-gray-300">
            복잡한 멀티클라우드 환경(AWS, GCP)을 하나의 플랫폼에서 통합 관리하고, AI 기반 자동화로 클라우드 실무 역량을 극대화하세요.
          </p>
          <div class="mt-10 flex flex-col sm:flex-row gap-4 justify-center">
            <UButton to="/curriculum" size="xl" color="primary" class="px-8 py-3.5 transition-transform hover:scale-105">
              <UIcon name="i-lucide-book-open" class="w-5 h-5 mr-2" />
              커리큘럼 시작하기
            </UButton>
            <UButton to="#how-it-works" size="xl" variant="outline" color="white" class="px-8 py-3.5 transition-transform hover:scale-105">
              <UIcon name="i-lucide-play-circle" class="w-5 h-5 mr-2" />
              플랫폼 동작 방식 보기
            </UButton>
          </div>
        </UContainer>
      </UPageSection>
      
      <!-- Features Section -->
      <UPageSection id="features">
        <UContainer>
          <div class="text-center mb-16">
            <h2 class="text-3xl font-bold tracking-tight">핵심 역량을 강화하는 기능들</h2>
            <p class="mt-4 text-lg text-gray-400">클라우드 관리의 모든 과정을 자동화하고 최적화합니다.</p>
          </div>
          <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
            <UCard
              v-for="feature in features"
              :key="feature.title"
              class="bg-slate-800/50 hover:bg-slate-800 ring-1 ring-slate-800 hover:ring-primary-500 transition-all duration-300 hover:-translate-y-2"
            >
              <div class="flex items-start gap-4">
                <div class="p-2 bg-primary-500/10 rounded-lg">
                  <UIcon :name="feature.icon" class="w-6 h-6 text-primary-400" />
                </div>
                <div>
                  <h3 class="text-lg font-semibold text-white">{{ feature.title }}</h3>
                  <p class="mt-1 text-sm text-gray-400">{{ feature.description }}</p>
                </div>
              </div>
            </UCard>
          </div>
        </UContainer>
      </UPageSection>

      <!-- How It Works Section -->
      <UPageSection id="how-it-works" class="bg-slate-950/50">
        <UContainer>
          <div class="text-center mb-16">
            <h2 class="text-3xl font-bold tracking-tight">AI 기반 자동화 워크플로우</h2>
            <p class="mt-4 text-lg text-gray-400">사용자 요청부터 배포까지, AI가 모든 단계를 지능적으로 처리합니다.</p>
          </div>
          <div class="relative">
            <!-- Connecting line -->
            <div class="absolute left-1/2 top-12 bottom-12 w-0.5 bg-slate-700 hidden lg:block"></div>
            
            <div class="grid grid-cols-1 lg:grid-cols-3 gap-12 lg:gap-0">
              <div v-for="(step, index) in workflowSteps" :key="step.title" class="flex flex-col items-center text-center">
                 <div class="relative flex items-center justify-center w-24 h-24 bg-slate-800 border border-slate-700 rounded-full">
                    <div class="absolute -inset-1 rounded-full bg-gradient-to-r from-purple-600 to-blue-600 opacity-0 group-hover:opacity-75 transition-opacity duration-300 blur"></div>
                    <div class="relative w-20 h-20 flex items-center justify-center bg-slate-900 rounded-full">
                        <UIcon :name="step.icon" class="w-10 h-10 text-primary-400"/>
                    </div>
                </div>
                <h3 class="mt-6 text-xl font-semibold">{{ step.title }}</h3>
                <p class="mt-2 text-gray-400 max-w-xs">{{ step.description }}</p>
              </div>
            </div>
          </div>
        </UContainer>
      </UPageSection>

      <!-- Course Overview Section -->
      <UPageSection id="curriculum">
        <UContainer>
          <div class="text-center mb-16">
            <h2 class="text-3xl font-bold tracking-tight">체계적인 클라우드 전문가 과정</h2>
            <p class="mt-4 text-lg text-gray-400">기초부터 심화까지, 실습 중심의 커리큘럼으로 실무 역량을 완성하세요.</p>
          </div>
          <div class="grid grid-cols-1 lg:grid-cols-3 gap-8">
            <div
              v-for="course in courses"
              :key="course.name"
              class="relative p-8 rounded-xl border border-slate-800 overflow-hidden transition-all duration-300 hover:border-primary-500/50 hover:shadow-2xl hover:shadow-primary-500/10"
              :class="course.gradient"
            >
              <div class="relative z-10">
                <UIcon :name="course.icon" class="w-10 h-10 mb-4 text-white" />
                <h3 class="text-2xl font-bold text-white mb-2">{{ course.name }}</h3>
                <p class="text-white/80 mb-6">{{ course.duration }}</p>
                <ul class="space-y-2 text-sm text-white/90">
                  <li v-for="item in course.topics" :key="item" class="flex items-center gap-3">
                    <UIcon name="i-lucide-check-circle-2" class="w-4 h-4 text-green-400" />
                    <span>{{ item }}</span>
                  </li>
                </ul>
                <UButton
                  :to="course.link"
                  variant="solid"
                  color="white"
                  size="lg"
                  block
                  class="mt-8 !text-slate-900"
                >
                  과정 상세보기
                </UButton>
              </div>
            </div>
          </div>
        </UContainer>
      </UPageSection>
      
      <!-- Testimonials Section -->
      <UPageSection class="bg-slate-950/50">
        <UContainer>
          <div class="text-center mb-16">
            <h2 class="text-3xl font-bold tracking-tight">수강생들이 인정한 최고의 과정</h2>
            <p class="mt-4 text-lg text-gray-400">실제 현업 개발자들의 생생한 후기를 확인해보세요.</p>
          </div>
          <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
            <UCard v-for="testimonial in testimonials" :key="testimonial.name" class="bg-slate-800/50 ring-1 ring-slate-800">
              <q class="italic text-gray-300">{{ testimonial.quote }}</q>
              <div class="flex items-center gap-4 mt-6">
                 <UAvatar :src="testimonial.avatar" size="lg" />
                 <div>
                   <p class="font-semibold text-white">{{ testimonial.name }}</p>
                   <p class="text-sm text-gray-400">{{ testimonial.role }}</p>
                 </div>
              </div>
            </UCard>
          </div>
        </UContainer>
      </UPageSection>
      
      <!-- CTA Section -->
      <UPageSection>
        <UContainer>
          <div class="relative py-16 px-8 rounded-2xl bg-gradient-to-r from-primary-600 via-purple-600 to-blue-600 overflow-hidden">
            <div class="absolute -top-10 -right-10 w-40 h-40 bg-white/10 rounded-full filter blur-3xl"></div>
            <div class="absolute -bottom-16 -left-10 w-56 h-56 bg-white/10 rounded-full filter blur-3xl"></div>
            <div class="relative text-center">
              <h2 class="text-3xl md:text-4xl font-extrabold text-white">
                미래의 클라우드 전문가가 될 준비가 되셨나요?
              </h2>
              <p class="mt-4 max-w-2xl mx-auto text-lg text-white/80">
                지금 바로 AI 기반 클라우드 관리 플랫폼을 경험하고, 체계적인 커리큘럼으로 최고의 전문가로 거듭나세요.
              </p>
              <UButton to="/curriculum" size="xl" color="white" class="mt-8 px-10 py-4 !text-primary-600 font-bold transition-transform hover:scale-105">
                지금 바로 시작하기
              </UButton>
            </div>
          </div>
        </UContainer>
      </UPageSection>

      <!-- Footer -->
      <footer class="border-t border-slate-800">
        <UContainer class="py-12">
          <div class="grid grid-cols-2 md:grid-cols-4 gap-8">
            <!-- Column 1 -->
            <div class="col-span-2 md:col-span-1">
              <h3 class="text-lg font-semibold mb-4">MCP Cloud Platform</h3>
              <p class="text-gray-400 text-sm">
                AI 기반 멀티클라우드 관리 플랫폼으로 클라우드 실무력을 강화하세요.
              </p>
            </div>
            <!-- Column 2 -->
            <div>
              <h4 class="font-semibold mb-4">과정</h4>
              <ul class="space-y-2 text-sm text-gray-400">
                <li><NuxtLink to="/curriculum?path=cloud_basic" class="hover:text-white transition-colors">Cloud Basic</NuxtLink></li>
                <li><NuxtLink to="/curriculum?path=cloud_master" class="hover:text-white transition-colors">Cloud Master</NuxtLink></li>
                <li><NuxtLink to="/curriculum?path=cloud_container" class="hover:text-white transition-colors">Cloud Container</NuxtLink></li>
              </ul>
            </div>
            <!-- Column 3 -->
            <div>
              <h4 class="font-semibold mb-4">리소스</h4>
              <ul class="space-y-2 text-sm text-gray-400">
                <li><NuxtLink to="/knowledge-base" class="hover:text-white transition-colors">지식베이스</NuxtLink></li>
                <li><NuxtLink to="/billing" class="hover:text-white transition-colors">요금제</NuxtLink></li>
                <li><NuxtLink to="/cli" class="hover:text-white transition-colors">CLI 도구</NuxtLink></li>
              </ul>
            </div>
            <!-- Column 4 -->
            <div>
              <h4 class="font-semibold mb-4">지원</h4>
              <ul class="space-y-2 text-sm text-gray-400">
                <li><a href="#" class="hover:text-white transition-colors">문의하기</a></li>
                <li><a href="#" class="hover:text-white transition-colors">도움말</a></li>
                <li><a href="#" class="hover:text-white transition-colors">커뮤니티</a></li>
              </ul>
            </div>
          </div>
          <div class="border-t border-slate-800 mt-8 pt-8 text-center text-sm text-gray-500">
            <p>&copy; 2024 MCP Cloud Platform. All rights reserved.</p>
          </div>
        </UContainer>
      </footer>
    </main>
  </div>
</template>

<script setup>
import { ref } from 'vue'

definePageMeta({
  layout: 'default',
  title: 'MCP Cloud Platform - AI 기반 멀티클라우드 관리',
  description: 'AI 에이전트와 함께하는 멀티클라우드 관리 플랫폼으로 AWS, GCP 환경을 통합 관리하고 클라우드 실무력을 강화하세요.'
})

// Features Data
const features = ref([
  {
    title: 'AI 기반 인프라 관리',
    description: 'AI 에이전트가 인프라 설계, 배포, 모니터링을 자동화하여 운영 부담을 줄여줍니다.',
    icon: 'i-lucide-brain-circuit'
  },
  {
    title: '멀티클라우드 통합',
    description: 'AWS, GCP 등 분산된 클라우드 환경을 단일 대시보드에서 통합 관리하고 최적화합니다.',
    icon: 'i-lucide-cloudy'
  },
  {
    title: '실시간 비용 및 성능 모니터링',
    description: '클라우드 리소스의 성능과 비용을 실시간으로 추적하고 이상 징후를 감지합니다.',
    icon: 'i-lucide-bar-chart-3'
  },
  {
    title: '자동화된 CI/CD 파이프라인',
    description: 'GitHub Actions와 연동하여 코드 변경부터 배포까지 전 과정을 자동화합니다.',
    icon: 'i-lucide-git-branch-plus'
  },
  {
    title: '컨테이너 오케스트레이션',
    description: 'Kubernetes, ECS, Fargate를 활용한 고급 컨테이너 관리 기능을 제공합니다.',
    icon: 'i-lucide-cuboid'
  },
  {
    title: '강화된 보안 및 컴플라이언스',
    description: '클라우드 보안 모범 사례와 컴플라이언스 요구사항을 자동으로 적용하고 검사합니다.',
    icon: 'i-lucide-shield-check'
  }
])

// Workflow Steps Data
const workflowSteps = ref([
    {
        title: '요구사항 분석',
        description: '사용자가 자연어로 인프라 요구사항을 입력하면, AI가 의도를 파악하고 분석합니다.',
        icon: 'i-lucide-file-text'
    },
    {
        title: '계획 및 검증',
        description: 'RAG 기술로 최적의 아키텍처를 설계하고, 정책 및 보안 검사를 통해 안정성을 확보합니다.',
        icon: 'i-lucide-shield-check'
    },
    {
        title: '자동 배포 및 모니터링',
        description: '승인된 계획에 따라 인프라를 자동으로 배포하고, 지속적인 모니터링을 시작합니다.',
        icon: 'i-lucide-rocket'
    }
])


// Courses Data
const courses = ref([
  {
    name: 'Cloud Basic',
    duration: '2일 과정',
    icon: 'i-lucide-cloud',
    gradient: 'bg-gradient-to-br from-blue-500/10 to-blue-600/10',
    topics: [
      'AWS/GCP 기초 서비스',
      'IAM 사용자 및 권한 관리',
      'EC2/Compute Engine 인스턴스',
      'S3/Cloud Storage 버킷 관리'
    ],
    link: '/curriculum?path=cloud_basic'
  },
  {
    name: 'Cloud Master',
    duration: '3일 과정',
    icon: 'i-lucide-graduation-cap',
    gradient: 'bg-gradient-to-br from-purple-500/10 to-purple-600/10',
    topics: [
      'Docker 컨테이너 기술',
      'Git/GitHub 버전 관리',
      'GitHub Actions CI/CD',
      'VM 기반 웹 애플리케이션 배포'
    ],
    link: '/curriculum?path=cloud_master'
  },
  {
    name: 'Cloud Container',
    duration: '2일 과정',
    icon: 'i-lucide-container',
    gradient: 'bg-gradient-to-br from-green-500/10 to-green-600/10',
    topics: [
      'Kubernetes 클러스터 아키텍처',
      'GKE 클러스터 관리',
      'ECS/Fargate 서버리스 컨테이너',
      '고가용성 아키텍처 설계'
    ],
    link: '/curriculum?path=cloud_container'
  }
])

// Testimonials Data
const testimonials = ref([
  {
    name: '김민준',
    role: '백엔드 개발자, 스타트업',
    quote: '복잡한 클라우드 개념을 실습 위주로 배우니 이해가 정말 잘 됐습니다. 이제 AWS와 GCP를 자신있게 다룰 수 있게 됐어요.',
    avatar: 'https://i.pravatar.cc/150?u=a042581f4e29026704d'
  },
  {
    name: '이서연',
    role: '데브옵스 엔지니어, IT 기업',
    quote: 'AI를 이용한 인프라 관리가 이렇게 강력할 줄 몰랐습니다. 반복적인 배포 작업이 줄어들어 핵심 업무에 더 집중할 수 있게 되었습니다.',
    avatar: 'https://i.pravatar.cc/150?u=a042581f4e29026705d'
  },
  {
    name: '박지훈',
    role: '프로덕트 매니저, 핀테크',
    quote: '개발팀과의 커뮤니케이션에 큰 도움이 되었습니다. 클라우드 아키텍처에 대한 이해도가 높아져 더 효율적인 기획이 가능해졌습니다.',
    avatar: 'https://i.pravatar.cc/150?u=a042581f4e29026706d'
  }
])

</script>

<style scoped>
/* Scoped styles for custom animations or adjustments */
@import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800;900&display=swap');

body {
  font-family: 'Inter', sans-serif;
}
</style>
