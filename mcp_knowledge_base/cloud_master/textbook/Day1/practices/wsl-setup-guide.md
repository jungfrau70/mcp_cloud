# WSL 환경 설정 가이드

## 🎯 개요

이 가이드는 Windows 환경에서 WSL2를 사용하여 Cloud Master 실습 환경을 구축하는 방법을 단계별로 안내합니다. ["GitHub 저장소"][https://github.com/jungfrau70/github-actions-demo/tree/feature/cloud-master]에서 실습 코드를 클론받아 사용합니다.

---

## 🔧 WSL2 설치 및 설정

### 1단계: WSL2 설치

#### Windows 10/11에서 WSL2 설치
```bash
# PowerShell을 관리자 권한으로 실행 후 다음 명령어 실행

# WSL 기능 활성화
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart

# 컴퓨터 재시작
shutdown /r /t 0
```

#### WSL2 업데이트
```bash
# WSL2 Linux 커널 업데이트 패키지 다운로드
# https://aka.ms/wsl2kernel 에서 다운로드 후 설치

# WSL2를 기본 버전으로 설정
wsl --set-default-version 2
```

### 2단계: Ubuntu 설치
```bash
# Ubuntu 22.04 LTS 설치
wsl --install -d Ubuntu-22.04

# 또는 Microsoft Store에서 Ubuntu 22.04 LTS 설치
# https://apps.microsoft.com/store/detail/ubuntu-2204-lts/9PN20MSR04DW
```

### 3단계: WSL 환경 초기 설정
```bash
# WSL 터미널 실행
wsl

# Ubuntu 업데이트
sudo apt update && sudo apt upgrade -y

# 필수 패키지 설치
sudo apt install -y curl wget git unzip jq vim nano
```

---

## 🚀 Cloud Master 실습 환경 구축

### 1단계: 실습 디렉토리 생성 및 GitHub 저장소 클론
```bash
# WSL 홈 디렉토리에서 cloud_master 디렉토리 생성
mkdir -p ~/cloud_master
cd ~/cloud_master

# GitHub 저장소 클론
git clone https://github.com/jungfrau70/github-actions-demo.git
cd github-actions-demo

# feature/cloud-master 브랜치로 전환
git checkout feature/cloud-master

# 디렉토리 구조 확인
ls -la
```

### 2단계: 필수 도구 설치

#### Docker 설치
```bash
# Docker 설치 스크립트 다운로드 및 실행
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Docker 서비스 시작 및 자동 시작 설정
sudo systemctl start docker
sudo systemctl enable docker

# 현재 사용자를 docker 그룹에 추가
sudo usermod -aG docker $USER

# Docker 설치 확인
docker --version
docker run hello-world
```

#### AWS CLI 설치
```bash
# AWS CLI v2 설치
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# AWS CLI 설치 확인
aws --version

# AWS 자격증명 설정
aws configure
```

#### GCP CLI 설치
```bash
# GCP CLI 설치
curl https://sdk.cloud.google.com | bash
source ~/.bashrc

# GCP CLI 설치 확인
gcloud --version

# GCP 로그인
gcloud auth login
```

#### kubectl 설치
```bash
# kubectl 설치
curl -LO "https://dl.k8s.io/release/$[curl -L -s https://dl.k8s.io/release/stable.txt]/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# kubectl 설치 확인
kubectl version --client
```

#### Node.js 설치
```bash
# Node.js 18.x 설치
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# Node.js 설치 확인
node --version
npm --version
```

### 3단계: 환경 검증
```bash
# 환경 체크 스크립트 실행
chmod +x cloud-scripts/environment-check-wsl.sh
./cloud-scripts/environment-check-wsl.sh

# 자동 수정 시도 ["필요한 경우"]
./cloud-scripts/environment-check-wsl.sh --auto-fix
```

---

## 🔧 개발 환경 설정

### 1단계: VS Code WSL 확장 설치
```bash
# VS Code에서 WSL 확장 설치
# 1. VS Code 실행
# 2. 확장 탭에서 "WSL" 검색
# 3. "WSL" 확장 설치
# 4. "Remote - WSL" 확장 설치
```

### 2단계: WSL에서 VS Code 실행
```bash
# WSL 터미널에서 VS Code 실행
code .

# 또는 특정 디렉토리에서 실행
code ~/cloud_master/github-actions-demo
```

### 3단계: Git 설정
```bash
# Git 사용자 정보 설정
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"

# Git 설정 확인
git config --list
```

---

## 🚀 실습 시작

### 1단계: 실습 환경 확인
```bash
# 현재 디렉토리 확인
pwd
# 출력: /home/username/cloud_master/github-actions-demo

# 브랜치 확인
git branch
# 출력: * feature/cloud-master

# 실습 스크립트 확인
ls -la cloud-scripts/
ls -la automation/
```

### 2단계: Day 1 실습 시작
```bash
# GitHub Actions CI/CD 자동화 스크립트 실행
chmod +x automation/github-actions-cicd-automation.sh
./automation/github-actions-cicd-automation.sh --help

# 실습 프로젝트 생성
./automation/github-actions-cicd-automation.sh \
  --name my-cicd-app \
  --docker-user YOUR_DOCKER_USERNAME \
  --skill-level 중급 \
  --cloud-provider both
```

### 3단계: 실습 진행
```bash
# 생성된 프로젝트 디렉토리로 이동
cd my-cicd-app

# 프로젝트 구조 확인
ls -la

# GitHub Actions 워크플로우 확인
ls -la .github/workflows/

# Docker 이미지 빌드 테스트
docker build -t my-cicd-app:latest .

# 애플리케이션 실행 테스트
docker run -d -p 3000:3000 --name test-app my-cicd-app:latest
curl http://localhost:3000
```

---

## 🔧 문제 해결

### 일반적인 문제와 해결 방법

#### 1. WSL2 설치 실패
**문제**: WSL2 설치가 실패하거나 작동하지 않음
**해결 방법**:
1. Windows 기능에서 "Linux용 Windows 하위 시스템" 활성화
2. "가상 머신 플랫폼" 활성화
3. BIOS에서 가상화 기능 활성화
4. Windows 업데이트 확인

#### 2. Docker 권한 오류
**문제**: `docker: permission denied` 오류
**해결 방법**:
```bash
# 사용자를 docker 그룹에 추가
sudo usermod -aG docker $USER

# WSL 재시작
exit
wsl

# Docker 테스트
docker run hello-world
```

#### 3. AWS CLI 설정 오류
**문제**: AWS CLI 자격증명 설정 실패
**해결 방법**:
```bash
# AWS 자격증명 재설정
aws configure

# 자격증명 파일 확인
cat ~/.aws/credentials

# AWS 연결 테스트
aws sts get-caller-identity
```

#### 4. GCP CLI 설정 오류
**문제**: GCP CLI 로그인 실패
**해결 방법**:
```bash
# GCP CLI 재로그인
gcloud auth login

# 프로젝트 설정
gcloud config set project YOUR_PROJECT_ID

# GCP 연결 테스트
gcloud auth list
```

#### 5. Git 설정 오류
**문제**: Git 사용자 정보가 설정되지 않음
**해결 방법**:
```bash
# Git 사용자 정보 설정
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"

# Git 설정 확인
git config --list
```

---

## 📚 추가 자료

### 유용한 명령어
```bash
# WSL 상태 확인
wsl --list --verbose

# WSL 버전 확인
wsl --version

# WSL 업데이트
wsl --update

# WSL 재시작
wsl --shutdown
wsl
```

### VS Code 확장 추천
- WSL
- Remote - WSL
- Docker
- GitLens
- Prettier
- ESLint
- Thunder Client ["API 테스트"]

### 유용한 리소스
- ["WSL 공식 문서"][https://docs.microsoft.com/ko-kr/windows/wsl/]
- [Docker Desktop for Windows][https://www.docker.com/products/docker-desktop/]
- ["VS Code WSL 확장"][https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-wsl]

---

## 🎯 다음 단계

WSL 환경 설정이 완료되면 다음 단계로 진행하세요:

1. **Day 1 실습**: ["GitHub Actions CI/CD 완전 가이드"](github-actions-cicd-guide.md)
2. **배포 확인**: ["배포 후 체크포인트 가이드"](deployment-checkpoints-guide.md)
3. **자동화 스크립트**: ["GitHub Actions CI/CD 자동화"][../repos/automation/github-actions-cicd-automation.sh]

---

<div align="center">

["← 이전: GitHub Actions 기초 실습"](github-actions-basics.md) | 
["📚 전체 커리큘럼"](../../../curriculum.md) | 
["🏠 학습 경로로 돌아가기"](../../../index.md) | 
["다음: GitHub Actions CI/CD 완전 가이드 →"](github-actions-cicd-guide.md)

</div>
