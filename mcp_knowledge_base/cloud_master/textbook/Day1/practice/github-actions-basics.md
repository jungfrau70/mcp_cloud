# GitHub Actions 기초 실습 가이드

<div align="center">

[← 이전: Cloud Master 메인](../README.md) | [📚 전체 커리큘럼](/curriculum.md) | [🏠 학습 경로로 돌아가기](/index.md) | [📋 학습 경로](../../learning-path.md)

</div>

<div align="center">

[← 이전: Git/GitHub 기초 실습](./git-github-basics) | [📚 전체 커리큘럼](/curriculum.md) | [🏠 학습 경로로 돌아가기](/index.md) | [다음: VM 배포 실습 →](./vm-deployment)

</div>

## 🎯 실습 목표
- GitHub Actions의 기본 개념 이해
- CI/CD 파이프라인 구축
- 자동화된 테스트, 빌드, 배포 구현
- Docker 이미지 자동 빌드 및 레지스트리 푸시

## 📋 실습 환경 준비

### 필수 계정 및 도구
- **GitHub 계정**: Actions 사용을 위한 계정
- **Docker Hub 계정**: 컨테이너 이미지 저장소 (선택사항)
- **AWS/GCP 계정**: 클라우드 배포용 (선택사항)

### 프로젝트 준비
```bash
# 새 프로젝트 디렉토리 생성
mkdir github-actions-practice
cd github-actions-practice

# Git 저장소 초기화
git init

# GitHub에 저장소 생성 후 연결
git remote add origin https://github.com/username/github-actions-practice.git
```

## 🚀 실습 1: 기본 워크플로우 생성

### 1. 프로젝트 파일 생성

**package.json**
```json
{
  "name": "github-actions-practice",
  "version": "1.0.0",
  "description": "Practice project for GitHub Actions",
  "main": "app.js",
  "scripts": {
    "start": "node app.js",
    "test": "jest",
    "lint": "eslint ."
  },
  "dependencies": {
    "express": "^4.18.2"
  },
  "devDependencies": {
    "jest": "^29.7.0",
    "supertest": "^6.3.3",
    "eslint": "^8.57.0"
  }
}
```

**app.js**
```javascript
const express = require('express');
const app = express();
const port = process.env.PORT || 3000;

app.get('/', (req, res) => {
  res.json({
    message: 'Hello GitHub Actions!',
    timestamp: new Date().toISOString(),
    version: '1.0.0'
  });
});

app.get('/health', (req, res) => {
  res.json({ 
    status: 'OK', 
    uptime: process.uptime(),
    timestamp: new Date().toISOString()
  });
});

// 테스트 환경이 아닐 때만 서버 시작
if (process.env.NODE_ENV !== 'test') {
  app.listen(port, () => {
    console.log(`Server running on port ${port}`);
  });
}

module.exports = app;
```

**tests/app.test.js**
```javascript
const request = require('supertest');
const app = require('../app');

describe('App Tests', () => {
  beforeAll(() => {
    process.env.NODE_ENV = 'test';
  });

  test('GET / should return welcome message', async () => {
    const response = await request(app).get('/');
    expect(response.status).toBe(200);
    expect(response.body.message).toBe('Hello GitHub Actions!');
  });

  test('GET /health should return health status', async () => {
    const response = await request(app).get('/health');
    expect(response.status).toBe(200);
    expect(response.body.status).toBe('OK');
  });
});
```

### 2. 기본 CI 워크플로우 생성

**.github/workflows/ci.yml**
```yaml
name: CI Pipeline

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
    
    steps:
    - name: Checkout code
      uses: actions/checkout@v4
      
    - name: Setup Node.js ${{ matrix.node-version }}
      uses: actions/setup-node@v4
      with:
        node-version: ${{ matrix.node-version }}
        cache: 'npm'
        
    - name: Install dependencies
      run: npm ci
      
    - name: Run tests
      run: npm test
      
    - name: Run linting
      run: npm run lint
      
    - name: Upload coverage reports
      uses: codecov/codecov-action@v3
      if: matrix.node-version == 18
      with:
        file: ./coverage/lcov.info
```

## 🚀 실습 2: Docker 이미지 자동 빌드

### 1. Dockerfile 생성

**Dockerfile**
```dockerfile
# Node.js 18 버전을 베이스 이미지로 사용
FROM node:18-alpine

# 작업 디렉토리 설정
WORKDIR /app

# 패키지 파일 복사
COPY package*.json ./

# 의존성 설치
RUN npm ci --only=production

# 소스 코드 복사
COPY . .

# 비root 사용자로 실행
RUN addgroup -g 1001 -S nodejs
RUN adduser -S nextjs -u 1001
USER nextjs

# 포트 3000 노출
EXPOSE 3000

# 애플리케이션 시작
CMD ["npm", "start"]
```

### 2. Docker 이미지 빌드 워크플로우

**.github/workflows/docker-build.yml**
```yaml
name: Build and Push Docker Image

on:
  push:
    branches: [ main ]
    tags: [ 'v*' ]
  pull_request:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest
    
    steps:
    - name: Checkout code
      uses: actions/checkout@v4
      
    - name: Set up Docker Buildx
      uses: docker/setup-buildx-action@v3
      
    - name: Login to Docker Hub
      uses: docker/login-action@v3
      with:
        username: ${{ secrets.DOCKER_USERNAME }}
        password: ${{ secrets.DOCKER_PASSWORD }}
        
    - name: Extract metadata
      id: meta
      uses: docker/metadata-action@v5
      with:
        images: ${{ secrets.DOCKER_USERNAME }}/github-actions-practice
        tags: |
          type=ref,event=branch
          type=ref,event=pr
          type=semver,pattern={{version}}
          type=semver,pattern={{major}}.{{minor}}
          type=raw,value=latest,enable={{is_default_branch}}
          
    - name: Build and push
      uses: docker/build-push-action@v5
      with:
        context: .
        push: true
        tags: ${{ steps.meta.outputs.tags }}
        labels: ${{ steps.meta.outputs.labels }}
        cache-from: type=gha
        cache-to: type=gha,mode=max
```

## 🚀 실습 3: 자동 배포 워크플로우

### 1. VM 배포 워크플로우

**.github/workflows/deploy.yml**
```yaml
name: Deploy to VM

on:
  push:
    branches: [ main ]

jobs:
  deploy:
    runs-on: ubuntu-latest
    
    steps:
    - name: Checkout code
      uses: actions/checkout@v4
      
    - name: Setup Node.js
      uses: actions/setup-node@v4
      with:
        node-version: '18'
        
    - name: Install dependencies
      run: npm ci
      
    - name: Build application
      run: npm run build
      
    - name: Deploy to AWS EC2
      uses: appleboy/ssh-action@v1.0.3
      with:
        host: ${{ secrets.AWS_HOST }}
        username: ${{ secrets.AWS_USERNAME }}
        key: ${{ secrets.AWS_SSH_KEY }}
        script: |
          cd /home/ec2-user/github-actions-practice
          git pull origin main
          docker-compose down
          docker-compose up -d --build
          
    - name: Deploy to GCP Compute Engine
      uses: appleboy/ssh-action@v1.0.3
      with:
        host: ${{ secrets.GCP_HOST }}
        username: ${{ secrets.GCP_USERNAME }}
        key: ${{ secrets.GCP_SSH_KEY }}
        script: |
          cd /home/ubuntu/github-actions-practice
          git pull origin main
          docker-compose down
          docker-compose up -d --build
```

### 2. 환경별 배포 워크플로우

**.github/workflows/deploy-environments.yml**
```yaml
name: Deploy to Environments

on:
  push:
    branches: [ main, develop ]
  workflow_dispatch:
    inputs:
      environment:
        description: 'Environment to deploy'
        required: true
        default: 'staging'
        type: choice
        options:
        - staging
        - production

jobs:
  deploy:
    runs-on: ubuntu-latest
    environment: ${{ github.ref == 'refs/heads/main' && 'production' || 'staging' }}
    
    steps:
    - name: Checkout code
      uses: actions/checkout@v4
      
    - name: Setup Node.js
      uses: actions/setup-node@v4
      with:
        node-version: '18'
        
    - name: Install dependencies
      run: npm ci
      
    - name: Run tests
      run: npm test
      
    - name: Build application
      run: npm run build
      
    - name: Deploy to ${{ github.ref == 'refs/heads/main' && 'Production' || 'Staging' }}
      run: |
        echo "Deploying to ${{ github.ref == 'refs/heads/main' && 'production' || 'staging' }} environment"
        # 실제 배포 로직 구현
```

## 🚀 실습 4: 고급 워크플로우 기능

### 1. 매트릭스 빌드

**.github/workflows/matrix-build.yml**
```yaml
name: Matrix Build

on:
  push:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest
    
    strategy:
      matrix:
        node-version: [16, 18, 20]
        os: [ubuntu-latest, windows-latest, macos-latest]
        exclude:
          - node-version: 16
            os: windows-latest
          - node-version: 20
            os: macos-latest
    
    steps:
    - name: Checkout code
      uses: actions/checkout@v4
      
    - name: Setup Node.js ${{ matrix.node-version }}
      uses: actions/setup-node@v4
      with:
        node-version: ${{ matrix.node-version }}
        cache: 'npm'
        
    - name: Install dependencies
      run: npm ci
      
    - name: Run tests
      run: npm test
      
    - name: Upload test results
      uses: actions/upload-artifact@v4
      if: always()
      with:
        name: test-results-${{ matrix.os }}-${{ matrix.node-version }}
        path: test-results/
```

### 2. 조건부 실행

**.github/workflows/conditional.yml**
```yaml
name: Conditional Workflow

on:
  push:
    branches: [ main, develop ]
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
    - name: Checkout code
      uses: actions/checkout@v4
      with:
        fetch-depth: 0
        
    - name: Check for changes
      uses: dorny/paths-filter@v2
      id: changes
      with:
        filters: |
          frontend:
            - 'frontend/**'
          backend:
            - 'backend/**'
          docs:
            - 'docs/**'
            - '*.md'

  frontend-tests:
    needs: changes
    if: ${{ needs.changes.outputs.frontend == 'true' }}
    runs-on: ubuntu-latest
    steps:
    - name: Run frontend tests
      run: echo "Running frontend tests"

  backend-tests:
    needs: changes
    if: ${{ needs.changes.outputs.backend == 'true' }}
    runs-on: ubuntu-latest
    steps:
    - name: Run backend tests
      run: echo "Running backend tests"

  docs-build:
    needs: changes
    if: ${{ needs.changes.outputs.docs == 'true' }}
    runs-on: ubuntu-latest
    steps:
    - name: Build documentation
      run: echo "Building documentation"
```

## 🚀 실습 5: 시크릿 및 환경 변수

### 1. GitHub Secrets 설정
1. 저장소 Settings > Secrets and variables > Actions
2. New repository secret 클릭
3. 다음 시크릿들 추가:
   - `DOCKER_USERNAME`: Docker Hub 사용자명
   - `DOCKER_PASSWORD`: Docker Hub 비밀번호
   - `AWS_HOST`: AWS EC2 호스트
   - `AWS_USERNAME`: AWS EC2 사용자명
   - `AWS_SSH_KEY`: AWS EC2 SSH 키
   - `GCP_HOST`: GCP Compute Engine 호스트
   - `GCP_USERNAME`: GCP 사용자명
   - `GCP_SSH_KEY`: GCP SSH 키

### 2. 환경 변수 사용

**.github/workflows/secrets.yml**
```yaml
name: Secrets and Environment Variables

on:
  push:
    branches: [ main ]

jobs:
  deploy:
    runs-on: ubuntu-latest
    environment: production
    
    steps:
    - name: Checkout code
      uses: actions/checkout@v4
      
    - name: Use secrets
      run: |
        echo "Docker username: ${{ secrets.DOCKER_USERNAME }}"
        echo "AWS host: ${{ secrets.AWS_HOST }}"
        # 시크릿은 마스킹되어 로그에 표시되지 않음
        
    - name: Use environment variables
      env:
        NODE_ENV: production
        API_URL: ${{ vars.API_URL }}
      run: |
        echo "Node environment: $NODE_ENV"
        echo "API URL: $API_URL"
```

## 🚀 실습 6: 아티팩트 및 캐시

### 1. 아티팩트 업로드/다운로드

**.github/workflows/artifacts.yml**
```yaml
name: Artifacts and Cache

on:
  push:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest
    
    steps:
    - name: Checkout code
      uses: actions/checkout@v4
      
    - name: Setup Node.js
      uses: actions/setup-node@v4
      with:
        node-version: '18'
        cache: 'npm'
        
    - name: Install dependencies
      run: npm ci
      
    - name: Build application
      run: npm run build
      
    - name: Upload build artifacts
      uses: actions/upload-artifact@v4
      with:
        name: build-files
        path: |
          dist/
          build/
        retention-days: 30

  deploy:
    needs: build
    runs-on: ubuntu-latest
    
    steps:
    - name: Download build artifacts
      uses: actions/download-artifact@v4
      with:
        name: build-files
        path: ./dist
        
    - name: Deploy artifacts
      run: |
        echo "Deploying artifacts from dist/"
        ls -la dist/
```

### 2. 캐시 사용

**.github/workflows/cache.yml**
```yaml
name: Cache Usage

on:
  push:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest
    
    steps:
    - name: Checkout code
      uses: actions/checkout@v4
      
    - name: Cache dependencies
      uses: actions/cache@v3
      with:
        path: |
          node_modules
          ~/.npm
        key: ${{ runner.os }}-node-${{ hashFiles('**/package-lock.json') }}
        restore-keys: |
          ${{ runner.os }}-node-
          
    - name: Install dependencies
      run: npm ci
      
    - name: Cache build files
      uses: actions/cache@v3
      with:
        path: |
          dist/
          build/
        key: ${{ runner.os }}-build-${{ hashFiles('**/*.js') }}
        restore-keys: |
          ${{ runner.os }}-build-
          
    - name: Build application
      run: npm run build
```

## 🎯 실습 완료 체크리스트

- [ ] 기본 CI 워크플로우 생성
- [ ] Docker 이미지 자동 빌드
- [ ] VM 자동 배포
- [ ] 환경별 배포 전략
- [ ] 매트릭스 빌드 구현
- [ ] 조건부 실행 설정
- [ ] 시크릿 및 환경 변수 사용
- [ ] 아티팩트 및 캐시 활용

## 📚 추가 학습 자료

- [GitHub Actions 공식 문서](https://docs.github.com/en/actions)
- [GitHub Actions Marketplace](https://github.com/marketplace?type=actions)
- [GitHub Actions 예제](https://github.com/actions/starter-workflows)
- [Docker Actions](https://github.com/docker/build-push-action)

## 🚀 다음 단계

- **VM 배포**: 클라우드 환경에 애플리케이션 배포
- **고급 CI/CD**: 복잡한 배포 파이프라인 구축
- **모니터링**: 배포 상태 모니터링 및 알림
