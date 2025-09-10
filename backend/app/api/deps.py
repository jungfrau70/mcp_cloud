# backend/app/api/deps.py
from typing import Optional
from fastapi import Depends, Header, HTTPException, Request
from sqlalchemy.orm import Session
from config import SessionLocal
from app.models import User
import os
import jwt

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

def get_user_from_bearer(request: Request, db: Session) -> User | None:
    """JWT 토큰에서 사용자 정보를 추출합니다."""
    auth = request.headers.get("Authorization", "")
    if not auth.lower().startswith("bearer "):
        return None
    
    token = auth.split(" ", 1)[1].strip()
    try:
        JWT_SECRET = os.getenv("JWT_SECRET", "dev_secret_change_me")
        JWT_ALGORITHM = os.getenv("JWT_ALGORITHM", "HS256")
        payload = jwt.decode(token, JWT_SECRET, algorithms=[JWT_ALGORITHM])
        email = payload.get("sub")
        if not email:
            return None
        return db.query(User).filter(User.email == email).first()
    except Exception:
        return None

async def get_current_user(request: Request, db: Session = Depends(get_db)) -> User:
    """JWT 토큰을 우선으로 사용하고, 프록시 헤더는 fallback으로만 사용합니다."""
    # 1. JWT 토큰 우선 처리
    bearer_user = get_user_from_bearer(request, db)
    if bearer_user is not None:
        return bearer_user
    
    raise HTTPException(status_code=401, detail="Not authenticated")
