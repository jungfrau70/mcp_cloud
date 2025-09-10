# backend/app/api/routes/trending.py
from fastapi import APIRouter, Depends, HTTPException
from typing import Dict, Any
from pathlib import Path
import json
from security import get_api_key

router = APIRouter(prefix="/api/v1/trending", tags=["Knowledge Base"], dependencies=[Depends(get_api_key)])

DATA_FILE = Path('/app/backend/data/trending_categories.json')

def _read() -> Dict[str, Any]:
    if not DATA_FILE.exists():
        return {"categories": []}
    try:
        return json.loads(DATA_FILE.read_text(encoding='utf-8'))
    except Exception:
        return {"categories": []}

def _write(data: Dict[str, Any]):
    DATA_FILE.parent.mkdir(parents=True, exist_ok=True)
    DATA_FILE.write_text(json.dumps(data, ensure_ascii=False, indent=2), encoding='utf-8')

@router.get('/categories')
def list_categories():
    return _read()

@router.post('/categories')
def upsert_category(item: Dict[str, Any]):
    name = (item.get('name') or '').strip()
    query = (item.get('query') or '').strip()
    if not name or not query:
        raise HTTPException(status_code=400, detail='name and query are required')
    enabled = bool(item.get('enabled', True))
    data = _read()
    cats = data.get('categories', [])
    remaining = [c for c in cats if c.get('name') != name]
    remaining.append({"name": name, "query": query, "enabled": enabled})
    data['categories'] = remaining
    _write(data)
    return {"ok": True}

@router.delete('/categories/{name}')
def delete_category(name: str):
    data = _read()
    cats = data.get('categories', [])
    next_cats = [c for c in cats if c.get('name') != name]
    if len(next_cats) == len(cats):
        raise HTTPException(status_code=404, detail='Not found')
    data['categories'] = next_cats
    _write(data)
    return {"ok": True}

@router.post('/run-now')
def run_now():
    # Placeholder for background job trigger
    return {"ok": True}


