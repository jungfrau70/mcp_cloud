# 종합 프로젝트 실습

<div align="center">

[← 이전: 모니터링 시스템 구축 실습](./monitoring-system-setup.md) | [📚 전체 커리큘럼](../../../../curriculum.md) | [다음 과정 없음]

</div>

<details>
<summary>📋 목차</summary>

1. [🎯 학습 목표](#-학습-목표)
2. [📚 프로젝트 개요](#-프로젝트-개요)
3. [🔧 실습 환경 준비](#-실습-환경-준비)
4. [🏗️ 아키텍처 설계](#-아키텍처-설계)
5. [☁️ AWS 구현](#-aws-구현)
6. [☁️ GCP 구현](#-gcp-구현)
7. [🐳 Kubernetes 구현](#-kubernetes-구현)
8. [📊 모니터링 및 최적화](#-모니터링-및-최적화)
9. [📚 문제 해결 및 참고 자료](#-문제-해결-및-참고-자료)

</details>

---

## 🎯 학습 목표

<details>
<summary>📖 이번 실습에서 배우게 될 내용</summary>

### 핵심 학습 목표
- **종합 아키텍처** 고가용성, 확장성, 보안을 고려한 아키텍처 설계
- **멀티 클라우드** AWS, GCP, Kubernetes 통합 구현
- **실제 서비스** 실제 운영 환경과 유사한 시나리오 구현
- **성능 최적화** 비용, 성능, 보안 최적화

### 실습 후 달성할 수 있는 능력
- ✅ 실제 서비스 아키텍처 설계 및 구현
- ✅ 멀티 클라우드 환경 구성
- ✅ 종합적인 모니터링 및 알림 시스템
- ✅ 운영 환경 최적화

### 예상 소요 시간
- **아키텍처 설계**: 60-90분
- **AWS 구현**: 120-150분
- **GCP 구현**: 120-150분
- **Kubernetes 구현**: 90-120분
- **모니터링 및 최적화**: 90-120분
- **전체 과정**: 8-10시간

</details>

---

## 📚 프로젝트 개요

<details>
<summary>📖 프로젝트 시나리오</summary>

### 프로젝트 개요
**E-commerce 플랫폼**의 종합적인 클라우드 아키텍처를 구현합니다.

### 비즈니스 요구사항
- **가용성**: 99.9% 이상
- **성능**: 95% 요청이 200ms 이내
- **확장성**: 트래픽 증가에 따른 자동 확장
- **보안**: 데이터 보호 및 접근 제어
- **비용**: 최적화된 비용 구조

### 기술 요구사항
- **프론트엔드**: React, Next.js
- **백엔드**: Node.js, Express
- **데이터베이스**: MySQL, Redis
- **인프라**: AWS, GCP, Kubernetes
- **모니터링**: CloudWatch, Prometheus, Grafana

</details>

---

## 🔧 실습 환경 준비

<details>
<summary>📋 필수 도구 및 계정</summary>

### 필수 계정
- **AWS 계정**: Free Tier + 추가 크레딧
- **GCP 계정**: $300 크레딧
- **GitHub 계정**: 코드 저장소
- **Docker Hub 계정**: 컨테이너 이미지

### 필수 도구
```bash
# AWS CLI
aws --version
aws configure

# GCP CLI
gcloud --version
gcloud auth login

# kubectl
kubectl version --client

# Docker
docker --version
docker-compose --version

# Node.js
node --version
npm --version
```

### 환경 변수 설정
```bash
# AWS 설정
export AWS_DEFAULT_REGION=ap-northeast-2
export AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

# GCP 설정
export GCP_PROJECT_ID=my-project-123456
export GCP_REGION=asia-northeast3

# 애플리케이션 설정
export APP_NAME=my-ecommerce-app
export APP_VERSION=1.0.0
```

</details>

---

## 🏗️ 아키텍처 설계

<details>
<summary>📖 아키텍처 다이어그램</summary>

### 전체 아키텍처
```
Internet
    ↓
CloudFront (CDN)
    ↓
Application Load Balancer
    ↓
┌─────────────────────────────────────────────────────────┐
│  Auto Scaling Group (Multi-AZ)                        │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐      │
│  │   EC2 AZ-a  │ │   EC2 AZ-c  │ │   EC2 AZ-d  │      │
│  │   (Web)     │ │   (Web)     │ │   (Web)     │      │
│  └─────────────┘ └─────────────┘ └─────────────┘      │
└─────────────────────────────────────────────────────────┘
    ↓
┌─────────────────────────────────────────────────────────┐
│  RDS Multi-AZ (Primary + Standby)                     │
│  ElastiCache (Redis)                                   │
└─────────────────────────────────────────────────────────┘
    ↓
┌─────────────────────────────────────────────────────────┐
│  CloudWatch (Monitoring)                               │
│  SNS (Alerts)                                          │
└─────────────────────────────────────────────────────────┘
```

### Kubernetes 아키텍처
```
Internet
    ↓
Ingress Controller
    ↓
┌─────────────────────────────────────────────────────────┐
│  Kubernetes Cluster (Multi-Zone)                      │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐      │
│  │   Pod AZ-a  │ │   Pod AZ-b  │ │   Pod AZ-c  │      │
│  │   (Web)     │ │   (Web)     │ │   (Web)     │      │
│  └─────────────┘ └─────────────┘ └─────────────┘      │
└─────────────────────────────────────────────────────────┘
    ↓
┌─────────────────────────────────────────────────────────┐
│  Cloud SQL (Primary + Read Replica)                   │
│  Memorystore (Redis)                                   │
└─────────────────────────────────────────────────────────┘
    ↓
┌─────────────────────────────────────────────────────────┐
│  Cloud Monitoring (Prometheus + Grafana)               │
└─────────────────────────────────────────────────────────┘
```

</details>

<details>
<summary>📖 기술 스택</summary>

### 프론트엔드
- **React**: UI 라이브러리
- **Next.js**: React 프레임워크
- **Tailwind CSS**: CSS 프레임워크
- **TypeScript**: 타입 안전성

### 백엔드
- **Node.js**: 런타임 환경
- **Express**: 웹 프레임워크
- **MySQL**: 관계형 데이터베이스
- **Redis**: 캐시 및 세션 저장소

### 인프라
- **AWS**: EC2, RDS, ElastiCache, CloudWatch
- **GCP**: GKE, Cloud SQL, Memorystore, Cloud Monitoring
- **Kubernetes**: 컨테이너 오케스트레이션
- **Docker**: 컨테이너화

### 모니터링
- **Prometheus**: 메트릭 수집
- **Grafana**: 시각화
- **ELK Stack**: 로그 분석
- **CloudWatch**: AWS 모니터링

</details>

---

## ☁️ AWS 구현

<details>
<summary>🔧 1단계: 인프라 구성</summary>

### VPC 및 네트워킹
```bash
# VPC 생성
VPC_ID=$(aws ec2 create-vpc \
    --cidr-block 10.0.0.0/16 \
    --tag-specifications 'ResourceType=vpc,Tags=[{Key=Name,Value=my-ecommerce-vpc}]' \
    --query 'Vpc.VpcId' \
    --output text)

# Internet Gateway 생성
IGW_ID=$(aws ec2 create-internet-gateway \
    --tag-specifications 'ResourceType=internet-gateway,Tags=[{Key=Name,Value=my-ecommerce-igw}]' \
    --query 'InternetGateway.InternetGatewayId' \
    --output text)

aws ec2 attach-internet-gateway \
    --vpc-id $VPC_ID \
    --internet-gateway-id $IGW_ID

# 서브넷 생성 (Multi-AZ)
PUBLIC_SUBNET_A=$(aws ec2 create-subnet \
    --vpc-id $VPC_ID \
    --cidr-block 10.0.1.0/24 \
    --availability-zone ap-northeast-2a \
    --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=my-ecommerce-public-a}]' \
    --query 'Subnet.SubnetId' \
    --output text)

PUBLIC_SUBNET_C=$(aws ec2 create-subnet \
    --vpc-id $VPC_ID \
    --cidr-block 10.0.2.0/24 \
    --availability-zone ap-northeast-2c \
    --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=my-ecommerce-public-c}]' \
    --query 'Subnet.SubnetId' \
    --output text)

echo "VPC and subnets created"
```

### 보안 그룹 구성
```bash
# Web Security Group
WEB_SG=$(aws ec2 create-security-group \
    --group-name my-ecommerce-web-sg \
    --description "Security group for web servers" \
    --vpc-id $VPC_ID \
    --query 'GroupId' \
    --output text)

# Database Security Group
DB_SG=$(aws ec2 create-security-group \
    --group-name my-ecommerce-db-sg \
    --description "Security group for database" \
    --vpc-id $VPC_ID \
    --query 'GroupId' \
    --output text)

# 보안 그룹 규칙 설정
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
    --group-id $DB_SG \
    --protocol tcp \
    --port 3306 \
    --source-group $WEB_SG

echo "Security groups configured"
```

</details>

<details>
<summary>🔧 2단계: 데이터베이스 구성</summary>

### RDS Multi-AZ 설정
```bash
# DB Subnet Group 생성
aws rds create-db-subnet-group \
    --db-subnet-group-name my-ecommerce-db-subnet-group \
    --db-subnet-group-description "Subnet group for RDS Multi-AZ" \
    --subnet-ids $PUBLIC_SUBNET_A $PUBLIC_SUBNET_C

# RDS Multi-AZ 인스턴스 생성
aws rds create-db-instance \
    --db-instance-identifier my-ecommerce-db \
    --db-instance-class db.t3.small \
    --engine mysql \
    --engine-version 8.0.35 \
    --master-username admin \
    --master-user-password MyPassword123! \
    --allocated-storage 20 \
    --storage-type gp2 \
    --db-subnet-group-name my-ecommerce-db-subnet-group \
    --vpc-security-group-ids $DB_SG \
    --multi-az \
    --backup-retention-period 7 \
    --preferred-backup-window "03:00-04:00" \
    --preferred-maintenance-window "sun:04:00-sun:05:00" \
    --storage-encrypted \
    --deletion-protection

echo "RDS Multi-AZ instance creating..."
```

### ElastiCache Redis 설정
```bash
# ElastiCache 서브넷 그룹 생성
aws elasticache create-cache-subnet-group \
    --cache-subnet-group-name my-ecommerce-cache-subnet-group \
    --cache-subnet-group-description "Subnet group for ElastiCache" \
    --subnet-ids $PUBLIC_SUBNET_A $PUBLIC_SUBNET_C

# ElastiCache 클러스터 생성
aws elasticache create-cache-cluster \
    --cache-cluster-id my-ecommerce-cache \
    --cache-node-type cache.t3.micro \
    --engine redis \
    --num-cache-nodes 1 \
    --port 6379 \
    --cache-subnet-group-name my-ecommerce-cache-subnet-group \
    --security-group-ids $WEB_SG

echo "ElastiCache cluster creating..."
```

</details>

<details>
<summary>🔧 3단계: 애플리케이션 배포</summary>

### 애플리케이션 코드 생성
```bash
# 프로젝트 디렉토리 생성
mkdir -p my-ecommerce-app
cd my-ecommerce-app

# package.json 생성
cat > package.json << 'EOF'
{
  "name": "my-ecommerce-app",
  "version": "1.0.0",
  "description": "E-commerce application",
  "main": "server.js",
  "scripts": {
    "start": "node server.js",
    "dev": "nodemon server.js"
  },
  "dependencies": {
    "express": "^4.18.2",
    "mysql2": "^3.6.0",
    "redis": "^4.6.7",
    "cors": "^2.8.5",
    "helmet": "^7.0.0",
    "morgan": "^1.10.0"
  },
  "devDependencies": {
    "nodemon": "^3.0.1"
  }
}
EOF

# 서버 코드 생성
cat > server.js << 'EOF'
const express = require('express');
const mysql = require('mysql2/promise');
const redis = require('redis');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(helmet());
app.use(cors());
app.use(morgan('combined'));
app.use(express.json());

// Redis 클라이언트
const redisClient = redis.createClient({
  host: process.env.REDIS_HOST || 'localhost',
  port: process.env.REDIS_PORT || 6379
});

// MySQL 연결
const dbConfig = {
  host: process.env.DB_HOST || 'localhost',
  user: process.env.DB_USER || 'admin',
  password: process.env.DB_PASSWORD || 'MyPassword123!',
  database: process.env.DB_NAME || 'myecommerce'
};

// Health Check 엔드포인트
app.get('/health', async (req, res) => {
  try {
    // 데이터베이스 연결 확인
    const connection = await mysql.createConnection(dbConfig);
    await connection.execute('SELECT 1');
    await connection.end();
    
    // Redis 연결 확인
    await redisClient.ping();
    
    res.status(200).json({
      status: 'healthy',
      timestamp: new Date().toISOString(),
      services: {
        database: 'connected',
        redis: 'connected'
      }
    });
  } catch (error) {
    res.status(500).json({
      status: 'unhealthy',
      timestamp: new Date().toISOString(),
      error: error.message
    });
  }
});

// API 엔드포인트
app.get('/api/products', async (req, res) => {
  try {
    // Redis에서 캐시 확인
    const cacheKey = 'products:all';
    const cached = await redisClient.get(cacheKey);
    
    if (cached) {
      return res.json(JSON.parse(cached));
    }
    
    // 데이터베이스에서 조회
    const connection = await mysql.createConnection(dbConfig);
    const [rows] = await connection.execute('SELECT * FROM products');
    await connection.end();
    
    // Redis에 캐시 저장 (5분)
    await redisClient.setex(cacheKey, 300, JSON.stringify(rows));
    
    res.json(rows);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
EOF

# Dockerfile 생성
cat > Dockerfile << 'EOF'
FROM node:18-alpine

WORKDIR /app

COPY package*.json ./
RUN npm install --production

COPY . .

EXPOSE 3000

CMD ["npm", "start"]
EOF

echo "Application code created"
```

### Docker 이미지 빌드 및 배포
```bash
# Docker 이미지 빌드
docker build -t my-ecommerce-app:latest .

# Docker Hub에 푸시
docker tag my-ecommerce-app:latest your-dockerhub-username/my-ecommerce-app:latest
docker push your-dockerhub-username/my-ecommerce-app:latest

echo "Docker image built and pushed"
```

</details>

---

## ☁️ GCP 구현

<details>
<summary>🔧 1단계: GKE 클러스터 구성</summary>

### GKE 클러스터 생성
```bash
# GKE 클러스터 생성
gcloud container clusters create my-ecommerce-gke \
    --zone=asia-northeast3-a \
    --num-nodes=3 \
    --machine-type=e2-medium \
    --enable-autoscaling \
    --min-nodes=1 \
    --max-nodes=10 \
    --node-locations=asia-northeast3-a,asia-northeast3-b,asia-northeast3-c \
    --enable-autorepair \
    --enable-autoupgrade \
    --enable-ip-alias \
    --network=my-app-vpc \
    --subnetwork=my-app-subnet-1

# 클러스터 연결
gcloud container clusters get-credentials my-ecommerce-gke \
    --zone=asia-northeast3-a

echo "GKE cluster created and connected"
```

### Cloud SQL 설정
```bash
# Cloud SQL 인스턴스 생성
gcloud sql instances create my-ecommerce-sql \
    --database-version=MYSQL_8_0 \
    --tier=db-f1-micro \
    --region=asia-northeast3 \
    --availability-type=REGIONAL \
    --storage-type=SSD \
    --storage-size=20GB \
    --backup-start-time=03:00 \
    --enable-bin-log \
    --root-password=MyPassword123!

# 데이터베이스 생성
gcloud sql databases create myecommerce \
    --instance=my-ecommerce-sql

# 사용자 생성
gcloud sql users create myecommerce-user \
    --instance=my-ecommerce-sql \
    --password=MyPassword123!

echo "Cloud SQL instance created"
```

</details>

<details>
<summary>🔧 2단계: Kubernetes 배포</summary>

### Deployment 생성
```yaml
# deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-ecommerce-app
  labels:
    app: my-ecommerce-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: my-ecommerce-app
  template:
    metadata:
      labels:
        app: my-ecommerce-app
    spec:
      containers:
      - name: my-ecommerce-app
        image: your-dockerhub-username/my-ecommerce-app:latest
        ports:
        - containerPort: 3000
        env:
        - name: DB_HOST
          value: "my-ecommerce-sql"
        - name: DB_USER
          value: "myecommerce-user"
        - name: DB_PASSWORD
          valueFrom:
            secretKeyRef:
              name: db-secret
              key: password
        - name: DB_NAME
          value: "myecommerce"
        - name: REDIS_HOST
          value: "my-ecommerce-redis"
        resources:
          requests:
            memory: "128Mi"
            cpu: "250m"
          limits:
            memory: "256Mi"
            cpu: "500m"
        livenessProbe:
          httpGet:
            path: /health
            port: 3000
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /health
            port: 3000
          initialDelaySeconds: 5
          periodSeconds: 5
```

### Service 및 Ingress 생성
```yaml
# service.yaml
apiVersion: v1
kind: Service
metadata:
  name: my-ecommerce-service
  labels:
    app: my-ecommerce-app
spec:
  type: LoadBalancer
  ports:
  - port: 80
    targetPort: 3000
    protocol: TCP
  selector:
    app: my-ecommerce-app
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: my-ecommerce-ingress
  annotations:
    kubernetes.io/ingress.class: "gce"
    kubernetes.io/ingress.global-static-ip-name: "my-ecommerce-ip"
spec:
  rules:
  - host: my-ecommerce.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: my-ecommerce-service
            port:
              number: 80
```

### HPA 설정
```yaml
# hpa.yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: my-ecommerce-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: my-ecommerce-app
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
```

</details>

---

## 📊 모니터링 및 최적화

<details>
<summary>🔧 1단계: Prometheus + Grafana 설정</summary>

### Prometheus 설정
```yaml
# prometheus-config.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: prometheus-config
data:
  prometheus.yml: |
    global:
      scrape_interval: 15s
      evaluation_interval: 15s
    
    scrape_configs:
      - job_name: 'prometheus'
        static_configs:
          - targets: ['localhost:9090']
      
      - job_name: 'my-ecommerce-app'
        kubernetes_sd_configs:
          - role: pod
        relabel_configs:
          - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_scrape]
            action: keep
            regex: true
          - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_path]
            action: replace
            target_label: __metrics_path__
            regex: (.+)
```

### Grafana 대시보드
```json
{
  "dashboard": {
    "title": "My E-commerce Dashboard",
    "panels": [
      {
        "title": "Request Rate",
        "type": "graph",
        "targets": [
          {
            "expr": "rate(http_requests_total[5m])",
            "legendFormat": "{{method}} {{endpoint}}"
          }
        ]
      },
      {
        "title": "Error Rate",
        "type": "graph",
        "targets": [
          {
            "expr": "rate(http_requests_total{status=~\"5..\"}[5m])",
            "legendFormat": "5xx Errors"
          }
        ]
      },
      {
        "title": "Response Time",
        "type": "graph",
        "targets": [
          {
            "expr": "histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m]))",
            "legendFormat": "95th percentile"
          }
        ]
      }
    ]
  }
}
```

</details>

<details>
<summary>🔧 2단계: 비용 최적화</summary>

### AWS 비용 최적화
```bash
# Spot Instance 활용
aws ec2 request-spot-fleet \
    --spot-fleet-request-config '{
        "IamFleetRole": "arn:aws:iam::'$AWS_ACCOUNT_ID':role/aws-ec2-spot-fleet-role",
        "AllocationStrategy": "diversified",
        "TargetCapacity": 2,
        "SpotPrice": "0.05",
        "LaunchSpecifications": [
            {
                "ImageId": "ami-0ae2c887094315bed",
                "InstanceType": "t3.micro",
                "KeyName": "my-key",
                "SecurityGroups": [{"GroupId": "'$WEB_SG'"}]
            }
        ]
    }'

# Reserved Instance 구매
aws ec2 purchase-reserved-instances-offering \
    --reserved-instances-offering-id 12345678-1234-1234-1234-123456789012 \
    --instance-count 1

echo "Cost optimization configured"
```

### GCP 비용 최적화
```bash
# Preemptible Instance 활용
gcloud compute instance-templates create my-ecommerce-preemptible-template \
    --machine-type=e2-micro \
    --preemptible \
    --network=my-app-vpc \
    --subnet=my-app-subnet-1 \
    --tags=web-server \
    --image-family=ubuntu-2004-lts \
    --image-project=ubuntu-os-cloud

# Committed Use Discount
gcloud compute commitments create my-ecommerce-commitment \
    --plan=TWELVE_MONTH \
    --resources=vcpu=4,memory=16 \
    --region=asia-northeast3

echo "GCP cost optimization configured"
```

</details>

---

## 📚 문제 해결 및 참고 자료

<details>
<summary>🐛 자주 발생하는 문제</summary>

### 아키텍처 관련 문제
<details>
<summary>❌ 멀티 클라우드 연결 실패</summary>

**원인**: 
- 네트워크 설정 오류
- 보안 그룹 설정 문제
- DNS 설정 오류

**해결방법**:
```bash
# 1. 네트워크 연결 확인
ping my-ecommerce.example.com

# 2. 보안 그룹 확인
aws ec2 describe-security-groups --group-ids $WEB_SG

# 3. DNS 설정 확인
nslookup my-ecommerce.example.com
```

</details>

<details>
<summary>❌ 데이터베이스 연결 실패</summary>

**원인**:
- 데이터베이스 설정 오류
- 네트워크 접근 제한
- 인증 정보 오류

**해결방법**:
```bash
# 1. 데이터베이스 상태 확인
aws rds describe-db-instances --db-instance-identifier my-ecommerce-db

# 2. 연결 테스트
mysql -h my-ecommerce-db.region.rds.amazonaws.com -u admin -p

# 3. 보안 그룹 확인
aws ec2 describe-security-groups --group-ids $DB_SG
```

</details>

</details>

<details>
<summary>📖 추가 학습 자료</summary>

### 공식 문서
- [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)
- [GCP Architecture Center](https://cloud.google.com/architecture)
- [Kubernetes 공식 문서](https://kubernetes.io/docs/)
- [Docker 공식 문서](https://docs.docker.com/)

### 유용한 리소스
- [AWS 샘플 프로젝트](https://github.com/aws-samples)
- [GCP 샘플 프로젝트](https://github.com/GoogleCloudPlatform)
- [Kubernetes 샘플 프로젝트](https://github.com/kubernetes/examples)

</details>

---

## 🎉 완료!

축하합니다! 종합 프로젝트 실습을 완료했습니다.

### 📚 학습 요약

이번 실습을 통해 다음을 배웠습니다:

1. **🏗️ 아키텍처 설계**: 고가용성, 확장성, 보안을 고려한 설계
2. **☁️ AWS 구현**: EC2, RDS, ElastiCache, CloudWatch
3. **☁️ GCP 구현**: GKE, Cloud SQL, Memorystore, Cloud Monitoring
4. **🐳 Kubernetes 구현**: Deployment, Service, Ingress, HPA
5. **📊 모니터링 및 최적화**: Prometheus, Grafana, 비용 최적화

### 🚀 다음 단계

- **실제 프로젝트 적용**: 자신의 프로젝트에 적용
- **고급 기능 학습**: 서비스 메시, 보안, 성능 최적화
- **실무 경험**: 실제 운영 환경에서의 경험 축적

### 💡 추가 학습 자료

- [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)
- [GCP Architecture Center](https://cloud.google.com/architecture)
- [전체 커리큘럼](../../../../curriculum.md)

---

**🎯 이제 클라우드 컨테이너 기술의 모든 기본기를 갖추었습니다! 실제 프로젝트에 적용해보세요.**
