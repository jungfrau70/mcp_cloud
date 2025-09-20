# Multi-AZ 구성 실패 트러블슈팅


<details>
<summary>📋 목차</summary>

1. [🎯 문제 개요](#문제-개요)
2. [🔍 진단 방법](#진단-방법)
3. [🛠️ 해결 방법](#해결-방법)
4. [📚 예방 방법](#예방-방법)
5. [🔗 관련 자료](#관련-자료)

</details>

---

## 🎯 문제 개요

<details>
<summary>📖 Multi-AZ 구성 실패 시나리오</summary>

### 자주 발생하는 문제

[자주 발생하는 문제](#자주-발생하는-문제)
- **RDS Multi-AZ 구성 실패**
- **Auto Scaling Group Multi-AZ 배포 실패**
- **로드 밸런서 Multi-AZ 설정 실패**
- **데이터베이스 복제 실패**

### 문제 원인

[문제 원인](#문제-원인)
- 가용 영역 제한
- 서브넷 설정 오류
- 보안 그룹 설정 문제
- 권한 부족
- 리소스 제한

</details>

---

## 🔍 진단 방법

<details>
<summary>📋 1단계: 기본 상태 확인</summary>

### AWS CLI 상태 확인

[AWS CLI 상태 확인](#aws-cli-상태-확인)
```bash
# AWS CLI 설정 확인
aws configure list

# 현재 리전 확인
aws configure get region

# 계정 정보 확인
aws sts get-caller-identity
```

### 가용 영역 확인

[가용 영역 확인](#가용-영역-확인)
```bash
# 가용 영역 목록 확인
aws ec2 describe-availability-zones /
    --query 'AvailabilityZones[].{ZoneName:ZoneName,State:State}'

# 특정 리전의 가용 영역 확인
aws ec2 describe-availability-zones /
    --region ap-northeast-2 /
    --query 'AvailabilityZones[].ZoneName'
```

### VPC 및 서브넷 확인

[VPC 및 서브넷 확인](#vpc-및-서브넷-확인)
```bash
# VPC 목록 확인
aws ec2 describe-vpcs /
    --query 'Vpcs[].{VpcId:VpcId,CidrBlock:CidrBlock,State:State}'

# 서브넷 확인
aws ec2 describe-subnets /
    --filters "Name=vpc-id,Values=vpc-12345" /
    --query 'Subnets[].{SubnetId:SubnetId,AvailabilityZone:AvailabilityZone,CidrBlock:CidrBlock}'
```

</details>

<details>
<summary>📋 2단계: 리소스 상태 확인</summary>

### RDS Multi-AZ 상태 확인

[RDS Multi-AZ 상태 확인](#rds-multiaz-상태-확인)
```bash
# RDS 인스턴스 상태 확인
aws rds describe-db-instances /
    --db-instance-identifier my-app-db /
    --query 'DBInstances[0].{Status:DBInstanceStatus,MultiAZ:MultiAZ,AvailabilityZone:AvailabilityZone,SecondaryAvailabilityZone:SecondaryAvailabilityZone}'

# RDS 이벤트 확인
aws rds describe-events /
    --source-identifier my-app-db /
    --source-type db-instance /
    --max-items 10
```

### Auto Scaling Group 상태 확인

[Auto Scaling Group 상태 확인](#auto-scaling-group-상태-확인)
```bash
# Auto Scaling Group 상태 확인
aws autoscaling describe-auto-scaling-groups /
    --auto-scaling-group-names my-app-asg /
    --query 'AutoScalingGroups[0].{DesiredCapacity:DesiredCapacity,MinSize:MinSize,MaxSize:MaxSize,AvailabilityZones:AvailabilityZones}'

# 인스턴스 상태 확인
aws autoscaling describe-auto-scaling-groups /
    --auto-scaling-group-names my-app-asg /
    --query 'AutoScalingGroups[0].Instances[].{InstanceId:InstanceId,AvailabilityZone:AvailabilityZone,HealthStatus:HealthStatus,LifecycleState:LifecycleState}'
```

### 로드 밸런서 상태 확인

[로드 밸런서 상태 확인](#로드-밸런서-상태-확인)
```bash
# Application Load Balancer 상태 확인
aws elbv2 describe-load-balancers /
    --load-balancer-arns arn:aws:elasticloadbalancing:region:account:loadbalancer/app/my-app-alb/1234567890123456 /
    --query 'LoadBalancers[0].{State:State,Type:Type,Scheme:Scheme}'

# Target Group 상태 확인
aws elbv2 describe-target-health /
    --target-group-arn arn:aws:elasticloadbalancing:region:account:targetgroup/my-app-targets/1234567890123456
```

</details>

---

## 🛠️ 해결 방법

<details>
<summary>🔧 1단계: RDS Multi-AZ 구성 실패 해결</summary>

### 문제: RDS Multi-AZ 구성 실패

[문제: RDS Multi-AZ 구성 실패](#문제-rds-multiaz-구성-실패)
**원인**: 가용 영역 제한, 서브넷 설정 오류

**해결방법**:
```bash
# 1. 가용 영역 확인
aws ec2 describe-availability-zones /
    --query 'AvailabilityZones[?State==`available`].ZoneName'

# 2. 서브넷 그룹 확인
aws rds describe-db-subnet-groups /
    --db-subnet-group-name my-app-db-subnet-group

# 3. 서브넷 그룹 재생성 (필요시)
aws rds create-db-subnet-group /
    --db-subnet-group-name my-app-db-subnet-group-new /
    --db-subnet-group-description "New subnet group for RDS Multi-AZ" /
    --subnet-ids subnet-12345 subnet-67890

# 4. RDS 인스턴스 수정
aws rds modify-db-instance /
    --db-instance-identifier my-app-db /
    --db-subnet-group-name my-app-db-subnet-group-new /
    --apply-immediately
```

### 문제: 데이터베이스 복제 실패

[문제: 데이터베이스 복제 실패](#문제-데이터베이스-복제-실패)
**원인**: 네트워크 설정, 권한 문제

**해결방법**:
```bash
# 1. 보안 그룹 확인
aws ec2 describe-security-groups /
    --group-ids sg-12345

# 2. 보안 그룹 규칙 추가
aws ec2 authorize-security-group-ingress /
    --group-id sg-12345 /
    --protocol tcp /
    --port 3306 /
    --cidr 10.0.0.0/16

# 3. RDS 인스턴스 재시작
aws rds reboot-db-instance /
    --db-instance-identifier my-app-db /
    --force-failover
```

</details>

<details>
<summary>🔧 2단계: Auto Scaling Group Multi-AZ 배포 실패 해결</summary>

### 문제: 인스턴스가 특정 AZ에만 생성됨

[문제: 인스턴스가 특정 AZ에만 생성됨](#문제-인스턴스가-특정-az에만-생성됨)
**원인**: 서브넷 설정 오류, 인스턴스 타입 제한

**해결방법**:
```bash
# 1. 서브넷 가용 영역 확인
aws ec2 describe-subnets /
    --subnet-ids subnet-12345 subnet-67890 /
    --query 'Subnets[].{SubnetId:SubnetId,AvailabilityZone:AvailabilityZone}'

# 2. 인스턴스 타입 가용성 확인
aws ec2 describe-instance-type-offerings /
    --location-type availability-zone /
    --filters Name=instance-type,Values=t3.micro /
    --query 'InstanceTypeOfferings[].{InstanceType:InstanceType,Location:Location}'

# 3. Auto Scaling Group 수정
aws autoscaling update-auto-scaling-group /
    --auto-scaling-group-name my-app-asg /
    --vpc-zone-identifier "subnet-12345,subnet-67890,subnet-abcdef"

# 4. 인스턴스 타입 변경 (필요시)
aws autoscaling update-auto-scaling-group /
    --auto-scaling-group-name my-app-asg /
    --launch-template LaunchTemplateName=my-app-template,Version=1
```

### 문제: Health Check 실패

[문제: Health Check 실패](#문제-health-check-실패)
**원인**: 보안 그룹 설정, 애플리케이션 설정

**해결방법**:
```bash
# 1. 보안 그룹 규칙 확인
aws ec2 describe-security-groups /
    --group-ids sg-12345 /
    --query 'SecurityGroups[0].IpPermissions'

# 2. Health Check 엔드포인트 테스트
curl -I http://instance-ip/health

# 3. Target Group Health Check 설정 수정
aws elbv2 modify-target-group /
    --target-group-arn arn:aws:elasticloadbalancing:region:account:targetgroup/my-app-targets/1234567890123456 /
    --health-check-path /health /
    --health-check-interval-seconds 30 /
    --health-check-timeout-seconds 5 /
    --healthy-threshold-count 2 /
    --unhealthy-threshold-count 3
```

</details>

<details>
<summary>🔧 3단계: 로드 밸런서 Multi-AZ 설정 실패 해결</summary>

### 문제: 로드 밸런서가 특정 AZ에서만 작동

[문제: 로드 밸런서가 특정 AZ에서만 작동](#문제-로드-밸런서가-특정-az에서만-작동)
**원인**: 서브넷 설정 오류, 보안 그룹 설정

**해결방법**:
```bash
# 1. 로드 밸런서 서브넷 확인
aws elbv2 describe-load-balancers /
    --load-balancer-arns arn:aws:elasticloadbalancing:region:account:loadbalancer/app/my-app-alb/1234567890123456 /
    --query 'LoadBalancers[0].AvailabilityZones[].{ZoneName:ZoneName,SubnetId:SubnetId}'

# 2. 서브넷 추가
aws elbv2 set-subnets /
    --load-balancer-arn arn:aws:elasticloadbalancing:region:account:loadbalancer/app/my-app-alb/1234567890123456 /
    --subnets subnet-12345 subnet-67890 subnet-abcdef

# 3. 보안 그룹 확인 및 수정
aws ec2 describe-security-groups /
    --group-ids sg-12345

# 4. 로드 밸런서 상태 확인
aws elbv2 describe-load-balancers /
    --load-balancer-arns arn:aws:elasticloadbalancing:region:account:loadbalancer/app/my-app-alb/1234567890123456 /
    --query 'LoadBalancers[0].State'
```

</details>

---

## 📚 예방 방법

<details>
<summary>📋 1단계: 사전 검증</summary>

### 가용 영역 검증

[가용 영역 검증](#가용-영역-검증)
```bash
# 가용 영역 검증 스크립트
#!/bin/bash

echo "=== 가용 영역 검증 ==="
aws ec2 describe-availability-zones /
    --query 'AvailabilityZones[?State==`available`].ZoneName' /
    --output table

echo "=== 서브넷 검증 ==="
aws ec2 describe-subnets /
    --filters "Name=vpc-id,Values=$VPC_ID" /
    --query 'Subnets[].{SubnetId:SubnetId,AvailabilityZone:AvailabilityZone,CidrBlock:CidrBlock}' /
    --output table

echo "=== 인스턴스 타입 가용성 검증 ==="
aws ec2 describe-instance-type-offerings /
    --location-type availability-zone /
    --filters Name=instance-type,Values=t3.micro /
    --query 'InstanceTypeOfferings[].{InstanceType:InstanceType,Location:Location}' /
    --output table
```

### 리소스 제한 검증

[리소스 제한 검증](#리소스-제한-검증)
```bash
# 리소스 제한 검증 스크립트
#!/bin/bash

echo "=== RDS 제한 검증 ==="
aws rds describe-account-attributes /
    --query 'AccountQuotas[?AccountQuotaName==`DBInstances`].{Name:AccountQuotaName,Used:Used,Max:Max}'

echo "=== EC2 제한 검증 ==="
aws ec2 describe-account-attributes /
    --attribute-names supported-platforms

echo "=== ELB 제한 검증 ==="
aws elbv2 describe-account-limits /
    --query 'Limits[].{Name:Name,Max:Max}'
```

</details>

<details>
<summary>📋 2단계: 모니터링 설정</summary>

### CloudWatch 알람 설정

[CloudWatch 알람 설정](#cloudwatch-알람-설정)
```bash
# Multi-AZ 상태 모니터링 알람
aws cloudwatch put-metric-alarm /
    --alarm-name "RDS Multi-AZ Status" /
    --alarm-description "Monitor RDS Multi-AZ status" /
    --metric-name DatabaseConnections /
    --namespace AWS/RDS /
    --statistic Average /
    --period 300 /
    --threshold 0 /
    --comparison-operator GreaterThanThreshold /
    --evaluation-periods 1

# Auto Scaling Group 상태 모니터링
aws cloudwatch put-metric-alarm /
    --alarm-name "ASG Multi-AZ Distribution" /
    --alarm-description "Monitor ASG instance distribution" /
    --metric-name GroupInServiceInstances /
    --namespace AWS/AutoScaling /
    --statistic Average /
    --period 300 /
    --threshold 2 /
    --comparison-operator LessThanThreshold /
    --evaluation-periods 2
```

### 로그 모니터링

[로그 모니터링](#로그-모니터링)
```bash
# CloudWatch Logs 그룹 생성
aws logs create-log-group /
    --log-group-name /aws/ec2/multi-az-monitoring

# 로그 스트림 생성
aws logs create-log-stream /
    --log-group-name /aws/ec2/multi-az-monitoring /
    --log-stream-name multi-az-status
```

</details>

---

## 🔗 관련 자료

<details>
<summary>📖 추가 학습 자료</summary>

### 공식 문서

[공식 문서](#공식-문서)
- [AWS RDS Multi-AZ](https:///docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Concepts.MultiAZ.html)
- [AWS Auto Scaling Multi-AZ](https:///docs.aws.amazon.com/autoscaling/ec2/userguide/auto-scaling-benefits.html)
- [AWS ELB Multi-AZ](https:///docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-target-groups.html)

### 유용한 리소스

[유용한 리소스](#유용한-리소스)
- [AWS Well-Architected Framework](https:///aws.amazon.com/architecture/well-architected/)
- [AWS 샘플 프로젝트](https:///github.com/aws-samples)
- [AWS 트러블슈팅 가이드](https:///docs.aws.amazon.com/general/latest/gr/aws_troubleshooting.html)

</details>

---

## 🎉 완료!

[🎉 완료!](#완료)

Multi-AZ 구성 실패 트러블슈팅 가이드를 완료했습니다.

### 📚 학습 요약

[📚 학습 요약](#학습-요약)

이번 가이드를 통해 다음을 배웠습니다:

1. **🔍 진단 방법**: 문제 원인 파악 및 상태 확인
2. **🛠️ 해결 방법**: 단계별 문제 해결 방법
3. **📚 예방 방법**: 사전 검증 및 모니터링 설정
4. **🔗 관련 자료**: 추가 학습 자료 및 참고 문서

### 🚀 다음 단계

[🚀 다음 단계](#다음-단계)

- **실제 문제 해결**: 실제 환경에서 문제 해결 적용
- **모니터링 강화**: 지속적인 모니터링 시스템 구축
- **문서화**: 문제 해결 과정 문서화

### 💡 추가 학습 자료

[💡 추가 학습 자료](#추가-학습-자료)

- [AWS Well-Architected Framework](https:///aws.amazon.com/architecture/well-architected/)
- [전체 커리큘럼](curriculum.md)

---

**🎯 이제 Multi-AZ 구성 문제를 효과적으로 해결할 수 있습니다!**


---


---



<div align="center">

[← 이전: Cloud Container 메인](README.md) | [📚 전체 커리큘럼](curriculum.md) | [🏠 학습 경로로 돌아가기](index.md) | [📋 학습 경로](learning-path.md)

</div>