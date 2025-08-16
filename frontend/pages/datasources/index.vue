<template>
  <div class="px-4 sm:px-6 lg:px-8">
    <div class="mb-8">
      <h1 class="text-3xl font-bold text-gray-900">Terraform 데이터소스 쿼리</h1>
      <p class="mt-2 text-gray-600">
        AWS, GCP, Azure의 클라우드 리소스 정보를 Terraform 데이터소스로 조회하세요.
      </p>
    </div>

    <div class="max-w-4xl mx-auto">
      <div class="bg-white rounded-lg shadow p-6">
        <form @submit.prevent="handleSubmit" class="space-y-6">
          <!-- Provider 선택 -->
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">
              클라우드 프로바이더
            </label>
            <select
              v-model="provider"
              @change="onProviderChange"
              class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-transparent"
              required
            >
              <option value="">프로바이더를 선택하세요</option>
              <option value="aws">AWS</option>
              <option value="google">Google Cloud Platform</option>
              <option value="azurerm">Microsoft Azure</option>
            </select>
          </div>

          <!-- Data Type 선택 -->
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">
              데이터 타입
            </label>
            <select
              v-model="dataType"
              class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-transparent"
              :disabled="!provider"
              required
            >
              <option value="">데이터 타입을 선택하세요</option>
              <option
                v-for="type in availableDataTypes"
                :key="type"
                :value="type"
              >
                {{ type }}
              </option>
            </select>
          </div>

          <!-- Data Name 입력 -->
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">
              데이터 이름
            </label>
            <input
              v-model="dataName"
              type="text"
              placeholder="예: current, default, this"
              class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-transparent"
              required
            />
          </div>

          <!-- Config JSON 입력 -->
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">
              설정 (JSON)
            </label>
            <textarea
              v-model="config"
              rows="5"
              placeholder='예: {"most_recent": true, "owners": ["amazon"]}'
              class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-transparent font-mono text-sm"
            ></textarea>
            <p class="mt-1 text-xs text-gray-500">
              JSON 형식으로 설정을 입력하세요. 빈 객체 {}도 가능합니다.
            </p>
          </div>

          <!-- 제출 버튼 -->
          <div>
            <button
              type="submit"
              :disabled="!isFormValid || loading"
              class="w-full px-6 py-3 bg-primary-600 text-white font-medium rounded-md hover:bg-primary-700 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
            >
              <span v-if="loading" class="flex items-center justify-center">
                <svg class="animate-spin -ml-1 mr-3 h-5 w-5 text-white" fill="none" viewBox="0 0 24 24">
                  <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                  <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                </svg>
                쿼리 중...
              </span>
              <span v-else>데이터소스 쿼리</span>
            </button>
          </div>
        </form>

        <!-- 에러 메시지 -->
        <div v-if="error" class="mt-6 p-4 bg-red-50 border border-red-200 rounded-md">
          <div class="flex">
            <svg class="h-5 w-5 text-red-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
            </svg>
            <div class="ml-3">
              <h3 class="text-sm font-medium text-red-800">오류 발생</h3>
              <div class="mt-2 text-sm text-red-700">
                {{ error }}
              </div>
            </div>
          </div>
        </div>

        <!-- 결과 표시 -->
        <div v-if="result" class="mt-6">
          <h3 class="text-lg font-medium text-gray-900 mb-3">쿼리 결과</h3>
          <div class="bg-gray-50 rounded-md p-4">
            <pre class="text-sm text-gray-800 overflow-x-auto">{{ JSON.stringify(result, null, 2) }}</pre>
          </div>
        </div>
      </div>

      <!-- 도움말 섹션 -->
      <div class="mt-8 bg-blue-50 rounded-lg p-6">
        <h3 class="text-lg font-medium text-blue-900 mb-3">💡 사용 팁</h3>
        <div class="space-y-2 text-sm text-blue-800">
          <p>• <strong>AWS AMI 조회:</strong> Provider: aws, Data Type: aws_ami, Config: {"most_recent": true, "owners": ["amazon"]}</p>
          <p>• <strong>GCP 영역 조회:</strong> Provider: google, Data Type: google_compute_zones, Config: {"project": "your-project-id"}</p>
          <p>• <strong>Azure 구독 정보:</strong> Provider: azurerm, Data Type: azurerm_subscription, Config: {}</p>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
definePageMeta({
  title: '데이터소스 쿼리'
})

const provider = ref('')
const dataType = ref('')
const dataName = ref('')
const config = ref('{}')
const result = ref(null)
const error = ref('')
const loading = ref(false)

// 프로바이더별 데이터 타입 옵션
const dataTypeOptions = {
  aws: [
    'aws_caller_identity',
    'aws_iam_policy_document',
    'aws_region',
    'aws_ami',
    'aws_vpc',
    'aws_subnet',
    'aws_security_group'
  ],
  google: [
    'google_project',
    'google_storage_bucket',
    'google_service_account',
    'google_client_openid_userinfo',
    'google_compute_zones',
    'google_compute_regions'
  ],
  azurerm: [
    'azurerm_client_config',
    'azurerm_subscription',
    'azurerm_resource_group',
    'azurerm_virtual_network'
  ]
}

const availableDataTypes = computed(() => {
  return provider.value ? (dataTypeOptions[provider.value] || []) : []
})

const isFormValid = computed(() => {
  return provider.value && dataType.value && dataName.value.trim()
})

const onProviderChange = () => {
  dataType.value = ''
  result.value = null
  error.value = ''
}

const handleSubmit = async () => {
  if (!isFormValid.value) return

  loading.value = true
  error.value = ''
  result.value = null

  try {
    // JSON 파싱 검증
    const parsedConfig = JSON.parse(config.value)

    const response = await $fetch('/api/v1/data-sources/query', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-API-Key': 'my_mcp_eagle_tiger'
      },
      body: {
        provider: provider.value,
        data_type: dataType.value,
        data_name: dataName.value,
        config: parsedConfig
      }
    })

    if (response.success) {
      result.value = response.output
    } else {
      error.value = response.error || '알 수 없는 오류가 발생했습니다.'
    }
  } catch (err) {
    if (err.name === 'SyntaxError') {
      error.value = 'JSON 형식이 올바르지 않습니다. 설정을 확인해주세요.'
    } else {
      error.value = err.message || '데이터소스 쿼리 중 오류가 발생했습니다.'
    }
    console.error('Error fetching data source:', err)
  } finally {
    loading.value = false
  }
}
</script>
