#!/bin/bash

# GCP Cluster Integration Helper 모듈
# 역할: GCP GKE 클러스터 구축 및 멀티 클라우드 모니터링 통합
# 
# 사용법:
#   ./gcp-cluster-integration-helper.sh --action <액션> --provider gcp

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

# GCP 환경 설정 로드
if [ -f "$SCRIPT_DIR/gcp-environment.env" ]; then
    source "$SCRIPT_DIR/gcp-environment.env"
    log_info "GCP 환경 설정 로드 완료"
else
    log_error "GCP 환경 설정 파일을 찾을 수 없습니다"
    exit 1
fi

# =============================================================================
# 사용법 출력
# =============================================================================
usage() {
    cat << EOF
GCP Cluster Integration Helper 모듈

사용법:
  $0 --action <액션> [옵션]

액션:
  cluster-create           # GKE 클러스터 생성
  cluster-delete           # GKE 클러스터 삭제
  cluster-status           # GKE 클러스터 상태 확인
  app-deploy               # 애플리케이션 배포
  monitoring-setup         # 모니터링 설정
  cross-cluster-setup      # 크로스 클러스터 통합
  cleanup                  # 전체 정리

옵션:
  --cluster-name <name>    # GKE 클러스터 이름 (기본값: 환경변수)
  --zone <zone>            # GCP 존 (기본값: 환경변수)
  --project-id <id>        # GCP 프로젝트 ID (기본값: 환경변수)
  --help, -h              # 도움말 표시

예시:
  $0 --action cluster-create
  $0 --action app-deploy --cluster-name my-cluster
  $0 --action cross-cluster-setup
EOF
}

# =============================================================================
# 환경 검증
# =============================================================================
validate_environment() {
    log_step "GCP 클러스터 통합 환경 검증 중..."
    
    # gcloud CLI 확인
    if ! check_command "gcloud"; then
        log_error "gcloud CLI가 설치되지 않았습니다."
        return 1
    fi
    
    # kubectl 확인
    if ! check_command "kubectl"; then
        log_error "kubectl이 설치되지 않았습니다."
        return 1
    fi
    
    # GCP 자격 증명 확인
    if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" | head -n1 &> /dev/null; then
        log_error "GCP 자격 증명이 설정되지 않았습니다."
        return 1
    fi
    
    # GCP 프로젝트 설정 확인
    if ! gcloud config get-value project &> /dev/null; then
        log_error "GCP 프로젝트가 설정되지 않았습니다."
        return 1
    fi
    
    log_success "GCP 클러스터 통합 환경 검증 완료"
    return 0
}

# =============================================================================
# GKE 클러스터 생성
# =============================================================================
create_gke_cluster() {
    local cluster_name="${1:-$GKE_CLUSTER_NAME}"
    local zone="${2:-$GCP_ZONE}"
    local project_id="${3:-$GCP_PROJECT_ID}"
    
    log_header "GKE 클러스터 생성: $cluster_name"
    
    # 클러스터 존재 확인
    if gcloud container clusters describe "$cluster_name" --zone="$zone" --project="$project_id" &> /dev/null; then
        log_warning "GKE 클러스터가 이미 존재합니다: $cluster_name"
        log_info "기존 클러스터를 사용하여 다음 단계를 진행합니다."
        update_progress "cluster-check" "existing" "기존 GKE 클러스터 사용: $cluster_name"
        
        # 클러스터 연결
        gcloud container clusters get-credentials "$cluster_name" --zone="$zone" --project="$project_id"
        return 0
    fi
    
    log_info "GKE 클러스터 생성 시작: $cluster_name"
    update_progress "cluster-create" "started" "GKE 클러스터 생성 시작"
    
    # GKE 클러스터 생성
    gcloud container clusters create "$cluster_name" \
        --zone="$zone" \
        --project="$project_id" \
        --machine-type="$GKE_NODE_TYPE" \
        --num-nodes="$GKE_NODE_COUNT" \
        --min-nodes="$GKE_MIN_NODES" \
        --max-nodes="$GKE_MAX_NODES" \
        --cluster-version="$GKE_VERSION" \
        --enable-autoscaling \
        --enable-autorepair \
        --enable-autoupgrade \
        --enable-ip-alias \
        --enable-network-policy \
        --enable-stackdriver-kubernetes \
        --addons=HttpLoadBalancing,HorizontalPodAutoscaling,NetworkPolicy \
        --tags="$ENVIRONMENT_TAG,$PROJECT_TAG,$OWNER_TAG" \
        --labels="environment=$ENVIRONMENT_TAG,project=$PROJECT_TAG,owner=$OWNER_TAG"
    
    local exit_code=$?
    
    if [ $exit_code -eq 0 ]; then
        log_success "GKE 클러스터 생성 완료: $cluster_name"
        update_progress "cluster-create" "completed" "GKE 클러스터 생성 완료"
        
        # 클러스터 연결
        gcloud container clusters get-credentials "$cluster_name" --zone="$zone" --project="$project_id"
        
        # 클러스터 상태 확인
        check_cluster_status "$cluster_name" "$zone" "$project_id"
    else
        log_error "GKE 클러스터 생성 실패: $cluster_name"
        update_progress "cluster-create" "failed" "GKE 클러스터 생성 실패"
        return 1
    fi
}

# =============================================================================
# GKE 클러스터 삭제
# =============================================================================
delete_gke_cluster() {
    local cluster_name="${1:-$GKE_CLUSTER_NAME}"
    local zone="${2:-$GCP_ZONE}"
    local project_id="${3:-$GCP_PROJECT_ID}"
    
    log_header "GKE 클러스터 삭제: $cluster_name"
    
    # 클러스터 존재 확인
    if ! gcloud container clusters describe "$cluster_name" --zone="$zone" --project="$project_id" &> /dev/null; then
        log_warning "삭제할 GKE 클러스터가 존재하지 않습니다: $cluster_name"
        update_progress "cluster-delete" "skipped" "GKE 클러스터가 존재하지 않음"
        return 0
    fi
    
    log_info "GKE 클러스터 삭제 시작: $cluster_name"
    update_progress "cluster-delete" "started" "GKE 클러스터 삭제 시작"
    
    # GKE 클러스터 삭제
    gcloud container clusters delete "$cluster_name" \
        --zone="$zone" \
        --project="$project_id" \
        --quiet
    
    local exit_code=$?
    
    if [ $exit_code -eq 0 ]; then
        log_success "GKE 클러스터 삭제 완료: $cluster_name"
        update_progress "cluster-delete" "completed" "GKE 클러스터 삭제 완료"
        return 0
    else
        log_error "GKE 클러스터 삭제 실패: $cluster_name"
        update_progress "cluster-delete" "failed" "GKE 클러스터 삭제 실패"
        return 1
    fi
}

# =============================================================================
# GKE 클러스터 상태 확인
# =============================================================================
check_cluster_status() {
    local cluster_name="${1:-$GKE_CLUSTER_NAME}"
    local zone="${2:-$GCP_ZONE}"
    local project_id="${3:-$GCP_PROJECT_ID}"
    
    log_header "GKE 클러스터 상태 확인: $cluster_name"
    
    # 클러스터 정보 조회
    log_info "클러스터 기본 정보:"
    gcloud container clusters describe "$cluster_name" --zone="$zone" --project="$project_id" \
        --format="table(name,status,currentMasterVersion,currentNodeVersion,nodeCount,location)"
    
    # 노드 상태 확인
    log_step "노드 상태 확인"
    kubectl get nodes -o wide
    
    # 시스템 파드 상태 확인
    log_step "시스템 파드 상태 확인"
    kubectl get pods -n kube-system -o wide
    
    # 클러스터 리소스 사용량 확인
    log_step "클러스터 리소스 사용량"
    kubectl top nodes
    
    update_progress "cluster-status" "completed" "GKE 클러스터 상태 확인 완료"
}

# =============================================================================
# 애플리케이션 배포
# =============================================================================
deploy_application() {
    local cluster_name="${1:-$GKE_CLUSTER_NAME}"
    local zone="${2:-$GCP_ZONE}"
    local project_id="${3:-$GCP_PROJECT_ID}"
    local app_name="gcp-intermediate-app"
    local namespace="default"
    
    log_header "GCP 애플리케이션 배포: $app_name"
    
    # 클러스터 연결 확인
    if ! kubectl get nodes &> /dev/null; then
        log_info "GKE 클러스터 연결 중..."
        gcloud container clusters get-credentials "$cluster_name" --zone="$zone" --project="$project_id"
    fi
    
    # 네임스페이스 생성
    kubectl create namespace "$namespace" --dry-run=client -o yaml | kubectl apply -f -
    
    # 애플리케이션 매니페스트 생성
    cat > gcp-app-deployment.yaml << EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: $app_name
  namespace: $namespace
  labels:
    app: $app_name
spec:
  replicas: 2
  selector:
    matchLabels:
      app: $app_name
  template:
    metadata:
      labels:
        app: $app_name
    spec:
      containers:
      - name: $app_name
        image: nginx:1.21
        ports:
        - containerPort: 80
        env:
        - name: ENVIRONMENT
          value: "production"
        - name: APP_NAME
          value: "$app_name"
        - name: CLOUD_PROVIDER
          value: "GCP"
        resources:
          requests:
            memory: "128Mi"
            cpu: "100m"
          limits:
            memory: "256Mi"
            cpu: "200m"
        livenessProbe:
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 5
          periodSeconds: 5
---
apiVersion: v1
kind: Service
metadata:
  name: $app_name-service
  namespace: $namespace
  labels:
    app: $app_name
spec:
  selector:
    app: $app_name
  ports:
  - port: 80
    targetPort: 80
    protocol: TCP
  type: LoadBalancer
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: $app_name-ingress
  namespace: $namespace
  annotations:
    kubernetes.io/ingress.class: "gce"
    kubernetes.io/ingress.global-static-ip-name: "$app_name-ip"
spec:
  rules:
  - host: $app_name.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: $app_name-service
            port:
              number: 80
EOF

    # 애플리케이션 배포
    kubectl apply -f gcp-app-deployment.yaml
    
    if [ $? -eq 0 ]; then
        log_success "GCP 애플리케이션 배포 완료: $app_name"
        update_progress "app-deploy" "completed" "GCP 애플리케이션 배포 완료"
        
        # 배포 상태 확인
        check_deployment_status "$app_name" "$namespace"
    else
        log_error "GCP 애플리케이션 배포 실패: $app_name"
        update_progress "app-deploy" "failed" "GCP 애플리케이션 배포 실패"
        return 1
    fi
}

# =============================================================================
# 모니터링 설정
# =============================================================================
setup_monitoring() {
    local cluster_name="${1:-$GKE_CLUSTER_NAME}"
    local zone="${2:-$GCP_ZONE}"
    local project_id="${3:-$GCP_PROJECT_ID}"
    local namespace="monitoring"
    
    log_header "GCP 모니터링 설정"
    
    # 클러스터 연결 확인
    if ! kubectl get nodes &> /dev/null; then
        log_info "GKE 클러스터 연결 중..."
        gcloud container clusters get-credentials "$cluster_name" --zone="$zone" --project="$project_id"
    fi
    
    # 모니터링 네임스페이스 생성
    kubectl create namespace "$namespace" --dry-run=client -o yaml | kubectl apply -f -
    
    # GCP Cloud Monitoring 통합
    setup_gcp_cloud_monitoring "$namespace"
    
    # Prometheus 배포
    deploy_prometheus_gcp "$namespace"
    
    # Grafana 배포
    deploy_grafana_gcp "$namespace"
    
    log_success "GCP 모니터링 설정 완료"
    update_progress "monitoring-setup" "completed" "GCP 모니터링 설정 완료"
}

# =============================================================================
# GCP Cloud Monitoring 통합
# =============================================================================
setup_gcp_cloud_monitoring() {
    local namespace="$1"
    
    log_step "GCP Cloud Monitoring 통합 설정"
    
    # GCP Monitoring Agent 배포
    cat > gcp-monitoring-agent.yaml << EOF
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: gcp-monitoring-agent
  namespace: $namespace
spec:
  selector:
    matchLabels:
      name: gcp-monitoring-agent
  template:
    metadata:
      labels:
        name: gcp-monitoring-agent
    spec:
      containers:
      - name: gcp-monitoring-agent
        image: gcr.io/google-containers/monitoring:0.1.0
        env:
        - name: GCP_PROJECT_ID
          value: "$GCP_PROJECT_ID"
        - name: GCP_ZONE
          value: "$GCP_ZONE"
        - name: GCP_CLUSTER_NAME
          value: "$GKE_CLUSTER_NAME"
        resources:
          requests:
            memory: "128Mi"
            cpu: "100m"
          limits:
            memory: "256Mi"
            cpu: "200m"
        volumeMounts:
        - name: gcp-credentials
          mountPath: /var/secrets/google
          readOnly: true
      volumes:
      - name: gcp-credentials
        secret:
          secretName: gcp-monitoring-credentials
EOF

    # GCP 서비스 계정 키 시크릿 생성
    kubectl create secret generic gcp-monitoring-credentials \
        --from-file=key.json="$GCP_SERVICE_ACCOUNT_KEY_PATH" \
        -n "$namespace" --dry-run=client -o yaml | kubectl apply -f -
    
    kubectl apply -f gcp-monitoring-agent.yaml
    
    log_success "GCP Cloud Monitoring 통합 설정 완료"
    update_progress "gcp-monitoring" "completed" "GCP Cloud Monitoring 통합 설정 완료"
}

# =============================================================================
# Prometheus 배포 (GCP)
# =============================================================================
deploy_prometheus_gcp() {
    local namespace="$1"
    
    log_step "Prometheus 배포 (GCP)"
    
    # Prometheus Helm 차트 추가
    helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
    helm repo update
    
    # Prometheus 설정값 생성
    cat > prometheus-gcp-values.yaml << EOF
server:
  persistentVolume:
    enabled: true
    size: 20Gi
  service:
    type: LoadBalancer

alertmanager:
  enabled: true
  persistentVolume:
    enabled: true
    size: 2Gi

kubeStateMetrics:
  enabled: true

nodeExporter:
  enabled: true

pushgateway:
  enabled: true

grafana:
  enabled: false  # 별도로 Grafana 배포
EOF

    # Prometheus 설치
    helm upgrade --install prometheus prometheus-community/kube-prometheus-stack \
        --namespace "$namespace" \
        --values prometheus-gcp-values.yaml \
        --wait
    
    if [ $? -eq 0 ]; then
        log_success "Prometheus 배포 완료 (GCP)"
        update_progress "prometheus-deploy" "completed" "Prometheus 배포 완료 (GCP)"
    else
        log_error "Prometheus 배포 실패 (GCP)"
        update_progress "prometheus-deploy" "failed" "Prometheus 배포 실패 (GCP)"
        return 1
    fi
}

# =============================================================================
# Grafana 배포 (GCP)
# =============================================================================
deploy_grafana_gcp() {
    local namespace="$1"
    
    log_step "Grafana 배포 (GCP)"
    
    # Grafana Helm 차트 추가
    helm repo add grafana https://grafana.github.io/helm-charts
    helm repo update
    
    # Grafana 설정값 생성
    cat > grafana-gcp-values.yaml << EOF
service:
  type: LoadBalancer

persistence:
  enabled: true
  size: 10Gi

adminPassword: admin123

datasources:
  datasources.yaml:
    apiVersion: 1
    datasources:
    - name: Prometheus
      type: prometheus
      url: http://prometheus-server:80
      access: proxy
      isDefault: true
    - name: GCP Cloud Monitoring
      type: cloudwatch
      jsonData:
        defaultRegion: $GCP_REGION
        authType: keys
        accessKey: $GCP_ACCESS_KEY
        secretKey: $GCP_SECRET_KEY
EOF

    # Grafana 설치
    helm upgrade --install grafana grafana/grafana \
        --namespace "$namespace" \
        --values grafana-gcp-values.yaml \
        --wait
    
    if [ $? -eq 0 ]; then
        log_success "Grafana 배포 완료 (GCP)"
        update_progress "grafana-deploy" "completed" "Grafana 배포 완료 (GCP)"
    else
        log_error "Grafana 배포 실패 (GCP)"
        update_progress "grafana-deploy" "failed" "Grafana 배포 실패 (GCP)"
        return 1
    fi
}

# =============================================================================
# 크로스 클러스터 통합 설정
# =============================================================================
setup_cross_cluster_integration() {
    log_header "크로스 클러스터 통합 설정"
    
    # AWS EKS와 GCP GKE 간 통합 모니터링 설정
    setup_aws_gcp_integration
    
    # 통합 대시보드 설정
    setup_unified_dashboard_gcp
    
    log_success "크로스 클러스터 통합 설정 완료"
    update_progress "cross-cluster-setup" "completed" "크로스 클러스터 통합 설정 완료"
}

# =============================================================================
# AWS-GCP 통합 설정
# =============================================================================
setup_aws_gcp_integration() {
    log_step "AWS-GCP 통합 모니터링 설정"
    
    # GCP에서 AWS 클러스터 정보 접근 설정
    cat > aws-gcp-integration.yaml << EOF
apiVersion: v1
kind: Secret
metadata:
  name: aws-cluster-credentials
  namespace: monitoring
type: Opaque
data:
  aws-access-key-id: $(echo -n "$AWS_ACCESS_KEY_ID" | base64)
  aws-secret-access-key: $(echo -n "$AWS_SECRET_ACCESS_KEY" | base64)
  aws-region: $(echo -n "$AWS_REGION" | base64)
  eks-cluster-name: $(echo -n "$EKS_CLUSTER_NAME" | base64)
EOF

    kubectl apply -f aws-gcp-integration.yaml
    
    log_success "AWS-GCP 통합 설정 완료"
}

# =============================================================================
# 통합 대시보드 설정 (GCP)
# =============================================================================
setup_unified_dashboard_gcp() {
    log_step "통합 대시보드 설정 (GCP)"
    
    # Grafana 통합 대시보드 설정
    cat > unified-dashboard-gcp.json << EOF
{
  "dashboard": {
    "title": "Multi-Cloud Monitoring Dashboard (GCP)",
    "panels": [
      {
        "title": "GCP GKE Cluster Metrics",
        "type": "graph",
        "targets": [
          {
            "expr": "up{job=\"prometheus\"}",
            "legendFormat": "GCP GKE"
          }
        ]
      },
      {
        "title": "AWS EKS Cluster Metrics (from GCP)",
        "type": "graph", 
        "targets": [
          {
            "expr": "up{job=\"prometheus\"}",
            "legendFormat": "AWS EKS (via GCP)"
          }
        ]
      }
    ]
  }
}
EOF

    log_success "통합 대시보드 설정 완료 (GCP)"
}

# =============================================================================
# 배포 상태 확인
# =============================================================================
check_deployment_status() {
    local app_name="$1"
    local namespace="$2"
    
    log_info "배포 상태 확인 중..."
    
    # 배포 완료 대기
    kubectl rollout status deployment/"$app_name" -n "$namespace" --timeout=300s
    
    if [ $? -eq 0 ]; then
        log_success "배포가 성공적으로 완료되었습니다"
        
        # 서비스 엔드포인트 확인
        local service_name="${app_name}-service"
        local external_ip=$(kubectl get svc "$service_name" -n "$namespace" -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
        
        if [ -n "$external_ip" ]; then
            log_info "애플리케이션 URL: http://$external_ip"
        fi
    else
        log_error "배포가 실패했습니다"
        return 1
    fi
}

# =============================================================================
# 전체 정리
# =============================================================================
cleanup_all() {
    local cluster_name="${1:-$GKE_CLUSTER_NAME}"
    local zone="${2:-$GCP_ZONE}"
    local project_id="${3:-$GCP_PROJECT_ID}"
    
    log_header "GCP 클러스터 통합 환경 전체 정리"
    
    # 애플리케이션 리소스 삭제
    kubectl delete deployment gcp-intermediate-app --ignore-not-found=true
    kubectl delete service gcp-intermediate-app-service --ignore-not-found=true
    kubectl delete ingress gcp-intermediate-app-ingress --ignore-not-found=true
    
    # 모니터링 리소스 삭제
    helm uninstall prometheus -n monitoring 2>/dev/null || true
    helm uninstall grafana -n monitoring 2>/dev/null || true
    kubectl delete namespace monitoring --ignore-not-found=true
    
    # GKE 클러스터 삭제
    delete_gke_cluster "$cluster_name" "$zone" "$project_id"
    
    # 설정 파일 정리
    rm -f gcp-app-deployment.yaml gcp-monitoring-agent.yaml
    rm -f prometheus-gcp-values.yaml grafana-gcp-values.yaml
    rm -f aws-gcp-integration.yaml unified-dashboard-gcp.json
    
    log_success "GCP 클러스터 통합 환경 정리 완료"
    update_progress "cleanup" "completed" "GCP 클러스터 통합 환경 정리 완료"
}

# =============================================================================
# 메인 실행 로직
# =============================================================================
main() {
    local action=""
    local cluster_name="$GKE_CLUSTER_NAME"
    local zone="$GCP_ZONE"
    local project_id="$GCP_PROJECT_ID"
    
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
            --zone)
                zone="$2"
                shift 2
                ;;
            --project-id)
                project_id="$2"
                shift 2
                ;;
            --help|-h)
                usage
                exit 0
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
        "cluster-create")
            create_gke_cluster "$cluster_name" "$zone" "$project_id"
            ;;
        "cluster-delete")
            delete_gke_cluster "$cluster_name" "$zone" "$project_id"
            ;;
        "cluster-status")
            check_cluster_status "$cluster_name" "$zone" "$project_id"
            ;;
        "app-deploy")
            deploy_application "$cluster_name" "$zone" "$project_id"
            ;;
        "monitoring-setup")
            setup_monitoring "$cluster_name" "$zone" "$project_id"
            ;;
        "cross-cluster-setup")
            setup_cross_cluster_integration
            ;;
        "cleanup")
            cleanup_all "$cluster_name" "$zone" "$project_id"
            ;;
        "gcp-cluster-integration")
            # 메뉴에서 호출되는 통합 액션
            create_gke_cluster "$cluster_name" "$zone" "$project_id"
            deploy_application "$cluster_name" "$zone" "$project_id"
            setup_monitoring "$cluster_name" "$zone" "$project_id"
            setup_cross_cluster_integration
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
