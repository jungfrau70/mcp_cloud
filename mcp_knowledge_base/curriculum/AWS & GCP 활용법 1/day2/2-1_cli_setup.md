# 2-1. AWS/GCP CLI 설치 및 인증

## 학습 목표
- AWS CLI 설치 및 구성
- GCP CLI (gcloud) 설치 및 구성
- CLI를 통한 인증 및 권한 관리
- CLI 명령어 기본 사용법
- 자동화 스크립트 작성 기초

---

## AWS CLI 설치 및 설정

### Windows에서 설치
1. **MSI 설치 프로그램 다운로드**:
   - https://aws.amazon.com/ko/cli/
   - Windows x86_64 MSI 선택

2. **설치 실행**:
   ```bash
   # 설치 확인
   aws --version
   ```

3. **환경 변수 설정**:
   - `C:\Program Files\Amazon\AWSCLIV2`를 PATH에 추가

### macOS에서 설치
```bash
# Homebrew 사용
brew install awscli

# 또는 공식 설치 프로그램
curl "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "AWSCLIV2.pkg"
sudo installer -pkg AWSCLIV2.pkg -target /
```

### Linux에서 설치
```bash
# Ubuntu/Debian
sudo apt update
sudo apt install awscli

# CentOS/RHEL
sudo yum install awscli

# 또는 공식 설치 스크립트
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
```

---

## AWS CLI 구성 및 인증

### 기본 구성
```bash
# 기본 구성
aws configure

# 입력 정보:
# AWS Access Key ID: [YOUR_ACCESS_KEY]
# AWS Secret Access Key: [YOUR_SECRET_KEY]
# Default region name: ap-northeast-2
# Default output format: json
```

### 프로필별 구성
```bash
# 개발용 프로필
aws configure --profile dev

# 프로덕션용 프로필
aws configure --profile prod

# 프로필 사용
aws s3 ls --profile dev
```

### 구성 파일 위치
- **Windows**: `%UserProfile%\.aws\config`
- **macOS/Linux**: `~/.aws/config`

---

## GCP CLI (gcloud) 설치

### Windows에서 설치
1. **Google Cloud SDK 설치 프로그램**:
   - https://cloud.google.com/sdk/docs/install
   - Windows x86_64 선택

2. **설치 후 초기화**:
   ```bash
   gcloud init
   ```

### macOS에서 설치
```bash
# Homebrew 사용
brew install --cask google-cloud-sdk

# 또는 공식 설치 스크립트
curl https://sdk.cloud.google.com | bash
exec -l $SHELL
```

### Linux에서 설치
```bash
# 공식 설치 스크립트
curl https://sdk.cloud.google.com | bash
exec -l $SHELL

# 또는 패키지 매니저
# Ubuntu/Debian
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
sudo apt-get update && sudo apt-get install google-cloud-cli
```

---

## GCP CLI 초기화 및 인증

### 초기 설정
```bash
# 초기화
gcloud init

# 프로젝트 선택
gcloud config set project [PROJECT_ID]

# 기본 리전 설정
gcloud config set compute/region asia-northeast3
```

### 서비스 계정 키 인증
```bash
# JSON 키 파일로 인증
gcloud auth activate-service-account --key-file=path/to/service-account-key.json

# 또는 사용자 계정 인증
gcloud auth login
```

### 구성 확인
```bash
# 현재 구성 확인
gcloud config list

# 활성 계정 확인
gcloud auth list

# 프로젝트 확인
gcloud config get-value project
```

---

## CLI 기본 명령어

### AWS CLI 기본 명령어
```bash
# S3 버킷 목록
aws s3 ls

# EC2 인스턴스 목록
aws ec2 describe-instances

# IAM 사용자 목록
aws iam list-users

# CloudFormation 스택 목록
aws cloudformation list-stacks

# 로그 그룹 목록
aws logs describe-log-groups
```

### GCP CLI 기본 명령어
```bash
# Compute Engine 인스턴스 목록
gcloud compute instances list

# Cloud Storage 버킷 목록
gsutil ls

# Cloud SQL 인스턴스 목록
gcloud sql instances list

# IAM 정책 확인
gcloud projects get-iam-policy [PROJECT_ID]

# 로그 확인
gcloud logging read "resource.type=gce_instance"
```

---

## 고급 CLI 기능

### AWS CLI 고급 기능
```bash
# JSON 출력 포맷팅
aws ec2 describe-instances --output table

# JMESPath 쿼리
aws ec2 describe-instances --query 'Reservations[].Instances[?State.Name==`running`]'

# 페이지네이션
aws s3api list-objects-v2 --bucket my-bucket --max-items 10 --starting-token [TOKEN]

# 자동 완성 활성화
aws_completer
```

### GCP CLI 고급 기능
```bash
# 출력 포맷 지정
gcloud compute instances list --format="table(name,zone,status)"

# 필터링
gcloud compute instances list --filter="status=RUNNING"

# 정렬
gcloud compute instances list --sort-by=~creationTimestamp

# 자동 완성 활성화
gcloud completion bash
```

---

## 보안 및 권한 관리

### AWS IAM 정책 예시
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:DescribeInstances",
        "ec2:DescribeSecurityGroups",
        "s3:ListBucket",
        "s3:GetObject"
      ],
      "Resource": "*"
    }
  ]
}
```

### GCP IAM 역할 예시
```bash
# 기본 역할 할당
gcloud projects add-iam-policy-binding [PROJECT_ID] \
    --member="user:user@example.com" \
    --role="roles/compute.viewer"

# 커스텀 역할 생성
gcloud iam roles create customViewer \
    --project=[PROJECT_ID] \
    --title="Custom Viewer" \
    --description="Custom viewer role" \
    --permissions="compute.instances.list,compute.instances.get"
```

---

## 자동화 스크립트 작성

### Bash 스크립트 예시 (AWS)
```bash
#!/bin/bash
# AWS 리소스 백업 스크립트

# 환경 변수 설정
export AWS_PROFILE=prod
export AWS_DEFAULT_REGION=ap-northeast-2

# EC2 인스턴스 백업
echo "EC2 인스턴스 백업 시작..."
aws ec2 describe-instances --query 'Reservations[].Instances[?State.Name==`running`].[InstanceId,InstanceType,State.Name]' --output table

# S3 버킷 백업
echo "S3 버킷 백업 시작..."
aws s3 ls --output table

echo "백업 완료!"
```

### PowerShell 스크립트 예시 (AWS)
```powershell
# AWS 리소스 모니터링 스크립트

# AWS 프로필 설정
$env:AWS_PROFILE = "prod"
$env:AWS_DEFAULT_REGION = "ap-northeast-2"

# EC2 인스턴스 상태 확인
Write-Host "EC2 인스턴스 상태 확인 중..." -ForegroundColor Green
aws ec2 describe-instances --query 'Reservations[].Instances[?State.Name==`running`].[InstanceId,InstanceType,State.Name]' --output table

# S3 버킷 크기 확인
Write-Host "S3 버킷 크기 확인 중..." -ForegroundColor Green
aws s3 ls --human-readable --summarize
```

---

## 문제 해결 및 디버깅

### AWS CLI 문제 해결
```bash
# 디버그 모드 활성화
export AWS_CLI_DEBUG=1

# 로그 확인
aws sts get-caller-identity

# 권한 확인
aws iam get-user

# 리전 확인
aws configure list
```

### GCP CLI 문제 해결
```bash
# 디버그 모드 활성화
gcloud config set core/log_level debug

# 인증 상태 확인
gcloud auth list

# 프로젝트 확인
gcloud config get-value project

# API 활성화 확인
gcloud services list --enabled
```

---

## 모범 사례

### 보안 모범 사례
- [ ] **액세스 키 순환**: 90일마다 변경
- [ ] **최소 권한 원칙**: 필요한 권한만 부여
- [ ] **MFA 활성화**: 모든 계정에 적용
- [ ] **감사 로그**: 모든 CLI 활동 기록

### 성능 모범 사례
- [ ] **지역 설정**: 가까운 리전 사용
- [ ] **출력 포맷**: 필요한 정보만 요청
- [ ] **필터링**: 서버 사이드에서 처리
- [ ] **배치 처리**: 여러 명령어를 하나로 통합

---

## 실습 과제

### 기본 실습
1. **AWS CLI 설치 및 구성**
2. **GCP CLI 설치 및 초기화**
3. **기본 명령어 실행**
4. **프로필 생성 및 전환**

### 고급 실습
1. **자동화 스크립트 작성**
2. **권한 관리 및 정책 설정**
3. **모니터링 및 알림 설정**
4. **백업 및 복구 자동화**

---

## 다음 단계
- 클라우드 핵심 서비스 개념 학습
- VPC, S3, EC2 등 기본 서비스 이해
- 실제 리소스 생성 및 관리 실습

---

## 참고 자료
- [AWS CLI 사용자 가이드](https://docs.aws.amazon.com/cli/latest/userguide/)
- [GCP CLI 문서](https://cloud.google.com/sdk/docs)
- [AWS CLI 명령어 참조](https://docs.aws.amazon.com/cli/latest/reference/)
- [GCP CLI 명령어 참조](https://cloud.google.com/sdk/gcloud/reference)
