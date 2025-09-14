# 종합 프로젝트 실습

<div align="center">

[← 이전: Cloud Container 2일차 메인](../README.md) | [📚 전체 커리큘럼](../../../../curriculum.md) | [🏠 학습 경로로 돌아가기](../../../../index.md)

</div>

## 🎯 프로젝트 개요

이 종합 프로젝트를 통해 지금까지 학습한 모든 기술을 통합하여 **실제 서비스 시나리오**에 맞는 고가용성 클라우드 아키텍처를 구축합니다.

### 프로젝트 요구사항

- **고가용성**: 99.9% 가용성 보장
- **확장성**: 트래픽 증가에 따른 자동 확장
- **모니터링**: 실시간 모니터링 및 알림
- **비용 최적화**: 비용 효율적인 아키텍처
- **보안**: 최소 권한 원칙 적용

## 🏗️ 아키텍처 설계

### 전체 아키텍처

```
Internet
    ↓
CloudFront (CDN)
    ↓
Application Load Balancer
    ↓
Auto Scaling Group
    ↓
ECS Fargate Tasks
    ↓
RDS Multi-AZ
    ↓
ElastiCache Redis
    ↓
S3 (Static Assets)
```

### AWS 아키텍처

```
┌─────────────────┐    ┌─────────────────┐
│   CloudFront    │    │   Route 53      │
│   (CDN)         │    │   (DNS)         │
└─────────────────┘    └─────────────────┘
         │                       │
         └───────────┬───────────┘
                     │
         ┌─────────────────┐
         │   ALB           │
         │   (Load Balancer)│
         └─────────────────┘
                     │
    ┌────────────────┼────────────────┐
    │                │                │
┌───▼───┐        ┌───▼───┐        ┌───▼───┐
│ ECS   │        │ ECS   │        │ ECS   │
│Fargate│        │Fargate│        │Fargate│
│Task 1 │        │Task 2 │        │Task 3 │
└───┬───┘        └───┬───┘        └───┬───┘
    │                │                │
    └────────────────┼────────────────┘
                     │
    ┌────────────────┼────────────────┐
    │                │                │
┌───▼───┐        ┌───▼───┐        ┌───▼───┐
│  RDS  │        │Redis  │        │  S3   │
│Multi-AZ│        │Cache  │        │Bucket │
└───────┘        └───────┘        └───────┘
```

## 🚀 1단계: 인프라 구성

### 1.1 VPC 및 네트워킹 설정

```bash
#!/bin/bash
# infrastructure-setup.sh

# VPC 생성
VPC_ID=$(aws ec2 create-vpc \
    --cidr-block 10.0.0.0/16 \
    --tag-specifications 'ResourceType=vpc,Tags=[{Key=Name,Value=production-vpc}]' \
    --query 'Vpc.VpcId' \
    --output text)

echo "VPC ID: $VPC_ID"

# 인터넷 게이트웨이 생성
IGW_ID=$(aws ec2 create-internet-gateway \
    --tag-specifications 'ResourceType=internet-gateway,Tags=[{Key=Name,Value=production-igw}]' \
    --query 'InternetGateway.InternetGatewayId' \
    --output text)

# VPC에 인터넷 게이트웨이 연결
aws ec2 attach-internet-gateway \
    --vpc-id $VPC_ID \
    --internet-gateway-id $IGW_ID

# Public 서브넷 생성 (AZ-a)
PUBLIC_SUBNET_1=$(aws ec2 create-subnet \
    --vpc-id $VPC_ID \
    --cidr-block 10.0.1.0/24 \
    --availability-zone ap-northeast-2a \
    --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=public-subnet-1}]' \
    --query 'Subnet.SubnetId' \
    --output text)

# Public 서브넷 생성 (AZ-c)
PUBLIC_SUBNET_2=$(aws ec2 create-subnet \
    --vpc-id $VPC_ID \
    --cidr-block 10.0.2.0/24 \
    --availability-zone ap-northeast-2c \
    --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=public-subnet-2}]' \
    --query 'Subnet.SubnetId' \
    --output text)

# Private 서브넷 생성 (AZ-a)
PRIVATE_SUBNET_1=$(aws ec2 create-subnet \
    --vpc-id $VPC_ID \
    --cidr-block 10.0.10.0/24 \
    --availability-zone ap-northeast-2a \
    --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=private-subnet-1}]' \
    --query 'Subnet.SubnetId' \
    --output text)

# Private 서브넷 생성 (AZ-c)
PRIVATE_SUBNET_2=$(aws ec2 create-subnet \
    --vpc-id $VPC_ID \
    --cidr-block 10.0.20.0/24 \
    --availability-zone ap-northeast-2c \
    --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=private-subnet-2}]' \
    --query 'Subnet.SubnetId' \
    --output text)

echo "Public Subnets: $PUBLIC_SUBNET_1, $PUBLIC_SUBNET_2"
echo "Private Subnets: $PRIVATE_SUBNET_1, $PRIVATE_SUBNET_2"
```

### 1.2 보안 그룹 설정

```bash
# ALB 보안 그룹
ALB_SG_ID=$(aws ec2 create-security-group \
    --group-name production-alb-sg \
    --description "Security group for ALB" \
    --vpc-id $VPC_ID \
    --query 'GroupId' \
    --output text)

# HTTP/HTTPS 허용
aws ec2 authorize-security-group-ingress \
    --group-id $ALB_SG_ID \
    --protocol tcp \
    --port 80 \
    --cidr 0.0.0.0/0

aws ec2 authorize-security-group-ingress \
    --group-id $ALB_SG_ID \
    --protocol tcp \
    --port 443 \
    --cidr 0.0.0.0/0

# ECS 보안 그룹
ECS_SG_ID=$(aws ec2 create-security-group \
    --group-name production-ecs-sg \
    --description "Security group for ECS" \
    --vpc-id $VPC_ID \
    --query 'GroupId' \
    --output text)

# ALB에서 ECS로 트래픽 허용
aws ec2 authorize-security-group-ingress \
    --group-id $ECS_SG_ID \
    --protocol tcp \
    --port 3000 \
    --source-group $ALB_SG_ID

# RDS 보안 그룹
RDS_SG_ID=$(aws ec2 create-security-group \
    --group-name production-rds-sg \
    --description "Security group for RDS" \
    --vpc-id $VPC_ID \
    --query 'GroupId' \
    --output text)

# ECS에서 RDS로 트래픽 허용
aws ec2 authorize-security-group-ingress \
    --group-id $RDS_SG_ID \
    --protocol tcp \
    --port 3306 \
    --source-group $ECS_SG_ID
```

## 🐳 2단계: 애플리케이션 컨테이너화

### 2.1 Node.js 애플리케이션 생성

```javascript
// app.js
const express = require('express');
const mysql = require('mysql2/promise');
const redis = require('redis');
const cors = require('cors');

const app = express();
const PORT = process.env.PORT || 3000;

// 미들웨어
app.use(cors());
app.use(express.json());

// Redis 연결
const redisClient = redis.createClient({
    host: process.env.REDIS_HOST || 'localhost',
    port: process.env.REDIS_PORT || 6379
});

// MySQL 연결
const dbConfig = {
    host: process.env.DB_HOST || 'localhost',
    user: process.env.DB_USER || 'root',
    password: process.env.DB_PASSWORD || 'password',
    database: process.env.DB_NAME || 'myapp'
};

// 헬스 체크 엔드포인트
app.get('/health', (req, res) => {
    res.status(200).json({ status: 'healthy', timestamp: new Date().toISOString() });
});

// 메인 API 엔드포인트
app.get('/api/users', async (req, res) => {
    try {
        // Redis에서 캐시 확인
        const cacheKey = 'users:all';
        const cached = await redisClient.get(cacheKey);
        
        if (cached) {
            return res.json(JSON.parse(cached));
        }
        
        // 데이터베이스에서 조회
        const connection = await mysql.createConnection(dbConfig);
        const [rows] = await connection.execute('SELECT * FROM users');
        await connection.end();
        
        // Redis에 캐시 저장 (5분)
        await redisClient.setex(cacheKey, 300, JSON.stringify(rows));
        
        res.json(rows);
    } catch (error) {
        console.error('Error fetching users:', error);
        res.status(500).json({ error: 'Internal server error' });
    }
});

app.post('/api/users', async (req, res) => {
    try {
        const { name, email } = req.body;
        
        const connection = await mysql.createConnection(dbConfig);
        const [result] = await connection.execute(
            'INSERT INTO users (name, email) VALUES (?, ?)',
            [name, email]
        );
        await connection.end();
        
        // 캐시 무효화
        await redisClient.del('users:all');
        
        res.status(201).json({ id: result.insertId, name, email });
    } catch (error) {
        console.error('Error creating user:', error);
        res.status(500).json({ error: 'Internal server error' });
    }
});

app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
});
```

### 2.2 Dockerfile 생성

```dockerfile
# Dockerfile
FROM node:18-alpine AS builder

WORKDIR /app

# 패키지 파일 복사
COPY package*.json ./

# 의존성 설치
RUN npm ci --only=production

# 프로덕션 이미지
FROM node:18-alpine AS production

WORKDIR /app

# 사용자 생성
RUN addgroup -g 1001 -S nodejs
RUN adduser -S nextjs -u 1001

# 패키지 파일 및 의존성 복사
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package*.json ./

# 애플리케이션 코드 복사
COPY . .

# 사용자 변경
USER nextjs

# 포트 노출
EXPOSE 3000

# 헬스 체크
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:3000/health || exit 1

# 애플리케이션 실행
CMD ["node", "app.js"]
```

### 2.3 Docker Compose 설정

```yaml
# docker-compose.yml
version: '3.8'

services:
  app:
    build: .
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=production
      - DB_HOST=mysql
      - DB_USER=myapp
      - DB_PASSWORD=password
      - DB_NAME=myapp
      - REDIS_HOST=redis
      - REDIS_PORT=6379
    depends_on:
      - mysql
      - redis
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/health"]
      interval: 30s
      timeout: 10s
      retries: 3

  mysql:
    image: mysql:8.0
    environment:
      - MYSQL_ROOT_PASSWORD=rootpassword
      - MYSQL_DATABASE=myapp
      - MYSQL_USER=myapp
      - MYSQL_PASSWORD=password
    volumes:
      - mysql_data:/var/lib/mysql
      - ./init.sql:/docker-entrypoint-initdb.d/init.sql
    ports:
      - "3306:3306"

  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"
    volumes:
      - redis_data:/data

volumes:
  mysql_data:
  redis_data:
```

## ☁️ 3단계: AWS 서비스 구성

### 3.1 RDS 데이터베이스 생성

```bash
# DB 서브넷 그룹 생성
aws rds create-db-subnet-group \
    --db-subnet-group-name production-db-subnet-group \
    --db-subnet-group-description "Subnet group for production RDS" \
    --subnet-ids $PRIVATE_SUBNET_1 $PRIVATE_SUBNET_2

# RDS 인스턴스 생성
aws rds create-db-instance \
    --db-instance-identifier production-mysql \
    --db-instance-class db.t3.micro \
    --engine mysql \
    --master-username admin \
    --master-user-password MySecurePassword123 \
    --allocated-storage 20 \
    --vpc-security-group-ids $RDS_SG_ID \
    --db-subnet-group-name production-db-subnet-group \
    --backup-retention-period 7 \
    --multi-az \
    --storage-encrypted
```

### 3.2 ElastiCache Redis 생성

```bash
# Redis 서브넷 그룹 생성
aws elasticache create-cache-subnet-group \
    --cache-subnet-group-name production-redis-subnet-group \
    --cache-subnet-group-description "Subnet group for production Redis" \
    --subnet-ids $PRIVATE_SUBNET_1 $PRIVATE_SUBNET_2

# Redis 클러스터 생성
aws elasticache create-cache-cluster \
    --cache-cluster-id production-redis \
    --cache-node-type cache.t3.micro \
    --engine redis \
    --num-cache-nodes 1 \
    --cache-subnet-group-name production-redis-subnet-group \
    --security-group-ids $RDS_SG_ID
```

### 3.3 ECS 클러스터 및 서비스 생성

```bash
# ECS 클러스터 생성
aws ecs create-cluster \
    --cluster-name production-cluster \
    --capacity-providers FARGATE FARGATE_SPOT \
    --default-capacity-provider-strategy capacityProvider=FARGATE,weight=1

# Task Definition 생성
cat > task-definition.json << EOF
{
  "family": "production-app",
  "networkMode": "awsvpc",
  "requiresCompatibilities": ["FARGATE"],
  "cpu": "256",
  "memory": "512",
  "executionRoleArn": "arn:aws:iam::ACCOUNT:role/ecsTaskExecutionRole",
  "taskRoleArn": "arn:aws:iam::ACCOUNT:role/ecsTaskRole",
  "containerDefinitions": [
    {
      "name": "app",
      "image": "YOUR_ACCOUNT.dkr.ecr.ap-northeast-2.amazonaws.com/production-app:latest",
      "portMappings": [
        {
          "containerPort": 3000,
          "protocol": "tcp"
        }
      ],
      "environment": [
        {
          "name": "NODE_ENV",
          "value": "production"
        },
        {
          "name": "DB_HOST",
          "value": "production-mysql.xxxxx.ap-northeast-2.rds.amazonaws.com"
        },
        {
          "name": "DB_USER",
          "value": "admin"
        },
        {
          "name": "DB_PASSWORD",
          "value": "MySecurePassword123"
        },
        {
          "name": "DB_NAME",
          "value": "myapp"
        },
        {
          "name": "REDIS_HOST",
          "value": "production-redis.xxxxx.cache.amazonaws.com"
        }
      ],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/production-app",
          "awslogs-region": "ap-northeast-2",
          "awslogs-stream-prefix": "ecs"
        }
      },
      "healthCheck": {
        "command": ["CMD-SHELL", "curl -f http://localhost:3000/health || exit 1"],
        "interval": 30,
        "timeout": 5,
        "retries": 3,
        "startPeriod": 60
      }
    }
  ]
}
EOF

aws ecs register-task-definition --cli-input-json file://task-definition.json
```

### 3.4 Application Load Balancer 생성

```bash
# ALB 생성
ALB_ARN=$(aws elbv2 create-load-balancer \
    --name production-alb \
    --subnets $PUBLIC_SUBNET_1 $PUBLIC_SUBNET_2 \
    --security-groups $ALB_SG_ID \
    --scheme internet-facing \
    --type application \
    --ip-address-type ipv4 \
    --query 'LoadBalancers[0].LoadBalancerArn' \
    --output text)

# Target Group 생성
TARGET_GROUP_ARN=$(aws elbv2 create-target-group \
    --name production-targets \
    --protocol HTTP \
    --port 3000 \
    --vpc-id $VPC_ID \
    --target-type ip \
    --health-check-path /health \
    --health-check-interval-seconds 30 \
    --health-check-timeout-seconds 5 \
    --healthy-threshold-count 2 \
    --unhealthy-threshold-count 3 \
    --query 'TargetGroups[0].TargetGroupArn' \
    --output text)

# 리스너 생성
aws elbv2 create-listener \
    --load-balancer-arn $ALB_ARN \
    --protocol HTTP \
    --port 80 \
    --default-actions Type=forward,TargetGroupArn=$TARGET_GROUP_ARN
```

## 📊 4단계: 모니터링 및 알림 설정

### 4.1 CloudWatch 로그 그룹 생성

```bash
# 로그 그룹 생성
aws logs create-log-group \
    --log-group-name /ecs/production-app \
    --retention-in-days 30
```

### 4.2 CloudWatch 알람 설정

```bash
# CPU 사용률 알람
aws cloudwatch put-metric-alarm \
    --alarm-name "Production-High-CPU" \
    --alarm-description "Alarm when CPU exceeds 80%" \
    --metric-name CPUUtilization \
    --namespace AWS/ECS \
    --statistic Average \
    --period 300 \
    --threshold 80.0 \
    --comparison-operator GreaterThanThreshold \
    --evaluation-periods 2 \
    --alarm-actions arn:aws:sns:ap-northeast-2:ACCOUNT:alerts

# 메모리 사용률 알람
aws cloudwatch put-metric-alarm \
    --alarm-name "Production-High-Memory" \
    --alarm-description "Alarm when memory exceeds 80%" \
    --metric-name MemoryUtilization \
    --namespace AWS/ECS \
    --statistic Average \
    --period 300 \
    --threshold 80.0 \
    --comparison-operator GreaterThanThreshold \
    --evaluation-periods 2 \
    --alarm-actions arn:aws:sns:ap-northeast-2:ACCOUNT:alerts
```

### 4.3 대시보드 생성

```bash
# 종합 대시보드 생성
aws cloudwatch put-dashboard \
    --dashboard-name "Production-Dashboard" \
    --dashboard-body '{
        "widgets": [
            {
                "type": "metric",
                "properties": {
                    "metrics": [
                        ["AWS/ECS", "CPUUtilization"],
                        ["AWS/ECS", "MemoryUtilization"]
                    ],
                    "period": 300,
                    "stat": "Average",
                    "region": "ap-northeast-2",
                    "title": "ECS Metrics"
                }
            },
            {
                "type": "metric",
                "properties": {
                    "metrics": [
                        ["AWS/ApplicationELB", "RequestCount"],
                        ["AWS/ApplicationELB", "TargetResponseTime"]
                    ],
                    "period": 300,
                    "stat": "Average",
                    "region": "ap-northeast-2",
                    "title": "Load Balancer Metrics"
                }
            }
        ]
    }'
```

## 🧪 5단계: 테스트 및 검증

### 5.1 부하 테스트

```bash
#!/bin/bash
# load-test.sh

ALB_DNS=$(aws elbv2 describe-load-balancers \
    --names production-alb \
    --query 'LoadBalancers[0].DNSName' \
    --output text)

echo "Testing load balancer: $ALB_DNS"

# Apache Bench를 사용한 부하 테스트
ab -n 1000 -c 10 http://$ALB_DNS/health

# wrk를 사용한 부하 테스트
wrk -t12 -c400 -d30s http://$ALB_DNS/api/users
```

### 5.2 장애 복구 테스트

```bash
#!/bin/bash
# failover-test.sh

# ECS 서비스의 태스크 수 확인
TASK_COUNT=$(aws ecs describe-services \
    --cluster production-cluster \
    --services production-service \
    --query 'services[0].runningCount' \
    --output text)

echo "Current task count: $TASK_COUNT"

# 태스크 중지 (장애 시뮬레이션)
TASK_ARN=$(aws ecs list-tasks \
    --cluster production-cluster \
    --service-name production-service \
    --query 'taskArns[0]' \
    --output text)

aws ecs stop-task \
    --cluster production-cluster \
    --task $TASK_ARN

echo "Stopped task: $TASK_ARN"

# Auto Scaling이 새로운 태스크를 생성하는지 확인
sleep 60

NEW_TASK_COUNT=$(aws ecs describe-services \
    --cluster production-cluster \
    --services production-service \
    --query 'services[0].runningCount' \
    --output text)

echo "New task count: $NEW_TASK_COUNT"
```

## 📈 6단계: 성능 최적화

### 6.1 Auto Scaling 설정

```bash
# ECS 서비스 생성
aws ecs create-service \
    --cluster production-cluster \
    --service-name production-service \
    --task-definition production-app:1 \
    --desired-count 2 \
    --launch-type FARGATE \
    --network-configuration "awsvpcConfiguration={subnets=[$PRIVATE_SUBNET_1,$PRIVATE_SUBNET_2],securityGroups=[$ECS_SG_ID],assignPublicIp=DISABLED}" \
    --load-balancers "targetGroupArn=$TARGET_GROUP_ARN,containerName=app,containerPort=3000"

# Auto Scaling 정책 생성
aws application-autoscaling register-scalable-target \
    --service-namespace ecs \
    --resource-id service/production-cluster/production-service \
    --scalable-dimension ecs:service:DesiredCount \
    --min-capacity 2 \
    --max-capacity 10

# CPU 기반 스케일링 정책
aws application-autoscaling put-scaling-policy \
    --service-namespace ecs \
    --resource-id service/production-cluster/production-service \
    --scalable-dimension ecs:service:DesiredCount \
    --policy-name production-cpu-scaling \
    --policy-type TargetTrackingScaling \
    --target-tracking-scaling-policy-configuration '{
        "TargetValue": 70.0,
        "PredefinedMetricSpecification": {
            "PredefinedMetricType": "ECSServiceAverageCPUUtilization"
        },
        "ScaleOutCooldown": 300,
        "ScaleInCooldown": 300
    }'
```

### 6.2 비용 최적화

```bash
# Spot 인스턴스 사용을 위한 용량 공급자 추가
aws ecs put-cluster-capacity-providers \
    --cluster production-cluster \
    --capacity-providers FARGATE FARGATE_SPOT \
    --default-capacity-provider-strategy capacityProvider=FARGATE_SPOT,weight=1 capacityProvider=FARGATE,weight=1

# 비용 알림 설정
aws budgets create-budget \
    --account-id ACCOUNT_ID \
    --budget '{
        "BudgetName": "Production Budget",
        "BudgetLimit": {
            "Amount": "100",
            "Unit": "USD"
        },
        "TimeUnit": "MONTHLY",
        "BudgetType": "COST"
    }'
```

## 📝 7단계: 배포 자동화

### 7.1 GitHub Actions 워크플로우

```yaml
# .github/workflows/deploy.yml
name: Deploy to Production

on:
  push:
    branches: [main]

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Configure AWS credentials
      uses: aws-actions/configure-aws-credentials@v2
      with:
        aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
        aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        aws-region: ap-northeast-2
    
    - name: Login to Amazon ECR
      id: login-ecr
      uses: aws-actions/amazon-ecr-login@v1
    
    - name: Build, tag, and push image to Amazon ECR
      env:
        ECR_REGISTRY: ${{ steps.login-ecr.outputs.registry }}
        ECR_REPOSITORY: production-app
        IMAGE_TAG: ${{ github.sha }}
      run: |
        docker build -t $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG .
        docker push $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG
    
    - name: Update ECS service
      run: |
        aws ecs update-service \
          --cluster production-cluster \
          --service production-service \
          --force-new-deployment
```

## 📊 8단계: 모니터링 및 알림

### 8.1 종합 모니터링 대시보드

```bash
# 종합 대시보드 생성
aws cloudwatch put-dashboard \
    --dashboard-name "Production-Overview" \
    --dashboard-body '{
        "widgets": [
            {
                "type": "metric",
                "properties": {
                    "metrics": [
                        ["AWS/ECS", "CPUUtilization"],
                        ["AWS/ECS", "MemoryUtilization"],
                        ["AWS/ECS", "RunningTaskCount"]
                    ],
                    "period": 300,
                    "stat": "Average",
                    "region": "ap-northeast-2",
                    "title": "ECS Cluster Metrics"
                }
            },
            {
                "type": "metric",
                "properties": {
                    "metrics": [
                        ["AWS/ApplicationELB", "RequestCount"],
                        ["AWS/ApplicationELB", "TargetResponseTime"],
                        ["AWS/ApplicationELB", "HTTPCode_Target_2XX_Count"],
                        ["AWS/ApplicationELB", "HTTPCode_Target_5XX_Count"]
                    ],
                    "period": 300,
                    "stat": "Sum",
                    "region": "ap-northeast-2",
                    "title": "Load Balancer Metrics"
                }
            },
            {
                "type": "log",
                "properties": {
                    "query": "SOURCE \"/ecs/production-app\" | fields @timestamp, @message\n| filter @message like /ERROR/\n| sort @timestamp desc\n| limit 20",
                    "region": "ap-northeast-2",
                    "title": "Error Logs",
                    "view": "table"
                }
            }
        ]
    }'
```

## 📝 실습 결과 확인

### 체크리스트

- [ ] VPC 및 네트워킹 구성 완료
- [ ] RDS Multi-AZ 데이터베이스 구성 완료
- [ ] ElastiCache Redis 구성 완료
- [ ] ECS Fargate 서비스 구성 완료
- [ ] Application Load Balancer 구성 완료
- [ ] Auto Scaling 설정 완료
- [ ] 모니터링 및 알림 설정 완료
- [ ] CI/CD 파이프라인 구성 완료
- [ ] 부하 테스트 성공
- [ ] 장애 복구 테스트 성공

### 성능 지표

- **가용성**: 99.9% 이상
- **응답 시간**: 95% 요청이 200ms 이내
- **처리량**: 초당 1000 요청 처리
- **복구 시간**: 장애 발생 시 5분 이내 복구
- **비용**: 월 $100 이하 (Free Tier 활용)

## 🎉 프로젝트 완료

이 종합 프로젝트를 통해 다음을 달성했습니다:

1. **고가용성 아키텍처**: Multi-AZ, Auto Scaling, Load Balancing
2. **모니터링 시스템**: CloudWatch, 알림, 대시보드
3. **자동화**: CI/CD 파이프라인, 배포 자동화
4. **비용 최적화**: Spot 인스턴스, 예산 관리
5. **보안**: 최소 권한 원칙, 네트워크 격리

이제 실제 프로덕션 환경에서 사용할 수 있는 완전한 클라우드 아키텍처를 구축했습니다!