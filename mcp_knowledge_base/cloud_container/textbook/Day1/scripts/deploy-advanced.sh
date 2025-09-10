#!/bin/bash

# Container 과정 고급 실습 배포 스크립트
# Kubernetes, Helm, Istio, 모니터링 통합 배포

set -e

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

# 변수 설정
NAMESPACE="container-demo"
PROJECT_ID=${GCP_PROJECT_ID:-"your-project-id"}
IMAGE_TAG=${IMAGE_TAG:-"latest"}

log_info "=== Container 과정 고급 실습 배포 시작 ==="

# 1단계: Namespace 생성
log_info "1단계: Namespace 및 기본 리소스 생성"
kubectl create namespace $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -

# ConfigMap 생성
kubectl apply -f - <<EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: container-demo-config
  namespace: $NAMESPACE
data:
  app.properties: |
    server.port=3000
    logging.level=INFO
    database.host=mysql-service
    database.port=3306
    redis.host=redis-service
    redis.port=6379
EOF

# Secret 생성
kubectl apply -f - <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: container-demo-secrets
  namespace: $NAMESPACE
type: Opaque
data:
  database-password: $(echo -n "apppassword" | base64)
  redis-password: $(echo -n "" | base64)
  api-key: $(echo -n "your-api-key" | base64)
EOF

log_success "Namespace 및 기본 리소스 생성 완료"

# 2단계: Helm 차트 배포
log_info "2단계: Helm 차트 배포"

# Helm 차트 디렉토리 확인
if [ ! -d "helm-chart-templates" ]; then
    log_error "Helm 차트 템플릿 디렉토리를 찾을 수 없습니다"
    exit 1
fi

# Helm 차트 디렉토리로 이동
cd helm-chart-templates

# 의존성 업데이트
helm dependency update

# Helm 차트 설치
helm upgrade --install container-demo . \
  --namespace $NAMESPACE \
  --create-namespace \
  --set image.repository=gcr.io/$PROJECT_ID/container-demo \
  --set image.tag=$IMAGE_TAG \
  --set mysql.enabled=true \
  --set redis.enabled=true \
  --set monitoring.enabled=true \
  --set security.enabled=true

log_success "Helm 차트 배포 완료"

# 3단계: Istio 설치 및 설정
log_info "3단계: Istio 설치 및 설정"

# Istio 설치 확인
if ! command -v istioctl &> /dev/null; then
    log_warning "Istio CLI가 설치되지 않았습니다. 설치를 진행합니다."
    
    # Istio 다운로드 및 설치
    curl -L https://istio.io/downloadIstio | sh -
    cd istio-1.19.0
    export PATH=$PWD/bin:$PATH
    cd ..
fi

# Istio 설치
istioctl install --set values.defaultRevision=default -y

# Istio Gateway 설정
kubectl apply -f ../istio-config/gateway.yaml

log_success "Istio 설치 및 설정 완료"

# 4단계: 모니터링 설정
log_info "4단계: 모니터링 설정"

# Prometheus 설정
kubectl apply -f ../monitoring-advanced/prometheus-config.yaml

# Grafana 배포
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: grafana
  namespace: $NAMESPACE
spec:
  replicas: 1
  selector:
    matchLabels:
      app: grafana
  template:
    metadata:
      labels:
        app: grafana
    spec:
      containers:
      - name: grafana
        image: grafana/grafana:latest
        ports:
        - containerPort: 3000
        env:
        - name: GF_SECURITY_ADMIN_PASSWORD
          value: "admin123"
        volumeMounts:
        - name: grafana-storage
          mountPath: /var/lib/grafana
      volumes:
      - name: grafana-storage
        emptyDir: {}
---
apiVersion: v1
kind: Service
metadata:
  name: grafana-service
  namespace: $NAMESPACE
spec:
  selector:
    app: grafana
  ports:
  - port: 3000
    targetPort: 3000
  type: ClusterIP
EOF

log_success "모니터링 설정 완료"

# 5단계: 보안 정책 적용
log_info "5단계: 보안 정책 적용"

# Network Policy 적용
kubectl apply -f - <<EOF
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: container-demo-network-policy
  namespace: $NAMESPACE
spec:
  podSelector:
    matchLabels:
      app: container-demo
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          name: istio-system
    - podSelector:
        matchLabels:
          app: container-demo
    ports:
    - protocol: TCP
      port: 3000
  egress:
  - to:
    - podSelector:
        matchLabels:
          app: mysql
    ports:
    - protocol: TCP
      port: 3306
  - to:
    - podSelector:
        matchLabels:
          app: redis
    ports:
    - protocol: TCP
      port: 6379
EOF

log_success "보안 정책 적용 완료"

# 6단계: 배포 상태 확인
log_info "6단계: 배포 상태 확인"

# Pod 상태 확인
kubectl get pods -n $NAMESPACE

# Service 상태 확인
kubectl get services -n $NAMESPACE

# Ingress 상태 확인
kubectl get ingress -n $NAMESPACE

# Helm 릴리스 상태 확인
helm list -n $NAMESPACE

log_success "=== Container 과정 고급 실습 배포 완료 ==="

echo ""
echo "📋 배포된 리소스:"
echo "├── Namespace: $NAMESPACE"
echo "├── Helm Chart: container-demo"
echo "├── Istio Gateway: container-demo-gateway"
echo "├── Prometheus: prometheus-config"
echo "├── Grafana: grafana-service"
echo "└── Network Policy: container-demo-network-policy"
echo ""
echo "🎯 접속 정보:"
echo "├── Grafana: kubectl port-forward svc/grafana-service 3000:3000 -n $NAMESPACE"
echo "├── Prometheus: kubectl port-forward svc/prometheus-service 9090:9090 -n $NAMESPACE"
echo "└── Application: kubectl port-forward svc/container-demo-service 8080:80 -n $NAMESPACE"
echo ""
echo "🔧 다음 단계:"
echo "1. kubectl get pods -n $NAMESPACE 으로 모든 Pod가 Running 상태인지 확인"
echo "2. kubectl logs -f deployment/container-demo -n $NAMESPACE 으로 로그 확인"
echo "3. Grafana에 접속하여 대시보드 설정"
echo "4. Istio Gateway를 통한 트래픽 라우팅 테스트"
