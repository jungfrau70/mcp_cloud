#!/bin/bash

# RKE2 공통 라이브러리
# Version: 1.0.0
# Description: RKE2 모니터링 스크립트 공통 함수들

# 라이브러리 버전
RKE2_COMMON_VERSION="1.0.0"

# 기본 설정
DEFAULT_TIMEOUT=30
DEFAULT_LOG_DIR="./logs"
DEFAULT_LOG_LEVEL="INFO"
DEFAULT_RKE2_CONFIG_PATH="/etc/rancher/rke2"
DEFAULT_KUBECONFIG="/etc/rancher/rke2/rke2.yaml"

# 색상 코드 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# 공통 변수 초기화
init_common_vars() {
    export TIMEOUT="${TIMEOUT:-$DEFAULT_TIMEOUT}"
    export LOG_DIR="${LOG_DIR:-$DEFAULT_LOG_DIR}"
    export LOG_LEVEL="${LOG_LEVEL:-$DEFAULT_LOG_LEVEL}"
    export RKE2_CONFIG_PATH="${RKE2_CONFIG_PATH:-$DEFAULT_RKE2_CONFIG_PATH}"
    export KUBECONFIG="${KUBECONFIG:-$DEFAULT_KUBECONFIG}"
    
    # 로그 디렉토리 생성
    mkdir -p "${LOG_DIR}"
}

# 환경 변수 검증
validate_environment() {
    local required_vars=("KUBECONFIG")
    local missing_vars=()
    
    for var in "${required_vars[@]}"; do
        if [[ -z "${!var}" ]]; then
            missing_vars+=("$var")
        fi
    done
    
    if [[ ${#missing_vars[@]} -gt 0 ]]; then
        echo "오류: 필수 환경 변수가 설정되지 않았습니다: ${missing_vars[*]}"
        exit 1
    fi
    
    # kubectl 접근 가능 여부 확인
    if ! kubectl cluster-info &>/dev/null; then
        echo "오류: kubectl로 클러스터에 접근할 수 없습니다."
        echo "KUBECONFIG 경로를 확인하세요: $KUBECONFIG"
        exit 1
    fi
}

# 필수 도구 설치 여부 확인
check_prerequisites() {
    local required_tools=("kubectl" "jq")
    local optional_tools=("rke2" "helm" "k9s" "crictl")
    local missing_required=()
    local missing_optional=()
    
    # 필수 도구 확인
    for tool in "${required_tools[@]}"; do
        if ! command -v "$tool" &> /dev/null; then
            missing_required+=("$tool")
        fi
    done
    
    # 선택적 도구 확인
    for tool in "${optional_tools[@]}"; do
        if ! command -v "$tool" &> /dev/null; then
            missing_optional+=("$tool")
        fi
    done
    
    # 결과 보고
    if [[ ${#missing_required[@]} -gt 0 ]]; then
        log_message "오류: 필수 도구가 설치되어 있지 않습니다: ${missing_required[*]}" "ERROR"
        exit 1
    fi
    
    if [[ ${#missing_optional[@]} -gt 0 ]]; then
        log_message "경고: 선택적 도구가 설치되어 있지 않습니다: ${missing_optional[*]}" "WARNING"
    fi
    
    # RKE2 특화 확인
    if command -v rke2 &> /dev/null; then
        log_message "RKE2 버전: $(rke2 -v)" "SUCCESS"
    else
        log_message "RKE2가 설치되어 있지 않습니다 (선택적)" "WARNING"
    fi
    
    # kubectl 버전 확인
    log_message "kubectl 버전: $(kubectl version --short 2>/dev/null || echo '버전 정보 없음')" "SUCCESS"
    
    log_message "모든 필수 도구가 설치되어 있습니다" "SUCCESS"
}

# 유틸리티 함수들
get_timestamp() {
    date +%Y%m%d_%H%M%S
}

get_current_time() {
    date '+%Y-%m-%d %H:%M:%S'
}

calculate_duration() {
    local start_time="$1"
    local end_time=$(date +%s)
    echo $((end_time - start_time))
}

# 설정 파일 로드
load_config() {
    local config_file="$1"
    
    if [[ -f "$config_file" ]]; then
        source "$config_file"
        log_message "설정 파일 로드됨: $config_file" "INFO"
    else
        log_message "설정 파일을 찾을 수 없습니다: $config_file" "WARNING"
        log_message "기본 설정을 사용합니다." "INFO"
    fi
}

# 라이브러리 정보 출력
show_library_info() {
    echo "RKE2 Common Library v${RKE2_COMMON_VERSION}"
    echo "설정된 환경 변수:"
    echo "  TIMEOUT: ${TIMEOUT}"
    echo "  LOG_DIR: ${LOG_DIR}"
    echo "  LOG_LEVEL: ${LOG_LEVEL}"
    echo "  RKE2_CONFIG_PATH: ${RKE2_CONFIG_PATH}"
    echo "  KUBECONFIG: ${KUBECONFIG}"
}

# 라이브러리 초기화
init_library() {
    init_common_vars
    validate_environment
    check_prerequisites
}

# 로깅 함수 임시 정의 (lib/rke2_logging.sh에서 재정의됨)
log_message() {
    local message="$1"
    local level="${2:-INFO}"
    echo "[$level] $message"
}

# 보안 함수 임시 정의 (lib/rke2_security.sh에서 재정의됨)
mask_sensitive_info() {
    echo "$1"
}

# 모니터링 함수 임시 정의 (lib/rke2_monitoring.sh에서 재정의됨)
safe_execute() {
    local command="$1"
    eval "$command"
}
