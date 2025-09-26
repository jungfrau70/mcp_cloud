/**
 * 경로 수정 패턴 설정 파일
 * Windows 경로 구분자로 인한 문제를 해결하기 위한 패턴들을 정의
 */

export interface PathFix {
  pattern: RegExp
  replacement: string
  description: string
}

/**
 * 기본 경로 수정 패턴들
 * Windows에서 `\`가 `e`와 `p` 사이에 들어가면서 발생하는 문제들을 해결
 */
export const DEFAULT_PATH_FIXES: PathFix[] = [
  {
    pattern: /masterepos/g,
    replacement: 'master/repos',
    description: 'masterepos → master/repos (Windows 경로 구분자 문제)'
  },
  {
    pattern: /containerepos/g,
    replacement: 'container/repos',
    description: 'containerepos → container/repos (Windows 경로 구분자 문제)'
  },
  {
    pattern: /basicrepos/g,
    replacement: 'basic/repos',
    description: 'basicrepos → basic/repos (Windows 경로 구분자 문제)'
  }
]

/**
 * 동적으로 경로 수정 패턴을 생성하는 함수
 * 새로운 과정이 추가될 때 자동으로 패턴을 생성할 수 있음
 */
export function generatePathFixes(courseTypes: string[]): PathFix[] {
  return courseTypes.map(courseType => ({
    pattern: new RegExp(`${courseType}epos`, 'g'),
    replacement: `${courseType}/repos`,
    description: `${courseType}epos → ${courseType}/repos (Windows 경로 구분자 문제)`
  }))
}

/**
 * 모든 경로 수정 패턴을 가져오는 함수
 * 기본 패턴과 동적 패턴을 결합
 */
export function getAllPathFixes(courseTypes: string[] = ['basic', 'master', 'container']): PathFix[] {
  const dynamicFixes = generatePathFixes(courseTypes)
  return [...DEFAULT_PATH_FIXES, ...dynamicFixes]
}

/**
 * 새로운 경로 수정 패턴을 추가하는 함수
 */
export function addPathFix(pattern: RegExp, replacement: string, description: string): void {
  DEFAULT_PATH_FIXES.push({
    pattern,
    replacement,
    description
  })
}

/**
 * 경로 수정 패턴을 제거하는 함수
 */
export function removePathFix(pattern: RegExp): boolean {
  const index = DEFAULT_PATH_FIXES.findIndex(fix => fix.pattern.source === pattern.source)
  if (index !== -1) {
    DEFAULT_PATH_FIXES.splice(index, 1)
    return true
  }
  return false
}

/**
 * 경로 수정 패턴을 적용하는 함수
 */
export function applyPathFixes(path: string, fixes: PathFix[]): string {
  let result = path
  
  for (const fix of fixes) {
    if (fix.pattern.test(result)) {
      result = result.replace(fix.pattern, fix.replacement)
    }
  }
  
  return result
}

/**
 * 경로 수정 패턴을 검증하는 함수
 */
export function validatePathFixes(fixes: PathFix[]): { isValid: boolean; errors: string[] } {
  const errors: string[] = []
  
  for (const fix of fixes) {
    if (!fix.pattern || !(fix.pattern instanceof RegExp)) {
      errors.push(`Invalid pattern for fix: ${fix.description}`)
    }
    
    if (!fix.replacement || typeof fix.replacement !== 'string') {
      errors.push(`Invalid replacement for fix: ${fix.description}`)
    }
    
    if (!fix.description || typeof fix.description !== 'string') {
      errors.push(`Invalid description for fix: ${fix.description}`)
    }
  }
  
  return {
    isValid: errors.length === 0,
    errors
  }
}
