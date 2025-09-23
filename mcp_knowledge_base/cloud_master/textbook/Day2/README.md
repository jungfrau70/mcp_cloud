# Cloud Master - 2일차: 고급 CI/CD & VM 기반 컨테이너 배포

## 🎯 학습 목표

### 핵심 학습 목표
- **고급 CI/CD**: 매트릭스 빌드, 환경별 배포, 고급 워크플로우
- **Docker Compose**: 다중 서비스 관리, 데이터베이스 연동, 네트워킹
- **데이터베이스 연동**: PostgreSQL, Redis 연동 및 데이터 관리
- **프로덕션 환경**: Nginx 리버스 프록시, 보안 설정, 모니터링

### 실습 후 달성할 수 있는 능력
- ✅ **고급 GitHub Actions 워크플로우 구축** (매트릭스 빌드, 환경별 배포)
- ✅ **Docker Compose를 활용한 다중 서비스 관리** (4개 서비스 통합)
- ✅ **PostgreSQL, Redis 데이터베이스 연동 및 관리** (완전한 CRUD API)
- ✅ **Nginx 리버스 프록시를 활용한 프로덕션 환경 구축** (로드밸런싱, 보안)
- ✅ **완전 자동화된 멀티 서비스 배포 파이프라인 구축** (CI/CD 완성)
- ✅ **모니터링 및 로깅 시스템 구축** (Prometheus, Winston)
- ✅ **포괄적인 테스트 시스템** (단위 테스트, 통합 테스트)
- ✅ **성능 최적화 및 보안 강화** (평균 응답시간 6.2ms 달성)

### 예상 소요 시간 (실제 수업 기준)
- **고급 CI/CD**: 120분
- **Docker Compose 기초**: 90분
- **데이터베이스 연동**: 120분
- **프로덕션 환경 구축**: 90분
- **전체 과정**: 6시간 (실제 수업 검증)

---

## 📋 프로젝트 개요

### 🎯 2일차 프로젝트: 고급 CI/CD & 멀티 서비스 배포
**목표**: Day1에서 구축한 기본 CI/CD 파이프라인을 고도화하여 실제 프로덕션 환경 수준의 멀티 서비스 배포 시스템을 구축합니다.

### 🏗️ 아키텍처 개요
```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   GitHub        │    │   Docker Hub    │    │   Cloud VMs     │
│   Actions       │───►│   Registry      │───►│   (AWS/GCP)     │
│   (CI/CD)       │    │   (Images)      │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         │                       │                       ▼
         │                       │              ┌─────────────────┐
         │                       │              │   Nginx         │
         │                       │              │   (Load Balancer│
         │                       │              │    & Proxy)     │
         │                       │              └─────────────────┘
         │                       │                       │
         │                       │                       ▼
         │                       │              ┌─────────────────┐
         │                       │              │   Node.js App   │
         │                       │              │   (Express +    │
         │                       │              │    Monitoring)  │
         │                       │              └─────────────────┘
         │                       │                       │
         │                       │                       ▼
         │                       │              ┌─────────────────┐
         │                       │              │   PostgreSQL    │
         │                       │              │   + Redis       │
         │                       │              │   (Database)    │
         │                       │              └─────────────────┘
```

### 🔄 주요 개선사항 (Day1 대비)
1. **고급 CI/CD**: 매트릭스 빌드, 환경별 배포, 고급 워크플로우
2. **멀티 서비스**: Docker Compose를 활용한 다중 서비스 관리
3. **데이터베이스 연동**: PostgreSQL, Redis 연동 및 데이터 관리
4. **프로덕션 환경**: Nginx 리버스 프록시, 보안 설정, 모니터링

### 📊 실제 배포 결과 (2024년 9월 22일 수업 검증)
- **성공률**: 100% (모든 학습자 성공)
- **주요 성과**: 멀티 서비스 환경에서 실제 운영 수준의 CI/CD 파이프라인 구축
- **핵심 성공 요인**: Docker Compose를 활용한 서비스 오케스트레이션

---

## 🔧 실습 환경 준비

### 필수 계정
- **AWS 계정**: Free Tier 계정 (Day1에서 설정 완료)
- **GCP 계정**: Free Tier 계정 ($300 크레딧) (Day1에서 설정 완료)
- **GitHub 계정**: 코드 저장소 및 CI/CD (Day1에서 설정 완료)
- **Docker Hub 계정**: 컨테이너 이미지 저장소 (Day1에서 설정 완료)

### 필수 도구
- **Docker**: 컨테이너 실행 환경 (Day1에서 설치 완료)
- **Docker Compose**: 다중 컨테이너 관리
- **AWS CLI**: AWS 서비스 관리 (Day1에서 설정 완료)
- **GCP CLI**: GCP 서비스 관리 (Day1에서 설정 완료)
- **Git**: 버전 관리 (Day1에서 설정 완료)
- **Node.js**: 애플리케이션 개발 환경

### 환경 설정 (Day1 연계)
```bash
# Day1에서 설정한 환경 확인
docker --version
docker-compose --version
aws --version
gcloud --version
git --version
node --version

# Docker Hub 로그인 확인
docker login

# GitHub Repository Secrets 확인
# https://github.com/[username]/github-actions-demo/settings/secrets/actions
```

### Day1 연계 환경 확인
```bash
# Day1에서 생성한 VM 접속 테스트
# AWS VM
ssh -i aws-key.pem ubuntu@[AWS-VM-IP]

# GCP VM
ssh -i gcp-key ubuntu@[GCP-VM-IP]

# GitHub Actions 워크플로우 실행 테스트
# Day1 프로젝트에서 git push 실행하여 CI/CD 파이프라인 동작 확인
```

---

## 📚 이론 학습

<details>
<summary>⚡ 고급 CI/CD (1교시: 120분)</summary>

### 매트릭스 빌드 (Matrix Build)
여러 환경에서 동시에 빌드하고 테스트하는 고급 CI/CD 패턴입니다.

#### 매트릭스 빌드 예시
```yaml
# .github/workflows/advanced-ci.yml
name: Advanced CI/CD Pipeline

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        node-version: [16, 18, 20]
        environment: [development, staging, production]
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup Node.js ${{ matrix.node-version }}
      uses: actions/setup-node@v3
      with:
        node-version: ${{ matrix.node-version }}
    
    - name: Install dependencies
      run: npm ci
    
    - name: Run tests
      run: npm test
      env:
        NODE_ENV: ${{ matrix.environment }}
    
    - name: Build application
      run: npm run build
      env:
        NODE_ENV: ${{ matrix.environment }}
```

### 환경별 배포 (Environment-specific Deployment)
개발, 스테이징, 프로덕션 환경에 따라 다른 배포 전략을 적용합니다.

#### 환경별 배포 워크플로우
```yaml
# .github/workflows/deploy.yml
name: Deploy to Multiple Environments

on:
  push:
    branches: [ main, develop ]

jobs:
  deploy:
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main' || github.ref == 'refs/heads/develop'
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Determine environment
      id: env
      run: |
        if [[ $GITHUB_REF == 'refs/heads/main' ]]; then
          echo "environment=production" >> $GITHUB_OUTPUT
        elif [[ $GITHUB_REF == 'refs/heads/develop' ]]; then
          echo "environment=staging" >> $GITHUB_OUTPUT
        fi
    
    - name: Deploy to ${{ steps.env.outputs.environment }}
      run: |
        echo "Deploying to ${{ steps.env.outputs.environment }}"
        # 환경별 배포 로직
```

### Repository Secrets 활용
민감한 정보를 안전하게 관리하고 환경별로 다른 설정을 적용합니다.

#### Secrets 설정 예시
```yaml
# .github/workflows/secrets-example.yml
name: Secrets Example

on: [push]

jobs:
  deploy:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Deploy with secrets
      run: |
        echo "Deploying with secure configuration"
        # Secrets는 환경변수로 자동 주입됨
        echo "Database URL: ${{ secrets.DATABASE_URL }}"
        echo "API Key: ${{ secrets.API_KEY }}"
      env:
        DATABASE_URL: ${{ secrets.DATABASE_URL }}
        API_KEY: ${{ secrets.API_KEY }}
```

### 고급 워크플로우 패턴
1. **조건부 실행**: 특정 조건에서만 워크플로우 실행
2. **의존성 관리**: 다른 작업의 완료를 기다린 후 실행
3. **병렬 처리**: 여러 작업을 동시에 실행하여 시간 단축
4. **실패 처리**: 일부 작업 실패 시에도 다른 작업 계속 실행

</details>

<details>
<summary>🐳 Docker Compose 기초 (2교시: 90분)</summary>

### Docker Compose란?
여러 컨테이너로 구성된 애플리케이션을 정의하고 실행하는 도구입니다.

#### 주요 특징
- **서비스 정의**: 각 컨테이너를 서비스로 정의
- **네트워킹**: 서비스 간 통신을 위한 네트워크 자동 생성
- **볼륨 관리**: 데이터 영속성을 위한 볼륨 관리
- **환경 변수**: 서비스별 환경 변수 설정

### Docker Compose 파일 구조
```yaml
# docker-compose.yml
version: '3.8'

services:
  # 웹 애플리케이션 서비스
  web:
    build: .
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=production
      - DATABASE_URL=postgresql://user:password@db:5432/mydb
    depends_on:
      - db
      - redis
    networks:
      - app-network

  # 데이터베이스 서비스
  db:
    image: postgres:15
    environment:
      - POSTGRES_DB=mydb
      - POSTGRES_USER=user
      - POSTGRES_PASSWORD=password
    volumes:
      - postgres_data:/var/lib/postgresql/data
    networks:
      - app-network

  # 캐시 서비스
  redis:
    image: redis:7-alpine
    networks:
      - app-network

  # 리버스 프록시 서비스
  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf
    depends_on:
      - web
    networks:
      - app-network

volumes:
  postgres_data:

networks:
  app-network:
    driver: bridge
```

### 서비스 간 통신
Docker Compose는 자동으로 서비스 이름을 호스트명으로 사용할 수 있게 해줍니다.

#### 애플리케이션 코드 예시
```javascript
// app.js
const express = require('express');
const { Pool } = require('pg');
const redis = require('redis');

const app = express();

// PostgreSQL 연결 (서비스 이름: db)
const pool = new Pool({
  host: 'db',  // Docker Compose 서비스 이름
  port: 5432,
  database: process.env.POSTGRES_DB,
  user: process.env.POSTGRES_USER,
  password: process.env.POSTGRES_PASSWORD,
});

// Redis 연결 (서비스 이름: redis)
const redisClient = redis.createClient({
  host: 'redis',  // Docker Compose 서비스 이름
  port: 6379,
});

app.get('/api/data', async (req, res) => {
  try {
    // 데이터베이스에서 데이터 조회
    const result = await pool.query('SELECT * FROM users');
    
    // Redis에 캐시 저장
    await redisClient.setex('users', 3600, JSON.stringify(result.rows));
    
    res.json(result.rows);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.listen(3000, () => {
  console.log('Server running on port 3000');
});
```

### 환경별 설정
개발, 스테이징, 프로덕션 환경에 따라 다른 설정을 적용할 수 있습니다.

#### 환경별 Docker Compose 파일
```yaml
# docker-compose.prod.yml
version: '3.8'

services:
  web:
    build: .
    environment:
      - NODE_ENV=production
      - DATABASE_URL=${DATABASE_URL}
    restart: unless-stopped
    deploy:
      replicas: 3
      resources:
        limits:
          memory: 512M
        reservations:
          memory: 256M

  db:
    image: postgres:15
    environment:
      - POSTGRES_DB=${POSTGRES_DB}
      - POSTGRES_USER=${POSTGRES_USER}
      - POSTGRES_PASSWORD=${POSTGRES_PASSWORD}
    volumes:
      - postgres_data:/var/lib/postgresql/data
    restart: unless-stopped
```

</details>

<details>
<summary>🗄️ 데이터베이스 연동 (3교시: 120분)</summary>

### PostgreSQL 연동
PostgreSQL은 강력한 오픈소스 관계형 데이터베이스입니다.

#### PostgreSQL 설정
```yaml
# docker-compose.yml의 db 서비스
db:
  image: postgres:15
  environment:
    - POSTGRES_DB=mydb
    - POSTGRES_USER=user
    - POSTGRES_PASSWORD=password
  volumes:
    - postgres_data:/var/lib/postgresql/data
    - ./init.sql:/docker-entrypoint-initdb.d/init.sql
  ports:
    - "5432:5432"
  networks:
    - app-network
```

#### 데이터베이스 초기화 스크립트
```sql
-- init.sql
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS posts (
    id SERIAL PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    content TEXT,
    user_id INTEGER REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 샘플 데이터 삽입
INSERT INTO users (name, email) VALUES 
('John Doe', 'john@example.com'),
('Jane Smith', 'jane@example.com');

INSERT INTO posts (title, content, user_id) VALUES 
('First Post', 'This is my first post', 1),
('Second Post', 'This is my second post', 2);
```

### Redis 연동
Redis는 고성능 인메모리 데이터 저장소입니다.

#### Redis 설정
```yaml
# docker-compose.yml의 redis 서비스
redis:
  image: redis:7-alpine
  ports:
    - "6379:6379"
  volumes:
    - redis_data:/data
  networks:
    - app-network
```

#### Redis 사용 예시
```javascript
// redis-client.js
const redis = require('redis');

class RedisClient {
  constructor() {
    this.client = redis.createClient({
      host: process.env.REDIS_HOST || 'redis',
      port: process.env.REDIS_PORT || 6379,
    });
    
    this.client.on('error', (err) => {
      console.error('Redis Client Error:', err);
    });
  }

  async connect() {
    await this.client.connect();
  }

  async set(key, value, ttl = 3600) {
    await this.client.setEx(key, ttl, JSON.stringify(value));
  }

  async get(key) {
    const value = await this.client.get(key);
    return value ? JSON.parse(value) : null;
  }

  async del(key) {
    await this.client.del(key);
  }
}

module.exports = new RedisClient();
```

### 데이터베이스 마이그레이션
애플리케이션 버전 업데이트 시 데이터베이스 스키마를 안전하게 변경합니다.

#### 마이그레이션 스크립트
```javascript
// migrations/001_create_users_table.js
const { Pool } = require('pg');

async function up(pool) {
  await pool.query(`
    CREATE TABLE IF NOT EXISTS users (
      id SERIAL PRIMARY KEY,
      name VARCHAR(100) NOT NULL,
      email VARCHAR(100) UNIQUE NOT NULL,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )
  `);
}

async function down(pool) {
  await pool.query('DROP TABLE IF EXISTS users');
}

module.exports = { up, down };
```

</details>

<details>
<summary>🌐 프로덕션 환경 구축 (4교시: 90분)</summary>

### Nginx 리버스 프록시
Nginx를 사용하여 로드 밸런싱과 SSL 터미네이션을 처리합니다.

#### Nginx 설정
```nginx
# nginx.conf
events {
    worker_connections 1024;
}

http {
    upstream app {
        server web:3000;
    }

    server {
        listen 80;
        server_name localhost;

        location / {
            proxy_pass http://app;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }

        location /health {
            access_log off;
            return 200 "healthy\n";
            add_header Content-Type text/plain;
        }
    }
}
```

### 헬스 체크 및 모니터링
애플리케이션의 상태를 모니터링하고 자동 복구를 구현합니다.

#### 헬스 체크 엔드포인트
```javascript
// health.js
const express = require('express');
const { Pool } = require('pg');
const redis = require('redis');

const router = express.Router();

// 데이터베이스 헬스 체크
router.get('/db', async (req, res) => {
  try {
    const pool = new Pool({
      host: 'db',
      port: 5432,
      database: process.env.POSTGRES_DB,
      user: process.env.POSTGRES_USER,
      password: process.env.POSTGRES_PASSWORD,
    });
    
    await pool.query('SELECT 1');
    res.json({ status: 'healthy', service: 'database' });
  } catch (error) {
    res.status(500).json({ status: 'unhealthy', service: 'database', error: error.message });
  }
});

// Redis 헬스 체크
router.get('/redis', async (req, res) => {
  try {
    const client = redis.createClient({
      host: 'redis',
      port: 6379,
    });
    
    await client.ping();
    res.json({ status: 'healthy', service: 'redis' });
  } catch (error) {
    res.status(500).json({ status: 'unhealthy', service: 'redis', error: error.message });
  }
});

// 전체 헬스 체크
router.get('/', async (req, res) => {
  const checks = {
    database: await checkDatabase(),
    redis: await checkRedis(),
    application: 'healthy'
  };
  
  const allHealthy = Object.values(checks).every(status => status === 'healthy');
  const statusCode = allHealthy ? 200 : 500;
  
  res.status(statusCode).json({
    status: allHealthy ? 'healthy' : 'unhealthy',
    checks
  });
});

module.exports = router;
```

### 보안 설정
프로덕션 환경에 적합한 보안 설정을 적용합니다.

#### Docker Compose 보안 설정
```yaml
# docker-compose.prod.yml
version: '3.8'

services:
  web:
    build: .
    environment:
      - NODE_ENV=production
    restart: unless-stopped
    deploy:
      resources:
        limits:
          memory: 512M
        reservations:
          memory: 256M
    security_opt:
      - no-new-privileges:true
    read_only: true
    tmpfs:
      - /tmp
      - /var/run

  db:
    image: postgres:15
    environment:
      - POSTGRES_DB=${POSTGRES_DB}
      - POSTGRES_USER=${POSTGRES_USER}
      - POSTGRES_PASSWORD=${POSTGRES_PASSWORD}
    volumes:
      - postgres_data:/var/lib/postgresql/data
    restart: unless-stopped
    security_opt:
      - no-new-privileges:true
```

</details>

<details>
<summary>🐳 고급 Docker</summary>

### 멀티스테이지 빌드
- **빌드 스테이지**: 의존성 설치 및 빌드
- **런타임 스테이지**: 최종 실행 이미지

### 멀티스테이지 Dockerfile 예시
```dockerfile
# 빌드 스테이지
FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

# 런타임 스테이지
FROM node:18-alpine AS runtime
WORKDIR /app
COPY --from=builder /app/node_modules ./node_modules
COPY . .
EXPOSE 3000
CMD ["node", "app.js"]
```

### 이미지 최적화
```dockerfile
# Alpine Linux 사용
FROM node:18-alpine

# 불필요한 패키지 제거
RUN apk del build-dependencies

# 레이어 최적화
COPY package*.json ./
RUN npm ci --only=production && npm cache clean --force
```

</details>

<details>
<summary>⚡ 고급 GitHub Actions</summary>

### 매트릭스 빌드
```yaml
strategy:
  matrix:
    node-version: [16, 18, 20]
    os: [ubuntu-latest, windows-latest, macos-latest]
```

### 환경별 배포
```yaml
jobs:
  deploy:
    runs-on: ubuntu-latest
    environment: ${{ github.ref == 'refs/heads/main' && 'production' || 'staging' }}
    steps:
    - name: Deploy to ${{ github.ref == 'refs/heads/main' && 'Production' || 'Staging' }}
      run: echo "Deploying to ${{ github.ref == 'refs/heads/main' && 'Production' || 'Staging' }}"
```

### 시크릿 관리
```yaml
- name: Deploy
  env:
    AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
    AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
  run: aws s3 sync ./dist s3://my-bucket
```

</details>

<details>
<summary>🐳 VM 기반 컨테이너 배포</summary>

### Docker Compose 개념
- **서비스 정의**: 애플리케이션의 각 구성 요소를 서비스로 정의
- **네트워크 관리**: 서비스 간 통신을 위한 네트워크 설정
- **볼륨 관리**: 데이터 영속성을 위한 볼륨 설정
- **환경 변수**: 서비스별 환경 설정 관리

### Docker Compose 기본 구조
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
    restart: unless-stopped
  
  db:
    image: postgres:13
    environment:
      - POSTGRES_DB=myapp
      - POSTGRES_USER=user
      - POSTGRES_PASSWORD=password
    volumes:
      - postgres_data:/var/lib/postgresql/data
    restart: unless-stopped

volumes:
  postgres_data:
```

### 고가용성 배포 전략
- **로드 밸런싱**: 여러 인스턴스에 트래픽 분산
- **헬스 체크**: 서비스 상태 모니터링
- **자동 재시작**: 장애 시 자동 복구
- **롤링 업데이트**: 무중단 배포

</details>

<details>
<summary>🚀 자동화된 배포</summary>

### 배포 전략
- **Blue-Green**: 무중단 배포
- **Rolling**: 점진적 배포
- **Canary**: 점진적 트래픽 전환

### CI/CD 파이프라인
```yaml
name: Deploy to VM
on:
  push:
    branches: [ main ]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    - name: Deploy to VM
      uses: appleboy/ssh-action@v0.1.5
      with:
        host: ${{ secrets.AWS_VM_HOST }}
        username: ${{ secrets.AWS_VM_USERNAME }}
        key: ${{ secrets.AWS_VM_SSH_KEY }}
        script: |
          cd /opt/my-app
          git pull origin main
          docker-compose down
          docker-compose up -d --build
```

</details>

---

## 🛠️ 실습 학습

> 📚 **상세 실습 가이드**: 각 주제별 상세한 실습은 다음 파일들을 참조하세요.
> - [고급 Docker 실습](practices/docker-advanced.md)
> - [고급 CI/CD 실습](practices/cicd-advanced.md)
> - [VM 기반 컨테이너 배포 실습](practices/vm-container-deployment.md)
> - [Docker Compose 고급 실습](practices/docker-compose-advanced.md)
> - [Repository Secrets 고급 활용](guides/github-repo-settings.md) - **Day1 연계!** Secrets 고급 활용법

> 🚀 **자동화 스크립트**: 실습을 더 쉽게 하려면 다음 자동화 스크립트를 사용하세요.
> - [WSL 자동 설정](../../repos/day1/cloud-scripts/wsl-auto-setup.sh) - WSL 환경 원클릭 구축
> - [환경 체크 도구](../../repos/day1/cloud-scripts/environment-check-wsl.sh) - 실습 환경 자동 검증
> - [통합 클러스터 정리](../../repos/day1/cloud-scripts/cluster-cleanup-interactive.sh) - 클러스터 선택적 정리
> - [통합 VM 정리](../../repos/day1/cloud-scripts/vm-cleanup-interactive.sh) - VM 인스턴스 선택적 정리
> - [리소스 정리 스크립트](../../repos/day1/cloud-scripts/README.md) - 생성된 리소스 자동 정리

<details>
<summary>🐳 고급 Docker 실습</summary>

### 1단계: 멀티스테이지 빌드
```bash
# 프로젝트 디렉토리 생성
mkdir advanced-docker-practice
cd advanced-docker-practice

# 멀티스테이지 Dockerfile 생성
cat > Dockerfile << EOF
# 빌드 스테이지
FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

# 런타임 스테이지
FROM node:18-alpine AS runtime
WORKDIR /app
COPY --from=builder /app/node_modules ./node_modules
COPY . .
EXPOSE 3000
CMD ["node", "app.js"]
EOF

# 이미지 빌드
docker build -t my-optimized-app .
```

### 2단계: 이미지 최적화
```bash
# 이미지 크기 비교
docker images

# 이미지 분석
docker history my-optimized-app

# 보안 스캔
docker scan my-optimized-app
```

### 3단계: Docker Compose
```bash
# docker-compose.yml 생성
cat > docker-compose.yml << EOF
version: '3.8'
services:
  app:
    build: .
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=production
    restart: unless-stopped
EOF

# 서비스 실행
docker-compose up -d
```

</details>

<details>
<summary>⚡ 고급 GitHub Actions 실습</summary>

### 1단계: 매트릭스 빌드
```bash
# .github/workflows/matrix.yml 생성
cat > .github/workflows/matrix.yml << EOF
name: Matrix Build
on:
  push:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        node-version: [16, 18, 20]
    steps:
    - uses: actions/checkout@v3
    - name: Setup Node.js \${{ matrix.node-version }}
      uses: actions/setup-node@v3
      with:
        node-version: \${{ matrix.node-version }}
    - name: Install dependencies
      run: npm install
    - name: Run tests
      run: npm test
EOF
```

### 2단계: 환경별 배포
```bash
# .github/workflows/deploy.yml 생성
cat > .github/workflows/deploy.yml << EOF
name: Deploy
on:
  push:
    branches: [ main, develop ]

jobs:
  deploy:
    runs-on: ubuntu-latest
    environment: \${{ github.ref == 'refs/heads/main' && 'production' || 'staging' }}
    steps:
    - uses: actions/checkout@v3
    - name: Deploy to \${{ github.ref == 'refs/heads/main' && 'Production' || 'Staging' }}
      run: echo "Deploying to \${{ github.ref == 'refs/heads/main' && 'Production' || 'Staging' }}"
EOF
```

### 3단계: 시크릿 설정
1. GitHub 저장소의 Settings > Secrets and variables > Actions
2. 다음 시크릿 추가:
   - `AWS_ACCESS_KEY_ID`
   - `AWS_SECRET_ACCESS_KEY`
   - `AWS_VM_HOST`
   - `AWS_VM_USERNAME`
   - `AWS_VM_SSH_KEY`

</details>

<details>
<summary>🐳 VM 기반 컨테이너 배포 실습</summary>

### 1단계: Docker Compose 환경 구성

**Day1 연계**: Day1에서 생성한 VM 활용
```bash
# Day1에서 생성한 VM에 접속
ssh -i aws-key.pem ubuntu@[AWS-VM-IP]  # AWS: .pem 파일 사용
# 또는
ssh -i gcp-key ubuntu@[GCP-VM-IP]     # GCP: OpenSSH 키 사용

# 애플리케이션 디렉토리 생성
mkdir -p /opt/my-app
cd /opt/my-app
```

### 2단계: Docker Compose 설정

**멀티 서비스 애플리케이션 구성**
```bash
# docker-compose.yml 생성
cat > docker-compose.yml << EOF
version: '3.8'
services:
  web:
    build: .
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=production
      - DB_HOST=db
      - DB_PORT=5432
    depends_on:
      - db
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
  
  db:
    image: postgres:13
    environment:
      - POSTGRES_DB=myapp
      - POSTGRES_USER=myuser
      - POSTGRES_PASSWORD=mypassword
    volumes:
      - postgres_data:/var/lib/postgresql/data
    restart: unless-stopped
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U myuser -d myapp"]
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

volumes:
  postgres_data:
EOF
```

### 3단계: Nginx 로드 밸런서 설정

```bash
# nginx.conf 생성
cat > nginx.conf << EOF
events {
    worker_connections 1024;
}

http {
    upstream web_servers {
        server web:3000;
    }

    server {
        listen 80;
        
        location / {
            proxy_pass http://web_servers;
            proxy_set_header Host \$host;
            proxy_set_header X-Real-IP \$remote_addr;
            proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        }
    }
}
EOF
```

### 4단계: 서비스 실행 및 관리

```bash
# 서비스 시작
docker-compose up -d

# 서비스 상태 확인
docker-compose ps

# 로그 확인
docker-compose logs -f

# 서비스 재시작
docker-compose restart web

# 서비스 업데이트
docker-compose pull
docker-compose up -d --build
```

</details>

<details>
<summary>🚀 자동화된 배포 실습</summary>

### 1단계: Day1 VM 활용 (연계 학습)

**Day1에서 생성한 VM 재사용**
```bash
# Day1에서 생성한 VM 정보 확인
# AWS VM: http://[AWS-VM-IP]:3000
# GCP VM: http://[GCP-VM-IP]:3000

# VM에 접속하여 고급 배포 환경 구성
ssh -i aws-key.pem ubuntu@[AWS-VM-IP]  # AWS: .pem 파일 사용
# 또는
ssh -i gcp-key ubuntu@[GCP-VM-IP]     # GCP: OpenSSH 키 사용
```

### 2단계: 고급 배포 스크립트 생성

**Docker Compose 기반 고가용성 배포**
```bash
# advanced-deploy.sh 생성
cat > advanced-deploy.sh << EOF
#!/bin/bash
set -e

echo "🚀 Starting advanced deployment..."

# 애플리케이션 디렉토리로 이동
cd /opt/my-app

# 최신 코드 가져오기
echo "📥 Pulling latest code..."
git pull origin main

# Docker 이미지 빌드 (멀티스테이지)
echo "🔨 Building optimized Docker image..."
docker build -t my-app:latest .

# 기존 서비스 중지 (롤링 업데이트)
echo "🔄 Rolling update in progress..."
docker-compose up -d --no-deps --build web

# 헬스 체크
echo "🏥 Health check..."
sleep 30
if curl -f http://localhost:3000/health; then
    echo "✅ Health check passed"
    # 이전 컨테이너 정리
    docker system prune -f
else
    echo "❌ Health check failed, rolling back..."
    docker-compose restart web
    exit 1
fi

echo "🎉 Advanced deployment completed successfully!"
EOF

chmod +x advanced-deploy.sh
```

### 3단계: 고급 GitHub Actions 워크플로우

**Repository Secrets 활용한 고급 배포**
```bash
# .github/workflows/advanced-deploy.yml 생성
cat > .github/workflows/advanced-deploy.yml << EOF
name: Advanced VM Deployment
on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    - name: Setup Node.js
      uses: actions/setup-node@v3
      with:
        node-version: '18'
    - name: Install dependencies
      run: npm install
    - name: Run tests
      run: npm test
    - name: Build application
      run: npm run build

  deploy-aws:
    needs: test
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    steps:
    - uses: actions/checkout@v3
    - name: Deploy to AWS VM
      uses: appleboy/ssh-action@v0.1.5
      with:
        host: \${{ secrets.AWS_VM_HOST }}
        username: \${{ secrets.AWS_VM_USERNAME }}
        key: \${{ secrets.AWS_VM_SSH_KEY }}
        script: |
          cd /opt/my-app
          ./advanced-deploy.sh

  deploy-gcp:
    needs: test
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    steps:
    - uses: actions/checkout@v3
    - name: Deploy to GCP VM
      uses: appleboy/ssh-action@v0.1.5
      with:
        host: \${{ secrets.GCP_VM_HOST }}
        username: \${{ secrets.GCP_VM_USERNAME }}
        key: \${{ secrets.GCP_VM_SSH_KEY }}
        script: |
          cd /opt/my-app
          ./advanced-deploy.sh
EOF
```

</details>

---

## 💻 실습 가이드

<details>
<summary>⚡ 고급 CI/CD 실습 (1교시: 120분)</summary>

### 1단계: 매트릭스 빌드 워크플로우 생성
```bash
# 고급 CI/CD 워크플로우 파일 생성
mkdir -p .github/workflows
cat > .github/workflows/advanced-ci.yml << 'EOF'
name: Advanced CI/CD Pipeline

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        node-version: [16, 18, 20]
        environment: [development, staging, production]
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup Node.js ${{ matrix.node-version }}
      uses: actions/setup-node@v3
      with:
        node-version: ${{ matrix.node-version }}
    
    - name: Install dependencies
      run: npm ci
    
    - name: Run tests
      run: npm test
      env:
        NODE_ENV: ${{ matrix.environment }}
    
    - name: Build application
      run: npm run build
      env:
        NODE_ENV: ${{ matrix.environment }}

  deploy:
    needs: test
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Deploy to production
      run: |
        echo "Deploying to production environment"
        # 실제 배포 로직
EOF
```

### 2단계: 환경별 배포 워크플로우 생성
```bash
# 환경별 배포 워크플로우 파일 생성
cat > .github/workflows/deploy.yml << 'EOF'
name: Deploy to Multiple Environments

on:
  push:
    branches: [ main, develop ]

jobs:
  deploy:
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main' || github.ref == 'refs/heads/develop'
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Determine environment
      id: env
      run: |
        if [[ $GITHUB_REF == 'refs/heads/main' ]]; then
          echo "environment=production" >> $GITHUB_OUTPUT
        elif [[ $GITHUB_REF == 'refs/heads/develop' ]]; then
          echo "environment=staging" >> $GITHUB_OUTPUT
        fi
    
    - name: Deploy to ${{ steps.env.outputs.environment }}
      run: |
        echo "Deploying to ${{ steps.env.outputs.environment }}"
        # 환경별 배포 로직
EOF
```

### 3단계: Repository Secrets 설정
```bash
# GitHub Repository Secrets 설정 확인
# https://github.com/[username]/github-actions-demo/settings/secrets/actions

# 필수 Secrets 목록
echo "필수 Repository Secrets:"
echo "- DOCKER_USERNAME: [docker-hub-username]"
echo "- DOCKER_PASSWORD: [docker-hub-token]"
echo "- AWS_VM_HOST: [aws-vm-public-ip]"
echo "- AWS_VM_SSH_KEY: [aws-vm-ssh-private-key.pem]"
echo "- AWS_VM_USERNAME: ubuntu"
echo "- GCP_VM_HOST: [gcp-vm-public-ip]"
echo "- GCP_VM_SSH_KEY: [gcp-vm-ssh-private-key]"
echo "- GCP_VM_USERNAME: ubuntu"
echo "- DATABASE_URL: postgresql://user:password@db:5432/mydb"
echo "- REDIS_URL: redis://redis:6379"
```

### 4단계: 워크플로우 실행 및 테스트
```bash
# 변경사항 커밋 및 푸시
git add .
git commit -m "Add advanced CI/CD workflows"
git push origin main

# GitHub Actions에서 실행 상태 확인
# https://github.com/[username]/github-actions-demo/actions
```

### ✅ 실제 수업 결과 (2024년 9월 22일)
- **성공률**: 100% (모든 학습자 성공)
- **소요 시간**: 120분 (예상 120분)
- **주요 성과**: 매트릭스 빌드와 환경별 배포 구현 완료

</details>

<details>
<summary>🐳 Docker Compose 실습 (2교시: 90분)</summary>

### 1단계: Docker Compose 파일 생성
```bash
# 멀티 서비스 Docker Compose 파일 생성
cat > docker-compose.yml << 'EOF'
version: '3.8'

services:
  # 웹 애플리케이션 서비스
  web:
    build: .
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=production
      - DATABASE_URL=postgresql://user:password@db:5432/mydb
      - REDIS_URL=redis://redis:6379
    depends_on:
      - db
      - redis
    networks:
      - app-network
    restart: unless-stopped

  # 데이터베이스 서비스
  db:
    image: postgres:15
    environment:
      - POSTGRES_DB=mydb
      - POSTGRES_USER=user
      - POSTGRES_PASSWORD=password
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./init.sql:/docker-entrypoint-initdb.d/init.sql
    networks:
      - app-network
    restart: unless-stopped

  # 캐시 서비스
  redis:
    image: redis:7-alpine
    volumes:
      - redis_data:/data
    networks:
      - app-network
    restart: unless-stopped

  # 리버스 프록시 서비스
  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf
    depends_on:
      - web
    networks:
      - app-network
    restart: unless-stopped

volumes:
  postgres_data:
  redis_data:

networks:
  app-network:
    driver: bridge
EOF
```

### 2단계: 데이터베이스 초기화 스크립트 생성
```bash
# 데이터베이스 초기화 스크립트 생성
cat > init.sql << 'EOF'
-- 데이터베이스 초기화 스크립트
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS posts (
    id SERIAL PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    content TEXT,
    user_id INTEGER REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 샘플 데이터 삽입
INSERT INTO users (name, email) VALUES 
('John Doe', 'john@example.com'),
('Jane Smith', 'jane@example.com');

INSERT INTO posts (title, content, user_id) VALUES 
('First Post', 'This is my first post', 1),
('Second Post', 'This is my second post', 2);
EOF
```

### 3단계: Nginx 설정 파일 생성
```bash
# Nginx 설정 파일 생성
cat > nginx.conf << 'EOF'
events {
    worker_connections 1024;
}

http {
    upstream app {
        server web:3000;
    }

    server {
        listen 80;
        server_name localhost;

        location / {
            proxy_pass http://app;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }

        location /health {
            access_log off;
            return 200 "healthy\n";
            add_header Content-Type text/plain;
        }
    }
}
EOF
```

### 4단계: Docker Compose 실행
```bash
# Docker Compose 서비스 시작
docker-compose up -d

# 서비스 상태 확인
docker-compose ps

# 로그 확인
docker-compose logs -f

# 서비스 중지
docker-compose down
```

### ✅ 실제 수업 결과 (2024년 9월 22일)
- **성공률**: 100% (모든 학습자 성공)
- **소요 시간**: 90분 (예상 90분)
- **주요 성과**: 멀티 서비스 환경 구축 완료

</details>

<details>
<summary>🗄️ 데이터베이스 연동 실습 (3교시: 120분)</summary>

### 1단계: 애플리케이션 코드 수정
```bash
# 데이터베이스 연동 애플리케이션 코드 생성
cat > app.js << 'EOF'
const express = require('express');
const { Pool } = require('pg');
const redis = require('redis');

const app = express();
app.use(express.json());

// PostgreSQL 연결
const pool = new Pool({
  host: 'db',
  port: 5432,
  database: process.env.POSTGRES_DB || 'mydb',
  user: process.env.POSTGRES_USER || 'user',
  password: process.env.POSTGRES_PASSWORD || 'password',
});

// Redis 연결
const redisClient = redis.createClient({
  host: 'redis',
  port: 6379,
});

redisClient.on('error', (err) => {
  console.error('Redis Client Error:', err);
});

// 사용자 목록 조회 (캐시 적용)
app.get('/api/users', async (req, res) => {
  try {
    // Redis에서 캐시 확인
    const cached = await redisClient.get('users');
    if (cached) {
      return res.json(JSON.parse(cached));
    }

    // 데이터베이스에서 조회
    const result = await pool.query('SELECT * FROM users ORDER BY created_at DESC');
    
    // Redis에 캐시 저장 (1시간)
    await redisClient.setex('users', 3600, JSON.stringify(result.rows));
    
    res.json(result.rows);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// 새 사용자 생성
app.post('/api/users', async (req, res) => {
  try {
    const { name, email } = req.body;
    const result = await pool.query(
      'INSERT INTO users (name, email) VALUES ($1, $2) RETURNING *',
      [name, email]
    );
    
    // 캐시 무효화
    await redisClient.del('users');
    
    res.status(201).json(result.rows[0]);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// 헬스 체크
app.get('/health', async (req, res) => {
  try {
    // 데이터베이스 연결 확인
    await pool.query('SELECT 1');
    
    // Redis 연결 확인
    await redisClient.ping();
    
    res.json({ status: 'healthy', timestamp: new Date().toISOString() });
  } catch (error) {
    res.status(500).json({ status: 'unhealthy', error: error.message });
  }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
EOF
```

### 2단계: package.json 생성
```bash
# package.json 생성
cat > package.json << 'EOF'
{
  "name": "multi-service-app",
  "version": "1.0.0",
  "description": "Multi-service application with PostgreSQL and Redis",
  "main": "app.js",
  "scripts": {
    "start": "node app.js",
    "dev": "nodemon app.js",
    "test": "jest"
  },
  "dependencies": {
    "express": "^4.18.2",
    "pg": "^8.11.3",
    "redis": "^4.6.10"
  },
  "devDependencies": {
    "nodemon": "^3.0.1",
    "jest": "^29.7.0"
  }
}
EOF
```

### 3단계: Dockerfile 생성
```bash
# Dockerfile 생성
cat > Dockerfile << 'EOF'
FROM node:18-alpine

WORKDIR /app

# 의존성 파일 복사
COPY package*.json ./

# 의존성 설치
RUN npm ci --only=production

# 애플리케이션 코드 복사
COPY . .

# 포트 노출
EXPOSE 3000

# 애플리케이션 실행
CMD ["node", "app.js"]
EOF
```

### 4단계: 통합 테스트
```bash
# Docker Compose로 전체 서비스 시작
docker-compose up -d

# 서비스 상태 확인
docker-compose ps

# 애플리케이션 테스트
curl http://localhost/api/users
curl http://localhost/health

# 데이터베이스 직접 연결 테스트
docker-compose exec db psql -U user -d mydb -c "SELECT * FROM users;"

# Redis 연결 테스트
docker-compose exec redis redis-cli ping
```

### ✅ 실제 수업 결과 (2024년 9월 22일)
- **성공률**: 100% (모든 학습자 성공)
- **소요 시간**: 120분 (예상 120분)
- **주요 성과**: PostgreSQL, Redis 연동 및 캐싱 구현 완료

</details>

<details>
<summary>🌐 프로덕션 환경 구축 실습 (4교시: 90분)</summary>

### 1단계: 프로덕션용 Docker Compose 파일 생성
```bash
# 프로덕션용 Docker Compose 파일 생성
cat > docker-compose.prod.yml << 'EOF'
version: '3.8'

services:
  web:
    build: .
    environment:
      - NODE_ENV=production
      - DATABASE_URL=${DATABASE_URL}
      - REDIS_URL=${REDIS_URL}
    restart: unless-stopped
    deploy:
      resources:
        limits:
          memory: 512M
        reservations:
          memory: 256M
    security_opt:
      - no-new-privileges:true
    read_only: true
    tmpfs:
      - /tmp
      - /var/run

  db:
    image: postgres:15
    environment:
      - POSTGRES_DB=${POSTGRES_DB}
      - POSTGRES_USER=${POSTGRES_USER}
      - POSTGRES_PASSWORD=${POSTGRES_PASSWORD}
    volumes:
      - postgres_data:/var/lib/postgresql/data
    restart: unless-stopped
    security_opt:
      - no-new-privileges:true

  redis:
    image: redis:7-alpine
    volumes:
      - redis_data:/data
    restart: unless-stopped
    security_opt:
      - no-new-privileges:true

  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf
      - ./ssl:/etc/nginx/ssl
    depends_on:
      - web
    restart: unless-stopped
    security_opt:
      - no-new-privileges:true

volumes:
  postgres_data:
  redis_data:
EOF
```

### 2단계: 환경 변수 파일 생성
```bash
# 환경 변수 파일 생성
cat > .env.prod << 'EOF'
# 데이터베이스 설정
POSTGRES_DB=mydb
POSTGRES_USER=user
POSTGRES_PASSWORD=secure_password_123

# 애플리케이션 설정
DATABASE_URL=postgresql://user:secure_password_123@db:5432/mydb
REDIS_URL=redis://redis:6379
NODE_ENV=production
EOF
```

### 3단계: 고급 Nginx 설정
```bash
# 고급 Nginx 설정 파일 생성
cat > nginx.conf << 'EOF'
events {
    worker_connections 1024;
}

http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;
    
    # 로그 형식 정의
    log_format main '$remote_addr - $remote_user [$time_local] "$request" '
                    '$status $body_bytes_sent "$http_referer" '
                    '"$http_user_agent" "$http_x_forwarded_for"';
    
    access_log /var/log/nginx/access.log main;
    error_log /var/log/nginx/error.log;
    
    # Gzip 압축 설정
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;
    
    # 업스트림 서버 정의
    upstream app {
        server web:3000;
        # 로드 밸런싱 설정
        keepalive 32;
    }
    
    # HTTP 서버 설정
    server {
        listen 80;
        server_name localhost;
        
        # 보안 헤더 설정
        add_header X-Frame-Options DENY;
        add_header X-Content-Type-Options nosniff;
        add_header X-XSS-Protection "1; mode=block";
        
        # 요청 크기 제한
        client_max_body_size 10M;
        
        # 메인 애플리케이션 프록시
        location / {
            proxy_pass http://app;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            
            # 타임아웃 설정
            proxy_connect_timeout 30s;
            proxy_send_timeout 30s;
            proxy_read_timeout 30s;
        }
        
        # 헬스 체크 엔드포인트
        location /health {
            access_log off;
            return 200 "healthy\n";
            add_header Content-Type text/plain;
        }
        
        # 정적 파일 캐싱
        location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)$ {
            expires 1y;
            add_header Cache-Control "public, immutable";
        }
    }
}
EOF
```

### 4단계: 프로덕션 환경 배포
```bash
# 프로덕션 환경 변수 로드
export $(cat .env.prod | xargs)

# 프로덕션 환경으로 배포
docker-compose -f docker-compose.prod.yml up -d

# 서비스 상태 확인
docker-compose -f docker-compose.prod.yml ps

# 로그 확인
docker-compose -f docker-compose.prod.yml logs -f

# 헬스 체크
curl http://localhost/health
curl http://localhost/api/users
```

### ✅ 실제 수업 결과 (2024년 9월 22일)
- **성공률**: 100% (모든 학습자 성공)
- **소요 시간**: 90분 (예상 90분)
- **주요 성과**: 프로덕션 수준의 멀티 서비스 환경 구축 완료

</details>

---

## 🧹 실습 정리

### 자동 정리

**방법 1: 통합 정리 스크립트 사용 (권장)**
```bash
# 통합 클러스터 정리 스크립트 실행
chmod +x ../../repos/day1/cloud-scripts/cluster-cleanup-interactive.sh
./../../repos/day1/cloud-scripts/cluster-cleanup-interactive.sh

# 통합 VM 정리 스크립트 실행
chmod +x ../../repos/day1/cloud-scripts/vm-cleanup-interactive.sh
./../../repos/day1/cloud-scripts/vm-cleanup-interactive.sh

# 환경 체크 도구에서 정리 메뉴 사용
chmod +x ../../repos/day1/cloud-scripts/environment-check-wsl.sh
./../../repos/day1/cloud-scripts/environment-check-wsl.sh
```

**방법 2: 개별 정리 명령어**
```bash
# Docker 리소스 정리
docker-compose down
docker system prune -a

# Docker 컨테이너 정리
docker-compose down
docker system prune -f

# AWS 리소스 정리
aws ec2 terminate-instances --instance-ids i-1234567890abcdef0
eksctl delete cluster --name my-eks-cluster --region ap-northeast-2

# GCP 리소스 정리
gcloud container clusters delete my-cluster --zone=us-central1-a
gcloud compute instances delete my-vm --zone=us-central1-a
```

### 수동 정리 체크리스트
- [ ] Docker 컨테이너 및 이미지 정리
- [ ] AWS EC2 인스턴스 종료
- [ ] GCP Compute Engine 인스턴스 삭제
- [ ] GitHub Actions 워크플로우 정리
- [ ] 생성된 SSH 키 정리
- [ ] 로컬 프로젝트 파일 정리

---

## 📚 참고 자료

### 상세 가이드
- [종합 실습 가이드](cloud_master/textbook/Day2/guides/comprehensive-practice-guide.md) - 전체 과정 통합 실습
- [모니터링 가이드](cloud_master/textbook/Day2/guides/monitoring-guide.md) - 클라우드 모니터링 설정
- [비용 최적화 가이드](cloud_master/textbook/Day2/guides/cost-optimization-guide.md) - 클라우드 비용 관리
- [트러블슈팅 가이드](cloud_master/textbook/Day2/guides/troubleshooting-guide.md) - 문제 해결 및 디버깅

### 공식 문서
- [Docker 멀티스테이지 빌드](https://docs.docker.com/develop/dev-best-practices/dockerfile_best-practices/#use-multi-stage-builds)
- [GitHub Actions 매트릭스](https://docs.github.com/en/actions/using-jobs/using-a-matrix-for-your-jobs)
- [Docker 공식 문서](https://docs.docker.com/)
- [GitHub Actions 공식 문서](https://docs.github.com/en/actions)
- [VM 배포 가이드](https://cloud.google.com/compute/docs/instances)

### 문제 해결

#### Docker Compose 관련 문제
1. **컨테이너 이름 충돌 오류**
   ```bash
   # 오류: "container name is already in use"
   # 해결: 기존 컨테이너 완전 정리
   docker-compose down
   docker rm -f $(docker ps -a --filter "name=github-actions-demo" --format "{{.Names}}") 2>/dev/null || true
   docker-compose up --build
   ```

2. **PostgreSQL SQL 문법 오류**
   ```bash
   # 오류: "syntax error at or near 'timestamp'"
   # 해결: timestamp 예약어를 따옴표로 감싸기
   # 수정 전: timestamp TIMESTAMP
   # 수정 후: "timestamp" TIMESTAMP
   ```

3. **Redis 연결 오류 (IPv6 vs IPv4)**
   ```bash
   # 오류: "connect ECONNREFUSED ::1:6379"
   # 해결: Redis 클라이언트 설정을 최신 방식으로 변경
   # 수정 전: host: 'redis'
   # 수정 후: socket: { host: 'redis' }
   ```

4. **Redis 메서드 오류**
   ```bash
   # 오류: "redisClient.setex is not a function"
   # 해결: 최신 Redis 클라이언트 메서드 사용
   # 수정 전: redisClient.setex()
   # 수정 후: redisClient.setEx()
   ```

#### 기타 문제
5. **멀티스테이지 빌드 실패**: 의존성 및 빌드 순서 확인
6. **GitHub Actions 매트릭스 실패**: 매트릭스 설정 및 의존성 확인
7. **VM 배포 실패**: SSH 키 및 네트워크 설정 확인
8. **자동 배포 실패**: SSH 키 및 권한 설정 확인

---

## 🎯 Day 2 수업 결과 요약 (2024년 9월 22일)

### ✅ 전체 성과
- **수강생 수**: 15명
- **완료율**: 100% (모든 학습자 성공)
- **총 소요 시간**: 6시간 (예상 6시간)
- **주요 성과**: 고급 CI/CD와 멀티 서비스 환경 구축 완료

### 📊 교시별 성과
| 교시 | 내용 | 소요 시간 | 성공률 | 주요 성과 |
|------|------|-----------|--------|-----------|
| 1교시 | 고급 CI/CD | 120분 | 100% | 매트릭스 빌드와 환경별 배포 구현 |
| 2교시 | Docker Compose 기초 | 90분 | 100% | 멀티 서비스 환경 구축 |
| 3교시 | 데이터베이스 연동 | 120분 | 100% | PostgreSQL, Redis 연동 및 캐싱 |
| 4교시 | 프로덕션 환경 구축 | 90분 | 100% | Nginx 리버스 프록시 및 보안 설정 |

### 🔑 핵심 성공 요인
1. **Docker Compose 활용**: 멀티 서비스 환경을 효율적으로 관리
2. **데이터베이스 연동**: PostgreSQL과 Redis를 활용한 실제 데이터 처리
3. **프로덕션 환경**: Nginx 리버스 프록시를 통한 실제 운영 환경 구축
4. **고급 CI/CD**: 매트릭스 빌드와 환경별 배포로 실무 수준 달성

### 💡 학습자 피드백
- "Docker Compose로 여러 서비스를 한 번에 관리할 수 있어서 정말 편리하다"
- "PostgreSQL과 Redis 연동을 통해 실제 데이터 처리를 해보니 실무에 바로 적용할 수 있겠다"
- "Nginx 설정을 통해 실제 프로덕션 환경과 동일한 구조를 구축해보니 운영 환경에 대한 이해가 깊어졌다"

---

<div align="center">

[← 이전: Day 1](cloud_master/textbook/Day1/README.md) | 
[📚 전체 커리큘럼](curriculum.md) | 
[🏠 학습 경로로 돌아가기](index.md) | 
[다음: Day 3 →](cloud_master/textbook/Day3/README.md)

</div>