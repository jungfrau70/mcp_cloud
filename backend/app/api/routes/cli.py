from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel
from typing import Dict, Any, Optional, List
from security import get_api_key
import subprocess
import time
import select

router = APIRouter(prefix="/api/v1/cli", tags=["CLI Commands"], dependencies=[Depends(get_api_key)])


class ReadOnlyCliRequest(BaseModel):
    provider: str
    command_name: str
    args: Optional[Dict[str, Any]] = None


class ReadOnlyCliResponse(BaseModel):
    provider: str
    command_name: str
    exit_code: int
    stdout: str
    stderr: str


# Blacklist-based safety (default allow, block destructive verbs/flags)
DENY_TOKENS = {}
# DENY_TOKENS = { 
#     "create", "update", "delete", "remove", "rm", "put", "apply", "patch", "write",
#     "terminate", "reboot", "stop", "start", "format", "mkfs", "attach", "detach",
#     "insert", "enable", "disable", "set", "add", "grant", "revoke", "deploy",
# }
DENY_FLAG_PREFIXES = {}
# DENY_FLAG_PREFIXES = {"--delete", "--remove", "--force", "--yes", "-y"}

# Common aliases for provider and command keys
PROVIDER_ALIASES = {
    "gcloud": "gcp",
    "google": "gcp",
    "googlecloud": "gcp",
    "az": "azure",
    "microsoft": "azure",
}

COMMAND_ALIASES: Dict[str, Dict[str, str]] = {}


def _provider_binary(provider: str) -> str:
    if provider == "gcp":
        return "gcloud"
    if provider == "azure":
        return "az"
    return "aws"


def _build_args_for_provider(provider: str, args: Dict[str, Any]) -> List[str]:
    out: List[str] = []
    for k, v in (args or {}).items():
        flag = f"--{str(k).replace('_','-')}"
        if v is None or v == "":
            out.append(flag)
        else:
            out.append(f"{flag}={v}")
    return out


def _is_denied(tokens: List[str], args: Dict[str, Any]) -> Optional[str]:
    for t in tokens:
        lt = (t or "").lower()
        if lt in DENY_TOKENS:
            return lt
    for k in (args or {}).keys():
        fk = f"--{str(k).replace('_','-')}".lower()
        if any(fk.startswith(p) for p in DENY_FLAG_PREFIXES):
            return fk
    return None


def execute_readonly_cli(provider: str, command_name: str, args: Optional[Dict[str, Any]] = None) -> ReadOnlyCliResponse:
    p = (provider or "").lower()
    provider = PROVIDER_ALIASES.get(p, p)
    if provider not in {"aws","gcp","azure"}:
        raise HTTPException(status_code=400, detail=f"Unsupported provider: {provider}")

    # Raw tokens: do not transform; split by whitespace
    raw = (command_name or "").strip()
    tokens = [t for t in raw.split() if t]
    if not tokens:
        raise HTTPException(status_code=400, detail="Empty command")

    denied = _is_denied(tokens, args or {})
    if denied:
        raise HTTPException(status_code=403, detail=f"Command blocked by blacklist: {denied}")

    final: List[str] = [_provider_binary(provider)] + tokens + _build_args_for_provider(provider, args or {})

    # Special handling for interactive login commands: return initial prompt promptly
    is_login = (
        (provider == "azure" and tokens[:1] == ["login"]) or
        (provider == "gcp" and tokens[:2] == ["auth", "login"]) or
        (provider == "aws" and tokens[:2] == ["sso", "login"]) or
        (provider == "aws" and tokens[:1] == ["configure"])  # may prompt
    )

    if is_login:
        try:
            proc = subprocess.Popen(
                final,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                text=True,
                bufsize=1
            )
            start = time.time()
            out_buf: List[str] = []
            err_buf: List[str] = []
            # collect a few seconds of initial output (device code prompt etc.)
            while (time.time() - start) < 8.0 and proc.poll() is None:
                rlist, _, _ = select.select(
                    [fd for fd in [proc.stdout, proc.stderr] if fd], [], [], 0.2
                )
                for fd in rlist:
                    try:
                        line = fd.readline()
                        if not line:
                            continue
                        if fd is proc.stdout:
                            out_buf.append(line)
                        else:
                            err_buf.append(line)
                    except Exception:
                        pass
            try:
                proc.terminate()
            except Exception:
                pass
            stdout = ''.join(out_buf).strip()
            stderr = ''.join(err_buf).strip()
            return ReadOnlyCliResponse(
                provider=provider,
                command_name=command_name,
                exit_code=-1,
                stdout=stdout,
                stderr=stderr
            )
        except Exception as e:
            raise HTTPException(status_code=500, detail=f"CLI execution failed: {e}")

    try:
        proc = subprocess.run(final, capture_output=True, text=True, timeout=45)
        return ReadOnlyCliResponse(
            provider=provider,
            command_name=command_name,
            exit_code=proc.returncode,
            stdout=proc.stdout or "",
            stderr=proc.stderr or "",
        )
    except subprocess.TimeoutExpired as e:
        raise HTTPException(status_code=504, detail=f"CLI command timeout: {e}")
    except FileNotFoundError:
        raise HTTPException(status_code=500, detail="CLI binary not found in container")
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"CLI execution failed: {e}")


@router.post("/read-only", response_model=ReadOnlyCliResponse)
def run_readonly_cli(request: ReadOnlyCliRequest):
    return execute_readonly_cli(request.provider, request.command_name, request.args)


