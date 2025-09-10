#!/bin/bash

# Container 과정용 실습 환경 설정 스크립트
# Master 과정의 actions-demo 프로젝트를 기반으로 Container 과정용 환경 구성

set -e

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 로그 함수
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 변수 설정
MASTER_PROJECT_PATH="../cloud_master/textbook/Day1/actions-demo"
CONTAINER_PROJECT_PATH="./container-demo"
PROJECT_NAME="container-demo"

log_info "=== Container 과정용 실습 환경 설정 시작 ==="

# 1단계: Master 과정 프로젝트 복사
log_info "1단계: Master 과정 프로젝트 복사"
if [ -d "$MASTER_PROJECT_PATH" ]; then
    cp -r "$MASTER_PROJECT_PATH" "$CONTAINER_PROJECT_PATH"
    log_success "Master 과정 프로젝트 복사 완료"
else
    log_error "Master 과정 프로젝트를 찾을 수 없습니다: $MASTER_PROJECT_PATH"
    exit 1
fi

cd "$CONTAINER_PROJECT_PATH"

# 2단계: Container 과정용 디렉토리 구조 생성
log_info "2단계: Container 과정용 디렉토리 구조 생성"
mkdir -p k8s/aws-ecs
mkdir -p k8s/gcp-gke
mkdir -p k8s/monitoring
mkdir -p scripts
mkdir -p docs

log_success "디렉토리 구조 생성 완료"

# 3단계: 고급 워크플로우 활성화
log_info "3단계: 고급 워크플로우 활성화"
if [ -f ".github/workflows/aws-deploy.yml.disabled" ]; then
    mv .github/workflows/aws-deploy.yml.disabled .github/workflows/aws-deploy.yml
    log_success "AWS ECS 배포 워크플로우 활성화"
fi

if [ -f ".github/workflows/gcp-deploy.yml.disabled" ]; then
    mv .github/workflows/gcp-deploy.yml.disabled .github/workflows/gcp-deploy.yml
    log_success "GCP Cloud Run 배포 워크플로우 활성화"
fi

if [ -f ".github/workflows/multi-cloud-deploy.yml.disabled" ]; then
    mv .github/workflows/multi-cloud-deploy.yml.disabled .github/workflows/multi-cloud-deploy.yml
    log_success "멀티클라우드 배포 워크플로우 활성화"
fi

# 4단계: Container 과정용 Dockerfile 개선
log_info "4단계: Container 과정용 Dockerfile 개선"
cat > Dockerfile.container << 'EOF'
# 멀티스테이지 빌드를 사용한 최적화된 Dockerfile
# Container 과정용 고급 Dockerfile

# 빌드 스테이지
FROM node:18-alpine AS builder

WORKDIR /app

# 의존성 파일 복사 및 설치
COPY package*.json ./
RUN npm ci --only=production && npm cache clean --force

# 애플리케이션 코드 복사
COPY . .

# 프로덕션 스테이지
FROM node:18-alpine AS production

# 보안을 위한 비루트 사용자 생성
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nextjs -u 1001

WORKDIR /app

# 빌드 스테이지에서 의존성 복사
COPY --from=builder --chown=nextjs:nodejs /app/node_modules ./node_modules
COPY --from=builder --chown=nextjs:nodejs /app/package*.json ./
COPY --from=builder --chown=nextjs:nodejs /app/app.js ./

# 비루트 사용자로 전환
USER nextjs

# 헬스체크 추가
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD node -e "require('http').get('http://localhost:3000/health', (res) => { process.exit(res.statusCode === 200 ? 0 : 1) })"

# 포트 노출
EXPOSE 3000

# 애플리케이션 실행
CMD ["node", "app.js"]
EOF

log_success "Container 과정용 Dockerfile 생성 완료"

# 5단계: Kubernetes 매니페스트 생성
log_info "5단계: Kubernetes 매니페스트 생성"

# AWS ECS용 태스크 정의
cat > k8s/aws-ecs/task-definition.json << 'EOF'
{
  "family": "container-demo-task",
  "networkMode": "awsvpc",
  "requiresCompatibilities": ["FARGATE"],
  "cpu": "512",
  "memory": "1024",
  "executionRoleArn": "arn:aws:iam::ACCOUNT_ID:role/ecsTaskExecutionRole",
  "taskRoleArn": "arn:aws:iam::ACCOUNT_ID:role/ecsTaskRole",
  "containerDefinitions": [
    {
      "name": "container-demo",
      "image": "ACCOUNT_ID.dkr.ecr.REGION.amazonaws.com/container-demo:latest",
      "portMappings": [
        {
          "containerPort": 3000,
          "protocol": "tcp"
        }
      ],
      "essential": true,
      "environment": [
        {
          "name": "NODE_ENV",
          "value": "production"
        }
      ],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/container-demo",
          "awslogs-region": "REGION",
          "awslogs-stream-prefix": "ecs"
        }
      },
      "healthCheck": {
        "command": [
          "CMD-SHELL",
          "curl -f http://localhost:3000/health || exit 1"
        ],
        "interval": 30,
        "timeout": 5,
        "retries": 3,
        "startPeriod": 60
      }
    }
  ]
}
EOF

# GCP GKE용 Deployment
cat > k8s/gcp-gke/deployment.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: container-demo-deployment
  labels:
    app: container-demo
spec:
  replicas: 3
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 1
  selector:
    matchLabels:
      app: container-demo
  template:
    metadata:
      labels:
        app: container-demo
    spec:
      containers:
      - name: container-demo
        image: gcr.io/PROJECT_ID/container-demo:latest
        ports:
        - containerPort: 3000
        env:
        - name: NODE_ENV
          value: "production"
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "512Mi"
            cpu: "500m"
        livenessProbe:
          httpGet:
            path: /health
            port: 3000
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /health
            port: 3000
          initialDelaySeconds: 5
          periodSeconds: 5
---
apiVersion: v1
kind: Service
metadata:
  name: container-demo-service
spec:
  selector:
    app: container-demo
  ports:
  - protocol: TCP
    port: 80
    targetPort: 3000
  type: LoadBalancer
---
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: container-demo-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: container-demo-deployment
  minReplicas: 1
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
EOF

log_success "Kubernetes 매니페스트 생성 완료"

# 6단계: 모니터링 설정 파일 생성
log_info "6단계: 모니터링 설정 파일 생성"

# Prometheus 설정
cat > k8s/monitoring/prometheus-config.yaml << 'EOF'
apiVersion: v1
kind: ConfigMap
metadata:
  name: prometheus-config
data:
  prometheus.yml: |
    global:
      scrape_interval: 15s
    scrape_configs:
    - job_name: 'container-demo'
      static_configs:
      - targets: ['container-demo-service:80']
      metrics_path: /metrics
      scrape_interval: 5s
EOF

# Grafana 설정
cat > k8s/monitoring/grafana-dashboard.json << 'EOF'
{
  "dashboard": {
    "title": "Container Demo Dashboard",
    "panels": [
      {
        "title": "CPU Usage",
        "type": "graph",
        "targets": [
          {
            "expr": "rate(container_cpu_usage_seconds_total[5m])",
            "legendFormat": "CPU Usage"
          }
        ]
      },
      {
        "title": "Memory Usage",
        "type": "graph",
        "targets": [
          {
            "expr": "container_memory_usage_bytes",
            "legendFormat": "Memory Usage"
          }
        ]
      }
    ]
  }
}
EOF

log_success "모니터링 설정 파일 생성 완료"

# 7단계: 실습 스크립트 생성
log_info "7단계: 실습 스크립트 생성"

# AWS ECS 배포 스크립트
cat > scripts/deploy-aws-ecs.sh << 'EOF'
#!/bin/bash

# AWS ECS 배포 스크립트
set -e

echo "🚀 AWS ECS 배포 시작"

# ECR 리포지토리 생성
aws ecr create-repository --repository-name container-demo --region $AWS_REGION || true

# ECR 로그인
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com

# 이미지 빌드 및 푸시
docker build -f Dockerfile.container -t container-demo .
docker tag container-demo:latest $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/container-demo:latest
docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/container-demo:latest

# ECS 클러스터 생성
aws ecs create-cluster --cluster-name container-demo-cluster --region $AWS_REGION || true

# 태스크 정의 등록
aws ecs register-task-definition --cli-input-json file://k8s/aws-ecs/task-definition.json --region $AWS_REGION

echo "✅ AWS ECS 배포 완료"
EOF

# GCP GKE 배포 스크립트
cat > scripts/deploy-gcp-gke.sh << 'EOF'
#!/bin/bash

# GCP GKE 배포 스크립트
set -e

echo "🚀 GCP GKE 배포 시작"

# GCR에 이미지 푸시
gcloud builds submit --tag gcr.io/$GCP_PROJECT_ID/container-demo .

# GKE 클러스터 생성
gcloud container clusters create container-demo-cluster \
  --zone $GCP_ZONE \
  --num-nodes 3 \
  --machine-type e2-medium

# 클러스터 인증
gcloud container clusters get-credentials container-demo-cluster --zone $GCP_ZONE

# 애플리케이션 배포
kubectl apply -f k8s/gcp-gke/deployment.yaml

echo "✅ GCP GKE 배포 완료"
EOF

chmod +x scripts/*.sh

log_success "실습 스크립트 생성 완료"

# 8단계: README 업데이트
log_info "8단계: README 업데이트"
cat > README.container.md << 'EOF'
# Container 과정용 실습 프로젝트

## 🎯 프로젝트 개요

이 프로젝트는 **Container 과정**을 위한 실습 프로젝트입니다.
Master 과정의 actions-demo 프로젝트를 기반으로 하여 고급 컨테이너 기술을 학습합니다.

## 📋 학습 내용

### Day 1: 컨테이너 기술 심화
- Docker 최적화 (멀티스테이지 빌드)
- GitHub Actions 고급 기능
- AWS ECS (Fargate) 배포
- GCP Cloud Run 배포
- GCP GKE 배포

### Day 2: 고가용성 아키텍처
- Multi-AZ 구성
- 로드 밸런싱 설정
- Auto Scaling 구성
- 모니터링 및 로깅
- 운영 자동화

## 🚀 빠른 시작

### 1단계: 환경 설정
```bash
# Container 과정용 환경 설정
./container-demo-setup.sh
```

### 2단계: AWS ECS 배포
```bash
# 환경 변수 설정
export AWS_ACCOUNT_ID=your-account-id
export AWS_REGION=ap-northeast-2

# AWS ECS 배포
./scripts/deploy-aws-ecs.sh
```

### 3단계: GCP GKE 배포
```bash
# 환경 변수 설정
export GCP_PROJECT_ID=your-project-id
export GCP_ZONE=asia-northeast3-a

# GCP GKE 배포
./scripts/deploy-gcp-gke.sh
```

## 📚 참고 자료

- [Master 과정 연계 가이드](./master-integration-guide.md)
- [Container 오케스트레이션 가이드](./container-orchestration-guide.md)
EOF

log_success "README 업데이트 완료"

# 9단계: 완료 메시지
log_success "=== Container 과정용 실습 환경 설정 완료 ==="
log_info "프로젝트 경로: $CONTAINER_PROJECT_PATH"
log_info "다음 단계: README.container.md를 참고하여 실습을 시작하세요"

echo ""
echo "📋 생성된 파일들:"
echo "├── k8s/aws-ecs/task-definition.json"
echo "├── k8s/gcp-gke/deployment.yaml"
echo "├── k8s/monitoring/prometheus-config.yaml"
echo "├── scripts/deploy-aws-ecs.sh"
echo "├── scripts/deploy-gcp-gke.sh"
echo "├── Dockerfile.container"
echo "└── README.container.md"
echo ""
echo "🎯 다음 단계:"
echo "1. 환경 변수 설정"
echo "2. AWS ECS 또는 GCP GKE 배포 실습"
echo "3. 모니터링 설정 및 테스트"
