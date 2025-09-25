# 📚 클라우드 학습 과정 자동화 가이드

> **대상**: 대학생, 클라우드 강의 수강자 ["친숙하지 않은 사용자"]  
> **목적**: 교재와 연계된 체계적인 클라우드 실습 자동화

## 🎯 시작하기 전에

### 📋 **필수 준비사항**

#### 1. 계정 준비
- **AWS 계정**: [AWS Free Tier][https:///aws.amazon.com/free/] 가입
- **GCP 계정**: [Google Cloud Platform][https:///cloud.google.com/] 가입 ["$300 크레딧"]
- **GitHub 계정**: [GitHub][https:///github.com/] 가입

#### 2. 도구 설치
- **AWS CLI**: ["설치 가이드"][https:///docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html]
- **Google Cloud SDK**: ["설치 가이드"][https:///cloud.google.com/sdk/docs/install]
- **Docker**: ["설치 가이드"][https:///docs.docker.com/get-docker/]
- **kubectl**: ["설치 가이드"][https:///kubernetes.io/docs/tasks/tools/install-kubectl/]

#### 3. 환경 설정
```bash
# AWS 자격 증명 설정
aws configure
# AWS Access Key ID: ["입력"]
# AWS Secret Access Key: ["입력"]
# Default region name: ap-northeast-2
# Default output format: json

# GCP 자격 증명 설정
gcloud auth login
gcloud auth application-default login
gcloud config set project [YOUR_PROJECT_ID]

# Docker 권한 설정 [Linux]
sudo usermod -aG docker $USER
# 로그아웃 후 다시 로그인 필요
```

---

## 🚀 과정별 실습 자동화 스크립트 실행

각 과정의 실습 환경을 자동으로 구축하는 파이썬 스크립트입니다. 프로젝트 루트 디렉토리에서 아래 명령어를 실행하세요.

**✨ 중요:** 스크립트는 **멱등성[Idempotency]**을 가지도록 설계되었습니다. 중간에 실행이 실패하더라도 스크립트를 다시 실행하면, 이미 생성된 리소스는 건너뛰고 실패한 지점부터 실습을 이어갈 수 있습니다.

### 1. Cloud Basic 과정

이 스크립트는 AWS와 GCP의 기초 리소스["IAM, EC2/Compute Engine, S3/Cloud Storage 등"]를 생성합니다.

```bash
python mcp_knowledge_base/cloud_basic/automation_tests/cloud_basic_course_automation.py
```

### 2. Cloud Master 과정

이 스크립트는 AWS ECR 리포지토리, 고가용성을 위한 Application Load Balancer와 Auto Scaling Group 등을 생성합니다.

```bash
python mcp_knowledge_base/cloud_master/repos/automation/automation_tests/cloud_master_course_automation.py
```

### 3. Cloud Container 과정

이 스크립트는 Google Kubernetes Engine[GKE] 클러스터를 생성하고 샘플 애플리케이션을 배포합니다. **["주의: 클러스터 생성에 10분 이상 소요될 수 있습니다."]**

```bash
python mcp_knowledge_base/cloud_container/automation_tests/cloud_container_course_automation.py
```

---

## 🔍 **진행 상황 확인 및 문제 해결**

### 진행 로그 확인
- 스크립트를 실행하면 터미널에 각 단계의 진행 상황이 실시간으로 출력됩니다. ["`✅ 성공, ⚠️ 경고, ❌ 오류`"]
- 상세 로그는 각 `automation_tests` 디렉토리 아래의 `*.log` 파일에 기록됩니다.

### 리소스 정리
- 각 스크립트는 실행이 완료되거나 실패했을 때 생성했던 리소스를 자동으로 정리[`cleanup`]하도록 구현되어 있습니다.
- 만약 수동으로 리소스를 확인하고 싶다면 각 클라우드 제공사의 콘솔이나 CLI를 사용하세요.

### 자주 발생하는 오류
- **권한 오류 [`AccessDeniedException`, `403 Forbidden`]:** AWS/GCP CLI의 인증 및 권한 설정을 다시 확인하세요. 특히 GCP는 `gcloud auth application-default login` 명령이 필요할 수 있습니다.
- **API 활성화 오류 [GCP]:** `gcloud services enable [SERVICE_NAME]` 명령을 사용하여 필요한 API[e.g., `container.googleapis.com`, `compute.googleapis.com`]가 활성화되어 있는지 확인하세요.

## 📞 **지원 및 ### 📧 연락처
- **이메일**: inhwan.jung@gmail.com
- **GitHub**: ["프로젝트 저장소"][https:///github.com/jungfrau70/aws_gcp.git]
