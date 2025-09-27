#!/bin/bash

# GCP GKE 클러스터 구성 Helper 스크립트
# Cloud Intermediate 과정용 GKE 클러스터 자동화 도구

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

# 기본 설정
CLUSTER_NAME="cloud-intermediate-gke"
PROJECT_ID=""
ZONE="asia-northeast3-a"
REGION="asia-northeast3"
MACHINE_TYPE="e2-medium"
NODE_COUNT=2
MIN_NODES=1
MAX_NODES=4
VERSION="1.28"
DISK_SIZE="20"
DISK_TYPE="pd-standard"

# 환경 변수 로드
if [ -f "gcp-environment.env" ]; then
    source gcp-environment.env
    log_info "GCP 환경 변수 로드 완료"
fi

# GCP CLI 설정 확인
check_gcp_cli() {
    log_info "GCP CLI 설정 확인 중..."
    
    if ! command -v gcloud &> /dev/null; then
        log_error "GCP CLI가 설치되지 않았습니다."
        return 1
    fi
    
    if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" | head -n1 &> /dev/null; then
        log_error "GCP 자격 증명이 설정되지 않았습니다."
        return 1
    fi
    
    if [ -z "$PROJECT_ID" ]; then
        PROJECT_ID=$(gcloud config get-value project)
        if [ -z "$PROJECT_ID" ]; then
            log_error "GCP 프로젝트 ID가 설정되지 않았습니다."
            return 1
        fi
    fi
    
    log_success "GCP CLI 설정 확인 완료 (프로젝트: $PROJECT_ID)"
    return 0
}

# GKE 클러스터 생성
create_gke_cluster() {
    log_info "GKE 클러스터 생성 시작: $CLUSTER_NAME"
    
    # 클러스터 존재 여부 확인
    if gcloud container clusters describe $CLUSTER_NAME --zone $ZONE --project $PROJECT_ID &> /dev/null; then
        log_warning "클러스터 $CLUSTER_NAME이 이미 존재합니다."
        read -p "기존 클러스터를 삭제하고 새로 생성하시겠습니까? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            delete_gke_cluster
        else
            log_info "기존 클러스터를 사용합니다."
            return 0
        fi
    fi
    
    # GKE 클러스터 생성
    gcloud container clusters create $CLUSTER_NAME \
        --zone $ZONE \
        --project $PROJECT_ID \
        --machine-type $MACHINE_TYPE \
        --num-nodes $NODE_COUNT \
        --min-nodes $MIN_NODES \
        --max-nodes $MAX_NODES \
        --disk-size $DISK_SIZE \
        --disk-type $DISK_TYPE \
        --cluster-version $VERSION \
        --enable-autoscaling \
        --enable-autorepair \
        --enable-autoupgrade \
        --enable-ip-alias \
        --enable-network-policy \
        --enable-stackdriver-kubernetes \
        --addons HorizontalPodAutoscaling,HttpLoadBalancing \
        --tags "environment=learning,project=cloudintermediate"
    
    if [ $? -eq 0 ]; then
        log_success "GKE 클러스터 생성 완료: $CLUSTER_NAME"
        
        # kubectl 설정
        gcloud container clusters get-credentials $CLUSTER_NAME --zone $ZONE --project $PROJECT_ID
        
        # 클러스터 정보 출력
        log_info "클러스터 정보:"
        kubectl cluster-info
        kubectl get nodes
        
        return 0
    else
        log_error "GKE 클러스터 생성 실패"
        return 1
    fi
}

# GKE 클러스터 삭제
delete_gke_cluster() {
    log_warning "GKE 클러스터 삭제 시작: $CLUSTER_NAME"
    
    read -p "정말로 클러스터를 삭제하시겠습니까? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_info "클러스터 삭제를 취소했습니다."
        return 0
    fi
    
    gcloud container clusters delete $CLUSTER_NAME \
        --zone $ZONE \
        --project $PROJECT_ID \
        --quiet
    
    if [ $? -eq 0 ]; then
        log_success "GKE 클러스터 삭제 완료: $CLUSTER_NAME"
    else
        log_error "GKE 클러스터 삭제 실패"
        return 1
    fi
}

# GKE 클러스터 상태 확인
check_gke_cluster() {
    log_info "GKE 클러스터 상태 확인: $CLUSTER_NAME"
    
    if gcloud container clusters describe $CLUSTER_NAME --zone $ZONE --project $PROJECT_ID &> /dev/null; then
        log_success "클러스터가 실행 중입니다."
        
        # 클러스터 상세 정보
        gcloud container clusters describe $CLUSTER_NAME --zone $ZONE --project $PROJECT_ID
        
        # 노드 풀 정보
        gcloud container node-pools list --cluster $CLUSTER_NAME --zone $ZONE --project $PROJECT_ID
        
        # kubectl 설정 확인
        if kubectl cluster-info &> /dev/null; then
            log_success "kubectl 설정 완료"
            kubectl get nodes
        else
            log_warning "kubectl 설정이 필요합니다."
            gcloud container clusters get-credentials $CLUSTER_NAME --zone $ZONE --project $PROJECT_ID
        fi
    else
        log_error "클러스터가 존재하지 않거나 접근할 수 없습니다."
        return 1
    fi
}

# GKE 클러스터 스케일링
scale_gke_cluster() {
    local desired_count=$1
    
    if [ -z "$desired_count" ]; then
        log_error "스케일링할 노드 수를 지정해주세요."
        return 1
    fi
    
    log_info "GKE 클러스터 스케일링: $desired_count 노드"
    
    gcloud container clusters resize $CLUSTER_NAME \
        --zone $ZONE \
        --project $PROJECT_ID \
        --num-nodes $desired_count \
        --quiet
    
    if [ $? -eq 0 ]; then
        log_success "클러스터 스케일링 완료: $desired_count 노드"
    else
        log_error "클러스터 스케일링 실패"
        return 1
    fi
}

# GKE 클러스터 업그레이드
upgrade_gke_cluster() {
    local target_version=$1
    
    if [ -z "$target_version" ]; then
        log_error "업그레이드할 버전을 지정해주세요."
        return 1
    fi
    
    log_info "GKE 클러스터 업그레이드: $target_version"
    
    gcloud container clusters upgrade $CLUSTER_NAME \
        --zone $ZONE \
        --project $PROJECT_ID \
        --cluster-version $target_version \
        --quiet
    
    if [ $? -eq 0 ]; then
        log_success "클러스터 업그레이드 완료: $target_version"
    else
        log_error "클러스터 업그레이드 실패"
        return 1
    fi
}

# GKE 클러스터 모니터링 설정
setup_gke_monitoring() {
    log_info "GKE 클러스터 모니터링 설정 시작"
    
    # Prometheus 설정
    kubectl create namespace monitoring
    
    # Prometheus Operator 설치
    kubectl apply -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/main/bundle.yaml
    
    # Node Exporter DaemonSet
    kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: node-exporter
  namespace: monitoring
spec:
  selector:
    matchLabels:
      app: node-exporter
  template:
    metadata:
      labels:
        app: node-exporter
    spec:
      containers:
      - name: node-exporter
        image: prom/node-exporter:latest
        ports:
        - containerPort: 9100
        volumeMounts:
        - name: proc
          mountPath: /host/proc
          readOnly: true
        - name: sys
          mountPath: /host/sys
          readOnly: true
      volumes:
      - name: proc
        hostPath:
          path: /proc
      - name: sys
        hostPath:
          path: /sys
EOF
    
    log_success "GKE 클러스터 모니터링 설정 완료"
}

# GKE 클러스터 백업
backup_gke_cluster() {
    local backup_name="backup-$(date +%Y%m%d-%H%M%S)"
    
    log_info "GKE 클러스터 백업 시작: $backup_name"
    
    # 클러스터 설정 백업
    gcloud container clusters describe $CLUSTER_NAME \
        --zone $ZONE \
        --project $PROJECT_ID \
        --format="yaml" > "gke-cluster-${backup_name}.yaml"
    
    # kubectl 설정 백업
    kubectl get all --all-namespaces -o yaml > "k8s-resources-${backup_name}.yaml"
    
    log_success "GKE 클러스터 백업 완료: $backup_name"
}

# GKE 클러스터 비용 최적화
optimize_gke_cluster() {
    log_info "GKE 클러스터 비용 최적화 시작"
    
    # 자동 스케일링 설정
    gcloud container clusters update $CLUSTER_NAME \
        --zone $ZONE \
        --project $PROJECT_ID \
        --enable-autoscaling \
        --min-nodes $MIN_NODES \
        --max-nodes $MAX_NODES
    
    # 노드 풀 최적화
    gcloud container node-pools update default-pool \
        --cluster $CLUSTER_NAME \
        --zone $ZONE \
        --project $PROJECT_ID \
        --machine-type $MACHINE_TYPE \
        --disk-type $DISK_TYPE
    
    log_success "GKE 클러스터 비용 최적화 완료"
}

# 사용법 출력
usage() {
    echo "GCP GKE 클러스터 구성 Helper 스크립트"
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
    echo "  --action create              # GKE 클러스터 생성"
    echo "  --action delete              # GKE 클러스터 삭제"
    echo "  --action status              # GKE 클러스터 상태 확인"
    echo "  --action scale <count>       # 클러스터 스케일링"
    echo "  --action upgrade <version>   # 클러스터 업그레이드"
    echo "  --action monitoring          # 모니터링 설정"
    echo "  --action backup              # 클러스터 백업"
    echo "  --action optimize            # 비용 최적화"
    echo ""
    echo "예시:"
    echo "  $0                           # Interactive 모드"
    echo "  $0 --action create           # GKE 클러스터 생성"
    echo "  $0 --action status           # 클러스터 상태 확인"
    echo "  $0 --action scale 3          # 노드 3개로 스케일링"
    echo ""
    echo "환경 변수:"
    echo "  CLUSTER_NAME        클러스터 이름 (기본값: cloud-intermediate-gke)"
    echo "  PROJECT_ID          GCP 프로젝트 ID"
    echo "  ZONE                GCP 존 (기본값: asia-northeast3-a)"
    echo "  MACHINE_TYPE         머신 타입 (기본값: e2-medium)"
    echo "  NODE_COUNT          노드 수 (기본값: 2)"
}

# Interactive 모드 메뉴
show_interactive_menu() {
    echo ""
    log_header "GCP GKE 클러스터 관리 메뉴"
    echo "1. GKE 클러스터 생성"
    echo "2. GKE 클러스터 삭제"
    echo "3. 클러스터 상태 확인"
    echo "4. 클러스터 스케일링"
    echo "5. 클러스터 업그레이드"
    echo "6. 모니터링 설정"
    echo "7. 클러스터 백업"
    echo "8. 비용 최적화"
    echo "9. 종료"
    echo ""
}

# Interactive 모드 실행
run_interactive_mode() {
    log_header "GCP GKE 클러스터 관리"
    
    while true; do
        show_interactive_menu
        read -p "선택하세요 (1-9): " choice
        
        case $choice in
            1)
                create_gke_cluster
                ;;
            2)
                delete_gke_cluster
                ;;
            3)
                check_gke_cluster
                ;;
            4)
                read -p "스케일링할 노드 수를 입력하세요: " node_count
                scale_gke_cluster "$node_count"
                ;;
            5)
                read -p "업그레이드할 버전을 입력하세요: " version
                upgrade_gke_cluster "$version"
                ;;
            6)
                setup_gke_monitoring
                ;;
            7)
                backup_gke_cluster
                ;;
            8)
                optimize_gke_cluster
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
    done
}

# Parameter 모드 실행
run_parameter_mode() {
    local action=$1
    shift
    
    case "$action" in
        "create")
            check_gcp_cli && create_gke_cluster
            ;;
        "delete")
            check_gcp_cli && delete_gke_cluster
            ;;
        "status")
            check_gcp_cli && check_gke_cluster
            ;;
        "scale")
            check_gcp_cli && scale_gke_cluster "$1"
            ;;
        "upgrade")
            check_gcp_cli && upgrade_gke_cluster "$1"
            ;;
        "monitoring")
            check_gcp_cli && setup_gke_monitoring
            ;;
        "backup")
            check_gcp_cli && backup_gke_cluster
            ;;
        "optimize")
            check_gcp_cli && optimize_gke_cluster
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
main "$@"
