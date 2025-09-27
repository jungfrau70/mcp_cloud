# ☁️ 클라우드 중급 과정 - Day 2: CI/CD 및 고급 클라우드 배포, 멀티 클라우드 모니터링

## 🎯 학습 목표

### 핵심 학습 목표
- **CI/CD 파이프라인** GitHub Actions를 활용한 자동화된 빌드, 테스트, 배포 파이프라인을 구축합니다.
- **멀티 클라우드 통합 모니터링** AWS EKS, GCP GKE를 연동한 통합 모니터링 시스템을 구축합니다.
- **AWS Application 모니터링** EKS 애플리케이션 배포 및 모니터링을 통해 실무 역량을 강화합니다.
- **GCP 클러스터 통합** GKE 클러스터 구축 및 멀티 클라우드 모니터링을 완성합니다.

### 실습 후 달성할 수 있는 능력
- ✅ GitHub Actions CI/CD 파이프라인 구축 및 운영
- ✅ 멀티 클라우드 환경에서의 통합 모니터링 시스템 구축
- ✅ AWS EKS 및 GCP GKE 클러스터 운영
- ✅ 실무 수준의 DevOps 자동화 역량

### 예상 소요 시간
- **CI/CD 파이프라인**: 90-120분
- **멀티 클라우드 통합 모니터링**: 90-120분
- **AWS Application 모니터링**: 90-120분
- **GCP 클러스터 통합**: 90-120분
- **전체 과정**: 6-8시간

---

## 🛠️ 실습 학습

### 📁 실습 코드 및 자동화
- **실습 샘플 코드**: `/mcp_knowledge_base/cloud_intermediate/repo/samples/day2/`
- **자동화 스크립트**: `/mcp_knowledge_base/cloud_intermediate/repo/automation/day2/`
- **클라우드 스크립트**: `/mcp_knowledge_base/cloud_intermediate/repo/cloud-scripts/`

<details>
<summary>🚀 실습 환경 준비</summary>

#### 필수 도구
- **GitHub Actions**: CI/CD 파이프라인 자동화
- **AWS CLI**: AWS 서비스 관리 도구
- **GCP CLI**: GCP 서비스 관리 도구
- **kubectl**: Kubernetes 클러스터 관리 도구

#### 환경 설정
```bash
# GitHub Actions 설정 확인
gh auth status

# AWS CLI 설정 확인
aws sts get-caller-identity

# GCP CLI 설정 확인
gcloud auth list

# kubectl 설정 확인
kubectl version --client
```

</details>

<details>
<summary>🔧 1교시: GitHub Actions CI/CD 파이프라인</summary>

#### GitHub Actions 워크플로우 생성
```bash
# .github/workflows/ci-cd.yml 생성
mkdir -p .github/workflows
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
EOF

# 워크플로우 파일 권한 설정
chmod +x .github/workflows/ci-cd.yml
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
docker build -t cicd-practice-app:latest .

# 보안 스캔 실행
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
  aquasec/trivy image cicd-practice-app:latest
```

</details>

<details>
<summary>🔧 2교시: 멀티 클라우드 통합 모니터링 시스템</summary>

#### Phase 1: 통합 모니터링 허브 구축
```bash
# AWS EC2 인스턴스 생성 (모니터링 허브)
aws ec2 run-instances \
    --image-id ami-0c02fb55956c7d316 \
    --instance-type t3.medium \
    --key-name my-key \
    --security-group-ids sg-12345 \
    --subnet-id subnet-12345 \
    --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=monitoring-hub}]'

# 인스턴스 상태 확인
aws ec2 describe-instances --filters "Name=tag:Name,Values=monitoring-hub"
```

#### Phase 2: AWS 클러스터 모니터링
```bash
# EKS 클러스터 생성
aws eks create-cluster \
    --name aws-monitoring-cluster \
    --role-arn arn:aws:iam::ACCOUNT:role/eks-cluster-role \
    --resources-vpc-config subnetIds=subnet-12345,subnet-67890,securityGroupIds=sg-12345

# 클러스터 상태 확인
aws eks describe-cluster --name aws-monitoring-cluster

# kubectl 설정
aws eks update-kubeconfig --name aws-monitoring-cluster --region us-west-2
```

#### Prometheus 스택 배포
```bash
# Prometheus 스택 배포
kubectl apply -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/main/bundle.yaml

# Prometheus 인스턴스 생성
cat > prometheus-instance.yaml << 'EOF'
apiVersion: monitoring.coreos.com/v1
kind: Prometheus
metadata:
  name: prometheus
spec:
  serviceAccountName: prometheus
  serviceMonitorSelector:
    matchLabels:
      team: frontend
  resources:
    requests:
      memory: 400Mi
  enableAdminAPI: false
EOF

kubectl apply -f prometheus-instance.yaml
```

</details>

<details>
<summary>🔧 3교시: AWS Application 모니터링</summary>

#### 애플리케이션 배포 매니페스트 생성
```bash
# 애플리케이션 Deployment 생성
cat > aws-app-deployment.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: aws-monitoring-app
  labels:
    app: aws-monitoring-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: aws-monitoring-app
  template:
    metadata:
      labels:
        app: aws-monitoring-app
    spec:
      containers:
      - name: app
        image: nginx:1.21
        ports:
        - containerPort: 80
        resources:
          requests:
            memory: "64Mi"
            cpu: "250m"
          limits:
            memory: "128Mi"
            cpu: "500m"
EOF

# Service 생성
cat > aws-app-service.yaml << 'EOF'
apiVersion: v1
kind: Service
metadata:
  name: aws-monitoring-app-service
  labels:
    app: aws-monitoring-app
spec:
  selector:
    app: aws-monitoring-app
  ports:
  - port: 80
    targetPort: 80
  type: LoadBalancer
EOF

# ServiceMonitor 생성
cat > aws-app-servicemonitor.yaml << 'EOF'
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: aws-monitoring-app
  labels:
    team: frontend
spec:
  selector:
    matchLabels:
      app: aws-monitoring-app
  endpoints:
  - port: http
    interval: 30s
EOF

# 리소스 배포
kubectl apply -f aws-app-deployment.yaml
kubectl apply -f aws-app-service.yaml
kubectl apply -f aws-app-servicemonitor.yaml
```

#### 애플리케이션 모니터링 확인
```bash
# 배포 상태 확인
kubectl get pods -l app=aws-monitoring-app
kubectl get services
kubectl get servicemonitors

# 애플리케이션 로그 확인
kubectl logs -l app=aws-monitoring-app

# Prometheus 타겟 확인
kubectl port-forward svc/prometheus 9090:9090
curl http://localhost:9090/api/v1/targets
```

</details>

<details>
<summary>🔧 4교시: GCP 클러스터 통합 모니터링</summary>

#### GCP GKE 클러스터 생성
```bash
# GKE 클러스터 생성
gcloud container clusters create gcp-monitoring-cluster \
    --zone us-central1-a \
    --num-nodes 3 \
    --machine-type e2-medium \
    --enable-ip-alias \
    --enable-autoscaling \
    --min-nodes 1 \
    --max-nodes 5

# 클러스터 연결
gcloud container clusters get-credentials gcp-monitoring-cluster \
    --zone us-central1-a

# 클러스터 상태 확인
kubectl get nodes
kubectl get pods --all-namespaces
```

#### GCP Infrastructure/Platform 모니터링 설정
```bash
# Prometheus 스택 배포
kubectl apply -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/main/bundle.yaml

# Prometheus 인스턴스 생성
cat > gcp-prometheus-instance.yaml << 'EOF'
apiVersion: monitoring.coreos.com/v1
kind: Prometheus
metadata:
  name: gcp-prometheus
spec:
  serviceAccountName: prometheus
  serviceMonitorSelector:
    matchLabels:
      team: backend
  resources:
    requests:
      memory: 400Mi
  enableAdminAPI: false
EOF

kubectl apply -f gcp-prometheus-instance.yaml
```

#### Global Prometheus에 GCP 클러스터 연동
```bash
# GCP 클러스터 메트릭 수집 설정
cat > gcp-cluster-monitoring.yaml << 'EOF'
apiVersion: v1
kind: ConfigMap
metadata:
  name: gcp-cluster-config
data:
  prometheus.yml: |
    global:
      scrape_interval: 15s
    scrape_configs:
    - job_name: 'gcp-cluster'
      static_configs:
      - targets: ['gcp-monitoring-cluster:9090']
      metrics_path: '/federate'
      params:
        'match[]':
        - '{job=~".*"}'
EOF

kubectl apply -f gcp-cluster-monitoring.yaml
```

</details>

<details>
<summary>🔧 5교시: AWS ECS 고급 배포</summary>

#### ECS 클러스터 생성
```bash
# ECS 클러스터 생성
aws ecs create-cluster \
    --cluster-name production-cluster \
    --capacity-providers FARGATE \
    --default-capacity-provider-strategy capacityProvider=FARGATE,weight=1

# 클러스터 상태 확인
aws ecs describe-clusters --clusters production-cluster
```

#### Application Load Balancer 설정
```bash
# ALB 생성
aws elbv2 create-load-balancer \
    --name production-alb \
    --subnets subnet-12345 subnet-67890 \
    --security-groups sg-12345

# 타겟 그룹 생성
aws elbv2 create-target-group \
    --name production-targets \
    --protocol HTTP \
    --port 80 \
    --vpc-id vpc-12345 \
    --target-type ip

# 리스너 생성
aws elbv2 create-listener \
    --load-balancer-arn arn:aws:elasticloadbalancing:region:account:loadbalancer/app/production-alb/1234567890123456 \
    --protocol HTTP \
    --port 80 \
    --default-actions Type=forward,TargetGroupArn=arn:aws:elasticloadbalancing:region:account:targetgroup/production-targets/1234567890123456
```

#### ECS 서비스 배포
```bash
# 태스크 정의 생성
cat > task-definition.json << 'EOF'
{
  "family": "production-app",
  "networkMode": "awsvpc",
  "requiresCompatibilities": ["FARGATE"],
  "cpu": "512",
  "memory": "1024",
  "executionRoleArn": "arn:aws:iam::ACCOUNT:role/ecsTaskExecutionRole",
  "containerDefinitions": [
    {
      "name": "production-app",
      "image": "nginx:1.21",
      "portMappings": [
        {
          "containerPort": 80,
          "protocol": "tcp"
        }
      ],
      "essential": true,
      "healthCheck": {
        "command": ["CMD-SHELL", "curl -f http://localhost/ || exit 1"],
        "interval": 30,
        "timeout": 5,
        "retries": 3
      }
    }
  ]
}
EOF

# 태스크 정의 등록
aws ecs register-task-definition --cli-input-json file://task-definition.json

# ECS 서비스 생성
aws ecs create-service \
    --cluster production-cluster \
    --service-name production-service \
    --task-definition production-app:1 \
    --desired-count 3 \
    --launch-type FARGATE \
    --network-configuration "awsvpcConfiguration={subnets=[subnet-12345,subnet-67890],securityGroups=[sg-12345],assignPublicIp=ENABLED}" \
    --load-balancers "targetGroupArn=arn:aws:elasticloadbalancing:region:account:targetgroup/production-targets/1234567890123456,containerName=production-app,containerPort=80"
```

</details>

<details>
<summary>🔧 6교시: GCP Cloud Run 고급 배포</summary>

#### Docker 이미지 빌드 및 푸시
```bash
# Docker 이미지 빌드
docker build -t gcr.io/PROJECT_ID/cloud-run-app:latest .

# GCP Container Registry에 푸시
docker push gcr.io/PROJECT_ID/cloud-run-app:latest

# 이미지 푸시 확인
gcloud container images list --repository gcr.io/PROJECT_ID
```

#### Cloud Run 서비스 배포
```bash
# Cloud Run 서비스 배포
gcloud run deploy cloud-run-app \
    --image gcr.io/PROJECT_ID/cloud-run-app:latest \
    --platform managed \
    --region us-central1 \
    --allow-unauthenticated \
    --memory 512Mi \
    --cpu 1 \
    --max-instances 10 \
    --min-instances 1

# 서비스 상태 확인
gcloud run services describe cloud-run-app --region us-central1
```

#### 도메인 매핑 설정
```bash
# 도메인 매핑
gcloud run domain-mappings create \
    --service cloud-run-app \
    --domain your-domain.com \
    --region us-central1

# SSL 인증서 자동 생성 확인
gcloud run domain-mappings describe your-domain.com --region us-central1
```

#### 트래픽 분할 설정
```bash
# 트래픽 분할 설정
gcloud run services update-traffic cloud-run-app \
    --to-latest \
    --region us-central1

# 카나리 배포 설정
gcloud run services update-traffic cloud-run-app \
    --to-revisions cloud-run-app-00001-abc=90,cloud-run-app-00002-def=10 \
    --region us-central1
```

</details>

---

## 📚 참고 자료

### 유용한 명령어
```bash
# GitHub Actions 관리
gh workflow list
gh workflow run ci-cd.yml

# AWS ECS 관리
aws ecs list-clusters
aws ecs list-services --cluster production-cluster
aws ecs describe-tasks --cluster production-cluster --tasks TASK_ARN

# GCP Cloud Run 관리
gcloud run services list
gcloud run services describe cloud-run-app --region us-central1
gcloud logging read "resource.type=cloud_run_revision" --limit 50

# Kubernetes 관리
kubectl get all
kubectl logs -l app=aws-monitoring-app
kubectl exec -it POD_NAME -- /bin/bash
```

### 문제 해결
1. **GitHub Actions 워크플로우 실패**
   - Actions 탭에서 워크플로우 실행 로그 확인
   - 로컬에서 동일한 명령어 실행 테스트
   - 시크릿 및 환경 변수 설정 확인

2. **AWS ECS 태스크 시작 실패**
   - IAM 역할 권한 확인
   - 서브넷 및 보안 그룹 설정 확인
   - 태스크 정의 문법 확인

3. **GCP Cloud Run 배포 실패**
   - 이미지 푸시 상태 확인
   - 서비스 계정 권한 확인
   - 리전 및 리소스 제한 확인

---

## 🧹 실습 정리

### 자동 정리
```bash
# Day2 실습 자동 정리
./mcp_knowledge_base/cloud_intermediate/repo/automation/day2/cleanup.sh
```

### 수동 정리
```bash
# AWS ECS 리소스 정리
aws ecs delete-service --cluster production-cluster --service production-service
aws ecs delete-cluster --cluster production-cluster

# GCP Cloud Run 리소스 정리
gcloud run services delete cloud-run-app --region us-central1

# Kubernetes 리소스 정리
kubectl delete all --all
kubectl delete servicemonitors --all
```

### 정리 확인
- [ ] GitHub Actions 워크플로우 정상 동작 확인
- [ ] AWS ECS 리소스 정리 완료
- [ ] GCP Cloud Run 리소스 정리 완료
- [ ] 멀티 클라우드 모니터링 시스템 정상 동작 확인

---

## 🔗 관련 문서

- [학습 경로 (Learning Path)](./learning-path.md)
- [1일차 강의안 (Day1_강의안)](./Day1_강의안.md)
- [통합 강의 시나리오 (Integrated Lecture Scenario)](./통합강의시나리오.md)
- [통합 모니터링 시나리오 (Integrated Monitoring Scenario)](./통합모니터링시나리오.md)

---

**💡 궁금한 점이 있으시면 언제든 문의해주세요!**  
**문제가 발생하거나 도움이 필요하시면 실시간으로 지원해드리겠습니다.**