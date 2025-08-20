# tests/test_main.py
import pytest
import os
import json
import subprocess
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

# NOTE: DO NOT import app from backend.main at the top level.
# It needs to be imported *after* environment variables are patched.

@pytest.fixture(scope="function")
def client(monkeypatch):
    """
    A function-scoped fixture that provides a fully isolated test client
    for each test function.
    """
    # 1. Set environment variables for the test
    monkeypatch.setenv("DATABASE_URL", "sqlite:///./test.db")
    monkeypatch.setenv("GEMINI_API_KEY", "fake_api_key")
    monkeypatch.setenv("MCP_API_KEY", "test_api_key") # Add a test API key

    # 2. Now, safely import the app
    from backend.main import app, get_db
    from backend.models import Base

    # 3. Create a fresh, in-memory SQLite database for this test
    engine = create_engine(
        "sqlite:///./test.db", connect_args={"check_same_thread": False}
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