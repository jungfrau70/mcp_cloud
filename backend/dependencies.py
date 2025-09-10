# backend/dependencies.py
import os
from fastapi import Depends, HTTPException, Header, Security, Request
from sqlalchemy import create_engine, text
from sqlalchemy.orm import sessionmaker, Session
from typing import Optional, List, Literal, Tuple
from datetime import datetime

from backend import models # Absolute import for models

# 데이터베이스 URL 환경변수 가져오기 (Docker 환경 우선)
DATABASE_URL = os.getenv("DATABASE_URL", "postgresql://mcpuser:mcppassword@mcp_postgres:5432/mcp_db")

# API Key for authentication
MCP_API_KEY = os.getenv("MCP_API_KEY")
if not MCP_API_KEY and os.getenv("DISABLE_AUTH", "false").lower() != "true":
    raise RuntimeError("MCP_API_KEY is not set. Please configure it in backend/env/.env or environment variables.")

# SQLAlchemy 엔진 생성 (SQLite 호환성 및 테스트 안정성 개선)
try:
    if DATABASE_URL.startswith("sqlite"):
        engine = create_engine(
            DATABASE_URL,
            echo=False,
            connect_args={"check_same_thread": False}
        )
    else:
        engine = create_engine(
            DATABASE_URL,
            echo=False,
            pool_pre_ping=True,
            pool_recycle=300,
            connect_args={
                "connect_timeout": 10,
                "application_name": "mcp_cloud_backend"
            }
        )

    SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

    # 연결 테스트 (PostgreSQL에서만 엄격하게 수행; SQLite는 간단 검증)
    with engine.connect() as conn:
        conn.execute(text("SELECT 1"))
        print("✅ Database connection successful")

except Exception as e:
    print(f"❌ Database connection failed: {e}")
    # 마지막 폴백: 로컬 SQLite
    fallback_path = "sqlite:///./data/mcp_knowledge.db"
    print(f"🔄 Falling back to SQLite: {fallback_path}")
    data_dir = "./data"
    if not os.path.exists(data_dir):
        os.makedirs(data_dir, exist_ok=True)
    engine = create_engine(
        fallback_path,
        echo=False,
        connect_args={"check_same_thread": False}
    )
    SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

# 데이터베이스 테이블 생성 (에러 처리 추가)
try:
    models.Base.metadata.create_all(bind=engine)
    print("Database tables created successfully!")
except Exception as e:
    print(f"Failed to create database tables: {e}")

# API Key Header for security
api_key_header = Header(name="X-API-Key", auto_error=False)

# Role Literal for type hinting
Role = Literal["student","tutor","admin"]

# --- Dependency functions ---

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

async def get_api_key(api_key: str = Security(api_key_header), request: Request = None):
    provided = api_key
    if not provided and request is not None:
        provided = request.query_params.get("api_key")

    if os.getenv("DISABLE_AUTH", "false").lower() == "true":
        return provided or ""

    expected_primary = os.getenv("MCP_API_KEY")
    allowed = {expected_primary} if expected_primary else set()

    if not provided:
        path = request.url.path if request else ""
        if "/knowledge/generate-from-external" in path:
            raise HTTPException(status_code=403, detail="Could not validate credentials")
        raise HTTPException(status_code=403, detail="Not authenticated")
    if provided not in allowed:
        raise HTTPException(status_code=403, detail="Could not validate credentials")
    return provided

def _extract_role_from_headers(request: Request) -> Tuple[str|None, Role]:
    email = request.headers.get("X-Forwarded-Email") or request.headers.get("X-Forwarded-User")
    groups = (request.headers.get("X-Forwarded-Groups") or "").lower()
    role: Role = "student"
    if "admins" in groups:
        role = "admin"
    elif "tutors" in groups:
        role = "tutor"
    return email, role

async def get_current_user(x_forwarded_email: Optional[str] = Header(None, alias="X-Forwarded-Email"), db: Session = Depends(get_db)) -> models.User:
    if not x_forwarded_email:
        raise HTTPException(status_code=401, detail="Not authenticated")
    user = db.query(models.User).filter(models.User.email == x_forwarded_email).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found in database")
    return user
