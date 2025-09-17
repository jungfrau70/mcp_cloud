<template>
  <div class="bg-slate-900 text-white font-sans overflow-hidden">
    <!-- Floating Navigation -->
    <header class="fixed top-4 left-1/2 transform -translate-x-1/2 z-50 w-full max-w-6xl px-4">
      <nav class="bg-white/5 backdrop-blur-xl border border-white/10 rounded-2xl px-6 py-3 shadow-2xl">
        <div class="flex justify-between items-center">
          <div class="flex items-center gap-3">
            <div class="p-2 bg-gradient-to-br from-blue-400 to-purple-500 rounded-xl">
              <UIcon name="i-lucide-graduation-cap" class="w-6 h-6 text-white" />
            </div>
            <span class="text-lg font-bold bg-gradient-to-r from-blue-400 to-purple-400 bg-clip-text text-transparent">
              MCP Cloud Platform
            </span>
          </div>
          <nav class="hidden md:flex items-center gap-8 text-sm font-medium">
            <NuxtLink to="#features" class="hover:text-blue-400 transition-colors duration-300">주요 기능</NuxtLink>
            <NuxtLink to="#curriculum" class="hover:text-blue-400 transition-colors duration-300">교육 과정</NuxtLink>
            <NuxtLink to="#how-it-works" class="hover:text-blue-400 transition-colors duration-300">동작 방식</NuxtLink>
            <NuxtLink to="/knowledge-base" class="hover:text-blue-400 transition-colors duration-300">지식베이스</NuxtLink>
          </nav>
          <UButton to="/curriculum" variant="solid" class="bg-gradient-to-r from-blue-500 to-purple-500 hover:from-blue-600 hover:to-purple-600 border-0 px-6 py-2 rounded-xl shadow-lg transition-all duration-300 hover:shadow-blue-500/25 hover:scale-105">
            <UIcon name="i-lucide-rocket" class="w-4 h-4 mr-2" />
            시작하기
          </UButton>
        </div>
      </nav>
    </header>

    <main>
      <!-- Hero Section with Animated Background -->
      <section class="relative min-h-screen flex items-center justify-center overflow-hidden">
        <!-- Animated Background Elements -->
        <div class="absolute inset-0 -z-10">
          <div class="absolute top-20 left-10 w-72 h-72 bg-blue-500/20 rounded-full filter blur-3xl animate-pulse"></div>
          <div class="absolute top-40 right-20 w-96 h-96 bg-purple-500/20 rounded-full filter blur-3xl animate-pulse" style="animation-delay: 2s;"></div>
          <div class="absolute bottom-20 left-1/3 w-80 h-80 bg-cyan-500/20 rounded-full filter blur-3xl animate-pulse" style="animation-delay: 4s;"></div>
          
          <!-- Floating Elements -->
          <div class="absolute top-1/4 left-1/4 animate-float">
            <div class="p-4 bg-white/5 backdrop-blur-sm border border-white/10 rounded-2xl shadow-2xl">
              <UIcon name="i-lucide-brain-circuit" class="w-8 h-8 text-blue-400" />
            </div>
          </div>
          <div class="absolute top-1/3 right-1/4 animate-float-delayed">
            <div class="p-4 bg-white/5 backdrop-blur-sm border border-white/10 rounded-2xl shadow-2xl">
              <UIcon name="i-lucide-cloud" class="w-8 h-8 text-purple-400" />
            </div>
          </div>
          <div class="absolute bottom-1/3 left-1/5 animate-float-slow">
            <div class="p-4 bg-white/5 backdrop-blur-sm border border-white/10 rounded-2xl shadow-2xl">
              <UIcon name="i-lucide-code" class="w-8 h-8 text-cyan-400" />
            </div>
          </div>
        </div>

        <div class="container mx-auto px-6 text-center relative z-10">
          <!-- Main Heading with Animated Gradient -->
          <div class="mb-8">
            <h1 class="text-5xl md:text-7xl font-black tracking-tight mb-6">
              <span class="block bg-gradient-to-r from-blue-400 via-purple-400 to-cyan-400 bg-clip-text text-transparent animate-gradient-x">
                AI 기반 클라우드
              </span>
              <span class="block text-white mt-2">교육 플랫폼</span>
            </h1>
            
            <!-- Subtitle with Typewriter Effect -->
            <div class="relative inline-block">
              <p class="text-xl md:text-2xl text-gray-300 max-w-4xl mx-auto leading-relaxed">
                실무 중심의 체계적인 커리큘럼으로 
                <span class="text-transparent bg-gradient-to-r from-blue-400 to-purple-400 bg-clip-text font-semibold">
                  클라우드 전문가
                </span>
                가 되어보세요
              </p>
              <div class="absolute -inset-1 bg-gradient-to-r from-blue-600/20 to-purple-600/20 rounded-lg blur opacity-30"></div>
            </div>
          </div>

          <!-- Stats Cards -->
          <div class="flex flex-wrap justify-center gap-6 mb-12">
            <div class="bg-white/5 backdrop-blur-xl border border-white/10 rounded-2xl p-6 shadow-2xl hover:bg-white/10 transition-all duration-300">
              <div class="text-3xl font-bold text-blue-400">5000+</div>
              <div class="text-sm text-gray-400">수강생</div>
            </div>
            <div class="bg-white/5 backdrop-blur-xl border border-white/10 rounded-2xl p-6 shadow-2xl hover:bg-white/10 transition-all duration-300">
              <div class="text-3xl font-bold text-purple-400">98%</div>
              <div class="text-sm text-gray-400">취업률</div>
            </div>
            <div class="bg-white/5 backdrop-blur-xl border border-white/10 rounded-2xl p-6 shadow-2xl hover:bg-white/10 transition-all duration-300">
              <div class="text-3xl font-bold text-cyan-400">24/7</div>
              <div class="text-sm text-gray-400">AI 지원</div>
            </div>
          </div>

          <!-- CTA Buttons -->
          <div class="flex flex-col sm:flex-row gap-6 justify-center items-center">
            <UButton 
              to="/curriculum" 
              size="xl" 
              class="group bg-gradient-to-r from-blue-500 to-purple-500 hover:from-blue-600 hover:to-purple-600 border-0 px-10 py-4 rounded-2xl shadow-xl transition-all duration-300 hover:shadow-blue-500/25 hover:scale-105"
            >
              <UIcon name="i-lucide-play-circle" class="w-6 h-6 mr-3 group-hover:rotate-12 transition-transform" />
              <span class="text-lg font-semibold">무료 체험 시작</span>
            </UButton>
            
            <UButton 
              to="#how-it-works" 
              variant="outline" 
              size="xl" 
              class="border-2 border-white/20 hover:border-white/40 hover:bg-white/5 px-10 py-4 rounded-2xl backdrop-blur-sm transition-all duration-300 hover:scale-105"
            >
              <UIcon name="i-lucide-book-open" class="w-6 h-6 mr-3" />
              <span class="text-lg font-semibold">커리큘럼 보기</span>
            </UButton>
          </div>
        </div>

        <!-- Scroll Indicator -->
        <div class="absolute bottom-10 left-1/2 transform -translate-x-1/2 animate-bounce">
          <div class="w-6 h-10 border-2 border-white/30 rounded-full flex justify-center">
            <div class="w-1 h-3 bg-white/50 rounded-full mt-2 animate-pulse"></div>
          </div>
        </div>
      </section>
      
      <!-- Features Section with Interactive Cards -->
      <section id="features" class="py-24 relative">
        <div class="absolute inset-0 bg-gradient-to-b from-slate-900 via-slate-800 to-slate-900"></div>
        <div class="container mx-auto px-6 relative z-10">
          <div class="text-center mb-20">
            <h2 class="text-4xl md:text-5xl font-bold mb-6">
              <span class="bg-gradient-to-r from-blue-400 to-purple-400 bg-clip-text text-transparent">
                혁신적인 학습 경험
              </span>
            </h2>
            <p class="text-xl text-gray-300 max-w-3xl mx-auto">
              AI 기술과 실무 프로젝트를 결합한 차세대 클라우드 교육
            </p>
          </div>
          
          <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
            <div
              v-for="(feature, index) in features"
              :key="feature.title"
              class="group relative p-8 bg-white/5 backdrop-blur-xl border border-white/10 rounded-3xl shadow-2xl hover:shadow-blue-500/20 transition-all duration-500 hover:-translate-y-2 hover:bg-white/10"
              :style="{ animationDelay: `${index * 200}ms` }"
            >
              <!-- Animated Border -->
              <div class="absolute inset-0 rounded-3xl bg-gradient-to-r from-blue-500/20 to-purple-500/20 opacity-0 group-hover:opacity-100 transition-opacity duration-500 blur-sm"></div>
              
              <div class="relative z-10">
                <!-- Icon with Gradient Background -->
                <div class="mb-6 inline-block p-4 bg-gradient-to-br from-blue-500/20 to-purple-500/20 rounded-2xl group-hover:from-blue-500/30 group-hover:to-purple-500/30 transition-all duration-300">
                  <UIcon :name="feature.icon" class="w-8 h-8 text-blue-400 group-hover:text-blue-300 transition-colors" />
                </div>
                
                <h3 class="text-xl font-bold text-white mb-3 group-hover:text-blue-300 transition-colors">
                  {{ feature.title }}
                </h3>
                <p class="text-gray-400 leading-relaxed group-hover:text-gray-300 transition-colors">
                  {{ feature.description }}
                </p>
              </div>
            </div>
          </div>
        </div>
      </section>

      <!-- Learning Path Section -->
      <section id="how-it-works" class="py-24 relative overflow-hidden">
        <div class="absolute inset-0">
          <div class="absolute top-20 right-20 w-96 h-96 bg-blue-500/10 rounded-full filter blur-3xl"></div>
          <div class="absolute bottom-20 left-20 w-96 h-96 bg-purple-500/10 rounded-full filter blur-3xl"></div>
        </div>
        
        <div class="container mx-auto px-6 relative z-10">
          <div class="text-center mb-20">
            <h2 class="text-4xl md:text-5xl font-bold mb-6">
              <span class="bg-gradient-to-r from-purple-400 to-cyan-400 bg-clip-text text-transparent">
                학습 여정
              </span>
            </h2>
            <p class="text-xl text-gray-300 max-w-3xl mx-auto">
              체계적인 단계별 학습으로 전문가까지
            </p>
          </div>
          
          <!-- Interactive Timeline -->
          <div class="relative max-w-4xl mx-auto">
            <!-- Connecting Line -->
            <div class="absolute left-1/2 top-0 bottom-0 w-1 bg-gradient-to-b from-blue-500 via-purple-500 to-cyan-500 transform -translate-x-1/2 hidden lg:block"></div>
            
            <div class="space-y-16">
              <div v-for="(step, index) in workflowSteps" :key="step.title" class="relative">
                <div class="flex items-center justify-center lg:justify-start" :class="index % 2 === 0 ? 'lg:flex-row' : 'lg:flex-row-reverse'">
                  <!-- Content Card -->
                  <div class="flex-1 max-w-md">
                    <div class="group p-8 bg-white/5 backdrop-blur-xl border border-white/10 rounded-3xl shadow-2xl hover:shadow-purple-500/20 transition-all duration-500 hover:-translate-y-1">
                      <div class="flex items-center gap-4 mb-4">
                        <div class="p-3 bg-gradient-to-br from-blue-500/20 to-purple-500/20 rounded-2xl">
                          <UIcon :name="step.icon" class="w-6 h-6 text-blue-400" />
                        </div>
                        <div class="px-3 py-1 bg-gradient-to-r from-blue-500/20 to-purple-500/20 rounded-full text-sm font-semibold">
                          Step {{ index + 1 }}
                        </div>
                      </div>
                      <h3 class="text-xl font-bold text-white mb-3">{{ step.title }}</h3>
                      <p class="text-gray-400 leading-relaxed">{{ step.description }}</p>
                    </div>
                  </div>
                  
                  <!-- Center Icon (Desktop) -->
                  <div class="hidden lg:flex items-center justify-center w-16 h-16 bg-gradient-to-r from-blue-500 to-purple-500 rounded-full shadow-lg mx-8 z-10">
                    <div class="w-3 h-3 bg-white rounded-full"></div>
                  </div>
                  
                  <!-- Spacer -->
                  <div class="flex-1 max-w-md hidden lg:block"></div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      <!-- Curriculum Section with Course Cards -->
      <section id="curriculum" class="py-24 relative">
        <div class="absolute inset-0 bg-gradient-to-b from-slate-900 via-slate-800 to-slate-900"></div>
        <div class="container mx-auto px-6 relative z-10">
          <div class="text-center mb-20">
            <h2 class="text-4xl md:text-5xl font-bold mb-6">
              <span class="bg-gradient-to-r from-cyan-400 to-blue-400 bg-clip-text text-transparent">
                전문가 양성 커리큘럼
              </span>
            </h2>
            <p class="text-xl text-gray-300 max-w-3xl mx-auto">
              실무 프로젝트 중심의 체계적인 학습 과정
            </p>
          </div>
          
          <div class="grid grid-cols-1 lg:grid-cols-3 gap-8">
            <div
              v-for="(course, index) in courses"
              :key="course.name"
              class="group relative overflow-hidden rounded-3xl transition-all duration-500 hover:scale-105"
            >
              <!-- Background with Gradient -->
              <div class="absolute inset-0 bg-gradient-to-br" :class="course.gradient"></div>
              <div class="absolute inset-0 bg-black/20 group-hover:bg-black/10 transition-all duration-300"></div>
              
              <!-- Content -->
              <div class="relative z-10 p-8 h-full flex flex-col">
                <!-- Course Icon & Badge -->
                <div class="flex items-center justify-between mb-6">
                  <div class="p-4 bg-white/10 backdrop-blur-sm rounded-2xl group-hover:bg-white/20 transition-all duration-300">
                    <UIcon :name="course.icon" class="w-8 h-8 text-white" />
                  </div>
                  <div class="px-4 py-2 bg-white/10 backdrop-blur-sm rounded-full text-sm font-semibold text-white">
                    {{ course.duration }}
                  </div>
                </div>
                
                <!-- Course Title -->
                <h3 class="text-2xl font-bold text-white mb-4">{{ course.name }}</h3>
                
                <!-- Course Topics -->
                <div class="flex-1 mb-6">
                  <ul class="space-y-3">
                    <li v-for="topic in course.topics" :key="topic" class="flex items-start gap-3">
                      <div class="p-1 bg-green-500/20 rounded-full mt-1">
                        <UIcon name="i-lucide-check" class="w-3 h-3 text-green-400" />
                      </div>
                      <span class="text-white/90 text-sm leading-relaxed">{{ topic }}</span>
                    </li>
                  </ul>
                </div>
                
                <!-- Course CTA -->
                <UButton
                  :to="course.link"
                  variant="solid"
                  size="lg"
                  block
                  class="bg-white/10 hover:bg-white/20 backdrop-blur-sm border border-white/20 transition-all duration-300 group-hover:bg-white/30"
                >
                  <span class="text-white font-semibold">과정 상세보기</span>
                  <UIcon name="i-lucide-arrow-right" class="w-4 h-4 ml-2 group-hover:translate-x-1 transition-transform" />
                </UButton>
              </div>
            </div>
          </div>
        </div>
      </section>
      
      <!-- Testimonials Section -->
      <section class="py-24 relative overflow-hidden">
        <div class="absolute inset-0">
          <div class="absolute top-1/4 left-10 w-72 h-72 bg-blue-500/10 rounded-full filter blur-3xl animate-pulse"></div>
          <div class="absolute bottom-1/4 right-10 w-72 h-72 bg-purple-500/10 rounded-full filter blur-3xl animate-pulse" style="animation-delay: 3s;"></div>
        </div>
        
        <div class="container mx-auto px-6 relative z-10">
          <div class="text-center mb-20">
            <h2 class="text-4xl md:text-5xl font-bold mb-6">
              <span class="bg-gradient-to-r from-yellow-400 to-orange-400 bg-clip-text text-transparent">
                수강생 성공 스토리
              </span>
            </h2>
            <p class="text-xl text-gray-300 max-w-3xl mx-auto">
              실제 취업에 성공한 수강생들의 생생한 후기
            </p>
          </div>
          
          <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
            <div
              v-for="testimonial in testimonials"
              :key="testimonial.name"
              class="group p-8 bg-white/5 backdrop-blur-xl border border-white/10 rounded-3xl shadow-2xl hover:shadow-yellow-500/20 transition-all duration-500 hover:-translate-y-2"
            >
              <!-- Quote Icon -->
              <div class="mb-6">
                <UIcon name="i-lucide-quote" class="w-8 h-8 text-yellow-400" />
              </div>
              
              <!-- Quote Text -->
              <blockquote class="text-gray-300 leading-relaxed mb-6 italic">
                "{{ testimonial.quote }}"
              </blockquote>
              
              <!-- Author Info -->
              <div class="flex items-center gap-4">
                <UAvatar :src="testimonial.avatar" size="lg" class="ring-2 ring-white/20" />
                <div>
                  <p class="font-semibold text-white">{{ testimonial.name }}</p>
                  <p class="text-sm text-gray-400">{{ testimonial.role }}</p>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>
      
      <!-- CTA Section -->
      <section class="py-24 relative overflow-hidden">
        <div class="absolute inset-0 bg-gradient-to-r from-blue-600/20 via-purple-600/20 to-cyan-600/20"></div>
        <div class="absolute inset-0">
          <div class="absolute top-20 left-20 w-96 h-96 bg-white/5 rounded-full filter blur-3xl animate-pulse"></div>
          <div class="absolute bottom-20 right-20 w-96 h-96 bg-white/5 rounded-full filter blur-3xl animate-pulse" style="animation-delay: 2s;"></div>
        </div>
        
        <div class="container mx-auto px-6 relative z-10">
          <div class="max-w-4xl mx-auto text-center">
            <h2 class="text-4xl md:text-6xl font-black mb-6">
              <span class="bg-gradient-to-r from-white via-blue-200 to-purple-200 bg-clip-text text-transparent">
                지금 바로 시작하세요!
              </span>
            </h2>
            <p class="text-xl text-gray-300 mb-12 max-w-2xl mx-auto leading-relaxed">
              수천 명의 개발자들이 선택한 최고의 클라우드 교육 플랫폼에서
              <span class="text-blue-400 font-semibold">당신의 성공 스토리</span>를 만들어보세요.
            </p>
            
            <div class="flex flex-col sm:flex-row gap-6 justify-center items-center">
              <UButton
                to="/curriculum"
                size="xl"
                class="group bg-gradient-to-r from-blue-500 to-purple-500 hover:from-blue-600 hover:to-purple-600 border-0 px-12 py-6 rounded-2xl shadow-2xl transition-all duration-300 hover:shadow-blue-500/30 hover:scale-110"
              >
                <UIcon name="i-lucide-rocket" class="w-6 h-6 mr-3 group-hover:rotate-12 transition-transform" />
                <span class="text-xl font-bold">무료로 시작하기</span>
              </UButton>
              
              <div class="text-center">
                <p class="text-sm text-gray-400">✨ 7일 무료 체험</p>
                <p class="text-sm text-gray-400">💳 신용카드 없이 가능</p>
              </div>
            </div>
          </div>
        </div>
      </section>

      <!-- Footer -->
      <footer class="relative border-t border-white/10 bg-slate-900/50 backdrop-blur-sm">
        <div class="container mx-auto px-6 py-16">
          <div class="grid grid-cols-1 md:grid-cols-4 gap-8">
            <!-- Brand Column -->
            <div class="md:col-span-1">
              <div class="flex items-center gap-3 mb-6">
                <div class="p-2 bg-gradient-to-br from-blue-400 to-purple-500 rounded-xl">
                  <UIcon name="i-lucide-graduation-cap" class="w-6 h-6 text-white" />
                </div>
                <span class="text-xl font-bold bg-gradient-to-r from-blue-400 to-purple-400 bg-clip-text text-transparent">
                  MCP Cloud Platform
                </span>
              </div>
              <p class="text-gray-400 leading-relaxed mb-6">
                AI 기반 멀티클라우드 관리 플랫폼으로 클라우드 실무력을 강화하세요.
              </p>
              <div class="flex gap-4">
                <a href="#" class="p-2 bg-white/5 hover:bg-white/10 rounded-lg transition-colors">
                  <UIcon name="i-lucide-github" class="w-5 h-5 text-gray-400 hover:text-white" />
                </a>
                <a href="#" class="p-2 bg-white/5 hover:bg-white/10 rounded-lg transition-colors">
                  <UIcon name="i-lucide-twitter" class="w-5 h-5 text-gray-400 hover:text-white" />
                </a>
                <a href="#" class="p-2 bg-white/5 hover:bg-white/10 rounded-lg transition-colors">
                  <UIcon name="i-lucide-linkedin" class="w-5 h-5 text-gray-400 hover:text-white" />
                </a>
              </div>
            </div>
            
            <!-- Courses Column -->
            <div>
              <h4 class="font-semibold text-white mb-6">과정</h4>
              <ul class="space-y-3">
                <li><NuxtLink to="/curriculum?path=cloud_basic" class="text-gray-400 hover:text-white transition-colors">Cloud Basic</NuxtLink></li>
                <li><NuxtLink to="/curriculum?path=cloud_master" class="text-gray-400 hover:text-white transition-colors">Cloud Master</NuxtLink></li>
                <li><NuxtLink to="/curriculum?path=cloud_container" class="text-gray-400 hover:text-white transition-colors">Cloud Container</NuxtLink></li>
              </ul>
            </div>
            
            <!-- Resources Column -->
            <div>
              <h4 class="font-semibold text-white mb-6">리소스</h4>
              <ul class="space-y-3">
                <li><NuxtLink to="/knowledge-base" class="text-gray-400 hover:text-white transition-colors">지식베이스</NuxtLink></li>
                <li><NuxtLink to="/billing" class="text-gray-400 hover:text-white transition-colors">요금제</NuxtLink></li>
                <li><NuxtLink to="/cli" class="text-gray-400 hover:text-white transition-colors">CLI 도구</NuxtLink></li>
              </ul>
            </div>
            
            <!-- Support Column -->
            <div>
              <h4 class="font-semibold text-white mb-6">지원</h4>
              <ul class="space-y-3">
                <li><a href="#" class="text-gray-400 hover:text-white transition-colors">문의하기</a></li>
                <li><a href="#" class="text-gray-400 hover:text-white transition-colors">도움말</a></li>
                <li><a href="#" class="text-gray-400 hover:text-white transition-colors">커뮤니티</a></li>
              </ul>
            </div>
          </div>
          
          <div class="border-t border-white/10 mt-12 pt-8 text-center">
            <p class="text-gray-500">&copy; 2024 MCP Cloud Platform. All rights reserved.</p>
          </div>
        </div>
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
    title: 'AI 기반 맞춤형 학습',
    description: 'AI가 학습자의 수준과 진도를 분석하여 개인화된 학습 경로와 과제를 제공합니다.',
    icon: 'i-lucide-brain-circuit'
  },
  {
    title: '실시간 실습 환경',
    description: '브라우저에서 바로 접근할 수 있는 클라우드 실습 환경으로 실제 프로젝트를 경험할 수 있습니다.',
    icon: 'i-lucide-monitor'
  },
  {
    title: '멀티클라우드 통합 관리',
    description: 'AWS, GCP 등 분산된 클라우드 환경을 단일 대시보드에서 통합 관리하고 최적화합니다.',
    icon: 'i-lucide-cloudy'
  },
  {
    title: '프로젝트 기반 학습',
    description: '실무에서 사용하는 실제 프로젝트를 통해 이론과 실습을 동시에 학습할 수 있습니다.',
    icon: 'i-lucide-folder-open'
  },
  {
    title: '24/7 AI 멘토링',
    description: 'AI 멘토가 24시간 학습자의 질문에 답하고 개인별 맞춤 피드백을 제공합니다.',
    icon: 'i-lucide-message-circle'
  },
  {
    title: '취업 지원 시스템',
    description: '포트폴리오 관리부터 기업 연결까지 체계적인 취업 지원 프로그램을 제공합니다.',
  }
])

// Workflow Steps Data
const workflowSteps = ref([
  {
    title: '개인 맞춤 진단',
    description: 'AI가 현재 실력을 진단하고 최적의 학습 경로를 추천합니다.',
    icon: 'i-lucide-user-search'
  },
  {
    title: '단계별 실습',
    description: '이론 학습 후 즉시 실습으로 이어지는 체계적인 학습 과정을 제공합니다.',
    icon: 'i-lucide-layers'
  },
  {
    title: '포트폴리오 완성',
    description: '학습한 내용을 바탕으로 실무 수준의 포트폴리오를 구축합니다.',
    icon: 'i-lucide-award'
  }
])

// Courses Data
const courses = ref([
  {
    name: 'Cloud Basic',
    duration: '2일 과정',
    icon: 'i-lucide-cloud',
    gradient: 'from-blue-500/20 to-blue-700/20',
    topics: [
      'AWS/GCP 기초 서비스',
      'IAM 사용자 및 권한 관리',
      'EC2/Compute Engine 인스턴스',
      'S3/Cloud Storage 버킷 관리',
      '기본 네트워킹 개념'
    ],
    link: '/curriculum?path=cloud_basic'
  },
  {
    name: 'Cloud Master',
    duration: '3일 과정',
    icon: 'i-lucide-graduation-cap',
    gradient: 'from-purple-500/20 to-purple-700/20',
    topics: [
      'Docker 컨테이너 기술',
      'Git/GitHub 버전 관리',
      'GitHub Actions CI/CD',
      'VM 기반 웹 애플리케이션 배포',
      '모니터링 및 로깅'
    ],
    link: '/curriculum?path=cloud_master'
  },
  {
    name: 'Cloud Container',
    duration: '2일 과정',
    icon: 'i-lucide-container',
    gradient: 'from-green-500/20 to-green-700/20',
    topics: [
      'Kubernetes 클러스터 아키텍처',
      'GKE 클러스터 관리',
      'ECS/Fargate 서버리스 컨테이너',
      '고가용성 아키텍처 설계',
      '마이크로서비스 패턴'
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
    quote: 'AI를 이용한 인프라 관리가 이렇게 강력할 줄 몰랐습니다. 반복적인 배포 작업이 줄어들어 핵심 업무에 더 집중할 수 있게 됐습니다.',
    avatar: 'https://i.pravatar.cc/150?u=a042581f4e29026705d'
  },
  {
    name: '박지훈',
    role: '프로덕트 매니저, 핀테크',
    quote: '개발팀과의 커뮤니케이션에 큰 도움이 됐습니다. 클라우드 아키텍처에 대한 이해도가 높아져 더 효율적인 기획이 가능해졌습니다.',
    avatar: 'https://i.pravatar.cc/150?u=a042581f4e29026706d'
  }
])

</script>

<style scoped>
@import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800;900&display=swap');

/* Custom Animations */
@keyframes gradient-x {
  0%, 100% {
    background-size: 200% 200%;
    background-position: left center;
  }
  50% {
    background-size: 200% 200%;
    background-position: right center;
  }
}

@keyframes float {
  0%, 100% { transform: translateY(0px) rotate(0deg); }
  50% { transform: translateY(-20px) rotate(3deg); }
}

@keyframes float-delayed {
  0%, 100% { transform: translateY(0px) rotate(0deg); }
  50% { transform: translateY(-15px) rotate(-2deg); }
}

@keyframes float-slow {
  0%, 100% { transform: translateY(0px) rotate(0deg); }
  50% { transform: translateY(-10px) rotate(1deg); }
}

.animate-gradient-x {
  animation: gradient-x 6s ease infinite;
  background-size: 200% 200%;
}

.animate-float {
  animation: float 6s ease-in-out infinite;
}

.animate-float-delayed {
  animation: float-delayed 8s ease-in-out infinite;
}

.animate-float-slow {
  animation: float-slow 10s ease-in-out infinite;
}

/* Smooth scrolling */
html {
  scroll-behavior: smooth;
}

/* Glass morphism effects */
.backdrop-blur-xl {
  backdrop-filter: blur(16px);
}

/* Custom hover effects */
.hover-lift {
  transition: transform 0.3s ease, box-shadow 0.3s ease;
}

.hover-lift:hover {
  transform: translateY(-8px);
  box-shadow: 0 20px 40px rgba(0, 0, 0, 0.3);
}

/* Button glow effects */
.btn-glow {
  position: relative;
  overflow: hidden;
}

.btn-glow::before {
  content: '';
  position: absolute;
  top: 0;
  left: -100%;
  width: 100%;
  height: 100%;
  background: linear-gradient(90deg, transparent, rgba(255,255,255,0.2), transparent);
  transition: left 0.5s;
}

.btn-glow:hover::before {
  left: 100%;
}
</style>