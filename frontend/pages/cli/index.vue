<template>
  <div class="px-4 sm:px-6 lg:px-8">
    <div class="mb-8">
      <h1 class="text-3xl font-bold text-gray-900">CLI 읽기 전용 실행</h1>
      <p class="mt-2 text-gray-600">
        안전한 읽기 전용 CLI 명령을 실행하여 클라우드 리소스 정보를 조회하세요.
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
              <option value="gcp">Google Cloud Platform</option>
            </select>
          </div>

          <!-- 명령어 선택 -->
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">
              실행할 명령어
            </label>
            <select
              v-model="command"
              class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-transparent"
              :disabled="!provider"
              required
            >
              <option value="">명령어를 선택하세요</option>
              <option
                v-for="cmd in availableCommands"
                :key="cmd.value"
                :value="cmd.value"
              >
                {{ cmd.label }} ({{ cmd.description }})
              </option>
            </select>
          </div>

          <!-- 인수 입력 -->
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">
              명령어 인수 (JSON 형식)
            </label>
            <textarea
              v-model="args"
              rows="4"
              placeholder='예: {"region": "us-east-1", "bucket": "my-bucket"}'
              class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-transparent font-mono text-sm"
            ></textarea>
            <p class="mt-1 text-xs text-gray-500">
              JSON 형식으로 명령어 인수를 입력하세요. 인수가 필요하지 않으면 비워두세요.
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
                실행 중...
              </span>
              <span v-else>명령어 실행</span>
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

        <!-- 실행 결과 -->
        <div v-if="output" class="mt-6">
          <h3 class="text-lg font-medium text-gray-900 mb-3">실행 결과</h3>
          <div class="bg-gray-50 rounded-md p-4">
            <pre class="text-sm text-gray-800 overflow-x-auto whitespace-pre-wrap">{{ output }}</pre>
          </div>
        </div>
      </div>

      <!-- 보안 정보 -->
      <div class="mt-8 bg-green-50 rounded-lg p-6">
        <h3 class="text-lg font-medium text-green-900 mb-3">🔒 보안 정보</h3>
        <div class="space-y-2 text-sm text-green-800">
          <p>• <strong>읽기 전용:</strong> 모든 CLI 명령은 읽기 전용으로만 실행됩니다.</p>
          <p>• <strong>화이트리스트:</strong> 미리 승인된 안전한 명령어만 실행 가능합니다.</p>
          <p>• <strong>감사 로그:</strong> 모든 명령어 실행은 로그에 기록됩니다.</p>
          <p>• <strong>권한 제한:</strong> 인프라 변경을 위한 명령어는 Terraform을 통해 실행하세요.</p>
        </div>
      </div>

      <!-- 지원 명령어 목록 -->
      <div class="mt-8 bg-blue-50 rounded-lg p-6">
        <h3 class="text-lg font-medium text-blue-900 mb-3">📋 지원 명령어 목록</h3>
        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
          <div>
            <h4 class="font-medium text-blue-800 mb-2">AWS</h4>
            <ul class="space-y-1 text-sm text-blue-700">
              <li>• s3_ls - S3 버킷 목록 조회</li>
              <li>• ec2_describe_instances - EC2 인스턴스 정보 조회</li>
              <li>• iam_list_users - IAM 사용자 목록 조회</li>
              <li>• vpc_describe_vpcs - VPC 정보 조회</li>
            </ul>
          </div>
          <div>
            <h4 class="font-medium text-blue-800 mb-2">GCP</h4>
            <ul class="space-y-1 text-sm text-blue-700">
              <li>• gcloud_zones_list - 컴퓨팅 영역 목록 조회</li>
              <li>• gcloud_projects_list - 프로젝트 목록 조회</li>
              <li>• gcloud_storage_buckets_list - 스토리지 버킷 목록 조회</li>
              <li>• gcloud_compute_instances_list - 컴퓨팅 인스턴스 목록 조회</li>
            </ul>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
definePageMeta({
  title: 'CLI 실행'
})

const provider = ref('')
const command = ref('')
const args = ref('')
const output = ref('')
const error = ref('')
const loading = ref(false)

// 프로바이더별 사용 가능한 명령어
const commandOptions = {
  aws: [
    { value: 's3_ls', label: 'S3 버킷 목록 조회', description: 'aws s3 ls' },
    { value: 'ec2_describe_instances', label: 'EC2 인스턴스 정보 조회', description: 'aws ec2 describe-instances' },
    { value: 'iam_list_users', label: 'IAM 사용자 목록 조회', description: 'aws iam list-users' },
    { value: 'vpc_describe_vpcs', label: 'VPC 정보 조회', description: 'aws ec2 describe-vpcs' }
  ],
  gcp: [
    { value: 'gcloud_zones_list', label: '컴퓨팅 영역 목록 조회', description: 'gcloud compute zones list' },
    { value: 'gcloud_projects_list', label: '프로젝트 목록 조회', description: 'gcloud projects list' },
    { value: 'gcloud_storage_buckets_list', label: '스토리지 버킷 목록 조회', description: 'gcloud storage buckets list' },
    { value: 'gcloud_compute_instances_list', label: '컴퓨팅 인스턴스 목록 조회', description: 'gcloud compute instances list' }
  ]
}

const availableCommands = computed(() => {
  return provider.value ? (commandOptions[provider.value] || []) : []
})

const isFormValid = computed(() => {
  return provider.value && command.value
})

const onProviderChange = () => {
  command.value = ''
  output.value = ''
  error.value = ''
}

const handleSubmit = async () => {
  if (!isFormValid.value) return

  loading.value = true
  error.value = ''
  output.value = ''

  try {
    // JSON 파싱 검증 (인수가 있는 경우)
    let parsedArgs = {}
    if (args.value.trim()) {
      try {
        parsedArgs = JSON.parse(args.value)
      } catch (err) {
        throw new Error('JSON 형식이 올바르지 않습니다. 인수를 확인해주세요.')
      }
    }

    const response = await $fetch('/api/v1/cli/read-only', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-API-Key': 'my_mcp_eagle_tiger'
      },
      body: {
        provider: provider.value,
        command_name: command.value,
        args: parsedArgs
      }
    })

    if (response.success) {
      output.value = response.stdout || '명령어가 성공적으로 실행되었습니다.'
    } else {
      error.value = response.stderr || '명령어 실행 중 오류가 발생했습니다.'
    }
  } catch (err) {
    error.value = err.message || 'CLI 명령어 실행 중 오류가 발생했습니다.'
    console.error('Error executing CLI command:', err)
  } finally {
    loading.value = false
  }
}
</script>
