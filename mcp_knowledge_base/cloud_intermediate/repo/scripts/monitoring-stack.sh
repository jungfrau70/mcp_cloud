#!/bin/bash

# Cloud Intermediate - 통합 모니터링 스택 자동화 스크립트
# 멀티 클라우드 통합 모니터링 시스템 구축

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
NC='\033[0m'

# 로그 함수들
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_header() { echo -e "${PURPLE}=== $1 ===${NC}"; }

# 설정 변수
PROJECT_NAME="cloud-intermediate-monitoring"
MONITORING_DIR="./monitoring-stack"
PROMETHEUS_PORT="9090"
GRAFANA_PORT="3000"
NODE_EXPORTER_PORT="9100"
ALERTMANAGER_PORT="9093"
PUSHGATEWAY_PORT="9091"

# 사전 요구사항 확인
check_prerequisites() {
    log_header "사전 요구사항 확인"
    
    local missing_tools=()
    
    # Docker 확인
    if ! command -v docker &> /dev/null; then
        missing_tools+=("docker")
    fi
    
    # Docker Compose 확인
    if ! command -v docker-compose &> /dev/null; then
        missing_tools+=("docker-compose")
    fi
    
    # kubectl 확인
    if ! command -v kubectl &> /dev/null; then
        missing_tools+=("kubectl")
    fi
    
    # AWS CLI 확인
    if ! command -v aws &> /dev/null; then
        missing_tools+=("aws")
    fi
    
    # GCP CLI 확인
    if ! command -v gcloud &> /dev/null; then
        missing_tools+=("gcloud")
    fi
    
    if [ ${#missing_tools[@]} -gt 0 ]; then
        log_error "누락된 도구들: ${missing_tools[*]}"
        log_info "다음 명령어로 설치하세요:"
        for tool in "${missing_tools[@]}"; do
            case $tool in
                "docker")
                    echo "  sudo apt-get update && sudo apt-get install -y docker.io"
                    ;;
                "docker-compose")
                    echo "  sudo apt-get install -y docker-compose"
                    ;;
                "kubectl")
                    echo "  curl -LO https://dl.k8s.io/release/\$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
                    echo "  sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl"
                    ;;
                "aws")
                    echo "  curl 'https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip' -o 'awscliv2.zip'"
                    echo "  unzip awscliv2.zip && sudo ./aws/install"
                    ;;
                "gcloud")
                    echo "  curl https://sdk.cloud.google.com | bash"
                    echo "  exec -l $SHELL"
                    ;;
            esac
        done
        exit 1
    fi
    
    log_success "사전 요구사항 확인 완료"
}

# Phase 1: 통합 모니터링 허브 구축
setup_phase1_monitoring_hub() {
    log_header "Phase 1: 통합 모니터링 허브 구축"
    
    local phase1_dir="samples/day1/monitoring-hub"
    
    if [ ! -d "$phase1_dir" ]; then
        log_error "Phase 1 디렉토리가 없습니다: $phase1_dir"
        return 1
    fi
    
    log_info "Phase 1 모니터링 허브 설정 중..."
    cd "$phase1_dir"
    
    # Docker Compose 서비스 시작
    if docker-compose up -d; then
        log_success "Phase 1 모니터링 허브 시작 완료"
    else
        log_error "Phase 1 모니터링 허브 시작 실패"
        return 1
    fi
    
    cd - > /dev/null
}

# Phase 2: AWS 클러스터 모니터링
setup_phase2_aws_monitoring() {
    log_header "Phase 2: AWS 클러스터 모니터링"
    
    log_info "AWS 클러스터 모니터링 설정 중..."
    # 실제 AWS 환경에서 실행되는 코드
    log_warning "AWS 클러스터 모니터링은 실제 AWS 환경에서 실행해야 합니다."
}

# Phase 3: AWS Application 모니터링
setup_phase3_aws_application() {
    log_header "Phase 3: AWS Application 모니터링"
    
    log_info "AWS Application 모니터링 설정 중..."
    # 실제 AWS 환경에서 실행되는 코드
    log_warning "AWS Application 모니터링은 실제 AWS 환경에서 실행해야 합니다."
}

# Phase 4: GCP 클러스터 모니터링
setup_phase4_gcp_monitoring() {
    log_header "Phase 4: GCP 클러스터 모니터링"
    
    log_info "GCP 클러스터 모니터링 설정 중..."
    # 실제 GCP 환경에서 실행되는 코드
    log_warning "GCP 클러스터 모니터링은 실제 GCP 환경에서 실행해야 합니다."
}

# 모니터링 스택 상태 확인
check_monitoring_stack_status() {
    log_header "모니터링 스택 상태 확인"
    
    local phase1_dir="samples/day1/monitoring-hub"
    
    if [ -d "$phase1_dir" ]; then
        cd "$phase1_dir"
        
        # Docker Compose 서비스 상태 확인
        log_info "Docker Compose 서비스 상태 확인..."
        docker-compose ps
        
        # 서비스 접근성 확인
        log_info "서비스 접근성 확인..."
        if curl -s http://localhost:9090/api/v1/query?query=up > /dev/null; then
            log_success "Prometheus 접근 가능"
        else
            log_warning "Prometheus 접근 불가"
        fi
        
        if curl -s http://localhost:3000/api/health > /dev/null; then
            log_success "Grafana 접근 가능"
        else
            log_warning "Grafana 접근 불가"
        fi
        
        cd - > /dev/null
    fi
}

# 모니터링 스택 시작
start_monitoring_stack() {
    log_header "모니터링 스택 시작"
    
    local phase1_dir="samples/day1/monitoring-hub"
    
    if [ -d "$phase1_dir" ]; then
        cd "$phase1_dir"
        
        log_info "모니터링 스택 시작 중..."
        if docker-compose up -d; then
            log_success "모니터링 스택 시작 완료"
        else
            log_error "모니터링 스택 시작 실패"
            return 1
        fi
        
        cd - > /dev/null
    else
        log_error "Phase 1 디렉토리가 없습니다: $phase1_dir"
        return 1
    fi
}

# 모니터링 스택 중지
stop_monitoring_stack() {
    log_header "모니터링 스택 중지"
    
    local phase1_dir="samples/day1/monitoring-hub"
    
    if [ -d "$phase1_dir" ]; then
        cd "$phase1_dir"
        
        log_info "모니터링 스택 중지 중..."
        if docker-compose down; then
            log_success "모니터링 스택 중지 완료"
        else
            log_error "모니터링 스택 중지 실패"
            return 1
        fi
        
        cd - > /dev/null
    else
        log_error "Phase 1 디렉토리가 없습니다: $phase1_dir"
        return 1
    fi
}

# 모니터링 스택 로그 확인
show_monitoring_stack_logs() {
    log_header "모니터링 스택 로그 확인"
    
    local phase1_dir="samples/day1/monitoring-hub"
    
    if [ -d "$phase1_dir" ]; then
        cd "$phase1_dir"
        
        log_info "모니터링 스택 로그 확인 중..."
        docker-compose logs -f
        
        cd - > /dev/null
    else
        log_error "Phase 1 디렉토리가 없습니다: $phase1_dir"
        return 1
    fi
}

# 모니터링 스택 정리
cleanup_monitoring_stack() {
    log_header "모니터링 스택 정리"
    
    local phase1_dir="samples/day1/monitoring-hub"
    
    if [ -d "$phase1_dir" ]; then
        cd "$phase1_dir"
        
        log_info "모니터링 스택 정리 중..."
        docker-compose down -v
        docker volume prune -f
        
        log_success "모니터링 스택 정리 완료"
        
        cd - > /dev/null
    else
        log_error "Phase 1 디렉토리가 없습니다: $phase1_dir"
        return 1
    fi
}

# 도움말 표시
show_help() {
    echo "사용법: $0 [명령어]"
    echo ""
    echo "명령어:"
    echo "  setup-phase1     Phase 1: 통합 모니터링 허브 구축"
    echo "  setup-phase2     Phase 2: AWS 클러스터 모니터링"
    echo "  setup-phase3     Phase 3: AWS Application 모니터링"
    echo "  setup-phase4     Phase 4: GCP 클러스터 모니터링"
    echo "  start            모니터링 스택 시작"
    echo "  stop             모니터링 스택 중지"
    echo "  status           모니터링 스택 상태 확인"
    echo "  logs             모니터링 스택 로그 확인"
    echo "  cleanup          모니터링 스택 정리"
    echo "  help             도움말 표시"
    echo ""
    echo "예시:"
    echo "  $0 setup-phase1"
    echo "  $0 start"
    echo "  $0 status"
}

# 메인 실행 함수
main() {
    case "${1:-help}" in
        "setup-phase1")
            check_prerequisites
            setup_phase1_monitoring_hub
            ;;
        "setup-phase2")
            check_prerequisites
            setup_phase2_aws_monitoring
            ;;
        "setup-phase3")
            check_prerequisites
            setup_phase3_aws_application
            ;;
        "setup-phase4")
            check_prerequisites
            setup_phase4_gcp_monitoring
            ;;
        "start")
            start_monitoring_stack
            ;;
        "stop")
            stop_monitoring_stack
            ;;
        "status")
            check_monitoring_stack_status
            ;;
        "logs")
            show_monitoring_stack_logs
            ;;
        "cleanup")
            cleanup_monitoring_stack
            ;;
        "help"|*)
            show_help
            ;;
    esac
}

# 스크립트 실행
main "$@"