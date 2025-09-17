
## 🎯 실습 목표

이 실습을 통해 다음을 달성할 수 있습니다:

- **이론과 실습의 결합**: 학습한 이론을 실제로 적용해보는 경험
- **문제해결 능력 향상**: 실습 중 발생하는 문제를 해결하는 능력 개발
- **실무 적용 능력**: 학습한 내용을 실제 업무에 적용할 수 있는 능력 향상
- **자신감 향상**: 성공적인 실습 완료를 통한 학습 자신감 증진

**💡 팁**: 실습 중 문제가 발생하면 문제해결 가이드를 참고하세요!

<div align="center">

## 🏠 최상위 네비게이션
[🏠 홈](/mcp_knowledge_base/index.md) | [📚 전체 커리큘럼](/mcp_knowledge_base/curriculum.md) | [🔗 학습 경로](/mcp_knowledge_base/cloud_container/learning-path.md)

## 📖 현재 위치
**Cloud Container** > **1일차** > **컨테이너 기초 실습 가이드**

## ⬅️ 이전/다음 네비게이션
[← 이전: Cloud Container 메인](/mcp_knowledge_base/cloud_container/README.md) | [다음: Cloud Container 1일차 →](/mcp_knowledge_base/cloud_container/textbook/Day1/README.md)

</div>

# 컨테이너 기초 실습 가이드

<div align="center">

[← 이전: Cloud Container 1일차 메인](/mcp_knowledge_base/cloud_master/README.md) | [📚 전체 커리큘럼](/mcp_knowledge_base/curriculum.md) | [🏠 학습 경로로 돌아가기](/mcp_knowledge_base/index.md) | [다음: Kubernetes 기초 실습 →](/mcp_knowledge_base/cloud_container/textbook/Day1/practice/kubernetes-basics.md) | [← 이전: Cloud Container 메인](/mcp_knowledge_base/cloud_master/README.md) | [📋 학습 경로](/mcp_knowledge_base/cloud_master/learning-path.md)

</div>

## 📋 개요

**목적**: Docker 컨테이너 기술의 기초부터 고급까지 실습
**범위**: 
- Docker 기본 명령어 및 이미지 관리
- Dockerfile 작성 및 최적화
- Docker Compose를 활용한 멀티 컨테이너 관리
- 컨테이너 레지스트리 활용

---

## 🐳 1단계: Docker 기초 실습

### 1.1 Docker 설치 및 확인

```bash
# Docker 설치 확인
docker --version
docker-compose --version

# Docker 데몬 상태 확인
docker info

# Hello World 테스트
docker run hello-world
```

### 1.2 기본 Docker 명령어

```bash
# 이미지 목록 확인
docker images

# 실행 중인 컨테이너 확인
docker ps

# 모든 컨테이너 확인 (중지된 것 포함)
docker ps -a

# 컨테이너 로그 확인
docker logs [컨테이너ID]

# 컨테이너 내부 접속
docker exec -it [컨테이너ID] /bin/bash
```

---

## 📦 2단계: Dockerfile 작성 및 최적화

### 2.1 기본 Dockerfile 작성

```dockerfile
# Node.js 애플리케이션용 Dockerfile
FROM node:18-alpine

# 작업 디렉토리 설정
WORKDIR /app

# 패키지 파일 복사
COPY package*.json ./

# 의존성 설치
RUN npm ci --only=production

# 애플리케이션 코드 복사
COPY . .

# 포트 노출
EXPOSE 3000

# 애플리케이션 실행
CMD ["npm", "start"]
```

### 2.2 멀티스테이지 빌드 (최적화)

```dockerfile
# 멀티스테이지 빌드로 이미지 크기 최적화
FROM node:18-alpine AS builder

WORKDIR /app
COPY package*.json ./
RUN npm ci

COPY . .
RUN npm run build

# 프로덕션 이미지
FROM node:18-alpine AS production

WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

COPY --from=builder /app/dist ./dist

EXPOSE 3000
CMD ["npm", "start"]
```

### 2.3 이미지 빌드 및 실행

```bash
# 이미지 빌드
docker build -t my-app:latest .

# 이미지 실행
docker run -d -p 3000:3000 --name my-app-container my-app:latest

# 이미지 태그 지정
docker tag my-app:latest my-app:v1.0.0
```

---

## 🔧 3단계: Docker Compose 실습

### 3.1 기본 docker-compose.yml

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
      - redis

  db:
    image: mysql:8.0
    environment:
      - MYSQL_ROOT_PASSWORD=rootpassword
      - MYSQL_DATABASE=myapp
      - MYSQL_USER=appuser
      - MYSQL_PASSWORD=apppassword
    volumes:
      - mysql_data:/var/lib/mysql
    ports:
      - "3306:3306"

  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"

volumes:
  mysql_data:
```

### 3.2 Docker Compose 명령어

```bash
# 서비스 시작
docker-compose up -d

# 서비스 중지
docker-compose down

# 로그 확인
docker-compose logs -f

# 특정 서비스 재시작
docker-compose restart web

# 볼륨까지 삭제
docker-compose down -v
```

---

## 🏗️ 4단계: 컨테이너 레지스트리 활용

### 4.1 Docker Hub 활용

```bash
# Docker Hub 로그인
docker login

# 이미지 태그 지정
docker tag my-app:latest username/my-app:latest

# 이미지 푸시
docker push username/my-app:latest

# 이미지 풀
docker pull username/my-app:latest
```

### 4.2 AWS ECR 활용

```bash
# ECR 로그인
aws ecr get-login-password --region ap-northeast-2 | docker login --username AWS --password-stdin [ACCOUNT_ID].dkr.ecr.ap-northeast-2.amazonaws.com

# ECR 리포지토리 생성
aws ecr create-repository --repository-name my-app

# 이미지 태그 지정
docker tag my-app:latest [ACCOUNT_ID].dkr.ecr.ap-northeast-2.amazonaws.com/my-app:latest

# 이미지 푸시
docker push [ACCOUNT_ID].dkr.ecr.ap-northeast-2.amazonaws.com/my-app:latest
```

### 4.3 GCP GCR 활용

```bash
# GCR 인증
gcloud auth configure-docker

# 이미지 태그 지정
docker tag my-app:latest gcr.io/[PROJECT_ID]/my-app:latest

# 이미지 푸시
docker push gcr.io/[PROJECT_ID]/my-app:latest
```

---

## 🧪 5단계: 실습 프로젝트

### 5.1 간단한 웹 애플리케이션

```javascript
// app.js
const express = require('express');
const app = express();
const port = process.env.PORT || 3000;

app.get('/', (req, res) => {
  res.json({
    message: 'Hello from Docker!',
    timestamp: new Date().toISOString(),
    environment: process.env.NODE_ENV || 'development'
  });
});

app.get('/health', (req, res) => {
  res.status(200).json({ status: 'healthy' });
});

app.listen(port, () => {
  console.log(`App running on port ${port}`);
});
```

### 5.2 package.json

```json
{
  "name": "container-demo",
  "version": "1.0.0",
  "main": "app.js",
  "scripts": {
    "start": "node app.js",
    "dev": "nodemon app.js"
  },
  "dependencies": {
    "express": "^4.18.2"
  },
  "devDependencies": {
    "nodemon": "^2.0.20"
  }
}
```

---

## ✅ 실습 체크리스트

- [ ] Docker 설치 및 기본 명령어 숙지
- [ ] Dockerfile 작성 및 이미지 빌드
- [ ] 멀티스테이지 빌드로 이미지 최적화
- [ ] Docker Compose로 멀티 컨테이너 관리
- [ ] 컨테이너 레지스트리에 이미지 푸시
- [ ] 간단한 웹 애플리케이션 컨테이너화

---

## 🎯 학습 포인트

### Docker 기초
- 컨테이너와 이미지의 개념 이해
- Dockerfile 작성 및 최적화 기법
- Docker Compose를 활용한 서비스 오케스트레이션

### 실무 적용
- 멀티스테이지 빌드로 이미지 크기 최적화
- 환경변수를 활용한 설정 관리
- 볼륨을 활용한 데이터 영속성
- 네트워크를 활용한 컨테이너 간 통신

---

## 💡 추가 학습 아이디어

1. **Docker 보안**: 비루트 사용자로 실행, 이미지 스캔
2. **성능 최적화**: 레이어 캐싱, .dockerignore 활용
3. **모니터링**: 컨테이너 로그 수집 및 분석
4. **CI/CD**: GitHub Actions와 Docker 통합
5. **Kubernetes**: 컨테이너 오케스트레이션


---

<div align="center">

## 🔗 관련 과정 및 네비게이션
[🏠 홈](/mcp_knowledge_base/index.md) | [📚 전체 커리큘럼](/mcp_knowledge_base/curriculum.md) | [🔗 학습 경로](/mcp_knowledge_base/cloud_container/learning-path.md)

## 📖 현재 위치
**Cloud Container** > **1일차** > **컨테이너 기초 실습 가이드**

## ⬅️ 이전/다음 네비게이션
[← 이전: Cloud Container 메인](/mcp_knowledge_base/cloud_container/README.md) | [다음: Cloud Container 1일차 →](/mcp_knowledge_base/cloud_container/textbook/Day1/README.md)

## 🔗 관련 과정
[Cloud Master 3일차](/mcp_knowledge_base/cloud_master/textbook/Day3/README.md) | [Cloud Basic 1일차](/mcp_knowledge_base/cloud_basic/textbook/Day1/README.md)

</div>