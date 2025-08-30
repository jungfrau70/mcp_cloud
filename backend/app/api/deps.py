# backend/app/api/deps.py
from typing import Optional
from fastapi import Depends, Header, HTTPException
from sqlalchemy.orm import Session
from config import SessionLocal
from app.models import User

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

async def get_current_user(x_forwarded_email: Optional[str] = Header(None), db: Session = Depends(get_db)) -> User:
    if not x_forwarded_email:
        raise HTTPException(status_code=401, detail="Not authenticated")
    user = db.query(User).filter(User.email == x_forwarded_email).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    return user
