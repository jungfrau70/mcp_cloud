#!/bin/bash

# Cloud Intermediate 리소스 관리 유틸리티
# 기존 리소스 존재 시 스마트 처리

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

# 디렉토리 스마트 생성
smart_mkdir() {
    local dir_path="$1"
    local force_clean="${2:-false}"
    
    if [ -d "$dir_path" ]; then
        if [ "$force_clean" = "true" ]; then
            log_warning "기존 디렉토리 발견: $dir_path"
            log_info "기존 디렉토리 정리 중..."
            rm -rf "$dir_path"
            mkdir -p "$dir_path"
            log_success "디렉토리 재생성 완료: $dir_path"
        else
            log_info "기존 디렉토리 사용: $dir_path"
        fi
    else
        mkdir -p "$dir_path"
        log_success "새 디렉토리 생성: $dir_path"
    fi
}

# Docker 컨테이너 스마트 실행
smart_docker_run() {
    local container_name="$1"
    local image_name="$2"
    local run_options="$3"
    
    # 기존 컨테이너 확인
    if docker ps -a --format "table {{.Names}}" | grep -q "^${container_name}$"; then
        log_warning "기존 컨테이너 발견: $container_name"
        
        # 실행 중인 컨테이너인지 확인
        if docker ps --format "table {{.Names}}" | grep -q "^${container_name}$"; then
            log_info "실행 중인 컨테이너 사용: $container_name"
            return 0
        else
            log_info "중지된 컨테이너 재시작: $container_name"
            docker start "$container_name"
            return $?
        fi
    else
        log_info "새 컨테이너 생성: $container_name"
        docker run -d --name "$container_name" $run_options "$image_name"
        return $?
    fi
}

# Docker Compose 스마트 실행
smart_docker_compose_up() {
    local compose_file="${1:-docker-compose.yml}"
    local force_recreate="${2:-false}"
    
    if [ ! -f "$compose_file" ]; then
        log_error "Docker Compose 파일 없음: $compose_file"
        return 1
    fi
    
    # 기존 서비스 확인
    if docker-compose ps -q | grep -q .; then
        log_warning "기존 Docker Compose 서비스 발견"
        
        if [ "$force_recreate" = "true" ]; then
            log_info "기존 서비스 정리 후 재시작"
            docker-compose down -v
            docker-compose up -d
        else
            log_info "기존 서비스 상태 확인"
            if docker-compose ps | grep -q "Up"; then
                log_success "서비스가 이미 실행 중"
                return 0
            else
                log_info "서비스 재시작"
                docker-compose up -d
            fi
        fi
    else
        log_info "새 Docker Compose 서비스 시작"
        docker-compose up -d
    fi
    
    return $?
}

# Kubernetes 리소스 스마트 적용
smart_kubectl_apply() {
    local manifest_file="$1"
    local namespace="${2:-default}"
    
    if [ ! -f "$manifest_file" ]; then
        log_error "매니페스트 파일 없음: $manifest_file"
        return 1
    fi
    
    # 네임스페이스 확인
    if ! kubectl get namespace "$namespace" >/dev/null 2>&1; then
        log_info "네임스페이스 생성: $namespace"
        kubectl create namespace "$namespace"
    fi
    
    # 리소스 적용
    log_info "Kubernetes 리소스 적용: $manifest_file"
    kubectl apply -f "$manifest_file" -n "$namespace"
    
    return $?
}

# AWS 리소스 스마트 생성
smart_aws_resource() {
    local resource_type="$1"
    local resource_name="$2"
    local create_command="$3"
    
    # 기존 리소스 확인
    case "$resource_type" in
        "ecs-cluster")
            if aws ecs describe-clusters --clusters "$resource_name" >/dev/null 2>&1; then
                log_info "기존 ECS 클러스터 사용: $resource_name"
                return 0
            fi
            ;;
        "eks-cluster")
            if aws eks describe-cluster --name "$resource_name" >/dev/null 2>&1; then
                log_info "기존 EKS 클러스터 사용: $resource_name"
                return 0
            fi
            ;;
        "ec2-instance")
            local instance_id=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=$resource_name" "Name=instance-state-name,Values=running" --query 'Reservations[].Instances[].InstanceId' --output text 2>/dev/null)
            if [ -n "$instance_id" ]; then
                log_info "기존 EC2 인스턴스 사용: $instance_id"
                return 0
            fi
            ;;
    esac
    
    # 새 리소스 생성
    log_info "새 $resource_type 생성: $resource_name"
    eval "$create_command"
    return $?
}

# GCP 리소스 스마트 생성
smart_gcp_resource() {
    local resource_type="$1"
    local resource_name="$2"
    local create_command="$3"
    
    # 기존 리소스 확인
    case "$resource_type" in
        "gke-cluster")
            if gcloud container clusters describe "$resource_name" >/dev/null 2>&1; then
                log_info "기존 GKE 클러스터 사용: $resource_name"
                return 0
            fi
            ;;
        "cloud-run-service")
            if gcloud run services describe "$resource_name" >/dev/null 2>&1; then
                log_info "기존 Cloud Run 서비스 사용: $resource_name"
                return 0
            fi
            ;;
    esac
    
    # 새 리소스 생성
    log_info "새 $resource_type 생성: $resource_name"
    eval "$create_command"
    return $?
}

# 리소스 상태 확인
check_resource_status() {
    local resource_type="$1"
    local resource_name="$2"
    
    case "$resource_type" in
        "docker-container")
            if docker ps --format "table {{.Names}}" | grep -q "^${resource_name}$"; then
                log_success "Docker 컨테이너 실행 중: $resource_name"
                return 0
            else
                log_warning "Docker 컨테이너 중지됨: $resource_name"
                return 1
            fi
            ;;
        "docker-compose")
            if docker-compose ps | grep -q "Up"; then
                log_success "Docker Compose 서비스 실행 중"
                return 0
            else
                log_warning "Docker Compose 서비스 중지됨"
                return 1
            fi
            ;;
        "k8s-pod")
            if kubectl get pod "$resource_name" >/dev/null 2>&1; then
                log_success "Kubernetes Pod 존재: $resource_name"
                return 0
            else
                log_warning "Kubernetes Pod 없음: $resource_name"
                return 1
            fi
            ;;
    esac
}

# 리소스 정리 (선택적)
cleanup_resource() {
    local resource_type="$1"
    local resource_name="$2"
    local force="${3:-false}"
    
    if [ "$force" = "true" ]; then
        case "$resource_type" in
            "docker-container")
                docker stop "$resource_name" 2>/dev/null || true
                docker rm "$resource_name" 2>/dev/null || true
                log_info "Docker 컨테이너 정리: $resource_name"
                ;;
            "docker-compose")
                docker-compose down -v 2>/dev/null || true
                log_info "Docker Compose 서비스 정리"
                ;;
            "k8s-resource")
                kubectl delete -f "$resource_name" 2>/dev/null || true
                log_info "Kubernetes 리소스 정리: $resource_name"
                ;;
        esac
    else
        log_info "리소스 정리 건너뜀: $resource_name"
    fi
}

# 사용법 출력
usage() {
    echo "Cloud Intermediate 리소스 관리 유틸리티"
    echo ""
    echo "사용법:"
    echo "  source resource-manager.sh"
    echo ""
    echo "주요 함수:"
    echo "  smart_mkdir <디렉토리> [force_clean]"
    echo "  smart_docker_run <컨테이너명> <이미지명> <옵션>"
    echo "  smart_docker_compose_up [compose_file] [force_recreate]"
    echo "  smart_kubectl_apply <매니페스트> [네임스페이스]"
    echo "  smart_aws_resource <리소스타입> <리소스명> <생성명령>"
    echo "  smart_gcp_resource <리소스타입> <리소스명> <생성명령>"
    echo "  check_resource_status <리소스타입> <리소스명>"
    echo "  cleanup_resource <리소스타입> <리소스명> [force]"
}

# 스크립트가 직접 실행되지 않았을 때만 함수들을 export
if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
    export -f smart_mkdir
    export -f smart_docker_run
    export -f smart_docker_compose_up
    export -f smart_kubectl_apply
    export -f smart_aws_resource
    export -f smart_gcp_resource
    export -f check_resource_status
    export -f cleanup_resource
fi
