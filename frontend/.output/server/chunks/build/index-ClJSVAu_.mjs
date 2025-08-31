import { ref, computed, mergeProps, unref, useSSRContext } from 'vue';
import { ssrRenderAttrs, ssrIncludeBooleanAttr, ssrLooseContain, ssrLooseEqual, ssrRenderList, ssrRenderAttr, ssrInterpolate } from 'vue/server-renderer';

const _sfc_main = {
  __name: "index",
  __ssrInlineRender: true,
  setup(__props) {
    const provider = ref("");
    const dataType = ref("");
    const dataName = ref("");
    const config = ref("{}");
    const result = ref(null);
    const error = ref("");
    const loading = ref(false);
    const dataTypeOptions = {
      aws: [
        "aws_caller_identity",
        "aws_iam_policy_document",
        "aws_region",
        "aws_ami",
        "aws_vpc",
        "aws_subnet",
        "aws_security_group"
      ],
      google: [
        "google_project",
        "google_storage_bucket",
        "google_service_account",
        "google_client_openid_userinfo",
        "google_compute_zones",
        "google_compute_regions"
      ],
      azurerm: [
        "azurerm_client_config",
        "azurerm_subscription",
        "azurerm_resource_group",
        "azurerm_virtual_network"
      ]
    };
    const availableDataTypes = computed(() => {
      return provider.value ? dataTypeOptions[provider.value] || [] : [];
    });
    const isFormValid = computed(() => {
      return provider.value && dataType.value && dataName.value.trim();
    });
    return (_ctx, _push, _parent, _attrs) => {
      _push(`<div${ssrRenderAttrs(mergeProps({ class: "px-4 sm:px-6 lg:px-8" }, _attrs))}><div class="mb-8"><h1 class="text-3xl font-bold text-gray-900">Terraform \uB370\uC774\uD130\uC18C\uC2A4 \uCFFC\uB9AC</h1><p class="mt-2 text-gray-600"> AWS, GCP, Azure\uC758 \uD074\uB77C\uC6B0\uB4DC \uB9AC\uC18C\uC2A4 \uC815\uBCF4\uB97C Terraform \uB370\uC774\uD130\uC18C\uC2A4\uB85C \uC870\uD68C\uD558\uC138\uC694. </p></div><div class="max-w-4xl mx-auto"><div class="bg-white rounded-lg shadow p-6"><form class="space-y-6"><div><label class="block text-sm font-medium text-gray-700 mb-2"> \uD074\uB77C\uC6B0\uB4DC \uD504\uB85C\uBC14\uC774\uB354 </label><select class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-transparent" required><option value=""${ssrIncludeBooleanAttr(Array.isArray(unref(provider)) ? ssrLooseContain(unref(provider), "") : ssrLooseEqual(unref(provider), "")) ? " selected" : ""}>\uD504\uB85C\uBC14\uC774\uB354\uB97C \uC120\uD0DD\uD558\uC138\uC694</option><option value="aws"${ssrIncludeBooleanAttr(Array.isArray(unref(provider)) ? ssrLooseContain(unref(provider), "aws") : ssrLooseEqual(unref(provider), "aws")) ? " selected" : ""}>AWS</option><option value="google"${ssrIncludeBooleanAttr(Array.isArray(unref(provider)) ? ssrLooseContain(unref(provider), "google") : ssrLooseEqual(unref(provider), "google")) ? " selected" : ""}>Google Cloud Platform</option><option value="azurerm"${ssrIncludeBooleanAttr(Array.isArray(unref(provider)) ? ssrLooseContain(unref(provider), "azurerm") : ssrLooseEqual(unref(provider), "azurerm")) ? " selected" : ""}>Microsoft Azure</option></select></div><div><label class="block text-sm font-medium text-gray-700 mb-2"> \uB370\uC774\uD130 \uD0C0\uC785 </label><select class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-transparent"${ssrIncludeBooleanAttr(!unref(provider)) ? " disabled" : ""} required><option value=""${ssrIncludeBooleanAttr(Array.isArray(unref(dataType)) ? ssrLooseContain(unref(dataType), "") : ssrLooseEqual(unref(dataType), "")) ? " selected" : ""}>\uB370\uC774\uD130 \uD0C0\uC785\uC744 \uC120\uD0DD\uD558\uC138\uC694</option><!--[-->`);
      ssrRenderList(unref(availableDataTypes), (type) => {
        _push(`<option${ssrRenderAttr("value", type)}${ssrIncludeBooleanAttr(Array.isArray(unref(dataType)) ? ssrLooseContain(unref(dataType), type) : ssrLooseEqual(unref(dataType), type)) ? " selected" : ""}>${ssrInterpolate(type)}</option>`);
      });
      _push(`<!--]--></select></div><div><label class="block text-sm font-medium text-gray-700 mb-2"> \uB370\uC774\uD130 \uC774\uB984 </label><input${ssrRenderAttr("value", unref(dataName))} type="text" placeholder="\uC608: current, default, this" class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-transparent" required></div><div><label class="block text-sm font-medium text-gray-700 mb-2"> \uC124\uC815 (JSON) </label><textarea rows="5" placeholder="\uC608: {&quot;most_recent&quot;: true, &quot;owners&quot;: [&quot;amazon&quot;]}" class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-transparent font-mono text-sm">${ssrInterpolate(unref(config))}</textarea><p class="mt-1 text-xs text-gray-500"> JSON \uD615\uC2DD\uC73C\uB85C \uC124\uC815\uC744 \uC785\uB825\uD558\uC138\uC694. \uBE48 \uAC1D\uCCB4 {}\uB3C4 \uAC00\uB2A5\uD569\uB2C8\uB2E4. </p></div><div><button type="submit"${ssrIncludeBooleanAttr(!unref(isFormValid) || unref(loading)) ? " disabled" : ""} class="w-full px-6 py-3 bg-primary-600 text-white font-medium rounded-md hover:bg-primary-700 disabled:opacity-50 disabled:cursor-not-allowed transition-colors">`);
      if (unref(loading)) {
        _push(`<span class="flex items-center justify-center"><svg class="animate-spin -ml-1 mr-3 h-5 w-5 text-white" fill="none" viewBox="0 0 24 24"><circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle><path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path></svg> \uCFFC\uB9AC \uC911... </span>`);
      } else {
        _push(`<span>\uB370\uC774\uD130\uC18C\uC2A4 \uCFFC\uB9AC</span>`);
      }
      _push(`</button></div></form>`);
      if (unref(error)) {
        _push(`<div class="mt-6 p-4 bg-red-50 border border-red-200 rounded-md"><div class="flex"><svg class="h-5 w-5 text-red-400" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path></svg><div class="ml-3"><h3 class="text-sm font-medium text-red-800">\uC624\uB958 \uBC1C\uC0DD</h3><div class="mt-2 text-sm text-red-700">${ssrInterpolate(unref(error))}</div></div></div></div>`);
      } else {
        _push(`<!---->`);
      }
      if (unref(result)) {
        _push(`<div class="mt-6"><h3 class="text-lg font-medium text-gray-900 mb-3">\uCFFC\uB9AC \uACB0\uACFC</h3><div class="bg-gray-50 rounded-md p-4"><pre class="text-sm text-gray-800 overflow-x-auto">${ssrInterpolate(JSON.stringify(unref(result), null, 2))}</pre></div></div>`);
      } else {
        _push(`<!---->`);
      }
      _push(`</div><div class="mt-8 bg-blue-50 rounded-lg p-6"><h3 class="text-lg font-medium text-blue-900 mb-3">\u{1F4A1} \uC0AC\uC6A9 \uD301</h3><div class="space-y-2 text-sm text-blue-800"><p>\u2022 <strong>AWS AMI \uC870\uD68C:</strong> Provider: aws, Data Type: aws_ami, Config: {&quot;most_recent&quot;: true, &quot;owners&quot;: [&quot;amazon&quot;]}</p><p>\u2022 <strong>GCP \uC601\uC5ED \uC870\uD68C:</strong> Provider: google, Data Type: google_compute_zones, Config: {&quot;project&quot;: &quot;your-project-id&quot;}</p><p>\u2022 <strong>Azure \uAD6C\uB3C5 \uC815\uBCF4:</strong> Provider: azurerm, Data Type: azurerm_subscription, Config: {}</p></div></div></div></div>`);
    };
  }
};
const _sfc_setup = _sfc_main.setup;
_sfc_main.setup = (props, ctx) => {
  const ssrContext = useSSRContext();
  (ssrContext.modules || (ssrContext.modules = /* @__PURE__ */ new Set())).add("pages/datasources/index.vue");
  return _sfc_setup ? _sfc_setup(props, ctx) : void 0;
};

export { _sfc_main as default };
//# sourceMappingURL=index-ClJSVAu_.mjs.map
