export function stripBasePath(path: string, basePath = 'mcp_knowledge_base'): string {
  // Normalize path separators and leading slashes
  const normalized = path.replace(/\\/g, '/').replace(/^\/+/, '')
  
  // Remove basePath prefix if present
  const prefix = basePath.endsWith('/') ? basePath : basePath + '/'
  if (normalized.startsWith(prefix)) {
    return normalized.substring(prefix.length)
  }
  
  // If path already doesn't have basePath, return as is
  return normalized
}

export function normalizePath(path: string): string {
  // Remove any duplicate path segments and normalize
  const segments = path.split('/').filter(segment => segment !== '')
  const normalized: string[] = []
  
  for (const segment of segments) {
    if (segment === '..') {
      normalized.pop()
    } else if (segment !== '.') {
      normalized.push(segment)
    }
  }
  
  return normalized.join('/')
}

export function cleanApiPath(path: string): string {
  if (!path) return ''
  
  // First strip base path, then normalize
  const stripped = stripBasePath(path)
  const normalized = normalizePath(stripped)
  
  // Additional check to prevent duplication
  // If the path contains repeated segments, remove them
  const segments = normalized.split('/')
  const cleaned: string[] = []
  let lastSegment = ''
  
  for (const segment of segments) {
    if (segment && segment !== lastSegment) {
      cleaned.push(segment)
      lastSegment = segment
    }
  }
  
  // Final check: if the path still contains repeated patterns, remove them
  let result = cleaned.join('/')
  
  // Remove repeated patterns like "cloud_master/textbook/Day3/cloud_master/textbook/Day3/"
  const pattern = /(cloud_(?:basic|master|container)\/textbook\/Day\d+\/)(\1)+/g
  result = result.replace(pattern, '$1')
  
  // Remove any remaining duplicate segments
  const finalSegments = result.split('/')
  const finalCleaned: string[] = []
  let lastFinalSegment = ''
  
  for (const segment of finalSegments) {
    if (segment && segment !== lastFinalSegment) {
      finalCleaned.push(segment)
      lastFinalSegment = segment
    }
  }
  
  return finalCleaned.join('/')
}

// More aggressive path cleaning function for problematic cases
export function deepCleanApiPath(path: string): string {
  if (!path) return ''

  const normalized = path.replace(/\\/g, '/').replace(/^\/+/, '').replace(/\/+$/, '')
  const parts = normalized.split('/').filter(part => part !== '')

  if (parts.length === 0) return ''

  const rootMarkers = ['cloud_basic', 'cloud_master', 'cloud_container'];
  
  // Find the first occurrence of a root marker
  let firstRootIndex = -1;
  for (let i = 0; i < parts.length; i++) {
    if (rootMarkers.includes(parts[i])) {
      firstRootIndex = i;
      break;
    }
  }

  if (firstRootIndex === -1) {
    // No root marker found, return the path as is
    return normalized;
  }

  // Start from the first root marker and build the path
  const cleanedParts: string[] = [];
  let i = firstRootIndex;
  
  while (i < parts.length) {
    const currentPart = parts[i];
    
    // If we encounter a root marker again, it means we have duplication
    if (rootMarkers.includes(currentPart) && cleanedParts.length > 0) {
      // Check if this is a duplicate pattern
      const currentPattern = parts.slice(i, i + 3).join('/'); // Check next 3 parts for pattern
      const existingPattern = cleanedParts.slice(-3).join('/');
      
      if (currentPattern === existingPattern) {
        // Skip this duplicate pattern
        i += 3; // Skip the duplicate pattern (root/textbook/DayX)
        continue;
      }
    }
    
    cleanedParts.push(currentPart);
    i++;
  }

  // Additional check for repeated patterns in the cleaned path
  let result = cleanedParts.join('/');
  
  // Remove any remaining repeated patterns like "textbook/Day1/textbook/Day1"
  const repeatedPattern = /(textbook\/Day\d+\/)(\1)+/g;
  result = result.replace(repeatedPattern, '$1');
  
  // Remove any remaining repeated course patterns
  const coursePattern = /(cloud_(?:basic|master|container)\/textbook\/Day\d+\/)(\1)+/g;
  result = result.replace(coursePattern, '$1');

  return result;
}

export function resolveRelativePath(basePath: string, relativePath: string): string {
  if (!basePath || !relativePath) {
    return relativePath || basePath || '';
  }

  // basePath가 디렉토리인지 파일인지 확인
  const isBaseDirectory = basePath.endsWith('/') || !basePath.includes('.');
  const baseParts = isBaseDirectory 
    ? basePath.split('/').filter(part => part !== '')
    : basePath.split('/').slice(0, -1).filter(part => part !== '');
  
  const relativeParts = relativePath.split('/').filter(part => part !== '');
  const stack = [...baseParts];

  for (const part of relativeParts) {
    if (part === '.') {
      continue;
    }
    if (part === '..') {
      if (stack.length > 0) {
        stack.pop();
      }
    } else {
      stack.push(part);
    }
  }

  const result = stack.join('/');
  
  // 결과가 비어있으면 현재 디렉토리를 의미
  return result || '.';
}

// 경로 중복을 근본적으로 방지하는 함수
export function preventPathDuplication(path: string): string {
  if (!path || typeof path !== 'string') {
    return '';
  }

  // 1. 기본 정리
  let cleaned = path.replace(/\\/g, '/').replace(/^\/+/, '').replace(/\/+$/, '');
  
  if (!cleaned) return '';

  // 2. 경로 세그먼트 분리
  const parts = cleaned.split('/').filter(part => part !== '');
  
  if (parts.length === 0) return '';

  // 3. 강력한 중복 패턴 제거
  // 전체 경로에서 반복되는 패턴을 찾아서 제거
  let result = parts.join('/');
  
  // 가장 일반적인 중복 패턴들을 순차적으로 제거
  const patterns = [
    // cloud_*/textbook/DayX/scripts/cloud_*/textbook/DayX/scripts/ 패턴
    /(cloud_(?:basic|master|container)\/textbook\/Day\d+\/scripts\/)\1+/g,
    // cloud_*/textbook/DayX/cloud_*/textbook/DayX/ 패턴  
    /(cloud_(?:basic|master|container)\/textbook\/Day\d+\/)\1+/g,
    // textbook/DayX/textbook/DayX/ 패턴
    /(textbook\/Day\d+\/)\1+/g,
    // 일반적인 4세그먼트 패턴 반복
    /([^\/]+\/[^\/]+\/[^\/]+\/[^\/]+\/)\1+/g,
    // 일반적인 3세그먼트 패턴 반복
    /([^\/]+\/[^\/]+\/[^\/]+\/)\1+/g,
    // 일반적인 2세그먼트 패턴 반복
    /([^\/]+\/[^\/]+\/)\1+/g,
    // 연속된 동일 세그먼트 제거
    /([^\/]+)\/\1+/g
  ];

  // 각 패턴을 순차적으로 적용
  for (const pattern of patterns) {
    let prevResult = '';
    // 더 이상 변화가 없을 때까지 반복 적용
    while (prevResult !== result) {
      prevResult = result;
      result = result.replace(pattern, '$1');
    }
  }

  // 4. 추가 검증: 세그먼트 레벨에서 중복 제거
  const finalParts = result.split('/').filter(part => part !== '');
  const cleanedParts = [];
  
  // 슬라이딩 윈도우로 중복 패턴 감지 및 제거
  let i = 0;
  while (i < finalParts.length) {
    let foundDuplicate = false;
    
    // 최대 5개 세그먼트까지의 패턴을 확인
    for (let windowSize = Math.min(5, Math.floor((finalParts.length - i) / 2)); windowSize >= 1; windowSize--) {
      if (i + windowSize * 2 <= finalParts.length) {
        const pattern1 = finalParts.slice(i, i + windowSize);
        const pattern2 = finalParts.slice(i + windowSize, i + windowSize * 2);
        
        // 패턴이 동일한지 확인
        if (pattern1.length === pattern2.length && 
            pattern1.every((part, idx) => part === pattern2[idx])) {
          // 중복 패턴 발견, 첫 번째 패턴만 추가
          cleanedParts.push(...pattern1);
          i += windowSize * 2; // 두 패턴 모두 건너뛰기
          foundDuplicate = true;
          break;
        }
      }
    }
    
    if (!foundDuplicate) {
      cleanedParts.push(finalParts[i]);
      i++;
    }
  }

  return cleanedParts.join('/');
}

export function sanitizeGeneratedFilename(title: string): string {
  let rel = title.toLowerCase().trim()
  rel = rel.replace(/[^a-z0-9\-\s가-힣]/g,'').replace(/\s+/g,'-')
  if(!rel) rel = 'generated-' + Date.now()
  // Check if it already ends with .md before adding
  if(!rel.endsWith('.md')) rel += '.md'
  return rel
}

// 한글 파일명을 위한 URL 인코딩/디코딩 함수들
export function encodeKoreanPath(path: string): string {
  if (!path) return ''
  
  // 경로를 세그먼트별로 분리하여 각각 인코딩
  const segments = path.split('/')
  const encodedSegments = segments.map(segment => {
    // 한글이 포함된 경우에만 인코딩
    if (/[가-힣]/.test(segment)) {
      return encodeURIComponent(segment)
    }
    return segment
  })
  
  return encodedSegments.join('/')
}

export function decodeKoreanPath(path: string): string {
  if (!path) return ''
  
  try {
    return decodeURIComponent(path)
  } catch (error) {
    console.warn('Failed to decode path:', path, error)
    return path
  }
}

// API 요청용 경로 정리 함수 (한글 파일명 지원)
export function prepareApiPath(path: string): string {
  if (!path) return ''
  
  // 먼저 경로 정리
  const cleaned = cleanApiPath(path)
  
  // 한글 파일명 인코딩
  return encodeKoreanPath(cleaned)
}

// 읽을 수 있는 파일명인지 체크하는 함수
export function isReadableFilename(filename: string): boolean {
  if (!filename) return false
  
  // URL 인코딩된 문자가 있는지 체크
  const hasEncodedChars = /%[0-9A-Fa-f]{2}/.test(filename)
  
  // 한글이나 특수문자가 포함되어 있지만 인코딩되지 않은 경우
  const hasUnicodeChars = /[가-힣\u4e00-\u9fff\u3040-\u309f\u30a0-\u30ff]/.test(filename)
  
  // ASCII 문자만 포함된 경우는 항상 읽을 수 있음
  const isAsciiOnly = /^[a-zA-Z0-9._-]+$/.test(filename)
  
  return isAsciiOnly || (hasUnicodeChars && !hasEncodedChars)
}

// 파일명이 인코딩되어 있는지 체크
export function isEncodedFilename(filename: string): boolean {
  if (!filename) return false
  return /%[0-9A-Fa-f]{2}/.test(filename)
}

// 파일명 디코딩이 필요한지 체크
export function needsDecoding(filename: string): boolean {
  if (!filename) return false
  
  // 인코딩된 문자가 있고, 디코딩 후에 변화가 있는 경우
  if (isEncodedFilename(filename)) {
    try {
      const decoded = decodeURIComponent(filename)
      return decoded !== filename
    } catch {
      return false
    }
  }
  
  return false
}

// 파일명 상태를 분석하는 함수
export function analyzeFilename(filename: string): {
  isReadable: boolean
  isEncoded: boolean
  needsDecoding: boolean
  decoded?: string
  encodingLevel: number
} {
  const result = {
    isReadable: isReadableFilename(filename),
    isEncoded: isEncodedFilename(filename),
    needsDecoding: needsDecoding(filename),
    encodingLevel: 0
  }
  
  // 인코딩 레벨 계산
  let current = filename
  let level = 0
  while (needsDecoding(current)) {
    try {
      current = decodeURIComponent(current)
      level++
    } catch {
      break
    }
  }
  
  result.encodingLevel = level
  result.decoded = level > 0 ? current : undefined
  
  return result
}

// 경로가 디렉토리인지 파일인지 감지하는 함수
export function isDirectoryPath(path: string): boolean {
  if (!path) return false
  
  // 일반적인 파일 확장자가 없으면 디렉토리로 간주
  const fileExtensions = ['.md', '.txt', '.json', '.yaml', '.yml', '.csv', '.sh', '.pdf', '.ppt', '.pptx', '.html', '.css', '.js', '.ts', '.vue']
  const hasExtension = fileExtensions.some(ext => path.toLowerCase().endsWith(ext))
  
  return !hasExtension
}

// 경로가 파일인지 확인하는 함수
export function isFilePath(path: string): boolean {
  return !isDirectoryPath(path)
}

// 디렉토리 경로를 정리하는 함수 (README.md 추가)
export function normalizeDirectoryPath(path: string): string {
  if (!path) return ''
  
  const cleaned = cleanApiPath(path)
  
  // 디렉토리인 경우 README.md 추가
  if (isDirectoryPath(cleaned)) {
    return cleaned.endsWith('/') ? `${cleaned}README.md` : `${cleaned}/README.md`
  }
  
  return cleaned
}
