# Kubernetes 심화 실습 가이드

<div align="center">

[← 이전: Cloud Container 메인](../README.md) | [📚 전체 커리큘럼](/curriculum.md) | [🏠 학습 경로로 돌아가기](/index.md) | [📋 학습 경로](../../../../learning-path.md)

</div>

<div align="center">

[← 이전: Cloud Container 1일차 메인](../README.md) | [📚 전체 커리큘럼](/curriculum.md) | [🏠 학습 경로로 돌아가기](/index.md) | [📋 학습 경로](../../../../learning-path.md)

</div>

## 🎯 학습 목표

이 가이드를 통해 다음을 학습합니다:
- Kubernetes 고급 개념 및 아키텍처
- Helm 차트를 활용한 애플리케이션 배포
- Istio 서비스 메시 구성
- 고급 모니터링 및 로깅
- 보안 정책 및 네트워크 정책

---

## 📋 목차

1. [Kubernetes 고급 개념](#kubernetes-고급-개념)
2. [Helm 차트 작성 및 배포](#helm-차트-작성-및-배포)
3. [Istio 서비스 메시 구성](#istio-서비스-메시-구성)
4. [고급 모니터링 설정](#고급-모니터링-설정)
5. [보안 정책 적용](#보안-정책-적용)
6. [실습 프로젝트](#실습-프로젝트)

---

## 🎼 Kubernetes 고급 개념

### Namespace 및 리소스 관리

#### Namespace 생성 및 관리
```yaml
# namespace.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: container-demo
  labels:
    name: container-demo
    environment: production
---
apiVersion: v1
kind: ResourceQuota
metadata:
  name: container-demo-quota
  namespace: container-demo
spec:
  hard:
    requests.cpu: "2"
    requests.memory: 4Gi
    limits.cpu: "4"
    limits.memory: 8Gi
    persistentvolumeclaims: "10"
```

#### ConfigMap 및 Secret 관리
```yaml
# configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: container-demo-config
  namespace: container-demo
data:
  app.properties: |
    server.port=3000
    logging.level=INFO
    database.host=mysql-service
    database.port=3306
---
apiVersion: v1
kind: Secret
metadata:
  name: container-demo-secrets
  namespace: container-demo
type: Opaque
data:
  database-password: <base64-encoded-password>
  api-key: <base64-encoded-api-key>
```

### 고급 배포 전략

#### Rolling Update 설정
```yaml
# deployment-advanced.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: container-demo-deployment
  namespace: container-demo
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
      containers:
      - name: container-demo
        image: gcr.io/PROJECT_ID/container-demo:latest
        ports:
        - containerPort: 3000
        env:
        - name: NODE_ENV
          value: "production"
        - name: DATABASE_PASSWORD
          valueFrom:
            secretKeyRef:
              name: container-demo-secrets
              key: database-password
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "512Mi"
            cpu: "500m"
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
        volumeMounts:
        - name: config-volume
          mountPath: /app/config
      volumes:
      - name: config-volume
        configMap:
          name: container-demo-config
```

#### Blue-Green 배포
```yaml
# blue-green-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: container-demo-blue
  namespace: container-demo
spec:
  replicas: 3
  selector:
    matchLabels:
      app: container-demo
      version: blue
  template:
    metadata:
      labels:
        app: container-demo
        version: blue
    spec:
      containers:
      - name: container-demo
        image: gcr.io/PROJECT_ID/container-demo:v1.0.0
        ports:
        - containerPort: 3000
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: container-demo-green
  namespace: container-demo
spec:
  replicas: 3
  selector:
    matchLabels:
      app: container-demo
      version: green
  template:
    metadata:
      labels:
        app: container-demo
        version: green
    spec:
      containers:
      - name: container-demo
        image: gcr.io/PROJECT_ID/container-demo:v1.1.0
        ports:
        - containerPort: 3000
```

### 서비스 메시 및 네트워킹

#### Ingress 설정
```yaml
# ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: container-demo-ingress
  namespace: container-demo
  annotations:
    kubernetes.io/ingress.class: "gce"
    nginx.ingress.kubernetes.io/rewrite-target: /
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
spec:
  tls:
  - hosts:
    - container-demo.example.com
    secretName: container-demo-tls
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
```

#### Network Policy
```yaml
# network-policy.yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: container-demo-network-policy
  namespace: container-demo
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
```

---

## 🎯 Helm 차트 작성 및 배포

### Helm 차트 구조 생성

#### Chart.yaml
```yaml
# Chart.yaml
apiVersion: v2
name: container-demo
description: A Helm chart for Container Demo application
type: application
version: 0.1.0
appVersion: "1.0.0"
dependencies:
- name: mysql
  version: 8.8.0
  repository: https://charts.bitnami.com/bitnami
  condition: mysql.enabled
```

#### values.yaml
```yaml
# values.yaml
replicaCount: 3

image:
  repository: gcr.io/PROJECT_ID/container-demo
  pullPolicy: IfNotPresent
  tag: "latest"

service:
  type: ClusterIP
  port: 80
  targetPort: 3000

ingress:
  enabled: true
  className: "gce"
  annotations:
    kubernetes.io/ingress.class: "gce"
  hosts:
    - host: container-demo.example.com
      paths:
        - path: /
          pathType: Prefix
  tls: []

resources:
  limits:
    cpu: 500m
    memory: 512Mi
  requests:
    cpu: 250m
    memory: 256Mi

autoscaling:
  enabled: true
  minReplicas: 1
  maxReplicas: 10
  targetCPUUtilizationPercentage: 70

mysql:
  enabled: true
  auth:
    rootPassword: "rootpassword"
    database: "container_demo"
    username: "appuser"
    password: "apppassword"
  primary:
    persistence:
      enabled: true
      size: 8Gi
```

#### templates/deployment.yaml
```yaml
# templates/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "container-demo.fullname" . }}
  labels:
    {{- include "container-demo.labels" . | nindent 4 }}
spec:
  {{- if not .Values.autoscaling.enabled }}
  replicas: {{ .Values.replicaCount }}
  {{- end }}
  selector:
    matchLabels:
      {{- include "container-demo.selectorLabels" . | nindent 6 }}
  template:
    metadata:
      labels:
        {{- include "container-demo.selectorLabels" . | nindent 8 }}
    spec:
      containers:
        - name: {{ .Chart.Name }}
          image: "{{ .Values.image.repository }}:{{ .Values.image.tag | default .Chart.AppVersion }}"
          imagePullPolicy: {{ .Values.image.pullPolicy }}
          ports:
            - name: http
              containerPort: {{ .Values.service.targetPort }}
              protocol: TCP
          env:
            - name: NODE_ENV
              value: "production"
            - name: DATABASE_HOST
              value: "{{ include "mysql.primary.fullname" . }}"
            - name: DATABASE_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: {{ include "mysql.secretName" . }}
                  key: mysql-password
          livenessProbe:
            httpGet:
              path: /health
              port: http
          readinessProbe:
            httpGet:
              path: /ready
              port: http
          resources:
            {{- toYaml .Values.resources | nindent 12 }}
```

### Helm 차트 배포

#### 배포 스크립트
```bash
#!/bin/bash
# deploy-helm.sh

set -e

echo "🚀 Helm 차트 배포 시작"

# Helm 차트 디렉토리로 이동
cd helm/container-demo

# 의존성 업데이트
helm dependency update

# Helm 차트 설치
helm upgrade --install container-demo . \
  --namespace container-demo \
  --create-namespace \
  --values values.yaml \
  --set image.tag=$IMAGE_TAG \
  --set mysql.auth.password=$MYSQL_PASSWORD

echo "✅ Helm 차트 배포 완료"
```

---

## 🌐 Istio 서비스 메시 구성

### Istio 설치 및 설정

#### Istio 설치
```bash
# Istio 다운로드 및 설치
curl -L https://istio.io/downloadIstio | sh -
cd istio-1.19.0
export PATH=$PWD/bin:$PATH

# Istio 설치
istioctl install --set values.defaultRevision=default
```

#### Istio Gateway 설정
```yaml
# istio-gateway.yaml
apiVersion: networking.istio.io/v1alpha3
kind: Gateway
metadata:
  name: container-demo-gateway
  namespace: container-demo
spec:
  selector:
    istio: ingressgateway
  servers:
  - port:
      number: 80
      name: http
      protocol: HTTP
    hosts:
    - container-demo.example.com
  - port:
      number: 443
      name: https
      protocol: HTTPS
    tls:
      mode: SIMPLE
      credentialName: container-demo-tls
    hosts:
    - container-demo.example.com
---
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: container-demo-vs
  namespace: container-demo
spec:
  hosts:
  - container-demo.example.com
  gateways:
  - container-demo-gateway
  http:
  - match:
    - uri:
        prefix: /
    route:
    - destination:
        host: container-demo-service
        port:
          number: 80
```

#### Istio 보안 정책
```yaml
# istio-security-policy.yaml
apiVersion: security.istio.io/v1beta1
kind: PeerAuthentication
metadata:
  name: container-demo-peer-auth
  namespace: container-demo
spec:
  selector:
    matchLabels:
      app: container-demo
  mtls:
    mode: STRICT
---
apiVersion: security.istio.io/v1beta1
kind: AuthorizationPolicy
metadata:
  name: container-demo-authz
  namespace: container-demo
spec:
  selector:
    matchLabels:
      app: container-demo
  rules:
  - from:
    - source:
        principals: ["cluster.local/ns/istio-system/sa/istio-ingressgateway-service-account"]
    to:
    - operation:
        methods: ["GET", "POST"]
        paths: ["/health", "/ready", "/api/*"]
```

---

## 📊 고급 모니터링 설정

### Prometheus 및 Grafana 설정

#### Prometheus 설정
```yaml
# prometheus-config.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: prometheus-config
  namespace: container-demo
data:
  prometheus.yml: |
    global:
      scrape_interval: 15s
      evaluation_interval: 15s
    rule_files:
      - "rules/*.yml"
    scrape_configs:
    - job_name: 'kubernetes-pods'
      kubernetes_sd_configs:
      - role: pod
      relabel_configs:
      - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_scrape]
        action: keep
        regex: true
      - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_path]
        action: replace
        target_label: __metrics_path__
        regex: (.+)
    - job_name: 'container-demo'
      static_configs:
      - targets: ['container-demo-service:80']
      metrics_path: /metrics
      scrape_interval: 5s
```

#### Grafana 대시보드
```yaml
# grafana-dashboard.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: grafana-dashboard
  namespace: container-demo
data:
  dashboard.json: |
    {
      "dashboard": {
        "title": "Container Demo Dashboard",
        "panels": [
          {
            "title": "Request Rate",
            "type": "graph",
            "targets": [
              {
                "expr": "rate(http_requests_total[5m])",
                "legendFormat": "{{method}} {{status}}"
              }
            ]
          },
          {
            "title": "Response Time",
            "type": "graph",
            "targets": [
              {
                "expr": "histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m]))",
                "legendFormat": "95th percentile"
              }
            ]
          },
          {
            "title": "Error Rate",
            "type": "graph",
            "targets": [
              {
                "expr": "rate(http_requests_total{status=~\"5..\"}[5m])",
                "legendFormat": "5xx errors"
              }
            ]
          }
        ]
      }
    }
```

---

## 🔒 보안 정책 적용

### Pod Security Policy
```yaml
# pod-security-policy.yaml
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
```

### Network Policy
```yaml
# network-policy-advanced.yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: container-demo-network-policy
  namespace: container-demo
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
  - to: []
    ports:
    - protocol: TCP
      port: 53
    - protocol: UDP
      port: 53
```

---

## 🚀 실습 프로젝트

### 프로젝트 구조
```
kubernetes-advanced/
├── helm/
│   └── container-demo/
│       ├── Chart.yaml
│       ├── values.yaml
│       └── templates/
│           ├── deployment.yaml
│           ├── service.yaml
│           ├── ingress.yaml
│           └── hpa.yaml
├── istio/
│   ├── gateway.yaml
│   ├── virtualservice.yaml
│   └── security-policy.yaml
├── monitoring/
│   ├── prometheus-config.yaml
│   └── grafana-dashboard.yaml
├── security/
│   ├── pod-security-policy.yaml
│   └── network-policy.yaml
└── scripts/
    ├── deploy-helm.sh
    ├── deploy-istio.sh
    └── deploy-monitoring.sh
```

### 실습 순서

#### 1단계: 기본 Kubernetes 리소스 배포
```bash
# Namespace 및 기본 리소스 생성
kubectl apply -f namespace.yaml
kubectl apply -f configmap.yaml
kubectl apply -f secret.yaml
```

#### 2단계: Helm 차트 배포
```bash
# Helm 차트 배포
./scripts/deploy-helm.sh
```

#### 3단계: Istio 서비스 메시 구성
```bash
# Istio 설치 및 설정
./scripts/deploy-istio.sh
```

#### 4단계: 모니터링 설정
```bash
# Prometheus 및 Grafana 배포
./scripts/deploy-monitoring.sh
```

#### 5단계: 보안 정책 적용
```bash
# 보안 정책 적용
kubectl apply -f security/
```

---

## ✅ 체크리스트

### Kubernetes 고급 기능
- [ ] Namespace 및 리소스 관리
- [ ] ConfigMap 및 Secret 활용
- [ ] Rolling Update 배포
- [ ] Blue-Green 배포
- [ ] Ingress 설정
- [ ] Network Policy 적용

### Helm 차트
- [ ] Helm 차트 작성
- [ ] values.yaml 설정
- [ ] 템플릿 작성
- [ ] 차트 배포 및 업그레이드

### Istio 서비스 메시
- [ ] Istio 설치
- [ ] Gateway 설정
- [ ] VirtualService 구성
- [ ] 보안 정책 적용

### 모니터링 및 로깅
- [ ] Prometheus 설정
- [ ] Grafana 대시보드 구성
- [ ] 메트릭 수집 확인
- [ ] 알림 설정

---

## 📚 참고 자료

- [Kubernetes 공식 문서](https://kubernetes.io/docs/)
- [Helm 공식 문서](https://helm.sh/docs/)
- [Istio 공식 문서](https://istio.io/latest/docs/)
- [Prometheus 공식 문서](https://prometheus.io/docs/)
- [Grafana 공식 문서](https://grafana.com/docs/)
