#!/bin/bash

# IP 주소 보안 스캔 스크립트
# 마크다운 문서 내 민감한 IP 주소 검사 및 비식별화

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

# 스캔 결과 저장
SENSITIVE_IPS=0
TEMPLATE_IPS=0
TOTAL_FILES=0

# IP 주소 패턴 정의
PUBLIC_IP_PATTERN='\b(?:[0-9]{1,3}\.){3}[0-9]{1,3}\b'
AWS_INSTANCE_PATTERN='i-[a-z0-9]{8,17}'
AWS_SECURITY_GROUP_PATTERN='sg-[a-z0-9]{8,17}'
AWS_VPC_PATTERN='vpc-[a-z0-9]{8,17}'

# 민감한 IP 주소 검사
check_sensitive_ips() {
    log_info "🔍 민감한 IP 주소 스캔 시작..."
    
    # 공개 IP 주소 검사 (로컬호스트 제외)
    local public_ips=$(grep -r -E '\b(?:[0-9]{1,3}\.){3}[0-9]{1,3}\b' . --include="*.md" --include="*.sh" --include="*.yaml" --include="*.yml" | grep -v -E '(127\.0\.0\.1|localhost|0\.0\.0\.0|192\.168\.|10\.|172\.)' | wc -l)
    
    if [ "$public_ips" -gt 0 ]; then
        log_warning "⚠️ 공개 IP 주소 $public_ips개 발견"
        grep -r -E '\b(?:[0-9]{1,3}\.){3}[0-9]{1,3}\b' . --include="*.md" --include="*.sh" --include="*.yaml" --include="*.yml" | grep -v -E '(127\.0\.0\.1|localhost|0\.0\.0\.0|192\.168\.|10\.|172\.)'
        SENSITIVE_IPS=$((SENSITIVE_IPS + public_ips))
    else
        log_success "✅ 공개 IP 주소 없음"
    fi
    
    # AWS 리소스 ID 검사
    local aws_instances=$(grep -r -E "$AWS_INSTANCE_PATTERN" . --include="*.md" --include="*.sh" | wc -l)
    if [ "$aws_instances" -gt 0 ]; then
        log_warning "⚠️ AWS 인스턴스 ID $aws_instances개 발견"
        grep -r -E "$AWS_INSTANCE_PATTERN" . --include="*.md" --include="*.sh"
        SENSITIVE_IPS=$((SENSITIVE_IPS + aws_instances))
    fi
    
    local aws_sgs=$(grep -r -E "$AWS_SECURITY_GROUP_PATTERN" . --include="*.md" --include="*.sh" | wc -l)
    if [ "$aws_sgs" -gt 0 ]; then
        log_warning "⚠️ AWS 보안 그룹 ID $aws_sgs개 발견"
        grep -r -E "$AWS_SECURITY_GROUP_PATTERN" . --include="*.md" --include="*.sh"
        SENSITIVE_IPS=$((SENSITIVE_IPS + aws_sgs))
    fi
}

# 템플릿 IP 주소 검사
check_template_ips() {
    log_info "🔍 템플릿 IP 주소 검사..."
    
    local template_ips=$(grep -r -E '(YOUR_.*_IP|YOUR_.*_ID)' . --include="*.md" --include="*.sh" | wc -l)
    if [ "$template_ips" -gt 0 ]; then
        log_success "✅ 템플릿 IP 주소 $template_ips개 발견 (안전함)"
        TEMPLATE_IPS=$template_ips
    else
        log_warning "⚠️ 템플릿 IP 주소 없음"
    fi
}

# 파일 통계
count_files() {
    TOTAL_FILES=$(find . -name "*.md" -o -name "*.sh" -o -name "*.yaml" -o -name "*.yml" | wc -l)
    log_info "📊 총 스캔 파일 수: $TOTAL_FILES개"
}

# 결과 요약
print_summary() {
    log_info "=== IP 주소 보안 스캔 결과 ==="
    
    echo "📊 스캔 통계:"
    echo "  - 총 파일 수: $TOTAL_FILES개"
    echo "  - 민감한 IP 주소: $SENSITIVE_IPS개"
    echo "  - 템플릿 IP 주소: $TEMPLATE_IPS개"
    
    if [ "$SENSITIVE_IPS" -eq 0 ]; then
        log_success "🎉 모든 IP 주소가 안전하게 비식별화되었습니다!"
    elif [ "$SENSITIVE_IPS" -lt 5 ]; then
        log_warning "⚠️ 소수의 민감한 IP 주소가 발견되었습니다. 검토가 필요합니다."
    else
        log_error "❌ 많은 민감한 IP 주소가 발견되었습니다. 즉시 조치가 필요합니다."
    fi
    
    if [ "$TEMPLATE_IPS" -gt 0 ]; then
        log_success "✅ 템플릿 IP 주소가 올바르게 사용되고 있습니다."
    fi
}

# 자동 수정 제안
suggest_fixes() {
    if [ "$SENSITIVE_IPS" -gt 0 ]; then
        log_info "🔧 자동 수정 제안:"
        echo "1. 공개 IP 주소를 YOUR_PUBLIC_IP로 교체"
        echo "2. 인스턴스 ID를 YOUR_INSTANCE_ID로 교체"
        echo "3. 보안 그룹 ID를 YOUR_SECURITY_GROUP_ID로 교체"
        echo "4. 환경 변수 사용 권장"
    fi
}

# 메인 실행
main() {
    log_info "🚀 IP 주소 보안 스캔 시작"
    
    count_files
    check_sensitive_ips
    check_template_ips
    print_summary
    suggest_fixes
    
    log_info "✅ IP 주소 보안 스캔 완료"
}

# 스크립트 실행
main "$@"
