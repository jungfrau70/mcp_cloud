<template>
  <div class="fixed inset-0 z-40 bg-black/40 flex items-center justify-center">
    <div class="w-[680px] max-w-[90vw] bg-white rounded shadow flex flex-col">
      <div class="p-3 border-b text-sm flex items-center">
        <span class="font-semibold">관심 카테고리 관리</span>
        <div class="flex-1"></div>
        <button @click="$emit('close')" class="px-2 py-1 text-xs border rounded">Close</button>
      </div>
      <div class="p-3 space-y-3">
        <div class="flex items-center gap-2">
          <input v-model="form.name" placeholder="이름(예: aws)" class="border rounded px-2 py-1 text-sm" />
          <input v-model="form.query" placeholder="검색 쿼리" class="border rounded px-2 py-1 text-sm flex-1" />
          <label class="text-xs flex items-center gap-1"><input type="checkbox" v-model="form.enabled" class="accent-indigo-600"/> enabled</label>
          <button @click="save" class="px-2 py-1 text-xs bg-indigo-600 text-white rounded">저장</button>
          <button @click="runNow" class="px-2 py-1 text-xs border rounded">Run Now</button>
        </div>
        <div class="border rounded">
          <table class="w-full text-sm">
            <thead>
              <tr class="bg-gray-50 text-left">
                <th class="px-2 py-1">이름</th>
                <th class="px-2 py-1">쿼리</th>
                <th class="px-2 py-1 w-20">사용</th>
                <th class="px-2 py-1 w-24"></th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="c in categories" :key="c.name" class="border-t">
                <td class="px-2 py-1">{{ c.name }}</td>
                <td class="px-2 py-1">{{ c.query }}</td>
                <td class="px-2 py-1">{{ c.enabled ? 'ON' : 'OFF' }}</td>
                <td class="px-2 py-1 text-right">
                  <button class="text-xs border rounded px-2 py-0.5 mr-1" @click="edit(c)">Edit</button>
                  <button class="text-xs border rounded px-2 py-0.5" @click="remove(c.name)">Del</button>
                </td>
              </tr>
              <tr v-if="!categories.length"><td class="px-2 py-4 text-center text-gray-400" colspan="4">No categories</td></tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>
  </div>
</template>
<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useKbApi } from '~/composables/useKbApi'

const emit = defineEmits(['close'])
const api = useKbApi()
const categories = ref<{name:string;query:string;enabled:boolean}[]>([])
const form = ref<{name:string;query:string;enabled:boolean}>({ name:'', query:'', enabled:true })

async function load(){
  const r = await api.listTrending()
  categories.value = r.categories || []
}
function edit(c: { name: string; query: string; enabled?: boolean }){ form.value = { name:c.name, query:c.query, enabled: !!c.enabled } }
async function save(){
  if(!form.value.name || !form.value.query) return
  await api.upsertTrending(form.value)
  await load()
}
async function remove(name:string){
  if(!confirm('삭제할까요?')) return
  await api.deleteTrending(name)
  await load()
}
async function runNow(){
  await api.runTrendingNow()
  alert('즉시 실행 요청을 보냈습니다.')
}

onMounted(load)
</script>

