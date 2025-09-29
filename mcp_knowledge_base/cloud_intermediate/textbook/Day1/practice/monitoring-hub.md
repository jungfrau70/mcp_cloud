# 📊 통합 모니터링 허브 구축

> 📋 **실습 시간**: 90분  
> 📋 **난이도**: 중급  
> 📋 **선수 학습**: Docker 기초, Kubernetes 기초, 클라우드 컨테이너 서비스  
> 📋 **실습 환경**: AWS VM, Prometheus, Grafana, Node Exporter

## 🎯 학습 목표

### 핵심 학습 목표
- **Prometheus**: 메트릭 수집 및 저장 시스템 구축
- **Grafana**: 데이터 시각화 및 대시보드 생성
- **Node Exporter**: 시스템 메트릭 수집 설정
- **AlertManager**: 알림 시스템 구성
- **통합 모니터링**: 멀티 클라우드 환경 모니터링 전략
- **외부 접속**: AWS 보안 그룹 설정 및 외부 접속 테스트
- **자동 정리**: 통합 삭제 기능을 통한 리소스 정리

### 실습 후 달성할 수 있는 능력
- ✅ Prometheus 서버 설치 및 설정
- ✅ Grafana 대시보드 생성 및 설정
- ✅ Node Exporter를 통한 시스템 메트릭 수집
- ✅ AlertManager 알림 시스템 구성
- ✅ 통합 모니터링 대시보드 구축
- ✅ AWS 보안 그룹 자동 설정 및 외부 접속 테스트
- ✅ 통합 삭제 기능을 통한 모든 리소스 자동 정리

### 예상 소요 시간
- **Prometheus 설치**: 30분
- **Grafana 설치**: 30분
- **Node Exporter 설정**: 15분
- **AlertManager 설정**: 15분

---

## 🛠️ 실습 환경 준비

### 📁 실습 코드 및 자동화
- **실습 샘플 코드**: `/cloud_intermediate/repo/samples/day1/monitoring-hub/`
- **자동화 스크립트**: `/cloud_intermediate/repo/automation/day1/day1-practice.sh`
- **모니터링 스크립트**: `/cloud_intermediate/repo/monitoring-scripts/`

<details>
<summary>🚀 실습 환경 준비</summary>

#### 필수 도구
- **Docker**: 컨테이너 런타임
- **Docker Compose**: 멀티 컨테이너 관리
- **curl**: HTTP 요청 테스트
- **jq**: JSON 데이터 처리

#### 환경 설정
```bash
# Docker 설치 확인
docker --version
docker-compose --version

# 시스템 리소스 확인
free -h
df -h
top -n 1

# 네트워크 포트 확인
netstat -tlnp | grep -E "(9090|3000|9093|9100)"
```

</details>

---

## 🔧 1단계: Prometheus 설치 및 설정

### 📋 Step 1-1: Prometheus 설정 파일 생성

#### 실습 디렉토리 생성
```bash
# 실습 디렉토리 생성
mkdir -p day1-monitoring-hub
cd day1-monitoring-hub

# Prometheus 설정 디렉토리 생성
mkdir -p prometheus
cd prometheus
```

#### Prometheus 설정 파일 생성
```bash
# prometheus.yml 생성
cat > prometheus.yml << 'EOF'
global:
  scrape_interval: 15s
  evaluation_interval: 15s
  external_labels:
    cluster: 'cloud-intermediate'
    environment: 'learning'

rule_files:
  - "rules/*.yml"

alerting:
  alertmanagers:
    - static_configs:
        - targets:
          - alertmanager:9093

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']
    scrape_interval: 5s
    metrics_path: '/metrics'

  - job_name: 'node-exporter'
    static_configs:
      - targets: ['node-exporter:9100']
    scrape_interval: 15s
    metrics_path: '/metrics'

  - job_name: 'grafana'
    static_configs:
      - targets: ['grafana:3000']
    scrape_interval: 30s
    metrics_path: '/metrics'

  - job_name: 'alertmanager'
    static_configs:
      - targets: ['alertmanager:9093']
    scrape_interval: 30s
    metrics_path: '/metrics'

  - job_name: 'pushgateway'
    static_configs:
      - targets: ['pushgateway:9091']
    scrape_interval: 30s
    metrics_path: '/metrics'
EOF
```

#### Prometheus 규칙 파일 생성
```bash
# 규칙 디렉토리 생성
mkdir -p rules

# CPU 사용률 알람 규칙
cat > rules/cpu-alerts.yml << 'EOF'
groups:
- name: cpu-alerts
  rules:
  - alert: HighCPUUsage
    expr: 100 - (avg by(instance) (irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100) > 80
    for: 5m
    labels:
      severity: warning
    annotations:
      summary: "High CPU usage detected"
      description: "CPU usage is above 80% for more than 5 minutes on {{ $labels.instance }}"

  - alert: CriticalCPUUsage
    expr: 100 - (avg by(instance) (irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100) > 95
    for: 2m
    labels:
      severity: critical
    annotations:
      summary: "Critical CPU usage detected"
      description: "CPU usage is above 95% for more than 2 minutes on {{ $labels.instance }}"
EOF
```

#### 메모리 사용률 알람 규칙
```bash
# 메모리 사용률 알람 규칙
cat > rules/memory-alerts.yml << 'EOF'
groups:
- name: memory-alerts
  rules:
  - alert: HighMemoryUsage
    expr: (1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100 > 80
    for: 5m
    labels:
      severity: warning
    annotations:
      summary: "High memory usage detected"
      description: "Memory usage is above 80% for more than 5 minutes on {{ $labels.instance }}"

  - alert: CriticalMemoryUsage
    expr: (1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100 > 95
    for: 2m
    labels:
      severity: critical
    annotations:
      summary: "Critical memory usage detected"
      description: "Memory usage is above 95% for more than 2 minutes on {{ $labels.instance }}"
EOF
```

#### 디스크 사용률 알람 규칙
```bash
# 디스크 사용률 알람 규칙
cat > rules/disk-alerts.yml << 'EOF'
groups:
- name: disk-alerts
  rules:
  - alert: HighDiskUsage
    expr: (1 - (node_filesystem_avail_bytes / node_filesystem_size_bytes)) * 100 > 80
    for: 5m
    labels:
      severity: warning
    annotations:
      summary: "High disk usage detected"
      description: "Disk usage is above 80% for more than 5 minutes on {{ $labels.instance }}"

  - alert: CriticalDiskUsage
    expr: (1 - (node_filesystem_avail_bytes / node_filesystem_size_bytes)) * 100 > 95
    for: 2m
    labels:
      severity: critical
    annotations:
      summary: "Critical disk usage detected"
      description: "Disk usage is above 95% for more than 2 minutes on {{ $labels.instance }}"
EOF
```

### 📋 Step 1-2: Prometheus Docker 컨테이너 실행

#### Prometheus Docker 실행
```bash
# Prometheus 컨테이너 실행
docker run -d \
  --name prometheus \
  --network monitoring \
  -p 9090:9090 \
  -v $(pwd)/prometheus.yml:/etc/prometheus/prometheus.yml \
  -v $(pwd)/rules:/etc/prometheus/rules \
  prom/prometheus:latest \
  --config.file=/etc/prometheus/prometheus.yml \
  --storage.tsdb.path=/prometheus \
  --web.console.libraries=/etc/prometheus/console_libraries \
  --web.console.templates=/etc/prometheus/consoles \
  --web.enable-lifecycle

# Prometheus 상태 확인
curl -s http://localhost:9090/api/v1/status/config | jq
curl -s http://localhost:9090/api/v1/targets | jq
```

#### Prometheus 메트릭 확인
```bash
# Prometheus 메트릭 확인
curl -s http://localhost:9090/metrics | head -20

# 특정 메트릭 확인
curl -s "http://localhost:9090/api/v1/query?query=up" | jq
curl -s "http://localhost:9090/api/v1/query?query=node_cpu_seconds_total" | jq
```

---

## 🔧 2단계: Grafana 설치 및 설정

### 📋 Step 2-1: Grafana 설정 파일 생성

#### Grafana 설정 디렉토리 생성
```bash
# Grafana 설정 디렉토리 생성
cd ../grafana
mkdir -p grafana
cd grafana
```

#### Grafana 설정 파일 생성
```bash
# grafana.ini 생성
cat > grafana.ini << 'EOF'
[server]
http_port = 3000
root_url = http://localhost:3000/

[security]
admin_user = admin
admin_password = admin123

[database]
type = sqlite3
path = grafana.db

[log]
mode = console
level = info

[alerting]
enabled = true

[unified_alerting]
enabled = true
EOF
```

#### Grafana 데이터 소스 설정
```bash
# datasources.yml 생성
cat > datasources.yml << 'EOF'
apiVersion: 1

datasources:
  - name: Prometheus
    type: prometheus
    access: proxy
    url: http://prometheus:9090
    isDefault: true
    editable: true
EOF
```

### 📋 Step 2-2: Grafana Docker 컨테이너 실행

#### Grafana Docker 실행
```bash
# Grafana 컨테이너 실행
docker run -d \
  --name grafana \
  --network monitoring \
  -p 3000:3000 \
  -v $(pwd)/grafana.ini:/etc/grafana/grafana.ini \
  -v $(pwd)/datasources.yml:/etc/grafana/provisioning/datasources/datasources.yml \
  grafana/grafana:latest

# Grafana 상태 확인
curl -s http://localhost:3000/api/health | jq
```

#### Grafana 로그인 및 설정
```bash
# Grafana 접속 정보
echo "Grafana URL: http://localhost:3000"
echo "Username: admin"
echo "Password: admin123"

# Grafana API 테스트
curl -u admin:admin123 http://localhost:3000/api/org | jq
```

---

## 🔧 3단계: Node Exporter 설정

### 📋 Step 3-1: Node Exporter Docker 컨테이너 실행

#### Node Exporter Docker 실행
```bash
# Node Exporter 컨테이너 실행
docker run -d \
  --name node-exporter \
  --network monitoring \
  -p 9100:9100 \
  -v /proc:/host/proc:ro \
  -v /sys:/host/sys:ro \
  -v /:/rootfs:ro \
  prom/node-exporter:latest \
  --path.procfs=/host/proc \
  --path.sysfs=/host/sys \
  --collector.filesystem.mount-points-exclude=^/(sys|proc|dev|host|etc)($|/)

# Node Exporter 상태 확인
curl -s http://localhost:9100/metrics | head -20
```

#### Node Exporter 메트릭 확인
```bash
# Node Exporter 메트릭 확인
curl -s http://localhost:9100/metrics | grep -E "(node_cpu_seconds_total|node_memory_MemTotal_bytes|node_filesystem_size_bytes)"

# 특정 메트릭 확인
curl -s "http://localhost:9090/api/v1/query?query=node_cpu_seconds_total" | jq
curl -s "http://localhost:9090/api/v1/query?query=node_memory_MemTotal_bytes" | jq
```

---

## 🔧 4단계: AlertManager 설정

### 📋 Step 4-1: AlertManager 설정 파일 생성

#### AlertManager 설정 디렉토리 생성
```bash
# AlertManager 설정 디렉토리 생성
cd ../alertmanager
mkdir -p alertmanager
cd alertmanager
```

#### AlertManager 설정 파일 생성
```bash
# alertmanager.yml 생성
cat > alertmanager.yml << 'EOF'
global:
  smtp_smarthost: 'localhost:587'
  smtp_from: 'alertmanager@example.com'

route:
  group_by: ['alertname']
  group_wait: 10s
  group_interval: 10s
  repeat_interval: 1h
  receiver: 'web.hook'

receivers:
- name: 'web.hook'
  webhook_configs:
  - url: 'http://localhost:5001/'

inhibit_rules:
  - source_match:
      severity: 'critical'
    target_match:
      severity: 'warning'
    equal: ['alertname', 'dev', 'instance']
EOF
```

### 📋 Step 4-2: AlertManager Docker 컨테이너 실행

#### AlertManager Docker 실행
```bash
# AlertManager 컨테이너 실행
docker run -d \
  --name alertmanager \
  --network monitoring \
  -p 9093:9093 \
  -v $(pwd)/alertmanager.yml:/etc/alertmanager/alertmanager.yml \
  prom/alertmanager:latest \
  --config.file=/etc/alertmanager/alertmanager.yml \
  --storage.path=/alertmanager

# AlertManager 상태 확인
curl -s http://localhost:9093/api/v1/status | jq
```

#### AlertManager 알람 확인
```bash
# AlertManager 알람 확인
curl -s http://localhost:9093/api/v1/alerts | jq
```

---

## 🔧 5단계: Docker Compose 통합 설정

### 📋 Step 5-1: Docker Compose 파일 생성

#### 통합 Docker Compose 파일 생성
```bash
# 상위 디렉토리로 이동
cd ../..

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
      - ./prometheus/prometheus.yml:/etc/prometheus/prometheus.yml
      - ./prometheus/rules:/etc/prometheus/rules
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
      - '--web.console.libraries=/etc/prometheus/console_libraries'
      - '--web.console.templates=/etc/prometheus/consoles'
      - '--web.enable-lifecycle'
    networks:
      - monitoring

  grafana:
    image: grafana/grafana:latest
    container_name: grafana
    ports:
      - "3000:3000"
    volumes:
      - ./grafana/grafana.ini:/etc/grafana/grafana.ini
      - ./grafana/datasources.yml:/etc/grafana/provisioning/datasources/datasources.yml
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin123
    networks:
      - monitoring

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
      - '--path.sysfs=/host/sys'
      - '--collector.filesystem.mount-points-exclude=^/(sys|proc|dev|host|etc)($|/)'
    networks:
      - monitoring

  alertmanager:
    image: prom/alertmanager:latest
    container_name: alertmanager
    ports:
      - "9093:9093"
    volumes:
      - ./alertmanager/alertmanager.yml:/etc/alertmanager/alertmanager.yml
    command:
      - '--config.file=/etc/alertmanager/alertmanager.yml'
      - '--storage.path=/alertmanager'
    networks:
      - monitoring

  pushgateway:
    image: prom/pushgateway:latest
    container_name: pushgateway
    ports:
      - "9091:9091"
    networks:
      - monitoring

networks:
  monitoring:
    driver: bridge
EOF
```

### 📋 Step 5-2: 통합 모니터링 스택 실행

#### Docker Compose 실행
```bash
# Docker 네트워크 생성
docker network create monitoring

# Docker Compose 실행
docker-compose up -d

# 서비스 상태 확인
docker-compose ps
```

#### 서비스 상태 확인
```bash
# 모든 서비스 상태 확인
docker-compose ps

# 서비스 로그 확인
docker-compose logs prometheus
docker-compose logs grafana
docker-compose logs node-exporter
docker-compose logs alertmanager
```

---

## 🔧 6단계: Grafana 대시보드 생성

### 📋 Step 6-1: 기본 대시보드 생성

#### Grafana 대시보드 JSON 생성
```bash
# 대시보드 디렉토리 생성
mkdir -p grafana/dashboards

# 시스템 모니터링 대시보드 생성
cat > grafana/dashboards/system-dashboard.json << 'EOF'
{
  "dashboard": {
    "id": null,
    "title": "System Monitoring Dashboard",
    "tags": ["system", "monitoring"],
    "style": "dark",
    "timezone": "browser",
    "panels": [
      {
        "id": 1,
        "title": "CPU Usage",
        "type": "graph",
        "targets": [
          {
            "expr": "100 - (avg by(instance) (irate(node_cpu_seconds_total{mode=\"idle\"}[5m])) * 100)",
            "legendFormat": "CPU Usage %"
          }
        ],
        "yAxes": [
          {
            "label": "CPU Usage %",
            "min": 0,
            "max": 100
          }
        ],
        "xAxes": [
          {
            "type": "time"
          }
        ]
      },
      {
        "id": 2,
        "title": "Memory Usage",
        "type": "graph",
        "targets": [
          {
            "expr": "(1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100",
            "legendFormat": "Memory Usage %"
          }
        ],
        "yAxes": [
          {
            "label": "Memory Usage %",
            "min": 0,
            "max": 100
          }
        ],
        "xAxes": [
          {
            "type": "time"
          }
        ]
      },
      {
        "id": 3,
        "title": "Disk Usage",
        "type": "graph",
        "targets": [
          {
            "expr": "(1 - (node_filesystem_avail_bytes / node_filesystem_size_bytes)) * 100",
            "legendFormat": "Disk Usage %"
          }
        ],
        "yAxes": [
          {
            "label": "Disk Usage %",
            "min": 0,
            "max": 100
          }
        ],
        "xAxes": [
          {
            "type": "time"
          }
        ]
      }
    ],
    "time": {
      "from": "now-1h",
      "to": "now"
    },
    "refresh": "5s"
  }
}
EOF
```

### 📋 Step 6-2: Grafana 대시보드 가져오기

#### Grafana API를 통한 대시보드 가져오기
```bash
# Grafana 대시보드 가져오기
curl -X POST \
  -H "Content-Type: application/json" \
  -u admin:admin123 \
  -d @grafana/dashboards/system-dashboard.json \
  http://localhost:3000/api/dashboards/db

# 대시보드 목록 확인
curl -u admin:admin123 http://localhost:3000/api/search?type=dash-db | jq
```

---

## 🔧 7단계: 알람 테스트

### 📋 Step 7-1: 알람 규칙 테스트

#### CPU 부하 생성 (알람 테스트용)
```bash
# CPU 부하 생성 (주의: 실제 환경에서는 사용하지 마세요)
stress --cpu 2 --timeout 300s &

# CPU 사용률 확인
top -n 1 | grep "Cpu(s)"

# Prometheus에서 CPU 사용률 확인
curl -s "http://localhost:9090/api/v1/query?query=100 - (avg by(instance) (irate(node_cpu_seconds_total{mode=\"idle\"}[5m])) * 100)" | jq
```

#### 알람 상태 확인
```bash
# Prometheus 알람 확인
curl -s http://localhost:9090/api/v1/alerts | jq

# AlertManager 알람 확인
curl -s http://localhost:9093/api/v1/alerts | jq
```

### 📋 Step 7-2: 알람 해제

#### CPU 부하 중지
```bash
# CPU 부하 중지
pkill stress

# CPU 사용률 확인
top -n 1 | grep "Cpu(s)"
```

---

## 📚 참고 자료

### 유용한 명령어
```bash
# Prometheus 관리
curl -s http://localhost:9090/api/v1/status/config | jq
curl -s http://localhost:9090/api/v1/targets | jq
curl -s http://localhost:9090/api/v1/query?query=up | jq

# Grafana 관리
curl -u admin:admin123 http://localhost:3000/api/org | jq
curl -u admin:admin123 http://localhost:3000/api/datasources | jq

# Node Exporter 관리
curl -s http://localhost:9100/metrics | grep node_cpu_seconds_total

# AlertManager 관리
curl -s http://localhost:9093/api/v1/status | jq
curl -s http://localhost:9093/api/v1/alerts | jq
```

### 문제 해결
1. **Prometheus 시작 실패**
   - 설정 파일 확인: `docker logs prometheus`
   - 포트 충돌 확인: `netstat -tlnp | grep 9090`

2. **Grafana 접속 불가**
   - 컨테이너 상태 확인: `docker logs grafana`
   - 포트 확인: `netstat -tlnp | grep 3000`

3. **Node Exporter 메트릭 없음**
   - 컨테이너 상태 확인: `docker logs node-exporter`
   - 메트릭 확인: `curl -s http://localhost:9100/metrics`

4. **AlertManager 알람 없음**
   - 설정 파일 확인: `docker logs alertmanager`
   - 알람 규칙 확인: `curl -s http://localhost:9090/api/v1/rules`

---

## 🌐 외부 접속 및 보안 설정

### AWS 보안 그룹 자동 설정
```bash
# 외부 접속을 위한 보안 그룹 자동 설정
cd /home/ec2-user/mcp-cloud-workspace/mcp_cloud/cloud_intermediate/repo/samples/day1
./external-access-test.sh
```

### 외부 접속 URL 생성
```bash
# 외부 IP 자동 감지 및 URL 생성
EXTERNAL_IP=$(curl -s https://ipinfo.io/ip)
echo "🌐 외부에서 접속 가능한 모니터링 URL:"
echo "   - Prometheus: http://$EXTERNAL_IP:9090"
echo "   - Grafana: http://$EXTERNAL_IP:3000 (admin/admin)"
echo "   - AlertManager: http://$EXTERNAL_IP:9093"
echo "   - Node Exporter: http://$EXTERNAL_IP:9100/metrics"
```

### 외부 접속 테스트
```bash
# 모든 모니터링 서비스 외부 접속 테스트
curl -f http://3.38.192.99:9090/api/v1/status/config && echo "Prometheus: OK"
curl -f http://3.38.192.99:3000/api/health && echo "Grafana: OK"
curl -f http://3.38.192.99:9093/api/v1/status && echo "AlertManager: OK"
curl -f http://3.38.192.99:9100/metrics && echo "Node Exporter: OK"
```

---

## 🧹 실습 정리

### 통합 삭제 (자동 정리)
```bash
# 모든 Day1 실습 리소스 통합 삭제
cd /home/ec2-user/mcp-cloud-workspace/mcp_cloud/cloud_intermediate/repo/automation/day1
./day1-practice.sh
# 메뉴에서 "6. 실습 환경 정리" 선택

# 또는 직접 통합 삭제 스크립트 실행
cd /home/ec2-user/mcp-cloud-workspace/mcp_cloud/cloud_intermediate/repo/samples/day1
./unified-cleanup.sh
```

### 통합 삭제 기능
- **Docker 컨테이너 정리**: 모든 실습 컨테이너 중지 및 삭제
- **Docker 이미지 정리**: 사용하지 않는 이미지 삭제
- **Docker 네트워크 정리**: 생성된 네트워크 삭제
- **Docker 볼륨 정리**: 사용하지 않는 볼륨 삭제
- **설정 파일 정리**: 생성된 설정 파일 삭제
- **Kubernetes 리소스 정리**: 배포된 K8s 리소스 삭제
- **클라우드 리소스 정리**: AWS/GCP 리소스 정리

### 수동 정리
```bash
# Docker Compose 정리
docker-compose down

# Docker 네트워크 정리
docker network rm monitoring

# Docker 볼륨 정리
docker volume prune -f

# 설정 파일 정리
rm -rf prometheus grafana alertmanager
```

### 정리 확인
- [ ] Docker Compose 서비스 중지 완료
- [ ] Docker 네트워크 정리 완료
- [ ] Docker 볼륨 정리 완료
- [ ] 설정 파일 정리 완료

---

## 🎯 학습 성과 확인

### 실습 완료 체크리스트
- [ ] Prometheus 서버 설치 및 설정 완료
- [ ] Grafana 대시보드 생성 및 설정 완료
- [ ] Node Exporter 시스템 메트릭 수집 완료
- [ ] AlertManager 알림 시스템 구성 완료
- [ ] 통합 모니터링 대시보드 구축 완료

### 다음 단계
- **Day 2 실습**으로 진행: CI/CD 및 고급 클라우드 배포
- **멀티 클라우드 모니터링** 전략 수립
- **고급 모니터링** 기법 학습

---

**💡 통합 모니터링 허브를 통해 멀티 클라우드 환경의 통합 모니터링 전략을 수립하세요!**  
**문제가 발생하거나 도움이 필요하시면 실시간으로 지원해드리겠습니다.**