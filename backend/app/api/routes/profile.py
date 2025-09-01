# backend/app/api/routes/profile.py
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List, Optional
from pydantic import BaseModel
from app.api.deps import get_db, get_current_user
from app.models import User, UserKey
from security import get_api_key

router = APIRouter(prefix="/api/v1/profile", tags=["User Profile"], dependencies=[Depends(get_api_key)]) # 헤더 기반 사용자 인증만 사용

class UserKeyCreate(BaseModel):
    name: str
    platform: str
    secret_value: str

class UserKeyResponse(BaseModel):
    id: int
    name: str
    platform: str
    fingerprint: Optional[str] = None
    created_at: str

    class Config:
        from_attributes = True

class ProfileResponse(BaseModel):
    email: str
    full_name: Optional[str] = None
    role: Optional[str] = None
    is_active: Optional[bool] = None

class ProfileUpdate(BaseModel):
    full_name: Optional[str] = None

@router.post("/keys", response_model=UserKeyResponse)
def create_api_key(key_in: UserKeyCreate, current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    new_key = UserKey(
        user_id=current_user.id,
        name=key_in.name,
        platform=key_in.platform,
        encrypted_value=key_in.secret_value.encode(),
    )
    db.add(new_key)
    db.commit()
    db.refresh(new_key)
    return UserKeyResponse.from_orm(new_key)

@router.get("/keys", response_model=List[UserKeyResponse])
def list_api_keys(current_user: User = Depends(get_current_user)):
    return [UserKeyResponse.from_orm(k) for k in current_user.keys]

@router.get("/me", response_model=ProfileResponse)
def get_profile(current_user: User = Depends(get_current_user)):
    return ProfileResponse(
        email=current_user.email,
        full_name=current_user.full_name,
        role=current_user.role,
        is_active=current_user.is_active,
    )

@router.patch("", response_model=ProfileResponse)
def update_profile(payload: ProfileUpdate, current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    changed = False
    if payload.full_name is not None and payload.full_name != current_user.full_name:
        current_user.full_name = payload.full_name
        changed = True
    if changed:
        db.add(current_user)
        db.commit()
        db.refresh(current_user)
    return ProfileResponse(
        email=current_user.email,
        full_name=current_user.full_name,
        role=current_user.role,
        is_active=current_user.is_active,
    )
