#!/bin/bash

# Container 과정 종합 실습 배포 스크립트
# 자동 복구, 보안 정책, 비용 최적화를 포함한 완전한 운영 환경 구축

set -e

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
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

log_step() {
    echo -e "${PURPLE}[STEP]${NC} $1"
}

# 변수 설정
NAMESPACE="container-demo"
PROJECT_ID=${GCP_PROJECT_ID:-"your-project-id"}
IMAGE_TAG=${IMAGE_TAG:-"latest"}
ENVIRONMENT=${ENVIRONMENT:-"production"}

log_info "=== Container 과정 종합 실습 배포 시작 ==="
log_info "프로젝트 ID: $PROJECT_ID"
log_info "이미지 태그: $IMAGE_TAG"
log_info "환경: $ENVIRONMENT"

# 1단계: Namespace 및 기본 리소스 생성
log_step "1단계: Namespace 및 기본 리소스 생성"
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
    environment=$ENVIRONMENT
    security.mode=strict
    monitoring.enabled=true
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
  jwt-secret: $(echo -n "your-jwt-secret" | base64)
EOF

log_success "Namespace 및 기본 리소스 생성 완료"

# 2단계: 보안 정책 적용
log_step "2단계: 보안 정책 적용"

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
  - to: []
    ports:
    - protocol: TCP
      port: 53
    - protocol: UDP
      port: 53
EOF

# Pod Security Policy 적용
kubectl apply -f - <<EOF
apiVersion: policy/v1beta1
kind: PodSecurityPolicy
metadata:
  name: container-demo-psp
spec:
  privileged: false
  allowPrivilegeEscalation: false
  requiredDropCapabilities:
    - ALL
  volumes:
    - 'configMap'
    - 'emptyDir'
    - 'projected'
    - 'secret'
    - 'downwardAPI'
    - 'persistentVolumeClaim'
  runAsUser:
    rule: 'MustRunAsNonRoot'
  seLinux:
    rule: 'RunAsAny'
  fsGroup:
    rule: 'RunAsAny'
EOF

log_success "보안 정책 적용 완료"

# 3단계: 자동 복구 설정
log_step "3단계: 자동 복구 설정"

# 자동 복구가 적용된 Deployment 생성
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: container-demo
  namespace: $NAMESPACE
  labels:
    app: container-demo
    version: v1.0.0
spec:
  replicas: 3
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0
  selector:
    matchLabels:
      app: container-demo
  template:
    metadata:
      labels:
        app: container-demo
        version: v1.0.0
    spec:
      # 보안 컨텍스트
      securityContext:
        runAsNonRoot: true
        runAsUser: 1000
        runAsGroup: 1000
        fsGroup: 1000
        seccompProfile:
          type: RuntimeDefault
      # Pod 분산 배치
      affinity:
        podAntiAffinity:
          preferredDuringSchedulingIgnoredDuringExecution:
          - weight: 100
            podAffinityTerm:
              labelSelector:
                matchExpressions:
                - key: app
                  operator: In
                  values:
                  - container-demo
              topologyKey: kubernetes.io/hostname
      containers:
      - name: container-demo
        image: gcr.io/$PROJECT_ID/container-demo:$IMAGE_TAG
        ports:
        - containerPort: 3000
        # 보안 컨텍스트
        securityContext:
          allowPrivilegeEscalation: false
          readOnlyRootFilesystem: true
          runAsNonRoot: true
          runAsUser: 1000
          capabilities:
            drop:
            - ALL
        # 환경 변수
        env:
        - name: NODE_ENV
          value: "production"
        - name: SECURITY_MODE
          value: "strict"
        - name: MONITORING_ENABLED
          value: "true"
        - name: DATABASE_PASSWORD
          valueFrom:
            secretKeyRef:
              name: container-demo-secrets
              key: database-password
        - name: API_KEY
          valueFrom:
            secretKeyRef:
              name: container-demo-secrets
              key: api-key
        # 리소스 제한
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "512Mi"
            cpu: "500m"
        # 헬스체크
        livenessProbe:
          httpGet:
            path: /health
            port: 3000
          initialDelaySeconds: 30
          periodSeconds: 10
          timeoutSeconds: 5
          failureThreshold: 3
        readinessProbe:
          httpGet:
            path: /ready
            port: 3000
          initialDelaySeconds: 5
          periodSeconds: 5
          timeoutSeconds: 3
          failureThreshold: 3
        startupProbe:
          httpGet:
            path: /startup
            port: 3000
          initialDelaySeconds: 10
          periodSeconds: 5
          timeoutSeconds: 3
          failureThreshold: 30
        # 볼륨 마운트
        volumeMounts:
        - name: tmp-volume
          mountPath: /tmp
        - name: cache-volume
          mountPath: /app/cache
        - name: config-volume
          mountPath: /app/config
          readOnly: true
      volumes:
      - name: tmp-volume
        emptyDir: {}
      - name: cache-volume
        emptyDir: {}
      - name: config-volume
        configMap:
          name: container-demo-config
EOF

log_success "자동 복구 설정 완료"

# 4단계: 자동 스케일링 설정
log_step "4단계: 자동 스케일링 설정"

# HPA 설정
kubectl apply -f - <<EOF
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: container-demo-hpa
  namespace: $NAMESPACE
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: container-demo
  minReplicas: 2
  maxReplicas: 20
  behavior:
    scaleDown:
      stabilizationWindowSeconds: 300
      policies:
      - type: Percent
        value: 10
        periodSeconds: 60
    scaleUp:
      stabilizationWindowSeconds: 60
      policies:
      - type: Percent
        value: 50
        periodSeconds: 60
      - type: Pods
        value: 2
        periodSeconds: 60
      selectPolicy: Max
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

# VPA 설정
kubectl apply -f - <<EOF
apiVersion: autoscaling.k8s.io/v1
kind: VerticalPodAutoscaler
metadata:
  name: container-demo-vpa
  namespace: $NAMESPACE
spec:
  targetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: container-demo
  updatePolicy:
    updateMode: "Auto"
  resourcePolicy:
    containerPolicies:
    - containerName: container-demo
      minAllowed:
        cpu: 100m
        memory: 128Mi
      maxAllowed:
        cpu: 1000m
        memory: 1Gi
      controlledResources: ["cpu", "memory"]
      controlledValues: RequestsAndLimits
EOF

log_success "자동 스케일링 설정 완료"

# 5단계: 서비스 및 Ingress 설정
log_step "5단계: 서비스 및 Ingress 설정"

# Service 생성
kubectl apply -f - <<EOF
apiVersion: v1
kind: Service
metadata:
  name: container-demo-service
  namespace: $NAMESPACE
  labels:
    app: container-demo
spec:
  selector:
    app: container-demo
  ports:
  - protocol: TCP
    port: 80
    targetPort: 3000
  type: ClusterIP
EOF

# Ingress 생성
kubectl apply -f - <<EOF
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: container-demo-ingress
  namespace: $NAMESPACE
  annotations:
    kubernetes.io/ingress.class: "gce"
    nginx.ingress.kubernetes.io/rewrite-target: /
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
spec:
  rules:
  - host: container-demo.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: container-demo-service
            port:
              number: 80
EOF

log_success "서비스 및 Ingress 설정 완료"

# 6단계: 모니터링 설정
log_step "6단계: 모니터링 설정"

# Prometheus 설정
kubectl apply -f - <<EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: prometheus-config
  namespace: $NAMESPACE
data:
  prometheus.yml: |
    global:
      scrape_interval: 15s
      evaluation_interval: 15s
    scrape_configs:
    - job_name: 'container-demo'
      static_configs:
      - targets: ['container-demo-service:80']
      metrics_path: /metrics
      scrape_interval: 5s
    - job_name: 'kubernetes-pods'
      kubernetes_sd_configs:
      - role: pod
      relabel_configs:
      - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_scrape]
        action: keep
        regex: true
EOF

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

# 7단계: 비용 최적화 설정
log_step "7단계: 비용 최적화 설정"

# 비용 분석 대시보드 생성
kubectl apply -f - <<EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: cost-analysis-dashboard
  namespace: $NAMESPACE
data:
  cost-analysis.json: |
    {
      "dashboard": {
        "title": "Cost Analysis Dashboard",
        "panels": [
          {
            "title": "Resource Utilization",
            "type": "graph",
            "targets": [
              {
                "expr": "rate(container_cpu_usage_seconds_total[5m])",
                "legendFormat": "CPU Usage"
              },
              {
                "expr": "container_memory_usage_bytes",
                "legendFormat": "Memory Usage"
              }
            ]
          },
          {
            "title": "Pod Count",
            "type": "graph",
            "targets": [
              {
                "expr": "kube_deployment_status_replicas",
                "legendFormat": "Replicas"
              }
            ]
          }
        ]
      }
    }
EOF

log_success "비용 최적화 설정 완료"

# 8단계: 배포 상태 확인
log_step "8단계: 배포 상태 확인"

# Pod 상태 확인
log_info "Pod 상태 확인:"
kubectl get pods -n $NAMESPACE

# Service 상태 확인
log_info "Service 상태 확인:"
kubectl get services -n $NAMESPACE

# Ingress 상태 확인
log_info "Ingress 상태 확인:"
kubectl get ingress -n $NAMESPACE

# HPA 상태 확인
log_info "HPA 상태 확인:"
kubectl get hpa -n $NAMESPACE

# VPA 상태 확인
log_info "VPA 상태 확인:"
kubectl get vpa -n $NAMESPACE

log_success "=== Container 과정 종합 실습 배포 완료 ==="

echo ""
echo "📋 배포된 리소스:"
echo "├── Namespace: $NAMESPACE"
echo "├── Deployment: container-demo (3 replicas)"
echo "├── Service: container-demo-service"
echo "├── Ingress: container-demo-ingress"
echo "├── HPA: container-demo-hpa (2-20 replicas)"
echo "├── VPA: container-demo-vpa"
echo "├── Network Policy: container-demo-network-policy"
echo "├── Pod Security Policy: container-demo-psp"
echo "├── Prometheus: prometheus-config"
echo "└── Grafana: grafana-service"
echo ""
echo "🎯 접속 정보:"
echo "├── Application: kubectl port-forward svc/container-demo-service 8080:80 -n $NAMESPACE"
echo "├── Grafana: kubectl port-forward svc/grafana-service 3000:3000 -n $NAMESPACE"
echo "└── Prometheus: kubectl port-forward svc/prometheus-service 9090:9090 -n $NAMESPACE"
echo ""
echo "🔧 다음 단계:"
echo "1. kubectl get pods -n $NAMESPACE 으로 모든 Pod가 Running 상태인지 확인"
echo "2. kubectl logs -f deployment/container-demo -n $NAMESPACE 으로 로그 확인"
echo "3. Grafana에 접속하여 대시보드 설정 (admin/admin123)"
echo "4. HPA 동작 테스트를 위한 부하 생성"
echo "5. 보안 정책 테스트 및 네트워크 격리 확인"
echo ""
echo "🧪 실습 시나리오:"
echo "1. Pod 장애 시뮬레이션: kubectl delete pod -l app=container-demo -n $NAMESPACE"
echo "2. 부하 테스트: kubectl run -i --tty load-generator --rm --image=busybox --restart=Never -- /bin/sh"
echo "3. 보안 테스트: kubectl run -i --tty test-pod --rm --image=busybox --restart=Never -- /bin/sh"
echo ""
echo "📊 모니터링:"
echo "1. kubectl top pods -n $NAMESPACE 으로 리소스 사용량 확인"
echo "2. kubectl get hpa -n $NAMESPACE -w 으로 HPA 동작 확인"
echo "3. Grafana 대시보드에서 메트릭 확인"
echo ""
echo "🎉 Container 과정 종합 실습 환경이 성공적으로 구축되었습니다!"
