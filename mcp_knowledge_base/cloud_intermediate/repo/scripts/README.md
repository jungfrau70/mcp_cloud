# Cloud Intermediate 개선된 스크립트 모음

컨테이너 기술과 Kubernetes를 중심으로 한 중급 실무 과정 자동화 스크립트들입니다.

## 📁 스크립트 구조

```
scripts/
├── cloud-intermediate-helper.sh          # 기본 통합 Helper 스크립트
├── cloud-intermediate-advanced.sh        # 고도화된 통합 Helper 스크립트
├── aws-eks-helper.sh                     # AWS EKS 클러스터 관리 스크립트
├── gcp-gke-helper.sh                     # GCP GKE 클러스터 관리 스크립트
├── cloud-cluster-helper.sh               # 통합 클라우드 클러스터 관리 스크립트
├── aws-environment.env                   # AWS 환경 설정 파일
├── gcp-environment.env                   # GCP 환경 설정 파일
├── test-dry-run.sh                      # Dry-run 테스트 스크립트
└── README.md                           # 이 파일
```

## 🚀 주요 개선사항

### 1. Interactive & Parameter 모드 지원
- **Interactive 모드**: 메뉴 기반 선택 시스템으로 사용자 친화적 인터페이스
- **Parameter 모드**: 명령줄 인수를 통한 자동화 및 스크립트 통합 지원
- **통합 사용법**: `./script.sh` (Interactive) 또는 `./script.sh --action <액션>` (Parameter)
- **진행 상태 표시**: 색상 구분된 로그 메시지와 상세한 진행 상황 표시

### 2. 강화된 오류 처리
- **안전한 실행**: `set -e`, `set -u`, `set -o pipefail` 패턴 적용
- **신호 처리**: `trap cleanup EXIT INT TERM` 설정으로 안전한 종료
- **단계별 검증**: 각 단계별 검증 및 복구 로직 구현
- **상세한 피드백**: 명확한 오류 메시지와 해결 방법 제시

### 3. 종합 환경 체크
- **기본 도구**: Docker, Docker Compose, kubectl, AWS CLI, GCP CLI 확인
- **계정 설정**: AWS/GCP 자격 증명 및 권한 검증
- **리소스 상태**: 컨테이너 및 Kubernetes 클러스터 상태 모니터링
- **네트워크 연결**: 인터넷 연결 및 방화벽 설정 확인

## 📋 스크립트별 상세 설명

### 1. cloud-intermediate-advanced.sh
**고도화된 통합 Helper 스크립트 ["권장"]**

```bash
cloud-intermediate-advanced.sh
```

**주요 기능:**
- 종합 환경 체크 [Docker, Docker Compose, kubectl, AWS, GCP, Git, GitHub CLI, jq]
- Docker 리소스 현황 모니터링
- Kubernetes 리소스 현황 모니터링
- AWS 컨테이너 서비스 현황 [ECS, EKS, ECR]
- GCP 컨테이너 서비스 현황 [GKE, Cloud Run, Container Registry]
- 비용 분석 및 최적화 제안
- 모니터링 스택 자동 설정
- Day별 실습 자동화
- 리소스 정리 및 관리
- 상세한 로깅 및 추적

**고급 기능:**
- 컨테이너 리소스 사용량 모니터링
- Kubernetes 클러스터 상태 실시간 확인
- 클라우드 컨테이너 서비스 비용 분석
- 자동화된 리소스 정리
- 실시간 로그 모니터링

### 2. aws-eks-helper.sh
**AWS EKS 클러스터 관리 스크립트**

```bash
./aws-eks-helper.sh [옵션]
```

**주요 기능:**
- EKS 클러스터 생성/삭제
- 클러스터 상태 확인
- 노드 스케일링
- 클러스터 업그레이드
- 모니터링 설정
- 자동 스케일링 설정

**사용 예시:**
```bash
# EKS 클러스터 생성
./aws-eks-helper.sh create

# 클러스터 상태 확인
./aws-eks-helper.sh status

# 노드 스케일링
./aws-eks-helper.sh scale 3

# 클러스터 업그레이드
./aws-eks-helper.sh upgrade 1.29

# 모니터링 설정
./aws-eks-helper.sh monitoring
```

### 3. gcp-gke-helper.sh
**GCP GKE 클러스터 관리 스크립트**

```bash
./gcp-gke-helper.sh [옵션]
```

**주요 기능:**
- GKE 클러스터 생성/삭제
- 클러스터 상태 확인
- 노드 스케일링
- 클러스터 업그레이드
- 모니터링 설정
- 클러스터 백업
- 비용 최적화

**사용 예시:**
```bash
# GKE 클러스터 생성
./gcp-gke-helper.sh create

# 클러스터 상태 확인
./gcp-gke-helper.sh status

# 노드 스케일링
./gcp-gke-helper.sh scale 3

# 클러스터 백업
./gcp-gke-helper.sh backup

# 비용 최적화
./gcp-gke-helper.sh optimize
```

### 4. cloud-cluster-helper.sh
**통합 클라우드 클러스터 관리 스크립트**

```bash
./cloud-cluster-helper.sh [옵션]
```

**주요 기능:**
- 멀티 클라우드 클러스터 생성/삭제
- 클러스터 간 연결 테스트
- 통합 모니터링 설정
- 클러스터 리소스 정리
- 비용 분석
- 클러스터 백업

**사용 예시:**
```bash
# 멀티 클라우드 클러스터 생성
./cloud-cluster-helper.sh create

# 클러스터 상태 확인
./cloud-cluster-helper.sh status

# 연결 테스트
./cloud-cluster-helper.sh test

# 비용 분석
./cloud-cluster-helper.sh costs

# 리소스 정리
./cloud-cluster-helper.sh cleanup
```

### 5. cloud-intermediate-helper.sh
**기본 통합 Helper 스크립트**

```bash
cloud-intermediate-helper.sh
```

**주요 기능:**
- 환경 체크 [Docker, Docker Compose, kubectl, AWS, GCP, Git, GitHub CLI, jq]
- Docker 리소스 상태 확인
- Kubernetes 리소스 상태 확인
- AWS/GCP 컨테이너 서비스 상태 확인
- Day1/Day2 실습 도구 통합 메뉴

**사용 예시:**
```bash
# 고도화된 스크립트 실행 ["권장"]
cloud-intermediate-advanced.sh

# 메뉴에서 선택하여 실행
1. 🔍 종합 환경 체크
2. 📊 Docker 리소스 현황
3. 📊 Kubernetes 리소스 현황
4. 📊 AWS 컨테이너 서비스 현황
5. 📊 GCP 컨테이너 서비스 현황
6. 💰 AWS 비용 분석
7. 💰 GCP 비용 분석
8. 📈 모니터링 스택 설정
9. 🚀 Day 1 실습 자동화
10. 🚀 Day 2 실습 자동화
11. 🧹 AWS 리소스 정리
12. 🧹 GCP 리소스 정리
13. 🧹 Docker 리소스 정리
14. 📋 로그 보기
```

**기본 스크립트 사용 예시:**
```bash
# 환경 체크만 실행
cloud-intermediate-helper.sh

# 메뉴에서 선택하여 실행
1. 환경 체크
2. Docker 상태 확인
3. Kubernetes 상태 확인
4. AWS 컨테이너 서비스 상태
5. GCP 컨테이너 서비스 상태
6. 전체 상태 확인
7. Day1 실습 도구
8. Day2 실습 도구
```

## 🔧 사용 전 준비사항

### 1. 필수 도구 설치
```bash
# Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh

# Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo aws/install

# GCP CLI
curl https://sdk.cloud.google.com | bash

# Git
sudo apt update && sudo apt install git

# GitHub CLI ["선택사항"]
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt update
sudo apt install gh

# jq ["JSON 처리용"]
sudo apt install jq
```

### 2. 계정 설정
```bash
# AWS 계정 설정
aws configure

# GCP 계정 설정
gcloud auth login
gcloud config set project YOUR_PROJECT_ID

# GitHub CLI 설정 ["선택사항"]
gh auth login
```

### 3. 환경 변수 설정
```bash
# AWS 환경 변수 (aws-environment.env)
export AWS_DEFAULT_REGION="ap-northeast-2"
export EKS_CLUSTER_NAME="cloud-intermediate-eks"
export EKS_NODE_TYPE="t3.medium"
export EKS_NODE_COUNT=2

# GCP 환경 변수 (gcp-environment.env)
export GCP_PROJECT_ID="your-project-id"
export GKE_CLUSTER_NAME="cloud-intermediate-gke"
export GKE_MACHINE_TYPE="e2-medium"
export GKE_NODE_COUNT=2
```

## 🎯 사용법

### Interactive 모드 (기본)
```bash
# 기본 실행 (Interactive 모드)
./cloud-intermediate-helper.sh
./aws-eks-helper.sh
./gcp-gke-helper.sh
./cloud-cluster-helper.sh

# Interactive 모드 명시적 실행
./cloud-intermediate-helper.sh --interactive
./aws-eks-helper.sh -i
```

### Parameter 모드 (자동화)
```bash
# 환경 체크
./cloud-intermediate-helper.sh --action check-env
./cloud-intermediate-helper.sh --action check-docker
./cloud-intermediate-helper.sh --action check-k8s
./cloud-intermediate-helper.sh --action check-aws
./cloud-intermediate-helper.sh --action check-gcp

# AWS EKS 클러스터 관리
./aws-eks-helper.sh --action create
./aws-eks-helper.sh --action status
./aws-eks-helper.sh --action scale 3
./aws-eks-helper.sh --action upgrade 1.29

# GCP GKE 클러스터 관리
./gcp-gke-helper.sh --action create
./gcp-gke-helper.sh --action status
./gcp-gke-helper.sh --action backup
./gcp-gke-helper.sh --action optimize

# 통합 클러스터 관리
./cloud-cluster-helper.sh --action create
./cloud-cluster-helper.sh --action status
./cloud-cluster-helper.sh --action aws create
./cloud-cluster-helper.sh --action gcp status
```

### 도움말 확인
```bash
# 모든 스크립트의 도움말 확인
./cloud-intermediate-helper.sh --help
./aws-eks-helper.sh --help
./gcp-gke-helper.sh --help
./cloud-cluster-helper.sh --help
```

## 🧪 테스트 방법

### 1. 환경 체크 테스트
```bash
# Parameter 모드로 환경 체크
./cloud-intermediate-helper.sh --action check-env
./cloud-intermediate-helper.sh --action check-docker
./cloud-intermediate-helper.sh --action check-k8s
./cloud-intermediate-helper.sh --action check-aws
./cloud-intermediate-helper.sh --action check-gcp

# Interactive 모드로 환경 체크
./cloud-intermediate-helper.sh
# 메뉴에서 "1. 환경 체크" 선택
```

### 2. 클러스터 관리 테스트
```bash
# AWS EKS 클러스터 상태 확인
./aws-eks-helper.sh --action status

# GCP GKE 클러스터 상태 확인
./gcp-gke-helper.sh --action status

# 통합 클러스터 상태 확인
./cloud-cluster-helper.sh --action status
```

### 3. Dry-run 테스트
```bash
# Dry-run 테스트 실행
./test-dry-run.sh

# 모니터링 스택 테스트
./test-monitoring-stack.sh
```

### 4. 실제 리소스 테스트
```bash
# Docker 실습 (로컬 환경)
./cloud-intermediate-helper.sh --action check-docker

# Kubernetes 실습 (로컬 클러스터)
./cloud-intermediate-helper.sh --action check-k8s

# 클라우드 서비스 테스트
./cloud-intermediate-helper.sh --action check-aws
./cloud-intermediate-helper.sh --action check-gcp
```

## 🚨 주의사항

### 1. 비용 관리
- AWS/GCP 컨테이너 서비스 사용 시 비용이 발생합니다
- 실습 완료 후 반드시 리소스를 정리하세요
- 스크립트의 "리소스 정리" 기능을 활용하세요

### 2. 권한 설정
- AWS IAM 사용자에게 ECS, EKS, ECR 권한이 필요합니다
- GCP 프로젝트에서 Container Engine, Cloud Run API가 활성화되어야 합니다
- Kubernetes 클러스터 접근 권한이 필요합니다

### 3. 네트워크 설정
- Docker 네트워크 설정 확인
- Kubernetes 클러스터 네트워크 정책 확인
- 클라우드 보안 그룹에서 필요한 포트 허용

## 📊 개선 효과

### Before ["기존 스크립트"]
- ❌ 명령어 오류 빈발
- ❌ 진행 상태 불명확
- ❌ 오류 처리 부족
- ❌ 컨테이너 관련 기능 부족

### After ["개선된 스크립트"]
- ✅ 강화된 오류 처리 및 안정성
- ✅ Interactive 메뉴 시스템
- ✅ 단계별 검증 및 복구
- ✅ 통합된 스크립트 구조
- ✅ 상세한 진행 상태 표시
- ✅ 사용자 친화적 오류 메시지
- ✅ 컨테이너 및 Kubernetes 전용 기능
- ✅ 클라우드 컨테이너 서비스 통합 관리

## 🔄 업데이트 이력

- **2025-01-25**: Cloud Intermediate 자동화 스크립트 초기 생성
- **2025-01-25**: Docker 및 Kubernetes 전용 기능 추가
- **2025-01-25**: 클라우드 컨테이너 서비스 통합 관리 기능 추가
- **2025-01-25**: 비용 분석 및 최적화 기능 추가
- **2025-01-25**: 모니터링 스택 자동 설정 기능 추가
- **2025-01-25**: 리소스 정리 및 관리 기능 추가
- **2025-01-25**: 상세한 로깅 및 추적 시스템 추가
- **2025-01-25**: Dry-run 테스트 스크립트 추가
- **2025-01-25**: AWS EKS 클러스터 관리 스크립트 추가
- **2025-01-25**: GCP GKE 클러스터 관리 스크립트 추가
- **2025-01-25**: 통합 클라우드 클러스터 관리 스크립트 추가
- **2025-01-25**: 환경 설정 파일 추가 (aws-environment.env, gcp-environment.env)
- **2025-01-25**: Interactive & Parameter 모드 통합 지원 추가
- **2025-01-25**: 스크립트 실제 테스트 및 검증 완료
- **2025-01-25**: README.md 최종 갱신 및 문서화 완료

## 📞 지원

문제가 발생하거나 개선 사항이 있으면 이슈를 등록해 주세요.

---

**Cloud Intermediate 실습을 즐겁게 진행하세요! 🐳☸️**
