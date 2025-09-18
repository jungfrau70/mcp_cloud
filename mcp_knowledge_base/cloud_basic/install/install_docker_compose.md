# Docker Compose 설치 가이드


Docker Compose는 다중 컨테이너 Docker 애플리케이션을 정의하고 실행하기 위한 도구입니다. 이 가이드는 다양한 운영체제에서 Docker Compose를 설치하는 방법을 설명합니다.

## 목차
- [Docker Compose란?](#docker-compose란)
- [Windows 설치](#windows-설치)
- [macOS 설치](#macos-설치)
- [Linux 설치](#linux-설치)
- [설치 확인](#설치-확인)
- [기본 사용법](#기본-사용법)
- [문제 해결](#문제-해결)

## Docker Compose란?

Docker Compose는 YAML 파일을 사용하여 다중 컨테이너 애플리케이션을 정의하고 실행하는 도구입니다. 주요 기능:

- **다중 컨테이너 정의**: 하나의 YAML 파일로 여러 서비스 정의
- **환경별 설정**: 개발, 테스트, 프로덕션 환경별 설정
- **의존성 관리**: 서비스 간 의존성 및 시작 순서 관리
- **볼륨 및 네트워크**: 컨테이너 간 데이터 공유 및 통신 설정

## Windows 설치

### 방법 1: Docker Desktop 포함 (권장)

Docker Desktop을 설치하면 Docker Compose가 자동으로 포함됩니다.

```bash
# Docker Desktop 설치 후 확인
docker compose version
```

### 방법 2: 독립 설치

1. **Docker Compose 바이너리 다운로드**
   ```powershell
   # PowerShell에서 실행
   $latest = (Invoke-RestMethod -Uri "https:///api.github.com/repos/docker/compose/releases/latest").tag_name
   Invoke-WebRequest -Uri "https:///github.com/docker/compose/releases/download/$latest/docker-compose-Windows-x86_64.exe" -OutFile "docker-compose.exe"
   ```

2. **PATH에 추가**
   ```powershell
   # C:/bin 디렉토리 생성 (없는 경우)
   New-Item -ItemType Directory -Path "C:/bin" -Force
   
   # docker-compose.exe를 C:/bin으로 이동
   Move-Item docker-compose.exe C:/bin/
   
   # PATH에 C:/bin 추가
   [Environment]::SetEnvironmentVariable("Path", $env:Path + ";C:/bin", [EnvironmentVariableTarget]::User)
   ```

### 방법 3: Chocolatey 사용

```cmd
choco install docker-compose
```

### 방법 4: winget 사용

```cmd
winget install Docker.Compose
```

## macOS 설치

### 방법 1: Docker Desktop 포함 (권장)

Docker Desktop을 설치하면 Docker Compose가 자동으로 포함됩니다.

```bash
# Docker Desktop 설치 후 확인
docker compose version
```

### 방법 2: Homebrew 사용

```bash
# Homebrew 설치 확인
brew --version

# Docker Compose 설치
brew install docker-compose
```

### 방법 3: 독립 설치

```bash
# 최신 버전 다운로드
sudo curl -L "https:///github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

# 실행 권한 부여
sudo chmod +x /usr/local/bin/docker-compose

# 심볼릭 링크 생성 (선택사항)
sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
```

### 방법 4: pip 사용

```bash
# Python 확인
python3 --version

# Docker Compose 설치
pip3 install docker-compose
```

## Linux 설치

### Ubuntu/Debian

#### 방법 1: Docker Compose 플러그인 (권장)

Docker Engine과 함께 설치됩니다:

```bash
# Docker 설치 시 함께 설치됨
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# 사용법: docker compose (공백 포함)
docker compose version
```

#### 방법 2: 독립 바이너리 설치

```bash
# 최신 버전 확인
COMPOSE_VERSION=$(curl -s https:///api.github.com/repos/docker/compose/releases/latest | grep tag_name | cut -d '"' -f 4)

# Docker Compose 다운로드
sudo curl -L "https:///github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

# 실행 권한 부여
sudo chmod +x /usr/local/bin/docker-compose

# 심볼릭 링크 생성
sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
```

#### 방법 3: pip 사용

```bash
# pip 설치 (없는 경우)
sudo apt-get install -y python3-pip

# Docker Compose 설치
pip3 install docker-compose
```

### CentOS/RHEL/Rocky Linux

#### 방법 1: Docker Compose 플러그인 (권장)

```bash
# Docker 설치 시 함께 설치됨
sudo yum install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# 사용법: docker compose
docker compose version
```

#### 방법 2: 독립 바이너리 설치

```bash
# 최신 버전 다운로드
COMPOSE_VERSION=$(curl -s https:///api.github.com/repos/docker/compose/releases/latest | grep tag_name | cut -d '"' -f 4)

sudo curl -L "https:///github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

sudo chmod +x /usr/local/bin/docker-compose
```

### Fedora

```bash
# dnf 사용
sudo dnf install -y docker-compose

# 또는 최신 버전 바이너리 설치
COMPOSE_VERSION=$(curl -s https:///api.github.com/repos/docker/compose/releases/latest | grep tag_name | cut -d '"' -f 4)
sudo curl -L "https:///github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

### openSUSE

```bash
# zypper 사용
sudo zypper install docker-compose

# 또는 바이너리 설치
COMPOSE_VERSION=$(curl -s https:///api.github.com/repos/docker/compose/releases/latest | grep tag_name | cut -d '"' -f 4)
sudo curl -L "https:///github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

### Arch Linux

```bash
# pacman 사용
sudo pacman -S docker-compose

# 또는 AUR 사용
yay -S docker-compose
```

## 설치 확인

설치가 완료된 후 다음 명령어로 확인할 수 있습니다:

```bash
# Docker Compose 버전 확인 (플러그인)
docker compose version

# 또는 독립 바이너리
docker-compose --version
```

예상 출력:
```
Docker Compose version v2.21.0
```

## 기본 사용법

### 1. docker-compose.yml 파일 생성

```yaml
# docker-compose.yml
version: '3.8'

services:
  web:
    image: nginx:alpine
    ports:
      - "80:80"
    volumes:
      - ./html:/usr/share/nginx/html
    depends_on:
      - db

  db:
    image: postgres:13
    environment:
      POSTGRES_DB: myapp
      POSTGRES_USER: user
      POSTGRES_PASSWORD: password
    volumes:
      - postgres_data:/var/lib/postgresql/data

volumes:
  postgres_data:
```

### 2. 기본 명령어

```bash
# 서비스 시작 (백그라운드)
docker compose up -d

# 서비스 중지
docker compose down

# 서비스 재시작
docker compose restart

# 로그 확인
docker compose logs

# 특정 서비스 로그
docker compose logs web

# 서비스 상태 확인
docker compose ps

# 서비스 빌드 및 시작
docker compose up --build

# 환경 변수 파일 사용
docker compose --env-file .env up
```

### 3. 환경별 설정

```yaml
# docker-compose.override.yml (개발 환경)
version: '3.8'

services:
  web:
    volumes:
      - ./src:/app/src
    environment:
      - DEBUG=true
    ports:
      - "3000:3000"
```

```yaml
# docker-compose.prod.yml (프로덕션 환경)
version: '3.8'

services:
  web:
    restart: unless-stopped
    environment:
      - DEBUG=false
    deploy:
      replicas: 3
      resources:
        limits:
          cpus: '0.5'
          memory: 512M
```

## 문제 해결

### 일반적인 문제들

1. **명령어를 찾을 수 없음**
   ```bash
   # PATH 확인
   echo $PATH
   
   # Docker Compose 경로 확인
   which docker-compose
   which docker
   
   # 플러그인 버전 사용
   docker compose version
   ```

2. **권한 오류**
   ```bash
   # 사용자를 docker 그룹에 추가
   sudo usermod -aG docker $USER
   
   # 재로그인 또는 그룹 변경사항 적용
   newgrp docker
   ```

3. **포트 충돌**
   ```bash
   # 사용 중인 포트 확인
   sudo netstat -tulpn | grep :80
   
   # 다른 포트 사용
   docker compose up -d --scale web=0
   docker compose up -d -p 8080:80
   ```

4. **볼륨 마운트 오류**
   ```bash
   # 볼륨 권한 확인
   ls -la ./html
   
   # 권한 수정
   sudo chown -R $USER:$USER ./html
   ```

### 로그 및 디버깅

```bash
# 상세 로그 확인
docker compose logs --follow

# 특정 서비스 로그
docker compose logs web --tail=100

# 디버그 모드로 실행
docker compose up --verbose

# 서비스 상태 확인
docker compose ps -a
```

### 성능 최적화

```bash
# 사용하지 않는 리소스 정리
docker compose down --volumes --remove-orphans

# 이미지 정리
docker compose down --rmi all

# 시스템 전체 정리
docker system prune -a
```

## 고급 기능

### 1. 환경 변수 관리

```bash
# .env 파일 생성
cat > .env << EOF
POSTGRES_DB=myapp
POSTGRES_USER=user
POSTGRES_PASSWORD=password
DEBUG=true
EOF

# 환경 변수 사용
docker compose up
```

### 2. 프로파일 사용

```yaml
# docker-compose.yml
version: '3.8'

services:
  web:
    image: nginx
    profiles: ["frontend"]
  
  api:
    image: node:alpine
    profiles: ["backend"]
  
  db:
    image: postgres
    profiles: ["database"]
```

```bash
# 특정 프로파일만 실행
docker compose --profile frontend up
docker compose --profile backend --profile database up
```

### 3. 확장 및 스케일링

```bash
# 서비스 확장
docker compose up --scale web=3

# 특정 서비스만 확장
docker compose up -d --scale web=5 --no-deps web
```

### 4. 네트워크 및 볼륨 관리

```yaml
# docker-compose.yml
version: '3.8'

services:
  web:
    image: nginx
    networks:
      - frontend
    volumes:
      - web_data:/var/www/html

  api:
    image: node:alpine
    networks:
      - frontend
      - backend

networks:
  frontend:
    driver: bridge
  backend:
    driver: bridge

volumes:
  web_data:
    driver: local
```

## 추가 리소스

- [Docker Compose 공식 문서](https:///docs.docker.com/compose/)
- [Docker Compose 명령어 참조](https:///docs.docker.com/compose/reference/)
- [Docker Compose 파일 참조](https:///docs.docker.com/compose/compose-file/)
- [Docker Compose 환경 변수](https:///docs.docker.com/compose/environment-variables/)

## 버전 관리

```bash
# 현재 버전 확인
docker compose version

# 업데이트
# 플러그인: Docker Engine 업데이트와 함께
# 독립 바이너리: 수동 다운로드 및 교체

# 최신 버전 확인
curl -s https:///api.github.com/repos/docker/compose/releases/latest | grep tag_name
```

## 보안 모범 사례

1. **최신 버전 사용**: 정기적으로 Docker Compose 업데이트
2. **환경 변수 보안**: 민감한 정보는 .env 파일로 관리
3. **네트워크 격리**: 필요한 서비스만 외부 노출
4. **리소스 제한**: 컨테이너 리소스 제한 설정
5. **볼륨 보안**: 민감한 데이터 볼륨 암호화

```yaml
# 보안 설정 예시
version: '3.8'

services:
  web:
    image: nginx
    restart: unless-stopped
    security_opt:
      - no-new-privileges:true
    read_only: true
    tmpfs:
      - /tmp
      - /var/cache/nginx
    deploy:
      resources:
        limits:
          cpus: '0.5'
          memory: 512M
```

## 자동화 스크립트

### Ubuntu/Debian 자동 설치 스크립트

```bash
#!/bin/bash
set -e

echo "Docker Compose 설치 시작..."

# 최신 버전 확인
COMPOSE_VERSION=$(curl -s https:///api.github.com/repos/docker/compose/releases/latest | grep tag_name | cut -d '"' -f 4)

echo "Docker Compose 버전: $COMPOSE_VERSION"

# Docker Compose 다운로드
sudo curl -L "https:///github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

# 실행 권한 부여
sudo chmod +x /usr/local/bin/docker-compose

# 심볼릭 링크 생성
sudo ln -sf /usr/local/bin/docker-compose /usr/bin/docker-compose

# 설치 확인
docker-compose --version

echo "Docker Compose 설치 완료!"
```

### 테스트 스크립트

```bash
#!/bin/bash
# Docker Compose 테스트 스크립트

# 테스트용 docker-compose.yml 생성
cat > docker-compose.test.yml << EOF
version: '3.8'

services:
  test:
    image: hello-world
    restart: "no"
EOF

# 테스트 실행
echo "Docker Compose 테스트 시작..."
docker-compose -f docker-compose.test.yml up

# 정리
docker-compose -f docker-compose.test.yml down
rm docker-compose.test.yml

echo "테스트 완료!"
```


---


---



<div align="center">

[← 이전: Cloud Basic 메인](/mcp_knowledge_base/README.md) | [📚 전체 커리큘럼](/mcp_knowledge_base/curriculum.md) | [🏠 학습 경로로 돌아가기](/mcp_knowledge_base/index.md) | [📋 학습 경로](/mcp_knowledge_base/learning-path.md)

</div>