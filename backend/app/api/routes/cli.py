from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel
from typing import Dict, Any, Optional, List
from security import get_api_key
import subprocess

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


# Strict read-only whitelist
READ_ONLY_COMMAND_WHITELIST: Dict[str, Dict[str, List[str]]] = {
    "aws": {
        "s3_ls": ["aws", "s3", "ls"],
        "ec2_describe_instances": ["aws", "ec2", "describe-instances", "--output", "json"],
        "iam_list_users": ["aws", "iam", "list-users", "--output", "json"],
        "sts_get_caller_identity": ["aws", "sts", "get-caller-identity"],
    },
    "gcp": {
        "gcloud_zones_list": ["gcloud", "compute", "zones", "list"],
        "gcloud_projects_list": ["gcloud", "projects", "list"],
        "gcloud_compute_instances_list": ["gcloud", "compute", "instances", "list", "--format", "json"],
        "gcloud_auth_list": ["gcloud", "auth", "list"],
    },
    "azure": {
        "account_show": ["az", "account", "show"],
        "resource_groups_list": ["az", "group", "list"],
        "vm_list": ["az", "vm", "list"],
        "storage_accounts_list": ["az", "storage", "account", "list"],
        "aks_list": ["az", "aks", "list"],
    },
}

# Common aliases for provider and command keys
PROVIDER_ALIASES = {
    "gcloud": "gcp",
    "google": "gcp",
    "googlecloud": "gcp",
    "az": "azure",
    "microsoft": "azure",
}

COMMAND_ALIASES: Dict[str, Dict[str, str]] = {
    "aws": {
        "sts_get-caller-identity": "sts_get_caller_identity",
    },
    "gcp": {
        "auth_list": "gcloud_auth_list",
        "compute_instances_list": "gcloud_compute_instances_list",
        "projects_list": "gcloud_projects_list",
        "zones_list": "gcloud_zones_list",
    },
    "azure": {
        "group_list": "resource_groups_list",
    },
}


def execute_readonly_cli(provider: str, command_name: str, args: Optional[Dict[str, Any]] = None) -> ReadOnlyCliResponse:
    p = (provider or "").lower()
    provider = PROVIDER_ALIASES.get(p, p)
    commands = READ_ONLY_COMMAND_WHITELIST.get(provider)
    if not commands:
        raise HTTPException(status_code=400, detail=f"Unsupported provider: {provider}")

    # Normalize command key: unify with whitelist/aliases
    key = command_name.replace("/", "_").replace("-", "_")
    key = COMMAND_ALIASES.get(provider, {}).get(key, key)

    template = commands.get(key)
    if not template:
        raise HTTPException(status_code=400, detail=f"Command '{command_name}' is not a valid or allowed read-only command.")

    # Simple placeholder injection if template contains {key}
    final: List[str] = []
    a = args or {}
    for token in template:
        if token.startswith("{") and token.endswith("}"):
            key = token[1:-1]
            value = str(a.get(key, ""))
            final.append(value)
        else:
            final.append(token)

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


