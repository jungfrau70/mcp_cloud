# Cloud Master 과정 실습 가이드

Cloud Master 과정 실습을 위한 완전한 가이드입니다. WSL 환경 설정부터 고급 클라우드 실습까지 단계별로 안내합니다.

## 📋 목차

1. [환경 준비](#1-환경-준비)
   - [WSL 설치 및 설정](#11-wsl-설치-및-설정)
   - [필수 도구 설치](#12-필수-도구-설치)
   - [클라우드 계정 설정](#13-클라우드-계정-설정)

2. [학습 자료 구조](#2-학습-자료-구조)
   - [메인 학습 경로](#21-메인-학습-경로)
   - [Day별 실습 자료](#22-day별-실습-자료)
   - [자동화 스크립트](#23-자동화-스크립트)

3. [실습 진행 방법](#3-실습-진행-방법)
   - [Day 1: GitHub Actions CI/CD 기본 실습](#31-day-1-github-actions-cicd-기본-실습)
   - [Day 2: 고급 CI/CD 및 Docker Compose 실습](#32-day-2-고급-cicd-및-docker-compose-실습)
   - [Day 3: 프로덕션 레벨 모니터링 및 보안 실습](#33-day-3-프로덕션-레벨-모니터링-및-보안-실습)

4. [고급 기능](#4-고급-기능)
   - [AI 기반 학습 지원](#41-ai-기반-학습-지원)
   - [인프라 관리](#42-인프라-관리)
   - [CI/CD 파이프라인](#43-cicd-파이프라인)
   - [모니터링 및 최적화](#44-모니터링-및-최적화)

5. [문제 해결](#5-문제-해결)

---

## 1. 환경 준비

### 1.1 WSL 설치 및 설정

Cloud Master 과정의 모든 실습은 WSL(Windows Subsystem for Linux) 환경에서 진행됩니다. 먼저 WSL을 설치하고 설정해야 합니다.

#### 📖 WSL 설치 가이드
```
mcp_knowledge_base/cloud_master/repos/cloud-scripts/wsl-install.md
```

**주요 설치 단계:**
1. **Windows 기능 활성화**
   - Windows Subsystem for Linux
   - 가상 머신 플랫폼 (Virtual Machine Platform)

2. **WSL 2 설치 및 설정**
   ```powershell
   # WSL 2를 기본 버전으로 설정
   wsl --set-default-version 2
   
   # Ubuntu 설치
   wsl --install -d Ubuntu
   ```

3. **초기 설정**
   - 사용자 계정 및 비밀번호 설정
   - Root 암호 설정
   - 기본 패키지 업데이트

#### 📖 WSL 고급 설정 가이드
```
mcp_knowledge_base/cloud_master/repos/cloud-scripts/wsl-setup-guide.md
```

**고급 설정 포함:**
- 추가 WSL 인스턴스 생성
- 성능 최적화 설정
- 개발 환경 구성
- GUI 애플리케이션 실행 설정

### 1.2 필수 도구 설치

WSL 환경에서 다음 도구들을 설치해야 합니다:

#### 설치 가이드
```
mcp_knowledge_base/cloud_master/repos/install/
```

**필수 도구 목록:**
- **AWS CLI**: AWS 서비스 관리
- **GCP CLI**: Google Cloud 서비스 관리
- **Docker**: 컨테이너 실행 환경
- **Kubernetes (kubectl)**: 쿠버네티스 클러스터 관리
- **Terraform**: 인프라 자동화
- **Git**: 버전 관리

#### 자동 설치 스크립트
```bash
# WSL 환경에서 실행
cd mcp_knowledge_base/cloud_master/repos/cloud-scripts
./install-all-tools.sh
```

### 1.3 클라우드 계정 설정

#### AWS 계정 설정
```
mcp_knowledge_base/cloud_master/accounts/AWS계정가입.md
```

**설정 단계:**
1. AWS 계정 생성 (Free Tier 권장)
2. IAM 사용자 생성 및 권한 설정
3. AWS CLI 설정
4. 리전 및 가용 영역 확인

#### GCP 계정 설정
```
mcp_knowledge_base/cloud_master/accounts/GCP_개인계정가입.md
```

**설정 단계:**
1. GCP 계정 생성 ($300 크레딧 제공)
2. 프로젝트 생성 및 설정
3. GCP CLI 설정
4. 서비스 계정 및 키 생성

---

## 2. 학습 자료 구조

### 2.1 메인 학습 경로

#### 전체 과정 개요
```
mcp_knowledge_base/cloud_master/learning-path.md
```

**포함 내용:**
- 전체 과정 개요 및 학습 순서
- 각 Day별 학습 목표와 실습 가이드
- 실습 환경 준비 방법
- 평가 기준 및 인증 과정

### 2.2 Day별 실습 자료

#### Day 1: VM 배포 및 기본 실습
```
mcp_knowledge_base/cloud_master/textbook/Day1/README.md
```

**실습 내용:**
- AWS EC2, GCP Compute Engine 실습
- Docker 컨테이너 실습
- 기본 클라우드 서비스 이해
- 네트워킹 및 보안 기초

#### Day 2: Kubernetes 및 컨테이너 오케스트레이션
```
mcp_knowledge_base/cloud_master/textbook/Day2/README.md
```

**실습 내용:**
- Kubernetes 클러스터 구축
- Pod, Service, Deployment 실습
- 애플리케이션 배포 및 관리
- 고가용성 아키텍처 설계

#### Day 3: 모니터링, 로드밸런싱, 비용 최적화
```
mcp_knowledge_base/cloud_master/textbook/Day3/README.md
```

**실습 내용:**
- Prometheus, Grafana 모니터링 스택
- 로드밸런서 설정
- 비용 최적화 실습
- 성능 튜닝 및 최적화

### 2.3 자동화 스크립트

#### 환경 설정 스크립트
```
mcp_knowledge_base/cloud_master/repos/cloud-scripts/README.md
```

**주요 스크립트:**
- `aws-setup-helper.sh`: AWS 환경 자동 설정
- `gcp-setup-helper.sh`: GCP 환경 자동 설정
- `docker-setup.sh`: Docker 환경 설정
- `k8s-setup.sh`: Kubernetes 환경 설정

#### 통합 자동화 스크립트
```
mcp_knowledge_base/cloud_master/repos/cloud-scripts/integrated-automation.sh
```

**기능:**
- 전체 과정 통합 자동화
- CI/CD 파이프라인 설정
- 모니터링 및 비용 최적화 자동화
- 실습 환경 정리 자동화

---

## 3. 실습 진행 방법

### 3.1 Day 1: VM 배포 및 기본 실습

#### 실습 시작 전 체크리스트
- [ ] WSL 환경 설정 완료
- [ ] AWS CLI, GCP CLI 설치 및 설정
- [ ] Docker 설치 및 실행 확인
- [ ] Git 설정 완료

#### 실습 진행 순서
1. **환경 설정 확인**
   ```bash
   # WSL 환경 확인
   wsl --list --verbose
   
   # 필수 도구 확인
   aws --version
   gcloud --version
   docker --version
   ```

2. **Day 1 실습 시작**
   ```bash
   # Day 1 실습 가이드 확인
   cat mcp_knowledge_base/cloud_master/textbook/Day1/README.md
   
   # 자동화 스크립트 실행
   cd mcp_knowledge_base/cloud_master/repos/cloud-scripts
   ./day1-automation.sh
   ```

3. **실습 결과 확인**
   - AWS EC2 인스턴스 생성 확인
   - GCP Compute Engine 인스턴스 생성 확인
   - Docker 컨테이너 실행 확인

### 3.2 Day 2: Kubernetes 및 컨테이너 오케스트레이션

#### 실습 시작 전 체크리스트
- [ ] Day 1 실습 완료
- [ ] Kubernetes 환경 준비
- [ ] Helm 설치 완료
- [ ] 모니터링 도구 설치

#### 실습 진행 순서
1. **Kubernetes 환경 설정**
   ```bash
   # Kubernetes 클러스터 생성
   ./k8s-cluster-setup.sh
   
   # Helm 차트 설치
   ./helm-setup.sh
   ```

2. **Day 2 실습 시작**
   ```bash
   # Day 2 실습 가이드 확인
   cat mcp_knowledge_base/cloud_master/textbook/Day2/README.md
   
   # 자동화 스크립트 실행
   ./day2-automation.sh
   ```

3. **실습 결과 확인**
   - Kubernetes 클러스터 상태 확인
   - 애플리케이션 배포 확인
   - 서비스 및 인그레스 설정 확인

### 3.3 Day 3: 모니터링, 로드밸런싱, 비용 최적화

#### 실습 시작 전 체크리스트
- [ ] Day 2 실습 완료
- [ ] 모니터링 스택 준비
- [ ] 로드밸런서 설정
- [ ] 비용 모니터링 도구 설치

#### 실습 진행 순서
1. **모니터링 환경 설정**
   ```bash
   # Prometheus, Grafana 설치
   ./monitoring-setup.sh
   
   # 로드밸런서 설정
   ./loadbalancer-setup.sh
   ```

2. **Day 3 실습 시작**
   ```bash
   # Day 3 실습 가이드 확인
   cat mcp_knowledge_base/cloud_master/textbook/Day3/README.md
   
   # 자동화 스크립트 실행
   ./day3-automation.sh
   ```

3. **실습 결과 확인**
   - 모니터링 대시보드 확인
   - 로드밸런서 동작 확인
   - 비용 최적화 결과 확인

---

## 4. 고급 기능

### 4.1 AI 기반 학습 지원

#### 학습 진도 추적
```
mcp_knowledge_base/cloud_master/repos/cloud-scripts/learning-progress-tracker.sh
```

**기능:**
- 실시간 학습 진도 추적
- 개인화된 학습 분석
- 상세 진도 리포트 생성

#### AI 학습 분석
```
mcp_knowledge_base/cloud_master/repos/cloud-scripts/ai-learning-analyzer.sh
```

**기능:**
- AI 기반 학습 패턴 분석
- 개인화된 추천사항 생성
- 학습 경로 최적화

### 4.2 인프라 관리

#### 인프라 가이드
```
mcp_knowledge_base/cloud_master/infra-guide.md
```

**포함 내용:**
- WSL 환경 설정 및 도구 설치
- 클라우드 계정 설정 (AWS, GCP)
- VM 인프라 배포 (EC2, Compute Engine)
- Kubernetes 클러스터 구축 (로컬, EKS, GKE)
- 인프라 모니터링 및 최적화

#### 인프라 자동화 실행
```bash
# 전체 과정 통합 자동화
./integrated-automation.sh aws --full-deploy

# GCP 환경 자동화
./integrated-automation.sh gcp --full-deploy
```

### 4.3 CI/CD 파이프라인

#### CI/CD 가이드
```
mcp_knowledge_base/cloud_master/cicd-guide.md
```

**포함 내용:**
- GitHub Actions 워크플로우 생성
- Docker 이미지 자동 빌드 및 배포
- VM 및 Kubernetes 자동 배포
- 모니터링 및 알림 시스템 구축

#### CI/CD 파이프라인 설정
```bash
# GitHub Actions 설정
./setup-github-actions.sh

# GitLab CI/CD 설정
./setup-gitlab-ci.sh
```

### 4.4 모니터링 및 최적화

#### 성능 모니터링
```bash
# 성능 모니터링 시작
./start-performance-monitoring.sh

# 비용 최적화 분석
./cost-optimization-analysis.sh
```

---

## 5. 문제 해결

### 5.1 일반적인 문제들

#### WSL 관련 문제
```bash
# WSL 서비스 재시작
wsl --shutdown
wsl

# WSL 버전 확인
wsl --list --verbose
```

#### 클라우드 연결 문제
```bash
# AWS 연결 확인
aws sts get-caller-identity

# GCP 연결 확인
gcloud auth list
```

#### Docker 관련 문제
```bash
# Docker 서비스 재시작
sudo systemctl restart docker

# Docker 상태 확인
docker system info
```

### 5.2 실습 환경 정리

#### 리소스 정리
```bash
# AWS 리소스 정리
./cleanup-aws-resources.sh

# GCP 리소스 정리
./cleanup-gcp-resources.sh

# 전체 환경 정리
./cleanup-all-resources.sh
```

#### 비용 모니터링
```bash
# AWS 비용 확인
aws ce get-cost-and-usage --time-period Start=2024-01-01,End=2024-01-31

# GCP 비용 확인
gcloud billing budgets list
```

---

## 📚 추가 자료

### 실습 샘플 코드
```
mcp_knowledge_base/cloud_master/repos/samples/
├── day1/          # Day 1 실습 샘플
├── day2/          # Day 2 실습 샘플
└── day3/          # Day 3 실습 샘플
```

### 프레젠테이션 자료
```
mcp_knowledge_base/cloud_master/presentation/
```
- 과정 개요 프레젠테이션
- 실습 가이드 PDF
- 교재 자료

### 설치 가이드
```
mcp_knowledge_base/cloud_master/repos/install/
```
- AWS CLI, GCP CLI 설치
- Docker, Kubernetes 설치
- 기타 필수 도구 설치

---

## 🎯 실습 시작하기

### 1단계: 환경 준비
```bash
# 1. WSL 설치 및 설정
cat mcp_knowledge_base/cloud_master/repos/cloud-scripts/wsl-install.md

# 2. 필수 도구 설치
cd mcp_knowledge_base/cloud_master/repos/cloud-scripts
./install-all-tools.sh
```

### 2단계: 학습 경로 확인
```bash
# 전체 학습 경로 확인
cat mcp_knowledge_base/cloud_master/learning-path.md
```

### 3단계: 전문 분야별 실습 진행
```bash
# 인프라 관리 실습
cat mcp_knowledge_base/cloud_master/infra-guide.md

# CI/CD 파이프라인 실습
cat mcp_knowledge_base/cloud_master/cicd-guide.md

# Day별 실습
cat mcp_knowledge_base/cloud_master/textbook/Day1/README.md
cat mcp_knowledge_base/cloud_master/textbook/Day2/README.md
cat mcp_knowledge_base/cloud_master/textbook/Day3/README.md
```

## 📚 전문 분야별 가이드

### 🏗️ 인프라 관리
- **문서**: [infra-guide.md](infra-guide.md)
- **내용**: WSL 환경 설정, 클라우드 계정 구성, VM 배포, Kubernetes 클러스터 구축
- **대상**: 인프라 엔지니어, DevOps 엔지니어

### 🚀 CI/CD 파이프라인
- **문서**: [cicd-guide.md](cicd-guide.md)
- **내용**: GitHub Actions, Docker, 자동 배포, 모니터링 시스템
- **대상**: 개발자, CI/CD 엔지니어, SRE

### 📖 전체 실습 가이드
- **문서**: [execuise-guide.md](execuise-guide.md) (현재 문서)
- **내용**: 전체 과정 개요, 학습 자료 구조, 실습 진행 방법
- **대상**: 모든 학습자

이 가이드를 따라하면 Cloud Master 과정의 모든 실습을 체계적으로 진행할 수 있습니다! 🚀✨