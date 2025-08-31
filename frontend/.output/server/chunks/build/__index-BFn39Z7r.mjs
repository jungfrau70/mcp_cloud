import { defineComponent, ref, mergeProps, useSSRContext } from 'vue';
import { ssrRenderAttrs, ssrRenderComponent } from 'vue/server-renderer';
import { _ as _sfc_main$1 } from './KnowledgeBaseExplorer-C5yiN_9k.mjs';
import './server.mjs';
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
import './_plugin-vue_export-helper-1tPrXgE0.mjs';

const _sfc_main = /* @__PURE__ */ defineComponent({
  __name: "__index",
  __ssrInlineRender: true,
  setup(__props) {
    const loading = ref(true);
    const isAdmin = ref(false);
    return (_ctx, _push, _parent, _attrs) => {
      _push(`<div${ssrRenderAttrs(mergeProps({ class: "p-6 h-full w-full" }, _attrs))}><h1 class="text-xl font-semibold mb-2">\uC9C0\uC2DD\uBCA0\uC774\uC2A4</h1>`);
      if (loading.value) {
        _push(`<p>Loading...</p>`);
      } else if (!isAdmin.value) {
        _push(`<p class="text-red-600">\uAD00\uB9AC\uC790 \uC804\uC6A9 \uD398\uC774\uC9C0\uC785\uB2C8\uB2E4.</p>`);
      } else {
        _push(`<div class="h-full w-full">`);
        _push(ssrRenderComponent(_sfc_main$1, { mode: "full" }, null, _parent));
        _push(`</div>`);
      }
      _push(`</div>`);
    };
  }
});
const _sfc_setup = _sfc_main.setup;
_sfc_main.setup = (props, ctx) => {
  const ssrContext = useSSRContext();
  (ssrContext.modules || (ssrContext.modules = /* @__PURE__ */ new Set())).add("pages/knowledge-base/__index.vue");
  return _sfc_setup ? _sfc_setup(props, ctx) : void 0;
};

export { _sfc_main as default };
//# sourceMappingURL=__index-BFn39Z7r.mjs.map
