import { test, expect } from '@playwright/test';

test('홈 페이지 타이틀 확인', async ({ page, baseURL }) => {
  await page.goto(baseURL || '/', { waitUntil: 'domcontentloaded' });
  await expect(page).toHaveTitle(/Bigs|Nuxt|MentorAi/i);
});

test('탑 네비게이션 존재 확인', async ({ page, baseURL }) => {
  await page.goto(baseURL || '/', { waitUntil: 'domcontentloaded' });
  const kbLink = page.getByRole('link', { name: /지식베이스|knowledge-base|login/i });
  await expect(kbLink.first()).toBeVisible();
});


