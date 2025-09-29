#!/bin/bash

# Cloud Intermediate 실습 메뉴 시스템 (중앙화)
# 사용자에게 서비스 실행 모듈을 호출할 수 있는 메뉴 제공 역할에 한정
# 날짜별로 동적 구성되는 통합 메뉴 시스템

# =============================================================================
# 설정 및 초기화
# =============================================================================

# 스크립트 디렉토리 설정
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TOOLS_DIR="$SCRIPT_DIR"
ENV_DIR="$TOOLS_DIR"

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
# 날짜별 메뉴 구성 감지
# =============================================================================

detect_day_context() {
    # 호출된 경로에서 day 정보 추출
    local current_path="$(pwd)"
    local day_pattern="day([0-9]+)"
    
    if [[ "$current_path" =~ $day_pattern ]]; then
        DAY_NUMBER="${BASH_REMATCH[1]}"
        log_info "Day $DAY_NUMBER 컨텍스트 감지됨"
    else
        # 명령행 인수에서 day 정보 확인
        for arg in "$@"; do
            if [[ "$arg" =~ ^day([0-9]+)$ ]]; then
                DAY_NUMBER="${BASH_REMATCH[1]}"
                log_info "Day $DAY_NUMBER 컨텍스트 감지됨 (인수에서)"
                break
            fi
        done
    fi
    
    # 기본값 설정
    DAY_NUMBER="${DAY_NUMBER:-1}"
    log_info "활성 Day: $DAY_NUMBER"
}

# =============================================================================
# 서비스 실행 모듈 호출 함수
# =============================================================================

call_sub_module() {
    local module_name="$1"
    local action="$2"
    local provider="${3:-aws}"
    
    local module_path="$TOOLS_DIR/$module_name"
    
    if [ ! -f "$module_path" ]; then
        log_error "서브 실행 모듈을 찾을 수 없습니다: $module_path"
        return 1
    fi
    
    if [ ! -x "$module_path" ]; then
        log_error "서브 실행 모듈에 실행 권한이 없습니다: $module_path"
        return 1
    fi
    
    log_info "서브 실행 모듈 호출: $module_name"
    log_info "액션: $action, 프로바이더: $provider"
    
    # 환경 설정 로드
    case "$provider" in
        "aws")
            source "$TOOLS_DIR/aws-environment.env"
            ;;
        "gcp")
            source "$TOOLS_DIR/gcp-environment.env"
            ;;
    esac
    
    # 서브 모듈 실행
    "$module_path" --action "$action" --provider "$provider"
    local exit_code=$?
    
    if [ $exit_code -eq 0 ]; then
        log_success "서브 실행 모듈 완료: $module_name"
    else
        log_error "서브 실행 모듈 실패: $module_name (종료 코드: $exit_code)"
    fi
    
    return $exit_code
}

# =============================================================================
# Day별 메뉴 표시 함수
# =============================================================================

show_day1_menu() {
    clear
    log_header "=========================================="
    log_header "Cloud Intermediate Day 1 실습 메뉴"
    log_header "=========================================="
    echo ""
    echo "1. 🐳 Docker 고급 실습"
    echo "2. ☸️ Kubernetes cluster 배포 실습"
    echo "3. ☸️ Kubernetes object 배포 실습"
    echo "4. 📊 통합 모니터링 허브 구축"
    echo "5. 🔍 클러스터 현황 확인"
    echo "6. 🚀 배포 관리"
    echo "7. ⚙️  클러스터 관리"
    echo "8. 🧹 실습 환경 정리"
    echo "9. 📋 현재 리소스 상태 확인"
    echo "0. 종료"
    echo ""
}

show_day2_menu() {
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

show_general_menu() {
    clear
    log_header "=========================================="
    log_header "Cloud Intermediate 실습 메뉴"
    log_header "=========================================="
    echo ""
    echo "1. 📋 현재 리소스 상태 확인"
    echo "2. 🧹 실습 환경 정리"
    echo "3. 🔍 클러스터 현황 확인"
    echo "4. 🚀 배포 관리"
    echo "5. ⚙️  클러스터 관리"
    echo "6. 📊 모니터링 설정"
    echo "7. 🔄 CI/CD 파이프라인"
    echo "8. ☁️  멀티 클라우드 관리"
    echo "0. 종료"
    echo ""
}

# =============================================================================
# Day별 메뉴 처리 함수
# =============================================================================

handle_day1_menu() {
    while true; do
        show_day1_menu
        read -p "선택하세요 (0-9): " choice
        
        case $choice in
            1) call_sub_module "aws-setup-helper.sh" "docker-advanced" ;;
            2) call_sub_module "aws-eks-helper-new.sh" "cluster" ;;
            3) call_sub_module "aws-eks-helper-new.sh" "kubernetes-basics" ;;
            4) call_sub_module "aws-eks-helper-new.sh" "deployment" ;;
            5) call_sub_module "aws-eks-helper-new.sh" "cloud-services" ;;
            6) call_sub_module "multi-cloud-monitoring-helper.sh" "monitoring-hub" ;;
            7) call_sub_module "status-helper.sh" "status" "aws" ;;
            8) call_sub_module "aws-eks-helper-new.sh" "cluster" ;;
            9) call_sub_module "cleanup-helper.sh" "cleanup" "aws" ;;
            a) call_sub_module "status-helper.sh" "status" "aws" ;;
            b) 
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

handle_day2_menu() {
    while true; do
        show_day2_menu
        read -p "선택하세요 (0-9): " choice
        
        case $choice in
            1) call_sub_module "cicd-pipeline-helper.sh" "cicd-pipeline" ;;
            2) call_sub_module "multi-cloud-monitoring-helper.sh" "multi-cloud-monitoring" ;;
            3) call_sub_module "aws-app-monitoring-helper.sh" "aws-app-monitoring" ;;
            4) call_sub_module "gcp-cluster-integration-helper.sh" "gcp-cluster-integration" ;;
            5) call_sub_module "status-helper.sh" "status" "all" ;;
            6) call_sub_module "cicd-pipeline-helper.sh" "deployment" ;;
            7) call_sub_module "multi-cloud-monitoring-helper.sh" "cluster-management" ;;
            8) call_sub_module "cleanup-helper.sh" "cleanup" "all" ;;
            9) call_sub_module "status-helper.sh" "status" "all" ;;
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

handle_general_menu() {
    while true; do
        show_general_menu
        read -p "선택하세요 (0-8): " choice
        
        case $choice in
            1) call_sub_module "status-helper.sh" "status" "all" ;;
            2) call_sub_module "cleanup-helper.sh" "cleanup" "all" ;;
            3) call_sub_module "status-helper.sh" "status" "all" ;;
            4) call_sub_module "aws-eks-helper-new.sh" "deployment" ;;
            5) call_sub_module "aws-eks-helper-new.sh" "cluster" ;;
            6) call_sub_module "multi-cloud-monitoring-helper.sh" "monitoring-setup" "all" ;;
            7) call_sub_module "cicd-pipeline-helper.sh" "cicd-pipeline" ;;
            8) call_sub_module "multi-cloud-monitoring-helper.sh" "multi-cloud-monitoring" ;;
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
Cloud Intermediate 실습 메뉴 시스템 (중앙화)

사용법:
  $0 [옵션]                    # Interactive 모드
  $0 --action <액션> [파라미터] # Direct 실행 모드
  $0 --day <N> [옵션]          # 특정 Day 모드

Interactive 모드 옵션:
  --interactive, -i           # Interactive 모드 (기본값)
  --day <N>                   # 특정 Day 모드 (1, 2, ...)
  --help, -h                 # 도움말 표시

Parameter 모드 액션:
  --action status             # 현재 리소스 상태 확인
  --action cleanup            # 실습 환경 정리
  --action cluster-status     # 클러스터 현황 확인
  --action deployment         # 배포 관리
  --action cluster            # 클러스터 관리
  --action monitoring         # 모니터링 설정
  --action cicd               # CI/CD 파이프라인
  --action multi-cloud        # 멀티 클라우드 관리

예시:
  $0                          # Interactive 모드 (자동 Day 감지)
  $0 --day 1                  # Day 1 모드
  $0 --day 2                  # Day 2 모드
  $0 --action status          # 상태 확인
  $0 --action cleanup         # 환경 정리
EOF
}

# =============================================================================
# Direct 실행 모드 처리
# =============================================================================
direct_mode() {
    local action="$1"
    local provider="${2:-aws}"
    
    case "$action" in
        "status")
            call_sub_module "status-helper.sh" "status" "all"
            ;;
        "cleanup")
            call_sub_module "cleanup-helper.sh" "cleanup" "all"
            ;;
        "cluster-status")
            call_sub_module "status-helper.sh" "status" "all"
            ;;
        "deployment")
            call_sub_module "aws-eks-helper-new.sh" "deployment"
            ;;
        "cluster")
            call_sub_module "aws-eks-helper-new.sh" "cluster"
            ;;
        "monitoring")
            call_sub_module "multi-cloud-monitoring-helper.sh" "monitoring-setup" "all"
            ;;
        "cicd")
            call_sub_module "cicd-pipeline-helper.sh" "cicd-pipeline"
            ;;
        "multi-cloud")
            call_sub_module "multi-cloud-monitoring-helper.sh" "multi-cloud-monitoring"
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
    local day_mode=""
    local action=""
    local provider="aws"
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --help|-h)
                usage
                exit 0
                ;;
            --day)
                day_mode="$2"
                shift 2
                ;;
            --action)
                action="$2"
                shift 2
                ;;
            --provider)
                provider="$2"
                shift 2
                ;;
            --interactive|-i|"")
                # Interactive 모드 (기본값)
                break
                ;;
            *)
                # Day 감지를 위한 인수 처리
                if [[ "$1" =~ ^day([0-9]+)$ ]]; then
                    day_mode="${BASH_REMATCH[1]}"
                fi
                shift
                ;;
        esac
    done
    
    # 환경 설정 로드
    load_environment
    
    # Day 컨텍스트 감지
    detect_day_context "$@"
    
    # Day 모드가 명시적으로 지정된 경우
    if [ -n "$day_mode" ]; then
        DAY_NUMBER="$day_mode"
    fi
    
    # 액션이 지정된 경우 Direct 모드
    if [ -n "$action" ]; then
        direct_mode "$action" "$provider"
        return
    fi
    
    # Day별 메뉴 처리
    case "$DAY_NUMBER" in
        "1")
            log_success "Cloud Intermediate Day 1 실습 메뉴 시스템을 시작합니다."
            handle_day1_menu
            ;;
        "2")
            log_success "Cloud Intermediate Day 2 실습 메뉴 시스템을 시작합니다."
            handle_day2_menu
            ;;
        *)
            log_success "Cloud Intermediate 실습 메뉴 시스템을 시작합니다."
            handle_general_menu
            ;;
    esac
}

# =============================================================================
# 스크립트 실행
# =============================================================================
main "$@"
