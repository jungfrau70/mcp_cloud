# tests/test_main.py
import pytest
import os
import json
import subprocess
import shutil
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

# NOTE: DO NOT import app from backend.main at the top level.
# It needs to be imported *after* environment variables are patched.

@pytest.fixture(scope="function")
def client(monkeypatch, tmp_path):
    """
    A function-scoped fixture that provides a fully isolated test client
    for each test function. It also sets up a temporary knowledge base directory.
    """
    # Create a temporary directory for the knowledge base
    kb_root = tmp_path / "mcp_knowledge_base"
    kb_root.mkdir()
    
    # 1. Set environment variables for the test
    monkeypatch.setenv("DATABASE_URL", f"sqlite:///{tmp_path / 'test.db'}")
    monkeypatch.setenv("GEMINI_API_KEY", "fake_api_key")
    monkeypatch.setenv("MCP_API_KEY", "test_api_key")
    
    # Monkeypatch the KNOWLEDGE_BASE_DIR constant in main
    monkeypatch.setattr("backend.main.KNOWLEDGE_BASE_DIR", str(kb_root))

    # 2. Now, safely import the app
    from backend.main import app, get_db
    from backend.models import Base

    # 3. Create a fresh, in-memory SQLite database for this test
    engine = create_engine(
        f"sqlite:///{tmp_path / 'test.db'}", connect_args={"check_same_thread": False}
    )
    TestingSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
    
    Base.metadata.create_all(bind=engine) # Create tables

    # 4. Override the `get_db` dependency to use the in-memory database
    def override_get_db():
        db = TestingSessionLocal()
        try:
            yield db
        finally:
            db.close()

    app.dependency_overrides[get_db] = override_get_db

    # 5. Yield the test client
    yield TestClient(app)

    # Teardown: clear dependency overrides and drop tables
    app.dependency_overrides.clear()
    Base.metadata.drop_all(bind=engine)
    # The tmp_path fixture handles directory cleanup

def test_read_root(client):
    """
    Tests the root endpoint GET /.
    """
    response = client.get("/")
    assert response.status_code == 200
    assert response.json() == {"message": "MCP Backend is running!"}


def test_create_deployment(client):
    """
    Tests the successful creation of a deployment via POST /deployments/.
    """
    response = client.post(
        "/api/v1/deployments/",
        headers={"X-API-Key": "test_api_key"},
        json={"name": "test-s3", "cloud": "aws", "module": "s3_bucket", "vars": {"bucket_name": "my-test-bucket"}},
    )
    assert response.status_code == 200
    data = response.json()
    assert data["name"] == "test-s3"
    assert data["cloud"] == "aws"
    assert data["status"] == "created"
    assert "id" in data

def test_run_readonly_cli_command_success(client, monkeypatch):
    """
    Tests the successful execution of a whitelisted read-only CLI command.
    """
    # 1. Mock subprocess.run to simulate a successful aws s3 ls
    mock_stdout = "2024-08-13 14:20:00 my-test-bucket-1\n2024-08-13 14:21:00 my-test-bucket-2"
    monkeypatch.setattr(
        "subprocess.run",
        lambda *args, **kwargs: subprocess.CompletedProcess(
            args=args, returncode=0, stdout=mock_stdout, stderr=""
        ),
    )

    # 2. Call the new /cli/read-only endpoint
    response = client.post(
        "/api/v1/cli/read-only",
        headers={"X-API-Key": "test_api_key"},
        json={"provider": "aws", "command_name": "s3_ls", "args": {}},
    )

    # 3. Assert the results
    assert response.status_code == 200
    data = response.json()
    assert data["success"] is True
    assert data["stdout"] == mock_stdout
    assert data["stderr"] == ""


def test_run_readonly_cli_command_blocked(client, monkeypatch):
    """
    Tests that a non-whitelisted or malicious command is blocked.
    """
    # 1. Call the endpoint with a command that is not in the whitelist
    response = client.post(
        "/api/v1/cli/read-only",
        headers={"X-API-Key": "test_api_key"},
        json={"provider": "aws", "command_name": "s3_rb", "args": {"bucket_name": "my-test-bucket"}},
    )

    # 2. Assert that the request is rejected
    assert response.status_code == 400
    data = response.json()
    assert data["detail"] == "Command 's3_rb' is not a valid or allowed read-only command."


def test_run_readonly_cli_command_gcp_success(client, monkeypatch):
    """
    Tests the successful execution of a whitelisted GCP read-only CLI command.
    """
    mock_stdout = "NAME  ZONE        STATUS\nzone1 us-central1-a UP"
    monkeypatch.setattr(
        "subprocess.run",
        lambda *args, **kwargs: subprocess.CompletedProcess(
            args=args, returncode=0, stdout=mock_stdout, stderr=""
        ),
    )

    response = client.post(
        "/api/v1/cli/read-only",
        headers={"X-API-Key": "test_api_key"},
        json={"provider": "gcp", "command_name": "gcloud_zones_list", "args": {}},
    )

    assert response.status_code == 200
    data = response.json()
    assert data["success"] is True
    assert data["stdout"] == mock_stdout


def test_run_readonly_cli_command_failure(client, monkeypatch):
    """
    Tests the handling of a CLI command that fails during execution.
    """
    mock_stderr = "An error occurred: region not specified."
    monkeypatch.setattr(
        "subprocess.run",
        lambda *args, **kwargs: subprocess.CompletedProcess(
            args=args, returncode=1, stdout="", stderr=mock_stderr
        ),
    )

    response = client.post(
        "/api/v1/cli/read-only",
        headers={"X-API-Key": "test_api_key"},
        json={"provider": "aws", "command_name": "ec2_describe_instances", "args": {}},
    )

    assert response.status_code == 200 # The API call itself succeeds
    data = response.json()
    assert data["success"] is False
    assert data["stdout"] == ""
    assert data["stderr"] == mock_stderr

class TestKnowledgeBaseV2:
    def test_get_kb_tree_empty(self, client):
        response = client.get("/api/v1/knowledge/tree", headers={"X-API-Key": "test_api_key"})
        assert response.status_code == 200
        assert response.json() == {}

    def test_file_crud_cycle(self, client):
        # 1. Create File
        create_resp = client.post(
            "/api/v1/knowledge/item",
            headers={"X-API-Key": "test_api_key"},
            json={"path": "test/document.md", "type": "file", "content": "Hello World"}
        )
        assert create_resp.status_code == 200
        assert create_resp.json()["path"] == "test/document.md"

        # 2. Read File
        read_resp = client.get("/api/v1/knowledge/item?path=test/document.md", headers={"X-API-Key": "test_api_key"})
        assert read_resp.status_code == 200
        assert read_resp.json()["content"] == "Hello World"

        # 3. Update File
        update_resp = client.put(
            "/api/v1/knowledge/item",
            headers={"X-API-Key": "test_api_key"},
            json={"path": "test/document.md", "type": "file", "content": "Hello Again"}
        )
        assert update_resp.status_code == 200
        
        read_again_resp = client.get("/api/v1/knowledge/item?path=test/document.md", headers={"X-API-Key": "test_api_key"})
        assert read_again_resp.json()["content"] == "Hello Again"

        # 4. Rename File
        rename_resp = client.patch(
            "/api/v1/knowledge/item",
            headers={"X-API-Key": "test_api_key"},
            json={"path": "test/document.md", "new_path": "test/renamed.md"}
        )
        assert rename_resp.status_code == 200
        
        # Verify old path is gone
        read_old_resp = client.get("/api/v1/knowledge/item?path=test/document.md", headers={"X-API-Key": "test_api_key"})
        assert read_old_resp.status_code == 404

        # Verify new path exists
        read_new_resp = client.get("/api/v1/knowledge/item?path=test/renamed.md", headers={"X-API-Key": "test_api_key"})
        assert read_new_resp.status_code == 200
        assert read_new_resp.json()["content"] == "Hello Again"

        # 5. Delete File
        delete_resp = client.delete("/api/v1/knowledge/item?path=test/renamed.md", headers={"X-API-Key": "test_api_key"})
        assert delete_resp.status_code == 200

        # Verify it's gone
        read_deleted_resp = client.get("/api/v1/knowledge/item?path=test/renamed.md", headers={"X-API-Key": "test_api_key"})
        assert read_deleted_resp.status_code == 404

    def test_directory_crud_cycle(self, client):
        # 1. Create Directory
        create_resp = client.post(
            "/api/v1/knowledge/item",
            headers={"X-API-Key": "test_api_key"},
            json={"path": "test_dir", "type": "directory"}
        )
        assert create_resp.status_code == 200

        # 2. Check Tree
        tree_resp = client.get("/api/v1/knowledge/tree", headers={"X-API-Key": "test_api_key"})
        assert "test_dir" in tree_resp.json()

        # 3. Delete Directory
        delete_resp = client.delete("/api/v1/knowledge/item?path=test_dir", headers={"X-API-Key": "test_api_key"})
        assert delete_resp.status_code == 200

        # 4. Check Tree again
        tree_after_delete_resp = client.get("/api/v1/knowledge/tree", headers={"X-API-Key": "test_api_key"})
        assert "test_dir" not in tree_after_delete_resp.json()
