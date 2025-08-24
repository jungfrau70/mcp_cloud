import os
import uuid
from fastapi.testclient import TestClient

# Allow running either from project root (import backend.main) or from inside backend/ (import main)
try:  # project root execution
    from backend.main import app  # type: ignore
except ImportError:  # inside backend directory
    from main import app  # type: ignore

API_KEY = {"X-API-Key": os.getenv("MCP_API_KEY", "my_mcp_eagle_tiger")}

client = TestClient(app)


def test_kb_save_and_list_versions_and_diff(tmp_path):
    # create a temp doc path inside knowledge base root simulation
    path = f"test_directory/test_doc_{uuid.uuid4().hex}.md"
    content_v1 = "# Title\nFirst line"
    content_v2 = "# Title\nFirst line changed\nSecond line"

    # save v1
    r1 = client.patch("/api/_deprecated/kb/item", json={"path": path, "content": content_v1, "message": "initial"}, headers=API_KEY)
    assert r1.status_code == 200, r1.text
    v1_no = r1.json()["version_no"]

    # save v2
    r2 = client.patch("/api/_deprecated/kb/item", json={"path": path, "content": content_v2, "message": "update"}, headers=API_KEY)
    assert r2.status_code == 200, r2.text
    v2_no = r2.json()["version_no"]
    assert v2_no == v1_no + 1

    # list versions
    rv = client.get(f"/api/kb/versions?path={path}", headers=API_KEY)
    assert rv.status_code == 200
    versions = rv.json()["versions"]
    assert len(versions) >= 2
    nums = [v["version_no"] for v in versions]
    assert v2_no in nums and v1_no in nums

    # diff
    rd = client.get(f"/api/kb/diff?path={path}&v1={v1_no}&v2={v2_no}", headers=API_KEY)
    assert rd.status_code == 200
    data = rd.json()
    assert data["diff_format"] == "unified"
    assert data["hunks"], "Expected at least one hunk"
    # ensure changed line appears
    full_lines = [l for h in data["hunks"] for l in h["lines"]]
    assert any("First line changed" in l for l in full_lines)
