#!/usr/bin/env python3
"""
과정 메인 README 사용자 친화성 개선
"""

import os
import re
from pathlib import Path
from typing import Dict, List

class CourseREADMEImprover:
    def __init__(self, knowledge_base_path: str = "mcp_knowledge_base"):
        self.knowledge_base_path = Path(knowledge_base_path)
        self.courses = ['cloud_basic', 'cloud_master', 'cloud_container']
        
    def improve_cloud_basic_readme(self):
        """Cloud Basic README 개선"""
        readme_path = self.knowledge_base_path / 'cloud_basic' / 'README.md'
        
        if not readme_path.exists():
            print("❌ Cloud Basic README 파일을 찾을 수 없습니다.")
            return
        
        try:
            with open(readme_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            # 기존 내용을 개선된 버전으로 교체
            improved_content = """# ☁️ Cloud Basic - 클라우드 기초 실습 과정

## 🎯 과정 소개

**Cloud Basic**은 클라우드 컴퓨팅의 기초를 학습하고 AWS와 GCP의 핵심 서비스를 실습하는 과정입니다. 
초보자도 쉽게 따라할 수 있도록 단계별로 구성되어 있으며, 실제 프로젝트에서 바로 활용할 수 있는 실무 중심의 내용으로 구성되어 있습니다.

### 📋 과정 정보
- **대상자**: 클라우드 초보자, IT 관련 전공자, 클라우드 전환을 고려하는 개발자
- **예상 소요시간**: 2일 (총 16시간)
- **난이도**: 초급 (Beginner)
- **선수 요구사항**: 
  - 기본적인 컴퓨터 사용 능력
  - 인터넷 사용 경험
  - 클라우드 서비스에 대한 기본적인 관심

## 📚 학습 목표

이 과정을 완료하면 다음과 같은 능력을 갖추게 됩니다:

### 🎯 핵심 목표
- **클라우드 기본 개념 이해**: 클라우드 컴퓨팅의 핵심 개념과 장점을 설명할 수 있습니다
- **AWS & GCP 계정 설정**: 두 클라우드 플랫폼의 계정을 생성하고 기본 설정을 완료할 수 있습니다
- **핵심 서비스 활용**: EC2, S3, Compute Engine, Cloud Storage 등 핵심 서비스를 실제로 사용할 수 있습니다
- **비용 관리**: 클라우드 서비스의 비용 구조를 이해하고 최적화할 수 있습니다
- **보안 기초**: IAM, 보안 그룹 등 기본적인 보안 설정을 할 수 있습니다

### 🚀 실무 적용 목표
- **프로젝트 시작**: 실제 프로젝트에서 클라우드 서비스를 선택하고 시작할 수 있습니다
- **문제 해결**: 일반적인 클라우드 관련 문제를 스스로 해결할 수 있습니다
- **다음 단계 준비**: Cloud Master 과정으로 자연스럽게 연결될 수 있습니다

## 📋 과정 개요

### 📅 Day 1: AWS & GCP 기초 서비스 실습 (8시간)
**목표**: 클라우드 기본 개념을 이해하고 핵심 서비스를 실습합니다

#### 🌅 오전 (4시간)
- **09:00-10:00**: 클라우드 기본 개념 및 AWS/GCP 소개
- **10:00-11:00**: AWS 계정 생성 및 기본 설정
- **11:00-12:00**: GCP 계정 생성 및 기본 설정

#### 🌆 오후 (4시간)
- **13:00-14:00**: EC2 인스턴스 생성 및 관리
- **14:00-15:00**: S3 스토리지 서비스 실습
- **15:00-16:00**: Compute Engine 및 Cloud Storage 실습
- **16:00-17:00**: 종합 실습 및 정리

### 📅 Day 2: 서비스 비교 및 최적화 (8시간)
**목표**: AWS와 GCP 서비스를 비교 분석하고 최적화 방법을 학습합니다

#### 🌅 오전 (4시간)
- **09:00-10:00**: 컴퓨팅 서비스 비교 분석
- **10:00-11:00**: 스토리지 서비스 비교 분석
- **11:00-12:00**: 데이터베이스 서비스 비교 분석

#### 🌆 오후 (4시간)
- **13:00-14:00**: 네트워킹 서비스 비교 분석
- **14:00-15:00**: 비용 최적화 전략
- **15:00-16:00**: 보안 및 모니터링 기초
- **16:00-17:00**: 종합 프로젝트 및 다음 단계 안내

## 🚀 시작하기

### 1️⃣ 사전 준비
다음 항목들을 미리 준비해주세요:

- **컴퓨터**: Windows, Mac, Linux 중 하나
- **인터넷 연결**: 안정적인 인터넷 연결
- **이메일 주소**: AWS와 GCP 계정 생성용
- **신용카드**: 클라우드 서비스 가입용 (무료 크레딧 사용)

### 2️⃣ 환경 설정
```bash
# AWS CLI 설치 (Windows)
# https://aws.amazon.com/cli/ 에서 다운로드

# GCP CLI 설치 (Windows)
# https://cloud.google.com/sdk/docs/install 에서 다운로드
```

### 3️⃣ 첫 번째 실습 시작
1. [Day 1 실습 가이드](/mcp_knowledge_base/cloud_basic/textbook/Day1/README.md)로 이동
2. [AWS 계정 생성 가이드](/mcp_knowledge_base/cloud_basic/accounts/AWS계정가입.md) 따라하기
3. [GCP 계정 생성 가이드](/mcp_knowledge_base/cloud_basic/accounts/GCP_개인계정가입.md) 따라하기

## 📚 학습 자료

### 📖 교재
- [Day 1: AWS & GCP 기초 서비스 실습](/mcp_knowledge_base/cloud_basic/textbook/Day1/README.md)
- [Day 2: 서비스 비교 및 최적화](/mcp_knowledge_base/cloud_basic/textbook/Day2/README.md)

### 🔧 실습 가이드
- [AWS 계정 생성](/mcp_knowledge_base/cloud_basic/accounts/AWS계정가입.md)
- [GCP 계정 생성](/mcp_knowledge_base/cloud_basic/accounts/GCP_개인계정가입.md)
- [Azure 계정 생성](/mcp_knowledge_base/cloud_basic/accounts/Azure계정가입.md)

### 🛠️ 설치 가이드
- [AWS CLI 설치](/mcp_knowledge_base/cloud_basic/install/install_aws_cli.md)
- [GCP CLI 설치](/mcp_knowledge_base/cloud_basic/install/install_gcp_cli.md)
- [Azure CLI 설치](/mcp_knowledge_base/cloud_basic/install/install_azure_cli.md)

## ✅ 학습 체크리스트

### Day 1 완료 확인
- [ ] AWS 계정 생성 및 기본 설정 완료
- [ ] GCP 계정 생성 및 기본 설정 완료
- [ ] EC2 인스턴스 생성 및 연결 성공
- [ ] S3 버킷 생성 및 파일 업로드 성공
- [ ] Compute Engine 인스턴스 생성 성공
- [ ] Cloud Storage 버킷 생성 및 파일 업로드 성공

### Day 2 완료 확인
- [ ] AWS와 GCP 서비스 비교 분석 완료
- [ ] 비용 최적화 전략 이해
- [ ] 보안 설정 기본 사항 이해
- [ ] 종합 프로젝트 완료
- [ ] 다음 단계 학습 계획 수립

## ❓ 자주 묻는 질문 (FAQ)

### Q1: 클라우드 경험이 전혀 없어도 수강할 수 있나요?
**A**: 네, 가능합니다! 이 과정은 클라우드 초보자를 위해 설계되었으며, 기본적인 컴퓨터 사용 능력만 있으면 충분합니다.

### Q2: 비용이 얼마나 발생하나요?
**A**: AWS와 GCP 모두 무료 크레딧을 제공합니다. 실습 과정에서 발생하는 비용은 월 $5-10 정도이며, 무료 크레딧으로 대부분 커버됩니다.

### Q3: 실습 중 문제가 발생하면 어떻게 하나요?
**A**: 각 실습 가이드에 문제해결 섹션이 있으며, [종합 문제해결 가이드](/mcp_knowledge_base/cloud_basic/textbook/Day1/troubleshooting-guide.md)도 제공됩니다.

### Q4: 다음 단계는 무엇인가요?
**A**: Cloud Basic 완료 후 [Cloud Master 과정](/mcp_knowledge_base/cloud_master/README.md)을 추천합니다. Docker, CI/CD, 고급 배포 기술을 학습할 수 있습니다.

## 🔗 관련 과정

### 📚 전체 커리큘럼
- [전체 커리큘럼 보기](/mcp_knowledge_base/curriculum.md)
- [학습 경로 안내](/mcp_knowledge_base/cloud_basic/learning-path.md)

### 🚀 다음 단계
- [Cloud Master 과정](/mcp_knowledge_base/cloud_master/README.md) - Docker, CI/CD, 고급 배포
- [Cloud Container 과정](/mcp_knowledge_base/cloud_container/README.md) - Kubernetes, 오케스트레이션

### 🏠 홈으로
- [통합 인덱스](/mcp_knowledge_base/index.md)

## 📞 문의 및 지원

### 💬 학습 지원
- **실시간 질문**: 각 실습 가이드의 댓글 섹션 활용
- **문제 신고**: GitHub Issues를 통한 버그 신고
- **기능 요청**: 새로운 기능이나 개선사항 제안

### 📧 연락처
- **이메일**: support@cloud-education.com
- **GitHub**: [프로젝트 저장소](https://github.com/your-repo/mcp_cloud)
- **문서**: [온라인 문서](https://docs.cloud-education.com)

---

<div align="center">

## 🎉 Cloud Basic 과정을 시작하세요!

[🚀 Day 1 실습 시작하기](/mcp_knowledge_base/cloud_basic/textbook/Day1/README.md) | 
[📚 전체 커리큘럼 보기](/mcp_knowledge_base/curriculum.md) | 
[🏠 홈으로 돌아가기](/mcp_knowledge_base/index.md)

</div>
"""
            
            with open(readme_path, 'w', encoding='utf-8') as f:
                f.write(improved_content)
            
            print("✅ Cloud Basic README 개선 완료")
            
        except Exception as e:
            print(f"❌ Cloud Basic README 개선 실패: {str(e)}")
    
    def improve_cloud_master_readme(self):
        """Cloud Master README 개선"""
        readme_path = self.knowledge_base_path / 'cloud_master' / 'README.md'
        
        if not readme_path.exists():
            print("❌ Cloud Master README 파일을 찾을 수 없습니다.")
            return
        
        try:
            with open(readme_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            # 기존 내용을 개선된 버전으로 교체
            improved_content = """# 🚀 Cloud Master - 클라우드 실무 마스터 과정

## 🎯 과정 소개

**Cloud Master**는 클라우드 환경에서 실제 프로젝트를 구축하고 운영하는 데 필요한 실무 기술을 학습하는 과정입니다. 
Docker, CI/CD, 고급 배포 기술을 통해 현업에서 바로 활용할 수 있는 전문적인 역량을 기를 수 있습니다.

### 📋 과정 정보
- **대상자**: Cloud Basic 완료자, 개발자, DevOps 엔지니어, 클라우드 아키텍트
- **예상 소요시간**: 3일 (총 24시간)
- **난이도**: 중급 (Intermediate)
- **선수 요구사항**: 
  - Cloud Basic 과정 완료 또는 동등한 수준
  - 기본적인 리눅스 명령어 사용 능력
  - Git 기본 사용법 이해

## 📚 학습 목표

이 과정을 완료하면 다음과 같은 전문적인 능력을 갖추게 됩니다:

### 🎯 핵심 목표
- **Docker 마스터**: 컨테이너 기술을 완전히 이해하고 활용할 수 있습니다
- **CI/CD 파이프라인 구축**: GitHub Actions를 활용한 자동화 파이프라인을 구축할 수 있습니다
- **고급 배포 기술**: Blue-Green, Canary 배포 등 고급 배포 전략을 구현할 수 있습니다
- **모니터링 및 로깅**: Prometheus, Grafana를 활용한 모니터링 시스템을 구축할 수 있습니다
- **비용 최적화**: 클라우드 비용을 분석하고 최적화할 수 있습니다

### 🚀 실무 적용 목표
- **프로덕션 환경 구축**: 실제 서비스 운영에 필요한 인프라를 구축할 수 있습니다
- **팀 협업**: Git/GitHub을 활용한 효율적인 팀 협업이 가능합니다
- **문제 해결**: 복잡한 시스템 문제를 분석하고 해결할 수 있습니다
- **아키텍처 설계**: 확장 가능하고 안정적인 시스템 아키텍처를 설계할 수 있습니다

## 📋 과정 개요

### 📅 Day 1: Docker, Git/GitHub, GitHub Actions 기초 (8시간)
**목표**: 컨테이너 기술과 CI/CD의 기초를 학습합니다

#### 🌅 오전 (4시간)
- **09:00-10:00**: Docker 기본 개념 및 설치
- **10:00-11:00**: Docker 이미지 생성 및 관리
- **11:00-12:00**: Docker Compose를 활용한 멀티 컨테이너 관리

#### 🌆 오후 (4시간)
- **13:00-14:00**: Git/GitHub 기초 및 협업 워크플로우
- **14:00-15:00**: GitHub Actions 기본 개념
- **15:00-16:00**: CI/CD 파이프라인 구축 실습
- **16:00-17:00**: 종합 실습 및 정리

### 📅 Day 2: 비용 최적화 및 모니터링 (8시간)
**목표**: 클라우드 비용을 최적화하고 모니터링 시스템을 구축합니다

#### 🌅 오전 (4시간)
- **09:00-10:00**: 클라우드 비용 구조 분석
- **10:00-11:00**: 비용 최적화 전략 및 도구
- **11:00-12:00**: 모니터링 시스템 설계

#### 🌆 오후 (4시간)
- **13:00-14:00**: Prometheus 설치 및 설정
- **14:00-15:00**: Grafana 대시보드 구축
- **15:00-16:00**: 알림 시스템 구축
- **16:00-17:00**: 종합 실습 및 정리

### 📅 Day 3: 고급 아키텍처 및 배포 (8시간)
**목표**: 고가용성과 확장성을 갖춘 고급 아키텍처를 구축합니다

#### 🌅 오전 (4시간)
- **09:00-10:00**: 자동 스케일링 설정
- **10:00-11:00**: 로드 밸런싱 구성
- **11:00-12:00**: 고가용성 아키텍처 설계

#### 🌆 오후 (4시간)
- **13:00-14:00**: 재해 복구 계획 수립
- **14:00-15:00**: Blue-Green 배포 구현
- **15:00-16:00**: 종합 프로젝트
- **16:00-17:00**: 다음 단계 안내 및 정리

## 🚀 시작하기

### 1️⃣ 사전 준비
다음 항목들을 미리 준비해주세요:

- **Cloud Basic 완료**: 기본적인 클라우드 서비스 사용 경험
- **개발 환경**: VS Code, Git, Docker Desktop
- **클라우드 계정**: AWS, GCP 계정 (무료 크레딧 사용)
- **GitHub 계정**: 코드 저장 및 협업용

### 2️⃣ 환경 설정
```bash
# Docker Desktop 설치
# https://www.docker.com/products/docker-desktop

# Git 설치 (이미 설치되어 있다면 생략)
# https://git-scm.com/downloads

# VS Code 설치
# https://code.visualstudio.com/
```

### 3️⃣ 첫 번째 실습 시작
1. [Day 1 실습 가이드](/mcp_knowledge_base/cloud_master/textbook/Day1/README.md)로 이동
2. [Docker 기초 가이드](/mcp_knowledge_base/cloud_master/textbook/Day1/docker-basic-guide.md) 따라하기
3. [Git/GitHub 기초](/mcp_knowledge_base/cloud_master/textbook/Day1/git-github-basics.md) 따라하기

## 📚 학습 자료

### 📖 교재
- [Day 1: Docker, Git/GitHub, GitHub Actions 기초](/mcp_knowledge_base/cloud_master/textbook/Day1/README.md)
- [Day 2: 비용 최적화 및 모니터링](/mcp_knowledge_base/cloud_master/textbook/Day2/README.md)
- [Day 3: 고급 아키텍처 및 배포](/mcp_knowledge_base/cloud_master/textbook/Day3/README.md)

### 🔧 실습 가이드
- [Docker 기초 가이드](/mcp_knowledge_base/cloud_master/textbook/Day1/docker-basic-guide.md)
- [Git/GitHub 기초](/mcp_knowledge_base/cloud_master/textbook/Day1/git-github-basics.md)
- [GitHub Actions 가이드](/mcp_knowledge_base/cloud_master/textbook/Day1/github-actions-guide.md)
- [비용 최적화 가이드](/mcp_knowledge_base/cloud_master/textbook/Day2/cost-optimization-guide.md)
- [모니터링 가이드](/mcp_knowledge_base/cloud_master/textbook/Day2/monitoring-guide.md)

### 🛠️ 설치 가이드
- [Docker 설치](/mcp_knowledge_base/cloud_master/install/install_docker.md)
- [Git 설치](/mcp_knowledge_base/cloud_master/install/install_git.md)
- [GitHub Actions 설정](/mcp_knowledge_base/cloud_master/install/github-actions-setup.md)

## ✅ 학습 체크리스트

### Day 1 완료 확인
- [ ] Docker 기본 명령어 숙지
- [ ] Docker 이미지 생성 및 실행 성공
- [ ] Docker Compose로 멀티 컨테이너 구성 성공
- [ ] Git 기본 워크플로우 이해
- [ ] GitHub Actions 파이프라인 구축 성공

### Day 2 완료 확인
- [ ] 클라우드 비용 분석 완료
- [ ] 비용 최적화 전략 수립
- [ ] Prometheus 모니터링 시스템 구축
- [ ] Grafana 대시보드 생성
- [ ] 알림 시스템 설정 완료

### Day 3 완료 확인
- [ ] 자동 스케일링 설정 완료
- [ ] 로드 밸런싱 구성 성공
- [ ] 고가용성 아키텍처 설계
- [ ] 재해 복구 계획 수립
- [ ] Blue-Green 배포 구현 성공

## ❓ 자주 묻는 질문 (FAQ)

### Q1: Cloud Basic을 완료하지 않았는데 수강할 수 있나요?
**A**: Cloud Basic 과정을 먼저 완료하는 것을 강력히 권장합니다. 이 과정은 중급 수준의 내용으로 구성되어 있어 기본 지식이 필요합니다.

### Q2: Docker 경험이 없어도 괜찮나요?
**A**: 네, 괜찮습니다! 이 과정에서 Docker 기초부터 차근차근 학습할 수 있습니다.

### Q3: 실제 프로젝트에 바로 적용할 수 있나요?
**A**: 네, 가능합니다! 이 과정의 모든 내용은 실제 프로덕션 환경에서 사용되는 기술들입니다.

### Q4: 다음 단계는 무엇인가요?
**A**: [Cloud Container 과정](/mcp_knowledge_base/cloud_container/README.md)을 추천합니다. Kubernetes와 고급 오케스트레이션 기술을 학습할 수 있습니다.

## 🔗 관련 과정

### 📚 전체 커리큘럼
- [전체 커리큘럼 보기](/mcp_knowledge_base/curriculum.md)
- [학습 경로 안내](/mcp_knowledge_base/cloud_master/learning-path.md)

### 🚀 이전 단계
- [Cloud Basic 과정](/mcp_knowledge_base/cloud_basic/README.md) - 클라우드 기초

### 🚀 다음 단계
- [Cloud Container 과정](/mcp_knowledge_base/cloud_container/README.md) - Kubernetes, 오케스트레이션

### 🏠 홈으로
- [통합 인덱스](/mcp_knowledge_base/index.md)

## 📞 문의 및 지원

### 💬 학습 지원
- **실시간 질문**: 각 실습 가이드의 댓글 섹션 활용
- **문제 신고**: GitHub Issues를 통한 버그 신고
- **기능 요청**: 새로운 기능이나 개선사항 제안

### 📧 연락처
- **이메일**: support@cloud-education.com
- **GitHub**: [프로젝트 저장소](https://github.com/your-repo/mcp_cloud)
- **문서**: [온라인 문서](https://docs.cloud-education.com)

---

<div align="center">

## 🎉 Cloud Master 과정을 시작하세요!

[🚀 Day 1 실습 시작하기](/mcp_knowledge_base/cloud_master/textbook/Day1/README.md) | 
[📚 전체 커리큘럼 보기](/mcp_knowledge_base/curriculum.md) | 
[🏠 홈으로 돌아가기](/mcp_knowledge_base/index.md)

</div>
"""
            
            with open(readme_path, 'w', encoding='utf-8') as f:
                f.write(improved_content)
            
            print("✅ Cloud Master README 개선 완료")
            
        except Exception as e:
            print(f"❌ Cloud Master README 개선 실패: {str(e)}")
    
    def improve_cloud_container_readme(self):
        """Cloud Container README 개선"""
        readme_path = self.knowledge_base_path / 'cloud_container' / 'README.md'
        
        if not readme_path.exists():
            print("❌ Cloud Container README 파일을 찾을 수 없습니다.")
            return
        
        try:
            with open(readme_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            # 기존 내용을 개선된 버전으로 교체
            improved_content = """# 🐳 Cloud Container - 컨테이너 오케스트레이션 마스터 과정

## 🎯 과정 소개

**Cloud Container**는 Kubernetes와 고급 컨테이너 오케스트레이션 기술을 학습하는 과정입니다. 
대규모 컨테이너 환경을 관리하고 고가용성 시스템을 구축하는 데 필요한 전문적인 역량을 기를 수 있습니다.

### 📋 과정 정보
- **대상자**: Cloud Master 완료자, DevOps 엔지니어, 클라우드 아키텍트, SRE
- **예상 소요시간**: 2일 (총 16시간)
- **난이도**: 고급 (Advanced)
- **선수 요구사항**: 
  - Cloud Master 과정 완료 또는 동등한 수준
  - Docker 기본 사용법 숙지
  - Git/GitHub 기본 사용법 이해
  - 기본적인 YAML 문법 이해

## 📚 학습 목표

이 과정을 완료하면 다음과 같은 전문적인 능력을 갖추게 됩니다:

### 🎯 핵심 목표
- **Kubernetes 마스터**: Kubernetes 클러스터를 완전히 이해하고 관리할 수 있습니다
- **고가용성 아키텍처**: Multi-AZ, Multi-Region 환경을 구축할 수 있습니다
- **고급 모니터링**: Prometheus, Grafana를 활용한 고급 모니터링 시스템을 구축할 수 있습니다
- **보안 정책**: 컨테이너 보안과 네트워크 정책을 구현할 수 있습니다
- **자동화**: CI/CD 파이프라인과 자동 배포를 구현할 수 있습니다

### 🚀 실무 적용 목표
- **프로덕션 환경**: 대규모 프로덕션 환경을 안정적으로 운영할 수 있습니다
- **팀 리딩**: 컨테이너 기반 개발팀을 리딩할 수 있습니다
- **문제 해결**: 복잡한 클러스터 문제를 분석하고 해결할 수 있습니다
- **아키텍처 설계**: 확장 가능하고 안정적인 컨테이너 아키텍처를 설계할 수 있습니다

## 📋 과정 개요

### 📅 Day 1: Kubernetes 및 GKE 고급 오케스트레이션 (8시간)
**목표**: Kubernetes의 고급 기능을 학습하고 GKE를 활용한 클러스터를 구축합니다

#### 🌅 오전 (4시간)
- **09:00-10:00**: Kubernetes 고급 개념 및 아키텍처
- **10:00-11:00**: GKE 클러스터 생성 및 설정
- **11:00-12:00**: Pod, Service, Ingress 고급 설정

#### 🌆 오후 (4시간)
- **13:00-14:00**: ConfigMap, Secret, PersistentVolume 관리
- **14:00-15:00**: 네트워크 정책 및 보안 설정
- **15:00-16:00**: 고급 스케줄링 및 리소스 관리
- **16:00-17:00**: 종합 실습 및 정리

### 📅 Day 2: 고가용성 및 확장성 아키텍처 (8시간)
**목표**: 고가용성과 확장성을 갖춘 고급 아키텍처를 구축합니다

#### 🌅 오전 (4시간)
- **09:00-10:00**: Multi-AZ 클러스터 구성
- **10:00-11:00**: 고급 로드 밸런싱 및 트래픽 관리
- **11:00-12:00**: 자동 스케일링 및 HPA 설정

#### 🌆 오후 (4시간)
- **13:00-14:00**: 고급 모니터링 시스템 구축
- **14:00-15:00**: 로그 수집 및 분석 시스템
- **15:00-16:00**: 종합 프로젝트
- **16:00-17:00**: 다음 단계 안내 및 정리

## 🚀 시작하기

### 1️⃣ 사전 준비
다음 항목들을 미리 준비해주세요:

- **Cloud Master 완료**: Docker, CI/CD 기본 지식
- **개발 환경**: kubectl, Helm, VS Code
- **클라우드 계정**: GCP 계정 (GKE 사용)
- **GitHub 계정**: 코드 저장 및 협업용

### 2️⃣ 환경 설정
```bash
# kubectl 설치
# https://kubernetes.io/docs/tasks/tools/install-kubectl/

# Helm 설치
# https://helm.sh/docs/intro/install/

# GCP CLI 설치 (이미 설치되어 있다면 생략)
# https://cloud.google.com/sdk/docs/install
```

### 3️⃣ 첫 번째 실습 시작
1. [Day 1 실습 가이드](/mcp_knowledge_base/cloud_container/textbook/Day1/README.md)로 이동
2. [Kubernetes 기초](/mcp_knowledge_base/cloud_container/textbook/Day1/kubernetes-basics.md) 따라하기
3. [GKE 클러스터 생성](/mcp_knowledge_base/cloud_container/textbook/Day1/container-orchestration-guide.md) 따라하기

## 📚 학습 자료

### 📖 교재
- [Day 1: Kubernetes 및 GKE 고급 오케스트레이션](/mcp_knowledge_base/cloud_container/textbook/Day1/README.md)
- [Day 2: 고가용성 및 확장성 아키텍처](/mcp_knowledge_base/cloud_container/textbook/Day2/README.md)

### 🔧 실습 가이드
- [Kubernetes 기초](/mcp_knowledge_base/cloud_container/textbook/Day1/kubernetes-basics.md)
- [컨테이너 오케스트레이션 가이드](/mcp_knowledge_base/cloud_container/textbook/Day1/container-orchestration-guide.md)
- [보안 정책 가이드](/mcp_knowledge_base/cloud_container/textbook/Day1/security-policies-guide.md)
- [고가용성 아키텍처](/mcp_knowledge_base/cloud_container/textbook/Day2/high-availability-architecture.md)
- [고급 모니터링](/mcp_knowledge_base/cloud_container/textbook/Day2/monitoring-setup.md)

### 🛠️ 설치 가이드
- [kubectl 설치](/mcp_knowledge_base/cloud_container/install/install_kubectl.md)
- [Helm 설치](/mcp_knowledge_base/cloud_container/install/install_helm.md)
- [GKE 클러스터 설정](/mcp_knowledge_base/cloud_container/install/gke-setup.md)

## ✅ 학습 체크리스트

### Day 1 완료 확인
- [ ] Kubernetes 기본 개념 이해
- [ ] GKE 클러스터 생성 및 연결 성공
- [ ] Pod, Service, Ingress 설정 완료
- [ ] ConfigMap, Secret 관리 완료
- [ ] 네트워크 정책 설정 완료

### Day 2 완료 확인
- [ ] Multi-AZ 클러스터 구성 완료
- [ ] 고급 로드 밸런싱 설정 완료
- [ ] 자동 스케일링 설정 완료
- [ ] 고급 모니터링 시스템 구축 완료
- [ ] 로그 수집 시스템 구축 완료

## ❓ 자주 묻는 질문 (FAQ)

### Q1: Cloud Master를 완료하지 않았는데 수강할 수 있나요?
**A**: Cloud Master 과정을 먼저 완료하는 것을 강력히 권장합니다. 이 과정은 고급 수준의 내용으로 구성되어 있어 기본 지식이 필요합니다.

### Q2: Kubernetes 경험이 없어도 괜찮나요?
**A**: 네, 괜찮습니다! 이 과정에서 Kubernetes 기초부터 차근차근 학습할 수 있습니다.

### Q3: 실제 프로덕션 환경에 바로 적용할 수 있나요?
**A**: 네, 가능합니다! 이 과정의 모든 내용은 실제 프로덕션 환경에서 사용되는 기술들입니다.

### Q4: 이 과정을 완료하면 어떤 자격을 얻을 수 있나요?
**A**: 이 과정을 완료하면 Kubernetes 관리자 수준의 역량을 갖추게 되며, CKA(Certified Kubernetes Administrator) 시험 준비에도 도움이 됩니다.

## 🔗 관련 과정

### 📚 전체 커리큘럼
- [전체 커리큘럼 보기](/mcp_knowledge_base/curriculum.md)
- [학습 경로 안내](/mcp_knowledge_base/cloud_container/learning-path.md)

### 🚀 이전 단계
- [Cloud Basic 과정](/mcp_knowledge_base/cloud_basic/README.md) - 클라우드 기초
- [Cloud Master 과정](/mcp_knowledge_base/cloud_master/README.md) - Docker, CI/CD

### 🏠 홈으로
- [통합 인덱스](/mcp_knowledge_base/index.md)

## 📞 문의 및 지원

### 💬 학습 지원
- **실시간 질문**: 각 실습 가이드의 댓글 섹션 활용
- **문제 신고**: GitHub Issues를 통한 버그 신고
- **기능 요청**: 새로운 기능이나 개선사항 제안

### 📧 연락처
- **이메일**: support@cloud-education.com
- **GitHub**: [프로젝트 저장소](https://github.com/your-repo/mcp_cloud)
- **문서**: [온라인 문서](https://docs.cloud-education.com)

---

<div align="center">

## 🎉 Cloud Container 과정을 시작하세요!

[🚀 Day 1 실습 시작하기](/mcp_knowledge_base/cloud_container/textbook/Day1/README.md) | 
[📚 전체 커리큘럼 보기](/mcp_knowledge_base/curriculum.md) | 
[🏠 홈으로 돌아가기](/mcp_knowledge_base/index.md)

</div>
"""
            
            with open(readme_path, 'w', encoding='utf-8') as f:
                f.write(improved_content)
            
            print("✅ Cloud Container README 개선 완료")
            
        except Exception as e:
            print(f"❌ Cloud Container README 개선 실패: {str(e)}")
    
    def run_improvements(self):
        """전체 README 개선 실행"""
        print("🚀 과정 메인 README 사용자 친화성 개선 시작")
        
        # 1. Cloud Basic README 개선
        self.improve_cloud_basic_readme()
        
        # 2. Cloud Master README 개선
        self.improve_cloud_master_readme()
        
        # 3. Cloud Container README 개선
        self.improve_cloud_container_readme()
        
        print("\n🎉 모든 과정 README 개선 완료!")

def main():
    """메인 함수"""
    improver = CourseREADMEImprover()
    improver.run_improvements()

if __name__ == "__main__":
    main()
