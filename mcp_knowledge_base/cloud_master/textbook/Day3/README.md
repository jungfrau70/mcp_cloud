# Cloud Master - 3일차: 로드 밸런싱, 모니터링, 비용 최적화

<details>
<summary>📋 목차</summary>

1. [🎯 학습 목표](#-학습-목표)
2. [📚 실습 가이드](#-실습-가이드)
3. [🔧 실습 환경 준비](#-실습-환경-준비)
4. [⚖️ 로드 밸런싱 및 Auto Scaling](#️-로드-밸런싱-및-auto-scaling)
5. [📊 컨테이너 모니터링 및 로깅](#-컨테이너-모니터링-및-로깅)
6. [🔄 장애 복구 및 운영 자동화](#-장애-복구-및-운영-자동화)
7. [💰 비용 최적화 및 운영 전략](#-비용-최적화-및-운영-전략)
8. [📚 문제 해결 및 참고 자료](#-문제-해결-및-참고-자료)

</details>

---

## 🎯 학습 목표

### 핵심 학습 목표
- **로드 밸런싱** ELB, Cloud Load Balancing 구성
- **Auto Scaling** Auto Scaling Group, Managed Instance Group
- **모니터링** CloudWatch, Cloud Monitoring 설정
- **장애 복구** Health Check 기반 자동 교체

### 실습 후 달성할 수 있는 능력
- ✅ 로드 밸런서 구성 및 트래픽 분산
- ✅ Auto Scaling 정책 설정 및 자동 확장
- ✅ 모니터링 대시보드 구축
- ✅ 장애 복구 자동화 구현

### 예상 소요 시간
- **로드 밸런싱**: 120-150분
- **Auto Scaling**: 90-120분
- **모니터링**: 90-120분
- **장애 복구**: 60-90분
- **전체 과정**: 6-8시간

---

## 📚 실습 가이드

<details>
<summary>📖 실습 가이드 개요</summary>

### 실습 구성
1. **로드 밸런싱 및 Auto Scaling** (150분)
2. **컨테이너 모니터링 및 로깅** (120분)
3. **장애 복구 및 운영 자동화** (90분)
4. **비용 최적화 및 운영 전략** (60분)

### 실습 방식
- **로드 밸런싱**: ELB, Cloud Load Balancing 구성
- **Auto Scaling**: 정책 설정 및 자동 확장 테스트
- **모니터링**: Prometheus, Grafana, CloudWatch
- **장애 복구**: Health Check 기반 자동 교체

### 실습 결과물
- 로드 밸런서 구성
- Auto Scaling 그룹 설정
- 모니터링 대시보드
- 장애 복구 자동화

</details>

<details>
<summary>🔗 관련 실습 가이드</summary>

### 📖 상세 실습 가이드
- 🔗 [로드 밸런싱 가이드](./load-balancing-guide.md) - ELB, Cloud Load Balancing 구성
- 🔗 [Auto Scaling 가이드](./auto-scaling-guide.md) - ASG, MIG 자동 확장 설정
- 🔗 [통합 가이드](./integration-guide.md) - 로드 밸런서 + 오토스케일링 연동
- 🔗 [장애 복구 가이드](./disaster-recovery-guide.md) - 장애 시뮬레이션 및 복구

### 📚 데모 프로젝트
- 🔗 [Actions Demo 프로젝트](./actions-demo/README.md) - GitHub Actions CI/CD 데모
- 🔗 [My App 프로젝트](./my-app/README.md) - Docker 기반 웹 애플리케이션
- 🔗 [스크립트 모음](./scripts/README.md) - AWS/GCP 자동화 스크립트

### 🛠️ 문제 해결 가이드
- 🔗 [트러블슈팅 가이드](./troubleshooting-guide.md) - 로드 밸런싱, 오토스케일링, 모니터링 문제 해결

### 🔗 관련 과정 링크
- 🔗 [Cloud Master 1일차](../Day1/README.md) - Docker, Git/GitHub, GitHub Actions 기초
- 🔗 [Cloud Master 2일차](../Day2/README.md) - 고급 CI/CD 및 VM 기반 컨테이너 배포
- 🔗 [Cloud Container 과정](../../../cloud_container/textbook/Day1/README.md) - 컨테이너 심화 과정
- 🔗 [전체 커리큘럼](../../../curriculum.md) - 전체 과정 구조 및 학습 경로

</details>

---

## 🔧 실습 환경 준비

<details>
<summary>📋 필수 계정 및 도구</summary>

### 필수 계정
- **AWS 계정**: Free Tier 계정
- **GCP 계정**: $300 크레딧 계정
- **GitHub 계정**: 저장소 관리 및 Actions 사용
- **Docker Hub 계정**: 컨테이너 이미지 저장소

### 필수 도구
- **AWS CLI**: AWS 서비스 관리
- **gcloud CLI**: Google Cloud 서비스 관리
- **Docker**: 컨테이너 이미지 빌드
- **kubectl**: Kubernetes 클러스터 관리 (선택사항)

</details>

<details>
<summary>🔧 1일차 실습 완료 확인</summary>

### 필수 완료 사항
- [ ] Docker 고급 기술 및 최적화 완료
- [ ] GitHub Actions 고급 워크플로우 구축
- [ ] VM 기반 컨테이너 배포 자동화
- [ ] 완전 자동화된 CI/CD 파이프라인

### 실습 환경 확인
```bash
# AWS CLI 설정 확인
aws sts get-caller-identity

# gcloud 설정 확인
gcloud auth list

# Docker 설정 확인
docker --version
docker-compose --version
```

</details>

---

## ⚖️ 로드 밸런싱 및 Auto Scaling

<details>
<summary>📖 로드 밸런싱 개념</summary>

### 로드 밸런싱이란?
- **정의**: 여러 서버에 트래픽을 분산하는 기술
- **목적**: 가용성 향상, 성능 최적화, 장애 복구
- **유형**: Layer 4 (TCP/UDP), Layer 7 (HTTP/HTTPS)

### AWS ELB vs GCP Cloud Load Balancing
| 구분 | AWS ELB | GCP Cloud Load Balancing |
|------|---------|--------------------------|
| **유형** | ALB, NLB, CLB | HTTP(S), TCP, UDP |
| **대상** | EC2, ECS, Lambda | Compute Engine, GKE |
| **가격** | 시간당 요금 | 시간당 요금 |
| **모니터링** | CloudWatch | Cloud Monitoring |

</details>

<details>
<summary>🔗 AWS ELB 실습</summary>

### Application Load Balancer 생성
```bash
# VPC ID 확인
VPC_ID=$(aws ec2 describe-vpcs \
    --filters "Name=is-default,Values=true" \
    --query 'Vpcs[0].VpcId' \
    --output text)

# 서브넷 ID 확인
SUBNET_IDS=$(aws ec2 describe-subnets \
    --filters "Name=vpc-id,Values=$VPC_ID" \
    --query 'Subnets[0:2].SubnetId' \
    --output text)

# 보안 그룹 생성
aws ec2 create-security-group \
    --group-name alb-sg \
    --description "Security group for ALB" \
    --vpc-id $VPC_ID

# HTTP/HTTPS 포트 열기
aws ec2 authorize-security-group-ingress \
    --group-name alb-sg \
    --protocol tcp \
    --port 80 \
    --cidr 0.0.0.0/0

aws ec2 authorize-security-group-ingress \
    --group-name alb-sg \
    --protocol tcp \
    --port 443 \
    --cidr 0.0.0.0/0

# ALB 생성
aws elbv2 create-load-balancer \
    --name my-app-alb \
    --subnets $SUBNET_IDS \
    --security-groups $ALB_SG_ID \
    --scheme internet-facing \
    --type application
```

### Target Group 생성
```bash
# Target Group 생성
aws elbv2 create-target-group \
    --name my-app-targets \
    --protocol HTTP \
    --port 3000 \
    --vpc-id $VPC_ID \
    --target-type instance \
    --health-check-path /health \
    --health-check-interval-seconds 30 \
    --health-check-timeout-seconds 5 \
    --healthy-threshold-count 2 \
    --unhealthy-threshold-count 3

# Target Group에 인스턴스 등록
aws elbv2 register-targets \
    --target-group-arn $TARGET_GROUP_ARN \
    --targets Id=$INSTANCE_ID_1,Port=3000 Id=$INSTANCE_ID_2,Port=3000
```

</details>

<details>
<summary>🔗 GCP Cloud Load Balancing 실습</summary>

### HTTP(S) Load Balancer 생성
```bash
# 백엔드 서비스 생성
gcloud compute backend-services create my-app-backend \
    --protocol=HTTP \
    --port-name=http \
    --health-checks=my-app-health-check \
    --global

# 인스턴스 그룹 생성
gcloud compute instance-groups unmanaged create my-app-group \
    --zone=asia-northeast3-a

# 인스턴스를 그룹에 추가
gcloud compute instance-groups unmanaged add-instances my-app-group \
    --instances=my-app-instance-1,my-app-instance-2 \
    --zone=asia-northeast3-a

# 백엔드 서비스에 인스턴스 그룹 추가
gcloud compute backend-services add-backend my-app-backend \
    --instance-group=my-app-group \
    --instance-group-zone=asia-northeast3-a \
    --global

# URL 맵 생성
gcloud compute url-maps create my-app-map \
    --default-service=my-app-backend

# HTTP 프록시 생성
gcloud compute target-http-proxies create my-app-proxy \
    --url-map=my-app-map

# 전역 포워딩 규칙 생성
gcloud compute forwarding-rules create my-app-rule \
    --global \
    --target-http-proxy=my-app-proxy \
    --ports=80
```

</details>

<details>
<summary>🔗 Auto Scaling 실습</summary>

### AWS Auto Scaling Group
```bash
# Launch Template 생성
aws ec2 create-launch-template \
    --launch-template-name my-app-template \
    --launch-template-data '{
        "ImageId": "ami-0ae2c887094315bed",
        "InstanceType": "t3.micro",
        "SecurityGroupIds": ["'$WEB_SG_ID'"],
        "UserData": "'$(base64 -w 0 user-data.sh)'"
    }'

# Auto Scaling Group 생성
aws autoscaling create-auto-scaling-group \
    --auto-scaling-group-name my-app-asg \
    --launch-template LaunchTemplateName=my-app-template,Version=1 \
    --min-size 1 \
    --max-size 5 \
    --desired-capacity 2 \
    --target-group-arns $TARGET_GROUP_ARN \
    --health-check-type ELB \
    --health-check-grace-period 300

# 스케일링 정책 생성
aws autoscaling put-scaling-policy \
    --auto-scaling-group-name my-app-asg \
    --policy-name my-app-scale-out \
    --policy-type TargetTrackingScaling \
    --target-tracking-configuration '{
        "TargetValue": 70.0,
        "PredefinedMetricSpecification": {
            "PredefinedMetricType": "ASGAverageCPUUtilization"
        }
    }'
```

### GCP Managed Instance Group
```bash
# 인스턴스 템플릿 생성
gcloud compute instance-templates create my-app-template \
    --machine-type=e2-micro \
    --image-family=ubuntu-2004-lts \
    --image-project=ubuntu-os-cloud \
    --boot-disk-size=10GB \
    --tags=http-server \
    --metadata-from-file startup-script=startup-script.sh

# Managed Instance Group 생성
gcloud compute instance-groups managed create my-app-mig \
    --template=my-app-template \
    --size=2 \
    --zone=asia-northeast3-a

# Auto Scaling 정책 설정
gcloud compute instance-groups managed set-autoscaling my-app-mig \
    --zone=asia-northeast3-a \
    --max-num-replicas=5 \
    --min-num-replicas=1 \
    --target-cpu-utilization=0.7
```

</details>

---

## 📊 컨테이너 모니터링 및 로깅

<details>
<summary>📖 모니터링 개념</summary>

### 모니터링의 3가지 기둥
- **메트릭**: CPU, 메모리, 네트워크 사용량
- **로그**: 애플리케이션 로그, 시스템 로그
- **트레이스**: 요청 추적, 성능 분석

### 모니터링 도구 비교
| 구분 | AWS | GCP | 오픈소스 |
|------|-----|-----|----------|
| **메트릭** | CloudWatch | Cloud Monitoring | Prometheus |
| **로그** | CloudWatch Logs | Cloud Logging | ELK Stack |
| **트레이스** | X-Ray | Cloud Trace | Jaeger |

</details>

<details>
<summary>🔗 AWS CloudWatch 실습</summary>

### CloudWatch 메트릭 설정
```bash
# 커스텀 메트릭 전송
aws cloudwatch put-metric-data \
    --namespace "MyApp/ECS" \
    --metric-data MetricName=RequestCount,Value=100,Unit=Count

# CloudWatch 대시보드 생성
aws cloudwatch put-dashboard \
    --dashboard-name "MyApp-Dashboard" \
    --dashboard-body '{
        "widgets": [
            {
                "type": "metric",
                "properties": {
                    "metrics": [
                        ["AWS/EC2", "CPUUtilization", "InstanceId", "i-1234567890abcdef0"]
                    ],
                    "period": 300,
                    "stat": "Average",
                    "region": "ap-northeast-2",
                    "title": "EC2 CPU Utilization"
                }
            }
        ]
    }'
```

### CloudWatch 알람 설정
```bash
# CPU 사용률 알람 생성
aws cloudwatch put-metric-alarm \
    --alarm-name "High CPU Utilization" \
    --alarm-description "Alarm when CPU exceeds 80%" \
    --metric-name CPUUtilization \
    --namespace AWS/EC2 \
    --statistic Average \
    --period 300 \
    --threshold 80.0 \
    --comparison-operator GreaterThanThreshold \
    --evaluation-periods 2
```

</details>

<details>
<summary>🔗 GCP Cloud Monitoring 실습</summary>

### Cloud Monitoring 설정
```bash
# 커스텀 메트릭 생성
gcloud monitoring metrics-descriptors create \
    --display-name="Request Count" \
    --type="custom.googleapis.com/myapp/request_count" \
    --metric-kind="GAUGE" \
    --value-type="INT64"

# 알림 정책 생성
gcloud alpha monitoring policies create \
    --policy-from-file=alert-policy.yaml
```

### Prometheus + Grafana 설정
```yaml
# prometheus.yml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'my-app'
    static_configs:
      - targets: ['my-app:3000']
    metrics_path: /metrics
    scrape_interval: 5s
```

</details>

---

## 🔄 장애 복구 및 운영 자동화

<details>
<summary>📖 장애 복구 전략</summary>

### Health Check 기반 복구
- **Health Check**: 애플리케이션 상태 확인
- **자동 교체**: 장애 인스턴스 자동 교체
- **롤링 업데이트**: 무중단 배포

### 복구 시간 목표 (RTO)
- **RTO**: Recovery Time Objective (복구 시간 목표)
- **RPO**: Recovery Point Objective (복구 지점 목표)
- **SLA**: Service Level Agreement (서비스 수준 협약)

</details>

<details>
<summary>🔗 Health Check 설정</summary>

### AWS ELB Health Check
```bash
# Target Group Health Check 설정
aws elbv2 modify-target-group \
    --target-group-arn $TARGET_GROUP_ARN \
    --health-check-path /health \
    --health-check-interval-seconds 30 \
    --health-check-timeout-seconds 5 \
    --healthy-threshold-count 2 \
    --unhealthy-threshold-count 3
```

### GCP Health Check
```bash
# Health Check 생성
gcloud compute health-checks create http my-app-health-check \
    --port=3000 \
    --request-path=/health \
    --check-interval=30s \
    --timeout=5s \
    --unhealthy-threshold=3 \
    --healthy-threshold=2
```

</details>

<details>
<summary>🔗 자동 복구 구현</summary>

### AWS Auto Recovery
```bash
# Auto Recovery 설정
aws ec2 modify-instance-attribute \
    --instance-id $INSTANCE_ID \
    --source-dest-check Value=false

# CloudWatch 알람으로 Auto Recovery
aws cloudwatch put-metric-alarm \
    --alarm-name "Instance Status Check Failed" \
    --alarm-description "Alarm when instance status check fails" \
    --metric-name StatusCheckFailed \
    --namespace AWS/EC2 \
    --statistic Maximum \
    --period 60 \
    --threshold 1.0 \
    --comparison-operator GreaterThanOrEqualToThreshold \
    --evaluation-periods 2 \
    --alarm-actions arn:aws:automate:region:ec2:recover
```

### GCP Auto Healing
```bash
# Auto Healing 설정
gcloud compute instance-groups managed set-autohealing my-app-mig \
    --zone=asia-northeast3-a \
    --health-check=my-app-health-check \
    --initial-delay=300s
```

</details>

---

## 💰 비용 최적화 및 운영 전략

<details>
<summary>📖 비용 최적화 전략</summary>

### AWS 비용 최적화
- **Reserved Instances**: 1-3년 약정으로 최대 75% 할인
- **Spot Instances**: 미사용 인스턴스 활용으로 최대 90% 할인
- **Auto Scaling**: 필요에 따른 자동 확장/축소

### GCP 비용 최적화
- **Committed Use Discounts**: 1-3년 약정으로 최대 70% 할인
- **Preemptible Instances**: 단기 작업용으로 최대 80% 할인
- **Sustained Use Discounts**: 장기 사용 시 자동 할인

</details>

<details>
<summary>🔗 비용 모니터링 설정</summary>

### AWS Cost Explorer
```bash
# 비용 및 사용량 보고서 활성화
aws ce create-cost-category-definition \
    --name "Environment" \
    --rules '[
        {
            "Value": "Production",
            "Rule": {
                "Dimensions": {
                    "Key": "TAG",
                    "Values": ["Environment=Production"]
                }
            }
        }
    ]'
```

### GCP Billing 알림
```bash
# 예산 알림 설정
gcloud billing budgets create \
    --billing-account=BILLING_ACCOUNT_ID \
    --display-name="My App Budget" \
    --budget-amount=100USD \
    --threshold-rule=percent=50 \
    --threshold-rule=percent=90 \
    --threshold-rule=percent=100
```

</details>

---

## 📚 문제 해결 및 참고 자료

<details>
<summary>🐛 자주 발생하는 문제</summary>

### 로드 밸런싱 관련 문제
<details>
<summary>❌ 로드 밸런서에서 502 오류</summary>

**원인**: 
- Target Group에 인스턴스가 없음
- Health Check 실패
- 보안 그룹 설정 문제

**해결방법**:
```bash
# 1. Target Group 상태 확인
aws elbv2 describe-target-health --target-group-arn $TARGET_GROUP_ARN

# 2. Health Check 설정 확인
aws elbv2 describe-target-groups --target-group-arns $TARGET_GROUP_ARN

# 3. 보안 그룹 규칙 확인
aws ec2 describe-security-groups --group-ids $WEB_SG_ID
```

</details>

<details>
<summary>❌ Auto Scaling이 작동하지 않음</summary>

**원인**:
- 스케일링 정책 설정 오류
- CloudWatch 메트릭 부족
- 권한 문제

**해결방법**:
```bash
# 1. Auto Scaling Group 상태 확인
aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names my-app-asg

# 2. 스케일링 정책 확인
aws autoscaling describe-policies --auto-scaling-group-name my-app-asg

# 3. CloudWatch 메트릭 확인
aws cloudwatch get-metric-statistics \
    --namespace AWS/EC2 \
    --metric-name CPUUtilization \
    --dimensions Name=AutoScalingGroupName,Value=my-app-asg \
    --start-time 2023-01-01T00:00:00Z \
    --end-time 2023-01-01T23:59:59Z \
    --period 300 \
    --statistics Average
```

</details>

</details>

<details>
<summary>📖 추가 학습 자료</summary>

### 공식 문서
- [AWS ELB 공식 문서](https://docs.aws.amazon.com/elasticloadbalancing/)
- [GCP Cloud Load Balancing 공식 문서](https://cloud.google.com/load-balancing/docs)
- [AWS Auto Scaling 공식 문서](https://docs.aws.amazon.com/autoscaling/)
- [GCP Auto Scaling 공식 문서](https://cloud.google.com/compute/docs/autoscaler)

### 유용한 리소스
- [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)
- [GCP Architecture Center](https://cloud.google.com/architecture)
- [Prometheus 공식 문서](https://prometheus.io/docs/)
- [Grafana 공식 문서](https://grafana.com/docs/)

### 관련 프로젝트
- [AWS 샘플 프로젝트](https://github.com/aws-samples)
- [GCP 샘플 프로젝트](https://github.com/GoogleCloudPlatform)

</details>

<details>
<summary>🚀 다음 단계</summary>

### Cloud Container 과정 준비
1. **Kubernetes**: 컨테이너 오케스트레이션
2. **GKE**: Google Kubernetes Engine
3. **ECS/Fargate**: AWS 서버리스 컨테이너
4. **고가용성**: Multi-AZ, Multi-Region

### 실무 적용
1. **실제 프로젝트**: 자신의 프로젝트에 고급 기능 적용
2. **모니터링**: 종합적인 모니터링 시스템 구축
3. **자동화**: 완전 자동화된 운영 환경
4. **비용 최적화**: 지속적인 비용 최적화

</details>

---

## 🎉 완료!

축하합니다! Cloud Master 2일차 실습을 완료했습니다.

### 📚 학습 요약

이번 실습을 통해 다음을 배웠습니다:

1. **⚖️ 로드 밸런싱**: ELB, Cloud Load Balancing 구성
2. **📈 Auto Scaling**: 자동 확장 및 축소 정책
3. **📊 모니터링**: CloudWatch, Cloud Monitoring 설정
4. **🔄 장애 복구**: Health Check 기반 자동 복구

### 🚀 다음 단계

- **Cloud Container 과정**: Kubernetes, ECS, Fargate
- **실제 프로젝트 적용**: 자신의 프로젝트에 고급 기능 적용
- **고급 기능 학습**: 서비스 메시, 보안, 성능 최적화

### 💡 추가 학습 자료

- [AWS ELB 공식 문서](https://docs.aws.amazon.com/elasticloadbalancing/)
- [GCP Cloud Load Balancing 공식 문서](https://cloud.google.com/load-balancing/docs)
- [Cloud Container 과정](../../../cloud_container/textbook/Day1/README.md)

---

**🎯 이제 고급 클라우드 운영 기술을 갖추었습니다! Cloud Container 과정으로 진행하세요.**


<div align="center">

[← 이전: Cloud Master 2일차](../Day2/README.md) | [📚 전체 커리큘럼](../../../curriculum.md) | [다음 과정: Cloud Container 1일차 →](../../../cloud_container/textbook/Day1/README.md)

</div>
