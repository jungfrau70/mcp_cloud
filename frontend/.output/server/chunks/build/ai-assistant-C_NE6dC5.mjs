import { ref, reactive, mergeProps, useSSRContext } from 'vue';
import { ssrRenderAttrs, ssrRenderList, ssrRenderClass, ssrInterpolate, ssrRenderAttr, ssrIncludeBooleanAttr, ssrLooseContain, ssrLooseEqual } from 'vue/server-renderer';
import { u as useRuntimeConfig } from './server.mjs';
import { _ as _export_sfc } from './_plugin-vue_export-helper-1tPrXgE0.mjs';
import '../nitro/nitro.mjs';
import 'node:http';
import 'node:https';
import 'node:events';
import 'node:buffer';
import 'node:fs';
import 'node:path';
import 'node:crypto';
import 'node:url';
import '../routes/renderer.mjs';
import 'vue-bundle-renderer/runtime';
import 'unhead/server';
import 'devalue';
import 'unhead/utils';
import 'unhead/plugins';
import 'vue-router';
import 'pinia';

const _sfc_main = {
  __name: "ai-assistant",
  __ssrInlineRender: true,
  setup(__props) {
    const activeTab = ref("chat");
    const tabs = [
      { id: "chat", name: "AI \uC5B4\uC2DC\uC2A4\uD134\uD2B8" },
      { id: "terraform", name: "Terraform \uC0DD\uC131" },
      { id: "cost", name: "\uBE44\uC6A9 \uBD84\uC11D" },
      { id: "security", name: "\uBCF4\uC548 \uAC10\uC0AC" }
    ];
    const chatMessages = ref([]);
    const chatInput = ref("");
    const isLoading = ref(false);
    const terraformForm = reactive({
      cloudProvider: "aws",
      requirements: ""
    });
    const terraformResult = ref(null);
    const isGenerating = ref(false);
    const costForm = reactive({
      cloudProvider: "aws",
      infrastructureDescription: ""
    });
    const costResult = ref(null);
    const isAnalyzing = ref(false);
    const securityForm = reactive({
      cloudProvider: "aws",
      infrastructureDescription: ""
    });
    const securityResult = ref(null);
    const isAuditing = ref(false);
    process.env.MCP_API_KEY || "my_mcp_eagle_tiger";
    const config = useRuntimeConfig();
    config.public.apiBaseUrl;
    const getSecurityScoreLabel = (score) => {
      if (score >= 90) return "\uB9E4\uC6B0 \uC548\uC804";
      if (score >= 80) return "\uC548\uC804";
      if (score >= 70) return "\uBCF4\uD1B5";
      if (score >= 60) return "\uC8FC\uC758 \uD544\uC694";
      return "\uC704\uD5D8";
    };
    chatMessages.value.push({
      id: 1,
      role: "assistant",
      content: "\uC548\uB155\uD558\uC138\uC694! AWS\uC640 GCP \uD074\uB77C\uC6B0\uB4DC \uC804\uBB38\uAC00\uC785\uB2C8\uB2E4. \uC5B4\uB5A4 \uB3C4\uC6C0\uC774 \uD544\uC694\uD558\uC2E0\uAC00\uC694?"
    });
    return (_ctx, _push, _parent, _attrs) => {
      _push(`<div${ssrRenderAttrs(mergeProps({ class: "min-h-screen bg-gray-50 py-8" }, _attrs))} data-v-d121f879><div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8" data-v-d121f879><div class="mb-8" data-v-d121f879><h1 class="text-3xl font-bold text-gray-900" data-v-d121f879>AI \uD074\uB77C\uC6B0\uB4DC \uC5B4\uC2DC\uC2A4\uD134\uD2B8</h1><p class="mt-2 text-gray-600" data-v-d121f879> AWS\uC640 GCP \uD074\uB77C\uC6B0\uB4DC \uC778\uD504\uB77C \uC124\uACC4, \uBE44\uC6A9 \uBD84\uC11D, \uBCF4\uC548 \uAC10\uC0AC\uB97C AI\uC640 \uD568\uAED8 \uC218\uD589\uD558\uC138\uC694 </p></div><div class="mb-6" data-v-d121f879><nav class="flex space-x-8" data-v-d121f879><!--[-->`);
      ssrRenderList(tabs, (tab) => {
        _push(`<button class="${ssrRenderClass([
          activeTab.value === tab.id ? "border-blue-500 text-blue-600" : "border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300",
          "whitespace-nowrap py-2 px-1 border-b-2 font-medium text-sm"
        ])}" data-v-d121f879>${ssrInterpolate(tab.name)}</button>`);
      });
      _push(`<!--]--></nav></div>`);
      if (activeTab.value === "chat") {
        _push(`<div class="bg-white rounded-lg shadow" data-v-d121f879><div class="p-6" data-v-d121f879><h2 class="text-lg font-medium text-gray-900 mb-4" data-v-d121f879>\uD074\uB77C\uC6B0\uB4DC \uC804\uBB38\uAC00\uC640 \uB300\uD654\uD558\uAE30</h2><div class="bg-gray-50 rounded-lg p-4 h-96 overflow-y-auto mb-4" data-v-d121f879><!--[-->`);
        ssrRenderList(chatMessages.value, (message) => {
          _push(`<div class="mb-4" data-v-d121f879><div class="${ssrRenderClass(message.role === "user" ? "text-right" : "text-left")}" data-v-d121f879><div class="${ssrRenderClass([
            message.role === "user" ? "bg-blue-500 text-white ml-auto" : "bg-white text-gray-900",
            "inline-block rounded-lg px-4 py-2 max-w-xs lg:max-w-md shadow-sm"
          ])}" data-v-d121f879><p class="text-sm" data-v-d121f879>${ssrInterpolate(message.content)}</p></div></div></div>`);
        });
        _push(`<!--]-->`);
        if (isLoading.value) {
          _push(`<div class="text-left" data-v-d121f879><div class="bg-white text-gray-900 inline-block rounded-lg px-4 py-2 shadow-sm" data-v-d121f879><div class="flex items-center space-x-2" data-v-d121f879><div class="animate-spin rounded-full h-4 w-4 border-b-2 border-blue-500" data-v-d121f879></div><span class="text-sm" data-v-d121f879>AI\uAC00 \uB2F5\uBCC0\uC744 \uC0DD\uC131\uD558\uACE0 \uC788\uC2B5\uB2C8\uB2E4...</span></div></div></div>`);
        } else {
          _push(`<!---->`);
        }
        _push(`</div><div class="flex space-x-2" data-v-d121f879><input${ssrRenderAttr("value", chatInput.value)} type="text" placeholder="\uD074\uB77C\uC6B0\uB4DC \uAD00\uB828 \uC9C8\uBB38\uC744 \uC785\uB825\uD558\uC138\uC694..." class="flex-1 rounded-lg border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500" data-v-d121f879><button${ssrIncludeBooleanAttr(!chatInput.value.trim() || isLoading.value) ? " disabled" : ""} class="px-4 py-2 bg-blue-500 text-white rounded-lg hover:bg-blue-600 disabled:opacity-50 disabled:cursor-not-allowed" data-v-d121f879> \uC804\uC1A1 </button></div></div></div>`);
      } else {
        _push(`<!---->`);
      }
      if (activeTab.value === "terraform") {
        _push(`<div class="bg-white rounded-lg shadow" data-v-d121f879><div class="p-6" data-v-d121f879><h2 class="text-lg font-medium text-gray-900 mb-4" data-v-d121f879>Terraform \uCF54\uB4DC \uC0DD\uC131</h2><div class="grid grid-cols-1 lg:grid-cols-2 gap-6" data-v-d121f879><div data-v-d121f879><div class="mb-4" data-v-d121f879><label class="block text-sm font-medium text-gray-700 mb-2" data-v-d121f879>\uD074\uB77C\uC6B0\uB4DC \uC81C\uACF5\uC790</label><select class="w-full rounded-lg border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500" data-v-d121f879><option value="aws" data-v-d121f879${ssrIncludeBooleanAttr(Array.isArray(terraformForm.cloudProvider) ? ssrLooseContain(terraformForm.cloudProvider, "aws") : ssrLooseEqual(terraformForm.cloudProvider, "aws")) ? " selected" : ""}>AWS</option><option value="gcp" data-v-d121f879${ssrIncludeBooleanAttr(Array.isArray(terraformForm.cloudProvider) ? ssrLooseContain(terraformForm.cloudProvider, "gcp") : ssrLooseEqual(terraformForm.cloudProvider, "gcp")) ? " selected" : ""}>GCP</option></select></div><div class="mb-4" data-v-d121f879><label class="block text-sm font-medium text-gray-700 mb-2" data-v-d121f879>\uC778\uD504\uB77C \uC694\uAD6C\uC0AC\uD56D</label><textarea rows="6" placeholder="\uC608: 3\uAC1C\uC758 \uAC00\uC6A9\uC601\uC5ED\uC5D0 \uAC78\uCE5C \uACE0\uAC00\uC6A9\uC131 VPC\uB97C \uC0DD\uC131\uD558\uACE0, \uAC01 \uAC00\uC6A9\uC601\uC5ED\uC5D0 public\uACFC private \uC11C\uBE0C\uB137\uC744 \uB9CC\uB4E4\uACE0, NAT Gateway\uB97C \uC124\uC815\uD574\uC8FC\uC138\uC694." class="w-full rounded-lg border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500" data-v-d121f879>${ssrInterpolate(terraformForm.requirements)}</textarea></div><button${ssrIncludeBooleanAttr(!terraformForm.requirements.trim() || isGenerating.value) ? " disabled" : ""} class="w-full px-4 py-2 bg-green-500 text-white rounded-lg hover:bg-green-600 disabled:opacity-50 disabled:cursor-not-allowed" data-v-d121f879>`);
        if (isGenerating.value) {
          _push(`<span data-v-d121f879>\uC0DD\uC131 \uC911...</span>`);
        } else {
          _push(`<span data-v-d121f879>\uCF54\uB4DC \uC0DD\uC131</span>`);
        }
        _push(`</button></div><div data-v-d121f879>`);
        if (terraformResult.value) {
          _push(`<div class="space-y-4" data-v-d121f879><div class="bg-gray-50 rounded-lg p-4" data-v-d121f879><h3 class="font-medium text-gray-900 mb-2" data-v-d121f879>\uC0DD\uC131\uB41C \uCF54\uB4DC</h3><div class="space-y-3" data-v-d121f879><div data-v-d121f879><h4 class="text-sm font-medium text-gray-700" data-v-d121f879>main.tf</h4><pre class="text-xs bg-gray-800 text-green-400 p-2 rounded overflow-x-auto" data-v-d121f879>${ssrInterpolate(terraformResult.value.main_tf)}</pre></div><div data-v-d121f879><h4 class="text-sm font-medium text-gray-700" data-v-d121f879>variables.tf</h4><pre class="text-xs bg-gray-800 text-green-400 p-2 rounded overflow-x-auto" data-v-d121f879>${ssrInterpolate(terraformResult.value.variables_tf)}</pre></div><div data-v-d121f879><h4 class="text-sm font-medium text-gray-700" data-v-d121f879>outputs.tf</h4><pre class="text-xs bg-gray-800 text-green-400 p-2 rounded overflow-x-auto" data-v-d121f879>${ssrInterpolate(terraformResult.value.outputs_tf)}</pre></div></div></div><div class="bg-blue-50 rounded-lg p-4" data-v-d121f879><h3 class="font-medium text-blue-900 mb-2" data-v-d121f879>\uCD94\uAC00 \uC815\uBCF4</h3><div class="text-sm text-blue-800 space-y-2" data-v-d121f879><p data-v-d121f879><strong data-v-d121f879>\uC124\uBA85:</strong> ${ssrInterpolate(terraformResult.value.description)}</p><p data-v-d121f879><strong data-v-d121f879>\uC608\uC0C1 \uBE44\uC6A9:</strong> ${ssrInterpolate(terraformResult.value.estimated_cost)}</p><p data-v-d121f879><strong data-v-d121f879>\uBCF4\uC548 \uC8FC\uC758\uC0AC\uD56D:</strong> ${ssrInterpolate(terraformResult.value.security_notes)}</p><p data-v-d121f879><strong data-v-d121f879>\uBAA8\uBC94 \uC0AC\uB840:</strong> ${ssrInterpolate(terraformResult.value.best_practices)}</p></div></div></div>`);
        } else {
          _push(`<!---->`);
        }
        _push(`</div></div></div></div>`);
      } else {
        _push(`<!---->`);
      }
      if (activeTab.value === "cost") {
        _push(`<div class="bg-white rounded-lg shadow" data-v-d121f879><div class="p-6" data-v-d121f879><h2 class="text-lg font-medium text-gray-900 mb-4" data-v-d121f879>\uC778\uD504\uB77C \uBE44\uC6A9 \uBD84\uC11D</h2><div class="grid grid-cols-1 lg:grid-cols-2 gap-6" data-v-d121f879><div data-v-d121f879><div class="mb-4" data-v-d121f879><label class="block text-sm font-medium text-gray-700 mb-2" data-v-d121f879>\uD074\uB77C\uC6B0\uB4DC \uC81C\uACF5\uC790</label><select class="w-full rounded-lg border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500" data-v-d121f879><option value="aws" data-v-d121f879${ssrIncludeBooleanAttr(Array.isArray(costForm.cloudProvider) ? ssrLooseContain(costForm.cloudProvider, "aws") : ssrLooseEqual(costForm.cloudProvider, "aws")) ? " selected" : ""}>AWS</option><option value="gcp" data-v-d121f879${ssrIncludeBooleanAttr(Array.isArray(costForm.cloudProvider) ? ssrLooseContain(costForm.cloudProvider, "gcp") : ssrLooseEqual(costForm.cloudProvider, "gcp")) ? " selected" : ""}>GCP</option></select></div><div class="mb-4" data-v-d121f879><label class="block text-sm font-medium text-gray-700 mb-2" data-v-d121f879>\uC778\uD504\uB77C \uC124\uBA85</label><textarea rows="6" placeholder="\uC608: 3\uAC1C\uC758 \uAC00\uC6A9\uC601\uC5ED\uC5D0 \uAC78\uCE5C VPC, \uAC01 \uAC00\uC6A9\uC601\uC5ED\uC5D0 public/private \uC11C\uBE0C\uB137, NAT Gateway, 3\uAC1C\uC758 t3.medium EC2 \uC778\uC2A4\uD134\uC2A4, RDS MySQL \uC778\uC2A4\uD134\uC2A4" class="w-full rounded-lg border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500" data-v-d121f879>${ssrInterpolate(costForm.infrastructureDescription)}</textarea></div><button${ssrIncludeBooleanAttr(!costForm.infrastructureDescription.trim() || isAnalyzing.value) ? " disabled" : ""} class="w-full px-4 py-2 bg-purple-500 text-white rounded-lg hover:bg-purple-600 disabled:opacity-50 disabled:cursor-not-allowed" data-v-d121f879>`);
        if (isAnalyzing.value) {
          _push(`<span data-v-d121f879>\uBD84\uC11D \uC911...</span>`);
        } else {
          _push(`<span data-v-d121f879>\uBE44\uC6A9 \uBD84\uC11D</span>`);
        }
        _push(`</button></div><div data-v-d121f879>`);
        if (costResult.value) {
          _push(`<div class="space-y-4" data-v-d121f879><div class="bg-purple-50 rounded-lg p-4" data-v-d121f879><h3 class="font-medium text-purple-900 mb-2" data-v-d121f879>\uBE44\uC6A9 \uBD84\uC11D \uACB0\uACFC</h3><div class="text-sm text-purple-800 space-y-2" data-v-d121f879><p data-v-d121f879><strong data-v-d121f879>\uC608\uC0C1 \uC6D4 \uBE44\uC6A9:</strong> ${ssrInterpolate(costResult.value.estimated_monthly_cost)}</p>`);
          if (costResult.value.cost_breakdown) {
            _push(`<div data-v-d121f879><p class="font-medium" data-v-d121f879>\uBE44\uC6A9 \uC138\uBD80\uC0AC\uD56D:</p><ul class="ml-4 space-y-1" data-v-d121f879><li data-v-d121f879>\uCEF4\uD4E8\uD305: ${ssrInterpolate(costResult.value.cost_breakdown.compute)}</li><li data-v-d121f879>\uC2A4\uD1A0\uB9AC\uC9C0: ${ssrInterpolate(costResult.value.cost_breakdown.storage)}</li><li data-v-d121f879>\uB124\uD2B8\uC6CC\uD06C: ${ssrInterpolate(costResult.value.cost_breakdown.network)}</li><li data-v-d121f879>\uAE30\uD0C0: ${ssrInterpolate(costResult.value.cost_breakdown.other)}</li></ul></div>`);
          } else {
            _push(`<!---->`);
          }
          _push(`</div></div><div class="bg-green-50 rounded-lg p-4" data-v-d121f879><h3 class="font-medium text-green-900 mb-2" data-v-d121f879>\uCD5C\uC801\uD654 \uAE30\uD68C</h3><div class="text-sm text-green-800" data-v-d121f879><ul class="space-y-1" data-v-d121f879><!--[-->`);
          ssrRenderList(costResult.value.optimization_opportunities, (opportunity) => {
            _push(`<li class="flex items-start" data-v-d121f879><span class="text-green-500 mr-2" data-v-d121f879>\u2022</span> ${ssrInterpolate(opportunity)}</li>`);
          });
          _push(`<!--]--></ul></div></div><div class="bg-blue-50 rounded-lg p-4" data-v-d121f879><h3 class="font-medium text-blue-900 mb-2" data-v-d121f879>\uAD8C\uC7A5\uC0AC\uD56D</h3><div class="text-sm text-blue-800 space-y-2" data-v-d121f879>`);
          if (costResult.value.reserved_instances) {
            _push(`<div data-v-d121f879><p class="font-medium" data-v-d121f879>\uC608\uC57D \uC778\uC2A4\uD134\uC2A4:</p><ul class="ml-4 space-y-1" data-v-d121f879><!--[-->`);
            ssrRenderList(costResult.value.reserved_instances, (rec) => {
              _push(`<li class="flex items-start" data-v-d121f879><span class="text-blue-500 mr-2" data-v-d121f879>\u2022</span> ${ssrInterpolate(rec)}</li>`);
            });
            _push(`<!--]--></ul></div>`);
          } else {
            _push(`<!---->`);
          }
          _push(`</div></div></div>`);
        } else {
          _push(`<!---->`);
        }
        _push(`</div></div></div></div>`);
      } else {
        _push(`<!---->`);
      }
      if (activeTab.value === "security") {
        _push(`<div class="bg-white rounded-lg shadow" data-v-d121f879><div class="p-6" data-v-d121f879><h2 class="text-lg font-medium text-gray-900 mb-4" data-v-d121f879>\uC778\uD504\uB77C \uBCF4\uC548 \uAC10\uC0AC</h2><div class="grid grid-cols-1 lg:grid-cols-2 gap-6" data-v-d121f879><div data-v-d121f879><div class="mb-4" data-v-d121f879><label class="block text-sm font-medium text-gray-700 mb-2" data-v-d121f879>\uD074\uB77C\uC6B0\uB4DC \uC81C\uACF5\uC790</label><select class="w-full rounded-lg border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500" data-v-d121f879><option value="aws" data-v-d121f879${ssrIncludeBooleanAttr(Array.isArray(securityForm.cloudProvider) ? ssrLooseContain(securityForm.cloudProvider, "aws") : ssrLooseEqual(securityForm.cloudProvider, "aws")) ? " selected" : ""}>AWS</option><option value="gcp" data-v-d121f879${ssrIncludeBooleanAttr(Array.isArray(securityForm.cloudProvider) ? ssrLooseContain(securityForm.cloudProvider, "gcp") : ssrLooseEqual(securityForm.cloudProvider, "gcp")) ? " selected" : ""}>GCP</option></select></div><div class="mb-4" data-v-d121f879><label class="block text-sm font-medium text-gray-700 mb-2" data-v-d121f879>\uC778\uD504\uB77C \uC124\uBA85</label><textarea rows="6" placeholder="\uC608: 3\uAC1C\uC758 \uAC00\uC6A9\uC601\uC5ED\uC5D0 \uAC78\uCE5C VPC, \uAC01 \uAC00\uC6A9\uC601\uC5ED\uC5D0 public/private \uC11C\uBE0C\uB137, NAT Gateway, 3\uAC1C\uC758 t3.medium EC2 \uC778\uC2A4\uD134\uC2A4, RDS MySQL \uC778\uC2A4\uD134\uC2A4" class="w-full rounded-lg border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500" data-v-d121f879>${ssrInterpolate(securityForm.infrastructureDescription)}</textarea></div><button${ssrIncludeBooleanAttr(!securityForm.infrastructureDescription.trim() || isAuditing.value) ? " disabled" : ""} class="w-full px-4 py-2 bg-red-500 text-white rounded-lg hover:bg-red-600 disabled:opacity-50 disabled:cursor-not-allowed" data-v-d121f879>`);
        if (isAuditing.value) {
          _push(`<span data-v-d121f879>\uAC10\uC0AC \uC911...</span>`);
        } else {
          _push(`<span data-v-d121f879>\uBCF4\uC548 \uAC10\uC0AC</span>`);
        }
        _push(`</button></div><div data-v-d121f879>`);
        if (securityResult.value) {
          _push(`<div class="space-y-4" data-v-d121f879><div class="bg-red-50 rounded-lg p-4" data-v-d121f879><h3 class="font-medium text-red-900 mb-2" data-v-d121f879>\uBCF4\uC548 \uC810\uC218</h3><div class="text-center" data-v-d121f879><div class="text-3xl font-bold text-red-600" data-v-d121f879>${ssrInterpolate(securityResult.value.security_score)}/100</div><div class="text-sm text-red-700 mt-1" data-v-d121f879>${ssrInterpolate(getSecurityScoreLabel(securityResult.value.security_score))}</div></div></div>`);
          if (securityResult.value.critical_issues && securityResult.value.critical_issues.length > 0) {
            _push(`<div class="bg-red-100 rounded-lg p-4" data-v-d121f879><h3 class="font-medium text-red-900 mb-2" data-v-d121f879>\uCE58\uBA85\uC801 \uBCF4\uC548 \uC774\uC288</h3><ul class="text-sm text-red-800 space-y-1" data-v-d121f879><!--[-->`);
            ssrRenderList(securityResult.value.critical_issues, (issue) => {
              _push(`<li class="flex items-start" data-v-d121f879><span class="text-red-500 mr-2" data-v-d121f879>\u26A0\uFE0F</span> ${ssrInterpolate(issue)}</li>`);
            });
            _push(`<!--]--></ul></div>`);
          } else {
            _push(`<!---->`);
          }
          if (securityResult.value.high_risk_issues && securityResult.value.high_risk_issues.length > 0) {
            _push(`<div class="bg-orange-100 rounded-lg p-4" data-v-d121f879><h3 class="font-medium text-orange-900 mb-2" data-v-d121f879>\uB192\uC740 \uC704\uD5D8\uB3C4 \uC774\uC288</h3><ul class="text-sm text-orange-800 space-y-1" data-v-d121f879><!--[-->`);
            ssrRenderList(securityResult.value.high_risk_issues, (issue) => {
              _push(`<li class="flex items-start" data-v-d121f879><span class="text-orange-500 mr-2" data-v-d121f879>\u26A0\uFE0F</span> ${ssrInterpolate(issue)}</li>`);
            });
            _push(`<!--]--></ul></div>`);
          } else {
            _push(`<!---->`);
          }
          _push(`<div class="bg-blue-50 rounded-lg p-4" data-v-d121f879><h3 class="font-medium text-blue-900 mb-2" data-v-d121f879>\uBCF4\uC548 \uAD8C\uC7A5\uC0AC\uD56D</h3><div class="text-sm text-blue-800" data-v-d121f879><ul class="space-y-1" data-v-d121f879><!--[-->`);
          ssrRenderList(securityResult.value.security_recommendations, (rec) => {
            _push(`<li class="flex items-start" data-v-d121f879><span class="text-blue-500 mr-2" data-v-d121f879>\u2022</span> ${ssrInterpolate(rec)}</li>`);
          });
          _push(`<!--]--></ul></div></div></div>`);
        } else {
          _push(`<!---->`);
        }
        _push(`</div></div></div></div>`);
      } else {
        _push(`<!---->`);
      }
      _push(`</div></div>`);
    };
  }
};
const _sfc_setup = _sfc_main.setup;
_sfc_main.setup = (props, ctx) => {
  const ssrContext = useSSRContext();
  (ssrContext.modules || (ssrContext.modules = /* @__PURE__ */ new Set())).add("pages/ai-assistant.vue");
  return _sfc_setup ? _sfc_setup(props, ctx) : void 0;
};
const aiAssistant = /* @__PURE__ */ _export_sfc(_sfc_main, [["__scopeId", "data-v-d121f879"]]);

export { aiAssistant as default };
//# sourceMappingURL=ai-assistant-C_NE6dC5.mjs.map
