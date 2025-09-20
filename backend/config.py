# backend/config.py
import os
from dotenv import load_dotenv
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

# Load .env if present
_env_path = os.path.join(os.path.dirname(__file__), 'env', '.env')
if os.path.exists(_env_path):
    load_dotenv(dotenv_path=_env_path)

# 환경 설정
ENV = os.getenv("ENV", "development")
DEBUG = os.getenv("DEBUG", "true" if ENV == "development" else "false").lower() == "true"

# Core settings
if ENV == "production":
    # 운영 환경 설정
    DATABASE_URL = os.getenv("DATABASE_URL", "postgresql://mcpuser:mcppassword@mcp_postgres:5432/mcp_db")
    HOST = os.getenv("HOST", "0.0.0.0")
    PORT = int(os.getenv("PORT", "8000"))
    LOG_LEVEL = os.getenv("LOG_LEVEL", "INFO")
else:
    # 개발 환경 설정
    DATABASE_URL = os.getenv("DATABASE_URL", "sqlite:///./data/mcp_knowledge.db")
    HOST = os.getenv("HOST", "127.0.0.1")
    PORT = int(os.getenv("PORT", "8000"))
    LOG_LEVEL = os.getenv("LOG_LEVEL", "DEBUG")

# API Keys
GEMINI_API_KEY = os.getenv("GEMINI_API_KEY")
MCP_API_KEY = os.getenv("MCP_API_KEY")

# Security settings
DISABLE_AUTH = os.getenv("DISABLE_AUTH", "true" if ENV == "production" else "false").lower() == "true"
KB_PUBLIC_READ = os.getenv("KB_PUBLIC_READ", "true" if ENV == "production" else "false").lower() == "true"

# CORS settings
if ENV == "production":
    ALLOWED_ORIGINS = [
        "https://goldencircle.us",
        "https://www.goldencircle.us",
        "https://app.goldencircle.us",  # 프론트엔드 앱 도메인
        "https://api.goldencircle.us",
        "http://localhost:3000",  # 개발 환경 호환성
        "http://127.0.0.1:3000"   # 로컬 개발 환경
    ]
else:
    ALLOWED_ORIGINS = ["*"]  # 개발 환경에서는 모든 origin 허용

# Create SQLAlchemy engine/session
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
