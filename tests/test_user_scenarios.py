import pytest
import json
import asyncio
from unittest.mock import Mock, patch, MagicMock
from backend.rag_service import RAGService, TerraformCodeGenerator, CostOptimizer, SecurityAuditor

class TestUserScenario1_NewTeamInfrastructure:
    """시나리오 1: 신규 개발팀의 클라우드 인프라 설계 테스트"""
    
    def setup_method(self):
        """테스트 메서드 실행 전 설정"""
        self.mock_llm = Mock()
        self.terraform_generator = TerraformCodeGenerator(self.mock_llm)
        self.cost_optimizer = CostOptimizer(self.mock_llm)
        self.security_auditor = SecurityAuditor(self.mock_llm)
    
    def test_new_team_infrastructure_workflow(self):
        """신규 팀 인프라 설계 전체 워크플로우 테스트"""
        
        # 1. Terraform 코드 생성 테스트
        mock_terraform_response = {
            "main_tf": """
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true
  
  tags = {
    Name = "web-app-vpc"
    Environment = "production"
  }
}

resource "aws_subnet" "public" {
  count = 3
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.${count.index + 1}.0/24"
  availability_zone = data.aws_availability_zones.available.names[count.index]
  
  tags = {
    Name = "public-subnet-${count.index + 1}"
  }
}

resource "aws_subnet" "private" {
  count = 3
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.${count.index + 10}.0/24"
  availability_zone = data.aws_availability_zones.available.names[count.index]
  
  tags = {
    Name = "private-subnet-${count.index + 1}"
  }
}
            """,
            "variables_tf": """
variable "region" {
  description = "AWS region"
  type = string
  default = "us-east-1"
}

variable "environment" {
  description = "Environment name"
  type = string
  default = "production"
}
            """,
            "outputs_tf": """
output "vpc_id" {
  description = "VPC ID"
  value = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value = aws_subnet.public[*].id
}
            """,
            "description": "3개 가용영역에 걸친 고가용성 웹 애플리케이션 인프라",
            "estimated_cost": "$180/month",
            "security_notes": "보안 그룹 설정 필요, IAM 역할 기반 접근 제어 권장",
            "best_practices": "태그 설정, 모니터링 활성화, 백업 정책 수립"
        }
        
        self.mock_llm.invoke.return_value = mock_terraform_response
        
        terraform_result = self.terraform_generator.generate_code(
            "AWS에서 3개 가용영역에 걸친 고가용성 웹 애플리케이션 인프라 구축", 
            "aws"
        )
        
        # 검증
        assert terraform_result["main_tf"] is not None
        assert "aws_vpc" in terraform_result["main_tf"]
        assert "aws_subnet" in terraform_result["main_tf"]
        assert terraform_result["estimated_cost"] == "$180/month"
        assert "보안 그룹 설정 필요" in terraform_result["security_notes"]
        
        # 2. 비용 분석 테스트
        mock_cost_response = {
            "estimated_monthly_cost": "$178.50",
            "cost_breakdown": {
                "compute": "$95",
                "storage": "$45",
                "network": "$25",
                "other": "$13.50"
            },
            "optimization_opportunities": [
                "예약 인스턴스 사용 시 30% 절약 가능",
                "Spot 인스턴스 고려 시 추가 절약"
            ],
            "reserved_instances": ["t3.medium 1년 예약"],
            "auto_scaling_recommendations": ["CPU 사용률 기반 스케일링"],
            "budget_alerts": ["$200 예산 알림 설정"]
        }
        
        self.mock_llm.invoke.return_value = mock_cost_response
        
        cost_result = self.cost_optimizer.analyze_cost(
            "3개 가용영역 VPC, ALB, Auto Scaling Group, RDS Multi-AZ", 
            "aws"
        )
        
        # 검증
        assert cost_result["estimated_monthly_cost"] == "$178.50"
        assert cost_result["cost_breakdown"]["compute"] == "$95"
        assert len(cost_result["optimization_opportunities"]) > 0
        
        # 3. 보안 감사 테스트
        mock_security_response = {
            "security_score": 82,
            "critical_issues": [],
            "high_risk_issues": ["기본 보안 그룹 사용"],
            "medium_risk_issues": ["태그 미설정", "로깅 미설정"],
            "low_risk_issues": ["모니터링 부족"],
            "compliance_check": ["PCI DSS 준수 가능", "SOC 2 준수 가능"],
            "security_recommendations": [
                "보안 그룹 규칙 세분화",
                "IAM 역할 기반 접근 제어",
                "CloudTrail 로깅 활성화"
            ],
            "iam_recommendations": ["최소 권한 원칙 적용", "MFA 활성화"],
            "network_security": ["VPC 엔드포인트 사용", "NACL 설정"]
        }
        
        self.mock_llm.invoke.return_value = mock_security_response
        
        security_result = self.security_auditor.audit_security(
            "3개 가용영역 VPC, ALB, Auto Scaling Group, RDS Multi-AZ", 
            "aws"
        )
        
        # 검증
        assert security_result["security_score"] == 82
        assert len(security_result["critical_issues"]) == 0
        assert "기본 보안 그룹 사용" in security_result["high_risk_issues"]
        assert len(security_result["security_recommendations"]) > 0

class TestUserScenario2_CostOptimization:
    """시나리오 2: 기존 인프라의 비용 최적화 테스트"""
    
    def setup_method(self):
        """테스트 메서드 실행 전 설정"""
        self.mock_llm = Mock()
        self.cost_optimizer = CostOptimizer(self.mock_llm)
    
    def test_existing_infrastructure_cost_optimization(self):
        """기존 인프라 비용 최적화 테스트"""
        
        # 현재 인프라 비용 분석
        mock_current_cost_response = {
            "estimated_monthly_cost": "$487.50",
            "cost_breakdown": {
                "compute": "$250",
                "storage": "$120",
                "network": "$80",
                "other": "$37.50"
            },
            "optimization_opportunities": [
                "예약 인스턴스 사용 시 30% 절약 가능",
                "Auto Scaling 설정 시 20% 절약",
                "S3 Intelligent Tiering 시 20% 절약"
            ],
            "reserved_instances": [
                "t3.medium 1년 예약 (월 $175)",
                "RDS MySQL 1년 예약 (월 $84)"
            ],
            "auto_scaling_recommendations": [
                "CPU 사용률 기반 스케일링",
                "시간대별 스케일링"
            ],
            "budget_alerts": ["$400 예산 알림 설정", "$300 예산 알림 설정"]
        }
        
        self.mock_llm.invoke.return_value = mock_current_cost_response
        
        current_cost_result = self.cost_optimizer.analyze_cost(
            "EC2 인스턴스 5대, RDS MySQL, S3, CloudFront", 
            "aws"
        )
        
        # 검증
        assert current_cost_result["estimated_monthly_cost"] == "$487.50"
        assert current_cost_result["cost_breakdown"]["compute"] == "$250"
        assert len(current_cost_result["optimization_opportunities"]) >= 3
        
        # 최적화 후 비용 분석
        mock_optimized_cost_response = {
            "estimated_monthly_cost": "$289.50",
            "cost_breakdown": {
                "compute": "$175",
                "storage": "$84",
                "network": "$20",
                "other": "$10.50"
            },
            "optimization_opportunities": ["추가 최적화 여지 있음"],
            "reserved_instances": ["모든 인스턴스 예약 완료"],
            "auto_scaling_recommendations": ["Auto Scaling 완벽 설정"],
            "budget_alerts": ["$300 예산 알림 설정"]
        }
        
        self.mock_llm.invoke.return_value = mock_optimized_cost_response
        
        optimized_cost_result = self.cost_optimizer.analyze_cost(
            "예약 인스턴스 + Auto Scaling + Intelligent Tiering 적용", 
            "aws"
        )
        
        # 검증
        assert optimized_cost_result["estimated_monthly_cost"] == "$289.50"
        savings = float(current_cost_result["estimated_monthly_cost"].replace("$", "")) - \
                 float(optimized_cost_result["estimated_monthly_cost"].replace("$", ""))
        assert savings >= 150  # 최소 $150 절약 확인

class TestUserScenario3_SecurityCompliance:
    """시나리오 3: 보안 강화 및 규정 준수 테스트"""
    
    def setup_method(self):
        """테스트 메서드 실행 전 설정"""
        self.mock_llm = Mock()
        self.security_auditor = SecurityAuditor(self.mock_llm)
    
    def test_pci_dss_compliance_audit(self):
        """PCI DSS 규정 준수 보안 감사 테스트"""
        
        # 초기 보안 감사
        mock_initial_security_response = {
            "security_score": 65,
            "critical_issues": [
                "RDS 퍼블릭 액세스 허용",
                "S3 버킷 퍼블릭 읽기 권한"
            ],
            "high_risk_issues": [
                "기본 보안 그룹 사용",
                "IAM 사용자 직접 권한 부여"
            ],
            "medium_risk_issues": [
                "CloudTrail 로깅 미설정",
                "WAF 미설정"
            ],
            "low_risk_issues": [
                "태그 미설정",
                "모니터링 부족"
            ],
            "compliance_check": [
                "PCI DSS: ❌ 네트워크 보안 부족",
                "PCI DSS: ❌ 접근 제어 미흡",
                "PCI DSS: ❌ 데이터 보호 부족"
            ],
            "security_recommendations": [
                "VPC 엔드포인트 설정",
                "보안 그룹 규칙 세분화",
                "WAF 설정"
            ],
            "iam_recommendations": [
                "IAM 역할 기반 접근 제어",
                "MFA 활성화",
                "최소 권한 원칙 적용"
            ],
            "network_security": [
                "VPC 엔드포인트 사용",
                "NACL 설정",
                "VPN 연결 설정"
            ]
        }
        
        self.mock_llm.invoke.return_value = mock_initial_security_response
        
        initial_security_result = self.security_auditor.audit_security(
            "고객 결제 정보 처리 웹 애플리케이션, EC2, RDS, S3", 
            "aws"
        )
        
        # 검증
        assert initial_security_result["security_score"] == 65
        assert len(initial_security_result["critical_issues"]) >= 2
        assert "PCI DSS" in str(initial_security_result["compliance_check"])
        
        # 보안 강화 후 감사
        mock_improved_security_response = {
            "security_score": 92,
            "critical_issues": [],
            "high_risk_issues": [],
            "medium_risk_issues": [
                "일부 태그 미설정"
            ],
            "low_risk_issues": [
                "모니터링 강화 여지"
            ],
            "compliance_check": [
                "PCI DSS: ✅ 네트워크 보안 완료",
                "PCI DSS: ✅ 접근 제어 완료",
                "PCI DSS: ✅ 데이터 보호 완료"
            ],
            "security_recommendations": [
                "정기적인 보안 감사",
                "자동화된 모니터링"
            ],
            "iam_recommendations": [
                "정기적인 권한 검토",
                "접근 로그 모니터링"
            ],
            "network_security": [
                "정기적인 보안 그룹 검토",
                "트래픽 패턴 분석"
            ]
        }
        
        self.mock_llm.invoke.return_value = mock_improved_security_response
        
        improved_security_result = self.security_auditor.audit_security(
            "보안 강화 완료된 인프라: VPC 엔드포인트, WAF, IAM 역할, 암호화", 
            "aws"
        )
        
        # 검증
        assert improved_security_result["security_score"] == 92
        assert len(improved_security_result["critical_issues"]) == 0
        assert len(improved_security_result["high_risk_issues"]) == 0
        assert "✅" in str(improved_security_result["compliance_check"])
        
        # 보안 점수 향상 확인
        score_improvement = improved_security_result["security_score"] - initial_security_result["security_score"]
        assert score_improvement >= 25  # 최소 25점 향상

class TestUserScenario4_MultiCloudStrategy:
    """시나리오 4: 멀티 클라우드 전략 수립 테스트"""
    
    def setup_method(self):
        """테스트 메서드 실행 전 설정"""
        self.mock_llm = Mock()
        self.terraform_generator = TerraformCodeGenerator(self.mock_llm)
        self.cost_optimizer = CostOptimizer(self.mock_llm)
        self.security_auditor = SecurityAuditor(self.mock_llm)
    
    def test_multi_cloud_strategy_planning(self):
        """멀티 클라우드 전략 수립 테스트"""
        
        # AWS 인프라 설계
        mock_aws_response = {
            "main_tf": """
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = { Name = "web-app-vpc" }
}

resource "aws_ec2" "web" {
  instance_type = "t3.medium"
  ami = "ami-12345"
}
            """,
            "variables_tf": "variable \"region\" { type = string }",
            "outputs_tf": "output \"vpc_id\" { value = aws_vpc.main.id }",
            "description": "웹 애플리케이션 및 데이터베이스",
            "estimated_cost": "$320/month",
            "security_notes": "보안 그룹 설정 완료",
            "best_practices": "모니터링 및 백업 설정"
        }
        
        self.mock_llm.invoke.return_value = mock_aws_response
        
        aws_result = self.terraform_generator.generate_code(
            "웹 애플리케이션과 데이터베이스를 위한 AWS 인프라", 
            "aws"
        )
        
        # 검증
        assert "aws_vpc" in aws_result["main_tf"]
        assert aws_result["estimated_cost"] == "$320/month"
        
        # GCP 인프라 설계
        mock_gcp_response = {
            "main_tf": """
resource "google_compute_instance" "ai" {
  name = "ai-training-instance"
  machine_type = "n1-standard-4"
  zone = "us-central1-a"
}

resource "google_bigquery_dataset" "analytics" {
  dataset_id = "web_analytics"
  location = "US"
}
            """,
            "variables_tf": "variable \"project_id\" { type = string }",
            "outputs_tf": "output \"instance_name\" { value = google_compute_instance.ai.name }",
            "description": "AI/ML 서비스 및 데이터 분석",
            "estimated_cost": "$280/month",
            "security_notes": "IAM 정책 설정 완료",
            "best_practices": "데이터 암호화 및 접근 제어"
        }
        
        self.mock_llm.invoke.return_value = mock_gcp_response
        
        gcp_result = self.terraform_generator.generate_code(
            "AI/ML 서비스와 데이터 분석을 위한 GCP 인프라", 
            "gcp"
        )
        
        # 검증
        assert "google_compute_instance" in gcp_result["main_tf"]
        assert gcp_result["estimated_cost"] == "$280/month"
        
        # 통합 비용 분석
        mock_integrated_cost_response = {
            "estimated_monthly_cost": "$650/month",
            "cost_breakdown": {
                "aws": "$320",
                "gcp": "$280",
                "connection": "$50"
            },
            "optimization_opportunities": [
                "예약 인스턴스 사용",
                "Spot 인스턴스 활용",
                "데이터 전송 최적화"
            ],
            "reserved_instances": [
                "AWS EC2 1년 예약",
                "GCP Compute Engine 1년 예약"
            ],
            "auto_scaling_recommendations": [
                "AWS Auto Scaling Group",
                "GCP Managed Instance Group"
            ],
            "budget_alerts": ["$700 예산 알림 설정"]
        }
        
        self.mock_llm.invoke.return_value = mock_integrated_cost_response
        
        integrated_cost_result = self.cost_optimizer.analyze_cost(
            "AWS 웹 애플리케이션 + GCP AI/ML 서비스 + 클라우드 간 연결", 
            "multi"
        )
        
        # 검증
        assert integrated_cost_result["estimated_monthly_cost"] == "$650/month"
        assert integrated_cost_result["cost_breakdown"]["aws"] == "$320"
        assert integrated_cost_result["cost_breakdown"]["gcp"] == "$280"
        
        # 통합 보안 감사
        mock_integrated_security_response = {
            "security_score": 88,
            "critical_issues": [],
            "high_risk_issues": ["클라우드 간 통신 암호화 강화 필요"],
            "medium_risk_issues": ["통합 모니터링 설정"],
            "low_risk_issues": ["태그 정책 통일"],
            "compliance_check": [
                "SOC 2: ✅ 준수",
                "ISO 27001: ✅ 준수",
                "GDPR: ✅ 준수"
            ],
            "security_recommendations": [
                "클라우드 간 VPN 연결",
                "통합 IAM 정책",
                "중앙화된 로깅"
            ],
            "iam_recommendations": [
                "SSO 설정",
                "역할 기반 접근 제어",
                "정기적인 권한 검토"
            ],
            "network_security": [
                "VPN 연결 암호화",
                "방화벽 규칙 통일",
                "트래픽 모니터링"
            ]
        }
        
        self.mock_llm.invoke.return_value = mock_integrated_security_response
        
        integrated_security_result = self.security_auditor.audit_security(
            "AWS + GCP 멀티 클라우드 환경, VPN 연결, 통합 IAM", 
            "multi"
        )
        
        # 검증
        assert integrated_security_result["security_score"] == 88
        assert len(integrated_security_result["critical_issues"]) == 0
        assert "클라우드 간 VPN 연결" in integrated_security_result["security_recommendations"]

class TestUserScenario5_DeveloperEducation:
    """시나리오 5: 개발자 교육 및 학습 테스트"""
    
    def setup_method(self):
        """테스트 메서드 실행 전 설정"""
        self.mock_llm = Mock()
        self.rag_service = Mock()
        self.rag_service.query.return_value = "VPC는 가상의 사설 네트워크입니다."
    
    def test_developer_learning_workflow(self):
        """개발자 학습 워크플로우 테스트"""
        
        # 1. 기초 개념 학습 테스트
        basic_concept_response = self.rag_service.query("VPC가 뭔지 잘 모르겠어요.")
        
        # 검증
        assert "VPC" in basic_concept_response
        assert "가상" in basic_concept_response
        
        # 2. 실습 가이드 테스트
        practice_guide_response = self.rag_service.query("VPC 실습을 진행해보겠습니다.")
        
        # 검증
        assert practice_guide_response is not None
        
        # 3. 심화 학습 테스트
        advanced_learning_response = self.rag_service.query("보안 그룹은 어떻게 설정하나요?")
        
        # 검증
        assert advanced_learning_response is not None

class TestUserScenarioIntegration:
    """사용자 시나리오 통합 테스트"""
    
    @patch('backend.rag_service.RAGService')
    def test_complete_user_journey(self, mock_rag_service):
        """완전한 사용자 여정 통합 테스트"""
        
        # Mock RAG 서비스 설정
        mock_instance = Mock()
        mock_rag_service.return_value = mock_instance
        
        # 시나리오 1: 신규 팀 인프라 설계
        mock_instance.generate_terraform_code.return_value = {
            "main_tf": "resource \"aws_vpc\" \"main\" { cidr_block = \"10.0.0.0/16\" }",
            "estimated_cost": "$180/month"
        }
        
        terraform_result = mock_instance.generate_terraform_code("웹 애플리케이션 인프라", "aws")
        assert "aws_vpc" in terraform_result["main_tf"]
        
        # 시나리오 2: 비용 최적화
        mock_instance.analyze_cost.return_value = {
            "estimated_monthly_cost": "$289.50",
            "optimization_opportunities": ["예약 인스턴스 사용"]
        }
        
        cost_result = mock_instance.analyze_cost("최적화된 인프라", "aws")
        assert cost_result["estimated_monthly_cost"] == "$289.50"
        
        # 시나리오 3: 보안 감사
        mock_instance.audit_security.return_value = {
            "security_score": 92,
            "security_recommendations": ["보안 그룹 강화"]
        }
        
        security_result = mock_instance.audit_security("보안 강화된 인프라", "aws")
        assert security_result["security_score"] == 92
        
        # 시나리오 4: 멀티 클라우드
        mock_instance.generate_terraform_code.return_value = {
            "main_tf": "resource \"google_compute_instance\" \"ai\" { machine_type = \"n1-standard-4\" }",
            "estimated_cost": "$280/month"
        }
        
        gcp_result = mock_instance.generate_terraform_code("AI 서비스", "gcp")
        assert "google_compute_instance" in gcp_result["main_tf"]
        
        # 시나리오 5: 교육
        mock_instance.query.return_value = "VPC는 가상의 사설 네트워크입니다."
        
        education_result = mock_instance.query("VPC란 무엇인가요?")
        assert "VPC" in education_result
        
        # 전체 워크플로우 검증
        assert mock_instance.generate_terraform_code.call_count >= 2
        assert mock_instance.analyze_cost.call_count >= 1
        assert mock_instance.audit_security.call_count >= 1
        assert mock_instance.query.call_count >= 1

if __name__ == "__main__":
    pytest.main([__file__, "-v"])
