import { _ as __nuxt_component_0 } from './nuxt-link-DynZTYcZ.mjs';
import { defineComponent, ref, mergeProps, withCtx, createTextVNode, useSSRContext } from 'vue';
import { ssrRenderAttrs, ssrRenderComponent } from 'vue/server-renderer';
import { a as useRoute } from './server.mjs';
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

const _sfc_main = /* @__PURE__ */ defineComponent({
  __name: "verify-email",
  __ssrInlineRender: true,
  setup(__props) {
    useRoute();
    const status = ref("pending");
    return (_ctx, _push, _parent, _attrs) => {
      const _component_NuxtLink = __nuxt_component_0;
      _push(`<div${ssrRenderAttrs(mergeProps({ class: "max-w-md mx-auto mt-16 bg-white p-6 rounded shadow text-center" }, _attrs))}><h1 class="text-xl font-semibold mb-4">\uC774\uBA54\uC77C \uC778\uC99D</h1>`);
      if (status.value === "pending") {
        _push(`<div class="text-gray-600">\uC778\uC99D \uC911\uC785\uB2C8\uB2E4...</div>`);
      } else if (status.value === "success") {
        _push(`<div class="text-green-700">\uC778\uC99D\uC774 \uC644\uB8CC\uB418\uC5C8\uC2B5\uB2C8\uB2E4. \uC774\uC81C \uB85C\uADF8\uC778\uD560 \uC218 \uC788\uC2B5\uB2C8\uB2E4.</div>`);
      } else {
        _push(`<div class="text-red-700">\uC778\uC99D \uB9C1\uD06C\uAC00 \uC720\uD6A8\uD558\uC9C0 \uC54A\uAC70\uB098 \uB9CC\uB8CC\uB418\uC5C8\uC2B5\uB2C8\uB2E4.</div>`);
      }
      _push(`<div class="mt-6 flex justify-center gap-4">`);
      _push(ssrRenderComponent(_component_NuxtLink, {
        to: "/login",
        class: "px-4 py-2 bg-black text-white rounded"
      }, {
        default: withCtx((_, _push2, _parent2, _scopeId) => {
          if (_push2) {
            _push2(`\uB85C\uADF8\uC778`);
          } else {
            return [
              createTextVNode("\uB85C\uADF8\uC778")
            ];
          }
        }),
        _: 1
      }, _parent));
      _push(ssrRenderComponent(_component_NuxtLink, {
        to: "/",
        class: "px-4 py-2 bg-gray-200 rounded"
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
      _push(`</div></div>`);
    };
  }
});
const _sfc_setup = _sfc_main.setup;
_sfc_main.setup = (props, ctx) => {
  const ssrContext = useSSRContext();
  (ssrContext.modules || (ssrContext.modules = /* @__PURE__ */ new Set())).add("pages/verify-email.vue");
  return _sfc_setup ? _sfc_setup(props, ctx) : void 0;
};

export { _sfc_main as default };
//# sourceMappingURL=verify-email-DBVtZaiU.mjs.map
