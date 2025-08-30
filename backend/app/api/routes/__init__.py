# backend/app/api/routes/__init__.py
from .kb import router as kb_router, legacy_router as kb_legacy_router, kb_ws_router
from .profile import router as profile_router
from .slides import router as slides_router, legacy_router as curriculum_legacy_router
from .users import router as users_router
from .trending import router as trending_router
from .datasources import router as datasources_router
from .knowledge import router as knowledge_router
from .deployments import router as deployments_router
__all__ = ['kb_router', 'kb_legacy_router', 'kb_ws_router', 'profile_router', 'slides_router', 'curriculum_legacy_router', 'users_router', 'trending_router', 'datasources_router', 'deployments_router', 'knowledge_router']
