# ⚡ 빠른 시작 가이드

> **5분 만에 클라우드 학습 자동화 시작하기**

## 🚀 **1단계: 환경 준비 ["2분"]**

### 필수 도구 설치
```bash
# AWS CLI 설치
curl "https:///awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip && sudo ./aws/install

# GCP CLI 설치
curl https:///sdk.cloud.google.com | bash
exec -l $SHELL

# Docker 설치
curl -fsSL https:///get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER
```

### 계정 설정
```bash
# AWS 설정
aws configure
# AWS Access Key ID: ["입력"]
# AWS Secret Access Key: ["입력"]
# Default region name: us-west-2
# Default output format: json

# GCP 설정
gcloud auth login
gcloud config set project [YOUR_PROJECT_ID]
```

## 🎯 **2단계: 첫 번째 실습 실행 ["3분"]**

### Cloud Basic Day1 실행
```bash
# 1. 디렉토리 이동
cd mcp_knowledge_base/cloud_basic/automation_tests

# 2. 자동화 실행
python3 improved_basic_automation.py

# 3. 결과 확인
# 터미널에서 ✅ 성공 메시지 확인
```

## 📊 **3단계: 결과 확인**

### 실시간 모니터링
```bash
# 실행 중 터미널에서 확인
# 🚀 basic Day1 자동화 시작
# ✅ 환경 설정: Cloud Basic Day1 환경 설정 시작
# ✅ AWS 계정 확인: AWS 계정: 123456789012
# ✅ GCP 계정 확인: GCP 계정 및 크레딧 확인 완료
# ✅ Day1 실습: AWS & GCP 기초 서비스 실습 시작
# ✅ IAM 기초 실습: AWS IAM 사용자 생성 및 권한 부여
# ✅ 가상머신 서비스 기초: t2.micro 인스턴스 생성 완료
# ✅ 스토리지 서비스 기초: S3 버킷 생성 완료
# ✅ GCP 서비스 실습: Compute Engine 및 Cloud Storage 생성 완료
# 🎉 basic Day1 자동화 완료 ["소요시간: 120.50초"]
```

### 결과 파일 확인
```bash
# 자동화 결과 확인
ls automation_results/
cat automation_results/basic_day1_*.json

# 로그 파일 확인
ls logs/
tail -f logs/basic_day1_*.log
```

## 🔍 **4단계: 리소스 확인**

### AWS 리소스 확인
```bash
# EC2 인스턴스 확인
aws ec2 describe-instances --query 'Reservations[*].Instances[*].[InstanceId,State.Name,InstanceType]' --output table

# S3 버킷 확인
aws s3 ls

# RDS 인스턴스 확인
aws rds describe-db-instances --query 'DBInstances[*].[DBInstanceIdentifier,DBInstanceStatus,Engine]' --output table
```

### GCP 리소스 확인
```bash
# Compute Engine 인스턴스 확인
gcloud compute instances list

# Cloud Storage 버킷 확인
gsutil ls

# Cloud SQL 인스턴스 확인
gcloud sql instances list
```

## 🚨 **문제 해결**

### 자주 발생하는 오류
```bash
# AWS 계정 오류
aws sts get-caller-identity

# GCP 계정 오류
gcloud auth list
gcloud config get-value project

# Docker 오류
sudo systemctl status docker
sudo systemctl start docker
```

### 리소스 정리
```bash
# 자동화 스크립트가 자동으로 정리하지만, 수동 정리도 가능
# AWS 리소스 정리
aws ec2 terminate-instances --instance-ids i-1234567890abcdef0
aws s3 rb s3://cloud-training-basic-day1-1234567890 --force

# GCP 리소스 정리
gcloud compute instances delete basic-day1-vm --zone=us-central1-a
gsutil rm -r gs://cloud-training-basic-day1-1234567890
```

## 📚 **다음 단계**

### Cloud Basic Day2 실행
```bash
# 1. 설정 파일 수정
# improved_basic_automation.py에서 day를 2로 변경

# 2. 자동화 실행
python3 improved_basic_automation.py
```

### Cloud Master 과정으로 진행
```bash
# Cloud Master 과정으로 이동
cd ../cloud_master/automation_tests
python3 improved_master_automation.py
```

### Cloud Container 과정으로 진행
```bash
# Cloud Container 과정으로 이동
cd ../cloud_container/automation_tests
python3 improved_container_automation.py
```

## 💡 **팁**

1. **교재와 함께**: 자동화 실행 전 교재 해당 섹션을 먼저 읽어보세요
2. **단계별 진행**: 한 번에 모든 과정을 실행하지 말고 단계별로 진행하세요
3. **비용 관리**: 실습 완료 후 반드시 리소스를 정리하세요
4. **오류 발생 시**: 교재의 문제 해결 섹션을 참고하세요

---

**🎓 축하합니다! 클라우드 학습 자동화를 성공적으로 시작했습니다!**


---

### 📧 연락처
- **이메일**: inhwan.jung@gmail.com
- **GitHub**: ["프로젝트 저장소"][https:///github.com/jungfrau70/aws_gcp.git]

---



<div align="center">

["🏠 홈"][index.md] | ["📚 전체 커리큘럼"][curriculum.md] | ["🔗 학습 경로"][learning-path.md]

</div>