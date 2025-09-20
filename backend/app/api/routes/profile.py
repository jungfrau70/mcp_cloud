# backend/app/api/routes/profile.py
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List, Optional
from pydantic import BaseModel
from app.api.deps import get_db, get_current_user
from app.models import User, UserKey
from security import get_api_key
import os
from cryptography.fernet import Fernet

# --- Encryption Utility ---
ENCRYPTION_KEY = os.getenv("CREDENTIAL_ENCRYPTION_KEY", "placeholder_must_be_32_byte_secret_key")
if len(ENCRYPTION_KEY.encode()) < 32:
    ENCRYPTION_KEY = ENCRYPTION_KEY.ljust(32, '=')

fernet = Fernet(ENCRYPTION_KEY.encode())

def encrypt_value(value: str) -> bytes:
    return fernet.encrypt(value.encode())

def decrypt_value(encrypted_value: bytes) -> str:
    return fernet.decrypt(encrypted_value).decode()

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
    gemini_api_key: Optional[str] = None

class ProfileUpdate(BaseModel):
    full_name: Optional[str] = None
    gemini_api_key: Optional[str] = None

@router.post("/keys", response_model=UserKeyResponse)
def create_api_key(key_in: UserKeyCreate, current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    new_key = UserKey(
        user_id=current_user.id,
        name=key_in.name,
        platform=key_in.platform,
        encrypted_value=encrypt_value(key_in.secret_value),
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
    decrypted_key = None
    if current_user.gemini_api_key:
        try:
            decrypted_key = decrypt_value(current_user.gemini_api_key.encode('utf-8'))
        except Exception:
            decrypted_key = current_user.gemini_api_key

    return ProfileResponse(
        email=current_user.email,
        full_name=current_user.full_name,
        role=current_user.role,
        is_active=current_user.is_active,
        gemini_api_key=decrypted_key,
    )

@router.patch("", response_model=ProfileResponse)
def update_profile(payload: ProfileUpdate, current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    changed = False
    if payload.full_name is not None and payload.full_name != current_user.full_name:
        current_user.full_name = payload.full_name
        changed = True
    if payload.gemini_api_key is not None:
        encrypted_key = encrypt_value(payload.gemini_api_key).decode('utf-8')
        if encrypted_key != current_user.gemini_api_key:
            current_user.gemini_api_key = encrypted_key
            changed = True
    if changed:
        db.add(current_user)
        db.commit()
        db.refresh(current_user)
    
    decrypted_key = None
    if current_user.gemini_api_key:
        try:
            decrypted_key = decrypt_value(current_user.gemini_api_key.encode('utf-8'))
        except Exception:
            decrypted_key = current_user.gemini_api_key

    return ProfileResponse(
        email=current_user.email,
        full_name=current_user.full_name,
        role=current_user.role,
        is_active=current_user.is_active,
        gemini_api_key=decrypted_key,
    )
