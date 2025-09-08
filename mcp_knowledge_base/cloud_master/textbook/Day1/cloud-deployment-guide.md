# 3교시: 클라우드 배포 기초 실습

## 📋 목차
1. [클라우드 배포 개념](#클라우드-배포-개념)
2. [배포 방식 비교](#배포-방식-비교)
3. [실습 목표](#실습-목표)
4. [실습 절차](#실습-절차)
5. [실습 코드 예시](#실습-코드-예시)
6. [예상 결과](#예상-결과)
7. [혼자 해보기](#혼자-해보기)

---

## ☁️ 클라우드 배포 개념

### 클라우드 배포란?

클라우드 배포는 **개발한 애플리케이션을 클라우드 환경에서 실행할 수 있도록 배치하는 과정**입니다.

### 배포의 필요성

#### 로컬 개발의 한계
- 다른 사람이 접근할 수 없음
- 24시간 실행 불가능
- 확장성 부족
- 보안 취약

#### 클라우드 배포의 장점
- **전 세계 접근 가능**: 인터넷이 있는 곳 어디서나 접근
- **24시간 가동**: 서버가 계속 실행되어 서비스 제공
- **자동 확장**: 트래픽 증가 시 자동으로 리소스 확장
- **보안 강화**: 클라우드 제공업체의 보안 인프라 활용

### 주요 배포 방식

| 배포 방식 | 설명 | 장점 | 단점 | 적합한 경우 |
|-----------|------|------|------|-------------|
| **가상머신** | VM에 애플리케이션 배포 | 완전한 제어 가능 | 관리 복잡 | 전통적인 애플리케이션 |
| **컨테이너** | Docker 컨테이너로 배포 | 이식성, 일관성 | 오케스트레이션 필요 | 마이크로서비스 |
| **서버리스** | 함수 단위로 배포 | 비용 효율적, 관리 불필요 | 제한적 | 이벤트 기반 애플리케이션 |
| **PaaS** | 플랫폼에서 직접 배포 | 간단한 배포 | 제한적 커스터마이징 | 웹 애플리케이션 |

---

## ⚖️ 배포 방식 비교

### 1. AWS 배포 옵션

#### AWS EC2 (가상머신) - Docker 배포
```bash
# EC2 인스턴스에 Docker로 배포
ssh ec2-user@your-instance.com

# Docker 이미지 다운로드 및 실행
docker pull your-registry/your-app:latest
docker stop your-app || true
docker rm your-app || true
docker run -d -p 80:3000 --name your-app your-registry/your-app:latest

# 또는 Docker Compose 사용
docker-compose up -d
```

#### AWS EC2 (가상머신) - 직접 배포
```bash
# EC2 인스턴스에 직접 배포
ssh ec2-user@your-instance.com
git clone https://github.com/your-repo.git
npm install
npm start
```

#### AWS Elastic Beanstalk (PaaS)
```bash
# EB CLI로 간단 배포
eb init
eb create production
eb deploy
```

#### AWS ECS (컨테이너)
```bash
# ECS에 컨테이너 배포
aws ecs create-service --cluster my-cluster --service-name my-app
```

### 2. GCP 배포 옵션

#### Google Compute Engine (가상머신) - Docker 배포
```bash
# GCE 인스턴스에 Docker로 배포
gcloud compute ssh my-instance

# Docker 이미지 다운로드 및 실행
docker pull your-registry/your-app:latest
docker stop your-app || true
docker rm your-app || true
docker run -d -p 80:3000 --name your-app your-registry/your-app:latest

# 또는 Docker Compose 사용
docker-compose up -d
```

#### Google Compute Engine (가상머신) - 직접 배포
```bash
# GCE 인스턴스에 직접 배포
gcloud compute ssh my-instance
git clone https://github.com/your-repo.git
npm install && npm start
```

#### Google App Engine (PaaS)
```bash
# App Engine에 배포
gcloud app deploy
```

#### Google Cloud Run (서버리스 컨테이너)
```bash
# Cloud Run에 컨테이너 배포
gcloud run deploy --source .
```

---

## 🎯 실습 목표

이 실습을 통해 다음을 달성합니다:

1. **배포 개념 이해**: 클라우드 배포의 기본 개념과 필요성을 이해합니다.

2. **간단한 배포 실습**: GitHub Actions를 통해 간단한 배포를 자동화합니다.

3. **배포 결과 확인**: 배포된 애플리케이션이 정상 동작하는지 확인합니다.

4. **배포 방식 비교**: 다양한 배포 방식의 특징을 이해합니다.

---

## 📝 실습 절차

### 1단계: 배포 환경 준비

#### GitHub Actions 워크플로우 수정
기존 `deploy.yml` 파일을 수정하여 실제 배포 시뮬레이션을 추가합니다.

```yaml
# .github/workflows/deploy.yml
name: Deploy to Cloud

on:
  push:
    branches: [ main ]

jobs:
  deploy:
    name: Deploy Application
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
      
      - name: Run tests
        run: npm test
      
      - name: Build application
        run: npm run build
      
      # 배포 시뮬레이션
      - name: Deploy to AWS EC2 with Docker (Simulation)
        run: |
          echo "🚀 Deploying to AWS EC2 with Docker..."
          echo "📦 Application: actions-demo"
          echo "🌍 Environment: production"
          echo "📊 Version: ${{ github.sha }}"
          echo "🐳 Building Docker image..."
          echo "🐳 Pushing to Docker Hub..."
          echo "🖥️  Connecting to EC2 instance..."
          echo "🐳 Pulling Docker image on EC2..."
          echo "🚀 Starting container on EC2..."
          echo "✅ AWS EC2 Docker deployment completed successfully!"
      
      - name: Deploy to GCP GCE with Docker (Simulation)
        run: |
          echo "🚀 Deploying to GCP GCE with Docker..."
          echo "📦 Application: actions-demo"
          echo "🌍 Environment: production"
          echo "📊 Version: ${{ github.sha }}"
          echo "🐳 Building Docker image..."
          echo "🐳 Pushing to Docker Hub..."
          echo "🖥️  Connecting to GCE instance..."
          echo "🐳 Pulling Docker image on GCE..."
          echo "🚀 Starting container on GCE..."
          echo "✅ GCP GCE Docker deployment completed successfully!"
      
      - name: Health Check
        run: |
          echo "🔍 Performing health check..."
          echo "✅ Application is running successfully!"
          echo "🌐 Service URL: https://your-app.com"
          echo "📈 Status: Healthy"
      
      - name: Deployment Summary
        run: |
          echo "=== 🎉 Deployment Summary ==="
          echo "Application: actions-demo"
          echo "Version: ${{ github.sha }}"
          echo "AWS Status: ✅ Success"
          echo "GCP Status: ✅ Success"
          echo "Health Check: ✅ Passed"
          echo "Deployment Time: $(date)"
```

### 2단계: 배포 워크플로우 실행

#### 코드 커밋 및 푸시
```bash
# 변경사항 커밋
git add .
git commit -m "Add cloud deployment simulation"
git push origin main
```

#### GitHub Actions 실행 확인
1. GitHub 저장소 → Actions 탭
2. "Deploy to Cloud" 워크플로우 실행 확인
3. 각 단계별 로그 확인

### 3단계: 배포 결과 분석

#### 성공적인 배포 확인
- ✅ AWS 배포 시뮬레이션 완료
- ✅ GCP 배포 시뮬레이션 완료
- ✅ 헬스체크 통과
- ✅ 배포 요약 출력

---

## 💻 실습 코드 예시

### 배포 상태 확인 스크립트

```bash
#!/bin/bash
# deploy-check.sh

echo "🔍 Checking deployment status..."

# 애플리케이션 상태 확인
echo "📊 Application Status:"
echo "  - Name: actions-demo"
echo "  - Version: $GITHUB_SHA"
echo "  - Environment: production"
echo "  - Status: Running"

# 서비스 엔드포인트 확인
echo "🌐 Service Endpoints:"
echo "  - AWS: https://aws.your-app.com"
echo "  - GCP: https://gcp.your-app.com"

# 헬스체크
echo "🔍 Health Check:"
curl -f https://your-app.com/health && echo "✅ Healthy" || echo "❌ Unhealthy"

echo "✅ Deployment check completed!"
```

### 배포 알림 스크립트

```bash
#!/bin/bash
# notify-deployment.sh

DEPLOYMENT_STATUS=$1
APPLICATION_NAME="actions-demo"
VERSION=$GITHUB_SHA

if [ "$DEPLOYMENT_STATUS" = "success" ]; then
    echo "🎉 Deployment Successful!"
    echo "📦 Application: $APPLICATION_NAME"
    echo "📊 Version: $VERSION"
    echo "🌍 Environment: production"
    echo "⏰ Time: $(date)"
else
    echo "❌ Deployment Failed!"
    echo "📦 Application: $APPLICATION_NAME"
    echo "📊 Version: $VERSION"
    echo "🔍 Check logs for details"
fi
```

---

## 📊 예상 결과

### 성공적인 배포 시

```
🚀 Deploying to AWS EC2 with Docker...
📦 Application: actions-demo
🌍 Environment: production
📊 Version: abc123def456
🐳 Building Docker image...
🐳 Pushing to Docker Hub...
🖥️  Connecting to EC2 instance...
🐳 Pulling Docker image on EC2...
🚀 Starting container on EC2...
✅ AWS EC2 Docker deployment completed successfully!

🚀 Deploying to GCP GCE with Docker...
📦 Application: actions-demo
🌍 Environment: production
📊 Version: abc123def456
🐳 Building Docker image...
🐳 Pushing to Docker Hub...
🖥️  Connecting to GCE instance...
🐳 Pulling Docker image on GCE...
🚀 Starting container on GCE...
✅ GCP GCE Docker deployment completed successfully!

🔍 Performing health check...
✅ Application is running successfully!
🌐 Service URL: https://your-app.com
📈 Status: Healthy

=== 🎉 Deployment Summary ===
Application: actions-demo
Version: abc123def456
AWS EC2 Docker Status: ✅ Success
GCP GCE Docker Status: ✅ Success
Health Check: ✅ Passed
Deployment Time: 2024-01-15 14:30:25
```

### GitHub Actions 실행 결과

- **워크플로우 상태**: ✅ Success
- **실행 시간**: 약 2-3분
- **배포 단계**: 모두 성공
- **알림**: Slack 또는 이메일 발송 (설정된 경우)

---

## 🏃‍♂️ 혼자 해보기

### 기본 실습
1. **배포 시뮬레이션 확장**: 더 많은 배포 단계 추가
2. **환경별 배포**: staging, production 환경 구분
3. **배포 롤백**: 실패 시 이전 버전으로 복구

### 고급 실습
1. **실제 VM 배포**: AWS EC2/GCP GCE에 Docker로 실제 배포
2. **배포 전략**: Blue-Green, Canary 배포 구현
3. **모니터링 연동**: 배포 후 자동 모니터링 설정
4. **Docker Compose 활용**: 복잡한 애플리케이션 스택 배포

### 실무 적용
1. **팀 프로젝트**: 실제 프로젝트에 배포 파이프라인 적용
2. **CI/CD 완성**: 테스트 → 빌드 → 배포 전체 자동화
3. **배포 최적화**: 배포 시간 단축 및 안정성 향상

---

## 🔧 문제 해결

### 배포 실패 시
```bash
# 로그 확인
# GitHub Actions → 해당 워크플로우 → 실패한 Job 클릭

# 일반적인 문제들
1. 권한 부족: GitHub 시크릿 설정 확인
2. 네트워크 문제: 인터넷 연결 확인
3. 코드 오류: 테스트 실패 시 코드 수정
4. SSH 연결 실패: VM 접근 권한 및 키 확인
5. Docker 이미지 푸시 실패: Docker Hub 토큰 확인
```

### VM Docker 배포 문제 해결

#### SSH 연결 문제
```bash
# SSH 키 권한 확인
chmod 600 ~/.ssh/id_rsa

# SSH 연결 테스트
ssh -i ~/.ssh/id_rsa user@your-vm-ip

# GitHub 시크릿 확인
# AWS_EC2_HOST, AWS_EC2_USER, AWS_EC2_SSH_KEY
# GCP_GCE_HOST, GCP_GCE_USER, GCP_GCE_SSH_KEY
```

#### Docker 이미지 문제
```bash
# Docker Hub 로그인 확인
docker login

# 이미지 존재 확인
docker pull your-registry/your-app:tag

# 컨테이너 상태 확인
docker ps -a
docker logs container-name
```

### 성능 최적화
```bash
# 배포 시간 단축
1. 캐시 활용: npm cache, Docker layer cache
2. 병렬 실행: 여러 Job을 동시에 실행
3. 불필요한 단계 제거: 최소한의 단계만 실행
```

---

## 📚 다음 단계

이 3교시를 완료하면 다음을 학습할 수 있습니다:

- **4교시**: 전체 자동 배포 파이프라인 구성
- **Advanced 과정**: 실제 클라우드 오케스트레이션 (ECS/GKE)
- **실무 적용**: 팀 프로젝트에 VM Docker 배포 적용

## 🔗 관련 파일

- **VM Docker 배포 워크플로우**: `actions-demo/.github/workflows/vm-docker-deploy.yml`
- **Docker Compose 예시**: `actions-demo/docker-compose.yml`
- **SSH 키 설정 가이드**: `aws-gcp-permissions-setup.md`

**🎯 목표**: 클라우드 배포의 기본 개념을 이해하고, GitHub Actions를 통한 자동 배포 파이프라인을 구축할 수 있습니다.
