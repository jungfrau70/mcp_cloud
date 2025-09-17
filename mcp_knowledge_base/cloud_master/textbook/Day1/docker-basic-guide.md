# 🐳 Docker 기본 가이드

<div align="center">

[← 이전: Cloud Master 메인](/mcp_knowledge_base/cloud_master/README.md) | [📚 전체 커리큘럼](/mcp_knowledge_base/curriculum.md) | [🏠 학습 경로로 돌아가기](/mcp_knowledge_base/index.md) | [다음: Docker 고급 가이드 →](/mcp_knowledge_base/cloud_master/textbook/Day1/docker-advanced-guide.md)

</div>

> 📋 **전체 개요**: [README.md](/mcp_knowledge_base/cloud_master/README.md) | [통합 커리큘럼](/mcp_knowledge_base/curriculum.md) | [통합 인덱스](/mcp_knowledge_base/index.md)에서 전체 과정 구조를 확인하세요.

## 🎯 학습 목표

이 가이드를 통해 다음을 학습합니다:

1. **Docker 개념 이해**: 컨테이너 기술의 핵심 개념과 장점
2. **Docker 기본 명령어**: 이미지, 컨테이너, 볼륨 관리
3. **Dockerfile 작성**: 애플리케이션 컨테이너화 방법
4. **Docker Compose**: 다중 서비스 애플리케이션 관리
5. **실습 프로젝트**: Node.js 웹 애플리케이션 컨테이너화

---

## 📚 Docker 개념 및 아키텍처

### 🐳 Docker란?

Docker는 **컨테이너 기반 가상화 플랫폼**으로, 애플리케이션과 그 의존성을 하나의 패키지로 묶어 어디서든 일관된 환경에서 실행할 수 있게 해줍니다.

#### 컨테이너 vs 가상머신

```mermaid
graph TB
    subgraph "가상머신 (VM)"
        A[Host OS] --> B[Hypervisor]
        B --> C[Guest OS 1]
        B --> D[Guest OS 2]
        B --> E[Guest OS 3]
        C --> F[App A]
        D --> G[App B]
        E --> H[App C]
    end
    
    subgraph "컨테이너 (Docker)"
        I[Host OS] --> J[Docker Engine]
        J --> K[Container 1]
        J --> L[Container 2]
        J --> M[Container 3]
        K --> N[App A]
        L --> O[App B]
        M --> P[App C]
    end
```

#### Docker의 핵심 구성요소

1. **Docker Engine**: 컨테이너를 실행하는 핵심 엔진
2. **Docker Image**: 애플리케이션과 의존성을 포함한 읽기 전용 템플릿
3. **Docker Container**: Docker Image의 실행 인스턴스
4. **Dockerfile**: 이미지를 빌드하기 위한 명령어 스크립트
5. **Docker Compose**: 다중 컨테이너 애플리케이션 관리 도구

---

## 🛠️ Docker 기본 명령어

### 설치 확인

```bash
# Docker 버전 확인
docker --version
docker-compose --version

# Docker 실행 상태 확인
docker info
```

### 이미지 관리

```bash
# 이미지 목록 확인
docker images

# 이미지 검색
docker search nginx

# 이미지 다운로드 (pull)
docker pull nginx:latest
docker pull node:18-alpine

# 이미지 삭제
docker rmi nginx:latest
docker rmi $(docker images -q)  # 모든 이미지 삭제
```

### 컨테이너 관리

```bash
# 컨테이너 실행
docker run -d -p 8080:80 --name my-nginx nginx

# 실행 중인 컨테이너 확인
docker ps

# 모든 컨테이너 확인 (중지된 것 포함)
docker ps -a

# 컨테이너 중지
docker stop my-nginx

# 컨테이너 시작
docker start my-nginx

# 컨테이너 재시작
docker restart my-nginx

# 컨테이너 삭제
docker rm my-nginx
docker rm $(docker ps -aq)  # 모든 컨테이너 삭제
```

### 컨테이너 내부 접근

```bash
# 컨테이너 내부로 접근
docker exec -it my-nginx bash

# 컨테이너 로그 확인
docker logs my-nginx
docker logs -f my-nginx  # 실시간 로그 확인
```

---

## 📝 Dockerfile 작성

### 기본 Dockerfile 구조

```dockerfile
# 베이스 이미지 지정
FROM node:18-alpine

# 작업 디렉토리 설정
WORKDIR /app

# 의존성 파일 복사
COPY package*.json ./

# 의존성 설치
RUN npm install

# 애플리케이션 코드 복사
COPY . .

# 포트 노출
EXPOSE 3000

# 애플리케이션 실행
CMD ["npm", "start"]
```

### Dockerfile 최적화 기법

```dockerfile
# 멀티스테이지 빌드 예시
FROM node:18-alpine AS builder

WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

FROM node:18-alpine AS runtime

WORKDIR /app
COPY --from=builder /app/node_modules ./node_modules
COPY . .

# 비root 사용자로 실행
RUN addgroup -g 1001 -S nodejs
RUN adduser -S nextjs -u 1001
USER nextjs

EXPOSE 3000
CMD ["npm", "start"]
```

### .dockerignore 파일

```dockerignore
node_modules
npm-debug.log
.git
.gitignore
README.md
.env
.nyc_output
coverage
.nyc_output
.vscode
```

---

## 🚀 실습: Node.js 웹 애플리케이션 컨테이너화

### 1단계: 프로젝트 준비

```bash
# 프로젝트 디렉토리 생성
mkdir docker-basic-app
cd docker-basic-app

# package.json 생성
npm init -y

# Express 설치
npm install express
```

### 2단계: 애플리케이션 코드 작성

**app.js**
```javascript
const express = require('express');
const app = express();
const PORT = process.env.PORT || 3000;

app.get('/', (req, res) => {
  res.json({
    message: 'Hello Docker!',
    timestamp: new Date().toISOString(),
    environment: process.env.NODE_ENV || 'development'
  });
});

app.get('/health', (req, res) => {
  res.json({ status: 'OK', uptime: process.uptime() });
});

app.listen(PORT, '0.0.0.0', () => {
  console.log(`Server running on port ${PORT}`);
});
```

### 3단계: Dockerfile 작성

```dockerfile
FROM node:18-alpine

WORKDIR /app

# package.json과 package-lock.json 복사
COPY package*.json ./

# 의존성 설치
RUN npm ci --only=production

# 애플리케이션 코드 복사
COPY . .

# 비root 사용자 생성 및 전환
RUN addgroup -g 1001 -S nodejs
RUN adduser -S appuser -u 1001
USER appuser

# 포트 노출
EXPOSE 3000

# 헬스체크 추가
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD node -e "require('http').get('http://localhost:3000/health', (res) => { process.exit(res.statusCode === 200 ? 0 : 1) })"

# 애플리케이션 실행
CMD ["node", "app.js"]
```

### 4단계: 이미지 빌드 및 실행

```bash
# 이미지 빌드
docker build -t my-node-app .

# 이미지 실행
docker run -d -p 3000:3000 --name my-app my-node-app

# 애플리케이션 테스트
curl http://localhost:3000
curl http://localhost:3000/health
```

---

## 🐙 Docker Compose 활용

### docker-compose.yml 작성

```yaml
version: '3.8'

services:
  web:
    build: .
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=production
    volumes:
      - ./logs:/app/logs
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/health"]
      interval: 30s
      timeout: 10s
      retries: 3

  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf
    depends_on:
      - web
    restart: unless-stopped

  redis:
    image: redis:alpine
    ports:
      - "6379:6379"
    volumes:
      - redis_data:/data
    restart: unless-stopped

volumes:
  redis_data:
```

### Docker Compose 명령어

```bash
# 서비스 시작
docker-compose up -d

# 서비스 중지
docker-compose down

# 로그 확인
docker-compose logs -f web

# 서비스 재시작
docker-compose restart web

# 볼륨까지 삭제
docker-compose down -v
```

---

## 🔧 환경 변수 및 볼륨 관리

### 환경 변수 설정

```bash
# 명령어로 환경 변수 전달
docker run -e NODE_ENV=production -e PORT=8080 my-node-app

# .env 파일 사용
docker run --env-file .env my-node-app
```

**.env 파일**
```env
NODE_ENV=production
PORT=3000
DATABASE_URL=postgresql://user:password@localhost:5432/mydb
REDIS_URL=redis://localhost:6379
```

### 볼륨 마운트

```bash
# 호스트 디렉토리를 컨테이너에 마운트
docker run -v /host/path:/container/path my-node-app

# Docker 볼륨 사용
docker volume create my-volume
docker run -v my-volume:/data my-node-app
```

---

## 🧪 실습 프로젝트: 완전한 웹 애플리케이션

### 프로젝트 구조

```
docker-basic-app/
├── app.js
├── package.json
├── Dockerfile
├── docker-compose.yml
├── .dockerignore
├── .env
├── nginx.conf
└── README.md
```

### nginx.conf 설정

```nginx
events {
    worker_connections 1024;
}

http {
    upstream app {
        server web:3000;
    }

    server {
        listen 80;
        
        location / {
            proxy_pass http://app;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
        }
    }
}
```

### 실행 및 테스트

```bash
# 전체 스택 실행
docker-compose up -d

# 서비스 상태 확인
docker-compose ps

# 애플리케이션 테스트
curl http://localhost
curl http://localhost/health

# 로그 확인
docker-compose logs -f
```

---

## 🔍 디버깅 및 문제 해결

### 일반적인 문제들

#### 1. 포트 충돌
```bash
# 포트 사용 중인 프로세스 확인
netstat -tulpn | grep :3000

# 다른 포트 사용
docker run -p 3001:3000 my-node-app
```

#### 2. 권한 문제
```bash
# Docker 그룹에 사용자 추가
sudo usermod -aG docker $USER

# 로그아웃 후 재로그인 필요
```

#### 3. 메모리 부족
```bash
# 컨테이너 메모리 제한
docker run -m 512m my-node-app

# Docker Desktop 메모리 설정 조정
```

### 유용한 디버깅 명령어

```bash
# 컨테이너 내부 프로세스 확인
docker exec -it my-app ps aux

# 컨테이너 리소스 사용량 확인
docker stats my-app

# 이미지 레이어 확인
docker history my-node-app

# 컨테이너 상세 정보
docker inspect my-app
```

---

## 📊 모니터링 및 로깅

### 로그 관리

```bash
# 로그 파일로 저장
docker logs my-app > app.log 2>&1

# 로그 로테이션 설정
docker run --log-opt max-size=10m --log-opt max-file=3 my-app
```

### 헬스체크 설정

```dockerfile
# Dockerfile에 헬스체크 추가
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:3000/health || exit 1
```

---

## 🎯 다음 단계

이 기본 가이드를 완료했다면 다음을 학습하세요:

1. **[Docker 고급 가이드](/mcp_knowledge_base/cloud_master/textbook/Day1/docker-advanced-guide.md)**: 멀티스테이지 빌드, 최적화 기법
2. **[Docker Compose 가이드](/mcp_knowledge_base/cloud_master/textbook/Day1/docker-compose-guide.md)**: 복잡한 애플리케이션 오케스트레이션
3. **[GitHub Actions 가이드](/mcp_knowledge_base/cloud_master/textbook/Day1/github-actions-guide.md)**: CI/CD 파이프라인 구축

---

## 📚 참고 자료

- [Docker 공식 문서](https://docs.docker.com/)
- [Docker Compose 문서](https://docs.docker.com/compose/)
- [Dockerfile 모범 사례](https://docs.docker.com/develop/dev-best-practices/)
- [Node.js Docker 가이드](https://nodejs.org/en/docs/guides/nodejs-docker-webapp/)

---

## 🆘 문제 해결

문제가 발생하면 다음을 확인하세요:

1. **Docker 설치 상태**: `docker --version` 명령어로 확인
2. **권한 설정**: Docker 그룹에 사용자가 포함되어 있는지 확인
3. **포트 충돌**: 사용하려는 포트가 이미 사용 중인지 확인
4. **리소스 부족**: 메모리나 디스크 공간이 충분한지 확인

> 🆘 **지원 채널**: [과정상세.md](/mcp_knowledge_base/cloud_master/과정상세.md)에서 문의 정보를 확인하세요.

**🎯 목표**: Docker의 기본 개념과 사용법을 익혀 컨테이너 기반 애플리케이션 개발의 기초를 다집니다.


---

<div align="center">

[🏠 홈](/mcp_knowledge_base/index.md) | [📚 전체 커리큘럼](/mcp_knowledge_base/curriculum.md) | [🔗 학습 경로](/mcp_knowledge_base/cloud_master/learning-path.md)

</div>