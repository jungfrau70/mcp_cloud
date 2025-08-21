#!/bin/bash

# RKE2 클러스터 서비스 체크 스크립트
# (Azure VM + RHEL9 OS + RKE2 설치형 클러스터 환경)

# 환경 변수 파일 로드 및 검증
if [ ! -f "./rke2_service_check.env" ]; then
    echo "오류: rke2_service_check.env 파일을 찾을 수 없습니다."
    echo "기본 환경 변수를 사용합니다."
    # 기본 환경 변수 설정
    export LOG_LEVEL="${LOG_LEVEL:-INFO}"
    export LOG_DIR="${LOG_DIR:-./logs}"
    export RKE2_CONFIG_PATH="${RKE2_CONFIG_PATH:-/etc/rancher/rke2}"
    export KUBECONFIG="${KUBECONFIG:-/etc/rancher/rke2/rke2.yaml}"
    export TIMEOUT="${TIMEOUT:-10}"
    export RETRY_COUNT="${RETRY_COUNT:-3}"
else
    source ./rke2_service_check.env
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
LOG_FILE="${LOG_DIR}/rke2_service_check_${TIMESTAMP}.log"
HTML_LOG_FILE="${LOG_DIR}/rke2_service_check_${TIMESTAMP}.html"

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
     RKE2 클러스터 서비스 체크 보고서
     실행 시각: $(date)
============================================

EOF

    cat > ${HTML_LOG_FILE} << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>RKE2 클러스터 서비스 체크 보고서</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .header { background-color: #f0f0f0; padding: 20px; border-radius: 5px; }
        .section { margin: 20px 0; padding: 15px; border-left: 4px solid #007cba; }
        .success { color: #28a745; }
        .warning { color: #ffc107; }
        .error { color: #dc3545; }
        .info { color: #17a2b8; }
        table { border-collapse: collapse; width: 100%; margin: 10px 0; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        th { background-color: #f2f2f2; }
        .status-ok { background-color: #d4edda; }
        .status-warning { background-color: #fff3cd; }
        .status-error { background-color: #f8d7da; }
    </style>
</head>
<body>
    <div class="header">
        <h1>RKE2 클러스터 서비스 체크 보고서</h1>
        <p>실행 시각: <span id="timestamp"></span></p>
    </div>
EOF
}

# 로그 메시지 출력
log_message() {
    local message="$1"
    local level="${2:-INFO}"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    case $level in
        "SUCCESS")
            echo -e "${GREEN}[SUCCESS]${NC} $message"
            echo "[SUCCESS] $timestamp - $message" >> ${LOG_FILE}
            ;;
        "WARNING")
            echo -e "${YELLOW}[WARNING]${NC} $message"
            echo "[WARNING] $timestamp - $message" >> ${LOG_FILE}
            ;;
        "ERROR")
            echo -e "${RED}[ERROR]${NC} $message"
            echo "[ERROR] $timestamp - $message" >> ${LOG_FILE}
            ;;
        "INFO")
            echo -e "${BLUE}[INFO]${NC} $message"
            echo "[INFO] $timestamp - $message" >> ${LOG_FILE}
            ;;
        *)
            echo "[$level] $message"
            echo "[$level] $timestamp - $message" >> ${LOG_FILE}
            ;;
    esac
}

# 안전한 명령어 실행
safe_execute() {
    local command="$1"
    local description="${2:-$command}"
    
    log_message "실행: $description" "INFO"
    
    # 타임아웃 설정으로 명령어 실행
    local output
    output=$(timeout ${TIMEOUT} bash -c "$command" 2>&1)
    local exit_code=$?
    
    if [ $exit_code -eq 0 ]; then
        log_message "성공: $description" "SUCCESS"
        echo "$output" >> ${LOG_FILE}
        echo "$output"
    elif [ $exit_code -eq 124 ]; then
        log_message "타임아웃: $description (${TIMEOUT}초 초과)" "WARNING"
        echo "타임아웃: ${TIMEOUT}초 초과" >> ${LOG_FILE}
    else
        log_message "실패: $description (종료 코드: $exit_code)" "ERROR"
        echo "$output" >> ${LOG_FILE}
        echo "$output"
    fi
    
    return $exit_code
}

# HTTP 서비스 체크 함수
check_http_service() {
    local url="$1"
    local description="$2"
    local expected_status="${3:-200}"
    local timeout="${4:-${TIMEOUT}}"
    
    log_message "HTTP 체크: $description ($url)" "INFO"
    
    # curl로 HTTP 요청
    local response
    local http_code
    local exit_code
    
    response=$(curl -s -w "HTTPSTATUS:%{http_code}" --connect-timeout $timeout --max-time $timeout "$url" 2>/dev/null)
    exit_code=$?
    
    if [ $exit_code -eq 0 ]; then
        http_code=$(echo "$response" | tr -d '\n' | sed -e 's/.*HTTPSTATUS://')
        response=$(echo "$response" | sed -e 's/HTTPSTATUS\:.*//g')
        
        if [ "$http_code" = "$expected_status" ]; then
            log_message "성공: $description (HTTP $http_code)" "SUCCESS"
            echo "응답: $response" >> ${LOG_FILE}
            return 0
        else
            log_message "경고: $description (예상: $expected_status, 실제: $http_code)" "WARNING"
            echo "응답: $response" >> ${LOG_FILE}
            return 1
        fi
    else
        log_message "실패: $description (연결 오류, 종료 코드: $exit_code)" "ERROR"
        return 2
    fi
}

# HTTPS 서비스 체크 함수 (인증서 검증 무시)
check_https_service() {
    local url="$1"
    local description="$2"
    local expected_status="${3:-200}"
    local timeout="${4:-${TIMEOUT}}"
    
    log_message "HTTPS 체크: $description ($url)" "INFO"
    
    # curl로 HTTPS 요청 (인증서 검증 무시)
    local response
    local http_code
    local exit_code
    
    response=$(curl -k -s -w "HTTPSTATUS:%{http_code}" --connect-timeout $timeout --max-time $timeout "$url" 2>/dev/null)
    exit_code=$?
    
    if [ $exit_code -eq 0 ]; then
        http_code=$(echo "$response" | tr -d '\n' | sed -e 's/.*HTTPSTATUS://')
        response=$(echo "$response" | sed -e 's/HTTPSTATUS\:.*//g')
        
        if [ "$http_code" = "$expected_status" ]; then
            log_message "성공: $description (HTTP $http_code)" "SUCCESS"
            echo "응답: $response" >> ${LOG_FILE}
            return 0
        else
            log_message "경고: $description (예상: $expected_status, 실제: $http_code)" "WARNING"
            echo "응답: $response" >> ${LOG_FILE}
            return 1
        fi
    else
        log_message "실패: $description (연결 오류, 종료 코드: $exit_code)" "ERROR"
        return 2
    fi
}

# Kubernetes API 서버 체크
check_kubernetes_api() {
    log_message "\n=== Kubernetes API 서버 체크 ===" "SECTION"
    
    # 클러스터 내부 API 서버 체크
    check_https_service "https://kubernetes.default.svc.cluster.local:443/api/v1/namespaces" \
        "Kubernetes API 서버 (클러스터 내부)" "200"
    
    # 헬스체크 엔드포인트
    check_https_service "https://kubernetes.default.svc.cluster.local:443/healthz" \
        "Kubernetes API 서버 헬스체크" "200"
    
    # API 버전 정보
    check_https_service "https://kubernetes.default.svc.cluster.local:443/api/v1/" \
        "Kubernetes API v1 정보" "200"
    
    log_message "" "SECTION_END"
}

# RKE2 특화 서비스 체크
check_rke2_services() {
    log_message "\n=== RKE2 특화 서비스 체크 ===" "SECTION"
    
    # 메트릭 서버
    check_https_service "https://kubernetes.default.svc.cluster.local:443/api/v1/namespaces/kube-system/services/https:metrics-server:https/proxy/metrics" \
        "RKE2 메트릭 서버" "200"
    
    # 컨트롤러 매니저
    check_https_service "https://kubernetes.default.svc.cluster.local:443/api/v1/namespaces/kube-system/services/https:kube-controller-manager:https/proxy/healthz" \
        "RKE2 컨트롤러 매니저" "200"
    
    # 스케줄러
    check_https_service "https://kubernetes.default.svc.cluster.local:443/api/v1/namespaces/kube-system/services/https:kube-scheduler:https/proxy/healthz" \
        "RKE2 스케줄러" "200"
    
    log_message "" "SECTION_END"
}

# 애플리케이션 서비스 체크
check_application_services() {
    log_message "\n=== 애플리케이션 서비스 체크 ===" "SECTION"
    
    # NodePort 서비스 확인
    local nodeport_services
    nodeport_services=$(kubectl get services --all-namespaces -o jsonpath='{range .items[?(@.spec.type=="NodePort")]}{.metadata.namespace}/{.metadata.name}:{.spec.ports[0].nodePort}{"\n"}{end}' 2>/dev/null)
    
    if [ -n "$nodeport_services" ]; then
        log_message "NodePort 서비스 발견:" "INFO"
        echo "$nodeport_services" >> ${LOG_FILE}
        
        # 각 NodePort 서비스 체크
        while IFS= read -r service_info; do
            if [ -n "$service_info" ]; then
                local namespace=$(echo "$service_info" | cut -d'/' -f1)
                local service_name=$(echo "$service_info" | cut -d'/' -f2 | cut -d':' -f1)
                local node_port=$(echo "$service_info" | cut -d':' -f2)
                
                # 노드 IP 가져오기
                local node_ip
                node_ip=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}' 2>/dev/null)
                
                if [ -n "$node_ip" ]; then
                    log_message "NodePort 서비스 체크: $namespace/$service_name ($node_ip:$node_port)" "INFO"
                    check_http_service "http://$node_ip:$node_port" \
                        "$namespace/$service_name NodePort" "200"
                fi
            fi
        done <<< "$nodeport_services"
    else
        log_message "NodePort 서비스가 없습니다." "INFO"
    fi
    
    # LoadBalancer 서비스 확인
    local lb_services
    lb_services=$(kubectl get services --all-namespaces -o jsonpath='{range .items[?(@.spec.type=="LoadBalancer")]}{.metadata.namespace}/{.metadata.name}:{.status.loadBalancer.ingress[0].ip}{"\n"}{end}' 2>/dev/null)
    
    if [ -n "$lb_services" ]; then
        log_message "LoadBalancer 서비스 발견:" "INFO"
        echo "$lb_services" >> ${LOG_FILE}
        
        # 각 LoadBalancer 서비스 체크
        while IFS= read -r service_info; do
            if [ -n "$service_info" ]; then
                local namespace=$(echo "$service_info" | cut -d'/' -f1)
                local service_name=$(echo "$service_info" | cut -d'/' -f2 | cut -d':' -f1)
                local external_ip=$(echo "$service_info" | cut -d':' -f2)
                
                if [ -n "$external_ip" ]; then
                    log_message "LoadBalancer 서비스 체크: $namespace/$service_name ($external_ip)" "INFO"
                    check_http_service "http://$external_ip" \
                        "$namespace/$service_name LoadBalancer" "200"
                fi
            fi
        done <<< "$lb_services"
    else
        log_message "LoadBalancer 서비스가 없습니다." "INFO"
    fi
    
    log_message "" "SECTION_END"
}

# 사용자 정의 서비스 체크
check_custom_services() {
    log_message "\n=== 사용자 정의 서비스 체크 ===" "SECTION"
    
    # 환경 변수에서 사용자 정의 서비스 목록 확인
    if [ -n "$CUSTOM_SERVICES" ]; then
        log_message "사용자 정의 서비스 체크:" "INFO"
        
        # 쉼표로 구분된 서비스 목록 파싱
        IFS=',' read -ra services <<< "$CUSTOM_SERVICES"
        for service in "${services[@]}"; do
            if [ -n "$service" ]; then
                local url
                local description
                
                # URL과 설명이 |로 구분되어 있는지 확인
                if [[ "$service" == *"|"* ]]; then
                    url=$(echo "$service" | cut -d'|' -f1)
                    description=$(echo "$service" | cut -d'|' -f2)
                else
                    url="$service"
                    description="사용자 정의 서비스 ($service)"
                fi
                
                # HTTP/HTTPS 자동 감지
                if [[ "$url" == https://* ]]; then
                    check_https_service "$url" "$description"
                else
                    check_http_service "$url" "$description"
                fi
            fi
        done
    else
        log_message "사용자 정의 서비스가 설정되지 않았습니다." "INFO"
        log_message "CUSTOM_SERVICES 환경 변수에 서비스 URL을 설정하세요." "INFO"
        log_message "예: CUSTOM_SERVICES='http://app1:8080/health|앱1 헬스체크,https://app2:8443/api|앱2 API'" "INFO"
    fi
    
    log_message "" "SECTION_END"
}

# 네트워크 연결성 체크
check_network_connectivity() {
    log_message "\n=== 네트워크 연결성 체크 ===" "SECTION"
    
    # 클러스터 내부 DNS 확인
    log_message "클러스터 내부 DNS 확인:" "INFO"
    safe_execute "nslookup kubernetes.default.svc.cluster.local" "클러스터 내부 DNS 확인"
    
    # 외부 DNS 확인
    log_message "외부 DNS 확인:" "INFO"
    safe_execute "nslookup google.com" "외부 DNS 확인"
    
    # 기본 게이트웨이 확인
    log_message "기본 게이트웨이 확인:" "INFO"
    safe_execute "ip route show default" "기본 게이트웨이 확인"
    
    # 네트워크 인터페이스 상태
    log_message "네트워크 인터페이스 상태:" "INFO"
    safe_execute "ip addr show" "네트워크 인터페이스 상태"
    
    log_message "" "SECTION_END"
}

# HTML 보고서 완성
finish_html() {
    cat >> ${HTML_LOG_FILE} << 'EOF'
    <script>
        document.getElementById('timestamp').textContent = new Date().toLocaleString();
    </script>
</body>
</html>
EOF
}

# 메인 실행 함수
main() {
    init_log_files
    
    # 시작 시간 기록
    local start_time=$(date +%s)
    
    log_message "RKE2 클러스터 서비스 체크 시작 - $(date)" "SUCCESS"
    
    # 각 체크 함수 실행
    check_kubernetes_api
    check_rke2_services
    check_application_services
    check_custom_services
    check_network_connectivity
    
    # 완료 시간 계산 및 요약
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    log_message "\n=== 서비스 체크 완료 ===" "SUCCESS"
    log_message "소요 시간: ${duration}초" "INFO"
    log_message "상세 결과는 다음 파일에서 확인하세요: ${LOG_FILE}" "INFO"
    log_message "HTML 보고서: ${HTML_LOG_FILE}" "INFO"
    
    # HTML 파일 완성
    finish_html
}

# 스크립트 실행
main
