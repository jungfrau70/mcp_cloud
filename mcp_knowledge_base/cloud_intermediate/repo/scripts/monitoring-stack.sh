#!/bin/bash

# Cloud Intermediate - 모니터링 스택 자동화 스크립트
# Prometheus + Grafana + Node Exporter 스택 구축

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
MONITORING_DIR="./monitoring-stack"
PROMETHEUS_PORT="9090"
GRAFANA_PORT="3000"
NODE_EXPORTER_PORT="9100"
APP_PORT="3001"

# 사전 요구사항 확인
check_prerequisites() {
    log_header "사전 요구사항 확인"
    
    local missing_tools=()
    
    # Docker 확인
    if ! command -v docker &> /dev/null; then
        missing_tools+=("docker")
    fi
    
    # Docker Compose 확인
    if ! command -v docker-compose &> /dev/null; then
        missing_tools+=("docker-compose")
    fi
    
    if [ ${#missing_tools[@]} -gt 0 ]; then
        log_error "다음 도구들이 설치되지 않았습니다: ${missing_tools[*]}"
        log_info "설치 방법:"
        for tool in "${missing_tools[@]}"; do
            case $tool in
                "docker")
                    log_info "  Docker: https://docs.docker.com/get-docker/"
                    ;;
                "docker-compose")
                    log_info "  Docker Compose: https://docs.docker.com/compose/install/"
                    ;;
            esac
        done
        exit 1
    fi
    
    log_success "모든 필수 도구가 설치되어 있습니다."
}

# 모니터링 디렉토리 생성
create_monitoring_directory() {
    log_header "모니터링 디렉토리 생성"
    
    mkdir -p "$MONITORING_DIR"/{prometheus,grafana/provisioning/datasources,grafana/dashboards}
    
    log_success "모니터링 디렉토리 생성 완료"
}

# Prometheus 설정
setup_prometheus() {
    log_header "Prometheus 설정"
    
    cat > "$MONITORING_DIR/prometheus/prometheus.yml" << 'EOF'
global:
  scrape_interval: 15s
  evaluation_interval: 15s
  external_labels:
    monitor: 'cloud-intermediate-monitor'

rule_files:
  # - "first_rules.yml"
  # - "second_rules.yml"

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']
    scrape_interval: 5s
    metrics_path: /metrics

  - job_name: 'node-exporter'
    static_configs:
      - targets: ['node-exporter:9100']
    scrape_interval: 5s

  - job_name: 'application'
    static_configs:
      - targets: ['application:3000']
    metrics_path: /metrics
    scrape_interval: 5s
    scrape_timeout: 5s

  - job_name: 'grafana'
    static_configs:
      - targets: ['grafana:3000']
    scrape_interval: 5s
EOF

    log_success "Prometheus 설정 완료"
}

# Grafana 설정
setup_grafana() {
    log_header "Grafana 설정"
    
    # 데이터 소스 설정
    cat > "$MONITORING_DIR/grafana/provisioning/datasources/datasources.yml" << 'EOF'
apiVersion: 1

datasources:
  - name: Prometheus
    type: prometheus
    access: proxy
    url: http://prometheus:9090
    isDefault: true
    editable: true
    jsonData:
      httpMethod: POST
      manageAlerts: true
      prometheusType: Prometheus
      prometheusVersion: 2.40.0
      cacheLevel: 'High'
      disableRecordingRules: false
      incrementalQueryOverlapWindow: 10m
EOF

    # 대시보드 프로비저닝 설정
    cat > "$MONITORING_DIR/grafana/provisioning/dashboards/dashboards.yml" << 'EOF'
apiVersion: 1

providers:
  - name: 'default'
    orgId: 1
    folder: ''
    type: file
    disableDeletion: false
    updateIntervalSeconds: 10
    allowUiUpdates: true
    options:
      path: /var/lib/grafana/dashboards
EOF

    log_success "Grafana 설정 완료"
}

# Docker Compose 파일 생성
create_docker_compose() {
    log_header "Docker Compose 설정"
    
    cat > "$MONITORING_DIR/docker-compose.yml" << EOF
version: '3.8'

services:
  # Prometheus
  prometheus:
    image: prom/prometheus:latest
    container_name: prometheus
    ports:
      - "${PROMETHEUS_PORT}:9090"
    volumes:
      - ./prometheus/prometheus.yml:/etc/prometheus/prometheus.yml:ro
      - prometheus_data:/prometheus
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
      - '--web.console.libraries=/etc/prometheus/console_libraries'
      - '--web.console.templates=/etc/prometheus/consoles'
      - '--storage.tsdb.retention.time=200h'
      - '--web.enable-lifecycle'
      - '--web.enable-admin-api'
    networks:
      - monitoring
    restart: unless-stopped

  # Node Exporter
  node-exporter:
    image: prom/node-exporter:latest
    container_name: node-exporter
    ports:
      - "${NODE_EXPORTER_PORT}:9100"
    volumes:
      - /proc:/host/proc:ro
      - /sys:/host/sys:ro
      - /:/rootfs:ro
    command:
      - '--path.procfs=/host/proc'
      - '--path.rootfs=/rootfs'
      - '--path.sysfs=/host/sys'
      - '--collector.filesystem.mount-points-exclude=^/(sys|proc|dev|host|etc)($$|/)'
    networks:
      - monitoring
    restart: unless-stopped

  # Grafana
  grafana:
    image: grafana/grafana:latest
    container_name: grafana
    ports:
      - "${GRAFANA_PORT}:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin
      - GF_USERS_ALLOW_SIGN_UP=false
      - GF_INSTALL_PLUGINS=grafana-clock-panel,grafana-simple-json-datasource
    volumes:
      - grafana_data:/var/lib/grafana
      - ./grafana/provisioning:/etc/grafana/provisioning:ro
      - ./grafana/dashboards:/var/lib/grafana/dashboards:ro
    networks:
      - monitoring
    restart: unless-stopped
    depends_on:
      - prometheus

  # 샘플 애플리케이션
  application:
    build: ../samples/day1/docker-advanced
    container_name: sample-app
    ports:
      - "${APP_PORT}:3000"
    environment:
      - NODE_ENV=production
    networks:
      - monitoring
    restart: unless-stopped
    depends_on:
      - prometheus

volumes:
  prometheus_data:
  grafana_data:

networks:
  monitoring:
    driver: bridge
EOF

    log_success "Docker Compose 설정 완료"
}

# 모니터링 스택 시작
start_monitoring_stack() {
    log_header "모니터링 스택 시작"
    
    cd "$MONITORING_DIR"
    
    # Docker Compose로 서비스 시작
    log_info "Docker Compose로 서비스 시작 중..."
    docker-compose up -d
    
    # 서비스 상태 확인
    log_info "서비스 상태 확인 중..."
    sleep 10
    
    # 각 서비스 상태 확인
    local services=("prometheus" "grafana" "node-exporter" "sample-app")
    for service in "${services[@]}"; do
        if docker-compose ps | grep -q "$service.*Up"; then
            log_success "$service 서비스가 정상적으로 실행 중입니다."
        else
            log_error "$service 서비스 실행에 실패했습니다."
        fi
    done
    
    cd ..
}

# 서비스 상태 확인
check_services() {
    log_header "서비스 상태 확인"
    
    cd "$MONITORING_DIR"
    
    # Prometheus 상태 확인
    log_info "Prometheus 상태 확인..."
    if curl -f -s http://localhost:$PROMETHEUS_PORT/api/v1/status/config > /dev/null; then
        log_success "Prometheus가 정상적으로 실행 중입니다."
        log_info "Prometheus URL: http://localhost:$PROMETHEUS_PORT"
    else
        log_error "Prometheus 연결에 실패했습니다."
    fi
    
    # Grafana 상태 확인
    log_info "Grafana 상태 확인..."
    if curl -f -s http://localhost:$GRAFANA_PORT/api/health > /dev/null; then
        log_success "Grafana가 정상적으로 실행 중입니다."
        log_info "Grafana URL: http://localhost:$GRAFANA_PORT [admin/admin]"
    else
        log_error "Grafana 연결에 실패했습니다."
    fi
    
    # Node Exporter 상태 확인
    log_info "Node Exporter 상태 확인..."
    if curl -f -s http://localhost:$NODE_EXPORTER_PORT/metrics > /dev/null; then
        log_success "Node Exporter가 정상적으로 실행 중입니다."
    else
        log_error "Node Exporter 연결에 실패했습니다."
    fi
    
    # 샘플 애플리케이션 상태 확인
    log_info "샘플 애플리케이션 상태 확인..."
    if curl -f -s http://localhost:$APP_PORT/health > /dev/null; then
        log_success "샘플 애플리케이션이 정상적으로 실행 중입니다."
        log_info "애플리케이션 URL: http://localhost:$APP_PORT"
    else
        log_error "샘플 애플리케이션 연결에 실패했습니다."
    fi
    
    cd ..
}

# Prometheus 타겟 상태 확인
check_prometheus_targets() {
    log_header "Prometheus 타겟 상태 확인"
    
    log_info "Prometheus 타겟 상태 조회 중..."
    local targets_response=$(curl -s http://localhost:$PROMETHEUS_PORT/api/v1/targets)
    
    if [ $? -eq 0 ]; then
        log_success "Prometheus 타겟 상태 조회 성공"
        echo "$targets_response" | jq -r '.data.activeTargets[] | "\(.labels.job): \(.health)"' 2>/dev/null || echo "$targets_response"
    else
        log_error "Prometheus 타겟 상태 조회 실패"
    fi
}

# 메트릭 쿼리 테스트
test_metrics() {
    log_header "메트릭 쿼리 테스트"
    
    local queries=(
        "up"
        "nodejs_heap_size_total_bytes"
        "node_cpu_seconds_total"
        "http_requests_total"
    )
    
    for query in "${queries[@]}"; do
        log_info "쿼리 테스트: $query"
        local response=$(curl -s "http://localhost:$PROMETHEUS_PORT/api/v1/query?query=$query")
        
        if echo "$response" | jq -e '.data.result | length > 0' > /dev/null 2>&1; then
            log_success "쿼리 '$query' 성공"
        else
            log_warning "쿼리 '$query' 결과 없음"
        fi
    done
}

# 정리 함수
cleanup() {
    log_header "모니터링 스택 정리"
    
    if [ -d "$MONITORING_DIR" ]; then
        cd "$MONITORING_DIR"
        
        log_info "Docker Compose 서비스 중지 중..."
        docker-compose down -v
        
        log_info "Docker 이미지 정리 중..."
        docker-compose down --rmi all --volumes --remove-orphans
        
        cd ..
        
        log_info "모니터링 디렉토리 삭제 중..."
        rm -rf "$MONITORING_DIR"
        
        log_success "모니터링 스택 정리 완료"
    else
        log_warning "모니터링 디렉토리가 존재하지 않습니다."
    fi
}

# 도움말 표시
show_help() {
    echo "Cloud Intermediate 모니터링 스택 자동화 스크립트"
    echo ""
    echo "사용법: $0 [명령어]"
    echo ""
    echo "명령어:"
    echo "  setup     - 모니터링 스택 설정 및 시작"
    echo "  start     - 모니터링 스택 시작"
    echo "  stop      - 모니터링 스택 중지"
    echo "  status    - 서비스 상태 확인"
    echo "  targets   - Prometheus 타겟 상태 확인"
    echo "  test      - 메트릭 쿼리 테스트"
    echo "  cleanup   - 모니터링 스택 정리"
    echo "  help      - 이 도움말 표시"
    echo ""
    echo "예시:"
    echo "  $0 setup    # 모니터링 스택 설정 및 시작"
    echo "  $0 status   # 서비스 상태 확인"
    echo "  $0 cleanup  # 정리"
}

# 메인 함수
main() {
    case "${1:-help}" in
        "setup")
            check_prerequisites
            create_monitoring_directory
            setup_prometheus
            setup_grafana
            create_docker_compose
            start_monitoring_stack
            check_services
            log_success "모니터링 스택 설정 완료!"
            log_info "접속 정보:"
            log_info "  Prometheus: http://localhost:$PROMETHEUS_PORT"
            log_info "  Grafana: http://localhost:$GRAFANA_PORT [admin/admin]"
            log_info "  Node Exporter: http://localhost:$NODE_EXPORTER_PORT"
            log_info "  Sample App: http://localhost:$APP_PORT"
            ;;
        "start")
            if [ -d "$MONITORING_DIR" ]; then
                cd "$MONITORING_DIR"
                docker-compose up -d
                cd ..
                check_services
            else
                log_error "모니터링 스택이 설정되지 않았습니다. 'setup' 명령어를 먼저 실행하세요."
            fi
            ;;
        "stop")
            if [ -d "$MONITORING_DIR" ]; then
                cd "$MONITORING_DIR"
                docker-compose down
                cd ..
                log_success "모니터링 스택이 중지되었습니다."
            else
                log_warning "모니터링 스택이 실행되지 않았습니다."
            fi
            ;;
        "status")
            check_services
            ;;
        "targets")
            check_prometheus_targets
            ;;
        "test")
            test_metrics
            ;;
        "cleanup")
            cleanup
            ;;
        "help"|*)
            show_help
            ;;
    esac
}

# 스크립트 실행
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
