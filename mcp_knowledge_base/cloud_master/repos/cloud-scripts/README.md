# 가상머신 생성 스크립트

<div align="center">

← 이전: Cloud Master 1일차 메인 | [다음: Cloud Master 2일차 →](/mcp_knowledge_base/cloud_master/textbook/Day2/README.md) | [📚 전체 커리큘럼](/mcp_knowledge_base/curriculum.md) | [🏠 학습 경로로 돌아가기](/mcp_knowledge_base/index.md) | [📋 학습 경로](/mcp_knowledge_base/cloud_master/learning-path.md)

</div>

이 디렉토리는 AWS와 GCP에서 가상머신을 자동으로 생성하는 스크립트들을 포함합니다.

## 📁 파일 구조

[📁 파일 구조](#-)

```
scripts/
├── README.md              # 이 파일
├── PROJECT_SETUP.md       # 프로젝트 설정 가이드
├── GCP_SSH_KEY_GUIDE.md   # GCP SSH 키 등록 상세 가이드
├── aws-ec2-create.sh      # AWS EC2 인스턴스 자동 생성
├── aws-setup-helper.sh    # AWS 설정 도우미
├── aws-resource-cleanup.sh # AWS 리소스 정리 및 삭제
├── gcp-compute-create.sh  # GCP Compute Engine 인스턴스 자동 생성
├── gcp-setup-helper.sh    # GCP 설정 도우미
├── gcp-ssh-key-add.sh     # GCP VM에 SSH 키 추가 (기존 VM용)
└── gcp-project-cleanup.sh # GCP 프로젝트 및 리소스 정리

../user-data.sh            # AWS EC2 초기화 스크립트
../startup-script.sh       # GCP Compute Engine 초기화 스크립트
```

## 🚀 사용법

[🚀 사용법](#-)

### 1. 설정 도우미 사용 (권장)

[1. 설정 도우미 사용 (권장)](#-1.-()))

**AWS 설정:**
```bash
# AWS 설정 도우미 실행
chmod +x scripts/aws-setup-helper.sh
./scripts/aws-setup-helper.sh

# 설정 완료 후 가상머신 생성
./scripts/aws-ec2-create.sh
```

**GCP 설정:**
```bash
# GCP 설정 도우미 실행
chmod +x scripts/gcp-setup-helper.sh
./scripts/gcp-setup-helper.sh

# 설정 완료 후 가상머신 생성
./scripts/gcp-compute-create.sh
```

**리소스 정리:**
```bash
# AWS 리소스 정리
chmod +x scripts/aws-resource-cleanup.sh
./scripts/aws-resource-cleanup.sh

# GCP 리소스 정리
chmod +x scripts/gcp-project-cleanup.sh
./scripts/gcp-project-cleanup.sh
```

### 2. 직접 실행

[2. 직접 실행](#-2.)

**AWS EC2 인스턴스 생성:**
```bash
# 1. 스크립트 실행 권한 부여
chmod +x scripts/aws-ec2-create.sh

# 2. AWS CLI 설정 확인
aws configure list
aws sts get-caller-identity

# 3. 스크립트 실행
./scripts/aws-ec2-create.sh
```

**GCP Compute Engine 인스턴스 생성:**
```bash
# 1. 스크립트 실행 권한 부여
chmod +x scripts/gcp-compute-create.sh

# 2. GCP CLI 설정 확인
gcloud auth list
gcloud config get-value project

# 3. 스크립트 실행
./scripts/gcp-compute-create.sh

# 4. SSH 키 문제 해결 (필요한 경우)
./scripts/gcp-ssh-key-add.sh
```

## ⚙️ 설정 변경

[⚙️ 설정 변경](#-)

### AWS 스크립트 설정

[AWS 스크립트 설정](#-aws)

`aws-ec2-create.sh` 파일의 상단 변수들을 수정하여 환경에 맞게 조정할 수 있습니다:

```bash
PROJECT_NAME="cloud-deployment"   # 프로젝트명
REGION="ap-northeast-2"           # AWS 리전
AZ="ap-northeast-2a"              # 가용영역
INSTANCE_TYPE="t3.medium"         # 인스턴스 타입
AMI_ID="ami-0c02fb55956c7d316"    # AMI ID
```

### GCP 스크립트 설정

[GCP 스크립트 설정](#-gcp)

`gcp-compute-create.sh` 파일의 상단 변수들을 수정하여 환경에 맞게 조정할 수 있습니다:

```bash
PROJECT_NAME="cloud-deployment"   # 프로젝트명
PROJECT_ID="cloud-deployment-2025-12345"  # GCP 프로젝트 ID
REGION="asia-northeast3"          # GCP 리전
ZONE="asia-northeast3-a"          # 존
MACHINE_TYPE="e2-medium"          # 머신 타입
```

## 📋 사전 요구사항

[📋 사전 요구사항](#-)

### AWS 사용 시

[AWS 사용 시](#-aws)
- [ ] AWS CLI 설치 및 설정
- [ ] AWS 계정 및 적절한 IAM 권한
- [ ] 기본 VPC 존재 확인
- [ ] SSH 키 페어 (자동 생성됨)

### GCP 사용 시

[GCP 사용 시](#-gcp)
- [ ] Google Cloud CLI 설치 및 설정
- [ ] GCP 프로젝트 생성 및 설정
- [ ] Compute Engine API 활성화
- [ ] SSH 키 생성 (`ssh-keygen -t rsa -b 4096`)

#### GCP 프로젝트 설정 방법

[GCP 프로젝트 설정 방법](#-gcp)
```bash
# 1. 프로젝트 목록 확인
gcloud projects list

# 2. 프로젝트 설정
gcloud config set project YOUR_PROJECT_ID
gcloud config set compute/region asia-northeast3
gcloud config set compute/zone asia-northeast3-a

# 3. 스크립트 실행 후 다른 터미널에서도 동일한 설정 적용
gcloud config set project YOUR_PROJECT_ID
gcloud config set compute/region asia-northeast3
gcloud config set compute/zone asia-northeast3-a
```

## 🔧 스크립트 기능

[🔧 스크립트 기능](#-)

### 공통 기능

[공통 기능](#-)
- ✅ 자동 리소스 생성 (VPC, 서브넷, 방화벽 규칙 등)
- ✅ 중복 생성 방지 (기존 리소스 확인)
- ✅ **재시작 안전성**: 중단되어도 다시 시작 시 기존 리소스 재사용
- ✅ **키 파일 재사용**: 기존 키 파일이 있으면 자동으로 재사용
- ✅ 색상 출력으로 진행 상황 표시
- ✅ 오류 처리 및 검증
- ✅ 상세한 로그 출력

### AWS 특화 기능

[AWS 특화 기능](#-aws)
- ✅ 보안 그룹 자동 생성 및 규칙 설정
- ✅ 키 페어 자동 생성
- ✅ Elastic IP 할당 옵션
- ✅ user-data 스크립트 실행
- ✅ **자동 리소스 정리**: 전체 AWS 리소스 일괄 삭제

### GCP 특화 기능

[GCP 특화 기능](#-gcp)
- ✅ **SSH 키 사전 등록**: 인스턴스 생성 전에 SSH 키를 프로젝트 메타데이터에 등록
- ✅ VPC 네트워크 및 서브넷 생성
- ✅ 방화벽 규칙 자동 생성
- ✅ OS Login SSH 키 설정
- ✅ startup-script 실행
- ✅ 정적 IP 할당 옵션
- ✅ **자동 프로젝트 정리**: 전체 GCP 프로젝트 및 리소스 일괄 삭제

## 🗑️ 리소스 정리

[🗑️ 리소스 정리](#-)

### 자동 정리 스크립트 (권장)

[자동 정리 스크립트 (권장)](#-()))

**AWS 리소스 정리:**
```bash
# 전체 AWS 리소스 자동 정리
chmod +x scripts/aws-resource-cleanup.sh
./scripts/aws-resource-cleanup.sh
```

#### AWS 정리 스크립트 기능

[AWS 정리 스크립트 기능](#-aws)
- ✅ **EC2 인스턴스 삭제**: 실행 중인 모든 인스턴스 종료 및 삭제
- ✅ **보안 그룹 삭제**: 프로젝트 관련 보안 그룹 삭제
- ✅ **키 페어 삭제**: AWS 키 페어 및 로컬 키 파일 삭제
- ✅ **Elastic IP 해제**: 할당된 Elastic IP 주소 해제
- ✅ **체크포인트 파일 정리**: 스크립트 체크포인트 파일 삭제
- ✅ **안전한 삭제**: 삭제 전 확인 및 단계별 진행 상황 표시

**GCP 리소스 정리:**
```bash
# 전체 GCP 리소스 자동 정리
chmod +x scripts/gcp-project-cleanup.sh
./scripts/gcp-project-cleanup.sh
```

### 수동 정리 (고급 사용자용)

[수동 정리 (고급 사용자용)](#-(-)))

**AWS 리소스 삭제:**
```bash
# 인스턴스 중지
aws ec2 stop-instances --instance-ids i-xxxxxxxx

# 인스턴스 삭제
aws ec2 terminate-instances --instance-ids i-xxxxxxxx

# 보안 그룹 삭제
aws ec2 delete-security-group --group-id sg-xxxxxxxx

# 키 페어 삭제
aws ec2 delete-key-pair --key-name cloud-deployment-key
```

**GCP 리소스 삭제:**
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

## 🔄 재시작 기능

[🔄 재시작 기능](#-)

### 스크립트 중단 시 대응

[스크립트 중단 시 대응](#-)
스크립트가 중간에 중단되어도 안전하게 다시 시작할 수 있습니다:

```bash
# 스크립트가 중단된 경우, 그냥 다시 실행
./scripts/aws-ec2-create.sh
./scripts/gcp-compute-create.sh
```

### 재시작 시 동작

[재시작 시 동작](#-)
1. **기존 리소스 확인**: 이미 생성된 리소스들을 자동으로 감지
2. **리소스 재사용**: 기존 리소스를 그대로 사용하여 계속 진행
3. **상태 복구**: 중지된 인스턴스는 자동으로 시작
4. **중복 방지**: 동일한 리소스는 다시 생성하지 않음

### 지원되는 재시작 시나리오

[지원되는 재시작 시나리오](#-)
- ✅ 네트워크 리소스 생성 중 중단
- ✅ 보안 그룹/방화벽 규칙 생성 중 중단
- ✅ 인스턴스 생성 중 중단
- ✅ IP 할당 중 중단
- ✅ 인스턴스가 중지된 상태에서 재시작

## 🔑 SSH 키 관리

[🔑 SSH 키 관리](#-ssh)

### GCP SSH 키 등록 방법

[GCP SSH 키 등록 방법](#-gcp-ssh)

GCP VM에 SSH로 접속하려면 공개키를 메타데이터에 등록해야 합니다. 스크립트는 세 가지 방법으로 SSH 키를 등록합니다:

> 📖 **상세 가이드**: [GCP_SSH_KEY_GUIDE.md](/mcp_knowledge_base/mcp_knowledge_base\cloud_master\textbook\Day1\scripts\GCP_SSH_KEY_GUIDE.md)에서 SSH 키 등록 방법과 우선순위에 대한 자세한 설명을 확인하세요.

#### 1. 자동 등록 (권장)

[1. 자동 등록 (권장)](#-1.-()))
`gcp-compute-create.sh` 스크립트는 **인스턴스 생성 전에** SSH 키를 자동으로 등록합니다:
- **OS Login 방식**: Google 계정으로 자동 인증
- **프로젝트 메타데이터**: 프로젝트 전체 VM에서 사용 가능 (Prerequisite)
- **인스턴스 메타데이터**: 특정 VM에서만 사용 가능

#### 2. 수동 등록 (문제 해결용)

[2. 수동 등록 (문제 해결용)](#-2.-(-)))
기존 VM에 SSH 키를 추가하려면 `gcp-ssh-key-add.sh` 스크립트를 사용하세요:

```bash
# SSH 키 추가 스크립트 실행
./scripts/gcp-ssh-key-add.sh
```

#### 3. SSH 연결 방법

[3. SSH 연결 방법](#-3.-ssh)

**방법 1: gcloud 명령어 (권장)**
```bash
gcloud compute ssh cloud-deployment-server --zone=asia-northeast3-a
```

**방법 2: 일반 SSH 명령어**
```bash
ssh -i cloud-deployment-key ubuntu@VM_EXTERNAL_IP
```

### 키 파일 재사용 기능

[키 파일 재사용 기능](#-)
스크립트는 기존 키 파일을 자동으로 감지하고 재사용합니다:

**AWS:**
- `cloud-deployment-key.pem` 파일이 있으면 재사용
- AWS에서 키 페어 존재 여부 확인
- 로컬 파일과 AWS 키 페어가 일치하지 않으면 새로 생성

**GCP:**
- `cloud-deployment-key.pub` 파일이 있으면 재사용 (공개키 우선)
- `cloud-deployment-key.pem` 파일도 확인하여 개인키 복사
- 키 파일 유효성 검사 수행
- 손상된 키 파일은 자동으로 재생성

### 키 파일 명명 규칙

[키 파일 명명 규칙](#-)
```
cloud-deployment-key       # 개인키 (SSH 연결용)
cloud-deployment-key.pub   # 공개키 (GCP OS Login용)
cloud-deployment-key.pem   # 개인키 백업 (호환성)
```

### 키 파일 재사용 시나리오

[키 파일 재사용 시나리오](#-)
1. **첫 실행**: 키 파일 생성 및 클라우드에 등록
2. **재실행**: 기존 키 파일 감지 → 재사용
3. **손상된 키**: 유효성 검사 실패 → 자동 재생성
4. **다른 프로젝트**: 프로젝트명이 다르면 새 키 생성

## 🐛 문제 해결

[🐛 문제 해결](#-)

### 일반적인 문제

[일반적인 문제](#-)
1. **권한 오류**: CLI 인증 및 권한 확인
2. **리소스 중복**: 기존 리소스 삭제 후 재실행
3. **네트워크 오류**: VPC 및 서브넷 설정 확인
4. **스크립트 중단**: 그냥 다시 실행하면 자동으로 복구

### SSH 연결 문제

[SSH 연결 문제](#-ssh)
1. **Permission denied (publickey)**: SSH 키가 VM에 등록되지 않음
   ```bash
   # 해결 방법: SSH 키 추가 스크립트 실행
   ./scripts/gcp-ssh-key-add.sh
   ```

2. **Connection timeout**: 방화벽 규칙 또는 네트워크 문제
   ```bash
   # 방화벽 규칙 확인
   gcloud compute firewall-rules list --filter="name:cloud-deployment-allow-ssh"
   
   # 인스턴스 상태 확인
   gcloud compute instances describe cloud-deployment-server --zone=asia-northeast3-a
   ```

3. **SSH 키 파일 권한 오류**: 키 파일 권한 설정
   ```bash
   # 개인키 파일 권한 설정
   chmod 400 cloud-deployment-key
   
   # 공개키 파일 권한 설정
   chmod 644 cloud-deployment-key.pub
   ```

4. **잘못된 사용자명**: 사용자 계정 확인
   ```bash
   # GCP OS Login 사용자 확인
   gcloud config get-value account
   
   # 또는 Ubuntu 기본 사용자 사용
   ssh -i cloud-deployment-key ubuntu@VM_EXTERNAL_IP
   ```

### 로그 확인

[로그 확인](#-)
- AWS: CloudTrail 및 EC2 콘솔 로그
- GCP: Cloud Logging 및 Compute Engine 로그

## 📞 지원

[📞 지원](#-)

문제가 발생하면 다음을 확인하세요:
1. CLI 설정 및 인증 상태
2. 네트워크 연결 상태
3. 클라우드 서비스 상태
4. 스크립트 로그 출력

## 📝 라이선스

[📝 라이선스](#-)

이 스크립트들은 MCP Cloud 프로젝트의 일부로 MIT 라이선스 하에 제공됩니다.


---

<div align="center">

[🏠 홈](/mcp_knowledge_base/index.md) | [📚 전체 커리큘럼](/mcp_knowledge_base/curriculum.md) | [🔗 학습 경로](/mcp_knowledge_base/cloud_master/learning-path.md)

</div>

### 📧 연락처

[📧 연락처](#-)
- **이메일**: inhwan.jung@gmail.com
- **GitHub**: [프로젝트 저장소](https://github.com/jungfrau70/aws_gcp.git)

---

<div align="center">

[🏠 홈](/mcp_knowledge_base/index.md) | [📚 전체 커리큘럼](/mcp_knowledge_base/curriculum.md) | [🔗 학습 경로](/mcp_knowledge_base/cloud_master/learning-path.md)

</div>
