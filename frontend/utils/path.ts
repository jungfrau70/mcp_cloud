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
  const result: {
    isReadable: boolean
    isEncoded: boolean
    needsDecoding: boolean
    decoded?: string
    encodingLevel: number
  } = {
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

// 한글 URI 처리를 위한 고급 함수들

// URI 내 한글을 안전하게 처리하는 함수
export function safeKoreanUri(uri: string): string {
  if (!uri) return ''
  
  try {
    // 이미 인코딩된 URI인지 확인
    if (isEncodedFilename(uri)) {
      // 디코딩 후 다시 인코딩하여 정규화
      const decoded = decodeURIComponent(uri)
      return encodeURIComponent(decoded)
    }
    
    // 한글이 포함된 경우에만 인코딩
    if (/[가-힣]/.test(uri)) {
      return encodeURIComponent(uri)
    }
    
    return uri
  } catch (error) {
    console.warn('Failed to process Korean URI:', uri, error)
    return uri
  }
}

// URI에서 한글을 읽을 수 있게 디코딩하는 함수
export function makeKoreanUriReadable(uri: string): string {
  if (!uri) return ''
  
  try {
    // 인코딩된 문자가 있는지 확인
    if (isEncodedFilename(uri)) {
      return decodeURIComponent(uri)
    }
    
    return uri
  } catch (error) {
    console.warn('Failed to decode Korean URI:', uri, error)
    return uri
  }
}

// 경로 세그먼트별로 한글 처리하는 함수
export function processKoreanPathSegments(path: string): string {
  if (!path) return ''
  
  const segments = path.split('/')
  const processedSegments = segments.map(segment => {
    if (!segment) return segment
    
    // 한글이 포함된 세그먼트만 처리
    if (/[가-힣]/.test(segment)) {
      // 이미 인코딩되어 있는지 확인
      if (isEncodedFilename(segment)) {
        return segment // 이미 인코딩됨
      } else {
        return encodeURIComponent(segment) // 인코딩 필요
      }
    }
    
    return segment
  })
  
  return processedSegments.join('/')
}

// API 요청용 경로를 안전하게 준비하는 함수 (개선된 버전)
export function prepareSafeApiPath(path: string): string {
  if (!path) return ''
  
  // 1. 기본 경로 정리
  const cleaned = cleanApiPath(path)
  
  // 2. 한글 파일명 처리
  const koreanProcessed = processKoreanPathSegments(cleaned)
  
  // 3. 최종 검증
  return koreanProcessed
}

// URI를 사용자에게 표시할 때 읽기 쉽게 만드는 함수
export function makeUriDisplayFriendly(uri: string): string {
  if (!uri) return ''
  
  try {
    // 인코딩된 URI를 디코딩하여 표시
    if (isEncodedFilename(uri)) {
      return decodeURIComponent(uri)
    }
    
    return uri
  } catch (error) {
    console.warn('Failed to make URI display friendly:', uri, error)
    return uri
  }
}

// URI 처리 상태를 확인하는 함수
export function getUriProcessingStatus(uri: string): {
  original: string
  needsProcessing: boolean
  isEncoded: boolean
  processed: string
  displayFriendly: string
  error?: string
} {
  const result: {
    original: string
    needsProcessing: boolean
    isEncoded: boolean
    processed: string
    displayFriendly: string
    error?: string
  } = {
    original: uri,
    needsProcessing: false,
    isEncoded: false,
    processed: uri,
    displayFriendly: uri
  }
  
  try {
    result.isEncoded = isEncodedFilename(uri)
    result.needsProcessing = /[가-힣]/.test(uri) || result.isEncoded
    
    if (result.needsProcessing) {
      if (result.isEncoded) {
        // 이미 인코딩된 경우
        result.processed = uri
        result.displayFriendly = decodeURIComponent(uri)
      } else {
        // 인코딩이 필요한 경우
        result.processed = encodeURIComponent(uri)
        result.displayFriendly = uri
      }
    }
  } catch (error) {
    result.error = error instanceof Error ? error.message : 'Unknown error'
  }
  
  return result
}

// 한글 파일명 처리를 위한 통합 함수
export function handleKoreanFilename(filename: string, mode: 'encode' | 'decode' | 'auto' = 'auto'): string {
  if (!filename) return ''
  
  try {
    switch (mode) {
      case 'encode':
        return /[가-힣]/.test(filename) ? encodeURIComponent(filename) : filename
        
      case 'decode':
        return isEncodedFilename(filename) ? decodeURIComponent(filename) : filename
        
      case 'auto':
      default:
        if (isEncodedFilename(filename)) {
          return decodeURIComponent(filename)
        } else if (/[가-힣]/.test(filename)) {
          return encodeURIComponent(filename)
        }
        return filename
    }
  } catch (error) {
    console.warn('Failed to handle Korean filename:', filename, error)
    return filename
  }
}

// ===== 개선된 통합 함수들 =====

// 1. 안전한 URL 인코딩 (이중 인코딩 방지)
export function safeEncodeURIComponent(str: string): string {
  if (!str) return ''
  
  try {
    // 이미 인코딩된 경우 디코딩 후 재인코딩
    if (str.includes('%') && str !== decodeURIComponent(str)) {
      const decoded = decodeURIComponent(str)
      return encodeURIComponent(decoded)
    }
    return encodeURIComponent(str)
  } catch (error) {
    console.warn('Failed to safely encode URI component:', str, error)
    return str
  }
}

// 2. 안전한 URL 디코딩 (재귀적 디코딩)
export function safeDecodeURIComponent(str: string): string {
  if (!str) return ''
  
  try {
    let decoded = str
    // 재귀적 디코딩: 2중 인코딩된 경우를 처리
    while (decoded.includes('%') && decoded !== decodeURIComponent(decoded)) {
      decoded = decodeURIComponent(decoded)
    }
    return decoded
  } catch (error) {
    console.warn('Failed to safely decode URI component:', str, error)
    return str
  }
}

// 3. 경로 세그먼트별 안전한 처리
export function safeProcessPathSegments(path: string, mode: 'encode' | 'decode' | 'auto' = 'auto'): string {
  if (!path) return ''
  
  const segments = path.split('/')
  const processedSegments = segments.map(segment => {
    if (!segment) return segment
    
    switch (mode) {
      case 'encode':
        return /[가-힣]/.test(segment) ? safeEncodeURIComponent(segment) : segment
        
      case 'decode':
        return isEncodedFilename(segment) ? safeDecodeURIComponent(segment) : segment
        
      case 'auto':
      default:
        if (isEncodedFilename(segment)) {
          return safeDecodeURIComponent(segment)
        } else if (/[가-힣]/.test(segment)) {
          return safeEncodeURIComponent(segment)
        }
        return segment
    }
  })
  
  return processedSegments.join('/')
}

// 4. API 요청용 경로 준비 (개선된 버전)
export function prepareApiPathSafe(path: string): string {
  if (!path) return ''
  
  // 1. 기본 경로 정리
  const cleaned = cleanApiPath(path)
  
  // 2. 안전한 한글 파일명 처리
  return safeProcessPathSegments(cleaned, 'encode')
}

// 5. UI 표시용 경로 준비 (개선된 버전)
export function prepareDisplayPath(path: string): string {
  if (!path) return ''
  
  // 1. 안전한 디코딩
  const decoded = safeProcessPathSegments(path, 'decode')
  
  // 2. 경로 정리
  return cleanApiPath(decoded)
}

// 6. 앵커 ID 안전한 처리
export function safeProcessAnchorId(anchorId: string, mode: 'encode' | 'decode' = 'decode'): string {
  if (!anchorId) return ''
  
  try {
    if (mode === 'encode') {
      return safeEncodeURIComponent(anchorId)
    } else {
      return safeDecodeURIComponent(anchorId)
    }
  } catch (error) {
    console.warn('Failed to process anchor ID:', anchorId, error)
    return anchorId
  }
}

// ===== 성능 최적화를 위한 캐싱 시스템 =====

// 캐시 인터페이스
interface PathCache {
  encode: Map<string, string>
  decode: Map<string, string>
  lastCleanup: number
}

// 전역 캐시 인스턴스
const pathCache: PathCache = {
  encode: new Map(),
  decode: new Map(),
  lastCleanup: Date.now()
}

// 캐시 정리 (메모리 누수 방지)
function cleanupCache(): void {
  const now = Date.now()
  const CACHE_TTL = 5 * 60 * 1000 // 5분
  
  if (now - pathCache.lastCleanup > CACHE_TTL) {
    // 캐시 크기가 너무 크면 정리
    if (pathCache.encode.size > 1000) {
      pathCache.encode.clear()
    }
    if (pathCache.decode.size > 1000) {
      pathCache.decode.clear()
    }
    pathCache.lastCleanup = now
  }
}

// 7. 캐시된 안전한 URL 인코딩
export function cachedSafeEncodeURIComponent(str: string): string {
  if (!str) return ''
  
  // 캐시 확인
  if (pathCache.encode.has(str)) {
    return pathCache.encode.get(str)!
  }
  
  // 캐시 정리
  cleanupCache()
  
  // 인코딩 수행
  const result = safeEncodeURIComponent(str)
  
  // 캐시 저장
  pathCache.encode.set(str, result)
  
  return result
}

// 8. 캐시된 안전한 URL 디코딩
export function cachedSafeDecodeURIComponent(str: string): string {
  if (!str) return ''
  
  // 캐시 확인
  if (pathCache.decode.has(str)) {
    return pathCache.decode.get(str)!
  }
  
  // 캐시 정리
  cleanupCache()
  
  // 디코딩 수행
  const result = safeDecodeURIComponent(str)
  
  // 캐시 저장
  pathCache.decode.set(str, result)
  
  return result
}

// 9. 캐시된 경로 처리
export function cachedSafeProcessPathSegments(path: string, mode: 'encode' | 'decode' | 'auto' = 'auto'): string {
  if (!path) return ''
  
  const cacheKey = `${mode}:${path}`
  const cache = mode === 'encode' ? pathCache.encode : pathCache.decode
  
  // 캐시 확인
  if (cache.has(cacheKey)) {
    return cache.get(cacheKey)!
  }
  
  // 캐시 정리
  cleanupCache()
  
  // 처리 수행
  const result = safeProcessPathSegments(path, mode)
  
  // 캐시 저장
  cache.set(cacheKey, result)
  
  return result
}

// 10. 캐시 초기화 (필요시)
export function clearPathCache(): void {
  pathCache.encode.clear()
  pathCache.decode.clear()
  pathCache.lastCleanup = Date.now()
}

// ===== 에러 처리 및 검증 강화 =====

// 에러 타입 정의
export interface PathProcessingError {
  type: 'encoding' | 'decoding' | 'validation' | 'unknown'
  message: string
  originalValue: string
  timestamp: number
}

// 에러 로그 저장소
const errorLog: PathProcessingError[] = []
const MAX_ERROR_LOG_SIZE = 100

// 에러 로깅 함수
function logPathError(error: Omit<PathProcessingError, 'timestamp'>): void {
  const fullError: PathProcessingError = {
    ...error,
    timestamp: Date.now()
  }
  
  errorLog.push(fullError)
  
  // 로그 크기 제한
  if (errorLog.length > MAX_ERROR_LOG_SIZE) {
    errorLog.shift()
  }
  
  console.warn(`Path processing error [${error.type}]:`, error.message, error.originalValue)
}

// 11. 강화된 안전한 URL 인코딩 (에러 처리 포함)
export function robustSafeEncodeURIComponent(str: string): string {
  if (!str) return ''
  
  try {
    // 입력 검증
    if (typeof str !== 'string') {
      logPathError({
        type: 'validation',
        message: 'Input is not a string',
        originalValue: String(str)
      })
      return String(str)
    }
    
    // 길이 제한
    if (str.length > 10000) {
      logPathError({
        type: 'validation',
        message: 'Input string too long',
        originalValue: str.substring(0, 100) + '...'
      })
      return str
    }
    
    // 이미 인코딩된 경우 디코딩 후 재인코딩
    if (str.includes('%') && str !== decodeURIComponent(str)) {
      const decoded = decodeURIComponent(str)
      return encodeURIComponent(decoded)
    }
    
    return encodeURIComponent(str)
  } catch (error) {
    logPathError({
      type: 'encoding',
      message: `Encoding failed: ${error instanceof Error ? error.message : 'Unknown error'}`,
      originalValue: str
    })
    return str
  }
}

// 12. 강화된 안전한 URL 디코딩 (에러 처리 포함)
export function robustSafeDecodeURIComponent(str: string): string {
  if (!str) return ''
  
  try {
    // 입력 검증
    if (typeof str !== 'string') {
      logPathError({
        type: 'validation',
        message: 'Input is not a string',
        originalValue: String(str)
      })
      return String(str)
    }
    
    let decoded = str
    let iterations = 0
    const MAX_ITERATIONS = 10 // 무한 루프 방지
    
    // 재귀적 디코딩: 2중 인코딩된 경우를 처리
    while (decoded.includes('%') && decoded !== decodeURIComponent(decoded) && iterations < MAX_ITERATIONS) {
      decoded = decodeURIComponent(decoded)
      iterations++
    }
    
    if (iterations >= MAX_ITERATIONS) {
      logPathError({
        type: 'decoding',
        message: 'Maximum decoding iterations reached',
        originalValue: str
      })
    }
    
    return decoded
  } catch (error) {
    logPathError({
      type: 'decoding',
      message: `Decoding failed: ${error instanceof Error ? error.message : 'Unknown error'}`,
      originalValue: str
    })
    return str
  }
}

// 13. 경로 유효성 검증
export function validatePath(path: string): { isValid: boolean; errors: string[] } {
  const errors: string[] = []
  
  if (!path) {
    errors.push('Path is empty')
    return { isValid: false, errors }
  }
  
  if (typeof path !== 'string') {
    errors.push('Path is not a string')
    return { isValid: false, errors }
  }
  
  if (path.length > 1000) {
    errors.push('Path is too long')
  }
  
  // 위험한 문자 검사
  if (/[<>:"|?*]/.test(path)) {
    errors.push('Path contains invalid characters')
  }
  
  // 상대 경로 보안 검사
  if (path.includes('..') && path.split('..').length > 2) {
    errors.push('Path contains potentially dangerous relative path')
  }
  
  return { isValid: errors.length === 0, errors }
}

// 14. 에러 로그 조회
export function getPathErrorLog(): PathProcessingError[] {
  return [...errorLog]
}

// 15. 에러 로그 초기화
export function clearPathErrorLog(): void {
  errorLog.length = 0
}

// 16. 통합된 안전한 경로 처리 (최종 버전)
export function processPathSafely(path: string, mode: 'encode' | 'decode' | 'auto' = 'auto'): {
  result: string
  success: boolean
  errors: string[]
} {
  // 1. 입력 검증
  const validation = validatePath(path)
  if (!validation.isValid) {
    return {
      result: path,
      success: false,
      errors: validation.errors
    }
  }
  
  // 2. 경로 처리
  try {
    let result: string
    
    switch (mode) {
      case 'encode':
        result = robustSafeEncodeURIComponent(path)
        break
      case 'decode':
        result = robustSafeDecodeURIComponent(path)
        break
      case 'auto':
      default:
        if (isEncodedFilename(path)) {
          result = robustSafeDecodeURIComponent(path)
        } else if (/[가-힣]/.test(path)) {
          result = robustSafeEncodeURIComponent(path)
        } else {
          result = path
        }
    }
    
    return {
      result,
      success: true,
      errors: []
    }
  } catch (error) {
    logPathError({
      type: 'unknown',
      message: `Path processing failed: ${error instanceof Error ? error.message : 'Unknown error'}`,
      originalValue: path
    })
    
    return {
      result: path,
      success: false,
      errors: ['Path processing failed']
    }
  }
}

/**
 * mcp_knowledge_base를 root로 하는 경로 처리 함수
 * 모든 내부 문서 링크가 mcp_knowledge_base를 기준으로 동작하도록 함
 */
export function resolveKnowledgeBasePath(currentPath: string, relativePath: string): string {
  if (!relativePath) return relativePath;
  
  // 절대 경로인 경우 mcp_knowledge_base 기준으로 처리
  if (relativePath.startsWith('/')) {
    // /로 시작하는 경우 mcp_knowledge_base를 prefix로 추가
    return `/mcp_knowledge_base${relativePath}`;
  }
  
  // 현재 경로에서 mcp_knowledge_base 기준 디렉토리 추출
  let baseDir = '';
  if (currentPath) {
    // mcp_knowledge_base 이후의 경로 추출
    const kbIndex = currentPath.indexOf('mcp_knowledge_base/');
    if (kbIndex !== -1) {
      baseDir = currentPath.substring(kbIndex + 'mcp_knowledge_base/'.length);
      // 파일명 제거하여 디렉토리만 추출
      const lastSlash = baseDir.lastIndexOf('/');
      if (lastSlash > 0) {
        baseDir = baseDir.substring(0, lastSlash);
      } else {
        baseDir = '';
      }
    }
  }
  
  // 상대 경로 해석
  const parts = relativePath.split('/');
  let result = baseDir;
  
  for (const part of parts) {
    if (part === '..') {
      // 상위 디렉토리로 이동
      const lastSlash = result.lastIndexOf('/');
      if (lastSlash > 0) {
        result = result.substring(0, lastSlash);
      } else {
        result = '';
      }
    } else if (part === '.') {
      // 현재 디렉토리 (변화 없음)
      continue;
    } else if (part) {
      // 하위 디렉토리 또는 파일
      result = result ? `${result}/${part}` : part;
    }
  }
  
  // mcp_knowledge_base prefix 추가
  return `/mcp_knowledge_base/${result}`;
}