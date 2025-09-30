# 🚀 GitHub Actions CI/CD 파이프라인 실습

> 📋 **실습 시간**: 90분  
> 📋 **난이도**: 중급  
> 📋 **선수 학습**: Git, GitHub, Docker, AWS/GCP 계정  
> 📋 **실습 환경**: GitHub Actions, AWS ECS, GCP Cloud Run

## 🎯 학습 목표

### 핵심 학습 목표
- **GitHub Actions 워크플로우**: 자동화된 빌드, 테스트, 배포 파이프라인 구축
- **자동화된 테스트 및 배포**: 품질 보장 및 배포 자동화
- **환경별 배포 전략**: 개발, 스테이징, 프로덕션 환경 관리

### 실습 후 달성할 수 있는 능력
- ✅ GitHub Actions 워크플로우 작성 및 실행
- ✅ 자동화된 테스트 및 빌드 파이프라인 구축
- ✅ Docker 이미지 빌드 및 푸시 자동화
- ✅ 보안 스캔 및 품질 검증 자동화

### 예상 소요 시간
- **환경 준비**: 15분
- **워크플로우 작성**: 30분
- **테스트 및 빌드**: 25분
- **배포 자동화**: 20분

---

## 🛠️ 실습 환경 준비

### 📁 실습 코드 및 자동화
- **실습 샘플 코드**: `/cloud_intermediate/repo/practice/day2/cicd-pipeline/`
- **자동화 스크립트**: `/cloud_intermediate/tools/cloud/github-actions-helper.sh` (복사 후 사용)
- **클라우드 스크립트**: `/cloud_intermediate/tools/cloud/`

### 🔧 자동화 스크립트 사용법
```bash
# 자동화 스크립트를 실습 위치로 복사
cp ../../tools/cloud/github-actions-helper.sh ./
chmod +x github-actions-helper.sh

# CI/CD 파이프라인 실습
./github-actions-helper.sh --action create-workflow
./github-actions-helper.sh --action setup-secrets
./github-actions-helper.sh --action test-pipeline
```

<details>
<summary>🚀 실습 환경 준비</summary>

#### 필수 도구
- **Git**: 버전 관리
- **GitHub**: 코드 저장소 및 Actions
- **Docker**: 컨테이너 이미지 빌드
- **AWS CLI**: AWS 서비스 관리
- **GCP CLI**: GCP 서비스 관리

#### 환경 설정
```bash
# Git 설정 확인
git config --global user.name
git config --global user.email

# GitHub 인증 확인
gh auth status

# Docker 설치 확인
docker --version

# AWS CLI 설정 확인
aws sts get-caller-identity

# GCP CLI 설정 확인
gcloud auth list
```

</details>

<details>
<summary>🔧 1단계: GitHub Actions 워크플로우 작성</summary>

#### 실습 디렉토리 생성
```bash
# 실습 디렉토리 생성
mkdir -p ~/cloud_intermediate/samples/day2/cicd-pipeline
cd ~/cloud_intermediate/samples/day2/cicd-pipeline

# 실습 샘플 코드 복사 (있는 경우)
cp -r /cloud_intermediate/repo/examples/day2/cicd-pipeline/* ./
```

#### GitHub Actions 워크플로우 생성
```bash
# .github/workflows 디렉토리 생성
mkdir -p .github/workflows

# CI/CD 워크플로우 생성
cat > .github/workflows/ci-cd.yml << 'EOF'
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
    
    - name: Build Docker image
      run: docker build -t ${{ github.repository }}:${{ github.sha }} .
    
    - name: Run security scan
      run: |
        docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
          aquasec/trivy image ${{ github.repository }}:${{ github.sha }}

  deploy:
    needs: test
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    steps:
    - uses: actions/checkout@v3
    
    - name: Deploy to AWS ECS
      run: |
        aws ecs update-service \
          --cluster ${{ secrets.ECS_CLUSTER }} \
          --service ${{ secrets.ECS_SERVICE }} \
          --force-new-deployment
    
    - name: Deploy to GCP Cloud Run
      run: |
        gcloud run deploy ${{ secrets.CLOUD_RUN_SERVICE }} \
          --image gcr.io/${{ secrets.GCP_PROJECT_ID }}/${{ github.repository }}:${{ github.sha }} \
          --region ${{ secrets.GCP_REGION }}
EOF

# 워크플로우 파일 권한 설정
chmod +x .github/workflows/ci-cd.yml
```

#### package.json 생성
```json
{
  "name": "cicd-pipeline-app",
  "version": "1.0.0",
  "description": "CI/CD 파이프라인 실습용 앱",
  "main": "index.js",
  "scripts": {
    "start": "node index.js",
    "test": "jest",
    "lint": "eslint .",
    "build": "echo 'Build completed'"
  },
  "dependencies": {
    "express": "^4.18.2"
  },
  "devDependencies": {
    "jest": "^29.5.0",
    "eslint": "^8.40.0"
  }
}
```

</details>

<details>
<summary>🔧 2단계: Docker 이미지 빌드 및 테스트</summary>

#### Dockerfile 생성
```bash
# Dockerfile 생성
cat > Dockerfile << 'EOF'
FROM node:18-alpine

WORKDIR /app

# 의존성 설치
COPY package*.json ./
RUN npm ci --only=production

# 애플리케이션 코드 복사
COPY . .

# 포트 설정
EXPOSE 3000

# 헬스체크 추가
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:3000/health || exit 1

# 애플리케이션 실행
CMD ["npm", "start"]
EOF
```

#### 애플리케이션 코드 생성
```bash
# index.js 생성
cat > index.js << 'EOF'
const express = require('express');
const app = express();
const port = process.env.PORT || 3000;

app.get('/', (req, res) => {
  res.json({ message: 'CI/CD Pipeline App', version: '1.0.0' });
});

app.get('/health', (req, res) => {
  res.status(200).json({ status: 'healthy' });
});

app.get('/metrics', (req, res) => {
  res.set('Content-Type', 'text/plain');
  res.send('# Prometheus metrics\n');
});

app.listen(port, () => {
  console.log(`App running on port ${port}`);
});
EOF
```

#### 로컬 테스트 실행
```bash
# 의존성 설치
npm install

# 테스트 실행
npm test

# 린팅 실행
npm run lint

# Docker 이미지 빌드 테스트
docker build -t cicd-pipeline-app:latest .

# 컨테이너 실행 테스트
docker run -d --name test-container -p 3000:3000 cicd-pipeline-app:latest

# 애플리케이션 테스트
curl http://localhost:3000/
curl http://localhost:3000/health
curl http://localhost:3000/metrics

# 컨테이너 정리
docker stop test-container
docker rm test-container
```

</details>

<details>
<summary>🔧 3단계: GitHub Actions 실행 및 배포</summary>

#### GitHub 저장소 설정
```bash
# Git 저장소 초기화
git init
git add .
git commit -m "Initial commit: CI/CD pipeline setup"

# GitHub 저장소 생성 (GitHub CLI 사용)
gh repo create cloud-intermediate-cicd --public

# 원격 저장소 추가
git remote add origin https://github.com/USERNAME/cloud-intermediate-cicd.git

# 코드 푸시
git push -u origin main
```

#### GitHub Actions 실행 확인
```bash
# GitHub Actions 실행 상태 확인
gh run list

# 특정 워크플로우 실행 상태 확인
gh run watch

# 워크플로우 로그 확인
gh run view --log
```

#### AWS ECS 배포 설정
```bash
# ECS 클러스터 생성
aws ecs create-cluster \
    --cluster-name cicd-cluster \
    --capacity-providers FARGATE \
    --default-capacity-provider-strategy capacityProvider=FARGATE,weight=1

# 태스크 정의 생성
cat > task-definition.json << 'EOF'
{
  "family": "cicd-app",
  "networkMode": "awsvpc",
  "requiresCompatibilities": ["FARGATE"],
  "cpu": "256",
  "memory": "512",
  "executionRoleArn": "arn:aws:iam::ACCOUNT:role/ecsTaskExecutionRole",
  "containerDefinitions": [
    {
      "name": "cicd-app",
      "image": "nginx:1.21",
      "portMappings": [
        {
          "containerPort": 3000,
          "protocol": "tcp"
        }
      ],
      "essential": true
    }
  ]
}
EOF

# 태스크 정의 등록
aws ecs register-task-definition --cli-input-json file://task-definition.json
```

#### GCP Cloud Run 배포 설정
```bash
# GCP 프로젝트 설정
gcloud config set project YOUR_PROJECT_ID

# Cloud Run 서비스 배포
gcloud run deploy cicd-app \
    --image gcr.io/YOUR_PROJECT_ID/cicd-pipeline-app:latest \
    --platform managed \
    --region us-central1 \
    --allow-unauthenticated
```

</details>

---

## 📚 참고 자료

### 유용한 명령어
```bash
# GitHub Actions 관리
gh run list
gh run watch
gh run view --log

# Docker 관리
docker images
docker ps -a
docker system prune -a

# AWS ECS 관리
aws ecs list-clusters
aws ecs list-services --cluster cicd-cluster
aws ecs describe-tasks --cluster cicd-cluster --tasks TASK_ARN

# GCP Cloud Run 관리
gcloud run services list
gcloud run services describe cicd-app --region us-central1
```

### 문제 해결
1. **GitHub Actions 워크플로우 실패**
   - Actions 탭에서 워크플로우 실행 로그 확인
   - 로컬에서 동일한 명령어 실행 테스트
   - 시크릿 및 환경 변수 설정 확인

2. **Docker 빌드 실패**
   - Dockerfile 문법 확인
   - 베이스 이미지 존재 여부 확인
   - 네트워크 연결 상태 확인

3. **AWS ECS 배포 실패**
   - IAM 역할 권한 확인
   - 서브넷 및 보안 그룹 설정 확인
   - 태스크 정의 문법 확인

---

## 🧹 실습 정리

### 자동 정리
```bash
# Day2 CI/CD 실습 자동 정리
./cloud_intermediate/repo/automation/day2/cicd-pipeline-practice-automation.sh --cleanup
```

### 수동 정리
```bash
# GitHub Actions 워크플로우 정리
gh run list --status completed --limit 10 | xargs -I {} gh run delete {}

# Docker 리소스 정리
docker system prune -a

# AWS ECS 리소스 정리
aws ecs delete-service --cluster cicd-cluster --service cicd-service
aws ecs delete-cluster --cluster cicd-cluster

# GCP Cloud Run 리소스 정리
gcloud run services delete cicd-app --region us-central1
```

### 정리 확인
- [ ] GitHub Actions 워크플로우 정리 완료
- [ ] Docker 리소스 정리 완료
- [ ] AWS ECS 리소스 정리 완료
- [ ] GCP Cloud Run 리소스 정리 완료

---

## 🎯 학습 성과 확인

### 실습 완료 체크리스트
- [ ] GitHub Actions 워크플로우 작성 완료
- [ ] 자동화된 테스트 및 빌드 파이프라인 구축
- [ ] Docker 이미지 빌드 및 푸시 자동화
- [ ] 보안 스캔 및 품질 검증 자동화
- [ ] AWS ECS 및 GCP Cloud Run 배포 자동화

### 다음 단계
- **멀티 클라우드 통합 모니터링** 실습으로 진행
- **클라우드 고급 배포** 실습 준비
- **실무 프로젝트**에 CI/CD 파이프라인 적용

---

**💡 궁금한 점이 있으시면 언제든 문의해주세요!**
**문제가 발생하거나 도움이 필요하시면 실시간으로 지원해드리겠습니다.**
