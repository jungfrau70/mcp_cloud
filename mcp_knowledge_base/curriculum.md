# 클라우드 실무력 강화! AWS & GCP 활용법 - 통합 커리큘럼

본 커리큘럼은 **4단계 체계적 학습 과정**으로 구성되어 있으며, 클라우드 기초부터 고급 오케스트레이션까지 실무 중심의 교육을 제공합니다.

> 표기 안내: 🔗 아이콘이 붙은 항목은 클릭 가능한 링크입니다.

## 📚 과정 개요

| 과정 | 일정 | 대상 | 주요 내용 | 선수 요구사항 |
|------|------|------|-----------|---------------|
| **Cloud Basic** | 2일 | 클라우드 입문자 | AWS/GCP 기초 서비스, IAM, VM, 스토리지, 네트워크 | IT 기초 지식 |
| **Cloud Master** | 3일 | Basic 수료자 | Docker, Git/GitHub, CI/CD, VM 배포, 로드 밸런싱, 모니터링 | Cloud Basic 수료 |
| **Cloud Container** | 2일 | Master 수료자 | K8s, ECS, Fargate, 고가용성 아키텍처 | Cloud Master 수료 |

---

## 🎯 Cloud Basic (2일) - 클라우드 기초

### 📅 1일차: AWS & GCP 기초 서비스 실습

- **클라우드 개념 및 계정 생성**
  - 클라우드 컴퓨팅 개요와 장점
  - AWS와 GCP 서비스 개요 및 비교
  - 실습: AWS Free Tier 계정 생성 및 콘솔 탐색
  - 실습: GCP 계정 생성 및 $300 크레딧 활성화

- **IAM 기초 실습**
  - AWS IAM: 사용자, 그룹, 역할, 정책 개념
  - GCP IAM: 서비스 계정, 역할, 권한 관리
  - 실습: AWS IAM 사용자 생성 및 권한 부여
  - 실습: GCP 서비스 계정 생성 및 키 관리

- **가상머신 서비스 기초**
  - AWS EC2 vs GCP Compute Engine 비교
  - 인스턴스 타입, 이미지, 리전 개념
  - 실습: AWS EC2 인스턴스 생성 및 SSH 접속
  - 실습: GCP Compute Engine 인스턴스 생성 및 접속

- **스토리지 서비스 기초**
  - AWS S3 vs GCP Cloud Storage 비교
  - 객체 스토리지 개념과 활용 사례
  - 실습: AWS S3 버킷 생성 및 파일 업로드/다운로드
  - 실습: GCP Cloud Storage 버킷 생성 및 파일 관리

### 📅 2일차: 네트워크, 보안 및 데이터베이스 실습

- **네트워킹 기초 실습**
  - AWS VPC vs GCP VPC 개념 및 비교
  - 서브넷, 라우팅, 게이트웨이, NAT 게이트웨이
  - 실습: AWS VPC 및 서브넷 구성
  - 실습: GCP VPC 네트워크 및 서브넷 생성

- **보안 그룹 및 방화벽 실습**
  - AWS Security Groups vs GCP Firewall Rules
  - 인바운드/아웃바운드 규칙 설정 및 모범 사례
  - 실습: AWS Security Groups 생성 및 규칙 설정
  - 실습: GCP Firewall Rules 생성 및 테스트

- **데이터베이스 서비스 기초**
  - AWS RDS vs GCP Cloud SQL 비교
  - 관계형 데이터베이스 관리 및 백업
  - 실습: AWS RDS MySQL 인스턴스 생성 및 연결
  - 실습: GCP Cloud SQL MySQL 인스턴스 생성 및 접속

- **종합 실습 및 비교 분석**
  - 웹 서버 + 데이터베이스 구성 종합 실습
  - AWS vs GCP 서비스별 비용 및 성능 비교
  - 실습: 간단한 웹 애플리케이션을 AWS와 GCP에 각각 배포
  - 실습: 리소스 정리 및 비용 모니터링

**📚 실습 자료**
- 🔗 [AWS 기초 실습 가이드](mcp_knowledge_base/cloud_basic/textbook/Day1/practice/aws_basic_practice.md)
- 🔗 [GCP 기초 실습 가이드](mcp_knowledge_base/cloud_basic/textbook/Day1/practice/gcp_basic_practice.md)
- 🔗 [통합 실습 가이드](mcp_knowledge_base/cloud_basic/textbook/Day1/practice/실습1_aws_gcp.md)

---


## ⚙️ Cloud Master (3일) - Docker, CI/CD & VM 기반 컨테이너 배포

### 📅 1일차: Docker, Git/GitHub, GitHub Actions 기초

- **Docker 기초 및 컨테이너 기술**
  - Docker 개념 및 아키텍처 이해
  - Dockerfile 작성 및 이미지 빌드
  - Docker Compose를 활용한 다중 서비스 관리
  - 실습: Node.js 웹 애플리케이션 컨테이너화

- **Git/GitHub 기초 및 협업**
  - Git 기본 명령어 및 워크플로우
  - GitHub 저장소 생성 및 관리
  - 브랜치 전략 및 Pull Request 활용
  - 실습: 팀 프로젝트 기반 Git 협업

- **GitHub Actions CI/CD 파이프라인**
  - GitHub Actions 개념 및 워크플로우 구조
  - 자동화된 테스트, 빌드, 배포 파이프라인
  - Docker 이미지 자동 빌드 및 레지스트리 푸시
  - 실습: GitHub Actions로 CI/CD 파이프라인 구축

- **VM 기반 웹 애플리케이션 배포**
  - AWS EC2 + Docker / GCP Compute Engine + Docker
  - 웹 애플리케이션 배포 및 도메인 연결
  - 기본 모니터링 및 로그 관리
  - 실습: 완전 자동화된 VM 배포 파이프라인

### 📅 2일차: 고급 CI/CD 및 VM 기반 컨테이너 배포

- **Docker 고급 기법 및 최적화**
  - Dockerfile 멀티스테이지 빌드 및 최적화
  - Docker Compose 고급 설정 및 오케스트레이션
  - 실습: 프로덕션급 Docker 이미지 빌드 및 최적화

- **GitHub Actions 고급 워크플로우**
  - 매트릭스 빌드 및 환경별 배포 전략
  - 시크릿 관리 및 보안 설정
  - 실습: 고급 CI/CD 파이프라인 구축

- **VM 기반 컨테이너 배포 자동화**
  - AWS EC2 + Docker / GCP Compute Engine + Docker
  - 컨테이너 오케스트레이션 및 관리
  - 실습: 고가용성 컨테이너 배포 환경 구성

- **완전 자동화된 배포 파이프라인**
  - GitHub Actions + VM 배포 자동화
  - 실습: GitHub 푸시 → Docker 빌드 → VM 배포 자동화

### 📅 3일차: 로드 밸런싱, 모니터링, 비용 최적화

- **로드 밸런싱 및 Auto Scaling**
  - AWS ELB + Auto Scaling Group / GCP Cloud LB + Managed Instance Group
  - 실습: VM 기반 로드 밸런싱 환경 구성

- **모니터링 및 로깅 시스템**
  - CloudWatch, Cloud Monitoring 설정
  - Prometheus + Grafana 모니터링 구축
  - 실습: 종합 모니터링 대시보드 구축

- **장애 복구 및 운영 자동화**
  - Health Check 기반 자동 교체 및 복구
  - 실습: 장애 시뮬레이션 및 자동 복구 테스트

- **비용 최적화 및 운영 전략**
  - 클라우드 비용 구조 및 과금 체계 분석
  - VM 기반 아키텍처 비용 분석 및 최적화
  - 실습: 비용 최적화 전략 수립 및 발표

**📚 실습 자료**
- 🔗 [Docker 기초 실습](mcp_knowledge_base/cloud_master/textbook/Day1/)
- 🔗 [GitHub Actions 실습](mcp_knowledge_base/cloud_master/textbook/Day1/)
- 🔗 [VM 배포 자동화](mcp_knowledge_base/cloud_master/textbook/Day2/)
- 🔗 [모니터링 및 비용 최적화](mcp_knowledge_base/cloud_master/textbook/Day3/)

---

## ☸️ Cloud Container (2일) - 고급 오케스트레이션

### 📅 1일차: Kubernetes 및 GKE 고급 오케스트레이션

- **Kubernetes 고급 아키텍처**
  - Kubernetes 클러스터 아키텍처 및 컴포넌트
  - GKE 클러스터 생성 및 고급 설정
  - 실습: GKE 클러스터 생성 및 애플리케이션 배포

- **컨테이너 오케스트레이션 고급 기법**
  - Deployment, Service, Ingress 고급 설정
  - ConfigMap, Secret, PersistentVolume 관리
  - 실습: 마이크로서비스 아키텍처 구성

- **AWS ECS 및 Fargate 심화**
  - ECS 클러스터 구성 및 태스크 정의
  - Fargate 서버리스 컨테이너 실행
  - 실습: ECS Fargate 서비스 배포

- **고급 CI/CD 파이프라인**
  - Multi-stage 배포 파이프라인
  - 환경별 배포 전략 (Dev, Staging, Production)
  - 실습: GitOps 기반 배포 자동화

### 📅 2일차: 고가용성 및 확장성 아키텍처

- **고가용성 아키텍처 설계**
  - AWS Multi-AZ / GCP Multi-Region
  - 장애 복구 및 재해 복구 전략(DR)
  - 실습: Multi-AZ RDS 및 EC2 구성, GCP Multi-Region 배포

- **로드 밸런싱 및 Auto Scaling**
  - AWS ELB 심화 / GCP Cloud Load Balancing
  - Auto Scaling 정책 및 메트릭 기반 확장
  - 실습: Auto Scaling + Load Balancer 연동

- **모니터링 및 로깅 시스템**
  - AWS CloudWatch / GCP Monitoring & Logging
  - 경보 및 이벤트 기반 자동화
  - 실습: 커스텀 메트릭 대시보드 및 로그 기반 알림 구축

- **종합 프로젝트 및 최적화**
  - 고가용성 웹 서비스 아키텍처 설계
  - 성능 최적화 및 비용 효율성 분석
  - 실습: 실제 서비스 시나리오 아키텍처 구현 및 발표

**📚 실습 자료**
- 🔗 [Kubernetes 기초 실습](mcp_knowledge_base/cloud_container/textbook/Day1/practice/kubernetes-basics.md)
- 🔗 [ECS/Fargate 실습](mcp_knowledge_base/cloud_container/textbook/Day1/practice/container-basics.md)
- 🔗 [고가용성 아키텍처 실습](mcp_knowledge_base/cloud_container/textbook/Day2/practice/)

---

## 🔗 과정 간 연계성

### 학습 경로
```
Cloud Basic (2일) → Cloud Master (3일) → Cloud Container (2일)
     ↓                    ↓                        ↓
기초 서비스 실습    →   Docker/Git/CI/CD/VM    →   K8s/ECS/Fargate
```

### 선수 요구사항 체크리스트
- **Cloud Basic → Master**: AWS/GCP 기초 서비스 실습 완료
- **Cloud Master → Container**: Docker, Git/GitHub, CI/CD, VM 기반 컨테이너 배포 실습 완료

---

## 🛠️ 자동화 및 도구

### 공통 도구
- **CLI 도구**: AWS CLI, gcloud CLI, Docker CLI
- **버전 관리**: Git, GitHub
- **CI/CD**: GitHub Actions
- **모니터링**: Prometheus, Grafana, CloudWatch, Cloud Monitoring

### 자동화 스크립트
- 🔗 [AWS 자동화 스크립트](mcp_knowledge_base/cloud_basic/textbook/Day1/scripts/)
- 🔗 [GCP 자동화 스크립트](mcp_knowledge_base/cloud_basic/textbook/Day1/scripts/)
- 🔗 [Docker 자동화 스크립트](mcp_knowledge_base/cloud_master/textbook/Day1/scripts/)
- 🔗 [Kubernetes 자동화 스크립트](mcp_knowledge_base/cloud_container/textbook/Day1/scripts/)

---

## 📋 최종 제출물

### 각 과정별 제출물
- **Cloud Basic**: 아키텍처 다이어그램, 계정 설정 증빙, 실습 결과 스크린샷
- **Cloud Intermediate**: Docker 이미지, GitHub 저장소, CI/CD 파이프라인
- **Cloud Master**: 자동화된 배포 파이프라인, 모니터링 대시보드
- **Cloud Container**: Kubernetes 클러스터, 고가용성 아키텍처, 성능 최적화 보고서

### 통합 프로젝트
- **최종 아키텍처**: 4단계 과정을 통합한 완전한 클라우드 아키텍처
- **비용 분석**: 각 단계별 비용 최적화 전략
- **보안 정책**: 종합적인 보안 및 컴플라이언스 정책
- **운영 가이드**: 실무 적용을 위한 운영 매뉴얼

---

## 🎯 학습 성과

과정 완료 후 수강생은 다음을 수행할 수 있습니다:

- **Cloud Basic**: 클라우드 기초 서비스 활용 및 기본 아키텍처 구성
- **Cloud Intermediate**: Docker, Git/GitHub, CI/CD 기초 활용
- **Cloud Master**: VM 기반 컨테이너 배포 및 자동화 운영
- **Cloud Container**: 고급 오케스트레이션 및 엔터프라이즈급 아키텍처 설계

---

## 💡 추가 학습 자료

- [AWS 공식 문서](https://docs.aws.amazon.com/)
- [GCP 공식 문서](https://cloud.google.com/docs)
- [Docker 공식 문서](https://docs.docker.com/)
- [Kubernetes 공식 문서](https://kubernetes.io/docs/)
- [GitHub Actions 공식 문서](https://docs.github.com/en/actions)

