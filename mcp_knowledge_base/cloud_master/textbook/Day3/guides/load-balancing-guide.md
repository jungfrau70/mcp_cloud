# 로드 밸런싱 가이드


---

## 🎯 학습 목표

### 핵심 학습 목표
- **AWS ELB 구성**: Application Load Balancer, Network Load Balancer 설정
- **GCP Cloud Load Balancing**: HTTP[S] Load Balancing, TCP/UDP Load Balancing
- **로드 밸런싱 알고리즘**: Round Robin, Least Connections, IP Hash 이해
- **고가용성 구성**: Multi-AZ, Multi-Region 로드 밸런싱

### 실습 후 달성할 수 있는 능력
- ✅ AWS ELB를 통한 웹 애플리케이션 로드 밸런싱 구성
- ✅ GCP Cloud Load Balancing을 통한 글로벌 로드 밸런싱 설정
- ✅ 로드 밸런싱 알고리즘 선택 및 최적화
- ✅ 고가용성 웹 애플리케이션 아키텍처 구축

---

## 📚 이론 학습

### AWS Elastic Load Balancer [ELB]

#### Application Load Balancer [ALB]
- **7계층 로드 밸런싱**: HTTP/HTTPS 트래픽 처리
- **Path-based Routing**: URL 경로 기반 라우팅
- **Host-based Routing**: 도메인 기반 라우팅
- **Target Groups**: 다양한 타겟 그룹 지원

#### Network Load Balancer [NLB]
- **4계층 로드 밸런싱**: TCP/UDP 트래픽 처리
- **고성능**: 초당 수백만 요청 처리
- **정적 IP**: 고정 IP 주소 제공
- **Ultra-low Latency**: 극저지연 시간

### GCP Cloud Load Balancing

#### HTTP[S] Load Balancing
- **글로벌 로드 밸런싱**: 전 세계 엣지 로케이션 활용
- **SSL 종료**: SSL 인증서 관리
- **CDN 통합**: Cloud CDN과 통합
- **Auto Scaling**: 자동 확장 지원

#### TCP/UDP Load Balancing
- **지역 로드 밸런싱**: 특정 리전 내 로드 밸런싱
- **고성능**: 높은 처리량과 낮은 지연시간
- **Health Check**: 타겟 상태 모니터링

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

### AWS ELB 실습

#### 1단계: VPC 및 서브넷 생성
```bash
# VPC 생성
VPC_ID=$[aws ec2 create-vpc --cidr-block 10.0.0.0/16 --query 'Vpc.VpcId' --output text]
aws ec2 create-tags --resources $VPC_ID --tags Key=Name,Value=load-balancer-vpc

# 서브넷 생성 [Multi-AZ]
SUBNET_1=$[aws ec2 create-subnet --vpc-id $VPC_ID --cidr-block 10.0.1.0/24 --availability-zone ap-northeast-2a --query 'Subnet.SubnetId' --output text]
SUBNET_2=$[aws ec2 create-subnet --vpc-id $VPC_ID --cidr-block 10.0.2.0/24 --availability-zone ap-northeast-2c --query 'Subnet.SubnetId' --output text]

# 인터넷 게이트웨이 생성
IGW_ID=$[aws ec2 create-internet-gateway --query 'InternetGateway.InternetGatewayId' --output text]
aws ec2 attach-internet-gateway --vpc-id $VPC_ID --internet-gateway-id $IGW_ID
```

#### 2단계: 보안 그룹 생성
```bash
# ALB 보안 그룹
ALB_SG=$[aws ec2 create-security-group --group-name alb-sg --description "ALB Security Group" --vpc-id $VPC_ID --query 'GroupId' --output text]
aws ec2 authorize-security-group-ingress --group-id $ALB_SG --protocol tcp --port 80 --cidr 0.0.0.0/0
aws ec2 authorize-security-group-ingress --group-id $ALB_SG --protocol tcp --port 443 --cidr 0.0.0.0/0

# EC2 보안 그룹
EC2_SG=$[aws ec2 create-security-group --group-name ec2-sg --description "EC2 Security Group" --vpc-id $VPC_ID --query 'GroupId' --output text]
aws ec2 authorize-security-group-ingress --group-id $EC2_SG --protocol tcp --port 80 --source-group $ALB_SG
aws ec2 authorize-security-group-ingress --group-id $EC2_SG --protocol tcp --port 22 --cidr 0.0.0.0/0
```

#### 3단계: EC2 인스턴스 생성
```bash
# 키 페어 생성
aws ec2 create-key-pair --key-name load-balancer-key --query 'KeyMaterial' --output text > load-balancer-key.pem
chmod 400 load-balancer-key.pem

# EC2 인스턴스 생성 ["2개"]
INSTANCE_1=$[aws ec2 run-instances --image-id ami-0c76973fbe0ee100c --count 1 --instance-type t2.micro --key-name load-balancer-key --security-group-ids $EC2_SG --subnet-id $SUBNET_1 --user-data file://user-data.sh --query 'Instances[0].InstanceId' --output text]

INSTANCE_2=$[aws ec2 run-instances --image-id ami-0c76973fbe0ee100c --count 1 --instance-type t2.micro --key-name load-balancer-key --security-group-ids $EC2_SG --subnet-id $SUBNET_2 --user-data file://user-data.sh --query 'Instances[0].InstanceId' --output text]
```

#### 4단계: Application Load Balancer 생성
```bash
# Target Group 생성
TARGET_GROUP_ARN=$[aws elbv2 create-target-group --name my-targets --protocol HTTP --port 80 --vpc-id $VPC_ID --query 'TargetGroups[0].TargetGroupArn' --output text]

# ALB 생성
ALB_ARN=$[aws elbv2 create-load-balancer --name my-load-balancer --subnets $SUBNET_1 $SUBNET_2 --security-groups $ALB_SG --query 'LoadBalancers[0].LoadBalancerArn' --output text]

# 타겟 등록
aws elbv2 register-targets --target-group-arn $TARGET_GROUP_ARN --targets Id=$INSTANCE_1 Id=$INSTANCE_2

# 리스너 생성
aws elbv2 create-listener --load-balancer-arn $ALB_ARN --protocol HTTP --port 80 --default-actions Type=forward,TargetGroupArn=$TARGET_GROUP_ARN
```

### GCP Cloud Load Balancing 실습

#### 1단계: 인스턴스 템플릿 생성
```bash
# 인스턴스 템플릿 생성
gcloud compute instance-templates create web-server-template /
    --image-family=ubuntu-2004-lts /
    --image-project=ubuntu-os-cloud /
    --machine-type=e2-micro /
    --tags=web-server /
    --metadata=startup-script='#!/bin/bash
apt-get update
apt-get install -y nginx
echo "Hello from $[hostname]" > /var/www/html/index.html
systemctl restart nginx'
```

#### 2단계: Managed Instance Group 생성
```bash
# Managed Instance Group 생성
gcloud compute instance-groups managed create web-server-group /
    --template=web-server-template /
    --size=2 /
    --zone=asia-northeast3-a

# 인스턴스 그룹에 인스턴스 추가
gcloud compute instance-groups managed set-named-ports web-server-group /
    --named-ports=http:80 /
    --zone=asia-northeast3-a
```

#### 3단계: Health Check 생성
```bash
# Health Check 생성
gcloud compute health-checks create http web-health-check /
    --port=80 /
    --request-path=/
```

#### 4단계: Backend Service 생성
```bash
# Backend Service 생성
gcloud compute backend-services create web-backend-service /
    --protocol=HTTP /
    --health-checks=web-health-check /
    --global

# Backend Service에 인스턴스 그룹 추가
gcloud compute backend-services add-backend web-backend-service /
    --instance-group=web-server-group /
    --instance-group-zone=asia-northeast3-a /
    --global
```

#### 5단계: URL Map 및 Target Proxy 생성
```bash
# URL Map 생성
gcloud compute url-maps create web-map /
    --default-service=web-backend-service

# Target HTTP Proxy 생성
gcloud compute target-http-proxies create web-proxy /
    --url-map=web-map

# Forwarding Rule 생성
gcloud compute forwarding-rules create web-rule /
    --global /
    --target-http-proxy=web-proxy /
    --ports=80
```

---

## 🔧 고급 설정

### SSL/TLS 종료
```bash
# SSL 인증서 생성 [AWS]
aws acm request-certificate --domain-name example.com --validation-method DNS

# SSL 인증서 생성 [GCP]
gcloud compute ssl-certificates create web-ssl-cert /
    --domains=example.com
```

### 로드 밸런싱 알고리즘 설정
```bash
# AWS: Target Group 설정
aws elbv2 modify-target-group-attributes /
    --target-group-arn $TARGET_GROUP_ARN /
    --attributes Key=deregistration_delay.timeout_seconds,Value=30

# GCP: Backend Service 설정
gcloud compute backend-services update web-backend-service /
    --balancing-mode=UTILIZATION /
    --max-utilization=0.8 /
    --global
```

---

## 📊 모니터링 및 테스트

### 로드 밸런서 상태 확인
```bash
# AWS ALB 상태 확인
aws elbv2 describe-load-balancers --load-balancer-arns $ALB_ARN
aws elbv2 describe-target-health --target-group-arn $TARGET_GROUP_ARN

# GCP Load Balancer 상태 확인
gcloud compute forwarding-rules describe web-rule --global
gcloud compute backend-services get-health web-backend-service --global
```

### 부하 테스트
```bash
# Apache Bench를 사용한 부하 테스트
ab -n 1000 -c 10 http://your-load-balancer-dns/

# curl을 사용한 연속 요청
for i in {1..10}; do
  curl http://your-load-balancer-dns/
  sleep 1
done
```

---

## 🚨 문제 해결

### 일반적인 문제

#### 1. Health Check 실패
- **원인**: 보안 그룹 설정, 포트 설정 문제
- **해결방법**: 
  ```bash
  # 보안 그룹 규칙 확인
  aws ec2 describe-security-groups --group-ids $EC2_SG
  
  # Health Check 설정 확인
  aws elbv2 describe-target-groups --target-group-arns $TARGET_GROUP_ARN
  ```

#### 2. 타겟 등록 실패
- **원인**: 인스턴스 상태, 네트워크 설정 문제
- **해결방법**:
  ```bash
  # 인스턴스 상태 확인
  aws ec2 describe-instances --instance-ids $INSTANCE_1 $INSTANCE_2
  
  # 타겟 상태 확인
  aws elbv2 describe-target-health --target-group-arn $TARGET_GROUP_ARN
  ```

#### 3. 로드 밸런서 접근 불가
- **원인**: 라우팅 테이블, 인터넷 게이트웨이 설정 문제
- **해결방법**:
  ```bash
  # 라우팅 테이블 확인
  aws ec2 describe-route-tables --filters "Name=vpc-id,Values=$VPC_ID"
  
  # 인터넷 게이트웨이 확인
  aws ec2 describe-internet-gateways --internet-gateway-ids $IGW_ID
  ```

---

## 📚 참고 자료

### AWS 공식 문서
- ["Application Load Balancer 가이드"][https:///docs.aws.amazon.com/elasticloadbalancing/latest/application/]
- ["Network Load Balancer 가이드"][https:///docs.aws.amazon.com/elasticloadbalancing/latest/network/]

### GCP 공식 문서
- ["Cloud Load Balancing 가이드"][https:///cloud.google.com/load-balancing/docs]
- [HTTP[S] Load Balancing 가이드][https:///cloud.google.com/load-balancing/docs/https]

### 추가 학습 자료
- ["로드 밸런싱 알고리즘 비교"][https:///www.nginx.com/resources/glossary/load-balancing/]
- ["고가용성 아키텍처 설계"][https:///aws.amazon.com/architecture/well-architected/]

---



<div align="center">

["← 이전: Cloud Master 3일차 메인"](README.md) | ["📚 전체 커리큘럼"](curriculum.md) | ["🏠 학습 경로로 돌아가기"](index.md)

</div>