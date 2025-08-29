import { test, expect } from '@playwright/test';

// Usage:
// set PLAYWRIGHT_BASE_URL=https://app.gostock.us
// set AUTHELIA_E2E_USER=admin
// set AUTHELIA_E2E_PASS=ChangeMe_123
// yarn test

const username = process.env.AUTHELIA_E2E_USER || '';
const password = process.env.AUTHELIA_E2E_PASS || '';

test.describe('Authelia login flow → app redirect', () => {
  test.skip(!username || !password, 'Set AUTHELIA_E2E_USER and AUTHELIA_E2E_PASS environment variables to run this test.');

  test('should require auth and redirect back to app after login', async ({ page, baseURL }) => {
    const appUrl = baseURL || 'http://localhost:3000';

    // 1) Open app → should be redirected to Authelia
    await page.goto(appUrl, { waitUntil: 'domcontentloaded' });

    // 2) Fill Authelia form (selectors tolerant to different themes/locales)
    const userInput = page.locator('input[name="username"], input#username, input[type="text"]');
    const passInput = page.locator('input[name="password"], input#password, input[type="password"]');
    await expect(userInput.first()).toBeVisible();
    await userInput.first().fill(username);
    await passInput.first().fill(password);

    const loginButton = page.getByRole('button', { name: /로그인|log ?in/i });
    await loginButton.click();

    // 3) Expect redirect back to app (URL host should NOT contain auth.)
    await page.waitForLoadState('networkidle');
    await expect.poll(async () => new URL(page.url()).hostname, { timeout: 15000 }).not.toContain('auth.');

    // 4) Basic sanity: app responds with 200 and renders some HTML
    await expect(page).toHaveTitle(/.+/);
  });
});


