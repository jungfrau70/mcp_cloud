# 🏗️ 통합 모니터링 허브 구축

## 🎯 학습 목표

### 핵심 학습 목표
- **멀티 클라우드 환경**을 위한 통합 모니터링 허브 구축
- **AWS VM 기반** Global Prometheus + Grafana 설정
- **Docker Compose**를 활용한 모니터링 스택 구성
- **실제 운영 환경** 수준의 모니터링 기반 환경 준비

### 실습 후 달성할 수 있는 능력
- ✅ AWS VM 기반 통합 모니터링 허브 구축
- ✅ Global Prometheus + Grafana 정상 동작
- ✅ Node Exporter를 통한 시스템 메트릭 수집
- ✅ 멀티 클라우드 모니터링 기반 환경 준비

### 예상 소요 시간
- **AWS VM 설정**: 30-45분
- **모니터링 스택 구성**: 60-90분
- **연결 및 테스트**: 30-45분
- **전체 과정**: 2-3시간

---

## 🛠️ 실습 학습

### 📁 실습 코드 및 자동화
- **통합 시나리오**: `cloud_intermediate/통합모니터링시나리오.md`
- **실습 코드**: `cloud_intermediate/samples/day1/monitoring-hub/`
- **자동화 스크립트**: `cloud_intermediate/scripts/monitoring-stack.sh`
- **클라우드 스크립트**: `cloud_intermediate/cloud-scripts/`

<details>
<summary>🚀 실습 환경 준비</summary>

#### 필수 도구
- **AWS CLI**: AWS 서비스 관리
- **Docker & Docker Compose**: 컨테이너 환경
- **SSH 클라이언트**: AWS VM 접속

#### 환경 설정
```bash
# AWS CLI 설정 확인
aws --version
aws configure list

# Docker 환경 확인
docker --version
docker-compose --version

# AWS 계정 설정 확인
aws sts get-caller-identity
```

#### 클라우드 계정 설정
```bash
# AWS 계정 설정
aws sts get-caller-identity

# AWS 리전 설정
aws configure set region us-west-2
```

</details>

---

## 🏗️ Phase 1: 통합 모니터링 허브 구축

### 📋 **Phase 1 개요**
- **목표**: AWS VM에 통합 모니터링 허브 구축
- **구성**: Global Prometheus + Grafana + AlertManager + Node Exporter
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

aws ec2 authorize-security-group-ingress \
  --group-id sg-12345678 \
  --protocol tcp \
  --port 9093 \
  --cidr 0.0.0.0/0

aws ec2 authorize-security-group-ingress \
  --group-id sg-12345678 \
  --protocol tcp \
  --port 9091 \
  --cidr 0.0.0.0/0
```

</details>

### 🔧 **1-4. SSH 접속 및 환경 설정**

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

### 🔧 **1-5. Prometheus 설정 파일 생성**

<details>
<summary>📋 클릭하여 코드 복사</summary>

```bash
# Prometheus 설정 파일 생성
cat > /home/ubuntu/monitoring/prometheus/prometheus.yml << 'EOF'
global:
  scrape_interval: 15s
  external_labels:
    environment: 'production'
    region: 'global'

scrape_configs:
  # AWS VM 로컬 메트릭 수집
  - job_name: 'aws-vm-local'
    static_configs:
      - targets: ['node-exporter:9100']
    scrape_interval: 15s

  # Push Gateway 메트릭 수집
  - job_name: 'pushgateway'
    static_configs:
      - targets: ['pushgateway:9091']
    honor_labels: true
    scrape_interval: 5s

  # GCP 클러스터 메트릭 수집 (Federation) - 나중에 추가
  - job_name: 'gcp-cluster-federation'
    scrape_interval: 30s
    honor_labels: true
    metrics_path: /federate
    params:
      'match[]':
        - '{job=~"gcp-.*"}'
    static_configs:
      - targets: ['gcp-prometheus.example.com:9090']
    basic_auth:
      username: 'prometheus'
      password: 'secure-password'

  # AWS 클러스터 메트릭 수집 (Federation) - 나중에 추가
  - job_name: 'aws-cluster-federation'
    scrape_interval: 30s
    honor_labels: true
    metrics_path: /federate
    params:
      'match[]':
        - '{job=~"aws-.*"}'
    static_configs:
      - targets: ['aws-prometheus.example.com:9090']
    basic_auth:
      username: 'prometheus'
      password: 'secure-password'
EOF
```

</details>

### 🔧 **1-6. AlertManager 설정 파일 생성**

<details>
<summary>📋 클릭하여 코드 복사</summary>

```bash
# AlertManager 설정 파일 생성
cat > /home/ubuntu/monitoring/alertmanager/alertmanager.yml << 'EOF'
global:
  smtp_smarthost: 'localhost:587'
  smtp_from: 'alerts@example.com'

route:
  group_by: ['alertname']
  group_wait: 10s
  group_interval: 10s
  repeat_interval: 1h
  receiver: 'web.hook'

receivers:
- name: 'web.hook'
  webhook_configs:
  - url: 'http://127.0.0.1:5001/'

- name: 'email'
  email_configs:
  - to: 'admin@example.com'
    subject: 'Alert: {{ .GroupLabels.alertname }}'
    body: |
      {{ range .Alerts }}
      Alert: {{ .Annotations.summary }}
      Description: {{ .Annotations.description }}
      {{ end }}
EOF
```

</details>

### 🔧 **1-7. Docker Compose 파일 생성**

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

### 🔧 **1-8. 모니터링 스택 실행**

<details>
<summary>📋 클릭하여 코드 복사</summary>

```bash
# 모니터링 스택 실행
cd /home/ubuntu/monitoring
docker-compose up -d

# 서비스 상태 확인
docker-compose ps

# 로그 확인
docker-compose logs prometheus
docker-compose logs grafana
```

</details>

### 🔧 **1-9. 접속 정보 확인**

<details>
<summary>📋 클릭하여 코드 복사</summary>

```bash
# Public IP 확인
PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)

# 접속 정보 출력
echo "=== 모니터링 스택 접속 정보 ==="
echo "Grafana: http://$PUBLIC_IP:3000 (admin/admin123)"
echo "Prometheus: http://$PUBLIC_IP:9090"
echo "AlertManager: http://$PUBLIC_IP:9093"
echo "Push Gateway: http://$PUBLIC_IP:9091"
echo "Node Exporter: http://$PUBLIC_IP:9100"
```

</details>

### 🔧 **1-10. 서비스 상태 확인**

<details>
<summary>📋 클릭하여 코드 복사</summary>

```bash
# Prometheus 타겟 확인
curl "http://localhost:9090/api/v1/targets" | jq '.data.activeTargets[] | {job: .labels.job, health: .health}'

# Grafana 헬스 체크
curl "http://localhost:3000/api/health"

# Node Exporter 메트릭 확인
curl "http://localhost:9100/metrics" | head -20
```

</details>

---

## 🧪 **연결 및 테스트**

### 🔍 **Prometheus 쿼리 테스트**

<details>
<summary>📋 클릭하여 코드 복사</summary>

```bash
# 기본 메트릭 쿼리 테스트
curl "http://localhost:9090/api/v1/query?query=up"

# CPU 사용률 쿼리
curl "http://localhost:9090/api/v1/query?query=100 - (avg(rate(node_cpu_seconds_total{mode=\"idle\"}[5m])) * 100)"

# 메모리 사용률 쿼리
curl "http://localhost:9090/api/v1/query?query=(1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100"

# 디스크 사용률 쿼리
curl "http://localhost:9090/api/v1/query?query=(1 - (node_filesystem_avail_bytes / node_filesystem_size_bytes)) * 100"
```

</details>

### 📊 **Grafana 대시보드 설정**

<details>
<summary>📋 클릭하여 코드 복사</summary>

```bash
# 기본 대시보드 JSON 생성
cat > /home/ubuntu/monitoring/dashboards/basic-dashboard.json << 'EOF'
{
  "dashboard": {
    "title": "AWS VM Basic Monitoring",
    "panels": [
      {
        "title": "System Overview",
        "type": "stat",
        "targets": [
          {
            "expr": "up",
            "legendFormat": "System Status"
          }
        ]
      },
      {
        "title": "CPU Usage",
        "type": "graph",
        "targets": [
          {
            "expr": "100 - (avg(rate(node_cpu_seconds_total{mode=\"idle\"}[5m])) * 100)",
            "legendFormat": "CPU Usage %"
          }
        ]
      },
      {
        "title": "Memory Usage",
        "type": "graph",
        "targets": [
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

---

## 🧹 **실습 정리**

### 🔧 **자동 정리**

<details>
<summary>📋 클릭하여 코드 복사</summary>

```bash
# 모니터링 스택 중지
cd /home/ubuntu/monitoring
docker-compose down

# 볼륨 정리 (선택사항)
docker-compose down -v

# AWS 리소스 정리
aws ec2 terminate-instances --instance-id i-1234567890abcdef0
aws ec2 release-address --allocation-id eipalloc-12345678
```

</details>

### 📊 **수동 정리**

<details>
<summary>📋 클릭하여 코드 복사</summary>

```bash
# Docker 컨테이너 정리
docker stop $(docker ps -aq)
docker rm $(docker ps -aq)

# Docker 이미지 정리
docker rmi $(docker images -q)

# 모니터링 디렉토리 정리
sudo rm -rf /home/ubuntu/monitoring
```

</details>

### ✅ **정리 확인**

- [ ] 모니터링 스택이 정상적으로 중지됨
- [ ] AWS EC2 인스턴스가 종료됨
- [ ] Elastic IP가 해제됨
- [ ] 불필요한 리소스가 정리됨

---

## 🎓 **학습 성과 및 다음 단계**

### 🏆 **달성한 학습 목표**
- ✅ **AWS VM 기반** 통합 모니터링 허브 구축
- ✅ **Global Prometheus + Grafana** 정상 동작
- ✅ **Node Exporter**를 통한 시스템 메트릭 수집
- ✅ **멀티 클라우드 모니터링** 기반 환경 준비

### 🚀 **다음 단계 학습 제안**
1. **Day2**: AWS 클러스터 Infrastructure/Platform 모니터링
2. **Day2**: AWS Application 모니터링
3. **Day2**: GCP 클러스터 통합 모니터링
4. **고급**: APM, 로그 분석, 보안 모니터링

### 💡 **실무 적용 팁**
- **점진적 구축**: 단계별로 모니터링 범위 확장
- **자동화**: Infrastructure as Code로 모니터링 환경 관리
- **문서화**: 모니터링 시스템 운영 가이드 작성
- **팀 교육**: 모니터링 도구 사용법 교육

---

## 📚 **참고 자료**

### **공식 문서**
- [Prometheus 공식 문서](https://prometheus.io/docs/)
- [Grafana 공식 문서](https://grafana.com/docs/)
- [AWS EC2 가이드](https://docs.aws.amazon.com/ec2/)
- [Docker Compose 가이드](https://docs.docker.com/compose/)

### **추가 실습 자료**
- [Prometheus 쿼리 예제](https://prometheus.io/docs/prometheus/latest/querying/examples/)
- [Grafana 대시보드 템플릿](https://grafana.com/grafana/dashboards/)

이제 **Cloud Intermediate Day1**의 학습자들이 이 실습 가이드를 따라하면서 **멀티 클라우드 환경을 위한 통합 모니터링 허브**를 구축할 수 있습니다! 🎉
