# backend/app/main.py
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from .api.routes import (
  kb_router,
  profile_router,
  slides_router,
  users_router,
  trending_router,
  datasources_router,
  deployments_router,
)
from .db.base import Base
from .models import *  # noqa: F401,F403 ensure models are imported for metadata
from config import engine

app = FastAPI(title="MCP Cloud API", version="1.0.0", docs_url="/docs", redoc_url="/redoc")

# CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Health
@app.get("/health")
def health():
    return {"ok": True}

# Routers
app.include_router(kb_router)
app.include_router(profile_router)
app.include_router(slides_router)
app.include_router(users_router)
app.include_router(trending_router)
app.include_router(datasources_router)
app.include_router(deployments_router)

# Create tables on startup (idempotent)
try:
    Base.metadata.create_all(bind=engine)
except Exception:
    pass
