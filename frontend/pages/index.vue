<template>
  <div class="min-h-screen bg-gradient-to-br from-blue-50 via-white to-purple-50">
    <!-- Hero Section -->
    <UPageHero
      :title="heroData.title"
      :description="heroData.description"
      :headline="heroData.headline"
      :links="heroData.links"
      class="relative overflow-hidden"
    >
      <template #headline>
        <div class="flex items-center gap-2 text-sm font-medium text-primary-600 dark:text-primary-400">
          <UIcon name="i-lucide-sparkles" class="w-4 h-4" />
          <span>{{ heroData.headline }}</span>
        </div>
      </template>
      
      <template #links>
        <div class="flex flex-col sm:flex-row gap-3">
          <UButton
            v-for="link in heroData.links"
            :key="link.label"
            :to="link.to"
            :target="link.target"
            :color="link.color || 'primary'"
            :variant="link.variant || 'solid'"
            :size="link.size || 'lg'"
            :icon="link.icon"
            class="w-full sm:w-auto"
          >
            {{ link.label }}
          </UButton>
        </div>
      </template>
    </UPageHero>

    <!-- Features Section -->
    <UPageSection>
      <UContainer>
        <div class="text-center mb-16">
          <h2 class="text-3xl font-bold text-gray-900 dark:text-white mb-4">
            🚀 MCP 기반 클라우드 플랫폼
          </h2>
          <p class="text-lg text-gray-600 dark:text-gray-300 max-w-2xl mx-auto">
            AI 에이전트와 함께하는 멀티클라우드 관리 플랫폼으로 AWS, GCP 환경을 통합 관리하세요
          </p>
        </div>

        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
          <UCard
            v-for="feature in features"
            :key="feature.title"
            class="hover:shadow-lg transition-all duration-300 hover:-translate-y-1"
          >
            <template #header>
              <div class="flex items-center gap-3">
                <div class="p-2 bg-primary-100 dark:bg-primary-900 rounded-lg">
                  <UIcon :name="feature.icon" class="w-6 h-6 text-primary-600 dark:text-primary-400" />
                </div>
                <h3 class="text-xl font-semibold text-gray-900 dark:text-white">
                  {{ feature.title }}
                </h3>
              </div>
            </template>

            <p class="text-gray-600 dark:text-gray-300 mb-4">
              {{ feature.description }}
            </p>

            <UButton
              v-if="feature.action"
              :to="feature.action.to"
              :target="feature.action.target"
              variant="ghost"
              color="primary"
              size="sm"
              class="w-full"
            >
              {{ feature.action.label }}
              <UIcon name="i-lucide-arrow-right" class="w-4 h-4 ml-1" />
            </UButton>
          </UCard>
        </div>
      </UContainer>
    </UPageSection>

    <!-- Course Overview Section -->
    <UPageSection class="bg-gray-50 dark:bg-gray-900/50">
      <UContainer>
        <div class="text-center mb-16">
          <h2 class="text-3xl font-bold text-gray-900 dark:text-white mb-4">
            📚 클라우드 실무력 강화 과정
          </h2>
          <p class="text-lg text-gray-600 dark:text-gray-300 max-w-2xl mx-auto">
            3단계 체계적 학습으로 클라우드 전문가가 되세요
          </p>
        </div>

        <div class="grid grid-cols-1 lg:grid-cols-3 gap-8">
          <UCard
            v-for="course in courses"
            :key="course.name"
            class="relative overflow-hidden hover:shadow-xl transition-all duration-300 hover:-translate-y-2"
            :class="course.gradient"
          >
            <template #header>
              <div class="text-center">
                <div class="inline-flex items-center justify-center w-16 h-16 bg-white/20 rounded-full mb-4">
                  <UIcon :name="course.icon" class="w-8 h-8 text-white" />
                </div>
                <h3 class="text-2xl font-bold text-white mb-2">{{ course.name }}</h3>
                <p class="text-white/80">{{ course.duration }}</p>
              </div>
            </template>

            <div class="space-y-4">
              <div class="text-white/90">
                <h4 class="font-semibold mb-2">주요 내용</h4>
                <ul class="space-y-1 text-sm">
                  <li v-for="item in course.topics" :key="item" class="flex items-center gap-2">
                    <UIcon name="i-lucide-check" class="w-4 h-4 text-green-300" />
                    {{ item }}
                  </li>
                </ul>
              </div>

              <div class="text-white/90">
                <h4 class="font-semibold mb-2">실습 환경</h4>
                <p class="text-sm">{{ course.environment }}</p>
              </div>

              <UButton
                :to="course.link"
                variant="solid"
                color="white"
                size="lg"
                class="w-full mt-6"
              >
                과정 상세보기
                <UIcon name="i-lucide-arrow-right" class="w-4 h-4 ml-1" />
              </UButton>
            </div>
          </UCard>
        </div>
      </UContainer>
    </UPageSection>

    <!-- MCP Services Section -->
    <UPageSection>
      <UContainer>
        <div class="text-center mb-16">
          <h2 class="text-3xl font-bold text-gray-900 dark:text-white mb-4">
            🤖 MCP 서비스 통합
          </h2>
          <p class="text-lg text-gray-600 dark:text-gray-300 max-w-2xl mx-auto">
            다양한 MCP 서버들을 통합하여 강력한 AI 기반 클라우드 관리 기능을 제공합니다
          </p>
        </div>

        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
          <UCard
            v-for="service in mcpServices"
            :key="service.name"
            class="text-center hover:shadow-lg transition-all duration-300 hover:-translate-y-1"
          >
            <div class="p-6">
              <div class="inline-flex items-center justify-center w-12 h-12 bg-primary-100 dark:bg-primary-900 rounded-lg mb-4">
                <UIcon :name="service.icon" class="w-6 h-6 text-primary-600 dark:text-primary-400" />
              </div>
              <h3 class="text-lg font-semibold text-gray-900 dark:text-white mb-2">
                {{ service.name }}
              </h3>
              <p class="text-sm text-gray-600 dark:text-gray-300 mb-4">
                {{ service.description }}
              </p>
              <UBadge
                :color="service.status === 'active' ? 'green' : 'gray'"
                variant="soft"
                size="sm"
              >
                {{ service.status === 'active' ? '활성' : '준비중' }}
              </UBadge>
            </div>
          </UCard>
        </div>
      </UContainer>
    </UPageSection>

    <!-- Statistics Section -->
    <UPageSection class="bg-primary-600 dark:bg-primary-700">
      <UContainer>
        <div class="grid grid-cols-1 md:grid-cols-4 gap-8 text-center">
          <div
            v-for="stat in statistics"
            :key="stat.label"
            class="text-white"
          >
            <div class="text-4xl font-bold mb-2">{{ stat.value }}</div>
            <div class="text-white/80">{{ stat.label }}</div>
          </div>
        </div>
      </UContainer>
    </UPageSection>

    <!-- CTA Section -->
    <UPageSection>
      <UContainer>
        <UCard class="text-center bg-gradient-to-r from-primary-50 to-purple-50 dark:from-primary-900/20 dark:to-purple-900/20">
          <div class="py-12">
            <h2 class="text-3xl font-bold text-gray-900 dark:text-white mb-4">
              🎯 지금 시작하세요!
            </h2>
            <p class="text-lg text-gray-600 dark:text-gray-300 mb-8 max-w-2xl mx-auto">
              클라우드 실무력을 한 단계 업그레이드하고, AI와 함께하는 미래의 클라우드 전문가가 되세요
            </p>
            <div class="flex flex-col sm:flex-row gap-4 justify-center">
              <UButton
                to="/curriculum"
                size="xl"
                color="primary"
                class="px-8 py-4"
              >
                <UIcon name="i-lucide-book-open" class="w-5 h-5 mr-2" />
                커리큘럼 시작하기
              </UButton>
              <UButton
                to="/knowledge-base"
                size="xl"
                variant="outline"
                color="primary"
                class="px-8 py-4"
              >
                <UIcon name="i-lucide-graduation-cap" class="w-5 h-5 mr-2" />
                지식베이스 탐색
              </UButton>
              <UButton
                to="/mcp-demo"
                size="xl"
                variant="outline"
                color="purple"
                class="px-8 py-4"
              >
                <UIcon name="i-lucide-robot" class="w-5 h-5 mr-2" />
                MCP 데모 체험
              </UButton>
            </div>
          </div>
        </UCard>
      </UContainer>
    </UPageSection>

    <!-- Footer -->
    <footer class="bg-gray-900 text-white py-12">
      <UContainer>
        <div class="grid grid-cols-1 md:grid-cols-4 gap-8">
          <div>
            <h3 class="text-lg font-semibold mb-4">MCP Cloud Platform</h3>
            <p class="text-gray-400 text-sm">
              AI 기반 멀티클라우드 관리 플랫폼으로 클라우드 실무력을 강화하세요
            </p>
          </div>
          <div>
            <h4 class="font-semibold mb-4">과정</h4>
            <ul class="space-y-2 text-sm text-gray-400">
              <li><NuxtLink to="/curriculum?path=cloud_basic" class="hover:text-white transition-colors">Cloud Basic</NuxtLink></li>
              <li><NuxtLink to="/curriculum?path=cloud_master" class="hover:text-white transition-colors">Cloud Master</NuxtLink></li>
              <li><NuxtLink to="/curriculum?path=cloud_container" class="hover:text-white transition-colors">Cloud Container</NuxtLink></li>
            </ul>
          </div>
          <div>
            <h4 class="font-semibold mb-4">리소스</h4>
            <ul class="space-y-2 text-sm text-gray-400">
              <li><NuxtLink to="/knowledge-base" class="hover:text-white transition-colors">지식베이스</NuxtLink></li>
              <li><NuxtLink to="/billing" class="hover:text-white transition-colors">요금제</NuxtLink></li>
              <li><NuxtLink to="/cli" class="hover:text-white transition-colors">CLI 도구</NuxtLink></li>
            </ul>
          </div>
          <div>
            <h4 class="font-semibold mb-4">지원</h4>
            <ul class="space-y-2 text-sm text-gray-400">
              <li><a href="#" class="hover:text-white transition-colors">문의하기</a></li>
              <li><a href="#" class="hover:text-white transition-colors">도움말</a></li>
              <li><a href="#" class="hover:text-white transition-colors">커뮤니티</a></li>
            </ul>
          </div>
        </div>
        <div class="border-t border-gray-800 mt-8 pt-8 text-center text-sm text-gray-400">
          <p>&copy; 2024 MCP Cloud Platform. All rights reserved.</p>
        </div>
      </UContainer>
    </footer>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'

definePageMeta({ 
  layout: 'default', 
  title: 'MCP Cloud Platform - AI 기반 멀티클라우드 관리',
  description: 'AI 에이전트와 함께하는 멀티클라우드 관리 플랫폼으로 AWS, GCP 환경을 통합 관리하고 클라우드 실무력을 강화하세요.'
})

// Hero Section Data
const heroData = ref({
  title: 'MCP Cloud Platform',
  description: 'AI 에이전트와 함께하는 멀티클라우드 관리 플랫폼으로 AWS, GCP 환경을 통합 관리하고 클라우드 실무력을 강화하세요.',
  headline: 'AI 기반 클라우드 실무력 강화',
  links: [
    {
      label: '커리큘럼 시작하기',
      to: '/curriculum',
      icon: 'i-lucide-book-open',
      color: 'primary',
      variant: 'solid'
    },
    {
      label: '지식베이스 탐색',
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
    title: 'AI 기반 인프라 관리',
    description: 'MCP 서버를 통한 AI 에이전트가 인프라 설계, 배포, 모니터링을 자동화합니다.',
    icon: 'i-lucide-brain',
    action: {
      label: '자세히 보기',
      to: '/curriculum?path=cloud_master',
      target: '_self'
    }
  },
  {
    title: '멀티클라우드 통합',
    description: 'AWS, GCP 환경을 하나의 플랫폼에서 통합 관리하고 최적화합니다.',
    icon: 'i-lucide-cloud',
    action: {
      label: '환경 설정',
      to: '/curriculum?path=cloud_basic',
      target: '_self'
    }
  },
  {
    title: '실시간 모니터링',
    description: '클라우드 리소스의 성능과 비용을 실시간으로 모니터링하고 최적화합니다.',
    icon: 'i-lucide-bar-chart-3',
    action: {
      label: '모니터링 설정',
      to: '/billing',
      target: '_self'
    }
  },
  {
    title: '자동화된 CI/CD',
    description: 'GitHub Actions와 통합된 자동화된 배포 파이프라인을 구축합니다.',
    icon: 'i-lucide-git-branch',
    action: {
      label: 'CI/CD 설정',
      to: '/curriculum?path=cloud_master/textbook/Day2',
      target: '_self'
    }
  },
  {
    title: '컨테이너 오케스트레이션',
    description: 'Kubernetes, ECS, Fargate를 활용한 고급 컨테이너 관리 기능을 제공합니다.',
    icon: 'i-lucide-container',
    action: {
      label: '컨테이너 학습',
      to: '/curriculum?path=cloud_container',
      target: '_self'
    }
  },
  {
    title: '보안 및 컴플라이언스',
    description: '클라우드 보안 모범 사례와 컴플라이언스 요구사항을 자동으로 적용합니다.',
    icon: 'i-lucide-shield-check',
    action: {
      label: '보안 가이드',
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

// MCP Services Data
const mcpServices = ref([
  {
    name: 'Context7',
    description: '라이브러리 문서 및 코드 예제 검색',
    icon: 'i-lucide-search',
    status: 'active'
  },
  {
    name: 'GitHub MCP',
    description: 'GitHub 리포지토리 및 이슈 관리',
    icon: 'i-simple-icons-github',
    status: 'active'
  },
  {
    name: 'PostgreSQL MCP',
    description: '데이터베이스 쿼리 및 관리',
    icon: 'i-lucide-database',
    status: 'active'
  },
  {
    name: 'Filesystem MCP',
    description: '파일 시스템 관리 및 조작',
    icon: 'i-lucide-folder',
    status: 'active'
  }
])

// Statistics Data
const statistics = ref([
  { value: '3+', label: '클라우드 과정' },
  { value: '50+', label: '실습 가이드' },
  { value: '100+', label: 'MCP 서비스' },
  { value: '24/7', label: 'AI 지원' }
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
/* 추가적인 커스텀 스타일이 필요한 경우 여기에 추가 */
</style>