import sys
import os
import pytest
from unittest.mock import Mock, patch

# 백엔드 루트(현재 디렉터리 상위) 경로를 sys.path에 추가
# 기존 경로는 backend/backend 를 가리켜 ModuleNotFoundError 발생
PROJECT_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))
if PROJECT_ROOT not in sys.path:
    sys.path.insert(0, PROJECT_ROOT)

# 테스트용 환경 변수 설정
# 통합/라이브 테스트 시 실제 실행중인 백엔드의 키를 덮어쓰면 안되므로 LIVE_API_BASE 존재 시 MCP_API_KEY 미변경
live_mode = bool(os.getenv('LIVE_API_BASE'))

env_patch = {
    'DATABASE_URL': 'postgresql://mcpuser:mcppassword@localhost:5434/mcp_db',
    'GEMINI_API_KEY': 'test_key_for_testing',
    'AWS_DEFAULT_REGION': 'ap-northeast-2',
    'ENVIRONMENT': 'test',
    'DEBUG': 'false',
    'LOG_LEVEL': 'INFO'
}
"""MCP_API_KEY 우선순위
1. 이미 환경에 설정되어 있으면(예: live 서비스) 그대로 사용
2. LIVE_API_BASE 지정되면 라이브 모드 간주 → 덮어쓰지 않음
3. 그 외(로컬 단위/모킹 테스트)일 때만 test_mcp_key 주입
"""
if not live_mode and 'MCP_API_KEY' not in os.environ:
    env_patch['MCP_API_KEY'] = 'test_mcp_key'

os.environ.update(env_patch)

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
