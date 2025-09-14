# Docker 기초 실습 가이드

<div align="center">

[← 이전: Cloud Master 메인](../../README.md) | [📚 전체 커리큘럼](../../../curriculum.md) | [🏠 학습 경로로 돌아가기](../../../index.md) | [📋 학습 경로](../../../learning-path.md)

</div>

<div align="center">

[← 이전: Cloud Master 1일차 메인](../README) | [📚 전체 커리큘럼](../../../../curriculum) | [🏠 학습 경로로 돌아가기](../../../../index.md) | [다음: Git/GitHub 기초 실습 →](./git-github-basics)

</div>

## 🎯 실습 목표
- Docker의 기본 개념 이해
- Dockerfile 작성 및 이미지 빌드
- Docker Compose를 활용한 다중 서비스 관리
- 실제 웹 애플리케이션 컨테이너화

## 📋 실습 환경 준비

### 필수 도구 설치
```bash
# Docker Desktop 설치 확인
docker --version
docker-compose --version

# Docker 실행 상태 확인
docker info
```

## 🐳 실습 1: 기본 Docker 명령어

### 1. Hello World 컨테이너 실행
```bash
# Hello World 이미지 다운로드 및 실행
docker run hello-world

# 실행 중인 컨테이너 확인
docker ps

# 모든 컨테이너 확인 (중지된 것 포함)
docker ps -a

# 이미지 목록 확인
docker images
```

### 2. Nginx 웹서버 실행
```bash
# Nginx 컨테이너 실행
docker run -d -p 8080:80 --name my-nginx nginx

# 웹브라우저에서 http://localhost:8080 접속 확인

# 컨테이너 중지
docker stop my-nginx

# 컨테이너 삭제
docker rm my-nginx
```

## 🐳 실습 2: Dockerfile 작성

### 1. 간단한 Node.js 애플리케이션 생성

**package.json**
```json
{
  "name": "docker-basics-app",
  "version": "1.0.0",
  "description": "Simple Node.js app for Docker practice",
  "main": "app.js",
  "scripts": {
    "start": "node app.js"
  },
  "dependencies": {
    "express": "^4.18.2"
  }
}
```

**app.js**
```javascript
const express = require('express');
const app = express();
const port = 3000;

app.get('/', (req, res) => {
  res.send(`
    <h1>Hello Docker!</h1>
    <p>This is a simple Node.js app running in a Docker container.</p>
    <p>Current time: ${new Date().toISOString()}</p>
  `);
});

app.get('/health', (req, res) => {
  res.json({ status: 'OK', uptime: process.uptime() });
});

app.listen(port, () => {
  console.log(`App running at http://localhost:${port}`);
});
```

### 2. Dockerfile 작성

**Dockerfile**
```dockerfile
# Node.js 18 버전을 베이스 이미지로 사용
FROM node:18

# 작업 디렉토리 설정
WORKDIR /app

# 패키지 파일 복사 (캐시 최적화를 위해 의존성 설치를 먼저)
COPY package*.json ./

# 의존성 설치
RUN npm install

# 소스 코드 복사
COPY . .

# 포트 3000 노출
EXPOSE 3000

# 애플리케이션 시작
CMD ["npm", "start"]
```

### 3. 이미지 빌드 및 실행
```bash
# 이미지 빌드
docker build -t my-node-app .

# 컨테이너 실행
docker run -p 3000:3000 my-node-app

# 백그라운드 실행
docker run -d -p 3000:3000 --name my-app my-node-app

# 컨테이너 로그 확인
docker logs my-app

# 컨테이너 내부 접속
docker exec -it my-app /bin/bash
```

## 🐳 실습 3: Docker Compose

### 1. docker-compose.yml 작성

**docker-compose.yml**
```yaml
version: '3.8'

services:
  # 웹 애플리케이션 서비스
  web:
    build: .
    ports:
      - "3000:3000"
    volumes:
      - ./:/app
      - /app/node_modules
    environment:
      - NODE_ENV=development
    depends_on:
      - db
    restart: unless-stopped

  # MongoDB 데이터베이스 서비스
  db:
    image: mongo:6.0
    ports:
      - "27017:27017"
    environment:
      - MONGO_INITDB_ROOT_USERNAME=admin
      - MONGO_INITDB_ROOT_PASSWORD=secret
    volumes:
      - mongodb_data:/data/db
    restart: unless-stopped

# 볼륨 정의
volumes:
  mongodb_data:
```

### 2. Docker Compose 명령어 실행
```bash
# 서비스 시작
docker-compose up

# 백그라운드에서 시작
docker-compose up -d

# 서비스 중지
docker-compose down

# 볼륨까지 삭제
docker-compose down -v

# 로그 확인
docker-compose logs

# 특정 서비스 로그 확인
docker-compose logs web
```

## 🐳 실습 4: 멀티스테이지 빌드

### 1. 최적화된 Dockerfile 작성

**Dockerfile.optimized**
```dockerfile
# 빌드 스테이지
FROM node:18 AS builder

WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

# 프로덕션 스테이지
FROM node:18-alpine AS production

WORKDIR /app

# 빌드 스테이지에서 필요한 파일만 복사
COPY --from=builder /app/node_modules ./node_modules
COPY . .

# 비root 사용자로 실행
RUN addgroup -g 1001 -S nodejs
RUN adduser -S nextjs -u 1001
USER nextjs

EXPOSE 3000
CMD ["npm", "start"]
```

### 2. 최적화된 이미지 빌드
```bash
# 최적화된 이미지 빌드
docker build -f Dockerfile.optimized -t my-node-app-optimized .

# 이미지 크기 비교
docker images | grep my-node-app
```

## 🐳 실습 5: Docker Hub에 이미지 푸시

### 1. Docker Hub 계정 생성 및 로그인
```bash
# Docker Hub 로그인
docker login

# 이미지 태그 지정
docker tag my-node-app username/my-node-app:latest

# 이미지 푸시
docker push username/my-node-app:latest
```

### 2. 다른 환경에서 이미지 사용
```bash
# Docker Hub에서 이미지 다운로드
docker pull username/my-node-app:latest

# 이미지 실행
docker run -p 3000:3000 username/my-node-app:latest
```

## 🐳 실습 6: 문제 해결

### 1. 컨테이너 디버깅
```bash
# 실행 중인 컨테이너 확인
docker ps

# 컨테이너 로그 확인
docker logs <container_id>

# 컨테이너 내부 접속
docker exec -it <container_id> /bin/bash

# 컨테이너 프로세스 확인
docker top <container_id>
```

### 2. 이미지 분석
```bash
# 이미지 히스토리 확인
docker history my-node-app

# 이미지 상세 정보 확인
docker inspect my-node-app

# 이미지 크기 분석
docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}"
```

## 🎯 실습 완료 체크리스트

- [ ] Docker 기본 명령어 사용
- [ ] Dockerfile 작성 및 이미지 빌드
- [ ] Docker Compose로 다중 서비스 관리
- [ ] 멀티스테이지 빌드로 이미지 최적화
- [ ] Docker Hub에 이미지 푸시
- [ ] 컨테이너 디버깅 및 문제 해결

## 📚 추가 학습 자료

- [Docker 공식 문서](https://docs.docker.com/)
- [Docker Hub](https://hub.docker.com/)
- [Docker Compose 문서](https://docs.docker.com/compose/)
- [Dockerfile 모범 사례](https://docs.docker.com/develop/dev-best-practices/)

## 🚀 다음 단계

- **Git/GitHub 기초**: 버전 관리 및 협업
- **GitHub Actions**: CI/CD 파이프라인 구축
- **VM 배포**: 클라우드 환경에 애플리케이션 배포
