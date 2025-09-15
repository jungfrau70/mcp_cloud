# 모니터링 및 로깅 시스템 구축 가이드

<div align="center">

[← 이전: Cloud Container 메인](../../README.md) | [📚 전체 커리큘럼](../../curriculum.md) | [🏠 학습 경로로 돌아가기](../../index.md) | [📋 학습 경로](../../learning-path.md)

</div>

<div align="center">

[← 이전: Cloud Container 2일차 메인](../README.md) | [📚 전체 커리큘럼](../../curriculum.md) | [🏠 학습 경로로 돌아가기](../../index.md)

</div>

## 🎯 학습 목표

이 가이드를 통해 다음을 학습합니다:
- AWS CloudWatch 및 GCP Cloud Monitoring 설정
- Prometheus + Grafana 모니터링 스택 구축
- 커스텀 메트릭 및 대시보드 생성
- 로그 기반 알림 시스템 구성
- 실무 환경에 적용 가능한 모니터링 전략

---

## 📋 목차

1. [모니터링 아키텍처 설계](#모니터링-아키텍처-설계)
2. [AWS CloudWatch 설정](#aws-cloudwatch-설정)
3. [GCP Cloud Monitoring 설정](#gcp-cloud-monitoring-설정)
4. [Prometheus + Grafana 스택](#📈-prometheus-+-grafana-스택)
5. [로그 수집 및 분석](#로그-수집-및-분석)
6. [알림 시스템 구성](#알림-시스템-구성)
7. [실습 시나리오](#실습-시나리오)

---

## 📊 모니터링 아키텍처 설계

### 모니터링 계층 구조

#### 1. 인프라 모니터링
- **시스템 메트릭**: CPU, 메모리, 디스크, 네트워크
- **애플리케이션 메트릭**: 응답 시간, 처리량, 에러율
- **비즈니스 메트릭**: 사용자 수, 트랜잭션 수, 매출

#### 2. 로그 모니터링
- **애플리케이션 로그**: 에러, 디버그, 액세스 로그
- **시스템 로그**: 커널, 시스템 서비스 로그
- **보안 로그**: 인증, 권한, 보안 이벤트

#### 3. 알림 및 대응
- **실시간 알림**: 이메일, SMS, Slack, PagerDuty
- **자동 대응**: 자동 스케일링, 자동 복구
- **에스컬레이션**: 심각도별 알림 전략

### 모니터링 도구 선택 기준

#### AWS 환경
- **CloudWatch**: 기본 메트릭 및 로그
- **X-Ray**: 분산 추적
- **CloudTrail**: API 호출 추적
- **Config**: 리소스 변경 추적

#### GCP 환경
- **Cloud Monitoring**: 기본 메트릭 및 로그
- **Cloud Trace**: 분산 추적
- **Cloud Logging**: 중앙화된 로그 관리
- **Cloud Security Command Center**: 보안 모니터링

#### 오픈소스 도구
- **Prometheus**: 메트릭 수집 및 저장
- **Grafana**: 시각화 및 대시보드
- **ELK Stack**: 로그 수집, 분석, 시각화
- **Jaeger**: 분산 추적

---

## ☁️ AWS CloudWatch 설정

### CloudWatch 메트릭 설정

#### 커스텀 메트릭 생성
```javascript
// custom-metrics.js
const AWS = require('aws-sdk');
const cloudwatch = new AWS.CloudWatch({ region: 'ap-northeast-2' });

// 커스텀 메트릭 전송
async function sendCustomMetric(metricName, value, unit = 'Count') {
  const params = {
    Namespace: 'ContainerDemo/Application',
    MetricData: [
      {
        MetricName: metricName,
        Value: value,
        Unit: unit,
        Timestamp: new Date(),
        Dimensions: [
          {
            Name: 'Environment',
            Value: 'production'
          },
          {
            Name: 'Service',
            Value: 'container-demo'
          }
        ]
      }
    ]
  };

  try {
    await cloudwatch.putMetricData(params).promise();
    console.log(`메트릭 전송 성공: ${metricName} = ${value}`);
  } catch (error) {
    console.error('메트릭 전송 실패:', error);
  }
}

// 애플리케이션 메트릭 수집
function collectApplicationMetrics() {
  // 응답 시간 메트릭
  const responseTime = Math.random() * 1000; // 실제로는 측정된 값
  sendCustomMetric('ResponseTime', responseTime, 'Milliseconds');

  // 처리량 메트릭
  const throughput = Math.floor(Math.random() * 100); // 실제로는 측정된 값
  sendCustomMetric('Throughput', throughput, 'Count');

  // 에러율 메트릭
  const errorRate = Math.random() * 5; // 실제로는 측정된 값
  sendCustomMetric('ErrorRate', errorRate, 'Percent');
}

// 주기적으로 메트릭 수집
setInterval(collectApplicationMetrics, 60000); // 1분마다

module.exports = { sendCustomMetric, collectApplicationMetrics };
```

#### CloudWatch 알림 설정
```yaml
# cloudwatch-alarms.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: cloudwatch-alarms
  namespace: container-demo
data:
  alarms.json: |
    {
      "AlarmName": "container-demo-high-cpu",
      "ComparisonOperator": "GreaterThanThreshold",
      "EvaluationPeriods": 2,
      "MetricName": "CPUUtilization",
      "Namespace": "AWS/EC2",
      "Period": 300,
      "Statistic": "Average",
      "Threshold": 80.0,
      "ActionsEnabled": true,
      "AlarmActions": ["arn:aws:sns:ap-northeast-2:123456789012:container-demo-alerts"],
      "AlarmDescription": "High CPU utilization detected"
    }
    {
      "AlarmName": "container-demo-high-memory",
      "ComparisonOperator": "GreaterThanThreshold",
      "EvaluationPeriods": 2,
      "MetricName": "MemoryUtilization",
      "Namespace": "AWS/EC2",
      "Period": 300,
      "Statistic": "Average",
      "Threshold": 85.0,
      "ActionsEnabled": true,
      "AlarmActions": ["arn:aws:sns:ap-northeast-2:123456789012:container-demo-alerts"],
      "AlarmDescription": "High memory utilization detected"
    }
    {
      "AlarmName": "container-demo-high-error-rate",
      "ComparisonOperator": "GreaterThanThreshold",
      "EvaluationPeriods": 1,
      "MetricName": "ErrorRate",
      "Namespace": "ContainerDemo/Application",
      "Period": 300,
      "Statistic": "Average",
      "Threshold": 5.0,
      "ActionsEnabled": true,
      "AlarmActions": ["arn:aws:sns:ap-northeast-2:123456789012:container-demo-alerts"],
      "AlarmDescription": "High error rate detected"
    }
```

### CloudWatch 로그 설정

#### 로그 그룹 생성
```bash
#!/bin/bash
# cloudwatch-logs-setup.sh

# 로그 그룹 생성
aws logs create-log-group \
  --log-group-name /aws/ecs/container-demo \
  --region ap-northeast-2

# 로그 스트림 생성
aws logs create-log-stream \
  --log-group-name /aws/ecs/container-demo \
  --log-stream-name container-demo-app \
  --region ap-northeast-2

# 로그 보존 정책 설정
aws logs put-retention-policy \
  --log-group-name /aws/ecs/container-demo \
  --retention-in-days 30 \
  --region ap-northeast-2
```

#### 로그 필터 설정
```json
{
  "filterName": "container-demo-error-filter",
  "logGroupName": "/aws/ecs/container-demo",
  "filterPattern": "[timestamp, request_id, level=\"ERROR\", ...]",
  "destinationArn": "arn:aws:lambda:ap-northeast-2:123456789012:function:container-demo-error-handler"
}
```

---

## 🌐 GCP Cloud Monitoring 설정

### Cloud Monitoring 메트릭 설정

#### 커스텀 메트릭 생성
```javascript
// gcp-custom-metrics.js
const { MonitoringServiceClient } = require('@google-cloud/monitoring');
const client = new MonitoringServiceClient();

// 커스텀 메트릭 전송
async function sendCustomMetric(metricType, value) {
  const projectId = 'your-project-id';
  const projectName = `projects/${projectId}`;

  const request = {
    name: projectName,
    timeSeries: [
      {
        metric: {
          type: `custom.googleapis.com/${metricType}`,
          labels: {
            environment: 'production',
            service: 'container-demo'
          }
        },
        resource: {
          type: 'global',
          labels: {
            project_id: projectId
          }
        },
        points: [
          {
            interval: {
              endTime: {
                seconds: Date.now() / 1000
              }
            },
            value: {
              doubleValue: value
            }
          }
        ]
      }
    ]
  };

  try {
    await client.createTimeSeries(request);
    console.log(`메트릭 전송 성공: ${metricType} = ${value}`);
  } catch (error) {
    console.error('메트릭 전송 실패:', error);
  }
}

// 애플리케이션 메트릭 수집
function collectApplicationMetrics() {
  // 응답 시간 메트릭
  const responseTime = Math.random() * 1000;
  sendCustomMetric('response_time', responseTime);

  // 처리량 메트릭
  const throughput = Math.floor(Math.random() * 100);
  sendCustomMetric('throughput', throughput);

  // 에러율 메트릭
  const errorRate = Math.random() * 5;
  sendCustomMetric('error_rate', errorRate);
}

// 주기적으로 메트릭 수집
setInterval(collectApplicationMetrics, 60000);

module.exports = { sendCustomMetric, collectApplicationMetrics };
```

#### Cloud Monitoring 알림 정책
```yaml
# gcp-alerting-policy.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: gcp-alerting-policy
  namespace: container-demo
data:
  alerting-policy.json: |
    {
      "displayName": "Container Demo High CPU",
      "conditions": [
        {
          "displayName": "CPU utilization is above 80%",
          "conditionThreshold": {
            "filter": "resource.type=\"gce_instance\" AND metric.type=\"compute.googleapis.com/instance/cpu/utilization\"",
            "comparison": "COMPARISON_GREATER_THAN",
            "thresholdValue": 0.8,
            "duration": "300s"
          }
        }
      ],
      "notificationChannels": [
        "projects/PROJECT_ID/notificationChannels/CHANNEL_ID"
      ],
      "alertStrategy": {
        "autoClose": "1800s"
      }
    }
```

---

## 📈 Prometheus + Grafana 스택

### Prometheus 설정

#### Prometheus 구성 파일
```yaml
# prometheus.yml
global:
  scrape_interval: 15s
  evaluation_interval: 15s

rule_files:
  - "rules/*.yml"

alerting:
  alertmanagers:
    - static_configs:
        - targets:
          - alertmanager:9093

scrape_configs:
  # Kubernetes API server
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

  # Kubernetes nodes
  - job_name: 'kubernetes-nodes'
    kubernetes_sd_configs:
    - role: node
    scheme: https
    tls_config:
      ca_file: /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
    bearer_token_file: /var/run/secrets/kubernetes.io/serviceaccount/token
    relabel_configs:
    - action: labelmap
      regex: __meta_kubernetes_node_label_(.+)
    - target_label: __address__
      replacement: kubernetes.default.svc:443
    - source_labels: [__meta_kubernetes_node_name]
      regex: (.+)
      target_label: __metrics_path__
      replacement: /api/v1/nodes/${1}/proxy/metrics

  # Kubernetes pods
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
    - source_labels: [__address__, __meta_kubernetes_pod_annotation_prometheus_io_port]
      action: replace
      regex: ([^:]+)(?::\d+)?;(\d+)
      replacement: $1:$2
      target_label: __address__
    - action: labelmap
      regex: __meta_kubernetes_pod_label_(.+)
    - source_labels: [__meta_kubernetes_namespace]
      action: replace
      target_label: kubernetes_namespace
    - source_labels: [__meta_kubernetes_pod_name]
      action: replace
      target_label: kubernetes_pod_name

  # Container Demo application
  - job_name: 'container-demo'
    static_configs:
    - targets: ['container-demo-service:80']
    metrics_path: /metrics
    scrape_interval: 5s
    scrape_timeout: 3s
    relabel_configs:
    - source_labels: [__address__]
      target_label: instance
      replacement: container-demo
```

#### Prometheus 알림 규칙
```yaml
# rules/container-demo-alerts.yml
groups:
- name: container-demo
  rules:
  - alert: ContainerDemoDown
    expr: up{job="container-demo"} == 0
    for: 1m
    labels:
      severity: critical
    annotations:
      summary: "Container Demo application is down"
      description: "Container Demo application has been down for more than 1 minute"

  - alert: ContainerDemoHighErrorRate
    expr: rate(http_requests_total{status=~"5.."}[5m]) > 0.1
    for: 2m
    labels:
      severity: warning
    annotations:
      summary: "Container Demo high error rate"
      description: "Container Demo error rate is {{ $value }} errors per second"

  - alert: ContainerDemoHighResponseTime
    expr: histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m])) > 1
    for: 3m
    labels:
      severity: warning
    annotations:
      summary: "Container Demo high response time"
      description: "Container Demo 95th percentile response time is {{ $value }} seconds"

  - alert: ContainerDemoHighCPUUsage
    expr: rate(container_cpu_usage_seconds_total[5m]) > 0.8
    for: 5m
    labels:
      severity: warning
    annotations:
      summary: "Container Demo high CPU usage"
      description: "Container Demo CPU usage is {{ $value }}%"

  - alert: ContainerDemoHighMemoryUsage
    expr: container_memory_usage_bytes / container_spec_memory_limit_bytes > 0.9
    for: 5m
    labels:
      severity: warning
    annotations:
      summary: "Container Demo high memory usage"
      description: "Container Demo memory usage is {{ $value }}%"
```

### Grafana 대시보드 설정

#### Grafana 대시보드 JSON
```json
{
  "dashboard": {
    "id": null,
    "title": "Container Demo Dashboard",
    "tags": ["container-demo", "kubernetes"],
    "style": "dark",
    "timezone": "browser",
    "panels": [
      {
        "id": 1,
        "title": "Request Rate",
        "type": "graph",
        "targets": [
          {
            "expr": "rate(http_requests_total[5m])",
            "legendFormat": "{{method}} {{status}}"
          }
        ],
        "xAxis": {
          "show": true
        },
        "yAxes": [
          {
            "label": "Requests per second",
            "show": true
          }
        ],
        "gridPos": {
          "h": 8,
          "w": 12,
          "x": 0,
          "y": 0
        }
      },
      {
        "id": 2,
        "title": "Response Time",
        "type": "graph",
        "targets": [
          {
            "expr": "histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m]))",
            "legendFormat": "95th percentile"
          },
          {
            "expr": "histogram_quantile(0.50, rate(http_request_duration_seconds_bucket[5m]))",
            "legendFormat": "50th percentile"
          }
        ],
        "xAxis": {
          "show": true
        },
        "yAxes": [
          {
            "label": "Response time (seconds)",
            "show": true
          }
        ],
        "gridPos": {
          "h": 8,
          "w": 12,
          "x": 12,
          "y": 0
        }
      },
      {
        "id": 3,
        "title": "Error Rate",
        "type": "graph",
        "targets": [
          {
            "expr": "rate(http_requests_total{status=~\"5..\"}[5m])",
            "legendFormat": "5xx errors"
          },
          {
            "expr": "rate(http_requests_total{status=~\"4..\"}[5m])",
            "legendFormat": "4xx errors"
          }
        ],
        "xAxis": {
          "show": true
        },
        "yAxes": [
          {
            "label": "Error rate (errors per second)",
            "show": true
          }
        ],
        "gridPos": {
          "h": 8,
          "w": 12,
          "x": 0,
          "y": 8
        }
      },
      {
        "id": 4,
        "title": "Resource Usage",
        "type": "graph",
        "targets": [
          {
            "expr": "rate(container_cpu_usage_seconds_total[5m])",
            "legendFormat": "CPU usage"
          },
          {
            "expr": "container_memory_usage_bytes / container_spec_memory_limit_bytes",
            "legendFormat": "Memory usage"
          }
        ],
        "xAxis": {
          "show": true
        },
        "yAxes": [
          {
            "label": "Usage percentage",
            "show": true,
            "max": 1,
            "min": 0
          }
        ],
        "gridPos": {
          "h": 8,
          "w": 12,
          "x": 12,
          "y": 8
        }
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

---

## 📝 로그 수집 및 분석

### ELK Stack 설정

#### Elasticsearch 설정
```yaml
# elasticsearch.yml
cluster.name: container-demo-cluster
node.name: container-demo-node-1
network.host: 0.0.0.0
discovery.type: single-node
xpack.security.enabled: false
```

#### Logstash 설정
```ruby
# logstash.conf
input {
  beats {
    port => 5044
  }
}

filter {
  if [fields][service] == "container-demo" {
    grok {
      match => { "message" => "%{TIMESTAMP_ISO8601:timestamp} %{WORD:level} %{GREEDYDATA:message}" }
    }
    
    date {
      match => [ "timestamp", "ISO8601" ]
    }
    
    if [level] == "ERROR" {
      mutate {
        add_tag => [ "error" ]
      }
    }
  }
}

output {
  elasticsearch {
    hosts => ["elasticsearch:9200"]
    index => "container-demo-%{+YYYY.MM.dd}"
  }
  
  if "error" in [tags] {
    email {
      to => "admin@example.com"
      subject => "Container Demo Error Alert"
      body => "Error detected: %{message}"
    }
  }
}
```

#### Kibana 대시보드 설정
```json
{
  "version": 1,
  "objects": [
    {
      "id": "container-demo-dashboard",
      "type": "dashboard",
      "attributes": {
        "title": "Container Demo Logs Dashboard",
        "panelsJSON": "[{\"id\":\"1\",\"type\":\"visualization\",\"gridData\":{\"x\":0,\"y\":0,\"w\":12,\"h\":8}},{\"id\":\"2\",\"type\":\"visualization\",\"gridData\":{\"x\":12,\"y\":0,\"w\":12,\"h\":8}}]"
      }
    }
  ]
}
```

---

## 🚨 알림 시스템 구성

### Slack 알림 설정

#### Slack 웹훅 설정
```javascript
// slack-notifications.js
const axios = require('axios');

const SLACK_WEBHOOK_URL = process.env.SLACK_WEBHOOK_URL;

async function sendSlackNotification(alert) {
  const message = {
    text: `🚨 *${alert.severity.toUpperCase()}* - ${alert.title}`,
    attachments: [
      {
        color: alert.severity === 'critical' ? 'danger' : 'warning',
        fields: [
          {
            title: 'Description',
            value: alert.description,
            short: false
          },
          {
            title: 'Time',
            value: new Date().toISOString(),
            short: true
          },
          {
            title: 'Service',
            value: 'Container Demo',
            short: true
          }
        ]
      }
    ]
  };

  try {
    await axios.post(SLACK_WEBHOOK_URL, message);
    console.log('Slack 알림 전송 성공');
  } catch (error) {
    console.error('Slack 알림 전송 실패:', error);
  }
}

module.exports = { sendSlackNotification };
```

### PagerDuty 통합

#### PagerDuty 이벤트 전송
```javascript
// pagerduty-integration.js
const axios = require('axios');

const PAGERDUTY_INTEGRATION_KEY = process.env.PAGERDUTY_INTEGRATION_KEY;

async function sendPagerDutyEvent(alert) {
  const event = {
    routing_key: PAGERDUTY_INTEGRATION_KEY,
    event_action: 'trigger',
    dedup_key: alert.id,
    payload: {
      summary: alert.title,
      source: 'container-demo',
      severity: alert.severity,
      custom_details: {
        description: alert.description,
        timestamp: new Date().toISOString()
      }
    }
  };

  try {
    await axios.post('https://events.pagerduty.com/v2/enqueue', event);
    console.log('PagerDuty 이벤트 전송 성공');
  } catch (error) {
    console.error('PagerDuty 이벤트 전송 실패:', error);
  }
}

module.exports = { sendPagerDutyEvent };
```

---

## 🚀 실습 시나리오

### 시나리오 1: AWS CloudWatch 설정

#### 1단계: CloudWatch 메트릭 설정
```bash
# CloudWatch 로그 그룹 생성
aws logs create-log-group \
  --log-group-name /aws/ecs/container-demo \
  --region ap-northeast-2

# CloudWatch 알림 설정
aws cloudwatch put-metric-alarm \
  --alarm-name container-demo-high-cpu \
  --alarm-description "High CPU utilization detected" \
  --metric-name CPUUtilization \
  --namespace AWS/EC2 \
  --statistic Average \
  --period 300 \
  --threshold 80.0 \
  --comparison-operator GreaterThanThreshold \
  --evaluation-periods 2 \
  --alarm-actions arn:aws:sns:ap-northeast-2:123456789012:container-demo-alerts
```

#### 2단계: 커스텀 메트릭 전송
```bash
# 커스텀 메트릭 전송 스크립트 실행
node custom-metrics.js
```

### 시나리오 2: Prometheus + Grafana 설정

#### 1단계: Prometheus 배포
```bash
# Prometheus ConfigMap 생성
kubectl apply -f monitoring-advanced/prometheus-config.yaml

# Prometheus 배포
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: prometheus
  namespace: container-demo
spec:
  replicas: 1
  selector:
    matchLabels:
      app: prometheus
  template:
    metadata:
      labels:
        app: prometheus
    spec:
      containers:
      - name: prometheus
        image: prom/prometheus:latest
        ports:
        - containerPort: 9090
        volumeMounts:
        - name: prometheus-config
          mountPath: /etc/prometheus
      volumes:
      - name: prometheus-config
        configMap:
          name: prometheus-config
EOF
```

#### 2단계: Grafana 배포
```bash
# Grafana 배포
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: grafana
  namespace: container-demo
spec:
  replicas: 1
  selector:
    matchLabels:
      app: grafana
  template:
    metadata:
      labels:
        app: grafana
    spec:
      containers:
      - name: grafana
        image: grafana/grafana:latest
        ports:
        - containerPort: 3000
        env:
        - name: GF_SECURITY_ADMIN_PASSWORD
          value: "admin123"
EOF
```

### 시나리오 3: 로그 기반 알림 설정

#### 1단계: ELK Stack 배포
```bash
# Elasticsearch 배포
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: elasticsearch
  namespace: container-demo
spec:
  replicas: 1
  selector:
    matchLabels:
      app: elasticsearch
  template:
    metadata:
      labels:
        app: elasticsearch
    spec:
      containers:
      - name: elasticsearch
        image: elasticsearch:7.17.0
        ports:
        - containerPort: 9200
        env:
        - name: discovery.type
          value: single-node
        - name: xpack.security.enabled
          value: "false"
EOF
```

#### 2단계: 로그 수집 설정
```bash
# Logstash 배포
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: logstash
  namespace: container-demo
spec:
  replicas: 1
  selector:
    matchLabels:
      app: logstash
  template:
    metadata:
      labels:
        app: logstash
    spec:
      containers:
      - name: logstash
        image: logstash:7.17.0
        ports:
        - containerPort: 5044
        volumeMounts:
        - name: logstash-config
          mountPath: /usr/share/logstash/pipeline
      volumes:
      - name: logstash-config
        configMap:
          name: logstash-config
EOF
```

---

## ✅ 체크리스트

### AWS CloudWatch 설정
- [ ] CloudWatch 로그 그룹 생성
- [ ] 커스텀 메트릭 전송 구현
- [ ] CloudWatch 알림 설정
- [ ] 로그 필터 구성
- [ ] 대시보드 생성

### GCP Cloud Monitoring 설정
- [ ] Cloud Monitoring 메트릭 설정
- [ ] 커스텀 메트릭 전송 구현
- [ ] 알림 정책 설정
- [ ] 로그 기반 알림 구성
- [ ] 대시보드 생성

### Prometheus + Grafana 스택
- [ ] Prometheus 배포 및 설정
- [ ] Grafana 배포 및 설정
- [ ] 알림 규칙 설정
- [ ] 대시보드 구성
- [ ] 메트릭 수집 확인

### 로그 수집 및 분석
- [ ] ELK Stack 배포
- [ ] 로그 파이프라인 구성
- [ ] Kibana 대시보드 생성
- [ ] 로그 기반 알림 설정
- [ ] 로그 분석 쿼리 작성

---

## 📚 참고 자료

### 공식 문서
- [AWS CloudWatch 공식 문서](https://docs.aws.amazon.com/cloudwatch/)
- [GCP Cloud Monitoring 공식 문서](https://cloud.google.com/monitoring/docs)
- [Prometheus 공식 문서](https://prometheus.io/docs/)
- [Grafana 공식 문서](https://grafana.com/docs/)

### 추가 학습 자료
- [고가용성 아키텍처 가이드](./high-availability-architecture.md)
- [종합 프로젝트 실습](./practice/comprehensive-project.md)

---

**💡 팁**: 모니터링은 운영 환경에서 가장 중요한 요소입니다. 메트릭, 로그, 알림을 체계적으로 구성하여 문제를 빠르게 감지하고 대응할 수 있는 시스템을 구축하세요!
