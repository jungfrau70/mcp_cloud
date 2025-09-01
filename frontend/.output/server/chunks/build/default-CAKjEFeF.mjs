import { _ as __nuxt_component_0$1 } from './nuxt-link-DnuW-ndg.mjs';
import { defineComponent, createElementBlock, shallowRef, getCurrentInstance, provide, cloneVNode, h, ref, watch, computed, mergeProps, unref, withCtx, createTextVNode, toRef, isRef, defineAsyncComponent, toValue, reactive, withDirectives, createVNode, createBlock, createCommentVNode, vModelText, openBlock, toDisplayString, onServerPrefetch, nextTick, useSSRContext } from 'vue';
import { ssrRenderAttrs, ssrRenderComponent, ssrRenderAttr, ssrInterpolate, ssrRenderStyle, ssrRenderClass, ssrIncludeBooleanAttr, ssrRenderSlot, ssrRenderList, ssrLooseContain, ssrLooseEqual } from 'vue/server-renderer';
import { useRoute, useRouter } from 'vue-router';
import { u as useRuntimeConfig, b as useNuxtApp, f as fetchDefaults, c as asyncDataDefaults, d as createError } from './server.mjs';
import { q as hash } from '../nitro/nitro.mjs';
import { isPlainObject } from '@vue/shared';
import { debounce } from 'perfect-debounce';
import { u as useAuthStore } from './auth-D2H_Myyg.mjs';
import { u as useToastStore, _ as _sfc_main$9, a as useKbApi, b as _sfc_main$4$1, r as resolveApiBase } from './KnowledgeBaseExplorer-BPhUR6EE.mjs';
import { _ as _sfc_main$a, e as embed } from './ContentView-BvDwlwCj.mjs';
import { marked } from 'marked';
import DOMPurify from 'dompurify';
import mermaid from 'mermaid';
import { defineStore, storeToRefs } from 'pinia';
import { _ as _export_sfc } from './_plugin-vue_export-helper-1tPrXgE0.mjs';
import '../routes/renderer.mjs';
import 'vue-bundle-renderer/runtime';
import 'unhead/server';
import 'devalue';
import 'unhead/utils';
import 'unhead/plugins';
import 'node:http';
import 'node:https';
import 'node:events';
import 'node:buffer';
import 'node:fs';
import 'node:path';
import 'node:crypto';
import 'node:url';
import 'json-stringify-pretty-compact';
import 'vega';
import 'vega-interpreter';
import 'vega-lite';
import 'vega-schema-url-parser';
import 'vega-themes';
import 'vega-tooltip';

const __nuxt_component_1 = defineComponent({
  name: "ServerPlaceholder",
  render() {
    return createElementBlock("div");
  }
});
const clientOnlySymbol = Symbol.for("nuxt:client-only");
const __nuxt_component_0 = defineComponent({
  name: "ClientOnly",
  inheritAttrs: false,
  props: ["fallback", "placeholder", "placeholderTag", "fallbackTag"],
  ...false,
  setup(props, { slots, attrs }) {
    const mounted = shallowRef(false);
    const vm = getCurrentInstance();
    if (vm) {
      vm._nuxtClientOnly = true;
    }
    provide(clientOnlySymbol, true);
    return () => {
      var _a;
      if (mounted.value) {
        const vnodes = (_a = slots.default) == null ? void 0 : _a.call(slots);
        if (vnodes && vnodes.length === 1) {
          return [cloneVNode(vnodes[0], attrs)];
        }
        return vnodes;
      }
      const slot = slots.fallback || slots.placeholder;
      if (slot) {
        return h(slot);
      }
      const fallbackStr = props.fallback || props.placeholder || "";
      const fallbackTag = props.fallbackTag || props.placeholderTag || "span";
      return createElementBlock(fallbackTag, attrs, fallbackStr);
    };
  }
});

const isDefer = (dedupe) => dedupe === "defer" || dedupe === false;
function useAsyncData(...args) {
  var _a, _b, _c, _d, _e, _f, _g, _h;
  const autoKey = typeof args[args.length - 1] === "string" ? args.pop() : void 0;
  if (_isAutoKeyNeeded(args[0], args[1])) {
    args.unshift(autoKey);
  }
  let [_key, _handler, options = {}] = args;
  const key = computed(() => toValue(_key));
  if (typeof key.value !== "string") {
    throw new TypeError("[nuxt] [useAsyncData] key must be a string.");
  }
  if (typeof _handler !== "function") {
    throw new TypeError("[nuxt] [useAsyncData] handler must be a function.");
  }
  const nuxtApp = useNuxtApp();
  (_a = options.server) != null ? _a : options.server = true;
  (_b = options.default) != null ? _b : options.default = getDefault;
  (_c = options.getCachedData) != null ? _c : options.getCachedData = getDefaultCachedData;
  (_d = options.lazy) != null ? _d : options.lazy = false;
  (_e = options.immediate) != null ? _e : options.immediate = true;
  (_f = options.deep) != null ? _f : options.deep = asyncDataDefaults.deep;
  (_g = options.dedupe) != null ? _g : options.dedupe = "cancel";
  options._functionName || "useAsyncData";
  nuxtApp._asyncData[key.value];
  const initialFetchOptions = { cause: "initial", dedupe: options.dedupe };
  if (!((_h = nuxtApp._asyncData[key.value]) == null ? void 0 : _h._init)) {
    initialFetchOptions.cachedData = options.getCachedData(key.value, nuxtApp, { cause: "initial" });
    nuxtApp._asyncData[key.value] = createAsyncData(nuxtApp, key.value, _handler, options, initialFetchOptions.cachedData);
  }
  const asyncData = nuxtApp._asyncData[key.value];
  asyncData._deps++;
  const initialFetch = () => nuxtApp._asyncData[key.value].execute(initialFetchOptions);
  const fetchOnServer = options.server !== false && nuxtApp.payload.serverRendered;
  if (fetchOnServer && options.immediate) {
    const promise = initialFetch();
    if (getCurrentInstance()) {
      onServerPrefetch(() => promise);
    } else {
      nuxtApp.hook("app:created", async () => {
        await promise;
      });
    }
  }
  const asyncReturn = {
    data: writableComputedRef(() => {
      var _a2;
      return (_a2 = nuxtApp._asyncData[key.value]) == null ? void 0 : _a2.data;
    }),
    pending: writableComputedRef(() => {
      var _a2;
      return (_a2 = nuxtApp._asyncData[key.value]) == null ? void 0 : _a2.pending;
    }),
    status: writableComputedRef(() => {
      var _a2;
      return (_a2 = nuxtApp._asyncData[key.value]) == null ? void 0 : _a2.status;
    }),
    error: writableComputedRef(() => {
      var _a2;
      return (_a2 = nuxtApp._asyncData[key.value]) == null ? void 0 : _a2.error;
    }),
    refresh: (...args2) => nuxtApp._asyncData[key.value].execute(...args2),
    execute: (...args2) => nuxtApp._asyncData[key.value].execute(...args2),
    clear: () => clearNuxtDataByKey(nuxtApp, key.value)
  };
  const asyncDataPromise = Promise.resolve(nuxtApp._asyncDataPromises[key.value]).then(() => asyncReturn);
  Object.assign(asyncDataPromise, asyncReturn);
  return asyncDataPromise;
}
function writableComputedRef(getter) {
  return computed({
    get() {
      var _a;
      return (_a = getter()) == null ? void 0 : _a.value;
    },
    set(value) {
      const ref2 = getter();
      if (ref2) {
        ref2.value = value;
      }
    }
  });
}
function _isAutoKeyNeeded(keyOrFetcher, fetcher) {
  if (typeof keyOrFetcher === "string") {
    return false;
  }
  if (typeof keyOrFetcher === "object" && keyOrFetcher !== null) {
    return false;
  }
  if (typeof keyOrFetcher === "function" && typeof fetcher === "function") {
    return false;
  }
  return true;
}
function clearNuxtDataByKey(nuxtApp, key) {
  if (key in nuxtApp.payload.data) {
    nuxtApp.payload.data[key] = void 0;
  }
  if (key in nuxtApp.payload._errors) {
    nuxtApp.payload._errors[key] = asyncDataDefaults.errorValue;
  }
  if (nuxtApp._asyncData[key]) {
    nuxtApp._asyncData[key].data.value = void 0;
    nuxtApp._asyncData[key].error.value = asyncDataDefaults.errorValue;
    {
      nuxtApp._asyncData[key].pending.value = false;
    }
    nuxtApp._asyncData[key].status.value = "idle";
  }
  if (key in nuxtApp._asyncDataPromises) {
    if (nuxtApp._asyncDataPromises[key]) {
      nuxtApp._asyncDataPromises[key].cancelled = true;
    }
    nuxtApp._asyncDataPromises[key] = void 0;
  }
}
function pick(obj, keys) {
  const newObj = {};
  for (const key of keys) {
    newObj[key] = obj[key];
  }
  return newObj;
}
function createAsyncData(nuxtApp, key, _handler, options, initialCachedData) {
  var _a, _b;
  (_b = (_a = nuxtApp.payload._errors)[key]) != null ? _b : _a[key] = asyncDataDefaults.errorValue;
  const hasCustomGetCachedData = options.getCachedData !== getDefaultCachedData;
  const handler = _handler ;
  const _ref = options.deep ? ref : shallowRef;
  const hasCachedData = initialCachedData != null;
  const unsubRefreshAsyncData = nuxtApp.hook("app:data:refresh", async (keys) => {
    if (!keys || keys.includes(key)) {
      await asyncData.execute({ cause: "refresh:hook" });
    }
  });
  const asyncData = {
    data: _ref(hasCachedData ? initialCachedData : options.default()),
    pending: shallowRef(!hasCachedData),
    error: toRef(nuxtApp.payload._errors, key),
    status: shallowRef("idle"),
    execute: (...args) => {
      var _a2, _b2;
      const [_opts, newValue = void 0] = args;
      const opts = _opts && newValue === void 0 && typeof _opts === "object" ? _opts : {};
      if (nuxtApp._asyncDataPromises[key]) {
        if (isDefer((_a2 = opts.dedupe) != null ? _a2 : options.dedupe)) {
          return nuxtApp._asyncDataPromises[key];
        }
        nuxtApp._asyncDataPromises[key].cancelled = true;
      }
      if (opts.cause === "initial" || nuxtApp.isHydrating) {
        const cachedData = "cachedData" in opts ? opts.cachedData : options.getCachedData(key, nuxtApp, { cause: (_b2 = opts.cause) != null ? _b2 : "refresh:manual" });
        if (cachedData != null) {
          nuxtApp.payload.data[key] = asyncData.data.value = cachedData;
          asyncData.error.value = asyncDataDefaults.errorValue;
          asyncData.status.value = "success";
          return Promise.resolve(cachedData);
        }
      }
      {
        asyncData.pending.value = true;
      }
      asyncData.status.value = "pending";
      const promise = new Promise(
        (resolve, reject) => {
          try {
            resolve(handler(nuxtApp));
          } catch (err) {
            reject(err);
          }
        }
      ).then(async (_result) => {
        if (promise.cancelled) {
          return nuxtApp._asyncDataPromises[key];
        }
        let result = _result;
        if (options.transform) {
          result = await options.transform(_result);
        }
        if (options.pick) {
          result = pick(result, options.pick);
        }
        nuxtApp.payload.data[key] = result;
        asyncData.data.value = result;
        asyncData.error.value = asyncDataDefaults.errorValue;
        asyncData.status.value = "success";
      }).catch((error) => {
        if (promise.cancelled) {
          return nuxtApp._asyncDataPromises[key];
        }
        asyncData.error.value = createError(error);
        asyncData.data.value = unref(options.default());
        asyncData.status.value = "error";
      }).finally(() => {
        if (promise.cancelled) {
          return;
        }
        {
          asyncData.pending.value = false;
        }
        delete nuxtApp._asyncDataPromises[key];
      });
      nuxtApp._asyncDataPromises[key] = promise;
      return nuxtApp._asyncDataPromises[key];
    },
    _execute: debounce((...args) => asyncData.execute(...args), 0, { leading: true }),
    _default: options.default,
    _deps: 0,
    _init: true,
    _hash: void 0,
    _off: () => {
      var _a2;
      unsubRefreshAsyncData();
      if ((_a2 = nuxtApp._asyncData[key]) == null ? void 0 : _a2._init) {
        nuxtApp._asyncData[key]._init = false;
      }
      if (!hasCustomGetCachedData) {
        nextTick(() => {
          var _a3;
          if (!((_a3 = nuxtApp._asyncData[key]) == null ? void 0 : _a3._init)) {
            clearNuxtDataByKey(nuxtApp, key);
            asyncData.execute = () => Promise.resolve();
            asyncData.data.value = asyncDataDefaults.value;
          }
        });
      }
    }
  };
  return asyncData;
}
const getDefault = () => asyncDataDefaults.value;
const getDefaultCachedData = (key, nuxtApp, ctx) => {
  if (nuxtApp.isHydrating) {
    return nuxtApp.payload.data[key];
  }
  if (ctx.cause !== "refresh:manual" && ctx.cause !== "refresh:hook") {
    return nuxtApp.static.data[key];
  }
};
const useStateKeyPrefix = "$s";
function useState(...args) {
  const autoKey = typeof args[args.length - 1] === "string" ? args.pop() : void 0;
  if (typeof args[0] !== "string") {
    args.unshift(autoKey);
  }
  const [_key, init] = args;
  if (!_key || typeof _key !== "string") {
    throw new TypeError("[nuxt] [useState] key must be a string: " + _key);
  }
  if (init !== void 0 && typeof init !== "function") {
    throw new Error("[nuxt] [useState] init must be a function: " + init);
  }
  const key = useStateKeyPrefix + _key;
  const nuxtApp = useNuxtApp();
  const state = toRef(nuxtApp.payload.state, key);
  if (state.value === void 0 && init) {
    const initialValue = init();
    if (isRef(initialValue)) {
      nuxtApp.payload.state[key] = initialValue;
      return initialValue;
    }
    state.value = initialValue;
  }
  return state;
}
function useRequestEvent(nuxtApp) {
  var _a;
  nuxtApp || (nuxtApp = useNuxtApp());
  return (_a = nuxtApp.ssrContext) == null ? void 0 : _a.event;
}
function useRequestFetch() {
  var _a;
  return ((_a = useRequestEvent()) == null ? void 0 : _a.$fetch) || globalThis.$fetch;
}
function useFetch(request, arg1, arg2) {
  const [opts = {}, autoKey] = typeof arg1 === "string" ? [{}, arg1] : [arg1, arg2];
  const _request = computed(() => toValue(request));
  const key = computed(() => toValue(opts.key) || "$f" + hash([autoKey, typeof _request.value === "string" ? _request.value : "", ...generateOptionSegments(opts)]));
  if (!opts.baseURL && typeof _request.value === "string" && (_request.value[0] === "/" && _request.value[1] === "/")) {
    throw new Error('[nuxt] [useFetch] the request URL must not start with "//".');
  }
  const {
    server,
    lazy,
    default: defaultFn,
    transform,
    pick: pick2,
    watch: watchSources,
    immediate,
    getCachedData,
    deep,
    dedupe,
    ...fetchOptions
  } = opts;
  const _fetchOptions = reactive({
    ...fetchDefaults,
    ...fetchOptions,
    cache: typeof opts.cache === "boolean" ? void 0 : opts.cache
  });
  const _asyncDataOptions = {
    server,
    lazy,
    default: defaultFn,
    transform,
    pick: pick2,
    immediate,
    getCachedData,
    deep,
    dedupe,
    watch: watchSources === false ? [] : [...watchSources || [], _fetchOptions]
  };
  if (!immediate) {
    let setImmediate = function() {
      _asyncDataOptions.immediate = true;
    };
    watch(key, setImmediate, { flush: "sync", once: true });
    watch([...watchSources || [], _fetchOptions], setImmediate, { flush: "sync", once: true });
  }
  let controller;
  const asyncData = useAsyncData(watchSources === false ? key.value : key, () => {
    var _a;
    (_a = controller == null ? void 0 : controller.abort) == null ? void 0 : _a.call(controller, new DOMException("Request aborted as another request to the same endpoint was initiated.", "AbortError"));
    controller = typeof AbortController !== "undefined" ? new AbortController() : {};
    const timeoutLength = toValue(opts.timeout);
    let timeoutId;
    if (timeoutLength) {
      timeoutId = setTimeout(() => controller.abort(new DOMException("Request aborted due to timeout.", "AbortError")), timeoutLength);
      controller.signal.onabort = () => clearTimeout(timeoutId);
    }
    let _$fetch = opts.$fetch || globalThis.$fetch;
    if (!opts.$fetch) {
      const isLocalFetch = typeof _request.value === "string" && _request.value[0] === "/" && (!toValue(opts.baseURL) || toValue(opts.baseURL)[0] === "/");
      if (isLocalFetch) {
        _$fetch = useRequestFetch();
      }
    }
    return _$fetch(_request.value, { signal: controller.signal, ..._fetchOptions }).finally(() => {
      clearTimeout(timeoutId);
    });
  }, _asyncDataOptions);
  return asyncData;
}
function generateOptionSegments(opts) {
  var _a;
  const segments = [
    ((_a = toValue(opts.method)) == null ? void 0 : _a.toUpperCase()) || "GET",
    toValue(opts.baseURL)
  ];
  for (const _obj of [opts.params || opts.query]) {
    const obj = toValue(_obj);
    if (!obj) {
      continue;
    }
    const unwrapped = {};
    for (const [key, value] of Object.entries(obj)) {
      unwrapped[toValue(key)] = toValue(value);
    }
    segments.push(unwrapped);
  }
  if (opts.body) {
    const value = toValue(opts.body);
    if (!value) {
      segments.push(hash(value));
    } else if (value instanceof ArrayBuffer) {
      segments.push(hash(Object.fromEntries([...new Uint8Array(value).entries()].map(([k, v]) => [k, v.toString()]))));
    } else if (value instanceof FormData) {
      const obj = {};
      for (const entry of value.entries()) {
        const [key, val] = entry;
        obj[key] = val instanceof File ? val.name : val;
      }
      segments.push(hash(obj));
    } else if (isPlainObject(value)) {
      segments.push(hash(reactive(value)));
    } else {
      try {
        segments.push(hash(value));
      } catch {
        console.warn("[useFetch] Failed to hash body", value);
      }
    }
  }
  return segments;
}
const _sfc_main$8 = {
  __name: "SyllabusExplorer",
  __ssrInlineRender: true,
  emits: ["file-click"],
  setup(__props, { emit: __emit }) {
    var _a, _b;
    const kbTree = ref(null);
    const curriculumTree = ref(null);
    const loading = ref(false);
    const error = ref(null);
    const config = useRuntimeConfig();
    function resolveApiBase2() {
      var _a2;
      const configured = ((_a2 = config.public) == null ? void 0 : _a2.apiBaseUrl) || "/api";
      return configured;
    }
    const apiBase = resolveApiBase2();
    const apiKey = ((_a = useRuntimeConfig().public) == null ? void 0 : _a.apiKey) || "my_mcp_eagle_tiger";
    const curriculumLoading = ref(false);
    const topics = ref([]);
    const search = ref("");
    const filteredTopics = computed(() => {
      const q = (search.value || "").toLowerCase();
      const base = (topics.value || []).filter((t) => Array.isArray(t == null ? void 0 : t.messages) && t.messages.length > 0);
      if (!q) return base;
      return base.filter((t) => (t.name || "").toLowerCase().includes(q));
    });
    const route = useRoute();
    const auth = useAuthStore();
    try {
      (_b = auth.loadFromStorage) == null ? void 0 : _b.call(auth);
    } catch {
    }
    const isCurriculum = computed(() => {
      try {
        return typeof (route == null ? void 0 : route.path) === "string" && (route.path.startsWith("/curriculum") || route.path.startsWith("/textbook"));
      } catch {
        return false;
      }
    });
    const isTutorOrAdmin = computed(() => {
      const r = String(auth.role || "").toLowerCase();
      return r === "tutor" || r === "admin" || r === "administrator";
    });
    const showChatSection = computed(() => !isCurriculum.value || isTutorOrAdmin.value);
    function shortTitle(name) {
      if (!name) return "\uC81C\uBAA9 \uC5C6\uC74C";
      return name.length > 18 ? name.slice(0, 18) + "\u2026" : name;
    }
    const emit = __emit;
    const onFileClick = (path) => {
      emit("file-click", path);
    };
    async function loadcurriculumTreeIfCurriculum() {
      if (curriculumLoading.value) return;
      try {
        const route2 = useRoute();
        const p = String((route2 == null ? void 0 : route2.path) || "");
        if (!(p.startsWith("/curriculum") || p.startsWith("/textbook"))) return;
        curriculumLoading.value = true;
        const r2 = await fetch(`${apiBase}/v1/curriculum/selection`, { headers: { "X-API-Key": apiKey } });
        const sel = await r2.json();
        selectedDirs.value = Array.isArray(sel == null ? void 0 : sel.selected_dirs) ? sel.selected_dirs : [];
        const r3 = await fetch(`${apiBase}/v1/curriculum/tree`, { headers: { "X-API-Key": apiKey } });
        if (r3.ok) {
          curriculumTree.value = await r3.json();
        }
      } finally {
        curriculumLoading.value = false;
      }
    }
    try {
      const route2 = useRoute();
      watch(() => route2.path, async (p) => {
        try {
          if (typeof p === "string" && (p.startsWith("/curriculum") || p.startsWith("/textbook"))) {
            await loadcurriculumTreeIfCurriculum();
          }
        } catch {
        }
      });
    } catch {
    }
    const selectedDirs = ref([]);
    const displayTree = computed(() => {
      if (curriculumTree.value) return curriculumTree.value;
      const t = kbTree.value || {};
      const picked = selectedDirs.value || [];
      if (!picked.length) return t;
      const filtered = {};
      for (const key of picked) {
        if (t[key]) filtered[key] = t[key];
      }
      return filtered;
    });
    return (_ctx, _push, _parent, _attrs) => {
      _push(`<div${ssrRenderAttrs(mergeProps({ class: "p-4 select-none" }, _attrs))}><h3 class="text-lg font-semibold mb-4 whitespace-nowrap text-gray-800"> \uCE74\uD14C\uACE0\uB9AC </h3>`);
      if (loading.value) {
        _push(`<div>Loading...</div>`);
      } else {
        _push(`<!---->`);
      }
      if (error.value) {
        _push(`<div>${ssrInterpolate(error.value)}</div>`);
      } else {
        _push(`<!---->`);
      }
      if (displayTree.value) {
        _push(`<div>`);
        _push(ssrRenderComponent(_sfc_main$4$1, {
          tree: displayTree.value,
          "selected-file": null,
          onFileSelect: onFileClick,
          onFileOpen: onFileClick
        }, null, _parent));
        _push(`</div>`);
      } else {
        _push(`<!---->`);
      }
      if (showChatSection.value) {
        _push(`<div class="mt-6"><div class="flex items-center justify-between mb-2"><h4 class="text-sm font-semibold text-gray-800">\uCC44\uD305</h4><button class="text-xs px-2 py-1 bg-blue-600 text-white rounded">\uC0C8 \uCC44\uD305</button></div><div class="mb-2"><input${ssrRenderAttr("value", search.value)} type="text" placeholder="\uCC44\uD305 \uAC80\uC0C9" class="w-full px-2 py-1 border rounded text-sm"></div><ul class="space-y-1"><!--[-->`);
        ssrRenderList(filteredTopics.value, (t) => {
          _push(`<li class="flex items-center justify-between group"><button class="text-left text-sm w-full truncate px-2 py-1 rounded hover:bg-gray-100"${ssrRenderAttr("title", t.name)}>${ssrInterpolate(shortTitle(t.name))}</button><button class="opacity-0 group-hover:opacity-100 text-gray-500 hover:text-red-600 px-2" title="\uC0AD\uC81C">\xD7</button></li>`);
        });
        _push(`<!--]--></ul></div>`);
      } else {
        _push(`<!---->`);
      }
      _push(`</div>`);
    };
  }
};
const _sfc_setup$8 = _sfc_main$8.setup;
_sfc_main$8.setup = (props, ctx) => {
  const ssrContext = useSSRContext();
  (ssrContext.modules || (ssrContext.modules = /* @__PURE__ */ new Set())).add("components/SyllabusExplorer.vue");
  return _sfc_setup$8 ? _sfc_setup$8(props, ctx) : void 0;
};
const _sfc_main$7 = {
  __name: "DiffViewer",
  __ssrInlineRender: true,
  props: {
    path: { type: String, required: true },
    versions: { type: Array, required: true },
    defaultLeft: { type: Number, required: false },
    defaultRight: { type: Number, required: false }
  },
  setup(__props) {
    var _a, _b, _c;
    const props = __props;
    const leftVersion = ref(props.defaultLeft || (((_a = props.versions[1]) == null ? void 0 : _a.version_no) || ((_b = props.versions[0]) == null ? void 0 : _b.version_no)));
    const rightVersion = ref(props.defaultRight || ((_c = props.versions[0]) == null ? void 0 : _c.version_no));
    const structured = ref([]);
    const loading = ref(false);
    const showLineNumbers = ref(true);
    const viewMode = ref("unified");
    const displayHunks = computed(() => structured.value);
    function lineClassUnified(line) {
      if (line.type === "add") return "text-green-700";
      if (line.type === "del") return "text-red-600";
      if (line.type === "context") return "text-gray-700";
      return "text-gray-700";
    }
    function unifiedPrefix(line) {
      if (line.type === "add") return "+";
      if (line.type === "del") return "-";
      return " ";
    }
    watch(() => [leftVersion.value, rightVersion.value], () => {
      structured.value = [];
    });
    function sideRows(h) {
      const rows = [];
      let adds = [];
      let dels = [];
      for (const ln of h.lines) {
        if (ln.type === "context") {
          while (dels.length || adds.length) {
            const d = dels.shift() || { old_line: null, text: "", type: "del" };
            const a = adds.shift() || { new_line: null, text: "", type: "add" };
            rows.push({ key: h.header + "-" + rows.length, type: d.type === "del" && a.type === "add" ? "change" : d.type === "del" ? "del" : "add", old_line: d.old_line, old_text: d.text, new_line: a.new_line, new_text: a.text });
          }
          rows.push({ key: h.header + "-ctx-" + rows.length, type: "context", old_line: ln.old_line, old_text: ln.text, new_line: ln.new_line, new_text: ln.text });
        } else if (ln.type === "del") {
          dels.push(ln);
        } else if (ln.type === "add") {
          adds.push(ln);
        }
      }
      while (dels.length || adds.length) {
        const d = dels.shift() || { old_line: null, text: "", type: "del" };
        const a = adds.shift() || { new_line: null, text: "", type: "add" };
        rows.push({ key: h.header + "-" + rows.length, type: d.type === "del" && a.type === "add" ? "change" : d.type === "del" ? "del" : "add", old_line: d.old_line, old_text: d.text, new_line: a.new_line, new_text: a.text });
      }
      return rows;
    }
    function rowClass(row) {
      if (row.type === "add") return "bg-green-50";
      if (row.type === "del") return "bg-red-50";
      if (row.type === "change") return "bg-yellow-50";
      return "";
    }
    function tokenize(str) {
      if (!str) return [];
      return str.split(/(\s+)/);
    }
    function inlineDiff(oldText, newText) {
      if (oldText === newText) return { oldHtml: escapeHtml(oldText), newHtml: escapeHtml(newText) };
      if (oldText.length + newText.length > 800) return { oldHtml: escapeHtml(oldText), newHtml: escapeHtml(newText) };
      const a = tokenize(oldText);
      const b = tokenize(newText);
      if (a.length + b.length > 300) return { oldHtml: escapeHtml(oldText), newHtml: escapeHtml(newText) };
      const m = a.length, n = b.length;
      const dp = Array.from({ length: m + 1 }, () => new Array(n + 1).fill(0));
      for (let i2 = 1; i2 <= m; i2++) {
        for (let j2 = 1; j2 <= n; j2++) {
          if (a[i2 - 1] === b[j2 - 1]) dp[i2][j2] = dp[i2 - 1][j2 - 1] + 1;
          else dp[i2][j2] = dp[i2 - 1][j2] >= dp[i2][j2 - 1] ? dp[i2 - 1][j2] : dp[i2][j2 - 1];
        }
      }
      let i = m, j = n;
      const chunks = [];
      while (i > 0 || j > 0) {
        if (i > 0 && j > 0 && a[i - 1] === b[j - 1]) {
          chunks.push({ type: "eq", text: a[i - 1] });
          i--;
          j--;
        } else if (j > 0 && (i === 0 || dp[i][j - 1] >= dp[i - 1][j])) {
          chunks.push({ type: "add", text: b[j - 1] });
          j--;
        } else if (i > 0) {
          chunks.push({ type: "del", text: a[i - 1] });
          i--;
        }
      }
      chunks.reverse();
      let oldHtml = "", newHtml = "";
      for (const c of chunks) {
        if (c.type === "eq") {
          oldHtml += escapeHtml(c.text);
          newHtml += escapeHtml(c.text);
        } else if (c.type === "del") {
          oldHtml += `<span class="bg-red-200/70 line-through">${escapeHtml(c.text)}</span>`;
        } else if (c.type === "add") {
          newHtml += `<span class="bg-green-200/70">${escapeHtml(c.text)}</span>`;
        }
      }
      return { oldHtml, newHtml };
    }
    function escapeHtml(s) {
      return (s || "").replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;");
    }
    return (_ctx, _push, _parent, _attrs) => {
      _push(`<div${ssrRenderAttrs(mergeProps({ class: "h-full flex flex-col" }, _attrs))}><div class="flex items-center gap-2 p-2 border-b bg-white text-sm"><select class="border rounded px-2 py-1 text-xs"><!--[-->`);
      ssrRenderList(__props.versions, (v) => {
        _push(`<option${ssrRenderAttr("value", v.version_no)}${ssrIncludeBooleanAttr(Array.isArray(leftVersion.value) ? ssrLooseContain(leftVersion.value, v.version_no) : ssrLooseEqual(leftVersion.value, v.version_no)) ? " selected" : ""}>v${ssrInterpolate(v.version_no)}</option>`);
      });
      _push(`<!--]--></select><span class="text-gray-500">\u2192</span><select class="border rounded px-2 py-1 text-xs"><!--[-->`);
      ssrRenderList(__props.versions, (v) => {
        _push(`<option${ssrRenderAttr("value", v.version_no)}${ssrIncludeBooleanAttr(Array.isArray(rightVersion.value) ? ssrLooseContain(rightVersion.value, v.version_no) : ssrLooseEqual(rightVersion.value, v.version_no)) ? " selected" : ""}>v${ssrInterpolate(v.version_no)}</option>`);
      });
      _push(`<!--]--></select><button${ssrIncludeBooleanAttr(loading.value || !leftVersion.value || !rightVersion.value) ? " disabled" : ""} class="px-2 py-1 bg-indigo-600 text-white rounded text-xs hover:bg-indigo-500 disabled:opacity-50">Diff</button>`);
      if (loading.value) {
        _push(`<span class="text-xs text-gray-500">Loading...</span>`);
      } else {
        _push(`<!---->`);
      }
      if (displayHunks.value.length) {
        _push(`<button class="px-2 py-1 text-xs border rounded hover:bg-gray-100">Copy Patch</button>`);
      } else {
        _push(`<!---->`);
      }
      _push(`<select class="border rounded px-1 py-1 text-[11px]"><option value="unified"${ssrIncludeBooleanAttr(Array.isArray(viewMode.value) ? ssrLooseContain(viewMode.value, "unified") : ssrLooseEqual(viewMode.value, "unified")) ? " selected" : ""}>Unified</option><option value="side"${ssrIncludeBooleanAttr(Array.isArray(viewMode.value) ? ssrLooseContain(viewMode.value, "side") : ssrLooseEqual(viewMode.value, "side")) ? " selected" : ""}>Side-by-Side</option></select><label class="flex items-center gap-1 text-[11px] cursor-pointer select-none"><input type="checkbox"${ssrIncludeBooleanAttr(Array.isArray(showLineNumbers.value) ? ssrLooseContain(showLineNumbers.value, null) : showLineNumbers.value) ? " checked" : ""} class="accent-indigo-600"> LN </label><div class="flex-1"></div><button class="px-2 py-1 text-xs border rounded hover:bg-gray-100">Close</button></div>`);
      if (viewMode.value === "unified") {
        _push(`<div class="flex-1 overflow-auto font-mono text-[12px] leading-snug bg-gray-50 p-3">`);
        if (displayHunks.value.length) {
          _push(`<!--[-->`);
          ssrRenderList(displayHunks.value, (h, i) => {
            _push(`<div class="mb-4"><div class="bg-gray-200 text-gray-700 px-1 py-0.5 text-xs">${ssrInterpolate(h.header)}</div><pre class="whitespace-pre-wrap"><!--[-->`);
            ssrRenderList(h.lines, (line, li) => {
              var _a2, _b2, _c2;
              _push(`<span class="${ssrRenderClass(lineClassUnified(line))}">`);
              if (showLineNumbers.value) {
                _push(`<span class="inline-block w-10 pr-2 text-right text-gray-400 select-none">${ssrInterpolate((_b2 = (_a2 = line.old_line) != null ? _a2 : line.new_line) != null ? _b2 : "")}</span>`);
              } else {
                _push(`<!---->`);
              }
              if (line.type === "change") {
                _push(`<!--[-->${ssrInterpolate(unifiedPrefix(line))}<span>${(_c2 = inlineDiff(line.old_text || line.text, line.new_text || line.text).newHtml) != null ? _c2 : ""}</span><!--]-->`);
              } else {
                _push(`<!--[-->${ssrInterpolate(unifiedPrefix(line))}${ssrInterpolate(line.text)}<!--]-->`);
              }
              _push(`
</span>`);
            });
            _push(`<!--]--></pre></div>`);
          });
          _push(`<!--]-->`);
        } else {
          _push(`<div class="text-gray-400 text-xs">No diff</div>`);
        }
        _push(`</div>`);
      } else {
        _push(`<div class="flex-1 overflow-auto bg-white text-[12px]">`);
        if (displayHunks.value.length) {
          _push(`<!--[-->`);
          ssrRenderList(displayHunks.value, (h, i) => {
            _push(`<div class="mb-6 border rounded"><div class="bg-gray-100 text-gray-700 px-2 py-1 text-xs font-mono">${ssrInterpolate(h.header)}</div><table class="w-full text-[11px] font-mono"><tbody><!--[-->`);
            ssrRenderList(sideRows(h), (row) => {
              var _a2, _b2;
              _push(`<tr class="${ssrRenderClass(rowClass(row))}">`);
              if (showLineNumbers.value) {
                _push(`<td class="w-12 text-right pr-2 text-gray-400 align-top">${ssrInterpolate(row.old_line || "")}</td>`);
              } else {
                _push(`<!---->`);
              }
              if (showLineNumbers.value) {
                _push(`<td class="w-1 align-top text-red-600">${ssrInterpolate(row.type === "del" || row.type === "change" ? "-" : "")}</td>`);
              } else {
                _push(`<!---->`);
              }
              _push(`<td class="align-top whitespace-pre-wrap w-1/2 px-1">`);
              if (row.type === "change") {
                _push(`<span>${(_a2 = inlineDiff(row.old_text || "", row.new_text || "").oldHtml) != null ? _a2 : ""}</span>`);
              } else {
                _push(`<span>${ssrInterpolate(row.old_text || "")}</span>`);
              }
              _push(`</td>`);
              if (showLineNumbers.value) {
                _push(`<td class="w-12 text-right pr-2 text-gray-400 align-top">${ssrInterpolate(row.new_line || "")}</td>`);
              } else {
                _push(`<!---->`);
              }
              if (showLineNumbers.value) {
                _push(`<td class="w-1 align-top text-green-600">${ssrInterpolate(row.type === "add" || row.type === "change" ? "+" : "")}</td>`);
              } else {
                _push(`<!---->`);
              }
              _push(`<td class="align-top whitespace-pre-wrap w-1/2 px-1">`);
              if (row.type === "change") {
                _push(`<span>${(_b2 = inlineDiff(row.old_text || "", row.new_text || "").newHtml) != null ? _b2 : ""}</span>`);
              } else {
                _push(`<span>${ssrInterpolate(row.new_text || "")}</span>`);
              }
              _push(`</td></tr>`);
            });
            _push(`<!--]--></tbody></table></div>`);
          });
          _push(`<!--]-->`);
        } else {
          _push(`<div class="text-gray-400 text-xs p-4">No diff</div>`);
        }
        _push(`</div>`);
      }
      _push(`</div>`);
    };
  }
};
const _sfc_setup$7 = _sfc_main$7.setup;
_sfc_main$7.setup = (props, ctx) => {
  const ssrContext = useSSRContext();
  (ssrContext.modules || (ssrContext.modules = /* @__PURE__ */ new Set())).add("components/DiffViewer.vue");
  return _sfc_setup$7 ? _sfc_setup$7(props, ctx) : void 0;
};
function mermaidTemplate(kind = "flow") {
  if (kind === "sequence") {
    return ["```mermaid", "sequenceDiagram", "  participant User", "  participant API", "  User->>API: request", "  API-->>User: response", "```", ""].join("\n");
  }
  if (kind === "gantt") {
    return ["```mermaid", "gantt", "  dateFormat  YYYY-MM-DD", "  title Deployment Pipeline", "  section Plan", "  Plan      :a1, 2025-01-01, 1d", "  Apply     :a2, after a1, 1d", "```", ""].join("\n");
  }
  return ["```mermaid", "flowchart LR", "  A[User] --> B[FastAPI]", "  B --> C[Terraform Plan]", "```", ""].join("\n");
}
function vegaLiteBarSpec() {
  const spec = {
    $schema: "https://vega.github.io/schema/vega-lite/v5.json",
    data: { values: [{ stage: "plan", sec: 12 }, { stage: "apply", sec: 34 }] },
    mark: "bar",
    encoding: {
      x: { field: "stage", type: "nominal" },
      y: { field: "sec", type: "quantitative" }
    }
  };
  return JSON.stringify(spec, null, 2);
}
const _sfc_main$6 = /* @__PURE__ */ defineComponent({
  __name: "KbToolbar",
  __ssrInlineRender: true,
  props: {
    saving: { type: Boolean, default: false },
    saveLabel: { type: String, default: "Save" },
    cancelLabel: { type: String, default: "Cancel" },
    deleteLabel: { type: String, default: "Delete" },
    savingText: { type: String, default: "Saving\u2026" },
    ariaLabel: { type: String, default: "Editor toolbar" },
    saveAriaLabel: { type: String, default: "Save (Ctrl+S)" },
    cancelAriaLabel: { type: String, default: "Cancel" },
    deleteAriaLabel: { type: String, default: "Delete current file" }
  },
  emits: ["save", "cancel", "delete"],
  setup(__props) {
    return (_ctx, _push, _parent, _attrs) => {
      _push(`<div${ssrRenderAttrs(mergeProps({
        class: "border-b p-2 flex items-center gap-2 text-sm overflow-x-auto whitespace-nowrap",
        role: "toolbar",
        "aria-label": __props.ariaLabel
      }, _attrs))}><button class="px-2 py-1 rounded bg-indigo-600 text-white"${ssrIncludeBooleanAttr(__props.saving) ? " disabled" : ""}${ssrRenderAttr("aria-label", __props.saveAriaLabel)}>${ssrInterpolate(__props.saveLabel)}</button><button class="px-2 py-1 rounded bg-gray-200"${ssrRenderAttr("aria-label", __props.cancelAriaLabel)}>${ssrInterpolate(__props.cancelLabel)}</button><button class="px-2 py-1 rounded bg-red-600 text-white"${ssrRenderAttr("aria-label", __props.deleteAriaLabel)}>${ssrInterpolate(__props.deleteLabel)}</button>`);
      if (__props.saving) {
        _push(`<span class="text-gray-500">${ssrInterpolate(__props.savingText)}</span>`);
      } else {
        _push(`<!---->`);
      }
      _push(`<div class="w-px h-5 bg-gray-200 mx-1"></div>`);
      ssrRenderSlot(_ctx.$slots, "default", {}, null, _push, _parent);
      _push(`<div class="flex-1"></div>`);
      ssrRenderSlot(_ctx.$slots, "right", {}, null, _push, _parent);
      _push(`</div>`);
    };
  }
});
const _sfc_setup$6 = _sfc_main$6.setup;
_sfc_main$6.setup = (props, ctx) => {
  const ssrContext = useSSRContext();
  (ssrContext.modules || (ssrContext.modules = /* @__PURE__ */ new Set())).add("components/KbToolbar.vue");
  return _sfc_setup$6 ? _sfc_setup$6(props, ctx) : void 0;
};
const useDocStore = defineStore("doc", () => {
  const api = useKbApi();
  const path = ref("");
  const content = ref("");
  const loading = ref(false);
  const dirty = ref(false);
  const version = ref();
  const baseVersion = ref();
  const error = ref();
  async function open(p) {
    loading.value = true;
    error.value = void 0;
    try {
      path.value = p;
      try {
        if (false) ;
      } catch {
      }
      const data = await api.getItem(p);
      content.value = data.content || "";
      version.value = data.version_no;
      baseVersion.value = data.version_no;
      dirty.value = false;
    } catch (e) {
      error.value = e.message || "load failed";
    } finally {
      loading.value = false;
    }
  }
  function update(newContent) {
    dirty.value = newContent !== content.value;
    content.value = newContent;
  }
  function whenLoaded(expectedPath) {
    return new Promise((resolve) => {
      if (!loading.value && (!expectedPath || path.value === expectedPath)) {
        resolve();
        return;
      }
      const stop = watch([loading, path], () => {
        if (!loading.value && (!expectedPath || path.value === expectedPath)) {
          stop();
          resolve();
        }
      });
    });
  }
  async function save(message) {
    var _a;
    if (!path.value) return;
    try {
      const res = await api.saveItem(path.value, content.value, message, version.value);
      version.value = res.version_no;
      baseVersion.value = res.version_no;
      dirty.value = false;
      return { conflict: false, version: res.version_no };
    } catch (e) {
      if ((_a = e.message) == null ? void 0 : _a.includes("409")) {
        return { conflict: true };
      }
      error.value = e.message;
      return { conflict: false, error: e.message };
    }
  }
  const status = computed(() => loading.value ? "loading" : dirty.value ? "modified" : "clean");
  return { path, content, version, baseVersion, loading, dirty, error, status, open, update, save, whenLoaded };
});
const chartPlaceholder = '{ "$schema": "https://vega.github.io/schema/vega-lite/v5.json", ... }';
const _sfc_main$5 = {
  __name: "SplitEditor",
  __ssrInlineRender: true,
  props: {
    path: { type: String, required: false },
    content: { type: String, required: false, default: "" }
  },
  emits: ["save"],
  setup(__props, { expose: __expose, emit: __emit }) {
    const props = __props;
    const emit = __emit;
    const docStore = useDocStore();
    const draft = ref(props.content);
    let selfUpdating = false;
    watch(() => props.content, async (c) => {
      if (c === draft.value) return;
      try {
        await docStore.whenLoaded(props.path || docStore.path);
      } catch {
      }
      selfUpdating = true;
      draft.value = c;
      selfUpdating = false;
    });
    watch(() => docStore.path, async (p) => {
      if (p !== props.path) return;
      try {
        await docStore.whenLoaded(p);
      } catch {
      }
      if (docStore.content !== draft.value) {
        selfUpdating = true;
        draft.value = docStore.content;
        selfUpdating = false;
      }
    });
    watch(draft, (v) => {
      if (!selfUpdating && docStore.path === props.path) docStore.update(v);
    });
    const showPreview = ref(true);
    const showOutline = ref(true);
    const showVersions = ref(false);
    const showDiff = ref(false);
    const showExcalidraw = ref(false);
    const outline = ref([]);
    const outlineLoading = ref(false);
    const activeOutlineLine = ref(null);
    const editorEl = ref(null);
    ref(null);
    ref(null);
    let lineOffsets = [];
    computed(() => true);
    const saving = ref(false);
    const lastSaved = ref("");
    const lastVersion = ref(0);
    const baseContent = ref("");
    const baseVersion = ref(0);
    const saveMessage = ref("");
    const versions = ref([]);
    const versionsLoading = ref(false);
    const versionsSorted = computed(() => [...versions.value].sort((a, b) => b.version_no - a.version_no));
    const diffLeft = ref(null);
    const diffRight = ref(null);
    const diffKey = computed(() => `${diffLeft.value || ""}-${diffRight.value || ""}`);
    const rendered = computed(() => DOMPurify.sanitize(marked.parse(draft.value || "")));
    function insertAtCursor(text) {
      var _a;
      const el = editorEl.value;
      if (!el) {
        draft.value = (draft.value || "") + "\n" + text;
        return;
      }
      const start = el.selectionStart || 0;
      const end = el.selectionEnd || 0;
      draft.value = (draft.value || "").slice(0, start) + text + (draft.value || "").slice(end);
      (_a = nextTick) == null ? void 0 : _a(() => {
        try {
          el.selectionStart = el.selectionEnd = start + text.length;
          el.focus();
        } catch {
        }
      });
    }
    const api = useKbApi();
    async function openAiMenu() {
      const choice = (void 0).prompt("AI \uC791\uC5C5 \uC120\uD0DD: table / mermaid / summary");
      if (!choice) return;
      const kind = choice.trim().toLowerCase();
      let sel = "";
      const el = editorEl.value;
      if (el && el.selectionStart !== void 0 && el.selectionEnd !== void 0 && el.selectionStart !== el.selectionEnd) {
        sel = (draft.value || "").slice(el.selectionStart, el.selectionEnd);
      } else {
        sel = draft.value || "";
      }
      try {
        const opts = {};
        if (kind === "table") {
          const cols = (void 0).prompt("\uC5F4 \uC218(\uCD5C\uB300 8, \uBE48\uCE78=\uC790\uB3D9):");
          if (cols) opts.cols = Math.min(8, Math.max(1, parseInt(cols) || 6));
          const rag = (void 0).confirm("RAG \uCEE8\uD14D\uC2A4\uD2B8 \uC0AC\uC6A9\uD560\uAE4C\uC694?");
          opts.use_rag = !!rag;
        } else if (kind === "mermaid") {
          const type = (void 0).prompt("\uB2E4\uC774\uC5B4\uADF8\uB7A8 \uC720\uD615(flow/sequence/gantt, \uBE48\uCE78=flow):");
          if (type) opts.diagramType = type;
          opts.use_rag = (void 0).confirm("RAG \uCEE8\uD14D\uC2A4\uD2B8 \uC0AC\uC6A9\uD560\uAE4C\uC694?");
        } else {
          const len = (void 0).prompt("\uC694\uC57D \uBB38\uC7A5 \uC218(\uAE30\uBCF8 5):");
          if (len) opts.summaryLen = Math.min(8, Math.max(1, parseInt(len) || 5));
          opts.use_rag = (void 0).confirm("RAG \uCEE8\uD14D\uC2A4\uD2B8 \uC0AC\uC6A9\uD560\uAE4C\uC694?");
        }
        const out = await api.transform(sel, kind === "table" ? "table" : kind === "mermaid" ? "mermaid" : "summary", opts);
        insertAtCursor("\n" + out.result + "\n");
      } catch (e) {
        try {
          alert(e && e.message || "AI \uBCC0\uD658 \uC2E4\uD328");
        } catch {
          alert("AI \uBCC0\uD658 \uC2E4\uD328");
        }
      }
    }
    function togglePreview() {
      showPreview.value = !showPreview.value;
    }
    function toggleOutline() {
      showOutline.value = !showOutline.value;
    }
    function toggleVersions() {
      if (!showVersions.value) {
        loadVersions();
      }
      showVersions.value = !showVersions.value;
    }
    async function toggleDiff() {
      if (!versions.value.length) {
        await loadVersions();
        if (!versions.value.length) return;
      }
      if (!showDiff.value) {
        await loadVersions();
        if (versionsSorted.value.length >= 2 && (!diffLeft.value || !diffRight.value)) {
          diffRight.value = versionsSorted.value[0].version_no;
          diffLeft.value = versionsSorted.value[1].version_no;
        }
      }
      showDiff.value = !showDiff.value;
    }
    async function requestOutline() {
      if (!draft.value) {
        outline.value = [];
        return;
      }
      outlineLoading.value = true;
      try {
        const api2 = useKbApi();
        const data = await api2.outline(draft.value);
        outline.value = data.outline || [];
      } finally {
        outlineLoading.value = false;
      }
    }
    function emitSave() {
      const api2 = useKbApi();
      saving.value = true;
      api2.lint(draft.value || "").then((res) => {
        const issues = res.issues || [];
        if (issues.length) {
          const top = issues.slice(0, 5).map((i) => `L${i.line}:${i.column} ${i.message}`).join("\n");
          const proceed = confirm(`Lint \uACBD\uACE0 ${issues.length}\uAC74

${top}

\uADF8\uB798\uB3C4 \uC800\uC7A5\uD560\uAE4C\uC694?`);
          if (!proceed) {
            saving.value = false;
            return;
          }
        }
        emit("save", { path: props.path, content: draft.value, message: saveMessage.value || void 0 });
      }).catch(() => {
        emit("save", { path: props.path, content: draft.value, message: saveMessage.value || void 0 });
      });
    }
    function cancelEdit() {
      draft.value = baseContent.value || draft.value;
      try {
        (void 0).dispatchEvent(new CustomEvent("kb:mode", { detail: { to: "view" } }));
      } catch {
      }
    }
    async function deleteCurrent() {
      try {
        const p = props.path;
        if (!p) return;
        const ok = confirm("\uC774 \uBB38\uC11C\uB97C \uD734\uC9C0\uD1B5\uC73C\uB85C \uC774\uB3D9\uD560\uAE4C\uC694?");
        if (!ok) return;
        const apiBase = resolveApiBase();
        const ts = (/* @__PURE__ */ new Date()).toISOString().replace(/[-:T.Z]/g, "").slice(0, 14);
        const trashPath = `.trash/${ts}/${p}`;
        await fetch(`${apiBase}/v1/knowledge-base/move`, { method: "POST", headers: { "Content-Type": "application/json", "X-API-Key": "my_mcp_eagle_tiger" }, body: JSON.stringify({ path: p, new_path: trashPath }) });
        try {
          (void 0).dispatchEvent(new CustomEvent("kb:deleted", { detail: { path: p, trashPath } }));
        } catch {
        }
      } catch {
        alert("\uC0AD\uC81C \uC2E4\uD328");
      }
    }
    function setSaved(meta) {
      saving.value = false;
      lastSaved.value = (/* @__PURE__ */ new Date()).toLocaleTimeString();
      lastVersion.value = (meta == null ? void 0 : meta.version_no) || lastVersion.value + 1;
      baseContent.value = draft.value;
      baseVersion.value = lastVersion.value;
      saveMessage.value = "";
      if (showVersions.value) loadVersions();
    }
    async function loadVersions() {
      if (!props.path) return;
      versionsLoading.value = true;
      try {
        const api2 = useKbApi();
        const data = await api2.listVersions(props.path);
        versions.value = data.versions || [];
      } finally {
        versionsLoading.value = false;
      }
    }
    watch(() => props.path, () => {
      requestOutline();
      buildLineOffsets();
    });
    watch(rendered, () => {
    });
    if (props.content) {
      baseContent.value = props.content;
      baseVersion.value = lastVersion.value;
    }
    const conflictActive = ref(false);
    const conflictLatestContent = ref("");
    const conflictLatestVersion = ref(0);
    const conflictStats = ref({ changedLocal: 0, changedUpstream: 0, conflicts: 0 });
    const conflictPreview = ref([]);
    const mergeResultMsg = ref("");
    function handleConflict(latestContent, latestVersion) {
      var _a, _b, _c;
      conflictActive.value = true;
      conflictLatestContent.value = latestContent;
      conflictLatestVersion.value = latestVersion;
      const baseLines = baseContent.value.split("\n");
      const localLines = draft.value.split("\n");
      const upstreamLines = latestContent.split("\n");
      const max = Math.max(baseLines.length, localLines.length, upstreamLines.length);
      let changedLocal = 0, changedUpstream = 0, conflicts = 0;
      for (let i = 0; i < max; i++) {
        const b = (_a = baseLines[i]) != null ? _a : "";
        const l = (_b = localLines[i]) != null ? _b : "";
        const u = (_c = upstreamLines[i]) != null ? _c : "";
        const localChanged = b !== l;
        const upstreamChanged = b !== u;
        if (localChanged) changedLocal++;
        if (upstreamChanged) changedUpstream++;
        if (localChanged && upstreamChanged && l !== u) conflicts++;
      }
      conflictStats.value = { changedLocal, changedUpstream, conflicts };
      buildConflictPreview(baseLines, localLines, upstreamLines);
    }
    function buildConflictPreview(baseLines, localLines, upstreamLines) {
      var _a, _b, _c;
      const preview = [];
      const limit = 40;
      for (let i = 0; i < limit; i++) {
        const b = (_a = baseLines[i]) != null ? _a : "";
        const l = (_b = localLines[i]) != null ? _b : "";
        const u = (_c = upstreamLines[i]) != null ? _c : "";
        if (l === u && b === l) {
          preview.push("  " + (l || ""));
        } else if (l === u && b !== l) {
          preview.push("~ " + (l || ""));
        } else if (l !== u) {
          preview.push("- " + (l || ""));
          preview.push("+ " + (u || ""));
        } else if (l !== b) {
          preview.push("- " + (l || ""));
        } else if (u !== b) {
          preview.push("+ " + (u || ""));
        }
      }
      conflictPreview.value = preview;
    }
    function diffClass(line) {
      if (line.startsWith("+")) return "text-green-600";
      if (line.startsWith("-")) return "text-red-600";
      if (line.startsWith("~")) return "text-indigo-600";
      return "text-gray-500";
    }
    function buildLineOffsets() {
      const text = draft.value || "";
      const compute = () => {
        const lines = text.split("\n");
        lineOffsets = new Array(lines.length);
        let acc = 0;
        for (let i = 0; i < lines.length; i++) {
          lineOffsets[i] = acc;
          acc += lines[i].length + 1;
        }
      };
      if (text.length > 2e4 && false) ;
      else {
        compute();
      }
    }
    __expose({ setSaved, lastVersion, draft, handleConflict });
    const showTableModal = ref(false);
    const tableRows = ref(4);
    const tableCols = ref(3);
    const tableHeader = ref(true);
    const showMermaidModal = ref(false);
    const mermaidType = ref("flow");
    const mermaidCode = ref("");
    const mermaidPreviewMount = ref(null);
    function openMermaidModal() {
      showMermaidModal.value = true;
      if (!mermaidCode.value) {
        mermaidCode.value = mermaidTemplate(mermaidType.value).replace(/^```mermaid\n|```\n?$/g, "");
      }
      nextTick(() => renderMermaidPreview());
    }
    function renderMermaidPreview() {
      try {
        if (!mermaidPreviewMount.value) return;
        const code = mermaidCode.value || "";
        mermaid.initialize({ startOnLoad: false, theme: "default" });
        const id = "m" + Math.random().toString(36).slice(2);
        mermaid.render(id, code).then(({ svg }) => {
          mermaidPreviewMount.value.innerHTML = svg;
        }).catch(() => {
          mermaidPreviewMount.value.innerHTML = '<div class="text-xs text-red-600">Render failed</div>';
        });
      } catch {
        try {
          mermaidPreviewMount.value.innerHTML = '<div class="text-xs text-red-600">Render failed</div>';
        } catch {
        }
      }
    }
    const showChartModal = ref(false);
    const chartSpec = ref(vegaLiteBarSpec());
    const chartPreviewMount = ref(null);
    function openChartModal() {
      showChartModal.value = true;
      nextTick(() => renderChartPreview());
    }
    async function renderChartPreview() {
      if (!chartPreviewMount.value) return;
      chartPreviewMount.value.innerHTML = "";
      try {
        const spec = JSON.parse(chartSpec.value);
        await embed(chartPreviewMount.value, spec, { actions: false });
      } catch {
        chartPreviewMount.value.innerHTML = '<div class="text-xs text-red-600">Invalid Vega-Lite JSON</div>';
      }
    }
    const showImageModal = ref(false);
    const imageUrl = ref("");
    const imageAlt = ref("");
    const imageTitle = ref("");
    const imageWidth = ref(null);
    function openImageModal() {
      showImageModal.value = true;
    }
    return (_ctx, _push, _parent, _attrs) => {
      var _a;
      _push(`<div${ssrRenderAttrs(mergeProps({ class: "flex h-full w-full overflow-hidden" }, _attrs))} data-v-ba6e7bda>`);
      if (showOutline.value) {
        _push(`<div class="w-56 flex-none border-r bg-gray-50 flex flex-col" data-v-ba6e7bda><div class="p-2 font-semibold text-xs tracking-wide text-gray-600 border-b" data-v-ba6e7bda>OUTLINE</div><div class="flex-1 overflow-auto text-sm" role="tree" aria-label="Document outline" data-v-ba6e7bda><ul data-v-ba6e7bda><!--[-->`);
        ssrRenderList(outline.value, (item) => {
          _push(`<li role="none" data-v-ba6e7bda><button role="treeitem"${ssrRenderAttr("aria-current", activeOutlineLine.value && item.line === activeOutlineLine.value ? "true" : "false")} class="${ssrRenderClass([["pl-" + item.level * 2, activeOutlineLine.value && item.line === activeOutlineLine.value ? "bg-indigo-100 text-indigo-700" : ""], "block w-full text-left px-2 py-1 hover:bg-indigo-50 rounded focus:outline-none focus:ring-1 focus:ring-indigo-400"])}"${ssrRenderAttr("title", `Line ${item.line}`)} data-v-ba6e7bda><span class="${ssrRenderClass({ "font-semibold": item.level === 1 })}" data-v-ba6e7bda>#${ssrInterpolate(item.level)} ${ssrInterpolate(item.text)}</span></button></li>`);
        });
        _push(`<!--]--></ul></div></div>`);
      } else {
        _push(`<!---->`);
      }
      _push(`<div class="flex-1 flex flex-col" data-v-ba6e7bda>`);
      _push(ssrRenderComponent(_sfc_main$6, {
        saving: saving.value,
        "save-label": "Save",
        "cancel-label": "Cancel",
        "delete-label": "Delete",
        "saving-text": "Saving...",
        "aria-label": "Markdown toolbar",
        onSave: emitSave,
        onCancel: cancelEdit,
        onDelete: deleteCurrent
      }, {
        right: withCtx((_, _push2, _parent2, _scopeId) => {
          if (_push2) {
            _push2(`<button class="px-2 py-1 rounded bg-gray-200 hover:bg-gray-300" data-v-ba6e7bda${_scopeId}>${ssrInterpolate(showPreview.value ? "Editor Only" : "Split")}</button>`);
          } else {
            return [
              createVNode("button", {
                onClick: togglePreview,
                class: "px-2 py-1 rounded bg-gray-200 hover:bg-gray-300"
              }, toDisplayString(showPreview.value ? "Editor Only" : "Split"), 1)
            ];
          }
        }),
        default: withCtx((_, _push2, _parent2, _scopeId) => {
          if (_push2) {
            _push2(`<input${ssrRenderAttr("value", saveMessage.value)} placeholder="commit message" class="px-2 py-1 text-xs border rounded w-48 focus:outline-none focus:ring" data-v-ba6e7bda${_scopeId}><button class="px-2 py-1 rounded bg-gray-200 hover:bg-gray-300" data-v-ba6e7bda${_scopeId}>Outline</button><button class="px-2 py-1 rounded bg-gray-200 hover:bg-gray-300" data-v-ba6e7bda${_scopeId}>Versions</button><button class="px-2 py-1 rounded bg-gray-200 hover:bg-gray-300"${ssrIncludeBooleanAttr(!versions.value.length) ? " disabled" : ""} data-v-ba6e7bda${_scopeId}>Diff</button><button class="px-2 py-1 rounded bg-gray-200 hover:bg-gray-300"${ssrIncludeBooleanAttr(outlineLoading.value) ? " disabled" : ""} data-v-ba6e7bda${_scopeId}>Refresh Outline</button>`);
            if (saving.value) {
              _push2(`<span class="text-gray-500 text-xs" data-v-ba6e7bda${_scopeId}>Saving...</span>`);
            } else {
              _push2(`<!---->`);
            }
            if (lastSaved.value) {
              _push2(`<span class="text-gray-400 text-xs" data-v-ba6e7bda${_scopeId}>v${ssrInterpolate(lastVersion.value)} @ ${ssrInterpolate(lastSaved.value)}</span>`);
            } else {
              _push2(`<!---->`);
            }
            _push2(`<div class="flex-1" data-v-ba6e7bda${_scopeId}></div><div class="flex items-center gap-1" data-v-ba6e7bda${_scopeId}><button class="px-2 py-1 rounded bg-gray-200 hover:bg-gray-300" data-v-ba6e7bda${_scopeId}>Table</button><button class="px-2 py-1 rounded bg-gray-200 hover:bg-gray-300" data-v-ba6e7bda${_scopeId}>Mermaid</button><button class="px-2 py-1 rounded bg-gray-200 hover:bg-gray-300" data-v-ba6e7bda${_scopeId}>Chart</button><button class="px-2 py-1 rounded bg-gray-200 hover:bg-gray-300" data-v-ba6e7bda${_scopeId}>Image</button><button class="px-2 py-1 rounded bg-indigo-50 hover:bg-indigo-100 text-indigo-700" data-v-ba6e7bda${_scopeId}>AI</button><button class="px-2 py-1 rounded bg-gray-200 hover:bg-gray-300" data-v-ba6e7bda${_scopeId}>Draw</button></div>`);
          } else {
            return [
              withDirectives(createVNode("input", {
                "onUpdate:modelValue": ($event) => saveMessage.value = $event,
                placeholder: "commit message",
                class: "px-2 py-1 text-xs border rounded w-48 focus:outline-none focus:ring"
              }, null, 8, ["onUpdate:modelValue"]), [
                [vModelText, saveMessage.value]
              ]),
              createVNode("button", {
                onClick: toggleOutline,
                class: "px-2 py-1 rounded bg-gray-200 hover:bg-gray-300"
              }, "Outline"),
              createVNode("button", {
                onClick: toggleVersions,
                class: "px-2 py-1 rounded bg-gray-200 hover:bg-gray-300"
              }, "Versions"),
              createVNode("button", {
                onClick: toggleDiff,
                class: "px-2 py-1 rounded bg-gray-200 hover:bg-gray-300",
                disabled: !versions.value.length
              }, "Diff", 8, ["disabled"]),
              createVNode("button", {
                onClick: requestOutline,
                class: "px-2 py-1 rounded bg-gray-200 hover:bg-gray-300",
                disabled: outlineLoading.value
              }, "Refresh Outline", 8, ["disabled"]),
              saving.value ? (openBlock(), createBlock("span", {
                key: 0,
                class: "text-gray-500 text-xs"
              }, "Saving...")) : createCommentVNode("", true),
              lastSaved.value ? (openBlock(), createBlock("span", {
                key: 1,
                class: "text-gray-400 text-xs"
              }, "v" + toDisplayString(lastVersion.value) + " @ " + toDisplayString(lastSaved.value), 1)) : createCommentVNode("", true),
              createVNode("div", { class: "flex-1" }),
              createVNode("div", { class: "flex items-center gap-1" }, [
                createVNode("button", {
                  onClick: ($event) => showTableModal.value = true,
                  class: "px-2 py-1 rounded bg-gray-200 hover:bg-gray-300"
                }, "Table", 8, ["onClick"]),
                createVNode("button", {
                  onClick: ($event) => openMermaidModal(),
                  class: "px-2 py-1 rounded bg-gray-200 hover:bg-gray-300"
                }, "Mermaid", 8, ["onClick"]),
                createVNode("button", {
                  onClick: ($event) => openChartModal(),
                  class: "px-2 py-1 rounded bg-gray-200 hover:bg-gray-300"
                }, "Chart", 8, ["onClick"]),
                createVNode("button", {
                  onClick: ($event) => openImageModal(),
                  class: "px-2 py-1 rounded bg-gray-200 hover:bg-gray-300"
                }, "Image", 8, ["onClick"]),
                createVNode("button", {
                  onClick: openAiMenu,
                  class: "px-2 py-1 rounded bg-indigo-50 hover:bg-indigo-100 text-indigo-700"
                }, "AI"),
                createVNode("button", {
                  onClick: ($event) => showExcalidraw.value = true,
                  class: "px-2 py-1 rounded bg-gray-200 hover:bg-gray-300"
                }, "Draw", 8, ["onClick"])
              ])
            ];
          }
        }),
        _: 1
      }, _parent));
      _push(`<div class="flex flex-1 min-h-0" data-v-ba6e7bda>`);
      if (conflictActive.value) {
        _push(`<div class="absolute inset-0 z-20 flex" data-v-ba6e7bda><div class="w-96 h-full border-r bg-white flex flex-col shadow-xl" data-v-ba6e7bda><div class="p-3 border-b bg-amber-50 flex items-center gap-2 text-xs font-semibold text-amber-700" data-v-ba6e7bda> Conflict Detected <span class="ml-auto text-[10px] text-amber-600" data-v-ba6e7bda>local vs upstream v${ssrInterpolate(conflictLatestVersion.value)}</span></div><div class="p-3 flex-1 overflow-auto text-xs space-y-3" data-v-ba6e7bda><div class="space-y-1" data-v-ba6e7bda><div class="font-semibold text-gray-700" data-v-ba6e7bda>Stats</div><ul class="list-disc ml-4 text-gray-600" data-v-ba6e7bda><li data-v-ba6e7bda>Local changed lines: ${ssrInterpolate(conflictStats.value.changedLocal)}</li><li data-v-ba6e7bda>Upstream changed lines: ${ssrInterpolate(conflictStats.value.changedUpstream)}</li><li data-v-ba6e7bda>Potential conflicts: ${ssrInterpolate(conflictStats.value.conflicts)}</li></ul></div><div data-v-ba6e7bda><div class="font-semibold text-gray-700 mb-1" data-v-ba6e7bda>Preview (first 40 lines diff)</div><pre class="bg-gray-900 text-gray-100 p-2 rounded max-h-60 overflow-auto text-[11px] leading-snug" data-v-ba6e7bda><!--[-->`);
        ssrRenderList(conflictPreview.value, (l, i) => {
          _push(`<span class="${ssrRenderClass(diffClass(l))}" data-v-ba6e7bda>${ssrInterpolate(l)}
</span>`);
        });
        _push(`<!--]--></pre></div><div class="space-y-2" data-v-ba6e7bda><button class="w-full px-2 py-1 text-xs rounded bg-indigo-600 text-white hover:bg-indigo-500" data-v-ba6e7bda>Auto Merge (Trivial)</button><button class="w-full px-2 py-1 text-xs rounded bg-red-600 text-white hover:bg-red-500" data-v-ba6e7bda>Overwrite With Mine</button><button class="w-full px-2 py-1 text-xs rounded bg-blue-600 text-white hover:bg-blue-500" data-v-ba6e7bda>Accept Upstream</button><button class="w-full px-2 py-1 text-xs rounded bg-gray-200 hover:bg-gray-300 text-gray-700" data-v-ba6e7bda>Dismiss</button></div>`);
        if (mergeResultMsg.value) {
          _push(`<div class="text-[10px] text-indigo-700 whitespace-pre-line border border-indigo-200 bg-indigo-50 px-2 py-1 rounded" data-v-ba6e7bda>${ssrInterpolate(mergeResultMsg.value)}</div>`);
        } else {
          _push(`<!---->`);
        }
        _push(`<p class="text-[10px] text-gray-500 leading-relaxed" data-v-ba6e7bda>\uC790\uB3D9 \uBCD1\uD569\uC740 \uC904 \uBC30\uC5F4\uC774 \uB3D9\uC77C\uD560 \uB54C\uB9CC \uC218\uD589\uD569\uB2C8\uB2E4. \uCDA9\uB3CC \uB9C8\uCEE4(&lt;&lt;&lt;&lt;&lt;&lt;&lt; &gt;&gt;&gt;&gt;&gt;&gt;&gt;)\uAC00 \uB0A8\uC544 \uC788\uB2E4\uBA74 \uC218\uB3D9 \uD3B8\uC9D1 \uD6C4 \uB2E4\uC2DC \uC800\uC7A5\uD558\uC138\uC694.</p></div></div><div class="flex-1 h-full relative bg-white/70 backdrop-blur-sm" data-v-ba6e7bda></div></div>`);
      } else {
        _push(`<!---->`);
      }
      _push(`<div class="flex-1 flex flex-col" data-v-ba6e7bda><textarea class="flex-1 font-mono text-sm p-3 outline-none resize-none" data-v-ba6e7bda>${ssrInterpolate(draft.value)}</textarea></div>`);
      if (showPreview.value && !showDiff.value) {
        _push(`<div class="flex-1 flex min-h-0 overflow-hidden" data-v-ba6e7bda><div class="flex-1 min-h-0 border-l overflow-auto p-4 prose max-w-none bg-white" data-v-ba6e7bda><div data-v-ba6e7bda>${(_a = rendered.value) != null ? _a : ""}</div></div></div>`);
      } else {
        _push(`<!---->`);
      }
      if (showDiff.value) {
        _push(`<div class="flex-1 border-l bg-white" data-v-ba6e7bda>`);
        if (versions.value.length) {
          _push(ssrRenderComponent(_sfc_main$7, {
            key: diffKey.value,
            path: __props.path,
            versions: versionsSorted.value,
            "default-left": diffLeft.value,
            "default-right": diffRight.value,
            onClose: ($event) => showDiff.value = false
          }, null, _parent));
        } else {
          _push(`<!---->`);
        }
        _push(`</div>`);
      } else {
        _push(`<!---->`);
      }
      _push(`</div>`);
      if (showExcalidraw.value) {
        _push(`<div class="absolute inset-0 z-30 bg-black/40 flex items-center justify-center" data-v-ba6e7bda><div class="w-[900px] h-[600px] bg-white rounded shadow flex flex-col" data-v-ba6e7bda><div class="p-2 border-b text-sm flex items-center" data-v-ba6e7bda>Sketch <div class="flex-1" data-v-ba6e7bda></div><button class="px-2 py-1 text-xs border rounded mr-2" data-v-ba6e7bda>Export &amp; Insert</button><button class="px-2 py-1 text-xs border rounded" data-v-ba6e7bda>Close</button></div><iframe src="https://excalidraw.com" class="flex-1" data-v-ba6e7bda></iframe></div></div>`);
      } else {
        _push(`<!---->`);
      }
      if (showTableModal.value) {
        _push(`<div class="absolute inset-0 z-30 bg-black/40 flex items-center justify-center" data-v-ba6e7bda><div class="w-[420px] bg-white rounded shadow flex flex-col" data-v-ba6e7bda><div class="p-2 border-b text-sm flex items-center" data-v-ba6e7bda>Insert Table<div class="flex-1" data-v-ba6e7bda></div><button class="px-2 py-1 text-xs border rounded" data-v-ba6e7bda>Close</button></div><div class="p-3 space-y-2 text-sm" data-v-ba6e7bda><div class="flex items-center gap-2" data-v-ba6e7bda><label class="w-24" data-v-ba6e7bda>Rows</label><input${ssrRenderAttr("value", tableRows.value)} type="number" min="1" max="50" class="border rounded px-2 py-1 w-24" data-v-ba6e7bda><label class="w-24" data-v-ba6e7bda>Cols</label><input${ssrRenderAttr("value", tableCols.value)} type="number" min="1" max="20" class="border rounded px-2 py-1 w-24" data-v-ba6e7bda></div><label class="inline-flex items-center gap-2" data-v-ba6e7bda><input type="checkbox"${ssrIncludeBooleanAttr(Array.isArray(tableHeader.value) ? ssrLooseContain(tableHeader.value, null) : tableHeader.value) ? " checked" : ""} data-v-ba6e7bda><span data-v-ba6e7bda>With header</span></label><div class="text-[11px] text-gray-500" data-v-ba6e7bda>A markdown table will be inserted at the cursor.</div><div class="pt-2 flex items-center justify-end" data-v-ba6e7bda><button class="px-2 py-1 text-xs rounded bg-indigo-600 text-white" data-v-ba6e7bda>Insert</button></div></div></div></div>`);
      } else {
        _push(`<!---->`);
      }
      if (showMermaidModal.value) {
        _push(`<div class="absolute inset-0 z-30 bg-black/40 flex items-center justify-center" data-v-ba6e7bda><div class="w-[900px] h-[600px] bg-white rounded shadow flex flex-col" data-v-ba6e7bda><div class="p-2 border-b text-sm flex items-center" data-v-ba6e7bda>Insert Mermaid Diagram<div class="flex-1" data-v-ba6e7bda></div><button class="px-2 py-1 text-xs border rounded mr-2" data-v-ba6e7bda>Close</button><button class="px-2 py-1 text-xs rounded bg-indigo-600 text-white" data-v-ba6e7bda>Insert</button></div><div class="flex-1 grid grid-cols-2 min-h-0" data-v-ba6e7bda><div class="p-3 space-y-2 border-r min-h-0 flex flex-col" data-v-ba6e7bda><div class="flex items-center gap-2 text-sm" data-v-ba6e7bda><label class="w-24" data-v-ba6e7bda>Type</label><select class="border rounded px-2 py-1" data-v-ba6e7bda><option value="flow" data-v-ba6e7bda${ssrIncludeBooleanAttr(Array.isArray(mermaidType.value) ? ssrLooseContain(mermaidType.value, "flow") : ssrLooseEqual(mermaidType.value, "flow")) ? " selected" : ""}>flow</option><option value="sequence" data-v-ba6e7bda${ssrIncludeBooleanAttr(Array.isArray(mermaidType.value) ? ssrLooseContain(mermaidType.value, "sequence") : ssrLooseEqual(mermaidType.value, "sequence")) ? " selected" : ""}>sequence</option><option value="gantt" data-v-ba6e7bda${ssrIncludeBooleanAttr(Array.isArray(mermaidType.value) ? ssrLooseContain(mermaidType.value, "gantt") : ssrLooseEqual(mermaidType.value, "gantt")) ? " selected" : ""}>gantt</option></select></div><textarea class="flex-1 font-mono text-xs p-2 border rounded resize-none" placeholder="Mermaid code" data-v-ba6e7bda>${ssrInterpolate(mermaidCode.value)}</textarea></div><div class="p-3 min-h-0 overflow-auto" data-v-ba6e7bda><div data-v-ba6e7bda></div></div></div></div></div>`);
      } else {
        _push(`<!---->`);
      }
      if (showChartModal.value) {
        _push(`<div class="absolute inset-0 z-30 bg-black/40 flex items-center justify-center" data-v-ba6e7bda><div class="w-[1000px] h-[650px] bg-white rounded shadow flex flex-col" data-v-ba6e7bda><div class="p-2 border-b text-sm flex items-center" data-v-ba6e7bda>Insert Chart (Vega-Lite)<div class="flex-1" data-v-ba6e7bda></div><button class="px-2 py-1 text-xs border rounded mr-2" data-v-ba6e7bda>Close</button><button class="px-2 py-1 text-xs rounded bg-indigo-600 text-white" data-v-ba6e7bda>Insert</button></div><div class="flex-1 grid grid-cols-2 min-h-0" data-v-ba6e7bda><div class="p-3 space-y-2 border-r min-h-0 flex flex-col" data-v-ba6e7bda><div class="text-xs text-gray-600" data-v-ba6e7bda>Paste or edit a Vega-Lite spec JSON. A preview will render on the right.</div><textarea class="flex-1 font-mono text-xs p-2 border rounded resize-none"${ssrRenderAttr("placeholder", chartPlaceholder)} data-v-ba6e7bda>${ssrInterpolate(chartSpec.value)}</textarea></div><div class="p-3 min-h-0 overflow-auto" data-v-ba6e7bda><div data-v-ba6e7bda></div></div></div></div></div>`);
      } else {
        _push(`<!---->`);
      }
      if (showImageModal.value) {
        _push(`<div class="absolute inset-0 z-30 bg-black/40 flex items-center justify-center" data-v-ba6e7bda><div class="w-[520px] bg-white rounded shadow flex flex-col" data-v-ba6e7bda><div class="p-2 border-b text-sm flex items-center" data-v-ba6e7bda>Insert Image<div class="flex-1" data-v-ba6e7bda></div><button class="px-2 py-1 text-xs border rounded mr-2" data-v-ba6e7bda>Close</button><button class="px-2 py-1 text-xs rounded bg-indigo-600 text-white" data-v-ba6e7bda>Insert</button></div><div class="p-3 space-y-3 text-sm" data-v-ba6e7bda><div class="space-y-1" data-v-ba6e7bda><label data-v-ba6e7bda>Image URL</label><input${ssrRenderAttr("value", imageUrl.value)} type="text" placeholder="https://... or /assets/..." class="w-full border rounded px-2 py-1" data-v-ba6e7bda><div class="text-[11px] text-gray-500" data-v-ba6e7bda>Or upload a file below to get a URL.</div><input type="file" accept="image/*" data-v-ba6e7bda></div><div class="flex items-center gap-2" data-v-ba6e7bda><label class="w-20" data-v-ba6e7bda>Alt</label><input${ssrRenderAttr("value", imageAlt.value)} type="text" class="flex-1 border rounded px-2 py-1" data-v-ba6e7bda></div><div class="flex items-center gap-2" data-v-ba6e7bda><label class="w-20" data-v-ba6e7bda>Title</label><input${ssrRenderAttr("value", imageTitle.value)} type="text" class="flex-1 border rounded px-2 py-1" data-v-ba6e7bda></div><div class="flex items-center gap-2" data-v-ba6e7bda><label class="w-20" data-v-ba6e7bda>Width</label><input${ssrRenderAttr("value", imageWidth.value)} type="number" min="1" max="4000" placeholder="optional" class="border rounded px-2 py-1 w-32" data-v-ba6e7bda><span class="text-[11px] text-gray-500" data-v-ba6e7bda>px (optional)</span></div></div></div></div>`);
      } else {
        _push(`<!---->`);
      }
      _push(`</div></div>`);
    };
  }
};
const _sfc_setup$5 = _sfc_main$5.setup;
_sfc_main$5.setup = (props, ctx) => {
  const ssrContext = useSSRContext();
  (ssrContext.modules || (ssrContext.modules = /* @__PURE__ */ new Set())).add("components/SplitEditor.vue");
  return _sfc_setup$5 ? _sfc_setup$5(props, ctx) : void 0;
};
const SplitEditor = /* @__PURE__ */ _export_sfc(_sfc_main$5, [["__scopeId", "data-v-ba6e7bda"]]);
const _sfc_main$4 = {
  __name: "WorkspaceView",
  __ssrInlineRender: true,
  props: {
    activeContent: String,
    activeSlide: Object,
    activePath: String,
    readonly: { type: Boolean, default: false }
  },
  setup(__props) {
    defineAsyncComponent(() => import('./TipTapKbEditor.client-CW18LzFa.mjs'));
    const props = __props;
    const activeComponent = shallowRef(_sfc_main$a);
    computed(() => {
      if (activeComponent.value === _sfc_main$a) {
        return {
          content: props.activeContent,
          slide: props.activeSlide,
          path: props.activePath,
          readonly: props.readonly
        };
      } else if (activeComponent.value === SplitEditor) {
        return { path: props.activePath, content: props.activeContent };
      }
      return {};
    });
    watch(() => props.activeContent, (newContent) => {
      if (newContent) {
        activeComponent.value = _sfc_main$a;
      }
    });
    return (_ctx, _push, _parent, _attrs) => {
      const _component_ClientOnly = __nuxt_component_0;
      _push(`<div${ssrRenderAttrs(mergeProps({ class: "h-full flex flex-col" }, _attrs))}><div class="flex-grow overflow-y-auto p-6 bg-white">`);
      _push(ssrRenderComponent(_component_ClientOnly, null, {}, _parent));
      _push(`</div></div>`);
    };
  }
};
const _sfc_setup$4 = _sfc_main$4.setup;
_sfc_main$4.setup = (props, ctx) => {
  const ssrContext = useSSRContext();
  (ssrContext.modules || (ssrContext.modules = /* @__PURE__ */ new Set())).add("components/WorkspaceView.vue");
  return _sfc_setup$4 ? _sfc_setup$4(props, ctx) : void 0;
};
const _sfc_main$3 = {
  __name: "AIAssistantPanel",
  __ssrInlineRender: true,
  setup(__props) {
    process.env.MCP_API_KEY || "my_mcp_eagle_tiger";
    const input = ref("");
    ref(null);
    ref(null);
    const loading = ref(false);
    ref("");
    const topics = ref([]);
    const activeTopicId = ref("");
    const placeholderText = computed(() => `/cli gcloud auth list \uB610\uB294 AI\uC5D0\uAC8C \uC9C8\uBB38`);
    const activeTopic = computed(() => topics.value.find((t) => t.id === activeTopicId.value));
    const activeMessages = computed(() => activeTopic.value ? activeTopic.value.messages : []);
    function formatMessage(text) {
      return text.replace(/\*\*(.*?)\*\*/g, "<strong>$1</strong>").replace(/\*(.*?)\*/g, "<em>$1</em>").replace(/`(.*?)`/g, '<code class="bg-gray-200 px-1 py-0.5 rounded text-sm">$1</code>').replace(/\n/g, "<br>");
    }
    watch(activeTopicId, (newId) => {
    });
    return (_ctx, _push, _parent, _attrs) => {
      _push(`<div${ssrRenderAttrs(mergeProps({ class: "h-full flex flex-col bg-white" }, _attrs))}><div class="flex-grow overflow-y-auto p-4 space-y-2">`);
      if (activeMessages.value.length) {
        _push(`<!--[-->`);
        ssrRenderList(activeMessages.value, (m, i) => {
          var _a;
          _push(`<div class="${ssrRenderClass(m.role === "user" ? "text-right" : "text-left")}"><div class="${ssrRenderClass(m.role === "user" ? "inline-block bg-blue-100 rounded px-3 py-2" : "inline-block bg-gray-100 rounded px-3 py-2")}">`);
          if (m.mode === "cli") {
            _push(`<pre class="whitespace-pre-wrap font-mono text-xs">${ssrInterpolate(m.text)}</pre>`);
          } else {
            _push(`<div class="text-sm">${(_a = formatMessage(m.text)) != null ? _a : ""}</div>`);
          }
          _push(`</div></div>`);
        });
        _push(`<!--]-->`);
      } else {
        _push(`<div class="h-full flex flex-col items-center justify-center text-center text-gray-500 select-none"><div class="text-2xl font-semibold mb-2">\uC900\uBE44\uB418\uBA74 \uC598\uAE30\uD574 \uC8FC\uC138\uC694.</div><div class="text-sm mb-4">/cli \uB85C \uC2DC\uC791\uD558\uBA74 \uC2DC\uC2A4\uD15C \uBA85\uB839\uC744 \uC2E4\uD589\uD569\uB2C8\uB2E4.</div><div class="flex gap-2"><button class="px-3 py-1 border rounded-full text-xs">gcloud auth list</button><button class="px-3 py-1 border rounded-full text-xs">AWS vs GCP</button><button class="px-3 py-1 border rounded-full text-xs">VPC \uC124\uACC4</button></div></div>`);
      }
      _push(`</div><div class="border-t border-gray-200 p-5 flex-shrink-0"><form class="flex items-center gap-2"><div class="flex-1 relative"><input${ssrRenderAttr("value", input.value)} type="text"${ssrRenderAttr("placeholder", placeholderText.value)} class="w-full px-4 py-3 border border-gray-300 rounded-full focus:outline-none focus:ring-2 focus:ring-blue-500"${ssrIncludeBooleanAttr(loading.value) ? " disabled" : ""}><div class="absolute right-3 top-1/2 -translate-y-1/2 flex items-center gap-2 text-gray-400"><span title="\uC74C\uC131 \uC785\uB825(\uD5A5\uD6C4)">\u{1F3A4}</span></div></div><button class="px-4 py-2 bg-blue-600 text-white rounded-full"${ssrIncludeBooleanAttr(loading.value || !input.value.trim()) ? " disabled" : ""}>\uC804\uC1A1</button></form>`);
      if (loading.value) {
        _push(`<p class="text-xs text-gray-500 mt-2">\uCC98\uB9AC \uC911...</p>`);
      } else {
        _push(`<!---->`);
      }
      _push(`</div></div>`);
    };
  }
};
const _sfc_setup$3 = _sfc_main$3.setup;
_sfc_main$3.setup = (props, ctx) => {
  const ssrContext = useSSRContext();
  (ssrContext.modules || (ssrContext.modules = /* @__PURE__ */ new Set())).add("components/AIAssistantPanel.vue");
  return _sfc_setup$3 ? _sfc_setup$3(props, ctx) : void 0;
};
const _sfc_main$2 = {
  __name: "TaskStatusBar",
  __ssrInlineRender: true,
  setup(__props) {
    const tasks = ref([]);
    return (_ctx, _push, _parent, _attrs) => {
      _push(`<div${ssrRenderAttrs(mergeProps({ class: "h-6 text-xs flex items-center gap-4 px-3 border-t bg-white/90 backdrop-blur" }, _attrs))}><!--[-->`);
      ssrRenderList(tasks.value, (t) => {
        _push(`<div class="flex items-center gap-1"><span class="text-gray-500">${ssrInterpolate(t.type)}:</span><div class="w-40 bg-gray-200 h-2 rounded overflow-hidden"><div class="h-full bg-indigo-500 transition-all" style="${ssrRenderStyle({ width: (t.progress || 0) + "%" })}"></div></div><span class="text-gray-500">${ssrInterpolate(t.progress || 0)}%</span></div>`);
      });
      _push(`<!--]-->`);
      if (!tasks.value.length) {
        _push(`<div class="text-gray-400">No active tasks</div>`);
      } else {
        _push(`<!---->`);
      }
      _push(`</div>`);
    };
  }
};
const _sfc_setup$2 = _sfc_main$2.setup;
_sfc_main$2.setup = (props, ctx) => {
  const ssrContext = useSSRContext();
  (ssrContext.modules || (ssrContext.modules = /* @__PURE__ */ new Set())).add("components/TaskStatusBar.vue");
  return _sfc_setup$2 ? _sfc_setup$2(props, ctx) : void 0;
};
const _sfc_main$1 = /* @__PURE__ */ defineComponent({
  __name: "ToastStack",
  __ssrInlineRender: true,
  setup(__props) {
    const toast = useToastStore();
    const { items } = storeToRefs(toast);
    toast.remove;
    function typeClass(t) {
      if (t === "success") return "bg-green-600 text-white";
      if (t === "error") return "bg-red-600 text-white";
      if (t === "warn") return "bg-yellow-500 text-white";
      return "bg-slate-700 text-white";
    }
    function icon(t) {
      if (t === "success") return "\u2714";
      if (t === "error") return "\u2716";
      if (t === "warn") return "!";
      return "\u2139";
    }
    return (_ctx, _push, _parent, _attrs) => {
      _push(`<div${ssrRenderAttrs(mergeProps({ class: "fixed top-4 right-4 space-y-2 z-50 w-80" }, _attrs))} data-v-4b6192b5><div${ssrRenderAttrs({ name: "toast-fade" })} data-v-4b6192b5>`);
      ssrRenderList(unref(items), (t) => {
        _push(`<div class="${ssrRenderClass([typeClass(t.type), "px-4 py-3 rounded shadow text-sm flex items-start gap-2"])}" data-v-4b6192b5><span class="font-medium" data-v-4b6192b5>${ssrInterpolate(icon(t.type))}</span><span class="flex-1 whitespace-pre-wrap" data-v-4b6192b5>${ssrInterpolate(t.msg)} `);
        if (t.link) {
          _push(`<button class="ml-2 underline text-white/90 hover:text-white" data-v-4b6192b5>${ssrInterpolate(t.link.label)}</button>`);
        } else {
          _push(`<!---->`);
        }
        _push(`</span><button class="opacity-60 hover:opacity-100" aria-label="\uB2EB\uAE30" data-v-4b6192b5>\xD7</button></div>`);
      });
      _push(`</div></div>`);
    };
  }
});
const _sfc_setup$1 = _sfc_main$1.setup;
_sfc_main$1.setup = (props, ctx) => {
  const ssrContext = useSSRContext();
  (ssrContext.modules || (ssrContext.modules = /* @__PURE__ */ new Set())).add("components/ToastStack.vue");
  return _sfc_setup$1 ? _sfc_setup$1(props, ctx) : void 0;
};
const ToastStack = /* @__PURE__ */ _export_sfc(_sfc_main$1, [["__scopeId", "data-v-4b6192b5"]]);
function useSidebarResize(initial = 256, min = 200, max = 500) {
  const isCollapsed = ref(false);
  const width = ref(initial);
  const toggle = () => {
    isCollapsed.value = !isCollapsed.value;
  };
  const start = () => {
  };
  return { isCollapsed, width, toggle, start };
}
const _sfc_main = {
  __name: "default",
  __ssrInlineRender: true,
  setup(__props) {
    var _a;
    const toast = useToastStore();
    const user = useState("user", () => null);
    const auth = useAuthStore();
    const userMenuOpen = ref(false);
    async function fetchCurrentUser() {
      try {
        if (!auth.token) {
          user.value = null;
          auth.setUser(null, null);
          return;
        }
        console.log("Fetching user with token:", auth.token);
        const headers = {
          "X-API-Key": apiKey,
          "Authorization": `Bearer ${auth.token}`
        };
        const { data: fetchedUser, error } = await useFetch("/api/v1/users/me", {
          key: auth.token,
          lazy: false,
          headers,
          server: false,
          retry: 0
        }, "$6ckdPRX2kF");
        if (error.value) {
          user.value = null;
          auth.setUser(null, null);
          return;
        }
        if (fetchedUser.value) {
          user.value = fetchedUser.value;
          auth.setUser(fetchedUser.value.email || null, fetchedUser.value.role || null);
        }
      } catch {
        user.value = null;
        auth.setUser(null, null);
      }
    }
    watch(() => auth.token, async (newToken, oldToken) => {
      if (newToken !== oldToken) {
        user.value = null;
        auth.setUser(null, null);
      }
      if (newToken) {
        await fetchCurrentUser();
      } else {
        user.value = null;
        auth.setUser(null, null);
      }
    }, { immediate: true });
    watch(() => {
      var _a2;
      return (_a2 = user.value) == null ? void 0 : _a2.role;
    }, async () => {
      if (route.path.startsWith("/knowledge-base") && !isAdmin.value) {
        try {
          await router.replace("/curriculum");
        } catch {
        }
      }
    });
    ref(null);
    const activeSlide = ref(null);
    const docStore = useDocStore();
    const activeContent = computed(() => docStore.content);
    const activePath = computed(() => docStore.path);
    computed(() => docStore.version);
    const kbTab = ref("tree");
    const kbHistory = ref([]);
    computed(() => `${kbTab.value}`);
    const chatVisible = ref(true);
    const chatWidth = ref(320);
    const editorKeyFull = computed(() => `${kbTab.value}:${activePath.value || ""}`);
    const { isCollapsed: isSidebarCollapsed, width: sidebarWidth } = useSidebarResize(256, 200, 500);
    ref(null);
    const workspaceView = ref(null);
    const splitEditor = ref(null);
    const tbContent = ref("");
    const tbSlide = ref(null);
    const tbPath = ref("");
    const config = useRuntimeConfig();
    function resolveApiBase2() {
      var _a2;
      const configured = ((_a2 = config.public) == null ? void 0 : _a2.apiBaseUrl) || "/api";
      return configured;
    }
    const apiBase = resolveApiBase2();
    const apiKey = ((_a = config.public) == null ? void 0 : _a.apiKey) || "my_mcp_eagle_tiger";
    const displayName = computed(() => {
      var _a2;
      const nm = (auth.email ? (((_a2 = user.value) == null ? void 0 : _a2.full_name) || "").trim() : "") || auth.email || "\uC0AC\uC6A9\uC790";
      return nm;
    });
    const isAdmin = computed(() => {
      var _a2;
      const r = String(auth.role || ((_a2 = user.value) == null ? void 0 : _a2.role) || "").toLowerCase();
      return r === "admin" || r === "administrator";
    });
    const isTutor = computed(() => {
      var _a2;
      return String(auth.role || ((_a2 = user.value) == null ? void 0 : _a2.role) || "").toLowerCase() === "tutor";
    });
    const isTutorOrAdmin = computed(() => isTutor.value || isAdmin.value);
    const showProfile = ref(false);
    const profile = ref({ email: "", full_name: "", role: "" });
    const savingProfile = ref(false);
    const route = useRoute();
    const router = useRouter();
    const isKnowledgeBase = computed(() => route.path.startsWith("/knowledge-base"));
    const isLoggedIn = computed(() => !!auth.token);
    const isCurriculumRoute = computed(() => route.path.startsWith("/curriculum") || route.path.startsWith("/textbook"));
    computed(() => {
      try {
        return String((route.query || {}).force || "") === "1";
      } catch {
        return false;
      }
    });
    computed(() => {
      try {
        return String((route.query || {}).path || "");
      } catch {
        return "";
      }
    });
    const isHome = computed(() => route.path === "/");
    const isAuthRoute = computed(() => route.path.startsWith("/login") || route.path.startsWith("/register") || route.path.startsWith("/verify-email"));
    watch(() => route.path, async (p) => {
      if (!isLoggedIn.value && !(isHome.value || isAuthRoute.value)) {
        try {
          await router.replace("/login");
        } catch {
        }
        return;
      }
      if (p.startsWith("/curriculum") || p.startsWith("/textbook")) {
        if (!isLoggedIn.value) {
          try {
            await router.replace({ path: "/login", query: { rd: encodeURIComponent(route.fullPath) } });
          } catch {
          }
          return;
        }
        try {
          const q = route.query || {};
          const forced = String(q.force || "") === "1";
          const target = String(q.path || "");
          const lastNew = false ? localStorage.getItem("curriculum_last_path") : null;
          const lastOld = false ? localStorage.getItem("textbook_last_path") : null;
          const last = lastNew || lastOld;
          if (forced && target && tbPath.value !== target) {
            await handleFileClick(target);
          } else if (!forced && last && tbPath.value !== last) ;
          else if (!tbPath.value) {
            await showCurriculumIndex();
          }
        } catch {
        }
        isSidebarCollapsed.value = false;
      }
    });
    async function showCurriculumIndex() {
      try {
        const s = await fetch(`${apiBase}/v1/curriculum?curriculum_path=${encodeURIComponent("index")}`, { headers: { "X-API-Key": apiKey } });
        if (s.ok) {
          const ct = (s.headers.get("content-type") || "").toLowerCase();
          if (ct.includes("application/pdf")) {
            const blob = await s.blob();
            tbContent.value = "# index\n\nPDF \uC2AC\uB77C\uC774\uB4DC\uAC00 \uB85C\uB4DC\uB418\uC5C8\uC2B5\uB2C8\uB2E4.";
            tbSlide.value = { type: "pdf", url: URL.createObjectURL(blob) };
          } else {
            tbContent.value = await s.text();
            tbSlide.value = null;
          }
          tbPath.value = "index.md";
          return;
        }
      } catch {
      }
      tbContent.value = "# \uACF5\uAC1C \uCEE4\uB9AC\uD058\uB7FC\n\n\uAD00\uB9AC\uC790\uAC00 \uACF5\uAC1C\uD55C \uC790\uB8CC\uAC00 \uC5C6\uC2B5\uB2C8\uB2E4.";
      tbSlide.value = null;
      tbPath.value = "";
    }
    const handleFileClick = async (path) => {
      try {
        if (!route.path.startsWith("/curriculum") && !route.path.startsWith("/textbook")) {
          await router.push({ path: "/curriculum", query: { path, force: "1" } });
          return;
        }
      } catch {
      }
      try {
        tbPath.value = path;
        try {
          if (false) ;
        } catch {
        }
        const ext = getExt(path);
        if (["pdf", "ppt", "pptx", "png", "jpg", "jpeg", "gif", "svg", "webp", "mp4", "webm", "mp3", "wav"].includes(ext)) {
          await openKbBinary(path);
          tbContent.value = "";
          tbSlide.value = null;
          return;
        }
        if (ext === "md" || ["txt", "log", "json", "yaml", "yml", "csv"].includes(ext) || ext === "") {
          const s = await fetch(`${apiBase}/v1/curriculum?curriculum_path=${encodeURIComponent(path)}`, { headers: { "X-API-Key": apiKey } });
          if (s.ok) {
            tbContent.value = await s.text();
            tbSlide.value = null;
          } else {
            tbContent.value = "# \uACF5\uAC1C\uB418\uC9C0 \uC54A\uC740 \uC790\uB8CC\uC785\uB2C8\uB2E4.";
            tbSlide.value = null;
          }
          return;
        }
        await downloadKbFile(path);
      } catch (error) {
        console.error("Error fetching textbook content:", error);
        const msg = String((error == null ? void 0 : error.message) || "");
        if (msg.includes("403") || msg.toLowerCase().includes("forbidden")) {
          tbContent.value = "# \uC77D\uAE30 \uAD8C\uD55C\uC774 \uD544\uC694\uD55C \uBB38\uC11C\uC785\uB2C8\uB2E4.";
          tbSlide.value = null;
        } else {
          tbContent.value = `Error loading content. ${msg}`;
          tbSlide.value = null;
        }
      }
    };
    const handleKbFileSelect = async (path) => {
      activeSlide.value = null;
      if (activePath.value && activePath.value !== path) {
        kbHistory.value.push(activePath.value);
      }
      await docStore.open(path);
      if (docStore.error) toast.push("error", "\uB85C\uB4DC \uC2E4\uD328: " + docStore.error);
    };
    const handleKbSave = async ({ path, content, message, force }) => {
      var _a2, _b;
      if (force) {
        try {
          const config2 = useRuntimeConfig();
          const apiBase2 = config2.public.apiBaseUrl || "/api";
          await fetch(`${apiBase2}/v1/knowledge-base/item`, { method: "PATCH", headers: { "Content-Type": "application/json", "X-API-Key": "my_mcp_eagle_tiger" }, body: JSON.stringify({ path, content, message }) });
          toast.push("success", "\uAC15\uC81C \uC800\uC7A5 \uC644\uB8CC");
        } catch (e) {
          toast.push("error", "\uAC15\uC81C \uC800\uC7A5 \uC2E4\uD328");
        }
        return;
      }
      const res = await docStore.save(message);
      if (res == null ? void 0 : res.conflict) {
        await docStore.open(path || docStore.path);
        if ((_a2 = splitEditor.value) == null ? void 0 : _a2.handleConflict) {
          splitEditor.value.handleConflict(docStore.content, docStore.version);
        }
        toast.push("warn", "\uBC84\uC804 \uCDA9\uB3CC \uBC1C\uC0DD: \uBCD1\uD569 \uD544\uC694");
      } else if (!(res == null ? void 0 : res.error)) {
        (_b = splitEditor.value) == null ? void 0 : _b.setSaved({ version_no: docStore.version });
        toast.push("success", "\uC800\uC7A5 \uC644\uB8CC");
      } else if (res.error) {
        toast.push("error", "\uC800\uC7A5 \uC2E4\uD328: " + res.error);
      }
    };
    function getExt(p) {
      const i = p.lastIndexOf(".");
      return i >= 0 ? p.slice(i + 1).toLowerCase() : "";
    }
    async function openKbBinary(path) {
      try {
        const r = await fetch(`${apiBase}/v1/knowledge-base/file?path=${encodeURIComponent(path)}`, { headers: { "X-API-Key": apiKey } });
        if (!r.ok) {
          toast.push("error", "\uD30C\uC77C \uC5F4\uAE30 \uC2E4\uD328: " + r.status);
          return;
        }
        const blob = await r.blob();
        const url = URL.createObjectURL(blob);
        (void 0).open(url, "_blank", "noopener,noreferrer");
      } catch (e) {
        toast.push("error", "\uD30C\uC77C \uB85C\uB4DC \uC624\uB958");
      }
    }
    async function downloadKbFile(path) {
      try {
        const r = await fetch(`${apiBase}/v1/knowledge-base/file?path=${encodeURIComponent(path)}`, { headers: { "X-API-Key": apiKey } });
        if (!r.ok) {
          toast.push("error", "\uB2E4\uC6B4\uB85C\uB4DC \uC2E4\uD328: " + r.status);
          return;
        }
        const blob = await r.blob();
        const url = URL.createObjectURL(blob);
        const a = (void 0).createElement("a");
        a.href = url;
        a.download = path.split("/").pop() || "download";
        (void 0).body.appendChild(a);
        a.click();
        a.remove();
        URL.revokeObjectURL(url);
      } catch (e) {
        toast.push("error", "\uB2E4\uC6B4\uB85C\uB4DC \uC624\uB958");
      }
    }
    async function onTreeSelect(p) {
      const ext = getExt(p);
      if (ext === "md") {
        await handleKbFileSelect(p);
        kbTab.value = "tiptap";
        return;
      }
      if (["txt", "log", "json", "yaml", "yml", "csv"].includes(ext)) {
        await handleKbFileSelect(p);
        kbTab.value = "markdown";
        return;
      }
      if (["pdf", "ppt", "pptx", "png", "jpg", "jpeg", "gif", "svg", "webp", "mp4", "webm", "mp3", "wav"].includes(ext)) {
        await openKbBinary(p);
        return;
      }
      await downloadKbFile(p);
    }
    watch(kbTab, (v) => {
      try {
        if (false) ;
      } catch {
      }
    });
    return (_ctx, _push, _parent, _attrs) => {
      var _a2, _b;
      const _component_NuxtLink = __nuxt_component_0$1;
      const _component_TipTapKbEditor = __nuxt_component_1;
      _push(`<div${ssrRenderAttrs(mergeProps({ class: "h-screen flex flex-col" }, _attrs))}><nav class="bg-white shadow-sm border-b z-10"><div class="max-w-full mx-auto px-4 sm:px-6 lg:px-8"><div class="flex justify-between h-16"><div class="flex items-center"><button class="mr-3 p-2 rounded hover:bg-gray-100 focus:outline-none" title="Toggle sidebar"><svg class="w-5 h-5 text-gray-700" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16"></path></svg></button><a href="/" class="text-xl font-bold text-gray-900"> GoldenCicle </a></div><div class="flex items-center space-x-4 relative">`);
      _push(ssrRenderComponent(_component_NuxtLink, {
        to: "/curriculum",
        class: ["px-3 py-2 rounded-md text-sm", unref(route).path.startsWith("/curriculum") ? "font-bold text-gray-900" : "text-gray-700 hover:text-gray-900"]
      }, {
        default: withCtx((_, _push2, _parent2, _scopeId) => {
          if (_push2) {
            _push2(` \uCEE4\uB9AC\uD058\uB7FC `);
          } else {
            return [
              createTextVNode(" \uCEE4\uB9AC\uD058\uB7FC ")
            ];
          }
        }),
        _: 1
      }, _parent));
      if (isAdmin.value) {
        _push(ssrRenderComponent(_component_NuxtLink, {
          to: "/knowledge-base",
          class: ["px-3 py-2 rounded-md text-sm", unref(route).path.startsWith("/knowledge-base") ? "font-bold text-gray-900" : "text-gray-700 hover:text-gray-900"]
        }, {
          default: withCtx((_, _push2, _parent2, _scopeId) => {
            if (_push2) {
              _push2(` \uC9C0\uC2DD\uBCA0\uC774\uC2A4 `);
            } else {
              return [
                createTextVNode(" \uC9C0\uC2DD\uBCA0\uC774\uC2A4 ")
              ];
            }
          }),
          _: 1
        }, _parent));
      } else {
        _push(`<!---->`);
      }
      if (isLoggedIn.value) {
        _push(`<div class="relative"><button class="px-3 py-2 rounded-md text-sm text-gray-700 hover:text-gray-900 flex items-center gap-2" aria-haspopup="menu"${ssrRenderAttr("aria-expanded", userMenuOpen.value ? "true" : "false")}><span class="truncate max-w-[180px]">${ssrInterpolate(displayName.value)}</span><svg class="w-4 h-4" viewBox="0 0 20 20" fill="currentColor"><path fill-rule="evenodd" d="M5.23 7.21a.75.75 0 011.06.02L10 11.188l3.71-3.957a.75.75 0 111.08 1.04l-4.25 4.53a.75.75 0 01-1.08 0l-4.25-4.53a.75.75 0 01.02-1.06z" clip-rule="evenodd"></path></svg></button>`);
        if (userMenuOpen.value) {
          _push(`<div class="absolute right-0 mt-2 w-48 bg-white border rounded-md shadow-lg z-30" role="menu"><button class="w-full text-left px-3 py-2 text-sm text-gray-700 hover:bg-gray-100" role="menuitem">\uD504\uB85C\uD30C\uC77C</button><button class="w-full text-left px-3 py-2 text-sm text-gray-700 hover:bg-gray-100" role="menuitem">\uB85C\uADF8\uC544\uC6C3</button></div>`);
        } else {
          _push(`<!---->`);
        }
        _push(`</div>`);
      } else {
        _push(`<div class="flex items-center space-x-2">`);
        _push(ssrRenderComponent(_component_NuxtLink, {
          to: "/login",
          class: ["px-3 py-2 rounded-md text-sm", unref(route).path.startsWith("/login") ? "font-bold text-gray-900" : "text-gray-700 hover:text-gray-900"]
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
          to: "/register",
          class: ["px-3 py-2 rounded-md text-sm", unref(route).path.startsWith("/register") ? "font-bold text-gray-900" : "text-gray-700 hover:text-gray-900"]
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
        _push(`</div>`);
      }
      _push(`</div></div></div></nav><div class="flex flex-grow overflow-hidden bg-gray-100 relative">`);
      if (!isKnowledgeBase.value) {
        _push(`<aside class="bg-white border-r border-gray-200 flex-shrink-0 overflow-y-auto shadow-md transition-all duration-200" style="${ssrRenderStyle({ width: unref(isSidebarCollapsed) ? "0px" : unref(sidebarWidth) + "px" })}"><div style="${ssrRenderStyle(!unref(isSidebarCollapsed) ? null : { display: "none" })}">`);
        _push(ssrRenderComponent(_sfc_main$8, { onFileClick: handleFileClick }, null, _parent));
        _push(`</div></aside>`);
      } else {
        _push(`<!---->`);
      }
      if (!isKnowledgeBase.value && !unref(isSidebarCollapsed)) {
        _push(`<div class="w-1 cursor-col-resize bg-gray-200 hover:bg-gray-300"></div>`);
      } else {
        _push(`<!---->`);
      }
      if (!isKnowledgeBase.value) {
        _push(`<div class="absolute top-1/2 -translate-y-1/2 z-20" style="${ssrRenderStyle({ left: unref(isSidebarCollapsed) ? "0px" : unref(sidebarWidth) + "px" })}"><button class="sidebar-handle"${ssrRenderAttr("aria-label", unref(isSidebarCollapsed) ? "\uC0AC\uC774\uB4DC\uBC14 \uC5F4\uAE30" : "\uC0AC\uC774\uB4DC\uBC14 \uB2EB\uAE30")}${ssrRenderAttr("aria-expanded", unref(isSidebarCollapsed) ? "false" : "true")}>`);
        if (unref(isSidebarCollapsed)) {
          _push(`<span>\u203A</span>`);
        } else {
          _push(`<span>\u2039</span>`);
        }
        _push(`</button></div>`);
      } else {
        _push(`<!---->`);
      }
      _push(`<main class="flex-grow overflow-hidden flex flex-col"><div class="flex-1 overflow-hidden">`);
      if (isKnowledgeBase.value) {
        _push(`<div class="h-full flex flex-col"><div class="border-b bg-white p-2 text-sm flex items-center gap-2" role="tablist" aria-label="KB editor tabs"><button role="tab"${ssrRenderAttr("aria-selected", kbTab.value === "tree")} class="${ssrRenderClass(kbTab.value === "tree" ? "px-3 py-1 rounded bg-indigo-600 text-white" : "px-3 py-1 rounded bg-gray-200")}">FileTree</button><button role="tab"${ssrRenderAttr("aria-selected", kbTab.value === "tiptap")} class="${ssrRenderClass(kbTab.value === "tiptap" ? "px-3 py-1 rounded bg-indigo-600 text-white" : "px-3 py-1 rounded bg-gray-200")}">WYSIWYG</button><button role="tab"${ssrRenderAttr("aria-selected", kbTab.value === "markdown")} class="${ssrRenderClass(kbTab.value === "markdown" ? "px-3 py-1 rounded bg-indigo-600 text-white" : "px-3 py-1 rounded bg-gray-200")}">Markdown</button><div class="flex-1"></div><button${ssrIncludeBooleanAttr(!kbHistory.value.length) ? " disabled" : ""} class="px-2 py-1 rounded bg-gray-200 disabled:opacity-50">\uB4A4\uB85C</button>`);
        if (activePath.value) {
          _push(`<span class="text-xs text-gray-500">${ssrInterpolate(activePath.value)}</span>`);
        } else {
          _push(`<!---->`);
        }
        _push(`</div><div class="flex-1 overflow-hidden">`);
        if (kbTab.value === "tree") {
          _push(`<div class="h-full">`);
          _push(ssrRenderComponent(_sfc_main$9, {
            mode: "full",
            "selected-file": activePath.value,
            onFileSelect: onTreeSelect,
            onFileOpen: onTreeSelect
          }, null, _parent));
          _push(`</div>`);
        } else if (kbTab.value === "tiptap") {
          _push(`<div class="h-full">`);
          if (activePath.value) {
            _push(`<div class="h-full">`);
            _push(ssrRenderComponent(_component_TipTapKbEditor, {
              key: editorKeyFull.value,
              path: activePath.value,
              content: activeContent.value
            }, null, _parent));
            _push(`</div>`);
          } else {
            _push(`<div class="p-6 text-sm text-gray-500">\uC88C\uCE21 FileTree \uD0ED\uC5D0\uC11C \uBB38\uC11C\uB97C \uC120\uD0DD\uD574 \uC8FC\uC138\uC694.</div>`);
          }
          _push(`</div>`);
        } else {
          _push(`<div class="h-full flex flex-col">`);
          if (activePath.value) {
            _push(`<div class="h-full overflow-y-auto">`);
            _push(ssrRenderComponent(SplitEditor, {
              key: editorKeyFull.value,
              path: activePath.value,
              content: activeContent.value,
              ref_key: "splitEditor",
              ref: splitEditor,
              onSave: handleKbSave
            }, null, _parent));
            _push(`</div>`);
          } else {
            _push(`<div class="p-6 text-sm text-gray-500">\uC88C\uCE21 FileTree \uD0ED\uC5D0\uC11C \uBB38\uC11C\uB97C \uC120\uD0DD\uD574 \uC8FC\uC138\uC694.</div>`);
          }
          _push(`</div>`);
        }
        _push(`</div></div>`);
      } else if (isHome.value || isAuthRoute.value) {
        _push(`<div class="h-full">`);
        ssrRenderSlot(_ctx.$slots, "default", {}, null, _push, _parent);
        _push(`</div>`);
      } else {
        _push(ssrRenderComponent(_sfc_main$4, {
          "active-content": tbContent.value,
          "active-slide": tbSlide.value,
          "active-path": tbPath.value,
          readonly: true,
          ref_key: "workspaceView",
          ref: workspaceView
        }, null, _parent));
      }
      _push(`</div></main>`);
      if (!isKnowledgeBase.value && (!isCurriculumRoute.value || isTutorOrAdmin.value)) {
        _push(`<div class="absolute top-1/2 -translate-y-1/2 right-0 z-20"><button class="chat-handle"${ssrRenderAttr("aria-label", chatVisible.value ? "\uCC44\uD305 \uC228\uAE40" : "\uCC44\uD305 \uD45C\uC2DC")}${ssrRenderAttr("aria-expanded", chatVisible.value ? "true" : "false")}>`);
        if (chatVisible.value) {
          _push(`<span>\u203A</span>`);
        } else {
          _push(`<span>\u2039</span>`);
        }
        _push(`</button></div>`);
      } else {
        _push(`<!---->`);
      }
      if (!isKnowledgeBase.value && chatVisible.value && (!isCurriculumRoute.value || isTutorOrAdmin.value)) {
        _push(`<div class="chat-resizer" style="${ssrRenderStyle({ right: chatWidth.value + "px" })}"></div>`);
      } else {
        _push(`<!---->`);
      }
      if (!isKnowledgeBase.value && chatVisible.value && (!isCurriculumRoute.value || isTutorOrAdmin.value)) {
        _push(`<aside class="bg-white border-l border-gray-200 flex-shrink-0 overflow-y-auto shadow-md" style="${ssrRenderStyle({ width: chatWidth.value + "px" })}">`);
        _push(ssrRenderComponent(_sfc_main$3, null, null, _parent));
        _push(`</aside>`);
      } else {
        _push(`<!---->`);
      }
      if (showProfile.value) {
        _push(`<div class="fixed inset-0 z-40 bg-black/30 flex items-center justify-center"><div class="bg-white rounded-lg shadow-xl w-[440px] max-w-[92vw] p-4"><div class="text-lg font-semibold mb-2">\uD504\uB85C\uD30C\uC77C</div><div class="space-y-3"><div><div class="text-xs text-gray-500">\uC774\uBA54\uC77C</div><div class="text-sm">${ssrInterpolate(profile.value.email || unref(auth).email || ((_a2 = unref(user)) == null ? void 0 : _a2.email))}</div></div><div><label class="text-xs text-gray-500">\uC774\uB984</label><input${ssrRenderAttr("value", profile.value.full_name)} type="text" class="mt-1 w-full border rounded px-2 py-1"></div><div class="text-xs text-gray-500">\uC5ED\uD560: <span class="font-medium">${ssrInterpolate(profile.value.role || unref(auth).role || ((_b = unref(user)) == null ? void 0 : _b.role) || "student")}</span></div></div><div class="mt-4 flex justify-end gap-2"><button class="px-3 py-1 border rounded">\uB2EB\uAE30</button><button class="px-3 py-1 bg-indigo-600 text-white rounded"${ssrIncludeBooleanAttr(savingProfile.value) ? " disabled" : ""}>${ssrInterpolate(savingProfile.value ? "\uC800\uC7A5 \uC911..." : "\uC800\uC7A5")}</button></div></div></div>`);
      } else {
        _push(`<!---->`);
      }
      _push(`</div>`);
      if (isKnowledgeBase.value) {
        _push(ssrRenderComponent(_sfc_main$2, null, null, _parent));
      } else {
        _push(`<!---->`);
      }
      _push(ssrRenderComponent(ToastStack, null, null, _parent));
      _push(`</div>`);
    };
  }
};
const _sfc_setup = _sfc_main.setup;
_sfc_main.setup = (props, ctx) => {
  const ssrContext = useSSRContext();
  (ssrContext.modules || (ssrContext.modules = /* @__PURE__ */ new Set())).add("layouts/default.vue");
  return _sfc_setup ? _sfc_setup(props, ctx) : void 0;
};
const _default = /* @__PURE__ */ Object.freeze(/* @__PURE__ */ Object.defineProperty({
  __proto__: null,
  default: _sfc_main
}, Symbol.toStringTag, { value: "Module" }));

export { _sfc_main$7 as _, _sfc_main$6 as a, _default as b, useDocStore as u };
//# sourceMappingURL=default-CAKjEFeF.mjs.map
