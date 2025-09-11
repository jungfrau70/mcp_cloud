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
  // First strip base path, then normalize
  const stripped = stripBasePath(path)
  return normalizePath(stripped)
}

export function sanitizeGeneratedFilename(title: string): string {
  let rel = title.toLowerCase().trim()
  rel = rel.replace(/[^a-z0-9\-\s]/g,'').replace(/\s+/g,'-')
  if(!rel) rel = 'generated-' + Date.now()
  if(!rel.endsWith('.md')) rel += '.md'
  return rel
}
