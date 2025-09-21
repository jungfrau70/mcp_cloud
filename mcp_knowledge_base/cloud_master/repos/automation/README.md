# Cloud Master 자동화 스크립트 모음

## 📚 개요

이 디렉토리는 Cloud Master 과정의 실습을 자동화하는 스크립트들을 포함합니다. 각 스크립트는 특정 실습 과정을 자동화하여 학습자가 더 쉽고 빠르게 실습할 수 있도록 도와줍니다.

## 🚀 주요 자동화 스크립트

### 1. GitHub Actions CI/CD 자동화
**파일**: `github-actions-cicd-automation.sh`

GitHub Actions CI/CD 파이프라인을 자동으로 설정하는 스크립트입니다.

#### 기능
- 프로젝트 구조 자동 생성
- GitHub Actions 워크플로우 자동 생성
- Docker 이미지 빌드 설정
- VM 및 Kubernetes 배포 설정
- 모니터링 및 최적화 설정

#### 사용법
```bash
# 기본 설정으로 실행
./github-actions-cicd-automation.sh

# 사용자 정의 설정으로 실행
./github-actions-cicd-automation.sh \
  --name my-app \
  --docker-user myuser \
  --skill-level 중급 \
  --cloud-provider both \
  --budget 100

# 생성된 리소스 정리
./github-actions-cicd-automation.sh --cleanup
```

#### 옵션
- `-n, --name NAME`: 프로젝트 이름 (기본값: github-actions-cicd-practice)
- `-v, --node-version VER`: Node.js 버전 (기본값: 18)
- `-d, --docker-user USER`: Docker Hub 사용자명
- `-a, --aws-region REGION`: AWS 리전 (기본값: us-west-2)
- `-g, --gcp-region REGION`: GCP 리전 (기본값: us-central1)
- `-s, --skill-level LEVEL`: 실습 난이도 (초급/중급/고급)
- `-b, --budget BUDGET`: 예산 한도 (USD)
- `-c, --cloud-provider`: 클라우드 프로바이더 (aws/gcp/both)
- `--setup-only`: 설정만 생성 (실행하지 않음)
- `--cleanup`: 생성된 리소스 정리
- `-h, --help`: 도움말 표시

### 2. 통합 자동화 스크립트
**파일**: `integrated-practice-automation.sh`

전체 Cloud Master 과정을 통합적으로 자동화하는 스크립트입니다.

#### 기능
- 환경 설정 자동화
- 인프라 자동 생성 (AWS/GCP)
- Kubernetes 클러스터 자동 생성
- 애플리케이션 자동 배포
- 모니터링 스택 자동 설정

#### 사용법
```bash
# 전체 과정 자동화
./integrated-practice-automation.sh

# 특정 단계만 실행
./integrated-practice-automation.sh --step infrastructure
./integrated-practice-automation.sh --step kubernetes
./integrated-practice-automation.sh --step monitoring
```

### 3. 환경 체크 도구
**파일**: `environment-check-wsl.sh`

실습 환경이 올바르게 설정되어 있는지 확인하는 스크립트입니다.

#### 기능
- 필수 도구 설치 확인
- 클라우드 계정 연결 확인
- 권한 설정 확인
- 환경 설정 검증

#### 사용법
```bash
# 환경 체크 실행
./environment-check-wsl.sh

# 자동 수정 시도
./environment-check-wsl.sh --auto-fix
```

## 🛠️ 설치 및 설정

### 1. 필수 도구 설치

#### Windows (WSL2)
```bash
# WSL2 업데이트
wsl --update

# Ubuntu 설치
wsl --install -d Ubuntu

# WSL 환경에서 cloud_master 디렉토리 생성
mkdir -p ~/cloud_master
cd ~/cloud_master

# GitHub 저장소 클론
git clone https://github.com/jungfrau70/github-actions-demo.git
cd github-actions-demo

# feature/cloud-master 브랜치로 전환
git checkout feature/cloud-master

# 필수 도구 설치
sudo apt update
sudo apt install -y curl wget git unzip jq

# Docker 설치
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh

# AWS CLI 설치
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# GCP CLI 설치
curl https://sdk.cloud.google.com | bash
source ~/.bashrc

# kubectl 설치
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
```

#### macOS
```bash
# Homebrew 설치
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 필수 도구 설치
brew install curl wget git unzip jq docker awscli google-cloud-sdk kubectl
```

#### Linux
```bash
# Ubuntu/Debian
sudo apt update
sudo apt install -y curl wget git unzip jq docker.io awscli google-cloud-cli kubectl

# CentOS/RHEL
sudo yum install -y curl wget git unzip jq docker awscli google-cloud-cli kubectl
```

### 2. 클라우드 계정 설정

#### AWS 설정
```bash
# AWS 자격증명 설정
aws configure

# AWS 자격증명 확인
aws sts get-caller-identity
```

#### GCP 설정
```bash
# GCP 로그인
gcloud auth login

# 프로젝트 설정
gcloud config set project YOUR_PROJECT_ID

# GCP 자격증명 확인
gcloud auth list
```

### 3. 스크립트 실행 권한 부여
```bash
# 모든 스크립트에 실행 권한 부여
chmod +x *.sh

# 개별 스크립트 실행 권한 부여
chmod +x github-actions-cicd-automation.sh
chmod +x integrated-practice-automation.sh
chmod +x environment-check-wsl.sh
```

## 📋 사용 시나리오

### 시나리오 1: GitHub Actions CI/CD 실습
```bash
# 1. WSL 환경에서 GitHub 저장소 클론
mkdir -p ~/cloud_master
cd ~/cloud_master
git clone https://github.com/jungfrau70/github-actions-demo.git
cd github-actions-demo
git checkout feature/cloud-master

# 2. 환경 체크
./cloud-scripts/environment-check-wsl.sh

# 3. GitHub Actions CI/CD 자동화 실행
./automation/github-actions-cicd-automation.sh \
  --name my-cicd-app \
  --docker-user myuser \
  --skill-level 중급 \
  --cloud-provider both

# 4. 생성된 프로젝트 확인
ls -la my-cicd-app/

# 5. GitHub 저장소에 푸시
cd my-cicd-app
git init
git add .
git commit -m "Initial commit"
git remote add origin https://github.com/username/my-cicd-app.git
git push -u origin main
```

### 시나리오 2: 전체 과정 통합 실습
```bash
# 1. WSL 환경에서 GitHub 저장소 클론
mkdir -p ~/cloud_master
cd ~/cloud_master
git clone https://github.com/jungfrau70/github-actions-demo.git
cd github-actions-demo
git checkout feature/cloud-master

# 2. 환경 체크
./cloud-scripts/environment-check-wsl.sh

# 3. 통합 자동화 실행
./automation/integrated-practice-automation.sh \
  --cloud-provider both \
  --skill-level 고급 \
  --budget 100

# 4. 실습 진행
# - 인프라 생성 확인
# - Kubernetes 클러스터 확인
# - 애플리케이션 배포 확인
# - 모니터링 설정 확인

# 5. 정리
./automation/integrated-practice-automation.sh --cleanup
```

### 시나리오 3: 단계별 실습
```bash
# 1. WSL 환경에서 GitHub 저장소 클론
mkdir -p ~/cloud_master
cd ~/cloud_master
git clone https://github.com/jungfrau70/github-actions-demo.git
cd github-actions-demo
git checkout feature/cloud-master

# 2. 환경 설정
./cloud-scripts/environment-check-wsl.sh --auto-fix

# 3. 인프라 생성
./automation/integrated-practice-automation.sh --step infrastructure

# 4. Kubernetes 클러스터 생성
./automation/integrated-practice-automation.sh --step kubernetes

# 5. 애플리케이션 배포
./automation/integrated-practice-automation.sh --step deployment

# 6. 모니터링 설정
./automation/integrated-practice-automation.sh --step monitoring
```

## 🔧 문제 해결

### 일반적인 문제

#### 1. 권한 오류
```bash
# 스크립트 실행 권한 확인
ls -la *.sh

# 실행 권한 부여
chmod +x *.sh
```

#### 2. 도구 설치 오류
```bash
# 환경 체크 실행
./environment-check-wsl.sh

# 자동 수정 시도
./environment-check-wsl.sh --auto-fix
```

#### 3. 클라우드 연결 오류
```bash
# AWS 연결 확인
aws sts get-caller-identity

# GCP 연결 확인
gcloud auth list

# 자격증명 재설정
aws configure
gcloud auth login
```

#### 4. Docker 오류
```bash
# Docker 서비스 시작
sudo systemctl start docker
sudo systemctl enable docker

# Docker 그룹에 사용자 추가
sudo usermod -aG docker $USER
newgrp docker
```

### 로그 확인

#### 스크립트 실행 로그
```bash
# 상세 로그와 함께 실행
bash -x github-actions-cicd-automation.sh

# 로그 파일로 저장
./github-actions-cicd-automation.sh 2>&1 | tee automation.log
```

#### 클라우드 리소스 확인
```bash
# AWS 리소스 확인
aws ec2 describe-instances
aws eks list-clusters

# GCP 리소스 확인
gcloud compute instances list
gcloud container clusters list
```

## 📚 추가 자료

### 관련 문서
- [GitHub Actions CI/CD 완전 가이드](../../textbook/Day1/practices/github-actions-cicd-guide.md)
- [Cloud Master Day 1 가이드](../../textbook/Day1/README.md)
- [Cloud Master Day 2 가이드](../../textbook/Day2/README.md)
- [Cloud Master Day 3 가이드](../../textbook/Day3/README.md)

### 공식 문서
- [GitHub Actions 공식 문서](https://docs.github.com/ko/actions)
- [Docker 공식 문서](https://docs.docker.com/)
- [Kubernetes 공식 문서](https://kubernetes.io/docs/)
- [AWS 공식 문서](https://docs.aws.amazon.com/)
- [GCP 공식 문서](https://cloud.google.com/docs)

### 커뮤니티
- [GitHub Actions Marketplace](https://github.com/marketplace?type=actions)
- [Docker Hub](https://hub.docker.com/)
- [Kubernetes 예제](https://kubernetes.io/examples/)

## 🤝 기여하기

### 버그 리포트
1. GitHub Issues에서 버그 리포트 생성
2. 다음 정보 포함:
   - 운영체제 및 버전
   - 스크립트 실행 명령어
   - 오류 메시지
   - 로그 파일

### 기능 요청
1. GitHub Issues에서 기능 요청 생성
2. 다음 정보 포함:
   - 요청하는 기능 설명
   - 사용 사례
   - 예상되는 이점

### 코드 기여
1. Fork 생성
2. 기능 브랜치 생성
3. 변경사항 커밋
4. Pull Request 생성

## 📄 라이선스

이 프로젝트는 MIT 라이선스 하에 배포됩니다. 자세한 내용은 [LICENSE](../../LICENSE) 파일을 참조하세요.

---

<div align="center">

[← 이전: Cloud Master 메인](../../README.md) | 
[📚 전체 커리큘럼](../../../curriculum.md) | 
[🏠 학습 경로로 돌아가기](../../../index.md) | 
[다음: Cloud Scripts →](../cloud-scripts/README.md)

</div>