<template>
  <div class="bg-white rounded-xl shadow-lg overflow-hidden h-full flex flex-col">
    <div class="p-6 border-b border-gray-200">
      <h2 class="text-2xl font-bold text-gray-800">
        <slot name="title">Step Title</slot>
      </h2>
    </div>
    <div class="p-6 flex-grow overflow-y-auto">
      <slot>
        <p>Step content goes here...</p>
      </slot>
    </div>
  </div>
</template>

<script setup>
// This is a generic container for any type of journey step content.
</script>
