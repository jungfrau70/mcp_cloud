from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel
from typing import Optional, Dict, Any
from security import get_api_key
import uuid
from rag_service import get_rag_service
from .cli import execute_readonly_cli

router = APIRouter(prefix="/api/v1/terminal", tags=["Terminal"], dependencies=[Depends(get_api_key)])


class TerminalAgentRequest(BaseModel):
    user_input: str
    conversation_id: Optional[str] = None


@router.post("/agent")
def terminal_agent(req: TerminalAgentRequest) -> Dict[str, Any]:
    # Debug log to verify request arrival
    try:
        print(f"[terminal.agent] incoming: text='{(req.user_input or '')[:64]}' cid={req.conversation_id}")
    except Exception:
        pass
    cid = req.conversation_id or str(uuid.uuid4())
    text = (req.user_input or "").strip()
    is_cli = text.startswith("/cli") or text.startswith("/c ")

    # Route to RAG service for chat; CLI stays acknowledged (read-only proxy can be wired later)
    if is_cli:
        # Raw passthrough: /cli <provider> <anything...>
        payload = text[4:].strip()
        parts = [p for p in payload.split() if p]
        if len(parts) < 2:
            raise HTTPException(status_code=400, detail="Usage: /cli <provider> <command...>")
        provider, *rest = parts
        command_raw = ' '.join(rest)
        resp = execute_readonly_cli(provider, command_raw, None)
        result = (resp.stdout or '').strip() or (resp.stderr or '').strip() or f"exit={resp.exit_code}"
        mode = "cli"
    else:
        svc = get_rag_service()
        if not svc:
            raise HTTPException(status_code=503, detail="RAG service is not available")
        try:
            result = svc.query(text)
        except Exception as e:
            raise HTTPException(status_code=500, detail=f"RAG query failed: {e}")
        mode = "chat"

    return {"conversation_id": cid, "result": result, "mode": mode}


@router.get("/ping")
def terminal_ping() -> Dict[str, Any]:
    return {"ok": True}


