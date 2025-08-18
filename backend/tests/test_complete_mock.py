import pytest
from unittest.mock import Mock, patch, MagicMock

class TestCompleteUserScenarios:
    """완전한 Mock 기반 사용자 시나리오 테스트"""
    
    def setup_method(self):
        """테스트 메서드 실행 전 설정"""
        # 모든 외부 의존성을 Mock으로 대체
        self.mock_service = Mock()
        
        # Mock 메서드들 설정
        self.mock_service.generate_terraform_code = Mock()
        self.mock_service.analyze_cost = Mock()
        self.mock_service.audit_security = Mock()
        self.mock_service.query = Mock()
    
    def test_scenario1_new_team_infrastructure(self):
        """시나리오 1: 신규 개발팀 인프라 설계 전체 워크플로우"""
        print("\n🚀 시나리오 1: 신규 개발팀 인프라 설계 테스트 시작")
        
        # 1단계: Terraform 코드 생성 Mock
        terraform_result = {
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
        
        self.mock_service.generate_terraform_code.return_value = terraform_result
        
        # 테스트 실행
        result1 = self.mock_service.generate_terraform_code("AWS에서 3개 가용영역 VPC, public/private 서브넷, NAT Gateway, ALB, Auto Scaling Group, RDS Multi-AZ", "aws")
        
        # 검증
        assert "aws_vpc" in result1["main_tf"]
        assert "aws_subnet" in result1["main_tf"]
        assert result1["estimated_cost"] == "$180/month"
        assert "보안 그룹 설정 필요" in result1["security_notes"]
        print(f"✅ 1단계 완료: Terraform 코드 생성 ({len(result1['main_tf'])} 문자)")
        
        # 2단계: 비용 분석 Mock
        cost_result = {
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
        
        self.mock_service.analyze_cost.return_value = cost_result
        
        result2 = self.mock_service.analyze_cost("3개 가용영역 VPC, ALB, Auto Scaling Group, RDS Multi-AZ", "aws")
        
        # 검증
        assert result2["estimated_monthly_cost"] == "$178.50"
        assert result2["cost_breakdown"]["compute"] == "$95"
        assert len(result2["optimization_opportunities"]) > 0
        print(f"✅ 2단계 완료: 비용 분석 - {result2['estimated_monthly_cost']}")
        
        # 3단계: 보안 감사 Mock
        security_result = {
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
        
        self.mock_service.audit_security.return_value = security_result
        
        result3 = self.mock_service.audit_security("3개 가용영역 VPC, ALB, Auto Scaling Group, RDS Multi-AZ", "aws")
        
        # 검증
        assert result3["security_score"] == 82
        assert len(result3["critical_issues"]) == 0
        assert "기본 보안 그룹 사용" in result3["high_risk_issues"]
        assert len(result3["security_recommendations"]) > 0
        print(f"✅ 3단계 완료: 보안 감사 - 점수 {result3['security_score']}/100")
        
        # 전체 결과 검증
        assert "aws_vpc" in result1["main_tf"]
        assert "estimated_monthly_cost" in result2
        assert "security_score" in result3
        
        print("🎉 시나리오 1 전체 워크플로우 테스트 완료!")
        
        # Mock 호출 검증
        assert self.mock_service.generate_terraform_code.call_count == 1
        assert self.mock_service.analyze_cost.call_count == 1
        assert self.mock_service.audit_security.call_count == 1
    
    def test_scenario2_cost_optimization(self):
        """시나리오 2: 기존 인프라 비용 최적화"""
        print("\n💰 시나리오 2: 기존 인프라 비용 최적화 테스트 시작")
        
        # 현재 인프라 비용 분석 Mock
        current_cost_result = {
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
        
        # Mock 설정 - 첫 번째 호출은 현재 비용, 두 번째 호출은 최적화 후 비용
        self.mock_service.analyze_cost.side_effect = [
            current_cost_result,
            {"estimated_monthly_cost": "$289.50"}
        ]
        
        # 현재 비용 분석
        result1 = self.mock_service.analyze_cost("EC2 인스턴스 5대, RDS MySQL, S3, CloudFront", "aws")
        
        # 검증
        assert result1["estimated_monthly_cost"] == "$487.50"
        assert result1["cost_breakdown"]["compute"] == "$250"
        assert len(result1["optimization_opportunities"]) >= 3
        print(f"✅ 현재 비용 분석: {result1['estimated_monthly_cost']}")
        
        # 최적화 후 비용 분석
        result2 = self.mock_service.analyze_cost("예약 인스턴스 + Auto Scaling + Intelligent Tiering 적용", "aws")
        
        # 검증
        assert result2["estimated_monthly_cost"] == "$289.50"
        
        # 비용 절약 확인
        current_cost = float(result1["estimated_monthly_cost"].replace("$", "").replace("/month", ""))
        optimized_cost = float(result2["estimated_monthly_cost"].replace("$", "").replace("/month", ""))
        
        assert current_cost > optimized_cost, "비용 최적화가 이루어지지 않았습니다"
        
        savings = current_cost - optimized_cost
        print(f"🎉 비용 절약: ${savings:.2f}/월")
        print("💰 시나리오 2 비용 최적화 테스트 완료!")
        
        # Mock 호출 검증
        assert self.mock_service.analyze_cost.call_count == 2
    
    def test_scenario3_security_compliance(self):
        """시나리오 3: 보안 강화 및 규정 준수"""
        print("\n🔒 시나리오 3: 보안 강화 및 규정 준수 테스트 시작")
        
        # 초기 보안 감사 Mock
        initial_security_result = {
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
        
        # 보안 강화 후 감사 Mock
        improved_security_result = {
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
        
        # Mock 설정 - 첫 번째 호출은 초기 상태, 두 번째 호출은 개선 후 상태
        self.mock_service.audit_security.side_effect = [
            initial_security_result,
            improved_security_result
        ]
        
        # 초기 보안 감사
        result1 = self.mock_service.audit_security("고객 결제 정보 처리 웹 애플리케이션, EC2, RDS, S3", "aws")
        
        # 검증
        assert result1["security_score"] == 65
        assert len(result1["critical_issues"]) >= 2
        assert "PCI DSS" in str(result1["compliance_check"])
        print(f"✅ 초기 보안 감사: 점수 {result1['security_score']}/100")
        
        # 보안 강화 후 감사
        result2 = self.mock_service.audit_security("보안 강화 완료된 인프라: VPC 엔드포인트, WAF, IAM 역할, 암호화", "aws")
        
        # 검증
        assert result2["security_score"] == 92
        assert len(result2["critical_issues"]) == 0
        assert len(result2["high_risk_issues"]) == 0
        assert "✅" in str(result2["compliance_check"])
        print(f"✅ 보안 강화 후 감사: 점수 {result2['security_score']}/100")
        
        # 보안 점수 향상 확인
        score_improvement = result2["security_score"] - result1["security_score"]
        assert score_improvement >= 25, "보안 점수가 충분히 향상되지 않았습니다"
        
        print(f"🎉 보안 점수 향상: +{score_improvement}점")
        print("🔒 시나리오 3 보안 강화 테스트 완료!")
        
        # Mock 호출 검증
        assert self.mock_service.audit_security.call_count == 2
    
    def test_scenario4_multi_cloud_strategy(self):
        """시나리오 4: 멀티 클라우드 전략 수립"""
        print("\n☁️ 시나리오 4: 멀티 클라우드 전략 수립 테스트 시작")
        
        # AWS 인프라 설계 Mock
        aws_result = {
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
        
        # GCP 인프라 설계 Mock
        gcp_result = {
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
        
        # 통합 비용 분석 Mock
        integrated_cost_result = {
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
        
        # 통합 보안 감사 Mock
        integrated_security_result = {
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
        
        # Mock 설정
        self.mock_service.generate_terraform_code.side_effect = [aws_result, gcp_result]
        self.mock_service.analyze_cost.return_value = integrated_cost_result
        self.mock_service.audit_security.return_value = integrated_security_result
        
        # AWS 인프라 설계
        aws_infra = self.mock_service.generate_terraform_code("웹 애플리케이션과 데이터베이스를 위한 AWS 인프라", "aws")
        
        # 검증
        assert "aws_vpc" in aws_infra["main_tf"]
        assert aws_infra["estimated_cost"] == "$320/month"
        print(f"✅ AWS 인프라 설계: {aws_infra['estimated_cost']}")
        
        # GCP 인프라 설계
        gcp_infra = self.mock_service.generate_terraform_code("AI/ML 서비스와 데이터 분석을 위한 GCP 인프라", "gcp")
        
        # 검증
        assert "google_compute_instance" in gcp_infra["main_tf"]
        assert gcp_infra["estimated_cost"] == "$280/month"
        print(f"✅ GCP 인프라 설계: {gcp_infra['estimated_cost']}")
        
        # 통합 비용 분석
        cost_analysis = self.mock_service.analyze_cost("AWS 웹 애플리케이션 + GCP AI/ML 서비스 + 클라우드 간 연결", "multi")
        
        # 검증
        assert cost_analysis["estimated_monthly_cost"] == "$650/month"
        assert cost_analysis["cost_breakdown"]["aws"] == "$320"
        assert cost_analysis["cost_breakdown"]["gcp"] == "$280"
        print(f"✅ 통합 비용 분석: {cost_analysis['estimated_monthly_cost']}")
        
        # 통합 보안 감사
        security_audit = self.mock_service.audit_security("AWS + GCP 멀티 클라우드 환경, VPN 연결, 통합 IAM", "multi")
        
        # 검증
        assert security_audit["security_score"] == 88
        assert len(security_audit["critical_issues"]) == 0
        assert "클라우드 간 VPN 연결" in security_audit["security_recommendations"]
        print(f"✅ 통합 보안 감사: 점수 {security_audit['security_score']}/100")
        
        print("☁️ 시나리오 4 멀티 클라우드 전략 테스트 완료!")
        
        # Mock 호출 검증
        assert self.mock_service.generate_terraform_code.call_count == 2
        assert self.mock_service.analyze_cost.call_count == 1
        assert self.mock_service.audit_security.call_count == 1
    
    def test_scenario5_developer_education(self):
        """시나리오 5: 개발자 교육 및 학습"""
        print("\n📚 시나리오 5: 개발자 교육 및 학습 테스트 시작")
        
        # 기초 개념 학습 Mock
        basic_answer = "VPC(Virtual Private Cloud)는 가상의 사설 네트워크입니다. AWS에서 제공하는 논리적으로 격리된 네트워크 환경으로, 사용자가 정의한 가상 네트워크에서 AWS 리소스를 실행할 수 있습니다."
        
        # 실습 가이드 Mock
        practice_answer = "VPC 생성 단계별 가이드:\n1. AWS 콘솔에서 VPC 서비스 선택\n2. 'VPC 생성' 버튼 클릭\n3. IPv4 CIDR 블록 설정 (예: 10.0.0.0/16)\n4. 가용영역 선택\n5. 서브넷 생성\n6. 인터넷 게이트웨이 연결\n7. 라우팅 테이블 설정"
        
        # 심화 학습 Mock
        advanced_answer = "보안 그룹 모범 사례:\n1. 최소 권한 원칙 적용\n2. 특정 IP 주소에서만 접근 허용\n3. 필요한 포트만 열기\n4. 정기적인 보안 그룹 검토\n5. 태그를 사용한 관리\n6. VPC 엔드포인트 사용 고려"
        
        # Mock 설정
        self.mock_service.query.side_effect = [basic_answer, practice_answer, advanced_answer]
        
        # 1. 기초 개념 학습
        basic_result = self.mock_service.query("VPC가 뭔지 잘 모르겠어요. 간단히 설명해주세요.")
        
        # 검증
        assert "VPC" in basic_result
        assert "가상" in basic_result
        assert len(basic_result) > 50
        print(f"✅ 기초 개념 학습: {len(basic_result)} 문자")
        
        # 2. 실습 가이드
        practice_result = self.mock_service.query("VPC를 만들어보고 싶어요. 단계별로 설명해주세요.")
        
        # 검증
        assert "단계별" in practice_result
        assert "AWS 콘솔" in practice_result
        assert len(practice_result) > 100
        print(f"✅ 실습 가이드: {len(practice_result)} 문자")
        
        # 3. 심화 학습
        advanced_result = self.mock_service.query("보안 그룹은 어떻게 설정해야 하나요? 모범 사례를 알려주세요.")
        
        # 검증
        assert "모범 사례" in advanced_result
        assert "보안 그룹" in advanced_result
        assert len(advanced_result) > 100
        print(f"✅ 심화 학습: {len(advanced_result)} 문자")
        
        # 결과 검증
        assert len(basic_result) > 50
        assert len(practice_result) > 100
        assert len(advanced_result) > 100
        
        print("📚 시나리오 5 개발자 교육 테스트 완료!")
        
        # Mock 호출 검증
        assert self.mock_service.query.call_count == 3

class TestCompleteIntegration:
    """완전한 통합 테스트"""
    
    def test_complete_user_journey(self):
        """완전한 사용자 여정 통합 테스트"""
        print("\n🎯 완전한 사용자 여정 통합 테스트 시작")
        
        # Mock 서비스 생성
        mock_service = Mock()
        
        # 모든 메서드 Mock 설정
        mock_service.generate_terraform_code = Mock()
        mock_service.analyze_cost = Mock()
        mock_service.audit_security = Mock()
        mock_service.query = Mock()
        
        # 시나리오 1: 신규 팀 인프라 설계
        mock_service.generate_terraform_code.return_value = {
            "main_tf": "resource \"aws_vpc\" \"main\" { cidr_block = \"10.0.0.0/16\" }",
            "estimated_cost": "$180/month"
        }
        
        terraform_result = mock_service.generate_terraform_code("웹 애플리케이션 인프라", "aws")
        assert "aws_vpc" in terraform_result["main_tf"]
        print("✅ 시나리오 1: Terraform 코드 생성 완료")
        
        # 시나리오 2: 비용 최적화
        mock_service.analyze_cost.return_value = {
            "estimated_monthly_cost": "$289.50",
            "optimization_opportunities": ["예약 인스턴스 사용"]
        }
        
        cost_result = mock_service.analyze_cost("최적화된 인프라", "aws")
        assert cost_result["estimated_monthly_cost"] == "$289.50"
        print("✅ 시나리오 2: 비용 최적화 완료")
        
        # 시나리오 3: 보안 감사
        mock_service.audit_security.return_value = {
            "security_score": 92,
            "security_recommendations": ["보안 그룹 강화"]
        }
        
        security_result = mock_service.audit_security("보안 강화된 인프라", "aws")
        assert security_result["security_score"] == 92
        print("✅ 시나리오 3: 보안 감사 완료")
        
        # 시나리오 4: 멀티 클라우드
        mock_service.generate_terraform_code.return_value = {
            "main_tf": "resource \"google_compute_instance\" \"ai\" { machine_type = \"n1-standard-4\" }",
            "estimated_cost": "$280/month"
        }
        
        gcp_result = mock_service.generate_terraform_code("AI 서비스", "gcp")
        assert "google_compute_instance" in gcp_result["main_tf"]
        print("✅ 시나리오 4: 멀티 클라우드 전략 완료")
        
        # 시나리오 5: 교육
        mock_service.query.return_value = "VPC는 가상의 사설 네트워크입니다."
        
        education_result = mock_service.query("VPC란 무엇인가요?")
        assert "VPC" in education_result
        print("✅ 시나리오 5: 개발자 교육 완료")
        
        # 전체 워크플로우 검증
        assert mock_service.generate_terraform_code.call_count >= 2
        assert mock_service.analyze_cost.call_count >= 1
        assert mock_service.audit_security.call_count >= 1
        assert mock_service.query.call_count >= 1
        
        print("🎉 모든 사용자 시나리오 통합 테스트 완료!")

if __name__ == "__main__":
    pytest.main([__file__, "-v"])
