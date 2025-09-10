export function stripBasePath(path: string, basePath = 'mcp_knowledge_base'): string {
  // Normalize path separators and leading slashes
  const normalized = path.replace(/\\/g, '/').replace(/^\/+/, '')
  const prefix = basePath.endsWith('/') ? basePath : basePath + '/'
  if (normalized.startsWith(prefix)) return normalized.substring(prefix.length)
  return normalized
}

export function sanitizeGeneratedFilename(title: string): string {
  let rel = title.toLowerCase().trim()
  rel = rel.replace(/[^a-z0-9\-\s]/g,'').replace(/\s+/g,'-')
  if(!rel) rel = 'generated-' + Date.now()
  if(!rel.endsWith('.md')) rel += '.md'
  return rel
}
