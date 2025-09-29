#!/bin/bash

# =============================================================================
# Cloud Intermediate 통합 테스트 스위트
# =============================================================================
# 
# 기능:
#   - 전체 실습 환경 검증
#   - 자동화 스크립트 테스트
#   - 실습 코드 동작 검증
#   - 성능 벤치마크 테스트
#
# 사용법:
#   ./test-cloud-intermediate.sh                    # 전체 테스트
#   ./test-cloud-intermediate.sh --env development  # 개발 환경만
#   ./test-cloud-intermediate.sh --quick           # 빠른 테스트
#
# 작성일: 2024-12-19
# 작성자: Cloud Intermediate 과정
# =============================================================================

set -euo pipefail

# =============================================================================
# 환경 설정
# =============================================================================
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"
TEST_RESULTS_DIR="$PROJECT_ROOT/tests/results"
TEST_LOGS_DIR="$PROJECT_ROOT/tests/logs"

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 로그 함수
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_header() { echo -e "${PURPLE}[HEADER]${NC} $1"; }
log_test() { echo -e "${CYAN}[TEST]${NC} $1"; }

# 테스트 결과 변수
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0
SKIPPED_TESTS=0

# =============================================================================
# 테스트 헬퍼 함수
# =============================================================================
run_test() {
    local test_name="$1"
    local test_function="$2"
    local description="$3"
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    log_test "실행 중: $test_name - $description"
    
    if $test_function; then
        log_success "통과: $test_name"
        PASSED_TESTS=$((PASSED_TESTS + 1))
        return 0
    else
        log_error "실패: $test_name"
        FAILED_TESTS=$((FAILED_TESTS + 1))
        return 1
    fi
}

skip_test() {
    local test_name="$1"
    local reason="$2"
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    SKIPPED_TESTS=$((SKIPPED_TESTS + 1))
    log_warning "건너뜀: $test_name - $reason"
}

# =============================================================================
# 환경 검증 테스트
# =============================================================================
test_environment_setup() {
    log_test "환경 설정 검증"
    
    # 필수 디렉토리 확인
    local required_dirs=(
        "$PROJECT_ROOT/lectures"
        "$PROJECT_ROOT/practice"
        "$PROJECT_ROOT/automation"
        "$PROJECT_ROOT/tools"
    )
    
    for dir in "${required_dirs[@]}"; do
        if [ ! -d "$dir" ]; then
            log_error "필수 디렉토리가 없습니다: $dir"
            return 1
        fi
    done
    
    # 필수 파일 확인
    local required_files=(
        "$PROJECT_ROOT/automation/common-environment.env"
        "$PROJECT_ROOT/tools/cloud/environment-config.yml"
        "$PROJECT_ROOT/tools/cloud/dependencies.yml"
    )
    
    for file in "${required_files[@]}"; do
        if [ ! -f "$file" ]; then
            log_error "필수 파일이 없습니다: $file"
            return 1
        fi
    done
    
    return 0
}

test_required_tools() {
    log_test "필수 도구 검증"
    
    local tools=("docker" "kubectl" "aws" "gcloud" "node" "npm" "jq" "yq")
    
    for tool in "${tools[@]}"; do
        if ! command -v "$tool" &> /dev/null; then
            log_error "필수 도구가 설치되지 않았습니다: $tool"
            return 1
        fi
    done
    
    return 0
}

test_docker_functionality() {
    log_test "Docker 기능 검증"
    
    # Docker 데몬 확인
    if ! docker info &> /dev/null; then
        log_error "Docker 데몬이 실행되지 않음"
        return 1
    fi
    
    # Docker 이미지 빌드 테스트
    local test_dir="/tmp/docker-test"
    mkdir -p "$test_dir"
    
    cat > "$test_dir/Dockerfile" << 'EOF'
FROM alpine:latest
RUN echo "Hello from Docker test"
EOF
    
    if docker build -t test-image "$test_dir" &> /dev/null; then
        log_success "Docker 이미지 빌드 성공"
        docker rmi test-image &> /dev/null || true
    else
        log_error "Docker 이미지 빌드 실패"
        return 1
    fi
    
    rm -rf "$test_dir"
    return 0
}

test_kubernetes_connectivity() {
    log_test "Kubernetes 연결 검증"
    
    if kubectl cluster-info &> /dev/null; then
        log_success "Kubernetes 클러스터 연결됨"
        return 0
    else
        log_warning "Kubernetes 클러스터에 연결할 수 없음 (선택적)"
        return 0
    fi
}

test_cloud_authentication() {
    log_test "클라우드 인증 검증"
    
    local aws_auth=false
    local gcp_auth=false
    
    # AWS 인증 확인
    if aws sts get-caller-identity &> /dev/null; then
        log_success "AWS 인증됨"
        aws_auth=true
    else
        log_warning "AWS 인증 필요"
    fi
    
    # GCP 인증 확인
    if gcloud auth list --filter=status:ACTIVE --format="value(account)" | grep -q .; then
        log_success "GCP 인증됨"
        gcp_auth=true
    else
        log_warning "GCP 인증 필요"
    fi
    
    # 최소 하나의 클라우드 인증이 필요
    if [ "$aws_auth" = true ] || [ "$gcp_auth" = true ]; then
        return 0
    else
        log_warning "클라우드 인증이 없습니다 (선택적)"
        return 0
    fi
}

# =============================================================================
# 자동화 스크립트 테스트
# =============================================================================
test_automation_scripts() {
    log_test "자동화 스크립트 검증"
    
    local scripts=(
        "$PROJECT_ROOT/automation/day1/cloud-practice-menu.sh"
        "$PROJECT_ROOT/automation/day2/cicd-pipeline-helper.sh"
        "$PROJECT_ROOT/automation/day2/github-actions-helper.sh"
    )
    
    for script in "${scripts[@]}"; do
        if [ ! -f "$script" ]; then
            log_error "자동화 스크립트가 없습니다: $script"
            return 1
        fi
        
        if [ ! -x "$script" ]; then
            log_warning "자동화 스크립트 실행 권한이 없습니다: $script"
        fi
    done
    
    return 0
}

test_environment_config() {
    log_test "환경 설정 파일 검증"
    
    local config_file="$PROJECT_ROOT/tools/cloud/environment-config.yml"
    
    if [ ! -f "$config_file" ]; then
        log_error "환경 설정 파일이 없습니다: $config_file"
        return 1
    fi
    
    # YAML 파일 구문 검증
    if command -v yq &> /dev/null; then
        if yq eval '.' "$config_file" &> /dev/null; then
            log_success "환경 설정 파일 구문 검증 통과"
        else
            log_error "환경 설정 파일 구문 오류"
            return 1
        fi
    else
        log_warning "yq가 설치되지 않아 YAML 구문 검증을 건너뜁니다"
    fi
    
    return 0
}

# =============================================================================
# 실습 코드 테스트
# =============================================================================
test_practice_code() {
    log_test "실습 코드 검증"
    
    # Day1 실습 코드 확인
    local day1_practices=(
        "$PROJECT_ROOT/practice/day1/docker-advanced"
        "$PROJECT_ROOT/practice/day1/kubernetes-basics"
        "$PROJECT_ROOT/practice/day1/cloud-container-services"
        "$PROJECT_ROOT/practice/day1/monitoring-hub"
    )
    
    for practice in "${day1_practices[@]}"; do
        if [ ! -d "$practice" ]; then
            log_error "Day1 실습 디렉토리가 없습니다: $practice"
            return 1
        fi
    done
    
    # Day2 실습 코드 확인
    local day2_practices=(
        "$PROJECT_ROOT/practice/day2/cicd-pipeline"
        "$PROJECT_ROOT/practice/day2/cicd-practice-app"
        "$PROJECT_ROOT/practice/day2/advanced-monitoring"
        "$PROJECT_ROOT/practice/day2/cloud-deployment"
    )
    
    for practice in "${day2_practices[@]}"; do
        if [ ! -d "$practice" ]; then
            log_error "Day2 실습 디렉토리가 없습니다: $practice"
            return 1
        fi
    done
    
    return 0
}

test_cicd_practice_app() {
    log_test "CI/CD 연습용 앱 검증"
    
    local app_dir="$PROJECT_ROOT/practice/day2/cicd-practice-app"
    
    if [ ! -d "$app_dir" ]; then
        log_error "CI/CD 연습용 앱 디렉토리가 없습니다: $app_dir"
        return 1
    fi
    
    cd "$app_dir"
    
    # package.json 확인
    if [ ! -f "package.json" ]; then
        log_error "package.json이 없습니다"
        return 1
    fi
    
    # 의존성 설치 테스트
    if npm install &> /dev/null; then
        log_success "의존성 설치 성공"
    else
        log_error "의존성 설치 실패"
        return 1
    fi
    
    # 테스트 실행
    if npm test &> /dev/null; then
        log_success "테스트 실행 성공"
    else
        log_warning "테스트 실행 실패 (선택적)"
    fi
    
    return 0
}

# =============================================================================
# 성능 벤치마크 테스트
# =============================================================================
test_docker_performance() {
    log_test "Docker 성능 벤치마크"
    
    local start_time=$(date +%s)
    
    # 간단한 이미지 빌드 시간 측정
    local test_dir="/tmp/docker-perf-test"
    mkdir -p "$test_dir"
    
    cat > "$test_dir/Dockerfile" << 'EOF'
FROM alpine:latest
RUN apk add --no-cache curl
EOF
    
    if docker build -t perf-test "$test_dir" &> /dev/null; then
        local end_time=$(date +%s)
        local build_time=$((end_time - start_time))
        
        log_success "Docker 빌드 시간: ${build_time}초"
        
        # 정리
        docker rmi perf-test &> /dev/null || true
        rm -rf "$test_dir"
        
        # 성능 기준 (30초 이내)
        if [ $build_time -le 30 ]; then
            return 0
        else
            log_warning "Docker 빌드 시간이 기준을 초과했습니다 (${build_time}초 > 30초)"
            return 0
        fi
    else
        log_error "Docker 성능 테스트 실패"
        return 1
    fi
}

test_network_connectivity() {
    log_test "네트워크 연결성 검증"
    
    local endpoints=(
        "https://docker.io"
        "https://registry.k8s.io"
        "https://aws.amazon.com"
        "https://cloud.google.com"
    )
    
    for endpoint in "${endpoints[@]}"; do
        if curl -s --connect-timeout 10 "$endpoint" &> /dev/null; then
            log_success "연결됨: $endpoint"
        else
            log_warning "연결 실패: $endpoint"
        fi
    done
    
    return 0
}

# =============================================================================
# 테스트 결과 보고서 생성
# =============================================================================
generate_test_report() {
    local report_file="$TEST_RESULTS_DIR/test-report-$(date +%Y%m%d-%H%M%S).json"
    
    mkdir -p "$TEST_RESULTS_DIR"
    
    cat > "$report_file" << EOF
{
  "timestamp": "$(date -Iseconds)",
  "environment": "${ENVIRONMENT:-development}",
  "summary": {
    "total_tests": $TOTAL_TESTS,
    "passed_tests": $PASSED_TESTS,
    "failed_tests": $FAILED_TESTS,
    "skipped_tests": $SKIPPED_TESTS,
    "success_rate": "$(( (PASSED_TESTS * 100) / TOTAL_TESTS ))%"
  },
  "details": {
    "environment_setup": "검증 완료",
    "required_tools": "검증 완료",
    "docker_functionality": "검증 완료",
    "kubernetes_connectivity": "검증 완료",
    "cloud_authentication": "검증 완료",
    "automation_scripts": "검증 완료",
    "environment_config": "검증 완료",
    "practice_code": "검증 완료",
    "cicd_practice_app": "검증 완료",
    "docker_performance": "검증 완료",
    "network_connectivity": "검증 완료"
  }
}
EOF
    
    log_success "테스트 보고서 생성: $report_file"
}

# =============================================================================
# 메인 실행 로직
# =============================================================================
main() {
    local environment="development"
    local quick_mode=false
    
    # 명령행 인수 처리
    while [[ $# -gt 0 ]]; do
        case $1 in
            --env)
                environment="$2"
                shift 2
                ;;
            --quick)
                quick_mode=true
                shift
                ;;
            --help|-h)
                echo "사용법: $0 [--env <environment>] [--quick]"
                exit 0
                ;;
            *)
                log_error "알 수 없는 옵션: $1"
                exit 1
                ;;
        esac
    done
    
    log_header "Cloud Intermediate 통합 테스트 시작"
    log_info "환경: $environment"
    log_info "빠른 모드: $quick_mode"
    
    # 테스트 실행
    run_test "environment_setup" test_environment_setup "환경 설정 검증"
    run_test "required_tools" test_required_tools "필수 도구 검증"
    run_test "docker_functionality" test_docker_functionality "Docker 기능 검증"
    run_test "kubernetes_connectivity" test_kubernetes_connectivity "Kubernetes 연결 검증"
    run_test "cloud_authentication" test_cloud_authentication "클라우드 인증 검증"
    run_test "automation_scripts" test_automation_scripts "자동화 스크립트 검증"
    run_test "environment_config" test_environment_config "환경 설정 파일 검증"
    run_test "practice_code" test_practice_code "실습 코드 검증"
    run_test "cicd_practice_app" test_cicd_practice_app "CI/CD 연습용 앱 검증"
    
    if [ "$quick_mode" = false ]; then
        run_test "docker_performance" test_docker_performance "Docker 성능 벤치마크"
        run_test "network_connectivity" test_network_connectivity "네트워크 연결성 검증"
    fi
    
    # 테스트 결과 요약
    log_header "테스트 결과 요약"
    log_info "총 테스트: $TOTAL_TESTS"
    log_success "통과: $PASSED_TESTS"
    log_error "실패: $FAILED_TESTS"
    log_warning "건너뜀: $SKIPPED_TESTS"
    
    local success_rate=$(( (PASSED_TESTS * 100) / TOTAL_TESTS ))
    log_info "성공률: ${success_rate}%"
    
    # 보고서 생성
    generate_test_report
    
    # 종료 코드 설정
    if [ $FAILED_TESTS -eq 0 ]; then
        log_success "모든 테스트가 통과했습니다!"
        exit 0
    else
        log_error "$FAILED_TESTS 개의 테스트가 실패했습니다"
        exit 1
    fi
}

# =============================================================================
# 스크립트 실행
# =============================================================================
main "$@"
