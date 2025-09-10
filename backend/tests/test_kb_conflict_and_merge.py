import os
import uuid
from fastapi.testclient import TestClient

try:
    from backend.main import app
except ImportError:
    from main import app

API_KEY = {"X-API-Key": os.getenv("MCP_API_KEY", "my_mcp_eagle_tiger")}
client = TestClient(app)

def save_doc(path: str, content: str, message: str, expected_version=None):
    body = {"path": path, "content": content, "message": message}
    if expected_version is not None:
        body["expected_version_no"] = expected_version
    r = client.patch("/api/_deprecated/kb/item", json=body, headers=API_KEY)
    return r

def test_version_conflict():
    path = f"test_directory/conflict_{uuid.uuid4().hex}.md"
    base_content = "Line1\nLine2"
    r1 = save_doc(path, base_content, "base")
    assert r1.status_code == 200
    v1 = r1.json()["version_no"]
    # Simulate two editors: editor A keeps v1, editor B updates to v2
    r2 = save_doc(path, base_content + "\nLine3", "editorB", expected_version=v1)
    assert r2.status_code == 200
    v2 = r2.json()["version_no"]
    # Editor A tries to save based on stale v1 expected_version_no
    r_conflict = save_doc(path, base_content + "\nLineX", "editorA-stale", expected_version=v1)
    assert r_conflict.status_code == 409, r_conflict.text

def test_force_save_without_expected():
    path = f"test_directory/conflict_{uuid.uuid4().hex}.md"
    base_content = "Alpha"
    r1 = save_doc(path, base_content, "base")
    assert r1.status_code == 200
    # Omit expected_version_no -> always allowed
    r2 = save_doc(path, base_content + "\nBeta", "no-optimistic")
    assert r2.status_code == 200
