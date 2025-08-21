import os
from typing import Optional, List, Dict, Any
from sqlalchemy.orm import Session
from sqlalchemy import select, func
from datetime import datetime, timezone
from models import KbDocument, KbDocumentVersion, KbTask
import json, sys


def normalize_path(path: str) -> str:
    # Prevent path traversal and unify separators
    path = path.replace('..', '').replace('\\', '/').strip('/')
    return path


def get_or_create_document(db: Session, path: str) -> KbDocument:
    npath = normalize_path(path)
    doc = db.scalar(select(KbDocument).where(KbDocument.path == npath))
    if doc:
        return doc
    doc = KbDocument(path=npath, title=os.path.basename(npath))
    db.add(doc)
    db.flush()  # assign id
    return doc


def create_version(db: Session, document: KbDocument, content: str, message: Optional[str], author: str = 'system') -> KbDocumentVersion:
    # compute next version number
    max_no = db.scalar(select(func.max(KbDocumentVersion.version_no)).where(KbDocumentVersion.document_id == document.id)) or 0
    next_no = max_no + 1
    ver = KbDocumentVersion(
        document_id=document.id,
        version_no=next_no,
        content=content,
        message=message,
        author=author,
        size_bytes=len(content.encode('utf-8'))
    )
    db.add(ver)
    db.flush()
    document.latest_version_id = ver.id
    document.updated_at = datetime.now(timezone.utc)
    return ver


def list_versions(db: Session, path: str, limit: int = 50, offset: int = 0) -> List[Dict[str, Any]]:
    npath = normalize_path(path)
    doc = db.scalar(select(KbDocument).where(KbDocument.path == npath))
    if not doc:
        return []
    rows = db.execute(
        select(
            KbDocumentVersion.id,
            KbDocumentVersion.version_no,
            KbDocumentVersion.message,
            KbDocumentVersion.author,
            KbDocumentVersion.size_bytes,
            KbDocumentVersion.created_at
        ).where(KbDocumentVersion.document_id == doc.id)
         .order_by(KbDocumentVersion.version_no.desc())
         .limit(limit).offset(offset)
    ).all()
    return [
        {
            'id': r.id,
            'version_no': r.version_no,
            'message': r.message,
            'author': r.author,
            'size_bytes': r.size_bytes,
            'created_at': r.created_at.isoformat()
        }
        for r in rows
    ]


def get_latest_content(db: Session, path: str) -> Optional[Dict[str, Any]]:
    npath = normalize_path(path)
    doc = db.scalar(select(KbDocument).where(KbDocument.path == npath))
    if not doc or not doc.latest_version_id:
        return None
    ver = db.get(KbDocumentVersion, doc.latest_version_id)
    if not ver:
        return None
    return {
        'path': npath,
        'content': ver.content,
        'version_no': ver.version_no,
        'updated_at': ver.created_at.isoformat()
    }


def record_task(db: Session, task_id: str, type_: str, status: str = 'pending', stage: str = None, progress: int = 0, input: Dict[str, Any] = None):
    t = KbTask(
        id=task_id,
        type=type_,
        status=status,
        stage=stage,
        progress=progress,
        input=input or {}
    )
    db.add(t)
    return t


def update_task(db: Session, task_id: str, **fields):
    t = db.get(KbTask, task_id)
    if not t:
        return None
    for k, v in fields.items():
        setattr(t, k, v)
    from datetime import datetime, timezone
    t.updated_at = datetime.now(timezone.utc)
    return t

def log_task_event(level: str, task_id: str, type_: str, stage: str, status: str, **extra):
    record = {
        'ts': datetime.now(timezone.utc).isoformat(),
        'level': level,
        'component': 'kb_task',
        'task_id': task_id,
        'task_type': type_,
        'stage': stage,
        'status': status,
        **extra
    }
    try:
        json.dump(record, sys.stdout)
        sys.stdout.write('\n')
    except Exception:
        pass


def get_task(db: Session, task_id: str) -> Optional[Dict[str, Any]]:
    t = db.get(KbTask, task_id)
    if not t:
        return None
    return {
        'id': t.id,
        'type': t.type,
        'status': t.status,
        'stage': t.stage,
        'progress': t.progress,
        'input': t.input,
        'output': t.output,
        'error': t.error,
        'updated_at': t.updated_at.isoformat()
    }
