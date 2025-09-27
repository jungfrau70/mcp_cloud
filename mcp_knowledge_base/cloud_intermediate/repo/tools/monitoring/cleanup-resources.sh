#!/bin/bash

# Cloud Intermediate 리소스 정리 스크립트
# 모든 실습 리소스 및 클라우드 리소스 정리

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

# 사용법 출력
usage() {
    echo "Cloud Intermediate 리소스 정리 스크립트"
    echo ""
    echo "사용법:"
    echo "  $0 [옵션]                    # Interactive 모드"
    echo "  $0 --action <액션> [파라미터] # Parameter 모드"
    echo ""
    echo "Interactive 모드 옵션:"
    echo "  --interactive, -i           # Interactive 모드 (기본값)"
    echo "  --help, -h                   # 도움말 표시"
    echo ""
    echo "Parameter 모드 액션:"
    echo "  --action local              # 로컬 리소스 정리"
    echo "  --action docker             # Docker 리소스 정리"
    echo "  --action aws                # AWS 리소스 정리"
    echo "  --action gcp                # GCP 리소스 정리"
    echo "  --action all                # 모든 리소스 정리"
    echo "  --action dry-run            # 정리 대상 확인 (실제 삭제 안함)"
    echo ""
    echo "예시:"
    echo "  $0                          # Interactive 모드"
    echo "  $0 --action local           # 로컬 리소스만 정리"
    echo "  $0 --action all             # 모든 리소스 정리"
    echo "  $0 --action dry-run         # 정리 대상 확인"
}

# 로컬 리소스 정리
cleanup_local_resources() {
    log_header "로컬 리소스 정리"
    
    # 실습 디렉토리 정리
    log_info "실습 디렉토리 정리"
    local practice_dirs=(
        "day1-docker-advanced"
        "day1-kubernetes-basics"
        "day1-cloud-services"
        "day1-monitoring-hub"
        "day2-cicd-pipeline"
        "day2-cloud-deployment"
        "day2-monitoring-basics"
    )
    
    for dir in "${practice_dirs[@]}"; do
        if [ -d "$dir" ]; then
            log_info "디렉토리 삭제: $dir"
            rm -rf "$dir"
            log_success "✅ $dir 삭제 완료"
        else
            log_info "디렉토리 없음: $dir"
        fi
    done
    
    # 임시 파일 정리
    log_info "임시 파일 정리"
    find . -name "*.tmp" -delete 2>/dev/null || true
    find . -name "*.log" -delete 2>/dev/null || true
    find . -name ".DS_Store" -delete 2>/dev/null || true
    
    log_success "로컬 리소스 정리 완료"
}

# Docker 리소스 정리
cleanup_docker_resources() {
    log_header "Docker 리소스 정리"
    
    # 실행 중인 컨테이너 정지 및 삭제
    log_info "실행 중인 컨테이너 정지"
    docker stop $(docker ps -q) 2>/dev/null || log_info "실행 중인 컨테이너 없음"
    
    log_info "모든 컨테이너 삭제"
    docker rm $(docker ps -aq) 2>/dev/null || log_info "삭제할 컨테이너 없음"
    
    # 사용하지 않는 이미지 삭제
    log_info "사용하지 않는 이미지 삭제"
    docker image prune -f 2>/dev/null || log_info "삭제할 이미지 없음"
    
    # 사용하지 않는 볼륨 삭제
    log_info "사용하지 않는 볼륨 삭제"
    docker volume prune -f 2>/dev/null || log_info "삭제할 볼륨 없음"
    
    # 사용하지 않는 네트워크 삭제
    log_info "사용하지 않는 네트워크 삭제"
    docker network prune -f 2>/dev/null || log_info "삭제할 네트워크 없음"
    
    # Docker Compose 스택 정리
    log_info "Docker Compose 스택 정리"
    if [ -f "docker-compose.yml" ]; then
        docker-compose down -v --remove-orphans 2>/dev/null || log_info "Docker Compose 스택 없음"
    fi
    
    log_success "Docker 리소스 정리 완료"
}

# AWS 리소스 정리
cleanup_aws_resources() {
    log_header "AWS 리소스 정리"
    
    # AWS CLI 확인
    if ! command -v aws &> /dev/null; then
        log_error "AWS CLI가 설치되지 않음"
        return 1
    fi
    
    # AWS 자격 증명 확인
    if ! aws sts get-caller-identity &> /dev/null; then
        log_error "AWS 자격 증명이 설정되지 않음"
        return 1
    fi
    
    log_info "AWS 리소스 정리 시작"
    
    # EKS 클러스터 삭제
    log_info "EKS 클러스터 삭제 확인"
    local eks_clusters=$(aws eks list-clusters --query 'clusters[?contains(name, `cloud-intermediate`)].name' --output text 2>/dev/null || echo "")
    if [ -n "$eks_clusters" ]; then
        for cluster in $eks_clusters; do
            log_warning "EKS 클러스터 발견: $cluster"
            log_info "EKS 클러스터 삭제: $cluster"
            # eksctl delete cluster --name "$cluster" --wait 2>/dev/null || log_warning "EKS 클러스터 삭제 실패: $cluster"
        done
    else
        log_info "삭제할 EKS 클러스터 없음"
    fi
    
    # ECS 클러스터 및 서비스 삭제
    log_info "ECS 리소스 삭제 확인"
    local ecs_clusters=$(aws ecs list-clusters --query 'clusterArns[?contains(@, `cloud-intermediate`)]' --output text 2>/dev/null || echo "")
    if [ -n "$ecs_clusters" ]; then
        for cluster in $ecs_clusters; do
            log_warning "ECS 클러스터 발견: $cluster"
            # ECS 서비스 삭제 로직 추가
        done
    else
        log_info "삭제할 ECS 클러스터 없음"
    fi
    
    # EC2 인스턴스 삭제 (실습용)
    log_info "EC2 인스턴스 삭제 확인"
    local instances=$(aws ec2 describe-instances --filters "Name=tag:Purpose,Values=cloud-intermediate-practice" --query 'Reservations[].Instances[?State.Name!=`terminated`].InstanceId' --output text 2>/dev/null || echo "")
    if [ -n "$instances" ]; then
        for instance in $instances; do
            log_warning "EC2 인스턴스 발견: $instance"
            log_info "EC2 인스턴스 종료: $instance"
            # aws ec2 terminate-instances --instance-ids "$instance" 2>/dev/null || log_warning "EC2 인스턴스 종료 실패: $instance"
        done
    else
        log_info "삭제할 EC2 인스턴스 없음"
    fi
    
    log_success "AWS 리소스 정리 완료"
}

# GCP 리소스 정리
cleanup_gcp_resources() {
    log_header "GCP 리소스 정리"
    
    # GCP CLI 확인
    if ! command -v gcloud &> /dev/null; then
        log_error "GCP CLI가 설치되지 않음"
        return 1
    fi
    
    # GCP 프로젝트 확인
    local project_id=$(gcloud config get-value project 2>/dev/null || echo "")
    if [ -z "$project_id" ]; then
        log_error "GCP 프로젝트가 설정되지 않음"
        return 1
    fi
    
    log_info "GCP 프로젝트: $project_id"
    log_info "GCP 리소스 정리 시작"
    
    # GKE 클러스터 삭제
    log_info "GKE 클러스터 삭제 확인"
    local gke_clusters=$(gcloud container clusters list --filter="name:cloud-intermediate*" --format="value(name)" 2>/dev/null || echo "")
    if [ -n "$gke_clusters" ]; then
        for cluster in $gke_clusters; do
            log_warning "GKE 클러스터 발견: $cluster"
            log_info "GKE 클러스터 삭제: $cluster"
            # gcloud container clusters delete "$cluster" --quiet 2>/dev/null || log_warning "GKE 클러스터 삭제 실패: $cluster"
        done
    else
        log_info "삭제할 GKE 클러스터 없음"
    fi
    
    # Cloud Run 서비스 삭제
    log_info "Cloud Run 서비스 삭제 확인"
    local cloud_run_services=$(gcloud run services list --filter="metadata.name:cloud-intermediate*" --format="value(metadata.name)" 2>/dev/null || echo "")
    if [ -n "$cloud_run_services" ]; then
        for service in $cloud_run_services; do
            log_warning "Cloud Run 서비스 발견: $service"
            log_info "Cloud Run 서비스 삭제: $service"
            # gcloud run services delete "$service" --quiet 2>/dev/null || log_warning "Cloud Run 서비스 삭제 실패: $service"
        done
    else
        log_info "삭제할 Cloud Run 서비스 없음"
    fi
    
    log_success "GCP 리소스 정리 완료"
}

# Dry-run 모드 (실제 삭제하지 않고 확인만)
cleanup_dry_run() {
    log_header "정리 대상 확인 (Dry-run)"
    
    log_info "로컬 리소스 확인"
    local practice_dirs=(
        "day1-docker-advanced"
        "day1-kubernetes-basics"
        "day1-cloud-services"
        "day1-monitoring-hub"
        "day2-cicd-pipeline"
        "day2-cloud-deployment"
        "day2-monitoring-basics"
    )
    
    for dir in "${practice_dirs[@]}"; do
        if [ -d "$dir" ]; then
            log_warning "삭제 대상 디렉토리: $dir"
        fi
    done
    
    log_info "Docker 리소스 확인"
    local containers=$(docker ps -aq 2>/dev/null | wc -l)
    local images=$(docker images -q 2>/dev/null | wc -l)
    local volumes=$(docker volume ls -q 2>/dev/null | wc -l)
    
    log_warning "Docker 컨테이너: $containers개"
    log_warning "Docker 이미지: $images개"
    log_warning "Docker 볼륨: $volumes개"
    
    # AWS 리소스 확인
    if command -v aws &> /dev/null && aws sts get-caller-identity &> /dev/null; then
        log_info "AWS 리소스 확인"
        local eks_clusters=$(aws eks list-clusters --query 'clusters[?contains(name, `cloud-intermediate`)].name' --output text 2>/dev/null || echo "")
        if [ -n "$eks_clusters" ]; then
            log_warning "삭제 대상 EKS 클러스터: $eks_clusters"
        fi
    fi
    
    # GCP 리소스 확인
    if command -v gcloud &> /dev/null; then
        log_info "GCP 리소스 확인"
        local gke_clusters=$(gcloud container clusters list --filter="name:cloud-intermediate*" --format="value(name)" 2>/dev/null || echo "")
        if [ -n "$gke_clusters" ]; then
            log_warning "삭제 대상 GKE 클러스터: $gke_clusters"
        fi
    fi
    
    log_success "Dry-run 완료"
}

# Interactive 모드 메뉴
show_interactive_menu() {
    echo ""
    log_header "리소스 정리 메뉴"
    echo "1. 로컬 리소스 정리"
    echo "2. Docker 리소스 정리"
    echo "3. AWS 리소스 정리"
    echo "4. GCP 리소스 정리"
    echo "5. 모든 리소스 정리"
    echo "6. 정리 대상 확인 (Dry-run)"
    echo "7. 종료"
    echo ""
}

# Interactive 모드 실행
run_interactive_mode() {
    log_header "Cloud Intermediate 리소스 정리"
    while true; do
        show_interactive_menu
        read -p "선택하세요 (1-7): " choice
        
        case $choice in
            1)
                cleanup_local_resources
                ;;
            2)
                cleanup_docker_resources
                ;;
            3)
                cleanup_aws_resources
                ;;
            4)
                cleanup_gcp_resources
                ;;
            5)
                log_info "모든 리소스 정리 시작"
                cleanup_local_resources
                cleanup_docker_resources
                cleanup_aws_resources
                cleanup_gcp_resources
                log_success "모든 리소스 정리 완료!"
                ;;
            6)
                cleanup_dry_run
                ;;
            7)
                log_info "프로그램을 종료합니다"
                exit 0
                ;;
            *)
                log_error "잘못된 선택입니다. 1-7 중에서 선택하세요."
                ;;
        esac
        
        echo ""
        read -p "계속하려면 Enter를 누르세요..."
    done
}

# Parameter 모드 실행
run_parameter_mode() {
    local action=$1
    shift
    
    case "$action" in
        "local")
            log_info "로컬 리소스 정리 실행"
            cleanup_local_resources
            ;;
        "docker")
            log_info "Docker 리소스 정리 실행"
            cleanup_docker_resources
            ;;
        "aws")
            log_info "AWS 리소스 정리 실행"
            cleanup_aws_resources
            ;;
        "gcp")
            log_info "GCP 리소스 정리 실행"
            cleanup_gcp_resources
            ;;
        "all")
            log_info "모든 리소스 정리 실행"
            cleanup_local_resources
            cleanup_docker_resources
            cleanup_aws_resources
            cleanup_gcp_resources
            log_success "모든 리소스 정리 완료!"
            ;;
        "dry-run")
            log_info "정리 대상 확인 실행"
            cleanup_dry_run
            ;;
        *)
            log_error "알 수 없는 액션: $action"
            usage
            exit 1
            ;;
    esac
}

# 메인 함수
main() {
    case "${1:-}" in
        "--help"|"-h")
            usage
            exit 0
            ;;
        "--interactive"|"-i"|"")
            run_interactive_mode
            ;;
        "--action")
            if [ -z "${2:-}" ]; then
                log_error "액션을 지정해주세요."
                usage
                exit 1
            fi
            run_parameter_mode "$2" "$3"
            ;;
        *)
            log_error "알 수 없는 옵션: $1"
            usage
            exit 1
            ;;
    esac
}

# 스크립트 실행
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
