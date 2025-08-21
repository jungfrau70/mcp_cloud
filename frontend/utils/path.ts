export function stripBasePath(path: string, basePath = 'mcp_knowledge_base/'): string {
  if (path.startsWith(basePath)) return path.substring(basePath.length)
  return path
}

export function sanitizeGeneratedFilename(title: string): string {
  let rel = title.toLowerCase().trim()
  rel = rel.replace(/[^a-z0-9\-\s]/g,'').replace(/\s+/g,'-')
  if(!rel) rel = 'generated-' + Date.now()
  if(!rel.endsWith('.md')) rel += '.md'
  return rel
}
