#!/bin/bash

# Cloud Intermediate 통합 Helper 스크립트
# 컨테이너 및 Kubernetes 기초, CI/CD 파이프라인 실습 통합 관리
# Interactive 모드와 Parameter 모드 모두 지원

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

# 사용법 출력
usage() {
    echo "Cloud Intermediate 통합 Helper 스크립트"
    echo ""
    echo "사용법:"
    echo "  $0 [옵션]                    # Interactive 모드"
    echo "  $0 --action <액션> [파라미터] # Parameter 모드"
    echo ""
    echo "Interactive 모드 옵션:"
    echo "  --interactive, -i            # Interactive 모드 (기본값)"
    echo "  --help, -h                   # 도움말 출력"
    echo ""
    echo "Parameter 모드 액션:"
    echo "  --action check-env           # 환경 체크"
    echo "  --action check-docker        # Docker 상태 확인"
    echo "  --action check-k8s           # Kubernetes 상태 확인"
    echo "  --action check-aws           # AWS 컨테이너 서비스 상태"
    echo "  --action check-gcp           # GCP 컨테이너 서비스 상태"
    echo "  --action check-all           # 전체 상태 확인"
    echo "  --action day1-tools          # Day1 실습 도구"
    echo "  --action day2-tools          # Day2 실습 도구"
    echo ""
    echo "예시:"
    echo "  $0                           # Interactive 모드"
    echo "  $0 --action check-env        # 환경 체크만 실행"
    echo "  $0 --action check-docker    # Docker 상태만 확인"
    echo "  $0 --action day1-tools      # Day1 실습 도구 실행"
}

# Parameter 모드 실행
run_parameter_mode() {
    local action=$1
    shift
    
    case "$action" in
        "check-env")
            check_environment
            ;;
        "check-docker")
            check_docker_status
            ;;
        "check-k8s")
            check_kubernetes_status
            ;;
        "check-aws")
            check_aws_services
            ;;
        "check-gcp")
            check_gcp_services
            ;;
        "check-all")
            check_environment
            check_docker_status
            check_kubernetes_status
            check_aws_services
            check_gcp_services
            ;;
        "day1-tools")
            day1_practice_tools
            ;;
        "day2-tools")
            day2_practice_tools
            ;;
        *)
            log_error "알 수 없는 액션: $action"
            usage
            exit 1
            ;;
    esac
}

# 환경 체크 함수
check_environment() {
    log_header "환경 체크"
    
    local checks=0
    local total_checks=10
    local failed_checks=()
    
    echo ""
    log_info "=== 수동 체크 항목과 동일한 자동 체크 수행 ==="
    echo ""
    
    # 1. AWS CLI 설정 체크
    log_info "1. AWS CLI 설정: aws sts get-caller-identity 성공"
    if command -v aws &> /dev/null; then
        if aws sts get-caller-identity &> /dev/null; then
            local account_id=$(aws sts get-caller-identity --query 'Account' --output text 2>/dev/null)
            local user_arn=$(aws sts get-caller-identity --query 'Arn' --output text 2>/dev/null)
            log_success "✅ AWS CLI 설정: 되어 있음"
            log_info "   📋 AWS 계정 ID: $account_id"
            log_info "   👤 사용자 ARN: $user_arn"
            checks=$((checks + 1))
        else
            log_error "❌ AWS CLI 설정: 안되어 있음"
            log_info "   💡 해결 방법: aws configure 실행하여 Access Key, Secret Key 설정"
            failed_checks+=("AWS CLI 설정")
        fi
    else
        log_error "❌ AWS CLI 설정: 안되어 있음 (AWS CLI 미설치)"
        log_info "   💡 해결 방법: AWS CLI 설치 필요"
        failed_checks+=("AWS CLI 설치")
    fi
    
    # 2. GCP CLI 설정 체크
    log_info "2. GCP CLI 설정: gcloud auth list 성공"
    if command -v gcloud &> /dev/null; then
        if gcloud auth list --filter=status:ACTIVE --format="value(account)" &> /dev/null; then
            local gcp_account=$(gcloud auth list --filter=status:ACTIVE --format='value(account)' | head -1)
            log_success "✅ GCP CLI 설정: 되어 있음"
            log_info "   📋 GCP 계정: $gcp_account"
            checks=$((checks + 1))
        else
            log_error "❌ GCP CLI 설정: 안되어 있음"
            log_info "   💡 해결 방법: gcloud auth login 실행하여 Google 계정 로그인"
            failed_checks+=("GCP CLI 설정")
        fi
    else
        log_error "❌ GCP CLI 설정: 안되어 있음 (GCP CLI 미설치)"
        log_info "   💡 해결 방법: GCP CLI 설치 필요"
        failed_checks+=("GCP CLI 설치")
    fi
    
    # 3. Docker 실행 체크
    log_info "3. Docker 실행: docker --version 확인"
    if command -v docker &> /dev/null; then
        local docker_version=$(docker --version)
        log_success "✅ Docker 실행: 되어 있음"
        log_info "   📋 Docker 버전: $docker_version"
        checks=$((checks + 1))
    else
        log_error "❌ Docker 실행: 안되어 있음 (Docker 미설치)"
        log_info "   💡 해결 방법: Docker 설치 필요"
        failed_checks+=("Docker 설치")
    fi
    
    # 4. kubectl 설치 체크
    log_info "4. kubectl 설치: Kubernetes 클러스터 관리 준비"
    if command -v kubectl &> /dev/null; then
        local kubectl_version=$(kubectl version --client --short 2>/dev/null || kubectl version --client)
        log_success "✅ kubectl 설치: 되어 있음"
        log_info "   📋 kubectl 버전: $kubectl_version"
        checks=$((checks + 1))
    else
        log_error "❌ kubectl 설치: 안되어 있음 (kubectl 미설치)"
        log_info "   💡 해결 방법: kubectl 설치 필요"
        failed_checks+=("kubectl 설치")
    fi
    
    # 5. 권한 확인 체크
    log_info "5. 권한 확인: AWS/GCP 리소스 생성 권한"
    local permission_ok=true
    
    # AWS 권한 확인
    if command -v aws &> /dev/null; then
        if aws sts get-caller-identity &> /dev/null; then
            log_success "   ✅ AWS 권한: 되어 있음"
        else
            log_error "   ❌ AWS 권한: 안되어 있음"
            log_info "   💡 해결 방법: aws configure 실행"
            permission_ok=false
        fi
    else
        log_error "   ❌ AWS 권한: 안되어 있음 (AWS CLI 미설치)"
        log_info "   💡 해결 방법: AWS CLI 설치 필요"
        permission_ok=false
    fi
    
    # GCP 권한 확인
    if command -v gcloud &> /dev/null; then
        if gcloud auth list --filter=status:ACTIVE --format="value(account)" &> /dev/null; then
            log_success "   ✅ GCP 권한: 되어 있음"
        else
            log_error "   ❌ GCP 권한: 안되어 있음"
            log_info "   💡 해결 방법: gcloud auth login 실행"
            permission_ok=false
        fi
    else
        log_error "   ❌ GCP 권한: 안되어 있음 (GCP CLI 미설치)"
        log_info "   💡 해결 방법: GCP CLI 설치 필요"
        permission_ok=false
    fi
    
    if [ "$permission_ok" = true ]; then
        log_success "✅ 권한 확인: 되어 있음"
        checks=$((checks + 1))
    else
        log_error "❌ 권한 확인: 안되어 있음"
        failed_checks+=("권한 설정")
    fi
    
    # 6. 네트워크 확인 체크
    log_info "6. 네트워크 확인: 인터넷 연결 및 방화벽 설정"
    if ping -c 1 google.com &> /dev/null; then
        log_success "✅ 네트워크 확인: 되어 있음"
        log_info "   📋 인터넷 연결: 정상"
        checks=$((checks + 1))
    else
        log_error "❌ 네트워크 확인: 안되어 있음"
        log_info "   💡 해결 방법: 인터넷 연결 확인 및 방화벽 설정 검토"
        failed_checks+=("네트워크 연결")
    fi
    
    # 7. Git Repository 준비 체크
    log_info "7. Git Repository 준비: 실습 코드 저장소 생성 및 설정"
    if [ -d ".git" ] || git status &> /dev/null; then
        local git_remote=$(git remote get-url origin 2>/dev/null || echo "로컬 저장소")
        log_success "✅ Git Repository 준비: 되어 있음"
        log_info "   📋 저장소: $git_remote"
        checks=$((checks + 1))
    else
        log_warning "⚠️ Git Repository 준비: 안되어 있음"
        log_info "   💡 해결 방법: git init 실행하여 Git 저장소 초기화"
        failed_checks+=("Git Repository")
    fi
    
    # 추가 체크 항목들
    log_info "8. 추가 도구 확인"
    
    # Terraform 체크
    if command -v terraform &> /dev/null; then
        local terraform_version=$(terraform --version | head -1)
        log_success "   ✅ Terraform: 되어 있음 ($terraform_version)"
        checks=$((checks + 1))
    else
        log_warning "   ⚠️ Terraform: 안되어 있음 (설치되지 않음)"
        log_info "   💡 해결 방법: Terraform 설치 필요"
    fi
    
    # Node.js 체크
    if command -v node &> /dev/null; then
        local node_version=$(node --version)
        log_success "   ✅ Node.js: 되어 있음 ($node_version)"
        checks=$((checks + 1))
    else
        log_warning "   ⚠️ Node.js: 안되어 있음 (설치되지 않음)"
        log_info "   💡 해결 방법: Node.js 설치 필요"
    fi
    
    # Python 체크
    if command -v python3 &> /dev/null; then
        local python_version=$(python3 --version)
        log_success "   ✅ Python: 되어 있음 ($python_version)"
        checks=$((checks + 1))
    else
        log_warning "   ⚠️ Python: 안되어 있음 (설치되지 않음)"
        log_info "   💡 해결 방법: Python 설치 필요"
    fi
    
    # Helm 체크
    if command -v helm &> /dev/null; then
        local helm_version=$(helm version --short)
        log_success "   ✅ Helm: 되어 있음 ($helm_version)"
        checks=$((checks + 1))
    else
        log_warning "   ⚠️ Helm: 안되어 있음 (설치되지 않음)"
        log_info "   💡 해결 방법: Helm 설치 필요"
    fi
    
    echo ""
    log_header "=== 체크 결과 요약 ==="
    
    local success_rate=$((checks * 100 / total_checks))
    
    if [ "$success_rate" -ge 80 ]; then
        log_success "🎉 환경 체크 통과! (${success_rate}%)"
        log_info "✅ 성공한 체크: $checks/$total_checks"
        
        if [ ${#failed_checks[@]} -gt 0 ]; then
            log_warning "⚠️ 안되어 있는 항목: ${failed_checks[*]}"
            log_info "💡 안되어 있는 항목들을 수동으로 설정해주세요."
        fi
        
        echo ""
        log_success "🚀 실습을 시작할 준비가 되었습니다!"
        
        return 0
    else
        log_error "❌ 환경 체크 실패 (${success_rate}%)"
        log_info "✅ 되어 있는 체크: $checks/$total_checks"
        log_error "❌ 안되어 있는 체크: ${failed_checks[*]}"
        log_info "💡 안되어 있는 항목들을 설치하고 설정해주세요."
        
        echo ""
        log_warning "🔧 실습을 시작하기 전에 안되어 있는 항목들을 먼저 설정해주세요."
        
        return 1
    fi
}

# Docker 상태 확인
check_docker_status() {
    log_header "Docker 상태 확인"
    
    # Docker 버전 확인
    if command -v docker &> /dev/null; then
        local docker_version=$(docker --version)
        log_success "✅ Docker 설치됨: $docker_version"
    else
        log_error "❌ Docker가 설치되지 않았습니다."
        return 1
    fi
    
    # Docker 서비스 상태 확인
    if docker info &> /dev/null; then
        log_success "✅ Docker 서비스 실행 중"
    else
        log_error "❌ Docker 서비스가 실행되지 않았습니다."
        return 1
    fi
    
    # Docker 컨테이너 상태 확인
    log_info "Docker 컨테이너 상태:"
    docker ps -a
    
    # Docker 이미지 상태 확인
    log_info "Docker 이미지 상태:"
    docker images
    
    log_success "Docker 상태 확인 완료"
}

# Kubernetes 상태 확인
check_kubernetes_status() {
    log_header "Kubernetes 상태 확인"
    
    # kubectl 버전 확인
    if command -v kubectl &> /dev/null; then
        local kubectl_version=$(kubectl version --client --short 2>/dev/null)
        log_success "✅ kubectl 설치됨: $kubectl_version"
    else
        log_error "❌ kubectl이 설치되지 않았습니다."
        return 1
    fi
    
    # Kubernetes 클러스터 연결 확인
    if kubectl cluster-info &> /dev/null; then
        log_success "✅ Kubernetes 클러스터 연결됨"
        kubectl cluster-info
    else
        log_warning "⚠️ Kubernetes 클러스터에 연결되지 않았습니다."
        log_info "💡 해결 방법: kubectl config를 설정하거나 클러스터를 생성하세요."
    fi
    
    # Kubernetes 리소스 상태 확인
    if kubectl get nodes &> /dev/null; then
        log_info "Kubernetes 노드 상태:"
        kubectl get nodes
    fi
    
    log_success "Kubernetes 상태 확인 완료"
}

# AWS 컨테이너 서비스 상태 확인
check_aws_services() {
    log_header "AWS 컨테이너 서비스 상태 확인"
    
    # AWS CLI 확인
    if command -v aws &> /dev/null; then
        log_success "✅ AWS CLI 설치됨"
    else
        log_error "❌ AWS CLI가 설치되지 않았습니다."
        return 1
    fi
    
    # AWS 자격 증명 확인
    if aws sts get-caller-identity &> /dev/null; then
        log_success "✅ AWS 자격 증명 설정됨"
    else
        log_error "❌ AWS 자격 증명이 설정되지 않았습니다."
        return 1
    fi
    
    # ECS 클러스터 확인
    log_info "ECS 클러스터 상태:"
    aws ecs list-clusters --query 'clusterArns[]' --output table 2>/dev/null || log_warning "ECS 클러스터가 없습니다."
    
    # EKS 클러스터 확인
    log_info "EKS 클러스터 상태:"
    aws eks list-clusters --query 'clusters[]' --output table 2>/dev/null || log_warning "EKS 클러스터가 없습니다."
    
    log_success "AWS 컨테이너 서비스 상태 확인 완료"
}

# GCP 컨테이너 서비스 상태 확인
check_gcp_services() {
    log_header "GCP 컨테이너 서비스 상태 확인"
    
    # GCP CLI 확인
    if command -v gcloud &> /dev/null; then
        log_success "✅ GCP CLI 설치됨"
    else
        log_error "❌ GCP CLI가 설치되지 않았습니다."
        return 1
    fi
    
    # GCP 자격 증명 확인
    if gcloud auth list --filter=status:ACTIVE --format="value(account)" | head -n1 &> /dev/null; then
        log_success "✅ GCP 자격 증명 설정됨"
    else
        log_error "❌ GCP 자격 증명이 설정되지 않았습니다."
        return 1
    fi
    
    # GKE 클러스터 확인
    log_info "GKE 클러스터 상태:"
    gcloud container clusters list --format="table(name,location,status)" 2>/dev/null || log_warning "GKE 클러스터가 없습니다."
    
    log_success "GCP 컨테이너 서비스 상태 확인 완료"
}

# Day1 실습 도구
day1_practice_tools() {
    log_header "Day1 실습 도구"
    log_info "Docker 고급 실습을 시작합니다."
    docker_advanced_practice
}

# Day2 실습 도구
day2_practice_tools() {
    log_header "Day2 실습 도구"
    log_info "Kubernetes 기초 실습을 시작합니다."
    kubernetes_basics_practice
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

# Interactive 모드 메인 함수
run_interactive_mode() {
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

# 메인 함수
main() {
    # 인수 처리
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
            run_parameter_mode "$2"
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