# 로드 밸런싱 고급 실습

<details>
<summary>📋 목차</summary>

1. [🎯 학습 목표](#-학습-목표)
2. [📚 실습 개요](#-실습-개요)
3. [🔧 실습 환경 준비](#-실습-환경-준비)
4. [☁️ AWS 고급 로드 밸런싱](#-aws-고급-로드-밸런싱)
5. [☁️ GCP 고급 로드 밸런싱](#-gcp-고급-로드-밸런싱)
6. [🐳 Kubernetes 로드 밸런싱](#-kubernetes-로드-밸런싱)
7. [⚖️ Auto Scaling 고급 설정](#️-auto-scaling-고급-설정)
8. [📚 문제 해결 및 참고 자료](#-문제-해결-및-참고-자료)

</details>

---

## 🎯 학습 목표

<details>
<summary>📖 이번 실습에서 배우게 될 내용</summary>

### 핵심 학습 목표
- **고급 로드 밸런싱** ALB, NLB, Cloud Load Balancing 고급 구성
- **Health Check 고급 설정** HTTP, TCP, Custom Health Check
- **로드 밸런싱 전략** Round Robin, Least Connections, Weighted
- **Auto Scaling 고급 정책** CPU, 메모리, 커스텀 메트릭 기반

### 실습 후 달성할 수 있는 능력
- ✅ 고급 로드 밸런싱 구성 및 최적화
- ✅ Health Check 고급 설정 및 모니터링
- ✅ Auto Scaling 고급 정책 설정
- ✅ 로드 밸런싱 성능 최적화

### 예상 소요 시간
- **AWS 고급 로드 밸런싱**: 90-120분
- **GCP 고급 로드 밸런싱**: 90-120분
- **Kubernetes 로드 밸런싱**: 60-90분
- **Auto Scaling 고급 설정**: 60-90분
- **전체 과정**: 5-7시간

</details>

---

## 📚 실습 개요

<details>
<summary>📖 실습 시나리오</summary>

### 프로젝트 개요
**고성능 웹 애플리케이션**의 로드 밸런싱 및 Auto Scaling을 구성합니다.

### 성능 요구사항
- **처리량**: 초당 10,000 요청 처리
- **응답 시간**: 95% 요청이 100ms 이내
- **가용성**: 99.99% 이상
- **확장성**: 트래픽 증가에 따른 자동 확장

### 구현할 구성 요소
1. **Application Load Balancer**: Layer 7 로드 밸런싱
2. **Network Load Balancer**: Layer 4 고성능 로드 밸런싱
3. **Auto Scaling Group**: 자동 확장 및 축소
4. **Health Check**: 고급 상태 확인

</details>

---

## 🔧 실습 환경 준비

<details>
<summary>📋 필수 도구 및 계정</summary>

### 필수 계정
- **AWS 계정**: Free Tier (ALB, NLB 실습용)
- **GCP 계정**: $300 크레딧 (Cloud Load Balancing 실습용)
- **Docker Hub**: 컨테이너 이미지 저장소

### 필수 도구
```bash
# AWS CLI 설정 확인
aws --version
aws configure list

# GCP CLI 설정 확인
gcloud --version
gcloud auth list

# kubectl 설정 확인
kubectl version --client

# Docker 설정 확인
docker --version
```

### 환경 변수 설정
```bash
# AWS 설정
export AWS_DEFAULT_REGION=ap-northeast-2
export AWS_AVAILABILITY_ZONE_1=ap-northeast-2a
export AWS_AVAILABILITY_ZONE_2=ap-northeast-2c

# GCP 설정
export GCP_PROJECT_ID=my-project-123456
export GCP_REGION=asia-northeast3
export GCP_ZONE_1=asia-northeast3-a
export GCP_ZONE_2=asia-northeast3-b
export GCP_ZONE_3=asia-northeast3-c
```

</details>

---

## ☁️ AWS 고급 로드 밸런싱

<details>
<summary>📖 AWS 로드 밸런싱 타입</summary>

### 로드 밸런싱 타입 비교
| 타입 | 계층 | 프로토콜 | 특징 | 사용 사례 |
|------|------|----------|------|-----------|
| **ALB** | Layer 7 | HTTP/HTTPS | 라우팅, SSL 종료 | 웹 애플리케이션 |
| **NLB** | Layer 4 | TCP/UDP | 고성능, 고가용성 | 게임, IoT, 실시간 |
| **CLB** | Layer 4 | HTTP/HTTPS/TCP | 레거시 | 기존 애플리케이션 |
| **GWLB** | Layer 3 | IP | 게이트웨이 | 보안, 네트워크 |

### 로드 밸런싱 전략
- **Round Robin**: 순차적 분산
- **Least Connections**: 연결 수가 적은 서버 선택
- **IP Hash**: 클라이언트 IP 기반 분산
- **Weighted**: 가중치 기반 분산

</details>

<details>
<summary>🔧 1단계: Application Load Balancer 고급 설정</summary>

### ALB 생성
```bash
# ALB 생성
ALB_ARN=$(aws elbv2 create-load-balancer \
    --name my-app-alb \
    --subnets $PUBLIC_SUBNET_A $PUBLIC_SUBNET_C \
    --security-groups $WEB_SG \
    --scheme internet-facing \
    --type application \
    --ip-address-type ipv4 \
    --query 'LoadBalancers[0].LoadBalancerArn' \
    --output text)

echo "ALB ARN: $ALB_ARN"

# ALB DNS 이름 확인
ALB_DNS=$(aws elbv2 describe-load-balancers \
    --load-balancer-arns $ALB_ARN \
    --query 'LoadBalancers[0].DNSName' \
    --output text)

echo "ALB DNS: $ALB_DNS"
```

### Target Group 고급 설정
```bash
# Target Group 생성
TARGET_GROUP_ARN=$(aws elbv2 create-target-group \
    --name my-app-targets \
    --protocol HTTP \
    --port 3000 \
    --vpc-id $VPC_ID \
    --target-type instance \
    --health-check-path /health \
    --health-check-interval-seconds 30 \
    --health-check-timeout-seconds 5 \
    --healthy-threshold-count 2 \
    --unhealthy-threshold-count 3 \
    --health-check-matcher HTTP_200 \
    --health-check-enabled \
    --health-check-port traffic-port \
    --health-check-protocol HTTP \
    --query 'TargetGroups[0].TargetGroupArn' \
    --output text)

echo "Target Group ARN: $TARGET_GROUP_ARN"
```

### 리스너 및 규칙 설정
```bash
# HTTP 리스너 생성
HTTP_LISTENER_ARN=$(aws elbv2 create-listener \
    --load-balancer-arn $ALB_ARN \
    --protocol HTTP \
    --port 80 \
    --default-actions Type=forward,TargetGroupArn=$TARGET_GROUP_ARN \
    --query 'Listeners[0].ListenerArn' \
    --output text)

echo "HTTP Listener ARN: $HTTP_LISTENER_ARN"

# HTTPS 리스너 생성 (SSL 인증서 필요)
# aws elbv2 create-listener \
#     --load-balancer-arn $ALB_ARN \
#     --protocol HTTPS \
#     --port 443 \
#     --certificates CertificateArn=arn:aws:acm:region:account:certificate/cert-id \
#     --default-actions Type=forward,TargetGroupArn=$TARGET_GROUP_ARN

# 리스너 규칙 생성 (Path 기반 라우팅)
aws elbv2 create-rule \
    --listener-arn $HTTP_LISTENER_ARN \
    --priority 100 \
    --conditions Field=path-pattern,Values='/api/*' \
    --actions Type=forward,TargetGroupArn=$TARGET_GROUP_ARN

echo "Listener rules created"
```

</details>

<details>
<summary>🔧 2단계: Network Load Balancer 고급 설정</summary>

### NLB 생성
```bash
# NLB 생성
NLB_ARN=$(aws elbv2 create-load-balancer \
    --name my-app-nlb \
    --subnets $PUBLIC_SUBNET_A $PUBLIC_SUBNET_C \
    --scheme internet-facing \
    --type network \
    --ip-address-type ipv4 \
    --query 'LoadBalancers[0].LoadBalancerArn' \
    --output text)

echo "NLB ARN: $NLB_ARN"

# NLB DNS 이름 확인
NLB_DNS=$(aws elbv2 describe-load-balancers \
    --load-balancer-arns $NLB_ARN \
    --query 'LoadBalancers[0].DNSName' \
    --output text)

echo "NLB DNS: $NLB_DNS"
```

### NLB Target Group 생성
```bash
# NLB Target Group 생성
NLB_TARGET_GROUP_ARN=$(aws elbv2 create-target-group \
    --name my-app-nlb-targets \
    --protocol TCP \
    --port 80 \
    --vpc-id $VPC_ID \
    --target-type instance \
    --health-check-protocol TCP \
    --health-check-port 80 \
    --health-check-interval-seconds 30 \
    --health-check-timeout-seconds 10 \
    --healthy-threshold-count 2 \
    --unhealthy-threshold-count 3 \
    --query 'TargetGroups[0].TargetGroupArn' \
    --output text)

echo "NLB Target Group ARN: $NLB_TARGET_GROUP_ARN"
```

### NLB 리스너 생성
```bash
# NLB TCP 리스너 생성
aws elbv2 create-listener \
    --load-balancer-arn $NLB_ARN \
    --protocol TCP \
    --port 80 \
    --default-actions Type=forward,TargetGroupArn=$NLB_TARGET_GROUP_ARN

echo "NLB listener created"
```

</details>

<details>
<summary>🔧 3단계: Auto Scaling Group 고급 설정</summary>

### Launch Template 고급 설정
```bash
# 고급 Launch Template 생성
aws ec2 create-launch-template \
    --launch-template-name my-app-advanced-template \
    --version-description "Advanced version with monitoring" \
    --launch-template-data '{
        "ImageId": "ami-0ae2c887094315bed",
        "InstanceType": "t3.small",
        "KeyName": "my-key",
        "SecurityGroupIds": ["'$WEB_SG'"],
        "IamInstanceProfile": {
            "Name": "my-app-instance-profile"
        },
        "UserData": "IyEvYmluL2Jhc2gKeXVtIHVwZGF0ZSAteQp5dW0gaW5zdGFsbCAteSBodHRwZApzeXN0ZW1jdGwgc3RhcnQgaHR0cGQKeW1tIGluc3RhbGwgLXkgZG9ja2VyCnN5c3RlbWN0bCBzdGFydCBkb2NrZXIKZG9ja2VyIHB1bGwgZG9ja2VyL2hlbGxvLXdvcmxkCmRvY2tlciBydW4gLWQgLXAgODA6ODAgZG9ja2VyL2hlbGxvLXdvcmxk",
        "Monitoring": {
            "Enabled": true
        },
        "TagSpecifications": [
            {
                "ResourceType": "instance",
                "Tags": [
                    {"Key": "Name", "Value": "my-app-instance"},
                    {"Key": "Environment", "Value": "production"},
                    {"Key": "AutoScalingGroup", "Value": "my-app-asg"}
                ]
            }
        ]
    }'

echo "Advanced Launch Template created"
```

### Auto Scaling Group 고급 설정
```bash
# Auto Scaling Group 생성
aws autoscaling create-auto-scaling-group \
    --auto-scaling-group-name my-app-advanced-asg \
    --launch-template LaunchTemplateName=my-app-advanced-template,Version=1 \
    --min-size 2 \
    --max-size 20 \
    --desired-capacity 4 \
    --vpc-zone-identifier "$PUBLIC_SUBNET_A,$PUBLIC_SUBNET_C" \
    --health-check-type ELB \
    --health-check-grace-period 300 \
    --target-group-arns $TARGET_GROUP_ARN \
    --termination-policies "OldestInstance" \
    --tag-specifications 'ResourceType=auto-scaling-group,Tags=[{Key=Name,Value=my-app-advanced-asg}]'

echo "Advanced Auto Scaling Group created"
```

### 스케일링 정책 설정
```bash
# CPU 기반 스케일 아웃 정책
aws autoscaling put-scaling-policy \
    --auto-scaling-group-name my-app-advanced-asg \
    --policy-name my-app-cpu-scale-out \
    --policy-type TargetTrackingScaling \
    --target-tracking-scaling-policy-configuration '{
        "TargetValue": 70.0,
        "PredefinedMetricSpecification": {
            "PredefinedMetricType": "ASGAverageCPUUtilization"
        },
        "ScaleOutCooldown": 300,
        "ScaleInCooldown": 300
    }'

# 메모리 기반 스케일 아웃 정책
aws autoscaling put-scaling-policy \
    --auto-scaling-group-name my-app-advanced-asg \
    --policy-name my-app-memory-scale-out \
    --policy-type TargetTrackingScaling \
    --target-tracking-scaling-policy-configuration '{
        "TargetValue": 80.0,
        "PredefinedMetricSpecification": {
            "PredefinedMetricType": "ASGAverageMemoryUtilization"
        },
        "ScaleOutCooldown": 300,
        "ScaleInCooldown": 300
    }'

echo "Scaling policies created"
```

### 커스텀 메트릭 기반 스케일링
```bash
# 커스텀 메트릭 스케일링 정책
aws autoscaling put-scaling-policy \
    --auto-scaling-group-name my-app-advanced-asg \
    --policy-name my-app-custom-scale-out \
    --policy-type TargetTrackingScaling \
    --target-tracking-scaling-policy-configuration '{
        "TargetValue": 100.0,
        "CustomizedMetricSpecification": {
            "MetricName": "RequestCount",
            "Namespace": "MyApp/ECS",
            "Statistic": "Average",
            "Unit": "Count"
        },
        "ScaleOutCooldown": 300,
        "ScaleInCooldown": 300
    }'

echo "Custom metric scaling policy created"
```

</details>

<details>
<summary>🔧 4단계: Health Check 고급 설정</summary>

### HTTP Health Check 설정
```bash
# HTTP Health Check 엔드포인트 설정
aws elbv2 modify-target-group \
    --target-group-arn $TARGET_GROUP_ARN \
    --health-check-path /health \
    --health-check-interval-seconds 15 \
    --health-check-timeout-seconds 5 \
    --healthy-threshold-count 2 \
    --unhealthy-threshold-count 3 \
    --health-check-matcher HTTP_200,HTTP_201

echo "HTTP Health Check configured"
```

### TCP Health Check 설정
```bash
# TCP Health Check 설정
aws elbv2 modify-target-group \
    --target-group-arn $NLB_TARGET_GROUP_ARN \
    --health-check-protocol TCP \
    --health-check-port 80 \
    --health-check-interval-seconds 30 \
    --health-check-timeout-seconds 10 \
    --healthy-threshold-count 2 \
    --unhealthy-threshold-count 3

echo "TCP Health Check configured"
```

### Health Check 모니터링
```bash
# Target Health 상태 확인
aws elbv2 describe-target-health \
    --target-group-arn $TARGET_GROUP_ARN

# Health Check 통계 확인
aws cloudwatch get-metric-statistics \
    --namespace AWS/ApplicationELB \
    --metric-name HealthyHostCount \
    --dimensions Name=TargetGroup,Value=$TARGET_GROUP_ARN \
    --start-time $(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%S) \
    --end-time $(date -u +%Y-%m-%dT%H:%M:%S) \
    --period 300 \
    --statistics Average
```

</details>

---

## ☁️ GCP 고급 로드 밸런싱

<details>
<summary>📖 GCP 로드 밸런싱 타입</summary>

### 로드 밸런싱 타입 비교
| 타입 | 범위 | 특징 | 사용 사례 |
|------|------|------|-----------|
| **HTTP(S) Load Balancer** | Global | Layer 7, CDN | 웹 애플리케이션 |
| **TCP Proxy Load Balancer** | Global | Layer 4, TCP | 데이터베이스 |
| **Network Load Balancer** | Regional | Layer 4, 고성능 | 게임, IoT |
| **Internal Load Balancer** | Regional | 내부 통신 | 마이크로서비스 |

### 로드 밸런싱 전략
- **Round Robin**: 순차적 분산
- **Least Connections**: 연결 수 기반
- **Weighted**: 가중치 기반
- **Geographic**: 지리적 분산

</details>

<details>
<summary>🔧 1단계: HTTP(S) Load Balancer 고급 설정</summary>

### 백엔드 서비스 생성
```bash
# Health Check 생성
gcloud compute health-checks create http my-app-health-check \
    --port=80 \
    --request-path=/health \
    --check-interval=15s \
    --timeout=5s \
    --healthy-threshold=2 \
    --unhealthy-threshold=3

echo "Health Check created"

# 백엔드 서비스 생성
gcloud compute backend-services create my-app-backend \
    --protocol=HTTP \
    --port-name=http \
    --health-checks=my-app-health-check \
    --global \
    --enable-cdn \
    --cache-mode=CACHE_ALL_STATIC \
    --default-ttl=3600

echo "Backend Service created"
```

### 인스턴스 그룹 생성
```bash
# 인스턴스 그룹 생성
gcloud compute instance-groups unmanaged create my-app-group \
    --zone=$GCP_ZONE_1

# 인스턴스 템플릿 생성
gcloud compute instance-templates create my-app-template \
    --machine-type=e2-small \
    --network=my-app-vpc \
    --subnet=my-app-subnet-1 \
    --tags=web-server \
    --image-family=ubuntu-2004-lts \
    --image-project=ubuntu-os-cloud \
    --boot-disk-size=20GB \
    --boot-disk-type=pd-standard \
    --metadata=startup-script='#!/bin/bash
apt-get update
apt-get install -y nginx
systemctl start nginx
echo "Server: $(hostname)" > /var/www/html/index.html
echo "Health: OK" > /var/www/html/health'

echo "Instance template created"

# 인스턴스 생성
gcloud compute instances create my-app-instance-1 \
    --zone=$GCP_ZONE_1 \
    --source-instance-template=my-app-template

gcloud compute instances create my-app-instance-2 \
    --zone=$GCP_ZONE_2 \
    --source-instance-template=my-app-template

echo "Instances created"
```

### 로드 밸런서 구성
```bash
# 인스턴스를 그룹에 추가
gcloud compute instance-groups unmanaged add-instances my-app-group \
    --instances=my-app-instance-1 \
    --zone=$GCP_ZONE_1

# 백엔드 서비스에 인스턴스 그룹 추가
gcloud compute backend-services add-backend my-app-backend \
    --instance-group=my-app-group \
    --instance-group-zone=$GCP_ZONE_1 \
    --global

echo "Backend configured"

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

echo "Load Balancer configured"
```

</details>

<details>
<summary>🔧 2단계: Network Load Balancer 고급 설정</summary>

### Network Load Balancer 생성
```bash
# Network Load Balancer 생성
gcloud compute forwarding-rules create my-app-nlb-rule \
    --region=$GCP_REGION \
    --load-balancing-scheme=EXTERNAL \
    --backend-service=my-app-backend \
    --ports=80

echo "Network Load Balancer created"
```

### 백엔드 서비스 고급 설정
```bash
# 백엔드 서비스 고급 설정
gcloud compute backend-services update my-app-backend \
    --global \
    --connection-draining-timeout=30s \
    --timeout=30s \
    --max-utilization=0.8 \
    --balancing-mode=UTILIZATION

echo "Backend service advanced settings configured"
```

</details>

<details>
<summary>🔧 3단계: Managed Instance Group Auto Scaling</summary>

### Managed Instance Group 생성
```bash
# Managed Instance Group 생성
gcloud compute instance-groups managed create my-app-mig \
    --template=my-app-template \
    --size=3 \
    --zones=$GCP_ZONE_1,$GCP_ZONE_2,$GCP_ZONE_3

echo "Managed Instance Group created"
```

### Auto Scaling 정책 설정
```bash
# Auto Scaling 정책 설정
gcloud compute instance-groups managed set-autoscaling my-app-mig \
    --zone=$GCP_ZONE_1 \
    --max-num-replicas=20 \
    --min-num-replicas=2 \
    --target-cpu-utilization=0.7 \
    --cool-down-period=60s

echo "Auto scaling configured"
```

### 커스텀 메트릭 기반 스케일링
```bash
# 커스텀 메트릭 기반 스케일링
gcloud compute instance-groups managed set-autoscaling my-app-mig \
    --zone=$GCP_ZONE_1 \
    --max-num-replicas=20 \
    --min-num-replicas=2 \
    --custom-metric-utilization metric-type=custom.googleapis.com/request_count,utilization-target=100,utilization-target-type=GAUGE \
    --cool-down-period=60s

echo "Custom metric scaling configured"
```

</details>

---

## 🐳 Kubernetes 로드 밸런싱

<details>
<summary>📖 Kubernetes 로드 밸런싱</summary>

### 로드 밸런싱 타입
- **Service**: ClusterIP, NodePort, LoadBalancer
- **Ingress**: HTTP/HTTPS 라우팅
- **Ingress Controller**: Nginx, Traefik, Istio
- **External Load Balancer**: Cloud Load Balancer

### 로드 밸런싱 전략
- **Round Robin**: 순차적 분산
- **Least Connections**: 연결 수 기반
- **IP Hash**: IP 기반 분산
- **Weighted**: 가중치 기반

</details>

<details>
<summary>🔧 1단계: Service 로드 밸런싱</summary>

### Service 생성
```yaml
# service.yaml
apiVersion: v1
kind: Service
metadata:
  name: my-app-service
  labels:
    app: my-app
spec:
  type: LoadBalancer
  ports:
  - port: 80
    targetPort: 3000
    protocol: TCP
  selector:
    app: my-app
```

### Service 적용
```bash
# Service 생성
kubectl apply -f service.yaml

# Service 상태 확인
kubectl get services

# Service 상세 정보 확인
kubectl describe service my-app-service
```

</details>

<details>
<summary>🔧 2단계: Ingress 고급 설정</summary>

### Ingress 생성
```yaml
# ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: my-app-ingress
  annotations:
    kubernetes.io/ingress.class: "gce"
    kubernetes.io/ingress.global-static-ip-name: "my-app-ip"
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
    nginx.ingress.kubernetes.io/force-ssl-redirect: "true"
    nginx.ingress.kubernetes.io/rate-limit: "100"
    nginx.ingress.kubernetes.io/rate-limit-window: "1m"
    nginx.ingress.kubernetes.io/load-balance: "round_robin"
spec:
  rules:
  - host: my-app.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: my-app-service
            port:
              number: 80
      - path: /api
        pathType: Prefix
        backend:
          service:
            name: my-app-api-service
            port:
              number: 8080
```

### Ingress 적용
```bash
# Ingress 생성
kubectl apply -f ingress.yaml

# Ingress 상태 확인
kubectl get ingress

# Ingress 상세 정보 확인
kubectl describe ingress my-app-ingress
```

</details>

<details>
<summary>🔧 3단계: Horizontal Pod Autoscaler 설정</summary>

### HPA 설정
```yaml
# hpa.yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: my-app-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: my-app-deployment
  minReplicas: 2
  maxReplicas: 20
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: 80
  behavior:
    scaleUp:
      stabilizationWindowSeconds: 60
      policies:
      - type: Percent
        value: 100
        periodSeconds: 15
    scaleDown:
      stabilizationWindowSeconds: 300
      policies:
      - type: Percent
        value: 10
        periodSeconds: 60
```

### HPA 적용 및 테스트
```bash
# HPA 생성
kubectl apply -f hpa.yaml

# HPA 상태 확인
kubectl get hpa

# HPA 상세 정보 확인
kubectl describe hpa my-app-hpa

# CPU 부하 테스트
kubectl run -i --tty load-generator --rm --image=busybox --restart=Never -- /bin/sh

# 부하 테스트 실행
while true; do wget -q -O- http://my-app-service; done
```

</details>

---

## ⚖️ Auto Scaling 고급 설정

<details>
<summary>📖 Auto Scaling 전략</summary>

### 스케일링 메트릭
- **CPU Utilization**: CPU 사용률 기반
- **Memory Utilization**: 메모리 사용률 기반
- **Custom Metrics**: 커스텀 메트릭 기반
- **Scheduled Scaling**: 시간 기반 스케일링

### 스케일링 정책
- **Target Tracking**: 목표 값 추적
- **Step Scaling**: 단계별 스케일링
- **Simple Scaling**: 단순 스케일링
- **Predictive Scaling**: 예측적 스케일링

</details>

<details>
<summary>🔧 1단계: AWS Auto Scaling 고급 설정</summary>

### 예측적 스케일링
```bash
# 예측적 스케일링 정책 생성
aws autoscaling put-scaling-policy \
    --auto-scaling-group-name my-app-advanced-asg \
    --policy-name my-app-predictive-scale-out \
    --policy-type PredictiveScaling \
    --predictive-scaling-configuration '{
        "MetricSpecification": {
            "TargetValue": 70.0,
            "PredefinedMetricSpecification": {
                "PredefinedMetricType": "ASGAverageCPUUtilization"
            }
        },
        "Mode": "ForecastAndScale",
        "SchedulingBufferTime": 10,
        "MaxCapacityBreachBehavior": "HonorMaxCapacity",
        "MaxCapacityBuffer": 10
    }'

echo "Predictive scaling policy created"
```

### 스케일링 정책 조합
```bash
# CPU 기반 스케일 아웃 (빠른 응답)
aws autoscaling put-scaling-policy \
    --auto-scaling-group-name my-app-advanced-asg \
    --policy-name my-app-cpu-scale-out-fast \
    --policy-type StepScaling \
    --adjustment-type PercentChangeInCapacity \
    --scaling-adjustment 50 \
    --cooldown 60 \
    --step-adjustments '[
        {
            "MetricIntervalLowerBound": 0.0,
            "MetricIntervalUpperBound": 10.0,
            "ScalingAdjustment": 20
        },
        {
            "MetricIntervalLowerBound": 10.0,
            "MetricIntervalUpperBound": 20.0,
            "ScalingAdjustment": 50
        },
        {
            "MetricIntervalLowerBound": 20.0,
            "ScalingAdjustment": 100
        }
    ]'

echo "Step scaling policy created"
```

### 스케일링 알림 설정
```bash
# SNS 토픽 생성
SNS_TOPIC_ARN=$(aws sns create-topic \
    --name my-app-scaling-alerts \
    --query 'TopicArn' \
    --output text)

echo "SNS Topic ARN: $SNS_TOPIC_ARN"

# CloudWatch 알람 생성 (스케일 아웃)
aws cloudwatch put-metric-alarm \
    --alarm-name "High CPU Utilization" \
    --alarm-description "Alarm when CPU exceeds 80%" \
    --metric-name CPUUtilization \
    --namespace AWS/EC2 \
    --statistic Average \
    --period 300 \
    --threshold 80.0 \
    --comparison-operator GreaterThanThreshold \
    --evaluation-periods 2 \
    --alarm-actions $SNS_TOPIC_ARN

# CloudWatch 알람 생성 (스케일 인)
aws cloudwatch put-metric-alarm \
    --alarm-name "Low CPU Utilization" \
    --alarm-description "Alarm when CPU below 20%" \
    --metric-name CPUUtilization \
    --namespace AWS/EC2 \
    --statistic Average \
    --period 300 \
    --threshold 20.0 \
    --comparison-operator LessThanThreshold \
    --evaluation-periods 2 \
    --alarm-actions $SNS_TOPIC_ARN

echo "Scaling alarms created"
```

</details>

<details>
<summary>🔧 2단계: GCP Auto Scaling 고급 설정</summary>

### 커스텀 메트릭 기반 스케일링
```bash
# 커스텀 메트릭 기반 스케일링
gcloud compute instance-groups managed set-autoscaling my-app-mig \
    --zone=$GCP_ZONE_1 \
    --max-num-replicas=20 \
    --min-num-replicas=2 \
    --custom-metric-utilization metric-type=custom.googleapis.com/request_count,utilization-target=100,utilization-target-type=GAUGE \
    --cool-down-period=60s

echo "Custom metric scaling configured"
```

### 스케일링 정책 설정
```bash
# 스케일링 정책 설정
gcloud compute instance-groups managed set-autoscaling my-app-mig \
    --zone=$GCP_ZONE_1 \
    --max-num-replicas=20 \
    --min-num-replicas=2 \
    --target-cpu-utilization=0.7 \
    --cool-down-period=60s \
    --scale-down-control max-scaled-down-replicas=1,time-window=300s

echo "Scaling policy configured"
```

</details>

<details>
<summary>🔧 3단계: Kubernetes HPA 고급 설정</summary>

### 커스텀 메트릭 HPA
```yaml
# custom-hpa.yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: my-app-custom-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: my-app-deployment
  minReplicas: 2
  maxReplicas: 20
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
  - type: Pods
    pods:
      metric:
        name: requests_per_second
      target:
        type: AverageValue
        averageValue: "100"
  behavior:
    scaleUp:
      stabilizationWindowSeconds: 60
      policies:
      - type: Percent
        value: 100
        periodSeconds: 15
      - type: Pods
        value: 4
        periodSeconds: 15
      selectPolicy: Max
    scaleDown:
      stabilizationWindowSeconds: 300
      policies:
      - type: Percent
        value: 10
        periodSeconds: 60
      selectPolicy: Min
```

### HPA 적용
```bash
# 커스텀 HPA 생성
kubectl apply -f custom-hpa.yaml

# HPA 상태 확인
kubectl get hpa

# HPA 이벤트 확인
kubectl get events --sort-by=.metadata.creationTimestamp
```

</details>

---

## 📚 문제 해결 및 참고 자료

<details>
<summary>🐛 자주 발생하는 문제</summary>

### 로드 밸런싱 관련 문제
<details>
<summary>❌ ALB 502 Bad Gateway 오류</summary>

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
<summary>❌ Auto Scaling 작동 안함</summary>

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
    --start-time $(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%S) \
    --end-time $(date -u +%Y-%m-%dT%H:%M:%S) \
    --period 300 \
    --statistics Average
```

</details>

### Kubernetes 관련 문제
<details>
<summary>❌ HPA 스케일링 안됨</summary>

**원인**:
- 메트릭 서버 설치 안됨
- 리소스 요청/제한 설정 안됨
- 권한 문제

**해결방법**:
```bash
# 1. 메트릭 서버 설치 확인
kubectl get pods -n kube-system | grep metrics-server

# 2. HPA 상태 확인
kubectl describe hpa my-app-hpa

# 3. 리소스 설정 확인
kubectl describe deployment my-app-deployment
```

</details>

</details>

<details>
<summary>📖 추가 학습 자료</summary>

### 공식 문서
- [AWS Application Load Balancer](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/)
- [AWS Network Load Balancer](https://docs.aws.amazon.com/elasticloadbalancing/latest/network/)
- [GCP Cloud Load Balancing](https://cloud.google.com/load-balancing/docs)
- [Kubernetes Service](https://kubernetes.io/docs/concepts/services-networking/service/)
- [Kubernetes Ingress](https://kubernetes.io/docs/concepts/services-networking/ingress/)

### 유용한 리소스
- [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)
- [GCP Architecture Center](https://cloud.google.com/architecture)
- [Kubernetes 샘플 프로젝트](https://github.com/kubernetes/examples)

</details>

---

## 🎉 완료!

축하합니다! 로드 밸런싱 고급 실습을 완료했습니다.

### 📚 학습 요약

이번 실습을 통해 다음을 배웠습니다:

1. **☁️ AWS 고급 로드 밸런싱**: ALB, NLB 고급 설정
2. **☁️ GCP 고급 로드 밸런싱**: HTTP(S), Network Load Balancer
3. **🐳 Kubernetes 로드 밸런싱**: Service, Ingress, HPA
4. **⚖️ Auto Scaling 고급 설정**: 다양한 메트릭 기반 스케일링

### 🚀 다음 단계

- **모니터링 시스템 구축**: [모니터링 시스템 구축](./monitoring-system-setup.md)
- **종합 프로젝트**: [종합 프로젝트 실습](./comprehensive-project.md)
- **성능 최적화**: [성능 최적화 실습](./performance-optimization.md)

### 💡 추가 학습 자료

- [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)
- [GCP Architecture Center](https://cloud.google.com/architecture)
- [전체 커리큘럼](../../../../curriculum.md)

---

**🎯 이제 고급 로드 밸런싱의 모든 기본기를 갖추었습니다! 실제 프로젝트에 적용해보세요.**
