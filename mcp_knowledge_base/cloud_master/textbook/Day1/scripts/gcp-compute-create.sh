#!/bin/bash

# GCP Compute Engine 가상머신 생성 스크립트
# MCP Cloud 프로젝트용 GCE 인스턴스 생성 및 설정

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
PROJECT_ID=""
REGION="asia-northeast3"
ZONE="asia-northeast3-a"
MACHINE_TYPE="e2-medium"
IMAGE_FAMILY="ubuntu-2204-lts"
IMAGE_PROJECT="ubuntu-os-cloud"
INSTANCE_NAME="${PROJECT_NAME}-server"
NETWORK_NAME="${PROJECT_NAME}-vpc"
SUBNET_NAME="${PROJECT_NAME}-subnet"
FIREWALL_RULE_SSH="${PROJECT_NAME}-allow-ssh"
FIREWALL_RULE_HTTP="${PROJECT_NAME}-allow-http"
FIREWALL_RULE_HTTPS="${PROJECT_NAME}-allow-https"
FIREWALL_RULE_APP="${PROJECT_NAME}-allow-app"

log_info "=== GCP Compute Engine 가상머신 생성 시작 ==="
log_info "프로젝트명: $PROJECT_NAME"
log_info "리전: $REGION"
log_info "존: $ZONE"

# 1. GCP CLI 설정 확인
log_info "GCP CLI 설정 확인 중..."
if ! command -v gcloud &> /dev/null; then
    log_error "Google Cloud CLI가 설치되지 않았습니다. 먼저 gcloud CLI를 설치해주세요."
    exit 1
fi

if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" | grep -q .; then
    log_error "GCP 인증이 설정되지 않았습니다. 'gcloud auth login'을 실행해주세요."
    exit 1
fi

# 프로젝트 ID 확인
if [ -z "$PROJECT_ID" ]; then
    PROJECT_ID=$(gcloud config get-value project 2>/dev/null)
    if [ -z "$PROJECT_ID" ]; then
        log_error "GCP 프로젝트가 설정되지 않았습니다. 'gcloud config set project PROJECT_ID'를 실행해주세요."
        exit 1
    fi
fi

log_success "GCP CLI 설정 확인 완료"
log_success "프로젝트 ID: $PROJECT_ID"

# 2. 프로젝트 설정
log_info "프로젝트 설정 중..."
gcloud config set project $PROJECT_ID
gcloud config set compute/region $REGION
gcloud config set compute/zone $ZONE

# 3. VPC 네트워크 생성 (기본 네트워크가 아닌 경우)
log_info "VPC 네트워크 확인 중..."
if ! gcloud compute networks describe $NETWORK_NAME &> /dev/null; then
    log_info "VPC 네트워크 생성 중..."
    gcloud compute networks create $NETWORK_NAME --subnet-mode custom
    log_success "VPC 네트워크 생성 완료: $NETWORK_NAME"
else
    log_warning "VPC 네트워크가 이미 존재합니다: $NETWORK_NAME"
fi

# 4. 서브넷 생성
log_info "서브넷 확인 중..."
if ! gcloud compute networks subnets describe $SUBNET_NAME --region=$REGION &> /dev/null; then
    log_info "서브넷 생성 중..."
    gcloud compute networks subnets create $SUBNET_NAME \
        --network $NETWORK_NAME \
        --range 10.0.0.0/24 \
        --region $REGION
    log_success "서브넷 생성 완료: $SUBNET_NAME"
else
    log_warning "서브넷이 이미 존재합니다: $SUBNET_NAME"
fi

# 5. 방화벽 규칙 생성
log_info "방화벽 규칙 확인 중..."

# SSH 규칙
if ! gcloud compute firewall-rules describe $FIREWALL_RULE_SSH &> /dev/null; then
    log_info "SSH 방화벽 규칙 생성 중..."
    gcloud compute firewall-rules create $FIREWALL_RULE_SSH \
        --network $NETWORK_NAME \
        --allow tcp:22 \
        --source-ranges 0.0.0.0/0 \
        --description "Allow SSH access"
    log_success "SSH 방화벽 규칙 생성 완료"
fi

# HTTP 규칙
if ! gcloud compute firewall-rules describe $FIREWALL_RULE_HTTP &> /dev/null; then
    log_info "HTTP 방화벽 규칙 생성 중..."
    gcloud compute firewall-rules create $FIREWALL_RULE_HTTP \
        --network $NETWORK_NAME \
        --allow tcp:80 \
        --source-ranges 0.0.0.0/0 \
        --description "Allow HTTP access"
    log_success "HTTP 방화벽 규칙 생성 완료"
fi

# HTTPS 규칙
if ! gcloud compute firewall-rules describe $FIREWALL_RULE_HTTPS &> /dev/null; then
    log_info "HTTPS 방화벽 규칙 생성 중..."
    gcloud compute firewall-rules create $FIREWALL_RULE_HTTPS \
        --network $NETWORK_NAME \
        --allow tcp:443 \
        --source-ranges 0.0.0.0/0 \
        --description "Allow HTTPS access"
    log_success "HTTPS 방화벽 규칙 생성 완료"
fi

# 애플리케이션 포트 규칙
if ! gcloud compute firewall-rules describe $FIREWALL_RULE_APP &> /dev/null; then
    log_info "애플리케이션 포트 방화벽 규칙 생성 중..."
    gcloud compute firewall-rules create $FIREWALL_RULE_APP \
        --network $NETWORK_NAME \
        --allow tcp:3000,tcp:7000 \
        --source-ranges 0.0.0.0/0 \
        --description "Allow application ports"
    log_success "애플리케이션 포트 방화벽 규칙 생성 완료"
fi

# 6. SSH 키 설정
log_info "SSH 키 설정 중..."
if [ -f ~/.ssh/id_rsa.pub ]; then
    gcloud compute os-login ssh-keys add --key-file ~/.ssh/id_rsa.pub --project $PROJECT_ID > /dev/null 2>&1 || true
    log_success "SSH 키 설정 완료"
else
    log_warning "SSH 공개키가 없습니다. SSH 키를 생성해주세요: ssh-keygen -t rsa -b 4096"
fi

# 7. startup-script 확인
STARTUP_SCRIPT_FILE="startup-script.sh"
if [ ! -f "$STARTUP_SCRIPT_FILE" ]; then
    log_warning "startup-script.sh 파일이 없습니다. 기본 설정으로 진행합니다."
    STARTUP_SCRIPT_FILE=""
fi

# 8. Compute Engine 인스턴스 생성
log_info "Compute Engine 인스턴스 생성 중..."

INSTANCE_CMD="gcloud compute instances create $INSTANCE_NAME \
    --zone=$ZONE \
    --machine-type=$MACHINE_TYPE \
    --network-interface=network-tier=PREMIUM,subnet=$SUBNET_NAME \
    --maintenance-policy=MIGRATE \
    --provisioning-model=STANDARD \
    --scopes=https://www.googleapis.com/auth/cloud-platform \
    --create-disk=auto-delete=yes,boot=yes,device-name=$INSTANCE_NAME,image-family=$IMAGE_FAMILY,image-project=$IMAGE_PROJECT,mode=rw,size=20,type=projects/$PROJECT_ID/zones/$ZONE/diskTypes/pd-standard \
    --tags=$PROJECT_NAME"

if [ -n "$STARTUP_SCRIPT_FILE" ]; then
    INSTANCE_CMD="$INSTANCE_CMD --metadata-from-file startup-script=$STARTUP_SCRIPT_FILE"
fi

eval $INSTANCE_CMD

log_success "Compute Engine 인스턴스 생성 완료: $INSTANCE_NAME"

# 9. 인스턴스 정보 조회
log_info "인스턴스 정보 조회 중..."
EXTERNAL_IP=$(gcloud compute instances describe $INSTANCE_NAME --zone=$ZONE --format="get(networkInterfaces[0].accessConfigs[0].natIP)")
INTERNAL_IP=$(gcloud compute instances describe $INSTANCE_NAME --zone=$ZONE --format="get(networkInterfaces[0].networkIP)")

# 10. 결과 출력
echo ""
log_success "=== Compute Engine 인스턴스 생성 완료 ==="
echo "인스턴스 이름: $INSTANCE_NAME"
echo "외부 IP: $EXTERNAL_IP"
echo "내부 IP: $INTERNAL_IP"
echo "네트워크: $NETWORK_NAME"
echo "서브넷: $SUBNET_NAME"
echo ""

# 11. 연결 명령어 출력
if [ -n "$EXTERNAL_IP" ]; then
    log_info "SSH 연결 명령어:"
    echo "gcloud compute ssh $INSTANCE_NAME --zone=$ZONE"
    echo "또는"
    echo "ssh $USER@$EXTERNAL_IP"
    echo ""
fi

# 12. 정적 IP 할당 옵션
read -p "정적 IP를 할당하시겠습니까? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    log_info "정적 IP 할당 중..."
    STATIC_IP_NAME="${PROJECT_NAME}-ip"
    gcloud compute addresses create $STATIC_IP_NAME --region=$REGION
    STATIC_IP=$(gcloud compute addresses describe $STATIC_IP_NAME --region=$REGION --format="get(address)")
    
    gcloud compute instances add-access-config $INSTANCE_NAME \
        --zone=$ZONE \
        --address=$STATIC_IP > /dev/null
    
    log_success "정적 IP 할당 완료: $STATIC_IP"
    echo "정적 IP: $STATIC_IP"
    echo "SSH 연결 명령어: gcloud compute ssh $INSTANCE_NAME --zone=$ZONE"
fi

log_success "=== 스크립트 실행 완료 ==="
echo ""
log_info "다음 단계:"
echo "1. SSH로 인스턴스에 연결"
echo "2. 애플리케이션 배포"
echo "3. 도메인 설정 (필요한 경우)"
echo ""
log_warning "비용 절약을 위해 사용하지 않을 때는 인스턴스를 중지하세요:"
echo "gcloud compute instances stop $INSTANCE_NAME --zone=$ZONE"
echo ""
log_warning "인스턴스 삭제 시:"
echo "gcloud compute instances delete $INSTANCE_NAME --zone=$ZONE --quiet"
