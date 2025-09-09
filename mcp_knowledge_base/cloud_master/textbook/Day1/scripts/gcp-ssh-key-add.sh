#!/bin/bash

# GCP VM에 SSH 키 추가 스크립트
# 기존 VM 인스턴스에 SSH 키를 메타데이터로 추가

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

# 변수 설정
PROJECT_NAME="cloud-deployment"
PROJECT_ID="cloud-deployment-2025-12345"
REGION="asia-northeast3"
ZONE="asia-northeast3-a"
INSTANCE_NAME="${PROJECT_NAME}-server"
KEY_FILE="${PROJECT_NAME}-key"
PUBLIC_KEY_FILE="${KEY_FILE}.pub"

# 사용자 이름 설정
CURRENT_USER=$(gcloud config get-value account 2>/dev/null)
if [ -n "$CURRENT_USER" ]; then
    USER="$CURRENT_USER"  # GCP OS Login 사용자 (Google 계정 이메일)
else
    USER="ubuntu"  # 기본 Ubuntu 사용자
fi

log_info "=== GCP VM에 SSH 키 추가 시작 ==="
log_info "프로젝트명: $PROJECT_NAME"
log_info "인스턴스명: $INSTANCE_NAME"
log_info "사용자명: $USER"

# 1. GCP CLI 설정 확인
log_info "GCP CLI 설정 확인 중..."
if ! command -v gcloud &> /dev/null; then
    log_error "Google Cloud CLI가 설치되지 않았습니다. 먼저 gcloud CLI를 설치해주세요."
    exit 1
fi

# GCP 인증 확인
if ! gcloud auth list > /dev/null 2>&1; then
    log_error "GCP 인증이 설정되지 않았습니다. 'gcloud auth login'을 실행해주세요."
    exit 1
fi

# 프로젝트 설정
log_info "프로젝트 설정 중..."
gcloud config set project $PROJECT_ID > /dev/null 2>&1
if [ $? -eq 0 ]; then
    log_success "프로젝트 설정 완료: $PROJECT_ID"
else
    log_error "프로젝트 설정 실패: $PROJECT_ID"
    exit 1
fi

# 2. 인스턴스 존재 확인
log_info "인스턴스 존재 확인 중..."
if ! gcloud compute instances describe $INSTANCE_NAME --zone=$ZONE &> /dev/null; then
    log_error "인스턴스 '$INSTANCE_NAME'이 존재하지 않습니다."
    log_info "사용 가능한 인스턴스 목록:"
    gcloud compute instances list --format="table(name,zone,status)" || true
    exit 1
fi

# 3. SSH 키 파일 확인
log_info "SSH 키 파일 확인 중..."
if [ ! -f "$PUBLIC_KEY_FILE" ]; then
    log_error "공개키 파일 '$PUBLIC_KEY_FILE'이 존재하지 않습니다."
    log_info "다음 명령어로 SSH 키를 생성하세요:"
    echo "ssh-keygen -t rsa -b 4096 -f $KEY_FILE -N \"\" -C \"${PROJECT_NAME}-key\""
    exit 1
fi

# 공개키 파일 유효성 검사
if ! ssh-keygen -l -f "$PUBLIC_KEY_FILE" > /dev/null 2>&1; then
    log_error "공개키 파일 '$PUBLIC_KEY_FILE'이 손상되었습니다."
    exit 1
fi

log_success "SSH 키 파일 확인 완료"

# 4. SSH 키 내용 읽기
SSH_KEY_CONTENT=$(cat "$PUBLIC_KEY_FILE")
log_info "SSH 키 내용:"
echo "$SSH_KEY_CONTENT"
echo ""

# 5. 인스턴스 메타데이터에 SSH 키 추가
log_info "인스턴스 메타데이터에 SSH 키 추가 중..."
if gcloud compute instances add-metadata $INSTANCE_NAME --zone=$ZONE --metadata "ssh-keys=$USER:$SSH_KEY_CONTENT" > /dev/null 2>&1; then
    log_success "SSH 키가 인스턴스 메타데이터에 추가되었습니다"
else
    log_error "SSH 키 추가에 실패했습니다"
    exit 1
fi

# 6. OS Login에도 SSH 키 추가 (선택사항)
log_info "GCP OS Login에 SSH 키 추가 중..."
if gcloud compute os-login ssh-keys add --key-file "$PUBLIC_KEY_FILE" --project $PROJECT_ID > /dev/null 2>&1; then
    log_success "SSH 키가 GCP OS Login에 추가되었습니다"
else
    log_warning "SSH 키 추가에 실패했거나 이미 존재합니다"
fi

# 7. 인스턴스 정보 조회
log_info "인스턴스 정보 조회 중..."
EXTERNAL_IP=$(gcloud compute instances describe $INSTANCE_NAME --zone=$ZONE --format="get(networkInterfaces[0].accessConfigs[0].natIP)")
INTERNAL_IP=$(gcloud compute instances describe $INSTANCE_NAME --zone=$ZONE --format="get(networkInterfaces[0].networkIP)")
INSTANCE_STATUS=$(gcloud compute instances describe $INSTANCE_NAME --zone=$ZONE --format="get(status)")

# 8. 결과 출력
echo ""
log_success "=== SSH 키 추가 완료 ==="
echo "인스턴스 이름: $INSTANCE_NAME"
echo "외부 IP: $EXTERNAL_IP"
echo "내부 IP: $INTERNAL_IP"
echo "인스턴스 상태: $INSTANCE_STATUS"
echo ""

# 9. 연결 명령어 출력
if [ -n "$EXTERNAL_IP" ]; then
    log_info "SSH 연결 명령어:"
    echo "1. gcloud 명령어 (권장 - OS Login 사용):"
    echo "   gcloud compute ssh $INSTANCE_NAME --zone=$ZONE"
    echo ""
    echo "2. 일반 SSH 명령어 (메타데이터 SSH 키 사용):"
    echo "   ssh -i $KEY_FILE $USER@$EXTERNAL_IP"
    echo ""
    echo "3. SSH 키 파일 확인:"
    echo "   개인키: $KEY_FILE"
    echo "   공개키: $PUBLIC_KEY_FILE"
    echo ""
    log_info "사용자 계정 정보:"
    echo "   사용자명: $USER"
    echo "   계정 타입: $(if [[ "$USER" == *"@"* ]]; then echo "GCP OS Login (Google 계정)"; else echo "Ubuntu 기본 사용자"; fi)"
    echo ""
    log_info "SSH 키가 인스턴스 메타데이터에 등록되었습니다."
    echo "   - OS Login 방식: Google 계정으로 자동 인증"
    echo "   - 인스턴스 메타데이터 방식: 개인키 파일로 직접 인증"
    echo ""
    
    # 연결 테스트 제안
    log_info "연결 테스트:"
    echo "다음 명령어로 연결을 테스트해보세요:"
    echo "ssh -i $KEY_FILE -o ConnectTimeout=10 $USER@$EXTERNAL_IP 'echo \"SSH 연결 성공!\"'"
    echo ""
fi

log_success "=== 스크립트 실행 완료 ==="
