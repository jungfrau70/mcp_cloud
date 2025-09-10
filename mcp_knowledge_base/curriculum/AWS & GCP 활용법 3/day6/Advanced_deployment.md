# 6-2. 심화 배포 관리 (Auto Scaling, 로드밸런싱)

## 📚 학습 목표
- Auto Scaling의 원리와 구성 요소 이해
- 로드 밸런서의 종류와 설정 방법 학습
- 고가용성을 위한 배포 전략 수립

---

## 🚀 **Auto Scaling 기초**

### **Auto Scaling이란?**
- **정의**: 트래픽에 따라 자동으로 인스턴스 수를 조절하는 서비스
- **목적**: 
  - 비용 최적화
  - 가용성 향상
  - 성능 보장
- **동작 원리**:
  - 스케일 아웃: 트래픽 증가 시 인스턴스 추가
  - 스케일 인: 트래픽 감소 시 인스턴스 제거

### **Auto Scaling 구성 요소**
1. **Launch Template/Configuration**: 인스턴스 생성 템플릿
2. **Auto Scaling Group**: 관리할 인스턴스 그룹
3. **Scaling Policy**: 스케일링 조건 및 규칙
4. **Target Tracking**: 목표 지표 기반 스케일링

---

## 🔧 **AWS Auto Scaling 설정**

### **Launch Template 생성**
```bash
# Launch Template 생성
aws ec2 create-launch-template \
    --launch-template-name WebServerTemplate \
    --version-description v1 \
    --launch-template-data '{
        "ImageId": "ami-12345678",
        "InstanceType": "t3.micro",
        "SecurityGroupIds": ["sg-12345678"],
        "UserData": "#!/bin/bash\nsudo yum update -y\nsudo yum install -y httpd\nsudo systemctl start httpd\nsudo systemctl enable httpd"
    }'
```

### **Auto Scaling Group 생성**
```bash
# Auto Scaling Group 생성
aws autoscaling create-auto-scaling-group \
    --auto-scaling-group-name WebServerASG \
    --launch-template LaunchTemplateName=WebServerTemplate,Version=\$Latest \
    --min-size 2 \
    --max-size 10 \
    --desired-capacity 2 \
    --vpc-zone-identifier "subnet-12345678,subnet-87654321" \
    --target-group-arns "arn:aws:elasticloadbalancing:region:account:targetgroup/WebServerTG/1234567890123456"
```

### **Scaling Policy 설정**
```bash
# CPU 사용률 기반 스케일링 정책
aws autoscaling put-scaling-policy \
    --auto-scaling-group-name WebServerASG \
    --policy-name CPUScalingPolicy \
    --policy-type TargetTrackingScaling \
    --target-tracking-configuration '{
        "PredefinedMetricSpecification": {
            "PredefinedMetricType": "ASGAverageCPUUtilization"
        },
        "TargetValue": 70.0
    }'
```

---

## ☁️ **GCP Auto Scaling 설정**

### **Instance Template 생성**
```bash
# Instance Template 생성
gcloud compute instance-templates create web-server-template \
    --machine-type=e2-micro \
    --network=default \
    --subnet=default \
    --tags=http-server \
    --image-family=debian-11 \
    --image-project=debian-cloud \
    --metadata-from-file startup-script=startup-script.sh
```

### **Instance Group 생성**
```bash
# Managed Instance Group 생성
gcloud compute instance-groups managed create web-server-group \
    --base-instance-name=web-server \
    --template=web-server-template \
    --size=2 \
    --zone=us-central1-a

# Auto Scaling 설정
gcloud compute instance-groups managed set-autoscaling web-server-group \
    --max-num-replicas=10 \
    --min-num-replicas=2 \
    --target-cpu-utilization=0.7 \
    --zone=us-central1-a
```

---

## ⚖️ **로드 밸런서 종류 및 설정**

### **AWS 로드 밸런서**

#### **Application Load Balancer (ALB)**
- **계층**: 7계층 (애플리케이션)
- **특징**: HTTP/HTTPS 트래픽 처리, 경로 기반 라우팅
- **사용 사례**: 웹 애플리케이션, 마이크로서비스

```bash
# ALB 생성
aws elbv2 create-load-balancer \
    --name WebServerALB \
    --subnets subnet-12345678 subnet-87654321 \
    --security-groups sg-12345678 \
    --scheme internet-facing \
    --type application

# Target Group 생성
aws elbv2 create-target-group \
    --name WebServerTG \
    --protocol HTTP \
    --port 80 \
    --vpc-id vpc-12345678 \
    --target-type instance \
    --health-check-path /health \
    --health-check-interval-seconds 30
```

#### **Network Load Balancer (NLB)**
- **계층**: 4계층 (전송)
- **특징**: TCP/UDP 트래픽 처리, 고성능
- **사용 사례**: 게임 서버, 실시간 스트리밍

```bash
# NLB 생성
aws elbv2 create-load-balancer \
    --name GameServerNLB \
    --subnets subnet-12345678 subnet-87654321 \
    --security-groups sg-12345678 \
    --scheme internet-facing \
    --type network
```

### **GCP 로드 밸런서**

#### **HTTP(S) Load Balancing**
```bash
# Backend Service 생성
gcloud compute backend-services create web-backend \
    --global \
    --load-balancing-scheme=EXTERNAL_MANAGED \
    --protocol=HTTP \
    --port-name=http

# URL Map 생성
gcloud compute url-maps create web-load-balancer \
    --default-service web-backend

# HTTP Proxy 생성
gcloud compute target-http-proxies create http-lb-proxy \
    --url-map=web-load-balancer

# Forwarding Rule 생성
gcloud compute forwarding-rules create http-content-rule \
    --global \
    --target-http-proxy=http-lb-proxy \
    --ports=80
```

---

## 🎯 **고가용성 배포 전략**

### **Multi-AZ 배포 (AWS)**
```bash
# Auto Scaling Group을 여러 AZ에 배포
aws autoscaling create-auto-scaling-group \
    --auto-scaling-group-name WebServerASG \
    --launch-template LaunchTemplateName=WebServerTemplate,Version=\$Latest \
    --min-size 2 \
    --max-size 10 \
    --desired-capacity 2 \
    --vpc-zone-identifier "subnet-az1,subnet-az2,subnet-az3" \
    --health-check-type ELB \
    --health-check-grace-period 300
```

### **Multi-Region 배포 (GCP)**
```bash
# 여러 리전에 Instance Group 생성
gcloud compute instance-groups managed create web-server-group-us \
    --base-instance-name=web-server \
    --template=web-server-template \
    --size=2 \
    --zone=us-central1-a

gcloud compute instance-groups managed create web-server-group-eu \
    --base-instance-name=web-server \
    --template=web-server-template \
    --size=2 \
    --zone=europe-west1-b
```

---

## 📊 **모니터링 및 알림**

### **AWS CloudWatch 설정**
```bash
# CPU 사용률 알림 설정
aws cloudwatch put-metric-alarm \
    --alarm-name HighCPUAlarm \
    --alarm-description "CPU 사용률이 높을 때 알림" \
    --metric-name CPUUtilization \
    --namespace AWS/EC2 \
    --statistic Average \
    --period 300 \
    --threshold 80 \
    --comparison-operator GreaterThanThreshold \
    --evaluation-periods 2 \
    --alarm-actions "arn:aws:sns:region:account:topic-name"
```

### **GCP Cloud Monitoring 설정**
```bash
# CPU 사용률 알림 정책 생성
gcloud alpha monitoring policies create \
    --policy-from-file=cpu-alert-policy.yaml
```

---

## 🏢 **실제 사례 분석 (출처 기반)**

### **Netflix - Auto Scaling으로 글로벌 서비스 운영**
- **출처**: [Netflix Tech Blog - "Auto Scaling in the Cloud"](https://netflixtechblog.com/auto-scaling-in-the-cloud-9b5b0c3d471c)
- **도입 배경**: 글로벌 트래픽 변동에 대응하는 자동 스케일링 필요
- **구현 방식**:
  - CPU 사용률 기반 Auto Scaling Group
  - Multi-AZ 배포로 고가용성 확보
  - CloudWatch 메트릭 기반 알림
- **성과**: 
  - 99.99% 가용성 달성
  - 트래픽 피크 시 자동 확장
  - 운영 비용 최적화

### **Spotify - GCP Load Balancing으로 글로벌 서비스**
- **출처**: [Google Cloud Blog - "Spotify's Global Load Balancing"](https://cloud.google.com/blog/products/networking/spotifys-global-load-balancing)
- **도입 배경**: 글로벌 사용자에게 최적의 성능 제공 필요
- **구현 방식**:
  - HTTP(S) Load Balancing으로 글로벌 트래픽 분산
  - CDN과 연동하여 콘텐츠 전송 최적화
  - Health Check로 백엔드 서비스 모니터링
- **성과**:
  - 글로벌 지연시간 50% 감소
  - 지역별 사용자 경험 향상
  - 서비스 가용성 99.9% 달성

### **Airbnb - AWS Auto Scaling으로 비용 최적화**
- **출처**: [AWS re:Invent 2019 - "Airbnb's Cost Optimization"](https://www.youtube.com/watch?v=KXzNo0qI0c8)
- **도입 배경**: 계절별 트래픽 변동에 따른 비용 최적화 필요
- **구현 방식**:
  - 예측 기반 스케일링 (Predictive Scaling)
  - 스팟 인스턴스 활용으로 비용 절감
  - 시간 기반 스케일링으로 리소스 효율성 향상
- **성과**:
  - 클라우드 비용 25% 절감
  - 리소스 활용률 40% 향상
  - 자동화된 운영으로 인력 효율성 증대

---

## 🛠️ **실습: Auto Scaling + 로드 밸런서 구성**

### **1단계: 인프라 생성**
```bash
# VPC 및 서브넷 생성
aws ec2 create-vpc --cidr-block 10.0.0.0/16
aws ec2 create-subnet --vpc-id vpc-12345678 --cidr-block 10.0.1.0/24 --availability-zone us-east-1a
aws ec2 create-subnet --vpc-id vpc-12345678 --cidr-block 10.0.2.0/24 --availability-zone us-east-1b
```

### **2단계: 보안 그룹 설정**
```bash
# 웹 서버 보안 그룹 생성
aws ec2 create-security-group \
    --group-name WebServerSG \
    --description "Web Server Security Group" \
    --vpc-id vpc-12345678

# HTTP 및 SSH 허용
aws ec2 authorize-security-group-ingress \
    --group-id sg-12345678 \
    --protocol tcp \
    --port 80 \
    --cidr 0.0.0.0/0

aws ec2 authorize-security-group-ingress \
    --group-id sg-12345678 \
    --protocol tcp \
    --port 22 \
    --cidr 0.0.0.0/0
```

### **3단계: 로드 밸런서 및 Auto Scaling 구성**
```bash
# ALB 생성
aws elbv2 create-load-balancer \
    --name WebServerALB \
    --subnets subnet-12345678 subnet-87654321 \
    --security-groups sg-12345678

# Target Group 생성
aws elbv2 create-target-group \
    --name WebServerTG \
    --protocol HTTP \
    --port 80 \
    --vpc-id vpc-12345678

# Auto Scaling Group 생성
aws autoscaling create-auto-scaling-group \
    --auto-scaling-group-name WebServerASG \
    --launch-template LaunchTemplateName=WebServerTemplate,Version=\$Latest \
    --min-size 2 \
    --max-size 10 \
    --desired-capacity 2 \
    --vpc-zone-identifier "subnet-12345678,subnet-87654321" \
    --target-group-arns "arn:aws:elasticloadbalancing:region:account:targetgroup/WebServerTG/1234567890123456"
```

---

## 🎯 **성능 최적화 팁 (업계 모범 사례)**

### **Auto Scaling 최적화**
1. **Cooldown 설정**: 스케일링 간격 조정
   - **출처**: [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)
2. **Predictive Scaling**: 예측 기반 스케일링
   - **출처**: [AWS Auto Scaling Best Practices](https://docs.aws.amazon.com/autoscaling/ec2/userguide/auto-scaling-best-practices.html)
3. **Scheduled Scaling**: 시간 기반 스케일링
   - **출처**: [GCP Auto Scaling Documentation](https://cloud.google.com/compute/docs/autoscaler/scaling-schedules)

### **로드 밸런서 최적화**
1. **Health Check 설정**: 적절한 경로와 간격
   - **출처**: [AWS Load Balancer Best Practices](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-best-practices.html)
2. **Sticky Sessions**: 세션 유지 설정
   - **출처**: [GCP Load Balancing Best Practices](https://cloud.google.com/load-balancing/docs/best-practices)
3. **Connection Draining**: 안전한 인스턴스 제거
   - **출처**: [AWS Auto Scaling Best Practices](https://docs.aws.amazon.com/autoscaling/ec2/userguide/auto-scaling-best-practices.html)

---

## 🚨 **문제 해결 및 디버깅**

### **일반적인 문제**
1. **Auto Scaling이 작동하지 않음**
   - CloudWatch 메트릭 확인
   - IAM 권한 점검
   - Launch Template 설정 검증

2. **로드 밸런서 트래픽 분산 안됨**
   - Target Group 상태 확인
   - 보안 그룹 규칙 점검
   - Health Check 설정 검증

### **디버깅 명령어**
```bash
# Auto Scaling Group 상태 확인
aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names WebServerASG

# 로드 밸런서 상태 확인
aws elbv2 describe-load-balancers --names WebServerALB

# Target Group 상태 확인
aws elbv2 describe-target-health --target-group-arn arn:aws:elasticloadbalancing:region:account:targetgroup/WebServerTG/1234567890123456
```

---

## 🎯 **다음 단계**
- [Day 7: 보안 및 DevOps 심화](./7-1_security_compliance.md) 준비
- Auto Scaling 및 로드 밸런서 모니터링 대시보드 구성
- 실제 트래픽을 통한 성능 테스트

## 📚 **추가 학습 자료**
- [AWS Auto Scaling User Guide](https://docs.aws.amazon.com/autoscaling/ec2/userguide/)
- [Google Cloud Load Balancing](https://cloud.google.com/load-balancing/docs)
- [AWS Well-Architected Framework - Performance](https://aws.amazon.com/architecture/well-architected/)
- [GCP Architecture Framework - Performance](https://cloud.google.com/architecture/framework/performance)
- [Netflix Auto Scaling Case Study](https://netflixtechblog.com/auto-scaling-in-the-cloud-9b5b0c3d471c)
- [Spotify Load Balancing Case Study](https://cloud.google.com/blog/products/networking/spotifys-global-load-balancing)
