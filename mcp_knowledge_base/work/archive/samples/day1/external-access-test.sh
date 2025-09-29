#!/bin/bash

# 외부 접속 테스트 및 검증 스크립트
# AWS EC2 환경에서 실습한 서비스들의 외부 접속 가능 여부를 자동으로 테스트

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

# 외부 IP 주소 가져오기
get_external_ip() {
    # AWS EC2 메타데이터에서 퍼블릭 IP 가져오기
    if curl -s --max-time 2 http://169.254.169.254/latest/meta-data/public-ipv4 2>/dev/null; then
        return 0
    fi
    
    # 외부 서비스에서 IP 가져오기 (fallback)
    curl -s --max-time 5 https://ipinfo.io/ip 2>/dev/null || \
    curl -s --max-time 5 https://ifconfig.me 2>/dev/null || \
    curl -s --max-time 5 https://api.ipify.org 2>/dev/null || \
    echo "localhost"
}

# AWS 보안 그룹 자동 설정
setup_security_group() {
    log_header "AWS 보안 그룹 자동 설정"
    
    # 현재 인스턴스 ID 가져오기
    INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id 2>/dev/null)
    if [ -z "$INSTANCE_ID" ]; then
        log_error "인스턴스 ID를 가져올 수 없습니다"
        return 1
    fi
    
    log_info "인스턴스 ID: $INSTANCE_ID"
    
    # 보안 그룹 ID 가져오기
    SECURITY_GROUP_ID=$(aws ec2 describe-instances \
        --instance-ids "$INSTANCE_ID" \
        --query 'Reservations[0].Instances[0].SecurityGroups[0].GroupId' \
        --output text 2>/dev/null)
    
    if [ -z "$SECURITY_GROUP_ID" ] || [ "$SECURITY_GROUP_ID" = "None" ]; then
        log_error "보안 그룹 ID를 가져올 수 없습니다"
        return 1
    fi
    
    log_info "보안 그룹 ID: $SECURITY_GROUP_ID"
    
    # 필요한 포트들 설정
    PORTS=(3000 8080 9090 9093 9100)
    
    for port in "${PORTS[@]}"; do
        log_info "포트 $port 인바운드 규칙 확인/추가"
        
        # 기존 규칙 확인
        existing_rule=$(aws ec2 describe-security-groups \
            --group-ids "$SECURITY_GROUP_ID" \
            --query "SecurityGroups[0].IpPermissions[?FromPort==\`$port\` && ToPort==\`$port\` && IpProtocol==\`tcp\`]" \
            --output text 2>/dev/null)
        
        if [ -z "$existing_rule" ]; then
            log_info "포트 $port 규칙 추가 중..."
            if aws ec2 authorize-security-group-ingress \
                --group-id "$SECURITY_GROUP_ID" \
                --protocol tcp \
                --port "$port" \
                --cidr 0.0.0.0/0 2>/dev/null; then
                log_success "포트 $port 규칙 추가 성공"
            else
                log_warning "포트 $port 규칙 추가 실패"
            fi
        else
            log_success "포트 $port 규칙이 이미 존재합니다"
        fi
    done
    
    log_success "AWS 보안 그룹 설정 완료"
}

# 외부 접속 테스트
test_external_access() {
    log_header "외부 접속 테스트"
    
    EXTERNAL_IP=$(get_external_ip)
    
    if [ "$EXTERNAL_IP" = "localhost" ]; then
        log_warning "외부 IP를 가져올 수 없습니다. 외부 접속 테스트를 건너뜁니다."
        return 0
    fi
    
    log_info "외부 IP: $EXTERNAL_IP"
    
    # 테스트할 URL들
    declare -A test_urls=(
        ["AWS ECS 앱"]="http://$EXTERNAL_IP:3000/health"
        ["GCP Cloud Run 앱"]="http://$EXTERNAL_IP:8080/health"
        ["Prometheus"]="http://$EXTERNAL_IP:9090/api/v1/status/config"
        ["Grafana"]="http://$EXTERNAL_IP:3000/api/health"
        ["AlertManager"]="http://$EXTERNAL_IP:9093/api/v1/status"
        ["Node Exporter"]="http://$EXTERNAL_IP:9100/metrics"
    )
    
    # 각 URL 테스트
    for service in "${!test_urls[@]}"; do
        url="${test_urls[$service]}"
        log_info "$service 외부 접속 테스트: $url"
        
        # 최대 3번 재시도
        for i in {1..3}; do
            if curl -f -s --max-time 10 "$url" >/dev/null 2>&1; then
                log_success "$service 외부 접속 성공 (${i}번째 시도)"
                break
            else
                log_warning "$service 외부 접속 실패 (${i}/3 시도)"
                if [ $i -eq 3 ]; then
                    log_error "$service 외부 접속 최종 실패"
                else
                    sleep 2
                fi
            fi
        done
    done
}

# 외부 접속 정보 출력
show_external_access() {
    log_header "외부 접속 정보"
    
    EXTERNAL_IP=$(get_external_ip)
    
    if [ "$EXTERNAL_IP" != "localhost" ]; then
        log_success "외부에서 접속 가능한 URL:"
        echo ""
        echo "🌐 AWS ECS 테스트 앱:"
        echo "   http://$EXTERNAL_IP:3000"
        echo "   - 헬스체크: http://$EXTERNAL_IP:3000/health"
        echo "   - API 상태: http://$EXTERNAL_IP:3000/api/status"
        echo "   - 메트릭: http://$EXTERNAL_IP:3000/metrics"
        echo ""
        echo "🌐 GCP Cloud Run 테스트 앱:"
        echo "   http://$EXTERNAL_IP:8080"
        echo "   - 헬스체크: http://$EXTERNAL_IP:8080/health"
        echo "   - API 상태: http://$EXTERNAL_IP:8080/api/status"
        echo "   - 메트릭: http://$EXTERNAL_IP:8080/metrics"
        echo ""
        echo "📊 통합 모니터링 허브:"
        echo "   - Prometheus: http://$EXTERNAL_IP:9090"
        echo "   - Grafana: http://$EXTERNAL_IP:3000 (admin/admin)"
        echo "   - AlertManager: http://$EXTERNAL_IP:9093"
        echo "   - Node Exporter: http://$EXTERNAL_IP:9100/metrics"
        echo ""
        log_info "방화벽이 설정되어 외부에서 접속 가능합니다!"
        
        # 외부 접속 테스트 실행
        test_external_access
    else
        log_warning "외부 IP를 가져올 수 없습니다. localhost에서만 접속 가능합니다."
        echo ""
        echo "🏠 로컬 접속 URL:"
        echo "   - AWS ECS: http://localhost:3000"
        echo "   - GCP Cloud Run: http://localhost:8080"
        echo "   - Prometheus: http://localhost:9090"
        echo "   - Grafana: http://localhost:3000"
        echo "   - AlertManager: http://localhost:9093"
        echo "   - Node Exporter: http://localhost:9100/metrics"
    fi
}

# 메인 실행
main() {
    log_header "외부 접속 테스트 및 검증 시작"
    
    # AWS 보안 그룹 설정
    setup_security_group
    
    # 외부 접속 정보 출력 및 테스트
    show_external_access
    
    log_success "외부 접속 테스트 및 검증 완료!"
}

# 스크립트 실행
main "$@"
