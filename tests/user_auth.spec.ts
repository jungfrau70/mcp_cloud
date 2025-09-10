import { test, expect } from '@playwright/test';

// Helper to generate a unique email for each test run
const generateUniqueEmail = () => {
  const randomString = Math.random().toString(36).substring(2, 10);
  return `testuser_${randomString}@example.com`;
};

test.describe('User Authentication Flow', () => {
  const user = {
    email: generateUniqueEmail(),
    password: 'password123',
    fullName: 'Test User',
  };

  test('should allow a user to register, log in, and log out', async ({ page, baseURL }) => {
    const appUrl = baseURL || 'http://localhost:3000';

    // --- Registration ---
    await page.goto(`${appUrl}/register`);
    try {
      await expect(page.getByRole('heading', { name: '회원가입' })).toBeVisible({ timeout: 10000 });
    } catch (e) {
      console.log('Initial load failed, reloading page...');
      await page.reload();
      await expect(page.getByRole('heading', { name: '회원가입' })).toBeVisible({ timeout: 15000 });
    }

    await page.getByLabel('이메일').fill(user.email);
    await page.getByLabel('이름(선택)').fill(user.fullName);
    await page.getByLabel('비밀번호').fill(user.password);
    await page.getByRole('button', { name: '회원가입' }).click();

    // Because we are in test mode, the user is active immediately.
    // The app redirects to /verify-email, but we can proceed to login.
    await page.waitForURL(`${appUrl}/verify-email`);

    // --- Login ---
    await page.goto(`${appUrl}/login`);
    await expect(page.getByRole('heading', { name: '로그인' })).toBeVisible({ timeout: 10000 });

    await page.getByLabel('이메일').fill(user.email);
    await page.getByLabel('비밀번호').fill(user.password);
    await page.getByRole('button', { name: '로그인' }).click();

    // After login, user is redirected and we should see their email
    await page.waitForURL(`${appUrl}/curriculum`);
    await expect(page.getByText(user.email)).toBeVisible();

    // --- Logout ---
    await page.getByRole('button', { name: '로그아웃' }).click();

    // After logout, user is redirected to home and should see the login link
    await page.waitForURL(`${appUrl}/`);
    await expect(page.getByRole('link', { name: '로그인' })).toBeVisible();
  });
});
