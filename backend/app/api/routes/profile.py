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
ENCRYPTION_KEY = os.getenv("CREDENTIAL_ENCRYPTION_KEY")

if not ENCRYPTION_KEY:
    # 환경변수가 없으면 새 키 생성
    from cryptography.fernet import Fernet
    ENCRYPTION_KEY = Fernet.generate_key().decode()
    print(f"⚠️  새로운 암호화 키가 생성되었습니다. 다음 환경변수를 설정하세요:")
    print(f"CREDENTIAL_ENCRYPTION_KEY={ENCRYPTION_KEY}")
else:
    # 기존 키가 있으면 유효성 검사
    try:
        # Fernet 키 유효성 검사
        Fernet(ENCRYPTION_KEY.encode())
    except Exception as e:
        print(f"❌ 잘못된 암호화 키: {e}")
        print("올바른 Fernet 키를 생성합니다...")
        from cryptography.fernet import Fernet
        ENCRYPTION_KEY = Fernet.generate_key().decode()
        print(f"새로운 암호화 키: {ENCRYPTION_KEY}")

def encrypt_value(value: str) -> bytes:
    """문자열을 암호화합니다."""
    f = Fernet(ENCRYPTION_KEY.encode())
    return f.encrypt(value.encode())

def decrypt_value(encrypted_value: bytes) -> str:
    """암호화된 값을 복호화합니다."""
    f = Fernet(ENCRYPTION_KEY.encode())
    return f.decrypt(encrypted_value).decode()

router = APIRouter(prefix="/api/v1/profile", tags=["User Profile"])

class ProfileResponse(BaseModel):
    email: str
    full_name: Optional[str]
    role: str
    is_active: bool
    gemini_api_key: Optional[str]

class ProfileUpdate(BaseModel):
    full_name: Optional[str] = None
    gemini_api_key: Optional[str] = None

@router.get("/keys")
def get_api_keys(current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    """사용자의 API 키 목록을 반환합니다."""
    keys = db.query(UserKey).filter(UserKey.user_id == current_user.id).all()
    return [{"id": key.id, "name": key.name, "created_at": key.created_at} for key in keys]

@router.post("/keys")
def create_api_key(name: str, current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    """새로운 API 키를 생성합니다."""
    # API 키 생성 로직 (실제 구현에서는 더 복잡한 키 생성 로직이 필요)
    import secrets
    api_key = f"mcp_{secrets.token_urlsafe(32)}"
    
    user_key = UserKey(
        user_id=current_user.id,
        name=name,
        key_hash=api_key  # 실제로는 해시값을 저장해야 함
    )
    db.add(user_key)
    db.commit()
    db.refresh(user_key)
    
    return {"id": user_key.id, "name": user_key.name, "key": api_key}

@router.delete("/keys/{key_id}")
def delete_api_key(key_id: int, current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    """API 키를 삭제합니다."""
    key = db.query(UserKey).filter(UserKey.id == key_id, UserKey.user_id == current_user.id).first()
    if not key:
        raise HTTPException(status_code=404, detail="API 키를 찾을 수 없습니다.")
    
    db.delete(key)
    db.commit()
    return {"message": "API 키가 삭제되었습니다."}

@router.get("/me/subscription")
def get_subscription(current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    """사용자의 구독 정보를 반환합니다."""
    if not current_user.subscription:
        return {"plan_id": "free", "status": "active"}
    
    return {
        "plan_id": current_user.subscription.plan_id,
        "status": current_user.subscription.status
    }

@router.get("", response_model=ProfileResponse)
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

# 커리큘럼 선택 저장 API
class CurriculumSelectionRequest(BaseModel):
    selected_dirs: List[str]

class CurriculumSelectionResponse(BaseModel):
    success: bool
    selected_dirs: List[str]
    message: str

@router.post("/curriculum-selection", response_model=CurriculumSelectionResponse)
def save_curriculum_selection(
    request: CurriculumSelectionRequest,
    current_user: User = Depends(get_current_user)
):
    """
    사용자의 커리큘럼 디렉토리 선택을 저장합니다.
    """
    try:
        from pathlib import Path
        import json
        
        # mcp_knowledge_base 경로 설정
        KB_ROOT = Path('../mcp_knowledge_base').resolve()
        if not KB_ROOT.exists():
            KB_ROOT = Path('/app/../mcp_knowledge_base').resolve()
        if not KB_ROOT.exists():
            KB_ROOT = Path('/mcp_knowledge_base').resolve()
        
        SELECTION_FILE = KB_ROOT / 'shared_configs' / '.slides_selection.json'
        
        selected_dirs = request.selected_dirs
        
        # 디렉토리 존재 여부 검증
        valid_dirs = []
        for dir_name in selected_dirs:
            dir_path = KB_ROOT / dir_name
            if dir_path.exists() and dir_path.is_dir():
                valid_dirs.append(dir_name)
        
        # .slides_selection.json 파일에 저장
        SELECTION_FILE.parent.mkdir(parents=True, exist_ok=True)
        with open(SELECTION_FILE, 'w', encoding='utf-8') as f:
            json.dump(valid_dirs, f, ensure_ascii=False, indent=2)
        
        return CurriculumSelectionResponse(
            success=True,
            selected_dirs=valid_dirs,
            message=f"커리큘럼 디렉토리 {len(valid_dirs)}개가 성공적으로 저장되었습니다."
        )
        
    except Exception as e:
        return CurriculumSelectionResponse(
            success=False,
            selected_dirs=[],
            message=f"저장 중 오류가 발생했습니다: {str(e)}"
        )