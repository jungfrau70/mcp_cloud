<template>
  <div class="h-full flex flex-col">
    <div class="flex-grow overflow-y-auto p-6 bg-white">
      <ClientOnly>
        <transition name="fade" mode="out-in">
          <div>
            <component :is="activeComponent" v-bind="viewProps" @navigate-tool="handleNavigation" />
          </div>
        </transition>
      </ClientOnly>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, shallowRef, watch, defineAsyncComponent } from 'vue';
import ContentView from './ContentView.vue';
import SplitEditor from './SplitEditor.vue';
const TipTapKbEditor = defineAsyncComponent(() => import('./TipTapKbEditor.client.vue'))
// Do NOT statically import StepCli to avoid SSR loading xterm; lazy-load on client only
const StepCli = process.client
  ? defineAsyncComponent(() => import(/* webpackChunkName: "step-cli" */ './StepCli.client.vue'))
  : null;
// Import other tool components here as they are created

const props = defineProps({
  activeContent: String,
  activeSlide: Object,
  activePath: String,
  readonly: { type: Boolean, default: false },
});

const activeComponent = shallowRef(ContentView);

const viewProps = computed(() => {
  if (activeComponent.value === ContentView) {
    return {
      content: props.activeContent,
      slide: props.activeSlide,
      path: props.activePath,
      readonly: props.readonly,
    };
  } else if (activeComponent.value === SplitEditor) {
    return { path: props.activePath, content: props.activeContent };
  }
  return {};
});

const toolComponents = {
  content: ContentView,
  'content-edit': TipTapKbEditor,
  ...(StepCli ? { cli: StepCli } : {}),
};

const handleNavigation = (event) => {
  const toolName = event.tool.toLowerCase();
  const next = toolComponents[toolName];
  if (next) {
    activeComponent.value = next;
  } else {
    console.warn(`Unknown tool: ${toolName}`);
  }
};

// Watch for content changes to switch back to the content view
watch(() => props.activeContent, (newContent) => {
  if (newContent) {
    activeComponent.value = ContentView;
  }
});

</script>

<style>
.fade-enter-active, .fade-leave-active {
  transition: opacity 0.3s ease;
}
.fade-enter-from, .fade-leave-to {
  opacity: 0;
}
</style>
