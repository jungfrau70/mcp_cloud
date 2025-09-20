# 통합 가이드 - 로드 밸런서 + 오토스케일링 연동


---

## 🎯 학습 목표

### 핵심 학습 목표
- **로드 밸런서 + Auto Scaling 연동**: 완전 자동화된 고가용성 아키텍처
- **Health Check 통합**: 로드 밸런서와 Auto Scaling 간 상태 동기화
- **트래픽 분산**: 자동 확장된 인스턴스에 트래픽 자동 분산
- **장애 복구**: 인스턴스 장애 시 자동 교체 및 트래픽 전환

### 실습 후 달성할 수 있는 능력
- ✅ AWS ELB + ASG 통합 아키텍처 구축
- ✅ GCP Cloud Load Balancing + MIG 통합 구성
- ✅ 완전 자동화된 고가용성 웹 애플리케이션 운영
- ✅ 트래픽 증가 시 자동 확장 및 부하 분산

---

## 📚 이론 학습

### 통합 아키텍처의 핵심 구성요소

#### 1. 로드 밸런서 (Traffic Distribution)
- **트래픽 분산**: 여러 인스턴스에 요청 분산
- **Health Check**: 인스턴스 상태 모니터링
- **SSL 종료**: HTTPS 트래픽 처리
- **Sticky Session**: 세션 유지 (필요시)

#### 2. Auto Scaling Group (Instance Management)
- **자동 확장**: 부하 증가 시 인스턴스 추가
- **자동 축소**: 부하 감소 시 인스턴스 제거
- **Health Check**: 인스턴스 상태 모니터링
- **Launch Template**: 인스턴스 생성 템플릿

#### 3. 통합 Health Check
- **ELB Health Check**: 로드 밸런서 레벨 상태 확인
- **ASG Health Check**: Auto Scaling 그룹 레벨 상태 확인
- **Application Health Check**: 애플리케이션 레벨 상태 확인

### 고가용성 아키텍처 패턴

#### Multi-AZ 배포
- **가용 영역 분산**: 여러 AZ에 인스턴스 배치
- **장애 격리**: 한 AZ 장애 시 다른 AZ에서 서비스 지속
- **데이터 동기화**: AZ 간 데이터 일관성 유지

#### Multi-Region 배포
- **지역 분산**: 여러 리전에 서비스 배포
- **글로벌 로드 밸런싱**: 사용자 위치 기반 트래픽 라우팅
- **재해 복구**: 한 리전 장애 시 다른 리전으로 전환

---

## 🛠️ 실습 학습

### 실습 환경 준비

#### 1. 통합 환경 설정
```bash
# AWS 환경 변수
export AWS_DEFAULT_REGION=ap-northeast-2
export PROJECT_NAME=integrated-web-app
export VPC_CIDR=10.0.0.0/16
export SUBNET_1_CIDR=10.0.1.0/24
export SUBNET_2_CIDR=10.0.2.0/24

# GCP 환경 변수
export PROJECT_ID=your-project-id
export ZONE=asia-northeast3-a
gcloud config set project $PROJECT_ID
```

#### 2. 공통 스크립트 생성
```bash
# user-data.sh 생성
cat > user-data.sh << 'EOF'
#!/bin/bash
apt-get update
apt-get install -y nginx stress-ng htop

# 웹 서버 설정
cat > /var/www/html/index.html << 'HTML'
<!DOCTYPE html>
<html>
<head>
    <title>Integrated Web App</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; }
        .container { max-width: 800px; margin: 0 auto; }
        .status { background: #f0f0f0; padding: 20px; border-radius: 5px; }
    </style>
</head>
<body>
    <div class="container">
        <h1>Integrated Web Application</h1>
        <div class="status">
            <h2>Server Information</h2>
            <p><strong>Hostname:</strong> $(hostname)</p>
            <p><strong>Instance ID:</strong> $(curl -s http://169.254.169.254/latest/meta-data/instance-id 2>/dev/null || echo "N/A")</p>
            <p><strong>Availability Zone:</strong> $(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone 2>/dev/null || echo "N/A")</p>
            <p><strong>Timestamp:</strong> $(date)</p>
        </div>
    </div>
</body>
</html>
HTML

systemctl restart nginx
systemctl enable nginx
EOF
```

### AWS 통합 아키텍처 구축

#### 1단계: VPC 및 네트워크 구성
```bash
# VPC 생성
VPC_ID=$(aws ec2 create-vpc --cidr-block $VPC_CIDR --query 'Vpc.VpcId' --output text)
aws ec2 create-tags --resources $VPC_ID --tags Key=Name,Value=$PROJECT_NAME-vpc

# 인터넷 게이트웨이 생성 및 연결
IGW_ID=$(aws ec2 create-internet-gateway --query 'InternetGateway.InternetGatewayId' --output text)
aws ec2 attach-internet-gateway --vpc-id $VPC_ID --internet-gateway-id $IGW_ID
aws ec2 create-tags --resources $IGW_ID --tags Key=Name,Value=$PROJECT_NAME-igw

# 서브넷 생성 (Multi-AZ)
SUBNET_1=$(aws ec2 create-subnet --vpc-id $VPC_ID --cidr-block $SUBNET_1_CIDR --availability-zone ap-northeast-2a --query 'Subnet.SubnetId' --output text)
SUBNET_2=$(aws ec2 create-subnet --vpc-id $VPC_ID --cidr-block $SUBNET_2_CIDR --availability-zone ap-northeast-2c --query 'Subnet.SubnetId' --output text)

# 라우팅 테이블 생성 및 설정
RT_ID=$(aws ec2 create-route-table --vpc-id $VPC_ID --query 'RouteTable.RouteTableId' --output text)
aws ec2 create-route --route-table-id $RT_ID --destination-cidr-block 0.0.0.0/0 --gateway-id $IGW_ID
aws ec2 associate-route-table --subnet-id $SUBNET_1 --route-table-id $RT_ID
aws ec2 associate-route-table --subnet-id $SUBNET_2 --route-table-id $RT_ID
```

#### 2단계: 보안 그룹 구성
```bash
# ALB 보안 그룹
ALB_SG=$(aws ec2 create-security-group --group-name $PROJECT_NAME-alb-sg --description "ALB Security Group" --vpc-id $VPC_ID --query 'GroupId' --output text)
aws ec2 authorize-security-group-ingress --group-id $ALB_SG --protocol tcp --port 80 --cidr 0.0.0.0/0
aws ec2 authorize-security-group-ingress --group-id $ALB_SG --protocol tcp --port 443 --cidr 0.0.0.0/0

# EC2 보안 그룹
EC2_SG=$(aws ec2 create-security-group --group-name $PROJECT_NAME-ec2-sg --description "EC2 Security Group" --vpc-id $VPC_ID --query 'GroupId' --output text)
aws ec2 authorize-security-group-ingress --group-id $EC2_SG --protocol tcp --port 80 --source-group $ALB_SG
aws ec2 authorize-security-group-ingress --group-id $EC2_SG --protocol tcp --port 22 --cidr 0.0.0.0/0
aws ec2 authorize-security-group-ingress --group-id $EC2_SG --protocol tcp --port 80 --cidr 10.0.0.0/16
```

#### 3단계: Launch Template 생성
```bash
# 키 페어 생성
aws ec2 create-key-pair --key-name $PROJECT_NAME-key --query 'KeyMaterial' --output text > $PROJECT_NAME-key.pem
chmod 400 $PROJECT_NAME-key.pem

# Launch Template 생성
LAUNCH_TEMPLATE_ID=$(aws ec2 create-launch-template /
    --launch-template-name $PROJECT_NAME-template /
    --launch-template-data '{
        "ImageId": "ami-0c76973fbe0ee100c",
        "InstanceType": "t2.micro",
        "KeyName": "'$PROJECT_NAME'-key",
        "SecurityGroupIds": ["'$EC2_SG'"],
        "UserData": "'$(base64 -w 0 user-data.sh)'",
        "TagSpecifications": [{
            "ResourceType": "instance",
            "Tags": [{"Key": "Name", "Value": "'$PROJECT_NAME'-instance"}]
        }]
    }' /
    --query 'LaunchTemplate.LaunchTemplateId' --output text)
```

#### 4단계: Target Group 및 ALB 생성
```bash
# Target Group 생성
TARGET_GROUP_ARN=$(aws elbv2 create-target-group /
    --name $PROJECT_NAME-targets /
    --protocol HTTP /
    --port 80 /
    --vpc-id $VPC_ID /
    --health-check-path / /
    --health-check-interval-seconds 30 /
    --health-check-timeout-seconds 5 /
    --healthy-threshold-count 2 /
    --unhealthy-threshold-count 3 /
    --query 'TargetGroups[0].TargetGroupArn' --output text)

# ALB 생성
ALB_ARN=$(aws elbv2 create-load-balancer /
    --name $PROJECT_NAME-alb /
    --subnets $SUBNET_1 $SUBNET_2 /
    --security-groups $ALB_SG /
    --query 'LoadBalancers[0].LoadBalancerArn' --output text)

# ALB DNS 이름 확인
ALB_DNS=$(aws elbv2 describe-load-balancers --load-balancer-arns $ALB_ARN --query 'LoadBalancers[0].DNSName' --output text)
echo "ALB DNS: http://$ALB_DNS"

# 리스너 생성
aws elbv2 create-listener /
    --load-balancer-arn $ALB_ARN /
    --protocol HTTP /
    --port 80 /
    --default-actions Type=forward,TargetGroupArn=$TARGET_GROUP_ARN
```

#### 5단계: Auto Scaling Group 생성
```bash
# Auto Scaling Group 생성
aws autoscaling create-auto-scaling-group /
    --auto-scaling-group-name $PROJECT_NAME-asg /
    --launch-template LaunchTemplateId=$LAUNCH_TEMPLATE_ID,Version='$Latest' /
    --min-size 2 /
    --max-size 10 /
    --desired-capacity 2 /
    --target-group-arns $TARGET_GROUP_ARN /
    --health-check-type ELB /
    --health-check-grace-period 300 /
    --vpc-zone-identifier "$SUBNET_1,$SUBNET_2" /
    --tags ResourceId=$PROJECT_NAME-asg,ResourceType=auto-scaling-group,Key=Name,Value=$PROJECT_NAME-asg
```

#### 6단계: 스케일링 정책 설정
```bash
# Target Tracking Scaling 정책 생성
aws autoscaling put-scaling-policy /
    --auto-scaling-group-name $PROJECT_NAME-asg /
    --policy-name $PROJECT_NAME-target-tracking /
    --policy-type TargetTrackingScaling /
    --target-tracking-config '{
        "TargetValue": 70.0,
        "PredefinedMetricSpecification": {
            "PredefinedMetricType": "ASGAverageCPUUtilization"
        },
        "ScaleOutCooldown": 300,
        "ScaleInCooldown": 300
    }'
```

### GCP 통합 아키텍처 구축

#### 1단계: Instance Template 생성
```bash
# Instance Template 생성
gcloud compute instance-templates create $PROJECT_NAME-template /
    --image-family=ubuntu-2004-lts /
    --image-project=ubuntu-os-cloud /
    --machine-type=e2-micro /
    --tags=web-server /
    --metadata=startup-script='#!/bin/bash
apt-get update
apt-get install -y nginx stress-ng htop

# 웹 서버 설정
cat > /var/www/html/index.html << "HTML"
<!DOCTYPE html>
<html>
<head>
    <title>Integrated Web App</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; }
        .container { max-width: 800px; margin: 0 auto; }
        .status { background: #f0f0f0; padding: 20px; border-radius: 5px; }
    </style>
</head>
<body>
    <div class="container">
        <h1>Integrated Web Application</h1>
        <div class="status">
            <h2>Server Information</h2>
            <p><strong>Hostname:</strong> $(hostname)</p>
            <p><strong>Zone:</strong> $(curl -s http://metadata.google.internal/computeMetadata/v1/instance/zone -H "Metadata-Flavor: Google" | cut -d/ -f4)</p>
            <p><strong>Timestamp:</strong> $(date)</p>
        </div>
    </div>
</body>
</html>
HTML

systemctl restart nginx
systemctl enable nginx'
```

#### 2단계: Managed Instance Group 생성
```bash
# Managed Instance Group 생성
gcloud compute instance-groups managed create $PROJECT_NAME-mig /
    --template=$PROJECT_NAME-template /
    --size=2 /
    --zone=$ZONE

# Named Ports 설정
gcloud compute instance-groups managed set-named-ports $PROJECT_NAME-mig /
    --named-ports=http:80 /
    --zone=$ZONE
```

#### 3단계: Health Check 및 Backend Service 생성
```bash
# Health Check 생성
gcloud compute health-checks create http $PROJECT_NAME-health-check /
    --port=80 /
    --request-path=/ /
    --check-interval=30s /
    --timeout=5s /
    --healthy-threshold=2 /
    --unhealthy-threshold=3

# Backend Service 생성
gcloud compute backend-services create $PROJECT_NAME-backend /
    --protocol=HTTP /
    --health-checks=$PROJECT_NAME-health-check /
    --global

# Backend Service에 MIG 추가
gcloud compute backend-services add-backend $PROJECT_NAME-backend /
    --instance-group=$PROJECT_NAME-mig /
    --instance-group-zone=$ZONE /
    --global
```

#### 4단계: URL Map 및 Load Balancer 생성
```bash
# URL Map 생성
gcloud compute url-maps create $PROJECT_NAME-map /
    --default-service=$PROJECT_NAME-backend

# Target HTTP Proxy 생성
gcloud compute target-http-proxies create $PROJECT_NAME-proxy /
    --url-map=$PROJECT_NAME-map

# Forwarding Rule 생성
gcloud compute forwarding-rules create $PROJECT_NAME-rule /
    --global /
    --target-http-proxy=$PROJECT_NAME-proxy /
    --ports=80

# Load Balancer IP 확인
LB_IP=$(gcloud compute forwarding-rules describe $PROJECT_NAME-rule --global --format="value(IPAddress)")
echo "Load Balancer IP: http://$LB_IP"
```

#### 5단계: Auto Scaling 설정
```bash
# Auto Scaling 설정
gcloud compute instance-groups managed set-autoscaling $PROJECT_NAME-mig /
    --zone=$ZONE /
    --max-num-replicas=10 /
    --min-num-replicas=2 /
    --target-cpu-utilization=0.7 /
    --cool-down-period=60

# Auto Healing 설정
gcloud compute instance-groups managed set-autohealing $PROJECT_NAME-mig /
    --zone=$ZONE /
    --health-check=$PROJECT_NAME-health-check /
    --initial-delay=300
```

---

## 🔧 통합 테스트 및 모니터링

### 부하 테스트 실행
```bash
# Apache Bench를 사용한 부하 테스트
ab -n 1000 -c 10 http://$ALB_DNS/

# 지속적인 부하 테스트 (스케일링 확인용)
while true; do
    ab -n 100 -c 5 http://$ALB_DNS/ > /dev/null 2>&1
    sleep 10
done &
```

### 모니터링 대시보드
```bash
# AWS CloudWatch 메트릭 확인
aws cloudwatch get-metric-statistics /
    --namespace AWS/ApplicationELB /
    --metric-name RequestCount /
    --dimensions Name=LoadBalancer,Value=$ALB_ARN /
    --start-time $(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%S) /
    --end-time $(date -u +%Y-%m-%dT%H:%M:%S) /
    --period 300 /
    --statistics Sum

# GCP Cloud Monitoring 메트릭 확인
gcloud monitoring metrics list --filter="metric.type:loadbalancing.googleapis.com/request_count"
```

### 상태 확인 스크립트
```bash
# 통합 상태 확인 스크립트
cat > check-status.sh << 'EOF'
#!/bin/bash

echo "=== Integrated Web App Status ==="
echo "Timestamp: $(date)"
echo ""

# AWS 상태 확인
if command -v aws &> /dev/null; then
    echo "--- AWS Status ---"
    echo "ALB DNS: $ALB_DNS"
    echo "ASG Instances:"
    aws autoscaling describe-auto-scaling-groups /
        --auto-scaling-group-names $PROJECT_NAME-asg /
        --query "AutoScalingGroups[0].Instances[].{InstanceId:InstanceId,LifecycleState:LifecycleState,HealthStatus:HealthStatus}" /
        --output table
    echo ""
fi

# GCP 상태 확인
if command -v gcloud &> /dev/null; then
    echo "--- GCP Status ---"
    echo "Load Balancer IP: $LB_IP"
    echo "MIG Instances:"
    gcloud compute instance-groups managed list-instances $PROJECT_NAME-mig /
        --zone=$ZONE /
        --format="table(instance,status,healthState)"
    echo ""
fi

# 웹 서비스 테스트
echo "--- Web Service Test ---"
if [ ! -z "$ALB_DNS" ]; then
    echo "AWS ALB Response:"
    curl -s http://$ALB_DNS/ | grep -o '<title>.*</title>' || echo "Connection failed"
fi

if [ ! -z "$LB_IP" ]; then
    echo "GCP Load Balancer Response:"
    curl -s http://$LB_IP/ | grep -o '<title>.*</title>' || echo "Connection failed"
fi
EOF

chmod +x check-status.sh
```

---

## 🚨 문제 해결

### 일반적인 문제

#### 1. Auto Scaling이 작동하지 않음
- **원인**: Target Group에 인스턴스가 등록되지 않음
- **해결방법**:
  ```bash
  # Target Group 상태 확인
  aws elbv2 describe-target-health --target-group-arn $TARGET_GROUP_ARN
  
  # ASG 인스턴스 상태 확인
  aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names $PROJECT_NAME-asg
  ```

#### 2. 로드 밸런서가 인스턴스를 찾지 못함
- **원인**: 보안 그룹 설정, Health Check 실패
- **해결방법**:
  ```bash
  # 보안 그룹 규칙 확인
  aws ec2 describe-security-groups --group-ids $EC2_SG $ALB_SG
  
  # Health Check 설정 확인
  aws elbv2 describe-target-groups --target-group-arns $TARGET_GROUP_ARN
  ```

#### 3. 스케일링이 너무 자주 발생함
- **원인**: 임계값 설정 문제, 쿨다운 시간 부족
- **해결방법**:
  ```bash
  # 스케일링 정책 수정
  aws autoscaling put-scaling-policy /
      --auto-scaling-group-name $PROJECT_NAME-asg /
      --policy-name $PROJECT_NAME-target-tracking /
      --policy-type TargetTrackingScaling /
      --target-tracking-config '{
          "TargetValue": 70.0,
          "PredefinedMetricSpecification": {
              "PredefinedMetricType": "ASGAverageCPUUtilization"
          },
          "ScaleOutCooldown": 600,
          "ScaleInCooldown": 600
      }'
  ```

---

## 📚 참고 자료

### AWS 통합 아키텍처
- [ELB + Auto Scaling 가이드](https:///docs.aws.amazon.com/autoscaling/ec2/userguide/autoscaling-load-balancer.html)
- [Target Tracking Scaling 정책](https:///docs.aws.amazon.com/autoscaling/ec2/userguide/target-tracking-scaling-policy.html)

### GCP 통합 아키텍처
- [Cloud Load Balancing + MIG 가이드](https:///cloud.google.com/compute/docs/load-balancing/http/backend-service)
- [Auto Scaling 가이드](https:///cloud.google.com/compute/docs/autoscaler/)

### 모니터링 및 최적화
- [CloudWatch 메트릭 가이드](https:///docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/cloudwatch_concepts.html)
- [Cloud Monitoring 가이드](https:///cloud.google.com/monitoring/docs)

---



<div align="center">

[← 이전: Auto Scaling 가이드](cloud_master/textbook/Day3/guides/auto-scaling-guide.md) | [📚 전체 커리큘럼](curriculum.md) | [🏠 학습 경로로 돌아가기](index.md)

</div>