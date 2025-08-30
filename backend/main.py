# Compatibility wrapper for refactored backend
# Provides legacy imports: app, get_db, get_api_key, Base

from app.main import app  # FastAPI application
from app.api.deps import get_db  # DB session dependency
from security import get_api_key  # API key dependency
from app.db.base import Base  # SQLAlchemy Base
