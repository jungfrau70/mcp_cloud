<template>
  <div class="bg-gray-50 min-h-screen">
    <div class="p-4 sm:p-6 lg:p-8">
      <div class="max-w-4xl mx-auto">
        <h1 class="text-2xl font-bold text-gray-900 mb-6">구독 및 결제</h1>

        <!-- Current Plan -->
        <div class="bg-white shadow-md rounded-lg p-6 mb-8">
          <h2 class="text-lg font-semibold text-gray-800 mb-2">나의 플랜</h2>
          <div v-if="isLoading" class="text-gray-500">정보를 불러오는 중...</div>
          <div v-else-if="subscription && subscription.status === 'active'" class="space-y-2">
            <p class="text-xl font-medium text-indigo-600">{{ subscription.plan_id === proPlanId ? 'Pro Plan' : 'Free Plan' }}</p>
            <p class="text-sm text-gray-600">상태: <span class="font-semibold text-green-600">활성</span></p>
            <p class="text-sm text-gray-600">다음 결제일: {{ new Date(subscription.current_period_end * 1000).toLocaleDateString() }}</p>
            <button @click="manageSubscription" class="mt-4 px-4 py-2 border border-transparent text-sm font-medium rounded-md shadow-sm text-white bg-indigo-600 hover:bg-indigo-700">구독 관리</button>
          </div>
          <div v-else>
            <p class="text-xl font-medium text-gray-700">Free Plan</p>
            <p class="text-sm text-gray-600">현재 무료 플랜을 사용하고 있습니다.</p>
          </div>
        </div>

        <!-- Plan Options -->
        <div class="bg-white shadow-md rounded-lg p-6">
          <h2 class="text-lg font-semibold text-gray-800 mb-4">플랜 업그레이드</h2>
          <div class="border border-gray-200 rounded-lg p-6 flex justify-between items-center">
            <div>
              <h3 class="text-xl font-bold text-indigo-600">Pro Plan</h3>
              <p class="text-gray-600 mt-2">모든 기능을 제한 없이 사용하세요.</p>
              <ul class="text-sm text-gray-500 list-disc list-inside mt-2">
                <li>무제한 AI 문서 생성</li>
                <li>무제한 키/인증서 관리</li>
                <li>우선 지원</li>
              </ul>
            </div>
            <div class="text-right">
              <p class="text-2xl font-bold">$10 / 월</p>
              <button v-if="!isSubscribedToPro" @click="subscribeToPro" class="mt-4 w-full px-6 py-3 border border-transparent text-base font-medium rounded-md shadow-sm text-white bg-indigo-600 hover:bg-indigo-700">Pro 플랜으로 시작하기</button>
              <p v-else class="mt-4 text-sm text-green-600 font-semibold">현재 사용 중인 플랜입니다.</p>
            </div>
          </div>
        </div>

      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, computed } from 'vue';

const subscription = ref(null);
const isLoading = ref(true);
// This should match the ID in your Stripe dashboard and backend .env file
const proPlanId = ref(import.meta.env.VITE_STRIPE_PRO_PLAN_PRICE_ID || 'price_1Pb...pro_plan_id'); 

const isSubscribedToPro = computed(() => {
  return subscription.value && subscription.value.plan_id === proPlanId.value && subscription.value.status === 'active';
});

async function fetchSubscriptionStatus() {
  try {
    isLoading.value = true;
    // This endpoint needs to be created to fetch user's subscription from your DB
    const { data } = await useFetch('/api/v1/users/me/subscription', { server: false });
    if (data.value) {
      subscription.value = data.value;
    }
  } catch (error) {
    console.error("Failed to fetch subscription status:", error);
  } finally {
    isLoading.value = false;
  }
}

async function subscribeToPro() {
  try {
    const { data } = await useFetch('/api/v1/billing/checkout-session', { method: 'POST', server: false });
    if (data.value && data.value.url) {
      window.location.href = data.value.url;
    }
  } catch (error) {
    console.error("Failed to create checkout session:", error);
  }
}

async function manageSubscription() {
  try {
    const { data } = await useFetch('/api/v1/billing/portal-session', { method: 'POST', server: false });
    if (data.value && data.value.url) {
      window.location.href = data.value.url;
    }
  } catch (error) {
    console.error("Failed to create portal session:", error);
  }
}

onMounted(() => {
  // We need an endpoint to get the current user's subscription status from our DB
  // For now, this is a placeholder. Let's assume we need to implement GET /api/v1/users/me/subscription
  // fetchSubscriptionStatus();
});
</script>
