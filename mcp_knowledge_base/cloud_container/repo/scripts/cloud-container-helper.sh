#!/bin/bash

# Cloud Container Helper - 통합 컨테이너 실습 도우미
# Kubernetes, Docker, CI/CD 파이프라인 관리

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

# 환경 체크 함수들
check_kubectl() {
    if command -v kubectl &> /dev/null; then
        echo -e "${GREEN}✅ kubectl 설치됨${NC}"
        kubectl version --client --short 2>/dev/null
    else
        echo -e "${RED}❌ kubectl 설치 필요${NC}"
        return 1
    fi
}

check_gcloud() {
    if command -v gcloud &> /dev/null; then
        echo -e "${GREEN}✅ GCP CLI 설치됨${NC}"
        gcloud version --format="value(Google Cloud SDK)" 2>/dev/null
    else
        echo -e "${RED}❌ GCP CLI 설치 필요${NC}"
        return 1
    fi
}

check_docker() {
    if command -v docker &> /dev/null; then
        echo -e "${GREEN}✅ Docker 설치됨${NC}"
        docker --version 2>/dev/null
    else
        echo -e "${RED}❌ Docker 설치 필요${NC}"
        return 1
    fi
}

check_helm() {
    if command -v helm &> /dev/null; then
        echo -e "${GREEN}✅ Helm 설치됨${NC}"
        helm version --short 2>/dev/null
    else
        echo -e "${RED}❌ Helm 설치 필요${NC}"
        return 1
    fi
}

check_git() {
    if command -v git &> /dev/null; then
        echo -e "${GREEN}✅ Git 설치됨${NC}"
        git --version 2>/dev/null
    else
        echo -e "${RED}❌ Git 설치 필요${NC}"
        return 1
    fi
}

# 환경 체크
environment_check() {
    log_header "Cloud Container 환경 체크"
    
    echo -e "${CYAN}=== 필수 도구 확인 ===${NC}"
    check_kubectl
    check_gcloud
    check_docker
    check_helm
    check_git
    
    echo -e "\n${CYAN}=== 클라우드 계정 설정 확인 ===${NC}"
    if gcloud auth list --filter=status:ACTIVE --format="value(account)" &> /dev/null; then
        echo -e "${GREEN}✅ GCP 계정 설정됨${NC}"
        gcloud auth list --filter=status:ACTIVE --format="value(account)"
    else
        echo -e "${RED}❌ GCP 계정 설정 필요${NC}"
    fi
    
    if gcloud config get-value project &> /dev/null; then
        echo -e "${GREEN}✅ GCP 프로젝트 설정됨${NC}"
        gcloud config get-value project
    else
        echo -e "${RED}❌ GCP 프로젝트 설정 필요${NC}"
    fi
    
    echo -e "\n${CYAN}=== Kubernetes 클러스터 연결 확인 ===${NC}"
    if kubectl cluster-info &> /dev/null; then
        echo -e "${GREEN}✅ Kubernetes 클러스터 연결됨${NC}"
        kubectl cluster-info --request-timeout=5s 2>/dev/null | head -1
    else
        echo -e "${YELLOW}⚠️ Kubernetes 클러스터 연결 필요${NC}"
    fi
}

# GKE 클러스터 생성
create_gke_cluster() {
    log_header "GKE 클러스터 생성"
    
    read -p "클러스터 이름을 입력하세요 (기본값: cloud-container-cluster): " CLUSTER_NAME
    CLUSTER_NAME=${CLUSTER_NAME:-cloud-container-cluster}
    
    read -p "리전을 입력하세요 (기본값: asia-northeast3): " REGION
    REGION=${REGION:-asia-northeast3}
    
    read -p "노드 수를 입력하세요 (기본값: 3): " NODE_COUNT
    NODE_COUNT=${NODE_COUNT:-3}
    
    read -p "머신 타입을 입력하세요 (기본값: e2-medium): " MACHINE_TYPE
    MACHINE_TYPE=${MACHINE_TYPE:-e2-medium}
    
    log_info "GKE 클러스터 생성 중..."
    log_info "클러스터명: $CLUSTER_NAME"
    log_info "리전: $REGION"
    log_info "노드 수: $NODE_COUNT"
    log_info "머신 타입: $MACHINE_TYPE"
    
    gcloud container clusters create "$CLUSTER_NAME" \
        --region="$REGION" \
        --num-nodes="$NODE_COUNT" \
        --machine-type="$MACHINE_TYPE" \
        --enable-autoscaling \
        --min-nodes=1 \
        --max-nodes=10 \
        --enable-autorepair \
        --enable-autoupgrade \
        --disk-size=20GB \
        --disk-type=pd-standard
    
    if [ $? -eq 0 ]; then
        log_success "GKE 클러스터 생성 완료"
        
        log_info "클러스터 인증 설정 중..."
        gcloud container clusters get-credentials "$CLUSTER_NAME" --region="$REGION"
        
        if [ $? -eq 0 ]; then
            log_success "클러스터 인증 설정 완료"
            kubectl cluster-info
        else
            log_error "클러스터 인증 설정 실패"
        fi
    else
        log_error "GKE 클러스터 생성 실패"
    fi
}

# Docker 이미지 빌드 및 푸시
build_and_push_image() {
    log_header "Docker 이미지 빌드 및 푸시"
    
    read -p "이미지 이름을 입력하세요 (기본값: cloud-container-app): " IMAGE_NAME
    IMAGE_NAME=${IMAGE_NAME:-cloud-container-app}
    
    read -p "태그를 입력하세요 (기본값: latest): " TAG
    TAG=${TAG:-latest}
    
    read -p "Dockerfile 경로를 입력하세요 (기본값: ./Dockerfile): " DOCKERFILE_PATH
    DOCKERFILE_PATH=${DOCKERFILE_PATH:-./Dockerfile}
    
    # GCP 프로젝트 ID 가져오기
    PROJECT_ID=$(gcloud config get-value project)
    if [ -z "$PROJECT_ID" ]; then
        log_error "GCP 프로젝트 ID를 가져올 수 없습니다"
        return 1
    fi
    
    FULL_IMAGE_NAME="gcr.io/$PROJECT_ID/$IMAGE_NAME:$TAG"
    
    log_info "Docker 이미지 빌드 중..."
    log_info "이미지명: $FULL_IMAGE_NAME"
    
    docker build -t "$FULL_IMAGE_NAME" -f "$DOCKERFILE_PATH" .
    
    if [ $? -eq 0 ]; then
        log_success "Docker 이미지 빌드 완료"
        
        log_info "GCR에 이미지 푸시 중..."
        docker push "$FULL_IMAGE_NAME"
        
        if [ $? -eq 0 ]; then
            log_success "이미지 푸시 완료: $FULL_IMAGE_NAME"
        else
            log_error "이미지 푸시 실패"
        fi
    else
        log_error "Docker 이미지 빌드 실패"
    fi
}

# Kubernetes 배포
deploy_to_kubernetes() {
    log_header "Kubernetes 배포"
    
    read -p "배포 이름을 입력하세요 (기본값: cloud-container-app): " DEPLOYMENT_NAME
    DEPLOYMENT_NAME=${DEPLOYMENT_NAME:-cloud-container-app}
    
    read -p "이미지 이름을 입력하세요 (gcr.io/PROJECT_ID/IMAGE_NAME:TAG): " IMAGE_NAME
    if [ -z "$IMAGE_NAME" ]; then
        PROJECT_ID=$(gcloud config get-value project)
        IMAGE_NAME="gcr.io/$PROJECT_ID/cloud-container-app:latest"
    fi
    
    read -p "포트를 입력하세요 (기본값: 8080): " PORT
    PORT=${PORT:-8080}
    
    read -p "레플리카 수를 입력하세요 (기본값: 3): " REPLICAS
    REPLICAS=${REPLICAS:-3}
    
    log_info "Kubernetes 배포 생성 중..."
    log_info "배포명: $DEPLOYMENT_NAME"
    log_info "이미지: $IMAGE_NAME"
    log_info "포트: $PORT"
    log_info "레플리카: $REPLICAS"
    
    # Deployment 생성
    kubectl create deployment "$DEPLOYMENT_NAME" \
        --image="$IMAGE_NAME" \
        --replicas="$REPLICAS" \
        --port="$PORT"
    
    if [ $? -eq 0 ]; then
        log_success "Deployment 생성 완료"
        
        # Service 생성
        kubectl expose deployment "$DEPLOYMENT_NAME" \
            --type=LoadBalancer \
            --port=80 \
            --target-port="$PORT"
        
        if [ $? -eq 0 ]; then
            log_success "Service 생성 완료"
            
            log_info "배포 상태 확인 중..."
            kubectl get deployments
            kubectl get services
            kubectl get pods
            
            log_info "외부 IP 확인 중... (몇 분 소요될 수 있습니다)"
            kubectl get service "$DEPLOYMENT_NAME" -w
        else
            log_error "Service 생성 실패"
        fi
    else
        log_error "Deployment 생성 실패"
    fi
}

# 모니터링 설정
setup_monitoring() {
    log_header "모니터링 설정"
    
    log_info "Prometheus 설치 중..."
    helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
    helm repo update
    
    helm install prometheus prometheus-community/kube-prometheus-stack \
        --namespace monitoring \
        --create-namespace \
        --set grafana.adminPassword=admin123
    
    if [ $? -eq 0 ]; then
        log_success "Prometheus 설치 완료"
        
        log_info "Grafana 접속 정보:"
        kubectl get secret --namespace monitoring prometheus-grafana -o jsonpath="{.data.admin-password}" | base64 --decode
        echo ""
        
        log_info "포트 포워딩 설정 중..."
        kubectl port-forward --namespace monitoring svc/prometheus-grafana 3000:80 &
        
        log_success "Grafana 접속: http://localhost:3000"
        log_info "사용자명: admin, 비밀번호: admin123"
    else
        log_error "Prometheus 설치 실패"
    fi
}

# 자동 스케일링 설정
setup_autoscaling() {
    log_header "자동 스케일링 설정"
    
    read -p "배포 이름을 입력하세요: " DEPLOYMENT_NAME
    if [ -z "$DEPLOYMENT_NAME" ]; then
        log_error "배포 이름이 필요합니다"
        return 1
    fi
    
    read -p "최소 레플리카 수를 입력하세요 (기본값: 1): " MIN_REPLICAS
    MIN_REPLICAS=${MIN_REPLICAS:-1}
    
    read -p "최대 레플리카 수를 입력하세요 (기본값: 10): " MAX_REPLICAS
    MAX_REPLICAS=${MAX_REPLICAS:-10}
    
    read -p "CPU 임계값을 입력하세요 (기본값: 50): " CPU_THRESHOLD
    CPU_THRESHOLD=${CPU_THRESHOLD:-50}
    
    log_info "HPA (Horizontal Pod Autoscaler) 생성 중..."
    
    kubectl autoscale deployment "$DEPLOYMENT_NAME" \
        --cpu-percent="$CPU_THRESHOLD" \
        --min="$MIN_REPLICAS" \
        --max="$MAX_REPLICAS"
    
    if [ $? -eq 0 ]; then
        log_success "HPA 생성 완료"
        
        log_info "HPA 상태 확인:"
        kubectl get hpa
    else
        log_error "HPA 생성 실패"
    fi
}

# 클러스터 정리
cleanup_cluster() {
    log_header "클러스터 정리"
    
    read -p "정리할 클러스터 이름을 입력하세요: " CLUSTER_NAME
    if [ -z "$CLUSTER_NAME" ]; then
        log_error "클러스터 이름이 필요합니다"
        return 1
    fi
    
    read -p "리전을 입력하세요 (기본값: asia-northeast3): " REGION
    REGION=${REGION:-asia-northeast3}
    
    log_warning "클러스터 '$CLUSTER_NAME'를 삭제하시겠습니까? (y/N)"
    read -p "확인: " CONFIRM
    
    if [[ "$CONFIRM" =~ ^[Yy]$ ]]; then
        log_info "클러스터 삭제 중..."
        gcloud container clusters delete "$CLUSTER_NAME" --region="$REGION" --quiet
        
        if [ $? -eq 0 ]; then
            log_success "클러스터 삭제 완료"
        else
            log_error "클러스터 삭제 실패"
        fi
    else
        log_info "클러스터 삭제 취소됨"
    fi
}

# 메인 메뉴
main_menu() {
    while true; do
        clear
        log_header "Cloud Container Helper"
        echo "1. 환경 체크"
        echo "2. GKE 클러스터 생성"
        echo "3. Docker 이미지 빌드 및 푸시"
        echo "4. Kubernetes 배포"
        echo "5. 모니터링 설정 (Prometheus/Grafana)"
        echo "6. 자동 스케일링 설정"
        echo "7. 클러스터 정리"
        echo "0. 종료"
        echo ""
        read -p "메뉴를 선택하세요: " choice
        
        case $choice in
            1) environment_check ;;
            2) create_gke_cluster ;;
            3) build_and_push_image ;;
            4) deploy_to_kubernetes ;;
            5) setup_monitoring ;;
            6) setup_autoscaling ;;
            7) cleanup_cluster ;;
            0) 
                log_info "Cloud Container Helper를 종료합니다."
                exit 0
                ;;
            *)
                log_error "잘못된 선택입니다. 다시 시도하세요."
                sleep 2
                ;;
        esac
        
        echo ""
        read -p "계속하려면 Enter를 누르세요..."
    done
}

# 스크립트 실행
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main_menu
fi
