import { _ as __nuxt_component_0 } from './client-only-D-BZfu7n.mjs';
import { ref, watch, mergeProps, unref, useSSRContext } from 'vue';
import { ssrRenderAttrs, ssrRenderAttr, ssrRenderList, ssrRenderClass, ssrInterpolate, ssrRenderComponent } from 'vue/server-renderer';

const _sfc_main = {
  __name: "index",
  __ssrInlineRender: true,
  setup(__props) {
    const searchQuery = ref("");
    const selectedCategory = ref("all");
    const selectedDoc = ref(null);
    const categories = ref([
      { id: "all", name: "\uC804\uCCB4", count: 25 },
      { id: "aws", name: "AWS", count: 8 },
      { id: "gcp", name: "GCP", count: 7 },
      { id: "azure", name: "Azure", count: 5 },
      { id: "terraform", name: "Terraform", count: 3 },
      { id: "best-practices", name: "\uBAA8\uBC94 \uC0AC\uB840", count: 2 }
    ]);
    const recentDocs = ref([
      { id: 1, title: "AWS VPC \uAD6C\uC131 \uAC00\uC774\uB4DC", category: "aws", content: "<p>AWS VPC\uB97C \uAD6C\uC131\uD558\uB294 \uBC29\uBC95\uC5D0 \uB300\uD55C \uC0C1\uC138\uD55C \uAC00\uC774\uB4DC\uC785\uB2C8\uB2E4.</p>" },
      { id: 2, title: "GCP GKE \uD074\uB7EC\uC2A4\uD130 \uC124\uC815", category: "gcp", content: "<p>Google Kubernetes Engine \uD074\uB7EC\uC2A4\uD130\uB97C \uC124\uC815\uD558\uB294 \uBC29\uBC95\uC744 \uC124\uBA85\uD569\uB2C8\uB2E4.</p>" },
      { id: 3, title: "Terraform \uBAA8\uB4C8 \uC791\uC131\uBC95", category: "terraform", content: "<p>Terraform \uBAA8\uB4C8\uC744 \uC791\uC131\uD558\uACE0 \uC7AC\uC0AC\uC6A9\uD558\uB294 \uBC29\uBC95\uC744 \uC54C\uC544\uBD05\uB2C8\uB2E4.</p>" },
      { id: 4, title: "\uD074\uB77C\uC6B0\uB4DC \uBCF4\uC548 \uCCB4\uD06C\uB9AC\uC2A4\uD2B8", category: "best-practices", content: "<p>\uD074\uB77C\uC6B0\uB4DC \uD658\uACBD\uC5D0\uC11C \uBCF4\uC548\uC744 \uAC15\uD654\uD558\uAE30 \uC704\uD55C \uCCB4\uD06C\uB9AC\uC2A4\uD2B8\uC785\uB2C8\uB2E4.</p>" }
    ]);
    const relatedDocs = ref([
      { id: 5, title: "AWS EC2 \uC778\uC2A4\uD134\uC2A4 \uC0DD\uC131", category: "aws", excerpt: "EC2 \uC778\uC2A4\uD134\uC2A4\uB97C \uC0DD\uC131\uD558\uACE0 \uAD6C\uC131\uD558\uB294 \uBC29\uBC95\uC744 \uC54C\uC544\uBD05\uB2C8\uB2E4." },
      { id: 6, title: "GCP Cloud Storage \uC124\uC815", category: "gcp", excerpt: "Cloud Storage \uBC84\uD0B7\uC744 \uC0DD\uC131\uD558\uACE0 \uAD8C\uD55C\uC744 \uC124\uC815\uD558\uB294 \uBC29\uBC95\uC785\uB2C8\uB2E4." }
    ]);
    watch(searchQuery, (newQuery) => {
      if (newQuery.length > 2) {
        console.log("Searching for:", newQuery);
      }
    });
    return (_ctx, _push, _parent, _attrs) => {
      var _a;
      const _component_ClientOnly = __nuxt_component_0;
      _push(`<div${ssrRenderAttrs(mergeProps({ class: "px-4 sm:px-6 lg:px-8" }, _attrs))}><div class="mb-8"><h1 class="text-3xl font-bold text-gray-900">\uC9C0\uC2DD\uBCA0\uC774\uC2A4</h1><p class="mt-2 text-gray-600"> MCP \uD074\uB77C\uC6B0\uB4DC \uD50C\uB7AB\uD3FC\uC758 \uBAA8\uB4E0 \uC9C0\uC2DD\uACFC \uAC00\uC774\uB4DC\uB97C \uD0D0\uC0C9\uD558\uC138\uC694. </p></div><div class="grid grid-cols-1 lg:grid-cols-4 gap-6"><div class="lg:col-span-1"><div class="bg-white rounded-lg shadow p-6 sticky top-6"><div class="mb-6"><label for="search" class="block text-sm font-medium text-gray-700 mb-2"> \uAC80\uC0C9 </label><input id="search"${ssrRenderAttr("value", unref(searchQuery))} type="text" placeholder="\uC9C0\uC2DD \uAC80\uC0C9..." class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-transparent"></div><div class="mb-6"><h3 class="text-lg font-medium text-gray-900 mb-3">\uCE74\uD14C\uACE0\uB9AC</h3><div class="space-y-2"><!--[-->`);
      ssrRenderList(unref(categories), (category) => {
        _push(`<button class="${ssrRenderClass([
          "w-full text-left px-3 py-2 rounded-md text-sm transition-colors",
          unref(selectedCategory) === category.id ? "bg-primary-100 text-primary-700" : "text-gray-600 hover:bg-gray-100"
        ])}">${ssrInterpolate(category.name)} <span class="ml-2 text-xs text-gray-400">(${ssrInterpolate(category.count)})</span></button>`);
      });
      _push(`<!--]--></div></div><div><h3 class="text-lg font-medium text-gray-900 mb-3">\uCD5C\uADFC \uBB38\uC11C</h3><div class="space-y-2"><!--[-->`);
      ssrRenderList(unref(recentDocs), (doc) => {
        _push(`<button class="w-full text-left px-3 py-2 rounded-md text-sm text-gray-600 hover:bg-gray-100 transition-colors">${ssrInterpolate(doc.title)}</button>`);
      });
      _push(`<!--]--></div></div></div></div><div class="lg:col-span-3"><div class="bg-white rounded-lg shadow"><div class="p-6">`);
      if (unref(selectedDoc)) {
        _push(`<div class="prose max-w-none"><h1 class="text-2xl font-bold text-gray-900 mb-4">${ssrInterpolate(unref(selectedDoc).title)}</h1><div class="flex items-center text-sm text-gray-500 mb-6"><span>\uCE74\uD14C\uACE0\uB9AC: ${ssrInterpolate(unref(selectedDoc).category)}</span><span class="mx-2">\u2022</span><span>\uCD5C\uC885 \uC218\uC815: ${ssrInterpolate(unref(selectedDoc).updatedAt || "\uCD5C\uADFC")}</span></div><div>${(_a = unref(selectedDoc).content) != null ? _a : ""}</div><div class="mt-8 pt-6 border-t border-gray-200"><h3 class="text-lg font-medium text-gray-900 mb-3">\uAD00\uB828 \uBB38\uC11C</h3><div class="grid grid-cols-1 md:grid-cols-2 gap-4"><!--[-->`);
        ssrRenderList(unref(relatedDocs), (related) => {
          _push(`<div class="p-4 border border-gray-200 rounded-lg hover:border-primary-300 cursor-pointer transition-colors"><h4 class="font-medium text-gray-900">${ssrInterpolate(related.title)}</h4><p class="text-sm text-gray-600 mt-1">${ssrInterpolate(related.excerpt)}</p></div>`);
        });
        _push(`<!--]--></div></div></div>`);
      } else {
        _push(`<div class="text-center py-12"><svg class="mx-auto h-12 w-12 text-gray-400" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"></path></svg><h3 class="mt-2 text-sm font-medium text-gray-900">\uBB38\uC11C\uB97C \uC120\uD0DD\uD558\uC138\uC694</h3><p class="mt-1 text-sm text-gray-500"> \uC67C\uCABD \uC0AC\uC774\uB4DC\uBC14\uC5D0\uC11C \uCE74\uD14C\uACE0\uB9AC\uB098 \uAC80\uC0C9\uC744 \uD1B5\uD574 \uC6D0\uD558\uB294 \uBB38\uC11C\uB97C \uCC3E\uC544\uBCF4\uC138\uC694. </p></div>`);
      }
      _push(`</div></div></div></div>`);
      _push(ssrRenderComponent(_component_ClientOnly, null, {}, _parent));
      _push(`</div>`);
    };
  }
};
const _sfc_setup = _sfc_main.setup;
_sfc_main.setup = (props, ctx) => {
  const ssrContext = useSSRContext();
  (ssrContext.modules || (ssrContext.modules = /* @__PURE__ */ new Set())).add("pages/knowledge-base/index.vue");
  return _sfc_setup ? _sfc_setup(props, ctx) : void 0;
};

export { _sfc_main as default };
//# sourceMappingURL=index-BWSX7Mvm.mjs.map
