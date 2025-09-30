#!/bin/bash

# =============================================================================
# Cloud Intermediate 통합 실습 메뉴 시스템 (개선된 버전)
# =============================================================================
# 
# 기능:
#   - 통합강의안 자동화 코드를 사용자에게 호출할 수 있는 메뉴 제공
#   - AWS 및 GCP 인프라 자원배포 (EC2, EKS, GKE) 통합 관리
#   - 서브실행모듈을 통한 클라우드 작업 실행
#   - 환경 파일 기반 설정 관리
#   - 향상된 에러 처리 및 로깅 시스템
#
# 사용법:
#   ./enhanced-cloud-practice-menu.sh                    # Interactive 모드
#   ./enhanced-cloud-practice-menu.sh --day 1            # Day 1 모드
#   ./enhanced-cloud-practice-menu.sh --day 2            # Day 2 모드
#   ./enhanced-cloud-practice-menu.sh --action status    # Direct 실행 모드
#
# 작성일: 2024-12-19
# 작성자: Cloud Intermediate 과정
# =============================================================================

# =============================================================================
# 환경 설정 및 초기화
# =============================================================================
set -euo pipefail

# 공통 환경 설정 로드
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$SCRIPT_DIR/common-environment.env" ]; then
    source "$SCRIPT_DIR/common-environment.env"
else
    echo "ERROR: 공통 환경 설정 파일을 찾을 수 없습니다"
    exit 1
fi

# =============================================================================
# 메뉴 시스템
# =============================================================================
show_main_menu() {
    clear
    log_header "=== Cloud Intermediate 통합 실습 메뉴 ==="
    echo ""
    echo "1. 🐳 Docker 고급 실습"
    echo "2. ☸️  Kubernetes 기초 실습"
    echo "3. ☁️  클라우드 컨테이너 서비스 실습"
    echo "4. 📊 통합 모니터링 허브 구축"
    echo "5. 🔍 클러스터 현황 확인"
    echo "6. 🚀 배포 관리"
    echo "7. ⚙️  클러스터 관리"
    echo "8. 🧹 실습 환경 정리"
    echo "9. 📋 현재 리소스 상태 확인"
    echo "0. 종료"
    echo ""
    echo -n "선택하세요 (0-9): "
}

show_day1_menu() {
    clear
    log_header "=== Day 1: 컨테이너 기초 실습 메뉴 ==="
    echo ""
    echo "1. 🐳 Docker 고급 실습"
    echo "2. ☸️  Kubernetes 기초 실습"
    echo "3. ☁️  클라우드 컨테이너 서비스 실습"
    echo "4. 📊 통합 모니터링 허브 구축"
    echo "5. 🔍 클러스터 현황 확인"
    echo "6. 🧹 실습 환경 정리"
    echo "0. 메인 메뉴로 돌아가기"
    echo ""
    echo -n "선택하세요 (0-6): "
}

show_day2_menu() {
    clear
    log_header "=== Day 2: CI/CD 및 고급 배포 실습 메뉴 ==="
    echo ""
    echo "1. 🔄 GitHub Actions CI/CD 파이프라인"
    echo "2. 📊 멀티 클라우드 통합 모니터링"
    echo "3. 🚀 AWS Application 모니터링"
    echo "4. ☁️  GCP 클러스터 통합 모니터링"
    echo "5. 🔍 배포 상태 확인"
    echo "6. 🧹 실습 환경 정리"
    echo "0. 메인 메뉴로 돌아가기"
    echo ""
    echo -n "선택하세요 (0-6): "
}

# =============================================================================
# 실습 실행 함수
# =============================================================================
run_docker_advanced() {
    log_header "Docker 고급 실습 시작"
    
    local practice_dir="$PROJECT_ROOT/practice/day1/docker-advanced"
    
    if [ ! -d "$practice_dir" ]; then
        handle_error 1 "Docker 고급 실습 디렉토리를 찾을 수 없습니다: $practice_dir" "docker"
    fi
    
    cd "$practice_dir"
    
    # 환경 파일 복사
    log_info "환경 파일 복사 중..."
    cp "$CONFIG_DIR/.env*" ./ 2>/dev/null || log_warning "환경 파일이 없습니다"
    cp "$CONFIG_DIR/docker-compose.yml" ./ 2>/dev/null || log_warning "docker-compose.yml이 없습니다"
    cp "$CONFIG_DIR/Dockerfile*" ./ 2>/dev/null || log_warning "Dockerfile이 없습니다"
    
    # Docker 고급 실습 실행
    if [ -f "./docker-comparison-demo.sh" ]; then
        log_info "Docker 비교 데모 실행 중..."
        chmod +x ./docker-comparison-demo.sh
        ./docker-comparison-demo.sh
        log_success "Docker 고급 실습 완료"
    else
        handle_error 1 "Docker 비교 데모 스크립트를 찾을 수 없습니다" "docker"
    fi
}

run_kubernetes_basics() {
    log_header "Kubernetes 기초 실습 시작"
    
    local practice_dir="$PROJECT_ROOT/practice/day1/kubernetes-basics"
    
    if [ ! -d "$practice_dir" ]; then
        handle_error 1 "Kubernetes 기초 실습 디렉토리를 찾을 수 없습니다: $practice_dir" "kubernetes"
    fi
    
    cd "$practice_dir"
    
    # 환경 파일 복사
    log_info "환경 파일 복사 중..."
    cp "$CONFIG_DIR/kubeconfig*" ./ 2>/dev/null || log_warning "kubeconfig가 없습니다"
    cp "$CONFIG_DIR/.env*" ./ 2>/dev/null || log_warning "환경 파일이 없습니다"
    cp "$CONFIG_DIR/*.yaml" ./ 2>/dev/null || log_warning "YAML 파일이 없습니다"
    
    # Kubernetes 기초 실습 실행
    if [ -f "./kubernetes-basics-helper.sh" ]; then
        log_info "Kubernetes 기초 헬퍼 실행 중..."
        chmod +x ./kubernetes-basics-helper.sh
        ./kubernetes-basics-helper.sh
        log_success "Kubernetes 기초 실습 완료"
    else
        handle_error 1 "Kubernetes 기초 헬퍼 스크립트를 찾을 수 없습니다" "kubernetes"
    fi
}

run_cloud_container_services() {
    log_header "클라우드 컨테이너 서비스 실습 시작"
    
    local practice_dir="$PROJECT_ROOT/practice/day1/cloud-container-services"
    
    if [ ! -d "$practice_dir" ]; then
        handle_error 1 "클라우드 컨테이너 서비스 실습 디렉토리를 찾을 수 없습니다: $practice_dir" "cloud"
    fi
    
    cd "$practice_dir"
    
    # 환경 파일 복사
    log_info "환경 파일 복사 중..."
    cp "$CONFIG_DIR/aws-config" ./ 2>/dev/null || log_warning "AWS 설정이 없습니다"
    cp "$CONFIG_DIR/gcp-config" ./ 2>/dev/null || log_warning "GCP 설정이 없습니다"
    cp "$CONFIG_DIR/*.yaml" ./ 2>/dev/null || log_warning "YAML 파일이 없습니다"
    
    # AWS ECS 실습
    if [ -f "./aws-ecs-helper.sh" ]; then
        log_info "AWS ECS 헬퍼 실행 중..."
        chmod +x ./aws-ecs-helper.sh
        ./aws-ecs-helper.sh
    fi
    
    # GCP Cloud Run 실습
    if [ -f "./gcp-cloud-run-helper.sh" ]; then
        log_info "GCP Cloud Run 헬퍼 실행 중..."
        chmod +x ./gcp-cloud-run-helper.sh
        ./gcp-cloud-run-helper.sh
    fi
    
    log_success "클라우드 컨테이너 서비스 실습 완료"
}

run_monitoring_hub() {
    log_header "통합 모니터링 허브 구축 시작"
    
    local practice_dir="$PROJECT_ROOT/practice/day1/monitoring-hub"
    
    if [ ! -d "$practice_dir" ]; then
        handle_error 1 "모니터링 허브 실습 디렉토리를 찾을 수 없습니다: $practice_dir" "monitoring"
    fi
    
    cd "$practice_dir"
    
    # 환경 파일 복사
    log_info "환경 파일 복사 중..."
    cp "$CONFIG_DIR/prometheus.yml" ./ 2>/dev/null || log_warning "Prometheus 설정이 없습니다"
    cp -r "$CONFIG_DIR/grafana/" ./ 2>/dev/null || log_warning "Grafana 설정이 없습니다"
    cp "$CONFIG_DIR/docker-compose.yml" ./ 2>/dev/null || log_warning "docker-compose.yml이 없습니다"
    
    # 모니터링 허브 구축
    if [ -f "./monitoring-hub-helper.sh" ]; then
        log_info "모니터링 허브 헬퍼 실행 중..."
        chmod +x ./monitoring-hub-helper.sh
        ./monitoring-hub-helper.sh
        log_success "통합 모니터링 허브 구축 완료"
    else
        handle_error 1 "모니터링 허브 헬퍼 스크립트를 찾을 수 없습니다" "monitoring"
    fi
}

run_cicd_pipeline() {
    log_header "GitHub Actions CI/CD 파이프라인 실습 시작"
    
    local practice_dir="$PROJECT_ROOT/practice/day2/cicd-pipeline"
    
    if [ ! -d "$practice_dir" ]; then
        handle_error 1 "CI/CD 파이프라인 실습 디렉토리를 찾을 수 없습니다: $practice_dir" "cicd"
    fi
    
    cd "$practice_dir"
    
    # CI/CD 파이프라인 헬퍼 실행
    if [ -f "./cicd-pipeline-helper.sh" ]; then
        log_info "CI/CD 파이프라인 헬퍼 실행 중..."
        chmod +x ./cicd-pipeline-helper.sh
        ./cicd-pipeline-helper.sh
        log_success "CI/CD 파이프라인 실습 완료"
    else
        handle_error 1 "CI/CD 파이프라인 헬퍼 스크립트를 찾을 수 없습니다" "cicd"
    fi
}

run_advanced_monitoring() {
    log_header "멀티 클라우드 통합 모니터링 실습 시작"
    
    local practice_dir="$PROJECT_ROOT/practice/day2/advanced-monitoring"
    
    if [ ! -d "$practice_dir" ]; then
        handle_error 1 "고급 모니터링 실습 디렉토리를 찾을 수 없습니다: $practice_dir" "monitoring"
    fi
    
    cd "$practice_dir"
    
    # 고급 모니터링 헬퍼 실행
    if [ -f "./monitoring-helper.sh" ]; then
        log_info "고급 모니터링 헬퍼 실행 중..."
        chmod +x ./monitoring-helper.sh
        ./monitoring-helper.sh
        log_success "멀티 클라우드 통합 모니터링 실습 완료"
    else
        handle_error 1 "고급 모니터링 헬퍼 스크립트를 찾을 수 없습니다" "monitoring"
    fi
}

# =============================================================================
# 상태 확인 함수
# =============================================================================
check_cluster_status() {
    log_header "클러스터 현황 확인"
    
    # Docker 상태 확인
    log_info "Docker 상태 확인 중..."
    if docker info &> /dev/null; then
        log_success "Docker 실행 중"
        docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
    else
        log_warning "Docker가 실행되지 않음"
    fi
    
    # Kubernetes 클러스터 상태 확인
    log_info "Kubernetes 클러스터 상태 확인 중..."
    if kubectl cluster-info &> /dev/null; then
        log_success "Kubernetes 클러스터 연결됨"
        kubectl get nodes
        kubectl get pods --all-namespaces
    else
        log_warning "Kubernetes 클러스터에 연결할 수 없음"
    fi
    
    # AWS 상태 확인
    log_info "AWS 상태 확인 중..."
    if aws sts get-caller-identity &> /dev/null; then
        log_success "AWS 연결됨"
        aws ec2 describe-instances --query 'Reservations[*].Instances[*].[InstanceId,State.Name,PublicIpAddress]' --output table
    else
        log_warning "AWS에 연결할 수 없음"
    fi
    
    # GCP 상태 확인
    log_info "GCP 상태 확인 중..."
    if gcloud auth list --filter=status:ACTIVE --format="value(account)" | grep -q .; then
        log_success "GCP 연결됨"
        gcloud compute instances list
    else
        log_warning "GCP에 연결할 수 없음"
    fi
}

check_deployment_status() {
    log_header "배포 상태 확인"
    
    # GitHub Actions 상태 확인
    log_info "GitHub Actions 상태 확인 중..."
    if command -v gh &> /dev/null; then
        gh run list --limit 5
    else
        log_warning "GitHub CLI가 설치되지 않음"
    fi
    
    # Docker 이미지 상태 확인
    log_info "Docker 이미지 상태 확인 중..."
    docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}\t{{.CreatedAt}}"
    
    # Kubernetes 배포 상태 확인
    log_info "Kubernetes 배포 상태 확인 중..."
    if kubectl cluster-info &> /dev/null; then
        kubectl get deployments
        kubectl get services
    else
        log_warning "Kubernetes 클러스터에 연결할 수 없음"
    fi
}

# =============================================================================
# 정리 함수
# =============================================================================
cleanup_environment() {
    log_header "실습 환경 정리 시작"
    
    # Docker 정리
    log_info "Docker 리소스 정리 중..."
    docker system prune -f || log_warning "Docker 정리 실패"
    
    # Kubernetes 리소스 정리
    log_info "Kubernetes 리소스 정리 중..."
    if kubectl cluster-info &> /dev/null; then
        kubectl delete --all pods --grace-period=0 --force || log_warning "Kubernetes 정리 실패"
    fi
    
    # AWS 리소스 정리 (선택적)
    read -p "AWS 리소스를 정리하시겠습니까? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        log_info "AWS 리소스 정리 중..."
        # AWS 리소스 정리 로직
    fi
    
    # GCP 리소스 정리 (선택적)
    read -p "GCP 리소스를 정리하시겠습니까? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        log_info "GCP 리소스 정리 중..."
        # GCP 리소스 정리 로직
    fi
    
    log_success "실습 환경 정리 완료"
}

# =============================================================================
# 메인 실행 로직
# =============================================================================
main() {
    # 명령행 인수 처리
    case "${1:-}" in
        --day)
            case "${2:-}" in
                1) run_day1_menu ;;
                2) run_day2_menu ;;
                *) log_error "잘못된 Day 번호: $2" ;;
            esac
            ;;
        --action)
            case "${2:-}" in
                status) check_cluster_status ;;
                cleanup) cleanup_environment ;;
                *) log_error "잘못된 액션: $2" ;;
            esac
            ;;
        --help|-h)
            echo "사용법: $0 [--day 1|2] [--action status|cleanup]"
            exit 0
            ;;
        "")
            run_main_menu
            ;;
        *)
            log_error "알 수 없는 옵션: $1"
            exit 1
            ;;
    esac
}

run_main_menu() {
    while true; do
        show_main_menu
        read -r choice
        
        case $choice in
            1) run_docker_advanced ;;
            2) run_kubernetes_basics ;;
            3) run_cloud_container_services ;;
            4) run_monitoring_hub ;;
            5) check_cluster_status ;;
            6) log_info "배포 관리 기능은 Day 2에서 제공됩니다" ;;
            7) log_info "클러스터 관리 기능은 Day 2에서 제공됩니다" ;;
            8) cleanup_environment ;;
            9) check_cluster_status ;;
            0) 
                log_info "프로그램을 종료합니다"
                exit 0
                ;;
            *)
                log_error "잘못된 선택입니다. 다시 선택해주세요."
                ;;
        esac
        
        echo ""
        read -p "계속하려면 Enter를 누르세요..."
    done
}

run_day1_menu() {
    while true; do
        show_day1_menu
        read -r choice
        
        case $choice in
            1) run_docker_advanced ;;
            2) run_kubernetes_basics ;;
            3) run_cloud_container_services ;;
            4) run_monitoring_hub ;;
            5) check_cluster_status ;;
            6) cleanup_environment ;;
            0) run_main_menu ;;
            *)
                log_error "잘못된 선택입니다. 다시 선택해주세요."
                ;;
        esac
        
        echo ""
        read -p "계속하려면 Enter를 누르세요..."
    done
}

run_day2_menu() {
    while true; do
        show_day2_menu
        read -r choice
        
        case $choice in
            1) run_cicd_pipeline ;;
            2) run_advanced_monitoring ;;
            3) log_info "AWS Application 모니터링 실습" ;;
            4) log_info "GCP 클러스터 통합 모니터링 실습" ;;
            5) check_deployment_status ;;
            6) cleanup_environment ;;
            0) run_main_menu ;;
            *)
                log_error "잘못된 선택입니다. 다시 선택해주세요."
                ;;
        esac
        
        echo ""
        read -p "계속하려면 Enter를 누르세요..."
    done
}

# =============================================================================
# 스크립트 실행
# =============================================================================
main "$@"
