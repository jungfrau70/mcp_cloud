#!/bin/bash

# RKE2 플랫폼 점검 스크립트 (모듈화 버전)
# Version: 2.0.0
# Description: RKE2 플랫폼 레벨 진단 (공통 라이브러리 사용)

# 스크립트 정보
SCRIPT_NAME="rke2_check"
SCRIPT_VERSION="2.0.0"
SCRIPT_DESCRIPTION="RKE2 플랫폼 레벨 진단"

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
ENV_FILE="${SCRIPT_DIR}/rke2_check.env"

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
    
    log_message "=== RKE2 플랫폼 점검 시작 ===" "SECTION"
    log_message "스크립트 버전: $SCRIPT_VERSION" "INFO"
    log_message "설정 파일: $CONFIG_FILE" "INFO"
    log_message "로그 디렉토리: $LOG_DIR" "INFO"
    
    # 점검 실행
    run_platform_checks
    
    # 실행 시간 계산
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    log_message "=== RKE2 플랫폼 점검 완료 ===" "SECTION"
    log_message "소요 시간: ${duration}초" "INFO"
    log_message "로그 파일: $LOG_FILE" "INFO"
    log_message "HTML 보고서: $HTML_LOG_FILE" "INFO"
    
    # HTML 파일 완성
    finish_html
}

# 플랫폼 점검 실행
run_platform_checks() {
    log_message "플랫폼 점검 실행" "SECTION"
    
    # 클러스터 구성 점검
    if is_check_enabled "platform" "cluster_config"; then
        check_cluster_config
    fi
    
    # 노드 역할 점검
    if is_check_enabled "platform" "node_roles"; then
        check_node_roles
    fi
    
    # 네트워크 점검
    if is_check_enabled "platform" "network"; then
        check_network
    fi
    
    # 스토리지 점검
    if is_check_enabled "platform" "storage"; then
        check_storage
    fi
    
    # 메트릭 점검
    if is_check_enabled "platform" "metrics"; then
        check_metrics
    fi
    
    # 보안 점검
    if is_check_enabled "platform" "security"; then
        check_security
    fi
    
    # 모니터링 점검
    if is_check_enabled "platform" "monitoring"; then
        check_monitoring
    fi
    
    # 서비스 체크 추가
    if is_check_enabled "platform" "service_checks"; then
        run_service_checks
    fi
    
    log_message "" "SECTION_END"
}

# 클러스터 구성 점검
check_cluster_config() {
    log_message "클러스터 구성 점검" "SECTION"
    safe_execute "kubectl cluster-info"
    safe_execute "kubectl get nodes -o wide"
    safe_execute "kubectl get namespaces"
    log_message "" "SECTION_END"
}

# 노드 역할 점검
check_node_roles() {
    log_message "노드 역할 점검" "SECTION"
    safe_execute "kubectl get nodes --show-labels"
    
    # 역할별 노드 확인
    local roles=("master" "worker" "oss")
    for role in "${roles[@]}"; do
        local nodes=$(kubectl get nodes -l node-role.kubernetes.io/$role= -o jsonpath='{.items[*].metadata.name}')
        if [[ -n "$nodes" ]]; then
            log_message "[$role 노드: $nodes]"
            for node in $nodes; do
                safe_execute "kubectl describe node $node"
            done
        else
            log_message "[$role 노드 없음]"
        fi
    done
    log_message "" "SECTION_END"
}

# 네트워크 점검
check_network() {
    log_message "네트워크 점검" "SECTION"
    safe_execute "kubectl get svc -A"
    safe_execute "kubectl get endpoints -A"
    safe_execute "kubectl get networkpolicy -A"
    log_message "" "SECTION_END"
}

# 스토리지 점검
check_storage() {
    log_message "스토리지 점검" "SECTION"
    safe_execute "kubectl get storageclass"
    safe_execute "kubectl get pv"
    safe_execute "kubectl get pvc -A"
    log_message "" "SECTION_END"
}

# 메트릭 점검
check_metrics() {
    log_message "메트릭 점검" "SECTION"
    if kubectl top nodes &>/dev/null; then
        safe_execute "kubectl top nodes"
        safe_execute "kubectl top pods -A"
    else
        log_message "메트릭 서버가 활성화되어 있지 않습니다" "WARNING"
    fi
    log_message "" "SECTION_END"
}

# 보안 점검
check_security() {
    log_message "보안 점검" "SECTION"
    safe_execute "kubectl get pods -A -o jsonpath='{range .items[*]}{.metadata.namespace}{\"\\t\"}{.metadata.name}{\"\\t\"}{.spec.securityContext.runAsNonRoot}{\"\\n\"}{end}'"
    safe_execute "kubectl get networkpolicy -A"
    log_message "" "SECTION_END"
}

# 모니터링 점검
check_monitoring() {
    log_message "모니터링 점검" "SECTION"
    safe_execute "kubectl get pods -n monitoring 2>/dev/null || echo 'monitoring 네임스페이스 없음'"
    safe_execute "kubectl get pods -n logging 2>/dev/null || echo 'logging 네임스페이스 없음'"
    log_message "" "SECTION_END"
}

# 사용법 출력
show_usage() {
    cat << EOF
RKE2 플랫폼 점검 스크립트 v${SCRIPT_VERSION}

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
    - 로그 파일: ${LOG_DIR}/rke2_check_YYYYMMDD_HHMMSS.log
    - HTML 보고서: ${LOG_DIR}/rke2_check_YYYYMMDD_HHMMSS.html

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
                echo "RKE2 플랫폼 점검 스크립트 v${SCRIPT_VERSION}"
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
