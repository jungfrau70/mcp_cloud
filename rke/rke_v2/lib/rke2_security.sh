#!/bin/bash

# RKE2 보안 라이브러리
# Version: 1.0.0
# Description: RKE2 모니터링 스크립트 보안 함수들

# 민감 정보 마스킹 함수 (RKE2 특화 강화)
mask_sensitive_info() {
    local content="$1"
    local patterns=(
        # UUID 패턴
        's/[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/********-****-****-****-************/gi'
        
        # Base64 인코딩된 토큰/인증서
        's/[A-Za-z0-9+/]{88,90}=[A-Za-z0-9+/]*={0,2}/************************************/g'
        's/[A-Za-z0-9+/]{40,}=[A-Za-z0-9+/]*={0,2}/****************************/g'
        
        # Azure 관련 민감 정보
        's/"clientId": "[^"]*"/"clientId": "****"/g'
        's/"clientSecret": "[^"]*"/"clientSecret": "****"/g'
        's/"subscriptionId": "[^"]*"/"subscriptionId": "****"/g'
        's/"tenantId": "[^"]*"/"tenantId": "****"/g'
        's/"resourceGroup": "[^"]*"/"resourceGroup": "****"/g'
        
        # SSH 키
        's/ssh-rsa [A-Za-z0-9+/]+[=]*/ssh-rsa ****/g'
        's/ssh-ed25519 [A-Za-z0-9+/]+[=]*/ssh-ed25519 ****/g'
        
        # 일반적인 민감 정보
        's/password[=:][ ]*[^ ]*\b/password: ****/gi'
        's/secret[=:][ ]*[^ ]*\b/secret: ****/gi'
        's/token[=:][ ]*[^ ]*\b/token: ****/gi'
        's/key[=:][ ]*[^ ]*\b/key: ****/gi'
        's/credential[=:][ ]*[^ ]*\b/credential: ****/gi'
        
        # RKE2 특화 민감 정보
        's/"clusterSecret": "[^"]*"/"clusterSecret": "****"/g'
        's/"serviceAccountToken": "[^"]*"/"serviceAccountToken": "****"/g'
        's/"caCert": "[^"]*"/"caCert": "****"/g'
        's/"clientCert": "[^"]*"/"clientCert": "****"/g'
        's/"clientKey": "[^"]*"/"clientKey": "****"/g'
        
        # etcd 관련 민감 정보
        's/"etcdKey": "[^"]*"/"etcdKey": "****"/g'
        's/"etcdCert": "[^"]*"/"etcdCert": "****"/g'
        
        # containerd 관련 민감 정보
        's/"registryPassword": "[^"]*"/"registryPassword": "****"/g'
        's/"registryUsername": "[^"]*"/"registryUsername": "****"/g'
        
        # 네트워크 관련 민감 정보
        's/"wireguardKey": "[^"]*"/"wireguardKey": "****"/g'
        's/"vpnKey": "[^"]*"/"vpnKey": "****"/g'
    )
    
    local masked_content="$content"
    for pattern in "${patterns[@]}"; do
        masked_content=$(echo "$masked_content" | sed -E "$pattern")
    done
    
    echo "$masked_content"
}

# 명령어 검증 함수
validate_command() {
    local command="$1"
    
    # 기본적인 인젝션 방지
    if [[ "$command" =~ [\&\|\`\;] ]]; then
        log_message "잠재적 위험한 명령어 감지: $command" "ERROR"
        return 1
    fi
    
    # 허용된 명령어 패턴 확인
    local allowed_patterns=(
        "^kubectl "
        "^rke2 "
        "^crictl "
        "^systemctl "
        "^journalctl "
        "^ps "
        "^grep "
        "^awk "
        "^sed "
        "^jq "
        "^ls "
        "^cat "
        "^du "
        "^df "
        "^free "
        "^uptime "
        "^ss "
        "^getenforce "
        "^firewall-cmd "
        "^sysctl "
        "^sestatus "
        "^aa-status "
    )
    
    local is_allowed=false
    for pattern in "${allowed_patterns[@]}"; do
        if [[ "$command" =~ $pattern ]]; then
            is_allowed=true
            break
        fi
    done
    
    if [[ "$is_allowed" == "false" ]]; then
        log_message "허용되지 않은 명령어: $command" "ERROR"
        return 1
    fi
    
    return 0
}

# 파일 권한 검증
validate_file_permissions() {
    local file_path="$1"
    local expected_permissions="$2"
    
    if [[ ! -f "$file_path" ]]; then
        log_message "파일이 존재하지 않습니다: $file_path" "ERROR"
        return 1
    fi
    
    local actual_permissions=$(stat -c %a "$file_path" 2>/dev/null || stat -f %Lp "$file_path" 2>/dev/null)
    
    if [[ "$actual_permissions" != "$expected_permissions" ]]; then
        log_message "파일 권한이 올바르지 않습니다: $file_path (예상: $expected_permissions, 실제: $actual_permissions)" "WARNING"
        return 1
    fi
    
    return 0
}

# 디렉토리 권한 검증
validate_directory_permissions() {
    local dir_path="$1"
    local expected_permissions="$2"
    
    if [[ ! -d "$dir_path" ]]; then
        log_message "디렉토리가 존재하지 않습니다: $dir_path" "ERROR"
        return 1
    fi
    
    local actual_permissions=$(stat -c %a "$dir_path" 2>/dev/null || stat -f %Lp "$dir_path" 2>/dev/null)
    
    if [[ "$actual_permissions" != "$expected_permissions" ]]; then
        log_message "디렉토리 권한이 올바르지 않습니다: $dir_path (예상: $expected_permissions, 실제: $actual_permissions)" "WARNING"
        return 1
    fi
    
    return 0
}

# 인증서 만료 확인
check_certificate_expiry() {
    local cert_file="$1"
    local days_warning="${2:-30}"
    
    if [[ ! -f "$cert_file" ]]; then
        log_message "인증서 파일이 존재하지 않습니다: $cert_file" "ERROR"
        return 1
    fi
    
    local expiry_date=$(openssl x509 -in "$cert_file" -noout -enddate 2>/dev/null | cut -d= -f2)
    if [[ -z "$expiry_date" ]]; then
        log_message "인증서 만료일을 확인할 수 없습니다: $cert_file" "WARNING"
        return 1
    fi
    
    local expiry_timestamp=$(date -d "$expiry_date" +%s 2>/dev/null)
    local current_timestamp=$(date +%s)
    local days_until_expiry=$(( (expiry_timestamp - current_timestamp) / 86400 ))
    
    if [[ $days_until_expiry -lt 0 ]]; then
        log_message "인증서가 만료되었습니다: $cert_file (만료일: $expiry_date)" "ERROR"
        return 1
    elif [[ $days_until_expiry -lt $days_warning ]]; then
        log_message "인증서가 곧 만료됩니다: $cert_file (만료일: $expiry_date, 남은 일수: $days_until_expiry)" "WARNING"
        return 1
    else
        log_message "인증서가 유효합니다: $cert_file (만료일: $expiry_date, 남은 일수: $days_until_expiry)" "SUCCESS"
        return 0
    fi
}

# RKE2 보안 설정 검증
validate_rke2_security() {
    log_message "RKE2 보안 설정 검증 시작" "SECTION"
    
    # 설정 파일 권한 확인
    validate_file_permissions "${RKE2_CONFIG_PATH}/config.yaml" "600"
    
    # 인증서 디렉토리 권한 확인
    validate_directory_permissions "${RKE2_CONFIG_PATH}/server/tls" "700"
    
    # 주요 인증서 만료 확인
    local cert_files=(
        "${RKE2_CONFIG_PATH}/server/tls/server-ca.crt"
        "${RKE2_CONFIG_PATH}/server/tls/client-ca.crt"
        "${RKE2_CONFIG_PATH}/server/tls/request-header-ca.crt"
    )
    
    for cert_file in "${cert_files[@]}"; do
        if [[ -f "$cert_file" ]]; then
            check_certificate_expiry "$cert_file" 30
        fi
    done
    
    # SELinux 상태 확인
    if command -v getenforce &>/dev/null; then
        local selinux_status=$(getenforce)
        if [[ "$selinux_status" == "Enforcing" ]]; then
            log_message "SELinux가 활성화되어 있습니다: $selinux_status" "SUCCESS"
        else
            log_message "SELinux가 비활성화되어 있습니다: $selinux_status" "WARNING"
        fi
    fi
    
    # 방화벽 상태 확인
    if command -v firewall-cmd &>/dev/null; then
        local firewall_status=$(firewall-cmd --state 2>/dev/null)
        if [[ "$firewall_status" == "running" ]]; then
            log_message "방화벽이 활성화되어 있습니다: $firewall_status" "SUCCESS"
        else
            log_message "방화벽이 비활성화되어 있습니다: $firewall_status" "WARNING"
        fi
    fi
    
    log_message "" "SECTION_END"
}

# 보안 감사 로그 생성
create_security_audit_log() {
    local audit_file="${LOG_DIR}/security_audit_$(get_timestamp).log"
    
    {
        echo "=== RKE2 보안 감사 로그 ==="
        echo "감사 시각: $(get_current_time)"
        echo "호스트명: $(hostname)"
        echo "사용자: $(whoami)"
        echo "KUBECONFIG: $KUBECONFIG"
        echo "RKE2_CONFIG_PATH: $RKE2_CONFIG_PATH"
        echo ""
        
        # 파일 권한 정보
        echo "=== 파일 권한 정보 ==="
        ls -la "${RKE2_CONFIG_PATH}/" 2>/dev/null || echo "설정 디렉토리 접근 불가"
        echo ""
        
        # 인증서 정보
        echo "=== 인증서 정보 ==="
        find "${RKE2_CONFIG_PATH}/server/tls" -name "*.crt" -exec openssl x509 -in {} -noout -subject -dates \; 2>/dev/null || echo "인증서 정보 조회 불가"
        echo ""
        
        # 프로세스 정보
        echo "=== RKE2 프로세스 정보 ==="
        ps aux | grep -E "rke2|containerd" | grep -v grep || echo "RKE2 프로세스 없음"
        
    } > "$audit_file"
    
    log_message "보안 감사 로그가 생성되었습니다: $audit_file" "INFO"
}
