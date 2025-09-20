# Cloud Master - cloud-scripts 통합 가이드

## 🎯 개요

Cloud Master 과정의 실습을 더 쉽고 효율적으로 진행할 수 있도록 자동화된 스크립트 모음입니다. 각 스크립트는 특정 클라우드 작업을 자동화하여 실습 시간을 단축하고 일관된 환경을 제공합니다.

## 📁 스크립트 구조

```
cloud-scripts/
├── README.md                           # 이 파일
├── .github/workflows/                  # CI/CD 파이프라인
│   └── cloud-master-ci-cd.yml         # GitHub Actions 워크플로우
├── aws-setup-helper.sh                 # AWS 환경 자동 설정
├── gcp-setup-helper.sh                 # GCP 환경 자동 설정
├── aws-ec2-create.sh                   # AWS EC2 인스턴스 자동 생성
├── gcp-compute-create.sh               # GCP Compute Engine 자동 생성
├── aws-resource-cleanup.sh             # AWS 리소스 정리
├── gcp-project-cleanup.sh              # GCP 프로젝트 정리
├── environment-check.sh                # 환경 체크
├── startup-script.sh                   # GCP 초기화 스크립트
├── user-data.sh                        # AWS 초기화 스크립트
├── k8s-cluster-create.sh               # Kubernetes 클러스터 자동 생성 (Day2)
├── k8s-app-deploy.sh                   # Kubernetes 애플리케이션 자동 배포 (Day2)
├── monitoring-stack-deploy.sh          # 모니터링 스택 자동 배포 (Day3)
├── load-balancer-setup.sh              # 로드밸런서 자동 설정 (Day3)
├── cost-optimization.sh                # 비용 최적화 자동화 (Day3)
├── deploy-practice-environment.sh      # 실습 환경 자동 배포 (CI/CD 통합)
├── monitoring-dashboard-setup.sh       # 모니터링 대시보드 자동 설정
├── alert-notification-system.sh        # 실시간 알림 시스템 설정
├── advanced-cost-optimization.sh       # 고급 비용 최적화 분석 및 실행
├── budget-monitoring.sh                # 예산 관리 및 비용 알림 설정
├── ai-environment-generator.sh         # AI 기반 실습 환경 자동 생성
├── ai-learning-analyzer.sh             # AI 기반 학습 분석 및 추천 시스템
├── ai-qa-assistant.sh                  # AI 기반 실시간 질문 답변 시스템
└── integrated-automation.sh            # 통합 자동화 스크립트 (모든 기능)
```

## 🚀 빠른 시작

### 1. 통합 자동화 (권장)
```bash
# 모든 스크립트 실행 권한 부여
chmod +x *.sh

# 통합 자동화 실행 (모든 기능)
./integrated-automation.sh aws --full-deploy
# 또는
./integrated-automation.sh gcp --full-deploy

# 특정 기능만 실행
./integrated-automation.sh aws --monitor-only    # 모니터링만
./integrated-automation.sh aws --cost-only       # 비용 최적화만
./integrated-automation.sh aws --ci-cd-only      # CI/CD만
./integrated-automation.sh aws --ai-only         # AI 기능만
./integrated-automation.sh aws --ai-enhanced     # AI 기반 개선
```

### 2. 개별 스크립트 실행
```bash
# 환경 설정
./environment-check.sh
./aws-setup-helper.sh
./gcp-setup-helper.sh

# Day1: VM 배포
./aws-ec2-create.sh
./gcp-compute-create.sh

# Day2: Kubernetes
./k8s-cluster-create.sh
./k8s-app-deploy.sh

# Day3: 모니터링 & 비용 최적화
./monitoring-stack-deploy.sh
./load-balancer-setup.sh
./cost-optimization.sh
```

### 3. 고급 자동화 기능
```bash
# 실습 환경 자동 배포
./deploy-practice-environment.sh aws

# 모니터링 대시보드 설정
./monitoring-dashboard-setup.sh aws --dashboard-url

# 실시간 알림 시스템 설정
./alert-notification-system.sh aws --slack-webhook "YOUR_WEBHOOK_URL" --email "admin@example.com"

# 고급 비용 최적화
./advanced-cost-optimization.sh aws --report-only

# 예산 관리 설정
./budget-monitoring.sh aws --create-budget --set-thresholds

# AI 기반 기능
./ai-environment-generator.sh aws --skill-level "중급" --budget 100 --duration 8
./ai-learning-analyzer.sh --analyze-progress --generate-recommendations
./ai-qa-assistant.sh --interactive
```

## 📚 스크립트별 상세 가이드

### 🔧 환경 설정 스크립트

#### `aws-setup-helper.sh`
- **목적**: AWS 환경 자동 설정
- **기능**: AWS CLI 설치, 인증 설정, 기본 리소스 생성
- **사용법**: `./aws-setup-helper.sh`

#### `gcp-setup-helper.sh`
- **목적**: GCP 환경 자동 설정
- **기능**: gcloud CLI 설치, 인증 설정, 프로젝트 설정
- **사용법**: `./gcp-setup-helper.sh`

#### `environment-check.sh`
- **목적**: 실습 환경 체크
- **기능**: 필수 도구 설치 확인, 권한 검증
- **사용법**: `./environment-check.sh`

### 🖥️ VM 배포 스크립트 (Day1)

#### `aws-ec2-create.sh`
- **목적**: AWS EC2 인스턴스 자동 생성
- **기능**: 보안 그룹, 키 페어, 인스턴스 생성
- **사용법**: `./aws-ec2-create.sh`

#### `gcp-compute-create.sh`
- **목적**: GCP Compute Engine 인스턴스 자동 생성
- **기능**: 방화벽 규칙, 인스턴스 템플릿, 인스턴스 생성
- **사용법**: `./gcp-compute-create.sh`

### ☸️ Kubernetes 스크립트 (Day2)

#### `k8s-cluster-create.sh`
- **목적**: Kubernetes 클러스터 자동 생성
- **기능**: GKE 클러스터 생성, 네임스페이스 설정, 기본 리소스 생성
- **사용법**: `./k8s-cluster-create.sh`

#### `k8s-app-deploy.sh`
- **목적**: Kubernetes 애플리케이션 자동 배포
- **기능**: Docker 이미지 빌드, Deployment, Service, Ingress 생성
- **사용법**: `./k8s-app-deploy.sh`

### 📊 모니터링 & 최적화 스크립트 (Day3)

#### `monitoring-stack-deploy.sh`
- **목적**: 모니터링 스택 자동 배포
- **기능**: Prometheus, Grafana, Node Exporter, AlertManager 배포
- **사용법**: `./monitoring-stack-deploy.sh`

#### `load-balancer-setup.sh`
- **목적**: 로드밸런서 자동 설정
- **기능**: GCP/AWS 로드밸런서 설정, Health Check, Backend Service 구성
- **사용법**: `./load-balancer-setup.sh`

#### `cost-optimization.sh`
- **목적**: 비용 최적화 자동화
- **기능**: 비용 분석, 권장사항 생성, 리소스 정리
- **사용법**: `./cost-optimization.sh`

### 🧹 정리 스크립트

#### `aws-resource-cleanup.sh`
- **목적**: AWS 리소스 정리
- **기능**: 생성된 모든 AWS 리소스 자동 삭제
- **사용법**: `./aws-resource-cleanup.sh`

#### `gcp-project-cleanup.sh`
- **목적**: GCP 프로젝트 정리
- **기능**: 생성된 모든 GCP 리소스 자동 삭제
- **사용법**: `./gcp-project-cleanup.sh`

### 🚀 고급 자동화 스크립트 (장기개선)

#### `deploy-practice-environment.sh`
- **목적**: 실습 환경 자동 배포 (CI/CD 통합)
- **기능**: VPC, 인스턴스, 클러스터, 로드밸런서 자동 생성
- **사용법**: `./deploy-practice-environment.sh [aws|gcp] [--dry-run]`

#### `monitoring-dashboard-setup.sh`
- **목적**: 모니터링 대시보드 자동 설정
- **기능**: CloudWatch/GCP Monitoring 대시보드 및 알람 생성
- **사용법**: `./monitoring-dashboard-setup.sh [aws|gcp] [--dashboard-url]`

#### `alert-notification-system.sh`
- **목적**: 실시간 알림 시스템 설정
- **기능**: SNS/Pub/Sub 기반 이메일, Slack 알림 설정
- **사용법**: `./alert-notification-system.sh [aws|gcp] [--slack-webhook URL] [--email EMAIL]`

#### `advanced-cost-optimization.sh`
- **목적**: 고급 비용 최적화 분석 및 실행
- **기능**: Right Sizing, RI/SP 권장사항, 자동 리소스 정리
- **사용법**: `./advanced-cost-optimization.sh [aws|gcp] [--auto-optimize] [--report-only]`

#### `budget-monitoring.sh`
- **목적**: 예산 관리 및 비용 알림 설정
- **기능**: 예산 생성, 임계값 설정, 비용 이상 탐지
- **사용법**: `./budget-monitoring.sh [aws|gcp] [--create-budget] [--check-alerts] [--set-thresholds]`

#### `ai-environment-generator.sh`
- **목적**: AI 기반 실습 환경 자동 생성
- **기능**: 기술 수준별 최적화된 환경 구성, 개인화된 학습 경로 생성
- **사용법**: `./ai-environment-generator.sh [aws|gcp] [--skill-level LEVEL] [--learning-goals GOALS] [--budget BUDGET] [--duration DURATION]`

#### `ai-learning-analyzer.sh`
- **목적**: AI 기반 학습 분석 및 추천 시스템
- **기능**: 학습 진도 분석, 개인화된 추천사항 생성, 학습 경로 업데이트
- **사용법**: `./ai-learning-analyzer.sh [--analyze-progress] [--generate-recommendations] [--update-learning-path] [--monitor-performance]`

#### `ai-qa-assistant.sh`
- **목적**: AI 기반 실시간 질문 답변 시스템
- **기능**: 맥락별 맞춤형 답변, 대화형 학습 지원, 실시간 문제 해결
- **사용법**: `./ai-qa-assistant.sh [--ask QUESTION] [--interactive] [--context CONTEXT] [--skill-level LEVEL]`

#### `integrated-automation.sh`
- **목적**: 통합 자동화 스크립트 (모든 기능)
- **기능**: CI/CD + 모니터링 + 비용 최적화 + AI 통합 실행
- **사용법**: `./integrated-automation.sh [aws|gcp] [--full-deploy] [--monitor-only] [--cost-only] [--ci-cd-only] [--ai-only] [--ai-enhanced]`

## 🔄 실습 워크플로우

### Day1: Docker & VM 배포
```bash
# 1. 환경 설정
./environment-check.sh
./aws-setup-helper.sh
./gcp-setup-helper.sh

# 2. VM 생성
./aws-ec2-create.sh
./gcp-compute-create.sh

# 3. 애플리케이션 배포
# (수동으로 VM에 SSH 연결 후 배포)

# 4. 정리
./aws-resource-cleanup.sh
./gcp-project-cleanup.sh
```

### Day2: Kubernetes & 고급 CI/CD
```bash
# 1. Kubernetes 클러스터 생성
./k8s-cluster-create.sh

# 2. 애플리케이션 배포
./k8s-app-deploy.sh

# 3. 테스트 및 모니터링
kubectl get pods
kubectl get services

# 4. 정리
kubectl delete namespace development
```

### Day3: 모니터링 & 비용 최적화
```bash
# 1. 모니터링 스택 배포
./monitoring-stack-deploy.sh

# 2. 로드밸런서 설정
./load-balancer-setup.sh

# 3. 비용 최적화
./cost-optimization.sh

# 4. 정리
./aws-resource-cleanup.sh
./gcp-project-cleanup.sh
```

## ⚙️ 설정 및 커스터마이징

### 환경 변수 설정
```bash
# 프로젝트 이름 설정
export PROJECT_NAME="my-cloud-project"

# 리전 설정
export REGION="us-central1"
export ZONE="us-central1-a"

# 인스턴스 설정
export INSTANCE_COUNT=3
export MACHINE_TYPE="e2-micro"
```

### 스크립트 커스터마이징
각 스크립트는 상단의 설정 변수를 수정하여 커스터마이징할 수 있습니다:

```bash
# 예시: k8s-cluster-create.sh
CLUSTER_NAME="my-cluster"
NODE_COUNT=5
MACHINE_TYPE="e2-medium"
```

## 🐛 문제 해결

### 일반적인 문제

#### 1. 권한 오류
```bash
# 해결방법: 스크립트 실행 권한 부여
chmod +x *.sh
```

#### 2. 인증 오류
```bash
# AWS 인증
aws configure

# GCP 인증
gcloud auth login
gcloud config set project PROJECT_ID
```

#### 3. 리소스 생성 실패
```bash
# 해결방법: 이전 리소스 정리 후 재실행
./aws-resource-cleanup.sh
./gcp-project-cleanup.sh
```

### 로그 확인
```bash
# 스크립트 실행 로그 확인
./script-name.sh 2>&1 | tee script.log

# Kubernetes 로그 확인
kubectl logs -l app=my-app

# Docker 로그 확인
docker logs container-name
```

## 📊 모니터링 및 상태 확인

### 리소스 상태 확인
   ```bash
# AWS 리소스 확인
aws ec2 describe-instances
aws elbv2 describe-load-balancers

# GCP 리소스 확인
gcloud compute instances list
gcloud compute forwarding-rules list

# Kubernetes 리소스 확인
kubectl get all
kubectl get nodes
```

### 비용 모니터링
   ```bash
# GCP 비용 확인
gcloud billing budgets list

# AWS 비용 확인
aws ce get-cost-and-usage --time-period Start=2024-01-01,End=2024-01-31
```

## 🔒 보안 고려사항

### 1. 자격 증명 관리
- AWS Access Key와 Secret Key를 안전하게 보관
- GCP Service Account Key를 안전하게 보관
- 환경 변수나 별도 설정 파일 사용 권장

### 2. 네트워크 보안
- 보안 그룹과 방화벽 규칙을 최소 권한으로 설정
- SSH 키 페어를 안전하게 관리
- 불필요한 포트 노출 방지

### 3. 리소스 정리
- 실습 완료 후 반드시 리소스 정리 실행
- 비용 발생을 방지하기 위한 정기적인 정리

## 📚 추가 자료

### 공식 문서
- [AWS CLI 공식 문서](https://docs.aws.amazon.com/cli/)
- [Google Cloud CLI 공식 문서](https://cloud.google.com/sdk/docs)
- [Kubernetes 공식 문서](https://kubernetes.io/docs/)

### Cloud Master 과정
- [Day1: Docker & VM 배포](cloud_master/textbook/Day1/README.md)
- [Day2: Kubernetes & 고급 CI/CD](cloud_master/textbook/Day2/README.md)
- [Day3: 모니터링 & 비용 최적화](cloud_master/textbook/Day3/README.md)

### 실습 샘플
- [Day1 실습 샘플](cloud_master/repos/samples/day1/my-app/README.md)
- [Day2 실습 샘플](cloud_master/repos/samples/day2/my-app/README.md)
- [Day3 실습 샘플](cloud_master/repos/samples/day3/my-app/README.md)

## 🤝 기여하기

### 버그 리포트
1. 문제가 발생한 스크립트와 환경 정보 제공
2. 실행 로그와 오류 메시지 포함
3. 재현 단계 상세 설명

### 기능 요청
1. 새로운 스크립트나 기능 제안
2. 기존 스크립트 개선 사항 제안
3. 사용 사례와 예상 효과 설명

### 코드 기여
1. Fork 후 브랜치 생성
2. 변경사항 구현 및 테스트
3. Pull Request 생성

## 📞 지원

### 문제 해결
- GitHub Issues를 통한 문제 보고
- Cloud Master 과정 커뮤니티 참여
- 공식 문서 및 가이드 참조

### 학습 지원
- Cloud Master 과정 수강
- 실습 가이드 및 샘플 코드 활용
- 정기적인 워크샵 참여

---

**Cloud Master cloud-scripts** - 클라우드 실습을 더 쉽고 효율적으로 만들어주는 자동화 도구 모음입니다. 🚀