#!/bin/bash

# Cloud Master Day 2 - Kubernetes Practice Automation Script
# 작성자: Cloud Master Team
# 목적: Kubernetes 클러스터 관리 및 애플리케이션 배포 실습 자동화

set -e  # 오류 발생 시 스크립트 중단

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 로그 함수
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 실습 환경 확인
check_prerequisites() {
    log_info "실습 환경 확인 중..."
    
    # 통합 환경 체크 스크립트 실행
    if [ -f "../../cloud-scripts/environment-check.sh" ]; then
        log_info "통합 환경 체크 실행 중..."
        if bash ../../cloud-scripts/environment-check.sh day2; then
            log_success "환경 체크 완료"
        else
            log_warning "환경 체크에서 일부 문제가 발견되었습니다."
            log_warning "계속 진행하시겠습니까? (y/N)"
            read -r response
            if [[ ! "$response" =~ ^[Yy]$ ]]; then
                log_info "실습을 중단합니다."
                exit 0
            fi
        fi
    else
        # 기본 환경 체크 (fallback)
        log_info "기본 환경 체크 실행 중..."
        
        # kubectl 설치 확인
        if ! command -v kubectl &> /dev/null; then
            log_error "kubectl이 설치되지 않았습니다. 먼저 kubectl을 설치해주세요."
            install_kubectl
        fi
        
        # Docker 설치 확인
        if ! command -v docker &> /dev/null; then
            log_error "Docker가 설치되지 않았습니다. 먼저 Docker를 설치해주세요."
            exit 1
        fi
        
        # Minikube 설치 확인
        if ! command -v minikube &> /dev/null; then
        log_warning "Minikube가 설치되지 않았습니다. 자동으로 설치를 시도합니다."
        install_minikube
    fi
    
    log_success "실습 환경 확인 완료"
}

# kubectl 설치
install_kubectl() {
    log_info "kubectl 설치 중..."
    
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # Linux
        curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
        sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        if command -v brew &> /dev/null; then
            brew install kubectl
        else
            curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/darwin/amd64/kubectl"
            chmod +x kubectl
            sudo mv kubectl /usr/local/bin/
        fi
    else
        log_error "지원되지 않는 운영체제입니다. kubectl을 수동으로 설치해주세요."
        exit 1
    fi
    
    log_success "kubectl 설치 완료"
}

# Minikube 설치
install_minikube() {
    log_info "Minikube 설치 중..."
    
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # Linux
        curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
        sudo install minikube-linux-amd64 /usr/local/bin/minikube
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        if command -v brew &> /dev/null; then
            brew install minikube
        else
            curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-darwin-amd64
            sudo install minikube-darwin-amd64 /usr/local/bin/minikube
        fi
    else
        log_error "지원되지 않는 운영체제입니다. Minikube를 수동으로 설치해주세요."
        exit 1
    fi
    
    log_success "Minikube 설치 완료"
}

# 1단계: Kubernetes 클러스터 시작
step1_start_cluster() {
    log_info "=== 1단계: Kubernetes 클러스터 시작 ==="
    
    # Minikube 상태 확인
    log_info "Minikube 상태 확인:"
    if minikube status | grep -q "Running"; then
        log_info "Minikube가 이미 실행 중입니다."
    else
        log_info "Minikube 클러스터 시작:"
        minikube start --driver=docker --memory=4096 --cpus=2
    fi
    
    # 클러스터 상태 확인
    log_info "클러스터 상태 확인:"
    kubectl cluster-info
    
    # 노드 상태 확인
    log_info "노드 상태 확인:"
    kubectl get nodes
    
    # 네임스페이스 확인
    log_info "네임스페이스 확인:"
    kubectl get namespaces
    
    log_success "1단계 완료: Kubernetes 클러스터 시작"
}

# 2단계: 기본 리소스 관리 실습
step2_basic_resource_management() {
    log_info "=== 2단계: 기본 리소스 관리 실습 ==="
    
    # 실습용 네임스페이스 확인 및 생성
    log_info "실습용 네임스페이스 확인:"
    if kubectl get namespace k8s-practice &> /dev/null; then
        log_info "k8s-practice 네임스페이스가 이미 존재합니다."
    else
        log_info "실습용 네임스페이스 생성:"
        kubectl create namespace k8s-practice
    fi
    
    # 기존 Pod 정리
    log_info "기존 Pod 정리:"
    if kubectl get pod nginx-pod -n k8s-practice &> /dev/null; then
        log_info "기존 nginx-pod를 삭제합니다."
        kubectl delete pod nginx-pod -n k8s-practice --ignore-not-found=true
    fi
    
    # Pod 생성
    log_info "Pod 생성:"
    kubectl run nginx-pod --image=nginx:1.21 --namespace=k8s-practice
    
    # Pod 시작 대기
    log_info "Pod 시작 대기 (30초)..."
    kubectl wait --for=condition=Ready pod/nginx-pod -n k8s-practice --timeout=60s
    
    # Pod 상태 확인
    log_info "Pod 상태 확인:"
    kubectl get pods -n k8s-practice
    kubectl get pods -n k8s-practice -o wide
    
    # Pod 상세 정보 확인
    log_info "Pod 상세 정보 확인:"
    kubectl describe pod nginx-pod -n k8s-practice
    
    # Pod 로그 확인
    log_info "Pod 로그 확인:"
    kubectl logs nginx-pod -n k8s-practice | head -10
    
    # Pod 삭제
    log_info "Pod 삭제:"
    kubectl delete pod nginx-pod -n k8s-practice
    
    log_success "2단계 완료: 기본 리소스 관리 실습"
}

# 3단계: Deployment 실습
step3_deployment_practice() {
    log_info "=== 3단계: Deployment 실습 ==="
    
    # 기존 Deployment 정리
    log_info "기존 Deployment 정리:"
    if kubectl get deployment nginx-deployment -n k8s-practice &> /dev/null; then
        log_info "기존 nginx-deployment를 삭제합니다."
        kubectl delete deployment nginx-deployment -n k8s-practice --ignore-not-found=true
    fi
    
    # Deployment 생성
    log_info "Deployment 생성:"
    kubectl create deployment nginx-deployment --image=nginx:1.21 --replicas=3 --namespace=k8s-practice
    
    # Deployment 시작 대기
    log_info "Deployment 시작 대기 (60초)..."
    kubectl wait --for=condition=Available deployment/nginx-deployment -n k8s-practice --timeout=120s
    
    # Deployment 상태 확인
    log_info "Deployment 상태 확인:"
    kubectl get deployments -n k8s-practice
    kubectl get pods -n k8s-practice
    
    # Deployment 스케일링
    log_info "Deployment 스케일링 (5개로 확장):"
    kubectl scale deployment nginx-deployment --replicas=5 --namespace=k8s-practice
    
    # 스케일링 상태 확인
    log_info "스케일링 상태 확인:"
    kubectl get pods -n k8s-practice
    kubectl rollout status deployment/nginx-deployment -n k8s-practice
    
    # Deployment 롤아웃 히스토리
    log_info "Deployment 롤아웃 히스토리:"
    kubectl rollout history deployment/nginx-deployment -n k8s-practice
    
    # Deployment 업데이트
    log_info "Deployment 업데이트 (이미지 변경):"
    kubectl set image deployment/nginx-deployment nginx=nginx:1.22 --namespace=k8s-practice
    
    # 업데이트 상태 확인
    log_info "업데이트 상태 확인:"
    kubectl rollout status deployment/nginx-deployment -n k8s-practice
    kubectl get pods -n k8s-practice
    
    log_success "3단계 완료: Deployment 실습"
}

# 4단계: Service 실습
step4_service_practice() {
    log_info "=== 4단계: Service 실습 ==="
    
    # Service 생성 (LoadBalancer)
    log_info "Service 생성 (LoadBalancer):"
    kubectl expose deployment nginx-deployment --port=80 --type=LoadBalancer --namespace=k8s-practice
    
    # Service 상태 확인
    log_info "Service 상태 확인:"
    kubectl get services -n k8s-practice
    kubectl get endpoints -n k8s-practice
    
    # Service 상세 정보
    log_info "Service 상세 정보:"
    kubectl describe service nginx-deployment -n k8s-practice
    
    # 포트 포워딩으로 접근 테스트
    log_info "포트 포워딩으로 접근 테스트:"
    kubectl port-forward service/nginx-deployment 8080:80 -n k8s-practice &
    PORT_FORWARD_PID=$!
    
    # 포트 포워딩 대기
    sleep 5
    
    # 웹 서버 접근 테스트
    log_info "웹 서버 접근 테스트:"
    if command -v curl &> /dev/null; then
        curl -s http://localhost:8080 | head -5
    else
        log_warning "curl이 설치되지 않았습니다. 브라우저에서 http://localhost:8080 접속해보세요."
    fi
    
    # 포트 포워딩 종료
    kill $PORT_FORWARD_PID 2>/dev/null || true
    
    log_success "4단계 완료: Service 실습"
}

# 5단계: ConfigMap과 Secret 실습
step5_configmap_secret_practice() {
    log_info "=== 5단계: ConfigMap과 Secret 실습 ==="
    
    # ConfigMap 생성
    log_info "ConfigMap 생성:"
    kubectl create configmap nginx-config --from-literal=server_name=my-nginx --from-literal=worker_processes=auto --namespace=k8s-practice
    
    # ConfigMap 확인
    log_info "ConfigMap 확인:"
    kubectl get configmaps -n k8s-practice
    kubectl describe configmap nginx-config -n k8s-practice
    
    # Secret 생성
    log_info "Secret 생성:"
    kubectl create secret generic nginx-secret --from-literal=username=admin --from-literal=password=secret123 --namespace=k8s-practice
    
    # Secret 확인
    log_info "Secret 확인:"
    kubectl get secrets -n k8s-practice
    kubectl describe secret nginx-secret -n k8s-practice
    
    # ConfigMap과 Secret을 사용하는 Pod 생성
    log_info "ConfigMap과 Secret을 사용하는 Pod 생성:"
    cat > config-pod.yaml << 'EOF'
apiVersion: v1
kind: Pod
metadata:
  name: config-pod
  namespace: k8s-practice
spec:
  containers:
  - name: nginx
    image: nginx:1.21
    env:
    - name: SERVER_NAME
      valueFrom:
        configMapKeyRef:
          name: nginx-config
          key: server_name
    - name: WORKER_PROCESSES
      valueFrom:
        configMapKeyRef:
          name: nginx-config
          key: worker_processes
    - name: USERNAME
      valueFrom:
        secretKeyRef:
          name: nginx-secret
          key: username
    - name: PASSWORD
      valueFrom:
        secretKeyRef:
          name: nginx-secret
          key: password
    command: ["/bin/sh"]
    args: ["-c", "echo 'Server: $SERVER_NAME, Workers: $WORKER_PROCESSES, User: $USERNAME' && sleep 3600"]
EOF
    
    kubectl apply -f config-pod.yaml
    
    # Pod 상태 확인
    log_info "Config Pod 상태 확인:"
    kubectl get pods -n k8s-practice
    kubectl logs config-pod -n k8s-practice
    
    # 정리
    kubectl delete -f config-pod.yaml
    rm config-pod.yaml
    
    log_success "5단계 완료: ConfigMap과 Secret 실습"
}

# 6단계: 고급 명령어 실습
step6_advanced_commands() {
    log_info "=== 6단계: 고급 명령어 실습 ==="
    
    # 모든 리소스 확인
    log_info "모든 리소스 확인:"
    kubectl get all -n k8s-practice
    
    # 리소스 상세 정보
    log_info "리소스 상세 정보:"
    kubectl get all -n k8s-practice -o wide
    
    # 노드 상세 정보
    log_info "노드 상세 정보:"
    kubectl describe nodes
    
    # 리소스 편집 (Deployment)
    log_info "리소스 편집 (Deployment):"
    kubectl edit deployment nginx-deployment -n k8s-practice --dry-run=client -o yaml | head -20
    
    # 리소스 패치
    log_info "리소스 패치 (replicas 변경):"
    kubectl patch deployment nginx-deployment -n k8s-practice -p '{"spec":{"replicas":2}}'
    
    # 패치 결과 확인
    log_info "패치 결과 확인:"
    kubectl get pods -n k8s-practice
    
    # 리소스 라벨 추가
    log_info "리소스 라벨 추가:"
    kubectl label deployment nginx-deployment app=web-server -n k8s-practice
    
    # 라벨로 리소스 조회
    log_info "라벨로 리소스 조회:"
    kubectl get deployments -l app=web-server -n k8s-practice
    
    # 리소스 어노테이션 추가
    log_info "리소스 어노테이션 추가:"
    kubectl annotate deployment nginx-deployment description="Nginx web server deployment" -n k8s-practice
    
    # 어노테이션 확인
    log_info "어노테이션 확인:"
    kubectl describe deployment nginx-deployment -n k8s-practice | grep -A 5 Annotations
    
    log_success "6단계 완료: 고급 명령어 실습"
}

# 7단계: 모니터링 및 디버깅
step7_monitoring_debugging() {
    log_info "=== 7단계: 모니터링 및 디버깅 ==="
    
    # 리소스 사용량 확인
    log_info "리소스 사용량 확인:"
    kubectl top nodes 2>/dev/null || log_warning "metrics-server가 설치되지 않았습니다."
    kubectl top pods -n k8s-practice 2>/dev/null || log_warning "metrics-server가 설치되지 않았습니다."
    
    # 이벤트 확인
    log_info "이벤트 확인:"
    kubectl get events -n k8s-practice --sort-by='.lastTimestamp' | head -10
    
    # Pod 로그 실시간 확인 (백그라운드)
    log_info "Pod 로그 실시간 확인:"
    kubectl logs -f deployment/nginx-deployment -n k8s-practice --tail=10 &
    LOG_PID=$!
    sleep 5
    kill $LOG_PID 2>/dev/null || true
    
    # Pod 내부 접속
    log_info "Pod 내부 접속 테스트:"
    POD_NAME=$(kubectl get pods -n k8s-practice -l app=nginx-deployment -o jsonpath='{.items[0].metadata.name}')
    kubectl exec -it $POD_NAME -n k8s-practice -- nginx -v
    
    # 리소스 상태 요약
    log_info "리소스 상태 요약:"
    echo "=== Namespaces ==="
    kubectl get namespaces
    echo ""
    echo "=== Nodes ==="
    kubectl get nodes
    echo ""
    echo "=== Pods ==="
    kubectl get pods -n k8s-practice
    echo ""
    echo "=== Services ==="
    kubectl get services -n k8s-practice
    echo ""
    echo "=== Deployments ==="
    kubectl get deployments -n k8s-practice
    
    log_success "7단계 완료: 모니터링 및 디버깅"
}

# 8단계: 정리 및 요약
step8_cleanup_and_summary() {
    log_info "=== 8단계: 정리 및 요약 ==="
    
    # 실습 네임스페이스 삭제
    log_info "실습 네임스페이스 삭제:"
    kubectl delete namespace k8s-practice
    
    # 네임스페이스 삭제 확인
    log_info "네임스페이스 삭제 확인:"
    kubectl get namespaces | grep k8s-practice || log_success "네임스페이스가 성공적으로 삭제되었습니다."
    
    # Minikube 상태 확인
    log_info "Minikube 상태 확인:"
    minikube status
    
    # 실습 결과 요약
    log_success "=== Kubernetes 실습 완료 ==="
    echo "✅ Kubernetes 클러스터 시작 (Minikube)"
    echo "✅ 기본 리소스 관리 (Pod, Namespace)"
    echo "✅ Deployment 관리 및 스케일링"
    echo "✅ Service 생성 및 노출"
    echo "✅ ConfigMap과 Secret 관리"
    echo "✅ 고급 kubectl 명령어 실습"
    echo "✅ 모니터링 및 디버깅 기법"
    echo "✅ 리소스 정리 및 관리"
    echo ""
    echo "🔧 주요 학습 내용:"
    echo "  - kubectl 기본 명령어"
    echo "  - Pod, Deployment, Service 개념"
    echo "  - ConfigMap과 Secret 활용"
    echo "  - 스케일링과 롤아웃"
    echo "  - 네트워킹과 서비스 디스커버리"
    echo "  - 모니터링과 디버깅"
    echo ""
    echo "📚 다음 단계:"
    echo "  - Helm을 사용한 패키지 관리"
    echo "  - Ingress를 사용한 외부 접근"
    echo "  - PersistentVolume과 StorageClass"
    echo "  - RBAC과 보안 설정"
}

# 메인 실행 함수
main() {
    log_info "Cloud Master Day 2 - Kubernetes Practice Automation 시작"
    echo "================================================================="
    
    check_prerequisites
    step1_start_cluster
    step2_basic_resource_management
    step3_deployment_practice
    step4_service_practice
    step5_configmap_secret_practice
    step6_advanced_commands
    step7_monitoring_debugging
    step8_cleanup_and_summary
    
    log_success "모든 Kubernetes 실습이 완료되었습니다!"
}

# 스크립트 실행
main "$@"
