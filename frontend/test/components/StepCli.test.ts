import { mount } from '@vue/test-utils';
import { describe, it, expect, vi } from 'vitest';
import { nextTick } from 'vue';
import StepCli from '../../components/StepCli.client.vue';

// Mock xterm.js and its addon
vi.mock('xterm', () => ({
  Terminal: vi.fn(() => ({
    loadAddon: vi.fn(),
    open: vi.fn(),
    onData: vi.fn(),
    writeln: vi.fn(),
    write: vi.fn(),
    dispose: vi.fn(),
  })),
}));

vi.mock('xterm-addon-fit', () => ({
  FitAddon: vi.fn(() => ({
    fit: vi.fn(),
  })),
}));

// Mock CSS import (dynamic import in component)
vi.mock('xterm/css/xterm.css', () => ({}));

// Mock WebSocket
vi.stubGlobal('WebSocket', vi.fn(() => ({
  send: vi.fn(),
  close: vi.fn(),
  readyState: 1, // OPEN
  onopen: null,
  onmessage: null,
  onerror: null,
  onclose: null,
})));

describe('StepCli.client.vue', () => {
  it('renders the terminal container', async () => {
  const wrapper = mount(StepCli);
  const flush = () => new Promise(r => setTimeout(r, 0));
  await nextTick();
  await flush();
  await nextTick();
  await flush();

    // Check if the main div for the terminal is present
    expect(wrapper.find('#terminal').exists()).toBe(true);

    // Check if the introductory paragraph is rendered
    expect(wrapper.text()).toContain('아래는 실제 서버와 연결된 대화형 셸입니다.');

    // Ensure xterm.js Terminal and FitAddon are instantiated
    const { Terminal } = await import('xterm'); // Re-import to get the mocked version
    const { FitAddon } = await import('xterm-addon-fit'); // Re-import to get the mocked version
  expect(Terminal).toHaveBeenCalled();
  expect(FitAddon).toHaveBeenCalled();

    // Ensure WebSocket is instantiated
    expect(WebSocket).toHaveBeenCalledWith('ws://localhost:8000/ws/v1/cli/interactive');
  });
});