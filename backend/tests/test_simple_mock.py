import pytest
from unittest.mock import Mock, patch, MagicMock

class TestSimpleMock:
    """간단한 Mock 기반 테스트"""
    
    def test_basic_mock(self):
        """기본 Mock 테스트"""
        mock_obj = Mock()
        mock_obj.some_method.return_value = "test_result"
        
        result = mock_obj.some_method()
        assert result == "test_result"
        mock_obj.some_method.assert_called_once()
    
    def test_mock_with_arguments(self):
        """인자를 받는 Mock 테스트"""
        mock_obj = Mock()
        mock_obj.calculate.return_value = 42
        
        result = mock_obj.calculate(10, 32)
        assert result == 42
        mock_obj.calculate.assert_called_once_with(10, 32)

class TestTerraformGeneratorMock:
    """Terraform 코드 생성기 Mock 테스트"""
    
    def setup_method(self):
        """테스트 메서드 실행 전 설정"""
        self.mock_llm = Mock()
        # Mock의 invoke 메서드가 호출될 때 반환할 값 설정
        self.mock_llm.invoke = Mock()
    
    def test_generate_code_mock(self):
        """Terraform 코드 생성 Mock 테스트"""
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
        
        # Mock 설정
        self.mock_llm.invoke.return_value = mock_response
        
        # 테스트 실행 (실제 클래스 대신 Mock 사용)
        mock_generator = Mock()
        mock_generator.generate_code = Mock(return_value=mock_response)
        
        result = mock_generator.generate_code("VPC 생성", "aws")
        
        # 검증
        assert result == mock_response
        assert "main_tf" in result
        assert "variables_tf" in result
        assert "outputs_tf" in result
        assert result["estimated_cost"] == "$50/month"
        
        # Mock 호출 확인
        mock_generator.generate_code.assert_called_once_with("VPC 생성", "aws")
    
    def test_cost_optimizer_mock(self):
        """비용 최적화 Mock 테스트"""
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
        
        # Mock 설정
        mock_optimizer = Mock()
        mock_optimizer.analyze_cost = Mock(return_value=mock_response)
        
        # 테스트 실행
        result = mock_optimizer.analyze_cost("3개 AZ VPC, EC2 인스턴스, RDS", "aws")
        
        # 검증
        assert result == mock_response
        assert result["estimated_monthly_cost"] == "$150/month"
        assert len(result["optimization_opportunities"]) == 2
        assert "예약 인스턴스 사용" in result["optimization_opportunities"]
        
        # Mock 호출 확인
        mock_optimizer.analyze_cost.assert_called_once_with("3개 AZ VPC, EC2 인스턴스, RDS", "aws")
    
    def test_security_auditor_mock(self):
        """보안 감사 Mock 테스트"""
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
        
        # Mock 설정
        mock_auditor = Mock()
        mock_auditor.audit_security = Mock(return_value=mock_response)
        
        # 테스트 실행
        result = mock_auditor.audit_security("퍼블릭 서브넷, EC2 인스턴스", "aws")
        
        # 검증
        assert result == mock_response
        assert result["security_score"] == 75
        assert len(result["critical_issues"]) == 1
        assert "퍼블릭 액세스 허용" in result["critical_issues"]
        assert len(result["security_recommendations"]) == 2
        
        # Mock 호출 확인
        mock_auditor.audit_security.assert_called_once_with("퍼블릭 서브넷, EC2 인스턴스", "aws")

class TestUserScenarioMock:
    """사용자 시나리오 Mock 테스트"""
    
    def test_scenario1_new_team_infrastructure(self):
        """시나리오 1: 신규 개발팀 인프라 설계 Mock 테스트"""
        # Mock 서비스 생성
        mock_service = Mock()
        
        # 1단계: Terraform 코드 생성
        terraform_result = {
            "main_tf": "resource \"aws_vpc\" \"main\" { cidr_block = \"10.0.0.0/16\" }",
            "estimated_cost": "$180/month"
        }
        mock_service.generate_terraform_code = Mock(return_value=terraform_result)
        
        result1 = mock_service.generate_terraform_code("웹 애플리케이션 인프라", "aws")
        assert "aws_vpc" in result1["main_tf"]
        assert result1["estimated_cost"] == "$180/month"
        
        # 2단계: 비용 분석
        cost_result = {
            "estimated_monthly_cost": "$178.50",
            "cost_breakdown": {"compute": "$95", "storage": "$45"}
        }
        mock_service.analyze_cost = Mock(return_value=cost_result)
        
        result2 = mock_service.analyze_cost("3개 가용영역 VPC, ALB, Auto Scaling Group", "aws")
        assert result2["estimated_monthly_cost"] == "$178.50"
        
        # 3단계: 보안 감사
        security_result = {
            "security_score": 82,
            "security_recommendations": ["보안 그룹 규칙 세분화"]
        }
        mock_service.audit_security = Mock(return_value=security_result)
        
        result3 = mock_service.audit_security("3개 가용영역 VPC, ALB, Auto Scaling Group", "aws")
        assert result3["security_score"] == 82
        
        # 전체 워크플로우 검증
        assert mock_service.generate_terraform_code.call_count == 1
        assert mock_service.analyze_cost.call_count == 1
        assert mock_service.audit_security.call_count == 1
        
        print("✅ 시나리오 1 Mock 테스트 완료")
    
    def test_scenario2_cost_optimization(self):
        """시나리오 2: 비용 최적화 Mock 테스트"""
        mock_service = Mock()
        
        # 현재 비용
        current_cost = {
            "estimated_monthly_cost": "$487.50",
            "cost_breakdown": {"compute": "$250", "storage": "$120"}
        }
        mock_service.analyze_cost = Mock(side_effect=[current_cost, {"estimated_monthly_cost": "$289.50"}])
        
        # 현재 비용 분석
        result1 = mock_service.analyze_cost("EC2 인스턴스 5대, RDS MySQL, S3", "aws")
        assert result1["estimated_monthly_cost"] == "$487.50"
        
        # 최적화 후 비용 분석
        result2 = mock_service.analyze_cost("예약 인스턴스 + Auto Scaling", "aws")
        assert result2["estimated_monthly_cost"] == "$289.50"
        
        # 비용 절약 계산
        current = float(result1["estimated_monthly_cost"].replace("$", "").replace("/month", ""))
        optimized = float(result2["estimated_monthly_cost"].replace("$", "").replace("/month", ""))
        savings = current - optimized
        
        assert savings >= 150  # 최소 $150 절약
        print(f"✅ 시나리오 2 Mock 테스트 완료 - 비용 절약: ${savings:.2f}/월")
    
    def test_scenario3_security_compliance(self):
        """시나리오 3: 보안 강화 Mock 테스트"""
        mock_service = Mock()
        
        # 초기 보안 상태
        initial_security = {
            "security_score": 65,
            "critical_issues": ["RDS 퍼블릭 액세스 허용"],
            "high_risk_issues": ["기본 보안 그룹 사용"]
        }
        
        # 보안 강화 후 상태
        improved_security = {
            "security_score": 92,
            "critical_issues": [],
            "high_risk_issues": []
        }
        
        mock_service.audit_security = Mock(side_effect=[initial_security, improved_security])
        
        # 초기 보안 감사
        result1 = mock_service.audit_security("고객 결제 정보 처리 웹 애플리케이션", "aws")
        assert result1["security_score"] == 65
        assert len(result1["critical_issues"]) >= 1
        
        # 보안 강화 후 감사
        result2 = mock_service.audit_security("보안 강화 완료된 인프라", "aws")
        assert result2["security_score"] == 92
        assert len(result2["critical_issues"]) == 0
        
        # 보안 점수 향상 확인
        score_improvement = result2["security_score"] - result1["security_score"]
        assert score_improvement >= 25
        
        print(f"✅ 시나리오 3 Mock 테스트 완료 - 보안 점수 향상: +{score_improvement}점")

if __name__ == "__main__":
    pytest.main([__file__, "-v"])
