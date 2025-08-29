import os
import json
import pytest
from fastapi.testclient import TestClient


def get_client():
    import sys
    import pathlib
    root = pathlib.Path(__file__).resolve().parents[1]
    if str(root) not in sys.path:
        sys.path.insert(0, str(root))
    from main import app
    return TestClient(app)


API_KEY = os.environ.get("MCP_API_KEY", "test_mcp_key")
HEADERS = {"X-API-Key": API_KEY}


@pytest.mark.parametrize("provider", ["azure", "gcp", "aws"])
def test_cli_setup_status_smoke(provider):
    client = get_client()
    r = client.get(f"/api/v1/cli/setup/status", params={"provider": provider}, headers=HEADERS)
    assert r.status_code in (200, 400)
    if r.status_code == 200:
        data = r.json()
        assert data.get("provider") == provider


def test_cli_setup_gcp_service_account_when_key_present(monkeypatch, tmp_path):
    client = get_client()
    keyfile = tmp_path / "sa.json"
    keyfile.write_text("{}", encoding="utf-8")
    monkeypatch.setenv("GOOGLE_APPLICATION_CREDENTIALS", str(keyfile))
    r = client.post("/api/v1/cli/setup", headers=HEADERS, json={
        "provider": "gcp",
        "action": "login",
        "args": {"project": "demo"}
    })
    assert r.status_code == 200
    data = r.json()
    assert data.get("provider") == "gcp"
    assert "success" in data


def test_cli_setup_azure_requires_interactive_when_no_sp(monkeypatch):
    client = get_client()
    for k in ["AZURE_CLIENT_ID", "AZURE_TENANT_ID", "AZURE_CLIENT_SECRET"]:
        monkeypatch.delenv(k, raising=False)
    r = client.post("/api/v1/cli/setup", headers=HEADERS, json={
        "provider": "azure",
        "action": "login",
        "args": {}
    })
    assert r.status_code == 200
    data = r.json()
    assert data.get("provider") == "azure"
    assert data.get("requires_interactive") is True


