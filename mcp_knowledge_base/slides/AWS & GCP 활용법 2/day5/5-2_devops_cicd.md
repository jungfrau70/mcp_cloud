# 5-2. CI/CD 파이프라인 구축 (GitHub Actions, Docker)

## 학습 목표
- CI/CD 파이프라인의 개념과 중요성 이해
- GitHub Actions를 사용한 자동화 파이프라인 구축
- Docker 컨테이너 이미지 빌드 및 배포
- 클라우드 환경으로의 자동 배포

---

## CI/CD 파이프라인 개요

### CI/CD란?
```
CI (Continuous Integration):
├── 코드 통합
├── 자동 테스트
├── 빌드 자동화
└── 품질 검사

CD (Continuous Deployment):
├── 자동 배포
├── 환경 관리
├── 롤백 전략
└── 모니터링
```

---

## GitHub Actions 기초

### 워크플로우 구조
```yaml
# .github/workflows/deploy.yml
name: Deploy to Cloud

on:
  push:
    branches: [ main ]
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

  build:
    needs: test
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    
    - name: Build Docker image
      run: docker build -t myapp .
    
    - name: Push to registry
      run: docker push myapp:latest
```

---

## Docker 컨테이너화

### Dockerfile 작성
```dockerfile
# Dockerfile
FROM node:18-alpine

WORKDIR /app

COPY package*.json ./
RUN npm ci --only=production

COPY . .

EXPOSE 3000

CMD ["npm", "start"]
```

### Docker Compose
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
    depends_on:
      - db
  
  db:
    image: postgres:13
    environment:
      - POSTGRES_DB=myapp
      - POSTGRES_USER=user
      - POSTGRES_PASSWORD=password
    volumes:
      - postgres_data:/var/lib/postgresql/data

volumes:
  postgres_data:
```

---

## AWS 배포 파이프라인

### GitHub Actions + AWS
```yaml
# .github/workflows/aws-deploy.yml
name: Deploy to AWS

on:
  push:
    branches: [ main ]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    
    - name: Configure AWS credentials
      uses: aws-actions/configure-aws-credentials@v1
      with:
        aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
        aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        aws-region: ap-northeast-2
    
    - name: Login to Amazon ECR
      id: login-ecr
      uses: aws-actions/amazon-ecr-login@v1
    
    - name: Build and push Docker image
      env:
        ECR_REGISTRY: ${{ steps.login-ecr.outputs.registry }}
        ECR_REPOSITORY: myapp
        IMAGE_TAG: ${{ github.sha }}
      run: |
        docker build -t $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG .
        docker push $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG
    
    - name: Deploy to ECS
      run: |
        aws ecs update-service \
          --cluster my-cluster \
          --service my-service \
          --force-new-deployment
```

---

## GCP 배포 파이프라인

### GitHub Actions + GCP
```yaml
# .github/workflows/gcp-deploy.yml
name: Deploy to GCP

on:
  push:
    branches: [ main ]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup Google Cloud CLI
      uses: google-github-actions/setup-gcloud@v0
      with:
        project_id: ${{ secrets.GCP_PROJECT_ID }}
        service_account_key: ${{ secrets.GCP_SA_KEY }}
    
    - name: Configure Docker for GCR
      run: gcloud auth configure-docker
    
    - name: Build and push Docker image
      run: |
        docker build -t gcr.io/${{ secrets.GCP_PROJECT_ID }}/myapp:${{ github.sha }} .
        docker push gcr.io/${{ secrets.GCP_PROJECT_ID }}/myapp:${{ github.sha }}
    
    - name: Deploy to Cloud Run
      run: |
        gcloud run deploy myapp \
          --image gcr.io/${{ secrets.GCP_PROJECT_ID }}/myapp:${{ github.sha }} \
          --platform managed \
          --region asia-northeast3 \
          --allow-unauthenticated
```

---

## 멀티 환경 배포

### 환경별 워크플로우
```yaml
# .github/workflows/multi-env-deploy.yml
name: Multi-Environment Deployment

on:
  push:
    branches: [ main, develop ]
  workflow_dispatch:
    inputs:
      environment:
        description: 'Environment to deploy to'
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
    - uses: actions/checkout@v3
    
    - name: Deploy to ${{ github.ref == 'refs/heads/main' && 'Production' || 'Staging' }}
      run: |
        echo "Deploying to ${{ github.ref == 'refs/heads/main' && 'production' || 'staging' }}"
        # 환경별 배포 스크립트 실행
```

---

## 보안 및 모범 사례

### 시크릿 관리
```yaml
# GitHub Secrets 설정
AWS_ACCESS_KEY_ID: AWS 액세스 키
AWS_SECRET_ACCESS_KEY: AWS 시크릿 키
GCP_PROJECT_ID: GCP 프로젝트 ID
GCP_SA_KEY: GCP 서비스 계정 키
DOCKER_USERNAME: Docker Hub 사용자명
DOCKER_PASSWORD: Docker Hub 비밀번호
```

### 보안 체크리스트
- [ ] **시크릿 관리**: 민감한 정보를 GitHub Secrets에 저장
- [ ] **권한 최소화**: 필요한 최소 권한만 부여
- [ ] **코드 스캔**: 보안 취약점 자동 검사
- [ ] **의존성 검사**: 보안 업데이트 자동화

---

## 모니터링 및 알림

### 배포 상태 모니터링
```yaml
# .github/workflows/notify.yml
name: Deployment Notification

on:
  workflow_run:
    workflows: ["Deploy to AWS", "Deploy to GCP"]
    types: [completed]

jobs:
  notify:
    runs-on: ubuntu-latest
    steps:
    - name: Notify Slack
      uses: 8398a7/action-slack@v3
      with:
        status: ${{ job.status }}
        channel: '#deployments'
        webhook_url: ${{ secrets.SLACK_WEBHOOK }}
```

---

## 실습 과제

### 기본 실습
1. **GitHub Actions 워크플로우 작성**
2. **Docker 컨테이너 이미지 빌드**
3. **간단한 CI/CD 파이프라인 구성**

### 고급 실습
1. **멀티 클라우드 배포 파이프라인 구축**
2. **자동화된 테스트 및 배포**
3. **배포 모니터링 및 알림 설정**

---

## 다음 단계
- 컨테이너 및 고급 배포 전략
- 보안 및 규정 준수
- 클라우드 기반 DevOps 심화 실습
