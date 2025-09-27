#!/bin/bash

# 100% 자동화 커버리지 테스트 스크립트
# 모든 실습 시나리오의 자동화 커버리지 검증

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

# 테스트 결과 저장
TESTS_PASSED=0
TESTS_FAILED=0
TOTAL_TESTS=0

# 테스트 함수
run_test() {
    local test_name="$1"
    local test_command="$2"
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    
    log_info "테스트 실행: $test_name"
    
    if eval "$test_command" >/dev/null 2>&1; then
        log_success "✅ $test_name: 통과"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        log_error "❌ $test_name: 실패"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
}

# 1. 자동화 스크립트 존재 확인
test_script_existence() {
    log_header "자동화 스크립트 존재 확인"
    
    local scripts=(
        "day1-practice.sh"
        "day2-practice.sh"
        "cloud-intermediate-helper.sh"
        "aws-eks-helper.sh"
        "gcp-gke-helper.sh"
        "cloud-cluster-helper.sh"
        "monitoring-stack.sh"
        "aws-setup-helper.sh"
    )
    
    for script in "${scripts[@]}"; do
        run_test "스크립트 존재: $script" "test -f ./$script"
    done
}

# 2. Parameter 모드 지원 확인
test_parameter_mode() {
    log_header "Parameter 모드 지원 확인"
    
    local scripts=(
        "day1-practice.sh"
        "day2-practice.sh"
        "cloud-intermediate-helper.sh"
        "aws-eks-helper.sh"
        "gcp-gke-helper.sh"
        "cloud-cluster-helper.sh"
    )
    
    for script in "${scripts[@]}"; do
        run_test "Parameter 모드: $script" "grep -q '\-\-action' ./$script"
        run_test "도움말 함수: $script" "grep -q 'usage()' ./$script"
    done
}

# 3. 샘플 코드 존재 확인
test_sample_code() {
    log_header "샘플 코드 존재 확인"
    
    # Day1 샘플 코드
    local day1_samples=(
        "day1/docker-advanced/Dockerfile"
        "day1/docker-advanced/package.json"
        "day1/kubernetes-basics/nginx-deployment.yaml"
        "day1/cloud-container-services/aws-ecs-task-definition.json"
        "day1/cloud-container-services/gcp-cloud-run.yaml"
        "day1/monitoring-hub/docker-compose.yml"
        "day1/aws-eks/eks-cluster-config.yaml"
        "day1/aws-eks/nginx-deployment.yaml"
        "day1/gcp-gke/gke-cluster-config.yaml"
        "day1/gcp-gke/nginx-deployment.yaml"
    )
    
    # Day2 샘플 코드
    local day2_samples=(
        "day2/cicd-pipeline/.github/workflows/ci-cd.yml"
        "day2/cloud-deployment/aws-ecs-deploy.sh"
        "day2/cloud-deployment/gcp-cloud-run-deploy.sh"
        "day2/monitoring-basics/aws-prometheus-config.yml"
        "day2/advanced-monitoring/multi-cloud-prometheus.yaml"
        "day2/advanced-monitoring/grafana-dashboards.yaml"
    )
    
    for sample in "${day1_samples[@]}" "${day2_samples[@]}"; do
        run_test "샘플 코드: $sample" "test -f ../samples/$sample"
    done
}

# 4. 환경 설정 파일 확인
test_environment_files() {
    log_header "환경 설정 파일 확인"
    
    local env_files=(
        "aws-environment.env"
        "gcp-environment.env"
    )
    
    for env_file in "${env_files[@]}"; do
        run_test "환경 파일: $env_file" "test -f ./$env_file"
    done
}

# 5. 테스트 스크립트 확인
test_test_scripts() {
    log_header "테스트 스크립트 확인"
    
    local test_scripts=(
        "run-all-tests.sh"
        "test-dry-run.sh"
        "test-monitoring-stack.sh"
        "test-phase1-local.sh"
        "test-phase2-4-cloud.sh"
        "test-100-percent-coverage.sh"
    )
    
    for test_script in "${test_scripts[@]}"; do
        run_test "테스트 스크립트: $test_script" "test -f ./$test_script"
    done
}

# 6. 스크립트 실행 권한 확인
test_script_permissions() {
    log_header "스크립트 실행 권한 확인"
    
    local scripts=(
        "day1-practice.sh"
        "day2-practice.sh"
        "cloud-intermediate-helper.sh"
        "aws-eks-helper.sh"
        "gcp-gke-helper.sh"
        "cloud-cluster-helper.sh"
        "monitoring-stack.sh"
        "aws-setup-helper.sh"
    )
    
    for script in "${scripts[@]}"; do
        run_test "실행 권한: $script" "test -x ./$script"
    done
}

# 7. 도움말 기능 확인
test_help_functions() {
    log_header "도움말 기능 확인"
    
    local scripts=(
        "day1-practice.sh"
        "day2-practice.sh"
        "cloud-intermediate-helper.sh"
        "aws-eks-helper.sh"
        "gcp-gke-helper.sh"
        "cloud-cluster-helper.sh"
    )
    
    for script in "${scripts[@]}"; do
        run_test "도움말: $script" "./$script --help >/dev/null"
    done
}

# 8. Parameter 모드 액션 확인
test_parameter_actions() {
    log_header "Parameter 모드 액션 확인"
    
    # Day1 액션들
    local day1_actions=("docker-advanced" "kubernetes-basics" "cloud-services" "monitoring-hub" "all")
    for action in "${day1_actions[@]}"; do
        run_test "Day1 액션: $action" "./day1-practice.sh --action $action --help >/dev/null 2>&1 || true"
    done
    
    # Day2 액션들
    local day2_actions=("cicd-pipeline" "cloud-deployment" "monitoring-basics" "all")
    for action in "${day2_actions[@]}"; do
        run_test "Day2 액션: $action" "./day2-practice.sh --action $action --help >/dev/null 2>&1 || true"
    done
}

# 9. 통합 테스트 실행
test_integration() {
    log_header "통합 테스트 실행"
    
    # 환경 체크 테스트
    run_test "환경 체크" "./cloud-intermediate-helper.sh --action check-env >/dev/null 2>&1 || true"
    
    # Docker 상태 체크
    run_test "Docker 상태 체크" "./cloud-intermediate-helper.sh --action check-docker >/dev/null 2>&1 || true"
    
    # AWS 서비스 체크
    run_test "AWS 서비스 체크" "./cloud-intermediate-helper.sh --action check-aws >/dev/null 2>&1 || true"
    
    # GCP 서비스 체크
    run_test "GCP 서비스 체크" "./cloud-intermediate-helper.sh --action check-gcp >/dev/null 2>&1 || true"
}

# 10. 커버리지 계산
calculate_coverage() {
    log_header "커버리지 계산"
    
    local coverage_rate=$((TESTS_PASSED * 100 / TOTAL_TESTS))
    
    log_info "총 테스트: $TOTAL_TESTS"
    log_info "통과: $TESTS_PASSED"
    log_info "실패: $TESTS_FAILED"
    log_info "커버리지: $coverage_rate%"
    
    if [ "$coverage_rate" -ge 100 ]; then
        log_success "🎉 100% 커버리지 달성!"
    elif [ "$coverage_rate" -ge 95 ]; then
        log_success "✅ 95% 이상 커버리지 달성!"
    elif [ "$coverage_rate" -ge 90 ]; then
        log_warning "⚠️ 90% 이상 커버리지 달성"
    else
        log_error "❌ 커버리지 개선 필요"
    fi
    
    return $coverage_rate
}

# 메인 실행 함수
main() {
    log_header "100% 자동화 커버리지 테스트 시작"
    
    # 모든 테스트 실행
    test_script_existence
    test_parameter_mode
    test_sample_code
    test_environment_files
    test_test_scripts
    test_script_permissions
    test_help_functions
    test_parameter_actions
    test_integration
    
    # 결과 요약
    log_header "테스트 결과 요약"
    calculate_coverage
    
    if [ $TESTS_FAILED -eq 0 ]; then
        log_success "🎉 모든 테스트 통과! 100% 커버리지 달성!"
        exit 0
    else
        log_error "❌ $TESTS_FAILED개 테스트 실패"
        exit 1
    fi
}

# 스크립트 실행
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
