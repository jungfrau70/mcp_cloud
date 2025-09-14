import { test, expect } from '@playwright/test';

test('목차 링크 최종 테스트', async ({ page }) => {
  // 로컬 서버로 이동
  await page.goto('http://localhost:3000');
  
  // 페이지 로드 대기
  await page.waitForLoadState('networkidle');
  
  // 커리큘럼 페이지로 직접 이동
  await page.goto('http://localhost:3000/knowledge-base?path=mcp_knowledge_base/index.md');
  
  // 페이지 로드 대기
  await page.waitForLoadState('networkidle');
  
  // 페이지 스크린샷
  await page.screenshot({ path: 'test-results/curriculum-final.png' });
  
  // 페이지 내용 확인
  const pageContent = await page.textContent('body');
  console.log('페이지에 "목차" 텍스트가 있는지 확인:', pageContent?.includes('목차'));
  console.log('페이지에 "🎯" 이모지가 있는지 확인:', pageContent?.includes('🎯'));
  
  // 모든 링크 찾기
  const allLinks = await page.locator('a').all();
  console.log(`전체 링크 개수: ${allLinks.length}`);
  
  // 앵커 링크 찾기
  const anchorLinks = await page.locator('a[href^="#"]').all();
  console.log(`앵커 링크 개수: ${anchorLinks.length}`);
  
  for (let i = 0; i < Math.min(anchorLinks.length, 10); i++) {
    const href = await anchorLinks[i].getAttribute('href');
    const text = await anchorLinks[i].textContent();
    console.log(`앵커 링크 ${i}: ${text} -> ${href}`);
  }
  
  // 목차 관련 요소 찾기
  const tocElements = await page.locator('summary, details').all();
  console.log(`목차 관련 요소 개수: ${tocElements.length}`);
  
  for (let i = 0; i < tocElements.length; i++) {
    const text = await tocElements[i].textContent();
    console.log(`목차 요소 ${i}: ${text}`);
  }
  
  // 특정 링크 클릭 테스트
  const targetLink = page.locator('a[href="#🎯-전체-과정-개요"]');
  if (await targetLink.isVisible({ timeout: 5000 })) {
    console.log('목표 링크를 찾았습니다. 클릭합니다.');
    await targetLink.click();
    
    // 잠시 대기
    await page.waitForTimeout(1000);
    
    // 해당 섹션 확인
    const targetSection = page.locator('h2:has-text("🎯 전체 과정 개요")');
    if (await targetSection.isVisible({ timeout: 2000 })) {
      console.log('✅ 목차 링크가 정상적으로 작동합니다!');
    } else {
      console.log('❌ 목차 링크 클릭 후 해당 섹션을 찾을 수 없습니다.');
    }
  } else {
    console.log('❌ 목표 링크를 찾을 수 없습니다.');
  }
});
