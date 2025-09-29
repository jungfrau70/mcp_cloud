#!/bin/bash

# =============================================================================
# Cloud Intermediate 통합 실습 메뉴 시스템
# =============================================================================
# 
# 기능:
#   - 통합강의안 자동화 코드를 사용자에게 호출할 수 있는 메뉴 제공
#   - AWS 및 GCP 인프라 자원배포 (EC2, EKS, GKE) 통합 관리
#   - 서브실행모듈을 통한 클라우드 작업 실행
#   - 환경 파일 기반 설정 관리
#
# 사용법:
#   ./cloud-practice-menu.sh                    # Interactive 모드
#   ./cloud-practice-menu.sh --day 1            # Day 1 모드
#   ./cloud-practice-menu.sh --day 2            # Day 2 모드
#   ./cloud-practice-menu.sh --action status    # Direct 실행 모드
#
# 작성일: 2024-01-XX
# 작성자: Cloud Intermediate 과정
# =============================================================================

# =============================================================================
# 환경 설정 및 초기화
# =============================================================================
set -euo pipefail

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

show_day2_menu() {
    clear
    log_header "=========================================="
    log_header "Cloud Intermediate Day 2 실습 메뉴"
    log_header "=========================================="
    echo ""
    echo "1. 🔄 GitHub Actions CI/CD 파이프라인"
    echo "2. 📊 AWS EKS 애플리케이션 모니터링"
    echo "3. ☁️  GCP GKE 클러스터 통합 모니터링"
    echo "4. 🌐 멀티 클라우드 통합 모니터링"
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
    log_header "Cloud Intermediate 통합 실습 메뉴"
    log_header "=========================================="
    echo ""
    echo "1. 🏗️  AWS/GCP 인프라 설정"
    echo "1a. 🖥️  AWS EC2 인스턴스 생성"
    echo "1b. 🖥️  GCP Compute Engine 인스턴스 생성"
    echo "2. 📋 현재 리소스 상태 확인"
    echo "3. 🧹 실습 환경 정리"
    echo "4. 🔍 클러스터 현황 확인"
    echo "5. 🚀 배포 관리"
    echo "6. ⚙️  클러스터 관리"
    echo "7. 📊 모니터링 설정"
    echo "8. 🔄 CI/CD 파이프라인"
    echo "9. ☁️  멀티 클라우드 관리"
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
            1) 
                log_info "Docker 고급 실습을 시작합니다..."
                call_sub_module "docker-helper.sh" "multistage-build" "aws"
                ;;
            2) 
                log_info "Kubernetes 기초 실습을 시작합니다..."
                call_sub_module "k8s-helper.sh" "setup-context" "aws"
                ;;
            3) 
                log_info "클라우드 컨테이너 서비스 실습을 시작합니다..."
                call_sub_module "aws-ecs-helper.sh" "cluster-create" "aws"
                call_sub_module "gcp-cloudrun-helper.sh" "deploy-service" "gcp"
                ;;
            4) 
                log_info "통합 모니터링 허브 구축을 시작합니다..."
                call_sub_module "monitoring-hub-helper.sh" "create-hub" "aws"
                ;;
            5) 
                log_info "클러스터 현황을 확인합니다..."
                call_sub_module "k8s-helper.sh" "status" "aws"
                call_sub_module "k8s-helper.sh" "status" "gcp"
                ;;
            6) 
                log_info "배포 관리를 시작합니다..."
                call_sub_module "k8s-helper.sh" "deploy-workload" "aws"
                ;;
            7) 
                log_info "클러스터 관리를 시작합니다..."
                call_sub_module "k8s-helper.sh" "setup-external-access" "aws"
                ;;
            8) 
                log_info "실습 환경을 정리합니다..."
                call_sub_module "comprehensive-cleanup.sh" "cleanup" "all"
                ;;
            9) 
                log_info "현재 리소스 상태를 확인합니다..."
                call_sub_module "comprehensive-cleanup.sh" "status" "all"
                ;;
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

handle_day2_menu() {
    while true; do
        show_day2_menu
        read -p "선택하세요 (0-9): " choice
        
        case $choice in
            1) 
                log_info "GitHub Actions CI/CD 파이프라인을 시작합니다..."
                call_sub_module "github-actions-helper.sh" "create-workflow" "aws"
                ;;
            2) 
                log_info "AWS EKS 애플리케이션 모니터링을 시작합니다..."
                call_sub_module "aws-eks-monitoring-helper.sh" "create-cluster" "aws"
                call_sub_module "aws-app-monitoring-helper.sh" "app-deploy" "aws"
                ;;
            3) 
                log_info "GCP GKE 클러스터 통합 모니터링을 시작합니다..."
                call_sub_module "gcp-gke-monitoring-helper.sh" "create-cluster" "gcp"
                call_sub_module "gcp-gke-monitoring-helper.sh" "setup-monitoring" "gcp"
                ;;
            4) 
                log_info "멀티 클라우드 통합 모니터링을 시작합니다..."
                call_sub_module "multi-cloud-monitoring-helper.sh" "monitoring-setup" "all"
                ;;
            5) 
                log_info "클러스터 현황을 확인합니다..."
                call_sub_module "aws-eks-monitoring-helper.sh" "status" "aws"
                call_sub_module "gcp-gke-monitoring-helper.sh" "status" "gcp"
                ;;
            6) 
                log_info "배포 관리를 시작합니다..."
                call_sub_module "github-actions-helper.sh" "deploy-app" "aws"
                ;;
            7) 
                log_info "클러스터 관리를 시작합니다..."
                call_sub_module "multi-cloud-monitoring-helper.sh" "cross-cluster-setup" "all"
                ;;
            8) 
                log_info "실습 환경을 정리합니다..."
                call_sub_module "comprehensive-cleanup.sh" "cleanup" "all"
                ;;
            9) 
                log_info "현재 리소스 상태를 확인합니다..."
                call_sub_module "comprehensive-cleanup.sh" "status" "all"
                ;;
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
        read -p "선택하세요 (0-9): " choice
        
        case $choice in
            1) 
                log_info "AWS/GCP 인프라 설정을 시작합니다..."
                call_sub_module "aws-setup-helper.sh" "setup" "aws"
                call_sub_module "gcp-setup-helper.sh" "setup" "gcp"
                ;;
            1a) 
                log_info "AWS EC2 인스턴스를 생성합니다..."
                call_sub_module "aws-ec2-helper.sh" "create-instance" "aws"
                ;;
            1b) 
                log_info "GCP Compute Engine 인스턴스를 생성합니다..."
                call_sub_module "gcp-compute-helper.sh" "create-instance" "gcp"
                ;;
            2) 
                log_info "현재 리소스 상태를 확인합니다..."
                call_sub_module "comprehensive-cleanup.sh" "status" "all"
                ;;
            3) 
                log_info "실습 환경을 정리합니다..."
                call_sub_module "comprehensive-cleanup.sh" "cleanup" "all"
                ;;
            4) 
                log_info "클러스터 현황을 확인합니다..."
                call_sub_module "aws-eks-monitoring-helper.sh" "status" "aws"
                call_sub_module "gcp-gke-monitoring-helper.sh" "status" "gcp"
                ;;
            5) 
                log_info "배포 관리를 시작합니다..."
                call_sub_module "github-actions-helper.sh" "deploy-app" "aws"
                ;;
            6) 
                log_info "클러스터 관리를 시작합니다..."
                call_sub_module "k8s-helper.sh" "setup-external-access" "aws"
                call_sub_module "k8s-helper.sh" "setup-external-access" "gcp"
                ;;
            7) 
                log_info "모니터링 설정을 시작합니다..."
                call_sub_module "monitoring-hub-helper.sh" "create-hub" "aws"
                call_sub_module "multi-cloud-monitoring-helper.sh" "monitoring-setup" "all"
                ;;
            8) 
                log_info "CI/CD 파이프라인을 시작합니다..."
                call_sub_module "github-actions-helper.sh" "create-workflow" "aws"
                ;;
            9) 
                log_info "멀티 클라우드 관리를 시작합니다..."
                call_sub_module "multi-cloud-monitoring-helper.sh" "cross-cluster-setup" "all"
                ;;
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
Cloud Intermediate 통합 실습 메뉴 시스템

사용법:
  $0 [옵션]                    # Interactive 모드
  $0 --action <액션> [파라미터] # Direct 실행 모드
  $0 --day <N> [옵션]          # 특정 Day 모드

Interactive 모드 옵션:
  --interactive, -i           # Interactive 모드 (기본값)
  --day <N>                   # 특정 Day 모드 (1, 2, ...)
  --help, -h                 # 도움말 표시

Direct 실행 모드 액션:
  --action status             # 현재 리소스 상태 확인
  --action cleanup            # 실습 환경 정리
  --action cluster-status     # 클러스터 현황 확인
  --action deployment         # 배포 관리
  --action cluster            # 클러스터 관리
  --action monitoring         # 모니터링 설정
  --action cicd               # CI/CD 파이프라인
  --action multi-cloud        # 멀티 클라우드 관리
  --action setup              # AWS/GCP 인프라 설정

Day 1 실습 내용:
  - Docker 고급 실습 (멀티스테이지 빌드, 이미지 최적화, 보안 스캔)
  - Kubernetes 기초 실습 (클러스터 Context, Workload 배포, 외부 접근)
  - 클라우드 컨테이너 서비스 (AWS ECS, GCP Cloud Run)
  - 통합 모니터링 허브 구축 (Prometheus, Grafana, Node Exporter)

Day 2 실습 내용:
  - GitHub Actions CI/CD 파이프라인
  - AWS EKS 애플리케이션 모니터링
  - GCP GKE 클러스터 통합 모니터링
  - 멀티 클라우드 통합 모니터링

예시:
  $0                          # Interactive 모드 (자동 Day 감지)
  $0 --day 1                  # Day 1 모드
  $0 --day 2                  # Day 2 모드
  $0 --action status          # 상태 확인
  $0 --action cleanup         # 환경 정리
  $0 --action setup           # 인프라 설정
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
            call_sub_module "comprehensive-cleanup.sh" "status" "all"
            ;;
        "cleanup")
            call_sub_module "comprehensive-cleanup.sh" "cleanup" "all"
            ;;
        "cluster-status")
            call_sub_module "aws-eks-monitoring-helper.sh" "status" "aws"
            call_sub_module "gcp-gke-monitoring-helper.sh" "status" "gcp"
            ;;
        "deployment")
            call_sub_module "github-actions-helper.sh" "deploy-app" "aws"
            ;;
        "cluster")
            call_sub_module "k8s-helper.sh" "setup-external-access" "aws"
            call_sub_module "k8s-helper.sh" "setup-external-access" "gcp"
            ;;
        "monitoring")
            call_sub_module "monitoring-hub-helper.sh" "create-hub" "aws"
            call_sub_module "multi-cloud-monitoring-helper.sh" "monitoring-setup" "all"
            ;;
        "cicd")
            call_sub_module "github-actions-helper.sh" "create-workflow" "aws"
            ;;
        "multi-cloud")
            call_sub_module "multi-cloud-monitoring-helper.sh" "cross-cluster-setup" "all"
            ;;
        "setup")
            call_sub_module "aws-setup-helper.sh" "setup" "aws"
            call_sub_module "gcp-setup-helper.sh" "setup" "gcp"
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
