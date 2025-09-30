#!/bin/bash

# Cloud Intermediate - 통합 모니터링 스택 테스트 스크립트
# 멀티 클라우드 통합 모니터링 시스템 테스트

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
PROJECT_NAME="cloud-intermediate-monitoring"
TEST_DIR="./test-results"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
TEST_LOG="$TEST_DIR/test_$TIMESTAMP.log"

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
        echo "PASS: $test_name - $message" >> "$TEST_LOG"
    else
        FAILED_TESTS=$((FAILED_TESTS + 1))
        log_error "❌ $test_name: $message"
        echo "FAIL: $test_name - $message" >> "$TEST_LOG"
    fi
}

# 테스트 디렉토리 생성
setup_test_environment() {
    log_header "테스트 환경 설정"
    
    mkdir -p "$TEST_DIR"
    echo "테스트 시작: $(date)" > "$TEST_LOG"
    
    log_success "테스트 환경 설정 완료"
}

# Phase 1: 통합 모니터링 허브 테스트
test_phase1_monitoring_hub() {
    log_header "Phase 1: 통합 모니터링 허브 테스트"
    
    local phase1_dir="samples/day1/monitoring-hub"
    
    # 1. 디렉토리 존재 확인
    if [ -d "$phase1_dir" ]; then
        record_test_result "Phase1_Directory_Exists" "PASS" "monitoring-hub 디렉토리 존재"
    else
        record_test_result "Phase1_Directory_Exists" "FAIL" "monitoring-hub 디렉토리 없음"
        return 1
    fi
    
    # 2. Docker Compose 파일 확인
    if [ -f "$phase1_dir/docker-compose.yml" ]; then
        record_test_result "Phase1_DockerCompose_Exists" "PASS" "docker-compose.yml 파일 존재"
        
        # Docker Compose 파일 문법 검증
        if docker-compose -f "$phase1_dir/docker-compose.yml" config > /dev/null 2>&1; then
            record_test_result "Phase1_DockerCompose_Valid" "PASS" "docker-compose.yml 문법 검증 통과"
        else
            record_test_result "Phase1_DockerCompose_Valid" "FAIL" "docker-compose.yml 문법 오류"
        fi
    else
        record_test_result "Phase1_DockerCompose_Exists" "FAIL" "docker-compose.yml 파일 없음"
    fi
    
    # 3. Prometheus 설정 파일 확인
    if [ -f "$phase1_dir/prometheus/prometheus.yml" ]; then
        record_test_result "Phase1_PrometheusConfig_Exists" "PASS" "prometheus.yml 파일 존재"
        
        # Prometheus 설정 파일 검증
        if python3 -c "import yaml; yaml.safe_load(open('$phase1_dir/prometheus/prometheus.yml'))" 2>/dev/null; then
            record_test_result "Phase1_PrometheusConfig_Valid" "PASS" "prometheus.yml YAML 문법 검증 통과"
        else
            record_test_result "Phase1_PrometheusConfig_Valid" "FAIL" "prometheus.yml YAML 문법 오류"
        fi
    else
        record_test_result "Phase1_PrometheusConfig_Exists" "FAIL" "prometheus.yml 파일 없음"
    fi
    
    # 4. AlertManager 설정 파일 확인
    if [ -f "$phase1_dir/alertmanager/alertmanager.yml" ]; then
        record_test_result "Phase1_AlertManagerConfig_Exists" "PASS" "alertmanager.yml 파일 존재"
        
        # AlertManager 설정 파일 검증
        if python3 -c "import yaml; yaml.safe_load(open('$phase1_dir/alertmanager/alertmanager.yml'))" 2>/dev/null; then
            record_test_result "Phase1_AlertManagerConfig_Valid" "PASS" "alertmanager.yml YAML 문법 검증 통과"
        else
            record_test_result "Phase1_AlertManagerConfig_Valid" "FAIL" "alertmanager.yml YAML 문법 오류"
        fi
    else
        record_test_result "Phase1_AlertManagerConfig_Exists" "FAIL" "alertmanager.yml 파일 없음"
    fi
    
    # 5. Docker Compose 서비스 시작 테스트
    log_info "Docker Compose 서비스 시작 테스트..."
    cd "$phase1_dir"
    
    if docker-compose up -d > /dev/null 2>&1; then
        record_test_result "Phase1_DockerCompose_Start" "PASS" "Docker Compose 서비스 시작 성공"
        
        # 서비스 상태 확인
        sleep 10
        if docker-compose ps | grep -q "Up"; then
            record_test_result "Phase1_DockerCompose_Status" "PASS" "모든 서비스 정상 실행"
        else
            record_test_result "Phase1_DockerCompose_Status" "FAIL" "일부 서비스 실행 실패"
        fi
        
        # 서비스 중지
        docker-compose down > /dev/null 2>&1
    else
        record_test_result "Phase1_DockerCompose_Start" "FAIL" "Docker Compose 서비스 시작 실패"
    fi
    
    cd - > /dev/null
}

# Phase 2-4: 멀티 클라우드 모니터링 테스트
test_phase2_4_monitoring_basics() {
    log_header "Phase 2-4: 멀티 클라우드 모니터링 테스트"
    
    local phase2_dir="samples/day2/monitoring-basics"
    
    # 1. 디렉토리 존재 확인
    if [ -d "$phase2_dir" ]; then
        record_test_result "Phase2_Directory_Exists" "PASS" "monitoring-basics 디렉토리 존재"
    else
        record_test_result "Phase2_Directory_Exists" "FAIL" "monitoring-basics 디렉토리 없음"
        return 1
    fi
    
    # 2. AWS Prometheus 설정 파일 확인
    if [ -f "$phase2_dir/aws-prometheus-config.yml" ]; then
        record_test_result "Phase2_AWS_PrometheusConfig_Exists" "PASS" "aws-prometheus-config.yml 파일 존재"
        
        # AWS Prometheus 설정 파일 검증
        if python3 -c "import yaml; yaml.safe_load(open('$phase2_dir/aws-prometheus-config.yml'))" 2>/dev/null; then
            record_test_result "Phase2_AWS_PrometheusConfig_Valid" "PASS" "aws-prometheus-config.yml YAML 문법 검증 통과"
        else
            record_test_result "Phase2_AWS_PrometheusConfig_Valid" "FAIL" "aws-prometheus-config.yml YAML 문법 오류"
        fi
    else
        record_test_result "Phase2_AWS_PrometheusConfig_Exists" "FAIL" "aws-prometheus-config.yml 파일 없음"
    fi
    
    # 3. GCP Prometheus 설정 파일 확인
    if [ -f "$phase2_dir/gcp-prometheus-config.yml" ]; then
        record_test_result "Phase2_GCP_PrometheusConfig_Exists" "PASS" "gcp-prometheus-config.yml 파일 존재"
        
        # GCP Prometheus 설정 파일 검증
        if python3 -c "import yaml; yaml.safe_load(open('$phase2_dir/gcp-prometheus-config.yml'))" 2>/dev/null; then
            record_test_result "Phase2_GCP_PrometheusConfig_Valid" "PASS" "gcp-prometheus-config.yml YAML 문법 검증 통과"
        else
            record_test_result "Phase2_GCP_PrometheusConfig_Valid" "FAIL" "gcp-prometheus-config.yml YAML 문법 오류"
        fi
    else
        record_test_result "Phase2_GCP_PrometheusConfig_Exists" "FAIL" "gcp-prometheus-config.yml 파일 없음"
    fi
    
    # 4. Kubernetes 매니페스트 파일 확인
    local k8s_dir="$phase2_dir/k8s"
    if [ -d "$k8s_dir" ]; then
        record_test_result "Phase2_K8s_Directory_Exists" "PASS" "k8s 디렉토리 존재"
        
        # Kubernetes 매니페스트 파일들 검증
        for manifest in aws-app-deployment.yml aws-app-service.yml aws-app-monitoring.yml; do
            if [ -f "$k8s_dir/$manifest" ]; then
                record_test_result "Phase2_K8s_$manifest" "PASS" "$manifest 파일 존재"
                
                # Kubernetes 매니페스트 문법 검증
                if kubectl --dry-run=client apply -f "$k8s_dir/$manifest" > /dev/null 2>&1; then
                    record_test_result "Phase2_K8s_${manifest}_Valid" "PASS" "$manifest Kubernetes 문법 검증 통과"
                else
                    record_test_result "Phase2_K8s_${manifest}_Valid" "FAIL" "$manifest Kubernetes 문법 오류"
                fi
            else
                record_test_result "Phase2_K8s_$manifest" "FAIL" "$manifest 파일 없음"
            fi
        done
    else
        record_test_result "Phase2_K8s_Directory_Exists" "FAIL" "k8s 디렉토리 없음"
    fi
    
    # 5. GitHub Actions 워크플로우 확인
    local workflow_file="$phase2_dir/.github/workflows/deploy-aws-app.yml"
    if [ -f "$workflow_file" ]; then
        record_test_result "Phase2_GitHubActions_Exists" "PASS" "deploy-aws-app.yml 워크플로우 존재"
        
        # GitHub Actions 워크플로우 문법 검증
        if python3 -c "import yaml; yaml.safe_load(open('$workflow_file'))" 2>/dev/null; then
            record_test_result "Phase2_GitHubActions_Valid" "PASS" "GitHub Actions 워크플로우 YAML 문법 검증 통과"
        else
            record_test_result "Phase2_GitHubActions_Valid" "FAIL" "GitHub Actions 워크플로우 YAML 문법 오류"
        fi
    else
        record_test_result "Phase2_GitHubActions_Exists" "FAIL" "deploy-aws-app.yml 워크플로우 없음"
    fi
}

# 자동화 스크립트 테스트
test_automation_scripts() {
    log_header "자동화 스크립트 테스트"
    
    # 1. monitoring-stack.sh 스크립트 확인
    local script_file="scripts/monitoring-stack.sh"
    if [ -f "$script_file" ]; then
        record_test_result "Automation_Script_Exists" "PASS" "monitoring-stack.sh 스크립트 존재"
        
        # 스크립트 실행 권한 확인
        if [ -x "$script_file" ]; then
            record_test_result "Automation_Script_Executable" "PASS" "monitoring-stack.sh 실행 권한 있음"
        else
            record_test_result "Automation_Script_Executable" "FAIL" "monitoring-stack.sh 실행 권한 없음"
        fi
        
        # 스크립트 문법 검증
        if bash -n "$script_file" 2>/dev/null; then
            record_test_result "Automation_Script_Valid" "PASS" "monitoring-stack.sh 문법 검증 통과"
        else
            record_test_result "Automation_Script_Valid" "FAIL" "monitoring-stack.sh 문법 오류"
        fi
    else
        record_test_result "Automation_Script_Exists" "FAIL" "monitoring-stack.sh 스크립트 없음"
    fi
    
    # 2. test-monitoring-stack.sh 스크립트 확인
    local test_script_file="scripts/test-monitoring-stack.sh"
    if [ -f "$test_script_file" ]; then
        record_test_result "Test_Script_Exists" "PASS" "test-monitoring-stack.sh 스크립트 존재"
        
        # 스크립트 실행 권한 확인
        if [ -x "$test_script_file" ]; then
            record_test_result "Test_Script_Executable" "PASS" "test-monitoring-stack.sh 실행 권한 있음"
        else
            record_test_result "Test_Script_Executable" "FAIL" "test-monitoring-stack.sh 실행 권한 없음"
        fi
    else
        record_test_result "Test_Script_Exists" "FAIL" "test-monitoring-stack.sh 스크립트 없음"
    fi
}

# 사전 요구사항 확인
check_prerequisites() {
    log_header "사전 요구사항 확인"
    
    local missing_tools=()
    
    # Docker 확인
    if command -v docker &> /dev/null; then
        record_test_result "Prerequisites_Docker" "PASS" "Docker 설치됨"
    else
        record_test_result "Prerequisites_Docker" "FAIL" "Docker 설치되지 않음"
        missing_tools+=("docker")
    fi
    
    # Docker Compose 확인
    if command -v docker-compose &> /dev/null; then
        record_test_result "Prerequisites_DockerCompose" "PASS" "Docker Compose 설치됨"
    else
        record_test_result "Prerequisites_DockerCompose" "FAIL" "Docker Compose 설치되지 않음"
        missing_tools+=("docker-compose")
    fi
    
    # kubectl 확인
    if command -v kubectl &> /dev/null; then
        record_test_result "Prerequisites_Kubectl" "PASS" "kubectl 설치됨"
    else
        record_test_result "Prerequisites_Kubectl" "FAIL" "kubectl 설치되지 않음"
        missing_tools+=("kubectl")
    fi
    
    # Python3 확인
    if command -v python3 &> /dev/null; then
        record_test_result "Prerequisites_Python3" "PASS" "Python3 설치됨"
    else
        record_test_result "Prerequisites_Python3" "FAIL" "Python3 설치되지 않음"
        missing_tools+=("python3")
    fi
    
    # PyYAML 확인
    if python3 -c "import yaml" 2>/dev/null; then
        record_test_result "Prerequisites_PyYAML" "PASS" "PyYAML 설치됨"
    else
        record_test_result "Prerequisites_PyYAML" "FAIL" "PyYAML 설치되지 않음"
        missing_tools+=("PyYAML")
    fi
    
    if [ ${#missing_tools[@]} -gt 0 ]; then
        log_warning "누락된 도구들: ${missing_tools[*]}"
        log_info "다음 명령어로 설치하세요:"
        for tool in "${missing_tools[@]}"; do
            case $tool in
                "docker")
                    echo "  sudo apt-get update && sudo apt-get install -y docker.io"
                    ;;
                "docker-compose")
                    echo "  sudo apt-get install -y docker-compose"
                    ;;
                "kubectl")
                    echo "  curl -LO https://dl.k8s.io/release/\$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
                    echo "  sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl"
                    ;;
                "python3")
                    echo "  sudo apt-get install -y python3"
                    ;;
                "PyYAML")
                    echo "  pip3 install PyYAML"
                    ;;
            esac
        done
    fi
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
        log_success "🎉 테스트 통과! (${success_rate}%)"
    elif [ "$success_rate" -ge 70 ]; then
        log_warning "⚠️ 테스트 부분 통과 (${success_rate}%)"
    else
        log_error "❌ 테스트 실패 (${success_rate}%)"
    fi
    
    echo "상세 로그: $TEST_LOG"
}

# 메인 실행 함수
main() {
    log_header "Cloud Intermediate 통합 모니터링 스택 테스트 시작"
    
    # 테스트 환경 설정
    setup_test_environment
    
    # 사전 요구사항 확인
    check_prerequisites
    
    # Phase 1 테스트
    test_phase1_monitoring_hub
    
    # Phase 2-4 테스트
    test_phase2_4_monitoring_basics
    
    # 자동화 스크립트 테스트
    test_automation_scripts
    
    # 테스트 결과 요약
    print_test_summary
    
    log_header "테스트 완료"
}

# 스크립트 실행
main "$@"
