#!/bin/bash

# Cloud Master Advanced Helper Script
# 통합된 Cloud Master 실습 도구 (고도화 버전)

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
LOG_FILE="$PROJECT_ROOT/cloud-master-advanced.log"

# Initialize log file
init_log() {
    echo "=== Cloud Master Advanced Helper Log ===" > "$LOG_FILE"
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

check_docker() {
    log_info "Docker 상태 확인 중..."
    if command -v docker &> /dev/null; then
        DOCKER_VERSION=$(docker --version 2>&1 | cut -d' ' -f3 | cut -d',' -f1)
        log_success "Docker 설치됨: $DOCKER_VERSION"
        
        # Check Docker daemon
        if docker info &> /dev/null; then
            log_success "Docker 데몬 실행 중"
            return 0
        else
            log_error "Docker 데몬 시작 필요"
            return 1
        fi
    else
        log_error "Docker 설치 필요"
        return 1
    fi
}

check_git() {
    log_info "Git 상태 확인 중..."
    if command -v git &> /dev/null; then
        GIT_VERSION=$(git --version 2>&1 | cut -d' ' -f3)
        log_success "Git 설치됨: $GIT_VERSION"
        
        # Check Git configuration
        if git config --global user.name &> /dev/null && git config --global user.email &> /dev/null; then
            GIT_USER=$(git config --global user.name)
            GIT_EMAIL=$(git config --global user.email)
            log_success "Git 설정됨: $GIT_USER <$GIT_EMAIL>"
            return 0
        else
            log_warning "Git 사용자 정보 설정 필요"
            return 1
        fi
    else
        log_error "Git 설치 필요"
        return 1
    fi
}

# Comprehensive environment check
comprehensive_environment_check() {
    log_header "=== 종합 환경 체크 시작 ==="
    
    local checks_passed=0
    local total_checks=4
    
    check_aws_cli && ((checks_passed++))
    check_gcp_cli && ((checks_passed++))
    check_docker && ((checks_passed++))
    check_git && ((checks_passed++))
    
    log_header "=== 환경 체크 결과 ==="
    log_info "통과: $checks_passed/$total_checks"
    
    if [ $checks_passed -eq $total_checks ]; then
        log_success "🎉 모든 환경 체크 통과!"
        return 0
    else
        log_warning "⚠️ 일부 환경 체크 실패. 설정을 확인하세요."
        return 1
    fi
}

# Resource management functions
list_aws_resources() {
    log_header "=== AWS 리소스 현황 ==="
    
    if ! check_aws_cli; then
        return 1
    fi
    
    # EC2 instances
    log_info "EC2 인스턴스 조회 중..."
    aws ec2 describe-instances --query 'Reservations[*].Instances[*].[InstanceId,State.Name,InstanceType,PublicIpAddress,Tags[?Key==`Name`].Value|[0]]' --output table 2>/dev/null || log_warning "EC2 인스턴스 조회 실패"
    
    # Load balancers
    log_info "로드 밸런서 조회 중..."
    aws elbv2 describe-load-balancers --query 'LoadBalancers[*].[LoadBalancerName,State.Code,Type,DNSName]' --output table 2>/dev/null || log_warning "로드 밸런서 조회 실패"
    
    # Auto Scaling Groups
    log_info "Auto Scaling 그룹 조회 중..."
    aws autoscaling describe-auto-scaling-groups --query 'AutoScalingGroups[*].[AutoScalingGroupName,DesiredCapacity,MinSize,MaxSize,Instances[0].InstanceId]' --output table 2>/dev/null || log_warning "Auto Scaling 그룹 조회 실패"
}

list_gcp_resources() {
    log_header "=== GCP 리소스 현황 ==="
    
    if ! check_gcp_cli; then
        return 1
    fi
    
    # Compute instances
    log_info "Compute 인스턴스 조회 중..."
    gcloud compute instances list --format="table(name,zone,status,machineType,externalIP)" 2>/dev/null || log_warning "Compute 인스턴스 조회 실패"
    
    # Load balancers
    log_info "로드 밸런서 조회 중..."
    gcloud compute forwarding-rules list --format="table(name,region,IPAddress,target)" 2>/dev/null || log_warning "로드 밸런서 조회 실패"
    
    # Instance groups
    log_info "인스턴스 그룹 조회 중..."
    gcloud compute instance-groups list --format="table(name,zone,size,template)" 2>/dev/null || log_warning "인스턴스 그룹 조회 실패"
}

list_docker_resources() {
    log_header "=== Docker 리소스 현황 ==="
    
    if ! check_docker; then
        return 1
    fi
    
    # Running containers
    log_info "실행 중인 컨테이너:"
    docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}" 2>/dev/null || log_warning "컨테이너 조회 실패"
    
    # Docker images
    log_info "Docker 이미지:"
    docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}\t{{.CreatedAt}}" 2>/dev/null || log_warning "이미지 조회 실패"
    
    # Docker networks
    log_info "Docker 네트워크:"
    docker network ls --format "table {{.Name}}\t{{.Driver}}\t{{.Scope}}" 2>/dev/null || log_warning "네트워크 조회 실패"
}

# Cost optimization functions
analyze_aws_costs() {
    log_header "=== AWS 비용 분석 ==="
    
    if ! check_aws_cli; then
        return 1
    fi
    
    # Get current month costs (requires Cost Explorer API)
    log_info "AWS 비용 분석 중... (Cost Explorer API 필요)"
    
    # Check for unused resources
    log_info "사용하지 않는 리소스 검색 중..."
    
    # Unused EBS volumes
    log_info "사용하지 않는 EBS 볼륨:"
    aws ec2 describe-volumes --filters "Name=status,Values=available" --query 'Volumes[*].[VolumeId,Size,VolumeType,CreateTime]' --output table 2>/dev/null || log_warning "EBS 볼륨 조회 실패"
    
    # Unused Elastic IPs
    log_info "사용하지 않는 Elastic IP:"
    aws ec2 describe-addresses --query 'Addresses[?InstanceId==null].[PublicIp,AllocationId]' --output table 2>/dev/null || log_warning "Elastic IP 조회 실패"
}

analyze_gcp_costs() {
    log_header "=== GCP 비용 분석 ==="
    
    if ! check_gcp_cli; then
        return 1
    fi
    
    # Get current month costs
    log_info "GCP 비용 분석 중..."
    
    # Check for unused resources
    log_info "사용하지 않는 리소스 검색 중..."
    
    # Unused persistent disks
    log_info "사용하지 않는 영구 디스크:"
    gcloud compute disks list --filter="status:READY AND -users:*" --format="table(name,zone,sizeGb,type)" 2>/dev/null || log_warning "영구 디스크 조회 실패"
    
    # Unused static IPs
    log_info "사용하지 않는 정적 IP:"
    gcloud compute addresses list --filter="status:RESERVED AND -users:*" --format="table(name,region,address)" 2>/dev/null || log_warning "정적 IP 조회 실패"
}

# Monitoring functions
setup_monitoring_stack() {
    log_header "=== 모니터링 스택 설정 ==="
    
    if ! check_docker; then
        return 1
    fi
    
    local monitoring_dir="$PROJECT_ROOT/repo/day3/monitoring-stack"
    
    if [ -d "$monitoring_dir" ]; then
        log_info "모니터링 스택 디렉토리로 이동: $monitoring_dir"
        cd "$monitoring_dir"
        
        # Check for port conflicts
        log_info "포트 충돌 확인 중..."
        local ports=(3000 9090 9093 5601 16686)
        local conflicts=()
        
        for port in "${ports[@]}"; do
            if netstat -tuln 2>/dev/null | grep -q ":$port "; then
                conflicts+=($port)
            fi
        done
        
        if [ ${#conflicts[@]} -gt 0 ]; then
            log_warning "포트 충돌 발견: ${conflicts[*]}"
            log_info "기존 서비스 중지 중..."
            docker-compose down 2>/dev/null || true
        fi
        
        # Start monitoring stack
        log_info "모니터링 스택 시작 중..."
        docker-compose up -d
        
        if [ $? -eq 0 ]; then
            log_success "모니터링 스택 시작 완료"
            log_info "접속 URL:"
            log_info "  - Grafana: http://localhost:3000 (admin/admin)"
            log_info "  - Prometheus: http://localhost:9090"
            log_info "  - Jaeger: http://localhost:16686"
            log_info "  - Kibana: http://localhost:5601"
        else
            log_error "모니터링 스택 시작 실패"
            return 1
        fi
    else
        log_error "모니터링 스택 디렉토리를 찾을 수 없습니다: $monitoring_dir"
        return 1
    fi
}

# Practice automation functions
run_day1_practice() {
    log_header "=== Day 1 실습 실행 ==="
    
    local day1_script="$SCRIPT_DIR/day1-practice-improved.sh"
    
    if [ -f "$day1_script" ]; then
        log_info "Day 1 실습 스크립트 실행: $day1_script"
        chmod +x "$day1_script"
        "$day1_script"
    else
        log_error "Day 1 실습 스크립트를 찾을 수 없습니다: $day1_script"
        return 1
    fi
}

run_day2_practice() {
    log_header "=== Day 2 실습 실행 ==="
    
    local day2_script="$SCRIPT_DIR/cicd-docker-improved.sh"
    
    if [ -f "$day2_script" ]; then
        log_info "Day 2 실습 스크립트 실행: $day2_script"
        chmod +x "$day2_script"
        "$day2_script"
    else
        log_error "Day 2 실습 스크립트를 찾을 수 없습니다: $day2_script"
        return 1
    fi
}

run_day3_practice() {
    log_header "=== Day 3 실습 실행 ==="
    
    local day3_script="$SCRIPT_DIR/aws-loadbalancing-improved.sh"
    
    if [ -f "$day3_script" ]; then
        log_info "Day 3 실습 스크립트 실행: $day3_script"
        chmod +x "$day3_script"
        "$day3_script"
    else
        log_error "Day 3 실습 스크립트를 찾을 수 없습니다: $day3_script"
        return 1
    fi
}

# Cleanup functions
cleanup_aws_resources() {
    log_header "=== AWS 리소스 정리 ==="
    
    if ! check_aws_cli; then
        return 1
    fi
    
    log_warning "AWS 리소스 정리를 시작합니다. 계속하시겠습니까? (y/N)"
    read -r response
    
    if [[ "$response" =~ ^[Yy]$ ]]; then
        log_info "AWS 리소스 정리 중..."
        
        # Terminate all running instances (except those with "keep" tag)
        log_info "실행 중인 EC2 인스턴스 종료 중..."
        aws ec2 describe-instances --filters "Name=instance-state-name,Values=running" --query 'Reservations[*].Instances[?!Tags[?Key==`keep`]].[InstanceId]' --output text | xargs -r aws ec2 terminate-instances --instance-ids 2>/dev/null || log_warning "EC2 인스턴스 종료 실패"
        
        # Delete unused EBS volumes
        log_info "사용하지 않는 EBS 볼륨 삭제 중..."
        aws ec2 describe-volumes --filters "Name=status,Values=available" --query 'Volumes[*].VolumeId' --output text | xargs -r aws ec2 delete-volume --volume-ids 2>/dev/null || log_warning "EBS 볼륨 삭제 실패"
        
        log_success "AWS 리소스 정리 완료"
    else
        log_info "AWS 리소스 정리 취소됨"
    fi
}

cleanup_gcp_resources() {
    log_header "=== GCP 리소스 정리 ==="
    
    if ! check_gcp_cli; then
        return 1
    fi
    
    log_warning "GCP 리소스 정리를 시작합니다. 계속하시겠습니까? (y/N)"
    read -r response
    
    if [[ "$response" =~ ^[Yy]$ ]]; then
        log_info "GCP 리소스 정리 중..."
        
        # Delete all instances (except those with "keep" label)
        log_info "Compute 인스턴스 삭제 중..."
        gcloud compute instances list --filter="NOT labels.keep:*" --format="value(name,zone)" | while read -r name zone; do
            if [ -n "$name" ] && [ -n "$zone" ]; then
                gcloud compute instances delete "$name" --zone="$zone" --quiet 2>/dev/null || log_warning "인스턴스 $name 삭제 실패"
            fi
        done
        
        # Delete unused persistent disks
        log_info "사용하지 않는 영구 디스크 삭제 중..."
        gcloud compute disks list --filter="status:READY AND -users:*" --format="value(name,zone)" | while read -r name zone; do
            if [ -n "$name" ] && [ -n "$zone" ]; then
                gcloud compute disks delete "$name" --zone="$zone" --quiet 2>/dev/null || log_warning "디스크 $name 삭제 실패"
            fi
        done
        
        log_success "GCP 리소스 정리 완료"
    else
        log_info "GCP 리소스 정리 취소됨"
    fi
}

cleanup_docker_resources() {
    log_header "=== Docker 리소스 정리 ==="
    
    if ! check_docker; then
        return 1
    fi
    
    log_warning "Docker 리소스 정리를 시작합니다. 계속하시겠습니까? (y/N)"
    read -r response
    
    if [[ "$response" =~ ^[Yy]$ ]]; then
        log_info "Docker 리소스 정리 중..."
        
        # Stop all containers
        log_info "모든 컨테이너 중지 중..."
        docker stop $(docker ps -q) 2>/dev/null || log_warning "컨테이너 중지 실패"
        
        # Remove all containers
        log_info "모든 컨테이너 삭제 중..."
        docker rm $(docker ps -aq) 2>/dev/null || log_warning "컨테이너 삭제 실패"
        
        # Remove unused images
        log_info "사용하지 않는 이미지 삭제 중..."
        docker image prune -f 2>/dev/null || log_warning "이미지 정리 실패"
        
        # Remove unused volumes
        log_info "사용하지 않는 볼륨 삭제 중..."
        docker volume prune -f 2>/dev/null || log_warning "볼륨 정리 실패"
        
        # Remove unused networks
        log_info "사용하지 않는 네트워크 삭제 중..."
        docker network prune -f 2>/dev/null || log_warning "네트워크 정리 실패"
        
        log_success "Docker 리소스 정리 완료"
    else
        log_info "Docker 리소스 정리 취소됨"
    fi
}

# Main menu
main_menu() {
    while true; do
        clear
        log_header "=== Cloud Master Advanced Helper ==="
        echo -e "${CYAN}현재 시간: $(date)${NC}"
        echo -e "${CYAN}로그 파일: $LOG_FILE${NC}"
        echo ""
        echo "1. 🔍 종합 환경 체크"
        echo "2. 📊 AWS 리소스 현황"
        echo "3. 📊 GCP 리소스 현황"
        echo "4. 📊 Docker 리소스 현황"
        echo "5. 💰 AWS 비용 분석"
        echo "6. 💰 GCP 비용 분석"
        echo "7. 📈 모니터링 스택 설정"
        echo "8. 🚀 Day 1 실습 실행"
        echo "9. 🚀 Day 2 실습 실행"
        echo "10. 🚀 Day 3 실습 실행"
        echo "11. 🧹 AWS 리소스 정리"
        echo "12. 🧹 GCP 리소스 정리"
        echo "13. 🧹 Docker 리소스 정리"
        echo "14. 📋 로그 보기"
        echo "0. 종료"
        echo ""
        read -p "메뉴를 선택하세요 (0-14): " choice
        
        case $choice in
            1) comprehensive_environment_check ;;
            2) list_aws_resources ;;
            3) list_gcp_resources ;;
            4) list_docker_resources ;;
            5) analyze_aws_costs ;;
            6) analyze_gcp_costs ;;
            7) setup_monitoring_stack ;;
            8) run_day1_practice ;;
            9) run_day2_practice ;;
            10) run_day3_practice ;;
            11) cleanup_aws_resources ;;
            12) cleanup_gcp_resources ;;
            13) cleanup_docker_resources ;;
            14) 
                log_info "로그 파일 내용:"
                cat "$LOG_FILE" | tail -50
                ;;
            0) 
                log_info "Cloud Master Advanced Helper를 종료합니다."
                exit 0
                ;;
            *) 
                log_error "잘못된 선택입니다. 다시 시도하세요."
                ;;
        esac
        
        echo ""
        read -p "계속하려면 Enter를 누르세요..."
    done
}

# Initialize and start
init_log
log_header "Cloud Master Advanced Helper 시작"
main_menu
