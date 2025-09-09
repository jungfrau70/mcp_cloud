#!/bin/bash

# GCP 설정 도우미 스크립트
# GCP 프로젝트, 리전, 존 설정을 도와주는 스크립트

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

echo "=== GCP 설정 도우미 ==="
echo ""

# 1. 인증 확인
log_info "GCP 인증 상태 확인 중..."
if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" | grep -q .; then
    log_error "GCP 인증이 설정되지 않았습니다."
    log_info "다음 명령어로 인증하세요:"
    echo "gcloud auth login"
    exit 1
fi

CURRENT_ACCOUNT=$(gcloud auth list --filter=status:ACTIVE --format="value(account)")
log_success "인증된 계정: $CURRENT_ACCOUNT"
echo ""

# 2. 프로젝트 목록 표시
log_info "사용 가능한 프로젝트 목록:"
echo ""
gcloud projects list --format="table(projectId,name,projectNumber)" || {
    log_error "프로젝트 목록을 가져올 수 없습니다."
    exit 1
}
echo ""

# 3. 현재 프로젝트 확인
CURRENT_PROJECT=$(gcloud config get-value project 2>/dev/null || echo "")
if [ -n "$CURRENT_PROJECT" ]; then
    log_info "현재 설정된 프로젝트: $CURRENT_PROJECT"
else
    log_warning "현재 프로젝트가 설정되지 않았습니다."
fi
echo ""

# 4. 프로젝트 선택
read -p "사용할 프로젝트 ID를 입력하세요 (또는 Enter로 현재 프로젝트 유지): " SELECTED_PROJECT

if [ -n "$SELECTED_PROJECT" ]; then
    # 프로젝트 유효성 검사
    if ! gcloud projects describe $SELECTED_PROJECT &> /dev/null; then
        log_error "프로젝트 '$SELECTED_PROJECT'에 접근할 수 없습니다."
        exit 1
    fi
    
    # 프로젝트 설정
    gcloud config set project $SELECTED_PROJECT
    log_success "프로젝트가 '$SELECTED_PROJECT'로 설정되었습니다."
    CURRENT_PROJECT=$SELECTED_PROJECT
else
    if [ -z "$CURRENT_PROJECT" ]; then
        log_error "프로젝트를 선택해야 합니다."
        exit 1
    fi
    log_info "현재 프로젝트 '$CURRENT_PROJECT'를 사용합니다."
fi
echo ""

# 5. 리전 목록 표시
log_info "사용 가능한 리전 목록 (한국):"
echo ""
gcloud compute regions list --filter="name~asia-northeast" --format="table(name,status,description)" || {
    log_error "리전 목록을 가져올 수 없습니다."
    exit 1
}
echo ""

# 6. 리전 선택
read -p "사용할 리전을 입력하세요 (예: asia-northeast1, asia-northeast3) [기본값: asia-northeast1]: " SELECTED_REGION
SELECTED_REGION=${SELECTED_REGION:-asia-northeast1}

# 리전 유효성 검사
if ! gcloud compute regions describe $SELECTED_REGION &> /dev/null; then
    log_error "리전 '$SELECTED_REGION'이 유효하지 않습니다."
    exit 1
fi

gcloud config set compute/region $SELECTED_REGION
log_success "리전이 '$SELECTED_REGION'로 설정되었습니다."
echo ""

# 7. 존 목록 표시
log_info "사용 가능한 존 목록 ($SELECTED_REGION):"
echo ""
gcloud compute zones list --filter="region:$SELECTED_REGION" --format="table(name,status)" || {
    log_error "존 목록을 가져올 수 없습니다."
    exit 1
}
echo ""

# 8. 존 선택
read -p "사용할 존을 입력하세요 (예: asia-northeast1-a) [기본값: ${SELECTED_REGION}-a]: " SELECTED_ZONE
SELECTED_ZONE=${SELECTED_ZONE:-${SELECTED_REGION}-a}

# 존 유효성 검사
if ! gcloud compute zones describe $SELECTED_ZONE &> /dev/null; then
    log_error "존 '$SELECTED_ZONE'이 유효하지 않습니다."
    exit 1
fi

gcloud config set compute/zone $SELECTED_ZONE
log_success "존이 '$SELECTED_ZONE'로 설정되었습니다."
echo ""

# 9. 설정 확인
log_success "=== GCP 설정 완료 ==="
echo "계정: $CURRENT_ACCOUNT"
echo "프로젝트: $CURRENT_PROJECT"
echo "리전: $SELECTED_REGION"
echo "존: $SELECTED_ZONE"
echo ""

# 10. 스크립트 실행 안내
log_info "이제 다음 명령어로 가상머신을 생성할 수 있습니다:"
echo "./gcp-compute-create.sh"
echo ""

# 11. 스크립트 변수 업데이트 안내
log_info "또는 스크립트 상단의 변수를 다음과 같이 설정하세요:"
echo "PROJECT_ID=\"$CURRENT_PROJECT\""
echo "REGION=\"$SELECTED_REGION\""
echo "ZONE=\"$SELECTED_ZONE\""
echo ""
