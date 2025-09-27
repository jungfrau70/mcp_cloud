# 📊 통합 모니터링 허브 구축 실습

> 📋 **실습 시간**: 90분  
> 📋 **난이도**: 중급  
> 📋 **선수 학습**: Docker, Prometheus, Grafana 기초  
> 📋 **실습 환경**: AWS VM 기반 Global Prometheus + Grafana

## 🎯 학습 목표

### 핵심 학습 목표
- **통합 모니터링**: 멀티 클라우드 환경을 위한 통합 모니터링 허브 구축
- **Global Prometheus**: 중앙 집중식 메트릭 수집 및 저장
- **Grafana 대시보드**: 시각화 및 알림 설정

### 실습 후 달성할 수 있는 능력
- ✅ AWS VM 기반 통합 모니터링 허브 구축
- ✅ Global Prometheus + Grafana 정상 동작
- ✅ Node Exporter를 통한 시스템 메트릭 수집
- ✅ 멀티 클라우드 모니터링 기반 환경 준비

### 예상 소요 시간
- **모니터링 환경 준비**: 15분
- **Global Prometheus 설정**: 25분
- **Grafana 설정**: 20분
- **Docker Compose 스택 실행**: 30분

---

## 🛠️ 실습 환경 준비

### 📁 실습 코드 및 자동화
- **실습 샘플 코드**: `/mcp_knowledge_base/cloud_intermediate/repos/samples/day1/monitoring-hub/`
- **자동화 스크립트**: `/mcp_knowledge_base/cloud_intermediate/repos/automation/day1/monitoring-hub-practice-automation.sh`
- **클라우드 스크립트**: `/mcp_knowledge_base/cloud_intermediate/repos/cloud-scripts/`

<details>
<summary>🚀 실습 환경 준비</summary>

#### 필수 도구
- **Docker**: 컨테이너 런타임
- **Docker Compose**: 컨테이너 오케스트레이션
- **curl**: HTTP 요청 테스트
- **jq**: JSON 데이터 처리

#### 환경 설정
```bash
# Docker 및 Docker Compose 설치 확인
sudo systemctl status docker
docker --version
docker-compose --version

# Docker 서비스 시작
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $USER
newgrp docker
```

</details>

<details>
<summary>🔧 1단계: 모니터링 환경 준비</summary>

#### 실습 디렉토리 생성
```bash
# 실습 디렉토리 생성
mkdir -p ~/cloud_intermediate/samples/day1/monitoring-hub
cd ~/cloud_intermediate/samples/day1/monitoring-hub

# 실습 샘플 코드 복사 (있는 경우)
cp -r /mcp_knowledge_base/cloud_intermediate/repos/samples/day1/monitoring-hub/* ./

# 모니터링 디렉토리 구조 생성
mkdir -p monitoring/{prometheus,grafana,alertmanager,dashboards}
cd monitoring
```

#### 실습 샘플과 동일한 구성 확인
```bash
# 실습 샘플 디렉토리 구조 확인
echo "=== 실습 샘플 디렉토리 구조 ==="
echo "실습 샘플: mcp_knowledge_base/cloud_intermediate/repos/samples/day1/monitoring-hub/"
echo "현재 디렉토리: $(pwd)"
echo "구성 파일: docker-compose.yml, prometheus.yml, alertmanager.yml"
```

</details>

<details>
<summary>🔧 2단계: Global Prometheus 설정</summary>

#### Prometheus 설정 파일 생성
```bash
# Prometheus 설정 파일 생성
cat > prometheus/prometheus.yml << 'EOF'
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

# Prometheus 설정 확인
echo "=== Prometheus 설정 확인 ==="
cat prometheus/prometheus.yml
```

</details>

<details>
<summary>🔧 3단계: Grafana 설정</summary>

#### Grafana 데이터소스 설정 생성
```bash
# Grafana 데이터소스 설정 생성
cat > grafana/datasources.yml << 'EOF'
apiVersion: 1

datasources:
  - name: Prometheus
    type: prometheus
    access: proxy
    url: http://prometheus:9090
    isDefault: true
    editable: true
    jsonData:
      httpMethod: POST
      manageAlerts: true
      prometheusType: Prometheus
      prometheusVersion: 2.40.0
      cacheLevel: 'High'
      disableRecordingRules: false
      incrementalQueryOverlapWindow: 10m
      queryTimeout: 60s
      timeInterval: 15s
EOF

# Grafana 대시보드 설정 생성
cat > grafana/dashboards.yml << 'EOF'
apiVersion: 1

providers:
  - name: 'default'
    orgId: 1
    folder: ''
    type: file
    disableDeletion: false
    updateIntervalSeconds: 10
    allowUiUpdates: true
    options:
      path: /var/lib/grafana/dashboards
EOF

# 기본 대시보드 JSON 생성
cat > dashboards/aws-vm-dashboard.json << 'EOF'
{
  "dashboard": {
    "id": null,
    "title": "AWS VM 모니터링",
    "tags": ["aws", "vm", "monitoring"],
    "timezone": "browser",
    "panels": [
      {
        "id": 1,
        "title": "CPU 사용률",
        "type": "stat",
        "targets": [
          {
            "expr": "100 - (avg by (instance) (irate(node_cpu_seconds_total{mode=\"idle\"}[5m])) * 100)",
            "refId": "A"
          }
        ],
        "gridPos": {"h": 8, "w": 12, "x": 0, "y": 0}
      },
      {
        "id": 2,
        "title": "메모리 사용률",
        "type": "stat",
        "targets": [
          {
            "expr": "100 * (1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes))",
            "refId": "A"
          }
        ],
        "gridPos": {"h": 8, "w": 12, "x": 12, "y": 0}
      }
    ],
    "time": {
      "from": "now-1h",
      "to": "now"
    },
    "refresh": "30s"
  }
}
EOF
```

</details>

<details>
<summary>🔧 4단계: Docker Compose 스택 실행</summary>

#### Docker Compose 파일 생성
```bash
# Docker Compose 파일 생성 (실습 샘플과 동일한 구성)
cat > docker-compose.yml << 'EOF'
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

# AlertManager 설정 생성
cat > alertmanager/alertmanager.yml << 'EOF'
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

#### 모니터링 스택 실행
```bash
# 모니터링 스택 실행
echo "=== 모니터링 스택 실행 ==="
docker-compose up -d

# 서비스 상태 확인
echo "=== 서비스 상태 확인 ==="
sleep 10
docker-compose ps

# 서비스 접근성 확인
echo "=== 서비스 접근성 확인 ==="
curl -s http://localhost:9090/api/v1/query?query=up | jq .
curl -s http://localhost:3000/api/health
curl -s http://localhost:9100/metrics | head -10
```

</details>

---

## 📚 참고 자료

### 유용한 명령어
```bash
# Docker Compose 관리
docker-compose up -d
docker-compose down
docker-compose ps
docker-compose logs

# Prometheus 쿼리
curl "http://localhost:9090/api/v1/query?query=up"
curl "http://localhost:9090/api/v1/query?query=node_cpu_seconds_total"

# Grafana 접속
# http://localhost:3000 (admin/admin123)
```

### 문제 해결
1. **Prometheus 시작 실패**
   - 설정 파일 문법 확인: `promtool check config prometheus.yml`
   - 포트 충돌 확인: `netstat -tlnp | grep 9090`

2. **Grafana 접속 불가**
   - 컨테이너 상태 확인: `docker-compose logs grafana`
   - 포트 확인: `docker-compose ps`

3. **Node Exporter 메트릭 없음**
   - 컨테이너 상태 확인: `docker-compose logs node-exporter`
   - 메트릭 엔드포인트 확인: `curl http://localhost:9100/metrics`

---

## 🧹 실습 정리

### 자동 정리
```bash
# Day1 모니터링 허브 실습 자동 정리
./mcp_knowledge_base/cloud_intermediate/repos/automation/day1/monitoring-hub-practice-automation.sh --cleanup
```

### 수동 정리
```bash
# 모니터링 스택 정리
docker-compose down

# 볼륨 정리
docker volume rm monitoring-hub_prometheus_data monitoring-hub_grafana_data

# 컨테이너 정리
docker system prune -a
```

### 정리 확인
- [ ] 모니터링 스택 정리 완료
- [ ] Docker 볼륨 정리 완료
- [ ] 포트 해제 확인
- [ ] 디스크 공간 정리 확인

---

## 🎯 학습 성과 확인

### 실습 완료 체크리스트
- [ ] AWS VM 통합 모니터링 허브 구축 완료
- [ ] Global Prometheus + Grafana 정상 동작 확인
- [ ] Node Exporter 메트릭 수집 확인
- [ ] 멀티 클라우드 모니터링 기반 환경 준비 완료
- [ ] AlertManager 설정 완료

### 다음 단계
- **Day2 CI/CD 파이프라인** 실습으로 진행
- **멀티 클라우드 모니터링** 확장 실습
- **고급 모니터링 설정** 및 **알림 구성**

---

**💡 궁금한 점이 있으시면 언제든 문의해주세요!**  
**문제가 발생하거나 도움이 필요하시면 실시간으로 지원해드리겠습니다.**