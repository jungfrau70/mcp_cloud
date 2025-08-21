<template>
  <div class="fixed top-4 right-4 space-y-2 z-50 w-80">
    <transition-group name="toast-fade" tag="div">
      <div v-for="t in items" :key="t.id" class="px-4 py-3 rounded shadow text-sm flex items-start gap-2" :class="typeClass(t.type)">
        <span class="font-medium">{{ icon(t.type) }}</span>
        <span class="flex-1 whitespace-pre-wrap">{{ t.msg }}</span>
        <button class="opacity-60 hover:opacity-100" @click="remove(t.id)" aria-label="닫기">×</button>
      </div>
    </transition-group>
  </div>
</template>
<script setup lang="ts">
import { storeToRefs } from 'pinia'
import { useToastStore } from '~/stores/toast'
const toast = useToastStore()
const { items } = storeToRefs(toast)
const remove = toast.remove
function typeClass(t: string){
  if(t==='success') return 'bg-green-600 text-white'
  if(t==='error') return 'bg-red-600 text-white'
  if(t==='warn') return 'bg-yellow-500 text-white'
  return 'bg-slate-700 text-white'
}
function icon(t: string){
  if(t==='success') return '✔'
  if(t==='error') return '✖'
  if(t==='warn') return '!'
  return 'ℹ'
}
</script>
<style scoped>
.toast-fade-enter-active,.toast-fade-leave-active{transition:all .25s}
.toast-fade-enter-from{opacity:0;transform:translateY(-6px)}
.toast-fade-leave-to{opacity:0;transform:translateY(-6px)}
</style>
