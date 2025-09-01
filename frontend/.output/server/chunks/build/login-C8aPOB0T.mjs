import { _ as __nuxt_component_0 } from './nuxt-link-DnuW-ndg.mjs';
import { defineComponent, ref, mergeProps, withCtx, createTextVNode, useSSRContext } from 'vue';
import { ssrRenderAttrs, ssrRenderAttr, ssrInterpolate, ssrIncludeBooleanAttr, ssrRenderComponent } from 'vue/server-renderer';
import { useRouter } from 'vue-router';
import { u as useAuthStore } from './auth-D2H_Myyg.mjs';
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
import 'pinia';

const _sfc_main = /* @__PURE__ */ defineComponent({
  __name: "login",
  __ssrInlineRender: true,
  setup(__props) {
    const email = ref("");
    const password = ref("");
    useRouter();
    useAuthStore();
    const showVerifyNotice = ref(false);
    const sending = ref(false);
    return (_ctx, _push, _parent, _attrs) => {
      const _component_NuxtLink = __nuxt_component_0;
      _push(`<div${ssrRenderAttrs(mergeProps({ class: "max-w-md mx-auto mt-16 bg-white p-6 rounded shadow" }, _attrs))}><h1 class="text-xl font-semibold mb-4">\uB85C\uADF8\uC778</h1><form class="space-y-4"><div><label class="block text-sm mb-1">\uC774\uBA54\uC77C</label><input${ssrRenderAttr("value", email.value)} type="email" class="w-full border rounded px-3 py-2" required></div><div><label class="block text-sm mb-1">\uBE44\uBC00\uBC88\uD638</label><input${ssrRenderAttr("value", password.value)} type="password" class="w-full border rounded px-3 py-2" required></div><button type="submit" class="w-full bg-black text-white py-2 rounded">\uB85C\uADF8\uC778</button></form>`);
      if (showVerifyNotice.value) {
        _push(`<div class="mt-4 p-3 rounded border border-amber-300 bg-amber-50 text-amber-800 text-sm"> \uC774\uBA54\uC77C \uC778\uC99D\uC774 \uD544\uC694\uD569\uB2C8\uB2E4. \uBC1B\uC740 \uBA54\uC77C\uC758 \uB9C1\uD06C\uB97C \uD074\uB9AD\uD558\uAC70\uB098, <button class="ml-1 underline"${ssrIncludeBooleanAttr(sending.value) ? " disabled" : ""}>${ssrInterpolate(sending.value ? "\uC7AC\uC804\uC1A1 \uC911..." : "\uC778\uC99D \uBA54\uC77C \uC7AC\uC804\uC1A1")}</button></div>`);
      } else {
        _push(`<!---->`);
      }
      _push(`<p class="text-sm mt-4 text-gray-600">\uACC4\uC815\uC774 \uC5C6\uB098\uC694? `);
      _push(ssrRenderComponent(_component_NuxtLink, {
        class: "text-blue-600",
        to: "/register"
      }, {
        default: withCtx((_, _push2, _parent2, _scopeId) => {
          if (_push2) {
            _push2(`\uD68C\uC6D0\uAC00\uC785`);
          } else {
            return [
              createTextVNode("\uD68C\uC6D0\uAC00\uC785")
            ];
          }
        }),
        _: 1
      }, _parent));
      _push(`</p></div>`);
    };
  }
});
const _sfc_setup = _sfc_main.setup;
_sfc_main.setup = (props, ctx) => {
  const ssrContext = useSSRContext();
  (ssrContext.modules || (ssrContext.modules = /* @__PURE__ */ new Set())).add("pages/login.vue");
  return _sfc_setup ? _sfc_setup(props, ctx) : void 0;
};

export { _sfc_main as default };
//# sourceMappingURL=login-C8aPOB0T.mjs.map
