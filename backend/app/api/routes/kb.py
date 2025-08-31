# backend/app/api/routes/kb.py
from fastapi import APIRouter, Depends, HTTPException, WebSocket, WebSocketDisconnect
from fastapi.responses import FileResponse, Response
from typing import Any, Dict
from pathlib import Path
from security import get_api_key, get_current_admin_user
from app.schemas.kb import KBItemCreate, KBItemMove
from config import MCP_API_KEY, DISABLE_AUTH, KB_PUBLIC_READ
from pydantic import BaseModel
from typing import List, Optional, Literal

router = APIRouter(
    prefix="/api/v1/knowledge-base",
    tags=["Knowledge Base"],
    dependencies=[] if KB_PUBLIC_READ else [Depends(get_api_key), Depends(get_current_admin_user)]
)

# Compatibility aliases for legacy tests
legacy_router = APIRouter(prefix="/api/v1/kb", tags=["Knowledge Base (legacy)"])

@legacy_router.get('/tree')
def legacy_kb_tree(path: str = ""):
    return kb_tree(path)

@legacy_router.get('/item')
def legacy_kb_get_item(path: str):
    return kb_get_item(path)

@legacy_router.post('/item')
def legacy_kb_create_item(payload: KBItemCreate):
    return kb_create_item(payload)

@legacy_router.patch('/item')
def legacy_kb_rename_item(payload: KBItemMove):
    return kb_rename_item(payload)

@legacy_router.delete('/item')
def legacy_kb_delete_item(path: str):
    return kb_delete_item(path)

# WebSocket router without API-key dependency (uses query param)
kb_ws_router = APIRouter(prefix="/api/v1/knowledge-base", tags=["Knowledge Base"])

@kb_ws_router.websocket('/tasks/ws')
async def kb_tasks_ws(websocket: WebSocket):
    # Accept first to be able to close with specific code
    await websocket.accept()
    try:
        if not DISABLE_AUTH:
            token = websocket.query_params.get('api_key')
            if not token or token != (MCP_API_KEY or ""):
                await websocket.close(code=1008)
                return
        # Minimal keep-alive loop
        import asyncio
        while True:
            await asyncio.sleep(30)
    except WebSocketDisconnect:
        return

KB_ROOT = Path('/mcp_knowledge_base').resolve()
try:
    from utils.doc_convert import convert_pptx_to_pdf  # correct import within backend package
except Exception:
    convert_pptx_to_pdf = None  # fallback when utils not importable in some envs

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

@router.get('/file')
def kb_get_file(path: str):
    """Return binary/static file contents with appropriate Content-Type.

    Intended for non-markdown assets like pdf/images/video or arbitrary downloads.
    """
    fp = _safe_path(path)
    if not fp.exists():
        raise HTTPException(status_code=404, detail='Not found')
    if fp.is_dir():
        raise HTTPException(status_code=400, detail='Path is a directory')

    # Handle PowerPoint → PDF conversion on the fly
    ext = (fp.suffix or '').lstrip('.').lower()
    if ext in {'ppt', 'pptx'}:
        if convert_pptx_to_pdf is None:
            raise HTTPException(status_code=501, detail='PPTX conversion is not available on server')
        try:
            pdf_path = convert_pptx_to_pdf(fp, KB_ROOT)
        except HTTPException as e:
            # propagate HTTPException as is
            raise e
        except Exception as e:
            raise HTTPException(status_code=500, detail=f'Conversion error: {e}')
        # Always inline PDF preview for converted output; let Starlette build headers safely
        return FileResponse(
            path=str(pdf_path),
            media_type='application/pdf',
            filename=pdf_path.name,
            content_disposition_type='inline'
        )

    # Guess content type
    import mimetypes
    ctype, _ = mimetypes.guess_type(fp.name)
    media_type = ctype or 'application/octet-stream'

    # Inline for common previewable types (pdf/images/video/audio), else download
    inline_exts = {
        'pdf','png','jpg','jpeg','gif','svg','webp','mp4','webm','mp3','wav'
    }
    disposition = 'inline' if ext in inline_exts else 'attachment'
    return FileResponse(
        path=str(fp),
        media_type=media_type,
        filename=fp.name,
        content_disposition_type=disposition
    )

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

@router.post('/move')
def kb_move(payload: KBItemMove):
    """Move or rename a file/directory. Alias for PATCH /item for compatibility.

    Expected payload: { "path": "src", "new_path": "dst" }
    """
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
