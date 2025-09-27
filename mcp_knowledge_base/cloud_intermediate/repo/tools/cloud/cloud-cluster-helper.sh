#!/bin/bash

# 통합 클라우드 클러스터 관리 Helper 스크립트
# Cloud Intermediate 과정용 멀티 클라우드 클러스터 자동화 도구

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

# 스크립트 디렉토리 설정
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AWS_EKS_HELPER="$SCRIPT_DIR/aws-eks-helper.sh"
GCP_GKE_HELPER="$SCRIPT_DIR/gcp-gke-helper.sh"

# 기본 설정
AWS_CLUSTER_NAME="cloud-intermediate-eks"
GCP_CLUSTER_NAME="cloud-intermediate-gke"
AWS_REGION="ap-northeast-2"
GCP_ZONE="asia-northeast3-a"

# 환경 변수 로드
load_environment() {
    if [ -f "$SCRIPT_DIR/aws-environment.env" ]; then
        source "$SCRIPT_DIR/aws-environment.env"
        log_info "AWS 환경 변수 로드 완료"
    fi
    
    if [ -f "$SCRIPT_DIR/gcp-environment.env" ]; then
        source "$SCRIPT_DIR/gcp-environment.env"
        log_info "GCP 환경 변수 로드 완료"
    fi
}

# AWS EKS 클러스터 관리
manage_aws_eks() {
    local action=$1
    local param=$2
    
    log_info "AWS EKS 클러스터 관리: $action"
    
    if [ ! -f "$AWS_EKS_HELPER" ]; then
        log_error "AWS EKS Helper 스크립트를 찾을 수 없습니다: $AWS_EKS_HELPER"
        return 1
    fi
    
    chmod +x "$AWS_EKS_HELPER"
    "$AWS_EKS_HELPER" "$action" "$param"
}

# GCP GKE 클러스터 관리
manage_gcp_gke() {
    local action=$1
    local param=$2
    
    log_info "GCP GKE 클러스터 관리: $action"
    
    if [ ! -f "$GCP_GKE_HELPER" ]; then
        log_error "GCP GKE Helper 스크립트를 찾을 수 없습니다: $GCP_GKE_HELPER"
        return 1
    fi
    
    chmod +x "$GCP_GKE_HELPER"
    "$GCP_GKE_HELPER" "$action" "$param"
}

# 멀티 클라우드 클러스터 생성
create_multi_cloud_clusters() {
    log_info "멀티 클라우드 클러스터 생성 시작"
    
    # AWS EKS 클러스터 생성
    log_info "1. AWS EKS 클러스터 생성"
    manage_aws_eks "create"
    
    if [ $? -eq 0 ]; then
        log_success "AWS EKS 클러스터 생성 완료"
    else
        log_error "AWS EKS 클러스터 생성 실패"
        return 1
    fi
    
    # GCP GKE 클러스터 생성
    log_info "2. GCP GKE 클러스터 생성"
    manage_gcp_gke "create"
    
    if [ $? -eq 0 ]; then
        log_success "GCP GKE 클러스터 생성 완료"
    else
        log_error "GCP GKE 클러스터 생성 실패"
        return 1
    fi
    
    log_success "멀티 클라우드 클러스터 생성 완료"
}

# 멀티 클라우드 클러스터 삭제
delete_multi_cloud_clusters() {
    log_warning "멀티 클라우드 클러스터 삭제 시작"
    
    read -p "정말로 모든 클러스터를 삭제하시겠습니까? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_info "클러스터 삭제를 취소했습니다."
        return 0
    fi
    
    # AWS EKS 클러스터 삭제
    log_info "1. AWS EKS 클러스터 삭제"
    manage_aws_eks "delete"
    
    # GCP GKE 클러스터 삭제
    log_info "2. GCP GKE 클러스터 삭제"
    manage_gcp_gke "delete"
    
    log_success "멀티 클라우드 클러스터 삭제 완료"
}

# 멀티 클라우드 클러스터 상태 확인
check_multi_cloud_clusters() {
    log_info "멀티 클라우드 클러스터 상태 확인"
    
    # AWS EKS 클러스터 상태
    log_info "=== AWS EKS 클러스터 상태 ==="
    manage_aws_eks "status"
    
    echo ""
    
    # GCP GKE 클러스터 상태
    log_info "=== GCP GKE 클러스터 상태 ==="
    manage_gcp_gke "status"
}

# 멀티 클라우드 클러스터 모니터링 설정
setup_multi_cloud_monitoring() {
    log_info "멀티 클라우드 클러스터 모니터링 설정 시작"
    
    # AWS EKS 모니터링 설정
    log_info "1. AWS EKS 모니터링 설정"
    manage_aws_eks "monitoring"
    
    # GCP GKE 모니터링 설정
    log_info "2. GCP GKE 모니터링 설정"
    manage_gcp_gke "monitoring"
    
    log_success "멀티 클라우드 클러스터 모니터링 설정 완료"
}

# 클러스터 간 연결 테스트
test_cluster_connectivity() {
    log_info "클러스터 간 연결 테스트"
    
    # AWS EKS 클러스터 연결 테스트
    log_info "=== AWS EKS 클러스터 연결 테스트 ==="
    if kubectl config use-context "arn:aws:eks:$AWS_REGION:$(aws sts get-caller-identity --query Account --output text):cluster/$AWS_CLUSTER_NAME" &> /dev/null; then
        log_success "AWS EKS 클러스터 연결 성공"
        kubectl get nodes
    else
        log_error "AWS EKS 클러스터 연결 실패"
    fi
    
    echo ""
    
    # GCP GKE 클러스터 연결 테스트
    log_info "=== GCP GKE 클러스터 연결 테스트 ==="
    if kubectl config use-context "gke_$(gcloud config get-value project)_$GCP_ZONE_$GCP_CLUSTER_NAME" &> /dev/null; then
        log_success "GCP GKE 클러스터 연결 성공"
        kubectl get nodes
    else
        log_error "GCP GKE 클러스터 연결 실패"
    fi
}

# 클러스터 리소스 정리
cleanup_cluster_resources() {
    log_info "클러스터 리소스 정리 시작"
    
    # AWS EKS 리소스 정리
    log_info "1. AWS EKS 리소스 정리"
    if kubectl config use-context "arn:aws:eks:$AWS_REGION:$(aws sts get-caller-identity --query Account --output text):cluster/$AWS_CLUSTER_NAME" &> /dev/null; then
        kubectl delete all --all --all-namespaces
        log_success "AWS EKS 리소스 정리 완료"
    else
        log_warning "AWS EKS 클러스터에 연결할 수 없습니다."
    fi
    
    # GCP GKE 리소스 정리
    log_info "2. GCP GKE 리소스 정리"
    if kubectl config use-context "gke_$(gcloud config get-value project)_$GCP_ZONE_$GCP_CLUSTER_NAME" &> /dev/null; then
        kubectl delete all --all --all-namespaces
        log_success "GCP GKE 리소스 정리 완료"
    else
        log_warning "GCP GKE 클러스터에 연결할 수 없습니다."
    fi
    
    log_success "클러스터 리소스 정리 완료"
}

# 클러스터 비용 분석
analyze_cluster_costs() {
    log_info "클러스터 비용 분석 시작"
    
    # AWS EKS 비용 분석
    log_info "=== AWS EKS 비용 분석 ==="
    aws ec2 describe-instances \
        --filters "Name=tag:kubernetes.io/cluster/$AWS_CLUSTER_NAME,Values=owned" \
        --query 'Reservations[*].Instances[*].[InstanceId,InstanceType,State.Name]' \
        --output table
    
    # GCP GKE 비용 분석
    log_info "=== GCP GKE 비용 분석 ==="
    gcloud compute instances list \
        --filter="name~$GCP_CLUSTER_NAME" \
        --format="table(name,machineType,status)"
    
    log_success "클러스터 비용 분석 완료"
}

# 클러스터 백업
backup_clusters() {
    log_info "클러스터 백업 시작"
    
    # AWS EKS 백업
    log_info "1. AWS EKS 백업"
    manage_aws_eks "backup"
    
    # GCP GKE 백업
    log_info "2. GCP GKE 백업"
    manage_gcp_gke "backup"
    
    log_success "클러스터 백업 완료"
}

# 사용법 출력
usage() {
    echo "통합 클라우드 클러스터 관리 Helper 스크립트"
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
    echo "  --action create              # 멀티 클라우드 클러스터 생성"
    echo "  --action delete              # 멀티 클라우드 클러스터 삭제"
    echo "  --action status              # 멀티 클라우드 클러스터 상태 확인"
    echo "  --action monitoring          # 멀티 클라우드 모니터링 설정"
    echo "  --action test                # 클러스터 간 연결 테스트"
    echo "  --action cleanup             # 클러스터 리소스 정리"
    echo "  --action costs               # 클러스터 비용 분석"
    echo "  --action backup              # 클러스터 백업"
    echo "  --action aws <action>         # AWS EKS 클러스터 관리"
    echo "  --action gcp <action>        # GCP GKE 클러스터 관리"
    echo ""
    echo "예시:"
    echo "  $0                           # Interactive 모드"
    echo "  $0 --action create           # 멀티 클라우드 클러스터 생성"
    echo "  $0 --action status           # 클러스터 상태 확인"
    echo "  $0 --action aws create       # AWS EKS 클러스터 생성"
    echo "  $0 --action gcp status       # GCP GKE 클러스터 상태 확인"
    echo ""
    echo "AWS EKS 액션:"
    echo "  create, delete, status, scale, upgrade, monitoring"
    echo ""
    echo "GCP GKE 액션:"
    echo "  create, delete, status, scale, upgrade, monitoring, backup, optimize"
}

# Interactive 모드 메뉴
show_interactive_menu() {
    echo ""
    log_header "통합 클라우드 클러스터 관리 메뉴"
    echo "1. 멀티 클라우드 클러스터 생성"
    echo "2. 멀티 클라우드 클러스터 삭제"
    echo "3. 클러스터 상태 확인"
    echo "4. 멀티 클라우드 모니터링 설정"
    echo "5. 클러스터 간 연결 테스트"
    echo "6. 클러스터 리소스 정리"
    echo "7. 클러스터 비용 분석"
    echo "8. 클러스터 백업"
    echo "9. AWS EKS 클러스터 관리"
    echo "10. GCP GKE 클러스터 관리"
    echo "11. 종료"
    echo ""
}

# Interactive 모드 실행
run_interactive_mode() {
    log_header "통합 클라우드 클러스터 관리"
    
    while true; do
        show_interactive_menu
        read -p "선택하세요 (1-11): " choice
        
        case $choice in
            1)
                create_multi_cloud_clusters
                ;;
            2)
                delete_multi_cloud_clusters
                ;;
            3)
                check_multi_cloud_clusters
                ;;
            4)
                setup_multi_cloud_monitoring
                ;;
            5)
                test_cluster_connectivity
                ;;
            6)
                cleanup_cluster_resources
                ;;
            7)
                analyze_cluster_costs
                ;;
            8)
                backup_clusters
                ;;
            9)
                log_info "AWS EKS 클러스터 관리 메뉴로 이동합니다."
                manage_aws_eks "interactive"
                ;;
            10)
                log_info "GCP GKE 클러스터 관리 메뉴로 이동합니다."
                manage_gcp_gke "interactive"
                ;;
            11)
                log_info "프로그램을 종료합니다"
                exit 0
                ;;
            *)
                log_error "잘못된 선택입니다. 1-11 중에서 선택하세요."
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
            create_multi_cloud_clusters
            ;;
        "delete")
            delete_multi_cloud_clusters
            ;;
        "status")
            check_multi_cloud_clusters
            ;;
        "monitoring")
            setup_multi_cloud_monitoring
            ;;
        "test")
            test_cluster_connectivity
            ;;
        "cleanup")
            cleanup_cluster_resources
            ;;
        "costs")
            analyze_cluster_costs
            ;;
        "backup")
            backup_clusters
            ;;
        "aws")
            manage_aws_eks "$1" "$2"
            ;;
        "gcp")
            manage_gcp_gke "$1" "$2"
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
    # 환경 변수 로드
    load_environment
    
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
            run_parameter_mode "$2" "$3" "$4"
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
