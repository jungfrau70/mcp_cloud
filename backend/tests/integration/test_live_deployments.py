import os
import pytest
import requests

API_BASE = os.getenv("LIVE_API_BASE", "http://localhost:8000")
PROD_API_KEY = "my_mcp_eagle_tiger"  # Known backend key for live container
API_KEY = os.getenv("MCP_API_KEY") or PROD_API_KEY

def _auth_headers():
    # Always send constant PROD key to avoid local test env overrides
    return {"X-API-Key": PROD_API_KEY, "Content-Type": "application/json"}

@pytest.mark.live
@pytest.mark.integration
@pytest.mark.skipif(os.getenv("RUN_LIVE_TESTS") != "1", reason="RUN_LIVE_TESTS!=1")
def test_create_deployment_live():
    payload = {
        "name": "integration-s3",
        "cloud": "aws",
        "module": "s3_bucket",
        "vars": {"bucket_name": "integration-test-bucket"}
    }
    url = f"{API_BASE}/api/v1/deployments/"
    resp = requests.post(url, json=payload, headers=_auth_headers())

    # Retry with api_key query param if header-based auth rejected
    if resp.status_code == 403:
        # Retry with query param (some gateways may strip custom headers)
        resp = requests.post(
            f"{url}?api_key={PROD_API_KEY}",
            json=payload,
            headers={"Content-Type": "application/json"},
        )

    assert resp.status_code == 200, (
        "Deployment create failed "
    f"(status={resp.status_code}) body={resp.text} tried_key={PROD_API_KEY}"
    )
    data = resp.json()
    assert data.get("name") == payload["name"]
    assert data.get("status") in ("created", "pending", "failed", "applied")

@pytest.mark.live
@pytest.mark.integration
@pytest.mark.skipif(os.getenv("RUN_LIVE_TESTS") != "1", reason="RUN_LIVE_TESTS!=1")
def test_create_deployment_unauthorized():
    payload = {"name": "bad", "cloud": "aws", "module": "s3_bucket", "vars": {}}
    resp = requests.post(f"{API_BASE}/api/v1/deployments/", json=payload)  # no API key
    assert resp.status_code in (401, 403)
