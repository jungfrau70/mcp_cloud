import { _ as __nuxt_component_0 } from './nuxt-link-BoT4h8Q2.mjs';
import { ref, computed, watch, mergeProps, withCtx, createTextVNode, unref, defineComponent, withDirectives, createVNode, createBlock, createCommentVNode, vModelText, openBlock, Fragment, renderList, defineAsyncComponent, shallowRef, h, getCurrentInstance, watchEffect, nextTick, useSSRContext, toDisplayString } from 'vue';
import { ssrRenderAttrs, ssrRenderComponent, ssrRenderStyle, ssrRenderAttr, ssrRenderClass, ssrIncludeBooleanAttr, ssrInterpolate, ssrRenderSlot, ssrRenderList, ssrLooseContain, ssrLooseEqual } from 'vue/server-renderer';
import { useRoute, useRouter } from 'vue-router';
import { u as useRuntimeConfig } from './server.mjs';
import { _ as _sfc_main$h, a as __nuxt_component_0$1, e as embed } from './ContentView-kiIy8Wk9.mjs';
import { _ as _export_sfc } from './_plugin-vue_export-helper-1tPrXgE0.mjs';
import { defineStore, storeToRefs } from 'pinia';
import { marked } from 'marked';
import DOMPurify from 'dompurify';
import mermaid from 'mermaid';
import Turndown from 'turndown';
import { Plugin, PluginKey, Selection, TextSelection, NodeSelection, AllSelection } from '@tiptap/pm/state';
import { Decoration, DecorationSet } from '@tiptap/pm/view';
import { Fragment as Fragment$1, Slice, Node as Node$1, Schema, DOMParser } from '@tiptap/pm/model';
import { findWrapping, canJoin, canSplit, joinPoint, liftTarget, Transform, ReplaceStep, ReplaceAroundStep } from '@tiptap/pm/transform';
import { wrapIn as wrapIn$1, setBlockType, selectTextblockStart as selectTextblockStart$1, selectTextblockEnd as selectTextblockEnd$1, selectParentNode as selectParentNode$1, selectNodeForward as selectNodeForward$1, selectNodeBackward as selectNodeBackward$1, newlineInCode as newlineInCode$1, liftEmptyBlock as liftEmptyBlock$1, lift as lift$1, joinUp as joinUp$1, joinTextblockForward as joinTextblockForward$1, joinTextblockBackward as joinTextblockBackward$1, joinForward as joinForward$1, joinDown as joinDown$1, joinBackward as joinBackward$1, exitCode as exitCode$1, deleteSelection as deleteSelection$1, createParagraphNear as createParagraphNear$1 } from '@tiptap/pm/commands';
import { wrapInList as wrapInList$1, sinkListItem as sinkListItem$1, liftListItem as liftListItem$1 } from '@tiptap/pm/schema-list';
import { dropCursor } from '@tiptap/pm/dropcursor';
import { gapCursor } from '@tiptap/pm/gapcursor';
import { history, redo, undo } from '@tiptap/pm/history';
import { reset, registerCustomProtocol, tokenize, find } from 'linkifyjs';
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
import 'json-stringify-pretty-compact';
import 'vega';
import 'vega-interpreter';
import 'vega-lite';
import 'vega-schema-url-parser';
import 'vega-themes';
import 'vega-tooltip';

function resolveApiBase() {
  var _a;
  const config = useRuntimeConfig();
  const configured = ((_a = config.public) == null ? void 0 : _a.apiBaseUrl) || "/api";
  return configured;
}
function useKbApi() {
  const apiBase = resolveApiBase();
  const apiKey2 = "my_mcp_eagle_tiger";
  async function request(url, init, errorMessage = "request failed") {
    const r = await fetch(url, init);
    if (!r.ok) {
      let detail;
      try {
        const data = await r.json();
        detail = data == null ? void 0 : data.detail;
      } catch {
      }
      throw new Error(detail || `${errorMessage}: ${r.status}`);
    }
    return r.json();
  }
  async function getItem(path) {
    return request(`${apiBase}/v1/knowledge-base/item?path=${encodeURIComponent(path)}`, { headers: { "X-API-Key": apiKey2 } }, "getItem failed");
  }
  async function saveItem(path, content, message, expectedVersion) {
    return request(`${apiBase}/_deprecated/kb/item`, {
      method: "PATCH",
      headers: { "Content-Type": "application/json", "X-API-Key": apiKey2 },
      body: JSON.stringify({ path, content, message, expected_version_no: expectedVersion })
    }, "saveItem failed");
  }
  async function listVersions(path) {
    return request(`${apiBase}/v1/knowledge-base/versions?path=${encodeURIComponent(path)}`, { headers: { "X-API-Key": apiKey2 } }, "listVersions failed");
  }
  async function outline(content) {
    return request(`${apiBase}/v1/knowledge-base/outline`, {
      method: "POST",
      headers: { "Content-Type": "application/json", "X-API-Key": apiKey2 },
      body: JSON.stringify({ content })
    }, "outline failed");
  }
  async function startCompose(topic, failStage) {
    const qs = new URLSearchParams({ topic });
    if (failStage) qs.append("fail_stage", failStage);
    return request(`${apiBase}/v1/knowledge-base/compose/external?${qs.toString()}`, { method: "POST", headers: { "X-API-Key": apiKey2 } }, "compose failed");
  }
  async function getTask(id) {
    return request(`${apiBase}/v1/knowledge-base/tasks/${id}`, { headers: { "X-API-Key": apiKey2 } }, "task failed");
  }
  async function diff(path, v1, v2) {
    return request(`${apiBase}/v1/knowledge-base/diff?path=${encodeURIComponent(path)}&v1=${v1}&v2=${v2}`, { headers: { "X-API-Key": apiKey2 } }, "diff failed");
  }
  async function structuredDiff(path, v1, v2) {
    return request(`${apiBase}/v1/knowledge-base/diff/structured?path=${encodeURIComponent(path)}&v1=${v1}&v2=${v2}`, { headers: { "X-API-Key": apiKey2 } }, "structured diff failed");
  }
  async function recentTasks(limit = 20) {
    return request(`${apiBase}/v1/knowledge-base/tasks/recent?limit=${limit}`, { headers: { "X-API-Key": apiKey2 } }, "recent tasks failed");
  }
  async function uploadAsset(file, subdir = "assets") {
    const form = new FormData();
    form.append("file", file);
    form.append("subdir", subdir);
    const r = await fetch(`${apiBase}/v1/assets/upload`, { method: "POST", headers: { "X-API-Key": apiKey2 }, body: form });
    if (!r.ok) {
      let detail;
      try {
        const d = await r.json();
        detail = d == null ? void 0 : d.detail;
      } catch {
      }
      throw new Error(detail || `upload failed: ${r.status}`);
    }
    return r.json();
  }
  async function transform(text, kind, opts) {
    return request(`${apiBase}/v1/knowledge-base/transform`, {
      method: "POST",
      headers: { "Content-Type": "application/json", "X-API-Key": apiKey2 },
      body: JSON.stringify({ text, kind, ...opts || {} })
    }, "transform failed");
  }
  async function lint(text) {
    return request(`${apiBase}/v1/knowledge-base/lint`, {
      method: "POST",
      headers: { "Content-Type": "application/json", "X-API-Key": apiKey2 },
      body: JSON.stringify({ text })
    }, "lint failed");
  }
  async function listTrending() {
    return request(`${apiBase}/v1/trending/categories`, { headers: { "X-API-Key": apiKey2 } }, "trending list failed");
  }
  async function upsertTrending(item) {
    return request(`${apiBase}/v1/trending/categories`, {
      method: "POST",
      headers: { "Content-Type": "application/json", "X-API-Key": apiKey2 },
      body: JSON.stringify(item)
    }, "trending upsert failed");
  }
  async function deleteTrending(name) {
    return request(`${apiBase}/v1/trending/categories/${encodeURIComponent(name)}`, {
      method: "DELETE",
      headers: { "X-API-Key": apiKey2 }
    }, "trending delete failed");
  }
  async function runTrendingNow() {
    return request(`${apiBase}/v1/trending/run-now`, { method: "POST", headers: { "X-API-Key": apiKey2 } }, "trending run failed");
  }
  return { getItem, saveItem, listVersions, outline, startCompose, getTask, diff, structuredDiff, recentTasks, uploadAsset, transform, lint, listTrending, upsertTrending, deleteTrending, runTrendingNow, request };
}
const _sfc_main$g = {
  __name: "FileTree",
  __ssrInlineRender: true,
  props: {
    tree: {
      type: Object,
      required: true
    },
    depth: {
      type: Number,
      default: 0
    },
    basePath: {
      type: String,
      default: ""
    },
    selectedFile: {
      type: String,
      default: null
    },
    excludeDirs: {
      type: Array,
      default: () => []
    }
  },
  emits: ["file-click", "file-open", "directory-create", "directory-rename", "directory-delete", "file-move"],
  setup(__props, { emit: __emit }) {
    const props = __props;
    const emit = __emit;
    const openDirectories = ref({});
    ref(false);
    const showDirectoryContextMenu = ref(false);
    const showFileContextMenu = ref(false);
    const showCreateMenu = ref(false);
    const contextMenuX = ref(0);
    const contextMenuY = ref(0);
    const selectedItem = ref(null);
    const isSelectedInTrash = computed(() => {
      var _a;
      try {
        if (!selectedItem.value) return false;
        const p = ((_a = selectedItem.value.item) == null ? void 0 : _a.path) || constructPath(selectedItem.value.name);
        return typeof p === "string" && /(^|\/)\.trash(\/|$)/.test(p);
      } catch {
        return false;
      }
    });
    const showRenameDialog = ref(false);
    const showCreateDialog = ref(false);
    const newName = ref("");
    const createType = ref("file");
    ref(null);
    ref(null);
    const dragOverTarget = ref(null);
    ref(null);
    const isDirectory = (item) => {
      return typeof item === "object" && item !== null && !Array.isArray(item);
    };
    const files = computed(() => {
      return props.tree.files || [];
    });
    const directories = computed(() => {
      const dirs = { ...props.tree };
      delete dirs.files;
      return dirs;
    });
    const sortedTree = computed(() => {
      const dirs = { ...props.tree };
      delete dirs.files;
      return Object.keys(dirs).sort().reduce((acc, key) => {
        acc[key] = dirs[key];
        return acc;
      }, {});
    });
    const isOpen = (name) => {
      return !!openDirectories.value[name];
    };
    const constructPath = (fileName) => {
      return props.basePath ? `${props.basePath}/${fileName}` : fileName;
    };
    const emitFileClick = (path) => {
      if (typeof path === "string" && path.includes("/")) {
        emit("file-click", path);
      } else if (typeof path === "object" && path.path) {
        emit("file-click", path.path);
      } else {
        const fullPath = props.basePath ? `${props.basePath}/${path}` : path;
        emit("file-click", fullPath);
      }
    };
    const handleDirectoryCreate = (data) => {
      emit("directory-create", data);
    };
    const handleDirectoryRename = (data) => {
      emit("directory-rename", data);
    };
    const handleDirectoryDelete = (data) => {
      emit("directory-delete", data);
    };
    const handleFileMove = (data) => {
      emit("file-move", data);
    };
    function expandBySelected(newPath) {
      if (!newPath) return;
      const base = props.basePath ? props.basePath + "/" : "";
      if (base && newPath.indexOf(base) !== 0) return;
      const remaining = base ? newPath.slice(base.length) : newPath;
      const parts = remaining.split("/").filter(Boolean);
      if (parts.length > 1) {
        const first2 = parts[0];
        if (directories.value[first2]) {
          openDirectories.value[first2] = true;
        }
      }
      nextTick(() => {
        try {
          const el = (void 0).querySelector(`.tree-item.is-file[data-path="${CSS.escape(newPath)}"]`);
          if (el && typeof el.scrollIntoView === "function") {
            el.scrollIntoView({ block: "nearest" });
          }
        } catch {
        }
      });
    }
    watch(() => props.selectedFile, (newPath) => {
      expandBySelected(newPath);
    }, { immediate: true });
    watch(() => props.tree, () => {
      expandBySelected(props.selectedFile);
    }, { deep: true });
    return (_ctx, _push, _parent, _attrs) => {
      const _component_FileTree = FileTree;
      _push(`<div${ssrRenderAttrs(mergeProps({ class: "file-tree" }, _attrs))} data-v-08685139><ul data-v-08685139><!--[-->`);
      ssrRenderList(sortedTree.value, (item, name) => {
        _push(`<li data-v-08685139><div class="${ssrRenderClass(["tree-item", { "is-directory": isDirectory(item), "is-open": isOpen(name), "drag-over": dragOverTarget.value === name }])}" style="${ssrRenderStyle({ "padding-left": __props.depth * 15 + "px" })}" data-v-08685139>`);
        if (isDirectory(item)) {
          _push(`<span class="icon" data-v-08685139>${ssrInterpolate(isOpen(name) ? "\u25BC" : "\u25B6")}</span>`);
        } else {
          _push(`<span class="icon" data-v-08685139>\u{1F4C4}</span>`);
        }
        _push(`<span class="name" data-v-08685139>${ssrInterpolate(name)}</span>`);
        if (isDirectory(item)) {
          _push(`<div class="directory-actions" data-v-08685139><button class="action-btn" title="\uC0C8 \uD56D\uBAA9 \uC0DD\uC131" data-v-08685139>+</button></div>`);
        } else {
          _push(`<!---->`);
        }
        _push(`</div>`);
        if (isDirectory(item) && isOpen(name)) {
          _push(ssrRenderComponent(_component_FileTree, {
            tree: item,
            depth: __props.depth + 1,
            "base-path": constructPath(name),
            "selected-file": __props.selectedFile,
            onFileClick: emitFileClick,
            onDirectoryCreate: handleDirectoryCreate,
            onDirectoryRename: handleDirectoryRename,
            onDirectoryDelete: handleDirectoryDelete,
            onFileMove: handleFileMove
          }, null, _parent));
        } else {
          _push(`<!---->`);
        }
        _push(`</li>`);
      });
      _push(`<!--]--><!--[-->`);
      ssrRenderList(files.value, (file) => {
        _push(`<li data-v-08685139><div class="${ssrRenderClass(["tree-item", "is-file", { "is-selected": __props.selectedFile === (file.path || constructPath(file)) }])}"${ssrRenderAttr("data-path", file.path || constructPath(file))} style="${ssrRenderStyle({ "padding-left": __props.depth * 15 + "px" })}" draggable="true" data-v-08685139><span class="icon" data-v-08685139>\u{1F4C4}</span><span class="name" data-v-08685139>${ssrInterpolate(file.name || file)}</span></div></li>`);
      });
      _push(`<!--]--></ul>`);
      if (showDirectoryContextMenu.value) {
        _push(`<div style="${ssrRenderStyle({ left: contextMenuX.value + "px", top: contextMenuY.value + "px" })}" class="context-menu" data-v-08685139><div class="context-menu-item" data-v-08685139>\u{1F4C1} \uC0C8 \uB514\uB809\uD1A0\uB9AC</div><div class="context-menu-item" data-v-08685139>\u{1F4C4} \uC0C8 \uD30C\uC77C</div><div class="context-menu-divider" data-v-08685139></div><div class="context-menu-item" data-v-08685139>\u270F\uFE0F \uC774\uB984 \uBCC0\uACBD</div><div class="context-menu-item text-red-600" data-v-08685139>\u{1F5D1}\uFE0F \uC0AD\uC81C</div></div>`);
      } else {
        _push(`<!---->`);
      }
      if (showFileContextMenu.value) {
        _push(`<div style="${ssrRenderStyle({ left: contextMenuX.value + "px", top: contextMenuY.value + "px" })}" class="context-menu" data-v-08685139>`);
        if (!isSelectedInTrash.value) {
          _push(`<div class="context-menu-item" data-v-08685139>\u270F\uFE0F \uC774\uB984 \uBCC0\uACBD</div>`);
        } else {
          _push(`<!---->`);
        }
        if (!isSelectedInTrash.value) {
          _push(`<div class="context-menu-item text-red-600" data-v-08685139>\u{1F5D1}\uFE0F \uC0AD\uC81C(\uD734\uC9C0\uD1B5\uC73C\uB85C)</div>`);
        } else {
          _push(`<!---->`);
        }
        if (isSelectedInTrash.value) {
          _push(`<div class="context-menu-item" data-v-08685139>\u21A9\uFE0F \uBCF5\uAD6C</div>`);
        } else {
          _push(`<!---->`);
        }
        if (isSelectedInTrash.value) {
          _push(`<div class="context-menu-item text-red-600" data-v-08685139>\u274C \uC601\uAD6C \uC0AD\uC81C</div>`);
        } else {
          _push(`<!---->`);
        }
        _push(`</div>`);
      } else {
        _push(`<!---->`);
      }
      if (showCreateMenu.value) {
        _push(`<div style="${ssrRenderStyle({ left: contextMenuX.value + "px", top: contextMenuY.value + "px" })}" class="context-menu" data-v-08685139><div class="context-menu-item" data-v-08685139>\u{1F4C1} \uC0C8 \uB514\uB809\uD1A0\uB9AC</div><div class="context-menu-item" data-v-08685139>\u{1F4C4} \uC0C8 \uD30C\uC77C</div></div>`);
      } else {
        _push(`<!---->`);
      }
      if (showRenameDialog.value) {
        _push(`<div class="modal-overlay" data-v-08685139><div class="modal-content" data-v-08685139><h3 class="modal-title" data-v-08685139>\uC774\uB984 \uBCC0\uACBD</h3><input${ssrRenderAttr("value", newName.value)} class="modal-input" placeholder="\uC0C8 \uC774\uB984\uC744 \uC785\uB825\uD558\uC138\uC694" data-v-08685139><div class="modal-actions" data-v-08685139><button class="btn-primary" data-v-08685139>\uD655\uC778</button><button class="btn-secondary" data-v-08685139>\uCDE8\uC18C</button></div></div></div>`);
      } else {
        _push(`<!---->`);
      }
      if (showCreateDialog.value) {
        _push(`<div class="modal-overlay" data-v-08685139><div class="modal-content" data-v-08685139><h3 class="modal-title" data-v-08685139>${ssrInterpolate(createType.value === "directory" ? "\uC0C8 \uB514\uB809\uD1A0\uB9AC" : "\uC0C8 \uD30C\uC77C")}</h3><input${ssrRenderAttr("value", newName.value)} class="modal-input"${ssrRenderAttr("placeholder", createType.value === "directory" ? "\uB514\uB809\uD1A0\uB9AC \uC774\uB984" : "\uD30C\uC77C \uC774\uB984")} data-v-08685139><div class="modal-actions" data-v-08685139><button class="btn-primary" data-v-08685139>\uC0DD\uC131</button><button class="btn-secondary" data-v-08685139>\uCDE8\uC18C</button></div></div></div>`);
      } else {
        _push(`<!---->`);
      }
      _push(`</div>`);
    };
  }
};
const _sfc_setup$g = _sfc_main$g.setup;
_sfc_main$g.setup = (props, ctx) => {
  const ssrContext = useSSRContext();
  (ssrContext.modules || (ssrContext.modules = /* @__PURE__ */ new Set())).add("components/FileTree.vue");
  return _sfc_setup$g ? _sfc_setup$g(props, ctx) : void 0;
};
const FileTree = /* @__PURE__ */ _export_sfc(_sfc_main$g, [["__scopeId", "data-v-08685139"]]);
const _sfc_main$f = /* @__PURE__ */ defineComponent({
  __name: "FileTreePanel",
  __ssrInlineRender: true,
  props: {
    tree: {},
    selectedFile: {}
  },
  emits: ["file-select", "file-open", "directory-create", "directory-rename", "directory-delete", "file-move"],
  setup(__props, { emit: __emit }) {
    const emit = __emit;
    return (_ctx, _push, _parent, _attrs) => {
      _push(`<div${ssrRenderAttrs(_attrs)}>`);
      _push(ssrRenderComponent(FileTree, {
        tree: _ctx.tree,
        "base-path": "",
        "selected-file": _ctx.selectedFile,
        onFileClick: (p) => emit("file-select", p),
        onFileOpen: (p) => emit("file-open", p),
        onDirectoryCreate: (d) => emit("directory-create", d),
        onDirectoryRename: (d) => emit("directory-rename", d),
        onDirectoryDelete: (d) => emit("directory-delete", d),
        onFileMove: (d) => emit("file-move", d)
      }, null, _parent));
      _push(`</div>`);
    };
  }
});
const _sfc_setup$f = _sfc_main$f.setup;
_sfc_main$f.setup = (props, ctx) => {
  const ssrContext = useSSRContext();
  (ssrContext.modules || (ssrContext.modules = /* @__PURE__ */ new Set())).add("components/FileTreePanel.vue");
  return _sfc_setup$f ? _sfc_setup$f(props, ctx) : void 0;
};
const _sfc_main$e = {
  __name: "SyllabusExplorer",
  __ssrInlineRender: true,
  emits: ["file-click"],
  setup(__props, { emit: __emit }) {
    const kbTree = ref(null);
    const slidesTree = ref(null);
    const loading = ref(false);
    const error2 = ref(null);
    const config = useRuntimeConfig();
    function resolveApiBase2() {
      var _a;
      const configured = ((_a = config.public) == null ? void 0 : _a.apiBaseUrl) || "/api";
      return configured;
    }
    resolveApiBase2();
    const topics = ref([]);
    const search = ref("");
    const filteredTopics = computed(() => {
      const q = (search.value || "").toLowerCase();
      const base = (topics.value || []).filter((t) => Array.isArray(t == null ? void 0 : t.messages) && t.messages.length > 0);
      if (!q) return base;
      return base.filter((t) => (t.name || "").toLowerCase().includes(q));
    });
    function shortTitle(name) {
      if (!name) return "\uC81C\uBAA9 \uC5C6\uC74C";
      return name.length > 18 ? name.slice(0, 18) + "\u2026" : name;
    }
    const emit = __emit;
    const onFileClick = (path) => {
      emit("file-click", path);
    };
    const selectedDirs = ref([]);
    const displayTree = computed(() => {
      if (slidesTree.value) return slidesTree.value;
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
      if (error2.value) {
        _push(`<div>${ssrInterpolate(error2.value)}</div>`);
      } else {
        _push(`<!---->`);
      }
      if (displayTree.value) {
        _push(`<div>`);
        _push(ssrRenderComponent(_sfc_main$f, {
          tree: displayTree.value,
          "selected-file": null,
          onFileSelect: onFileClick,
          onFileOpen: onFileClick
        }, null, _parent));
        _push(`</div>`);
      } else {
        _push(`<!---->`);
      }
      _push(`<div class="mt-6"><div class="flex items-center justify-between mb-2"><h4 class="text-sm font-semibold text-gray-800">\uCC44\uD305</h4><button class="text-xs px-2 py-1 bg-blue-600 text-white rounded">\uC0C8 \uCC44\uD305</button></div><div class="mb-2"><input${ssrRenderAttr("value", search.value)} type="text" placeholder="\uCC44\uD305 \uAC80\uC0C9" class="w-full px-2 py-1 border rounded text-sm"></div><ul class="space-y-1"><!--[-->`);
      ssrRenderList(filteredTopics.value, (t) => {
        _push(`<li class="flex items-center justify-between group"><button class="text-left text-sm w-full truncate px-2 py-1 rounded hover:bg-gray-100"${ssrRenderAttr("title", t.name)}>${ssrInterpolate(shortTitle(t.name))}</button><button class="opacity-0 group-hover:opacity-100 text-gray-500 hover:text-red-600 px-2" title="\uC0AD\uC81C">\xD7</button></li>`);
      });
      _push(`<!--]--></ul></div></div>`);
    };
  }
};
const _sfc_setup$e = _sfc_main$e.setup;
_sfc_main$e.setup = (props, ctx) => {
  const ssrContext = useSSRContext();
  (ssrContext.modules || (ssrContext.modules = /* @__PURE__ */ new Set())).add("components/SyllabusExplorer.vue");
  return _sfc_setup$e ? _sfc_setup$e(props, ctx) : void 0;
};
function stripBasePath(path, basePath = "mcp_knowledge_base") {
  const normalized = path.replace(/\\/g, "/").replace(/^\/+/, "");
  const prefix = basePath.endsWith("/") ? basePath : basePath + "/";
  if (normalized.startsWith(prefix)) return normalized.substring(prefix.length);
  return normalized;
}
let socket = null;
let listeners = {};
function useTaskEvents() {
  function on(type, cb) {
    if (!listeners[type]) listeners[type] = [];
    listeners[type].push(cb);
    return () => {
      listeners[type] = listeners[type].filter((f) => f !== cb);
    };
  }
  function close() {
    try {
      socket == null ? void 0 : socket.close();
    } catch (e) {
    }
  }
  return { on, close };
}
const useTaskStore = defineStore("task", () => {
  const tasks = ref([]);
  let subscribed = false;
  function upsert(patch) {
    const idx = tasks.value.findIndex((t) => t.id === patch.id);
    if (idx >= 0) tasks.value[idx] = { ...tasks.value[idx], ...patch };
    else tasks.value.unshift(patch);
    if (tasks.value.length > 100) tasks.value.pop();
  }
  function subscribe() {
    if (subscribed) return;
    subscribed = true;
    const { on } = useTaskEvents();
    on("generation", (evt) => {
      upsert({ id: evt.task_id, type: "generation", status: evt.status, stage: evt.stage, progress: evt.progress, error: evt.error });
    });
  }
  return { tasks, subscribe };
});
const _sfc_main$d = /* @__PURE__ */ defineComponent({
  __name: "SearchPanel",
  __ssrInlineRender: true,
  props: {
    apiBase: {},
    apiKey: {}
  },
  emits: ["open"],
  setup(__props, { emit: __emit }) {
    const query = ref("");
    const loading = ref(false);
    const searched = ref(false);
    const results = ref([]);
    try {
      if (false) ;
    } catch {
    }
    return (_ctx, _push, _parent, _attrs) => {
      _push(`<div${ssrRenderAttrs(mergeProps({ class: "space-y-3" }, _attrs))}><div class="flex items-center space-x-2"><input${ssrRenderAttr("value", query.value)} type="text" placeholder="\uD30C\uC77C/\uB0B4\uC6A9 \uAC80\uC0C9" class="flex-1 px-2 py-1 border rounded"><button${ssrIncludeBooleanAttr(loading.value) ? " disabled" : ""} class="px-3 py-1 text-sm bg-blue-600 text-white rounded disabled:opacity-50">\uAC80\uC0C9</button>`);
      if (searched.value) {
        _push(`<button class="px-2 py-1 text-xs bg-gray-200 rounded">\uCD08\uAE30\uD654</button>`);
      } else {
        _push(`<!---->`);
      }
      _push(`</div>`);
      if (loading.value) {
        _push(`<div data-testid="loading-indicator" class="text-xs text-gray-500">\uAC80\uC0C9 \uC911...</div>`);
      } else if (searched.value) {
        _push(`<div class="border rounded divide-y max-h-72 overflow-auto bg-white">`);
        if (!results.value.length) {
          _push(`<div class="p-3 text-xs text-gray-500">\uACB0\uACFC \uC5C6\uC74C</div>`);
        } else {
          _push(`<!---->`);
        }
        _push(`<!--[-->`);
        ssrRenderList(results.value, (r) => {
          var _a, _b;
          _push(`<div data-testid="result-item" class="p-2 hover:bg-blue-50 cursor-pointer"><div class="text-xs font-medium">${(_a = r.highlighted_title || r.title) != null ? _a : ""}</div><div class="text-[10px] text-gray-500">${ssrInterpolate(r.path)}</div><div class="text-[11px] text-gray-600">${(_b = r.highlighted_content || (r.content ? r.content.slice(0, 100) + "\u2026" : "")) != null ? _b : ""}</div></div>`);
        });
        _push(`<!--]--></div>`);
      } else {
        _push(`<!---->`);
      }
      _push(`</div>`);
    };
  }
});
const _sfc_setup$d = _sfc_main$d.setup;
_sfc_main$d.setup = (props, ctx) => {
  const ssrContext = useSSRContext();
  (ssrContext.modules || (ssrContext.modules = /* @__PURE__ */ new Set())).add("components/SearchPanel.vue");
  return _sfc_setup$d ? _sfc_setup$d(props, ctx) : void 0;
};
const useToastStore = defineStore("toast", {
  state: () => ({ items: [] }),
  actions: {
    push(type, msg, ttl = 4e3) {
      const id = typeof crypto !== "undefined" && crypto.randomUUID ? crypto.randomUUID() : String(Date.now());
      this.items.push({ id, type, msg, ts: Date.now(), ttl });
      setTimeout(() => this.remove(id), ttl);
    },
    pushWithLink(type, msg, link, ttl = 6e3) {
      const id = typeof crypto !== "undefined" && crypto.randomUUID ? crypto.randomUUID() : String(Date.now());
      this.items.push({ id, type, msg, ts: Date.now(), ttl, link });
      setTimeout(() => this.remove(id), ttl);
    },
    remove(id) {
      this.items = this.items.filter((t) => t.id !== id);
    }
  }
});
const _sfc_main$c = /* @__PURE__ */ defineComponent({
  __name: "ExternalGeneratePanel",
  __ssrInlineRender: true,
  emits: ["open"],
  setup(__props, { emit: __emit }) {
    useKbApi();
    useTaskStore();
    useToastStore();
    const topic = ref("");
    const targetPath = ref("");
    const failStage = ref("");
    const stages = ["collect", "extract", "cluster", "summarize", "compose", "validate"];
    ref();
    const running = ref(false);
    const status = ref("");
    const errorMsg = ref("");
    const successMsg = ref("");
    const progress = computed(() => {
      const m = status.value.match(/(\d+)%/);
      return m ? Number(m[1]) : 0;
    });
    const canStart = computed(() => topic.value.trim().length > 2);
    return (_ctx, _push, _parent, _attrs) => {
      _push(`<div${ssrRenderAttrs(mergeProps({ class: "space-y-3" }, _attrs))}><textarea rows="3" placeholder="\uC0DD\uC131\uD560 \uBB38\uC11C \uC8FC\uC81C" class="w-full px-2 py-1 border rounded">${ssrInterpolate(topic.value)}</textarea><input${ssrRenderAttr("value", targetPath.value)} type="text" placeholder="\uC800\uC7A5 \uACBD\uB85C(optional)" class="w-full px-2 py-1 border rounded"><div class="flex items-center gap-2 text-xs text-gray-500"><span>\uC2E4\uD328 \uC2A4\uD14C\uC774\uC9C0</span><select class="border rounded px-1 py-0.5 bg-white"><option value=""${ssrIncludeBooleanAttr(Array.isArray(failStage.value) ? ssrLooseContain(failStage.value, "") : ssrLooseEqual(failStage.value, "")) ? " selected" : ""}>--</option><!--[-->`);
      ssrRenderList(stages, (s) => {
        _push(`<option${ssrIncludeBooleanAttr(Array.isArray(failStage.value) ? ssrLooseContain(failStage.value, null) : ssrLooseEqual(failStage.value, null)) ? " selected" : ""}>${ssrInterpolate(s)}</option>`);
      });
      _push(`<!--]--></select>`);
      if (failStage.value) {
        _push(`<button class="text-gray-400 hover:text-gray-600">\uCD08\uAE30\uD654</button>`);
      } else {
        _push(`<!---->`);
      }
      _push(`</div><div class="flex items-center gap-2"><button${ssrIncludeBooleanAttr(!canStart.value || running.value) ? " disabled" : ""} class="px-4 py-2 bg-blue-600 text-white text-sm rounded disabled:opacity-50 flex items-center gap-2">`);
      if (running.value) {
        _push(`<span class="animate-spin h-4 w-4 border-2 border-white border-t-transparent rounded-full"></span>`);
      } else {
        _push(`<!---->`);
      }
      _push(` ${ssrInterpolate(running.value ? "\uC0DD\uC131 \uC911..." : "AI \uBB38\uC11C \uC0DD\uC131")}</button>`);
      if (!running.value && (errorMsg.value || successMsg.value)) {
        _push(`<button class="px-2 py-1 text-xs bg-gray-200 rounded">Retry</button>`);
      } else {
        _push(`<!---->`);
      }
      if (running.value) {
        _push(`<div class="flex items-center gap-2 text-xs text-blue-600"><span>${ssrInterpolate(status.value)}</span><div class="w-28 h-2 bg-gray-200 rounded overflow-hidden"><div class="h-full bg-blue-500" style="${ssrRenderStyle({ width: progress.value + "%" })}"></div></div></div>`);
      } else {
        _push(`<!---->`);
      }
      _push(`</div>`);
      if (errorMsg.value) {
        _push(`<div class="text-xs text-red-600">${ssrInterpolate(errorMsg.value)}</div>`);
      } else {
        _push(`<!---->`);
      }
      if (successMsg.value) {
        _push(`<div class="text-xs text-green-600">${ssrInterpolate(successMsg.value)}</div>`);
      } else {
        _push(`<!---->`);
      }
      _push(`</div>`);
    };
  }
});
const _sfc_setup$c = _sfc_main$c.setup;
_sfc_main$c.setup = (props, ctx) => {
  const ssrContext = useSSRContext();
  (ssrContext.modules || (ssrContext.modules = /* @__PURE__ */ new Set())).add("components/ExternalGeneratePanel.vue");
  return _sfc_setup$c ? _sfc_setup$c(props, ctx) : void 0;
};
const _sfc_main$b = /* @__PURE__ */ defineComponent({
  __name: "TrendingCategoriesModal",
  __ssrInlineRender: true,
  emits: ["close"],
  setup(__props, { emit: __emit }) {
    useKbApi();
    const categories = ref([]);
    const form = ref({ name: "", query: "", enabled: true });
    const isRunning = ref(false);
    return (_ctx, _push, _parent, _attrs) => {
      _push(`<div${ssrRenderAttrs(mergeProps({ class: "fixed inset-0 z-40 bg-black/40 flex items-center justify-center" }, _attrs))}><div class="w-[680px] max-w-[90vw] bg-white rounded shadow flex flex-col"><div class="p-3 border-b text-sm flex items-center"><span class="font-semibold">\uAD00\uC2EC \uCE74\uD14C\uACE0\uB9AC \uAD00\uB9AC</span><div class="flex-1"></div><button class="px-2 py-1 text-xs border rounded">Close</button></div><div class="p-3 space-y-3"><div class="flex items-center gap-2"><input${ssrRenderAttr("value", form.value.name)} placeholder="\uC774\uB984(\uC608: aws)" class="border rounded px-2 py-1 text-sm"><input${ssrRenderAttr("value", form.value.query)} placeholder="\uAC80\uC0C9 \uCFFC\uB9AC" class="border rounded px-2 py-1 text-sm flex-1"><label class="text-xs flex items-center gap-1"><input type="checkbox"${ssrIncludeBooleanAttr(Array.isArray(form.value.enabled) ? ssrLooseContain(form.value.enabled, null) : form.value.enabled) ? " checked" : ""} class="accent-indigo-600"> enabled</label><button class="px-2 py-1 text-xs bg-indigo-600 text-white rounded">\uC800\uC7A5</button><button${ssrIncludeBooleanAttr(isRunning.value) ? " disabled" : ""} class="${ssrRenderClass([
        "px-2 py-1 text-xs rounded shadow",
        isRunning.value ? "bg-indigo-300 text-white opacity-70 cursor-not-allowed" : "bg-indigo-600 text-white hover:bg-indigo-700"
      ])}">Run Now</button></div><div class="border rounded"><table class="w-full text-sm"><thead><tr class="bg-gray-50 text-left"><th class="px-2 py-1">\uC774\uB984</th><th class="px-2 py-1">\uCFFC\uB9AC</th><th class="px-2 py-1 w-20">\uC0AC\uC6A9</th><th class="px-2 py-1 w-24"></th></tr></thead><tbody><!--[-->`);
      ssrRenderList(categories.value, (c) => {
        _push(`<tr class="border-t"><td class="px-2 py-1">${ssrInterpolate(c.name)}</td><td class="px-2 py-1">${ssrInterpolate(c.query)}</td><td class="px-2 py-1">${ssrInterpolate(c.enabled ? "ON" : "OFF")}</td><td class="px-2 py-1 text-right"><button class="text-xs border rounded px-2 py-0.5 mr-1">Edit</button><button class="text-xs border rounded px-2 py-0.5">Del</button></td></tr>`);
      });
      _push(`<!--]-->`);
      if (!categories.value.length) {
        _push(`<tr><td class="px-2 py-4 text-center text-gray-400" colspan="4">No categories</td></tr>`);
      } else {
        _push(`<!---->`);
      }
      _push(`</tbody></table></div></div></div></div>`);
    };
  }
});
const _sfc_setup$b = _sfc_main$b.setup;
_sfc_main$b.setup = (props, ctx) => {
  const ssrContext = useSSRContext();
  (ssrContext.modules || (ssrContext.modules = /* @__PURE__ */ new Set())).add("components/TrendingCategoriesModal.vue");
  return _sfc_setup$b ? _sfc_setup$b(props, ctx) : void 0;
};
const apiKey$1 = "my_mcp_eagle_tiger";
const _sfc_main$a = {
  __name: "KnowledgeBaseExplorer",
  __ssrInlineRender: true,
  props: {
    // mode: 'full' (검색+트리), 'search' (검색 패널), 'tree' (파일 트리만)
    mode: { type: String, default: "full" },
    selectedFile: { type: String, default: "" }
  },
  emits: ["file-select"],
  setup(__props, { emit: __emit }) {
    const emit = __emit;
    const props = __props;
    const config = useRuntimeConfig();
    function resolveApiBase2() {
      var _a;
      const configured = ((_a = config.public) == null ? void 0 : _a.apiBaseUrl) || "/api";
      return configured;
    }
    const apiBase = resolveApiBase2();
    useTaskStore();
    const showGenModal = ref(false);
    const showTrending = ref(false);
    const showAdmin = ref(false);
    const allKbDirs = ref([]);
    const allDirsLoading = ref(false);
    const selectedDirs = ref([]);
    const saving = ref(false);
    const treeData = ref({ "mcp_knowledge_base": { files: [] } });
    const selectedFile = ref(null);
    watch(() => props.selectedFile, (p) => {
      selectedFile.value = p ? "mcp_knowledge_base/" + stripBasePath(p) : null;
    }, { immediate: true });
    const isInitialLoading = ref(true);
    const statusMessage = ref("");
    const loadKnowledgeBaseStructure = async () => {
      try {
        const response = await fetch(`${apiBase}/v1/knowledge-base/tree`, {
          headers: { "X-API-Key": apiKey$1 }
        });
        if (!response.ok) throw new Error("Failed to load structure");
        const data = await response.json();
        treeData.value = { "mcp_knowledge_base": data };
      } catch (error2) {
        console.error("Error loading structure:", error2);
        statusMessage.value = "\uAD6C\uC870 \uB85C\uB529 \uC2E4\uD328";
        if (!treeData.value || !Object.keys(treeData.value).length) {
          treeData.value = { "mcp_knowledge_base": { files: [] } };
        }
      } finally {
        isInitialLoading.value = false;
      }
    };
    const handleFileSelect = (path) => {
      const p = stripBasePath(path);
      emit("file-select", p);
    };
    const handleFileOpen = (path) => {
      const p = stripBasePath(path);
      emit("file-select", p);
    };
    function onExternalGenerated(path) {
      showGenModal.value = false;
      if (path) emit("file-select", stripBasePath(path));
    }
    const handleDirectoryCreate = async (data) => {
      try {
        console.log("Creating item:", data);
        const response = await fetch(`${apiBase}/api/v1/knowledge-base/item`, {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
            "X-API-Key": apiKey$1
          },
          body: JSON.stringify({
            path: stripBasePath(data.path),
            type: data.type,
            content: data.type === "file" ? "" : void 0
          })
        });
        if (!response.ok) {
          const errorData = await response.json();
          throw new Error(`Failed to create ${data.type}: ${response.status} ${errorData.detail || "Unknown error"}`);
        }
        const result = await response.json();
        console.log(`${data.type} created:`, result);
        statusMessage.value = `${data.type === "file" ? "\uD30C\uC77C" : "\uB514\uB809\uD1A0\uB9AC"} \uC0DD\uC131 \uC644\uB8CC`;
        await loadKnowledgeBaseStructure();
      } catch (error2) {
        console.error(`Error creating ${data.type}:`, error2);
        statusMessage.value = `${data.type === "file" ? "\uD30C\uC77C" : "\uB514\uB809\uD1A0\uB9AC"} \uC0DD\uC131 \uC2E4\uD328: ${error2.message}`;
      }
    };
    const handleDirectoryRename = async (data) => {
      try {
        console.log("Renaming item:", data);
        const response = await fetch(`${apiBase}/api/v1/knowledge-base/item`, {
          method: "PATCH",
          headers: {
            "Content-Type": "application/json",
            "X-API-Key": apiKey$1
          },
          body: JSON.stringify({
            path: stripBasePath(data.oldPath),
            new_path: stripBasePath(data.newPath)
          })
        });
        if (!response.ok) {
          const errorData = await response.json();
          throw new Error(`Failed to rename item: ${response.status} ${errorData.detail || "Unknown error"}`);
        }
        const result = await response.json();
        console.log("Item renamed:", result);
        statusMessage.value = "\uC774\uB984 \uBCC0\uACBD \uC644\uB8CC";
        await loadKnowledgeBaseStructure();
      } catch (error2) {
        console.error("Error renaming item:", error2);
        statusMessage.value = `\uC774\uB984 \uBCC0\uACBD \uC2E4\uD328: ${error2.message}`;
      }
    };
    const handleDirectoryDelete = async (data) => {
      try {
        console.log("Deleting item:", data);
        if (data.type === "file") {
          const response = await fetch(`${apiBase}/api/v1/knowledge-base/item?path=${encodeURIComponent(stripBasePath(data.path))}`, {
            method: "DELETE",
            headers: { "X-API-Key": apiKey$1 }
          });
          if (!response.ok) {
            const errorData = await response.json();
            throw new Error(`Failed to delete file: ${response.status} ${errorData.detail || "Unknown error"}`);
          }
          statusMessage.value = "\uD30C\uC77C \uC0AD\uC81C \uC644\uB8CC";
        } else {
          const response = await fetch(`${apiBase}/api/v1/knowledge-base/directory?path=${encodeURIComponent(stripBasePath(data.path))}&recursive=true`, {
            method: "DELETE",
            headers: { "X-API-Key": apiKey$1 }
          });
          if (!response.ok) {
            const errorData = await response.json();
            throw new Error(`Failed to delete directory: ${response.status} ${errorData.detail || "Unknown error"}`);
          }
          statusMessage.value = "\uB514\uB809\uD1A0\uB9AC \uC0AD\uC81C \uC644\uB8CC";
        }
        await loadKnowledgeBaseStructure();
      } catch (error2) {
        console.error("Error deleting item:", error2);
        statusMessage.value = `\uC0AD\uC81C \uC2E4\uD328: ${error2.message}`;
      }
    };
    const handleFileMove = async (data) => {
      try {
        console.log("Moving file (original data):", data);
        const oldPath = stripBasePath(data.oldPath);
        const newPath = stripBasePath(data.newPath);
        console.log("Moving file (stripped paths):", { oldPath, newPath });
        const requestBody = {
          path: oldPath,
          new_path: newPath
        };
        const response = await fetch(`${apiBase}/api/v1/knowledge-base/move`, {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
            "X-API-Key": apiKey$1
          },
          body: JSON.stringify(requestBody)
        });
        if (!response.ok) {
          const errorData = await response.json();
          throw new Error(`Failed to move file: ${response.status} ${errorData.detail || "Unknown error"}`);
        }
        const result = await response.json();
        console.log("File moved:", result);
        statusMessage.value = "\uD30C\uC77C \uC774\uB3D9 \uC644\uB8CC";
        await loadKnowledgeBaseStructure();
      } catch (error2) {
        console.error("Error moving file:", error2);
        statusMessage.value = `\uD30C\uC77C \uC774\uB3D9 \uC2E4\uD328: ${error2.message}`;
      }
    };
    return (_ctx, _push, _parent, _attrs) => {
      _push(`<!--[--><div class="p-4 space-y-4 h-full flex flex-col">`);
      if (__props.mode !== "search") {
        _push(`<!--[-->`);
        if (__props.mode !== "search") {
          _push(`<h2 class="text-lg font-semibold">\uC9C0\uC2DD\uBCA0\uC774\uC2A4</h2>`);
        } else {
          _push(`<!---->`);
        }
        _push(`<!--]-->`);
      } else {
        _push(`<!---->`);
      }
      if (__props.mode === "tree") {
        _push(`<!--[--><div class="flex items-center justify-between"><div></div><div class="flex items-center gap-2"><button class="mb-2 px-2 py-1 text-xs border rounded" title="\uC2AC\uB77C\uC774\uB4DC \uB514\uB809\uD1A0\uB9AC \uC124\uC815">\uC124\uC815</button><button class="mb-2 px-2 py-1 text-xs border rounded">\uAD00\uC2EC \uCE74\uD14C\uACE0\uB9AC</button></div></div><div class="flex-1 min-h-0 overflow-auto">`);
        if (isInitialLoading.value) {
          _push(`<div class="text-center py-8 text-sm text-gray-500">\uB85C\uB529 \uC911\u2026</div>`);
        } else {
          _push(ssrRenderComponent(_sfc_main$f, {
            tree: treeData.value,
            "selected-file": props.selectedFile ? "mcp_knowledge_base/" + unref(stripBasePath)(props.selectedFile) : null,
            onFileSelect: handleFileSelect,
            onFileOpen: handleFileOpen,
            onDirectoryCreate: handleDirectoryCreate,
            onDirectoryRename: handleDirectoryRename,
            onDirectoryDelete: handleDirectoryDelete,
            onFileMove: handleFileMove
          }, null, _parent));
        }
        _push(`</div><!--]-->`);
      } else {
        _push(`<!--[--><div class="flex items-center justify-between mb-2"><div></div><div class="flex items-center gap-2"><button class="px-2 py-1 text-xs border rounded" title="\uC2AC\uB77C\uC774\uB4DC \uB514\uB809\uD1A0\uB9AC \uC124\uC815">\uC124\uC815</button><button class="px-2 py-1 text-xs border rounded">\uAD00\uC2EC \uCE74\uD14C\uACE0\uB9AC</button></div></div>`);
        _push(ssrRenderComponent(_sfc_main$d, {
          "api-base": unref(apiBase),
          "api-key": apiKey$1,
          onOpen: ($event) => emit("file-select", $event)
        }, null, _parent));
        _push(`<div class="border rounded bg-white flex-1 min-h-0 overflow-hidden"><div class="h-full min-h-0 overflow-auto">`);
        if (isInitialLoading.value) {
          _push(`<div class="text-center py-8 text-sm text-gray-500">\uB85C\uB529 \uC911\u2026</div>`);
        } else {
          _push(ssrRenderComponent(_sfc_main$f, {
            tree: treeData.value,
            "selected-file": props.selectedFile ? "mcp_knowledge_base/" + unref(stripBasePath)(props.selectedFile) : null,
            onFileSelect: handleFileSelect,
            onFileOpen: handleFileOpen,
            onDirectoryCreate: handleDirectoryCreate,
            onDirectoryRename: handleDirectoryRename,
            onDirectoryDelete: handleDirectoryDelete,
            onFileMove: handleFileMove
          }, null, _parent));
        }
        _push(`</div></div><button class="fixed bottom-6 right-6 z-20 rounded-full w-14 h-14 bg-blue-600 text-white shadow-lg hover:bg-blue-700" title="\uC678\uBD80\uC790\uB8CC \uAE30\uBC18 \uBB38\uC11C \uC0DD\uC131"> + </button>`);
        if (showGenModal.value) {
          _push(ssrRenderComponent(_sfc_main$c, {
            onOpen: onExternalGenerated,
            onClose: ($event) => showGenModal.value = false
          }, null, _parent));
        } else {
          _push(`<!---->`);
        }
        _push(`<!--]-->`);
      }
      _push(`</div>`);
      if (showTrending.value) {
        _push(ssrRenderComponent(_sfc_main$b, {
          onClose: ($event) => showTrending.value = false
        }, null, _parent));
      } else {
        _push(`<!---->`);
      }
      if (showAdmin.value) {
        _push(`<div class="fixed inset-0 bg-black/30 flex items-center justify-center z-50"><div class="bg-white rounded shadow-lg w-[520px] max-w-[92vw] p-4"><div class="flex items-center justify-between mb-2"><h4 class="text-sm font-semibold">\uC2AC\uB77C\uC774\uB4DC \uB514\uB809\uD1A0\uB9AC \uC120\uD0DD</h4><button class="text-gray-500 hover:text-black">\u2715</button></div><div class="text-xs text-gray-600 mb-3">mcp_knowledge_base \uD558\uC704\uC758 \uB514\uB809\uD1A0\uB9AC \uC911 \uC2AC\uB77C\uC774\uB4DC\uB85C \uC0AC\uC6A9\uD560 \uB8E8\uD2B8\uB97C \uC120\uD0DD\uD558\uC138\uC694.</div>`);
        if (allDirsLoading.value) {
          _push(`<div class="text-sm text-gray-500">\uBD88\uB7EC\uC624\uB294 \uC911\u2026</div>`);
        } else {
          _push(`<div class="max-h-60 overflow-auto border rounded p-2 space-y-1"><!--[-->`);
          ssrRenderList(allKbDirs.value, (dir) => {
            _push(`<label class="flex items-center gap-2 text-sm"><input type="checkbox"${ssrRenderAttr("value", dir)}${ssrIncludeBooleanAttr(Array.isArray(selectedDirs.value) ? ssrLooseContain(selectedDirs.value, dir) : selectedDirs.value) ? " checked" : ""}><span class="font-mono">${ssrInterpolate(dir)}</span></label>`);
          });
          _push(`<!--]-->`);
          if (!allKbDirs.value.length) {
            _push(`<div class="text-xs text-gray-400">\uC120\uD0DD \uAC00\uB2A5\uD55C \uB514\uB809\uD1A0\uB9AC\uAC00 \uC5C6\uC2B5\uB2C8\uB2E4.</div>`);
          } else {
            _push(`<!---->`);
          }
          _push(`</div>`);
        }
        _push(`<div class="mt-3 flex items-center justify-end gap-2"><button class="px-3 py-1 text-xs border rounded">\uCDE8\uC18C</button><button class="px-3 py-1 text-xs bg-blue-600 text-white rounded disabled:opacity-50"${ssrIncludeBooleanAttr(saving.value) ? " disabled" : ""}>\uC800\uC7A5</button></div></div></div>`);
      } else {
        _push(`<!---->`);
      }
      _push(`<!--]-->`);
    };
  }
};
const _sfc_setup$a = _sfc_main$a.setup;
_sfc_main$a.setup = (props, ctx) => {
  const ssrContext = useSSRContext();
  (ssrContext.modules || (ssrContext.modules = /* @__PURE__ */ new Set())).add("components/KnowledgeBaseExplorer.vue");
  return _sfc_setup$a ? _sfc_setup$a(props, ctx) : void 0;
};
const _sfc_main$9 = {
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
    function sideRows(h2) {
      const rows = [];
      let adds = [];
      let dels = [];
      for (const ln of h2.lines) {
        if (ln.type === "context") {
          while (dels.length || adds.length) {
            const d = dels.shift() || { old_line: null, text: "", type: "del" };
            const a = adds.shift() || { new_line: null, text: "", type: "add" };
            rows.push({ key: h2.header + "-" + rows.length, type: d.type === "del" && a.type === "add" ? "change" : d.type === "del" ? "del" : "add", old_line: d.old_line, old_text: d.text, new_line: a.new_line, new_text: a.text });
          }
          rows.push({ key: h2.header + "-ctx-" + rows.length, type: "context", old_line: ln.old_line, old_text: ln.text, new_line: ln.new_line, new_text: ln.text });
        } else if (ln.type === "del") {
          dels.push(ln);
        } else if (ln.type === "add") {
          adds.push(ln);
        }
      }
      while (dels.length || adds.length) {
        const d = dels.shift() || { old_line: null, text: "", type: "del" };
        const a = adds.shift() || { new_line: null, text: "", type: "add" };
        rows.push({ key: h2.header + "-" + rows.length, type: d.type === "del" && a.type === "add" ? "change" : d.type === "del" ? "del" : "add", old_line: d.old_line, old_text: d.text, new_line: a.new_line, new_text: a.text });
      }
      return rows;
    }
    function rowClass(row) {
      if (row.type === "add") return "bg-green-50";
      if (row.type === "del") return "bg-red-50";
      if (row.type === "change") return "bg-yellow-50";
      return "";
    }
    function tokenize2(str) {
      if (!str) return [];
      return str.split(/(\s+)/);
    }
    function inlineDiff(oldText, newText) {
      if (oldText === newText) return { oldHtml: escapeHtml(oldText), newHtml: escapeHtml(newText) };
      if (oldText.length + newText.length > 800) return { oldHtml: escapeHtml(oldText), newHtml: escapeHtml(newText) };
      const a = tokenize2(oldText);
      const b = tokenize2(newText);
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
          ssrRenderList(displayHunks.value, (h2, i) => {
            _push(`<div class="mb-4"><div class="bg-gray-200 text-gray-700 px-1 py-0.5 text-xs">${ssrInterpolate(h2.header)}</div><pre class="whitespace-pre-wrap"><!--[-->`);
            ssrRenderList(h2.lines, (line, li) => {
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
          ssrRenderList(displayHunks.value, (h2, i) => {
            _push(`<div class="mb-6 border rounded"><div class="bg-gray-100 text-gray-700 px-2 py-1 text-xs font-mono">${ssrInterpolate(h2.header)}</div><table class="w-full text-[11px] font-mono"><tbody><!--[-->`);
            ssrRenderList(sideRows(h2), (row) => {
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
const _sfc_setup$9 = _sfc_main$9.setup;
_sfc_main$9.setup = (props, ctx) => {
  const ssrContext = useSSRContext();
  (ssrContext.modules || (ssrContext.modules = /* @__PURE__ */ new Set())).add("components/DiffViewer.vue");
  return _sfc_setup$9 ? _sfc_setup$9(props, ctx) : void 0;
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
const _sfc_main$8 = /* @__PURE__ */ defineComponent({
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
const _sfc_setup$8 = _sfc_main$8.setup;
_sfc_main$8.setup = (props, ctx) => {
  const ssrContext = useSSRContext();
  (ssrContext.modules || (ssrContext.modules = /* @__PURE__ */ new Set())).add("components/KbToolbar.vue");
  return _sfc_setup$8 ? _sfc_setup$8(props, ctx) : void 0;
};
const _sfc_main$7 = {
  __name: "KbSidePanel",
  __ssrInlineRender: true,
  props: {
    path: { type: String, required: false },
    content: { type: String, required: false, default: "" }
  },
  emits: ["goto-line"],
  setup(__props) {
    const props = __props;
    const api = useKbApi();
    const active = ref("outline");
    const outline = ref([]);
    const outlineLoading = ref(false);
    function buildLocalOutline(md) {
      const out = [];
      if (!md) return out;
      const lines = String(md).split(/\r?\n/);
      let inCode = false;
      let inFrontmatter = false;
      if (lines.length && /^\s*---\s*$/.test(lines[0])) {
        inFrontmatter = true;
      }
      for (let i = 0; i < lines.length; i++) {
        const line = lines[i];
        if (inFrontmatter) {
          if (/^\s*---\s*$/.test(line) && i !== 0) {
            inFrontmatter = false;
          }
          continue;
        }
        if (/^\s*```/.test(line) || /^\s*~~~/.test(line)) {
          inCode = !inCode;
          continue;
        }
        if (inCode) continue;
        const m = line.match(/^\s{0,3}(#{1,6})\s*(.*?)\s*#*\s*$/);
        if (m && m[2]) {
          let text = String(m[2]).trim();
          text = text.replace(/\[([^\]]+)\]\([^\)]+\)/g, "$1").replace(/[*_]{1,3}([^*_]+)[*_]{1,3}/g, "$1").replace(/`([^`]+)`/g, "$1").replace(/<[^>]+>/g, "").trim();
          if (text) {
            out.push({ level: m[1].length, text, line: i + 1 });
          }
          continue;
        }
        if (i + 1 < lines.length) {
          const next = lines[i + 1];
          if (/^=+\s*$/.test(next) && line.trim()) {
            let text = line.trim();
            text = text.replace(/\[([^\]]+)\]\([^\)]+\)/g, "$1").replace(/[*_]{1,3}([^*_]+)[*_]{1,3}/g, "$1").replace(/`([^`]+)`/g, "$1").replace(/<[^>]+>/g, "").trim();
            out.push({ level: 1, text, line: i + 1 });
            i++;
            continue;
          } else if (/^-+\s*$/.test(next) && line.trim()) {
            let text = line.trim();
            text = text.replace(/\[([^\]]+)\]\([^\)]+\)/g, "$1").replace(/[*_]{1,3}([^*_]+)[*_]{1,3}/g, "$1").replace(/`([^`]+)`/g, "$1").replace(/<[^>]+>/g, "").trim();
            out.push({ level: 2, text, line: i + 1 });
            i++;
            continue;
          }
        }
      }
      return out;
    }
    async function refreshOutline() {
      if (props.content === void 0 || props.content === null) {
        outline.value = [];
        return;
      }
      outlineLoading.value = true;
      const local = buildLocalOutline(props.content);
      try {
        const data = await api.outline(props.content);
        let server = data && Array.isArray(data.outline) ? data.outline : [];
        server = server.map((it) => ({
          level: it == null ? void 0 : it.level,
          line: it == null ? void 0 : it.line,
          text: typeof (it == null ? void 0 : it.text) === "string" ? it.text.trim() : ""
        })).filter((it) => it.level && it.line);
        const byLine = /* @__PURE__ */ new Map();
        for (const it of local) {
          byLine.set(it.line, { ...it });
        }
        for (const it of server) {
          if (!byLine.has(it.line)) {
            byLine.set(it.line, { ...it });
          }
        }
        outline.value = Array.from(byLine.values()).sort((a, b) => a.line - b.line);
      } catch {
        outline.value = local;
      } finally {
        outlineLoading.value = false;
      }
    }
    watch(() => props.content, () => {
      refreshOutline();
    });
    watch(() => props.path, () => {
      refreshOutline();
      diffLeft.value = null;
      diffRight.value = null;
      loadVersions();
    });
    const versions = ref([]);
    const versionsLoading = ref(false);
    const versionsSorted = computed(() => [...versions.value].sort((a, b) => b.version_no - a.version_no));
    const diffLeft = ref(null);
    const diffRight = ref(null);
    const diffKey = computed(() => `${diffLeft.value || ""}-${diffRight.value || ""}`);
    async function loadVersions() {
      if (!props.path) {
        versions.value = [];
        return;
      }
      versionsLoading.value = true;
      try {
        const data = await api.listVersions(props.path);
        versions.value = data.versions || [];
      } finally {
        versionsLoading.value = false;
      }
    }
    function formatTs(ts) {
      try {
        return ts ? new Date(ts).toLocaleString() : "";
      } catch (e) {
        return ts;
      }
    }
    function tabClass(name) {
      return name === active.value ? "px-2 py-1 rounded bg-white border text-gray-800" : "px-2 py-1 rounded bg-gray-200 text-gray-700";
    }
    return (_ctx, _push, _parent, _attrs) => {
      _push(`<div${ssrRenderAttrs(mergeProps({ class: "w-72 flex-none bg-gray-50 flex flex-col min-h-0" }, _attrs))}><div class="p-2 font-semibold text-xs tracking-wide text-gray-700 border-b flex items-center gap-2"><button class="${ssrRenderClass(tabClass("outline"))}">Outline</button><button class="${ssrRenderClass(tabClass("versions"))}">Versions</button><button class="${ssrRenderClass(tabClass("diff"))}">Diff</button><div class="ml-auto"></div>`);
      if (active.value === "outline") {
        _push(`<button class="text-[10px] px-1 py-0.5 bg-white border rounded"${ssrIncludeBooleanAttr(outlineLoading.value) ? " disabled" : ""}>\u21BB</button>`);
      } else {
        _push(`<!---->`);
      }
      if (active.value !== "outline") {
        _push(`<button class="text-[10px] px-1 py-0.5 bg-white border rounded"${ssrIncludeBooleanAttr(versionsLoading.value) ? " disabled" : ""}>\u21BB</button>`);
      } else {
        _push(`<!---->`);
      }
      _push(`</div>`);
      if (__props.path) {
        _push(`<div class="px-2 py-1 text-[10px] text-gray-500 truncate"${ssrRenderAttr("title", __props.path || "")}>${ssrInterpolate(__props.path)}</div>`);
      } else {
        _push(`<!---->`);
      }
      _push(`<div class="flex-1 overflow-auto text-sm">`);
      if (active.value === "outline") {
        _push(`<div class="p-2"><ul><!--[-->`);
        ssrRenderList(outline.value, (item) => {
          _push(`<li><button class="block w-full text-left px-2 py-1 hover:bg-indigo-50 rounded" style="${ssrRenderStyle({ paddingLeft: (item.level - 1) * 12 + "px" })}"><span class="${ssrRenderClass({ "font-semibold": item.level === 1 })}">${ssrInterpolate(item.text)}</span></button></li>`);
        });
        _push(`<!--]--></ul>`);
        if (!outline.value.length && !outlineLoading.value) {
          _push(`<div class="text-gray-400 text-xs p-2">No outline</div>`);
        } else {
          _push(`<!---->`);
        }
        _push(`</div>`);
      } else if (active.value === "versions") {
        _push(`<div><ul><!--[-->`);
        ssrRenderList(versionsSorted.value, (v) => {
          _push(`<li class="border-b px-2 py-1 hover:bg-indigo-50 cursor-pointer group"><div class="flex items-center justify-between"><div class="font-mono">v${ssrInterpolate(v.version_no)}</div>`);
          if (v.version_no === diffLeft.value) {
            _push(`<span class="text-[10px] text-indigo-600">LEFT</span>`);
          } else if (v.version_no === diffRight.value) {
            _push(`<span class="text-[10px] text-green-600">RIGHT</span>`);
          } else {
            _push(`<!---->`);
          }
          _push(`</div><div class="truncate text-[11px]"${ssrRenderAttr("title", v.message)}>${ssrInterpolate(v.message || "\u2014")}</div><div class="text-[10px] text-gray-400">${ssrInterpolate(formatTs(v.created_at))}</div></li>`);
        });
        _push(`<!--]-->`);
        if (!versions.value.length && !versionsLoading.value) {
          _push(`<li class="px-2 py-4 text-center text-gray-400">No versions</li>`);
        } else {
          _push(`<!---->`);
        }
        _push(`</ul></div>`);
      } else {
        _push(`<div class="p-2">`);
        if (versions.value.length && diffLeft.value && diffRight.value) {
          _push(ssrRenderComponent(_sfc_main$9, {
            key: diffKey.value,
            path: __props.path,
            versions: versionsSorted.value,
            "default-left": diffLeft.value,
            "default-right": diffRight.value,
            onClose: ($event) => {
              diffLeft.value = null;
              diffRight.value = null;
            }
          }, null, _parent));
        } else {
          _push(`<div class="text-xs text-gray-500">Select two versions in Versions tab.</div>`);
        }
        _push(`</div>`);
      }
      _push(`</div></div>`);
    };
  }
};
const _sfc_setup$7 = _sfc_main$7.setup;
_sfc_main$7.setup = (props, ctx) => {
  const ssrContext = useSSRContext();
  (ssrContext.modules || (ssrContext.modules = /* @__PURE__ */ new Set())).add("components/KbSidePanel.vue");
  return _sfc_setup$7 ? _sfc_setup$7(props, ctx) : void 0;
};
const useDocStore = defineStore("doc", () => {
  const api = useKbApi();
  const path = ref("");
  const content = ref("");
  const loading = ref(false);
  const dirty = ref(false);
  const version2 = ref();
  const baseVersion = ref();
  const error2 = ref();
  async function open(p) {
    loading.value = true;
    error2.value = void 0;
    try {
      path.value = p;
      try {
        if (false) ;
      } catch {
      }
      const data = await api.getItem(p);
      content.value = data.content || "";
      version2.value = data.version_no;
      baseVersion.value = data.version_no;
      dirty.value = false;
    } catch (e) {
      error2.value = e.message || "load failed";
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
      const res = await api.saveItem(path.value, content.value, message, version2.value);
      version2.value = res.version_no;
      baseVersion.value = res.version_no;
      dirty.value = false;
      return { conflict: false, version: res.version_no };
    } catch (e) {
      if ((_a = e.message) == null ? void 0 : _a.includes("409")) {
        return { conflict: true };
      }
      error2.value = e.message;
      return { conflict: false, error: e.message };
    }
  }
  const status = computed(() => loading.value ? "loading" : dirty.value ? "modified" : "clean");
  return { path, content, version: version2, baseVersion, loading, dirty, error: error2, status, open, update, save, whenLoaded };
});
const chartPlaceholder = '{ "$schema": "https://vega.github.io/schema/vega-lite/v5.json", ... }';
const _sfc_main$6 = {
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
        await fetch(`${apiBase}/api/v1/knowledge-base/move`, { method: "POST", headers: { "Content-Type": "application/json", "X-API-Key": "my_mcp_eagle_tiger" }, body: JSON.stringify({ path: p, new_path: trashPath }) });
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
      _push(`<div${ssrRenderAttrs(mergeProps({ class: "flex h-full w-full overflow-hidden" }, _attrs))} data-v-03e0ffcf>`);
      if (showOutline.value) {
        _push(`<div class="w-56 flex-none border-r bg-gray-50 flex flex-col" data-v-03e0ffcf><div class="p-2 font-semibold text-xs tracking-wide text-gray-600 border-b" data-v-03e0ffcf>OUTLINE</div><div class="flex-1 overflow-auto text-sm" role="tree" aria-label="Document outline" data-v-03e0ffcf><ul data-v-03e0ffcf><!--[-->`);
        ssrRenderList(outline.value, (item) => {
          _push(`<li role="none" data-v-03e0ffcf><button role="treeitem"${ssrRenderAttr("aria-current", activeOutlineLine.value && item.line === activeOutlineLine.value ? "true" : "false")} class="${ssrRenderClass([["pl-" + item.level * 2, activeOutlineLine.value && item.line === activeOutlineLine.value ? "bg-indigo-100 text-indigo-700" : ""], "block w-full text-left px-2 py-1 hover:bg-indigo-50 rounded focus:outline-none focus:ring-1 focus:ring-indigo-400"])}"${ssrRenderAttr("title", `Line ${item.line}`)} data-v-03e0ffcf><span class="${ssrRenderClass({ "font-semibold": item.level === 1 })}" data-v-03e0ffcf>#${ssrInterpolate(item.level)} ${ssrInterpolate(item.text)}</span></button></li>`);
        });
        _push(`<!--]--></ul></div></div>`);
      } else {
        _push(`<!---->`);
      }
      _push(`<div class="flex-1 flex flex-col" data-v-03e0ffcf>`);
      _push(ssrRenderComponent(_sfc_main$8, {
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
            _push2(`<button class="px-2 py-1 rounded bg-gray-200 hover:bg-gray-300" data-v-03e0ffcf${_scopeId}>${ssrInterpolate(showPreview.value ? "Editor Only" : "Split")}</button>`);
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
            _push2(`<input${ssrRenderAttr("value", saveMessage.value)} placeholder="commit message" class="px-2 py-1 text-xs border rounded w-48 focus:outline-none focus:ring" data-v-03e0ffcf${_scopeId}><button class="px-2 py-1 rounded bg-gray-200 hover:bg-gray-300" data-v-03e0ffcf${_scopeId}>Outline</button><button class="px-2 py-1 rounded bg-gray-200 hover:bg-gray-300" data-v-03e0ffcf${_scopeId}>Versions</button><button class="px-2 py-1 rounded bg-gray-200 hover:bg-gray-300"${ssrIncludeBooleanAttr(!versions.value.length) ? " disabled" : ""} data-v-03e0ffcf${_scopeId}>Diff</button><button class="px-2 py-1 rounded bg-gray-200 hover:bg-gray-300"${ssrIncludeBooleanAttr(outlineLoading.value) ? " disabled" : ""} data-v-03e0ffcf${_scopeId}>Refresh Outline</button>`);
            if (saving.value) {
              _push2(`<span class="text-gray-500 text-xs" data-v-03e0ffcf${_scopeId}>Saving...</span>`);
            } else {
              _push2(`<!---->`);
            }
            if (lastSaved.value) {
              _push2(`<span class="text-gray-400 text-xs" data-v-03e0ffcf${_scopeId}>v${ssrInterpolate(lastVersion.value)} @ ${ssrInterpolate(lastSaved.value)}</span>`);
            } else {
              _push2(`<!---->`);
            }
            _push2(`<div class="flex-1" data-v-03e0ffcf${_scopeId}></div><div class="flex items-center gap-1" data-v-03e0ffcf${_scopeId}><button class="px-2 py-1 rounded bg-gray-200 hover:bg-gray-300" data-v-03e0ffcf${_scopeId}>Table</button><button class="px-2 py-1 rounded bg-gray-200 hover:bg-gray-300" data-v-03e0ffcf${_scopeId}>Mermaid</button><button class="px-2 py-1 rounded bg-gray-200 hover:bg-gray-300" data-v-03e0ffcf${_scopeId}>Chart</button><button class="px-2 py-1 rounded bg-gray-200 hover:bg-gray-300" data-v-03e0ffcf${_scopeId}>Image</button><button class="px-2 py-1 rounded bg-indigo-50 hover:bg-indigo-100 text-indigo-700" data-v-03e0ffcf${_scopeId}>AI</button><button class="px-2 py-1 rounded bg-gray-200 hover:bg-gray-300" data-v-03e0ffcf${_scopeId}>Draw</button></div>`);
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
      _push(`<div class="flex flex-1 min-h-0" data-v-03e0ffcf>`);
      if (conflictActive.value) {
        _push(`<div class="absolute inset-0 z-20 flex" data-v-03e0ffcf><div class="w-96 h-full border-r bg-white flex flex-col shadow-xl" data-v-03e0ffcf><div class="p-3 border-b bg-amber-50 flex items-center gap-2 text-xs font-semibold text-amber-700" data-v-03e0ffcf> Conflict Detected <span class="ml-auto text-[10px] text-amber-600" data-v-03e0ffcf>local vs upstream v${ssrInterpolate(conflictLatestVersion.value)}</span></div><div class="p-3 flex-1 overflow-auto text-xs space-y-3" data-v-03e0ffcf><div class="space-y-1" data-v-03e0ffcf><div class="font-semibold text-gray-700" data-v-03e0ffcf>Stats</div><ul class="list-disc ml-4 text-gray-600" data-v-03e0ffcf><li data-v-03e0ffcf>Local changed lines: ${ssrInterpolate(conflictStats.value.changedLocal)}</li><li data-v-03e0ffcf>Upstream changed lines: ${ssrInterpolate(conflictStats.value.changedUpstream)}</li><li data-v-03e0ffcf>Potential conflicts: ${ssrInterpolate(conflictStats.value.conflicts)}</li></ul></div><div data-v-03e0ffcf><div class="font-semibold text-gray-700 mb-1" data-v-03e0ffcf>Preview (first 40 lines diff)</div><pre class="bg-gray-900 text-gray-100 p-2 rounded max-h-60 overflow-auto text-[11px] leading-snug" data-v-03e0ffcf><!--[-->`);
        ssrRenderList(conflictPreview.value, (l, i) => {
          _push(`<span class="${ssrRenderClass(diffClass(l))}" data-v-03e0ffcf>${ssrInterpolate(l)}
</span>`);
        });
        _push(`<!--]--></pre></div><div class="space-y-2" data-v-03e0ffcf><button class="w-full px-2 py-1 text-xs rounded bg-indigo-600 text-white hover:bg-indigo-500" data-v-03e0ffcf>Auto Merge (Trivial)</button><button class="w-full px-2 py-1 text-xs rounded bg-red-600 text-white hover:bg-red-500" data-v-03e0ffcf>Overwrite With Mine</button><button class="w-full px-2 py-1 text-xs rounded bg-blue-600 text-white hover:bg-blue-500" data-v-03e0ffcf>Accept Upstream</button><button class="w-full px-2 py-1 text-xs rounded bg-gray-200 hover:bg-gray-300 text-gray-700" data-v-03e0ffcf>Dismiss</button></div>`);
        if (mergeResultMsg.value) {
          _push(`<div class="text-[10px] text-indigo-700 whitespace-pre-line border border-indigo-200 bg-indigo-50 px-2 py-1 rounded" data-v-03e0ffcf>${ssrInterpolate(mergeResultMsg.value)}</div>`);
        } else {
          _push(`<!---->`);
        }
        _push(`<p class="text-[10px] text-gray-500 leading-relaxed" data-v-03e0ffcf>\uC790\uB3D9 \uBCD1\uD569\uC740 \uC904 \uBC30\uC5F4\uC774 \uB3D9\uC77C\uD560 \uB54C\uB9CC \uC218\uD589\uD569\uB2C8\uB2E4. \uCDA9\uB3CC \uB9C8\uCEE4(&lt;&lt;&lt;&lt;&lt;&lt;&lt; &gt;&gt;&gt;&gt;&gt;&gt;&gt;)\uAC00 \uB0A8\uC544 \uC788\uB2E4\uBA74 \uC218\uB3D9 \uD3B8\uC9D1 \uD6C4 \uB2E4\uC2DC \uC800\uC7A5\uD558\uC138\uC694.</p></div></div><div class="flex-1 h-full relative bg-white/70 backdrop-blur-sm" data-v-03e0ffcf></div></div>`);
      } else {
        _push(`<!---->`);
      }
      _push(`<div class="flex-1 flex flex-col" data-v-03e0ffcf><textarea class="flex-1 font-mono text-sm p-3 outline-none resize-none" data-v-03e0ffcf>${ssrInterpolate(draft.value)}</textarea></div>`);
      if (showPreview.value && !showDiff.value) {
        _push(`<div class="flex-1 flex min-h-0 overflow-hidden" data-v-03e0ffcf><div class="flex-1 min-h-0 border-l overflow-auto p-4 prose max-w-none bg-white" data-v-03e0ffcf><div data-v-03e0ffcf>${(_a = rendered.value) != null ? _a : ""}</div></div></div>`);
      } else {
        _push(`<!---->`);
      }
      if (showDiff.value) {
        _push(`<div class="flex-1 border-l bg-white" data-v-03e0ffcf>`);
        if (versions.value.length) {
          _push(ssrRenderComponent(_sfc_main$9, {
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
        _push(`<div class="absolute inset-0 z-30 bg-black/40 flex items-center justify-center" data-v-03e0ffcf><div class="w-[900px] h-[600px] bg-white rounded shadow flex flex-col" data-v-03e0ffcf><div class="p-2 border-b text-sm flex items-center" data-v-03e0ffcf>Sketch <div class="flex-1" data-v-03e0ffcf></div><button class="px-2 py-1 text-xs border rounded mr-2" data-v-03e0ffcf>Export &amp; Insert</button><button class="px-2 py-1 text-xs border rounded" data-v-03e0ffcf>Close</button></div><iframe src="https://excalidraw.com" class="flex-1" data-v-03e0ffcf></iframe></div></div>`);
      } else {
        _push(`<!---->`);
      }
      if (showTableModal.value) {
        _push(`<div class="absolute inset-0 z-30 bg-black/40 flex items-center justify-center" data-v-03e0ffcf><div class="w-[420px] bg-white rounded shadow flex flex-col" data-v-03e0ffcf><div class="p-2 border-b text-sm flex items-center" data-v-03e0ffcf>Insert Table<div class="flex-1" data-v-03e0ffcf></div><button class="px-2 py-1 text-xs border rounded" data-v-03e0ffcf>Close</button></div><div class="p-3 space-y-2 text-sm" data-v-03e0ffcf><div class="flex items-center gap-2" data-v-03e0ffcf><label class="w-24" data-v-03e0ffcf>Rows</label><input${ssrRenderAttr("value", tableRows.value)} type="number" min="1" max="50" class="border rounded px-2 py-1 w-24" data-v-03e0ffcf><label class="w-24" data-v-03e0ffcf>Cols</label><input${ssrRenderAttr("value", tableCols.value)} type="number" min="1" max="20" class="border rounded px-2 py-1 w-24" data-v-03e0ffcf></div><label class="inline-flex items-center gap-2" data-v-03e0ffcf><input type="checkbox"${ssrIncludeBooleanAttr(Array.isArray(tableHeader.value) ? ssrLooseContain(tableHeader.value, null) : tableHeader.value) ? " checked" : ""} data-v-03e0ffcf><span data-v-03e0ffcf>With header</span></label><div class="text-[11px] text-gray-500" data-v-03e0ffcf>A markdown table will be inserted at the cursor.</div><div class="pt-2 flex items-center justify-end" data-v-03e0ffcf><button class="px-2 py-1 text-xs rounded bg-indigo-600 text-white" data-v-03e0ffcf>Insert</button></div></div></div></div>`);
      } else {
        _push(`<!---->`);
      }
      if (showMermaidModal.value) {
        _push(`<div class="absolute inset-0 z-30 bg-black/40 flex items-center justify-center" data-v-03e0ffcf><div class="w-[900px] h-[600px] bg-white rounded shadow flex flex-col" data-v-03e0ffcf><div class="p-2 border-b text-sm flex items-center" data-v-03e0ffcf>Insert Mermaid Diagram<div class="flex-1" data-v-03e0ffcf></div><button class="px-2 py-1 text-xs border rounded mr-2" data-v-03e0ffcf>Close</button><button class="px-2 py-1 text-xs rounded bg-indigo-600 text-white" data-v-03e0ffcf>Insert</button></div><div class="flex-1 grid grid-cols-2 min-h-0" data-v-03e0ffcf><div class="p-3 space-y-2 border-r min-h-0 flex flex-col" data-v-03e0ffcf><div class="flex items-center gap-2 text-sm" data-v-03e0ffcf><label class="w-24" data-v-03e0ffcf>Type</label><select class="border rounded px-2 py-1" data-v-03e0ffcf><option value="flow" data-v-03e0ffcf${ssrIncludeBooleanAttr(Array.isArray(mermaidType.value) ? ssrLooseContain(mermaidType.value, "flow") : ssrLooseEqual(mermaidType.value, "flow")) ? " selected" : ""}>flow</option><option value="sequence" data-v-03e0ffcf${ssrIncludeBooleanAttr(Array.isArray(mermaidType.value) ? ssrLooseContain(mermaidType.value, "sequence") : ssrLooseEqual(mermaidType.value, "sequence")) ? " selected" : ""}>sequence</option><option value="gantt" data-v-03e0ffcf${ssrIncludeBooleanAttr(Array.isArray(mermaidType.value) ? ssrLooseContain(mermaidType.value, "gantt") : ssrLooseEqual(mermaidType.value, "gantt")) ? " selected" : ""}>gantt</option></select></div><textarea class="flex-1 font-mono text-xs p-2 border rounded resize-none" placeholder="Mermaid code" data-v-03e0ffcf>${ssrInterpolate(mermaidCode.value)}</textarea></div><div class="p-3 min-h-0 overflow-auto" data-v-03e0ffcf><div data-v-03e0ffcf></div></div></div></div></div>`);
      } else {
        _push(`<!---->`);
      }
      if (showChartModal.value) {
        _push(`<div class="absolute inset-0 z-30 bg-black/40 flex items-center justify-center" data-v-03e0ffcf><div class="w-[1000px] h-[650px] bg-white rounded shadow flex flex-col" data-v-03e0ffcf><div class="p-2 border-b text-sm flex items-center" data-v-03e0ffcf>Insert Chart (Vega-Lite)<div class="flex-1" data-v-03e0ffcf></div><button class="px-2 py-1 text-xs border rounded mr-2" data-v-03e0ffcf>Close</button><button class="px-2 py-1 text-xs rounded bg-indigo-600 text-white" data-v-03e0ffcf>Insert</button></div><div class="flex-1 grid grid-cols-2 min-h-0" data-v-03e0ffcf><div class="p-3 space-y-2 border-r min-h-0 flex flex-col" data-v-03e0ffcf><div class="text-xs text-gray-600" data-v-03e0ffcf>Paste or edit a Vega-Lite spec JSON. A preview will render on the right.</div><textarea class="flex-1 font-mono text-xs p-2 border rounded resize-none"${ssrRenderAttr("placeholder", chartPlaceholder)} data-v-03e0ffcf>${ssrInterpolate(chartSpec.value)}</textarea></div><div class="p-3 min-h-0 overflow-auto" data-v-03e0ffcf><div data-v-03e0ffcf></div></div></div></div></div>`);
      } else {
        _push(`<!---->`);
      }
      if (showImageModal.value) {
        _push(`<div class="absolute inset-0 z-30 bg-black/40 flex items-center justify-center" data-v-03e0ffcf><div class="w-[520px] bg-white rounded shadow flex flex-col" data-v-03e0ffcf><div class="p-2 border-b text-sm flex items-center" data-v-03e0ffcf>Insert Image<div class="flex-1" data-v-03e0ffcf></div><button class="px-2 py-1 text-xs border rounded mr-2" data-v-03e0ffcf>Close</button><button class="px-2 py-1 text-xs rounded bg-indigo-600 text-white" data-v-03e0ffcf>Insert</button></div><div class="p-3 space-y-3 text-sm" data-v-03e0ffcf><div class="space-y-1" data-v-03e0ffcf><label data-v-03e0ffcf>Image URL</label><input${ssrRenderAttr("value", imageUrl.value)} type="text" placeholder="https://... or /assets/..." class="w-full border rounded px-2 py-1" data-v-03e0ffcf><div class="text-[11px] text-gray-500" data-v-03e0ffcf>Or upload a file below to get a URL.</div><input type="file" accept="image/*" data-v-03e0ffcf></div><div class="flex items-center gap-2" data-v-03e0ffcf><label class="w-20" data-v-03e0ffcf>Alt</label><input${ssrRenderAttr("value", imageAlt.value)} type="text" class="flex-1 border rounded px-2 py-1" data-v-03e0ffcf></div><div class="flex items-center gap-2" data-v-03e0ffcf><label class="w-20" data-v-03e0ffcf>Title</label><input${ssrRenderAttr("value", imageTitle.value)} type="text" class="flex-1 border rounded px-2 py-1" data-v-03e0ffcf></div><div class="flex items-center gap-2" data-v-03e0ffcf><label class="w-20" data-v-03e0ffcf>Width</label><input${ssrRenderAttr("value", imageWidth.value)} type="number" min="1" max="4000" placeholder="optional" class="border rounded px-2 py-1 w-32" data-v-03e0ffcf><span class="text-[11px] text-gray-500" data-v-03e0ffcf>px (optional)</span></div></div></div></div>`);
      } else {
        _push(`<!---->`);
      }
      _push(`</div></div>`);
    };
  }
};
const _sfc_setup$6 = _sfc_main$6.setup;
_sfc_main$6.setup = (props, ctx) => {
  const ssrContext = useSSRContext();
  (ssrContext.modules || (ssrContext.modules = /* @__PURE__ */ new Set())).add("components/SplitEditor.vue");
  return _sfc_setup$6 ? _sfc_setup$6(props, ctx) : void 0;
};
const SplitEditor = /* @__PURE__ */ _export_sfc(_sfc_main$6, [["__scopeId", "data-v-03e0ffcf"]]);
const _sfc_main$5 = {
  __name: "WorkspaceView",
  __ssrInlineRender: true,
  props: {
    activeContent: String,
    activeSlide: Object,
    activePath: String,
    readonly: { type: Boolean, default: false }
  },
  setup(__props) {
    defineAsyncComponent(() => Promise.resolve().then(() => TipTapKbEditor_client));
    const props = __props;
    const activeComponent = shallowRef(_sfc_main$h);
    computed(() => {
      if (activeComponent.value === _sfc_main$h) {
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
        activeComponent.value = _sfc_main$h;
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
const _sfc_setup$5 = _sfc_main$5.setup;
_sfc_main$5.setup = (props, ctx) => {
  const ssrContext = useSSRContext();
  (ssrContext.modules || (ssrContext.modules = /* @__PURE__ */ new Set())).add("components/WorkspaceView.vue");
  return _sfc_setup$5 ? _sfc_setup$5(props, ctx) : void 0;
};
const _sfc_main$4 = {
  __name: "AIAssistantPanel",
  __ssrInlineRender: true,
  setup(__props) {
    resolveApiBase();
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
const _sfc_setup$4 = _sfc_main$4.setup;
_sfc_main$4.setup = (props, ctx) => {
  const ssrContext = useSSRContext();
  (ssrContext.modules || (ssrContext.modules = /* @__PURE__ */ new Set())).add("components/AIAssistantPanel.vue");
  return _sfc_setup$4 ? _sfc_setup$4(props, ctx) : void 0;
};
function createChainableState(config) {
  const { state, transaction } = config;
  let { selection } = transaction;
  let { doc } = transaction;
  let { storedMarks } = transaction;
  return {
    ...state,
    apply: state.apply.bind(state),
    applyTransaction: state.applyTransaction.bind(state),
    plugins: state.plugins,
    schema: state.schema,
    reconfigure: state.reconfigure.bind(state),
    toJSON: state.toJSON.bind(state),
    get storedMarks() {
      return storedMarks;
    },
    get selection() {
      return selection;
    },
    get doc() {
      return doc;
    },
    get tr() {
      selection = transaction.selection;
      doc = transaction.doc;
      storedMarks = transaction.storedMarks;
      return transaction;
    }
  };
}
class CommandManager {
  constructor(props) {
    this.editor = props.editor;
    this.rawCommands = this.editor.extensionManager.commands;
    this.customState = props.state;
  }
  get hasCustomState() {
    return !!this.customState;
  }
  get state() {
    return this.customState || this.editor.state;
  }
  get commands() {
    const { rawCommands, editor, state } = this;
    const { view } = editor;
    const { tr } = state;
    const props = this.buildProps(tr);
    return Object.fromEntries(Object.entries(rawCommands).map(([name, command2]) => {
      const method = (...args) => {
        const callback = command2(...args)(props);
        if (!tr.getMeta("preventDispatch") && !this.hasCustomState) {
          view.dispatch(tr);
        }
        return callback;
      };
      return [name, method];
    }));
  }
  get chain() {
    return () => this.createChain();
  }
  get can() {
    return () => this.createCan();
  }
  createChain(startTr, shouldDispatch = true) {
    const { rawCommands, editor, state } = this;
    const { view } = editor;
    const callbacks = [];
    const hasStartTransaction = !!startTr;
    const tr = startTr || state.tr;
    const run2 = () => {
      if (!hasStartTransaction && shouldDispatch && !tr.getMeta("preventDispatch") && !this.hasCustomState) {
        view.dispatch(tr);
      }
      return callbacks.every((callback) => callback === true);
    };
    const chain = {
      ...Object.fromEntries(Object.entries(rawCommands).map(([name, command2]) => {
        const chainedCommand = (...args) => {
          const props = this.buildProps(tr, shouldDispatch);
          const callback = command2(...args)(props);
          callbacks.push(callback);
          return chain;
        };
        return [name, chainedCommand];
      })),
      run: run2
    };
    return chain;
  }
  createCan(startTr) {
    const { rawCommands, state } = this;
    const dispatch = false;
    const tr = startTr || state.tr;
    const props = this.buildProps(tr, dispatch);
    const formattedCommands = Object.fromEntries(Object.entries(rawCommands).map(([name, command2]) => {
      return [name, (...args) => command2(...args)({ ...props, dispatch: void 0 })];
    }));
    return {
      ...formattedCommands,
      chain: () => this.createChain(tr, dispatch)
    };
  }
  buildProps(tr, shouldDispatch = true) {
    const { rawCommands, editor, state } = this;
    const { view } = editor;
    const props = {
      tr,
      editor,
      view,
      state: createChainableState({
        state,
        transaction: tr
      }),
      dispatch: shouldDispatch ? () => void 0 : void 0,
      chain: () => this.createChain(tr, shouldDispatch),
      can: () => this.createCan(tr),
      get commands() {
        return Object.fromEntries(Object.entries(rawCommands).map(([name, command2]) => {
          return [name, (...args) => command2(...args)(props)];
        }));
      }
    };
    return props;
  }
}
function getExtensionField(extension, field, context) {
  if (extension.config[field] === void 0 && extension.parent) {
    return getExtensionField(extension.parent, field, context);
  }
  if (typeof extension.config[field] === "function") {
    const value = extension.config[field].bind({
      ...context,
      parent: extension.parent ? getExtensionField(extension.parent, field, context) : null
    });
    return value;
  }
  return extension.config[field];
}
function splitExtensions(extensions) {
  const baseExtensions = extensions.filter((extension) => extension.type === "extension");
  const nodeExtensions = extensions.filter((extension) => extension.type === "node");
  const markExtensions = extensions.filter((extension) => extension.type === "mark");
  return {
    baseExtensions,
    nodeExtensions,
    markExtensions
  };
}
function getNodeType(nameOrType, schema) {
  if (typeof nameOrType === "string") {
    if (!schema.nodes[nameOrType]) {
      throw Error(`There is no node type named '${nameOrType}'. Maybe you forgot to add the extension?`);
    }
    return schema.nodes[nameOrType];
  }
  return nameOrType;
}
function mergeAttributes(...objects) {
  return objects.filter((item) => !!item).reduce((items, item) => {
    const mergedAttributes = { ...items };
    Object.entries(item).forEach(([key, value]) => {
      const exists = mergedAttributes[key];
      if (!exists) {
        mergedAttributes[key] = value;
        return;
      }
      if (key === "class") {
        const valueClasses = value ? String(value).split(" ") : [];
        const existingClasses = mergedAttributes[key] ? mergedAttributes[key].split(" ") : [];
        const insertClasses = valueClasses.filter((valueClass) => !existingClasses.includes(valueClass));
        mergedAttributes[key] = [...existingClasses, ...insertClasses].join(" ");
      } else if (key === "style") {
        const newStyles = value ? value.split(";").map((style2) => style2.trim()).filter(Boolean) : [];
        const existingStyles = mergedAttributes[key] ? mergedAttributes[key].split(";").map((style2) => style2.trim()).filter(Boolean) : [];
        const styleMap = /* @__PURE__ */ new Map();
        existingStyles.forEach((style2) => {
          const [property, val] = style2.split(":").map((part) => part.trim());
          styleMap.set(property, val);
        });
        newStyles.forEach((style2) => {
          const [property, val] = style2.split(":").map((part) => part.trim());
          styleMap.set(property, val);
        });
        mergedAttributes[key] = Array.from(styleMap.entries()).map(([property, val]) => `${property}: ${val}`).join("; ");
      } else {
        mergedAttributes[key] = value;
      }
    });
    return mergedAttributes;
  }, {});
}
function isFunction$1(value) {
  return typeof value === "function";
}
function callOrReturn(value, context = void 0, ...props) {
  if (isFunction$1(value)) {
    if (context) {
      return value.bind(context)(...props);
    }
    return value(...props);
  }
  return value;
}
function isRegExp(value) {
  return Object.prototype.toString.call(value) === "[object RegExp]";
}
class InputRule {
  constructor(config) {
    this.find = config.find;
    this.handler = config.handler;
  }
}
function getType(value) {
  return Object.prototype.toString.call(value).slice(8, -1);
}
function isPlainObject(value) {
  if (getType(value) !== "Object") {
    return false;
  }
  return value.constructor === Object && Object.getPrototypeOf(value) === Object.prototype;
}
function mergeDeep(target, source2) {
  const output = { ...target };
  if (isPlainObject(target) && isPlainObject(source2)) {
    Object.keys(source2).forEach((key) => {
      if (isPlainObject(source2[key]) && isPlainObject(target[key])) {
        output[key] = mergeDeep(target[key], source2[key]);
      } else {
        output[key] = source2[key];
      }
    });
  }
  return output;
}
class Mark {
  constructor(config = {}) {
    this.type = "mark";
    this.name = "mark";
    this.parent = null;
    this.child = null;
    this.config = {
      name: this.name,
      defaultOptions: {}
    };
    this.config = {
      ...this.config,
      ...config
    };
    this.name = this.config.name;
    if (config.defaultOptions && Object.keys(config.defaultOptions).length > 0) {
      console.warn(`[tiptap warn]: BREAKING CHANGE: "defaultOptions" is deprecated. Please use "addOptions" instead. Found in extension: "${this.name}".`);
    }
    this.options = this.config.defaultOptions;
    if (this.config.addOptions) {
      this.options = callOrReturn(getExtensionField(this, "addOptions", {
        name: this.name
      }));
    }
    this.storage = callOrReturn(getExtensionField(this, "addStorage", {
      name: this.name,
      options: this.options
    })) || {};
  }
  static create(config = {}) {
    return new Mark(config);
  }
  configure(options = {}) {
    const extension = this.extend({
      ...this.config,
      addOptions: () => {
        return mergeDeep(this.options, options);
      }
    });
    extension.name = this.name;
    extension.parent = this.parent;
    return extension;
  }
  extend(extendedConfig = {}) {
    const extension = new Mark(extendedConfig);
    extension.parent = this;
    this.child = extension;
    extension.name = extendedConfig.name ? extendedConfig.name : extension.parent.name;
    if (extendedConfig.defaultOptions && Object.keys(extendedConfig.defaultOptions).length > 0) {
      console.warn(`[tiptap warn]: BREAKING CHANGE: "defaultOptions" is deprecated. Please use "addOptions" instead. Found in extension: "${extension.name}".`);
    }
    extension.options = callOrReturn(getExtensionField(extension, "addOptions", {
      name: extension.name
    }));
    extension.storage = callOrReturn(getExtensionField(extension, "addStorage", {
      name: extension.name,
      options: extension.options
    }));
    return extension;
  }
  static handleExit({ editor, mark }) {
    const { tr } = editor.state;
    const currentPos = editor.state.selection.$from;
    const isAtEnd = currentPos.pos === currentPos.end();
    if (isAtEnd) {
      const currentMarks = currentPos.marks();
      const isInMark = !!currentMarks.find((m) => (m === null || m === void 0 ? void 0 : m.type.name) === mark.name);
      if (!isInMark) {
        return false;
      }
      const removeMark = currentMarks.find((m) => (m === null || m === void 0 ? void 0 : m.type.name) === mark.name);
      if (removeMark) {
        tr.removeStoredMark(removeMark);
      }
      tr.insertText(" ", currentPos.pos);
      editor.view.dispatch(tr);
      return true;
    }
    return false;
  }
}
class PasteRule {
  constructor(config) {
    this.find = config.find;
    this.handler = config.handler;
  }
}
class Extension {
  constructor(config = {}) {
    this.type = "extension";
    this.name = "extension";
    this.parent = null;
    this.child = null;
    this.config = {
      name: this.name,
      defaultOptions: {}
    };
    this.config = {
      ...this.config,
      ...config
    };
    this.name = this.config.name;
    if (config.defaultOptions && Object.keys(config.defaultOptions).length > 0) {
      console.warn(`[tiptap warn]: BREAKING CHANGE: "defaultOptions" is deprecated. Please use "addOptions" instead. Found in extension: "${this.name}".`);
    }
    this.options = this.config.defaultOptions;
    if (this.config.addOptions) {
      this.options = callOrReturn(getExtensionField(this, "addOptions", {
        name: this.name
      }));
    }
    this.storage = callOrReturn(getExtensionField(this, "addStorage", {
      name: this.name,
      options: this.options
    })) || {};
  }
  static create(config = {}) {
    return new Extension(config);
  }
  configure(options = {}) {
    const extension = this.extend({
      ...this.config,
      addOptions: () => {
        return mergeDeep(this.options, options);
      }
    });
    extension.name = this.name;
    extension.parent = this.parent;
    return extension;
  }
  extend(extendedConfig = {}) {
    const extension = new Extension({ ...this.config, ...extendedConfig });
    extension.parent = this;
    this.child = extension;
    extension.name = extendedConfig.name ? extendedConfig.name : extension.parent.name;
    if (extendedConfig.defaultOptions && Object.keys(extendedConfig.defaultOptions).length > 0) {
      console.warn(`[tiptap warn]: BREAKING CHANGE: "defaultOptions" is deprecated. Please use "addOptions" instead. Found in extension: "${extension.name}".`);
    }
    extension.options = callOrReturn(getExtensionField(extension, "addOptions", {
      name: extension.name
    }));
    extension.storage = callOrReturn(getExtensionField(extension, "addStorage", {
      name: extension.name,
      options: extension.options
    }));
    return extension;
  }
}
function getTextBetween(startNode, range, options) {
  const { from, to } = range;
  const { blockSeparator = "\n\n", textSerializers = {} } = options || {};
  let text = "";
  startNode.nodesBetween(from, to, (node, pos, parent, index2) => {
    var _a;
    if (node.isBlock && pos > from) {
      text += blockSeparator;
    }
    const textSerializer = textSerializers === null || textSerializers === void 0 ? void 0 : textSerializers[node.type.name];
    if (textSerializer) {
      if (parent) {
        text += textSerializer({
          node,
          pos,
          parent,
          index: index2,
          range
        });
      }
      return false;
    }
    if (node.isText) {
      text += (_a = node === null || node === void 0 ? void 0 : node.text) === null || _a === void 0 ? void 0 : _a.slice(Math.max(from, pos) - pos, to - pos);
    }
  });
  return text;
}
function getTextSerializersFromSchema(schema) {
  return Object.fromEntries(Object.entries(schema.nodes).filter(([, node]) => node.spec.toText).map(([name, node]) => [name, node.spec.toText]));
}
Extension.create({
  name: "clipboardTextSerializer",
  addOptions() {
    return {
      blockSeparator: void 0
    };
  },
  addProseMirrorPlugins() {
    return [
      new Plugin({
        key: new PluginKey("clipboardTextSerializer"),
        props: {
          clipboardTextSerializer: () => {
            const { editor } = this;
            const { state, schema } = editor;
            const { doc, selection } = state;
            const { ranges } = selection;
            const from = Math.min(...ranges.map((range2) => range2.$from.pos));
            const to = Math.max(...ranges.map((range2) => range2.$to.pos));
            const textSerializers = getTextSerializersFromSchema(schema);
            const range = { from, to };
            return getTextBetween(doc, range, {
              ...this.options.blockSeparator !== void 0 ? { blockSeparator: this.options.blockSeparator } : {},
              textSerializers
            });
          }
        }
      })
    ];
  }
});
const blur = () => ({ editor, view }) => {
  requestAnimationFrame(() => {
    var _a;
    if (!editor.isDestroyed) {
      view.dom.blur();
      (_a = void 0) === null || _a === void 0 ? void 0 : _a.removeAllRanges();
    }
  });
  return true;
};
const clearContent = (emitUpdate = false) => ({ commands: commands2 }) => {
  return commands2.setContent("", emitUpdate);
};
const clearNodes = () => ({ state, tr, dispatch }) => {
  const { selection } = tr;
  const { ranges } = selection;
  if (!dispatch) {
    return true;
  }
  ranges.forEach(({ $from, $to }) => {
    state.doc.nodesBetween($from.pos, $to.pos, (node, pos) => {
      if (node.type.isText) {
        return;
      }
      const { doc, mapping } = tr;
      const $mappedFrom = doc.resolve(mapping.map(pos));
      const $mappedTo = doc.resolve(mapping.map(pos + node.nodeSize));
      const nodeRange = $mappedFrom.blockRange($mappedTo);
      if (!nodeRange) {
        return;
      }
      const targetLiftDepth = liftTarget(nodeRange);
      if (node.type.isTextblock) {
        const { defaultType } = $mappedFrom.parent.contentMatchAt($mappedFrom.index());
        tr.setNodeMarkup(nodeRange.start, defaultType);
      }
      if (targetLiftDepth || targetLiftDepth === 0) {
        tr.lift(nodeRange, targetLiftDepth);
      }
    });
  });
  return true;
};
const command = (fn) => (props) => {
  return fn(props);
};
const createParagraphNear = () => ({ state, dispatch }) => {
  return createParagraphNear$1(state, dispatch);
};
const cut = (originRange, targetPos) => ({ editor, tr }) => {
  const { state } = editor;
  const contentSlice = state.doc.slice(originRange.from, originRange.to);
  tr.deleteRange(originRange.from, originRange.to);
  const newPos = tr.mapping.map(targetPos);
  tr.insert(newPos, contentSlice.content);
  tr.setSelection(new TextSelection(tr.doc.resolve(Math.max(newPos - 1, 0))));
  return true;
};
const deleteCurrentNode = () => ({ tr, dispatch }) => {
  const { selection } = tr;
  const currentNode = selection.$anchor.node();
  if (currentNode.content.size > 0) {
    return false;
  }
  const $pos = tr.selection.$anchor;
  for (let depth = $pos.depth; depth > 0; depth -= 1) {
    const node = $pos.node(depth);
    if (node.type === currentNode.type) {
      if (dispatch) {
        const from = $pos.before(depth);
        const to = $pos.after(depth);
        tr.delete(from, to).scrollIntoView();
      }
      return true;
    }
  }
  return false;
};
const deleteNode = (typeOrName) => ({ tr, state, dispatch }) => {
  const type = getNodeType(typeOrName, state.schema);
  const $pos = tr.selection.$anchor;
  for (let depth = $pos.depth; depth > 0; depth -= 1) {
    const node = $pos.node(depth);
    if (node.type === type) {
      if (dispatch) {
        const from = $pos.before(depth);
        const to = $pos.after(depth);
        tr.delete(from, to).scrollIntoView();
      }
      return true;
    }
  }
  return false;
};
const deleteRange = (range) => ({ tr, dispatch }) => {
  const { from, to } = range;
  if (dispatch) {
    tr.delete(from, to);
  }
  return true;
};
const deleteSelection = () => ({ state, dispatch }) => {
  return deleteSelection$1(state, dispatch);
};
const enter = () => ({ commands: commands2 }) => {
  return commands2.keyboardShortcut("Enter");
};
const exitCode = () => ({ state, dispatch }) => {
  return exitCode$1(state, dispatch);
};
function objectIncludes(object1, object2, options = { strict: true }) {
  const keys = Object.keys(object2);
  if (!keys.length) {
    return true;
  }
  return keys.every((key) => {
    if (options.strict) {
      return object2[key] === object1[key];
    }
    if (isRegExp(object2[key])) {
      return object2[key].test(object1[key]);
    }
    return object2[key] === object1[key];
  });
}
function findMarkInSet(marks, type, attributes = {}) {
  return marks.find((item) => {
    return item.type === type && objectIncludes(
      // Only check equality for the attributes that are provided
      Object.fromEntries(Object.keys(attributes).map((k) => [k, item.attrs[k]])),
      attributes
    );
  });
}
function isMarkInSet(marks, type, attributes = {}) {
  return !!findMarkInSet(marks, type, attributes);
}
function getMarkRange($pos, type, attributes) {
  var _a;
  if (!$pos || !type) {
    return;
  }
  let start = $pos.parent.childAfter($pos.parentOffset);
  if (!start.node || !start.node.marks.some((mark2) => mark2.type === type)) {
    start = $pos.parent.childBefore($pos.parentOffset);
  }
  if (!start.node || !start.node.marks.some((mark2) => mark2.type === type)) {
    return;
  }
  attributes = attributes || ((_a = start.node.marks[0]) === null || _a === void 0 ? void 0 : _a.attrs);
  const mark = findMarkInSet([...start.node.marks], type, attributes);
  if (!mark) {
    return;
  }
  let startIndex = start.index;
  let startPos = $pos.start() + start.offset;
  let endIndex = startIndex + 1;
  let endPos = startPos + start.node.nodeSize;
  while (startIndex > 0 && isMarkInSet([...$pos.parent.child(startIndex - 1).marks], type, attributes)) {
    startIndex -= 1;
    startPos -= $pos.parent.child(startIndex).nodeSize;
  }
  while (endIndex < $pos.parent.childCount && isMarkInSet([...$pos.parent.child(endIndex).marks], type, attributes)) {
    endPos += $pos.parent.child(endIndex).nodeSize;
    endIndex += 1;
  }
  return {
    from: startPos,
    to: endPos
  };
}
function getMarkType(nameOrType, schema) {
  if (typeof nameOrType === "string") {
    if (!schema.marks[nameOrType]) {
      throw Error(`There is no mark type named '${nameOrType}'. Maybe you forgot to add the extension?`);
    }
    return schema.marks[nameOrType];
  }
  return nameOrType;
}
const extendMarkRange = (typeOrName, attributes = {}) => ({ tr, state, dispatch }) => {
  const type = getMarkType(typeOrName, state.schema);
  const { doc, selection } = tr;
  const { $from, from, to } = selection;
  if (dispatch) {
    const range = getMarkRange($from, type, attributes);
    if (range && range.from <= from && range.to >= to) {
      const newSelection = TextSelection.create(doc, range.from, range.to);
      tr.setSelection(newSelection);
    }
  }
  return true;
};
const first = (commands2) => (props) => {
  const items = typeof commands2 === "function" ? commands2(props) : commands2;
  for (let i = 0; i < items.length; i += 1) {
    if (items[i](props)) {
      return true;
    }
  }
  return false;
};
function isTextSelection(value) {
  return value instanceof TextSelection;
}
function minMax(value = 0, min = 0, max = 0) {
  return Math.min(Math.max(value, min), max);
}
function resolveFocusPosition(doc, position = null) {
  if (!position) {
    return null;
  }
  const selectionAtStart = Selection.atStart(doc);
  const selectionAtEnd = Selection.atEnd(doc);
  if (position === "start" || position === true) {
    return selectionAtStart;
  }
  if (position === "end") {
    return selectionAtEnd;
  }
  const minPos = selectionAtStart.from;
  const maxPos = selectionAtEnd.to;
  if (position === "all") {
    return TextSelection.create(doc, minMax(0, minPos, maxPos), minMax(doc.content.size, minPos, maxPos));
  }
  return TextSelection.create(doc, minMax(position, minPos, maxPos), minMax(position, minPos, maxPos));
}
function isAndroid() {
  return (void 0).platform === "Android" || /android/i.test((void 0).userAgent);
}
function isiOS() {
  return [
    "iPad Simulator",
    "iPhone Simulator",
    "iPod Simulator",
    "iPad",
    "iPhone",
    "iPod"
  ].includes((void 0).platform) || (void 0).userAgent.includes("Mac") && "ontouchend" in void 0;
}
const focus = (position = null, options = {}) => ({ editor, view, tr, dispatch }) => {
  options = {
    scrollIntoView: true,
    ...options
  };
  const delayedFocus = () => {
    if (isiOS() || isAndroid()) {
      view.dom.focus();
    }
    requestAnimationFrame(() => {
      if (!editor.isDestroyed) {
        view.focus();
        if (options === null || options === void 0 ? void 0 : options.scrollIntoView) {
          editor.commands.scrollIntoView();
        }
      }
    });
  };
  if (view.hasFocus() && position === null || position === false) {
    return true;
  }
  if (dispatch && position === null && !isTextSelection(editor.state.selection)) {
    delayedFocus();
    return true;
  }
  const selection = resolveFocusPosition(tr.doc, position) || editor.state.selection;
  const isSameSelection = editor.state.selection.eq(selection);
  if (dispatch) {
    if (!isSameSelection) {
      tr.setSelection(selection);
    }
    if (isSameSelection && tr.storedMarks) {
      tr.setStoredMarks(tr.storedMarks);
    }
    delayedFocus();
  }
  return true;
};
const forEach = (items, fn) => (props) => {
  return items.every((item, index2) => fn(item, { ...props, index: index2 }));
};
const insertContent = (value, options) => ({ tr, commands: commands2 }) => {
  return commands2.insertContentAt({ from: tr.selection.from, to: tr.selection.to }, value, options);
};
const removeWhitespaces = (node) => {
  const children = node.childNodes;
  for (let i = children.length - 1; i >= 0; i -= 1) {
    const child = children[i];
    if (child.nodeType === 3 && child.nodeValue && /^(\n\s\s|\n)$/.test(child.nodeValue)) {
      node.removeChild(child);
    } else if (child.nodeType === 1) {
      removeWhitespaces(child);
    }
  }
  return node;
};
function elementFromString(value) {
  const wrappedValue = `<body>${value}</body>`;
  const html = new (void 0).DOMParser().parseFromString(wrappedValue, "text/html").body;
  return removeWhitespaces(html);
}
function createNodeFromContent(content, schema, options) {
  if (content instanceof Node$1 || content instanceof Fragment$1) {
    return content;
  }
  options = {
    slice: true,
    parseOptions: {},
    ...options
  };
  const isJSONContent = typeof content === "object" && content !== null;
  const isTextContent = typeof content === "string";
  if (isJSONContent) {
    try {
      const isArrayContent = Array.isArray(content) && content.length > 0;
      if (isArrayContent) {
        return Fragment$1.fromArray(content.map((item) => schema.nodeFromJSON(item)));
      }
      const node = schema.nodeFromJSON(content);
      if (options.errorOnInvalidContent) {
        node.check();
      }
      return node;
    } catch (error2) {
      if (options.errorOnInvalidContent) {
        throw new Error("[tiptap error]: Invalid JSON content", { cause: error2 });
      }
      console.warn("[tiptap warn]: Invalid content.", "Passed value:", content, "Error:", error2);
      return createNodeFromContent("", schema, options);
    }
  }
  if (isTextContent) {
    if (options.errorOnInvalidContent) {
      let hasInvalidContent = false;
      let invalidContent = "";
      const contentCheckSchema = new Schema({
        topNode: schema.spec.topNode,
        marks: schema.spec.marks,
        // Prosemirror's schemas are executed such that: the last to execute, matches last
        // This means that we can add a catch-all node at the end of the schema to catch any content that we don't know how to handle
        nodes: schema.spec.nodes.append({
          __tiptap__private__unknown__catch__all__node: {
            content: "inline*",
            group: "block",
            parseDOM: [
              {
                tag: "*",
                getAttrs: (e) => {
                  hasInvalidContent = true;
                  invalidContent = typeof e === "string" ? e : e.outerHTML;
                  return null;
                }
              }
            ]
          }
        })
      });
      if (options.slice) {
        DOMParser.fromSchema(contentCheckSchema).parseSlice(elementFromString(content), options.parseOptions);
      } else {
        DOMParser.fromSchema(contentCheckSchema).parse(elementFromString(content), options.parseOptions);
      }
      if (options.errorOnInvalidContent && hasInvalidContent) {
        throw new Error("[tiptap error]: Invalid HTML content", { cause: new Error(`Invalid element found: ${invalidContent}`) });
      }
    }
    const parser = DOMParser.fromSchema(schema);
    if (options.slice) {
      return parser.parseSlice(elementFromString(content), options.parseOptions).content;
    }
    return parser.parse(elementFromString(content), options.parseOptions);
  }
  return createNodeFromContent("", schema, options);
}
function selectionToInsertionEnd(tr, startLen, bias) {
  const last = tr.steps.length - 1;
  if (last < startLen) {
    return;
  }
  const step = tr.steps[last];
  if (!(step instanceof ReplaceStep || step instanceof ReplaceAroundStep)) {
    return;
  }
  const map = tr.mapping.maps[last];
  let end = 0;
  map.forEach((_from, _to, _newFrom, newTo) => {
    if (end === 0) {
      end = newTo;
    }
  });
  tr.setSelection(Selection.near(tr.doc.resolve(end), bias));
}
const isFragment = (nodeOrFragment) => {
  return !("type" in nodeOrFragment);
};
const insertContentAt = (position, value, options) => ({ tr, dispatch, editor }) => {
  var _a;
  if (dispatch) {
    options = {
      parseOptions: editor.options.parseOptions,
      updateSelection: true,
      applyInputRules: false,
      applyPasteRules: false,
      ...options
    };
    let content;
    const emitContentError = (error2) => {
      editor.emit("contentError", {
        editor,
        error: error2,
        disableCollaboration: () => {
          if (editor.storage.collaboration) {
            editor.storage.collaboration.isDisabled = true;
          }
        }
      });
    };
    const parseOptions = {
      preserveWhitespace: "full",
      ...options.parseOptions
    };
    if (!options.errorOnInvalidContent && !editor.options.enableContentCheck && editor.options.emitContentError) {
      try {
        createNodeFromContent(value, editor.schema, {
          parseOptions,
          errorOnInvalidContent: true
        });
      } catch (e) {
        emitContentError(e);
      }
    }
    try {
      content = createNodeFromContent(value, editor.schema, {
        parseOptions,
        errorOnInvalidContent: (_a = options.errorOnInvalidContent) !== null && _a !== void 0 ? _a : editor.options.enableContentCheck
      });
    } catch (e) {
      emitContentError(e);
      return false;
    }
    let { from, to } = typeof position === "number" ? { from: position, to: position } : { from: position.from, to: position.to };
    let isOnlyTextContent = true;
    let isOnlyBlockContent = true;
    const nodes = isFragment(content) ? content : [content];
    nodes.forEach((node) => {
      node.check();
      isOnlyTextContent = isOnlyTextContent ? node.isText && node.marks.length === 0 : false;
      isOnlyBlockContent = isOnlyBlockContent ? node.isBlock : false;
    });
    if (from === to && isOnlyBlockContent) {
      const { parent } = tr.doc.resolve(from);
      const isEmptyTextBlock = parent.isTextblock && !parent.type.spec.code && !parent.childCount;
      if (isEmptyTextBlock) {
        from -= 1;
        to += 1;
      }
    }
    let newContent;
    if (isOnlyTextContent) {
      if (Array.isArray(value)) {
        newContent = value.map((v) => v.text || "").join("");
      } else if (value instanceof Fragment$1) {
        let text = "";
        value.forEach((node) => {
          if (node.text) {
            text += node.text;
          }
        });
        newContent = text;
      } else if (typeof value === "object" && !!value && !!value.text) {
        newContent = value.text;
      } else {
        newContent = value;
      }
      tr.insertText(newContent, from, to);
    } else {
      newContent = content;
      tr.replaceWith(from, to, newContent);
    }
    if (options.updateSelection) {
      selectionToInsertionEnd(tr, tr.steps.length - 1, -1);
    }
    if (options.applyInputRules) {
      tr.setMeta("applyInputRules", { from, text: newContent });
    }
    if (options.applyPasteRules) {
      tr.setMeta("applyPasteRules", { from, text: newContent });
    }
  }
  return true;
};
const joinUp = () => ({ state, dispatch }) => {
  return joinUp$1(state, dispatch);
};
const joinDown = () => ({ state, dispatch }) => {
  return joinDown$1(state, dispatch);
};
const joinBackward = () => ({ state, dispatch }) => {
  return joinBackward$1(state, dispatch);
};
const joinForward = () => ({ state, dispatch }) => {
  return joinForward$1(state, dispatch);
};
const joinItemBackward = () => ({ state, dispatch, tr }) => {
  try {
    const point = joinPoint(state.doc, state.selection.$from.pos, -1);
    if (point === null || point === void 0) {
      return false;
    }
    tr.join(point, 2);
    if (dispatch) {
      dispatch(tr);
    }
    return true;
  } catch {
    return false;
  }
};
const joinItemForward = () => ({ state, dispatch, tr }) => {
  try {
    const point = joinPoint(state.doc, state.selection.$from.pos, 1);
    if (point === null || point === void 0) {
      return false;
    }
    tr.join(point, 2);
    if (dispatch) {
      dispatch(tr);
    }
    return true;
  } catch {
    return false;
  }
};
const joinTextblockBackward = () => ({ state, dispatch }) => {
  return joinTextblockBackward$1(state, dispatch);
};
const joinTextblockForward = () => ({ state, dispatch }) => {
  return joinTextblockForward$1(state, dispatch);
};
function isMacOS() {
  return false;
}
function normalizeKeyName(name) {
  const parts = name.split(/-(?!$)/);
  let result = parts[parts.length - 1];
  if (result === "Space") {
    result = " ";
  }
  let alt;
  let ctrl;
  let shift;
  let meta;
  for (let i = 0; i < parts.length - 1; i += 1) {
    const mod = parts[i];
    if (/^(cmd|meta|m)$/i.test(mod)) {
      meta = true;
    } else if (/^a(lt)?$/i.test(mod)) {
      alt = true;
    } else if (/^(c|ctrl|control)$/i.test(mod)) {
      ctrl = true;
    } else if (/^s(hift)?$/i.test(mod)) {
      shift = true;
    } else if (/^mod$/i.test(mod)) {
      if (isiOS() || isMacOS()) {
        meta = true;
      } else {
        ctrl = true;
      }
    } else {
      throw new Error(`Unrecognized modifier name: ${mod}`);
    }
  }
  if (alt) {
    result = `Alt-${result}`;
  }
  if (ctrl) {
    result = `Ctrl-${result}`;
  }
  if (meta) {
    result = `Meta-${result}`;
  }
  if (shift) {
    result = `Shift-${result}`;
  }
  return result;
}
const keyboardShortcut = (name) => ({ editor, view, tr, dispatch }) => {
  const keys = normalizeKeyName(name).split(/-(?!$)/);
  const key = keys.find((item) => !["Alt", "Ctrl", "Meta", "Shift"].includes(item));
  const event = new KeyboardEvent("keydown", {
    key: key === "Space" ? " " : key,
    altKey: keys.includes("Alt"),
    ctrlKey: keys.includes("Ctrl"),
    metaKey: keys.includes("Meta"),
    shiftKey: keys.includes("Shift"),
    bubbles: true,
    cancelable: true
  });
  const capturedTransaction = editor.captureTransaction(() => {
    view.someProp("handleKeyDown", (f) => f(view, event));
  });
  capturedTransaction === null || capturedTransaction === void 0 ? void 0 : capturedTransaction.steps.forEach((step) => {
    const newStep = step.map(tr.mapping);
    if (newStep && dispatch) {
      tr.maybeStep(newStep);
    }
  });
  return true;
};
function isNodeActive(state, typeOrName, attributes = {}) {
  const { from, to, empty } = state.selection;
  const type = typeOrName ? getNodeType(typeOrName, state.schema) : null;
  const nodeRanges = [];
  state.doc.nodesBetween(from, to, (node, pos) => {
    if (node.isText) {
      return;
    }
    const relativeFrom = Math.max(from, pos);
    const relativeTo = Math.min(to, pos + node.nodeSize);
    nodeRanges.push({
      node,
      from: relativeFrom,
      to: relativeTo
    });
  });
  const selectionRange = to - from;
  const matchedNodeRanges = nodeRanges.filter((nodeRange) => {
    if (!type) {
      return true;
    }
    return type.name === nodeRange.node.type.name;
  }).filter((nodeRange) => objectIncludes(nodeRange.node.attrs, attributes, { strict: false }));
  if (empty) {
    return !!matchedNodeRanges.length;
  }
  const range = matchedNodeRanges.reduce((sum, nodeRange) => sum + nodeRange.to - nodeRange.from, 0);
  return range >= selectionRange;
}
const lift = (typeOrName, attributes = {}) => ({ state, dispatch }) => {
  const type = getNodeType(typeOrName, state.schema);
  const isActive2 = isNodeActive(state, type, attributes);
  if (!isActive2) {
    return false;
  }
  return lift$1(state, dispatch);
};
const liftEmptyBlock = () => ({ state, dispatch }) => {
  return liftEmptyBlock$1(state, dispatch);
};
const liftListItem = (typeOrName) => ({ state, dispatch }) => {
  const type = getNodeType(typeOrName, state.schema);
  return liftListItem$1(type)(state, dispatch);
};
const newlineInCode = () => ({ state, dispatch }) => {
  return newlineInCode$1(state, dispatch);
};
function getSchemaTypeNameByName(name, schema) {
  if (schema.nodes[name]) {
    return "node";
  }
  if (schema.marks[name]) {
    return "mark";
  }
  return null;
}
function deleteProps(obj, propOrProps) {
  const props = typeof propOrProps === "string" ? [propOrProps] : propOrProps;
  return Object.keys(obj).reduce((newObj, prop) => {
    if (!props.includes(prop)) {
      newObj[prop] = obj[prop];
    }
    return newObj;
  }, {});
}
const resetAttributes = (typeOrName, attributes) => ({ tr, state, dispatch }) => {
  let nodeType = null;
  let markType = null;
  const schemaType = getSchemaTypeNameByName(typeof typeOrName === "string" ? typeOrName : typeOrName.name, state.schema);
  if (!schemaType) {
    return false;
  }
  if (schemaType === "node") {
    nodeType = getNodeType(typeOrName, state.schema);
  }
  if (schemaType === "mark") {
    markType = getMarkType(typeOrName, state.schema);
  }
  if (dispatch) {
    tr.selection.ranges.forEach((range) => {
      state.doc.nodesBetween(range.$from.pos, range.$to.pos, (node, pos) => {
        if (nodeType && nodeType === node.type) {
          tr.setNodeMarkup(pos, void 0, deleteProps(node.attrs, attributes));
        }
        if (markType && node.marks.length) {
          node.marks.forEach((mark) => {
            if (markType === mark.type) {
              tr.addMark(pos, pos + node.nodeSize, markType.create(deleteProps(mark.attrs, attributes)));
            }
          });
        }
      });
    });
  }
  return true;
};
const scrollIntoView = () => ({ tr, dispatch }) => {
  if (dispatch) {
    tr.scrollIntoView();
  }
  return true;
};
const selectAll = () => ({ tr, dispatch }) => {
  if (dispatch) {
    const selection = new AllSelection(tr.doc);
    tr.setSelection(selection);
  }
  return true;
};
const selectNodeBackward = () => ({ state, dispatch }) => {
  return selectNodeBackward$1(state, dispatch);
};
const selectNodeForward = () => ({ state, dispatch }) => {
  return selectNodeForward$1(state, dispatch);
};
const selectParentNode = () => ({ state, dispatch }) => {
  return selectParentNode$1(state, dispatch);
};
const selectTextblockEnd = () => ({ state, dispatch }) => {
  return selectTextblockEnd$1(state, dispatch);
};
const selectTextblockStart = () => ({ state, dispatch }) => {
  return selectTextblockStart$1(state, dispatch);
};
function createDocument(content, schema, parseOptions = {}, options = {}) {
  return createNodeFromContent(content, schema, {
    slice: false,
    parseOptions,
    errorOnInvalidContent: options.errorOnInvalidContent
  });
}
const setContent = (content, emitUpdate = false, parseOptions = {}, options = {}) => ({ editor, tr, dispatch, commands: commands2 }) => {
  var _a, _b;
  const { doc } = tr;
  if (parseOptions.preserveWhitespace !== "full") {
    const document2 = createDocument(content, editor.schema, parseOptions, {
      errorOnInvalidContent: (_a = options.errorOnInvalidContent) !== null && _a !== void 0 ? _a : editor.options.enableContentCheck
    });
    if (dispatch) {
      tr.replaceWith(0, doc.content.size, document2).setMeta("preventUpdate", !emitUpdate);
    }
    return true;
  }
  if (dispatch) {
    tr.setMeta("preventUpdate", !emitUpdate);
  }
  return commands2.insertContentAt({ from: 0, to: doc.content.size }, content, {
    parseOptions,
    errorOnInvalidContent: (_b = options.errorOnInvalidContent) !== null && _b !== void 0 ? _b : editor.options.enableContentCheck
  });
};
function getMarkAttributes(state, typeOrName) {
  const type = getMarkType(typeOrName, state.schema);
  const { from, to, empty } = state.selection;
  const marks = [];
  if (empty) {
    if (state.storedMarks) {
      marks.push(...state.storedMarks);
    }
    marks.push(...state.selection.$head.marks());
  } else {
    state.doc.nodesBetween(from, to, (node) => {
      marks.push(...node.marks);
    });
  }
  const mark = marks.find((markItem) => markItem.type.name === type.name);
  if (!mark) {
    return {};
  }
  return { ...mark.attrs };
}
function combineTransactionSteps(oldDoc, transactions) {
  const transform = new Transform(oldDoc);
  transactions.forEach((transaction) => {
    transaction.steps.forEach((step) => {
      transform.step(step);
    });
  });
  return transform;
}
function defaultBlockAt(match) {
  for (let i = 0; i < match.edgeCount; i += 1) {
    const { type } = match.edge(i);
    if (type.isTextblock && !type.hasRequiredAttrs()) {
      return type;
    }
  }
  return null;
}
function findChildren(node, predicate) {
  const nodesWithPos = [];
  node.descendants((child, pos) => {
    if (predicate(child)) {
      nodesWithPos.push({
        node: child,
        pos
      });
    }
  });
  return nodesWithPos;
}
function findChildrenInRange(node, range, predicate) {
  const nodesWithPos = [];
  node.nodesBetween(range.from, range.to, (child, pos) => {
    if (predicate(child)) {
      nodesWithPos.push({
        node: child,
        pos
      });
    }
  });
  return nodesWithPos;
}
function findParentNodeClosestToPos($pos, predicate) {
  for (let i = $pos.depth; i > 0; i -= 1) {
    const node = $pos.node(i);
    if (predicate(node)) {
      return {
        pos: i > 0 ? $pos.before(i) : 0,
        start: $pos.start(i),
        depth: i,
        node
      };
    }
  }
}
function findParentNode(predicate) {
  return (selection) => findParentNodeClosestToPos(selection.$from, predicate);
}
function getNodeAttributes(state, typeOrName) {
  const type = getNodeType(typeOrName, state.schema);
  const { from, to } = state.selection;
  const nodes = [];
  state.doc.nodesBetween(from, to, (node2) => {
    nodes.push(node2);
  });
  const node = nodes.reverse().find((nodeItem) => nodeItem.type.name === type.name);
  if (!node) {
    return {};
  }
  return { ...node.attrs };
}
function getAttributes(state, typeOrName) {
  const schemaType = getSchemaTypeNameByName(typeof typeOrName === "string" ? typeOrName : typeOrName.name, state.schema);
  if (schemaType === "node") {
    return getNodeAttributes(state, typeOrName);
  }
  if (schemaType === "mark") {
    return getMarkAttributes(state, typeOrName);
  }
  return {};
}
function removeDuplicates(array, by = JSON.stringify) {
  const seen = {};
  return array.filter((item) => {
    const key = by(item);
    return Object.prototype.hasOwnProperty.call(seen, key) ? false : seen[key] = true;
  });
}
function simplifyChangedRanges(changes) {
  const uniqueChanges = removeDuplicates(changes);
  return uniqueChanges.length === 1 ? uniqueChanges : uniqueChanges.filter((change, index2) => {
    const rest = uniqueChanges.filter((_, i) => i !== index2);
    return !rest.some((otherChange) => {
      return change.oldRange.from >= otherChange.oldRange.from && change.oldRange.to <= otherChange.oldRange.to && change.newRange.from >= otherChange.newRange.from && change.newRange.to <= otherChange.newRange.to;
    });
  });
}
function getChangedRanges(transform) {
  const { mapping, steps } = transform;
  const changes = [];
  mapping.maps.forEach((stepMap, index2) => {
    const ranges = [];
    if (!stepMap.ranges.length) {
      const { from, to } = steps[index2];
      if (from === void 0 || to === void 0) {
        return;
      }
      ranges.push({ from, to });
    } else {
      stepMap.forEach((from, to) => {
        ranges.push({ from, to });
      });
    }
    ranges.forEach(({ from, to }) => {
      const newStart = mapping.slice(index2).map(from, -1);
      const newEnd = mapping.slice(index2).map(to);
      const oldStart = mapping.invert().map(newStart, -1);
      const oldEnd = mapping.invert().map(newEnd);
      changes.push({
        oldRange: {
          from: oldStart,
          to: oldEnd
        },
        newRange: {
          from: newStart,
          to: newEnd
        }
      });
    });
  });
  return simplifyChangedRanges(changes);
}
function getMarksBetween(from, to, doc) {
  const marks = [];
  if (from === to) {
    doc.resolve(from).marks().forEach((mark) => {
      const $pos = doc.resolve(from);
      const range = getMarkRange($pos, mark.type);
      if (!range) {
        return;
      }
      marks.push({
        mark,
        ...range
      });
    });
  } else {
    doc.nodesBetween(from, to, (node, pos) => {
      if (!node || (node === null || node === void 0 ? void 0 : node.nodeSize) === void 0) {
        return;
      }
      marks.push(...node.marks.map((mark) => ({
        from: pos,
        to: pos + node.nodeSize,
        mark
      })));
    });
  }
  return marks;
}
function getSplittedAttributes(extensionAttributes, typeName, attributes) {
  return Object.fromEntries(Object.entries(attributes).filter(([name]) => {
    const extensionAttribute = extensionAttributes.find((item) => {
      return item.type === typeName && item.name === name;
    });
    if (!extensionAttribute) {
      return false;
    }
    return extensionAttribute.attribute.keepOnSplit;
  }));
}
function isMarkActive(state, typeOrName, attributes = {}) {
  const { empty, ranges } = state.selection;
  const type = typeOrName ? getMarkType(typeOrName, state.schema) : null;
  if (empty) {
    return !!(state.storedMarks || state.selection.$from.marks()).filter((mark) => {
      if (!type) {
        return true;
      }
      return type.name === mark.type.name;
    }).find((mark) => objectIncludes(mark.attrs, attributes, { strict: false }));
  }
  let selectionRange = 0;
  const markRanges = [];
  ranges.forEach(({ $from, $to }) => {
    const from = $from.pos;
    const to = $to.pos;
    state.doc.nodesBetween(from, to, (node, pos) => {
      if (!node.isText && !node.marks.length) {
        return;
      }
      const relativeFrom = Math.max(from, pos);
      const relativeTo = Math.min(to, pos + node.nodeSize);
      const range2 = relativeTo - relativeFrom;
      selectionRange += range2;
      markRanges.push(...node.marks.map((mark) => ({
        mark,
        from: relativeFrom,
        to: relativeTo
      })));
    });
  });
  if (selectionRange === 0) {
    return false;
  }
  const matchedRange = markRanges.filter((markRange) => {
    if (!type) {
      return true;
    }
    return type.name === markRange.mark.type.name;
  }).filter((markRange) => objectIncludes(markRange.mark.attrs, attributes, { strict: false })).reduce((sum, markRange) => sum + markRange.to - markRange.from, 0);
  const excludedRange = markRanges.filter((markRange) => {
    if (!type) {
      return true;
    }
    return markRange.mark.type !== type && markRange.mark.type.excludes(type);
  }).reduce((sum, markRange) => sum + markRange.to - markRange.from, 0);
  const range = matchedRange > 0 ? matchedRange + excludedRange : matchedRange;
  return range >= selectionRange;
}
function isList(name, extensions) {
  const { nodeExtensions } = splitExtensions(extensions);
  const extension = nodeExtensions.find((item) => item.name === name);
  if (!extension) {
    return false;
  }
  const context = {
    name: extension.name,
    options: extension.options,
    storage: extension.storage
  };
  const group = callOrReturn(getExtensionField(extension, "group", context));
  if (typeof group !== "string") {
    return false;
  }
  return group.split(" ").includes("list");
}
function isNodeEmpty(node, { checkChildren = true, ignoreWhitespace = false } = {}) {
  var _a;
  if (ignoreWhitespace) {
    if (node.type.name === "hardBreak") {
      return true;
    }
    if (node.isText) {
      return /^\s*$/m.test((_a = node.text) !== null && _a !== void 0 ? _a : "");
    }
  }
  if (node.isText) {
    return !node.text;
  }
  if (node.isAtom || node.isLeaf) {
    return false;
  }
  if (node.content.childCount === 0) {
    return true;
  }
  if (checkChildren) {
    let isContentEmpty = true;
    node.content.forEach((childNode) => {
      if (isContentEmpty === false) {
        return;
      }
      if (!isNodeEmpty(childNode, { ignoreWhitespace, checkChildren })) {
        isContentEmpty = false;
      }
    });
    return isContentEmpty;
  }
  return false;
}
function isNodeSelection(value) {
  return value instanceof NodeSelection;
}
function canSetMark(state, tr, newMarkType) {
  var _a;
  const { selection } = tr;
  let cursor = null;
  if (isTextSelection(selection)) {
    cursor = selection.$cursor;
  }
  if (cursor) {
    const currentMarks = (_a = state.storedMarks) !== null && _a !== void 0 ? _a : cursor.marks();
    return !!newMarkType.isInSet(currentMarks) || !currentMarks.some((mark) => mark.type.excludes(newMarkType));
  }
  const { ranges } = selection;
  return ranges.some(({ $from, $to }) => {
    let someNodeSupportsMark = $from.depth === 0 ? state.doc.inlineContent && state.doc.type.allowsMarkType(newMarkType) : false;
    state.doc.nodesBetween($from.pos, $to.pos, (node, _pos, parent) => {
      if (someNodeSupportsMark) {
        return false;
      }
      if (node.isInline) {
        const parentAllowsMarkType = !parent || parent.type.allowsMarkType(newMarkType);
        const currentMarksAllowMarkType = !!newMarkType.isInSet(node.marks) || !node.marks.some((otherMark) => otherMark.type.excludes(newMarkType));
        someNodeSupportsMark = parentAllowsMarkType && currentMarksAllowMarkType;
      }
      return !someNodeSupportsMark;
    });
    return someNodeSupportsMark;
  });
}
const setMark = (typeOrName, attributes = {}) => ({ tr, state, dispatch }) => {
  const { selection } = tr;
  const { empty, ranges } = selection;
  const type = getMarkType(typeOrName, state.schema);
  if (dispatch) {
    if (empty) {
      const oldAttributes = getMarkAttributes(state, type);
      tr.addStoredMark(type.create({
        ...oldAttributes,
        ...attributes
      }));
    } else {
      ranges.forEach((range) => {
        const from = range.$from.pos;
        const to = range.$to.pos;
        state.doc.nodesBetween(from, to, (node, pos) => {
          const trimmedFrom = Math.max(pos, from);
          const trimmedTo = Math.min(pos + node.nodeSize, to);
          const someHasMark = node.marks.find((mark) => mark.type === type);
          if (someHasMark) {
            node.marks.forEach((mark) => {
              if (type === mark.type) {
                tr.addMark(trimmedFrom, trimmedTo, type.create({
                  ...mark.attrs,
                  ...attributes
                }));
              }
            });
          } else {
            tr.addMark(trimmedFrom, trimmedTo, type.create(attributes));
          }
        });
      });
    }
  }
  return canSetMark(state, tr, type);
};
const setMeta = (key, value) => ({ tr }) => {
  tr.setMeta(key, value);
  return true;
};
const setNode = (typeOrName, attributes = {}) => ({ state, dispatch, chain }) => {
  const type = getNodeType(typeOrName, state.schema);
  let attributesToCopy;
  if (state.selection.$anchor.sameParent(state.selection.$head)) {
    attributesToCopy = state.selection.$anchor.parent.attrs;
  }
  if (!type.isTextblock) {
    console.warn('[tiptap warn]: Currently "setNode()" only supports text block nodes.');
    return false;
  }
  return chain().command(({ commands: commands2 }) => {
    const canSetBlock = setBlockType(type, { ...attributesToCopy, ...attributes })(state);
    if (canSetBlock) {
      return true;
    }
    return commands2.clearNodes();
  }).command(({ state: updatedState }) => {
    return setBlockType(type, { ...attributesToCopy, ...attributes })(updatedState, dispatch);
  }).run();
};
const setNodeSelection = (position) => ({ tr, dispatch }) => {
  if (dispatch) {
    const { doc } = tr;
    const from = minMax(position, 0, doc.content.size);
    const selection = NodeSelection.create(doc, from);
    tr.setSelection(selection);
  }
  return true;
};
const setTextSelection = (position) => ({ tr, dispatch }) => {
  if (dispatch) {
    const { doc } = tr;
    const { from, to } = typeof position === "number" ? { from: position, to: position } : position;
    const minPos = TextSelection.atStart(doc).from;
    const maxPos = TextSelection.atEnd(doc).to;
    const resolvedFrom = minMax(from, minPos, maxPos);
    const resolvedEnd = minMax(to, minPos, maxPos);
    const selection = TextSelection.create(doc, resolvedFrom, resolvedEnd);
    tr.setSelection(selection);
  }
  return true;
};
const sinkListItem = (typeOrName) => ({ state, dispatch }) => {
  const type = getNodeType(typeOrName, state.schema);
  return sinkListItem$1(type)(state, dispatch);
};
function ensureMarks(state, splittableMarks) {
  const marks = state.storedMarks || state.selection.$to.parentOffset && state.selection.$from.marks();
  if (marks) {
    const filteredMarks = marks.filter((mark) => splittableMarks === null || splittableMarks === void 0 ? void 0 : splittableMarks.includes(mark.type.name));
    state.tr.ensureMarks(filteredMarks);
  }
}
const splitBlock = ({ keepMarks = true } = {}) => ({ tr, state, dispatch, editor }) => {
  const { selection, doc } = tr;
  const { $from, $to } = selection;
  const extensionAttributes = editor.extensionManager.attributes;
  const newAttributes = getSplittedAttributes(extensionAttributes, $from.node().type.name, $from.node().attrs);
  if (selection instanceof NodeSelection && selection.node.isBlock) {
    if (!$from.parentOffset || !canSplit(doc, $from.pos)) {
      return false;
    }
    if (dispatch) {
      if (keepMarks) {
        ensureMarks(state, editor.extensionManager.splittableMarks);
      }
      tr.split($from.pos).scrollIntoView();
    }
    return true;
  }
  if (!$from.parent.isBlock) {
    return false;
  }
  const atEnd = $to.parentOffset === $to.parent.content.size;
  const deflt = $from.depth === 0 ? void 0 : defaultBlockAt($from.node(-1).contentMatchAt($from.indexAfter(-1)));
  let types = atEnd && deflt ? [
    {
      type: deflt,
      attrs: newAttributes
    }
  ] : void 0;
  let can = canSplit(tr.doc, tr.mapping.map($from.pos), 1, types);
  if (!types && !can && canSplit(tr.doc, tr.mapping.map($from.pos), 1, deflt ? [{ type: deflt }] : void 0)) {
    can = true;
    types = deflt ? [
      {
        type: deflt,
        attrs: newAttributes
      }
    ] : void 0;
  }
  if (dispatch) {
    if (can) {
      if (selection instanceof TextSelection) {
        tr.deleteSelection();
      }
      tr.split(tr.mapping.map($from.pos), 1, types);
      if (deflt && !atEnd && !$from.parentOffset && $from.parent.type !== deflt) {
        const first2 = tr.mapping.map($from.before());
        const $first = tr.doc.resolve(first2);
        if ($from.node(-1).canReplaceWith($first.index(), $first.index() + 1, deflt)) {
          tr.setNodeMarkup(tr.mapping.map($from.before()), deflt);
        }
      }
    }
    if (keepMarks) {
      ensureMarks(state, editor.extensionManager.splittableMarks);
    }
    tr.scrollIntoView();
  }
  return can;
};
const splitListItem = (typeOrName, overrideAttrs = {}) => ({ tr, state, dispatch, editor }) => {
  var _a;
  const type = getNodeType(typeOrName, state.schema);
  const { $from, $to } = state.selection;
  const node = state.selection.node;
  if (node && node.isBlock || $from.depth < 2 || !$from.sameParent($to)) {
    return false;
  }
  const grandParent = $from.node(-1);
  if (grandParent.type !== type) {
    return false;
  }
  const extensionAttributes = editor.extensionManager.attributes;
  if ($from.parent.content.size === 0 && $from.node(-1).childCount === $from.indexAfter(-1)) {
    if ($from.depth === 2 || $from.node(-3).type !== type || $from.index(-2) !== $from.node(-2).childCount - 1) {
      return false;
    }
    if (dispatch) {
      let wrap = Fragment$1.empty;
      const depthBefore = $from.index(-1) ? 1 : $from.index(-2) ? 2 : 3;
      for (let d = $from.depth - depthBefore; d >= $from.depth - 3; d -= 1) {
        wrap = Fragment$1.from($from.node(d).copy(wrap));
      }
      const depthAfter = $from.indexAfter(-1) < $from.node(-2).childCount ? 1 : $from.indexAfter(-2) < $from.node(-3).childCount ? 2 : 3;
      const newNextTypeAttributes2 = {
        ...getSplittedAttributes(extensionAttributes, $from.node().type.name, $from.node().attrs),
        ...overrideAttrs
      };
      const nextType2 = ((_a = type.contentMatch.defaultType) === null || _a === void 0 ? void 0 : _a.createAndFill(newNextTypeAttributes2)) || void 0;
      wrap = wrap.append(Fragment$1.from(type.createAndFill(null, nextType2) || void 0));
      const start = $from.before($from.depth - (depthBefore - 1));
      tr.replace(start, $from.after(-depthAfter), new Slice(wrap, 4 - depthBefore, 0));
      let sel = -1;
      tr.doc.nodesBetween(start, tr.doc.content.size, (n, pos) => {
        if (sel > -1) {
          return false;
        }
        if (n.isTextblock && n.content.size === 0) {
          sel = pos + 1;
        }
      });
      if (sel > -1) {
        tr.setSelection(TextSelection.near(tr.doc.resolve(sel)));
      }
      tr.scrollIntoView();
    }
    return true;
  }
  const nextType = $to.pos === $from.end() ? grandParent.contentMatchAt(0).defaultType : null;
  const newTypeAttributes = {
    ...getSplittedAttributes(extensionAttributes, grandParent.type.name, grandParent.attrs),
    ...overrideAttrs
  };
  const newNextTypeAttributes = {
    ...getSplittedAttributes(extensionAttributes, $from.node().type.name, $from.node().attrs),
    ...overrideAttrs
  };
  tr.delete($from.pos, $to.pos);
  const types = nextType ? [
    { type, attrs: newTypeAttributes },
    { type: nextType, attrs: newNextTypeAttributes }
  ] : [{ type, attrs: newTypeAttributes }];
  if (!canSplit(tr.doc, $from.pos, 2)) {
    return false;
  }
  if (dispatch) {
    const { selection, storedMarks } = state;
    const { splittableMarks } = editor.extensionManager;
    const marks = storedMarks || selection.$to.parentOffset && selection.$from.marks();
    tr.split($from.pos, 2, types).scrollIntoView();
    if (!marks || !dispatch) {
      return true;
    }
    const filteredMarks = marks.filter((mark) => splittableMarks.includes(mark.type.name));
    tr.ensureMarks(filteredMarks);
  }
  return true;
};
const joinListBackwards = (tr, listType) => {
  const list = findParentNode((node) => node.type === listType)(tr.selection);
  if (!list) {
    return true;
  }
  const before = tr.doc.resolve(Math.max(0, list.pos - 1)).before(list.depth);
  if (before === void 0) {
    return true;
  }
  const nodeBefore = tr.doc.nodeAt(before);
  const canJoinBackwards = list.node.type === (nodeBefore === null || nodeBefore === void 0 ? void 0 : nodeBefore.type) && canJoin(tr.doc, list.pos);
  if (!canJoinBackwards) {
    return true;
  }
  tr.join(list.pos);
  return true;
};
const joinListForwards = (tr, listType) => {
  const list = findParentNode((node) => node.type === listType)(tr.selection);
  if (!list) {
    return true;
  }
  const after = tr.doc.resolve(list.start).after(list.depth);
  if (after === void 0) {
    return true;
  }
  const nodeAfter = tr.doc.nodeAt(after);
  const canJoinForwards = list.node.type === (nodeAfter === null || nodeAfter === void 0 ? void 0 : nodeAfter.type) && canJoin(tr.doc, after);
  if (!canJoinForwards) {
    return true;
  }
  tr.join(after);
  return true;
};
const toggleList = (listTypeOrName, itemTypeOrName, keepMarks, attributes = {}) => ({ editor, tr, state, dispatch, chain, commands: commands2, can }) => {
  const { extensions, splittableMarks } = editor.extensionManager;
  const listType = getNodeType(listTypeOrName, state.schema);
  const itemType = getNodeType(itemTypeOrName, state.schema);
  const { selection, storedMarks } = state;
  const { $from, $to } = selection;
  const range = $from.blockRange($to);
  const marks = storedMarks || selection.$to.parentOffset && selection.$from.marks();
  if (!range) {
    return false;
  }
  const parentList = findParentNode((node) => isList(node.type.name, extensions))(selection);
  if (range.depth >= 1 && parentList && range.depth - parentList.depth <= 1) {
    if (parentList.node.type === listType) {
      return commands2.liftListItem(itemType);
    }
    if (isList(parentList.node.type.name, extensions) && listType.validContent(parentList.node.content) && dispatch) {
      return chain().command(() => {
        tr.setNodeMarkup(parentList.pos, listType);
        return true;
      }).command(() => joinListBackwards(tr, listType)).command(() => joinListForwards(tr, listType)).run();
    }
  }
  if (!keepMarks || !marks || !dispatch) {
    return chain().command(() => {
      const canWrapInList = can().wrapInList(listType, attributes);
      if (canWrapInList) {
        return true;
      }
      return commands2.clearNodes();
    }).wrapInList(listType, attributes).command(() => joinListBackwards(tr, listType)).command(() => joinListForwards(tr, listType)).run();
  }
  return chain().command(() => {
    const canWrapInList = can().wrapInList(listType, attributes);
    const filteredMarks = marks.filter((mark) => splittableMarks.includes(mark.type.name));
    tr.ensureMarks(filteredMarks);
    if (canWrapInList) {
      return true;
    }
    return commands2.clearNodes();
  }).wrapInList(listType, attributes).command(() => joinListBackwards(tr, listType)).command(() => joinListForwards(tr, listType)).run();
};
const toggleMark = (typeOrName, attributes = {}, options = {}) => ({ state, commands: commands2 }) => {
  const { extendEmptyMarkRange = false } = options;
  const type = getMarkType(typeOrName, state.schema);
  const isActive2 = isMarkActive(state, type, attributes);
  if (isActive2) {
    return commands2.unsetMark(type, { extendEmptyMarkRange });
  }
  return commands2.setMark(type, attributes);
};
const toggleNode = (typeOrName, toggleTypeOrName, attributes = {}) => ({ state, commands: commands2 }) => {
  const type = getNodeType(typeOrName, state.schema);
  const toggleType = getNodeType(toggleTypeOrName, state.schema);
  const isActive2 = isNodeActive(state, type, attributes);
  let attributesToCopy;
  if (state.selection.$anchor.sameParent(state.selection.$head)) {
    attributesToCopy = state.selection.$anchor.parent.attrs;
  }
  if (isActive2) {
    return commands2.setNode(toggleType, attributesToCopy);
  }
  return commands2.setNode(type, { ...attributesToCopy, ...attributes });
};
const toggleWrap = (typeOrName, attributes = {}) => ({ state, commands: commands2 }) => {
  const type = getNodeType(typeOrName, state.schema);
  const isActive2 = isNodeActive(state, type, attributes);
  if (isActive2) {
    return commands2.lift(type);
  }
  return commands2.wrapIn(type, attributes);
};
const undoInputRule = () => ({ state, dispatch }) => {
  const plugins = state.plugins;
  for (let i = 0; i < plugins.length; i += 1) {
    const plugin = plugins[i];
    let undoable;
    if (plugin.spec.isInputRules && (undoable = plugin.getState(state))) {
      if (dispatch) {
        const tr = state.tr;
        const toUndo = undoable.transform;
        for (let j = toUndo.steps.length - 1; j >= 0; j -= 1) {
          tr.step(toUndo.steps[j].invert(toUndo.docs[j]));
        }
        if (undoable.text) {
          const marks = tr.doc.resolve(undoable.from).marks();
          tr.replaceWith(undoable.from, undoable.to, state.schema.text(undoable.text, marks));
        } else {
          tr.delete(undoable.from, undoable.to);
        }
      }
      return true;
    }
  }
  return false;
};
const unsetAllMarks = () => ({ tr, dispatch }) => {
  const { selection } = tr;
  const { empty, ranges } = selection;
  if (empty) {
    return true;
  }
  if (dispatch) {
    ranges.forEach((range) => {
      tr.removeMark(range.$from.pos, range.$to.pos);
    });
  }
  return true;
};
const unsetMark = (typeOrName, options = {}) => ({ tr, state, dispatch }) => {
  var _a;
  const { extendEmptyMarkRange = false } = options;
  const { selection } = tr;
  const type = getMarkType(typeOrName, state.schema);
  const { $from, empty, ranges } = selection;
  if (!dispatch) {
    return true;
  }
  if (empty && extendEmptyMarkRange) {
    let { from, to } = selection;
    const attrs = (_a = $from.marks().find((mark) => mark.type === type)) === null || _a === void 0 ? void 0 : _a.attrs;
    const range = getMarkRange($from, type, attrs);
    if (range) {
      from = range.from;
      to = range.to;
    }
    tr.removeMark(from, to, type);
  } else {
    ranges.forEach((range) => {
      tr.removeMark(range.$from.pos, range.$to.pos, type);
    });
  }
  tr.removeStoredMark(type);
  return true;
};
const updateAttributes = (typeOrName, attributes = {}) => ({ tr, state, dispatch }) => {
  let nodeType = null;
  let markType = null;
  const schemaType = getSchemaTypeNameByName(typeof typeOrName === "string" ? typeOrName : typeOrName.name, state.schema);
  if (!schemaType) {
    return false;
  }
  if (schemaType === "node") {
    nodeType = getNodeType(typeOrName, state.schema);
  }
  if (schemaType === "mark") {
    markType = getMarkType(typeOrName, state.schema);
  }
  if (dispatch) {
    tr.selection.ranges.forEach((range) => {
      const from = range.$from.pos;
      const to = range.$to.pos;
      let lastPos;
      let lastNode;
      let trimmedFrom;
      let trimmedTo;
      if (tr.selection.empty) {
        state.doc.nodesBetween(from, to, (node, pos) => {
          if (nodeType && nodeType === node.type) {
            trimmedFrom = Math.max(pos, from);
            trimmedTo = Math.min(pos + node.nodeSize, to);
            lastPos = pos;
            lastNode = node;
          }
        });
      } else {
        state.doc.nodesBetween(from, to, (node, pos) => {
          if (pos < from && nodeType && nodeType === node.type) {
            trimmedFrom = Math.max(pos, from);
            trimmedTo = Math.min(pos + node.nodeSize, to);
            lastPos = pos;
            lastNode = node;
          }
          if (pos >= from && pos <= to) {
            if (nodeType && nodeType === node.type) {
              tr.setNodeMarkup(pos, void 0, {
                ...node.attrs,
                ...attributes
              });
            }
            if (markType && node.marks.length) {
              node.marks.forEach((mark) => {
                if (markType === mark.type) {
                  const trimmedFrom2 = Math.max(pos, from);
                  const trimmedTo2 = Math.min(pos + node.nodeSize, to);
                  tr.addMark(trimmedFrom2, trimmedTo2, markType.create({
                    ...mark.attrs,
                    ...attributes
                  }));
                }
              });
            }
          }
        });
      }
      if (lastNode) {
        if (lastPos !== void 0) {
          tr.setNodeMarkup(lastPos, void 0, {
            ...lastNode.attrs,
            ...attributes
          });
        }
        if (markType && lastNode.marks.length) {
          lastNode.marks.forEach((mark) => {
            if (markType === mark.type) {
              tr.addMark(trimmedFrom, trimmedTo, markType.create({
                ...mark.attrs,
                ...attributes
              }));
            }
          });
        }
      }
    });
  }
  return true;
};
const wrapIn = (typeOrName, attributes = {}) => ({ state, dispatch }) => {
  const type = getNodeType(typeOrName, state.schema);
  return wrapIn$1(type, attributes)(state, dispatch);
};
const wrapInList = (typeOrName, attributes = {}) => ({ state, dispatch }) => {
  const type = getNodeType(typeOrName, state.schema);
  return wrapInList$1(type, attributes)(state, dispatch);
};
var commands = /* @__PURE__ */ Object.freeze({
  __proto__: null,
  blur,
  clearContent,
  clearNodes,
  command,
  createParagraphNear,
  cut,
  deleteCurrentNode,
  deleteNode,
  deleteRange,
  deleteSelection,
  enter,
  exitCode,
  extendMarkRange,
  first,
  focus,
  forEach,
  insertContent,
  insertContentAt,
  joinBackward,
  joinDown,
  joinForward,
  joinItemBackward,
  joinItemForward,
  joinTextblockBackward,
  joinTextblockForward,
  joinUp,
  keyboardShortcut,
  lift,
  liftEmptyBlock,
  liftListItem,
  newlineInCode,
  resetAttributes,
  scrollIntoView,
  selectAll,
  selectNodeBackward,
  selectNodeForward,
  selectParentNode,
  selectTextblockEnd,
  selectTextblockStart,
  setContent,
  setMark,
  setMeta,
  setNode,
  setNodeSelection,
  setTextSelection,
  sinkListItem,
  splitBlock,
  splitListItem,
  toggleList,
  toggleMark,
  toggleNode,
  toggleWrap,
  undoInputRule,
  unsetAllMarks,
  unsetMark,
  updateAttributes,
  wrapIn,
  wrapInList
});
Extension.create({
  name: "commands",
  addCommands() {
    return {
      ...commands
    };
  }
});
Extension.create({
  name: "drop",
  addProseMirrorPlugins() {
    return [
      new Plugin({
        key: new PluginKey("tiptapDrop"),
        props: {
          handleDrop: (_, e, slice, moved) => {
            this.editor.emit("drop", {
              editor: this.editor,
              event: e,
              slice,
              moved
            });
          }
        }
      })
    ];
  }
});
Extension.create({
  name: "editable",
  addProseMirrorPlugins() {
    return [
      new Plugin({
        key: new PluginKey("editable"),
        props: {
          editable: () => this.editor.options.editable
        }
      })
    ];
  }
});
const focusEventsPluginKey = new PluginKey("focusEvents");
Extension.create({
  name: "focusEvents",
  addProseMirrorPlugins() {
    const { editor } = this;
    return [
      new Plugin({
        key: focusEventsPluginKey,
        props: {
          handleDOMEvents: {
            focus: (view, event) => {
              editor.isFocused = true;
              const transaction = editor.state.tr.setMeta("focus", { event }).setMeta("addToHistory", false);
              view.dispatch(transaction);
              return false;
            },
            blur: (view, event) => {
              editor.isFocused = false;
              const transaction = editor.state.tr.setMeta("blur", { event }).setMeta("addToHistory", false);
              view.dispatch(transaction);
              return false;
            }
          }
        }
      })
    ];
  }
});
Extension.create({
  name: "keymap",
  addKeyboardShortcuts() {
    const handleBackspace = () => this.editor.commands.first(({ commands: commands2 }) => [
      () => commands2.undoInputRule(),
      // maybe convert first text block node to default node
      () => commands2.command(({ tr }) => {
        const { selection, doc } = tr;
        const { empty, $anchor } = selection;
        const { pos, parent } = $anchor;
        const $parentPos = $anchor.parent.isTextblock && pos > 0 ? tr.doc.resolve(pos - 1) : $anchor;
        const parentIsIsolating = $parentPos.parent.type.spec.isolating;
        const parentPos = $anchor.pos - $anchor.parentOffset;
        const isAtStart = parentIsIsolating && $parentPos.parent.childCount === 1 ? parentPos === $anchor.pos : Selection.atStart(doc).from === pos;
        if (!empty || !parent.type.isTextblock || parent.textContent.length || !isAtStart || isAtStart && $anchor.parent.type.name === "paragraph") {
          return false;
        }
        return commands2.clearNodes();
      }),
      () => commands2.deleteSelection(),
      () => commands2.joinBackward(),
      () => commands2.selectNodeBackward()
    ]);
    const handleDelete = () => this.editor.commands.first(({ commands: commands2 }) => [
      () => commands2.deleteSelection(),
      () => commands2.deleteCurrentNode(),
      () => commands2.joinForward(),
      () => commands2.selectNodeForward()
    ]);
    const handleEnter = () => this.editor.commands.first(({ commands: commands2 }) => [
      () => commands2.newlineInCode(),
      () => commands2.createParagraphNear(),
      () => commands2.liftEmptyBlock(),
      () => commands2.splitBlock()
    ]);
    const baseKeymap = {
      Enter: handleEnter,
      "Mod-Enter": () => this.editor.commands.exitCode(),
      Backspace: handleBackspace,
      "Mod-Backspace": handleBackspace,
      "Shift-Backspace": handleBackspace,
      Delete: handleDelete,
      "Mod-Delete": handleDelete,
      "Mod-a": () => this.editor.commands.selectAll()
    };
    const pcKeymap = {
      ...baseKeymap
    };
    const macKeymap = {
      ...baseKeymap,
      "Ctrl-h": handleBackspace,
      "Alt-Backspace": handleBackspace,
      "Ctrl-d": handleDelete,
      "Ctrl-Alt-Backspace": handleDelete,
      "Alt-Delete": handleDelete,
      "Alt-d": handleDelete,
      "Ctrl-a": () => this.editor.commands.selectTextblockStart(),
      "Ctrl-e": () => this.editor.commands.selectTextblockEnd()
    };
    if (isiOS() || isMacOS()) {
      return macKeymap;
    }
    return pcKeymap;
  },
  addProseMirrorPlugins() {
    return [
      // With this plugin we check if the whole document was selected and deleted.
      // In this case we will additionally call `clearNodes()` to convert e.g. a heading
      // to a paragraph if necessary.
      // This is an alternative to ProseMirror's `AllSelection`, which doesn’t work well
      // with many other commands.
      new Plugin({
        key: new PluginKey("clearDocument"),
        appendTransaction: (transactions, oldState, newState) => {
          if (transactions.some((tr2) => tr2.getMeta("composition"))) {
            return;
          }
          const docChanges = transactions.some((transaction) => transaction.docChanged) && !oldState.doc.eq(newState.doc);
          const ignoreTr = transactions.some((transaction) => transaction.getMeta("preventClearDocument"));
          if (!docChanges || ignoreTr) {
            return;
          }
          const { empty, from, to } = oldState.selection;
          const allFrom = Selection.atStart(oldState.doc).from;
          const allEnd = Selection.atEnd(oldState.doc).to;
          const allWasSelected = from === allFrom && to === allEnd;
          if (empty || !allWasSelected) {
            return;
          }
          const isEmpty = isNodeEmpty(newState.doc);
          if (!isEmpty) {
            return;
          }
          const tr = newState.tr;
          const state = createChainableState({
            state: newState,
            transaction: tr
          });
          const { commands: commands2 } = new CommandManager({
            editor: this.editor,
            state
          });
          commands2.clearNodes();
          if (!tr.steps.length) {
            return;
          }
          return tr;
        }
      })
    ];
  }
});
Extension.create({
  name: "paste",
  addProseMirrorPlugins() {
    return [
      new Plugin({
        key: new PluginKey("tiptapPaste"),
        props: {
          handlePaste: (_view, e, slice) => {
            this.editor.emit("paste", {
              editor: this.editor,
              event: e,
              slice
            });
          }
        }
      })
    ];
  }
});
Extension.create({
  name: "tabindex",
  addProseMirrorPlugins() {
    return [
      new Plugin({
        key: new PluginKey("tabindex"),
        props: {
          attributes: () => this.editor.isEditable ? { tabindex: "0" } : {}
        }
      })
    ];
  }
});
function markInputRule(config) {
  return new InputRule({
    find: config.find,
    handler: ({ state, range, match }) => {
      const attributes = callOrReturn(config.getAttributes, void 0, match);
      if (attributes === false || attributes === null) {
        return null;
      }
      const { tr } = state;
      const captureGroup = match[match.length - 1];
      const fullMatch = match[0];
      if (captureGroup) {
        const startSpaces = fullMatch.search(/\S/);
        const textStart = range.from + fullMatch.indexOf(captureGroup);
        const textEnd = textStart + captureGroup.length;
        const excludedMarks = getMarksBetween(range.from, range.to, state.doc).filter((item) => {
          const excluded = item.mark.type.excluded;
          return excluded.find((type) => type === config.type && type !== item.mark.type);
        }).filter((item) => item.to > textStart);
        if (excludedMarks.length) {
          return null;
        }
        if (textEnd < range.to) {
          tr.delete(textEnd, range.to);
        }
        if (textStart > range.from) {
          tr.delete(range.from + startSpaces, textStart);
        }
        const markEnd = range.from + startSpaces + captureGroup.length;
        tr.addMark(range.from + startSpaces, markEnd, config.type.create(attributes || {}));
        tr.removeStoredMark(config.type);
      }
    }
  });
}
function nodeInputRule(config) {
  return new InputRule({
    find: config.find,
    handler: ({ state, range, match }) => {
      const attributes = callOrReturn(config.getAttributes, void 0, match) || {};
      const { tr } = state;
      const start = range.from;
      let end = range.to;
      const newNode2 = config.type.create(attributes);
      if (match[1]) {
        const offset = match[0].lastIndexOf(match[1]);
        let matchStart = start + offset;
        if (matchStart > end) {
          matchStart = end;
        } else {
          end = matchStart + match[1].length;
        }
        const lastChar = match[0][match[0].length - 1];
        tr.insertText(lastChar, start + match[0].length - 1);
        tr.replaceWith(matchStart, end, newNode2);
      } else if (match[0]) {
        const insertionStart = config.type.isInline ? start : start - 1;
        tr.insert(insertionStart, config.type.create(attributes)).delete(tr.mapping.map(start), tr.mapping.map(end));
      }
      tr.scrollIntoView();
    }
  });
}
function textblockTypeInputRule(config) {
  return new InputRule({
    find: config.find,
    handler: ({ state, range, match }) => {
      const $start = state.doc.resolve(range.from);
      const attributes = callOrReturn(config.getAttributes, void 0, match) || {};
      if (!$start.node(-1).canReplaceWith($start.index(-1), $start.indexAfter(-1), config.type)) {
        return null;
      }
      state.tr.delete(range.from, range.to).setBlockType(range.from, range.from, config.type, attributes);
    }
  });
}
function wrappingInputRule(config) {
  return new InputRule({
    find: config.find,
    handler: ({ state, range, match, chain }) => {
      const attributes = callOrReturn(config.getAttributes, void 0, match) || {};
      const tr = state.tr.delete(range.from, range.to);
      const $start = tr.doc.resolve(range.from);
      const blockRange = $start.blockRange();
      const wrapping = blockRange && findWrapping(blockRange, config.type, attributes);
      if (!wrapping) {
        return null;
      }
      tr.wrap(blockRange, wrapping);
      if (config.keepMarks && config.editor) {
        const { selection, storedMarks } = state;
        const { splittableMarks } = config.editor.extensionManager;
        const marks = storedMarks || selection.$to.parentOffset && selection.$from.marks();
        if (marks) {
          const filteredMarks = marks.filter((mark) => splittableMarks.includes(mark.type.name));
          tr.ensureMarks(filteredMarks);
        }
      }
      if (config.keepAttributes) {
        const nodeType = config.type.name === "bulletList" || config.type.name === "orderedList" ? "listItem" : "taskList";
        chain().updateAttributes(nodeType, attributes).run();
      }
      const before = tr.doc.resolve(range.from - 1).nodeBefore;
      if (before && before.type === config.type && canJoin(tr.doc, range.from - 1) && (!config.joinPredicate || config.joinPredicate(match, before))) {
        tr.join(range.from - 1);
      }
    }
  });
}
class Node {
  constructor(config = {}) {
    this.type = "node";
    this.name = "node";
    this.parent = null;
    this.child = null;
    this.config = {
      name: this.name,
      defaultOptions: {}
    };
    this.config = {
      ...this.config,
      ...config
    };
    this.name = this.config.name;
    if (config.defaultOptions && Object.keys(config.defaultOptions).length > 0) {
      console.warn(`[tiptap warn]: BREAKING CHANGE: "defaultOptions" is deprecated. Please use "addOptions" instead. Found in extension: "${this.name}".`);
    }
    this.options = this.config.defaultOptions;
    if (this.config.addOptions) {
      this.options = callOrReturn(getExtensionField(this, "addOptions", {
        name: this.name
      }));
    }
    this.storage = callOrReturn(getExtensionField(this, "addStorage", {
      name: this.name,
      options: this.options
    })) || {};
  }
  static create(config = {}) {
    return new Node(config);
  }
  configure(options = {}) {
    const extension = this.extend({
      ...this.config,
      addOptions: () => {
        return mergeDeep(this.options, options);
      }
    });
    extension.name = this.name;
    extension.parent = this.parent;
    return extension;
  }
  extend(extendedConfig = {}) {
    const extension = new Node(extendedConfig);
    extension.parent = this;
    this.child = extension;
    extension.name = extendedConfig.name ? extendedConfig.name : extension.parent.name;
    if (extendedConfig.defaultOptions && Object.keys(extendedConfig.defaultOptions).length > 0) {
      console.warn(`[tiptap warn]: BREAKING CHANGE: "defaultOptions" is deprecated. Please use "addOptions" instead. Found in extension: "${extension.name}".`);
    }
    extension.options = callOrReturn(getExtensionField(extension, "addOptions", {
      name: extension.name
    }));
    extension.storage = callOrReturn(getExtensionField(extension, "addStorage", {
      name: extension.name,
      options: extension.options
    }));
    return extension;
  }
}
function markPasteRule(config) {
  return new PasteRule({
    find: config.find,
    handler: ({ state, range, match, pasteEvent }) => {
      const attributes = callOrReturn(config.getAttributes, void 0, match, pasteEvent);
      if (attributes === false || attributes === null) {
        return null;
      }
      const { tr } = state;
      const captureGroup = match[match.length - 1];
      const fullMatch = match[0];
      let markEnd = range.to;
      if (captureGroup) {
        const startSpaces = fullMatch.search(/\S/);
        const textStart = range.from + fullMatch.indexOf(captureGroup);
        const textEnd = textStart + captureGroup.length;
        const excludedMarks = getMarksBetween(range.from, range.to, state.doc).filter((item) => {
          const excluded = item.mark.type.excluded;
          return excluded.find((type) => type === config.type && type !== item.mark.type);
        }).filter((item) => item.to > textStart);
        if (excludedMarks.length) {
          return null;
        }
        if (textEnd < range.to) {
          tr.delete(textEnd, range.to);
        }
        if (textStart > range.from) {
          tr.delete(range.from + startSpaces, textStart);
        }
        markEnd = range.from + startSpaces + captureGroup.length;
        tr.addMark(range.from + startSpaces, markEnd, config.type.create(attributes || {}));
        tr.removeStoredMark(config.type);
      }
    }
  });
}
function canInsertNode(state, nodeType) {
  const { selection } = state;
  const { $from } = selection;
  if (selection instanceof NodeSelection) {
    const index2 = $from.index();
    const parent = $from.parent;
    return parent.canReplaceWith(index2, index2 + 1, nodeType);
  }
  let depth = $from.depth;
  while (depth >= 0) {
    const index2 = $from.index(depth);
    const parent = $from.node(depth);
    const match = parent.contentMatchAt(index2);
    if (match.matchType(nodeType)) {
      return true;
    }
    depth -= 1;
  }
  return false;
}
defineComponent({
  name: "BubbleMenu",
  props: {
    pluginKey: {
      type: [String, Object],
      default: "bubbleMenu"
    },
    editor: {
      type: Object,
      required: true
    },
    updateDelay: {
      type: Number,
      default: void 0
    },
    tippyOptions: {
      type: Object,
      default: () => ({})
    },
    shouldShow: {
      type: Function,
      default: null
    }
  },
  setup(props, { slots }) {
    const root = ref(null);
    return () => {
      var _a;
      return h("div", { ref: root }, (_a = slots.default) === null || _a === void 0 ? void 0 : _a.call(slots));
    };
  }
});
const EditorContent = defineComponent({
  name: "EditorContent",
  props: {
    editor: {
      default: null,
      type: Object
    }
  },
  setup(props) {
    const rootEl = ref();
    const instance = getCurrentInstance();
    watchEffect(() => {
      const editor = props.editor;
      if (editor && editor.options.element && rootEl.value) {
        nextTick(() => {
          if (!rootEl.value || !editor.options.element.firstChild) {
            return;
          }
          const element = unref(rootEl.value);
          rootEl.value.append(...editor.options.element.childNodes);
          editor.contentComponent = instance.ctx._;
          if (instance) {
            editor.appContext = {
              ...instance.appContext,
              // Vue internally uses prototype chain to forward/shadow injects across the entire component chain
              // so don't use object spread operator or 'Object.assign' and just set `provides` as is on editor's appContext
              // @ts-expect-error forward instance's 'provides' into appContext
              provides: instance.provides
            };
          }
          editor.setOptions({
            element
          });
          editor.createNodeViews();
        });
      }
    });
    return { rootEl };
  },
  render() {
    return h("div", {
      ref: (el) => {
        this.rootEl = el;
      }
    });
  }
});
defineComponent({
  name: "FloatingMenu",
  props: {
    pluginKey: {
      // TODO: TypeScript breaks :(
      // type: [String, Object as PropType<Exclude<FloatingMenuPluginProps['pluginKey'], string>>],
      type: null,
      default: "floatingMenu"
    },
    editor: {
      type: Object,
      required: true
    },
    tippyOptions: {
      type: Object,
      default: () => ({})
    },
    shouldShow: {
      type: Function,
      default: null
    }
  },
  setup(props, { slots }) {
    const root = ref(null);
    return () => {
      var _a;
      return h("div", { ref: root }, (_a = slots.default) === null || _a === void 0 ? void 0 : _a.call(slots));
    };
  }
});
defineComponent({
  name: "NodeViewContent",
  props: {
    as: {
      type: String,
      default: "div"
    }
  },
  render() {
    return h(this.as, {
      style: {
        whiteSpace: "pre-wrap"
      },
      "data-node-view-content": ""
    });
  }
});
defineComponent({
  name: "NodeViewWrapper",
  props: {
    as: {
      type: String,
      default: "div"
    }
  },
  inject: ["onDragStart", "decorationClasses"],
  render() {
    var _a, _b;
    return h(this.as, {
      // @ts-ignore
      class: this.decorationClasses,
      style: {
        whiteSpace: "normal"
      },
      "data-node-view-wrapper": "",
      // @ts-ignore (https://github.com/vuejs/vue-next/issues/3031)
      onDragstart: this.onDragStart
    }, (_b = (_a = this.$slots).default) === null || _b === void 0 ? void 0 : _b.call(_a));
  }
});
const inputRegex$5 = /^\s*>\s$/;
const Blockquote = Node.create({
  name: "blockquote",
  addOptions() {
    return {
      HTMLAttributes: {}
    };
  },
  content: "block+",
  group: "block",
  defining: true,
  parseHTML() {
    return [
      { tag: "blockquote" }
    ];
  },
  renderHTML({ HTMLAttributes }) {
    return ["blockquote", mergeAttributes(this.options.HTMLAttributes, HTMLAttributes), 0];
  },
  addCommands() {
    return {
      setBlockquote: () => ({ commands: commands2 }) => {
        return commands2.wrapIn(this.name);
      },
      toggleBlockquote: () => ({ commands: commands2 }) => {
        return commands2.toggleWrap(this.name);
      },
      unsetBlockquote: () => ({ commands: commands2 }) => {
        return commands2.lift(this.name);
      }
    };
  },
  addKeyboardShortcuts() {
    return {
      "Mod-Shift-b": () => this.editor.commands.toggleBlockquote()
    };
  },
  addInputRules() {
    return [
      wrappingInputRule({
        find: inputRegex$5,
        type: this.type
      })
    ];
  }
});
const starInputRegex$1 = /(?:^|\s)(\*\*(?!\s+\*\*)((?:[^*]+))\*\*(?!\s+\*\*))$/;
const starPasteRegex$1 = /(?:^|\s)(\*\*(?!\s+\*\*)((?:[^*]+))\*\*(?!\s+\*\*))/g;
const underscoreInputRegex$1 = /(?:^|\s)(__(?!\s+__)((?:[^_]+))__(?!\s+__))$/;
const underscorePasteRegex$1 = /(?:^|\s)(__(?!\s+__)((?:[^_]+))__(?!\s+__))/g;
const Bold = Mark.create({
  name: "bold",
  addOptions() {
    return {
      HTMLAttributes: {}
    };
  },
  parseHTML() {
    return [
      {
        tag: "strong"
      },
      {
        tag: "b",
        getAttrs: (node) => node.style.fontWeight !== "normal" && null
      },
      {
        style: "font-weight=400",
        clearMark: (mark) => mark.type.name === this.name
      },
      {
        style: "font-weight",
        getAttrs: (value) => /^(bold(er)?|[5-9]\d{2,})$/.test(value) && null
      }
    ];
  },
  renderHTML({ HTMLAttributes }) {
    return ["strong", mergeAttributes(this.options.HTMLAttributes, HTMLAttributes), 0];
  },
  addCommands() {
    return {
      setBold: () => ({ commands: commands2 }) => {
        return commands2.setMark(this.name);
      },
      toggleBold: () => ({ commands: commands2 }) => {
        return commands2.toggleMark(this.name);
      },
      unsetBold: () => ({ commands: commands2 }) => {
        return commands2.unsetMark(this.name);
      }
    };
  },
  addKeyboardShortcuts() {
    return {
      "Mod-b": () => this.editor.commands.toggleBold(),
      "Mod-B": () => this.editor.commands.toggleBold()
    };
  },
  addInputRules() {
    return [
      markInputRule({
        find: starInputRegex$1,
        type: this.type
      }),
      markInputRule({
        find: underscoreInputRegex$1,
        type: this.type
      })
    ];
  },
  addPasteRules() {
    return [
      markPasteRule({
        find: starPasteRegex$1,
        type: this.type
      }),
      markPasteRule({
        find: underscorePasteRegex$1,
        type: this.type
      })
    ];
  }
});
const ListItemName$1 = "listItem";
const TextStyleName$1 = "textStyle";
const inputRegex$4 = /^\s*([-+*])\s$/;
const BulletList = Node.create({
  name: "bulletList",
  addOptions() {
    return {
      itemTypeName: "listItem",
      HTMLAttributes: {},
      keepMarks: false,
      keepAttributes: false
    };
  },
  group: "block list",
  content() {
    return `${this.options.itemTypeName}+`;
  },
  parseHTML() {
    return [
      { tag: "ul" }
    ];
  },
  renderHTML({ HTMLAttributes }) {
    return ["ul", mergeAttributes(this.options.HTMLAttributes, HTMLAttributes), 0];
  },
  addCommands() {
    return {
      toggleBulletList: () => ({ commands: commands2, chain }) => {
        if (this.options.keepAttributes) {
          return chain().toggleList(this.name, this.options.itemTypeName, this.options.keepMarks).updateAttributes(ListItemName$1, this.editor.getAttributes(TextStyleName$1)).run();
        }
        return commands2.toggleList(this.name, this.options.itemTypeName, this.options.keepMarks);
      }
    };
  },
  addKeyboardShortcuts() {
    return {
      "Mod-Shift-8": () => this.editor.commands.toggleBulletList()
    };
  },
  addInputRules() {
    let inputRule = wrappingInputRule({
      find: inputRegex$4,
      type: this.type
    });
    if (this.options.keepMarks || this.options.keepAttributes) {
      inputRule = wrappingInputRule({
        find: inputRegex$4,
        type: this.type,
        keepMarks: this.options.keepMarks,
        keepAttributes: this.options.keepAttributes,
        getAttributes: () => {
          return this.editor.getAttributes(TextStyleName$1);
        },
        editor: this.editor
      });
    }
    return [
      inputRule
    ];
  }
});
const inputRegex$3 = /(^|[^`])`([^`]+)`(?!`)/;
const pasteRegex$1 = /(^|[^`])`([^`]+)`(?!`)/g;
const Code = Mark.create({
  name: "code",
  addOptions() {
    return {
      HTMLAttributes: {}
    };
  },
  excludes: "_",
  code: true,
  exitable: true,
  parseHTML() {
    return [
      { tag: "code" }
    ];
  },
  renderHTML({ HTMLAttributes }) {
    return ["code", mergeAttributes(this.options.HTMLAttributes, HTMLAttributes), 0];
  },
  addCommands() {
    return {
      setCode: () => ({ commands: commands2 }) => {
        return commands2.setMark(this.name);
      },
      toggleCode: () => ({ commands: commands2 }) => {
        return commands2.toggleMark(this.name);
      },
      unsetCode: () => ({ commands: commands2 }) => {
        return commands2.unsetMark(this.name);
      }
    };
  },
  addKeyboardShortcuts() {
    return {
      "Mod-e": () => this.editor.commands.toggleCode()
    };
  },
  addInputRules() {
    return [
      markInputRule({
        find: inputRegex$3,
        type: this.type
      })
    ];
  },
  addPasteRules() {
    return [
      markPasteRule({
        find: pasteRegex$1,
        type: this.type
      })
    ];
  }
});
const backtickInputRegex = /^```([a-z]+)?[\s\n]$/;
const tildeInputRegex = /^~~~([a-z]+)?[\s\n]$/;
const CodeBlock = Node.create({
  name: "codeBlock",
  addOptions() {
    return {
      languageClassPrefix: "language-",
      exitOnTripleEnter: true,
      exitOnArrowDown: true,
      defaultLanguage: null,
      HTMLAttributes: {}
    };
  },
  content: "text*",
  marks: "",
  group: "block",
  code: true,
  defining: true,
  addAttributes() {
    return {
      language: {
        default: this.options.defaultLanguage,
        parseHTML: (element) => {
          var _a;
          const { languageClassPrefix } = this.options;
          const classNames = [...((_a = element.firstElementChild) === null || _a === void 0 ? void 0 : _a.classList) || []];
          const languages = classNames.filter((className) => className.startsWith(languageClassPrefix)).map((className) => className.replace(languageClassPrefix, ""));
          const language = languages[0];
          if (!language) {
            return null;
          }
          return language;
        },
        rendered: false
      }
    };
  },
  parseHTML() {
    return [
      {
        tag: "pre",
        preserveWhitespace: "full"
      }
    ];
  },
  renderHTML({ node, HTMLAttributes }) {
    return [
      "pre",
      mergeAttributes(this.options.HTMLAttributes, HTMLAttributes),
      [
        "code",
        {
          class: node.attrs.language ? this.options.languageClassPrefix + node.attrs.language : null
        },
        0
      ]
    ];
  },
  addCommands() {
    return {
      setCodeBlock: (attributes) => ({ commands: commands2 }) => {
        return commands2.setNode(this.name, attributes);
      },
      toggleCodeBlock: (attributes) => ({ commands: commands2 }) => {
        return commands2.toggleNode(this.name, "paragraph", attributes);
      }
    };
  },
  addKeyboardShortcuts() {
    return {
      "Mod-Alt-c": () => this.editor.commands.toggleCodeBlock(),
      // remove code block when at start of document or code block is empty
      Backspace: () => {
        const { empty, $anchor } = this.editor.state.selection;
        const isAtStart = $anchor.pos === 1;
        if (!empty || $anchor.parent.type.name !== this.name) {
          return false;
        }
        if (isAtStart || !$anchor.parent.textContent.length) {
          return this.editor.commands.clearNodes();
        }
        return false;
      },
      // exit node on triple enter
      Enter: ({ editor }) => {
        if (!this.options.exitOnTripleEnter) {
          return false;
        }
        const { state } = editor;
        const { selection } = state;
        const { $from, empty } = selection;
        if (!empty || $from.parent.type !== this.type) {
          return false;
        }
        const isAtEnd = $from.parentOffset === $from.parent.nodeSize - 2;
        const endsWithDoubleNewline = $from.parent.textContent.endsWith("\n\n");
        if (!isAtEnd || !endsWithDoubleNewline) {
          return false;
        }
        return editor.chain().command(({ tr }) => {
          tr.delete($from.pos - 2, $from.pos);
          return true;
        }).exitCode().run();
      },
      // exit node on arrow down
      ArrowDown: ({ editor }) => {
        if (!this.options.exitOnArrowDown) {
          return false;
        }
        const { state } = editor;
        const { selection, doc } = state;
        const { $from, empty } = selection;
        if (!empty || $from.parent.type !== this.type) {
          return false;
        }
        const isAtEnd = $from.parentOffset === $from.parent.nodeSize - 2;
        if (!isAtEnd) {
          return false;
        }
        const after = $from.after();
        if (after === void 0) {
          return false;
        }
        const nodeAfter = doc.nodeAt(after);
        if (nodeAfter) {
          return editor.commands.command(({ tr }) => {
            tr.setSelection(Selection.near(doc.resolve(after)));
            return true;
          });
        }
        return editor.commands.exitCode();
      }
    };
  },
  addInputRules() {
    return [
      textblockTypeInputRule({
        find: backtickInputRegex,
        type: this.type,
        getAttributes: (match) => ({
          language: match[1]
        })
      }),
      textblockTypeInputRule({
        find: tildeInputRegex,
        type: this.type,
        getAttributes: (match) => ({
          language: match[1]
        })
      })
    ];
  },
  addProseMirrorPlugins() {
    return [
      // this plugin creates a code block for pasted content from VS Code
      // we can also detect the copied code language
      new Plugin({
        key: new PluginKey("codeBlockVSCodeHandler"),
        props: {
          handlePaste: (view, event) => {
            if (!event.clipboardData) {
              return false;
            }
            if (this.editor.isActive(this.type.name)) {
              return false;
            }
            const text = event.clipboardData.getData("text/plain");
            const vscode = event.clipboardData.getData("vscode-editor-data");
            const vscodeData = vscode ? JSON.parse(vscode) : void 0;
            const language = vscodeData === null || vscodeData === void 0 ? void 0 : vscodeData.mode;
            if (!text || !language) {
              return false;
            }
            const { tr, schema } = view.state;
            const textNode = schema.text(text.replace(/\r\n?/g, "\n"));
            tr.replaceSelectionWith(this.type.create({ language }, textNode));
            if (tr.selection.$from.parent.type !== this.type) {
              tr.setSelection(TextSelection.near(tr.doc.resolve(Math.max(0, tr.selection.from - 2))));
            }
            tr.setMeta("paste", true);
            view.dispatch(tr);
            return true;
          }
        }
      })
    ];
  }
});
const Document = Node.create({
  name: "doc",
  topNode: true,
  content: "block+"
});
const Dropcursor = Extension.create({
  name: "dropCursor",
  addOptions() {
    return {
      color: "currentColor",
      width: 1,
      class: void 0
    };
  },
  addProseMirrorPlugins() {
    return [
      dropCursor(this.options)
    ];
  }
});
const Gapcursor = Extension.create({
  name: "gapCursor",
  addProseMirrorPlugins() {
    return [
      gapCursor()
    ];
  },
  extendNodeSchema(extension) {
    var _a;
    const context = {
      name: extension.name,
      options: extension.options,
      storage: extension.storage
    };
    return {
      allowGapCursor: (_a = callOrReturn(getExtensionField(extension, "allowGapCursor", context))) !== null && _a !== void 0 ? _a : null
    };
  }
});
const HardBreak = Node.create({
  name: "hardBreak",
  addOptions() {
    return {
      keepMarks: true,
      HTMLAttributes: {}
    };
  },
  inline: true,
  group: "inline",
  selectable: false,
  linebreakReplacement: true,
  parseHTML() {
    return [
      { tag: "br" }
    ];
  },
  renderHTML({ HTMLAttributes }) {
    return ["br", mergeAttributes(this.options.HTMLAttributes, HTMLAttributes)];
  },
  renderText() {
    return "\n";
  },
  addCommands() {
    return {
      setHardBreak: () => ({ commands: commands2, chain, state, editor }) => {
        return commands2.first([
          () => commands2.exitCode(),
          () => commands2.command(() => {
            const { selection, storedMarks } = state;
            if (selection.$from.parent.type.spec.isolating) {
              return false;
            }
            const { keepMarks } = this.options;
            const { splittableMarks } = editor.extensionManager;
            const marks = storedMarks || selection.$to.parentOffset && selection.$from.marks();
            return chain().insertContent({ type: this.name }).command(({ tr, dispatch }) => {
              if (dispatch && marks && keepMarks) {
                const filteredMarks = marks.filter((mark) => splittableMarks.includes(mark.type.name));
                tr.ensureMarks(filteredMarks);
              }
              return true;
            }).run();
          })
        ]);
      }
    };
  },
  addKeyboardShortcuts() {
    return {
      "Mod-Enter": () => this.editor.commands.setHardBreak(),
      "Shift-Enter": () => this.editor.commands.setHardBreak()
    };
  }
});
const Heading = Node.create({
  name: "heading",
  addOptions() {
    return {
      levels: [1, 2, 3, 4, 5, 6],
      HTMLAttributes: {}
    };
  },
  content: "inline*",
  group: "block",
  defining: true,
  addAttributes() {
    return {
      level: {
        default: 1,
        rendered: false
      }
    };
  },
  parseHTML() {
    return this.options.levels.map((level) => ({
      tag: `h${level}`,
      attrs: { level }
    }));
  },
  renderHTML({ node, HTMLAttributes }) {
    const hasLevel = this.options.levels.includes(node.attrs.level);
    const level = hasLevel ? node.attrs.level : this.options.levels[0];
    return [`h${level}`, mergeAttributes(this.options.HTMLAttributes, HTMLAttributes), 0];
  },
  addCommands() {
    return {
      setHeading: (attributes) => ({ commands: commands2 }) => {
        if (!this.options.levels.includes(attributes.level)) {
          return false;
        }
        return commands2.setNode(this.name, attributes);
      },
      toggleHeading: (attributes) => ({ commands: commands2 }) => {
        if (!this.options.levels.includes(attributes.level)) {
          return false;
        }
        return commands2.toggleNode(this.name, "paragraph", attributes);
      }
    };
  },
  addKeyboardShortcuts() {
    return this.options.levels.reduce((items, level) => ({
      ...items,
      ...{
        [`Mod-Alt-${level}`]: () => this.editor.commands.toggleHeading({ level })
      }
    }), {});
  },
  addInputRules() {
    return this.options.levels.map((level) => {
      return textblockTypeInputRule({
        find: new RegExp(`^(#{${Math.min(...this.options.levels)},${level}})\\s$`),
        type: this.type,
        getAttributes: {
          level
        }
      });
    });
  }
});
const History = Extension.create({
  name: "history",
  addOptions() {
    return {
      depth: 100,
      newGroupDelay: 500
    };
  },
  addCommands() {
    return {
      undo: () => ({ state, dispatch }) => {
        return undo(state, dispatch);
      },
      redo: () => ({ state, dispatch }) => {
        return redo(state, dispatch);
      }
    };
  },
  addProseMirrorPlugins() {
    return [
      history(this.options)
    ];
  },
  addKeyboardShortcuts() {
    return {
      "Mod-z": () => this.editor.commands.undo(),
      "Shift-Mod-z": () => this.editor.commands.redo(),
      "Mod-y": () => this.editor.commands.redo(),
      // Russian keyboard layouts
      "Mod-\u044F": () => this.editor.commands.undo(),
      "Shift-Mod-\u044F": () => this.editor.commands.redo()
    };
  }
});
const HorizontalRule = Node.create({
  name: "horizontalRule",
  addOptions() {
    return {
      HTMLAttributes: {}
    };
  },
  group: "block",
  parseHTML() {
    return [{ tag: "hr" }];
  },
  renderHTML({ HTMLAttributes }) {
    return ["hr", mergeAttributes(this.options.HTMLAttributes, HTMLAttributes)];
  },
  addCommands() {
    return {
      setHorizontalRule: () => ({ chain, state }) => {
        if (!canInsertNode(state, state.schema.nodes[this.name])) {
          return false;
        }
        const { selection } = state;
        const { $from: $originFrom, $to: $originTo } = selection;
        const currentChain = chain();
        if ($originFrom.parentOffset === 0) {
          currentChain.insertContentAt({
            from: Math.max($originFrom.pos - 1, 0),
            to: $originTo.pos
          }, {
            type: this.name
          });
        } else if (isNodeSelection(selection)) {
          currentChain.insertContentAt($originTo.pos, {
            type: this.name
          });
        } else {
          currentChain.insertContent({ type: this.name });
        }
        return currentChain.command(({ tr, dispatch }) => {
          var _a;
          if (dispatch) {
            const { $to } = tr.selection;
            const posAfter = $to.end();
            if ($to.nodeAfter) {
              if ($to.nodeAfter.isTextblock) {
                tr.setSelection(TextSelection.create(tr.doc, $to.pos + 1));
              } else if ($to.nodeAfter.isBlock) {
                tr.setSelection(NodeSelection.create(tr.doc, $to.pos));
              } else {
                tr.setSelection(TextSelection.create(tr.doc, $to.pos));
              }
            } else {
              const node = (_a = $to.parent.type.contentMatch.defaultType) === null || _a === void 0 ? void 0 : _a.create();
              if (node) {
                tr.insert(posAfter, node);
                tr.setSelection(TextSelection.create(tr.doc, posAfter + 1));
              }
            }
            tr.scrollIntoView();
          }
          return true;
        }).run();
      }
    };
  },
  addInputRules() {
    return [
      nodeInputRule({
        find: /^(?:---|—-|___\s|\*\*\*\s)$/,
        type: this.type
      })
    ];
  }
});
const starInputRegex = /(?:^|\s)(\*(?!\s+\*)((?:[^*]+))\*(?!\s+\*))$/;
const starPasteRegex = /(?:^|\s)(\*(?!\s+\*)((?:[^*]+))\*(?!\s+\*))/g;
const underscoreInputRegex = /(?:^|\s)(_(?!\s+_)((?:[^_]+))_(?!\s+_))$/;
const underscorePasteRegex = /(?:^|\s)(_(?!\s+_)((?:[^_]+))_(?!\s+_))/g;
const Italic = Mark.create({
  name: "italic",
  addOptions() {
    return {
      HTMLAttributes: {}
    };
  },
  parseHTML() {
    return [
      {
        tag: "em"
      },
      {
        tag: "i",
        getAttrs: (node) => node.style.fontStyle !== "normal" && null
      },
      {
        style: "font-style=normal",
        clearMark: (mark) => mark.type.name === this.name
      },
      {
        style: "font-style=italic"
      }
    ];
  },
  renderHTML({ HTMLAttributes }) {
    return ["em", mergeAttributes(this.options.HTMLAttributes, HTMLAttributes), 0];
  },
  addCommands() {
    return {
      setItalic: () => ({ commands: commands2 }) => {
        return commands2.setMark(this.name);
      },
      toggleItalic: () => ({ commands: commands2 }) => {
        return commands2.toggleMark(this.name);
      },
      unsetItalic: () => ({ commands: commands2 }) => {
        return commands2.unsetMark(this.name);
      }
    };
  },
  addKeyboardShortcuts() {
    return {
      "Mod-i": () => this.editor.commands.toggleItalic(),
      "Mod-I": () => this.editor.commands.toggleItalic()
    };
  },
  addInputRules() {
    return [
      markInputRule({
        find: starInputRegex,
        type: this.type
      }),
      markInputRule({
        find: underscoreInputRegex,
        type: this.type
      })
    ];
  },
  addPasteRules() {
    return [
      markPasteRule({
        find: starPasteRegex,
        type: this.type
      }),
      markPasteRule({
        find: underscorePasteRegex,
        type: this.type
      })
    ];
  }
});
const ListItem = Node.create({
  name: "listItem",
  addOptions() {
    return {
      HTMLAttributes: {},
      bulletListTypeName: "bulletList",
      orderedListTypeName: "orderedList"
    };
  },
  content: "paragraph block*",
  defining: true,
  parseHTML() {
    return [
      {
        tag: "li"
      }
    ];
  },
  renderHTML({ HTMLAttributes }) {
    return ["li", mergeAttributes(this.options.HTMLAttributes, HTMLAttributes), 0];
  },
  addKeyboardShortcuts() {
    return {
      Enter: () => this.editor.commands.splitListItem(this.name),
      Tab: () => this.editor.commands.sinkListItem(this.name),
      "Shift-Tab": () => this.editor.commands.liftListItem(this.name)
    };
  }
});
const ListItemName = "listItem";
const TextStyleName = "textStyle";
const inputRegex$2 = /^(\d+)\.\s$/;
const OrderedList = Node.create({
  name: "orderedList",
  addOptions() {
    return {
      itemTypeName: "listItem",
      HTMLAttributes: {},
      keepMarks: false,
      keepAttributes: false
    };
  },
  group: "block list",
  content() {
    return `${this.options.itemTypeName}+`;
  },
  addAttributes() {
    return {
      start: {
        default: 1,
        parseHTML: (element) => {
          return element.hasAttribute("start") ? parseInt(element.getAttribute("start") || "", 10) : 1;
        }
      },
      type: {
        default: null,
        parseHTML: (element) => element.getAttribute("type")
      }
    };
  },
  parseHTML() {
    return [
      {
        tag: "ol"
      }
    ];
  },
  renderHTML({ HTMLAttributes }) {
    const { start, ...attributesWithoutStart } = HTMLAttributes;
    return start === 1 ? ["ol", mergeAttributes(this.options.HTMLAttributes, attributesWithoutStart), 0] : ["ol", mergeAttributes(this.options.HTMLAttributes, HTMLAttributes), 0];
  },
  addCommands() {
    return {
      toggleOrderedList: () => ({ commands: commands2, chain }) => {
        if (this.options.keepAttributes) {
          return chain().toggleList(this.name, this.options.itemTypeName, this.options.keepMarks).updateAttributes(ListItemName, this.editor.getAttributes(TextStyleName)).run();
        }
        return commands2.toggleList(this.name, this.options.itemTypeName, this.options.keepMarks);
      }
    };
  },
  addKeyboardShortcuts() {
    return {
      "Mod-Shift-7": () => this.editor.commands.toggleOrderedList()
    };
  },
  addInputRules() {
    let inputRule = wrappingInputRule({
      find: inputRegex$2,
      type: this.type,
      getAttributes: (match) => ({ start: +match[1] }),
      joinPredicate: (match, node) => node.childCount + node.attrs.start === +match[1]
    });
    if (this.options.keepMarks || this.options.keepAttributes) {
      inputRule = wrappingInputRule({
        find: inputRegex$2,
        type: this.type,
        keepMarks: this.options.keepMarks,
        keepAttributes: this.options.keepAttributes,
        getAttributes: (match) => ({ start: +match[1], ...this.editor.getAttributes(TextStyleName) }),
        joinPredicate: (match, node) => node.childCount + node.attrs.start === +match[1],
        editor: this.editor
      });
    }
    return [
      inputRule
    ];
  }
});
const Paragraph = Node.create({
  name: "paragraph",
  priority: 1e3,
  addOptions() {
    return {
      HTMLAttributes: {}
    };
  },
  group: "block",
  content: "inline*",
  parseHTML() {
    return [
      { tag: "p" }
    ];
  },
  renderHTML({ HTMLAttributes }) {
    return ["p", mergeAttributes(this.options.HTMLAttributes, HTMLAttributes), 0];
  },
  addCommands() {
    return {
      setParagraph: () => ({ commands: commands2 }) => {
        return commands2.setNode(this.name);
      }
    };
  },
  addKeyboardShortcuts() {
    return {
      "Mod-Alt-0": () => this.editor.commands.setParagraph()
    };
  }
});
const inputRegex$1 = /(?:^|\s)(~~(?!\s+~~)((?:[^~]+))~~(?!\s+~~))$/;
const pasteRegex = /(?:^|\s)(~~(?!\s+~~)((?:[^~]+))~~(?!\s+~~))/g;
const Strike = Mark.create({
  name: "strike",
  addOptions() {
    return {
      HTMLAttributes: {}
    };
  },
  parseHTML() {
    return [
      {
        tag: "s"
      },
      {
        tag: "del"
      },
      {
        tag: "strike"
      },
      {
        style: "text-decoration",
        consuming: false,
        getAttrs: (style) => style.includes("line-through") ? {} : false
      }
    ];
  },
  renderHTML({ HTMLAttributes }) {
    return ["s", mergeAttributes(this.options.HTMLAttributes, HTMLAttributes), 0];
  },
  addCommands() {
    return {
      setStrike: () => ({ commands: commands2 }) => {
        return commands2.setMark(this.name);
      },
      toggleStrike: () => ({ commands: commands2 }) => {
        return commands2.toggleMark(this.name);
      },
      unsetStrike: () => ({ commands: commands2 }) => {
        return commands2.unsetMark(this.name);
      }
    };
  },
  addKeyboardShortcuts() {
    return {
      "Mod-Shift-s": () => this.editor.commands.toggleStrike()
    };
  },
  addInputRules() {
    return [
      markInputRule({
        find: inputRegex$1,
        type: this.type
      })
    ];
  },
  addPasteRules() {
    return [
      markPasteRule({
        find: pasteRegex,
        type: this.type
      })
    ];
  }
});
const Text = Node.create({
  name: "text",
  group: "inline"
});
Extension.create({
  name: "starterKit",
  addExtensions() {
    const extensions = [];
    if (this.options.bold !== false) {
      extensions.push(Bold.configure(this.options.bold));
    }
    if (this.options.blockquote !== false) {
      extensions.push(Blockquote.configure(this.options.blockquote));
    }
    if (this.options.bulletList !== false) {
      extensions.push(BulletList.configure(this.options.bulletList));
    }
    if (this.options.code !== false) {
      extensions.push(Code.configure(this.options.code));
    }
    if (this.options.codeBlock !== false) {
      extensions.push(CodeBlock.configure(this.options.codeBlock));
    }
    if (this.options.document !== false) {
      extensions.push(Document.configure(this.options.document));
    }
    if (this.options.dropcursor !== false) {
      extensions.push(Dropcursor.configure(this.options.dropcursor));
    }
    if (this.options.gapcursor !== false) {
      extensions.push(Gapcursor.configure(this.options.gapcursor));
    }
    if (this.options.hardBreak !== false) {
      extensions.push(HardBreak.configure(this.options.hardBreak));
    }
    if (this.options.heading !== false) {
      extensions.push(Heading.configure(this.options.heading));
    }
    if (this.options.history !== false) {
      extensions.push(History.configure(this.options.history));
    }
    if (this.options.horizontalRule !== false) {
      extensions.push(HorizontalRule.configure(this.options.horizontalRule));
    }
    if (this.options.italic !== false) {
      extensions.push(Italic.configure(this.options.italic));
    }
    if (this.options.listItem !== false) {
      extensions.push(ListItem.configure(this.options.listItem));
    }
    if (this.options.orderedList !== false) {
      extensions.push(OrderedList.configure(this.options.orderedList));
    }
    if (this.options.paragraph !== false) {
      extensions.push(Paragraph.configure(this.options.paragraph));
    }
    if (this.options.strike !== false) {
      extensions.push(Strike.configure(this.options.strike));
    }
    if (this.options.text !== false) {
      extensions.push(Text.configure(this.options.text));
    }
    return extensions;
  }
});
Extension.create({
  name: "textAlign",
  addOptions() {
    return {
      types: [],
      alignments: ["left", "center", "right", "justify"],
      defaultAlignment: null
    };
  },
  addGlobalAttributes() {
    return [
      {
        types: this.options.types,
        attributes: {
          textAlign: {
            default: this.options.defaultAlignment,
            parseHTML: (element) => {
              const alignment = element.style.textAlign;
              return this.options.alignments.includes(alignment) ? alignment : this.options.defaultAlignment;
            },
            renderHTML: (attributes) => {
              if (!attributes.textAlign) {
                return {};
              }
              return { style: `text-align: ${attributes.textAlign}` };
            }
          }
        }
      }
    ];
  },
  addCommands() {
    return {
      setTextAlign: (alignment) => ({ commands: commands2 }) => {
        if (!this.options.alignments.includes(alignment)) {
          return false;
        }
        return this.options.types.map((type) => commands2.updateAttributes(type, { textAlign: alignment })).every((response) => response);
      },
      unsetTextAlign: () => ({ commands: commands2 }) => {
        return this.options.types.map((type) => commands2.resetAttributes(type, "textAlign")).every((response) => response);
      },
      toggleTextAlign: (alignment) => ({ editor, commands: commands2 }) => {
        if (!this.options.alignments.includes(alignment)) {
          return false;
        }
        if (editor.isActive({ textAlign: alignment })) {
          return commands2.unsetTextAlign();
        }
        return commands2.setTextAlign(alignment);
      }
    };
  },
  addKeyboardShortcuts() {
    return {
      "Mod-Shift-l": () => this.editor.commands.setTextAlign("left"),
      "Mod-Shift-e": () => this.editor.commands.setTextAlign("center"),
      "Mod-Shift-r": () => this.editor.commands.setTextAlign("right"),
      "Mod-Shift-j": () => this.editor.commands.setTextAlign("justify")
    };
  }
});
const UNICODE_WHITESPACE_PATTERN = "[\0- \xA0\u1680\u180E\u2000-\u2029\u205F\u3000]";
const UNICODE_WHITESPACE_REGEX = new RegExp(UNICODE_WHITESPACE_PATTERN);
const UNICODE_WHITESPACE_REGEX_END = new RegExp(`${UNICODE_WHITESPACE_PATTERN}$`);
const UNICODE_WHITESPACE_REGEX_GLOBAL = new RegExp(UNICODE_WHITESPACE_PATTERN, "g");
function isValidLinkStructure(tokens) {
  if (tokens.length === 1) {
    return tokens[0].isLink;
  }
  if (tokens.length === 3 && tokens[1].isLink) {
    return ["()", "[]"].includes(tokens[0].value + tokens[2].value);
  }
  return false;
}
function autolink(options) {
  return new Plugin({
    key: new PluginKey("autolink"),
    appendTransaction: (transactions, oldState, newState) => {
      const docChanges = transactions.some((transaction) => transaction.docChanged) && !oldState.doc.eq(newState.doc);
      const preventAutolink = transactions.some((transaction) => transaction.getMeta("preventAutolink"));
      if (!docChanges || preventAutolink) {
        return;
      }
      const { tr } = newState;
      const transform = combineTransactionSteps(oldState.doc, [...transactions]);
      const changes = getChangedRanges(transform);
      changes.forEach(({ newRange }) => {
        const nodesInChangedRanges = findChildrenInRange(newState.doc, newRange, (node) => node.isTextblock);
        let textBlock;
        let textBeforeWhitespace;
        if (nodesInChangedRanges.length > 1) {
          textBlock = nodesInChangedRanges[0];
          textBeforeWhitespace = newState.doc.textBetween(textBlock.pos, textBlock.pos + textBlock.node.nodeSize, void 0, " ");
        } else if (nodesInChangedRanges.length) {
          const endText = newState.doc.textBetween(newRange.from, newRange.to, " ", " ");
          if (!UNICODE_WHITESPACE_REGEX_END.test(endText)) {
            return;
          }
          textBlock = nodesInChangedRanges[0];
          textBeforeWhitespace = newState.doc.textBetween(textBlock.pos, newRange.to, void 0, " ");
        }
        if (textBlock && textBeforeWhitespace) {
          const wordsBeforeWhitespace = textBeforeWhitespace.split(UNICODE_WHITESPACE_REGEX).filter(Boolean);
          if (wordsBeforeWhitespace.length <= 0) {
            return false;
          }
          const lastWordBeforeSpace = wordsBeforeWhitespace[wordsBeforeWhitespace.length - 1];
          const lastWordAndBlockOffset = textBlock.pos + textBeforeWhitespace.lastIndexOf(lastWordBeforeSpace);
          if (!lastWordBeforeSpace) {
            return false;
          }
          const linksBeforeSpace = tokenize(lastWordBeforeSpace).map((t) => t.toObject(options.defaultProtocol));
          if (!isValidLinkStructure(linksBeforeSpace)) {
            return false;
          }
          linksBeforeSpace.filter((link) => link.isLink).map((link) => ({
            ...link,
            from: lastWordAndBlockOffset + link.start + 1,
            to: lastWordAndBlockOffset + link.end + 1
          })).filter((link) => {
            if (!newState.schema.marks.code) {
              return true;
            }
            return !newState.doc.rangeHasMark(link.from, link.to, newState.schema.marks.code);
          }).filter((link) => options.validate(link.value)).filter((link) => options.shouldAutoLink(link.value)).forEach((link) => {
            if (getMarksBetween(link.from, link.to, newState.doc).some((item) => item.mark.type === options.type)) {
              return;
            }
            tr.addMark(link.from, link.to, options.type.create({
              href: link.href
            }));
          });
        }
      });
      if (!tr.steps.length) {
        return;
      }
      return tr;
    }
  });
}
function clickHandler(options) {
  return new Plugin({
    key: new PluginKey("handleClickLink"),
    props: {
      handleClick: (view, pos, event) => {
        var _a, _b;
        if (event.button !== 0) {
          return false;
        }
        if (!view.editable) {
          return false;
        }
        let a = event.target;
        const els = [];
        while (a.nodeName !== "DIV") {
          els.push(a);
          a = a.parentNode;
        }
        if (!els.find((value) => value.nodeName === "A")) {
          return false;
        }
        const attrs = getAttributes(view.state, options.type.name);
        const link = event.target;
        const href = (_a = link === null || link === void 0 ? void 0 : link.href) !== null && _a !== void 0 ? _a : attrs.href;
        const target = (_b = link === null || link === void 0 ? void 0 : link.target) !== null && _b !== void 0 ? _b : attrs.target;
        if (link && href) {
          (void 0).open(href, target);
          return true;
        }
        return false;
      }
    }
  });
}
function pasteHandler(options) {
  return new Plugin({
    key: new PluginKey("handlePasteLink"),
    props: {
      handlePaste: (view, event, slice) => {
        const { state } = view;
        const { selection } = state;
        const { empty } = selection;
        if (empty) {
          return false;
        }
        let textContent = "";
        slice.content.forEach((node) => {
          textContent += node.textContent;
        });
        const link = find(textContent, { defaultProtocol: options.defaultProtocol }).find((item) => item.isLink && item.value === textContent);
        if (!textContent || !link) {
          return false;
        }
        return options.editor.commands.setMark(options.type, {
          href: link.href
        });
      }
    }
  });
}
function isAllowedUri(uri, protocols) {
  const allowedProtocols = [
    "http",
    "https",
    "ftp",
    "ftps",
    "mailto",
    "tel",
    "callto",
    "sms",
    "cid",
    "xmpp"
  ];
  if (protocols) {
    protocols.forEach((protocol) => {
      const nextProtocol = typeof protocol === "string" ? protocol : protocol.scheme;
      if (nextProtocol) {
        allowedProtocols.push(nextProtocol);
      }
    });
  }
  return !uri || uri.replace(UNICODE_WHITESPACE_REGEX_GLOBAL, "").match(new RegExp(
    // eslint-disable-next-line no-useless-escape
    `^(?:(?:${allowedProtocols.join("|")}):|[^a-z]|[a-z0-9+.-]+(?:[^a-z+.-:]|$))`,
    "i"
  ));
}
Mark.create({
  name: "link",
  priority: 1e3,
  keepOnSplit: false,
  exitable: true,
  onCreate() {
    if (this.options.validate && !this.options.shouldAutoLink) {
      this.options.shouldAutoLink = this.options.validate;
      console.warn("The `validate` option is deprecated. Rename to the `shouldAutoLink` option instead.");
    }
    this.options.protocols.forEach((protocol) => {
      if (typeof protocol === "string") {
        registerCustomProtocol(protocol);
        return;
      }
      registerCustomProtocol(protocol.scheme, protocol.optionalSlashes);
    });
  },
  onDestroy() {
    reset();
  },
  inclusive() {
    return this.options.autolink;
  },
  addOptions() {
    return {
      openOnClick: true,
      linkOnPaste: true,
      autolink: true,
      protocols: [],
      defaultProtocol: "http",
      HTMLAttributes: {
        target: "_blank",
        rel: "noopener noreferrer nofollow",
        class: null
      },
      isAllowedUri: (url, ctx) => !!isAllowedUri(url, ctx.protocols),
      validate: (url) => !!url,
      shouldAutoLink: (url) => !!url
    };
  },
  addAttributes() {
    return {
      href: {
        default: null,
        parseHTML(element) {
          return element.getAttribute("href");
        }
      },
      target: {
        default: this.options.HTMLAttributes.target
      },
      rel: {
        default: this.options.HTMLAttributes.rel
      },
      class: {
        default: this.options.HTMLAttributes.class
      }
    };
  },
  parseHTML() {
    return [
      {
        tag: "a[href]",
        getAttrs: (dom) => {
          const href = dom.getAttribute("href");
          if (!href || !this.options.isAllowedUri(href, {
            defaultValidate: (url) => !!isAllowedUri(url, this.options.protocols),
            protocols: this.options.protocols,
            defaultProtocol: this.options.defaultProtocol
          })) {
            return false;
          }
          return null;
        }
      }
    ];
  },
  renderHTML({ HTMLAttributes }) {
    if (!this.options.isAllowedUri(HTMLAttributes.href, {
      defaultValidate: (href) => !!isAllowedUri(href, this.options.protocols),
      protocols: this.options.protocols,
      defaultProtocol: this.options.defaultProtocol
    })) {
      return [
        "a",
        mergeAttributes(this.options.HTMLAttributes, { ...HTMLAttributes, href: "" }),
        0
      ];
    }
    return ["a", mergeAttributes(this.options.HTMLAttributes, HTMLAttributes), 0];
  },
  addCommands() {
    return {
      setLink: (attributes) => ({ chain }) => {
        const { href } = attributes;
        if (!this.options.isAllowedUri(href, {
          defaultValidate: (url) => !!isAllowedUri(url, this.options.protocols),
          protocols: this.options.protocols,
          defaultProtocol: this.options.defaultProtocol
        })) {
          return false;
        }
        return chain().setMark(this.name, attributes).setMeta("preventAutolink", true).run();
      },
      toggleLink: (attributes) => ({ chain }) => {
        const { href } = attributes;
        if (!this.options.isAllowedUri(href, {
          defaultValidate: (url) => !!isAllowedUri(url, this.options.protocols),
          protocols: this.options.protocols,
          defaultProtocol: this.options.defaultProtocol
        })) {
          return false;
        }
        return chain().toggleMark(this.name, attributes, { extendEmptyMarkRange: true }).setMeta("preventAutolink", true).run();
      },
      unsetLink: () => ({ chain }) => {
        return chain().unsetMark(this.name, { extendEmptyMarkRange: true }).setMeta("preventAutolink", true).run();
      }
    };
  },
  addPasteRules() {
    return [
      markPasteRule({
        find: (text) => {
          const foundLinks = [];
          if (text) {
            const { protocols, defaultProtocol } = this.options;
            const links = find(text).filter((item) => item.isLink && this.options.isAllowedUri(item.value, {
              defaultValidate: (href) => !!isAllowedUri(href, protocols),
              protocols,
              defaultProtocol
            }));
            if (links.length) {
              links.forEach((link) => foundLinks.push({
                text: link.value,
                data: {
                  href: link.href
                },
                index: link.start
              }));
            }
          }
          return foundLinks;
        },
        type: this.type,
        getAttributes: (match) => {
          var _a;
          return {
            href: (_a = match.data) === null || _a === void 0 ? void 0 : _a.href
          };
        }
      })
    ];
  },
  addProseMirrorPlugins() {
    const plugins = [];
    const { protocols, defaultProtocol } = this.options;
    if (this.options.autolink) {
      plugins.push(autolink({
        type: this.type,
        defaultProtocol: this.options.defaultProtocol,
        validate: (url) => this.options.isAllowedUri(url, {
          defaultValidate: (href) => !!isAllowedUri(href, protocols),
          protocols,
          defaultProtocol
        }),
        shouldAutoLink: this.options.shouldAutoLink
      }));
    }
    if (this.options.openOnClick === true) {
      plugins.push(clickHandler({
        type: this.type
      }));
    }
    if (this.options.linkOnPaste) {
      plugins.push(pasteHandler({
        editor: this.editor,
        defaultProtocol: this.options.defaultProtocol,
        type: this.type
      }));
    }
    return plugins;
  }
});
const inputRegex = /(?:^|\s)(!\[(.+|:?)]\((\S+)(?:(?:\s+)["'](\S+)["'])?\))$/;
Node.create({
  name: "image",
  addOptions() {
    return {
      inline: false,
      allowBase64: false,
      HTMLAttributes: {}
    };
  },
  inline() {
    return this.options.inline;
  },
  group() {
    return this.options.inline ? "inline" : "block";
  },
  draggable: true,
  addAttributes() {
    return {
      src: {
        default: null
      },
      alt: {
        default: null
      },
      title: {
        default: null
      }
    };
  },
  parseHTML() {
    return [
      {
        tag: this.options.allowBase64 ? "img[src]" : 'img[src]:not([src^="data:"])'
      }
    ];
  },
  renderHTML({ HTMLAttributes }) {
    return ["img", mergeAttributes(this.options.HTMLAttributes, HTMLAttributes)];
  },
  addCommands() {
    return {
      setImage: (options) => ({ commands: commands2 }) => {
        return commands2.insertContent({
          type: this.name,
          attrs: options
        });
      }
    };
  },
  addInputRules() {
    return [
      nodeInputRule({
        find: inputRegex,
        type: this.type,
        getAttributes: (match) => {
          const [, , alt, src, title] = match;
          return { src, alt, title };
        }
      })
    ];
  }
});
function getDefaultExportFromCjs(x) {
  return x && x.__esModule && Object.prototype.hasOwnProperty.call(x, "default") ? x["default"] : x;
}
function deepFreeze(obj) {
  if (obj instanceof Map) {
    obj.clear = obj.delete = obj.set = function() {
      throw new Error("map is read-only");
    };
  } else if (obj instanceof Set) {
    obj.add = obj.clear = obj.delete = function() {
      throw new Error("set is read-only");
    };
  }
  Object.freeze(obj);
  Object.getOwnPropertyNames(obj).forEach((name) => {
    const prop = obj[name];
    const type = typeof prop;
    if ((type === "object" || type === "function") && !Object.isFrozen(prop)) {
      deepFreeze(prop);
    }
  });
  return obj;
}
class Response {
  /**
   * @param {CompiledMode} mode
   */
  constructor(mode) {
    if (mode.data === void 0) mode.data = {};
    this.data = mode.data;
    this.isMatchIgnored = false;
  }
  ignoreMatch() {
    this.isMatchIgnored = true;
  }
}
function escapeHTML(value) {
  return value.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;").replace(/"/g, "&quot;").replace(/'/g, "&#x27;");
}
function inherit$1(original, ...objects) {
  const result = /* @__PURE__ */ Object.create(null);
  for (const key in original) {
    result[key] = original[key];
  }
  objects.forEach(function(obj) {
    for (const key in obj) {
      result[key] = obj[key];
    }
  });
  return (
    /** @type {T} */
    result
  );
}
const SPAN_CLOSE = "</span>";
const emitsWrappingTags = (node) => {
  return !!node.scope;
};
const scopeToCSSClass = (name, { prefix }) => {
  if (name.startsWith("language:")) {
    return name.replace("language:", "language-");
  }
  if (name.includes(".")) {
    const pieces = name.split(".");
    return [
      `${prefix}${pieces.shift()}`,
      ...pieces.map((x, i) => `${x}${"_".repeat(i + 1)}`)
    ].join(" ");
  }
  return `${prefix}${name}`;
};
class HTMLRenderer {
  /**
   * Creates a new HTMLRenderer
   *
   * @param {Tree} parseTree - the parse tree (must support `walk` API)
   * @param {{classPrefix: string}} options
   */
  constructor(parseTree, options) {
    this.buffer = "";
    this.classPrefix = options.classPrefix;
    parseTree.walk(this);
  }
  /**
   * Adds texts to the output stream
   *
   * @param {string} text */
  addText(text) {
    this.buffer += escapeHTML(text);
  }
  /**
   * Adds a node open to the output stream (if needed)
   *
   * @param {Node} node */
  openNode(node) {
    if (!emitsWrappingTags(node)) return;
    const className = scopeToCSSClass(
      node.scope,
      { prefix: this.classPrefix }
    );
    this.span(className);
  }
  /**
   * Adds a node close to the output stream (if needed)
   *
   * @param {Node} node */
  closeNode(node) {
    if (!emitsWrappingTags(node)) return;
    this.buffer += SPAN_CLOSE;
  }
  /**
   * returns the accumulated buffer
  */
  value() {
    return this.buffer;
  }
  // helpers
  /**
   * Builds a span element
   *
   * @param {string} className */
  span(className) {
    this.buffer += `<span class="${className}">`;
  }
}
const newNode = (opts = {}) => {
  const result = { children: [] };
  Object.assign(result, opts);
  return result;
};
class TokenTree {
  constructor() {
    this.rootNode = newNode();
    this.stack = [this.rootNode];
  }
  get top() {
    return this.stack[this.stack.length - 1];
  }
  get root() {
    return this.rootNode;
  }
  /** @param {Node} node */
  add(node) {
    this.top.children.push(node);
  }
  /** @param {string} scope */
  openNode(scope) {
    const node = newNode({ scope });
    this.add(node);
    this.stack.push(node);
  }
  closeNode() {
    if (this.stack.length > 1) {
      return this.stack.pop();
    }
    return void 0;
  }
  closeAllNodes() {
    while (this.closeNode()) ;
  }
  toJSON() {
    return JSON.stringify(this.rootNode, null, 4);
  }
  /**
   * @typedef { import("./html_renderer").Renderer } Renderer
   * @param {Renderer} builder
   */
  walk(builder) {
    return this.constructor._walk(builder, this.rootNode);
  }
  /**
   * @param {Renderer} builder
   * @param {Node} node
   */
  static _walk(builder, node) {
    if (typeof node === "string") {
      builder.addText(node);
    } else if (node.children) {
      builder.openNode(node);
      node.children.forEach((child) => this._walk(builder, child));
      builder.closeNode(node);
    }
    return builder;
  }
  /**
   * @param {Node} node
   */
  static _collapse(node) {
    if (typeof node === "string") return;
    if (!node.children) return;
    if (node.children.every((el) => typeof el === "string")) {
      node.children = [node.children.join("")];
    } else {
      node.children.forEach((child) => {
        TokenTree._collapse(child);
      });
    }
  }
}
class TokenTreeEmitter extends TokenTree {
  /**
   * @param {*} options
   */
  constructor(options) {
    super();
    this.options = options;
  }
  /**
   * @param {string} text
   */
  addText(text) {
    if (text === "") {
      return;
    }
    this.add(text);
  }
  /** @param {string} scope */
  startScope(scope) {
    this.openNode(scope);
  }
  endScope() {
    this.closeNode();
  }
  /**
   * @param {Emitter & {root: DataNode}} emitter
   * @param {string} name
   */
  __addSublanguage(emitter, name) {
    const node = emitter.root;
    if (name) node.scope = `language:${name}`;
    this.add(node);
  }
  toHTML() {
    const renderer = new HTMLRenderer(this, this.options);
    return renderer.value();
  }
  finalize() {
    this.closeAllNodes();
    return true;
  }
}
function source(re) {
  if (!re) return null;
  if (typeof re === "string") return re;
  return re.source;
}
function lookahead(re) {
  return concat("(?=", re, ")");
}
function anyNumberOfTimes(re) {
  return concat("(?:", re, ")*");
}
function optional(re) {
  return concat("(?:", re, ")?");
}
function concat(...args) {
  const joined = args.map((x) => source(x)).join("");
  return joined;
}
function stripOptionsFromArgs(args) {
  const opts = args[args.length - 1];
  if (typeof opts === "object" && opts.constructor === Object) {
    args.splice(args.length - 1, 1);
    return opts;
  } else {
    return {};
  }
}
function either(...args) {
  const opts = stripOptionsFromArgs(args);
  const joined = "(" + (opts.capture ? "" : "?:") + args.map((x) => source(x)).join("|") + ")";
  return joined;
}
function countMatchGroups(re) {
  return new RegExp(re.toString() + "|").exec("").length - 1;
}
function startsWith(re, lexeme) {
  const match = re && re.exec(lexeme);
  return match && match.index === 0;
}
const BACKREF_RE = /\[(?:[^\\\]]|\\.)*\]|\(\??|\\([1-9][0-9]*)|\\./;
function _rewriteBackreferences(regexps, { joinWith }) {
  let numCaptures = 0;
  return regexps.map((regex) => {
    numCaptures += 1;
    const offset = numCaptures;
    let re = source(regex);
    let out = "";
    while (re.length > 0) {
      const match = BACKREF_RE.exec(re);
      if (!match) {
        out += re;
        break;
      }
      out += re.substring(0, match.index);
      re = re.substring(match.index + match[0].length);
      if (match[0][0] === "\\" && match[1]) {
        out += "\\" + String(Number(match[1]) + offset);
      } else {
        out += match[0];
        if (match[0] === "(") {
          numCaptures++;
        }
      }
    }
    return out;
  }).map((re) => `(${re})`).join(joinWith);
}
const MATCH_NOTHING_RE = /\b\B/;
const IDENT_RE = "[a-zA-Z]\\w*";
const UNDERSCORE_IDENT_RE = "[a-zA-Z_]\\w*";
const NUMBER_RE = "\\b\\d+(\\.\\d+)?";
const C_NUMBER_RE = "(-?)(\\b0[xX][a-fA-F0-9]+|(\\b\\d+(\\.\\d*)?|\\.\\d+)([eE][-+]?\\d+)?)";
const BINARY_NUMBER_RE = "\\b(0b[01]+)";
const RE_STARTERS_RE = "!|!=|!==|%|%=|&|&&|&=|\\*|\\*=|\\+|\\+=|,|-|-=|/=|/|:|;|<<|<<=|<=|<|===|==|=|>>>=|>>=|>=|>>>|>>|>|\\?|\\[|\\{|\\(|\\^|\\^=|\\||\\|=|\\|\\||~";
const SHEBANG = (opts = {}) => {
  const beginShebang = /^#![ ]*\//;
  if (opts.binary) {
    opts.begin = concat(
      beginShebang,
      /.*\b/,
      opts.binary,
      /\b.*/
    );
  }
  return inherit$1({
    scope: "meta",
    begin: beginShebang,
    end: /$/,
    relevance: 0,
    /** @type {ModeCallback} */
    "on:begin": (m, resp) => {
      if (m.index !== 0) resp.ignoreMatch();
    }
  }, opts);
};
const BACKSLASH_ESCAPE = {
  begin: "\\\\[\\s\\S]",
  relevance: 0
};
const APOS_STRING_MODE = {
  scope: "string",
  begin: "'",
  end: "'",
  illegal: "\\n",
  contains: [BACKSLASH_ESCAPE]
};
const QUOTE_STRING_MODE = {
  scope: "string",
  begin: '"',
  end: '"',
  illegal: "\\n",
  contains: [BACKSLASH_ESCAPE]
};
const PHRASAL_WORDS_MODE = {
  begin: /\b(a|an|the|are|I'm|isn't|don't|doesn't|won't|but|just|should|pretty|simply|enough|gonna|going|wtf|so|such|will|you|your|they|like|more)\b/
};
const COMMENT = function(begin, end, modeOptions = {}) {
  const mode = inherit$1(
    {
      scope: "comment",
      begin,
      end,
      contains: []
    },
    modeOptions
  );
  mode.contains.push({
    scope: "doctag",
    // hack to avoid the space from being included. the space is necessary to
    // match here to prevent the plain text rule below from gobbling up doctags
    begin: "[ ]*(?=(TODO|FIXME|NOTE|BUG|OPTIMIZE|HACK|XXX):)",
    end: /(TODO|FIXME|NOTE|BUG|OPTIMIZE|HACK|XXX):/,
    excludeBegin: true,
    relevance: 0
  });
  const ENGLISH_WORD = either(
    // list of common 1 and 2 letter words in English
    "I",
    "a",
    "is",
    "so",
    "us",
    "to",
    "at",
    "if",
    "in",
    "it",
    "on",
    // note: this is not an exhaustive list of contractions, just popular ones
    /[A-Za-z]+['](d|ve|re|ll|t|s|n)/,
    // contractions - can't we'd they're let's, etc
    /[A-Za-z]+[-][a-z]+/,
    // `no-way`, etc.
    /[A-Za-z][a-z]{2,}/
    // allow capitalized words at beginning of sentences
  );
  mode.contains.push(
    {
      // TODO: how to include ", (, ) without breaking grammars that use these for
      // comment delimiters?
      // begin: /[ ]+([()"]?([A-Za-z'-]{3,}|is|a|I|so|us|[tT][oO]|at|if|in|it|on)[.]?[()":]?([.][ ]|[ ]|\))){3}/
      // ---
      // this tries to find sequences of 3 english words in a row (without any
      // "programming" type syntax) this gives us a strong signal that we've
      // TRULY found a comment - vs perhaps scanning with the wrong language.
      // It's possible to find something that LOOKS like the start of the
      // comment - but then if there is no readable text - good chance it is a
      // false match and not a comment.
      //
      // for a visual example please see:
      // https://github.com/highlightjs/highlight.js/issues/2827
      begin: concat(
        /[ ]+/,
        // necessary to prevent us gobbling up doctags like /* @author Bob Mcgill */
        "(",
        ENGLISH_WORD,
        /[.]?[:]?([.][ ]|[ ])/,
        "){3}"
      )
      // look for 3 words in a row
    }
  );
  return mode;
};
const C_LINE_COMMENT_MODE = COMMENT("//", "$");
const C_BLOCK_COMMENT_MODE = COMMENT("/\\*", "\\*/");
const HASH_COMMENT_MODE = COMMENT("#", "$");
const NUMBER_MODE = {
  scope: "number",
  begin: NUMBER_RE,
  relevance: 0
};
const C_NUMBER_MODE = {
  scope: "number",
  begin: C_NUMBER_RE,
  relevance: 0
};
const BINARY_NUMBER_MODE = {
  scope: "number",
  begin: BINARY_NUMBER_RE,
  relevance: 0
};
const REGEXP_MODE = {
  scope: "regexp",
  begin: /\/(?=[^/\n]*\/)/,
  end: /\/[gimuy]*/,
  contains: [
    BACKSLASH_ESCAPE,
    {
      begin: /\[/,
      end: /\]/,
      relevance: 0,
      contains: [BACKSLASH_ESCAPE]
    }
  ]
};
const TITLE_MODE = {
  scope: "title",
  begin: IDENT_RE,
  relevance: 0
};
const UNDERSCORE_TITLE_MODE = {
  scope: "title",
  begin: UNDERSCORE_IDENT_RE,
  relevance: 0
};
const METHOD_GUARD = {
  // excludes method names from keyword processing
  begin: "\\.\\s*" + UNDERSCORE_IDENT_RE,
  relevance: 0
};
const END_SAME_AS_BEGIN = function(mode) {
  return Object.assign(
    mode,
    {
      /** @type {ModeCallback} */
      "on:begin": (m, resp) => {
        resp.data._beginMatch = m[1];
      },
      /** @type {ModeCallback} */
      "on:end": (m, resp) => {
        if (resp.data._beginMatch !== m[1]) resp.ignoreMatch();
      }
    }
  );
};
var MODES = /* @__PURE__ */ Object.freeze({
  __proto__: null,
  APOS_STRING_MODE,
  BACKSLASH_ESCAPE,
  BINARY_NUMBER_MODE,
  BINARY_NUMBER_RE,
  COMMENT,
  C_BLOCK_COMMENT_MODE,
  C_LINE_COMMENT_MODE,
  C_NUMBER_MODE,
  C_NUMBER_RE,
  END_SAME_AS_BEGIN,
  HASH_COMMENT_MODE,
  IDENT_RE,
  MATCH_NOTHING_RE,
  METHOD_GUARD,
  NUMBER_MODE,
  NUMBER_RE,
  PHRASAL_WORDS_MODE,
  QUOTE_STRING_MODE,
  REGEXP_MODE,
  RE_STARTERS_RE,
  SHEBANG,
  TITLE_MODE,
  UNDERSCORE_IDENT_RE,
  UNDERSCORE_TITLE_MODE
});
function skipIfHasPrecedingDot(match, response) {
  const before = match.input[match.index - 1];
  if (before === ".") {
    response.ignoreMatch();
  }
}
function scopeClassName(mode, _parent) {
  if (mode.className !== void 0) {
    mode.scope = mode.className;
    delete mode.className;
  }
}
function beginKeywords(mode, parent) {
  if (!parent) return;
  if (!mode.beginKeywords) return;
  mode.begin = "\\b(" + mode.beginKeywords.split(" ").join("|") + ")(?!\\.)(?=\\b|\\s)";
  mode.__beforeBegin = skipIfHasPrecedingDot;
  mode.keywords = mode.keywords || mode.beginKeywords;
  delete mode.beginKeywords;
  if (mode.relevance === void 0) mode.relevance = 0;
}
function compileIllegal(mode, _parent) {
  if (!Array.isArray(mode.illegal)) return;
  mode.illegal = either(...mode.illegal);
}
function compileMatch(mode, _parent) {
  if (!mode.match) return;
  if (mode.begin || mode.end) throw new Error("begin & end are not supported with match");
  mode.begin = mode.match;
  delete mode.match;
}
function compileRelevance(mode, _parent) {
  if (mode.relevance === void 0) mode.relevance = 1;
}
const beforeMatchExt = (mode, parent) => {
  if (!mode.beforeMatch) return;
  if (mode.starts) throw new Error("beforeMatch cannot be used with starts");
  const originalMode = Object.assign({}, mode);
  Object.keys(mode).forEach((key) => {
    delete mode[key];
  });
  mode.keywords = originalMode.keywords;
  mode.begin = concat(originalMode.beforeMatch, lookahead(originalMode.begin));
  mode.starts = {
    relevance: 0,
    contains: [
      Object.assign(originalMode, { endsParent: true })
    ]
  };
  mode.relevance = 0;
  delete originalMode.beforeMatch;
};
const COMMON_KEYWORDS = [
  "of",
  "and",
  "for",
  "in",
  "not",
  "or",
  "if",
  "then",
  "parent",
  // common variable name
  "list",
  // common variable name
  "value"
  // common variable name
];
const DEFAULT_KEYWORD_SCOPE = "keyword";
function compileKeywords(rawKeywords, caseInsensitive, scopeName = DEFAULT_KEYWORD_SCOPE) {
  const compiledKeywords = /* @__PURE__ */ Object.create(null);
  if (typeof rawKeywords === "string") {
    compileList(scopeName, rawKeywords.split(" "));
  } else if (Array.isArray(rawKeywords)) {
    compileList(scopeName, rawKeywords);
  } else {
    Object.keys(rawKeywords).forEach(function(scopeName2) {
      Object.assign(
        compiledKeywords,
        compileKeywords(rawKeywords[scopeName2], caseInsensitive, scopeName2)
      );
    });
  }
  return compiledKeywords;
  function compileList(scopeName2, keywordList) {
    if (caseInsensitive) {
      keywordList = keywordList.map((x) => x.toLowerCase());
    }
    keywordList.forEach(function(keyword) {
      const pair = keyword.split("|");
      compiledKeywords[pair[0]] = [scopeName2, scoreForKeyword(pair[0], pair[1])];
    });
  }
}
function scoreForKeyword(keyword, providedScore) {
  if (providedScore) {
    return Number(providedScore);
  }
  return commonKeyword(keyword) ? 0 : 1;
}
function commonKeyword(keyword) {
  return COMMON_KEYWORDS.includes(keyword.toLowerCase());
}
const seenDeprecations = {};
const error = (message) => {
  console.error(message);
};
const warn = (message, ...args) => {
  console.log(`WARN: ${message}`, ...args);
};
const deprecated = (version2, message) => {
  if (seenDeprecations[`${version2}/${message}`]) return;
  console.log(`Deprecated as of ${version2}. ${message}`);
  seenDeprecations[`${version2}/${message}`] = true;
};
const MultiClassError = new Error();
function remapScopeNames(mode, regexes, { key }) {
  let offset = 0;
  const scopeNames = mode[key];
  const emit = {};
  const positions = {};
  for (let i = 1; i <= regexes.length; i++) {
    positions[i + offset] = scopeNames[i];
    emit[i + offset] = true;
    offset += countMatchGroups(regexes[i - 1]);
  }
  mode[key] = positions;
  mode[key]._emit = emit;
  mode[key]._multi = true;
}
function beginMultiClass(mode) {
  if (!Array.isArray(mode.begin)) return;
  if (mode.skip || mode.excludeBegin || mode.returnBegin) {
    error("skip, excludeBegin, returnBegin not compatible with beginScope: {}");
    throw MultiClassError;
  }
  if (typeof mode.beginScope !== "object" || mode.beginScope === null) {
    error("beginScope must be object");
    throw MultiClassError;
  }
  remapScopeNames(mode, mode.begin, { key: "beginScope" });
  mode.begin = _rewriteBackreferences(mode.begin, { joinWith: "" });
}
function endMultiClass(mode) {
  if (!Array.isArray(mode.end)) return;
  if (mode.skip || mode.excludeEnd || mode.returnEnd) {
    error("skip, excludeEnd, returnEnd not compatible with endScope: {}");
    throw MultiClassError;
  }
  if (typeof mode.endScope !== "object" || mode.endScope === null) {
    error("endScope must be object");
    throw MultiClassError;
  }
  remapScopeNames(mode, mode.end, { key: "endScope" });
  mode.end = _rewriteBackreferences(mode.end, { joinWith: "" });
}
function scopeSugar(mode) {
  if (mode.scope && typeof mode.scope === "object" && mode.scope !== null) {
    mode.beginScope = mode.scope;
    delete mode.scope;
  }
}
function MultiClass(mode) {
  scopeSugar(mode);
  if (typeof mode.beginScope === "string") {
    mode.beginScope = { _wrap: mode.beginScope };
  }
  if (typeof mode.endScope === "string") {
    mode.endScope = { _wrap: mode.endScope };
  }
  beginMultiClass(mode);
  endMultiClass(mode);
}
function compileLanguage(language) {
  function langRe(value, global) {
    return new RegExp(
      source(value),
      "m" + (language.case_insensitive ? "i" : "") + (language.unicodeRegex ? "u" : "") + (global ? "g" : "")
    );
  }
  class MultiRegex {
    constructor() {
      this.matchIndexes = {};
      this.regexes = [];
      this.matchAt = 1;
      this.position = 0;
    }
    // @ts-ignore
    addRule(re, opts) {
      opts.position = this.position++;
      this.matchIndexes[this.matchAt] = opts;
      this.regexes.push([opts, re]);
      this.matchAt += countMatchGroups(re) + 1;
    }
    compile() {
      if (this.regexes.length === 0) {
        this.exec = () => null;
      }
      const terminators = this.regexes.map((el) => el[1]);
      this.matcherRe = langRe(_rewriteBackreferences(terminators, { joinWith: "|" }), true);
      this.lastIndex = 0;
    }
    /** @param {string} s */
    exec(s) {
      this.matcherRe.lastIndex = this.lastIndex;
      const match = this.matcherRe.exec(s);
      if (!match) {
        return null;
      }
      const i = match.findIndex((el, i2) => i2 > 0 && el !== void 0);
      const matchData = this.matchIndexes[i];
      match.splice(0, i);
      return Object.assign(match, matchData);
    }
  }
  class ResumableMultiRegex {
    constructor() {
      this.rules = [];
      this.multiRegexes = [];
      this.count = 0;
      this.lastIndex = 0;
      this.regexIndex = 0;
    }
    // @ts-ignore
    getMatcher(index) {
      if (this.multiRegexes[index]) return this.multiRegexes[index];
      const matcher = new MultiRegex();
      this.rules.slice(index).forEach(([re, opts]) => matcher.addRule(re, opts));
      matcher.compile();
      this.multiRegexes[index] = matcher;
      return matcher;
    }
    resumingScanAtSamePosition() {
      return this.regexIndex !== 0;
    }
    considerAll() {
      this.regexIndex = 0;
    }
    // @ts-ignore
    addRule(re, opts) {
      this.rules.push([re, opts]);
      if (opts.type === "begin") this.count++;
    }
    /** @param {string} s */
    exec(s) {
      const m = this.getMatcher(this.regexIndex);
      m.lastIndex = this.lastIndex;
      let result = m.exec(s);
      if (this.resumingScanAtSamePosition()) {
        if (result && result.index === this.lastIndex) ;
        else {
          const m2 = this.getMatcher(0);
          m2.lastIndex = this.lastIndex + 1;
          result = m2.exec(s);
        }
      }
      if (result) {
        this.regexIndex += result.position + 1;
        if (this.regexIndex === this.count) {
          this.considerAll();
        }
      }
      return result;
    }
  }
  function buildModeRegex(mode) {
    const mm = new ResumableMultiRegex();
    mode.contains.forEach((term) => mm.addRule(term.begin, { rule: term, type: "begin" }));
    if (mode.terminatorEnd) {
      mm.addRule(mode.terminatorEnd, { type: "end" });
    }
    if (mode.illegal) {
      mm.addRule(mode.illegal, { type: "illegal" });
    }
    return mm;
  }
  function compileMode(mode, parent) {
    const cmode = (
      /** @type CompiledMode */
      mode
    );
    if (mode.isCompiled) return cmode;
    [
      scopeClassName,
      // do this early so compiler extensions generally don't have to worry about
      // the distinction between match/begin
      compileMatch,
      MultiClass,
      beforeMatchExt
    ].forEach((ext) => ext(mode, parent));
    language.compilerExtensions.forEach((ext) => ext(mode, parent));
    mode.__beforeBegin = null;
    [
      beginKeywords,
      // do this later so compiler extensions that come earlier have access to the
      // raw array if they wanted to perhaps manipulate it, etc.
      compileIllegal,
      // default to 1 relevance if not specified
      compileRelevance
    ].forEach((ext) => ext(mode, parent));
    mode.isCompiled = true;
    let keywordPattern = null;
    if (typeof mode.keywords === "object" && mode.keywords.$pattern) {
      mode.keywords = Object.assign({}, mode.keywords);
      keywordPattern = mode.keywords.$pattern;
      delete mode.keywords.$pattern;
    }
    keywordPattern = keywordPattern || /\w+/;
    if (mode.keywords) {
      mode.keywords = compileKeywords(mode.keywords, language.case_insensitive);
    }
    cmode.keywordPatternRe = langRe(keywordPattern, true);
    if (parent) {
      if (!mode.begin) mode.begin = /\B|\b/;
      cmode.beginRe = langRe(cmode.begin);
      if (!mode.end && !mode.endsWithParent) mode.end = /\B|\b/;
      if (mode.end) cmode.endRe = langRe(cmode.end);
      cmode.terminatorEnd = source(cmode.end) || "";
      if (mode.endsWithParent && parent.terminatorEnd) {
        cmode.terminatorEnd += (mode.end ? "|" : "") + parent.terminatorEnd;
      }
    }
    if (mode.illegal) cmode.illegalRe = langRe(
      /** @type {RegExp | string} */
      mode.illegal
    );
    if (!mode.contains) mode.contains = [];
    mode.contains = [].concat(...mode.contains.map(function(c) {
      return expandOrCloneMode(c === "self" ? mode : c);
    }));
    mode.contains.forEach(function(c) {
      compileMode(
        /** @type Mode */
        c,
        cmode
      );
    });
    if (mode.starts) {
      compileMode(mode.starts, parent);
    }
    cmode.matcher = buildModeRegex(cmode);
    return cmode;
  }
  if (!language.compilerExtensions) language.compilerExtensions = [];
  if (language.contains && language.contains.includes("self")) {
    throw new Error("ERR: contains `self` is not supported at the top-level of a language.  See documentation.");
  }
  language.classNameAliases = inherit$1(language.classNameAliases || {});
  return compileMode(
    /** @type Mode */
    language
  );
}
function dependencyOnParent(mode) {
  if (!mode) return false;
  return mode.endsWithParent || dependencyOnParent(mode.starts);
}
function expandOrCloneMode(mode) {
  if (mode.variants && !mode.cachedVariants) {
    mode.cachedVariants = mode.variants.map(function(variant) {
      return inherit$1(mode, { variants: null }, variant);
    });
  }
  if (mode.cachedVariants) {
    return mode.cachedVariants;
  }
  if (dependencyOnParent(mode)) {
    return inherit$1(mode, { starts: mode.starts ? inherit$1(mode.starts) : null });
  }
  if (Object.isFrozen(mode)) {
    return inherit$1(mode);
  }
  return mode;
}
var version = "11.10.0";
class HTMLInjectionError extends Error {
  constructor(reason, html) {
    super(reason);
    this.name = "HTMLInjectionError";
    this.html = html;
  }
}
const escape = escapeHTML;
const inherit = inherit$1;
const NO_MATCH = Symbol("nomatch");
const MAX_KEYWORD_HITS = 7;
const HLJS = function(hljs) {
  const languages = /* @__PURE__ */ Object.create(null);
  const aliases = /* @__PURE__ */ Object.create(null);
  const plugins = [];
  let SAFE_MODE = true;
  const LANGUAGE_NOT_FOUND = "Could not find the language '{}', did you forget to load/include a language module?";
  const PLAINTEXT_LANGUAGE = { disableAutodetect: true, name: "Plain text", contains: [] };
  let options = {
    ignoreUnescapedHTML: false,
    throwUnescapedHTML: false,
    noHighlightRe: /^(no-?highlight)$/i,
    languageDetectRe: /\blang(?:uage)?-([\w-]+)\b/i,
    classPrefix: "hljs-",
    cssSelector: "pre code",
    languages: null,
    // beta configuration options, subject to change, welcome to discuss
    // https://github.com/highlightjs/highlight.js/issues/1086
    __emitter: TokenTreeEmitter
  };
  function shouldNotHighlight(languageName) {
    return options.noHighlightRe.test(languageName);
  }
  function blockLanguage(block) {
    let classes = block.className + " ";
    classes += block.parentNode ? block.parentNode.className : "";
    const match = options.languageDetectRe.exec(classes);
    if (match) {
      const language = getLanguage(match[1]);
      if (!language) {
        warn(LANGUAGE_NOT_FOUND.replace("{}", match[1]));
        warn("Falling back to no-highlight mode for this block.", block);
      }
      return language ? match[1] : "no-highlight";
    }
    return classes.split(/\s+/).find((_class) => shouldNotHighlight(_class) || getLanguage(_class));
  }
  function highlight2(codeOrLanguageName, optionsOrCode, ignoreIllegals) {
    let code = "";
    let languageName = "";
    if (typeof optionsOrCode === "object") {
      code = codeOrLanguageName;
      ignoreIllegals = optionsOrCode.ignoreIllegals;
      languageName = optionsOrCode.language;
    } else {
      deprecated("10.7.0", "highlight(lang, code, ...args) has been deprecated.");
      deprecated("10.7.0", "Please use highlight(code, options) instead.\nhttps://github.com/highlightjs/highlight.js/issues/2277");
      languageName = codeOrLanguageName;
      code = optionsOrCode;
    }
    if (ignoreIllegals === void 0) {
      ignoreIllegals = true;
    }
    const context = {
      code,
      language: languageName
    };
    fire("before:highlight", context);
    const result = context.result ? context.result : _highlight(context.language, context.code, ignoreIllegals);
    result.code = context.code;
    fire("after:highlight", result);
    return result;
  }
  function _highlight(languageName, codeToHighlight, ignoreIllegals, continuation) {
    const keywordHits = /* @__PURE__ */ Object.create(null);
    function keywordData(mode, matchText) {
      return mode.keywords[matchText];
    }
    function processKeywords() {
      if (!top.keywords) {
        emitter.addText(modeBuffer);
        return;
      }
      let lastIndex = 0;
      top.keywordPatternRe.lastIndex = 0;
      let match = top.keywordPatternRe.exec(modeBuffer);
      let buf = "";
      while (match) {
        buf += modeBuffer.substring(lastIndex, match.index);
        const word = language.case_insensitive ? match[0].toLowerCase() : match[0];
        const data = keywordData(top, word);
        if (data) {
          const [kind, keywordRelevance] = data;
          emitter.addText(buf);
          buf = "";
          keywordHits[word] = (keywordHits[word] || 0) + 1;
          if (keywordHits[word] <= MAX_KEYWORD_HITS) relevance += keywordRelevance;
          if (kind.startsWith("_")) {
            buf += match[0];
          } else {
            const cssClass = language.classNameAliases[kind] || kind;
            emitKeyword(match[0], cssClass);
          }
        } else {
          buf += match[0];
        }
        lastIndex = top.keywordPatternRe.lastIndex;
        match = top.keywordPatternRe.exec(modeBuffer);
      }
      buf += modeBuffer.substring(lastIndex);
      emitter.addText(buf);
    }
    function processSubLanguage() {
      if (modeBuffer === "") return;
      let result2 = null;
      if (typeof top.subLanguage === "string") {
        if (!languages[top.subLanguage]) {
          emitter.addText(modeBuffer);
          return;
        }
        result2 = _highlight(top.subLanguage, modeBuffer, true, continuations[top.subLanguage]);
        continuations[top.subLanguage] = /** @type {CompiledMode} */
        result2._top;
      } else {
        result2 = highlightAuto(modeBuffer, top.subLanguage.length ? top.subLanguage : null);
      }
      if (top.relevance > 0) {
        relevance += result2.relevance;
      }
      emitter.__addSublanguage(result2._emitter, result2.language);
    }
    function processBuffer() {
      if (top.subLanguage != null) {
        processSubLanguage();
      } else {
        processKeywords();
      }
      modeBuffer = "";
    }
    function emitKeyword(keyword, scope) {
      if (keyword === "") return;
      emitter.startScope(scope);
      emitter.addText(keyword);
      emitter.endScope();
    }
    function emitMultiClass(scope, match) {
      let i = 1;
      const max = match.length - 1;
      while (i <= max) {
        if (!scope._emit[i]) {
          i++;
          continue;
        }
        const klass = language.classNameAliases[scope[i]] || scope[i];
        const text = match[i];
        if (klass) {
          emitKeyword(text, klass);
        } else {
          modeBuffer = text;
          processKeywords();
          modeBuffer = "";
        }
        i++;
      }
    }
    function startNewMode(mode, match) {
      if (mode.scope && typeof mode.scope === "string") {
        emitter.openNode(language.classNameAliases[mode.scope] || mode.scope);
      }
      if (mode.beginScope) {
        if (mode.beginScope._wrap) {
          emitKeyword(modeBuffer, language.classNameAliases[mode.beginScope._wrap] || mode.beginScope._wrap);
          modeBuffer = "";
        } else if (mode.beginScope._multi) {
          emitMultiClass(mode.beginScope, match);
          modeBuffer = "";
        }
      }
      top = Object.create(mode, { parent: { value: top } });
      return top;
    }
    function endOfMode(mode, match, matchPlusRemainder) {
      let matched = startsWith(mode.endRe, matchPlusRemainder);
      if (matched) {
        if (mode["on:end"]) {
          const resp = new Response(mode);
          mode["on:end"](match, resp);
          if (resp.isMatchIgnored) matched = false;
        }
        if (matched) {
          while (mode.endsParent && mode.parent) {
            mode = mode.parent;
          }
          return mode;
        }
      }
      if (mode.endsWithParent) {
        return endOfMode(mode.parent, match, matchPlusRemainder);
      }
    }
    function doIgnore(lexeme) {
      if (top.matcher.regexIndex === 0) {
        modeBuffer += lexeme[0];
        return 1;
      } else {
        resumeScanAtSamePosition = true;
        return 0;
      }
    }
    function doBeginMatch(match) {
      const lexeme = match[0];
      const newMode = match.rule;
      const resp = new Response(newMode);
      const beforeCallbacks = [newMode.__beforeBegin, newMode["on:begin"]];
      for (const cb of beforeCallbacks) {
        if (!cb) continue;
        cb(match, resp);
        if (resp.isMatchIgnored) return doIgnore(lexeme);
      }
      if (newMode.skip) {
        modeBuffer += lexeme;
      } else {
        if (newMode.excludeBegin) {
          modeBuffer += lexeme;
        }
        processBuffer();
        if (!newMode.returnBegin && !newMode.excludeBegin) {
          modeBuffer = lexeme;
        }
      }
      startNewMode(newMode, match);
      return newMode.returnBegin ? 0 : lexeme.length;
    }
    function doEndMatch(match) {
      const lexeme = match[0];
      const matchPlusRemainder = codeToHighlight.substring(match.index);
      const endMode = endOfMode(top, match, matchPlusRemainder);
      if (!endMode) {
        return NO_MATCH;
      }
      const origin = top;
      if (top.endScope && top.endScope._wrap) {
        processBuffer();
        emitKeyword(lexeme, top.endScope._wrap);
      } else if (top.endScope && top.endScope._multi) {
        processBuffer();
        emitMultiClass(top.endScope, match);
      } else if (origin.skip) {
        modeBuffer += lexeme;
      } else {
        if (!(origin.returnEnd || origin.excludeEnd)) {
          modeBuffer += lexeme;
        }
        processBuffer();
        if (origin.excludeEnd) {
          modeBuffer = lexeme;
        }
      }
      do {
        if (top.scope) {
          emitter.closeNode();
        }
        if (!top.skip && !top.subLanguage) {
          relevance += top.relevance;
        }
        top = top.parent;
      } while (top !== endMode.parent);
      if (endMode.starts) {
        startNewMode(endMode.starts, match);
      }
      return origin.returnEnd ? 0 : lexeme.length;
    }
    function processContinuations() {
      const list = [];
      for (let current = top; current !== language; current = current.parent) {
        if (current.scope) {
          list.unshift(current.scope);
        }
      }
      list.forEach((item) => emitter.openNode(item));
    }
    let lastMatch = {};
    function processLexeme(textBeforeMatch, match) {
      const lexeme = match && match[0];
      modeBuffer += textBeforeMatch;
      if (lexeme == null) {
        processBuffer();
        return 0;
      }
      if (lastMatch.type === "begin" && match.type === "end" && lastMatch.index === match.index && lexeme === "") {
        modeBuffer += codeToHighlight.slice(match.index, match.index + 1);
        if (!SAFE_MODE) {
          const err = new Error(`0 width match regex (${languageName})`);
          err.languageName = languageName;
          err.badRule = lastMatch.rule;
          throw err;
        }
        return 1;
      }
      lastMatch = match;
      if (match.type === "begin") {
        return doBeginMatch(match);
      } else if (match.type === "illegal" && !ignoreIllegals) {
        const err = new Error('Illegal lexeme "' + lexeme + '" for mode "' + (top.scope || "<unnamed>") + '"');
        err.mode = top;
        throw err;
      } else if (match.type === "end") {
        const processed = doEndMatch(match);
        if (processed !== NO_MATCH) {
          return processed;
        }
      }
      if (match.type === "illegal" && lexeme === "") {
        return 1;
      }
      if (iterations > 1e5 && iterations > match.index * 3) {
        const err = new Error("potential infinite loop, way more iterations than matches");
        throw err;
      }
      modeBuffer += lexeme;
      return lexeme.length;
    }
    const language = getLanguage(languageName);
    if (!language) {
      error(LANGUAGE_NOT_FOUND.replace("{}", languageName));
      throw new Error('Unknown language: "' + languageName + '"');
    }
    const md = compileLanguage(language);
    let result = "";
    let top = continuation || md;
    const continuations = {};
    const emitter = new options.__emitter(options);
    processContinuations();
    let modeBuffer = "";
    let relevance = 0;
    let index = 0;
    let iterations = 0;
    let resumeScanAtSamePosition = false;
    try {
      if (!language.__emitTokens) {
        top.matcher.considerAll();
        for (; ; ) {
          iterations++;
          if (resumeScanAtSamePosition) {
            resumeScanAtSamePosition = false;
          } else {
            top.matcher.considerAll();
          }
          top.matcher.lastIndex = index;
          const match = top.matcher.exec(codeToHighlight);
          if (!match) break;
          const beforeMatch = codeToHighlight.substring(index, match.index);
          const processedCount = processLexeme(beforeMatch, match);
          index = match.index + processedCount;
        }
        processLexeme(codeToHighlight.substring(index));
      } else {
        language.__emitTokens(codeToHighlight, emitter);
      }
      emitter.finalize();
      result = emitter.toHTML();
      return {
        language: languageName,
        value: result,
        relevance,
        illegal: false,
        _emitter: emitter,
        _top: top
      };
    } catch (err) {
      if (err.message && err.message.includes("Illegal")) {
        return {
          language: languageName,
          value: escape(codeToHighlight),
          illegal: true,
          relevance: 0,
          _illegalBy: {
            message: err.message,
            index,
            context: codeToHighlight.slice(index - 100, index + 100),
            mode: err.mode,
            resultSoFar: result
          },
          _emitter: emitter
        };
      } else if (SAFE_MODE) {
        return {
          language: languageName,
          value: escape(codeToHighlight),
          illegal: false,
          relevance: 0,
          errorRaised: err,
          _emitter: emitter,
          _top: top
        };
      } else {
        throw err;
      }
    }
  }
  function justTextHighlightResult(code) {
    const result = {
      value: escape(code),
      illegal: false,
      relevance: 0,
      _top: PLAINTEXT_LANGUAGE,
      _emitter: new options.__emitter(options)
    };
    result._emitter.addText(code);
    return result;
  }
  function highlightAuto(code, languageSubset) {
    languageSubset = languageSubset || options.languages || Object.keys(languages);
    const plaintext = justTextHighlightResult(code);
    const results = languageSubset.filter(getLanguage).filter(autoDetection).map(
      (name) => _highlight(name, code, false)
    );
    results.unshift(plaintext);
    const sorted = results.sort((a, b) => {
      if (a.relevance !== b.relevance) return b.relevance - a.relevance;
      if (a.language && b.language) {
        if (getLanguage(a.language).supersetOf === b.language) {
          return 1;
        } else if (getLanguage(b.language).supersetOf === a.language) {
          return -1;
        }
      }
      return 0;
    });
    const [best, secondBest] = sorted;
    const result = best;
    result.secondBest = secondBest;
    return result;
  }
  function updateClassName(element, currentLang, resultLang) {
    const language = currentLang && aliases[currentLang] || resultLang;
    element.classList.add("hljs");
    element.classList.add(`language-${language}`);
  }
  function highlightElement(element) {
    let node = null;
    const language = blockLanguage(element);
    if (shouldNotHighlight(language)) return;
    fire(
      "before:highlightElement",
      { el: element, language }
    );
    if (element.dataset.highlighted) {
      console.log("Element previously highlighted. To highlight again, first unset `dataset.highlighted`.", element);
      return;
    }
    if (element.children.length > 0) {
      if (!options.ignoreUnescapedHTML) {
        console.warn("One of your code blocks includes unescaped HTML. This is a potentially serious security risk.");
        console.warn("https://github.com/highlightjs/highlight.js/wiki/security");
        console.warn("The element with unescaped HTML:");
        console.warn(element);
      }
      if (options.throwUnescapedHTML) {
        const err = new HTMLInjectionError(
          "One of your code blocks includes unescaped HTML.",
          element.innerHTML
        );
        throw err;
      }
    }
    node = element;
    const text = node.textContent;
    const result = language ? highlight2(text, { language, ignoreIllegals: true }) : highlightAuto(text);
    element.innerHTML = result.value;
    element.dataset.highlighted = "yes";
    updateClassName(element, language, result.language);
    element.result = {
      language: result.language,
      // TODO: remove with version 11.0
      re: result.relevance,
      relevance: result.relevance
    };
    if (result.secondBest) {
      element.secondBest = {
        language: result.secondBest.language,
        relevance: result.secondBest.relevance
      };
    }
    fire("after:highlightElement", { el: element, result, text });
  }
  function configure(userOptions) {
    options = inherit(options, userOptions);
  }
  const initHighlighting = () => {
    highlightAll();
    deprecated("10.6.0", "initHighlighting() deprecated.  Use highlightAll() now.");
  };
  function initHighlightingOnLoad() {
    highlightAll();
    deprecated("10.6.0", "initHighlightingOnLoad() deprecated.  Use highlightAll() now.");
  }
  function highlightAll() {
    if ((void 0).readyState === "loading") {
      return;
    }
    const blocks = (void 0).querySelectorAll(options.cssSelector);
    blocks.forEach(highlightElement);
  }
  function registerLanguage(languageName, languageDefinition) {
    let lang = null;
    try {
      lang = languageDefinition(hljs);
    } catch (error$1) {
      error("Language definition for '{}' could not be registered.".replace("{}", languageName));
      if (!SAFE_MODE) {
        throw error$1;
      } else {
        error(error$1);
      }
      lang = PLAINTEXT_LANGUAGE;
    }
    if (!lang.name) lang.name = languageName;
    languages[languageName] = lang;
    lang.rawDefinition = languageDefinition.bind(null, hljs);
    if (lang.aliases) {
      registerAliases(lang.aliases, { languageName });
    }
  }
  function unregisterLanguage(languageName) {
    delete languages[languageName];
    for (const alias of Object.keys(aliases)) {
      if (aliases[alias] === languageName) {
        delete aliases[alias];
      }
    }
  }
  function listLanguages() {
    return Object.keys(languages);
  }
  function getLanguage(name) {
    name = (name || "").toLowerCase();
    return languages[name] || languages[aliases[name]];
  }
  function registerAliases(aliasList, { languageName }) {
    if (typeof aliasList === "string") {
      aliasList = [aliasList];
    }
    aliasList.forEach((alias) => {
      aliases[alias.toLowerCase()] = languageName;
    });
  }
  function autoDetection(name) {
    const lang = getLanguage(name);
    return lang && !lang.disableAutodetect;
  }
  function upgradePluginAPI(plugin) {
    if (plugin["before:highlightBlock"] && !plugin["before:highlightElement"]) {
      plugin["before:highlightElement"] = (data) => {
        plugin["before:highlightBlock"](
          Object.assign({ block: data.el }, data)
        );
      };
    }
    if (plugin["after:highlightBlock"] && !plugin["after:highlightElement"]) {
      plugin["after:highlightElement"] = (data) => {
        plugin["after:highlightBlock"](
          Object.assign({ block: data.el }, data)
        );
      };
    }
  }
  function addPlugin(plugin) {
    upgradePluginAPI(plugin);
    plugins.push(plugin);
  }
  function removePlugin(plugin) {
    const index = plugins.indexOf(plugin);
    if (index !== -1) {
      plugins.splice(index, 1);
    }
  }
  function fire(event, args) {
    const cb = event;
    plugins.forEach(function(plugin) {
      if (plugin[cb]) {
        plugin[cb](args);
      }
    });
  }
  function deprecateHighlightBlock(el) {
    deprecated("10.7.0", "highlightBlock will be removed entirely in v12.0");
    deprecated("10.7.0", "Please use highlightElement now.");
    return highlightElement(el);
  }
  Object.assign(hljs, {
    highlight: highlight2,
    highlightAuto,
    highlightAll,
    highlightElement,
    // TODO: Remove with v12 API
    highlightBlock: deprecateHighlightBlock,
    configure,
    initHighlighting,
    initHighlightingOnLoad,
    registerLanguage,
    unregisterLanguage,
    listLanguages,
    getLanguage,
    registerAliases,
    autoDetection,
    inherit,
    addPlugin,
    removePlugin
  });
  hljs.debugMode = function() {
    SAFE_MODE = false;
  };
  hljs.safeMode = function() {
    SAFE_MODE = true;
  };
  hljs.versionString = version;
  hljs.regex = {
    concat,
    lookahead,
    either,
    optional,
    anyNumberOfTimes
  };
  for (const key in MODES) {
    if (typeof MODES[key] === "object") {
      deepFreeze(MODES[key]);
    }
  }
  Object.assign(hljs, MODES);
  return hljs;
};
const highlight = HLJS({});
highlight.newInstance = () => HLJS({});
var core = highlight;
highlight.HighlightJS = highlight;
highlight.default = highlight;
var HighlightJS = /* @__PURE__ */ getDefaultExportFromCjs(core);
function parseNodes(nodes, className = []) {
  return nodes.map((node) => {
    const classes = [...className, ...node.properties ? node.properties.className : []];
    if (node.children) {
      return parseNodes(node.children, classes);
    }
    return {
      text: node.value,
      classes
    };
  }).flat();
}
function getHighlightNodes(result) {
  return result.value || result.children || [];
}
function registered(aliasOrLanguage) {
  return Boolean(HighlightJS.getLanguage(aliasOrLanguage));
}
function getDecorations({ doc, name, lowlight, defaultLanguage }) {
  const decorations = [];
  findChildren(doc, (node) => node.type.name === name).forEach((block) => {
    var _a;
    let from = block.pos + 1;
    const language = block.node.attrs.language || defaultLanguage;
    const languages = lowlight.listLanguages();
    const nodes = language && (languages.includes(language) || registered(language) || ((_a = lowlight.registered) === null || _a === void 0 ? void 0 : _a.call(lowlight, language))) ? getHighlightNodes(lowlight.highlight(language, block.node.textContent)) : getHighlightNodes(lowlight.highlightAuto(block.node.textContent));
    parseNodes(nodes).forEach((node) => {
      const to = from + node.text.length;
      if (node.classes.length) {
        const decoration = Decoration.inline(from, to, {
          class: node.classes.join(" ")
        });
        decorations.push(decoration);
      }
      from = to;
    });
  });
  return DecorationSet.create(doc, decorations);
}
function isFunction(param) {
  return typeof param === "function";
}
function LowlightPlugin({ name, lowlight, defaultLanguage }) {
  if (!["highlight", "highlightAuto", "listLanguages"].every((api) => isFunction(lowlight[api]))) {
    throw Error("You should provide an instance of lowlight to use the code-block-lowlight extension");
  }
  const lowlightPlugin = new Plugin({
    key: new PluginKey("lowlight"),
    state: {
      init: (_, { doc }) => getDecorations({
        doc,
        name,
        lowlight,
        defaultLanguage
      }),
      apply: (transaction, decorationSet, oldState, newState) => {
        const oldNodeName = oldState.selection.$head.parent.type.name;
        const newNodeName = newState.selection.$head.parent.type.name;
        const oldNodes = findChildren(oldState.doc, (node) => node.type.name === name);
        const newNodes = findChildren(newState.doc, (node) => node.type.name === name);
        if (transaction.docChanged && ([oldNodeName, newNodeName].includes(name) || newNodes.length !== oldNodes.length || transaction.steps.some((step) => {
          return (
            // @ts-ignore
            step.from !== void 0 && step.to !== void 0 && oldNodes.some((node) => {
              return (
                // @ts-ignore
                node.pos >= step.from && node.pos + node.node.nodeSize <= step.to
              );
            })
          );
        }))) {
          return getDecorations({
            doc: transaction.doc,
            name,
            lowlight,
            defaultLanguage
          });
        }
        return decorationSet.map(transaction.mapping, transaction.doc);
      }
    },
    props: {
      decorations(state) {
        return lowlightPlugin.getState(state);
      }
    }
  });
  return lowlightPlugin;
}
CodeBlock.extend({
  addOptions() {
    var _a;
    return {
      ...(_a = this.parent) === null || _a === void 0 ? void 0 : _a.call(this),
      lowlight: {},
      languageClassPrefix: "language-",
      exitOnTripleEnter: true,
      exitOnArrowDown: true,
      defaultLanguage: null,
      HTMLAttributes: {}
    };
  },
  addProseMirrorPlugins() {
    var _a;
    return [
      ...((_a = this.parent) === null || _a === void 0 ? void 0 : _a.call(this)) || [],
      LowlightPlugin({
        name: this.name,
        lowlight: this.options.lowlight,
        defaultLanguage: this.options.defaultLanguage
      })
    ];
  }
});
const mergeNestedSpanStyles = (element) => {
  if (!element.children.length) {
    return;
  }
  const childSpans = element.querySelectorAll("span");
  if (!childSpans) {
    return;
  }
  childSpans.forEach((childSpan) => {
    var _a, _b;
    const childStyle = childSpan.getAttribute("style");
    const closestParentSpanStyleOfChild = (_b = (_a = childSpan.parentElement) === null || _a === void 0 ? void 0 : _a.closest("span")) === null || _b === void 0 ? void 0 : _b.getAttribute("style");
    childSpan.setAttribute("style", `${closestParentSpanStyleOfChild};${childStyle}`);
  });
};
Mark.create({
  name: "textStyle",
  priority: 101,
  addOptions() {
    return {
      HTMLAttributes: {},
      mergeNestedSpanStyles: false
    };
  },
  parseHTML() {
    return [
      {
        tag: "span",
        getAttrs: (element) => {
          const hasStyles = element.hasAttribute("style");
          if (!hasStyles) {
            return false;
          }
          if (this.options.mergeNestedSpanStyles) {
            mergeNestedSpanStyles(element);
          }
          return {};
        }
      }
    ];
  },
  renderHTML({ HTMLAttributes }) {
    return ["span", mergeAttributes(this.options.HTMLAttributes, HTMLAttributes), 0];
  },
  addCommands() {
    return {
      removeEmptyTextStyle: () => ({ tr }) => {
        const { selection } = tr;
        tr.doc.nodesBetween(selection.from, selection.to, (node, pos) => {
          if (node.isTextblock) {
            return true;
          }
          if (!node.marks.filter((mark) => mark.type === this.type).some((mark) => Object.values(mark.attrs).some((value) => !!value))) {
            tr.removeMark(pos, pos + node.nodeSize, this.type);
          }
        });
        return true;
      }
    };
  }
});
const _sfc_main$3 = /* @__PURE__ */ defineComponent({
  __name: "TipTapKbEditor.client",
  __ssrInlineRender: true,
  props: { path: String, content: String },
  setup(__props) {
    const props = __props;
    const api = useKbApi();
    const toast = useToastStore();
    const docStore = useDocStore();
    const saving = ref(false);
    const html = ref("");
    const editor = ref(null);
    ref(true);
    const turndown = new Turndown();
    const imagePicker = ref(null);
    const currentMarkdown = ref("");
    const saveMessage = ref("");
    ref("");
    const showColorPalette = ref(false);
    const showHighlightPalette = ref(false);
    const colorPreset = ["#000000", "#e11d48", "#ef4444", "#f59e0b", "#10b981", "#06b6d4", "#3b82f6", "#8b5cf6", "#ec4899"];
    const highlightPreset = ["#fff59d", "#fde68a", "#fca5a5", "#bbf7d0", "#bae6fd", "#ddd6fe"];
    async function save() {
      try {
        saving.value = true;
        const markdown = turndown.turndown(html.value || "");
        try {
          docStore.update(markdown);
        } catch {
        }
        const res = await docStore.save(saveMessage.value || "Edit via TipTap");
        if (res == null ? void 0 : res.conflict) {
          toast.push("warn", "\uBC84\uC804 \uCDA9\uB3CC \uBC1C\uC0DD: \uBCD1\uD569 \uD544\uC694 (Markdown \uD0ED\uC5D0\uC11C \uCC98\uB9AC)");
        }
        try {
          docStore.update(markdown);
        } catch {
        }
        toast.push("success", "\uC800\uC7A5 \uC644\uB8CC");
        try {
          (void 0).dispatchEvent(new CustomEvent("kb:mode", { detail: { to: "view" } }));
        } catch {
        }
      } catch (e) {
        toast.push("error", "\uC800\uC7A5 \uC2E4\uD328");
      } finally {
        saving.value = false;
      }
    }
    function cancel() {
      try {
        (void 0).dispatchEvent(new CustomEvent("kb:mode", { detail: { to: "view" } }));
      } catch {
      }
    }
    async function deleteCurrent() {
      try {
        if (!props.path) {
          return;
        }
        const ok = (void 0).confirm("\uC774 \uBB38\uC11C\uB97C \uD734\uC9C0\uD1B5\uC73C\uB85C \uC774\uB3D9\uD560\uAE4C\uC694?");
        if (!ok) return;
        const p = props.path;
        const ts = (/* @__PURE__ */ new Date()).toISOString().replace(/[-:T.Z]/g, "").slice(0, 14);
        const trashPath = `.trash/${ts}/${p}`;
        await fetch(`${resolveApiBase()}/api/v1/knowledge-base/move`, { method: "POST", headers: { "Content-Type": "application/json", "X-API-Key": "my_mcp_eagle_tiger" }, body: JSON.stringify({ path: p, new_path: trashPath }) });
        try {
          (void 0).dispatchEvent(new CustomEvent("kb:deleted", { detail: { path: p, trashPath } }));
        } catch {
        }
      } catch {
        alert("\uC0AD\uC81C \uC2E4\uD328");
      }
    }
    function cmd(name, args = {}) {
      var _a, _b;
      try {
        (_b = (_a = editor.value) == null ? void 0 : _a.chain().focus()) == null ? void 0 : _b[name](args).run();
      } catch {
      }
    }
    function align(dir) {
      var _a;
      try {
        const m = (_a = editor.value) == null ? void 0 : _a.chain().focus();
        if (dir === "left") m.setTextAlign("left").run();
        else if (dir === "center") m.setTextAlign("center").run();
        else if (dir === "right") m.setTextAlign("right").run();
        else m.setTextAlign("justify").run();
      } catch {
      }
    }
    function toggleTaskChecked() {
      var _a, _b;
      try {
        const api2 = editor.value;
        if (!api2) return;
        const state = api2.state;
        const { $from } = state.selection;
        const node = $from == null ? void 0 : $from.node($from.depth);
        if (node && ((_a = node.type) == null ? void 0 : _a.name) === "taskItem") {
          const checked = !!((_b = node == null ? void 0 : node.attrs) == null ? void 0 : _b.checked);
          api2.chain().focus().updateAttributes("taskItem", { checked: !checked }).run();
        } else {
          api2.chain().focus().toggleTaskList().run();
        }
      } catch {
      }
    }
    function insertTable() {
      var _a;
      try {
        (_a = editor.value) == null ? void 0 : _a.chain().focus().insertTable({ rows: 3, cols: 3, withHeaderRow: true }).run();
      } catch {
      }
    }
    function insertLink() {
      var _a;
      try {
        const url = (void 0).prompt("\uB9C1\uD06C URL \uC785\uB825 (\uBE48\uCE78=\uD574\uC81C):");
        if (url === null) return;
        if (url && !/^https?:\/\//i.test(url)) {
          alert("http(s):// \uB85C \uC2DC\uC791\uD558\uB294 \uC720\uD6A8\uD55C URL\uC744 \uC785\uB825\uD558\uC138\uC694.");
          return;
        }
        const chain = (_a = editor.value) == null ? void 0 : _a.chain().focus();
        if (!url) {
          chain.extendMarkRange("link").unsetLink().run();
          return;
        }
        chain.extendMarkRange("link").setLink({ href: url }).run();
      } catch {
      }
    }
    function unlink() {
      var _a;
      try {
        (_a = editor.value) == null ? void 0 : _a.chain().focus().unsetLink().run();
      } catch {
      }
    }
    function tableCmd(cmd2) {
      var _a, _b;
      try {
        (_b = (_a = editor.value) == null ? void 0 : _a.chain().focus()) == null ? void 0 : _b[cmd2]().run();
      } catch {
      }
    }
    function clearFormatting() {
      var _a;
      try {
        (_a = editor.value) == null ? void 0 : _a.chain().focus().unsetAllMarks().clearNodes().run();
      } catch {
      }
    }
    function indentList() {
      var _a;
      try {
        (_a = editor.value) == null ? void 0 : _a.chain().focus().sinkListItem("listItem").run();
      } catch {
      }
    }
    function outdentList() {
      var _a;
      try {
        (_a = editor.value) == null ? void 0 : _a.chain().focus().liftListItem("listItem").run();
      } catch {
      }
    }
    function clearColor() {
      var _a;
      try {
        (_a = editor.value) == null ? void 0 : _a.chain().focus().unsetColor().run();
      } catch {
      }
    }
    function setCodeLang() {
      var _a;
      try {
        const lang = (void 0).prompt("\uCF54\uB4DC \uBE14\uB85D \uC5B8\uC5B4(\uC608: javascript, typescript, python, bash, json, yaml, markdown):");
        if (!lang) return;
        (_a = editor.value) == null ? void 0 : _a.chain().focus().updateAttributes("codeBlock", { language: lang }).run();
      } catch {
      }
    }
    function toggleColorPalette() {
      showColorPalette.value = !showColorPalette.value;
    }
    function toggleHighlightPalette() {
      showHighlightPalette.value = !showHighlightPalette.value;
    }
    function setColorPreset(c) {
      var _a;
      try {
        (_a = editor.value) == null ? void 0 : _a.chain().focus().setColor(c).run();
        showColorPalette.value = false;
      } catch {
      }
    }
    function setHighlightPreset(c) {
      var _a;
      try {
        (_a = editor.value) == null ? void 0 : _a.chain().focus().setHighlight({ color: c }).run();
        showHighlightPalette.value = false;
      } catch {
      }
    }
    async function onPickImage(e) {
      var _a, _b;
      const input = e == null ? void 0 : e.target;
      const file = (_a = input == null ? void 0 : input.files) == null ? void 0 : _a[0];
      if (!file) return;
      try {
        const { path } = await api.uploadAsset(file, "assets");
        (_b = editor.value) == null ? void 0 : _b.chain().focus().setImage({ src: path }).run();
      } catch {
        toast.push("error", "\uC774\uBBF8\uC9C0 \uC5C5\uB85C\uB4DC \uC2E4\uD328");
      }
      if (imagePicker.value) imagePicker.value.value = "";
    }
    async function openAiMenu() {
      var _a;
      const choice = (void 0).prompt("AI \uC791\uC5C5 \uC120\uD0DD: table / mermaid / summary / rewrite");
      if (!choice) return;
      const kindRaw = choice.trim().toLowerCase();
      const kind = ["table", "mermaid", "summary"].includes(kindRaw) ? kindRaw : "summary";
      try {
        const currentMd = turndown.turndown(html.value || "");
        const out = await api.transform(currentMd, kind, {});
        const injected = marked.parse("\n" + ((out == null ? void 0 : out.result) || "") + "\n");
        (_a = editor.value) == null ? void 0 : _a.chain().focus().insertContent(injected).run();
      } catch {
        toast.push("error", "AI \uBCC0\uD658 \uC2E4\uD328");
      }
    }
    return (_ctx, _push, _parent, _attrs) => {
      _push(`<div${ssrRenderAttrs(mergeProps({ class: "h-full flex flex-col bg-white" }, _attrs))}>`);
      _push(ssrRenderComponent(_sfc_main$8, {
        saving: saving.value,
        "save-label": "\uC800\uC7A5",
        "cancel-label": "\uCDE8\uC18C",
        "delete-label": "\uC0AD\uC81C",
        "saving-text": "\uC800\uC7A5 \uC911\u2026",
        "aria-label": "WYSIWYG toolbar",
        "save-aria-label": "\uBB38\uC11C \uC800\uC7A5 (Ctrl+S)",
        "cancel-aria-label": "\uD3B8\uC9D1 \uCDE8\uC18C",
        "delete-aria-label": "\uD604\uC7AC \uBB38\uC11C \uC0AD\uC81C",
        onSave: save,
        onCancel: cancel,
        onDelete: deleteCurrent
      }, {
        default: withCtx((_, _push2, _parent2, _scopeId) => {
          if (_push2) {
            _push2(`<input${ssrRenderAttr("value", saveMessage.value)} placeholder="commit message" class="px-2 py-1 text-xs border rounded w-48 focus:outline-none focus:ring"${_scopeId}><button class="px-2 py-1 border rounded" aria-label="\uAD75\uAC8C"${_scopeId}><b${_scopeId}>B</b></button><button class="px-2 py-1 border rounded italic" aria-label="\uAE30\uC6B8\uC784"${_scopeId}>I</button><button class="px-2 py-1 border rounded" aria-label="\uBC11\uC904"${_scopeId}>U</button><button class="px-2 py-1 border rounded" aria-label="\uCDE8\uC18C\uC120"${_scopeId}>S</button><button class="px-2 py-1 border rounded" aria-label="\uC778\uB77C\uC778 \uCF54\uB4DC"${_scopeId}>\`code\`</button><button class="px-2 py-1 border rounded" aria-label="\uC11C\uC2DD \uC9C0\uC6B0\uAE30"${_scopeId}>Clear</button><div class="w-px h-5 bg-gray-200 mx-1"${_scopeId}></div><button class="px-2 py-1 border rounded" aria-label="\uBB38\uB2E8"${_scopeId}>P</button><button class="px-2 py-1 border rounded" aria-label="\uC81C\uBAA9 H1"${_scopeId}>H1</button><button class="px-2 py-1 border rounded" aria-label="\uC81C\uBAA9 H2"${_scopeId}>H2</button><button class="px-2 py-1 border rounded" aria-label="\uC81C\uBAA9 H3"${_scopeId}>H3</button><button class="px-2 py-1 border rounded" aria-label="\uC81C\uBAA9 H4"${_scopeId}>H4</button><button class="px-2 py-1 border rounded" aria-label="\uC81C\uBAA9 H5"${_scopeId}>H5</button><button class="px-2 py-1 border rounded" aria-label="\uC81C\uBAA9 H6"${_scopeId}>H6</button><button class="px-2 py-1 border rounded" aria-label="\uC778\uC6A9\uBB38"${_scopeId}>\u275D \u275E</button><button class="px-2 py-1 border rounded" aria-label="\uC218\uD3C9\uC120"${_scopeId}>HR</button><div class="w-px h-5 bg-gray-200 mx-1"${_scopeId}></div><button class="px-2 py-1 border rounded" aria-label="\uC67C\uCABD \uC815\uB82C"${_scopeId}>\u27F8</button><button class="px-2 py-1 border rounded" aria-label="\uAC00\uC6B4\uB370 \uC815\uB82C"${_scopeId}>\u21D4</button><button class="px-2 py-1 border rounded" aria-label="\uC624\uB978\uCABD \uC815\uB82C"${_scopeId}>\u27F9</button><button class="px-2 py-1 border rounded" aria-label="\uC591\uCABD \uC815\uB82C"${_scopeId}>\u27F7</button><div class="w-px h-5 bg-gray-200 mx-1"${_scopeId}></div><button class="px-2 py-1 border rounded" aria-label="\uBD88\uB9BF \uB9AC\uC2A4\uD2B8"${_scopeId}>\u2022 List</button><button class="px-2 py-1 border rounded" aria-label="\uBC88\uD638 \uB9AC\uC2A4\uD2B8"${_scopeId}>1. List</button><button class="px-2 py-1 border rounded" aria-label="\uD0DC\uC2A4\uD06C \uB9AC\uC2A4\uD2B8"${_scopeId}>\u2610 Task</button><button class="px-2 py-1 border rounded" aria-label="\uCCB4\uD06C \uD1A0\uAE00"${_scopeId}>\u2611\uFE0E</button><button class="px-2 py-1 border rounded" aria-label="\uBAA9\uB85D \uB4E4\uC5EC\uC4F0\uAE30"${_scopeId}>\u2192</button><button class="px-2 py-1 border rounded" aria-label="\uBAA9\uB85D \uB0B4\uC5B4\uC4F0\uAE30"${_scopeId}>\u2190</button><div class="w-px h-5 bg-gray-200 mx-1"${_scopeId}></div><button class="px-2 py-1 border rounded" aria-label="\uCF54\uB4DC \uBE14\uB85D"${_scopeId}>Code</button><button class="px-2 py-1 border rounded" aria-label="\uCF54\uB4DC \uC5B8\uC5B4 \uC124\uC815"${_scopeId}>Lang</button><button class="px-2 py-1 border rounded" aria-label="\uD558\uC774\uD37C\uB9C1\uD06C"${_scopeId}>Link</button><button class="px-2 py-1 border rounded" aria-label="\uB9C1\uD06C \uD574\uC81C"${_scopeId}>Unlink</button><button class="px-2 py-1 border rounded" aria-label="\uD45C \uC0BD\uC785"${_scopeId}>Table</button><div class="flex items-center gap-1"${_scopeId}><button class="px-2 py-1 border rounded" aria-label="\uC5F4 \uCD94\uAC00"${_scopeId}>+Col</button><button class="px-2 py-1 border rounded" aria-label="\uD589 \uCD94\uAC00"${_scopeId}>+Row</button><button class="px-2 py-1 border rounded" aria-label="\uC5F4 \uC0AD\uC81C"${_scopeId}>-Col</button><button class="px-2 py-1 border rounded" aria-label="\uD589 \uC0AD\uC81C"${_scopeId}>-Row</button><button class="px-2 py-1 border rounded" aria-label="\uC140 \uBCD1\uD569"${_scopeId}>Merge</button><button class="px-2 py-1 border rounded" aria-label="\uC140 \uBD84\uD560"${_scopeId}>Split</button><button class="px-2 py-1 border rounded" aria-label="\uD45C \uC0AD\uC81C"${_scopeId}>DelTbl</button></div><label class="px-2 py-1 border rounded bg-white cursor-pointer" aria-label="\uC774\uBBF8\uC9C0 \uC5C5\uB85C\uB4DC"${_scopeId}> Image<input type="file" accept="image/*" class="hidden"${_scopeId}></label><div class="w-px h-5 bg-gray-200 mx-1"${_scopeId}></div><button class="px-2 py-1 border rounded" aria-label="\uD14D\uC2A4\uD2B8 \uC0C9\uC0C1"${_scopeId}>Color</button>`);
            if (showColorPalette.value) {
              _push2(`<div class="flex items-center gap-1"${_scopeId}><!--[-->`);
              ssrRenderList(colorPreset, (c) => {
                _push2(`<button class="w-5 h-5 border rounded" style="${ssrRenderStyle({ backgroundColor: c })}"${ssrRenderAttr("title", c)}${_scopeId}></button>`);
              });
              _push2(`<!--]--></div>`);
            } else {
              _push2(`<!---->`);
            }
            _push2(`<button class="px-2 py-1 border rounded" aria-label="\uD558\uC774\uB77C\uC774\uD2B8"${_scopeId}>Mark</button>`);
            if (showHighlightPalette.value) {
              _push2(`<div class="flex items-center gap-1"${_scopeId}><!--[-->`);
              ssrRenderList(highlightPreset, (c) => {
                _push2(`<button class="w-5 h-5 border rounded" style="${ssrRenderStyle({ backgroundColor: c })}"${ssrRenderAttr("title", c)}${_scopeId}></button>`);
              });
              _push2(`<!--]--></div>`);
            } else {
              _push2(`<!---->`);
            }
            _push2(`<button class="px-2 py-1 border rounded" aria-label="\uC0C9\uC0C1 \uCD08\uAE30\uD654"${_scopeId}>NoColor</button><div class="w-px h-5 bg-gray-200 mx-1"${_scopeId}></div><button class="px-2 py-1 border rounded" aria-label="\uC2E4\uD589 \uCDE8\uC18C"${_scopeId}>Undo</button><button class="px-2 py-1 border rounded" aria-label="\uB2E4\uC2DC \uC2E4\uD589"${_scopeId}>Redo</button><button class="px-2 py-1 rounded bg-indigo-50 hover:bg-indigo-100 text-indigo-700" aria-label="AI \uBCC0\uD658"${_scopeId}>AI</button>`);
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
                class: "px-2 py-1 border rounded",
                "aria-label": "\uAD75\uAC8C",
                onClick: ($event) => cmd("toggleBold")
              }, [
                createVNode("b", null, "B")
              ], 8, ["onClick"]),
              createVNode("button", {
                class: "px-2 py-1 border rounded italic",
                "aria-label": "\uAE30\uC6B8\uC784",
                onClick: ($event) => cmd("toggleItalic")
              }, "I", 8, ["onClick"]),
              createVNode("button", {
                class: "px-2 py-1 border rounded",
                "aria-label": "\uBC11\uC904",
                onClick: ($event) => cmd("toggleUnderline")
              }, "U", 8, ["onClick"]),
              createVNode("button", {
                class: "px-2 py-1 border rounded",
                "aria-label": "\uCDE8\uC18C\uC120",
                onClick: ($event) => cmd("toggleStrike")
              }, "S", 8, ["onClick"]),
              createVNode("button", {
                class: "px-2 py-1 border rounded",
                "aria-label": "\uC778\uB77C\uC778 \uCF54\uB4DC",
                onClick: ($event) => cmd("toggleCode")
              }, "`code`", 8, ["onClick"]),
              createVNode("button", {
                class: "px-2 py-1 border rounded",
                "aria-label": "\uC11C\uC2DD \uC9C0\uC6B0\uAE30",
                onClick: clearFormatting
              }, "Clear"),
              createVNode("div", { class: "w-px h-5 bg-gray-200 mx-1" }),
              createVNode("button", {
                class: "px-2 py-1 border rounded",
                "aria-label": "\uBB38\uB2E8",
                onClick: ($event) => cmd("setParagraph")
              }, "P", 8, ["onClick"]),
              createVNode("button", {
                class: "px-2 py-1 border rounded",
                "aria-label": "\uC81C\uBAA9 H1",
                onClick: ($event) => cmd("toggleHeading", { level: 1 })
              }, "H1", 8, ["onClick"]),
              createVNode("button", {
                class: "px-2 py-1 border rounded",
                "aria-label": "\uC81C\uBAA9 H2",
                onClick: ($event) => cmd("toggleHeading", { level: 2 })
              }, "H2", 8, ["onClick"]),
              createVNode("button", {
                class: "px-2 py-1 border rounded",
                "aria-label": "\uC81C\uBAA9 H3",
                onClick: ($event) => cmd("toggleHeading", { level: 3 })
              }, "H3", 8, ["onClick"]),
              createVNode("button", {
                class: "px-2 py-1 border rounded",
                "aria-label": "\uC81C\uBAA9 H4",
                onClick: ($event) => cmd("toggleHeading", { level: 4 })
              }, "H4", 8, ["onClick"]),
              createVNode("button", {
                class: "px-2 py-1 border rounded",
                "aria-label": "\uC81C\uBAA9 H5",
                onClick: ($event) => cmd("toggleHeading", { level: 5 })
              }, "H5", 8, ["onClick"]),
              createVNode("button", {
                class: "px-2 py-1 border rounded",
                "aria-label": "\uC81C\uBAA9 H6",
                onClick: ($event) => cmd("toggleHeading", { level: 6 })
              }, "H6", 8, ["onClick"]),
              createVNode("button", {
                class: "px-2 py-1 border rounded",
                "aria-label": "\uC778\uC6A9\uBB38",
                onClick: ($event) => cmd("toggleBlockquote")
              }, "\u275D \u275E", 8, ["onClick"]),
              createVNode("button", {
                class: "px-2 py-1 border rounded",
                "aria-label": "\uC218\uD3C9\uC120",
                onClick: ($event) => cmd("setHorizontalRule")
              }, "HR", 8, ["onClick"]),
              createVNode("div", { class: "w-px h-5 bg-gray-200 mx-1" }),
              createVNode("button", {
                class: "px-2 py-1 border rounded",
                "aria-label": "\uC67C\uCABD \uC815\uB82C",
                onClick: ($event) => align("left")
              }, "\u27F8", 8, ["onClick"]),
              createVNode("button", {
                class: "px-2 py-1 border rounded",
                "aria-label": "\uAC00\uC6B4\uB370 \uC815\uB82C",
                onClick: ($event) => align("center")
              }, "\u21D4", 8, ["onClick"]),
              createVNode("button", {
                class: "px-2 py-1 border rounded",
                "aria-label": "\uC624\uB978\uCABD \uC815\uB82C",
                onClick: ($event) => align("right")
              }, "\u27F9", 8, ["onClick"]),
              createVNode("button", {
                class: "px-2 py-1 border rounded",
                "aria-label": "\uC591\uCABD \uC815\uB82C",
                onClick: ($event) => align("justify")
              }, "\u27F7", 8, ["onClick"]),
              createVNode("div", { class: "w-px h-5 bg-gray-200 mx-1" }),
              createVNode("button", {
                class: "px-2 py-1 border rounded",
                "aria-label": "\uBD88\uB9BF \uB9AC\uC2A4\uD2B8",
                onClick: ($event) => cmd("toggleBulletList")
              }, "\u2022 List", 8, ["onClick"]),
              createVNode("button", {
                class: "px-2 py-1 border rounded",
                "aria-label": "\uBC88\uD638 \uB9AC\uC2A4\uD2B8",
                onClick: ($event) => cmd("toggleOrderedList")
              }, "1. List", 8, ["onClick"]),
              createVNode("button", {
                class: "px-2 py-1 border rounded",
                "aria-label": "\uD0DC\uC2A4\uD06C \uB9AC\uC2A4\uD2B8",
                onClick: ($event) => cmd("toggleTaskList")
              }, "\u2610 Task", 8, ["onClick"]),
              createVNode("button", {
                class: "px-2 py-1 border rounded",
                "aria-label": "\uCCB4\uD06C \uD1A0\uAE00",
                onClick: toggleTaskChecked
              }, "\u2611\uFE0E"),
              createVNode("button", {
                class: "px-2 py-1 border rounded",
                "aria-label": "\uBAA9\uB85D \uB4E4\uC5EC\uC4F0\uAE30",
                onClick: indentList
              }, "\u2192"),
              createVNode("button", {
                class: "px-2 py-1 border rounded",
                "aria-label": "\uBAA9\uB85D \uB0B4\uC5B4\uC4F0\uAE30",
                onClick: outdentList
              }, "\u2190"),
              createVNode("div", { class: "w-px h-5 bg-gray-200 mx-1" }),
              createVNode("button", {
                class: "px-2 py-1 border rounded",
                "aria-label": "\uCF54\uB4DC \uBE14\uB85D",
                onClick: ($event) => cmd("toggleCodeBlock")
              }, "Code", 8, ["onClick"]),
              createVNode("button", {
                class: "px-2 py-1 border rounded",
                "aria-label": "\uCF54\uB4DC \uC5B8\uC5B4 \uC124\uC815",
                onClick: setCodeLang
              }, "Lang"),
              createVNode("button", {
                class: "px-2 py-1 border rounded",
                "aria-label": "\uD558\uC774\uD37C\uB9C1\uD06C",
                onClick: insertLink
              }, "Link"),
              createVNode("button", {
                class: "px-2 py-1 border rounded",
                "aria-label": "\uB9C1\uD06C \uD574\uC81C",
                onClick: unlink
              }, "Unlink"),
              createVNode("button", {
                class: "px-2 py-1 border rounded",
                "aria-label": "\uD45C \uC0BD\uC785",
                onClick: insertTable
              }, "Table"),
              createVNode("div", { class: "flex items-center gap-1" }, [
                createVNode("button", {
                  class: "px-2 py-1 border rounded",
                  "aria-label": "\uC5F4 \uCD94\uAC00",
                  onClick: ($event) => tableCmd("addColumnAfter")
                }, "+Col", 8, ["onClick"]),
                createVNode("button", {
                  class: "px-2 py-1 border rounded",
                  "aria-label": "\uD589 \uCD94\uAC00",
                  onClick: ($event) => tableCmd("addRowAfter")
                }, "+Row", 8, ["onClick"]),
                createVNode("button", {
                  class: "px-2 py-1 border rounded",
                  "aria-label": "\uC5F4 \uC0AD\uC81C",
                  onClick: ($event) => tableCmd("deleteColumn")
                }, "-Col", 8, ["onClick"]),
                createVNode("button", {
                  class: "px-2 py-1 border rounded",
                  "aria-label": "\uD589 \uC0AD\uC81C",
                  onClick: ($event) => tableCmd("deleteRow")
                }, "-Row", 8, ["onClick"]),
                createVNode("button", {
                  class: "px-2 py-1 border rounded",
                  "aria-label": "\uC140 \uBCD1\uD569",
                  onClick: ($event) => tableCmd("mergeCells")
                }, "Merge", 8, ["onClick"]),
                createVNode("button", {
                  class: "px-2 py-1 border rounded",
                  "aria-label": "\uC140 \uBD84\uD560",
                  onClick: ($event) => tableCmd("splitCell")
                }, "Split", 8, ["onClick"]),
                createVNode("button", {
                  class: "px-2 py-1 border rounded",
                  "aria-label": "\uD45C \uC0AD\uC81C",
                  onClick: ($event) => tableCmd("deleteTable")
                }, "DelTbl", 8, ["onClick"])
              ]),
              createVNode("label", {
                class: "px-2 py-1 border rounded bg-white cursor-pointer",
                "aria-label": "\uC774\uBBF8\uC9C0 \uC5C5\uB85C\uB4DC"
              }, [
                createTextVNode(" Image"),
                createVNode("input", {
                  ref_key: "imagePicker",
                  ref: imagePicker,
                  type: "file",
                  accept: "image/*",
                  class: "hidden",
                  onChange: onPickImage
                }, null, 544)
              ]),
              createVNode("div", { class: "w-px h-5 bg-gray-200 mx-1" }),
              createVNode("button", {
                class: "px-2 py-1 border rounded",
                "aria-label": "\uD14D\uC2A4\uD2B8 \uC0C9\uC0C1",
                onClick: toggleColorPalette
              }, "Color"),
              showColorPalette.value ? (openBlock(), createBlock("div", {
                key: 0,
                class: "flex items-center gap-1"
              }, [
                (openBlock(), createBlock(Fragment, null, renderList(colorPreset, (c) => {
                  return createVNode("button", {
                    key: "c" + c,
                    class: "w-5 h-5 border rounded",
                    style: { backgroundColor: c },
                    title: c,
                    onClick: ($event) => setColorPreset(c)
                  }, null, 12, ["title", "onClick"]);
                }), 64))
              ])) : createCommentVNode("", true),
              createVNode("button", {
                class: "px-2 py-1 border rounded",
                "aria-label": "\uD558\uC774\uB77C\uC774\uD2B8",
                onClick: toggleHighlightPalette
              }, "Mark"),
              showHighlightPalette.value ? (openBlock(), createBlock("div", {
                key: 1,
                class: "flex items-center gap-1"
              }, [
                (openBlock(), createBlock(Fragment, null, renderList(highlightPreset, (c) => {
                  return createVNode("button", {
                    key: "h" + c,
                    class: "w-5 h-5 border rounded",
                    style: { backgroundColor: c },
                    title: c,
                    onClick: ($event) => setHighlightPreset(c)
                  }, null, 12, ["title", "onClick"]);
                }), 64))
              ])) : createCommentVNode("", true),
              createVNode("button", {
                class: "px-2 py-1 border rounded",
                "aria-label": "\uC0C9\uC0C1 \uCD08\uAE30\uD654",
                onClick: clearColor
              }, "NoColor"),
              createVNode("div", { class: "w-px h-5 bg-gray-200 mx-1" }),
              createVNode("button", {
                class: "px-2 py-1 border rounded",
                "aria-label": "\uC2E4\uD589 \uCDE8\uC18C",
                onClick: ($event) => cmd("undo")
              }, "Undo", 8, ["onClick"]),
              createVNode("button", {
                class: "px-2 py-1 border rounded",
                "aria-label": "\uB2E4\uC2DC \uC2E4\uD589",
                onClick: ($event) => cmd("redo")
              }, "Redo", 8, ["onClick"]),
              createVNode("button", {
                class: "px-2 py-1 rounded bg-indigo-50 hover:bg-indigo-100 text-indigo-700",
                "aria-label": "AI \uBCC0\uD658",
                onClick: openAiMenu
              }, "AI")
            ];
          }
        }),
        _: 1
      }, _parent));
      _push(`<div class="flex-1 overflow-auto p-3"><div class="h-full grid grid-cols-[18rem_1fr] min-h-0">`);
      if (__props.path) {
        _push(ssrRenderComponent(_sfc_main$7, {
          key: `${__props.path}:${(currentMarkdown.value || "").length}`,
          path: __props.path,
          content: currentMarkdown.value
        }, null, _parent));
      } else {
        _push(`<!---->`);
      }
      _push(`<div class="min-h-0 h-full overflow-auto">`);
      if (editor.value) {
        _push(ssrRenderComponent(unref(EditorContent), {
          editor: editor.value,
          class: "tiptap-editor prose max-w-none h-full"
        }, null, _parent));
      } else {
        _push(`<div class="p-4 text-sm text-gray-500">\uC5D0\uB514\uD130 \uB85C\uB529 \uC911\u2026</div>`);
      }
      _push(`</div></div></div></div>`);
    };
  }
});
const _sfc_setup$3 = _sfc_main$3.setup;
_sfc_main$3.setup = (props, ctx) => {
  const ssrContext = useSSRContext();
  (ssrContext.modules || (ssrContext.modules = /* @__PURE__ */ new Set())).add("components/TipTapKbEditor.client.vue");
  return _sfc_setup$3 ? _sfc_setup$3(props, ctx) : void 0;
};
const TipTapKbEditor_client = /* @__PURE__ */ Object.freeze(/* @__PURE__ */ Object.defineProperty({
  __proto__: null,
  default: _sfc_main$3
}, Symbol.toStringTag, { value: "Module" }));
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
const apiKey = "my_mcp_eagle_tiger";
const _sfc_main = {
  __name: "default",
  __ssrInlineRender: true,
  setup(__props) {
    const toast = useToastStore();
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
      var _a;
      const configured = ((_a = config.public) == null ? void 0 : _a.apiBaseUrl) || "/api";
      return configured;
    }
    const apiBase = resolveApiBase2();
    const route = useRoute();
    const router = useRouter();
    const isKnowledgeBase = computed(() => route.path.startsWith("/knowledge-base"));
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
    watch(() => route.path, async (p) => {
      if (p.startsWith("/textbook")) {
        try {
          const q = route.query || {};
          const forced = String(q.force || "") === "1";
          const target = String(q.path || "");
          const last = false ? localStorage.getItem("textbook_last_path") : null;
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
        const s = await fetch(`${apiBase}/v1/slides?textbook_path=${encodeURIComponent("index")}`, { headers: { "X-API-Key": apiKey } });
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
      try {
        const r = await fetch(`${apiBase}/v1/knowledge-base/item?path=${encodeURIComponent("index.md")}`, { headers: { "X-API-Key": apiKey } });
        if (!r.ok) {
          throw new Error("failed");
        }
        const d = await r.json();
        tbContent.value = (d == null ? void 0 : d.content) || "# Welcome";
        tbSlide.value = null;
        tbPath.value = "index.md";
      } catch {
        tbContent.value = "# Knowledge Base\n\n\uC88C\uCE21\uC5D0\uC11C \uBB38\uC11C\uB97C \uC120\uD0DD\uD558\uAC70\uB098 index.md\uB97C \uC0DD\uC131\uD558\uC138\uC694.";
        tbSlide.value = null;
        tbPath.value = "";
      }
    }
    const handleFileClick = async (path) => {
      try {
        if (!route.path.startsWith("/textbook")) {
          await router.push({ path: "/textbook", query: { path, force: "1" } });
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
        const url = `${apiBase}/v1/knowledge-base/item?path=${encodeURIComponent(path)}`;
        const r = await fetch(url, {
          headers: { "X-API-Key": apiKey }
        });
        if (!r.ok) {
          let detail = "";
          try {
            const d2 = await r.json();
            detail = (d2 == null ? void 0 : d2.detail) || "";
          } catch {
            try {
              detail = await r.text();
            } catch {
            }
          }
          throw new Error(`KB item ${r.status} ${detail}`);
        }
        const d = await r.json();
        tbContent.value = (d == null ? void 0 : d.content) || "";
        tbSlide.value = null;
      } catch (error2) {
        console.error("Error fetching textbook content:", error2);
        tbContent.value = `Error loading content. ${(error2 == null ? void 0 : error2.message) || ""}`;
        tbSlide.value = null;
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
      var _a, _b;
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
        if ((_a = splitEditor.value) == null ? void 0 : _a.handleConflict) {
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
    async function onTreeSelect(p) {
      await handleKbFileSelect(p);
      kbTab.value = "tiptap";
    }
    watch(kbTab, (v) => {
      try {
        if (false) ;
      } catch {
      }
    });
    return (_ctx, _push, _parent, _attrs) => {
      const _component_NuxtLink = __nuxt_component_0;
      _push(`<div${ssrRenderAttrs(mergeProps({ class: "h-screen flex flex-col" }, _attrs))}><nav class="bg-white shadow-sm border-b z-10"><div class="max-w-full mx-auto px-4 sm:px-6 lg:px-8"><div class="flex justify-between h-16"><div class="flex items-center"><button class="mr-3 p-2 rounded hover:bg-gray-100 focus:outline-none" title="Toggle sidebar"><svg class="w-5 h-5 text-gray-700" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16"></path></svg></button><a href="/" class="text-xl font-bold text-gray-900"> MentorAi </a></div><div class="flex items-center space-x-4">`);
      _push(ssrRenderComponent(_component_NuxtLink, {
        to: "/textbook",
        class: "text-gray-700 hover:text-gray-900 px-3 py-2 rounded-md text-sm font-medium"
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
      _push(`<a href="/knowledge-base" class="text-gray-700 hover:text-gray-900 px-3 py-2 rounded-md text-sm font-medium"> \uC9C0\uC2DD\uBCA0\uC774\uC2A4 </a><a href="/login" class="text-gray-700 hover:text-gray-900 px-3 py-2 rounded-md text-sm font-medium"> \uB85C\uADF8\uC778 </a></div></div></div></nav><div class="flex flex-grow overflow-hidden bg-gray-100 relative">`);
      if (!isKnowledgeBase.value || isKnowledgeBase.value && kbTab.value !== "markdown") {
        _push(`<aside class="bg-white border-r border-gray-200 flex-shrink-0 overflow-y-auto shadow-md transition-all duration-200" style="${ssrRenderStyle({ width: unref(isSidebarCollapsed) ? "0px" : unref(sidebarWidth) + "px" })}"><div style="${ssrRenderStyle(!unref(isSidebarCollapsed) ? null : { display: "none" })}">`);
        _push(ssrRenderComponent(_sfc_main$e, { onFileClick: handleFileClick }, null, _parent));
        _push(`</div></aside>`);
      } else {
        _push(`<!---->`);
      }
      if ((!isKnowledgeBase.value || isKnowledgeBase.value && kbTab.value !== "markdown") && !unref(isSidebarCollapsed)) {
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
          _push(ssrRenderComponent(_sfc_main$a, {
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
            _push(ssrRenderComponent(_sfc_main$3, {
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
      } else if (isHome.value) {
        _push(`<div class="h-full">`);
        ssrRenderSlot(_ctx.$slots, "default", {}, null, _push, _parent);
        _push(`</div>`);
      } else {
        _push(ssrRenderComponent(_sfc_main$5, {
          "active-content": tbContent.value,
          "active-slide": tbSlide.value,
          "active-path": tbPath.value,
          readonly: true,
          ref_key: "workspaceView",
          ref: workspaceView
        }, null, _parent));
      }
      _push(`</div></main>`);
      if (!isKnowledgeBase.value) {
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
      if (!isKnowledgeBase.value && chatVisible.value) {
        _push(`<div class="chat-resizer" style="${ssrRenderStyle({ right: chatWidth.value + "px" })}"></div>`);
      } else {
        _push(`<!---->`);
      }
      if (!isKnowledgeBase.value && chatVisible.value) {
        _push(`<aside class="bg-white border-l border-gray-200 flex-shrink-0 overflow-y-auto shadow-md" style="${ssrRenderStyle({ width: chatWidth.value + "px" })}">`);
        _push(ssrRenderComponent(_sfc_main$4, null, null, _parent));
        _push(`</aside>`);
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

export { _sfc_main as default };
//# sourceMappingURL=default-D43ei22H.mjs.map
