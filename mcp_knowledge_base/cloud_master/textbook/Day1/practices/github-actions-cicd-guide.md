# GitHub Actions CI/CD 완전 가이드

## 🎯 학습 목표

### 핵심 학습 목표
- **GitHub Actions 기초**: 워크플로우 생성, 실행, 관리
- **CI/CD 파이프라인**: 자동화된 테스트, 빌드, 배포
- **클라우드 배포**: AWS, GCP 환경에 자동 배포
- **모니터링 및 최적화**: 배포 상태 모니터링 및 성능 최적화

### 실습 후 달성할 수 있는 능력
- ✅ GitHub Actions 워크플로우 설계 및 구현
- ✅ Docker 이미지 자동 빌드 및 배포
- ✅ VM 및 Kubernetes 클러스터 자동 배포
- ✅ 모니터링 및 알림 시스템 구축

### 예상 소요 시간
- **Day 1: 기본 CI/CD**: 120-150분
- **Day 2: 고급 CI/CD**: 150-180분
- **Day 3: 모니터링 & 최적화**: 120-150분
- **전체 과정**: 6-8시간

---

## 📚 기존 문서와의 연계

### 관련 실습 가이드
- [GitHub Actions 기초 실습](github-actions-basics.md) - 기본 워크플로우 생성
- [VM 배포 실습](vm-deployment.md) - 클라우드 VM 배포
- [Kubernetes 실습](../Day2/practices/kubernetes-basics.md) - 컨테이너 오케스트레이션
- [모니터링 실습](../Day3/practices/monitoring-basics.md) - 모니터링 시스템 구축

### 자동화 스크립트
- [통합 자동화 스크립트](../../../automation/integrated-practice-automation.sh) - 전체 과정 자동화
- [환경 체크 도구](../../../cloud-scripts/environment-check-wsl.sh) - 실습 환경 검증
- [클러스터 생성 스크립트](../../../cloud-scripts/k8s-cluster-create.sh) - Kubernetes 클러스터 자동 생성

---

## 🚀 Day 1: 기본 CI/CD 파이프라인 구축

### 📋 실습 환경 준비

#### 필수 계정 및 도구
- **GitHub 계정**: Actions 사용을 위한 계정
- **Docker Hub 계정**: 컨테이너 이미지 저장소
- **AWS 계정**: Free Tier 계정
- **GCP 계정**: Free Tier 계정 ($300 크레딧)

#### 환경 설정
```bash
# 필수 도구 설치 확인
docker --version
aws --version
gcloud --version
kubectl version --client

# GitHub CLI 설치 (선택사항)
gh --version
```

### 🔧 1단계: 기본 워크플로우 생성

#### 프로젝트 구조 생성
```bash
# 프로젝트 디렉토리 생성
mkdir github-actions-cicd-practice
cd github-actions-cicd-practice

# 기본 프로젝트 파일 생성
mkdir -p .github/workflows
mkdir -p src tests docs
```

#### 기본 애플리케이션 생성
**package.json**
```json
{
  "name": "github-actions-cicd-practice",
  "version": "1.0.0",
  "description": "GitHub Actions CI/CD 실습 프로젝트",
  "main": "src/app.js",
  "scripts": {
    "start": "node src/app.js",
    "test": "jest",
    "lint": "eslint src/",
    "build": "echo 'Build completed'"
  },
  "dependencies": {
    "express": "^4.18.2",
    "cors": "^2.8.5"
  },
  "devDependencies": {
    "jest": "^29.7.0",
    "supertest": "^6.3.3",
    "eslint": "^8.57.0"
  }
}
```

**src/app.js**
```javascript
const express = require('express');
const cors = require('cors');
const app = express();
const port = process.env.PORT || 3000;

// 미들웨어 설정
app.use(cors());
app.use(express.json());

// 기본 라우트
app.get('/', (req, res) => {
  res.json({
    message: 'GitHub Actions CI/CD 실습 애플리케이션',
    version: '1.0.0',
    timestamp: new Date().toISOString(),
    environment: process.env.NODE_ENV || 'development'
  });
});

// 헬스 체크 엔드포인트
app.get('/health', (req, res) => {
  res.json({
    status: 'OK',
    uptime: process.uptime(),
    memory: process.memoryUsage(),
    timestamp: new Date().toISOString()
  });
});

// API 엔드포인트
app.get('/api/status', (req, res) => {
  res.json({
    service: 'GitHub Actions CI/CD Practice',
    status: 'running',
    version: '1.0.0'
  });
});

// 테스트 환경이 아닐 때만 서버 시작
if (process.env.NODE_ENV !== 'test') {
  app.listen(port, () => {
    console.log(`🚀 서버가 포트 ${port}에서 실행 중입니다.`);
    console.log(`📊 헬스 체크: http://localhost:${port}/health`);
  });
}

module.exports = app;
```

#### 기본 CI 워크플로우 생성
**.github/workflows/ci.yml**
```yaml
name: CI Pipeline

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

env:
  NODE_VERSION: '18'

jobs:
  test:
    name: 테스트 실행
    runs-on: ubuntu-latest
    
    strategy:
      matrix:
        node-version: [16, 18, 20]
    
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
      
    - name: 린팅 실행
      run: npm run lint
      
    - name: 테스트 실행
      run: npm test
      
    - name: 테스트 결과 업로드
      uses: actions/upload-artifact@v4
      if: always()
      with:
        name: test-results-node-${{ matrix.node-version }}
        path: test-results/
        retention-days: 30

  build:
    name: 애플리케이션 빌드
    runs-on: ubuntu-latest
    needs: test
    
    steps:
    - name: 코드 체크아웃
      uses: actions/checkout@v4
      
    - name: Node.js 설정
      uses: actions/setup-node@v4
      with:
        node-version: ${{ env.NODE_VERSION }}
        cache: 'npm'
        
    - name: 의존성 설치
      run: npm ci
      
    - name: 애플리케이션 빌드
      run: npm run build
      
    - name: 빌드 아티팩트 업로드
      uses: actions/upload-artifact@v4
      with:
        name: build-artifacts
        path: |
          src/
          package.json
          package-lock.json
        retention-days: 30

  security-scan:
    name: 보안 스캔
    runs-on: ubuntu-latest
    needs: test
    
    steps:
    - name: 코드 체크아웃
      uses: actions/checkout@v4
      
    - name: Node.js 설정
      uses: actions/setup-node@v4
      with:
        node-version: ${{ env.NODE_VERSION }}
        cache: 'npm'
        
    - name: 의존성 설치
      run: npm ci
      
    - name: 보안 취약점 스캔
      run: npm audit --audit-level moderate
      
    - name: 의존성 취약점 스캔
      run: npx audit-ci --moderate
```

### 🐳 2단계: Docker 이미지 자동 빌드

#### Dockerfile 생성
**Dockerfile**
```dockerfile
# 멀티스테이지 빌드
FROM node:18-alpine AS builder

# 작업 디렉토리 설정
WORKDIR /app

# 패키지 파일 복사
COPY package*.json ./

# 의존성 설치
RUN npm ci --only=production && npm cache clean --force

# 런타임 스테이지
FROM node:18-alpine AS runtime

# 보안을 위한 비root 사용자 생성
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nextjs -u 1001

# 작업 디렉토리 설정
WORKDIR /app

# 의존성 복사
COPY --from=builder /app/node_modules ./node_modules

# 소스 코드 복사
COPY --chown=nextjs:nodejs . .

# 사용자 변경
USER nextjs

# 포트 노출
EXPOSE 3000

# 헬스 체크
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD node -e "require('http').get('http://localhost:3000/health', (res) => { process.exit(res.statusCode === 200 ? 0 : 1) })"

# 애플리케이션 시작
CMD ["node", "src/app.js"]
```

#### Docker 이미지 빌드 워크플로우
**.github/workflows/docker-build.yml**
```yaml
name: Docker Build and Push

on:
  push:
    branches: [ main ]
    tags: [ 'v*' ]
  pull_request:
    branches: [ main ]

env:
  REGISTRY: docker.io
  IMAGE_NAME: ${{ github.repository }}

jobs:
  build:
    name: Docker 이미지 빌드 및 푸시
    runs-on: ubuntu-latest
    
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
        
    - name: 메타데이터 추출
      id: meta
      uses: docker/metadata-action@v5
      with:
        images: ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}
        tags: |
          type=ref,event=branch
          type=ref,event=pr
          type=semver,pattern={{version}}
          type=semver,pattern={{major}}.{{minor}}
          type=raw,value=latest,enable={{is_default_branch}}
          
    - name: 이미지 빌드 및 푸시
      uses: docker/build-push-action@v5
      with:
        context: .
        push: true
        tags: ${{ steps.meta.outputs.tags }}
        labels: ${{ steps.meta.outputs.labels }}
        cache-from: type=gha
        cache-to: type=gha,mode=max
        platforms: linux/amd64,linux/arm64
        
    - name: 이미지 보안 스캔
      uses: aquasecurity/trivy-action@master
      with:
        image-ref: ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:${{ github.sha }}
        format: 'sarif'
        output: 'trivy-results.sarif'
        
    - name: 보안 스캔 결과 업로드
      uses: github/codeql-action/upload-sarif@v2
      with:
        sarif_file: 'trivy-results.sarif'
```

### 🚀 3단계: VM 자동 배포

#### VM 배포 워크플로우
**.github/workflows/deploy-vm.yml**
```yaml
name: Deploy to VM

on:
  push:
    branches: [ main ]
  workflow_dispatch:
    inputs:
      environment:
        description: '배포 환경 선택'
        required: true
        default: 'staging'
        type: choice
        options:
        - staging
        - production

env:
  DEPLOY_ENV: ${{ github.ref == 'refs/heads/main' && 'production' || 'staging' }}

jobs:
  deploy-aws:
    name: AWS EC2 배포
    runs-on: ubuntu-latest
    environment: ${{ env.DEPLOY_ENV }}
    
    steps:
    - name: 코드 체크아웃
      uses: actions/checkout@v4
      
    - name: AWS 자격증명 설정
      uses: aws-actions/configure-aws-credentials@v4
      with:
        aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
        aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        aws-region: us-west-2
        
    - name: AWS EC2 배포
      uses: appleboy/ssh-action@v1.0.3
      with:
        host: ${{ secrets.AWS_HOST }}
        username: ${{ secrets.AWS_USERNAME }}
        key: ${{ secrets.AWS_SSH_KEY }}
        script: |
          # 애플리케이션 디렉토리로 이동
          cd /opt/github-actions-cicd-practice
          
          # 최신 코드 가져오기
          git pull origin main
          
          # Docker 이미지 빌드
          docker build -t github-actions-cicd-practice:latest .
          
          # 기존 컨테이너 중지
          docker-compose down
          
          # 새 컨테이너 시작
          docker-compose up -d --build
          
          # 배포 상태 확인
          docker ps
          curl -f http://localhost:3000/health || exit 1
          
    - name: 배포 상태 확인
      run: |
        echo "AWS EC2 배포 완료"
        echo "환경: ${{ env.DEPLOY_ENV }}"
        echo "시간: $(date)"

  deploy-gcp:
    name: GCP Compute Engine 배포
    runs-on: ubuntu-latest
    environment: ${{ env.DEPLOY_ENV }}
    
    steps:
    - name: 코드 체크아웃
      uses: actions/checkout@v4
      
    - name: GCP 자격증명 설정
      uses: google-github-actions/auth@v2
      with:
        credentials_json: ${{ secrets.GCP_SERVICE_ACCOUNT_KEY }}
        
    - name: GCP Compute Engine 배포
      uses: appleboy/ssh-action@v1.0.3
      with:
        host: ${{ secrets.GCP_HOST }}
        username: ${{ secrets.GCP_USERNAME }}
        key: ${{ secrets.GCP_SSH_KEY }}
        script: |
          # 애플리케이션 디렉토리로 이동
          cd /opt/github-actions-cicd-practice
          
          # 최신 코드 가져오기
          git pull origin main
          
          # Docker 이미지 빌드
          docker build -t github-actions-cicd-practice:latest .
          
          # 기존 컨테이너 중지
          docker-compose down
          
          # 새 컨테이너 시작
          docker-compose up -d --build
          
          # 배포 상태 확인
          docker ps
          curl -f http://localhost:3000/health || exit 1
          
    - name: 배포 상태 확인
      run: |
        echo "GCP Compute Engine 배포 완료"
        echo "환경: ${{ env.DEPLOY_ENV }}"
        echo "시간: $(date)"
```

---

## 🚀 Day 2: 고급 CI/CD 파이프라인

### 📋 고급 기능 구현

#### 매트릭스 빌드 및 환경별 배포
**.github/workflows/advanced-cicd.yml**
```yaml
name: Advanced CI/CD Pipeline

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]
  workflow_dispatch:
    inputs:
      cloud_provider:
        description: '클라우드 프로바이더 선택'
        required: true
        default: 'aws'
        type: choice
        options:
        - aws
        - gcp
        - both
      skill_level:
        description: '실습 난이도'
        required: true
        default: '중급'
        type: choice
        options:
        - 초급
        - 중급
        - 고급

env:
  AWS_REGION: us-west-2
  GCP_REGION: us-central1
  GCP_ZONE: us-central1-a

jobs:
  # 1. 환경 검증
  environment-check:
    name: 환경 검증
    runs-on: ubuntu-latest
    outputs:
      environment-ok: ${{ steps.check.outputs.environment-ok }}
    steps:
    - name: 코드 체크아웃
      uses: actions/checkout@v4
      
    - name: 필수 도구 설치
      run: |
        sudo apt-get update
        sudo apt-get install -y curl wget git unzip jq
        
    - name: 환경 체크
      id: check
      run: |
        # Docker 설치 확인
        if ! command -v docker &> /dev/null; then
          echo "❌ Docker가 설치되지 않았습니다."
          echo "environment-ok=false" >> $GITHUB_OUTPUT
          exit 1
        fi
        
        # AWS CLI 설치 확인
        if ! command -v aws &> /dev/null; then
          echo "❌ AWS CLI가 설치되지 않았습니다."
          echo "environment-ok=false" >> $GITHUB_OUTPUT
          exit 1
        fi
        
        # GCP CLI 설치 확인
        if ! command -v gcloud &> /dev/null; then
          echo "❌ GCP CLI가 설치되지 않았습니다."
          echo "environment-ok=false" >> $GITHUB_OUTPUT
          exit 1
        fi
        
        echo "✅ 모든 필수 도구가 설치되어 있습니다."
        echo "environment-ok=true" >> $GITHUB_OUTPUT

  # 2. 매트릭스 테스트
  matrix-test:
    name: 매트릭스 테스트
    runs-on: ubuntu-latest
    needs: environment-check
    if: ${{ needs.environment-check.outputs.environment-ok == 'true' }}
    
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
    - name: 코드 체크아웃
      uses: actions/checkout@v4
      
    - name: Node.js ${{ matrix.node-version }} 설정
      uses: actions/setup-node@v4
      with:
        node-version: ${{ matrix.node-version }}
        cache: 'npm'
        
    - name: 의존성 설치
      run: npm ci
      
    - name: 테스트 실행
      run: npm test
      
    - name: 테스트 결과 업로드
      uses: actions/upload-artifact@v4
      if: always()
      with:
        name: test-results-${{ matrix.os }}-node-${{ matrix.node-version }}
        path: test-results/
        retention-days: 30

  # 3. 조건부 배포
  conditional-deploy:
    name: 조건부 배포
    runs-on: ubuntu-latest
    needs: [environment-check, matrix-test]
    if: ${{ needs.environment-check.outputs.environment-ok == 'true' && needs.matrix-test.result == 'success' }}
    
    steps:
    - name: 코드 체크아웃
      uses: actions/checkout@v4
      
    - name: 변경사항 확인
      uses: dorny/paths-filter@v2
      id: changes
      with:
        filters: |
          frontend:
            - 'src/**'
            - 'public/**'
          backend:
            - 'src/**'
            - 'package.json'
          docs:
            - 'docs/**'
            - '*.md'
            
    - name: 프론트엔드 배포
      if: ${{ steps.changes.outputs.frontend == 'true' }}
      run: |
        echo "프론트엔드 변경사항 감지 - 프론트엔드 배포 실행"
        # 프론트엔드 배포 로직
        
    - name: 백엔드 배포
      if: ${{ steps.changes.outputs.backend == 'true' }}
      run: |
        echo "백엔드 변경사항 감지 - 백엔드 배포 실행"
        # 백엔드 배포 로직
        
    - name: 문서 배포
      if: ${{ steps.changes.outputs.docs == 'true' }}
      run: |
        echo "문서 변경사항 감지 - 문서 배포 실행"
        # 문서 배포 로직

  # 4. Kubernetes 배포
  kubernetes-deploy:
    name: Kubernetes 배포
    runs-on: ubuntu-latest
    needs: [environment-check, matrix-test]
    if: ${{ needs.environment-check.outputs.environment-ok == 'true' && needs.matrix-test.result == 'success' }}
    
    steps:
    - name: 코드 체크아웃
      uses: actions/checkout@v4
      
    - name: AWS EKS 클러스터 연결
      if: ${{ github.event.inputs.cloud_provider == 'aws' || github.event.inputs.cloud_provider == 'both' }}
      run: |
        aws eks update-kubeconfig --region ${{ env.AWS_REGION }} --name my-eks-cluster
        
    - name: GCP GKE 클러스터 연결
      if: ${{ github.event.inputs.cloud_provider == 'gcp' || github.event.inputs.cloud_provider == 'both' }}
      run: |
        gcloud container clusters get-credentials my-gke-cluster --zone ${{ env.GCP_ZONE }}
        
    - name: Kubernetes 매니페스트 적용
      run: |
        kubectl apply -f k8s/
        
    - name: 배포 상태 확인
      run: |
        kubectl get pods
        kubectl get services
        kubectl get deployments
```

### 🔧 고급 기능 구현

#### 환경별 설정 관리
**.github/workflows/environment-deploy.yml**
```yaml
name: Environment Deployment

on:
  push:
    branches: [ main, develop ]
  workflow_dispatch:
    inputs:
      environment:
        description: '배포 환경 선택'
        required: true
        default: 'staging'
        type: choice
        options:
        - staging
        - production

env:
  DEPLOY_ENV: ${{ github.ref == 'refs/heads/main' && 'production' || 'staging' }}

jobs:
  deploy:
    name: ${{ env.DEPLOY_ENV }} 환경 배포
    runs-on: ubuntu-latest
    environment: ${{ env.DEPLOY_ENV }}
    
    steps:
    - name: 코드 체크아웃
      uses: actions/checkout@v4
      
    - name: 환경별 설정 적용
      run: |
        if [ "${{ env.DEPLOY_ENV }}" = "production" ]; then
          echo "PRODUCTION 환경 설정 적용"
          export NODE_ENV=production
          export LOG_LEVEL=warn
        else
          echo "STAGING 환경 설정 적용"
          export NODE_ENV=staging
          export LOG_LEVEL=debug
        fi
        
    - name: 환경별 배포 실행
      run: |
        echo "배포 환경: ${{ env.DEPLOY_ENV }}"
        echo "Node 환경: $NODE_ENV"
        echo "로그 레벨: $LOG_LEVEL"
        # 실제 배포 로직
```

---

## 🚀 Day 3: 모니터링 및 최적화

### 📊 모니터링 시스템 구축

#### 모니터링 워크플로우
**.github/workflows/monitoring.yml**
```yaml
name: Monitoring and Optimization

on:
  schedule:
    # 매일 오전 9시에 모니터링 실행
    - cron: '0 9 * * *'
  workflow_dispatch:
    inputs:
      monitoring_type:
        description: '모니터링 유형 선택'
        required: true
        default: 'full'
        type: choice
        options:
        - full
        - basic
        - security

jobs:
  # 1. 애플리케이션 모니터링
  app-monitoring:
    name: 애플리케이션 모니터링
    runs-on: ubuntu-latest
    
    steps:
    - name: 코드 체크아웃
      uses: actions/checkout@v4
      
    - name: 애플리케이션 상태 확인
      run: |
        # AWS EC2 상태 확인
        aws ec2 describe-instances --query 'Reservations[*].Instances[*].[InstanceId,State.Name,PublicIpAddress]' --output table
        
        # GCP Compute Engine 상태 확인
        gcloud compute instances list --format="table(name,zone,machineType,status)"
        
    - name: 애플리케이션 헬스 체크
      run: |
        # AWS 애플리케이션 헬스 체크
        curl -f http://${{ secrets.AWS_HOST }}/health || echo "AWS 애플리케이션 상태 확인 실패"
        
        # GCP 애플리케이션 헬스 체크
        curl -f http://${{ secrets.GCP_HOST }}/health || echo "GCP 애플리케이션 상태 확인 실패"

  # 2. 보안 모니터링
  security-monitoring:
    name: 보안 모니터링
    runs-on: ubuntu-latest
    
    steps:
    - name: 코드 체크아웃
      uses: actions/checkout@v4
      
    - name: 보안 취약점 스캔
      run: |
        # 의존성 보안 스캔
        npm audit --audit-level moderate
        
        # Docker 이미지 보안 스캔
        docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
          aquasec/trivy image github-actions-cicd-practice:latest
        
    - name: AWS 보안 스캔
      run: |
        # AWS Inspector 스캔
        aws inspector list-assessment-templates
        
    - name: GCP 보안 스캔
      run: |
        # GCP Security Command Center 스캔
        gcloud scc sources list

  # 3. 비용 최적화
  cost-optimization:
    name: 비용 최적화
    runs-on: ubuntu-latest
    
    steps:
    - name: 코드 체크아웃
      uses: actions/checkout@v4
      
    - name: AWS 비용 분석
      run: |
        # AWS Cost Explorer 사용
        aws ce get-cost-and-usage \
          --time-period Start=2024-01-01,End=2024-01-31 \
          --granularity MONTHLY \
          --metrics BlendedCost
          
    - name: GCP 비용 분석
      run: |
        # GCP 청구서 정보 조회
        gcloud billing accounts list
        
    - name: 비용 최적화 권장사항
      run: |
        echo "비용 최적화 권장사항:"
        echo "1. 사용하지 않는 리소스 정리"
        echo "2. 인스턴스 크기 최적화"
        echo "3. 예약 인스턴스 사용 고려"

  # 4. 성능 모니터링
  performance-monitoring:
    name: 성능 모니터링
    runs-on: ubuntu-latest
    
    steps:
    - name: 코드 체크아웃
      uses: actions/checkout@v4
      
    - name: 애플리케이션 성능 테스트
      run: |
        # 부하 테스트 실행
        npm install -g artillery
        artillery quick --count 10 --num 5 http://${{ secrets.AWS_HOST }}/
        
    - name: 데이터베이스 성능 확인
      run: |
        # 데이터베이스 연결 상태 확인
        echo "데이터베이스 성능 모니터링 완료"
        
    - name: 네트워크 성능 확인
      run: |
        # 네트워크 지연시간 측정
        ping -c 5 ${{ secrets.AWS_HOST }}
        ping -c 5 ${{ secrets.GCP_HOST }}

  # 5. 알림 및 보고서
  notification:
    name: 알림 및 보고서
    runs-on: ubuntu-latest
    needs: [app-monitoring, security-monitoring, cost-optimization, performance-monitoring]
    if: always()
    
    steps:
    - name: 모니터링 결과 수집
      run: |
        echo "모니터링 결과 수집 중..."
        
    - name: Slack 알림 전송
      if: ${{ secrets.SLACK_WEBHOOK_URL }}
      uses: 8398a7/action-slack@v3
      with:
        status: ${{ job.status }}
        channel: '#monitoring'
        text: |
          GitHub Actions CI/CD 모니터링 완료
          - 애플리케이션 모니터링: ${{ needs.app-monitoring.result }}
          - 보안 모니터링: ${{ needs.security-monitoring.result }}
          - 비용 최적화: ${{ needs.cost-optimization.result }}
          - 성능 모니터링: ${{ needs.performance-monitoring.result }}
          
    - name: 이메일 보고서 전송
      if: ${{ secrets.EMAIL_NOTIFICATION }}
      uses: dawidd6/action-send-mail@v3
      with:
        server_address: smtp.gmail.com
        server_port: 587
        username: ${{ secrets.EMAIL_USERNAME }}
        password: ${{ secrets.EMAIL_PASSWORD }}
        subject: GitHub Actions CI/CD 모니터링 보고서
        to: ${{ secrets.EMAIL_NOTIFICATION }}
        from: GitHub Actions
        body: |
          GitHub Actions CI/CD 모니터링이 완료되었습니다.
          
          결과:
          - 애플리케이션 모니터링: ${{ needs.app-monitoring.result }}
          - 보안 모니터링: ${{ needs.security-monitoring.result }}
          - 비용 최적화: ${{ needs.cost-optimization.result }}
          - 성능 모니터링: ${{ needs.performance-monitoring.result }}
```

---

## 🧪 실습 완료 체크리스트

### Day 1: 기본 CI/CD
- [ ] GitHub Actions 워크플로우 생성
- [ ] Docker 이미지 자동 빌드
- [ ] VM 자동 배포
- [ ] 기본 테스트 및 린팅

### Day 2: 고급 CI/CD
- [ ] 매트릭스 빌드 구현
- [ ] 환경별 배포 설정
- [ ] Kubernetes 자동 배포
- [ ] 조건부 실행 설정

### Day 3: 모니터링 & 최적화
- [ ] 애플리케이션 모니터링
- [ ] 보안 스캔 설정
- [ ] 비용 최적화 분석
- [ ] 성능 모니터링

---

## 📚 참고 자료

### 공식 문서
- [GitHub Actions 공식 문서](https://docs.github.com/ko/actions)
- [Docker 공식 문서](https://docs.docker.com/)
- [Kubernetes 공식 문서](https://kubernetes.io/docs/)
- [AWS 공식 문서](https://docs.aws.amazon.com/)
- [GCP 공식 문서](https://cloud.google.com/docs)

### 추가 학습 자료
- [GitHub Actions Marketplace](https://github.com/marketplace?type=actions)
- [Docker Hub](https://hub.docker.com/)
- [Kubernetes 예제](https://kubernetes.io/examples/)
- [AWS 예제](https://github.com/aws-samples)
- [GCP 예제](https://github.com/GoogleCloudPlatform)

---

<div align="center">

[← 이전: GitHub Actions 기초 실습](github-actions-basics.md) | 
[📚 전체 커리큘럼](../../../curriculum.md) | 
[🏠 학습 경로로 돌아가기](../../../index.md) | 
[다음: VM 배포 실습 →](vm-deployment.md)

</div>
