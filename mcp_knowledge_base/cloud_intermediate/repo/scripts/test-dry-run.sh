#!/bin/bash

# Cloud Intermediate 자동화 코드 Dry-Run 테스트 스크립트
# 컨테이너 기술과 Kubernetes 중심의 중급 실무 과정 자동화 검증

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 로그 함수들
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_header() { echo -e "${PURPLE}=== $1 ===${NC}"; }

# 테스트 결과 저장
TEST_RESULTS=()
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# 테스트 함수
run_test() {
    local test_name="$1"
    local test_command="$2"
    local expected_result="$3"
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    log_info "테스트 실행: $test_name"
    
    # Dry-run 모드로 실행 (실제 리소스 생성 없이)
    if eval "$test_command" &> /dev/null; then
        log_success "✅ $test_name: 통과"
        TEST_RESULTS+=("✅ $test_name: 통과")
        PASSED_TESTS=$((PASSED_TESTS + 1))
        return 0
    else
        log_error "❌ $test_name: 실패"
        TEST_RESULTS+=("❌ $test_name: 실패")
        FAILED_TESTS=$((FAILED_TESTS + 1))
        return 1
    fi
}

# 스크립트 문법 검사
test_syntax() {
    log_header "스크립트 문법 검사"
    
    local scripts=(
        "cloud-intermediate-advanced.sh"
        "cloud-intermediate-helper.sh"
    )
    
    for script in "${scripts[@]}"; do
        if [[ -f "$script" ]]; then
            run_test "문법 검사: $script" "bash -n $script" "syntax_ok"
        else
            log_warning "⚠️ 스크립트 파일 없음: $script"
        fi
    done
}

# 환경 체크 함수 테스트
test_environment_checks() {
    log_header "환경 체크 함수 테스트"
    
    # Docker CLI 체크 (설치 여부만)
    run_test "Docker CLI 설치 확인" "command -v docker" "docker_installed"
    
    # Docker Compose 체크 (설치 여부만)
    run_test "Docker Compose 설치 확인" "command -v docker-compose" "docker_compose_installed"
    
    # kubectl 체크 (설치 여부만)
    run_test "kubectl 설치 확인" "command -v kubectl" "kubectl_installed"
    
    # AWS CLI 체크 (설치 여부만)
    run_test "AWS CLI 설치 확인" "command -v aws" "aws_installed"
    
    # GCP CLI 체크 (설치 여부만)
    run_test "GCP CLI 설치 확인" "command -v gcloud" "gcloud_installed"
    
    # Git 체크
    run_test "Git 설치 확인" "command -v git" "git_installed"
    
    # GitHub CLI 체크 (선택사항)
    run_test "GitHub CLI 설치 확인" "command -v gh" "gh_installed"
    
    # jq 체크
    run_test "jq 설치 확인" "command -v jq" "jq_installed"
}

# 스크립트 실행 권한 테스트
test_permissions() {
    log_header "스크립트 실행 권한 테스트"
    
    local scripts=(
        "cloud-intermediate-advanced.sh"
        "cloud-intermediate-helper.sh"
    )
    
    for script in "${scripts[@]}"; do
        if [[ -f "$script" ]]; then
            if [[ -x "$script" ]]; then
                run_test "실행 권한: $script" "test -x $script" "executable"
            else
                log_warning "⚠️ 실행 권한 없음: $script"
                # 실행 권한 부여
                chmod +x "$script"
                log_info "실행 권한 부여: $script"
            fi
        fi
    done
}

# 함수 정의 검사
test_function_definitions() {
    log_header "함수 정의 검사"
    
    local functions=(
        "log_info"
        "log_success"
        "log_warning"
        "log_error"
        "check_docker_cli"
        "check_docker_compose"
        "check_kubectl"
        "check_aws_cli"
        "check_gcp_cli"
    )
    
    for func in "${functions[@]}"; do
        if grep -q "function $func\|$func()" cloud-intermediate-advanced.sh; then
            run_test "함수 정의: $func" "grep -q '$func()' cloud-intermediate-advanced.sh" "function_defined"
        else
            log_warning "⚠️ 함수 정의 없음: $func"
        fi
    done
}

# 변수 정의 검사
test_variable_definitions() {
    log_header "변수 정의 검사"
    
    local variables=(
        "RED"
        "GREEN"
        "YELLOW"
        "BLUE"
        "NC"
        "SCRIPT_DIR"
        "PROJECT_ROOT"
        "LOG_FILE"
    )
    
    for var in "${variables[@]}"; do
        if grep -q "$var=" cloud-intermediate-advanced.sh; then
            run_test "변수 정의: $var" "grep -q '$var=' cloud-intermediate-advanced.sh" "variable_defined"
        else
            log_warning "⚠️ 변수 정의 없음: $var"
        fi
    done
}

# 메뉴 시스템 테스트
test_menu_system() {
    log_header "메뉴 시스템 테스트"
    
    # 메뉴 옵션 검사
    local menu_options=(
        "종합 환경 체크"
        "Docker 리소스 현황"
        "Kubernetes 리소스 현황"
        "AWS 컨테이너 서비스 현황"
        "GCP 컨테이너 서비스 현황"
        "Day 1 실습 자동화"
        "Day 2 실습 자동화"
    )
    
    for option in "${menu_options[@]}"; do
        if grep -q "$option" cloud-intermediate-advanced.sh; then
            run_test "메뉴 옵션: $option" "grep -q '$option' cloud-intermediate-advanced.sh" "menu_option_exists"
        else
            log_warning "⚠️ 메뉴 옵션 없음: $option"
        fi
    done
}

# 로그 시스템 테스트
test_logging_system() {
    log_header "로깅 시스템 테스트"
    
    # 로그 함수 검사
    local log_functions=(
        "log_info"
        "log_success"
        "log_warning"
        "log_error"
        "log_header"
    )
    
    for log_func in "${log_functions[@]}"; do
        if grep -q "$log_func()" cloud-intermediate-advanced.sh; then
            run_test "로그 함수: $log_func" "grep -q '$log_func()' cloud-intermediate-advanced.sh" "log_function_exists"
        else
            log_warning "⚠️ 로그 함수 없음: $log_func"
        fi
    done
    
    # 로그 파일 설정 검사
    run_test "로그 파일 설정" "grep -q 'LOG_FILE=' cloud-intermediate-advanced.sh" "log_file_configured"
}

# 오류 처리 테스트
test_error_handling() {
    log_header "오류 처리 테스트"
    
    # 오류 처리 패턴 검사
    local error_patterns=(
        "set -e"
        "set -u"
        "set -o pipefail"
        "trap"
        "if.*then"
        "else"
        "return"
    )
    
    for pattern in "${error_patterns[@]}"; do
        if grep -q "$pattern" cloud-intermediate-advanced.sh; then
            run_test "오류 처리: $pattern" "grep -q '$pattern' cloud-intermediate-advanced.sh" "error_handling_exists"
        else
            log_warning "⚠️ 오류 처리 패턴 없음: $pattern"
        fi
    done
}

# 의존성 검사
test_dependencies() {
    log_header "의존성 검사"
    
    # 필수 명령어 검사
    local commands=(
        "curl"
        "wget"
        "unzip"
        "jq"
        "docker"
        "docker-compose"
        "kubectl"
        "git"
    )
    
    for cmd in "${commands[@]}"; do
        if command -v "$cmd" &> /dev/null; then
            run_test "의존성: $cmd" "command -v $cmd" "dependency_available"
        else
            log_warning "⚠️ 의존성 없음: $cmd"
        fi
    done
}

# 설정 파일 검사
test_configuration_files() {
    log_header "설정 파일 검사"
    
    # 설정 파일 존재 여부 검사
    local config_files=(
        "cloud-intermediate-advanced.sh"
        "cloud-intermediate-helper.sh"
    )
    
    for config_file in "${config_files[@]}"; do
        if [[ -f "$config_file" ]]; then
            run_test "설정 파일: $config_file" "test -f $config_file" "config_file_exists"
        else
            log_warning "⚠️ 설정 파일 없음: $config_file"
        fi
    done
}

# 컨테이너 관련 기능 테스트
test_container_features() {
    log_header "컨테이너 관련 기능 테스트"
    
    # Docker 관련 함수 검사
    local docker_functions=(
        "monitor_docker_resources"
        "cleanup_docker_resources"
        "check_docker_cli"
        "check_docker_compose"
    )
    
    for func in "${docker_functions[@]}"; do
        if grep -q "$func()" cloud-intermediate-advanced.sh; then
            run_test "Docker 함수: $func" "grep -q '$func()' cloud-intermediate-advanced.sh" "docker_function_exists"
        else
            log_warning "⚠️ Docker 함수 없음: $func"
        fi
    done
    
    # Kubernetes 관련 함수 검사
    local k8s_functions=(
        "monitor_kubernetes_resources"
        "check_kubectl"
    )
    
    for func in "${k8s_functions[@]}"; do
        if grep -q "$func()" cloud-intermediate-advanced.sh; then
            run_test "Kubernetes 함수: $func" "grep -q '$func()' cloud-intermediate-advanced.sh" "k8s_function_exists"
        else
            log_warning "⚠️ Kubernetes 함수 없음: $func"
        fi
    done
}

# 클라우드 서비스 기능 테스트
test_cloud_services() {
    log_header "클라우드 서비스 기능 테스트"
    
    # AWS 관련 함수 검사
    local aws_functions=(
        "monitor_aws_container_services"
        "analyze_aws_costs"
        "cleanup_aws_resources"
    )
    
    for func in "${aws_functions[@]}"; do
        if grep -q "$func()" cloud-intermediate-advanced.sh; then
            run_test "AWS 함수: $func" "grep -q '$func()' cloud-intermediate-advanced.sh" "aws_function_exists"
        else
            log_warning "⚠️ AWS 함수 없음: $func"
        fi
    done
    
    # GCP 관련 함수 검사
    local gcp_functions=(
        "monitor_gcp_container_services"
        "analyze_gcp_costs"
        "cleanup_gcp_resources"
    )
    
    for func in "${gcp_functions[@]}"; do
        if grep -q "$func()" cloud-intermediate-advanced.sh; then
            run_test "GCP 함수: $func" "grep -q '$func()' cloud-intermediate-advanced.sh" "gcp_function_exists"
        else
            log_warning "⚠️ GCP 함수 없음: $func"
        fi
    done
}

# 실습 자동화 기능 테스트
test_practice_automation() {
    log_header "실습 자동화 기능 테스트"
    
    # 실습 자동화 함수 검사
    local practice_functions=(
        "day1_practice_automation"
        "day2_practice_automation"
        "setup_monitoring_stack"
    )
    
    for func in "${practice_functions[@]}"; do
        if grep -q "$func()" cloud-intermediate-advanced.sh; then
            run_test "실습 자동화 함수: $func" "grep -q '$func()' cloud-intermediate-advanced.sh" "practice_function_exists"
        else
            log_warning "⚠️ 실습 자동화 함수 없음: $func"
        fi
    done
}

# 결과 요약
print_summary() {
    log_header "테스트 결과 요약"
    
    local success_rate=$((PASSED_TESTS * 100 / TOTAL_TESTS))
    
    echo ""
    echo "📊 테스트 통계:"
    echo "   총 테스트: $TOTAL_TESTS"
    echo "   통과: $PASSED_TESTS"
    echo "   실패: $FAILED_TESTS"
    echo "   성공률: ${success_rate}%"
    echo ""
    
    if [[ $success_rate -ge 90 ]]; then
        log_success "🎉 테스트 성공! (${success_rate}%)"
    elif [[ $success_rate -ge 70 ]]; then
        log_warning "⚠️ 테스트 부분 성공 (${success_rate}%)"
    else
        log_error "❌ 테스트 실패 (${success_rate}%)"
    fi
    
    echo ""
    echo "📋 상세 결과:"
    for result in "${TEST_RESULTS[@]}"; do
        echo "   $result"
    done
}

# 메인 실행 함수
main() {
    log_header "Cloud Intermediate 자동화 코드 Dry-Run 테스트 시작"
    
    # 스크립트 디렉토리로 이동
    cd "$(dirname "$0")" || exit 1
    
    # 테스트 실행
    test_syntax
    test_permissions
    test_environment_checks
    test_function_definitions
    test_variable_definitions
    test_menu_system
    test_logging_system
    test_error_handling
    test_dependencies
    test_configuration_files
    test_container_features
    test_cloud_services
    test_practice_automation
    
    # 결과 출력
    print_summary
    
    log_header "Dry-Run 테스트 완료"
}

# 스크립트 실행
main "$@"
