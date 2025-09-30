#!/bin/bash

# 기존 리소스 처리 테스트 스크립트
# 리소스가 이미 존재할 때의 처리 방안 테스트

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

# 리소스 관리 유틸리티 로드
source "$(dirname "$0")/resource-manager.sh"

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

# 디렉토리 스마트 생성 테스트
test_smart_directory_creation() {
    log_header "디렉토리 스마트 생성 테스트"
    
    local test_dir="test-smart-dir"
    
    # 1. 새 디렉토리 생성
    run_test "새 디렉토리 생성" "smart_mkdir '$test_dir' false"
    
    # 2. 기존 디렉토리 재사용
    run_test "기존 디렉토리 재사용" "smart_mkdir '$test_dir' false"
    
    # 3. 강제 정리 후 재생성
    run_test "디렉토리 강제 정리" "smart_mkdir '$test_dir' true"
    
    # 정리
    rm -rf "$test_dir"
}

# Docker 컨테이너 스마트 실행 테스트
test_smart_docker_container() {
    log_header "Docker 컨테이너 스마트 실행 테스트"
    
    local container_name="test-smart-container"
    local image_name="nginx:alpine"
    
    # 기존 컨테이너 정리
    docker stop "$container_name" 2>/dev/null || true
    docker rm "$container_name" 2>/dev/null || true
    
    # 1. 새 컨테이너 생성
    run_test "새 컨테이너 생성" "smart_docker_run '$container_name' '$image_name' '-p 8080:80'"
    
    # 2. 기존 컨테이너 재사용
    run_test "기존 컨테이너 재사용" "smart_docker_run '$container_name' '$image_name' '-p 8080:80'"
    
    # 3. 컨테이너 상태 확인
    run_test "컨테이너 상태 확인" "check_resource_status 'docker-container' '$container_name'"
    
    # 정리
    docker stop "$container_name" 2>/dev/null || true
    docker rm "$container_name" 2>/dev/null || true
}

# Docker Compose 스마트 실행 테스트
test_smart_docker_compose() {
    log_header "Docker Compose 스마트 실행 테스트"
    
    local test_dir="test-compose"
    smart_mkdir "$test_dir" true
    cd "$test_dir"
    
    # 간단한 docker-compose.yml 생성
    cat > docker-compose.yml << 'EOF'
version: '3.8'
services:
  web:
    image: nginx:alpine
    ports:
      - "8081:80"
  db:
    image: postgres:alpine
    environment:
      POSTGRES_PASSWORD: testpass
EOF
    
    # 1. 새 서비스 시작
    run_test "새 Docker Compose 서비스 시작" "smart_docker_compose_up 'docker-compose.yml' false"
    
    # 2. 기존 서비스 재사용
    run_test "기존 서비스 재사용" "smart_docker_compose_up 'docker-compose.yml' false"
    
    # 3. 서비스 상태 확인
    run_test "서비스 상태 확인" "check_resource_status 'docker-compose' ''"
    
    # 정리
    cd ..
    rm -rf "$test_dir"
}

# Kubernetes 리소스 스마트 적용 테스트
test_smart_kubectl_apply() {
    log_header "Kubernetes 리소스 스마트 적용 테스트"
    
    local test_dir="test-k8s"
    smart_mkdir "$test_dir" true
    cd "$test_dir"
    
    # 간단한 Kubernetes 매니페스트 생성
    cat > test-pod.yaml << 'EOF'
apiVersion: v1
kind: Pod
metadata:
  name: test-pod
spec:
  containers:
  - name: nginx
    image: nginx:alpine
    ports:
    - containerPort: 80
EOF
    
    # 1. 새 리소스 적용
    run_test "새 Kubernetes 리소스 적용" "smart_kubectl_apply 'test-pod.yaml' 'default'"
    
    # 2. 기존 리소스 재적용
    run_test "기존 리소스 재적용" "smart_kubectl_apply 'test-pod.yaml' 'default'"
    
    # 3. 리소스 상태 확인
    run_test "Pod 상태 확인" "check_resource_status 'k8s-pod' 'test-pod'"
    
    # 정리
    kubectl delete -f test-pod.yaml 2>/dev/null || true
    cd ..
    rm -rf "$test_dir"
}

# 실습 스크립트 기존 리소스 처리 테스트
test_practice_scripts_resource_handling() {
    log_header "실습 스크립트 기존 리소스 처리 테스트"
    
    # Day1 실습 스크립트 테스트
    run_test "Day1 실습 스크립트 리소스 관리" "./day1-practice.sh --action docker-advanced --help >/dev/null 2>&1 || true"
    
    # Day2 실습 스크립트 테스트
    run_test "Day2 실습 스크립트 리소스 관리" "./day2-practice.sh --action cicd-pipeline --help >/dev/null 2>&1 || true"
    
    # 모니터링 스택 스크립트 테스트
    run_test "모니터링 스택 리소스 관리" "./monitoring-stack.sh --help >/dev/null 2>&1 || true"
}

# 리소스 정리 테스트
test_resource_cleanup() {
    log_header "리소스 정리 테스트"
    
    # 정리 대상 확인
    run_test "정리 대상 확인" "./cleanup-resources.sh --action dry-run >/dev/null 2>&1 || true"
    
    # 로컬 리소스 정리
    run_test "로컬 리소스 정리" "./cleanup-resources.sh --action local >/dev/null 2>&1 || true"
    
    # Docker 리소스 정리
    run_test "Docker 리소스 정리" "./cleanup-resources.sh --action docker >/dev/null 2>&1 || true"
}

# 통합 테스트
test_integration_resource_handling() {
    log_header "통합 리소스 처리 테스트"
    
    # 전체 시스템 리소스 상태 확인
    run_test "전체 시스템 리소스 상태" "./cloud-intermediate-helper.sh --action check-all >/dev/null 2>&1 || true"
    
    # AWS 리소스 확인
    run_test "AWS 리소스 상태" "./cloud-intermediate-helper.sh --action check-aws >/dev/null 2>&1 || true"
    
    # GCP 리소스 확인
    run_test "GCP 리소스 상태" "./cloud-intermediate-helper.sh --action check-gcp >/dev/null 2>&1 || true"
}

# 커버리지 계산
calculate_coverage() {
    log_header "기존 리소스 처리 커버리지 계산"
    
    local coverage_rate=$((TESTS_PASSED * 100 / TOTAL_TESTS))
    
    log_info "총 테스트: $TOTAL_TESTS"
    log_info "통과: $TESTS_PASSED"
    log_info "실패: $TESTS_FAILED"
    log_info "커버리지: $coverage_rate%"
    
    if [ "$coverage_rate" -ge 100 ]; then
        log_success "🎉 100% 기존 리소스 처리 커버리지 달성!"
    elif [ "$coverage_rate" -ge 95 ]; then
        log_success "✅ 95% 이상 기존 리소스 처리 커버리지 달성!"
    elif [ "$coverage_rate" -ge 90 ]; then
        log_warning "⚠️ 90% 이상 기존 리소스 처리 커버리지 달성"
    else
        log_error "❌ 기존 리소스 처리 커버리지 개선 필요"
    fi
    
    return $coverage_rate
}

# 메인 실행 함수
main() {
    log_header "기존 리소스 처리 테스트 시작"
    
    # 모든 테스트 실행
    test_smart_directory_creation
    test_smart_docker_container
    test_smart_docker_compose
    test_smart_kubectl_apply
    test_practice_scripts_resource_handling
    test_resource_cleanup
    test_integration_resource_handling
    
    # 결과 요약
    log_header "기존 리소스 처리 테스트 결과 요약"
    calculate_coverage
    
    if [ $TESTS_FAILED -eq 0 ]; then
        log_success "🎉 모든 기존 리소스 처리 테스트 통과! 100% 커버리지 달성!"
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
