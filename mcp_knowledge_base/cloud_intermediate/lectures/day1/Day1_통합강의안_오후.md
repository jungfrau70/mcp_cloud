# ☁️ 클라우드 중급 과정 - Day 1 통합 강의안 (오후)

## 📋 오후 강의 개요

### 🎯 오후 강의 목표
- **클라우드 컨테이너 서비스**: AWS ECS, GCP Cloud Run을 활용하여 클라우드 환경에 컨테이너 애플리케이션 배포
- **통합 모니터링 허브**: AWS VM 기반 Prometheus + Grafana를 구축하여 모니터링 인프라 준비
- **외부 접속 및 보안**: AWS 보안 그룹 자동 설정 및 외부 접속 테스트를 통한 실습 환경 검증

### ⏰ 오후 강의 시간표
| 시간 | 교시 | 내용 | 시간 |
|------|------|------|------|
| 13:45-15:15 | 3교시 | 클라우드 컨테이너 서비스 | 90분 |
| 15:30-17:00 | 4교시 | 통합 모니터링 허브 | 90분 |
| 17:00-17:30 | 정리 | 실습 정리 | 30분 |

---

## 🕘 3교시: 클라우드 컨테이너 서비스 (13:45-15:15)

### 📚 강의 내용 (30분)

#### 클라우드 컨테이너 서비스 개요
```mermaid
flowchart TD
    subgraph "클라우드 컨테이너 서비스"
        A["AWS ECS"] --> B["Fargate 서버리스"]
        C["GCP Cloud Run"] --> D["서버리스 컨테이너"]
        E["Azure Container Instances"] --> F["관리형 컨테이너"]
    end
    
    subgraph "서비스 특징"
        G["자동 스케일링"] --> H["로드 밸런싱"]
        H --> I["보안 관리"]
        I --> J["모니터링 통합"]
    end
    
    A --> G
    C --> G
    E --> G
    
    style A fill:#ff6f00,color:#ffffff
    style B fill:#ff6f00,color:#ffffff
    style C fill:#1976d2,color:#ffffff
    style D fill:#1976d2,color:#ffffff
    style E fill:#4caf50,color:#ffffff
    style F fill:#4caf50,color:#ffffff
    style G fill:#4caf50,color:#ffffff
    style H fill:#4caf50,color:#ffffff
    style I fill:#4caf50,color:#ffffff
    style J fill:#4caf50,color:#ffffff
```

#### 핵심 개념
- **AWS ECS**: 컨테이너 오케스트레이션 서비스
- **GCP Cloud Run**: 서버리스 컨테이너 플랫폼
- **클라우드 네이티브**: 클라우드 환경에 최적화된 배포 전략

### 🛠️ 실습 진행 (60분)

#### 실습 1: AWS ECS 배포 (30분)

**변경 전 시스템 아키텍처**:
```mermaid
flowchart TD
    subgraph "기존 컨테이너 배포"
        A["로컬 Docker"] --> B["수동 배포"]
        B --> C["수동 스케일링"]
        C --> D["로드 밸런서 없음"]
        D --> E["관리 복잡성"]
    end
    
    style A fill:#1976d2,color:#ffffff
    style B fill:#388e3c,color:#ffffff
    style C fill:#f57c00,color:#ffffff
    style D fill:#d32f2f,color:#ffffff
    style E fill:#9c27b0,color:#ffffff
```

**자동화 도구 실행**:
```bash
# 실습 스크립트 실행
./day1-practice.sh
# 메뉴 선택: 3. 클라우드 컨테이너 서비스

# 자동화 도구: ./tools/cloud/aws-ecs-helper.sh --action cluster-create
```

**변경 후 시스템 아키텍처**:
```mermaid
flowchart TD
    subgraph "AWS ECS 아키텍처"
        A["ECS 클러스터"] --> B["Task Definition"]
        B --> C["ECS Service"]
        C --> D["Application Load Balancer"]
        D --> E["Auto Scaling"]
    end
    
    subgraph "Fargate 서버리스"
        F["컨테이너 실행"] --> G["자동 스케일링"]
        G --> H["관리형 인프라"]
    end
    
    E --> F
    
    style A fill:#ff6f00,color:#ffffff
    style B fill:#ff6f00,color:#ffffff
    style C fill:#ff6f00,color:#ffffff
    style D fill:#ff6f00,color:#ffffff
    style E fill:#ff6f00,color:#ffffff
    style F fill:#4caf50,color:#ffffff
    style G fill:#4caf50,color:#ffffff
    style H fill:#4caf50,color:#ffffff
```

**실습 명령어**:
```bash
# ECS 클러스터 생성
aws ecs create-cluster --cluster-name my-cluster

# Task Definition 생성
cat > task-definition.json << 'EOF'
{
  "family": "nginx-task",
  "networkMode": "awsvpc",
  "requiresCompatibilities": ["FARGATE"],
  "cpu": "256",
  "memory": "512",
  "executionRoleArn": "arn:aws:iam::ACCOUNT:role/ecsTaskExecutionRole",
  "containerDefinitions": [
    {
      "name": "nginx",
      "image": "nginx:1.21",
      "portMappings": [
        {
          "containerPort": 80,
          "protocol": "tcp"
        }
      ],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/nginx",
          "awslogs-region": "us-west-2",
          "awslogs-stream-prefix": "ecs"
        }
      }
    }
  ]
}
EOF

aws ecs register-task-definition --cli-input-json file://task-definition.json

# ECS 서비스 생성
aws ecs create-service \
  --cluster my-cluster \
  --service-name nginx-service \
  --task-definition nginx-task:1 \
  --desired-count 2 \
  --launch-type FARGATE \
  --network-configuration "awsvpcConfiguration={subnets=[subnet-12345],securityGroups=[sg-12345],assignPublicIp=ENABLED}"
```

**실습 내용**:
- ECS 태스크 정의 생성
- ECS 서비스 생성
- Application Load Balancer 연결
- 자동 스케일링 설정

#### 수작업 실습 가이드 (AWS ECS 배포)

**1단계: AWS CLI 설정 및 ECS 클러스터 생성**
```bash
# AWS CLI 설정 확인
aws configure list
aws sts get-caller-identity

# ECS 클러스터 생성
aws ecs create-cluster \
    --cluster-name cloud-intermediate-cluster \
    --capacity-providers FARGATE \
    --default-capacity-provider-strategy capacityProvider=FARGATE,weight=1

# 클러스터 상태 확인
aws ecs describe-clusters --clusters cloud-intermediate-cluster
```

**2단계: IAM 역할 생성**
```bash
# ECS Task Execution Role 생성
aws iam create-role \
    --role-name ecsTaskExecutionRole \
    --assume-role-policy-document '{
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Principal": {
                    "Service": "ecs-tasks.amazonaws.com"
                },
                "Action": "sts:AssumeRole"
            }
        ]
    }'

# ECS Task Execution Role에 정책 연결
aws iam attach-role-policy \
    --role-name ecsTaskExecutionRole \
    --policy-arn arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy

# ECS Task Role 생성 (애플리케이션용)
aws iam create-role \
    --role-name ecsTaskRole \
    --assume-role-policy-document '{
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Principal": {
                    "Service": "ecs-tasks.amazonaws.com"
                },
                "Action": "sts:AssumeRole"
            }
        ]
    }'
```

**3단계: CloudWatch Log Group 생성**
```bash
# CloudWatch Log Group 생성
aws logs create-log-group \
    --log-group-name /ecs/cloud-intermediate-app

# Log Group 정책 설정
aws logs put-retention-policy \
    --log-group-name /ecs/cloud-intermediate-app \
    --retention-in-days 7
```

**4단계: VPC 및 네트워크 설정**
```bash
# 기본 VPC 정보 확인
aws ec2 describe-vpcs --filters "Name=is-default,Values=true"

# 서브넷 정보 확인
aws ec2 describe-subnets --filters "Name=vpc-id,Values=vpc-$(aws ec2 describe-vpcs --filters 'Name=is-default,Values=true' --query 'Vpcs[0].VpcId' --output text)"

# 보안 그룹 생성
aws ec2 create-security-group \
    --group-name ecs-security-group \
    --description "Security group for ECS tasks" \
    --vpc-id $(aws ec2 describe-vpcs --filters 'Name=is-default,Values=true' --query 'Vpcs[0].VpcId' --output text)

# 보안 그룹 규칙 추가 (HTTP)
aws ec2 authorize-security-group-ingress \
    --group-id $(aws ec2 describe-security-groups --filters 'Name=group-name,Values=ecs-security-group' --query 'SecurityGroups[0].GroupId' --output text) \
    --protocol tcp \
    --port 80 \
    --cidr 0.0.0.0/0

# 보안 그룹 규칙 추가 (HTTPS)
aws ec2 authorize-security-group-ingress \
    --group-id $(aws ec2 describe-security-groups --filters 'Name=group-name,Values=ecs-security-group' --query 'SecurityGroups[0].GroupId' --output text) \
    --protocol tcp \
    --port 443 \
    --cidr 0.0.0.0/0
```

**5단계: Task Definition 생성**
```bash
# Task Definition JSON 파일 생성
cat > task-definition.json << 'EOF'
{
  "family": "cloud-intermediate-app",
  "networkMode": "awsvpc",
  "requiresCompatibilities": ["FARGATE"],
  "cpu": "256",
  "memory": "512",
  "executionRoleArn": "arn:aws:iam::ACCOUNT_ID:role/ecsTaskExecutionRole",
  "taskRoleArn": "arn:aws:iam::ACCOUNT_ID:role/ecsTaskRole",
  "containerDefinitions": [
    {
      "name": "nginx",
      "image": "nginx:1.21",
      "portMappings": [
        {
          "containerPort": 80,
          "protocol": "tcp"
        }
      ],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/cloud-intermediate-app",
          "awslogs-region": "ap-northeast-2",
          "awslogs-stream-prefix": "ecs"
        }
      },
      "healthCheck": {
        "command": [
          "CMD-SHELL",
          "curl -f http://localhost:80 || exit 1"
        ],
        "interval": 30,
        "timeout": 5,
        "retries": 3,
        "startPeriod": 60
      }
    }
  ]
}
EOF

# Account ID 자동 치환
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
sed -i "s/ACCOUNT_ID/$ACCOUNT_ID/g" task-definition.json

# Task Definition 등록
aws ecs register-task-definition --cli-input-json file://task-definition.json

# Task Definition 확인
aws ecs describe-task-definition --task-definition cloud-intermediate-app
```

**6단계: Application Load Balancer 생성**
```bash
# ALB 생성
aws elbv2 create-load-balancer \
    --name cloud-intermediate-alb \
    --subnets $(aws ec2 describe-subnets --filters 'Name=vpc-id,Values='$(aws ec2 describe-vpcs --filters 'Name=is-default,Values=true' --query 'Vpcs[0].VpcId' --output text) --query 'Subnets[0].SubnetId' --output text) $(aws ec2 describe-subnets --filters 'Name=vpc-id,Values='$(aws ec2 describe-vpcs --filters 'Name=is-default,Values=true' --query 'Vpcs[0].VpcId' --output text) --query 'Subnets[1].SubnetId' --output text) \
    --security-groups $(aws ec2 describe-security-groups --filters 'Name=group-name,Values=ecs-security-group' --query 'SecurityGroups[0].GroupId' --output text) \
    --scheme internet-facing \
    --type application \
    --ip-address-type ipv4

# ALB ARN 저장
ALB_ARN=$(aws elbv2 describe-load-balancers --names cloud-intermediate-alb --query 'LoadBalancers[0].LoadBalancerArn' --output text)

# Target Group 생성
aws elbv2 create-target-group \
    --name cloud-intermediate-tg \
    --protocol HTTP \
    --port 80 \
    --vpc-id $(aws ec2 describe-vpcs --filters 'Name=is-default,Values=true' --query 'Vpcs[0].VpcId' --output text) \
    --target-type ip \
    --health-check-path / \
    --health-check-interval-seconds 30 \
    --health-check-timeout-seconds 5 \
    --healthy-threshold-count 2 \
    --unhealthy-threshold-count 3

# Target Group ARN 저장
TG_ARN=$(aws elbv2 describe-target-groups --names cloud-intermediate-tg --query 'TargetGroups[0].TargetGroupArn' --output text)

# Listener 생성
aws elbv2 create-listener \
    --load-balancer-arn $ALB_ARN \
    --protocol HTTP \
    --port 80 \
    --default-actions Type=forward,TargetGroupArn=$TG_ARN
```

**7단계: ECS 서비스 생성**
```bash
# ECS 서비스 생성
aws ecs create-service \
    --cluster cloud-intermediate-cluster \
    --service-name cloud-intermediate-service \
    --task-definition cloud-intermediate-app:1 \
    --desired-count 2 \
    --launch-type FARGATE \
    --network-configuration "awsvpcConfiguration={subnets=[$(aws ec2 describe-subnets --filters 'Name=vpc-id,Values='$(aws ec2 describe-vpcs --filters 'Name=is-default,Values=true' --query 'Vpcs[0].VpcId' --output text) --query 'Subnets[0].SubnetId' --output text),$(aws ec2 describe-subnets --filters 'Name=vpc-id,Values='$(aws ec2 describe-vpcs --filters 'Name=is-default,Values=true' --query 'Vpcs[0].VpcId' --output text) --query 'Subnets[1].SubnetId' --output text)],securityGroups=[$(aws ec2 describe-security-groups --filters 'Name=group-name,Values=ecs-security-group' --query 'SecurityGroups[0].GroupId' --output text)],assignPublicIp=ENABLED}" \
    --load-balancers "targetGroupArn=$TG_ARN,containerName=nginx,containerPort=80"

# 서비스 상태 확인
aws ecs describe-services \
    --cluster cloud-intermediate-cluster \
    --services cloud-intermediate-service
```

**8단계: Auto Scaling 설정**
```bash
# Auto Scaling Target 생성
aws application-autoscaling register-scalable-target \
    --service-namespace ecs \
    --resource-id service/cloud-intermediate-cluster/cloud-intermediate-service \
    --scalable-dimension ecs:service:DesiredCount \
    --min-capacity 1 \
    --max-capacity 10

# Auto Scaling Policy 생성 (CPU 기반)
aws application-autoscaling put-scaling-policy \
    --service-namespace ecs \
    --resource-id service/cloud-intermediate-cluster/cloud-intermediate-service \
    --scalable-dimension ecs:service:DesiredCount \
    --policy-name cpu-scaling-policy \
    --policy-type TargetTrackingScaling \
    --target-tracking-scaling-policy-configuration '{
        "TargetValue": 70.0,
        "PredefinedMetricSpecification": {
            "PredefinedMetricType": "ECSServiceAverageCPUUtilization"
        },
        "ScaleOutCooldown": 300,
        "ScaleInCooldown": 300
    }'

# Auto Scaling Policy 생성 (메모리 기반)
aws application-autoscaling put-scaling-policy \
    --service-namespace ecs \
    --resource-id service/cloud-intermediate-cluster/cloud-intermediate-service \
    --scalable-dimension ecs:service:DesiredCount \
    --policy-name memory-scaling-policy \
    --policy-type TargetTrackingScaling \
    --target-tracking-scaling-policy-configuration '{
        "TargetValue": 80.0,
        "PredefinedMetricSpecification": {
            "PredefinedMetricType": "ECSServiceAverageMemoryUtilization"
        },
        "ScaleOutCooldown": 300,
        "ScaleInCooldown": 300
    }'
```

**9단계: 배포 테스트**
```bash
# ALB DNS 이름 확인
aws elbv2 describe-load-balancers --names cloud-intermediate-alb --query 'LoadBalancers[0].DNSName' --output text

# ALB 접근 테스트
ALB_DNS=$(aws elbv2 describe-load-balancers --names cloud-intermediate-alb --query 'LoadBalancers[0].DNSName' --output text)
curl -I http://$ALB_DNS

# ECS 태스크 상태 확인
aws ecs list-tasks --cluster cloud-intermediate-cluster --service-name cloud-intermediate-service

# CloudWatch 로그 확인
aws logs describe-log-streams --log-group-name /ecs/cloud-intermediate-app
```

**10단계: 모니터링 설정**
```bash
# CloudWatch 대시보드 생성
aws cloudwatch put-dashboard \
    --dashboard-name ECS-Monitoring \
    --dashboard-body '{
        "widgets": [
            {
                "type": "metric",
                "x": 0,
                "y": 0,
                "width": 12,
                "height": 6,
                "properties": {
                    "metrics": [
                        ["AWS/ECS", "CPUUtilization", "ServiceName", "cloud-intermediate-service", "ClusterName", "cloud-intermediate-cluster"]
                    ],
                    "period": 300,
                    "stat": "Average",
                    "region": "ap-northeast-2",
                    "title": "ECS CPU Utilization"
                }
            },
            {
                "type": "metric",
                "x": 12,
                "y": 0,
                "width": 12,
                "height": 6,
                "properties": {
                    "metrics": [
                        ["AWS/ECS", "MemoryUtilization", "ServiceName", "cloud-intermediate-service", "ClusterName", "cloud-intermediate-cluster"]
                    ],
                    "period": 300,
                    "stat": "Average",
                    "region": "ap-northeast-2",
                    "title": "ECS Memory Utilization"
                }
            }
        ]
    }'

# CloudWatch 알람 생성
aws cloudwatch put-metric-alarm \
    --alarm-name "ECS-High-CPU" \
    --alarm-description "Alarm when CPU exceeds 80%" \
    --metric-name CPUUtilization \
    --namespace AWS/ECS \
    --statistic Average \
    --period 300 \
    --threshold 80 \
    --comparison-operator GreaterThanThreshold \
    --dimensions Name=ServiceName,Value=cloud-intermediate-service Name=ClusterName,Value=cloud-intermediate-cluster \
    --evaluation-periods 2
```

**11단계: 정리**
```bash
# ECS 서비스 삭제
aws ecs update-service \
    --cluster cloud-intermediate-cluster \
    --service cloud-intermediate-service \
    --desired-count 0

aws ecs delete-service \
    --cluster cloud-intermediate-cluster \
    --service cloud-intermediate-service

# Task Definition 삭제
aws ecs deregister-task-definition --task-definition cloud-intermediate-app:1

# ALB 및 Target Group 삭제
aws elbv2 delete-load-balancer --load-balancer-arn $ALB_ARN
aws elbv2 delete-target-group --target-group-arn $TG_ARN

# ECS 클러스터 삭제
aws ecs delete-cluster --cluster cloud-intermediate-cluster

# IAM 역할 삭제
aws iam detach-role-policy --role-name ecsTaskExecutionRole --policy-arn arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy
aws iam delete-role --role-name ecsTaskExecutionRole
aws iam delete-role --role-name ecsTaskRole

# CloudWatch Log Group 삭제
aws logs delete-log-group --log-group-name /ecs/cloud-intermediate-app

# 보안 그룹 삭제
aws ec2 delete-security-group --group-id $(aws ec2 describe-security-groups --filters 'Name=group-name,Values=ecs-security-group' --query 'SecurityGroups[0].GroupId' --output text)
```

#### 실습 2: GCP Cloud Run 배포 (30분)

**변경 전 시스템 아키텍처**:
```mermaid
flowchart TD
    subgraph "기존 서버리스 배포"
        A["수동 배포"] --> B["서버 관리 필요"]
        B --> C["스케일링 설정 어려움"]
        C --> D["비용 최적화 어려움"]
    end
    
    style A fill:#1976d2,color:#ffffff
    style B fill:#388e3c,color:#ffffff
    style C fill:#f57c00,color:#ffffff
    style D fill:#d32f2f,color:#ffffff
```

**자동화 도구 실행**:
```bash
# 자동화 도구: ./tools/cloud/gcp-cloudrun-helper.sh --action deploy-service
```

**변경 후 시스템 아키텍처**:
```mermaid
flowchart TD
    subgraph "GCP Cloud Run 아키텍처"
        A["Container Image"] --> B["Cloud Run Service"]
        B --> C["Auto Scaling"]
        C --> D["Traffic Management"]
        D --> E["Security Settings"]
    end
    
    subgraph "서버리스 이점"
        F["Zero Server Management"] --> G["Pay per Use"]
        G --> H["Automatic Scaling"]
        H --> I["Global Distribution"]
    end
    
    E --> F
    
    style A fill:#1976d2,color:#ffffff
    style B fill:#1976d2,color:#ffffff
    style C fill:#1976d2,color:#ffffff
    style D fill:#1976d2,color:#ffffff
    style E fill:#1976d2,color:#ffffff
    style F fill:#4caf50,color:#ffffff
    style G fill:#4caf50,color:#ffffff
    style H fill:#4caf50,color:#ffffff
    style I fill:#4caf50,color:#ffffff
```

**실습 명령어**:
```bash
# Cloud Run 서비스 배포
gcloud run deploy nginx-service \
  --image nginx:1.21 \
  --platform managed \
  --region us-central1 \
  --allow-unauthenticated \
  --port 80 \
  --memory 512Mi \
  --cpu 1 \
  --min-instances 0 \
  --max-instances 10

# 서비스 상태 확인
gcloud run services list

# 서비스 URL 확인
gcloud run services describe nginx-service --region us-central1 --format 'value(status.url)'

# 트래픽 관리
gcloud run services update-traffic nginx-service \
  --to-latest \
  --region us-central1
```

**실습 내용**:
- Cloud Run 서비스 배포
- 자동 스케일링 설정
- 트래픽 관리
- 보안 설정

#### 수작업 실습 가이드 (GCP Cloud Run 배포)

**1단계: GCP CLI 설정 및 프로젝트 설정**
```bash
# GCP CLI 설치 확인
gcloud version

# GCP 인증
gcloud auth login

# 프로젝트 설정
gcloud config set project YOUR_PROJECT_ID

# 기본 리전 설정
gcloud config set compute/region asia-northeast3
gcloud config set run/region asia-northeast3

# 프로젝트 정보 확인
gcloud config list
gcloud projects describe $(gcloud config get-value project)
```

**2단계: 필요한 API 활성화**
```bash
# Cloud Run API 활성화
gcloud services enable run.googleapis.com

# Container Registry API 활성화
gcloud services enable containerregistry.googleapis.com

# Cloud Build API 활성화
gcloud services enable cloudbuild.googleapis.com

# 활성화된 API 확인
gcloud services list --enabled --filter="name:run.googleapis.com OR name:containerregistry.googleapis.com OR name:cloudbuild.googleapis.com"
```

**3단계: 샘플 애플리케이션 준비**
```bash
# 작업 디렉토리 생성
mkdir cloud-run-demo
cd cloud-run-demo

# 샘플 Node.js 애플리케이션 생성
cat > package.json << 'EOF'
{
  "name": "cloud-run-demo",
  "version": "1.0.0",
  "description": "GCP Cloud Run Demo Application",
  "main": "server.js",
  "scripts": {
    "start": "node server.js"
  },
  "dependencies": {
    "express": "^4.18.2",
    "cors": "^2.8.5"
  }
}
EOF

# Express 서버 생성
cat > server.js << 'EOF'
const express = require('express');
const cors = require('cors');

const app = express();
const PORT = process.env.PORT || 8080;

app.use(cors());
app.use(express.json());

app.get('/', (req, res) => {
  res.json({
    message: 'Hello from GCP Cloud Run!',
    timestamp: new Date().toISOString(),
    version: '1.0.0'
  });
});

app.get('/health', (req, res) => {
  res.json({
    status: 'healthy',
    uptime: process.uptime(),
    memory: process.memoryUsage()
  });
});

app.listen(PORT, '0.0.0.0', () => {
  console.log(`Server running on port ${PORT}`);
});
EOF

# Dockerfile 생성
cat > Dockerfile << 'EOF'
FROM node:18-alpine

WORKDIR /app

COPY package*.json ./
RUN npm install --only=production

COPY . .

EXPOSE 8080

USER node

CMD ["npm", "start"]
EOF

# .dockerignore 생성
cat > .dockerignore << 'EOF'
node_modules
npm-debug.log
.git
.gitignore
README.md
.env
.nyc_output
coverage
.DS_Store
EOF
```

**4단계: Container Registry에 이미지 빌드 및 푸시**
```bash
# 프로젝트 ID 가져오기
PROJECT_ID=$(gcloud config get-value project)

# Container Registry에 이미지 빌드
gcloud builds submit --tag gcr.io/$PROJECT_ID/cloud-run-demo .

# 이미지 확인
gcloud container images list --repository gcr.io/$PROJECT_ID

# 이미지 상세 정보 확인
gcloud container images describe gcr.io/$PROJECT_ID/cloud-run-demo:latest
```

**5단계: Cloud Run 서비스 배포**
```bash
# Cloud Run 서비스 배포
gcloud run deploy cloud-run-demo \
  --image gcr.io/$PROJECT_ID/cloud-run-demo:latest \
  --platform managed \
  --region asia-northeast3 \
  --allow-unauthenticated \
  --port 8080 \
  --memory 512Mi \
  --cpu 1 \
  --min-instances 0 \
  --max-instances 10 \
  --concurrency 80 \
  --timeout 300 \
  --set-env-vars NODE_ENV=production

# 배포 상태 확인
gcloud run services list --region asia-northeast3

# 서비스 상세 정보 확인
gcloud run services describe cloud-run-demo --region asia-northeast3
```

**6단계: 서비스 접근 테스트**
```bash
# 서비스 URL 가져오기
SERVICE_URL=$(gcloud run services describe cloud-run-demo --region asia-northeast3 --format 'value(status.url)')

# 서비스 접근 테스트
curl $SERVICE_URL

# 헬스 체크 테스트
curl $SERVICE_URL/health

# 서비스 로그 확인
gcloud logging read "resource.type=cloud_run_revision AND resource.labels.service_name=cloud-run-demo" --limit 10
```

**7단계: 트래픽 관리 설정**
```bash
# 새 버전 배포 (트래픽 분할 테스트용)
gcloud run deploy cloud-run-demo \
  --image gcr.io/$PROJECT_ID/cloud-run-demo:latest \
  --platform managed \
  --region asia-northeast3 \
  --no-traffic

# 트래픽을 새 버전으로 100% 전환
gcloud run services update-traffic cloud-run-demo \
  --to-latest \
  --region asia-northeast3

# 트래픽 분할 설정 (50:50)
gcloud run services update-traffic cloud-run-demo \
  --to-revisions=cloud-run-demo-00001-abc=50,cloud-run-demo-00002-def=50 \
  --region asia-northeast3

# 트래픽 설정 확인
gcloud run services describe cloud-run-demo --region asia-northeast3 --format 'value(status.traffic)'
```

**8단계: 자동 스케일링 설정**
```bash
# 서비스 업데이트 (스케일링 설정)
gcloud run services update cloud-run-demo \
  --region asia-northeast3 \
  --min-instances 1 \
  --max-instances 20 \
  --concurrency 100 \
  --cpu-throttling

# 스케일링 정책 확인
gcloud run services describe cloud-run-demo --region asia-northeast3 --format 'value(spec.template.metadata.annotations)'
```

**9단계: 보안 설정**
```bash
# 인증이 필요한 서비스로 변경
gcloud run services update cloud-run-demo \
  --region asia-northeast3 \
  --no-allow-unauthenticated

# IAM 정책 설정 (특정 사용자에게만 접근 허용)
gcloud run services add-iam-policy-binding cloud-run-demo \
  --region asia-northeast3 \
  --member="user:YOUR_EMAIL@gmail.com" \
  --role="roles/run.invoker"

# 다시 공개 접근 허용 (실습용)
gcloud run services update cloud-run-demo \
  --region asia-northeast3 \
  --allow-unauthenticated
```

**10단계: 환경 변수 및 시크릿 설정**
```bash
# 환경 변수 설정
gcloud run services update cloud-run-demo \
  --region asia-northeast3 \
  --set-env-vars NODE_ENV=production,LOG_LEVEL=info

# 시크릿 생성
echo -n "my-secret-value" | gcloud secrets create my-secret --data-file=-

# 시크릿을 환경 변수로 사용
gcloud run services update cloud-run-demo \
  --region asia-northeast3 \
  --set-secrets SECRET_KEY=my-secret:latest

# 설정 확인
gcloud run services describe cloud-run-demo --region asia-northeast3 --format 'value(spec.template.spec.template.spec.containers[0].env)'
```

**11단계: 모니터링 설정**
```bash
# Cloud Run 메트릭 확인
gcloud logging read "resource.type=cloud_run_revision AND resource.labels.service_name=cloud-run-demo" --limit 5

# Cloud Monitoring에서 메트릭 확인
gcloud monitoring metrics list --filter="resource.type=cloud_run_revision"

# 알림 정책 생성 (CPU 사용률)
gcloud alpha monitoring policies create --policy-from-file=- << 'EOF'
{
  "displayName": "Cloud Run High CPU",
  "conditions": [
    {
      "displayName": "CPU utilization is high",
      "conditionThreshold": {
        "filter": "resource.type=\"cloud_run_revision\" AND resource.labels.service_name=\"cloud-run-demo\"",
        "comparison": "COMPARISON_GREATER_THAN",
        "thresholdValue": 80,
        "duration": "300s"
      }
    }
  ],
  "alertStrategy": {
    "autoClose": "1800s"
  }
}
EOF
```

**12단계: 부하 테스트**
```bash
# Apache Bench를 사용한 부하 테스트
ab -n 100 -c 10 $SERVICE_URL/

# 또는 curl을 사용한 간단한 부하 테스트
for i in {1..10}; do
  curl -s $SERVICE_URL/health &
done
wait

# 서비스 메트릭 확인
gcloud run services describe cloud-run-demo --region asia-northeast3 --format 'value(status.conditions)'
```

**13단계: 정리**
```bash
# Cloud Run 서비스 삭제
gcloud run services delete cloud-run-demo --region asia-northeast3 --quiet

# Container Registry 이미지 삭제
gcloud container images delete gcr.io/$PROJECT_ID/cloud-run-demo:latest --quiet

# 시크릿 삭제
gcloud secrets delete my-secret --quiet

# 알림 정책 삭제
gcloud alpha monitoring policies list --filter="displayName=Cloud Run High CPU" --format="value(name)" | xargs -I {} gcloud alpha monitoring policies delete {}

# 로컬 파일 정리
cd ..
rm -rf cloud-run-demo
```

### 📊 실습 결과
- [ ] AWS ECS 컨테이너 서비스 배포 완료
- [ ] GCP Cloud Run 서버리스 배포 완료
- [ ] 자동 스케일링 설정 완료
- [ ] 로드 밸런서 연결 완료

---

## 🕘 4교시: 통합 모니터링 허브 (15:30-17:00)

### 📚 강의 내용 (30분)

#### 통합 모니터링 시스템 개요
```mermaid
flowchart TD
    subgraph "통합 모니터링 스택"
        A["Prometheus"] --> B["메트릭 수집"]
        B --> C["Grafana"]
        C --> D["시각화 대시보드"]
        D --> E["AlertManager"]
        E --> F["알림 발송"]
    end
    
    subgraph "모니터링 대상"
        G["애플리케이션"] --> H["인프라"]
        H --> I["클라우드 리소스"]
        I --> J["사용자 경험"]
    end
    
    A --> G
    
    style A fill:#d32f2f,color:#ffffff
    style B fill:#d32f2f,color:#ffffff
    style C fill:#1976d2,color:#ffffff
    style D fill:#1976d2,color:#ffffff
    style E fill:#f57c00,color:#ffffff
    style F fill:#f57c00,color:#ffffff
    style G fill:#4caf50,color:#ffffff
    style H fill:#4caf50,color:#ffffff
    style I fill:#4caf50,color:#ffffff
    style J fill:#4caf50,color:#ffffff
```

#### 핵심 개념
- **Prometheus**: 메트릭 수집 및 저장
- **Grafana**: 데이터 시각화 및 대시보드
- **Node Exporter**: 시스템 메트릭 수집
- **AlertManager**: 알림 관리

### 🛠️ 실습 진행 (60분)

#### 실습 1: 모니터링 허브 인프라 구축 (20분)

**변경 전 시스템 아키텍처**:
```mermaid
flowchart TD
    subgraph "기존 모니터링 환경"
        A["애플리케이션"] --> B["로그 파일"]
        B --> C["수동 모니터링"]
        C --> D["알림 없음"]
        D --> E["문제 발견 지연"]
    end
    
    style A fill:#1976d2,color:#ffffff
    style B fill:#388e3c,color:#ffffff
    style C fill:#f57c00,color:#ffffff
    style D fill:#d32f2f,color:#ffffff
    style E fill:#9c27b0,color:#ffffff
```

**자동화 도구 실행**:
```bash
# 실습 스크립트 실행
./day1-practice.sh
# 메뉴 선택: 4. 통합 모니터링 허브

# 자동화 도구: ./tools/cloud/monitoring-hub-helper.sh --action create-hub
```

**변경 후 시스템 아키텍처**:
```mermaid
flowchart TD
    subgraph "통합 모니터링 허브"
        A["AWS EC2 인스턴스"] --> B["Prometheus"]
        B --> C["Grafana"]
        C --> D["통합 대시보드"]
    end
    
    subgraph "모니터링 기능"
        E["메트릭 수집"] --> F["알림 관리"]
        F --> G["로그 분석"]
        G --> H["성능 분석"]
        H --> I["자동 스케일링"]
    end
    
    D --> E
    
    style A fill:#ff6f00,color:#ffffff
    style B fill:#d32f2f,color:#ffffff
    style C fill:#1976d2,color:#ffffff
    style D fill:#4caf50,color:#ffffff
    style E fill:#4caf50,color:#ffffff
    style F fill:#4caf50,color:#ffffff
    style G fill:#4caf50,color:#ffffff
    style H fill:#4caf50,color:#ffffff
    style I fill:#4caf50,color:#ffffff
```

**실습 명령어**:
```bash
# AWS EC2 인스턴스 생성 (모니터링 허브)
aws ec2 run-instances \
    --image-id ami-0c02fb55956c7d316 \
    --instance-type t3.medium \
    --key-name my-key \
    --security-group-ids sg-12345 \
    --subnet-id subnet-12345 \
    --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=monitoring-hub}]'

# 인스턴스 상태 확인
aws ec2 describe-instances --filters "Name=tag:Name,Values=monitoring-hub"
```

**실습 내용**:
- AWS EC2 모니터링 허브 인스턴스 생성
- 보안 그룹 설정
- 네트워크 구성

#### 수작업 실습 가이드 (모니터링 허브 인프라 구축)

**1단계: AWS CLI 설정 및 VPC 확인**
```bash
# AWS CLI 설정 확인
aws configure list
aws sts get-caller-identity

# 기본 VPC 정보 확인
aws ec2 describe-vpcs --filters "Name=is-default,Values=true"

# 서브넷 정보 확인
aws ec2 describe-subnets --filters "Name=vpc-id,Values=$(aws ec2 describe-vpcs --filters 'Name=is-default,Values=true' --query 'Vpcs[0].VpcId' --output text)"
```

**2단계: 보안 그룹 생성**
```bash
# 모니터링 허브용 보안 그룹 생성
aws ec2 create-security-group \
    --group-name monitoring-hub-sg \
    --description "Security group for monitoring hub" \
    --vpc-id $(aws ec2 describe-vpcs --filters 'Name=is-default,Values=true' --query 'Vpcs[0].VpcId' --output text)

# 보안 그룹 ID 저장
SG_ID=$(aws ec2 describe-security-groups --filters 'Name=group-name,Values=monitoring-hub-sg' --query 'SecurityGroups[0].GroupId' --output text)

# SSH 접근 허용 (22번 포트)
aws ec2 authorize-security-group-ingress \
    --group-id $SG_ID \
    --protocol tcp \
    --port 22 \
    --cidr 0.0.0.0/0

# Prometheus 접근 허용 (9090번 포트)
aws ec2 authorize-security-group-ingress \
    --group-id $SG_ID \
    --protocol tcp \
    --port 9090 \
    --cidr 0.0.0.0/0

# Grafana 접근 허용 (3000번 포트)
aws ec2 authorize-security-group-ingress \
    --group-id $SG_ID \
    --protocol tcp \
    --port 3000 \
    --cidr 0.0.0.0/0

# Node Exporter 접근 허용 (9100번 포트)
aws ec2 authorize-security-group-ingress \
    --group-id $SG_ID \
    --protocol tcp \
    --port 9100 \
    --cidr 0.0.0.0/0

# HTTP 접근 허용 (80번 포트)
aws ec2 authorize-security-group-ingress \
    --group-id $SG_ID \
    --protocol tcp \
    --port 80 \
    --cidr 0.0.0.0/0

# HTTPS 접근 허용 (443번 포트)
aws ec2 authorize-security-group-ingress \
    --group-id $SG_ID \
    --protocol tcp \
    --port 443 \
    --cidr 0.0.0.0/0
```

**3단계: Key Pair 생성 (없는 경우)**
```bash
# Key Pair 확인
aws ec2 describe-key-pairs --key-names monitoring-key

# Key Pair가 없으면 생성
if [ $? -ne 0 ]; then
    aws ec2 create-key-pair --key-name monitoring-key --query 'KeyMaterial' --output text > monitoring-key.pem
    chmod 400 monitoring-key.pem
    echo "Key pair created: monitoring-key.pem"
fi
```

**4단계: EC2 인스턴스 생성**
```bash
# 최신 Amazon Linux 2 AMI ID 가져오기
AMI_ID=$(aws ec2 describe-images \
    --owners amazon \
    --filters "Name=name,Values=amzn2-ami-hvm-*-x86_64-gp2" "Name=state,Values=available" \
    --query 'Images | sort_by(@, &CreationDate) | [-1].ImageId' \
    --output text)

# EC2 인스턴스 생성
aws ec2 run-instances \
    --image-id $AMI_ID \
    --instance-type t3.medium \
    --key-name monitoring-key \
    --security-group-ids $SG_ID \
    --subnet-id $(aws ec2 describe-subnets --filters 'Name=vpc-id,Values='$(aws ec2 describe-vpcs --filters 'Name=is-default,Values=true' --query 'Vpcs[0].VpcId' --output text) --query 'Subnets[0].SubnetId' --output text) \
    --associate-public-ip-address \
    --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=monitoring-hub},{Key=Environment,Value=production}]'

# 인스턴스 ID 저장
INSTANCE_ID=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=monitoring-hub" "Name=instance-state-name,Values=running" --query 'Reservations[0].Instances[0].InstanceId' --output text)

# 인스턴스 상태 확인
aws ec2 describe-instances --instance-ids $INSTANCE_ID

# Public IP 확인
PUBLIC_IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query 'Reservations[0].Instances[0].PublicIpAddress' --output text)
echo "Monitoring Hub Public IP: $PUBLIC_IP"
```

**5단계: 인스턴스 접속 및 기본 설정**
```bash
# 인스턴스 접속
ssh -i monitoring-key.pem ec2-user@$PUBLIC_IP

# 인스턴스 내에서 실행할 명령어들
sudo yum update -y
sudo yum install -y wget curl git htop

# Docker 설치
sudo yum install -y docker
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -a -G docker ec2-user

# Docker Compose 설치
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

**6단계: Prometheus 설치 및 설정**
```bash
# Prometheus 사용자 생성
sudo useradd --no-create-home --shell /bin/false prometheus

# Prometheus 디렉토리 생성
sudo mkdir /etc/prometheus
sudo mkdir /var/lib/prometheus
sudo chown prometheus:prometheus /etc/prometheus
sudo chown prometheus:prometheus /var/lib/prometheus

# Prometheus 다운로드 및 설치
cd /tmp
wget https://github.com/prometheus/prometheus/releases/download/v2.45.0/prometheus-2.45.0.linux-amd64.tar.gz
tar xzf prometheus-2.45.0.linux-amd64.tar.gz
cd prometheus-2.45.0.linux-amd64

sudo cp prometheus /usr/local/bin/
sudo cp promtool /usr/local/bin/
sudo chown prometheus:prometheus /usr/local/bin/prometheus
sudo chown prometheus:prometheus /usr/local/bin/promtool

sudo cp -r consoles /etc/prometheus
sudo cp -r console_libraries /etc/prometheus
sudo chown -R prometheus:prometheus /etc/prometheus/consoles
sudo chown -R prometheus:prometheus /etc/prometheus/console_libraries

# Prometheus 설정 파일 생성
sudo tee /etc/prometheus/prometheus.yml > /dev/null << 'EOF'
global:
  scrape_interval: 15s
  evaluation_interval: 15s

rule_files:
  # - "first_rules.yml"
  # - "second_rules.yml"

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'node-exporter'
    static_configs:
      - targets: ['localhost:9100']

  - job_name: 'grafana'
    static_configs:
      - targets: ['localhost:3000']
EOF

sudo chown prometheus:prometheus /etc/prometheus/prometheus.yml

# Prometheus systemd 서비스 파일 생성
sudo tee /etc/systemd/system/prometheus.service > /dev/null << 'EOF'
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/prometheus \
    --config.file /etc/prometheus/prometheus.yml \
    --storage.tsdb.path /var/lib/prometheus/ \
    --web.console.templates=/etc/prometheus/consoles \
    --web.console.libraries=/etc/prometheus/console_libraries \
    --web.listen-address=0.0.0.0:9090 \
    --web.enable-lifecycle

[Install]
WantedBy=multi-user.target
EOF

# Prometheus 서비스 시작
sudo systemctl daemon-reload
sudo systemctl start prometheus
sudo systemctl enable prometheus
sudo systemctl status prometheus
```

**7단계: Node Exporter 설치**
```bash
# Node Exporter 다운로드 및 설치
cd /tmp
wget https://github.com/prometheus/node_exporter/releases/download/v1.6.1/node_exporter-1.6.1.linux-amd64.tar.gz
tar xzf node_exporter-1.6.1.linux-amd64.tar.gz
cd node_exporter-1.6.1.linux-amd64

sudo cp node_exporter /usr/local/bin/
sudo chown prometheus:prometheus /usr/local/bin/node_exporter

# Node Exporter systemd 서비스 파일 생성
sudo tee /etc/systemd/system/node_exporter.service > /dev/null << 'EOF'
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target
EOF

# Node Exporter 서비스 시작
sudo systemctl daemon-reload
sudo systemctl start node_exporter
sudo systemctl enable node_exporter
sudo systemctl status node_exporter
```

**8단계: Grafana 설치 및 설정**
```bash
# Grafana 저장소 추가
sudo tee /etc/yum.repos.d/grafana.repo > /dev/null << 'EOF'
[grafana]
name=grafana
baseurl=https://rpm.grafana.com
repo_gpgcheck=1
enabled=1
gpgcheck=1
gpgkey=https://rpm.grafana.com/gpg.key
sslverify=1
sslcacert=/etc/pki/tls/certs/ca-bundle.crt
EOF

# Grafana 설치
sudo yum install -y grafana

# Grafana 설정 파일 수정
sudo sed -i 's/;http_port = 3000/http_port = 3000/' /etc/grafana/grafana.ini
sudo sed -i 's/;http_addr =/http_addr = 0.0.0.0/' /etc/grafana/grafana.ini

# Grafana 서비스 시작
sudo systemctl start grafana-server
sudo systemctl enable grafana-server
sudo systemctl status grafana-server

# Grafana 초기 설정
sudo systemctl restart grafana-server
```

**9단계: 서비스 상태 확인**
```bash
# 모든 서비스 상태 확인
sudo systemctl status prometheus node_exporter grafana-server

# 포트 확인
sudo netstat -tlnp | grep -E ':(3000|9090|9100)'

# 서비스 접근 테스트
curl -s http://localhost:9090/api/v1/query?query=up | jq
curl -s http://localhost:3000/api/health

# 방화벽 설정 (필요한 경우)
sudo firewall-cmd --permanent --add-port=3000/tcp
sudo firewall-cmd --permanent --add-port=9090/tcp
sudo firewall-cmd --permanent --add-port=9100/tcp
sudo firewall-cmd --reload
```

**10단계: Grafana 데이터 소스 설정**
```bash
# Grafana API를 통한 데이터 소스 추가
curl -X POST \
  http://admin:admin@localhost:3000/api/datasources \
  -H 'Content-Type: application/json' \
  -d '{
    "name": "Prometheus",
    "type": "prometheus",
    "url": "http://localhost:9090",
    "access": "proxy",
    "isDefault": true
  }'

# 기본 관리자 비밀번호 변경
curl -X PUT \
  http://admin:admin@localhost:3000/api/admin/users/1/password \
  -H 'Content-Type: application/json' \
  -d '{
    "oldPassword": "admin",
    "newPassword": "admin123",
    "confirmNew": "admin123"
  }'
```

**11단계: 모니터링 대시보드 생성**
```bash
# Node Exporter 대시보드 가져오기
DASHBOARD_ID=1860
curl -X POST \
  http://admin:admin123@localhost:3000/api/dashboards/db \
  -H 'Content-Type: application/json' \
  -d "{
    \"dashboard\": $(curl -s https://grafana.com/api/dashboards/$DASHBOARD_ID/revisions/1/download | jq '.dashboard'),
    \"overwrite\": true
  }"

# Prometheus Stats 대시보드 가져오기
DASHBOARD_ID=2
curl -X POST \
  http://admin:admin123@localhost:3000/api/dashboards/db \
  -H 'Content-Type: application/json' \
  -d "{
    \"dashboard\": $(curl -s https://grafana.com/api/dashboards/$DASHBOARD_ID/revisions/1/download | jq '.dashboard'),
    \"overwrite\": true
  }"
```

**12단계: 외부 접근 테스트**
```bash
# 인스턴스에서 나가기
exit

# 로컬에서 외부 접근 테스트
echo "Prometheus: http://$PUBLIC_IP:9090"
echo "Grafana: http://$PUBLIC_IP:3000 (admin/admin123)"
echo "Node Exporter: http://$PUBLIC_IP:9100"

# 접근 테스트
curl -I http://$PUBLIC_IP:9090
curl -I http://$PUBLIC_IP:3000
curl -I http://$PUBLIC_IP:9100
```

**13단계: 정리**
```bash
# EC2 인스턴스 종료
aws ec2 terminate-instances --instance-ids $INSTANCE_ID

# 보안 그룹 삭제
aws ec2 delete-security-group --group-id $SG_ID

# Key Pair 삭제 (선택사항)
aws ec2 delete-key-pair --key-name monitoring-key
rm -f monitoring-key.pem
```

#### 실습 2: Prometheus 설치 및 설정 (20분)

**변경 전 시스템 아키텍처**:
```mermaid
flowchart TD
    subgraph "기존 모니터링"
        A["애플리케이션"] --> B["로그 파일"]
        B --> C["수동 확인"]
        C --> D["알림 없음"]
    end
    
    style A fill:#1976d2,color:#ffffff
    style B fill:#388e3c,color:#ffffff
    style C fill:#f57c00,color:#ffffff
    style D fill:#d32f2f,color:#ffffff
```

**자동화 도구 실행**:
```bash
# 자동화 도구: ./tools/cloud/monitoring-helper.sh --action install-prometheus
```

**변경 후 시스템 아키텍처**:
```mermaid
flowchart TD
    subgraph "Prometheus 모니터링"
        A["애플리케이션"] --> B["메트릭 수집"]
        B --> C["Prometheus Server"]
        C --> D["메트릭 저장"]
        D --> E["쿼리 엔진"]
    end
    
    subgraph "모니터링 기능"
        F["실시간 메트릭"] --> G["알림 규칙"]
        G --> H["자동 알림"]
        H --> I["문제 조기 발견"]
    end
    
    E --> F
    
    style A fill:#1976d2,color:#ffffff
    style B fill:#388e3c,color:#ffffff
    style C fill:#d32f2f,color:#ffffff
    style D fill:#d32f2f,color:#ffffff
    style E fill:#d32f2f,color:#ffffff
    style F fill:#4caf50,color:#ffffff
    style G fill:#4caf50,color:#ffffff
    style H fill:#4caf50,color:#ffffff
    style I fill:#4caf50,color:#ffffff
```

**실습 명령어**:
```bash
# Prometheus 설치
wget https://github.com/prometheus/prometheus/releases/download/v2.40.0/prometheus-2.40.0.linux-amd64.tar.gz
tar xzf prometheus-2.40.0.linux-amd64.tar.gz
sudo mv prometheus-2.40.0.linux-amd64 /opt/prometheus

# Prometheus 설정 파일 생성
cat > /opt/prometheus/prometheus.yml << 'EOF'
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'node-exporter'
    static_configs:
      - targets: ['localhost:9100']
EOF

# Prometheus 서비스 시작
sudo systemctl start prometheus
sudo systemctl enable prometheus
```

**실습 내용**:
- Prometheus 서버 설치
- 설정 파일 구성
- 서비스 시작 및 확인

#### 수작업 실습 가이드 (Prometheus 설치 및 설정)

**1단계: Prometheus 사용자 및 디렉토리 설정**
```bash
# Prometheus 사용자 생성
sudo useradd --no-create-home --shell /bin/false prometheus

# Prometheus 디렉토리 생성
sudo mkdir -p /etc/prometheus
sudo mkdir -p /var/lib/prometheus
sudo chown prometheus:prometheus /etc/prometheus
sudo chown prometheus:prometheus /var/lib/prometheus
```

**2단계: Prometheus 바이너리 다운로드 및 설치**
```bash
# Prometheus 최신 버전 다운로드
cd /tmp
wget https://github.com/prometheus/prometheus/releases/download/v2.45.0/prometheus-2.45.0.linux-amd64.tar.gz

# 압축 해제
tar xzf prometheus-2.45.0.linux-amd64.tar.gz
cd prometheus-2.45.0.linux-amd64

# 바이너리 파일 복사
sudo cp prometheus /usr/local/bin/
sudo cp promtool /usr/local/bin/
sudo chown prometheus:prometheus /usr/local/bin/prometheus
sudo chown prometheus:prometheus /usr/local/bin/promtool

# 설정 파일 및 웹 UI 파일 복사
sudo cp -r consoles /etc/prometheus
sudo cp -r console_libraries /etc/prometheus
sudo chown -R prometheus:prometheus /etc/prometheus/consoles
sudo chown -R prometheus:prometheus /etc/prometheus/console_libraries
```

**3단계: Prometheus 설정 파일 생성**
```bash
# Prometheus 설정 파일 생성
sudo tee /etc/prometheus/prometheus.yml > /dev/null << 'EOF'
global:
  scrape_interval: 15s
  evaluation_interval: 15s

rule_files:
  # - "first_rules.yml"
  # - "second_rules.yml"

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'node-exporter'
    static_configs:
      - targets: ['localhost:9100']

  - job_name: 'grafana'
    static_configs:
      - targets: ['localhost:3000']

  - job_name: 'docker'
    static_configs:
      - targets: ['localhost:9323']
EOF

# 설정 파일 권한 설정
sudo chown prometheus:prometheus /etc/prometheus/prometheus.yml
```

**4단계: Prometheus systemd 서비스 파일 생성**
```bash
# systemd 서비스 파일 생성
sudo tee /etc/systemd/system/prometheus.service > /dev/null << 'EOF'
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/prometheus \
    --config.file /etc/prometheus/prometheus.yml \
    --storage.tsdb.path /var/lib/prometheus/ \
    --web.console.templates=/etc/prometheus/consoles \
    --web.console.libraries=/etc/prometheus/console_libraries \
    --web.listen-address=0.0.0.0:9090 \
    --web.enable-lifecycle

[Install]
WantedBy=multi-user.target
EOF
```

**5단계: Prometheus 서비스 시작 및 확인**
```bash
# systemd 데몬 리로드
sudo systemctl daemon-reload

# Prometheus 서비스 시작
sudo systemctl start prometheus

# 서비스 활성화 (부팅 시 자동 시작)
sudo systemctl enable prometheus

# 서비스 상태 확인
sudo systemctl status prometheus

# Prometheus 웹 UI 접근 테스트
curl -s http://localhost:9090/api/v1/query?query=up | jq
```

**6단계: Prometheus 설정 검증**
```bash
# 설정 파일 문법 검증
sudo -u prometheus /usr/local/bin/promtool check config /etc/prometheus/prometheus.yml

# Prometheus 메트릭 확인
curl -s http://localhost:9090/metrics | head -20

# 타겟 상태 확인
curl -s http://localhost:9090/api/v1/targets | jq '.data.activeTargets[] | {job: .labels.job, health: .health}'
```

**7단계: Prometheus 로그 확인**
```bash
# Prometheus 로그 확인
sudo journalctl -u prometheus -f

# 최근 로그 확인
sudo journalctl -u prometheus --since "10 minutes ago"
```

**8단계: Prometheus 웹 UI 접근**
```bash
# 웹 브라우저에서 접근
echo "Prometheus Web UI: http://$(curl -s ifconfig.me):9090"
echo "Status -> Targets에서 수집 대상 확인"
echo "Graph에서 메트릭 쿼리 가능"
```

#### 실습 3: Grafana 설치 및 설정 (20분)

**변경 전 시스템 아키텍처**:
```mermaid
flowchart TD
    subgraph "기존 데이터 시각화"
        A["Prometheus 데이터"] --> B["텍스트 기반 확인"]
        B --> C["수동 분석"]
        C --> D["시각화 부족"]
    end
    
    style A fill:#1976d2,color:#ffffff
    style B fill:#388e3c,color:#ffffff
    style C fill:#f57c00,color:#ffffff
    style D fill:#d32f2f,color:#ffffff
```

**자동화 도구 실행**:
```bash
# 자동화 도구: ./tools/cloud/monitoring-helper.sh --action install-grafana
```

**변경 후 시스템 아키텍처**:
```mermaid
flowchart TD
    subgraph "Grafana 시각화"
        A["Prometheus"] --> B["Grafana Server"]
        B --> C["대시보드"]
        C --> D["차트 및 그래프"]
        D --> E["실시간 모니터링"]
    end
    
    subgraph "시각화 기능"
        F["대시보드 템플릿"] --> G["알림 설정"]
        G --> H["사용자 권한 관리"]
        H --> I["데이터 소스 통합"]
    end
    
    E --> F
    
    style A fill:#d32f2f,color:#ffffff
    style B fill:#1976d2,color:#ffffff
    style C fill:#1976d2,color:#ffffff
    style D fill:#1976d2,color:#ffffff
    style E fill:#1976d2,color:#ffffff
    style F fill:#4caf50,color:#ffffff
    style G fill:#4caf50,color:#ffffff
    style H fill:#4caf50,color:#ffffff
    style I fill:#4caf50,color:#ffffff
```

**실습 명령어**:
```bash
# Grafana 설치
wget https://dl.grafana.com/oss/release/grafana-9.3.0.linux-amd64.tar.gz
tar xzf grafana-9.3.0.linux-amd64.tar.gz
sudo mv grafana-9.3.0 /opt/grafana

# Grafana 서비스 시작
sudo systemctl start grafana-server
sudo systemctl enable grafana-server

# Grafana 접속 확인
curl http://localhost:3000
```

**실습 내용**:
- Grafana 서버 설치
- Prometheus 데이터 소스 연결
- 기본 대시보드 생성

#### 실습 4: Node Exporter 설치 (20분)

**변경 전 시스템 아키텍처**:
```mermaid
flowchart TD
    subgraph "기존 시스템 모니터링"
        A["시스템 리소스"] --> B["수동 확인"]
        B --> C["로그 기반 모니터링"]
        C --> D["통합 모니터링 부족"]
    end
    
    style A fill:#1976d2,color:#ffffff
    style B fill:#388e3c,color:#ffffff
    style C fill:#f57c00,color:#ffffff
    style D fill:#d32f2f,color:#ffffff
```

**자동화 도구 실행**:
```bash
# 자동화 도구: ./tools/cloud/monitoring-helper.sh --action install-node-exporter
```

**변경 후 시스템 아키텍처**:
```mermaid
flowchart TD
    subgraph "통합 모니터링 시스템"
        A["Node Exporter"] --> B["시스템 메트릭"]
        B --> C["Prometheus"]
        C --> D["Grafana"]
        D --> E["통합 대시보드"]
    end
    
    subgraph "모니터링 범위"
        F["CPU/메모리"] --> G["디스크/네트워크"]
        G --> H["애플리케이션 메트릭"]
        H --> I["인프라 메트릭"]
    end
    
    E --> F
    
    style A fill:#388e3c,color:#ffffff
    style B fill:#388e3c,color:#ffffff
    style C fill:#d32f2f,color:#ffffff
    style D fill:#1976d2,color:#ffffff
    style E fill:#1976d2,color:#ffffff
    style F fill:#4caf50,color:#ffffff
    style G fill:#4caf50,color:#ffffff
    style H fill:#4caf50,color:#ffffff
    style I fill:#4caf50,color:#ffffff
```

**실습 명령어**:
```bash
# Node Exporter 설치
wget https://github.com/prometheus/node_exporter/releases/download/v1.5.0/node_exporter-1.5.0.linux-amd64.tar.gz
tar xzf node_exporter-1.5.0.linux-amd64.tar.gz
sudo mv node_exporter-1.5.0.linux-amd64/node_exporter /usr/local/bin/

# Node Exporter 서비스 시작
sudo systemctl start node_exporter
sudo systemctl enable node_exporter
```

**실습 내용**:
- Node Exporter 설치
- Push Gateway 설정
- 메트릭 수집 확인

### 📊 실습 결과
- [ ] Prometheus 서버 정상 작동
- [ ] Grafana 대시보드 접근 가능
- [ ] Node Exporter 메트릭 수집 확인
- [ ] AlertManager 알림 설정 완료

---

## 🧹 실습 정리 (17:00-17:30)

### 자동 정리 실행
```bash
# Day1 실습 자동 정리
./day1-practice.sh
# 메뉴에서 "정리" 옵션 선택
```

### 정리 내용
- [ ] Docker 이미지 정리
- [ ] Kubernetes 리소스 정리
- [ ] 클라우드 리소스 정리
- [ ] 모니터링 스택 정리

---

## 📊 학습 성과 확인

### 실습 완료 체크리스트
- [ ] Docker 멀티스테이지 빌드 실습 완료
- [ ] Kubernetes 기본 리소스 생성 및 관리 완료
- [ ] AWS ECS 컨테이너 서비스 배포 완료
- [ ] GCP Cloud Run 서버리스 배포 완료
- [ ] Prometheus + Grafana 모니터링 시스템 구축 완료

### 다음 단계
- **Day 2 실습**으로 진행: CI/CD 및 고급 클라우드 배포
- **통합 강의 시나리오** 확인
- **통합 모니터링 시나리오** 확인

---

## 🎯 강의 성공 지표

### 정량적 지표
- **실습 완료율**: 95% 이상
- **환경 설정 성공률**: 90% 이상
- **LoadBalancer 접근 성공률**: 85% 이상
- **모니터링 시스템 구축 성공률**: 90% 이상

### 정성적 지표
- **수강생 만족도**: 4.5/5.0 이상
- **실습 이해도**: 90% 이상
- **문제 해결 능력**: 향상 확인
- **다음 단계 준비도**: 85% 이상

---

## 🔗 관련 자동화 도구

### Docker 관련 도구
- `./tools/cloud/docker-helper.sh` - Docker 멀티스테이지 빌드, 이미지 최적화, 보안 스캔

### Kubernetes 관련 도구
- `./tools/cloud/k8s-helper.sh` - 클러스터 Context 설정, Workload 배포, 외부 접근 구성

### 클라우드 서비스 도구
- `./tools/cloud/aws-ecs-helper.sh` - ECS 클러스터, 태스크 정의, 서비스 관리
- `./tools/cloud/gcp-cloudrun-helper.sh` - Cloud Run 서비스 배포 및 관리

### 모니터링 도구
- `./tools/cloud/monitoring-helper.sh` - Prometheus, Grafana, Node Exporter 설치 및 설정
- `./tools/cloud/monitoring-hub-helper.sh` - 통합 모니터링 허브 구축

---

## 📚 추가 학습 자료

### 공식 문서
- [Docker 공식 문서](https://docs.docker.com/)
- [Kubernetes 공식 문서](https://kubernetes.io/docs/)
- [AWS ECS 공식 문서](https://docs.aws.amazon.com/ecs/)
- [GCP Cloud Run 공식 문서](https://cloud.google.com/run/docs)
- [Prometheus 공식 문서](https://prometheus.io/docs/)
- [Grafana 공식 문서](https://grafana.com/docs/)

### 실습 샘플 코드
- `/cloud_intermediate/repo/examples/day1/docker/` - Docker 멀티스테이지 빌드 예제
- `/cloud_intermediate/repo/examples/day1/kubernetes/` - Kubernetes 리소스 예제
- `/cloud_intermediate/repo/examples/day1/aws-ecs/` - AWS ECS 배포 예제
- `/cloud_intermediate/repo/examples/day1/gcp-cloudrun/` - GCP Cloud Run 배포 예제
- `/cloud_intermediate/repo/examples/day1/monitoring/` - 모니터링 설정 예제

---

**💡 강의 진행 중 문제가 발생하면 실시간으로 지원해드리겠습니다!**  
**수강생의 학습 성과를 최대화하기 위해 지속적으로 모니터링하겠습니다.**
