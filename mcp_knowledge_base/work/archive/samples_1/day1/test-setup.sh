#!/bin/bash

# Cloud Intermediate Day 1 실습 테스트 스크립트
# AWS ECS, GCP Cloud Run, 통합 모니터링 허브 테스트

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

# 방화벽 설정
setup_firewall() {
    log_header "방화벽 설정"
    
    # 현재 외부 IP 확인
    EXTERNAL_IP=$(get_external_ip)
    log_info "외부 IP: $EXTERNAL_IP"
    
    # AWS EC2 보안 그룹 확인 및 설정
    if command -v aws &> /dev/null; then
        log_info "AWS 보안 그룹 설정 확인"
        
        # 현재 인스턴스의 보안 그룹 ID 가져오기
        INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id 2>/dev/null)
        if [ -n "$INSTANCE_ID" ]; then
            log_info "인스턴스 ID: $INSTANCE_ID"
            
            # 보안 그룹 ID 가져오기
            SECURITY_GROUP_ID=$(aws ec2 describe-instances --instance-ids "$INSTANCE_ID" --query 'Reservations[0].Instances[0].SecurityGroups[0].GroupId' --output text 2>/dev/null)
            if [ -n "$SECURITY_GROUP_ID" ] && [ "$SECURITY_GROUP_ID" != "None" ]; then
                log_info "보안 그룹 ID: $SECURITY_GROUP_ID"
                
                # 필요한 포트들에 대한 인바운드 규칙 추가
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
            else
                log_warning "보안 그룹 ID를 가져올 수 없습니다"
            fi
        else
            log_warning "인스턴스 ID를 가져올 수 없습니다"
        fi
    else
        log_warning "AWS CLI가 설치되지 않았습니다"
    fi
    
    # 로컬 방화벽 설정 (iptables)
    if command -v iptables &> /dev/null; then
        log_info "로컬 iptables 설정"
        
        # 필요한 포트들 열기
        PORTS=(3000 8080 9090 9093 9100)
        for port in "${PORTS[@]}"; do
            iptables -I INPUT -p tcp --dport "$port" -j ACCEPT 2>/dev/null || log_warning "포트 $port iptables 규칙 추가 실패"
        done
        
        # iptables 규칙 저장
        if command -v iptables-save &> /dev/null; then
            iptables-save > /etc/iptables/rules.v4 2>/dev/null || log_warning "iptables 규칙 저장 실패"
        fi
        
        log_success "로컬 방화벽 설정 완료"
    else
        log_warning "iptables가 설치되지 않았습니다"
    fi
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

# 환경 체크
check_environment() {
    log_header "환경 체크"
    
    # Docker 체크
    if command -v docker &> /dev/null; then
        log_success "Docker 설치됨: $(docker --version)"
    else
        log_error "Docker가 설치되지 않았습니다."
        return 1
    fi
    
    # Docker Compose 체크
    if command -v docker-compose &> /dev/null; then
        log_success "Docker Compose 설치됨: $(docker-compose --version)"
    else
        log_error "Docker Compose가 설치되지 않았습니다."
        return 1
    fi
    
    # AWS CLI 체크
    if command -v aws &> /dev/null; then
        log_success "AWS CLI 설치됨: $(aws --version)"
    else
        log_warning "AWS CLI가 설치되지 않았습니다."
    fi
    
    # Google Cloud CLI 체크
    if command -v gcloud &> /dev/null; then
        log_success "Google Cloud CLI 설치됨: $(gcloud --version | head -1)"
    else
        log_warning "Google Cloud CLI가 설치되지 않았습니다."
    fi
    
    # kubectl 체크
    if command -v kubectl &> /dev/null; then
        log_success "kubectl 설치됨: $(kubectl version --client)"
    else
        log_warning "kubectl이 설치되지 않았습니다."
    fi
    
    # jq 체크
    if command -v jq &> /dev/null; then
        log_success "jq 설치됨: $(jq --version)"
    else
        log_warning "jq가 설치되지 않았습니다."
    fi
}

# AWS ECS 테스트
test_aws_ecs() {
    log_header "AWS ECS 테스트"
    
    cd ../../samples/day1/aws-ecs
    
    # Docker 이미지 빌드 테스트
    log_info "Docker 이미지 빌드 테스트"
    if docker build -t cloud-intermediate-app:test .; then
        log_success "Docker 이미지 빌드 성공"
    else
        log_error "Docker 이미지 빌드 실패"
        return 1
    fi
    
    # 기존 컨테이너 정리
    docker stop test-app 2>/dev/null || true
    docker rm test-app 2>/dev/null || true
    
    # 컨테이너 실행 테스트 (외부 접속 가능하도록 0.0.0.0 바인딩)
    log_info "컨테이너 실행 테스트 (외부 접속 가능)"
    if docker run -d --name test-app -p 0.0.0.0:3000:3000 cloud-intermediate-app:test; then
        log_success "컨테이너 실행 성공"
        
        # 헬스체크 테스트 (재시도 로직 포함)
        log_info "헬스체크 테스트 (최대 30초 대기)"
        for i in {1..6}; do
            sleep 5
            if curl -f http://localhost:3000/health 2>/dev/null; then
                log_success "헬스체크 성공 (${i}번째 시도)"
                break
            else
                log_warning "헬스체크 실패 (${i}/6 시도)"
                if [ $i -eq 6 ]; then
                    log_error "헬스체크 최종 실패"
                fi
            fi
        done
        
        # API 테스트 (응답 내용 검증)
        log_info "API 테스트"
        api_response=$(curl -s http://localhost:3000/api/status 2>/dev/null)
        if [ $? -eq 0 ] && [ -n "$api_response" ]; then
            log_success "API 테스트 성공"
            log_info "API 응답: $api_response"
        else
            log_error "API 테스트 실패"
        fi
        
        # 메트릭 테스트 (메트릭 데이터 검증)
        log_info "메트릭 엔드포인트 테스트"
        metrics_response=$(curl -s http://localhost:3000/metrics 2>/dev/null)
        if [ $? -eq 0 ] && echo "$metrics_response" | grep -q "http_requests_total"; then
            log_success "메트릭 엔드포인트 테스트 성공"
            log_info "메트릭 데이터 확인됨"
        else
            log_error "메트릭 엔드포인트 테스트 실패"
        fi
        
        # 컨테이너 상태 확인
        log_info "컨테이너 상태 확인"
        container_status=$(docker inspect test-app --format='{{.State.Status}}' 2>/dev/null)
        if [ "$container_status" = "running" ]; then
            log_success "컨테이너 정상 실행 중"
        else
            log_error "컨테이너 상태 이상: $container_status"
        fi
        
        # 컨테이너 정리
        docker stop test-app
        docker rm test-app
    else
        log_error "컨테이너 실행 실패"
        return 1
    fi
    
    cd ..
}

# GCP Cloud Run 테스트
test_gcp_cloud_run() {
    log_header "GCP Cloud Run 테스트"
    
    cd ../../samples/day1/gcp-cloud-run
    
    # Docker 이미지 빌드 테스트
    log_info "Docker 이미지 빌드 테스트"
    if docker build -t cloud-intermediate-app-gcp:test .; then
        log_success "Docker 이미지 빌드 성공"
    else
        log_error "Docker 이미지 빌드 실패"
        return 1
    fi
    
    # 기존 컨테이너 정리
    docker stop test-app-gcp 2>/dev/null || true
    docker rm test-app-gcp 2>/dev/null || true
    
    # 컨테이너 실행 테스트 (외부 접속 가능하도록 0.0.0.0 바인딩)
    log_info "컨테이너 실행 테스트 (외부 접속 가능)"
    if docker run -d --name test-app-gcp -p 0.0.0.0:8080:8080 cloud-intermediate-app-gcp:test; then
        log_success "컨테이너 실행 성공"
        
        # 헬스체크 테스트
        sleep 5
        if curl -f http://localhost:8080/health; then
            log_success "헬스체크 성공"
        else
            log_error "헬스체크 실패"
        fi
        
        # API 테스트
        if curl -f http://localhost:8080/api/status; then
            log_success "API 테스트 성공"
        else
            log_error "API 테스트 실패"
        fi
        
        # 메트릭 테스트
        if curl -f http://localhost:8080/metrics; then
            log_success "메트릭 엔드포인트 테스트 성공"
        else
            log_error "메트릭 엔드포인트 테스트 실패"
        fi
        
        # 컨테이너 정리
        docker stop test-app-gcp
        docker rm test-app-gcp
    else
        log_error "컨테이너 실행 실패"
        return 1
    fi
    
    cd ..
}

# 통합 모니터링 허브 테스트
test_monitoring_hub() {
    log_header "통합 모니터링 허브 테스트"
    
    cd ../../samples/day1/monitoring-hub
    
    # Docker Compose 테스트
    log_info "Docker Compose 설정 테스트"
    if docker-compose config; then
        log_success "Docker Compose 설정 유효"
    else
        log_error "Docker Compose 설정 오류"
        return 1
    fi
    
    # 간단한 모니터링 스택 실행 테스트 (복잡한 exporter 제외)
    log_info "간단한 모니터링 스택 실행 테스트"
    if docker-compose -f docker-compose-simple.yml up -d; then
        log_success "모니터링 스택 실행 성공"
        
        # 서비스 상태 확인
        sleep 10
        log_info "서비스 상태 확인"
        docker-compose ps
        
        # Prometheus 테스트
        if curl -f http://localhost:9090/api/v1/status/config; then
            log_success "Prometheus 연결 성공"
        else
            log_error "Prometheus 연결 실패"
        fi
        
        # Grafana 테스트
        if curl -f http://localhost:3000/api/health; then
            log_success "Grafana 연결 성공"
        else
            log_error "Grafana 연결 실패"
        fi
        
        # Node Exporter 테스트
        if curl -f http://localhost:9100/metrics; then
            log_success "Node Exporter 연결 성공"
        else
            log_error "Node Exporter 연결 실패"
        fi
        
        # AlertManager 테스트
        if curl -f http://localhost:9093/api/v1/status; then
            log_success "AlertManager 연결 성공"
        else
            log_error "AlertManager 연결 실패"
        fi
        
        # 모니터링 스택 정리
        docker-compose -f docker-compose-simple.yml down
    else
        log_error "모니터링 스택 실행 실패"
        return 1
    fi
    
    cd ..
}

# 메인 테스트 실행
main() {
    log_header "Cloud Intermediate Day 1 실습 테스트 시작"
    
    # 환경 체크
    if ! check_environment; then
        log_error "환경 체크 실패"
        exit 1
    fi
    
    # 방화벽 설정
    setup_firewall
    
    # AWS ECS 테스트
    if ! test_aws_ecs; then
        log_error "AWS ECS 테스트 실패"
        exit 1
    fi
    
    # GCP Cloud Run 테스트
    if ! test_gcp_cloud_run; then
        log_error "GCP Cloud Run 테스트 실패"
        exit 1
    fi
    
    # 통합 모니터링 허브 테스트
    if ! test_monitoring_hub; then
        log_error "통합 모니터링 허브 테스트 실패"
        exit 1
    fi
    
    log_success "모든 테스트 완료!"
    log_info "실습 환경이 정상적으로 구성되었습니다."
    
    # 외부 접속 정보 출력
    show_external_access
}

# 스크립트 실행
main "$@"
