#!/bin/bash

# AWS & GCP 통합 설정 스크립트
# Cloud Basic 과정용 통합 환경 설정

set -e

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

echo "=== Cloud Basic 환경 설정 시작 ==="
echo ""

# 1. AWS CLI 설치 확인
log_info "AWS CLI 설치 확인 중..."
if ! command -v aws &> /dev/null; then
    log_error "AWS CLI가 설치되지 않았습니다."
    log_info "다음 명령어로 설치하세요:"
    echo "  Windows: winget install Amazon.AWSCLI"
    echo "  macOS: brew install awscli"
    echo "  Ubuntu: sudo apt install awscli"
    exit 1
fi

# 2. gcloud CLI 설치 확인
log_info "Google Cloud SDK 설치 확인 중..."
if ! command -v gcloud &> /dev/null; then
    log_error "Google Cloud SDK가 설치되지 않았습니다."
    log_info "다음 명령어로 설치하세요:"
    echo "  Windows: winget install Google.CloudSDK"
    echo "  macOS: brew install google-cloud-sdk"
    echo "  Ubuntu: curl https://sdk.cloud.google.com | bash"
    exit 1
fi

# 3. Git 설치 확인
log_info "Git 설치 확인 중..."
if ! command -v git &> /dev/null; then
    log_error "Git이 설치되지 않았습니다."
    log_info "다음 명령어로 설치하세요:"
    echo "  Windows: winget install Git.Git"
    echo "  macOS: brew install git"
    echo "  Ubuntu: sudo apt install git"
    exit 1
fi

# 4. AWS 인증 확인
log_info "AWS 인증 상태 확인 중..."
if ! aws sts get-caller-identity &> /dev/null; then
    log_warning "AWS 인증이 설정되지 않았습니다."
    log_info "다음 명령어로 인증하세요:"
    echo "aws configure"
    echo "또는"
    echo "aws sso login"
    exit 1
fi

# 5. GCP 인증 확인
log_info "GCP 인증 상태 확인 중..."
if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" | grep -q .; then
    log_warning "GCP 인증이 설정되지 않았습니다."
    log_info "다음 명령어로 인증하세요:"
    echo "gcloud auth login"
    exit 1
fi

# 6. GCP 프로젝트 확인
log_info "GCP 프로젝트 설정 확인 중..."
PROJECT_ID=$(gcloud config get-value project 2>/dev/null)
if [ -z "$PROJECT_ID" ]; then
    log_warning "GCP 프로젝트가 설정되지 않았습니다."
    log_info "다음 명령어로 프로젝트를 설정하세요:"
    echo "gcloud config set project YOUR_PROJECT_ID"
    exit 1
fi

# 7. 환경 변수 설정
log_info "환경 변수 설정 중..."
export AWS_DEFAULT_REGION="ap-northeast-2"
export GCP_REGION="asia-northeast3"
export GCP_ZONE="asia-northeast3-a"

# 8. 실습 디렉토리 생성
log_info "실습 디렉토리 생성 중..."
mkdir -p cloud-basic-practice
cd cloud-basic-practice

# 9. 키 파일 생성
log_info "SSH 키 생성 중..."
if [ ! -f "cloud-basic-key.pem" ]; then
    ssh-keygen -t rsa -b 4096 -f cloud-basic-key -N ""
    log_success "SSH 키가 생성되었습니다: cloud-basic-key.pem"
else
    log_info "SSH 키가 이미 존재합니다."
fi

# 10. 설정 파일 생성
log_info "설정 파일 생성 중..."
cat > aws-config.env << EOF
# AWS 설정
AWS_DEFAULT_REGION=ap-northeast-2
AWS_AVAILABILITY_ZONE=ap-northeast-2a
AWS_INSTANCE_TYPE=t3.micro
AWS_AMI_ID=ami-0c76973fbe0ee100c
AWS_KEY_NAME=cloud-basic-key
AWS_SECURITY_GROUP_NAME=cloud-basic-sg
EOF

cat > gcp-config.env << EOF
# GCP 설정
GCP_PROJECT_ID=$PROJECT_ID
GCP_REGION=asia-northeast3
GCP_ZONE=asia-northeast3-a
GCP_MACHINE_TYPE=e2-micro
GCP_IMAGE_FAMILY=ubuntu-2204-lts
GCP_IMAGE_PROJECT=ubuntu-os-cloud
EOF

# 11. 실습 스크립트 생성
log_info "실습 스크립트 생성 중..."
cat > aws-setup.sh << 'EOF'
#!/bin/bash
source aws-config.env

# AWS EC2 인스턴스 생성
aws ec2 create-key-pair \
  --key-name $AWS_KEY_NAME \
  --query 'KeyMaterial' \
  --output text > $AWS_KEY_NAME.pem

chmod 400 $AWS_KEY_NAME.pem

# 보안 그룹 생성
aws ec2 create-security-group \
  --group-name $AWS_SECURITY_GROUP_NAME \
  --description "Security group for cloud basic practice"

# 보안 그룹 규칙 추가
aws ec2 authorize-security-group-ingress \
  --group-name $AWS_SECURITY_GROUP_NAME \
  --protocol tcp \
  --port 22 \
  --cidr 0.0.0.0/0

aws ec2 authorize-security-group-ingress \
  --group-name $AWS_SECURITY_GROUP_NAME \
  --protocol tcp \
  --port 80 \
  --cidr 0.0.0.0/0

# EC2 인스턴스 시작
aws ec2 run-instances \
  --image-id $AWS_AMI_ID \
  --count 1 \
  --instance-type $AWS_INSTANCE_TYPE \
  --key-name $AWS_KEY_NAME \
  --security-groups $AWS_SECURITY_GROUP_NAME \
  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=cloud-basic-server}]'

echo "AWS EC2 인스턴스가 생성되었습니다."
EOF

cat > gcp-setup.sh << 'EOF'
#!/bin/bash
source gcp-config.env

# 방화벽 규칙 생성
gcloud compute firewall-rules create allow-ssh-http \
  --allow tcp:22,tcp:80,tcp:443 \
  --source-ranges 0.0.0.0/0 \
  --description "Allow SSH, HTTP, and HTTPS traffic"

# Compute Engine 인스턴스 생성
gcloud compute instances create cloud-basic-server \
  --zone=$GCP_ZONE \
  --machine-type=$GCP_MACHINE_TYPE \
  --image-family=$GCP_IMAGE_FAMILY \
  --image-project=$GCP_IMAGE_PROJECT \
  --tags=web-server

echo "GCP Compute Engine 인스턴스가 생성되었습니다."
EOF

chmod +x aws-setup.sh gcp-setup.sh

# 12. 정리 스크립트 생성
log_info "정리 스크립트 생성 중..."
cat > cleanup.sh << 'EOF'
#!/bin/bash

# AWS 리소스 정리
aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=cloud-basic-server" \
  --query 'Reservations[*].Instances[*].InstanceId' \
  --output text | xargs -I {} aws ec2 terminate-instances --instance-ids {}

aws ec2 delete-security-group --group-name cloud-basic-sg
aws ec2 delete-key-pair --key-name cloud-basic-key

# GCP 리소스 정리
gcloud compute instances delete cloud-basic-server --zone=asia-northeast3-a --quiet
gcloud compute firewall-rules delete allow-ssh-http --quiet

echo "모든 리소스가 정리되었습니다."
EOF

chmod +x cleanup.sh

# 13. 완료 메시지
log_success "Cloud Basic 환경 설정이 완료되었습니다!"
echo ""
echo "📁 실습 디렉토리: $(pwd)"
echo "🔑 SSH 키: cloud-basic-key.pem"
echo "⚙️  AWS 설정: aws-config.env"
echo "⚙️  GCP 설정: gcp-config.env"
echo ""
echo "🚀 다음 단계:"
echo "1. ./aws-setup.sh 실행 (AWS 환경 구축)"
echo "2. ./gcp-setup.sh 실행 (GCP 환경 구축)"
echo "3. 실습 완료 후 ./cleanup.sh 실행 (리소스 정리)"
echo ""
echo "📚 실습 가이드:"
echo "- AWS 실습: ../practice/aws_basic_practice.md"
echo "- GCP 실습: ../practice/gcp_basic_practice.md"
echo "- 종합 실습: ../practice/실습1_aws_gcp.md"
