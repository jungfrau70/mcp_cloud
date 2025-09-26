# 📊 멀티 클라우드 통합 모니터링 시스템

## 🎯 학습 목표

### 핵심 학습 목표
- **멀티 클라우드 환경** 이해 및 통합 모니터링 시스템 구축
- **Infrastructure/Platform/Application** 3계층 모니터링 구현
- **AWS + GCP** 환경에서의 통합 모니터링 시스템 운영
- **실제 운영 환경** 수준의 모니터링 시스템 구축

### 실습 후 달성할 수 있는 능력
- ✅ 멀티 클라우드 통합 모니터링 시스템 설계 및 구축
- ✅ Infrastructure/Platform/Application 3계층 모니터링 구현
- ✅ Global Dashboard를 통한 통합 시각화
- ✅ 실제 운영 환경 수준의 모니터링 시스템 운영

### 예상 소요 시간
- **Phase 1**: 통합 모니터링 허브 구축 (2-3시간)
- **Phase 2**: AWS 클러스터 모니터링 (3-4시간)
- **Phase 3**: AWS Application 모니터링 (2-3시간)
- **Phase 4**: GCP 클러스터 모니터링 (3-4시간)
- **전체 과정**: 10-14시간

---

## 🛠️ 실습 학습

### 📁 실습 코드 및 자동화
- **통합 시나리오**: `./cloud_intermediate/통합모니터링시나리오.md`
- **실습 코드**: `./cloud_intermediate/samples/day2/monitoring-basics/`
- **자동화 스크립트**: `./cloud_intermediate/scripts/monitoring-stack.sh`
- **클라우드 스크립트**: `./cloud_intermediate/cloud-scripts/`

<details>
<summary>🚀 실습 환경 준비</summary>

#### 필수 도구
- **AWS CLI**: AWS 서비스 관리
- **GCP CLI**: GCP 서비스 관리
- **kubectl**: Kubernetes 클러스터 관리
- **eksctl**: AWS EKS 클러스터 관리
- **gcloud**: GCP GKE 클러스터 관리
- **Docker & Docker Compose**: 컨테이너 환경
- **Helm**: Kubernetes 패키지 관리

#### 환경 설정
```bash
# AWS CLI 설정 확인
aws --version
aws configure list

# GCP CLI 설정 확인
gcloud --version
gcloud auth list

# Kubernetes 도구 확인
kubectl version --client
eksctl version
helm version

# Docker 환경 확인
docker --version
docker-compose --version
```

#### 클라우드 계정 설정
```bash
# AWS 계정 설정
aws sts get-caller-identity

# GCP 프로젝트 설정
gcloud config get-value project
gcloud auth application-default login
```

</details>

---

## 🏗️ Phase 1: 통합 모니터링 허브 구축

### 📋 **Phase 1 개요**
- **목표**: AWS VM에 통합 모니터링 허브 구축
- **구성**: Global Prometheus + Grafana + AlertManager
- **예상 소요 시간**: 2-3시간

### 🔧 **1-1. AWS EC2 인스턴스 생성**

<details>
<summary>📋 클릭하여 코드 복사</summary>

```bash
# AWS EC2 인스턴스 생성
aws ec2 run-instances \
  --image-id ami-0c02fb55956c7d316 \
  --instance-type t3.medium \
  --key-name monitoring-key \
  --security-group-ids sg-monitoring \
  --subnet-id subnet-monitoring \
  --associate-public-ip-address \
  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=global-monitoring-hub}]'

# 인스턴스 ID 확인
aws ec2 describe-instances --filters "Name=tag:Name,Values=global-monitoring-hub" --query 'Reservations[*].Instances[*].[InstanceId,State.Name]' --output table
```

</details>

### 🔧 **1-2. Elastic IP 할당**

<details>
<summary>📋 클릭하여 코드 복사</summary>

```bash
# Elastic IP 할당
aws ec2 allocate-address --domain vpc

# 할당된 Elastic IP를 인스턴스에 연결
aws ec2 associate-address \
  --instance-id i-1234567890abcdef0 \
  --allocation-id eipalloc-12345678

# Public IP 확인
aws ec2 describe-addresses --query 'Addresses[*].[PublicIp,InstanceId]' --output table
```

</details>

### 🔧 **1-3. 보안 그룹 설정**

<details>
<summary>📋 클릭하여 코드 복사</summary>

```bash
# 보안 그룹 생성
aws ec2 create-security-group \
  --group-name global-monitoring-sg \
  --description "Security group for global monitoring hub"

# 인바운드 규칙 설정
aws ec2 authorize-security-group-ingress \
  --group-id sg-12345678 \
  --protocol tcp \
  --port 22 \
  --cidr 0.0.0.0/0

aws ec2 authorize-security-group-ingress \
  --group-id sg-12345678 \
  --protocol tcp \
  --port 9090 \
  --cidr 0.0.0.0/0

aws ec2 authorize-security-group-ingress \
  --group-id sg-12345678 \
  --protocol tcp \
  --port 3000 \
  --cidr 0.0.0.0/0
```

</details>

### 🔧 **1-4. 모니터링 스택 설치**

<details>
<summary>📋 클릭하여 코드 복사</summary>

```bash
# AWS VM에 SSH 접속
ssh -i monitoring-key.pem ubuntu@3.123.45.67

# 시스템 업데이트
sudo apt-get update && sudo apt-get upgrade -y

# Docker 설치
sudo apt-get install -y docker.io docker-compose
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker ubuntu

# 모니터링 디렉토리 생성
mkdir -p /home/ubuntu/monitoring/{prometheus,grafana,alertmanager,dashboards}
cd /home/ubuntu/monitoring
```

</details>

### 🔧 **1-5. Docker Compose 설정**

<details>
<summary>📋 클릭하여 코드 복사</summary>

```bash
# Docker Compose 파일 생성
cat > /home/ubuntu/monitoring/docker-compose.yml << 'EOF'
version: '3.8'

services:
  # Global Prometheus
  prometheus:
    image: prom/prometheus:latest
    container_name: global-prometheus
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
    networks:
      - monitoring

  # Node Exporter
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
    networks:
      - monitoring

  # Grafana
  grafana:
    image: grafana/grafana:latest
    container_name: global-grafana
    ports:
      - "3000:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin123
    volumes:
      - grafana_data:/var/lib/grafana
    networks:
      - monitoring

  # Push Gateway
  pushgateway:
    image: prom/pushgateway:latest
    container_name: pushgateway
    ports:
      - "9091:9091"
    networks:
      - monitoring

  # AlertManager
  alertmanager:
    image: prom/alertmanager:latest
    container_name: alertmanager
    ports:
      - "9093:9093"
    volumes:
      - ./alertmanager/alertmanager.yml:/etc/alertmanager/alertmanager.yml
    networks:
      - monitoring

volumes:
  prometheus_data:
  grafana_data:

networks:
  monitoring:
    driver: bridge
EOF
```

</details>

### 🔧 **1-6. 모니터링 스택 실행**

<details>
<summary>📋 클릭하여 코드 복사</summary>

```bash
# 모니터링 스택 실행
cd /home/ubuntu/monitoring
docker-compose up -d

# 서비스 상태 확인
docker-compose ps

# 접속 정보 확인
echo "=== 모니터링 스택 접속 정보 ==="
echo "Grafana: http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4):3000 (admin/admin123)"
echo "Prometheus: http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4):9090"
echo "AlertManager: http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4):9093"
```

</details>

**✅ Phase 1 완료 확인**:
- [ ] AWS VM 통합 모니터링 허브 구축 완료
- [ ] Global Prometheus + Grafana 정상 동작 확인
- [ ] Node Exporter 메트릭 수집 확인
- [ ] 멀티 클라우드 모니터링 기반 환경 준비 완료

---

## ☸️ Phase 2: AWS 클러스터 Infrastructure/Platform 모니터링

### 📋 **Phase 2 개요**
- **목표**: AWS EKS 클러스터 구축 및 Infrastructure/Platform 모니터링 설정
- **구성**: AWS EKS + Prometheus 스택 + Global 연동
- **예상 소요 시간**: 3-4시간

### 🔧 **2-1. AWS EKS 클러스터 생성**

<details>
<summary>📋 클릭하여 코드 복사</summary>

```bash
# EKS 클러스터 생성
eksctl create cluster \
  --name aws-monitoring-cluster \
  --region us-west-2 \
  --nodegroup-name worker-nodes \
  --node-type t3.medium \
  --nodes 3 \
  --nodes-min 1 \
  --nodes-max 5 \
  --managed

# 클러스터 상태 확인
eksctl get cluster --region us-west-2
```

</details>

### 🔧 **2-2. Prometheus 스택 배포**

<details>
<summary>📋 클릭하여 코드 복사</summary>

```bash
# kubectl 설정
aws eks update-kubeconfig --name aws-monitoring-cluster --region us-west-2

# Helm 설치
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Prometheus 스택 설치
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

helm install prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --create-namespace \
  --set prometheus.prometheusSpec.retention=30d \
  --set grafana.adminPassword=admin123 \
  --wait
```

</details>

### 🔧 **2-3. Global Prometheus 연동 설정**

<details>
<summary>📋 클릭하여 코드 복사</summary>

```bash
# AWS 클러스터의 Prometheus 서비스 엔드포인트 확인
kubectl get svc -n monitoring | grep prometheus-server

# Global Prometheus 설정에 AWS 클러스터 Federation 추가
cat >> /home/ubuntu/monitoring/prometheus/prometheus.yml << 'EOF'

  # AWS 클러스터 메트릭 수집 (Federation)
  - job_name: 'aws-cluster-federation'
    scrape_interval: 30s
    honor_labels: true
    metrics_path: /federate
    params:
      'match[]':
        - '{job=~"kubernetes-.*"}'
        - '{job=~"kube-.*"}'
    static_configs:
      - targets: ['aws-prometheus-endpoint:9090']
    basic_auth:
      username: 'prometheus'
      password: 'secure-password'
EOF

# Global Prometheus 재시작
cd /home/ubuntu/monitoring
docker-compose restart prometheus
```

</details>

**✅ Phase 2 완료 확인**:
- [ ] AWS EKS 클러스터가 정상적으로 생성됨
- [ ] Prometheus 스택이 클러스터에 배포됨
- [ ] Global Prometheus에서 AWS 클러스터 메트릭 수집 확인
- [ ] Infrastructure/Platform 모니터링 대시보드 구성

---

## 🚀 Phase 3: AWS Application 모니터링

### 📋 **Phase 3 개요**
- **목표**: GitHub Actions를 통한 AWS EKS 애플리케이션 배포 및 Application 모니터링
- **구성**: GitHub Actions + Kubernetes + Application 메트릭
- **예상 소요 시간**: 2-3시간

### 🔧 **3-1. GitHub Actions 워크플로우 생성**

<details>
<summary>📋 클릭하여 코드 복사</summary>

```yaml
# .github/workflows/deploy-aws-app.yml
name: Deploy to AWS EKS

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v2
    
    - name: Configure AWS credentials
      uses: aws-actions/configure-aws-credentials@v1
      with:
        aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
        aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        aws-region: us-west-2
    
    - name: Build and push Docker image
      run: |
        docker build -t $ECR_REGISTRY/$ECR_REPOSITORY:$GITHUB_SHA .
        docker push $ECR_REGISTRY/$ECR_REPOSITORY:$GITHUB_SHA
    
    - name: Deploy to EKS
      run: |
        aws eks update-kubeconfig --name aws-monitoring-cluster --region us-west-2
        kubectl apply -f k8s/aws-app-deployment.yml
        kubectl apply -f k8s/aws-app-service.yml
        kubectl apply -f k8s/aws-app-monitoring.yml
```

</details>

### 🔧 **3-2. 애플리케이션 배포 매니페스트 생성**

<details>
<summary>📋 클릭하여 코드 복사</summary>

```bash
# 애플리케이션 배포 매니페스트 생성
mkdir -p k8s

# Deployment 매니페스트
cat > k8s/aws-app-deployment.yml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: aws-monitoring-app
  namespace: default
  labels:
    app: aws-monitoring-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: aws-monitoring-app
  template:
    metadata:
      labels:
        app: aws-monitoring-app
      annotations:
        prometheus.io/scrape: "true"
        prometheus.io/port: "3000"
        prometheus.io/path: "/metrics"
    spec:
      containers:
      - name: aws-monitoring-app
        image: nginx:latest
        ports:
        - containerPort: 80
        - containerPort: 3000
        env:
        - name: APP_NAME
          value: "aws-monitoring-app"
        - name: ENVIRONMENT
          value: "production"
        resources:
          requests:
            memory: "64Mi"
            cpu: "50m"
          limits:
            memory: "128Mi"
            cpu: "100m"
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
EOF
```

</details>

### 🔧 **3-3. 애플리케이션 배포 및 모니터링 확인**

<details>
<summary>📋 클릭하여 코드 복사</summary>

```bash
# 애플리케이션 배포
kubectl apply -f k8s/aws-app-deployment.yml
kubectl apply -f k8s/aws-app-service.yml
kubectl apply -f k8s/aws-app-monitoring.yml

# 배포 상태 확인
kubectl get pods -l app=aws-monitoring-app
kubectl get svc aws-monitoring-app-service

# Prometheus에서 애플리케이션 메트릭 확인
curl "http://localhost:9090/api/v1/query?query=up{job=\"aws-monitoring-app\"}"
```

</details>

**✅ Phase 3 완료 확인**:
- [ ] GitHub Actions CI/CD 파이프라인 구축
- [ ] AWS EKS 애플리케이션 자동 배포
- [ ] Application 모니터링 설정
- [ ] 실시간 애플리케이션 성능 모니터링

---

## ☁️ Phase 4: GCP 클러스터 Infrastructure/Platform 모니터링

### 📋 **Phase 4 개요**
- **목표**: GCP GKE 클러스터 구축 및 멀티 클라우드 통합 모니터링 완성
- **구성**: GCP GKE + Prometheus 스택 + Global 연동
- **예상 소요 시간**: 3-4시간

### 🔧 **4-1. GCP GKE 클러스터 생성**

<details>
<summary>📋 클릭하여 코드 복사</summary>

```bash
# GCP GKE 클러스터 생성
gcloud container clusters create gcp-monitoring-cluster \
  --zone=us-central1-a \
  --num-nodes=3 \
  --machine-type=e2-medium \
  --enable-autoscaling \
  --min-nodes=1 \
  --max-nodes=5 \
  --enable-autorepair \
  --enable-autoupgrade

# 클러스터 상태 확인
gcloud container clusters list
```

</details>

### 🔧 **4-2. GCP Prometheus 스택 배포**

<details>
<summary>📋 클릭하여 코드 복사</summary>

```bash
# kubectl 설정
gcloud container clusters get-credentials gcp-monitoring-cluster --zone=us-central1-a

# Helm 설치
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Prometheus 스택 설치
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

helm install prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --create-namespace \
  --set prometheus.prometheusSpec.retention=30d \
  --set grafana.adminPassword=admin123 \
  --wait
```

</details>

### 🔧 **4-3. Global Prometheus에 GCP 클러스터 연동**

<details>
<summary>📋 클릭하여 코드 복사</summary>

```bash
# GCP 클러스터의 Prometheus 서비스 엔드포인트 확인
kubectl get svc -n monitoring | grep prometheus-server

# Global Prometheus 설정에 GCP 클러스터 Federation 추가
cat >> /home/ubuntu/monitoring/prometheus/prometheus.yml << 'EOF'

  # GCP 클러스터 메트릭 수집 (Federation)
  - job_name: 'gcp-cluster-federation'
    scrape_interval: 30s
    honor_labels: true
    metrics_path: /federate
    params:
      'match[]':
        - '{job=~"kubernetes-.*"}'
        - '{job=~"kube-.*"}'
    static_configs:
      - targets: ['gcp-prometheus-endpoint:9090']
    basic_auth:
      username: 'prometheus'
      password: 'secure-password'
EOF

# Global Prometheus 재시작
cd /home/ubuntu/monitoring
docker-compose restart prometheus
```

</details>

**✅ Phase 4 완료 확인**:
- [ ] GCP GKE 클러스터가 정상적으로 생성됨
- [ ] Prometheus 스택이 클러스터에 배포됨
- [ ] Global Prometheus에서 GCP 클러스터 메트릭 수집 확인
- [ ] 멀티 클라우드 통합 모니터링 시스템 완성

---

## 🎯 **통합 모니터링 대시보드 구성**

### 📊 **Global Dashboard 설정**

<details>
<summary>📋 클릭하여 코드 복사</summary>

```bash
# 통합 모니터링 대시보드 생성
cat > /home/ubuntu/monitoring/dashboards/global-monitoring-dashboard.json << 'EOF'
{
  "dashboard": {
    "title": "Global Multi-Cloud Monitoring Dashboard",
    "panels": [
      {
        "title": "AWS Infrastructure Overview",
        "type": "stat",
        "targets": [
          {
            "expr": "up{job=~\"aws-.*\"}",
            "legendFormat": "AWS Services"
          }
        ]
      },
      {
        "title": "GCP Infrastructure Overview", 
        "type": "stat",
        "targets": [
          {
            "expr": "up{job=~\"gcp-.*\"}",
            "legendFormat": "GCP Services"
          }
        ]
      },
      {
        "title": "Cross-Cloud Resource Usage",
        "type": "graph",
        "targets": [
          {
            "expr": "100 - (avg(rate(node_cpu_seconds_total{mode=\"idle\"}[5m])) * 100)",
            "legendFormat": "CPU Usage %"
          },
          {
            "expr": "(1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100",
            "legendFormat": "Memory Usage %"
          }
        ]
      }
    ]
  }
}
EOF
```

</details>

### 🔍 **모니터링 쿼리 예시**

<details>
<summary>📋 클릭하여 코드 복사</summary>

```bash
# 통합 모니터링 쿼리 테스트
# 1. 전체 클러스터 상태 확인
curl "http://localhost:9090/api/v1/query?query=up"

# 2. AWS 클러스터 메트릭 확인
curl "http://localhost:9090/api/v1/query?query=up{cluster=\"aws-eks-cluster\"}"

# 3. GCP 클러스터 메트릭 확인  
curl "http://localhost:9090/api/v1/query?query=up{cluster=\"gcp-gke-cluster\"}"

# 4. 애플리케이션 메트릭 확인
curl "http://localhost:9090/api/v1/query?query=up{job=~\"aws-monitoring-app\"}"
```

</details>

---

## 🧹 **실습 정리 및 비용 최적화**

### 💰 **예상 비용 요약**

| 구성 요소 | AWS | GCP | 월 예상 비용 |
|-----------|-----|-----|-------------|
| **통합 모니터링 허브** | EC2 t3.medium | - | $30-40 |
| **AWS EKS 클러스터** | 3 nodes (t3.medium) | - | $150-200 |
| **GCP GKE 클러스터** | - | 3 nodes (e2-medium) | $100-150 |
| **데이터 전송** | - | - | $10-20 |
| **총 예상 비용** | | | **$290-410/월** |

### 🔧 **비용 최적화 방법**

<details>
<summary>📋 클릭하여 코드 복사</summary>

```bash
# 1. 클러스터 자동 스케일링 설정
kubectl apply -f - << 'EOF'
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: aws-cluster-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: aws-monitoring-app
  minReplicas: 1
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
EOF

# 2. 불필요한 리소스 정리
# AWS 리소스 정리
aws eks delete-cluster --name aws-monitoring-cluster --region us-west-2
aws ec2 terminate-instances --instance-id i-1234567890abcdef0

# GCP 리소스 정리  
gcloud container clusters delete gcp-monitoring-cluster --zone=us-central1-a
```

</details>

### 📊 **실습 완료 체크리스트**

**✅ Phase 1 완료**:
- [ ] AWS VM 통합 모니터링 허브 구축
- [ ] Global Prometheus + Grafana 정상 동작
- [ ] Node Exporter 메트릭 수집 확인

**✅ Phase 2 완료**:
- [ ] AWS EKS 클러스터 구축
- [ ] Infrastructure/Platform 모니터링 설정
- [ ] AWS 클러스터 메트릭 수집 확인

**✅ Phase 3 완료**:
- [ ] GitHub Actions CI/CD 파이프라인 구축
- [ ] AWS EKS 애플리케이션 배포
- [ ] Application 모니터링 설정

**✅ Phase 4 완료**:
- [ ] GCP GKE 클러스터 구축
- [ ] GCP Infrastructure/Platform 모니터링 설정
- [ ] GCP 클러스터 메트릭 수집 확인

**✅ 통합 모니터링 완료**:
- [ ] 멀티 클라우드 통합 모니터링 시스템 구축
- [ ] Global Dashboard에서 모든 환경 모니터링 확인
- [ ] 알림 규칙 및 대시보드 구성 완료

---

## 🎓 **학습 성과 및 다음 단계**

### 🏆 **달성한 학습 목표**
- ✅ **멀티 클라우드 환경** 이해 및 구축
- ✅ **통합 모니터링 시스템** 설계 및 구현
- ✅ **Infrastructure/Platform/Application** 3계층 모니터링
- ✅ **실제 운영 환경** 수준의 모니터링 시스템 구축

### 🚀 **다음 단계 학습 제안**
1. **고급 모니터링**: APM (Application Performance Monitoring) 도구 도입
2. **로그 분석**: ELK Stack 또는 Fluentd를 활용한 로그 분석 시스템
3. **보안 모니터링**: Falco, OPA Gatekeeper를 활용한 보안 모니터링
4. **ML 기반 모니터링**: Anomaly Detection 및 Predictive Monitoring

### 💡 **실무 적용 팁**
- **점진적 도입**: 단계별로 모니터링 범위 확장
- **팀 교육**: 모니터링 도구 사용법 및 대응 절차 교육
- **지속적 개선**: 메트릭 및 알림 규칙 지속적 최적화
- **문서화**: 모니터링 시스템 운영 가이드 작성

---

## 📚 **참고 자료 및 추가 학습**

### **공식 문서**
- [Prometheus 공식 문서](https://prometheus.io/docs/)
- [Grafana 공식 문서](https://grafana.com/docs/)
- [AWS EKS 가이드](https://docs.aws.amazon.com/eks/)
- [GCP GKE 가이드](https://cloud.google.com/kubernetes-engine/docs)

### **추가 실습 자료**
- [Kubernetes 모니터링 베스트 프랙티스](https://kubernetes.io/docs/tasks/debug-application-cluster/resource-usage-monitoring/)
- [멀티 클라우드 모니터링 전략](https://www.cncf.io/blog/2021/03/15/multi-cloud-monitoring-strategies/)

이제 **Cloud Intermediate 과정**의 학습자들이 이 실습 가이드를 따라하면서 **실제 멀티 클라우드 환경에서의 통합 모니터링 시스템**을 완전히 구축할 수 있습니다! 🎉