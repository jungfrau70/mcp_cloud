# 트러블슈팅 가이드

## 📋 목차
1. [로드 밸런싱 관련 문제](#로드-밸런싱-관련-문제)
2. [오토 스케일링 관련 문제](#오토-스케일링-관련-문제)
3. [헬스체크 관련 문제](#헬스체크-관련-문제)
4. [네트워크 및 연결 문제](#네트워크-및-연결-문제)
5. [모니터링 및 알림 문제](#모니터링-및-알림-문제)
6. [성능 및 최적화 문제](#성능-및-최적화-문제)
7. [일반적인 오류 코드](#일반적인-오류-코드)

---

## ⚖️ 로드 밸런싱 관련 문제

### 문제 1: 로드 밸런서 생성 실패

#### 증상
```bash
ERROR: You do not have permission to create load balancer
```

#### 원인
- IAM 권한 부족
- 서브넷 설정 문제
- 보안 그룹 설정 문제

#### 해결 방법
```bash
# AWS IAM 권한 확인
aws iam list-attached-user-policies --user-name your-username

# 필요한 권한 추가
aws iam attach-user-policy \
  --user-name your-username \
  --policy-arn arn:aws:iam::aws:policy/ElasticLoadBalancingFullAccess

# 서브넷 확인
aws ec2 describe-subnets --subnet-ids subnet-12345

# 보안 그룹 확인
aws ec2 describe-security-groups --group-ids sg-12345
```

### 문제 2: 로드 밸런서에 인스턴스 등록 실패

#### 증상
```bash
ERROR: Instance is not in a valid state for registration
```

#### 원인
- 인스턴스가 실행 중이 아님
- 인스턴스가 다른 VPC에 있음
- 인스턴스에 적절한 보안 그룹이 없음

#### 해결 방법
```bash
# 인스턴스 상태 확인
aws ec2 describe-instances --instance-ids i-1234567890abcdef0

# 인스턴스 시작
aws ec2 start-instances --instance-ids i-1234567890abcdef0

# VPC 확인
aws ec2 describe-instances --instance-ids i-1234567890abcdef0 \
  --query "Reservations[0].Instances[0].VpcId"

# 보안 그룹 수정
aws ec2 modify-instance-attribute \
  --instance-id i-1234567890abcdef0 \
  --groups sg-12345
```

### 문제 3: 트래픽이 분산되지 않음

#### 증상
- 모든 요청이 하나의 인스턴스로만 전달
- 로드 밸런싱이 작동하지 않음

#### 원인
- 세션 고정(Session Affinity) 설정
- 인스턴스 상태 불일치
- 로드 밸런싱 알고리즘 문제

#### 해결 방법
```bash
# Target Group 설정 확인
aws elbv2 describe-target-groups \
  --target-group-arns arn:aws:elasticloadbalancing:region:account:targetgroup/web-servers-tg/1234567890123456

# 세션 고정 비활성화
aws elbv2 modify-target-group-attributes \
  --target-group-arn arn:aws:elasticloadbalancing:region:account:targetgroup/web-servers-tg/1234567890123456 \
  --attributes Key=stickiness.enabled,Value=false

# 인스턴스 상태 확인
aws elbv2 describe-target-health \
  --target-group-arn arn:aws:elasticloadbalancing:region:account:targetgroup/web-servers-tg/1234567890123456
```

---

## 📈 오토 스케일링 관련 문제

### 문제 1: Auto Scaling Group 생성 실패

#### 증상
```bash
ERROR: Launch configuration not found
```

#### 원인
- Launch Template/Configuration이 존재하지 않음
- Launch Template/Configuration에 오류가 있음
- 권한 부족

#### 해결 방법
```bash
# Launch Template 확인
aws ec2 describe-launch-templates --launch-template-names web-server-template

# Launch Template 생성
aws ec2 create-launch-template \
  --launch-template-name web-server-template \
  --launch-template-data '{
    "ImageId": "ami-0abcdef1234567890",
    "InstanceType": "t2.micro",
    "SecurityGroupIds": ["sg-12345"]
  }'

# ASG 생성
aws autoscaling create-auto-scaling-group \
  --auto-scaling-group-name web-servers-asg \
  --launch-template LaunchTemplateName=web-server-template,Version='$Latest' \
  --min-size 1 \
  --max-size 5 \
  --desired-capacity 2 \
  --vpc-zone-identifier "subnet-12345,subnet-67890"
```

### 문제 2: 스케일링이 작동하지 않음

#### 증상
- CPU 사용률이 높아도 인스턴스가 추가되지 않음
- 스케일링 정책이 실행되지 않음

#### 원인
- 스케일링 정책이 설정되지 않음
- CloudWatch 메트릭이 수집되지 않음
- ASG 설정 문제

#### 해결 방법
```bash
# ASG 설정 확인
aws autoscaling describe-auto-scaling-groups \
  --auto-scaling-group-names web-servers-asg

# 스케일링 정책 확인
aws autoscaling describe-policies \
  --auto-scaling-group-name web-servers-asg

# 스케일링 정책 생성
aws autoscaling put-scaling-policy \
  --auto-scaling-group-name web-servers-asg \
  --policy-name scale-out-policy \
  --policy-type TargetTrackingScaling \
  --target-tracking-configuration '{
    "TargetValue": 70.0,
    "PredefinedMetricSpecification": {
      "PredefinedMetricType": "ASGAverageCPUUtilization"
    }
  }'

# CloudWatch 메트릭 확인
aws cloudwatch get-metric-statistics \
  --namespace AWS/EC2 \
  --metric-name CPUUtilization \
  --dimensions Name=AutoScalingGroupName,Value=web-servers-asg \
  --start-time 2024-01-01T00:00:00Z \
  --end-time 2024-01-01T23:59:59Z \
  --period 300 \
  --statistics Average
```

### 문제 3: 인스턴스가 자동으로 종료됨

#### 증상
- 인스턴스가 예상보다 빨리 종료됨
- 스케일 인이 너무 빈번하게 발생

#### 원인
- 스케일 인 정책이 너무 민감함
- 쿨다운 시간이 짧음
- 헬스체크 실패

#### 해결 방법
```bash
# 스케일링 정책 수정
aws autoscaling put-scaling-policy \
  --auto-scaling-group-name web-servers-asg \
  --policy-name scale-in-policy \
  --policy-type TargetTrackingScaling \
  --target-tracking-configuration '{
    "TargetValue": 30.0,
    "PredefinedMetricSpecification": {
      "PredefinedMetricType": "ASGAverageCPUUtilization"
    },
    "ScaleInCooldown": 600,
    "ScaleOutCooldown": 300
  }'

# ASG 설정 수정
aws autoscaling update-auto-scaling-group \
  --auto-scaling-group-name web-servers-asg \
  --health-check-grace-period 300 \
  --termination-policies "OldestInstance"
```

---

## 🏥 헬스체크 관련 문제

### 문제 1: 헬스체크 실패

#### 증상
```bash
ERROR: Health check failed
```

#### 원인
- 애플리케이션이 실행되지 않음
- 포트가 열려있지 않음
- 방화벽 차단
- 헬스체크 경로 오류

#### 해결 방법
```bash
# 애플리케이션 상태 확인
systemctl status httpd
systemctl status nginx

# 포트 확인
netstat -tulpn | grep :80
ss -tulpn | grep :80

# 방화벽 확인
sudo iptables -L
sudo ufw status

# 헬스체크 경로 확인
curl -f http://localhost/health
curl -f http://localhost/

# 로그 확인
tail -f /var/log/httpd/error_log
tail -f /var/log/nginx/error.log
```

### 문제 2: 헬스체크가 너무 느림

#### 증상
- 헬스체크 응답 시간이 길음
- 인스턴스가 Unhealthy로 표시됨

#### 원인
- 애플리케이션 응답 시간이 길음
- 네트워크 지연
- 헬스체크 설정 문제

#### 해결 방법
```bash
# 헬스체크 응답 시간 측정
time curl -f http://localhost/health

# 애플리케이션 성능 확인
top
htop
iostat

# 헬스체크 설정 수정
aws elbv2 modify-target-group \
  --target-group-arn arn:aws:elasticloadbalancing:region:account:targetgroup/web-servers-tg/1234567890123456 \
  --health-check-timeout-seconds 10 \
  --health-check-interval-seconds 30

# 헬스체크 경로 최적화
cat > /var/www/html/health << 'EOF'
#!/bin/bash
echo "Content-Type: text/plain"
echo ""
echo "OK"
EOF

chmod +x /var/www/html/health
```

### 문제 3: 헬스체크가 불안정함

#### 증상
- 인스턴스가 Healthy/Unhealthy 상태를 반복
- 헬스체크 결과가 일관되지 않음

#### 원인
- 애플리케이션 불안정
- 리소스 부족
- 헬스체크 임계값 설정 문제

#### 해결 방법
```bash
# 애플리케이션 안정성 확인
journalctl -u httpd -f
tail -f /var/log/messages

# 리소스 사용량 확인
free -h
df -h
iostat

# 헬스체크 임계값 조정
aws elbv2 modify-target-group \
  --target-group-arn arn:aws:elasticloadbalancing:region:account:targetgroup/web-servers-tg/1234567890123456 \
  --healthy-threshold-count 3 \
  --unhealthy-threshold-count 5

# 애플리케이션 최적화
# 메모리 사용량 최적화
# 데이터베이스 연결 풀 최적화
# 캐시 설정 최적화
```

---

## 🌐 네트워크 및 연결 문제

### 문제 1: 로드 밸런서에 접속할 수 없음

#### 증상
```bash
ERROR: Connection refused
ERROR: Connection timeout
```

#### 원인
- 보안 그룹 설정 문제
- 서브넷 라우팅 문제
- DNS 설정 문제

#### 해결 방법
```bash
# 보안 그룹 확인
aws ec2 describe-security-groups --group-ids sg-12345

# 보안 그룹 규칙 추가
aws ec2 authorize-security-group-ingress \
  --group-id sg-12345 \
  --protocol tcp \
  --port 80 \
  --cidr 0.0.0.0/0

# 서브넷 라우팅 확인
aws ec2 describe-route-tables --filters "Name=association.subnet-id,Values=subnet-12345"

# DNS 확인
nslookup my-load-balancer-1234567890.us-west-2.elb.amazonaws.com
dig my-load-balancer-1234567890.us-west-2.elb.amazonaws.com
```

### 문제 2: 인스턴스 간 통신 실패

#### 증상
- 인스턴스 간 통신이 안됨
- 데이터베이스 연결 실패

#### 원인
- 보안 그룹 규칙 문제
- VPC 설정 문제
- 네트워크 ACL 문제

#### 해결 방법
```bash
# 보안 그룹 규칙 확인
aws ec2 describe-security-groups --group-ids sg-12345

# 보안 그룹 규칙 추가
aws ec2 authorize-security-group-ingress \
  --group-id sg-12345 \
  --protocol tcp \
  --port 3306 \
  --source-group sg-12345

# VPC 설정 확인
aws ec2 describe-vpcs --vpc-ids vpc-12345

# 네트워크 ACL 확인
aws ec2 describe-network-acls --filters "Name=vpc-id,Values=vpc-12345"
```

---

## 📊 모니터링 및 알림 문제

### 문제 1: CloudWatch 메트릭이 수집되지 않음

#### 증상
- CloudWatch 대시보드에 데이터가 없음
- 알람이 작동하지 않음

#### 원인
- CloudWatch 에이전트가 설치되지 않음
- IAM 권한 부족
- 메트릭 네임스페이스 오류

#### 해결 방법
```bash
# CloudWatch 에이전트 설치
wget https://s3.amazonaws.com/amazoncloudwatch-agent/amazon_linux/amd64/latest/amazon-cloudwatch-agent.rpm
sudo rpm -U ./amazon-cloudwatch-agent.rpm

# CloudWatch 에이전트 설정
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-config-wizard

# IAM 권한 확인
aws iam list-attached-user-policies --user-name your-username

# 필요한 권한 추가
aws iam attach-user-policy \
  --user-name your-username \
  --policy-arn arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy

# 메트릭 확인
aws cloudwatch list-metrics --namespace AWS/EC2
```

### 문제 2: 알림이 발송되지 않음

#### 증상
- 알람이 발생해도 알림이 오지 않음
- SNS 토픽이 작동하지 않음

#### 원인
- SNS 토픽 설정 문제
- 이메일 구독 확인 안됨
- 알람 설정 오류

#### 해결 방법
```bash
# SNS 토픽 확인
aws sns list-topics

# SNS 구독 확인
aws sns list-subscriptions-by-topic \
  --topic-arn arn:aws:sns:region:account:alerts

# 이메일 구독 확인
aws sns get-subscription-attributes \
  --subscription-arn arn:aws:sns:region:account:alerts:subscription-id

# 알람 설정 확인
aws cloudwatch describe-alarms --alarm-names "High-CPU-Usage"

# 테스트 알림 발송
aws sns publish \
  --topic-arn arn:aws:sns:region:account:alerts \
  --message "Test message"
```

---

## ⚡ 성능 및 최적화 문제

### 문제 1: 로드 밸런서 응답 시간이 느림

#### 증상
- 로드 밸런서를 통한 응답 시간이 길음
- 사용자 경험 저하

#### 원인
- 백엔드 인스턴스 성능 문제
- 로드 밸런서 설정 문제
- 네트워크 지연

#### 해결 방법
```bash
# 백엔드 인스턴스 성능 확인
ssh -i key.pem ec2-user@instance-ip "top"
ssh -i key.pem ec2-user@instance-ip "iostat"

# 로드 밸런서 설정 최적화
aws elbv2 modify-target-group \
  --target-group-arn arn:aws:elasticloadbalancing:region:account:targetgroup/web-servers-tg/1234567890123456 \
  --deregistration-delay-timeout-seconds 30

# 연결 드레이닝 설정
aws elbv2 modify-target-group-attributes \
  --target-group-arn arn:aws:elasticloadbalancing:region:account:targetgroup/web-servers-tg/1234567890123456 \
  --attributes Key=deregistration_delay.timeout_seconds,Value=30

# 인스턴스 최적화
# 애플리케이션 최적화
# 데이터베이스 최적화
# 캐시 설정
```

### 문제 2: 스케일링이 너무 느림

#### 증상
- 트래픽 증가 시 스케일링이 늦음
- 서비스 성능 저하

#### 원인
- 스케일링 정책 설정 문제
- 인스턴스 시작 시간이 길음
- 쿨다운 시간이 길음

#### 해결 방법
```bash
# 스케일링 정책 최적화
aws autoscaling put-scaling-policy \
  --auto-scaling-group-name web-servers-asg \
  --policy-name scale-out-policy \
  --policy-type TargetTrackingScaling \
  --target-tracking-configuration '{
    "TargetValue": 60.0,
    "PredefinedMetricSpecification": {
      "PredefinedMetricType": "ASGAverageCPUUtilization"
    },
    "ScaleOutCooldown": 180,
    "ScaleInCooldown": 300
  }'

# 인스턴스 시작 시간 최적화
# AMI 최적화
# 사용자 데이터 스크립트 최적화
# 애플리케이션 시작 시간 단축

# 예측적 스케일링 활성화
aws autoscaling put-scaling-policy \
  --auto-scaling-group-name web-servers-asg \
  --policy-name predictive-scale-out \
  --policy-type PredictiveScaling \
  --predictive-scaling-configuration '{
    "MetricSpecifications": [{
      "TargetValue": 70.0,
      "PredefinedMetricSpecification": {
        "PredefinedMetricType": "ASGAverageCPUUtilization"
      }
    }],
    "Mode": "ForecastOnly"
  }'
```

---

## 🚨 일반적인 오류 코드

### AWS 오류 코드

| 오류 코드 | 의미 | 해결 방법 |
|-----------|------|-----------|
| **AccessDenied** | 권한 부족 | IAM 권한 확인 및 추가 |
| **InvalidParameter** | 잘못된 매개변수 | 매개변수 값 확인 |
| **ResourceNotFound** | 리소스 없음 | 리소스 존재 여부 확인 |
| **LimitExceeded** | 한도 초과 | AWS 한도 증가 요청 |
| **InsufficientCapacity** | 용량 부족 | 다른 AZ 또는 인스턴스 타입 시도 |

### GCP 오류 코드

| 오류 코드 | 의미 | 해결 방법 |
|-----------|------|-----------|
| **PERMISSION_DENIED** | 권한 부족 | IAM 권한 확인 및 추가 |
| **INVALID_ARGUMENT** | 잘못된 인수 | 인수 값 확인 |
| **NOT_FOUND** | 리소스 없음 | 리소스 존재 여부 확인 |
| **QUOTA_EXCEEDED** | 할당량 초과 | 할당량 증가 요청 |
| **RESOURCE_EXHAUSTED** | 리소스 부족 | 다른 리전 또는 존 시도 |

---

## 🔧 디버깅 도구 및 명령어

### AWS 디버깅
```bash
# 로그 확인
aws logs describe-log-groups
aws logs get-log-events --log-group-name /aws/elasticloadbalancing/web-alb

# 메트릭 확인
aws cloudwatch get-metric-statistics \
  --namespace AWS/ApplicationELB \
  --metric-name TargetResponseTime \
  --start-time 2024-01-01T00:00:00Z \
  --end-time 2024-01-01T23:59:59Z \
  --period 300 \
  --statistics Average

# 이벤트 확인
aws autoscaling describe-scaling-activities \
  --auto-scaling-group-name web-servers-asg
```

### GCP 디버깅
```bash
# 로그 확인
gcloud logging read "resource.type=gce_instance" --limit=50

# 메트릭 확인
gcloud monitoring metrics list --filter="metric.type:compute.googleapis.com/instance/cpu/utilization"

# 이벤트 확인
gcloud compute operations list --filter="operationType:insert"
```

---

## 📞 지원 및 도움말

### 공식 문서
- [AWS ELB 트러블슈팅 가이드](https://docs.aws.amazon.com/elasticloadbalancing/latest/userguide/troubleshooting.html)
- [AWS Auto Scaling 트러블슈팅 가이드](https://docs.aws.amazon.com/autoscaling/ec2/userguide/troubleshooting.html)
- [GCP Load Balancing 트러블슈팅 가이드](https://cloud.google.com/load-balancing/docs/troubleshooting)
- [GCP Managed Instance Groups 트러블슈팅 가이드](https://cloud.google.com/compute/docs/instance-groups/troubleshooting)

### 커뮤니티 지원
- [AWS Developer Forums](https://forums.aws.amazon.com/)
- [Google Cloud Community](https://cloud.google.com/community)
- [Stack Overflow](https://stackoverflow.com/questions/tagged/aws)
- [Reddit r/aws](https://www.reddit.com/r/aws/)

### 문제 보고
문제가 지속되면 다음 정보와 함께 이슈를 생성하세요:
- 오류 메시지 전체
- 실행 환경 정보
- 재현 단계
- 로그 파일
- 설정 파일

---

## ✅ 체크리스트

### 문제 해결 전 확인사항
- [ ] 최신 버전 사용 중인가요?
- [ ] 권한 설정이 올바른가요?
- [ ] 네트워크 연결이 정상인가요?
- [ ] 리소스 할당량이 충분한가요?
- [ ] 로그를 확인했나요?

### 문제 해결 후 확인사항
- [ ] 문제가 해결되었나요?
- [ ] 다른 기능에 영향을 주지 않나요?
- [ ] 성능이 정상인가요?
- [ ] 모니터링이 정상 작동하나요?
- [ ] 알림이 정상 발송되나요?

이 가이드를 통해 대부분의 문제를 해결할 수 있습니다. 추가 도움이 필요하면 언제든 문의하세요! 🚀

---

<div align="center">

[← 이전: 장애 복구 가이드](./disaster-recovery-guide) | [📚 전체 커리큘럼](../../../curriculum) | [다음: Cloud Container 과정 →](../../../cloud_container/textbook/Day1/README)

</div>