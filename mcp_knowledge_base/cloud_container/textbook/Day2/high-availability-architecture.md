# 고가용성 아키텍처 설계 가이드

## 🎯 학습 목표

이 가이드를 통해 다음을 학습합니다:
- AWS Multi-AZ 및 GCP Multi-Region 아키텍처 설계
- 장애 복구 및 재해 복구 전략 수립
- RDS Multi-AZ 구성 및 EC2 고가용성 설정
- GCP Multi-Region 배포 전략
- 실제 서비스 시나리오 기반 아키텍처 구현

---

## 📋 목차

1. [고가용성 아키텍처 기본 개념](#고가용성-아키텍처-기본-개념)
2. [AWS Multi-AZ 구성](#aws-multi-az-구성)
3. [GCP Multi-Region 구성](#gcp-multi-region-구성)
4. [장애 복구 전략](#장애-복구-전략)
5. [재해 복구 전략](#재해-복구-전략)
6. [실습 시나리오](#실습-시나리오)

---

## 🏗️ 고가용성 아키텍처 기본 개념

### 가용성 레벨 정의

#### 가용성 백분율
- **99% (8.76시간/년 다운타임)**: 기본 가용성
- **99.9% (52.56분/년 다운타임)**: 고가용성
- **99.99% (5.26분/년 다운타임)**: 매우 높은 가용성
- **99.999% (31.5초/년 다운타임)**: 극도로 높은 가용성

#### RTO (Recovery Time Objective)
- **목표 복구 시간**: 장애 발생 후 서비스 복구까지의 최대 허용 시간
- **일반적인 RTO**: 1-4시간 (비즈니스 크리티컬 애플리케이션)

#### RPO (Recovery Point Objective)
- **목표 복구 시점**: 장애 발생 시점에서 데이터 손실 허용 범위
- **일반적인 RPO**: 15분-1시간 (데이터 크리티컬 애플리케이션)

### 고가용성 아키텍처 패턴

#### 1. Active-Passive (Active-Standby)
- **활성-대기**: 하나의 시스템이 활성화, 다른 시스템은 대기
- **장점**: 단순한 구조, 낮은 복잡성
- **단점**: 리소스 활용도 낮음, 수동 전환 필요

#### 2. Active-Active
- **활성-활성**: 여러 시스템이 동시에 서비스 제공
- **장점**: 높은 리소스 활용도, 자동 로드 분산
- **단점**: 복잡한 동기화, 데이터 일관성 관리

#### 3. Multi-Region
- **다중 리전**: 지리적으로 분산된 여러 리전에서 서비스 제공
- **장점**: 지역별 장애 격리, 낮은 지연시간
- **단점**: 높은 비용, 복잡한 관리

---

## ☁️ AWS Multi-AZ 구성

### RDS Multi-AZ 구성

#### RDS Multi-AZ 설정
```yaml
# rds-multi-az.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: rds-multi-az-config
  namespace: container-demo
data:
  rds-config.json: |
    {
      "DBInstanceIdentifier": "container-demo-db",
      "DBInstanceClass": "db.t3.medium",
      "Engine": "mysql",
      "EngineVersion": "8.0.35",
      "MasterUsername": "admin",
      "MasterUserPassword": "your-secure-password",
      "AllocatedStorage": 20,
      "StorageType": "gp3",
      "MultiAZ": true,
      "BackupRetentionPeriod": 7,
      "PreferredBackupWindow": "03:00-04:00",
      "PreferredMaintenanceWindow": "sun:04:00-sun:05:00",
      "PubliclyAccessible": false,
      "VpcSecurityGroupIds": ["sg-12345678"],
      "DBSubnetGroupName": "container-demo-subnet-group",
      "StorageEncrypted": true,
      "DeletionProtection": true,
      "MonitoringInterval": 60,
      "EnablePerformanceInsights": true
    }
```

#### RDS 서브넷 그룹 생성
```bash
# RDS 서브넷 그룹 생성 스크립트
#!/bin/bash

# RDS 서브넷 그룹 생성
aws rds create-db-subnet-group \
  --db-subnet-group-name container-demo-subnet-group \
  --db-subnet-group-description "Container Demo RDS Subnet Group" \
  --subnet-ids subnet-12345678 subnet-87654321

# RDS 인스턴스 생성 (Multi-AZ)
aws rds create-db-instance \
  --db-instance-identifier container-demo-db \
  --db-instance-class db.t3.medium \
  --engine mysql \
  --engine-version 8.0.35 \
  --master-username admin \
  --master-user-password your-secure-password \
  --allocated-storage 20 \
  --storage-type gp3 \
  --multi-az \
  --backup-retention-period 7 \
  --preferred-backup-window "03:00-04:00" \
  --preferred-maintenance-window "sun:04:00-sun:05:00" \
  --vpc-security-group-ids sg-12345678 \
  --db-subnet-group-name container-demo-subnet-group \
  --storage-encrypted \
  --deletion-protection \
  --monitoring-interval 60 \
  --enable-performance-insights
```

### EC2 고가용성 구성

#### Auto Scaling Group 설정
```yaml
# ec2-high-availability.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: ec2-ha-config
  namespace: container-demo
data:
  launch-template.json: |
    {
      "LaunchTemplateName": "container-demo-template",
      "LaunchTemplateData": {
        "ImageId": "ami-0c02fb55956c7d316",
        "InstanceType": "t3.medium",
        "KeyName": "container-demo-key",
        "SecurityGroupIds": ["sg-12345678"],
        "UserData": "IyEvYmluL2Jhc2gKc3VkbyB5dW0gdXBkYXRlIC15CnN1ZG8geXVtIGluc3RhbGwgLXkgZG9ja2VyCnN1ZG8gc3lzdGVtY3RsIHN0YXJ0IGRvY2tlcgpzdWRvIHN5c3RlbWN0bCBlbmFibGUgZG9ja2VyCg===",
        "TagSpecifications": [
          {
            "ResourceType": "instance",
            "Tags": [
              {
                "Key": "Name",
                "Value": "container-demo-instance"
              },
              {
                "Key": "Environment",
                "Value": "production"
              }
            ]
          }
        ]
      }
    }
  auto-scaling-group.json: |
    {
      "AutoScalingGroupName": "container-demo-asg",
      "LaunchTemplate": {
        "LaunchTemplateName": "container-demo-template",
        "Version": "$Latest"
      },
      "MinSize": 2,
      "MaxSize": 10,
      "DesiredCapacity": 3,
      "VPCZoneIdentifier": "subnet-12345678,subnet-87654321",
      "HealthCheckType": "ELB",
      "HealthCheckGracePeriod": 300,
      "TargetGroupARNs": ["arn:aws:elasticloadbalancing:region:account:targetgroup/container-demo-tg/1234567890123456"],
      "Tags": [
        {
          "Key": "Name",
          "Value": "container-demo-asg",
          "PropagateAtLaunch": true
        }
      ]
    }
```

#### Application Load Balancer 설정
```yaml
# alb-config.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: alb-config
  namespace: container-demo
data:
  alb-config.json: |
    {
      "LoadBalancerName": "container-demo-alb",
      "Scheme": "internet-facing",
      "Type": "application",
      "Subnets": ["subnet-12345678", "subnet-87654321"],
      "SecurityGroups": ["sg-12345678"],
      "Tags": [
        {
          "Key": "Name",
          "Value": "container-demo-alb"
        }
      ]
    }
  target-group-config.json: |
    {
      "TargetGroupName": "container-demo-tg",
      "Protocol": "HTTP",
      "Port": 80,
      "VpcId": "vpc-12345678",
      "HealthCheckProtocol": "HTTP",
      "HealthCheckPath": "/health",
      "HealthCheckIntervalSeconds": 30,
      "HealthCheckTimeoutSeconds": 5,
      "HealthyThresholdCount": 2,
      "UnhealthyThresholdCount": 3,
      "Tags": [
        {
          "Key": "Name",
          "Value": "container-demo-tg"
        }
      ]
    }
```

---

## 🌍 GCP Multi-Region 구성

### GKE Multi-Region 클러스터

#### Multi-Region 클러스터 생성
```bash
#!/bin/bash
# gcp-multi-region-setup.sh

# 1. Primary Region 클러스터 생성
gcloud container clusters create container-demo-primary \
  --zone asia-northeast3-a \
  --num-nodes 3 \
  --machine-type e2-medium \
  --enable-autoscaling \
  --min-nodes 1 \
  --max-nodes 10 \
  --enable-autorepair \
  --enable-autoupgrade \
  --enable-ip-alias \
  --network container-demo-vpc \
  --subnetwork container-demo-subnet

# 2. Secondary Region 클러스터 생성
gcloud container clusters create container-demo-secondary \
  --zone asia-northeast2-a \
  --num-nodes 3 \
  --machine-type e2-medium \
  --enable-autoscaling \
  --min-nodes 1 \
  --max-nodes 10 \
  --enable-autorepair \
  --enable-autoupgrade \
  --enable-ip-alias \
  --network container-demo-vpc \
  --subnetwork container-demo-subnet-secondary

# 3. Global Load Balancer 설정
gcloud compute backend-services create container-demo-backend \
  --global \
  --protocol HTTP \
  --health-checks container-demo-health-check \
  --timeout 30s

# 4. URL Map 생성
gcloud compute url-maps create container-demo-map \
  --default-service container-demo-backend

# 5. Target HTTP Proxy 생성
gcloud compute target-http-proxies create container-demo-proxy \
  --url-map container-demo-map

# 6. Global Forwarding Rule 생성
gcloud compute forwarding-rules create container-demo-rule \
  --global \
  --target-http-proxy container-demo-proxy \
  --ports 80
```

### Cloud SQL Multi-Region 설정

#### Cloud SQL 인스턴스 생성
```yaml
# cloud-sql-multi-region.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: cloud-sql-config
  namespace: container-demo
data:
  cloud-sql-config.json: |
    {
      "name": "container-demo-db",
      "databaseVersion": "MYSQL_8_0",
      "region": "asia-northeast3",
      "settings": {
        "tier": "db-n1-standard-1",
        "availabilityType": "REGIONAL",
        "backupConfiguration": {
          "enabled": true,
          "startTime": "03:00",
          "binaryLogEnabled": true,
          "transactionLogRetentionDays": 7
        },
        "ipConfiguration": {
          "ipv4Enabled": false,
          "privateNetwork": "projects/PROJECT_ID/global/networks/container-demo-vpc"
        },
        "databaseFlags": [
          {
            "name": "innodb_buffer_pool_size",
            "value": "1073741824"
          }
        ]
      },
      "replicaConfiguration": {
        "mysqlReplicaConfiguration": {
          "masterHeartbeatPeriod": 1000
        }
      }
    }
```

---

## 🔄 장애 복구 전략

### 자동 장애 감지 및 복구

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
      "AlarmActions": ["arn:aws:sns:region:account:container-demo-alerts"],
      "AlarmDescription": "High CPU utilization detected"
    }
```

#### 자동 복구 스크립트
```bash
#!/bin/bash
# auto-recovery.sh

# 장애 감지 및 복구 함수
detect_and_recover() {
    local instance_id=$1
    local region=$2
    
    # 인스턴스 상태 확인
    local state=$(aws ec2 describe-instances \
        --instance-ids $instance_id \
        --region $region \
        --query 'Reservations[0].Instances[0].State.Name' \
        --output text)
    
    if [ "$state" = "stopped" ]; then
        echo "인스턴스 $instance_id가 중지됨. 재시작 시도..."
        
        # 인스턴스 재시작
        aws ec2 start-instances \
            --instance-ids $instance_id \
            --region $region
        
        # 상태 확인 대기
        aws ec2 wait instance-running \
            --instance-ids $instance_id \
            --region $region
        
        echo "인스턴스 $instance_id 재시작 완료"
    elif [ "$state" = "running" ]; then
        # 헬스체크 수행
        local health_check=$(curl -f http://$instance_id/health 2>/dev/null)
        
        if [ $? -ne 0 ]; then
            echo "인스턴스 $instance_id 헬스체크 실패. 재시작 시도..."
            
            # 인스턴스 재시작
            aws ec2 reboot-instances \
                --instance-ids $instance_id \
                --region $region
        fi
    fi
}

# 메인 실행
detect_and_recover "i-1234567890abcdef0" "ap-northeast-2"
```

---

## 🚨 재해 복구 전략

### 백업 및 복원 전략

#### RDS 백업 설정
```bash
#!/bin/bash
# rds-backup-strategy.sh

# 1. 자동 백업 설정
aws rds modify-db-instance \
  --db-instance-identifier container-demo-db \
  --backup-retention-period 7 \
  --preferred-backup-window "03:00-04:00" \
  --apply-immediately

# 2. 수동 스냅샷 생성
aws rds create-db-snapshot \
  --db-instance-identifier container-demo-db \
  --db-snapshot-identifier container-demo-snapshot-$(date +%Y%m%d-%H%M%S)

# 3. 다른 리전으로 스냅샷 복사
aws rds copy-db-snapshot \
  --source-db-snapshot-identifier container-demo-snapshot-20231201-120000 \
  --target-db-snapshot-identifier container-demo-snapshot-us-west-2 \
  --source-region ap-northeast-2 \
  --region us-west-2
```

#### 애플리케이션 데이터 백업
```bash
#!/bin/bash
# app-data-backup.sh

# 1. 애플리케이션 데이터 백업
kubectl exec -n container-demo deployment/container-demo -- \
  mysqldump -h mysql-service -u admin -p$DB_PASSWORD \
  container_demo > backup_$(date +%Y%m%d_%H%M%S).sql

# 2. S3에 백업 업로드
aws s3 cp backup_$(date +%Y%m%d_%H%M%S).sql \
  s3://container-demo-backups/database/

# 3. 백업 보존 정책 적용
aws s3api put-bucket-lifecycle-configuration \
  --bucket container-demo-backups \
  --lifecycle-configuration file://backup-lifecycle.json
```

### 재해 복구 테스트

#### DR 테스트 시나리오
```bash
#!/bin/bash
# dr-test-scenario.sh

echo "=== 재해 복구 테스트 시작 ==="

# 1. Primary 리전 장애 시뮬레이션
echo "1. Primary 리전 장애 시뮬레이션..."
kubectl scale deployment container-demo --replicas=0 -n container-demo

# 2. Secondary 리전 활성화
echo "2. Secondary 리전 활성화..."
kubectl apply -f k8s/gcp-gke/deployment-secondary.yaml

# 3. 서비스 연속성 확인
echo "3. 서비스 연속성 확인..."
kubectl get pods -o wide -n container-demo
kubectl get services -n container-demo

# 4. 데이터 일관성 확인
echo "4. 데이터 일관성 확인..."
kubectl exec -n container-demo deployment/container-demo -- \
  mysql -h mysql-service -u admin -p$DB_PASSWORD \
  -e "SELECT COUNT(*) FROM users;"

# 5. Primary 리전 복구
echo "5. Primary 리전 복구..."
kubectl scale deployment container-demo --replicas=3 -n container-demo

echo "=== 재해 복구 테스트 완료 ==="
```

---

## 🚀 실습 시나리오

### 시나리오 1: AWS Multi-AZ 구성

#### 1단계: RDS Multi-AZ 설정
```bash
# RDS 서브넷 그룹 생성
aws rds create-db-subnet-group \
  --db-subnet-group-name container-demo-subnet-group \
  --db-subnet-group-description "Container Demo RDS Subnet Group" \
  --subnet-ids subnet-12345678 subnet-87654321

# RDS Multi-AZ 인스턴스 생성
aws rds create-db-instance \
  --db-instance-identifier container-demo-db \
  --db-instance-class db.t3.medium \
  --engine mysql \
  --engine-version 8.0.35 \
  --master-username admin \
  --master-user-password your-secure-password \
  --allocated-storage 20 \
  --multi-az \
  --backup-retention-period 7 \
  --vpc-security-group-ids sg-12345678 \
  --db-subnet-group-name container-demo-subnet-group
```

#### 2단계: EC2 Auto Scaling Group 설정
```bash
# Launch Template 생성
aws ec2 create-launch-template \
  --launch-template-name container-demo-template \
  --launch-template-data file://launch-template.json

# Auto Scaling Group 생성
aws autoscaling create-auto-scaling-group \
  --auto-scaling-group-name container-demo-asg \
  --launch-template LaunchTemplateName=container-demo-template,Version=1 \
  --min-size 2 \
  --max-size 10 \
  --desired-capacity 3 \
  --vpc-zone-identifier "subnet-12345678,subnet-87654321" \
  --health-check-type ELB \
  --target-group-arns arn:aws:elasticloadbalancing:region:account:targetgroup/container-demo-tg/1234567890123456
```

### 시나리오 2: GCP Multi-Region 구성

#### 1단계: Multi-Region 클러스터 생성
```bash
# Primary Region 클러스터
gcloud container clusters create container-demo-primary \
  --zone asia-northeast3-a \
  --num-nodes 3 \
  --machine-type e2-medium \
  --enable-autoscaling \
  --min-nodes 1 \
  --max-nodes 10

# Secondary Region 클러스터
gcloud container clusters create container-demo-secondary \
  --zone asia-northeast2-a \
  --num-nodes 3 \
  --machine-type e2-medium \
  --enable-autoscaling \
  --min-nodes 1 \
  --max-nodes 10
```

#### 2단계: Global Load Balancer 설정
```bash
# Global Load Balancer 생성
gcloud compute backend-services create container-demo-backend \
  --global \
  --protocol HTTP \
  --health-checks container-demo-health-check

# URL Map 생성
gcloud compute url-maps create container-demo-map \
  --default-service container-demo-backend

# Global Forwarding Rule 생성
gcloud compute forwarding-rules create container-demo-rule \
  --global \
  --target-http-proxy container-demo-proxy \
  --ports 80
```

---

## ✅ 체크리스트

### AWS Multi-AZ 구성
- [ ] RDS Multi-AZ 인스턴스 생성
- [ ] EC2 Auto Scaling Group 설정
- [ ] Application Load Balancer 구성
- [ ] CloudWatch 알림 설정
- [ ] 자동 복구 스크립트 구현

### GCP Multi-Region 구성
- [ ] Multi-Region GKE 클러스터 생성
- [ ] Global Load Balancer 설정
- [ ] Cloud SQL Multi-Region 구성
- [ ] 모니터링 및 알림 설정
- [ ] 재해 복구 테스트 수행

### 장애 복구 및 재해 복구
- [ ] 백업 전략 수립
- [ ] 복원 절차 문서화
- [ ] DR 테스트 시나리오 실행
- [ ] RTO/RPO 목표 달성 확인
- [ ] 모니터링 및 알림 시스템 구축

---

## 📚 참고 자료

### 공식 문서
- [AWS RDS Multi-AZ 공식 문서](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Concepts.MultiAZ.html)
- [AWS Auto Scaling 공식 문서](https://docs.aws.amazon.com/autoscaling/)
- [GCP Multi-Region 공식 문서](https://cloud.google.com/architecture/best-practices-for-enterprise-organizations)
- [GCP Global Load Balancing 공식 문서](https://cloud.google.com/load-balancing/docs/https)

### 추가 학습 자료
- [자동 복구 가이드](../Day1/auto-recovery-guide.md)
- [모니터링 설정 가이드](./monitoring-setup.md)
- [종합 실습 가이드](../Day1/comprehensive-practice-guide.md)

---

**💡 팁**: 고가용성 아키텍처는 비즈니스 요구사항에 따라 설계해야 합니다. RTO/RPO 목표를 명확히 정의하고, 비용과 복잡성을 고려하여 최적의 아키텍처를 선택하세요!
