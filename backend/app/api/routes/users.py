# backend/app/api/routes/users.py
from fastapi import APIRouter, Depends, HTTPException, Request
import os
from typing import Literal
from sqlalchemy.orm import Session
from security import get_api_key
from ..deps import get_db, get_current_user
from app.models import User

router = APIRouter(prefix="/api/v1/users", tags=["Users"], dependencies=[Depends(get_api_key)])

Role = Literal["student","tutor","admin"]

@router.get("/me")
def users_me(current_user: User = Depends(get_current_user)):
    return {"email": current_user.email, "role": current_user.role, "full_name": current_user.full_name}


