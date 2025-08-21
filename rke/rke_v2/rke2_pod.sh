#!/bin/bash

# RKE2 파드 점검 스크립트 (모듈화 버전)
# Version: 2.0.0
# Description: RKE2 파드 레벨 진단 (공통 라이브러리 사용)

# 스크립트 정보
SCRIPT_NAME="rke2_pod"
SCRIPT_VERSION="2.0.0"
SCRIPT_DESCRIPTION="RKE2 파드 레벨 진단"

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
ENV_FILE="${SCRIPT_DIR}/rke2_pod.env"

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
    
    log_message "=== RKE2 파드 점검 시작 ===" "SECTION"
    log_message "스크립트 버전: $SCRIPT_VERSION" "INFO"
    log_message "설정 파일: $CONFIG_FILE" "INFO"
    log_message "로그 디렉토리: $LOG_DIR" "INFO"
    log_message "점검 네임스페이스: ${NAMESPACE:-'전체'}" "INFO"
    
    # 네임스페이스 목록 가져오기
    local namespaces=($(get_namespaces))
    
    if [[ ${#namespaces[@]} -eq 0 ]]; then
        log_message "오류: 검사할 네임스페이스가 없습니다." "ERROR"
        exit 1
    fi
    
    # 통계 변수
    local total_pods=0
    local running_pods=0
    local problem_pods=0
    
    # 각 네임스페이스별 점검
    for namespace in "${namespaces[@]}"; do
        log_message "네임스페이스: ${namespace}" "SECTION"
        
        # 파드 수 계산
        local ns_pods=$(kubectl get pods -n "${namespace}" --no-headers 2>/dev/null | wc -l)
        local ns_running=$(kubectl get pods -n "${namespace}" --no-headers 2>/dev/null | grep "Running\|Completed" | wc -l)
        local ns_problems=$((ns_pods - ns_running))
        
        total_pods=$((total_pods + ns_pods))
        running_pods=$((running_pods + ns_running))
        problem_pods=$((problem_pods + ns_problems))
        
        # 파드 점검 실행
        run_pod_checks "$namespace"
        
        log_message "" "SECTION_END"
    done
    
    # 요약 정보 추가
    if [[ "$ENABLE_SUMMARY" == "true" ]]; then
        add_summary "$total_pods" "$running_pods" "$problem_pods" "${namespaces[*]}"
    fi
    
    # 실행 시간 계산
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    log_message "=== RKE2 파드 점검 완료 ===" "SECTION"
    log_message "소요 시간: ${duration}초" "INFO"
    log_message "전체 파드: $total_pods, 정상: $running_pods, 문제: $problem_pods" "INFO"
    log_message "로그 파일: $LOG_FILE" "INFO"
    log_message "HTML 보고서: $HTML_LOG_FILE" "INFO"
    
    # HTML 파일 완성
    finish_html
}

# 파드 점검 실행
run_pod_checks() {
    local namespace="$1"
    
    # 파드 상태 점검
    if is_check_enabled "pod" "pod_status"; then
        check_pod_status "$namespace"
    fi
    
    # 파드 리소스 점검
    if is_check_enabled "pod" "pod_resources"; then
        check_pod_resources "$namespace"
    fi
    
    # 파드 네트워킹 점검
    if is_check_enabled "pod" "pod_networking"; then
        check_pod_networking "$namespace"
    fi
    
    # 파드 볼륨 점검
    if is_check_enabled "pod" "pod_volumes"; then
        check_pod_volumes "$namespace"
    fi
    
    # 파드 로그 점검
    if is_check_enabled "pod" "pod_logs"; then
        check_pod_logs "$namespace"
    fi
    
    # RKE2 파드 보안 점검
    if is_check_enabled "pod" "pod_security"; then
        check_rke2_pod_security "$namespace"
    fi
    
    # RKE2 containerd 컨테이너 점검
    if is_check_enabled "pod" "pod_containerd"; then
        check_rke2_pod_containerd "$namespace"
    fi
    
    # 서비스 체크 추가 (해당 네임스페이스의 서비스만)
    if is_check_enabled "pod" "service_checks"; then
        check_namespace_services "$namespace"
    fi
}

# 사용법 출력
show_usage() {
    cat << EOF
RKE2 파드 점검 스크립트 v${SCRIPT_VERSION}

사용법:
    $0 [옵션]

옵션:
    -c, --config FILE     설정 파일 경로 (기본: ${CONFIG_FILE})
    -e, --env FILE        환경 변수 파일 경로 (기본: ${ENV_FILE})
    -n, --namespace NS    점검할 네임스페이스 (기본: 전체)
    -v, --version         버전 정보 출력
    -h, --help           이 도움말 출력

예제:
    $0                                    # 기본 설정으로 실행
    $0 -c /path/to/config.yaml           # 사용자 정의 설정 파일 사용
    $0 -e /path/to/env.file              # 사용자 정의 환경 변수 파일 사용
    $0 -n kube-system                    # 특정 네임스페이스만 점검

설정 파일:
    YAML 형식의 설정 파일을 사용하여 점검 범위와 옵션을 제어할 수 있습니다.
    기본 설정 파일: ${CONFIG_FILE}

환경 변수:
    환경 변수 파일을 통해 런타임 설정을 오버라이드할 수 있습니다.
    기본 환경 변수 파일: ${ENV_FILE}

출력:
    - 로그 파일: ${LOG_DIR}/rke2_pod_YYYYMMDD_HHMMSS.log
    - HTML 보고서: ${LOG_DIR}/rke2_pod_YYYYMMDD_HHMMSS.html

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
            -n|--namespace)
                export NAMESPACE="$2"
                shift 2
                ;;
            -v|--version)
                echo "RKE2 파드 점검 스크립트 v${SCRIPT_VERSION}"
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
