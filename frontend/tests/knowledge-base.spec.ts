import { test, expect } from '@playwright/test';

test.describe('Knowledge Base AI Document Generation', () => {
  test('should generate and save a document from AI', async ({ page }) => {
    // 1. Navigate to the knowledge base page and wait for it to be fully loaded
    await page.goto('/knowledge-base', { waitUntil: 'networkidle' }); // Wait until network is idle

    // Wait for the initial state message to be visible, indicating the page has rendered
    await expect(page.getByText('문서가 선택되지 않았습니다')).toBeVisible({ timeout: 15000 }); // Increased timeout

    // Now, wait for the "AI 문서 생성" button to be visible
    await expect(page.getByRole('button', { name: 'AI 문서 생성' })).toBeVisible({ timeout: 10000 }); // Increased timeout

    // 2. Click the "AI 문서 생성" button
    await page.getByRole('button', { name: 'AI 문서 생성' }).click();

    // Wait for the modal to appear
    await expect(page.getByRole('heading', { name: 'AI 문서 생성' })).toBeVisible();

    // 3. Fill in the query
    const query = 'AWS S3 버킷 생성 및 관리 방법';
    await page.getByPlaceholder('예: AWS S3 버킷 생성 방법').fill(query);

    // 4. Click the "생성" button
    await page.getByRole('button', { name: '생성' }).click();

    // Wait for loading to finish and success message
    await expect(page.getByText(/문서 생성 성공/)).toBeVisible({ timeout: 60000 }); // Increased timeout for AI generation

    // Verify that the editor is populated with the generated content
    // This assumes the generated content is loaded into the editor.content textarea
    // You might need to adjust the selector based on the actual editor implementation
    await expect(page.getByPlaceholder('제목')).toHaveValue(/AWS S3/); // Check title
    await expect(page.getByPlaceholder('내용 입력')).toContainText(/# AWS S3/); // Check content

    // 5. Click the "저장" button
    await page.getByRole('button', { name: '저장' }).click();

    // Wait for save message
    await expect(page.getByText('저장 완료')).toBeVisible();

    // Optional: Verify the document appears in the recent documents list
    // This would require navigating back or refreshing the page and checking the list
    // For simplicity, we'll skip this for now, as file creation is verified by backend tests.
  });

  test('should handle AI document generation failure', async ({ page }) => {
    // 1. Navigate to the knowledge base page and wait for it to be fully loaded
    await page.goto('/knowledge-base', { waitUntil: 'networkidle' }); // Wait until network is idle

    // Wait for the initial state message to be visible, indicating the page has rendered
    await expect(page.getByText('문서가 선택되지 않았습니다')).toBeVisible({ timeout: 15000 }); // Increased timeout

    // Now, wait for the "AI 문서 생성" button to be visible
    await expect(page.getByRole('button', { name: 'AI 문서 생성' })).toBeVisible({ timeout: 10000 }); // Increased timeout

    // 2. Click the "AI 문서 생성" button
    await page.getByRole('button', { name: 'AI 문서 생성' }).click();

    // Wait for the modal to appear
    await expect(page.getByRole('heading', { name: 'AI 문서 생성' })).toBeVisible();

    // 3. Fill in a query that is expected to cause a failure (e.g., a very short/ambiguous query)
    // In a real scenario, you might mock the backend response for failure.
    const query = 'fail'; // A query that might trigger a backend error or no results
    await page.getByPlaceholder('예: AWS S3 버킷 생성 방법').fill(query);

    // 4. Click the "생성" button
    await page.getByRole('button', { name: '생성' }).click();

    // Wait for error message
    await expect(page.getByText(/문서 생성 실패/)).toBeVisible({ timeout: 60000 }); // Increased timeout for AI generation
  });
});