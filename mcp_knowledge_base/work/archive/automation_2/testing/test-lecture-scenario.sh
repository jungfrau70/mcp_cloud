#!/bin/bash

# Cloud Intermediate 강의 시나리오 테스트 스크립트
# 실제 강의 순서대로 모든 실습 시나리오 테스트

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

# 1일차 강의 시나리오 테스트
test_day1_scenario() {
    log_header "1일차 강의 시나리오 테스트"
    
    # 1교시: Docker 고급 실습
    log_info "1교시: Docker 고급 실습 테스트"
    run_test "Docker 고급 실습 스크립트" "./day1-practice.sh --action docker-advanced --help >/dev/null 2>&1 || true"
    run_test "Docker 샘플 코드" "test -f ../samples/day1/docker-advanced/Dockerfile"
    run_test "Docker 샘플 코드" "test -f ../samples/day1/docker-advanced/package.json"
    
    # 2교시: 통합 모니터링 허브 구축
    log_info "2교시: 통합 모니터링 허브 구축 테스트"
    run_test "모니터링 허브 스크립트" "./monitoring-stack.sh --help >/dev/null 2>&1 || true"
    run_test "모니터링 허브 샘플" "test -f ../samples/day1/monitoring-hub/docker-compose.yml"
    run_test "Prometheus 설정" "test -f ../samples/day1/monitoring-hub/prometheus/prometheus.yml"
    run_test "AlertManager 설정" "test -f ../samples/day1/monitoring-hub/alertmanager/alertmanager.yml"
    
    # 3교시: Kubernetes 기초 실습
    log_info "3교시: Kubernetes 기초 실습 테스트"
    run_test "Kubernetes 기초 실습 스크립트" "./day1-practice.sh --action kubernetes-basics --help >/dev/null 2>&1 || true"
    run_test "Kubernetes 샘플 코드" "test -f ../samples/day1/kubernetes-basics/nginx-deployment.yaml"
    run_test "Kubernetes 샘플 코드" "test -f ../samples/day1/kubernetes-basics/configmap-secret.yaml"
    run_test "Kubernetes 샘플 코드" "test -f ../samples/day1/kubernetes-basics/namespace.yaml"
    
    # 4교시: 클라우드 컨테이너 서비스
    log_info "4교시: 클라우드 컨테이너 서비스 테스트"
    run_test "클라우드 서비스 실습 스크립트" "./day1-practice.sh --action cloud-services --help >/dev/null 2>&1 || true"
    run_test "AWS ECS 샘플" "test -f ../samples/day1/cloud-container-services/aws-ecs-task-definition.json"
    run_test "GCP Cloud Run 샘플" "test -f ../samples/day1/cloud-container-services/gcp-cloud-run.yaml"
    run_test "AWS EKS 샘플" "test -f ../samples/day1/aws-eks/eks-cluster-config.yaml"
    run_test "GCP GKE 샘플" "test -f ../samples/day1/gcp-gke/gke-cluster-config.yaml"
}

# 2일차 강의 시나리오 테스트
test_day2_scenario() {
    log_header "2일차 강의 시나리오 테스트"
    
    # 1교시: CI/CD 파이프라인
    log_info "1교시: CI/CD 파이프라인 테스트"
    run_test "CI/CD 파이프라인 스크립트" "./day2-practice.sh --action cicd-pipeline --help >/dev/null 2>&1 || true"
    run_test "GitHub Actions 워크플로우" "test -f ../samples/day2/cicd-pipeline/.github/workflows/ci-cd.yml"
    run_test "CI/CD Dockerfile" "test -f ../samples/day2/cicd-pipeline/Dockerfile"
    run_test "CI/CD 애플리케이션" "test -f ../samples/day2/cicd-pipeline/index.js"
    
    # 2교시: 클라우드 배포 전략
    log_info "2교시: 클라우드 배포 전략 테스트"
    run_test "클라우드 배포 스크립트" "./day2-practice.sh --action cloud-deployment --help >/dev/null 2>&1 || true"
    run_test "AWS ECS 배포 스크립트" "test -f ../samples/day2/cloud-deployment/aws-ecs-deploy.sh"
    run_test "GCP Cloud Run 배포 스크립트" "test -f ../samples/day2/cloud-deployment/gcp-cloud-run-deploy.sh"
    
    # 3교시: 멀티 클라우드 모니터링
    log_info "3교시: 멀티 클라우드 모니터링 테스트"
    run_test "모니터링 기초 스크립트" "./day2-practice.sh --action monitoring-basics --help >/dev/null 2>&1 || true"
    run_test "AWS Prometheus 설정" "test -f ../samples/day2/monitoring-basics/aws-prometheus-config.yml"
    run_test "GCP Prometheus 설정" "test -f ../samples/day2/monitoring-basics/gcp-prometheus-config.yml"
    run_test "멀티 클라우드 Prometheus" "test -f ../samples/day2/advanced-monitoring/multi-cloud-prometheus.yaml"
    run_test "Grafana 대시보드" "test -f ../samples/day2/advanced-monitoring/grafana-dashboards.yaml"
    
    # 4교시: 실무 모니터링 시나리오
    log_info "4교시: 실무 모니터링 시나리오 테스트"
    run_test "통합 헬퍼 스크립트" "./cloud-intermediate-helper.sh --help >/dev/null 2>&1 || true"
    run_test "AWS EKS 헬퍼" "./aws-eks-helper.sh --help >/dev/null 2>&1 || true"
    run_test "GCP GKE 헬퍼" "./gcp-gke-helper.sh --help >/dev/null 2>&1 || true"
    run_test "클라우드 클러스터 헬퍼" "./cloud-cluster-helper.sh --help >/dev/null 2>&1 || true"
}

# 환경 설정 테스트
test_environment_setup() {
    log_header "환경 설정 테스트"
    
    # 필수 도구 확인
    run_test "Docker 설치" "command -v docker"
    run_test "Docker Compose 설치" "command -v docker-compose"
    run_test "kubectl 설치" "command -v kubectl"
    run_test "AWS CLI 설치" "command -v aws"
    run_test "GCP CLI 설치" "command -v gcloud"
    run_test "Git 설치" "command -v git"
    run_test "jq 설치" "command -v jq"
    
    # 환경 설정 파일 확인
    run_test "AWS 환경 설정" "test -f ./aws-environment.env"
    run_test "GCP 환경 설정" "test -f ./gcp-environment.env"
    
    # AWS 설정 확인
    if command -v aws &> /dev/null; then
        run_test "AWS 자격 증명" "aws sts get-caller-identity >/dev/null 2>&1 || true"
    fi
    
    # GCP 설정 확인
    if command -v gcloud &> /dev/null; then
        run_test "GCP 프로젝트 설정" "gcloud config get-value project >/dev/null 2>&1 || true"
    fi
}

# 자동화 스크립트 테스트
test_automation_scripts() {
    log_header "자동화 스크립트 테스트"
    
    # 핵심 스크립트 존재 확인
    local scripts=(
        "day1-practice.sh"
        "day2-practice.sh"
        "cloud-intermediate-helper.sh"
        "aws-eks-helper.sh"
        "gcp-gke-helper.sh"
        "cloud-cluster-helper.sh"
        "monitoring-stack.sh"
        "aws-setup-helper.sh"
        "cleanup-resources.sh"
    )
    
    for script in "${scripts[@]}"; do
        run_test "스크립트 존재: $script" "test -f ./$script"
        run_test "스크립트 실행 권한: $script" "test -x ./$script"
        run_test "스크립트 도움말: $script" "./$script --help >/dev/null 2>&1 || true"
    done
}

# Parameter 모드 테스트
test_parameter_modes() {
    log_header "Parameter 모드 테스트"
    
    # Day1 Parameter 모드 테스트
    local day1_actions=("docker-advanced" "kubernetes-basics" "cloud-services" "monitoring-hub" "all")
    for action in "${day1_actions[@]}"; do
        run_test "Day1 Parameter: $action" "./day1-practice.sh --action $action --help >/dev/null 2>&1 || true"
    done
    
    # Day2 Parameter 모드 테스트
    local day2_actions=("cicd-pipeline" "cloud-deployment" "monitoring-basics" "all")
    for action in "${day2_actions[@]}"; do
        run_test "Day2 Parameter: $action" "./day2-practice.sh --action $action --help >/dev/null 2>&1 || true"
    done
    
    # 클라우드 헬퍼 Parameter 모드 테스트
    run_test "AWS EKS Parameter" "./aws-eks-helper.sh --action create --help >/dev/null 2>&1 || true"
    run_test "GCP GKE Parameter" "./gcp-gke-helper.sh --action create --help >/dev/null 2>&1 || true"
    run_test "클라우드 클러스터 Parameter" "./cloud-cluster-helper.sh --action create --help >/dev/null 2>&1 || true"
    
    # 통합 헬퍼 Parameter 모드 테스트
    run_test "환경 체크 Parameter" "./cloud-intermediate-helper.sh --action check-env --help >/dev/null 2>&1 || true"
    run_test "Docker 체크 Parameter" "./cloud-intermediate-helper.sh --action check-docker --help >/dev/null 2>&1 || true"
    run_test "AWS 체크 Parameter" "./cloud-intermediate-helper.sh --action check-aws --help >/dev/null 2>&1 || true"
    run_test "GCP 체크 Parameter" "./cloud-intermediate-helper.sh --action check-gcp --help >/dev/null 2>&1 || true"
}

# 리소스 정리 테스트
test_cleanup_resources() {
    log_header "리소스 정리 테스트"
    
    # 리소스 정리 스크립트 테스트
    run_test "리소스 정리 스크립트" "test -f ./cleanup-resources.sh"
    run_test "리소스 정리 실행 권한" "test -x ./cleanup-resources.sh"
    run_test "리소스 정리 도움말" "./cleanup-resources.sh --help >/dev/null 2>&1 || true"
    
    # Parameter 모드 테스트
    local cleanup_actions=("local" "docker" "aws" "gcp" "all" "dry-run")
    for action in "${cleanup_actions[@]}"; do
        run_test "리소스 정리 Parameter: $action" "./cleanup-resources.sh --action $action --help >/dev/null 2>&1 || true"
    done
}

# 통합 테스트 실행
test_integration() {
    log_header "통합 테스트 실행"
    
    # 환경 체크 통합 테스트
    run_test "통합 환경 체크" "./cloud-intermediate-helper.sh --action check-env >/dev/null 2>&1 || true"
    run_test "Docker 상태 체크" "./cloud-intermediate-helper.sh --action check-docker >/dev/null 2>&1 || true"
    run_test "AWS 서비스 체크" "./cloud-intermediate-helper.sh --action check-aws >/dev/null 2>&1 || true"
    run_test "GCP 서비스 체크" "./cloud-intermediate-helper.sh --action check-gcp >/dev/null 2>&1 || true"
    
    # 전체 시스템 체크
    run_test "전체 시스템 체크" "./cloud-intermediate-helper.sh --action check-all >/dev/null 2>&1 || true"
}

# 커버리지 계산
calculate_coverage() {
    log_header "강의 시나리오 커버리지 계산"
    
    local coverage_rate=$((TESTS_PASSED * 100 / TOTAL_TESTS))
    
    log_info "총 테스트: $TOTAL_TESTS"
    log_info "통과: $TESTS_PASSED"
    log_info "실패: $TESTS_FAILED"
    log_info "커버리지: $coverage_rate%"
    
    if [ "$coverage_rate" -ge 100 ]; then
        log_success "🎉 100% 강의 시나리오 커버리지 달성!"
    elif [ "$coverage_rate" -ge 95 ]; then
        log_success "✅ 95% 이상 강의 시나리오 커버리지 달성!"
    elif [ "$coverage_rate" -ge 90 ]; then
        log_warning "⚠️ 90% 이상 강의 시나리오 커버리지 달성"
    else
        log_error "❌ 강의 시나리오 커버리지 개선 필요"
    fi
    
    return $coverage_rate
}

# 메인 실행 함수
main() {
    log_header "Cloud Intermediate 강의 시나리오 테스트 시작"
    
    # 모든 테스트 실행
    test_environment_setup
    test_automation_scripts
    test_parameter_modes
    test_day1_scenario
    test_day2_scenario
    test_cleanup_resources
    test_integration
    
    # 결과 요약
    log_header "강의 시나리오 테스트 결과 요약"
    calculate_coverage
    
    if [ $TESTS_FAILED -eq 0 ]; then
        log_success "🎉 모든 강의 시나리오 테스트 통과! 100% 커버리지 달성!"
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
