<template>
  <div class="min-h-screen bg-gray-50 py-8">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
      <!-- 헤더 -->
      <div class="mb-8">
        <h1 class="text-3xl font-bold text-gray-900">AI 클라우드 어시스턴트</h1>
        <p class="mt-2 text-gray-600">
          AWS와 GCP 클라우드 인프라 설계, 비용 분석, 보안 감사를 AI와 함께 수행하세요
        </p>
      </div>

      <!-- 탭 네비게이션 -->
      <div class="mb-6">
        <nav class="flex space-x-8">
          <button
            v-for="tab in tabs"
            :key="tab.id"
            @click="activeTab = tab.id"
            :class="[
              activeTab === tab.id
                ? 'border-blue-500 text-blue-600'
                : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300',
              'whitespace-nowrap py-2 px-1 border-b-2 font-medium text-sm'
            ]"
          >
            {{ tab.name }}
          </button>
        </nav>
      </div>

      <!-- AI 어시스턴트 채팅 -->
      <div v-if="activeTab === 'chat'" class="bg-white rounded-lg shadow">
        <div class="p-6">
          <h2 class="text-lg font-medium text-gray-900 mb-4">클라우드 전문가와 대화하기</h2>
          
          <!-- 채팅 메시지 영역 -->
          <div class="bg-gray-50 rounded-lg p-4 h-96 overflow-y-auto mb-4">
            <div v-for="message in chatMessages" :key="message.id" class="mb-4">
              <div :class="message.role === 'user' ? 'text-right' : 'text-left'">
                <div
                  :class="[
                    message.role === 'user'
                      ? 'bg-blue-500 text-white ml-auto'
                      : 'bg-white text-gray-900',
                    'inline-block rounded-lg px-4 py-2 max-w-xs lg:max-w-md shadow-sm'
                  ]"
                >
                  <p class="text-sm">{{ message.content }}</p>
                </div>
              </div>
            </div>
            
            <!-- 로딩 인디케이터 -->
            <div v-if="isLoading" class="text-left">
              <div class="bg-white text-gray-900 inline-block rounded-lg px-4 py-2 shadow-sm">
                <div class="flex items-center space-x-2">
                  <div class="animate-spin rounded-full h-4 w-4 border-b-2 border-blue-500"></div>
                  <span class="text-sm">AI가 답변을 생성하고 있습니다...</span>
                </div>
              </div>
            </div>
          </div>

          <!-- 입력 폼 -->
          <div class="flex space-x-2">
            <input
              v-model="chatInput"
              @keyup.enter="sendMessage"
              type="text"
              placeholder="클라우드 관련 질문을 입력하세요..."
              class="flex-1 rounded-lg border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
            />
            <button
              @click="sendMessage"
              :disabled="!chatInput.trim() || isLoading"
              class="px-4 py-2 bg-blue-500 text-white rounded-lg hover:bg-blue-600 disabled:opacity-50 disabled:cursor-not-allowed"
            >
              전송
            </button>
          </div>
        </div>
      </div>

      <!-- Terraform 코드 생성 -->
      <div v-if="activeTab === 'terraform'" class="bg-white rounded-lg shadow">
        <div class="p-6">
          <h2 class="text-lg font-medium text-gray-900 mb-4">Terraform 코드 생성</h2>
          
          <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
            <!-- 입력 폼 -->
            <div>
              <div class="mb-4">
                <label class="block text-sm font-medium text-gray-700 mb-2">클라우드 제공자</label>
                <select v-model="terraformForm.cloudProvider" class="w-full rounded-lg border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500">
                  <option value="aws">AWS</option>
                  <option value="gcp">GCP</option>
                </select>
              </div>
              
              <div class="mb-4">
                <label class="block text-sm font-medium text-gray-700 mb-2">인프라 요구사항</label>
                <textarea
                  v-model="terraformForm.requirements"
                  rows="6"
                  placeholder="예: 3개의 가용영역에 걸친 고가용성 VPC를 생성하고, 각 가용영역에 public과 private 서브넷을 만들고, NAT Gateway를 설정해주세요."
                  class="w-full rounded-lg border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
                ></textarea>
              </div>
              
              <button
                @click="generateTerraformCode"
                :disabled="!terraformForm.requirements.trim() || isGenerating"
                class="w-full px-4 py-2 bg-green-500 text-white rounded-lg hover:bg-green-600 disabled:opacity-50 disabled:cursor-not-allowed"
              >
                <span v-if="isGenerating">생성 중...</span>
                <span v-else>코드 생성</span>
              </button>
            </div>

            <!-- 결과 표시 -->
            <div>
              <div v-if="terraformResult" class="space-y-4">
                <div class="bg-gray-50 rounded-lg p-4">
                  <h3 class="font-medium text-gray-900 mb-2">생성된 코드</h3>
                  <div class="space-y-3">
                    <div>
                      <h4 class="text-sm font-medium text-gray-700">main.tf</h4>
                      <pre class="text-xs bg-gray-800 text-green-400 p-2 rounded overflow-x-auto">{{ terraformResult.main_tf }}</pre>
                    </div>
                    <div>
                      <h4 class="text-sm font-medium text-gray-700">variables.tf</h4>
                      <pre class="text-xs bg-gray-800 text-green-400 p-2 rounded overflow-x-auto">{{ terraformResult.variables_tf }}</pre>
                    </div>
                    <div>
                      <h4 class="text-sm font-medium text-gray-700">outputs.tf</h4>
                      <pre class="text-xs bg-gray-800 text-green-400 p-2 rounded overflow-x-auto">{{ terraformResult.outputs_tf }}</pre>
                    </div>
                  </div>
                </div>
                
                <div class="bg-blue-50 rounded-lg p-4">
                  <h3 class="font-medium text-blue-900 mb-2">추가 정보</h3>
                  <div class="text-sm text-blue-800 space-y-2">
                    <p><strong>설명:</strong> {{ terraformResult.description }}</p>
                    <p><strong>예상 비용:</strong> {{ terraformResult.estimated_cost }}</p>
                    <p><strong>보안 주의사항:</strong> {{ terraformResult.security_notes }}</p>
                    <p><strong>모범 사례:</strong> {{ terraformResult.best_practices }}</p>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- 비용 분석 -->
      <div v-if="activeTab === 'cost'" class="bg-white rounded-lg shadow">
        <div class="p-6">
          <h2 class="text-lg font-medium text-gray-900 mb-4">인프라 비용 분석</h2>
          
          <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
            <!-- 입력 폼 -->
            <div>
              <div class="mb-4">
                <label class="block text-sm font-medium text-gray-700 mb-2">클라우드 제공자</label>
                <select v-model="costForm.cloudProvider" class="w-full rounded-lg border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500">
                  <option value="aws">AWS</option>
                  <option value="gcp">GCP</option>
                </select>
              </div>
              
              <div class="mb-4">
                <label class="block text-sm font-medium text-gray-700 mb-2">인프라 설명</label>
                <textarea
                  v-model="costForm.infrastructureDescription"
                  rows="6"
                  placeholder="예: 3개의 가용영역에 걸친 VPC, 각 가용영역에 public/private 서브넷, NAT Gateway, 3개의 t3.medium EC2 인스턴스, RDS MySQL 인스턴스"
                  class="w-full rounded-lg border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
                ></textarea>
              </div>
              
              <button
                @click="analyzeCost"
                :disabled="!costForm.infrastructureDescription.trim() || isAnalyzing"
                class="w-full px-4 py-2 bg-purple-500 text-white rounded-lg hover:bg-purple-600 disabled:opacity-50 disabled:cursor-not-allowed"
              >
                <span v-if="isAnalyzing">분석 중...</span>
                <span v-else>비용 분석</span>
              </button>
            </div>

            <!-- 결과 표시 -->
            <div>
              <div v-if="costResult" class="space-y-4">
                <div class="bg-purple-50 rounded-lg p-4">
                  <h3 class="font-medium text-purple-900 mb-2">비용 분석 결과</h3>
                  <div class="text-sm text-purple-800 space-y-2">
                    <p><strong>예상 월 비용:</strong> {{ costResult.estimated_monthly_cost }}</p>
                    <div v-if="costResult.cost_breakdown">
                      <p class="font-medium">비용 세부사항:</p>
                      <ul class="ml-4 space-y-1">
                        <li>컴퓨팅: {{ costResult.cost_breakdown.compute }}</li>
                        <li>스토리지: {{ costResult.cost_breakdown.storage }}</li>
                        <li>네트워크: {{ costResult.cost_breakdown.network }}</li>
                        <li>기타: {{ costResult.cost_breakdown.other }}</li>
                      </ul>
                    </div>
                  </div>
                </div>
                
                <div class="bg-green-50 rounded-lg p-4">
                  <h3 class="font-medium text-green-900 mb-2">최적화 기회</h3>
                  <div class="text-sm text-green-800">
                    <ul class="space-y-1">
                      <li v-for="opportunity in costResult.optimization_opportunities" :key="opportunity" class="flex items-start">
                        <span class="text-green-500 mr-2">•</span>
                        {{ opportunity }}
                      </li>
                    </ul>
                  </div>
                </div>
                
                <div class="bg-blue-50 rounded-lg p-4">
                  <h3 class="font-medium text-blue-900 mb-2">권장사항</h3>
                  <div class="text-sm text-blue-800 space-y-2">
                    <div v-if="costResult.reserved_instances">
                      <p class="font-medium">예약 인스턴스:</p>
                      <ul class="ml-4 space-y-1">
                        <li v-for="rec in costResult.reserved_instances" :key="rec" class="flex items-start">
                          <span class="text-blue-500 mr-2">•</span>
                          {{ rec }}
                        </li>
                      </ul>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- 보안 감사 -->
      <div v-if="activeTab === 'security'" class="bg-white rounded-lg shadow">
        <div class="p-6">
          <h2 class="text-lg font-medium text-gray-900 mb-4">인프라 보안 감사</h2>
          
          <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
            <!-- 입력 폼 -->
            <div>
              <div class="mb-4">
                <label class="block text-sm font-medium text-gray-700 mb-2">클라우드 제공자</label>
                <select v-model="securityForm.cloudProvider" class="w-full rounded-lg border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500">
                  <option value="aws">AWS</option>
                  <option value="gcp">GCP</option>
                </select>
              </div>
              
              <div class="mb-4">
                <label class="block text-sm font-medium text-gray-700 mb-2">인프라 설명</label>
                <textarea
                  v-model="securityForm.infrastructureDescription"
                  rows="6"
                  placeholder="예: 3개의 가용영역에 걸친 VPC, 각 가용영역에 public/private 서브넷, NAT Gateway, 3개의 t3.medium EC2 인스턴스, RDS MySQL 인스턴스"
                  class="w-full rounded-lg border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
                ></textarea>
              </div>
              
              <button
                @click="auditSecurity"
                :disabled="!securityForm.infrastructureDescription.trim() || isAuditing"
                class="w-full px-4 py-2 bg-red-500 text-white rounded-lg hover:bg-red-600 disabled:opacity-50 disabled:cursor-not-allowed"
              >
                <span v-if="isAuditing">감사 중...</span>
                <span v-else>보안 감사</span>
              </button>
            </div>

            <!-- 결과 표시 -->
            <div>
              <div v-if="securityResult" class="space-y-4">
                <div class="bg-red-50 rounded-lg p-4">
                  <h3 class="font-medium text-red-900 mb-2">보안 점수</h3>
                  <div class="text-center">
                    <div class="text-3xl font-bold text-red-600">{{ securityResult.security_score }}/100</div>
                    <div class="text-sm text-red-700 mt-1">
                      {{ getSecurityScoreLabel(securityResult.security_score) }}
                    </div>
                  </div>
                </div>
                
                <div v-if="securityResult.critical_issues && securityResult.critical_issues.length > 0" class="bg-red-100 rounded-lg p-4">
                  <h3 class="font-medium text-red-900 mb-2">치명적 보안 이슈</h3>
                  <ul class="text-sm text-red-800 space-y-1">
                    <li v-for="issue in securityResult.critical_issues" :key="issue" class="flex items-start">
                      <span class="text-red-500 mr-2">⚠️</span>
                      {{ issue }}
                    </li>
                  </ul>
                </div>
                
                <div v-if="securityResult.high_risk_issues && securityResult.high_risk_issues.length > 0" class="bg-orange-100 rounded-lg p-4">
                  <h3 class="font-medium text-orange-900 mb-2">높은 위험도 이슈</h3>
                  <ul class="text-sm text-orange-800 space-y-1">
                    <li v-for="issue in securityResult.high_risk_issues" :key="issue" class="flex items-start">
                      <span class="text-orange-500 mr-2">⚠️</span>
                      {{ issue }}
                    </li>
                  </ul>
                </div>
                
                <div class="bg-blue-50 rounded-lg p-4">
                  <h3 class="font-medium text-blue-900 mb-2">보안 권장사항</h3>
                  <div class="text-sm text-blue-800">
                    <ul class="space-y-1">
                      <li v-for="rec in securityResult.security_recommendations" :key="rec" class="flex items-start">
                        <span class="text-blue-500 mr-2">•</span>
                        {{ rec }}
                      </li>
                    </ul>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive } from 'vue'

// 탭 관리
const activeTab = ref('chat')
const tabs = [
  { id: 'chat', name: 'AI 어시스턴트' },
  { id: 'terraform', name: 'Terraform 생성' },
  { id: 'cost', name: '비용 분석' },
  { id: 'security', name: '보안 감사' }
]

// 채팅 관련 상태
const chatMessages = ref([])
const chatInput = ref('')
const isLoading = ref(false)

// Terraform 코드 생성 관련 상태
const terraformForm = reactive({
  cloudProvider: 'aws',
  requirements: ''
})
const terraformResult = ref(null)
const isGenerating = ref(false)

// 비용 분석 관련 상태
const costForm = reactive({
  cloudProvider: 'aws',
  infrastructureDescription: ''
})
const costResult = ref(null)
const isAnalyzing = ref(false)

// 보안 감사 관련 상태
const securityForm = reactive({
  cloudProvider: 'aws',
  infrastructureDescription: ''
})
const securityResult = ref(null)
const isAuditing = ref(false)

// API 키 설정
const API_KEY = process.env.MCP_API_KEY || 'my_mcp_eagle_tiger'

// Nuxt 런타임 설정을 사용하여 API 기본 URL 가져오기
const config = useRuntimeConfig()
const API_BASE_URL = config.public.apiBaseUrl

// 메시지 전송
const sendMessage = async () => {
  if (!chatInput.value.trim() || isLoading.value) return
  
  const userMessage = {
    id: Date.now(),
    role: 'user',
    content: chatInput.value
  }
  
  chatMessages.value.push(userMessage)
  const question = chatInput.value
  chatInput.value = ''
  isLoading.value = true
  
  try {
    const response = await fetch(`${API_BASE_URL}/ai/assistant/query-sync`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-API-Key': API_KEY
      },
      body: JSON.stringify({ question })
    })
    
    const data = await response.json()
    
    if (data.success) {
      const aiMessage = {
        id: Date.now() + 1,
        role: 'assistant',
        content: data.answer
      }
      chatMessages.value.push(aiMessage)
    } else {
      const errorMessage = {
        id: Date.now() + 1,
        role: 'assistant',
        content: `오류가 발생했습니다: ${data.error}`
      }
      chatMessages.value.push(errorMessage)
    }
  } catch (error) {
    const errorMessage = {
      id: Date.now() + 1,
      role: 'assistant',
      content: `네트워크 오류가 발생했습니다: ${error.message}`
    }
    chatMessages.value.push(errorMessage)
  } finally {
    isLoading.value = false
  }
}

// Terraform 코드 생성
const generateTerraformCode = async () => {
  if (!terraformForm.requirements.trim() || isGenerating.value) return
  
  isGenerating.value = true
  
  try {
    const response = await fetch(`${API_BASE_URL}/ai/terraform/generate`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-API-Key': API_KEY
      },
      body: JSON.stringify({
        requirements: terraformForm.requirements,
        cloud_provider: terraformForm.cloudProvider
      })
    })
    
    const data = await response.json()
    
    if (data.success) {
      terraformResult.value = data.result
    } else {
      alert(`오류가 발생했습니다: ${data.error}`)
    }
  } catch (error) {
    alert(`네트워크 오류가 발생했습니다: ${error.message}`)
  } finally {
    isGenerating.value = false
  }
}

// 비용 분석
const analyzeCost = async () => {
  if (!costForm.infrastructureDescription.trim() || isAnalyzing.value) return
  
  isAnalyzing.value = true
  
  try {
    const response = await fetch(`${API_BASE_URL}/ai/cost/analyze`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-API-Key': API_KEY
      },
      body: JSON.stringify({
        infrastructure_description: costForm.infrastructureDescription,
        cloud_provider: costForm.cloudProvider
      })
    })
    
    const data = await response.json()
    
    if (data.success) {
      costResult.value = data.result
    } else {
      alert(`오류가 발생했습니다: ${data.error}`)
    }
  } catch (error) {
    alert(`네트워크 오류가 발생했습니다: ${error.message}`)
  } finally {
    isAnalyzing.value = false
  }
}

// 보안 감사
const auditSecurity = async () => {
  if (!securityForm.infrastructureDescription.trim() || isAuditing.value) return
  
  isAuditing.value = true
  
  try {
    const response = await fetch(`${API_BASE_URL}/ai/security/audit`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-API-Key': API_KEY
      },
      body: JSON.stringify({
        infrastructure_description: securityForm.infrastructureDescription,
        cloud_provider: securityForm.cloudProvider
      })
    })
    
    const data = await response.json()
    
    if (data.success) {
      securityResult.value = data.result
    } else {
      alert(`오류가 발생했습니다: ${data.error}`)
    }
  } catch (error) {
    alert(`네트워크 오류가 발생했습니다: ${error.message}`)
  } finally {
    isAuditing.value = false
  }
}

// 보안 점수 라벨
const getSecurityScoreLabel = (score) => {
  if (score >= 90) return '매우 안전'
  if (score >= 80) return '안전'
  if (score >= 70) return '보통'
  if (score >= 60) return '주의 필요'
  return '위험'
}

// 초기 메시지
chatMessages.value.push({
  id: 1,
  role: 'assistant',
  content: '안녕하세요! AWS와 GCP 클라우드 전문가입니다. 어떤 도움이 필요하신가요?'
})
</script>

<style scoped>
/* 추가 스타일링 */
</style>
