#!/bin/bash

# AWS EKS Monitoring Helper 모듈
# 역할: AWS EKS 클러스터 모니터링 관련 작업 실행 (클러스터 생성, 앱 배포, 모니터링 설정)
# 
# 사용법:
#   ./aws-eks-monitoring-helper.sh --action <액션> [옵션]

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

# AWS 환경 설정 로드
if [ -f "$SCRIPT_DIR/aws-environment.env" ]; then
    source "$SCRIPT_DIR/aws-environment.env"
else
    echo "ERROR: AWS 환경 설정 파일을 찾을 수 없습니다"
    exit 1
fi

# =============================================================================
# 사용법 출력
# =============================================================================
usage() {
    cat << EOF
AWS EKS Monitoring Helper 모듈

사용법:
  $0 --action <액션> [옵션]

액션:
  create-cluster        # EKS 클러스터 생성
  deploy-app            # 애플리케이션 배포
  setup-monitoring      # 모니터링 설정
  install-prometheus    # Prometheus 설치
  install-grafana       # Grafana 설치
  setup-alerts          # 알림 설정
  cleanup               # 리소스 정리
  status                # 클러스터 상태 확인

옵션:
  --cluster-name <name> # EKS 클러스터 이름 (기본값: eks-monitoring-cluster)
  --node-type <type>    # 노드 인스턴스 타입 (기본값: t3.medium)
  --node-count <count>  # 노드 개수 (기본값: 2)
  --region <region>     # AWS 리전 (기본값: 환경변수)
  --namespace <ns>      # Kubernetes 네임스페이스 (기본값: monitoring)
  --help, -h            # 도움말 표시

예시:
  $0 --action create-cluster
  $0 --action deploy-app --cluster-name my-cluster
  $0 --action setup-monitoring --namespace monitoring
  $0 --action install-prometheus
  $0 --action install-grafana
  $0 --action setup-alerts
  $0 --action status
  $0 --action cleanup
EOF
}

# =============================================================================
# 액션별 상세 사용법 함수
# =============================================================================
show_action_help() {
    local action="$1"
    
    case "$action" in
        "create-cluster")
            cat << EOF
CREATE-CLUSTER 액션 상세 사용법:

기능:
  - AWS EKS 클러스터 생성
  - 노드 그룹 설정
  - 클러스터 접속 설정

사용법:
  $0 --action create-cluster [옵션]

옵션:
  --cluster-name <name> # EKS 클러스터 이름 (기본값: eks-monitoring-cluster)
  --node-type <type>    # 노드 인스턴스 타입 (기본값: t3.medium)
  --node-count <count>  # 노드 개수 (기본값: 2)
  --region <region>     # AWS 리전 (기본값: 환경변수)

예시:
  $0 --action create-cluster
  $0 --action create-cluster --cluster-name my-cluster --node-type t3.large

생성되는 리소스:
  - EKS 클러스터
  - 노드 그룹
  - IAM 역할
  - 보안 그룹

진행 상황:
  - 클러스터 생성
  - 노드 그룹 생성
  - kubectl 설정
  - 클러스터 연결 확인
EOF
            ;;
        "deploy-app")
            cat << EOF
DEPLOY-APP 액션 상세 사용법:

기능:
  - 샘플 애플리케이션 배포
  - 서비스 및 인그레스 설정
  - 로드 밸런서 구성

사용법:
  $0 --action deploy-app [옵션]

옵션:
  --cluster-name <name> # EKS 클러스터 이름
  --namespace <ns>      # Kubernetes 네임스페이스 (기본값: default)
  --region <region>     # AWS 리전 (기본값: 환경변수)

예시:
  $0 --action deploy-app --cluster-name my-cluster
  $0 --action deploy-app --cluster-name my-cluster --namespace monitoring

배포되는 구성요소:
  - 샘플 애플리케이션
  - 서비스
  - 인그레스
  - 로드 밸런서

진행 상황:
  - 애플리케이션 배포
  - 서비스 생성
  - 인그레스 설정
  - 접속 확인
EOF
            ;;
        "setup-monitoring")
            cat << EOF
SETUP-MONITORING 액션 상세 사용법:

기능:
  - 모니터링 네임스페이스 생성
  - Prometheus 및 Grafana 설치
  - 모니터링 대시보드 설정

사용법:
  $0 --action setup-monitoring [옵션]

옵션:
  --cluster-name <name> # EKS 클러스터 이름
  --namespace <ns>      # Kubernetes 네임스페이스 (기본값: monitoring)
  --region <region>     # AWS 리전 (기본값: 환경변수)

예시:
  $0 --action setup-monitoring --cluster-name my-cluster
  $0 --action setup-monitoring --cluster-name my-cluster --namespace monitoring

설치되는 구성요소:
  - Prometheus
  - Grafana
  - Node Exporter
  - kube-state-metrics

진행 상황:
  - 네임스페이스 생성
  - Helm 차트 설치
  - 서비스 설정
  - 대시보드 구성
EOF
            ;;
        "install-prometheus")
            cat << EOF
INSTALL-PROMETHEUS 액션 상세 사용법:

기능:
  - Prometheus 서버 설치
  - 메트릭 수집 설정
  - 서비스 모니터링 구성

사용법:
  $0 --action install-prometheus [옵션]

옵션:
  --cluster-name <name> # EKS 클러스터 이름
  --namespace <ns>      # Kubernetes 네임스페이스 (기본값: monitoring)
  --region <region>     # AWS 리전 (기본값: 환경변수)

예시:
  $0 --action install-prometheus --cluster-name my-cluster
  $0 --action install-prometheus --cluster-name my-cluster --namespace monitoring

설치되는 구성요소:
  - Prometheus 서버
  - 설정 파일
  - 서비스 모니터
  - 알림 규칙

진행 상황:
  - Prometheus 설치
  - 설정 파일 구성
  - 서비스 시작
  - 상태 확인
EOF
            ;;
        "install-grafana")
            cat << EOF
INSTALL-GRAFANA 액션 상세 사용법:

기능:
  - Grafana 서버 설치
  - Prometheus 데이터 소스 연결
  - 모니터링 대시보드 생성

사용법:
  $0 --action install-grafana [옵션]

옵션:
  --cluster-name <name> # EKS 클러스터 이름
  --namespace <ns>      # Kubernetes 네임스페이스 (기본값: monitoring)
  --region <region>     # AWS 리전 (기본값: 환경변수)

예시:
  $0 --action install-grafana --cluster-name my-cluster
  $0 --action install-grafana --cluster-name my-cluster --namespace monitoring

설치되는 구성요소:
  - Grafana 서버
  - 데이터 소스 설정
  - 대시보드
  - 사용자 설정

진행 상황:
  - Grafana 설치
  - 데이터 소스 연결
  - 대시보드 생성
  - 접속 확인
EOF
            ;;
        "setup-alerts")
            cat << EOF
SETUP-ALERTS 액션 상세 사용법:

기능:
  - 알림 규칙 설정
  - Slack 알림 구성
  - 이메일 알림 설정

사용법:
  $0 --action setup-alerts [옵션]

옵션:
  --cluster-name <name> # EKS 클러스터 이름
  --namespace <ns>      # Kubernetes 네임스페이스 (기본값: monitoring)
  --region <region>     # AWS 리전 (기본값: 환경변수)

예시:
  $0 --action setup-alerts --cluster-name my-cluster
  $0 --action setup-alerts --cluster-name my-cluster --namespace monitoring

설정되는 알림:
  - CPU 사용률 알림
  - 메모리 사용률 알림
  - 디스크 사용률 알림
  - Pod 상태 알림

진행 상황:
  - 알림 규칙 생성
  - 알림 채널 설정
  - 테스트 알림
  - 알림 확인
EOF
            ;;
        "cleanup")
            cat << EOF
CLEANUP 액션 상세 사용법:

기능:
  - EKS 클러스터 리소스 정리
  - 모니터링 구성요소 삭제
  - 관련 리소스 정리

사용법:
  $0 --action cleanup [옵션]

옵션:
  --cluster-name <name> # 삭제할 EKS 클러스터 이름
  --region <region>     # AWS 리전 (기본값: 환경변수)
  --force               # 확인 없이 강제 정리

예시:
  $0 --action cleanup --cluster-name my-cluster
  $0 --action cleanup --cluster-name my-cluster --force

정리되는 리소스:
  - EKS 클러스터
  - 노드 그룹
  - IAM 역할
  - 관련 리소스

주의사항:
  - 정리된 리소스는 복구할 수 없습니다
  - --force 옵션 사용 시 확인 없이 정리됩니다
EOF
            ;;
        "status")
            cat << EOF
STATUS 액션 상세 사용법:

기능:
  - EKS 클러스터 상태 확인
  - 모니터링 구성요소 상태 확인
  - 리소스 사용량 확인

사용법:
  $0 --action status [옵션]

옵션:
  --cluster-name <name> # 확인할 EKS 클러스터 이름
  --namespace <ns>      # Kubernetes 네임스페이스 (기본값: monitoring)
  --region <region>     # AWS 리전 (기본값: 환경변수)
  --format <format>     # 출력 형식 (table, json, yaml)

예시:
  $0 --action status --cluster-name my-cluster
  $0 --action status --cluster-name my-cluster --format json

확인되는 정보:
  - 클러스터 상태
  - 노드 상태
  - Pod 상태
  - 서비스 상태

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
  - create-cluster: EKS 클러스터 생성
  - deploy-app: 애플리케이션 배포
  - setup-monitoring: 모니터링 설정
  - install-prometheus: Prometheus 설치
  - install-grafana: Grafana 설치
  - setup-alerts: 알림 설정
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
    log_step "AWS EKS 모니터링 환경 검증 중..."
    
    # AWS CLI 설치 확인
    if ! check_command "aws"; then
        log_error "AWS CLI가 설치되지 않았습니다."
        return 1
    fi
    
    # AWS 자격 증명 확인
    if ! aws sts get-caller-identity &> /dev/null; then
        log_error "AWS 자격 증명이 설정되지 않았습니다."
        return 1
    fi
    
    # kubectl 설치 확인
    if ! check_command "kubectl"; then
        log_error "kubectl이 설치되지 않았습니다."
        return 1
    fi
    
    # Helm 설치 확인
    if ! check_command "helm"; then
        log_warning "Helm이 설치되지 않았습니다. 모니터링 설치에 필요할 수 있습니다."
    fi
    
    log_success "AWS EKS 모니터링 환경 검증 완료"
    return 0
}

# =============================================================================
# EKS 클러스터 생성
# =============================================================================
create_cluster() {
    local cluster_name="${1:-eks-monitoring-cluster}"
    local node_type="${2:-t3.medium}"
    local node_count="${3:-2}"
    local region="${4:-$AWS_REGION}"
    
    log_header "EKS 클러스터 생성"
    
    log_info "EKS 클러스터 생성 중... (클러스터: $cluster_name, 노드 타입: $node_type, 노드 수: $node_count)"
    update_progress "create-cluster" "started" "EKS 클러스터 생성 시작"
    
    # EKS 클러스터 생성
    if eksctl create cluster \
        --name "$cluster_name" \
        --region "$region" \
        --nodegroup-name "workers" \
        --node-type "$node_type" \
        --nodes "$node_count" \
        --nodes-min 1 \
        --nodes-max 4 \
        --managed \
        --with-oidc \
        --ssh-access \
        --ssh-public-key "$SSH_KEY_NAME" \
        --full-ecr-access; then
        
        log_success "EKS 클러스터 생성 완료: $cluster_name"
        update_progress "create-cluster" "completed" "EKS 클러스터 생성 완료"
        
        # kubectl 설정
        if aws eks update-kubeconfig --region "$region" --name "$cluster_name"; then
            log_success "kubectl 설정 완료"
        else
            log_warning "kubectl 설정 실패"
        fi
        
        # 클러스터 정보 출력
        log_info "클러스터 정보:"
        log_info "  - 클러스터 이름: $cluster_name"
        log_info "  - 리전: $region"
        log_info "  - 노드 타입: $node_type"
        log_info "  - 노드 수: $node_count"
        
        # 클러스터 ID를 파일에 저장
        echo "$cluster_name" > "$LOGS_DIR/eks-cluster-name.txt"
        
        return 0
    else
        log_error "EKS 클러스터 생성 실패"
        update_progress "create-cluster" "failed" "EKS 클러스터 생성 실패"
        return 1
    fi
}

# =============================================================================
# 애플리케이션 배포
# =============================================================================
deploy_app() {
    local cluster_name="${1:-}"
    local namespace="${2:-default}"
    local region="${3:-$AWS_REGION}"
    
    log_header "애플리케이션 배포"
    
    # 클러스터 이름 확인
    if [ -z "$cluster_name" ]; then
        if [ -f "$LOGS_DIR/eks-cluster-name.txt" ]; then
            cluster_name=$(cat "$LOGS_DIR/eks-cluster-name.txt")
        else
            log_error "클러스터 이름이 지정되지 않았습니다."
            return 1
        fi
    fi
    
    # kubectl 설정
    if ! aws eks update-kubeconfig --region "$region" --name "$cluster_name"; then
        log_error "kubectl 설정 실패"
        return 1
    fi
    
    log_info "애플리케이션 배포 중... (클러스터: $cluster_name, 네임스페이스: $namespace)"
    update_progress "deploy-app" "started" "애플리케이션 배포 시작"
    
    # 네임스페이스 생성
    if [ "$namespace" != "default" ]; then
        if kubectl create namespace "$namespace" 2>/dev/null || kubectl get namespace "$namespace" &> /dev/null; then
            log_success "네임스페이스 생성/확인 완료: $namespace"
        else
            log_error "네임스페이스 생성 실패: $namespace"
            return 1
        fi
    fi
    
    # 샘플 애플리케이션 배포
    cat > /tmp/sample-app.yaml << EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: sample-app
  namespace: $namespace
spec:
  replicas: 2
  selector:
    matchLabels:
      app: sample-app
  template:
    metadata:
      labels:
        app: sample-app
    spec:
      containers:
      - name: sample-app
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
---
apiVersion: v1
kind: Service
metadata:
  name: sample-app-service
  namespace: $namespace
spec:
  selector:
    app: sample-app
  ports:
  - port: 80
    targetPort: 80
  type: LoadBalancer
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: sample-app-ingress
  namespace: $namespace
  annotations:
    kubernetes.io/ingress.class: alb
    alb.ingress.kubernetes.io/scheme: internet-facing
    alb.ingress.kubernetes.io/target-type: ip
spec:
  rules:
  - http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: sample-app-service
            port:
              number: 80
EOF
    
    if kubectl apply -f /tmp/sample-app.yaml; then
        log_success "샘플 애플리케이션 배포 완료"
        
        # 배포 상태 확인
        log_info "배포 상태 확인 중..."
        kubectl rollout status deployment/sample-app -n "$namespace" --timeout=300s
        
        # 서비스 정보 출력
        log_info "서비스 정보:"
        kubectl get services -n "$namespace"
        
        # Ingress 정보 출력
        log_info "Ingress 정보:"
        kubectl get ingress -n "$namespace"
        
        update_progress "deploy-app" "completed" "애플리케이션 배포 완료"
        
        # 정리
        rm -f /tmp/sample-app.yaml
        
        return 0
    else
        log_error "샘플 애플리케이션 배포 실패"
        update_progress "deploy-app" "failed" "애플리케이션 배포 실패"
        return 1
    fi
}

# =============================================================================
# 모니터링 설정
# =============================================================================
setup_monitoring() {
    local cluster_name="${1:-}"
    local namespace="${2:-monitoring}"
    local region="${3:-$AWS_REGION}"
    
    log_header "모니터링 설정"
    
    # 클러스터 이름 확인
    if [ -z "$cluster_name" ]; then
        if [ -f "$LOGS_DIR/eks-cluster-name.txt" ]; then
            cluster_name=$(cat "$LOGS_DIR/eks-cluster-name.txt")
        else
            log_error "클러스터 이름이 지정되지 않았습니다."
            return 1
        fi
    fi
    
    # kubectl 설정
    if ! aws eks update-kubeconfig --region "$region" --name "$cluster_name"; then
        log_error "kubectl 설정 실패"
        return 1
    fi
    
    log_info "모니터링 설정 중... (클러스터: $cluster_name, 네임스페이스: $namespace)"
    update_progress "setup-monitoring" "started" "모니터링 설정 시작"
    
    # 네임스페이스 생성
    if kubectl create namespace "$namespace" 2>/dev/null || kubectl get namespace "$namespace" &> /dev/null; then
        log_success "네임스페이스 생성/확인 완료: $namespace"
    else
        log_error "네임스페이스 생성 실패: $namespace"
        return 1
    fi
    
    # Helm 리포지토리 추가
    if command -v helm &> /dev/null; then
        log_info "Helm 리포지토리 추가 중..."
        helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
        helm repo add grafana https://grafana.github.io/helm-charts
        helm repo update
        
        # Prometheus 설치
        log_info "Prometheus 설치 중..."
        if helm install prometheus prometheus-community/kube-prometheus-stack \
            --namespace "$namespace" \
            --set grafana.adminPassword=admin \
            --set prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues=false \
            --set prometheus.prometheusSpec.podMonitorSelectorNilUsesHelmValues=false \
            --set prometheus.prometheusSpec.ruleSelectorNilUsesHelmValues=false; then
            
            log_success "Prometheus 설치 완료"
        else
            log_error "Prometheus 설치 실패"
            return 1
        fi
        
        # Grafana 접속 정보 출력
        log_info "Grafana 접속 정보:"
        log_info "  - 사용자명: admin"
        log_info "  - 비밀번호: admin"
        log_info "  - 포트 포워딩: kubectl port-forward -n $namespace svc/prometheus-grafana 3000:80"
        
        update_progress "setup-monitoring" "completed" "모니터링 설정 완료"
        return 0
    else
        log_error "Helm이 설치되지 않았습니다. Helm을 설치한 후 다시 시도하세요."
        update_progress "setup-monitoring" "failed" "Helm 설치 필요"
        return 1
    fi
}

# =============================================================================
# Prometheus 설치
# =============================================================================
install_prometheus() {
    local cluster_name="${1:-}"
    local namespace="${2:-monitoring}"
    local region="${3:-$AWS_REGION}"
    
    log_header "Prometheus 설치"
    
    # 클러스터 이름 확인
    if [ -z "$cluster_name" ]; then
        if [ -f "$LOGS_DIR/eks-cluster-name.txt" ]; then
            cluster_name=$(cat "$LOGS_DIR/eks-cluster-name.txt")
        else
            log_error "클러스터 이름이 지정되지 않았습니다."
            return 1
        fi
    fi
    
    # kubectl 설정
    if ! aws eks update-kubeconfig --region "$region" --name "$cluster_name"; then
        log_error "kubectl 설정 실패"
        return 1
    fi
    
    log_info "Prometheus 설치 중... (클러스터: $cluster_name, 네임스페이스: $namespace)"
    update_progress "install-prometheus" "started" "Prometheus 설치 시작"
    
    # Helm 리포지토리 추가
    if command -v helm &> /dev/null; then
        helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
        helm repo update
        
        # Prometheus 설치
        if helm install prometheus prometheus-community/kube-prometheus-stack \
            --namespace "$namespace" \
            --set prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues=false \
            --set prometheus.prometheusSpec.podMonitorSelectorNilUsesHelmValues=false \
            --set prometheus.prometheusSpec.ruleSelectorNilUsesHelmValues=false; then
            
            log_success "Prometheus 설치 완료"
            update_progress "install-prometheus" "completed" "Prometheus 설치 완료"
            
            # Prometheus 접속 정보 출력
            log_info "Prometheus 접속 정보:"
            log_info "  - 포트 포워딩: kubectl port-forward -n $namespace svc/prometheus-kube-prometheus-prometheus 9090:9090"
            
            return 0
        else
            log_error "Prometheus 설치 실패"
            update_progress "install-prometheus" "failed" "Prometheus 설치 실패"
            return 1
        fi
    else
        log_error "Helm이 설치되지 않았습니다. Helm을 설치한 후 다시 시도하세요."
        update_progress "install-prometheus" "failed" "Helm 설치 필요"
        return 1
    fi
}

# =============================================================================
# Grafana 설치
# =============================================================================
install_grafana() {
    local cluster_name="${1:-}"
    local namespace="${2:-monitoring}"
    local region="${3:-$AWS_REGION}"
    
    log_header "Grafana 설치"
    
    # 클러스터 이름 확인
    if [ -z "$cluster_name" ]; then
        if [ -f "$LOGS_DIR/eks-cluster-name.txt" ]; then
            cluster_name=$(cat "$LOGS_DIR/eks-cluster-name.txt")
        else
            log_error "클러스터 이름이 지정되지 않았습니다."
            return 1
        fi
    fi
    
    # kubectl 설정
    if ! aws eks update-kubeconfig --region "$region" --name "$cluster_name"; then
        log_error "kubectl 설정 실패"
        return 1
    fi
    
    log_info "Grafana 설치 중... (클러스터: $cluster_name, 네임스페이스: $namespace)"
    update_progress "install-grafana" "started" "Grafana 설치 시작"
    
    # Helm 리포지토리 추가
    if command -v helm &> /dev/null; then
        helm repo add grafana https://grafana.github.io/helm-charts
        helm repo update
        
        # Grafana 설치
        if helm install grafana grafana/grafana \
            --namespace "$namespace" \
            --set adminPassword=admin \
            --set service.type=LoadBalancer; then
            
            log_success "Grafana 설치 완료"
            update_progress "install-grafana" "completed" "Grafana 설치 완료"
            
            # Grafana 접속 정보 출력
            log_info "Grafana 접속 정보:"
            log_info "  - 사용자명: admin"
            log_info "  - 비밀번호: admin"
            log_info "  - 포트 포워딩: kubectl port-forward -n $namespace svc/grafana 3000:80"
            
            return 0
        else
            log_error "Grafana 설치 실패"
            update_progress "install-grafana" "failed" "Grafana 설치 실패"
            return 1
        fi
    else
        log_error "Helm이 설치되지 않았습니다. Helm을 설치한 후 다시 시도하세요."
        update_progress "install-grafana" "failed" "Helm 설치 필요"
        return 1
    fi
}

# =============================================================================
# 알림 설정
# =============================================================================
setup_alerts() {
    local cluster_name="${1:-}"
    local namespace="${2:-monitoring}"
    local region="${3:-$AWS_REGION}"
    
    log_header "알림 설정"
    
    # 클러스터 이름 확인
    if [ -z "$cluster_name" ]; then
        if [ -f "$LOGS_DIR/eks-cluster-name.txt" ]; then
            cluster_name=$(cat "$LOGS_DIR/eks-cluster-name.txt")
        else
            log_error "클러스터 이름이 지정되지 않았습니다."
            return 1
        fi
    fi
    
    # kubectl 설정
    if ! aws eks update-kubeconfig --region "$region" --name "$cluster_name"; then
        log_error "kubectl 설정 실패"
        return 1
    fi
    
    log_info "알림 설정 중... (클러스터: $cluster_name, 네임스페이스: $namespace)"
    update_progress "setup-alerts" "started" "알림 설정 시작"
    
    # 알림 규칙 생성
    cat > /tmp/alert-rules.yaml << EOF
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: eks-alerts
  namespace: $namespace
spec:
  groups:
  - name: eks.rules
    rules:
    - alert: HighCPUUsage
      expr: 100 - (avg(rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100) > 80
      for: 5m
      labels:
        severity: warning
      annotations:
        summary: "High CPU usage detected"
        description: "CPU usage is above 80% for more than 5 minutes"
    
    - alert: HighMemoryUsage
      expr: (1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100 > 80
      for: 5m
      labels:
        severity: warning
      annotations:
        summary: "High memory usage detected"
        description: "Memory usage is above 80% for more than 5 minutes"
    
    - alert: PodCrashLooping
      expr: rate(kube_pod_container_status_restarts_total[15m]) > 0
      for: 5m
      labels:
        severity: critical
      annotations:
        summary: "Pod is crash looping"
        description: "Pod {{ \$labels.pod }} in namespace {{ \$labels.namespace }} is crash looping"
    
    - alert: PodNotReady
      expr: kube_pod_status_phase{phase!="Running",phase!="Succeeded"} > 0
      for: 5m
      labels:
        severity: warning
      annotations:
        summary: "Pod is not ready"
        description: "Pod {{ \$labels.pod }} in namespace {{ \$labels.namespace }} is not ready"
EOF
    
    if kubectl apply -f /tmp/alert-rules.yaml; then
        log_success "알림 규칙 생성 완료"
        update_progress "setup-alerts" "completed" "알림 설정 완료"
        
        # 정리
        rm -f /tmp/alert-rules.yaml
        
        return 0
    else
        log_error "알림 규칙 생성 실패"
        update_progress "setup-alerts" "failed" "알림 설정 실패"
        return 1
    fi
}

# =============================================================================
# 리소스 정리
# =============================================================================
cleanup_resources() {
    local cluster_name="${1:-}"
    local region="${2:-$AWS_REGION}"
    local force="${3:-false}"
    
    log_header "리소스 정리"
    
    # 클러스터 이름 확인
    if [ -z "$cluster_name" ]; then
        if [ -f "$LOGS_DIR/eks-cluster-name.txt" ]; then
            cluster_name=$(cat "$LOGS_DIR/eks-cluster-name.txt")
        else
            log_error "클러스터 이름이 지정되지 않았습니다."
            return 1
        fi
    fi
    
    if [ "$force" != "true" ]; then
        log_warning "삭제할 클러스터: $cluster_name"
        read -p "정말 삭제하시겠습니까? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_info "삭제가 취소되었습니다."
            return 0
        fi
    fi
    
    log_info "리소스 정리 중... (클러스터: $cluster_name)"
    update_progress "cleanup" "started" "리소스 정리 시작"
    
    # EKS 클러스터 삭제
    if eksctl delete cluster --name "$cluster_name" --region "$region"; then
        log_success "EKS 클러스터 삭제 완료: $cluster_name"
        update_progress "cleanup" "completed" "리소스 정리 완료"
        
        # 클러스터 이름 파일 삭제
        rm -f "$LOGS_DIR/eks-cluster-name.txt"
        
        return 0
    else
        log_error "EKS 클러스터 삭제 실패"
        update_progress "cleanup" "failed" "리소스 정리 실패"
        return 1
    fi
}

# =============================================================================
# 클러스터 상태 확인
# =============================================================================
check_cluster_status() {
    local cluster_name="${1:-}"
    local namespace="${2:-monitoring}"
    local region="${3:-$AWS_REGION}"
    local format="${4:-table}"
    
    log_header "클러스터 상태 확인"
    
    # 클러스터 이름 확인
    if [ -z "$cluster_name" ]; then
        if [ -f "$LOGS_DIR/eks-cluster-name.txt" ]; then
            cluster_name=$(cat "$LOGS_DIR/eks-cluster-name.txt")
        else
            log_error "클러스터 이름이 지정되지 않았습니다."
            return 1
        fi
    fi
    
    # kubectl 설정
    if ! aws eks update-kubeconfig --region "$region" --name "$cluster_name"; then
        log_error "kubectl 설정 실패"
        return 1
    fi
    
    log_info "클러스터 상태 확인 중... (클러스터: $cluster_name)"
    
    # 클러스터 상태 확인
    log_info "클러스터 상태:"
    case "$format" in
        "json")
            kubectl get nodes -o json
            ;;
        "yaml")
            kubectl get nodes -o yaml
            ;;
        *)
            kubectl get nodes
            ;;
    esac
    
    # Pod 상태 확인
    log_info "Pod 상태:"
    kubectl get pods -A
    
    # 서비스 상태 확인
    log_info "서비스 상태:"
    kubectl get services -A
    
    # 모니터링 구성요소 상태 확인
    if kubectl get namespace "$namespace" &> /dev/null; then
        log_info "모니터링 구성요소 상태:"
        kubectl get pods -n "$namespace"
    fi
    
    update_progress "status" "completed" "클러스터 상태 확인 완료"
    return 0
}

# =============================================================================
# 메인 실행 로직
# =============================================================================
main() {
    local action=""
    local cluster_name="eks-monitoring-cluster"
    local node_type="t3.medium"
    local node_count="2"
    local region="$AWS_REGION"
    local namespace="monitoring"
    local force="false"
    local format="table"
    
    # 인수 파싱
    while [[ $# -gt 0 ]]; do
        case $1 in
            --action)
                action="$2"
                shift 2
                ;;
            --cluster-name)
                cluster_name="$2"
                shift 2
                ;;
            --node-type)
                node_type="$2"
                shift 2
                ;;
            --node-count)
                node_count="$2"
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
            --force)
                force="true"
                shift
                ;;
            --format)
                format="$2"
                shift 2
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
        "create-cluster")
            create_cluster "$cluster_name" "$node_type" "$node_count" "$region"
            ;;
        "deploy-app")
            deploy_app "$cluster_name" "$namespace" "$region"
            ;;
        "setup-monitoring")
            setup_monitoring "$cluster_name" "$namespace" "$region"
            ;;
        "install-prometheus")
            install_prometheus "$cluster_name" "$namespace" "$region"
            ;;
        "install-grafana")
            install_grafana "$cluster_name" "$namespace" "$region"
            ;;
        "setup-alerts")
            setup_alerts "$cluster_name" "$namespace" "$region"
            ;;
        "cleanup")
            cleanup_resources "$cluster_name" "$region" "$force"
            ;;
        "status")
            check_cluster_status "$cluster_name" "$namespace" "$region" "$format"
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
