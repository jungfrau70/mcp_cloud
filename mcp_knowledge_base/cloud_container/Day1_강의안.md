# Cloud Container - 1일차 강의안

> 📋 **강의 일시**: 2024년 10월 1일 ["화"] 9:00~17:00  
> 📋 **강의 방식**: 온라인 실습 중심  
> 📋 **선수 학습**: Cloud Master 과정 완료 ["Docker, CI/CD 기본"]
> 📋 **WSL 환경설정**: [mcp_knowledge_base/cloud_container/_setup_wsl/README.md](../_setup_wsl/README.md)
> 📋 **실습 코드**: `git clone https://github.com/jungfrau70/cloud-container.git cloud_container`

---

## 🎯 1일차 학습 목표

### 핵심 목표
- **Kubernetes 클러스터**: GKE 클러스터 생성 및 고급 설정
- **GitHub Actions CI/CD**: Kubernetes 배포 자동화 파이프라인 구축
- **외부 모니터링**: VM 기반 Prometheus/Grafana로 Pod 모니터링
- **로드밸런싱**: Ingress를 통한 트래픽 분산
- **자동 스케일링**: HPA/VPA를 통한 Pod/Node 자동 확장
- **스트레스 테스트**: 부하 테스트를 통한 스케일링 검증

## ⚠️ 실습 전 필수 준비사항

### 🔧 **사전 요구사항 확인**
```bash
# 1. 필수 도구 설치 확인
echo "=== 필수 도구 확인 ==="
command -v kubectl && echo "✅ kubectl 설치됨" || echo "❌ kubectl 설치 필요"
command -v gcloud && echo "✅ GCP CLI 설치됨" || echo "❌ GCP CLI 설치 필요"
command -v docker && echo "✅ Docker 설치됨" || echo "❌ Docker 설치 필요"
command -v helm && echo "✅ Helm 설치됨" || echo "❌ Helm 설치 필요"
command -v git && echo "✅ Git 설치됨" || echo "❌ Git 설치 필요"

# 2. 클라우드 계정 설정 확인
echo "=== 클라우드 계정 설정 확인 ==="
gcloud auth list && echo "✅ GCP 계정 설정됨" || echo "❌ GCP 계정 설정 필요"
gcloud config get-value project && echo "✅ GCP 프로젝트 설정됨" || echo "❌ GCP 프로젝트 설정 필요"

# 3. GitHub Actions 권한 확인
echo "=== GitHub Actions 권한 확인 ==="
echo "GitHub Repository에 다음 권한이 필요합니다:"
echo "- Actions: Workflow 실행 권한"
echo "- Contents: 코드 읽기/쓰기 권한"
echo "- Packages: Container registry 푸시 권한"
```

### 📋 **실습 전 체크리스트**
- [ ] **GCP CLI 설정**: `gcloud auth list` 성공
- [ ] **kubectl 설치**: `kubectl version --client` 확인
- [ ] **Docker 실행**: `docker --version` 확인
- [ ] **GitHub 계정**: Actions 권한 확인
- [ ] **GCP 프로젝트**: Kubernetes Engine API 활성화
- [ ] **권한 확인**: GCP 리소스 생성 권한
- [ ] **네트워크 확인**: 인터넷 연결 및 방화벽 설정

## 📁 **1일차 강의 자료 구조**

### **새로운 디렉토리 구조**
```
cloud_container/scripts/
├── automation/          # 자동화 스크립트
│   ├── 01-gke-cluster.sh
│   ├── 02-github-actions-setup.sh
│   ├── 03-monitoring-stack.sh
│   ├── 04-loadbalancer-setup.sh
│   ├── 05-autoscaling.sh
│   ├── 06-stress-test.sh
│   └── 07-integration-test.sh
├── samples/             # 실습 샘플 코드
│   ├── sample-app/
│   ├── monitoring-config/
│   └── k8s-manifests/
├── docs/                # 문서 및 가이드
│   ├── github-actions-guide.md
│   ├── monitoring-setup.md
│   └── troubleshooting.md
└── scripts/             # 유틸리티 스크립트
    └── environment-check.sh
```

---

## 🕘 1교시: GKE 클러스터 구축 [9:00~10:30]

### 📚 이론 학습 ["15분"]
#### Kubernetes 아키텍처
- **클러스터 구성**: Control Plane + Worker Nodes
- **Pod**: 가장 작은 배포 단위
- **Service**: Pod 집합에 대한 네트워크 접근
- **Ingress**: HTTP/HTTPS 트래픽 라우팅

#### GKE [Google Kubernetes Engine]
- **관리형 Kubernetes**: Google이 Control Plane 관리
- **자동 업그레이드**: Kubernetes 버전 자동 업데이트
- **자동 스케일링**: 노드 자동 확장/축소
- **통합 모니터링**: Google Cloud 모니터링과 통합

### 🛠️ 실습 ["75분"]

#### 🏗️ **1단계: GKE 클러스터 생성**

**목표 아키텍처 ["1단계 완료 후"]**
```mermaid
flowchart TB
    subgraph "GCP Cloud"
        G1[GKE Cluster<br/>cloud-container-cluster]
        G2[Node Pool<br/>3 nodes]
        G3["VPC Network<br/>기본 네트워크"]
        G4["Firewall Rules<br/>Kubernetes 규칙"]
    end
    
    subgraph "Local"
        L1["개발자 머신<br/>kubectl"]
    end
    
    L1 -->> G1
    G1 -->> G2
    G2 -->> G3
    G3 -->> G4
```

**🔍 명령 실행: GKE 클러스터 생성**
```bash
# 자동화 스크립트 실행
echo "=== GKE 클러스터 생성 시작 ==="
./cloud_container/scripts/day1-practice-improved.sh

# 또는 수동 실행 ["참고용"]
echo "=== 수동 GKE 클러스터 생성 ==="
# 1. GKE 클러스터 생성
gcloud container clusters create cloud-container-cluster \
    --zone=asia-northeast3-a \
    --num-nodes=3 \
    --machine-type=e2-medium \
    --enable-autoscaling \
    --min-nodes=1 \
    --max-nodes=5 \
    --enable-autorepair \
    --enable-autoupgrade \
    --enable-ip-alias \
    --network=default \
    --subnetwork=default

# 2. 클러스터 인증
gcloud container clusters get-credentials cloud-container-cluster \
    --zone=asia-northeast3-a

# 3. 클러스터 상태 확인
kubectl cluster-info
kubectl get nodes
```

**✅ 예상 결과:**
- GKE 클러스터: `cloud-container-cluster` 생성
- 노드 수: 3개 [e2-medium]
- 자동 스케일링: 1-5개 노드
- 클러스터 상태: `RUNNING`

**🌐 콘솔에서 확인:**
- GCP Kubernetes Engine: https://console.cloud.google.com/kubernetes/clusters

---

## 🕘 2교시: GitHub Actions CI/CD 파이프라인 [10:45~12:00]

### 📚 이론 학습 ["15분"]
#### GitHub Actions CI/CD
- **Workflow**: 자동화된 CI/CD 파이프라인
- **Container Registry**: GCP Container Registry 연동
- **Kubernetes 배포**: kubectl을 통한 자동 배포
- **환경별 배포**: Dev, Staging, Production 분리

### 🛠️ 실습 ["60분"]

#### 🏗️ **2단계: GitHub Actions CI/CD 구축**

**목표 아키텍처 ["2단계 완료 후"]**
```mermaid
flowchart TB
    subgraph "GitHub"
        GH1[Repository<br/>sample-app]
        GH2[GitHub Actions<br/>CI/CD Pipeline]
        GH3["Container Registry<br/>GCR 연동"]
    end
    
    subgraph "GCP Cloud"
        G1[GKE Cluster<br/>cloud-container-cluster]
        G2[Container Registry<br/>gcr.io/project]
        G3[Kubernetes Pods<br/>sample-app]
    end
    
    subgraph "Local"
        L1["개발자 머신<br/>Git Push"]
    end
    
    L1 -->> GH1
    GH1 -->> GH2
    GH2 -->> GH3
    GH3 -->> G2
    G2 -->> G1
    G1 -->> G3
```

**🔍 명령 실행: GitHub Actions 설정**
```bash
# 자동화 스크립트 실행
echo "=== GitHub Actions CI/CD 설정 시작 ==="
./cloud_container/scripts/day1-practice-improved.sh

# 또는 수동 설정 ["참고용"]
echo "=== 수동 GitHub Actions 설정 ==="
# 1. 샘플 애플리케이션 생성
mkdir sample-app
cd sample-app

# 2. Dockerfile 생성
cat > Dockerfile << 'EOF'
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
EXPOSE 3000
CMD ["npm", "start"]
EOF

# 3. package.json 생성
cat > package.json << 'EOF'
{
  "name": "sample-app",
  "version": "1.0.0",
  "description": "Sample Node.js app for K8s",
  "main": "server.js",
  "scripts": {
    "start": "node server.js"
  },
  "dependencies": {
    "express": "^4.18.0"
  }
}
EOF

# 4. Express 서버 생성
cat > server.js << 'EOF'
const express = require['express'];
const app = express();
const port = 3000;

app.get['/', [req, res] => {
  res.json[{
    message: 'Hello from Kubernetes!',
    timestamp: new Date[].toISOString[],
    pod: process.env.HOSTNAME || 'unknown'
  }];
}];

app.get['/health', [req, res] => {
  res.status[200].json[{ status: 'healthy' }];
}];

app.get['/metrics', [req, res] => {
  res.json[{
    requests: Math.floor[Math.random[] * 1000],
    cpu_usage: Math.random[] * 100,
    memory_usage: Math.random[] * 100
  }];
}];

app.listen[port, '0.0.0.0', [] => {
  console.log[`Server running on port ${port}`];
}];
EOF

# 5. GitHub Actions Workflow 생성
mkdir -p .github/workflows
cat > .github/workflows/deploy.yml << 'EOF'
name: Deploy to GKE

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

env:
  PROJECT_ID: ${{ secrets.GCP_PROJECT_ID }}
  GKE_CLUSTER: cloud-container-cluster
  GKE_ZONE: asia-northeast3-a
  DEPLOYMENT_NAME: sample-app

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest
    
    steps:
    - name: Checkout
      uses: actions/checkout@v3
      
    - name: Setup Google Cloud CLI
      uses: google-github-actions/setup-gcloud@v1
      with:
        service_account_key: ${{ secrets.GCP_SA_KEY }}
        project_id: ${{ secrets.GCP_PROJECT_ID }}
        
    - name: Configure Docker
      run: gcloud auth configure-docker
      
    - name: Build Docker image
      run: |
        docker build -t gcr.io/$PROJECT_ID/$DEPLOYMENT_NAME:$GITHUB_SHA .
        
    - name: Push Docker image
      run: |
        docker push gcr.io/$PROJECT_ID/$DEPLOYMENT_NAME:$GITHUB_SHA
        
    - name: Setup kubectl
      run: |
        gcloud container clusters get-credentials $GKE_CLUSTER --zone $GKE_ZONE
        
    - name: Deploy to GKE
      run: |
        kubectl set image deployment/$DEPLOYMENT_NAME $DEPLOYMENT_NAME=gcr.io/$PROJECT_ID/$DEPLOYMENT_NAME:$GITHUB_SHA
        kubectl rollout status deployment/$DEPLOYMENT_NAME
EOF

# 6. Kubernetes 매니페스트 생성
mkdir k8s
cat > k8s/deployment.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: sample-app
  labels:
    app: sample-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: sample-app
  template:
    metadata:
      labels:
        app: sample-app
    spec:
      containers:
      - name: sample-app
        image: gcr.io/PROJECT_ID/sample-app:latest
        ports:
        - containerPort: 3000
        env:
        - name: NODE_ENV
          value: "production"
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
        readinessProbe:
          httpGet:
            path: /health
            port: 3000
          initialDelaySeconds: 5
          periodSeconds: 5
EOF

cat > k8s/service.yaml << 'EOF'
apiVersion: v1
kind: Service
metadata:
  name: sample-app-service
spec:
  selector:
    app: sample-app
  ports:
  - protocol: TCP
    port: 80
    targetPort: 3000
  type: ClusterIP
EOF

# 7. Git 초기화 및 푸시
git init
git add .
git commit -m "Initial commit: Sample app with GitHub Actions"
git branch -M main
git remote add origin https://github.com/USERNAME/sample-app.git
git push -u origin main
```

**✅ 예상 결과:**
- GitHub Repository: `sample-app` 생성
- GitHub Actions: CI/CD 파이프라인 활성화
- Container Registry: GCR에 이미지 푸시
- Kubernetes: Pod 자동 배포

**🌐 브라우저로 확인:**
- GitHub Actions: https://github.com/USERNAME/sample-app/actions
- GCP Container Registry: https://console.cloud.google.com/gcr

---

## 🍽️ 점심 시간 [12:00~13:00]

---

## 🕘 3교시: 외부 VM 모니터링 스택 구축 [13:00~14:30]

### 📚 이론 학습 ["15분"]
#### 모니터링 아키텍처
- **Prometheus**: 메트릭 수집 및 저장
- **Grafana**: 시각화 및 대시보드
- **Node Exporter**: 시스템 메트릭 수집
- **외부 모니터링**: VM에서 Kubernetes 클러스터 모니터링

### 🛠️ 실습 ["75분"]

#### 🏗️ **3단계: 외부 VM 모니터링 스택 구축**

**목표 아키텍처 ["3단계 완료 후"]**
```mermaid
flowchart TB
    subgraph "GCP Cloud - GKE"
        G1[GKE Cluster<br/>cloud-container-cluster]
        G2[Sample App Pods<br/>3 replicas]
        G3[Service<br/>sample-app-service]
        G4[Ingress<br/>Load Balancer]
    end
    
    subgraph "External VM - Monitoring"
        M1["Prometheus<br/>:9090<br/>메트릭 수집"]
        M2["Grafana<br/>:3000<br/>시각화"]
        M3["Node Exporter<br/>:9100<br/>시스템 메트릭"]
        M4["Kube State Metrics<br/>K8s 상태 메트릭"]
    end
    
    subgraph "Local"
        L1["개발자 머신"]
    end
    
    L1 -->> G4
    G4 -->> G3
    G3 -->> G2
    
    M1 -->> G2
    M1 -->> G3
    M3 -->> G2
    M4 -->> G1
    M2 -->> M1
    L1 -->> M2
```

**🔍 명령 실행: 외부 VM 모니터링 스택 구축**
```bash
# 자동화 스크립트 실행
echo "=== 외부 VM 모니터링 스택 구축 시작 ==="
./cloud_container/scripts/day1-practice-improved.sh

# 또는 수동 실행 ["참고용"]
echo "=== 수동 모니터링 스택 구축 ==="
# 1. 모니터링 디렉토리 생성
mkdir -p monitoring/{prometheus,grafana/dashboards,grafana/provisioning/datasources}

# 2. Prometheus 설정 파일 생성 ["Kubernetes 클러스터 모니터링 포함"]
cat > monitoring/prometheus/prometheus.yml << 'EOF'
global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']
  
  - job_name: 'node-exporter'
    static_configs:
      - targets: ['node-exporter:9100']
  
  # Kubernetes 클러스터 메트릭 수집
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
      regex: [.+]
    - source_labels: [__address__, __meta_kubernetes_pod_annotation_prometheus_io_port]
      action: replace
      regex: [[^:]+][?::\d+]?;[\d+]
      replacement: $1:$2
      target_label: __address__
  
  # Kubernetes API 서버 메트릭
  - job_name: 'kubernetes-apiservers'
    kubernetes_sd_configs:
    - role: endpoints
    scheme: https
    tls_config:
      ca_file: /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
    bearer_token_file: /var/run/secrets/kubernetes.io/serviceaccount/token
    relabel_configs:
    - source_labels: [__meta_kubernetes_namespace, __meta_kubernetes_service_name, __meta_kubernetes_endpoint_port_name]
      action: keep
      regex: default;kubernetes;https
  
  # Kubernetes 노드 메트릭
  - job_name: 'kubernetes-nodes'
    kubernetes_sd_configs:
    - role: node
    scheme: https
    tls_config:
      ca_file: /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
    bearer_token_file: /var/run/secrets/kubernetes.io/serviceaccount/token
    relabel_configs:
    - action: labelmap
      regex: __meta_kubernetes_node_label_[.+]
    - target_label: __address__
      replacement: kubernetes.default.svc:443
    - source_labels: [__meta_kubernetes_node_name]
      regex: [.+]
      target_label: __metrics_path__
      replacement: /api/v1/nodes/${1}/proxy/metrics
EOF

# 3. Docker Compose 파일 생성
cat > monitoring/docker-compose.yml << 'EOF'
version: '3.8'
services:
  prometheus:
    image: prom/prometheus:latest
    container_name: prometheus
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus/prometheus.yml:/etc/prometheus/prometheus.yml
      - prometheus_data:/prometheus
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
      - '--web.enable-lifecycle'
      - '--web.enable-admin-api'

  grafana:
    image: grafana/grafana:latest
    container_name: grafana
    ports:
      - "3000:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin
      - GF_INSTALL_PLUGINS=grafana-kubernetes-app
    volumes:
      - grafana_data:/var/lib/grafana
      - ./grafana/provisioning:/etc/grafana/provisioning

  node-exporter:
    image: prom/node-exporter:latest
    container_name: node-exporter
    ports:
      - "9100:9100"
    volumes:
      - /proc:/host/proc:ro
      - /sys:/host/sys:ro
      - /:/rootfs:ro
    command:
      - '--path.procfs=/host/proc'
      - '--path.rootfs=/rootfs'
      - '--path.sysfs=/host/sys'
      - '--collector.filesystem.mount-points-exclude=^/[sys|proc|dev|host|etc][$$|/]'

volumes:
  prometheus_data:
  grafana_data:
EOF

# 4. Grafana 데이터소스 설정
cat > monitoring/grafana/provisioning/datasources/datasources.yml << 'EOF'
apiVersion: 1

datasources:
  - name: Prometheus
    type: prometheus
    access: proxy
    url: http://prometheus:9090
    isDefault: true
    editable: true
EOF

# 5. 모니터링 스택 실행
cd monitoring
docker-compose up -d

# 6. Kubernetes에 모니터링 설정 추가
kubectl create namespace monitoring

# 7. Kube State Metrics 설치
kubectl apply -f https://raw.githubusercontent.com/kubernetes/kube-state-metrics/master/examples/standard/kube-state-metrics-deployment.yaml

# 8. Sample App에 Prometheus 어노테이션 추가
kubectl patch deployment sample-app -p '{"spec":{"template":{"metadata":{"annotations":{"prometheus.io/scrape":"true","prometheus.io/port":"3000","prometheus.io/path":"/metrics"}}}}}'

# 9. 상태 확인
echo "🔍 모니터링 시스템 상태 확인"
sleep 10
curl -f http://localhost:9090 && echo "✅ Prometheus 정상"
curl -f http://localhost:3000 && echo "✅ Grafana 정상"
curl -f http://localhost:9100 && echo "✅ Node Exporter 정상"
```

**✅ 예상 결과:**
- Prometheus: Kubernetes 클러스터 메트릭 수집
- Grafana: 시각화 대시보드 구성
- Node Exporter: 시스템 메트릭 수집
- Kube State Metrics: Kubernetes 상태 메트릭

**🌐 브라우저로 서비스 접근:**
```bash
echo "=== 모니터링 서비스 접속 URL ==="
echo "Prometheus: http://localhost:9090"
echo "Grafana: http://localhost:3000 [admin/admin]"
echo "Node Exporter: http://localhost:9100"
echo ""
echo "브라우저에서 각 URL에 접속하여 확인하세요!"
```

---

## 🕘 4교시: 로드밸런서 및 Ingress 설정 [14:45~16:15]

### 📚 이론 학습 ["15분"]
#### 로드밸런싱 개념
- **Ingress**: HTTP/HTTPS 트래픽 라우팅
- **Load Balancer**: 외부 트래픽을 서비스로 분산
- **Service**: Pod 집합에 대한 안정적인 엔드포인트
- **Health Check**: 서비스 상태 모니터링

### 🛠️ 실습 ["75분"]

#### 🏗️ **4단계: 로드밸런서 및 Ingress 설정**

**목표 아키텍처 ["4단계 완료 후"]**
```mermaid
flowchart TB
    subgraph "Internet"
        I1["사용자 요청"]
    end
    
    subgraph "GCP Cloud - Load Balancer"
        LB1[Cloud Load Balancer<br/>External IP]
        LB2[Ingress Controller<br/>nginx-ingress]
    end
    
    subgraph "GCP Cloud - GKE"
        G1[GKE Cluster<br/>cloud-container-cluster]
        G2[Sample App Pods<br/>3 replicas]
        G3[Service<br/>sample-app-service]
        G4[Ingress<br/>sample-app-ingress]
    end
    
    subgraph "External VM - Monitoring"
        M1[Prometheus<br/>:9090]
        M2[Grafana<br/>:3000]
    end
    
    I1 -->> LB1
    LB1 -->> LB2
    LB2 -->> G4
    G4 -->> G3
    G3 -->> G2
    
    M1 -->> G2
    M2 -->> M1
```

**🔍 명령 실행: 로드밸런서 및 Ingress 설정**
```bash
# 자동화 스크립트 실행
echo "=== 로드밸런서 및 Ingress 설정 시작 ==="
./cloud_container/scripts/day1-practice-improved.sh

# 또는 수동 실행 ["참고용"]
echo "=== 수동 로드밸런서 및 Ingress 설정 ==="
# 1. Ingress Controller 설치 [nginx-ingress]
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.1/deploy/static/provider/cloud/deploy.yaml

# 2. Ingress Controller 상태 확인
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=120s

# 3. Ingress 매니페스트 생성
cat > k8s/ingress.yaml << 'EOF'
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: sample-app-ingress
  annotations:
    kubernetes.io/ingress.class: "nginx"
    nginx.ingress.kubernetes.io/rewrite-target: /
    nginx.ingress.kubernetes.io/ssl-redirect: "false"
    nginx.ingress.kubernetes.io/force-ssl-redirect: "false"
spec:
  rules:
  - host: sample-app.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: sample-app-service
            port:
              number: 80
  - http:  # 기본 호스트 ["모든 요청"]
    paths:
    - path: /
      pathType: Prefix
      backend:
        service:
          name: sample-app-service
          port:
            number: 80
EOF

# 4. Ingress 적용
kubectl apply -f k8s/ingress.yaml

# 5. Load Balancer IP 확인
echo "Load Balancer IP 확인 중..."
kubectl get service ingress-nginx-controller -n ingress-nginx
EXTERNAL_IP=$[kubectl get service ingress-nginx-controller -n ingress-nginx -o jsonpath='{.status.loadBalancer.ingress[0].ip}']
echo "External IP: $EXTERNAL_IP"

# 6. 로드밸런서 헬스체크 확인
echo "로드밸런서 헬스체크 확인..."
curl -I http://$EXTERNAL_IP/health

# 7. 트래픽 분산 테스트
echo "트래픽 분산 테스트 ["10회 요청"]:"
for i in {1..10}; do
    echo -n "요청 $i: "
    curl -s http://$EXTERNAL_IP/ | grep -o '"pod":"[^"]*"' || echo "응답 없음"
    sleep 1
done
```

**✅ 예상 결과:**
- Ingress Controller: nginx-ingress 설치
- Load Balancer: 외부 IP 할당
- Ingress: 트래픽 라우팅 설정
- 트래픽 분산: 여러 Pod에 요청 분산

**🌐 브라우저로 서비스 접근:**
```bash
echo "=== 로드밸런서 접속 URL ==="
echo "Sample App: http://$EXTERNAL_IP"
echo "Health Check: http://$EXTERNAL_IP/health"
echo "Metrics: http://$EXTERNAL_IP/metrics"
echo ""
echo "브라우저에서 접속하여 확인하세요!"
```

---

## 🕘 5교시: 자동 스케일링 및 스트레스 테스트 [16:30~17:00]

### 📚 이론 학습 ["10분"]
#### 자동 스케일링
- **HPA [Horizontal Pod Autoscaler]**: Pod 수평 확장
- **VPA [Vertical Pod Autoscaler]**: Pod 리소스 수직 확장
- **Cluster Autoscaler**: 노드 자동 확장
- **메트릭 기반 스케일링**: CPU, 메모리, 커스텀 메트릭

### 🛠️ 실습 ["20분"]

#### 🏗️ **5단계: 자동 스케일링 설정**

**목표 아키텍처 ["5단계 완료 후"]**
```mermaid
flowchart TB
    subgraph "Internet"
        I1["사용자 요청<br/>고부하"]
    end
    
    subgraph "GCP Cloud - Load Balancer"
        LB1[Cloud Load Balancer<br/>External IP]
    end
    
    subgraph "GCP Cloud - GKE"
        G1[GKE Cluster<br/>cloud-container-cluster]
        G2["Sample App Pods<br/>1-10 replicas<br/>HPA 관리"]
        G3[Service<br/>sample-app-service]
        G4[Ingress<br/>sample-app-ingress]
        G5["HPA<br/>CPU 70% 기준"]
        G6["Cluster Autoscaler<br/>노드 자동 확장"]
    end
    
    subgraph "External VM - Monitoring"
        M1[Prometheus<br/>:9090]
        M2[Grafana<br/>:3000]
    end
    
    I1 -->> LB1
    LB1 -->> G4
    G4 -->> G3
    G3 -->> G2
    G5 -->> G2
    G6 -->> G1
    
    M1 -->> G2
    M2 -->> M1
```

**🔍 명령 실행: 자동 스케일링 설정**
```bash
# 자동화 스크립트 실행
echo "=== 자동 스케일링 설정 시작 ==="
./cloud_container/scripts/day1-practice-improved.sh

# 또는 수동 실행 ["참고용"]
echo "=== 수동 자동 스케일링 설정 ==="
# 1. HPA [Horizontal Pod Autoscaler] 생성
cat > k8s/hpa.yaml << 'EOF'
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: sample-app-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: sample-app
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

# 2. HPA 적용
kubectl apply -f k8s/hpa.yaml

# 3. Cluster Autoscaler 활성화 ["GKE에서 자동 활성화됨"]
echo "Cluster Autoscaler 상태 확인..."
kubectl get nodes
kubectl describe node | grep -i "autoscaler"

# 4. 현재 스케일링 상태 확인
echo "현재 HPA 상태:"
kubectl get hpa sample-app-hpa

# 5. 현재 Pod 상태 확인
echo "현재 Pod 상태:"
kubectl get pods -l app=sample-app
```

**✅ 예상 결과:**
- HPA: CPU 70%, 메모리 80% 기준으로 1-10개 Pod 스케일링
- Cluster Autoscaler: 노드 자동 확장 활성화
- 현재 상태: 3개 Pod 실행 중

#### 🏗️ **6단계: 스트레스 테스트 및 모니터링**

**🔍 명령 실행: 스트레스 테스트**
```bash
# 자동화 스크립트 실행
echo "=== 스트레스 테스트 시작 ==="
./cloud_container/scripts/day1-practice-improved.sh

# 또는 수동 실행 ["참고용"]
echo "=== 수동 스트레스 테스트 ==="
# 1. Load Balancer IP 가져오기
EXTERNAL_IP=$[kubectl get service ingress-nginx-controller -n ingress-nginx -o jsonpath='{.status.loadBalancer.ingress[0].ip}']
echo "Target URL: http://$EXTERNAL_IP"

# 2. CPU 부하 생성 스크립트 생성
cat > stress-test.sh << 'EOF'
#!/bin/bash

EXTERNAL_IP=$1
echo "스트레스 테스트 시작: $EXTERNAL_IP"

# Apache Bench 설치 확인
if ! command -v ab &> /dev/null; then
    echo "Apache Bench 설치 중..."
    sudo apt update && sudo apt install -y apache2-utils
fi

# 스트레스 테스트 실행 ["1000 요청, 동시 50개"]
echo "고부하 테스트 시작 ["1000 요청, 동시 50개"]..."
ab -n 1000 -c 50 http://$EXTERNAL_IP/ > stress-test-results.log 2>&1 &

# 테스트 진행 중 모니터링
echo "모니터링 시작..."
for i in {1..20}; do
    echo "--- 모니터링 $i/20 ["10초 간격"] ---"
    
    # HPA 상태 확인
    echo "HPA 상태:"
    kubectl get hpa sample-app-hpa
    
    # Pod 상태 확인
    echo "Pod 상태:"
    kubectl get pods -l app=sample-app
    
    # 노드 상태 확인
    echo "노드 상태:"
    kubectl get nodes
    
    # CPU 사용률 확인
    echo "Pod CPU 사용률:"
    kubectl top pods -l app=sample-app
    
    sleep 10
done

# 테스트 완료 대기
wait

echo "스트레스 테스트 완료!"
echo "결과 파일: stress-test-results.log"
EOF

chmod +x stress-test.sh

# 3. 스트레스 테스트 실행
./stress-test.sh $EXTERNAL_IP

# 4. 결과 분석
echo "=== 스트레스 테스트 결과 분석 ==="
echo "Apache Bench 결과:"
grep -E "[Requests per second|Time per request|Failed requests]" stress-test-results.log

echo "최종 HPA 상태:"
kubectl get hpa sample-app-hpa

echo "최종 Pod 상태:"
kubectl get pods -l app=sample-app

echo "최종 노드 상태:"
kubectl get nodes
```

**✅ 예상 결과:**
- 스트레스 테스트: 1000 요청, 동시 50개
- HPA 스케일링: CPU 사용률 증가로 Pod 수 증가
- Cluster Autoscaler: 필요시 노드 추가
- 모니터링: Prometheus/Grafana에서 실시간 확인

**🌐 브라우저로 모니터링 확인:**
```bash
echo "=== 모니터링 대시보드 확인 ==="
echo "1. Grafana: http://localhost:3000 [admin/admin]"
echo "2. Prometheus: http://localhost:9090"
echo "3. Sample App: http://$EXTERNAL_IP"
echo ""
echo "확인 포인트:"
echo "- CPU 사용률 그래프"
echo "- Pod 수 변화 그래프"
echo "- 노드 수 변화 그래프"
echo "- 응답 시간 그래프"
```

---

## 🎯 **실습 진행 패턴 요약**

### 📋 **각 단계별 진행 패턴**
1. **🏗️ 아키텍처 그림**: 현재 상태와 목표 상태를 Mermaid 다이어그램으로 시각화
2. **🔍 명령 실행**: 자동화 스크립트 또는 수동 명령어 실행
3. **✅ 예상 결과**: 명령 실행 후 예상되는 결과 명시
4. **🌐 콘솔에서 확인**: GCP 콘솔에서 리소스 상태 확인
5. **🌐 브라우저로 서비스 접근**: 실제 서비스에 접근하여 동작 확인

### 🚀 **실습 진행 순서**
1. **1교시**: GKE 클러스터 구축
2. **2교시**: GitHub Actions CI/CD 파이프라인
3. **3교시**: 외부 VM 모니터링 스택 구축
4. **4교시**: 로드밸런서 및 Ingress 설정
5. **5교시**: 자동 스케일링 및 스트레스 테스트

### 🎯 **핵심 학습 포인트**
- **아키텍처 이해**: 각 단계별 시스템 구조 변화 시각화
- **실습 중심**: 90% 실습, 10% 이론
- **단계별 검증**: 각 단계마다 결과 확인 및 검증
- **통합 시나리오**: CI/CD → 배포 → 모니터링 → 스케일링 연계
- **자동화**: 스크립트를 통한 효율적 실습

### 🏗️ 최종 시스템 아키텍처

#### 5단계: 자동 스케일링 및 스트레스 테스트 완료 후
```mermaid
flowchart TB
    subgraph "GitHub"
        GH1[Repository<br/>sample-app]
        GH2[GitHub Actions<br/>CI/CD Pipeline]
    end
    
    subgraph "GCP Cloud - Load Balancer"
        LB1[Cloud Load Balancer<br/>External IP]
        LB2[Ingress Controller<br/>nginx-ingress]
    end
    
    subgraph "GCP Cloud - GKE"
        G1[GKE Cluster<br/>cloud-container-cluster<br/>1-5 nodes]
        G2["Sample App Pods<br/>1-10 replicas<br/>HPA 관리"]
        G3[Service<br/>sample-app-service]
        G4[Ingress<br/>sample-app-ingress]
        G5["HPA<br/>CPU/Memory 기반"]
        G6["Cluster Autoscaler<br/>노드 자동 확장"]
    end
    
    subgraph "External VM - Monitoring"
        M1["Prometheus<br/>:9090<br/>메트릭 수집"]
        M2["Grafana<br/>:3000<br/>시각화"]
        M3["Node Exporter<br/>:9100<br/>시스템 메트릭"]
        M4["Kube State Metrics<br/>K8s 상태 메트릭"]
    end
    
    subgraph "Local"
        L1["개발자 머신"]
    end
    
    L1 -->> GH1
    GH1 -->> GH2
    GH2 -->> G1
    
    L1 -->> LB1
    LB1 -->> LB2
    LB2 -->> G4
    G4 -->> G3
    G3 -->> G2
    
    G5 -->> G2
    G6 -->> G1
    
    M1 -->> G2
    M1 -->> G3
    M3 -->> G2
    M4 -->> G1
    M2 -->> M1
    L1 -->> M2
```

**최종 적용된 기능:**
- ✅ **GitHub Actions CI/CD**: 코드 푸시 → 자동 빌드 → K8s 배포
- ✅ **GKE 클러스터**: 관리형 Kubernetes 클러스터
- ✅ **외부 모니터링**: VM 기반 Prometheus/Grafana로 K8s 모니터링
- ✅ **로드밸런싱**: Ingress를 통한 트래픽 분산
- ✅ **자동 스케일링**: HPA + Cluster Autoscaler
- ✅ **스트레스 테스트**: 부하 테스트를 통한 스케일링 검증

### 📊 예상 결과
- **성공률**: 95% ["자동화 스크립트 활용"]
- **소요 시간**: 7시간 ["자동화로 단축"]
- **주요 개선**: 통합 시나리오, 실시간 모니터링, 자동 스케일링

---

## 🎯 1일차 수업 성과

### ✅ 달성한 학습 목표
- [x] GKE 클러스터 생성 및 고급 설정
- [x] GitHub Actions CI/CD 파이프라인 구축
- [x] 외부 VM 모니터링 스택으로 K8s 모니터링
- [x] 로드밸런서 및 Ingress 설정
- [x] HPA 및 Cluster Autoscaler 설정
- [x] 스트레스 테스트를 통한 스케일링 검증

### 🔍 주요 학습 포인트
1. **통합 시나리오**: CI/CD → 배포 → 모니터링 → 스케일링 연계
2. **외부 모니터링**: VM에서 K8s 클러스터 모니터링
3. **자동화**: GitHub Actions를 통한 완전 자동화
4. **로드밸런싱**: Ingress를 통한 트래픽 분산
5. **자동 스케일링**: 메트릭 기반 Pod/Node 자동 확장
6. **실시간 모니터링**: Prometheus/Grafana 대시보드

### 🚀 실습 결과물
- **GKE 클러스터**: 관리형 Kubernetes 클러스터
- **CI/CD 파이프라인**: GitHub Actions 자동화
- **모니터링 스택**: Prometheus + Grafana
- **로드밸런서**: Ingress 기반 트래픽 분산
- **자동 스케일링**: HPA + Cluster Autoscaler
- **스트레스 테스트**: 부하 테스트 및 스케일링 검증

---

**강의안 작성일**: 2024년 10월 1일  
**예상 소요 시간**: 7시간 ["9:00~17:00, 자동화로 단축"]  
**실습 중심**: 90% 실습, 10% 이론  
**자동화 활용**: 95% 자동화 스크립트 사용 권장  
**통합 시나리오**: CI/CD → 배포 → 모니터링 → 스케일링 완전 연계
