<template>
  <div class="p-4 sm:p-6 lg:p-8">
    <div class="max-w-4xl mx-auto">
      <h1 class="text-2xl font-bold text-gray-900 mb-2">내 프로필</h1>
      <p class="mb-6 text-sm text-gray-600">사용자 유형: <span class="font-semibold" :class="roleLabelClass">{{ roleLabel }}</span></p>

      <!-- Gemini API Key Section -->
      <div class="bg-white shadow-md rounded-lg p-6 mb-6">
        <h2 class="text-lg font-semibold text-gray-800 mb-4">Gemini API 키 설정</h2>
        <p class="text-sm text-gray-600 mb-4">AI 채팅 기능을 사용하려면 Google Gemini API 키가 필요합니다.</p>
        
        <div class="space-y-4">
          <div>
            <label for="geminiApiKey" class="block text-sm font-medium text-gray-700">Gemini API 키</label>
            <div class="mt-1 flex rounded-md shadow-sm">
              <input 
                type="password" 
                id="geminiApiKey" 
                v-model="profileData.gemini_api_key" 
                @input="onApiKeyInput"
                :class="[
                  'flex-1 min-w-0 block w-full px-3 py-2 border rounded-l-md focus:outline-none focus:ring-2 focus:ring-offset-0',
                  apiKeyValidation.isValid ? 'border-green-300 focus:ring-green-500 focus:border-green-500' : 
                  apiKeyValidation.message && !apiKeyValidation.isValid ? 'border-red-300 focus:ring-red-500 focus:border-red-500' :
                  'border-gray-300 focus:ring-indigo-500 focus:border-indigo-500'
                ]"
                placeholder="AIzaSy..."
              />
              <button 
                @click="toggleApiKeyVisibility" 
                type="button" 
                class="inline-flex items-center px-3 py-2 border border-l-0 border-gray-300 rounded-r-md bg-gray-50 text-gray-500 hover:bg-gray-100"
              >
                {{ showApiKey ? '숨기기' : '보기' }}
              </button>
            </div>
            
            <!-- 유효성 검사 메시지 -->
            <div v-if="apiKeyValidation.message" class="mt-2">
              <div v-if="apiKeyValidation.isValid" class="flex items-center text-sm text-green-600">
                <svg class="w-4 h-4 mr-1" fill="currentColor" viewBox="0 0 20 20">
                  <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd"/>
                </svg>
                {{ apiKeyValidation.message }}
              </div>
              <div v-else class="flex items-center text-sm text-red-600">
                <svg class="w-4 h-4 mr-1" fill="currentColor" viewBox="0 0 20 20">
                  <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z" clip-rule="evenodd"/>
                </svg>
                {{ apiKeyValidation.message }}
              </div>
            </div>
            
            <p class="text-xs text-gray-500 mt-1">
              <a href="https://makersuite.google.com/app/apikey" target="_blank" class="text-indigo-600 hover:text-indigo-500">
                Google AI Studio에서 API 키 발급받기
              </a>
            </p>
          </div>
          
          <div class="flex justify-end">
            <button 
              @click="updateProfile" 
              :disabled="isUpdating || (!!profileData.gemini_api_key && !apiKeyValidation.isValid)"
              class="px-4 py-2 bg-indigo-600 text-white rounded-md hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500 disabled:opacity-50"
            >
              {{ isUpdating ? '저장 중...' : '저장' }}
            </button>
          </div>
        </div>
      </div>

      <!-- API Keys Section -->
      <div class="bg-white shadow-md rounded-lg p-6">
        <div class="flex justify-between items-center mb-4">
          <h2 class="text-lg font-semibold text-gray-800">API 키 관리</h2>
          <button @click="showAddKeyModal = true" class="px-4 py-2 bg-indigo-600 text-white rounded-md hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500">
            + 새 키 추가
          </button>
        </div>

        <!-- API Keys List -->
        <div v-if="isLoading" class="text-center text-gray-500">키 목록을 불러오는 중...</div>
        <div v-else-if="keys.length === 0" class="text-center text-gray-500 py-4 border-t">등록된 API 키가 없습니다.</div>
        <ul v-else class="divide-y divide-gray-200">
          <li v-for="key in keys" :key="key.id" class="py-3 flex justify-between items-center">
            <div>
              <p class="font-medium text-gray-900">{{ key.name }}</p>
              <p class="text-sm text-gray-500">플랫폼: {{ key.platform }} | 등록일: {{ new Date(key.created_at).toLocaleDateString() }}</p>
            </div>
            <button @click="deleteKey(key.id)" class="text-red-600 hover:text-red-800 text-sm font-medium">삭제</button>
          </li>
        </ul>
      </div>

      <!-- Add Key Modal -->
      <div v-if="showAddKeyModal" class="fixed inset-0 bg-gray-500 bg-opacity-75 flex items-center justify-center z-50" @click.self="showAddKeyModal = false">
        <div class="bg-white rounded-lg shadow-xl p-6 w-full max-w-md">
          <h3 class="text-xl font-semibold mb-4">새 API 키 추가</h3>
          <form @submit.prevent="addKey">
            <div class="space-y-4">
              <div>
                <label for="keyName" class="block text-sm font-medium text-gray-700">키 이름</label>
                <input type="text" id="keyName" v-model="newKey.name" required class="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-indigo-500 focus:border-indigo-500" placeholder="예: 내 AWS 개발 키">
              </div>
              <div>
                <label for="keyPlatform" class="block text-sm font-medium text-gray-700">플랫폼</label>
                <select id="keyPlatform" v-model="newKey.platform" required class="mt-1 block w-full px-3 py-2 border border-gray-300 bg-white rounded-md shadow-sm focus:outline-none focus:ring-indigo-500 focus:border-indigo-500">
                  <option value="aws">AWS</option>
                  <option value="gcp">GCP</option>
                  <option value="azure">Azure</option>
                  <option value="other">Other</option>
                </select>
              </div>
              <div>
                <label for="keyValue" class="block text-sm font-medium text-gray-700">키 값 (Secret)</label>
                <textarea id="keyValue" v-model="newKey.secret_value" required rows="4" class="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-indigo-500 focus:border-indigo-500" placeholder="API 키 또는 시크릿을 여기에 붙여넣으세요"></textarea>
                <p class="text-xs text-gray-500 mt-1">이 값은 암호화되어 저장되며, 다시 볼 수 없습니다.</p>
              </div>
            </div>
            <div class="mt-6 flex justify-end space-x-3">
              <button type="button" @click="showAddKeyModal = false" class="px-4 py-2 bg-white border border-gray-300 rounded-md text-gray-700 hover:bg-gray-50">취소</button>
              <button type="submit" class="px-4 py-2 bg-indigo-600 text-white rounded-md hover:bg-indigo-700">저장</button>
            </div>
          </form>
        </div>
      </div>

    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, computed } from 'vue';
import { $fetch } from 'ofetch'
import { useAuthStore } from '~/stores/auth';

type ApiKey = {
  id: number
  name: string
  platform: string
  created_at: string | number | Date
}

const keys = ref<ApiKey[]>([]);
const isLoading = ref(true);
const showAddKeyModal = ref(false);
const newKey = ref({
  name: '',
  platform: 'aws',
  secret_value: ''
});

// 프로필 데이터
const profileData = ref({
  full_name: '',
  gemini_api_key: ''
});
const isUpdating = ref(false);
const showApiKey = ref(false);

// API 키 유효성 검사
const apiKeyValidation = ref({
  isValid: false,
  message: '',
  isChecking: false
});

async function fetchProfile() {
  try {
    const data = await $fetch('/api/v1/profile/me', {
      headers: {
        ...(auth.token ? { 'Authorization': `Bearer ${auth.token}` } : {})
      }
    });
    profileData.value = {
      full_name: data.full_name || '',
      gemini_api_key: data.gemini_api_key || ''
    };
  } catch (error) {
    console.error("Failed to fetch profile:", error);
  }
}

async function fetchKeys() {
  try {
    isLoading.value = true;
    const data = await $fetch<ApiKey[]>('/api/v1/profile/keys', {
      headers: {
        ...(auth.token ? { 'Authorization': `Bearer ${auth.token}` } : {})
      }
    });
    keys.value = (data || []) as ApiKey[];
  } catch (error) {
    console.error("Failed to fetch API keys:", error);
    // Handle error display to user
  } finally {
    isLoading.value = false;
  }
}

async function addKey() {
  try {
    await $fetch('/api/v1/profile/keys', {
      method: 'POST',
      body: newKey.value,
      headers: {
        ...(auth.token ? { 'Authorization': `Bearer ${auth.token}` } : {})
      }
    });
    showAddKeyModal.value = false;
    newKey.value = { name: '', platform: 'aws', secret_value: '' }; // Reset form
    await fetchKeys(); // Refresh list
  } catch (error) {
    console.error("Failed to add API key:", error);
  }
}

// API 키 유효성 검사 함수
function validateApiKey(apiKey: string) {
  if (!apiKey || apiKey.trim() === '') {
    return {
      isValid: false,
      message: 'API 키를 입력해주세요.'
    };
  }

  const trimmedKey = apiKey.trim();
  
  // Gemini API 키 형식 검사
  if (!trimmedKey.startsWith('AIzaSy')) {
    return {
      isValid: false,
      message: '올바른 Gemini API 키 형식이 아닙니다. (AIzaSy...로 시작해야 함)'
    };
  }

  if (trimmedKey.length < 20) {
    return {
      isValid: false,
      message: 'API 키가 너무 짧습니다. (최소 20자 이상)'
    };
  }

  if (trimmedKey.length > 100) {
    return {
      isValid: false,
      message: 'API 키가 너무 깁니다. (최대 100자)'
    };
  }

  // 특수문자나 공백 검사
  if (!/^[A-Za-z0-9_-]+$/.test(trimmedKey)) {
    return {
      isValid: false,
      message: 'API 키에 허용되지 않는 문자가 포함되어 있습니다.'
    };
  }

  return {
    isValid: true,
    message: '유효한 API 키입니다.'
  };
}

// API 키 입력 시 실시간 검사
function onApiKeyInput() {
  const validation = validateApiKey(profileData.value.gemini_api_key);
  apiKeyValidation.value = {
    ...validation,
    isChecking: false
  };
}

async function updateProfile() {
  // API 키가 입력된 경우 유효성 검사
  if (profileData.value.gemini_api_key && !apiKeyValidation.value.isValid) {
    alert('유효한 API 키를 입력해주세요.');
    return;
  }

  try {
    isUpdating.value = true;
    await $fetch('/api/v1/profile', {
      method: 'PATCH',
      body: profileData.value,
      headers: {
        ...(auth.token ? { 'Authorization': `Bearer ${auth.token}` } : {})
      }
    });
    alert('프로필이 성공적으로 업데이트되었습니다.');
  } catch (error) {
    console.error("Failed to update profile:", error);
    alert('프로필 업데이트에 실패했습니다.');
  } finally {
    isUpdating.value = false;
  }
}

function toggleApiKeyVisibility() {
  showApiKey.value = !showApiKey.value;
  const input = document.getElementById('geminiApiKey') as HTMLInputElement;
  if (input) {
    input.type = showApiKey.value ? 'text' : 'password';
  }
}

async function deleteKey(keyId: number) {
  if (!confirm("정말로 이 키를 삭제하시겠습니까?")) return;

  try {
    await $fetch(`/api/v1/profile/keys/${keyId}`,
    {
      method: 'DELETE',
      headers: {
        ...(auth.token ? { 'Authorization': `Bearer ${auth.token}` } : {})
      }
    });
    await fetchKeys(); // Refresh list
  } catch (error) {
    console.error("Failed to delete API key:", error);
  }
}

onMounted(() => {
  fetchProfile();
  fetchKeys();
});

const auth = useAuthStore();
const roleLabel = computed(() => {
  const r = (auth.role || '').toLowerCase();
  if (r === 'admin' || r === 'administrator') return '관리자';
  return '일반회원';
});
const roleLabelClass = computed(() => roleLabel.value === '관리자' ? 'text-red-600' : 'text-gray-800');
</script>
