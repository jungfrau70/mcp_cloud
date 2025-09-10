# 고가용성 아키텍처 실습

<details>
<summary>📋 목차</summary>

1. [🎯 학습 목표](#-학습-목표)
2. [📚 실습 개요](#-실습-개요)
3. [🔧 실습 환경 준비](#-실습-환경-준비)
4. [☁️ AWS Multi-AZ 구성](#-aws-multi-az-구성)
5. [☁️ GCP Multi-Region 구성](#-gcp-multi-region-구성)
6. [🐳 Kubernetes 고가용성 설정](#-kubernetes-고가용성-설정)
7. [🗄️ 데이터베이스 고가용성](#️-데이터베이스-고가용성)
8. [📚 문제 해결 및 참고 자료](#-문제-해결-및-참고-자료)

</details>

---

## 🎯 학습 목표

<details>
<summary>📖 이번 실습에서 배우게 될 내용</summary>

### 핵심 학습 목표
- **Multi-AZ 구성** AWS, GCP에서 고가용성 아키텍처 구현
- **Multi-Region 구성** 재해 복구를 위한 크로스 리전 설정
- **Kubernetes 고가용성** Pod Anti-Affinity, HPA 설정
- **데이터베이스 고가용성** RDS, Cloud SQL 복제 설정

### 실습 후 달성할 수 있는 능력
- ✅ Multi-AZ/Multi-Region 아키텍처 구성
- ✅ Kubernetes 고가용성 설정
- ✅ 데이터베이스 복제 및 백업 설정
- ✅ 장애 복구 시나리오 테스트

### 예상 소요 시간
- **AWS Multi-AZ**: 60-90분
- **GCP Multi-Region**: 60-90분
- **Kubernetes 고가용성**: 60-90분
- **데이터베이스 고가용성**: 60-90분
- **전체 과정**: 4-6시간

</details>

---

## 📚 실습 개요

<details>
<summary>📖 실습 시나리오</summary>

### 프로젝트 개요
**E-commerce 웹 애플리케이션**의 고가용성 아키텍처를 구성합니다.

### 아키텍처 요구사항
- **가용성**: 99.9% 이상
- **복구 시간**: 5분 이내
- **데이터 보호**: 자동 백업 및 복제
- **확장성**: 트래픽 증가에 따른 자동 확장

### 구현할 구성 요소
1. **웹 서버**: Multi-AZ 배포
2. **데이터베이스**: Multi-AZ 복제
3. **로드 밸런서**: 고가용성 구성
4. **모니터링**: 실시간 상태 확인

</details>

---

## 🔧 실습 환경 준비

<details>
<summary>📋 필수 도구 및 계정</summary>

### 필수 계정
- **AWS 계정**: Free Tier (Multi-AZ 실습용)
- **GCP 계정**: $300 크레딧 (Multi-Region 실습용)
- **Docker Hub**: 컨테이너 이미지 저장소

### 필수 도구
```bash
# AWS CLI 설치 및 설정
aws --version
aws configure

# GCP CLI 설치 및 설정
gcloud --version
gcloud auth login

# kubectl 설치
kubectl version --client

# Docker 설치
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
export GCP_REGION_1=asia-northeast3
export GCP_REGION_2=asia-northeast1
```

</details>

---

## ☁️ AWS Multi-AZ 구성

<details>
<summary>📖 AWS Multi-AZ 아키텍처</summary>

### 구성 요소
- **VPC**: 가상 네트워크
- **Subnet**: Multi-AZ 서브넷
- **Security Group**: 보안 그룹
- **RDS**: Multi-AZ 데이터베이스
- **Auto Scaling Group**: Multi-AZ 인스턴스

### 아키텍처 다이어그램
```
Internet Gateway
        ↓
Application Load Balancer
        ↓
┌─────────────────────────────────────┐
│  Auto Scaling Group (Multi-AZ)     │
│  ┌─────────────┐ ┌─────────────┐   │
│  │   EC2 AZ-a  │ │   EC2 AZ-c  │   │
│  │   (Web)     │ │   (Web)     │   │
│  └─────────────┘ └─────────────┘   │
└─────────────────────────────────────┘
        ↓
┌─────────────────────────────────────┐
│  RDS Multi-AZ (Primary + Standby)  │
└─────────────────────────────────────┘
```

</details>

<details>
<summary>🔧 1단계: VPC 및 서브넷 구성</summary>

### VPC 생성
```bash
# VPC 생성
VPC_ID=$(aws ec2 create-vpc \
    --cidr-block 10.0.0.0/16 \
    --tag-specifications 'ResourceType=vpc,Tags=[{Key=Name,Value=my-app-vpc}]' \
    --query 'Vpc.VpcId' \
    --output text)

echo "VPC ID: $VPC_ID"

# Internet Gateway 생성 및 연결
IGW_ID=$(aws ec2 create-internet-gateway \
    --tag-specifications 'ResourceType=internet-gateway,Tags=[{Key=Name,Value=my-app-igw}]' \
    --query 'InternetGateway.InternetGatewayId' \
    --output text)

aws ec2 attach-internet-gateway \
    --vpc-id $VPC_ID \
    --internet-gateway-id $IGW_ID

echo "Internet Gateway ID: $IGW_ID"
```

### Multi-AZ 서브넷 생성
```bash
# Public Subnet AZ-a
PUBLIC_SUBNET_A=$(aws ec2 create-subnet \
    --vpc-id $VPC_ID \
    --cidr-block 10.0.1.0/24 \
    --availability-zone ap-northeast-2a \
    --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=my-app-public-subnet-a}]' \
    --query 'Subnet.SubnetId' \
    --output text)

# Public Subnet AZ-c
PUBLIC_SUBNET_C=$(aws ec2 create-subnet \
    --vpc-id $VPC_ID \
    --cidr-block 10.0.2.0/24 \
    --availability-zone ap-northeast-2c \
    --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=my-app-public-subnet-c}]' \
    --query 'Subnet.SubnetId' \
    --output text)

# Private Subnet AZ-a
PRIVATE_SUBNET_A=$(aws ec2 create-subnet \
    --vpc-id $VPC_ID \
    --cidr-block 10.0.11.0/24 \
    --availability-zone ap-northeast-2a \
    --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=my-app-private-subnet-a}]' \
    --query 'Subnet.SubnetId' \
    --output text)

# Private Subnet AZ-c
PRIVATE_SUBNET_C=$(aws ec2 create-subnet \
    --vpc-id $VPC_ID \
    --cidr-block 10.0.12.0/24 \
    --availability-zone ap-northeast-2c \
    --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=my-app-private-subnet-c}]' \
    --query 'Subnet.SubnetId' \
    --output text)

echo "Public Subnet A: $PUBLIC_SUBNET_A"
echo "Public Subnet C: $PUBLIC_SUBNET_C"
echo "Private Subnet A: $PRIVATE_SUBNET_A"
echo "Private Subnet C: $PRIVATE_SUBNET_C"
```

### 라우팅 테이블 설정
```bash
# Public Route Table
PUBLIC_RT=$(aws ec2 create-route-table \
    --vpc-id $VPC_ID \
    --tag-specifications 'ResourceType=route-table,Tags=[{Key=Name,Value=my-app-public-rt}]' \
    --query 'RouteTable.RouteTableId' \
    --output text)

# Internet Gateway 라우트 추가
aws ec2 create-route \
    --route-table-id $PUBLIC_RT \
    --destination-cidr-block 0.0.0.0/0 \
    --gateway-id $IGW_ID

# Public 서브넷을 Public Route Table에 연결
aws ec2 associate-route-table \
    --subnet-id $PUBLIC_SUBNET_A \
    --route-table-id $PUBLIC_RT

aws ec2 associate-route-table \
    --subnet-id $PUBLIC_SUBNET_C \
    --route-table-id $PUBLIC_RT

echo "Public Route Table: $PUBLIC_RT"
```

</details>

<details>
<summary>🔧 2단계: 보안 그룹 구성</summary>

### 보안 그룹 생성
```bash
# Web Security Group
WEB_SG=$(aws ec2 create-security-group \
    --group-name my-app-web-sg \
    --description "Security group for web servers" \
    --vpc-id $VPC_ID \
    --query 'GroupId' \
    --output text)

# Database Security Group
DB_SG=$(aws ec2 create-security-group \
    --group-name my-app-db-sg \
    --description "Security group for database" \
    --vpc-id $VPC_ID \
    --query 'GroupId' \
    --output text)

echo "Web Security Group: $WEB_SG"
echo "Database Security Group: $DB_SG"
```

### 보안 그룹 규칙 설정
```bash
# Web Security Group 규칙
aws ec2 authorize-security-group-ingress \
    --group-id $WEB_SG \
    --protocol tcp \
    --port 80 \
    --cidr 0.0.0.0/0

aws ec2 authorize-security-group-ingress \
    --group-id $WEB_SG \
    --protocol tcp \
    --port 443 \
    --cidr 0.0.0.0/0

aws ec2 authorize-security-group-ingress \
    --group-id $WEB_SG \
    --protocol tcp \
    --port 22 \
    --cidr 0.0.0.0/0

# Database Security Group 규칙
aws ec2 authorize-security-group-ingress \
    --group-id $DB_SG \
    --protocol tcp \
    --port 3306 \
    --source-group $WEB_SG

echo "Security group rules configured"
```

</details>

<details>
<summary>🔧 3단계: RDS Multi-AZ 구성</summary>

### RDS 서브넷 그룹 생성
```bash
# DB Subnet Group 생성
aws rds create-db-subnet-group \
    --db-subnet-group-name my-app-db-subnet-group \
    --db-subnet-group-description "Subnet group for RDS Multi-AZ" \
    --subnet-ids $PRIVATE_SUBNET_A $PRIVATE_SUBNET_C

echo "DB Subnet Group created"
```

### RDS Multi-AZ 인스턴스 생성
```bash
# RDS Multi-AZ 인스턴스 생성
aws rds create-db-instance \
    --db-instance-identifier my-app-db \
    --db-instance-class db.t3.micro \
    --engine mysql \
    --engine-version 8.0.35 \
    --master-username admin \
    --master-user-password MyPassword123! \
    --allocated-storage 20 \
    --storage-type gp2 \
    --db-subnet-group-name my-app-db-subnet-group \
    --vpc-security-group-ids $DB_SG \
    --multi-az \
    --backup-retention-period 7 \
    --preferred-backup-window "03:00-04:00" \
    --preferred-maintenance-window "sun:04:00-sun:05:00" \
    --storage-encrypted \
    --deletion-protection

echo "RDS Multi-AZ instance creating..."
```

### RDS 상태 확인
```bash
# RDS 인스턴스 상태 확인
aws rds describe-db-instances \
    --db-instance-identifier my-app-db \
    --query 'DBInstances[0].{Status:DBInstanceStatus,MultiAZ:MultiAZ,Endpoint:Endpoint.Address}'

# Multi-AZ 상태 확인
aws rds describe-db-instances \
    --db-instance-identifier my-app-db \
    --query 'DBInstances[0].MultiAZ'
```

</details>

<details>
<summary>🔧 4단계: Auto Scaling Group Multi-AZ 구성</summary>

### Launch Template 생성
```bash
# Launch Template 생성
aws ec2 create-launch-template \
    --launch-template-name my-app-template \
    --version-description "Initial version" \
    --launch-template-data '{
        "ImageId": "ami-0ae2c887094315bed",
        "InstanceType": "t3.micro",
        "KeyName": "my-key",
        "SecurityGroupIds": ["'$WEB_SG'"],
        "UserData": "IyEvYmluL2Jhc2gKeXVtIHVwZGF0ZSAteQp5dW0gaW5zdGFsbCAteSBodHRwZApzeXN0ZW1jdGwgc3RhcnQgaHR0cGQKeW1tIGluc3RhbGwgLXkgZG9ja2VyCnN5c3RlbWN0bCBzdGFydCBkb2NrZXIKZG9ja2VyIHB1bGwgZG9ja2VyL2hlbGxvLXdvcmxkCmRvY2tlciBydW4gLWQgLXAgODA6ODAgZG9ja2VyL2hlbGxvLXdvcmxk"
    }'

echo "Launch Template created"
```

### Auto Scaling Group 생성
```bash
# Auto Scaling Group 생성
aws autoscaling create-auto-scaling-group \
    --auto-scaling-group-name my-app-asg \
    --launch-template LaunchTemplateName=my-app-template,Version=1 \
    --min-size 2 \
    --max-size 10 \
    --desired-capacity 4 \
    --vpc-zone-identifier "$PUBLIC_SUBNET_A,$PUBLIC_SUBNET_C" \
    --health-check-type ELB \
    --health-check-grace-period 300 \
    --tag-specifications 'ResourceType=auto-scaling-group,Tags=[{Key=Name,Value=my-app-asg}]'

echo "Auto Scaling Group created"
```

### Auto Scaling Group 상태 확인
```bash
# Auto Scaling Group 상태 확인
aws autoscaling describe-auto-scaling-groups \
    --auto-scaling-group-names my-app-asg \
    --query 'AutoScalingGroups[0].{DesiredCapacity:DesiredCapacity,MinSize:MinSize,MaxSize:MaxSize,AvailabilityZones:AvailabilityZones}'

# 인스턴스 분산 확인
aws autoscaling describe-auto-scaling-groups \
    --auto-scaling-group-names my-app-asg \
    --query 'AutoScalingGroups[0].Instances[].{InstanceId:InstanceId,AvailabilityZone:AvailabilityZone,HealthStatus:HealthStatus}'
```

</details>

---

## ☁️ GCP Multi-Region 구성

<details>
<summary>📖 GCP Multi-Region 아키텍처</summary>

### 구성 요소
- **VPC Network**: 글로벌 네트워크
- **Subnet**: 리전별 서브넷
- **Firewall Rules**: 방화벽 규칙
- **Cloud SQL**: Multi-Region 데이터베이스
- **Managed Instance Group**: Multi-Zone 인스턴스

### 아키텍처 다이어그램
```
Internet
    ↓
Global Load Balancer
    ↓
┌─────────────────────────────────────────────────────────┐
│  Managed Instance Group (Multi-Zone)                  │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐      │
│  │   VM Zone-a │ │   VM Zone-b │ │   VM Zone-c │      │
│  │   (Web)     │ │   (Web)     │ │   (Web)     │      │
│  └─────────────┘ └─────────────┘ └─────────────┘      │
└─────────────────────────────────────────────────────────┘
    ↓
┌─────────────────────────────────────────────────────────┐
│  Cloud SQL (Primary + Read Replica)                   │
└─────────────────────────────────────────────────────────┘
```

</details>

<details>
<summary>🔧 1단계: VPC 및 서브넷 구성</summary>

### VPC Network 생성
```bash
# VPC Network 생성
gcloud compute networks create my-app-vpc \
    --subnet-mode=regional \
    --bgp-routing-mode=global

# 서브넷 생성 (Region 1)
gcloud compute networks subnets create my-app-subnet-1 \
    --network=my-app-vpc \
    --range=10.0.1.0/24 \
    --region=asia-northeast3

# 서브넷 생성 (Region 2)
gcloud compute networks subnets create my-app-subnet-2 \
    --network=my-app-vpc \
    --range=10.0.2.0/24 \
    --region=asia-northeast1

echo "VPC and subnets created"
```

### 방화벽 규칙 설정
```bash
# HTTP 방화벽 규칙
gcloud compute firewall-rules create my-app-http \
    --network=my-app-vpc \
    --allow=tcp:80 \
    --source-ranges=0.0.0.0/0 \
    --target-tags=web-server

# HTTPS 방화벽 규칙
gcloud compute firewall-rules create my-app-https \
    --network=my-app-vpc \
    --allow=tcp:443 \
    --source-ranges=0.0.0.0/0 \
    --target-tags=web-server

# SSH 방화벽 규칙
gcloud compute firewall-rules create my-app-ssh \
    --network=my-app-vpc \
    --allow=tcp:22 \
    --source-ranges=0.0.0.0/0 \
    --target-tags=web-server

echo "Firewall rules created"
```

</details>

<details>
<summary>🔧 2단계: Cloud SQL Multi-Region 구성</summary>

### Cloud SQL 인스턴스 생성
```bash
# Cloud SQL 인스턴스 생성 (Primary)
gcloud sql instances create my-app-sql-primary \
    --database-version=MYSQL_8_0 \
    --tier=db-f1-micro \
    --region=asia-northeast3 \
    --availability-type=REGIONAL \
    --storage-type=SSD \
    --storage-size=10GB \
    --backup-start-time=03:00 \
    --enable-bin-log \
    --root-password=MyPassword123!

echo "Cloud SQL primary instance creating..."
```

### 읽기 복제본 생성
```bash
# 읽기 복제본 생성 (다른 리전)
gcloud sql instances create my-app-sql-replica \
    --master-instance-name=my-app-sql-primary \
    --region=asia-northeast1

echo "Cloud SQL read replica creating..."
```

### 데이터베이스 생성
```bash
# 데이터베이스 생성
gcloud sql databases create myapp \
    --instance=my-app-sql-primary

# 사용자 생성
gcloud sql users create myapp-user \
    --instance=my-app-sql-primary \
    --password=MyPassword123!

echo "Database and user created"
```

</details>

<details>
<summary>🔧 3단계: Managed Instance Group Multi-Zone 구성</summary>

### 인스턴스 템플릿 생성
```bash
# 인스턴스 템플릿 생성
gcloud compute instance-templates create my-app-template \
    --machine-type=e2-micro \
    --network=my-app-vpc \
    --subnet=my-app-subnet-1 \
    --tags=web-server \
    --image-family=ubuntu-2004-lts \
    --image-project=ubuntu-os-cloud \
    --boot-disk-size=10GB \
    --boot-disk-type=pd-standard \
    --metadata=startup-script='#!/bin/bash
apt-get update
apt-get install -y docker.io
systemctl start docker
docker pull nginx
docker run -d -p 80:80 nginx'

echo "Instance template created"
```

### Managed Instance Group 생성
```bash
# Managed Instance Group 생성 (Multi-Zone)
gcloud compute instance-groups managed create my-app-mig \
    --template=my-app-template \
    --size=3 \
    --zones=asia-northeast3-a,asia-northeast3-b,asia-northeast3-c

echo "Managed Instance Group created"
```

### Auto Scaling 설정
```bash
# Auto Scaling 정책 설정
gcloud compute instance-groups managed set-autoscaling my-app-mig \
    --zone=asia-northeast3-a \
    --max-num-replicas=10 \
    --min-num-replicas=2 \
    --target-cpu-utilization=0.7

echo "Auto scaling configured"
```

</details>

---

## 🐳 Kubernetes 고가용성 설정

<details>
<summary>📖 Kubernetes 고가용성 개념</summary>

### 고가용성 구성 요소
- **Pod Anti-Affinity**: Pod 분산 배치
- **Horizontal Pod Autoscaler**: 자동 확장
- **Vertical Pod Autoscaler**: 리소스 최적화
- **Cluster Autoscaler**: 노드 자동 확장

### 고가용성 전략
- **Multi-Node**: 여러 노드에 Pod 분산
- **Multi-Zone**: 여러 가용 영역에 분산
- **Health Checks**: 상태 확인 및 자동 복구
- **Rolling Updates**: 무중단 업데이트

</details>

<details>
<summary>🔧 1단계: GKE Multi-Zone 클러스터 생성</summary>

### GKE 클러스터 생성
```bash
# GKE Multi-Zone 클러스터 생성
gcloud container clusters create my-app-gke-cluster \
    --zone=asia-northeast3-a \
    --num-nodes=3 \
    --machine-type=e2-medium \
    --enable-autoscaling \
    --min-nodes=1 \
    --max-nodes=5 \
    --node-locations=asia-northeast3-a,asia-northeast3-b,asia-northeast3-c \
    --enable-autorepair \
    --enable-autoupgrade \
    --enable-ip-alias \
    --network=my-app-vpc \
    --subnetwork=my-app-subnet-1

echo "GKE cluster creating..."
```

### 클러스터 연결
```bash
# 클러스터 연결
gcloud container clusters get-credentials my-app-gke-cluster \
    --zone=asia-northeast3-a

# 클러스터 상태 확인
kubectl cluster-info
kubectl get nodes
```

</details>

<details>
<summary>🔧 2단계: Pod Anti-Affinity 설정</summary>

### Deployment with Anti-Affinity
```yaml
# high-availability-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app-deployment
  labels:
    app: my-app
spec:
  replicas: 6
  selector:
    matchLabels:
      app: my-app
  template:
    metadata:
      labels:
        app: my-app
    spec:
      affinity:
        podAntiAffinity:
          preferredDuringSchedulingIgnoredDuringExecution:
          - weight: 100
            podAffinityTerm:
              labelSelector:
                matchExpressions:
                - key: app
                  operator: In
                  values:
                  - my-app
              topologyKey: kubernetes.io/hostname
      containers:
      - name: my-app
        image: nginx:latest
        ports:
        - containerPort: 80
        resources:
          requests:
            memory: "64Mi"
            cpu: "250m"
          limits:
            memory: "128Mi"
            cpu: "500m"
        livenessProbe:
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 5
          periodSeconds: 5
```

### Deployment 적용
```bash
# Deployment 생성
kubectl apply -f high-availability-deployment.yaml

# Pod 분산 확인
kubectl get pods -o wide

# Pod Anti-Affinity 확인
kubectl describe pods -l app=my-app | grep -A 10 "Affinity"
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

# CPU 부하 테스트
kubectl run -i --tty load-generator --rm --image=busybox --restart=Never -- /bin/sh

# 부하 테스트 실행 (다른 터미널에서)
while true; do wget -q -O- http://my-app-service; done
```

</details>

---

## 🗄️ 데이터베이스 고가용성

<details>
<summary>📖 데이터베이스 고가용성 전략</summary>

### 복제 전략
- **Master-Slave**: 읽기/쓰기 분리
- **Master-Master**: 양방향 복제
- **Read Replicas**: 읽기 전용 복제본
- **Sharding**: 데이터 분할

### 백업 전략
- **자동 백업**: 정기적 자동 백업
- **Point-in-Time Recovery**: 특정 시점 복구
- **Cross-Region Backup**: 리전 간 백업
- **Snapshot**: 스냅샷 기반 백업

</details>

<details>
<summary>🔧 AWS RDS 고가용성 설정</summary>

### RDS Multi-AZ 설정
```bash
# RDS Multi-AZ 상태 확인
aws rds describe-db-instances \
    --db-instance-identifier my-app-db \
    --query 'DBInstances[0].{MultiAZ:MultiAZ,AvailabilityZone:AvailabilityZone,SecondaryAvailabilityZone:SecondaryAvailabilityZone}'

# 장애 조치 테스트
aws rds reboot-db-instance \
    --db-instance-identifier my-app-db \
    --force-failover

echo "Failover test initiated"
```

### RDS 백업 설정
```bash
# 수동 스냅샷 생성
aws rds create-db-snapshot \
    --db-instance-identifier my-app-db \
    --db-snapshot-identifier my-app-snapshot-$(date +%Y%m%d-%H%M%S)

# 스냅샷 목록 확인
aws rds describe-db-snapshots \
    --db-instance-identifier my-app-db \
    --query 'DBSnapshots[].{SnapshotId:DBSnapshotIdentifier,CreationTime:SnapshotCreateTime,Status:Status}'
```

</details>

<details>
<summary>🔧 GCP Cloud SQL 고가용성 설정</summary>

### Cloud SQL 상태 확인
```bash
# Cloud SQL 인스턴스 상태 확인
gcloud sql instances describe my-app-sql-primary \
    --format="table(name,state,settings.availabilityType,settings.backupConfiguration.enabled)"

# 읽기 복제본 상태 확인
gcloud sql instances describe my-app-sql-replica \
    --format="table(name,state,replicaConfiguration.masterInstanceName)"
```

### Cloud SQL 백업 설정
```bash
# 수동 백업 생성
gcloud sql backups create \
    --instance=my-app-sql-primary \
    --description="Manual backup $(date)"

# 백업 목록 확인
gcloud sql backups list \
    --instance=my-app-sql-primary \
    --format="table(id,windowStartTime,status,type)"
```

</details>

---

## 📚 문제 해결 및 참고 자료

<details>
<summary>🐛 자주 발생하는 문제</summary>

### Multi-AZ 관련 문제
<details>
<summary>❌ RDS Multi-AZ 구성 실패</summary>

**원인**: 
- 가용 영역 제한
- 서브넷 설정 오류
- 보안 그룹 설정 문제

**해결방법**:
```bash
# 1. 가용 영역 확인
aws ec2 describe-availability-zones

# 2. 서브넷 확인
aws ec2 describe-subnets --filters "Name=vpc-id,Values=$VPC_ID"

# 3. 보안 그룹 확인
aws ec2 describe-security-groups --group-ids $DB_SG
```

</details>

<details>
<summary>❌ Auto Scaling Group 인스턴스 분산 실패</summary>

**원인**:
- 서브넷 설정 오류
- 가용 영역 제한
- 인스턴스 타입 제한

**해결방법**:
```bash
# 1. Auto Scaling Group 설정 확인
aws autoscaling describe-auto-scaling-groups \
    --auto-scaling-group-names my-app-asg

# 2. 서브넷 가용 영역 확인
aws ec2 describe-subnets \
    --subnet-ids $PUBLIC_SUBNET_A $PUBLIC_SUBNET_C

# 3. 인스턴스 타입 가용성 확인
aws ec2 describe-instance-type-offerings \
    --location-type availability-zone \
    --filters Name=instance-type,Values=t3.micro
```

</details>

### Kubernetes 관련 문제
<details>
<summary>❌ Pod Anti-Affinity 작동 안함</summary>

**원인**:
- 노드 수 부족
- 리소스 부족
- 스케줄링 정책 오류

**해결방법**:
```bash
# 1. 노드 상태 확인
kubectl get nodes

# 2. Pod 스케줄링 이벤트 확인
kubectl describe pods -l app=my-app

# 3. 노드 리소스 확인
kubectl top nodes
```

</details>

</details>

<details>
<summary>📖 추가 학습 자료</summary>

### 공식 문서
- [AWS RDS Multi-AZ](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Concepts.MultiAZ.html)
- [GCP Cloud SQL 고가용성](https://cloud.google.com/sql/docs/mysql/high-availability)
- [Kubernetes 고가용성](https://kubernetes.io/docs/setup/production-environment/)
- [Pod Anti-Affinity](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#affinity-and-anti-affinity)

### 유용한 리소스
- [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)
- [GCP Architecture Center](https://cloud.google.com/architecture)
- [Kubernetes 샘플 프로젝트](https://github.com/kubernetes/examples)

</details>

---

## 🎉 완료!

축하합니다! 고가용성 아키텍처 실습을 완료했습니다.

### 📚 학습 요약

이번 실습을 통해 다음을 배웠습니다:

1. **☁️ AWS Multi-AZ**: RDS, Auto Scaling Group Multi-AZ 구성
2. **☁️ GCP Multi-Region**: Cloud SQL, Managed Instance Group 구성
3. **🐳 Kubernetes 고가용성**: Pod Anti-Affinity, HPA 설정
4. **🗄️ 데이터베이스 고가용성**: 복제, 백업, 장애 복구

### 🚀 다음 단계

- **로드 밸런싱 고급 실습**: [로드 밸런싱 고급 실습](./advanced-load-balancing.md)
- **모니터링 시스템 구축**: [모니터링 시스템 구축](./monitoring-system-setup.md)
- **종합 프로젝트**: [종합 프로젝트 실습](./comprehensive-project.md)

### 💡 추가 학습 자료

- [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)
- [GCP Architecture Center](https://cloud.google.com/architecture)
- [전체 커리큘럼](../../../../curriculum.md)

---

**🎯 이제 고가용성 아키텍처의 기본기를 갖추었습니다! 실제 프로젝트에 적용해보세요.**
