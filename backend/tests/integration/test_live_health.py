import os
import time
import os
import pytest
import requests

API_BASE = os.getenv("LIVE_API_BASE", "http://localhost:8000")
API_KEY = os.getenv("MCP_API_KEY", "my_mcp_eagle_tiger")
HEADERS = {"X-API-Key": API_KEY}

@pytest.mark.live
@pytest.mark.integration
@pytest.mark.skipif(os.getenv("RUN_LIVE_TESTS") != "1", reason="RUN_LIVE_TESTS!=1")
def test_health_endpoint_live():
    url = f"{API_BASE}/health"
    resp = requests.get(url)
    assert resp.status_code == 200, resp.text
    data = resp.json()
    assert data.get("status") == "healthy"
    assert "timestamp" in data

@pytest.mark.live
@pytest.mark.integration
@pytest.mark.skipif(os.getenv("RUN_LIVE_TESTS") != "1", reason="RUN_LIVE_TESTS!=1")
def test_root_endpoint_live():
    resp = requests.get(f"{API_BASE}/")
    assert resp.status_code == 200
    assert resp.json().get("message") == "MCP Backend is running!"
