#!/bin/bash

# =============================================================================
# Cloud Intermediate Day 1 실습 스크립트
# =============================================================================
# 
# 기능:
#   - Docker 고급 실습 (멀티스테이지 빌드, 이미지 최적화, 보안 스캔)
#   - Kubernetes 기초 실습 (클러스터 Context, Workload 배포, 외부 접근)
#   - 클라우드 컨테이너 서비스 (AWS ECS, GCP Cloud Run)
#   - 통합 모니터링 허브 구축 (Prometheus, Grafana, Node Exporter)
#   - 서브실행모듈을 통한 클라우드 작업 실행
#
# 사용법:
#   ./day1-practice.sh                    # Interactive 모드
#   ./day1-practice.sh --action <액션>    # Direct 실행 모드
#   ./day1-practice.sh --help             # 도움말 표시
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
            if [ -f "$TOOLS_DIR/aws-environment.env" ]; then
                source "$TOOLS_DIR/aws-environment.env"
            fi
            ;;
        "gcp")
            if [ -f "$TOOLS_DIR/gcp-environment.env" ]; then
                source "$TOOLS_DIR/gcp-environment.env"
            fi
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
# Day 1 실습 메뉴 표시
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
    echo "5. 🖥️  AWS EC2 인스턴스 생성"
    echo "6. 🖥️  GCP Compute Engine 인스턴스 생성"
    echo "7. 🔍 클러스터 현황 확인"
    echo "8. 🚀 배포 관리"
    echo "9. ⚙️  클러스터 관리"
    echo "10. 🧹 실습 환경 정리"
    echo "11. 📋 현재 리소스 상태 확인"
    echo "0. 종료"
    echo ""
}

# =============================================================================
# Day 1 실습 메뉴 처리
# =============================================================================
handle_day1_menu() {
    while true; do
        show_day1_menu
        read -p "선택하세요 (0-9): " choice
        
        case $choice in
            1)
                log_info "Docker 고급 실습을 시작합니다..."
                call_sub_module "docker-helper.sh" "multistage-build" "aws"
                call_sub_module "docker-helper.sh" "optimize-image" "aws"
                call_sub_module "docker-helper.sh" "security-scan" "aws"
                ;;
            2) 
                log_info "Kubernetes 기초 실습을 시작합니다..."
                call_sub_module "k8s-helper.sh" "setup-context" "aws"
                call_sub_module "k8s-helper.sh" "deploy-workload" "aws"
                call_sub_module "k8s-helper.sh" "setup-external-access" "aws"
                ;;
            3) 
                log_info "클라우드 컨테이너 서비스 실습을 시작합니다..."
                call_sub_module "aws-ecs-helper.sh" "cluster-create" "aws"
                call_sub_module "aws-ecs-helper.sh" "task-definition" "aws"
                call_sub_module "aws-ecs-helper.sh" "service-create" "aws"
                call_sub_module "gcp-cloudrun-helper.sh" "deploy-service" "gcp"
                call_sub_module "gcp-cloudrun-helper.sh" "status" "gcp"
                call_sub_module "gcp-cloudrun-helper.sh" "manage-traffic" "gcp"
                ;;
            4) 
                log_info "통합 모니터링 허브 구축을 시작합니다..."
                call_sub_module "monitoring-hub-helper.sh" "create-hub" "aws"
                call_sub_module "monitoring-hub-helper.sh" "install-prometheus" "aws"
                call_sub_module "monitoring-hub-helper.sh" "install-grafana" "aws"
                call_sub_module "monitoring-hub-helper.sh" "install-node-exporter" "aws"
                call_sub_module "monitoring-hub-helper.sh" "setup-integration" "aws"
                ;;
            5) 
                log_info "AWS EC2 인스턴스를 생성합니다..."
                call_sub_module "aws-ec2-helper.sh" "create-instance" "aws"
                ;;
            6) 
                log_info "GCP Compute Engine 인스턴스를 생성합니다..."
                call_sub_module "gcp-compute-helper.sh" "create-instance" "gcp"
                ;;
            7) 
                log_info "클러스터 현황을 확인합니다..."
                call_sub_module "k8s-helper.sh" "status" "aws"
                call_sub_module "k8s-helper.sh" "status" "gcp"
                call_sub_module "aws-ecs-helper.sh" "status" "aws"
                call_sub_module "gcp-cloudrun-helper.sh" "status" "gcp"
                call_sub_module "aws-ec2-helper.sh" "status" "aws"
                call_sub_module "gcp-compute-helper.sh" "status" "gcp"
                ;;
            8) 
                log_info "배포 관리를 시작합니다..."
                call_sub_module "k8s-helper.sh" "deploy-workload" "aws"
                call_sub_module "aws-ecs-helper.sh" "service-update" "aws"
                call_sub_module "gcp-cloudrun-helper.sh" "update-service" "gcp"
                ;;
            9) 
                log_info "클러스터 관리를 시작합니다..."
                call_sub_module "k8s-helper.sh" "setup-external-access" "aws"
                call_sub_module "k8s-helper.sh" "troubleshoot" "aws"
                call_sub_module "aws-ecs-helper.sh" "service-update" "aws"
                call_sub_module "gcp-cloudrun-helper.sh" "setup-security" "gcp"
                ;;
            10) 
                log_info "실습 환경을 정리합니다..."
                call_sub_module "comprehensive-cleanup.sh" "cleanup" "all"
                ;;
            11) 
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

# =============================================================================
# 사용법 출력
# =============================================================================
usage() {
    cat << EOF
Cloud Intermediate Day 1 실습 스크립트

사용법:
  $0 [옵션]                    # Interactive 모드
  $0 --action <액션> [파라미터] # Direct 실행 모드
  $0 --help, -h                # 도움말 표시

Interactive 모드 옵션:
  --interactive, -i           # Interactive 모드 (기본값)
  --help, -h                  # 도움말 표시

Direct 실행 모드 액션:
  --action docker-advanced     # Docker 고급 실습
  --action kubernetes-basics   # Kubernetes 기초 실습
  --action cloud-services     # 클라우드 컨테이너 서비스 실습
  --action monitoring-hub     # 통합 모니터링 허브 구축
  --action cluster-status     # 클러스터 현황 확인
  --action deployment         # 배포 관리
  --action cluster            # 클러스터 관리
  --action cleanup            # 실습 환경 정리
  --action status             # 현재 리소스 상태 확인
  --action all                # 전체 실습 실행

Day 1 실습 내용:
  - Docker 고급 실습 (멀티스테이지 빌드, 이미지 최적화, 보안 스캔)
  - Kubernetes 기초 실습 (클러스터 Context, Workload 배포, 외부 접근)
  - 클라우드 컨테이너 서비스 (AWS ECS, GCP Cloud Run)
  - 통합 모니터링 허브 구축 (Prometheus, Grafana, Node Exporter)

예시:
  $0                          # Interactive 모드
  $0 --action docker-advanced # Docker 고급 실습만 실행
  $0 --action cleanup         # 실습 환경 정리
  $0 --action status          # 현재 리소스 상태 확인
  $0 --action all             # 전체 실습 실행
EOF
}

# =============================================================================
# Direct 실행 모드 처리
# =============================================================================
direct_mode() {
    local action="$1"
    
    case "$action" in
        "docker-advanced")
            log_info "Docker 고급 실습을 시작합니다..."
            call_sub_module "docker-helper.sh" "multistage-build" "aws"
            call_sub_module "docker-helper.sh" "optimize-image" "aws"
            call_sub_module "docker-helper.sh" "security-scan" "aws"
            ;;
        "kubernetes-basics")
            log_info "Kubernetes 기초 실습을 시작합니다..."
            call_sub_module "k8s-helper.sh" "setup-context" "aws"
            call_sub_module "k8s-helper.sh" "deploy-workload" "aws"
            call_sub_module "k8s-helper.sh" "setup-external-access" "aws"
            ;;
        "cloud-services")
            log_info "클라우드 컨테이너 서비스 실습을 시작합니다..."
            call_sub_module "aws-ecs-helper.sh" "cluster-create" "aws"
            call_sub_module "aws-ecs-helper.sh" "task-definition" "aws"
            call_sub_module "aws-ecs-helper.sh" "service-create" "aws"
            call_sub_module "gcp-cloudrun-helper.sh" "deploy-service" "gcp"
            call_sub_module "gcp-cloudrun-helper.sh" "status" "gcp"
            call_sub_module "gcp-cloudrun-helper.sh" "manage-traffic" "gcp"
            ;;
        "monitoring-hub")
            log_info "통합 모니터링 허브 구축을 시작합니다..."
            call_sub_module "monitoring-hub-helper.sh" "create-hub" "aws"
            call_sub_module "monitoring-hub-helper.sh" "install-prometheus" "aws"
            call_sub_module "monitoring-hub-helper.sh" "install-grafana" "aws"
            call_sub_module "monitoring-hub-helper.sh" "install-node-exporter" "aws"
            call_sub_module "monitoring-hub-helper.sh" "setup-integration" "aws"
            ;;
        "cluster-status")
            log_info "클러스터 현황을 확인합니다..."
            call_sub_module "k8s-helper.sh" "status" "aws"
            call_sub_module "k8s-helper.sh" "status" "gcp"
            call_sub_module "aws-ecs-helper.sh" "status" "aws"
            call_sub_module "gcp-cloudrun-helper.sh" "status" "gcp"
            ;;
        "deployment")
            log_info "배포 관리를 시작합니다..."
            call_sub_module "k8s-helper.sh" "deploy-workload" "aws"
            call_sub_module "aws-ecs-helper.sh" "service-update" "aws"
            call_sub_module "gcp-cloudrun-helper.sh" "update-service" "gcp"
            ;;
        "cluster")
            log_info "클러스터 관리를 시작합니다..."
            call_sub_module "k8s-helper.sh" "setup-external-access" "aws"
            call_sub_module "k8s-helper.sh" "troubleshoot" "aws"
            call_sub_module "aws-ecs-helper.sh" "service-update" "aws"
            call_sub_module "gcp-cloudrun-helper.sh" "setup-security" "gcp"
            ;;
        "cleanup")
            log_info "실습 환경을 정리합니다..."
            call_sub_module "comprehensive-cleanup.sh" "cleanup" "all"
            ;;
        "status")
            log_info "현재 리소스 상태를 확인합니다..."
            call_sub_module "comprehensive-cleanup.sh" "status" "all"
            ;;
        "all")
            log_info "전체 Day 1 실습을 시작합니다..."
            call_sub_module "docker-helper.sh" "multistage-build" "aws"
            call_sub_module "k8s-helper.sh" "setup-context" "aws"
            call_sub_module "aws-ecs-helper.sh" "cluster-create" "aws"
            call_sub_module "gcp-cloudrun-helper.sh" "deploy-service" "gcp"
            call_sub_module "gcp-cloudrun-helper.sh" "status" "gcp"
            call_sub_module "monitoring-hub-helper.sh" "create-hub" "aws"
            log_success "Day 1 전체 실습 완료"
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
    local action=""
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --help|-h)
            usage
            exit 0
            ;;
            --action)
                action="$2"
                shift 2
                ;;
            --interactive|-i|"")
                # Interactive 모드 (기본값)
                break
            ;;
        *)
            log_error "알 수 없는 옵션: $1"
            usage
            exit 1
            ;;
    esac
    done
    
    # 환경 설정 로드
    load_environment
    
    # 액션이 지정된 경우 Direct 모드
    if [ -n "$action" ]; then
        direct_mode "$action"
        return
    fi
    
    # Interactive 모드
    log_success "Cloud Intermediate Day 1 실습 메뉴 시스템을 시작합니다."
    handle_day1_menu
}

# =============================================================================
# 스크립트 실행
# =============================================================================
    main "$@"
