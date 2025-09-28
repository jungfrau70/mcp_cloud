#!/bin/bash

# Cloud Intermediate Day 1 실습 메뉴 시스템
# 사용자에게 서비스 실행 모듈을 호출할 수 있는 메뉴 제공 역할에 한정

# =============================================================================
# 설정 및 초기화
# =============================================================================

# 스크립트 디렉토리 설정
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TOOLS_DIR="${SCRIPT_DIR}/../../tools/cloud"
ENV_DIR="${TOOLS_DIR}"

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 로그 함수
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_header() { echo -e "${PURPLE}[HEADER]${NC} $1"; }

# =============================================================================
# 환경 설정 로드
# =============================================================================

load_environment() {
    log_info "환경 설정 로드 중..."
    
    # 공통 환경 설정 로드
    if [ -f "${ENV_DIR}/common-environment.env" ]; then
        source "${ENV_DIR}/common-environment.env"
        log_success "공통 환경 설정 로드 완료"
    else
        log_warning "공통 환경 설정 파일을 찾을 수 없습니다: ${ENV_DIR}/common-environment.env"
    fi
    
    # AWS 환경 설정 로드
    if [ -f "${ENV_DIR}/aws-environment.env" ]; then
        source "${ENV_DIR}/aws-environment.env"
        log_success "AWS 환경 설정 로드 완료"
    else
        log_warning "AWS 환경 설정 파일을 찾을 수 없습니다: ${ENV_DIR}/aws-environment.env"
    fi
    
    # GCP 환경 설정 로드
    if [ -f "${ENV_DIR}/gcp-environment.env" ]; then
        source "${ENV_DIR}/gcp-environment.env"
        log_success "GCP 환경 설정 로드 완료"
    else
        log_warning "GCP 환경 설정 파일을 찾을 수 없습니다: ${ENV_DIR}/gcp-environment.env"
    fi
}

# =============================================================================
# 서비스 실행 모듈 호출 함수
# =============================================================================

# AWS EKS 관련 서비스 호출
call_aws_eks_service() {
    local action="$1"
    log_info "AWS EKS 서비스 호출: ${action}"
    
    if [ -f "${TOOLS_DIR}/aws-eks-helper.sh" ]; then
        bash "${TOOLS_DIR}/aws-eks-helper.sh" --action "${action}"
    else
        log_error "AWS EKS Helper를 찾을 수 없습니다: ${TOOLS_DIR}/aws-eks-helper.sh"
        return 1
    fi
}

# AWS 설정 관련 서비스 호출
call_aws_setup_service() {
    local action="$1"
    log_info "AWS Setup 서비스 호출: ${action}"
    
    if [ -f "${TOOLS_DIR}/aws-setup-helper.sh" ]; then
        bash "${TOOLS_DIR}/aws-setup-helper.sh" --action "${action}"
    else
        log_error "AWS Setup Helper를 찾을 수 없습니다: ${TOOLS_DIR}/aws-setup-helper.sh"
        return 1
    fi
}

# 클라우드 클러스터 관련 서비스 호출
call_cloud_cluster_service() {
    local action="$1"
    log_info "Cloud Cluster 서비스 호출: ${action}"
    
    if [ -f "${TOOLS_DIR}/cloud-cluster-helper.sh" ]; then
        bash "${TOOLS_DIR}/cloud-cluster-helper.sh" --action "${action}"
    else
        log_error "Cloud Cluster Helper를 찾을 수 없습니다: ${TOOLS_DIR}/cloud-cluster-helper.sh"
        return 1
    fi
}

# =============================================================================
# 메뉴 표시 함수
# =============================================================================

show_main_menu() {
    clear
    log_header "=========================================="
    log_header "Cloud Intermediate Day 1 실습 메뉴"
    log_header "=========================================="
    echo ""
    echo "1. 🐳 Docker 고급 실습"
    echo "2. ☸️  Kubernetes 기초 실습"
    echo "3. ☁️  클라우드 컨테이너 서비스 실습"
    echo "4. 📊 통합 모니터링 허브 구축"
    echo "5. 🔍 클러스터 현황 확인"
    echo "6. 🚀 배포 관리"
    echo "7. ⚙️  클러스터 관리"
    echo "8. 🧹 실습 환경 정리"
    echo "9. 📋 현재 리소스 상태 확인"
    echo "0. 종료"
    echo ""
}

# =============================================================================
# 메뉴 처리 함수
# =============================================================================

handle_main_menu() {
    while true; do
        show_main_menu
        read -p "선택하세요 (0-9): " choice
        
        case $choice in
            1) call_aws_setup_service "docker-advanced" ;;
            2) call_aws_eks_service "kubernetes-basics" ;;
            3) call_cloud_cluster_service "cloud-services" ;;
            4) call_cloud_cluster_service "monitoring-hub" ;;
            5) call_cloud_cluster_service "cluster-status" ;;
            6) call_cloud_cluster_service "deployment" ;;
            7) call_cloud_cluster_service "cluster" ;;
            8) call_cloud_cluster_service "cleanup" ;;
            9) call_cloud_cluster_service "status" ;;
            0) 
                log_info "프로그램을 종료합니다."
                exit 0
                ;;
            *)
                log_error "잘못된 선택입니다. 다시 선택해주세요."
                read -p "계속하려면 Enter를 누르세요..."
                ;;
        esac
    done
}

# =============================================================================
# 메인 실행
# =============================================================================

main() {
    # 환경 설정 로드
    load_environment
    
    # 메뉴 시스템 시작
    log_success "Cloud Intermediate Day 1 실습 메뉴 시스템을 시작합니다."
    handle_main_menu
}

# 스크립트 실행
main "$@"