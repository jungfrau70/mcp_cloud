#!/bin/bash

# 통합 삭제 스크립트
# Day1 실습에서 생성된 모든 리소스를 자동으로 정리

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

# Docker 컨테이너 정리
cleanup_docker_containers() {
    log_header "Docker 컨테이너 정리"
    
    # 모든 실습 관련 컨테이너 중지 및 삭제
    containers=(
        "test-app"
        "test-app-gcp"
        "prometheus"
        "grafana"
        "node-exporter"
        "alertmanager"
        "pushgateway"
        "aws-ecs-exporter"
        "gcp-cloud-run-exporter"
    )
    
    for container in "${containers[@]}"; do
        if docker ps -a --format "table {{.Names}}" | grep -q "^${container}$"; then
            log_info "컨테이너 $container 중지 및 삭제 중..."
            docker stop "$container" 2>/dev/null || true
            docker rm "$container" 2>/dev/null || true
            log_success "컨테이너 $container 정리 완료"
        else
            log_info "컨테이너 $container가 존재하지 않습니다"
        fi
    done
    
    # 실행 중인 모든 컨테이너 확인
    running_containers=$(docker ps -q)
    if [ -n "$running_containers" ]; then
        log_warning "아직 실행 중인 컨테이너가 있습니다:"
        docker ps --format "table {{.Names}}\t{{.Status}}"
    else
        log_success "모든 컨테이너가 정리되었습니다"
    fi
}

# Docker 이미지 정리
cleanup_docker_images() {
    log_header "Docker 이미지 정리"
    
    # 실습에서 생성된 이미지 삭제
    images=(
        "cloud-intermediate-app:test"
        "cloud-intermediate-app-gcp:test"
    )
    
    for image in "${images[@]}"; do
        if docker images --format "table {{.Repository}}:{{.Tag}}" | grep -q "^${image}$"; then
            log_info "이미지 $image 삭제 중..."
            docker rmi "$image" 2>/dev/null || true
            log_success "이미지 $image 삭제 완료"
        else
            log_info "이미지 $image가 존재하지 않습니다"
        fi
    done
    
    # 사용하지 않는 이미지 정리
    log_info "사용하지 않는 이미지 정리 중..."
    docker image prune -f
    log_success "사용하지 않는 이미지 정리 완료"
}

# Docker 네트워크 정리
cleanup_docker_networks() {
    log_header "Docker 네트워크 정리"
    
    # 실습에서 생성된 네트워크 삭제
    networks=(
        "monitoring"
        "day1-practice"
    )
    
    for network in "${networks[@]}"; do
        if docker network ls --format "table {{.Name}}" | grep -q "^${network}$"; then
            log_info "네트워크 $network 삭제 중..."
            docker network rm "$network" 2>/dev/null || true
            log_success "네트워크 $network 삭제 완료"
        else
            log_info "네트워크 $network가 존재하지 않습니다"
        fi
    done
    
    # 사용하지 않는 네트워크 정리
    log_info "사용하지 않는 네트워크 정리 중..."
    docker network prune -f
    log_success "사용하지 않는 네트워크 정리 완료"
}

# Docker 볼륨 정리
cleanup_docker_volumes() {
    log_header "Docker 볼륨 정리"
    
    # 실습에서 생성된 볼륨 삭제
    volumes=(
        "prometheus_data"
        "grafana_data"
        "alertmanager_data"
    )
    
    for volume in "${volumes[@]}"; do
        if docker volume ls --format "table {{.Name}}" | grep -q "^${volume}$"; then
            log_info "볼륨 $volume 삭제 중..."
            docker volume rm "$volume" 2>/dev/null || true
            log_success "볼륨 $volume 삭제 완료"
        else
            log_info "볼륨 $volume이 존재하지 않습니다"
        fi
    done
    
    # 사용하지 않는 볼륨 정리
    log_info "사용하지 않는 볼륨 정리 중..."
    docker volume prune -f
    log_success "사용하지 않는 볼륨 정리 완료"
}

# Kubernetes 리소스 정리
cleanup_kubernetes_resources() {
    log_header "Kubernetes 리소스 정리"
    
    if command -v kubectl &> /dev/null; then
        # day1-practice 네임스페이스의 모든 리소스 삭제
        if kubectl get namespace day1-practice &> /dev/null; then
            log_info "day1-practice 네임스페이스 리소스 삭제 중..."
            kubectl delete all --all -n day1-practice 2>/dev/null || true
            kubectl delete namespace day1-practice 2>/dev/null || true
            log_success "Kubernetes 리소스 정리 완료"
        else
            log_info "day1-practice 네임스페이스가 존재하지 않습니다"
        fi
    else
        log_warning "kubectl이 설치되지 않았습니다. Kubernetes 리소스 정리를 건너뜁니다."
    fi
}

# 설정 파일 정리
cleanup_config_files() {
    log_header "설정 파일 정리"
    
    # 실습에서 생성된 설정 파일 삭제
    config_dirs=(
        "prometheus"
        "grafana"
        "alertmanager"
        "aws-ecs-exporter"
        "gcp-cloud-run-exporter"
    )
    
    for dir in "${config_dirs[@]}"; do
        if [ -d "$dir" ]; then
            log_info "설정 디렉토리 $dir 삭제 중..."
            rm -rf "$dir"
            log_success "설정 디렉토리 $dir 삭제 완료"
        else
            log_info "설정 디렉토리 $dir이 존재하지 않습니다"
        fi
    done
    
    # Docker Compose 파일 정리
    compose_files=(
        "docker-compose.yml"
        "docker-compose-simple.yml"
    )
    
    for file in "${compose_files[@]}"; do
        if [ -f "$file" ]; then
            log_info "Docker Compose 파일 $file 삭제 중..."
            rm -f "$file"
            log_success "Docker Compose 파일 $file 삭제 완료"
        else
            log_info "Docker Compose 파일 $file이 존재하지 않습니다"
        fi
    done
}

# 클라우드 리소스 정리
cleanup_cloud_resources() {
    log_header "클라우드 리소스 정리"
    
    # AWS 리소스 정리
    if command -v aws &> /dev/null; then
        log_info "AWS 리소스 정리 중..."
        
        # ECS 클러스터 정리
        if aws ecs list-clusters --query 'clusterArns[?contains(@, `day1-practice`)]' --output text 2>/dev/null | grep -q "day1-practice"; then
            log_info "ECS 클러스터 day1-practice 삭제 중..."
            aws ecs delete-cluster --cluster day1-practice 2>/dev/null || true
            log_success "ECS 클러스터 정리 완료"
        fi
        
        # EKS 클러스터 정리 (주의: 실제 클러스터 삭제)
        log_warning "EKS 클러스터는 수동으로 삭제해야 합니다"
    else
        log_warning "AWS CLI가 설치되지 않았습니다. AWS 리소스 정리를 건너뜁니다."
    fi
    
    # GCP 리소스 정리
    if command -v gcloud &> /dev/null; then
        log_info "GCP 리소스 정리 중..."
        
        # Cloud Run 서비스 정리
        if gcloud run services list --filter="metadata.name:day1-practice" --format="value(metadata.name)" 2>/dev/null | grep -q "day1-practice"; then
            log_info "Cloud Run 서비스 day1-practice 삭제 중..."
            gcloud run services delete day1-practice --quiet 2>/dev/null || true
            log_success "Cloud Run 서비스 정리 완료"
        fi
        
        # GKE 클러스터 정리 (주의: 실제 클러스터 삭제)
        log_warning "GKE 클러스터는 수동으로 삭제해야 합니다"
    else
        log_warning "Google Cloud CLI가 설치되지 않았습니다. GCP 리소스 정리를 건너뜁니다."
    fi
}

# 시스템 정리
cleanup_system() {
    log_header "시스템 정리"
    
    # 임시 파일 정리
    log_info "임시 파일 정리 중..."
    rm -rf /tmp/day1-practice-* 2>/dev/null || true
    rm -rf /tmp/cloud-intermediate-* 2>/dev/null || true
    
    # 로그 파일 정리
    log_info "로그 파일 정리 중..."
    rm -rf /var/log/day1-practice-* 2>/dev/null || true
    
    log_success "시스템 정리 완료"
}

# 정리 결과 확인
verify_cleanup() {
    log_header "정리 결과 확인"
    
    # Docker 리소스 확인
    log_info "Docker 리소스 상태:"
    echo "  - 컨테이너: $(docker ps -q | wc -l)개 실행 중"
    echo "  - 이미지: $(docker images -q | wc -l)개 존재"
    echo "  - 네트워크: $(docker network ls -q | wc -l)개 존재"
    echo "  - 볼륨: $(docker volume ls -q | wc -l)개 존재"
    
    # Kubernetes 리소스 확인
    if command -v kubectl &> /dev/null; then
        log_info "Kubernetes 리소스 상태:"
        echo "  - 네임스페이스: $(kubectl get namespaces --no-headers | wc -l)개 존재"
        echo "  - Pod: $(kubectl get pods --all-namespaces --no-headers | wc -l)개 존재"
    fi
    
    log_success "정리 결과 확인 완료"
}

# 메인 실행 함수
main() {
    log_header "Day1 실습 통합 삭제 시작"
    
    # 사용자 확인
    echo ""
    log_warning "이 작업은 Day1 실습에서 생성된 모든 리소스를 삭제합니다."
    read -p "계속하시겠습니까? (y/N): " confirm
    
    if [[ $confirm != [yY] ]]; then
        log_info "삭제 작업이 취소되었습니다."
        exit 0
    fi
    
    # 정리 작업 실행
    cleanup_docker_containers
    cleanup_docker_images
    cleanup_docker_networks
    cleanup_docker_volumes
    cleanup_kubernetes_resources
    cleanup_config_files
    cleanup_cloud_resources
    cleanup_system
    
    # 정리 결과 확인
    verify_cleanup
    
    log_success "Day1 실습 통합 삭제 완료!"
    echo ""
    log_info "정리된 리소스:"
    echo "  ✅ Docker 컨테이너, 이미지, 네트워크, 볼륨"
    echo "  ✅ Kubernetes 리소스"
    echo "  ✅ 설정 파일 및 로그"
    echo "  ✅ 클라우드 리소스 (일부)"
    echo ""
    log_warning "주의: EKS/GKE 클러스터는 수동으로 삭제해야 합니다."
}

# 스크립트 실행
main "$@"
