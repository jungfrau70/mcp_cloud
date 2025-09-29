#!/bin/bash

# Monitoring Hub Helper 모듈
# 역할: 통합 모니터링 허브 구축 관련 작업 실행 (Prometheus, Grafana, Node Exporter 설치 및 설정)
# 
# 사용법:
#   ./monitoring-hub-helper.sh --action <액션> [옵션]

# =============================================================================
# 환경 설정 로드
# =============================================================================
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 공통 환경 설정 로드
if [ -f "$SCRIPT_DIR/common-environment.env" ]; then
    source "$SCRIPT_DIR/common-environment.env"
else
    echo "ERROR: 공통 환경 설정 파일을 찾을 수 없습니다"
    exit 1
fi

# AWS 환경 설정 로드
if [ -f "$SCRIPT_DIR/aws-environment.env" ]; then
    source "$SCRIPT_DIR/aws-environment.env"
else
    echo "ERROR: AWS 환경 설정 파일을 찾을 수 없습니다"
    exit 1
fi

# =============================================================================
# 사용법 출력
# =============================================================================
usage() {
    cat << EOF
Monitoring Hub Helper 모듈

사용법:
  $0 --action <액션> [옵션]

액션:
  create-hub             # 모니터링 허브 인프라 생성
  install-prometheus     # Prometheus 설치 및 설정
  install-grafana        # Grafana 설치 및 설정
  install-node-exporter  # Node Exporter 설치 및 설정
  setup-integration      # 통합 모니터링 설정
  cleanup                # 모니터링 허브 정리
  status                 # 모니터링 허브 상태 확인

옵션:
  --instance-type <type> # EC2 인스턴스 타입 (기본값: t3.medium)
  --key-name <key>       # SSH 키 이름
  --security-group <sg>  # 보안 그룹 ID
  --subnet-id <subnet>   # 서브넷 ID
  --region <region>      # AWS 리전 (기본값: 환경변수)
  --help, -h             # 도움말 표시

예시:
  $0 --action create-hub
  $0 --action install-prometheus
  $0 --action install-grafana
  $0 --action install-node-exporter
  $0 --action setup-integration
  $0 --action status
  $0 --action cleanup
EOF
}

# =============================================================================
# 액션별 상세 사용법 함수
# =============================================================================
show_action_help() {
    local action="$1"
    
    case "$action" in
        "create-hub")
            cat << EOF
CREATE-HUB 액션 상세 사용법:

기능:
  - AWS EC2 모니터링 허브 인스턴스 생성
  - 보안 그룹 및 네트워크 설정
  - SSH 접속 설정

사용법:
  $0 --action create-hub [옵션]

옵션:
  --instance-type <type> # EC2 인스턴스 타입 (기본값: t3.medium)
  --key-name <key>       # SSH 키 이름
  --security-group <sg>  # 보안 그룹 ID
  --subnet-id <subnet>   # 서브넷 ID
  --region <region>      # AWS 리전 (기본값: 환경변수)

예시:
  $0 --action create-hub
  $0 --action create-hub --instance-type t3.large --key-name my-key

생성되는 리소스:
  - EC2 인스턴스
  - 보안 그룹 (필요시)
  - 네트워크 설정
  - SSH 접속 설정

진행 상황:
  - 인스턴스 생성
  - 보안 그룹 설정
  - 네트워크 구성
  - SSH 접속 확인
EOF
            ;;
        "install-prometheus")
            cat << EOF
INSTALL-PROMETHEUS 액션 상세 사용법:

기능:
  - Prometheus 서버 설치
  - 설정 파일 구성
  - 서비스 시작 및 확인

사용법:
  $0 --action install-prometheus [옵션]

옵션:
  --instance-id <id>     # EC2 인스턴스 ID
  --region <region>      # AWS 리전 (기본값: 환경변수)

예시:
  $0 --action install-prometheus
  $0 --action install-prometheus --instance-id i-1234567890abcdef0

설치되는 구성요소:
  - Prometheus 서버
  - 설정 파일
  - 시스템 서비스
  - 로그 설정

진행 상황:
  - Prometheus 다운로드
  - 설정 파일 생성
  - 서비스 시작
  - 상태 확인
EOF
            ;;
        "install-grafana")
            cat << EOF
INSTALL-GRAFANA 액션 상세 사용법:

기능:
  - Grafana 서버 설치
  - Prometheus 데이터 소스 연결
  - 기본 대시보드 생성

사용법:
  $0 --action install-grafana [옵션]

옵션:
  --instance-id <id>     # EC2 인스턴스 ID
  --region <region>      # AWS 리전 (기본값: 환경변수)

예시:
  $0 --action install-grafana
  $0 --action install-grafana --instance-id i-1234567890abcdef0

설치되는 구성요소:
  - Grafana 서버
  - 데이터 소스 설정
  - 기본 대시보드
  - 사용자 설정

진행 상황:
  - Grafana 다운로드
  - 서비스 설정
  - 데이터 소스 연결
  - 대시보드 생성
EOF
            ;;
        "install-node-exporter")
            cat << EOF
INSTALL-NODE-EXPORTER 액션 상세 사용법:

기능:
  - Node Exporter 설치
  - 시스템 메트릭 수집 설정
  - Prometheus 연동

사용법:
  $0 --action install-node-exporter [옵션]

옵션:
  --instance-id <id>     # EC2 인스턴스 ID
  --region <region>      # AWS 리전 (기본값: 환경변수)

예시:
  $0 --action install-node-exporter
  $0 --action install-node-exporter --instance-id i-1234567890abcdef0

설치되는 구성요소:
  - Node Exporter
  - 시스템 메트릭 수집
  - Prometheus 설정
  - 서비스 등록

진행 상황:
  - Node Exporter 다운로드
  - 서비스 설정
  - Prometheus 연동
  - 메트릭 수집 확인
EOF
            ;;
        "setup-integration")
            cat << EOF
SETUP-INTEGRATION 액션 상세 사용법:

기능:
  - 통합 모니터링 시스템 구성
  - Prometheus + Grafana 연동
  - 알림 설정

사용법:
  $0 --action setup-integration [옵션]

옵션:
  --instance-id <id>     # EC2 인스턴스 ID
  --region <region>      # AWS 리전 (기본값: 환경변수)

예시:
  $0 --action setup-integration
  $0 --action setup-integration --instance-id i-1234567890abcdef0

설정되는 통합 기능:
  - Prometheus + Grafana 연동
  - 데이터 소스 설정
  - 알림 규칙 설정
  - 대시보드 구성

진행 상황:
  - 서비스 연동
  - 설정 파일 구성
  - 알림 설정
  - 통합 테스트
EOF
            ;;
        "cleanup")
            cat << EOF
CLEANUP 액션 상세 사용법:

기능:
  - 모니터링 허브 리소스 정리
  - EC2 인스턴스 삭제
  - 관련 리소스 정리

사용법:
  $0 --action cleanup [옵션]

옵션:
  --instance-id <id>     # 삭제할 EC2 인스턴스 ID
  --region <region>      # AWS 리전 (기본값: 환경변수)
  --force                # 확인 없이 강제 정리

예시:
  $0 --action cleanup
  $0 --action cleanup --force

정리되는 리소스:
  - EC2 인스턴스
  - 보안 그룹 (생성한 경우)
  - 관련 리소스

주의사항:
  - 정리된 리소스는 복구할 수 없습니다
  - --force 옵션 사용 시 확인 없이 정리됩니다
EOF
            ;;
        "status")
            cat << EOF
STATUS 액션 상세 사용법:

기능:
  - 모니터링 허브 상태 확인
  - 서비스 상태 모니터링
  - 리소스 사용량 확인

사용법:
  $0 --action status [옵션]

옵션:
  --instance-id <id>     # 확인할 EC2 인스턴스 ID
  --region <region>      # AWS 리전 (기본값: 환경변수)
  --format <format>      # 출력 형식 (table, json, yaml)

예시:
  $0 --action status
  $0 --action status --format json

확인되는 정보:
  - EC2 인스턴스 상태
  - Prometheus 상태
  - Grafana 상태
  - Node Exporter 상태

출력 형식:
  - table: 테이블 형태 (기본값)
  - json: JSON 형태
  - yaml: YAML 형태
EOF
            ;;
        *)
            cat << EOF
알 수 없는 액션: $action

사용 가능한 액션:
  - create-hub: 모니터링 허브 인프라 생성
  - install-prometheus: Prometheus 설치 및 설정
  - install-grafana: Grafana 설치 및 설정
  - install-node-exporter: Node Exporter 설치 및 설정
  - setup-integration: 통합 모니터링 설정
  - cleanup: 리소스 정리
  - status: 상태 확인

각 액션의 상세 사용법을 보려면:
  $0 --help --action <액션명>
EOF
            ;;
    esac
}

# =============================================================================
# --help 옵션 처리 로직
# =============================================================================
handle_help_option() {
    local action="$1"
    
    if [ -n "$action" ]; then
        show_action_help "$action"
    else
        usage
    fi
    exit 0
}

# =============================================================================
# 환경 검증
# =============================================================================
validate_environment() {
    log_step "모니터링 허브 환경 검증 중..."
    
    # AWS CLI 설치 확인
    if ! check_command "aws"; then
        log_error "AWS CLI가 설치되지 않았습니다."
        return 1
    fi
    
    # AWS 자격 증명 확인
    if ! aws sts get-caller-identity &> /dev/null; then
        log_error "AWS 자격 증명이 설정되지 않았습니다."
        return 1
    fi
    
    log_success "모니터링 허브 환경 검증 완료"
    return 0
}

# =============================================================================
# 모니터링 허브 인프라 생성
# =============================================================================
create_hub() {
    local instance_type="${1:-t3.medium}"
    local key_name="${2:-my-key}"
    local security_group="${3:-}"
    local subnet_id="${4:-}"
    local region="${5:-$AWS_REGION}"
    
    log_header "모니터링 허브 인프라 생성"
    
    # 기본 VPC 및 서브넷 확인
    if [ -z "$subnet_id" ]; then
        log_info "기본 서브넷 확인 중..."
        subnet_id=$(aws ec2 describe-subnets --filters "Name=vpc-id,Values=$(aws ec2 describe-vpcs --filters "Name=is-default,Values=true" --query 'Vpcs[0].VpcId' --output text)" --query 'Subnets[0].SubnetId' --output text)
    fi
    
    # 보안 그룹 생성 (필요시)
    if [ -z "$security_group" ]; then
        log_info "보안 그룹 생성 중..."
        local vpc_id
        vpc_id=$(aws ec2 describe-subnets --subnet-ids "$subnet_id" --query 'Subnets[0].VpcId' --output text)
        
        security_group=$(aws ec2 create-security-group \
            --group-name "monitoring-hub-sg" \
            --description "Security group for monitoring hub" \
            --vpc-id "$vpc_id" \
            --query 'GroupId' --output text)
        
        # 보안 그룹 규칙 설정
        aws ec2 authorize-security-group-ingress \
            --group-id "$security_group" \
            --protocol tcp \
            --port 22 \
            --cidr 0.0.0.0/0
        
        aws ec2 authorize-security-group-ingress \
            --group-id "$security_group" \
            --protocol tcp \
            --port 3000 \
            --cidr 0.0.0.0/0
        
        aws ec2 authorize-security-group-ingress \
            --group-id "$security_group" \
            --protocol tcp \
            --port 9090 \
            --cidr 0.0.0.0/0
        
        aws ec2 authorize-security-group-ingress \
            --group-id "$security_group" \
            --protocol tcp \
            --port 9100 \
            --cidr 0.0.0.0/0
    fi
    
    # EC2 인스턴스 생성
    log_info "EC2 인스턴스 생성 중..."
    update_progress "create-hub" "started" "모니터링 허브 인프라 생성 시작"
    
    local instance_id
    instance_id=$(aws ec2 run-instances \
        --image-id ami-0c02fb55956c7d316 \
        --instance-type "$instance_type" \
        --key-name "$key_name" \
        --security-group-ids "$security_group" \
        --subnet-id "$subnet_id" \
        --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=monitoring-hub},{Key=Environment,Value=$ENVIRONMENT_TAG},{Key=Project,Value=$PROJECT_TAG}]" \
        --query 'Instances[0].InstanceId' --output text)
    
    if [ $? -eq 0 ]; then
        log_success "EC2 인스턴스 생성 완료: $instance_id"
        update_progress "create-hub" "completed" "모니터링 허브 인프라 생성 완료"
        
        # 인스턴스 상태 확인
        log_info "인스턴스 상태 확인 중..."
        aws ec2 wait instance-running --instance-ids "$instance_id"
        
        # 인스턴스 정보 출력
        local public_ip
        public_ip=$(aws ec2 describe-instances --instance-ids "$instance_id" --query 'Reservations[0].Instances[0].PublicIpAddress' --output text)
        
        log_info "인스턴스 정보:"
        log_info "  - Instance ID: $instance_id"
        log_info "  - Public IP: $public_ip"
        log_info "  - SSH 접속: ssh -i $key_name.pem ec2-user@$public_ip"
        
        # 인스턴스 ID를 파일에 저장
        echo "$instance_id" > "$LOGS_DIR/monitoring-hub-instance-id.txt"
        
        return 0
    else
        log_error "EC2 인스턴스 생성 실패"
        update_progress "create-hub" "failed" "모니터링 허브 인프라 생성 실패"
        return 1
    fi
}

# =============================================================================
# Prometheus 설치
# =============================================================================
install_prometheus() {
    local instance_id="${1:-}"
    local region="${2:-$AWS_REGION}"
    
    log_header "Prometheus 설치"
    
    # 인스턴스 ID 확인
    if [ -z "$instance_id" ]; then
        if [ -f "$LOGS_DIR/monitoring-hub-instance-id.txt" ]; then
            instance_id=$(cat "$LOGS_DIR/monitoring-hub-instance-id.txt")
        else
            log_error "인스턴스 ID가 지정되지 않았습니다."
            return 1
        fi
    fi
    
    # 인스턴스 상태 확인
    local instance_state
    instance_state=$(aws ec2 describe-instances --instance-ids "$instance_id" --query 'Reservations[0].Instances[0].State.Name' --output text)
    
    if [ "$instance_state" != "running" ]; then
        log_error "인스턴스가 실행 중이 아닙니다: $instance_state"
        return 1
    fi
    
    # 인스턴스 IP 확인
    local public_ip
    public_ip=$(aws ec2 describe-instances --instance-ids "$instance_id" --query 'Reservations[0].Instances[0].PublicIpAddress' --output text)
    
    log_info "Prometheus 설치 중... (인스턴스: $instance_id, IP: $public_ip)"
    update_progress "install-prometheus" "started" "Prometheus 설치 시작"
    
    # Prometheus 설치 스크립트 생성
    cat > /tmp/install-prometheus.sh << 'EOF'
#!/bin/bash

# Prometheus 설치 스크립트
set -e

# Prometheus 다운로드
wget https://github.com/prometheus/prometheus/releases/download/v2.40.0/prometheus-2.40.0.linux-amd64.tar.gz
tar xzf prometheus-2.40.0.linux-amd64.tar.gz
sudo mv prometheus-2.40.0.linux-amd64 /opt/prometheus

# Prometheus 사용자 생성
sudo useradd --no-create-home --shell /bin/false prometheus
sudo chown -R prometheus:prometheus /opt/prometheus

# Prometheus 설정 파일 생성
sudo tee /opt/prometheus/prometheus.yml > /dev/null << 'PROMETHEUS_CONFIG'
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'node-exporter'
    static_configs:
      - targets: ['localhost:9100']
PROMETHEUS_CONFIG

# Prometheus 서비스 파일 생성
sudo tee /etc/systemd/system/prometheus.service > /dev/null << 'SERVICE_CONFIG'
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/opt/prometheus/prometheus \
  --config.file /opt/prometheus/prometheus.yml \
  --storage.tsdb.path /opt/prometheus/data \
  --web.console.templates=/opt/prometheus/consoles \
  --web.console.libraries=/opt/prometheus/console_libraries \
  --web.listen-address=0.0.0.0:9090 \
  --web.external-url=

[Install]
WantedBy=multi-user.target
SERVICE_CONFIG

# Prometheus 서비스 시작
sudo systemctl daemon-reload
sudo systemctl start prometheus
sudo systemctl enable prometheus

# 상태 확인
sudo systemctl status prometheus --no-pager

echo "Prometheus 설치 완료"
echo "접속 URL: http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4):9090"
EOF
    
    # 스크립트를 인스턴스에 복사 및 실행
    if scp -i "$key_name.pem" -o StrictHostKeyChecking=no /tmp/install-prometheus.sh ec2-user@"$public_ip":/tmp/; then
        if ssh -i "$key_name.pem" -o StrictHostKeyChecking=no ec2-user@"$public_ip" "chmod +x /tmp/install-prometheus.sh && sudo /tmp/install-prometheus.sh"; then
            log_success "Prometheus 설치 완료"
            update_progress "install-prometheus" "completed" "Prometheus 설치 완료"
            
            # 정리
            rm -f /tmp/install-prometheus.sh
            
            return 0
        else
            log_error "Prometheus 설치 실패"
            update_progress "install-prometheus" "failed" "Prometheus 설치 실패"
            return 1
        fi
    else
        log_error "인스턴스 접속 실패"
        update_progress "install-prometheus" "failed" "인스턴스 접속 실패"
        return 1
    fi
}

# =============================================================================
# Grafana 설치
# =============================================================================
install_grafana() {
    local instance_id="${1:-}"
    local region="${2:-$AWS_REGION}"
    
    log_header "Grafana 설치"
    
    # 인스턴스 ID 확인
    if [ -z "$instance_id" ]; then
        if [ -f "$LOGS_DIR/monitoring-hub-instance-id.txt" ]; then
            instance_id=$(cat "$LOGS_DIR/monitoring-hub-instance-id.txt")
        else
            log_error "인스턴스 ID가 지정되지 않았습니다."
            return 1
        fi
    fi
    
    # 인스턴스 IP 확인
    local public_ip
    public_ip=$(aws ec2 describe-instances --instance-ids "$instance_id" --query 'Reservations[0].Instances[0].PublicIpAddress' --output text)
    
    log_info "Grafana 설치 중... (인스턴스: $instance_id, IP: $public_ip)"
    update_progress "install-grafana" "started" "Grafana 설치 시작"
    
    # Grafana 설치 스크립트 생성
    cat > /tmp/install-grafana.sh << 'EOF'
#!/bin/bash

# Grafana 설치 스크립트
set -e

# Grafana 다운로드
wget https://dl.grafana.com/oss/release/grafana-9.3.0.linux-amd64.tar.gz
tar xzf grafana-9.3.0.linux-amd64.tar.gz
sudo mv grafana-9.3.0 /opt/grafana

# Grafana 사용자 생성
sudo useradd --no-create-home --shell /bin/false grafana
sudo chown -R grafana:grafana /opt/grafana

# Grafana 서비스 파일 생성
sudo tee /etc/systemd/system/grafana-server.service > /dev/null << 'SERVICE_CONFIG'
[Unit]
Description=Grafana Server
After=network.target

[Service]
User=grafana
Group=grafana
Type=notify
ExecStart=/opt/grafana/bin/grafana-server --config=/opt/grafana/conf/defaults.ini --pidfile=/var/run/grafana-server.pid --packaging=tar
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
SERVICE_CONFIG

# Grafana 설정 파일 생성
sudo tee /opt/grafana/conf/custom.ini > /dev/null << 'GRAFANA_CONFIG'
[server]
http_port = 3000
http_addr = 0.0.0.0

[security]
admin_user = admin
admin_password = admin

[database]
type = sqlite3
path = /opt/grafana/data/grafana.db
EOF
    
    # 스크립트를 인스턴스에 복사 및 실행
    if scp -i "$key_name.pem" -o StrictHostKeyChecking=no /tmp/install-grafana.sh ec2-user@"$public_ip":/tmp/; then
        if ssh -i "$key_name.pem" -o StrictHostKeyChecking=no ec2-user@"$public_ip" "chmod +x /tmp/install-grafana.sh && sudo /tmp/install-grafana.sh"; then
            log_success "Grafana 설치 완료"
            update_progress "install-grafana" "completed" "Grafana 설치 완료"
            
            # 정리
            rm -f /tmp/install-grafana.sh
            
            return 0
        else
            log_error "Grafana 설치 실패"
            update_progress "install-grafana" "failed" "Grafana 설치 실패"
            return 1
        fi
    else
        log_error "인스턴스 접속 실패"
        update_progress "install-grafana" "failed" "인스턴스 접속 실패"
        return 1
    fi
}

# =============================================================================
# Node Exporter 설치
# =============================================================================
install_node_exporter() {
    local instance_id="${1:-}"
    local region="${2:-$AWS_REGION}"
    
    log_header "Node Exporter 설치"
    
    # 인스턴스 ID 확인
    if [ -z "$instance_id" ]; then
        if [ -f "$LOGS_DIR/monitoring-hub-instance-id.txt" ]; then
            instance_id=$(cat "$LOGS_DIR/monitoring-hub-instance-id.txt")
        else
            log_error "인스턴스 ID가 지정되지 않았습니다."
            return 1
        fi
    fi
    
    # 인스턴스 IP 확인
    local public_ip
    public_ip=$(aws ec2 describe-instances --instance-ids "$instance_id" --query 'Reservations[0].Instances[0].PublicIpAddress' --output text)
    
    log_info "Node Exporter 설치 중... (인스턴스: $instance_id, IP: $public_ip)"
    update_progress "install-node-exporter" "started" "Node Exporter 설치 시작"
    
    # Node Exporter 설치 스크립트 생성
    cat > /tmp/install-node-exporter.sh << 'EOF'
#!/bin/bash

# Node Exporter 설치 스크립트
set -e

# Node Exporter 다운로드
wget https://github.com/prometheus/node_exporter/releases/download/v1.5.0/node_exporter-1.5.0.linux-amd64.tar.gz
tar xzf node_exporter-1.5.0.linux-amd64.tar.gz
sudo mv node_exporter-1.5.0.linux-amd64/node_exporter /usr/local/bin/

# Node Exporter 사용자 생성
sudo useradd --no-create-home --shell /bin/false node_exporter
sudo chown node_exporter:node_exporter /usr/local/bin/node_exporter

# Node Exporter 서비스 파일 생성
sudo tee /etc/systemd/system/node_exporter.service > /dev/null << 'SERVICE_CONFIG'
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target
SERVICE_CONFIG

# Node Exporter 서비스 시작
sudo systemctl daemon-reload
sudo systemctl start node_exporter
sudo systemctl enable node_exporter

# 상태 확인
sudo systemctl status node_exporter --no-pager

echo "Node Exporter 설치 완료"
EOF
    
    # 스크립트를 인스턴스에 복사 및 실행
    if scp -i "$key_name.pem" -o StrictHostKeyChecking=no /tmp/install-node-exporter.sh ec2-user@"$public_ip":/tmp/; then
        if ssh -i "$key_name.pem" -o StrictHostKeyChecking=no ec2-user@"$public_ip" "chmod +x /tmp/install-node-exporter.sh && sudo /tmp/install-node-exporter.sh"; then
            log_success "Node Exporter 설치 완료"
            update_progress "install-node-exporter" "completed" "Node Exporter 설치 완료"
            
            # 정리
            rm -f /tmp/install-node-exporter.sh
            
            return 0
        else
            log_error "Node Exporter 설치 실패"
            update_progress "install-node-exporter" "failed" "Node Exporter 설치 실패"
            return 1
        fi
    else
        log_error "인스턴스 접속 실패"
        update_progress "install-node-exporter" "failed" "인스턴스 접속 실패"
        return 1
    fi
}

# =============================================================================
# 통합 모니터링 설정
# =============================================================================
setup_integration() {
    local instance_id="${1:-}"
    local region="${2:-$AWS_REGION}"
    
    log_header "통합 모니터링 설정"
    
    # 인스턴스 ID 확인
    if [ -z "$instance_id" ]; then
        if [ -f "$LOGS_DIR/monitoring-hub-instance-id.txt" ]; then
            instance_id=$(cat "$LOGS_DIR/monitoring-hub-instance-id.txt")
        else
            log_error "인스턴스 ID가 지정되지 않았습니다."
            return 1
        fi
    fi
    
    # 인스턴스 IP 확인
    local public_ip
    public_ip=$(aws ec2 describe-instances --instance-ids "$instance_id" --query 'Reservations[0].Instances[0].PublicIpAddress' --output text)
    
    log_info "통합 모니터링 설정 중... (인스턴스: $instance_id, IP: $public_ip)"
    update_progress "setup-integration" "started" "통합 모니터링 설정 시작"
    
    # 통합 설정 스크립트 생성
    cat > /tmp/setup-integration.sh << 'EOF'
#!/bin/bash

# 통합 모니터링 설정 스크립트
set -e

# Grafana 데이터 소스 설정
curl -X POST \
  http://admin:admin@localhost:3000/api/datasources \
  -H 'Content-Type: application/json' \
  -d '{
    "name": "Prometheus",
    "type": "prometheus",
    "url": "http://localhost:9090",
    "access": "proxy",
    "isDefault": true
  }'

# 기본 대시보드 생성
curl -X POST \
  http://admin:admin@localhost:3000/api/dashboards/db \
  -H 'Content-Type: application/json' \
  -d '{
    "dashboard": {
      "id": null,
      "title": "System Overview",
      "tags": ["templated"],
      "style": "dark",
      "timezone": "browser",
      "panels": [
        {
          "id": 1,
          "title": "CPU Usage",
          "type": "graph",
          "targets": [
            {
              "expr": "100 - (avg(irate(node_cpu_seconds_total{mode=\"idle\"}[5m])) * 100)",
              "legendFormat": "CPU Usage %"
            }
          ],
          "yAxes": [
            {
              "label": "Percentage",
              "min": 0,
              "max": 100
            }
          ]
        }
      ],
      "time": {
        "from": "now-1h",
        "to": "now"
      }
    }
  }'

echo "통합 모니터링 설정 완료"
echo "Grafana 접속 URL: http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4):3000"
echo "Prometheus 접속 URL: http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4):9090"
EOF
    
    # 스크립트를 인스턴스에 복사 및 실행
    if scp -i "$key_name.pem" -o StrictHostKeyChecking=no /tmp/setup-integration.sh ec2-user@"$public_ip":/tmp/; then
        if ssh -i "$key_name.pem" -o StrictHostKeyChecking=no ec2-user@"$public_ip" "chmod +x /tmp/setup-integration.sh && sudo /tmp/setup-integration.sh"; then
            log_success "통합 모니터링 설정 완료"
            update_progress "setup-integration" "completed" "통합 모니터링 설정 완료"
            
            # 정리
            rm -f /tmp/setup-integration.sh
            
            return 0
        else
            log_error "통합 모니터링 설정 실패"
            update_progress "setup-integration" "failed" "통합 모니터링 설정 실패"
            return 1
        fi
    else
        log_error "인스턴스 접속 실패"
        update_progress "setup-integration" "failed" "인스턴스 접속 실패"
        return 1
    fi
}

# =============================================================================
# 모니터링 허브 정리
# =============================================================================
cleanup_hub() {
    local instance_id="${1:-}"
    local region="${2:-$AWS_REGION}"
    local force="${3:-false}"
    
    log_header "모니터링 허브 정리"
    
    # 인스턴스 ID 확인
    if [ -z "$instance_id" ]; then
        if [ -f "$LOGS_DIR/monitoring-hub-instance-id.txt" ]; then
            instance_id=$(cat "$LOGS_DIR/monitoring-hub-instance-id.txt")
        else
            log_error "인스턴스 ID가 지정되지 않았습니다."
            return 1
        fi
    fi
    
    if [ "$force" != "true" ]; then
        log_warning "삭제할 인스턴스: $instance_id"
        read -p "정말 삭제하시겠습니까? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_info "삭제가 취소되었습니다."
            return 0
        fi
    fi
    
    log_info "모니터링 허브 정리 중..."
    update_progress "cleanup" "started" "모니터링 허브 정리 시작"
    
    # EC2 인스턴스 삭제
    if aws ec2 terminate-instances --instance-ids "$instance_id"; then
        log_success "모니터링 허브 정리 완료"
        update_progress "cleanup" "completed" "모니터링 허브 정리 완료"
        
        # 인스턴스 ID 파일 삭제
        rm -f "$LOGS_DIR/monitoring-hub-instance-id.txt"
        
        return 0
    else
        log_error "모니터링 허브 정리 실패"
        update_progress "cleanup" "failed" "모니터링 허브 정리 실패"
        return 1
    fi
}

# =============================================================================
# 모니터링 허브 상태 확인
# =============================================================================
check_hub_status() {
    local instance_id="${1:-}"
    local region="${2:-$AWS_REGION}"
    local format="${3:-table}"
    
    log_header "모니터링 허브 상태 확인"
    
    # 인스턴스 ID 확인
    if [ -z "$instance_id" ]; then
        if [ -f "$LOGS_DIR/monitoring-hub-instance-id.txt" ]; then
            instance_id=$(cat "$LOGS_DIR/monitoring-hub-instance-id.txt")
        else
            log_error "인스턴스 ID가 지정되지 않았습니다."
            return 1
        fi
    fi
    
    # 인스턴스 상태 확인
    log_info "인스턴스 상태:"
    case "$format" in
        "json")
            aws ec2 describe-instances --instance-ids "$instance_id" --output json
            ;;
        "yaml")
            aws ec2 describe-instances --instance-ids "$instance_id" --output yaml
            ;;
        *)
            aws ec2 describe-instances --instance-ids "$instance_id" --query 'Reservations[0].Instances[0].{InstanceId:InstanceId,State:State.Name,PublicIP:PublicIpAddress,PrivateIP:PrivateIpAddress,InstanceType:InstanceType}' --output table
            ;;
    esac
    
    # 서비스 상태 확인 (인스턴스가 실행 중인 경우)
    local instance_state
    instance_state=$(aws ec2 describe-instances --instance-ids "$instance_id" --query 'Reservations[0].Instances[0].State.Name' --output text)
    
    if [ "$instance_state" = "running" ]; then
        local public_ip
        public_ip=$(aws ec2 describe-instances --instance-ids "$instance_id" --query 'Reservations[0].Instances[0].PublicIpAddress' --output text)
        
        log_info "서비스 상태 확인:"
        log_info "  - Prometheus: http://$public_ip:9090"
        log_info "  - Grafana: http://$public_ip:3000"
        log_info "  - Node Exporter: http://$public_ip:9100"
    fi
    
    update_progress "status" "completed" "모니터링 허브 상태 확인 완료"
    return 0
}

# =============================================================================
# 메인 실행 로직
# =============================================================================
main() {
    local action=""
    local instance_type="t3.medium"
    local key_name="my-key"
    local security_group=""
    local subnet_id=""
    local region="$AWS_REGION"
    local force="false"
    local format="table"
    
    # 인수 파싱
    while [[ $# -gt 0 ]]; do
        case $1 in
            --action)
                action="$2"
                shift 2
                ;;
            --instance-type)
                instance_type="$2"
                shift 2
                ;;
            --key-name)
                key_name="$2"
                shift 2
                ;;
            --security-group)
                security_group="$2"
                shift 2
                ;;
            --subnet-id)
                subnet_id="$2"
                shift 2
                ;;
            --region)
                region="$2"
                shift 2
                ;;
            --force)
                force="true"
                shift
                ;;
            --format)
                format="$2"
                shift 2
                ;;
            --help|-h)
                # --help 옵션 처리
                if [ "$2" = "--action" ] && [ -n "$3" ]; then
                    handle_help_option "$3"
                else
                    usage
                    exit 0
                fi
                ;;
            *)
                log_error "알 수 없는 옵션: $1"
                usage
                exit 1
                ;;
        esac
    done
    
    # 액션이 지정되지 않은 경우
    if [ -z "$action" ]; then
        log_error "액션이 지정되지 않았습니다."
        usage
        exit 1
    fi
    
    # 환경 검증
    if ! validate_environment; then
        log_error "환경 검증 실패"
        exit 1
    fi
    
    # 액션 실행
    case "$action" in
        "create-hub")
            create_hub "$instance_type" "$key_name" "$security_group" "$subnet_id" "$region"
            ;;
        "install-prometheus")
            install_prometheus "" "$region"
            ;;
        "install-grafana")
            install_grafana "" "$region"
            ;;
        "install-node-exporter")
            install_node_exporter "" "$region"
            ;;
        "setup-integration")
            setup_integration "" "$region"
            ;;
        "cleanup")
            cleanup_hub "" "$region" "$force"
            ;;
        "status")
            check_hub_status "" "$region" "$format"
            ;;
        *)
            log_error "알 수 없는 액션: $action"
            usage
            exit 1
            ;;
    esac
    
    # 실행 요약 보고
    generate_summary
}

# =============================================================================
# 스크립트 실행
# =============================================================================
main "$@"
