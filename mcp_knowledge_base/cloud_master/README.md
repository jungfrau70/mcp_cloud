# AWS/GCP Master 과정

<div align="center">

[← 이전: Cloud Master 메인](../README.md) | [📚 전체 커리큘럼](/curriculum.md) | [🏠 학습 경로로 돌아가기](/index.md) | [📋 학습 경로](../learning-path.md)

</div>

> 📋 **전체 개요**: [README.md](../README.md) | [통합 커리큘럼](/curriculum.md) | [통합 인덱스](/index.md)에서 전체 과정 구조를 확인하세요.

> 📋 **과정 개요**: [과정상세.md](./과정상세.md)에서 상세한 교육 정보를 확인하세요.

## 📋 개요

이 Master 과정은 **클라우드 실무 전반을 아우르는 마스터 수준 과정**입니다.

### 🎯 대상 학습자
- Cloud Basic 과정을 수료한 학습자 (필수)
- DevOps, 인프라 운영 및 최적화를 담당하는 IT 전문가
- AWS/GCP 환경에서 실무 통합 역량을 강화하려는 아키텍트 및 엔지니어

---

## 📚 과정 구성

### Day 0: Install

#### 🛠️ 필수 도구 설치

Cloud Master 과정을 시작하기 전에 다음 도구들을 설치해야 합니다:

##### 1. Git 설치 및 설정
- **목적**: 버전 관리 및 GitHub 연동
- **가이드**: [Git 설치 가이드](install/install_git.md)
- **설치 확인**:
  ```bash
  git --version
  git config --global user.name "Your Name"
  git config --global user.email "your.email@example.com"
  ```

##### 2. Docker 설치 및 설정
- **목적**: 컨테이너 기반 애플리케이션 배포
- **가이드**: [Docker 설치 가이드](install/install_docker.md)
- **설치 확인**:
  ```bash
  docker --version
  docker run hello-world
  ```

##### 3. AWS CLI 설치 및 설정
- **목적**: AWS 서비스와의 상호작용
- **가이드**: [AWS CLI 설치 가이드](install/install_aws_cli.md)
- **설치 확인**:
  ```bash
  aws --version
  aws configure
  ```

##### 4. Azure CLI 설치 및 설정
- **목적**: Azure 서비스와의 상호작용
- **가이드**: [Azure CLI 설치 가이드](install/install_azure_cli.md)
- **설치 확인**:
  ```bash
  az --version
  az login
  ```

##### 5. Google Cloud CLI 설치 및 설정
- **목적**: GCP 서비스와의 상호작용
- **가이드**: [Google Cloud CLI 설치 가이드](install/install_glcoud_cli.md)
- **설치 확인**:
  ```bash
  gcloud --version
  gcloud auth login
  ```

##### 6. GitHub Actions 설정
- **목적**: CI/CD 파이프라인 구축
- **가이드**: [GitHub Actions 완전 가이드](install/github-actions-complete-guide.md)
- **설치 확인**:
  ```bash
  # GitHub 저장소 생성 및 Actions 활성화
  # .github/workflows/ 디렉토리 생성
  ```

#### 🔧 설치 스크립트 (자동화)

각 클라우드 플랫폼별 자동 설치 스크립트를 제공합니다:

- **AWS 환경**: [install_git_aws.sh](install/install_git_aws.sh)
- **Azure 환경**: [install_git_azure.sh](install/install_git_azure.sh)
- **GCP 환경**: [install_git_gcp.sh](install/install_git_gcp.sh)

#### 📋 설치 체크리스트

- [ ] Git 설치 및 사용자 정보 설정
- [ ] Docker 설치 및 실행 확인
- [ ] AWS CLI 설치 및 자격 증명 설정
- [ ] Azure CLI 설치 및 로그인
- [ ] Google Cloud CLI 설치 및 인증
- [ ] GitHub 계정 생성 및 SSH 키 설정
- [ ] GitHub Actions 워크플로우 이해
- [ ] 모든 도구 버전 확인

#### ⚠️ 주의사항

1. **시스템 요구사항**: 각 도구별 최소 시스템 요구사항 확인
2. **권한 설정**: Docker 사용자 그룹 추가 및 권한 설정
3. **네트워크 설정**: 프록시 환경에서의 추가 설정 필요
4. **보안**: 클라우드 계정 자격 증명 안전한 관리

#### 🆘 문제 해결

설치 과정에서 문제가 발생하면 각 설치 가이드의 "문제 해결" 섹션을 참조하세요:

- [Git 문제 해결](install/install_git.md#문제-해결)
- [Docker 문제 해결](install/install_docker.md#문제-해결)
- [AWS CLI 문제 해결](install/install_aws_cli.md#문제-해결)
- [Azure CLI 문제 해결](install/install_azure_cli.md#문제-해결)
- [Google Cloud CLI 문제 해결](install/install_glcoud_cli.md#문제-해결)

#### 🎯 다음 단계

모든 도구 설치가 완료되면 [Day 1: AWS & GCP 고급 아키텍처](textbook/Day1/README.md)로 진행하세요.

### Day 1: Docker, Git/GitHub, GitHub Actions 기초
- **1교시**: Docker 기초 및 컨테이너 기술
  - Docker 개념 및 아키텍처 이해
  - Dockerfile 작성 및 이미지 빌드
  - Docker Compose를 활용한 다중 서비스 관리
  - 실습: Node.js 웹 애플리케이션 컨테이너화

- **2교시**: Git/GitHub 기초 및 협업
  - Git 기본 명령어 및 워크플로우
  - GitHub 저장소 생성 및 관리
  - 브랜치 전략 및 Pull Request 활용
  - 실습: 팀 프로젝트 기반 Git 협업

- **3교시**: GitHub Actions CI/CD 파이프라인
  - GitHub Actions 개념 및 워크플로우 구조
  - 자동화된 테스트, 빌드, 배포 파이프라인
  - Docker 이미지 자동 빌드 및 레지스트리 푸시
  - 실습: GitHub Actions로 CI/CD 파이프라인 구축

- **4교시**: VM 기반 웹 애플리케이션 배포
  - AWS EC2 + Docker / GCP Compute Engine + Docker
  - 웹 애플리케이션 배포 및 도메인 연결
  - 기본 모니터링 및 로그 관리
  - 실습: 완전 자동화된 VM 배포 파이프라인

### Day 2: 고급 CI/CD 및 VM 기반 컨테이너 배포
- **1교시**: Docker 고급 기법 및 최적화
  - Dockerfile 멀티스테이지 빌드 및 최적화
  - Docker Compose 고급 설정 및 오케스트레이션
  - 실습: 프로덕션급 Docker 이미지 빌드 및 최적화

- **2교시**: GitHub Actions 고급 워크플로우
  - 매트릭스 빌드 및 환경별 배포 전략
  - 시크릿 관리 및 보안 설정
  - 실습: 고급 CI/CD 파이프라인 구축

- **3교시**: VM 기반 컨테이너 배포 자동화
  - AWS EC2 + Docker / GCP Compute Engine + Docker
  - 컨테이너 오케스트레이션 및 관리
  - 실습: 고가용성 컨테이너 배포 환경 구성

- **4교시**: 완전 자동화된 배포 파이프라인
  - GitHub Actions + VM 배포 자동화
  - 실습: GitHub 푸시 → Docker 빌드 → VM 배포 자동화

### Day 3: 로드 밸런싱, 모니터링, 비용 최적화
- **1교시**: 로드 밸런싱 및 Auto Scaling
  - AWS ELB + Auto Scaling Group / GCP Cloud LB + Managed Instance Group
  - 실습: VM 기반 로드 밸런싱 환경 구성

- **2교시**: 모니터링 및 로깅 시스템
  - CloudWatch, Cloud Monitoring 설정
  - Prometheus + Grafana 모니터링 구축
  - 실습: 종합 모니터링 대시보드 구축

- **3교시**: 장애 복구 및 운영 자동화
  - Health Check 기반 자동 교체 및 복구
  - 실습: 장애 시뮬레이션 및 자동 복구 테스트

- **4교시**: 비용 최적화 및 운영 전략
  - 클라우드 비용 구조 및 과금 체계 분석
  - VM 기반 아키텍처 비용 분석 및 최적화
  - 실습: 비용 최적화 전략 수립 및 발표

---

## Container 과정과의 연계

### Master 과정에서 학습한 내용
- ✅ Docker 컨테이너화 및 최적화
- ✅ CI/CD 파이프라인 구축
- ✅ VM 기반 컨테이너 배포
- ✅ 로드 밸런싱 및 모니터링

### Container 과정에서 확장하는 내용
- 🚀 **Kubernetes 오케스트레이션**: EKS/GKE 클러스터 관리
- 🚀 **고가용성 아키텍처**: Multi-AZ 배포 및 장애 복구
- 🚀 **서비스 메시**: Istio를 활용한 트래픽 관리
- 🚀 **고급 모니터링**: Prometheus, Grafana, ELK Stack

---

## 📖 학습 자료

### Day 1
- [Docker 고급 가이드](./textbook/Day1/docker-advanced-guide.md)
- [GitHub Actions 가이드](./textbook/Day1/github-actions-guide.md)
- [Docker Compose 가이드](./textbook/Day1/docker-compose-guide.md)
- [VM 배포 가이드](./textbook/Day1/cloud-deployment-guide.md)

### Day 2
- [비용 구조 가이드](./textbook/Day2/cost-structure-guide.md)
- [비용 최적화 가이드](./textbook/Day2/cost-optimization-guide.md)
- [모니터링 가이드](./textbook/Day2/monitoring-guide.md)
- [종합 실습 가이드](./textbook/Day2/comprehensive-practice-guide.md)

### Day 3
- [로드 밸런싱 가이드](./textbook/Day3/load-balancing-guide.md)
- [모니터링 설정 가이드](./textbook/Day3/monitoring-advanced/monitoring-setup.yaml)
- [비용 최적화 가이드](./textbook/Day3/cost-optimization/cost-optimization-guide.md)

> 📚 **전체 실습 가이드**: [Day1 README](./textbook/Day1/README.md) | [Day2 README](./textbook/Day2/README.md) | [Day3 README](./textbook/Day3/README.md)

---

## 🎯 학습 목표

이 Master 과정을 통해 다음을 달성합니다:

1. **Docker 마스터**: 컨테이너화 및 최적화 기법
2. **CI/CD 파이프라인**: GitHub Actions 자동화
3. **VM 기반 배포**: AWS/GCP 환경에서 컨테이너 배포
4. **운영 자동화**: 모니터링, 로깅, 장애 복구
5. **비용 최적화**: 클라우드 비용 분석 및 최적화 전략

---

## 🚀 시작하기

Master 과정을 시작하기 전에 다음을 확인하세요:

### 필수 선수 과정
- [ ] [Cloud Basic 과정](../cloud_basic/textbook/Day1/README.md) 수료
- [ ] Linux 기본 명령어 사용법 숙지
- [ ] 웹 애플리케이션 개발 경험 권장
- [ ] 프로그래밍 기초 지식 (JavaScript, Python 등)

> **다음 과정**: [Cloud Container 과정](../cloud_container/textbook/Day1/README.md) | [전체 커리큘럼](/curriculum.md) | [🏠 학습 경로로 돌아가기](/index.md)

### 환경 준비
- [ ] Docker Desktop 설치 및 설정
- [ ] Git/GitHub 계정 및 CLI 설정
- [ ] AWS/GCP 계정 및 CLI 설정
- [ ] VS Code 또는 선호하는 IDE

### 권장 사항
- Docker 기초 경험
- Git/GitHub 사용 경험
- 클라우드 서비스 기본 이해
- 실습용 프로젝트 준비

---

## 📞 지원

Master 과정에서 문제가 발생하면:
1. [각 교시별 문제 해결 섹션](./textbook/Day1/troubleshooting-guide.md) 확인
2. Docker 및 Git 환경 설정 재확인
3. 클라우드 계정 권한 및 설정 점검

> 🆘 **지원 채널**: [과정상세.md](./과정상세.md)에서 문의 정보를 확인하세요.

**🎯 목표**: 클라우드 실무의 핵심 기술을 마스터하고 다음 단계인 Container 과정으로 나아갈 수 있는 실무 역량을 기릅니다.
