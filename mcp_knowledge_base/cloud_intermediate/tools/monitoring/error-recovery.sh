#!/bin/bash

# 자동화 스크립트 에러 복구 유틸리티
# 실패한 스크립트 자동 재시도 및 복구

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

# 에러 복구 설정
MAX_RETRIES=3
RETRY_DELAY=10
ERROR_LOG="/tmp/automation_errors.log"

# 에러 로그 초기화
init_error_log() {
    echo "=== 자동화 에러 로그 시작: $(date) ===" > "$ERROR_LOG"
}

# 에러 복구 시도
retry_with_recovery() {
    local script="$1"
    local action="$2"
    local max_retries="${3:-$MAX_RETRIES}"
    local retry_count=0
    
    while [ $retry_count -lt $max_retries ]; do
        log_info "시도 $((retry_count + 1))/$max_retries: $script"
        
        if ./"$script" --action "$action" 2>&1 | tee -a "$ERROR_LOG"; then
            log_success "✅ $script 실행 성공"
            return 0
        else
            retry_count=$((retry_count + 1))
            log_warning "❌ $script 실행 실패 (시도 $retry_count/$max_retries)"
            
            if [ $retry_count -lt $max_retries ]; then
                log_info "복구 시도 중... ($RETRY_DELAY초 대기)"
                perform_recovery "$script" "$action"
                sleep $RETRY_DELAY
            fi
        fi
    done
    
    log_error "❌ $script 최대 재시도 횟수 초과"
    return 1
}

# 복구 작업 수행
perform_recovery() {
    local script="$1"
    local action="$2"
    
    log_header "복구 작업 수행: $script"
    
    case "$script" in
        "day1-practice.sh")
            recover_day1_practice "$action"
            ;;
        "day2-practice.sh")
            recover_day2_practice "$action"
            ;;
        "monitoring-stack.sh")
            recover_monitoring_stack
            ;;
        "cleanup-resources.sh")
            recover_cleanup_resources
            ;;
        *)
            log_warning "알 수 없는 스크립트: $script"
            ;;
    esac
}

# Day1 실습 복구
recover_day1_practice() {
    local action="$1"
    
    log_info "Day1 실습 복구: $action"
    
    # Docker 리소스 정리
    docker system prune -f || true
    
    # Kubernetes 리소스 정리
    kubectl delete --all pods --all-namespaces || true
    kubectl delete --all services --all-namespaces || true
    
    # 실습 디렉토리 정리
    rm -rf day1-* || true
    
    log_success "Day1 실습 환경 복구 완료"
}

# Day2 실습 복구
recover_day2_practice() {
    local action="$1"
    
    log_info "Day2 실습 복구: $action"
    
    # Docker Compose 서비스 정리
    docker-compose down -v || true
    
    # 실습 디렉토리 정리
    rm -rf day2-* || true
    
    # GitHub Actions 워크플로우 정리
    rm -rf .github/workflows || true
    
    log_success "Day2 실습 환경 복구 완료"
}

# 모니터링 스택 복구
recover_monitoring_stack() {
    log_info "모니터링 스택 복구"
    
    # Docker Compose 서비스 정리
    docker-compose down -v || true
    
    # 볼륨 정리
    docker volume prune -f || true
    
    # 네트워크 정리
    docker network prune -f || true
    
    log_success "모니터링 스택 복구 완료"
}

# 리소스 정리 복구
recover_cleanup_resources() {
    log_info "리소스 정리 복구"
    
    # 로컬 Docker 리소스 정리
    docker system prune -a -f || true
    
    # Kubernetes 리소스 정리
    kubectl delete --all pods --all-namespaces || true
    kubectl delete --all services --all-namespaces || true
    kubectl delete --all deployments --all-namespaces || true
    
    log_success "리소스 정리 복구 완료"
}

# 전체 강의 시나리오 복구 실행
recover_full_lecture() {
    log_header "전체 강의 시나리오 복구 실행"
    
    # 에러 로그 초기화
    init_error_log
    
    # Day1 실습 복구 실행
    log_header "Day1 실습 복구 실행"
    retry_with_recovery "day1-practice.sh" "docker-advanced"
    retry_with_recovery "day1-practice.sh" "kubernetes-basics"
    retry_with_recovery "day1-practice.sh" "cloud-services"
    retry_with_recovery "day1-practice.sh" "monitoring-hub"
    
    # Day2 실습 복구 실행
    log_header "Day2 실습 복구 실행"
    retry_with_recovery "day2-practice.sh" "cicd-pipeline"
    retry_with_recovery "day2-practice.sh" "cloud-deployment"
    retry_with_recovery "day2-practice.sh" "monitoring-basics"
    
    # 리소스 정리 복구 실행
    log_header "리소스 정리 복구 실행"
    retry_with_recovery "cleanup-resources.sh" "all"
    
    log_success "🎉 전체 강의 시나리오 복구 완료!"
}

# 에러 로그 분석
analyze_errors() {
    log_header "에러 로그 분석"
    
    if [ -f "$ERROR_LOG" ]; then
        log_info "에러 로그 내용:"
        cat "$ERROR_LOG"
        
        log_info "에러 통계:"
        echo "총 에러 수: $(grep -c "ERROR" "$ERROR_LOG" || echo "0")"
        echo "경고 수: $(grep -c "WARNING" "$ERROR_LOG" || echo "0")"
        echo "성공 수: $(grep -c "SUCCESS" "$ERROR_LOG" || echo "0")"
    else
        log_warning "에러 로그 파일이 없습니다."
    fi
}

# 사용법 출력
usage() {
    echo "자동화 스크립트 에러 복구 유틸리티"
    echo ""
    echo "사용법:"
    echo "  $0 [옵션]"
    echo ""
    echo "옵션:"
    echo "  --recover-full, -f           # 전체 강의 시나리오 복구"
    echo "  --recover-script <스크립트> <액션>  # 특정 스크립트 복구"
    echo "  --analyze-errors, -a         # 에러 로그 분석"
    echo "  --help, -h                   # 도움말 표시"
    echo ""
    echo "예시:"
    echo "  $0 --recover-full            # 전체 복구"
    echo "  $0 --recover-script day1-practice.sh docker-advanced"
    echo "  $0 --analyze-errors          # 에러 분석"
}

# 메인 함수
main() {
    case "${1:-}" in
        "--recover-full"|"-f")
            recover_full_lecture
            ;;
        "--recover-script")
            if [ -z "${2:-}" ] || [ -z "${3:-}" ]; then
                log_error "스크립트와 액션을 지정해주세요."
                usage
                exit 1
            fi
            retry_with_recovery "$2" "$3"
            ;;
        "--analyze-errors"|"-a")
            analyze_errors
            ;;
        "--help"|"-h")
            usage
            exit 0
            ;;
        *)
            log_error "알 수 없는 옵션: $1"
            usage
            exit 1
            ;;
    esac
}

# 스크립트 실행
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
