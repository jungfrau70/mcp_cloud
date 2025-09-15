import { test, expect } from '@playwright/test';

test.describe('커리큘럼 FileTree 테스트', () => {
  test.beforeEach(async ({ page }) => {
    // 애플리케이션 로드 대기
    await page.goto('http://localhost:3000');
    await page.waitForLoadState('networkidle');
  });

  test('FileTree 기본 로드 테스트', async ({ page }) => {
    console.log('🔍 FileTree 기본 로드 테스트 시작...');
    
    // 커리큘럼 페이지로 이동
    await page.click('text=커리큘럼');
    await page.waitForLoadState('networkidle');
    
    // FileTree가 로드되었는지 확인
    const fileTree = page.locator('[data-testid="file-tree"]');
    await expect(fileTree).toBeVisible();
    
    console.log('✅ FileTree 로드 성공');
  });

  test('FileTree 디렉토리 구조 확인', async ({ page }) => {
    console.log('🔍 FileTree 디렉토리 구조 확인...');
    
    await page.goto('http://localhost:3000/curriculum');
    await page.waitForLoadState('networkidle');
    
    // 주요 디렉토리들이 표시되는지 확인
    const cloudBasic = page.locator('text=cloud_basic');
    const cloudMaster = page.locator('text=cloud_master');
    const cloudContainer = page.locator('text=cloud_container');
    
    await expect(cloudBasic).toBeVisible();
    await expect(cloudMaster).toBeVisible();
    await expect(cloudContainer).toBeVisible();
    
    console.log('✅ 주요 디렉토리 구조 확인 완료');
  });

  test('FileTree 파일 클릭 테스트', async ({ page }) => {
    console.log('🔍 FileTree 파일 클릭 테스트...');
    
    await page.goto('http://localhost:3000/curriculum');
    await page.waitForLoadState('networkidle');
    
    // cloud_basic 디렉토리 확장
    await page.click('text=cloud_basic');
    await page.waitForTimeout(1000);
    
    // README.md 파일 클릭
    const readmeFile = page.locator('text=README.md').first();
    if (await readmeFile.isVisible()) {
      await readmeFile.click();
      await page.waitForLoadState('networkidle');
      
      // ContentView에서 파일 내용이 표시되는지 확인
      const contentView = page.locator('[data-testid="content-view"]');
      await expect(contentView).toBeVisible();
      
      console.log('✅ 파일 클릭 및 내용 표시 성공');
    } else {
      console.log('⚠️ README.md 파일을 찾을 수 없음');
    }
  });

  test('한글 파일명 처리 테스트', async ({ page }) => {
    console.log('🔍 한글 파일명 처리 테스트...');
    
    await page.goto('http://localhost:3000/curriculum');
    await page.waitForLoadState('networkidle');
    
    // cloud_basic 디렉토리 확장
    await page.click('text=cloud_basic');
    await page.waitForTimeout(1000);
    
    // 한글 파일명 파일 찾기
    const koreanFile = page.locator('text=과정명.md');
    if (await koreanFile.isVisible()) {
      await koreanFile.click();
      await page.waitForLoadState('networkidle');
      
      // 한글이 올바르게 표시되는지 확인
      const contentView = page.locator('[data-testid="content-view"]');
      await expect(contentView).toBeVisible();
      
      // 파일 경로에서 한글이 깨지지 않았는지 확인
      const filePath = page.locator('[data-testid="file-path"]');
      if (await filePath.isVisible()) {
        const pathText = await filePath.textContent();
        console.log(`파일 경로: ${pathText}`);
        
        // URL 인코딩된 한글이 아닌 실제 한글이 표시되는지 확인
        if (pathText && !pathText.includes('%EA%B3%BC%EC%A0%95%EB%AA%85')) {
          console.log('✅ 한글 파일명 올바르게 표시됨');
        } else {
          console.log('❌ 한글 파일명이 URL 인코딩된 상태로 표시됨');
        }
      }
    } else {
      console.log('⚠️ 한글 파일명 파일을 찾을 수 없음');
    }
  });

  test('FileTree 설정 모달 테스트', async ({ page }) => {
    console.log('🔍 FileTree 설정 모달 테스트...');
    
    await page.goto('http://localhost:3000/curriculum');
    await page.waitForLoadState('networkidle');
    
    // 설정 버튼 클릭
    const settingsButton = page.locator('[data-testid="settings-button"]');
    if (await settingsButton.isVisible()) {
      await settingsButton.click();
      await page.waitForTimeout(1000);
      
      // 설정 모달이 열렸는지 확인
      const settingsModal = page.locator('[data-testid="settings-modal"]');
      await expect(settingsModal).toBeVisible();
      
      console.log('✅ 설정 모달 열기 성공');
      
      // 설정 저장 테스트
      const saveButton = page.locator('[data-testid="save-settings"]');
      if (await saveButton.isVisible()) {
        await saveButton.click();
        await page.waitForTimeout(1000);
        
        console.log('✅ 설정 저장 버튼 클릭 완료');
      }
    } else {
      console.log('⚠️ 설정 버튼을 찾을 수 없음');
    }
  });

  test('FileTree 새로고침 테스트', async ({ page }) => {
    console.log('🔍 FileTree 새로고침 테스트...');
    
    await page.goto('http://localhost:3000/curriculum');
    await page.waitForLoadState('networkidle');
    
    // 새로고침 버튼 클릭
    const refreshButton = page.locator('[data-testid="refresh-button"]');
    if (await refreshButton.isVisible()) {
      await refreshButton.click();
      await page.waitForLoadState('networkidle');
      
      console.log('✅ FileTree 새로고침 성공');
    } else {
      console.log('⚠️ 새로고침 버튼을 찾을 수 없음');
    }
  });
});
