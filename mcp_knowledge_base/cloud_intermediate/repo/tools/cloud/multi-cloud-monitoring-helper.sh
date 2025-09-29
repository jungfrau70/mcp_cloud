#!/bin/bash

# Multi-Cloud Monitoring Helper 모듈
# 역할: AWS EKS, GCP GKE 통합 모니터링 시스템 구축
# 
# 사용법:
#   ./multi-cloud-monitoring-helper.sh --action <액션> --provider <프로바이더>

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
Multi-Cloud Monitoring Helper 모듈

사용법:
  $0 --action <액션> [옵션]

액션:
  monitoring-setup         # 통합 모니터링 시스템 구축
  prometheus-deploy        # Prometheus 배포
  grafana-deploy           # Grafana 배포
  cross-cluster-setup      # 크로스 클러스터 모니터링 설정
  monitoring-status        # 모니터링 상태 확인
  cleanup                  # 전체 정리

옵션:
  --provider <provider>    # 클라우드 프로바이더 (aws/gcp/all)
  --cluster-name <name>    # 클러스터 이름 (기본값: 환경변수)
  --namespace <namespace>  # 네임스페이스 (기본값: monitoring)
  --help, -h              # 도움말 표시

예시:
  $0 --action monitoring-setup --provider aws
  $0 --action prometheus-deploy --provider gcp
  $0 --action cross-cluster-setup --provider all

상세 사용법:
  $0 --help --action monitoring-setup     # monitoring-setup 액션 상세 사용법
  $0 --help --action prometheus-deploy    # prometheus-deploy 액션 상세 사용법
  $0 --help --action cleanup              # cleanup 액션 상세 사용법
EOF
}

# =============================================================================
# 액션별 상세 사용법 함수
# =============================================================================
show_action_help() {
    local action="$1"
    
    case "$action" in
        "monitoring-setup")
            cat << EOF
MONITORING-SETUP 액션 상세 사용법:

기능:
  - 멀티 클라우드 통합 모니터링 시스템을 구축합니다
  - AWS EKS와 GCP GKE를 연동하여 통합 모니터링을 제공합니다
  - Prometheus와 Grafana를 기반으로 한 모니터링 스택을 배포합니다

사용법:
  $0 --action monitoring-setup [옵션]

옵션:
  --provider <provider>   # 클라우드 프로바이더 (aws, gcp, all)
  --cluster-name <name>   # 클러스터 이름 (기본값: 환경변수)
  --namespace <namespace> # 네임스페이스 (기본값: monitoring)
  --region <region>       # 리전 (기본값: 환경변수)

예시:
  $0 --action monitoring-setup --provider aws
  $0 --action monitoring-setup --provider all --namespace custom-monitoring
  $0 --action monitoring-setup --cluster-name my-cluster --region us-west-2

구축되는 리소스:
  - Prometheus 서버
  - Grafana 대시보드
  - Node Exporter
  - AlertManager
  - 통합 모니터링 대시보드

진행 상황:
  - 환경 검증
  - 클러스터 확인
  - 모니터링 스택 배포
  - 크로스 클러스터 설정
  - 완료 보고
EOF
            ;;
        "prometheus-deploy")
            cat << EOF
PROMETHEUS-DEPLOY 액션 상세 사용법:

기능:
  - Prometheus 서버를 클러스터에 배포합니다
  - 메트릭 수집 및 저장 기능을 제공합니다
  - 서비스 디스커버리를 통한 자동 타겟 관리

사용법:
  $0 --action prometheus-deploy [옵션]

옵션:
  --provider <provider>   # 클라우드 프로바이더 (aws, gcp)
  --cluster-name <name>   # 클러스터 이름 (기본값: 환경변수)
  --namespace <namespace> # 네임스페이스 (기본값: monitoring)
  --storage-size <size>   # 스토리지 크기 (기본값: 10Gi)

예시:
  $0 --action prometheus-deploy --provider aws
  $0 --action prometheus-deploy --provider gcp --namespace custom-monitoring
  $0 --action prometheus-deploy --storage-size 20Gi

배포되는 리소스:
  - Prometheus Deployment
  - Prometheus Service
  - Prometheus ConfigMap
  - PersistentVolumeClaim
  - ServiceMonitor

진행 상황:
  - 네임스페이스 생성
  - ConfigMap 생성
  - Deployment 배포
  - Service 생성
  - 상태 확인
EOF
            ;;
        "cleanup")
            cat << EOF
CLEANUP 액션 상세 사용법:

기능:
  - 멀티 클라우드 모니터링 관련 모든 리소스를 정리합니다
  - Prometheus, Grafana, AlertManager를 순서대로 삭제합니다
  - 네임스페이스와 관련 리소스를 정리합니다

사용법:
  $0 --action cleanup [옵션]

옵션:
  --provider <provider>   # 클라우드 프로바이더 (aws, gcp, all)
  --cluster-name <name>   # 클러스터 이름 (기본값: 환경변수)
  --namespace <namespace> # 네임스페이스 (기본값: monitoring)
  --force                 # 확인 없이 강제 삭제
  --keep-data             # 데이터 유지

예시:
  $0 --action cleanup --provider aws
  $0 --action cleanup --provider all --force
  $0 --action cleanup --namespace custom-monitoring

삭제되는 리소스:
  - Grafana Deployment
  - Prometheus Deployment
  - AlertManager Deployment
  - 관련 Services
  - ConfigMaps
  - PersistentVolumeClaims (--keep-data 옵션 없을 경우)
  - 네임스페이스 (--keep-data 옵션 없을 경우)

주의사항:
  - 삭제된 모니터링 데이터는 복구할 수 없습니다
  - --force 옵션 사용 시 확인 없이 삭제됩니다
  - 데이터를 보존하려면 --keep-data 옵션을 사용하세요
EOF
            ;;
        *)
            cat << EOF
알 수 없는 액션: $action

사용 가능한 액션:
  - monitoring-setup: 통합 모니터링 시스템 구축
  - prometheus-deploy: Prometheus 배포
  - grafana-deploy: Grafana 배포
  - cross-cluster-setup: 크로스 클러스터 모니터링 설정
  - monitoring-status: 모니터링 상태 확인
  - cleanup: 전체 정리

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
    log_step "멀티 클라우드 모니터링 환경 검증 중..."
    
    # kubectl 확인
    if ! check_command "kubectl"; then
        log_error "kubectl이 설치되지 않았습니다."
        return 1
    fi
    
    # Helm 확인
    if ! check_command "helm"; then
        log_error "Helm이 설치되지 않았습니다."
        return 1
    fi
    
    # 프로바이더별 도구 확인
    case "$provider" in
        "aws"|"all")
            if ! check_command "aws"; then
                log_error "AWS CLI가 설치되지 않았습니다."
                return 1
            fi
            if ! aws sts get-caller-identity &> /dev/null; then
                log_error "AWS 자격 증명이 설정되지 않았습니다."
                return 1
            fi
            ;;
    esac
    
    case "$provider" in
        "gcp"|"all")
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
    
    log_success "멀티 클라우드 모니터링 환경 검증 완료"
    return 0
}

# =============================================================================
# 통합 모니터링 시스템 구축
# =============================================================================
setup_monitoring() {
    local provider="$1"
    local namespace="${2:-monitoring}"
    
    log_header "통합 모니터링 시스템 구축: $provider"
    
    case "$provider" in
        "aws")
            setup_aws_monitoring "$namespace"
            ;;
        "gcp")
            setup_gcp_monitoring "$namespace"
            ;;
        "all")
            setup_aws_monitoring "$namespace"
            setup_gcp_monitoring "$namespace"
            setup_cross_cluster_monitoring
            ;;
        *)
            log_error "지원하지 않는 프로바이더: $provider"
            return 1
            ;;
    esac
    
    update_progress "monitoring-setup" "completed" "통합 모니터링 시스템 구축 완료"
}

# =============================================================================
# AWS 모니터링 설정
# =============================================================================
setup_aws_monitoring() {
    local namespace="$1"
    
    log_step "AWS EKS 모니터링 설정"
    
    # AWS 환경 설정 로드
    if [ -f "$SCRIPT_DIR/aws-environment.env" ]; then
        source "$SCRIPT_DIR/aws-environment.env"
    fi
    
    # EKS 클러스터 연결
    log_info "EKS 클러스터 연결 중: $EKS_CLUSTER_NAME"
    aws eks update-kubeconfig --name "$EKS_CLUSTER_NAME" --region "$AWS_REGION"
    
    # 모니터링 네임스페이스 생성
    kubectl create namespace "$namespace" --dry-run=client -o yaml | kubectl apply -f -
    
    # Prometheus 배포
    deploy_prometheus "$namespace" "aws"
    
    # Grafana 배포
    deploy_grafana "$namespace" "aws"
    
    # AWS CloudWatch 통합
    setup_cloudwatch_integration "$namespace"
    
    log_success "AWS 모니터링 설정 완료"
    update_progress "aws-monitoring" "completed" "AWS 모니터링 설정 완료"
}

# =============================================================================
# GCP 모니터링 설정
# =============================================================================
setup_gcp_monitoring() {
    local namespace="$1"
    
    log_step "GCP GKE 모니터링 설정"
    
    # GCP 환경 설정 로드
    if [ -f "$SCRIPT_DIR/gcp-environment.env" ]; then
        source "$SCRIPT_DIR/gcp-environment.env"
    fi
    
    # GKE 클러스터 연결
    log_info "GKE 클러스터 연결 중: $GKE_CLUSTER_NAME"
    gcloud container clusters get-credentials "$GKE_CLUSTER_NAME" --zone "$GCP_ZONE"
    
    # 모니터링 네임스페이스 생성
    kubectl create namespace "$namespace" --dry-run=client -o yaml | kubectl apply -f -
    
    # Prometheus 배포
    deploy_prometheus "$namespace" "gcp"
    
    # Grafana 배포
    deploy_grafana "$namespace" "gcp"
    
    # GCP Cloud Monitoring 통합
    setup_gcp_monitoring_integration "$namespace"
    
    log_success "GCP 모니터링 설정 완료"
    update_progress "gcp-monitoring" "completed" "GCP 모니터링 설정 완료"
}

# =============================================================================
# Prometheus 배포
# =============================================================================
deploy_prometheus() {
    local namespace="$1"
    local provider="$2"
    
    log_step "Prometheus 배포: $provider"
    
    # Prometheus Helm 차트 추가
    helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
    helm repo update
    
    # Prometheus 설정값 생성
    cat > prometheus-values.yaml << EOF
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
        --values prometheus-values.yaml \
        --wait
    
    if [ $? -eq 0 ]; then
        log_success "Prometheus 배포 완료: $provider"
        update_progress "prometheus-deploy" "completed" "Prometheus 배포 완료: $provider"
    else
        log_error "Prometheus 배포 실패: $provider"
        update_progress "prometheus-deploy" "failed" "Prometheus 배포 실패: $provider"
        return 1
    fi
}

# =============================================================================
# Grafana 배포
# =============================================================================
deploy_grafana() {
    local namespace="$1"
    local provider="$2"
    
    log_step "Grafana 배포: $provider"
    
    # Grafana Helm 차트 추가
    helm repo add grafana https://grafana.github.io/helm-charts
    helm repo update
    
    # Grafana 설정값 생성
    cat > grafana-values.yaml << EOF
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
    - name: AWS CloudWatch
      type: cloudwatch
      jsonData:
        defaultRegion: $AWS_REGION
        authType: keys
        accessKey: $AWS_ACCESS_KEY_ID
        secretKey: $AWS_SECRET_ACCESS_KEY
EOF

    # Grafana 설치
    helm upgrade --install grafana grafana/grafana \
        --namespace "$namespace" \
        --values grafana-values.yaml \
        --wait
    
    if [ $? -eq 0 ]; then
        log_success "Grafana 배포 완료: $provider"
        update_progress "grafana-deploy" "completed" "Grafana 배포 완료: $provider"
    else
        log_error "Grafana 배포 실패: $provider"
        update_progress "grafana-deploy" "failed" "Grafana 배포 실패: $provider"
        return 1
    fi
}

# =============================================================================
# AWS CloudWatch 통합
# =============================================================================
setup_cloudwatch_integration() {
    local namespace="$1"
    
    log_step "AWS CloudWatch 통합 설정"
    
    # CloudWatch Agent ConfigMap 생성
    cat > cloudwatch-config.yaml << EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: cloudwatch-config
  namespace: $namespace
data:
  cwagentconfig.json: |
    {
      "agent": {
        "metrics_collection_interval": 60,
        "run_as_user": "root"
      },
      "metrics": {
        "namespace": "CloudWatch-EKS",
        "metrics_collected": {
          "cpu": {
            "measurement": ["cpu_usage_idle", "cpu_usage_iowait", "cpu_usage_user", "cpu_usage_system"],
            "metrics_collection_interval": 60
          },
          "disk": {
            "measurement": ["used_percent"],
            "metrics_collection_interval": 60,
            "resources": ["*"]
          },
          "mem": {
            "measurement": ["mem_used_percent"],
            "metrics_collection_interval": 60
          }
        }
      }
    }
EOF

    kubectl apply -f cloudwatch-config.yaml
    
    log_success "AWS CloudWatch 통합 설정 완료"
    update_progress "cloudwatch-integration" "completed" "AWS CloudWatch 통합 설정 완료"
}

# =============================================================================
# GCP Cloud Monitoring 통합
# =============================================================================
setup_gcp_monitoring_integration() {
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
EOF

    kubectl apply -f gcp-monitoring-agent.yaml
    
    log_success "GCP Cloud Monitoring 통합 설정 완료"
    update_progress "gcp-monitoring-integration" "completed" "GCP Cloud Monitoring 통합 설정 완료"
}

# =============================================================================
# 크로스 클러스터 모니터링 설정
# =============================================================================
setup_cross_cluster_monitoring() {
    log_step "크로스 클러스터 모니터링 설정"
    
    # 중앙 모니터링 클러스터 설정 (AWS EKS)
    log_info "중앙 모니터링 클러스터 설정 중..."
    
    # 외부 클러스터 연결 설정
    setup_external_cluster_access
    
    # 통합 대시보드 설정
    setup_unified_dashboard
    
    log_success "크로스 클러스터 모니터링 설정 완료"
    update_progress "cross-cluster-setup" "completed" "크로스 클러스터 모니터링 설정 완료"
}

# =============================================================================
# 외부 클러스터 접근 설정
# =============================================================================
setup_external_cluster_access() {
    log_info "외부 클러스터 접근 설정"
    
    # GCP GKE 클러스터 정보를 AWS EKS에서 접근 가능하도록 설정
    cat > external-cluster-config.yaml << EOF
apiVersion: v1
kind: Secret
metadata:
  name: gcp-cluster-credentials
  namespace: monitoring
type: Opaque
data:
  gcp-key.json: $(echo -n "$GCP_SA_KEY" | base64)
EOF

    kubectl apply -f external-cluster-config.yaml
    
    log_success "외부 클러스터 접근 설정 완료"
}

# =============================================================================
# 통합 대시보드 설정
# =============================================================================
setup_unified_dashboard() {
    log_info "통합 대시보드 설정"
    
    # Grafana 통합 대시보드 설정
    cat > unified-dashboard.json << EOF
{
  "dashboard": {
    "title": "Multi-Cloud Monitoring Dashboard",
    "panels": [
      {
        "title": "AWS EKS Cluster Metrics",
        "type": "graph",
        "targets": [
          {
            "expr": "up{job=\"prometheus\"}",
            "legendFormat": "AWS EKS"
          }
        ]
      },
      {
        "title": "GCP GKE Cluster Metrics", 
        "type": "graph",
        "targets": [
          {
            "expr": "up{job=\"prometheus\"}",
            "legendFormat": "GCP GKE"
          }
        ]
      }
    ]
  }
}
EOF

    log_success "통합 대시보드 설정 완료"
}

# =============================================================================
# 모니터링 상태 확인
# =============================================================================
check_monitoring_status() {
    local namespace="${1:-monitoring}"
    
    log_header "모니터링 상태 확인: $namespace"
    
    # Prometheus 상태 확인
    log_step "Prometheus 상태 확인"
    if kubectl get pods -n "$namespace" -l app.kubernetes.io/name=prometheus &> /dev/null; then
        local prometheus_pods=$(kubectl get pods -n "$namespace" -l app.kubernetes.io/name=prometheus --no-headers | wc -l)
        log_success "✅ Prometheus Pods: $prometheus_pods개 실행 중"
        
        # Prometheus 서비스 확인
        if kubectl get svc -n "$namespace" prometheus-server &> /dev/null; then
            local prometheus_url=$(kubectl get svc -n "$namespace" prometheus-server -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
            log_info "Prometheus URL: http://$prometheus_url:80"
        fi
    else
        log_warning "⚠️ Prometheus가 실행되지 않음"
    fi
    
    # Grafana 상태 확인
    log_step "Grafana 상태 확인"
    if kubectl get pods -n "$namespace" -l app.kubernetes.io/name=grafana &> /dev/null; then
        local grafana_pods=$(kubectl get pods -n "$namespace" -l app.kubernetes.io/name=grafana --no-headers | wc -l)
        log_success "✅ Grafana Pods: $grafana_pods개 실행 중"
        
        # Grafana 서비스 확인
        if kubectl get svc -n "$namespace" grafana &> /dev/null; then
            local grafana_url=$(kubectl get svc -n "$namespace" grafana -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
            log_info "Grafana URL: http://$grafana_url:3000"
            log_info "Grafana 로그인: admin / admin123"
        fi
    else
        log_warning "⚠️ Grafana가 실행되지 않음"
    fi
    
    # 전체 파드 상태 확인
    log_step "전체 모니터링 파드 상태"
    kubectl get pods -n "$namespace" -o wide
    
    update_progress "monitoring-status" "completed" "모니터링 상태 확인 완료"
}

# =============================================================================
# 전체 정리
# =============================================================================
cleanup_all() {
    local namespace="${1:-monitoring}"
    
    log_header "모니터링 환경 전체 정리: $namespace"
    
    # Helm 릴리스 삭제
    log_info "Helm 릴리스 삭제 중..."
    helm uninstall prometheus -n "$namespace" 2>/dev/null || true
    helm uninstall grafana -n "$namespace" 2>/dev/null || true
    
    # 네임스페이스 삭제
    log_info "모니터링 네임스페이스 삭제 중..."
    kubectl delete namespace "$namespace" --ignore-not-found=true
    
    # 설정 파일 정리
    rm -f prometheus-values.yaml grafana-values.yaml
    rm -f cloudwatch-config.yaml gcp-monitoring-agent.yaml
    rm -f external-cluster-config.yaml unified-dashboard.json
    
    log_success "모니터링 환경 정리 완료"
    update_progress "cleanup" "completed" "모니터링 환경 정리 완료"
}

# =============================================================================
# 메인 실행 로직
# =============================================================================
main() {
    local action=""
    local provider="aws"
    local cluster_name=""
    local namespace="monitoring"
    
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
            --namespace)
                namespace="$2"
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
        "monitoring-setup")
            setup_monitoring "$provider" "$namespace"
            ;;
        "prometheus-deploy")
            deploy_prometheus "$namespace" "$provider"
            ;;
        "grafana-deploy")
            deploy_grafana "$namespace" "$provider"
            ;;
        "cross-cluster-setup")
            setup_cross_cluster_monitoring
            ;;
        "monitoring-status")
            check_monitoring_status "$namespace"
            ;;
        "cleanup")
            cleanup_all "$namespace"
            ;;
        "multi-cloud-monitoring")
            # 메뉴에서 호출되는 통합 액션
            setup_monitoring "$provider" "$namespace"
            check_monitoring_status "$namespace"
            ;;
        "cluster-status")
            check_monitoring_status "$namespace"
            ;;
        "cluster-management")
            setup_monitoring "$provider" "$namespace"
            ;;
        "status")
            check_monitoring_status "$namespace"
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
