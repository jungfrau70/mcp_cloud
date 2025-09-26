# 🔄 CI/CD 파이프라인

## 🎯 학습 목표

### 핵심 학습 목표
- **GitHub Actions 고급** 환경별 배포 전략, 매트릭스 빌드, 워크플로우 재사용
- **자동화된 Docker 이미지 빌드** 이미지 태깅, 보안 스캔, 자동 푸시

### 실습 후 달성할 수 있는 능력
- ✅ GitHub Actions를 활용한 완전 자동화된 CI/CD 파이프라인 구축
- ✅ 환경별 자동 배포 전략 구현
- ✅ Docker 이미지 자동 빌드, 보안 스캔, 푸시 자동화

### 예상 소요 시간
- **GitHub Actions 고급**: 90-120분
- **자동화된 Docker 이미지 빌드**: 60-90분
- **전체 과정**: 2.5-3.5시간

---

## 🛠️ 실습 학습

### 📁 실습 코드 및 자동화
- **실습 코드**: `./cloud_intermediate/samples/day2/cicd-pipeline/`
- **자동화 스크립트**: `./cloud_intermediate/scripts/cicd-pipeline-practice.sh`
- **클라우드 스크립트**: `./cloud_intermediate/cloud-scripts/`

<details>
<summary>🚀 실습 환경 준비</summary>

#### 필수 도구
- **GitHub 계정**: 코드 저장소 및 CI/CD
- **Docker Hub 계정**: 컨테이너 이미지 저장소
- **AWS CLI**: AWS 서비스 관리
- **GCP CLI**: GCP 서비스 관리

#### 환경 설정
```bash
# GitHub CLI 설치 확인
gh --version

# Docker Hub 로그인
docker login

# AWS CLI 설정 확인
aws --version
aws configure list

# GCP CLI 설정 확인
gcloud --version
gcloud auth list
```

</details>

<details>
<summary>🔧 1단계: GitHub Actions 고급 워크플로우</summary>

#### 기본 CI/CD 워크플로우
```yaml
# .github/workflows/ci-cd.yml
name: CI/CD Pipeline

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
        cache: 'npm'
    
    - name: Install dependencies
      run: npm ci
    
    - name: Run tests
      run: npm test
    
    - name: Run linting
      run: npm run lint

  build-and-deploy:
    needs: test
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Build Docker image
      run: |
        docker build -t ${{ secrets.DOCKER_USERNAME }}/myapp:${{ github.sha }} .
        docker build -t ${{ secrets.DOCKER_USERNAME }}/myapp:latest .
    
    - name: Push to Docker Hub
      run: |
        echo ${{ secrets.DOCKER_PASSWORD }} | docker login -u ${{ secrets.DOCKER_USERNAME }} --password-stdin
        docker push ${{ secrets.DOCKER_USERNAME }}/myapp:${{ github.sha }}
        docker push ${{ secrets.DOCKER_USERNAME }}/myapp:latest
    
    - name: Deploy to AWS ECS
      run: |
        aws ecs update-service --cluster my-cluster --service my-service --force-new-deployment
    
    - name: Deploy to GCP Cloud Run
      run: |
        gcloud run deploy myapp --image gcr.io/${{ secrets.GCP_PROJECT_ID }}/myapp:${{ github.sha }} --region us-central1
```

#### 고급 워크플로우 ["환경별 배포"]
```yaml
# .github/workflows/advanced-ci-cd.yml
name: Advanced CI/CD Pipeline

on:
  push:
    branches: [ main, develop, staging ]
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
    
    - name: Run tests
      run: npm test
    
    - name: Run linting
      run: npm run lint
    
    - name: Run security audit
      run: npm audit --audit-level moderate

  build:
    needs: test
    runs-on: ubuntu-latest
    outputs:
      image: ${{ steps.image.outputs.image }}
      digest: ${{ steps.build.outputs.digest }}
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
      id: build
      uses: docker/build-push-action@v4
      with:
        context: .
        push: true
        tags: ${{ steps.meta.outputs.tags }}
        labels: ${{ steps.meta.outputs.labels }}
        cache-from: type=gha
        cache-to: type=gha,mode=max
    
    - name: Output image
      id: image
      run: echo "image=${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:${{ github.sha }}" >> $GITHUB_OUTPUT

  security-scan:
    needs: build
    runs-on: ubuntu-latest
    steps:
    - name: Run Trivy vulnerability scanner
      uses: aquasecurity/trivy-action@master
      with:
        image-ref: ${{ needs.build.outputs.image }}
        format: 'sarif'
        output: 'trivy-results.sarif'
    
    - name: Upload Trivy scan results to GitHub Security tab
      uses: github/codeql-action/upload-sarif@v2
      with:
        sarif_file: 'trivy-results.sarif'

  deploy-staging:
    needs: [build, security-scan]
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/develop'
    environment: staging
    steps:
    - name: Deploy to Staging
      run: |
        echo "Deploying to staging environment"
        # Add your staging deployment commands here

  deploy-production:
    needs: [build, security-scan]
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    environment: production
    steps:
    - name: Deploy to Production
      run: |
        echo "Deploying to production environment"
        # Add your production deployment commands here
```

</details>

<details>
<summary>🔧 2단계: 자동화된 Docker 이미지 빌드</summary>

#### Dockerfile 최적화
```dockerfile
# Dockerfile
FROM node:18-alpine AS builder
WORKDIR /app

# 의존성 파일만 먼저 복사 ["캐시 최적화"]
COPY package*.json ./
RUN npm ci --only=production && npm cache clean --force

# 애플리케이션 코드 복사
COPY . .

# 프로덕션 이미지
FROM node:18-alpine AS runtime
WORKDIR /app

# 보안을 위한 non-root 사용자 생성
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nextjs -u 1001

# 빌드된 파일만 복사
COPY --from=builder --chown=nextjs:nodejs /app/node_modules ./node_modules
COPY --from=builder --chown=nextjs:nodejs /app ./

USER nextjs
EXPOSE 3000
CMD ["npm", "start"]
```

#### 이미지 빌드 및 푸시 자동화
```bash
# 이미지 빌드 스크립트
#!/bin/bash
set -e

# 환경 변수 설정
IMAGE_NAME="myapp"
REGISTRY="ghcr.io"
TAG="${GITHUB_SHA:-latest}"

# 이미지 빌드
docker build -t ${REGISTRY}/${IMAGE_NAME}:${TAG} .
docker build -t ${REGISTRY}/${IMAGE_NAME}:latest .

# 이미지 푸시
docker push ${REGISTRY}/${IMAGE_NAME}:${TAG}
docker push ${REGISTRY}/${IMAGE_NAME}:latest

echo "Successfully built and pushed ${REGISTRY}/${IMAGE_NAME}:${TAG}"
```

#### 보안 스캔 통합
```yaml
# .github/workflows/security-scan.yml
name: Security Scan

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  security-scan:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    
    - name: Build Docker image
      run: |
        docker build -t myapp:latest .
    
    - name: Run Trivy vulnerability scanner
      uses: aquasecurity/trivy-action@master
      with:
        image-ref: 'myapp:latest'
        format: 'sarif'
        output: 'trivy-results.sarif'
    
    - name: Upload Trivy scan results to GitHub Security tab
      uses: github/codeql-action/upload-sarif@v2
      with:
        sarif_file: 'trivy-results.sarif'
    
    - name: Run Snyk to check for vulnerabilities
      uses: snyk/actions/docker@master
      env:
        SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}
      with:
        image: myapp:latest
        args: --severity-threshold=high
```

</details>

<details>
<summary>🔧 3단계: 환경별 배포 전략</summary>

#### Blue-Green 배포
```yaml
# .github/workflows/blue-green-deployment.yml
name: Blue-Green Deployment

on:
  push:
    branches: [ main ]

jobs:
  blue-green-deploy:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    
    - name: Build Docker image
      run: |
        docker build -t myapp:${{ github.sha }} .
    
    - name: Deploy to Blue environment
      run: |
        # Blue 환경에 배포
        kubectl apply -f k8s/blue-deployment.yaml
        kubectl apply -f k8s/blue-service.yaml
        
        # Blue 환경 헬스 체크
        kubectl wait --for=condition=available --timeout=300s deployment/myapp-blue
    
    - name: Switch traffic to Blue
      run: |
        # 트래픽을 Blue 환경으로 전환
        kubectl patch service myapp-service -p '{"spec":{"selector":{"version":"blue"}}}'
    
    - name: Cleanup Green environment
      run: |
        # Green 환경 정리
        kubectl delete -f k8s/green-deployment.yaml
        kubectl delete -f k8s/green-service.yaml
```

#### Canary 배포
```yaml
# .github/workflows/canary-deployment.yml
name: Canary Deployment

on:
  push:
    branches: [ main ]

jobs:
  canary-deploy:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    
    - name: Build Docker image
      run: |
        docker build -t myapp:${{ github.sha }} .
    
    - name: Deploy Canary
      run: |
        # Canary 배포 ["10% 트래픽"]
        kubectl apply -f k8s/canary-deployment.yaml
        kubectl apply -f k8s/canary-service.yaml
        
        # Canary 헬스 체크
        kubectl wait --for=condition=available --timeout=300s deployment/myapp-canary
    
    - name: Monitor Canary
      run: |
        # Canary 모니터링 ["5분간"]
        sleep 300
        
        # 메트릭 확인
        kubectl top pods -l app=myapp,version=canary
    
    - name: Promote to Production
      run: |
        # Canary를 프로덕션으로 승격
        kubectl patch service myapp-service -p '{"spec":{"selector":{"version":"canary"}}}'
        
        # 기존 프로덕션 정리
        kubectl delete -f k8s/production-deployment.yaml
```

#### A/B 테스트
```yaml
# .github/workflows/ab-test-deployment.yml
name: A/B Test Deployment

on:
  push:
    branches: [ main ]

jobs:
  ab-test-deploy:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    
    - name: Build Docker image
      run: |
        docker build -t myapp:${{ github.sha }} .
    
    - name: Deploy A/B Test
      run: |
        # A 버전 배포 ["50% 트래픽"]
        kubectl apply -f k8s/version-a-deployment.yaml
        kubectl apply -f k8s/version-a-service.yaml
        
        # B 버전 배포 ["50% 트래픽"]
        kubectl apply -f k8s/version-b-deployment.yaml
        kubectl apply -f k8s/version-b-service.yaml
        
        # 트래픽 분할 설정
        kubectl apply -f k8s/ab-test-service.yaml
    
    - name: Monitor A/B Test
      run: |
        # A/B 테스트 모니터링 ["10분간"]
        sleep 600
        
        # 메트릭 수집 및 분석
        kubectl top pods -l app=myapp,version=a
        kubectl top pods -l app=myapp,version=b
```

</details>

---

## 📚 참고 자료

### 유용한 명령어
```bash
# GitHub Actions 명령어
gh workflow list  # 워크플로우 목록
gh run list  # 실행 기록
gh run view <run-id>  # 실행 상세 정보
gh run rerun <run-id>  # 실행 재시작

# Docker 명령어
docker buildx build --platform linux/amd64,linux/arm64 -t myapp:latest .  # 멀티 아키텍처 빌드
docker buildx imagetools inspect myapp:latest  # 이미지 상세 정보
docker buildx prune  # 빌드 캐시 정리

# Kubernetes 명령어
kubectl rollout status deployment/myapp  # 배포 상태 확인
kubectl rollout undo deployment/myapp  # 배포 롤백
kubectl scale deployment myapp --replicas=3  # 스케일링
```

### 문제 해결
1. **GitHub Actions 워크플로우 실패**
   - 시크릿 설정 확인
   - 권한 설정 확인
   - 워크플로우 문법 확인
   - 리소스 할당량 확인

2. **Docker 이미지 빌드 실패**
   - Dockerfile 문법 확인
   - 베이스 이미지 존재 여부 확인
   - 네트워크 연결 상태 확인
   - 빌드 컨텍스트 확인

3. **배포 실패**
   - 클러스터 연결 상태 확인
   - 리소스 제한 확인
   - 네트워크 정책 확인
   - 권한 설정 확인

---

## 🧹 실습 정리

### 자동 정리
```bash
# CI/CD 파이프라인 실습 자동 정리
./cloud_intermediate/scripts/cicd-pipeline-practice.sh --cleanup
```

### 수동 정리
```bash
# GitHub Actions 워크플로우 정리
rm -rf .github/workflows/

# Docker 이미지 정리
docker rmi myapp:latest myapp:$GITHUB_SHA

# Kubernetes 리소스 정리
kubectl delete -f k8s/

# 시크릿 정리
gh secret delete DOCKER_USERNAME
gh secret delete DOCKER_PASSWORD
gh secret delete GCP_PROJECT_ID
```

### 정리 확인
- [ ] GitHub Actions 워크플로우 정리 완료
- [ ] Docker 이미지 정리 완료
- [ ] Kubernetes 리소스 정리 완료
- [ ] 시크릿 정리 완료

---

## 🔗 관련 자료

### 📚 실습 가이드
- ["클라우드 배포"](cloud-deployment.md)
- ["모니터링 기초"](monitoring-basics.md)

### 🛠️ 설치 가이드
- ["GitHub CLI 설치"][_setup_wsl/install-github-cli-wsl.sh]
- ["Docker Desktop 설치"][_setup_wsl/install-docker-wsl.sh]

### 🏠 네비게이션
<div align="center">

["← 이전: Day 1"](../Day1/README.md) | 
["📚 전체 커리큘럼"](../../../curriculum.md) | 
["🏠 학습 경로로 돌아가기"](../../../index.md) | 
["다음: 클라우드 배포 →"](cloud-deployment.md)

</div>
