import { ref, computed, mergeProps, unref, useSSRContext } from 'vue';
import { ssrRenderAttrs, ssrIncludeBooleanAttr, ssrLooseContain, ssrLooseEqual, ssrRenderList, ssrRenderAttr, ssrInterpolate } from 'vue/server-renderer';

const _sfc_main = {
  __name: "index",
  __ssrInlineRender: true,
  setup(__props) {
    const provider = ref("");
    const command = ref("");
    const args = ref("");
    const output = ref("");
    const error = ref("");
    const loading = ref(false);
    const commandOptions = {
      aws: [
        { value: "s3_ls", label: "S3 \uBC84\uD0B7 \uBAA9\uB85D \uC870\uD68C", description: "aws s3 ls" },
        { value: "ec2_describe_instances", label: "EC2 \uC778\uC2A4\uD134\uC2A4 \uC815\uBCF4 \uC870\uD68C", description: "aws ec2 describe-instances" },
        { value: "iam_list_users", label: "IAM \uC0AC\uC6A9\uC790 \uBAA9\uB85D \uC870\uD68C", description: "aws iam list-users" },
        { value: "vpc_describe_vpcs", label: "VPC \uC815\uBCF4 \uC870\uD68C", description: "aws ec2 describe-vpcs" }
      ],
      gcp: [
        { value: "gcloud_zones_list", label: "\uCEF4\uD4E8\uD305 \uC601\uC5ED \uBAA9\uB85D \uC870\uD68C", description: "gcloud compute zones list" },
        { value: "gcloud_projects_list", label: "\uD504\uB85C\uC81D\uD2B8 \uBAA9\uB85D \uC870\uD68C", description: "gcloud projects list" },
        { value: "gcloud_storage_buckets_list", label: "\uC2A4\uD1A0\uB9AC\uC9C0 \uBC84\uD0B7 \uBAA9\uB85D \uC870\uD68C", description: "gcloud storage buckets list" },
        { value: "gcloud_compute_instances_list", label: "\uCEF4\uD4E8\uD305 \uC778\uC2A4\uD134\uC2A4 \uBAA9\uB85D \uC870\uD68C", description: "gcloud compute instances list" }
      ]
    };
    const availableCommands = computed(() => {
      return provider.value ? commandOptions[provider.value] || [] : [];
    });
    const isFormValid = computed(() => {
      return provider.value && command.value;
    });
    return (_ctx, _push, _parent, _attrs) => {
      _push(`<div${ssrRenderAttrs(mergeProps({ class: "px-4 sm:px-6 lg:px-8" }, _attrs))}><div class="mb-8"><h1 class="text-3xl font-bold text-gray-900">CLI \uC77D\uAE30 \uC804\uC6A9 \uC2E4\uD589</h1><p class="mt-2 text-gray-600"> \uC548\uC804\uD55C \uC77D\uAE30 \uC804\uC6A9 CLI \uBA85\uB839\uC744 \uC2E4\uD589\uD558\uC5EC \uD074\uB77C\uC6B0\uB4DC \uB9AC\uC18C\uC2A4 \uC815\uBCF4\uB97C \uC870\uD68C\uD558\uC138\uC694. </p></div><div class="max-w-4xl mx-auto"><div class="bg-white rounded-lg shadow p-6"><form class="space-y-6"><div><label class="block text-sm font-medium text-gray-700 mb-2"> \uD074\uB77C\uC6B0\uB4DC \uD504\uB85C\uBC14\uC774\uB354 </label><select class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-transparent" required><option value=""${ssrIncludeBooleanAttr(Array.isArray(unref(provider)) ? ssrLooseContain(unref(provider), "") : ssrLooseEqual(unref(provider), "")) ? " selected" : ""}>\uD504\uB85C\uBC14\uC774\uB354\uB97C \uC120\uD0DD\uD558\uC138\uC694</option><option value="aws"${ssrIncludeBooleanAttr(Array.isArray(unref(provider)) ? ssrLooseContain(unref(provider), "aws") : ssrLooseEqual(unref(provider), "aws")) ? " selected" : ""}>AWS</option><option value="gcp"${ssrIncludeBooleanAttr(Array.isArray(unref(provider)) ? ssrLooseContain(unref(provider), "gcp") : ssrLooseEqual(unref(provider), "gcp")) ? " selected" : ""}>Google Cloud Platform</option></select></div><div><label class="block text-sm font-medium text-gray-700 mb-2"> \uC2E4\uD589\uD560 \uBA85\uB839\uC5B4 </label><select class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-transparent"${ssrIncludeBooleanAttr(!unref(provider)) ? " disabled" : ""} required><option value=""${ssrIncludeBooleanAttr(Array.isArray(unref(command)) ? ssrLooseContain(unref(command), "") : ssrLooseEqual(unref(command), "")) ? " selected" : ""}>\uBA85\uB839\uC5B4\uB97C \uC120\uD0DD\uD558\uC138\uC694</option><!--[-->`);
      ssrRenderList(unref(availableCommands), (cmd) => {
        _push(`<option${ssrRenderAttr("value", cmd.value)}${ssrIncludeBooleanAttr(Array.isArray(unref(command)) ? ssrLooseContain(unref(command), cmd.value) : ssrLooseEqual(unref(command), cmd.value)) ? " selected" : ""}>${ssrInterpolate(cmd.label)} (${ssrInterpolate(cmd.description)}) </option>`);
      });
      _push(`<!--]--></select></div><div><label class="block text-sm font-medium text-gray-700 mb-2"> \uBA85\uB839\uC5B4 \uC778\uC218 (JSON \uD615\uC2DD) </label><textarea rows="4" placeholder="\uC608: {&quot;region&quot;: &quot;us-east-1&quot;, &quot;bucket&quot;: &quot;my-bucket&quot;}" class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-transparent font-mono text-sm">${ssrInterpolate(unref(args))}</textarea><p class="mt-1 text-xs text-gray-500"> JSON \uD615\uC2DD\uC73C\uB85C \uBA85\uB839\uC5B4 \uC778\uC218\uB97C \uC785\uB825\uD558\uC138\uC694. \uC778\uC218\uAC00 \uD544\uC694\uD558\uC9C0 \uC54A\uC73C\uBA74 \uBE44\uC6CC\uB450\uC138\uC694. </p></div><div><button type="submit"${ssrIncludeBooleanAttr(!unref(isFormValid) || unref(loading)) ? " disabled" : ""} class="w-full px-6 py-3 bg-primary-600 text-white font-medium rounded-md hover:bg-primary-700 disabled:opacity-50 disabled:cursor-not-allowed transition-colors">`);
      if (unref(loading)) {
        _push(`<span class="flex items-center justify-center"><svg class="animate-spin -ml-1 mr-3 h-5 w-5 text-white" fill="none" viewBox="0 0 24 24"><circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle><path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path></svg> \uC2E4\uD589 \uC911... </span>`);
      } else {
        _push(`<span>\uBA85\uB839\uC5B4 \uC2E4\uD589</span>`);
      }
      _push(`</button></div></form>`);
      if (unref(error)) {
        _push(`<div class="mt-6 p-4 bg-red-50 border border-red-200 rounded-md"><div class="flex"><svg class="h-5 w-5 text-red-400" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path></svg><div class="ml-3"><h3 class="text-sm font-medium text-red-800">\uC624\uB958 \uBC1C\uC0DD</h3><div class="mt-2 text-sm text-red-700">${ssrInterpolate(unref(error))}</div></div></div></div>`);
      } else {
        _push(`<!---->`);
      }
      if (unref(output)) {
        _push(`<div class="mt-6"><h3 class="text-lg font-medium text-gray-900 mb-3">\uC2E4\uD589 \uACB0\uACFC</h3><div class="bg-gray-50 rounded-md p-4"><pre class="text-sm text-gray-800 overflow-x-auto whitespace-pre-wrap">${ssrInterpolate(unref(output))}</pre></div></div>`);
      } else {
        _push(`<!---->`);
      }
      _push(`</div><div class="mt-8 bg-green-50 rounded-lg p-6"><h3 class="text-lg font-medium text-green-900 mb-3">\u{1F512} \uBCF4\uC548 \uC815\uBCF4</h3><div class="space-y-2 text-sm text-green-800"><p>\u2022 <strong>\uC77D\uAE30 \uC804\uC6A9:</strong> \uBAA8\uB4E0 CLI \uBA85\uB839\uC740 \uC77D\uAE30 \uC804\uC6A9\uC73C\uB85C\uB9CC \uC2E4\uD589\uB429\uB2C8\uB2E4.</p><p>\u2022 <strong>\uD654\uC774\uD2B8\uB9AC\uC2A4\uD2B8:</strong> \uBBF8\uB9AC \uC2B9\uC778\uB41C \uC548\uC804\uD55C \uBA85\uB839\uC5B4\uB9CC \uC2E4\uD589 \uAC00\uB2A5\uD569\uB2C8\uB2E4.</p><p>\u2022 <strong>\uAC10\uC0AC \uB85C\uADF8:</strong> \uBAA8\uB4E0 \uBA85\uB839\uC5B4 \uC2E4\uD589\uC740 \uB85C\uADF8\uC5D0 \uAE30\uB85D\uB429\uB2C8\uB2E4.</p><p>\u2022 <strong>\uAD8C\uD55C \uC81C\uD55C:</strong> \uC778\uD504\uB77C \uBCC0\uACBD\uC744 \uC704\uD55C \uBA85\uB839\uC5B4\uB294 Terraform\uC744 \uD1B5\uD574 \uC2E4\uD589\uD558\uC138\uC694.</p></div></div><div class="mt-8 bg-blue-50 rounded-lg p-6"><h3 class="text-lg font-medium text-blue-900 mb-3">\u{1F4CB} \uC9C0\uC6D0 \uBA85\uB839\uC5B4 \uBAA9\uB85D</h3><div class="grid grid-cols-1 md:grid-cols-2 gap-4"><div><h4 class="font-medium text-blue-800 mb-2">AWS</h4><ul class="space-y-1 text-sm text-blue-700"><li>\u2022 s3_ls - S3 \uBC84\uD0B7 \uBAA9\uB85D \uC870\uD68C</li><li>\u2022 ec2_describe_instances - EC2 \uC778\uC2A4\uD134\uC2A4 \uC815\uBCF4 \uC870\uD68C</li><li>\u2022 iam_list_users - IAM \uC0AC\uC6A9\uC790 \uBAA9\uB85D \uC870\uD68C</li><li>\u2022 vpc_describe_vpcs - VPC \uC815\uBCF4 \uC870\uD68C</li></ul></div><div><h4 class="font-medium text-blue-800 mb-2">GCP</h4><ul class="space-y-1 text-sm text-blue-700"><li>\u2022 gcloud_zones_list - \uCEF4\uD4E8\uD305 \uC601\uC5ED \uBAA9\uB85D \uC870\uD68C</li><li>\u2022 gcloud_projects_list - \uD504\uB85C\uC81D\uD2B8 \uBAA9\uB85D \uC870\uD68C</li><li>\u2022 gcloud_storage_buckets_list - \uC2A4\uD1A0\uB9AC\uC9C0 \uBC84\uD0B7 \uBAA9\uB85D \uC870\uD68C</li><li>\u2022 gcloud_compute_instances_list - \uCEF4\uD4E8\uD305 \uC778\uC2A4\uD134\uC2A4 \uBAA9\uB85D \uC870\uD68C</li></ul></div></div></div></div></div>`);
    };
  }
};
const _sfc_setup = _sfc_main.setup;
_sfc_main.setup = (props, ctx) => {
  const ssrContext = useSSRContext();
  (ssrContext.modules || (ssrContext.modules = /* @__PURE__ */ new Set())).add("pages/cli/index.vue");
  return _sfc_setup ? _sfc_setup(props, ctx) : void 0;
};

export { _sfc_main as default };
//# sourceMappingURL=index-DZVI2pHJ.mjs.map
