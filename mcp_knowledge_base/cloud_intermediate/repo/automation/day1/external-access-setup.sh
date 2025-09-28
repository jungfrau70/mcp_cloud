#!/bin/bash

# Kubernetes 서비스 외부 접근 설정 스크립트
# Cloud Intermediate Day 1 - 외부 접근 실습

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

# 메뉴 함수
show_menu() {
    echo -e "${PURPLE}=== Kubernetes 서비스 외부 접근 설정 ===${NC}"
    echo "1. LoadBalancer 서비스 배포 (AWS EKS 권장)"
    echo "2. NodePort 서비스 배포"
    echo "3. Ingress 컨트롤러 설정"
    echo "4. 포트 포워딩으로 임시 접근"
    echo "5. 현재 서비스 상태 확인"
    echo "6. 외부 접근 테스트"
    echo "7. 정리"
    echo "8. 종료"
    echo ""
}

# LoadBalancer 서비스 배포
deploy_loadbalancer() {
    log_info "LoadBalancer 서비스 배포 중..."
    
    # 기존 서비스 삭제
    kubectl delete service myapp-service -n day1-practice 2>/dev/null
    
    # LoadBalancer 서비스 배포
    kubectl apply -f /home/ec2-user/mcp_knowledge_base/cloud_intermediate/repo/samples/day1/external-access/myapp-service-loadbalancer.yaml
    
    log_info "LoadBalancer 서비스 생성 중... (1-2분 소요)"
    
    # External IP 대기
    log_info "External IP 할당 대기 중..."
    kubectl wait --for=condition=Ready service/myapp-service-lb -n day1-practice --timeout=300s
    
    # External IP 확인
    EXTERNAL_IP=$(kubectl get service myapp-service-lb -n day1-practice -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
    
    if [ -n "$EXTERNAL_IP" ]; then
        log_success "LoadBalancer 서비스 배포 완료!"
        log_info "External IP: $EXTERNAL_IP"
        log_info "접근 URL: http://$EXTERNAL_IP"
    else
        log_warning "External IP가 아직 할당되지 않았습니다. 잠시 후 다시 확인하세요."
    fi
}

# NodePort 서비스 배포
deploy_nodeport() {
    log_info "NodePort 서비스 배포 중..."
    
    # 기존 서비스 삭제
    kubectl delete service myapp-service -n day1-practice 2>/dev/null
    
    # NodePort 서비스 배포
    kubectl apply -f /home/ec2-user/mcp_knowledge_base/cloud_intermediate/repo/samples/day1/external-access/myapp-service-nodeport.yaml
    
    log_success "NodePort 서비스 배포 완료!"
    
    # NodePort 확인
    NODEPORT=$(kubectl get service myapp-service-np -n day1-practice -o jsonpath='{.spec.ports[0].nodePort}')
    log_info "NodePort: $NODEPORT"
    
    # 노드 IP 확인
    NODE_IP=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="ExternalIP")].address}')
    if [ -z "$NODE_IP" ]; then
        NODE_IP=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')
    fi
    
    log_info "노드 IP: $NODE_IP"
    log_info "접근 URL: http://$NODE_IP:$NODEPORT"
}

# Ingress 설정
setup_ingress() {
    log_info "Ingress 설정 중..."
    
    # AWS Load Balancer Controller 설치 확인
    if ! kubectl get deployment aws-load-balancer-controller -n kube-system >/dev/null 2>&1; then
        log_warning "AWS Load Balancer Controller가 설치되지 않았습니다."
        log_info "Ingress 설정을 위해서는 ALB Ingress Controller가 필요합니다."
        return 1
    fi
    
    # Ingress 배포
    kubectl apply -f /home/ec2-user/mcp_knowledge_base/cloud_intermediate/repo/samples/day1/external-access/myapp-ingress.yaml
    
    log_success "Ingress 설정 완료!"
    log_info "ALB 생성 중... (2-3분 소요)"
    
    # ALB URL 확인
    sleep 30
    ALB_URL=$(kubectl get ingress myapp-ingress -n day1-practice -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
    
    if [ -n "$ALB_URL" ]; then
        log_success "ALB 생성 완료!"
        log_info "ALB URL: http://$ALB_URL"
    else
        log_warning "ALB가 아직 생성되지 않았습니다. 잠시 후 다시 확인하세요."
    fi
}

# 포트 포워딩으로 임시 접근
port_forward() {
    log_info "포트 포워딩 설정 중..."
    
    # 기존 포트 포워딩 프로세스 종료
    pkill -f "kubectl port-forward" 2>/dev/null
    
    # 포트 포워딩 시작
    kubectl port-forward service/myapp-service 8080:80 -n day1-practice &
    PORT_FORWARD_PID=$!
    
    sleep 3
    
    if ps -p $PORT_FORWARD_PID > /dev/null; then
        log_success "포트 포워딩 설정 완료!"
        log_info "로컬 접근 URL: http://localhost:8080"
        log_info "포트 포워딩 PID: $PORT_FORWARD_PID"
        log_warning "포트 포워딩을 중지하려면: kill $PORT_FORWARD_PID"
    else
        log_error "포트 포워딩 설정 실패"
    fi
}

# 서비스 상태 확인
check_services() {
    log_info "현재 서비스 상태 확인..."
    
    echo -e "\n${PURPLE}=== Namespace: day1-practice ===${NC}"
    kubectl get all -n day1-practice
    
    echo -e "\n${PURPLE}=== 서비스 상세 정보 ===${NC}"
    kubectl get services -n day1-practice -o wide
    
    echo -e "\n${PURPLE}=== Ingress 정보 ===${NC}"
    kubectl get ingress -n day1-practice 2>/dev/null || echo "Ingress 없음"
}

# 외부 접근 테스트
test_external_access() {
    log_info "외부 접근 테스트 중..."
    
    # LoadBalancer 서비스 확인
    LB_IP=$(kubectl get service myapp-service-lb -n day1-practice -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null)
    if [ -n "$LB_IP" ]; then
        log_info "LoadBalancer 테스트: http://$LB_IP"
        curl -s -o /dev/null -w "HTTP Status: %{http_code}\n" "http://$LB_IP" || log_warning "LoadBalancer 접근 실패"
    fi
    
    # NodePort 서비스 확인
    NODEPORT=$(kubectl get service myapp-service-np -n day1-practice -o jsonpath='{.spec.ports[0].nodePort}' 2>/dev/null)
    if [ -n "$NODEPORT" ]; then
        NODE_IP=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="ExternalIP")].address}')
        if [ -z "$NODE_IP" ]; then
            NODE_IP=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')
        fi
        log_info "NodePort 테스트: http://$NODE_IP:$NODEPORT"
        curl -s -o /dev/null -w "HTTP Status: %{http_code}\n" "http://$NODE_IP:$NODEPORT" || log_warning "NodePort 접근 실패"
    fi
    
    # 포트 포워딩 테스트
    log_info "포트 포워딩 테스트: http://localhost:8080"
    curl -s -o /dev/null -w "HTTP Status: %{http_code}\n" "http://localhost:8080" || log_warning "포트 포워딩 접근 실패"
}

# 정리
cleanup() {
    log_info "외부 접근 설정 정리 중..."
    
    # 포트 포워딩 프로세스 종료
    pkill -f "kubectl port-forward" 2>/dev/null
    
    # LoadBalancer 서비스 삭제
    kubectl delete service myapp-service-lb -n day1-practice 2>/dev/null
    
    # NodePort 서비스 삭제
    kubectl delete service myapp-service-np -n day1-practice 2>/dev/null
    
    # Ingress 삭제
    kubectl delete ingress myapp-ingress -n day1-practice 2>/dev/null
    
    # 원래 ClusterIP 서비스 복원
    kubectl apply -f /home/ec2-user/mcp_knowledge_base/cloud_intermediate/repo/samples/day1/kubernetes-basics/myapp-service.yaml
    
    log_success "정리 완료!"
}

# 메인 실행
main() {
    while true; do
        show_menu
        read -p "선택하세요 (1-8): " choice
        
        case $choice in
            1)
                deploy_loadbalancer
                ;;
            2)
                deploy_nodeport
                ;;
            3)
                setup_ingress
                ;;
            4)
                port_forward
                ;;
            5)
                check_services
                ;;
            6)
                test_external_access
                ;;
            7)
                cleanup
                ;;
            8)
                log_info "종료합니다."
                exit 0
                ;;
            *)
                log_error "잘못된 선택입니다."
                ;;
        esac
        
        echo ""
        read -p "계속하려면 Enter를 누르세요..."
        echo ""
    done
}

# 스크립트 실행
main "$@"
