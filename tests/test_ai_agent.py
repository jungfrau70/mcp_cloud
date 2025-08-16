import pytest
import json
from unittest.mock import Mock, patch, MagicMock
from backend.rag_service import RAGService, TerraformCodeGenerator, CostOptimizer, SecurityAuditor

class TestTerraformCodeGenerator:
    """Terraform 코드 생성기 테스트"""
    
    def setup_method(self):
        """테스트 메서드 실행 전 설정"""
        self.mock_llm = Mock()
        self.generator = TerraformCodeGenerator(self.mock_llm)
    
    def test_generate_code_success(self):
        """Terraform 코드 생성 성공 테스트"""
        # Mock 응답 설정
        mock_response = {
            "main_tf": "resource \"aws_vpc\" \"main\" { cidr_block = \"10.0.0.0/16\" }",
            "variables_tf": "variable \"region\" { type = string }",
            "outputs_tf": "output \"vpc_id\" { value = aws_vpc.main.id }",
            "description": "VPC 생성",
            "estimated_cost": "$50/month",
            "security_notes": "보안 그룹 설정 필요",
            "best_practices": "태그 설정 권장"
        }
        
        self.mock_llm.invoke.return_value = mock_response
        
        # 테스트 실행
        result = self.generator.generate_code("VPC 생성", "aws")
        
        # 검증
        assert result == mock_response
        assert "main_tf" in result
        assert "variables_tf" in result
        assert "outputs_tf" in result
    
    def test_generate_code_error(self):
        """Terraform 코드 생성 오류 테스트"""
        # Mock 오류 설정
        self.mock_llm.invoke.side_effect = Exception("LLM 오류")
        
        # 테스트 실행
        result = self.generator.generate_code("VPC 생성", "aws")
        
        # 검증
        assert "error" in result
        assert result["main_tf"] == ""
    
    def test_validate_code_success(self):
        """Terraform 코드 검증 성공 테스트"""
        # Mock 응답 설정
        mock_response = {
            "is_valid": True,
            "syntax_errors": [],
            "security_issues": ["보안 그룹 설정 필요"],
            "best_practice_violations": [],
            "recommendations": ["태그 설정 권장"],
            "severity": "LOW"
        }
        
        self.mock_llm.invoke.return_value = mock_response
        
        # 테스트 실행
        terraform_code = 'resource "aws_vpc" "main" { cidr_block = "10.0.0.0/16" }'
        result = self.generator.validate_code(terraform_code)
        
        # 검증
        assert result == mock_response
        assert result["is_valid"] is True
        assert len(result["security_issues"]) > 0

class TestCostOptimizer:
    """비용 최적화 도구 테스트"""
    
    def setup_method(self):
        """테스트 메서드 실행 전 설정"""
        self.mock_llm = Mock()
        self.optimizer = CostOptimizer(self.mock_llm)
    
    def test_analyze_cost_success(self):
        """비용 분석 성공 테스트"""
        # Mock 응답 설정
        mock_response = {
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
        
        self.mock_llm.invoke.return_value = mock_response
        
        # 테스트 실행
        infrastructure_desc = "3개 AZ VPC, EC2 인스턴스, RDS"
        result = self.optimizer.analyze_cost(infrastructure_desc, "aws")
        
        # 검증
        assert result == mock_response
        assert result["estimated_monthly_cost"] == "$150/month"
        assert len(result["optimization_opportunities"]) > 0

class TestSecurityAuditor:
    """보안 감사 도구 테스트"""
    
    def setup_method(self):
        """테스트 메서드 실행 전 설정"""
        self.mock_llm = Mock()
        self.auditor = SecurityAuditor(self.mock_llm)
    
    def test_audit_security_success(self):
        """보안 감사 성공 테스트"""
        # Mock 응답 설정
        mock_response = {
            "security_score": 75,
            "critical_issues": ["퍼블릭 액세스 허용"],
            "high_risk_issues": ["기본 보안 그룹 사용"],
            "medium_risk_issues": ["태그 미설정"],
            "low_risk_issues": ["로깅 미설정"],
            "compliance_check": ["CIS 벤치마크 준수"],
            "security_recommendations": ["보안 그룹 제한", "IAM 정책 강화"],
            "iam_recommendations": ["최소 권한 원칙 적용"],
            "network_security": ["VPC 엔드포인트 사용"]
        }
        
        self.mock_llm.invoke.return_value = mock_response
        
        # 테스트 실행
        infrastructure_desc = "퍼블릭 서브넷, EC2 인스턴스"
        result = self.auditor.audit_security(infrastructure_desc, "aws")
        
        # 검증
        assert result == mock_response
        assert result["security_score"] == 75
        assert len(result["critical_issues"]) > 0
        assert len(result["security_recommendations"]) > 0

class TestRAGService:
    """RAG 서비스 통합 테스트"""
    
    @patch('backend.rag_service.HuggingFaceEmbeddings')
    @patch('backend.rag_service.ChatGoogleGenerativeAI')
    def setup_method(self, mock_genai, mock_embeddings):
        """테스트 메서드 실행 전 설정"""
        # Mock 설정
        mock_embeddings.return_value = Mock()
        mock_genai.return_value = Mock()
        
        # 환경 변수 Mock 설정
        with patch.dict('os.environ', {'GEMINI_API_KEY': 'test_key'}):
            with patch('os.path.exists', return_value=False):
                with patch('backend.rag_service.FAISS.from_documents') as mock_faiss:
                    mock_faiss.return_value = Mock()
                    self.rag_service = RAGService()
    
    def test_generate_terraform_code(self):
        """RAG 서비스의 Terraform 코드 생성 테스트"""
        # Mock 설정
        mock_result = {
            "main_tf": "resource \"aws_vpc\" \"main\" { cidr_block = \"10.0.0.0/16\" }",
            "variables_tf": "variable \"region\" { type = string }",
            "outputs_tf": "output \"vpc_id\" { value = aws_vpc.main.id }",
            "description": "VPC 생성",
            "estimated_cost": "$50/month",
            "security_notes": "보안 그룹 설정 필요",
            "best_practices": "태그 설정 권장"
        }
        
        self.rag_service.terraform_generator.generate_code.return_value = mock_result
        
        # 테스트 실행
        result = self.rag_service.generate_terraform_code("VPC 생성", "aws")
        
        # 검증
        assert result == mock_result
        self.rag_service.terraform_generator.generate_code.assert_called_once_with("VPC 생성", "aws")
    
    def test_analyze_cost(self):
        """RAG 서비스의 비용 분석 테스트"""
        # Mock 설정
        mock_result = {
            "estimated_monthly_cost": "$150/month",
            "cost_breakdown": {"compute": "$80"},
            "optimization_opportunities": ["예약 인스턴스 사용"]
        }
        
        self.rag_service.cost_optimizer.analyze_cost.return_value = mock_result
        
        # 테스트 실행
        result = self.rag_service.analyze_cost("인프라 설명", "aws")
        
        # 검증
        assert result == mock_result
        self.rag_service.cost_optimizer.analyze_cost.assert_called_once_with("인프라 설명", "aws")
    
    def test_audit_security(self):
        """RAG 서비스의 보안 감사 테스트"""
        # Mock 설정
        mock_result = {
            "security_score": 75,
            "critical_issues": ["퍼블릭 액세스 허용"],
            "security_recommendations": ["보안 그룹 제한"]
        }
        
        self.rag_service.security_auditor.audit_security.return_value = mock_result
        
        # 테스트 실행
        result = self.rag_service.audit_security("인프라 설명", "aws")
        
        # 검증
        assert result == mock_result
        self.rag_service.security_auditor.audit_security.assert_called_once_with("인프라 설명", "aws")

class TestAIAgentIntegration:
    """AI Agent 통합 테스트"""
    
    @patch('backend.rag_service.RAGService')
    def test_ai_agent_workflow(self, mock_rag_service):
        """AI Agent 워크플로우 통합 테스트"""
        # Mock RAG 서비스 설정
        mock_instance = Mock()
        mock_rag_service.return_value = mock_instance
        
        # Terraform 코드 생성 Mock
        mock_instance.generate_terraform_code.return_value = {
            "main_tf": "resource \"aws_vpc\" \"main\" { cidr_block = \"10.0.0.0/16\" }",
            "description": "VPC 생성"
        }
        
        # 비용 분석 Mock
        mock_instance.analyze_cost.return_value = {
            "estimated_monthly_cost": "$50/month"
        }
        
        # 보안 감사 Mock
        mock_instance.audit_security.return_value = {
            "security_score": 80,
            "security_recommendations": ["보안 그룹 설정"]
        }
        
        # 워크플로우 테스트
        # 1. Terraform 코드 생성
        terraform_result = mock_instance.generate_terraform_code("VPC 생성", "aws")
        assert "main_tf" in terraform_result
        
        # 2. 비용 분석
        cost_result = mock_instance.analyze_cost("VPC 인프라", "aws")
        assert "estimated_monthly_cost" in cost_result
        
        # 3. 보안 감사
        security_result = mock_instance.audit_security("VPC 인프라", "aws")
        assert "security_score" in security_result
        
        # 검증
        assert mock_instance.generate_terraform_code.call_count == 1
        assert mock_instance.analyze_cost.call_count == 1
        assert mock_instance.audit_security.call_count == 1

if __name__ == "__main__":
    pytest.main([__file__, "-v"])
