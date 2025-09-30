# 📊 멀티 클라우드 통합 모니터링 시스템

## 🎯 학습 목표

### 핵심 학습 목표
- **멀티 클라우드 VM 환경** 이해 및 통합 모니터링 시스템 구축
- **Infrastructure/Platform/Application** 3계층 모니터링 구현
- **AWS EC2 + GCP Compute Engine** 환경에서의 통합 모니터링 시스템 운영
- **VM 기반 실제 운영 환경** 수준의 모니터링 시스템 구축

### 실습 후 달성할 수 있는 능력
- ✅ 멀티 클라우드 VM 통합 모니터링 시스템 설계 및 구축
- ✅ Infrastructure/Platform/Application 3계층 모니터링 구현
- ✅ Global Dashboard를 통한 통합 시각화
- ✅ VM 기반 실제 운영 환경 수준의 모니터링 시스템 운영

### 예상 소요 시간
- **Phase 1**: 통합 모니터링 허브 구축 (2-3시간)
- **Phase 2**: AWS EC2 VM 모니터링 (2-3시간)
- **Phase 3**: AWS EC2 VM 애플리케이션 모니터링 (2-3시간)
- **Phase 4**: GCP Compute Engine VM 모니터링 (2-3시간)
- **전체 과정**: 8-12시간

---

## 🛠️ 실습 학습

### 📁 실습 코드 및 자동화
- **통합 시나리오**: `cloud_intermediate/통합모니터링시나리오.md`
- **실습 코드**: `cloud_intermediate/repo/practice/day2/monitoring-basics/`
- **자동화 스크립트**: `cloud_intermediate/repo/automation/day2/monitoring-stack.sh`
- **클라우드 스크립트**: `cloud_intermediate/tools/cloud/`

<details>
<summary>🚀 실습 환경 준비</summary>

#### 필수 도구
- **AWS CLI**: AWS 서비스 관리
- **GCP CLI**: GCP 서비스 관리
- **Docker & Docker Compose**: 컨테이너 환경
- **SSH**: VM 접속 도구
- **curl**: HTTP 요청 도구

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
      - prometheus/prometheus.yml:/etc/prometheus/prometheus.yml
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
      - alertmanager/alertmanager.yml:/etc/alertmanager/alertmanager.yml
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

## ☸️ Phase 2: AWS EC2 VM Infrastructure/Platform 모니터링

### 📋 **Phase 2 개요**
- **목표**: AWS EC2 VM 구축 및 Infrastructure/Platform 모니터링 설정
- **구성**: AWS EC2 + Docker + Prometheus 스택 + Global 연동
- **예상 소요 시간**: 3-4시간

### 🔧 **2-1. AWS EC2 VM 생성**

<details>
<summary>📋 클릭하여 코드 복사</summary>

```bash
# EC2 인스턴스 생성
aws ec2 run-instances \
  --image-id ami-0c02fb55956c7d316 \
  --instance-type t3.medium \
  --key-name aws-monitoring-key \
  --security-group-ids sg-12345678 \
  --subnet-id subnet-12345678 \
  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=aws-monitoring-vm}]' \
  --user-data file://user-data.sh

# 인스턴스 상태 확인
aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=aws-monitoring-vm" \
  --query 'Reservations[*].Instances[*].[InstanceId,State.Name,PublicIpAddress]' \
  --output table
```

</details>

### 🔧 **2-2. Docker 및 모니터링 스택 설치**

<details>
<summary>📋 클릭하여 코드 복사</summary>

```bash
# EC2 VM에 SSH 접속
ssh -i aws-monitoring-key.pem ubuntu@<EC2-PUBLIC-IP>

# Docker 설치
sudo apt-get update
sudo apt-get install -y docker.io docker-compose
sudo usermod -aG docker ubuntu
sudo systemctl enable docker
sudo systemctl start docker

# 모니터링 디렉토리 생성
mkdir -p /home/ubuntu/monitoring
cd /home/ubuntu/monitoring

# docker-compose.yml 생성
cat > docker-compose.yml << 'EOF'
version: '3.8'
services:
  prometheus:
    image: prom/prometheus:latest
    container_name: prometheus
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
      - prometheus_data:/prometheus
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
      - '--web.console.libraries=/etc/prometheus/console_libraries'
      - '--web.console.templates=/etc/prometheus/consoles'
      - '--storage.tsdb.retention.time=200h'
      - '--web.enable-lifecycle'
    restart: unless-stopped

  grafana:
    image: grafana/grafana:latest
    container_name: grafana
    ports:
      - "3000:3000"
    volumes:
      - grafana_data:/var/lib/grafana
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin123
    restart: unless-stopped

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
      - '--collector.filesystem.mount-points-exclude=^/(sys|proc|dev|host|etc)($$|/)'
    restart: unless-stopped

volumes:
  prometheus_data:
  grafana_data:
EOF

# Prometheus 설정 파일 생성
cat > prometheus.yml << 'EOF'
global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'node-exporter'
    static_configs:
      - targets: ['localhost:9100']
EOF

# 모니터링 스택 시작
docker-compose up -d
```

</details>

### 🔧 **2-3. Global Prometheus 연동 설정**

<details>
<summary>📋 클릭하여 코드 복사</summary>

```bash
# AWS VM의 Prometheus 엔드포인트 확인
curl -s http://localhost:9090/api/v1/targets | jq '.data.activeTargets[]'

# Global Prometheus 설정에 AWS VM Federation 추가
cat >> /home/ubuntu/monitoring/prometheus/prometheus.yml << 'EOF'

  # AWS VM 메트릭 수집 (Federation)
  - job_name: 'aws-vm-federation'
    scrape_interval: 30s
    honor_labels: true
    metrics_path: /federate
    params:
      'match[]':
        - '{job=~"node-exporter"}'
        - '{job=~"prometheus"}'
    static_configs:
      - targets: ['<AWS-VM-PUBLIC-IP>:9090']
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
- [ ] AWS EC2 VM이 정상적으로 생성됨
- [ ] Docker 및 모니터링 스택이 VM에 배포됨
- [ ] Global Prometheus에서 AWS VM 메트릭 수집 확인
- [ ] Infrastructure/Platform 모니터링 대시보드 구성

---

## 🚀 Phase 3: AWS EC2 VM Application 모니터링

### 📋 **Phase 3 개요**
- **목표**: GitHub Actions를 통한 AWS EC2 VM 애플리케이션 배포 및 Application 모니터링
- **구성**: GitHub Actions + Docker + Application 메트릭
- **예상 소요 시간**: 2-3시간

### 🔧 **3-1. GitHub Actions 워크플로우 생성**

<details>
<summary>📋 클릭하여 코드 복사</summary>

```yaml
# .github/workflows/deploy-aws-vm-app.yml
name: Deploy to AWS EC2 VM

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
    
    - name: Deploy to EC2 VM
      run: |
        # EC2 VM에 SSH 접속하여 애플리케이션 배포
        ssh -i aws-monitoring-key.pem ubuntu@${{ secrets.EC2_PUBLIC_IP }} << 'EOF'
        cd /home/ubuntu/apps
        docker pull $ECR_REGISTRY/$ECR_REPOSITORY:$GITHUB_SHA
        docker stop aws-monitoring-app || true
        docker rm aws-monitoring-app || true
        docker run -d --name aws-monitoring-app \
          -p 8080:80 \
          -p 3000:3000 \
          -e APP_NAME=aws-monitoring-app \
          -e ENVIRONMENT=production \
          $ECR_REGISTRY/$ECR_REPOSITORY:$GITHUB_SHA
        EOF
```

</details>

### 🔧 **3-2. 애플리케이션 Dockerfile 생성**

<details>
<summary>📋 클릭하여 코드 복사</summary>

```bash
# 애플리케이션 디렉토리 생성
mkdir -p app
cd app

# Dockerfile 생성
cat > Dockerfile << 'EOF'
FROM nginx:alpine

# 애플리케이션 파일 복사
COPY index.html /usr/share/nginx/html/
COPY nginx.conf /etc/nginx/nginx.conf

# 메트릭 수집을 위한 포트 노출
EXPOSE 80 3000

# 헬스체크 추가
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:80/health || exit 1

# 애플리케이션 시작
CMD ["nginx", "-g", "daemon off;"]
EOF

# nginx.conf 생성
cat > nginx.conf << 'EOF'
events {
    worker_connections 1024;
}

http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;
    
    # 메트릭 엔드포인트
    server {
        listen 3000;
        location /metrics {
            return 200 'app_requests_total{app="aws-monitoring-app"} 100\n';
            add_header Content-Type text/plain;
        }
    }
    
    # 메인 애플리케이션
    server {
        listen 80;
        root /usr/share/nginx/html;
        index index.html;
        
        location /health {
            return 200 'OK';
            add_header Content-Type text/plain;
        }
        
        location / {
            try_files $uri $uri/ =404;
        }
    }
}
EOF

# index.html 생성
cat > index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>AWS Monitoring App</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; }
        .container { max-width: 800px; margin: 0 auto; }
        .status { color: green; font-weight: bold; }
    </style>
</head>
<body>
    <div class="container">
        <h1>AWS EC2 VM Monitoring Application</h1>
        <p class="status">✅ Application is running successfully!</p>
        <p>Environment: Production</p>
        <p>Deployed on: AWS EC2 VM</p>
        <p>Monitoring: Prometheus + Grafana</p>
    </div>
</body>
</html>
EOF
```

</details>

### 🔧 **3-3. EC2 VM에 애플리케이션 배포**

<details>
<summary>📋 클릭하여 코드 복사</summary>

```bash
# EC2 VM에 SSH 접속
ssh -i aws-monitoring-key.pem ubuntu@<EC2-PUBLIC-IP>

# 애플리케이션 디렉토리 생성
mkdir -p /home/ubuntu/apps
cd /home/ubuntu/apps

# 애플리케이션 빌드 및 실행
docker build -t aws-monitoring-app:latest .
docker run -d --name aws-monitoring-app \
  -p 8080:80 \
  -p 3000:3000 \
  -e APP_NAME=aws-monitoring-app \
  -e ENVIRONMENT=production \
  aws-monitoring-app:latest

# 애플리케이션 상태 확인
docker ps
docker logs aws-monitoring-app

# 애플리케이션 접속 테스트
curl http://localhost:8080
curl http://localhost:3000/metrics
```

</details>

### 🔧 **3-4. Application 메트릭 수집 설정**

<details>
<summary>📋 클릭하여 코드 복사</summary>

```bash
# Prometheus 설정에 애플리케이션 메트릭 추가
cat >> /home/ubuntu/monitoring/prometheus.yml << 'EOF'

  # AWS VM 애플리케이션 메트릭 수집
  - job_name: 'aws-vm-app'
    scrape_interval: 15s
    static_configs:
      - targets: ['localhost:3000']
    metrics_path: /metrics
EOF

# Prometheus 재시작
cd /home/ubuntu/monitoring
docker-compose restart prometheus

# 메트릭 수집 확인
curl -s http://localhost:9090/api/v1/targets | jq '.data.activeTargets[] | select(.job == "aws-vm-app")'
```

</details>

**✅ Phase 3 완료 확인**:
- [ ] GitHub Actions 워크플로우가 정상적으로 실행됨
- [ ] AWS EC2 VM에 애플리케이션이 배포됨
- [ ] 애플리케이션 메트릭이 Prometheus에서 수집됨
- [ ] Application 모니터링 대시보드 구성
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

## ☁️ Phase 4: GCP Compute Engine VM Infrastructure/Platform 모니터링

### 📋 **Phase 4 개요**
- **목표**: GCP Compute Engine VM 구축 및 멀티 클라우드 통합 모니터링 완성
- **구성**: GCP Compute Engine + Docker + Prometheus 스택 + Global 연동
- **예상 소요 시간**: 3-4시간

### 🔧 **4-1. GCP Compute Engine VM 생성**

<details>
<summary>📋 클릭하여 코드 복사</summary>

```bash
# GCP Compute Engine VM 생성
gcloud compute instances create gcp-monitoring-vm \
  --zone=us-central1-a \
  --machine-type=e2-medium \
  --image-family=ubuntu-2004-lts \
  --image-project=ubuntu-os-cloud \
  --boot-disk-size=20GB \
  --boot-disk-type=pd-standard \
  --tags=monitoring-vm \
  --metadata=startup-script='#!/bin/bash
apt-get update
apt-get install -y docker.io docker-compose
usermod -aG docker ubuntu
systemctl enable docker
systemctl start docker'

# VM 상태 확인
gcloud compute instances list --filter="name=gcp-monitoring-vm"
```

</details>

### 🔧 **4-2. GCP VM에 Docker 및 모니터링 스택 설치**

<details>
<summary>📋 클릭하여 코드 복사</summary>

```bash
# GCP VM에 SSH 접속
gcloud compute ssh gcp-monitoring-vm --zone=us-central1-a

# 모니터링 디렉토리 생성
mkdir -p /home/ubuntu/monitoring
cd /home/ubuntu/monitoring

# docker-compose.yml 생성
cat > docker-compose.yml << 'EOF'
version: '3.8'
services:
  prometheus:
    image: prom/prometheus:latest
    container_name: prometheus
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
      - prometheus_data:/prometheus
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
      - '--web.console.libraries=/etc/prometheus/console_libraries'
      - '--web.console.templates=/etc/prometheus/consoles'
      - '--storage.tsdb.retention.time=200h'
      - '--web.enable-lifecycle'
    restart: unless-stopped

  grafana:
    image: grafana/grafana:latest
    container_name: grafana
    ports:
      - "3000:3000"
    volumes:
      - grafana_data:/var/lib/grafana
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin123
    restart: unless-stopped

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
      - '--collector.filesystem.mount-points-exclude=^/(sys|proc|dev|host|etc)($$|/)'
    restart: unless-stopped

volumes:
  prometheus_data:
  grafana_data:
EOF

# Prometheus 설정 파일 생성
cat > prometheus.yml << 'EOF'
global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'node-exporter'
    static_configs:
      - targets: ['localhost:9100']
EOF

# 모니터링 스택 시작
docker-compose up -d
```

</details>

### 🔧 **4-3. Global Prometheus에 GCP VM 연동**

<details>
<summary>📋 클릭하여 코드 복사</summary>

```bash
# GCP VM의 Prometheus 엔드포인트 확인
curl -s http://localhost:9090/api/v1/targets | jq '.data.activeTargets[]'

# Global Prometheus 설정에 GCP VM Federation 추가
cat >> /home/ubuntu/monitoring/prometheus/prometheus.yml << 'EOF'

  # GCP VM 메트릭 수집 (Federation)
  - job_name: 'gcp-vm-federation'
    scrape_interval: 30s
    honor_labels: true
    metrics_path: /federate
    params:
      'match[]':
        - '{job=~"node-exporter"}'
        - '{job=~"prometheus"}'
    static_configs:
      - targets: ['<GCP-VM-EXTERNAL-IP>:9090']
    basic_auth:
      username: 'prometheus'
      password: 'secure-password'
EOF

# Global Prometheus 재시작
cd /home/ubuntu/monitoring
docker-compose restart prometheus
```

</details>

### 🔧 **4-4. GCP VM 애플리케이션 배포**

<details>
<summary>📋 클릭하여 코드 복사</summary>

```bash
# GCP VM에 SSH 접속
gcloud compute ssh gcp-monitoring-vm --zone=us-central1-a

# 애플리케이션 디렉토리 생성
mkdir -p /home/ubuntu/apps
cd /home/ubuntu/apps

# 애플리케이션 빌드 및 실행
docker build -t gcp-monitoring-app:latest .
docker run -d --name gcp-monitoring-app \
  -p 8080:80 \
  -p 3000:3000 \
  -e APP_NAME=gcp-monitoring-app \
  -e ENVIRONMENT=production \
  gcp-monitoring-app:latest

# 애플리케이션 상태 확인
docker ps
docker logs gcp-monitoring-app

# 애플리케이션 접속 테스트
curl http://localhost:8080
curl http://localhost:3000/metrics
```

</details>

**✅ Phase 4 완료 확인**:
- [ ] GCP Compute Engine VM이 정상적으로 생성됨
- [ ] Docker 및 모니터링 스택이 VM에 배포됨
- [ ] Global Prometheus에서 GCP VM 메트릭 수집 확인
- [ ] 멀티 클라우드 통합 모니터링 완성

---

## 📊 통합 모니터링 대시보드 구성

### 📋 **통합 대시보드 개요**
- **목표**: AWS EC2 VM과 GCP Compute Engine VM의 통합 모니터링 대시보드 구성
- **구성**: Grafana + Prometheus + 멀티 클라우드 메트릭
- **예상 소요 시간**: 1-2시간

### 🔧 **Grafana 대시보드 설정**

<details>
<summary>📋 클릭하여 코드 복사</summary>

```bash
# Global Prometheus에 접속하여 Grafana 설정
# 브라우저에서 http://localhost:3000 접속
# admin / admin123 로그인

# Prometheus 데이터 소스 추가
# Configuration > Data Sources > Add data source
# URL: http://prometheus:9090
# Access: Server (default)
# Save & Test

# 멀티 클라우드 대시보드 생성
# Create > Import > Upload JSON file
# 또는 Dashboard ID: 1860 (Node Exporter Full) 사용
```

</details>

### 🔧 **알림 규칙 설정**

<details>
<summary>📋 클릭하여 코드 복사</summary>

```bash
# Prometheus 알림 규칙 생성
cat > /home/ubuntu/monitoring/prometheus/alerts.yml << 'EOF'
groups:
- name: vm-alerts
  rules:
  - alert: HighCPUUsage
    expr: 100 - (avg by(instance) (irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100) > 80
    for: 5m
    labels:
      severity: warning
    annotations:
      summary: "High CPU usage detected"
      description: "CPU usage is above 80% for more than 5 minutes"

  - alert: HighMemoryUsage
    expr: (1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100 > 80
    for: 5m
    labels:
      severity: warning
    annotations:
      summary: "High memory usage detected"
      description: "Memory usage is above 80% for more than 5 minutes"

  - alert: DiskSpaceLow
    expr: (1 - (node_filesystem_avail_bytes / node_filesystem_size_bytes)) * 100 > 80
    for: 5m
    labels:
      severity: critical
    annotations:
      summary: "Low disk space"
      description: "Disk space is above 80% for more than 5 minutes"
EOF

# Prometheus 설정에 알림 규칙 추가
cat >> /home/ubuntu/monitoring/prometheus/prometheus.yml << 'EOF'

rule_files:
  - "alerts.yml"

alerting:
  alertmanagers:
    - static_configs:
        - targets:
          - alertmanager:9093
EOF

# Prometheus 재시작
cd /home/ubuntu/monitoring
docker-compose restart prometheus
```

</details>

**✅ 통합 모니터링 완료 확인**:
- [ ] Grafana 대시보드가 정상적으로 구성됨
- [ ] AWS EC2 VM과 GCP Compute Engine VM 메트릭이 통합 표시됨
- [ ] 알림 규칙이 정상적으로 작동함
- [ ] 멀티 클라우드 모니터링 환경 완성
---

## 🧹 실습 정리

### 자동 정리
```bash
# Day2 실습 자동 정리
./mcp_knowledge_base/cloud_intermediate/repo/automation/day2/monitoring-stack.sh --cleanup
```

### 수동 정리
```bash
# AWS EC2 VM 정리
aws ec2 terminate-instances --instance-ids <INSTANCE-ID>

# GCP Compute Engine VM 정리
gcloud compute instances delete gcp-monitoring-vm --zone=us-central1-a --quiet

# 로컬 모니터링 스택 정리
cd /home/ubuntu/monitoring
docker-compose down -v
```

### 정리 확인
- [ ] AWS EC2 VM이 정상적으로 종료됨
- [ ] GCP Compute Engine VM이 정상적으로 삭제됨
- [ ] 로컬 모니터링 스택이 정상적으로 정리됨
- [ ] 모든 리소스가 정상적으로 정리됨

---

## 📚 참고 자료

### 유용한 명령어
```bash
# VM 상태 확인
aws ec2 describe-instances --filters "Name=tag:Name,Values=aws-monitoring-vm"
gcloud compute instances list --filter="name=gcp-monitoring-vm"

# Docker 컨테이너 관리
docker ps -a
docker logs <container-name>
docker exec -it <container-name> /bin/bash

# Prometheus 메트릭 확인
curl -s http://localhost:9090/api/v1/targets | jq '.data.activeTargets[]'
curl -s http://localhost:9090/api/v1/query?query=up
```

### 문제 해결
1. **VM 접속 불가**
   - 보안 그룹 설정 확인
   - SSH 키 파일 권한 확인
   - 방화벽 설정 확인

2. **Docker 컨테이너 실행 실패**
   - Docker 서비스 상태 확인
   - 포트 충돌 확인
   - 로그 확인

3. **Prometheus 메트릭 수집 실패**
   - 네트워크 연결 확인
   - 방화벽 설정 확인
   - 서비스 상태 확인

---

## 🎯 다음 단계

### Cloud Master 과정 준비
- **VM 기반 배포**: 실제 프로덕션 환경과 유사한 VM 기반 배포 경험
- **멀티 클라우드 모니터링**: AWS와 GCP의 통합 모니터링 환경 구축
- **자동화 도구**: CI/CD 파이프라인과 모니터링 자동화 도구 활용
- **실무 적용**: 실제 프로젝트에 적용 가능한 실무 경험

### 관련 문서
- [Day2 README](../README.md)
- [CI/CD 파이프라인](./cicd-pipeline.md)
- [클라우드 배포](./cloud-deployment.md)
- [통합 모니터링 시나리오](../../../통합모니터링시나리오.md)

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