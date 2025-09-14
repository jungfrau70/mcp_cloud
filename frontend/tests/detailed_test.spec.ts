import { test, expect } from '@playwright/test';

test('커리큘럼 목차 링크 상세 테스트', async ({ page }) => {
  // 로컬 서버로 이동
  await page.goto('http://localhost:3000');
  
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
  await page.screenshot({ path: 'test-results/curriculum-page-detailed.png' });
  
  // 페이지 내용 확인
  const pageContent = await page.textContent('body');
  console.log('페이지 내용 일부:', pageContent?.substring(0, 500));
  
  // 모든 summary 요소 찾기
  const summaryElements = await page.locator('summary').all();
  console.log(`찾은 summary 요소 개수: ${summaryElements.length}`);
  
  for (let i = 0; i < summaryElements.length; i++) {
    const text = await summaryElements[i].textContent();
    console.log(`Summary ${i}: ${text}`);
  }
  
  // 목차 섹션 찾기 (다양한 방법으로 시도)
  const tocSelectors = [
    'summary:has-text("📋 목차")',
    'summary:has-text("목차")',
    'summary:has-text("📋")',
    'details summary',
    'summary'
  ];
  
  let tocFound = false;
  for (const selector of tocSelectors) {
    const element = page.locator(selector);
    if (await element.isVisible({ timeout: 2000 })) {
      console.log(`목차 섹션을 찾았습니다: ${selector}`);
      tocFound = true;
      
      // 목차 클릭
      await element.click();
      
      // 잠시 대기
      await page.waitForTimeout(1000);
      
      // 목차 링크 확인
      const links = await page.locator('a[href^="#"]').all();
      console.log(`찾은 앵커 링크 개수: ${links.length}`);
      
      for (let i = 0; i < Math.min(links.length, 5); i++) {
        const href = await links[i].getAttribute('href');
        const text = await links[i].textContent();
        console.log(`링크 ${i}: ${text} -> ${href}`);
      }
      
      // 첫 번째 링크 클릭 테스트
      if (links.length > 0) {
        const firstLink = links[0];
        const href = await firstLink.getAttribute('href');
        const text = await firstLink.textContent();
        
        console.log(`첫 번째 링크 클릭: ${text} -> ${href}`);
        await firstLink.click();
        
        // 잠시 대기
        await page.waitForTimeout(1000);
        
        // 해당 섹션이 보이는지 확인
        if (href) {
          const targetId = href.substring(1);
          const targetElement = page.locator(`#${targetId}`);
          if (await targetElement.isVisible({ timeout: 2000 })) {
            console.log(`✅ 링크 클릭 후 해당 섹션을 찾았습니다: ${targetId}`);
          } else {
            console.log(`❌ 링크 클릭 후 해당 섹션을 찾을 수 없습니다: ${targetId}`);
          }
        }
      }
      
      break;
    }
  }
  
  if (!tocFound) {
    console.log('❌ 목차 섹션을 찾을 수 없습니다.');
    
    // 페이지의 모든 텍스트 내용 확인
    const allText = await page.textContent('body');
    if (allText?.includes('목차')) {
      console.log('페이지에 "목차" 텍스트가 있습니다.');
    } else {
      console.log('페이지에 "목차" 텍스트가 없습니다.');
    }
  }
});
