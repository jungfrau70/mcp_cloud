# Cloud Master - cloud-scripts 통합 가이드

## 🎯 개요

Cloud Master 과정의 실습을 더 쉽고 효율적으로 진행할 수 있도록 자동화된 스크립트 모음입니다. 각 스크립트는 특정 클라우드 작업을 자동화하여 실습 시간을 단축하고 일관된 환경을 제공합니다.

## 🚀 실행 순서 (필수)

Cloud Master 과정을 시작하기 전에 **반드시** 다음 순서대로 실행하세요:

### **1단계: 환경 설치 및 검증**
```bash
# WSL 환경 전체 설치
mcp_knowledge_base/cloud_master/repos/install/install-all-wsl.sh

# 환경 체크 (설치 확인)
mcp_knowledge_base/cloud_master/repos/cloud-scripts/environment-check-wsl.sh
```

### **2단계: AWS 환경 설정 및 인스턴스 생성**
```bash
# AWS 환경 자동 설정
mcp_knowledge_base/cloud_master/repos/cloud-scripts/aws-setup-helper.sh

# AWS EC2 인스턴스 생성
mcp_knowledge_base/cloud_master/repos/cloud-scripts/aws-ec2-create.sh
```

### **3단계: GCP 환경 설정 및 인스턴스 생성**
```bash
# GCP 환경 자동 설정
mcp_knowledge_base/cloud_master/repos/cloud-scripts/gcp-setup-helper.sh

# GCP Compute Engine 인스턴스 생성
mcp_knowledge_base/cloud_master/repos/cloud-scripts/gcp-compute-create.sh
```

### **4단계: Kubernetes 클러스터 생성 (선택)**
```bash
# GCP GKE 클러스터 생성
mcp_knowledge_base/cloud_master/repos/cloud-scripts/k8s-cluster-create.sh

# AWS EKS 클러스터 생성
mcp_knowledge_base/cloud_master/repos/cloud-scripts/eks-cluster-create.sh

# kubectl context 설정 및 관리
# Linux/macOS
mcp_knowledge_base/cloud_master/repos/cloud-scripts/context-switch.sh help

# Windows
mcp_knowledge_base/cloud_master/repos/cloud-scripts/context-switch.bat help
```

### **5단계: GitHub Actions CI/CD 파이프라인 설정 (필수)**
```bash
# GitHub Actions 워크플로우 활성화
# .github/workflows/cloud-master-ci-cd.yml 파일이 자동으로 실행됩니다.
```

> **⚠️ 중요**: 모든 단계를 순서대로 실행해야 합니다. 이전 단계를 건너뛰면 오류가 발생할 수 있습니다.

## 🖥️ 실행 환경

### **WSL (Windows Subsystem for Linux) - 권장** ⭐
- **실행 위치**: WSL 내부 (Ubuntu 20.04+ 권장)
- **설치 방법**: `mcp_knowledge_base/cloud_master/repos/install/install-all-wsl.sh` 실행
- **장점**: Windows와 Linux 환경 모두 활용 가능, 파일 공유 용이
- **경로 변환**: Windows 경로를 WSL 경로로 자동 변환
- **호환성**: Windows Git Bash 대비 높은 호환성

### **VM (Virtual Machine)**
- **실행 위치**: Linux VM 내부 (Ubuntu 20.04+ 권장)
- **설치 방법**: VM 내부에서 동일한 설치 스크립트 실행
- **장점**: 완전한 Linux 환경, 격리된 실습 환경
- **요구사항**: VirtualBox, VMware, Hyper-V 등

### **클라우드 인스턴스**
- **실행 위치**: AWS EC2, GCP Compute Engine 등
- **설치 방법**: 클라우드 인스턴스에서 설치 스크립트 실행
- **장점**: 실제 클라우드 환경에서 실습
- **비용**: 인스턴스 실행 비용 발생

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
├── context-switch.sh                   # kubectl context 관리 및 전환 (Linux/macOS)
├── context-switch.bat                  # kubectl context 관리 및 전환 (Windows)
├── kubectl-context-guide.md            # kubectl context 설정 가이드 문서
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

### 0. GitHub Actions CI/CD 설정 (권장) ⭐

#### **GitHub Actions 파이프라인 개요**
Cloud Master 과정의 모든 실습을 자동화하는 포괄적인 CI/CD 파이프라인입니다.

**주요 기능:**
- 🔧 **환경 검증**: WSL/VM 환경 자동 체크
- ☁️ **클라우드 자동화**: AWS/GCP 인프라 자동 생성
- ☸️ **Kubernetes 배포**: K8s 클러스터 및 애플리케이션 자동 배포
- 📊 **모니터링 설정**: Prometheus, Grafana 자동 구성
- 🔒 **보안 스캔**: 인프라 보안 취약점 자동 검사
- 💰 **비용 최적화**: 리소스 사용량 분석 및 최적화 권장
- 🧹 **자동 정리**: 실습 완료 후 리소스 자동 정리

#### **GitHub Repository Secrets 설정**
```bash
# Repository Settings → Secrets and variables → Actions에서 설정

# AWS 자격증명 (필수)
AWS_ACCESS_KEY_ID: your-aws-access-key
AWS_SECRET_ACCESS_KEY: your-aws-secret-key

# GCP 자격증명 (필수)
GCP_PROJECT_ID: your-gcp-project-id
GCP_SERVICE_ACCOUNT_KEY: your-gcp-service-account-json

# 알림 설정 (선택사항)
SLACK_WEBHOOK_URL: your-slack-webhook-url
EMAIL_NOTIFICATION: your-email@example.com
EMAIL_USERNAME: your-email-username
EMAIL_PASSWORD: your-email-password

# Docker Hub (선택사항)
DOCKERHUB_USERNAME: your-dockerhub-username
DOCKERHUB_TOKEN: your-dockerhub-access-token
```

#### **CI/CD 파이프라인 실행 방법**

##### **방법 1: GitHub CLI 사용 (권장)**
```bash
# 1. GitHub CLI 설치 및 인증
gh auth login

# 2. 수동 워크플로우 실행
gh workflow run cloud-master-ci-cd.yml \
  --field cloud_provider=aws \
  --field skill_level=중급 \
  --field budget_limit=100

# 3. 실행 상태 확인
gh run list --workflow=cloud-master-ci-cd.yml

# 4. 실시간 로그 확인
gh run view <run-id> --log
```

##### **방법 2: GitHub 웹 인터페이스**
```bash
# 1. GitHub 저장소 → Actions 탭
# 2. "Cloud Master CI/CD Pipeline" 선택
# 3. "Run workflow" 버튼 클릭
# 4. 파라미터 설정 후 "Run workflow" 실행
```

##### **방법 3: 코드 푸시로 자동 트리거**
```bash
# 1. 코드 변경 후 푸시
git add .
git commit -m "feat: add Day1 application"
git push origin main

# 2. GitHub Actions 자동 실행 확인
# Repository → Actions 탭에서 실행 상태 확인
```

#### **워크플로우 모니터링 및 디버깅**
```bash
# 특정 작업 로그 확인
gh run view <run-id> --log --job=aws-infrastructure
gh run view <run-id> --log --job=gcp-infrastructure
gh run view <run-id> --log --job=kubernetes-deployment

# 워크플로우 재실행
gh run rerun <run-id>

# 워크플로우 취소
gh run cancel <run-id>
```

#### **스케줄된 워크플로우**
- **매일 오전 9시**: 정기 정리 실행 (`cleanup-schedule.yml`)
- **매일 오후 6시**: 비용 최적화 실행 (`cost-optimization.yml`)
- **매주 월요일 오전 2시**: 보안 스캔 실행 (`security-scan.yml`)

### 1. 환경 준비 (WSL 권장) ⭐

#### WSL 환경 구축

##### 새로운 WSL 환경 생성 (권장)
```bash
# WSL 자동 설정 스크립트 실행
./wsl-auto-setup.sh
```

##### 기존 WSL 환경 체크
```bash
# WSL 환경 체크 스크립트 실행
./environment-check-wsl.sh

# 또는 특정 Day 체크
./environment-check-wsl.sh day2
```

##### WSL 수동 설정
상세한 WSL 환경 구축 방법은 [WSL 추가 생성 가이드](wsl-setup-guide.md)를 참조하세요.

#### WSL 환경에서 실행
```bash
# WSL 터미널에서 실행
# 방법 1: 직접 경로 입력
cd /mnt/c/Users/[사용자명]/githubs/mcp_cloud/mcp_knowledge_base/cloud_master/repos/cloud-scripts

# 방법 2: Windows 경로를 WSL로 변환 (권장)
cd $(wslpath "C:\Users\[사용자명]\githubs\mcp_cloud\mcp_knowledge_base\cloud_master\repos\cloud-scripts")

# 방법 3: Windows 탐색기에서 WSL로 열기
# Windows 탐색기에서 폴더 우클릭 → "Linux에서 열기"
```

#### VM 환경에서 실행
```bash
# VM 내부에서 실행
cd /path/to/mcp_knowledge_base/cloud_master/repos/cloud-scripts
```

#### 클라우드 인스턴스에서 실행
```bash
# 클라우드 인스턴스에서 실행
cd /home/ubuntu/mcp_knowledge_base/cloud_master/repos/cloud-scripts
```

### 2. 통합 자동화 (권장)
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

### 3. 개별 스크립트 실행
```bash
# 환경 설정 (WSL/VM에서 실행)
./environment-check.sh
./aws-setup-helper.sh
./gcp-setup-helper.sh

# Day1: VM 배포 (WSL/VM에서 실행)
./aws-ec2-create.sh
./gcp-compute-create.sh

# Day2: Kubernetes (WSL/VM에서 실행)
./k8s-cluster-create.sh
./k8s-app-deploy.sh

# Day3: 모니터링 & 비용 최적화 (WSL/VM에서 실행)
./monitoring-stack-deploy.sh
./load-balancer-setup.sh
./cost-optimization.sh
```

### 4. 고급 자동화 기능
```bash
# 실습 환경 자동 배포 (WSL/VM에서 실행)
./deploy-practice-environment.sh aws

# 모니터링 대시보드 설정 (WSL/VM에서 실행)
./monitoring-dashboard-setup.sh aws --dashboard-url

# 실시간 알림 시스템 설정 (WSL/VM에서 실행)
./alert-notification-system.sh aws --slack-webhook "YOUR_WEBHOOK_URL" --email "admin@example.com"

# 고급 비용 최적화 (WSL/VM에서 실행)
./advanced-cost-optimization.sh aws --report-only

# 예산 관리 설정 (WSL/VM에서 실행)
./budget-monitoring.sh aws --create-budget --set-thresholds

# AI 기반 기능 (WSL/VM에서 실행)
./ai-environment-generator.sh aws --skill-level "중급" --budget 100 --duration 8
./ai-learning-analyzer.sh --analyze-progress --generate-recommendations
./ai-qa-assistant.sh --interactive
```

### 5. 클러스터 삭제 및 정리

#### **통합 클러스터 정리 도구 (권장)**

##### 대화형 클러스터 정리
```bash
# 통합 클러스터 정리 스크립트 실행
./cluster-cleanup-interactive.sh
```

**기능:**
- EKS 클러스터 목록 보기 및 선택적 삭제
- GKE 클러스터 목록 보기 및 선택적 삭제
- 전체 클러스터 정리 (EKS + GKE)
- 환경 상태 확인

##### VPC 정리 도구
```bash
# VPC 선택적 삭제
./cleanup-vpcs.sh

# VPC 종속성 진단
./diagnose-vpc.sh
```

##### VM 정리 도구
```bash
# 통합 VM 정리 스크립트 실행
./vm-cleanup-interactive.sh
```

**기능:**
- GCP VM 인스턴스 목록 보기 및 선택적 삭제
- AWS EC2 인스턴스 목록 보기 및 선택적 삭제
- 전체 VM 정리 (GCP + AWS)
- 환경 상태 확인

#### **GCP GKE 클러스터 삭제**

##### 수동 삭제
```bash
# GKE 클러스터 삭제
gcloud container clusters delete cloud-master-cluster --zone=asia-northeast3-a

# 모든 GKE 클러스터 확인
gcloud container clusters list

# 특정 프로젝트의 모든 클러스터 삭제
gcloud container clusters list --format="value(name,zone)" | while read name zone; do
    gcloud container clusters delete "$name" --zone="$zone" --quiet
done
```

##### 스크립트를 통한 삭제
```bash
# GKE 클러스터 삭제 스크립트 실행
./k8s-cluster-create.sh --delete
```

#### **AWS EKS 클러스터 삭제**

##### 수동 삭제
```bash
# EKS 클러스터 삭제
eksctl delete cluster --name cloud-master-eks-cluster --region ap-northeast-2

# 모든 EKS 클러스터 확인
eksctl get cluster --region ap-northeast-2

# 특정 리전의 모든 클러스터 삭제
eksctl get cluster --region ap-northeast-2 --output json | jq -r '.[].name' | while read cluster; do
    eksctl delete cluster --name "$cluster" --region ap-northeast-2
done
```

##### 스크립트를 통한 삭제
```bash
# EKS 클러스터 삭제 스크립트 실행
./eks-cluster-create.sh delete
```

#### **통합 정리 스크립트**
```bash
# 모든 클러스터 정리 (GCP + AWS)
./cleanup-all-clusters.sh

# 특정 클라우드만 정리
./cleanup-all-clusters.sh --gcp-only
./cleanup-all-clusters.sh --aws-only

# 강제 삭제 (확인 없이)
./cleanup-all-clusters.sh --force
```

#### **수동 정리 절차**

**GCP 정리:**
```bash
# 1. 모든 클러스터 확인
gcloud container clusters list

# 2. 클러스터별 삭제
gcloud container clusters delete [CLUSTER_NAME] --zone=[ZONE]

# 3. 리소스 정리
gcloud compute instances list
gcloud compute instances delete [INSTANCE_NAME] --zone=[ZONE]

# 4. 네트워크 정리
gcloud compute networks list
gcloud compute networks delete [NETWORK_NAME]

# 5. 방화벽 규칙 정리
gcloud compute firewall-rules list
gcloud compute firewall-rules delete [RULE_NAME]
```

**AWS 정리:**
```bash
# 1. 모든 클러스터 확인
eksctl get cluster --all-regions

# 2. 클러스터별 삭제
eksctl delete cluster --name [CLUSTER_NAME] --region [REGION]

# 3. EC2 인스턴스 정리
aws ec2 describe-instances --query 'Reservations[*].Instances[*].[InstanceId,State.Name]' --output table
aws ec2 terminate-instances --instance-ids [INSTANCE_ID]

# 4. VPC 정리
aws ec2 describe-vpcs --query 'Vpcs[*].[VpcId,State]' --output table
aws ec2 delete-vpc --vpc-id [VPC_ID]

# 5. 보안 그룹 정리
aws ec2 describe-security-groups --query 'SecurityGroups[*].[GroupId,GroupName]' --output table
aws ec2 delete-security-group --group-id [SECURITY_GROUP_ID]
```

#### **비용 확인 및 최적화**
```bash
# GCP 비용 확인
gcloud billing budgets list
gcloud billing accounts list

# AWS 비용 확인
aws ce get-cost-and-usage --time-period Start=2024-01-01,End=2024-01-31 --granularity MONTHLY --metrics BlendedCost

# 비용 최적화 권장사항
./cost-optimization.sh --analyze --recommendations
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

### 🔄 GitHub Actions CI/CD 파이프라인 (Day1)

#### `.github/workflows/cloud-master-ci-cd.yml`
- **목적**: Cloud Master 실습 환경 자동화 CI/CD 파이프라인
- **기능**: 
  - **환경 검증**: WSL/VM 환경 자동 체크
  - **AWS 자동화**: EC2 인스턴스 생성 및 설정
  - **GCP 자동화**: Compute Engine 인스턴스 생성 및 설정
  - **Kubernetes 배포**: Day2 K8s 클러스터 자동 생성
  - **모니터링 설정**: Day3 모니터링 스택 자동 배포
  - **비용 최적화**: 리소스 사용량 모니터링 및 최적화
  - **보안 스캔**: 생성된 인프라 보안 취약점 검사
  - **자동 정리**: 실습 완료 후 리소스 자동 정리

#### **워크플로우 트리거**
```yaml
# 수동 실행
workflow_dispatch:
  inputs:
    cloud_provider:
      description: '클라우드 프로바이더 선택'
      required: true
      default: 'aws'
      type: choice
      options:
      - aws
      - gcp
      - both
    skill_level:
      description: '실습 난이도'
      required: true
      default: '중급'
      type: choice
      options:
      - 초급
      - 중급
      - 고급
    budget_limit:
      description: '예산 한도 (USD)'
      required: false
      default: '50'
      type: string
```

#### **주요 워크플로우 단계**
1. **환경 준비**
   - WSL/VM 환경 검증
   - 필수 도구 설치 확인
   - 클라우드 자격증명 검증

2. **AWS 인프라 자동화**
   - VPC 및 서브넷 생성
   - 보안 그룹 설정
   - EC2 인스턴스 생성 및 설정
   - RDS 데이터베이스 생성 (선택사항)

3. **GCP 인프라 자동화**
   - VPC 네트워크 생성
   - 방화벽 규칙 설정
   - Compute Engine 인스턴스 생성
   - Cloud SQL 인스턴스 생성 (선택사항)

4. **Kubernetes 클러스터 자동화**
   - EKS/GKE 클러스터 생성
   - 노드 그룹 설정
   - 기본 애플리케이션 배포

5. **모니터링 및 로깅**
   - CloudWatch/Stackdriver 설정
   - Prometheus + Grafana 배포
   - 알림 규칙 설정

6. **보안 및 컴플라이언스**
   - 보안 스캔 실행
   - 취약점 검사
   - 컴플라이언스 체크

7. **비용 최적화**
   - 리소스 사용량 분석
   - 비용 최적화 권장사항 생성
   - 예산 알림 설정

8. **자동 정리**
   - 실습 완료 후 리소스 정리
   - 비용 보고서 생성
   - 학습 진도 저장

#### **사용법**
```bash
# GitHub Actions 수동 실행
gh workflow run cloud-master-ci-cd.yml \
  --field cloud_provider=aws \
  --field skill_level=중급 \
  --field budget_limit=100

# 워크플로우 상태 확인
gh run list --workflow=cloud-master-ci-cd.yml

# 로그 확인
gh run view <run-id> --log
```

#### **환경 변수 설정**
```bash
# GitHub Secrets에 다음 값들을 설정해야 합니다:
AWS_ACCESS_KEY_ID=your_aws_access_key
AWS_SECRET_ACCESS_KEY=your_aws_secret_key
GCP_PROJECT_ID=your_gcp_project_id
GCP_SERVICE_ACCOUNT_KEY=your_gcp_service_account_json
SLACK_WEBHOOK_URL=your_slack_webhook_url (선택사항)
EMAIL_NOTIFICATION=your_email@example.com (선택사항)
```

#### **워크플로우 파일 위치**
```
.github/
└── workflows/
    ├── cloud-master-ci-cd.yml          # 메인 CI/CD 파이프라인
    ├── security-scan.yml               # 보안 스캔 워크플로우
    ├── cost-optimization.yml           # 비용 최적화 워크플로우
    └── cleanup-schedule.yml            # 정기 정리 워크플로우
```

### ☸️ Kubernetes 스크립트 (Day2)

#### `k8s-cluster-create.sh`
- **목적**: Kubernetes 클러스터 자동 생성
- **기능**: GKE 클러스터 생성, 네임스페이스 설정, 기본 리소스 생성
- **사용법**: `./k8s-cluster-create.sh`

#### `k8s-app-deploy.sh`
- **목적**: Kubernetes 애플리케이션 자동 배포
- **기능**: Docker 이미지 빌드, Deployment, Service, Ingress 생성
- **사용법**: `./k8s-app-deploy.sh`

#### `context-switch.sh` / `context-switch.bat`
- **목적**: kubectl context 관리 및 전환
- **기능**: 
  - Context 목록 조회 및 전환
  - GKE 클러스터 자격 증명 자동 설정
  - Context 연결 테스트
  - Context 삭제 및 관리
- **사용법**: 
  ```bash
  # Linux/macOS
  ./context-switch.sh current
  ./context-switch.sh list
  ./context-switch.sh switch gke-cloud-master
  ./context-switch.sh test gke-cloud-master
  
  # Windows
  context-switch.bat current
  context-switch.bat list
  context-switch.bat switch gke-cloud-master
  context-switch.bat test gke-cloud-master
  ```

#### 📚 kubectl Context 가이드 문서
- **파일**: `kubectl-context-guide.md`
- **내용**: 
  - kubectl context 설정 및 변경 방법
  - GKE 클러스터 자격 증명 설정
  - Context 문제 해결 가이드
  - Windows/Linux 환경별 설정 방법
  - Context 관리 모범 사례

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

### 🔄 GitHub Actions CI/CD 스크립트

#### `.github/workflows/cloud-master-ci-cd.yml`
- **목적**: GitHub Actions CI/CD 파이프라인
- **기능**: Docker 이미지 빌드, Docker Hub 푸시, VM 자동 배포
- **트리거**: 코드 푸시, Pull Request, 수동 실행
- **사용법**: GitHub Repository에 푸시하면 자동 실행

#### GitHub Actions 워크플로우 단계
1. **Environment Check**: AWS/GCP VM IP 확인
2. **Build and Push**: Docker 이미지 빌드 및 Docker Hub 푸시
3. **Deploy to AWS/GCP**: VM에 자동 배포
4. **Post Deployment Test**: 배포 상태 확인
5. **Notification**: 성공/실패 알림

#### 설정 방법
```bash
# 1. GitHub Secrets 설정
# Repository Settings → Secrets and variables → Actions

# 2. SSH 키 생성
ssh-keygen -t rsa -b 4096 -f aws-key -C "mcp-cloud-master-aws"
ssh-keygen -t rsa -b 4096 -f gcp-key -C "mcp-cloud-master-gcp"

# 3. Docker Hub 토큰 생성
# Docker Hub → Account Settings → Security → New Access Token

# 4. 코드 푸시 (자동 트리거)
git add .
git commit -m "feat: add CI/CD pipeline"
git push origin main
```

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

#### WSL 환경에서 실행 ⭐
```bash
# WSL 터미널에서 실행
# 경로 이동 (Windows 경로를 WSL로 변환)
cd $(wslpath "C:\Users\[사용자명]\githubs\mcp_cloud\mcp_knowledge_base\cloud_master\repos\cloud-scripts")

# 1. 환경 설정 (WSL에서 실행)
./environment-check.sh
./aws-setup-helper.sh
./gcp-setup-helper.sh

# 2. VM 생성 (WSL에서 실행)
./aws-ec2-create.sh
./gcp-compute-create.sh

# 3. GitHub Actions CI/CD 설정 (선택사항)
# 3-1. GitHub Secrets 설정
# Repository Settings → Secrets and variables → Actions
# DOCKERHUB_USERNAME, DOCKERHUB_TOKEN, AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY 등 설정

# 3-2. SSH 키 생성 및 설정
ssh-keygen -t rsa -b 4096 -f aws-key -C "mcp-cloud-master-aws"
ssh-keygen -t rsa -b 4096 -f gcp-key -C "mcp-cloud-master-gcp"
# 생성된 키를 GitHub Secrets에 설정

# 3-3. 코드 푸시 (GitHub Actions 자동 트리거)
git add .
git commit -m "feat: add Day1 application and CI/CD pipeline"
git push origin main

# 4. 수동 배포 (GitHub Actions 사용하지 않는 경우)
# (WSL에서 생성된 VM에 SSH 연결 후 배포)
ssh -i ~/.ssh/aws-key.pem ubuntu@[EC2-PUBLIC-IP]
ssh -i ~/.ssh/gcp-key.pem ubuntu@[GCP-EXTERNAL-IP]

# 5. 정리 (WSL에서 실행)
./aws-resource-cleanup.sh
./gcp-project-cleanup.sh
```

#### VM 환경에서 실행
```bash
# VM 내부에서 실행
cd /path/to/cloud-scripts

# 동일한 명령어 실행
./environment-check.sh
./aws-setup-helper.sh
./gcp-setup-helper.sh
./aws-ec2-create.sh
./gcp-compute-create.sh
```

#### 클라우드 인스턴스에서 실행
```bash
# 클라우드 인스턴스에서 실행
cd /home/ubuntu/cloud-scripts

# 동일한 명령어 실행
./environment-check.sh
./aws-setup-helper.sh
./gcp-setup-helper.sh
./aws-ec2-create.sh
./gcp-compute-create.sh
```

### Day2: Kubernetes & 고급 CI/CD

#### WSL 환경에서 실행 ⭐
```bash
# WSL 터미널에서 실행
# 경로 이동 (Windows 경로를 WSL로 변환)
cd $(wslpath "C:\Users\[사용자명]\githubs\mcp_cloud\mcp_knowledge_base\cloud_master\repos\cloud-scripts")

# 1. Kubernetes 클러스터 생성 (WSL에서 실행)
./k8s-cluster-create.sh

# 2. 애플리케이션 배포 (WSL에서 실행)
./k8s-app-deploy.sh

# 3. 테스트 및 모니터링 (WSL에서 실행)
kubectl get pods
kubectl get services

# 4. 정리 (WSL에서 실행)
kubectl delete namespace development
```

#### VM 환경에서 실행
```bash
# VM 내부에서 실행
cd /path/to/cloud-scripts

# 동일한 명령어 실행
./k8s-cluster-create.sh
./k8s-app-deploy.sh
kubectl get pods
kubectl get services
```

#### 클라우드 인스턴스에서 실행
```bash
# 클라우드 인스턴스에서 실행
cd /home/ubuntu/cloud-scripts

# 동일한 명령어 실행
./k8s-cluster-create.sh
./k8s-app-deploy.sh
kubectl get pods
kubectl get services
```

### Day3: 모니터링 & 비용 최적화

#### WSL 환경에서 실행 ⭐
```bash
# WSL 터미널에서 실행
# 경로 이동 (Windows 경로를 WSL로 변환)
cd $(wslpath "C:\Users\[사용자명]\githubs\mcp_cloud\mcp_knowledge_base\cloud_master\repos\cloud-scripts")

# 1. 모니터링 스택 배포 (WSL에서 실행)
./monitoring-stack-deploy.sh

# 2. 로드밸런서 설정 (WSL에서 실행)
./load-balancer-setup.sh

# 3. 비용 최적화 (WSL에서 실행)
./cost-optimization.sh

# 4. 정리 (WSL에서 실행)
./aws-resource-cleanup.sh
./gcp-project-cleanup.sh
```

#### VM 환경에서 실행
```bash
# VM 내부에서 실행
cd /path/to/cloud-scripts

# 동일한 명령어 실행
./monitoring-stack-deploy.sh
./load-balancer-setup.sh
./cost-optimization.sh
```

#### 클라우드 인스턴스에서 실행
```bash
# 클라우드 인스턴스에서 실행
cd /home/ubuntu/cloud-scripts

# 동일한 명령어 실행
./monitoring-stack-deploy.sh
./load-balancer-setup.sh
./cost-optimization.sh
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

### WSL 환경 특화 문제

#### 1. WSL 경로 변환 문제
```bash
# Windows 경로를 WSL 경로로 변환
wslpath "C:\Users\[사용자명]\githubs\mcp_cloud\mcp_knowledge_base\cloud_master\repos\cloud-scripts"

# WSL 경로를 Windows 경로로 변환
wslpath -w "/mnt/c/Users/[사용자명]/githubs/mcp_cloud/mcp_knowledge_base/cloud_master/repos/cloud-scripts"
```

#### 2. WSL에서 Docker 권한 문제
```bash
# Docker 그룹에 사용자 추가
sudo usermod -aG docker $USER

# WSL 재시작 또는 새 그룹 적용
newgrp docker

# Docker 서비스 시작
sudo service docker start
```

#### 3. WSL에서 AWS CLI 인증 문제
```bash
# AWS 자격 증명 확인
aws sts get-caller-identity

# AWS 자격 증명 재설정
aws configure

# 환경 변수 확인
echo $AWS_ACCESS_KEY_ID
echo $AWS_SECRET_ACCESS_KEY
```

#### 4. WSL에서 GCP CLI 인증 문제
```bash
# GCP 인증 확인
gcloud auth list

# GCP 인증 재설정
gcloud auth login
gcloud auth application-default login

# 프로젝트 설정 확인
gcloud config get-value project
```

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

#### 3. kubectl Context 문제
```bash
# 현재 context 확인
kubectl config current-context

# 모든 context 목록 확인
kubectl config get-contexts

# Context 전환
kubectl config use-context <context-name>

# GKE 클러스터 자격 증명 재설정
gcloud container clusters get-credentials <cluster-name> --zone <zone> --project <project-id>

# gke-gcloud-auth-plugin 설치 (Windows)
curl -LO "https://storage.googleapis.com/gke-release/gke-gcloud-auth-plugin/v0.5.3/windows/amd64/gke-gcloud-auth-plugin.exe"
mkdir -p "$HOME/.local/bin"
mv gke-gcloud-auth-plugin.exe "$HOME/.local/bin/"
set PATH=%USERPROFILE%\.local\bin;%PATH%

# Context 연결 테스트
kubectl get nodes
kubectl get namespaces
```

#### 3. 리소스 생성 실패
```bash
# 해결방법: 이전 리소스 정리 후 재실행
./aws-resource-cleanup.sh
./gcp-project-cleanup.sh
```

#### 4. WSL 환경 확인
```bash
# WSL 버전 확인
wsl --list --verbose

# WSL 상태 확인
wsl --status

# Linux 배포판 확인
cat /etc/os-release
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

## 🖥️ 실행 위치별 가이드

### WSL 환경 (권장) ⭐
- **실행 위치**: WSL 내부 (Ubuntu 20.04+)
- **경로 변환**: `wslpath` 명령어 사용
- **장점**: Windows와 Linux 환경 모두 활용, 파일 공유 용이
- **설치**: `install-all-wsl.sh` 실행

### VM 환경
- **실행 위치**: Linux VM 내부 (Ubuntu 20.04+)
- **경로**: VM 내부 절대 경로 사용
- **장점**: 완전한 Linux 환경, 격리된 실습 환경
- **설치**: VM 내부에서 동일한 설치 스크립트 실행

### 클라우드 인스턴스
- **실행 위치**: AWS EC2, GCP Compute Engine 등
- **경로**: 클라우드 인스턴스 내부 경로 사용
- **장점**: 실제 클라우드 환경에서 실습
- **설치**: 클라우드 인스턴스에서 설치 스크립트 실행

## 📚 추가 자료

### 공식 문서
- [GitHub Actions 공식 자습서](https://docs.github.com/ko/actions/tutorials)
- [GitHub Actions 워크플로우 구문](https://docs.github.com/ko/actions/using-workflows/workflow-syntax-for-github-actions)
- [AWS CLI 공식 문서](https://docs.aws.amazon.com/cli/)
- [Google Cloud CLI 공식 문서](https://cloud.google.com/sdk/docs)
- [Kubernetes 공식 문서](https://kubernetes.io/docs/)
- [WSL 공식 문서](https://docs.microsoft.com/en-us/windows/wsl/)
- [Docker Desktop WSL2 가이드](https://docs.docker.com/desktop/wsl/)

### Cloud Master 과정
- [Day1: Docker & VM 배포](cloud_master/textbook/Day1/README.md)
- [Day2: Kubernetes & 고급 CI/CD](cloud_master/textbook/Day2/README.md)
- [Day3: 모니터링 & 비용 최적화](cloud_master/textbook/Day3/README.md)

### 실습 샘플
- [Day1 실습 샘플](cloud_master/repos/samples/day1/my-app/README.md)
- [Day2 실습 샘플](cloud_master/repos/samples/day2/my-app/README.md)
- [Day3 실습 샘플](cloud_master/repos/samples/day3/my-app/README.md)

### 설치 가이드
- [WSL 환경 설치 가이드](cloud_master/repos/install/README-wsl.md)
- [WSL 추가 생성 가이드](wsl-setup-guide.md) - 상세한 WSL 환경 구축 가이드
- [WSL 자동 설정 스크립트](wsl-auto-setup.sh) - 원클릭 WSL 환경 구축
- [전체 설치 스크립트](cloud_master/repos/install/install-all-wsl.sh)

### kubectl Context 관리
- [kubectl Context 설정 가이드](kubectl-context-guide.md)
- [Context 전환 스크립트 (Linux/macOS)](context-switch.sh)
- [Context 전환 스크립트 (Windows)](context-switch.bat)

### 클러스터 정리 도구
- [통합 클러스터 정리 스크립트](cluster-cleanup-interactive.sh) - EKS/GKE 클러스터 선택적 정리
- [VPC 정리 스크립트](cleanup-vpcs.sh) - AWS VPC 선택적 삭제
- [VPC 진단 스크립트](diagnose-vpc.sh) - VPC 종속성 진단

### VM 정리 도구
- [통합 VM 정리 스크립트](vm-cleanup-interactive.sh) - GCP/AWS VM 인스턴스 선택적 정리

### CI/CD 가이드
- [GitHub Actions 워크플로우](.github/workflows/cloud-master-ci-cd.yml)
- [GitHub Actions 설정 가이드](.github/workflows/README.md)
- [Docker 이미지 빌드 가이드](cloud_master/repos/samples/day1/my-app/Dockerfile)

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