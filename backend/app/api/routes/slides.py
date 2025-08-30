# backend/app/api/routes/slides.py
from fastapi import APIRouter, Depends, HTTPException
from typing import Any, Dict, List
from pathlib import Path
from security import get_api_key
from fastapi.responses import PlainTextResponse

router = APIRouter(prefix="/api/v1/slides", tags=["Slides"])  # GET은 공개, POST는 보호

# Legacy compatibility for tests expecting /api/v1/curriculum
legacy_router = APIRouter(prefix="/api/v1/curriculum", tags=["Slides (legacy)"])

@legacy_router.get('/tree')
def legacy_curriculum_tree():
    return slides_tree()

KB_ROOT = Path('/mcp_knowledge_base').resolve()
SELECTION_FILE = KB_ROOT / '.slides_selection.json'

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

@router.get('/tree')
def slides_tree():
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

@router.get('')
def get_slide(textbook_path: str):
    # Accept paths with or without extension; default to .md
    rel = textbook_path.strip().lstrip('/\\')
    if not any(rel.endswith(ext) for ext in ('.md', '.markdown', '.txt', '.pdf')):
        rel = f"{rel}.md"
    fp = (KB_ROOT / rel).resolve()
    if not str(fp).startswith(str(KB_ROOT)):
        raise HTTPException(status_code=400, detail='Invalid path')
    if not fp.exists():
        raise HTTPException(status_code=404, detail='Not found')
    # Minimal implementation: return text content; PDF handling can be added later
    try:
        text = fp.read_text(encoding='utf-8', errors='ignore')
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
    return PlainTextResponse(text)


