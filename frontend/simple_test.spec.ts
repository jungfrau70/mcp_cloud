import { test, expect } from '@playwright/test';

test('로그인 및 커리큘럼 페이지 접근 테스트', async ({ page }) => {
  // 로컬 서버로 이동
  await page.goto('http://localhost:3000');
  
  // 페이지 제목 확인
  await expect(page).toHaveTitle(/Bigs/);
  
  // 로그인 페이지인지 확인
  const loginHeading = page.locator('h1:has-text("로그인")');
  if (await loginHeading.isVisible({ timeout: 5000 })) {
    console.log('로그인 페이지 감지됨. 로그인을 시도합니다.');
    
    // 이메일 입력
    await page.fill('input[type="email"], input[name="email"], input[placeholder*="이메일"], input[placeholder*="email"]', 'inhwan.jung@gmail.com');
    
    // 비밀번호 입력
    await page.fill('input[type="password"], input[name="password"], input[placeholder*="비밀번호"], input[placeholder*="password"]', 'bright2n');
    
    // 로그인 버튼 클릭
    await page.click('button:has-text("로그인")');
    
    // 로그인 완료 대기
    await page.waitForLoadState('networkidle');
    
    console.log('로그인 완료');
  }
  
  // 커리큘럼 페이지로 이동
  await page.goto('http://localhost:3000/knowledge-base?path=mcp_knowledge_base/index.md');
  
  // 페이지 로드 대기
  await page.waitForLoadState('networkidle');
  
  // 페이지 스크린샷
  await page.screenshot({ path: 'test-results/curriculum-page.png' });
  
  // 목차 섹션 찾기
  const tocSummary = page.locator('summary:has-text("📋 목차")');
  if (await tocSummary.isVisible({ timeout: 10000 })) {
    console.log('목차 섹션을 찾았습니다.');
    
    // 목차 클릭
    await tocSummary.click();
    
    // 목차 링크 확인
    const firstLink = page.locator('a[href="#🎯-전체-과정-개요"]');
    if (await firstLink.isVisible({ timeout: 5000 })) {
      console.log('목차 링크를 찾았습니다.');
      
      // 첫 번째 링크 클릭
      await firstLink.click();
      
      // 해당 섹션이 보이는지 확인
      const targetSection = page.locator('h2:has-text("🎯 전체 과정 개요")');
      if (await targetSection.isVisible({ timeout: 5000 })) {
        console.log('✅ 목차 링크가 정상적으로 작동합니다!');
      } else {
        console.log('❌ 목차 링크 클릭 후 해당 섹션을 찾을 수 없습니다.');
      }
    } else {
      console.log('❌ 목차 링크를 찾을 수 없습니다.');
    }
  } else {
    console.log('❌ 목차 섹션을 찾을 수 없습니다.');
  }
});
