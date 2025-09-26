#!/bin/bash

# Cloud Intermediate - Phase 1 로컬 테스트 스크립트
# 통합 모니터링 허브 로컬 테스트 (Docker Compose)

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
MONITORING_DIR="samples/day1/monitoring-hub"
TEST_DURATION=60  # 테스트 지속 시간 (초)
CLEANUP_AFTER_TEST=true

# 테스트 결과 저장
TEST_RESULTS=()
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
    else
        FAILED_TESTS=$((FAILED_TESTS + 1))
        log_error "❌ $test_name: $message"
    fi
}

# 사전 요구사항 확인
check_prerequisites() {
    log_header "사전 요구사항 확인"
    
    # Docker 확인
    if ! command -v docker &> /dev/null; then
        log_error "Docker가 설치되지 않았습니다."
        exit 1
    fi
    
    # Docker Compose 확인
    if ! command -v docker-compose &> /dev/null; then
        log_error "Docker Compose가 설치되지 않았습니다."
        exit 1
    fi
    
    # Docker 서비스 실행 확인
    if ! docker info &> /dev/null; then
        log_error "Docker 서비스가 실행되지 않았습니다."
        exit 1
    fi
    
    log_success "사전 요구사항 확인 완료"
}

# 테스트 환경 준비
setup_test_environment() {
    log_header "테스트 환경 준비"
    
    # 모니터링 디렉토리 확인
    if [ ! -d "$MONITORING_DIR" ]; then
        log_error "모니터링 디렉토리가 없습니다: $MONITORING_DIR"
        exit 1
    fi
    
    # 기존 컨테이너 정리
    log_info "기존 컨테이너 정리 중..."
    cd "$MONITORING_DIR"
    docker-compose down -v > /dev/null 2>&1 || true
    cd - > /dev/null
    
    log_success "테스트 환경 준비 완료"
}

# Docker Compose 서비스 시작 테스트
test_docker_compose_start() {
    log_header "Docker Compose 서비스 시작 테스트"
    
    cd "$MONITORING_DIR"
    
    # Docker Compose 서비스 시작
    log_info "Docker Compose 서비스 시작 중..."
    if docker-compose up -d; then
        record_test_result "DockerCompose_Start" "PASS" "Docker Compose 서비스 시작 성공"
    else
        record_test_result "DockerCompose_Start" "FAIL" "Docker Compose 서비스 시작 실패"
        return 1
    fi
    
    # 서비스 시작 대기
    log_info "서비스 시작 대기 중... (30초)"
    sleep 30
    
    cd - > /dev/null
}

# 서비스 상태 확인
test_services_status() {
    log_header "서비스 상태 확인"
    
    cd "$MONITORING_DIR"
    
    # 모든 서비스 상태 확인
    local services=("prometheus" "grafana" "node-exporter" "pushgateway" "alertmanager")
    
    for service in "${services[@]}"; do
        if docker-compose ps | grep -q "$service.*Up"; then
            record_test_result "Service_${service}" "PASS" "$service 서비스 정상 실행"
        else
            record_test_result "Service_${service}" "FAIL" "$service 서비스 실행 실패"
        fi
    done
    
    cd - > /dev/null
}

# 서비스 접근성 테스트
test_services_accessibility() {
    log_header "서비스 접근성 테스트"
    
    # Prometheus 접근성 테스트
    log_info "Prometheus 접근성 테스트..."
    if curl -s http://localhost:9090/api/v1/query?query=up > /dev/null; then
        record_test_result "Prometheus_Access" "PASS" "Prometheus API 접근 가능"
    else
        record_test_result "Prometheus_Access" "FAIL" "Prometheus API 접근 불가"
    fi
    
    # Grafana 접근성 테스트
    log_info "Grafana 접근성 테스트..."
    if curl -s http://localhost:3000/api/health > /dev/null; then
        record_test_result "Grafana_Access" "PASS" "Grafana API 접근 가능"
    else
        record_test_result "Grafana_Access" "FAIL" "Grafana API 접근 불가"
    fi
    
    # Node Exporter 접근성 테스트
    log_info "Node Exporter 접근성 테스트..."
    if curl -s http://localhost:9100/metrics > /dev/null; then
        record_test_result "NodeExporter_Access" "PASS" "Node Exporter 메트릭 접근 가능"
    else
        record_test_result "NodeExporter_Access" "FAIL" "Node Exporter 메트릭 접근 불가"
    fi
    
    # Push Gateway 접근성 테스트
    log_info "Push Gateway 접근성 테스트..."
    if curl -s http://localhost:9091/metrics > /dev/null; then
        record_test_result "PushGateway_Access" "PASS" "Push Gateway 메트릭 접근 가능"
    else
        record_test_result "PushGateway_Access" "FAIL" "Push Gateway 메트릭 접근 불가"
    fi
    
    # AlertManager 접근성 테스트
    log_info "AlertManager 접근성 테스트..."
    if curl -s http://localhost:9093/api/v1/status > /dev/null; then
        record_test_result "AlertManager_Access" "PASS" "AlertManager API 접근 가능"
    else
        record_test_result "AlertManager_Access" "FAIL" "AlertManager API 접근 불가"
    fi
}

# 메트릭 수집 테스트
test_metrics_collection() {
    log_header "메트릭 수집 테스트"
    
    # Prometheus에서 메트릭 쿼리 테스트
    log_info "Prometheus 메트릭 쿼리 테스트..."
    
    # up 메트릭 확인
    if curl -s "http://localhost:9090/api/v1/query?query=up" | grep -q "result"; then
        record_test_result "Prometheus_Up_Metric" "PASS" "up 메트릭 수집 확인"
    else
        record_test_result "Prometheus_Up_Metric" "FAIL" "up 메트릭 수집 실패"
    fi
    
    # node_exporter 메트릭 확인
    if curl -s "http://localhost:9090/api/v1/query?query=node_cpu_seconds_total" | grep -q "result"; then
        record_test_result "Prometheus_Node_Metric" "PASS" "node_exporter 메트릭 수집 확인"
    else
        record_test_result "Prometheus_Node_Metric" "FAIL" "node_exporter 메트릭 수집 실패"
    fi
    
    # pushgateway 메트릭 확인
    if curl -s "http://localhost:9090/api/v1/query?query=pushgateway_build_info" | grep -q "result"; then
        record_test_result "Prometheus_PushGateway_Metric" "PASS" "pushgateway 메트릭 수집 확인"
    else
        record_test_result "Prometheus_PushGateway_Metric" "FAIL" "pushgateway 메트릭 수집 실패"
    fi
}

# Push Gateway 테스트
test_push_gateway() {
    log_header "Push Gateway 테스트"
    
    # 테스트 메트릭 생성
    local test_metric="test_metric{job=\"test-job\"} 42"
    
    # Push Gateway에 메트릭 전송
    log_info "Push Gateway에 테스트 메트릭 전송..."
    if echo "$test_metric" | curl -s --data-binary @- http://localhost:9091/metrics/job/test-job; then
        record_test_result "PushGateway_Push" "PASS" "Push Gateway 메트릭 전송 성공"
    else
        record_test_result "PushGateway_Push" "FAIL" "Push Gateway 메트릭 전송 실패"
    fi
    
    # 잠시 대기
    sleep 5
    
    # Prometheus에서 테스트 메트릭 확인
    log_info "Prometheus에서 테스트 메트릭 확인..."
    if curl -s "http://localhost:9090/api/v1/query?query=test_metric" | grep -q "42"; then
        record_test_result "PushGateway_Query" "PASS" "Push Gateway 메트릭 쿼리 성공"
    else
        record_test_result "PushGateway_Query" "FAIL" "Push Gateway 메트릭 쿼리 실패"
    fi
}

# Grafana 대시보드 테스트
test_grafana_dashboard() {
    log_header "Grafana 대시보드 테스트"
    
    # Grafana 데이터소스 확인
    log_info "Grafana 데이터소스 확인..."
    if curl -s -u admin:admin123 http://localhost:3000/api/datasources | grep -q "Prometheus"; then
        record_test_result "Grafana_Datasource" "PASS" "Grafana Prometheus 데이터소스 확인"
    else
        record_test_result "Grafana_Datasource" "FAIL" "Grafana Prometheus 데이터소스 없음"
    fi
    
    # Grafana 대시보드 목록 확인
    log_info "Grafana 대시보드 목록 확인..."
    if curl -s -u admin:admin123 http://localhost:3000/api/search?type=dash-db | grep -q "dashboards"; then
        record_test_result "Grafana_Dashboards" "PASS" "Grafana 대시보드 목록 확인"
    else
        record_test_result "Grafana_Dashboards" "FAIL" "Grafana 대시보드 목록 없음"
    fi
}

# 로그 확인
test_logs() {
    log_header "서비스 로그 확인"
    
    cd "$MONITORING_DIR"
    
    # 각 서비스의 로그 확인
    local services=("prometheus" "grafana" "node-exporter" "pushgateway" "alertmanager")
    
    for service in "${services[@]}"; do
        log_info "$service 로그 확인..."
        if docker-compose logs "$service" 2>&1 | grep -q -E "(error|Error|ERROR)"; then
            record_test_result "Logs_${service}" "FAIL" "$service 로그에 오류 발견"
        else
            record_test_result "Logs_${service}" "PASS" "$service 로그 정상"
        fi
    done
    
    cd - > /dev/null
}

# 성능 테스트
test_performance() {
    log_header "성능 테스트"
    
    # Prometheus 응답 시간 테스트
    log_info "Prometheus 응답 시간 테스트..."
    local response_time=$(curl -s -w "%{time_total}" -o /dev/null http://localhost:9090/api/v1/query?query=up)
    local response_time_ms=$(echo "$response_time * 1000" | bc)
    
    if (( $(echo "$response_time_ms < 1000" | bc -l) )); then
        record_test_result "Prometheus_Performance" "PASS" "Prometheus 응답 시간: ${response_time_ms}ms"
    else
        record_test_result "Prometheus_Performance" "FAIL" "Prometheus 응답 시간 느림: ${response_time_ms}ms"
    fi
    
    # Grafana 응답 시간 테스트
    log_info "Grafana 응답 시간 테스트..."
    local response_time=$(curl -s -w "%{time_total}" -o /dev/null http://localhost:3000/api/health)
    local response_time_ms=$(echo "$response_time * 1000" | bc)
    
    if (( $(echo "$response_time_ms < 2000" | bc -l) )); then
        record_test_result "Grafana_Performance" "PASS" "Grafana 응답 시간: ${response_time_ms}ms"
    else
        record_test_result "Grafana_Performance" "FAIL" "Grafana 응답 시간 느림: ${response_time_ms}ms"
    fi
}

# 테스트 환경 정리
cleanup_test_environment() {
    log_header "테스트 환경 정리"
    
    cd "$MONITORING_DIR"
    
    # Docker Compose 서비스 중지
    log_info "Docker Compose 서비스 중지 중..."
    docker-compose down -v
    
    # 볼륨 정리
    log_info "Docker 볼륨 정리 중..."
    docker volume prune -f > /dev/null 2>&1 || true
    
    cd - > /dev/null
    
    log_success "테스트 환경 정리 완료"
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
        log_success "🎉 Phase 1 테스트 통과! (${success_rate}%)"
    elif [ "$success_rate" -ge 70 ]; then
        log_warning "⚠️ Phase 1 테스트 부분 통과 (${success_rate}%)"
    else
        log_error "❌ Phase 1 테스트 실패 (${success_rate}%)"
    fi
}

# 메인 실행 함수
main() {
    log_header "Cloud Intermediate Phase 1 로컬 테스트 시작"
    
    # 사전 요구사항 확인
    check_prerequisites
    
    # 테스트 환경 준비
    setup_test_environment
    
    # Docker Compose 서비스 시작 테스트
    test_docker_compose_start
    
    # 서비스 상태 확인
    test_services_status
    
    # 서비스 접근성 테스트
    test_services_accessibility
    
    # 메트릭 수집 테스트
    test_metrics_collection
    
    # Push Gateway 테스트
    test_push_gateway
    
    # Grafana 대시보드 테스트
    test_grafana_dashboard
    
    # 로그 확인
    test_logs
    
    # 성능 테스트
    test_performance
    
    # 테스트 결과 요약
    print_test_summary
    
    # 테스트 환경 정리
    if [ "$CLEANUP_AFTER_TEST" = true ]; then
        cleanup_test_environment
    fi
    
    log_header "Phase 1 로컬 테스트 완료"
}

# 스크립트 실행
main "$@"
