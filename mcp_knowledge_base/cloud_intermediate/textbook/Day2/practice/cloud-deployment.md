# ☁️ 클라우드 배포

## 🎯 학습 목표

### 핵심 학습 목표
- **AWS ECS 배포** Elastic Container Service를 활용한 컨테이너 배포
- **GCP Cloud Run 배포** 서버리스 컨테이너 배포 및 관리

### 실습 후 달성할 수 있는 능력
- ✅ AWS ECS를 통한 컨테이너 기반 애플리케이션 배포
- ✅ GCP Cloud Run을 통한 서버리스 컨테이너 배포
- ✅ 로드 밸런싱, SSL, 도메인 설정을 포함한 프로덕션 환경 구축

### 예상 소요 시간
- **AWS ECS 배포**: 90-120분
- **GCP Cloud Run 배포**: 90-120분
- **전체 과정**: 3-4시간

---

## 🛠️ 실습 학습

### 📁 실습 코드 및 자동화
- **실습 샘플 코드**: `/mcp_knowledge_base/cloud_intermediate/repo/samples/day2/cloud-deployment/`
- **자동화 스크립트**: `/mcp_knowledge_base/cloud_intermediate/repo/scripts/cloud-deployment-practice.sh`
- **클라우드 스크립트**: `/mcp_knowledge_base/cloud_intermediate/repo/cloud-scripts/`

<details>
<summary>🚀 실습 환경 준비</summary>

#### 필수 도구
- **AWS CLI**: AWS 서비스 관리
- **GCP CLI**: GCP 서비스 관리
- **Docker**: 컨테이너 이미지 빌드
- **kubectl**: Kubernetes 클러스터 관리 ["선택사항"]

#### 환경 설정
```bash
# AWS CLI 설정 확인
aws --version
aws configure list

# GCP CLI 설정 확인
gcloud --version
gcloud auth list

# Docker 설치 확인
docker --version

# kubectl 설치 확인 ["선택사항"]
kubectl version --client
```

</details>

<details>
<summary>🔧 1단계: AWS ECS 배포</summary>

#### ECS 클러스터 생성
```bash
# ECS 클러스터 생성
aws ecs create-cluster \
  --cluster-name my-ecs-cluster \
  --capacity-providers FARGATE \
  --default-capacity-provider-strategy capacityProvider=FARGATE,weight=1

# 클러스터 상태 확인
aws ecs describe-clusters --clusters my-ecs-cluster
```

#### 태스크 정의 생성
```json
{
  "family": "myapp-task",
  "networkMode": "awsvpc",
  "requiresCompatibilities": ["FARGATE"],
  "cpu": "256",
  "memory": "512",
  "executionRoleArn": "arn:aws:iam::123456789012:role/ecsTaskExecutionRole",
  "taskRoleArn": "arn:aws:iam::123456789012:role/ecsTaskRole",
  "containerDefinitions": [
    {
      "name": "myapp",
      "image": "nginx:1.21",
      "portMappings": [
        {
          "containerPort": 80,
          "protocol": "tcp"
        }
      ],
      "essential": true,
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/myapp",
          "awslogs-region": "us-west-2",
          "awslogs-stream-prefix": "ecs"
        }
      },
      "healthCheck": {
        "command": ["CMD-SHELL", "curl -f http://localhost:80/ || exit 1"],
        "interval": 30,
        "timeout": 5,
        "retries": 3
      }
    }
  ]
}
```

#### ECS 서비스 생성
```bash
# 태스크 정의 등록
aws ecs register-task-definition --cli-input-json file://task-definition.json

# 서비스 생성
aws ecs create-service \
  --cluster my-ecs-cluster \
  --service-name myapp-service \
  --task-definition myapp-task:1 \
  --desired-count 2 \
  --launch-type FARGATE \
  --network-configuration "awsvpcConfiguration={subnets=[subnet-12345,subnet-67890],securityGroups=[sg-12345],assignPublicIp=ENABLED}" \
  --load-balancers "targetGroupArn=arn:aws:elasticloadbalancing:us-west-2:123456789012:targetgroup/myapp-tg/1234567890123456,containerName=myapp,containerPort=80"

# 서비스 상태 확인
aws ecs describe-services --cluster my-ecs-cluster --services myapp-service
```

#### Application Load Balancer 설정
```bash
# ALB 생성
aws elbv2 create-load-balancer \
  --name myapp-alb \
  --subnets subnet-12345 subnet-67890 \
  --security-groups sg-12345

# 타겟 그룹 생성
aws elbv2 create-target-group \
  --name myapp-tg \
  --protocol HTTP \
  --port 80 \
  --vpc-id vpc-12345 \
  --target-type ip \
  --health-check-path / \
  --health-check-interval-seconds 30 \
  --health-check-timeout-seconds 5 \
  --healthy-threshold-count 2 \
  --unhealthy-threshold-count 3

# 리스너 생성
aws elbv2 create-listener \
  --load-balancer-arn arn:aws:elasticloadbalancing:us-west-2:123456789012:loadbalancer/app/myapp-alb/1234567890123456 \
  --protocol HTTP \
  --port 80 \
  --default-actions Type=forward,TargetGroupArn=arn:aws:elasticloadbalancing:us-west-2:123456789012:targetgroup/myapp-tg/1234567890123456
```

</details>

<details>
<summary>🔧 2단계: GCP Cloud Run 배포</summary>

#### Cloud Run 서비스 배포
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
  --max-instances 10 \
  --concurrency 80 \
  --timeout 300 \
  --set-env-vars NODE_ENV=production

# 서비스 상태 확인
gcloud run services describe myapp --region us-central1
```

#### 도메인 매핑 및 SSL 설정
```bash
# 도메인 매핑
gcloud run domain-mappings create \
  --service myapp \
  --domain myapp.example.com \
  --region us-central1

# SSL 인증서 생성
gcloud compute ssl-certificates create myapp-ssl \
  --domains myapp.example.com \
  --global

# 로드 밸런서 설정
gcloud compute url-maps create myapp-url-map \
  --default-service myapp-backend-service

# 백엔드 서비스 생성
gcloud compute backend-services create myapp-backend-service \
  --global \
  --load-balancing-scheme EXTERNAL \
  --protocol HTTP \
  --port-name http \
  --health-checks myapp-health-check

# 헬스 체크 생성
gcloud compute health-checks create http myapp-health-check \
  --port 80 \
  --request-path /health
```

#### Cloud Run 고급 설정
```yaml
# cloud-run-service.yaml
apiVersion: serving.knative.dev/v1
kind: Service
metadata:
  name: myapp
  annotations:
    run.googleapis.com/ingress: all
    run.googleapis.com/execution-environment: gen2
spec:
  template:
    metadata:
      annotations:
        autoscaling.knative.dev/maxScale: "10"
        autoscaling.knative.dev/minScale: "0"
        run.googleapis.com/cpu-throttling: "true"
        run.googleapis.com/execution-environment: gen2
    spec:
      containerConcurrency: 80
      timeoutSeconds: 300
      containers:
      - image: gcr.io/my-project/myapp:latest
        ports:
        - containerPort: 3000
        env:
        - name: NODE_ENV
          value: production
        - name: PORT
          value: "3000"
        resources:
          limits:
            cpu: "1"
            memory: "512Mi"
          requests:
            cpu: "0.5"
            memory: "256Mi"
        livenessProbe:
          httpGet:
            path: /health
            port: 3000
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /ready
            port: 3000
          initialDelaySeconds: 5
          periodSeconds: 5
```

</details>

<details>
<summary>🔧 3단계: 로드 밸런싱 및 SSL 설정</summary>

#### AWS ALB SSL 설정
```bash
# SSL 인증서 요청
aws acm request-certificate \
  --domain-name myapp.example.com \
  --validation-method DNS \
  --region us-east-1

# HTTPS 리스너 생성
aws elbv2 create-listener \
  --load-balancer-arn arn:aws:elasticloadbalancing:us-west-2:123456789012:loadbalancer/app/myapp-alb/1234567890123456 \
  --protocol HTTPS \
  --port 443 \
  --certificates CertificateArn=arn:aws:acm:us-east-1:123456789012:certificate/12345678-1234-1234-1234-123456789012 \
  --default-actions Type=forward,TargetGroupArn=arn:aws:elasticloadbalancing:us-west-2:123456789012:targetgroup/myapp-tg/1234567890123456

# HTTP에서 HTTPS로 리다이렉트
aws elbv2 create-listener \
  --load-balancer-arn arn:aws:elasticloadbalancing:us-west-2:123456789012:loadbalancer/app/myapp-alb/1234567890123456 \
  --protocol HTTP \
  --port 80 \
  --default-actions Type=redirect,RedirectConfig='{Protocol=HTTPS,Port=443,StatusCode=HTTP_301}'
```

#### GCP Cloud Load Balancer SSL 설정
```bash
# SSL 인증서 생성
gcloud compute ssl-certificates create myapp-ssl \
  --domains myapp.example.com \
  --global

# HTTPS 프록시 생성
gcloud compute target-https-proxies create myapp-https-proxy \
  --url-map myapp-url-map \
  --ssl-certificates myapp-ssl

# 전역 IP 주소 생성
gcloud compute addresses create myapp-ip \
  --global

# 전역 포워딩 규칙 생성
gcloud compute forwarding-rules create myapp-https-rule \
  --global \
  --target-https-proxy myapp-https-proxy \
  --address myapp-ip \
  --ports 443
```

#### CDN 설정
```bash
# AWS CloudFront 배포 생성
aws cloudfront create-distribution \
  --distribution-config file://cloudfront-config.json

# GCP Cloud CDN 설정
gcloud compute backend-services update myapp-backend-service \
  --global \
  --enable-cdn \
  --cache-mode CACHE_ALL_STATIC \
  --default-ttl 3600 \
  --max-ttl 86400
```

</details>

<details>
<summary>🔧 4단계: 배포 자동화</summary>

#### GitHub Actions를 통한 ECS 배포
```yaml
# .github/workflows/deploy-ecs.yml
name: Deploy to ECS

on:
  push:
    branches: [ main ]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    
    - name: Configure AWS credentials
      uses: aws-actions/configure-aws-credentials@v2
      with:
        aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
        aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        aws-region: us-west-2
    
    - name: Login to Amazon ECR
      id: login-ecr
      uses: aws-actions/amazon-ecr-login@v1
    
    - name: Build, tag, and push image to Amazon ECR
      id: build-image
      env:
        ECR_REGISTRY: ${{ steps.login-ecr.outputs.registry }}
        ECR_REPOSITORY: myapp
        IMAGE_TAG: ${{ github.sha }}
      run: |
        docker build -t $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG .
        docker push $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG
        echo "image=$ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG" >> $GITHUB_OUTPUT
    
    - name: Deploy Amazon ECS task definition
      uses: aws-actions/amazon-ecs-deploy-task-definition@v1
      with:
        task-definition: task-definition.json
        service: myapp-service
        cluster: my-ecs-cluster
        wait-for-service-stability: true
```

#### GitHub Actions를 통한 Cloud Run 배포
```yaml
# .github/workflows/deploy-cloud-run.yml
name: Deploy to Cloud Run

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
        service_account_key: ${{ secrets.GCP_SA_KEY }}
        project_id: ${{ secrets.GCP_PROJECT_ID }}
    
    - name: Configure Docker to use gcloud as a credential helper
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
          --region us-central1 \
          --allow-unauthenticated
```

</details>

---

## 📚 참고 자료

### 유용한 명령어
```bash
# AWS ECS 명령어
aws ecs list-services --cluster my-ecs-cluster
aws ecs describe-services --cluster my-ecs-cluster --services myapp-service
aws ecs update-service --cluster my-ecs-cluster --service myapp-service --force-new-deployment
aws ecs delete-service --cluster my-ecs-cluster --service myapp-service

# GCP Cloud Run 명령어
gcloud run services list
gcloud run services describe myapp --region us-central1
gcloud run services update myapp --region us-central1 --image gcr.io/my-project/myapp:latest
gcloud run services delete myapp --region us-central1

# 로드 밸런서 명령어
aws elbv2 describe-load-balancers
gcloud compute url-maps list
```

### 문제 해결
1. **ECS 서비스 배포 실패**
   - 태스크 정의 확인
   - 서브넷 및 보안 그룹 확인
   - IAM 역할 확인
   - 로드 밸런서 설정 확인

2. **Cloud Run 배포 실패**
   - 이미지 존재 여부 확인
   - 권한 설정 확인
   - 리소스 제한 확인
   - 네트워크 설정 확인

3. **SSL 인증서 문제**
   - 도메인 소유권 확인
   - DNS 설정 확인
   - 인증서 상태 확인
   - 리다이렉트 설정 확인

---

## 🧹 실습 정리

### 자동 정리
```bash
# 클라우드 배포 실습 자동 정리
./mcp_knowledge_base/cloud_intermediate/repo/scripts/cloud-deployment-practice.sh --cleanup
```

### 수동 정리
```bash
# AWS ECS 리소스 정리
aws ecs delete-service --cluster my-ecs-cluster --service myapp-service
aws ecs delete-cluster --cluster my-ecs-cluster
aws elbv2 delete-load-balancer --load-balancer-arn arn:aws:elasticloadbalancing:us-west-2:123456789012:loadbalancer/app/myapp-alb/1234567890123456

# GCP Cloud Run 리소스 정리
gcloud run services delete myapp --region us-central1
gcloud run domain-mappings delete myapp.example.com --region us-central1

# SSL 인증서 정리
aws acm delete-certificate --certificate-arn arn:aws:acm:us-east-1:123456789012:certificate/12345678-1234-1234-1234-123456789012
gcloud compute ssl-certificates delete myapp-ssl --global
```

### 정리 확인
- [ ] AWS ECS 리소스 삭제 완료
- [ ] GCP Cloud Run 리소스 삭제 완료
- [ ] 로드 밸런서 정리 완료
- [ ] SSL 인증서 정리 완료
- [ ] 비용 발생 확인

---

## 🔗 관련 자료

### 📚 실습 가이드
- ["CI/CD 파이프라인"][cicd-pipeline.md]
- ["모니터링 기초"][monitoring-basics.md]

### 🛠️ 설치 가이드
- ["AWS CLI 설정"][_setup_wsl/install-aws-cli-wsl.sh]
- ["GCP CLI 설정"][_setup_wsl/install-gcp-cli-wsl.sh]

### 🏠 네비게이션
<div align="center">

["← 이전: CI/CD 파이프라인"][cicd-pipeline.md] | 
["📚 전체 커리큘럼"][../../../curriculum.md] | 
["🏠 학습 경로로 돌아가기"][../../../index.md] | 
["다음: 모니터링 기초 →"][monitoring-basics.md]

</div>
