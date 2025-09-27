#!/bin/bash

# Cloud Intermediate - Phase 2-4 클라우드 테스트 스크립트
# 멀티 클라우드 통합 모니터링 클라우드 테스트

# 오류 처리 설정
set -e
set -u
set -o pipefail

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

# 로그 함수들
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_header() { echo -e "${PURPLE}=== $1 ===${NC}"; }

# 설정 변수
AWS_REGION="us-west-2"
GCP_REGION="us-central1"
GCP_ZONE="us-central1-a"
AWS_CLUSTER_NAME="aws-monitoring-cluster"
GCP_CLUSTER_NAME="gcp-monitoring-cluster"
TEST_DURATION=300  # 테스트 지속 시간 (초)

# 테스트 결과 저장
TEST_RESULTS=()
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# 테스트 결과 기록 함수
record_test_result() {
    local test_name="$1"
    local result="$2"
    local message="$3"
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    
    if [ "$result" = "PASS" ]; then
        PASSED_TESTS=$((PASSED_TESTS + 1))
        log_success "✅ $test_name: $message"
    else
        FAILED_TESTS=$((FAILED_TESTS + 1))
        log_error "❌ $test_name: $message"
    fi
}

# 사전 요구사항 확인
check_prerequisites() {
    log_header "사전 요구사항 확인"
    
    # AWS CLI 확인
    if ! command -v aws &> /dev/null; then
        log_error "AWS CLI가 설치되지 않았습니다."
        exit 1
    fi
    
    # GCP CLI 확인
    if ! command -v gcloud &> /dev/null; then
        log_error "GCP CLI가 설치되지 않았습니다."
        exit 1
    fi
    
    # kubectl 확인
    if ! command -v kubectl &> /dev/null; then
        log_error "kubectl이 설치되지 않았습니다."
        exit 1
    fi
    
    # AWS 자격 증명 확인
    if ! aws sts get-caller-identity &> /dev/null; then
        log_error "AWS 자격 증명이 설정되지 않았습니다."
        exit 1
    fi
    
    # GCP 자격 증명 확인
    if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" | grep -q .; then
        log_error "GCP 자격 증명이 설정되지 않았습니다."
        exit 1
    fi
    
    log_success "사전 요구사항 확인 완료"
}

# AWS EKS 클러스터 테스트
test_aws_eks_cluster() {
    log_header "AWS EKS 클러스터 테스트"
    
    # EKS 클러스터 존재 확인
    log_info "AWS EKS 클러스터 존재 확인..."
    if aws eks describe-cluster --name "$AWS_CLUSTER_NAME" --region "$AWS_REGION" &> /dev/null; then
        record_test_result "AWS_EKS_Cluster_Exists" "PASS" "AWS EKS 클러스터 존재"
    else
        record_test_result "AWS_EKS_Cluster_Exists" "FAIL" "AWS EKS 클러스터 없음"
        return 1
    fi
    
    # EKS 클러스터 상태 확인
    log_info "AWS EKS 클러스터 상태 확인..."
    local cluster_status=$(aws eks describe-cluster --name "$AWS_CLUSTER_NAME" --region "$AWS_REGION" --query 'cluster.status' --output text)
    if [ "$cluster_status" = "ACTIVE" ]; then
        record_test_result "AWS_EKS_Cluster_Status" "PASS" "AWS EKS 클러스터 활성 상태"
    else
        record_test_result "AWS_EKS_Cluster_Status" "FAIL" "AWS EKS 클러스터 비활성 상태: $cluster_status"
    fi
    
    # kubectl 설정 확인
    log_info "kubectl 설정 확인..."
    if aws eks update-kubeconfig --name "$AWS_CLUSTER_NAME" --region "$AWS_REGION" &> /dev/null; then
        record_test_result "AWS_EKS_Kubectl_Config" "PASS" "kubectl 설정 완료"
    else
        record_test_result "AWS_EKS_Kubectl_Config" "FAIL" "kubectl 설정 실패"
        return 1
    fi
    
    # 클러스터 노드 확인
    log_info "클러스터 노드 확인..."
    if kubectl get nodes | grep -q "Ready"; then
        record_test_result "AWS_EKS_Nodes_Ready" "PASS" "클러스터 노드 준비 완료"
    else
        record_test_result "AWS_EKS_Nodes_Ready" "FAIL" "클러스터 노드 준비 안됨"
    fi
}

# GCP GKE 클러스터 테스트
test_gcp_gke_cluster() {
    log_header "GCP GKE 클러스터 테스트"
    
    # GKE 클러스터 존재 확인
    log_info "GCP GKE 클러스터 존재 확인..."
    if gcloud container clusters describe "$GCP_CLUSTER_NAME" --zone="$GCP_ZONE" &> /dev/null; then
        record_test_result "GCP_GKE_Cluster_Exists" "PASS" "GCP GKE 클러스터 존재"
    else
        record_test_result "GCP_GKE_Cluster_Exists" "FAIL" "GCP GKE 클러스터 없음"
        return 1
    fi
    
    # GKE 클러스터 상태 확인
    log_info "GCP GKE 클러스터 상태 확인..."
    local cluster_status=$(gcloud container clusters describe "$GCP_CLUSTER_NAME" --zone="$GCP_ZONE" --format="value(status)")
    if [ "$cluster_status" = "RUNNING" ]; then
        record_test_result "GCP_GKE_Cluster_Status" "PASS" "GCP GKE 클러스터 실행 상태"
    else
        record_test_result "GCP_GKE_Cluster_Status" "FAIL" "GCP GKE 클러스터 비실행 상태: $cluster_status"
    fi
    
    # kubectl 설정 확인
    log_info "kubectl 설정 확인..."
    if gcloud container clusters get-credentials "$GCP_CLUSTER_NAME" --zone="$GCP_ZONE" &> /dev/null; then
        record_test_result "GCP_GKE_Kubectl_Config" "PASS" "kubectl 설정 완료"
    else
        record_test_result "GCP_GKE_Kubectl_Config" "FAIL" "kubectl 설정 실패"
        return 1
    fi
    
    # 클러스터 노드 확인
    log_info "클러스터 노드 확인..."
    if kubectl get nodes | grep -q "Ready"; then
        record_test_result "GCP_GKE_Nodes_Ready" "PASS" "클러스터 노드 준비 완료"
    else
        record_test_result "GCP_GKE_Nodes_Ready" "FAIL" "클러스터 노드 준비 안됨"
    fi
}

# AWS 애플리케이션 배포 테스트
test_aws_application_deployment() {
    log_header "AWS 애플리케이션 배포 테스트"
    
    # kubectl 컨텍스트를 AWS로 설정
    aws eks update-kubeconfig --name "$AWS_CLUSTER_NAME" --region "$AWS_REGION" &> /dev/null
    
    # 애플리케이션 배포
    log_info "AWS 애플리케이션 배포 중..."
    if kubectl apply -f samples/day2/monitoring-basics/k8s/aws-app-deployment.yml; then
        record_test_result "AWS_App_Deployment" "PASS" "AWS 애플리케이션 배포 성공"
    else
        record_test_result "AWS_App_Deployment" "FAIL" "AWS 애플리케이션 배포 실패"
        return 1
    fi
    
    # 서비스 배포
    log_info "AWS 서비스 배포 중..."
    if kubectl apply -f samples/day2/monitoring-basics/k8s/aws-app-service.yml; then
        record_test_result "AWS_App_Service" "PASS" "AWS 서비스 배포 성공"
    else
        record_test_result "AWS_App_Service" "FAIL" "AWS 서비스 배포 실패"
    fi
    
    # ServiceMonitor 배포
    log_info "AWS ServiceMonitor 배포 중..."
    if kubectl apply -f samples/day2/monitoring-basics/k8s/aws-app-monitoring.yml; then
        record_test_result "AWS_App_ServiceMonitor" "PASS" "AWS ServiceMonitor 배포 성공"
    else
        record_test_result "AWS_App_ServiceMonitor" "FAIL" "AWS ServiceMonitor 배포 실패"
    fi
    
    # 배포 상태 확인
    log_info "배포 상태 확인 중..."
    sleep 30
    
    if kubectl get pods | grep -q "aws-monitoring-app.*Running"; then
        record_test_result "AWS_App_Pods_Running" "PASS" "AWS 애플리케이션 Pod 실행 중"
    else
        record_test_result "AWS_App_Pods_Running" "FAIL" "AWS 애플리케이션 Pod 실행 실패"
    fi
    
    if kubectl get services | grep -q "aws-monitoring-app-service"; then
        record_test_result "AWS_App_Service_Running" "PASS" "AWS 서비스 실행 중"
    else
        record_test_result "AWS_App_Service_Running" "FAIL" "AWS 서비스 실행 실패"
    fi
}

# GCP 애플리케이션 배포 테스트
test_gcp_application_deployment() {
    log_header "GCP 애플리케이션 배포 테스트"
    
    # kubectl 컨텍스트를 GCP로 설정
    gcloud container clusters get-credentials "$GCP_CLUSTER_NAME" --zone="$GCP_ZONE" &> /dev/null
    
    # GCP용 애플리케이션 매니페스트 생성
    log_info "GCP용 애플리케이션 매니페스트 생성 중..."
    cat > /tmp/gcp-app-deployment.yml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: gcp-monitoring-app
  namespace: default
  labels:
    app: gcp-monitoring-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: gcp-monitoring-app
  template:
    metadata:
      labels:
        app: gcp-monitoring-app
      annotations:
        prometheus.io/scrape: "true"
        prometheus.io/port: "3000"
        prometheus.io/path: "/metrics"
    spec:
      containers:
      - name: gcp-monitoring-app
        image: nginx:latest
        ports:
        - containerPort: 80
        - containerPort: 3000
        env:
        - name: APP_NAME
          value: "gcp-monitoring-app"
        - name: ENVIRONMENT
          value: "production"
        resources:
          requests:
            memory: "64Mi"
            cpu: "50m"
          limits:
            memory: "128Mi"
            cpu: "100m"
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
EOF
    
    # 애플리케이션 배포
    log_info "GCP 애플리케이션 배포 중..."
    if kubectl apply -f /tmp/gcp-app-deployment.yml; then
        record_test_result "GCP_App_Deployment" "PASS" "GCP 애플리케이션 배포 성공"
    else
        record_test_result "GCP_App_Deployment" "FAIL" "GCP 애플리케이션 배포 실패"
        return 1
    fi
    
    # 서비스 배포
    log_info "GCP 서비스 배포 중..."
    cat > /tmp/gcp-app-service.yml << 'EOF'
apiVersion: v1
kind: Service
metadata:
  name: gcp-monitoring-app-service
  namespace: default
  labels:
    app: gcp-monitoring-app
spec:
  selector:
    app: gcp-monitoring-app
  ports:
  - name: http
    port: 80
    targetPort: 80
    protocol: TCP
  - name: metrics
    port: 3000
    targetPort: 3000
    protocol: TCP
  type: ClusterIP
EOF
    
    if kubectl apply -f /tmp/gcp-app-service.yml; then
        record_test_result "GCP_App_Service" "PASS" "GCP 서비스 배포 성공"
    else
        record_test_result "GCP_App_Service" "FAIL" "GCP 서비스 배포 실패"
    fi
    
    # 배포 상태 확인
    log_info "배포 상태 확인 중..."
    sleep 30
    
    if kubectl get pods | grep -q "gcp-monitoring-app.*Running"; then
        record_test_result "GCP_App_Pods_Running" "PASS" "GCP 애플리케이션 Pod 실행 중"
    else
        record_test_result "GCP_App_Pods_Running" "FAIL" "GCP 애플리케이션 Pod 실행 실패"
    fi
    
    if kubectl get services | grep -q "gcp-monitoring-app-service"; then
        record_test_result "GCP_App_Service_Running" "PASS" "GCP 서비스 실행 중"
    else
        record_test_result "GCP_App_Service_Running" "FAIL" "GCP 서비스 실행 실패"
    fi
}

# Prometheus 설정 파일 검증
test_prometheus_configs() {
    log_header "Prometheus 설정 파일 검증"
    
    # AWS Prometheus 설정 검증
    log_info "AWS Prometheus 설정 검증..."
    if python3 -c "import yaml; yaml.safe_load(open('samples/day2/monitoring-basics/aws-prometheus-config.yml'))" 2>/dev/null; then
        record_test_result "AWS_Prometheus_Config_Valid" "PASS" "AWS Prometheus 설정 파일 유효"
    else
        record_test_result "AWS_Prometheus_Config_Valid" "FAIL" "AWS Prometheus 설정 파일 오류"
    fi
    
    # GCP Prometheus 설정 검증
    log_info "GCP Prometheus 설정 검증..."
    if python3 -c "import yaml; yaml.safe_load(open('samples/day2/monitoring-basics/gcp-prometheus-config.yml'))" 2>/dev/null; then
        record_test_result "GCP_Prometheus_Config_Valid" "PASS" "GCP Prometheus 설정 파일 유효"
    else
        record_test_result "GCP_Prometheus_Config_Valid" "FAIL" "GCP Prometheus 설정 파일 오류"
    fi
}

# GitHub Actions 워크플로우 검증
test_github_actions_workflow() {
    log_header "GitHub Actions 워크플로우 검증"
    
    # 워크플로우 파일 존재 확인
    log_info "GitHub Actions 워크플로우 파일 확인..."
    if [ -f "samples/day2/monitoring-basics/.github/workflows/deploy-aws-app.yml" ]; then
        record_test_result "GitHubActions_Workflow_Exists" "PASS" "GitHub Actions 워크플로우 파일 존재"
    else
        record_test_result "GitHubActions_Workflow_Exists" "FAIL" "GitHub Actions 워크플로우 파일 없음"
        return 1
    fi
    
    # 워크플로우 YAML 문법 검증
    log_info "GitHub Actions 워크플로우 YAML 문법 검증..."
    if python3 -c "import yaml; yaml.safe_load(open('samples/day2/monitoring-basics/.github/workflows/deploy-aws-app.yml'))" 2>/dev/null; then
        record_test_result "GitHubActions_Workflow_Valid" "PASS" "GitHub Actions 워크플로우 YAML 문법 유효"
    else
        record_test_result "GitHubActions_Workflow_Valid" "FAIL" "GitHub Actions 워크플로우 YAML 문법 오류"
    fi
}

# 리소스 정리
cleanup_resources() {
    log_header "리소스 정리"
    
    # AWS 리소스 정리
    log_info "AWS 리소스 정리 중..."
    aws eks update-kubeconfig --name "$AWS_CLUSTER_NAME" --region "$AWS_REGION" &> /dev/null
    kubectl delete -f samples/day2/monitoring-basics/k8s/aws-app-deployment.yml &> /dev/null || true
    kubectl delete -f samples/day2/monitoring-basics/k8s/aws-app-service.yml &> /dev/null || true
    kubectl delete -f samples/day2/monitoring-basics/k8s/aws-app-monitoring.yml &> /dev/null || true
    
    # GCP 리소스 정리
    log_info "GCP 리소스 정리 중..."
    gcloud container clusters get-credentials "$GCP_CLUSTER_NAME" --zone="$GCP_ZONE" &> /dev/null
    kubectl delete -f /tmp/gcp-app-deployment.yml &> /dev/null || true
    kubectl delete -f /tmp/gcp-app-service.yml &> /dev/null || true
    
    # 임시 파일 정리
    rm -f /tmp/gcp-app-deployment.yml /tmp/gcp-app-service.yml
    
    log_success "리소스 정리 완료"
}

# 테스트 결과 요약
print_test_summary() {
    log_header "테스트 결과 요약"
    
    local success_rate=$((PASSED_TESTS * 100 / TOTAL_TESTS))
    
    echo "총 테스트: $TOTAL_TESTS"
    echo "통과: $PASSED_TESTS"
    echo "실패: $FAILED_TESTS"
    echo "성공률: $success_rate%"
    
    if [ "$success_rate" -ge 90 ]; then
        log_success "🎉 Phase 2-4 클라우드 테스트 통과! (${success_rate}%)"
    elif [ "$success_rate" -ge 70 ]; then
        log_warning "⚠️ Phase 2-4 클라우드 테스트 부분 통과 (${success_rate}%)"
    else
        log_error "❌ Phase 2-4 클라우드 테스트 실패 (${success_rate}%)"
    fi
}

# 메인 실행 함수
main() {
    log_header "Cloud Intermediate Phase 2-4 클라우드 테스트 시작"
    
    # 사전 요구사항 확인
    check_prerequisites
    
    # AWS EKS 클러스터 테스트
    test_aws_eks_cluster
    
    # GCP GKE 클러스터 테스트
    test_gcp_gke_cluster
    
    # AWS 애플리케이션 배포 테스트
    test_aws_application_deployment
    
    # GCP 애플리케이션 배포 테스트
    test_gcp_application_deployment
    
    # Prometheus 설정 파일 검증
    test_prometheus_configs
    
    # GitHub Actions 워크플로우 검증
    test_github_actions_workflow
    
    # 테스트 결과 요약
    print_test_summary
    
    # 리소스 정리
    cleanup_resources
    
    log_header "Phase 2-4 클라우드 테스트 완료"
}

# 스크립트 실행
main "$@"
