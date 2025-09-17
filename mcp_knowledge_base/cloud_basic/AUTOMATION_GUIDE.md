<div align="center">

## 🏠 최상위 네비게이션
[🏠 홈](/mcp_knowledge_base/index.md) | [📚 전체 커리큘럼](/mcp_knowledge_base/curriculum.md) | [🔗 학습 경로](/mcp_knowledge_base/cloud_basic/learning-path.md)

## 📖 현재 위치
**Cloud Basic** > **1일차** > **📚 Cloud Basic 과정 자동화 가이드**

## ⬅️ 이전/다음 네비게이션
[← 이전: Cloud Basic 메인](/mcp_knowledge_base/cloud_basic/README.md) | [다음: Cloud Basic 1일차 →](/mcp_knowledge_base/cloud_basic/textbook/Day1/README.md)

</div>

# 📚 Cloud Basic 과정 자동화 가이드

> **대상**: 클라우드 입문자, 대학생  
> **기간**: 2일차  
> **목표**: AWS & GCP 기초 서비스 실습

## 🎯 **과정 개요**

Cloud Basic 과정은 클라우드 컴퓨팅의 기초부터 시작하여 AWS와 GCP의 핵심 서비스를 실습을 통해 학습하는 과정입니다.

### 📋 **학습 목표**
- 클라우드 컴퓨팅 기본 개념 이해
- AWS와 GCP 서비스 개요 및 비교
- IAM을 통한 사용자 및 권한 관리
- 가상머신, 스토리지, 네트워크 서비스 기본 활용

## 🚀 **자동화 실행 방법**

### **전제 조건 확인**

#### 1. 필수 도구 설치
```bash
# AWS CLI 설치 확인
aws --version
# 출력 예시: aws-cli/2.13.0 Python/3.11.0

# GCP CLI 설치 확인
gcloud --version
# 출력 예시: Google Cloud SDK 432.0.0

# Python 설치 확인
python3 --version
# 출력 예시: Python 3.9.0
```

#### 2. 계정 설정
```bash
# AWS 자격 증명 설정
aws configure
# AWS Access Key ID: [입력]
# AWS Secret Access Key: [입력]
# Default region name: us-west-2
# Default output format: json

# GCP 자격 증명 설정
gcloud auth login
gcloud config set project [YOUR_PROJECT_ID]
```

### **Day 1: AWS & GCP 기초 서비스 실습**

#### 1. 자동화 실행
```bash
# 1. 디렉토리 이동
cd mcp_knowledge_base/cloud_basic/automation_tests

# 2. 자동화 실행
python3 improved_basic_automation.py
```

#### 2. 실행 과정 확인
```bash
# 실시간 로그 확인
# 터미널에서 다음과 같은 출력을 확인할 수 있습니다:

# 🚀 basic Day1 자동화 시작
# ✅ 환경 설정: Cloud Basic Day1 환경 설정 시작
# ✅ AWS 계정 확인: AWS 계정: 123456789012
# ✅ GCP 계정 확인: GCP 계정 및 크레딧 확인 완료
# ✅ 실습 환경 준비: 모든 필수 도구 확인 완료
# ✅ Day1 실습: AWS & GCP 기초 서비스 실습 시작
# ✅ IAM 기초 실습: AWS IAM 사용자 생성 및 권한 부여
# ✅ 가상머신 서비스 기초: t2.micro 인스턴스 생성 완료
# ✅ 스토리지 서비스 기초: S3 버킷 생성 완료
# ✅ GCP 서비스 실습: Compute Engine 및 Cloud Storage 생성 완료
# ✅ Day1 실습: AWS & GCP 기초 서비스 실습 완료
# ✅ 리소스 정리: Cloud Basic Day1 리소스 정리 완료
# 🎉 basic Day1 자동화 완료 (소요시간: 120.50초)
```

#### 3. 교재 연계 확인
**📚 교재 Day1 섹션과 연계**:
- **섹션 1**: 클라우드 개념 및 계정 생성 ✅
- **섹션 2**: IAM 기초 실습 ✅
- **섹션 3**: 가상머신 서비스 기초 ✅
- **섹션 4**: 스토리지 서비스 기초 ✅

### **Day 2: 네트워크, 보안 및 데이터베이스 실습**

#### 1. 설정 수정
```bash
# improved_basic_automation.py 파일 수정
# 47번째 줄 근처에서 day를 2로 변경
basic_config = {
    'course_name': 'basic',
    'day': 2,  # 1에서 2로 변경
    'project_prefix': config['automation']['project_prefix'],
    'aws_region': config['cloud_providers']['aws']['region'],
    'gcp_region': config['cloud_providers']['gcp']['region']
}
```

#### 2. 자동화 실행
```bash
python3 improved_basic_automation.py
```

#### 3. 실행 과정 확인
```bash
# 터미널에서 다음과 같은 출력을 확인할 수 있습니다:

# 🚀 basic Day2 자동화 시작
# ✅ 환경 설정: Cloud Basic Day2 환경 설정 시작
# ✅ Day2 실습: 네트워크, 보안 및 데이터베이스 실습 시작
# ✅ 네트워킹 기초 실습: VPC 및 서브넷 구성
# ✅ 보안 그룹 및 방화벽 실습: Security Groups 생성 및 규칙 설정
# ✅ 데이터베이스 서비스 기초: RDS MySQL 인스턴스 생성
# ✅ 종합 실습 및 비교 분석: 웹 서버 + 데이터베이스 구성
# ✅ Day2 실습: 네트워크, 보안 및 데이터베이스 실습 완료
# 🎉 basic Day2 자동화 완료 (소요시간: 180.30초)
```

#### 4. 교재 연계 확인
**📚 교재 Day2 섹션과 연계**:
- **섹션 1**: 네트워킹 기초 실습 ✅
- **섹션 2**: 보안 그룹 및 방화벽 실습 ✅
- **섹션 3**: 데이터베이스 서비스 기초 ✅
- **섹션 4**: 종합 실습 및 비교 분석 ✅

## 🔍 **진행 상황 확인 방법**

### 1. 실시간 모니터링
```bash
# 자동화 실행 중 터미널에서 확인
# ✅ 성공, ⚠️ 경고, ❌ 오류 표시
```

### 2. 결과 파일 확인
```bash
# 자동화 결과 확인
ls automation_results/
# 출력 예시:
# basic_day1_20241201_143022.json
# basic_day2_20241201_150045.json

# 결과 내용 확인
cat automation_results/basic_day1_20241201_143022.json
```

### 3. 로그 파일 확인
```bash
# 로그 파일 확인
ls logs/
# 출력 예시:
# basic_day1_20241201_143022.log
# basic_day2_20241201_150045.log

# 실시간 로그 확인
tail -f logs/basic_day1_20241201_143022.log
```

### 4. AWS 리소스 확인
```bash
# EC2 인스턴스 확인
aws ec2 describe-instances --query 'Reservations[*].Instances[*].[InstanceId,State.Name,InstanceType]' --output table

# S3 버킷 확인
aws s3 ls

# RDS 인스턴스 확인
aws rds describe-db-instances --query 'DBInstances[*].[DBInstanceIdentifier,DBInstanceStatus,Engine]' --output table

# VPC 확인
aws ec2 describe-vpcs --query 'Vpcs[*].[VpcId,State,CidrBlock]' --output table
```

### 5. GCP 리소스 확인
```bash
# Compute Engine 인스턴스 확인
gcloud compute instances list

# Cloud Storage 버킷 확인
gsutil ls

# Cloud SQL 인스턴스 확인
gcloud sql instances list

# VPC 네트워크 확인
gcloud compute networks list
```

## 🚨 **문제 해결 가이드**

### 1. 자주 발생하는 오류

#### **AWS 계정 오류**
```
❌ AWS 계정 확인 실패: AWS 계정 설정이 필요합니다
```
**해결 방법**:
```bash
# 1. AWS 자격 증명 확인
aws sts get-caller-identity

# 2. 자격 증명 재설정
aws configure

# 3. 권한 확인
aws iam get-user
```

#### **GCP 계정 오류**
```
❌ GCP 계정 확인 실패: GCP 계정 설정이 필요합니다
```
**해결 방법**:
```bash
# 1. GCP 로그인 확인
gcloud auth list

# 2. 프로젝트 설정 확인
gcloud config get-value project

# 3. API 활성화
gcloud services enable compute.googleapis.com
gcloud services enable storage.googleapis.com
gcloud services enable sqladmin.googleapis.com
```

#### **리소스 생성 오류**
```
❌ EC2 인스턴스 생성 실패: InsufficientInstanceCapacity
```
**해결 방법**:
```bash
# 1. 다른 리전 시도
aws ec2 describe-regions --query 'Regions[*].RegionName' --output table

# 2. 다른 인스턴스 타입 시도
# improved_basic_automation.py에서 t2.micro 대신 t3.micro 사용

# 3. 가용 영역 확인
aws ec2 describe-availability-zones --region us-west-2
```

### 2. 비용 관리

#### **리소스 정리**
```bash
# 자동화 스크립트가 자동으로 정리하지만, 수동 정리도 가능
# AWS 리소스 수동 정리
aws ec2 terminate-instances --instance-ids i-1234567890abcdef0
aws s3 rb s3://cloud-training-basic-day1-1234567890 --force
aws rds delete-db-instance --db-instance-identifier basic-day1-db --skip-final-snapshot

# GCP 리소스 수동 정리
gcloud compute instances delete basic-day1-vm --zone=us-central1-a
gsutil rm -r gs://cloud-training-basic-day1-1234567890
gcloud sql instances delete basic-day1-db
```

#### **비용 모니터링**
```bash
# AWS 비용 확인
aws ce get-cost-and-usage --time-period Start=2024-12-01,End=2024-12-02 --granularity DAILY --metrics BlendedCost

# GCP 비용 확인
gcloud billing budgets list
```

## 📊 **성과 확인 방법**

### 1. 자동화 결과 요약
```bash
# 자동화 완료 후 터미널에서 확인
# ================================================
# 📊 BASIC DAY 1 자동화 결과
# ================================================
# 상태: success
# 소요시간: 120.50초
# 총 단계: 12
# 성공: 12
# 오류: 0
# 경고: 0
# 성공률: 100.0%
# ================================================
```

### 2. 학습 목표 달성 확인
- **✅ 클라우드 컴퓨팅 기본 개념 이해**: 교재 섹션 1 완료
- **✅ AWS와 GCP 서비스 개요 및 비교**: 교재 섹션 1, 4 완료
- **✅ IAM을 통한 사용자 및 권한 관리**: 교재 섹션 2 완료
- **✅ 가상머신, 스토리지, 네트워크 서비스 기본 활용**: 교재 섹션 3, 4 완료

### 3. 다음 과정 준비
Cloud Basic 과정을 성공적으로 완료했다면, Cloud Master 과정으로 진행할 수 있습니다.

```bash
# Cloud Master 과정으로 이동
cd ../cloud_master/automation_tests
python3 improved_master_automation.py
```

## 💡 **학습 팁**

### 1. 효율적인 학습 방법
- **교재와 함께**: 자동화 실행 전 교재 해당 섹션을 먼저 읽어보세요
- **단계별 진행**: 한 번에 모든 과정을 실행하지 말고 단계별로 진행하세요
- **오류 발생 시**: 교재의 문제 해결 섹션을 참고하세요

### 2. 실습 환경 최적화
- **리전 선택**: 가까운 리전을 선택하여 지연 시간을 줄이세요
- **리소스 크기**: 학습 목적에 맞는 적절한 크기의 리소스를 사용하세요
- **비용 관리**: 실습 완료 후 반드시 리소스를 정리하세요

### 3. 보안 주의사항
- **자격 증명 보호**: AWS/GCP 자격 증명을 안전하게 보관하세요
- **권한 최소화**: 필요한 최소 권한만 부여하세요
- **리소스 태깅**: 생성한 리소스에 적절한 태그를 부여하세요

---

**🎓 Cloud Basic 과정을 성공적으로 완료하셨습니다! 다음 단계인 Cloud Master 과정으로 진행해보세요!**


---

<div align="center">

## 🔗 관련 과정 및 네비게이션
[🏠 홈](/mcp_knowledge_base/index.md) | [📚 전체 커리큘럼](/mcp_knowledge_base/curriculum.md) | [🔗 학습 경로](/mcp_knowledge_base/cloud_basic/learning-path.md)

## 📖 현재 위치
**Cloud Basic** > **1일차** > **📚 Cloud Basic 과정 자동화 가이드**

## ⬅️ 이전/다음 네비게이션
[← 이전: Cloud Basic 메인](/mcp_knowledge_base/cloud_basic/README.md) | [다음: Cloud Basic 1일차 →](/mcp_knowledge_base/cloud_basic/textbook/Day1/README.md)

## 🔗 관련 과정
[Cloud Master 1일차](/mcp_knowledge_base/cloud_master/textbook/Day1/README.md) | [Cloud Container 1일차](/mcp_knowledge_base/cloud_container/textbook/Day1/README.md)

</div>

### 📧 연락처
- **이메일**: inhwan.jung@gmail.com
- **GitHub**: [프로젝트 저장소](https://github.com/jungfrau70/aws_gcp.git)
