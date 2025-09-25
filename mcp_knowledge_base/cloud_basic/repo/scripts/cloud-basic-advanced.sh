#!/bin/bash

# Cloud Basic Advanced Helper Script
# 고도화된 Cloud Basic 실습 도구

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
LOG_FILE="$PROJECT_ROOT/cloud-basic-advanced.log"

# Initialize log file
init_log() {
    echo "=== Cloud Basic Advanced Helper Log ===" > "$LOG_FILE"
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

# Resource management functions
list_aws_resources() {
    log_header "=== AWS 리소스 현황 ==="
    
    if ! check_aws_cli; then
        return 1
    fi
    
    # EC2 instances
    log_info "EC2 인스턴스 조회 중..."
    aws ec2 describe-instances --query 'Reservations[*].Instances[*].[InstanceId,State.Name,InstanceType,PublicIpAddress,Tags[?Key==`Name`].Value|[0]]' --output table 2>/dev/null || log_warning "EC2 인스턴스 조회 실패"
    
    # S3 buckets
    log_info "S3 버킷 조회 중..."
    aws s3 ls 2>/dev/null || log_warning "S3 버킷 조회 실패"
    
    # IAM users
    log_info "IAM 사용자 조회 중..."
    aws iam list-users --query 'Users[*].[UserName,CreateDate]' --output table 2>/dev/null || log_warning "IAM 사용자 조회 실패"
}

list_gcp_resources() {
    log_header "=== GCP 리소스 현황 ==="
    
    if ! check_gcp_cli; then
        return 1
    fi
    
    # Compute instances
    log_info "Compute 인스턴스 조회 중..."
    gcloud compute instances list --format="table(name,zone,status,machineType,externalIP)" 2>/dev/null || log_warning "Compute 인스턴스 조회 실패"
    
    # Cloud Storage buckets
    log_info "Cloud Storage 버킷 조회 중..."
    gsutil ls 2>/dev/null || log_warning "Cloud Storage 버킷 조회 실패"
    
    # IAM service accounts
    log_info "IAM 서비스 계정 조회 중..."
    gcloud iam service-accounts list --format="table(email,displayName)" 2>/dev/null || log_warning "IAM 서비스 계정 조회 실패"
}

# Cost analysis functions
analyze_aws_costs() {
    log_header "=== AWS 비용 분석 ==="
    
    if ! check_aws_cli; then
        return 1
    fi
    
    log_info "AWS 비용 분석 중... (Cost Explorer API 필요)"
    
    # Check for unused resources
    log_info "사용하지 않는 리소스 검색 중..."
    
    # Unused EBS volumes
    log_info "사용하지 않는 EBS 볼륨:"
    aws ec2 describe-volumes --filters "Name=status,Values=available" --query 'Volumes[*].[VolumeId,Size,VolumeType,CreateTime]' --output table 2>/dev/null || log_warning "EBS 볼륨 조회 실패"
    
    # Unused Elastic IPs
    log_info "사용하지 않는 Elastic IP:"
    aws ec2 describe-addresses --query 'Addresses[?InstanceId==null].[PublicIp,AllocationId]' --output table 2>/dev/null || log_warning "Elastic IP 조회 실패"
    
    # Empty S3 buckets
    log_info "비어있는 S3 버킷:"
    aws s3 ls | while read -r bucket_info; do
        bucket_name=$(echo "$bucket_info" | awk '{print $3}')
        if [ -n "$bucket_name" ]; then
            object_count=$(aws s3 ls "s3://$bucket_name" --recursive --summarize 2>/dev/null | grep "Total Objects: 0" || echo "has objects")
            if [[ "$object_count" == *"Total Objects: 0"* ]]; then
                echo "  - $bucket_name (비어있음)"
            fi
        fi
    done
}

analyze_gcp_costs() {
    log_header "=== GCP 비용 분석 ==="
    
    if ! check_gcp_cli; then
        return 1
    fi
    
    log_info "GCP 비용 분석 중..."
    
    # Check for unused resources
    log_info "사용하지 않는 리소스 검색 중..."
    
    # Unused persistent disks
    log_info "사용하지 않는 영구 디스크:"
    gcloud compute disks list --filter="status:READY AND -users:*" --format="table(name,zone,sizeGb,type)" 2>/dev/null || log_warning "영구 디스크 조회 실패"
    
    # Unused static IPs
    log_info "사용하지 않는 정적 IP:"
    gcloud compute addresses list --filter="status:RESERVED AND -users:*" --format="table(name,region,address)" 2>/dev/null || log_warning "정적 IP 조회 실패"
    
    # Empty Cloud Storage buckets
    log_info "비어있는 Cloud Storage 버킷:"
    gsutil ls 2>/dev/null | while read -r bucket_uri; do
        if [ -n "$bucket_uri" ]; then
            bucket_name=$(echo "$bucket_uri" | sed 's|gs://||' | sed 's|/||')
            object_count=$(gsutil ls -l "gs://$bucket_name" 2>/dev/null | wc -l)
            if [ "$object_count" -le 1 ]; then
                echo "  - $bucket_name (비어있음)"
            fi
        fi
    done
}

# Practice automation functions
run_day1_practice() {
    log_header "=== Day 1 실습 실행 ==="
    
    local day1_scripts=(
        "cloud_basics.sh"
        "iam_basics.sh"
        "vm_services.sh"
        "storage_services.sh"
    )
    
    for script in "${day1_scripts[@]}"; do
        local script_path="$AUTOMATION_DIR/day1/$script"
        
        if [ -f "$script_path" ]; then
            log_info "Day 1 실습 스크립트 실행: $script"
            chmod +x "$script_path"
            cd "$(dirname "$script_path")"
            ./"$script"
            
            if [ $? -eq 0 ]; then
                log_success "✅ $script 실행 완료"
            else
                log_error "❌ $script 실행 실패"
            fi
        else
            log_error "스크립트를 찾을 수 없습니다: $script_path"
        fi
    done
}

run_day2_practice() {
    log_header "=== Day 2 실습 실행 ==="
    
    local day2_scripts=(
        "networking_basics.sh"
        "security_basics.sh"
        "database_services.sh"
        "comprehensive_practice.sh"
    )
    
    for script in "${day2_scripts[@]}"; do
        local script_path="$AUTOMATION_DIR/day2/$script"
        
        if [ -f "$script_path" ]; then
            log_info "Day 2 실습 스크립트 실행: $script"
            chmod +x "$script_path"
            cd "$(dirname "$script_path")"
            ./"$script"
            
            if [ $? -eq 0 ]; then
                log_success "✅ $script 실행 완료"
            else
                log_error "❌ $script 실행 실패"
            fi
        else
            log_error "스크립트를 찾을 수 없습니다: $script_path"
        fi
    done
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
        
        # Delete empty S3 buckets
        log_info "비어있는 S3 버킷 삭제 중..."
        aws s3 ls | while read -r bucket_info; do
            bucket_name=$(echo "$bucket_info" | awk '{print $3}')
            if [ -n "$bucket_name" ]; then
                object_count=$(aws s3 ls "s3://$bucket_name" --recursive --summarize 2>/dev/null | grep "Total Objects: 0" || echo "has objects")
                if [[ "$object_count" == *"Total Objects: 0"* ]]; then
                    log_info "비어있는 버킷 삭제: $bucket_name"
                    aws s3 rb "s3://$bucket_name" 2>/dev/null || log_warning "버킷 $bucket_name 삭제 실패"
                fi
            fi
        done
        
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
        
        # Delete empty Cloud Storage buckets
        log_info "비어있는 Cloud Storage 버킷 삭제 중..."
        gsutil ls 2>/dev/null | while read -r bucket_uri; do
            if [ -n "$bucket_uri" ]; then
                bucket_name=$(echo "$bucket_uri" | sed 's|gs://||' | sed 's|/||')
                object_count=$(gsutil ls -l "gs://$bucket_name" 2>/dev/null | wc -l)
                if [ "$object_count" -le 1 ]; then
                    log_info "비어있는 버킷 삭제: $bucket_name"
                    gsutil rm -r "gs://$bucket_name" 2>/dev/null || log_warning "버킷 $bucket_name 삭제 실패"
                fi
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
        log_header "=== Cloud Basic Advanced Helper ==="
        echo -e "${CYAN}현재 시간: $(date)${NC}"
        echo -e "${CYAN}로그 파일: $LOG_FILE${NC}"
        echo ""
        echo "1. 🔍 종합 환경 체크"
        echo "2. 📊 AWS 리소스 현황"
        echo "3. 📊 GCP 리소스 현황"
        echo "4. 💰 AWS 비용 분석"
        echo "5. 💰 GCP 비용 분석"
        echo "6. 🚀 Day 1 실습 실행 (전체)"
        echo "7. 🚀 Day 2 실습 실행 (전체)"
        echo "8. 🧪 자동화 테스트 실행"
        echo "9. 🔧 자동화 스크립트 생성"
        echo "10. 🧹 AWS 리소스 정리"
        echo "11. 🧹 GCP 리소스 정리"
        echo "12. 📋 로그 보기"
        echo "0. 종료"
        echo ""
        read -p "메뉴를 선택하세요 (0-12): " choice
        
        case $choice in
            1) comprehensive_environment_check ;;
            2) list_aws_resources ;;
            3) list_gcp_resources ;;
            4) analyze_aws_costs ;;
            5) analyze_gcp_costs ;;
            6) run_day1_practice ;;
            7) run_day2_practice ;;
            8) run_automation_tests ;;
            9) run_automation_generation ;;
            10) cleanup_aws_resources ;;
            11) cleanup_gcp_resources ;;
            12) 
                log_info "로그 파일 내용:"
                cat "$LOG_FILE" | tail -50
                ;;
            0) 
                log_info "Cloud Basic Advanced Helper를 종료합니다."
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
log_header "Cloud Basic Advanced Helper 시작"
main_menu
