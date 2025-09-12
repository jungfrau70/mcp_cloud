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

  // Remove any base path prefixes
  let cleaned = stripBasePath(path)
  
  // Remove any leading/trailing slashes
  cleaned = cleaned.replace(/^\/+|\/+$/g, '')
  
  // Split into segments and remove empty ones
  const segments = cleaned.split('/').filter(segment => segment && segment.trim() !== '')
  
  // Remove consecutive duplicates
  const uniqueSegments: string[] = []
  let lastSegment = ''
  
  for (const segment of segments) {
    if (segment !== lastSegment) {
      uniqueSegments.push(segment)
      lastSegment = segment
    }
  }
  
  // Check for repeated patterns and remove them
  let result = uniqueSegments.join('/')
  
  // Remove patterns like "cloud_master/textbook/Day3/cloud_master/textbook/Day3/"
  const repeatedPattern = /(cloud_(?:basic|master|container)\/textbook\/Day\d+\/)(\1)+/g
  result = result.replace(repeatedPattern, '$1')
  
  // Final cleanup - remove multiple slashes and leading/trailing slashes
  return result.replace(/\/+/g, '/').replace(/^\/+|\/+$/g, '')
}

export function sanitizeGeneratedFilename(title: string): string {
  let rel = title.toLowerCase().trim()
  rel = rel.replace(/[^a-z0-9\-\s가-힣]/g,'').replace(/\s+/g,'-')
  if(!rel) rel = 'generated-' + Date.now()
  // Check if it already ends with .md before adding
  if(!rel.endsWith('.md')) rel += '.md'
  return rel
}
