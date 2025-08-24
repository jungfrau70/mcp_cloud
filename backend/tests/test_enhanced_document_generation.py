import pytest
import os
from fastapi.testclient import TestClient
from unittest.mock import patch, AsyncMock, MagicMock
import json
from main import app

@pytest.fixture
def client():
    return TestClient(app)

@pytest.fixture
def mock_external_search():
    with patch('main.external_search_service_instance') as mock:
        mock.search.return_value = [
            {
                "title": "AWS Lambda Tutorial",
                "link": "https://example.com/lambda-tutorial",
                "snippet": "Learn how to deploy serverless functions with AWS Lambda",
                "source": "AWS Docs",
                "date": "2024-01-15"
            },
            {
                "title": "Serverless Architecture Guide",
                "link": "https://example.com/serverless-guide",
                "snippet": "Complete guide to building serverless applications",
                "source": "Tech Blog",
                "date": "2024-01-10"
            }
        ]
        yield mock

@pytest.fixture
def mock_content_extractor():
    with patch('main.content_extractor_instance') as mock:
        mock.extract_multiple_urls.return_value = {
            "https://example.com/lambda-tutorial": {
                "content": "This is extracted content from the Lambda tutorial...",
                "word_count": 150,
                "extraction_time": 1234567890.0,
                "url": "https://example.com/lambda-tutorial",
                "metadata": {
                    "title": "AWS Lambda Tutorial",
                    "description": "Learn AWS Lambda",
                    "author": "AWS Team"
                }
            },
            "https://example.com/serverless-guide": {
                "content": "This is extracted content from the serverless guide...",
                "word_count": 200,
                "extraction_time": 1234567890.0,
                "url": "https://example.com/serverless-guide",
                "metadata": {
                    "title": "Serverless Architecture Guide",
                    "description": "Serverless architecture guide",
                    "author": "Tech Blog"
                }
            }
        }
        yield mock

@pytest.fixture
def mock_ai_generator():
    with patch('main.ai_document_generator_instance') as mock:
        mock.generate_document.return_value = AsyncMock(return_value={
            "title": "AWS Lambda 서버리스 애플리케이션 배포 가이드",
            "slug": "aws-lambda-serverless-deployment-guide",
            "content": "# AWS Lambda 서버리스 애플리케이션 배포 가이드\n\n## 개요\n\nAWS Lambda를 사용한 서버리스 애플리케이션 배포 방법에 대해 설명합니다.\n\n## 참고 자료\n\n1. **AWS Lambda Tutorial**\n   - 링크: https://example.com/lambda-tutorial\n   - 요약: Learn how to deploy serverless functions with AWS Lambda\n   - 출처: AWS Docs\n   - 날짜: 2024-01-15\n\n2. **Serverless Architecture Guide**\n   - 링크: https://example.com/serverless-guide\n   - 요약: Complete guide to building serverless applications\n   - 출처: Tech Blog\n   - 날짜: 2024-01-10\n",
            "metadata": {
                "generated_at": "2024-01-20T10:00:00",
                "query": "AWS Lambda를 사용한 서버리스 애플리케이션 배포 방법",
                "doc_type": "guide",
                "sources_count": 2,
                "validation_passed": True,
                "quality_suggestions": []
            }
        })
        yield mock

@pytest.fixture
def mock_rag_service():
    with patch('main.rag_service_instance') as mock:
        mock.update_knowledge_base.return_value = True
        yield mock

class TestEnhancedDocumentGeneration:
    """향상된 외부자료기반문서생성기능 테스트"""

    @pytest.mark.asyncio
    async def test_generate_document_from_external_enhanced_success(
        self, client, mock_external_search, mock_content_extractor, 
        mock_ai_generator, mock_rag_service, tmp_path
    ):
        """향상된 문서 생성 API 성공 테스트"""
        
        # 테스트 데이터
        request_data = {
            "query": "AWS Lambda를 사용한 서버리스 애플리케이션 배포 방법",
            "doc_type": "guide",
            "search_sources": ["web", "news"],
            "target_path": "aws/lambda-deployment",
            "max_results": 5
        }

        # API 호출
        response = client.post(
            "/api/v1/knowledge/generate-from-external-enhanced",
            headers={"X-API-Key": os.getenv("MCP_API_KEY")},
            json=request_data
        )

        # 응답 검증
        assert response.status_code == 200
        data = response.json()
        
        assert data["success"] is True
        assert "AWS Lambda 서버리스 애플리케이션 배포 가이드" in data["message"]
        assert data["document_path"] == "aws/lambda-deployment/aws-lambda-serverless-deployment-guide.md"
        assert data["generated_doc_data"]["title"] == "AWS Lambda 서버리스 애플리케이션 배포 가이드"
        assert data["generated_doc_data"]["slug"] == "aws-lambda-serverless-deployment-guide"

        # 모킹된 함수들이 올바르게 호출되었는지 확인
        mock_external_search.search.assert_called()
        mock_content_extractor.extract_multiple_urls.assert_called()
        mock_ai_generator.generate_document.assert_called()

    @pytest.mark.asyncio
    async def test_generate_document_no_search_results(
        self, client, mock_external_search, mock_content_extractor, 
        mock_ai_generator, mock_rag_service
    ):
        """검색 결과가 없는 경우 테스트"""
        
        # 검색 결과가 없도록 모킹
        mock_external_search.search.return_value = []

        request_data = {
            "query": "존재하지 않는 주제",
            "doc_type": "guide",
            "search_sources": ["web"],
            "max_results": 5
        }

        response = client.post(
            "/api/v1/knowledge/generate-from-external-enhanced",
            headers={"X-API-Key": os.getenv("MCP_API_KEY")},
            json=request_data
        )

        assert response.status_code == 200
        data = response.json()
        assert data["success"] is False
        assert "No relevant search results found" in data["message"]

    @pytest.mark.asyncio
    async def test_generate_document_no_content_extracted(
        self, client, mock_external_search, mock_content_extractor, 
        mock_ai_generator, mock_rag_service
    ):
        """콘텐츠 추출에 실패한 경우 테스트"""
        
        # 콘텐츠 추출 결과가 없도록 모킹
        mock_content_extractor.extract_multiple_urls.return_value = {
            "https://example.com/failed": None
        }

        request_data = {
            "query": "테스트 쿼리",
            "doc_type": "guide",
            "search_sources": ["web"],
            "max_results": 5
        }

        response = client.post(
            "/api/v1/knowledge/generate-from-external-enhanced",
            headers={"X-API-Key": os.getenv("MCP_API_KEY")},
            json=request_data
        )

        assert response.status_code == 200
        data = response.json()
        assert data["success"] is False
        assert "Could not extract content" in data["message"]

    @pytest.mark.asyncio
    async def test_generate_document_ai_generation_failed(
        self, client, mock_external_search, mock_content_extractor, 
        mock_ai_generator, mock_rag_service
    ):
        """AI 문서 생성에 실패한 경우 테스트"""
        
        # AI 생성 결과가 None이 되도록 모킹
        mock_ai_generator.generate_document.return_value = AsyncMock(return_value={"slug": "ai-gen-failed", "title": "AI Gen Failed"})

        request_data = {
            "query": "테스트 쿼리",
            "doc_type": "guide",
            "search_sources": ["web"],
            "max_results": 5
        }

        response = client.post(
            "/api/v1/knowledge/generate-from-external-enhanced",
            headers={"X-API-Key": os.getenv("MCP_API_KEY")},
            json=request_data
        )

        assert response.status_code == 200
        data = response.json()
        assert data["success"] is False
        assert "AI document generation failed" in data["message"]

    @pytest.mark.asyncio
    async def test_generate_document_invalid_request(self, client):
        """잘못된 요청 데이터 테스트"""
        
        # 필수 필드가 없는 요청
        request_data = {
            "doc_type": "guide"
            # query 필드 누락
        }

        response = client.post(
            "/api/v1/knowledge/generate-from-external-enhanced",
            headers={"X-API-Key": os.getenv("MCP_API_KEY")},
            json=request_data
        )

        assert response.status_code == 422  # Validation error

    @pytest.mark.asyncio
    async def test_generate_document_unauthorized(self, client):
        """인증되지 않은 요청 테스트"""
        
        request_data = {
            "query": "테스트 쿼리",
            "doc_type": "guide",
            "search_sources": ["web"],
            "max_results": 5
        }

        # API 키 없이 요청
        response = client.post(
            "/api/v1/knowledge/generate-from-external-enhanced",
            json=request_data
        )

        assert response.status_code == 403

class TestContentExtraction:
    """콘텐츠 추출 API 테스트"""

    @pytest.mark.asyncio
    async def test_extract_content_from_urls_success(
        self, client, mock_content_extractor
    ):
        """URL에서 콘텐츠 추출 성공 테스트"""
        
        request_data = {
            "urls": [
                "https://example.com/doc1",
                "https://example.com/doc2"
            ],
            "extract_metadata": True
        }

        response = client.post(
            "/api/v1/knowledge/extract-content",
            headers={"X-API-Key": os.getenv("MCP_API_KEY")},
            json=request_data
        )

        assert response.status_code == 200
        data = response.json()
        
        assert data["success"] is True
        assert "results" in data
        assert "stats" in data
        assert len(data["results"]) == 2

        mock_content_extractor.extract_multiple_urls.assert_called_with(
            request_data["urls"], max_concurrent=5
        )

    @pytest.mark.asyncio
    async def test_extract_content_empty_urls(self, client):
        """빈 URL 목록 테스트"""
        
        request_data = {
            "urls": [],
            "extract_metadata": True
        }

        response = client.post(
            "/api/v1/knowledge/extract-content",
            headers={"X-API-Key": os.getenv("MCP_API_KEY")},
            json=request_data
        )

        assert response.status_code == 200
        data = response.json()
        assert data["success"] is True
        assert len(data["results"]) == 0

class TestMultipleFormatGeneration:
    """다중 형식 문서 생성 테스트"""

    @pytest.mark.asyncio
    async def test_generate_multiple_formats_success(
        self, client, mock_external_search, mock_content_extractor, 
        mock_ai_generator, mock_rag_service
    ):
        """다중 형식 문서 생성 성공 테스트"""
        
        # 다중 형식 생성 결과 모킹
        mock_ai_generator.generate_multiple_formats.return_value = AsyncMock(return_value={
            "guide": {
                "title": "가이드 문서",
                "slug": "guide-doc",
                "content": "# 가이드 문서\n\n가이드 내용..."
            },
            "tutorial": {
                "title": "튜토리얼 문서",
                "slug": "tutorial-doc",
                "content": "# 튜토리얼 문서\n\n튜토리얼 내용..."
            },
            "reference": {
                "title": "참조 문서",
                "slug": "reference-doc",
                "content": "# 참조 문서\n\n참조 내용..."
            }
        })

        request_data = {
            "query": "테스트 쿼리",
            "doc_type": "guide",
            "search_sources": ["web"],
            "max_results": 5
        }

        response = client.post(
            "/api/v1/knowledge/generate-multiple-formats",
            headers={"X-API-Key": os.getenv("MCP_API_KEY")},
            json=request_data
        )

        assert response.status_code == 200
        data = response.json()
        
        assert data["success"] is True
        assert "formats" in data
        assert len(data["formats"]) == 3
        assert "guide" in data["formats"]
        assert "tutorial" in data["formats"]
        assert "reference" in data["formats"]

class TestSearchStats:
    """검색 통계 API 테스트"""

    @pytest.mark.asyncio
    async def test_get_search_stats_success(
        self, client, mock_content_extractor
    ):
        """검색 통계 조회 성공 테스트"""
        
        # 통계 데이터 모킹
        mock_content_extractor.get_extraction_stats.return_value = {
            "cached_urls": 10,
            "total_words": 5000,
            "cache_size_mb": 2.5
        }

        response = client.get(
            "/api/v1/knowledge/search-stats",
            headers={"X-API-Key": os.getenv("MCP_API_KEY")}
        )

        assert response.status_code == 200
        data = response.json()
        
        assert data["success"] is True
        assert "extraction_stats" in data
        assert "timestamp" in data
        assert data["extraction_stats"]["cached_urls"] == 10
        assert data["extraction_stats"]["total_words"] == 5000

    @pytest.mark.asyncio
    async def test_get_search_stats_unauthorized(self, client):
        """인증되지 않은 통계 조회 테스트"""
        
        response = client.get("/api/v1/knowledge/search-stats")
        assert response.status_code == 403
