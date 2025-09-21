#!/bin/bash

# Kubernetes 클러스터 자동 생성 스크립트
# Cloud Master Day2용 - Kubernetes & 고급 CI/CD

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# 로그 함수
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# 설정 변수
PROJECT_NAME="cloud-master-k8s"
CLUSTER_NAME="cloud-master-cluster"
REGION="asia-northeast3"
ZONE="asia-northeast3-a"
NODE_COUNT=3
MACHINE_TYPE="e2-medium"
NODE_POOL_NAME="default-pool"

# 체크포인트 파일
CHECKPOINT_FILE="k8s-cluster-checkpoint.json"

# 체크포인트 로드
load_checkpoint() {
    if [ -f "$CHECKPOINT_FILE" ]; then
        log_warning "이전 체크포인트 파일이 발견되었습니다."
        log_info "체크포인트 파일 삭제 중..."
        rm -f "$CHECKPOINT_FILE"
        log_success "체크포인트 파일 삭제 완료"
    fi
}

# 체크포인트 저장
save_checkpoint() {
    log_info "체크포인트 저장 중..."
    cat > "$CHECKPOINT_FILE" << EOF
CLUSTER_CREATED=$CLUSTER_CREATED
NODE_POOL_CREATED=$NODE_POOL_CREATED
CLUSTER_CONNECTED=$CLUSTER_CONNECTED
EOF
}

# 환경 체크
check_environment() {
    log_info "환경 체크 중..."
    
    # gcloud CLI 체크
    if ! command -v gcloud &> /dev/null; then
        log_error "gcloud CLI가 설치되지 않았습니다."
        exit 1
    fi
    
    # kubectl 체크
    if ! command -v kubectl &> /dev/null; then
        log_warning "kubectl이 설치되지 않았습니다. 설치 중..."
        gcloud components install kubectl
    fi
    
    # gke-gcloud-auth-plugin 체크 및 설치
    log_info "gke-gcloud-auth-plugin 설치 확인 중..."
    if ! command -v gke-gcloud-auth-plugin &> /dev/null; then
        log_warning "gke-gcloud-auth-plugin이 설치되지 않았습니다. 설치 시도 중..."
        
        # Windows 환경에서의 설치 시도
        if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" || "$OSTYPE" == "win32" ]]; then
            log_info "Windows 환경에서 gke-gcloud-auth-plugin 설치 중..."
            
            # gke-gcloud-auth-plugin 다운로드 및 설치
            curl -LO "https://storage.googleapis.com/gke-release/gke-gcloud-auth-plugin/v0.5.3/windows/amd64/gke-gcloud-auth-plugin.exe"
            if [ -f "gke-gcloud-auth-plugin.exe" ]; then
                mkdir -p "$HOME/.local/bin"
                mv gke-gcloud-auth-plugin.exe "$HOME/.local/bin/"
                chmod +x "$HOME/.local/bin/gke-gcloud-auth-plugin.exe"
                export PATH="$HOME/.local/bin:$PATH"
                log_success "gke-gcloud-auth-plugin 설치 완료"
            else
                log_warning "gke-gcloud-auth-plugin 다운로드에 실패했습니다."
            fi
        else
            # Linux/macOS/WSL 환경에서의 설치
            log_info "Linux/macOS/WSL 환경에서 gke-gcloud-auth-plugin 설치 중..."
            
            # WSL 환경 감지
            if grep -q Microsoft /proc/version 2>/dev/null; then
                log_info "WSL 환경 감지됨. 수동 설치 스크립트 실행 중..."
                if [ -f "./fix-gke-auth.sh" ]; then
                    chmod +x ./fix-gke-auth.sh
                    if ./fix-gke-auth.sh; then
                        log_success "WSL 환경에서 gke-gcloud-auth-plugin 설치 완료"
                    else
                        log_warning "수동 설치 스크립트 실패. gcloud components 설치 시도 중..."
                        gcloud components install gke-gcloud-auth-plugin --quiet
                    fi
                else
                    log_warning "수동 설치 스크립트를 찾을 수 없습니다. gcloud components 설치 시도 중..."
                    gcloud components install gke-gcloud-auth-plugin --quiet
                fi
            else
                # 일반 Linux/macOS 환경
                gcloud components install gke-gcloud-auth-plugin --quiet
            fi
        fi
        
        # 설치 확인
        if command -v gke-gcloud-auth-plugin &> /dev/null; then
            log_success "gke-gcloud-auth-plugin 설치 완료"
        else
            log_warning "gke-gcloud-auth-plugin 설치에 실패했습니다. 수동 설치가 필요할 수 있습니다."
        fi
    else
        log_success "gke-gcloud-auth-plugin이 이미 설치되어 있습니다."
    fi
    
    # 인증 체크
    if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" | grep -q .; then
        log_error "GCP 인증이 필요합니다. 'gcloud auth login'을 실행하세요."
        exit 1
    fi
    
    # 프로젝트 설정 체크
    if ! gcloud config get-value project &> /dev/null; then
        log_error "GCP 프로젝트가 설정되지 않았습니다."
        exit 1
    fi
    
    # 필요한 API 활성화
    enable_required_apis
    
    log_success "환경 체크 완료"
}

# 필요한 API 활성화
enable_required_apis() {
    log_info "필요한 GCP API 활성화 중..."
    
    # 필요한 API 목록
    local apis=(
        "container.googleapis.com"
        "compute.googleapis.com"
        "logging.googleapis.com"
        "monitoring.googleapis.com"
        "cloudresourcemanager.googleapis.com"
    )
    
    for api in "${apis[@]}"; do
        log_info "API 활성화 중: $api"
        gcloud services enable "$api" --quiet
        
        if [ $? -eq 0 ]; then
            log_success "✅ $api 활성화 완료"
        else
            log_warning "⚠️ $api 활성화 실패 (이미 활성화되었을 수 있음)"
        fi
    done
    
    # API 활성화 완료 대기
    log_info "API 활성화 완료 대기 중... (30초)"
    sleep 30
    
    log_success "필요한 API 활성화 완료"
}

# 클러스터 생성
create_cluster() {
    if [ "$CLUSTER_CREATED" = "true" ]; then
        log_info "클러스터가 이미 생성되어 있습니다."
        return 0
    fi
    
    log_info "Kubernetes 클러스터 생성 중..."
    
    # GKE 클러스터 생성 (containerd 런타임 사용)
    gcloud container clusters create "$CLUSTER_NAME" \
        --zone="$ZONE" \
        --num-nodes="$NODE_COUNT" \
        --machine-type="$MACHINE_TYPE" \
        --enable-autoscaling \
        --min-nodes=1 \
        --max-nodes=10 \
        --enable-autorepair \
        --enable-autoupgrade \
        --disk-size=20GB \
        --disk-type=pd-standard \
        --image-type=COS_CONTAINERD \
        --enable-ip-alias \
        --network=default \
        --subnetwork=default \
        --enable-network-policy \
        --logging=SYSTEM,WORKLOAD \
        --monitoring=SYSTEM \
        --addons=HttpLoadBalancing,HorizontalPodAutoscaling,NetworkPolicy \
        --labels=environment=development,project=cloud-master \
        --tags=cloud-master-k8s \
        --quiet
    
    if [ $? -eq 0 ]; then
        CLUSTER_CREATED="true"
        log_success "클러스터 생성 완료: $CLUSTER_NAME"
    else
        log_error "클러스터 생성 실패"
        exit 1
    fi
}

# 클러스터 연결
connect_cluster() {
    if [ "$CLUSTER_CONNECTED" = "true" ]; then
        log_info "클러스터가 이미 연결되어 있습니다."
        return 0
    fi
    
    log_info "클러스터 연결 중..."
    
    # 클러스터 자격 증명 가져오기
    gcloud container clusters get-credentials "$CLUSTER_NAME" --zone="$ZONE"
    
    if [ $? -eq 0 ]; then
        CLUSTER_CONNECTED="true"
        log_success "클러스터 연결 완료"
        
        # 클러스터 정보 출력
        log_info "클러스터 정보:"
        kubectl cluster-info
        kubectl get nodes
    else
        log_error "클러스터 연결 실패"
        exit 1
    fi
}

# 네임스페이스 생성
create_namespaces() {
    log_info "네임스페이스 생성 중..."
    
    # 기본 네임스페이스들 생성
    kubectl create namespace development --dry-run=client -o yaml | kubectl apply -f -
    kubectl create namespace staging --dry-run=client -o yaml | kubectl apply -f -
    kubectl create namespace production --dry-run=client -o yaml | kubectl apply -f -
    kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -
    
    log_success "네임스페이스 생성 완료"
}

# 기본 리소스 생성
create_basic_resources() {
    log_info "기본 리소스 생성 중..."
    
    # ConfigMap 생성
    kubectl create configmap app-config \
        --from-literal=database_url="postgresql://localhost:5432/myapp" \
        --from-literal=redis_url="redis://localhost:6379" \
        --namespace=development
    
    # Secret 생성
    kubectl create secret generic app-secrets \
        --from-literal=api-key="your-api-key-here" \
        --from-literal=db-password="your-db-password-here" \
        --namespace=development
    
    # ServiceAccount 생성
    kubectl create serviceaccount app-service-account --namespace=development
    
    # ClusterRole 및 ClusterRoleBinding 생성
    kubectl create clusterrole app-cluster-role \
        --verb=get,list,watch \
        --resource=pods,services,configmaps,secrets
    
    kubectl create clusterrolebinding app-cluster-role-binding \
        --clusterrole=app-cluster-role \
        --serviceaccount=development:app-service-account
    
    log_success "기본 리소스 생성 완료"
}

# 모니터링 설정
setup_monitoring() {
    log_info "모니터링 설정 중..."
    
    # Prometheus 네임스페이스 생성
    kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -
    
    # Prometheus ConfigMap 생성
    cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: prometheus-config
  namespace: monitoring
data:
  prometheus.yml: |
    global:
      scrape_interval: 15s
    scrape_configs:
      - job_name: 'prometheus'
        static_configs:
          - targets: ['localhost:9090']
      - job_name: 'kubernetes-pods'
        kubernetes_sd_configs:
          - role: pod
EOF
    
    log_success "모니터링 설정 완료"
}

# 클러스터 상태 확인
check_cluster_status() {
    log_info "클러스터 상태 확인 중..."
    
    # 노드 상태 확인
    log_info "노드 상태:"
    kubectl get nodes -o wide
    
    # 시스템 Pod 상태 확인
    log_info "시스템 Pod 상태:"
    kubectl get pods -n kube-system
    
    # 네임스페이스 확인
    log_info "네임스페이스:"
    kubectl get namespaces
    
    # 리소스 사용량 확인
    log_info "리소스 사용량:"
    kubectl top nodes 2>/dev/null || log_warning "메트릭 서버가 설치되지 않았습니다."
}

# 정리 함수
cleanup() {
    log_info "정리 중..."
    
    # 체크포인트 파일 삭제
    rm -f "$CHECKPOINT_FILE"
    
    log_success "정리 완료"
}

# 메인 함수
main() {
    log_info "=== Cloud Master Day2 - Kubernetes 클러스터 생성 시작 ==="
    
    # 체크포인트 로드
    load_checkpoint
    
    # 환경 체크
    check_environment
    
    # 클러스터 생성
    create_cluster
    save_checkpoint
    
    # 클러스터 연결
    connect_cluster
    save_checkpoint
    
    # 네임스페이스 생성
    create_namespaces
    
    # 기본 리소스 생성
    create_basic_resources
    
    # 모니터링 설정
    setup_monitoring
    
    # 클러스터 상태 확인
    check_cluster_status
    
    log_success "=== Kubernetes 클러스터 생성 완료 ==="
    log_info "클러스터 이름: $CLUSTER_NAME"
    log_info "리전: $REGION"
    log_info "존: $ZONE"
    log_info "노드 수: $NODE_COUNT"
    log_info "머신 타입: $MACHINE_TYPE"
    
    log_info "다음 단계:"
    log_info "1. kubectl get nodes - 클러스터 노드 확인"
    log_info "2. kubectl get namespaces - 네임스페이스 확인"
    log_info "3. kubectl create deployment nginx --image=nginx - 테스트 배포"
}

# 스크립트 실행
if [ "${BASH_SOURCE[0]}" == "${0}" ]; then
    main "$@"
fi
