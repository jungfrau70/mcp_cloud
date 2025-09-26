# Auto Scaling 가이드


---

## 🎯 학습 목표

### 핵심 학습 목표
- **AWS Auto Scaling Group**: ASG 구성 및 정책 설정
- **GCP Managed Instance Group**: MIG 구성 및 자동 확장
- **스케일링 메트릭**: CPU, 메모리, 커스텀 메트릭 기반 스케일링
- **스케일링 정책**: Scale-out, Scale-in 정책 최적화

### 실습 후 달성할 수 있는 능력
- ✅ AWS Auto Scaling Group을 통한 자동 확장/축소 구성
- ✅ GCP Managed Instance Group을 통한 자동 확장 설정
- ✅ CloudWatch/Cloud Monitoring 기반 스케일링 메트릭 설정
- ✅ 고가용성 및 비용 최적화를 위한 스케일링 정책 구축

---

## 📚 이론 학습

### AWS Auto Scaling Group [ASG]

#### 기본 개념
- **Auto Scaling Group**: EC2 인스턴스의 자동 확장/축소 관리
- **Launch Template**: 인스턴스 생성 템플릿
- **Scaling Policy**: 확장/축소 정책
- **Health Check**: 인스턴스 상태 모니터링

#### 스케일링 정책 유형
- **Target Tracking**: 목표 메트릭 기반 자동 조정
- **Simple Scaling**: 단일 알람 기반 스케일링
- **Step Scaling**: 단계별 스케일링
- **Predictive Scaling**: 예측 기반 스케일링

### GCP Managed Instance Group [MIG]

#### 기본 개념
- **Managed Instance Group**: VM 인스턴스의 자동 관리
- **Instance Template**: VM 생성 템플릿
- **Auto Scaling Policy**: 확장/축소 정책
- **Health Check**: 인스턴스 상태 모니터링

#### 스케일링 모드
- **Off**: 자동 스케일링 비활성화
- **On**: 자동 스케일링 활성화
- **Only Scale Out**: 확장만 허용

---

## 🛠️ 실습 학습

### 실습 환경 준비

#### 1. AWS 환경 설정
```bash
# AWS CLI 설정 확인
aws sts get-caller-identity

# 리전 설정
export AWS_DEFAULT_REGION=ap-northeast-2
```

#### 2. GCP 환경 설정
```bash
# GCP 인증 확인
gcloud auth list

# 프로젝트 설정
export PROJECT_ID=your-project-id
gcloud config set project $PROJECT_ID
```

### AWS Auto Scaling Group 실습

#### 1단계: Launch Template 생성
```bash
# Launch Template 생성
LAUNCH_TEMPLATE_ID=$[aws ec2 create-launch-template /
    --launch-template-name web-server-template /
    --launch-template-data '{
        "ImageId": "ami-0c76973fbe0ee100c",
        "InstanceType": "t2.micro",
        "KeyName": "load-balancer-key",
        "SecurityGroupIds": ["'$EC2_SG'"],
        "UserData": "'$[base64 -w 0 user-data.sh]'"
    }' /
    --query 'LaunchTemplate.LaunchTemplateId' --output text]
```

#### 2단계: Auto Scaling Group 생성
```bash
# Auto Scaling Group 생성
aws autoscaling create-auto-scaling-group /
    --auto-scaling-group-name web-server-asg /
    --launch-template LaunchTemplateId=$LAUNCH_TEMPLATE_ID,Version='$Latest' /
    --min-size 1 /
    --max-size 5 /
    --desired-capacity 2 /
    --target-group-arns $TARGET_GROUP_ARN /
    --health-check-type ELB /
    --health-check-grace-period 300 /
    --vpc-zone-identifier "$SUBNET_1,$SUBNET_2"
```

#### 3단계: 스케일링 정책 생성
```bash
# Scale-out 정책 ["CPU 사용률 70% 초과 시"]
aws autoscaling put-scaling-policy /
    --auto-scaling-group-name web-server-asg /
    --policy-name scale-out-policy /
    --policy-type TargetTrackingScaling /
    --target-tracking-config '{
        "TargetValue": 70.0,
        "PredefinedMetricSpecification": {
            "PredefinedMetricType": "ASGAverageCPUUtilization"
        }
    }'

# Scale-in 정책 ["CPU 사용률 30% 미만 시"]
aws autoscaling put-scaling-policy /
    --auto-scaling-group-name web-server-asg /
    --policy-name scale-in-policy /
    --policy-type TargetTrackingScaling /
    --target-tracking-config '{
        "TargetValue": 30.0,
        "PredefinedMetricType": "ASGAverageCPUUtilization"
    }'
```

#### 4단계: CloudWatch 알람 설정
```bash
# CPU 사용률 알람 생성
aws cloudwatch put-metric-alarm /
    --alarm-name "High CPU Utilization" /
    --alarm-description "Alarm when CPU exceeds 70%" /
    --metric-name CPUUtilization /
    --namespace AWS/EC2 /
    --statistic Average /
    --period 300 /
    --threshold 70.0 /
    --comparison-operator GreaterThanThreshold /
    --evaluation-periods 2 /
    --alarm-actions arn:aws:autoscaling:ap-northeast-2:ACCOUNT_ID:scalingPolicy:POLICY_ID:autoScalingGroupName/web-server-asg:policyName/scale-out-policy
```

### GCP Managed Instance Group 실습

#### 1단계: Instance Template 생성
```bash
# Instance Template 생성
gcloud compute instance-templates create web-server-template /
    --image-family=ubuntu-2004-lts /
    --image-project=ubuntu-os-cloud /
    --machine-type=e2-micro /
    --tags=web-server /
    --metadata=startup-script='#!/bin/bash
apt-get update
apt-get install -y nginx stress-ng
echo "Hello from $[hostname]" > /var/www/html/index.html
systemctl restart nginx'
```

#### 2단계: Managed Instance Group 생성
```bash
# Managed Instance Group 생성
gcloud compute instance-groups managed create web-server-mig /
    --template=web-server-template /
    --size=2 /
    --zone=asia-northeast3-a
```

#### 3단계: Auto Scaling 설정
```bash
# Auto Scaling 설정
gcloud compute instance-groups managed set-autoscaling web-server-mig /
    --zone=asia-northeast3-a /
    --max-num-replicas=5 /
    --min-num-replicas=1 /
    --target-cpu-utilization=0.7 /
    --cool-down-period=60
```

#### 4단계: Health Check 설정
```bash
# Health Check 생성
gcloud compute health-checks create http web-health-check /
    --port=80 /
    --request-path=/

# Auto Healing 설정
gcloud compute instance-groups managed set-autohealing web-server-mig /
    --zone=asia-northeast3-a /
    --health-check=web-health-check /
    --initial-delay=300
```

---

## 🔧 고급 설정

### 커스텀 메트릭 기반 스케일링

#### AWS CloudWatch 커스텀 메트릭
```bash
# 커스텀 메트릭 전송
aws cloudwatch put-metric-data /
    --namespace "Custom/WebServer" /
    --metric-data MetricName=ActiveConnections,Value=150,Unit=Count

# 커스텀 메트릭 기반 스케일링 정책
aws autoscaling put-scaling-policy /
    --auto-scaling-group-name web-server-asg /
    --policy-name custom-metric-policy /
    --policy-type TargetTrackingScaling /
    --target-tracking-config '{
        "TargetValue": 100.0,
        "CustomizedMetricSpecification": {
            "MetricName": "ActiveConnections",
            "Namespace": "Custom/WebServer",
            "Statistic": "Average"
        }
    }'
```

#### GCP Cloud Monitoring 커스텀 메트릭
```bash
# 커스텀 메트릭 생성
gcloud monitoring metrics-descriptors create /
    --display-name="Active Connections" /
    --type="custom.googleapis.com/active_connections" /
    --metric-kind="GAUGE" /
    --value-type="INT64"

# 커스텀 메트릭 기반 스케일링
gcloud compute instance-groups managed set-autoscaling web-server-mig /
    --zone=asia-northeast3-a /
    --custom-metric-utilization metric=custom.googleapis.com/active_connections,utilization-target=0.8,utilization-target-type=GAUGE
```

### 예측 기반 스케일링 [AWS]

```bash
# 예측 스케일링 활성화
aws autoscaling put-scaling-policy /
    --auto-scaling-group-name web-server-asg /
    --policy-name predictive-scaling-policy /
    --policy-type PredictiveScaling /
    --predictive-scaling-configuration '{
        "MetricSpecifications": [{
            "TargetValue": 70.0,
            "PredefinedMetricSpecification": {
                "PredefinedMetricType": "ASGAverageCPUUtilization"
            }
        }],
        "Mode": "ForecastAndScale",
        "SchedulingBufferTime": 10
    }'
```

---

## 📊 모니터링 및 테스트

### Auto Scaling 상태 확인
```bash
# AWS ASG 상태 확인
aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names web-server-asg
aws autoscaling describe-scaling-activities --auto-scaling-group-name web-server-asg

# GCP MIG 상태 확인
gcloud compute instance-groups managed describe web-server-mig --zone=asia-northeast3-a
gcloud compute instance-groups managed list-instances web-server-mig --zone=asia-northeast3-a
```

### 부하 테스트 및 스케일링 확인
```bash
# CPU 부하 생성 ["stress-ng 사용"]
stress-ng --cpu 4 --timeout 300s

# 메모리 부하 생성
stress-ng --vm 2 --vm-bytes 1G --timeout 300s

# 스케일링 활동 모니터링
watch -n 5 'aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names web-server-asg --query "AutoScalingGroups[0].Instances[].{InstanceId:InstanceId,LifecycleState:LifecycleState,HealthStatus:HealthStatus}"'
```

---

## 🚨 문제 해결

### 일반적인 문제

#### 1. Auto Scaling이 작동하지 않음
- **원인**: CloudWatch 메트릭 부족, 권한 문제
- **해결방법**:
  ```bash
  # CloudWatch 메트릭 확인
  aws cloudwatch get-metric-statistics /
      --namespace AWS/EC2 /
      --metric-name CPUUtilization /
      --dimensions Name=AutoScalingGroupName,Value=web-server-asg /
      --start-time 2023-01-01T00:00:00Z /
      --end-time 2023-01-01T23:59:59Z /
      --period 300 /
      --statistics Average
  ```

#### 2. 인스턴스가 계속 종료됨
- **원인**: Health Check 실패, Launch Template 문제
- **해결방법**:
  ```bash
  # Health Check 상태 확인
  aws autoscaling describe-auto-scaling-groups /
      --auto-scaling-group-names web-server-asg /
      --query "AutoScalingGroups[0].Instances[].{InstanceId:InstanceId,HealthStatus:HealthStatus,LifecycleState:LifecycleState}"
  ```

#### 3. 스케일링 정책이 너무 민감함
- **원인**: 임계값 설정 문제, 쿨다운 시간 부족
- **해결방법**:
  ```bash
  # 스케일링 정책 수정
  aws autoscaling put-scaling-policy /
      --auto-scaling-group-name web-server-asg /
      --policy-name scale-out-policy /
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

---

## 📚 참고 자료

### AWS 공식 문서
- ["Auto Scaling Group 가이드"][https:///docs.aws.amazon.com/autoscaling/ec2/userguide/]
- ["Target Tracking Scaling 정책"][https:///docs.aws.amazon.com/autoscaling/ec2/userguide/target-tracking-scaling-policy.html]

### GCP 공식 문서
- ["Managed Instance Groups 가이드"][https:///cloud.google.com/compute/docs/instance-groups/]
- ["Auto Scaling 가이드"][https:///cloud.google.com/compute/docs/autoscaler/]

### 추가 학습 자료
- ["Auto Scaling 모범 사례"][https:///aws.amazon.com/autoscaling/faqs/]
- ["비용 최적화를 위한 스케일링 전략"][https:///cloud.google.com/compute/docs/autoscaler/optimizing-costs]

---



<div align="center">

["← 이전: 로드 밸런싱 가이드"](cloud_master/textbook/Day3/guides/load-balancing-guide.md) | ["📚 전체 커리큘럼"](curriculum.md) | ["🏠 학습 경로로 돌아가기"](index.md)

</div>