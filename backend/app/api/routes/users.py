# backend/app/api/routes/users.py
from fastapi import APIRouter, Depends, HTTPException, Request
from typing import Literal
from sqlalchemy.orm import Session
from security import get_api_key
from ..deps import get_db
from app.models import User

router = APIRouter(prefix="/api/v1/users", tags=["Users"], dependencies=[Depends(get_api_key)])

Role = Literal["student","tutor","admin"]

def _extract_role_from_headers(request: Request) -> tuple[str|None, Role]:
    email = request.headers.get("X-Forwarded-Email") or request.headers.get("X-Forwarded-User")
    groups = (request.headers.get("X-Forwarded-Groups") or "").lower()
    role: Role = "student"
    if "admins" in groups:
        role = "admin"
    elif "tutors" in groups:
        role = "tutor"
    return email, role

@router.get("/me")
def users_me(request: Request, db: Session = Depends(get_db)):
    email, role = _extract_role_from_headers(request)
    if not email:
        raise HTTPException(status_code=401, detail="Unauthenticated")

    user = db.query(User).filter(User.email == email).first()
    if not user:
        user = User(email=email, role=role)
        db.add(user)
        db.commit()
        db.refresh(user)
    else:
        if user.role != role:
            user.role = role
            db.add(user)
            db.commit()

    return {"email": email, "role": role}


