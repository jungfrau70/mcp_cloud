# Docker 기초 실습 가이드

<details>
<summary>📋 목차</summary>

1. [🎯 학습 목표](#-학습-목표)
2. [📚 실습 개요](#-실습-개요)
3. [🔧 실습 환경 준비](#-실습-환경-준비)
4. [🐳 Docker 기본 명령어](#-docker-기본-명령어)
5. [📝 Dockerfile 작성](#-dockerfile-작성)
6. [🔧 Docker Compose 실습](#-docker-compose-실습)
7. [📚 문제 해결 및 참고 자료](#-문제-해결-및-참고-자료)

</details>

---

## 🎯 학습 목표

<details>
<summary>📖 이번 실습에서 배우게 될 내용</summary>

### 핵심 학습 목표
- **Docker 기본 개념** 이해 및 컨테이너 기술 습득
- **Docker 명령어** 기본 사용법 및 이미지 관리
- **Dockerfile 작성** 및 이미지 빌드 방법
- **Docker Compose** 다중 서비스 관리

### 실습 후 달성할 수 있는 능력
- ✅ Docker 컨테이너 기본 사용법
- ✅ Dockerfile 작성 및 이미지 빌드
- ✅ Docker Compose로 다중 서비스 관리
- ✅ 웹 애플리케이션 컨테이너화

### 예상 소요 시간
- **Docker 기초**: 60-90분
- **Dockerfile 작성**: 90-120분
- **Docker Compose**: 60-90분
- **종합 실습**: 60-90분
- **전체 과정**: 4-6시간

</details>

---

## 📚 실습 개요

<details>
<summary>📖 실습 개요</summary>

### 실습 구성
1. **Docker 기본 명령어** (90분)
2. **Dockerfile 작성** (120분)
3. **Docker Compose 실습** (90분)
4. **종합 실습** (90분)

### 실습 방식
- **로컬 환경**: Docker Desktop 사용
- **단계별 실습**: 기본 → 고급 → 통합
- **실제 프로젝트**: Node.js 웹 애플리케이션

### 실습 결과물
- Docker 컨테이너화된 웹 애플리케이션
- Dockerfile 및 docker-compose.yml
- Docker Hub에 업로드된 이미지

</details>

---

## 🔧 실습 환경 준비

<details>
<summary>📋 필수 도구 설치</summary>

### Docker Desktop 설치
```bash
# Windows
winget install Docker.DockerDesktop

# macOS
brew install --cask docker

# Ubuntu
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
```

### 설치 확인
```bash
# Docker 버전 확인
docker --version
docker-compose --version

# Docker 서비스 상태 확인
docker info

# Hello World 실행
docker run hello-world
```

</details>

<details>
<summary>🔧 Docker Hub 계정 설정</summary>

### Docker Hub 계정 생성
1. [Docker Hub](https://hub.docker.com) 방문
2. 계정 생성 및 이메일 인증
3. 로그인 및 토큰 생성

### Docker Hub 로그인
```bash
# Docker Hub에 로그인
docker login

# 로그인 확인
docker system info | grep Username
```

</details>

---

## 🐳 Docker 기본 명령어

<details>
<summary>📖 Docker 기본 개념</summary>

### Docker 아키텍처
- **이미지**: 컨테이너의 템플릿
- **컨테이너**: 실행 중인 이미지 인스턴스
- **레지스트리**: 이미지 저장소 (Docker Hub)
- **Dockerfile**: 이미지 빌드 명세서

### Docker vs 가상머신
| 구분 | Docker | 가상머신 |
|------|--------|----------|
| **가상화 레벨** | OS 레벨 | 하드웨어 레벨 |
| **리소스 사용량** | 적음 | 많음 |
| **시작 시간** | 빠름 (초) | 느림 (분) |
| **이식성** | 높음 | 낮음 |

</details>

<details>
<summary>🔗 이미지 관리 명령어</summary>

### 이미지 다운로드 및 확인
```bash
# 이미지 다운로드
docker pull nginx:alpine
docker pull node:18-alpine

# 이미지 목록 확인
docker images

# 이미지 상세 정보
docker inspect nginx:alpine

# 이미지 삭제
docker rmi nginx:alpine
```

### 이미지 빌드
```bash
# Dockerfile로 이미지 빌드
docker build -t my-app:latest .

# 태그 지정하여 빌드
docker build -t my-app:v1.0.0 .

# 빌드 컨텍스트 지정
docker build -f Dockerfile.prod -t my-app:prod .
```

</details>

<details>
<summary>🔗 컨테이너 관리 명령어</summary>

### 컨테이너 실행
```bash
# 컨테이너 실행 (백그라운드)
docker run -d -p 3000:3000 --name my-app my-app:latest

# 컨테이너 실행 (인터랙티브)
docker run -it --name my-container ubuntu:20.04 bash

# 환경 변수 설정
docker run -e NODE_ENV=production my-app:latest

# 볼륨 마운트
docker run -v /host/path:/container/path my-app:latest
```

### 컨테이너 관리
```bash
# 실행 중인 컨테이너 확인
docker ps

# 모든 컨테이너 확인
docker ps -a

# 컨테이너 중지
docker stop my-app

# 컨테이너 시작
docker start my-app

# 컨테이너 삭제
docker rm my-app

# 컨테이너 로그 확인
docker logs my-app

# 컨테이너 내부 접속
docker exec -it my-app bash
```

</details>

---

## 📝 Dockerfile 작성

<details>
<summary>📖 Dockerfile 기본 구조</summary>

### Dockerfile 명령어
| 명령어 | 설명 | 예시 |
|--------|------|------|
| **FROM** | 베이스 이미지 지정 | `FROM node:18-alpine` |
| **WORKDIR** | 작업 디렉토리 설정 | `WORKDIR /app` |
| **COPY** | 파일 복사 | `COPY . .` |
| **RUN** | 명령어 실행 | `RUN npm install` |
| **EXPOSE** | 포트 노출 | `EXPOSE 3000` |
| **CMD** | 컨테이너 실행 명령 | `CMD ["npm", "start"]` |

### 기본 Dockerfile 예시
```dockerfile
FROM node:18-alpine

WORKDIR /app

COPY package*.json ./
RUN npm ci --only=production

COPY . .

EXPOSE 3000

CMD ["npm", "start"]
```

</details>

<details>
<summary>🔗 Node.js 애플리케이션 Dockerfile</summary>

### 기본 Dockerfile
```dockerfile
# 베이스 이미지
FROM node:18-alpine

# 작업 디렉토리 설정
WORKDIR /app

# 의존성 파일 복사
COPY package*.json ./

# 의존성 설치
RUN npm ci --only=production

# 소스 코드 복사
COPY . .

# 포트 노출
EXPOSE 3000

# 애플리케이션 실행
CMD ["npm", "start"]
```

### 최적화된 Dockerfile
```dockerfile
# 멀티스테이지 빌드
FROM node:18-alpine AS builder

WORKDIR /app
COPY package*.json ./
RUN npm ci

COPY . .
RUN npm run build

# 실행 환경
FROM node:18-alpine AS runtime

WORKDIR /app
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package*.json ./

# 비루트 사용자
RUN addgroup -g 1001 -S nodejs
RUN adduser -S nextjs -u 1001
USER nextjs

EXPOSE 3000
CMD ["npm", "start"]
```

</details>

<details>
<summary>🔗 .dockerignore 파일</summary>

### .dockerignore 설정
```dockerignore
# Git
.git
.gitignore

# Dependencies
node_modules
npm-debug.log*

# Build outputs
dist
build
.next

# Environment files
.env
.env.local
.env.production

# IDE
.vscode
.idea

# OS
.DS_Store
Thumbs.db

# Logs
logs
*.log
```

</details>

---

## 🔧 Docker Compose 실습

<details>
<summary>📖 Docker Compose 개념</summary>

### Docker Compose란?
- **정의**: 다중 컨테이너 Docker 애플리케이션 정의 및 실행 도구
- **특징**: YAML 파일로 서비스 정의, 네트워킹, 볼륨 관리
- **용도**: 개발 환경, 테스트 환경, 단일 호스트 배포

### docker-compose.yml 구조
```yaml
version: '3.8'

services:
  web:
    build: .
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=production
    depends_on:
      - db

  db:
    image: postgres:13-alpine
    environment:
      - POSTGRES_DB=myapp
      - POSTGRES_USER=user
      - POSTGRES_PASSWORD=password
    volumes:
      - postgres_data:/var/lib/postgresql/data

volumes:
  postgres_data:
```

</details>

<details>
<summary>🔗 웹 애플리케이션 Docker Compose</summary>

### 완전한 docker-compose.yml
```yaml
version: '3.8'

services:
  # 웹 애플리케이션
  web:
    build:
      context: .
      dockerfile: Dockerfile
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=production
      - DATABASE_URL=postgresql://user:password@db:5432/myapp
    depends_on:
      db:
        condition: service_healthy
    restart: unless-stopped
    networks:
      - app-network

  # 데이터베이스
  db:
    image: postgres:13-alpine
    environment:
      - POSTGRES_DB=myapp
      - POSTGRES_USER=user
      - POSTGRES_PASSWORD=password
    volumes:
      - postgres_data:/var/lib/postgresql/data
    restart: unless-stopped
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U user -d myapp"]
      interval: 10s
      timeout: 5s
      retries: 5
    networks:
      - app-network

  # Redis 캐시
  redis:
    image: redis:6-alpine
    command: redis-server --appendonly yes
    volumes:
      - redis_data:/data
    restart: unless-stopped
    networks:
      - app-network

  # Nginx 리버스 프록시
  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf
    depends_on:
      - web
    restart: unless-stopped
    networks:
      - app-network

volumes:
  postgres_data:
  redis_data:

networks:
  app-network:
    driver: bridge
```

</details>

<details>
<summary>🔗 Docker Compose 명령어</summary>

### 기본 명령어
```bash
# 서비스 시작
docker-compose up -d

# 서비스 중지
docker-compose down

# 서비스 재시작
docker-compose restart

# 로그 확인
docker-compose logs

# 특정 서비스 로그
docker-compose logs web

# 서비스 상태 확인
docker-compose ps

# 서비스 빌드
docker-compose build

# 서비스 강제 재빌드
docker-compose build --no-cache
```

### 고급 명령어
```bash
# 특정 서비스만 실행
docker-compose up web db

# 환경 변수 파일 지정
docker-compose --env-file .env.production up

# 스케일링
docker-compose up --scale web=3

# 볼륨 삭제
docker-compose down -v
```

</details>

---

## 📚 문제 해결 및 참고 자료

<details>
<summary>🐛 자주 발생하는 문제</summary>

### Docker 관련 문제
<details>
<summary>❌ Docker 이미지 빌드 실패</summary>

**원인**: 
- Dockerfile 문법 오류
- 의존성 설치 실패
- 권한 문제

**해결방법**:
```bash
# 1. Dockerfile 문법 검사
docker build --no-cache -t my-app .

# 2. 빌드 로그 확인
docker build --progress=plain -t my-app .

# 3. 권한 확인
docker run --rm -v $(pwd):/app -w /app node:18-alpine sh -c "ls -la"
```

</details>

<details>
<summary>❌ Docker 컨테이너 실행 실패</summary>

**원인**:
- 포트 충돌
- 환경 변수 누락
- 이미지 없음

**해결방법**:
```bash
# 1. 포트 확인
docker ps -a
netstat -tulpn | grep :3000

# 2. 환경 변수 확인
docker run -e NODE_ENV=production my-app

# 3. 이미지 확인
docker images | grep my-app
```

</details>

### Docker Compose 관련 문제
<details>
<summary>❌ 서비스 시작 실패</summary>

**원인**:
- 의존성 문제
- 포트 충돌
- 환경 변수 누락

**해결방법**:
```bash
# 1. 서비스 상태 확인
docker-compose ps

# 2. 로그 확인
docker-compose logs service-name

# 3. 서비스 재시작
docker-compose restart service-name
```

</details>

</details>

<details>
<summary>📖 추가 학습 자료</summary>

### 공식 문서
- [Docker 공식 문서](https://docs.docker.com/)
- [Docker Compose 공식 문서](https://docs.docker.com/compose/)
- [Dockerfile 참조](https://docs.docker.com/engine/reference/builder/)
- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)

### 유용한 리소스
- [Docker Hub](https://hub.docker.com/)
- [Docker 샘플 프로젝트](https://github.com/docker/awesome-compose)
- [Docker 보안 가이드](https://docs.docker.com/engine/security/)

### 관련 프로젝트
- [Docker Compose 예제](https://docs.docker.com/compose/gettingstarted/)
- [멀티스테이지 빌드 예제](https://docs.docker.com/develop/dev-best-practices/dockerfile_best-practices/#use-multi-stage-builds)

</details>

<details>
<summary>🚀 다음 단계</summary>

### GitHub Actions 연동
1. **Docker 이미지 자동 빌드**: GitHub Actions로 이미지 빌드
2. **Docker Hub 푸시**: 자동으로 Docker Hub에 이미지 업로드
3. **VM 배포**: 자동으로 VM에 컨테이너 배포

### 실무 적용
1. **마이크로서비스**: Docker Compose로 마이크로서비스 구성
2. **개발 환경**: 로컬 개발 환경 Docker화
3. **CI/CD**: Docker를 활용한 자동화 파이프라인

</details>

---

## 🎉 완료!

축하합니다! Docker 기초 실습을 완료했습니다.

### 📚 학습 요약

이번 실습을 통해 다음을 배웠습니다:

1. **🐳 Docker 기본**: 컨테이너 기술 및 기본 명령어
2. **📝 Dockerfile**: 이미지 빌드 및 최적화
3. **🔧 Docker Compose**: 다중 서비스 관리
4. **🏗️ 웹 애플리케이션**: 컨테이너화된 웹 애플리케이션

### 🚀 다음 단계

- **GitHub Actions**: CI/CD 파이프라인 구축
- **VM 배포**: 컨테이너를 VM에 배포
- **실제 프로젝트 적용**: 자신의 프로젝트에 Docker 적용

### 💡 추가 학습 자료

- [Docker 공식 문서](https://docs.docker.com/)
- [Docker Compose 공식 문서](https://docs.docker.com/compose/)
- [GitHub Actions 기초 실습](./github-actions-basics.md)

---

**🎯 이제 Docker의 기본기를 갖추었습니다! GitHub Actions 실습으로 진행하세요.**
