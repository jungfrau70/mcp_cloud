# 비용 최적화 실습 가이드

## 🎯 학습 목표

### 핵심 학습 목표
- **AWS 비용 최적화** Reserved Instances, Spot Instances, Savings Plans
- **GCP 비용 최적화** Committed Use Discounts, Preemptible Instances
- **리소스 모니터링** Cost Explorer, Billing Alerts, Budget 설정
- **자동화된 비용 관리** 태깅, 리소스 정리, 비용 알림

### 실습 후 달성할 수 있는 능력
- ✅ AWS/GCP 비용 최적화 전략 구현
- ✅ Reserved Instances 및 Committed Use Discounts 활용
- ✅ Spot/Preemptible Instances를 이용한 비용 절감
- ✅ 자동화된 비용 모니터링 및 알림 시스템 구축

### 예상 소요 시간
- **AWS 비용 최적화**: 90-120분
- **GCP 비용 최적화**: 90-120분
- **리소스 모니터링**: 60-90분
- **자동화된 비용 관리**: 90-120분
- **전체 과정**: 5-7시간

---

## 🛠️ 실습 학습

### 📁 실습 코드 및 자동화
- **실습 샘플 코드**: `/mcp_knowledge_base/cloud_master/repos/samples/day3/my-app/`
- **자동화 스크립트**: `/mcp_knowledge_base/cloud_master/repos/automation/day3/cost_optimization.sh`
- **클라우드 스크립트**: `/mcp_knowledge_base/cloud_master/repos/cloud-scripts/`

<details>
<summary>🚀 실습 환경 준비</summary>

#### 필수 도구
- **AWS CLI**: 2.0 이상
- **gcloud CLI**: 400.0 이상
- **Terraform**: 1.0 이상
- **AWS Cost Explorer API**: 활성화 필요

#### 환경 설정
```bash
# AWS CLI 설정 확인
aws sts get-caller-identity

# gcloud CLI 설정 확인
gcloud auth list

# Terraform 설치 확인
terraform version

# AWS Cost Explorer API 활성화
aws ce get-cost-and-usage --time-period Start=2023-01-01,End=2023-01-02 --granularity MONTHLY --metrics BlendedCost
```

</details>

<details>
<summary>🔧 1단계: AWS 비용 최적화</summary>

#### Reserved Instances 구매
```bash
# Reserved Instances 구매
aws ec2 purchase-reserved-instances-offering /
  --reserved-instances-offering-id 12345678-1234-1234-1234-123456789012 /
  --instance-count 1

# Reserved Instances 목록 확인
aws ec2 describe-reserved-instances

# Reserved Instances 수정
aws ec2 modify-reserved-instances /
  --reserved-instances-ids r-12345678 /
  --target-configurations '{
    "ReservedInstancesId": "r-12345678",
    "TargetConfiguration": {
      "AvailabilityZone": "us-west-2a",
      "InstanceCount": 1,
      "InstanceType": "t3.micro"
    }
  }'
```

#### Spot Instances 활용
```bash
# Spot Instance 요청
aws ec2 request-spot-instances /
  --spot-price "0.01" /
  --instance-count 1 /
  --type "one-time" /
  --launch-specification '{
    "ImageId": "ami-0c02fb55956c7d316",
    "InstanceType": "t3.micro",
    "KeyName": "my-key",
    "SecurityGroups": ["sg-12345"],
    "UserData": "'$[base64 -w 0 user-data.sh]'"
  }'

# Spot Instance 요청 상태 확인
aws ec2 describe-spot-instance-requests

# Spot Instance 요청 취소
aws ec2 cancel-spot-instance-requests --spot-instance-request-ids sir-12345678
```

#### Savings Plans 설정
```bash
# Compute Savings Plans 구매
aws savingsplans create-savings-plan /
  --savings-plan-offering-id "arn:aws:savingsplans::123456789012:offering/12345678-1234-1234-1234-123456789012" /
  --commitment "1000" /
  --upfront-payment-amount "1000" /
  --payment-option "All Upfront"

# Savings Plans 목록 확인
aws savingsplans describe-savings-plans

# Savings Plans 사용률 확인
aws savingsplans describe-savings-plans-utilization
```

#### Auto Scaling Group 비용 최적화
```yaml
# cost-optimized-asg.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: cost-optimization-config
data:
  mixed-instance-policy.yaml: |
    MixedInstancesPolicy:
      InstancesDistribution:
        OnDemandBaseCapacity: 0
        OnDemandPercentageAboveBaseCapacity: 20
        SpotAllocationStrategy: "diversified"
        SpotInstancePools: 4
      LaunchTemplate:
        LaunchTemplateSpecification:
          LaunchTemplateName: web-template
          Version: '$Latest'
        Overrides:
        - InstanceType: t3.micro
          WeightedCapacity: 1
        - InstanceType: t3.small
          WeightedCapacity: 2
        - InstanceType: t3.medium
          WeightedCapacity: 4
```

</details>

<details>
<summary>🔧 2단계: GCP 비용 최적화</summary>

#### Committed Use Discounts
```bash
# Committed Use Discount 생성
gcloud compute commitments create web-commitment /
  --plan 12-month /
  --resources vcpu=4,memory=16 /
  --region us-central1

# Committed Use Discount 목록 확인
gcloud compute commitments list

# Committed Use Discount 상세 정보
gcloud compute commitments describe web-commitment --region us-central1
```

#### Preemptible Instances 활용
```bash
# Preemptible Instance Group 생성
gcloud compute instance-groups managed create preemptible-group /
  --template web-template /
  --size 2 /
  --zone us-central1-a /
  --preemptible

# Preemptible Instance Group 자동 스케일링
gcloud compute instance-groups managed set-autoscaling preemptible-group /
  --max-num-replicas 10 /
  --min-num-replicas 2 /
  --target-cpu-utilization 0.7 /
  --zone us-central1-a
```

#### 커스텀 머신 타입 활용
```bash
# 커스텀 머신 타입으로 인스턴스 생성
gcloud compute instances create custom-instance /
  --custom-cpu 2 /
  --custom-memory 4 /
  --zone us-central1-a /
  --image-family ubuntu-2004-lts /
  --image-project ubuntu-os-cloud

# 커스텀 머신 타입 템플릿 생성
gcloud compute instance-templates create custom-template /
  --custom-cpu 1 /
  --custom-memory 2 /
  --machine-type custom-1-2048 /
  --zone us-central1-a
```

#### 리소스 태깅 및 라벨링
```bash
# 인스턴스에 라벨 추가
gcloud compute instances add-labels custom-instance /
  --labels environment=production,team=backend,cost-center=engineering /
  --zone us-central1-a

# 라벨 기반 리소스 필터링
gcloud compute instances list --filter="labels.environment=production"

# 라벨 기반 비용 분석
gcloud billing budgets list --billing-account=123456789012
```

</details>

<details>
<summary>🔧 3단계: 리소스 모니터링 및 알림</summary>

#### AWS Cost Explorer 설정
```bash
# Cost Explorer 데이터 활성화
aws ce get-cost-and-usage /
  --time-period Start=2023-01-01,End=2023-01-31 /
  --granularity MONTHLY /
  --metrics BlendedCost /
  --group-by Type=DIMENSION,Key=SERVICE

# 비용 및 사용량 보고서 생성
aws ce get-cost-and-usage /
  --time-period Start=2023-01-01,End=2023-01-31 /
  --granularity DAILY /
  --metrics BlendedCost,UsageQuantity /
  --group-by Type=DIMENSION,Key=SERVICE /
  --filter file://cost-filter.json
```

#### AWS Budget 설정
```bash
# Budget 생성
aws budgets create-budget /
  --account-id 123456789012 /
  --budget '{
    "BudgetName": "Monthly-Budget",
    "BudgetLimit": {
      "Amount": "1000",
      "Unit": "USD"
    },
    "TimeUnit": "MONTHLY",
    "BudgetType": "COST",
    "CostFilters": {
      "Service": ["Amazon Elastic Compute Cloud - Compute"]
    }
  }'

# Budget 알림 설정
aws budgets create-notification /
  --account-id 123456789012 /
  --budget-name "Monthly-Budget" /
  --notification '{
    "NotificationType": "ACTUAL",
    "ComparisonOperator": "GREATER_THAN",
    "Threshold": 80,
    "ThresholdType": "PERCENTAGE"
  }' /
  --subscribers '[
    {
      "SubscriptionType": "EMAIL",
      "Address": "admin@example.com"
    }
  ]'
```

#### GCP Billing 알림 설정
```bash
# Billing 계정 목록 확인
gcloud billing accounts list

# Budget 생성
gcloud billing budgets create /
  --billing-account=123456789012 /
  --display-name="Monthly Budget" /
  --budget-amount=1000USD /
  --threshold-rule=percent:80 /
  --threshold-rule=percent:100

# Budget 알림 설정
gcloud billing budgets create /
  --billing-account=123456789012 /
  --display-name="High Usage Alert" /
  --budget-amount=1000USD /
  --threshold-rule=percent:90 /
  --notification-rule=pubsub-topic=projects/my-project/topics/billing-alerts
```

#### CloudWatch 비용 모니터링
```yaml
# cost-monitoring.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: cost-monitoring
data:
  cloudwatch-alarms.yaml: |
    Resources:
      HighCostAlarm:
        Type: AWS::CloudWatch::Alarm
        Properties:
          AlarmName: High-Cost-Alarm
          AlarmDescription: Alert when daily cost exceeds threshold
          MetricName: EstimatedCharges
          Namespace: AWS/Billing
          Statistic: Maximum
          Period: 86400
          EvaluationPeriods: 1
          Threshold: 50
          ComparisonOperator: GreaterThanThreshold
          Dimensions:
            - Name: Currency
              Value: USD
          AlarmActions:
            - !Ref SNSTopic
      
      SNSTopic:
        Type: AWS::SNS::Topic
        Properties:
          TopicName: cost-alerts
          DisplayName: Cost Alerts
```

</details>

<details>
<summary>🔧 4단계: 자동화된 비용 관리</summary>

#### 리소스 태깅 자동화
```python
# auto-tagging.py
import boto3
import json
from datetime import datetime

def auto_tag_resources():
    """리소스에 자동으로 태그 추가"""
    ec2 = boto3.client['ec2']
    
    # 모든 EC2 인스턴스에 태그 추가
    instances = ec2.describe_instances()
    
    for reservation in instances['Reservations']:
        for instance in reservation['Instances']:
            if instance['State']['Name'] == 'running':
                # 비용 할당 태그 추가
                tags = [
                    {'Key': 'CostCenter', 'Value': 'Engineering'},
                    {'Key': 'Environment', 'Value': 'Production'},
                    {'Key': 'CreatedDate', 'Value': datetime.now().strftime['%Y-%m-%d']},
                    {'Key': 'AutoTagged', 'Value': 'True'}
                ]
                
                ec2.create_tags[
                    Resources=[instance['InstanceId']],
                    Tags=tags
                ]
                print[f"Tagged instance: {instance['InstanceId']}"]

if __name__ == "__main__":
    auto_tag_resources()
```

#### 미사용 리소스 정리
```bash
# 미사용 EBS 볼륨 정리
aws ec2 describe-volumes --filters "Name=status,Values=available" --query "Volumes[*].VolumeId" --output text | xargs -I {} aws ec2 delete-volume --volume-id {}

# 미사용 Elastic IP 정리
aws ec2 describe-addresses --query "Addresses[?AssociationId==null].AllocationId" --output text | xargs -I {} aws ec2 release-address --allocation-id {}

# 미사용 스냅샷 정리 ["30일 이상"]
aws ec2 describe-snapshots --owner-ids self --query "Snapshots[?StartTime<='$[date -d '30 days ago' --iso-8601]'].SnapshotId" --output text | xargs -I {} aws ec2 delete-snapshot --snapshot-id {}
```

#### 비용 최적화 권장사항 자동화
```python
# cost-optimization-recommendations.py
import boto3
import json

def get_cost_optimization_recommendations():
    """비용 최적화 권장사항 조회"""
    ce = boto3.client['ce']
    
    # Reserved Instance 권장사항
    ri_recommendations = ce.get_reservation_purchase_recommendation[
        Service='Amazon Elastic Compute Cloud - Compute',
        LookbackPeriodInDays=30,
        TermInYears='ONE_YEAR',
        PaymentOption='NO_UPFRONT'
    ]
    
    # Savings Plans 권장사항
    sp_recommendations = ce.get_savings_plans_purchase_recommendation[
        LookbackPeriodInDays=30,
        TermInYears='ONE_YEAR',
        PaymentOption='NO_UPFRONT',
        SavingsPlanType='COMPUTE_SP'
    ]
    
    print["Reserved Instance 권장사항:"]
    print[json.dumps[ri_recommendations, indent=2, default=str]]
    
    print["/nSavings Plans 권장사항:"]
    print[json.dumps[sp_recommendations, indent=2, default=str]]

if __name__ == "__main__":
    get_cost_optimization_recommendations()
```

#### Terraform 비용 최적화 모듈
```hcl
# modules/cost-optimization/main.tf
resource "aws_ec2_spot_instance_request" "web" {
  count = var.spot_instance_count
  
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name
  
  vpc_security_group_ids = var.security_group_ids
  subnet_id              = var.subnet_id
  
  user_data = var.user_data
  
  tags = merge[var.tags, {
    Name = "spot-instance-${count.index + 1}"
    Type = "spot"
  }]
}

resource "aws_ec2_instance" "on_demand" {
  count = var.on_demand_instance_count
  
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name
  
  vpc_security_group_ids = var.security_group_ids
  subnet_id              = var.subnet_id
  
  user_data = var.user_data
  
  tags = merge[var.tags, {
    Name = "on-demand-instance-${count.index + 1}"
    Type = "on-demand"
  }]
}

# Auto Scaling Group with mixed instance policy
resource "aws_autoscaling_group" "cost_optimized" {
  name                = var.asg_name
  vpc_zone_identifier = var.subnet_ids
  target_group_arns   = var.target_group_arns
  health_check_type   = "ELB"
  
  min_size         = var.min_size
  max_size         = var.max_size
  desired_capacity = var.desired_capacity
  
  mixed_instances_policy {
    instances_distribution {
      on_demand_base_capacity                  = 0
      on_demand_percentage_above_base_capacity = 20
      spot_allocation_strategy                 = "diversified"
      spot_instance_pools                      = 4
    }
    
    launch_template {
      launch_template_specification {
        launch_template_id = var.launch_template_id
        version           = "$Latest"
      }
      
      override {
        instance_type = "t3.micro"
      }
      
      override {
        instance_type = "t3.small"
      }
      
      override {
        instance_type = "t3.medium"
      }
    }
  }
  
  tag {
    key                 = "Name"
    value               = var.asg_name
    propagate_at_launch = true
  }
}
```

</details>

---

## 📚 참고 자료

### 유용한 명령어
```bash
# AWS 비용 관리
aws ce get-cost-and-usage                    # 비용 및 사용량 조회
aws budgets describe-budgets                 # Budget 목록
aws ec2 describe-reserved-instances          # Reserved Instances 목록

# GCP 비용 관리
gcloud billing budgets list                  # Budget 목록
gcloud compute commitments list              # Committed Use Discounts
gcloud logging read "resource.type=gce_instance"  # 인스턴스 로그
```

### 문제 해결
1. **예상보다 높은 비용**
   - Cost Explorer에서 서비스별 비용 분석
   - 미사용 리소스 확인 및 정리
   - Reserved Instances 활용 검토

2. **Spot Instance 중단**
   - Spot Instance 요청 상태 모니터링
   - 애플리케이션 중단 대응 로직 구현
   - On-Demand Instance로 자동 전환

---

## 🧹 실습 정리

### 자동 정리
```bash
# Day3 비용 최적화 실습 자동 정리
./mcp_knowledge_base/cloud_master/repos/automation/day3/cost_optimization.sh --cleanup
```

### 수동 정리
```bash
# AWS 리소스 정리
aws ec2 terminate-instances --instance-ids i-1234567890abcdef0
aws ec2 delete-volume --volume-id vol-1234567890abcdef0
aws budgets delete-budget --account-id 123456789012 --budget-name Monthly-Budget

# GCP 리소스 정리
gcloud compute instances delete cost-optimization-instance --zone us-central1-a
gcloud compute commitments delete web-commitment --region us-central1
gcloud billing budgets delete 123456789012 --billing-account=123456789012
```

### 정리 확인
- [ ] 미사용 EC2 인스턴스 종료
- [ ] 미사용 EBS 볼륨 삭제
- [ ] 미사용 Elastic IP 해제
- [ ] Budget 및 알림 정리
