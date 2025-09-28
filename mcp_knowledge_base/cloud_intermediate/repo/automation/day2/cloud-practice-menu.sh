#!/bin/bash

# Cloud Intermediate Day 2 실습 메뉴 시스템
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

# CI/CD 파이프라인 서비스 호출
call_cicd_service() {
    local action="$1"
    log_info "CI/CD 파이프라인 서비스 호출: ${action}"
    
    if [ -f "${TOOLS_DIR}/cicd-pipeline-helper.sh" ]; then
        bash "${TOOLS_DIR}/cicd-pipeline-helper.sh" --action "${action}"
    else
        log_error "CI/CD 파이프라인 Helper를 찾을 수 없습니다: ${TOOLS_DIR}/cicd-pipeline-helper.sh"
        return 1
    fi
}

# 멀티 클라우드 모니터링 서비스 호출
call_multi_cloud_service() {
    local action="$1"
    log_info "멀티 클라우드 모니터링 서비스 호출: ${action}"
    
    if [ -f "${TOOLS_DIR}/multi-cloud-monitoring-helper.sh" ]; then
        bash "${TOOLS_DIR}/multi-cloud-monitoring-helper.sh" --action "${action}"
    else
        log_error "멀티 클라우드 모니터링 Helper를 찾을 수 없습니다: ${TOOLS_DIR}/multi-cloud-monitoring-helper.sh"
        return 1
    fi
}

# AWS Application 모니터링 서비스 호출
call_aws_app_service() {
    local action="$1"
    log_info "AWS Application 모니터링 서비스 호출: ${action}"
    
    if [ -f "${TOOLS_DIR}/aws-app-monitoring-helper.sh" ]; then
        bash "${TOOLS_DIR}/aws-app-monitoring-helper.sh" --action "${action}"
    else
        log_error "AWS Application 모니터링 Helper를 찾을 수 없습니다: ${TOOLS_DIR}/aws-app-monitoring-helper.sh"
        return 1
    fi
}

# GCP 클러스터 통합 서비스 호출
call_gcp_cluster_service() {
    local action="$1"
    log_info "GCP 클러스터 통합 서비스 호출: ${action}"
    
    if [ -f "${TOOLS_DIR}/gcp-cluster-integration-helper.sh" ]; then
        bash "${TOOLS_DIR}/gcp-cluster-integration-helper.sh" --action "${action}"
    else
        log_error "GCP 클러스터 통합 Helper를 찾을 수 없습니다: ${TOOLS_DIR}/gcp-cluster-integration-helper.sh"
        return 1
    fi
}

# =============================================================================
# 메뉴 표시 함수
# =============================================================================

show_main_menu() {
    clear
    log_header "=========================================="
    log_header "Cloud Intermediate Day 2 실습 메뉴"
    log_header "=========================================="
    echo ""
    echo "1. 🔄 CI/CD 파이프라인 실습"
    echo "2. 🌐 멀티 클라우드 통합 모니터링"
    echo "3. 📊 AWS Application 모니터링"
    echo "4. ☁️  GCP 클러스터 통합"
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
            1) call_cicd_service "cicd-pipeline" ;;
            2) call_multi_cloud_service "multi-cloud-monitoring" ;;
            3) call_aws_app_service "aws-app-monitoring" ;;
            4) call_gcp_cluster_service "gcp-cluster-integration" ;;
            5) call_multi_cloud_service "cluster-status" ;;
            6) call_cicd_service "deployment" ;;
            7) call_multi_cloud_service "cluster-management" ;;
            8) call_multi_cloud_service "cleanup" ;;
            9) call_multi_cloud_service "status" ;;
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
# 사용법 출력
# =============================================================================
usage() {
    cat << EOF
Cloud Intermediate Day 2 실습 메뉴 시스템

사용법:
  $0 [옵션]                    # Interactive 모드
  $0 --action <액션> [파라미터] # Direct 실행 모드

Interactive 모드 옵션:
  --interactive, -i           # Interactive 모드 (기본값)
  --help, -h                 # 도움말 표시

Parameter 모드 액션:
  --action cicd-pipeline      # CI/CD 파이프라인 실습
  --action multi-cloud        # 멀티 클라우드 통합 모니터링
  --action aws-app            # AWS Application 모니터링
  --action gcp-cluster        # GCP 클러스터 통합
  --action cluster-status     # 클러스터 현황 확인
  --action deployment         # 배포 관리
  --action cluster            # 클러스터 관리
  --action cleanup            # 실습 환경 정리
  --action status             # 현재 리소스 상태 확인
  --action all                  # 전체 실습 실행

예시:
  $0                          # Interactive 모드
  $0 --action cicd-pipeline   # CI/CD 파이프라인만 실행
  $0 --action multi-cloud     # 멀티 클라우드 모니터링만 실행
  $0 --action all             # 전체 실습 실행

자동화 툴 사용 예시:
  $0 --action cleanup         # 정리만 실행
  $0 --action status          # 상태만 확인
  $0 --action all             # 전체 실습 실행
EOF
}

# =============================================================================
# Direct 실행 모드 처리
# =============================================================================
direct_mode() {
    local action="$1"
    local provider="${2:-aws}"
    
    case "$action" in
        "cicd-pipeline")
            call_cicd_service "cicd-pipeline"
            ;;
        "multi-cloud")
            call_multi_cloud_service "multi-cloud-monitoring"
            ;;
        "aws-app")
            call_aws_app_service "aws-app-monitoring"
            ;;
        "gcp-cluster")
            call_gcp_cluster_service "gcp-cluster-integration"
            ;;
        "cluster-status")
            call_multi_cloud_service "cluster-status"
            ;;
        "deployment")
            call_cicd_service "deployment"
            ;;
        "cluster")
            call_multi_cloud_service "cluster-management"
            ;;
        "cleanup")
            call_multi_cloud_service "cleanup"
            ;;
        "status")
            call_multi_cloud_service "status"
            ;;
        "all")
            call_cicd_service "cicd-pipeline"
            call_multi_cloud_service "multi-cloud-monitoring"
            call_aws_app_service "aws-app-monitoring"
            call_gcp_cluster_service "gcp-cluster-integration"
            ;;
        *)
            log_error "알 수 없는 액션: $action"
            usage
            exit 1
            ;;
    esac
}

# =============================================================================
# 메인 실행 로직
# =============================================================================
main() {
    # 인수 파싱
    case "${1:-}" in
        "--help"|"-h")
            usage
            exit 0
            ;;
        "--action")
            if [ -z "${2:-}" ]; then
                log_error "액션이 지정되지 않았습니다."
                usage
                exit 1
            fi
            direct_mode "$2" "${3:-aws}"
            ;;
        "--interactive"|"-i"|"")
            interactive_mode
            ;;
        *)
            log_error "알 수 없는 옵션: $1"
            usage
            exit 1
            ;;
    esac
}

# =============================================================================
# 스크립트 실행
# =============================================================================
main "$@"
