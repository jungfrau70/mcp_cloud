#!/bin/bash

# =============================================================================
# Cloud Master Day1 - 통합 VM 정리 스크립트
# GCP와 AWS VM 인스턴스를 선택적으로 정리할 수 있는 대화형 스크립트
# =============================================================================

set -e

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 로그 함수
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_header() { echo -e "${PURPLE}[HEADER]${NC} $1"; }

# 설정
AWS_REGION="ap-northeast-2"
GCP_PROJECT="cloud-deployment-471606"
GCP_ZONE="asia-northeast3-a"

# 체크포인트 파일
CHECKPOINT_FILE="vm-cleanup-checkpoint.json"

# =============================================================================
# 유틸리티 함수
# =============================================================================

# 환경 체크
check_environment() {
    log_header "=== 환경 체크 ==="
    
    # AWS CLI 체크
    if command -v aws &> /dev/null; then
        log_success "AWS CLI 설치됨"
        aws --version
    else
        log_error "AWS CLI가 설치되지 않았습니다."
        return 1
    fi
    
    # GCP CLI 체크
    if command -v gcloud &> /dev/null; then
        log_success "GCP CLI 설치됨"
        gcloud version --format="value(Google Cloud SDK)" 2>/dev/null || gcloud version
    else
        log_warning "GCP CLI가 설치되지 않았습니다. GCP VM 정리 기능을 사용할 수 없습니다."
    fi
    
    echo ""
}

# AWS 계정 정보 확인
check_aws_credentials() {
    log_info "AWS 계정 정보 확인 중..."
    
    if aws sts get-caller-identity &> /dev/null; then
        local account_id=$(aws sts get-caller-identity --query Account --output text)
        local user_arn=$(aws sts get-caller-identity --query Arn --output text)
        log_success "AWS 계정 ID: $account_id"
        log_success "사용자: $user_arn"
        return 0
    else
        log_error "AWS 자격 증명이 설정되지 않았습니다."
        return 1
    fi
}

# GCP 계정 정보 확인
check_gcp_credentials() {
    log_info "GCP 계정 정보 확인 중..."
    
    if gcloud auth list --filter=status:ACTIVE --format="value(account)" &> /dev/null; then
        local account=$(gcloud auth list --filter=status:ACTIVE --format="value(account)")
        local project=$(gcloud config get-value project 2>/dev/null)
        log_success "GCP 계정: $account"
        log_success "프로젝트: $project"
        return 0
    else
        log_error "GCP 자격 증명이 설정되지 않았습니다."
        return 1
    fi
}

# =============================================================================
# GCP VM 관리
# =============================================================================

# GCP VM 인스턴스 목록 조회
list_gcp_vms() {
    log_info "GCP VM 인스턴스 목록 조회 중..."
    
    local vms=$(gcloud compute instances list --format="value(name,zone,status,machineType)" 2>/dev/null)
    
    if [ -z "$vms" ]; then
        log_warning "GCP VM 인스턴스가 없습니다."
        return 1
    fi
    
    echo ""
    log_info "=== GCP VM 인스턴스 목록 ==="
    local count=0
    local vm_names=()
    local vm_zones=()
    while IFS=$'\t' read -r name zone status machine_type; do
        count=$((count + 1))
        vm_names+=("$name")
        vm_zones+=("$zone")
        echo "  $count. 📦 $name"
        echo "     존: $zone"
        echo "     상태: $status"
        echo "     머신 타입: $machine_type"
        echo ""
    done <<< "$vms"
    
    if [ $count -eq 0 ]; then
        log_warning "GCP VM 인스턴스가 없습니다."
        return 1
    fi
    
    # 전역 배열에 저장
    GCP_VM_NAMES=("${vm_names[@]}")
    GCP_VM_ZONES=("${vm_zones[@]}")
    return 0
}

# GCP VM 인스턴스 삭제
delete_gcp_vm() {
    local vm_name="$1"
    local zone="$2"
    
    log_warning "GCP VM 인스턴스 삭제: $vm_name (존: $zone)"
    echo -n "정말로 삭제하시겠습니까? (y/N): "
    read -r response
    
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        log_info "삭제가 취소되었습니다."
        return 0
    fi
    
    log_info "GCP VM 인스턴스 삭제 중: $vm_name"
    
    if gcloud compute instances delete "$vm_name" --zone="$zone" --quiet; then
        log_success "GCP VM 인스턴스 삭제 완료: $vm_name"
        return 0
    else
        log_error "GCP VM 인스턴스 삭제 실패: $vm_name"
        return 1
    fi
}

# =============================================================================
# AWS EC2 관리
# =============================================================================

# AWS EC2 인스턴스 목록 조회
list_aws_ec2s() {
    log_info "AWS EC2 인스턴스 목록 조회 중..."
    
    local instances=$(aws ec2 describe-instances \
        --region "$AWS_REGION" \
        --query 'Reservations[*].Instances[*].[InstanceId,State.Name,InstanceType,PublicIpAddress,PrivateIpAddress,Tags[?Key==`Name`].Value|[0]]' \
        --output text 2>/dev/null)
    
    if [ -z "$instances" ]; then
        log_warning "AWS EC2 인스턴스가 없습니다."
        return 1
    fi
    
    echo ""
    log_info "=== AWS EC2 인스턴스 목록 ==="
    local count=0
    local instance_ids=()
    while IFS=$'\t' read -r instance_id state instance_type public_ip private_ip name; do
        count=$((count + 1))
        instance_ids+=("$instance_id")
        echo "  $count. 📦 $instance_id"
        echo "     이름: ${name:-N/A}"
        echo "     상태: $state"
        echo "     타입: $instance_type"
        echo "     퍼블릭 IP: ${public_ip:-N/A}"
        echo "     프라이빗 IP: ${private_ip:-N/A}"
        echo ""
    done <<< "$instances"
    
    if [ $count -eq 0 ]; then
        log_warning "AWS EC2 인스턴스가 없습니다."
        return 1
    fi
    
    # 전역 배열에 저장
    AWS_INSTANCE_IDS=("${instance_ids[@]}")
    return 0
}

# AWS EC2 인스턴스 삭제
delete_aws_ec2() {
    local instance_id="$1"
    
    log_warning "AWS EC2 인스턴스 삭제: $instance_id"
    echo -n "정말로 삭제하시겠습니까? (y/N): "
    read -r response
    
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        log_info "삭제가 취소되었습니다."
        return 0
    fi
    
    log_info "AWS EC2 인스턴스 삭제 중: $instance_id"
    
    if aws ec2 terminate-instances --instance-ids "$instance_id" --region "$AWS_REGION"; then
        log_success "AWS EC2 인스턴스 삭제 완료: $instance_id"
        return 0
    else
        log_error "AWS EC2 인스턴스 삭제 실패: $instance_id"
        return 1
    fi
}

# =============================================================================
# 메인 메뉴
# =============================================================================

# GCP VM 메뉴
gcp_vm_menu() {
    while true; do
        echo ""
        log_header "=== GCP VM 인스턴스 관리 ==="
        echo "1. GCP VM 인스턴스 목록 보기"
        echo "2. GCP VM 인스턴스 삭제"
        echo "3. 모든 GCP VM 인스턴스 삭제"
        echo "4. 메인 메뉴로 돌아가기"
        echo ""
        echo -n "선택 (1-4): "
        read -r choice
        
        case $choice in
            1)
                list_gcp_vms
                ;;
            2)
                if list_gcp_vms; then
                    echo ""
                    echo -n "삭제할 VM 번호를 입력하세요 (1-${#GCP_VM_NAMES[@]}): "
                    read -r choice
                    if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le "${#GCP_VM_NAMES[@]}" ]; then
                        local vm_name="${GCP_VM_NAMES[$((choice-1))]}"
                        local zone="${GCP_VM_ZONES[$((choice-1))]}"
                        delete_gcp_vm "$vm_name" "$zone"
                    else
                        log_error "잘못된 번호입니다."
                    fi
                fi
                ;;
            3)
                log_warning "모든 GCP VM 인스턴스를 삭제합니다."
                echo -n "정말로 모든 GCP VM 인스턴스를 삭제하시겠습니까? (y/N): "
                read -r response
                if [[ "$response" =~ ^[Yy]$ ]]; then
                    local vms=$(gcloud compute instances list --format="value(name,zone)" 2>/dev/null)
                    while IFS=$'\t' read -r name zone; do
                        if [ -n "$name" ] && [ -n "$zone" ]; then
                            delete_gcp_vm "$name" "$zone"
                        fi
                    done <<< "$vms"
                fi
                ;;
            4)
                break
                ;;
            *)
                log_error "잘못된 선택입니다."
                ;;
        esac
    done
}

# AWS EC2 메뉴
aws_ec2_menu() {
    while true; do
        echo ""
        log_header "=== AWS EC2 인스턴스 관리 ==="
        echo "1. AWS EC2 인스턴스 목록 보기"
        echo "2. AWS EC2 인스턴스 삭제"
        echo "3. 모든 AWS EC2 인스턴스 삭제"
        echo "4. 메인 메뉴로 돌아가기"
        echo ""
        echo -n "선택 (1-4): "
        read -r choice
        
        case $choice in
            1)
                list_aws_ec2s
                ;;
            2)
                if list_aws_ec2s; then
                    echo ""
                    echo -n "삭제할 인스턴스 번호를 입력하세요 (1-${#AWS_INSTANCE_IDS[@]}): "
                    read -r choice
                    if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le "${#AWS_INSTANCE_IDS[@]}" ]; then
                        local instance_id="${AWS_INSTANCE_IDS[$((choice-1))]}"
                        delete_aws_ec2 "$instance_id"
                    else
                        log_error "잘못된 번호입니다."
                    fi
                fi
                ;;
            3)
                log_warning "모든 AWS EC2 인스턴스를 삭제합니다."
                echo -n "정말로 모든 AWS EC2 인스턴스를 삭제하시겠습니까? (y/N): "
                read -r response
                if [[ "$response" =~ ^[Yy]$ ]]; then
                    local instances=$(aws ec2 describe-instances \
                        --region "$AWS_REGION" \
                        --query 'Reservations[*].Instances[*].InstanceId' \
                        --output text 2>/dev/null)
                    for instance_id in $instances; do
                        if [ -n "$instance_id" ]; then
                            delete_aws_ec2 "$instance_id"
                        fi
                    done
                fi
                ;;
            4)
                break
                ;;
            *)
                log_error "잘못된 선택입니다."
                ;;
        esac
    done
}

# 전체 정리 메뉴
full_cleanup_menu() {
    log_warning "전체 VM 정리를 시작합니다."
    echo "이 작업은 모든 GCP와 AWS VM 인스턴스를 삭제합니다."
    echo -n "정말로 계속하시겠습니까? (y/N): "
    read -r response
    
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        log_info "전체 정리가 취소되었습니다."
        return 0
    fi
    
    # GCP VM 정리
    log_info "GCP VM 인스턴스 정리 시작..."
    local gcp_vms=$(gcloud compute instances list --format="value(name,zone)" 2>/dev/null)
    if [ -n "$gcp_vms" ]; then
        while IFS=$'\t' read -r name zone; do
            if [ -n "$name" ] && [ -n "$zone" ]; then
                log_info "GCP VM 인스턴스 삭제: $name"
                gcloud compute instances delete "$name" --zone="$zone" --quiet
            fi
        done <<< "$gcp_vms"
    else
        log_info "삭제할 GCP VM 인스턴스가 없습니다."
    fi
    
    # AWS EC2 정리
    log_info "AWS EC2 인스턴스 정리 시작..."
    local aws_instances=$(aws ec2 describe-instances \
        --region "$AWS_REGION" \
        --query 'Reservations[*].Instances[*].InstanceId' \
        --output text 2>/dev/null)
    if [ -n "$aws_instances" ]; then
        for instance_id in $aws_instances; do
            if [ -n "$instance_id" ]; then
                log_info "AWS EC2 인스턴스 삭제: $instance_id"
                aws ec2 terminate-instances --instance-ids "$instance_id" --region "$AWS_REGION"
            fi
        done
    else
        log_info "삭제할 AWS EC2 인스턴스가 없습니다."
    fi
    
    log_success "전체 VM 정리 완료!"
}

# 메인 메뉴
main_menu() {
    while true; do
        echo ""
        log_header "=== Cloud Master Day1 - 통합 VM 정리 ==="
        echo "1. GCP VM 인스턴스 관리"
        echo "2. AWS EC2 인스턴스 관리"
        echo "3. 전체 VM 정리 (GCP + AWS)"
        echo "4. 환경 상태 확인"
        echo "5. 종료"
        echo ""
        echo -n "선택 (1-5): "
        read -r choice
        
        case $choice in
            1)
                gcp_vm_menu
                ;;
            2)
                aws_ec2_menu
                ;;
            3)
                full_cleanup_menu
                ;;
            4)
                check_environment
                ;;
            5)
                log_info "프로그램을 종료합니다."
                exit 0
                ;;
            *)
                log_error "잘못된 선택입니다."
                ;;
        esac
    done
}

# =============================================================================
# 메인 실행
# =============================================================================

main() {
    log_header "=== Cloud Master Day1 - 통합 VM 정리 스크립트 ==="
    log_info "GCP와 AWS VM 인스턴스를 선택적으로 정리할 수 있습니다."
    echo ""
    
    # 환경 체크
    if ! check_environment; then
        log_error "환경 체크 실패. 필요한 도구를 설치하세요."
        exit 1
    fi
    
    # AWS 자격 증명 체크
    if ! check_aws_credentials; then
        log_warning "AWS 자격 증명이 설정되지 않았습니다. AWS 기능을 사용할 수 없습니다."
    fi
    
    # GCP 자격 증명 체크
    if ! check_gcp_credentials; then
        log_warning "GCP 자격 증명이 설정되지 않았습니다. GCP 기능을 사용할 수 없습니다."
    fi
    
    # 메인 메뉴 시작
    main_menu
}

# 스크립트 실행
main "$@"
