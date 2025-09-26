#!/bin/bash

# Cloud Intermediate - 통합 테스트 실행 스크립트
# 모든 Phase의 테스트를 순차적으로 실행

# 오류 처리 설정
set -e
set -u
set -o pipefail

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

# 로그 함수들
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_header() { echo -e "${PURPLE}=== $1 ===${NC}"; }

# 설정 변수
TEST_DIR="./test-results"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
TEST_LOG="$TEST_DIR/test_$TIMESTAMP.log"
PHASE1_TEST_LOG="$TEST_DIR/phase1_$TIMESTAMP.log"
PHASE2_4_TEST_LOG="$TEST_DIR/phase2-4_$TIMESTAMP.log"

# 테스트 결과 저장
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# 테스트 결과 기록 함수
record_test_result() {
    local test_name="$1"
    local result="$2"
    local message="$3"
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    
    if [ "$result" = "PASS" ]; then
        PASSED_TESTS=$((PASSED_TESTS + 1))
        log_success "✅ $test_name: $message"
        echo "PASS: $test_name - $message" >> "$TEST_LOG"
    else
        FAILED_TESTS=$((FAILED_TESTS + 1))
        log_error "❌ $test_name: $message"
        echo "FAIL: $test_name - $message" >> "$TEST_LOG"
    fi
}

# 테스트 환경 설정
setup_test_environment() {
    log_header "테스트 환경 설정"
    
    # 테스트 디렉토리 생성
    mkdir -p "$TEST_DIR"
    
    # 테스트 로그 초기화
    echo "통합 테스트 시작: $(date)" > "$TEST_LOG"
    echo "Phase 1 로컬 테스트 시작: $(date)" > "$PHASE1_TEST_LOG"
    echo "Phase 2-4 클라우드 테스트 시작: $(date)" > "$PHASE2_4_TEST_LOG"
    
    log_success "테스트 환경 설정 완료"
}

# Phase 1 로컬 테스트 실행
run_phase1_tests() {
    log_header "Phase 1 로컬 테스트 실행"
    
    # Phase 1 테스트 스크립트 실행
    if [ -f "scripts/test-phase1-local.sh" ]; then
        log_info "Phase 1 로컬 테스트 시작..."
        if bash scripts/test-phase1-local.sh 2>&1 | tee -a "$PHASE1_TEST_LOG"; then
            record_test_result "Phase1_Local_Test" "PASS" "Phase 1 로컬 테스트 완료"
        else
            record_test_result "Phase1_Local_Test" "FAIL" "Phase 1 로컬 테스트 실패"
        fi
    else
        record_test_result "Phase1_Local_Test" "FAIL" "Phase 1 테스트 스크립트 없음"
    fi
}

# Phase 2-4 클라우드 테스트 실행
run_phase2_4_tests() {
    log_header "Phase 2-4 클라우드 테스트 실행"
    
    # Phase 2-4 테스트 스크립트 실행
    if [ -f "scripts/test-phase2-4-cloud.sh" ]; then
        log_info "Phase 2-4 클라우드 테스트 시작..."
        if bash scripts/test-phase2-4-cloud.sh 2>&1 | tee -a "$PHASE2_4_TEST_LOG"; then
            record_test_result "Phase2_4_Cloud_Test" "PASS" "Phase 2-4 클라우드 테스트 완료"
        else
            record_test_result "Phase2_4_Cloud_Test" "FAIL" "Phase 2-4 클라우드 테스트 실패"
        fi
    else
        record_test_result "Phase2_4_Cloud_Test" "FAIL" "Phase 2-4 테스트 스크립트 없음"
    fi
}

# 통합 테스트 실행
run_integration_tests() {
    log_header "통합 테스트 실행"
    
    # 통합 테스트 스크립트 실행
    if [ -f "scripts/test-monitoring-stack.sh" ]; then
        log_info "통합 테스트 시작..."
        if bash scripts/test-monitoring-stack.sh 2>&1 | tee -a "$TEST_LOG"; then
            record_test_result "Integration_Test" "PASS" "통합 테스트 완료"
        else
            record_test_result "Integration_Test" "FAIL" "통합 테스트 실패"
        fi
    else
        record_test_result "Integration_Test" "FAIL" "통합 테스트 스크립트 없음"
    fi
}

# 테스트 스크립트 권한 설정
setup_script_permissions() {
    log_header "테스트 스크립트 권한 설정"
    
    # 스크립트 실행 권한 부여
    chmod +x scripts/*.sh 2>/dev/null || true
    
    log_success "테스트 스크립트 권한 설정 완료"
}

# 테스트 결과 요약
print_test_summary() {
    log_header "테스트 결과 요약"
    
    local success_rate=$((PASSED_TESTS * 100 / TOTAL_TESTS))
    
    echo "총 테스트: $TOTAL_TESTS"
    echo "통과: $PASSED_TESTS"
    echo "실패: $FAILED_TESTS"
    echo "성공률: $success_rate%"
    
    if [ "$success_rate" -ge 90 ]; then
        log_success "🎉 모든 테스트 통과! (${success_rate}%)"
    elif [ "$success_rate" -ge 70 ]; then
        log_warning "⚠️ 테스트 부분 통과 (${success_rate}%)"
    else
        log_error "❌ 테스트 실패 (${success_rate}%)"
    fi
    
    echo ""
    echo "상세 로그:"
    echo "  - 통합 테스트: $TEST_LOG"
    echo "  - Phase 1 로컬: $PHASE1_TEST_LOG"
    echo "  - Phase 2-4 클라우드: $PHASE2_4_TEST_LOG"
}

# 테스트 옵션 처리
parse_arguments() {
    local run_phase1=false
    local run_phase2_4=false
    local run_integration=false
    local run_all=false
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --phase1)
                run_phase1=true
                shift
                ;;
            --phase2-4)
                run_phase2_4=true
                shift
                ;;
            --integration)
                run_integration=true
                shift
                ;;
            --all)
                run_all=true
                shift
                ;;
            --help)
                echo "사용법: $0 [옵션]"
                echo "옵션:"
                echo "  --phase1        Phase 1 로컬 테스트만 실행"
                echo "  --phase2-4      Phase 2-4 클라우드 테스트만 실행"
                echo "  --integration   통합 테스트만 실행"
                echo "  --all           모든 테스트 실행 (기본값)"
                echo "  --help          도움말 표시"
                exit 0
                ;;
            *)
                log_error "알 수 없는 옵션: $1"
                exit 1
                ;;
        esac
    done
    
    # 기본값 설정
    if [ "$run_phase1" = false ] && [ "$run_phase2_4" = false ] && [ "$run_integration" = false ] && [ "$run_all" = false ]; then
        run_all=true
    fi
    
    # 테스트 실행
    if [ "$run_all" = true ] || [ "$run_phase1" = true ]; then
        run_phase1_tests
    fi
    
    if [ "$run_all" = true ] || [ "$run_phase2_4" = true ]; then
        run_phase2_4_tests
    fi
    
    if [ "$run_all" = true ] || [ "$run_integration" = true ]; then
        run_integration_tests
    fi
}

# 메인 실행 함수
main() {
    log_header "Cloud Intermediate 통합 테스트 시작"
    
    # 테스트 환경 설정
    setup_test_environment
    
    # 테스트 스크립트 권한 설정
    setup_script_permissions
    
    # 인수 처리 및 테스트 실행
    parse_arguments "$@"
    
    # 테스트 결과 요약
    print_test_summary
    
    log_header "통합 테스트 완료"
}

# 스크립트 실행
main "$@"
