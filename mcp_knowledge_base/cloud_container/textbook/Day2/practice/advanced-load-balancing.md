# 고급 로드 밸런싱 실습

<div align="center">

[← 이전: Cloud Container 2일차 메인](/mcp_knowledge_base/cloud_master/README.md) | [📚 전체 커리큘럼](/mcp_knowledge_base/curriculum.md) | [🏠 학습 경로로 돌아가기](/mcp_knowledge_base/index.md) | [← 이전: Cloud Container 메인](/mcp_knowledge_base/cloud_master/README.md) | [📋 학습 경로](/mcp_knowledge_base/cloud_master/learning-path.md)

</div>

## 🎯 실습 목표

이 실습을 통해 다음을 학습합니다:
- Application Load Balancer (ALB) 고급 설정
- Network Load Balancer (NLB) 구성
- GCP Cloud Load Balancing 고급 기능
- Health Check 및 Auto Scaling 연동

## 📋 사전 준비사항

- AWS 계정 (Free Tier 가능)
- GCP 계정 ($300 크레딧)
- 기본적인 로드 밸런싱 이해

## ⚖️ AWS Application Load Balancer 고급 설정

### 1단계: ALB 생성

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
    --name advanced-alb \
    --subnets $SUBNET_IDS \
    --security-groups $ALB_SG_ID \
    --scheme internet-facing \
    --type application \
    --ip-address-type ipv4
```

### 2단계: Target Group 생성

```bash
# Web 서버 Target Group 생성
aws elbv2 create-target-group \
    --name web-targets \
    --protocol HTTP \
    --port 80 \
    --vpc-id $VPC_ID \
    --target-type instance \
    --health-check-path /health \
    --health-check-interval-seconds 30 \
    --health-check-timeout-seconds 5 \
    --healthy-threshold-count 2 \
    --unhealthy-threshold-count 3

# API 서버 Target Group 생성
aws elbv2 create-target-group \
    --name api-targets \
    --protocol HTTP \
    --port 3000 \
    --vpc-id $VPC_ID \
    --target-type instance \
    --health-check-path /api/health \
    --health-check-interval-seconds 30 \
    --health-check-timeout-seconds 5 \
    --healthy-threshold-count 2 \
    --unhealthy-threshold-count 3
```

### 3단계: 리스너 및 규칙 설정

```bash
# HTTP 리스너 생성
aws elbv2 create-listener \
    --load-balancer-arn $ALB_ARN \
    --protocol HTTP \
    --port 80 \
    --default-actions Type=forward,TargetGroupArn=$WEB_TARGET_GROUP_ARN

# HTTPS 리스너 생성 (SSL 인증서 필요)
aws elbv2 create-listener \
    --load-balancer-arn $ALB_ARN \
    --protocol HTTPS \
    --port 443 \
    --certificates CertificateArn=$SSL_CERTIFICATE_ARN \
    --default-actions Type=forward,TargetGroupArn=$WEB_TARGET_GROUP_ARN

# 경로 기반 라우팅 규칙 생성
aws elbv2 create-rule \
    --listener-arn $HTTPS_LISTENER_ARN \
    --priority 100 \
    --conditions Field=path-pattern,Values='/api/*' \
    --actions Type=forward,TargetGroupArn=$API_TARGET_GROUP_ARN

# 호스트 기반 라우팅 규칙 생성
aws elbv2 create-rule \
    --listener-arn $HTTPS_LISTENER_ARN \
    --priority 200 \
    --conditions Field=host-header,Values='api.example.com' \
    --actions Type=forward,TargetGroupArn=$API_TARGET_GROUP_ARN
```

## 🌐 AWS Network Load Balancer 구성

### 1단계: NLB 생성

```bash
# NLB 생성
aws elbv2 create-load-balancer \
    --name advanced-nlb \
    --subnets $SUBNET_IDS \
    --scheme internet-facing \
    --type network \
    --ip-address-type ipv4

# TCP Target Group 생성
aws elbv2 create-target-group \
    --name tcp-targets \
    --protocol TCP \
    --port 80 \
    --vpc-id $VPC_ID \
    --target-type instance \
    --health-check-protocol TCP \
    --health-check-port 80 \
    --health-check-interval-seconds 30 \
    --health-check-timeout-seconds 10 \
    --healthy-threshold-count 2 \
    --unhealthy-threshold-count 3

# TCP 리스너 생성
aws elbv2 create-listener \
    --load-balancer-arn $NLB_ARN \
    --protocol TCP \
    --port 80 \
    --default-actions Type=forward,TargetGroupArn=$TCP_TARGET_GROUP_ARN
```

## ☁️ GCP Cloud Load Balancing 고급 설정

### 1단계: HTTP(S) Load Balancer 생성

```bash
# 백엔드 서비스 생성
gcloud compute backend-services create advanced-backend \
    --protocol=HTTP \
    --port-name=http \
    --health-checks=advanced-health-check \
    --global

# URL 맵 생성
gcloud compute url-maps create advanced-url-map \
    --default-service=advanced-backend

# HTTP 프록시 생성
gcloud compute target-http-proxies create advanced-http-proxy \
    --url-map=advanced-url-map

# HTTPS 프록시 생성 (SSL 인증서 필요)
gcloud compute target-https-proxies create advanced-https-proxy \
    --url-map=advanced-url-map \
    --ssl-certificates=advanced-ssl-cert

# 전역 포워딩 규칙 생성
gcloud compute forwarding-rules create advanced-http-rule \
    --global \
    --target-http-proxy=advanced-http-proxy \
    --ports=80

gcloud compute forwarding-rules create advanced-https-rule \
    --global \
    --target-https-proxy=advanced-https-proxy \
    --ports=443
```

### 2단계: 고급 라우팅 설정

```bash
# 경로 매처 생성
gcloud compute url-maps add-path-matcher advanced-url-map \
    --path-matcher-name=api-matcher \
    --default-service=advanced-backend \
    --path-rules="/api/*=api-backend"

# 호스트 규칙 생성
gcloud compute url-maps add-host-rule advanced-url-map \
    --hosts="api.example.com" \
    --path-matcher-name=api-matcher
```

## 🔍 Health Check 고급 설정

### 1단계: AWS Health Check 설정

```bash
# 고급 Health Check 설정
aws elbv2 modify-target-group \
    --target-group-arn $TARGET_GROUP_ARN \
    --health-check-path /health \
    --health-check-interval-seconds 15 \
    --health-check-timeout-seconds 5 \
    --healthy-threshold-count 3 \
    --unhealthy-threshold-count 2 \
    --health-check-enabled \
    --health-check-protocol HTTP \
    --health-check-port traffic-port \
    --matcher HttpCode=200,300,301,302
```

### 2단계: GCP Health Check 설정

```bash
# HTTP Health Check 생성
gcloud compute health-checks create http advanced-health-check \
    --port=80 \
    --request-path=/health \
    --check-interval=15s \
    --timeout=5s \
    --unhealthy-threshold=2 \
    --healthy-threshold=3

# HTTPS Health Check 생성
gcloud compute health-checks create https advanced-https-health-check \
    --port=443 \
    --request-path=/health \
    --check-interval=15s \
    --timeout=5s \
    --unhealthy-threshold=2 \
    --healthy-threshold=3
```

## 📈 Auto Scaling 연동

### 1단계: AWS Auto Scaling 설정

```bash
# Launch Template 생성
aws ec2 create-launch-template \
    --launch-template-name advanced-template \
    --launch-template-data '{
        "ImageId": "ami-0ae2c887094315bed",
        "InstanceType": "t3.micro",
        "SecurityGroupIds": ["'$WEB_SG_ID'"],
        "UserData": "'$(base64 -w 0 user-data.sh)'",
        "TagSpecifications": [{
            "ResourceType": "instance",
            "Tags": [{"Key": "Name", "Value": "web-server"}]
        }]
    }'

# Auto Scaling Group 생성
aws autoscaling create-auto-scaling-group \
    --auto-scaling-group-name advanced-asg \
    --launch-template LaunchTemplateName=advanced-template,Version=1 \
    --min-size 2 \
    --max-size 10 \
    --desired-capacity 3 \
    --target-group-arns $TARGET_GROUP_ARN \
    --health-check-type ELB \
    --health-check-grace-period 300 \
    --vpc-zone-identifier $SUBNET_IDS

# 스케일링 정책 생성
aws autoscaling put-scaling-policy \
    --auto-scaling-group-name advanced-asg \
    --policy-name scale-out-policy \
    --policy-type TargetTrackingScaling \
    --target-tracking-configuration '{
        "TargetValue": 70.0,
        "PredefinedMetricSpecification": {
            "PredefinedMetricType": "ASGAverageCPUUtilization"
        },
        "ScaleOutCooldown": 300,
        "ScaleInCooldown": 300
    }'
```

### 2단계: GCP Auto Scaling 설정

```bash
# 인스턴스 템플릿 생성
gcloud compute instance-templates create advanced-template \
    --machine-type=e2-micro \
    --image-family=ubuntu-2004-lts \
    --image-project=ubuntu-os-cloud \
    --boot-disk-size=10GB \
    --tags=web-server \
    --metadata-from-file startup-script=startup-script.sh

# Managed Instance Group 생성
gcloud compute instance-groups managed create advanced-mig \
    --template=advanced-template \
    --size=3 \
    --zone=asia-northeast3-a

# Auto Scaling 정책 설정
gcloud compute instance-groups managed set-autoscaling advanced-mig \
    --zone=asia-northeast3-a \
    --max-num-replicas=10 \
    --min-num-replicas=2 \
    --target-cpu-utilization=0.7 \
    --cool-down-period=60s
```

## 🧪 로드 밸런싱 테스트

### 1단계: 부하 테스트

```bash
# Apache Bench를 사용한 부하 테스트
ab -n 1000 -c 10 http://LOAD_BALANCER_IP/

# wrk를 사용한 부하 테스트
wrk -t12 -c400 -d30s http://LOAD_BALANCER_IP/

# 커스텀 스크립트로 Health Check 테스트
for i in {1..100}; do
    curl -s -o /dev/null -w "%{http_code}\n" http://LOAD_BALANCER_IP/health
    sleep 1
done
```

### 2단계: 장애 시뮬레이션

```bash
# 인스턴스 중지
aws ec2 stop-instances --instance-ids $INSTANCE_ID

# 로드 밸런서가 다른 인스턴스로 트래픽 전환하는지 확인
curl -I http://LOAD_BALANCER_IP/

# 인스턴스 재시작
aws ec2 start-instances --instance-ids $INSTANCE_ID

# Health Check 통과 후 트래픽 분산 확인
curl -I http://LOAD_BALANCER_IP/
```

## 📊 모니터링 및 메트릭

### 1단계: CloudWatch 메트릭 확인

```bash
# ALB 메트릭 확인
aws cloudwatch get-metric-statistics \
    --namespace AWS/ApplicationELB \
    --metric-name RequestCount \
    --dimensions Name=LoadBalancer,Value=$ALB_ARN \
    --start-time 2023-01-01T00:00:00Z \
    --end-time 2023-01-01T23:59:59Z \
    --period 300 \
    --statistics Sum

# Target Group 메트릭 확인
aws cloudwatch get-metric-statistics \
    --namespace AWS/ApplicationELB \
    --metric-name TargetResponseTime \
    --dimensions Name=TargetGroup,Value=$TARGET_GROUP_ARN \
    --start-time 2023-01-01T00:00:00Z \
    --end-time 2023-01-01T23:59:59Z \
    --period 300 \
    --statistics Average
```

### 2단계: GCP 모니터링 설정

```bash
# 커스텀 메트릭 생성
gcloud monitoring metrics-descriptors create \
    --display-name="Load Balancer Request Count" \
    --type="custom.googleapis.com/loadbalancer/request_count" \
    --metric-kind="GAUGE" \
    --value-type="INT64"

# 알림 정책 생성
gcloud alpha monitoring policies create \
    --policy-from-file=load-balancer-alert-policy.yaml
```

## 📝 실습 결과 확인

### 체크리스트

- [ ] ALB 고급 설정 완료
- [ ] NLB 구성 완료
- [ ] GCP Load Balancing 설정 완료
- [ ] Health Check 고급 설정 완료
- [ ] Auto Scaling 연동 완료
- [ ] 부하 테스트 성공
- [ ] 장애 복구 테스트 성공

### 성능 지표

- **응답 시간**: 95% 요청이 200ms 이내
- **가용성**: 99.9% 이상
- **처리량**: 초당 1000 요청 처리
- **복구 시간**: 장애 발생 시 30초 이내 복구

## 🔧 문제 해결

### 자주 발생하는 문제

1. **Health Check 실패**
   - 보안 그룹/방화벽 규칙 확인
   - 애플리케이션 Health Check 엔드포인트 확인
   - 포트 및 프로토콜 설정 확인

2. **로드 밸런서 502 오류**
   - Target Group 상태 확인
   - 인스턴스 그룹 설정 확인
   - 백엔드 서비스 상태 확인

3. **Auto Scaling 작동 안함**
   - CloudWatch 메트릭 확인
   - 스케일링 정책 설정 확인
   - IAM 권한 확인

4. **SSL 인증서 문제**
   - 인증서 유효성 확인
   - 도메인 매칭 확인
   - 인증서 체인 확인

## 📚 추가 학습 자료

- [AWS Load Balancer 공식 문서](https://docs.aws.amazon.com/elasticloadbalancing/)
- [GCP Load Balancing 공식 문서](https://cloud.google.com/load-balancing/docs)
- [로드 밸런싱 모범 사례](https://docs.aws.amazon.com/wellarchitected/latest/reliability-pillar/load-balancing.html)
- [성능 최적화 가이드](https://cloud.google.com/load-balancing/docs/performance)