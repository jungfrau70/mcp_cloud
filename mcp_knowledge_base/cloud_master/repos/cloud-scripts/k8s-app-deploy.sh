#!/bin/bash

# Kubernetes 애플리케이션 자동 배포 스크립트
# Cloud Master Day2용 - Kubernetes & 고급 CI/CD

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

# 설정 변수
APP_NAME="cloud-master-app"
NAMESPACE="development"
IMAGE_NAME="cloud-master-app"
IMAGE_TAG="latest"
REPLICAS=3
PORT=3000
TARGET_PORT=3000

# 체크포인트 파일
CHECKPOINT_FILE="k8s-app-deploy-checkpoint.json"

# 체크포인트 로드
load_checkpoint() {
    if [ -f "$CHECKPOINT_FILE" ]; then
        log_info "체크포인트 파일 로드 중..."
        source "$CHECKPOINT_FILE"
    fi
}

# 체크포인트 저장
save_checkpoint() {
    log_info "체크포인트 저장 중..."
    cat > "$CHECKPOINT_FILE" << EOF
DEPLOYMENT_CREATED=$DEPLOYMENT_CREATED
SERVICE_CREATED=$SERVICE_CREATED
INGRESS_CREATED=$INGRESS_CREATED
HPA_CREATED=$HPA_CREATED
EOF
}

# 환경 체크
check_environment() {
    log_info "환경 체크 중..."
    
    # kubectl 체크
    if ! command -v kubectl &> /dev/null; then
        log_error "kubectl이 설치되지 않았습니다."
        exit 1
    fi
    
    # 클러스터 연결 체크
    if ! kubectl cluster-info &> /dev/null; then
        log_error "Kubernetes 클러스터에 연결되지 않았습니다."
        log_info "k8s-cluster-create.sh를 먼저 실행하세요."
        exit 1
    fi
    
    # Docker 체크
    if ! command -v docker &> /dev/null; then
        log_warning "Docker가 설치되지 않았습니다."
    fi
    
    log_success "환경 체크 완료"
}

# Docker 이미지 빌드
build_docker_image() {
    log_info "Docker 이미지 빌드 중..."
    
    # Dockerfile이 있는지 확인
    if [ ! -f "Dockerfile" ]; then
        log_warning "Dockerfile이 없습니다. 기본 Dockerfile을 생성합니다."
        create_default_dockerfile
    fi
    
    # Docker 이미지 빌드
    docker build -t "$IMAGE_NAME:$IMAGE_TAG" .
    
    if [ $? -eq 0 ]; then
        log_success "Docker 이미지 빌드 완료: $IMAGE_NAME:$IMAGE_TAG"
    else
        log_error "Docker 이미지 빌드 실패"
        exit 1
    fi
}

# 기본 Dockerfile 생성
create_default_dockerfile() {
    cat > Dockerfile << EOF
FROM node:18-alpine

WORKDIR /app

COPY package*.json ./
RUN npm ci --only=production

COPY . .

EXPOSE $PORT

CMD ["node", "app.js"]
EOF
    
    # 기본 package.json 생성
    if [ ! -f "package.json" ]; then
        cat > package.json << EOF
{
  "name": "$APP_NAME",
  "version": "1.0.0",
  "description": "Cloud Master App",
  "main": "app.js",
  "scripts": {
    "start": "node app.js"
  },
  "dependencies": {
    "express": "^4.18.2"
  }
}
EOF
    fi
    
    # 기본 app.js 생성
    if [ ! -f "app.js" ]; then
        cat > app.js << EOF
const express = require('express');
const app = express();
const port = process.env.PORT || $PORT;

app.get('/', (req, res) => {
  res.json({
    message: 'Hello from Cloud Master App!',
    timestamp: new Date().toISOString(),
    pod: process.env.HOSTNAME || 'unknown'
  });
});

app.get('/health', (req, res) => {
  res.json({ status: 'healthy' });
});

app.listen(port, '0.0.0.0', () => {
  console.log(\`App running on port \${port}\`);
});
EOF
    fi
}

# 네임스페이스 생성
create_namespace() {
    log_info "네임스페이스 생성 중..."
    
    kubectl create namespace "$NAMESPACE" --dry-run=client -o yaml | kubectl apply -f -
    
    log_success "네임스페이스 생성 완료: $NAMESPACE"
}

# ConfigMap 생성
create_configmap() {
    log_info "ConfigMap 생성 중..."
    
    cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: $APP_NAME-config
  namespace: $NAMESPACE
data:
  NODE_ENV: "production"
  PORT: "$PORT"
  LOG_LEVEL: "info"
EOF
    
    log_success "ConfigMap 생성 완료"
}

# Secret 생성
create_secret() {
    log_info "Secret 생성 중..."
    
    cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: $APP_NAME-secret
  namespace: $NAMESPACE
type: Opaque
data:
  api-key: $(echo -n "your-api-key-here" | base64)
  db-password: $(echo -n "your-db-password-here" | base64)
EOF
    
    log_success "Secret 생성 완료"
}

# Deployment 생성
create_deployment() {
    if [ "$DEPLOYMENT_CREATED" = "true" ]; then
        log_info "Deployment가 이미 생성되어 있습니다."
        return 0
    fi
    
    log_info "Deployment 생성 중..."
    
    cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: $APP_NAME
  namespace: $NAMESPACE
  labels:
    app: $APP_NAME
spec:
  replicas: $REPLICAS
  selector:
    matchLabels:
      app: $APP_NAME
  template:
    metadata:
      labels:
        app: $APP_NAME
    spec:
      containers:
      - name: $APP_NAME
        image: $IMAGE_NAME:$IMAGE_TAG
        ports:
        - containerPort: $TARGET_PORT
        env:
        - name: NODE_ENV
          valueFrom:
            configMapKeyRef:
              name: $APP_NAME-config
              key: NODE_ENV
        - name: PORT
          valueFrom:
            configMapKeyRef:
              name: $APP_NAME-config
              key: PORT
        - name: API_KEY
          valueFrom:
            secretKeyRef:
              name: $APP_NAME-secret
              key: api-key
        resources:
          requests:
            memory: "128Mi"
            cpu: "100m"
          limits:
            memory: "256Mi"
            cpu: "200m"
        livenessProbe:
          httpGet:
            path: /health
            port: $TARGET_PORT
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /health
            port: $TARGET_PORT
          initialDelaySeconds: 5
          periodSeconds: 5
EOF
    
    if [ $? -eq 0 ]; then
        DEPLOYMENT_CREATED="true"
        log_success "Deployment 생성 완료"
    else
        log_error "Deployment 생성 실패"
        exit 1
    fi
}

# Service 생성
create_service() {
    if [ "$SERVICE_CREATED" = "true" ]; then
        log_info "Service가 이미 생성되어 있습니다."
        return 0
    fi
    
    log_info "Service 생성 중..."
    
    cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Service
metadata:
  name: $APP_NAME-service
  namespace: $NAMESPACE
  labels:
    app: $APP_NAME
spec:
  selector:
    app: $APP_NAME
  ports:
  - port: $PORT
    targetPort: $TARGET_PORT
    protocol: TCP
  type: ClusterIP
EOF
    
    if [ $? -eq 0 ]; then
        SERVICE_CREATED="true"
        log_success "Service 생성 완료"
    else
        log_error "Service 생성 실패"
        exit 1
    fi
}

# Ingress 생성
create_ingress() {
    if [ "$INGRESS_CREATED" = "true" ]; then
        log_info "Ingress가 이미 생성되어 있습니다."
        return 0
    fi
    
    log_info "Ingress 생성 중..."
    
    cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: $APP_NAME-ingress
  namespace: $NAMESPACE
  annotations:
    kubernetes.io/ingress.class: "gce"
    kubernetes.io/ingress.global-static-ip-name: "$APP_NAME-ip"
spec:
  rules:
  - host: $APP_NAME.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: $APP_NAME-service
            port:
              number: $PORT
EOF
    
    if [ $? -eq 0 ]; then
        INGRESS_CREATED="true"
        log_success "Ingress 생성 완료"
    else
        log_warning "Ingress 생성 실패 (선택사항)"
    fi
}

# HorizontalPodAutoscaler 생성
create_hpa() {
    if [ "$HPA_CREATED" = "true" ]; then
        log_info "HPA가 이미 생성되어 있습니다."
        return 0
    fi
    
    log_info "HorizontalPodAutoscaler 생성 중..."
    
    cat <<EOF | kubectl apply -f -
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: $APP_NAME-hpa
  namespace: $NAMESPACE
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: $APP_NAME
  minReplicas: 1
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: 80
EOF
    
    if [ $? -eq 0 ]; then
        HPA_CREATED="true"
        log_success "HorizontalPodAutoscaler 생성 완료"
    else
        log_warning "HPA 생성 실패 (선택사항)"
    fi
}

# 배포 상태 확인
check_deployment_status() {
    log_info "배포 상태 확인 중..."
    
    # Deployment 상태 확인
    log_info "Deployment 상태:"
    kubectl get deployment "$APP_NAME" -n "$NAMESPACE" -o wide
    
    # Pod 상태 확인
    log_info "Pod 상태:"
    kubectl get pods -l app="$APP_NAME" -n "$NAMESPACE" -o wide
    
    # Service 상태 확인
    log_info "Service 상태:"
    kubectl get service "$APP_NAME-service" -n "$NAMESPACE" -o wide
    
    # HPA 상태 확인
    if [ "$HPA_CREATED" = "true" ]; then
        log_info "HPA 상태:"
        kubectl get hpa "$APP_NAME-hpa" -n "$NAMESPACE"
    fi
    
    # 로그 확인
    log_info "애플리케이션 로그:"
    kubectl logs -l app="$APP_NAME" -n "$NAMESPACE" --tail=10
}

# 포트 포워딩 설정
setup_port_forward() {
    log_info "포트 포워딩 설정 중..."
    
    # 백그라운드에서 포트 포워딩 시작
    kubectl port-forward service/"$APP_NAME-service" 8080:$PORT -n "$NAMESPACE" &
    PORT_FORWARD_PID=$!
    
    log_success "포트 포워딩 설정 완료"
    log_info "애플리케이션 접속: http://localhost:8080"
    log_info "포트 포워딩 중지: kill $PORT_FORWARD_PID"
}

# 정리 함수
cleanup() {
    log_info "정리 중..."
    
    # 포트 포워딩 중지
    if [ ! -z "$PORT_FORWARD_PID" ]; then
        kill $PORT_FORWARD_PID 2>/dev/null
    fi
    
    # 체크포인트 파일 삭제
    rm -f "$CHECKPOINT_FILE"
    
    log_success "정리 완료"
}

# 메인 함수
main() {
    log_info "=== Cloud Master Day2 - Kubernetes 애플리케이션 배포 시작 ==="
    
    # 체크포인트 로드
    load_checkpoint
    
    # 환경 체크
    check_environment
    
    # Docker 이미지 빌드
    build_docker_image
    
    # 네임스페이스 생성
    create_namespace
    
    # ConfigMap 생성
    create_configmap
    
    # Secret 생성
    create_secret
    
    # Deployment 생성
    create_deployment
    save_checkpoint
    
    # Service 생성
    create_service
    save_checkpoint
    
    # Ingress 생성
    create_ingress
    save_checkpoint
    
    # HPA 생성
    create_hpa
    save_checkpoint
    
    # 배포 상태 확인
    check_deployment_status
    
    # 포트 포워딩 설정
    setup_port_forward
    
    log_success "=== Kubernetes 애플리케이션 배포 완료 ==="
    log_info "애플리케이션 이름: $APP_NAME"
    log_info "네임스페이스: $NAMESPACE"
    log_info "이미지: $IMAGE_NAME:$IMAGE_TAG"
    log_info "레플리카 수: $REPLICAS"
    
    log_info "다음 단계:"
    log_info "1. kubectl get pods -n $NAMESPACE - Pod 상태 확인"
    log_info "2. kubectl logs -l app=$APP_NAME -n $NAMESPACE - 로그 확인"
    log_info "3. http://localhost:8080 - 애플리케이션 접속"
}

# 스크립트 실행
if [ "${BASH_SOURCE[0]}" == "${0}" ]; then
    main "$@"
fi
