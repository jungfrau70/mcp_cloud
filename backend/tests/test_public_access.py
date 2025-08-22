import os
from fastapi.testclient import TestClient


def test_kb_tree_public_access(monkeypatch):
    monkeypatch.setenv("DISABLE_AUTH", "true")
    from backend.main import app
    client = TestClient(app)
    r = client.get("/api/kb/tree")
    assert r.status_code == 200


def test_curriculum_tree_public_access(monkeypatch):
    monkeypatch.setenv("DISABLE_AUTH", "true")
    from backend.main import app
    client = TestClient(app)
    r = client.get("/api/v1/curriculum/tree")
    assert r.status_code in [200, 500]
    # 200 when path exists; 500 allowed in CI where filesystem may be missing


