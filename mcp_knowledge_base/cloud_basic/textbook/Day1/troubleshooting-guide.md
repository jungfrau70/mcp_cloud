# 트러블슈팅 가이드


## 📋 목차

[📋 목차](#목차)
1. [일반적인 문제](#일반적인-문제)
2. [AWS 관련 문제](#aws-관련-문제)
3. [GCP 관련 문제](#gcp-관련-문제)
4. [네트워크 문제](#네트워크-문제)
5. [권한 문제](#권한-문제)

---

## 🔧 일반적인 문제

### 1.1 CLI 설치 문제

[1.1 CLI 설치 문제](#11-cli-설치-문제)

#### AWS CLI 설치 실패

[AWS CLI 설치 실패](#aws-cli-설치-실패)
```bash
# Windows (PowerShell)
winget install Amazon.AWSCLI

# macOS
brew install awscli

# Ubuntu
sudo apt update
sudo apt install awscli

# 설치 확인
aws --version
```

#### gcloud CLI 설치 실패

[gcloud CLI 설치 실패](#gcloud-cli-설치-실패)
```bash
# Windows
winget install Google.CloudSDK

# macOS
brew install google-cloud-sdk

# Ubuntu
curl https:///sdk.cloud.google.com | bash
exec -l $SHELL

# 설치 확인
gcloud --version
```

### 1.2 인증 문제

[1.2 인증 문제](#12-인증-문제)

#### AWS 인증 실패

[AWS 인증 실패](#aws-인증-실패)
```bash
# 인증 상태 확인
aws sts get-caller-identity

# 인증 재설정
aws configure

# 또는 SSO 사용
aws sso login
```

#### GCP 인증 실패

[GCP 인증 실패](#gcp-인증-실패)
```bash
# 인증 상태 확인
gcloud auth list

# 인증 재설정
gcloud auth login

# 프로젝트 설정 확인
gcloud config get-value project
```

---

## 🔐 AWS 관련 문제

### 2.1 EC2 인스턴스 문제

[2.1 EC2 인스턴스 문제](#21-ec2-인스턴스-문제)

#### SSH 접속 실패

[SSH 접속 실패](#ssh-접속-실패)
```bash
# 키 파일 권한 확인
chmod 400 cloud-student-key.pem

# 인스턴스 상태 확인
aws ec2 describe-instances --instance-ids i-1234567890abcdef0

# 보안 그룹 확인
aws ec2 describe-security-groups --group-names web-server-sg
```

#### 인스턴스 시작 실패

[인스턴스 시작 실패](#인스턴스-시작-실패)
```bash
# 인스턴스 상태 확인
aws ec2 describe-instances --instance-ids i-1234567890abcdef0

# 이벤트 로그 확인
aws ec2 describe-instance-status --instance-ids i-1234567890abcdef0
```

### 2.2 S3 문제

[2.2 S3 문제](#22-s3-문제)

#### 버킷 생성 실패

[버킷 생성 실패](#버킷-생성-실패)
```bash
# 버킷 이름 중복 확인
aws s3 ls | grep bucket-name

# 다른 리전에서 생성 시도
aws s3 mb s3://bucket-name --region us-west-2
```

#### 파일 업로드 실패

[파일 업로드 실패](#파일-업로드-실패)
```bash
# 권한 확인
aws s3api get-bucket-acl --bucket bucket-name

# 버킷 정책 확인
aws s3api get-bucket-policy --bucket bucket-name
```

---

## ☁️ GCP 관련 문제

### 3.1 Compute Engine 문제

[3.1 Compute Engine 문제](#31-compute-engine-문제)

#### SSH 접속 실패

[SSH 접속 실패](#ssh-접속-실패)
```bash
# 인스턴스 상태 확인
gcloud compute instances describe INSTANCE_NAME --zone=ZONE

# 방화벽 규칙 확인
gcloud compute firewall-rules list

# SSH 키 등록
gcloud compute os-login ssh-keys add --key-file=~/.ssh/id_rsa.pub
```

#### 인스턴스 시작 실패

[인스턴스 시작 실패](#인스턴스-시작-실패)
```bash
# 인스턴스 상태 확인
gcloud compute instances describe INSTANCE_NAME --zone=ZONE

# 이벤트 로그 확인
gcloud logging read "resource.type=gce_instance" --limit=10
```

### 3.2 Cloud Storage 문제

[3.2 Cloud Storage 문제](#32-cloud-storage-문제)

#### 버킷 생성 실패

[버킷 생성 실패](#버킷-생성-실패)
```bash
# 버킷 이름 중복 확인
gsutil ls | grep bucket-name

# 다른 리전에서 생성 시도
gsutil mb -l asia-northeast3 gs://bucket-name
```

#### 파일 업로드 실패

[파일 업로드 실패](#파일-업로드-실패)
```bash
# 권한 확인
gsutil iam get gs://bucket-name

# 버킷 정책 확인
gsutil iam get gs://bucket-name
```

---

## 🌐 네트워크 문제

### 4.1 연결 문제

[4.1 연결 문제](#41-연결-문제)

#### 인터넷 연결 확인

[인터넷 연결 확인](#인터넷-연결-확인)
```bash
# ping 테스트
ping google.com

# DNS 확인
nslookup google.com

# 포트 연결 확인
telnet google.com 80
```

#### 방화벽 문제

[방화벽 문제](#방화벽-문제)
```bash
# Windows 방화벽 확인
netsh advfirewall show allprofiles

# Linux 방화벽 확인
sudo ufw status

# 포트 열기 (Linux)
sudo ufw allow 22
sudo ufw allow 80
sudo ufw allow 443
```

### 4.2 프록시 문제

[4.2 프록시 문제](#42-프록시-문제)

#### 프록시 설정

[프록시 설정](#프록시-설정)
```bash
# AWS CLI 프록시 설정
export HTTP_PROXY=http://proxy.company.com:8080
export HTTPS_PROXY=http://proxy.company.com:8080

# gcloud 프록시 설정
gcloud config set proxy/type http
gcloud config set proxy/address proxy.company.com
gcloud config set proxy/port 8080
```

---

## 🔑 권한 문제

### 5.1 AWS 권한 문제

[5.1 AWS 권한 문제](#51-aws-권한-문제)

#### IAM 권한 확인

[IAM 권한 확인](#iam-권한-확인)
```bash
# 현재 사용자 권한 확인
aws sts get-caller-identity

# 사용자 정책 확인
aws iam list-attached-user-policies --user-name USER_NAME

# 그룹 정책 확인
aws iam list-attached-group-policies --group-name GROUP_NAME
```

#### 권한 부족 오류

[권한 부족 오류](#권한-부족-오류)
```bash
# 필요한 권한 확인
aws iam simulate-principal-policy /
  --policy-source-arn arn:aws:iam::ACCOUNT:user/USER_NAME /
  --action-names ec2:RunInstances /
  --resource-arns arn:aws:ec2:REGION:ACCOUNT:instance/*
```

### 5.2 GCP 권한 문제

[5.2 GCP 권한 문제](#52-gcp-권한-문제)

#### IAM 권한 확인

[IAM 권한 확인](#iam-권한-확인)
```bash
# 현재 사용자 권한 확인
gcloud auth list

# 프로젝트 권한 확인
gcloud projects get-iam-policy PROJECT_ID

# 서비스 계정 권한 확인
gcloud iam service-accounts get-iam-policy SERVICE_ACCOUNT_EMAIL
```

#### 권한 부족 오류

[권한 부족 오류](#권한-부족-오류)
```bash
# 필요한 권한 확인
gcloud iam roles describe roles/compute.instanceAdmin

# 권한 부여
gcloud projects add-iam-policy-binding PROJECT_ID /
  --member="user:USER_EMAIL" /
  --role="roles/compute.instanceAdmin"
```

---

## 🆘 추가 도움

[🆘 추가 도움](#추가-도움)

### 6.1 로그 확인

[6.1 로그 확인](#61-로그-확인)

#### AWS CloudTrail

[AWS CloudTrail](#aws-cloudtrail)
```bash
# API 호출 로그 확인
aws logs describe-log-groups --log-group-name-prefix /aws/cloudtrail

# 특정 이벤트 검색
aws logs filter-log-events /
  --log-group-name /aws/cloudtrail /
  --start-time 1640995200000 /
  --end-time 1641081600000
```

#### GCP Cloud Logging

[GCP Cloud Logging](#gcp-cloud-logging)
```bash
# 로그 검색
gcloud logging read "resource.type=gce_instance" --limit=10

# 특정 시간대 로그
gcloud logging read "timestamp>=/"2024-01-01T00:00:00Z/"" --limit=10
```

### 6.2 지원 채널

[6.2 지원 채널](#62-지원-채널)

#### AWS 지원

[AWS 지원](#aws-지원)
- [AWS Support Center](https:///console.aws.amazon.com/support/)
- [AWS Documentation](https:///docs.aws.amazon.com/)
- [AWS Forums](https:///forums.aws.amazon.com/)

#### GCP 지원

[GCP 지원](#gcp-지원)
- [GCP Support](https:///cloud.google.com/support/)
- [GCP Documentation](https:///cloud.google.com/docs/)
- [GCP Community](https:///cloud.google.com/community/)

---

## ✅ 문제 해결 체크리스트

[✅ 문제 해결 체크리스트](#문제-해결-체크리스트)

- [ ] CLI 설치 및 버전 확인
- [ ] 인증 설정 확인
- [ ] 네트워크 연결 확인
- [ ] 권한 설정 확인
- [ ] 로그 확인 및 분석
- [ ] 지원 채널 문의

---

## 🚀 다음 단계

[🚀 다음 단계](#다음-단계)

문제가 해결되었다면 원래 실습으로 돌아가세요. 문제가 지속되면 지원 채널에 문의하세요.


---


### 📧 연락처

[📧 연락처](#연락처)
- **이메일**: inhwan.jung@gmail.com
- **GitHub**: [프로젝트 저장소](https:///github.com/jungfrau70/aws_gcp.git)

---



<div align="center">

[← 이전: Cloud Basic 1일차 메인](/mcp_knowledge_base/README.md) | [📚 전체 커리큘럼](/mcp_knowledge_base/curriculum.md) | [🏠 학습 경로로 돌아가기](/mcp_knowledge_base/index.md) | [📋 학습 경로](/mcp_knowledge_base/learning-path.md)

</div>