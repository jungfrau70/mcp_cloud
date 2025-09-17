#!/usr/bin/env python3
"""
Day별 README 사용자 친화성 개선
"""

import os
import re
from pathlib import Path
from typing import Dict, List

class DayREADMEImprover:
    def __init__(self, knowledge_base_path: str = "mcp_knowledge_base"):
        self.knowledge_base_path = Path(knowledge_base_path)
        self.courses = ['cloud_basic', 'cloud_master', 'cloud_container']
        
    def improve_cloud_basic_day1_readme(self):
        """Cloud Basic Day1 README 개선"""
        readme_path = self.knowledge_base_path / 'cloud_basic' / 'textbook' / 'Day1' / 'README.md'
        
        if not readme_path.exists():
            print("❌ Cloud Basic Day1 README 파일을 찾을 수 없습니다.")
            return
        
        try:
            with open(readme_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            # 기존 내용을 개선된 버전으로 교체
            improved_content = """# 📅 Day 1: AWS & GCP 기초 서비스 실습

## 🎯 학습 목표

오늘은 클라우드 컴퓨팅의 기본 개념을 이해하고, AWS와 GCP의 핵심 서비스를 직접 실습해보겠습니다. 
이 과정을 완료하면 클라우드 서비스의 기본 사용법을 익히고, 실제 프로젝트에서 바로 활용할 수 있는 기초 역량을 갖추게 됩니다.

### 📋 구체적인 학습 목표
- **클라우드 기본 개념 이해**: 클라우드 컴퓨팅의 핵심 개념과 장점을 설명할 수 있습니다
- **AWS 계정 생성 및 설정**: AWS 계정을 생성하고 기본 보안 설정을 완료할 수 있습니다
- **GCP 계정 생성 및 설정**: GCP 계정을 생성하고 프로젝트를 설정할 수 있습니다
- **EC2 인스턴스 관리**: EC2 인스턴스를 생성, 연결, 관리할 수 있습니다
- **S3 스토리지 활용**: S3 버킷을 생성하고 파일을 업로드/다운로드할 수 있습니다
- **Compute Engine 사용**: GCP Compute Engine 인스턴스를 생성하고 관리할 수 있습니다
- **Cloud Storage 활용**: GCP Cloud Storage를 사용하여 파일을 저장하고 관리할 수 있습니다

## ⏱️ 예상 소요시간

- **이론 학습**: 2시간 (클라우드 개념, 서비스 소개)
- **실습**: 5시간 (계정 생성, 서비스 실습)
- **정리 및 문제해결**: 1시간
- **총 소요시간**: 8시간

## 📚 학습 순서

### 🌅 오전 (4시간)

#### 1단계: 클라우드 기본 개념 이해 (1시간)
- [클라우드 컴퓨팅 개념](/mcp_knowledge_base/cloud_basic/textbook/Day1/aws-gcp-account-setup.md#클라우드-기본-개념)
- [AWS 서비스 개요](/mcp_knowledge_base/cloud_basic/textbook/Day1/aws-gcp-account-setup.md#aws-서비스-개요)
- [GCP 서비스 개요](/mcp_knowledge_base/cloud_basic/textbook/Day1/aws-gcp-account-setup.md#gcp-서비스-개요)

#### 2단계: AWS 계정 생성 및 설정 (1시간)
- [AWS 계정 생성](/mcp_knowledge_base/cloud_basic/accounts/AWS계정가입.md)
- [AWS CLI 설치 및 설정](/mcp_knowledge_base/cloud_basic/install/install_aws_cli.md)
- [기본 보안 설정](/mcp_knowledge_base/cloud_basic/textbook/Day1/iam-basics-guide.md)

#### 3단계: GCP 계정 생성 및 설정 (1시간)
- [GCP 계정 생성](/mcp_knowledge_base/cloud_basic/accounts/GCP_개인계정가입.md)
- [GCP CLI 설치 및 설정](/mcp_knowledge_base/cloud_basic/install/install_gcp_cli.md)
- [프로젝트 설정](/mcp_knowledge_base/cloud_basic/textbook/Day1/aws-gcp-account-setup.md#gcp-프로젝트-설정)

#### 4단계: 기본 실습 환경 확인 (1시간)
- [환경 설정 확인](/mcp_knowledge_base/cloud_basic/textbook/Day1/aws-gcp-account-setup.md#환경-설정-확인)
- [연결 테스트](/mcp_knowledge_base/cloud_basic/textbook/Day1/aws-gcp-account-setup.md#연결-테스트)

### 🌆 오후 (4시간)

#### 5단계: AWS EC2 실습 (1시간)
- [EC2 인스턴스 생성](/mcp_knowledge_base/cloud_basic/textbook/Day1/vm-services-guide.md#ec2-인스턴스-생성)
- [SSH 연결](/mcp_knowledge_base/cloud_basic/textbook/Day1/vm-services-guide.md#ssh-연결)
- [기본 명령어 실행](/mcp_knowledge_base/cloud_basic/textbook/Day1/vm-services-guide.md#기본-명령어-실행)

#### 6단계: AWS S3 실습 (1시간)
- [S3 버킷 생성](/mcp_knowledge_base/cloud_basic/textbook/Day1/storage-services-guide.md#s3-버킷-생성)
- [파일 업로드/다운로드](/mcp_knowledge_base/cloud_basic/textbook/Day1/storage-services-guide.md#파일-업로드다운로드)
- [권한 설정](/mcp_knowledge_base/cloud_basic/textbook/Day1/storage-services-guide.md#권한-설정)

#### 7단계: GCP Compute Engine 실습 (1시간)
- [Compute Engine 인스턴스 생성](/mcp_knowledge_base/cloud_basic/textbook/Day1/vm-services-guide.md#compute-engine-인스턴스-생성)
- [SSH 연결](/mcp_knowledge_base/cloud_basic/textbook/Day1/vm-services-guide.md#gcp-ssh-연결)
- [기본 명령어 실행](/mcp_knowledge_base/cloud_basic/textbook/Day1/vm-services-guide.md#gcp-기본-명령어-실행)

#### 8단계: GCP Cloud Storage 실습 (1시간)
- [Cloud Storage 버킷 생성](/mcp_knowledge_base/cloud_basic/textbook/Day1/storage-services-guide.md#cloud-storage-버킷-생성)
- [파일 업로드/다운로드](/mcp_knowledge_base/cloud_basic/textbook/Day1/storage-services-guide.md#gcp-파일-업로드다운로드)
- [권한 설정](/mcp_knowledge_base/cloud_basic/textbook/Day1/storage-services-guide.md#gcp-권한-설정)

## 💻 실습 가이드

### 🔧 필수 도구 설치
실습을 시작하기 전에 다음 도구들을 설치해주세요:

1. **AWS CLI 설치**
   ```bash
   # Windows
   # https://aws.amazon.com/cli/ 에서 다운로드
   
   # 설치 확인
   aws --version
   ```

2. **GCP CLI 설치**
   ```bash
   # Windows
   # https://cloud.google.com/sdk/docs/install 에서 다운로드
   
   # 설치 확인
   gcloud --version
   ```

3. **SSH 클라이언트**
   - Windows: PuTTY 또는 Windows Terminal
   - Mac: 기본 터미널
   - Linux: 기본 터미널

### 📝 실습 체크리스트

#### AWS 실습 체크리스트
- [ ] AWS 계정 생성 완료
- [ ] AWS CLI 설치 및 설정 완료
- [ ] EC2 인스턴스 생성 성공
- [ ] SSH 연결 성공
- [ ] S3 버킷 생성 성공
- [ ] 파일 업로드/다운로드 성공

#### GCP 실습 체크리스트
- [ ] GCP 계정 생성 완료
- [ ] GCP CLI 설치 및 설정 완료
- [ ] Compute Engine 인스턴스 생성 성공
- [ ] SSH 연결 성공
- [ ] Cloud Storage 버킷 생성 성공
- [ ] 파일 업로드/다운로드 성공

## ✅ 완료 확인

### 🎯 학습 목표 달성 확인
다음 질문들에 답할 수 있다면 학습 목표를 달성한 것입니다:

1. **클라우드 기본 개념**
   - 클라우드 컴퓨팅이 무엇인지 설명할 수 있나요?
   - AWS와 GCP의 주요 차이점을 설명할 수 있나요?

2. **계정 관리**
   - AWS 계정을 생성하고 기본 설정을 완료했나요?
   - GCP 계정을 생성하고 프로젝트를 설정했나요?

3. **서비스 사용**
   - EC2 인스턴스를 생성하고 연결할 수 있나요?
   - S3 버킷을 생성하고 파일을 업로드할 수 있나요?
   - Compute Engine 인스턴스를 생성하고 연결할 수 있나요?
   - Cloud Storage 버킷을 생성하고 파일을 업로드할 수 있나요?

### 📊 실습 결과 확인
- **AWS 실습**: 모든 체크리스트 항목 완료
- **GCP 실습**: 모든 체크리스트 항목 완료
- **문제해결**: 발생한 문제를 스스로 해결했나요?

## 🔧 문제해결

### 자주 발생하는 문제들

#### 1. AWS 계정 생성 문제
**문제**: 신용카드 정보 입력 시 오류 발생
**해결**: 
- 카드 정보를 정확히 입력했는지 확인
- 카드가 해외 결제가 가능한지 확인
- AWS 지원팀에 문의

#### 2. SSH 연결 실패
**문제**: EC2 인스턴스에 SSH 연결이 안됨
**해결**:
- 보안 그룹에서 SSH(22번 포트) 허용 확인
- 키 페어 파일 권한 확인 (Windows: 600, Mac/Linux: chmod 400)
- 인스턴스 상태 확인 (running 상태여야 함)

#### 3. GCP 프로젝트 설정 문제
**문제**: GCP 프로젝트 생성 후 CLI에서 인식하지 못함
**해결**:
- `gcloud auth login` 실행
- `gcloud config set project [PROJECT_ID]` 실행
- 프로젝트 ID 확인

#### 4. 권한 오류
**문제**: S3 버킷에 파일 업로드 시 권한 오류
**해결**:
- IAM 사용자 권한 확인
- 버킷 정책 확인
- AWS CLI 자격 증명 확인

### 📞 추가 도움
- [종합 문제해결 가이드](/mcp_knowledge_base/cloud_basic/textbook/Day1/troubleshooting-guide.md)
- [AWS 공식 문서](https://docs.aws.amazon.com/)
- [GCP 공식 문서](https://cloud.google.com/docs)

## ➡️ 다음 단계

### 📅 Day 2 준비
Day 1을 성공적으로 완료했다면, 다음 단계인 Day 2로 진행할 수 있습니다:

- [Day 2: 서비스 비교 및 최적화](/mcp_knowledge_base/cloud_basic/textbook/Day2/README.md)

### 🔗 관련 자료
- [Cloud Basic 과정 전체](/mcp_knowledge_base/cloud_basic/README.md)
- [학습 경로](/mcp_knowledge_base/cloud_basic/learning-path.md)
- [전체 커리큘럼](/mcp_knowledge_base/curriculum.md)

### 🎯 다음 단계 학습 목표
Day 2에서는 다음 내용을 학습하게 됩니다:
- AWS와 GCP 서비스 비교 분석
- 비용 최적화 전략
- 보안 및 모니터링 기초
- 종합 프로젝트

---

<div align="center">

## 🎉 Day 1 실습을 시작하세요!

[🚀 실습 시작하기](/mcp_knowledge_base/cloud_basic/textbook/Day1/aws-gcp-account-setup.md) | 
[📚 Cloud Basic 과정 전체](/mcp_knowledge_base/cloud_basic/README.md) | 
[🏠 홈으로 돌아가기](/mcp_knowledge_base/index.md)

</div>
"""
            
            with open(readme_path, 'w', encoding='utf-8') as f:
                f.write(improved_content)
            
            print("✅ Cloud Basic Day1 README 개선 완료")
            
        except Exception as e:
            print(f"❌ Cloud Basic Day1 README 개선 실패: {str(e)}")
    
    def improve_cloud_basic_day2_readme(self):
        """Cloud Basic Day2 README 개선"""
        readme_path = self.knowledge_base_path / 'cloud_basic' / 'textbook' / 'Day2' / 'README.md'
        
        if not readme_path.exists():
            print("❌ Cloud Basic Day2 README 파일을 찾을 수 없습니다.")
            return
        
        try:
            with open(readme_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            # 기존 내용을 개선된 버전으로 교체
            improved_content = """# 📅 Day 2: 서비스 비교 및 최적화

## 🎯 학습 목표

오늘은 AWS와 GCP의 핵심 서비스를 비교 분석하고, 비용 최적화와 보안의 기초를 학습합니다. 
이 과정을 완료하면 두 클라우드 플랫폼의 장단점을 이해하고, 프로젝트에 적합한 서비스를 선택할 수 있는 역량을 갖추게 됩니다.

### 📋 구체적인 학습 목표
- **서비스 비교 분석**: AWS와 GCP의 주요 서비스를 체계적으로 비교할 수 있습니다
- **비용 구조 이해**: 클라우드 서비스의 비용 구조를 이해하고 예상 비용을 계산할 수 있습니다
- **최적화 전략 수립**: 프로젝트에 맞는 비용 최적화 전략을 수립할 수 있습니다
- **보안 기초**: 기본적인 보안 설정과 모니터링 방법을 이해할 수 있습니다
- **의사결정 능력**: 프로젝트 요구사항에 맞는 클라우드 서비스를 선택할 수 있습니다

## ⏱️ 예상 소요시간

- **이론 학습**: 2시간 (서비스 비교, 비용 구조)
- **실습**: 5시간 (비교 분석, 최적화 실습)
- **정리 및 프로젝트**: 1시간
- **총 소요시간**: 8시간

## 📚 학습 순서

### 🌅 오전 (4시간)

#### 1단계: 컴퓨팅 서비스 비교 (1시간)
- [EC2 vs Compute Engine 비교](/mcp_knowledge_base/cloud_basic/textbook/Day2/compute_comparison.md)
- [인스턴스 유형 분석](/mcp_knowledge_base/cloud_basic/textbook/Day2/compute_comparison.md#인스턴스-유형-분석)
- [가격 비교](/mcp_knowledge_base/cloud_basic/textbook/Day2/compute_comparison.md#가격-비교)

#### 2단계: 스토리지 서비스 비교 (1시간)
- [S3 vs Cloud Storage 비교](/mcp_knowledge_base/cloud_basic/textbook/Day2/storage_comparison.md)
- [스토리지 클래스 분석](/mcp_knowledge_base/cloud_basic/textbook/Day2/storage_comparison.md#스토리지-클래스-분석)
- [성능 및 가격 비교](/mcp_knowledge_base/cloud_basic/textbook/Day2/storage_comparison.md#성능-및-가격-비교)

#### 3단계: 데이터베이스 서비스 비교 (1시간)
- [RDS vs Cloud SQL 비교](/mcp_knowledge_base/cloud_basic/textbook/Day2/database_comparison.md)
- [NoSQL 서비스 비교](/mcp_knowledge_base/cloud_basic/textbook/Day2/database_comparison.md#nosql-서비스-비교)
- [관리형 서비스 장단점](/mcp_knowledge_base/cloud_basic/textbook/Day2/database_comparison.md#관리형-서비스-장단점)

#### 4단계: 네트워킹 서비스 비교 (1시간)
- [VPC vs VPC 비교](/mcp_knowledge_base/cloud_basic/textbook/Day2/network_comparison.md)
- [로드 밸런서 비교](/mcp_knowledge_base/cloud_basic/textbook/Day2/network_comparison.md#로드-밸런서-비교)
- [CDN 서비스 비교](/mcp_knowledge_base/cloud_basic/textbook/Day2/network_comparison.md#cdn-서비스-비교)

### 🌆 오후 (4시간)

#### 5단계: 비용 최적화 실습 (2시간)
- [비용 분석 도구 사용](/mcp_knowledge_base/cloud_basic/textbook/Day2/compute_comparison.md#비용-분석-도구)
- [리소스 최적화](/mcp_knowledge_base/cloud_basic/textbook/Day2/storage_comparison.md#리소스-최적화)
- [예산 설정 및 모니터링](/mcp_knowledge_base/cloud_basic/textbook/Day2/database_comparison.md#예산-설정-및-모니터링)

#### 6단계: 보안 및 모니터링 기초 (1시간)
- [IAM 권한 관리](/mcp_knowledge_base/cloud_basic/textbook/Day1/iam-basics-guide.md#고급-권한-관리)
- [보안 그룹 설정](/mcp_knowledge_base/cloud_basic/textbook/Day1/iam-basics-guide.md#보안-그룹-설정)
- [기본 모니터링 설정](/mcp_knowledge_base/cloud_basic/textbook/Day2/compute_comparison.md#모니터링-설정)

#### 7단계: 종합 프로젝트 (1시간)
- [프로젝트 요구사항 분석](/mcp_knowledge_base/cloud_basic/textbook/Day2/basic-to-master-bridge.md)
- [서비스 선택 및 설계](/mcp_knowledge_base/cloud_basic/textbook/Day2/basic-to-master-bridge.md#서비스-선택-및-설계)
- [비용 예상 및 최적화](/mcp_knowledge_base/cloud_basic/textbook/Day2/basic-to-master-bridge.md#비용-예상-및-최적화)

## 💻 실습 가이드

### 🔧 비교 분석 도구
실습을 위해 다음 도구들을 활용합니다:

1. **AWS 비용 계산기**
   - [AWS Pricing Calculator](https://calculator.aws/)
   - [AWS Cost Explorer](https://console.aws.amazon.com/cost-management/home)

2. **GCP 비용 계산기**
   - [GCP Pricing Calculator](https://cloud.google.com/products/calculator)
   - [GCP Billing Console](https://console.cloud.google.com/billing)

3. **비교 분석 템플릿**
   - [서비스 비교 체크리스트](/mcp_knowledge_base/cloud_basic/textbook/Day2/compute_comparison.md#비교-체크리스트)
   - [비용 분석 템플릿](/mcp_knowledge_base/cloud_basic/textbook/Day2/storage_comparison.md#비용-분석-템플릿)

### 📝 실습 체크리스트

#### 서비스 비교 체크리스트
- [ ] 컴퓨팅 서비스 비교 완료
- [ ] 스토리지 서비스 비교 완료
- [ ] 데이터베이스 서비스 비교 완료
- [ ] 네트워킹 서비스 비교 완료
- [ ] 각 서비스의 장단점 정리 완료

#### 비용 최적화 체크리스트
- [ ] 현재 사용 중인 리소스 분석 완료
- [ ] 비용 최적화 방안 도출 완료
- [ ] 예산 설정 및 알림 구성 완료
- [ ] 모니터링 대시보드 설정 완료

#### 보안 설정 체크리스트
- [ ] IAM 사용자 권한 검토 완료
- [ ] 보안 그룹 규칙 검토 완료
- [ ] 기본 모니터링 설정 완료
- [ ] 보안 체크리스트 작성 완료

## ✅ 완료 확인

### 🎯 학습 목표 달성 확인
다음 질문들에 답할 수 있다면 학습 목표를 달성한 것입니다:

1. **서비스 비교**
   - AWS와 GCP의 주요 서비스 차이점을 설명할 수 있나요?
   - 각 서비스의 장단점을 비교할 수 있나요?

2. **비용 관리**
   - 클라우드 서비스의 비용 구조를 이해하고 있나요?
   - 비용 최적화 방안을 제시할 수 있나요?

3. **보안 기초**
   - 기본적인 보안 설정을 할 수 있나요?
   - 모니터링의 중요성을 이해하고 있나요?

4. **의사결정**
   - 프로젝트 요구사항에 맞는 서비스를 선택할 수 있나요?
   - 비용과 성능을 고려한 최적의 솔루션을 제안할 수 있나요?

### 📊 실습 결과 확인
- **서비스 비교**: 모든 서비스 비교 분석 완료
- **비용 최적화**: 최적화 방안 도출 및 적용 완료
- **보안 설정**: 기본 보안 설정 완료
- **종합 프로젝트**: 요구사항 분석 및 솔루션 제안 완료

## 🔧 문제해결

### 자주 발생하는 문제들

#### 1. 비용 계산 오류
**문제**: 예상 비용과 실제 비용이 크게 다름
**해결**:
- 사용량 패턴을 정확히 분석
- 리전별 가격 차이 고려
- 추가 서비스 비용 포함

#### 2. 서비스 선택 어려움
**문제**: 비슷한 서비스 중 선택이 어려움
**해결**:
- 프로젝트 요구사항 명확히 정의
- 성능, 비용, 관리 편의성 종합 고려
- 프로토타입으로 테스트

#### 3. 보안 설정 복잡함
**문제**: 보안 설정이 복잡하고 어려움
**해결**:
- 기본 보안 설정부터 단계적으로 진행
- 보안 체크리스트 활용
- AWS/GCP 보안 가이드 참조

### 📞 추가 도움
- [종합 문제해결 가이드](/mcp_knowledge_base/cloud_basic/textbook/Day1/troubleshooting-guide.md)
- [비용 최적화 가이드](/mcp_knowledge_base/cloud_basic/textbook/Day2/compute_comparison.md#비용-최적화-가이드)
- [보안 모범 사례](/mcp_knowledge_base/cloud_basic/textbook/Day1/iam-basics-guide.md#보안-모범-사례)

## ➡️ 다음 단계

### 🚀 Cloud Master 과정 준비
Cloud Basic을 성공적으로 완료했다면, 다음 단계인 Cloud Master 과정을 추천합니다:

- [Cloud Master 과정](/mcp_knowledge_base/cloud_master/README.md)
- [Cloud Master Day1: Docker, Git/GitHub, GitHub Actions 기초](/mcp_knowledge_base/cloud_master/textbook/Day1/README.md)

### 🔗 관련 자료
- [Cloud Basic 과정 전체](/mcp_knowledge_base/cloud_basic/README.md)
- [학습 경로](/mcp_knowledge_base/cloud_basic/learning-path.md)
- [전체 커리큘럼](/mcp_knowledge_base/curriculum.md)

### 🎯 다음 단계 학습 목표
Cloud Master 과정에서는 다음 내용을 학습하게 됩니다:
- Docker 컨테이너 기술
- Git/GitHub 협업 워크플로우
- CI/CD 파이프라인 구축
- 고급 배포 기술
- 모니터링 및 로깅

---

<div align="center">

## 🎉 Day 2 실습을 시작하세요!

[🚀 실습 시작하기](/mcp_knowledge_base/cloud_basic/textbook/Day2/compute_comparison.md) | 
[📚 Cloud Basic 과정 전체](/mcp_knowledge_base/cloud_basic/README.md) | 
[🏠 홈으로 돌아가기](/mcp_knowledge_base/index.md)

</div>
"""
            
            with open(readme_path, 'w', encoding='utf-8') as f:
                f.write(improved_content)
            
            print("✅ Cloud Basic Day2 README 개선 완료")
            
        except Exception as e:
            print(f"❌ Cloud Basic Day2 README 개선 실패: {str(e)}")
    
    def run_improvements(self):
        """전체 Day README 개선 실행"""
        print("🚀 Day별 README 사용자 친화성 개선 시작")
        
        # 1. Cloud Basic Day1 README 개선
        self.improve_cloud_basic_day1_readme()
        
        # 2. Cloud Basic Day2 README 개선
        self.improve_cloud_basic_day2_readme()
        
        print("\n🎉 Day별 README 개선 완료!")

def main():
    """메인 함수"""
    improver = DayREADMEImprover()
    improver.run_improvements()

if __name__ == "__main__":
    main()
