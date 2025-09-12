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

  const normalized = path.replace(/\\/g, '/')
  const parts = normalized.split('/')

  const rootMarkers = ['cloud_basic', 'cloud_master', 'cloud_container'];
  let lastRootIndex = -1;

  for (let i = parts.length - 1; i >= 0; i--) {
    if (rootMarkers.includes(parts[i])) {
      lastRootIndex = i;
      break;
    }
  }

  if (lastRootIndex !== -1) {
    return parts.slice(lastRootIndex).join('/');
  }

  return path;
}

export function resolveRelativePath(basePath: string, relativePath: string): string {
  const baseParts = basePath.split('/').slice(0, -1);
  const relativeParts = relativePath.split('/');
  const stack = [...baseParts];

  for (const part of relativeParts) {
    if (part === '.' || part === '') {
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

  return stack.join('/');
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
