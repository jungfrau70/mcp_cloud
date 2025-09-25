# CI/CD 고급 실습 가이드

## 🎯 학습 목표

### 핵심 학습 목표
- **GitHub Actions 고급** 워크플로우 최적화 및 보안
- **Docker 기반 CI/CD** 컨테이너화된 파이프라인 구축
- **다중 환경 배포** 개발/스테이징/프로덕션 환경 관리
- **자동화된 테스팅** 단위/통합/E2E 테스트 자동화

### 실습 후 달성할 수 있는 능력
- ✅ 복잡한 GitHub Actions 워크플로우 설계 및 구현
- ✅ Docker 기반 CI/CD 파이프라인 구축
- ✅ 다중 환경 자동 배포 시스템 구축
- ✅ 포괄적인 테스트 자동화 구현

### 예상 소요 시간
- **GitHub Actions 고급**: 90-120분
- **Docker CI/CD**: 90-120분
- **다중 환경 배포**: 60-90분
- **테스트 자동화**: 90-120분
- **전체 과정**: 5-7시간

---

## 🛠️ 실습 학습

### 📁 실습 코드 및 자동화
- **실습 샘플 코드**: `/mcp_knowledge_base/cloud_master/repos/samples/day2/actions-demo/`
- **자동화 스크립트**: `/mcp_knowledge_base/cloud_master/repos/automation/day2/advanced_cicd.sh`
- **클라우드 스크립트**: `/mcp_knowledge_base/cloud_master/repos/cloud-scripts/`

<details>
<summary>🚀 실습 환경 준비</summary>

#### 필수 도구
- **Git**: 2.30 이상
- **Docker**: 20.10 이상
- **GitHub CLI**: 2.0 이상
- **Node.js**: 16 이상

#### 환경 설정
```bash
# GitHub CLI 설치 확인
gh --version

# Docker 설치 확인
docker --version

# Node.js 설치 확인
node --version
npm --version
```

</details>

<details>
<summary>🔧 1단계: 고급 GitHub Actions 워크플로우</summary>

#### 복합 워크플로우 구성
```yaml
# .github/workflows/advanced-ci-cd.yml
name: Advanced CI/CD Pipeline

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

env:
  REGISTRY: ghcr.io
  IMAGE_NAME: ${{ github.repository }}

jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        node-version: [16, 18, 20]
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup Node.js ${{ matrix.node-version }}
      uses: actions/setup-node@v3
      with:
        node-version: ${{ matrix.node-version }}
        cache: 'npm'
    
    - name: Install dependencies
      run: npm ci
    
    - name: Run unit tests
      run: npm run test:unit
    
    - name: Run integration tests
      run: npm run test:integration
    
    - name: Generate coverage report
      run: npm run test:coverage
    
    - name: Upload coverage to Codecov
      uses: codecov/codecov-action@v3
      with:
        file: ./coverage/lcov.info

  security:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    
    - name: Run security audit
      run: npm audit --audit-level moderate
    
    - name: Run Snyk security scan
      uses: snyk/actions/node@master
      env:
        SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}

  build:
    needs: [test, security]
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Set up Docker Buildx
      uses: docker/setup-buildx-action@v2
    
    - name: Log in to Container Registry
      uses: docker/login-action@v2
      with:
        registry: ${{ env.REGISTRY }}
        username: ${{ github.actor }}
        password: ${{ secrets.GITHUB_TOKEN }}
    
    - name: Extract metadata
      id: meta
      uses: docker/metadata-action@v4
      with:
        images: ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}
        tags: |
          type=ref,event=branch
          type=ref,event=pr
          type=sha,prefix={{branch}}-
          type=raw,value=latest,enable={{is_default_branch}}
    
    - name: Build and push Docker image
      uses: docker/build-push-action@v4
      with:
        context: .
        push: true
        tags: ${{ steps.meta.outputs.tags }}
        labels: ${{ steps.meta.outputs.labels }}
        cache-from: type=gha
        cache-to: type=gha,mode=max

  deploy-staging:
    needs: build
    runs-on: ubuntu-latest
    environment: staging
    
    steps:
    - name: Deploy to staging
      run: |
        echo "Deploying to staging environment..."
        # 실제 배포 스크립트 실행

  deploy-production:
    needs: [build, deploy-staging]
    runs-on: ubuntu-latest
    environment: production
    if: github.ref == 'refs/heads/main'
    
    steps:
    - name: Deploy to production
      run: |
        echo "Deploying to production environment..."
        # 실제 배포 스크립트 실행
```

#### 워크플로우 최적화
```yaml
# .github/workflows/optimized-ci.yml
name: Optimized CI

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  changes:
    runs-on: ubuntu-latest
    outputs:
      frontend: ${{ steps.changes.outputs.frontend }}
      backend: ${{ steps.changes.outputs.backend }}
      docs: ${{ steps.changes.outputs.docs }}
    steps:
    - uses: actions/checkout@v3
    - uses: dorny/paths-filter@v2
      id: changes
      with:
        filters: |
          frontend:
            - 'frontend/**'
          backend:
            - 'backend/**'
          docs:
            - 'docs/**'

  frontend-tests:
    needs: changes
    if: ${{ needs.changes.outputs.frontend == 'true' }}
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    - name: Frontend tests
      run: |
        cd frontend
        npm ci
        npm run test

  backend-tests:
    needs: changes
    if: ${{ needs.changes.outputs.backend == 'true' }}
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    - name: Backend tests
      run: |
        cd backend
        npm ci
        npm run test
```

</details>

<details>
<summary>🔧 2단계: Docker 기반 CI/CD 파이프라인</summary>

#### 멀티스테이지 CI/CD Dockerfile
```dockerfile
# CI/CD용 멀티스테이지 Dockerfile
FROM node:16-alpine AS base
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production && npm cache clean --force

FROM node:16-alpine AS development
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
EXPOSE 3000
CMD ["npm", "run", "dev"]

FROM node:16-alpine AS test
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run test
RUN npm run test:coverage

FROM node:16-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

FROM node:16-alpine AS production
WORKDIR /app
COPY --from=base /app/node_modules ./node_modules
COPY --from=build /app/dist ./dist
COPY --from=build /app/package*.json ./
EXPOSE 3000
CMD ["npm", "start"]
```

#### Docker Compose CI/CD 설정
```yaml
# docker-compose.ci.yml
version: '3.8'

services:
  test:
    build:
      context: .
      target: test
    volumes:
      - ./coverage:/app/coverage
    environment:
      - NODE_ENV=test
      - CI=true

  build:
    build:
      context: .
      target: build
    volumes:
      - ./dist:/app/dist

  production:
    build:
      context: .
      target: production
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=production
```

</details>

<details>
<summary>🔧 3단계: 다중 환경 배포</summary>

#### 환경별 설정 관리
```yaml
# .github/workflows/deploy-multi-env.yml
name: Multi-Environment Deployment

on:
  push:
    branches: [ main, develop, feature/* ]

jobs:
  determine-environment:
    runs-on: ubuntu-latest
    outputs:
      environment: ${{ steps.env.outputs.environment }}
      should-deploy: ${{ steps.env.outputs.should-deploy }}
    steps:
    - name: Determine environment
      id: env
      run: |
        if [[ "${{ github.ref }}" == "refs/heads/main" ]]; then
          echo "environment=production" >> $GITHUB_OUTPUT
          echo "should-deploy=true" >> $GITHUB_OUTPUT
        elif [[ "${{ github.ref }}" == "refs/heads/develop" ]]; then
          echo "environment=staging" >> $GITHUB_OUTPUT
          echo "should-deploy=true" >> $GITHUB_OUTPUT
        else
          echo "environment=development" >> $GITHUB_OUTPUT
          echo "should-deploy=false" >> $GITHUB_OUTPUT
        fi

  deploy:
    needs: determine-environment
    if: needs.determine-environment.outputs.should-deploy == 'true'
    runs-on: ubuntu-latest
    environment: ${{ needs.determine-environment.outputs.environment }}
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Deploy to ${{ needs.determine-environment.outputs.environment }}
      run: |
        echo "Deploying to ${{ needs.determine-environment.outputs.environment }}"
        # 환경별 배포 스크립트 실행
```

#### 환경별 설정 파일
```yaml
# config/development.yml
database:
  host: localhost
  port: 5432
  name: myapp_dev

redis:
  host: localhost
  port: 6379

logging:
  level: debug

# config/staging.yml
database:
  host: staging-db.example.com
  port: 5432
  name: myapp_staging

redis:
  host: staging-redis.example.com
  port: 6379

logging:
  level: info

# config/production.yml
database:
  host: prod-db.example.com
  port: 5432
  name: myapp_prod

redis:
  host: prod-redis.example.com
  port: 6379

logging:
  level: warn
```

</details>

<details>
<summary>🔧 4단계: 테스트 자동화</summary>

#### 포괄적인 테스트 설정
```yaml
# .github/workflows/test-automation.yml
name: Test Automation

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  unit-tests:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup Node.js
      uses: actions/setup-node@v3
      with:
        node-version: '18'
        cache: 'npm'
    
    - name: Install dependencies
      run: npm ci
    
    - name: Run unit tests
      run: npm run test:unit
    
    - name: Upload unit test results
      uses: actions/upload-artifact@v3
      with:
        name: unit-test-results
        path: test-results/

  integration-tests:
    runs-on: ubuntu-latest
    services:
      postgres:
        image: postgres:13
        env:
          POSTGRES_PASSWORD: postgres
          POSTGRES_DB: testdb
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
        ports:
          - 5432:5432
      
      redis:
        image: redis:6
        options: >-
          --health-cmd "redis-cli ping"
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
        ports:
          - 6379:6379
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup Node.js
      uses: actions/setup-node@v3
      with:
        node-version: '18'
        cache: 'npm'
    
    - name: Install dependencies
      run: npm ci
    
    - name: Run integration tests
      run: npm run test:integration
      env:
        DATABASE_URL: postgres://postgres:postgres@localhost:5432/testdb
        REDIS_URL: redis://localhost:6379

  e2e-tests:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup Node.js
      uses: actions/setup-node@v3
      with:
        node-version: '18'
        cache: 'npm'
    
    - name: Install dependencies
      run: npm ci
    
    - name: Build application
      run: npm run build
    
    - name: Start application
      run: npm start &
      env:
        NODE_ENV: test
        PORT: 3000
    
    - name: Wait for application
      run: npx wait-on http://localhost:3000
    
    - name: Run E2E tests
      run: npm run test:e2e
    
    - name: Upload E2E test results
      uses: actions/upload-artifact@v3
      with:
        name: e2e-test-results
        path: e2e-results/

  performance-tests:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup Node.js
      uses: actions/setup-node@v3
      with:
        node-version: '18'
        cache: 'npm'
    
    - name: Install dependencies
      run: npm ci
    
    - name: Build application
      run: npm run build
    
    - name: Start application
      run: npm start &
      env:
        NODE_ENV: test
        PORT: 3000
    
    - name: Wait for application
      run: npx wait-on http://localhost:3000
    
    - name: Run performance tests
      run: npm run test:performance
    
    - name: Upload performance test results
      uses: actions/upload-artifact@v3
      with:
        name: performance-test-results
        path: performance-results/
```

</details>

---

## 📚 참고 자료

### 유용한 명령어
```bash
# GitHub Actions 관리
gh workflow list                    # 워크플로우 목록
gh workflow run "CI/CD Pipeline"    # 워크플로우 수동 실행
gh run list                        # 실행 기록 확인
gh run view <run-id>               # 실행 상세 확인

# Docker CI/CD 관리
docker build --target test .       # 테스트 단계만 빌드
docker-compose -f docker-compose.ci.yml up test  # CI 테스트 실행
```

### 문제 해결
1. **워크플로우 실패**
   - 로그 확인 및 디버깅
   - 시크릿 및 환경 변수 확인
   - 권한 설정 검토

2. **Docker 빌드 실패**
   - Dockerfile 문법 검증
   - 빌드 컨텍스트 확인
   - 레이어 캐시 정리

---

## 🧹 실습 정리

### 자동 정리
```bash
# Day2 CI/CD 고급 실습 자동 정리
./mcp_knowledge_base/cloud_master/repos/automation/day2/advanced_cicd.sh --cleanup
```

### 수동 정리
```bash
# GitHub Actions 아티팩트 정리
gh api repos/:owner/:repo/actions/artifacts --jq '.artifacts[] | select[.expired == true] | .id' | xargs -I {} gh api -X DELETE repos/:owner/:repo/actions/artifacts/{}

# Docker 리소스 정리
docker system prune -a
docker volume prune
```

### 정리 확인
- [ ] GitHub Actions 아티팩트 정리
- [ ] Docker 이미지 및 컨테이너 정리
- [ ] 테스트 결과 파일 정리
- [ ] 임시 파일 정리
