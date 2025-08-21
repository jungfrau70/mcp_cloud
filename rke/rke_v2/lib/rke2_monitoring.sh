#!/bin/bash

# RKE2 모니터링 라이브러리
# Version: 1.0.0
# Description: RKE2 모니터링 스크립트 모니터링 함수들

# 안전한 명령어 실행 함수 (RKE2 특화 개선)
safe_execute() {
    local command="$1"
    local timeout="${2:-${TIMEOUT:-30}}"
    local retry_count="${3:-0}"
    local max_retries="${4:-2}"
    
    # 명령어 검증
    if ! validate_command "$command"; then
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

# RKE2 특화 점검 함수들

# RKE2 설정 및 서비스 상태 점검
check_rke2_specific() {
    log_message "RKE2 특화 구성 및 상태 점검" "SECTION"
    
    # RKE2 설정 파일 확인
    log_message "[RKE2 설정 파일]"
    safe_execute "ls -la ${RKE2_CONFIG_PATH}/"
    safe_execute "cat ${RKE2_CONFIG_PATH}/config.yaml 2>/dev/null || echo '설정 파일 없음'"
    
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

# RKE2 etcd 상태 점검
check_rke2_etcd() {
    log_message "RKE2 etcd 상태 (내장) 점검" "SECTION"
    
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

# RKE2 containerd 상태 점검
check_rke2_containerd() {
    log_message "RKE2 containerd 상태 점검" "SECTION"
    
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

# RKE2 보안 설정 점검
check_rke2_security() {
    log_message "RKE2 보안 설정 점검" "SECTION"
    
    # SELinux 상태
    safe_execute "getenforce"
    safe_execute "sestatus"
    
    # AppArmor 상태
    safe_execute "aa-status 2>/dev/null || echo 'AppArmor 사용 안함'"
    
    # 방화벽 상태
    safe_execute "firewall-cmd --state"
    safe_execute "firewall-cmd --list-all"
    
    # RKE2 보안 프로파일
    safe_execute "grep -r 'profile' ${RKE2_CONFIG_PATH}/config.yaml 2>/dev/null || echo '보안 프로파일 설정 없음'"
    
    # mTLS 설정 확인
    safe_execute "kubectl get configmap -n kube-system rke2-canal-config -o yaml 2>/dev/null || echo 'Canal 설정 없음'"
    
    log_message "" "SECTION_END"
}

# RKE2 로그 점검
check_rke2_logs() {
    log_message "RKE2 장애 징후(로그) 점검" "SECTION"
    
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

# 클러스터 정보 점검
check_cluster_info() {
    log_message "RKE2 및 클러스터 정보 확인" "SECTION"
    safe_execute "rke2 -v"
    safe_execute "kubectl version --short"
    safe_execute "kubectl cluster-info"
    log_message "" "SECTION_END"
}

# 컨트롤 플레인 상태 점검
check_control_plane() {
    log_message "etcd 및 Control-plane 상태 점검" "SECTION"
    safe_execute "kubectl get pods -n kube-system -l component=etcd -o wide"
    
    # etcd health (한 노드에서만 수행)
    local ETCD_POD=$(kubectl get pod -n kube-system -l component=etcd -o jsonpath='{.items[0].metadata.name}')
    if [[ -n "$ETCD_POD" ]]; then
        safe_execute "kubectl -n kube-system exec -it $ETCD_POD -- etcdctl endpoint health --cluster"
    fi
    
    safe_execute "kubectl get pods -n kube-system -l 'component in (etcd, kube-apiserver, kube-controller-manager, kube-scheduler)' -o wide"
    log_message "" "SECTION_END"
}

# 노드 개요 점검
check_node_overview() {
    log_message "전체 노드/레이블/taint 현황 점검" "SECTION"
    safe_execute "kubectl get nodes -o wide"
    safe_execute "kubectl get nodes --show-labels"
    safe_execute "kubectl get nodes -o json | jq '.items[].spec.taints'"
    log_message "" "SECTION_END"
}

# 역할별 노드 점검
check_role_nodes() {
    log_message "Master/Worker/OSS Node 상태 점검" "SECTION"
    declare -A node_roles=( ["master"]="node-role.kubernetes.io/master=" ["worker"]="node-role.kubernetes.io/worker=" ["oss"]="node-role.kubernetes.io/oss=" )

    for role in "${!node_roles[@]}"; do
        log_message "[${role^^} Node]" "SUCCESS"
        local NODES=$(kubectl get nodes -l ${node_roles[$role]} -o jsonpath='{.items[*].metadata.name}')
        if [[ -z "$NODES" ]]; then
            log_message "해당 역할($role) 노드가 존재하지 않습니다" "WARNING"
            continue
        fi
        for NODE in $NODES; do
            log_message "--- $role: $NODE ---"
            safe_execute "kubectl describe node $NODE"
            safe_execute "kubectl get pods -A -o wide --field-selector spec.nodeName=$NODE"
        done
    done
    log_message "" "SECTION_END"
}

# 네임스페이스/파드 상태 점검
check_namespace_pod() {
    log_message "네임스페이스/파드/리소스 상태 점검" "SECTION"
    safe_execute "kubectl get ns"
    safe_execute "kubectl get pods -A -o wide"
    safe_execute "kubectl top node"
    safe_execute "kubectl top pod -A"
    log_message "" "SECTION_END"
}

# 스토리지 및 인프라 점검
check_storage_infra() {
    log_message "스토리지 및 인프라(운영툴/서비스 등) 점검" "SECTION"
    safe_execute "kubectl get sc"
    safe_execute "kubectl get pv -A"
    safe_execute "kubectl get pvc -A"
    safe_execute "kubectl get deploy -A"
    safe_execute "kubectl get svc -A"
    safe_execute "kubectl get ingress -A"
    safe_execute "kubectl get hpa -A"
    safe_execute "kubectl get pdb -A"
    safe_execute "kubectl get rs -A"
    safe_execute "kubectl get networkpolicy -A"
    log_message "" "SECTION_END"
}

# OSS 운영툴 상태 점검
check_oss_tools() {
    log_message "운영툴(Grafana, Prometheus, Loki, Harbor) 상태 점검" "SECTION"
    safe_execute "kubectl get pods -n monitoring"
    safe_execute "kubectl get pods -n logging"
    safe_execute "kubectl get pods -n harbor"
    safe_execute "kubectl get svc -n harbor"
    safe_execute "kubectl get ingress -n harbor"
    safe_execute "kubectl get pods -n kube-system | grep csi-azure"
    log_message "" "SECTION_END"
}

# 시스템 점검
check_system() {
    log_message "시스템 리소스 및 보안 상태 점검" "SECTION"
    safe_execute "free -h"
    safe_execute "df -h"
    safe_execute "uptime"
    safe_execute "ss -tulpn | grep -E '6443|2379|2380|10250'"
    safe_execute "ps aux | grep -E 'rke2|etcd|containerd'"
    safe_execute "getenforce"
    safe_execute "firewall-cmd --state"
    safe_execute "sysctl -a | grep -E 'vm.max_map_count|fs.inotify.max_user_watches'"
    log_message "" "SECTION_END"
}

# 파드 상태 점검
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

# 파드 리소스 점검
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

# 파드 네트워킹 점검
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

# 파드 볼륨 점검
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

# 파드 로그 점검
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

# RKE2 파드 보안 점검
check_rke2_pod_security() {
    local namespace="$1"
    log_message "[RKE2 파드 보안 - $namespace]" "SECTION"
    
    # Pod Security Standards 확인
    safe_execute "kubectl get pods -n $namespace -o jsonpath='{range .items[*]}{.metadata.name}{\"\\t\"}{.spec.securityContext.runAsNonRoot}{\"\\t\"}{.spec.securityContext.runAsUser}{\"\\n\"}{end}'"
    
    # Security Context 확인
    safe_execute "kubectl get pods -n $namespace -o jsonpath='{range .items[*]}{.metadata.name}{\"\\t\"}{.spec.containers[0].securityContext.allowPrivilegeEscalation}{\"\\t\"}{.spec.containers[0].securityContext.readOnlyRootFilesystem}{\"\\n\"}{end}'"
    
    log_message "" "SECTION_END"
}

# RKE2 containerd 컨테이너 점검
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

# 네임스페이스 목록 가져오기
get_namespaces() {
    if [[ -n "$NAMESPACE" ]]; then
        echo "$NAMESPACE"
    else
        kubectl get namespaces --no-headers -o custom-columns=NAME:.metadata.name 2>/dev/null || echo "default"
    fi
}

# ========================================
# 서비스 체크 함수들
# ========================================

# HTTP 서비스 체크 함수
check_http_service() {
    local url="$1"
    local description="$2"
    local expected_status="${3:-200}"
    local timeout="${4:-${TIMEOUT:-10}}"
    
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
    local timeout="${4:-${TIMEOUT:-10}}"
    
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

# 네임스페이스별 서비스 체크 함수
check_namespace_services() {
    local namespace="$1"
    log_message "=== 네임스페이스 서비스 체크: $namespace ===" "SECTION"
    
    # 해당 네임스페이스의 서비스 목록 가져오기
    local services=$(kubectl get services -n "$namespace" -o jsonpath='{range .items[*]}{.metadata.name}:{.spec.type}:{.spec.ports[0].port}{"\n"}{end}' 2>/dev/null)
    
    if [ -n "$services" ]; then
        log_message "네임스페이스 $namespace의 서비스 발견:" "INFO"
        echo "$services" >> ${LOG_FILE}
        
        while IFS= read -r service_info; do
            if [ -n "$service_info" ]; then
                local service_name=$(echo "$service_info" | cut -d':' -f1)
                local service_type=$(echo "$service_info" | cut -d':' -f2)
                local service_port=$(echo "$service_info" | cut -d':' -f3)
                
                log_message "서비스 체크: $service_name ($service_type, 포트: $service_port)" "INFO"
                
                # 서비스 타입별 체크
                case $service_type in
                    "NodePort")
                        local node_port=$(kubectl get service "$service_name" -n "$namespace" -o jsonpath='{.spec.ports[0].nodePort}' 2>/dev/null)
                        local node_ip=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}' 2>/dev/null)
                        
                        if [ -n "$node_port" ] && [ -n "$node_ip" ]; then
                            check_http_service "http://$node_ip:$node_port" \
                                "$namespace/$service_name NodePort" "200"
                        fi
                        ;;
                    "LoadBalancer")
                        local external_ip=$(kubectl get service "$service_name" -n "$namespace" -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null)
                        
                        if [ -n "$external_ip" ]; then
                            check_http_service "http://$external_ip:$service_port" \
                                "$namespace/$service_name LoadBalancer" "200"
                        fi
                        ;;
                    "ClusterIP")
                        # ClusterIP는 프록시를 통해 접근
                        local cluster_ip=$(kubectl get service "$service_name" -n "$namespace" -o jsonpath='{.spec.clusterIP}' 2>/dev/null)
                        
                        if [ -n "$cluster_ip" ]; then
                            log_message "ClusterIP 서비스 $service_name ($cluster_ip:$service_port) - 프록시 접근 필요" "INFO"
                        fi
                        ;;
                esac
            fi
        done <<< "$services"
    else
        log_message "네임스페이스 $namespace에 서비스가 없습니다." "INFO"
    fi
    
    log_message "" "SECTION_END"
}

# 통합 서비스 체크 함수
run_service_checks() {
    log_message "=== RKE2 클러스터 서비스 체크 시작 ===" "SECTION"
    
    # 각 체크 함수 실행
    check_kubernetes_api
    check_rke2_services
    check_application_services
    check_custom_services
    check_network_connectivity
    
    log_message "=== RKE2 클러스터 서비스 체크 완료 ===" "SECTION"
}
