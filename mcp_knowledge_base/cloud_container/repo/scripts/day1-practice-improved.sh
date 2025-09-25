#!/bin/bash

# Cloud Container Day1 실습 개선 스크립트
# GKE 클러스터, GitHub Actions CI/CD, 모니터링 설정

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# 로그 함수들
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_header() { echo -e "${PURPLE}=== $1 ===${NC}"; }

# 환경 변수 설정
export CLUSTER_NAME="cloud-container-day1-cluster"
export REGION="asia-northeast3"
export PROJECT_ID=$(gcloud config get-value project 2>/dev/null)
export NAMESPACE="default"

# 환경 체크
check_prerequisites() {
    log_header "Day1 실습 환경 체크"
    
    local errors=0
    
    # GCP CLI 체크
    if ! command -v gcloud &> /dev/null; then
        log_error "GCP CLI가 설치되지 않았습니다"
        ((errors++))
    else
        log_success "GCP CLI 설치됨"
    fi
    
    # kubectl 체크
    if ! command -v kubectl &> /dev/null; then
        log_error "kubectl이 설치되지 않았습니다"
        ((errors++))
    else
        log_success "kubectl 설치됨"
    fi
    
    # Docker 체크
    if ! command -v docker &> /dev/null; then
        log_error "Docker가 설치되지 않았습니다"
        ((errors++))
    else
        log_success "Docker 설치됨"
    fi
    
    # Helm 체크
    if ! command -v helm &> /dev/null; then
        log_warning "Helm이 설치되지 않았습니다. 설치하시겠습니까? (y/N)"
        read -p "설치: " install_helm
        if [[ "$install_helm" =~ ^[Yy]$ ]]; then
            install_helm
        else
            ((errors++))
        fi
    else
        log_success "Helm 설치됨"
    fi
    
    # GCP 프로젝트 체크
    if [ -z "$PROJECT_ID" ]; then
        log_error "GCP 프로젝트가 설정되지 않았습니다"
        log_info "다음 명령어로 프로젝트를 설정하세요: gcloud config set project PROJECT_ID"
        ((errors++))
    else
        log_success "GCP 프로젝트 설정됨: $PROJECT_ID"
    fi
    
    # GCP 인증 체크
    if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" &> /dev/null; then
        log_error "GCP 인증이 필요합니다"
        log_info "다음 명령어로 인증하세요: gcloud auth login"
        ((errors++))
    else
        log_success "GCP 인증됨"
    fi
    
    if [ $errors -gt 0 ]; then
        log_error "$errors 개의 문제가 발견되었습니다. 해결 후 다시 시도하세요."
        return 1
    fi
    
    log_success "모든 필수 요구사항이 충족되었습니다"
    return 0
}

# Helm 설치
install_helm() {
    log_info "Helm 설치 중..."
    
    curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
    
    if [ $? -eq 0 ]; then
        log_success "Helm 설치 완료"
    else
        log_error "Helm 설치 실패"
        return 1
    fi
}

# GKE 클러스터 생성
create_gke_cluster() {
    log_header "GKE 클러스터 생성"
    
    log_info "클러스터 생성 중..."
    log_info "클러스터명: $CLUSTER_NAME"
    log_info "리전: $REGION"
    log_info "프로젝트: $PROJECT_ID"
    
    gcloud container clusters create "$CLUSTER_NAME" \
        --region="$REGION" \
        --num-nodes=3 \
        --machine-type=e2-medium \
        --enable-autoscaling \
        --min-nodes=1 \
        --max-nodes=10 \
        --enable-autorepair \
        --enable-autoupgrade \
        --disk-size=20GB \
        --disk-type=pd-standard \
        --enable-ip-alias \
        --network="default" \
        --subnetwork="default" \
        --enable-autoscaling \
        --enable-autorepair \
        --enable-autoupgrade
    
    if [ $? -eq 0 ]; then
        log_success "GKE 클러스터 생성 완료"
        
        log_info "클러스터 인증 설정 중..."
        gcloud container clusters get-credentials "$CLUSTER_NAME" --region="$REGION"
        
        if [ $? -eq 0 ]; then
            log_success "클러스터 인증 설정 완료"
            
            log_info "클러스터 정보:"
            kubectl cluster-info
        else
            log_error "클러스터 인증 설정 실패"
            return 1
        fi
    else
        log_error "GKE 클러스터 생성 실패"
        return 1
    fi
}

# 샘플 애플리케이션 배포
deploy_sample_app() {
    log_header "샘플 애플리케이션 배포"
    
    # 샘플 애플리케이션 매니페스트 생성
    cat > sample-app-deployment.yaml << EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: sample-app
  labels:
    app: sample-app
spec:
  replicas: 3
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
        image: gcr.io/google-samples/hello-app:1.0
        ports:
        - containerPort: 8080
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
spec:
  selector:
    app: sample-app
  ports:
    - protocol: TCP
      port: 80
      targetPort: 8080
  type: LoadBalancer
EOF
    
    log_info "샘플 애플리케이션 배포 중..."
    kubectl apply -f sample-app-deployment.yaml
    
    if [ $? -eq 0 ]; then
        log_success "샘플 애플리케이션 배포 완료"
        
        log_info "배포 상태 확인 중..."
        kubectl get deployments
        kubectl get services
        kubectl get pods
        
        log_info "외부 IP 확인 중... (몇 분 소요될 수 있습니다)"
        kubectl get service sample-app-service
    else
        log_error "샘플 애플리케이션 배포 실패"
        return 1
    fi
}

# 모니터링 스택 설치
setup_monitoring() {
    log_header "모니터링 스택 설치"
    
    log_info "Prometheus Helm 저장소 추가 중..."
    helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
    helm repo update
    
    log_info "Prometheus 스택 설치 중..."
    helm install prometheus prometheus-community/kube-prometheus-stack \
        --namespace monitoring \
        --create-namespace \
        --set grafana.adminPassword=admin123 \
        --set prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues=false \
        --set prometheus.prometheusSpec.podMonitorSelectorNilUsesHelmValues=false \
        --set prometheus.prometheusSpec.ruleSelectorNilUsesHelmValues=false
    
    if [ $? -eq 0 ]; then
        log_success "Prometheus 스택 설치 완료"
        
        log_info "모니터링 리소스 확인 중..."
        kubectl get pods -n monitoring
        
        log_info "Grafana 접속 정보:"
        echo "사용자명: admin"
        echo "비밀번호: admin123"
        echo ""
        
        log_info "포트 포워딩 설정 중..."
        kubectl port-forward --namespace monitoring svc/prometheus-grafana 3000:80 &
        PF_PID=$!
        
        log_success "Grafana 접속: http://localhost:3000"
        log_info "포트 포워딩 PID: $PF_PID"
        log_info "포트 포워딩 중지: kill $PF_PID"
    else
        log_error "Prometheus 스택 설치 실패"
        return 1
    fi
}

# HPA (Horizontal Pod Autoscaler) 설정
setup_hpa() {
    log_header "HPA (Horizontal Pod Autoscaler) 설정"
    
    log_info "HPA 생성 중..."
    kubectl autoscale deployment sample-app \
        --cpu-percent=50 \
        --min=1 \
        --max=10
    
    if [ $? -eq 0 ]; then
        log_success "HPA 생성 완료"
        
        log_info "HPA 상태 확인:"
        kubectl get hpa
        
        log_info "HPA 상세 정보:"
        kubectl describe hpa sample-app
    else
        log_error "HPA 생성 실패"
        return 1
    fi
}

# 부하 테스트
run_load_test() {
    log_header "부하 테스트 실행"
    
    log_info "부하 테스트를 위한 테스트 Pod 생성 중..."
    kubectl run load-test --image=busybox --rm -it --restart=Never -- /bin/sh -c "
        while true; do
            wget -q -O- http://sample-app-service.default.svc.cluster.local
            sleep 0.1
        done
    " &
    
    LOAD_TEST_PID=$!
    
    log_info "부하 테스트 시작됨 (PID: $LOAD_TEST_PID)"
    log_info "HPA 동작 확인을 위해 2분간 대기합니다..."
    
    for i in {1..12}; do
        echo -n "."
        sleep 10
        kubectl get hpa sample-app
    done
    echo ""
    
    log_info "부하 테스트 중지 중..."
    kill $LOAD_TEST_PID 2>/dev/null
    
    log_success "부하 테스트 완료"
    log_info "최종 HPA 상태:"
    kubectl get hpa sample-app
}

# GitHub Actions 워크플로우 생성
create_github_workflow() {
    log_header "GitHub Actions 워크플로우 생성"
    
    mkdir -p .github/workflows
    
    cat > .github/workflows/ci-cd.yaml << EOF
name: CI/CD Pipeline

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

env:
  PROJECT_ID: $PROJECT_ID
  CLUSTER_NAME: $CLUSTER_NAME
  REGION: $REGION
  IMAGE_NAME: gcr.io/\${{ env.PROJECT_ID }}/sample-app

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest
    
    steps:
    - name: Checkout code
      uses: actions/checkout@v3
    
    - name: Setup Google Cloud CLI
      uses: google-github-actions/setup-gcloud@v1
      with:
        service_account_key: \${{ secrets.GCP_SA_KEY }}
        project_id: \${{ env.PROJECT_ID }}
    
    - name: Configure Docker for GCR
      run: gcloud auth configure-docker
    
    - name: Build Docker image
      run: |
        docker build -t \${{ env.IMAGE_NAME }}:\${{ github.sha }} .
        docker tag \${{ env.IMAGE_NAME }}:\${{ github.sha }} \${{ env.IMAGE_NAME }}:latest
    
    - name: Push to GCR
      run: |
        docker push \${{ env.IMAGE_NAME }}:\${{ github.sha }}
        docker push \${{ env.IMAGE_NAME }}:latest
    
    - name: Get GKE credentials
      run: gcloud container clusters get-credentials \${{ env.CLUSTER_NAME }} --region \${{ env.REGION }}
    
    - name: Deploy to GKE
      run: |
        kubectl set image deployment/sample-app sample-app=\${{ env.IMAGE_NAME }}:\${{ github.sha }}
        kubectl rollout status deployment/sample-app
        kubectl get services
EOF
    
    log_success "GitHub Actions 워크플로우 생성 완료"
    log_info "파일 위치: .github/workflows/ci-cd.yaml"
    log_warning "GitHub 저장소에 GCP_SA_KEY 시크릿을 설정해야 합니다"
}

# 정리 함수
cleanup() {
    log_header "Day1 실습 정리"
    
    log_warning "모든 리소스를 정리하시겠습니까? (y/N)"
    read -p "확인: " confirm
    
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        log_info "리소스 정리 중..."
        
        # 애플리케이션 삭제
        kubectl delete -f sample-app-deployment.yaml 2>/dev/null
        
        # 모니터링 스택 삭제
        helm uninstall prometheus -n monitoring 2>/dev/null
        kubectl delete namespace monitoring 2>/dev/null
        
        # 클러스터 삭제
        gcloud container clusters delete "$CLUSTER_NAME" --region="$REGION" --quiet
        
        # 로컬 파일 정리
        rm -f sample-app-deployment.yaml
        
        log_success "정리 완료"
    else
        log_info "정리 취소됨"
    fi
}

# Day1 메인 메뉴
day1_main_menu() {
    while true; do
        clear
        log_header "Cloud Container Day1 실습"
        echo "1. 환경 체크"
        echo "2. GKE 클러스터 생성"
        echo "3. 샘플 애플리케이션 배포"
        echo "4. 모니터링 스택 설치"
        echo "5. HPA 설정"
        echo "6. 부하 테스트"
        echo "7. GitHub Actions 워크플로우 생성"
        echo "8. 전체 실습 실행"
        echo "9. 정리"
        echo "0. 이전 메뉴로 돌아가기"
        echo ""
        read -p "메뉴를 선택하세요: " choice
        
        case $choice in
            1) check_prerequisites ;;
            2) create_gke_cluster ;;
            3) deploy_sample_app ;;
            4) setup_monitoring ;;
            5) setup_hpa ;;
            6) run_load_test ;;
            7) create_github_workflow ;;
            8) 
                log_header "전체 Day1 실습 실행"
                check_prerequisites && \
                create_gke_cluster && \
                deploy_sample_app && \
                setup_monitoring && \
                setup_hpa && \
                create_github_workflow && \
                log_success "Day1 실습 완료!"
                ;;
            9) cleanup ;;
            0) return ;;
            *)
                log_error "잘못된 선택입니다. 다시 시도하세요."
                sleep 2
                ;;
        esac
        
        echo ""
        read -p "계속하려면 Enter를 누르세요..."
    done
}

# 스크립트 실행
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    day1_main_menu
fi
