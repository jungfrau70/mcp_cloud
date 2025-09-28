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
    echo "  --action kubernetes-basics   # 클라우드 컨테이너 서비스 기초 실습 (EKS/GKE)"
    echo "  --action cloud-services     # 클라우드 컨테이너 서비스 기초 실습 (EKS/GKE)"
    echo "  --action monitoring-hub     # 통합 모니터링 허브 구축"
    echo "  --action cluster-status     # 클러스터 현황 확인"
    echo "  --action deployment         # 배포 관리"
    echo "  --action cluster            # 클러스터 관리"
    echo "  --action cleanup            # 실습 환경 정리"
    echo "  --action status             # 현재 리소스 상태 확인"
    echo "  --action remaining           # 정리 후 남은 리소스 확인"
    echo "  --action all                # 전체 실습 실행"
    echo ""
    echo "예시:"
    echo "  $0                          # Interactive 모드"
    echo "  $0 --action docker-advanced # Docker 고급 실습만 실행"
    echo "  $0 --action cleanup         # 실습 환경 정리"
    echo "  $0 --action status          # 현재 리소스 상태 확인"
    echo "  $0 --action all             # 전체 실습 실행"
    echo ""
    echo "자동화 툴 사용 예시:"
    echo "  $0 --action cleanup         # 정리만 실행"
    echo "  $0 --action status          # 상태만 확인"
    echo "  $0 --action remaining       # 남은 리소스 확인"
    echo "  $0 --action cleanup && $0 --action remaining  # 정리 후 남은 리소스 확인"
    echo "  $0 --action status && $0 --action cleanup && $0 --action remaining  # 전체 프로세스"
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
      - "5000:3000"
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
    curl -f http://localhost:5000/health || log_warning "헬스 체크 실패"
    curl -f http://localhost:5000/info || log_warning "정보 엔드포인트 실패"
    
    log_success "Docker 고급 실습 완료"
    cd ..
}

# Kubernetes 기초 실습
# 클라우드 컨테이너 서비스 기초 실습 서브 메뉴
kubernetes_basics_submenu() {
    while true; do
        echo ""
        log_header "클라우드 컨테이너 서비스 기초 실습 (EKS/GKE) 서브 메뉴"
        echo "1. K8s 클러스터 컨텍스트 구성 및 체크"
        echo "2. 클러스터 전환 (EKS ↔ GKE)"
        echo "3. Pod 생성 및 관리"
        echo "4. Deployment 생성 및 관리"
        echo "5. Service 생성 및 관리"
        echo "6. ConfigMap 및 Secret 관리"
        echo "7. 전체 K8s 리소스 배포"
        echo "8. AWS EKS 클러스터 생성 및 배포"
        echo "9. GCP GKE 클러스터 생성 및 배포"
        echo "10. LoadBalancer 서비스 배포 (EKS ALB / GKE GLB)"
        echo "11. NodePort 서비스 배포"
        echo "12. Ingress 설정"
        echo "13. 포트 포워딩 테스트"
        echo "14. 리소스 상태 확인"
        echo "15. 통합 클러스터 관리"
        echo "16. 이전 메뉴로 돌아가기"
        echo ""
        read -p "선택하세요 (1-16): " sub_choice
        
        case $sub_choice in
            1)
                kubernetes_context_setup
                ;;
            2)
                kubernetes_cluster_switch
                ;;
            3)
                kubernetes_pod_practice
                ;;
            4)
                kubernetes_deployment_practice
                ;;
            5)
                kubernetes_service_practice
                ;;
            6)
                kubernetes_config_secret_practice
                ;;
            7)
                kubernetes_all_resources_practice
                ;;
            8)
                cloud_container_services_practice
                ;;
            9)
                cloud_container_services_practice
                ;;
            10)
                kubernetes_alb_loadbalancer_practice
                ;;
            11)
                kubernetes_nodeport_practice
                ;;
            12)
                kubernetes_ingress_practice
                ;;
            13)
                kubernetes_port_forward_practice
                ;;
            14)
                kubernetes_status_check
                ;;
            15)
                unified_cluster_management
                ;;
            16)
                return
                ;;
            *)
                log_error "잘못된 선택입니다. 1-16 중에서 선택하세요."
                ;;
        esac
        
        echo ""
        read -p "계속하려면 Enter를 누르세요..."
        # Enter 입력 시 현재 메뉴 유지 (종료하지 않음)
    done
}

# K8s 클러스터 컨텍스트 구성 및 체크
kubernetes_context_setup() {
    log_header "K8s 클러스터 컨텍스트 구성 및 체크"
    
    # 1. AWS CLI 확인
    log_info "1. AWS CLI 확인"
    if command -v aws &> /dev/null; then
        log_success "AWS CLI 확인됨"
        aws --version
    else
        log_error "AWS CLI가 설치되지 않았습니다."
        return 1
    fi
    
    # 2. AWS 자격 증명 확인
    log_info "2. AWS 자격 증명 확인"
    if aws sts get-caller-identity &> /dev/null; then
        log_success "AWS 자격 증명 확인됨"
        aws sts get-caller-identity
    else
        log_error "AWS 자격 증명이 설정되지 않았습니다."
        return 1
    fi
    
    # 3. kubectl 확인
    log_info "3. kubectl 확인"
    if command -v kubectl &> /dev/null; then
        log_success "kubectl 확인됨"
        kubectl version --client
    else
        log_error "kubectl이 설치되지 않았습니다."
        return 1
    fi
    
    # 4. EKS 클러스터 확인
    log_info "4. EKS 클러스터 확인"
    CLUSTER_NAME=$(aws eks list-clusters --query 'clusters[0]' --output text 2>/dev/null)
    if [ -n "$CLUSTER_NAME" ] && [ "$CLUSTER_NAME" != "None" ]; then
        log_success "EKS 클러스터 확인됨: $CLUSTER_NAME"
        
        # 5. EKS 클러스터 연결
        log_info "5. EKS 클러스터 연결"
        if aws eks update-kubeconfig --region ap-northeast-2 --name "$CLUSTER_NAME"; then
            log_success "EKS 클러스터 연결 성공"
        else
            log_error "EKS 클러스터 연결 실패"
            return 1
        fi
    else
        log_warning "EKS 클러스터를 찾을 수 없습니다."
        log_info "사용 가능한 클러스터 목록:"
        aws eks list-clusters --output table 2>/dev/null || log_error "EKS 클러스터 목록 조회 실패"
        return 1
    fi
    
    # 6. 클러스터 연결 테스트
    log_info "6. 클러스터 연결 테스트"
    if kubectl get nodes &> /dev/null; then
        log_success "클러스터 연결 성공"
        kubectl get nodes
    else
        log_error "클러스터 연결 실패"
        return 1
    fi
    
    # 7. 현재 컨텍스트 확인
    log_info "7. 현재 컨텍스트 확인"
    CURRENT_CONTEXT=$(kubectl config current-context)
    log_info "현재 컨텍스트: $CURRENT_CONTEXT"
    
    # 8. 네임스페이스 확인/생성
    log_info "8. 네임스페이스 확인/생성"
    if kubectl get namespace day1-practice &> /dev/null; then
        log_success "네임스페이스 'day1-practice' 존재"
    else
        log_info "네임스페이스 'day1-practice' 생성"
        kubectl create namespace day1-practice
        log_success "네임스페이스 'day1-practice' 생성 완료"
    fi
    
    # 9. 클러스터 정보 요약
    log_info "9. 클러스터 정보 요약"
    echo -e "\n${PURPLE}=== 클러스터 정보 ===${NC}"
    kubectl cluster-info
    
    echo -e "\n${PURPLE}=== 노드 정보 ===${NC}"
    kubectl get nodes -o wide
    
    echo -e "\n${PURPLE}=== 네임스페이스 정보 ===${NC}"
    kubectl get namespaces
    
    log_success "K8s 클러스터 컨텍스트 구성 및 체크 완료"
}

# 클러스터 전환 (EKS ↔ GKE)
kubernetes_cluster_switch() {
    log_header "클러스터 전환 (EKS ↔ GKE)"
    
    # 현재 컨텍스트 확인
    CURRENT_CONTEXT=$(kubectl config current-context 2>/dev/null || echo "none")
    log_info "현재 컨텍스트: $CURRENT_CONTEXT"
    
    # 클러스터 전환 메뉴
    echo ""
    log_header "클러스터 전환 메뉴"
    echo "1. AWS EKS 클러스터로 전환"
    echo "2. GCP GKE 클러스터로 전환"
    echo "3. 사용 가능한 클러스터 목록 확인"
    echo "4. 현재 클러스터 정보 확인"
    echo "5. 이전 메뉴로 돌아가기"
    echo ""
    read -p "선택하세요 (1-5): " switch_choice
    
    case $switch_choice in
        1)
            switch_to_eks
            ;;
        2)
            switch_to_gke
            ;;
        3)
            list_available_clusters
            ;;
        4)
            show_current_cluster_info
            ;;
        5)
            return
            ;;
        *)
            log_error "잘못된 선택입니다. 1-5 중에서 선택하세요."
            ;;
    esac
}

# AWS EKS 클러스터로 전환
switch_to_eks() {
    log_header "AWS EKS 클러스터로 전환"
    
    # AWS CLI 확인
    if ! command -v aws &> /dev/null; then
        log_error "AWS CLI가 설치되지 않았습니다."
        return 1
    fi
    
    # AWS 자격 증명 확인
    if ! aws sts get-caller-identity &> /dev/null; then
        log_error "AWS 자격 증명이 설정되지 않았습니다."
        return 1
    fi
    
    # EKS 클러스터 목록 조회
    log_info "EKS 클러스터 목록 조회 중..."
    EKS_CLUSTERS=$(aws eks list-clusters --query 'clusters[]' --output text 2>/dev/null)
    
    if [ -z "$EKS_CLUSTERS" ]; then
        log_error "EKS 클러스터를 찾을 수 없습니다."
        return 1
    fi
    
    log_info "사용 가능한 EKS 클러스터:"
    echo "$EKS_CLUSTERS" | nl
    
    # 클러스터 선택
    read -p "전환할 EKS 클러스터 이름을 입력하세요: " CLUSTER_NAME
    
    if [ -z "$CLUSTER_NAME" ]; then
        log_error "클러스터 이름을 입력해주세요."
        return 1
    fi
    
    # EKS 클러스터 연결
    log_info "EKS 클러스터 '$CLUSTER_NAME' 연결 중..."
    if aws eks update-kubeconfig --region ap-northeast-2 --name "$CLUSTER_NAME"; then
        log_success "EKS 클러스터 연결 성공"
        
        # 연결 테스트
        if kubectl get nodes &> /dev/null; then
            log_success "클러스터 연결 확인됨"
            kubectl get nodes
        else
            log_error "클러스터 연결 실패"
            return 1
        fi
    else
        log_error "EKS 클러스터 연결 실패"
        return 1
    fi
    
    log_success "AWS EKS 클러스터로 전환 완료"
}

# GCP GKE 클러스터로 전환
switch_to_gke() {
    log_header "GCP GKE 클러스터로 전환"
    
    # gcloud CLI 확인
    if ! command -v gcloud &> /dev/null; then
        log_error "gcloud CLI가 설치되지 않았습니다."
        log_info "gcloud CLI 설치 방법:"
        echo "curl https://sdk.cloud.google.com | bash"
        echo "exec -l $SHELL"
        return 1
    fi
    
    # GCP 인증 확인
    if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" | head -n1 &> /dev/null; then
        log_error "GCP 인증이 필요합니다."
        log_info "GCP 인증 방법:"
        echo "gcloud auth login"
        echo "gcloud auth application-default login"
        return 1
    fi
    
    # GCP 프로젝트 설정 확인
    CURRENT_PROJECT=$(gcloud config get-value project 2>/dev/null)
    if [ -z "$CURRENT_PROJECT" ]; then
        log_error "GCP 프로젝트가 설정되지 않았습니다."
        log_info "GCP 프로젝트 설정 방법:"
        echo "gcloud config set project YOUR_PROJECT_ID"
        return 1
    fi
    
    log_info "현재 GCP 프로젝트: $CURRENT_PROJECT"
    
    # GKE 클러스터 목록 조회
    log_info "GKE 클러스터 목록 조회 중..."
    GKE_CLUSTERS=$(gcloud container clusters list --format="value(name,location,status)" 2>/dev/null)
    
    if [ -z "$GKE_CLUSTERS" ]; then
        log_error "GKE 클러스터를 찾을 수 없습니다."
        return 1
    fi
    
    log_info "사용 가능한 GKE 클러스터:"
    echo "$GKE_CLUSTERS" | nl
    
    # 클러스터 선택
    read -p "전환할 GKE 클러스터 이름을 입력하세요: " CLUSTER_NAME
    read -p "클러스터 위치를 입력하세요 (예: asia-northeast3-a): " CLUSTER_LOCATION
    
    if [ -z "$CLUSTER_NAME" ] || [ -z "$CLUSTER_LOCATION" ]; then
        log_error "클러스터 이름과 위치를 입력해주세요."
        return 1
    fi
    
    # GKE 클러스터 연결
    log_info "GKE 클러스터 '$CLUSTER_NAME' 연결 중..."
    if gcloud container clusters get-credentials "$CLUSTER_NAME" --location="$CLUSTER_LOCATION"; then
        log_success "GKE 클러스터 연결 성공"
        
        # 연결 테스트
        if kubectl get nodes &> /dev/null; then
            log_success "클러스터 연결 확인됨"
            kubectl get nodes
        else
            log_error "클러스터 연결 실패"
            return 1
        fi
    else
        log_error "GKE 클러스터 연결 실패"
        return 1
    fi
    
    log_success "GCP GKE 클러스터로 전환 완료"
}

# 사용 가능한 클러스터 목록 확인
list_available_clusters() {
    log_header "사용 가능한 클러스터 목록 확인"
    
    # kubectl 컨텍스트 목록
    log_info "kubectl 컨텍스트 목록:"
    kubectl config get-contexts
    
    # AWS EKS 클러스터 목록
    if command -v aws &> /dev/null && aws sts get-caller-identity &> /dev/null; then
        log_info "AWS EKS 클러스터 목록:"
        aws eks list-clusters --output table 2>/dev/null || log_warning "EKS 클러스터 조회 실패"
    else
        log_warning "AWS CLI 또는 자격 증명이 설정되지 않았습니다."
    fi
    
    # GCP GKE 클러스터 목록
    if command -v gcloud &> /dev/null && gcloud auth list --filter=status:ACTIVE --format="value(account)" | head -n1 &> /dev/null; then
        log_info "GCP GKE 클러스터 목록:"
        gcloud container clusters list --format="table(name,location,status,currentMasterVersion)" 2>/dev/null || log_warning "GKE 클러스터 조회 실패"
    else
        log_warning "gcloud CLI 또는 인증이 설정되지 않았습니다."
    fi
}

# 현재 클러스터 정보 확인
show_current_cluster_info() {
    log_header "현재 클러스터 정보 확인"
    
    # 현재 컨텍스트
    CURRENT_CONTEXT=$(kubectl config current-context 2>/dev/null || echo "none")
    log_info "현재 컨텍스트: $CURRENT_CONTEXT"
    
    # 클러스터 정보
    if kubectl get nodes &> /dev/null; then
        log_info "클러스터 정보:"
        kubectl cluster-info
        
        log_info "노드 정보:"
        kubectl get nodes -o wide
        
        log_info "네임스페이스 정보:"
        kubectl get namespaces
    else
        log_error "클러스터에 연결할 수 없습니다."
    fi
}

# Pod 생성 및 관리
kubernetes_pod_practice() {
    log_header "Pod 생성 및 관리"
    
    local practice_dir="day1-kubernetes-basics"
    mkdir -p "$practice_dir"
    cd "$practice_dir"
    
    log_info "Pod 생성"
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
    
    log_success "Pod 생성 및 관리 완료"
    cd ..
}

# Deployment 생성 및 관리
kubernetes_deployment_practice() {
    log_header "Deployment 생성 및 관리"
    
    local practice_dir="day1-kubernetes-basics"
    mkdir -p "$practice_dir"
    cd "$practice_dir"
    
    log_info "Deployment 생성"
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
EOF

    kubectl apply -f deployment-basic.yaml -n day1-practice
    log_success "Deployment 생성 완료"
    
    # 스케일링 테스트
    log_info "Deployment 스케일링 테스트"
    kubectl scale deployment myapp-deployment --replicas=5 -n day1-practice
    kubectl get deployment myapp-deployment -n day1-practice
    
    log_success "Deployment 생성 및 관리 완료"
    cd ..
}

# Service 생성 및 관리
kubernetes_service_practice() {
    log_header "Service 생성 및 관리"
    
    local practice_dir="day1-kubernetes-basics"
    mkdir -p "$practice_dir"
    cd "$practice_dir"
    
    log_info "ClusterIP Service 생성"
    cat > service-basic.yaml << 'EOF'
apiVersion: v1
kind: Service
metadata:
  name: myapp-service
  labels:
    app: myapp
spec:
  type: ClusterIP
  ports:
  - port: 80
    targetPort: 80
    protocol: TCP
  selector:
    app: myapp
EOF

    kubectl apply -f service-basic.yaml -n day1-practice
    log_success "ClusterIP Service 생성 완료"
    
    # 서비스 엔드포인트 확인
    log_info "Service 엔드포인트 확인"
    kubectl get service myapp-service -n day1-practice
    kubectl get endpoints myapp-service -n day1-practice
    
    log_success "Service 생성 및 관리 완료"
    cd ..
}

# ConfigMap 및 Secret 관리
kubernetes_config_secret_practice() {
    log_header "ConfigMap 및 Secret 관리"
    
    local practice_dir="day1-kubernetes-basics"
    mkdir -p "$practice_dir"
    cd "$practice_dir"
    
    log_info "ConfigMap 생성"
    cat > configmap-basic.yaml << 'EOF'
apiVersion: v1
kind: ConfigMap
metadata:
  name: myapp-config
  labels:
    app: myapp
data:
  database_url: "mysql://localhost:3306/myapp"
  debug: "true"
  log_level: "info"
  max_connections: "100"
  timeout: "30s"
EOF

    log_info "Secret 생성"
    cat > secret-basic.yaml << 'EOF'
apiVersion: v1
kind: Secret
metadata:
  name: myapp-secret
  labels:
    app: myapp
type: Opaque
data:
  username: bXlhcHA=  # myapp
  password: cGFzc3dvcmQxMjM=  # password123
  api_key: YWJjZGVmZ2hpams=  # abcdefghijk
  database_password: c2VjcmV0cGFzc3dvcmQ=  # secretpassword
EOF

    kubectl apply -f configmap-basic.yaml -n day1-practice
    kubectl apply -f secret-basic.yaml -n day1-practice
    
    log_success "ConfigMap 및 Secret 생성 완료"
    
    # 확인
    kubectl get configmap myapp-config -n day1-practice
    kubectl get secret myapp-secret -n day1-practice
    
    log_success "ConfigMap 및 Secret 관리 완료"
    cd ..
}

# 전체 K8s 리소스 배포
kubernetes_all_resources_practice() {
    log_header "전체 K8s 리소스 배포"
    
    local practice_dir="day1-kubernetes-basics"
    mkdir -p "$practice_dir"
    cd "$practice_dir"
    
    # 네임스페이스 생성
    log_info "네임스페이스 생성"
    kubectl create namespace day1-practice --dry-run=client -o yaml | kubectl apply -f -
    
    # 모든 리소스 배포
    log_info "모든 K8s 리소스 배포"
    
    # Pod
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

    # Deployment
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
EOF

    # Service
    cat > service-basic.yaml << 'EOF'
apiVersion: v1
kind: Service
metadata:
  name: myapp-service
  labels:
    app: myapp
spec:
  type: ClusterIP
  ports:
  - port: 80
    targetPort: 80
    protocol: TCP
  selector:
    app: myapp
EOF

    # ConfigMap
    cat > configmap-basic.yaml << 'EOF'
apiVersion: v1
kind: ConfigMap
metadata:
  name: myapp-config
  labels:
    app: myapp
data:
  database_url: "mysql://localhost:3306/myapp"
  debug: "true"
  log_level: "info"
  max_connections: "100"
  timeout: "30s"
EOF

    # Secret
    cat > secret-basic.yaml << 'EOF'
apiVersion: v1
kind: Secret
metadata:
  name: myapp-secret
  labels:
    app: myapp
type: Opaque
data:
  username: bXlhcHA=  # myapp
  password: cGFzc3dvcmQxMjM=  # password123
  api_key: YWJjZGVmZ2hpams=  # abcdefghijk
  database_password: c2VjcmV0cGFzc3dvcmQ=  # secretpassword
EOF

    # 모든 리소스 배포
    kubectl apply -f pod-basic.yaml -n day1-practice
    kubectl apply -f deployment-basic.yaml -n day1-practice
    kubectl apply -f service-basic.yaml -n day1-practice
    kubectl apply -f configmap-basic.yaml -n day1-practice
    kubectl apply -f secret-basic.yaml -n day1-practice
    
    log_success "모든 K8s 리소스 배포 완료"
    
    # 상태 확인
    log_info "리소스 상태 확인"
    kubectl get all -n day1-practice
    kubectl get configmap,secret -n day1-practice
    
    log_success "전체 K8s 리소스 배포 완료"
    cd ..
}

# LoadBalancer 서비스 배포 (EKS ALB / GKE GLB)
kubernetes_alb_loadbalancer_practice() {
    log_header "LoadBalancer 서비스 배포 (EKS ALB / GKE GLB)"
    
    # 현재 클러스터 타입 확인
    CURRENT_CONTEXT=$(kubectl config current-context 2>/dev/null || echo "none")
    
    if [[ "$CURRENT_CONTEXT" == *"eks"* ]] || [[ "$CURRENT_CONTEXT" == *"EKS"* ]]; then
        deploy_eks_loadbalancer
    elif [[ "$CURRENT_CONTEXT" == *"gke"* ]] || [[ "$CURRENT_CONTEXT" == *"GKE"* ]]; then
        deploy_gke_loadbalancer
    else
        log_warning "클러스터 타입을 자동으로 감지할 수 없습니다."
        log_info "수동으로 클러스터 타입을 선택하세요:"
        echo "1. AWS EKS (ALB)"
        echo "2. GCP GKE (GLB)"
        read -p "선택하세요 (1-2): " cluster_type
        
        case $cluster_type in
            1)
                deploy_eks_loadbalancer
                ;;
            2)
                deploy_gke_loadbalancer
                ;;
            *)
                log_error "잘못된 선택입니다."
                return 1
                ;;
        esac
    fi
}

# EKS ALB LoadBalancer 배포
deploy_eks_loadbalancer() {
    log_header "EKS ALB LoadBalancer 배포"
    
    local practice_dir="day1-kubernetes-basics"
    mkdir -p "$practice_dir"
    cd "$practice_dir"
    
    log_info "LoadBalancer 서비스 생성"
    cat > service-loadbalancer.yaml << 'EOF'
apiVersion: v1
kind: Service
metadata:
  name: myapp-service-lb
  namespace: day1-practice
  labels:
    app: myapp
spec:
  type: LoadBalancer
  ports:
  - port: 80
    targetPort: 80
    protocol: TCP
  selector:
    app: myapp
EOF

    # 기존 ClusterIP 서비스 삭제
    kubectl delete service myapp-service -n day1-practice 2>/dev/null || true
    
    # LoadBalancer 서비스 배포
    kubectl apply -f service-loadbalancer.yaml
    
    log_info "LoadBalancer 서비스 생성 중... (1-2분 소요)"
    log_info "External IP 할당 대기 중..."
    
    # External IP 확인
    for i in {1..12}; do
        EXTERNAL_IP=$(kubectl get service myapp-service-lb -n day1-practice -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null)
        if [ -n "$EXTERNAL_IP" ]; then
            log_success "LoadBalancer 서비스 배포 완료!"
            log_info "External IP: $EXTERNAL_IP"
            log_info "접근 URL: http://$EXTERNAL_IP"
            break
        else
            log_info "External IP 할당 대기 중... ($i/12)"
            sleep 10
        fi
    done
    
    if [ -z "$EXTERNAL_IP" ]; then
        log_warning "External IP가 아직 할당되지 않았습니다. 잠시 후 다시 확인하세요."
        kubectl get service myapp-service-lb -n day1-practice
    fi
    
    log_success "EKS ALB LoadBalancer 배포 완료"
    cd ..
}

# GKE GLB LoadBalancer 배포
deploy_gke_loadbalancer() {
    log_header "GKE GLB LoadBalancer 배포"
    
    # GKE LoadBalancer 구성 옵션 메뉴
    echo ""
    log_header "GKE LoadBalancer 구성 옵션"
    echo "1. 기본 External LoadBalancer"
    echo "2. Internal LoadBalancer"
    echo "3. Global LoadBalancer"
    echo "4. 고급 LoadBalancer (BackendConfig 포함)"
    echo "5. SSL/TLS LoadBalancer"
    echo "6. 이전 메뉴로 돌아가기"
    echo ""
    read -p "선택하세요 (1-6): " gke_lb_choice
    
    case $gke_lb_choice in
        1)
            deploy_gke_basic_loadbalancer
            ;;
        2)
            deploy_gke_internal_loadbalancer
            ;;
        3)
            deploy_gke_global_loadbalancer
            ;;
        4)
            deploy_gke_advanced_loadbalancer
            ;;
        5)
            deploy_gke_ssl_loadbalancer
            ;;
        6)
            return
            ;;
        *)
            log_error "잘못된 선택입니다. 1-6 중에서 선택하세요."
            ;;
    esac
}

# GKE 기본 External LoadBalancer 배포
deploy_gke_basic_loadbalancer() {
    log_header "GKE 기본 External LoadBalancer 배포"
    
    local practice_dir="day1-kubernetes-basics"
    mkdir -p "$practice_dir"
    cd "$practice_dir"
    
    log_info "GKE 기본 External LoadBalancer 서비스 생성"
    cat > service-gke-basic-lb.yaml << 'EOF'
apiVersion: v1
kind: Service
metadata:
  name: myapp-service-gke-basic-lb
  namespace: day1-practice
  labels:
    app: myapp
  annotations:
    cloud.google.com/load-balancer-type: "External"
spec:
  type: LoadBalancer
  ports:
  - port: 80
    targetPort: 80
    protocol: TCP
  selector:
    app: myapp
EOF

    # 기존 ClusterIP 서비스 삭제
    kubectl delete service myapp-service -n day1-practice 2>/dev/null || true
    
    # GKE LoadBalancer 서비스 배포
    kubectl apply -f service-gke-basic-lb.yaml
    
    log_info "GKE LoadBalancer 서비스 생성 중... (1-2분 소요)"
    log_info "External IP 할당 대기 중..."
    
    # External IP 확인
    for i in {1..12}; do
        EXTERNAL_IP=$(kubectl get service myapp-service-gke-basic-lb -n day1-practice -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null)
        if [ -n "$EXTERNAL_IP" ]; then
            log_success "GKE LoadBalancer 서비스 배포 완료!"
            log_info "External IP: $EXTERNAL_IP"
            log_info "접근 URL: http://$EXTERNAL_IP"
            break
        else
            log_info "External IP 할당 대기 중... ($i/12)"
            sleep 10
        fi
    done
    
    if [ -z "$EXTERNAL_IP" ]; then
        log_warning "External IP가 아직 할당되지 않았습니다. 잠시 후 다시 확인하세요."
        kubectl get service myapp-service-gke-basic-lb -n day1-practice
    fi
    
    log_success "GKE 기본 External LoadBalancer 배포 완료"
    cd ..
}

# GKE Internal LoadBalancer 배포
deploy_gke_internal_loadbalancer() {
    log_header "GKE Internal LoadBalancer 배포"
    
    local practice_dir="day1-kubernetes-basics"
    mkdir -p "$practice_dir"
    cd "$practice_dir"
    
    log_info "GKE Internal LoadBalancer 서비스 생성"
    cat > service-gke-internal-lb.yaml << 'EOF'
apiVersion: v1
kind: Service
metadata:
  name: myapp-service-gke-internal-lb
  namespace: day1-practice
  labels:
    app: myapp
  annotations:
    cloud.google.com/load-balancer-type: "Internal"
    networking.gke.io/load-balancer-subnet: "default"
spec:
  type: LoadBalancer
  ports:
  - port: 80
    targetPort: 80
    protocol: TCP
  selector:
    app: myapp
EOF

    # GKE Internal LoadBalancer 서비스 배포
    kubectl apply -f service-gke-internal-lb.yaml
    
    log_info "GKE Internal LoadBalancer 서비스 생성 중... (1-2분 소요)"
    log_info "Internal IP 할당 대기 중..."
    
    # Internal IP 확인
    for i in {1..12}; do
        INTERNAL_IP=$(kubectl get service myapp-service-gke-internal-lb -n day1-practice -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null)
        if [ -n "$INTERNAL_IP" ]; then
            log_success "GKE Internal LoadBalancer 서비스 배포 완료!"
            log_info "Internal IP: $INTERNAL_IP"
            log_info "VPC 내부 접근 URL: http://$INTERNAL_IP"
            break
        else
            log_info "Internal IP 할당 대기 중... ($i/12)"
            sleep 10
        fi
    done
    
    if [ -z "$INTERNAL_IP" ]; then
        log_warning "Internal IP가 아직 할당되지 않았습니다. 잠시 후 다시 확인하세요."
        kubectl get service myapp-service-gke-internal-lb -n day1-practice
    fi
    
    log_success "GKE Internal LoadBalancer 배포 완료"
    cd ..
}

# GKE Global LoadBalancer 배포
deploy_gke_global_loadbalancer() {
    log_header "GKE Global LoadBalancer 배포"
    
    local practice_dir="day1-kubernetes-basics"
    mkdir -p "$practice_dir"
    cd "$practice_dir"
    
    log_info "GKE Global LoadBalancer 서비스 생성"
    cat > service-gke-global-lb.yaml << 'EOF'
apiVersion: v1
kind: Service
metadata:
  name: myapp-service-gke-global-lb
  namespace: day1-practice
  labels:
    app: myapp
  annotations:
    cloud.google.com/load-balancer-type: "External"
    networking.gke.io/load-balancer-type: "Global"
spec:
  type: LoadBalancer
  ports:
  - port: 80
    targetPort: 80
    protocol: TCP
  selector:
    app: myapp
EOF

    # GKE Global LoadBalancer 서비스 배포
    kubectl apply -f service-gke-global-lb.yaml
    
    log_info "GKE Global LoadBalancer 서비스 생성 중... (2-3분 소요)"
    log_info "Global IP 할당 대기 중..."
    
    # Global IP 확인
    for i in {1..18}; do
        GLOBAL_IP=$(kubectl get service myapp-service-gke-global-lb -n day1-practice -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null)
        if [ -n "$GLOBAL_IP" ]; then
            log_success "GKE Global LoadBalancer 서비스 배포 완료!"
            log_info "Global IP: $GLOBAL_IP"
            log_info "전 세계 접근 URL: http://$GLOBAL_IP"
            break
        else
            log_info "Global IP 할당 대기 중... ($i/18)"
            sleep 10
        fi
    done
    
    if [ -z "$GLOBAL_IP" ]; then
        log_warning "Global IP가 아직 할당되지 않았습니다. 잠시 후 다시 확인하세요."
        kubectl get service myapp-service-gke-global-lb -n day1-practice
    fi
    
    log_success "GKE Global LoadBalancer 배포 완료"
    cd ..
}

# GKE 고급 LoadBalancer 배포 (BackendConfig 포함)
deploy_gke_advanced_loadbalancer() {
    log_header "GKE 고급 LoadBalancer 배포 (BackendConfig 포함)"
    
    local practice_dir="day1-kubernetes-basics"
    mkdir -p "$practice_dir"
    cd "$practice_dir"
    
    log_info "BackendConfig 생성"
    cat > backend-config.yaml << 'EOF'
apiVersion: cloud.google.com/v1
kind: BackendConfig
metadata:
  name: myapp-backend-config
  namespace: day1-practice
spec:
  healthCheck:
    checkIntervalSec: 10
    timeoutSec: 5
    healthyThreshold: 2
    unhealthyThreshold: 3
    path: "/"
    port: 80
  sessionAffinity:
    affinityType: "CLIENT_IP"
  connectionDraining:
    drainingTimeoutSec: 60
EOF

    log_info "GKE 고급 LoadBalancer 서비스 생성"
    cat > service-gke-advanced-lb.yaml << 'EOF'
apiVersion: v1
kind: Service
metadata:
  name: myapp-service-gke-advanced-lb
  namespace: day1-practice
  labels:
    app: myapp
  annotations:
    cloud.google.com/load-balancer-type: "External"
    cloud.google.com/backend-config: '{"default": "myapp-backend-config"}'
    cloud.google.com/neg: '{"ingress": true}'
spec:
  type: LoadBalancer
  ports:
  - port: 80
    targetPort: 80
    protocol: TCP
  selector:
    app: myapp
EOF

    # BackendConfig 배포
    kubectl apply -f backend-config.yaml
    
    # GKE 고급 LoadBalancer 서비스 배포
    kubectl apply -f service-gke-advanced-lb.yaml
    
    log_info "GKE 고급 LoadBalancer 서비스 생성 중... (2-3분 소요)"
    log_info "External IP 할당 대기 중..."
    
    # External IP 확인
    for i in {1..18}; do
        EXTERNAL_IP=$(kubectl get service myapp-service-gke-advanced-lb -n day1-practice -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null)
        if [ -n "$EXTERNAL_IP" ]; then
            log_success "GKE 고급 LoadBalancer 서비스 배포 완료!"
            log_info "External IP: $EXTERNAL_IP"
            log_info "접근 URL: http://$EXTERNAL_IP"
            log_info "BackendConfig 적용됨: myapp-backend-config"
            break
        else
            log_info "External IP 할당 대기 중... ($i/18)"
            sleep 10
        fi
    done
    
    if [ -z "$EXTERNAL_IP" ]; then
        log_warning "External IP가 아직 할당되지 않았습니다. 잠시 후 다시 확인하세요."
        kubectl get service myapp-service-gke-advanced-lb -n day1-practice
    fi
    
    log_success "GKE 고급 LoadBalancer 배포 완료"
    cd ..
}

# GKE SSL/TLS LoadBalancer 배포
deploy_gke_ssl_loadbalancer() {
    log_header "GKE SSL/TLS LoadBalancer 배포"
    
    local practice_dir="day1-kubernetes-basics"
    mkdir -p "$practice_dir"
    cd "$practice_dir"
    
    log_info "GKE SSL/TLS LoadBalancer 서비스 생성"
    cat > service-gke-ssl-lb.yaml << 'EOF'
apiVersion: v1
kind: Service
metadata:
  name: myapp-service-gke-ssl-lb
  namespace: day1-practice
  labels:
    app: myapp
  annotations:
    cloud.google.com/load-balancer-type: "External"
    cloud.google.com/ssl-redirect: "true"
spec:
  type: LoadBalancer
  ports:
  - port: 443
    targetPort: 80
    name: https
  - port: 80
    targetPort: 80
    name: http
  selector:
    app: myapp
EOF

    # GKE SSL LoadBalancer 서비스 배포
    kubectl apply -f service-gke-ssl-lb.yaml
    
    log_info "GKE SSL LoadBalancer 서비스 생성 중... (2-3분 소요)"
    log_info "External IP 할당 대기 중..."
    
    # External IP 확인
    for i in {1..18}; do
        EXTERNAL_IP=$(kubectl get service myapp-service-gke-ssl-lb -n day1-practice -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null)
        if [ -n "$EXTERNAL_IP" ]; then
            log_success "GKE SSL LoadBalancer 서비스 배포 완료!"
            log_info "External IP: $EXTERNAL_IP"
            log_info "HTTP 접근 URL: http://$EXTERNAL_IP"
            log_info "HTTPS 접근 URL: https://$EXTERNAL_IP"
            log_warning "SSL 인증서가 필요합니다. Google Managed SSL 인증서를 설정하세요."
            break
        else
            log_info "External IP 할당 대기 중... ($i/18)"
            sleep 10
        fi
    done
    
    if [ -z "$EXTERNAL_IP" ]; then
        log_warning "External IP가 아직 할당되지 않았습니다. 잠시 후 다시 확인하세요."
        kubectl get service myapp-service-gke-ssl-lb -n day1-practice
    fi
    
    log_success "GKE SSL LoadBalancer 배포 완료"
    cd ..
}

# NodePort 서비스 배포
kubernetes_nodeport_practice() {
    log_header "NodePort 서비스 배포"
    
    local practice_dir="day1-kubernetes-basics"
    mkdir -p "$practice_dir"
    cd "$practice_dir"
    
    log_info "NodePort 서비스 생성"
    cat > service-nodeport.yaml << 'EOF'
apiVersion: v1
kind: Service
metadata:
  name: myapp-service-np
  namespace: day1-practice
  labels:
    app: myapp
spec:
  type: NodePort
  ports:
  - port: 80
    targetPort: 80
    nodePort: 30080
    protocol: TCP
  selector:
    app: myapp
EOF

    # NodePort 서비스 배포
    kubectl apply -f service-nodeport.yaml
    
    log_success "NodePort 서비스 배포 완료!"
    
    # NodePort 및 노드 IP 확인
    NODEPORT=$(kubectl get service myapp-service-np -n day1-practice -o jsonpath='{.spec.ports[0].nodePort}')
    NODE_IP=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="ExternalIP")].address}')
    if [ -z "$NODE_IP" ]; then
        NODE_IP=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')
    fi
    
    log_info "NodePort: $NODEPORT"
    log_info "노드 IP: $NODE_IP"
    log_info "접근 URL: http://$NODE_IP:$NODEPORT"
    
    log_success "NodePort 서비스 배포 완료"
    cd ..
}

# Ingress 설정
kubernetes_ingress_practice() {
    log_header "Ingress 설정"
    
    local practice_dir="day1-kubernetes-basics"
    mkdir -p "$practice_dir"
    cd "$practice_dir"
    
    log_info "Ingress 설정"
    cat > ingress-basic.yaml << 'EOF'
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: myapp-ingress
  namespace: day1-practice
  annotations:
    kubernetes.io/ingress.class: "alb"
    alb.ingress.kubernetes.io/scheme: internet-facing
    alb.ingress.kubernetes.io/target-type: ip
    alb.ingress.kubernetes.io/listen-ports: '[{"HTTP": 80}]'
spec:
  rules:
  - host: myapp.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: myapp-service
            port:
              number: 80
EOF

    # AWS Load Balancer Controller 설치 확인
    if ! kubectl get deployment aws-load-balancer-controller -n kube-system >/dev/null 2>&1; then
        log_warning "AWS Load Balancer Controller가 설치되지 않았습니다."
        log_info "Ingress 설정을 위해서는 ALB Ingress Controller가 필요합니다."
        return 1
    fi
    
    # Ingress 배포
    kubectl apply -f ingress-basic.yaml
    
    log_success "Ingress 설정 완료!"
    log_info "ALB 생성 중... (2-3분 소요)"
    
    # ALB URL 확인
    sleep 30
    ALB_URL=$(kubectl get ingress myapp-ingress -n day1-practice -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
    
    if [ -n "$ALB_URL" ]; then
        log_success "ALB 생성 완료!"
        log_info "ALB URL: http://$ALB_URL"
    else
        log_warning "ALB가 아직 생성되지 않았습니다. 잠시 후 다시 확인하세요."
    fi
    
    log_success "Ingress 설정 완료"
    cd ..
}

# 포트 포워딩 테스트
kubernetes_port_forward_practice() {
    log_header "포트 포워딩 테스트"
    
    log_info "포트 포워딩 설정 중..."
    
    # 기존 포트 포워딩 프로세스 종료
    pkill -f "kubectl port-forward" 2>/dev/null || true
    
    # 포트 포워딩 시작
    kubectl port-forward service/myapp-service 8080:80 -n day1-practice &
    PORT_FORWARD_PID=$!
    
    sleep 3
    
    if ps -p $PORT_FORWARD_PID > /dev/null; then
        log_success "포트 포워딩 설정 완료!"
        log_info "로컬 접근 URL: http://localhost:8080"
        log_info "포트 포워딩 PID: $PORT_FORWARD_PID"
        log_warning "포트 포워딩을 중지하려면: kill $PORT_FORWARD_PID"
        
        # 접근 테스트
        log_info "접근 테스트 중..."
        if curl -s -o /dev/null -w "HTTP Status: %{http_code}\n" "http://localhost:8080"; then
            log_success "포트 포워딩 접근 성공!"
        else
            log_warning "포트 포워딩 접근 실패"
        fi
    else
        log_error "포트 포워딩 설정 실패"
    fi
    
    log_success "포트 포워딩 테스트 완료"
}

# 리소스 상태 확인
kubernetes_status_check() {
    log_header "리소스 상태 확인"
    
    echo -e "\n${PURPLE}=== Namespace: day1-practice ===${NC}"
    kubectl get all -n day1-practice
    
    echo -e "\n${PURPLE}=== 서비스 상세 정보 ===${NC}"
    kubectl get services -n day1-practice -o wide
    
    echo -e "\n${PURPLE}=== Ingress 정보 ===${NC}"
    kubectl get ingress -n day1-practice 2>/dev/null || echo "Ingress 없음"
    
    echo -e "\n${PURPLE}=== ConfigMap 및 Secret ===${NC}"
    kubectl get configmap,secret -n day1-practice
    
    log_success "리소스 상태 확인 완료"
}

# 기존 kubernetes_basics_practice 함수를 서브 메뉴로 변경
kubernetes_basics_practice() {
    kubernetes_basics_submenu
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

# 통합 모니터링 허브 구축 실습
monitoring_hub_practice() {
    log_header "통합 모니터링 허브 구축 실습"
    
    local practice_dir="day1-monitoring-hub"
    mkdir -p "$practice_dir"
    cd "$practice_dir"
    
    # 1. Prometheus 설정
    log_info "1. Prometheus 설정"
    mkdir -p prometheus/rules
    cat > prometheus/prometheus.yml << 'EOF'
global:
  scrape_interval: 15s
  evaluation_interval: 15s
  external_labels:
    cluster: 'cloud-intermediate'
    environment: 'learning'

rule_files:
  - "rules/*.yml"

alerting:
  alertmanagers:
    - static_configs:
        - targets:
          - alertmanager:9093

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']
    scrape_interval: 5s
    metrics_path: '/metrics'

  - job_name: 'node-exporter'
    static_configs:
      - targets: ['node-exporter:9100']
    scrape_interval: 15s
    metrics_path: '/metrics'

  - job_name: 'grafana'
    static_configs:
      - targets: ['grafana:3000']
    scrape_interval: 30s
    metrics_path: '/metrics'

  - job_name: 'alertmanager'
    static_configs:
      - targets: ['alertmanager:9093']
    scrape_interval: 30s
    metrics_path: '/metrics'
EOF

    # 2. Prometheus 알람 규칙 생성
    log_info "2. Prometheus 알람 규칙 생성"
    cat > prometheus/rules/cpu-alerts.yml << 'EOF'
groups:
- name: cpu-alerts
  rules:
  - alert: HighCPUUsage
    expr: 100 - (avg by(instance) (irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100) > 80
    for: 5m
    labels:
      severity: warning
    annotations:
      summary: "High CPU usage detected"
      description: "CPU usage is above 80% for more than 5 minutes on {{ $labels.instance }}"

  - alert: CriticalCPUUsage
    expr: 100 - (avg by(instance) (irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100) > 95
    for: 2m
    labels:
      severity: critical
    annotations:
      summary: "Critical CPU usage detected"
      description: "CPU usage is above 95% for more than 2 minutes on {{ $labels.instance }}"
EOF

    cat > prometheus/rules/memory-alerts.yml << 'EOF'
groups:
- name: memory-alerts
  rules:
  - alert: HighMemoryUsage
    expr: (1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100 > 80
    for: 5m
    labels:
      severity: warning
    annotations:
      summary: "High memory usage detected"
      description: "Memory usage is above 80% for more than 5 minutes on {{ $labels.instance }}"

  - alert: CriticalMemoryUsage
    expr: (1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100 > 95
    for: 2m
    labels:
      severity: critical
    annotations:
      summary: "Critical memory usage detected"
      description: "Memory usage is above 95% for more than 2 minutes on {{ $labels.instance }}"
EOF

    # 3. Grafana 설정
    log_info "3. Grafana 설정"
    mkdir -p grafana
    cat > grafana/grafana.ini << 'EOF'
[server]
http_port = 3000
root_url = http://localhost:3000/

[security]
admin_user = admin
admin_password = admin123

[database]
type = sqlite3
path = grafana.db

[log]
mode = console
level = info

[alerting]
enabled = true

[unified_alerting]
enabled = true
EOF

    cat > grafana/datasources.yml << 'EOF'
apiVersion: 1

datasources:
  - name: Prometheus
    type: prometheus
    access: proxy
    url: http://prometheus:9090
    isDefault: true
    editable: true
EOF

    # 4. AlertManager 설정
    log_info "4. AlertManager 설정"
    mkdir -p alertmanager
    cat > alertmanager/alertmanager.yml << 'EOF'
global:
  smtp_smarthost: 'localhost:587'
  smtp_from: 'alertmanager@example.com'

route:
  group_by: ['alertname']
  group_wait: 10s
  group_interval: 10s
  repeat_interval: 1h
  receiver: 'web.hook'

receivers:
- name: 'web.hook'
  webhook_configs:
  - url: 'http://localhost:5001/'

inhibit_rules:
  - source_match:
      severity: 'critical'
    target_match:
      severity: 'warning'
    equal: ['alertname', 'dev', 'instance']
EOF

    # 5. Docker Compose 파일 생성
    log_info "5. Docker Compose 파일 생성"
    cat > docker-compose.yml << 'EOF'
version: '3.8'

services:
  prometheus:
    image: prom/prometheus:latest
    container_name: prometheus
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus/prometheus.yml:/etc/prometheus/prometheus.yml
      - ./prometheus/rules:/etc/prometheus/rules
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
      - '--web.console.libraries=/etc/prometheus/console_libraries'
      - '--web.console.templates=/etc/prometheus/consoles'
      - '--web.enable-lifecycle'
    networks:
      - monitoring

  grafana:
    image: grafana/grafana:latest
    container_name: grafana
    ports:
      - "3000:3000"
    volumes:
      - ./grafana/grafana.ini:/etc/grafana/grafana.ini
      - ./grafana/datasources.yml:/etc/grafana/provisioning/datasources/datasources.yml
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin123
    networks:
      - monitoring

  node-exporter:
    image: prom/node-exporter:latest
    container_name: node-exporter
    ports:
      - "9100:9100"
    volumes:
      - /proc:/host/proc:ro
      - /sys:/host/sys:ro
      - /:/rootfs:ro
    command:
      - '--path.procfs=/host/proc'
      - '--path.sysfs=/host/sys'
      - '--collector.filesystem.mount-points-exclude=^/(sys|proc|dev|host|etc)($|/)'
    networks:
      - monitoring

  alertmanager:
    image: prom/alertmanager:latest
    container_name: alertmanager
    ports:
      - "9093:9093"
    volumes:
      - ./alertmanager/alertmanager.yml:/etc/alertmanager/alertmanager.yml
    command:
      - '--config.file=/etc/alertmanager/alertmanager.yml'
      - '--storage.path=/alertmanager'
    networks:
      - monitoring

networks:
  monitoring:
    driver: bridge
EOF

    # 6. 모니터링 스택 실행
    log_info "6. 모니터링 스택 실행"
    docker network create monitoring 2>/dev/null || true
    docker-compose up -d

    # 7. 서비스 상태 확인
    log_info "7. 서비스 상태 확인"
    sleep 10
    
    echo "=== 모니터링 서비스 상태 ==="
    docker-compose ps
    
    echo ""
    echo "=== 서비스 접속 정보 ==="
    echo "Prometheus: http://localhost:9090"
    echo "Grafana: http://localhost:3000 (admin/admin123)"
    echo "Node Exporter: http://localhost:9100"
    echo "AlertManager: http://localhost:9093"
    
    # 8. 메트릭 수집 테스트
    log_info "8. 메트릭 수집 테스트"
    echo "Prometheus 타겟 확인:"
    curl -s http://localhost:9090/api/v1/targets | jq '.data.activeTargets[] | {job: .labels.job, health: .health}'
    
    echo ""
    echo "Node Exporter 메트릭 확인:"
    curl -s http://localhost:9100/metrics | grep node_cpu_seconds_total | head -3
    
    # 9. Grafana 대시보드 생성 가이드
    log_info "9. Grafana 대시보드 생성 가이드"
    cat > grafana-dashboard-guide.md << 'EOF'
# Grafana 대시보드 생성 가이드

## 1. 기본 대시보드 생성
1. Grafana 접속: http://localhost:3000
2. 로그인: admin / admin123
3. "+" 버튼 클릭 → "Dashboard" 선택
4. "Add new panel" 클릭

## 2. CPU 사용률 그래프
- Query: `100 - (avg by(instance) (irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)`
- Legend: `CPU Usage %`
- Y-axis: 0-100

## 3. 메모리 사용률 그래프
- Query: `(1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100`
- Legend: `Memory Usage %`
- Y-axis: 0-100

## 4. 디스크 사용률 그래프
- Query: `(1 - (node_filesystem_avail_bytes / node_filesystem_size_bytes)) * 100`
- Legend: `Disk Usage %`
- Y-axis: 0-100

## 5. 대시보드 저장
- "Save" 버튼 클릭
- 대시보드 이름: "System Monitoring"
- 폴더: "General"
EOF

    log_success "통합 모니터링 허브 구축 완료"
    log_info "모니터링 서비스가 실행 중입니다. 위의 접속 정보를 확인하세요."
    cd ..
}

# 실습 테스트 및 검증
practice_test_validation() {
    log_header "실습 테스트 및 검증"
    
    # 테스트 스크립트 실행
    local test_script="../../samples/day1/test-setup.sh"
    if [ -f "$test_script" ]; then
        log_info "실습 테스트 스크립트 실행"
        chmod +x "$test_script"
        "$test_script"
    else
        log_error "테스트 스크립트를 찾을 수 없습니다: $test_script"
        return 1
    fi
    
    log_success "실습 테스트 및 검증 완료"
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
        echo "5. 클러스터 상태"
        echo "6. EKS 클러스터 정리 (개선된 로직)"
        echo "7. 뒤로 가기"
        echo ""
    }
    
    while true; do
        show_cluster_menu
        read -p "선택하세요 (1-7): " choice
        
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
                log_info "클러스터 상태"
                deployment_management
                ;;
            6)
                log_info "EKS 클러스터 정리 (개선된 로직)"
                improved_eks_cleanup
                ;;
            7)
                log_info "클러스터 관리 메뉴를 종료합니다"
                break
                ;;
            *)
                log_error "잘못된 선택입니다. 1-7 중에서 선택하세요."
                ;;
        esac
        
        echo ""
        read -p "계속하려면 Enter를 누르세요..."
        # Enter 입력 시 현재 메뉴 유지 (종료하지 않음)
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

# 개선된 EKS 클러스터 정리
improved_eks_cleanup() {
    log_header "EKS 클러스터 정리 (개선된 로직)"
    
    # 개선된 EKS 정리 스크립트 실행
    local improved_cleanup="../../tools/cloud/improved-eks-cleanup.sh"
    if [ -f "$improved_cleanup" ]; then
        log_info "개선된 EKS 정리 스크립트 실행 중..."
        chmod +x "$improved_cleanup"
        "$improved_cleanup"
    else
        log_warning "개선된 EKS 정리 스크립트를 찾을 수 없습니다: $improved_cleanup"
        log_info "대신 기존 EKS Helper를 사용합니다."
        
        # 대안: 기존 EKS Helper의 delete 액션 사용
        local eks_helper="../../tools/cloud/aws-eks-helper.sh"
        if [ -f "$eks_helper" ]; then
            chmod +x "$eks_helper"
            "$eks_helper" --action delete
        else
            log_error "EKS Helper도 찾을 수 없습니다."
        fi
    fi
}

# 배포 관리
deployment_management() {
    log_header "클러스터 상태"
    
    # 클러스터 상태 메뉴
    show_deployment_menu() {
        echo ""
        log_header "클러스터 상태 메뉴"
        echo "1. 현재 배포 현황 확인"
        echo "2. EKS 클러스터 상태"
        echo "3. GKE 클러스터 상태"
        echo "4. 통합 클러스터 상태"
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
                log_info "EKS 클러스터 상태 확인"
                local eks_helper="../../tools/cloud/aws-eks-helper.sh"
                if [ -f "$eks_helper" ]; then
                    chmod +x "$eks_helper"
                    "$eks_helper" --action status
                else
                    log_warning "EKS Helper를 찾을 수 없습니다"
                fi
                ;;
            3)
                log_info "GKE 클러스터 상태 확인"
                local gke_helper="../../tools/cloud/gcp-gke-helper.sh"
                if [ -f "$gke_helper" ]; then
                    chmod +x "$gke_helper"
                    "$gke_helper" --action status
                else
                    log_warning "GKE Helper를 찾을 수 없습니다"
                fi
                ;;
            4)
                log_info "통합 클러스터 상태 확인"
                local cluster_helper="../../tools/cloud/cloud-cluster-helper.sh"
                if [ -f "$cluster_helper" ]; then
                    chmod +x "$cluster_helper"
                    "$cluster_helper" --action status
                else
                    log_warning "통합 클러스터 Helper를 찾을 수 없습니다"
                fi
                ;;
            5)
                log_info "클러스터 상태 메뉴를 종료합니다"
                break
                ;;
            *)
                log_error "잘못된 선택입니다. 1-5 중에서 선택하세요."
                ;;
        esac
        
        echo ""
        read -p "계속하려면 Enter를 누르세요..."
        # Enter 입력 시 현재 메뉴 유지 (종료하지 않음)
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
        # Enter 입력 시 현재 메뉴 유지 (종료하지 않음)
    done
}

# 현재 리소스 상태 확인 함수
show_current_resources() {
    echo ""
    log_header "=== 현재 리소스 상태 ==="
    
    # Docker 리소스 확인
    log_info "Docker 리소스 상태:"
    if command -v docker &> /dev/null; then
        echo "Docker 이미지:"
        docker images | grep -E "(myapp|day1)" 2>/dev/null || echo "  - 관련 이미지 없음"
        echo ""
        echo "Docker 컨테이너:"
        docker ps -a | grep -E "(myapp|day1)" 2>/dev/null || echo "  - 관련 컨테이너 없음"
    else
        echo "  - Docker가 설치되지 않음"
    fi
    echo ""
    
    # Kubernetes 클러스터 확인
    log_info "Kubernetes 클러스터 상태:"
    if command -v kubectl &> /dev/null; then
        # 현재 컨텍스트 확인
        current_context=$(kubectl config current-context 2>/dev/null || echo "none")
        echo "현재 컨텍스트: $current_context"
        
        if kubectl cluster-info &> /dev/null; then
            echo "클러스터 연결: ✅ 연결됨"
            
            # 네임스페이스 확인
            echo "네임스페이스:"
            kubectl get namespaces | grep -E "(day1|practice)" 2>/dev/null || echo "  - day1-practice 네임스페이스 없음"
            
            # 리소스 확인
            if kubectl get namespace day1-practice &> /dev/null; then
                echo ""
                echo "day1-practice 네임스페이스 리소스:"
                kubectl get all -n day1-practice 2>/dev/null || echo "  - 리소스 없음"
            fi
        else
            echo "클러스터 연결: ❌ 연결 안됨"
        fi
    else
        echo "  - kubectl이 설치되지 않음"
    fi
    echo ""
    
    # AWS EKS 클러스터 확인
    log_info "AWS EKS 클러스터 상태:"
    if command -v aws &> /dev/null && aws sts get-caller-identity &> /dev/null; then
        echo "AWS 자격 증명: ✅ 설정됨"
        echo "EKS 클러스터 목록:"
        aws eks list-clusters --query 'clusters[]' --output table 2>/dev/null || echo "  - EKS 클러스터 없음"
    else
        echo "  - AWS CLI가 설치되지 않거나 자격 증명이 설정되지 않음"
    fi
    echo ""
    
    # GCP GKE 클러스터 확인
    log_info "GCP GKE 클러스터 상태:"
    if command -v gcloud &> /dev/null && gcloud auth list --filter=status:ACTIVE --format="value(account)" | head -n1 &> /dev/null; then
        echo "GCP 인증: ✅ 설정됨"
        echo "GKE 클러스터 목록:"
        gcloud container clusters list --format="table(name,location,status,currentMasterVersion)" 2>/dev/null || echo "  - GKE 클러스터 없음"
    else
        echo "  - gcloud CLI가 설치되지 않거나 인증되지 않음"
    fi
    echo ""
    
    # 실습 디렉토리 확인 (스크립트 파일 제외)
    log_info "실습 디렉토리 상태:"
    if find . -maxdepth 1 -type d -name "day1-*" 2>/dev/null; then
        echo "실습 디렉토리:"
        find . -maxdepth 1 -type d -name "day1-*" -exec ls -la {} \; 2>/dev/null
    else
        echo "  - 실습 디렉토리 없음"
    fi
    echo ""
}

# 정리 후 남은 리소스 확인 함수
show_remaining_resources() {
    echo ""
    log_header "=== 정리 후 남은 리소스 ==="
    
    # Docker 리소스 확인
    log_info "Docker 리소스 상태:"
    if command -v docker &> /dev/null; then
        remaining_images=$(docker images | grep -E "(myapp|day1)" 2>/dev/null || echo "")
        if [ -n "$remaining_images" ]; then
            echo "⚠️ 남은 Docker 이미지:"
            echo "$remaining_images"
        else
            echo "✅ Docker 이미지 정리 완료"
        fi
        
        remaining_containers=$(docker ps -a | grep -E "(myapp|day1)" 2>/dev/null || echo "")
        if [ -n "$remaining_containers" ]; then
            echo "⚠️ 남은 Docker 컨테이너:"
            echo "$remaining_containers"
        else
            echo "✅ Docker 컨테이너 정리 완료"
        fi
    else
        echo "  - Docker가 설치되지 않음"
    fi
    echo ""
    
    # Kubernetes 리소스 확인
    log_info "Kubernetes 리소스 상태:"
    if command -v kubectl &> /dev/null && kubectl cluster-info &> /dev/null; then
        if kubectl get namespace day1-practice &> /dev/null; then
            echo "⚠️ day1-practice 네임스페이스가 아직 존재합니다:"
            kubectl get all -n day1-practice 2>/dev/null || echo "  - 리소스 없음"
        else
            echo "✅ day1-practice 네임스페이스 정리 완료"
        fi
    else
        echo "  - Kubernetes 클러스터에 연결할 수 없음"
    fi
    echo ""
    
    # AWS EKS 클러스터 확인
    log_info "AWS EKS 클러스터 상태:"
    if command -v aws &> /dev/null && aws sts get-caller-identity &> /dev/null; then
        eks_clusters=$(aws eks list-clusters --query 'clusters[]' --output text 2>/dev/null || echo "")
        if [ -n "$eks_clusters" ]; then
            echo "⚠️ EKS 클러스터가 여전히 존재합니다:"
            echo "$eks_clusters"
            echo "수동 삭제가 필요합니다:"
            echo "$eks_clusters" | while read cluster; do
                echo "  - aws eks delete-cluster --name $cluster"
            done
        else
            echo "✅ EKS 클러스터 없음"
        fi
    else
        echo "  - AWS CLI가 설치되지 않거나 자격 증명이 설정되지 않음"
    fi
    echo ""
    
    # GCP GKE 클러스터 확인
    log_info "GCP GKE 클러스터 상태:"
    if command -v gcloud &> /dev/null && gcloud auth list --filter=status:ACTIVE --format="value(account)" | head -n1 &> /dev/null; then
        gke_clusters=$(gcloud container clusters list --format="value(name,location)" 2>/dev/null || echo "")
        if [ -n "$gke_clusters" ]; then
            echo "⚠️ GKE 클러스터가 여전히 존재합니다:"
            gcloud container clusters list --format="table(name,location,status)" 2>/dev/null || echo "  - 클러스터 정보를 가져올 수 없음"
            echo "수동 삭제가 필요합니다:"
            echo "$gke_clusters" | while read name location; do
                echo "  - gcloud container clusters delete $name --zone $location"
            done
        else
            echo "✅ GKE 클러스터 없음"
        fi
    else
        echo "  - gcloud CLI가 설치되지 않거나 인증되지 않음"
    fi
    echo ""
    
    # 실습 디렉토리 확인 (스크립트 파일 제외)
    log_info "실습 디렉토리 상태:"
    remaining_dirs=$(find . -maxdepth 1 -type d -name "day1-*" 2>/dev/null || echo "")
    if [ -n "$remaining_dirs" ]; then
        echo "⚠️ 남은 실습 디렉토리:"
        echo "$remaining_dirs"
        echo "수동 삭제가 필요합니다:"
        echo "$remaining_dirs" | while read dir; do
            echo "  - rm -rf $dir"
        done
    else
        echo "✅ 실습 디렉토리 정리 완료"
    fi
    echo ""
}

# 클러스터 삭제 함수
delete_clusters() {
    log_header "클러스터 삭제"
    
    # EKS 클러스터 및 연계 리소스 삭제
    log_info "EKS 클러스터 및 연계 리소스 삭제"
    if command -v aws &> /dev/null && aws sts get-caller-identity &> /dev/null; then
        eks_clusters=$(aws eks list-clusters --query 'clusters[]' --output text 2>/dev/null || echo "")
        if [ -n "$eks_clusters" ]; then
            echo "삭제할 EKS 클러스터:"
            echo "$eks_clusters"
            echo ""
            
            # 연계 리소스 확인
            log_info "EKS 연계 리소스 확인"
            echo "Load Balancer:"
            aws elbv2 describe-load-balancers --query 'LoadBalancers[?contains(LoadBalancerName, `k8s`) || contains(LoadBalancerName, `eks`)].{Name:LoadBalancerName,Type:Type,State:State.Code}' --output table 2>/dev/null || echo "  - Load Balancer 없음"
            
            echo "Security Groups:"
            aws ec2 describe-security-groups --query 'SecurityGroups[?contains(GroupName, `eks`) || contains(GroupName, `k8s`)].{Name:GroupName,Id:GroupId}' --output table 2>/dev/null || echo "  - EKS 관련 Security Group 없음"
            
            echo "CloudWatch Log Groups:"
            aws logs describe-log-groups --query 'logGroups[?contains(logGroupName, `/aws/eks`)].{Name:logGroupName}' --output table 2>/dev/null || echo "  - EKS Log Group 없음"
            
            echo ""
            log_info "EKS 클러스터 및 연계 리소스 자동 삭제 시작"
            
            # 1단계: EKS 클러스터 강화된 삭제 프로세스
            log_info "1단계: EKS 클러스터 강화된 삭제 프로세스"
            echo "$eks_clusters" | while read cluster; do
                log_info "EKS 클러스터 삭제 시작: $cluster"
                
                # 1-1. NodeGroups 먼저 삭제
                log_info "NodeGroups 삭제 중..."
                nodegroups=$(aws eks list-nodegroups --cluster-name "$cluster" --query 'nodegroups[]' --output text 2>/dev/null || echo "")
                if [ -n "$nodegroups" ]; then
                    for nodegroup in $nodegroups; do
                        log_info "NodeGroup 삭제 중: $nodegroup"
                        aws eks delete-nodegroup --cluster-name "$cluster" --nodegroup-name "$nodegroup" 2>/dev/null || log_warning "NodeGroup 삭제 실패: $nodegroup"
                        
                        # NodeGroup 삭제 대기 (최대 15분)
                        for j in {1..60}; do
                            ng_status=$(aws eks describe-nodegroup --cluster-name "$cluster" --nodegroup-name "$nodegroup" --query 'nodegroup.status' --output text 2>/dev/null || echo "DELETED")
                            if [ "$ng_status" = "DELETED" ] || [ "$ng_status" = "FAILED" ]; then
                                log_success "NodeGroup 삭제 완료: $nodegroup"
                                break
                            fi
                            log_info "NodeGroup 삭제 진행 중... ($j/60) - 상태: $ng_status"
                            sleep 15
                        done
                        
                        # NodeGroup 삭제 최종 확인
                        final_ng_status=$(aws eks describe-nodegroup --cluster-name "$cluster" --nodegroup-name "$nodegroup" --query 'nodegroup.status' --output text 2>/dev/null || echo "DELETED")
                        if [ "$final_ng_status" != "DELETED" ]; then
                            log_warning "NodeGroup 삭제 미완료: $nodegroup (상태: $final_ng_status)"
                            log_info "NodeGroup이 완전히 삭제될 때까지 더 기다려야 합니다."
                            
                            # 추가 대기 (5분)
                            log_info "NodeGroup 삭제 완료를 위해 추가 대기 중..."
                            for extra_wait in {1..20}; do
                                extra_ng_status=$(aws eks describe-nodegroup --cluster-name "$cluster" --nodegroup-name "$nodegroup" --query 'nodegroup.status' --output text 2>/dev/null || echo "DELETED")
                                if [ "$extra_ng_status" = "DELETED" ]; then
                                    log_success "NodeGroup 최종 삭제 완료: $nodegroup"
                                    break
                                fi
                                log_info "추가 대기 중... ($extra_wait/20) - 상태: $extra_ng_status"
                                sleep 15
                            done
                        else
                            log_success "NodeGroup 삭제 완료 확인: $nodegroup"
                        fi
                    done
                else
                    log_info "삭제할 NodeGroup 없음"
                fi
                
                # 1-2. Add-ons 삭제
                log_info "Add-ons 삭제 중..."
                addons=$(aws eks list-addons --cluster-name "$cluster" --query 'addons[]' --output text 2>/dev/null || echo "")
                if [ -n "$addons" ]; then
                    for addon in $addons; do
                        log_info "Add-on 삭제 중: $addon"
                        aws eks delete-addon --cluster-name "$cluster" --addon-name "$addon" 2>/dev/null || log_warning "Add-on 삭제 실패: $addon"
                        
                        # Add-on 삭제 대기 (최대 10분)
                        for k in {1..40}; do
                            addon_status=$(aws eks describe-addon --cluster-name "$cluster" --addon-name "$addon" --query 'addon.status' --output text 2>/dev/null || echo "DELETED")
                            if [ "$addon_status" = "DELETED" ] || [ "$addon_status" = "FAILED" ]; then
                                log_success "Add-on 삭제 완료: $addon"
                                break
                            fi
                            log_info "Add-on 삭제 진행 중... ($k/40) - 상태: $addon_status"
                            sleep 15
                        done
                    done
                else
                    log_info "삭제할 Add-ons 없음"
                fi
                
                # 1-3. 클러스터 삭제 전 최종 확인
                log_info "클러스터 삭제 전 최종 확인 중..."
                
                # NodeGroup 삭제 완료 확인
                remaining_ngs=$(aws eks list-nodegroups --cluster-name "$cluster" --query 'nodegroups[]' --output text 2>/dev/null || echo "")
                if [ -n "$remaining_ngs" ]; then
                    log_warning "아직 삭제되지 않은 NodeGroups: $remaining_ngs"
                    log_info "NodeGroups 삭제 완료까지 대기 중..."
                    sleep 30
                else
                    log_success "모든 NodeGroups 삭제 완료"
                fi
                
                # Add-ons 삭제 완료 확인
                remaining_addons=$(aws eks list-addons --cluster-name "$cluster" --query 'addons[]' --output text 2>/dev/null || echo "")
                if [ -n "$remaining_addons" ]; then
                    log_warning "아직 삭제되지 않은 Add-ons: $remaining_addons"
                    log_info "Add-ons 삭제 완료까지 대기 중..."
                    sleep 30
                else
                    log_success "모든 Add-ons 삭제 완료"
                fi
                
                # 클러스터 삭제 가능 여부 최종 확인
                log_info "클러스터 삭제 가능 여부 최종 확인 중..."
                cluster_status=$(aws eks describe-cluster --name "$cluster" --query 'cluster.status' --output text 2>/dev/null || echo "UNKNOWN")
                log_info "현재 클러스터 상태: $cluster_status"
                
                if [ "$cluster_status" = "ACTIVE" ]; then
                    log_info "클러스터가 ACTIVE 상태입니다. 삭제를 진행합니다."
                elif [ "$cluster_status" = "DELETING" ]; then
                    log_info "클러스터가 이미 삭제 중입니다."
                else
                    log_warning "클러스터 상태가 예상과 다릅니다: $cluster_status"
                fi
                
                # 1-4. 클러스터 삭제 (강제 옵션 포함)
                log_info "EKS 클러스터 삭제 중: $cluster"
                
                # 일반 삭제 시도
                log_info "EKS 클러스터 삭제 명령 실행 중..."
                if aws eks delete-cluster --name "$cluster" 2>/dev/null; then
                    log_success "EKS 클러스터 삭제 명령 실행됨: $cluster"
                else
                    log_warning "EKS 클러스터 삭제 명령 실패, 재시도 중..."
                    
                    # 2초 대기 후 재시도
                    sleep 2
                    if aws eks delete-cluster --name "$cluster" 2>/dev/null; then
                        log_success "EKS 클러스터 삭제 명령 재시도 성공: $cluster"
                    else
                        log_warning "EKS 클러스터 삭제 실패, 문제 진단 중..."
                    
                    # 클러스터 상태 확인
                    cluster_info=$(aws eks describe-cluster --name "$cluster" 2>/dev/null || echo "")
                    if [ -n "$cluster_info" ]; then
                        cluster_status=$(echo "$cluster_info" | jq -r '.cluster.status' 2>/dev/null || echo "UNKNOWN")
                        log_info "클러스터 상태: $cluster_status"
                        
                        # NodeGroup 상태 재확인
                        remaining_ngs=$(aws eks list-nodegroups --cluster-name "$cluster" --query 'nodegroups[]' --output text 2>/dev/null || echo "")
                        if [ -n "$remaining_ngs" ]; then
                            log_warning "아직 삭제되지 않은 NodeGroups: $remaining_ngs"
                            log_info "NodeGroups를 먼저 삭제해야 합니다."
                        fi
                        
                        # Add-ons 상태 재확인
                        remaining_addons=$(aws eks list-addons --cluster-name "$cluster" --query 'addons[]' --output text 2>/dev/null || echo "")
                        if [ -n "$remaining_addons" ]; then
                            log_warning "아직 삭제되지 않은 Add-ons: $remaining_addons"
                            log_info "Add-ons를 먼저 삭제해야 합니다."
                        fi
                    else
                        log_warning "클러스터 정보를 가져올 수 없습니다. 이미 삭제되었을 수 있습니다."
                    fi
                    
                    # 강제 삭제 시도 (--force 옵션)
                    log_info "강제 삭제 시도 중..."
                    if aws eks delete-cluster --name "$cluster" --force 2>/dev/null; then
                        log_success "EKS 클러스터 강제 삭제 명령 실행됨: $cluster"
                    else
                        log_warning "강제 삭제도 실패, 최종 재시도 중..."
                        
                        # 최종 재시도 (5초 대기 후)
                        sleep 5
                        if aws eks delete-cluster --name "$cluster" --force 2>/dev/null; then
                            log_success "EKS 클러스터 최종 삭제 명령 실행됨: $cluster"
                        else
                            log_error "EKS 클러스터 삭제 완전 실패: $cluster"
                            log_info "수동 삭제가 필요합니다:"
                            log_info "1. AWS 콘솔에서 클러스터 상태 확인"
                            log_info "2. NodeGroups와 Add-ons 수동 삭제"
                            log_info "3. 클러스터 수동 삭제"
                        fi
                    fi
                fi
                
                # 1-4. 클러스터 삭제 상태 확인 및 대기
                log_info "클러스터 삭제 상태 확인 중..."
                for i in {1..30}; do
                    cluster_status=$(aws eks describe-cluster --name "$cluster" --query 'cluster.status' --output text 2>/dev/null || echo "DELETED")
                    if [ "$cluster_status" = "DELETED" ] || [ "$cluster_status" = "FAILED" ]; then
                        log_success "EKS 클러스터 삭제 완료: $cluster"
                        break
                    fi
                    log_info "클러스터 삭제 진행 중... ($i/30) - 상태: $cluster_status"
                    sleep 10
                done
                
                # 1-5. 최종 삭제 확인
                final_status=$(aws eks describe-cluster --name "$cluster" --query 'cluster.status' --output text 2>/dev/null || echo "DELETED")
                if [ "$final_status" = "DELETED" ]; then
                    log_success "EKS 클러스터 완전 삭제 확인: $cluster"
                else
                    log_warning "EKS 클러스터 삭제 미완료: $cluster (상태: $final_status)"
                    log_info "수동 삭제 명령어: aws eks delete-cluster --name $cluster"
                fi
            fi
        done
            
            # 2단계: 남은 연관 리소스 수동 삭제 가이드
            log_info "2단계: 남은 EKS 연관 리소스 수동 삭제 가이드"
            
            # Load Balancer 확인 및 삭제 명령어 제공
            log_info "Load Balancer 확인 중..."
            lb_arns=($(aws elbv2 describe-load-balancers --query 'LoadBalancers[?contains(LoadBalancerName, `k8s`) || contains(LoadBalancerName, `eks`)].LoadBalancerArn' --output text 2>/dev/null))
            if [ ${#lb_arns[@]} -gt 0 ]; then
                log_warning "삭제가 필요한 Load Balancer:"
                for lb_arn in "${lb_arns[@]}"; do
                    lb_name=$(aws elbv2 describe-load-balancers --load-balancer-arns "$lb_arn" --query 'LoadBalancers[0].LoadBalancerName' --output text 2>/dev/null)
                    echo "  - Load Balancer: $lb_name ($lb_arn)"
                    echo "    삭제 명령어: aws elbv2 delete-load-balancer --load-balancer-arn $lb_arn"
                done
            else
                log_success "Load Balancer 없음"
            fi
            
            # Security Groups 확인 및 삭제 명령어 제공
            log_info "Security Groups 확인 중..."
            sg_ids=($(aws ec2 describe-security-groups --query 'SecurityGroups[?contains(GroupName, `eks`) || contains(GroupName, `k8s`)].GroupId' --output text 2>/dev/null))
            if [ ${#sg_ids[@]} -gt 0 ]; then
                log_warning "삭제가 필요한 Security Groups:"
                for sg_id in "${sg_ids[@]}"; do
                    sg_name=$(aws ec2 describe-security-groups --group-ids "$sg_id" --query 'SecurityGroups[0].GroupName' --output text 2>/dev/null)
                    echo "  - Security Group: $sg_name ($sg_id)"
                    echo "    삭제 명령어: aws ec2 delete-security-group --group-id $sg_id"
                done
            else
                log_success "Security Groups 없음"
            fi
            
            # CloudWatch Log Groups 확인 및 삭제 명령어 제공
            log_info "CloudWatch Log Groups 확인 중..."
            log_groups=($(aws logs describe-log-groups --query 'logGroups[?contains(logGroupName, `/aws/eks`)].logGroupName' --output text 2>/dev/null))
            if [ ${#log_groups[@]} -gt 0 ]; then
                log_warning "삭제가 필요한 CloudWatch Log Groups:"
                for log_group in "${log_groups[@]}"; do
                    echo "  - Log Group: $log_group"
                    echo "    삭제 명령어: aws logs delete-log-group --log-group-name $log_group"
                done
            else
                log_success "CloudWatch Log Groups 없음"
            fi
            
            # IAM Roles 확인 및 삭제 명령어 제공
            log_info "IAM Roles 확인 중..."
            # 사용자 생성 역할만 확인
            role_names=($(aws iam list-roles --query 'Roles[?contains(RoleName, `eksctl`) && !contains(RoleName, `AWSServiceRoleFor`)].RoleName' --output text 2>/dev/null))
            if [ ${#role_names[@]} -gt 0 ]; then
                log_warning "삭제가 필요한 IAM Roles:"
                for role_name in "${role_names[@]}"; do
                    echo "  - IAM Role: $role_name"
                    echo "    삭제 명령어:"
                    echo "      # 정책 분리:"
                    policy_arns=($(aws iam list-attached-role-policies --role-name "$role_name" --query 'AttachedPolicies[].PolicyArn' --output text 2>/dev/null))
                    for policy_arn in "${policy_arns[@]}"; do
                        echo "        aws iam detach-role-policy --role-name $role_name --policy-arn $policy_arn"
                    done
                    echo "      # 역할 삭제:"
                    echo "        aws iam delete-role --role-name $role_name"
                done
            else
                log_success "삭제 가능한 IAM Roles 없음"
            fi
            
            # AWS 관리형 IAM Roles 확인
            managed_roles=($(aws iam list-roles --query 'Roles[?contains(RoleName, `AWSServiceRoleFor`) && contains(RoleName, `EKS`)].RoleName' --output text 2>/dev/null))
            if [ ${#managed_roles[@]} -gt 0 ]; then
                log_info "AWS 관리형 IAM Roles (삭제 불가):"
                for managed_role in "${managed_roles[@]}"; do
                    echo "  - AWS 관리형 역할: $managed_role (삭제 불가)"
                done
            fi
            
            log_success "EKS 클러스터 및 연계 리소스 자동 삭제 완료"
        else
            log_info "삭제할 EKS 클러스터가 없습니다."
        fi
    else
        log_warning "AWS CLI가 설치되지 않거나 자격 증명이 설정되지 않음"
    fi
    echo ""
    
    # GKE 클러스터 및 연계 리소스 삭제
    log_info "GKE 클러스터 및 연계 리소스 삭제"
    if command -v gcloud &> /dev/null && gcloud auth list --filter=status:ACTIVE --format="value(account)" | head -n1 &> /dev/null; then
        gke_clusters=$(gcloud container clusters list --format="value(name,location)" 2>/dev/null || echo "")
        if [ -n "$gke_clusters" ]; then
            echo "삭제할 GKE 클러스터:"
            gcloud container clusters list --format="table(name,location,status)" 2>/dev/null || echo "  - 클러스터 정보를 가져올 수 없음"
            echo ""
            
            # 연계 리소스 확인
            log_info "GKE 연계 리소스 확인"
            echo "Load Balancer:"
            gcloud compute forwarding-rules list --filter="name~k8s OR name~gke" --format="table(name,region,IPAddress,target)" 2>/dev/null || echo "  - GKE 관련 Load Balancer 없음"
            
            echo "Firewall Rules:"
            gcloud compute firewall-rules list --filter="name~gke OR name~k8s" --format="table(name,direction,priority,sourceRanges.list():label=SRC_RANGES)" 2>/dev/null || echo "  - GKE 관련 Firewall Rule 없음"
            
            echo "Persistent Disks:"
            gcloud compute disks list --filter="name~gke OR name~k8s" --format="table(name,zone,sizeGb,status)" 2>/dev/null || echo "  - GKE 관련 Persistent Disk 없음"
            
            echo ""
            log_info "GKE 클러스터 및 연계 리소스 자동 삭제 시작"
            
            # 1단계: GKE 클러스터 먼저 삭제 (강제 삭제)
            log_info "1단계: GKE 클러스터 강제 삭제"
            echo "$gke_clusters" | while read name location; do
                log_info "GKE 클러스터 삭제 중: $name ($location)"
                gcloud container clusters delete "$name" --zone "$location" --quiet 2>/dev/null || log_warning "GKE 클러스터 삭제 실패: $name"
                
                # 클러스터 삭제 상태 확인 및 대기
                log_info "클러스터 삭제 상태 확인 중..."
                for i in {1..30}; do
                    cluster_status=$(gcloud container clusters describe "$name" --zone "$location" --format="value(status)" 2>/dev/null || echo "DELETED")
                    if [ "$cluster_status" = "DELETED" ] || [ "$cluster_status" = "FAILED" ]; then
                        log_success "GKE 클러스터 삭제 완료: $name"
                        break
                    fi
                    log_info "클러스터 삭제 진행 중... ($i/30) - 상태: $cluster_status"
                    sleep 10
                done
            done
            
            # 2단계: 남은 연관 리소스 수동 삭제 가이드
            log_info "2단계: 남은 GKE 연관 리소스 수동 삭제 가이드"
            
            # Load Balancer 확인 및 삭제 명령어 제공
            log_info "Load Balancer 확인 중..."
            lb_info=($(gcloud compute forwarding-rules list --filter="name~k8s OR name~gke" --format="value(name,region)" 2>/dev/null))
            if [ ${#lb_info[@]} -gt 0 ]; then
                log_warning "삭제가 필요한 Load Balancer:"
                for ((i=0; i<${#lb_info[@]}; i+=2)); do
                    lb_name="${lb_info[i]}"
                    region="${lb_info[i+1]}"
                    if [ -n "$lb_name" ] && [ -n "$region" ]; then
                        echo "  - Load Balancer: $lb_name ($region)"
                        echo "    삭제 명령어: gcloud compute forwarding-rules delete $lb_name --region $region --quiet"
                    fi
                done
            else
                log_success "Load Balancer 없음"
            fi
            
            # Persistent Disks 확인 및 삭제 명령어 제공
            log_info "Persistent Disks 확인 중..."
            disk_info=($(gcloud compute disks list --filter="name~gke OR name~k8s" --format="value(name,zone)" 2>/dev/null))
            if [ ${#disk_info[@]} -gt 0 ]; then
                log_warning "삭제가 필요한 Persistent Disks:"
                for ((i=0; i<${#disk_info[@]}; i+=2)); do
                    disk_name="${disk_info[i]}"
                    zone="${disk_info[i+1]}"
                    if [ -n "$disk_name" ] && [ -n "$zone" ]; then
                        echo "  - Persistent Disk: $disk_name ($zone)"
                        echo "    삭제 명령어: gcloud compute disks delete $disk_name --zone $zone --quiet"
                    fi
                done
            else
                log_success "Persistent Disks 없음"
            fi
            
            # Firewall Rules 확인 및 삭제 명령어 제공
            log_info "Firewall Rules 확인 중..."
            rule_names=($(gcloud compute firewall-rules list --filter="name~gke OR name~k8s" --format="value(name)" 2>/dev/null))
            if [ ${#rule_names[@]} -gt 0 ]; then
                log_warning "삭제가 필요한 Firewall Rules:"
                for rule_name in "${rule_names[@]}"; do
                    echo "  - Firewall Rule: $rule_name"
                    echo "    삭제 명령어: gcloud compute firewall-rules delete $rule_name --quiet"
                done
            else
                log_success "Firewall Rules 없음"
            fi
            
            # VPC 서브넷 확인 및 삭제 명령어 제공
            log_info "VPC 서브넷 확인 중..."
            subnet_info=($(gcloud compute networks subnets list --filter="name~gke OR name~k8s" --format="value(name,region)" 2>/dev/null))
            if [ ${#subnet_info[@]} -gt 0 ]; then
                log_warning "삭제가 필요한 VPC 서브넷:"
                for ((i=0; i<${#subnet_info[@]}; i+=2)); do
                    subnet_name="${subnet_info[i]}"
                    region="${subnet_info[i+1]}"
                    if [ -n "$subnet_name" ] && [ -n "$region" ]; then
                        echo "  - VPC 서브넷: $subnet_name ($region)"
                        echo "    삭제 명령어: gcloud compute networks subnets delete $subnet_name --region $region --quiet"
                    fi
                done
            else
                log_success "VPC 서브넷 없음"
            fi
            
            # Service Accounts 확인 및 삭제 명령어 제공
            log_info "Service Accounts 확인 중..."
            sa_emails=($(gcloud iam service-accounts list --filter="email~gke OR email~k8s" --format="value(email)" 2>/dev/null))
            if [ ${#sa_emails[@]} -gt 0 ]; then
                log_warning "삭제가 필요한 Service Accounts:"
                for sa_email in "${sa_emails[@]}"; do
                    echo "  - Service Account: $sa_email"
                    echo "    삭제 명령어: gcloud iam service-accounts delete $sa_email --quiet"
                done
            else
                log_success "Service Accounts 없음"
            fi
            
            log_success "GKE 클러스터 및 연계 리소스 자동 삭제 완료"
        else
            log_info "삭제할 GKE 클러스터가 없습니다."
        fi
    else
        log_warning "gcloud CLI가 설치되지 않거나 인증되지 않음"
    fi
    echo ""
    
    log_success "클러스터 및 연계 리소스 삭제 프로세스 완료"
}

# 정리 메뉴 함수
show_cleanup_menu() {
    while true; do
        echo ""
        log_header "실습 환경 정리 메뉴"
        echo "1. 현재 리소스 상태 확인"
        echo "2. 실습 환경 정리 실행"
        echo "3. 정리 후 남은 리소스 확인"
        echo "4. 전체 정리 프로세스 (상태 확인 → 정리 → 확인)"
        echo "5. 통합 삭제 (모든 리소스 완전 삭제)"
        echo "6. 클러스터 삭제 (EKS/GKE 클러스터 완전 삭제)"
        echo "7. EKS 클러스터 정리 (개선된 로직)"
        echo "8. 이전 메뉴로 돌아가기"
        echo ""
        read -p "선택하세요 (1-8): " cleanup_choice
        
        case $cleanup_choice in
            1)
                log_info "현재 리소스 상태 확인"
                show_current_resources
                ;;
            2)
                log_info "실습 환경 정리 실행"
                cleanup_day1
                ;;
            3)
                log_info "정리 후 남은 리소스 확인"
                show_remaining_resources
                ;;
            4)
                log_info "전체 정리 프로세스 실행"
                log_info "1단계: 현재 상태 확인"
                show_current_resources
                echo ""
                read -p "정리를 계속하시겠습니까? (y/N): " confirm
                if [[ $confirm =~ ^[Yy]$ ]]; then
                    log_info "2단계: 정리 실행"
                    cleanup_day1
                    echo ""
                    log_info "3단계: 정리 후 상태 확인"
                    show_remaining_resources
                    log_success "전체 정리 프로세스 완료!"
                else
                    log_info "정리가 취소되었습니다."
                fi
                ;;
            5)
                log_info "통합 삭제 실행"
                unified_cleanup
                ;;
            6)
                log_info "클러스터 삭제 실행"
                delete_clusters
                ;;
            7)
                log_info "EKS 클러스터 정리 (개선된 로직)"
                improved_eks_cleanup
                ;;
            8)
                return
                ;;
            *)
                log_error "잘못된 선택입니다. 1-8 중에서 선택하세요."
                ;;
        esac
        
        echo ""
        read -p "계속하려면 Enter를 누르세요..."
        # Enter 입력 시 현재 메뉴 유지 (종료하지 않음)
    done
}

# 통합 삭제 함수
unified_cleanup() {
    log_header "통합 삭제 실행"
    
    # 사용자 확인
    echo ""
    log_warning "이 작업은 Day1 실습에서 생성된 모든 리소스를 삭제합니다."
    read -p "계속하시겠습니까? (y/N): " confirm
    
    if [[ $confirm != [yY] ]]; then
        log_info "통합 삭제 작업이 취소되었습니다."
        return 0
    fi
    
    # 통합 삭제 스크립트 실행
    log_info "통합 삭제 스크립트 실행 중..."
    
    # 스크립트 경로 확인
    cleanup_script="../../samples/day1/unified-cleanup.sh"
    if [ -f "$cleanup_script" ]; then
        log_info "통합 삭제 스크립트 실행: $cleanup_script"
        bash "$cleanup_script"
        log_success "통합 삭제 완료!"
    else
        log_warning "통합 삭제 스크립트를 찾을 수 없습니다: $cleanup_script"
        log_info "기본 정리 함수를 실행합니다."
        cleanup_day1
    fi
}

# 정리 함수
cleanup_day1() {
    log_header "Day 1 실습 정리"
    
    # 정리 전 현재 상태 확인
    log_info "정리 전 현재 상태 확인"
    show_current_resources
    
    # Docker 리소스 정리
    log_info "Docker 리소스 정리"
    docker-compose -f day1-docker-advanced/docker-compose.yml down -v 2>/dev/null || true
    
    # 실습 관련 Docker 이미지 모두 삭제
    docker rmi myapp:optimized myapp:builder myapp:runtime 2>/dev/null || true
    docker rmi day1-docker-advanced-web:latest 2>/dev/null || true
    docker rmi $(docker images | grep -E "(day1|myapp)" | awk '{print $3}') 2>/dev/null || true
    
    # Docker 정리 확인
    log_info "Docker 리소스 정리 상태 확인 중..."
    sleep 2
    
    # Docker 이미지 확인
    if docker images | grep -E "(myapp:optimized|myapp:builder|myapp:runtime)" 2>/dev/null; then
        log_warning "일부 Docker 이미지가 아직 존재합니다. 수동으로 삭제하세요."
        echo "  docker rmi myapp:optimized myapp:builder myapp:runtime --force"
    else
        log_success "Docker 리소스 정리 완료 (이미지 삭제 확인됨)"
    fi
    
    # Docker 컨테이너 확인
    if docker ps -a | grep -E "(myapp|day1)" 2>/dev/null; then
        log_warning "일부 Docker 컨테이너가 아직 존재합니다. 수동으로 정리하세요."
        echo "  docker rm -f \$(docker ps -aq --filter name=myapp)"
    else
        log_success "Docker 컨테이너 정리 완료"
    fi
    
    # EKS 리소스 정리
    log_info "EKS 리소스 정리"
    if kubectl cluster-info &> /dev/null; then
        # 네임스페이스 삭제
        kubectl delete namespace day1-practice 2>/dev/null || true
        
        # 정리 확인
        log_info "EKS 리소스 정리 상태 확인 중..."
        sleep 3
        
        if kubectl get namespace day1-practice 2>/dev/null; then
            log_warning "EKS 네임스페이스가 아직 존재합니다. 수동으로 삭제하세요."
            echo "  kubectl delete namespace day1-practice --force --grace-period=0"
        else
            log_success "EKS 리소스 정리 완료 (네임스페이스 삭제 확인됨)"
        fi
    else
        log_warning "EKS 클러스터에 연결할 수 없어 리소스 정리를 건너뜁니다."
        log_info "수동으로 정리하려면:"
        echo "  kubectl delete namespace day1-practice"
    fi
    
    # GCP GKE 리소스 정리
    log_info "GCP GKE 리소스 정리"
    if command -v gcloud &> /dev/null && gcloud auth list --filter=status:ACTIVE --format="value(account)" | head -n1 &> /dev/null; then
        # GKE 클러스터 연결 확인
        if kubectl cluster-info &> /dev/null; then
            # 네임스페이스 삭제
            kubectl delete namespace day1-practice 2>/dev/null || true
            
            # 정리 확인
            log_info "GKE 리소스 정리 상태 확인 중..."
            sleep 3
            
            if kubectl get namespace day1-practice 2>/dev/null; then
                log_warning "GKE 네임스페이스가 아직 존재합니다. 수동으로 삭제하세요."
                echo "  kubectl delete namespace day1-practice --force --grace-period=0"
            else
                log_success "GKE 리소스 정리 완료 (네임스페이스 삭제 확인됨)"
            fi
        else
            log_warning "GKE 클러스터에 연결할 수 없어 리소스 정리를 건너뜁니다."
        fi
    else
        log_warning "GCP CLI가 설치되지 않았거나 인증되지 않아 GKE 리소스 정리를 건너뜁니다."
        log_info "GCP 인증 후 수동으로 정리하려면:"
        echo "  gcloud auth login"
        echo "  gcloud container clusters get-credentials CLUSTER_NAME --zone ZONE"
        echo "  kubectl delete namespace day1-practice"
    fi
    
    # 실습 디렉토리 정리 (스크립트 파일 제외)
    log_info "실습 디렉토리 정리"
    rm -rf day1-docker-advanced
    rm -rf day1-kubernetes-basics
    rm -rf day1-cloud-container-services
    rm -rf day1-monitoring-hub
    
    # day1-* 디렉토리만 삭제 (스크립트 파일은 보존)
    find . -maxdepth 1 -type d -name "day1-*" -exec rm -rf {} + 2>/dev/null || true
    
    # 디렉토리 정리 확인
    log_info "실습 디렉토리 정리 상태 확인 중..."
    sleep 1
    
    # 남은 디렉토리 확인 (스크립트 파일 제외)
    remaining_dirs=$(find . -maxdepth 1 -type d -name "day1-*" 2>/dev/null || echo "")
    if [ -n "$remaining_dirs" ]; then
        log_warning "일부 실습 디렉토리가 아직 존재합니다:"
        echo "$remaining_dirs" | while read dir; do
            echo "  - $dir"
        done
        echo "수동으로 정리하려면: rm -rf $remaining_dirs"
    else
        log_success "실습 디렉토리 정리 완료 (모든 디렉토리 삭제 확인됨)"
    fi
    
    # 정리 후 상태 확인
    log_info "정리 후 상태 확인"
    show_remaining_resources
    
    # 클라우드 리소스 정리 요약
    log_info "클라우드 리소스 정리 요약"
    echo "정리된 리소스:"
    echo "  - Docker 컨테이너 및 이미지"
    echo "  - EKS 클러스터 리소스 (day1-practice 네임스페이스)"
    echo "  - GKE 클러스터 리소스 (day1-practice 네임스페이스)"
    echo "  - 로컬 실습 디렉토리"
    echo ""
    echo "수동 정리가 필요한 경우:"
    echo "  - AWS EKS 클러스터 삭제: aws eks delete-cluster --name CLUSTER_NAME"
    echo "  - GCP GKE 클러스터 삭제: gcloud container clusters delete CLUSTER_NAME --zone ZONE"
    echo "  - 클라우드 로드밸런서 정리: 각 클라우드 콘솔에서 확인"
    
    log_success "Day 1 정리 완료"
}

# 메인 메뉴
show_menu() {
    echo ""
    log_header "Cloud Intermediate Day 1 실습 메뉴"
    echo "1. Docker 고급 실습"
    echo "2. Kubernetes 기초 실습"
    echo "3. 클라우드 컨테이너 서비스 실습"
    echo "4. 통합 모니터링 허브 구축"
    echo "5. 실습 테스트 및 검증"
    echo "6. 전체 Day 1 실습 실행"
    echo "7. K8s 클러스터 관리"
    echo "8. 정리"
    echo "9. 종료"
    echo ""
}

# 메인 함수
main() {
    log_header "Cloud Intermediate Day 1 실습 스크립트"
    log_info "Docker 고급 활용, Kubernetes 기초, 클라우드 컨테이너 서비스 실습"
    
    while true; do
        show_menu
        read -p "선택하세요 (1-9): " choice
        
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
                log_info "통합 모니터링 허브 구축 실행"
                monitoring_hub_practice
                ;;
            5)
                log_info "실습 테스트 및 검증 실행"
                practice_test_validation
                ;;
            6)
                log_info "전체 Day 1 실습 실행"
                docker_advanced_practice
                kubernetes_basics_practice
                cloud_container_services_practice
                monitoring_hub_practice
                log_success "전체 Day 1 실습 완료!"
                ;;
            7)
                unified_cluster_management
                ;;
            8)
                cleanup_day1
                ;;
            9)
                log_info "프로그램을 종료합니다"
                exit 0
                ;;
            *)
                log_error "잘못된 선택입니다. 1-9 중에서 선택하세요."
                ;;
        esac
        
        echo ""
        read -p "계속하려면 Enter를 누르세요..."
        # Enter 입력 시 현재 메뉴 유지 (종료하지 않음)
    done
}

# Interactive 모드 메뉴
show_interactive_menu() {
    echo ""
    log_header "Cloud Intermediate Day 1 실습 메뉴"
    echo "1. Docker 고급 실습"
    echo "2. 클라우드 컨테이너 서비스 기초 실습 (EKS/GKE)"
    echo "3. 통합 모니터링 실습"
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
                log_info "통합 모니터링 실습 실행"
                practice_test_validation
                ;;
            4)
                log_info "전체 Day 1 실습 실행"
                docker_advanced_practice
                kubernetes_basics_practice
                log_success "전체 Day 1 실습 완료!"
                ;;
            5)
                unified_cluster_management
                ;;
            6)
                log_info "실습 환경 정리 메뉴"
                show_cleanup_menu
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
        # Enter 입력 시 현재 메뉴 유지 (종료하지 않음)
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
            log_info "클라우드 컨테이너 서비스 기초 실습 실행"
            kubernetes_basics_practice
            ;;
        "monitoring-hub")
            log_info "통합 모니터링 허브 구축 실행"
            monitoring_hub_practice
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
            log_success "전체 Day 1 실습 완료!"
            ;;
        "cleanup")
            log_info "Day 1 실습 정리 실행"
            cleanup_day1
            ;;
        "status")
            log_info "현재 리소스 상태 확인 실행"
            show_current_resources
            ;;
        "remaining")
            log_info "정리 후 남은 리소스 확인 실행"
            show_remaining_resources
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
