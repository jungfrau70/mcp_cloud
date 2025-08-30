import { defineComponent, ref, mergeProps, useSSRContext } from 'vue';
import { ssrRenderAttrs, ssrRenderList, ssrInterpolate, ssrRenderAttr, ssrIncludeBooleanAttr, ssrLooseContain, ssrLooseEqual } from 'vue/server-renderer';

const _sfc_main = /* @__PURE__ */ defineComponent({
  __name: "profile",
  __ssrInlineRender: true,
  setup(__props) {
    const keys = ref([]);
    const isLoading = ref(true);
    const showAddKeyModal = ref(false);
    const newKey = ref({
      name: "",
      platform: "aws",
      secret_value: ""
    });
    return (_ctx, _push, _parent, _attrs) => {
      _push(`<div${ssrRenderAttrs(mergeProps({ class: "p-4 sm:p-6 lg:p-8" }, _attrs))}><div class="max-w-4xl mx-auto"><h1 class="text-2xl font-bold text-gray-900 mb-6">\uB0B4 \uD504\uB85C\uD544</h1><div class="bg-white shadow-md rounded-lg p-6"><div class="flex justify-between items-center mb-4"><h2 class="text-lg font-semibold text-gray-800">API \uD0A4 \uAD00\uB9AC</h2><button class="px-4 py-2 bg-indigo-600 text-white rounded-md hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500"> + \uC0C8 \uD0A4 \uCD94\uAC00 </button></div>`);
      if (isLoading.value) {
        _push(`<div class="text-center text-gray-500">\uD0A4 \uBAA9\uB85D\uC744 \uBD88\uB7EC\uC624\uB294 \uC911...</div>`);
      } else if (keys.value.length === 0) {
        _push(`<div class="text-center text-gray-500 py-4 border-t">\uB4F1\uB85D\uB41C API \uD0A4\uAC00 \uC5C6\uC2B5\uB2C8\uB2E4.</div>`);
      } else {
        _push(`<ul class="divide-y divide-gray-200"><!--[-->`);
        ssrRenderList(keys.value, (key) => {
          _push(`<li class="py-3 flex justify-between items-center"><div><p class="font-medium text-gray-900">${ssrInterpolate(key.name)}</p><p class="text-sm text-gray-500">\uD50C\uB7AB\uD3FC: ${ssrInterpolate(key.platform)} | \uB4F1\uB85D\uC77C: ${ssrInterpolate(new Date(key.created_at).toLocaleDateString())}</p></div><button class="text-red-600 hover:text-red-800 text-sm font-medium">\uC0AD\uC81C</button></li>`);
        });
        _push(`<!--]--></ul>`);
      }
      _push(`</div>`);
      if (showAddKeyModal.value) {
        _push(`<div class="fixed inset-0 bg-gray-500 bg-opacity-75 flex items-center justify-center z-50"><div class="bg-white rounded-lg shadow-xl p-6 w-full max-w-md"><h3 class="text-xl font-semibold mb-4">\uC0C8 API \uD0A4 \uCD94\uAC00</h3><form><div class="space-y-4"><div><label for="keyName" class="block text-sm font-medium text-gray-700">\uD0A4 \uC774\uB984</label><input type="text" id="keyName"${ssrRenderAttr("value", newKey.value.name)} required class="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-indigo-500 focus:border-indigo-500" placeholder="\uC608: \uB0B4 AWS \uAC1C\uBC1C \uD0A4"></div><div><label for="keyPlatform" class="block text-sm font-medium text-gray-700">\uD50C\uB7AB\uD3FC</label><select id="keyPlatform" required class="mt-1 block w-full px-3 py-2 border border-gray-300 bg-white rounded-md shadow-sm focus:outline-none focus:ring-indigo-500 focus:border-indigo-500"><option value="aws"${ssrIncludeBooleanAttr(Array.isArray(newKey.value.platform) ? ssrLooseContain(newKey.value.platform, "aws") : ssrLooseEqual(newKey.value.platform, "aws")) ? " selected" : ""}>AWS</option><option value="gcp"${ssrIncludeBooleanAttr(Array.isArray(newKey.value.platform) ? ssrLooseContain(newKey.value.platform, "gcp") : ssrLooseEqual(newKey.value.platform, "gcp")) ? " selected" : ""}>GCP</option><option value="azure"${ssrIncludeBooleanAttr(Array.isArray(newKey.value.platform) ? ssrLooseContain(newKey.value.platform, "azure") : ssrLooseEqual(newKey.value.platform, "azure")) ? " selected" : ""}>Azure</option><option value="other"${ssrIncludeBooleanAttr(Array.isArray(newKey.value.platform) ? ssrLooseContain(newKey.value.platform, "other") : ssrLooseEqual(newKey.value.platform, "other")) ? " selected" : ""}>Other</option></select></div><div><label for="keyValue" class="block text-sm font-medium text-gray-700">\uD0A4 \uAC12 (Secret)</label><textarea id="keyValue" required rows="4" class="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-indigo-500 focus:border-indigo-500" placeholder="API \uD0A4 \uB610\uB294 \uC2DC\uD06C\uB9BF\uC744 \uC5EC\uAE30\uC5D0 \uBD99\uC5EC\uB123\uC73C\uC138\uC694">${ssrInterpolate(newKey.value.secret_value)}</textarea><p class="text-xs text-gray-500 mt-1">\uC774 \uAC12\uC740 \uC554\uD638\uD654\uB418\uC5B4 \uC800\uC7A5\uB418\uBA70, \uB2E4\uC2DC \uBCFC \uC218 \uC5C6\uC2B5\uB2C8\uB2E4.</p></div></div><div class="mt-6 flex justify-end space-x-3"><button type="button" class="px-4 py-2 bg-white border border-gray-300 rounded-md text-gray-700 hover:bg-gray-50">\uCDE8\uC18C</button><button type="submit" class="px-4 py-2 bg-indigo-600 text-white rounded-md hover:bg-indigo-700">\uC800\uC7A5</button></div></form></div></div>`);
      } else {
        _push(`<!---->`);
      }
      _push(`</div></div>`);
    };
  }
});
const _sfc_setup = _sfc_main.setup;
_sfc_main.setup = (props, ctx) => {
  const ssrContext = useSSRContext();
  (ssrContext.modules || (ssrContext.modules = /* @__PURE__ */ new Set())).add("pages/profile.vue");
  return _sfc_setup ? _sfc_setup(props, ctx) : void 0;
};

export { _sfc_main as default };
//# sourceMappingURL=profile-Cug0xkxK.mjs.map
