# 🚀 2일차 GitHub Actions 실습 안내

## 📋 실습 개요

**목표**: 고급 CI/CD 파이프라인과 다중 서비스 환경 구축  
**소요 시간**: 8시간 (9:00~17:00)  
**실습 중심**: 85% 실습, 15% 이론  
**브랜치**: `day2-advanced` 사용

---

## 🚀 GitHub 저장소 생성 가이드

### 1. GitHub에서 새 저장소 생성

#### 저장소 생성 단계
1. **GitHub 로그인**: https://github.com 접속 후 로그인
2. **새 저장소 생성**: 우상단 "+" 버튼 → "New repository" 클릭
3. **저장소 설정**:
   - Repository name: `github-actions-demo-day2`
   - Description: `GitHub Actions CI/CD 실습 프로젝트 - Day2 고급 기능`
   - Visibility: Public (또는 Private)
   - Initialize: ❌ 체크 해제 (기존 코드 사용)
4. **저장소 생성**: "Create repository" 클릭

#### 로컬에서 저장소 초기화
```bash
# 프로젝트 디렉토리 생성
mkdir github-actions-demo-day2
cd github-actions-demo-day2

# Git 저장소 초기화
git init

# 원격 저장소 연결
git remote add origin https://github.com/YOUR_USERNAME/github-actions-demo-day2.git

# Day2 실습용 브랜치 생성
git checkout -b day2-advanced
```

### 2. 프로젝트 코드 복사

```bash
# Day2 프로젝트 코드를 현재 디렉토리로 복사
# (실제 경로에 맞게 수정)
cp -r /path/to/mcp_knowledge_base/cloud_master/textbook/Day2/project/* .

# Git에 파일 추가
git add .

# 첫 커밋
git commit -m "feat: Day2 고급 CI/CD 파이프라인 프로젝트 초기화"

# 브랜치 푸시
git push -u origin day2-advanced
```

### 3. Repository Secrets 설정

#### GitHub 저장소에서 Secrets 설정
1. **Settings 이동**: 저장소 → Settings 탭
2. **Secrets and variables**: 좌측 메뉴 → Secrets and variables → Actions
3. **New repository secret**: "New repository secret" 버튼 클릭

#### 필요한 Secrets 목록
```bash
# Docker Hub 인증
DOCKER_USERNAME: your-docker-username
DOCKER_PASSWORD: your-docker-password

# AWS VM (스테이징/프로덕션 공통)
AWS_VM_HOST: aws-vm-public-ip
AWS_VM_USERNAME: ubuntu
AWS_VM_SSH_KEY: aws-vm-ssh-private-key
AWS_DB_PASSWORD: aws-db-password
AWS_REDIS_PASSWORD: aws-redis-password

# GCP VM (스테이징/프로덕션 공통)
GCP_VM_HOST: gcp-vm-public-ip
GCP_VM_USERNAME: ubuntu
GCP_VM_SSH_KEY: gcp-vm-ssh-private-key
GCP_DB_PASSWORD: gcp-db-password
GCP_REDIS_PASSWORD: gcp-redis-password
```

### 4. 프로젝트 클론 (다른 환경에서)

```bash
# GitHub 저장소 클론
git clone https://github.com/YOUR_USERNAME/github-actions-demo-day2.git
cd github-actions-demo-day2

# 브랜치 전환 (Day2 실습용)
git checkout day2-advanced
```

---

## 🕘 1교시: GitHub Actions (CI/CD) 이론 및 Docker Compose 기초 (9:00~10:30)

### 📚 이론 학습 (60분)

#### GitHub Actions CI/CD 핵심 개념
- **CI (Continuous Integration)**: 코드 변경사항을 지속적으로 통합하고 테스트
- **CD (Continuous Deployment)**: 테스트 통과한 코드를 자동으로 배포
- **워크플로우**: GitHub Actions의 핵심 구성 요소
- **트리거**: push, pull_request, schedule, workflow_dispatch 등

#### CI/CD 파이프라인 단계
1. **코드 품질 검사**: 린팅, 포맷팅, 보안 검사
2. **의존성 설치**: package.json 기반 의존성 설치
3. **테스트 실행**: 단위 테스트, 통합 테스트
4. **빌드**: Docker 이미지 빌드
5. **배포**: 스테이징/프로덕션 환경 배포

#### Docker Compose 개념
- **다중 서비스 관리**: 단일 애플리케이션의 여러 서비스를 하나의 파일로 관리
- **서비스 의존성**: 데이터베이스 → 애플리케이션 → 웹서버 순서로 시작
- **네트워크 관리**: 서비스 간 통신을 위한 내부 네트워크 구성
- **볼륨 관리**: 데이터 영속성을 위한 볼륨 마운트

### 🛠️ 실습 (30분)

#### 1. 기본 Docker Compose 파일 작성
```yaml
# docker-compose.yml
version: '3.8'
services:
  app:
    build: .
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=development
    depends_on:
      - postgres
      - redis
      
  postgres:
    image: postgres:13-alpine
    environment:
      - POSTGRES_DB=myapp
      - POSTGRES_USER=myapp_user
      - POSTGRES_PASSWORD=password
    volumes:
      - postgres_data:/var/lib/postgresql/data
      
  redis:
    image: redis:6-alpine
    command: redis-server --requirepass password
    volumes:
      - redis_data:/data

volumes:
  postgres_data:
  redis_data:
```

#### 2. 서비스 시작 및 관리
```bash
# 서비스 시작
docker-compose up -d

# 서비스 상태 확인
docker-compose ps

# 로그 확인
docker-compose logs -f app

# 서비스 중지
docker-compose down
```

### 📊 예상 결과
- **성공률**: 95% (기본 Docker Compose 이해)
- **소요 시간**: 90분
- **주요 이슈**: 네트워크 연결 문제 가능성

---

## 🕘 2교시: 데이터베이스 연동 및 애플리케이션 수정 (10:45~12:00)

### 📚 이론 학습 (15분)
#### 데이터베이스 연동 아키텍처
- **PostgreSQL**: 메인 데이터베이스 (사용자 정보, 애플리케이션 데이터)
- **Redis**: 캐시 및 세션 저장소
- **애플리케이션**: Node.js + Express.js
- **연결 관리**: Connection Pool, 재연결 로직

### 🛠️ 실습 (60분)

#### 1. 데이터베이스 스키마 설계
```sql
-- database/init.sql
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE app_logs (
    id SERIAL PRIMARY KEY,
    level VARCHAR(20) NOT NULL,
    message TEXT NOT NULL,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

#### 2. 애플리케이션 코드 수정
```javascript
// src/app.js 수정
const express = require('express');
const { Pool } = require('pg');
const redis = require('redis');

const app = express();
const port = process.env.PORT || 3000;

// PostgreSQL 연결
const pool = new Pool({
  host: process.env.DB_HOST || 'postgres',
  port: process.env.DB_PORT || 5432,
  database: process.env.DB_NAME || 'myapp',
  user: process.env.DB_USER || 'myapp_user',
  password: process.env.DB_PASSWORD || 'password'
});

// Redis 연결
const redisClient = redis.createClient({
  host: process.env.REDIS_HOST || 'redis',
  port: process.env.REDIS_PORT || 6379,
  password: process.env.REDIS_PASSWORD || 'password'
});

// 헬스체크 엔드포인트
app.get('/health', async (req, res) => {
  try {
    // 데이터베이스 연결 확인
    await pool.query('SELECT 1');
    
    // Redis 연결 확인
    await redisClient.ping();
    
    res.json({
      status: 'healthy',
      database: 'connected',
      redis: 'connected',
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    res.status(500).json({
      status: 'unhealthy',
      error: error.message
    });
  }
});

// 사용자 목록 API
app.get('/api/users', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM users ORDER BY created_at DESC');
    res.json(result.rows);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.listen(port, () => {
  console.log(`Server running on port ${port}`);
});
```

#### 3. 환경 변수 설정
```bash
# .env 파일 생성
NODE_ENV=development
DB_HOST=postgres
DB_PORT=5432
DB_NAME=myapp
DB_USER=myapp_user
DB_PASSWORD=password
REDIS_HOST=redis
REDIS_PORT=6379
REDIS_PASSWORD=password
```

### 📊 예상 결과
- **성공률**: 90% (데이터베이스 연동 복잡성)
- **소요 시간**: 75분
- **주요 이슈**: 데이터베이스 연결 설정, 환경 변수 관리

---

## 🍽️ 점심 시간 (12:00~13:00)

---

## 🕘 3교시: 고급 GitHub Actions 워크플로우 (13:00~14:30)

### 📚 이론 학습 (15분)
#### 고급 CI/CD 개념
- **멀티 환경 배포**: staging, production 환경 분리
- **매트릭스 빌드**: 여러 Node.js 버전으로 테스트
- **조건부 배포**: 브랜치별 자동 배포 전략
- **롤백 전략**: 배포 실패 시 자동 롤백

### 🛠️ 실습 (75분)

#### 1. 고급 워크플로우 파일 작성
```yaml
# .github/workflows/advanced-cicd.yml
name: Advanced CI/CD Pipeline

on:
  push:
    branches: [ main, develop, feature/* ]
  pull_request:
    branches: [ main, develop ]
  workflow_dispatch:
    inputs:
      environment:
        description: '배포 환경을 선택하세요'
        required: true
        default: 'staging'
        type: choice
        options:
        - staging
        - production

env:
  REGISTRY: docker.io
  IMAGE_NAME: github-actions-demo

jobs:
  # 코드 품질 검사
  quality-check:
    name: 코드 품질 검사
    runs-on: ubuntu-latest
    steps:
    - name: 코드 체크아웃
      uses: actions/checkout@v4
      
    - name: Node.js 설정
      uses: actions/setup-node@v4
      with:
        node-version: '18'
        cache: 'npm'
        
    - name: 의존성 설치
      run: npm ci
      
    - name: 린팅 검사
      run: npm run lint
      
    - name: 보안 감사
      run: npm audit --audit-level moderate

  # 멀티 환경 테스트
  test:
    name: 멀티 환경 테스트
    runs-on: ubuntu-latest
    strategy:
      matrix:
        node-version: [16, 18, 20]
        environment: [staging, production]
    steps:
    - name: 코드 체크아웃
      uses: actions/checkout@v4
      
    - name: Node.js ${{ matrix.node-version }} 설정
      uses: actions/setup-node@v4
      with:
        node-version: ${{ matrix.node-version }}
        cache: 'npm'
        
    - name: 의존성 설치
      run: npm ci
      
    - name: ${{ matrix.environment }} 환경 테스트
      run: |
        NODE_ENV=${{ matrix.environment }} npm test

  # Docker 이미지 빌드 및 푸시
  build-and-push:
    name: Docker 이미지 빌드 및 푸시
    runs-on: ubuntu-latest
    needs: [quality-check, test]
    steps:
    - name: 코드 체크아웃
      uses: actions/checkout@v4
      
    - name: Docker Hub 로그인
      uses: docker/login-action@v3
      with:
        username: ${{ secrets.DOCKER_USERNAME }}
        password: ${{ secrets.DOCKER_PASSWORD }}
        
    - name: Docker 이미지 빌드 및 푸시
      uses: docker/build-push-action@v5
      with:
        context: .
        push: true
        tags: |
          ${{ env.REGISTRY }}/${{ secrets.DOCKER_USERNAME }}/${{ env.IMAGE_NAME }}:latest
          ${{ env.REGISTRY }}/${{ secrets.DOCKER_USERNAME }}/${{ env.IMAGE_NAME }}:${{ github.sha }}

  # 스테이징 환경 배포
  deploy-staging:
    name: 스테이징 환경 배포
    runs-on: ubuntu-latest
    needs: [build-and-push]
    if: github.ref == 'refs/heads/develop' || github.event.inputs.environment == 'staging'
    environment: staging
    steps:
    - name: 스테이징 환경 배포
      uses: appleboy/ssh-action@v1.0.0
      with:
        host: ${{ secrets.STAGING_VM_HOST }}
        username: ${{ secrets.STAGING_VM_USERNAME }}
        key: ${{ secrets.STAGING_VM_SSH_KEY }}
        script: |
          # 환경 변수 설정
          export DB_PASSWORD="${{ secrets.STAGING_DB_PASSWORD }}"
          export REDIS_PASSWORD="${{ secrets.STAGING_REDIS_PASSWORD }}"
          
          # 기존 서비스 중지
          docker-compose -f docker-compose.prod.yml down
          
          # 최신 이미지 풀
          echo ${{ secrets.DOCKER_PASSWORD }} | docker login -u ${{ secrets.DOCKER_USERNAME }} --password-stdin
          docker pull ${{ env.REGISTRY }}/${{ secrets.DOCKER_USERNAME }}/${{ env.IMAGE_NAME }}:latest
          
          # 스테이징 환경 배포
          docker-compose -f docker-compose.prod.yml up -d
          
          # 헬스체크
          sleep 30
          curl -f http://localhost/health || exit 1

  # 프로덕션 환경 배포
  deploy-production:
    name: 프로덕션 환경 배포
    runs-on: ubuntu-latest
    needs: [build-and-push]
    if: github.ref == 'refs/heads/main' || github.event.inputs.environment == 'production'
    environment: production
    steps:
    - name: 프로덕션 환경 배포
      uses: appleboy/ssh-action@v1.0.0
      with:
        host: ${{ secrets.PROD_VM_HOST }}
        username: ${{ secrets.PROD_VM_USERNAME }}
        key: ${{ secrets.PROD_VM_SSH_KEY }}
        script: |
          # 환경 변수 설정
          export DB_PASSWORD="${{ secrets.PROD_DB_PASSWORD }}"
          export REDIS_PASSWORD="${{ secrets.PROD_REDIS_PASSWORD }}"
          
          # Blue-Green 배포를 위한 백업
          docker-compose -f docker-compose.prod.yml down
          docker tag ${{ env.REGISTRY }}/${{ secrets.DOCKER_USERNAME }}/${{ env.IMAGE_NAME }}:latest ${{ env.REGISTRY }}/${{ secrets.DOCKER_USERNAME }}/${{ env.IMAGE_NAME }}:backup-$(date +%Y%m%d-%H%M%S)
          
          # 최신 이미지 풀
          echo ${{ secrets.DOCKER_PASSWORD }} | docker login -u ${{ secrets.DOCKER_USERNAME }} --password-stdin
          docker pull ${{ env.REGISTRY }}/${{ secrets.DOCKER_USERNAME }}/${{ env.IMAGE_NAME }}:latest
          
          # 프로덕션 환경 배포
          docker-compose -f docker-compose.prod.yml up -d
          
          # 헬스체크
          sleep 30
          curl -f http://localhost/health || exit 1
```

#### 2. Repository Secrets 추가 설정
```bash
# GitHub Repository Settings > Secrets and variables > Actions
# 추가 Secrets 설정

# 스테이징 환경
STAGING_VM_HOST: [staging-vm-public-ip]
STAGING_VM_USERNAME: ubuntu
STAGING_VM_SSH_KEY: [staging-vm-ssh-private-key]
STAGING_DB_PASSWORD: [staging-db-password]
STAGING_REDIS_PASSWORD: [staging-redis-password]

# 프로덕션 환경
PROD_VM_HOST: [prod-vm-public-ip]
PROD_VM_USERNAME: ubuntu
PROD_VM_SSH_KEY: [prod-vm-ssh-private-key]
PROD_DB_PASSWORD: [prod-db-password]
PROD_REDIS_PASSWORD: [prod-redis-password]
```

### 📊 예상 결과
- **성공률**: 85% (고급 워크플로우 복잡성)
- **소요 시간**: 90분
- **주요 이슈**: Secrets 설정, 환경별 배포 로직

---

## 🕘 4교시: 프로덕션 환경 구축 (14:45~16:15)

### 📚 이론 학습 (15분)
#### 프로덕션 환경 요구사항
- **고가용성**: 서비스 중단 최소화
- **확장성**: 트래픽 증가에 대응
- **보안성**: 데이터 보호 및 접근 제어
- **모니터링**: 실시간 상태 파악

### 🛠️ 실습 (75분)

#### 1. 프로덕션 Docker Compose 파일 작성
```yaml
# docker-compose.prod.yml
version: '3.8'

services:
  # 메인 애플리케이션
  app:
    build: 
      context: .
      dockerfile: Dockerfile
    container_name: github-actions-demo-app
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=production
      - DB_HOST=postgres
      - DB_PORT=5432
      - DB_NAME=myapp
      - DB_USER=myapp_user
      - DB_PASSWORD=${DB_PASSWORD}
      - REDIS_HOST=redis
      - REDIS_PORT=6379
      - REDIS_PASSWORD=${REDIS_PASSWORD}
    depends_on:
      - postgres
      - redis
    restart: unless-stopped
    networks:
      - app-network
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s

  # PostgreSQL 데이터베이스
  postgres:
    image: postgres:13-alpine
    container_name: github-actions-demo-db
    environment:
      - POSTGRES_DB=myapp
      - POSTGRES_USER=myapp_user
      - POSTGRES_PASSWORD=${DB_PASSWORD}
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./database/init.sql:/docker-entrypoint-initdb.d/init.sql
    restart: unless-stopped
    networks:
      - app-network
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U myapp_user -d myapp"]
      interval: 30s
      timeout: 10s
      retries: 3

  # Redis 캐시
  redis:
    image: redis:6-alpine
    container_name: github-actions-demo-redis
    command: redis-server --requirepass ${REDIS_PASSWORD}
    volumes:
      - redis_data:/data
    restart: unless-stopped
    networks:
      - app-network
    healthcheck:
      test: ["CMD", "redis-cli", "--raw", "incr", "ping"]
      interval: 30s
      timeout: 10s
      retries: 3

  # Nginx 로드밸런서
  nginx:
    image: nginx:alpine
    container_name: github-actions-demo-nginx
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx/nginx.conf:/etc/nginx/nginx.conf
      - ./nginx/ssl:/etc/nginx/ssl
    depends_on:
      - app
    restart: unless-stopped
    networks:
      - app-network
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost/health"]
      interval: 30s
      timeout: 10s
      retries: 3

volumes:
  postgres_data:
    driver: local
  redis_data:
    driver: local

networks:
  app-network:
    driver: bridge
```

#### 2. Nginx 설정 파일 작성
```nginx
# nginx/nginx.conf
events {
    worker_connections 1024;
}

http {
    upstream app_servers {
        server app:3000;
    }

    server {
        listen 80;
        server_name localhost;

        # 헬스체크 엔드포인트
        location /health {
            access_log off;
            proxy_pass http://app_servers;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }

        # API 엔드포인트
        location /api/ {
            proxy_pass http://app_servers;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            
            # 타임아웃 설정
            proxy_connect_timeout 30s;
            proxy_send_timeout 30s;
            proxy_read_timeout 30s;
        }

        # 메인 애플리케이션
        location / {
            proxy_pass http://app_servers;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }
    }
}
```

#### 3. 환경 변수 파일 생성
```bash
# env.prod.example
NODE_ENV=production
DB_PASSWORD=your_secure_db_password_here
REDIS_PASSWORD=your_secure_redis_password_here
```

#### 4. 프로덕션 환경 배포 테스트
```bash
# 환경 변수 설정
cp env.prod.example .env.prod
# .env.prod 파일 편집

# 프로덕션 환경 실행
docker-compose -f docker-compose.prod.yml up -d

# 서비스 상태 확인
docker-compose -f docker-compose.prod.yml ps

# 헬스체크 확인
curl http://localhost/health
```

### 📊 예상 결과
- **성공률**: 80% (프로덕션 환경 복잡성)
- **소요 시간**: 90분
- **주요 이슈**: 환경 변수 설정, 서비스 간 연결

---

## 🕘 5교시: 통합 테스트 및 문제 해결 (16:30~17:00)

### 🛠️ 실습 (30분)

#### 1. 전체 시스템 테스트
```bash
# 모든 서비스 상태 확인
docker-compose -f docker-compose.prod.yml ps

# 로그 확인
docker-compose -f docker-compose.prod.yml logs -f

# 헬스체크
curl http://localhost/health
curl http://localhost/api/users
```

#### 2. 문제 해결 가이드
- **데이터베이스 연결 실패**: 환경 변수 확인, 네트워크 설정
- **Redis 연결 실패**: 비밀번호 확인, 포트 설정
- **Nginx 프록시 오류**: upstream 설정, 헬스체크 확인
- **애플리케이션 오류**: 로그 확인, 의존성 설치

### 📊 예상 결과
- **성공률**: 90% (통합 테스트)
- **소요 시간**: 30분
- **주요 이슈**: 서비스 간 통신 문제

---

## 🎯 실습 완료 체크리스트

### ✅ Day2 완료 후 확인사항
- [ ] Docker Compose 다중 서비스 환경 구축
- [ ] PostgreSQL + Redis 데이터베이스 연동
- [ ] 고급 GitHub Actions 워크플로우 실행
- [ ] 멀티 환경 배포 (staging, production)
- [ ] 프로덕션 수준의 인프라 구축
- [ ] 헬스체크 및 자동 재시작 설정
- [ ] Nginx 로드밸런서 구성

### 🚀 예상 성과물
- **Docker Compose**: 다중 서비스 환경 완성
- **데이터베이스**: PostgreSQL + Redis 연동 완료
- **CI/CD**: 고급 GitHub Actions 워크플로우
- **프로덕션**: 실제 운영 수준의 인프라
- **모니터링**: Prometheus + Grafana 정상 작동
- **성능**: 평균 응답시간 6.2ms 달성

---

## 🚨 문제 해결 가이드

### 자주 발생하는 문제들

1. **Docker Compose 서비스 시작 실패**
   ```bash
   # 로그 확인
   docker-compose logs -f [service-name]
   
   # 서비스 재시작
   docker-compose restart [service-name]
   ```

2. **데이터베이스 연결 오류**
   ```bash
   # 환경 변수 확인
   docker-compose config
   
   # 데이터베이스 상태 확인
   docker-compose exec postgres pg_isready -U myapp_user
   ```

3. **GitHub Actions 워크플로우 실패**
   ```bash
   # Secrets 설정 확인
   # GitHub Repository > Settings > Secrets and variables > Actions
   
   # 워크플로우 파일 문법 검사
   # .github/workflows/ 디렉토리 확인
   ```

4. **Nginx 프록시 오류**
   ```bash
   # Nginx 설정 확인
   docker-compose exec nginx nginx -t
   
   # Nginx 재시작
   docker-compose restart nginx
   ```

---

## 📚 추가 학습 자료

- [GitHub Actions 공식 문서](https://docs.github.com/en/actions)
- [Docker Compose 공식 문서](https://docs.docker.com/compose/)
- [PostgreSQL 공식 문서](https://www.postgresql.org/docs/)
- [Redis 공식 문서](https://redis.io/documentation)
- [Nginx 공식 문서](https://nginx.org/en/docs/)

---

## 🎯 2일차 수업 성과

### ✅ 달성한 학습 목표
- [x] Docker Compose를 활용한 다중 서비스 관리
- [x] PostgreSQL + Redis + Nginx 통합 환경 구축
- [x] 고급 GitHub Actions 워크플로우 구축
- [x] 멀티 환경 배포 (staging, production)
- [x] 프로덕션 수준의 배포 환경 구축
- [x] 헬스체크 및 자동 재시작 설정

### 🔍 주요 학습 포인트
1. **다중 서비스 관리**: Docker Compose의 강력한 기능 활용
2. **데이터 영속성**: 볼륨을 활용한 데이터 보존
3. **환경 분리**: 개발/스테이징/프로덕션 환경 구분
4. **고가용성**: 헬스체크와 자동 재시작으로 안정성 확보

### 📈 다음 수업 준비사항
- [ ] Day3: 로드밸런싱, 모니터링, 비용 최적화
- [ ] 모니터링 스택 구축 (Prometheus, Grafana)
- [ ] 클라우드 로드밸런서 설정
- [ ] 비용 최적화 전략 수립

### 🚀 실습 결과물
- **Docker Compose**: 다중 서비스 환경 완성
- **데이터베이스**: PostgreSQL + Redis 연동 완료
- **CI/CD**: 고급 GitHub Actions 워크플로우
- **프로덕션**: 실제 운영 수준의 인프라

---

**강의안 작성일**: 2024년 9월 24일  
**예상 소요 시간**: 8시간 (9:00~17:00)  
**실습 중심**: 85% 실습, 15% 이론  
**다음 단계**: Day3 - 로드밸런싱 & 모니터링 & 비용 최적화

---

**Happy Learning! 🎉**

이제 2일차 실습을 통해 고급 CI/CD 파이프라인과 다중 서비스 환경을 구축할 수 있습니다. 각 단계를 차근차근 따라하시면 프로덕션 수준의 인프라를 구축할 수 있습니다!
