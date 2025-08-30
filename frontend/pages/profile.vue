<template>
  <div class="p-4 sm:p-6 lg:p-8">
    <div class="max-w-4xl mx-auto">
      <h1 class="text-2xl font-bold text-gray-900 mb-6">내 프로필</h1>

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
import { ref, onMounted } from 'vue';

const keys = ref([]);
const isLoading = ref(true);
const showAddKeyModal = ref(false);
const newKey = ref({
  name: '',
  platform: 'aws',
  secret_value: ''
});

async function fetchKeys() {
  try {
    isLoading.value = true;
    const response = await useFetch('/api/v1/profile/keys', { server: false });
    if (response.data.value) {
      keys.value = response.data.value;
    }
  } catch (error) {
    console.error("Failed to fetch API keys:", error);
    // Handle error display to user
  } finally {
    isLoading.value = false;
  }
}

async function addKey() {
  try {
    await useFetch('/api/v1/profile/keys', {
      method: 'POST',
      body: newKey.value,
      server: false
    });
    showAddKeyModal.value = false;
    newKey.value = { name: '', platform: 'aws', secret_value: '' }; // Reset form
    await fetchKeys(); // Refresh list
  } catch (error) {
    console.error("Failed to add API key:", error);
  }
}

async function deleteKey(keyId: number) {
  if (!confirm("정말로 이 키를 삭제하시겠습니까?")) return;

  try {
    await useFetch(`/api/v1/profile/keys/${keyId}`,
    {
      method: 'DELETE',
      server: false
    });
    await fetchKeys(); // Refresh list
  } catch (error) {
    console.error("Failed to delete API key:", error);
  }
}

onMounted(() => {
  fetchKeys();
});
</script>
