# My App - Docker 기반 웹 애플리케이션

<div align="center">

[← 이전: Cloud Master 2일차](../Day2/README) | [📚 전체 커리큘럼](../../../curriculum) | [다음: Actions Demo 프로젝트 →](../actions-demo/README)

</div>

## 🎯 프로젝트 개요

이 프로젝트는 **Docker를 활용한 웹 애플리케이션**의 기본 구조를 보여주는 데모 프로젝트입니다.

## 📁 프로젝트 구조

```
my-app/
├── README.md           # 이 파일
├── app.js             # 메인 애플리케이션 (MongoDB + Redis 연동)
├── app_v1.js          # 기본 버전 (단순 Express 서버)
├── package.json       # Node.js 의존성 관리
├── Dockerfile         # Docker 이미지 빌드 설정
└── docker-compose.yml # 다중 서비스 관리
```

## 🚀 빠른 시작

### 1. 기본 버전 실행 (app_v1.js)
```bash
# 의존성 설치
npm install

# 기본 서버 실행
node app_v1.js

# 브라우저에서 http://localhost:3000 접속
```

### 2. 고급 버전 실행 (app.js + Docker Compose)
```bash
# Docker Compose로 전체 스택 실행
docker-compose up -d

# 브라우저에서 http://localhost:3000 접속
# MongoDB: localhost:27017
# Redis: localhost:6379
```

### 3. Docker 이미지 빌드
```bash
# 이미지 빌드
docker build -t my-app .

# 컨테이너 실행
docker run -p 3000:3000 my-app
```

## 📋 주요 기능

### app_v1.js (기본 버전)
- **Express 서버**: 간단한 HTTP 서버
- **시간 표시**: 현재 시간을 ISO 형식으로 표시
- **기본 라우팅**: 루트 경로(/)에서 환영 메시지

### app.js (고급 버전)
- **Express 서버**: HTTP 서버
- **MongoDB 연동**: 사용자 수 조회
- **Redis 연동**: 방문자 수 카운터
- **에러 처리**: 데이터베이스 연결 실패 시 처리

## 🐳 Docker 설정

### Dockerfile
```dockerfile
FROM node:18
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
EXPOSE 3000
CMD ["npm", "start"]
```

### docker-compose.yml
- **web**: Node.js 애플리케이션
- **db**: MongoDB 데이터베이스
- **redis**: Redis 캐시 서버

## 🔧 개발 환경

### 필수 도구
- **Node.js**: 18.x 이상
- **Docker**: 20.x 이상
- **Docker Compose**: 2.x 이상

### 환경 변수
```bash
# MongoDB 연결 정보
MONGO_URL=mongodb://admin:secret@db:27017

# Redis 연결 정보
REDIS_URL=redis://redis:6379
```

## 📚 학습 목표

이 프로젝트를 통해 다음을 학습할 수 있습니다:

1. **Docker 기본 사용법**
   - Dockerfile 작성
   - 이미지 빌드 및 실행
   - 컨테이너 관리

2. **Docker Compose 활용**
   - 다중 서비스 관리
   - 서비스 간 네트워킹
   - 볼륨 마운트

3. **웹 애플리케이션 개발**
   - Express.js 기본 사용법
   - 데이터베이스 연동
   - 캐시 시스템 활용

## 🚀 다음 단계

이 프로젝트를 완료한 후 다음을 진행하세요:

1. **GitHub Actions 연동**: [Actions Demo 프로젝트](../actions-demo/README) 참고
2. **클라우드 배포**: [로드 밸런싱 가이드](../load-balancing-guide) 참고
3. **모니터링 설정**: [모니터링 가이드](../monitoring-guide) 참고

## 📞 지원

문제가 발생하면 다음을 확인하세요:

1. **Docker 실행 상태**: `docker info`
2. **포트 충돌**: 3000, 27017, 6379 포트 사용 확인
3. **의존성 설치**: `npm install` 실행
4. **로그 확인**: `docker-compose logs`

---

<div align="center">

[← 이전: Cloud Master 2일차](../Day2/README) | [📚 전체 커리큘럼](../../../curriculum) | [다음: Actions Demo 프로젝트 →](../actions-demo/README)

</div>
