# Docker 설치 가이드

<div align="center">

[← 이전: Cloud Basic 메인](/mcp_knowledge_base/cloud_master/README.md) | [📚 전체 커리큘럼](/mcp_knowledge_base/curriculum.md) | [🏠 학습 경로로 돌아가기](/mcp_knowledge_base/index.md) | [📋 학습 경로](/mcp_knowledge_base/cloud_master/learning-path.md)

</div>

Docker는 컨테이너 기반의 애플리케이션 배포 플랫폼입니다. 이 가이드는 다양한 운영체제에서 Docker를 설치하는 방법을 설명합니다.

## 목차
- [Windows 설치](#windows-설치)
- [macOS 설치](#macos-설치)
- [Linux 설치](#linux-설치)
- [설치 확인](#설치-확인)
- [기본 설정](#기본-설정)
- [문제 해결](#문제-해결)

## Windows 설치

### 방법 1: Docker Desktop (권장)

1. **Docker Desktop 다운로드**
   ```bash
   # 공식 웹사이트에서 다운로드
   https://www.docker.com/products/docker-desktop/
   ```

2. **시스템 요구사항 확인**
   - Windows 10 64-bit: Pro, Enterprise, 또는 Education (Build 15063 이상)
   - WSL 2 기능 활성화
   - BIOS에서 가상화 기능 활성화

3. **설치 실행**
   - 다운로드한 Docker Desktop Installer.exe 실행
   - "Use WSL 2 instead of Hyper-V" 옵션 선택 (권장)
   - 설치 완료 후 재부팅

4. **Docker Desktop 시작**
   - 시작 메뉴에서 Docker Desktop 실행
   - 시스템 트레이에서 Docker 아이콘 확인

### 방법 2: Chocolatey 사용

```cmd
# Chocolatey 설치 (없는 경우)
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# Docker Desktop 설치
choco install docker-desktop
```

### 방법 3: winget 사용

```cmd
winget install Docker.DockerDesktop
```

### WSL 2 설정

1. **WSL 2 활성화**
   ```powershell
   # PowerShell을 관리자 권한으로 실행
   dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
   dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
   ```

2. **WSL 2로 업데이트**
   ```powershell
   wsl --set-default-version 2
   ```

3. **Linux 배포판 설치**
   ```powershell
   wsl --install -d Ubuntu
   ```

## macOS 설치

### 방법 1: Docker Desktop (권장)

1. **Docker Desktop 다운로드**
   ```bash
   # 공식 웹사이트에서 다운로드
   https://www.docker.com/products/docker-desktop/
   ```

2. **시스템 요구사항 확인**
   - macOS 10.15 이상
   - 최소 4GB RAM
   - Intel 또는 Apple Silicon (M1/M2) 프로세서

3. **설치 실행**
   - 다운로드한 Docker.dmg 파일 실행
   - Docker.app을 Applications 폴더로 드래그
   - Applications 폴더에서 Docker 실행

### 방법 2: Homebrew 사용

```bash
# Homebrew 설치 확인
brew --version

# Docker Desktop 설치
brew install --cask docker

# 또는 Docker CLI만 설치
brew install docker
```

### Apple Silicon (M1/M2) 지원

```bash
# Apple Silicon용 Docker Desktop 설치
# 공식 웹사이트에서 Apple Silicon 버전 다운로드
# 또는 Homebrew 사용
arch -arm64 brew install --cask docker
```

## Linux 설치

### Ubuntu/Debian

1. **기존 Docker 패키지 제거**
   ```bash
   sudo apt-get remove docker docker-engine docker.io containerd runc
   ```

2. **패키지 업데이트**
   ```bash
   sudo apt-get update
   ```

3. **필요한 패키지 설치**
   ```bash
   sudo apt-get install -y \
       ca-certificates \
       curl \
       gnupg \
       lsb-release
   ```

4. **Docker 공식 GPG 키 추가**
   ```bash
   sudo mkdir -p /etc/apt/keyrings
   curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
   ```

5. **Docker 리포지토리 설정**
   ```bash
   echo \
     "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
     $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
   ```

6. **Docker Engine 설치**
   ```bash
   sudo apt-get update
   sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
   ```

7. **Docker 서비스 시작**
   ```bash
   sudo systemctl start docker
   sudo systemctl enable docker
   ```

8. **사용자를 docker 그룹에 추가**
   ```bash
   sudo usermod -aG docker $USER
   ```

### CentOS/RHEL/Rocky Linux

1. **기존 Docker 패키지 제거**
   ```bash
   sudo yum remove docker docker-client docker-client-latest docker-common docker-latest docker-latest-logrotate docker-logrotate docker-engine
   ```

2. **필요한 패키지 설치**
   ```bash
   sudo yum install -y yum-utils
   ```

3. **Docker 리포지토리 추가**
   ```bash
   sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
   ```

4. **Docker Engine 설치**
   ```bash
   sudo yum install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
   ```

5. **Docker 서비스 시작**
   ```bash
   sudo systemctl start docker
   sudo systemctl enable docker
   ```

6. **사용자를 docker 그룹에 추가**
   ```bash
   sudo usermod -aG docker $USER
   ```

### Fedora

```bash
# dnf 사용
sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $USER
```

### openSUSE

```bash
# zypper 사용
sudo zypper install docker docker-compose
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $USER
```

### Arch Linux

```bash
# pacman 사용
sudo pacman -S docker docker-compose
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $USER
```

## 설치 확인

설치가 완료된 후 다음 명령어로 확인할 수 있습니다:

```bash
# Docker 버전 확인
docker --version

# Docker 정보 확인
docker info

# Hello World 컨테이너 실행
docker run hello-world
```

예상 출력:
```
Docker version 24.0.7, build afdd53b
```

## 기본 설정

### 1. Docker 서비스 관리

```bash
# Docker 서비스 시작
sudo systemctl start docker

# Docker 서비스 중지
sudo systemctl stop docker

# Docker 서비스 재시작
sudo systemctl restart docker

# Docker 서비스 상태 확인
sudo systemctl status docker

# 부팅 시 자동 시작
sudo systemctl enable docker
```

### 2. 사용자 권한 설정

```bash
# 현재 사용자를 docker 그룹에 추가
sudo usermod -aG docker $USER

# 그룹 변경사항 적용 (재로그인 또는)
newgrp docker

# 권한 확인
docker run hello-world
```

### 3. Docker 데몬 설정

```bash
# Docker 데몬 설정 파일 위치
# Linux: /etc/docker/daemon.json
# Windows/macOS: Docker Desktop 설정에서

# 예시 설정
sudo tee /etc/docker/daemon.json > /dev/null <<EOF
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  },
  "storage-driver": "overlay2"
}
EOF

# 설정 적용
sudo systemctl restart docker
```

## 문제 해결

### 일반적인 문제들

1. **권한 오류 (Permission denied)**
   ```bash
   # 사용자를 docker 그룹에 추가
   sudo usermod -aG docker $USER
   
   # 재로그인 또는 그룹 변경사항 적용
   newgrp docker
   ```

2. **Docker 서비스가 시작되지 않음**
   ```bash
   # 서비스 상태 확인
   sudo systemctl status docker
   
   # 로그 확인
   sudo journalctl -u docker.service
   
   # 서비스 재시작
   sudo systemctl restart docker
   ```

3. **가상화 문제 (Windows)**
   ```powershell
   # Hyper-V 활성화
   Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All
   
   # WSL 2 활성화
   wsl --install
   ```

4. **디스크 공간 부족**
   ```bash
   # 사용하지 않는 컨테이너, 이미지, 볼륨 정리
   docker system prune -a
   
   # 특정 리소스만 정리
   docker container prune
   docker image prune
   docker volume prune
   ```

### 로그 및 디버깅

```bash
# Docker 데몬 로그 확인
sudo journalctl -u docker.service

# 컨테이너 로그 확인
docker logs <container_id>

# 상세 정보 확인
docker info

# 시스템 정보 확인
docker system df
```

### 네트워크 문제

```bash
# Docker 네트워크 확인
docker network ls

# 네트워크 상세 정보
docker network inspect bridge

# 네트워크 재생성
sudo systemctl restart docker
```

## 추가 리소스

- [Docker 공식 문서](https://docs.docker.com/)
- [Docker Desktop 가이드](https://docs.docker.com/desktop/)
- [Docker 명령어 참조](https://docs.docker.com/engine/reference/commandline/docker/)
- [Docker Compose 가이드](https://docs.docker.com/compose/)

## 버전 관리

```bash
# 현재 버전 확인
docker --version

# 업데이트
# Windows/macOS: Docker Desktop에서 자동 업데이트
# Linux: 패키지 매니저를 통한 업데이트

# Ubuntu/Debian
sudo apt update && sudo apt upgrade docker-ce

# CentOS/RHEL
sudo yum update docker-ce
```

## 보안 모범 사례

1. **최신 버전 사용**: 정기적으로 Docker 업데이트
2. **사용자 권한**: root 권한으로 Docker 실행 금지
3. **이미지 보안**: 신뢰할 수 있는 이미지만 사용
4. **네트워크 보안**: 필요한 포트만 노출
5. **리소스 제한**: 컨테이너 리소스 제한 설정

```bash
# 컨테이너 리소스 제한 예시
docker run -m 512m --cpus="1.0" nginx

# 읽기 전용 파일시스템
docker run --read-only nginx

# 보안 옵션
docker run --security-opt no-new-privileges nginx
```

## 자동화 스크립트

### Ubuntu/Debian 자동 설치 스크립트

```bash
#!/bin/bash
set -e

echo "Docker 설치 시작..."

# 기존 Docker 제거
sudo apt-get remove -y docker docker-engine docker.io containerd runc || true

# 패키지 업데이트
sudo apt-get update

# 필요한 패키지 설치
sudo apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

# Docker GPG 키 추가
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# Docker 리포지토리 설정
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Docker 설치
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Docker 서비스 시작
sudo systemctl start docker
sudo systemctl enable docker

# 사용자를 docker 그룹에 추가
sudo usermod -aG docker $USER

echo "Docker 설치 완료!"
echo "재로그인 후 'docker run hello-world'로 테스트하세요."
```


---

<div align="center">

[🏠 홈](/mcp_knowledge_base/index.md) | [📚 전체 커리큘럼](/mcp_knowledge_base/curriculum.md) | [🔗 학습 경로](/mcp_knowledge_base/cloud_basic/learning-path.md)

</div>

### 📧 연락처
- **이메일**: inhwan.jung@gmail.com
- **GitHub**: [프로젝트 저장소](https://github.com/jungfrau70/aws_gcp.git)
