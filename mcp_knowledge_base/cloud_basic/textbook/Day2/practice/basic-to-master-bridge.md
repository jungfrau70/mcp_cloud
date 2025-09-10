# Cloud Basic → Cloud Master 연계 가이드

## 📋 개요

**목적**: Cloud Basic 과정 완료 후 Cloud Master 과정으로 자연스럽게 연결되는 중간 단계 학습
**범위**: 
- Docker 기초 개념 및 실습
- Git 및 GitHub 사용법
- 간단한 웹 애플리케이션 개발
- 클라우드 배포 준비

---

## 🎯 학습 목표

Cloud Basic 완료 후 다음을 학습합니다:

- **Docker 기초**: 컨테이너 개념 및 기본 사용법
- **Git/GitHub**: 버전 관리 및 협업 도구 사용
- **웹 애플리케이션 개발**: Node.js 기초 및 간단한 API 개발
- **배포 준비**: Cloud Master 과정을 위한 기초 지식 습득

---

## 🐳 Docker 기초 실습

### 1. Docker 설치 및 기본 사용법

```bash
# Docker 설치 확인
docker --version

# Hello World 실행
docker run hello-world

# 이미지 목록 확인
docker images

# 실행 중인 컨테이너 확인
docker ps
```

### 2. 간단한 웹 애플리케이션 컨테이너화

#### Node.js 애플리케이션 생성
```javascript
// app.js
const express = require('express');
const app = express();
const port = 3000;

app.get('/', (req, res) => {
  res.send('Hello from Docker!');
});

app.get('/health', (req, res) => {
  res.json({ status: 'healthy', timestamp: new Date().toISOString() });
});

app.listen(port, () => {
  console.log(`App running on port ${port}`);
});
```

#### package.json 생성
```json
{
  "name": "docker-basic-app",
  "version": "1.0.0",
  "description": "Basic Node.js app for Docker practice",
  "main": "app.js",
  "scripts": {
    "start": "node app.js"
  },
  "dependencies": {
    "express": "^4.18.2"
  }
}
```

#### Dockerfile 생성
```dockerfile
FROM node:18-alpine

WORKDIR /app

COPY package*.json ./
RUN npm install

COPY . .

EXPOSE 3000

CMD ["npm", "start"]
```

#### Docker 이미지 빌드 및 실행
```bash
# 이미지 빌드
docker build -t basic-web-app .

# 컨테이너 실행
docker run -p 3000:3000 basic-web-app

# 브라우저에서 http://localhost:3000 접속
```

---

## 📝 Git/GitHub 기초 실습

### 1. Git 저장소 초기화

```bash
# Git 저장소 초기화
git init

# 사용자 정보 설정
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"

# 파일 추가 및 커밋
git add .
git commit -m "Initial commit: Basic web app with Docker"
```

### 2. GitHub 저장소 생성 및 연결

```bash
# GitHub 저장소 연결
git remote add origin https://github.com/yourusername/docker-basic-app.git

# 브랜치 설정
git branch -M main

# 원격 저장소에 푸시
git push -u origin main
```

### 3. 기본 Git 워크플로우

```bash
# 변경사항 확인
git status

# 변경사항 추가
git add .

# 커밋
git commit -m "Add new feature"

# 푸시
git push origin main

# 풀
git pull origin main
```

---

## 🌐 웹 애플리케이션 개발 기초

### 1. Express.js 기초

```javascript
// app.js (확장 버전)
const express = require('express');
const app = express();
const port = process.env.PORT || 3000;

// 미들웨어
app.use(express.json());
app.use(express.static('public'));

// 라우트
app.get('/', (req, res) => {
  res.send(`
    <h1>Cloud Basic → Master Bridge</h1>
    <p>Welcome to the bridge course!</p>
    <ul>
      <li><a href="/health">Health Check</a></li>
      <li><a href="/api/info">API Info</a></li>
    </ul>
  `);
});

app.get('/health', (req, res) => {
  res.json({ 
    status: 'healthy', 
    timestamp: new Date().toISOString(),
    uptime: process.uptime()
  });
});

app.get('/api/info', (req, res) => {
  res.json({
    app: 'Docker Basic App',
    version: '1.0.0',
    environment: process.env.NODE_ENV || 'development'
  });
});

app.listen(port, '0.0.0.0', () => {
  console.log(`App running on port ${port}`);
});
```

### 2. 환경 변수 사용

```bash
# .env 파일 생성
echo "NODE_ENV=production" > .env
echo "PORT=3000" >> .env
```

```javascript
// 환경 변수 로드
require('dotenv').config();

const port = process.env.PORT || 3000;
const nodeEnv = process.env.NODE_ENV || 'development';
```

---

## 🚀 Cloud Master 준비

### 1. Docker Compose 기초

```yaml
# docker-compose.yml
version: '3.8'

services:
  web:
    build: .
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=production
    restart: unless-stopped

  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf
    depends_on:
      - web
```

### 2. Nginx 설정

```nginx
# nginx.conf
events {
    worker_connections 1024;
}

http {
    upstream web {
        server web:3000;
    }

    server {
        listen 80;
        
        location / {
            proxy_pass http://web;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
        }
    }
}
```

### 3. Docker Compose 실행

```bash
# 서비스 시작
docker-compose up -d

# 로그 확인
docker-compose logs

# 서비스 중지
docker-compose down
```

---

## ✅ 체크리스트

### Docker 기초
- [ ] Docker 설치 및 기본 명령어 숙지
- [ ] 간단한 웹 애플리케이션 컨테이너화
- [ ] Dockerfile 작성 및 이미지 빌드
- [ ] Docker Compose 기본 사용법

### Git/GitHub 기초
- [ ] Git 저장소 초기화 및 기본 워크플로우
- [ ] GitHub 저장소 생성 및 연결
- [ ] 커밋, 푸시, 풀 기본 명령어 숙지

### 웹 애플리케이션 개발
- [ ] Node.js/Express 기초 애플리케이션 개발
- [ ] 환경 변수 사용법
- [ ] 기본 API 엔드포인트 구현

### Cloud Master 준비
- [ ] Docker Compose를 활용한 멀티 컨테이너 구성
- [ ] Nginx 리버스 프록시 설정
- [ ] 기본적인 웹 애플리케이션 아키텍처 이해

---

## 🚀 다음 단계

이 가이드를 완료했다면 Cloud Master 과정을 수강할 준비가 되었습니다!

### Cloud Master에서 학습할 내용
- **고급 Docker 기술**: 멀티스테이지 빌드, 최적화
- **GitHub Actions**: CI/CD 파이프라인 구축
- **클라우드 배포**: AWS ECS, GCP GKE 배포
- **자동화**: 완전 자동화된 배포 파이프라인

### 준비사항
- [ ] GitHub 계정 생성
- [ ] Docker Hub 계정 생성
- [ ] AWS/GCP 계정 준비 (Free Tier)
- [ ] 기본적인 Linux 명령어 숙지

---

## 💡 추가 학습 자료

- [Docker 공식 문서](https://docs.docker.com/)
- [Git 공식 문서](https://git-scm.com/doc)
- [Node.js 공식 문서](https://nodejs.org/docs/)
- [Express.js 공식 문서](https://expressjs.com/)
