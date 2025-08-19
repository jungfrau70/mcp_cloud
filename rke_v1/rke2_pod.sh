#!/bin/bash



# RKE2 파드 점검 스크립트 (설치형 환경 2차 기술지원/운영진단용)

# (Azure VM + RHEL9 OS + RKE2 클러스터 환경)



# 환경 변수 파일 로드 및 검증
if [ ! -f "./rke2_pod.env" ]; then
    echo "오류: rke2_pod.env 파일을 찾을 수 없습니다."
    echo "기본 환경 변수를 사용합니다."
    # 기본 환경 변수 설정
    export LOG_LEVEL="${LOG_LEVEL:-INFO}"
    export LOG_DIR="${LOG_DIR:-./logs}"
    export RKE2_CONFIG_PATH="${RKE2_CONFIG_PATH:-/etc/rancher/rke2}"
    export KUBECONFIG="${KUBECONFIG:-/etc/rancher/rke2/rke2.yaml}"
    export NAMESPACE="${NAMESPACE:-}"  # 빈 값이면 전체 네임스페이스
else
    source ./rke2_pod.env
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



# 환경 변수 검증

validate_env() {
    if [ -n "$NAMESPACE" ]; then
        return
    fi
    # NAMESPACE 없으면 전체 네임스페이스 점검
    return
}



LOG_DIR="./logs"

TIMESTAMP=$(date +%Y%m%d_%H%M%S)

LOG_FILE="${LOG_DIR}/rke2_pod_${TIMESTAMP}.log"

HTML_LOG_FILE="${LOG_DIR}/rke2_pod_${TIMESTAMP}.html"



mkdir -p ${LOG_DIR}



# 색상 코드

RED='\033[0;31m'

GREEN='\033[0;32m'

YELLOW='\033[1;33m'

BLUE='\033[0;34m'

NC='\033[0m'

BOLD='\033[1m'



cat > ${HTML_LOG_FILE} << 'EOF'

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

        .pod-name { font-weight: bold; color: #0066cc; }

        .timestamp { color: #6c757d; }

        .summary { background-color: #e9ecef; padding: 15px; margin-top: 20px; border-radius: 5px; }

        table { width: 100%; border-collapse: collapse; margin: 10px 0; }

        th, td { padding: 8px; text-align: left; border: 1px solid #dee2e6; }

        th { background-color: #f8f9fa; }

        .status-running { color: #28a745; }

        .status-error { color: #dc3545; }

        .details { margin-left: 20px; }

    </style>

</head>

<body>

    <div class="header">

        <h1>RKE2 파드 상태 점검 보고서</h1>

        <p class="timestamp">점검 시각: $(date)</p>

    </div>

EOF



# 로그 메시지 함수

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



# 테이블 함수

start_table() {

    local headers=("$@")

    echo "<table><tr>" >> ${HTML_LOG_FILE}

    for header in "${headers[@]}"; do

        echo "<th>$header</th>" >> ${HTML_LOG_FILE}

    done

    echo "</tr>" >> ${HTML_LOG_FILE}

}



add_table_row() {

    echo "<tr>" >> ${HTML_LOG_FILE}

    for cell in "$@"; do

        echo "<td>$cell</td>" >> ${HTML_LOG_FILE}

    done

    echo "</tr>" >> ${HTML_LOG_FILE}

}



end_table() {

    echo "</table>" >> ${HTML_LOG_FILE}

}



add_summary() {

    local total_pods=$1

    local running_pods=$2

    local problem_pods=$3

    local namespaces=$4

    echo "<div class='summary'>" >> ${HTML_LOG_FILE}

    echo "<h2>점검 요약</h2>" >> ${HTML_LOG_FILE}

    echo "<ul>" >> ${HTML_LOG_FILE}

    echo "<li>검사한 네임스페이스: $namespaces</li>" >> ${HTML_LOG_FILE}

    echo "<li>전체 파드 수: $total_pods</li>" >> ${HTML_LOG_FILE}

    echo "<li>정상 실행 중인 파드: $running_pods</li>" >> ${HTML_LOG_FILE}

    echo "<li>문제가 있는 파드: $problem_pods</li>" >> ${HTML_LOG_FILE}

    echo "</ul>" >> ${HTML_LOG_FILE}

    echo "</div>" >> ${HTML_LOG_FILE}

}



finish_html() {

    echo "</body></html>" >> ${HTML_LOG_FILE}

    log_message "HTML 형식의 보고서가 생성되었습니다: ${HTML_LOG_FILE}" "SUCCESS"

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



get_namespaces() {

    if [ -n "$NAMESPACE" ]; then

        echo "$NAMESPACE"

    else

        kubectl get namespaces --no-headers -o custom-columns=NAME:.metadata.name 2>/dev/null || echo "default"

    fi

}



# RKE2 특화 파드 점검 함수들

check_pod_status() {
    local namespace="$1"
    log_message "[파드 상태 점검 - $namespace]" "SECTION"
    
    # 파드 상태 요약
    safe_execute "kubectl get pods -n $namespace -o wide"
    
    # 문제가 있는 파드 상세 정보
    local problem_pods=$(kubectl get pods -n "$namespace" --no-headers 2>/dev/null | grep -v "Running\|Completed" | awk '{print $1}')
    
    if [[ -n "$problem_pods" ]]; then
        log_message "[문제가 있는 파드 상세 정보]" "WARNING"
        for pod in $problem_pods; do
            safe_execute "kubectl describe pod $pod -n $namespace"
            safe_execute "kubectl logs $pod -n $namespace --tail=50"
        done
    else
        log_message "모든 파드가 정상 상태입니다" "SUCCESS"
    fi
    
    log_message "" "SECTION_END"
}

check_pod_resources() {
    local namespace="$1"
    log_message "[파드 리소스 사용량 - $namespace]" "SECTION"
    
    # 리소스 사용량 (메트릭 서버가 있는 경우)
    if kubectl top pods -n "$namespace" &>/dev/null; then
        safe_execute "kubectl top pods -n $namespace"
    else
        log_message "메트릭 서버가 없어 리소스 사용량을 확인할 수 없습니다" "WARNING"
    fi
    
    # 파드 리소스 요청/제한
    safe_execute "kubectl get pods -n $namespace -o custom-columns=NAME:.metadata.name,CPU_REQUEST:.spec.containers[0].resources.requests.cpu,CPU_LIMIT:.spec.containers[0].resources.limits.cpu,MEMORY_REQUEST:.spec.containers[0].resources.requests.memory,MEMORY_LIMIT:.spec.containers[0].resources.limits.memory"
    
    log_message "" "SECTION_END"
}

check_pod_networking() {
    local namespace="$1"
    log_message "[파드 네트워킹 - $namespace]" "SECTION"
    
    # 서비스 정보
    safe_execute "kubectl get svc -n $namespace"
    
    # 엔드포인트 정보
    safe_execute "kubectl get endpoints -n $namespace"
    
    # 네트워크 정책
    if kubectl get networkpolicy -n "$namespace" &>/dev/null; then
        safe_execute "kubectl get networkpolicy -n $namespace"
    else
        log_message "네트워크 정책이 설정되지 않았습니다" "INFO"
    fi
    
    log_message "" "SECTION_END"
}

check_pod_volumes() {
    local namespace="$1"
    log_message "[파드 볼륨 - $namespace]" "SECTION"
    
    # PVC 정보
    safe_execute "kubectl get pvc -n $namespace"
    
    # PV 정보
    safe_execute "kubectl get pv"
    
    # 스토리지 클래스
    safe_execute "kubectl get storageclass"
    
    log_message "" "SECTION_END"
}

check_pod_logs() {
    local namespace="$1"
    log_message "[파드 로그 분석 - $namespace]" "SECTION"
    
    # 최근 오류 로그가 있는 파드 찾기
    local pods=$(kubectl get pods -n "$namespace" --no-headers 2>/dev/null | awk '{print $1}')
    
    for pod in $pods; do
        # 오류 로그 확인
        local error_logs=$(kubectl logs "$pod" -n "$namespace" --tail=100 2>/dev/null | grep -i "error\|fail\|exception" | tail -10)
        
        if [[ -n "$error_logs" ]]; then
            log_message "[$pod - 최근 오류 로그]" "WARNING"
            log_message "$error_logs"
        fi
    done
    
    log_message "" "SECTION_END"
}

# RKE2 특화 추가 점검 함수들

check_rke2_pod_security() {
    local namespace="$1"
    log_message "[RKE2 파드 보안 - $namespace]" "SECTION"
    
    # Pod Security Standards 확인
    safe_execute "kubectl get pods -n $namespace -o jsonpath='{range .items[*]}{.metadata.name}{\"\\t\"}{.spec.securityContext.runAsNonRoot}{\"\\t\"}{.spec.securityContext.runAsUser}{\"\\n\"}{end}'"
    
    # Security Context 확인
    safe_execute "kubectl get pods -n $namespace -o jsonpath='{range .items[*]}{.metadata.name}{\"\\t\"}{.spec.containers[0].securityContext.allowPrivilegeEscalation}{\"\\t\"}{.spec.containers[0].securityContext.readOnlyRootFilesystem}{\"\\n\"}{end}'"
    
    log_message "" "SECTION_END"
}

check_rke2_pod_containerd() {
    local namespace="$1"
    log_message "[RKE2 containerd 컨테이너 - $namespace]" "SECTION"
    
    # containerd 컨테이너 ID 확인
    local pods=$(kubectl get pods -n "$namespace" --no-headers 2>/dev/null | awk '{print $1}')
    
    for pod in $pods; do
        local container_id=$(kubectl get pod "$pod" -n "$namespace" -o jsonpath='{.status.containerStatuses[0].containerID}' 2>/dev/null | sed 's/containerd:\/\///')
        
        if [[ -n "$container_id" ]]; then
            log_message "[$pod - containerd 컨테이너 정보]"
            safe_execute "crictl inspect $container_id 2>/dev/null | jq '.info.runtimeSpec.process.args' || echo '컨테이너 정보 조회 실패'"
        fi
    done
    
    log_message "" "SECTION_END"
}



# 메인 실행

main() {

    validate_environment

    # 로그 파일 초기화

    cat > ${LOG_FILE} << EOF

============================================

     RKE2 파드 상태 점검 보고서

     실행 시각: $(date)

============================================



EOF



    # 네임스페이스 목록

    local namespaces=($(get_namespaces))

    if [ ${#namespaces[@]} -eq 0 ]; then

        log_message "오류: 검사할 네임스페이스가 없습니다."

        exit 1

    fi



    # 통계 변수

    local total_pods=0

    local running_pods=0

    local problem_pods=0



    for namespace in "${namespaces[@]}"; do

        log_message "네임스페이스: ${namespace}" "SECTION"



        # 파드 수 계산

        local ns_pods=$(kubectl get pods -n "${namespace}" --no-headers 2>/dev/null | wc -l)

        local ns_running=$(kubectl get pods -n "${namespace}" --no-headers 2>/dev/null | grep "Running\|Completed" | wc -l)

        local ns_problems=$((ns_pods - ns_running))



        total_pods=$((total_pods + ns_pods))

        running_pods=$((running_pods + ns_running))

        problem_pods=$((problem_pods + ns_problems))



        # 아래 섹션별 점검 함수들(aks_pod.sh에서 내용 복붙)

        check_pod_status "$namespace"

        check_pod_resources "$namespace"

        check_pod_networking "$namespace"

        check_pod_volumes "$namespace"

        check_pod_logs "$namespace"
        check_rke2_pod_security "$namespace"
        check_rke2_pod_containerd "$namespace"
        
        log_message "" "SECTION_END"
    done
    
    # 요약 정보 추가
    add_summary "$total_pods" "$running_pods" "$problem_pods" "${namespaces[*]}"
    
    # HTML 파일 완성
    finish_html
    
    log_message "\n=== 파드 상태 점검 완료 ===" "SUCCESS"
    log_message "소요 시간: $(($(date +%s) - start_time))초" "INFO"
    log_message "상세 결과는 다음 파일에서 확인할 수 있습니다: ${LOG_FILE}" "INFO"
    log_message "HTML 보고서: ${HTML_LOG_FILE}" "INFO"
}

# 시작 시간 기록
start_time=$(date +%s)

# 메인 함수 실행
main