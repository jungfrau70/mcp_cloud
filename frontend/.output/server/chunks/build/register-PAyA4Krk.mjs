import { _ as __nuxt_component_0 } from './nuxt-link-DnuW-ndg.mjs';
import { defineComponent, ref, mergeProps, withCtx, createTextVNode, useSSRContext } from 'vue';
import { ssrRenderAttrs, ssrRenderComponent, ssrRenderAttr, ssrInterpolate } from 'vue/server-renderer';
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
  __name: "register",
  __ssrInlineRender: true,
  setup(__props) {
    const email = ref("");
    const password = ref("");
    const passwordConfirm = ref("");
    const fullName = ref("");
    const error = ref("");
    const done = ref(false);
    useRouter();
    const auth = useAuthStore();
    auth.loadFromStorage();
    return (_ctx, _push, _parent, _attrs) => {
      const _component_NuxtLink = __nuxt_component_0;
      _push(`<div${ssrRenderAttrs(mergeProps({ class: "max-w-md mx-auto mt-16 bg-white p-6 rounded shadow" }, _attrs))}><h1 class="text-xl font-semibold mb-4">\uD68C\uC6D0\uAC00\uC785</h1>`);
      if (done.value) {
        _push(`<div class="space-y-4"><div class="p-4 rounded border bg-gray-50 text-sm text-gray-700"> \uAC00\uC785\uC774 \uC811\uC218\uB418\uC5C8\uC2B5\uB2C8\uB2E4. \uC774\uBA54\uC77C\uB85C \uC778\uC99D \uB9C1\uD06C\uB97C \uBCF4\uB0C8\uC2B5\uB2C8\uB2E4.<br> \uBC1B\uC740 \uD3B8\uC9C0\uD568(\uB610\uB294 \uC2A4\uD338\uD568)\uC744 \uD655\uC778\uD558\uACE0 \uB9C1\uD06C\uB97C \uD074\uB9AD\uD574 \uC778\uC99D\uC744 \uC644\uB8CC\uD574 \uC8FC\uC138\uC694. </div><div class="flex gap-2">`);
        _push(ssrRenderComponent(_component_NuxtLink, {
          to: "/login",
          class: "flex-1 text-center px-4 py-2 rounded bg-black text-white"
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
        _push(`<a href="https://mail.google.com/" target="_blank" class="flex-1 text-center px-4 py-2 rounded border">Gmail \uC5F4\uAE30</a></div></div>`);
      } else {
        _push(`<form class="space-y-4"><div><label class="block text-sm mb-1">\uC774\uBA54\uC77C</label><input${ssrRenderAttr("value", email.value)} type="email" class="w-full border rounded px-3 py-2" required></div><div><label class="block text-sm mb-1">\uC774\uB984(\uC120\uD0DD)</label><input${ssrRenderAttr("value", fullName.value)} type="text" class="w-full border rounded px-3 py-2"></div><div><label class="block text-sm mb-1">\uBE44\uBC00\uBC88\uD638</label><input${ssrRenderAttr("value", password.value)} type="password" class="w-full border rounded px-3 py-2" required></div><div><label class="block text-sm mb-1">\uBE44\uBC00\uBC88\uD638 \uD655\uC778</label><input${ssrRenderAttr("value", passwordConfirm.value)} type="password" class="w-full border rounded px-3 py-2" required></div>`);
        if (error.value) {
          _push(`<p class="text-sm text-red-600">${ssrInterpolate(error.value)}</p>`);
        } else {
          _push(`<!---->`);
        }
        _push(`<button type="submit" class="w-full bg-black text-white py-2 rounded">\uD68C\uC6D0\uAC00\uC785</button><p class="text-xs text-gray-500">\uAC00\uC785 \uD6C4 \uC774\uBA54\uC77C \uC778\uC99D\uC744 \uC644\uB8CC\uD574\uC57C \uB85C\uADF8\uC778\uD560 \uC218 \uC788\uC2B5\uB2C8\uB2E4.</p></form>`);
      }
      if (!done.value) {
        _push(`<p class="text-sm mt-4 text-gray-600">\uC774\uBBF8 \uACC4\uC815\uC774 \uC788\uB098\uC694? `);
        _push(ssrRenderComponent(_component_NuxtLink, {
          class: "text-blue-600",
          to: "/login"
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
        _push(`</p>`);
      } else {
        _push(`<!---->`);
      }
      _push(`</div>`);
    };
  }
});
const _sfc_setup = _sfc_main.setup;
_sfc_main.setup = (props, ctx) => {
  const ssrContext = useSSRContext();
  (ssrContext.modules || (ssrContext.modules = /* @__PURE__ */ new Set())).add("pages/register.vue");
  return _sfc_setup ? _sfc_setup(props, ctx) : void 0;
};

export { _sfc_main as default };
//# sourceMappingURL=register-PAyA4Krk.mjs.map
