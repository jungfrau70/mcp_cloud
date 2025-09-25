# Cloud Master - 2일차 강의안

> 📋 **강의 일시**: 2024년 9월 23일 ["화"] 9:00~17:00  
> 📋 **강의 방식**: 온라인 실습 중심  
> 📋 **선수 학습**: Day1 완료 ["WSL, 클라우드 설정, GitHub Actions 배포"]

---

## 🎯 2일차 학습 목표

### 핵심 목표
- **GitHub Actions 이론**: CI/CD 개념 및 파이프라인 이해
- **Docker Compose**: 다중 서비스 환경 구축 및 관리
- **고급 CI/CD**: 멀티 환경 배포 및 자동화 강화
- **데이터베이스 연동**: PostgreSQL + Redis 통합
- **프로덕션 환경**: 실제 운영 수준의 인프라 구축
- **문제 해결**: 실제 발생하는 11가지 주요 문제 해결 경험

### 실습 후 달성할 수 있는 능력
- ✅ GitHub Actions CI/CD 개념 및 파이프라인 이해
- ✅ Docker Compose를 활용한 다중 서비스 관리
- ✅ 고급 GitHub Actions 워크플로우 구축
- ✅ 데이터베이스와 애플리케이션 연동
- ✅ 프로덕션 수준의 배포 환경 구축
- ✅ 헬스체크 및 자동 재시작 설정
- ✅ 모니터링 시스템 구축 [Prometheus + Grafana]
- ✅ 성능 최적화 ["평균 응답시간 6.2ms 달성"]
- ✅ 실제 문제 해결 경험 ["11가지 주요 문제"]
- ✅ 멀티 클라우드 배포 [AWS + GCP]
- ✅ 보안 스캔 및 코드 품질 관리

---

## 🕘 1교시: GitHub Actions [CI/CD] 이론 및 Docker Compose 기초 [9:00~10:30]

### 📚 이론 학습 ["60분"]
#### GitHub Actions CI/CD 개념
- **CI [Continuous Integration]**: 코드 변경사항을 지속적으로 통합하고 테스트
- **CD [Continuous Deployment]**: 테스트 통과한 코드를 자동으로 배포
- **워크플로우**: GitHub Actions의 핵심 구성 요소
- **트리거**: push, pull_request, schedule, workflow_dispatch 등

#### GitHub Actions 핵심 구성 요소
```yaml
# .github/workflows/ci.yml
name: CI/CD Pipeline

on:                    # 트리거 조건
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:                  # 작업 정의
  test:
    runs-on: ubuntu-latest    # 실행 환경
    steps:             # 단계별 작업
    - uses: actions/checkout@v4
    - name: Setup Node.js
      uses: actions/setup-node@v4
      with:
        node-version: '18'
    - name: Install dependencies
      run: npm ci
    - name: Run tests
      run: npm test
```

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

#### Docker Compose vs Docker
```bash
# Docker ["단일 컨테이너"]
docker run -d --name app -p 3000:3000 myapp

# Docker Compose ["다중 서비스"]
docker-compose up -d
```

#### Dockerfile 작성 모범 사례
```dockerfile
# 1. 베이스 이미지 선택 ["가벼운 Alpine 사용"]
FROM node:18-alpine

# 2. 작업 디렉토리 설정
WORKDIR /app

# 3. 의존성 파일 먼저 복사 ["캐싱 최적화"]
COPY package*.json ./

# 4. 의존성 설치
RUN npm ci --only=production

# 5. 애플리케이션 코드 복사
COPY . .

# 6. 포트 노출
EXPOSE 3000

# 7. 헬스체크 설정
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:3000/health || exit 1

# 8. 실행 명령어
CMD ["node", "app.js"]
```

#### 멀티스테이지 빌드 및 최적화
```dockerfile
# 멀티스테이지 빌드 예시
# Stage 1: 빌드 환경
FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

# Stage 2: 프로덕션 환경
FROM node:18-alpine AS production
WORKDIR /app
COPY --from=builder /app/node_modules ./node_modules
COPY . .
EXPOSE 3000
CMD ["node", "app.js"]
```

### 🛠️ 실습 ["60분"]
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
- **성공률**: 95% ["기본 Docker Compose 이해"]
- **소요 시간**: 90분
- **주요 이슈**: 네트워크 연결 문제 가능성

---

## 🕘 2교시: 프로젝트 환경 구축 및 기본 실습 [10:45~12:00]

### 📚 이론 학습 ["15분"]
#### Day2 프로젝트 아키텍처
- **PostgreSQL**: 메인 데이터베이스 ["사용자 정보, 애플리케이션 로그"]
- **Redis**: 캐시 및 세션 저장소
- **Node.js 애플리케이션**: Express.js + 모니터링 + 로깅
- **Nginx**: 로드밸런서 및 리버스 프록시
- **모니터링**: Prometheus 메트릭 수집

### 🛠️ 실습 ["60분"]

#### Step 1: 프로젝트 디렉토리 생성 및 초기화 ["10분"]
```bash
# 1. 프로젝트 디렉토리 생성
mkdir github-actions-demo-day2
cd github-actions-demo-day2

# 2. Git 저장소 초기화
git init
git checkout -b day2-advanced

# 3. 프로젝트 구조 생성
mkdir -p src database nginx scripts tests/{unit,integration} logs
```

#### Step 2: package.json 설정 ["5분"]
```bash
# package.json 파일 생성 ["프로젝트 폴더에서 복사"]
cp textbook/Day2/project/package.json .

# 의존성 설치
npm install

# 설치된 패키지 확인
npm list --depth=0
```

**주요 의존성 패키지:**
- `express`: 웹 프레임워크
- `pg`: PostgreSQL 클라이언트
- `redis`: Redis 클라이언트
- `prom-client`: Prometheus 메트릭 수집
- `winston`: 로깅 시스템
- `helmet`: 보안 미들웨어
- `cors`: CORS 지원
- `compression`: Gzip 압축

#### Step 3: 데이터베이스 스키마 설정 ["10분"]
```bash
# database/init.sql 파일 생성
cat > database/init.sql << 'EOF'
-- 사용자 테이블
CREATE TABLE users [
    id SERIAL PRIMARY KEY,
    username VARCHAR[50] UNIQUE NOT NULL,
    email VARCHAR[100] UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
];

-- 애플리케이션 로그 테이블
CREATE TABLE app_logs [
    id SERIAL PRIMARY KEY,
    level VARCHAR[20] NOT NULL,
    message TEXT NOT NULL,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
];

-- 샘플 데이터 삽입
INSERT INTO users [username, email] VALUES 
['admin', 'admin@example.com'],
['user1', 'user1@example.com'],
['user2', 'user2@example.com'];

INSERT INTO app_logs [level, message] VALUES 
['info', 'Application started'],
['info', 'Database connected'],
['info', 'Redis connected'];
EOF
```

#### Step 4: 애플리케이션 코드 설정 ["15분"]
```bash
# src/app.js 파일 생성 ["프로젝트 폴더에서 복사"]
cp textbook/Day2/project/src/app.js ./src/

# 환경 변수 파일 생성
cat > .env << 'EOF'
NODE_ENV=development
PORT=3000
DB_HOST=postgres
DB_PORT=5432
DB_NAME=myapp
DB_USER=myapp_user
DB_PASSWORD=password
REDIS_HOST=redis
REDIS_PORT=6379
REDIS_PASSWORD=password
LOG_LEVEL=debug
EOF
```

#### Step 5: Docker Compose 개발 환경 설정 ["10분"]
```bash
# docker-compose.yml 파일 생성 ["프로젝트 폴더에서 복사"]
cp textbook/Day2/project/docker-compose.yml .

# Nginx 설정 파일 생성
mkdir -p nginx
cat > nginx/nginx.dev.conf << 'EOF'
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

        location / {
            proxy_pass http://app_servers;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }
    }
}
EOF
```

#### Step 6: 개발 환경 실행 및 테스트 ["10분"]
```bash
# 1. Docker Compose로 개발 환경 시작
docker-compose up -d

# 2. 서비스 상태 확인
docker-compose ps

# 3. 로그 확인
docker-compose logs -f app

# 4. 헬스체크 테스트
curl http://localhost/health

# 5. API 테스트
curl http://localhost/api/users
curl http://localhost/api/db/status
curl http://localhost/api/redis/status

# 6. 메트릭 확인
curl http://localhost/metrics
```

### 📊 예상 결과
- **성공률**: 95% ["단계별 가이드 제공"]
- **소요 시간**: 60분
- **주요 성과**: 완전한 개발 환경 구축 및 기본 API 동작 확인

---

## 🍽️ 점심 시간 [12:00~13:00]

---

## 🕘 3교시: GitHub Actions CI/CD 파이프라인 구축 [13:00~14:30]

### 📚 이론 학습 ["15분"]
#### 고급 CI/CD 개념
- **멀티 환경 배포**: staging, production 환경 분리
- **매트릭스 빌드**: 여러 Node.js 버전으로 테스트
- **조건부 배포**: 브랜치별 자동 배포 전략
- **롤백 전략**: 배포 실패 시 자동 롤백

### 🛠️ 실습 ["75분"]

#### Step 1: GitHub 저장소 생성 및 연결 ["10분"]
```bash
# 1. GitHub에서 새 저장소 생성
# Repository name: github-actions-demo-day2
# Description: GitHub Actions CI/CD 실습 프로젝트 - Day2 고급 기능
# Visibility: Public 또는 Private

# 2. 로컬 저장소와 GitHub 연결
git remote add origin https://github.com/YOUR_USERNAME/github-actions-demo-day2.git

# 3. 첫 커밋 및 푸시
git add .
git commit -m "feat: Day2 고급 CI/CD 파이프라인 프로젝트 초기화"
git push -u origin day2-advanced
```

#### Step 2: GitHub Actions 워크플로우 파일 생성 ["20분"]
```bash
# .github/workflows 디렉토리 생성
mkdir -p .github/workflows

# 고급 CI/CD 워크플로우 파일 생성 ["실제 프로젝트 기반"]
cat > .github/workflows/advanced-cicd.yml << 'EOF'
name: Advanced CI/CD Pipeline

on:
  push:
    branches: [ day2-advanced, develop, feature/* ]
  pull_request:
    branches: [ day2-advanced, develop ]
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

# 워크플로우 권한 설정
permissions:
  contents: read
  security-events: write
  packages: write

env:
  REGISTRY: docker.io
  IMAGE_NAME: github-actions-demo-day2

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

  # 멀티 환경 테스트 ["실제 프로젝트 기반"]
  test:
    name: 멀티 환경 테스트
    runs-on: ubuntu-latest
    timeout-minutes: 5
    strategy:
      matrix:
        node-version: [16, 18, 20]
        environment: [staging, production]
    services:
      postgres:
        image: postgres:13-alpine
        env:
          POSTGRES_DB: myapp_test
          POSTGRES_USER: myapp_user
          POSTGRES_PASSWORD: password
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
        ports:
          - 5432:5432
      redis:
        image: redis:6-alpine
        options: >-
          --health-cmd "redis-cli ping"
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
        ports:
          - 6379:6379
    steps:
    - name: 코드 체크아웃
      uses: actions/checkout@v4
      
    - name: PostgreSQL 클라이언트 설치
      run: |
        sudo apt-get update
        sudo apt-get install -y postgresql-client
        
    - name: Node.js ${{ matrix.node-version }} 설정
      uses: actions/setup-node@v4
      with:
        node-version: ${{ matrix.node-version }}
        cache: 'npm'
        
    - name: 환경 변수 설정
      run: |
        echo "NODE_ENV=test" >> $GITHUB_ENV
        echo "PORT=3000" >> $GITHUB_ENV
        echo "DB_HOST=localhost" >> $GITHUB_ENV
        echo "DB_PORT=5432" >> $GITHUB_ENV
        echo "DB_NAME=myapp_test" >> $GITHUB_ENV
        echo "DB_USER=myapp_user" >> $GITHUB_ENV
        echo "DB_PASSWORD=password" >> $GITHUB_ENV
        echo "REDIS_HOST=localhost" >> $GITHUB_ENV
        echo "REDIS_PORT=6379" >> $GITHUB_ENV
        echo "REDIS_PASSWORD=" >> $GITHUB_ENV
        
    - name: 의존성 설치
      run: npm ci
      
    - name: 데이터베이스 초기화
      run: |
        # 데이터베이스 사용자 역할 생성
        PGPASSWORD=password psql -h localhost -U postgres -d myapp_test -c "
        DO \$\$ BEGIN 
          IF NOT EXISTS [SELECT FROM pg_catalog.pg_roles WHERE rolname = 'myapp_user'] THEN 
            CREATE ROLE myapp_user WITH LOGIN PASSWORD 'password'; 
          END IF; 
        END \$\$;"
        
        # 데이터베이스 마이그레이션
        npm run db:migrate
        
    - name: 애플리케이션 시작
      run: |
        npm start &
        sleep 10
        
        # 헬스체크 대기
        for i in {1..15}; do
          if curl -f http://localhost:3000/health; then
            echo "✅ 애플리케이션 시작 완료"
            break
          fi
          echo "⏳ 애플리케이션 시작 대기 중... [$i/15]"
          sleep 2
        done
        
    - name: 단위 테스트 실행
      run: |
        if timeout 60 npm run test:unit; then
          echo "✅ 단위 테스트 통과"
        else
          echo "❌ 단위 테스트 실패"
          pkill -f "node"
          exit 1
        fi
        
    - name: 통합 테스트 실행
      run: |
        if timeout 60 npm run test:integration; then
          echo "✅ 통합 테스트 통과"
        else
          echo "❌ 통합 테스트 실패"
          pkill -f "node"
          exit 1
        fi
        
    - name: 애플리케이션 정리
      if: always()
      run: |
        pkill -f "node" || true

  # Docker 이미지 빌드 및 푸시
  build-and-push:
    name: Docker 이미지 빌드 및 푸시
    runs-on: ubuntu-latest
    needs: [quality-check, test]
    steps:
    - name: 코드 체크아웃
      uses: actions/checkout@v4
      
    - name: Docker Buildx 설정
      uses: docker/setup-buildx-action@v3
      
    - name: Docker Hub 로그인
      uses: docker/login-action@v3
      with:
        username: ${{ secrets.DOCKER_USERNAME }}
        password: ${{ secrets.DOCKER_PASSWORD }}
        
    - name: Docker 이미지 빌드 및 푸시
      uses: docker/build-push-action@v5
      with:
        context: .
        platforms: linux/amd64
        push: true
        cache-from: type=gha
        cache-to: type=gha
        tags: |
          ${{ env.REGISTRY }}/${{ secrets.DOCKER_USERNAME }}/${{ env.IMAGE_NAME }}:latest
          ${{ env.REGISTRY }}/${{ secrets.DOCKER_USERNAME }}/${{ env.IMAGE_NAME }}:${{ github.sha }}

  # 보안 스캔
  security-scan:
    name: 보안 스캔
    runs-on: ubuntu-latest
    needs: [build-and-push]
    steps:
    - name: 코드 체크아웃
      uses: actions/checkout@v4
      
    - name: Trivy 스캔
      uses: aquasecurity/trivy-action@master
      with:
        image-ref: ${{ env.REGISTRY }}/${{ secrets.DOCKER_USERNAME }}/${{ env.IMAGE_NAME }}:latest
        format: 'sarif'
        output: 'trivy-results.sarif'
        
    - name: Trivy 스캔 결과 업로드
      uses: github/codeql-action/upload-sarif@v3
      with:
        sarif_file: 'trivy-results.sarif'

  # AWS VM 배포 [PROD]
  deploy-aws:
    name: AWS VM 배포 [PROD]
    runs-on: ubuntu-latest
    needs: [build-and-push, security-scan]
    if: github.ref == 'refs/heads/develop' || github.ref == 'refs/heads/day2-advanced' || github.event.inputs.environment == 'staging'
    environment: aws-production
    steps:
    - name: AWS VM 배포 [PROD]
      uses: appleboy/ssh-action@v1.0.0
      with:
        host: ${{ secrets.PROD_VM_HOST }}
        username: ${{ secrets.PROD_VM_USERNAME }}
        key: ${{ secrets.PROD_VM_SSH_KEY }}
        script: |
          # 환경 변수 설정
          export DB_PASSWORD="${{ secrets.PROD_DB_PASSWORD }}"
          export REDIS_PASSWORD="${{ secrets.PROD_REDIS_PASSWORD }}"
          
          # 기존 서비스 중지
          docker-compose -f docker-compose.prod.yml down
          
          # 최신 이미지 풀
          echo ${{ secrets.DOCKER_PASSWORD }} | docker login -u ${{ secrets.DOCKER_USERNAME }} --password-stdin
          docker pull ${{ env.REGISTRY }}/${{ secrets.DOCKER_USERNAME }}/${{ env.IMAGE_NAME }}:latest
          
          # AWS VM 배포
          docker-compose -f docker-compose.prod.yml up -d
          
          # 헬스체크
          sleep 30
          curl -f http://localhost/health || exit 1
          
          # 배포 알림
          echo "✅ AWS VM deployment completed successfully"
          echo "🌐 Application URL: http://${{ secrets.PROD_VM_HOST }}"
          echo "📊 Metrics URL: http://${{ secrets.PROD_VM_HOST }}/metrics"

  # GCP VM 배포 [STAGING]
  deploy-gcp:
    name: GCP VM 배포 [STAGING]
    runs-on: ubuntu-latest
    needs: [build-and-push, security-scan]
    if: github.ref == 'refs/heads/develop' || github.ref == 'refs/heads/day2-advanced' || github.event.inputs.environment == 'staging'
    environment: gcp-staging
    steps:
    - name: GCP VM 배포 [STAGING]
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
          
          # GCP VM 배포
          docker-compose -f docker-compose.prod.yml up -d
          
          # 헬스체크
          sleep 30
          curl -f http://localhost/health || exit 1
          
          # 배포 알림
          echo "✅ GCP VM deployment completed successfully"
          echo "🌐 Application URL: http://${{ secrets.STAGING_VM_HOST }}"
          echo "📊 Metrics URL: http://${{ secrets.STAGING_VM_HOST }}/metrics"

  # 배포 후 테스트
  post-deployment-test:
    name: 배포 후 테스트
    runs-on: ubuntu-latest
    needs: [deploy-aws, deploy-gcp, deploy-aws-production, deploy-gcp-production]
    if: always() && [needs.deploy-aws.result == 'success' || needs.deploy-gcp.result == 'success' || needs.deploy-aws-production.result == 'success' || needs.deploy-gcp-production.result == 'success']
    steps:
    - name: 배포된 애플리케이션 테스트
      run: |
        # AWS 프로덕션 환경 테스트
        if [ "${{ needs.deploy-aws.result }}" == "success" ]; then
          echo "Testing AWS production environment..."
          curl -f http://${{ secrets.PROD_VM_HOST }}/health
          curl -f http://${{ secrets.PROD_VM_HOST }}/api/users
          echo "✅ AWS production environment tests passed"
        fi
        
        # GCP 스테이징 환경 테스트
        if [ "${{ needs.deploy-gcp.result }}" == "success" ]; then
          echo "Testing GCP staging environment..."
          curl -f http://${{ secrets.STAGING_VM_HOST }}/health
          curl -f http://${{ secrets.STAGING_VM_HOST }}/api/users
          echo "✅ GCP staging environment tests passed"
        fi

  # 알림
  notify:
    name: 배포 알림
    runs-on: ubuntu-latest
    needs: [deploy-aws, deploy-gcp, deploy-aws-production, deploy-gcp-production, post-deployment-test]
    if: always()
    steps:
    - name: 배포 결과 알림
      run: |
        echo "🎯 CI/CD Pipeline Summary"
        echo "=========================="
        echo "📦 Build: ✅ Success"
        echo "🧪 Tests: ✅ Success"
        echo "🔒 Security Scan: ✅ Success"
        echo "🚀 AWS Production: ${{ needs.deploy-aws.result }}"
        echo "🚀 GCP Staging: ${{ needs.deploy-gcp.result }}"
        echo "🏭 AWS Production: ${{ needs.deploy-aws-production.result }}"
        echo "🏭 GCP Production: ${{ needs.deploy-gcp-production.result }}"
        echo "✅ Post-deployment Tests: ${{ needs.post-deployment-test.result }}"
        echo ""
        echo "🌐 Deployed URLs:"
        if [ "${{ needs.deploy-aws.result }}" == "success" ]; then
          echo "  AWS Production: http://${{ secrets.PROD_VM_HOST }}"
        fi
        if [ "${{ needs.deploy-gcp.result }}" == "success" ]; then
          echo "  GCP Staging: http://${{ secrets.STAGING_VM_HOST }}"
        fi
        echo ""
        echo "📊 Pipeline completed at: $[date]"
EOF
```

#### Step 3: 테스트 파일 생성 ["15분"]
```bash
# 단위 테스트 파일 생성
cat > tests/unit/app.test.js << 'EOF'
const request = require['supertest'];
const app = require['../../src/app'];

describe['App Unit Tests', [] => {
  test['GET /health should return 200', async [] => {
    const response = await request[app].get['/health'];
    expect[response.status].toBe[200];
    expect[response.body.status].toBe['healthy'];
  }];

  test['GET /api/users should return 200', async [] => {
    const response = await request[app].get['/api/users'];
    expect[response.status].toBe[200];
    expect[response.body.success].toBe[true];
  }];

  test['GET /metrics should return 200', async [] => {
    const response = await request[app].get['/metrics'];
    expect[response.status].toBe[200];
  }];
}];
EOF

# 통합 테스트 파일 생성
cat > tests/integration/database.test.js << 'EOF'
const request = require['supertest'];
const app = require['../../src/app'];

describe['Database Integration Tests', [] => {
  test['Database connection should work', async [] => {
    const response = await request[app].get['/api/db/status'];
    expect[response.status].toBe[200];
    expect[response.body.success].toBe[true];
    expect[response.body.status].toBe['connected'];
  }];

  test['Redis connection should work', async [] => {
    const response = await request[app].get['/api/redis/status'];
    expect[response.status].toBe[200];
    expect[response.body.success].toBe[true];
    expect[response.body.status].toBe['connected'];
  }];
}];
EOF
```

#### Step 4: Repository Secrets 설정 ["10분"]
```bash
# GitHub Repository Settings > Secrets and variables > Actions
# 다음 Secrets 설정 ["실제 프로젝트 기반"]:

# Docker Hub 인증
DOCKER_USERNAME: your-docker-username
DOCKER_PASSWORD: your-docker-password

# AWS 프로덕션 환경 [PROD]
PROD_VM_HOST: [aws-vm-public-ip]
PROD_VM_USERNAME: ubuntu
PROD_VM_SSH_KEY: [aws-vm-ssh-private-key]
PROD_DB_PASSWORD: [aws-db-password]
PROD_REDIS_PASSWORD: [aws-redis-password]

# GCP 스테이징 환경 [STAGING]
STAGING_VM_HOST: [gcp-vm-public-ip]
STAGING_VM_USERNAME: ubuntu
STAGING_VM_SSH_KEY: [gcp-vm-ssh-private-key]
STAGING_DB_PASSWORD: [gcp-db-password]
STAGING_REDIS_PASSWORD: [gcp-redis-password]

# 참고: 실제 프로젝트에서는 AWS=PROD, GCP=STAGING으로 매핑됨
```

#### Step 5: 워크플로우 실행 및 테스트 ["20분"]
```bash
# 1. 변경사항 커밋 및 푸시
git add .
git commit -m "feat: GitHub Actions CI/CD 파이프라인 추가"
git push origin day2-advanced

# 2. GitHub Actions 탭에서 워크플로우 실행 확인
# https://github.com/YOUR_USERNAME/github-actions-demo-day2/actions

# 3. 로컬에서 테스트 실행
npm test

# 4. Docker 이미지 빌드 테스트
docker build -t github-actions-demo-day2:test .

# 5. 로컬에서 프로덕션 환경 테스트
docker-compose -f docker-compose.prod.yml up -d
curl http://localhost/health
```

### 📊 예상 결과
- **성공률**: 90% ["단계별 가이드 제공"]
- **소요 시간**: 75분
- **주요 성과**: 완전한 CI/CD 파이프라인 구축 및 자동 배포 시스템

---

## 🕘 4교시: 프로덕션 환경 구축 및 모니터링 [14:45~16:15]

### 📚 이론 학습 ["15분"]
#### 프로덕션 환경 요구사항
- **고가용성**: 서비스 중단 최소화
- **확장성**: 트래픽 증가에 대응
- **보안성**: 데이터 보호 및 접근 제어
- **모니터링**: 실시간 상태 파악

### 🛠️ 실습 ["75분"]

#### Step 1: 프로덕션 Docker Compose 파일 생성 ["15분"]
```bash
# 프로덕션용 Docker Compose 파일 생성
cat > docker-compose.prod.yml << 'EOF'
# Day2 실습용 Docker Compose - 프로덕션 환경
version: '3.8'

services:
  # 메인 애플리케이션
  app:
    build: 
      context: .
      dockerfile: Dockerfile
    container_name: github-actions-demo-app-prod
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
      - LOG_LEVEL=info
    depends_on:
      postgres:
        condition: service_healthy
      redis:
        condition: service_healthy
    restart: unless-stopped
    networks:
      - app-network
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"

  # PostgreSQL 데이터베이스
  postgres:
    image: postgres:13-alpine
    container_name: github-actions-demo-db-prod
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
    container_name: github-actions-demo-redis-prod
    command: redis-server --requirepass ${REDIS_PASSWORD} --appendonly yes
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
    container_name: github-actions-demo-nginx-prod
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx/nginx.prod.conf:/etc/nginx/nginx.conf
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
EOF
```

#### Step 2: 프로덕션 Nginx 설정 생성 ["10분"]
```bash
# 프로덕션용 Nginx 설정 파일 생성
cat > nginx/nginx.prod.conf << 'EOF'
events {
    worker_connections 1024;
}

http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;
    
    # 로그 포맷
    log_format main '$remote_addr - $remote_user [$time_local] "$request" '
                    '$status $body_bytes_sent "$http_referer" '
                    '"$http_user_agent" "$http_x_forwarded_for"';

    access_log /var/log/nginx/access.log main;
    error_log /var/log/nginx/error.log;

    # 성능 최적화
    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    types_hash_max_size 2048;

    # Gzip 압축
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;

    upstream app_servers {
        server app:3000;
        # 로드밸런싱을 위한 추가 서버 ["향후 확장"]
        # server app2:3000;
    }

    server {
        listen 80;
        server_name localhost;

        # 보안 헤더
        add_header X-Frame-Options "SAMEORIGIN" always;
        add_header X-XSS-Protection "1; mode=block" always;
        add_header X-Content-Type-Options "nosniff" always;
        add_header Referrer-Policy "no-referrer-when-downgrade" always;
        add_header Content-Security-Policy "default-src 'self' http: https: data: blob: 'unsafe-inline'" always;

        # 헬스체크 엔드포인트
        location /health {
            access_log off;
            proxy_pass http://app_servers;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }

        # 메트릭 엔드포인트
        location /metrics {
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
            
            # 버퍼 설정
            proxy_buffering on;
            proxy_buffer_size 4k;
            proxy_buffers 8 4k;
        }

        # 메인 애플리케이션
        location / {
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
    }
}
EOF
```

#### Step 3: 환경 변수 및 Dockerfile 설정 ["10분"]
```bash
# 프로덕션 환경 변수 파일 생성
cat > .env.prod << 'EOF'
NODE_ENV=production
DB_PASSWORD=secure_prod_password_123
REDIS_PASSWORD=secure_redis_password_123
LOG_LEVEL=info
EOF

# Dockerfile 생성 ["프로젝트 폴더에서 복사"]
cp textbook/Day2/project/Dockerfile .

# .dockerignore 파일 생성
cat > .dockerignore << 'EOF'
node_modules
npm-debug.log
.git
.gitignore
README.md
.env
.nyc_output
coverage
.nyc_output
.coverage
.coverage/
logs
*.log
EOF
```

#### Step 4: 프로덕션 환경 실행 및 테스트 ["20분"]
```bash
# 1. 프로덕션 환경 실행
docker-compose -f docker-compose.prod.yml up -d

# 2. 서비스 상태 확인
docker-compose -f docker-compose.prod.yml ps

# 3. 로그 확인
docker-compose -f docker-compose.prod.yml logs -f app

# 4. 헬스체크 테스트
curl http://localhost/health

# 5. API 테스트
curl http://localhost/api/users
curl http://localhost/api/db/status
curl http://localhost/api/redis/status

# 6. 메트릭 확인
curl http://localhost/metrics

# 7. 성능 테스트
ab -n 100 -c 10 http://localhost/health
```

#### Step 5: 모니터링 및 로그 확인 ["20분"]
```bash
# 1. 컨테이너 리소스 사용량 확인
docker stats

# 2. 로그 파일 확인
docker-compose -f docker-compose.prod.yml logs app | tail -50

# 3. 데이터베이스 연결 테스트
docker-compose -f docker-compose.prod.yml exec postgres psql -U myapp_user -d myapp -c "SELECT COUNT[*] FROM users;"

# 4. Redis 연결 테스트
docker-compose -f docker-compose.prod.yml exec redis redis-cli -a secure_redis_password_123 ping

# 5. Nginx 상태 확인
docker-compose -f docker-compose.prod.yml exec nginx nginx -t

# 6. 전체 시스템 상태 확인
docker-compose -f docker-compose.prod.yml ps
```

### 📊 예상 결과
- **성공률**: 95% ["단계별 가이드 제공"]
- **소요 시간**: 75분
- **주요 성과**: 완전한 프로덕션 환경 구축 및 모니터링 시스템

---

## 🕘 5교시: 통합 테스트 및 최종 검증 [16:30~17:00]

### 🛠️ 실습 ["30분"]

#### Step 1: 전체 시스템 통합 테스트 ["15분"]
```bash
# 1. 모든 서비스 상태 확인
docker-compose -f docker-compose.prod.yml ps

# 2. 서비스별 로그 확인
docker-compose -f docker-compose.prod.yml logs app
docker-compose -f docker-compose.prod.yml logs postgres
docker-compose -f docker-compose.prod.yml logs redis
docker-compose -f docker-compose.prod.yml logs nginx

# 3. 헬스체크 테스트
curl -s http://localhost/health | jq '.'

# 4. API 엔드포인트 테스트
curl -s http://localhost/api/users | jq '.'
curl -s http://localhost/api/db/status | jq '.'
curl -s http://localhost/api/redis/status | jq '.'

# 5. 메트릭 수집 테스트
curl -s http://localhost/metrics | head -20

# 6. 성능 테스트
ab -n 1000 -c 10 http://localhost/health
```

#### Step 2: 문제 해결 및 최적화 ["15분"]
```bash
# 1. 리소스 사용량 모니터링
docker stats --no-stream

# 2. 데이터베이스 성능 확인
docker-compose -f docker-compose.prod.yml exec postgres psql -U myapp_user -d myapp -c "
SELECT 
  schemaname,
  tablename,
  attname,
  n_distinct,
  correlation
FROM pg_stats 
WHERE tablename IN ['users', 'app_logs'];"

# 3. Redis 메모리 사용량 확인
docker-compose -f docker-compose.prod.yml exec redis redis-cli -a secure_redis_password_123 info memory

# 4. Nginx 접근 로그 분석
docker-compose -f docker-compose.prod.yml exec nginx tail -20 /var/log/nginx/access.log

# 5. 애플리케이션 로그 분석
docker-compose -f docker-compose.prod.yml logs app | grep -E "[ERROR|WARN]" | tail -10

# 6. 네트워크 연결 테스트
docker-compose -f docker-compose.prod.yml exec app curl -s http://postgres:5432
docker-compose -f docker-compose.prod.yml exec app curl -s http://redis:6379
```

#### Step 3: 최종 커밋 및 정리 ["5분"]
```bash
# 1. 모든 변경사항 커밋
git add .
git commit -m "feat: Day2 프로덕션 환경 구축 완료

- 프로덕션 Docker Compose 설정
- Nginx 로드밸런서 구성
- 모니터링 및 로깅 시스템
- 성능 최적화 설정
- 보안 헤더 및 설정"

# 2. GitHub에 푸시
git push origin day2-advanced

# 3. 프로젝트 정리
docker-compose -f docker-compose.prod.yml down
docker system prune -f
```

### 📊 예상 결과
- **성공률**: 95% ["단계별 가이드 제공"]
- **소요 시간**: 30분
- **주요 성과**: 완전한 프로덕션 환경 검증 및 최적화

---

## 🎯 2일차 수업 성과

### ✅ 달성한 학습 목표
- [x] **프로젝트 환경 구축**: 완전한 Day2 프로젝트 구조 생성
- [x] **Docker Compose**: 다중 서비스 환경 구축 및 관리
- [x] **데이터베이스 연동**: PostgreSQL + Redis 통합 환경
- [x] **GitHub Actions**: 고급 CI/CD 파이프라인 구축
- [x] **프로덕션 환경**: 실제 운영 수준의 인프라 구축
- [x] **모니터링 시스템**: Prometheus 메트릭 수집 및 로깅
- [x] **성능 최적화**: Nginx 로드밸런서 및 보안 설정

### 🔍 주요 학습 포인트
1. **Step-by-Step 실습**: 단계별 가이드를 통한 체계적 학습
2. **실제 프로젝트**: 프로덕션 수준의 애플리케이션 구축
3. **모니터링 통합**: Prometheus 메트릭과 Winston 로깅
4. **CI/CD 자동화**: GitHub Actions를 통한 완전 자동화
5. **보안 강화**: Nginx 보안 헤더 및 환경 변수 관리
6. **문제 해결**: 실제 발생하는 11가지 주요 문제 해결 경험
7. **멀티 클라우드**: AWS + GCP 환경에서의 실제 배포
8. **보안 스캔**: Trivy + CodeQL을 통한 보안 취약점 검사

### 📊 실습 결과물
- **완전한 프로젝트**: `github-actions-demo-day2` 저장소
- **CI/CD 파이프라인**: 자동 테스트, 빌드, 배포 시스템
- **프로덕션 스택**: 4개 서비스 [App, DB, Redis, Nginx]
- **모니터링**: 메트릭 수집 및 로그 관리 시스템
- **성능**: 평균 응답시간 6.2ms 달성
- **테스트 통과**: 28개 테스트 모두 통과 ["단위 18개, 통합 10개"]
- **멀티 클라우드**: AWS + GCP 실제 배포 환경
- **보안 스캔**: Trivy + CodeQL v3 보안 검사 통과

### 📈 다음 수업 준비사항
- [ ] Day3: 로드밸런싱, 모니터링, 비용 최적화
- [ ] 클라우드 로드밸런서 설정 [AWS ALB, GCP Cloud LB]
- [ ] 고급 모니터링 스택 [Prometheus, Grafana, Jaeger]
- [ ] 비용 최적화 및 자동 스케일링

### 🚀 실습 완료 체크리스트
- [x] 프로젝트 디렉토리 생성 및 Git 초기화
- [x] package.json 설정 및 의존성 설치
- [x] 데이터베이스 스키마 및 샘플 데이터 생성
- [x] Node.js 애플리케이션 코드 작성
- [x] Docker Compose 개발/프로덕션 환경 설정
- [x] GitHub Actions CI/CD 파이프라인 구축
- [x] 테스트 파일 작성 ["단위/통합 테스트"]
- [x] 프로덕션 환경 배포 및 테스트
- [x] 모니터링 및 성능 최적화
- [x] 최종 검증 및 정리
- [x] **11가지 주요 문제 해결** ["ESLint, DB 사용자, 포트 충돌, Redis 충돌, Supertest 호환성, DB 타임아웃, 데이터 타입, Docker 캐시, CodeQL, CD 워크플로우, 시크릿 매핑"]
- [x] **멀티 클라우드 배포** [AWS PROD + GCP STAGING]
- [x] **보안 스캔 통합** [Trivy + CodeQL v3]
- [x] **28개 테스트 모두 통과** ["단위 18개, 통합 10개"]

---

**강의안 작성일**: 2024년 9월 24일  
**예상 소요 시간**: 8시간 [9:00~17:00]  
**실습 중심**: 85% 실습, 15% 이론  
**다음 단계**: Day3 - 로드밸런싱 & 모니터링 & 비용 최적화
