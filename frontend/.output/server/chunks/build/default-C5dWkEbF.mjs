import { _ as __nuxt_component_0 } from './nuxt-link-DuKmAlAX.mjs';
import { ref, mergeProps, withCtx, createTextVNode, renderSlot, shallowRef, computed, watch, reactive, useSSRContext } from 'vue';
import { ssrRenderAttrs, ssrRenderComponent, ssrRenderStyle, ssrRenderSlot, ssrInterpolate, ssrRenderList, ssrRenderClass } from 'vue/server-renderer';
import { useRoute } from 'vue-router';
import { _ as __nuxt_component_0$1 } from './client-only-D-BZfu7n.mjs';
import { u as useRuntimeConfig } from './server.mjs';
import { marked } from 'marked';
import '../_/nitro.mjs';
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

const __default__ = {
  name: "TreeItem"
};
const _sfc_main$5 = /* @__PURE__ */ Object.assign(__default__, {
  __ssrInlineRender: true,
  props: {
    item: Object,
    path: String
  },
  emits: ["file-click"],
  setup(__props) {
    const openMap = reactive({});
    const isOpen = (key) => openMap[key] === true;
    return (_ctx, _push, _parent, _attrs) => {
      const _component_TreeItem = _sfc_main$5;
      _push(`<!--[-->`);
      ssrRenderList(__props.item, (value, key) => {
        _push(`<li class="list-none">`);
        if (key !== "files") {
          _push(`<!--[--><div class="flex items-center cursor-pointer select-none"><svg class="${ssrRenderClass([{ "rotate-90": isOpen(key) }, "w-3 h-3 text-gray-600 transform transition-transform"])}" viewBox="0 0 20 20" fill="currentColor"><path fill-rule="evenodd" d="M6 6l6 4-6 4V6z" clip-rule="evenodd"></path></svg><span class="font-semibold whitespace-nowrap ml-1">${ssrInterpolate(key)}</span></div><ul style="${ssrRenderStyle(isOpen(key) ? null : { display: "none" })}" class="ml-4 space-y-1">`);
          _push(ssrRenderComponent(_component_TreeItem, {
            item: value,
            path: __props.path + key + "/",
            onFileClick: (p) => _ctx.$emit("file-click", p)
          }, null, _parent));
          _push(`</ul><!--]-->`);
        } else {
          _push(`<ul class="ml-6 space-y-1"><!--[-->`);
          ssrRenderList(value, (file) => {
            _push(`<li class="whitespace-nowrap"><a href="#" class="text-blue-600 hover:underline">${ssrInterpolate(file.replace(".md", ""))}</a></li>`);
          });
          _push(`<!--]--></ul>`);
        }
        _push(`</li>`);
      });
      _push(`<!--]-->`);
    };
  }
});
const _sfc_setup$5 = _sfc_main$5.setup;
_sfc_main$5.setup = (props, ctx) => {
  const ssrContext = useSSRContext();
  (ssrContext.modules || (ssrContext.modules = /* @__PURE__ */ new Set())).add("components/TreeItem.vue");
  return _sfc_setup$5 ? _sfc_setup$5(props, ctx) : void 0;
};
const _sfc_main$4 = {
  __name: "SyllabusExplorer",
  __ssrInlineRender: true,
  emits: ["file-click"],
  setup(__props, { emit: __emit }) {
    const tree = ref(null);
    const loading = ref(false);
    const error = ref(null);
    const emit = __emit;
    const onFileClick = (path) => {
      emit("file-click", path);
    };
    return (_ctx, _push, _parent, _attrs) => {
      _push(`<div${ssrRenderAttrs(mergeProps({ class: "p-4 select-none" }, _attrs))}><h3 class="text-lg font-semibold mb-4 whitespace-nowrap"><a href="#" class="hover:underline text-blue-700"> Curriculum </a></h3>`);
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
      if (tree.value) {
        _push(`<ul class="space-y-2">`);
        _push(ssrRenderComponent(_sfc_main$5, {
          item: tree.value,
          path: "",
          onFileClick
        }, null, _parent));
        _push(`</ul>`);
      } else {
        _push(`<!---->`);
      }
      _push(`</div>`);
    };
  }
};
const _sfc_setup$4 = _sfc_main$4.setup;
_sfc_main$4.setup = (props, ctx) => {
  const ssrContext = useSSRContext();
  (ssrContext.modules || (ssrContext.modules = /* @__PURE__ */ new Set())).add("components/SyllabusExplorer.vue");
  return _sfc_setup$4 ? _sfc_setup$4(props, ctx) : void 0;
};
const _sfc_main$3 = {
  __name: "ContentView",
  __ssrInlineRender: true,
  props: {
    content: String,
    slide: Object,
    path: String
  },
  emits: ["navigate-tool"],
  setup(__props, { emit: __emit }) {
    const props = __props;
    const emit = __emit;
    const contentContainer = ref(null);
    const showTextbook = ref(false);
    const textbookContent = ref("");
    const loadingTextbook = ref(false);
    const titleText = computed(() => {
      if (!props.content) return "";
      const match = props.content.match(/^\s*#{1,6}\s+(.+)$/m);
      if (match) return match[1].trim();
      return props.path ? props.path.split("/").pop().replace(/_/g, " ").replace(/\.md$/i, "") : "";
    });
    const renderedMarkdown = computed(() => {
      if (!props.content) return "";
      const lines = props.content.split(/\r?\n/);
      let removed = false;
      const rest = [];
      for (const line of lines) {
        if (!removed && /^\s*#{1,6}\s+.+$/.test(line)) {
          removed = true;
          continue;
        }
        rest.push(line);
      }
      const body = removed ? rest.join("\n") : props.content;
      return marked(body);
    });
    const apiBase2 = useRuntimeConfig().public.apiBaseUrl || "http://localhost:8000";
    const API_KEY = process.env.MCP_API_KEY || "my_mcp_eagle_tiger";
    computed(() => props.path ? props.path.split("/").pop() : "slide");
    const loadTextbook = async () => {
      if (!props.path) return;
      loadingTextbook.value = true;
      try {
        const response = await fetch(`${apiBase2}/api/v1/curriculum/content?path=${encodeURIComponent(props.path)}`, {
          headers: {
            "X-API-Key": API_KEY
          }
        });
        if (response.ok) {
          const content = await response.text();
          marked.setOptions({
            breaks: true,
            gfm: true,
            headerIds: true,
            mangle: false
          });
          textbookContent.value = marked(content);
        } else {
          console.error("Failed to load textbook content");
        }
      } catch (error) {
        console.error("Error loading textbook:", error);
      } finally {
        loadingTextbook.value = false;
      }
    };
    const setupLinkIntercepts = () => {
      if (contentContainer.value) {
        contentContainer.value.querySelectorAll('a[href^="mcp://"]').forEach((link) => {
          link.addEventListener("click", (event) => {
            event.preventDefault();
            const url = new URL(link.href);
            const tool = url.hostname;
            emit("navigate-tool", { tool });
          });
        });
      }
    };
    watch(showTextbook, (show) => {
      if (show && !textbookContent.value) {
        loadTextbook();
      }
    });
    watch(() => props.content, setupLinkIntercepts);
    return (_ctx, _push, _parent, _attrs) => {
      var _a, _b;
      if (__props.content) {
        _push(`<div${ssrRenderAttrs(mergeProps({
          class: "prose max-w-none",
          ref_key: "contentContainer",
          ref: contentContainer
        }, _attrs))}>`);
        if (titleText.value) {
          _push(`<div class="flex items-center justify-between mb-4"><h1 class="m-0">${ssrInterpolate(titleText.value)}</h1><div class="flex gap-3"><button class="${ssrRenderClass([
            "px-3 py-1 text-sm rounded font-medium transition-colors",
            showTextbook.value ? "bg-blue-600 text-white hover:bg-blue-700" : "bg-gray-200 text-gray-700 hover:bg-gray-300"
          ])}">${ssrInterpolate(showTextbook.value ? "Textbook \uC228\uAE30\uAE30" : "\u{1F4DA} Textbook")}</button>`);
          if (__props.path) {
            _push(`<button class="px-3 py-1 text-sm bg-green-600 text-white rounded hover:bg-green-700 transition-colors"> \uB2E4\uC6B4\uB85C\uB4DC \uC2AC\uB77C\uC774\uB4DC </button>`);
          } else {
            _push(`<!---->`);
          }
          _push(`</div></div>`);
        } else {
          _push(`<!---->`);
        }
        if (showTextbook.value) {
          _push(`<div class="mb-8 p-6 bg-gray-50 rounded-lg border"><h4 class="text-xl font-semibold mb-4 text-gray-800">\u{1F4DA} Textbook \uB0B4\uC6A9</h4>`);
          if (textbookContent.value) {
            _push(`<div class="prose prose-sm max-w-none"><div>${(_a = textbookContent.value) != null ? _a : ""}</div></div>`);
          } else if (loadingTextbook.value) {
            _push(`<div class="text-center py-8"><div class="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600 mx-auto"></div><p class="mt-2 text-gray-600">Textbook\uC744 \uBD88\uB7EC\uC624\uB294 \uC911...</p></div>`);
          } else {
            _push(`<div class="text-center py-8 text-gray-500"><p>Textbook \uB0B4\uC6A9\uC744 \uBD88\uB7EC\uC62C \uC218 \uC5C6\uC2B5\uB2C8\uB2E4.</p></div>`);
          }
          _push(`</div>`);
        } else {
          _push(`<!---->`);
        }
        _push(`<div>${(_b = renderedMarkdown.value) != null ? _b : ""}</div></div>`);
      } else {
        _push(`<!---->`);
      }
    };
  }
};
const _sfc_setup$3 = _sfc_main$3.setup;
_sfc_main$3.setup = (props, ctx) => {
  const ssrContext = useSSRContext();
  (ssrContext.modules || (ssrContext.modules = /* @__PURE__ */ new Set())).add("components/ContentView.vue");
  return _sfc_setup$3 ? _sfc_setup$3(props, ctx) : void 0;
};
const _sfc_main$2 = {
  __name: "WorkspaceView",
  __ssrInlineRender: true,
  props: {
    activeContent: String,
    activeSlide: Object,
    activePath: String
  },
  setup(__props) {
    const props = __props;
    const activeComponent = shallowRef(_sfc_main$3);
    computed(() => {
      if (activeComponent.value === _sfc_main$3) {
        return {
          content: props.activeContent,
          slide: props.activeSlide,
          path: props.activePath
        };
      }
      return {};
    });
    watch(() => props.activeContent, (newContent) => {
      if (newContent) {
        activeComponent.value = _sfc_main$3;
      }
    });
    return (_ctx, _push, _parent, _attrs) => {
      const _component_ClientOnly = __nuxt_component_0$1;
      _push(`<div${ssrRenderAttrs(mergeProps({ class: "h-full flex flex-col" }, _attrs))}><div class="flex-grow overflow-y-auto p-6 bg-white">`);
      _push(ssrRenderComponent(_component_ClientOnly, null, {}, _parent));
      _push(`</div></div>`);
    };
  }
};
const _sfc_setup$2 = _sfc_main$2.setup;
_sfc_main$2.setup = (props, ctx) => {
  const ssrContext = useSSRContext();
  (ssrContext.modules || (ssrContext.modules = /* @__PURE__ */ new Set())).add("components/WorkspaceView.vue");
  return _sfc_setup$2 ? _sfc_setup$2(props, ctx) : void 0;
};
const _sfc_main$1 = {
  __name: "AIAssistantPanel",
  __ssrInlineRender: true,
  setup(__props) {
    return (_ctx, _push, _parent, _attrs) => {
      _push(`<div${ssrRenderAttrs(mergeProps({ class: "h-full flex flex-col bg-white" }, _attrs))}><div class="flex-grow overflow-y-auto p-4 space-y-4"><div class="flex justify-start"><div class="bg-gray-200 p-3 rounded-lg max-w-xs"> Hello! How can I help you with cloud computing today? </div></div><div class="flex justify-end"><div class="bg-blue-100 p-3 rounded-lg max-w-xs"> What is an EC2 instance? </div></div></div><div class="border-t border-gray-200 p-4 flex-shrink-0"><input type="text" placeholder="Ask AI Assistant..." class="w-full p-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"></div></div>`);
    };
  }
};
const _sfc_setup$1 = _sfc_main$1.setup;
_sfc_main$1.setup = (props, ctx) => {
  const ssrContext = useSSRContext();
  (ssrContext.modules || (ssrContext.modules = /* @__PURE__ */ new Set())).add("components/AIAssistantPanel.vue");
  return _sfc_setup$1 ? _sfc_setup$1(props, ctx) : void 0;
};
const _sfc_main = {
  __name: "default",
  __ssrInlineRender: true,
  setup(__props) {
    const activeContent = ref("");
    const activeSlide = ref(null);
    const activePath = ref("");
    const isSidebarCollapsed = ref(false);
    const sidebarWidth = ref(256);
    ref(null);
    const workspaceView = ref(null);
    useRoute();
    const handleFileClick = async (path) => {
      try {
        activePath.value = path;
        const contentResponse = await fetch(`${apiBase}/api/v1/curriculum/content?path=${path}`, {
          headers: { "X-API-Key": apiKey }
        });
        if (!contentResponse.ok) throw new Error("Failed to fetch content");
        const contentData = await contentResponse.json();
        activeContent.value = contentData.content;
        activeSlide.value = null;
      } catch (error) {
        console.error("Error fetching curriculum data:", error);
        activeContent.value = "Error loading content.";
        activeSlide.value = null;
      }
    };
    return (_ctx, _push, _parent, _attrs) => {
      const _component_NuxtLink = __nuxt_component_0;
      _push(`<div${ssrRenderAttrs(mergeProps({ class: "h-screen flex flex-col" }, _attrs))}><nav class="bg-white shadow-sm border-b z-10"><div class="max-w-full mx-auto px-4 sm:px-6 lg:px-8"><div class="flex justify-between h-16"><div class="flex items-center"><button class="mr-3 p-2 rounded hover:bg-gray-100 focus:outline-none" title="Toggle sidebar"><svg class="w-5 h-5 text-gray-700" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16"></path></svg></button>`);
      _push(ssrRenderComponent(_component_NuxtLink, {
        to: "/",
        class: "text-xl font-bold text-gray-900"
      }, {
        default: withCtx((_, _push2, _parent2, _scopeId) => {
          if (_push2) {
            _push2(` m-Learning `);
          } else {
            return [
              createTextVNode(" m-Learning ")
            ];
          }
        }),
        _: 1
      }, _parent));
      _push(`</div><div class="flex items-center space-x-4">`);
      _push(ssrRenderComponent(_component_NuxtLink, {
        to: "/",
        class: "text-gray-700 hover:text-gray-900 px-3 py-2 rounded-md text-sm font-medium"
      }, {
        default: withCtx((_, _push2, _parent2, _scopeId) => {
          if (_push2) {
            _push2(` \uD648 `);
          } else {
            return [
              createTextVNode(" \uD648 ")
            ];
          }
        }),
        _: 1
      }, _parent));
      _push(ssrRenderComponent(_component_NuxtLink, {
        to: "/ai-assistant",
        class: "text-gray-700 hover:text-gray-900 px-3 py-2 rounded-md text-sm font-medium"
      }, {
        default: withCtx((_, _push2, _parent2, _scopeId) => {
          if (_push2) {
            _push2(` AI \uC5B4\uC2DC\uC2A4\uD134\uD2B8 `);
          } else {
            return [
              createTextVNode(" AI \uC5B4\uC2DC\uC2A4\uD134\uD2B8 ")
            ];
          }
        }),
        _: 1
      }, _parent));
      _push(ssrRenderComponent(_component_NuxtLink, {
        to: "/knowledge-base",
        class: "text-gray-700 hover:text-gray-900 px-3 py-2 rounded-md text-sm font-medium"
      }, {
        default: withCtx((_, _push2, _parent2, _scopeId) => {
          if (_push2) {
            _push2(` Curriculum `);
          } else {
            return [
              createTextVNode(" Curriculum ")
            ];
          }
        }),
        _: 1
      }, _parent));
      _push(ssrRenderComponent(_component_NuxtLink, {
        to: "/datasources",
        class: "text-gray-700 hover:text-gray-900 px-3 py-2 rounded-md text-sm font-medium"
      }, {
        default: withCtx((_, _push2, _parent2, _scopeId) => {
          if (_push2) {
            _push2(` \uB370\uC774\uD130\uC18C\uC2A4 `);
          } else {
            return [
              createTextVNode(" \uB370\uC774\uD130\uC18C\uC2A4 ")
            ];
          }
        }),
        _: 1
      }, _parent));
      _push(`<button class="text-gray-700 hover:text-gray-900 px-3 py-2 rounded-md text-sm font-medium"> \uB300\uD654\uD615 CLI </button>`);
      _push(ssrRenderComponent(_component_NuxtLink, {
        to: "/cli",
        class: "text-gray-700 hover:text-gray-900 px-3 py-2 rounded-md text-sm font-medium"
      }, {
        default: withCtx((_, _push2, _parent2, _scopeId) => {
          if (_push2) {
            _push2(` CLI \uBA85\uB839\uC5B4 `);
          } else {
            return [
              createTextVNode(" CLI \uBA85\uB839\uC5B4 ")
            ];
          }
        }),
        _: 1
      }, _parent));
      _push(`</div></div></div></nav><div class="flex flex-grow overflow-hidden bg-gray-100"><aside class="bg-white border-r border-gray-200 flex-shrink-0 overflow-y-auto shadow-md transition-all duration-200" style="${ssrRenderStyle({ width: isSidebarCollapsed.value ? "0px" : sidebarWidth.value + "px" })}"><div style="${ssrRenderStyle(!isSidebarCollapsed.value ? null : { display: "none" })}">`);
      _push(ssrRenderComponent(_sfc_main$4, { onFileClick: handleFileClick }, null, _parent));
      _push(`</div></aside>`);
      if (!isSidebarCollapsed.value) {
        _push(`<div class="w-1 cursor-col-resize bg-gray-200 hover:bg-gray-300"></div>`);
      } else {
        _push(`<!---->`);
      }
      _push(`<main class="flex-grow overflow-hidden">`);
      _push(ssrRenderComponent(_sfc_main$2, {
        "active-content": activeContent.value,
        "active-slide": activeSlide.value,
        "active-path": activePath.value,
        ref_key: "workspaceView",
        ref: workspaceView
      }, {
        default: withCtx((_, _push2, _parent2, _scopeId) => {
          if (_push2) {
            ssrRenderSlot(_ctx.$slots, "default", {}, null, _push2, _parent2, _scopeId);
          } else {
            return [
              renderSlot(_ctx.$slots, "default")
            ];
          }
        }),
        _: 3
      }, _parent));
      _push(`</main><aside class="w-80 bg-white border-l border-gray-200 flex-shrink-0 overflow-y-auto shadow-md">`);
      _push(ssrRenderComponent(_sfc_main$1, null, null, _parent));
      _push(`</aside></div></div>`);
    };
  }
};
const _sfc_setup = _sfc_main.setup;
_sfc_main.setup = (props, ctx) => {
  const ssrContext = useSSRContext();
  (ssrContext.modules || (ssrContext.modules = /* @__PURE__ */ new Set())).add("layouts/default.vue");
  return _sfc_setup ? _sfc_setup(props, ctx) : void 0;
};

export { _sfc_main as default };
//# sourceMappingURL=default-C5dWkEbF.mjs.map
