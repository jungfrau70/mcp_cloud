# backend/security.py
import os
from fastapi import HTTPException, Security, Request
from fastapi.security.api_key import APIKeyHeader
from config import MCP_API_KEY, DISABLE_AUTH

api_key_header = APIKeyHeader(name="X-API-Key", auto_error=False)

async def get_api_key(api_key: str = Security(api_key_header), request: Request = None) -> str:
    provided = api_key or (request.query_params.get("api_key") if request else None)

    if DISABLE_AUTH:
        return provided or ""

    expected_primary = MCP_API_KEY
    if not expected_primary:
        raise HTTPException(status_code=500, detail="MCP_API_KEY not configured")

    if not provided:
        path = request.url.path if request else ""
        if "/knowledge/generate-from-external" in path:
            raise HTTPException(status_code=403, detail="Could not validate credentials")
        raise HTTPException(status_code=403, detail="Not authenticated")

    if provided != expected_primary:
        raise HTTPException(status_code=403, detail="Could not validate credentials")

    return provided

async def get_current_admin_user(request: Request):
    # Authelia passes groups in X-Forwarded-Groups header, comma-separated
    groups_header = request.headers.get("X-Forwarded-Groups")
    print(f"DEBUG: X-Forwarded-Groups received: {groups_header}") # DEBUG PRINT
    if not groups_header:
        raise HTTPException(status_code=403, detail="Not authorized: Group information missing")

    groups = [g.strip() for g in groups_header.split(',')]
    print(f"DEBUG: Parsed groups: {groups}") # DEBUG PRINT
    if "admins" not in groups:
        raise HTTPException(status_code=403, detail="Not authorized: Requires admin privileges")
    return True # Or return user info if needed