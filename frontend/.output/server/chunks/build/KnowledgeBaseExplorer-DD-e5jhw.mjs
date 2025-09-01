import { defineComponent, ref, watch, unref, mergeProps, computed, nextTick, useSSRContext } from 'vue';
import { ssrRenderComponent, ssrRenderList, ssrRenderAttr, ssrInterpolate, ssrIncludeBooleanAttr, ssrLooseContain, ssrRenderAttrs, ssrLooseEqual, ssrRenderStyle, ssrRenderClass } from 'vue/server-renderer';
import { u as useRuntimeConfig } from './server.mjs';
import { defineStore } from 'pinia';
import { _ as _export_sfc } from './_plugin-vue_export-helper-1tPrXgE0.mjs';

function resolveApiBase() {
  var _a;
  const config = useRuntimeConfig();
  const configured = ((_a = config.public) == null ? void 0 : _a.apiBaseUrl) || "/api";
  function ensureApiPath(base) {
    try {
      const u = new URL(base);
      const path = (u.pathname || "/").replace(/\/+/g, "/");
      if (path === "/" || path === "") {
        u.pathname = "/api";
        return u.toString().replace(/\/$/, "");
      }
      return base.replace(/\/$/, "");
    } catch {
      return base;
    }
  }
  return ensureApiPath(configured);
}
function useKbApi() {
  var _a;
  const apiBase = resolveApiBase();
  const config = useRuntimeConfig();
  const apiKey = ((_a = config == null ? void 0 : config.public) == null ? void 0 : _a.apiKey) || "my_mcp_eagle_tiger";
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
    return request(`${apiBase}/v1/curriculum/item?path=${encodeURIComponent(path)}`, { headers: { "X-API-Key": apiKey } }, "getItem failed");
  }
  async function saveItem(path, content, message, expectedVersion) {
    return request(`${apiBase}/_deprecated/kb/item`, {
      method: "PATCH",
      headers: { "Content-Type": "application/json", "X-API-Key": apiKey },
      body: JSON.stringify({ path, content, message, expected_version_no: expectedVersion })
    }, "saveItem failed");
  }
  async function listVersions(path) {
    return request(`${apiBase}/v1/knowledge-base/versions?path=${encodeURIComponent(path)}`, { headers: { "X-API-Key": apiKey } }, "listVersions failed");
  }
  async function outline(content) {
    return request(`${apiBase}/v1/knowledge-base/outline`, {
      method: "POST",
      headers: { "Content-Type": "application/json", "X-API-Key": apiKey },
      body: JSON.stringify({ content })
    }, "outline failed");
  }
  async function startCompose(topic, failStage) {
    const qs = new URLSearchParams({ topic });
    if (failStage) qs.append("fail_stage", failStage);
    return request(`${apiBase}/v1/knowledge-base/compose/external?${qs.toString()}`, { method: "POST", headers: { "X-API-Key": apiKey } }, "compose failed");
  }
  async function getTask(id) {
    return request(`${apiBase}/v1/knowledge-base/tasks/${id}`, { headers: { "X-API-Key": apiKey } }, "task failed");
  }
  async function diff(path, v1, v2) {
    return request(`${apiBase}/v1/knowledge-base/diff?path=${encodeURIComponent(path)}&v1=${v1}&v2=${v2}`, { headers: { "X-API-Key": apiKey } }, "diff failed");
  }
  async function structuredDiff(path, v1, v2) {
    return request(`${apiBase}/v1/knowledge-base/diff/structured?path=${encodeURIComponent(path)}&v1=${v1}&v2=${v2}`, { headers: { "X-API-Key": apiKey } }, "structured diff failed");
  }
  async function recentTasks(limit = 20) {
    return request(`${apiBase}/v1/knowledge-base/tasks/recent?limit=${limit}`, { headers: { "X-API-Key": apiKey } }, "recent tasks failed");
  }
  async function uploadAsset(file, subdir = "assets") {
    const form = new FormData();
    form.append("file", file);
    form.append("subdir", subdir);
    const r = await fetch(`${apiBase}/v1/assets/upload`, { method: "POST", headers: { "X-API-Key": apiKey }, body: form });
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
      headers: { "Content-Type": "application/json", "X-API-Key": apiKey },
      body: JSON.stringify({ text, kind, ...opts || {} })
    }, "transform failed");
  }
  async function lint(text) {
    return request(`${apiBase}/v1/knowledge-base/lint`, {
      method: "POST",
      headers: { "Content-Type": "application/json", "X-API-Key": apiKey },
      body: JSON.stringify({ text })
    }, "lint failed");
  }
  async function listTrending() {
    return request(`${apiBase}/v1/trending/categories`, { headers: { "X-API-Key": apiKey } }, "trending list failed");
  }
  async function upsertTrending(item) {
    return request(`${apiBase}/v1/trending/categories`, {
      method: "POST",
      headers: { "Content-Type": "application/json", "X-API-Key": apiKey },
      body: JSON.stringify(item)
    }, "trending upsert failed");
  }
  async function deleteTrending(name) {
    return request(`${apiBase}/v1/trending/categories/${encodeURIComponent(name)}`, {
      method: "DELETE",
      headers: { "X-API-Key": apiKey }
    }, "trending delete failed");
  }
  async function runTrendingNow() {
    return request(`${apiBase}/v1/trending/run-now`, { method: "POST", headers: { "X-API-Key": apiKey } }, "trending run failed");
  }
  return { getItem, saveItem, listVersions, outline, startCompose, getTask, diff, structuredDiff, recentTasks, uploadAsset, transform, lint, listTrending, upsertTrending, deleteTrending, runTrendingNow, request };
}
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
const _sfc_main$5 = {
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
        const first = parts[0];
        if (directories.value[first]) {
          openDirectories.value[first] = true;
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
      _push(`<div${ssrRenderAttrs(mergeProps({ class: "file-tree" }, _attrs))} data-v-5b0bbf51><ul data-v-5b0bbf51><!--[-->`);
      ssrRenderList(sortedTree.value, (item, name) => {
        _push(`<li data-v-5b0bbf51><div class="${ssrRenderClass(["tree-item", { "is-directory": isDirectory(item), "is-open": isOpen(name), "drag-over": dragOverTarget.value === name }])}" style="${ssrRenderStyle({ "padding-left": __props.depth * 15 + "px" })}"${ssrRenderAttr("draggable", isDirectory(item))} data-v-5b0bbf51>`);
        if (isDirectory(item)) {
          _push(`<span class="icon" data-v-5b0bbf51>${ssrInterpolate(isOpen(name) ? "\u25BC" : "\u25B6")}</span>`);
        } else {
          _push(`<span class="icon" data-v-5b0bbf51>\u{1F4C4}</span>`);
        }
        _push(`<span class="name" data-v-5b0bbf51>${ssrInterpolate(name)}</span>`);
        if (isDirectory(item)) {
          _push(`<div class="directory-actions" data-v-5b0bbf51><button class="action-btn" title="\uC0C8 \uD56D\uBAA9 \uC0DD\uC131" data-v-5b0bbf51>+</button></div>`);
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
        _push(`<li data-v-5b0bbf51><div class="${ssrRenderClass(["tree-item", "is-file", { "is-selected": __props.selectedFile === (file.path || constructPath(file)) }])}"${ssrRenderAttr("data-path", file.path || constructPath(file))} style="${ssrRenderStyle({ "padding-left": __props.depth * 15 + "px" })}" draggable="true" data-v-5b0bbf51><span class="icon" data-v-5b0bbf51>\u{1F4C4}</span><span class="name" data-v-5b0bbf51>${ssrInterpolate(file.name || file)}</span></div></li>`);
      });
      _push(`<!--]--></ul>`);
      if (showDirectoryContextMenu.value) {
        _push(`<div style="${ssrRenderStyle({ left: contextMenuX.value + "px", top: contextMenuY.value + "px" })}" class="context-menu" data-v-5b0bbf51><div class="context-menu-item" data-v-5b0bbf51>\u{1F4C1} \uC0C8 \uB514\uB809\uD1A0\uB9AC</div><div class="context-menu-item" data-v-5b0bbf51>\u{1F4C4} \uC0C8 \uD30C\uC77C</div><div class="context-menu-divider" data-v-5b0bbf51></div><div class="context-menu-item" data-v-5b0bbf51>\u270F\uFE0F \uC774\uB984 \uBCC0\uACBD</div><div class="context-menu-item text-red-600" data-v-5b0bbf51>\u{1F5D1}\uFE0F \uC0AD\uC81C</div></div>`);
      } else {
        _push(`<!---->`);
      }
      if (showFileContextMenu.value) {
        _push(`<div style="${ssrRenderStyle({ left: contextMenuX.value + "px", top: contextMenuY.value + "px" })}" class="context-menu" data-v-5b0bbf51>`);
        if (!isSelectedInTrash.value) {
          _push(`<div class="context-menu-item" data-v-5b0bbf51>\u270F\uFE0F \uC774\uB984 \uBCC0\uACBD</div>`);
        } else {
          _push(`<!---->`);
        }
        if (!isSelectedInTrash.value) {
          _push(`<div class="context-menu-item text-red-600" data-v-5b0bbf51>\u{1F5D1}\uFE0F \uC0AD\uC81C(\uD734\uC9C0\uD1B5\uC73C\uB85C)</div>`);
        } else {
          _push(`<!---->`);
        }
        if (isSelectedInTrash.value) {
          _push(`<div class="context-menu-item" data-v-5b0bbf51>\u21A9\uFE0F \uBCF5\uAD6C</div>`);
        } else {
          _push(`<!---->`);
        }
        if (isSelectedInTrash.value) {
          _push(`<div class="context-menu-item text-red-600" data-v-5b0bbf51>\u274C \uC601\uAD6C \uC0AD\uC81C</div>`);
        } else {
          _push(`<!---->`);
        }
        _push(`</div>`);
      } else {
        _push(`<!---->`);
      }
      if (showCreateMenu.value) {
        _push(`<div style="${ssrRenderStyle({ left: contextMenuX.value + "px", top: contextMenuY.value + "px" })}" class="context-menu" data-v-5b0bbf51><div class="context-menu-item" data-v-5b0bbf51>\u{1F4C1} \uC0C8 \uB514\uB809\uD1A0\uB9AC</div><div class="context-menu-item" data-v-5b0bbf51>\u{1F4C4} \uC0C8 \uD30C\uC77C</div></div>`);
      } else {
        _push(`<!---->`);
      }
      if (showRenameDialog.value) {
        _push(`<div class="modal-overlay" data-v-5b0bbf51><div class="modal-content" data-v-5b0bbf51><h3 class="modal-title" data-v-5b0bbf51>\uC774\uB984 \uBCC0\uACBD</h3><input${ssrRenderAttr("value", newName.value)} class="modal-input" placeholder="\uC0C8 \uC774\uB984\uC744 \uC785\uB825\uD558\uC138\uC694" data-v-5b0bbf51><div class="modal-actions" data-v-5b0bbf51><button class="btn-primary" data-v-5b0bbf51>\uD655\uC778</button><button class="btn-secondary" data-v-5b0bbf51>\uCDE8\uC18C</button></div></div></div>`);
      } else {
        _push(`<!---->`);
      }
      if (showCreateDialog.value) {
        _push(`<div class="modal-overlay" data-v-5b0bbf51><div class="modal-content" data-v-5b0bbf51><h3 class="modal-title" data-v-5b0bbf51>${ssrInterpolate(createType.value === "directory" ? "\uC0C8 \uB514\uB809\uD1A0\uB9AC" : "\uC0C8 \uD30C\uC77C")}</h3><input${ssrRenderAttr("value", newName.value)} class="modal-input"${ssrRenderAttr("placeholder", createType.value === "directory" ? "\uB514\uB809\uD1A0\uB9AC \uC774\uB984" : "\uD30C\uC77C \uC774\uB984")} data-v-5b0bbf51><div class="modal-actions" data-v-5b0bbf51><button class="btn-primary" data-v-5b0bbf51>\uC0DD\uC131</button><button class="btn-secondary" data-v-5b0bbf51>\uCDE8\uC18C</button></div></div></div>`);
      } else {
        _push(`<!---->`);
      }
      _push(`</div>`);
    };
  }
};
const _sfc_setup$5 = _sfc_main$5.setup;
_sfc_main$5.setup = (props, ctx) => {
  const ssrContext = useSSRContext();
  (ssrContext.modules || (ssrContext.modules = /* @__PURE__ */ new Set())).add("components/FileTree.vue");
  return _sfc_setup$5 ? _sfc_setup$5(props, ctx) : void 0;
};
const FileTree = /* @__PURE__ */ _export_sfc(_sfc_main$5, [["__scopeId", "data-v-5b0bbf51"]]);
const _sfc_main$4 = /* @__PURE__ */ defineComponent({
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
const _sfc_setup$4 = _sfc_main$4.setup;
_sfc_main$4.setup = (props, ctx) => {
  const ssrContext = useSSRContext();
  (ssrContext.modules || (ssrContext.modules = /* @__PURE__ */ new Set())).add("components/FileTreePanel.vue");
  return _sfc_setup$4 ? _sfc_setup$4(props, ctx) : void 0;
};
const _sfc_main$3 = /* @__PURE__ */ defineComponent({
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
const _sfc_setup$3 = _sfc_main$3.setup;
_sfc_main$3.setup = (props, ctx) => {
  const ssrContext = useSSRContext();
  (ssrContext.modules || (ssrContext.modules = /* @__PURE__ */ new Set())).add("components/SearchPanel.vue");
  return _sfc_setup$3 ? _sfc_setup$3(props, ctx) : void 0;
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
const _sfc_main$2 = /* @__PURE__ */ defineComponent({
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
const _sfc_setup$2 = _sfc_main$2.setup;
_sfc_main$2.setup = (props, ctx) => {
  const ssrContext = useSSRContext();
  (ssrContext.modules || (ssrContext.modules = /* @__PURE__ */ new Set())).add("components/ExternalGeneratePanel.vue");
  return _sfc_setup$2 ? _sfc_setup$2(props, ctx) : void 0;
};
const _sfc_main$1 = /* @__PURE__ */ defineComponent({
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
const _sfc_setup$1 = _sfc_main$1.setup;
_sfc_main$1.setup = (props, ctx) => {
  const ssrContext = useSSRContext();
  (ssrContext.modules || (ssrContext.modules = /* @__PURE__ */ new Set())).add("components/TrendingCategoriesModal.vue");
  return _sfc_setup$1 ? _sfc_setup$1(props, ctx) : void 0;
};
const _sfc_main = {
  __name: "KnowledgeBaseExplorer",
  __ssrInlineRender: true,
  props: {
    // mode: 'full' (검색+트리), 'search' (검색 패널), 'tree' (파일 트리만)
    mode: { type: String, default: "full" },
    selectedFile: { type: String, default: "" }
  },
  emits: ["file-select"],
  setup(__props, { emit: __emit }) {
    var _a;
    const emit = __emit;
    const props = __props;
    const config = useRuntimeConfig();
    function resolveApiBase2() {
      var _a2;
      const configured = ((_a2 = config.public) == null ? void 0 : _a2.apiBaseUrl) || "/api";
      return configured;
    }
    const apiBase = resolveApiBase2();
    const apiKey = ((_a = config.public) == null ? void 0 : _a.apiKey) || "my_mcp_eagle_tiger";
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
          headers: { "X-API-Key": apiKey }
        });
        if (!response.ok) throw new Error("Failed to load structure");
        const data = await response.json();
        treeData.value = { "mcp_knowledge_base": data };
      } catch (error) {
        console.error("Error loading structure:", error);
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
        const response = await fetch(`${apiBase}/v1/knowledge-base/item`, {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
            "X-API-Key": apiKey
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
      } catch (error) {
        console.error(`Error creating ${data.type}:`, error);
        statusMessage.value = `${data.type === "file" ? "\uD30C\uC77C" : "\uB514\uB809\uD1A0\uB9AC"} \uC0DD\uC131 \uC2E4\uD328: ${error.message}`;
      }
    };
    const handleDirectoryRename = async (data) => {
      try {
        console.log("Renaming item:", data);
        const response = await fetch(`${apiBase}/v1/knowledge-base/item`, {
          method: "PATCH",
          headers: {
            "Content-Type": "application/json",
            "X-API-Key": apiKey
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
      } catch (error) {
        console.error("Error renaming item:", error);
        statusMessage.value = `\uC774\uB984 \uBCC0\uACBD \uC2E4\uD328: ${error.message}`;
      }
    };
    const handleDirectoryDelete = async (data) => {
      try {
        console.log("Deleting item:", data);
        if (data.type === "file") {
          const response = await fetch(`${apiBase}/v1/knowledge-base/item?path=${encodeURIComponent(stripBasePath(data.path))}`, {
            method: "DELETE",
            headers: { "X-API-Key": apiKey }
          });
          if (!response.ok) {
            const errorData = await response.json();
            throw new Error(`Failed to delete file: ${response.status} ${errorData.detail || "Unknown error"}`);
          }
          statusMessage.value = "\uD30C\uC77C \uC0AD\uC81C \uC644\uB8CC";
        } else {
          const response = await fetch(`${apiBase}/v1/knowledge-base/directory?path=${encodeURIComponent(stripBasePath(data.path))}&recursive=true`, {
            method: "DELETE",
            headers: { "X-API-Key": apiKey }
          });
          if (!response.ok) {
            const errorData = await response.json();
            throw new Error(`Failed to delete directory: ${response.status} ${errorData.detail || "Unknown error"}`);
          }
          statusMessage.value = "\uB514\uB809\uD1A0\uB9AC \uC0AD\uC81C \uC644\uB8CC";
        }
        await loadKnowledgeBaseStructure();
      } catch (error) {
        console.error("Error deleting item:", error);
        statusMessage.value = `\uC0AD\uC81C \uC2E4\uD328: ${error.message}`;
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
        const response = await fetch(`${apiBase}/v1/knowledge-base/move`, {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
            "X-API-Key": apiKey
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
      } catch (error) {
        console.error("Error moving file:", error);
        statusMessage.value = `\uD30C\uC77C \uC774\uB3D9 \uC2E4\uD328: ${error.message}`;
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
          _push(ssrRenderComponent(_sfc_main$4, {
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
        _push(ssrRenderComponent(_sfc_main$3, {
          "api-base": unref(apiBase),
          "api-key": unref(apiKey),
          onOpen: ($event) => emit("file-select", $event)
        }, null, _parent));
        _push(`<div class="border rounded bg-white flex-1 min-h-0 overflow-hidden"><div class="h-full min-h-0 overflow-auto">`);
        if (isInitialLoading.value) {
          _push(`<div class="text-center py-8 text-sm text-gray-500">\uB85C\uB529 \uC911\u2026</div>`);
        } else {
          _push(ssrRenderComponent(_sfc_main$4, {
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
          _push(ssrRenderComponent(_sfc_main$2, {
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
        _push(ssrRenderComponent(_sfc_main$1, {
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
const _sfc_setup = _sfc_main.setup;
_sfc_main.setup = (props, ctx) => {
  const ssrContext = useSSRContext();
  (ssrContext.modules || (ssrContext.modules = /* @__PURE__ */ new Set())).add("components/KnowledgeBaseExplorer.vue");
  return _sfc_setup ? _sfc_setup(props, ctx) : void 0;
};

export { _sfc_main as _, useKbApi as a, _sfc_main$4 as b, resolveApiBase as r, useToastStore as u };
//# sourceMappingURL=KnowledgeBaseExplorer-DD-e5jhw.mjs.map
