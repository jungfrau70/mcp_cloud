# backend/app/api/routes/profile.py
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List, Optional
from pydantic import BaseModel
from app.api.deps import get_db, get_current_user
from app.models import User, UserKey

router = APIRouter(prefix="/api/v1/profile", tags=["User Profile"])  # 헤더 기반 사용자 인증만 사용

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
