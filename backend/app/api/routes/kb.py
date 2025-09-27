# backend/app/api/routes/kb.py
from fastapi import APIRouter, Depends, HTTPException, WebSocket, WebSocketDisconnect, UploadFile, File, Form
from fastapi.responses import FileResponse, Response
from typing import Any, Dict
from pathlib import Path
from security import get_api_key, get_current_admin_user
from app.schemas.kb import KBItemCreate, KBItemMove
from config import MCP_API_KEY, DISABLE_AUTH, KB_PUBLIC_READ
from pydantic import BaseModel
from typing import List, Optional, Literal
import shutil
import os
import urllib.parse

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
            expected_key = MCP_API_KEY or ""
            print(f"DEBUG: WebSocket auth - DISABLE_AUTH: {DISABLE_AUTH}")
            print(f"DEBUG: WebSocket auth - MCP_API_KEY from env: {MCP_API_KEY}")
            print(f"DEBUG: WebSocket auth - token: {token}, expected: {expected_key}, match: {token == expected_key}")
            if not token or token != expected_key:
                print(f"DEBUG: WebSocket auth failed - token: '{token}', expected: '{expected_key}'")
                await websocket.close(code=1008, reason="Authentication failed")
                return
        print("DEBUG: WebSocket auth successful")
        # Minimal keep-alive loop
        import asyncio
        while True:
            await asyncio.sleep(30)
    except WebSocketDisconnect:
        return

# Docker 환경과 로컬 환경 모두 지원
KB_ROOT = Path('../mcp_knowledge_base').resolve()
if not KB_ROOT.exists():
    # Docker 환경에서 시도
    KB_ROOT = Path('/app/../mcp_knowledge_base').resolve()
if not KB_ROOT.exists():
    # 절대 경로로 시도
    KB_ROOT = Path('/mcp_knowledge_base').resolve()
try:
    from utils.doc_convert import convert_pptx_to_pdf  # correct import within backend package
except Exception:
    convert_pptx_to_pdf = None  # fallback when utils not importable in some envs

def _safe_path(rel: str) -> Path:
    rel = (rel or '').strip().lstrip('/\\')
    
    # 한글 파일명 디코딩 처리 (URL 인코딩된 한글 파일명을 원래 한글로 복원)
    try:
        # URL 인코딩된 한글 파일명 디코딩
        if '%' in rel:
            # 재귀적 디코딩: 2중 인코딩된 경우를 처리
            while '%' in rel and rel != urllib.parse.unquote(rel):
                rel = urllib.parse.unquote(rel)
            print(f"DEBUG: _safe_path - decoded Korean filename: {rel}")
    except Exception as e:
        print(f"DEBUG: _safe_path - failed to decode Korean filename: {e}")
    
    # 경로 중복 제거 로직 추가
    if rel:
        # 중복된 경로 세그먼트 제거
        segments = rel.split('/')
        cleaned_segments = []
        last_segment = ''
        
        for segment in segments:
            if segment and segment != last_segment:
                cleaned_segments.append(segment)
                last_segment = segment
        
        # 중복된 패턴 제거 (예: cloud_master/cloud_master/cloud_master/)
        course_patterns = ['cloud_basic', 'cloud_master', 'cloud_container']
        for pattern in course_patterns:
            pattern_regex = f'/{pattern}/'
            while pattern_regex + pattern_regex in '/'.join(cleaned_segments):
                cleaned_segments = '/'.join(cleaned_segments).replace(pattern_regex + pattern_regex, pattern_regex).split('/')
        
        # textbook/DayX 패턴 중복 제거
        import re
        textbook_pattern = r'/(textbook/Day\d+)/'
        text_path = '/'.join(cleaned_segments)
        while re.search(textbook_pattern + r'\1', text_path):
            text_path = re.sub(textbook_pattern + r'\1', r'\1', text_path)
        cleaned_segments = text_path.split('/')
        
        rel = '/'.join(cleaned_segments)
    
    p = (KB_ROOT / rel).resolve()
    print(f"DEBUG: _safe_path - original rel: {rel}")
    print(f"DEBUG: _safe_path - cleaned rel: {rel}")
    print(f"DEBUG: _safe_path - KB_ROOT: {KB_ROOT}")
    print(f"DEBUG: _safe_path - p: {p}")
    print(f"DEBUG: _safe_path - str(p): {str(p)}")
    print(f"DEBUG: _safe_path - str(KB_ROOT): {str(KB_ROOT)}")
    print(f"DEBUG: _safe_path - starts_with: {str(p).startswith(str(KB_ROOT))}")
    if not str(p).startswith(str(KB_ROOT)):
        raise HTTPException(status_code=400, detail=f"Invalid path: {str(p)} does not start with {str(KB_ROOT)}")
    return p

@router.get('/tree')
def kb_tree(path: str = "") -> Dict[str, Any]:
    base = _safe_path(path)
    base.mkdir(parents=True, exist_ok=True)

    def build(d: Path, rel: str = "") -> Dict[str, Any]:
        tree: Dict[str, Any] = {}
        files = []
        for child in sorted(d.iterdir()):
            # Windows 경로 구분자를 Unix 스타일로 정규화
            child_rel = f"{rel}/{child.name}" if rel else child.name
            # Windows 경로 구분자(\\)를 Unix 경로 구분자(/)로 변환
            child_rel = child_rel.replace("\\", "/")
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
    print(f"DEBUG: kb_get_item called with path: {path}")
    
    # URL 디코딩 처리 (한글 파일명 지원, 2중 인코딩 방지)
    try:
        decoded_path = path
        # 재귀적 디코딩: 2중 인코딩된 경우를 처리
        while '%' in decoded_path and decoded_path != urllib.parse.unquote(decoded_path):
            decoded_path = urllib.parse.unquote(decoded_path)
    except Exception:
        decoded_path = path
    
    print(f"DEBUG: decoded_path = {decoded_path}")
    fp = _safe_path(decoded_path)
    print(f"DEBUG: KB_ROOT = {KB_ROOT}")
    print(f"DEBUG: fp = {fp}")
    print(f"DEBUG: fp.exists() = {fp.exists()}")
    if not fp.exists():
        raise HTTPException(status_code=404, detail='Not found')
    if fp.is_dir():
        return {"path": path, "type": "directory"}
    try:
        content = fp.read_text(encoding='utf-8', errors='ignore')
        print(f"DEBUG: content length = {len(content)}")
    except Exception as e:
        raise HTTPException(status_code=500, detail=f'Failed to read file: {e}')
    return {"path": path, "type": "file", "content": content}

@router.get('/file')
def kb_get_file(path: str):
    """Return binary/static file contents with appropriate Content-Type.

    Intended for non-markdown assets like pdf/images/video or arbitrary downloads.
    """
    # URL 디코딩 처리 (한글 파일명 지원, 2중 인코딩 방지)
    try:
        decoded_path = path
        # 재귀적 디코딩: 2중 인코딩된 경우를 처리
        while '%' in decoded_path and decoded_path != urllib.parse.unquote(decoded_path):
            decoded_path = urllib.parse.unquote(decoded_path)
    except Exception:
        decoded_path = path
    
    fp = _safe_path(decoded_path)
    if not fp.exists():
        raise HTTPException(status_code=404, detail='Not found')
    if fp.is_dir():
        raise HTTPException(status_code=400, detail='Path is a directory')

    # Handle PowerPoint → PDF conversion on the fly (if available)
    ext = (fp.suffix or '').lstrip('.').lower()
    if ext in {'ppt', 'pptx'}:
        if convert_pptx_to_pdf is not None:
            try:
                pdf_path = convert_pptx_to_pdf(fp, KB_ROOT)
                # Always inline PDF preview for converted output; let Starlette build headers safely
                return FileResponse(
                    path=str(pdf_path),
                    media_type='application/pdf',
                    filename=pdf_path.name,
                    content_disposition_type='inline'
                )
            except HTTPException as e:
                # propagate HTTPException as is
                raise e
            except Exception as e:
                raise HTTPException(status_code=500, detail=f'Conversion error: {e}')
        else:
            # Fallback: serve PPTX as download if conversion is not available
            print(f"PPTX conversion not available, serving as download: {fp.name}")
            return FileResponse(
                path=str(fp),
                media_type='application/vnd.openxmlformats-officedocument.presentationml.presentation',
                filename=fp.name,
                content_disposition_type='attachment'
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

@router.put('/item')
def kb_save_item(payload: dict):
    """Save file content"""
    path = payload.get('path')
    content = payload.get('content', '')
    if not path:
        raise HTTPException(status_code=400, detail='Path is required')
    
    fp = _safe_path(path)
    fp.parent.mkdir(parents=True, exist_ok=True)
    
    try:
        fp.write_text(content, encoding='utf-8')
        return {"saved": path, "type": "file", "content": content}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f'Failed to save file: {e}')

@router.post('/move')
def kb_move(payload: KBItemMove):
    """Move or rename a file/directory. Alias for PATCH /item for compatibility.

    Expected payload: { "path": "src", "new_path": "dst" }
    """
    src = _safe_path(payload.path)
    if not src.exists():
        raise HTTPException(status_code=404, detail='Source not found')
    dst = _safe_path(payload.new_path)
    
    # 휴지통 디렉토리인 경우 특별 처리
    if payload.new_path.startswith('.trash/'):
        # 휴지통 루트 디렉토리 생성
        trash_root = _safe_path('.trash')
        if not trash_root.exists():
            trash_root.mkdir(parents=True, exist_ok=True)
            print(f"휴지통 디렉토리 생성: {trash_root}")
        
        # 타임스탬프 디렉토리 생성
        timestamp_dir = _safe_path('/'.join(payload.new_path.split('/')[:2]))
        if not timestamp_dir.exists():
            timestamp_dir.mkdir(parents=True, exist_ok=True)
            print(f"휴지통 타임스탬프 디렉토리 생성: {timestamp_dir}")
    
    # 대상 디렉토리 생성 (기존 로직)
    dst.parent.mkdir(parents=True, exist_ok=True)
    
    # 파일/디렉토리 이동
    src.rename(dst)
    return {"moved": {"from": payload.path, "to": payload.new_path}}

@router.delete('/item')
def kb_delete_item(path: str):
    try:
        fp = _safe_path(path)
        if not fp.exists():
            return {
                "success": False,
                "message": "파일을 찾을 수 없습니다.",
                "path": path,
                "error": "FILE_NOT_FOUND"
            }
        if fp.is_dir():
            return {
                "success": False,
                "message": "디렉토리는 삭제할 수 없습니다. 디렉토리 삭제 엔드포인트를 사용하세요.",
                "path": path,
                "error": "IS_DIRECTORY"
            }
        
        fp.unlink()
        return {
            "success": True,
            "message": "파일이 성공적으로 삭제되었습니다.",
            "path": path
        }
    except PermissionError:
        return {
            "success": False,
            "message": "파일 삭제 권한이 없습니다.",
            "path": path,
            "error": "PERMISSION_DENIED"
        }
    except Exception as e:
        return {
            "success": False,
            "message": f"파일 삭제 중 오류가 발생했습니다: {str(e)}",
            "path": path,
            "error": "DELETE_FAILED"
        }

@router.get('/trash')
def kb_list_trash():
    """휴지통에 있는 파일 목록 조회"""
    trash_root = _safe_path('.trash')
    if not trash_root.exists():
        return {"trash_items": []}
    
    trash_items = []
    for timestamp_dir in trash_root.iterdir():
        if timestamp_dir.is_dir():
            for item in timestamp_dir.rglob('*'):
                if item.is_file():
                    # 원본 경로 복원 (타임스탬프 디렉토리 제거)
                    original_path = str(item.relative_to(timestamp_dir))
                    trash_items.append({
                        "original_path": original_path,
                        "trash_path": str(item.relative_to(_safe_path('.'))),
                        "deleted_at": timestamp_dir.name,
                        "size": item.stat().st_size
                    })
    
    return {"trash_items": trash_items}

@router.post('/trash/restore')
def kb_restore_from_trash(trash_path: str):
    """휴지통에서 파일 복원"""
    trash_item = _safe_path(trash_path)
    if not trash_item.exists():
        raise HTTPException(status_code=404, detail='Trash item not found')
    
    # 원본 경로로 복원
    original_path = _safe_path(trash_item.relative_to(_safe_path('.trash').joinpath(trash_item.parts[1])))
    original_path.parent.mkdir(parents=True, exist_ok=True)
    
    trash_item.rename(original_path)
    return {"restored": {"from": trash_path, "to": str(original_path)}}

@router.delete('/trash/empty')
def kb_empty_trash():
    """휴지통 비우기"""
    trash_root = _safe_path('.trash')
    if not trash_root.exists():
        return {"emptied": True, "deleted_count": 0}
    
    deleted_count = 0
    for item in trash_root.rglob('*'):
        if item.is_file():
            item.unlink()
            deleted_count += 1
        elif item.is_dir() and item != trash_root:
            item.rmdir()
    
    return {"emptied": True, "deleted_count": deleted_count}

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

@router.post('/upload')
async def kb_upload_file(
    file: UploadFile = File(...),
    path: str = Form(""),
    overwrite: bool = Form(False)
):
    """
    Upload a file to the knowledge base.
    
    Args:
        file: The file to upload
        path: Target directory path (relative to knowledge base root)
        overwrite: Whether to overwrite existing files
    """
    try:
        # Validate file
        if not file.filename:
            raise HTTPException(status_code=400, detail="No filename provided")
        
        # Sanitize filename
        filename = os.path.basename(file.filename)
        if not filename or filename.startswith('.'):
            raise HTTPException(status_code=400, detail="Invalid filename")
        
        # Determine target path
        target_dir = _safe_path(path)
        target_file = target_dir / filename
        
        # Check if file exists and overwrite is not allowed
        if target_file.exists() and not overwrite:
            raise HTTPException(status_code=409, detail="File already exists. Use overwrite=true to replace.")
        
        # Ensure target directory exists
        target_dir.mkdir(parents=True, exist_ok=True)
        
        # Save file
        with open(target_file, "wb") as buffer:
            shutil.copyfileobj(file.file, buffer)
        
        # Get file info
        file_size = target_file.stat().st_size
        relative_path = str(target_file.relative_to(KB_ROOT))
        
        return {
            "success": True,
            "message": "File uploaded successfully",
            "filename": filename,
            "path": relative_path,
            "size": file_size,
            "overwritten": target_file.exists() and overwrite
        }
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Upload failed: {str(e)}")

@router.post('/upload-multiple')
async def kb_upload_multiple_files(
    files: List[UploadFile] = File(...),
    path: str = Form(""),
    overwrite: bool = Form(False)
):
    """
    Upload multiple files to the knowledge base.
    
    Args:
        files: List of files to upload
        path: Target directory path (relative to knowledge base root)
        overwrite: Whether to overwrite existing files
    """
    results = []
    errors = []
    
    for file in files:
        try:
            # Validate file
            if not file.filename:
                errors.append({"filename": file.filename or "unknown", "error": "No filename provided"})
                continue
            
            # Sanitize filename
            filename = os.path.basename(file.filename)
            if not filename or filename.startswith('.'):
                errors.append({"filename": file.filename, "error": "Invalid filename"})
                continue
            
            # Determine target path
            target_dir = _safe_path(path)
            target_file = target_dir / filename
            
            # Check if file exists and overwrite is not allowed
            if target_file.exists() and not overwrite:
                errors.append({"filename": filename, "error": "File already exists"})
                continue
            
            # Ensure target directory exists
            target_dir.mkdir(parents=True, exist_ok=True)
            
            # Save file
            with open(target_file, "wb") as buffer:
                shutil.copyfileobj(file.file, buffer)
            
            # Get file info
            file_size = target_file.stat().st_size
            relative_path = str(target_file.relative_to(KB_ROOT))
            
            results.append({
                "filename": filename,
                "path": relative_path,
                "size": file_size,
                "overwritten": target_file.exists() and overwrite
            })
            
        except Exception as e:
            errors.append({"filename": file.filename or "unknown", "error": str(e)})
    
    return {
        "success": len(errors) == 0,
        "message": f"Uploaded {len(results)} files successfully",
        "results": results,
        "errors": errors,
        "total_files": len(files),
        "successful": len(results),
        "failed": len(errors)
    }

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
