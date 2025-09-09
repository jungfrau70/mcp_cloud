# AWS/GCP 실전 마스터 1일차 교안

## 📋 목차
1. [실습 환경 준비](#실습-환경-준비)
2. [1교시: Docker 개념과 Compose 실습](./docker-compose-guide.md)
3. [2교시: GitHub Actions로 CI/CD 구성](./github-actions-guide.md)
4. [3교시: 클라우드 배포 기초 실습](./cloud-deployment-guide.md)
5. [4교시: 전체 자동 배포 파이프라인 구성](./cicd-pipeline-guide.md)
6. [AWS & GCP 멀티클라우드 배포 가이드](./aws-gcp-deployment-guide.md)
7. [AWS & GCP 권한 설정 가이드](./aws-gcp-permissions-setup.md)
8. [Docker Hub 가입 및 토큰 설정 가이드](./docker-hub-setup-guide.md)
9. [트러블슈팅 가이드](./troubleshooting-guide.md)
10. [actions-demo 프로젝트](./actions-demo/README.md)

---

## 🎯 학습 목표

이 1일차 과정을 통해 다음을 학습합니다:

- **Docker 컨테이너 기술**의 이해와 실습
- **GitHub Actions**를 활용한 CI/CD 파이프라인 구축
- **클라우드 배포 기초** 및 배포 방식 이해
- **자동 배포 파이프라인** 구축 및 운영
- **멀티클라우드 배포 전략** (고급 과정 대비)

---

## ⏰ 일정 및 소요 시간

| 교시 | 내용 | 소요 시간 |
|------|------|-----------|
| 1교시 | Docker 개념과 Compose 실습 | 60분 |
| 2교시 | GitHub Actions로 CI/CD 구성 | 45분 |
| 3교시 | 클라우드 배포 기초 실습 | 60분 |
| 4교시 | 전체 자동 배포 파이프라인 구성 | 75분 |
| **추가 학습** | AWS & GCP 멀티클라우드 배포 | 60분 |
| **실습 프로젝트** | actions-demo 프로젝트 실습 | 30분 |
| **총 소요 시간** | | **5시간 30분** |

---

## 🔧 실습 환경 준비

### 필수 소프트웨어 설치

#### 1. Docker 설치
- **Windows/Mac**: [Docker Desktop](https://www.docker.com/products/docker-desktop) 다운로드 및 설치
- **Linux**: Docker Engine 설치
```bash
# Ubuntu/Debian
sudo apt-get update
sudo apt-get install docker.io

# CentOS/RHEL
sudo yum install docker
sudo systemctl start docker
sudo systemctl enable docker
```

#### 2. Git 설치
```bash
# 설치 확인
git --version

# 사용자 정보 설정
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

#### 3. 개발 도구
- **IDE**: VS Code 또는 선호하는 에디터
- **터미널**: Windows Terminal, iTerm2, 또는 기본 터미널

### 클라우드 계정 준비

#### AWS 계정 설정
- [ ] AWS 계정 생성 (무료 티어 가능)
- [ ] 사용자 액세스 키 생성 (사용자->보안자격증명->액세스 키 만들기)
- [ ] AWS CLI 설치 및 설정
```bash
# AWS CLI 설치 확인
aws --version

# AWS 자격증명 설정, 액세스 키 필요 
aws configure
```

#### Google Cloud Platform 계정 설정
- [ ] GCP 계정 생성 ($300 크레딧)
- [ ] Google Cloud SDK 설치
  (PowerShell) Get-Command python
  (PowerShell) setx CLOUDSDK_PYTHON "C:\Python312\python.exe" /M
  (cmd) echo %CLOUDSDK_PYTHON%
```bash
# gcloud CLI 설치 확인
gcloud --version

# GCP 인증: Windows PC 경우, 별도로 해당 폴더에대해 사용자 접한 추가 필요 
gcloud auth login 
```

#### GitHub 계정 설정
- [ ] GitHub 계정 생성
- [ ] SSH 키 설정 (선택사항)
- [ ] 저장소 생성 권한 확인

### 실습 전 체크리스트

#### 환경 확인
- [ ] Docker가 정상 설치되어 있는가?
```bash
docker --version
docker run hello-world
```

- [ ] Git이 정상 설치되어 있는가?
```bash
git --version
```

- [ ] AWS CLI가 설정되어 있는가?
```bash
aws sts get-caller-identity
```

- [ ] Google Cloud SDK가 설정되어 있는가?
```bash
gcloud auth list
```

#### 스크립트 실행 환경
- [ ] 스크립트 실행 권한이 있는가?
```bash
# Windows (PowerShell)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Linux/macOS
chmod +x scripts/*.sh
```

- [ ] 체크포인트 기능 이해
```bash
# 스크립트 중단 시 자동으로 마지막 성공 지점부터 재시작
# 체크포인트 파일: cloud-deployment-checkpoint.txt
```

#### 계정 준비
- [ ] AWS 계정에 ECS, ECR 서비스 접근 권한이 있는가?
- [ ] GCP 계정에 Cloud Run, GCR 서비스 접근 권한이 있는가?
- [ ] GitHub 계정에 Actions 사용 권한이 있는가?
- [ ] Docker Hub 계정이 있는가? (토큰 생성 필요)

---

## 📚 학습 자료

### 참고 문서
- [Docker 공식 문서](https://docs.docker.com/)
- [GitHub Actions 공식 문서](https://docs.github.com/en/actions)
- [AWS ECS 공식 문서](https://docs.aws.amazon.com/ecs/)
- [GCP GKE 공식 문서](https://cloud.google.com/kubernetes-engine/docs)

### 유용한 링크
- [Docker Hub](https://hub.docker.com/)
- [GitHub Actions 마켓플레이스](https://github.com/marketplace?type=actions)
- [AWS ECR](https://aws.amazon.com/ecr/)
- [Google Container Registry](https://cloud.google.com/container-registry)

---

## 🚀 고급 스크립트 기능

### 체크포인트 시스템

모든 스크립트는 **체크포인트 기능**을 제공하여 안전한 재시작을 지원합니다.

#### 체크포인트 동작 방식
```bash
# 스크립트 실행 중 중단 시
./scripts/aws-ec2-create.sh
# ... 네트워크 오류로 중단 ...

# 다시 실행 시 자동으로 마지막 성공 지점부터 재시작
./scripts/aws-ec2-create.sh
# [INFO] 이전 실행에서 중단된 지점을 발견했습니다: security_group_ready
# [INFO] AWS 설정이 완료되었습니다. 인스턴스 생성부터 재시작합니다.
```

#### 체크포인트 관리
```bash
# 체크포인트 파일 확인
ls -la *-checkpoint.txt

# 체크포인트 파일 삭제 (처음부터 다시 시작)
rm cloud-deployment-checkpoint.txt
```

### 자동 리소스 정리

실습 완료 후 **자동 정리 스크립트**로 모든 리소스를 깔끔하게 정리할 수 있습니다.

#### AWS 리소스 정리
```bash
# AWS 리소스 자동 정리
chmod +x scripts/aws-resource-cleanup.sh
./scripts/aws-resource-cleanup.sh

# 정리되는 리소스:
# ✅ EC2 인스턴스 (종료 및 삭제)
# ✅ 보안 그룹
# ✅ 키 페어 (AWS 및 로컬 파일)
# ✅ Elastic IP (해제)
# ✅ 체크포인트 파일
```

#### GCP 리소스 정리
```bash
# GCP 프로젝트 자동 정리
chmod +x scripts/gcp-project-cleanup.sh
./scripts/gcp-project-cleanup.sh PROJECT_ID

# 정리되는 리소스:
# ✅ Compute Engine 인스턴스
# ✅ VPC 네트워크 및 서브넷
# ✅ 방화벽 규칙
# ✅ 정적 IP 주소
# ✅ 프로젝트 (선택사항)
```

### 설정 도우미 활용

복잡한 설정을 **도우미 스크립트**로 간편하게 처리할 수 있습니다.

#### AWS 설정 도우미
```bash
# AWS 설정 도우미 실행
chmod +x scripts/aws-setup-helper.sh
./scripts/aws-setup-helper.sh

# 확인하는 항목:
# - AWS CLI 설치 상태
# - 인증 설정
# - 기본 리전 설정
# - VPC 및 서브넷 확인
```

#### GCP 설정 도우미
```bash
# GCP 설정 도우미 실행
chmod +x scripts/gcp-setup-helper.sh
./scripts/gcp-setup-helper.sh

# 확인하는 항목:
# - gcloud CLI 설치 상태
# - 인증 설정
# - 프로젝트 설정
# - 리전 및 존 설정
# - API 활성화 상태
```

### SSH 키 사전 등록 (GCP)

GCP 스크립트는 **SSH 키를 인스턴스 생성 전에 사전 등록**하여 연결 문제를 방지합니다.

#### SSH 키 등록 과정
```bash
# 1. SSH 키 생성
ssh-keygen -t rsa -b 4096 -f cloud-deployment-key

# 2. 프로젝트 메타데이터에 등록 (모든 VM에서 사용 가능)
gcloud compute project-info add-metadata \
    --metadata-from-file ssh-keys=cloud-deployment-key.pub

# 3. OS Login에 등록 (Google 계정으로 자동 인증)
gcloud compute os-login ssh-keys add \
    --key-file=cloud-deployment-key.pub
```

---

## 🚀 시작하기

실습을 시작하기 전에 위의 체크리스트를 모두 확인하세요. 모든 준비가 완료되면 [1교시: Docker 개념과 Compose 실습](./docker-compose-guide.md)부터 시작하세요.

### 문제가 있나요?
실습 중 문제가 발생하면 [트러블슈팅 가이드](./troubleshooting-guide.md)를 참고하세요.
