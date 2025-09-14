import { test, expect } from '@playwright/test';

test.describe('커리큘럼 목차 링크 테스트', () => {
  test.beforeEach(async ({ page }) => {
    // 로컬 서버로 이동
    await page.goto('http://localhost:3000');
    
    // 로그인 페이지인지 확인하고 로그인 처리
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
      
      // 로그인 후 메인 페이지로 이동 확인
      await page.waitForURL('**/curriculum**', { timeout: 10000 });
    }
    
    // 페이지가 로드될 때까지 대기
    await page.waitForLoadState('networkidle');
  });

  test('메인 커리큘럼 페이지 목차 링크 동작 확인', async ({ page }) => {
    // 커리큘럼 페이지로 이동 (index.md)
    await page.goto('http://localhost:3000/knowledge-base?path=mcp_knowledge_base/index.md');
    
    // 페이지 로드 대기
    await page.waitForLoadState('networkidle');
    
    // 페이지 스크린샷 (디버깅용)
    await page.screenshot({ path: 'test-results/main-page.png' });
    
    // 목차 섹션이 로드되었는지 확인
    await expect(page.locator('summary:has-text("📋 목차")')).toBeVisible({ timeout: 10000 });
    
    // 목차를 열기
    await page.click('summary:has-text("📋 목차")');
    
    // 목차 링크들이 보이는지 확인
    await expect(page.locator('a[href="#🎯-전체-과정-개요"]')).toBeVisible();
    await expect(page.locator('a[href="#📚-과정별-상세-정보"]')).toBeVisible();
    await expect(page.locator('a[href="#🔗-과정-간-연계성"]')).toBeVisible();
    await expect(page.locator('a[href="#🛠️-실습-환경-및-도구"]')).toBeVisible();
    
    // 첫 번째 링크 클릭 테스트
    await page.click('a[href="#🎯-전체-과정-개요"]');
    
    // 해당 섹션이 보이는지 확인
    await expect(page.locator('h2:has-text("🎯 전체 과정 개요")')).toBeVisible();
    
    // 두 번째 링크 클릭 테스트
    await page.click('a[href="#📚-과정별-상세-정보"]');
    
    // 해당 섹션이 보이는지 확인
    await expect(page.locator('h2:has-text("📚 과정별 상세 정보")')).toBeVisible();
    
    // 세 번째 링크 클릭 테스트
    await page.click('a[href="#🔗-과정-간-연계성"]');
    
    // 해당 섹션이 보이는지 확인
    await expect(page.locator('h2:has-text("🔗 과정 간 연계성")')).toBeVisible();
    
    console.log('✅ 메인 커리큘럼 페이지 목차 링크 테스트 완료');
  });

  test('Cloud Basic 1일차 목차 링크 동작 확인', async ({ page }) => {
    // Cloud Basic 1일차 페이지로 이동
    await page.goto('http://localhost:3000/knowledge-base?path=mcp_knowledge_base/cloud_basic/textbook/Day1/README.md');
    
    // 페이지 로드 대기
    await page.waitForLoadState('networkidle');
    
    // 페이지 스크린샷 (디버깅용)
    await page.screenshot({ path: 'test-results/cloud-basic-page.png' });
    
    // 목차 섹션이 로드되었는지 확인
    await expect(page.locator('summary:has-text("📋 목차")')).toBeVisible({ timeout: 10000 });
    
    // 목차를 열기
    await page.click('summary:has-text("📋 목차")');
    
    // 목차 링크들이 보이는지 확인
    await expect(page.locator('a[href="#🎯-학습-목표"]')).toBeVisible();
    await expect(page.locator('a[href="#📚-실습-가이드"]')).toBeVisible();
    await expect(page.locator('a[href="#🔧-실습-환경-준비"]')).toBeVisible();
    
    // 학습 목표 링크 클릭 테스트
    await page.click('a[href="#🎯-학습-목표"]');
    
    // 해당 섹션이 보이는지 확인
    await expect(page.locator('h2:has-text("🎯 학습 목표")')).toBeVisible();
    
    // 실습 가이드 링크 클릭 테스트
    await page.click('a[href="#📚-실습-가이드"]');
    
    // 해당 섹션이 보이는지 확인
    await expect(page.locator('h2:has-text("📚 실습 가이드")')).toBeVisible();
    
    console.log('✅ Cloud Basic 1일차 목차 링크 테스트 완료');
  });

  test('앵커 링크 스크롤 동작 확인', async ({ page }) => {
    // 메인 커리큘럼 페이지로 이동
    await page.goto('http://localhost:3000/knowledge-base?path=mcp_knowledge_base/index.md');
    
    // 페이지 로드 대기
    await page.waitForLoadState('networkidle');
    
    // 목차를 열기
    await page.click('summary:has-text("📋 목차")');
    
    // 페이지 상단으로 스크롤
    await page.evaluate(() => window.scrollTo(0, 0));
    
    // 마지막 링크 클릭 (스크롤이 필요한 링크)
    await page.click('a[href="#🛠️-실습-환경-및-도구"]');
    
    // 해당 섹션이 보이는지 확인 (스크롤 후)
    await expect(page.locator('h2:has-text("🛠️ 실습 환경 및 도구")')).toBeVisible();
    
    // 하이라이트 효과가 적용되었는지 확인 (CSS 클래스나 스타일 확인)
    const targetElement = page.locator('h2:has-text("🛠️ 실습 환경 및 도구")');
    await expect(targetElement).toHaveCSS('background-color', 'rgb(254, 243, 199)'); // #fef3c7
    
    console.log('✅ 앵커 링크 스크롤 동작 테스트 완료');
  });
});