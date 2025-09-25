#!/bin/bash

# Cloud Intermediate Advanced Helper Script
# 컨테이너 기술과 Kubernetes 중심의 고도화된 중급 실무 과정 자동화 도구

# 오류 처리 설정
set -e  # 오류 발생 시 스크립트 종료
set -u  # 정의되지 않은 변수 사용 시 오류
set -o pipefail  # 파이프라인에서 오류 발생 시 종료

# 스크립트 종료 시 정리 함수
cleanup() {
    echo "스크립트가 종료됩니다. 정리 작업을 수행합니다..."
    # 필요한 정리 작업 추가
}

# 신호 트랩 설정
trap cleanup EXIT INT TERM

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Logging functions
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_header() { echo -e "${PURPLE}[HEADER]${NC} $1"; }

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"
LOG_FILE="$PROJECT_ROOT/cloud-intermediate-advanced.log"

# Initialize log file
init_log() {
    echo "=== Cloud Intermediate Advanced Helper Log ===" > "$LOG_FILE"
    echo "Started at: $(date)" >> "$LOG_FILE"
    echo "Script directory: $SCRIPT_DIR" >> "$LOG_FILE"
    echo "Project root: $PROJECT_ROOT" >> "$LOG_FILE"
    echo "" >> "$LOG_FILE"
}

# Log function
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
    echo "$1"
}

# Environment check functions
check_docker_cli() {
    log_info "Docker CLI 상태 확인 중..."
    if command -v docker &> /dev/null; then
        DOCKER_VERSION=$(docker --version 2>&1 | cut -d' ' -f3 | cut -d',' -f1)
        log_success "Docker CLI 설치됨: $DOCKER_VERSION"
        
        # Check Docker daemon
        if docker info &> /dev/null; then
            log_success "Docker 데몬 실행 중"
            return 0
        else
            log_error "Docker 데몬 시작 필요"
            return 1
        fi
    else
        log_error "Docker CLI 설치 필요"
        return 1
    fi
}

check_docker_compose() {
    log_info "Docker Compose 상태 확인 중..."
    if command -v docker-compose &> /dev/null; then
        COMPOSE_VERSION=$(docker-compose --version 2>&1 | cut -d' ' -f3 | cut -d',' -f1)
        log_success "Docker Compose 설치됨: $COMPOSE_VERSION"
        return 0
    else
        log_error "Docker Compose 설치 필요"
        return 1
    fi
}

check_kubectl() {
    log_info "kubectl 상태 확인 중..."
    if command -v kubectl &> /dev/null; then
        KUBECTL_VERSION=$(kubectl version --client --short 2>&1 | cut -d' ' -f3)
        log_success "kubectl 설치됨: $KUBECTL_VERSION"
        
        # Check Kubernetes cluster connection
        if kubectl cluster-info &> /dev/null; then
            log_success "Kubernetes 클러스터 연결됨"
            return 0
        else
            log_warning "Kubernetes 클러스터에 연결할 수 없음"
            return 1
        fi
    else
        log_error "kubectl 설치 필요"
        return 1
    fi
}

check_aws_cli() {
    log_info "AWS CLI 상태 확인 중..."
    if command -v aws &> /dev/null; then
        AWS_VERSION=$(aws --version 2>&1 | cut -d' ' -f1)
        log_success "AWS CLI 설치됨: $AWS_VERSION"
        
        # Check AWS credentials
        if aws sts get-caller-identity &> /dev/null; then
            AWS_ACCOUNT=$(aws sts get-caller-identity --query Account --output text 2>/dev/null)
            AWS_USER=$(aws sts get-caller-identity --query Arn --output text 2>/dev/null | cut -d'/' -f2)
            log_success "AWS 계정 연결됨: $AWS_ACCOUNT ($AWS_USER)"
            return 0
        else
            log_error "AWS 계정 설정 필요: aws configure 실행"
            return 1
        fi
    else
        log_error "AWS CLI 설치 필요"
        return 1
    fi
}

check_gcp_cli() {
    log_info "GCP CLI 상태 확인 중..."
    if command -v gcloud &> /dev/null; then
        GCP_VERSION=$(gcloud version --format="value(Google Cloud SDK)" 2>/dev/null)
        log_success "GCP CLI 설치됨: $GCP_VERSION"
        
        # Check GCP authentication
        if gcloud auth list --filter=status:ACTIVE --format="value(account)" &> /dev/null; then
            GCP_ACCOUNT=$(gcloud auth list --filter=status:ACTIVE --format="value(account)" | head -1)
            GCP_PROJECT=$(gcloud config get-value project 2>/dev/null)
            log_success "GCP 계정 연결됨: $GCP_ACCOUNT (프로젝트: $GCP_PROJECT)"
            return 0
        else
            log_error "GCP 계정 설정 필요: gcloud auth login 실행"
            return 1
        fi
    else
        log_error "GCP CLI 설치 필요"
        return 1
    fi
}

check_git() {
    log_info "Git 상태 확인 중..."
    if command -v git &> /dev/null; then
        GIT_VERSION=$(git --version 2>&1 | cut -d' ' -f3)
        log_success "Git 설치됨: $GIT_VERSION"
        return 0
    else
        log_error "Git 설치 필요"
        return 1
    fi
}

check_github_cli() {
    log_info "GitHub CLI 상태 확인 중..."
    if command -v gh &> /dev/null; then
        GH_VERSION=$(gh --version 2>&1 | head -1 | cut -d' ' -f3)
        log_success "GitHub CLI 설치됨: $GH_VERSION"
        
        # Check GitHub authentication
        if gh auth status &> /dev/null; then
            GH_USER=$(gh api user --jq .login 2>/dev/null)
            log_success "GitHub 계정 연결됨: $GH_USER"
            return 0
        else
            log_warning "GitHub CLI 인증 필요: gh auth login 실행"
            return 1
        fi
    else
        log_warning "GitHub CLI 설치 필요 (선택사항)"
        return 1
    fi
}

check_jq() {
    log_info "jq 상태 확인 중..."
    if command -v jq &> /dev/null; then
        JQ_VERSION=$(jq --version 2>&1 | cut -d'-' -f2)
        log_success "jq 설치됨: $JQ_VERSION"
        return 0
    else
        log_error "jq 설치 필요"
        return 1
    fi
}

# Comprehensive environment check
comprehensive_environment_check() {
    log_header "종합 환경 체크"
    
    local total_checks=8
    local passed_checks=0
    
    check_docker_cli && ((passed_checks++))
    check_docker_compose && ((passed_checks++))
    check_kubectl && ((passed_checks++))
    check_aws_cli && ((passed_checks++))
    check_gcp_cli && ((passed_checks++))
    check_git && ((passed_checks++))
    check_github_cli && ((passed_checks++))
    check_jq && ((passed_checks++))
    
    echo ""
    log_info "환경 체크 결과: $passed_checks/$total_checks 통과"
    
    if [ $passed_checks -eq $total_checks ]; then
        log_success "🎉 모든 환경이 준비되었습니다!"
    elif [ $passed_checks -ge 6 ]; then
        log_warning "⚠️ 대부분의 환경이 준비되었습니다. 일부 기능이 제한될 수 있습니다."
    else
        log_error "❌ 환경 설정이 부족합니다. 필요한 도구를 설치하세요."
    fi
}

# Docker resource monitoring
monitor_docker_resources() {
    log_header "Docker 리소스 현황"
    
    if ! docker info &> /dev/null; then
        log_error "Docker 데몬이 실행되지 않음"
        return 1
    fi
    
    # Container statistics
    local running_containers=$(docker ps --format "{{.Names}}" 2>/dev/null | wc -l)
    local total_containers=$(docker ps -a --format "{{.Names}}" 2>/dev/null | wc -l)
    local stopped_containers=$((total_containers - running_containers))
    
    echo ""
    log_info "📊 컨테이너 현황:"
    echo "   실행 중: $running_containers개"
    echo "   중지됨: $stopped_containers개"
    echo "   전체: $total_containers개"
    
    if [ $running_containers -gt 0 ]; then
        echo ""
        log_info "실행 중인 컨테이너:"
        docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" 2>/dev/null
    fi
    
    # Image statistics
    local total_images=$(docker images --format "{{.Repository}}" 2>/dev/null | wc -l)
    local dangling_images=$(docker images -f "dangling=true" --format "{{.Repository}}" 2>/dev/null | wc -l)
    
    echo ""
    log_info "📊 이미지 현황:"
    echo "   전체: $total_images개"
    echo "   미사용: $dangling_images개"
    
    if [ $total_images -gt 0 ]; then
        echo ""
        log_info "최근 이미지:"
        docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}\t{{.CreatedAt}}" 2>/dev/null | head -6
    fi
    
    # Volume statistics
    local total_volumes=$(docker volume ls --format "{{.Name}}" 2>/dev/null | wc -l)
    local unused_volumes=$(docker volume ls -f "dangling=true" --format "{{.Name}}" 2>/dev/null | wc -l)
    
    echo ""
    log_info "📊 볼륨 현황:"
    echo "   전체: $total_volumes개"
    echo "   미사용: $unused_volumes개"
    
    # Network statistics
    local total_networks=$(docker network ls --format "{{.Name}}" 2>/dev/null | wc -l)
    
    echo ""
    log_info "📊 네트워크 현황: $total_networks개"
    
    # Resource usage
    echo ""
    log_info "📊 리소스 사용량:"
    docker system df 2>/dev/null || log_warning "리소스 사용량 정보를 가져올 수 없음"
}

# Kubernetes resource monitoring
monitor_kubernetes_resources() {
    log_header "Kubernetes 리소스 현황"
    
    if ! kubectl cluster-info &> /dev/null; then
        log_error "Kubernetes 클러스터에 연결할 수 없음"
        return 1
    fi
    
    # Cluster information
    echo ""
    log_info "📊 클러스터 정보:"
    kubectl cluster-info --request-timeout=5s 2>/dev/null | head -3
    
    # Node information
    local total_nodes=$(kubectl get nodes --no-headers 2>/dev/null | wc -l)
    local ready_nodes=$(kubectl get nodes --no-headers --field-selector=status.conditions[0].status=True 2>/dev/null | wc -l)
    
    echo ""
    log_info "📊 노드 현황:"
    echo "   준비됨: $ready_nodes개"
    echo "   전체: $total_nodes개"
    
    if [ $total_nodes -gt 0 ]; then
        echo ""
        log_info "노드 상태:"
        kubectl get nodes --no-headers 2>/dev/null | awk '{print "   " $1 ": " $2}'
    fi
    
    # Pod information
    local total_pods=$(kubectl get pods --all-namespaces --no-headers 2>/dev/null | wc -l)
    local running_pods=$(kubectl get pods --all-namespaces --field-selector=status.phase=Running --no-headers 2>/dev/null | wc -l)
    local pending_pods=$(kubectl get pods --all-namespaces --field-selector=status.phase=Pending --no-headers 2>/dev/null | wc -l)
    local failed_pods=$(kubectl get pods --all-namespaces --field-selector=status.phase=Failed --no-headers 2>/dev/null | wc -l)
    
    echo ""
    log_info "📊 Pod 현황:"
    echo "   실행 중: $running_pods개"
    echo "   대기 중: $pending_pods개"
    echo "   실패: $failed_pods개"
    echo "   전체: $total_pods개"
    
    # Service information
    local total_services=$(kubectl get services --all-namespaces --no-headers 2>/dev/null | wc -l)
    
    echo ""
    log_info "📊 서비스 현황: $total_services개"
    
    # Namespace information
    local total_namespaces=$(kubectl get namespaces --no-headers 2>/dev/null | wc -l)
    
    echo ""
    log_info "📊 네임스페이스 현황: $total_namespaces개"
    
    if [ $total_namespaces -gt 0 ]; then
        echo ""
        log_info "네임스페이스 목록:"
        kubectl get namespaces --no-headers 2>/dev/null | awk '{print "   " $1}'
    fi
}

# AWS container services monitoring
monitor_aws_container_services() {
    log_header "AWS 컨테이너 서비스 현황"
    
    if ! aws sts get-caller-identity &> /dev/null; then
        log_error "AWS CLI 설정 필요"
        return 1
    fi
    
    # ECS clusters
    echo ""
    log_info "📊 ECS 클러스터 현황:"
    local ecs_clusters=$(aws ecs list-clusters --query 'clusterArns' --output text 2>/dev/null | wc -w)
    echo "   클러스터 수: $ecs_clusters개"
    
    if [ $ecs_clusters -gt 0 ]; then
        echo ""
        log_info "ECS 클러스터 목록:"
        aws ecs list-clusters --query 'clusterArns[]' --output table 2>/dev/null | head -5
    fi
    
    # EKS clusters
    echo ""
    log_info "📊 EKS 클러스터 현황:"
    local eks_clusters=$(aws eks list-clusters --query 'clusters' --output text 2>/dev/null | wc -w)
    echo "   클러스터 수: $eks_clusters개"
    
    if [ $eks_clusters -gt 0 ]; then
        echo ""
        log_info "EKS 클러스터 목록:"
        aws eks list-clusters --query 'clusters[]' --output table 2>/dev/null
    fi
    
    # ECR repositories
    echo ""
    log_info "📊 ECR 리포지토리 현황:"
    local ecr_repos=$(aws ecr describe-repositories --query 'repositories' --output text 2>/dev/null | wc -l)
    echo "   리포지토리 수: $ecr_repos개"
    
    if [ $ecr_repos -gt 0 ]; then
        echo ""
        log_info "ECR 리포지토리 목록:"
        aws ecr describe-repositories --query 'repositories[].repositoryName' --output table 2>/dev/null | head -5
    fi
}

# GCP container services monitoring
monitor_gcp_container_services() {
    log_header "GCP 컨테이너 서비스 현황"
    
    if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" &> /dev/null; then
        log_error "GCP CLI 설정 필요"
        return 1
    fi
    
    # GKE clusters
    echo ""
    log_info "📊 GKE 클러스터 현황:"
    local gke_clusters=$(gcloud container clusters list --format="value(name)" 2>/dev/null | wc -l)
    echo "   클러스터 수: $gke_clusters개"
    
    if [ $gke_clusters -gt 0 ]; then
        echo ""
        log_info "GKE 클러스터 목록:"
        gcloud container clusters list --format="table(name,location,status,currentMasterVersion)" 2>/dev/null
    fi
    
    # Cloud Run services
    echo ""
    log_info "📊 Cloud Run 서비스 현황:"
    local cloud_run_services=$(gcloud run services list --format="value(metadata.name)" 2>/dev/null | wc -l)
    echo "   서비스 수: $cloud_run_services개"
    
    if [ $cloud_run_services -gt 0 ]; then
        echo ""
        log_info "Cloud Run 서비스 목록:"
        gcloud run services list --format="table(metadata.name,status.url,status.conditions[0].status)" 2>/dev/null
    fi
    
    # Container Registry images
    echo ""
    log_info "📊 Container Registry 현황:"
    local gcr_images=$(gcloud container images list --format="value(name)" 2>/dev/null | wc -l)
    echo "   이미지 수: $gcr_images개"
    
    if [ $gcr_images -gt 0 ]; then
        echo ""
        log_info "Container Registry 이미지 목록:"
        gcloud container images list --format="table(name)" 2>/dev/null | head -5
    fi
}

# Cost analysis functions
analyze_aws_costs() {
    log_header "AWS 비용 분석"
    
    if ! aws sts get-caller-identity &> /dev/null; then
        log_error "AWS CLI 설정 필요"
        return 1
    fi
    
    # ECS costs
    echo ""
    log_info "📊 ECS 비용 분석:"
    local ecs_clusters=$(aws ecs list-clusters --query 'clusterArns' --output text 2>/dev/null | wc -w)
    if [ $ecs_clusters -gt 0 ]; then
        echo "   ECS 클러스터: $ecs_clusters개 (클러스터당 월 $10-50 예상)"
    else
        echo "   ECS 클러스터: 없음"
    fi
    
    # EKS costs
    echo ""
    log_info "📊 EKS 비용 분석:"
    local eks_clusters=$(aws eks list-clusters --query 'clusters' --output text 2>/dev/null | wc -w)
    if [ $eks_clusters -gt 0 ]; then
        echo "   EKS 클러스터: $eks_clusters개 (클러스터당 월 $73 예상)"
    else
        echo "   EKS 클러스터: 없음"
    fi
    
    # ECR costs
    echo ""
    log_info "📊 ECR 비용 분석:"
    local ecr_repos=$(aws ecr describe-repositories --query 'repositories' --output text 2>/dev/null | wc -l)
    if [ $ecr_repos -gt 0 ]; then
        echo "   ECR 리포지토리: $ecr_repos개 (GB당 월 $0.10 예상)"
    else
        echo "   ECR 리포지토리: 없음"
    fi
    
    echo ""
    log_info "💡 비용 절약 권장사항:"
    echo "   - 사용하지 않는 클러스터 삭제"
    echo "   - 미사용 이미지 정리"
    echo "   - 적절한 인스턴스 타입 선택"
}

analyze_gcp_costs() {
    log_header "GCP 비용 분석"
    
    if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" &> /dev/null; then
        log_error "GCP CLI 설정 필요"
        return 1
    fi
    
    # GKE costs
    echo ""
    log_info "📊 GKE 비용 분석:"
    local gke_clusters=$(gcloud container clusters list --format="value(name)" 2>/dev/null | wc -l)
    if [ $gke_clusters -gt 0 ]; then
        echo "   GKE 클러스터: $gke_clusters개 (클러스터당 월 $73 예상)"
    else
        echo "   GKE 클러스터: 없음"
    fi
    
    # Cloud Run costs
    echo ""
    log_info "📊 Cloud Run 비용 분석:"
    local cloud_run_services=$(gcloud run services list --format="value(metadata.name)" 2>/dev/null | wc -l)
    if [ $cloud_run_services -gt 0 ]; then
        echo "   Cloud Run 서비스: $cloud_run_services개 (요청당 $0.0000004 예상)"
    else
        echo "   Cloud Run 서비스: 없음"
    fi
    
    # Container Registry costs
    echo ""
    log_info "📊 Container Registry 비용 분석:"
    local gcr_images=$(gcloud container images list --format="value(name)" 2>/dev/null | wc -l)
    if [ $gcr_images -gt 0 ]; then
        echo "   Container Registry 이미지: $gcr_images개 (GB당 월 $0.026 예상)"
    else
        echo "   Container Registry 이미지: 없음"
    fi
    
    echo ""
    log_info "💡 비용 절약 권장사항:"
    echo "   - 사용하지 않는 클러스터 삭제"
    echo "   - 미사용 이미지 정리"
    echo "   - Cloud Run 자동 스케일링 활용"
}

# Monitoring stack setup
setup_monitoring_stack() {
    log_header "모니터링 스택 설정"
    
    echo "📊 모니터링 스택 옵션:"
    echo "1. Prometheus + Grafana (로컬)"
    echo "2. AWS CloudWatch"
    echo "3. GCP Cloud Monitoring"
    echo "4. 취소"
    echo ""
    
    local choice
    read -p "설정할 모니터링 스택을 선택하세요 (1-4): " choice
    
    case $choice in
        1)
            log_info "Prometheus + Grafana 설정 시작"
            # Prometheus + Grafana 설정 로직 추가
            ;;
        2)
            log_info "AWS CloudWatch 설정 시작"
            # AWS CloudWatch 설정 로직 추가
            ;;
        3)
            log_info "GCP Cloud Monitoring 설정 시작"
            # GCP Cloud Monitoring 설정 로직 추가
            ;;
        4)
            log_info "모니터링 스택 설정 취소"
            ;;
        *)
            log_error "잘못된 선택입니다."
            ;;
    esac
}

# Day 1 practice automation
day1_practice_automation() {
    log_header "Day 1 실습 자동화"
    
    echo "🐳 Day 1 실습 옵션:"
    echo "1. Docker 고급 활용 실습"
    echo "2. Kubernetes 기초 실습"
    echo "3. 클라우드 컨테이너 서비스 실습"
    echo "4. 전체 실습 실행"
    echo "5. 취소"
    echo ""
    
    local choice
    read -p "실행할 실습을 선택하세요 (1-5): " choice
    
    case $choice in
        1)
            log_info "🐳 Docker 고급 활용 실습 시작"
            # Docker 고급 실습 자동화 로직 추가
            ;;
        2)
            log_info "☸️  Kubernetes 기초 실습 시작"
            # Kubernetes 실습 자동화 로직 추가
            ;;
        3)
            log_info "☁️  클라우드 컨테이너 서비스 실습 시작"
            # 클라우드 컨테이너 서비스 실습 자동화 로직 추가
            ;;
        4)
            log_info "🚀 Day 1 전체 실습 실행"
            # 전체 실습 자동화 로직 추가
            ;;
        5)
            log_info "Day 1 실습 취소"
            ;;
        *)
            log_error "잘못된 선택입니다."
            ;;
    esac
}

# Day 2 practice automation
day2_practice_automation() {
    log_header "Day 2 실습 자동화"
    
    echo "🔄 Day 2 실습 옵션:"
    echo "1. CI/CD 파이프라인 실습"
    echo "2. 클라우드 배포 실습"
    echo "3. 모니터링 기초 실습"
    echo "4. 전체 실습 실행"
    echo "5. 취소"
    echo ""
    
    local choice
    read -p "실행할 실습을 선택하세요 (1-5): " choice
    
    case $choice in
        1)
            log_info "🔄 CI/CD 파이프라인 실습 시작"
            # CI/CD 실습 자동화 로직 추가
            ;;
        2)
            log_info "🚀 클라우드 배포 실습 시작"
            # 클라우드 배포 실습 자동화 로직 추가
            ;;
        3)
            log_info "📊 모니터링 기초 실습 시작"
            # 모니터링 실습 자동화 로직 추가
            ;;
        4)
            log_info "🚀 Day 2 전체 실습 실행"
            # 전체 실습 자동화 로직 추가
            ;;
        5)
            log_info "Day 2 실습 취소"
            ;;
        *)
            log_error "잘못된 선택입니다."
            ;;
    esac
}

# Resource cleanup functions
cleanup_aws_resources() {
    log_header "AWS 리소스 정리"
    
    if ! aws sts get-caller-identity &> /dev/null; then
        log_error "AWS CLI 설정 필요"
        return 1
    fi
    
    echo "🧹 AWS 리소스 정리 옵션:"
    echo "1. ECS 클러스터 정리"
    echo "2. EKS 클러스터 정리"
    echo "3. ECR 리포지토리 정리"
    echo "4. 전체 정리"
    echo "5. 취소"
    echo ""
    
    local choice
    read -p "정리할 리소스를 선택하세요 (1-5): " choice
    
    case $choice in
        1)
            log_info "ECS 클러스터 정리 시작"
            # ECS 클러스터 정리 로직 추가
            ;;
        2)
            log_info "EKS 클러스터 정리 시작"
            # EKS 클러스터 정리 로직 추가
            ;;
        3)
            log_info "ECR 리포지토리 정리 시작"
            # ECR 리포지토리 정리 로직 추가
            ;;
        4)
            log_info "AWS 전체 리소스 정리 시작"
            # 전체 정리 로직 추가
            ;;
        5)
            log_info "AWS 리소스 정리 취소"
            ;;
        *)
            log_error "잘못된 선택입니다."
            ;;
    esac
}

cleanup_gcp_resources() {
    log_header "GCP 리소스 정리"
    
    if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" &> /dev/null; then
        log_error "GCP CLI 설정 필요"
        return 1
    fi
    
    echo "🧹 GCP 리소스 정리 옵션:"
    echo "1. GKE 클러스터 정리"
    echo "2. Cloud Run 서비스 정리"
    echo "3. Container Registry 정리"
    echo "4. 전체 정리"
    echo "5. 취소"
    echo ""
    
    local choice
    read -p "정리할 리소스를 선택하세요 (1-5): " choice
    
    case $choice in
        1)
            log_info "GKE 클러스터 정리 시작"
            # GKE 클러스터 정리 로직 추가
            ;;
        2)
            log_info "Cloud Run 서비스 정리 시작"
            # Cloud Run 서비스 정리 로직 추가
            ;;
        3)
            log_info "Container Registry 정리 시작"
            # Container Registry 정리 로직 추가
            ;;
        4)
            log_info "GCP 전체 리소스 정리 시작"
            # 전체 정리 로직 추가
            ;;
        5)
            log_info "GCP 리소스 정리 취소"
            ;;
        *)
            log_error "잘못된 선택입니다."
            ;;
    esac
}

cleanup_docker_resources() {
    log_header "Docker 리소스 정리"
    
    if ! docker info &> /dev/null; then
        log_error "Docker 데몬이 실행되지 않음"
        return 1
    fi
    
    echo "🧹 Docker 리소스 정리 옵션:"
    echo "1. 중지된 컨테이너 정리"
    echo "2. 미사용 이미지 정리"
    echo "3. 미사용 볼륨 정리"
    echo "4. 미사용 네트워크 정리"
    echo "5. 전체 정리"
    echo "6. 취소"
    echo ""
    
    local choice
    read -p "정리할 리소스를 선택하세요 (1-6): " choice
    
    case $choice in
        1)
            log_info "중지된 컨테이너 정리 시작"
            docker container prune -f
            log_success "중지된 컨테이너 정리 완료"
            ;;
        2)
            log_info "미사용 이미지 정리 시작"
            docker image prune -f
            log_success "미사용 이미지 정리 완료"
            ;;
        3)
            log_info "미사용 볼륨 정리 시작"
            docker volume prune -f
            log_success "미사용 볼륨 정리 완료"
            ;;
        4)
            log_info "미사용 네트워크 정리 시작"
            docker network prune -f
            log_success "미사용 네트워크 정리 완료"
            ;;
        5)
            log_info "Docker 전체 리소스 정리 시작"
            docker system prune -f
            log_success "Docker 전체 리소스 정리 완료"
            ;;
        6)
            log_info "Docker 리소스 정리 취소"
            ;;
        *)
            log_error "잘못된 선택입니다."
            ;;
    esac
}

# View logs
view_logs() {
    log_header "로그 보기"
    
    if [ -f "$LOG_FILE" ]; then
        echo "📋 최근 로그 (마지막 50줄):"
        echo ""
        tail -50 "$LOG_FILE"
        echo ""
        log_info "전체 로그 파일: $LOG_FILE"
    else
        log_warning "로그 파일이 없습니다: $LOG_FILE"
    fi
}

# Main menu
show_menu() {
    clear
    log_header "Cloud Intermediate Advanced Helper"
    echo "1. 🔍 종합 환경 체크"
    echo "2. 📊 Docker 리소스 현황"
    echo "3. 📊 Kubernetes 리소스 현황"
    echo "4. 📊 AWS 컨테이너 서비스 현황"
    echo "5. 📊 GCP 컨테이너 서비스 현황"
    echo "6. 💰 AWS 비용 분석"
    echo "7. 💰 GCP 비용 분석"
    echo "8. 📈 모니터링 스택 설정"
    echo "9. 🚀 Day 1 실습 자동화"
    echo "10. 🚀 Day 2 실습 자동화"
    echo "11. 🧹 AWS 리소스 정리"
    echo "12. 🧹 GCP 리소스 정리"
    echo "13. 🧹 Docker 리소스 정리"
    echo "14. 📋 로그 보기"
    echo "15. 종료"
    echo ""
}

# Main execution function
main() {
    init_log
    
    while true; do
        show_menu
        read -p "선택하세요 (1-15): " choice
        
        case $choice in
            1)
                comprehensive_environment_check
                ;;
            2)
                monitor_docker_resources
                ;;
            3)
                monitor_kubernetes_resources
                ;;
            4)
                monitor_aws_container_services
                ;;
            5)
                monitor_gcp_container_services
                ;;
            6)
                analyze_aws_costs
                ;;
            7)
                analyze_gcp_costs
                ;;
            8)
                setup_monitoring_stack
                ;;
            9)
                day1_practice_automation
                ;;
            10)
                day2_practice_automation
                ;;
            11)
                cleanup_aws_resources
                ;;
            12)
                cleanup_gcp_resources
                ;;
            13)
                cleanup_docker_resources
                ;;
            14)
                view_logs
                ;;
            15)
                log_info "Cloud Intermediate Advanced Helper를 종료합니다."
                exit 0
                ;;
            *)
                log_error "잘못된 선택입니다. 1-15 중에서 선택하세요."
                ;;
        esac
        
        echo ""
        read -p "계속하려면 Enter를 누르세요..."
    done
}

# Script execution
main "$@"
