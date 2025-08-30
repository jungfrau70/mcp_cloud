import { _ as __nuxt_component_0 } from './nuxt-link-BoT4h8Q2.mjs';
import { mergeProps, withCtx, createTextVNode, useSSRContext } from 'vue';
import { ssrRenderAttrs, ssrRenderComponent } from 'vue/server-renderer';
import '../nitro/nitro.mjs';
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
import 'pinia';

const _sfc_main = {
  __name: "login",
  __ssrInlineRender: true,
  setup(__props) {
    return (_ctx, _push, _parent, _attrs) => {
      const _component_NuxtLink = __nuxt_component_0;
      _push(`<div${ssrRenderAttrs(mergeProps({ class: "min-h-screen flex items-center justify-center p-6" }, _attrs))}><div class="w-full max-w-sm bg-white border rounded-lg p-6 shadow-sm"><h1 class="text-xl font-semibold mb-4">\uB85C\uADF8\uC778</h1><p class="text-sm text-gray-600">\uD604\uC7AC\uB294 \uC778\uC99D\uC744 \uC0AC\uC6A9\uD558\uC9C0 \uC54A\uC2B5\uB2C8\uB2E4. \uD648\uC73C\uB85C \uC774\uB3D9\uD558\uC138\uC694.</p><div class="mt-4">`);
      _push(ssrRenderComponent(_component_NuxtLink, {
        to: "/",
        class: "px-4 py-2 bg-blue-600 text-white rounded"
      }, {
        default: withCtx((_, _push2, _parent2, _scopeId) => {
          if (_push2) {
            _push2(`\uD648\uC73C\uB85C`);
          } else {
            return [
              createTextVNode("\uD648\uC73C\uB85C")
            ];
          }
        }),
        _: 1
      }, _parent));
      _push(`</div></div></div>`);
    };
  }
};
const _sfc_setup = _sfc_main.setup;
_sfc_main.setup = (props, ctx) => {
  const ssrContext = useSSRContext();
  (ssrContext.modules || (ssrContext.modules = /* @__PURE__ */ new Set())).add("pages/login.vue");
  return _sfc_setup ? _sfc_setup(props, ctx) : void 0;
};

export { _sfc_main as default };
//# sourceMappingURL=login-DA-fY3L4.mjs.map
