import { test, expect } from '@playwright/test';

test('로그인 및 페이지 이동 테스트', async ({ page }) => {
  // 로컬 서버로 이동
  await page.goto('http://localhost:3000');
  
  // 초기 페이지 스크린샷
  await page.screenshot({ path: 'test-results/initial-page.png' });
  
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
    
    // 로그인 후 페이지 스크린샷
    await page.screenshot({ path: 'test-results/after-login.png' });
    
    console.log('로그인 완료');
    
    // 현재 URL 확인
    const currentUrl = page.url();
    console.log('로그인 후 URL:', currentUrl);
    
    // 커리큘럼 링크 클릭 시도
    const curriculumLink = page.locator('a:has-text("커리큘럼")');
    if (await curriculumLink.isVisible({ timeout: 5000 })) {
      console.log('커리큘럼 링크를 찾았습니다. 클릭합니다.');
      await curriculumLink.click();
      await page.waitForLoadState('networkidle');
      
      // 커리큘럼 페이지 스크린샷
      await page.screenshot({ path: 'test-results/curriculum-page.png' });
      
      const curriculumUrl = page.url();
      console.log('커리큘럼 페이지 URL:', curriculumUrl);
    } else {
      console.log('커리큘럼 링크를 찾을 수 없습니다.');
    }
  } else {
    console.log('로그인 페이지가 아닙니다. 현재 페이지:', page.url());
  }
  
  // 최종 페이지 스크린샷
  await page.screenshot({ path: 'test-results/final-page.png' });
});
