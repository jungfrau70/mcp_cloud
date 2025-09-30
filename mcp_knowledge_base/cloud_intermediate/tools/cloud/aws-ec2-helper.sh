#!/bin/bash

# =============================================================================
# AWS EC2 Helper 모듈
# =============================================================================
# 
# 기능:
#   - AWS EC2 인스턴스 생성 및 관리
#   - 보안 그룹 설정
#   - 키 페어 관리
#   - 인스턴스 상태 모니터링
#   - 서브실행모듈을 통한 클라우드 작업 실행
#
# 사용법:
#   ./aws-ec2-helper.sh --action <액션> [옵션]
#   ./aws-ec2-helper.sh --help
#
# 작성일: 2024-01-XX
# 작성자: Cloud Intermediate 과정
# =============================================================================

# =============================================================================
# 환경 설정 및 초기화
# =============================================================================
set -euo pipefail

# 스크립트 디렉토리 설정
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

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
log_debug() { echo -e "${PURPLE}[DEBUG]${NC} $1"; }
log_step() { echo -e "${CYAN}[STEP]${NC} $1"; }

# =============================================================================
# 환경 설정 로드
# =============================================================================
load_environment() {
    log_info "환경 설정 로드 중..."
    
    # AWS 환경 설정 로드
    if [ -f "aws-environment.env" ]; then
        source "aws-environment.env"
        log_success "AWS 환경 설정 로드 완료"
        log_info "로드된 설정:"
        echo "  - 리전: ${REGION:-'설정되지 않음'}"
        echo "  - VPC: ${VPC_ID:-'설정되지 않음'}"
        echo "  - 서브넷: ${SUBNET_ID:-'설정되지 않음'}"
        echo "  - 계정: ${AWS_ACCOUNT_ID:-'설정되지 않음'}"
    else
        log_warning "AWS 환경 설정 파일을 찾을 수 없습니다: aws-environment.env"
        log_info "aws-setup-helper.sh를 먼저 실행하세요."
    fi
}

# =============================================================================
# 사용법 출력
# =============================================================================
usage() {
    cat << EOF
AWS EC2 Helper 모듈

사용법:
  $0 --action <액션> [옵션]

액션:
  create-instance        # EC2 인스턴스 생성
  create-security-group  # 보안 그룹 생성
  create-key-pair        # 키 페어 생성
  start-instance         # 인스턴스 시작
  stop-instance          # 인스턴스 중지
  terminate-instance     # 인스턴스 종료
  list-instances         # 인스턴스 목록 조회
  instance-status        # 인스턴스 상태 확인
  cleanup                # EC2 리소스 정리
  status                 # EC2 상태 확인

옵션:
  --instance-name <name> # 인스턴스 이름 (기본값: mcp-cloud-instance)
  --instance-type <type> # 인스턴스 타입 (기본값: t3.medium)
  --key-name <key>       # 키 페어 이름 (기본값: mcp-cloud-key)
  --security-group <sg>  # 보안 그룹 ID
  --subnet-id <subnet>   # 서브넷 ID (기본값: 환경변수)
  --region <region>      # AWS 리전 (기본값: 환경변수)
  --help, -h             # 도움말 표시

예시:
  $0 --action create-instance
  $0 --action create-instance --instance-name my-instance --instance-type t3.large
  $0 --action create-security-group
  $0 --action list-instances
  $0 --action cleanup
EOF
}

# =============================================================================
# EC2 인스턴스 생성
# =============================================================================
create_instance() {
    local instance_name="${1:-mcp-cloud-instance}"
    local instance_type="${2:-t3.medium}"
    local key_name="${3:-mcp-cloud-key}"
    local security_group="${4:-}"
    local subnet_id="${5:-${SUBNET_ID:-}}"
    local region="${6:-${REGION:-ap-northeast-2}}"
    
    log_step "EC2 인스턴스 생성 시작"
    log_info "인스턴스 이름: $instance_name"
    log_info "인스턴스 타입: $instance_type"
    log_info "키 페어: $key_name"
    log_info "리전: $region"
    
    # AMI ID 설정 (Amazon Linux 2)
    local ami_id="ami-0ae2c887094315bed"
    
    # 보안 그룹 ID 확인
    if [ -z "$security_group" ]; then
        log_info "보안 그룹을 찾는 중..."
        security_group=$(aws ec2 describe-security-groups \
            --region "$region" \
            --filters "Name=group-name,Values=mcp-cloud-sg" \
            --query 'SecurityGroups[0].GroupId' \
            --output text 2>/dev/null || echo "")
        
        if [ -z "$security_group" ] || [ "$security_group" = "None" ]; then
            log_warning "기본 보안 그룹을 찾을 수 없습니다. 새로 생성합니다."
            create_security_group "mcp-cloud-sg" "$region"
            security_group=$(aws ec2 describe-security-groups \
                --region "$region" \
                --filters "Name=group-name,Values=mcp-cloud-sg" \
                --query 'SecurityGroups[0].GroupId' \
                --output text)
        fi
    fi
    
    # 서브넷 ID 확인
    if [ -z "$subnet_id" ]; then
        log_error "서브넷 ID가 설정되지 않았습니다."
        return 1
    fi
    
    # 인스턴스 생성
    log_info "인스턴스 생성 중..."
    local instance_id
    instance_id=$(aws ec2 run-instances \
        --region "$region" \
        --image-id "$ami_id" \
        --instance-type "$instance_type" \
        --key-name "$key_name" \
        --security-group-ids "$security_group" \
        --subnet-id "$subnet_id" \
        --associate-public-ip-address \
        --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance_name}]" \
        --query 'Instances[0].InstanceId' \
        --output text)
    
    if [ -z "$instance_id" ] || [ "$instance_id" = "None" ]; then
        log_error "인스턴스 생성에 실패했습니다."
        return 1
    fi
    
    log_success "인스턴스가 생성되었습니다: $instance_id"
    
    # 인스턴스 상태 확인
    log_info "인스턴스 상태 확인 중..."
    aws ec2 wait instance-running \
        --region "$region" \
        --instance-ids "$instance_id"
    
    # 퍼블릭 IP 주소 가져오기
    local public_ip
    public_ip=$(aws ec2 describe-instances \
        --region "$region" \
        --instance-ids "$instance_id" \
        --query 'Reservations[0].Instances[0].PublicIpAddress' \
        --output text)
    
    log_success "인스턴스가 실행 중입니다"
    log_info "인스턴스 ID: $instance_id"
    log_info "퍼블릭 IP: $public_ip"
    log_info "SSH 접속: ssh -i ~/.ssh/$key_name.pem ec2-user@$public_ip"
    
    return 0
}

# =============================================================================
# 보안 그룹 생성
# =============================================================================
create_security_group() {
    local sg_name="${1:-mcp-cloud-sg}"
    local region="${2:-${REGION:-ap-northeast-2}}"
    
    log_step "보안 그룹 생성 시작"
    log_info "보안 그룹 이름: $sg_name"
    log_info "리전: $region"
    
    # VPC ID 확인
    local vpc_id="${VPC_ID:-}"
    if [ -z "$vpc_id" ]; then
        log_error "VPC ID가 설정되지 않았습니다."
        return 1
    fi
    
    # 보안 그룹 생성
    local sg_id
    sg_id=$(aws ec2 create-security-group \
        --region "$region" \
        --group-name "$sg_name" \
        --description "MCP Cloud Security Group" \
        --vpc-id "$vpc_id" \
        --query 'GroupId' \
        --output text)
    
    if [ -z "$sg_id" ] || [ "$sg_id" = "None" ]; then
        log_error "보안 그룹 생성에 실패했습니다."
        return 1
    fi
    
    log_success "보안 그룹이 생성되었습니다: $sg_id"
    
    # 보안 그룹 규칙 추가
    log_info "보안 그룹 규칙 추가 중..."
    
    # SSH (포트 22)
    aws ec2 authorize-security-group-ingress \
        --region "$region" \
        --group-id "$sg_id" \
        --protocol tcp \
        --port 22 \
        --cidr 0.0.0.0/0
    
    # HTTP (포트 80)
    aws ec2 authorize-security-group-ingress \
        --region "$region" \
        --group-id "$sg_id" \
        --protocol tcp \
        --port 80 \
        --cidr 0.0.0.0/0
    
    # HTTPS (포트 443)
    aws ec2 authorize-security-group-ingress \
        --region "$region" \
        --group-id "$sg_id" \
        --protocol tcp \
        --port 443 \
        --cidr 0.0.0.0/0
    
    # 커스텀 포트 (3000-9000)
    aws ec2 authorize-security-group-ingress \
        --region "$region" \
        --group-id "$sg_id" \
        --protocol tcp \
        --port 3000-9000 \
        --cidr 0.0.0.0/0
    
    log_success "보안 그룹 규칙이 추가되었습니다"
    log_info "보안 그룹 ID: $sg_id"
    
    return 0
}

# =============================================================================
# 키 페어 생성
# =============================================================================
create_key_pair() {
    local key_name="${1:-mcp-cloud-key}"
    local region="${2:-${REGION:-ap-northeast-2}}"
    
    log_step "키 페어 생성 시작"
    log_info "키 페어 이름: $key_name"
    log_info "리전: $region"
    
    # 키 페어 생성
    aws ec2 create-key-pair \
        --region "$region" \
        --key-name "$key_name" \
        --query 'KeyMaterial' \
        --output text > "${key_name}.pem"
    
    if [ $? -eq 0 ]; then
        chmod 400 "${key_name}.pem"
        log_success "키 페어가 생성되었습니다: ${key_name}.pem"
        log_info "키 파일 위치: $(pwd)/${key_name}.pem"
        log_info "SSH 사용법: ssh -i ${key_name}.pem ec2-user@<public-ip>"
    else
        log_error "키 페어 생성에 실패했습니다."
        return 1
    fi
    
    return 0
}

# =============================================================================
# 인스턴스 목록 조회
# =============================================================================
list_instances() {
    local region="${1:-${REGION:-ap-northeast-2}}"
    
    log_step "EC2 인스턴스 목록 조회"
    log_info "리전: $region"
    
    aws ec2 describe-instances \
        --region "$region" \
        --query 'Reservations[*].Instances[*].[InstanceId,State.Name,InstanceType,PublicIpAddress,PrivateIpAddress,Tags[?Key==`Name`].Value|[0]]' \
        --output table
}

# =============================================================================
# 인스턴스 상태 확인
# =============================================================================
instance_status() {
    local instance_id="${1:-}"
    local region="${2:-${REGION:-ap-northeast-2}}"
    
    if [ -z "$instance_id" ]; then
        log_error "인스턴스 ID를 지정해주세요."
        return 1
    fi
    
    log_step "인스턴스 상태 확인"
    log_info "인스턴스 ID: $instance_id"
    log_info "리전: $region"
    
    aws ec2 describe-instances \
        --region "$region" \
        --instance-ids "$instance_id" \
        --query 'Reservations[0].Instances[0].[InstanceId,State.Name,InstanceType,PublicIpAddress,PrivateIpAddress,LaunchTime]' \
        --output table
}

# =============================================================================
# 인스턴스 시작
# =============================================================================
start_instance() {
    local instance_id="${1:-}"
    local region="${2:-${REGION:-ap-northeast-2}}"
    
    if [ -z "$instance_id" ]; then
        log_error "인스턴스 ID를 지정해주세요."
        return 1
    fi
    
    log_step "인스턴스 시작"
    log_info "인스턴스 ID: $instance_id"
    
    aws ec2 start-instances \
        --region "$region" \
        --instance-ids "$instance_id"
    
    log_success "인스턴스 시작 요청이 완료되었습니다"
    
    # 인스턴스가 실행될 때까지 대기
    aws ec2 wait instance-running \
        --region "$region" \
        --instance-ids "$instance_id"
    
    log_success "인스턴스가 실행 중입니다"
}

# =============================================================================
# 인스턴스 중지
# =============================================================================
stop_instance() {
    local instance_id="${1:-}"
    local region="${2:-${REGION:-ap-northeast-2}}"
    
    if [ -z "$instance_id" ]; then
        log_error "인스턴스 ID를 지정해주세요."
        return 1
    fi
    
    log_step "인스턴스 중지"
    log_info "인스턴스 ID: $instance_id"
    
    aws ec2 stop-instances \
        --region "$region" \
        --instance-ids "$instance_id"
    
    log_success "인스턴스 중지 요청이 완료되었습니다"
}

# =============================================================================
# 인스턴스 종료
# =============================================================================
terminate_instance() {
    local instance_id="${1:-}"
    local region="${2:-${REGION:-ap-northeast-2}}"
    
    if [ -z "$instance_id" ]; then
        log_error "인스턴스 ID를 지정해주세요."
        return 1
    fi
    
    log_step "인스턴스 종료"
    log_info "인스턴스 ID: $instance_id"
    
    aws ec2 terminate-instances \
        --region "$region" \
        --instance-ids "$instance_id"
    
    log_success "인스턴스 종료 요청이 완료되었습니다"
}

# =============================================================================
# EC2 리소스 정리
# =============================================================================
cleanup() {
    local region="${1:-${REGION:-ap-northeast-2}}"
    
    log_step "EC2 리소스 정리 시작"
    log_info "리전: $region"
    
    # 실행 중인 인스턴스 종료
    log_info "실행 중인 인스턴스 종료 중..."
    local running_instances
    running_instances=$(aws ec2 describe-instances \
        --region "$region" \
        --filters "Name=instance-state-name,Values=running" \
        --query 'Reservations[*].Instances[*].InstanceId' \
        --output text)
    
    if [ -n "$running_instances" ]; then
        echo "$running_instances" | tr '\t' '\n' | while read -r instance_id; do
            if [ -n "$instance_id" ]; then
                log_info "인스턴스 종료: $instance_id"
                aws ec2 terminate-instances \
                    --region "$region" \
                    --instance-ids "$instance_id" >/dev/null
            fi
        done
    fi
    
    # 보안 그룹 삭제
    log_info "보안 그룹 삭제 중..."
    local security_groups
    security_groups=$(aws ec2 describe-security-groups \
        --region "$region" \
        --filters "Name=group-name,Values=mcp-cloud-sg" \
        --query 'SecurityGroups[*].GroupId' \
        --output text)
    
    if [ -n "$security_groups" ]; then
        echo "$security_groups" | tr '\t' '\n' | while read -r sg_id; do
            if [ -n "$sg_id" ]; then
                log_info "보안 그룹 삭제: $sg_id"
                aws ec2 delete-security-group \
                    --region "$region" \
                    --group-id "$sg_id" >/dev/null 2>&1 || true
            fi
        done
    fi
    
    # 키 페어 삭제
    log_info "키 페어 삭제 중..."
    local key_pairs
    key_pairs=$(aws ec2 describe-key-pairs \
        --region "$region" \
        --filters "Name=key-name,Values=mcp-cloud-key" \
        --query 'KeyPairs[*].KeyName' \
        --output text)
    
    if [ -n "$key_pairs" ]; then
        echo "$key_pairs" | tr '\t' '\n' | while read -r key_name; do
            if [ -n "$key_name" ]; then
                log_info "키 페어 삭제: $key_name"
                aws ec2 delete-key-pair \
                    --region "$region" \
                    --key-name "$key_name" >/dev/null 2>&1 || true
            fi
        done
    fi
    
    # 로컬 키 파일 삭제
    rm -f mcp-cloud-key.pem
    
    log_success "EC2 리소스 정리가 완료되었습니다"
}

# =============================================================================
# EC2 상태 확인
# =============================================================================
status() {
    local region="${1:-${REGION:-ap-northeast-2}}"
    
    log_step "EC2 상태 확인"
    log_info "리전: $region"
    
    # 인스턴스 상태
    log_info "=== 인스턴스 상태 ==="
    aws ec2 describe-instances \
        --region "$region" \
        --query 'Reservations[*].Instances[*].[InstanceId,State.Name,InstanceType,PublicIpAddress,Tags[?Key==`Name`].Value|[0]]' \
        --output table
    
    # 보안 그룹 상태
    log_info "=== 보안 그룹 상태 ==="
    aws ec2 describe-security-groups \
        --region "$region" \
        --filters "Name=group-name,Values=mcp-cloud-sg" \
        --query 'SecurityGroups[*].[GroupId,GroupName,Description]' \
        --output table
    
    # 키 페어 상태
    log_info "=== 키 페어 상태 ==="
    aws ec2 describe-key-pairs \
        --region "$region" \
        --filters "Name=key-name,Values=mcp-cloud-key" \
        --query 'KeyPairs[*].[KeyName,KeyPairId]' \
        --output table
}

# =============================================================================
# 메인 실행 로직
# =============================================================================
main() {
    # 환경 설정 로드
    load_environment
    
    # 인수 파싱
    local action=""
    local instance_name="mcp-cloud-instance"
    local instance_type="t3.medium"
    local key_name="mcp-cloud-key"
    local security_group=""
    local subnet_id="${SUBNET_ID:-}"
    local region="${REGION:-ap-northeast-2}"
    local instance_id=""
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --help|-h)
                usage
                exit 0
                ;;
            --action)
                action="$2"
                shift 2
                ;;
            --instance-name)
                instance_name="$2"
                shift 2
                ;;
            --instance-type)
                instance_type="$2"
                shift 2
                ;;
            --key-name)
                key_name="$2"
                shift 2
                ;;
            --security-group)
                security_group="$2"
                shift 2
                ;;
            --subnet-id)
                subnet_id="$2"
                shift 2
                ;;
            --region)
                region="$2"
                shift 2
                ;;
            --instance-id)
                instance_id="$2"
                shift 2
                ;;
            *)
                log_error "알 수 없는 옵션: $1"
                usage
                exit 1
                ;;
        esac
    done
    
    if [ -z "$action" ]; then
        log_error "액션을 지정해주세요."
        usage
        exit 1
    fi
    
    # 액션 실행
    case "$action" in
        "create-instance")
            create_instance "$instance_name" "$instance_type" "$key_name" "$security_group" "$subnet_id" "$region"
            ;;
        "create-security-group")
            create_security_group "mcp-cloud-sg" "$region"
            ;;
        "create-key-pair")
            create_key_pair "$key_name" "$region"
            ;;
        "start-instance")
            start_instance "$instance_id" "$region"
            ;;
        "stop-instance")
            stop_instance "$instance_id" "$region"
            ;;
        "terminate-instance")
            terminate_instance "$instance_id" "$region"
            ;;
        "list-instances")
            list_instances "$region"
            ;;
        "instance-status")
            instance_status "$instance_id" "$region"
            ;;
        "cleanup")
            cleanup "$region"
            ;;
        "status")
            status "$region"
            ;;
        *)
            log_error "알 수 없는 액션: $action"
            usage
            exit 1
            ;;
    esac
}

# =============================================================================
# 스크립트 실행
# =============================================================================
main "$@"
