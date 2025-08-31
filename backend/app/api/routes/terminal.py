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
        # Parse simple format: /cli <provider> <command_name or tokens> [k=v ...]
        payload = text[4:].strip()
        parts = [p for p in payload.split() if p]
        if len(parts) < 2:
            raise HTTPException(status_code=400, detail="Usage: /cli <provider> <command_name> [k=v ...]")
        provider, *rest = parts
        # collect k=v args from the tail, remaining tokens form the command key
        kv: list[str] = []
        cmd_tokens: list[str] = []
        for token in rest:
            if '=' in token and len(token.split('=',1)[0])>0:
                kv.append(token)
            else:
                cmd_tokens.append(token)
        command_name = cmd_tokens[0] if cmd_tokens else ''
        # If multiple tokens like "auth list" → "auth_list"
        if len(cmd_tokens) > 1:
            command_name = ('_').join(cmd_tokens)
        args: Dict[str, Any] = {}
        for item in kv:
            if '=' in item:
                k, v = item.split('=', 1)
                args[k] = v
        resp = execute_readonly_cli(provider, command_name, args)
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


