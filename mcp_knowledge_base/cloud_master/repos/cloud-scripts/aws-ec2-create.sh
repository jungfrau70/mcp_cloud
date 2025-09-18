#!/bin/bash

# AWS EC2 가상머신 생성 스크립트
# MCP Cloud 프로젝트용 EC2 인스턴스 생성 및 설정

set -e  # 오류 발생 시 스크립트 종료

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 로그 함수
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 변수 설정 (필요에 따라 수정)
PROJECT_NAME="cloud-deployment"
REGION="ap-northeast-2"
AZ="ap-northeast-2a"
INSTANCE_TYPE="t3.medium"
AMI_ID="ami-0ae2c887094315bed"  # Amazon Linux 2
KEY_NAME="${PROJECT_NAME}-key"
SECURITY_GROUP_NAME="${PROJECT_NAME}-sg"
VPC_ID="vpc-0cda6aa4e12d0242b"
SUBNET_ID="subnet-0a711e414b1d0dede"

log_info "=== AWS EC2 가상머신 생성 시작 ==="
log_info "프로젝트명: $PROJECT_NAME"
log_info "리전: $REGION"
log_info "가용영역: $AZ"

# 체크포인트 파일 설정 (스크립트 중단 시 재시작 지원)
CHECKPOINT_FILE="${PROJECT_NAME}-checkpoint.txt"
log_info "체크포인트 파일: $CHECKPOINT_FILE"

# 체크포인트 함수
checkpoint() {
    echo "$1" > "$CHECKPOINT_FILE"
    log_info "체크포인트 저장: $1"
}

# 체크포인트 확인 함수
check_checkpoint() {
    if [ -f "$CHECKPOINT_FILE" ]; then
        local checkpoint=$(cat "$CHECKPOINT_FILE")
        log_info "이전 체크포인트 발견: $checkpoint"
        return 0
    fi
    return 1
}

# 체크포인트 삭제 함수
clear_checkpoint() {
    rm -f "$CHECKPOINT_FILE"
    log_info "체크포인트 삭제 완료"
}

# 체크포인트 기반 재시작 로직
if check_checkpoint; then
    local checkpoint=$(cat "$CHECKPOINT_FILE")
    log_info "이전 실행에서 중단된 지점을 발견했습니다: $checkpoint"
    log_info "중단된 지점부터 재시작합니다..."
    
    case "$checkpoint" in
        "aws_setup_complete"|"security_group_ready"|"key_pair_ready")
            log_info "AWS 설정이 완료되었습니다. 인스턴스 생성부터 재시작합니다."
            ;;
        "instance_created"|"instance_ready")
            log_info "인스턴스가 이미 생성되었습니다. 상태 확인부터 재시작합니다."
            ;;
        *)
            log_info "알 수 없는 체크포인트입니다. 처음부터 시작합니다."
            ;;
    esac
fi

# 1. AWS CLI 설정 확인
log_info "AWS CLI 설정 확인 중..."
if ! command -v aws &> /dev/null; then
    log_error "AWS CLI가 설치되지 않았습니다. 먼저 AWS CLI를 설치해주세요."
    exit 1
fi

if ! aws sts get-caller-identity &> /dev/null; then
    log_error "AWS 인증이 설정되지 않았습니다. 'aws configure'를 실행해주세요."
    exit 1
fi

log_success "AWS CLI 설정 확인 완료"
checkpoint "aws_setup_complete"

# 2. 기본 VPC 및 서브넷 확인
log_info "VPC 및 서브넷 정보 확인 중..."
if [ -z "$VPC_ID" ]; then
    VPC_ID=$(aws ec2 describe-vpcs --query 'Vpcs[?IsDefault==`true`].VpcId' --output text)
    if [ -z "$VPC_ID" ]; then
        log_error "기본 VPC를 찾을 수 없습니다."
        exit 1
    fi
fi

if [ -z "$SUBNET_ID" ]; then
    SUBNET_ID=$(aws ec2 describe-subnets --filters "Name=vpc-id,Values=$VPC_ID" --query 'Subnets[0].SubnetId' --output text)
    if [ -z "$SUBNET_ID" ]; then
        log_error "서브넷을 찾을 수 없습니다."
        exit 1
    fi
fi

log_success "VPC ID: $VPC_ID"
log_success "서브넷 ID: $SUBNET_ID"

# 3. 보안 그룹 생성 또는 확인
log_info "보안 그룹 확인 중..."
SECURITY_GROUP_ID=$(aws ec2 describe-security-groups \
    --filters "Name=group-name,Values=$SECURITY_GROUP_NAME" "Name=vpc-id,Values=$VPC_ID" \
    --query 'SecurityGroups[0].GroupId' --output text 2>/dev/null)

if [ -z "$SECURITY_GROUP_ID" ] || [ "$SECURITY_GROUP_ID" = "None" ]; then
    log_info "보안 그룹 생성 중..."
    SECURITY_GROUP_ID=$(aws ec2 create-security-group \
        --group-name $SECURITY_GROUP_NAME \
        --description "Security group for $PROJECT_NAME deployment" \
        --vpc-id $VPC_ID \
        --query 'GroupId' --output text)
    log_success "보안 그룹 생성 완료: $SECURITY_GROUP_ID"
else
    log_success "기존 보안 그룹 사용: $SECURITY_GROUP_ID"
fi
checkpoint "security_group_ready"

# 4. 보안 그룹 규칙 추가
log_info "보안 그룹 규칙 추가 중..."

# SSH (22)
if ! aws ec2 describe-security-groups --group-ids $SECURITY_GROUP_ID \
    --query 'SecurityGroups[0].IpPermissions[?FromPort==`22` && ToPort==`22`]' --output text | grep -q "22"; then
    aws ec2 authorize-security-group-ingress \
        --group-id $SECURITY_GROUP_ID \
        --protocol tcp \
        --port 22 \
        --cidr 0.0.0.0/0 > /dev/null
    log_info "SSH 규칙 추가 완료"
else
    log_info "SSH 규칙이 이미 존재합니다"
fi

# HTTP (80)
if ! aws ec2 describe-security-groups --group-ids $SECURITY_GROUP_ID \
    --query 'SecurityGroups[0].IpPermissions[?FromPort==`80` && ToPort==`80`]' --output text | grep -q "80"; then
    aws ec2 authorize-security-group-ingress \
        --group-id $SECURITY_GROUP_ID \
        --protocol tcp \
        --port 80 \
        --cidr 0.0.0.0/0 > /dev/null
    log_info "HTTP 규칙 추가 완료"
else
    log_info "HTTP 규칙이 이미 존재합니다"
fi

# HTTPS (443)
if ! aws ec2 describe-security-groups --group-ids $SECURITY_GROUP_ID \
    --query 'SecurityGroups[0].IpPermissions[?FromPort==`443` && ToPort==`443`]' --output text | grep -q "443"; then
    aws ec2 authorize-security-group-ingress \
        --group-id $SECURITY_GROUP_ID \
        --protocol tcp \
        --port 443 \
        --cidr 0.0.0.0/0 > /dev/null
    log_info "HTTPS 규칙 추가 완료"
else
    log_info "HTTPS 규칙이 이미 존재합니다"
fi

# 애플리케이션 포트 (3000)
if ! aws ec2 describe-security-groups --group-ids $SECURITY_GROUP_ID \
    --query 'SecurityGroups[0].IpPermissions[?FromPort==`3000` && ToPort==`3000`]' --output text | grep -q "3000"; then
    aws ec2 authorize-security-group-ingress \
        --group-id $SECURITY_GROUP_ID \
        --protocol tcp \
        --port 3000 \
        --cidr 0.0.0.0/0 > /dev/null
    log_info "포트 3000 규칙 추가 완료"
else
    log_info "포트 3000 규칙이 이미 존재합니다"
fi

# 애플리케이션 포트 (7000)
if ! aws ec2 describe-security-groups --group-ids $SECURITY_GROUP_ID \
    --query 'SecurityGroups[0].IpPermissions[?FromPort==`7000` && ToPort==`7000`]' --output text | grep -q "7000"; then
    aws ec2 authorize-security-group-ingress \
        --group-id $SECURITY_GROUP_ID \
        --protocol tcp \
        --port 7000 \
        --cidr 0.0.0.0/0 > /dev/null
    log_info "포트 7000 규칙 추가 완료"
else
    log_info "포트 7000 규칙이 이미 존재합니다"
fi

log_success "보안 그룹 규칙 확인 완료"

# 5. 키 페어 생성 및 확인
log_info "키 페어 확인 중..."
KEY_FILE="${KEY_NAME}.pem"

# 로컬 키 파일 존재 여부 확인
if [ -f "$KEY_FILE" ]; then
    log_success "기존 키 파일 발견: $KEY_FILE"
    log_info "기존 키 파일을 사용합니다."
    
    # 키 파일 권한 확인 및 수정
    chmod 400 "$KEY_FILE" 2>/dev/null || true
    
    # AWS에서 키 페어 존재 여부 확인
    if aws ec2 describe-key-pairs --key-names $KEY_NAME &> /dev/null; then
        log_success "AWS에서 키 페어가 확인되었습니다: $KEY_NAME"
    else
        log_warning "AWS에 키 페어가 없습니다. 키 페어를 생성합니다."
        aws ec2 create-key-pair \
            --key-name $KEY_NAME \
            --query 'KeyMaterial' \
            --output text > "$KEY_FILE"
        chmod 400 "$KEY_FILE"
        log_success "키 페어 생성 완료: $KEY_FILE"
    fi
else
    # 로컬 키 파일이 없으면 AWS에서 확인 후 생성
    if aws ec2 describe-key-pairs --key-names $KEY_NAME &> /dev/null; then
        log_warning "AWS에 키 페어가 있지만 로컬 파일이 없습니다."
        log_info "AWS에서 키 페어를 다운로드할 수 없으므로 새로 생성합니다."
        aws ec2 delete-key-pair --key-name $KEY_NAME
    fi
    
    log_info "키 페어 생성 중..."
    aws ec2 create-key-pair \
        --key-name $KEY_NAME \
        --query 'KeyMaterial' \
        --output text > "$KEY_FILE"
    chmod 400 "$KEY_FILE"
    log_success "키 페어 생성 완료: $KEY_FILE"
fi
checkpoint "key_pair_ready"

# 6. user-data 스크립트 확인
USER_DATA_FILE="user-data.sh"
if [ ! -f "$USER_DATA_FILE" ]; then
    log_warning "user-data.sh 파일이 없습니다. 기본 설정으로 진행합니다."
    USER_DATA_FILE=""
fi

# 7. EC2 인스턴스 생성 또는 확인
log_info "EC2 인스턴스 확인 중..."
INSTANCE_ID=$(aws ec2 describe-instances \
    --filters "Name=tag:Name,Values=${PROJECT_NAME}-server" "Name=instance-state-name,Values=running,pending,stopping,stopped" \
    --query 'Reservations[0].Instances[0].InstanceId' --output text 2>/dev/null)

if [ -z "$INSTANCE_ID" ] || [ "$INSTANCE_ID" = "None" ]; then
    log_info "EC2 인스턴스 생성 중..."
    
    INSTANCE_CMD="aws ec2 run-instances \
        --image-id $AMI_ID \
        --count 1 \
        --instance-type $INSTANCE_TYPE \
        --key-name $KEY_NAME \
        --security-group-ids $SECURITY_GROUP_ID \
        --subnet-id $SUBNET_ID \
        --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=${PROJECT_NAME}-server},{Key=Environment,Value=production},{Key=Project,Value=${PROJECT_NAME}}]'"

    if [ -n "$USER_DATA_FILE" ]; then
        INSTANCE_CMD="$INSTANCE_CMD --user-data file://$USER_DATA_FILE"
    fi

    INSTANCE_ID=$(eval $INSTANCE_CMD --query 'Instances[0].InstanceId' --output text)
    log_success "EC2 인스턴스 생성 완료: $INSTANCE_ID"
    checkpoint "instance_created"
else
    log_success "기존 EC2 인스턴스 사용: $INSTANCE_ID"
    
    # 인스턴스 상태 확인 및 복구
    INSTANCE_STATE=$(aws ec2 describe-instances \
        --instance-ids $INSTANCE_ID \
        --query 'Reservations[0].Instances[0].State.Name' --output text)
    
    log_info "인스턴스 상태: $INSTANCE_STATE"
    
    # 인스턴스 상태에 따른 처리
    case "$INSTANCE_STATE" in
        "stopped")
            log_info "중지된 인스턴스를 시작 중..."
            aws ec2 start-instances --instance-ids $INSTANCE_ID > /dev/null
            aws ec2 wait instance-running --instance-ids $INSTANCE_ID
            log_success "인스턴스 시작 완료"
            ;;
        "stopping")
            log_info "인스턴스가 중지 중입니다. 완료될 때까지 대기..."
            aws ec2 wait instance-stopped --instance-ids $INSTANCE_ID
            log_info "인스턴스 시작 중..."
            aws ec2 start-instances --instance-ids $INSTANCE_ID > /dev/null
            aws ec2 wait instance-running --instance-ids $INSTANCE_ID
            log_success "인스턴스 시작 완료"
            ;;
        "pending")
            log_info "인스턴스가 시작 중입니다. 완료될 때까지 대기..."
            aws ec2 wait instance-running --instance-ids $INSTANCE_ID
            log_success "인스턴스 시작 완료"
            ;;
        "running")
            log_success "인스턴스가 이미 실행 중입니다"
            ;;
        "terminated")
            log_error "인스턴스가 종료되었습니다. 새로 생성해야 합니다."
            INSTANCE_ID=""
            ;;
        *)
            log_warning "알 수 없는 인스턴스 상태: $INSTANCE_STATE"
            log_info "인스턴스 시작을 시도합니다..."
            aws ec2 start-instances --instance-ids $INSTANCE_ID > /dev/null || true
            ;;
    esac
    checkpoint "instance_ready"
fi

# 8. 인스턴스 시작 대기
log_info "인스턴스 시작 대기 중..."
aws ec2 wait instance-running --instance-ids $INSTANCE_ID
log_success "인스턴스가 실행 중입니다"

# 9. 인스턴스 정보 조회
log_info "인스턴스 정보 조회 중..."
PUBLIC_IP=$(aws ec2 describe-instances \
    --instance-ids $INSTANCE_ID \
    --query 'Reservations[0].Instances[0].PublicIpAddress' --output text)

PRIVATE_IP=$(aws ec2 describe-instances \
    --instance-ids $INSTANCE_ID \
    --query 'Reservations[0].Instances[0].PrivateIpAddress' --output text)

# 10. 결과 출력
echo ""
log_success "=== EC2 인스턴스 생성 완료 ==="
echo "인스턴스 ID: $INSTANCE_ID"
echo "퍼블릭 IP: $PUBLIC_IP"
echo "프라이빗 IP: $PRIVATE_IP"
echo "보안 그룹 ID: $SECURITY_GROUP_ID"
echo "키 페어: $KEY_NAME"
echo ""

# 11. 연결 명령어 출력
if [ -n "$PUBLIC_IP" ]; then
    log_info "SSH 연결 명령어:"
    echo "ssh -i ${KEY_NAME}.pem ec2-user@$PUBLIC_IP"
    echo ""
fi

# 12. Elastic IP 할당 옵션
read -p "Elastic IP를 할당하시겠습니까? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    # 기존 Elastic IP 확인
    EXISTING_EIP=$(aws ec2 describe-addresses \
        --filters "Name=instance-id,Values=$INSTANCE_ID" \
        --query 'Addresses[0].PublicIp' --output text 2>/dev/null)
    
    if [ -n "$EXISTING_EIP" ] && [ "$EXISTING_EIP" != "None" ]; then
        log_success "기존 Elastic IP 사용: $EXISTING_EIP"
        echo "Elastic IP: $EXISTING_EIP"
        echo "SSH 연결 명령어: ssh -i ${KEY_NAME}.pem ec2-user@$EXISTING_EIP"
    else
        log_info "Elastic IP 할당 중..."
        ALLOCATION_ID=$(aws ec2 allocate-address --domain vpc --query 'AllocationId' --output text)
        aws ec2 associate-address \
            --instance-id $INSTANCE_ID \
            --allocation-id $ALLOCATION_ID > /dev/null
        
        ELASTIC_IP=$(aws ec2 describe-addresses \
            --allocation-ids $ALLOCATION_ID \
            --query 'Addresses[0].PublicIp' --output text)
        
        log_success "Elastic IP 할당 완료: $ELASTIC_IP"
        echo "Elastic IP: $ELASTIC_IP"
        echo "SSH 연결 명령어: ssh -i ${KEY_NAME}.pem ec2-user@$ELASTIC_IP"
    fi
fi

log_success "=== 스크립트 실행 완료 ==="
clear_checkpoint
echo ""
log_info "다음 단계:"
echo "1. SSH로 인스턴스에 연결"
echo "2. 애플리케이션 배포"
echo "3. 도메인 설정 (필요한 경우)"
echo ""
log_warning "💰 비용 절약을 위해 사용하지 않을 때는 인스턴스를 중지하세요:"
echo "aws ec2 stop-instances --instance-ids $INSTANCE_ID"
echo ""
log_warning "🗑️ 리소스 정리:"
echo "전체 리소스 정리: ./aws-resource-cleanup.sh"
echo "인스턴스만 삭제: aws ec2 terminate-instances --instance-ids $INSTANCE_ID"
