# backend/app/schemas/kb.py
from pydantic import BaseModel
from typing import Optional, Literal

class KBItemCreate(BaseModel):
    path: str
    type: Literal["file", "directory"] = "file"
    content: Optional[str] = ""

class KBItemMove(BaseModel):
    path: str
    new_path: str
