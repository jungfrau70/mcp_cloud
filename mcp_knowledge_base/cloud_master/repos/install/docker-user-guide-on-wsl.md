# WSL 환경에서 Docker 사용 가이드

## 🎯 개요

이 문서는 WSL (Windows Subsystem for Linux) 환경에서 Docker를 사용하는 방법을 상세히 안내합니다. WSL은 `systemctl`을 지원하지 않기 때문에 일반적인 Linux 환경과는 다른 방식으로 Docker를 관리해야 합니다.

## 🚀 설치 방법

### 자동 설치 (권장)

```bash
# WSL에서 실행
cd mcp_knowledge_base/cloud_master/repos/install
chmod +x install-all-wsl.sh
./install-all-wsl.sh
```

### 수동 설치

```bash
# 1. 필수 패키지 설치
apt update
apt install -y apt-transport-https ca-certificates curl gnupg lsb-release

# 2. Docker GPG 키 추가
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# 3. Docker 저장소 추가
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

# 4. 패키지 목록 업데이트
apt update

# 5. Docker Engine 설치
apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# 6. 사용자를 docker 그룹에 추가
usermod -aG docker $USER
```

## 📋 설치되는 Docker 구성요소

- **Docker Engine**: 완전한 Docker 데몬 (`dockerd`)
- **Docker CLI**: Docker 명령어 도구 (`docker`)
- **containerd**: 컨테이너 런타임
- **Docker Buildx**: 멀티플랫폼 빌드 도구
- **Docker Compose Plugin**: Docker Compose 통합
- **Docker Compose (최신)**: `~/.local/bin`에 최신 버전

## 🔧 Docker 사용법

### 1. Docker 시작

#### 자동 시작 (권장)
```bash
# 자동 시작 스크립트 사용
start-docker
```

#### 수동 시작
```bash
# Docker 데몬 시작
dockerd --host=unix:///var/run/docker.sock --host=tcp://0.0.0.0:2375 &

# 백그라운드에서 실행하려면
dockerd --host=unix:///var/run/docker.sock --host=tcp://0.0.0.0:2375 > /dev/null 2>&1 &
```

### 2. Docker 상태 확인

```bash
# Docker 데몬 실행 상태 확인
pgrep dockerd

# Docker 버전 확인
docker --version

# Docker 정보 확인
docker info
```

### 3. Docker 테스트

```bash
# 기본 테스트
docker run hello-world

# 사용자 권한으로 테스트 (그룹 권한 적용 후)
newgrp docker
docker run hello-world
```

### 4. Docker 중지

```bash
# Docker 데몬 중지
pkill dockerd

# 또는 특정 프로세스 ID로 중지
kill $(pgrep dockerd)
```

## 🐳 Docker Compose 사용법

### 1. Docker Compose 확인

```bash
# Docker Compose 버전 확인
docker-compose --version

# 또는 플러그인 버전 확인
docker compose version
```

### 2. Docker Compose 사용

```bash
# docker-compose.yml 파일이 있는 디렉토리에서
docker-compose up -d

# 또는 플러그인 사용
docker compose up -d
```

## 🔄 WSL 재시작 시 Docker 자동 시작

### 1. .bashrc에 자동 시작 추가

```bash
# .bashrc 파일에 추가
echo 'if ! pgrep dockerd > /dev/null; then start-docker; fi' >> ~/.bashrc
```

### 2. 수동으로 환경 설정 로드

```bash
# 환경 설정 로드
source ~/.mcp-cloud-env

# Docker 시작
start-docker
```

## 🔗 Windows 디렉토리 심볼릭 링크 생성

### 1. Windows 경로를 WSL 경로로 변환

```bash
# Windows 경로 확인
echo "C:\Users\JIH\githubs\mcp_cloud\mcp_knowledge_base"

# WSL 경로로 변환
wslpath "C:\Users\JIH\githubs\mcp_cloud\mcp_knowledge_base"
# 결과: /mnt/c/Users/JIH/githubs/mcp_cloud/mcp_knowledge_base
```

### 2. 심볼릭 링크 생성

```bash
# 홈 디렉토리에 심볼릭 링크 생성
ln -s /mnt/c/Users/JIH/githubs/mcp_cloud/mcp_knowledge_base ~/mcp_knowledge_base

# 또는 다른 위치에 생성
ln -s /mnt/c/Users/JIH/githubs/mcp_cloud/mcp_knowledge_base ~/workspace/mcp_knowledge_base
```

### 3. 심볼릭 링크 확인

```bash
# 링크 상태 확인
ls -la ~/mcp_knowledge_base

# 링크가 올바르게 작동하는지 확인
cd ~/mcp_knowledge_base
ls -la
```

### 4. 자동 링크 생성 스크립트

```bash
# 자동 링크 생성 스크립트
create_mcp_link() {
    local windows_path="C:\\Users\\JIH\\githubs\\mcp_cloud\\mcp_knowledge_base"
    local wsl_path=$(wslpath "$windows_path")
    local link_name="mcp_knowledge_base"
    
    # Windows 경로가 존재하는지 확인
    if [ -d "$wsl_path" ]; then
        # 기존 링크가 있으면 제거
        if [ -L ~/$link_name ]; then
            rm ~/$link_name
            echo "기존 심볼릭 링크를 제거했습니다."
        fi
        
        # 새 심볼릭 링크 생성
        ln -s "$wsl_path" ~/$link_name
        echo "심볼릭 링크가 생성되었습니다: ~/$link_name -> $wsl_path"
        
        # 링크 테스트
        if [ -d ~/$link_name ]; then
            echo "✅ 심볼릭 링크가 정상적으로 작동합니다."
        else
            echo "❌ 심볼릭 링크 생성에 실패했습니다."
        fi
    else
        echo "❌ Windows 경로를 찾을 수 없습니다: $windows_path"
        echo "경로를 확인하고 다시 시도하세요."
    fi
}

# 함수 실행
create_mcp_link
```

### 5. 환경 변수에 추가

```bash
# .bashrc에 MCP 경로 추가
echo 'export MCP_KNOWLEDGE_BASE="$HOME/mcp_knowledge_base"' >> ~/.bashrc
echo 'export PATH="$MCP_KNOWLEDGE_BASE/cloud_master/repos/cloud-scripts:$PATH"' >> ~/.bashrc

# 환경 변수 적용
source ~/.bashrc

# 환경 변수 확인
echo "MCP Knowledge Base: $MCP_KNOWLEDGE_BASE"
```

### 6. Cloud Master 스크립트 실행

```bash
# 심볼릭 링크를 통한 스크립트 실행
cd ~/mcp_knowledge_base/cloud_master/repos/cloud-scripts

# 또는 환경 변수 사용
cd $MCP_KNOWLEDGE_BASE/cloud_master/repos/cloud-scripts

# 스크립트 실행
./aws-ec2-create.sh
./gcp-compute-create.sh
```

### 7. 문제 해결

#### 심볼릭 링크가 작동하지 않는 경우

```bash
# Windows 경로 확인
ls -la /mnt/c/Users/JIH/githubs/mcp_cloud/

# 권한 확인
ls -la /mnt/c/Users/JIH/githubs/mcp_cloud/mcp_knowledge_base

# WSL에서 Windows 파일 시스템 접근 확인
touch /mnt/c/Users/JIH/githubs/mcp_cloud/test.txt
rm /mnt/c/Users/JIH/githubs/mcp_cloud/test.txt
```

#### 권한 문제 해결

```bash
# Windows 파일 시스템 마운트 옵션 확인
mount | grep /mnt/c

# WSL 설정에서 파일 시스템 접근 권한 확인
# Windows에서 WSL 설정 파일 수정 필요할 수 있음
```

#### 경로 문제 해결

```bash
# 정확한 Windows 경로 확인
pwd
# WSL에서: /mnt/c/Users/JIH/githubs/mcp_cloud

# Windows에서 확인
# C:\Users\JIH\githubs\mcp_cloud\mcp_knowledge_base

# 경로 변환 테스트
wslpath "C:\Users\JIH\githubs\mcp_cloud\mcp_knowledge_base"
```

## 🛠️ 문제 해결

### 1. Docker 데몬이 시작되지 않는 경우

```bash
# Docker 데몬 로그 확인
dockerd --debug

# 포트 충돌 확인
netstat -tlnp | grep 2375

# 다른 포트로 시작
dockerd --host=unix:///var/run/docker.sock --host=tcp://0.0.0.0:2376 &
```

### 2. 권한 문제

```bash
# 사용자를 docker 그룹에 추가
usermod -aG docker $USER

# 그룹 권한 적용
newgrp docker

# 또는 로그아웃 후 다시 로그인
```

### 3. Docker 명령어를 찾을 수 없는 경우

```bash
# PATH 확인
echo $PATH

# Docker 경로 확인
which docker

# 수동으로 PATH 추가
export PATH="/usr/bin:$PATH"
```

### 4. 컨테이너 실행 오류

```bash
# Docker 데몬 상태 확인
pgrep dockerd

# Docker 데몬 재시작
pkill dockerd
dockerd &

# 컨테이너 로그 확인
docker logs <container_name>
```

## 📊 성능 최적화

### 1. Docker 데몬 설정

```bash
# Docker 데몬 설정 파일 생성
mkdir -p /etc/docker

# daemon.json 설정
tee /etc/docker/daemon.json > /dev/null <<EOF
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  },
  "storage-driver": "overlay2"
}
EOF
```

### 2. 리소스 제한

```bash
# 메모리 제한이 있는 컨테이너 실행
docker run -m 512m hello-world

# CPU 제한이 있는 컨테이너 실행
docker run --cpus="0.5" hello-world
```

## 🔐 보안 고려사항

### 1. Docker 소켓 권한

```bash
# Docker 소켓 권한 확인
ls -la /var/run/docker.sock

# 권한 수정 (필요시)
chmod 666 /var/run/docker.sock
```

### 2. 네트워크 보안

```bash
# Docker 네트워크 확인
docker network ls

# 특정 네트워크에서 컨테이너 실행
docker run --network bridge hello-world
```

## 📚 유용한 명령어 모음

### Docker 기본 명령어

```bash
# 이미지 목록
docker images

# 컨테이너 목록
docker ps -a

# 실행 중인 컨테이너
docker ps

# 컨테이너 중지
docker stop <container_id>

# 컨테이너 삭제
docker rm <container_id>

# 이미지 삭제
docker rmi <image_id>

# 시스템 정리
docker system prune -a
```

### Docker Compose 명령어

```bash
# 서비스 시작
docker-compose up -d

# 서비스 중지
docker-compose down

# 서비스 재시작
docker-compose restart

# 로그 확인
docker-compose logs

# 서비스 상태 확인
docker-compose ps
```

## 🎯 Cloud Master 실습과 연계

### 1. Day1 실습 준비

```bash
# Docker 시작
start-docker

# 실습 디렉토리로 이동
cd mcp_knowledge_base/cloud_master/repos/samples/day1/my-app

# Docker 이미지 빌드
docker build -t my-web-app .

# 컨테이너 실행
docker run -d -p 3000:3000 --name my-web-app my-web-app
```

### 2. GitHub Actions CI/CD 연계

```bash
# Docker 이미지 태그 변경
docker tag my-web-app mcp-cloud-master-day1:latest

# Docker Hub 푸시 준비
docker tag mcp-cloud-master-day1:latest YOUR_DOCKERHUB_USERNAME/mcp-cloud-master-day1:latest
```

## 🚨 주의사항

1. **WSL 재시작 시**: Docker 데몬이 자동으로 시작되지 않으므로 수동으로 시작해야 합니다.
2. **권한 문제**: `sudo` 없이 Docker를 사용하려면 `newgrp docker`를 실행하거나 로그아웃 후 다시 로그인해야 합니다.
3. **포트 충돌**: 2375 포트가 이미 사용 중인 경우 다른 포트를 사용하세요.
4. **메모리 사용량**: WSL에서 Docker를 사용할 때 Windows 메모리 사용량을 모니터링하세요.

## 📞 지원

문제가 발생하면 다음을 확인하세요:

1. **로그 확인**: `dockerd --debug`로 상세 로그 확인
2. **상태 확인**: `pgrep dockerd`로 Docker 데몬 실행 상태 확인
3. **권한 확인**: `groups` 명령어로 docker 그룹 멤버십 확인
4. **네트워크 확인**: `netstat -tlnp`로 포트 사용 상태 확인

이제 WSL 환경에서 Docker를 완전히 활용할 수 있습니다! 🐳✨