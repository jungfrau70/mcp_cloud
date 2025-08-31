import { defineComponent, ref, computed, mergeProps, useSSRContext } from 'vue';
import { ssrRenderAttrs, ssrInterpolate } from 'vue/server-renderer';

const _sfc_main = /* @__PURE__ */ defineComponent({
  __name: "billing",
  __ssrInlineRender: true,
  setup(__props) {
    const subscription = ref(null);
    const isLoading = ref(true);
    const proPlanId = ref("price_1Pb...pro_plan_id");
    const isSubscribedToPro = computed(() => {
      return subscription.value && subscription.value.plan_id === proPlanId.value && subscription.value.status === "active";
    });
    return (_ctx, _push, _parent, _attrs) => {
      _push(`<div${ssrRenderAttrs(mergeProps({ class: "bg-gray-50 min-h-screen" }, _attrs))}><div class="p-4 sm:p-6 lg:p-8"><div class="max-w-4xl mx-auto"><h1 class="text-2xl font-bold text-gray-900 mb-6">\uAD6C\uB3C5 \uBC0F \uACB0\uC81C</h1><div class="bg-white shadow-md rounded-lg p-6 mb-8"><h2 class="text-lg font-semibold text-gray-800 mb-2">\uB098\uC758 \uD50C\uB79C</h2>`);
      if (isLoading.value) {
        _push(`<div class="text-gray-500">\uC815\uBCF4\uB97C \uBD88\uB7EC\uC624\uB294 \uC911...</div>`);
      } else if (subscription.value && subscription.value.status === "active") {
        _push(`<div class="space-y-2"><p class="text-xl font-medium text-indigo-600">${ssrInterpolate(subscription.value.plan_id === proPlanId.value ? "Pro Plan" : "Free Plan")}</p><p class="text-sm text-gray-600">\uC0C1\uD0DC: <span class="font-semibold text-green-600">\uD65C\uC131</span></p><p class="text-sm text-gray-600">\uB2E4\uC74C \uACB0\uC81C\uC77C: ${ssrInterpolate(new Date(subscription.value.current_period_end * 1e3).toLocaleDateString())}</p><button class="mt-4 px-4 py-2 border border-transparent text-sm font-medium rounded-md shadow-sm text-white bg-indigo-600 hover:bg-indigo-700">\uAD6C\uB3C5 \uAD00\uB9AC</button></div>`);
      } else {
        _push(`<div><p class="text-xl font-medium text-gray-700">Free Plan</p><p class="text-sm text-gray-600">\uD604\uC7AC \uBB34\uB8CC \uD50C\uB79C\uC744 \uC0AC\uC6A9\uD558\uACE0 \uC788\uC2B5\uB2C8\uB2E4.</p></div>`);
      }
      _push(`</div><div class="bg-white shadow-md rounded-lg p-6"><h2 class="text-lg font-semibold text-gray-800 mb-4">\uD50C\uB79C \uC5C5\uADF8\uB808\uC774\uB4DC</h2><div class="border border-gray-200 rounded-lg p-6 flex justify-between items-center"><div><h3 class="text-xl font-bold text-indigo-600">Pro Plan</h3><p class="text-gray-600 mt-2">\uBAA8\uB4E0 \uAE30\uB2A5\uC744 \uC81C\uD55C \uC5C6\uC774 \uC0AC\uC6A9\uD558\uC138\uC694.</p><ul class="text-sm text-gray-500 list-disc list-inside mt-2"><li>\uBB34\uC81C\uD55C AI \uBB38\uC11C \uC0DD\uC131</li><li>\uBB34\uC81C\uD55C \uD0A4/\uC778\uC99D\uC11C \uAD00\uB9AC</li><li>\uC6B0\uC120 \uC9C0\uC6D0</li></ul></div><div class="text-right"><p class="text-2xl font-bold">$10 / \uC6D4</p>`);
      if (!isSubscribedToPro.value) {
        _push(`<button class="mt-4 w-full px-6 py-3 border border-transparent text-base font-medium rounded-md shadow-sm text-white bg-indigo-600 hover:bg-indigo-700">Pro \uD50C\uB79C\uC73C\uB85C \uC2DC\uC791\uD558\uAE30</button>`);
      } else {
        _push(`<p class="mt-4 text-sm text-green-600 font-semibold">\uD604\uC7AC \uC0AC\uC6A9 \uC911\uC778 \uD50C\uB79C\uC785\uB2C8\uB2E4.</p>`);
      }
      _push(`</div></div></div></div></div></div>`);
    };
  }
});
const _sfc_setup = _sfc_main.setup;
_sfc_main.setup = (props, ctx) => {
  const ssrContext = useSSRContext();
  (ssrContext.modules || (ssrContext.modules = /* @__PURE__ */ new Set())).add("pages/billing.vue");
  return _sfc_setup ? _sfc_setup(props, ctx) : void 0;
};

export { _sfc_main as default };
//# sourceMappingURL=billing-BKsrM_Bo.mjs.map
