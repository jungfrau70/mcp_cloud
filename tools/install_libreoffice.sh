#!/bin/bash

# LibreOffice 설치 스크립트
# PPTX → PDF 변환을 위한 LibreOffice 설치

set -e

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 로그 함수
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# 시스템 확인
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$NAME
    VER=$VERSION_ID
else
    log_error "OS 정보를 확인할 수 없습니다."
    exit 1
fi

log_info "OS: $OS $VER"

# LibreOffice 설치
install_libreoffice() {
    log_info "LibreOffice 설치를 시작합니다..."
    
    if command -v dnf &> /dev/null; then
        # Amazon Linux 2023, RHEL, CentOS
        log_info "dnf를 사용하여 LibreOffice 설치 중..."
        sudo dnf update -y
        sudo dnf install -y libreoffice-headless libreoffice-writer libreoffice-calc libreoffice-impress
        
    elif command -v yum &> /dev/null; then
        # Amazon Linux 2, CentOS 7
        log_info "yum을 사용하여 LibreOffice 설치 중..."
        sudo yum update -y
        sudo yum install -y libreoffice-headless libreoffice-writer libreoffice-calc libreoffice-impress
        
    elif command -v apt-get &> /dev/null; then
        # Ubuntu, Debian
        log_info "apt-get을 사용하여 LibreOffice 설치 중..."
        sudo apt-get update
        sudo apt-get install -y libreoffice-writer libreoffice-calc libreoffice-impress
        
    else
        log_error "지원되지 않는 패키지 매니저입니다."
        exit 1
    fi
}

# LibreOffice 설치 확인
check_libreoffice() {
    log_info "LibreOffice 설치 확인 중..."
    
    if command -v soffice &> /dev/null; then
        log_success "✅ soffice 명령어를 찾았습니다: $(which soffice)"
    elif command -v libreoffice &> /dev/null; then
        log_success "✅ libreoffice 명령어를 찾았습니다: $(which libreoffice)"
    else
        log_error "❌ LibreOffice가 설치되지 않았습니다."
        return 1
    fi
    
    # 버전 확인
    if command -v soffice &> /dev/null; then
        VERSION=$(soffice --version 2>/dev/null | head -n1 || echo "Unknown")
    else
        VERSION=$(libreoffice --version 2>/dev/null | head -n1 || echo "Unknown")
    fi
    
    log_success "LibreOffice 버전: $VERSION"
    return 0
}

# PPTX 변환 테스트
test_conversion() {
    log_info "PPTX 변환 기능 테스트 중..."
    
    # 테스트용 PPTX 파일 찾기
    TEST_PPTX=$(find . -name "*.pptx" -type f | head -n1)
    
    if [ -z "$TEST_PPTX" ]; then
        log_warning "테스트용 PPTX 파일을 찾을 수 없습니다."
        return 0
    fi
    
    log_info "테스트 파일: $TEST_PPTX"
    
    # 임시 디렉토리에서 변환 테스트
    TEMP_DIR=$(mktemp -d)
    cd "$TEMP_DIR"
    
    if command -v soffice &> /dev/null; then
        CMD="soffice"
    else
        CMD="libreoffice"
    fi
    
    # 변환 명령어 실행
    if $CMD --headless --nologo --nofirststartwizard --convert-to pdf --outdir . "$TEST_PPTX" 2>/dev/null; then
        log_success "✅ PPTX → PDF 변환 테스트 성공"
        rm -rf "$TEMP_DIR"
        return 0
    else
        log_error "❌ PPTX → PDF 변환 테스트 실패"
        rm -rf "$TEMP_DIR"
        return 1
    fi
}

# 메인 실행
main() {
    log_info "=== LibreOffice 설치 스크립트 시작 ==="
    
    # 이미 설치되어 있는지 확인
    if check_libreoffice; then
        log_success "LibreOffice가 이미 설치되어 있습니다."
        if test_conversion; then
            log_success "🎉 LibreOffice 설치 및 변환 기능이 정상적으로 작동합니다!"
            exit 0
        else
            log_warning "LibreOffice는 설치되어 있지만 변환 기능에 문제가 있습니다."
        fi
    fi
    
    # LibreOffice 설치
    install_libreoffice
    
    # 설치 확인
    if check_libreoffice; then
        log_success "✅ LibreOffice 설치 완료"
        
        # 변환 테스트
        if test_conversion; then
            log_success "🎉 LibreOffice 설치 및 PPTX 변환 기능이 정상적으로 작동합니다!"
        else
            log_warning "⚠️ LibreOffice는 설치되었지만 변환 기능에 문제가 있을 수 있습니다."
        fi
    else
        log_error "❌ LibreOffice 설치에 실패했습니다."
        exit 1
    fi
    
    log_info "=== LibreOffice 설치 스크립트 완료 ==="
}

# 스크립트 실행
main "$@"
