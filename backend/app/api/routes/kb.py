# backend/app/api/routes/kb.py
from fastapi import APIRouter, Depends, HTTPException
from typing import Any, Dict
from pathlib import Path
from security import get_api_key
from ...schemas.kb import KBItemCreate, KBItemMove
from pydantic import BaseModel
from typing import List, Optional, Literal

router = APIRouter(prefix="/api/v1/knowledge-base", tags=["Knowledge Base"], dependencies=[Depends(get_api_key)])

KB_ROOT = Path('/mcp_knowledge_base').resolve()

def _safe_path(rel: str) -> Path:
    rel = (rel or '').strip().lstrip('/\\')
    p = (KB_ROOT / rel).resolve()
    if not str(p).startswith(str(KB_ROOT)):
        raise HTTPException(status_code=400, detail="Invalid path")
    return p

@router.get('/tree')
def kb_tree(path: str = "") -> Dict[str, Any]:
    base = _safe_path(path)
    base.mkdir(parents=True, exist_ok=True)

    def build(d: Path, rel: str = "") -> Dict[str, Any]:
        tree: Dict[str, Any] = {}
        files = []
        for child in sorted(d.iterdir()):
            child_rel = f"{rel}/{child.name}" if rel else child.name
            if child.is_dir():
                tree[child.name] = build(child, child_rel)
            else:
                files.append({"name": child.name, "path": child_rel})
        if files:
            tree['files'] = files
        return tree

    return build(base, path.strip('/'))

@router.get('/item')
def kb_get_item(path: str):
    fp = _safe_path(path)
    if not fp.exists():
        raise HTTPException(status_code=404, detail='Not found')
    if fp.is_dir():
        return {"path": path, "type": "directory"}
    try:
        content = fp.read_text(encoding='utf-8', errors='ignore')
    except Exception as e:
        raise HTTPException(status_code=500, detail=f'Failed to read file: {e}')
    return {"path": path, "type": "file", "content": content}

@router.post('/item')
def kb_create_item(payload: KBItemCreate):
    fp = _safe_path(payload.path)
    fp.parent.mkdir(parents=True, exist_ok=True)
    if payload.type == 'directory':
        fp.mkdir(exist_ok=True)
        return {"created": payload.path, "type": "directory"}
    fp.write_text(payload.content or "", encoding='utf-8')
    return {"created": payload.path, "type": "file"}

@router.patch('/item')
def kb_rename_item(payload: KBItemMove):
    src = _safe_path(payload.path)
    if not src.exists():
        raise HTTPException(status_code=404, detail='Source not found')
    dst = _safe_path(payload.new_path)
    dst.parent.mkdir(parents=True, exist_ok=True)
    src.rename(dst)
    return {"moved": {"from": payload.path, "to": payload.new_path}}

@router.delete('/item')
def kb_delete_item(path: str):
    fp = _safe_path(path)
    if not fp.exists():
        raise HTTPException(status_code=404, detail='Not found')
    if fp.is_dir():
        raise HTTPException(status_code=400, detail='Use directory delete endpoint')
    fp.unlink()
    return {"deleted": path}

@router.delete('/directory')
def kb_delete_directory(path: str, recursive: bool = False):
    fp = _safe_path(path)
    if not fp.exists():
        raise HTTPException(status_code=404, detail='Not found')
    if not fp.is_dir():
        raise HTTPException(status_code=400, detail='Not a directory')
    if any(fp.iterdir()) and not recursive:
        raise HTTPException(status_code=400, detail='Directory not empty (use recursive=true)')
    if recursive:
        import shutil
        shutil.rmtree(fp)
    else:
        fp.rmdir()
    return {"deleted": path}

# ----- Outline / Transform / Lint -----
class OutlineRequest(BaseModel):
    content: str

class KbOutlineItem(BaseModel):
    level: int
    text: str
    line: int

class KbOutlineResponse(BaseModel):
    outline: List[KbOutlineItem]

@router.post('/outline', response_model=KbOutlineResponse)
def outline(req: OutlineRequest):
    outline: List[KbOutlineItem] = []
    for idx, line in enumerate((req.content or '').splitlines()):
        if line.lstrip().startswith('#'):
            hashes = len(line) - len(line.lstrip('#'))
            title = line.lstrip('#').strip()
            if title:
                outline.append(KbOutlineItem(level=max(1, min(6, hashes)), text=title, line=idx+1))
    return {"outline": outline}

class TransformRequest(BaseModel):
    text: str
    kind: Literal['table','mermaid','summary']
    cols: Optional[int] = None
    diagramType: Optional[Literal['flow','sequence','gantt']] = None
    summaryLen: Optional[int] = 5
    use_rag: Optional[bool] = False
    model: Optional[str] = None
    temperature: Optional[float] = None
    topK: Optional[int] = None

class TransformResponse(BaseModel):
    result: str
    meta: Optional[Dict[str, Any]] = None

@router.post('/transform', response_model=TransformResponse)
def transform(req: TransformRequest):
    if req.kind == 'summary':
        sentences = [s.strip() for s in (req.text or '').replace('\n',' ').split('.') if s.strip()]
        n = max(1, min(len(sentences), req.summaryLen or 5))
        return {"result": '. '.join(sentences[:n]) + ('.' if n and not sentences[:n][-1].endswith('.') else '')}
    if req.kind == 'table':
        lines = [l.strip() for l in (req.text or '').splitlines() if l.strip()]
        header = lines[0] if lines else 'Col1|Col2'
        cols = [c.strip() for c in header.split('|')]
        align = '|'.join(['---' for _ in cols])
        body = '\n'.join(lines[1:])
        result = f"|{ '|'.join(cols) }|\n|{align}|\n{body}"
        return {"result": result}
    # mermaid
    diagram = req.diagramType or 'flow'
    if diagram == 'sequence':
        return {"result": "sequenceDiagram\n  participant A\n  participant B\n  A->>B: Hello"}
    if diagram == 'gantt':
        return {"result": "gantt\n  title Sample\n  section Phase\n  Task :a1, 2025-01-01, 3d"}
    return {"result": "graph TD\n  A[Start] --> B{Decision}\n  B -->|Yes| C[Do]\n  B -->|No| D[Skip]"}

class LintRequest(BaseModel):
    text: str

class LintIssue(BaseModel):
    line: int
    column: int
    message: str
    rule: Optional[str] = None

class LintResponse(BaseModel):
    issues: List[LintIssue]

@router.post('/lint', response_model=LintResponse)
def lint(req: LintRequest):
    issues: List[LintIssue] = []
    for idx, line in enumerate((req.text or '').splitlines()):
        if line.rstrip() != line and not line.endswith('  '):
            issues.append(LintIssue(line=idx+1, column=len(line), message='Trailing whitespace', rule='whitespace.trailing'))
    return {"issues": issues}

# ----- Versions / Diff / Tasks (minimal implementations) -----
class KbVersion(BaseModel):
    id: int
    version_no: int
    message: Optional[str] = None
    created_at: Optional[str] = None

class KbVersionsResponse(BaseModel):
    versions: List[KbVersion]

@router.get('/versions', response_model=KbVersionsResponse)
def list_versions(path: str):  # path kept for API compatibility
    return {"versions": []}

class DiffHunk(BaseModel):
    header: str
    lines: List[str]

class KbUnifiedDiff(BaseModel):
    diff_format: str
    hunks: List[DiffHunk]

@router.get('/diff', response_model=KbUnifiedDiff)
def unified_diff(path: str, v1: int, v2: int):
    return {"diff_format": "unified", "hunks": []}

class StructuredLine(BaseModel):
    type: str
    old_line: Optional[int]
    new_line: Optional[int]
    text: Optional[str] = None
    old_text: Optional[str] = None
    new_text: Optional[str] = None

class StructuredHunk(BaseModel):
    header: str
    lines: List[StructuredLine]

class KbStructuredDiff(BaseModel):
    diff_format: str
    hunks: List[StructuredHunk]
    v1: int
    v2: int

@router.get('/diff/structured', response_model=KbStructuredDiff)
def structured_diff(path: str, v1: int, v2: int):
    return {"diff_format": "structured", "hunks": [], "v1": v1, "v2": v2}

class KbTask(BaseModel):
    id: str
    type: str
    status: str
    stage: Optional[str] = None
    progress: Optional[int] = None
    error: Optional[str] = None
    updated_at: Optional[str] = None

class KbTaskList(BaseModel):
    tasks: List[KbTask]

@router.get('/tasks/recent', response_model=KbTaskList)
def recent_tasks(limit: int = 20):
    return {"tasks": []}

@router.get('/tasks/{task_id}', response_model=KbTask)
def task_status(task_id: str):
    raise HTTPException(status_code=404, detail="Task not found")

# In-memory simple task store (ephemeral)
_tasks: Dict[str, KbTask] = {}

@router.post('/compose/external', response_model=KbTask)
def compose_external(topic: str, fail_stage: Optional[str] = None):
    import uuid
    tid = str(uuid.uuid4())
    task = KbTask(id=tid, type='compose', status='running', stage='init', progress=10)
    _tasks[tid] = task
    # Immediately mark as done for MVP
    _tasks[tid] = KbTask(id=tid, type='compose', status='done', stage='complete', progress=100)
    return _tasks[tid]

@router.get('/tasks/{task_id}', response_model=KbTask, include_in_schema=False)
def get_task_status(task_id: str):
    t = _tasks.get(task_id)
    if not t:
        raise HTTPException(status_code=404, detail='Task not found')
    return t
