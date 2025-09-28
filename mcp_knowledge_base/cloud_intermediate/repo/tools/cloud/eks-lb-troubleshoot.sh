#!/bin/bash

# EKS LoadBalancer 문제 해결 스크립트
# 방화벽 및 보안 그룹 설정 자동 수정

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# 로그 함수
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_header() { echo -e "${PURPLE}=== $1 ===${NC}"; }

# EKS LoadBalancer 문제 진단 및 해결
eks_lb_troubleshoot() {
    log_header "EKS LoadBalancer 문제 진단 및 해결"
    
    # 1. 현재 클러스터 정보 확인
    log_info "1. 현재 EKS 클러스터 정보 확인"
    CURRENT_CLUSTER=$(kubectl config current-context | grep -o 'arn:aws:eks:[^/]*/[^/]*' | cut -d'/' -f2)
    if [ -z "$CURRENT_CLUSTER" ]; then
        log_error "EKS 클러스터에 연결되지 않았습니다."
        return 1
    fi
    log_success "현재 클러스터: $CURRENT_CLUSTER"
    
    # 2. 보안 그룹 ID 확인
    log_info "2. EKS 클러스터 보안 그룹 확인"
    SECURITY_GROUP_ID=$(aws eks describe-cluster --name "$CURRENT_CLUSTER" --query 'cluster.resourcesVpcConfig.securityGroupIds[0]' --output text)
    if [ -z "$SECURITY_GROUP_ID" ] || [ "$SECURITY_GROUP_ID" = "None" ]; then
        log_error "보안 그룹을 찾을 수 없습니다."
        return 1
    fi
    log_success "보안 그룹 ID: $SECURITY_GROUP_ID"
    
    # 3. 현재 보안 그룹 규칙 확인
    log_info "3. 현재 보안 그룹 규칙 확인"
    INBOUND_RULES=$(aws ec2 describe-security-groups --group-ids "$SECURITY_GROUP_ID" --query 'SecurityGroups[0].IpPermissions' --output json)
    if [ "$INBOUND_RULES" = "[]" ]; then
        log_warning "인바운드 규칙이 없습니다. 방화벽 규칙을 추가합니다."
        add_firewall_rules "$SECURITY_GROUP_ID"
    else
        log_info "현재 인바운드 규칙:"
        echo "$INBOUND_RULES" | jq '.'
        
        # HTTP/HTTPS 포트 확인
        HTTP_RULE=$(echo "$INBOUND_RULES" | jq '.[] | select(.FromPort == 80 and .ToPort == 80)')
        HTTPS_RULE=$(echo "$INBOUND_RULES" | jq '.[] | select(.FromPort == 443 and .ToPort == 443)')
        
        if [ -z "$HTTP_RULE" ] || [ "$HTTP_RULE" = "null" ]; then
            log_warning "HTTP 포트 80이 허용되지 않았습니다. 추가합니다."
            add_firewall_rules "$SECURITY_GROUP_ID"
        else
            log_success "HTTP 포트 80이 이미 허용되어 있습니다."
        fi
        
        if [ -z "$HTTPS_RULE" ] || [ "$HTTPS_RULE" = "null" ]; then
            log_warning "HTTPS 포트 443이 허용되지 않았습니다. 추가합니다."
            add_firewall_rules "$SECURITY_GROUP_ID"
        else
            log_success "HTTPS 포트 443이 이미 허용되어 있습니다."
        fi
    fi
    
    # 4. LoadBalancer 서비스 확인
    log_info "4. LoadBalancer 서비스 확인"
    LB_SERVICES=$(kubectl get service -n day1-practice --field-selector spec.type=LoadBalancer -o json)
    if [ "$LB_SERVICES" = "null" ] || [ "$(echo "$LB_SERVICES" | jq '.items | length')" -eq 0 ]; then
        log_warning "LoadBalancer 서비스가 없습니다. 새로 생성합니다."
        create_loadbalancer_service
    else
        log_info "LoadBalancer 서비스가 존재합니다:"
        kubectl get service -n day1-practice --field-selector spec.type=LoadBalancer
        
        # External IP 확인
        EXTERNAL_IP=$(kubectl get service -n day1-practice --field-selector spec.type=LoadBalancer -o jsonpath='{.items[0].status.loadBalancer.ingress[0].hostname}')
        if [ -n "$EXTERNAL_IP" ]; then
            log_success "External IP: $EXTERNAL_IP"
            test_loadbalancer_access "$EXTERNAL_IP"
        else
            log_warning "External IP가 아직 할당되지 않았습니다."
        fi
    fi
}

# 방화벽 규칙 추가
add_firewall_rules() {
    local sg_id="$1"
    
    log_info "방화벽 규칙 추가 중..."
    
    # HTTP 포트 80 추가
    log_info "HTTP 포트 80 규칙 추가"
    if aws ec2 authorize-security-group-ingress --group-id "$sg_id" --protocol tcp --port 80 --cidr 0.0.0.0/0 2>/dev/null; then
        log_success "HTTP 포트 80 규칙 추가 완료"
    else
        log_warning "HTTP 포트 80 규칙이 이미 존재하거나 추가 실패"
    fi
    
    # HTTPS 포트 443 추가
    log_info "HTTPS 포트 443 규칙 추가"
    if aws ec2 authorize-security-group-ingress --group-id "$sg_id" --protocol tcp --port 443 --cidr 0.0.0.0/0 2>/dev/null; then
        log_success "HTTPS 포트 443 규칙 추가 완료"
    else
        log_warning "HTTPS 포트 443 규칙이 이미 존재하거나 추가 실패"
    fi
    
    # 추가 포트들 (NodePort 범위)
    log_info "NodePort 범위 포트 추가 (30000-32767)"
    if aws ec2 authorize-security-group-ingress --group-id "$sg_id" --protocol tcp --port 30000-32767 --cidr 0.0.0.0/0 2>/dev/null; then
        log_success "NodePort 범위 포트 규칙 추가 완료"
    else
        log_warning "NodePort 범위 포트 규칙이 이미 존재하거나 추가 실패"
    fi
}

# LoadBalancer 서비스 생성
create_loadbalancer_service() {
    log_info "LoadBalancer 서비스 생성 중..."
    
    cat > myapp-service-lb-troubleshoot.yaml << 'EOF'
apiVersion: v1
kind: Service
metadata:
  name: myapp-service-lb-troubleshoot
  namespace: day1-practice
  labels:
    app: myapp
spec:
  type: LoadBalancer
  ports:
  - port: 80
    targetPort: 80
    protocol: TCP
  selector:
    app: myapp
EOF

    kubectl apply -f myapp-service-lb-troubleshoot.yaml
    
    log_info "LoadBalancer 서비스 생성 완료. External IP 할당 대기 중..."
    
    # External IP 할당 대기
    for i in {1..12}; do
        EXTERNAL_IP=$(kubectl get service myapp-service-lb-troubleshoot -n day1-practice -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null)
        if [ -n "$EXTERNAL_IP" ]; then
            log_success "External IP 할당 완료: $EXTERNAL_IP"
            test_loadbalancer_access "$EXTERNAL_IP"
            break
        else
            log_info "External IP 할당 대기 중... ($i/12)"
            sleep 10
        fi
    done
    
    if [ -z "$EXTERNAL_IP" ]; then
        log_warning "External IP가 아직 할당되지 않았습니다. 잠시 후 다시 확인하세요."
        kubectl get service myapp-service-lb-troubleshoot -n day1-practice
    fi
}

# LoadBalancer 접근 테스트
test_loadbalancer_access() {
    local external_ip="$1"
    
    log_info "LoadBalancer 접근 테스트: $external_ip"
    
    # HTTP 접근 테스트
    if curl -s -o /dev/null -w "HTTP Status: %{http_code}\n" "http://$external_ip" --connect-timeout 10; then
        log_success "HTTP 접근 성공!"
        log_info "접근 URL: http://$external_ip"
        
        # 상세 응답 확인
        log_info "응답 내용 확인:"
        curl -s "http://$external_ip" | head -5
    else
        log_error "HTTP 접근 실패"
        log_info "가능한 원인:"
        log_info "1. ALB가 아직 완전히 준비되지 않음 (2-3분 더 대기)"
        log_info "2. 보안 그룹 규칙이 아직 적용되지 않음"
        log_info "3. Pod가 실행되지 않음"
        
        # Pod 상태 확인
        log_info "Pod 상태 확인:"
        kubectl get pods -n day1-practice
    fi
}

# 종합 진단
comprehensive_diagnosis() {
    log_header "EKS LoadBalancer 종합 진단"
    
    # 1. 클러스터 연결 확인
    log_info "1. 클러스터 연결 확인"
    if kubectl get nodes &> /dev/null; then
        log_success "클러스터 연결 정상"
    else
        log_error "클러스터 연결 실패"
        return 1
    fi
    
    # 2. Pod 상태 확인
    log_info "2. Pod 상태 확인"
    kubectl get pods -n day1-practice
    POD_COUNT=$(kubectl get pods -n day1-practice --field-selector status.phase=Running --no-headers | wc -l)
    if [ "$POD_COUNT" -eq 0 ]; then
        log_error "실행 중인 Pod가 없습니다."
        return 1
    else
        log_success "실행 중인 Pod: $POD_COUNT개"
    fi
    
    # 3. 서비스 상태 확인
    log_info "3. 서비스 상태 확인"
    kubectl get service -n day1-practice
    
    # 4. 엔드포인트 확인
    log_info "4. 엔드포인트 확인"
    kubectl get endpoints -n day1-practice
    
    # 5. 보안 그룹 확인
    log_info "5. 보안 그룹 확인"
    CURRENT_CLUSTER=$(kubectl config current-context | grep -o 'arn:aws:eks:[^/]*/[^/]*' | cut -d'/' -f2)
    SECURITY_GROUP_ID=$(aws eks describe-cluster --name "$CURRENT_CLUSTER" --query 'cluster.resourcesVpcConfig.securityGroupIds[0]' --output text)
    aws ec2 describe-security-groups --group-ids "$SECURITY_GROUP_ID" --query 'SecurityGroups[0].IpPermissions'
    
    # 6. ALB 상태 확인
    log_info "6. ALB 상태 확인"
    aws elbv2 describe-load-balancers --query 'LoadBalancers[*].[LoadBalancerName,State.Code,DNSName]' --output table
}

# 메인 실행
main() {
    case "${1:-}" in
        "diagnose")
            comprehensive_diagnosis
            ;;
        "fix")
            eks_lb_troubleshoot
            ;;
        "test")
            if [ -n "${2:-}" ]; then
                test_loadbalancer_access "$2"
            else
                log_error "테스트할 URL을 제공해주세요."
                echo "사용법: $0 test <URL>"
            fi
            ;;
        *)
            echo "EKS LoadBalancer 문제 해결 스크립트"
            echo ""
            echo "사용법:"
            echo "  $0 diagnose    # 종합 진단"
            echo "  $0 fix         # 문제 자동 해결"
            echo "  $0 test <URL>  # 접근 테스트"
            echo ""
            echo "예시:"
            echo "  $0 diagnose"
            echo "  $0 fix"
            echo "  $0 test http://your-alb-url"
            ;;
    esac
}

# 스크립트 실행
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
