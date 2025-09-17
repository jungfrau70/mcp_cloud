# 📚 클라우드 학습 과정 자동화 가이드

> **대상**: 대학생, 클라우드 강의 수강자 (친숙하지 않은 사용자)  
> **목적**: 교재와 연계된 체계적인 클라우드 실습 자동화

## 🎯 시작하기 전에

### 📋 **필수 준비사항**

#### 1. 계정 준비
- **AWS 계정**: [AWS Free Tier](https://aws.amazon.com/free/) 가입
- **GCP 계정**: [Google Cloud Platform](https://cloud.google.com/) 가입 ($300 크레딧)
- **GitHub 계정**: [GitHub](https://github.com/) 가입

#### 2. 도구 설치
```bash
# AWS CLI 설치
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# GCP CLI 설치
curl https://sdk.cloud.google.com | bash
exec -l $SHELL

# Docker 설치
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# kubectl 설치
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
```

#### 3. 환경 설정
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

# Docker 권한 설정
sudo usermod -aG docker $USER
# 로그아웃 후 다시 로그인 필요
```

## 🚀 **자동화 실행 방법**

### 1. Cloud Basic 과정 (2일차)

#### **Day 1: AWS & GCP 기초 서비스 실습**

```bash
# 1. 디렉토리 이동
cd mcp_knowledge_base/cloud_basic/automation_tests

# 2. 자동화 실행
python improved_basic_automation.py

# 3. 진행 상황 확인
# - 터미널에 실시간 로그 출력
# - 각 단계별 성공/실패 상태 표시
# - 오류 발생 시 해결 방법 안내
```

**📚 교재 연계**: 
- **섹션 1**: 클라우드 개념 및 계정 생성
- **섹션 2**: IAM 기초 실습  
- **섹션 3**: 가상머신 서비스 기초
- **섹션 4**: 스토리지 서비스 기초

#### **Day 2: 네트워크, 보안 및 데이터베이스 실습**

```bash
# 1. 설정 파일 수정 (day를 2로 변경)
# improved_basic_automation.py 파일에서:
# basic_config = {'course_name': 'basic', 'day': 2, ...}

# 2. 자동화 실행
python improved_basic_automation.py
```

**📚 교재 연계**:
- **섹션 1**: 네트워킹 기초 실습
- **섹션 2**: 보안 그룹 및 방화벽 실습
- **섹션 3**: 데이터베이스 서비스 기초
- **섹션 4**: 종합 실습 및 비교 분석

### 2. Cloud Master 과정 (3일차)

#### **Day 1: Docker, Git/GitHub, GitHub Actions 기초**

```bash
# 1. 디렉토리 이동
cd mcp_knowledge_base/cloud_master/automation_tests

# 2. 자동화 실행
python improved_master_automation.py
```

**📚 교재 연계**:
- **섹션 1**: Docker 기초 및 컨테이너 기술
- **섹션 2**: Git/GitHub 기초 및 협업
- **섹션 3**: GitHub Actions CI/CD 파이프라인
- **섹션 4**: VM 기반 웹 애플리케이션 배포

#### **Day 2: 고급 CI/CD 및 VM 기반 컨테이너 배포**

```bash
# 1. 설정 파일 수정 (day를 2로 변경)
# 2. 자동화 실행
python improved_master_automation.py
```

#### **Day 3: 로드 밸런싱, 모니터링, 비용 최적화**

```bash
# 1. 설정 파일 수정 (day를 3으로 변경)
# 2. 자동화 실행
python improved_master_automation.py
```

### 3. Cloud Container 과정 (2일차)

#### **Day 1: Kubernetes 및 GKE 고급 오케스트레이션**

```bash
# 1. 디렉토리 이동
cd mcp_knowledge_base/cloud_container/automation_tests

# 2. 자동화 실행
python improved_container_automation.py
```

**📚 교재 연계**:
- **섹션 1**: Kubernetes 고급 아키텍처
- **섹션 2**: 컨테이너 오케스트레이션 고급 기법
- **섹션 3**: AWS ECS 및 Fargate 심화
- **섹션 4**: 고급 CI/CD 파이프라인

#### **Day 2: 고가용성 및 확장성 아키텍처**

```bash
# 1. 설정 파일 수정 (day를 2로 변경)
# 2. 자동화 실행
python improved_container_automation.py
```

### 4. 통합 자동화 (전체 과정)

```bash
# 1. 디렉토리 이동
cd mcp_knowledge_base/integrated_automation

# 2. 통합 자동화 실행
python improved_integrated_automation.py

# 3. 통합 검증 실행
python improved_validation.py
```

## 🔍 **진행 상황 확인 방법**

### 1. 실시간 로그 확인
```bash
# 자동화 실행 중 터미널에서 확인
# ✅ 성공, ⚠️ 경고, ❌ 오류 표시
```

### 2. 결과 파일 확인
```bash
# 자동화 결과 확인
ls automation_results/
cat automation_results/[과정명]_day[일차]_[날짜시간].json

# 로그 파일 확인
ls logs/
tail -f logs/[과정명]_day[일차]_[날짜시간].log
```

### 3. 리소스 상태 확인
```bash
# AWS 리소스 확인
aws ec2 describe-instances
aws s3 ls
aws rds describe-db-instances

# GCP 리소스 확인
gcloud compute instances list
gsutil ls
gcloud sql instances list

# Docker 리소스 확인
docker ps
docker images

# Kubernetes 리소스 확인
kubectl get pods
kubectl get services
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
gcloud services enable container.googleapis.com
```

#### **Docker 오류**
```
❌ Docker 클라이언트 초기화 실패
```
**해결 방법**:
```bash
# 1. Docker 서비스 상태 확인
sudo systemctl status docker

# 2. Docker 서비스 시작
sudo systemctl start docker

# 3. 사용자 권한 확인
groups $USER
# docker 그룹에 포함되어 있는지 확인
```

#### **Kubernetes 오류**
```
❌ Kubernetes 환경 확인 실패
```
**해결 방법**:
```bash
# 1. kubectl 설정 확인
kubectl config current-context

# 2. 클러스터 연결 확인
kubectl cluster-info

# 3. GKE 클러스터 연결
gcloud container clusters get-credentials [CLUSTER_NAME] --region [REGION]
```

### 2. 리소스 정리

#### **비용 절약을 위한 리소스 정리**
```bash
# 1. 자동화 스크립트 실행 (자동 정리)
python [과정명]_automation.py

# 2. 수동 리소스 정리
# AWS 리소스 정리
aws ec2 terminate-instances --instance-ids [INSTANCE_ID]
aws s3 rb s3://[BUCKET_NAME] --force

# GCP 리소스 정리
gcloud compute instances delete [INSTANCE_NAME] --zone=[ZONE]
gsutil rm -r gs://[BUCKET_NAME]

# Docker 리소스 정리
docker system prune -a

# Kubernetes 리소스 정리
kubectl delete all --all
```

## 📊 **성과 확인 방법**

### 1. 자동화 결과 요약
```bash
# 자동화 완료 후 터미널에서 확인
# ================================================
# 📊 [과정명] DAY [일차] 자동화 결과
# ================================================
# 상태: success
# 소요시간: 120.50초
# 총 단계: 15
# 성공: 14
# 오류: 0
# 경고: 1
# 성공률: 93.3%
# ================================================
```

### 2. 검증 결과 확인
```bash
# 통합 검증 실행
python improved_validation.py

# 검증 결과 확인
cat validation_results/integrated_validation_[날짜시간].json
```

### 3. 학습 목표 달성 확인
- **Cloud Basic**: AWS/GCP 기초 서비스 활용 능력
- **Cloud Master**: Docker, CI/CD, VM 배포 능력
- **Cloud Container**: Kubernetes, 고가용성 아키텍처 능력

## 💡 **팁과 권장사항**

### 1. 효율적인 학습 방법
- **교재와 함께**: 자동화 실행 전 교재 해당 섹션 읽기
- **단계별 진행**: 한 번에 모든 과정을 실행하지 말고 단계별로 진행
- **오류 발생 시**: 교재의 문제 해결 섹션 참고

### 2. 비용 관리
- **Free Tier 활용**: AWS Free Tier, GCP $300 크레딧 활용
- **리소스 정리**: 실습 완료 후 반드시 리소스 정리
- **비용 모니터링**: 정기적으로 비용 확인

### 3. 보안 주의사항
- **자격 증명 보호**: AWS/GCP 자격 증명을 안전하게 보관
- **권한 최소화**: 필요한 최소 권한만 부여
- **리소스 태깅**: 생성한 리소스에 적절한 태그 부여

## 📞 **지원 및 ### 📧 연락처
- **이메일**: inhwan.jung@gmail.com
- **GitHub**: [프로젝트 저장소](https://github.com/jungfrau70/aws_gcp.git)
### 2. 추가 자료
- **교재**: `mcp_knowledge_base/cloud_*/textbook/`
- **실습 가이드**: `mcp_knowledge_base/cloud_*/textbook/Day*/README.md`
- **설정 파일**: `mcp_knowledge_base/shared_configs/unified_config.json`

### 3. 업데이트 확인
```bash
# 최신 버전 확인
git pull origin main

# 변경사항 확인
git log --oneline -10
```

---

**🎓 행운을 빕니다! 체계적인 클라우드 학습을 통해 실무 역량을 키워보세요!**


---



---



---

<div align="center">

## 🔗 관련 과정
[Cloud Basic 1일차](/mcp_knowledge_base/cloud_basic/textbook/Day1/README.md) | [Cloud Master 1일차](/mcp_knowledge_base/cloud_master/textbook/Day1/README.md) | [Cloud Container 1일차](/mcp_knowledge_base/cloud_container/textbook/Day1/README.md)

</div>

---

<div align="center">

[🏠 홈](/mcp_knowledge_base/index.md) | [📚 전체 커리큘럼](/mcp_knowledge_base/curriculum.md) | [🔗 학습 경로](/mcp_knowledge_base/cloud_basic/learning-path.md)

</div>
