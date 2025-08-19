#!/bin/bash



# RKE2 24x7 점검 스크립트 (설치형 클러스터 운영지원용)

# (Azure VM + RHEL9 OS 환경 전용)



# 환경 변수 파일 로드 및 검증
if [ ! -f "./24x7_rke2_check.env" ]; then
    echo "오류: 24x7_rke2_check.env 파일을 찾을 수 없습니다."
    echo "기본 환경 변수를 사용합니다."
    # 기본 환경 변수 설정
    export LOG_LEVEL="${LOG_LEVEL:-INFO}"
    export TIMEOUT="${TIMEOUT:-30}"
    export LOG_DIR="${LOG_DIR:-./logs}"
    export RKE2_CONFIG_PATH="${RKE2_CONFIG_PATH:-/etc/rancher/rke2}"
    export KUBECONFIG="${KUBECONFIG:-/etc/rancher/rke2/rke2.yaml}"
else
    source ./24x7_rke2_check.env
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

LOG_FILE="${LOG_DIR}/24x7_rke2_${TIMESTAMP}.log"

HTML_LOG_FILE="${LOG_DIR}/24x7_rke2_${TIMESTAMP}.html"

TIMEOUT=30  # 명령어 실행 타임아웃 (초)



# 로그 디렉토리가 없으면 생성

mkdir -p ${LOG_DIR}



# 색상 코드 정의

RED='\033[0;31m'

GREEN='\033[0;32m'

YELLOW='\033[1;33m'

BLUE='\033[0;34m'

NC='\033[0m' # No Color

BOLD='\033[1m'



# 로그 파일 초기화

init_log_files() {

    cat > ${LOG_FILE} << EOF

============================================

     RKE2 24x7 모니터링 보고서

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

        .status-ok { color: #28a745; }

        .status-warning { color: #ffc107; }

        .status-error { color: #dc3545; }

        .details { margin-left: 20px; }

    </style>

</head>

<body>

    <div class="header">

        <h1>RKE2 24x7 모니터링 보고서</h1>

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



# 로그 메시지 출력 함수

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



# 오류 처리 함수

handle_error() {

    local error_message="$1"

    log_message "오류 발생: ${error_message}" "ERROR"

    return 1

}



# 안전한 명령어 실행 함수 (RKE2 특화 개선)

safe_execute() {
    local command="$1"
    local timeout="${2:-${TIMEOUT:-30}}"
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



# 필수 도구 설치 여부 확인 (RKE2 특화)

check_prerequisites() {
    log_message "\n=== 필수 도구 설치 여부 확인 ===" "SECTION"
    
    local required_tools=("kubectl" "jq")
    local optional_tools=("rke2" "helm" "k9s")
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
    log_message "" "SECTION_END"
}



# RKE2/클러스터 정보 확인

check_cluster_info() {

    log_message "\n=== RKE2 및 클러스터 정보 확인 ===" "SECTION"

    log_command "rke2 -v"

    log_command "kubectl version --short"

    log_command "kubectl cluster-info"

    log_message "" "SECTION_END"

}



# etcd/Control-plane 상태 확인

check_control_plane() {

    log_message "\n=== etcd 및 Control-plane 상태 ===" "SECTION"

    log_command "kubectl get pods -n kube-system -l component=etcd -o wide"

    # etcd health (한 노드에서만 수행)

    ETCD_POD=$(kubectl get pod -n kube-system -l component=etcd -o jsonpath='{.items[0].metadata.name}')

    if [ -n "$ETCD_POD" ]; then

        log_command "kubectl -n kube-system exec -it $ETCD_POD -- etcdctl endpoint health --cluster"

    fi

    log_command "kubectl get pods -n kube-system -l 'component in (etcd, kube-apiserver, kube-controller-manager, kube-scheduler)' -o wide"

    log_message "" "SECTION_END"

}



# 전체 노드/라벨/taint 등 상태

check_node_overview() {

    log_message "\n=== 전체 노드/레이블/taint 현황 ===" "SECTION"

    log_command "kubectl get nodes -o wide"

    log_command "kubectl get nodes --show-labels"

    log_command "kubectl get nodes -o json | jq '.items[].spec.taints'"

    log_message "" "SECTION_END"

}



# 역할별 노드(Master/Worker/OSS) 점검

check_role_nodes() {

    log_message "\n=== Master/Worker/OSS Node 상태 점검 ===" "SECTION"

    declare -A node_roles=( ["master"]="node-role.kubernetes.io/master=" ["worker"]="node-role.kubernetes.io/worker=" ["oss"]="node-role.kubernetes.io/oss=" )



    for role in "${!node_roles[@]}"; do

        log_message "\n[${role^^} Node]" "SUCCESS"

        NODES=$(kubectl get nodes -l ${node_roles[$role]} -o jsonpath='{.items[*].metadata.name}')

        if [ -z "$NODES" ]; then

            log_message "해당 역할($role) 노드가 존재하지 않습니다" "WARNING"

            continue

        fi

        for NODE in $NODES; do

            log_message "\n--- $role: $NODE ---"

            log_command "kubectl describe node $NODE"

            log_command "kubectl get pods -A -o wide --field-selector spec.nodeName=$NODE"

        done

    done

    log_message "" "SECTION_END"

}



# 전체 네임스페이스/파드/리소스 상태

check_namespace_pod() {

    log_message "\n=== 네임스페이스/파드/리소스 상태 ===" "SECTION"

    log_command "kubectl get ns"

    log_command "kubectl get pods -A -o wide"

    log_command "kubectl top node"

    log_command "kubectl top pod -A"

    log_message "" "SECTION_END"

}



# 스토리지 및 인프라 리소스

check_storage_infra() {

    log_message "\n=== 스토리지 및 인프라(운영툴/서비스 등) ===" "SECTION"

    log_command "kubectl get sc"

    log_command "kubectl get pv -A"

    log_command "kubectl get pvc -A"

    log_command "kubectl get deploy -A"

    log_command "kubectl get svc -A"

    log_command "kubectl get ingress -A"

    log_command "kubectl get hpa -A"

    log_command "kubectl get pdb -A"

    log_command "kubectl get rs -A"

    log_command "kubectl get networkpolicy -A"

    log_message "" "SECTION_END"

}



# OSS 운영툴 상태 (네임스페이스 조정 필요)

check_oss_tools() {

    log_message "\n=== 운영툴(Grafana, Prometheus, Loki, Harbor) 상태 ===" "SECTION"

    log_command "kubectl get pods -n monitoring"

    log_command "kubectl get pods -n logging"

    log_command "kubectl get pods -n harbor"

    log_command "kubectl get svc -n harbor"

    log_command "kubectl get ingress -n harbor"

    log_command "kubectl get pods -n kube-system | grep csi-azure"

    log_message "" "SECTION_END"

}



# 시스템 점검(리눅스/리소스/보안 등)

check_system() {

    log_message "\n=== 시스템 리소스 및 보안 상태 ===" "SECTION"

    log_command "free -h"

    log_command "df -h"

    log_command "uptime"

    log_command "ss -tulpn | grep -E '6443|2379|2380|10250'"

    log_command "ps aux | grep -E 'rke2|etcd|containerd'"

    log_command "getenforce"

    log_command "firewall-cmd --state"

    log_command "sysctl -a | grep -E 'vm.max_map_count|fs.inotify.max_user_watches'"

    log_message "" "SECTION_END"

}



# RKE2 특화 점검 함수들

check_rke2_specific() {
    log_message "\n=== RKE2 특화 구성 및 상태 ===" "SECTION"
    
    # RKE2 설정 파일 확인
    log_message "[RKE2 설정 파일]"
    safe_execute "ls -la ${RKE2_CONFIG_PATH:-/etc/rancher/rke2}/"
    safe_execute "cat ${RKE2_CONFIG_PATH:-/etc/rancher/rke2}/config.yaml 2>/dev/null || echo '설정 파일 없음'"
    
    # RKE2 서비스 상태
    log_message "[RKE2 서비스 상태]"
    safe_execute "systemctl status rke2-server --no-pager -l"
    safe_execute "systemctl status rke2-agent --no-pager -l"
    
    # RKE2 프로세스 확인
    log_message "[RKE2 프로세스]"
    safe_execute "ps aux | grep -E 'rke2|containerd' | grep -v grep"
    
    # RKE2 데이터 디렉토리
    log_message "[RKE2 데이터 디렉토리]"
    safe_execute "du -sh /var/lib/rancher/rke2/ 2>/dev/null || echo '데이터 디렉토리 없음'"
    safe_execute "ls -la /var/lib/rancher/rke2/ 2>/dev/null || echo '데이터 디렉토리 없음'"
    
    log_message "" "SECTION_END"
}

check_rke2_etcd() {
    log_message "\n=== RKE2 etcd 상태 (내장) ===" "SECTION"
    
    # etcd 파드 확인
    local etcd_pods=$(kubectl get pods -n kube-system -l component=etcd -o jsonpath='{.items[*].metadata.name}' 2>/dev/null)
    
    if [[ -n "$etcd_pods" ]]; then
        for pod in $etcd_pods; do
            log_message "[etcd 파드: $pod]"
            safe_execute "kubectl describe pod $pod -n kube-system"
            safe_execute "kubectl logs $pod -n kube-system --tail=50"
        done
        
        # etcd 상태 확인
        local first_etcd_pod=$(echo "$etcd_pods" | awk '{print $1}')
        if [[ -n "$first_etcd_pod" ]]; then
            log_message "[etcd 클러스터 상태]"
            safe_execute "kubectl -n kube-system exec $first_etcd_pod -- etcdctl endpoint health --cluster"
            safe_execute "kubectl -n kube-system exec $first_etcd_pod -- etcdctl member list"
        fi
    else
        log_message "etcd 파드를 찾을 수 없습니다" "WARNING"
    fi
    
    log_message "" "SECTION_END"
}

check_rke2_containerd() {
    log_message "\n=== RKE2 containerd 상태 ===" "SECTION"
    
    # containerd 서비스 상태
    safe_execute "systemctl status containerd --no-pager -l"
    
    # containerd 프로세스
    safe_execute "ps aux | grep containerd | grep -v grep"
    
    # containerd 소켓 확인
    safe_execute "ls -la /run/containerd/containerd.sock 2>/dev/null || echo 'containerd 소켓 없음'"
    
    # 컨테이너 목록
    safe_execute "crictl ps -a 2>/dev/null || echo 'crictl 사용 불가'"
    
    # 이미지 목록
    safe_execute "crictl images 2>/dev/null || echo 'crictl 사용 불가'"
    
    log_message "" "SECTION_END"
}

check_rke2_security() {
    log_message "\n=== RKE2 보안 설정 ===" "SECTION"
    
    # SELinux 상태
    safe_execute "getenforce"
    safe_execute "sestatus"
    
    # AppArmor 상태
    safe_execute "aa-status 2>/dev/null || echo 'AppArmor 사용 안함'"
    
    # 방화벽 상태
    safe_execute "firewall-cmd --state"
    safe_execute "firewall-cmd --list-all"
    
    # RKE2 보안 프로파일
    safe_execute "grep -r 'profile' ${RKE2_CONFIG_PATH:-/etc/rancher/rke2}/config.yaml 2>/dev/null || echo '보안 프로파일 설정 없음'"
    
    # mTLS 설정 확인
    safe_execute "kubectl get configmap -n kube-system rke2-canal-config -o yaml 2>/dev/null || echo 'Canal 설정 없음'"
    
    log_message "" "SECTION_END"
}

# 장애 징후(RKE2 서버 로그 등)

check_rke2_logs() {
    log_message "\n=== RKE2 장애 징후(로그) ===" "SECTION"
    
    # RKE2 서버 로그
    log_message "[RKE2 서버 로그]"
    safe_execute "journalctl -u rke2-server -n 100 --no-pager"
    
    # RKE2 에이전트 로그
    log_message "[RKE2 에이전트 로그]"
    safe_execute "journalctl -u rke2-agent -n 100 --no-pager"
    
    # containerd 로그
    log_message "[containerd 로그]"
    safe_execute "journalctl -u containerd -n 50 --no-pager"
    
    # 시스템 로그에서 RKE2 관련 오류
    log_message "[시스템 로그 RKE2 오류]"
    safe_execute "journalctl -n 200 | grep -i 'rke2\|containerd' | grep -i 'error\|fail'"
    
    log_message "" "SECTION_END"
}



# 메인 실행 (RKE2 특화 개선)

main() {
    init_log_files
    
    # 시작 시간 기록
    local start_time=$(date +%s)
    
    log_message "RKE2 24x7 모니터링 시작 - $(date)" "SUCCESS"
    
    check_prerequisites
    check_cluster_info
    check_control_plane
    check_node_overview
    check_role_nodes
    check_namespace_pod
    check_storage_infra
    check_oss_tools
    check_system
    
    # RKE2 특화 점검 추가
    check_rke2_specific
    check_rke2_etcd
    check_rke2_containerd
    check_rke2_security
    check_rke2_logs
    
    # 종료 시간 및 소요 시간 계산
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    log_message "\n=== 상태 점검 완료 ===" "SUCCESS"
    log_message "소요 시간: ${duration}초" "INFO"
    log_message "상세 결과는 다음 파일에서 확인할 수 있습니다: ${LOG_FILE}" "INFO"
    log_message "HTML 보고서: ${HTML_LOG_FILE}" "INFO"
}



main