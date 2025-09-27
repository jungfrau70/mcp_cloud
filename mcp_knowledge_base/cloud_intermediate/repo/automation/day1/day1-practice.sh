#!/bin/bash

# Cloud Intermediate Day 1 실습 스크립트
# Docker 고급 활용, Kubernetes 기초, 클라우드 컨테이너 서비스

# 오류 처리 설정
set -e
set -u
set -o pipefail

# 리소스 관리 유틸리티 로드
source "$(dirname "$0")/../../tools/monitoring/resource-manager.sh"

# 사용법 출력
usage() {
    echo "Cloud Intermediate Day 1 실습 스크립트"
    echo ""
    echo "사용법:"
    echo "  $0 [옵션]                    # Interactive 모드"
    echo "  $0 --action <액션> [파라미터] # Parameter 모드"
    echo ""
    echo "Interactive 모드 옵션:"
    echo "  --interactive, -i           # Interactive 모드 (기본값)"
    echo "  --help, -h                   # 도움말 표시"
    echo ""
    echo "Parameter 모드 액션:"
    echo "  --action docker-advanced     # Docker 고급 실습"
    echo "  --action kubernetes-basics   # Kubernetes 기초 실습"
    echo "  --action cloud-services     # 클라우드 컨테이너 서비스"
    echo "  --action cluster-status     # 클러스터 현황 확인"
    echo "  --action deployment         # 배포 관리"
    echo "  --action cluster            # 클러스터 관리"
    echo "  --action monitoring-hub    # 모니터링 허브 구축"
    echo "  --action cleanup            # 실습 환경 정리"
    echo "  --action all                # 전체 실습 실행"
    echo ""
    echo "예시:"
    echo "  $0                          # Interactive 모드"
    echo "  $0 --action docker-advanced # Docker 고급 실습만 실행"
    echo "  $0 --action all             # 전체 실습 실행"
}

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

# 로그 함수들
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_header() { echo -e "${PURPLE}=== $1 ===${NC}"; }

# Docker 고급 실습
docker_advanced_practice() {
    log_header "Docker 고급 실습"
    
    local practice_dir="day1-docker-advanced"
    smart_mkdir "$practice_dir" false
    cd "$practice_dir"
    
    # 1. 최적화된 Dockerfile 생성
    log_info "1. 최적화된 Dockerfile 생성"
    cat > Dockerfile << 'EOF'
FROM node:18-alpine AS builder
WORKDIR /app

# 의존성 파일만 먼저 복사 (캐시 최적화)
COPY package*.json ./
RUN npm install --only=production && npm cache clean --force

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
EOF

    # 2. package.json 생성
    cat > package.json << 'EOF'
{
  "name": "myapp",
  "version": "1.0.0",
  "description": "Sample Node.js application for Docker practice",
  "main": "index.js",
  "scripts": {
    "start": "node index.js",
    "test": "echo \"Error: no test specified\" && exit 1"
  },
  "dependencies": {
    "express": "^4.18.2"
  }
}
EOF

    # 3. 간단한 Node.js 앱 생성
    cat > index.js << 'EOF'
const express = require('express');
const app = express();
const port = process.env.PORT || 3000;

app.get('/', (req, res) => {
  res.json({ 
    message: 'Hello from optimized Docker container!',
    timestamp: new Date().toISOString(),
    environment: process.env.NODE_ENV || 'development'
  });
});

app.get('/health', (req, res) => {
  res.json({ 
    status: 'healthy', 
    timestamp: new Date().toISOString(),
    uptime: process.uptime()
  });
});

app.get('/info', (req, res) => {
  res.json({
    nodeVersion: process.version,
    platform: process.platform,
    memory: process.memoryUsage(),
    env: process.env.NODE_ENV || 'development'
  });
});

app.listen(port, '0.0.0.0', () => {
  console.log(`App listening at http://0.0.0.0:${port}`);
});
EOF

    # 4. Docker Compose 파일 생성
    cat > docker-compose.yml << 'EOF'
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
      - redis
    networks:
      - app-network
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "wget", "--no-verbose", "--tries=1", "--spider", "http://localhost:3000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s

  db:
    image: postgres:13-alpine
    environment:
      POSTGRES_DB: myapp
      POSTGRES_USER: user
      POSTGRES_PASSWORD: password
    volumes:
      - postgres_data:/var/lib/postgresql/data
    networks:
      - app-network
    restart: unless-stopped
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U user -d myapp"]
      interval: 10s
      timeout: 5s
      retries: 5

  redis:
    image: redis:6-alpine
    command: redis-server --appendonly yes
    volumes:
      - redis_data:/data
    networks:
      - app-network
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 5s
      retries: 3

volumes:
  postgres_data:
  redis_data:

networks:
  app-network:
    driver: bridge
EOF

    # 5. 이미지 빌드
    log_info "2. Docker 이미지 빌드"
    docker build -t myapp:optimized .
    
    # 6. 멀티스테이지 빌드 테스트
    log_info "3. 멀티스테이지 빌드 테스트"
    docker build --target builder -t myapp:builder .
    docker build --target runtime -t myapp:runtime .
    
    # 7. 이미지 크기 비교
    log_info "4. 이미지 크기 비교"
    echo "=== 이미지 크기 비교 ==="
    docker images | grep myapp | head -5
    
    # 8. Docker Compose 실행
    log_info "5. Docker Compose 실행"
    smart_docker_compose_up "docker-compose.yml" false
    
    # 9. 서비스 상태 확인
    log_info "6. 서비스 상태 확인"
    sleep 10
    docker-compose ps
    
    # 10. 헬스 체크
    log_info "7. 헬스 체크"
    sleep 5
    curl -f http://localhost:3000/health || log_warning "헬스 체크 실패"
    curl -f http://localhost:3000/info || log_warning "정보 엔드포인트 실패"
    
    log_success "Docker 고급 실습 완료"
    cd ..
}

# Kubernetes 기초 실습
kubernetes_basics_practice() {
    log_header "Kubernetes 기초 실습"
    
    local practice_dir="day1-kubernetes-basics"
    mkdir -p "$practice_dir"
    cd "$practice_dir"
    
    # 1. Pod 생성
    log_info "1. Pod 생성"
    cat > pod-basic.yaml << 'EOF'
apiVersion: v1
kind: Pod
metadata:
  name: myapp-pod
  labels:
    app: myapp
    tier: frontend
spec:
  containers:
  - name: myapp
    image: nginx:1.21
    ports:
    - containerPort: 80
    env:
    - name: ENV
      value: "development"
    resources:
      requests:
        memory: "64Mi"
        cpu: "250m"
      limits:
        memory: "128Mi"
        cpu: "500m"
    livenessProbe:
      httpGet:
        path: /
        port: 80
      initialDelaySeconds: 30
      periodSeconds: 10
    readinessProbe:
      httpGet:
        path: /
        port: 80
      initialDelaySeconds: 5
      periodSeconds: 5
EOF

    # 2. Deployment 생성
    cat > deployment-basic.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp-deployment
  labels:
    app: myapp
spec:
  replicas: 3
  selector:
    matchLabels:
      app: myapp
  template:
    metadata:
      labels:
        app: myapp
    spec:
      containers:
      - name: myapp
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
        livenessProbe:
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 5
          periodSeconds: 5
EOF

    # 3. Service 생성
    cat > service-basic.yaml << 'EOF'
apiVersion: v1
kind: Service
metadata:
  name: myapp-service
  labels:
    app: myapp
spec:
  selector:
    app: myapp
  ports:
  - port: 80
    targetPort: 80
    protocol: TCP
  type: ClusterIP
EOF

    # 4. ConfigMap 생성
    cat > configmap-basic.yaml << 'EOF'
apiVersion: v1
kind: ConfigMap
metadata:
  name: myapp-config
data:
  database_url: "postgresql://localhost:5432/myapp"
  redis_url: "redis://localhost:6379"
  app_name: "My Application"
  environment: "development"
  log_level: "info"
EOF

    # 5. Secret 생성
    cat > secret-basic.yaml << 'EOF'
apiVersion: v1
kind: Secret
metadata:
  name: myapp-secret
type: Opaque
data:
  username: YWRtaW4=  # base64 encoded "admin"
  password: cGFzc3dvcmQ=  # base64 encoded "password"
  api_key: YWJjZGVmZ2hpams=  # base64 encoded "abcdefghijk"
  database_password: cG9zdGdyZXNfcGFzc3dvcmQ=  # base64 encoded "postgres_password"
EOF

    # 6. AWS EKS 환경 확인 및 설정
    log_info "2. AWS EKS 환경 확인"
    if command -v aws &> /dev/null; then
        log_info "AWS CLI 확인됨"
        
        # AWS 자격 증명 확인
        if aws sts get-caller-identity &> /dev/null; then
            log_success "AWS 자격 증명 확인됨"
            
            # EKS 클러스터 목록 확인
            log_info "EKS 클러스터 확인 중..."
            local clusters=$(aws eks list-clusters --query 'clusters[]' --output text 2>/dev/null || echo "")
            
            if [ -n "$clusters" ]; then
                log_info "사용 가능한 EKS 클러스터: $clusters"
                
                # 첫 번째 클러스터 사용
                local cluster_name=$(echo "$clusters" | head -1)
                log_info "클러스터 '$cluster_name' 사용"
                
                # kubeconfig 업데이트
                aws eks update-kubeconfig --region us-west-2 --name "$cluster_name" 2>/dev/null || \
                aws eks update-kubeconfig --region us-east-1 --name "$cluster_name" 2>/dev/null || \
                aws eks update-kubeconfig --region ap-northeast-2 --name "$cluster_name" 2>/dev/null
                
                # 클러스터 연결 확인
                if kubectl cluster-info &> /dev/null; then
                    log_success "EKS 클러스터 연결 성공"
                else
                    log_warning "EKS 클러스터 연결 실패"
                fi
            else
                log_warning "EKS 클러스터가 없습니다. 새 클러스터를 생성하거나 기존 클러스터를 확인하세요."
                log_info "EKS 클러스터 생성 예시:"
                echo "  aws eks create-cluster --name my-cluster --role-arn arn:aws:iam::ACCOUNT:role/eksServiceRole --resources-vpc-config subnetIds=subnet-12345,subnet-67890"
            fi
        else
            log_error "AWS 자격 증명이 설정되지 않았습니다."
            log_info "AWS 자격 증명 설정:"
            echo "  aws configure"
            echo "  또는"
            echo "  export AWS_ACCESS_KEY_ID=your-key"
            echo "  export AWS_SECRET_ACCESS_KEY=your-secret"
        fi
    else
        log_error "AWS CLI가 설치되지 않았습니다."
        log_info "AWS CLI 설치:"
        echo "  curl 'https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip' -o 'awscliv2.zip'"
        echo "  unzip awscliv2.zip"
        echo "  sudo ./aws/install"
    fi

    # 7. EKS 리소스 생성
    log_info "3. EKS 리소스 생성"
    
    # EKS 클러스터 연결 확인
    if kubectl cluster-info &> /dev/null; then
        log_info "EKS 클러스터에 리소스 배포 중..."
        
        # 네임스페이스 생성
        kubectl create namespace day1-practice --dry-run=client -o yaml | kubectl apply -f -
        kubectl config set-context --current --namespace=day1-practice
        
        # 리소스 생성
        kubectl apply -f pod-basic.yaml
        kubectl apply -f deployment-basic.yaml
        kubectl apply -f service-basic.yaml
        kubectl apply -f configmap-basic.yaml
        kubectl apply -f secret-basic.yaml
        
        log_success "EKS 리소스 생성 완료"
    else
        log_warning "EKS 클러스터에 연결할 수 없습니다. 리소스 생성을 건너뜁니다."
        log_info "생성될 리소스 파일들:"
        echo "  - pod-basic.yaml"
        echo "  - deployment-basic.yaml" 
        echo "  - service-basic.yaml"
        echo "  - configmap-basic.yaml"
        echo "  - secret-basic.yaml"
    fi
    
    # 8. EKS 상태 확인
    log_info "4. EKS 리소스 상태 확인"
    
    if kubectl cluster-info &> /dev/null; then
        log_info "EKS 클러스터 리소스 상태:"
        kubectl get pods -n day1-practice
        kubectl get deployments -n day1-practice
        kubectl get services -n day1-practice
        kubectl get configmaps -n day1-practice
        kubectl get secrets -n day1-practice
        
        # 9. EKS 스케일링 테스트
        log_info "5. EKS Deployment 스케일링"
        kubectl scale deployment myapp-deployment --replicas=3 -n day1-practice
        sleep 15
        kubectl get pods -l app=myapp -n day1-practice
        
        # 10. EKS 롤링 업데이트 테스트
        log_info "6. EKS 롤링 업데이트 테스트"
        kubectl set image deployment/myapp-deployment myapp=nginx:1.22 -n day1-practice
        kubectl rollout status deployment/myapp-deployment -n day1-practice
        
        # 11. EKS 롤백 테스트
        log_info "7. EKS 롤백 테스트"
        kubectl rollout undo deployment/myapp-deployment -n day1-practice
        kubectl rollout status deployment/myapp-deployment -n day1-practice
        
        # 12. EKS 서비스 엔드포인트 확인
        log_info "8. EKS 서비스 엔드포인트 확인"
        kubectl get services -n day1-practice
        kubectl describe service myapp-service -n day1-practice
    else
        log_warning "EKS 클러스터에 연결할 수 없어 상태 확인을 건너뜁니다."
        log_info "EKS 클러스터 연결 후 다음 명령어로 확인하세요:"
        echo "  kubectl get pods -n day1-practice"
        echo "  kubectl get deployments -n day1-practice"
        echo "  kubectl get services -n day1-practice"
    fi
    
    log_success "Kubernetes 기초 실습 완료"
    cd ..
}

# 클라우드 컨테이너 서비스 실습 (EKS 중심)
cloud_container_services_practice() {
    log_header "클라우드 컨테이너 서비스 실습 (EKS 중심)"
    
    local practice_dir="day1-cloud-container-services"
    mkdir -p "$practice_dir"
    cd "$practice_dir"
    
    # AWS EKS 실습
    log_info "1. AWS EKS 클러스터 생성 및 배포"
    if command -v aws &> /dev/null; then
        # EKS Helper 함수 사용
        log_info "EKS Helper 함수를 사용하여 클러스터 생성"
        
        # EKS Helper 스크립트 경로 설정
        local eks_helper="../../tools/cloud/aws-eks-helper.sh"
        
        if [ -f "$eks_helper" ]; then
            log_info "EKS Helper 스크립트 사용"
            chmod +x "$eks_helper"
            
            # EKS 클러스터 생성
            log_info "EKS 클러스터 생성 중..."
            "$eks_helper" create
            
            if [ $? -eq 0 ]; then
                log_success "EKS 클러스터 생성 완료"
            else
                log_warning "EKS 클러스터 생성 실패 또는 이미 존재"
            fi
        else
            log_warning "EKS Helper 스크립트를 찾을 수 없습니다. 수동 스크립트 생성"
            
            # EKS 클러스터 생성 스크립트 (Fallback)
            cat > create-eks-cluster.sh << 'EOF'
#!/bin/bash

# EKS 클러스터 생성 스크립트
set -e

CLUSTER_NAME="my-eks-cluster"
REGION="us-west-2"
NODE_GROUP_NAME="my-node-group"
NODE_TYPE="t3.medium"
NODE_COUNT=2

echo "Creating EKS cluster: $CLUSTER_NAME"

# 1. EKS 클러스터 생성
aws eks create-cluster \
  --name $CLUSTER_NAME \
  --version "1.28" \
  --role-arn arn:aws:iam::ACCOUNT:role/eksServiceRole \
  --resources-vpc-config subnetIds=subnet-12345,subnet-67890,securityGroupIds=sg-12345 \
  --region $REGION

echo "Waiting for cluster to be active..."
aws eks wait cluster-active --name $CLUSTER_NAME --region $REGION

# 2. Node Group 생성
aws eks create-nodegroup \
  --cluster-name $CLUSTER_NAME \
  --nodegroup-name $NODE_GROUP_NAME \
  --scaling-config minSize=1,maxSize=3,desiredSize=$NODE_COUNT \
  --instance-types $NODE_TYPE \
  --node-role arn:aws:iam::ACCOUNT:role/eksNodeRole \
  --subnets subnet-12345 subnet-67890 \
  --region $REGION

echo "Waiting for node group to be active..."
aws eks wait nodegroup-active --cluster-name $CLUSTER_NAME --nodegroup-name $NODE_GROUP_NAME --region $REGION

# 3. kubeconfig 업데이트
aws eks update-kubeconfig --name $CLUSTER_NAME --region $REGION

echo "EKS cluster created successfully!"
kubectl get nodes
EOF
            
            chmod +x create-eks-cluster.sh
        fi
        
        # EKS 배포 매니페스트 생성
        log_info "EKS 배포 매니페스트 생성"
        cat > eks-cluster-config.yaml << 'EOF'
apiVersion: v1
kind: ConfigMap
metadata:
  name: eks-cluster-info
  namespace: day1-practice
data:
  cluster-name: "my-eks-cluster"
  region: "us-west-2"
  node-type: "t3.medium"
  node-count: "2"
  min-nodes: "1"
  max-nodes: "3"
  version: "1.28"
EOF
        
        # EKS 애플리케이션 배포 매니페스트 생성
        log_info "EKS 애플리케이션 배포 매니페스트 생성"
        cat > eks-deployment.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp-eks
  namespace: day1-practice
  labels:
    app: myapp
    platform: aws-eks
spec:
  replicas: 3
  selector:
    matchLabels:
      app: myapp
  template:
    metadata:
      labels:
        app: myapp
        platform: aws-eks
    spec:
      containers:
      - name: myapp
        image: nginx:1.21
        ports:
        - containerPort: 80
        resources:
          requests:
            memory: "128Mi"
            cpu: "250m"
          limits:
            memory: "256Mi"
            cpu: "500m"
        livenessProbe:
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 5
          periodSeconds: 5
---
apiVersion: v1
kind: Service
metadata:
  name: myapp-eks-service
  namespace: day1-practice
spec:
  selector:
    app: myapp
  ports:
  - port: 80
    targetPort: 80
  type: LoadBalancer
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: myapp-config
  namespace: day1-practice
data:
  app_name: "My EKS Application"
  environment: "production"
  log_level: "info"
---
apiVersion: v1
kind: Secret
metadata:
  name: myapp-secret
  namespace: day1-practice
type: Opaque
data:
  api_key: YWJjZGVmZ2hpams=  # base64 encoded "abcdefghijk"
  database_url: cG9zdGdyZXM6Ly9sb2NhbGhvc3Q6NTQzMi9teWFwcA==  # base64 encoded "postgres://localhost:5432/myapp"
EOF
        
        # EKS 배포 스크립트 생성
        log_info "EKS 배포 스크립트 생성"
        cat > deploy-to-eks.sh << 'EOF'
#!/bin/bash

# EKS 배포 스크립트
set -e

CLUSTER_NAME="my-eks-cluster"
REGION="us-west-2"
NAMESPACE="day1-practice"

echo "Deploying to EKS cluster: $CLUSTER_NAME"

# 1. 클러스터 연결 확인
if ! kubectl cluster-info &> /dev/null; then
    echo "Connecting to EKS cluster..."
    aws eks update-kubeconfig --name $CLUSTER_NAME --region $REGION
fi

# 2. 네임스페이스 생성
kubectl create namespace $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -

# 3. 애플리케이션 배포
kubectl apply -f eks-deployment.yaml

# 4. 배포 상태 확인
echo "Waiting for deployment to be ready..."
kubectl rollout status deployment/myapp-eks -n $NAMESPACE --timeout=300s

# 5. 서비스 상태 확인
kubectl get services -n $NAMESPACE
kubectl get pods -n $NAMESPACE

# 6. LoadBalancer 엔드포인트 확인
echo "Getting LoadBalancer endpoint..."
kubectl get service myapp-eks-service -n $NAMESPACE -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'

echo "Deployment completed successfully!"
EOF
        
        chmod +x deploy-to-eks.sh
        
        log_info "EKS 배포 매니페스트 및 스크립트 생성 완료"
    else
        log_warning "AWS CLI가 설치되지 않음"
    fi
    
    # GCP GKE 실습 (참고용)
    log_info "2. GCP GKE 실습 (참고용)"
    if command -v gcloud &> /dev/null; then
        # GKE Helper 함수 사용
        log_info "GKE Helper 함수를 사용하여 클러스터 생성 (참고용)"
        
        # GKE Helper 스크립트 경로 설정
        local gke_helper="../../tools/cloud/gcp-gke-helper.sh"
        
        if [ -f "$gke_helper" ]; then
            log_info "GKE Helper 스크립트 사용 (참고용)"
            chmod +x "$gke_helper"
            
            # GKE 클러스터 생성 (참고용)
            log_info "GKE 클러스터 생성 중... (참고용)"
            "$gke_helper" create
            
            if [ $? -eq 0 ]; then
                log_success "GKE 클러스터 생성 완료 (참고용)"
            else
                log_warning "GKE 클러스터 생성 실패 또는 이미 존재 (참고용)"
            fi
        else
            log_warning "GKE Helper 스크립트를 찾을 수 없습니다. 수동 스크립트 생성 (참고용)"
            
            # GKE 클러스터 생성 스크립트 (Fallback)
            cat > create-gke-cluster.sh << 'EOF'
#!/bin/bash

# GKE 클러스터 생성 스크립트 (참고용)
set -e

CLUSTER_NAME="my-gke-cluster"
ZONE="us-central1-a"
NODE_COUNT=2
MACHINE_TYPE="e2-medium"

echo "Creating GKE cluster: $CLUSTER_NAME"

# 1. GKE 클러스터 생성
gcloud container clusters create $CLUSTER_NAME \
  --zone $ZONE \
  --num-nodes $NODE_COUNT \
  --machine-type $MACHINE_TYPE \
  --enable-autoscaling \
  --min-nodes 1 \
  --max-nodes 3

# 2. 클러스터 연결
gcloud container clusters get-credentials $CLUSTER_NAME --zone $ZONE

echo "GKE cluster created successfully!"
kubectl get nodes
EOF
            
            chmod +x create-gke-cluster.sh
        fi
        
        # GKE 배포 매니페스트 (참고용)
        cat > gke-deployment.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp-gke
  namespace: day1-practice
  labels:
    app: myapp
    platform: gcp-gke
spec:
  replicas: 2
  selector:
    matchLabels:
      app: myapp
  template:
    metadata:
      labels:
        app: myapp
        platform: gcp-gke
    spec:
      containers:
      - name: myapp
        image: nginx:1.21
        ports:
        - containerPort: 80
        resources:
          requests:
            memory: "128Mi"
            cpu: "250m"
          limits:
            memory: "256Mi"
            cpu: "500m"
---
apiVersion: v1
kind: Service
metadata:
  name: myapp-gke-service
  namespace: day1-practice
spec:
  selector:
    app: myapp
  ports:
  - port: 80
    targetPort: 80
  type: LoadBalancer
EOF
        
        log_info "GKE 배포 매니페스트 생성 완료 (참고용)"
    else
        log_warning "GCP CLI가 설치되지 않음"
    fi
    
    # 통합 클러스터 관리
    log_info "3. 통합 클러스터 관리"
    local cluster_helper="../../tools/cloud/cloud-cluster-helper.sh"
    
    if [ -f "$cluster_helper" ]; then
        log_info "통합 클러스터 Helper 사용"
        chmod +x "$cluster_helper"
        
        # 클러스터 상태 확인
        log_info "클러스터 상태 확인"
        "$cluster_helper" status
        
        # 필요시 클러스터 생성
        log_info "클러스터 생성 옵션 제공"
        echo "통합 클러스터 Helper 사용 가능:"
        echo "  - ./cloud-cluster-helper.sh create    # 멀티 클라우드 클러스터 생성"
        echo "  - ./cloud-cluster-helper.sh status    # 클러스터 상태 확인"
        echo "  - ./cloud-cluster-helper.sh delete    # 클러스터 삭제"
    else
        log_warning "통합 클러스터 Helper를 찾을 수 없습니다"
    fi
    
    # EKS 실제 배포 테스트
    log_info "4. EKS 실제 배포 테스트"
    if command -v aws &> /dev/null && aws sts get-caller-identity &> /dev/null; then
        log_info "EKS 클러스터 연결 테스트"
        
        # 기존 EKS 클러스터 확인
        local existing_clusters=$(aws eks list-clusters --query 'clusters[]' --output text 2>/dev/null || echo "")
        
        if [ -n "$existing_clusters" ]; then
            log_info "기존 EKS 클러스터 발견: $existing_clusters"
            local cluster_name=$(echo "$existing_clusters" | head -1)
            
            # 클러스터 연결
            aws eks update-kubeconfig --name "$cluster_name" --region us-west-2 2>/dev/null || \
            aws eks update-kubeconfig --name "$cluster_name" --region us-east-1 2>/dev/null || \
            aws eks update-kubeconfig --name "$cluster_name" --region ap-northeast-2 2>/dev/null
            
            if kubectl cluster-info &> /dev/null; then
                log_success "EKS 클러스터 연결 성공"
                
                # 실제 배포 테스트
                log_info "EKS에 애플리케이션 배포 테스트"
                kubectl create namespace day1-practice --dry-run=client -o yaml | kubectl apply -f -
                kubectl apply -f eks-deployment.yaml
                
                # 배포 상태 확인
                log_info "배포 상태 확인 중..."
                sleep 30
                kubectl get pods -n day1-practice
                kubectl get services -n day1-practice
                
                # LoadBalancer 엔드포인트 확인
                local lb_endpoint=$(kubectl get service myapp-eks-service -n day1-practice -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null || echo "")
                if [ -n "$lb_endpoint" ]; then
                    log_success "LoadBalancer 엔드포인트: $lb_endpoint"
                else
                    log_warning "LoadBalancer 엔드포인트를 가져올 수 없습니다"
                fi
            else
                log_warning "EKS 클러스터 연결 실패"
            fi
        else
            log_warning "EKS 클러스터가 없습니다"
            log_info "EKS 클러스터 생성 방법:"
            echo "  1. AWS 콘솔에서 EKS 클러스터 생성"
            echo "  2. 또는 ./create-eks-cluster.sh 스크립트 실행"
        fi
    else
        log_warning "AWS 자격 증명이 설정되지 않았습니다"
    fi
    
    # 클라우드 서비스 비교
    log_info "4. 클라우드 서비스 비교"
    cat > cloud-comparison.md << 'EOF'
# AWS EKS vs GCP GKE 비교

## AWS EKS (Elastic Kubernetes Service)
- **관리형 Kubernetes 서비스**
- **장점**: 
  - AWS 생태계 완벽 통합 (IAM, VPC, CloudWatch, ALB)
  - 엔터프라이즈급 보안 및 컴플라이언스
  - Fargate 서버리스 옵션
  - 강력한 네트워킹 및 보안 기능
- **단점**: 
  - 복잡한 초기 설정
  - 높은 비용 (컨트롤 플레인 비용)
  - AWS 의존성
- **사용 사례**: 
  - AWS 중심 환경
  - 엔터프라이즈급 애플리케이션
  - 복잡한 보안 요구사항

## GCP GKE (Google Kubernetes Engine)
- **관리형 Kubernetes 서비스**
- **장점**: 
  - 간단한 설정 및 관리
  - 자동 스케일링 및 업그레이드
  - 비용 효율성
  - Google의 Kubernetes 전문성
- **단점**: 
  - GCP 생태계 의존성
  - 제한적인 커스터마이징
- **사용 사례**: 
  - 클라우드 네이티브 애플리케이션
  - 마이크로서비스 아키텍처
  - 빠른 프로토타이핑

## 선택 기준
1. **기존 인프라**: AWS 사용 중이면 EKS, GCP 사용 중이면 GKE
2. **비용**: GKE가 일반적으로 더 비용 효율적
3. **복잡성**: GKE가 설정이 더 간단
4. **통합**: 각 클라우드의 다른 서비스와의 통합도 고려
5. **보안**: EKS가 더 강력한 보안 기능 제공
6. **스케일링**: GKE가 자동 스케일링에 더 우수

## 실습 권장사항
- **초급자**: GKE로 시작하여 Kubernetes 기본 개념 학습
- **중급자**: EKS로 실제 프로덕션 환경 경험
- **고급자**: 두 플랫폼 모두 경험하여 최적의 선택
EOF
    
    log_success "클라우드 컨테이너 서비스 실습 완료"
    cd ..
}

# 통합 클러스터 관리
unified_cluster_management() {
    log_header "K8s 클러스터 관리"
    
    # 클러스터 관리 메뉴
    show_cluster_menu() {
        echo ""
        log_header "K8s 클러스터 관리 메뉴"
        echo "1. 클러스터 현황 확인"
        echo "2. EKS 클러스터 관리"
        echo "3. GKE 클러스터 관리"
        echo "4. 통합 클러스터 관리"
        echo "5. 배포 관리"
        echo "6. 뒤로 가기"
        echo ""
    }
    
    while true; do
        show_cluster_menu
        read -p "선택하세요 (1-6): " choice
        
        case $choice in
            1)
                log_info "클러스터 현황 확인"
                cluster_status_check
                ;;
            2)
                log_info "EKS 클러스터 관리"
                local eks_helper="../../tools/cloud/aws-eks-helper.sh"
                if [ -f "$eks_helper" ]; then
                    chmod +x "$eks_helper"
                    "$eks_helper" --interactive
                else
                    log_warning "EKS Helper를 찾을 수 없습니다"
                fi
                ;;
            3)
                log_info "GKE 클러스터 관리"
                local gke_helper="../../tools/cloud/gcp-gke-helper.sh"
                if [ -f "$gke_helper" ]; then
                    chmod +x "$gke_helper"
                    "$gke_helper" --interactive
                else
                    log_warning "GKE Helper를 찾을 수 없습니다"
                fi
                ;;
            4)
                log_info "통합 클러스터 관리"
                local cluster_helper="../../tools/cloud/cloud-cluster-helper.sh"
                if [ -f "$cluster_helper" ]; then
                    chmod +x "$cluster_helper"
                    "$cluster_helper" --interactive
                else
                    log_warning "통합 클러스터 Helper를 찾을 수 없습니다"
                fi
                ;;
            5)
                log_info "배포 관리"
                deployment_management
                ;;
            6)
                log_info "클러스터 관리 메뉴를 종료합니다"
                break
                ;;
            *)
                log_error "잘못된 선택입니다. 1-6 중에서 선택하세요."
                ;;
        esac
        
        echo ""
        read -p "계속하려면 Enter를 누르세요..."
    done
}

# 클러스터 현황 확인
cluster_status_check() {
    log_header "클러스터 현황 확인"
    
    # 통합 클러스터 Helper 사용
    local cluster_helper="../../tools/cloud/cloud-cluster-helper.sh"
    if [ -f "$cluster_helper" ]; then
        log_info "통합 클러스터 Helper 사용"
        chmod +x "$cluster_helper"
        "$cluster_helper" --action status
    else
        log_warning "통합 클러스터 Helper를 찾을 수 없습니다"
        log_info "개별 클러스터 Helper 사용"
        
        # AWS EKS Helper
        local eks_helper="../../tools/cloud/aws-eks-helper.sh"
        if [ -f "$eks_helper" ]; then
            chmod +x "$eks_helper"
            "$eks_helper" --action status
        fi
        
        # GCP GKE Helper
        local gke_helper="../../tools/cloud/gcp-gke-helper.sh"
        if [ -f "$gke_helper" ]; then
            chmod +x "$gke_helper"
            "$gke_helper" --action status
        fi
    fi
    
    log_success "클러스터 현황 확인 완료"
}

# 배포 관리
deployment_management() {
    log_header "배포 관리"
    
    # 배포 관리 메뉴
    show_deployment_menu() {
        echo ""
        log_header "배포 관리 메뉴"
        echo "1. 현재 배포 현황 확인"
        echo "2. EKS 배포 관리"
        echo "3. GKE 배포 관리"
        echo "4. 통합 배포 관리"
        echo "5. 뒤로 가기"
        echo ""
    }
    
    while true; do
        show_deployment_menu
        read -p "선택하세요 (1-5): " choice
        
        case $choice in
            1)
                log_info "현재 배포 현황 확인"
                if kubectl cluster-info &> /dev/null; then
                    log_info "=== 클러스터 연결 상태 ==="
                    kubectl cluster-info
                    echo ""
                    
                    log_info "=== 전체 네임스페이스 배포 현황 ==="
                    kubectl get deployments --all-namespaces
                    echo ""
                    
                    log_info "=== 전체 네임스페이스 서비스 현황 ==="
                    kubectl get services --all-namespaces
                    echo ""
                    
                    log_info "=== 전체 네임스페이스 Pod 현황 ==="
                    kubectl get pods --all-namespaces
                    echo ""
                    
                    log_info "=== day1-practice 네임스페이스 상세 현황 ==="
                    if kubectl get namespace day1-practice &> /dev/null; then
                        log_info "Deployments:"
                        kubectl get deployments -n day1-practice
                        echo ""
                        log_info "Services:"
                        kubectl get services -n day1-practice
                        echo ""
                        log_info "Pods:"
                        kubectl get pods -n day1-practice
                        echo ""
                        log_info "ConfigMaps:"
                        kubectl get configmaps -n day1-practice
                        echo ""
                        log_info "Secrets:"
                        kubectl get secrets -n day1-practice
                        echo ""
                        log_info "=== 배포 중인 리소스 상태 ==="
                        kubectl get all -n day1-practice
                    else
                        log_warning "day1-practice 네임스페이스가 없습니다"
                    fi
                else
                    log_warning "Kubernetes 클러스터에 연결할 수 없습니다"
                    log_info "클러스터 연결을 위해 다음을 확인하세요:"
                    echo "  - kubectl 설정 확인: kubectl config current-context"
                    echo "  - 클러스터 상태 확인: kubectl cluster-info"
                fi
                ;;
            2)
                log_info "EKS 배포 관리"
                local eks_helper="../../tools/cloud/aws-eks-helper.sh"
                if [ -f "$eks_helper" ]; then
                    chmod +x "$eks_helper"
                    "$eks_helper" --action deploy
                else
                    log_warning "EKS Helper를 찾을 수 없습니다"
                fi
                ;;
            3)
                log_info "GKE 배포 관리"
                local gke_helper="../../tools/cloud/gcp-gke-helper.sh"
                if [ -f "$gke_helper" ]; then
                    chmod +x "$gke_helper"
                    "$gke_helper" --action deploy
                else
                    log_warning "GKE Helper를 찾을 수 없습니다"
                fi
                ;;
            4)
                log_info "통합 배포 관리"
                local cluster_helper="../../tools/cloud/cloud-cluster-helper.sh"
                if [ -f "$cluster_helper" ]; then
                    chmod +x "$cluster_helper"
                    "$cluster_helper" --action deploy
                else
                    log_warning "통합 클러스터 Helper를 찾을 수 없습니다"
                fi
                ;;
            5)
                log_info "배포 관리 메뉴를 종료합니다"
                break
                ;;
            *)
                log_error "잘못된 선택입니다. 1-5 중에서 선택하세요."
                ;;
        esac
        
        echo ""
        read -p "계속하려면 Enter를 누르세요..."
    done
}

# 클러스터 관리
cluster_management() {
    log_header "클러스터 관리"
    
    # 클러스터 관리 메뉴
    show_cluster_menu() {
        echo ""
        log_header "클러스터 관리 메뉴"
        echo "1. EKS 클러스터 관리"
        echo "2. GKE 클러스터 관리"
        echo "3. 통합 클러스터 관리"
        echo "4. 뒤로 가기"
        echo ""
    }
    
    while true; do
        show_cluster_menu
        read -p "선택하세요 (1-4): " choice
        
        case $choice in
            1)
                log_info "EKS 클러스터 관리"
                local eks_helper="../../tools/cloud/aws-eks-helper.sh"
                if [ -f "$eks_helper" ]; then
                    chmod +x "$eks_helper"
                    "$eks_helper" --interactive
                else
                    log_warning "EKS Helper를 찾을 수 없습니다"
                fi
                ;;
            2)
                log_info "GKE 클러스터 관리"
                local gke_helper="../../tools/cloud/gcp-gke-helper.sh"
                if [ -f "$gke_helper" ]; then
                    chmod +x "$gke_helper"
                    "$gke_helper" --interactive
                else
                    log_warning "GKE Helper를 찾을 수 없습니다"
                fi
                ;;
            3)
                log_info "통합 클러스터 관리"
                local cluster_helper="../../tools/cloud/cloud-cluster-helper.sh"
                if [ -f "$cluster_helper" ]; then
                    chmod +x "$cluster_helper"
                    "$cluster_helper" --interactive
                else
                    log_warning "통합 클러스터 Helper를 찾을 수 없습니다"
                fi
                ;;
            4)
                log_info "클러스터 관리 메뉴를 종료합니다"
                break
                ;;
            *)
                log_error "잘못된 선택입니다. 1-4 중에서 선택하세요."
                ;;
        esac
        
        echo ""
        read -p "계속하려면 Enter를 누르세요..."
    done
}

# 정리 함수
cleanup_day1() {
    log_header "Day 1 실습 정리"
    
    # Docker 리소스 정리
    log_info "Docker 리소스 정리"
    docker-compose -f day1-docker-advanced/docker-compose.yml down -v 2>/dev/null || true
    docker rmi myapp:optimized myapp:builder myapp:runtime 2>/dev/null || true
    
    # EKS 리소스 정리
    log_info "EKS 리소스 정리"
    if kubectl cluster-info &> /dev/null; then
        kubectl delete namespace day1-practice 2>/dev/null || true
        log_success "EKS 리소스 정리 완료"
    else
        log_warning "EKS 클러스터에 연결할 수 없어 리소스 정리를 건너뜁니다."
        log_info "수동으로 정리하려면:"
        echo "  kubectl delete namespace day1-practice"
    fi
    
    # 실습 디렉토리 정리
    log_info "실습 디렉토리 정리"
    rm -rf day1-docker-advanced
    rm -rf day1-kubernetes-basics
    rm -rf day1-cloud-container-services
    
    log_success "Day 1 정리 완료"
}

# 메인 메뉴
show_menu() {
    echo ""
    log_header "Cloud Intermediate Day 1 실습 메뉴"
    echo "1. Docker 고급 실습"
    echo "2. Kubernetes 기초 실습"
    echo "3. 클라우드 컨테이너 서비스 실습"
    echo "4. 전체 Day 1 실습 실행"
    echo "5. K8s 클러스터 관리"
    echo "6. 정리"
    echo "7. 종료"
    echo ""
}

# 메인 함수
main() {
    log_header "Cloud Intermediate Day 1 실습 스크립트"
    log_info "Docker 고급 활용, Kubernetes 기초, 클라우드 컨테이너 서비스 실습"
    
    while true; do
        show_menu
        read -p "선택하세요 (1-6): " choice
        
        case $choice in
            1)
                docker_advanced_practice
                ;;
            2)
                kubernetes_basics_practice
                ;;
            3)
                cloud_container_services_practice
                ;;
            4)
                log_info "전체 Day 1 실습 실행"
                docker_advanced_practice
                kubernetes_basics_practice
                cloud_container_services_practice
                log_success "전체 Day 1 실습 완료!"
                ;;
            5)
                cleanup_day1
                ;;
            6)
                log_info "프로그램을 종료합니다"
                exit 0
                ;;
            *)
                log_error "잘못된 선택입니다. 1-6 중에서 선택하세요."
                ;;
        esac
        
        echo ""
        read -p "계속하려면 Enter를 누르세요..."
    done
}

# Interactive 모드 메뉴
show_interactive_menu() {
    echo ""
    log_header "Cloud Intermediate Day 1 실습 메뉴"
    echo "1. Docker 고급 실습"
    echo "2. Kubernetes 기초 실습"
    echo "3. 클라우드 컨테이너 서비스 실습"
    echo "4. 전체 Day 1 실습 실행"
    echo "5. K8s 클러스터 관리"
    echo "6. 실습 환경 정리"
    echo "7. 종료"
    echo ""
}

# Interactive 모드 실행
run_interactive_mode() {
    log_header "Cloud Intermediate Day 1 실습"
    while true; do
        show_interactive_menu
        read -p "선택하세요 (1-7): " choice
        
        case $choice in
            1)
                docker_advanced_practice
                ;;
            2)
                kubernetes_basics_practice
                ;;
            3)
                cloud_container_services_practice
                ;;
            4)
                log_info "전체 Day 1 실습 실행"
                docker_advanced_practice
                kubernetes_basics_practice
                cloud_container_services_practice
                log_success "전체 Day 1 실습 완료!"
                ;;
            5)
                unified_cluster_management
                ;;
            6)
                cleanup_day1
                ;;
            7)
                log_info "프로그램을 종료합니다"
                exit 0
                ;;
            *)
                log_error "잘못된 선택입니다. 1-7 중에서 선택하세요."
                ;;
        esac
        
        echo ""
        read -p "계속하려면 Enter를 누르세요..."
    done
}

# Parameter 모드 실행
run_parameter_mode() {
    local action=$1
    shift
    
    case "$action" in
        "docker-advanced")
            log_info "Docker 고급 실습 실행"
            docker_advanced_practice
            ;;
        "kubernetes-basics")
            log_info "Kubernetes 기초 실습 실행"
            kubernetes_basics_practice
            ;;
        "cloud-services")
            log_info "클라우드 컨테이너 서비스 실습 실행"
            cloud_container_services_practice
            ;;
        "cluster-status")
            log_info "클러스터 현황 확인 실행"
            cluster_status_check
            ;;
        "deployment")
            log_info "배포 관리 실행"
            deployment_management
            ;;
        "cluster")
            log_info "클러스터 관리 실행"
            cluster_management
            ;;
        "monitoring-hub")
            log_info "모니터링 허브 구축 실습 실행"
            monitoring_hub_practice
            ;;
        "all")
            log_info "전체 Day 1 실습 실행"
            docker_advanced_practice
            kubernetes_basics_practice
            cloud_container_services_practice
            monitoring_hub_practice
            log_success "전체 Day 1 실습 완료!"
            ;;
        "cleanup")
            log_info "Day 1 실습 정리 실행"
            cleanup_day1
            ;;
        *)
            log_error "알 수 없는 액션: $action"
            usage
            exit 1
            ;;
    esac
}

# 메인 함수
main() {
    case "${1:-}" in
        "--help"|"-h")
            usage
            exit 0
            ;;
        "--interactive"|"-i"|"")
            run_interactive_mode
            ;;
        "--action")
            if [ -z "${2:-}" ]; then
                log_error "액션을 지정해주세요."
                usage
                exit 1
            fi
            run_parameter_mode "$2" "${3:-}"
            ;;
        *)
            log_error "알 수 없는 옵션: $1"
            usage
            exit 1
            ;;
    esac
}

# 스크립트 실행
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
