# backend/routers/profile.py
import os
from fastapi import APIRouter, Depends, HTTPException, Header
from sqlalchemy.orm import Session
from typing import List, Optional
from pydantic import BaseModel
from cryptography.fernet import Fernet

from backend import models
from backend.dependencies import get_db, get_current_user

# --- Encryption Utility ---
# WARNING: In a real application, this key MUST be loaded securely from environment variables or a secret management service.
# For this example, we'll derive it or use a placeholder.
ENCRYPTION_KEY = os.getenv("CREDENTIAL_ENCRYPTION_KEY", "placeholder_must_be_32_byte_secret_key")
if len(ENCRYPTION_KEY.encode()) < 32:
    # Pad the key if it's not long enough for Fernet
    ENCRYPTION_KEY = ENCRYPTION_KEY.ljust(32, '=')

fernet = Fernet(ENCRYPTION_KEY.encode())

def encrypt_value(value: str) -> bytes:
    return fernet.encrypt(value.encode())

def decrypt_value(encrypted_value: bytes) -> str:
    return fernet.decrypt(encrypted_value).decode()

# --- Pydantic Schemas ---
class UserKeyCreate(BaseModel):
    name: str
    platform: str
    secret_value: str # The raw secret, will be encrypted

class UserKeyResponse(BaseModel):
    id: int
    name: str
    platform: str
    fingerprint: Optional[str] = None
    created_at: str

    class Config:
        from_attributes = True

# --- Router Definition ---
router = APIRouter(
    prefix="/api/v1/profile",
    tags=["User Profile"],
    # dependencies=[Depends(get_current_user)] # We'll create a dependency for getting the user
)

# --- Dependency to get current user from DB ---
async def get_current_user(x_forwarded_email: Optional[str] = Header(None), db: Session = Depends(get_db)) -> models.User:
    if not x_forwarded_email:
        raise HTTPException(status_code=401, detail="Not authenticated")
    user = db.query(models.User).filter(models.User.email == x_forwarded_email).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    return user

# --- API Endpoints ---

@router.post("/keys", response_model=UserKeyResponse)
def create_api_key(key_in: UserKeyCreate, current_user: models.User = Depends(get_current_user), db: Session = Depends(get_db)):
    """Create and store a new encrypted API key for the current user."""
    encrypted_secret = encrypt_value(key_in.secret_value)
    
    new_key = models.UserKey(
        user_id=current_user.id,
        name=key_in.name,
        platform=key_in.platform,
        encrypted_value=encrypted_secret,
        # fingerprint can be added here, e.g., hash of a public part of the key
    )
    db.add(new_key)
    db.commit()
    db.refresh(new_key)
    
    return UserKeyResponse.from_orm(new_key)

@router.get("/keys", response_model=List[UserKeyResponse])
def list_api_keys(current_user: models.User = Depends(get_current_user)):
    """List all API keys for the current user."""
    return [UserKeyResponse.from_orm(key) for key in current_user.keys]

@router.delete("/keys/{key_id}", status_code=204)
def delete_api_key(key_id: int, current_user: models.User = Depends(get_current_user), db: Session = Depends(get_db)):
    """Delete an API key by its ID."""
    key_to_delete = db.query(models.UserKey).filter(
        models.UserKey.id == key_id,
        models.UserKey.user_id == current_user.id
    ).first()
    
    if not key_to_delete:
        raise HTTPException(status_code=404, detail="Key not found")
        
    db.delete(key_to_delete)
    db.commit()
    return

# --- Subscription Endpoint ---

class SubscriptionResponse(BaseModel):
    plan_id: Optional[str] = None
    status: Optional[str] = None
    current_period_end: Optional[datetime] = None

    class Config:
        from_attributes = True

@router.get("/me/subscription", response_model=SubscriptionResponse)
def get_my_subscription(current_user: models.User = Depends(get_current_user)):
    """Get the current user's subscription status."""
    if not current_user.subscription:
        return SubscriptionResponse(plan_id='free', status='active')
    return SubscriptionResponse.from_orm(current_user.subscription)
