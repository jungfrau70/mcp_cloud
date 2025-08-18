import { _ as __nuxt_component_0 } from './nuxt-link-DuKmAlAX.mjs';
import { mergeProps, withCtx, createTextVNode, useSSRContext } from 'vue';
import { ssrRenderAttrs, ssrRenderComponent } from 'vue/server-renderer';
import '../_/nitro.mjs';
import 'node:http';
import 'node:https';
import 'node:events';
import 'node:buffer';
import 'node:fs';
import 'node:path';
import 'node:crypto';
import 'node:url';
import './server.mjs';
import '../routes/renderer.mjs';
import 'vue-bundle-renderer/runtime';
import 'unhead/server';
import 'devalue';
import 'unhead/utils';
import 'unhead/plugins';
import 'vue-router';

const _sfc_main = {
  __name: "index",
  __ssrInlineRender: true,
  setup(__props) {
    return (_ctx, _push, _parent, _attrs) => {
      const _component_NuxtLink = __nuxt_component_0;
      _push(`<div${ssrRenderAttrs(mergeProps({ class: "h-full flex flex-col items-center justify-center p-4" }, _attrs))}><h1 class="text-4xl font-bold text-gray-900 mb-4">Welcome to MCP Cloud Platform</h1><p class="text-lg text-gray-600 mb-8">Your integrated learning and management environment.</p><div class="space-x-4">`);
      _push(ssrRenderComponent(_component_NuxtLink, {
        to: "/knowledge-base",
        class: "px-6 py-3 bg-blue-600 text-white rounded-lg shadow hover:bg-blue-700"
      }, {
        default: withCtx((_, _push2, _parent2, _scopeId) => {
          if (_push2) {
            _push2(` Start Learning `);
          } else {
            return [
              createTextVNode(" Start Learning ")
            ];
          }
        }),
        _: 1
      }, _parent));
      _push(ssrRenderComponent(_component_NuxtLink, {
        to: "/datasources",
        class: "px-6 py-3 bg-gray-200 text-gray-800 rounded-lg shadow hover:bg-gray-300"
      }, {
        default: withCtx((_, _push2, _parent2, _scopeId) => {
          if (_push2) {
            _push2(` Explore Data Sources `);
          } else {
            return [
              createTextVNode(" Explore Data Sources ")
            ];
          }
        }),
        _: 1
      }, _parent));
      _push(`</div></div>`);
    };
  }
};
const _sfc_setup = _sfc_main.setup;
_sfc_main.setup = (props, ctx) => {
  const ssrContext = useSSRContext();
  (ssrContext.modules || (ssrContext.modules = /* @__PURE__ */ new Set())).add("pages/index.vue");
  return _sfc_setup ? _sfc_setup(props, ctx) : void 0;
};

export { _sfc_main as default };
//# sourceMappingURL=index-Bwegcp5z.mjs.map
