#!/bin/bash

# RKE2 설정 파일 파서 라이브러리
# Version: 1.0.0
# Description: YAML 설정 파일을 파싱하는 함수들

# YAML 설정 파일 로드
load_yaml_config() {
    local config_file="$1"
    
    if [[ ! -f "$config_file" ]]; then
        log_message "설정 파일을 찾을 수 없습니다: $config_file" "WARNING"
        return 1
    fi
    
    # jq가 설치되어 있는지 확인
    if ! command -v jq &>/dev/null; then
        log_message "jq가 설치되어 있지 않아 YAML 설정을 파싱할 수 없습니다." "ERROR"
        return 1
    fi
    
    # YAML을 JSON으로 변환 (yq 또는 python 사용)
    local json_config
    if command -v yq &>/dev/null; then
        json_config=$(yq eval -o=json "$config_file" 2>/dev/null)
    elif command -v python3 &>/dev/null; then
        json_config=$(python3 -c "
import yaml
import json
import sys
try:
    with open('$config_file', 'r') as f:
        data = yaml.safe_load(f)
    print(json.dumps(data))
except Exception as e:
    print('Error: ' + str(e), file=sys.stderr)
    sys.exit(1)
" 2>/dev/null)
    else
        log_message "YAML 파서(yq 또는 python3)가 설치되어 있지 않습니다." "ERROR"
        return 1
    fi
    
    if [[ $? -ne 0 ]]; then
        log_message "YAML 설정 파일 파싱에 실패했습니다: $config_file" "ERROR"
        return 1
    fi
    
    # JSON을 환경 변수로 변환
    parse_json_to_env "$json_config"
    
    log_message "YAML 설정 파일이 로드되었습니다: $config_file" "SUCCESS"
    return 0
}

# JSON을 환경 변수로 변환
parse_json_to_env() {
    local json_data="$1"
    local prefix="${2:-}"
    
    # jq를 사용하여 JSON을 파싱하고 환경 변수로 설정
    local keys=$(echo "$json_data" | jq -r 'paths | join(".")' 2>/dev/null)
    
    for key in $keys; do
        local value=$(echo "$json_data" | jq -r ".$key" 2>/dev/null)
        
        # null 값은 건너뛰기
        if [[ "$value" != "null" ]]; then
            local env_var_name="${prefix}${key//./_}"
            export "$env_var_name"="$value"
        fi
    done
}

# 설정 값 가져오기
get_config_value() {
    local key="$1"
    local default_value="${2:-}"
    
    # 환경 변수에서 값 찾기
    local env_var_name="${key//./_}"
    local value="${!env_var_name}"
    
    if [[ -n "$value" ]]; then
        echo "$value"
    else
        echo "$default_value"
    fi
}

# 설정 섹션 활성화 여부 확인
is_check_enabled() {
    local check_type="$1"
    local check_name="$2"
    
    local enabled=$(get_config_value "checks.${check_type}.${check_name}" "true")
    
    if [[ "$enabled" == "true" ]]; then
        return 0
    else
        return 1
    fi
}

# 기본 설정 적용
apply_default_config() {
    # 기본값 설정
    export TIMEOUT="${TIMEOUT:-$(get_config_value 'defaults.timeout' '30')}"
    export LOG_DIR="${LOG_DIR:-$(get_config_value 'defaults.log_dir' "${SCRIPT_DIR}/logs")}"
    export LOG_LEVEL="${LOG_LEVEL:-$(get_config_value 'defaults.log_level' 'INFO')}"
    export RETENTION_DAYS="${RETENTION_DAYS:-$(get_config_value 'defaults.retention_days' '30')}"
    
    # RKE2 설정
    export RKE2_CONFIG_PATH="${RKE2_CONFIG_PATH:-$(get_config_value 'rke2.config_path' '/etc/rancher/rke2')}"
    export RKE2_DATA_DIR="${RKE2_DATA_DIR:-$(get_config_value 'rke2.data_dir' '/var/lib/rancher/rke2')}"
    export RKE2_ETCD_DIR="${RKE2_ETCD_DIR:-$(get_config_value 'rke2.etcd_dir' '/var/lib/rancher/rke2/server/tls/etcd')}"
    export KUBECONFIG="${KUBECONFIG:-$(get_config_value 'rke2.kubeconfig' '/etc/rancher/rke2/rke2.yaml')}"
    
    # 모니터링 설정
    export ENABLE_METRICS="${ENABLE_METRICS:-$(get_config_value 'monitoring.enable_metrics' 'true')}"
    export ENABLE_LOGS="${ENABLE_LOGS:-$(get_config_value 'monitoring.enable_logs' 'true')}"
    export ENABLE_SECURITY_CHECKS="${ENABLE_SECURITY_CHECKS:-$(get_config_value 'monitoring.enable_security_checks' 'true')}"
    export ENABLE_ETCD_CHECKS="${ENABLE_ETCD_CHECKS:-$(get_config_value 'monitoring.enable_etcd_checks' 'true')}"
    export ENABLE_CONTAINERD_CHECKS="${ENABLE_CONTAINERD_CHECKS:-$(get_config_value 'monitoring.enable_containerd_checks' 'true')}"
    
    # 보안 설정
    export MASK_SENSITIVE_INFO="${MASK_SENSITIVE_INFO:-$(get_config_value 'security.mask_sensitive_info' 'true')}"
    export ENABLE_AUDIT_LOGS="${ENABLE_AUDIT_LOGS:-$(get_config_value 'security.enable_audit_logs' 'true')}"
    export VALIDATE_COMMANDS="${VALIDATE_COMMANDS:-$(get_config_value 'security.validate_commands' 'true')}"
    export CHECK_FILE_PERMISSIONS="${CHECK_FILE_PERMISSIONS:-$(get_config_value 'security.check_file_permissions' 'true')}"
    export CHECK_CERTIFICATE_EXPIRY="${CHECK_CERTIFICATE_EXPIRY:-$(get_config_value 'security.check_certificate_expiry' 'true')}"
    export CERTIFICATE_WARNING_DAYS="${CERTIFICATE_WARNING_DAYS:-$(get_config_value 'security.certificate_warning_days' '30')}"
    
    # 성능 설정
    export MAX_RETRIES="${MAX_RETRIES:-$(get_config_value 'performance.max_retries' '2')}"
    export RETRY_DELAY="${RETRY_DELAY:-$(get_config_value 'performance.retry_delay' '2')}"
    export PARALLEL_EXECUTION="${PARALLEL_EXECUTION:-$(get_config_value 'performance.parallel_execution' 'false')}"
    export MAX_PARALLEL_JOBS="${MAX_PARALLEL_JOBS:-$(get_config_value 'performance.max_parallel_jobs' '5')}"
    
    # 로깅 설정
    export ENABLE_HTML_REPORTS="${ENABLE_HTML_REPORTS:-$(get_config_value 'logging.enable_html_reports' 'true')}"
    export ENABLE_SUMMARY="${ENABLE_SUMMARY:-$(get_config_value 'logging.enable_summary' 'true')}"
    export LOG_ROTATION="${LOG_ROTATION:-$(get_config_value 'logging.log_rotation' 'true')}"
    export COMPRESS_OLD_LOGS="${COMPRESS_OLD_LOGS:-$(get_config_value 'logging.compress_old_logs' 'true')}"
    export MAX_LOG_SIZE_MB="${MAX_LOG_SIZE_MB:-$(get_config_value 'logging.max_log_size_mb' '100')}"
    
    # 알림 설정
    export SLACK_WEBHOOK_URL="${SLACK_WEBHOOK_URL:-$(get_config_value 'alerts.slack_webhook_url' '')}"
    export EMAIL_RECIPIENTS="${EMAIL_RECIPIENTS:-$(get_config_value 'alerts.email_recipients' '')}"
    export ALERT_LEVEL="${ALERT_LEVEL:-$(get_config_value 'alerts.alert_level' 'WARNING')}"
    export ENABLE_NOTIFICATIONS="${ENABLE_NOTIFICATIONS:-$(get_config_value 'alerts.enable_notifications' 'false')}"
    
    # Azure 설정
    export AZURE_SUBSCRIPTION_ID="${AZURE_SUBSCRIPTION_ID:-$(get_config_value 'azure.subscription_id' '')}"
    export AZURE_RESOURCE_GROUP="${AZURE_RESOURCE_GROUP:-$(get_config_value 'azure.resource_group' '')}"
    export AZURE_LOCATION="${AZURE_LOCATION:-$(get_config_value 'azure.location' '')}"
    export ENABLE_AZURE_CHECKS="${ENABLE_AZURE_CHECKS:-$(get_config_value 'azure.enable_azure_checks' 'false')}"
}

# 설정 검증
validate_config() {
    local errors=()
    
    # 필수 설정 확인
    if [[ -z "$KUBECONFIG" ]]; then
        errors+=("KUBECONFIG가 설정되지 않았습니다.")
    fi
    
    if [[ -z "$RKE2_CONFIG_PATH" ]]; then
        errors+=("RKE2_CONFIG_PATH가 설정되지 않았습니다.")
    fi
    
    if [[ -z "$LOG_DIR" ]]; then
        errors+=("LOG_DIR가 설정되지 않았습니다.")
    fi
    
    # 설정 값 검증
    if [[ ! "$TIMEOUT" =~ ^[0-9]+$ ]] || [[ "$TIMEOUT" -lt 1 ]]; then
        errors+=("TIMEOUT은 1 이상의 정수여야 합니다.")
    fi
    
    if [[ ! "$MAX_RETRIES" =~ ^[0-9]+$ ]] || [[ "$MAX_RETRIES" -lt 0 ]]; then
        errors+=("MAX_RETRIES는 0 이상의 정수여야 합니다.")
    fi
    
    if [[ ! "$RETENTION_DAYS" =~ ^[0-9]+$ ]] || [[ "$RETENTION_DAYS" -lt 1 ]]; then
        errors+=("RETENTION_DAYS는 1 이상의 정수여야 합니다.")
    fi
    
    # 오류가 있으면 출력하고 종료
    if [[ ${#errors[@]} -gt 0 ]]; then
        log_message "설정 검증 오류:" "ERROR"
        for error in "${errors[@]}"; do
            log_message "  - $error" "ERROR"
        done
        return 1
    fi
    
    log_message "설정 검증이 완료되었습니다." "SUCCESS"
    return 0
}

# 설정 정보 출력
show_config_info() {
    echo "=== RKE2 모니터링 설정 정보 ==="
    echo "기본 설정:"
    echo "  TIMEOUT: ${TIMEOUT}"
    echo "  LOG_DIR: ${LOG_DIR}"
    echo "  LOG_LEVEL: ${LOG_LEVEL}"
    echo "  RETENTION_DAYS: ${RETENTION_DAYS}"
    echo ""
    echo "RKE2 설정:"
    echo "  RKE2_CONFIG_PATH: ${RKE2_CONFIG_PATH}"
    echo "  RKE2_DATA_DIR: ${RKE2_DATA_DIR}"
    echo "  KUBECONFIG: ${KUBECONFIG}"
    echo ""
    echo "모니터링 설정:"
    echo "  ENABLE_METRICS: ${ENABLE_METRICS}"
    echo "  ENABLE_LOGS: ${ENABLE_LOGS}"
    echo "  ENABLE_SECURITY_CHECKS: ${ENABLE_SECURITY_CHECKS}"
    echo ""
    echo "보안 설정:"
    echo "  MASK_SENSITIVE_INFO: ${MASK_SENSITIVE_INFO}"
    echo "  ENABLE_AUDIT_LOGS: ${ENABLE_AUDIT_LOGS}"
    echo "  VALIDATE_COMMANDS: ${VALIDATE_COMMANDS}"
    echo ""
    echo "성능 설정:"
    echo "  MAX_RETRIES: ${MAX_RETRIES}"
    echo "  RETRY_DELAY: ${RETRY_DELAY}"
    echo "  PARALLEL_EXECUTION: ${PARALLEL_EXECUTION}"
    echo ""
}

# 설정 초기화
init_config() {
    local config_file="$1"
    
    # YAML 설정 파일 로드
    if [[ -n "$config_file" ]]; then
        load_yaml_config "$config_file"
    fi
    
    # 기본 설정 적용
    apply_default_config
    
    # 설정 검증
    if ! validate_config; then
        return 1
    fi
    
    # 설정 정보 출력 (DEBUG 레벨에서만)
    if [[ "$LOG_LEVEL" == "DEBUG" ]]; then
        show_config_info
    fi
    
    return 0
}
