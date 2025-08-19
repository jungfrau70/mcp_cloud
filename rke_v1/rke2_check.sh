#!/bin/bash



# RKE2 플랫폼 점검 스크립트 (2차 기술지원/운영 진단용)

# (Azure VM + RHEL9 OS + RKE2 설치형 클러스터 환경)



# 환경 변수 파일 로드 및 검증
if [ ! -f "./rke2_check.env" ]; then
    echo "오류: rke2_check.env 파일을 찾을 수 없습니다."
    echo "기본 환경 변수를 사용합니다."
    # 기본 환경 변수 설정
    export LOG_LEVEL="${LOG_LEVEL:-INFO}"
    export LOG_DIR="${LOG_DIR:-./logs}"
    export RKE2_CONFIG_PATH="${RKE2_CONFIG_PATH:-/etc/rancher/rke2}"
    export KUBECONFIG="${KUBECONFIG:-/etc/rancher/rke2/rke2.yaml}"
else
    source ./rke2_check.env
fi

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

# 환경 변수 검증 실행
validate_environment



# 기본 값 설정

LOG_DIR="./logs"

TIMESTAMP=$(date +%Y%m%d_%H%M%S)

LOG_FILE="${LOG_DIR}/rke2_platform_${TIMESTAMP}.log"

HTML_LOG_FILE="${LOG_DIR}/rke2_platform_${TIMESTAMP}.html"



# 로그 디렉토리가 없으면 생성

mkdir -p ${LOG_DIR}



# 색상 코드 정의

RED='\033[0;31m'

GREEN='\033[0;32m'

YELLOW='\033[1;33m'

BLUE='\033[0;34m'

NC='\033[0m'

BOLD='\033[1m'



init_log_files() {

    cat > ${LOG_FILE} << EOF

============================================

     RKE2 플랫폼 상태 점검 보고서

     실행 시각: $(date)

============================================



EOF



    cat > ${HTML_LOG_FILE} << EOF

<!DOCTYPE html>

<html>

<head>

    <meta charset="UTF-8">

    <style>

        body { font-family: Arial, sans-serif; margin: 20px; }

        .header { background-color: #f8f9fa; padding: 20px; border-radius: 5px; }

        .section { margin: 20px 0; padding: 15px; border: 1px solid #dee2e6; border-radius: 5px; }

        .success { color: #28a745; }

        .warning { color: #ffc107; }

        .error { color: #dc3545; }

        .info { color: #17a2b8; }

        .timestamp { color: #6c757d; }

        .summary { background-color: #e9ecef; padding: 15px; margin-top: 20px; border-radius: 5px; }

        table { width: 100%; border-collapse: collapse; margin: 10px 0; }

        th, td { padding: 8px; text-align: left; border: 1px solid #dee2e6; }

        th { background-color: #f8f9fa; }

        .status-healthy { color: #28a745; }

        .status-warning { color: #ffc107; }

        .status-unhealthy { color: #dc3545; }

        .details { margin-left: 20px; }

        .metric-normal { color: #28a745; }

        .metric-warning { color: #ffc107; }

        .metric-critical { color: #dc3545; }

    </style>

</head>

<body>

    <div class="header">

        <h1>RKE2 플랫폼 상태 점검 보고서</h1>

        <p class="timestamp">점검 시각: $(date)</p>

    </div>

EOF

}



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



log_message() {

    local message="$1"

    local level="${2:-INFO}"

    message=$(echo -e "$message")

    local masked_message=$(mask_sensitive_info "$message")

    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')

    local html_message=$(echo "$masked_message" | sed ':a;N;$!ba;s/\n/<br>/g')

    case $level in

        "ERROR")

            printf "${RED}[오류]${NC} %b\n" "$masked_message" >&2

            printf "[%s] [오류] %b\n" "$timestamp" "$masked_message" >> ${LOG_FILE}

            echo "<div class='section error'><strong>오류:</strong> $html_message</div>" >> ${HTML_LOG_FILE}

            ;;

        "WARNING")

            printf "${YELLOW}[경고]${NC} %b\n" "$masked_message"

            printf "[%s] [경고] %b\n" "$timestamp" "$masked_message" >> ${LOG_FILE}

            echo "<div class='section warning'><strong>경고:</strong> $html_message</div>" >> ${HTML_LOG_FILE}

            ;;

        "SUCCESS")

            printf "${GREEN}[성공]${NC} %b\n" "$masked_message"

            printf "[%s] [성공] %b\n" "$timestamp" "$masked_message" >> ${LOG_FILE}

            echo "<div class='section success'><strong>성공:</strong> $html_message</div>" >> ${HTML_LOG_FILE}

            ;;

        "SECTION")

            printf "\n${BLUE}${BOLD}=== %b ===${NC}\n" "$masked_message"

            printf "\n===========================================\n" >> ${LOG_FILE}

            printf "[%s] === %b ===\n" "$timestamp" "$masked_message" >> ${LOG_FILE}

            printf "===========================================\n" >> ${LOG_FILE}

            echo "<div class='section'><h2>$html_message</h2>" >> ${HTML_LOG_FILE}

            ;;

        "SECTION_END")

            echo "</div>" >> ${HTML_LOG_FILE}

            ;;

        *)

            printf "%b\n" "$masked_message"

            printf "[%s] %b\n" "$timestamp" "$masked_message" >> ${LOG_FILE}

            echo "<div class='details'>$html_message</div>" >> ${HTML_LOG_FILE}

            ;;

    esac

}



# 안전한 명령어 실행 함수 (RKE2 특화 개선)

safe_execute() {
    local command="$1"
    local timeout="${2:-30}"
    local retry_count="${3:-0}"
    local max_retries="${4:-2}"
    
    # 명령어 검증 (기본적인 인젝션 방지)
    if [[ "$command" =~ [\&\|\`\;] ]]; then
        log_message "잠재적 위험한 명령어 감지: $command" "ERROR"
        return 1
    fi
    
    local output
    local exit_code
    
    for ((i=0; i<=max_retries; i++)); do
        if output=$(timeout "$timeout" bash -c "$command" 2>&1); then
            exit_code=0
            break
        else
            exit_code=$?
            if [[ $i -lt $max_retries ]]; then
                log_message "명령어 재시도 중... ($((i+1))/$((max_retries+1))): $command" "WARNING"
                sleep 2
            fi
        fi
    done
    
    case $exit_code in
        0)
            log_message "$(mask_sensitive_info "$output")"
            return 0
            ;;
        124)
            log_message "명령어 실행 시간 초과 (${timeout}초): $command" "ERROR"
            return 1
            ;;
        126)
            log_message "명령어를 실행할 수 없습니다: $command" "ERROR"
            return 1
            ;;
        127)
            log_message "명령어를 찾을 수 없습니다: $command" "ERROR"
            return 1
            ;;
        *)
            log_message "명령어 실행 실패 (exit: $exit_code): $command" "ERROR"
            log_message "$(mask_sensitive_info "$output")" "ERROR"
            return 1
            ;;
    esac
}

# 기존 log_command 함수를 safe_execute로 대체
log_command() {
    safe_execute "$1"
}



# ===============================

# 플랫폼 주요 점검 함수

# ===============================



check_cluster_config() {

    log_message "\n=== 클러스터 구성 및 버전 ===" "SECTION"

    log_command "rke2 -v"

    log_command "kubectl version --short"

    log_command "kubectl cluster-info"

    log_message "\n노드 전체 목록:"

    log_command "kubectl get nodes -o wide"

    log_message "" "SECTION_END"

}



check_node_roles() {

    log_message "\n=== 노드풀/역할별 노드 현황 ===" "SECTION"

    log_message "노드 Label/역할별 현황:"

    log_command "kubectl get nodes --show-labels"

    for role in master worker oss; do

        log_message "\n[$role 노드 현황]"

        local nodes=$(kubectl get nodes -l node-role.kubernetes.io/$role= -o jsonpath='{.items[*].metadata.name}')

        if [ -n "$nodes" ]; then

            for node in $nodes; do

                log_message "- $node"

                log_command "kubectl describe node $node"

            done

        else

            log_message "- $role 역할 노드 없음" "WARNING"

        fi

    done

    log_message "" "SECTION_END"

}



check_network() {

    log_message "\n=== 네트워크 및 정책 현황 ===" "SECTION"

    log_message "클러스터 네트워크 플러그인(설치시 기록 참고):"

    log_command "kubectl get pods -n kube-system -o wide | grep -Ei 'cni|calico|flannel|cilium'"

    log_message "\n네트워크 정책:"

    if kubectl get networkpolicy --all-namespaces &> /dev/null; then

        log_command "kubectl get networkpolicy --all-namespaces"

    else

        log_message "네트워크 정책 없음"

    fi

    log_message "" "SECTION_END"

}



check_storage() {

    log_message "\n=== 스토리지/볼륨/스토리지클래스 현황 ===" "SECTION"

    log_command "kubectl get storageclass"

    log_command "kubectl get pv -A"

    log_command "kubectl get pvc -A"

    log_message "" "SECTION_END"

}



check_metrics() {

    log_message "\n=== 노드/파드 메트릭/자원현황 ===" "SECTION"

    # 노드 리소스 사용량

    if kubectl top nodes &> /dev/null; then

        log_message "[노드 리소스 사용량]"

        log_command "kubectl top nodes"

    else

        log_message "노드 리소스 사용량(메트릭 서버) 정보 없음" "WARNING"

    fi

    # 파드 리소스 사용량

    if kubectl top pods --all-namespaces &> /dev/null; then

        log_message "[파드 리소스 사용량]"

        log_command "kubectl top pods --all-namespaces"

    else

        log_message "파드 리소스 사용량(메트릭 서버) 정보 없음" "WARNING"

    fi

    log_message "" "SECTION_END"

}



check_security() {

    log_message "\n=== RBAC/보안 정책/PSP 현황 ===" "SECTION"

    log_message "[ClusterRole]"

    log_command "kubectl get clusterroles"

    log_message "[ClusterRoleBinding]"

    log_command "kubectl get clusterrolebindings"

    log_message "[ServiceAccount]"

    log_command "kubectl get serviceaccounts --all-namespaces"

    log_message "[PodSecurityPolicy]"

    if kubectl get psp &> /dev/null; then

        log_command "kubectl get psp"

    else

        log_message "PodSecurityPolicy 사용 안함(Pod Security Admission 등 적용 가능)" "INFO"

    fi

    log_message "" "SECTION_END"

}



check_monitoring() {

    log_message "\n=== 모니터링/로깅/운영툴 현황 ===" "SECTION"

    for ns in monitoring logging harbor; do

        log_message "[$ns 네임스페이스]"

        if kubectl get pods -n $ns &> /dev/null; then

            log_command "kubectl get pods -n $ns"

        else

            log_message "$ns 네임스페이스 없음"

        fi

    done

    log_message "[운영툴 Service/Ingress]"

    log_command "kubectl get svc -A"

    log_command "kubectl get ingress -A"

    log_message "" "SECTION_END"

}



# ===============================

# 메인 실행

# ===============================



main() {

    init_log_files

    check_cluster_config

    check_node_roles

    check_network

    check_storage

    check_metrics

    check_security

    check_monitoring

    log_message "\n=== 플랫폼 상태 점검 완료 ===" "SUCCESS"

    log_message "상세 결과는 다음 파일에서 확인할 수 있습니다: ${LOG_FILE}" "INFO"

}



main

