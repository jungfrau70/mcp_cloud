<template>
  <div>
    <p class="mb-4 text-gray-700">
      아래는 실제 서버와 연결된 대화형 셸입니다. 명령어를 입력하여 실습을 진행하세요.
    </p>
    <div id="terminal" ref="terminalContainer" class="bg-black text-white font-mono rounded-lg p-4 h-96 overflow-y-auto text-sm"></div>
  </div>
</template>

<script setup>
import { onMounted, onBeforeUnmount, ref } from 'vue';
import { useRuntimeConfig } from '#app';

const terminalContainer = ref(null);
let term;
let ws;

onMounted(async () => {
  const { Terminal } = await import('xterm');
  const { FitAddon } = await import('xterm-addon-fit');
  await import('xterm/css/xterm.css');

  term = new Terminal({
    cursorBlink: true,
    convertEol: true,
    fontFamily: `'Fira Code', monospace`,
    fontSize: 14,
    theme: {
      background: '#000000',
      foreground: '#FFFFFF',
    }
  });

  const fitAddon = new FitAddon();
  term.loadAddon(fitAddon);

  if (terminalContainer.value) {
    term.open(terminalContainer.value);
    fitAddon.fit();
  }

  // 동적으로 API URL 가져오기
  const config = useRuntimeConfig();
  const apiBase = config.public.apiBaseUrl || '/api';
  const wsUrl = apiBase.replace('http://', 'ws://').replace('https://', 'wss://') + '/ws/v1/cli/interactive';
  
  ws = new WebSocket(wsUrl);

  ws.onopen = () => {
    term.writeln('Connected to interactive shell...');
    // API 키를 첫 번째 메시지로 전송 (보안 강화)
    const apiKey = process.env.MCP_API_KEY || 'my_mcp_eagle_tiger';
    ws.send(JSON.stringify({ type: 'auth', api_key: apiKey }));
    ws.send('PS1="mcp-user@cloud-shell:~$ "\n');
  };

  ws.onmessage = (event) => {
    term.write(event.data);
  };

  ws.onerror = (error) => {
    console.error('WebSocket Error:', error);
    term.writeln('\n\n--- WebSocket Connection Error ---');
  };

  ws.onclose = () => {
    term.writeln('\n\n--- Shell session closed ---');
  };

  term.onData((data) => {
    if (ws.readyState === WebSocket.OPEN) {
      ws.send(data);
    }
  });
});

onBeforeUnmount(() => {
  if (ws) {
    ws.close();
  }
  if (term) {
    term.dispose();
  }
});
</script>