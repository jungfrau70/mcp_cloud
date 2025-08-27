from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel
from typing import Optional, Any, Dict, List, Tuple
from sqlalchemy.orm import Session
from sqlalchemy import and_
from datetime import datetime, timedelta

from main import get_db
from models import ConfigItem, ConfigAudit

router = APIRouter(prefix="/api/v1/config", tags=["Config"])


# In-process TTL cache (avoid external deps); key by (env, service, tenant)
_CACHE: Dict[Tuple[str, str, Optional[str]], Tuple[datetime, Dict[str, Any]]] = {}
_CACHE_TTL = timedelta(seconds=90)


def _mask_secret(value: Any) -> Any:
    if value is None:
        return None
    s = str(value)
    if len(s) <= 4:
        return "****"
    return s[:2] + "****" + s[-2:]


def _resolve_from_db(db: Session, env: str, service: str, tenant: Optional[str]) -> Dict[str, Any]:
    # Specificity order: tenant > service > env > global(None)
    scopes = [
        (env, service, tenant),
        (env, service, None),
        (env, None, None),
        (None, None, None),
    ]
    merged: Dict[str, Any] = {}

    for se, ss, st in scopes:
        q = db.query(ConfigItem).filter(
            and_(
                (ConfigItem.scope_env == se) if se is not None else (ConfigItem.scope_env.is_(None)),
                (ConfigItem.scope_service == ss) if ss is not None else (ConfigItem.scope_service.is_(None)),
                (ConfigItem.scope_tenant == st) if st is not None else (ConfigItem.scope_tenant.is_(None)),
                ConfigItem.enabled.is_(True),
            )
        )
        for item in q.all():
            if item.key in merged:
                continue  # already set by a more specific scope
            if item.is_secret:
                merged[item.key] = _mask_secret("<secret>")
            else:
                merged[item.key] = item.value_json if item.value_json is not None else item.value_plain
    return merged


class CreateConfigItem(BaseModel):
    scope_env: Optional[str] = None
    scope_service: Optional[str] = None
    scope_tenant: Optional[str] = None
    key: str
    value_plain: Optional[str] = None
    value_json: Optional[Dict[str, Any]] = None
    is_secret: bool = False
    secret_ciphertext_b64: Optional[str] = None  # placeholder for future KMS/Vault
    secret_key_id: Optional[str] = None
    updated_by: Optional[str] = None


class UpdateConfigItem(BaseModel):
    value_plain: Optional[str] = None
    value_json: Optional[Dict[str, Any]] = None
    is_secret: Optional[bool] = None
    enabled: Optional[bool] = None
    updated_by: Optional[str] = None


@router.get("/resolve")
def resolve(env: str, service: str, tenant: Optional[str] = None, db: Session = Depends(get_db)):
    if not env or not service:
        raise HTTPException(status_code=400, detail="env and service are required")
    cache_key = (env, service, tenant)
    now = datetime.utcnow()
    cached = _CACHE.get(cache_key)
    if cached and (now - cached[0]) < _CACHE_TTL:
        return {"env": env, "service": service, "tenant": tenant, "config": cached[1], "cached": True}
    merged = _resolve_from_db(db, env, service, tenant)
    _CACHE[cache_key] = (now, merged)
    return {"env": env, "service": service, "tenant": tenant, "config": merged, "cached": False}


@router.post("")
def create_item(payload: CreateConfigItem, db: Session = Depends(get_db)):
    item = ConfigItem(
        scope_env=payload.scope_env,
        scope_service=payload.scope_service,
        scope_tenant=payload.scope_tenant,
        key=payload.key,
        value_plain=payload.value_plain,
        value_json=payload.value_json,
        is_secret=payload.is_secret,
        secret_ciphertext=None,  # integrate KMS/Vault later
        secret_key_id=payload.secret_key_id,
        version=1,
        enabled=True,
        updated_by=payload.updated_by,
        updated_at=datetime.utcnow(),
    )
    db.add(item)
    db.flush()
    db.add(ConfigAudit(item_id=item.id, action="create", diff=None, actor=payload.updated_by, created_at=datetime.utcnow()))
    db.commit()
    # Invalidate cache for affected scopes (simple clear-all for now)
    _CACHE.clear()
    return {"id": item.id, "ok": True}


@router.patch("/{item_id}")
def update_item(item_id: int, payload: UpdateConfigItem, db: Session = Depends(get_db)):
    item = db.query(ConfigItem).filter(ConfigItem.id == item_id).first()
    if not item:
        raise HTTPException(status_code=404, detail="item not found")
    before = {
        "value_plain": item.value_plain,
        "value_json": item.value_json,
        "is_secret": item.is_secret,
        "enabled": item.enabled,
    }
    if payload.value_plain is not None:
        item.value_plain = payload.value_plain
    if payload.value_json is not None:
        item.value_json = payload.value_json
    if payload.is_secret is not None:
        item.is_secret = payload.is_secret
    if payload.enabled is not None:
        item.enabled = payload.enabled
    item.version = (item.version or 1) + 1
    item.updated_by = payload.updated_by
    item.updated_at = datetime.utcnow()
    after = {
        "value_plain": item.value_plain,
        "value_json": item.value_json,
        "is_secret": item.is_secret,
        "enabled": item.enabled,
    }
    db.add(ConfigAudit(item_id=item.id, action="update", diff={"before": before, "after": after}, actor=payload.updated_by, created_at=datetime.utcnow()))
    db.commit()
    _CACHE.clear()
    return {"id": item.id, "ok": True, "version": item.version}


@router.get("/{item_id}/audit")
def audit(item_id: int, db: Session = Depends(get_db)):
    audits: List[ConfigAudit] = db.query(ConfigAudit).filter(ConfigAudit.item_id == item_id).order_by(ConfigAudit.created_at.desc()).all()
    return {
        "id": item_id,
        "events": [
            {
                "action": a.action,
                "actor": a.actor,
                "created_at": a.created_at.isoformat() if a.created_at else None,
                "diff": a.diff,
            } for a in audits
        ]
    }


