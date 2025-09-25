#!/bin/bash

# Cloud Basic Helper Script
# 통합된 Cloud Basic 실습 도구

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
AUTOMATION_DIR="$PROJECT_ROOT/repo/automation"
AUTOMATION_TESTS_DIR="$PROJECT_ROOT/repo/automation_tests"

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

check_python() {
    log_info "Python 상태 확인 중..."
    if command -v python3 &> /dev/null; then
        PYTHON_VERSION=$(python3 --version 2>&1 | cut -d' ' -f2)
        log_success "Python3 설치됨: $PYTHON_VERSION"
        return 0
    elif command -v python &> /dev/null; then
        PYTHON_VERSION=$(python --version 2>&1 | cut -d' ' -f2)
        log_success "Python 설치됨: $PYTHON_VERSION"
        return 0
    else
        log_error "Python 설치 필요"
        return 1
    fi
}

# Comprehensive environment check
comprehensive_environment_check() {
    log_header "=== Cloud Basic 환경 체크 시작 ==="
    
    local checks_passed=0
    local total_checks=3
    
    check_aws_cli && ((checks_passed++))
    check_gcp_cli && ((checks_passed++))
    check_python && ((checks_passed++))
    
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

# Day 1 practice functions
run_day1_cloud_basics() {
    log_header "=== Day 1: 클라우드 기초 실습 ==="
    
    local script_path="$AUTOMATION_DIR/day1/cloud_basics.sh"
    
    if [ -f "$script_path" ]; then
        log_info "클라우드 기초 실습 스크립트 실행: $script_path"
        chmod +x "$script_path"
        cd "$(dirname "$script_path")"
        ./cloud_basics.sh
    else
        log_error "클라우드 기초 실습 스크립트를 찾을 수 없습니다: $script_path"
        return 1
    fi
}

run_day1_iam_basics() {
    log_header "=== Day 1: IAM 기초 실습 ==="
    
    local script_path="$AUTOMATION_DIR/day1/iam_basics.sh"
    
    if [ -f "$script_path" ]; then
        log_info "IAM 기초 실습 스크립트 실행: $script_path"
        chmod +x "$script_path"
        cd "$(dirname "$script_path")"
        ./iam_basics.sh
    else
        log_error "IAM 기초 실습 스크립트를 찾을 수 없습니다: $script_path"
        return 1
    fi
}

run_day1_vm_services() {
    log_header "=== Day 1: VM 서비스 실습 ==="
    
    local script_path="$AUTOMATION_DIR/day1/vm_services.sh"
    
    if [ -f "$script_path" ]; then
        log_info "VM 서비스 실습 스크립트 실행: $script_path"
        chmod +x "$script_path"
        cd "$(dirname "$script_path")"
        ./vm_services.sh
    else
        log_error "VM 서비스 실습 스크립트를 찾을 수 없습니다: $script_path"
        return 1
    fi
}

run_day1_storage_services() {
    log_header "=== Day 1: 스토리지 서비스 실습 ==="
    
    local script_path="$AUTOMATION_DIR/day1/storage_services.sh"
    
    if [ -f "$script_path" ]; then
        log_info "스토리지 서비스 실습 스크립트 실행: $script_path"
        chmod +x "$script_path"
        cd "$(dirname "$script_path")"
        ./storage_services.sh
    else
        log_error "스토리지 서비스 실습 스크립트를 찾을 수 없습니다: $script_path"
        return 1
    fi
}

# Day 2 practice functions
run_day2_networking_basics() {
    log_header "=== Day 2: 네트워킹 기초 실습 ==="
    
    local script_path="$AUTOMATION_DIR/day2/networking_basics.sh"
    
    if [ -f "$script_path" ]; then
        log_info "네트워킹 기초 실습 스크립트 실행: $script_path"
        chmod +x "$script_path"
        cd "$(dirname "$script_path")"
        ./networking_basics.sh
    else
        log_error "네트워킹 기초 실습 스크립트를 찾을 수 없습니다: $script_path"
        return 1
    fi
}

run_day2_security_basics() {
    log_header "=== Day 2: 보안 기초 실습 ==="
    
    local script_path="$AUTOMATION_DIR/day2/security_basics.sh"
    
    if [ -f "$script_path" ]; then
        log_info "보안 기초 실습 스크립트 실행: $script_path"
        chmod +x "$script_path"
        cd "$(dirname "$script_path")"
        ./security_basics.sh
    else
        log_error "보안 기초 실습 스크립트를 찾을 수 없습니다: $script_path"
        return 1
    fi
}

run_day2_database_services() {
    log_header "=== Day 2: 데이터베이스 서비스 실습 ==="
    
    local script_path="$AUTOMATION_DIR/day2/database_services.sh"
    
    if [ -f "$script_path" ]; then
        log_info "데이터베이스 서비스 실습 스크립트 실행: $script_path"
        chmod +x "$script_path"
        cd "$(dirname "$script_path")"
        ./database_services.sh
    else
        log_error "데이터베이스 서비스 실습 스크립트를 찾을 수 없습니다: $script_path"
        return 1
    fi
}

run_day2_comprehensive_practice() {
    log_header "=== Day 2: 종합 실습 ==="
    
    local script_path="$AUTOMATION_DIR/day2/comprehensive_practice.sh"
    
    if [ -f "$script_path" ]; then
        log_info "종합 실습 스크립트 실행: $script_path"
        chmod +x "$script_path"
        cd "$(dirname "$script_path")"
        ./comprehensive_practice.sh
    else
        log_error "종합 실습 스크립트를 찾을 수 없습니다: $script_path"
        return 1
    fi
}

# Automation test functions
run_automation_tests() {
    log_header "=== 자동화 테스트 실행 ==="
    
    if [ -d "$AUTOMATION_TESTS_DIR" ]; then
        log_info "자동화 테스트 디렉토리로 이동: $AUTOMATION_TESTS_DIR"
        cd "$AUTOMATION_TESTS_DIR"
        
        # Run dry-run test
        if [ -f "dry_run_test.py" ]; then
            log_info "Dry-run 테스트 실행 중..."
            python3 dry_run_test.py
        else
            log_error "dry_run_test.py 파일을 찾을 수 없습니다"
            return 1
        fi
        
        # Run basic course tests
        if [ -f "run_basic_course_tests.py" ]; then
            log_info "Basic 과정 테스트 실행 중..."
            python3 run_basic_course_tests.py
        else
            log_error "run_basic_course_tests.py 파일을 찾을 수 없습니다"
            return 1
        fi
    else
        log_error "자동화 테스트 디렉토리를 찾을 수 없습니다: $AUTOMATION_TESTS_DIR"
        return 1
    fi
}

run_automation_generation() {
    log_header "=== 자동화 스크립트 생성 ==="
    
    if [ -d "$AUTOMATION_TESTS_DIR" ]; then
        log_info "자동화 테스트 디렉토리로 이동: $AUTOMATION_TESTS_DIR"
        cd "$AUTOMATION_TESTS_DIR"
        
        # Run automation generation
        if [ -f "basic_course_automation.py" ]; then
            log_info "자동화 스크립트 생성 중..."
            python3 basic_course_automation.py
        else
            log_error "basic_course_automation.py 파일을 찾을 수 없습니다"
            return 1
        fi
    else
        log_error "자동화 테스트 디렉토리를 찾을 수 없습니다: $AUTOMATION_TESTS_DIR"
        return 1
    fi
}

# Resource cleanup functions
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

# Main menu
main_menu() {
    while true; do
        clear
        log_header "=== Cloud Basic Helper ==="
        echo -e "${CYAN}현재 시간: $(date)${NC}"
        echo -e "${CYAN}프로젝트 루트: $PROJECT_ROOT${NC}"
        echo ""
        echo "1. 🔍 종합 환경 체크"
        echo "2. 🚀 Day 1: 클라우드 기초 실습"
        echo "3. 🚀 Day 1: IAM 기초 실습"
        echo "4. 🚀 Day 1: VM 서비스 실습"
        echo "5. 🚀 Day 1: 스토리지 서비스 실습"
        echo "6. 🚀 Day 2: 네트워킹 기초 실습"
        echo "7. 🚀 Day 2: 보안 기초 실습"
        echo "8. 🚀 Day 2: 데이터베이스 서비스 실습"
        echo "9. 🚀 Day 2: 종합 실습"
        echo "10. 🧪 자동화 테스트 실행"
        echo "11. 🔧 자동화 스크립트 생성"
        echo "12. 🧹 AWS 리소스 정리"
        echo "13. 🧹 GCP 리소스 정리"
        echo "0. 종료"
        echo ""
        read -p "메뉴를 선택하세요 (0-13): " choice
        
        case $choice in
            1) comprehensive_environment_check ;;
            2) run_day1_cloud_basics ;;
            3) run_day1_iam_basics ;;
            4) run_day1_vm_services ;;
            5) run_day1_storage_services ;;
            6) run_day2_networking_basics ;;
            7) run_day2_security_basics ;;
            8) run_day2_database_services ;;
            9) run_day2_comprehensive_practice ;;
            10) run_automation_tests ;;
            11) run_automation_generation ;;
            12) cleanup_aws_resources ;;
            13) cleanup_gcp_resources ;;
            0) 
                log_info "Cloud Basic Helper를 종료합니다."
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
log_header "Cloud Basic Helper 시작"
main_menu
