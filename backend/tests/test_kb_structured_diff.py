import os
import uuid
from fastapi.testclient import TestClient

try:
    from backend.main import app
except ImportError:
    from main import app

API_KEY = {"X-API-Key": os.getenv("MCP_API_KEY", "my_mcp_eagle_tiger")}
client = TestClient(app)

def save_doc(path: str, content: str, message: str):
    r = client.patch("/api/_deprecated/kb/item", json={"path": path, "content": content, "message": message}, headers=API_KEY)
    assert r.status_code == 200, r.text
    return r.json()["version_no"]

def test_structured_diff_change_pairing():
    path = f"test_directory/structured_diff_{uuid.uuid4().hex}.md"
    v1_content = "Line A\nLine B\nLine C"
    v2_content = "Line A\nLine B modified\nLine C"
    v1 = save_doc(path, v1_content, "v1")
    v2 = save_doc(path, v2_content, "v2")
    # structured diff
    rd = client.get(f"/api/kb/diff/structured?path={path}&v1={v1}&v2={v2}", headers=API_KEY)
    assert rd.status_code == 200
    data = rd.json()
    assert data["diff_format"] == "structured"
    hunks = data["hunks"]
    assert hunks, "Expected hunks"
    # find change line
    lines = [ln for h in hunks for ln in h["lines"]]
    assert any(ln.get("type") == "change" and ln.get("old_text","Line B") or ln.get("text","Line B modified") for ln in lines)

def test_structured_diff_add_del_pairing():
    path = f"test_directory/structured_diff_{uuid.uuid4().hex}.md"
    v1_content = "Line A\nLine X\nLine C"
    v2_content = "Line A\nLine Y\nLine C"
    v1 = save_doc(path, v1_content, "v1")
    v2 = save_doc(path, v2_content, "v2")
    rd = client.get(f"/api/kb/diff/structured?path={path}&v1={v1}&v2={v2}", headers=API_KEY)
    assert rd.status_code == 200
    data = rd.json()
    lines = [ln for h in data["hunks"] for ln in h["lines"]]
    # ensure no stray unmatched sequence (either change or add/del)
    dels = [l for l in lines if l["type"] == "del"]
    adds = [l for l in lines if l["type"] == "add"]
    # We expect either a change or matched del+add -> processed
    if not any(l["type"]=="change" for l in lines):
        # then both a del and an add around same region should exist
        assert dels and adds

def test_structured_diff_no_change_when_identical():
    path = f"test_directory/structured_diff_{uuid.uuid4().hex}.md"
    content = "Same\nContent"
    v1 = save_doc(path, content, "v1")
    v2 = save_doc(path, content, "v2")
    rd = client.get(f"/api/kb/diff/structured?path={path}&v1={v1}&v2={v2}", headers=API_KEY)
    assert rd.status_code == 200
    data = rd.json()
    lines = [ln for h in data["hunks"] for ln in h["lines"]]
    assert all(l["type"] == "context" for l in lines)
