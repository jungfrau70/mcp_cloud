import os
import re
import requests

APP_BASE = os.getenv("LIVE_APP_BASE", "https://app.gostock.us").rstrip("/")


def _get(url: str, headers: dict | None = None) -> requests.Response:
    h = {
        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/118 Safari/537.36",
        "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,*/ *;q=0.8".replace(" ", ""),
    }
    if headers:
        h.update(headers)
    return requests.get(url, headers=h, timeout=20)


def _head_or_get(url: str) -> requests.Response:
    h = {
        "User-Agent": "Mozilla/5.0",
        "Accept": "*/*",
    }
    r = requests.head(url, headers=h, timeout=20, allow_redirects=True)
    if r.status_code in (405, 501) or (r.status_code >= 400 and r.status_code < 500):
        # 일부 원본은 HEAD 미지원 → GET으로 대체
        r = requests.get(url, headers=h, timeout=20, stream=True)
    return r


def _extract_assets(html: str) -> list[str]:
    urls: list[str] = []
    # src/href에서 Nuxt 정적 및 css 경로 수집
    for m in re.finditer(r"(?:src|href)\s*=\s*\"(.*?)\"", html):
        u = m.group(1)
        if not u:
            continue
        if u.startswith("//"):
            u = "https:" + u
        if u.startswith("/"):
            u = APP_BASE + u
        if "/_nuxt/" in u or "/assets/" in u or u.endswith(".css") or u.endswith(".js"):
            urls.append(u)
    # 중복 제거, 상위 몇 개만 검사
    out: list[str] = []
    for u in urls:
        if u not in out:
            out.append(u)
        if len(out) >= 10:
            break
    return out


def test_front_page_loads_and_static_assets_resolve():
    # 1) 메인 페이지 로드
    page = _get(APP_BASE + "/knowledge-base")
    assert page.status_code == 200

    # 2) 정적 리소스 추출
    assets = _extract_assets(page.text)
    assert assets, "No assets discovered from front page"

    # 3) 각 리소스의 상태/콘텐츠 타입 확인
    for url in assets:
        r = _head_or_get(url)
        assert r.status_code == 200, f"{url} -> {r.status_code}"
        ctype = (r.headers.get("Content-Type") or "").lower()
        if url.endswith(".js") or "/_nuxt/" in url and (".js" in url):
            assert "javascript" in ctype or "ecmascript" in ctype,
            f"Unexpected JS content-type for {url}: {ctype}"
        if url.endswith(".css") or "/assets/" in url and (".css" in url):
            assert "text/css" in ctype, f"Unexpected CSS content-type for {url}: {ctype}"


def test_payload_json_and_service_worker_optional():
    # 존재하면 올바른 타입으로 응답하는지 확인(없어도 테스트는 통과)
    for path, expect in [
        ("/_payload.json", "application/json"),
        ("/sw.js", "javascript"),
    ]:
        url = APP_BASE + path
        r = requests.get(url, timeout=10)
        if r.status_code == 200:
            ctype = (r.headers.get("Content-Type") or "").lower()
            assert expect in ctype

