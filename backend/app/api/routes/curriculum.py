# backend/app/api/routes/slides.py
from fastapi import APIRouter, Depends, HTTPException
from typing import Any, Dict, List
from pathlib import Path
from security import get_api_key
from fastapi.responses import PlainTextResponse, FileResponse

router = APIRouter(prefix="/api/v1/curriculum", tags=["Curriculum"])

KB_ROOT = Path('/mcp_knowledge_base').resolve()
SELECTION_FILE = KB_ROOT / '.slides_selection.json'

def _safe_path(rel: str) -> Path:
    rel = (rel or '').strip().lstrip('/\\')
    p = (KB_ROOT / rel).resolve()
    if not str(p).startswith(str(KB_ROOT)):
        raise HTTPException(status_code=400, detail='Invalid path')
    return p

def _build_tree() -> Dict[str, Any]:
    # Simple merge of selected dirs under KB_ROOT
    data: Dict[str, Any] = {}
    selected = get_selection().get('selected_dirs', [])

    def build(d: Path) -> Dict[str, Any]:
        tree: Dict[str, Any] = {}
        files = []
        for child in sorted(d.iterdir()):
            if child.is_dir():
                tree[child.name] = build(child)
            else:
                files.append({"name": child.name, "path": str(child.relative_to(KB_ROOT)).replace('\\','/')})
        if files:
            tree['files'] = files
        return tree

    for rel in selected:
        p = (KB_ROOT / rel).resolve()
        if p.exists() and str(p).startswith(str(KB_ROOT)):
            data[rel.split('/')[-1]] = build(p)
    return data

@router.get('/tree')
def curriculum_tree():
    return _build_tree()


@router.get('/selection')
def get_selection():
    if not SELECTION_FILE.exists():
        return {"selected_dirs": []}
    try:
        import json
        return {"selected_dirs": json.loads(SELECTION_FILE.read_text())}
    except Exception:
        return {"selected_dirs": []}

@router.post('/selection', dependencies=[Depends(get_api_key)])
def set_selection(payload: Dict[str, List[str]]):
    selected = payload.get('selected_dirs') or []
    try:
        import json
        SELECTION_FILE.write_text(json.dumps(selected))
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
    return {"ok": True}

# @router.get('/`tree`')
# def slides_tree():
#     # Simple merge of selected dirs under KB_ROOT
#     data: Dict[str, Any] = {}
#     selected = get_selection().get('selected_dirs', [])

#     def build(d: Path) -> Dict[str, Any]:
#         tree: Dict[str, Any] = {}
#         files = []
#         for child in sorted(d.iterdir()):
#             if child.is_dir():
#                 tree[child.name] = build(child)
#             else:
#                 files.append({"name": child.name, "path": str(child.relative_to(KB_ROOT)).replace('\\','/')})
#         if files:
#             tree['files'] = files
#         return tree

#     for rel in selected:
#         p = (KB_ROOT / rel).resolve()
#         if p.exists() and str(p).startswith(str(KB_ROOT)):
#             data[rel.split('/')[-1]] = build(p)
#     return data

@router.get('')
def get_slide(textbook_path: str = None, curriculum_path: str = None):
    """Return slide content (text) for curriculum items.

    Accepts both 'curriculum_path' (new) and 'textbook_path' (legacy) for compatibility.
    """
    raw = curriculum_path if curriculum_path is not None else textbook_path
    if not raw:
        raise HTTPException(status_code=400, detail='Missing curriculum_path')
    # Accept paths with or without extension; default to .md
    rel = raw.strip().lstrip('/\\')
    if not any(rel.endswith(ext) for ext in ('.md', '.markdown', '.txt', '.pdf')):
        rel = f"{rel}.md"
    fp = (KB_ROOT / rel).resolve()
    if not str(fp).startswith(str(KB_ROOT)):
        raise HTTPException(status_code=400, detail='Invalid path')
    if not fp.exists():
        raise HTTPException(status_code=404, detail='Not found')
    # If PDF file requested, stream as binary
    if fp.suffix.lower() == '.pdf':
        if not fp.exists():
            raise HTTPException(status_code=404, detail='Not found')
        return FileResponse(str(fp), media_type='application/pdf', filename=fp.name, headers={'Content-Disposition': f'inline; filename="{fp.name}"'})

    # Default: return text content
    try:
        text = fp.read_text(encoding='utf-8', errors='ignore')
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
    return PlainTextResponse(text)

@router.get('/item')
def curriculum_get_item(path: str):
    """Read-only item fetch compatible with knowledge-base/item shape.

    Returns JSON: { path, type: 'file'|'directory', content? }
    """
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

@router.get('/pdf')
def download_pdf(path: str):
    """Download PDF for a given curriculum path.

    If path points to a markdown/text file, tries to find a sibling .pdf with the same basename.
    If a .pdf is directly requested, serves it. Otherwise falls back to returning the source text as attachment.
    """
    if not path:
        raise HTTPException(status_code=400, detail='path is required')
    rel = path.strip().lstrip('\\/')
    fp = (KB_ROOT / rel).resolve()
    if not str(fp).startswith(str(KB_ROOT)):
        raise HTTPException(status_code=400, detail='Invalid path')

    # If direct PDF requested
    if fp.suffix.lower() == '.pdf' and fp.exists():
        return FileResponse(str(fp), media_type='application/pdf', filename=fp.name, headers={'Content-Disposition': f'attachment; filename="{fp.name}"'})

    # Try sibling PDF with same stem
    stem = fp.with_suffix('')
    pdf_fp = stem.with_suffix('.pdf')
    if pdf_fp.exists():
        return FileResponse(str(pdf_fp), media_type='application/pdf', filename=pdf_fp.name, headers={'Content-Disposition': f'attachment; filename="{pdf_fp.name}"'})

    # Fallback: return original text as attachment
    try:
        text = fp.read_text(encoding='utf-8', errors='ignore')
    except Exception as e:
        raise HTTPException(status_code=404, detail=f'Not found or unreadable: {e}')
    return PlainTextResponse(text, headers={'Content-Disposition': f'attachment; filename="{stem.name}.md"'})


