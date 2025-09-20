# WSL 추가 생성 및 설정 가이드

## 🎯 개요

이 가이드는 Cloud Master 과정을 위한 WSL(Windows Subsystem for Linux) 환경을 추가로 생성하고 설정하는 방법을 설명합니다. 기존 WSL 환경에 추가로 새로운 WSL 인스턴스를 생성하거나, 완전히 새로운 WSL 환경을 구축할 수 있습니다.

## 📋 사전 요구사항

### Windows 요구사항
- **Windows 10**: 버전 2004 이상 (빌드 19041 이상)
- **Windows 11**: 모든 버전
- **WSL 2**: 권장 (WSL 1도 지원)
- **가상화 지원**: BIOS/UEFI에서 가상화 활성화 필요

### 시스템 요구사항
- **RAM**: 최소 8GB (16GB 권장)
- **저장공간**: 최소 20GB 여유 공간
- **CPU**: 64비트 프로세서

## 🚀 WSL 설치 및 설정

### 1단계: WSL 기능 활성화

#### PowerShell 관리자 권한으로 실행
```powershell
# WSL 기능 활성화
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart

# 가상 머신 플랫폼 활성화 (WSL 2용)
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart

# 컴퓨터 재시작
Restart-Computer
```

#### 또는 Windows 기능에서 활성화
1. **Windows 기능 켜기/끄기** 실행
2. 다음 항목 체크:
   - ✅ **Linux용 Windows 하위 시스템**
   - ✅ **가상 머신 플랫폼**
3. **확인** 클릭 후 재시작

### 2단계: WSL 2로 업데이트

#### WSL 2 커널 업데이트
```powershell
# WSL 2 Linux 커널 업데이트 패키지 다운로드
# https://aka.ms/wsl2kernel 에서 다운로드 후 설치

# WSL 2를 기본 버전으로 설정
wsl --set-default-version 2
```

### 3단계: Linux 배포판 설치

#### Microsoft Store에서 설치 (권장)
1. **Microsoft Store** 열기
2. 다음 중 하나 검색하여 설치:
   - **Ubuntu 22.04 LTS** (권장)
   - **Ubuntu 20.04 LTS**
   - **Ubuntu 18.04 LTS**
   - **Debian**
   - **Kali Linux**

#### 명령줄에서 설치
```powershell
# 사용 가능한 배포판 목록 확인
wsl --list --online

# Ubuntu 22.04 설치
wsl --install -d Ubuntu-22.04

# 또는 특정 배포판 설치
wsl --install -d Ubuntu-20.04
```

## 🔧 WSL 환경 설정

### 1단계: 초기 설정

#### WSL 실행 및 사용자 계정 생성
```bash
# WSL 실행 (첫 실행 시)
# 사용자명과 비밀번호 설정
# 예: 사용자명: clouduser, 비밀번호: [안전한 비밀번호]

# 시스템 업데이트
sudo apt update && sudo apt upgrade -y

# 필수 패키지 설치
sudo apt install -y curl wget git vim nano htop tree unzip
```

### 2단계: 개발 환경 설정

#### Node.js 설치
```bash
# NodeSource 저장소 추가
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -

# Node.js 설치
sudo apt install -y nodejs

# 버전 확인
node --version
npm --version
```

#### Python 설치
```bash
# Python 3 및 pip 설치
sudo apt install -y python3 python3-pip python3-venv

# 버전 확인
python3 --version
pip3 --version
```

#### Docker 설치
```bash
# Docker 공식 GPG 키 추가
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Docker 저장소 추가
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Docker 설치
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# 사용자를 docker 그룹에 추가
sudo usermod -aG docker $USER

# Docker 서비스 시작
sudo systemctl start docker
sudo systemctl enable docker
```

### 3단계: 클라우드 도구 설치

#### AWS CLI 설치
```bash
# AWS CLI v2 설치
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# 설치 확인
aws --version

# AWS 자격 증명 설정
aws configure
```

#### GCP CLI 설치
```bash
# GCP CLI 설치
curl https://sdk.cloud.google.com | bash

# 환경 변수 설정
echo 'export PATH=$PATH:/home/$USER/google-cloud-sdk/bin' >> ~/.bashrc
source ~/.bashrc

# 설치 확인
gcloud --version

# GCP 인증
gcloud auth login
gcloud config set project [PROJECT_ID]
```

#### kubectl 설치
```bash
# kubectl 설치
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# 설치 확인
kubectl version --client
```

#### eksctl 설치
```bash
# eksctl 설치
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin

# 설치 확인
eksctl version
```

#### Helm 설치
```bash
# Helm 설치
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# 설치 확인
helm version
```

## 🏗️ 프로젝트 환경 설정

### 1단계: 작업 디렉토리 생성

```bash
# 홈 디렉토리에 프로젝트 폴더 생성
mkdir -p ~/mcp-cloud-workspace
cd ~/mcp-cloud-workspace

# Git 저장소 클론
git clone https://github.com/[your-username]/mcp_cloud.git
cd mcp_cloud

# 권한 설정
chmod +x mcp_knowledge_base/cloud_master/repos/cloud-scripts/*.sh
```

### 2단계: 환경 변수 설정

#### .bashrc 설정
```bash
# .bashrc 파일 편집
nano ~/.bashrc

# 다음 내용 추가
export PATH=$PATH:/home/$USER/google-cloud-sdk/bin
export AWS_DEFAULT_REGION=ap-northeast-2
export GCP_PROJECT=cloud-deployment-471606

# 설정 적용
source ~/.bashrc
```

#### .profile 설정
```bash
# .profile 파일 편집
nano ~/.profile

# 다음 내용 추가
export EDITOR=nano
export LANG=ko_KR.UTF-8
export LC_ALL=ko_KR.UTF-8
```

### 3단계: SSH 키 설정

```bash
# SSH 키 생성
ssh-keygen -t rsa -b 4096 -C "cloud-deployment-key" -f ~/.ssh/cloud-deployment-key

# SSH 에이전트 시작
eval "$(ssh-agent -s)"

# SSH 키 추가
ssh-add ~/.ssh/cloud-deployment-key

# 공개키 복사
cat ~/.ssh/cloud-deployment-key.pub
```

## 🔄 WSL 관리 명령어

### WSL 인스턴스 관리

```powershell
# 설치된 WSL 배포판 목록
wsl --list --verbose

# 특정 배포판 실행
wsl -d Ubuntu-22.04

# WSL 배포판 종료
wsl --terminate Ubuntu-22.04

# WSL 배포판 제거
wsl --unregister Ubuntu-22.04

# WSL 기본 배포판 설정
wsl --set-default Ubuntu-22.04

# WSL 버전 확인
wsl --version
```

### WSL 백업 및 복원

```powershell
# WSL 배포판 내보내기
wsl --export Ubuntu-22.04 C:\backup\ubuntu-22.04-backup.tar

# WSL 배포판 가져오기
wsl --import Ubuntu-22.04-New C:\WSL\Ubuntu-22.04-New C:\backup\ubuntu-22.04-backup.tar
```

## 🛠️ 문제 해결

### 일반적인 문제

#### WSL이 시작되지 않는 경우
```powershell
# WSL 서비스 상태 확인
Get-Service LxssManager

# WSL 서비스 재시작
Restart-Service LxssManager

# WSL 재등록
wsl --shutdown
wsl --unregister [배포판명]
wsl --install -d [배포판명]
```

#### 메모리 부족 문제
```bash
# WSL 메모리 제한 설정
# C:\Users\[사용자명]\.wslconfig 파일 생성
[wsl2]
memory=8GB
processors=4
swap=2GB
```

#### 네트워크 문제
```bash
# DNS 설정 확인
cat /etc/resolv.conf

# 네트워크 재시작
sudo service networking restart

# WSL 네트워크 리셋 (PowerShell에서)
wsl --shutdown
```

### 성능 최적화

#### WSL 2 성능 최적화
```bash
# WSL 2에서 Windows 파일 시스템 접근 최적화
# /mnt/c/ 대신 ~/workspace 사용 권장

# Git 설정 최적화
git config --global core.autocrlf input
git config --global core.filemode false
```

#### Docker 성능 최적화
```bash
# Docker 데몬 설정
sudo nano /etc/docker/daemon.json

# 다음 내용 추가
{
  "storage-driver": "overlay2",
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  }
}

# Docker 재시작
sudo systemctl restart docker
```

## 📚 추가 리소스

### 유용한 WSL 확장 프로그램
- **WSL** (Microsoft)
- **Remote - WSL** (Microsoft)
- **Docker Desktop** (Docker Inc.)

### 참고 문서
- [WSL 공식 문서](https://docs.microsoft.com/ko-kr/windows/wsl/)
- [Docker Desktop for Windows](https://docs.docker.com/desktop/windows/)
- [AWS CLI 설치 가이드](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
- [Google Cloud CLI 설치 가이드](https://cloud.google.com/sdk/docs/install)

### 커뮤니티 지원
- [WSL GitHub 저장소](https://github.com/microsoft/WSL)
- [Docker Desktop GitHub 저장소](https://github.com/docker/for-win)
- [Cloud Master 과정 커뮤니티](https://github.com/[your-org]/mcp_cloud)

## 🎯 다음 단계

WSL 환경 설정이 완료되면 다음 단계를 진행하세요:

1. **환경 체크 스크립트 실행**
   ```bash
   ./environment-check-wsl.sh
   ```

2. **클러스터 생성 스크립트 테스트**
   ```bash
   ./k8s-cluster-create.sh
   ./eks-cluster-create.sh
   ```

3. **통합 클러스터 정리 도구 테스트**
   ```bash
   ./cluster-cleanup-interactive.sh
   ```

4. **Cloud Master 과정 실습 시작**
   - Day1: Docker & VM 배포
   - Day2: Kubernetes & 고급 CI/CD
   - Day3: 모니터링 & 비용 최적화

---

## 📞 지원

문제가 발생하거나 추가 도움이 필요한 경우:

1. **GitHub Issues**에 문제 보고
2. **Cloud Master 과정 커뮤니티** 참여
3. **공식 문서** 참조

**Happy Learning! 🚀**
