# Compatibility wrapper for refactored backend
# Provides legacy imports: app, get_db, get_api_key, Base

import os
import sys
import importlib
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from security import get_api_key  # API key dependency

# Re-export service singletons and constants expected by tests
try:
    from rag_service import rag_service_instance  # type: ignore
except Exception:
    rag_service_instance = None  # type: ignore

try:
    from external_search_service import external_search_service_instance  # type: ignore
except Exception:
    external_search_service_instance = None  # type: ignore

try:
    from content_extractor import content_extractor_instance  # type: ignore
except Exception:
    content_extractor_instance = None  # type: ignore

# Legacy constants for slide tests
# Load refactored FastAPI app without importing as 'app.main' to avoid circular/name clashes
# ensure project root is on sys.path
PROJECT_ROOT = os.path.dirname(__file__)
if PROJECT_ROOT not in sys.path:
    sys.path.insert(0, PROJECT_ROOT)

# Build a FastAPI app here to avoid circulars
from app.api.routes import (
    kb_router,
    kb_ws_router,
    profile_router,
    curriculum_router,
    users_router,
    trending_router,
    datasources_router,
    deployments_router,
    knowledge_router,
)

app = FastAPI(title="MCP Cloud API (compat)", version="1.0.0")
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/health")
def _health():
    return {"ok": True}

app.include_router(kb_router)
app.include_router(kb_ws_router)
app.include_router(curriculum_router)
app.include_router(profile_router)
app.include_router(users_router)
app.include_router(trending_router)
app.include_router(datasources_router)
app.include_router(deployments_router)
app.include_router(knowledge_router)

SLIDES_DIR = "/mcp_knowledge_base"

# Placeholders expected by some tests to allow monkeypatching
class AsyncIOScheduler:  # noqa: D401 - minimal stub for tests
    pass

async def _generate_trending_docs():  # noqa: D401 - minimal stub for tests
    return None


# Lazy proxies for legacy imports
def get_db(*args, **kwargs):  # type: ignore[no-redef]
    from app.api.deps import get_db as _get_db
    return _get_db(*args, **kwargs)


class _BaseProxy:
    @property
    def metadata(self):  # type: ignore[override]
        from app.db.base import Base as _Base
        return _Base.metadata


Base = _BaseProxy()  # type: ignore[assignment]
