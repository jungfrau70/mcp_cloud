# 모니터링 시스템 구축 실습

<div align="center">

[← 이전: Cloud Container 2일차 메인](/mcp_knowledge_base/cloud_master/README.md) | [📚 전체 커리큘럼](/mcp_knowledge_base/curriculum.md) | [🏠 학습 경로로 돌아가기](/mcp_knowledge_base/index.md) | [← 이전: Cloud Container 메인](/mcp_knowledge_base/cloud_master/README.md) | [📋 학습 경로](/mcp_knowledge_base/cloud_master/learning-path.md)

</div>

## 🎯 실습 목표

이 실습을 통해 다음을 학습합니다:
- AWS CloudWatch 고급 설정
- GCP Cloud Monitoring 구성
- Prometheus + Grafana 모니터링 스택 구축
- ELK Stack 로깅 시스템 구성

## 📋 사전 준비사항

- AWS 계정 (Free Tier 가능)
- GCP 계정 ($300 크레딧)
- Docker 및 Docker Compose 설치
- 기본적인 모니터링 개념 이해

## 📊 AWS CloudWatch 고급 설정

### 1단계: 커스텀 메트릭 설정

```bash
# 커스텀 메트릭 전송
aws cloudwatch put-metric-data \
    --namespace "MyApp/WebServer" \
    --metric-data MetricName=RequestCount,Value=100,Unit=Count

# 다차원 메트릭 전송
aws cloudwatch put-metric-data \
    --namespace "MyApp/WebServer" \
    --metric-data MetricName=ResponseTime,Value=250,Unit=Milliseconds,Dimensions=Environment=Production,Service=WebServer

# 통계적 메트릭 전송
aws cloudwatch put-metric-data \
    --namespace "MyApp/WebServer" \
    --metric-data MetricName=ErrorRate,Value=0.05,Unit=Percent,StatisticValues='{Maximum=0.1,Minimum=0.0,SampleCount=100,Sum=5.0}'
```

### 2단계: CloudWatch 대시보드 생성

```bash
# 대시보드 생성
aws cloudwatch put-dashboard \
    --dashboard-name "MyApp-Dashboard" \
    --dashboard-body '{
        "widgets": [
            {
                "type": "metric",
                "properties": {
                    "metrics": [
                        ["AWS/EC2", "CPUUtilization", "InstanceId", "i-1234567890abcdef0"],
                        ["AWS/EC2", "NetworkIn", "InstanceId", "i-1234567890abcdef0"],
                        ["AWS/EC2", "NetworkOut", "InstanceId", "i-1234567890abcdef0"]
                    ],
                    "period": 300,
                    "stat": "Average",
                    "region": "ap-northeast-2",
                    "title": "EC2 Metrics"
                }
            },
            {
                "type": "metric",
                "properties": {
                    "metrics": [
                        ["MyApp/WebServer", "RequestCount"],
                        ["MyApp/WebServer", "ResponseTime"],
                        ["MyApp/WebServer", "ErrorRate"]
                    ],
                    "period": 300,
                    "stat": "Average",
                    "region": "ap-northeast-2",
                    "title": "Application Metrics"
                }
            }
        ]
    }'
```

### 3단계: 알람 설정

```bash
# CPU 사용률 알람 생성
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
    --alarm-actions arn:aws:sns:ap-northeast-2:ACCOUNT:alerts

# 응답 시간 알람 생성
aws cloudwatch put-metric-alarm \
    --alarm-name "High Response Time" \
    --alarm-description "Alarm when response time exceeds 1 second" \
    --metric-name ResponseTime \
    --namespace MyApp/WebServer \
    --statistic Average \
    --period 300 \
    --threshold 1000.0 \
    --comparison-operator GreaterThanThreshold \
    --evaluation-periods 2 \
    --alarm-actions arn:aws:sns:ap-northeast-2:ACCOUNT:alerts
```

## ☁️ GCP Cloud Monitoring 설정

### 1단계: 커스텀 메트릭 생성

```bash
# 커스텀 메트릭 생성
gcloud monitoring metrics-descriptors create \
    --display-name="Request Count" \
    --type="custom.googleapis.com/myapp/request_count" \
    --metric-kind="GAUGE" \
    --value-type="INT64"

# 메트릭 데이터 전송
gcloud monitoring time-series create \
    --metric-type="custom.googleapis.com/myapp/request_count" \
    --resource-type="gce_instance" \
    --resource-labels="instance_id=INSTANCE_ID,zone=asia-northeast3-a" \
    --points="interval.endTime=2023-01-01T12:00:00Z,value.int64Value=100"
```

### 2단계: 알림 정책 생성

```yaml
# alert-policy.yaml
displayName: "High CPU Usage"
conditions:
  - displayName: "CPU usage is high"
    conditionThreshold:
      filter: 'resource.type="gce_instance" AND metric.type="compute.googleapis.com/instance/cpu/utilization"'
      comparison: COMPARISON_GREATER_THAN
      thresholdValue: 0.8
      duration: 300s
      aggregations:
        - alignmentPeriod: 60s
          perSeriesAligner: ALIGN_MEAN
notificationChannels:
  - "projects/PROJECT_ID/notificationChannels/CHANNEL_ID"
```

```bash
# 알림 정책 생성
gcloud alpha monitoring policies create \
    --policy-from-file=alert-policy.yaml
```

### 3단계: 대시보드 생성

```bash
# 대시보드 생성
gcloud alpha monitoring dashboards create \
    --config-from-file=dashboard-config.yaml
```

## 🔍 Prometheus + Grafana 모니터링 스택

### 1단계: Docker Compose 설정

```yaml
# docker-compose.monitoring.yml
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

  grafana:
    image: grafana/grafana:latest
    container_name: grafana
    ports:
      - "3000:3000"
    volumes:
      - grafana_data:/var/lib/grafana
      - ./grafana/provisioning:/etc/grafana/provisioning
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin123
      - GF_USERS_ALLOW_SIGN_UP=false

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

volumes:
  prometheus_data:
  grafana_data:
```

### 2단계: Prometheus 설정

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

  - job_name: 'node-exporter'
    static_configs:
      - targets: ['node-exporter:9100']

  - job_name: 'myapp'
    static_configs:
      - targets: ['myapp:3000']
    metrics_path: /metrics
    scrape_interval: 5s

  - job_name: 'aws-ec2'
    ec2_sd_configs:
      - region: ap-northeast-2
        port: 9100
    relabel_configs:
      - source_labels: [__meta_ec2_tag_Name]
        target_label: instance
```

### 3단계: Grafana 대시보드 설정

```json
{
  "dashboard": {
    "id": null,
    "title": "MyApp Monitoring Dashboard",
    "tags": ["myapp"],
    "style": "dark",
    "timezone": "browser",
    "panels": [
      {
        "id": 1,
        "title": "CPU Usage",
        "type": "graph",
        "targets": [
          {
            "expr": "100 - (avg(rate(node_cpu_seconds_total{mode=\"idle\"}[5m])) * 100)",
            "legendFormat": "CPU Usage %"
          }
        ],
        "yAxes": [
          {
            "min": 0,
            "max": 100,
            "unit": "percent"
          }
        ]
      },
      {
        "id": 2,
        "title": "Memory Usage",
        "type": "graph",
        "targets": [
          {
            "expr": "100 - ((node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes) * 100)",
            "legendFormat": "Memory Usage %"
          }
        ],
        "yAxes": [
          {
            "min": 0,
            "max": 100,
            "unit": "percent"
          }
        ]
      },
      {
        "id": 3,
        "title": "Request Rate",
        "type": "graph",
        "targets": [
          {
            "expr": "rate(http_requests_total[5m])",
            "legendFormat": "Requests/sec"
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
```

## 📝 ELK Stack 로깅 시스템

### 1단계: Elasticsearch 설정

```yaml
# docker-compose.logging.yml
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

  kibana:
    image: docker.elastic.co/kibana/kibana:7.15.0
    container_name: kibana
    ports:
      - "5601:5601"
    environment:
      - ELASTICSEARCH_HOSTS=http://elasticsearch:9200
    depends_on:
      - elasticsearch

  logstash:
    image: docker.elastic.co/logstash/logstash:7.15.0
    container_name: logstash
    ports:
      - "5044:5044"
    volumes:
      - ./logstash.conf:/usr/share/logstash/pipeline/logstash.conf
    depends_on:
      - elasticsearch

  filebeat:
    image: docker.elastic.co/beats/filebeat:7.15.0
    container_name: filebeat
    user: root
    volumes:
      - ./filebeat.yml:/usr/share/filebeat/filebeat.yml:ro
      - /var/log:/var/log:ro
      - /var/lib/docker/containers:/var/lib/docker/containers:ro
    depends_on:
      - logstash

volumes:
  elasticsearch_data:
```

### 2단계: Logstash 설정

```ruby
# logstash.conf
input {
  beats {
    port => 5044
  }
}

filter {
  if [fields][log_type] == "application" {
    grok {
      match => { "message" => "%{TIMESTAMP_ISO8601:timestamp} %{LOGLEVEL:level} %{GREEDYDATA:message}" }
    }
    date {
      match => [ "timestamp", "ISO8601" ]
    }
  }
  
  if [fields][log_type] == "access" {
    grok {
      match => { "message" => "%{COMBINEDAPACHELOG}" }
    }
  }
}

output {
  elasticsearch {
    hosts => ["elasticsearch:9200"]
    index => "logs-%{+YYYY.MM.dd}"
  }
}
```

### 3단계: Filebeat 설정

```yaml
# filebeat.yml
filebeat.inputs:
- type: log
  enabled: true
  paths:
    - /var/log/*.log
  fields:
    log_type: system

- type: container
  enabled: true
  paths:
    - /var/lib/docker/containers/*/*.log
  fields:
    log_type: application

output.logstash:
  hosts: ["logstash:5044"]
```

## 🧪 모니터링 테스트

### 1단계: 메트릭 생성 테스트

```bash
# 커스텀 메트릭 전송 스크립트
#!/bin/bash
while true; do
    # CPU 사용률 시뮬레이션
    cpu_usage=$(shuf -i 10-90 -n 1)
    aws cloudwatch put-metric-data \
        --namespace "MyApp/Test" \
        --metric-data MetricName=CPUUsage,Value=$cpu_usage,Unit=Percent
    
    # 메모리 사용률 시뮬레이션
    memory_usage=$(shuf -i 20-80 -n 1)
    aws cloudwatch put-metric-data \
        --namespace "MyApp/Test" \
        --metric-data MetricName=MemoryUsage,Value=$memory_usage,Unit=Percent
    
    sleep 60
done
```

### 2단계: 로그 생성 테스트

```bash
# 로그 생성 스크립트
#!/bin/bash
while true; do
    echo "$(date -Iseconds) INFO Application is running normally" >> /var/log/myapp.log
    echo "$(date -Iseconds) ERROR Something went wrong" >> /var/log/myapp.log
    sleep 10
done
```

### 3단계: 알람 테스트

```bash
# CPU 사용률을 90%로 설정하여 알람 트리거
aws cloudwatch put-metric-data \
    --namespace "MyApp/Test" \
    --metric-data MetricName=CPUUsage,Value=90,Unit=Percent

# 알람 상태 확인
aws cloudwatch describe-alarms \
    --alarm-names "High CPU Utilization"
```

## 📊 대시보드 구성

### 1단계: CloudWatch 대시보드

```bash
# 종합 대시보드 생성
aws cloudwatch put-dashboard \
    --dashboard-name "Production-Dashboard" \
    --dashboard-body '{
        "widgets": [
            {
                "type": "metric",
                "properties": {
                    "metrics": [
                        ["AWS/EC2", "CPUUtilization"],
                        ["AWS/EC2", "NetworkIn"],
                        ["AWS/EC2", "NetworkOut"]
                    ],
                    "period": 300,
                    "stat": "Average",
                    "region": "ap-northeast-2",
                    "title": "Infrastructure Metrics"
                }
            },
            {
                "type": "log",
                "properties": {
                    "query": "SOURCE \"/aws/ec2/myapp\" | fields @timestamp, @message\n| filter @message like /ERROR/\n| sort @timestamp desc\n| limit 20",
                    "region": "ap-northeast-2",
                    "title": "Error Logs",
                    "view": "table"
                }
            }
        ]
    }'
```

### 2단계: Grafana 대시보드

```bash
# Grafana 대시보드 가져오기
curl -X POST \
  http://localhost:3000/api/dashboards/db \
  -H 'Content-Type: application/json' \
  -H 'Authorization: Bearer YOUR_API_KEY' \
  -d @dashboard.json
```

## 📝 실습 결과 확인

### 체크리스트

- [ ] CloudWatch 커스텀 메트릭 설정 완료
- [ ] CloudWatch 대시보드 생성 완료
- [ ] CloudWatch 알람 설정 완료
- [ ] GCP Cloud Monitoring 설정 완료
- [ ] Prometheus + Grafana 스택 구축 완료
- [ ] ELK Stack 로깅 시스템 구성 완료
- [ ] 모니터링 테스트 성공

### 성능 지표

- **메트릭 수집**: 1분 이내
- **알람 응답**: 5분 이내
- **로그 검색**: 10초 이내
- **대시보드 업데이트**: 실시간

## 🔧 문제 해결

### 자주 발생하는 문제

1. **메트릭이 표시되지 않음**
   - IAM 권한 확인
   - 네임스페이스 및 메트릭 이름 확인
   - 시간 범위 확인

2. **알람이 작동하지 않음**
   - SNS 토픽 설정 확인
   - 임계값 설정 확인
   - 평가 기간 확인

3. **Prometheus 연결 실패**
   - 네트워크 설정 확인
   - 방화벽 규칙 확인
   - 서비스 상태 확인

4. **ELK Stack 로그 수집 실패**
   - Filebeat 설정 확인
   - Logstash 파이프라인 확인
   - Elasticsearch 인덱스 확인

## 📚 추가 학습 자료

- [AWS CloudWatch 공식 문서](https://docs.aws.amazon.com/cloudwatch/)
- [GCP Cloud Monitoring 공식 문서](https://cloud.google.com/monitoring/docs)
- [Prometheus 공식 문서](https://prometheus.io/docs/)
- [Grafana 공식 문서](https://grafana.com/docs/)
- [ELK Stack 공식 문서](https://www.elastic.co/guide/)

---

<div align="center">

[🏠 홈](/mcp_knowledge_base/index.md) | [📚 전체 커리큘럼](/mcp_knowledge_base/curriculum.md) | [🔗 학습 경로](/mcp_knowledge_base/cloud_container/learning-path.md)

</div>

### 📧 연락처
- **이메일**: inhwan.jung@gmail.com
- **GitHub**: [프로젝트 저장소](https://github.com/jungfrau70/aws_gcp.git)

---

<div align="center">

[🏠 홈](/mcp_knowledge_base/index.md) | [📚 전체 커리큘럼](/mcp_knowledge_base/curriculum.md) | [🔗 학습 경로](/mcp_knowledge_base/cloud_container/learning-path.md)

</div>
