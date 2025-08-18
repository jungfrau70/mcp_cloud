import pytest
import os
import json
import subprocess
from fastapi.testclient import TestClient
from fastapi import HTTPException
from fastapi.security.api_key import APIKeyHeader
from fastapi import Depends, Security

# For credential tests
import boto3
from botocore.stub import Stubber
import google.auth
from google.auth.credentials import Credentials as GoogleCredentials
from google.auth.transport.requests import Request as GoogleRequest

# NOTE: Import app and get_api_key after patching environment variables

@pytest.fixture(scope="function")
def auth_client(monkeypatch):
    """
    A function-scoped fixture that provides a test client for authentication tests.
    It sets necessary environment variables.
    """
    # Set environment variables for the test
    monkeypatch.setenv("DATABASE_URL", "sqlite:///./test_auth.db")
    monkeypatch.setenv("GEMINI_API_KEY", "fake_gemini_key")
    monkeypatch.setenv("MCP_API_KEY", "my_test_api_key")

    # Safely import the app and get_api_key after patching environment variables
    from backend.main import app, get_db, get_api_key
    from backend.models import Base
    from sqlalchemy import create_engine
    from sqlalchemy.orm import sessionmaker
    
    # Create a fresh, in-memory SQLite database for this test
    engine = create_engine(
        "sqlite:///./test_auth.db", connect_args={"check_same_thread": False}
    )
    TestingSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
    
    Base.metadata.create_all(bind=engine) # Create tables

    # Override the `get_db` dependency to use the in-memory database
    def override_get_db():
        db = TestingSessionLocal()
        try:
            yield db
        finally:
            db.close()

    app.dependency_overrides[get_db] = override_get_db

    # Yield the test client
    yield TestClient(app)

    # Teardown: clear dependency overrides and drop tables
    app.dependency_overrides.clear()
    Base.metadata.drop_all(bind=engine)


# Test query_data_source with authentication
def test_query_data_source_auth_success(auth_client, monkeypatch):
    # Mock subprocess.run for successful Terraform execution
    mock_output = {
        "outputs": {
            "result": {
                "value": {"id": "test-id", "name": "test-name"},
                "sensitive": True
            }
        }
    }
    def mock_run(*args, **kwargs):
        if "init" in args[0]:
            return subprocess.CompletedProcess(args=args[0], returncode=0, stdout='init', stderr='')
        elif "apply" in args[0]:
            return subprocess.CompletedProcess(args=args[0], returncode=0, stdout=json.dumps(mock_output), stderr='')
        raise subprocess.CalledProcessError(1, args[0], stderr="Unknown command")
    monkeypatch.setattr("subprocess.run", mock_run)

    response = auth_client.post(
        "/data-sources/query",
        headers={"X-API-Key": "my_test_api_key"},
        json={
            "provider": "aws",
            "data_type": "aws_ami",
            "data_name": "test_ami",
            "config": {"most_recent": True}
        }
    )
    assert response.status_code == 200
    assert response.json()["success"] is True
    assert response.json()["output"]["id"] == "test-id"

def test_query_data_source_auth_failure_incorrect_key(auth_client):
    response = auth_client.post(
        "/data-sources/query",
        headers={"X-API-Key": "wrong_key"},
        json={
            "provider": "aws",
            "data_type": "aws_ami",
            "data_name": "test_ami",
            "config": {"most_recent": True}
        }
    )
    assert response.status_code == 403
    assert response.json()["detail"] == "Could not validate credentials"

def test_query_data_source_auth_failure_missing_key(auth_client):
    response = auth_client.post(
        "/data-sources/query",
        json={
            "provider": "aws",
            "data_type": "aws_ami",
            "data_name": "test_ami",
            "config": {"most_recent": True}
        }
    )
    assert response.status_code == 403
    assert response.json()["detail"] == "Not authenticated"

# Test query_data_source with mocked Terraform errors for credentials
def test_query_data_source_aws_credentials_error(auth_client, monkeypatch):
    error_message = "Error: No valid AWS credentials found."
    def mock_run_error(*args, **kwargs):
        raise subprocess.CalledProcessError(1, args[0], stderr=error_message)
    monkeypatch.setattr("subprocess.run", mock_run_error)

    response = auth_client.post(
        "/data-sources/query",
        headers={"X-API-Key": "my_test_api_key"},
        json={
            "provider": "aws",
            "data_type": "aws_ami",
            "data_name": "test_ami",
            "config": {"most_recent": True}
        }
    )
    assert response.status_code == 200 # Endpoint itself returns 200 even on Terraform error
    assert response.json()["success"] is False
    assert error_message in response.json()["error"]

def test_query_data_source_gcp_permission_denied_error(auth_client, monkeypatch):
    error_message = "Error: Permission denied for project."
    def mock_run_error(*args, **kwargs):
        raise subprocess.CalledProcessError(1, args[0], stderr=error_message)
    monkeypatch.setattr("subprocess.run", mock_run_error)

    response = auth_client.post(
        "/data-sources/query",
        headers={"X-API-Key": "my_test_api_key"},
        json={
            "provider": "google",
            "data_type": "google_compute_zones",
            "data_name": "test_zones",
            "config": {"project": "test-project"}
        }
    )
    assert response.status_code == 200
    assert response.json()["success"] is False
    assert error_message in response.json()["error"]

# New tests for direct credential loading
def test_aws_credentials_load_success(monkeypatch):
    # Mock boto3.client to simulate successful credential loading
    mock_sts_client = boto3.client("sts")
    with Stubber(mock_sts_client) as stubber:
        stubber.add_response("get_caller_identity", {"Account": "123456789012"})
        monkeypatch.setattr(boto3, "client", lambda service_name: mock_sts_client)
        
        # Set dummy AWS credentials
        monkeypatch.setenv("AWS_ACCESS_KEY_ID", "AKIAIOSFODNN7EXAMPLE")
        monkeypatch.setenv("AWS_SECRET_ACCESS_KEY", "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY")
        monkeypatch.setenv("AWS_DEFAULT_REGION", "us-east-1")

        # Attempt to get caller identity
        try:
            sts_client = boto3.client("sts")
            response = sts_client.get_caller_identity()
            assert response["Account"] == "123456789012"
        except Exception as e:
            pytest.fail(f"AWS credentials loading failed: {e}")

def test_gcp_credentials_load_success(monkeypatch):
    # Mock google.auth.default to simulate successful credential loading
    class MockGoogleCredentials:
        def __init__(self, token, refresh_token):
            self.token = token
            self.refresh_token = refresh_token
        def refresh(self, request): # Abstract method that needs implementation
            pass

    mock_credentials = MockGoogleCredentials("token", "refresh_token")
    mock_project = "test-gcp-project"

    def mock_default(scopes=None, request=None):
        return mock_credentials, mock_project

    monkeypatch.setattr(google.auth, "default", mock_default)

    # Set dummy GCP credentials path (not actually used by mock, but good practice)
    monkeypatch.setenv("GOOGLE_APPLICATION_CREDENTIALS", "/tmp/fake-gcp-sa-key.json")

    # Attempt to load credentials
    try:
        credentials, project = google.auth.default()
        assert credentials == mock_credentials
        assert project == mock_project
    except Exception as e:
        pytest.fail(f"GCP credentials loading failed: {e}")