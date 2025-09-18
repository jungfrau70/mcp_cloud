# 로드 밸런싱 실습 가이드

## 🎯 학습 목표

### 핵심 학습 목표
- **로드 밸런서 기초** AWS ALB, GCP Load Balancer 설정
- **고가용성 구성** Multi-AZ, Multi-Region 아키텍처
- **로드 밸런싱 알고리즘** Round Robin, Least Connections, IP Hash
- **헬스 체크** 애플리케이션 상태 모니터링 및 자동 복구

### 실습 후 달성할 수 있는 능력
- ✅ AWS Application Load Balancer 설정 및 관리
- ✅ GCP Cloud Load Balancing 구성 및 최적화
- ✅ 고가용성 웹 애플리케이션 아키텍처 구축
- ✅ 로드 밸런싱 모니터링 및 트러블슈팅

### 예상 소요 시간
- **AWS ALB 설정**: 90-120분
- **GCP Load Balancer**: 90-120분
- **고가용성 구성**: 120-150분
- **모니터링 및 최적화**: 60-90분
- **전체 과정**: 6-8시간

---

## 🛠️ 실습 학습

### 📁 실습 코드 및 자동화
- **실습 샘플 코드**: `/mcp_knowledge_base/cloud_master/repos/samples/day3/my-app/`
- **자동화 스크립트**: `/mcp_knowledge_base/cloud_master/repos/automation/day3/load_balancing.sh`
- **클라우드 스크립트**: `/mcp_knowledge_base/cloud_master/repos/cloud-scripts/`

<details>
<summary>🚀 실습 환경 준비</summary>

#### 필수 도구
- **AWS CLI**: 2.0 이상
- **gcloud CLI**: 400.0 이상
- **Terraform**: 1.0 이상
- **Docker**: 20.10 이상

#### 환경 설정
```bash
# AWS CLI 설정 확인
aws sts get-caller-identity

# gcloud CLI 설정 확인
gcloud auth list

# Terraform 설치 확인
terraform version

# Docker 설치 확인
docker --version
```

</details>

<details>
<summary>🔧 1단계: AWS Application Load Balancer</summary>

#### ALB 생성 및 설정
```bash
# VPC 및 서브넷 생성
aws ec2 create-vpc --cidr-block 10.0.0.0/16 --tag-specifications 'ResourceType=vpc,Tags=[{Key=Name,Value=my-vpc}]'

# 서브넷 생성 (Multi-AZ)
aws ec2 create-subnet --vpc-id vpc-12345 --cidr-block 10.0.1.0/24 --availability-zone us-west-2a
aws ec2 create-subnet --vpc-id vpc-12345 --cidr-block 10.0.2.0/24 --availability-zone us-west-2b

# 보안 그룹 생성
aws ec2 create-security-group --group-name web-sg --description "Web server security group" --vpc-id vpc-12345

# 보안 그룹 규칙 추가
aws ec2 authorize-security-group-ingress --group-id sg-12345 --protocol tcp --port 80 --cidr 0.0.0.0/0
aws ec2 authorize-security-group-ingress --group-id sg-12345 --protocol tcp --port 443 --cidr 0.0.0.0/0
```

#### ALB 생성
```bash
# ALB 생성
aws elbv2 create-load-balancer \
  --name my-alb \
  --subnets subnet-12345 subnet-67890 \
  --security-groups sg-12345 \
  --scheme internet-facing \
  --type application \
  --ip-address-type ipv4

# 타겟 그룹 생성
aws elbv2 create-target-group \
  --name web-targets \
  --protocol HTTP \
  --port 80 \
  --vpc-id vpc-12345 \
  --health-check-path /health \
  --health-check-interval-seconds 30 \
  --health-check-timeout-seconds 5 \
  --healthy-threshold-count 2 \
  --unhealthy-threshold-count 3

# 리스너 생성
aws elbv2 create-listener \
  --load-balancer-arn arn:aws:elasticloadbalancing:us-west-2:123456789012:loadbalancer/app/my-alb/1234567890123456 \
  --protocol HTTP \
  --port 80 \
  --default-actions Type=forward,TargetGroupArn=arn:aws:elasticloadbalancing:us-west-2:123456789012:targetgroup/web-targets/1234567890123456
```

#### EC2 인스턴스 생성 및 등록
```bash
# EC2 인스턴스 생성
aws ec2 run-instances \
  --image-id ami-0c02fb55956c7d316 \
  --count 2 \
  --instance-type t2.micro \
  --key-name my-key \
  --security-group-ids sg-12345 \
  --subnet-id subnet-12345 \
  --user-data file://user-data.sh

# 타겟 그룹에 인스턴스 등록
aws elbv2 register-targets \
  --target-group-arn arn:aws:elasticloadbalancing:us-west-2:123456789012:targetgroup/web-targets/1234567890123456 \
  --targets Id=i-1234567890abcdef0,Port=80 Id=i-0987654321fedcba0,Port=80
```

#### ALB 모니터링
```bash
# ALB 상태 확인
aws elbv2 describe-load-balancers --names my-alb

# 타겟 그룹 상태 확인
aws elbv2 describe-target-health --target-group-arn arn:aws:elasticloadbalancing:us-west-2:123456789012:targetgroup/web-targets/1234567890123456

# ALB 메트릭 확인
aws cloudwatch get-metric-statistics \
  --namespace AWS/ApplicationELB \
  --metric-name RequestCount \
  --dimensions Name=LoadBalancer,Value=app/my-alb/1234567890123456 \
  --start-time 2023-01-01T00:00:00Z \
  --end-time 2023-01-01T23:59:59Z \
  --period 3600 \
  --statistics Sum
```

</details>

<details>
<summary>🔧 2단계: GCP Cloud Load Balancing</summary>

#### GCP 로드 밸런서 설정
```bash
# VPC 네트워크 생성
gcloud compute networks create my-vpc --subnet-mode custom

# 서브넷 생성
gcloud compute networks subnets create web-subnet \
  --network my-vpc \
  --range 10.0.1.0/24 \
  --region us-central1

# 방화벽 규칙 생성
gcloud compute firewall-rules create allow-http \
  --network my-vpc \
  --allow tcp:80 \
  --source-ranges 0.0.0.0/0 \
  --target-tags http-server

gcloud compute firewall-rules create allow-https \
  --network my-vpc \
  --allow tcp:443 \
  --source-ranges 0.0.0.0/0 \
  --target-tags https-server
```

#### 인스턴스 템플릿 생성
```bash
# 인스턴스 템플릿 생성
gcloud compute instance-templates create web-template \
  --machine-type e2-micro \
  --network my-vpc \
  --subnet web-subnet \
  --tags http-server,https-server \
  --image-family ubuntu-2004-lts \
  --image-project ubuntu-os-cloud \
  --metadata-from-file startup-script=startup-script.sh

# 관리형 인스턴스 그룹 생성
gcloud compute instance-groups managed create web-group \
  --template web-template \
  --size 2 \
  --zone us-central1-a

# 자동 스케일링 설정
gcloud compute instance-groups managed set-autoscaling web-group \
  --max-num-replicas 5 \
  --min-num-replicas 2 \
  --target-cpu-utilization 0.6 \
  --zone us-central1-a
```

#### HTTP(S) 로드 밸런서 생성
```bash
# 백엔드 서비스 생성
gcloud compute backend-services create web-backend \
  --protocol HTTP \
  --health-checks web-health-check \
  --global

# 백엔드에 인스턴스 그룹 추가
gcloud compute backend-services add-backend web-backend \
  --instance-group web-group \
  --instance-group-zone us-central1-a \
  --global

# URL 맵 생성
gcloud compute url-maps create web-map \
  --default-service web-backend

# HTTP 프록시 생성
gcloud compute target-http-proxies create web-proxy \
  --url-map web-map

# 전역 포워딩 규칙 생성
gcloud compute forwarding-rules create web-rule \
  --global \
  --target-http-proxy web-proxy \
  --ports 80
```

#### 헬스 체크 설정
```bash
# HTTP 헬스 체크 생성
gcloud compute health-checks create http web-health-check \
  --request-path /health \
  --port 80 \
  --check-interval 30s \
  --timeout 5s \
  --healthy-threshold 2 \
  --unhealthy-threshold 3

# HTTPS 헬스 체크 생성
gcloud compute health-checks create https web-health-check-https \
  --request-path /health \
  --port 443 \
  --check-interval 30s \
  --timeout 5s \
  --healthy-threshold 2 \
  --unhealthy-threshold 3
```

</details>

<details>
<summary>🔧 3단계: 고가용성 아키텍처</summary>

#### Multi-AZ 구성
```yaml
# terraform/multi-az-alb.tf
resource "aws_lb" "main" {
  name               = "my-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = [aws_subnet.public_1.id, aws_subnet.public_2.id]

  enable_deletion_protection = false

  tags = {
    Environment = "production"
  }
}

resource "aws_lb_target_group" "app" {
  name     = "app-targets"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    path                = "/health"
    matcher             = "200"
    port                = "traffic-port"
    protocol            = "HTTP"
  }
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}

resource "aws_autoscaling_group" "app" {
  name                = "app-asg"
  vpc_zone_identifier = [aws_subnet.private_1.id, aws_subnet.private_2.id]
  target_group_arns   = [aws_lb_target_group.app.arn]
  health_check_type   = "ELB"
  health_check_grace_period = 300

  min_size         = 2
  max_size         = 10
  desired_capacity = 2

  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "app-instance"
    propagate_at_launch = true
  }
}
```

#### Multi-Region 구성
```yaml
# terraform/multi-region.tf
# Primary Region (us-west-2)
resource "aws_lb" "primary" {
  provider = aws.primary
  name     = "my-alb-primary"
  # ... configuration
}

# Secondary Region (us-east-1)
resource "aws_lb" "secondary" {
  provider = aws.secondary
  name     = "my-alb-secondary"
  # ... configuration
}

# Route 53 Health Check
resource "aws_route53_health_check" "primary" {
  fqdn              = aws_lb.primary.dns_name
  port              = 80
  type              = "HTTP"
  resource_path     = "/health"
  failure_threshold = "3"
  request_interval  = "30"

  tags = {
    Name = "primary-health-check"
  }
}

# Route 53 Record with Failover
resource "aws_route53_record" "primary" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "www"
  type    = "CNAME"
  ttl     = 60

  set_identifier = "primary"
  health_check_id = aws_route53_health_check.primary.id

  records = [aws_lb.primary.dns_name]
}

resource "aws_route53_record" "secondary" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "www"
  type    = "CNAME"
  ttl     = 60

  set_identifier = "secondary"
  health_check_id = aws_route53_health_check.secondary.id

  records = [aws_lb.secondary.dns_name]
}
```

</details>

<details>
<summary>🔧 4단계: 로드 밸런싱 모니터링</summary>

#### CloudWatch 메트릭 설정
```bash
# CloudWatch 대시보드 생성
aws cloudwatch put-dashboard --dashboard-name "ALB-Dashboard" --dashboard-body '{
  "widgets": [
    {
      "type": "metric",
      "x": 0,
      "y": 0,
      "width": 12,
      "height": 6,
      "properties": {
        "metrics": [
          ["AWS/ApplicationELB", "RequestCount", "LoadBalancer", "app/my-alb/1234567890123456"],
          [".", "TargetResponseTime", ".", "."],
          [".", "HTTPCode_Target_2XX_Count", ".", "."],
          [".", "HTTPCode_Target_4XX_Count", ".", "."],
          [".", "HTTPCode_Target_5XX_Count", ".", "."]
        ],
        "view": "timeSeries",
        "stacked": false,
        "region": "us-west-2",
        "title": "ALB Metrics",
        "period": 300
      }
    }
  ]
}'

# CloudWatch 알람 생성
aws cloudwatch put-metric-alarm \
  --alarm-name "High-Response-Time" \
  --alarm-description "ALB response time is too high" \
  --metric-name TargetResponseTime \
  --namespace AWS/ApplicationELB \
  --statistic Average \
  --period 300 \
  --threshold 2.0 \
  --comparison-operator GreaterThanThreshold \
  --evaluation-periods 2 \
  --alarm-actions arn:aws:sns:us-west-2:123456789012:my-topic
```

#### GCP 모니터링 설정
```bash
# 로그 기반 메트릭 생성
gcloud logging metrics create alb_request_count \
  --description="ALB request count" \
  --log-filter='resource.type="http_load_balancer"'

# 알림 정책 생성
gcloud alpha monitoring policies create --policy-from-file=alert-policy.yaml

# 대시보드 생성
gcloud alpha monitoring dashboards create --config-from-file=dashboard.json
```

#### 성능 테스트
```bash
# Apache Bench를 이용한 부하 테스트
ab -n 1000 -c 10 http://my-alb-1234567890.us-west-2.elb.amazonaws.com/

# wrk를 이용한 고성능 부하 테스트
wrk -t12 -c400 -d30s http://my-alb-1234567890.us-west-2.elb.amazonaws.com/

# Artillery를 이용한 시나리오 기반 테스트
artillery run load-test-config.yml
```

</details>

---

## 📚 참고 자료

### 유용한 명령어
```bash
# AWS ALB 관리
aws elbv2 describe-load-balancers                    # ALB 목록
aws elbv2 describe-target-groups                     # 타겟 그룹 목록
aws elbv2 describe-target-health --target-group-arn  # 타겟 상태 확인

# GCP Load Balancer 관리
gcloud compute backend-services list                 # 백엔드 서비스 목록
gcloud compute url-maps list                         # URL 맵 목록
gcloud compute forwarding-rules list                 # 포워딩 규칙 목록
```

### 문제 해결
1. **ALB 타겟 Unhealthy**
   - 보안 그룹 규칙 확인
   - 헬스 체크 경로 확인
   - 애플리케이션 로그 확인

2. **로드 밸런서 응답 지연**
   - 타겟 그룹 용량 확인
   - 인스턴스 CPU/메모리 사용률 확인
   - 네트워크 지연 측정

---

## 🧹 실습 정리

### 자동 정리
```bash
# Day3 로드 밸런싱 실습 자동 정리
./mcp_knowledge_base/cloud_master/repos/automation/day3/load_balancing.sh --cleanup
```

### 수동 정리
```bash
# AWS 리소스 정리
aws elbv2 delete-load-balancer --load-balancer-arn arn:aws:elasticloadbalancing:us-west-2:123456789012:loadbalancer/app/my-alb/1234567890123456
aws elbv2 delete-target-group --target-group-arn arn:aws:elasticloadbalancing:us-west-2:123456789012:targetgroup/web-targets/1234567890123456

# GCP 리소스 정리
gcloud compute forwarding-rules delete web-rule --global
gcloud compute target-http-proxies delete web-proxy
gcloud compute url-maps delete web-map
gcloud compute backend-services delete web-backend --global
```

### 정리 확인
- [ ] ALB 및 타겟 그룹 삭제
- [ ] EC2 인스턴스 종료
- [ ] GCP 로드 밸런서 삭제
- [ ] CloudWatch 알람 삭제
