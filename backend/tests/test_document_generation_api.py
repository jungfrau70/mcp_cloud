import pytest
from fastapi.testclient import TestClient
from main import app, get_db
from models import Base
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from unittest.mock import patch, AsyncMock
import os
import pathlib

# Fixture to set up a test client with a clean database for each test
@pytest.fixture(scope="function")
def client(monkeypatch):
    # Set environment variables for the test
    monkeypatch.setenv("DATABASE_URL", "sqlite:///./test.db")
    monkeypatch.setenv("GEMINI_API_KEY", "fake_api_key")
    monkeypatch.setenv("MCP_API_KEY", "test_api_key")

    # Import app after environment variables are set
    from main import app as test_app
    from main import get_db as test_get_db
    from models import Base

    # Create a fresh, in-memory SQLite database for this test
    engine = create_engine(
        "sqlite:///./test.db", connect_args={"check_same_thread": False}
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

    test_app.dependency_overrides[test_get_db] = override_get_db

    yield TestClient(test_app)

    # Teardown: clear dependency overrides and drop tables
    test_app.dependency_overrides.clear()
    Base.metadata.drop_all(bind=engine)

@pytest.mark.asyncio
@patch('main.external_search_service_instance')
@patch('main.content_extractor_instance')
@patch('ai_document_generator.AIDocumentGenerator.generate_document') # Patch the class method
@patch('main.rag_service_instance') # Mock rag_service_instance as well
async def test_generate_document_from_external_success(
    mock_rag_service,
    mock_generate_document, # Renamed to reflect patching the method directly
    mock_content_extractor,
    mock_external_search,
    client,
    tmp_path, # pytest fixture for temporary directory
    monkeypatch # Add monkeypatch here
):
    """
    Tests the /api/v1/knowledge/generate-from-external endpoint with successful mocks.
    """
    # Set KNOWLEDGE_BASE_DIR to a temporary directory for testing file creation
    monkeypatch.setattr('main.KNOWLEDGE_BASE_DIR', str(tmp_path))

    query = "How to deploy a FastAPI application on AWS Lambda"
    target_path = "aws/fastapi-lambda-deployment.md"
    generated_slug = "fastapi-aws-lambda-deployment"
    generated_title = "FastAPI AWS Lambda 배포 가이드"
    generated_content = "# FastAPI AWS Lambda 배포 가이드\n\n## 참고 자료\n- [Result 1](http://example.com/1)\n- [Result 2](http://example.com/2)"

    # Mock external_search_service_instance.search
    mock_external_search.search.return_value = [
        {"title": "Result 1", "link": "http://example.com/1", "snippet": "Snippet 1"},
        {"title": "Result 2", "link": "http://example.com/2", "snippet": "Snippet 2"},
    ]

    # Mock content_extractor_instance.extract_content
    mock_content_extractor.extract_content.side_effect = [
        "Extracted content from link 1.",
        "Extracted content from link 2.",
    ]

    # Mock AIDocumentGenerator.generate_document
    mock_generate_document.return_value = AsyncMock(return_value={
        "title": generated_title,
        "slug": generated_slug,
        "content": generated_content,
    })

    # Mock rag_service_instance.update_knowledge_base
    mock_rag_service.update_knowledge_base.return_value = True

    response = client.post( # Removed await
        "/api/v1/knowledge/generate-from-external",
        headers={"X-API-Key": "test_api_key"},
        json={"query": query, "target_path": target_path}
    )

    assert response.status_code == 200
    data = response.json()
    assert data["success"] is True
    assert f"Document '{generated_title}' generated and saved." in data["message"]
    assert data["document_path"] == target_path

    # Verify file creation
    expected_file_path = tmp_path / target_path
    assert expected_file_path.exists()
    assert expected_file_path.read_text(encoding='utf-8') == generated_content

    # Verify mocks were called
    mock_external_search.search.assert_called_once_with(query, num_results=3)
    mock_content_extractor.extract_content.assert_any_call("http://example.com/1")
    mock_content_extractor.extract_content.assert_any_call("http://example.com/2")
    
    # Construct the expected combined_content exactly as main.py does
    expected_combined_content = "## Source: Result 1\nLink: http://example.com/1\n\nExtracted content from link 1.\n\n---\n\n## Source: Result 2\nLink: http://example.com/2\n\nExtracted content from link 2.\n\n---\n\n"

    mock_generate_document.assert_called_once_with(query, expected_combined_content, mock_external_search.search.return_value)
    mock_rag_service.update_knowledge_base.assert_called_once()

@pytest.mark.asyncio
@patch('main.external_search_service_instance')
@patch('main.content_extractor_instance')
@patch('ai_document_generator.AIDocumentGenerator.generate_document') # Patch the class method
@patch('main.rag_service_instance')
async def test_generate_document_from_external_no_target_path(
    mock_rag_service,
    mock_generate_document, # Renamed
    mock_content_extractor,
    mock_external_search,
    client,
    tmp_path,
    monkeypatch # Add monkeypatch here
):
    """
    Tests the /api/v1/knowledge/generate-from-external endpoint without a target_path.
    """
    monkeypatch.setattr('main.KNOWLEDGE_BASE_DIR', str(tmp_path))

    query = "What is serverless computing?"
    generated_slug = "what-is-serverless-computing"
    generated_title = "서버리스 컴퓨팅이란?"
    generated_content = "# 서버리스 컴퓨팅이란?\n\n## 참고 자료\n- [Serverless Intro](http://example.com/serverless)"

    mock_external_search.search.return_value = [
        {"title": "Serverless Intro", "link": "http://example.com/serverless", "snippet": "Intro to serverless"},
    ]
    mock_content_extractor.extract_content.return_value = "Extracted serverless content."
    mock_generate_document.return_value = AsyncMock(return_value={
        "title": generated_title,
        "slug": generated_slug,
        "content": generated_content,
    })

    mock_rag_service.update_knowledge_base.return_value = True

    response = client.post( # Removed await
        "/api/v1/knowledge/generate-from-external",
        headers={"X-API-Key": "test_api_key"},
        json={"query": query}
    )

    assert response.status_code == 200
    data = response.json()
    assert data["success"] is True
    assert f"Document '{generated_title}' generated and saved." in data["message"]
    assert data["document_path"] == f"{generated_slug}.md" # Default path

    # Verify file creation in root of tmp_path
    expected_file_path = tmp_path / f"{generated_slug}.md"
    assert expected_file_path.exists()
    assert expected_file_path.read_text(encoding='utf-8') == generated_content

    mock_external_search.search.assert_called_once_with(query, num_results=3)
    mock_content_extractor.extract_content.assert_called_once_with("http://example.com/serverless")

    # Construct the expected combined_content exactly as main.py does
    expected_combined_content_no_target_path = "## Source: Serverless Intro\nLink: http://example.com/serverless\n\nExtracted serverless content.\n\n---\n\n"

    mock_generate_document.assert_called_once_with(query, expected_combined_content_no_target_path, mock_external_search.search.return_value)
    mock_rag_service.update_knowledge_base.assert_called_once()


def test_generate_document_from_external_missing_query(client):
    """
    Tests the /api/v1/knowledge/generate-from-external endpoint with a missing query.
    """
    response = client.post(
        "/api/v1/knowledge/generate-from-external",
        headers={"X-API-Key": "test_api_key"},
        json={"target_path": "some/path.md"}
    )

    assert response.status_code == 422 # Unprocessable Entity due to Pydantic validation
    data = response.json()
    assert "detail" in data
    assert any("query" in error["loc"] and "missing" in error["type"] for error in data["detail"])

def test_generate_document_from_external_unauthorized(client):
    """
    Tests the /api/v1/knowledge/generate-from-external endpoint without an API key.
    """
    query = "Test query"
    response = client.post(
        "/api/v1/knowledge/generate-from-external",
        json={"query": query}
    )

    assert response.status_code == 403 # Forbidden
    data = response.json()
    assert "detail" in data
    assert "Could not validate credentials" in data["detail"]