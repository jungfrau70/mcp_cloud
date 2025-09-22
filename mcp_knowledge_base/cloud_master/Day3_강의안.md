# Cloud Master - 3일차 강의안

> 📋 **강의 일시**: 2024년 9월 24일 (수) 9:00~17:00  
> 📋 **강의 방식**: 온라인 실습 중심  
> 📋 **선수 학습**: Day1, Day2 완료 (기본 배포, 다중 서비스 환경)

---

## 🎯 3일차 학습 목표

### 핵심 목표
- **로드밸런싱**: AWS ELB + GCP Cloud Load Balancing 구축
- **모니터링**: Prometheus + Grafana + Jaeger 통합 모니터링
- **비용 최적화**: 클라우드 리소스 최적화 및 자동 스케일링
- **고가용성**: 장애 대응 및 복구 전략

### 실습 후 달성할 수 있는 능력
- ✅ 클라우드 로드밸런서 설정 및 관리
- ✅ 통합 모니터링 시스템 구축
- ✅ 분산 추적 및 로그 관리
- ✅ 비용 최적화 전략 수립
- ✅ 고가용성 아키텍처 설계
- ✅ 프로덕션 스택 운영 (8개 서비스)
- ✅ 보안 스캔 및 취약점 관리
- ✅ 성능 최적화 (평균 응답시간 6.2ms)

---

## 🕘 1교시: 로드밸런싱 구축 (9:00~10:30)

### 📚 이론 학습 (30분)
#### 로드밸런싱 개념
- **트래픽 분산**: 여러 서버에 요청을 균등하게 분산
- **고가용성**: 서버 장애 시 자동으로 다른 서버로 전환
- **확장성**: 트래픽 증가에 따라 서버 추가 가능
- **헬스체크**: 서버 상태를 주기적으로 확인

#### AWS ELB vs GCP Cloud Load Balancing
```bash
# AWS ELB
- Application Load Balancer (ALB): HTTP/HTTPS
- Network Load Balancer (NLB): TCP/UDP
- Classic Load Balancer (CLB): 레거시

# GCP Cloud Load Balancing
- HTTP(S) Load Balancing: 웹 애플리케이션
- TCP/UDP Load Balancing: 네트워크 트래픽
- Internal Load Balancing: 내부 트래픽
```

### 🛠️ 실습 (60분)
#### 1. AWS Application Load Balancer 설정
```bash
# aws-elb-setup.sh
#!/bin/bash

# 변수 설정
ALB_NAME="github-actions-demo-alb"
SECURITY_GROUP_NAME="github-actions-demo-sg"
TARGET_GROUP_NAME="github-actions-demo-tg"
VPC_ID=$(aws ec2 describe-vpcs --filters "Name=is-default,Values=true" --query "Vpcs[0].VpcId" --output text)

echo "🚀 AWS Application Load Balancer 설정 시작..."

# 1. 보안 그룹 생성
echo "📋 보안 그룹 생성 중..."
SECURITY_GROUP_ID=$(aws ec2 create-security-group \
    --group-name $SECURITY_GROUP_NAME \
    --description "Security group for GitHub Actions Demo ALB" \
    --vpc-id $VPC_ID \
    --query 'GroupId' \
    --output text)

# HTTP/HTTPS 트래픽 허용
aws ec2 authorize-security-group-ingress \
    --group-id $SECURITY_GROUP_ID \
    --protocol tcp \
    --port 80 \
    --cidr 0.0.0.0/0

aws ec2 authorize-security-group-ingress \
    --group-id $SECURITY_GROUP_ID \
    --protocol tcp \
    --port 443 \
    --cidr 0.0.0.0/0

echo "✅ 보안 그룹 생성 완료: $SECURITY_GROUP_ID"

# 2. 타겟 그룹 생성
echo "📋 타겟 그룹 생성 중..."
TARGET_GROUP_ARN=$(aws elbv2 create-target-group \
    --name $TARGET_GROUP_NAME \
    --protocol HTTP \
    --port 3000 \
    --vpc-id $VPC_ID \
    --health-check-path /health \
    --health-check-interval-seconds 30 \
    --health-check-timeout-seconds 5 \
    --healthy-threshold-count 2 \
    --unhealthy-threshold-count 3 \
    --query 'TargetGroups[0].TargetGroupArn' \
    --output text)

echo "✅ 타겟 그룹 생성 완료: $TARGET_GROUP_ARN"

# 3. Application Load Balancer 생성
echo "📋 Application Load Balancer 생성 중..."
ALB_ARN=$(aws elbv2 create-load-balancer \
    --name $ALB_NAME \
    --subnets $(aws ec2 describe-subnets --filters "Name=vpc-id,Values=$VPC_ID" --query "Subnets[0:2].SubnetId" --output text | tr '\t' ' ') \
    --security-groups $SECURITY_GROUP_ID \
    --query 'LoadBalancers[0].LoadBalancerArn' \
    --output text)

# ALB DNS 이름 가져오기
ALB_DNS=$(aws elbv2 describe-load-balancers \
    --load-balancer-arns $ALB_ARN \
    --query 'LoadBalancers[0].DNSName' \
    --output text)

echo "✅ Application Load Balancer 생성 완료: $ALB_DNS"

# 4. 리스너 생성 (HTTP)
echo "📋 HTTP 리스너 생성 중..."
aws elbv2 create-listener \
    --load-balancer-arn $ALB_ARN \
    --protocol HTTP \
    --port 80 \
    --default-actions Type=forward,TargetGroupArn=$TARGET_GROUP_ARN

echo "✅ HTTP 리스너 생성 완료"

# 5. 타겟 등록 (기존 EC2 인스턴스)
echo "📋 타겟 등록 중..."
INSTANCE_ID=$(aws ec2 describe-instances \
    --filters "Name=tag:Name,Values=github-actions-demo" \
    --query "Reservations[0].Instances[0].InstanceId" \
    --output text)

aws elbv2 register-targets \
    --target-group-arn $TARGET_GROUP_ARN \
    --targets Id=$INSTANCE_ID,Port=3000

echo "✅ 타겟 등록 완료: $INSTANCE_ID"

echo "🎉 AWS ALB 설정 완료!"
echo "🌐 ALB DNS: http://$ALB_DNS"
echo "🔍 헬스체크: http://$ALB_DNS/health"
```

#### 2. GCP Cloud Load Balancing 설정
```bash
# gcp-lb-setup.sh
#!/bin/bash

# 변수 설정
LB_NAME="github-actions-demo-lb"
HEALTH_CHECK_NAME="github-actions-demo-hc"
BACKEND_SERVICE_NAME="github-actions-demo-backend"
INSTANCE_GROUP_NAME="github-actions-demo-ig"
ZONE="us-central1-a"

echo "🚀 GCP Cloud Load Balancing 설정 시작..."

# 1. 인스턴스 그룹 생성
echo "📋 인스턴스 그룹 생성 중..."
gcloud compute instance-groups unmanaged create $INSTANCE_GROUP_NAME \
    --zone=$ZONE

# 기존 VM 인스턴스를 그룹에 추가
INSTANCE_NAME=$(gcloud compute instances list --filter="name~github-actions-demo" --format="value(name)" | head -1)
gcloud compute instance-groups unmanaged add-instances $INSTANCE_GROUP_NAME \
    --instances=$INSTANCE_NAME \
    --zone=$ZONE

echo "✅ 인스턴스 그룹 생성 완료"

# 2. 헬스체크 생성
echo "📋 헬스체크 생성 중..."
gcloud compute health-checks create http $HEALTH_CHECK_NAME \
    --port=3000 \
    --request-path=/health \
    --check-interval=30s \
    --timeout=5s \
    --healthy-threshold=2 \
    --unhealthy-threshold=3

echo "✅ 헬스체크 생성 완료"

# 3. 백엔드 서비스 생성
echo "📋 백엔드 서비스 생성 중..."
gcloud compute backend-services create $BACKEND_SERVICE_NAME \
    --protocol=HTTP \
    --port-name=http \
    --health-checks=$HEALTH_CHECK_NAME \
    --global

# 인스턴스 그룹을 백엔드에 추가
gcloud compute backend-services add-backend $BACKEND_SERVICE_NAME \
    --instance-group=$INSTANCE_GROUP_NAME \
    --instance-group-zone=$ZONE \
    --global

echo "✅ 백엔드 서비스 생성 완료"

# 4. URL 맵 생성
echo "📋 URL 맵 생성 중..."
gcloud compute url-maps create $LB_NAME \
    --default-service=$BACKEND_SERVICE_NAME

echo "✅ URL 맵 생성 완료"

# 5. HTTP 프록시 생성
echo "📋 HTTP 프록시 생성 중..."
gcloud compute target-http-proxies create $LB_NAME-proxy \
    --url-map=$LB_NAME

echo "✅ HTTP 프록시 생성 완료"

# 6. 글로벌 포워딩 규칙 생성
echo "📋 글로벌 포워딩 규칙 생성 중..."
gcloud compute forwarding-rules create $LB_NAME-rule \
    --global \
    --target-http-proxy=$LB_NAME-proxy \
    --ports=80

echo "✅ 글로벌 포워딩 규칙 생성 완료"

# 7. 로드밸런서 IP 주소 확인
LB_IP=$(gcloud compute forwarding-rules describe $LB_NAME-rule --global --format="value(IPAddress)")

echo "🎉 GCP Cloud Load Balancing 설정 완료!"
echo "🌐 LB IP: http://$LB_IP"
echo "🔍 헬스체크: http://$LB_IP/health"
```

### 📊 예상 결과
- **성공률**: 85% (클라우드 서비스 복잡성)
- **소요 시간**: 90분
- **주요 이슈**: 권한 설정, 네트워크 구성

---

## 🕘 2교시: 모니터링 스택 구축 (10:45~12:00)

### 📚 이론 학습 (15분)
#### 모니터링 아키텍처
- **Prometheus**: 메트릭 수집 및 저장
- **Grafana**: 시각화 및 대시보드
- **Jaeger**: 분산 추적
- **ELK Stack**: 로그 수집 및 분석

### 🛠️ 실습 (60분)
#### 1. Prometheus + Grafana 모니터링 스택
```yaml
# monitoring/docker-compose.monitoring.yml
version: '3.8'

services:
  # Prometheus 메트릭 수집
  prometheus:
    image: prom/prometheus:latest
    container_name: prometheus
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus/prometheus.yml:/etc/prometheus/prometheus.yml
      - ./prometheus/alert_rules.yml:/etc/prometheus/alert_rules.yml
      - prometheus_data:/prometheus
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
      - '--web.console.libraries=/etc/prometheus/console_libraries'
      - '--web.console.templates=/etc/prometheus/consoles'
      - '--storage.tsdb.retention.time=200h'
      - '--web.enable-lifecycle'
    networks:
      - monitoring

  # Grafana 시각화
  grafana:
    image: grafana/grafana:latest
    container_name: grafana
    ports:
      - "3001:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin123
    volumes:
      - grafana_data:/var/lib/grafana
      - ./grafana/dashboards:/var/lib/grafana/dashboards
      - ./grafana/provisioning:/etc/grafana/provisioning
    networks:
      - monitoring

  # Node Exporter (시스템 메트릭)
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
    networks:
      - monitoring

  # Jaeger 분산 추적
  jaeger:
    image: jaegertracing/all-in-one:latest
    container_name: jaeger
    ports:
      - "16686:16686"
      - "14268:14268"
    environment:
      - COLLECTOR_OTLP_ENABLED=true
    networks:
      - monitoring

volumes:
  prometheus_data:
  grafana_data:

networks:
  monitoring:
    driver: bridge
```

#### 2. Prometheus 설정
```yaml
# monitoring/prometheus/prometheus.yml
global:
  scrape_interval: 15s
  evaluation_interval: 15s

rule_files:
  - "alert_rules.yml"

alerting:
  alertmanagers:
    - static_configs:
        - targets: []

scrape_configs:
  # Prometheus 자체 모니터링
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  # Node Exporter (시스템 메트릭)
  - job_name: 'node-exporter'
    static_configs:
      - targets: ['node-exporter:9100']

  # 애플리케이션 메트릭
  - job_name: 'github-actions-demo'
    static_configs:
      - targets: ['app:3000']
    metrics_path: '/metrics'
    scrape_interval: 30s
```

#### 3. Grafana 대시보드 설정
```json
// monitoring/grafana/dashboards/app-dashboard.json
{
  "dashboard": {
    "id": null,
    "title": "GitHub Actions Demo - Application Dashboard",
    "tags": ["github-actions-demo"],
    "style": "dark",
    "timezone": "browser",
    "panels": [
      {
        "id": 1,
        "title": "Application Health",
        "type": "stat",
        "targets": [
          {
            "expr": "up{job=\"github-actions-demo\"}",
            "legendFormat": "App Status"
          }
        ],
        "fieldConfig": {
          "defaults": {
            "color": {
              "mode": "thresholds"
            },
            "thresholds": {
              "steps": [
                {"color": "red", "value": 0},
                {"color": "green", "value": 1}
              ]
            }
          }
        }
      },
      {
        "id": 2,
        "title": "HTTP Request Rate",
        "type": "graph",
        "targets": [
          {
            "expr": "rate(http_requests_total[5m])",
            "legendFormat": "{{method}} {{endpoint}}"
          }
        ]
      },
      {
        "id": 3,
        "title": "Response Time",
        "type": "graph",
        "targets": [
          {
            "expr": "histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m]))",
            "legendFormat": "95th percentile"
          }
        ]
      }
    ],
    "time": {
      "from": "now-1h",
      "to": "now"
    },
    "refresh": "30s"
  }
}
```

### 📊 예상 결과
- **성공률**: 80% (모니터링 스택 복잡성)
- **소요 시간**: 75분
- **주요 이슈**: 메트릭 수집 설정, 대시보드 구성

---

## 🍽️ 점심 시간 (12:00~13:00)

---

## 🕘 3교시: 분산 추적 및 로그 관리 (13:00~14:30)

### 📚 이론 학습 (15분)
#### 분산 추적의 중요성
- **마이크로서비스**: 여러 서비스 간의 요청 추적
- **성능 분석**: 병목 지점 식별
- **장애 진단**: 문제 발생 지점 빠른 파악
- **의존성 분석**: 서비스 간 관계 파악

### 🛠️ 실습 (75분)
#### 1. Jaeger 분산 추적 설정
```javascript
// src/app.js에 Jaeger 추적 추가
const express = require('express');
const { initTracer } = require('jaeger-client');

// Jaeger 설정
const config = {
  serviceName: 'github-actions-demo',
  sampler: {
    type: 'const',
    param: 1,
  },
  reporter: {
    logSpans: true,
    agentHost: process.env.JAEGER_AGENT_HOST || 'jaeger',
    agentPort: process.env.JAEGER_AGENT_PORT || 14268,
  },
};

const tracer = initTracer(config);

// Express 미들웨어
app.use((req, res, next) => {
  const span = tracer.startSpan(`${req.method} ${req.path}`);
  req.span = span;
  
  res.on('finish', () => {
    span.setTag('http.status_code', res.statusCode);
    span.finish();
  });
  
  next();
});

// 데이터베이스 쿼리 추적
app.get('/api/users', async (req, res) => {
  const span = tracer.startSpan('get_users', { childOf: req.span });
  
  try {
    const result = await pool.query('SELECT * FROM users ORDER BY created_at DESC');
    span.setTag('db.rows_returned', result.rows.length);
    res.json(result.rows);
  } catch (error) {
    span.setTag('error', true);
    span.setTag('error.message', error.message);
    res.status(500).json({ error: error.message });
  } finally {
    span.finish();
  }
});
```

#### 2. ELK Stack 로그 관리
```yaml
# monitoring/docker-compose.logging.yml
version: '3.8'

services:
  # Elasticsearch
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
    networks:
      - logging

  # Logstash
  logstash:
    image: docker.elastic.co/logstash/logstash:7.15.0
    container_name: logstash
    ports:
      - "5044:5044"
    volumes:
      - ./logstash/pipeline:/usr/share/logstash/pipeline
      - ./logstash/config:/usr/share/logstash/config
    depends_on:
      - elasticsearch
    networks:
      - logging

  # Kibana
  kibana:
    image: docker.elastic.co/kibana/kibana:7.15.0
    container_name: kibana
    ports:
      - "5601:5601"
    environment:
      - ELASTICSEARCH_HOSTS=http://elasticsearch:9200
    depends_on:
      - elasticsearch
    networks:
      - logging

volumes:
  elasticsearch_data:

networks:
  logging:
    driver: bridge
```

#### 3. 애플리케이션 로그 설정
```javascript
// src/logger.js
const winston = require('winston');

const logger = winston.createLogger({
  level: 'info',
  format: winston.format.combine(
    winston.format.timestamp(),
    winston.format.errors({ stack: true }),
    winston.format.json()
  ),
  transports: [
    new winston.transports.Console({
      format: winston.format.simple()
    }),
    new winston.transports.File({ filename: 'logs/error.log', level: 'error' }),
    new winston.transports.File({ filename: 'logs/combined.log' })
  ]
});

module.exports = logger;
```

### 📊 예상 결과
- **성공률**: 75% (분산 추적 복잡성)
- **소요 시간**: 90분
- **주요 이슈**: 추적 설정, 로그 파이프라인 구성

---

## 🕘 4교시: 비용 최적화 및 자동 스케일링 (14:45~16:15)

### 📚 이론 학습 (15분)
#### 비용 최적화 전략
- **리소스 최적화**: 사용하지 않는 리소스 제거
- **스케일링**: 수요에 따른 자동 조정
- **스팟 인스턴스**: 비용 절감을 위한 일시적 인스턴스
- **예약 인스턴스**: 장기 사용 시 할인 혜택

### 🛠️ 실습 (75분)
#### 1. AWS Auto Scaling 설정
```bash
# aws-autoscaling-setup.sh
#!/bin/bash

# 변수 설정
LAUNCH_TEMPLATE_NAME="github-actions-demo-template"
AUTO_SCALING_GROUP_NAME="github-actions-demo-asg"
TARGET_GROUP_ARN="arn:aws:elasticloadbalancing:us-west-2:123456789012:targetgroup/github-actions-demo-tg/1234567890123456"

echo "🚀 AWS Auto Scaling 설정 시작..."

# 1. Launch Template 생성
echo "📋 Launch Template 생성 중..."
LAUNCH_TEMPLATE_ID=$(aws ec2 create-launch-template \
    --launch-template-name $LAUNCH_TEMPLATE_NAME \
    --launch-template-data '{
        "ImageId": "ami-0c02fb55956c7d316",
        "InstanceType": "t2.micro",
        "KeyName": "my-key-pair",
        "SecurityGroupIds": ["sg-12345678"],
        "UserData": "'$(base64 -w 0 user-data.sh)'",
        "TagSpecifications": [{
            "ResourceType": "instance",
            "Tags": [{"Key": "Name", "Value": "github-actions-demo-asg"}]
        }]
    }' \
    --query 'LaunchTemplate.LaunchTemplateId' \
    --output text)

echo "✅ Launch Template 생성 완료: $LAUNCH_TEMPLATE_ID"

# 2. Auto Scaling Group 생성
echo "📋 Auto Scaling Group 생성 중..."
aws autoscaling create-auto-scaling-group \
    --auto-scaling-group-name $AUTO_SCALING_GROUP_NAME \
    --launch-template LaunchTemplateId=$LAUNCH_TEMPLATE_ID,Version='$Latest' \
    --min-size 1 \
    --max-size 3 \
    --desired-capacity 2 \
    --target-group-arns $TARGET_GROUP_ARN \
    --health-check-type ELB \
    --health-check-grace-period 300

echo "✅ Auto Scaling Group 생성 완료"

# 3. 스케일링 정책 생성
echo "📋 스케일링 정책 생성 중..."
# CPU 사용률 기반 스케일 아웃
aws autoscaling put-scaling-policy \
    --auto-scaling-group-name $AUTO_SCALING_GROUP_NAME \
    --policy-name scale-out-policy \
    --policy-type TargetTrackingScaling \
    --target-tracking-configuration '{
        "TargetValue": 70.0,
        "PredefinedMetricSpecification": {
            "PredefinedMetricType": "ASGAverageCPUUtilization"
        }
    }'

# CPU 사용률 기반 스케일 인
aws autoscaling put-scaling-policy \
    --auto-scaling-group-name $AUTO_SCALING_GROUP_NAME \
    --policy-name scale-in-policy \
    --policy-type TargetTrackingScaling \
    --target-tracking-configuration '{
        "TargetValue": 30.0,
        "PredefinedMetricSpecification": {
            "PredefinedMetricType": "ASGAverageCPUUtilization"
        }
    }'

echo "✅ 스케일링 정책 생성 완료"

echo "🎉 AWS Auto Scaling 설정 완료!"
```

#### 2. GCP Managed Instance Group 설정
```bash
# gcp-autoscaling-setup.sh
#!/bin/bash

# 변수 설정
INSTANCE_TEMPLATE_NAME="github-actions-demo-template"
INSTANCE_GROUP_NAME="github-actions-demo-mig"
ZONE="us-central1-a"

echo "🚀 GCP Managed Instance Group 설정 시작..."

# 1. 인스턴스 템플릿 생성
echo "📋 인스턴스 템플릿 생성 중..."
gcloud compute instance-templates create $INSTANCE_TEMPLATE_NAME \
    --image-family=ubuntu-2004-lts \
    --image-project=ubuntu-os-cloud \
    --machine-type=e2-micro \
    --boot-disk-size=10GB \
    --boot-disk-type=pd-standard \
    --tags=github-actions-demo \
    --metadata-from-file startup-script=startup-script.sh

echo "✅ 인스턴스 템플릿 생성 완료"

# 2. Managed Instance Group 생성
echo "📋 Managed Instance Group 생성 중..."
gcloud compute instance-groups managed create $INSTANCE_GROUP_NAME \
    --template=$INSTANCE_TEMPLATE_NAME \
    --size=2 \
    --zone=$ZONE

echo "✅ Managed Instance Group 생성 완료"

# 3. 자동 스케일링 설정
echo "📋 자동 스케일링 설정 중..."
gcloud compute instance-groups managed set-autoscaling $INSTANCE_GROUP_NAME \
    --zone=$ZONE \
    --max-num-replicas=5 \
    --min-num-replicas=1 \
    --target-cpu-utilization=0.7 \
    --cool-down-period=60

echo "✅ 자동 스케일링 설정 완료"

echo "🎉 GCP Managed Instance Group 설정 완료!"
```

#### 3. 비용 최적화 스크립트
```bash
# cost-optimization.sh
#!/bin/bash

echo "💰 클라우드 비용 최적화 분석 시작..."

# AWS 비용 분석
echo "📊 AWS 비용 분석..."
aws ce get-cost-and-usage \
    --time-period Start=2024-09-01,End=2024-09-30 \
    --granularity MONTHLY \
    --metrics BlendedCost \
    --group-by Type=DIMENSION,Key=SERVICE

# 사용하지 않는 리소스 찾기
echo "🔍 사용하지 않는 리소스 검색..."

# 중지된 EC2 인스턴스
echo "📋 중지된 EC2 인스턴스:"
aws ec2 describe-instances \
    --filters "Name=instance-state-name,Values=stopped" \
    --query "Reservations[].Instances[].{InstanceId:InstanceId,State:State.Name,LaunchTime:LaunchTime}"

# 사용하지 않는 EBS 볼륨
echo "📋 사용하지 않는 EBS 볼륨:"
aws ec2 describe-volumes \
    --filters "Name=status,Values=available" \
    --query "Volumes[].{VolumeId:VolumeId,Size:Size,CreateTime:CreateTime}"

# GCP 비용 분석
echo "📊 GCP 비용 분석..."
gcloud billing budgets list

# 사용하지 않는 GCP 리소스
echo "🔍 사용하지 않는 GCP 리소스 검색..."

# 중지된 Compute Engine 인스턴스
echo "📋 중지된 Compute Engine 인스턴스:"
gcloud compute instances list --filter="status=TERMINATED"

# 사용하지 않는 디스크
echo "📋 사용하지 않는 디스크:"
gcloud compute disks list --filter="status=UNATTACHED"

echo "✅ 비용 최적화 분석 완료!"
```

### 📊 예상 결과
- **성공률**: 70% (자동 스케일링 복잡성)
- **소요 시간**: 90분
- **주요 이슈**: 권한 설정, 스케일링 정책 구성

---

## 🕘 5교시: 통합 테스트 및 최종 정리 (16:30~17:00)

### 🛠️ 실습 (30분)
#### 1. 전체 시스템 통합 테스트
```bash
# 전체 시스템 상태 확인
echo "🔍 전체 시스템 상태 확인..."

# 로드밸런서 상태
echo "📋 로드밸런서 상태:"
curl -f http://$ALB_DNS/health
curl -f http://$LB_IP/health

# 모니터링 시스템
echo "📋 모니터링 시스템:"
curl -f http://localhost:9090  # Prometheus
curl -f http://localhost:3001  # Grafana
curl -f http://localhost:16686 # Jaeger
curl -f http://localhost:5601  # Kibana

# 자동 스케일링 상태
echo "📋 자동 스케일링 상태:"
aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names $AUTO_SCALING_GROUP_NAME
gcloud compute instance-groups managed describe $INSTANCE_GROUP_NAME --zone=$ZONE
```

#### 2. 성능 테스트
```bash
# 부하 테스트 (Apache Bench)
echo "🚀 부하 테스트 시작..."
ab -n 1000 -c 10 http://$ALB_DNS/
ab -n 1000 -c 10 http://$LB_IP/

# 모니터링 대시보드에서 결과 확인
echo "📊 Grafana 대시보드에서 결과 확인: http://localhost:3001"
echo "📊 Jaeger 추적 결과 확인: http://localhost:16686"
```

### 📊 예상 결과
- **성공률**: 90% (통합 테스트)
- **소요 시간**: 30분
- **주요 이슈**: 네트워크 연결, 서비스 간 통신

---

## 🎯 3일차 수업 성과

### ✅ 달성한 학습 목표
- [x] AWS ELB + GCP Cloud Load Balancing 구축
- [x] Prometheus + Grafana 통합 모니터링 시스템
- [x] Jaeger 분산 추적 및 ELK Stack 로그 관리
- [x] AWS Auto Scaling + GCP Managed Instance Group
- [x] 클라우드 비용 최적화 전략 수립
- [x] 고가용성 아키텍처 설계 및 구현

### 🔍 주요 학습 포인트
1. **로드밸런싱**: 트래픽 분산과 고가용성 확보
2. **모니터링**: 실시간 시스템 상태 파악
3. **분산 추적**: 마이크로서비스 환경에서의 문제 진단
4. **자동 스케일링**: 수요에 따른 자동 리소스 조정
5. **비용 최적화**: 효율적인 클라우드 리소스 활용

### 🚀 실습 결과물
- **로드밸런서**: AWS ALB + GCP Cloud LB
- **모니터링**: Prometheus + Grafana + Jaeger + ELK
- **자동 스케일링**: AWS Auto Scaling + GCP MIG
- **비용 최적화**: 리소스 사용량 분석 및 최적화

### 📈 Cloud Master 과정 완성
- **Day1**: 기본 환경 구축 및 CI/CD 파이프라인
- **Day2**: 다중 서비스 환경 및 고급 CI/CD
- **Day3**: 로드밸런싱, 모니터링, 비용 최적화
- **최종 결과**: 프로덕션 수준의 클라우드 네이티브 애플리케이션

---

**강의안 작성일**: 2024년 9월 24일  
**예상 소요 시간**: 8시간 (9:00~17:00)  
**실습 중심**: 85% 실습, 15% 이론  
**과정 완료**: Cloud Master 과정 전체 완성
