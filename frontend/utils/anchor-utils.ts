/**
 * 앵커 링크 처리 공통 유틸리티 함수
 * SplitEditor와 ContentView에서 공통으로 사용
 */

export interface AnchorSearchResult {
  element: HTMLElement | null;
  method: 'getElementById' | 'exactIdMatch' | 'textContentMatch' | 'emojiRemovedMatch' | 'specialCharsRemovedMatch' | 'notFound';
  debugInfo?: string;
}

/**
 * 앵커 ID를 디코딩하고 정리
 */
export function processAnchorId(rawId: string): string {
  let targetId = rawId;
  
  // URL 디코딩
  try {
    targetId = decodeURIComponent(targetId);
  } catch (e) {
    console.warn('Failed to decode anchor ID:', targetId);
  }
  
  // 앞에 - 기호 제거 (마크다운 렌더러가 추가하는 경우)
  if (targetId.startsWith('-')) {
    targetId = targetId.substring(1);
  }
  
  return targetId;
}

/**
 * 앵커 요소를 찾는 통합 함수
 * 여러 방법을 순차적으로 시도하여 최대한 찾을 수 있도록 함
 */
export function findAnchorElement(targetId: string): AnchorSearchResult {
  console.log('Looking for anchor ID:', targetId);
  
  // 1. getElementById로 직접 찾기
  let targetElement = document.getElementById(targetId);
  if (targetElement) {
    return {
      element: targetElement,
      method: 'getElementById',
      debugInfo: `Found by getElementById: ${targetId}`
    };
  }
  
  // 2. 정확한 ID 매칭
  const allElements = document.querySelectorAll('h1, h2, h3, h4, h5, h6');
  for (const el of allElements) {
    if (el.id === targetId) {
      return {
        element: el as HTMLElement,
        method: 'exactIdMatch',
        debugInfo: `Found by exact ID match: ${el.id}`
      };
    }
  }
  
  // 3. 텍스트 콘텐츠 매칭 (이모지 포함)
  for (const el of allElements) {
    const textContent = el.textContent?.trim();
    if (textContent) {
      const exactId = textContent
        .replace(/\s+/g, '-')
        .replace(/-+/g, '-')
        .replace(/^-+|-+$/g, '')
        .toLowerCase();
      
      if (exactId === targetId) {
        return {
          element: el as HTMLElement,
          method: 'textContentMatch',
          debugInfo: `Found by text content match: ${textContent} → ${exactId}`
        };
      }
    }
  }
  
  // 4. 이모지 제거 후 매칭
  for (const el of allElements) {
    const textContent = el.textContent?.trim();
    if (textContent) {
      const emojiRemovedId = textContent
        .replace(/[\u{1F600}-\u{1F64F}]|[\u{1F300}-\u{1F5FF}]|[\u{1F680}-\u{1F6FF}]|[\u{1F1E0}-\u{1F1FF}]/gu, '')
        .trim()
        .replace(/\s+/g, '-')
        .replace(/-+/g, '-')
        .replace(/^-+|-+$/g, '')
        .toLowerCase();
      
      if (emojiRemovedId === targetId) {
        return {
          element: el as HTMLElement,
          method: 'emojiRemovedMatch',
          debugInfo: `Found by emoji-removed match: ${textContent} → ${emojiRemovedId}`
        };
      }
    }
  }
  
  // 5. 특수문자 제거 후 매칭
  for (const el of allElements) {
    const textContent = el.textContent?.trim();
    if (textContent) {
      const specialCharsRemovedId = textContent
        .replace(/[^\w\s가-힣]/g, '')
        .trim()
        .replace(/\s+/g, '-')
        .replace(/-+/g, '-')
        .replace(/^-+|-+$/g, '')
        .toLowerCase();
      
      if (specialCharsRemovedId === targetId) {
        return {
          element: el as HTMLElement,
          method: 'specialCharsRemovedMatch',
          debugInfo: `Found by special chars removed match: ${textContent} → ${specialCharsRemovedId}`
        };
      }
    }
  }
  
  return {
    element: null,
    method: 'notFound',
    debugInfo: `Anchor not found: ${targetId}`
  };
}

/**
 * 접혀진 섹션(details) 내부의 앵커 처리
 */
export function handleCollapsedSection(targetElement: HTMLElement): boolean {
  const detailsElement = targetElement.closest('details');
  if (detailsElement && !detailsElement.open) {
    console.log('Opening collapsed section for anchor');
    detailsElement.open = true;
    return true; // 섹션이 열렸음을 반환
  }
  return false; // 이미 열려있거나 details 요소가 아님
}

/**
 * 앵커로 스크롤하는 함수 (하이라이트 효과 포함)
 */
export function scrollToTarget(
  targetElement: HTMLElement, 
  container?: HTMLElement | null,
  componentName: string = 'Component'
): void {
  // 하이라이트 효과 추가
  targetElement.style.backgroundColor = '#fef3c7';
  targetElement.style.border = '2px solid #f59e0b';
  targetElement.style.borderRadius = '4px';
  targetElement.style.padding = '8px';
  targetElement.style.margin = '4px 0';
  targetElement.style.transition = 'all 0.3s ease';
  
  // 스크롤 실행
  targetElement.scrollIntoView({ 
    behavior: 'smooth', 
    block: 'start',
    inline: 'nearest'
  });
  
  // 추가 스크롤 조정
  setTimeout(() => {
    if (container) {
      const containerRect = container.getBoundingClientRect();
      const elementRect = targetElement.getBoundingClientRect();
      
      // 요소가 상단에 너무 가까우면 스크롤 위치 조정
      if (elementRect.top < containerRect.top + 80) {
        container.scrollBy({
          top: elementRect.top - containerRect.top - 80,
          behavior: 'smooth'
        });
      }
    }
  }, 100);
  
  // 하이라이트 제거 (3초 후)
  setTimeout(() => {
    targetElement.style.backgroundColor = '';
    targetElement.style.border = '';
    targetElement.style.borderRadius = '';
    targetElement.style.padding = '';
    targetElement.style.margin = '';
  }, 3000);
  
  console.log(`${componentName}: Scrolled to anchor with highlight effect`);
}

/**
 * 목차 전체 펼치기/접기 함수
 */
export function toggleAllDetails(
  allDetailsExpanded: { value: boolean },
  componentName: string = 'Component'
): void {
  const detailsElements = document.querySelectorAll('details');
  allDetailsExpanded.value = !allDetailsExpanded.value;
  
  detailsElements.forEach(details => {
    details.open = allDetailsExpanded.value;
  });
  
  console.log(`${componentName}: Toggled all details to:`, allDetailsExpanded.value ? 'expanded' : 'collapsed');
}

/**
 * 앵커 링크 처리 통합 함수
 * SplitEditor와 ContentView에서 공통으로 사용
 */
export function handleAnchorLink(
  href: string,
  container: HTMLElement | null,
  componentName: string = 'Component'
): boolean {
  if (!href.startsWith('#')) {
    return false; // 앵커 링크가 아님
  }
  
  const rawId = href.substring(1);
  const targetId = processAnchorId(rawId);
  
  const result = findAnchorElement(targetId);
  
  if (result.element) {
    const wasCollapsed = handleCollapsedSection(result.element);
    
    if (wasCollapsed) {
      // 접혀진 섹션이 열린 경우 약간의 지연 후 스크롤
      setTimeout(() => {
        scrollToTarget(result.element!, container, componentName);
      }, 100);
    } else {
      // 이미 열려있는 경우 즉시 스크롤
      scrollToTarget(result.element, container, componentName);
    }
    
    console.log(`${componentName}: ${result.debugInfo}`);
    return true; // 앵커 링크 처리 완료
  } else {
    console.log(`${componentName}: ${result.debugInfo}`);
    return false; // 앵커를 찾지 못함
  }
}
