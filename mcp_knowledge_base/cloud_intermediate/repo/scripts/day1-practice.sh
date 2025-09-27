#!/bin/bash

# Cloud Intermediate Day 1 실습 스크립트
# Docker 고급 활용, Kubernetes 기초, 클라우드 컨테이너 서비스

# 오류 처리 설정
set -e
set -u
set -o pipefail

# 리소스 관리 유틸리티 로드
source "$(dirname "$0")/resource-manager.sh"

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
    echo "  --action monitoring-hub     # 모니터링 허브 구축"
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

    # 6. 로컬 Kubernetes 환경 확인
    log_info "2. Kubernetes 환경 확인"
    if command -v minikube &> /dev/null; then
        log_info "minikube 시작"
        minikube start
        kubectl config use-context minikube
    elif docker info | grep -q "Kubernetes: enabled"; then
        log_info "Docker Desktop Kubernetes 사용"
    else
        log_warning "로컬 Kubernetes 환경이 없습니다. 클라우드 환경을 사용하세요."
    fi

    # 7. 리소스 생성
    log_info "3. Kubernetes 리소스 생성"
    kubectl apply -f pod-basic.yaml
    kubectl apply -f deployment-basic.yaml
    kubectl apply -f service-basic.yaml
    kubectl apply -f configmap-basic.yaml
    kubectl apply -f secret-basic.yaml
    
    # 8. 상태 확인
    log_info "4. 리소스 상태 확인"
    kubectl get pods
    kubectl get deployments
    kubectl get services
    kubectl get configmaps
    kubectl get secrets
    
    # 9. 스케일링 테스트
    log_info "5. Deployment 스케일링"
    kubectl scale deployment myapp-deployment --replicas=5
    sleep 10
    kubectl get pods -l app=myapp
    
    # 10. 롤링 업데이트 테스트
    log_info "6. 롤링 업데이트 테스트"
    kubectl set image deployment/myapp-deployment myapp=nginx:1.22
    kubectl rollout status deployment/myapp-deployment
    
    # 11. 롤백 테스트
    log_info "7. 롤백 테스트"
    kubectl rollout undo deployment/myapp-deployment
    kubectl rollout status deployment/myapp-deployment
    
    log_success "Kubernetes 기초 실습 완료"
    cd ..
}

# 클라우드 컨테이너 서비스 실습
cloud_container_services_practice() {
    log_header "클라우드 컨테이너 서비스 실습"
    
    local practice_dir="day1-cloud-container-services"
    mkdir -p "$practice_dir"
    cd "$practice_dir"
    
    # AWS EKS 실습
    log_info "1. AWS EKS 실습"
    if command -v aws &> /dev/null; then
        # EKS 클러스터 생성 (시뮬레이션)
        log_info "EKS 클러스터 생성 (시뮬레이션)"
        cat > eks-cluster-config.yaml << 'EOF'
apiVersion: v1
kind: ConfigMap
metadata:
  name: eks-cluster-info
data:
  cluster-name: "my-eks-cluster"
  region: "us-west-2"
  node-type: "t3.medium"
  node-count: "2"
  min-nodes: "1"
  max-nodes: "3"
EOF
        
        # EKS 배포 매니페스트 생성
        cat > eks-deployment.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp-eks
  labels:
    app: myapp
    platform: aws-eks
spec:
  replicas: 2
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
---
apiVersion: v1
kind: Service
metadata:
  name: myapp-eks-service
spec:
  selector:
    app: myapp
  ports:
  - port: 80
    targetPort: 80
  type: LoadBalancer
EOF
        
        log_info "EKS 배포 매니페스트 생성 완료"
    else
        log_warning "AWS CLI가 설치되지 않음"
    fi
    
    # GCP GKE 실습
    log_info "2. GCP GKE 실습"
    if command -v gcloud &> /dev/null; then
        # GKE 클러스터 생성 (시뮬레이션)
        log_info "GKE 클러스터 생성 (시뮬레이션)"
        cat > gke-cluster-config.yaml << 'EOF'
apiVersion: v1
kind: ConfigMap
metadata:
  name: gke-cluster-info
data:
  cluster-name: "my-gke-cluster"
  zone: "us-central1-a"
  node-count: "2"
  machine-type: "e2-medium"
  min-nodes: "1"
  max-nodes: "3"
EOF
        
        # GKE 배포 매니페스트 생성
        cat > gke-deployment.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp-gke
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
spec:
  selector:
    app: myapp
  ports:
  - port: 80
    targetPort: 80
  type: LoadBalancer
EOF
        
        log_info "GKE 배포 매니페스트 생성 완료"
    else
        log_warning "GCP CLI가 설치되지 않음"
    fi
    
    # 클라우드 서비스 비교
    log_info "3. 클라우드 서비스 비교"
    cat > cloud-comparison.md << 'EOF'
# AWS EKS vs GCP GKE 비교

## AWS EKS
- **관리형 Kubernetes 서비스**
- **장점**: AWS 생태계 통합, IAM 통합, CloudWatch 모니터링
- **단점**: 복잡한 설정, 높은 비용
- **사용 사례**: AWS 중심 환경, 엔터프라이즈급 애플리케이션

## GCP GKE
- **관리형 Kubernetes 서비스**
- **장점**: 간단한 설정, 자동 스케일링, 비용 효율성
- **단점**: GCP 생태계 의존성
- **사용 사례**: 클라우드 네이티브 애플리케이션, 마이크로서비스

## 선택 기준
1. **기존 인프라**: AWS 사용 중이면 EKS, GCP 사용 중이면 GKE
2. **비용**: GKE가 일반적으로 더 비용 효율적
3. **복잡성**: GKE가 설정이 더 간단
4. **통합**: 각 클라우드의 다른 서비스와의 통합도 고려
EOF
    
    log_success "클라우드 컨테이너 서비스 실습 완료"
    cd ..
}

# 정리 함수
cleanup_day1() {
    log_header "Day 1 실습 정리"
    
    # Docker 리소스 정리
    log_info "Docker 리소스 정리"
    docker-compose -f day1-docker-advanced/docker-compose.yml down -v 2>/dev/null || true
    docker rmi myapp:optimized myapp:builder myapp:runtime 2>/dev/null || true
    
    # Kubernetes 리소스 정리
    log_info "Kubernetes 리소스 정리"
    kubectl delete -f day1-kubernetes-basics/ 2>/dev/null || true
    
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
    echo "5. 정리"
    echo "6. 종료"
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
    echo "5. 실습 환경 정리"
    echo "6. 종료"
    echo ""
}

# Interactive 모드 실행
run_interactive_mode() {
    log_header "Cloud Intermediate Day 1 실습"
    while true; do
        show_interactive_menu
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
            run_parameter_mode "$2" "$3"
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
