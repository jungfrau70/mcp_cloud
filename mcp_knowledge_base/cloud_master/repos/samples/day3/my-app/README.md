# My App - 고가용성 웹 애플리케이션

## 🎯 프로젝트 개요

이 프로젝트는 Day3에서 학습하는 로드 밸런싱, Auto Scaling, 모니터링을 활용한 고가용성 웹 애플리케이션입니다.

### 주요 기능
- **고가용성 아키텍처**: Multi-AZ, Multi-Region 배포
- **로드 밸런싱**: AWS ELB, GCP Cloud Load Balancing
- **Auto Scaling**: 자동 확장/축소
- **모니터링**: CloudWatch, Cloud Monitoring, Prometheus
- **장애 복구**: 자동 복구 및 백업

## 🏗️ 고가용성 아키텍처

```
┌─────────────────────────────────────────────────────────────────┐
│                        Global Load Balancer                     │
│                    (AWS ALB / GCP Cloud LB)                     │
└─────────────────┬───────────────────────────────────────────────┘
                  │
    ┌─────────────┼─────────────┐
    │             │             │
    ▼             ▼             ▼
┌─────────┐  ┌─────────┐  ┌─────────┐
│ Region 1│  │ Region 2│  │ Region 3│
│ (Seoul) │  │(Tokyo)  │  │(Singapore)│
└─────────┘  └─────────┘  └─────────┘
    │             │             │
    ▼             ▼             ▼
┌─────────┐  ┌─────────┐  ┌─────────┐
│   AZ-A  │  │   AZ-A  │  │   AZ-A  │
│   AZ-C  │  │   AZ-C  │  │   AZ-C  │
└─────────┘  └─────────┘  └─────────┘
    │             │             │
    ▼             ▼             ▼
┌─────────┐  ┌─────────┐  ┌─────────┐
│Auto Scale│  │Auto Scale│  │Auto Scale│
│  Group   │  │  Group   │  │  Group   │
└─────────┘  └─────────┘  └─────────┘
```

## 🚀 시작하기

### 필수 요구사항
- AWS CLI 2.0+
- Google Cloud SDK 400+
- Terraform 1.0+
- kubectl 1.20+

### 환경 설정

#### 1. AWS 환경 설정
```bash
# AWS CLI 설정
aws configure

# 환경 변수 설정
export AWS_DEFAULT_REGION=ap-northeast-2
export AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
```

#### 2. GCP 환경 설정
```bash
# GCP 인증
gcloud auth login
gcloud auth application-default login

# 프로젝트 설정
export PROJECT_ID=your-project-id
gcloud config set project $PROJECT_ID
```

#### 3. Terraform 초기화
```bash
# Terraform 초기화
cd terraform/
terraform init
terraform plan
terraform apply
```

## 📁 프로젝트 구조

```
my-app/
├── terraform/                 # Infrastructure as Code
│   ├── aws/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── gcp/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── modules/
├── k8s/                       # Kubernetes 매니페스트
│   ├── base/
│   ├── overlays/
│   │   ├── dev/
│   │   ├── staging/
│   │   └── prod/
│   └── monitoring/
├── monitoring/                # 모니터링 설정
│   ├── prometheus/
│   ├── grafana/
│   └── alertmanager/
├── scripts/                   # 배포 및 관리 스크립트
│   ├── deploy.sh
│   ├── scale.sh
│   └── monitor.sh
├── src/                       # 애플리케이션 소스
│   ├── app.py
│   ├── requirements.txt
│   └── tests/
├── docker-compose.yml
├── Dockerfile
└── README.md
```

## 🔧 고가용성 구성

### 1. AWS ELB + Auto Scaling Group

#### Terraform 구성
```hcl
# terraform/aws/main.tf
resource "aws_lb" "main" {
  name               = "my-app-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = aws_subnet.public[*].id

  enable_deletion_protection = false
}

resource "aws_lb_target_group" "app" {
  name     = "my-app-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 30
    matcher             = "200"
    path                = "/health"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 2
  }
}

resource "aws_autoscaling_group" "app" {
  name                = "my-app-asg"
  vpc_zone_identifier = aws_subnet.private[*].id
  target_group_arns   = [aws_lb_target_group.app.arn]
  health_check_type   = "ELB"
  health_check_grace_period = 300

  min_size         = 2
  max_size         = 10
  desired_capacity = 3

  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "my-app-instance"
    propagate_at_launch = true
  }
}
```

### 2. GCP Cloud Load Balancing + MIG

#### Terraform 구성
```hcl
# terraform/gcp/main.tf
resource "google_compute_global_forwarding_rule" "default" {
  name       = "my-app-forwarding-rule"
  target     = google_compute_target_http_proxy.default.id
  port_range = "80"
}

resource "google_compute_target_http_proxy" "default" {
  name    = "my-app-proxy"
  url_map = google_compute_url_map.default.id
}

resource "google_compute_url_map" "default" {
  name            = "my-app-map"
  default_service = google_compute_backend_service.default.id
}

resource "google_compute_backend_service" "default" {
  name        = "my-app-backend"
  protocol    = "HTTP"
  port_name   = "http"
  timeout_sec = 10

  backend {
    group = google_compute_instance_group_manager.app.instance_group
  }

  health_checks = [google_compute_health_check.default.id]
}

resource "google_compute_instance_group_manager" "app" {
  name = "my-app-mig"
  zone = var.zone

  version {
    instance_template = google_compute_instance_template.app.id
    name             = "primary"
  }

  base_instance_name = "my-app"
  target_size        = 3

  auto_healing_policies {
    health_check      = google_compute_health_check.default.id
    initial_delay_sec = 300
  }
}
```

## 📊 모니터링 설정

### 1. Prometheus + Grafana

#### Prometheus 설정
```yaml
# monitoring/prometheus/prometheus.yml
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
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'my-app'
    static_configs:
      - targets: ['my-app-service:80']
    metrics_path: /metrics
    scrape_interval: 5s

  - job_name: 'kubernetes-pods'
    kubernetes_sd_configs:
      - role: pod
    relabel_configs:
      - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_scrape]
        action: keep
        regex: true
```

#### Grafana 대시보드
```json
{
  "dashboard": {
    "title": "My App High Availability Dashboard",
    "panels": [
      {
        "title": "Request Rate",
        "type": "graph",
        "targets": [
          {
            "expr": "rate(http_requests_total[5m])",
            "legendFormat": "{{instance}}"
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

### 2. CloudWatch / Cloud Monitoring

#### AWS CloudWatch 알람
```bash
# CPU 사용률 알람
aws cloudwatch put-metric-alarm \
    --alarm-name "High CPU Utilization" \
    --alarm-description "Alarm when CPU exceeds 70%" \
    --metric-name CPUUtilization \
    --namespace AWS/EC2 \
    --statistic Average \
    --period 300 \
    --threshold 70.0 \
    --comparison-operator GreaterThanThreshold \
    --evaluation-periods 2 \
    --alarm-actions arn:aws:sns:ap-northeast-2:ACCOUNT_ID:my-app-alerts

# 응답 시간 알람
aws cloudwatch put-metric-alarm \
    --alarm-name "High Response Time" \
    --alarm-description "Alarm when response time exceeds 1 second" \
    --metric-name ResponseTime \
    --namespace MyApp \
    --statistic Average \
    --period 300 \
    --threshold 1.0 \
    --comparison-operator GreaterThanThreshold \
    --evaluation-periods 2 \
    --alarm-actions arn:aws:sns:ap-northeast-2:ACCOUNT_ID:my-app-alerts
```

#### GCP Cloud Monitoring 알람
```bash
# CPU 사용률 알람
gcloud alpha monitoring policies create \
    --policy-from-file=monitoring/cpu-policy.yaml

# 메모리 사용률 알람
gcloud alpha monitoring policies create \
    --policy-from-file=monitoring/memory-policy.yaml
```

## 🔄 장애 복구 설정

### 1. 자동 백업

#### AWS RDS 자동 백업
```hcl
# terraform/aws/rds.tf
resource "aws_db_instance" "main" {
  identifier = "my-app-db"
  
  engine         = "postgres"
  engine_version = "13.7"
  instance_class = "db.t3.micro"
  
  allocated_storage     = 20
  max_allocated_storage = 100
  storage_encrypted     = true
  
  backup_retention_period = 7
  backup_window          = "03:00-04:00"
  maintenance_window     = "sun:04:00-sun:05:00"
  
  skip_final_snapshot = false
  final_snapshot_identifier = "my-app-db-final-snapshot"
}
```

#### GCP Cloud SQL 자동 백업
```hcl
# terraform/gcp/sql.tf
resource "google_sql_database_instance" "main" {
  name             = "my-app-db"
  database_version = "POSTGRES_13"
  region           = var.region

  settings {
    tier = "db-f1-micro"
    
    backup_configuration {
      enabled                        = true
      start_time                     = "03:00"
      location                       = var.region
      point_in_time_recovery_enabled = true
    }
    
    maintenance_window {
      day          = 7
      hour         = 4
      update_track = "stable"
    }
  }
}
```

### 2. 재해 복구

#### Cross-Region 복제
```bash
# AWS Cross-Region 복제
aws rds create-db-instance-read-replica \
    --db-instance-identifier my-app-db-replica \
    --source-db-instance-identifier my-app-db \
    --db-instance-class db.t3.micro \
    --availability-zone ap-northeast-1a

# GCP Cross-Region 복제
gcloud sql instances create my-app-db-replica \
    --master-instance-name=my-app-db \
    --region=asia-northeast1
```

## 🧪 테스트 및 검증

### 1. 부하 테스트
```bash
# Apache Bench 부하 테스트
ab -n 10000 -c 100 http://your-load-balancer-dns/

# k6 성능 테스트
k6 run tests/load-test.js

# Artillery 부하 테스트
artillery run tests/artillery-config.yml
```

### 2. 장애 시뮬레이션
```bash
# 인스턴스 종료 시뮬레이션
aws ec2 terminate-instances --instance-ids i-1234567890abcdef0

# 데이터베이스 장애 시뮬레이션
kubectl delete pod postgres-pod

# 네트워크 분할 시뮬레이션
iptables -A INPUT -s 10.0.0.0/8 -j DROP
```

### 3. 복구 시간 측정
```bash
# 복구 시간 측정 스크립트
#!/bin/bash
echo "Starting disaster recovery test..."
start_time=$(date +%s)

# 장애 발생
kubectl delete deployment my-app

# 복구 대기
while ! kubectl get deployment my-app | grep -q "2/2"; do
  sleep 5
done

end_time=$(date +%s)
recovery_time=$((end_time - start_time))
echo "Recovery time: ${recovery_time} seconds"
```

## 📚 학습 목표 달성

이 프로젝트를 통해 다음을 학습할 수 있습니다:

1. **로드 밸런싱**
   - AWS ELB 구성 및 관리
   - GCP Cloud Load Balancing 설정
   - 로드 밸런싱 알고리즘 이해

2. **Auto Scaling**
   - AWS Auto Scaling Group 설정
   - GCP Managed Instance Group 구성
   - 스케일링 정책 최적화

3. **모니터링 및 로깅**
   - CloudWatch/Cloud Monitoring 설정
   - Prometheus + Grafana 구성
   - 알람 및 알림 설정

4. **장애 복구**
   - 자동 백업 설정
   - 재해 복구 계획 수립
   - 복구 시간 최적화

5. **비용 최적화**
   - 리소스 사용량 모니터링
   - 불필요한 리소스 정리
   - 예약 인스턴스 활용

## 🔗 관련 자료

- [AWS ELB 공식 문서](https://docs.aws.amazon.com/elasticloadbalancing/)
- [GCP Cloud Load Balancing 가이드](https://cloud.google.com/load-balancing/docs)
- [Prometheus 공식 문서](https://prometheus.io/docs/)
- [Grafana 공식 문서](https://grafana.com/docs/)
- [Terraform 공식 문서](https://www.terraform.io/docs/)
