#!/bin/bash

# Kubernetes Helper 모듈
# 역할: Kubernetes 기초 실습 관련 작업 실행 (클러스터 Context 설정, Workload 배포, 외부 접근 구성)
# 
# 사용법:
#   ./k8s-helper.sh --action <액션> --provider <프로바이더> [옵션]

# =============================================================================
# 환경 설정 로드
# =============================================================================
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 공통 환경 설정 로드
if [ -f "$SCRIPT_DIR/common-environment.env" ]; then
    source "$SCRIPT_DIR/common-environment.env"
else
    echo "ERROR: 공통 환경 설정 파일을 찾을 수 없습니다"
    exit 1
fi

# =============================================================================
# 사용법 출력
# =============================================================================
usage() {
    cat << EOF
Kubernetes Helper 모듈

사용법:
  $0 --action <액션> --provider <프로바이더> [옵션]

액션:
  setup-context           # 클러스터 Context 설정
  deploy-workload         # Workload 배포
  setup-external-access   # 외부 접근 구성
  troubleshoot            # 문제 해결
  cleanup                 # Kubernetes 리소스 정리
  status                  # 클러스터 상태 확인

프로바이더:
  aws                     # AWS EKS
  gcp                     # GCP GKE

옵션:
  --cluster-name <name>   # 클러스터 이름 (기본값: 환경변수)
  --region <region>       # 리전 (기본값: 환경변수)
  --namespace <ns>        # 네임스페이스 (기본값: default)
  --help, -h              # 도움말 표시

예시:
  $0 --action setup-context --provider aws
  $0 --action deploy-workload --provider gcp --namespace production
  $0 --action setup-external-access --provider aws
  $0 --action troubleshoot --provider gcp
  $0 --action cleanup --provider aws
EOF
}

# =============================================================================
# 액션별 상세 사용법 함수
# =============================================================================
show_action_help() {
    local action="$1"
    
    case "$action" in
        "setup-context")
            cat << EOF
SETUP-CONTEXT 액션 상세 사용법:

기능:
  - Kubernetes 클러스터 Context 설정
  - AWS EKS, GCP GKE 클러스터 연결
  - 클러스터 간 전환 설정

사용법:
  $0 --action setup-context --provider <provider> [옵션]

옵션:
  --provider <provider>   # 클라우드 프로바이더 (aws, gcp)
  --cluster-name <name>   # 클러스터 이름 (기본값: 환경변수)
  --region <region>       # 리전 (기본값: 환경변수)

예시:
  $0 --action setup-context --provider aws
  $0 --action setup-context --provider gcp --cluster-name my-cluster

설정되는 리소스:
  - kubectl context 설정
  - 클러스터 연결 확인
  - 클러스터 정보 표시

진행 상황:
  - 클러스터 연결
  - Context 설정
  - 연결 확인
  - 클러스터 정보 표시
EOF
            ;;
        "deploy-workload")
            cat << EOF
DEPLOY-WORKLOAD 액션 상세 사용법:

기능:
  - Kubernetes Workload 배포
  - Pod, Deployment, Service 생성
  - ConfigMap과 Secret 관리

사용법:
  $0 --action deploy-workload --provider <provider> [옵션]

옵션:
  --provider <provider>   # 클라우드 프로바이더 (aws, gcp)
  --namespace <ns>        # 네임스페이스 (기본값: default)
  --replicas <count>      # Pod 복제본 수 (기본값: 3)

예시:
  $0 --action deploy-workload --provider aws
  $0 --action deploy-workload --provider gcp --namespace production

생성되는 리소스:
  - Pod
  - Deployment
  - Service
  - ConfigMap
  - Secret

진행 상황:
  - YAML 파일 생성
  - 리소스 배포
  - 상태 확인
  - 서비스 접근 테스트
EOF
            ;;
        "setup-external-access")
            cat << EOF
SETUP-EXTERNAL-ACCESS 액션 상세 사용법:

기능:
  - 외부 접근을 위한 LoadBalancer 설정
  - NodePort 서비스 구성
  - Ingress 설정 (선택사항)

사용법:
  $0 --action setup-external-access --provider <provider> [옵션]

옵션:
  --provider <provider>   # 클라우드 프로바이더 (aws, gcp)
  --service-type <type>   # 서비스 타입 (LoadBalancer, NodePort)
  --port <port>           # 외부 포트 (기본값: 80)

예시:
  $0 --action setup-external-access --provider aws
  $0 --action setup-external-access --provider gcp --service-type NodePort

생성되는 리소스:
  - LoadBalancer Service
  - NodePort Service
  - Ingress (선택사항)

진행 상황:
  - 서비스 생성
  - 외부 IP 확인
  - 접근 테스트
  - 상태 확인
EOF
            ;;
        "troubleshoot")
            cat << EOF
TROUBLESHOOT 액션 상세 사용법:

기능:
  - Kubernetes 리소스 문제 진단
  - 로그 분석 및 이벤트 확인
  - 네트워크 연결 테스트

사용법:
  $0 --action troubleshoot --provider <provider> [옵션]

옵션:
  --provider <provider>   # 클라우드 프로바이더 (aws, gcp)
  --resource <name>       # 특정 리소스 진단
  --verbose               # 상세 정보 출력

예시:
  $0 --action troubleshoot --provider aws
  $0 --action troubleshoot --provider gcp --resource nginx-pod

진단되는 항목:
  - Pod 상태 및 이벤트
  - Service 및 Endpoint
  - 네트워크 연결
  - 리소스 사용량

진행 상황:
  - 리소스 상태 확인
  - 로그 분석
  - 이벤트 확인
  - 네트워크 테스트
EOF
            ;;
        "cleanup")
            cat << EOF
CLEANUP 액션 상세 사용법:

기능:
  - Kubernetes 리소스 정리
  - 배포된 Workload 제거
  - 네임스페이스 정리

사용법:
  $0 --action cleanup --provider <provider> [옵션]

옵션:
  --provider <provider>   # 클라우드 프로바이더 (aws, gcp)
  --namespace <ns>        # 정리할 네임스페이스
  --force                 # 확인 없이 강제 정리

예시:
  $0 --action cleanup --provider aws
  $0 --action cleanup --provider gcp --namespace production --force

정리되는 리소스:
  - Pod
  - Deployment
  - Service
  - ConfigMap
  - Secret

주의사항:
  - 정리된 리소스는 복구할 수 없습니다
  - --force 옵션 사용 시 확인 없이 정리됩니다
EOF
            ;;
        "status")
            cat << EOF
STATUS 액션 상세 사용법:

기능:
  - Kubernetes 클러스터 상태 확인
  - 리소스 목록 및 상태 표시
  - 클러스터 정보 확인

사용법:
  $0 --action status --provider <provider> [옵션]

옵션:
  --provider <provider>   # 클라우드 프로바이더 (aws, gcp)
  --format <format>       # 출력 형식 (table, json, yaml)
  --verbose               # 상세 정보 출력

예시:
  $0 --action status --provider aws
  $0 --action status --provider gcp --format json --verbose

확인되는 정보:
  - 클러스터 정보
  - 노드 상태
  - Pod 목록 및 상태
  - Service 목록
  - 네임스페이스 목록

출력 형식:
  - table: 테이블 형태 (기본값)
  - json: JSON 형태
  - yaml: YAML 형태
EOF
            ;;
        *)
            cat << EOF
알 수 없는 액션: $action

사용 가능한 액션:
  - setup-context: 클러스터 Context 설정
  - deploy-workload: Workload 배포
  - setup-external-access: 외부 접근 구성
  - troubleshoot: 문제 해결
  - cleanup: 리소스 정리
  - status: 상태 확인

각 액션의 상세 사용법을 보려면:
  $0 --help --action <액션명>
EOF
            ;;
    esac
}

# =============================================================================
# --help 옵션 처리 로직
# =============================================================================
handle_help_option() {
    local action="$1"
    
    if [ -n "$action" ]; then
        show_action_help "$action"
    else
        usage
    fi
    exit 0
}

# =============================================================================
# 환경 검증
# =============================================================================
validate_environment() {
    log_step "Kubernetes 환경 검증 중..."
    
    # kubectl 설치 확인
    if ! check_command "kubectl"; then
        log_error "kubectl이 설치되지 않았습니다."
        return 1
    fi
    
    # 프로바이더별 도구 확인
    case "$provider" in
        "aws")
            if ! check_command "aws"; then
                log_error "AWS CLI가 설치되지 않았습니다."
                return 1
            fi
            if ! aws sts get-caller-identity &> /dev/null; then
                log_error "AWS 자격 증명이 설정되지 않았습니다."
                return 1
            fi
            ;;
        "gcp")
            if ! check_command "gcloud"; then
                log_error "gcloud CLI가 설치되지 않았습니다."
                return 1
            fi
            if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" | head -n1 &> /dev/null; then
                log_error "GCP 자격 증명이 설정되지 않았습니다."
                return 1
            fi
            ;;
    esac
    
    log_success "Kubernetes 환경 검증 완료"
    return 0
}

# =============================================================================
# 클러스터 Context 설정
# =============================================================================
setup_context() {
    local cluster_name="${1:-$EKS_CLUSTER_NAME}"
    local region="${2:-$AWS_REGION}"
    
    log_header "Kubernetes 클러스터 Context 설정: $cluster_name"
    
    case "$provider" in
        "aws")
            log_info "AWS EKS 클러스터 연결 중..."
            if aws eks update-kubeconfig --region "$region" --name "$cluster_name"; then
                log_success "AWS EKS 클러스터 연결 완료: $cluster_name"
            else
                log_error "AWS EKS 클러스터 연결 실패"
                return 1
            fi
            ;;
        "gcp")
            log_info "GCP GKE 클러스터 연결 중..."
            if gcloud container clusters get-credentials "$cluster_name" --zone "$region"; then
                log_success "GCP GKE 클러스터 연결 완료: $cluster_name"
            else
                log_error "GCP GKE 클러스터 연결 실패"
                return 1
            fi
            ;;
    esac
    
    # 클러스터 정보 확인
    log_info "클러스터 정보:"
    kubectl cluster-info
    
    # Context 확인
    log_info "현재 Context:"
    kubectl config current-context
    
    update_progress "setup-context" "completed" "클러스터 Context 설정 완료"
    return 0
}

# =============================================================================
# Workload 배포
# =============================================================================
deploy_workload() {
    local namespace="${1:-default}"
    local replicas="${2:-3}"
    
    log_header "Kubernetes Workload 배포: $namespace"
    
    # 네임스페이스 생성
    if [ "$namespace" != "default" ]; then
        log_info "네임스페이스 생성: $namespace"
        kubectl create namespace "$namespace" --dry-run=client -o yaml | kubectl apply -f -
    fi
    
    # Pod 생성
    log_info "Pod 생성 중..."
    cat > nginx-pod.yaml << EOF
apiVersion: v1
kind: Pod
metadata:
  name: nginx-pod
  namespace: $namespace
  labels:
    app: nginx
spec:
  containers:
  - name: nginx
    image: nginx:1.21
    ports:
    - containerPort: 80
EOF
    
    kubectl apply -f nginx-pod.yaml
    
    # Deployment 생성
    log_info "Deployment 생성 중..."
    cat > nginx-deployment.yaml << EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  namespace: $namespace
spec:
  replicas: $replicas
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.21
        ports:
        - containerPort: 80
        resources:
          requests:
            memory: "64Mi"
            cpu: "250m"
          limits:
            memory: "128Mi"
            cpu: "500m"
EOF
    
    kubectl apply -f nginx-deployment.yaml
    
    # Service 생성
    log_info "Service 생성 중..."
    cat > nginx-service.yaml << EOF
apiVersion: v1
kind: Service
metadata:
  name: nginx-service
  namespace: $namespace
spec:
  selector:
    app: nginx
  ports:
  - port: 80
    targetPort: 80
  type: ClusterIP
EOF
    
    kubectl apply -f nginx-service.yaml
    
    # ConfigMap 생성
    log_info "ConfigMap 생성 중..."
    cat > nginx-configmap.yaml << EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: nginx-config
  namespace: $namespace
data:
  nginx.conf: |
    server {
        listen 80;
        server_name localhost;
        location / {
            root /usr/share/nginx/html;
            index index.html;
        }
    }
EOF
    
    kubectl apply -f nginx-configmap.yaml
    
    # Secret 생성
    log_info "Secret 생성 중..."
    kubectl create secret generic nginx-secret \
        --from-literal=username=admin \
        --from-literal=password=secret \
        --namespace="$namespace" \
        --dry-run=client -o yaml | kubectl apply -f -
    
    # 배포 상태 확인
    log_info "배포 상태 확인 중..."
    kubectl get pods -n "$namespace"
    kubectl get services -n "$namespace"
    kubectl get configmaps -n "$namespace"
    kubectl get secrets -n "$namespace"
    
    # 정리
    rm -f nginx-pod.yaml nginx-deployment.yaml nginx-service.yaml nginx-configmap.yaml
    
    update_progress "deploy-workload" "completed" "Workload 배포 완료"
    return 0
}

# =============================================================================
# 외부 접근 구성
# =============================================================================
setup_external_access() {
    local service_type="${1:-LoadBalancer}"
    local port="${2:-80}"
    local namespace="${3:-default}"
    
    log_header "Kubernetes 외부 접근 구성: $service_type"
    
    # LoadBalancer Service 생성
    log_info "LoadBalancer Service 생성 중..."
    cat > nginx-loadbalancer.yaml << EOF
apiVersion: v1
kind: Service
metadata:
  name: nginx-loadbalancer
  namespace: $namespace
spec:
  selector:
    app: nginx
  ports:
  - port: $port
    targetPort: 80
  type: $service_type
EOF
    
    kubectl apply -f nginx-loadbalancer.yaml
    
    # 서비스 상태 확인
    log_info "서비스 상태 확인 중..."
    kubectl get services nginx-loadbalancer -n "$namespace"
    
    # 외부 IP 대기
    if [ "$service_type" = "LoadBalancer" ]; then
        log_info "외부 IP 할당 대기 중..."
        kubectl wait --for=condition=Ready service/nginx-loadbalancer -n "$namespace" --timeout=300s
        
        # 외부 IP 확인
        local external_ip
        external_ip=$(kubectl get service nginx-loadbalancer -n "$namespace" -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
        if [ -n "$external_ip" ]; then
            log_success "외부 IP: $external_ip"
            log_info "접속 테스트: curl http://$external_ip"
        else
            log_warning "외부 IP가 아직 할당되지 않았습니다."
        fi
    fi
    
    # 정리
    rm -f nginx-loadbalancer.yaml
    
    update_progress "setup-external-access" "completed" "외부 접근 구성 완료"
    return 0
}

# =============================================================================
# 문제 해결
# =============================================================================
troubleshoot() {
    local resource="${1:-}"
    local namespace="${2:-default}"
    
    log_header "Kubernetes 문제 해결"
    
    # 리소스 상태 확인
    log_info "리소스 상태 확인 중..."
    kubectl get pods -n "$namespace"
    kubectl get services -n "$namespace"
    kubectl get deployments -n "$namespace"
    
    # 특정 리소스 진단
    if [ -n "$resource" ]; then
        log_info "특정 리소스 진단: $resource"
        kubectl describe pod "$resource" -n "$namespace"
        kubectl logs "$resource" -n "$namespace"
    else
        # 모든 Pod 진단
        log_info "모든 Pod 진단 중..."
        for pod in $(kubectl get pods -n "$namespace" -o jsonpath='{.items[*].metadata.name}'); do
            log_info "Pod 진단: $pod"
            kubectl describe pod "$pod" -n "$namespace"
            kubectl logs "$pod" -n "$namespace" --tail=10
        done
    fi
    
    # 이벤트 확인
    log_info "이벤트 확인 중..."
    kubectl get events -n "$namespace" --sort-by=.metadata.creationTimestamp
    
    # 네트워크 테스트
    log_info "네트워크 테스트 중..."
    kubectl run test-pod --image=busybox --rm -it --restart=Never -- wget -qO- nginx-service -n "$namespace" || true
    
    update_progress "troubleshoot" "completed" "문제 해결 완료"
    return 0
}

# =============================================================================
# Kubernetes 리소스 정리
# =============================================================================
cleanup_k8s() {
    local namespace="${1:-default}"
    local force="${2:-false}"
    
    log_header "Kubernetes 리소스 정리: $namespace"
    
    if [ "$force" != "true" ]; then
        log_warning "정리할 리소스:"
        log_info "Pod: $(kubectl get pods -n "$namespace" --no-headers | wc -l)개"
        log_info "Service: $(kubectl get services -n "$namespace" --no-headers | wc -l)개"
        log_info "Deployment: $(kubectl get deployments -n "$namespace" --no-headers | wc -l)개"
        
        read -p "정말 정리하시겠습니까? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_info "정리가 취소되었습니다."
            return 0
        fi
    fi
    
    log_info "Kubernetes 리소스 정리 중..."
    update_progress "cleanup" "started" "Kubernetes 리소스 정리 시작"
    
    # 리소스 삭제
    kubectl delete deployment nginx-deployment -n "$namespace" --ignore-not-found=true
    kubectl delete service nginx-service -n "$namespace" --ignore-not-found=true
    kubectl delete service nginx-loadbalancer -n "$namespace" --ignore-not-found=true
    kubectl delete pod nginx-pod -n "$namespace" --ignore-not-found=true
    kubectl delete configmap nginx-config -n "$namespace" --ignore-not-found=true
    kubectl delete secret nginx-secret -n "$namespace" --ignore-not-found=true
    
    # 네임스페이스 정리 (default가 아닌 경우)
    if [ "$namespace" != "default" ]; then
        kubectl delete namespace "$namespace" --ignore-not-found=true
    fi
    
    log_success "Kubernetes 리소스 정리 완료"
    update_progress "cleanup" "completed" "Kubernetes 리소스 정리 완료"
    return 0
}

# =============================================================================
# 클러스터 상태 확인
# =============================================================================
check_k8s_status() {
    local format="${1:-table}"
    local namespace="${2:-default}"
    
    log_header "Kubernetes 클러스터 상태 확인"
    
    # 클러스터 정보
    log_info "클러스터 정보:"
    kubectl cluster-info
    
    # 노드 상태
    log_info "노드 상태:"
    case "$format" in
        "json")
            kubectl get nodes -o json | jq .
            ;;
        "yaml")
            kubectl get nodes -o yaml
            ;;
        *)
            kubectl get nodes
            ;;
    esac
    
    # Pod 상태
    log_info "Pod 상태:"
    case "$format" in
        "json")
            kubectl get pods -n "$namespace" -o json | jq .
            ;;
        "yaml")
            kubectl get pods -n "$namespace" -o yaml
            ;;
        *)
            kubectl get pods -n "$namespace"
            ;;
    esac
    
    # Service 상태
    log_info "Service 상태:"
    case "$format" in
        "json")
            kubectl get services -n "$namespace" -o json | jq .
            ;;
        "yaml")
            kubectl get services -n "$namespace" -o yaml
            ;;
        *)
            kubectl get services -n "$namespace"
            ;;
    esac
    
    update_progress "status" "completed" "클러스터 상태 확인 완료"
    return 0
}

# =============================================================================
# 메인 실행 로직
# =============================================================================
main() {
    local action=""
    local provider="aws"
    local cluster_name="$EKS_CLUSTER_NAME"
    local region="$AWS_REGION"
    local namespace="default"
    local replicas="3"
    local service_type="LoadBalancer"
    local port="80"
    local resource=""
    local force="false"
    local format="table"
    local verbose="false"
    
    # 인수 파싱
    while [[ $# -gt 0 ]]; do
        case $1 in
            --action)
                action="$2"
                shift 2
                ;;
            --provider)
                provider="$2"
                shift 2
                ;;
            --cluster-name)
                cluster_name="$2"
                shift 2
                ;;
            --region)
                region="$2"
                shift 2
                ;;
            --namespace)
                namespace="$2"
                shift 2
                ;;
            --replicas)
                replicas="$2"
                shift 2
                ;;
            --service-type)
                service_type="$2"
                shift 2
                ;;
            --port)
                port="$2"
                shift 2
                ;;
            --resource)
                resource="$2"
                shift 2
                ;;
            --force)
                force="true"
                shift
                ;;
            --format)
                format="$2"
                shift 2
                ;;
            --verbose)
                verbose="true"
                shift
                ;;
            --help|-h)
                # --help 옵션 처리
                if [ "$2" = "--action" ] && [ -n "$3" ]; then
                    handle_help_option "$3"
                else
                    usage
                    exit 0
                fi
                ;;
            *)
                log_error "알 수 없는 옵션: $1"
                usage
                exit 1
                ;;
        esac
    done
    
    # 액션이 지정되지 않은 경우
    if [ -z "$action" ]; then
        log_error "액션이 지정되지 않았습니다."
        usage
        exit 1
    fi
    
    # 환경 검증
    if ! validate_environment; then
        log_error "환경 검증 실패"
        exit 1
    fi
    
    # 액션 실행
    case "$action" in
        "setup-context")
            setup_context "$cluster_name" "$region"
            ;;
        "deploy-workload")
            deploy_workload "$namespace" "$replicas"
            ;;
        "setup-external-access")
            setup_external_access "$service_type" "$port" "$namespace"
            ;;
        "troubleshoot")
            troubleshoot "$resource" "$namespace"
            ;;
        "cleanup")
            cleanup_k8s "$namespace" "$force"
            ;;
        "status")
            check_k8s_status "$format" "$namespace"
            ;;
        *)
            log_error "알 수 없는 액션: $action"
            usage
            exit 1
            ;;
    esac
    
    # 실행 요약 보고
    generate_summary
}

# =============================================================================
# 스크립트 실행
# =============================================================================
main "$@"
