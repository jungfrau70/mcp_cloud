# 모니터링 시스템 구축 실습

<details>
<summary>📋 목차</summary>

1. [🎯 학습 목표](#-학습-목표)
2. [📚 실습 개요](#-실습-개요)
3. [🔧 실습 환경 준비](#-실습-환경-준비)
4. [☁️ AWS CloudWatch 고급 설정](#-aws-cloudwatch-고급-설정)
5. [☁️ GCP Cloud Monitoring 설정](#-gcp-cloud-monitoring-설정)
6. [🐳 Prometheus + Grafana 설정](#-prometheus--grafana-설정)
7. [📊 ELK Stack 로깅 시스템](#-elk-stack-로깅-시스템)
8. [📚 문제 해결 및 참고 자료](#-문제-해결-및-참고-자료)

</details>

---

## 🎯 학습 목표

<details>
<summary>📖 이번 실습에서 배우게 될 내용</summary>

### 핵심 학습 목표
- **CloudWatch 고급 설정** 커스텀 메트릭, 대시보드, 알람 구성
- **Cloud Monitoring 설정** GCP 통합 모니터링 시스템
- **Prometheus + Grafana** 오픈소스 모니터링 스택
- **ELK Stack** 로그 수집, 분석, 시각화

### 실습 후 달성할 수 있는 능력
- ✅ 종합적인 모니터링 시스템 구축
- ✅ 커스텀 메트릭 및 알람 설정
- ✅ 로그 수집 및 분석 시스템 구성
- ✅ 모니터링 대시보드 구축

### 예상 소요 시간
- **AWS CloudWatch**: 90-120분
- **GCP Cloud Monitoring**: 90-120분
- **Prometheus + Grafana**: 120-150분
- **ELK Stack**: 90-120분
- **전체 과정**: 6-8시간

</details>

---

## 📚 실습 개요

<details>
<summary>📖 실습 시나리오</summary>

### 프로젝트 개요
**E-commerce 웹 애플리케이션**의 종합적인 모니터링 시스템을 구축합니다.

### 모니터링 요구사항
- **인프라 모니터링**: CPU, 메모리, 네트워크, 디스크
- **애플리케이션 모니터링**: 응답 시간, 에러율, 처리량
- **비즈니스 모니터링**: 사용자 수, 매출, 전환율
- **로그 모니터링**: 에러 로그, 액세스 로그, 보안 로그

### 구현할 구성 요소
1. **메트릭 수집**: CloudWatch, Prometheus
2. **로그 수집**: ELK Stack, CloudWatch Logs
3. **시각화**: Grafana, CloudWatch 대시보드
4. **알림**: SNS, Slack, Email

</details>

---

## 🔧 실습 환경 준비

<details>
<summary>📋 필수 도구 및 계정</summary>

### 필수 계정
- **AWS 계정**: Free Tier (CloudWatch 실습용)
- **GCP 계정**: $300 크레딧 (Cloud Monitoring 실습용)
- **Slack 워크스페이스**: 알림 테스트용

### 필수 도구
```bash
# AWS CLI 설정 확인
aws --version
aws configure list

# GCP CLI 설정 확인
gcloud --version
gcloud auth list

# kubectl 설정 확인
kubectl version --client

# Docker 설정 확인
docker --version
docker-compose --version
```

### 환경 변수 설정
```bash
# AWS 설정
export AWS_DEFAULT_REGION=ap-northeast-2
export AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

# GCP 설정
export GCP_PROJECT_ID=my-project-123456
export GCP_REGION=asia-northeast3

# Slack 설정
export SLACK_WEBHOOK_URL=https://hooks.slack.com/services/YOUR/SLACK/WEBHOOK
```

</details>

---

## ☁️ AWS CloudWatch 고급 설정

<details>
<summary>📖 CloudWatch 모니터링 계층</summary>

### 모니터링 계층
- **인프라 메트릭**: EC2, RDS, ELB, ECS
- **애플리케이션 메트릭**: 커스텀 메트릭, 로그 기반 메트릭
- **비즈니스 메트릭**: 사용자 정의 비즈니스 메트릭
- **로그 분석**: CloudWatch Logs, Log Insights

### CloudWatch 구성 요소
- **메트릭**: 시계열 데이터
- **대시보드**: 시각화
- **알람**: 임계값 기반 알림
- **로그**: 로그 수집 및 분석

</details>

<details>
<summary>🔧 1단계: 커스텀 메트릭 설정</summary>

### 커스텀 메트릭 전송
```bash
# 커스텀 메트릭 전송 스크립트
cat > send-custom-metrics.sh << 'EOF'
#!/bin/bash

# 애플리케이션 메트릭 전송
aws cloudwatch put-metric-data \
    --namespace "MyApp/ECS" \
    --metric-data MetricName=RequestCount,Value=100,Unit=Count,Timestamp=$(date -u +%Y-%m-%dT%H:%M:%S.000Z)

# 응답 시간 메트릭 전송
aws cloudwatch put-metric-data \
    --namespace "MyApp/ECS" \
    --metric-data MetricName=ResponseTime,Value=150,Unit=Milliseconds,Timestamp=$(date -u +%Y-%m-%dT%H:%M:%S.000Z)

# 에러율 메트릭 전송
aws cloudwatch put-metric-data \
    --namespace "MyApp/ECS" \
    --metric-data MetricName=ErrorRate,Value=0.05,Unit=Percent,Timestamp=$(date -u +%Y-%m-%dT%H:%M:%S.000Z)

# 활성 사용자 수 메트릭 전송
aws cloudwatch put-metric-data \
    --namespace "MyApp/ECS" \
    --metric-data MetricName=ActiveUsers,Value=1250,Unit=Count,Timestamp=$(date -u +%Y-%m-%dT%H:%M:%S.000Z)

echo "Custom metrics sent successfully"
EOF

chmod +x send-custom-metrics.sh
./send-custom-metrics.sh
```

### 메트릭 확인
```bash
# 커스텀 메트릭 목록 확인
aws cloudwatch list-metrics \
    --namespace "MyApp/ECS" \
    --query 'Metrics[].{MetricName:MetricName,Namespace:Namespace}'

# 메트릭 통계 확인
aws cloudwatch get-metric-statistics \
    --namespace "MyApp/ECS" \
    --metric-name RequestCount \
    --start-time $(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%S) \
    --end-time $(date -u +%Y-%m-%dT%H:%M:%S) \
    --period 300 \
    --statistics Sum,Average,Maximum
```

</details>

<details>
<summary>🔧 2단계: CloudWatch 대시보드 생성</summary>

### 대시보드 생성
```bash
# CloudWatch 대시보드 생성
aws cloudwatch put-dashboard \
    --dashboard-name "MyApp-Production-Dashboard" \
    --dashboard-body '{
        "widgets": [
            {
                "type": "metric",
                "x": 0,
                "y": 0,
                "width": 12,
                "height": 6,
                "properties": {
                    "metrics": [
                        ["AWS/EC2", "CPUUtilization", "InstanceId", "i-1234567890abcdef0"],
                        ["AWS/EC2", "NetworkIn", "InstanceId", "i-1234567890abcdef0"],
                        ["AWS/EC2", "NetworkOut", "InstanceId", "i-1234567890abcdef0"]
                    ],
                    "period": 300,
                    "stat": "Average",
                    "region": "ap-northeast-2",
                    "title": "EC2 Metrics",
                    "yAxis": {
                        "left": {
                            "min": 0,
                            "max": 100
                        }
                    }
                }
            },
            {
                "type": "metric",
                "x": 12,
                "y": 0,
                "width": 12,
                "height": 6,
                "properties": {
                    "metrics": [
                        ["MyApp/ECS", "RequestCount"],
                        ["MyApp/ECS", "ResponseTime"],
                        ["MyApp/ECS", "ErrorRate"]
                    ],
                    "period": 300,
                    "stat": "Average",
                    "region": "ap-northeast-2",
                    "title": "Application Metrics"
                }
            },
            {
                "type": "log",
                "x": 0,
                "y": 6,
                "width": 24,
                "height": 6,
                "properties": {
                    "query": "SOURCE \"/aws/ecs/my-app\" | fields @timestamp, @message\n| filter @message like /ERROR/\n| sort @timestamp desc\n| limit 20",
                    "region": "ap-northeast-2",
                    "title": "Error Logs",
                    "view": "table"
                }
            }
        ]
    }'

echo "Dashboard created successfully"
```

### 대시보드 확인
```bash
# 대시보드 목록 확인
aws cloudwatch list-dashboards \
    --query 'DashboardEntries[].{DashboardName:DashboardName,CreationDate:CreationDate}'

# 대시보드 상세 정보 확인
aws cloudwatch get-dashboard \
    --dashboard-name "MyApp-Production-Dashboard"
```

</details>

<details>
<summary>🔧 3단계: CloudWatch 알람 설정</summary>

### SNS 토픽 생성
```bash
# SNS 토픽 생성
SNS_TOPIC_ARN=$(aws sns create-topic \
    --name my-app-alerts \
    --query 'TopicArn' \
    --output text)

echo "SNS Topic ARN: $SNS_TOPIC_ARN"

# SNS 구독 생성 (Email)
aws sns subscribe \
    --topic-arn $SNS_TOPIC_ARN \
    --protocol email \
    --notification-endpoint admin@example.com

# SNS 구독 생성 (Slack)
aws sns subscribe \
    --topic-arn $SNS_TOPIC_ARN \
    --protocol https \
    --notification-endpoint $SLACK_WEBHOOK_URL
```

### CloudWatch 알람 생성
```bash
# CPU 사용률 알람
aws cloudwatch put-metric-alarm \
    --alarm-name "High CPU Utilization" \
    --alarm-description "Alarm when CPU exceeds 80%" \
    --metric-name CPUUtilization \
    --namespace AWS/EC2 \
    --statistic Average \
    --period 300 \
    --threshold 80.0 \
    --comparison-operator GreaterThanThreshold \
    --evaluation-periods 2 \
    --alarm-actions $SNS_TOPIC_ARN \
    --ok-actions $SNS_TOPIC_ARN

# 메모리 사용률 알람
aws cloudwatch put-metric-alarm \
    --alarm-name "High Memory Utilization" \
    --alarm-description "Alarm when Memory exceeds 85%" \
    --metric-name MemoryUtilization \
    --namespace AWS/EC2 \
    --statistic Average \
    --period 300 \
    --threshold 85.0 \
    --comparison-operator GreaterThanThreshold \
    --evaluation-periods 2 \
    --alarm-actions $SNS_TOPIC_ARN

# 에러율 알람
aws cloudwatch put-metric-alarm \
    --alarm-name "High Error Rate" \
    --alarm-description "Alarm when Error Rate exceeds 5%" \
    --metric-name ErrorRate \
    --namespace MyApp/ECS \
    --statistic Average \
    --period 300 \
    --threshold 5.0 \
    --comparison-operator GreaterThanThreshold \
    --evaluation-periods 2 \
    --alarm-actions $SNS_TOPIC_ARN

# 응답 시간 알람
aws cloudwatch put-metric-alarm \
    --alarm-name "High Response Time" \
    --alarm-description "Alarm when Response Time exceeds 1000ms" \
    --metric-name ResponseTime \
    --namespace MyApp/ECS \
    --statistic Average \
    --period 300 \
    --threshold 1000.0 \
    --comparison-operator GreaterThanThreshold \
    --evaluation-periods 2 \
    --alarm-actions $SNS_TOPIC_ARN

echo "CloudWatch alarms created"
```

### 알람 상태 확인
```bash
# 알람 목록 확인
aws cloudwatch describe-alarms \
    --query 'MetricAlarms[].{AlarmName:AlarmName,StateValue:StateValue,StateReason:StateReason}'

# 알람 상태 변경 테스트
aws cloudwatch set-alarm-state \
    --alarm-name "High CPU Utilization" \
    --state-value ALARM \
    --state-reason "Testing alarm state"
```

</details>

<details>
<summary>🔧 4단계: CloudWatch Logs 설정</summary>

### 로그 그룹 생성
```bash
# 로그 그룹 생성
aws logs create-log-group \
    --log-group-name /ecs/my-app \
    --retention-in-days 30

# 로그 스트림 생성
aws logs create-log-stream \
    --log-group-name /ecs/my-app \
    --log-stream-name my-app-stream

echo "Log group and stream created"
```

### 로그 필터 생성
```bash
# 에러 로그 필터
aws logs put-metric-filter \
    --log-group-name /ecs/my-app \
    --filter-name ErrorCount \
    --filter-pattern "ERROR" \
    --metric-transformations metricName=ErrorCount,metricNamespace=MyApp/Logs,metricValue=1

# 경고 로그 필터
aws logs put-metric-filter \
    --log-group-name /ecs/my-app \
    --filter-name WarningCount \
    --filter-pattern "WARN" \
    --metric-transformations metricName=WarningCount,metricNamespace=MyApp/Logs,metricValue=1

# 로그 기반 알람 생성
aws cloudwatch put-metric-alarm \
    --alarm-name "High Error Count" \
    --alarm-description "Alarm when Error Count exceeds 10 in 5 minutes" \
    --metric-name ErrorCount \
    --namespace MyApp/Logs \
    --statistic Sum \
    --period 300 \
    --threshold 10.0 \
    --comparison-operator GreaterThanThreshold \
    --evaluation-periods 1 \
    --alarm-actions $SNS_TOPIC_ARN

echo "Log filters and alarms created"
```

### 로그 쿼리
```bash
# Log Insights 쿼리 실행
aws logs start-query \
    --log-group-name /ecs/my-app \
    --start-time $(date -d '1 hour ago' +%s) \
    --end-time $(date +%s) \
    --query-string 'fields @timestamp, @message | filter @message like /ERROR/ | sort @timestamp desc | limit 20'

# 쿼리 결과 확인
aws logs get-query-results \
    --query-id $(aws logs describe-queries --query 'queries[0].queryId' --output text)
```

</details>

---

## ☁️ GCP Cloud Monitoring 설정

<details>
<summary>📖 Cloud Monitoring 구성 요소</summary>

### 모니터링 구성 요소
- **메트릭**: 시계열 데이터
- **대시보드**: 시각화
- **알림 정책**: 임계값 기반 알림
- **로그**: Cloud Logging

### Cloud Monitoring 특징
- **자동 메트릭**: GCP 서비스 자동 메트릭
- **커스텀 메트릭**: 사용자 정의 메트릭
- **Uptime Checks**: 가용성 모니터링
- **Error Reporting**: 에러 추적

</details>

<details>
<summary>🔧 1단계: 커스텀 메트릭 설정</summary>

### 커스텀 메트릭 생성
```bash
# 커스텀 메트릭 생성
gcloud monitoring metrics-descriptors create \
    --display-name="Request Count" \
    --type="custom.googleapis.com/myapp/request_count" \
    --metric-kind="GAUGE" \
    --value-type="INT64" \
    --description="Number of requests per second"

# 커스텀 메트릭 생성
gcloud monitoring metrics-descriptors create \
    --display-name="Response Time" \
    --type="custom.googleapis.com/myapp/response_time" \
    --metric-kind="GAUGE" \
    --value-type="DOUBLE" \
    --description="Average response time in milliseconds"

echo "Custom metrics created"
```

### 메트릭 데이터 전송
```bash
# 메트릭 데이터 전송 스크립트
cat > send-gcp-metrics.sh << 'EOF'
#!/bin/bash

# 현재 시간 (RFC3339 형식)
TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%S.000Z)

# 요청 수 메트릭 전송
gcloud monitoring time-series create \
    --metric-type="custom.googleapis.com/myapp/request_count" \
    --resource-type="gce_instance" \
    --resource-labels="instance_id=my-app-instance,zone=asia-northeast3-a" \
    --value-type="INT64" \
    --points="[{\"interval\":{\"endTime\":\"$TIMESTAMP\"},\"value\":{\"int64Value\":\"100\"}}]"

# 응답 시간 메트릭 전송
gcloud monitoring time-series create \
    --metric-type="custom.googleapis.com/myapp/response_time" \
    --resource-type="gce_instance" \
    --resource-labels="instance_id=my-app-instance,zone=asia-northeast3-a" \
    --value-type="DOUBLE" \
    --points="[{\"interval\":{\"endTime\":\"$TIMESTAMP\"},\"value\":{\"doubleValue\":150.5}}]"

echo "GCP custom metrics sent successfully"
EOF

chmod +x send-gcp-metrics.sh
./send-gcp-metrics.sh
```

</details>

<details>
<summary>🔧 2단계: Cloud Monitoring 대시보드 생성</summary>

### 대시보드 생성
```bash
# 대시보드 생성
gcloud monitoring dashboards create \
    --config-from-file=dashboard-config.json
```

### 대시보드 설정 파일
```json
# dashboard-config.json
{
  "displayName": "My App Production Dashboard",
  "mosaicLayout": {
    "tiles": [
      {
        "width": 6,
        "height": 4,
        "widget": {
          "title": "CPU Utilization",
          "xyChart": {
            "dataSets": [
              {
                "timeSeriesQuery": {
                  "timeSeriesFilter": {
                    "filter": "resource.type=\"gce_instance\" AND metric.type=\"compute.googleapis.com/instance/cpu/utilization\"",
                    "aggregation": {
                      "alignmentPeriod": "300s",
                      "perSeriesAligner": "ALIGN_MEAN"
                    }
                  }
                },
                "plotType": "LINE"
              }
            ],
            "timeshiftDuration": "0s",
            "yAxis": {
              "label": "CPU Utilization",
              "scale": "LINEAR"
            }
          }
        }
      },
      {
        "width": 6,
        "height": 4,
        "widget": {
          "title": "Request Count",
          "xyChart": {
            "dataSets": [
              {
                "timeSeriesQuery": {
                  "timeSeriesFilter": {
                    "filter": "metric.type=\"custom.googleapis.com/myapp/request_count\"",
                    "aggregation": {
                      "alignmentPeriod": "300s",
                      "perSeriesAligner": "ALIGN_RATE"
                    }
                  }
                },
                "plotType": "LINE"
              }
            ],
            "timeshiftDuration": "0s",
            "yAxis": {
              "label": "Requests/sec",
              "scale": "LINEAR"
            }
          }
        }
      }
    ]
  }
}
```

</details>

<details>
<summary>🔧 3단계: 알림 정책 설정</summary>

### 알림 정책 생성
```bash
# 알림 정책 생성
gcloud alpha monitoring policies create \
    --policy-from-file=alert-policy.yaml
```

### 알림 정책 설정 파일
```yaml
# alert-policy.yaml
displayName: "High CPU Utilization"
conditions:
  - displayName: "CPU utilization is high"
    conditionThreshold:
      filter: 'resource.type="gce_instance" AND metric.type="compute.googleapis.com/instance/cpu/utilization"'
      comparison: COMPARISON_GT
      thresholdValue: 0.8
      duration: 300s
      aggregations:
        - alignmentPeriod: 300s
          perSeriesAligner: ALIGN_MEAN
notificationChannels:
  - projects/my-project-123456/notificationChannels/1234567890123456789
alertStrategy:
  autoClose: 604800s
```

### 알림 채널 생성
```bash
# 이메일 알림 채널 생성
gcloud alpha monitoring channels create \
    --display-name="Email Alerts" \
    --type="email" \
    --channel-labels="email_address=admin@example.com"

# Slack 알림 채널 생성
gcloud alpha monitoring channels create \
    --display-name="Slack Alerts" \
    --type="slack" \
    --channel-labels="channel_name=#alerts,webhook_url=$SLACK_WEBHOOK_URL"
```

</details>

---

## 🐳 Prometheus + Grafana 설정

<details>
<summary>📖 Prometheus + Grafana 아키텍처</summary>

### Prometheus 구성 요소
- **Prometheus Server**: 메트릭 수집 및 저장
- **Exporters**: 메트릭 노출
- **Alertmanager**: 알림 관리
- **Grafana**: 시각화

### Grafana 특징
- **대시보드**: 다양한 데이터 소스 지원
- **알림**: 임계값 기반 알림
- **플러그인**: 확장 가능한 플러그인 시스템
- **사용자 관리**: RBAC 지원

</details>

<details>
<summary>🔧 1단계: Prometheus 설정</summary>

### Prometheus 설정 파일
```yaml
# prometheus.yml
global:
  scrape_interval: 15s
  evaluation_interval: 15s

rule_files:
  - "alert_rules.yml"

alerting:
  alertmanagers:
    - static_configs:
        - targets:
          - alertmanager:9093

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'my-app'
    static_configs:
      - targets: ['my-app:3000']
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
        regex: (.+)
```

### Docker Compose 설정
```yaml
# docker-compose.yml
version: '3.8'
services:
  prometheus:
    image: prom/prometheus:latest
    container_name: prometheus
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
      - ./alert_rules.yml:/etc/prometheus/alert_rules.yml
      - prometheus_data:/prometheus
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
      - '--web.console.libraries=/etc/prometheus/console_libraries'
      - '--web.console.templates=/etc/prometheus/consoles'
      - '--storage.tsdb.retention.time=200h'
      - '--web.enable-lifecycle'

  grafana:
    image: grafana/grafana:latest
    container_name: grafana
    ports:
      - "3000:3000"
    volumes:
      - grafana_data:/var/lib/grafana
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin123
      - GF_USERS_ALLOW_SIGN_UP=false

  alertmanager:
    image: prom/alertmanager:latest
    container_name: alertmanager
    ports:
      - "9093:9093"
    volumes:
      - ./alertmanager.yml:/etc/alertmanager/alertmanager.yml
      - alertmanager_data:/alertmanager
    command:
      - '--config.file=/etc/alertmanager/alertmanager.yml'
      - '--storage.path=/alertmanager'

volumes:
  prometheus_data:
  grafana_data:
  alertmanager_data:
```

### Prometheus 시작
```bash
# Prometheus 시작
docker-compose up -d

# Prometheus 상태 확인
curl http://localhost:9090/api/v1/query?query=up
```

</details>

<details>
<summary>🔧 2단계: Grafana 설정</summary>

### Grafana 대시보드 설정
```json
# dashboard.json
{
  "dashboard": {
    "title": "My App Dashboard",
    "panels": [
      {
        "title": "Request Rate",
        "type": "graph",
        "targets": [
          {
            "expr": "rate(http_requests_total[5m])",
            "legendFormat": "{{method}} {{endpoint}}"
          }
        ]
      },
      {
        "title": "Error Rate",
        "type": "graph",
        "targets": [
          {
            "expr": "rate(http_requests_total{status=~\"5..\"}[5m])",
            "legendFormat": "5xx Errors"
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
      }
    ]
  }
}
```

### Grafana 데이터 소스 설정
```bash
# Prometheus 데이터 소스 추가
curl -X POST \
  http://admin:admin123@localhost:3000/api/datasources \
  -H 'Content-Type: application/json' \
  -d '{
    "name": "Prometheus",
    "type": "prometheus",
    "url": "http://prometheus:9090",
    "access": "proxy",
    "isDefault": true
  }'
```

</details>

<details>
<summary>🔧 3단계: Alertmanager 설정</summary>

### Alertmanager 설정 파일
```yaml
# alertmanager.yml
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
      - url: 'http://localhost:5001/'

  - name: 'email'
    email_configs:
      - to: 'admin@example.com'
        subject: 'Alert: {{ .GroupLabels.alertname }}'
        body: |
          {{ range .Alerts }}
          Alert: {{ .Annotations.summary }}
          Description: {{ .Annotations.description }}
          {{ end }}

  - name: 'slack'
    slack_configs:
      - api_url: '$SLACK_WEBHOOK_URL'
        channel: '#alerts'
        title: 'Alert: {{ .GroupLabels.alertname }}'
        text: |
          {{ range .Alerts }}
          *Alert:* {{ .Annotations.summary }}
          *Description:* {{ .Annotations.description }}
          {{ end }}
```

### 알림 규칙 설정
```yaml
# alert_rules.yml
groups:
  - name: myapp
    rules:
      - alert: HighErrorRate
        expr: rate(http_requests_total{status=~"5.."}[5m]) > 0.1
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "High error rate detected"
          description: "Error rate is {{ $value }} errors per second"

      - alert: HighResponseTime
        expr: histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m])) > 1
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High response time detected"
          description: "95th percentile response time is {{ $value }} seconds"
```

</details>

---

## 📊 ELK Stack 로깅 시스템

<details>
<summary>📖 ELK Stack 구성 요소</summary>

### ELK Stack 구성 요소
- **Elasticsearch**: 로그 저장 및 검색
- **Logstash**: 로그 수집 및 처리
- **Kibana**: 로그 시각화 및 분석
- **Beats**: 경량 로그 수집기

### 로그 처리 파이프라인
1. **수집**: Beats, Logstash
2. **처리**: Logstash 필터
3. **저장**: Elasticsearch
4. **시각화**: Kibana

</details>

<details>
<summary>🔧 1단계: Elasticsearch 설정</summary>

### Elasticsearch 설정 파일
```yaml
# elasticsearch.yml
cluster.name: my-app-cluster
node.name: my-app-node
network.host: 0.0.0.0
discovery.type: single-node
xpack.security.enabled: false
```

### Docker Compose 설정
```yaml
# docker-compose-elk.yml
version: '3.8'
services:
  elasticsearch:
    image: docker.elastic.co/elasticsearch/elasticsearch:7.15.0
    container_name: elasticsearch
    environment:
      - discovery.type=single-node
      - "ES_JAVA_OPTS=-Xms512m -Xmx512m"
    ports:
      - "9200:9200"
    volumes:
      - elasticsearch_data:/usr/share/elasticsearch/data

  logstash:
    image: docker.elastic.co/logstash/logstash:7.15.0
    container_name: logstash
    ports:
      - "5044:5044"
    volumes:
      - ./logstash.conf:/usr/share/logstash/pipeline/logstash.conf
    depends_on:
      - elasticsearch

  kibana:
    image: docker.elastic.co/kibana/kibana:7.15.0
    container_name: kibana
    ports:
      - "5601:5601"
    environment:
      - ELASTICSEARCH_HOSTS=http://elasticsearch:9200
    depends_on:
      - elasticsearch

  filebeat:
    image: docker.elastic.co/beats/filebeat:7.15.0
    container_name: filebeat
    user: root
    volumes:
      - ./filebeat.yml:/usr/share/filebeat/filebeat.yml
      - /var/log:/var/log:ro
      - /var/lib/docker/containers:/var/lib/docker/containers:ro
    depends_on:
      - elasticsearch

volumes:
  elasticsearch_data:
```

### ELK Stack 시작
```bash
# ELK Stack 시작
docker-compose -f docker-compose-elk.yml up -d

# Elasticsearch 상태 확인
curl http://localhost:9200/_cluster/health
```

</details>

<details>
<summary>🔧 2단계: Logstash 설정</summary>

### Logstash 설정 파일
```ruby
# logstash.conf
input {
  beats {
    port => 5044
  }
}

filter {
  if [fields][service] == "my-app" {
    grok {
      match => { "message" => "%{TIMESTAMP_ISO8601:timestamp} %{LOGLEVEL:level} %{GREEDYDATA:message}" }
    }
    date {
      match => [ "timestamp", "ISO8601" ]
    }
    mutate {
      add_field => { "service" => "my-app" }
    }
  }
}

output {
  elasticsearch {
    hosts => ["elasticsearch:9200"]
    index => "my-app-%{+YYYY.MM.dd}"
  }
}
```

### Filebeat 설정
```yaml
# filebeat.yml
filebeat.inputs:
  - type: log
    enabled: true
    paths:
      - /var/log/my-app/*.log
    fields:
      service: my-app
    fields_under_root: true

output.logstash:
  hosts: ["logstash:5044"]
```

</details>

<details>
<summary>🔧 3단계: Kibana 대시보드 설정</summary>

### Kibana 인덱스 패턴 생성
```bash
# 인덱스 패턴 생성
curl -X POST \
  "http://localhost:5601/api/saved_objects/index-pattern/my-app-*" \
  -H 'kbn-xsrf: true' \
  -H 'Content-Type: application/json' \
  -d '{
    "attributes": {
      "title": "my-app-*",
      "timeFieldName": "@timestamp"
    }
  }'
```

### Kibana 대시보드 설정
```json
# dashboard.json
{
  "version": "7.15.0",
  "objects": [
    {
      "id": "my-app-dashboard",
      "type": "dashboard",
      "attributes": {
        "title": "My App Dashboard",
        "panelsJSON": "[{\"version\":\"7.15.0\",\"gridData\":{\"x\":0,\"y\":0,\"w\":24,\"h\":15,\"i\":\"1\"},\"panelIndex\":\"1\",\"embeddableConfig\":{},\"panelRefName\":\"panel_1\"}]"
      }
    }
  ]
}
```

</details>

---

## 📚 문제 해결 및 참고 자료

<details>
<summary>🐛 자주 발생하는 문제</summary>

### CloudWatch 관련 문제
<details>
<summary>❌ 커스텀 메트릭이 표시되지 않음</summary>

**원인**: 
- 메트릭 네임스페이스 오류
- 권한 부족
- 메트릭 전송 실패

**해결방법**:
```bash
# 1. 메트릭 네임스페이스 확인
aws cloudwatch list-metrics --namespace MyApp/ECS

# 2. IAM 권한 확인
aws iam get-role-policy --role-name MyAppRole --policy-name CloudWatchPolicy

# 3. 메트릭 전송 테스트
aws cloudwatch put-metric-data \
    --namespace "MyApp/Test" \
    --metric-data MetricName=TestMetric,Value=1,Unit=Count
```

</details>

<details>
<summary>❌ 알람이 작동하지 않음</summary>

**원인**:
- SNS 토픽 설정 오류
- 알람 임계값 설정 오류
- 권한 문제

**해결방법**:
```bash
# 1. 알람 상태 확인
aws cloudwatch describe-alarms --alarm-names "High CPU Utilization"

# 2. SNS 토픽 확인
aws sns list-topics

# 3. 알람 테스트
aws cloudwatch set-alarm-state \
    --alarm-name "High CPU Utilization" \
    --state-value ALARM \
    --state-reason "Testing alarm"
```

</details>

### Prometheus 관련 문제
<details>
<summary>❌ 메트릭 수집 실패</summary>

**원인**:
- 타겟 연결 실패
- 메트릭 엔드포인트 오류
- 네트워크 문제

**해결방법**:
```bash
# 1. Prometheus 타겟 상태 확인
curl http://localhost:9090/api/v1/targets

# 2. 메트릭 엔드포인트 확인
curl http://my-app:3000/metrics

# 3. Prometheus 로그 확인
docker logs prometheus
```

</details>

</details>

<details>
<summary>📖 추가 학습 자료</summary>

### 공식 문서
- [AWS CloudWatch](https://docs.aws.amazon.com/cloudwatch/)
- [GCP Cloud Monitoring](https://cloud.google.com/monitoring/docs)
- [Prometheus 공식 문서](https://prometheus.io/docs/)
- [Grafana 공식 문서](https://grafana.com/docs/)
- [ELK Stack 가이드](https://www.elastic.co/guide/)

### 유용한 리소스
- [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)
- [GCP Architecture Center](https://cloud.google.com/architecture)
- [Prometheus 샘플 프로젝트](https://github.com/prometheus/prometheus)
- [Grafana 대시보드 갤러리](https://grafana.com/grafana/dashboards/)

</details>

---

## 🎉 완료!

축하합니다! 모니터링 시스템 구축 실습을 완료했습니다.

### 📚 학습 요약

이번 실습을 통해 다음을 배웠습니다:

1. **☁️ AWS CloudWatch**: 커스텀 메트릭, 대시보드, 알람 설정
2. **☁️ GCP Cloud Monitoring**: 통합 모니터링 시스템
3. **🐳 Prometheus + Grafana**: 오픈소스 모니터링 스택
4. **📊 ELK Stack**: 로그 수집, 분석, 시각화

### 🚀 다음 단계

- **종합 프로젝트**: [종합 프로젝트 실습](./comprehensive-project.md)
- **성능 최적화**: [성능 최적화 실습](./performance-optimization.md)
- **비용 최적화**: [비용 최적화 실습](./cost-optimization.md)

### 💡 추가 학습 자료

- [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)
- [GCP Architecture Center](https://cloud.google.com/architecture)
- [전체 커리큘럼](../../../../curriculum.md)

---

**🎯 이제 종합적인 모니터링 시스템의 모든 기본기를 갖추었습니다! 실제 프로젝트에 적용해보세요.**
