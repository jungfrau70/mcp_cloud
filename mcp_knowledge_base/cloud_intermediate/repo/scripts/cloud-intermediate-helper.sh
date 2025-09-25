#!/bin/bash

# Cloud Intermediate 통합 Helper 스크립트
# 컨테이너 및 Kubernetes 기초, CI/CD 파이프라인 실습 통합 관리

# 오류 처리 설정
set -e
set -u
set -o pipefail

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# 로그 함수들
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_header() { echo -e "${PURPLE}=== $1 ===${NC}"; }

# 환경 체크 함수
check_environment() {
    log_header "환경 체크"
    
    local checks=0
    local total_checks=8
    
    # Docker 체크
    if command -v docker &> /dev/null; then
        log_success "Docker 설치됨: $(docker --version)"
        ((checks++))
    else
        log_error "Docker가 설치되지 않음"
    fi
    
    # kubectl 체크
    if command -v kubectl &> /dev/null; then
        log_success "kubectl 설치됨: $(kubectl version --client --short 2>/dev/null || kubectl version --client)"
        ((checks++))
    else
        log_error "kubectl이 설치되지 않음"
    fi
    
    # AWS CLI 체크
    if command -v aws &> /dev/null; then
        log_success "AWS CLI 설치됨: $(aws --version)"
        ((checks++))
    else
        log_error "AWS CLI가 설치되지 않음"
    fi
    
    # GCP CLI 체크
    if command -v gcloud &> /dev/null; then
        log_success "GCP CLI 설치됨: $(gcloud --version | head -1)"
        ((checks++))
    else
        log_error "GCP CLI가 설치되지 않음"
    fi
    
    echo ""
    local success_rate=$((checks * 100 / total_checks))
    
    if [ "$success_rate" -ge 80 ]; then
        log_success "환경 체크 통과! (${success_rate}%)"
        return 0
    else
        log_error "환경 체크 실패 (${success_rate}%)"
        return 1
    fi
}

# Docker 고급 실습 함수
docker_advanced_practice() {
    log_header "Docker 고급 실습"
    
    local practice_dir="docker-advanced-practice"
    mkdir -p "$practice_dir"
    cd "$practice_dir"
    
    # 최적화된 Dockerfile 생성
    log_info "최적화된 Dockerfile 생성"
    cat > Dockerfile << 'EOF'
FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production && npm cache clean --force
COPY . .

FROM node:18-alpine AS runtime
WORKDIR /app
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nextjs -u 1001
COPY --from=builder --chown=nextjs:nodejs /app/node_modules ./node_modules
COPY --from=builder --chown=nextjs:nodejs /app ./
USER nextjs
EXPOSE 3000
CMD ["npm", "start"]
EOF

    # package.json 생성
    cat > package.json << 'EOF'
{
  "name": "myapp",
  "version": "1.0.0",
  "description": "Sample Node.js application",
  "main": "index.js",
  "scripts": {
    "start": "node index.js"
  },
  "dependencies": {
    "express": "^4.18.2"
  }
}
EOF

    # 간단한 Node.js 앱 생성
    cat > index.js << 'EOF'
const express = require('express');
const app = express();
const port = process.env.PORT || 3000;

app.get('/', (req, res) => {
  res.json({ message: 'Hello from optimized Docker container!' });
});

app.get('/health', (req, res) => {
  res.json({ status: 'healthy', timestamp: new Date().toISOString() });
});

app.listen(port, () => {
  console.log(`App listening at http://localhost:${port}`);
});
EOF

    # 이미지 빌드
    log_info "Docker 이미지 빌드"
    docker build -t myapp:optimized .
    
    # 멀티스테이지 빌드 테스트
    log_info "멀티스테이지 빌드 테스트"
    docker build --target builder -t myapp:builder .
    docker build --target runtime -t myapp:runtime .
    
    # 이미지 크기 비교
    log_info "이미지 크기 비교"
    docker images | grep myapp
    
    log_success "Docker 고급 실습 완료"
    cd ..
}

# Kubernetes 기초 실습 함수
kubernetes_basics_practice() {
    log_header "Kubernetes 기초 실습"
    
    local practice_dir="kubernetes-basics-practice"
    mkdir -p "$practice_dir"
    cd "$practice_dir"
    
    # Pod 생성
    log_info "Pod 생성"
    cat > pod-basic.yaml << 'EOF'
apiVersion: v1
kind: Pod
metadata:
  name: myapp-pod
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

    # Deployment 생성
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
EOF

    # Service 생성
    cat > service-basic.yaml << 'EOF'
apiVersion: v1
kind: Service
metadata:
  name: myapp-service
spec:
  selector:
    app: myapp
  ports:
  - port: 80
    targetPort: 80
  type: ClusterIP
EOF

    # 리소스 생성
    log_info "Kubernetes 리소스 생성"
    kubectl apply -f pod-basic.yaml
    kubectl apply -f deployment-basic.yaml
    kubectl apply -f service-basic.yaml
    
    # 상태 확인
    log_info "리소스 상태 확인"
    kubectl get pods
    kubectl get deployments
    kubectl get services
    
    log_success "Kubernetes 기초 실습 완료"
    cd ..
}

# 정리 함수
cleanup_practice() {
    log_header "실습 정리"
    
    # Docker 리소스 정리
    log_info "Docker 리소스 정리"
    docker rmi myapp:optimized myapp:builder myapp:runtime 2>/dev/null || true
    
    # Kubernetes 리소스 정리
    log_info "Kubernetes 리소스 정리"
    kubectl delete -f kubernetes-basics-practice/ 2>/dev/null || true
    
    # 실습 디렉토리 정리
    log_info "실습 디렉토리 정리"
    rm -rf docker-advanced-practice
    rm -rf kubernetes-basics-practice
    
    log_success "정리 완료"
}

# 메인 메뉴
show_menu() {
    echo ""
    log_header "Cloud Intermediate 실습 메뉴"
    echo "1. 환경 체크"
    echo "2. Docker 고급 실습"
    echo "3. Kubernetes 기초 실습"
    echo "4. 정리"
    echo "5. 종료"
    echo ""
}

# 메인 함수
main() {
    log_header "Cloud Intermediate 통합 Helper 스크립트"
    log_info "컨테이너 및 Kubernetes 기초 실습을 시작합니다"
    
    while true; do
        show_menu
        read -p "선택하세요 (1-5): " choice
        
        case $choice in
            1)
                check_environment
                ;;
            2)
                docker_advanced_practice
                ;;
            3)
                kubernetes_basics_practice
                ;;
            4)
                cleanup_practice
                ;;
            5)
                log_info "프로그램을 종료합니다"
                exit 0
                ;;
            *)
                log_error "잘못된 선택입니다. 1-5 중에서 선택하세요."
                ;;
        esac
        
        echo ""
        read -p "계속하려면 Enter를 누르세요..."
    done
}

# 스크립트 실행
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi