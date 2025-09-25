# 📊 모니터링 기초

## 🎯 학습 목표

### 핵심 학습 목표
- **Prometheus + Grafana** 모니터링 스택 구축 및 활용
- **AWS CloudWatch** 로그 수집, 메트릭 모니터링, 알림 설정
- **GCP Cloud Monitoring** 메트릭 수집, 대시보드 구성, 알림 정책 설정

### 실습 후 달성할 수 있는 능력
- ✅ Prometheus + Grafana 모니터링 스택 구축
- ✅ AWS CloudWatch를 활용한 애플리케이션 모니터링
- ✅ GCP Cloud Monitoring을 활용한 시스템 모니터링
- ✅ 로그 기반 모니터링 및 알림 시스템 구축

### 예상 소요 시간
- **Prometheus + Grafana**: 120-150분
- **AWS CloudWatch**: 90-120분
- **GCP Cloud Monitoring**: 90-120분
- **전체 과정**: 5-6시간

---

## 🛠️ 실습 학습

### 📁 실습 코드 및 자동화
- **실습 샘플 코드**: `/mcp_knowledge_base/cloud_intermediate/repo/samples/day2/monitoring-basics/`
- **자동화 스크립트**: `/mcp_knowledge_base/cloud_intermediate/repo/scripts/monitoring-basics-practice.sh`
- **클라우드 스크립트**: `/mcp_knowledge_base/cloud_intermediate/repo/cloud-scripts/`

<details>
<summary>🚀 실습 환경 준비</summary>

#### 필수 도구
- **Docker & Docker Compose**: 컨테이너 환경
- **AWS CLI**: AWS 서비스 관리
- **GCP CLI**: GCP 서비스 관리
- **kubectl**: Kubernetes 클러스터 관리 ["선택사항"]

#### 환경 설정
```bash
# Docker 및 Docker Compose 확인
docker --version
docker-compose --version

# AWS CLI 설정 확인
aws --version
aws configure list

# GCP CLI 설정 확인
gcloud --version
gcloud auth list

# kubectl 설치 확인 ["선택사항"]
kubectl version --client
```

</details>

<details>
<summary>🔧 1단계: Prometheus + Grafana 모니터링 스택</summary>

#### Prometheus + Grafana 스택 구축
```bash
# 모니터링 디렉토리 생성
mkdir -p monitoring-stack/{prometheus,grafana}
cd monitoring-stack

# Prometheus 설정 파일 생성
cat > prometheus/prometheus.yml << 'EOF'
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
  
  - job_name: 'application'
    static_configs:
      - targets: ['application:3000']
    metrics_path: /metrics
    scrape_interval: 5s
EOF

# Grafana 데이터 소스 설정
cat > grafana/datasources.yml << 'EOF'
apiVersion: 1

datasources:
  - name: Prometheus
    type: prometheus
    access: proxy
    url: http://prometheus:9090
    isDefault: true
    editable: true
EOF

# Docker Compose 파일 생성
cat > docker-compose.yml << 'EOF'
version: '3.8'

services:
  # Prometheus
  prometheus:
    image: prom/prometheus:latest
    container_name: prometheus
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus/prometheus.yml:/etc/prometheus/prometheus.yml
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
      - '--web.enable-lifecycle'
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
    container_name: grafana
    ports:
      - "3000:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin
    volumes:
      - ./grafana/datasources.yml:/etc/grafana/provisioning/datasources/datasources.yml
    networks:
      - monitoring

  # 샘플 애플리케이션
  application:
    build: ../samples/day1/docker-advanced
    container_name: sample-app
    ports:
      - "3001:3000"
    networks:
      - monitoring

networks:
  monitoring:
    driver: bridge
EOF

# 모니터링 스택 실행
docker-compose up -d

# 서비스 상태 확인
docker-compose ps
```

#### Prometheus 메트릭 확인
```bash
# Prometheus 타겟 상태 확인
curl http://localhost:9090/api/v1/targets

# 메트릭 쿼리 테스트
curl "http://localhost:9090/api/v1/query?query=up"

# Prometheus 웹 UI 접속
echo "Prometheus: http://localhost:9090"
```

#### Grafana 대시보드 설정
```bash
# Grafana 접속 정보
echo "Grafana: http://localhost:3000 [admin/admin]"

# 대시보드 생성 [Node Exporter]
# 1. Grafana 웹 UI 접속
# 2. "+" > "Import" 클릭
# 3. Dashboard ID: 1860 [Node Exporter Full]
# 4. "Load" 클릭
# 5. Prometheus 데이터 소스 선택
# 6. "Import" 클릭
```

#### 애플리케이션 메트릭 확인
```bash
# 애플리케이션 메트릭 엔드포인트 확인
curl http://localhost:3001/metrics

# Prometheus에서 애플리케이션 메트릭 쿼리
curl "http://localhost:9090/api/v1/query?query=nodejs_heap_size_total_bytes"
```

</details>

<details>
<summary>🔧 2단계: AWS CloudWatch 모니터링</summary>

#### CloudWatch 로그 그룹 생성
```bash
# 로그 그룹 생성
aws logs create-log-group \
  --log-group-name /aws/ecs/myapp \
  --retention-in-days 30

# 로그 스트림 생성
aws logs create-log-stream \
  --log-group-name /aws/ecs/myapp \
  --log-stream-name myapp-stream

# 로그 이벤트 전송
aws logs put-log-events \
  --log-group-name /aws/ecs/myapp \
  --log-stream-name myapp-stream \
  --log-events timestamp=$[date +%s]000,message="Application started"
```

#### CloudWatch 메트릭 및 알람 설정
```bash
# 커스텀 메트릭 전송
aws cloudwatch put-metric-data \
  --namespace "MyApp/Performance" \
  --metric-data MetricName=ResponseTime,Value=150,Unit=Milliseconds

# 알람 생성
aws cloudwatch put-metric-alarm \
  --alarm-name "High CPU Usage" \
  --alarm-description "Alarm when CPU exceeds 80%" \
  --metric-name CPUUtilization \
  --namespace AWS/ECS \
  --statistic Average \
  --period 300 \
  --threshold 80 \
  --comparison-operator GreaterThanThreshold \
  --evaluation-periods 2 \
  --alarm-actions arn:aws:sns:us-west-2:123456789012:myapp-alerts

# SNS 토픽 생성
aws sns create-topic --name myapp-alerts

# SNS 구독 생성
aws sns subscribe \
  --topic-arn arn:aws:sns:us-west-2:123456789012:myapp-alerts \
  --protocol email \
  --notification-endpoint admin@example.com
```

#### CloudWatch 대시보드 생성
```json
{
  "widgets": [
    {
      "type": "metric",
      "x": 0,
      "y": 0,
      "width": 12,
      "height": 6,
      "properties": {
        "metrics": [
          ["AWS/ECS", "CPUUtilization", "ServiceName", "myapp-service", "ClusterName", "my-ecs-cluster"],
          [".", "MemoryUtilization", ".", ".", ".", "."]
        ],
        "view": "timeSeries",
        "stacked": false,
        "region": "us-west-2",
        "title": "ECS Service Metrics",
        "period": 300
      }
    },
    {
      "type": "log",
      "x": 0,
      "y": 6,
      "width": 12,
      "height": 6,
      "properties": {
        "query": "SOURCE '/aws/ecs/myapp' | fields @timestamp, @message\n| filter @message like /ERROR/\n| sort @timestamp desc\n| limit 20",
        "region": "us-west-2",
        "title": "Error Logs",
        "view": "table"
      }
    }
  ]
}
```

#### CloudWatch 대시보드 배포
```bash
# 대시보드 생성
aws cloudwatch put-dashboard \
  --dashboard-name "MyApp Dashboard" \
  --dashboard-body file://dashboard.json

# 대시보드 확인
aws cloudwatch get-dashboard --dashboard-name "MyApp Dashboard"
```

</details>

<details>
<summary>🔧 2단계: GCP Cloud Monitoring</summary>

#### Cloud Monitoring 메트릭 수집
```bash
# 커스텀 메트릭 생성
gcloud monitoring metrics-descriptors create \
  --config-from-file=metric-descriptor.yaml

# 메트릭 데이터 전송
gcloud monitoring time-series create \
  --config-from-file=time-series.yaml

# 알림 정책 생성
gcloud alpha monitoring policies create \
  --policy-from-file=alert-policy.yaml
```

#### Cloud Monitoring 대시보드 생성
```json
{
  "displayName": "MyApp Dashboard",
  "mosaicLayout": {
    "tiles": [
      {
        "width": 6,
        "height": 4,
        "widget": {
          "title": "CPU Usage",
          "xyChart": {
            "dataSets": [
              {
                "timeSeriesQuery": {
                  "timeSeriesFilter": {
                    "filter": "metric.type=\"compute.googleapis.com/instance/cpu/utilization\"",
                    "aggregation": {
                      "alignmentPeriod": "60s",
                      "perSeriesAligner": "ALIGN_MEAN"
                    }
                  }
                }
              }
            ]
          }
        }
      },
      {
        "width": 6,
        "height": 4,
        "widget": {
          "title": "Memory Usage",
          "xyChart": {
            "dataSets": [
              {
                "timeSeriesQuery": {
                  "timeSeriesFilter": {
                    "filter": "metric.type=\"compute.googleapis.com/instance/memory/utilization\"",
                    "aggregation": {
                      "alignmentPeriod": "60s",
                      "perSeriesAligner": "ALIGN_MEAN"
                    }
                  }
                }
              }
            ]
          }
        }
      }
    ]
  }
}
```

#### Cloud Monitoring 대시보드 배포
```bash
# 대시보드 생성
gcloud monitoring dashboards create \
  --config-from-file=dashboard.json

# 대시보드 목록 확인
gcloud monitoring dashboards list
```

#### Cloud Logging 설정
```bash
# 로그 기반 메트릭 생성
gcloud logging metrics create myapp_errors \
  --description="Count of error logs" \
  --log-filter="severity>=ERROR"

# 로그 기반 알림 정책 생성
gcloud alpha monitoring policies create \
  --policy-from-file=log-based-alert-policy.yaml
```

</details>

<details>
<summary>🔧 3단계: 통합 모니터링 시스템</summary>

#### Prometheus + Grafana 설정 ["선택사항"]
```yaml
# prometheus-config.yaml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'myapp'
    static_configs:
      - targets: ['myapp:3000']
    metrics_path: /metrics
    scrape_interval: 5s

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
```

#### Grafana 대시보드 설정
```json
{
  "dashboard": {
    "title": "MyApp Monitoring",
    "panels": [
      {
        "title": "Request Rate",
        "type": "graph",
        "targets": [
          {
            "expr": "rate[http_requests_total[5m]]",
            "legendFormat": "{{method}} {{endpoint}}"
          }
        ]
      },
      {
        "title": "Response Time",
        "type": "graph",
        "targets": [
          {
            "expr": "histogram_quantile[0.95, rate[http_request_duration_seconds_bucket[5m]]]",
            "legendFormat": "95th percentile"
          }
        ]
      }
    ]
  }
}
```

#### 모니터링 자동화
```bash
# 모니터링 스크립트
#!/bin/bash

# AWS CloudWatch 메트릭 수집
aws cloudwatch get-metric-statistics \
  --namespace AWS/ECS \
  --metric-name CPUUtilization \
  --dimensions Name=ServiceName,Value=myapp-service \
  --start-time $[date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%S] \
  --end-time $[date -u +%Y-%m-%dT%H:%M:%S] \
  --period 300 \
  --statistics Average

# GCP Cloud Monitoring 메트릭 수집
gcloud monitoring time-series list \
  --filter="metric.type=\"compute.googleapis.com/instance/cpu/utilization\"" \
  --interval="1h"

# 알림 상태 확인
aws cloudwatch describe-alarms --state-value ALARM
gcloud alpha monitoring policies list --filter="enabled=true"
```

</details>

<details>
<summary>🔧 4단계: 로그 분석 및 알림</summary>

#### CloudWatch Insights 쿼리
```sql
-- 에러 로그 분석
fields @timestamp, @message
| filter @message like /ERROR/
| sort @timestamp desc
| limit 100

-- 응답 시간 분석
fields @timestamp, @message
| filter @message like /response_time/
| stats avg[response_time] by bin[5m]

-- 사용자 활동 분석
fields @timestamp, @message
| filter @message like /user_activity/
| stats count() by user_id
```

#### Cloud Logging 쿼리
```sql
-- 에러 로그 분석
resource.type="gce_instance"
severity>=ERROR
timestamp>="2023-01-01T00:00:00Z"

-- 응답 시간 분석
resource.type="gce_instance"
jsonPayload.response_time>1000
timestamp>="2023-01-01T00:00:00Z"

-- 사용자 활동 분석
resource.type="gce_instance"
jsonPayload.event="user_login"
timestamp>="2023-01-01T00:00:00Z"
```

#### 알림 정책 설정
```yaml
# AWS CloudWatch 알림 정책
displayName: "High Error Rate"
conditions:
  - displayName: "Error rate > 5%"
    conditionThreshold:
      filter: "metric.type=\"custom.googleapis.com/error_rate\""
      comparison: COMPARISON_GREATER_THAN
      thresholdValue: 0.05
      duration: "300s"
notificationChannels:
  - "projects/my-project/notificationChannels/1234567890123456789"
```

</details>

---

## 📚 참고 자료

### 유용한 명령어
```bash
# AWS CloudWatch 명령어
aws logs describe-log-groups
aws logs describe-log-streams --log-group-name /aws/ecs/myapp
aws cloudwatch list-metrics --namespace AWS/ECS
aws cloudwatch describe-alarms

# GCP Cloud Monitoring 명령어
gcloud monitoring metrics-descriptors list
gcloud monitoring time-series list
gcloud alpha monitoring policies list
gcloud monitoring dashboards list

# 로그 분석 명령어
aws logs start-query --log-group-name /aws/ecs/myapp --start-time $[date -d '1 hour ago' +%s] --end-time $[date +%s] --query-string "fields @timestamp, @message | filter @message like /ERROR/"
gcloud logging read "resource.type=\"gce_instance\" AND severity>=ERROR" --limit=50
```

### 문제 해결
1. **CloudWatch 로그 수집 실패**
   - IAM 권한 확인
   - 로그 그룹 존재 여부 확인
   - 네트워크 연결 상태 확인

2. **Cloud Monitoring 메트릭 수집 실패**
   - API 활성화 확인
   - 권한 설정 확인
   - 메트릭 타입 확인

3. **알림 전송 실패**
   - SNS 토픽 설정 확인
   - 이메일 구독 확인
   - 알림 정책 설정 확인

---

## 🧹 실습 정리

### 자동 정리
```bash
# 모니터링 기초 실습 자동 정리
./mcp_knowledge_base/cloud_intermediate/repo/scripts/monitoring-basics-practice.sh --cleanup
```

### 수동 정리
```bash
# AWS CloudWatch 리소스 정리
aws logs delete-log-group --log-group-name /aws/ecs/myapp
aws cloudwatch delete-alarms --alarm-names "High CPU Usage"
aws cloudwatch delete-dashboards --dashboard-names "MyApp Dashboard"
aws sns delete-topic --topic-arn arn:aws:sns:us-west-2:123456789012:myapp-alerts

# GCP Cloud Monitoring 리소스 정리
gcloud alpha monitoring policies delete <policy-id>
gcloud monitoring dashboards delete <dashboard-id>
gcloud logging metrics delete myapp_errors
```

### 정리 확인
- [ ] AWS CloudWatch 리소스 정리 완료
- [ ] GCP Cloud Monitoring 리소스 정리 완료
- [ ] 알림 정책 정리 완료
- [ ] 대시보드 정리 완료

---

## 🔗 관련 자료

### 📚 실습 가이드
- ["CI/CD 파이프라인"][cicd-pipeline.md]
- ["클라우드 배포"][cloud-deployment.md]

### 🛠️ 설치 가이드
- ["AWS CLI 설정"][_setup_wsl/install-aws-cli-wsl.sh]
- ["GCP CLI 설정"][_setup_wsl/install-gcp-cli-wsl.sh]

### 🏠 네비게이션
<div align="center">

["← 이전: 클라우드 배포"][cloud-deployment.md] | 
["📚 전체 커리큘럼"][../../../curriculum.md] | 
["🏠 학습 경로로 돌아가기"][../../../index.md] | 
["다음: Cloud Master 과정 →"][../../../cloud_master/README.md]

</div>
