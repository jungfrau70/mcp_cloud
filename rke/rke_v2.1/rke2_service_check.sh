#!/bin/bash

# RKE2 클러스터 서비스 체크 스크립트 (모듈화 버전)
# Version: 2.0.0
# Description: RKE2 클러스터 서비스 HTTP/HTTPS 체크 (공통 라이브러리 사용)

# 스크립트 정보
SCRIPT_NAME="rke2_service_check"
SCRIPT_VERSION="2.0.0"
SCRIPT_DESCRIPTION="RKE2 클러스터 서비스 체크"

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
ENV_FILE="${SCRIPT_DIR}/rke2_service_check.env"

# 명령행 옵션 파싱
parse_options() {
    local custom_services=""
    local config_file="$CONFIG_FILE"
    local env_file="$ENV_FILE"
    local verbose=false
    local help=false
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            -c|--config)
                config_file="$2"
                shift 2
                ;;
            -e|--env)
                env_file="$2"
                shift 2
                ;;
            -s|--services)
                custom_services="$2"
                shift 2
                ;;
            -v|--verbose)
                verbose=true
                shift
                ;;
            -h|--help)
                help=true
                shift
                ;;
            *)
                echo "알 수 없는 옵션: $1"
                show_help
                exit 1
                ;;
        esac
    done
    
    # 환경 변수로 설정
    if [ -n "$custom_services" ]; then
        export CUSTOM_SERVICES="$custom_services"
    fi
    
    if [ "$verbose" = true ]; then
        export LOG_LEVEL="DEBUG"
    fi
    
    if [ "$help" = true ]; then
        show_help
        exit 0
    fi
    
    # 설정 파일 경로 업데이트
    CONFIG_FILE="$config_file"
    ENV_FILE="$env_file"
}

# 도움말 표시
show_help() {
    cat << EOF
RKE2 클러스터 서비스 체크 스크립트 (v${SCRIPT_VERSION})

사용법: $0 [옵션]

옵션:
    -c, --config FILE     설정 파일 경로 (기본: config/rke2-monitoring.yaml)
    -e, --env FILE        환경 변수 파일 경로 (기본: rke2_service_check.env)
    -s, --services LIST   사용자 정의 서비스 목록 (URL|설명,URL|설명 형식)
    -v, --verbose         상세 로그 출력
    -h, --help            이 도움말 표시

환경 변수:
    CUSTOM_SERVICES       사용자 정의 서비스 목록
    KUBECONFIG           Kubernetes 설정 파일 경로
    LOG_LEVEL            로그 레벨 (INFO, DEBUG, WARNING, ERROR)
    TIMEOUT              HTTP 요청 타임아웃 (초)

예시:
    $0                                    # 기본 설정으로 실행
    $0 -c custom-config.yaml             # 사용자 정의 설정 파일 사용
    $0 -s "http://app1:8080/health|앱1"  # 특정 서비스만 체크
    $0 -v                                # 상세 로그 출력

EOF
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
    if ! is_check_enabled "service_check" "kubernetes_api"; then
        log_message "Kubernetes API 체크가 비활성화되어 있습니다." "INFO"
        return 0
    fi
    
    log_message "=== Kubernetes API 서버 체크 ===" "SECTION"
    
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
    if ! is_check_enabled "service_check" "rke2_services"; then
        log_message "RKE2 서비스 체크가 비활성화되어 있습니다." "INFO"
        return 0
    fi
    
    log_message "=== RKE2 특화 서비스 체크 ===" "SECTION"
    
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
    if ! is_check_enabled "service_check" "application_services"; then
        log_message "애플리케이션 서비스 체크가 비활성화되어 있습니다." "INFO"
        return 0
    fi
    
    log_message "=== 애플리케이션 서비스 체크 ===" "SECTION"
    
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
    if ! is_check_enabled "service_check" "custom_services"; then
        log_message "사용자 정의 서비스 체크가 비활성화되어 있습니다." "INFO"
        return 0
    fi
    
    log_message "=== 사용자 정의 서비스 체크 ===" "SECTION"
    
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
    if ! is_check_enabled "service_check" "network_connectivity"; then
        log_message "네트워크 연결성 체크가 비활성화되어 있습니다." "INFO"
        return 0
    fi
    
    log_message "=== 네트워크 연결성 체크 ===" "SECTION"
    
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

# 메인 함수
main() {
    local start_time=$(date +%s)
    
    # 명령행 옵션 파싱
    parse_options "$@"
    
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
    
    log_message "=== RKE2 클러스터 서비스 체크 시작 ===" "SECTION"
    log_message "스크립트 버전: $SCRIPT_VERSION" "INFO"
    log_message "설정 파일: $CONFIG_FILE" "INFO"
    log_message "로그 디렉토리: $LOG_DIR" "INFO"
    
    # 각 체크 함수 실행
    check_kubernetes_api
    check_rke2_services
    check_application_services
    check_custom_services
    check_network_connectivity
    
    # 실행 시간 계산
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    log_message "=== RKE2 클러스터 서비스 체크 완료 ===" "SECTION"
    log_message "소요 시간: ${duration}초" "INFO"
    log_message "로그 파일: $LOG_FILE" "INFO"
    log_message "HTML 보고서: $HTML_LOG_FILE" "INFO"
    
    # HTML 파일 완성
    finish_html
}

# 스크립트 실행
main "$@"
