#!/bin/bash

# =============================================================================
# 자동화 스크립트 복사 도우미
# =============================================================================
# 
# 기능:
#   - tools/cloud의 자동화 스크립트를 실습 위치로 복사
#   - 실행 권한 자동 설정
#   - 필요한 환경 설정 파일도 함께 복사
#
# 사용법:
#   ./copy-automation-scripts.sh [day1|day2|all]
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
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# 로그 함수
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# =============================================================================
# 사용법 출력
# =============================================================================
usage() {
    cat << EOF
자동화 스크립트 복사 도우미

사용법:
  $0 [day1|day2|all]

옵션:
  day1    Day1 자동화 스크립트를 실습 위치로 복사
  day2    Day2 자동화 스크립트를 실습 위치로 복사
  all     모든 자동화 스크립트를 실습 위치로 복사

예시:
  $0 day1
  $0 day2
  $0 all
EOF
}

# =============================================================================
# Day1 자동화 스크립트 복사
# =============================================================================
copy_day1_scripts() {
    log_info "Day1 자동화 스크립트를 복사합니다..."
    
    local target_dir="$PROJECT_ROOT/repo/practice/day1"
    
    # 대상 디렉토리 생성
    mkdir -p "$target_dir"
    
    # Day1 자동화 스크립트 복사
    cp "$SCRIPT_DIR/day1-practice.sh" "$target_dir/"
    chmod +x "$target_dir/day1-practice.sh"
    log_success "Day1 자동화 스크립트 복사 완료"
    
    # 필요한 헬퍼 스크립트들 복사
    local helpers=(
        "docker-helper.sh"
        "k8s-helper.sh"
        "aws-ecs-helper.sh"
        "gcp-cloudrun-helper.sh"
        "monitoring-hub-helper.sh"
        "aws-ec2-helper.sh"
        "gcp-compute-helper.sh"
        "comprehensive-cleanup.sh"
    )
    
    for helper in "${helpers[@]}"; do
        if [ -f "$SCRIPT_DIR/$helper" ]; then
            cp "$SCRIPT_DIR/$helper" "$target_dir/"
            chmod +x "$target_dir/$helper"
            log_info "헬퍼 스크립트 복사: $helper"
        else
            log_warning "헬퍼 스크립트를 찾을 수 없습니다: $helper"
        fi
    done
    
    # 환경 설정 파일들 복사
    local env_files=(
        "common-environment.env"
        "aws-environment.env"
        "gcp-environment.env"
        "monitoring-environment.env"
    )
    
    for env_file in "${env_files[@]}"; do
        if [ -f "$SCRIPT_DIR/$env_file" ]; then
            cp "$SCRIPT_DIR/$env_file" "$target_dir/"
            log_info "환경 설정 파일 복사: $env_file"
        else
            log_warning "환경 설정 파일을 찾을 수 없습니다: $env_file"
        fi
    done
    
    log_success "Day1 자동화 스크립트 복사 완료"
}

# =============================================================================
# Day2 자동화 스크립트 복사
# =============================================================================
copy_day2_scripts() {
    log_info "Day2 자동화 스크립트를 복사합니다..."
    
    local target_dir="$PROJECT_ROOT/repo/practice/day2"
    
    # 대상 디렉토리 생성
    mkdir -p "$target_dir"
    
    # Day2 자동화 스크립트 복사
    cp "$SCRIPT_DIR/day2-practice.sh" "$target_dir/"
    chmod +x "$target_dir/day2-practice.sh"
    log_success "Day2 자동화 스크립트 복사 완료"
    
    # 필요한 헬퍼 스크립트들 복사
    local helpers=(
        "github-actions-helper.sh"
        "aws-ec2-helper.sh"
        "gcp-compute-helper.sh"
        "aws-app-monitoring-helper.sh"
        "multi-cloud-monitoring-helper.sh"
        "comprehensive-cleanup.sh"
    )
    
    for helper in "${helpers[@]}"; do
        if [ -f "$SCRIPT_DIR/$helper" ]; then
            cp "$SCRIPT_DIR/$helper" "$target_dir/"
            chmod +x "$target_dir/$helper"
            log_info "헬퍼 스크립트 복사: $helper"
        else
            log_warning "헬퍼 스크립트를 찾을 수 없습니다: $helper"
        fi
    done
    
    # 환경 설정 파일들 복사
    local env_files=(
        "common-environment.env"
        "aws-environment.env"
        "gcp-environment.env"
        "monitoring-environment.env"
    )
    
    for env_file in "${env_files[@]}"; do
        if [ -f "$SCRIPT_DIR/$env_file" ]; then
            cp "$SCRIPT_DIR/$env_file" "$target_dir/"
            log_info "환경 설정 파일 복사: $env_file"
        else
            log_warning "환경 설정 파일을 찾을 수 없습니다: $env_file"
        fi
    done
    
    log_success "Day2 자동화 스크립트 복사 완료"
}

# =============================================================================
# 모든 자동화 스크립트 복사
# =============================================================================
copy_all_scripts() {
    log_info "모든 자동화 스크립트를 복사합니다..."
    
    copy_day1_scripts
    copy_day2_scripts
    
    log_success "모든 자동화 스크립트 복사 완료"
}

# =============================================================================
# 메인 실행 로직
# =============================================================================
main() {
    local target="${1:-all}"
    
    case "$target" in
        "day1")
            copy_day1_scripts
            ;;
        "day2")
            copy_day2_scripts
            ;;
        "all")
            copy_all_scripts
            ;;
        "--help"|"-h"|"help")
            usage
            exit 0
            ;;
        *)
            log_error "알 수 없는 옵션: $target"
            usage
            exit 1
            ;;
    esac
}

# =============================================================================
# 스크립트 실행
# =============================================================================
main "$@"
