#!/bin/bash

# RKE2 24x7 모니터링 스크립트 (모듈화 버전)
# Version: 2.0.0
# Description: RKE2 클러스터 24x7 모니터링 (공통 라이브러리 사용)

# 스크립트 정보
SCRIPT_NAME="24x7_rke2_check"
SCRIPT_VERSION="2.0.0"
SCRIPT_DESCRIPTION="RKE2 클러스터 24x7 모니터링"

# 라이브러리 경로 설정
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="${SCRIPT_DIR}/lib"
CONFIG_DIR="${SCRIPT_DIR}/config"

# 공통 라이브러리 로드
source "${LIB_DIR}/rke2_common.sh"
source "${LIB_DIR}/rke2_logging.sh"
source "${LIB_DIR}/rke2_security.sh"
source "${LIB_DIR}/rke2_monitoring.sh"
source "${LIB_DIR}/rke2_config.sh"

# 설정 파일 경로
CONFIG_FILE="${CONFIG_DIR}/rke2-monitoring.yaml"
ENV_FILE="${SCRIPT_DIR}/24x7_rke2_check.env"

# 메인 함수
main() {
    local start_time=$(date +%s)
    
    # 라이브러리 초기화
    init_library
    
    # 설정 초기화
    if ! init_config "$CONFIG_FILE"; then
        log_message "설정 초기화에 실패했습니다." "ERROR"
        exit 1
    fi
    
    # 환경 변수 파일 로드 (선택사항)
    if [[ -f "$ENV_FILE" ]]; then
        source "$ENV_FILE"
        log_message "환경 변수 파일이 로드되었습니다: $ENV_FILE" "INFO"
    fi
    
    # 로그 파일 초기화
    init_log_files "$SCRIPT_NAME"
    
    log_message "=== RKE2 24x7 모니터링 시작 ===" "SECTION"
    log_message "스크립트 버전: $SCRIPT_VERSION" "INFO"
    log_message "설정 파일: $CONFIG_FILE" "INFO"
    log_message "로그 디렉토리: $LOG_DIR" "INFO"
    
    # 점검 실행
    run_24x7_checks
    
    # 실행 시간 계산
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    log_message "=== RKE2 24x7 모니터링 완료 ===" "SECTION"
    log_message "소요 시간: ${duration}초" "INFO"
    log_message "로그 파일: $LOG_FILE" "INFO"
    log_message "HTML 보고서: $HTML_LOG_FILE" "INFO"
    
    # HTML 파일 완성
    finish_html
}

# 24x7 점검 실행
run_24x7_checks() {
    log_message "24x7 모니터링 점검 실행" "SECTION"
    
    # 기본 점검들
    if is_check_enabled "24x7" "cluster_info"; then
        check_cluster_info
    fi
    
    if is_check_enabled "24x7" "control_plane"; then
        check_control_plane
    fi
    
    if is_check_enabled "24x7" "node_overview"; then
        check_node_overview
    fi
    
    if is_check_enabled "24x7" "role_nodes"; then
        check_role_nodes
    fi
    
    if is_check_enabled "24x7" "namespace_pod"; then
        check_namespace_pod
    fi
    
    if is_check_enabled "24x7" "storage_infra"; then
        check_storage_infra
    fi
    
    if is_check_enabled "24x7" "oss_tools"; then
        check_oss_tools
    fi
    
    if is_check_enabled "24x7" "system"; then
        check_system
    fi
    
    # RKE2 특화 점검들
    if is_check_enabled "24x7" "rke2_specific"; then
        check_rke2_specific
    fi
    
    if is_check_enabled "24x7" "rke2_etcd"; then
        check_rke2_etcd
    fi
    
    if is_check_enabled "24x7" "rke2_containerd"; then
        check_rke2_containerd
    fi
    
    if is_check_enabled "24x7" "rke2_security"; then
        check_rke2_security
    fi
    
    if is_check_enabled "24x7" "rke2_logs"; then
        check_rke2_logs
    fi
    
    log_message "" "SECTION_END"
}

# 사용법 출력
show_usage() {
    cat << EOF
RKE2 24x7 모니터링 스크립트 v${SCRIPT_VERSION}

사용법:
    $0 [옵션]

옵션:
    -c, --config FILE     설정 파일 경로 (기본: ${CONFIG_FILE})
    -e, --env FILE        환경 변수 파일 경로 (기본: ${ENV_FILE})
    -v, --version         버전 정보 출력
    -h, --help           이 도움말 출력

예제:
    $0                                    # 기본 설정으로 실행
    $0 -c /path/to/config.yaml           # 사용자 정의 설정 파일 사용
    $0 -e /path/to/env.file              # 사용자 정의 환경 변수 파일 사용

설정 파일:
    YAML 형식의 설정 파일을 사용하여 점검 범위와 옵션을 제어할 수 있습니다.
    기본 설정 파일: ${CONFIG_FILE}

환경 변수:
    환경 변수 파일을 통해 런타임 설정을 오버라이드할 수 있습니다.
    기본 환경 변수 파일: ${ENV_FILE}

출력:
    - 로그 파일: ${LOG_DIR}/24x7_rke2_check_YYYYMMDD_HHMMSS.log
    - HTML 보고서: ${LOG_DIR}/24x7_rke2_check_YYYYMMDD_HHMMSS.html

EOF
}

# 명령행 인수 처리
parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -c|--config)
                CONFIG_FILE="$2"
                shift 2
                ;;
            -e|--env)
                ENV_FILE="$2"
                shift 2
                ;;
            -v|--version)
                echo "RKE2 24x7 모니터링 스크립트 v${SCRIPT_VERSION}"
                exit 0
                ;;
            -h|--help)
                show_usage
                exit 0
                ;;
            *)
                log_message "알 수 없는 옵션: $1" "ERROR"
                show_usage
                exit 1
                ;;
        esac
    done
}

# 스크립트 시작
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    # 명령행 인수 처리
    parse_arguments "$@"
    
    # 메인 함수 실행
    main "$@"
fi
