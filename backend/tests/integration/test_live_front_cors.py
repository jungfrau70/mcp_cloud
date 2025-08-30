import os
import requests

API_BASE = os.getenv("LIVE_API_BASE", "https://api.gostock.us")
APP_ORIGIN = os.getenv("LIVE_APP_ORIGIN", "https://app.gostock.us")
API_KEY = os.getenv("MCP_API_KEY", "my_mcp_eagle_tiger")


def _preflight(url: str, method: str = "GET") -> requests.Response:
    headers = {
        "Origin": APP_ORIGIN,
        "Access-Control-Request-Method": method,
        "Access-Control-Request-Headers": "X-API-Key, Content-Type",
    }
    return requests.options(url, headers=headers, timeout=15)


def _get(url: str) -> requests.Response:
    headers = {
        "Origin": APP_ORIGIN,
        "X-API-Key": API_KEY,
        "Accept": "application/json",
        # 일부 WAF/프록시가 브라우저 UA가 아닐 때 차단할 수 있어 UA를 브라우저 유사로 설정
        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/118.0.0.0 Safari/537.36",
        "Referer": APP_ORIGIN + "/knowledge-base",
    }
    return requests.get(url, headers=headers, timeout=20)


def test_preflight_kb_item_allows_from_app_origin():
    url = f"{API_BASE}/api/v1/knowledge-base/item?path=index.md"
    r = _preflight(url)
    assert r.status_code == 200
    # Core CORS headers should be present
    assert r.headers.get("access-control-allow-origin") == APP_ORIGIN
    assert "GET" in r.headers.get("access-control-allow-methods", "")
    allows = r.headers.get("access-control-allow-headers", "").lower()
    assert "x-api-key" in allows and "content-type" in allows


def test_kb_item_fetch_succeeds_from_app_origin():
    url = f"{API_BASE}/api/v1/knowledge-base/item?path=index.md"
    r = _get(url)
    assert r.status_code == 200
    data = r.json()
    assert isinstance(data, dict)
    assert "content" in data


def test_tree_endpoints_ready():
    for path in [
        "/api/v1/knowledge-base/tree",
        "/api/v1/slides/selection",
        "/api/v1/slides/tree",
    ]:
        url = f"{API_BASE}{path}"
        pre = _preflight(url)
        assert pre.status_code == 200
        r = _get(url)
        assert r.status_code == 200

