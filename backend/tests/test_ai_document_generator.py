import pytest
from unittest.mock import AsyncMock, patch
from ai_document_generator import AIDocumentGenerator
import os
import json

@pytest.fixture
def ai_generator():
    # Ensure API key is set for initialization, though we'll mock the actual call
    os.environ["GEMINI_API_KEY"] = "test_api_key" 
    return AIDocumentGenerator()

@pytest.mark.asyncio
@patch('google.generativeai.GenerativeModel.generate_content_async')
async def test_generate_document_success(mock_generate_content_async, ai_generator):
    """
    Tests successful document generation with a mocked LLM response.
    """
    mock_response_text = json.dumps({"title": "FastAPI AWS Lambda 배포 가이드", "slug": "fastapi-aws-lambda-deployment-guide", "content": "# FastAPI AWS Lambda 배포 가이드\n\n이 문서는 FastAPI 애플리케이션을 AWS Lambda에 배포하는 방법을 설명합니다.\n\n## 1. 개요\nFastAPI는 파이썬 기반의 고성능 웹 프레임워크이며, AWS Lambda는 서버리스 컴퓨팅 서비스입니다. 둘을 결합하여 효율적인 서버리스 애플리케이션을 구축할 수 있습니다.\n\n## 2. 배포 단계\n1.  **프로젝트 설정**: `mangum` 라이브러리를 사용하여 ASGI 애플리케이션을 Lambda와 호환되도록 합니다.\n2.  **배포 패키지 생성**: 필요한 모든 의존성을 포함하는 배포 패키지를 생성합니다.\n3.  **Lambda 함수 생성**: AWS Lambda 콘솔 또는 AWS CLI를 사용하여 Lambda 함수를 생성하고 패키지를 업로드합니다.\n4.  **API Gateway 설정**: API Gateway를 통해 Lambda 함수를 HTTP 엔드포인트로 노출합니다.\n\n## 3. 결론\nFastAPI와 AWS Lambda를 사용하면 확장 가능하고 비용 효율적인 서버리스 애플리케이션을 쉽게 배포할 수 있습니다.\n\n## 참고 자료\n- [Result 1](http://example.com/1)\n- [Result 2](http://example.com/2)"})
    mock_generate_content_async.return_value = AsyncMock(text=mock_response_text)

    query = "FastAPI AWS Lambda 배포 방법"
    extracted_content = "FastAPI is a web framework. AWS Lambda is serverless. Here are steps to deploy..."
    search_results = [
        {"title": "Result 1", "link": "http://example.com/1"},
        {"title": "Result 2", "link": "http://example.com/2"},
    ]

    result = await ai_generator.generate_document(query, extracted_content, search_results)

    assert result is not None
    assert result["title"] == "FastAPI AWS Lambda 배포 가이드"
    assert result["slug"] == "fastapi-aws-lambda-deployment-guide"
    assert "# FastAPI AWS Lambda 배포 가이드" in result["content"]
    mock_generate_content_async.assert_called_once()

@pytest.mark.asyncio
@patch('google.generativeai.GenerativeModel.generate_content_async')
async def test_generate_document_llm_returns_invalid_json(mock_generate_content_async, ai_generator):
    """
    Tests handling of invalid JSON response from LLM.
    """
    mock_generate_content_async.return_value = AsyncMock(text="This is not valid JSON.")

    query = "Invalid JSON test"
    extracted_content = "Some content."
    search_results = [] # Added missing argument

    result = await ai_generator.generate_document(query, extracted_content, search_results)
    assert result is None

@pytest.mark.asyncio
@patch('google.generativeai.GenerativeModel.generate_content_async')
async def test_generate_document_llm_returns_missing_keys(mock_generate_content_async, ai_generator):
    """
    Tests handling of LLM response with missing required keys.
    """
    mock_generate_content_async.return_value = AsyncMock(text='{"title": "Only Title"}')

    query = "Missing keys test"
    extracted_content = "Some content."
    search_results = [] # Added missing argument

    result = await ai_generator.generate_document(query, extracted_content, search_results)
    assert result is None

@pytest.mark.asyncio
@patch('google.generativeai.GenerativeModel.generate_content_async')
async def test_generate_document_llm_exception(mock_generate_content_async, ai_generator):
    """
    Tests handling of exceptions during LLM call.
    """
    mock_generate_content_async.side_effect = Exception("LLM API error")

    query = "LLM error test"
    extracted_content = "Some content."
    search_results = [] # Added missing argument

    result = await ai_generator.generate_document(query, extracted_content, search_results)
    assert result is None
