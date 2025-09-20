from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel
from typing import Optional, Dict, Any
from security import get_api_key
from app.api.deps import get_current_user
from app.models import User
import uuid
from rag_service import get_rag_service, get_rag_service_with_user_key
from .cli import execute_readonly_cli

router = APIRouter(prefix="/api/v1/terminal", tags=["Terminal"], dependencies=[Depends(get_api_key)])


class TerminalAgentRequest(BaseModel):
    user_input: str
    conversation_id: Optional[str] = None


@router.post("/agent")
def terminal_agent(req: TerminalAgentRequest, current_user: User = Depends(get_current_user)) -> Dict[str, Any]:
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
        # 사용자별 API 키를 사용하여 RAG 서비스 가져오기
        svc = get_rag_service_with_user_key(current_user.gemini_api_key)
        if not svc:
            raise HTTPException(status_code=503, detail="RAG service is not available")
        try:
            result = svc.query(text)
        except ValueError as e:
            # API 키 관련 오류인 경우 사용자에게 안내
            if "API 키가 설정되지 않았습니다" in str(e):
                raise HTTPException(status_code=400, detail="Gemini API 키가 설정되지 않았습니다. 프로필에서 API 키를 설정해주세요.")
            else:
                raise HTTPException(status_code=500, detail=f"RAG query failed: {e}")
        except Exception as e:
            raise HTTPException(status_code=500, detail=f"RAG query failed: {e}")
        mode = "chat"

    return {"conversation_id": cid, "result": result, "mode": mode}


@router.get("/ping")
def terminal_ping() -> Dict[str, Any]:
    return {"ok": True}


