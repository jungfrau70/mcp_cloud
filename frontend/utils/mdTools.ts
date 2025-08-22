export function generateMarkdownTable(rows: number, cols: number, withHeader = true): string {
  const makeRow = (cells: number, fill: string) => `| ${Array.from({ length: cells }).map((_, i) => `${fill}${i+1}`).join(' | ')} |\n`
  let md = ''
  if (withHeader) {
    md += makeRow(cols, 'H')
    md += `| ${Array.from({ length: cols }).map(() => '---').join(' | ')} |\n`
  }
  for (let r = 0; r < rows - (withHeader ? 1 : 0); r++) {
    md += makeRow(cols, ' ')
  }
  return md
}

export function mermaidTemplate(kind: 'flow'|'sequence'|'gantt' = 'flow'): string {
  if (kind === 'sequence') {
    return ['```mermaid','sequenceDiagram','  participant User','  participant API','  User->>API: request','  API-->>User: response','```',''].join('\n')
  }
  if (kind === 'gantt') {
    return ['```mermaid','gantt','  dateFormat  YYYY-MM-DD','  title Deployment Pipeline','  section Plan','  Plan      :a1, 2025-01-01, 1d','  Apply     :a2, after a1, 1d','```',''].join('\n')
  }
  return ['```mermaid','flowchart LR','  A[User] --> B[FastAPI]','  B --> C[Terraform Plan]','```',''].join('\n')
}

export function vegaLiteBarTemplate(): string {
  const spec = {
    $schema: 'https://vega.github.io/schema/vega-lite/v5.json',
    data: { values: [ { stage: 'plan', sec: 12 }, { stage: 'apply', sec: 34 } ] },
    mark: 'bar',
    encoding: {
      x: { field: 'stage', type: 'nominal' },
      y: { field: 'sec', type: 'quantitative' }
    }
  }
  return ['```json','// vega-lite',''+JSON.stringify(spec, null, 2),'```',''].join('\n')
}

