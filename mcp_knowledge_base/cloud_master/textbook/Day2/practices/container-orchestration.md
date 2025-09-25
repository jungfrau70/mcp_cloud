# 컨테이너 오케스트레이션 실습 가이드

## 🎯 학습 목표

### 핵심 학습 목표
- **Kubernetes 고급** 고가용성 및 확장성 아키텍처
- **Helm 차트** 패키지 관리 및 배포 자동화
- **서비스 메시** Istio를 이용한 마이크로서비스 관리
- **모니터링** Prometheus, Grafana를 이용한 클러스터 모니터링

### 실습 후 달성할 수 있는 능력
- ✅ Kubernetes 고급 리소스 관리 및 배포
- ✅ Helm을 이용한 애플리케이션 패키징 및 배포
- ✅ 서비스 메시를 통한 마이크로서비스 관리
- ✅ 클러스터 모니터링 및 로그 관리

### 예상 소요 시간
- **Kubernetes 고급**: 120-150분
- **Helm 차트**: 90-120분
- **서비스 메시**: 120-150분
- **모니터링**: 90-120분
- **전체 과정**: 7-9시간

---

## 🛠️ 실습 학습

### 📁 실습 코드 및 자동화
- **실습 샘플 코드**: `/mcp_knowledge_base/cloud_master/repos/samples/day2/my-app/`
- **자동화 스크립트**: `/mcp_knowledge_base/cloud_master/repos/automation/day2/container_orchestration.sh`
- **클라우드 스크립트**: `/mcp_knowledge_base/cloud_master/repos/cloud-scripts/`

<details>
<summary>🚀 실습 환경 준비</summary>

#### 필수 도구
- **kubectl**: 1.24 이상
- **Helm**: 3.8 이상
- **Istio**: 1.15 이상
- **Minikube**: 1.28 이상

#### 환경 설정
```bash
# kubectl 설치 확인
kubectl version --client

# Helm 설치 확인
helm version

# Istio 설치 확인
istioctl version

# Minikube 설치 확인
minikube version
```

</details>

<details>
<summary>🔧 1단계: Kubernetes 고급 리소스</summary>

#### 고가용성 Deployment
```yaml
# high-availability-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-app
  labels:
    app: web-app
spec:
  replicas: 3
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 1
      maxSurge: 1
  selector:
    matchLabels:
      app: web-app
  template:
    metadata:
      labels:
        app: web-app
    spec:
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
                  - web-app
              topologyKey: kubernetes.io/hostname
      containers:
      - name: web-app
        image: nginx:1.21
        ports:
        - containerPort: 80
        resources:
          requests:
            memory: "64Mi"
            cpu: "250m"
          limits:
            memory: "128Mi"
            cpu: "500m"
        livenessProbe:
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 5
          periodSeconds: 5
```

#### Horizontal Pod Autoscaler
```yaml
# hpa.yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: web-app-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: web-app
  minReplicas: 2
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
```

#### ConfigMap과 Secret
```yaml
# configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
data:
  database.host: "postgres-service"
  database.port: "5432"
  redis.host: "redis-service"
  redis.port: "6379"
  app.environment: "production"

---
# secret.yaml
apiVersion: v1
kind: Secret
metadata:
  name: app-secrets
type: Opaque
data:
  database.password: cG9zdGdyZXM=  # base64 encoded
  api.key: YWJjZGVmZ2g=           # base64 encoded
```

</details>

<details>
<summary>🔧 2단계: Helm 차트 개발</summary>

#### Helm 차트 생성
```bash
# Helm 차트 생성
helm create my-app-chart

# 차트 구조 확인
tree my-app-chart/
```

#### Chart.yaml
```yaml
# my-app-chart/Chart.yaml
apiVersion: v2
name: my-app-chart
description: A Helm chart for My Application
type: application
version: 0.1.0
appVersion: "1.0.0"
dependencies:
- name: postgresql
  version: "11.6.12"
  repository: "https:///charts.bitnami.com/bitnami"
- name: redis
  version: "16.8.5"
  repository: "https:///charts.bitnami.com/bitnami"
```

#### values.yaml
```yaml
# my-app-chart/values.yaml
replicaCount: 3

image:
  repository: nginx
  pullPolicy: IfNotPresent
  tag: "1.21"

service:
  type: ClusterIP
  port: 80

ingress:
  enabled: true
  className: ""
  annotations: {}
  hosts:
    - host: my-app.local
      paths:
        - path: /
          pathType: Prefix
  tls: []

resources:
  limits:
    cpu: 500m
    memory: 128Mi
  requests:
    cpu: 250m
    memory: 64Mi

autoscaling:
  enabled: true
  minReplicas: 2
  maxReplicas: 10
  targetCPUUtilizationPercentage: 70
  targetMemoryUtilizationPercentage: 80

postgresql:
  enabled: true
  auth:
    postgresPassword: "postgres"
    database: "myapp"

redis:
  enabled: true
  auth:
    enabled: false
```

#### templates/deployment.yaml
```yaml
# my-app-chart/templates/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "my-app-chart.fullname" . }}
  labels:
    {{- include "my-app-chart.labels" . | nindent 4 }}
spec:
  {{- if not .Values.autoscaling.enabled }}
  replicas: {{ .Values.replicaCount }}
  {{- end }}
  selector:
    matchLabels:
      {{- include "my-app-chart.selectorLabels" . | nindent 6 }}
  template:
    metadata:
      labels:
        {{- include "my-app-chart.selectorLabels" . | nindent 8 }}
    spec:
      containers:
        - name: {{ .Chart.Name }}
          image: "{{ .Values.image.repository }}:{{ .Values.image.tag | default .Chart.AppVersion }}"
          imagePullPolicy: {{ .Values.image.pullPolicy }}
          ports:
            - name: http
              containerPort: {{ .Values.service.port }}
              protocol: TCP
          resources:
            {{- toYaml .Values.resources | nindent 12 }}
          env:
            - name: DATABASE_HOST
              value: {{ .Values.postgresql.auth.database }}
            - name: DATABASE_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: {{ include "my-app-chart.fullname" . }}-postgresql
                  key: postgres-password
```

#### Helm 배포
```bash
# 의존성 설치
helm dependency update my-app-chart

# 차트 설치
helm install my-app my-app-chart

# 차트 업그레이드
helm upgrade my-app my-app-chart --set replicaCount=5

# 차트 삭제
helm uninstall my-app
```

</details>

<details>
<summary>🔧 3단계: 서비스 메시 [Istio]</summary>

#### Istio 설치
```bash
# Istio 설치
curl -L https:///istio.io/downloadIstio | sh -
cd istio-*
export PATH=$PWD/bin:$PATH

# Istio 설치
istioctl install --set values.defaultRevision=default

# 네임스페이스에 사이드카 자동 주입 활성화
kubectl label namespace default istio-injection=enabled
```

#### Gateway와 VirtualService
```yaml
# gateway.yaml
apiVersion: networking.istio.io/v1alpha3
kind: Gateway
metadata:
  name: my-app-gateway
spec:
  selector:
    istio: ingressgateway
  servers:
  - port:
      number: 80
      name: http
      protocol: HTTP
    hosts:
    - "*"

---
# virtualservice.yaml
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: my-app-vs
spec:
  hosts:
  - "*"
  gateways:
  - my-app-gateway
  http:
  - match:
    - uri:
        prefix: /
    route:
    - destination:
        host: my-app-service
        port:
          number: 80
    fault:
      delay:
        percentage:
          value: 0.1
        fixedDelay: 5s
```

#### DestinationRule
```yaml
# destinationrule.yaml
apiVersion: networking.istio.io/v1alpha3
kind: DestinationRule
metadata:
  name: my-app-dr
spec:
  host: my-app-service
  trafficPolicy:
    loadBalancer:
      simple: LEAST_CONN
    connectionPool:
      tcp:
        maxConnections: 10
      http:
        http1MaxPendingRequests: 10
        maxRequestsPerConnection: 2
    circuitBreaker:
      consecutiveErrors: 3
      interval: 30s
      baseEjectionTime: 30s
```

#### 모니터링 설정
```yaml
# telemetry.yaml
apiVersion: telemetry.istio.io/v1alpha1
kind: Telemetry
metadata:
  name: default
  namespace: istio-system
spec:
  metrics:
  - providers:
    - name: prometheus
  accessLogging:
  - providers:
    - name: prometheus
```

</details>

<details>
<summary>🔧 4단계: 클러스터 모니터링</summary>

#### Prometheus Operator 설치
```bash
# Prometheus Operator 설치
helm repo add prometheus-community https:///prometheus-community.github.io/helm-charts
helm repo update

# Prometheus 스택 설치
helm install prometheus prometheus-community/kube-prometheus-stack /
  --namespace monitoring /
  --create-namespace /
  --set grafana.adminPassword=admin
```

#### ServiceMonitor 생성
```yaml
# servicemonitor.yaml
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: my-app-monitor
  namespace: monitoring
  labels:
    app: my-app
spec:
  selector:
    matchLabels:
      app: my-app
  endpoints:
  - port: http
    interval: 30s
    path: /metrics
```

#### Grafana 대시보드
```yaml
# grafana-dashboard.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: my-app-dashboard
  namespace: monitoring
  labels:
    grafana_dashboard: "1"
data:
  dashboard.json: |
    {
      "dashboard": {
        "title": "My App Dashboard",
        "panels": [
          {
            "title": "Request Rate",
            "type": "graph",
            "targets": [
              {
                "expr": "rate[http_requests_total[5m]]",
                "legendFormat": "{{instance}}"
              }
            ]
          },
          {
            "title": "Error Rate",
            "type": "graph",
            "targets": [
              {
                "expr": "rate[http_requests_total{status=~/"5../"}[5m]]",
                "legendFormat": "{{instance}}"
              }
            ]
          }
        ]
      }
    }
```

#### AlertManager 규칙
```yaml
# alertmanager-rules.yaml
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: my-app-alerts
  namespace: monitoring
spec:
  groups:
  - name: my-app
    rules:
    - alert: HighErrorRate
      expr: rate[http_requests_total{status=~"5.."}[5m]] > 0.1
      for: 5m
      labels:
        severity: warning
      annotations:
        summary: "High error rate detected"
        description: "Error rate is {{ $value }} errors per second"
    
    - alert: PodCrashLooping
      expr: rate[kube_pod_container_status_restarts_total[15m]] > 0
      for: 5m
      labels:
        severity: critical
      annotations:
        summary: "Pod is crash looping"
        description: "Pod {{ $labels.pod }} is restarting frequently"
```

</details>

---

## 📚 참고 자료

### 유용한 명령어
```bash
# Kubernetes 관리
kubectl get pods -o wide                    # Pod 상세 정보
kubectl describe pod <pod-name>             # Pod 상세 설명
kubectl logs -f <pod-name>                  # Pod 로그 실시간 확인
kubectl exec -it <pod-name> -- /bin/bash    # Pod 내부 접속

# Helm 관리
helm list                                   # 설치된 차트 목록
helm status <release-name>                  # 차트 상태 확인
helm history <release-name>                 # 차트 히스토리
helm rollback <release-name> <revision>     # 차트 롤백

# Istio 관리
istioctl proxy-status                       # 사이드카 상태 확인
istioctl analyze                            # 설정 분석
istioctl dashboard prometheus               # Prometheus 대시보드 열기
```

### 문제 해결
1. **Pod 시작 실패**
   - 이벤트 로그 확인: `kubectl describe pod <pod-name>`
   - 이미지 풀 정책 확인
   - 리소스 제한 확인

2. **서비스 연결 실패**
   - 서비스 엔드포인트 확인: `kubectl get endpoints`
   - 네트워크 정책 확인
   - DNS 해석 확인

---

## 🧹 실습 정리

### 자동 정리
```bash
# Day2 컨테이너 오케스트레이션 실습 자동 정리
./mcp_knowledge_base/cloud_master/repos/automation/day2/container_orchestration.sh --cleanup
```

### 수동 정리
```bash
# Helm 차트 정리
helm uninstall my-app

# Istio 정리
istioctl uninstall --purge

# Prometheus 스택 정리
helm uninstall prometheus -n monitoring

# Minikube 정리
minikube delete
```

### 정리 확인
- [ ] 모든 Helm 차트 삭제
- [ ] Istio 컴포넌트 정리
- [ ] 모니터링 스택 정리
- [ ] 클러스터 리소스 정리
