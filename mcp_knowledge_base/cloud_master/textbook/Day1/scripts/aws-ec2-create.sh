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
PROJECT_NAME="mcp-cloud"
REGION="ap-northeast-2"
AZ="ap-northeast-2a"
INSTANCE_TYPE="t3.medium"
AMI_ID="ami-0c02fb55956c7d316"  # Amazon Linux 2
KEY_NAME="${PROJECT_NAME}-key"
SECURITY_GROUP_NAME="${PROJECT_NAME}-sg"
VPC_ID=""
SUBNET_ID=""

log_info "=== AWS EC2 가상머신 생성 시작 ==="
log_info "프로젝트명: $PROJECT_NAME"
log_info "리전: $REGION"
log_info "가용영역: $AZ"

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

# 3. 보안 그룹 생성
log_info "보안 그룹 생성 중..."
SECURITY_GROUP_ID=$(aws ec2 create-security-group \
    --group-name $SECURITY_GROUP_NAME \
    --description "Security group for $PROJECT_NAME deployment" \
    --vpc-id $VPC_ID \
    --query 'GroupId' --output text)

log_success "보안 그룹 생성 완료: $SECURITY_GROUP_ID"

# 4. 보안 그룹 규칙 추가
log_info "보안 그룹 규칙 추가 중..."

# SSH (22)
aws ec2 authorize-security-group-ingress \
    --group-id $SECURITY_GROUP_ID \
    --protocol tcp \
    --port 22 \
    --cidr 0.0.0.0/0 > /dev/null

# HTTP (80)
aws ec2 authorize-security-group-ingress \
    --group-id $SECURITY_GROUP_ID \
    --protocol tcp \
    --port 80 \
    --cidr 0.0.0.0/0 > /dev/null

# HTTPS (443)
aws ec2 authorize-security-group-ingress \
    --group-id $SECURITY_GROUP_ID \
    --protocol tcp \
    --port 443 \
    --cidr 0.0.0.0/0 > /dev/null

# 애플리케이션 포트 (3000, 7000)
aws ec2 authorize-security-group-ingress \
    --group-id $SECURITY_GROUP_ID \
    --protocol tcp \
    --port 3000 \
    --cidr 0.0.0.0/0 > /dev/null

aws ec2 authorize-security-group-ingress \
    --group-id $SECURITY_GROUP_ID \
    --protocol tcp \
    --port 7000 \
    --cidr 0.0.0.0/0 > /dev/null

log_success "보안 그룹 규칙 추가 완료"

# 5. 키 페어 생성 (없는 경우)
log_info "키 페어 확인 중..."
if ! aws ec2 describe-key-pairs --key-names $KEY_NAME &> /dev/null; then
    log_info "키 페어 생성 중..."
    aws ec2 create-key-pair \
        --key-name $KEY_NAME \
        --query 'KeyMaterial' \
        --output text > ${KEY_NAME}.pem
    chmod 400 ${KEY_NAME}.pem
    log_success "키 페어 생성 완료: ${KEY_NAME}.pem"
else
    log_warning "키 페어가 이미 존재합니다: $KEY_NAME"
fi

# 6. user-data 스크립트 확인
USER_DATA_FILE="user-data.sh"
if [ ! -f "$USER_DATA_FILE" ]; then
    log_warning "user-data.sh 파일이 없습니다. 기본 설정으로 진행합니다."
    USER_DATA_FILE=""
fi

# 7. EC2 인스턴스 생성
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

log_success "=== 스크립트 실행 완료 ==="
echo ""
log_info "다음 단계:"
echo "1. SSH로 인스턴스에 연결"
echo "2. 애플리케이션 배포"
echo "3. 도메인 설정 (필요한 경우)"
echo ""
log_warning "비용 절약을 위해 사용하지 않을 때는 인스턴스를 중지하세요:"
echo "aws ec2 stop-instances --instance-ids $INSTANCE_ID"
echo ""
log_warning "인스턴스 삭제 시:"
echo "aws ec2 terminate-instances --instance-ids $INSTANCE_ID"
