import sys
import os
import pytest
from unittest.mock import Mock, patch

# 백엔드 모듈 경로 추가
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..', 'backend')))

# 테스트용 환경 변수 설정
os.environ.update({
    'DATABASE_URL': 'postgresql://mcpuser:mcppassword@localhost:5434/mcp_db',
    'GEMINI_API_KEY': 'test_key_for_testing',
    'MCP_API_KEY': 'test_mcp_key',
    'AWS_DEFAULT_REGION': 'ap-northeast-2',
    'ENVIRONMENT': 'test',
    'DEBUG': 'false',
    'LOG_LEVEL': 'INFO'
})

@pytest.fixture(scope="session")
def test_environment():
    """테스트 환경 설정"""
    return {
        'database_url': os.environ['DATABASE_URL'],
        'gemini_api_key': os.environ['GEMINI_API_KEY'],
        'mcp_api_key': os.environ['MCP_API_KEY']
    }

@pytest.fixture
def mock_llm():
    """Mock LLM 객체"""
    mock = Mock()
    mock.invoke.return_value = {
        "main_tf": 'resource "aws_vpc" "main" { cidr_block = "10.0.0.0/16" }',
        "variables_tf": 'variable "region" { type = string }',
        "outputs_tf": 'output "vpc_id" { value = aws_vpc.main.id }',
        "description": "VPC 생성",
        "estimated_cost": "$50/month",
        "security_notes": "보안 그룹 설정 필요",
        "best_practices": "태그 설정 권장"
    }
    return mock

@pytest.fixture
def mock_cost_optimizer():
    """Mock 비용 최적화 도구"""
    mock = Mock()
    mock.invoke.return_value = {
        "estimated_monthly_cost": "$150/month",
        "cost_breakdown": {
            "compute": "$80",
            "storage": "$40",
            "network": "$20",
            "other": "$10"
        },
        "optimization_opportunities": ["예약 인스턴스 사용", "자동 스케일링 설정"],
        "reserved_instances": ["t3.medium 1년 예약"],
        "auto_scaling_recommendations": ["CPU 사용률 기반 스케일링"],
        "budget_alerts": ["$200 예산 알림 설정"]
    }
    return mock

@pytest.fixture
def mock_security_auditor():
    """Mock 보안 감사 도구"""
    mock = Mock()
    mock.invoke.return_value = {
        "security_score": 75,
        "critical_issues": ["보안 그룹 설정 필요"],
        "high_risk_issues": ["IAM 권한 과다"],
        "medium_risk_issues": ["태그 설정 부족"],
        "low_risk_issues": ["모니터링 설정"],
        "compliance_check": ["PCI DSS: ⚠️ 부분 준수"],
        "security_recommendations": ["보안 그룹 규칙 세분화"],
        "iam_recommendations": ["최소 권한 원칙 적용"],
        "network_security": ["VPC 엔드포인트 사용"]
    }
    return mock
