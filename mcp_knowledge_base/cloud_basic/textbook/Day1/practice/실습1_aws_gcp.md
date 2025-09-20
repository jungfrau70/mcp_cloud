
## 🎯 실습 목표

[🎯 실습 목표](#실습-목표)

이 실습을 통해 다음을 달성할 수 있습니다:

- **이론과 실습의 결합**: 학습한 이론을 실제로 적용해보는 경험
- **문제해결 능력 향상**: 실습 중 발생하는 문제를 해결하는 능력 개발
- **실무 적용 능력**: 학습한 내용을 실제 업무에 적용할 수 있는 능력 향상
- **자신감 향상**: 성공적인 실습 완료를 통한 학습 자신감 증진

**💡 팁**: 실습 중 문제가 발생하면 문제해결 가이드를 참고하세요!

# 🎯 AWS & GCP 기초 실습 통합 가이드


## 📋 개요

[📋 개요](#개요)

**목적**: AWS와 GCP 환경에서 핵심 기초 서비스를 직접 실습하고 두 플랫폼을 비교 분석
**범위**: 
- AWS & GCP 계정 생성 및 설정
- IAM 사용자/서비스 계정 및 권한 관리
- 가상머신 서비스 (EC2 vs Compute Engine)
- 스토리지 서비스 (S3 vs Cloud Storage)
- 네트워킹 및 보안 설정

---

## 🏗️ 1단계: AWS & GCP 환경 준비

[🏗️ 1단계: AWS & GCP 환경 준비](#1단계-aws-gcp-환경-준비)

### 1.1 AWS 계정 생성 및 설정

[1.1 AWS 계정 생성 및 설정](#11-aws-계정-생성-및-설정)

#### 🌐 웹콘솔 방식

[🌐 웹콘솔 방식](#웹콘솔-방식)
```markdown
1. [AWS 홈페이지](https:///aws.amazon.com) 접속
2. "AWS 계정 생성" 클릭
3. 이메일 주소, 비밀번호, 계정 이름 입력
4. 계정 유형: "개인" 선택
5. 신용카드 정보 등록 (Free Tier 사용)
6. 전화번호 인증 완료
7. 지원 플랜: "기본 지원 - 무료" 선택
8. 계정 생성 완료
```

#### 💻 CLI 방식

[💻 CLI 방식](#cli-방식)
```bash
# AWS CLI 설치
winget install Amazon.AWSCLI  # Windows
brew install awscli           # macOS
sudo apt install awscli       # Ubuntu

# AWS CLI 설정
aws configure
# AWS Access Key ID: [입력]
# AWS Secret Access Key: [입력]
# Default region name: ap-northeast-2
# Default output format: json
```

### 1.2 GCP 계정 생성 및 설정

[1.2 GCP 계정 생성 및 설정](#12-gcp-계정-생성-및-설정)

#### 🌐 웹콘솔 방식

[🌐 웹콘솔 방식](#웹콘솔-방식)
```markdown
1. [Google Cloud Platform](https:///cloud.google.com) 접속
2. "무료로 시작하기" 클릭
3. Google 계정으로 로그인
4. 국가/지역: "대한민국" 선택
5. 계정 유형: "개인" 선택
6. 약관 동의 및 계정 생성
7. 결제 정보 등록 ($300 크레딧 활성화)
8. 프로젝트 생성: "cloud-student-project"
```

#### 💻 CLI 방식

[💻 CLI 방식](#cli-방식)
```bash
# Google Cloud SDK 설치
winget install Google.CloudSDK  # Windows
brew install google-cloud-sdk   # macOS
curl https:///sdk.cloud.google.com | bash  # Ubuntu

# gcloud 초기화
gcloud init

# 프로젝트 설정
gcloud config set project cloud-student-project
```

---

## 👥 2단계: IAM 사용자 및 권한 관리

[👥 2단계: IAM 사용자 및 권한 관리](#2단계-iam-사용자-및-권한-관리)

### 2.1 AWS IAM 사용자 생성

[2.1 AWS IAM 사용자 생성](#21-aws-iam-사용자-생성)

#### 🌐 웹콘솔 방식

[🌐 웹콘솔 방식](#웹콘솔-방식)
```markdown
1. AWS Console → "IAM" 검색
2. "사용자" → "사용자 추가" 클릭
3. 사용자 이름: "cloud-student"
4. 액세스 유형: "프로그래밍 방식 액세스" 선택
5. "다음: 권한" 클릭
6. "기존 정책 직접 연결" 선택
7. 권한 정책 선택:
   - AmazonEC2FullAccess
   - AmazonS3FullAccess
   - AmazonRDSFullAccess
8. "다음: 태그" → "다음: 검토" → "사용자 만들기"
9. 액세스 키 ID와 비밀 액세스 키 저장
```

#### 💻 CLI 방식

[💻 CLI 방식](#cli-방식)
```bash
# IAM 사용자 생성
aws iam create-user --user-name cloud-student

# 사용자에게 정책 연결
aws iam attach-user-policy /
  --user-name cloud-student /
  --policy-arn arn:aws:iam::aws:policy/AmazonEC2FullAccess

aws iam attach-user-policy /
  --user-name cloud-student /
  --policy-arn arn:aws:iam::aws:policy/AmazonS3FullAccess

# 액세스 키 생성
aws iam create-access-key --user-name cloud-student
```

### 2.2 GCP IAM 서비스 계정 생성

[2.2 GCP IAM 서비스 계정 생성](#22-gcp-iam-서비스-계정-생성)

#### 🌐 웹콘솔 방식

[🌐 웹콘솔 방식](#웹콘솔-방식)
```markdown
1. GCP Console → "IAM 및 관리자" → "서비스 계정" 클릭
2. "서비스 계정 만들기" 클릭
3. 서비스 계정 이름: "cloud-student-sa"
4. 서비스 계정 ID: "cloud-student-sa"
5. 설명: "Cloud Student Service Account"
6. "만들기 및 계속" 클릭
7. 역할 선택:
   - Compute Instance Admin
   - Storage Admin
   - Cloud SQL Admin
8. "완료" 클릭
```

#### 💻 CLI 방식

[💻 CLI 방식](#cli-방식)
```bash
# 서비스 계정 생성
gcloud iam service-accounts create cloud-student-sa /
  --display-name="Cloud Student Service Account"

# 서비스 계정에 역할 부여
gcloud projects add-iam-policy-binding cloud-student-project /
  --member="serviceAccount:cloud-student-sa@cloud-student-project.iam.gserviceaccount.com" /
  --role="roles/compute.instanceAdmin"

# 서비스 계정 키 생성
gcloud iam service-accounts keys create cloud-student-key.json /
  --iam-account=cloud-student-sa@cloud-student-project.iam.gserviceaccount.com
```

---

## 💻 3단계: 가상머신 서비스 실습

[💻 3단계: 가상머신 서비스 실습](#3단계-가상머신-서비스-실습)

### 3.1 AWS EC2 인스턴스 생성

[3.1 AWS EC2 인스턴스 생성](#31-aws-ec2-인스턴스-생성)

#### 🌐 웹콘솔 방식

[🌐 웹콘솔 방식](#웹콘솔-방식)
```markdown
1. AWS Console → "EC2" 검색
2. "인스턴스 시작" 클릭
3. AMI 선택: "Amazon Linux 2 AMI (HVM)" 선택
4. 인스턴스 유형: "t2.micro" (Free Tier)
5. "다음: 인스턴스 세부 정보 구성" 클릭
6. "다음: 스토리지 추가" 클릭
7. "다음: 태그 추가" 클릭
8. "다음: 보안 그룹 구성" 클릭
9. 보안 그룹 이름: "web-server-sg"
10. 규칙 추가:
    - SSH (22) - 내 IP
    - HTTP (80) - 어디서나
    - HTTPS (443) - 어디서나
11. "검토 및 시작" → "시작" 클릭
12. 키 페어 선택: "새 키 페어 생성"
13. 키 페어 이름: "cloud-student-key"
14. "인스턴스 시작" 클릭
```

#### 💻 CLI 방식

[💻 CLI 방식](#cli-방식)
```bash
# 키 페어 생성
aws ec2 create-key-pair /
  --key-name cloud-student-key /
  --query 'KeyMaterial' /
  --output text > cloud-student-key.pem

# 보안 그룹 생성
aws ec2 create-security-group /
  --group-name web-server-sg /
  --description "Security group for web server"

# 보안 그룹 규칙 추가
aws ec2 authorize-security-group-ingress /
  --group-name web-server-sg /
  --protocol tcp /
  --port 22 /
  --cidr 0.0.0.0/0

# EC2 인스턴스 시작
aws ec2 run-instances /
  --image-id ami-0c76973fbe0ee100c /
  --count 1 /
  --instance-type t2.micro /
  --key-name cloud-student-key /
  --security-groups web-server-sg
```

### 3.2 GCP Compute Engine 인스턴스 생성

[3.2 GCP Compute Engine 인스턴스 생성](#32-gcp-compute-engine-인스턴스-생성)

#### 🌐 웹콘솔 방식

[🌐 웹콘솔 방식](#웹콘솔-방식)
```markdown
1. GCP Console → "Compute Engine" → "VM 인스턴스" 클릭
2. "인스턴스 만들기" 클릭
3. 인스턴스 이름: "cloud-student-server"
4. 리전: "asia-northeast3 (서울)"
5. 영역: "asia-northeast3-a"
6. 머신 유형: "e2-micro" (Free Tier)
7. 부팅 디스크: "Ubuntu 22.04 LTS"
8. 방화벽: "HTTP 트래픽 허용", "HTTPS 트래픽 허용" 체크
9. "만들기" 클릭
```

#### 💻 CLI 방식

[💻 CLI 방식](#cli-방식)
```bash
# 방화벽 규칙 생성
gcloud compute firewall-rules create allow-http-https /
  --allow tcp:80,tcp:443 /
  --source-ranges 0.0.0.0/0

# Compute Engine 인스턴스 생성
gcloud compute instances create cloud-student-server /
  --zone=asia-northeast3-a /
  --machine-type=e2-micro /
  --image-family=ubuntu-2204-lts /
  --image-project=ubuntu-os-cloud /
  --tags=web-server
```

---

## 🗂️ 4단계: 스토리지 서비스 실습

[🗂️ 4단계: 스토리지 서비스 실습](#4단계-스토리지-서비스-실습)

### 4.1 AWS S3 버킷 생성

[4.1 AWS S3 버킷 생성](#41-aws-s3-버킷-생성)

#### 🌐 웹콘솔 방식

[🌐 웹콘솔 방식](#웹콘솔-방식)
```markdown
1. AWS Console → "S3" 검색
2. "버킷 만들기" 클릭
3. 버킷 이름: "cloud-student-bucket-[고유번호]"
4. 리전: "아시아 태평양(서울)"
5. "다음" 클릭
6. 버킷 버전 관리: "비활성화"
7. "다음" 클릭
8. 퍼블릭 액세스 차단: "모든 퍼블릭 액세스 차단 해제"
9. "다음" 클릭
10. "다음" 클릭
11. "버킷 만들기" 클릭
```

#### 💻 CLI 방식

[💻 CLI 방식](#cli-방식)
```bash
# S3 버킷 생성
aws s3 mb s3://cloud-student-bucket-$(date +%s)

# 파일 업로드
echo "Hello from AWS S3!" > hello.txt
aws s3 cp hello.txt s3://cloud-student-bucket-[버킷명]/

# 파일 다운로드
aws s3 cp s3://cloud-student-bucket-[버킷명]/hello.txt downloaded-hello.txt
```

### 4.2 GCP Cloud Storage 버킷 생성

[4.2 GCP Cloud Storage 버킷 생성](#42-gcp-cloud-storage-버킷-생성)

#### 🌐 웹콘솔 방식

[🌐 웹콘솔 방식](#웹콘솔-방식)
```markdown
1. GCP Console → "Cloud Storage" → "버킷" 클릭
2. "버킷 만들기" 클릭
3. 버킷 이름: "cloud-student-bucket-[고유번호]"
4. 위치 유형: "리전"
5. 리전: "asia-northeast3 (서울)"
6. 스토리지 클래스: "Standard"
7. 액세스 제어: "균일한 액세스"
8. "만들기" 클릭
```

#### 💻 CLI 방식

[💻 CLI 방식](#cli-방식)
```bash
# Cloud Storage 버킷 생성
gsutil mb gs://cloud-student-bucket-$(date +%s)

# 파일 업로드
echo "Hello from GCP Cloud Storage!" > hello.txt
gsutil cp hello.txt gs://cloud-student-bucket-[버킷명]/

# 파일 다운로드
gsutil cp gs://cloud-student-bucket-[버킷명]/hello.txt downloaded-hello.txt
```

---

## 🧪 5단계: 실습 테스트 및 비교

[🧪 5단계: 실습 테스트 및 비교](#5단계-실습-테스트-및-비교)

### 5.1 웹서버 테스트

[5.1 웹서버 테스트](#51-웹서버-테스트)

#### AWS EC2 테스트

[AWS EC2 테스트](#aws-ec2-테스트)
```bash
# EC2 인스턴스 IP 확인
INSTANCE_IP=$(aws ec2 describe-instances /
  --filters "Name=tag:Name,Values=cloud-student-server" /
  --query 'Reservations[*].Instances[*].PublicIpAddress' /
  --output text)

# 웹서버 접속 테스트
curl http://$INSTANCE_IP
```

#### GCP Compute Engine 테스트

[GCP Compute Engine 테스트](#gcp-compute-engine-테스트)
```bash
# Compute Engine 인스턴스 IP 확인
INSTANCE_IP=$(gcloud compute instances describe cloud-student-server /
  --zone=asia-northeast3-a /
  --format='get(networkInterfaces[0].accessConfigs[0].natIP)')

# 웹서버 접속 테스트
curl http://$INSTANCE_IP
```

### 5.2 스토리지 서비스 테스트

[5.2 스토리지 서비스 테스트](#52-스토리지-서비스-테스트)

#### AWS S3 테스트

[AWS S3 테스트](#aws-s3-테스트)
```bash
# S3 버킷 내용 확인
aws s3 ls s3://cloud-student-bucket-[버킷명]/
```

#### GCP Cloud Storage 테스트

[GCP Cloud Storage 테스트](#gcp-cloud-storage-테스트)
```bash
# Cloud Storage 버킷 내용 확인
gsutil ls gs://cloud-student-bucket-[버킷명]/
```

---

## 🧹 6단계: 리소스 정리

[🧹 6단계: 리소스 정리](#6단계-리소스-정리)

### 6.1 AWS 리소스 정리

[6.1 AWS 리소스 정리](#61-aws-리소스-정리)

```bash
# EC2 인스턴스 삭제
aws ec2 terminate-instances --instance-ids [인스턴스-ID]

# 보안 그룹 삭제
aws ec2 delete-security-group --group-name web-server-sg

# S3 버킷 삭제
aws s3 rb s3://cloud-student-bucket-[버킷명] --force
```

### 6.2 GCP 리소스 정리

[6.2 GCP 리소스 정리](#62-gcp-리소스-정리)

```bash
# Compute Engine 인스턴스 삭제
gcloud compute instances delete cloud-student-server /
  --zone=asia-northeast3-a --quiet

# 방화벽 규칙 삭제
gcloud compute firewall-rules delete allow-http-https --quiet

# Cloud Storage 버킷 삭제
gsutil rm gs://cloud-student-bucket-[버킷명]/* --recursive
gsutil rb gs://cloud-student-bucket-[버킷명]
```

---

## ✅ 실습 완료 체크리스트

[✅ 실습 완료 체크리스트](#실습-완료-체크리스트)

- [ ] AWS 계정 생성 및 Free Tier 활성화
- [ ] GCP 계정 생성 및 $300 크레딧 활성화
- [ ] AWS IAM 사용자 생성 및 권한 설정
- [ ] GCP IAM 서비스 계정 생성 및 권한 설정
- [ ] AWS EC2 인스턴스 생성 및 SSH 접속
- [ ] GCP Compute Engine 인스턴스 생성 및 접속
- [ ] AWS S3 버킷 생성 및 파일 업로드/다운로드
- [ ] GCP Cloud Storage 버킷 생성 및 파일 관리
- [ ] 리소스 정리 완료

---

## 🎯 학습 포인트

[🎯 학습 포인트](#학습-포인트)

### AWS vs GCP 비교 분석

[AWS vs GCP 비교 분석](#aws-vs-gcp-비교-분석)
- **계정 구조**: AWS 계정 vs GCP 프로젝트
- **IAM 시스템**: AWS IAM vs GCP IAM
- **가상머신**: EC2 vs Compute Engine
- **스토리지**: S3 vs Cloud Storage
- **CLI 도구**: AWS CLI vs gcloud CLI

### 실무 적용

[실무 적용](#실무-적용)
- 멀티클라우드 환경에서의 서비스 선택 기준
- 각 플랫폼의 장단점 이해
- 비용 최적화를 위한 리소스 관리
- 자동화를 통한 효율적인 리소스 관리

---

## 💡 추가 학습 아이디어

[💡 추가 학습 아이디어](#추가-학습-아이디어)

1. **네트워킹**: VPC vs VPC Network 비교
2. **데이터베이스**: RDS vs Cloud SQL 비교
3. **모니터링**: CloudWatch vs Cloud Monitoring
4. **보안**: Security Groups vs Firewall Rules
5. **비용 관리**: AWS Cost Explorer vs GCP Billing


---


### 📧 연락처

[📧 연락처](#연락처)
- **이메일**: inhwan.jung@gmail.com
- **GitHub**: [프로젝트 저장소](https:///github.com/jungfrau70/aws_gcp.git)

---



<div align="center">

[← 이전: GCP 기초 실습](cloud_basic/textbook/Day1/practice/gcp_basic_practice.md) | [📚 전체 커리큘럼](curriculum.md) | [🏠 학습 경로로 돌아가기](index.md) | [다음: Cloud Basic 2일차 →](README.md) | [📋 학습 경로](learning-path.md)

</div>