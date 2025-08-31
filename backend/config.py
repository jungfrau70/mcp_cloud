# backend/config.py
import os
from dotenv import load_dotenv
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

# Load .env if present
_env_path = os.path.join(os.path.dirname(__file__), 'env', '.env')
if os.path.exists(_env_path):
    load_dotenv(dotenv_path=_env_path)

# Core settings
DATABASE_URL = os.getenv("DATABASE_URL", "postgresql://mcpuser:mcppassword@mcp_postgres:5432/mcp_db")
GEMINI_API_KEY = os.getenv("GEMINI_API_KEY")
MCP_API_KEY = os.getenv("MCP_API_KEY")
DISABLE_AUTH = os.getenv("DISABLE_AUTH", "false").lower() == "true"
KB_PUBLIC_READ = os.getenv("KB_PUBLIC_READ", "false").lower() == "true"

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
