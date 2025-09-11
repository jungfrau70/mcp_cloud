# Cloud Master - 1일차: Docker, Git/GitHub, GitHub Actions 기초

<details>
<summary>📋 목차</summary>

1. [🎯 학습 목표](#-학습-목표)
2. [📚 실습 가이드](#-실습-가이드)
3. [🔧 실습 환경 준비](#-실습-환경-준비)
4. [🐳 Docker 기초 및 컨테이너 기술](#-docker-기초-및-컨테이너-기술)
5. [📝 Git/GitHub 기초 및 협업](#-gitgithub-기초-및-협업)
6. [🚀 GitHub Actions CI/CD 파이프라인](#-github-actions-cicd-파이프라인)
7. [☁️ VM 기반 웹 애플리케이션 배포](#-vm-기반-웹-애플리케이션-배포)
8. [📚 문제 해결 및 참고 자료](#-문제-해결-및-참고-자료)

</details>

---

## 🎯 학습 목표

<details>
<summary>📖 이번 실습에서 배우게 될 내용</summary>

### 핵심 학습 목표
- **Docker 기초** 컨테이너 개념 및 Dockerfile 작성
- **Git/GitHub 기초** 버전 관리 및 협업 도구 사용법
- **GitHub Actions 기초** CI/CD 파이프라인 구축
- **VM 배포** AWS EC2, GCP Compute Engine 웹 애플리케이션 배포

### 실습 후 달성할 수 있는 능력
- ✅ Docker를 활용한 웹 애플리케이션 컨테이너화
- ✅ Git/GitHub을 통한 버전 관리 및 협업
- ✅ GitHub Actions로 기본 CI/CD 파이프라인 구축
- ✅ VM 기반 웹 애플리케이션 배포 및 기본 운영

### 예상 소요 시간
- **Docker 기초**: 90-120분
- **Git/GitHub 기초**: 60-90분
- **GitHub Actions 기초**: 90-120분
- **VM 배포**: 90-120분
- **전체 과정**: 6-8시간

</details>

---

## 📚 실습 가이드

<details>
<summary>📖 실습 가이드 개요</summary>

### 실습 구성
1. **Docker 기초 및 컨테이너 기술** (120분)
2. **Git/GitHub 기초 및 협업** (90분)
3. **GitHub Actions CI/CD 파이프라인** (120분)
4. **VM 기반 웹 애플리케이션 배포** (120분)

### 실습 방식
- **Docker 기초**: 컨테이너 개념, Dockerfile 작성, Docker Compose
- **Git/GitHub 기초**: 버전 관리, 브랜치 전략, Pull Request
- **GitHub Actions 기초**: 워크플로우 작성, 자동 빌드/배포
- **VM 배포**: AWS EC2, GCP Compute Engine 웹 애플리케이션 배포

### 실습 결과물
- 컨테이너화된 웹 애플리케이션
- Git/GitHub 저장소 및 협업 환경
- GitHub Actions CI/CD 파이프라인
- VM에 배포된 웹 애플리케이션

</details>

<details>
<summary>🔗 관련 실습 가이드</summary>

### 📖 상세 실습 가이드
- 🔗 [Docker 고급 실습](docker-advanced-guide.md)
- 🔗 [GitHub Actions 고급 실습](github-actions-guide.md)
- 🔗 [VM 배포 자동화](aws-gcp-deployment-guide.md)

### 📚 개념 학습 가이드
- 🔗 [Docker 최적화 가이드](docker-advanced-guide.md)
- 🔗 [GitHub Actions 고급 가이드](github-actions-guide.md)
- 🔗 [VM 배포 전략 가이드](aws-gcp-deployment-guide.md)

### 🛠️ 문제 해결 가이드
- 🔗 [종합 트러블슈팅 가이드](troubleshooting-guide.md)

### 🔗 관련 과정 링크
- 🔗 [Cloud Master 과정](../../../cloud_master/textbook/Day1/README.md)
- 🔗 [Cloud Master 2일차](../Day2/README.md)
- 🔗 [Cloud Container 과정](../../../cloud_container/textbook/Day1/README.md)
- 🔗 [전체 커리큘럼](../../../curriculum.md)

</details>

---

## 🔧 실습 환경 준비

<details>
<summary>📋 필수 계정 및 도구</summary>

### 필수 계정
- **GitHub 계정**: 고급 Actions 사용
- **Docker Hub 계정**: 이미지 저장소
- **AWS 계정**: EC2 인스턴스 배포용
- **GCP 계정**: Compute Engine 배포용

### 필수 도구
- **Docker**: 고급 컨테이너 기술
- **Git**: 버전 관리
- **Node.js**: 웹 애플리케이션 개발
- **VS Code**: 코드 편집 (권장)

</details>

<details>
<summary>🔧 고급 환경 설정</summary>

### Docker 고급 설정
```bash
# Docker Buildx 활성화
docker buildx create --name mybuilder --use

# 멀티 플랫폼 빌드 확인
docker buildx inspect --bootstrap

# Docker Compose V2 사용
docker compose version
```

### GitHub Actions 고급 설정
```bash
# GitHub CLI 설치
winget install GitHub.cli

# GitHub CLI 인증
gh auth login

# 워크플로우 실행
gh workflow run "CI Pipeline"
```

</details>

---

## 🐳 Docker 기초 및 Dockerfile 최적화

<details>
<summary>📖 Docker 고급 개념</summary>

### Docker 최적화 원칙
- **레이어 최소화**: RUN 명령어 통합
- **캐시 활용**: 자주 변경되지 않는 레이어를 위에 배치
- **멀티스테이지 빌드**: 빌드 도구와 실행 환경 분리
- **보안**: 비루트 사용자, 최소 권한

### Docker 이미지 크기 최적화
| 기법 | 설명 | 효과 |
|------|------|------|
| **Alpine Linux** | 경량 리눅스 배포판 | 50-80% 크기 감소 |
| **멀티스테이지 빌드** | 빌드 도구 제거 | 60-90% 크기 감소 |
| **레이어 통합** | RUN 명령어 통합 | 10-20% 크기 감소 |
| **불필요한 파일 제거** | .git, node_modules 등 | 20-40% 크기 감소 |

</details>

<details>
<summary>🔗 Dockerfile 최적화</summary>

### 기본 Dockerfile (비최적화)
```dockerfile
FROM node:18
WORKDIR /app
COPY . .
RUN npm install
RUN npm run build
EXPOSE 3000
CMD ["npm", "start"]
```

### 최적화된 Dockerfile
```dockerfile
# 멀티스테이지 빌드
FROM node:18-alpine AS builder

# 빌드 환경 설정
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production && npm cache clean --force

# 소스 코드 복사 및 빌드
COPY . .
RUN npm run build

# 실행 환경
FROM node:18-alpine AS runtime

# 보안 설정
RUN addgroup -g 1001 -S nodejs
RUN adduser -S nextjs -u 1001

# 애플리케이션 복사
WORKDIR /app
COPY --from=builder --chown=nextjs:nodejs /app/dist ./dist
COPY --from=builder --chown=nextjs:nodejs /app/node_modules ./node_modules
COPY --from=builder --chown=nextjs:nodejs /app/package*.json ./

# 포트 노출
EXPOSE 3000

# 비루트 사용자로 실행
USER nextjs

# 헬스체크
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:3000/health || exit 1

# 애플리케이션 실행
CMD ["npm", "start"]
```

</details>

<details>
<summary>🔗 Docker Compose 고급 설정</summary>

### docker-compose.yml (고급)
```yaml
version: '3.8'

services:
  web:
    build:
      context: .
      dockerfile: Dockerfile
      target: runtime
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=production
      - DATABASE_URL=postgresql://user:password@db:5432/myapp
    depends_on:
      db:
        condition: service_healthy
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
    networks:
      - app-network

  db:
    image: postgres:13-alpine
    environment:
      - POSTGRES_DB=myapp
      - POSTGRES_USER=user
      - POSTGRES_PASSWORD=password
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./init.sql:/docker-entrypoint-initdb.d/init.sql
    restart: unless-stopped
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U user -d myapp"]
      interval: 10s
      timeout: 5s
      retries: 5
    networks:
      - app-network

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
    networks:
      - app-network

  redis:
    image: redis:6-alpine
    command: redis-server --appendonly yes
    volumes:
      - redis_data:/data
    restart: unless-stopped
    networks:
      - app-network

volumes:
  postgres_data:
  redis_data:

networks:
  app-network:
    driver: bridge
```

</details>

---

## 🚀 GitHub Actions CI/CD 파이프라인

<details>
<summary>📖 GitHub Actions 고급 개념</summary>

### 고급 워크플로우 패턴
- **매트릭스 빌드**: 여러 환경에서 동시 테스트
- **조건부 실행**: 브랜치, 파일 변경에 따른 실행
- **환경별 배포**: Dev, Staging, Production 분리
- **의존성 관리**: Job 간 의존성 및 순서 제어

### 워크플로우 최적화
| 기법 | 설명 | 효과 |
|------|------|------|
| **캐시 활용** | npm, Docker 레이어 캐시 | 50-80% 빌드 시간 단축 |
| **병렬 실행** | 독립적인 Job 병렬 실행 | 30-50% 전체 시간 단축 |
| **조건부 실행** | 필요한 경우만 실행 | 20-40% 리소스 절약 |
| **아티팩트 공유** | Job 간 파일 공유 | 10-20% 중복 작업 제거 |

</details>

<details>
<summary>🔗 고급 워크플로우 작성</summary>

### .github/workflows/ci-cd-advanced.yml
```yaml
name: Advanced CI/CD Pipeline

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]
  release:
    types: [ published ]

env:
  NODE_VERSION: '18'
  DOCKER_IMAGE: ${{ secrets.DOCKERHUB_USERNAME }}/my-app
  DOCKER_TAG: ${{ github.sha }}

jobs:
  # 테스트 Job
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
      
    - name: Run security audit
      run: npm audit --audit-level moderate
      
    - name: Upload coverage reports
      uses: codecov/codecov-action@v3
      with:
        file: ./coverage/lcov.info

  # 빌드 Job
  build:
    needs: test
    runs-on: ubuntu-latest
    outputs:
      image-digest: ${{ steps.build.outputs.digest }}
      
    steps:
    - name: Checkout code
      uses: actions/checkout@v4
      
    - name: Set up Docker Buildx
      uses: docker/setup-buildx-action@v3
      
    - name: Login to Docker Hub
      uses: docker/login-action@v3
      with:
        username: ${{ secrets.DOCKERHUB_USERNAME }}
        password: ${{ secrets.DOCKERHUB_TOKEN }}
        
    - name: Extract metadata
      id: meta
      uses: docker/metadata-action@v5
      with:
        images: ${{ env.DOCKER_IMAGE }}
        tags: |
          type=ref,event=branch
          type=ref,event=pr
          type=semver,pattern={{version}}
          type=raw,value=latest,enable={{is_default_branch}}
          
    - name: Build and push
      id: build
      uses: docker/build-push-action@v5
      with:
        context: .
        platforms: linux/amd64,linux/arm64
        push: true
        tags: ${{ steps.meta.outputs.tags }}
        labels: ${{ steps.meta.outputs.labels }}
        cache-from: type=gha
        cache-to: type=gha,mode=max
        build-args: |
          NODE_ENV=production
          BUILD_DATE=${{ github.event.head_commit.timestamp }}

  # 보안 스캔 Job
  security-scan:
    needs: build
    runs-on: ubuntu-latest
    if: github.event_name == 'pull_request'
    
    steps:
    - name: Run Trivy vulnerability scanner
      uses: aquasecurity/trivy-action@master
      with:
        image-ref: ${{ env.DOCKER_IMAGE }}:${{ github.sha }}
        format: 'sarif'
        output: 'trivy-results.sarif'
        
    - name: Upload Trivy scan results
      uses: github/codeql-action/upload-sarif@v2
      with:
        sarif_file: 'trivy-results.sarif'

  # 배포 Job (Staging)
  deploy-staging:
    needs: build
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/develop'
    environment: staging
    
    steps:
    - name: Deploy to Staging
      uses: appleboy/ssh-action@v1.0.0
      with:
        host: ${{ secrets.STAGING_HOST }}
        username: ${{ secrets.STAGING_USERNAME }}
        key: ${{ secrets.STAGING_SSH_KEY }}
        script: |
          docker pull ${{ env.DOCKER_IMAGE }}:${{ github.sha }}
          docker stop my-app-staging || true
          docker rm my-app-staging || true
          docker run -d -p 3000:3000 --name my-app-staging ${{ env.DOCKER_IMAGE }}:${{ github.sha }}

  # 배포 Job (Production)
  deploy-production:
    needs: [build, security-scan]
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    environment: production
    
    steps:
    - name: Deploy to Production
      uses: appleboy/ssh-action@v1.0.0
      with:
        host: ${{ secrets.PRODUCTION_HOST }}
        username: ${{ secrets.PRODUCTION_USERNAME }}
        key: ${{ secrets.PRODUCTION_SSH_KEY }}
        script: |
          docker pull ${{ env.DOCKER_IMAGE }}:${{ github.sha }}
          docker stop my-app-production || true
          docker rm my-app-production || true
          docker run -d -p 80:3000 --name my-app-production ${{ env.DOCKER_IMAGE }}:${{ github.sha }}
          
    - name: Notify deployment success
      uses: 8398a7/action-slack@v3
      with:
        status: success
        text: 'Production deployment successful!'
      env:
        SLACK_WEBHOOK_URL: ${{ secrets.SLACK_WEBHOOK_URL }}
```

</details>

---

## ☁️ VM 기반 컨테이너 배포

<details>
<summary>📖 VM 배포 전략</summary>

### 배포 아키텍처
- **Blue-Green 배포**: 무중단 배포
- **롤링 배포**: 점진적 업데이트
- **Canary 배포**: 일부 트래픽으로 테스트
- **A/B 테스트**: 다른 버전 비교

### 배포 환경 구성
| 환경 | 목적 | 특징 |
|------|------|------|
| **Development** | 개발 | 자동 배포, 디버깅 |
| **Staging** | 테스트 | 프로덕션과 동일 |
| **Production** | 운영 | 안정성, 모니터링 |

</details>

<details>
<summary>🔗 AWS EC2 고급 배포</summary>

### EC2 인스턴스 자동 생성
```bash
# EC2 인스턴스 생성 스크립트
#!/bin/bash

# 변수 설정
INSTANCE_TYPE="t3.medium"
AMI_ID="ami-0ae2c887094315bed"
KEY_NAME="student-key"
SECURITY_GROUP_ID="sg-xxxxxxxx"
SUBNET_ID="subnet-xxxxxxxx"

# 인스턴스 생성
INSTANCE_ID=$(aws ec2 run-instances \
    --image-id $AMI_ID \
    --count 1 \
    --instance-type $INSTANCE_TYPE \
    --key-name $KEY_NAME \
    --security-group-ids $SECURITY_GROUP_ID \
    --subnet-id $SUBNET_ID \
    --user-data file://user-data.sh \
    --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=my-app},{Key=Environment,Value=production}]' \
    --query 'Instances[0].InstanceId' \
    --output text)

echo "Instance ID: $INSTANCE_ID"

# 인스턴스 상태 확인
aws ec2 wait instance-running --instance-ids $INSTANCE_ID

# 퍼블릭 IP 조회
PUBLIC_IP=$(aws ec2 describe-instances \
    --instance-ids $INSTANCE_ID \
    --query 'Reservations[0].Instances[0].PublicIpAddress' \
    --output text)

echo "Public IP: $PUBLIC_IP"
```

### Docker 설치 및 설정 (user-data.sh)
```bash
#!/bin/bash

# 시스템 업데이트
yum update -y

# Docker 설치
yum install -y docker
systemctl start docker
systemctl enable docker
usermod -a -G docker ec2-user

# Docker Compose 설치
curl -L "https://github.com/docker/compose/releases/download/v2.20.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Nginx 설치
yum install -y nginx
systemctl start nginx
systemctl enable nginx

# 방화벽 설정
firewall-cmd --permanent --add-port=80/tcp
firewall-cmd --permanent --add-port=443/tcp
firewall-cmd --reload

# 애플리케이션 디렉토리 생성
mkdir -p /opt/my-app
cd /opt/my-app

# Docker Compose 파일 생성
cat > docker-compose.yml << 'EOF'
version: '3.8'
services:
  web:
    image: your-username/my-app:latest
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=production
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
EOF

# 애플리케이션 시작
docker-compose up -d
```

</details>

---

## ⚙️ 완전 자동화된 VM 배포 파이프라인

<details>
<summary>📖 자동화 파이프라인 설계</summary>

### 파이프라인 구성
1. **코드 푸시** → GitHub 저장소
2. **자동 테스트** → GitHub Actions
3. **Docker 이미지 빌드** → Docker Hub
4. **VM 배포** → AWS EC2 / GCP Compute Engine
5. **헬스 체크** → 배포 상태 확인
6. **알림** → Slack, 이메일

### 자동화 이점
- **일관성**: 동일한 배포 프로세스
- **신뢰성**: 자동화된 테스트 및 검증
- **효율성**: 수동 작업 최소화
- **추적성**: 배포 이력 및 로그 관리

</details>

<details>
<summary>🔗 통합 배포 파이프라인</summary>

### .github/workflows/deploy-vm.yml
```yaml
name: Deploy to VM

on:
  push:
    branches: [ main, develop ]
  workflow_dispatch:

env:
  DOCKER_IMAGE: ${{ secrets.DOCKERHUB_USERNAME }}/my-app
  DOCKER_TAG: ${{ github.sha }}

jobs:
  # AWS EC2 배포
  deploy-aws:
    runs-on: ubuntu-latest
    if: ${{ secrets.AWS_ACCESS_KEY_ID }}
    environment: ${{ github.ref == 'refs/heads/main' && 'production' || 'staging' }}
    
    steps:
    - name: Checkout code
      uses: actions/checkout@v4
      
    - name: Configure AWS credentials
      uses: aws-actions/configure-aws-credentials@v4
      with:
        aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
        aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        aws-region: ap-northeast-2
        
    - name: Deploy to AWS EC2
      uses: appleboy/ssh-action@v1.0.0
      with:
        host: ${{ secrets.AWS_EC2_HOST }}
        username: ${{ secrets.AWS_EC2_USERNAME }}
        key: ${{ secrets.AWS_EC2_SSH_KEY }}
        script: |
          # Docker 이미지 풀
          docker pull ${{ env.DOCKER_IMAGE }}:${{ env.DOCKER_TAG }}
          
          # 기존 컨테이너 중지
          docker stop my-app || true
          docker rm my-app || true
          
          # 새 컨테이너 실행
          docker run -d \
            --name my-app \
            --restart unless-stopped \
            -p 80:3000 \
            -e NODE_ENV=production \
            ${{ env.DOCKER_IMAGE }}:${{ env.DOCKER_TAG }}
          
          # 헬스 체크
          sleep 10
          curl -f http://localhost:3000/health || exit 1
          
          # 로그 확인
          docker logs my-app

  # GCP Compute Engine 배포
  deploy-gcp:
    runs-on: ubuntu-latest
    if: ${{ secrets.GCP_SA_KEY }}
    environment: ${{ github.ref == 'refs/heads/main' && 'production' || 'staging' }}
    
    steps:
    - name: Checkout code
      uses: actions/checkout@v4
      
    - name: Setup Google Cloud CLI
      uses: google-github-actions/setup-gcloud@v1
      with:
        service_account_key: ${{ secrets.GCP_SA_KEY }}
        project_id: ${{ secrets.GCP_PROJECT_ID }}
        
    - name: Deploy to GCP Compute Engine
      run: |
        gcloud compute ssh ${{ secrets.GCP_INSTANCE_NAME }} \
          --zone=${{ secrets.GCP_ZONE }} \
          --command="
            docker pull ${{ env.DOCKER_IMAGE }}:${{ env.DOCKER_TAG }}
            docker stop my-app || true
            docker rm my-app || true
            docker run -d \
              --name my-app \
              --restart unless-stopped \
              -p 80:3000 \
              -e NODE_ENV=production \
              ${{ env.DOCKER_IMAGE }}:${{ env.DOCKER_TAG }}
            sleep 10
            curl -f http://localhost:3000/health || exit 1
            docker logs my-app
          "

  # 배포 상태 확인
  verify-deployment:
    needs: [deploy-aws, deploy-gcp]
    runs-on: ubuntu-latest
    if: always()
    
    steps:
    - name: Verify AWS deployment
      if: needs.deploy-aws.result == 'success'
      run: |
        curl -f http://${{ secrets.AWS_EC2_HOST }}:3000/health
        echo "✅ AWS deployment verified"
        
    - name: Verify GCP deployment
      if: needs.deploy-gcp.result == 'success'
      run: |
        curl -f http://${{ secrets.GCP_INSTANCE_IP }}:3000/health
        echo "✅ GCP deployment verified"

  # 배포 알림
  notify:
    needs: [deploy-aws, deploy-gcp, verify-deployment]
    runs-on: ubuntu-latest
    if: always()
    
    steps:
    - name: Notify deployment status
      uses: 8398a7/action-slack@v3
      with:
        status: ${{ job.status }}
        text: |
          🚀 Deployment Status: ${{ job.status }}
          📦 Image: ${{ env.DOCKER_IMAGE }}:${{ env.DOCKER_TAG }}
          🌐 AWS: ${{ needs.deploy-aws.result }}
          ☁️ GCP: ${{ needs.deploy-gcp.result }}
      env:
        SLACK_WEBHOOK_URL: ${{ secrets.SLACK_WEBHOOK_URL }}
```

</details>

---

## 📚 문제 해결 및 참고 자료

<details>
<summary>🐛 자주 발생하는 문제</summary>

### Docker 관련 문제
<details>
<summary>❌ 멀티스테이지 빌드 실패</summary>

**원인**: 
- 빌드 컨텍스트 문제
- 의존성 누락
- 권한 문제

**해결방법**:
```bash
# 1. 빌드 컨텍스트 확인
docker build --no-cache -t my-app .

# 2. 빌드 로그 확인
docker build --progress=plain -t my-app .

# 3. 중간 이미지 확인
docker images | grep my-app
```

</details>

<details>
<summary>❌ Docker 이미지 크기 문제</summary>

**원인**:
- 불필요한 파일 포함
- 레이어 최적화 부족
- 멀티스테이지 빌드 미사용

**해결방법**:
```bash
# 1. 이미지 크기 분석
docker history my-app:latest

# 2. 불필요한 파일 제거
docker run --rm -v $(pwd):/app -w /app node:18-alpine sh -c "find . -name 'node_modules' -type d -exec rm -rf {} +"

# 3. 멀티스테이지 빌드 적용
docker build --target runtime -t my-app:latest .
```

</details>

### GitHub Actions 관련 문제
<details>
<summary>❌ 워크플로우 실행 실패</summary>

**원인**:
- 시크릿 설정 누락
- 권한 부족
- YAML 문법 오류

**해결방법**:
1. GitHub Secrets 확인
2. 워크플로우 권한 확인
3. YAML 문법 검사

</details>

<details>
<summary>❌ 배포 실패</summary>

**원인**:
- SSH 연결 실패
- Docker 이미지 없음
- 포트 충돌

**해결방법**:
```bash
# 1. SSH 연결 테스트
ssh -i key.pem user@host

# 2. Docker 이미지 확인
docker images | grep my-app

# 3. 포트 확인
netstat -tulpn | grep :3000
```

</details>

</details>

<details>
<summary>📖 추가 학습 자료</summary>

### 공식 문서
- [Docker 공식 문서](https://docs.docker.com/)
- [GitHub Actions 공식 문서](https://docs.github.com/en/actions)
- [AWS EC2 공식 문서](https://docs.aws.amazon.com/ec2/)
- [GCP Compute Engine 공식 문서](https://cloud.google.com/compute/docs)

### 유용한 리소스
- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)
- [GitHub Actions Marketplace](https://github.com/marketplace?type=actions)
- [AWS CLI 공식 문서](https://docs.aws.amazon.com/cli/)
- [gcloud CLI 공식 문서](https://cloud.google.com/sdk/docs)

### 관련 프로젝트
- [Docker 샘플 프로젝트](https://github.com/docker/awesome-compose)
- [GitHub Actions 샘플](https://github.com/actions/starter-workflows)

</details>

<details>
<summary>🚀 다음 단계</summary>

### 2일차 준비
1. **로드 밸런싱**: ELB, Cloud Load Balancing
2. **Auto Scaling**: Auto Scaling Group, Managed Instance Group
3. **모니터링**: CloudWatch, Cloud Monitoring
4. **비용 최적화**: 비용 분석 및 최적화 전략

### 고급 기능
1. **Kubernetes**: 컨테이너 오케스트레이션
2. **서비스 메시**: Istio, Linkerd
3. **보안**: 보안 스캔, 암호화
4. **성능**: 성능 모니터링, 최적화

</details>

---

## 🎉 완료!

축하합니다! Cloud Master 1일차 실습을 완료했습니다.

### 📚 학습 요약

이번 실습을 통해 다음을 배웠습니다:

1. **🐳 Docker 고급**: Dockerfile 최적화, 멀티스테이지 빌드
2. **🚀 GitHub Actions 고급**: 고급 워크플로우, 환경별 배포
3. **☁️ VM 배포**: AWS EC2, GCP Compute Engine 자동 배포
4. **⚙️ 자동화**: 완전 자동화된 CI/CD 파이프라인

### 🚀 다음 단계

- **2일차 실습**: 로드 밸런싱, Auto Scaling, 모니터링
- **실제 프로젝트 적용**: 자신의 프로젝트에 고급 CI/CD 적용
- **고급 기능 학습**: Kubernetes, 서비스 메시, 보안

### 💡 추가 학습 자료

- [Docker 공식 문서](https://docs.docker.com/)
- [GitHub Actions 공식 문서](https://docs.github.com/en/actions)
- [Cloud Master 2일차 실습](../Day2/README.md)

---

**🎯 이제 고급 CI/CD와 VM 기반 컨테이너 배포의 기본기를 갖추었습니다! 2일차 실습으로 진행하세요.**