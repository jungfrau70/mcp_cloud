import { describe, it, expect, vi, beforeEach } from 'vitest';
import { mount, flushPromises } from '@vue/test-utils';
import SearchPanel from '../../components/SearchPanel.vue';

// Mock global fetch
global.fetch = vi.fn();

describe('SearchPanel.vue', () => {
  const apiBase = 'http://localhost:8000';
  const apiKey = 'test-api-key';

  beforeEach(() => {
    (global.fetch as vi.Mock).mockClear();
  });

  it('renders correctly', () => {
    const wrapper = mount(SearchPanel, {
      props: { apiBase, apiKey },
    });
    expect(wrapper.find('input[type="text"]').exists()).toBe(true);
    expect(wrapper.find('button').text()).toBe('검색');
  });

  it('does not perform search with empty query', async () => {
    const wrapper = mount(SearchPanel, {
      props: { apiBase, apiKey },
    });
    await wrapper.find('button').trigger('click');
    expect(global.fetch).not.toHaveBeenCalled();
  });

  async function performSearch(wrapper: any) {
    const mockResults = { results: [{ id: 1, path: '/path/to/doc', title: 'Test Doc', content: 'Some content' }] };
    (global.fetch as vi.Mock).mockResolvedValue({
      ok: true,
      json: () => Promise.resolve(mockResults),
    });

    const input = wrapper.find('input[type="text"]');
    await input.setValue('test query');
    await wrapper.find('button').trigger('click');

    await flushPromises();
  }

  it('performs search when search button is clicked', async () => {
    const wrapper = mount(SearchPanel, {
      props: { apiBase, apiKey },
    });

    await performSearch(wrapper);

    expect(global.fetch).toHaveBeenCalledWith(
      `${apiBase}/api/v1/knowledge/search-enhanced`,
      expect.any(Object)
    );
    
    expect(wrapper.find('[data-testid="loading-indicator"]').exists()).toBe(false);
    expect(wrapper.findAll('[data-testid="result-item"]').length).toBe(1);
    expect(wrapper.find('.text-xs.font-medium').html()).toContain('Test Doc');
  });

  it('resets the search when reset button is clicked', async () => {
    const wrapper = mount(SearchPanel, {
      props: { apiBase, apiKey },
    });

    await performSearch(wrapper);

    // Reset button should be visible now
    const resetButton = wrapper.find('button.bg-gray-200');
    expect(resetButton.exists()).toBe(true);
    await resetButton.trigger('click');

    expect(wrapper.vm.query).toBe('');
    expect(wrapper.vm.searched).toBe(false);
    expect(wrapper.vm.results.length).toBe(0);
  });

  it('emits "open" event when a result is clicked', async () => {
    const wrapper = mount(SearchPanel, {
      props: { apiBase, apiKey },
    });

    await performSearch(wrapper);

    await wrapper.find('[data-testid="result-item"]').trigger('click');
    
    expect(wrapper.emitted().open).toBeTruthy();
    expect(wrapper.emitted().open[0]).toEqual(['/path/to/doc']);
  });
});