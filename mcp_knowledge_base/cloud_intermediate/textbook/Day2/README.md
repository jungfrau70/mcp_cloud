# 🚀 Day 2: CI/CD 및 클라우드 배포

## 📚 학습 목표

### 핵심 학습 목표
- **CI/CD 파이프라인** GitHub Actions를 활용한 자동화된 배포 시스템
- **클라우드 배포** AWS ECS, GCP Cloud Run을 활용한 컨테이너 배포

### 실습 후 달성할 수 있는 능력
- ✅ GitHub Actions를 활용한 완전 자동화된 CI/CD 파이프라인 구축
- ✅ AWS ECS, GCP Cloud Run을 통한 클라우드 컨테이너 배포
- ✅ 로드 밸런싱, SSL, 모니터링을 포함한 프로덕션 환경 구축

### 예상 소요 시간
- **CI/CD 파이프라인**: 120-150분
- **클라우드 배포**: 120-150분
- **모니터링 기초**: 90-120분
- **전체 과정**: 8시간

---

## 🛠️ 실습 학습

### 📁 실습 코드 및 자동화
- **실습 샘플 코드**: `/mcp_knowledge_base/cloud_intermediate/repo/samples/day2/`
- **자동화 스크립트**: `/mcp_knowledge_base/cloud_intermediate/repo/scripts/day2-practice.sh`
- **클라우드 스크립트**: `/mcp_knowledge_base/cloud_intermediate/repo/cloud-scripts/`

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
<summary>🔧 1단계: CI/CD 파이프라인</summary>

#### GitHub Actions 워크플로우
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

#### 자동화된 Docker 이미지 빌드
```bash
# Dockerfile 최적화
cat > Dockerfile << 'EOF'
FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

FROM node:18-alpine AS runtime
WORKDIR /app
COPY --from=builder /app/node_modules ./node_modules
COPY . .
EXPOSE 3000
CMD ["npm", "start"]
EOF

# 이미지 빌드 및 푸시
docker build -t myapp:latest .
docker tag myapp:latest myapp:$GITHUB_SHA
docker push myapp:latest
docker push myapp:$GITHUB_SHA
```

</details>

<details>
<summary>🔧 2단계: 클라우드 배포</summary>

#### AWS ECS 배포
```bash
# ECS 클러스터 생성
aws ecs create-cluster --cluster-name my-cluster

# 태스크 정의 생성
aws ecs register-task-definition --cli-input-json file://task-definition.json

# 서비스 생성
aws ecs create-service \
  --cluster my-cluster \
  --service-name my-service \
  --task-definition myapp:1 \
  --desired-count 2 \
  --launch-type FARGATE \
  --network-configuration "awsvpcConfiguration={subnets=[subnet-12345],securityGroups=[sg-12345],assignPublicIp=ENABLED}"

# Application Load Balancer 생성
aws elbv2 create-load-balancer \
  --name my-alb \
  --subnets subnet-12345 subnet-67890 \
  --security-groups sg-12345
```

#### GCP Cloud Run 배포
```bash
# Cloud Run 서비스 배포
gcloud run deploy myapp \
  --image gcr.io/my-project/myapp:latest \
  --platform managed \
  --region us-central1 \
  --allow-unauthenticated \
  --port 3000 \
  --memory 512Mi \
  --cpu 1 \
  --min-instances 0 \
  --max-instances 10

# 도메인 매핑
gcloud run domain-mappings create \
  --service myapp \
  --domain myapp.example.com \
  --region us-central1

# SSL 인증서 생성
gcloud compute ssl-certificates create myapp-ssl \
  --domains myapp.example.com \
  --global
```

</details>

<details>
<summary>🔧 3단계: 모니터링 기초</summary>

#### AWS CloudWatch 모니터링
```bash
# CloudWatch 로그 그룹 생성
aws logs create-log-group --log-group-name /aws/ecs/myapp

# CloudWatch 알람 생성
aws cloudwatch put-metric-alarm \
  --alarm-name "High CPU Usage" \
  --alarm-description "Alarm when CPU exceeds 80%" \
  --metric-name CPUUtilization \
  --namespace AWS/ECS \
  --statistic Average \
  --period 300 \
  --threshold 80 \
  --comparison-operator GreaterThanThreshold \
  --evaluation-periods 2

# CloudWatch 대시보드 생성
aws cloudwatch put-dashboard \
  --dashboard-name "MyApp Dashboard" \
  --dashboard-body file://dashboard.json
```

#### GCP Cloud Monitoring
```bash
# Cloud Monitoring 알림 정책 생성
gcloud alpha monitoring policies create \
  --policy-from-file=alert-policy.yaml

# Cloud Monitoring 대시보드 생성
gcloud monitoring dashboards create \
  --config-from-file=dashboard.json

# Cloud Logging 로그 기반 메트릭 생성
gcloud logging metrics create myapp_errors \
  --description="Count of error logs" \
  --log-filter="severity>=ERROR"
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

# AWS ECS 명령어
aws ecs list-services --cluster my-cluster
aws ecs describe-services --cluster my-cluster --services my-service
aws ecs update-service --cluster my-cluster --service my-service --force-new-deployment

# GCP Cloud Run 명령어
gcloud run services list
gcloud run services describe myapp --region us-central1
gcloud run services update myapp --region us-central1 --image gcr.io/my-project/myapp:latest
```

### 문제 해결
1. **GitHub Actions 워크플로우 실패**
   - 시크릿 설정 확인
   - 권한 설정 확인
   - 워크플로우 문법 확인

2. **ECS 서비스 배포 실패**
   - 태스크 정의 확인
   - 서브넷 및 보안 그룹 확인
   - IAM 역할 확인

3. **Cloud Run 배포 실패**
   - 이미지 존재 여부 확인
   - 권한 설정 확인
   - 리소스 제한 확인

---

## 🧹 실습 정리

### 자동 정리
```bash
# Day2 실습 자동 정리
./mcp_knowledge_base/cloud_intermediate/repo/scripts/day2-practice.sh --cleanup
```

### 수동 정리
```bash
# AWS ECS 리소스 정리
aws ecs delete-service --cluster my-cluster --service my-service
aws ecs delete-cluster --cluster my-cluster
aws elbv2 delete-load-balancer --load-balancer-arn arn:aws:elasticloadbalancing:us-west-2:123456789012:loadbalancer/app/my-alb/1234567890123456

# GCP Cloud Run 리소스 정리
gcloud run services delete myapp --region us-central1
gcloud run domain-mappings delete myapp.example.com --region us-central1

# CloudWatch 리소스 정리
aws logs delete-log-group --log-group-name /aws/ecs/myapp
aws cloudwatch delete-alarms --alarm-names "High CPU Usage"
aws cloudwatch delete-dashboards --dashboard-names "MyApp Dashboard"

# Cloud Monitoring 리소스 정리
gcloud alpha monitoring policies delete <policy-id>
gcloud monitoring dashboards delete <dashboard-id>
```

### 정리 확인
- [ ] AWS ECS 리소스 삭제 완료
- [ ] GCP Cloud Run 리소스 삭제 완료
- [ ] 모니터링 리소스 정리 완료
- [ ] 비용 발생 확인

---

## 🔗 관련 자료

### 📚 실습 가이드
- ["CI/CD 파이프라인"][practice/cicd-pipeline.md]
- ["클라우드 배포"][practice/cloud-deployment.md]
- ["모니터링 기초"][practice/monitoring-basics.md]

### 🛠️ 설치 가이드
- ["GitHub CLI 설치"][_setup_wsl/install-github-cli-wsl.sh]
- ["AWS CLI 설정"][_setup_wsl/install-aws-cli-wsl.sh]
- ["GCP CLI 설정"][_setup_wsl/install-gcp-cli-wsl.sh]

### 🏠 네비게이션
<div align="center">

["← 이전: Day 1"][../Day1/README.md] | 
["📚 전체 커리큘럼"][../../curriculum.md] | 
["🏠 학습 경로로 돌아가기"][../../index.md] | 
["다음: Cloud Master 과정 →"][../cloud_master/README.md]

</div>
