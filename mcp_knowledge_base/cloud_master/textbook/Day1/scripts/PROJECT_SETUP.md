# Cloud Deployment 프로젝트 설정 가이드

이 가이드는 `cloud-deployment` 프로젝트로 GCP VM을 설정하는 방법을 설명합니다.

## 🚀 빠른 시작

### 1. GCP 프로젝트 설정

```bash
# 1. GCP 인증
gcloud auth login

# 2. 프로젝트 목록 확인
gcloud projects list

# 3. 새 프로젝트 생성 (선택사항)
gcloud projects create cloud-deployment-2025-12345 --name="Cloud Deployment Project"

# 4. 프로젝트 설정
gcloud config set project cloud-deployment-2025-12345
gcloud config set compute/region asia-northeast3
gcloud config set compute/zone asia-northeast3-a

# 5. 프로젝트 삭제
gcloud projects delete cloud-deployment-2025-12345 
```

### 2. VM 생성 및 SSH 키 설정

```bash
# 1. VM 생성 스크립트 실행
./gcp-compute-create.sh

# 2. SSH 키 문제가 있는 경우
./gcp-ssh-key-add.sh
```

### 3. SSH 연결

```bash
# 방법 1: gcloud 명령어 (권장)
gcloud compute ssh cloud-deployment-server --zone=asia-northeast3-a

# 방법 2: 일반 SSH 명령어
ssh -i cloud-deployment-key ubuntu@VM_EXTERNAL_IP
```

## 📋 프로젝트 정보

- **프로젝트명**: `cloud-deployment`
- **프로젝트 ID**: `cloud-deployment-2025-12345`
- **리전**: `asia-northeast3` (서울)
- **존**: `asia-northeast3-a`
- **인스턴스명**: `cloud-deployment-server`
- **키 파일**: `cloud-deployment-key`

## 🔧 주요 리소스

### 네트워크 리소스
- VPC: `cloud-deployment-vpc`
- 서브넷: `cloud-deployment-subnet`
- 방화벽 규칙:
  - `cloud-deployment-allow-ssh` (포트 22)
  - `cloud-deployment-allow-http` (포트 80)
  - `cloud-deployment-allow-https` (포트 443)
  - `cloud-deployment-allow-app` (포트 3000, 7000)

### SSH 키 파일
- 개인키: `cloud-deployment-key`
- 공개키: `cloud-deployment-key.pub`

## 🐛 문제 해결

### SSH 연결 문제
```bash
# SSH 키 추가
./gcp-ssh-key-add.sh

# 방화벽 규칙 확인
gcloud compute firewall-rules list --filter="name:cloud-deployment-allow-ssh"

# 인스턴스 상태 확인
gcloud compute instances describe cloud-deployment-server --zone=asia-northeast3-a
```

### 프로젝트 변경
```bash
# 현재 프로젝트 확인
gcloud config get-value project

# 프로젝트 변경
gcloud config set project YOUR_PROJECT_ID
```

## 🗑️ 리소스 정리

```bash
# 인스턴스 삭제
gcloud compute instances delete cloud-deployment-server --zone=asia-northeast3-a --quiet

# 방화벽 규칙 삭제
gcloud compute firewall-rules delete cloud-deployment-allow-ssh --quiet
gcloud compute firewall-rules delete cloud-deployment-allow-http --quiet
gcloud compute firewall-rules delete cloud-deployment-allow-https --quiet
gcloud compute firewall-rules delete cloud-deployment-allow-app --quiet

# 서브넷 삭제
gcloud compute networks subnets delete cloud-deployment-subnet --region=asia-northeast3 --quiet

# VPC 삭제
gcloud compute networks delete cloud-deployment-vpc --quiet
```

## 📝 참고사항

- 모든 스크립트는 `cloud-deployment` 프로젝트명을 사용합니다
- **SSH 키는 인스턴스 생성 전에 사전 등록됩니다** (Prerequisite):
  - **프로젝트 메타데이터**: 프로젝트 전체 VM에서 사용 가능
  - **인스턴스 메타데이터**: 특정 VM에서만 사용 가능
  - **OS Login**: Google 계정으로 자동 인증
- 기존 리소스가 있으면 재사용하여 중복 생성을 방지합니다
- 스크립트 중단 시에도 안전하게 재시작할 수 있습니다
