# 가상머신 생성 스크립트

이 디렉토리는 AWS와 GCP에서 가상머신을 자동으로 생성하는 스크립트들을 포함합니다.

## 📁 파일 구조

```
scripts/
├── README.md              # 이 파일
├── aws-ec2-create.sh      # AWS EC2 인스턴스 자동 생성
└── gcp-compute-create.sh  # GCP Compute Engine 인스턴스 자동 생성

../user-data.sh            # AWS EC2 초기화 스크립트
../startup-script.sh       # GCP Compute Engine 초기화 스크립트
```

## 🚀 사용법

### AWS EC2 인스턴스 생성

```bash
# 1. 스크립트 실행 권한 부여
chmod +x scripts/aws-ec2-create.sh

# 2. AWS CLI 설정 확인
aws configure list
aws sts get-caller-identity

# 3. 스크립트 실행
./scripts/aws-ec2-create.sh
```

### GCP Compute Engine 인스턴스 생성

```bash
# 1. 스크립트 실행 권한 부여
chmod +x scripts/gcp-compute-create.sh

# 2. GCP CLI 설정 확인
gcloud auth list
gcloud config get-value project

# 3. 스크립트 실행
./scripts/gcp-compute-create.sh
```

## ⚙️ 설정 변경

### AWS 스크립트 설정

`aws-ec2-create.sh` 파일의 상단 변수들을 수정하여 환경에 맞게 조정할 수 있습니다:

```bash
PROJECT_NAME="mcp-cloud"           # 프로젝트명
REGION="ap-northeast-2"           # AWS 리전
AZ="ap-northeast-2a"              # 가용영역
INSTANCE_TYPE="t3.medium"         # 인스턴스 타입
AMI_ID="ami-0c02fb55956c7d316"    # AMI ID
```

### GCP 스크립트 설정

`gcp-compute-create.sh` 파일의 상단 변수들을 수정하여 환경에 맞게 조정할 수 있습니다:

```bash
PROJECT_NAME="mcp-cloud"          # 프로젝트명
PROJECT_ID=""                     # GCP 프로젝트 ID (자동 감지)
REGION="asia-northeast3"          # GCP 리전
ZONE="asia-northeast3-a"          # 존
MACHINE_TYPE="e2-medium"          # 머신 타입
```

## 📋 사전 요구사항

### AWS 사용 시
- [ ] AWS CLI 설치 및 설정
- [ ] AWS 계정 및 적절한 IAM 권한
- [ ] 기본 VPC 존재 확인
- [ ] SSH 키 페어 (자동 생성됨)

### GCP 사용 시
- [ ] Google Cloud CLI 설치 및 설정
- [ ] GCP 프로젝트 생성 및 설정
- [ ] Compute Engine API 활성화
- [ ] SSH 키 생성 (`ssh-keygen -t rsa -b 4096`)

## 🔧 스크립트 기능

### 공통 기능
- ✅ 자동 리소스 생성 (VPC, 서브넷, 방화벽 규칙 등)
- ✅ 중복 생성 방지 (기존 리소스 확인)
- ✅ 색상 출력으로 진행 상황 표시
- ✅ 오류 처리 및 검증
- ✅ 상세한 로그 출력

### AWS 특화 기능
- ✅ 보안 그룹 자동 생성 및 규칙 설정
- ✅ 키 페어 자동 생성
- ✅ Elastic IP 할당 옵션
- ✅ user-data 스크립트 실행

### GCP 특화 기능
- ✅ VPC 네트워크 및 서브넷 생성
- ✅ 방화벽 규칙 자동 생성
- ✅ OS Login SSH 키 설정
- ✅ startup-script 실행
- ✅ 정적 IP 할당 옵션

## 🗑️ 리소스 정리

### AWS 리소스 삭제
```bash
# 인스턴스 중지
aws ec2 stop-instances --instance-ids i-xxxxxxxx

# 인스턴스 삭제
aws ec2 terminate-instances --instance-ids i-xxxxxxxx

# 보안 그룹 삭제
aws ec2 delete-security-group --group-id sg-xxxxxxxx

# 키 페어 삭제
aws ec2 delete-key-pair --key-name mcp-cloud-key
```

### GCP 리소스 삭제
```bash
# 인스턴스 삭제
gcloud compute instances delete mcp-cloud-server --zone=asia-northeast3-a --quiet

# 방화벽 규칙 삭제
gcloud compute firewall-rules delete mcp-cloud-allow-ssh --quiet
gcloud compute firewall-rules delete mcp-cloud-allow-http --quiet
gcloud compute firewall-rules delete mcp-cloud-allow-https --quiet
gcloud compute firewall-rules delete mcp-cloud-allow-app --quiet

# 서브넷 삭제
gcloud compute networks subnets delete mcp-cloud-subnet --region=asia-northeast3 --quiet

# VPC 삭제
gcloud compute networks delete mcp-cloud-vpc --quiet
```

## 🐛 문제 해결

### 일반적인 문제
1. **권한 오류**: CLI 인증 및 권한 확인
2. **리소스 중복**: 기존 리소스 삭제 후 재실행
3. **네트워크 오류**: VPC 및 서브넷 설정 확인

### 로그 확인
- AWS: CloudTrail 및 EC2 콘솔 로그
- GCP: Cloud Logging 및 Compute Engine 로그

## 📞 지원

문제가 발생하면 다음을 확인하세요:
1. CLI 설정 및 인증 상태
2. 네트워크 연결 상태
3. 클라우드 서비스 상태
4. 스크립트 로그 출력

## 📝 라이선스

이 스크립트들은 MCP Cloud 프로젝트의 일부로 MIT 라이선스 하에 제공됩니다.
