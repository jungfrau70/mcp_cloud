# ☁️ 클라우드 컨테이너 서비스 실습

> 📋 **실습 시간**: 90분  
> 📋 **난이도**: 중급  
> 📋 **선수 학습**: Docker 기초, Kubernetes 기초  
> 📋 **실습 환경**: AWS ECS, GCP Cloud Run

## 🎯 학습 목표

### 핵심 학습 목표
- **AWS ECS**: 컨테이너 오케스트레이션 서비스 이해 및 활용
- **GCP Cloud Run**: 서버리스 컨테이너 플랫폼 이해 및 활용
- **클라우드 네이티브**: 클라우드 환경에 최적화된 배포 전략 학습
- **멀티 클라우드**: AWS와 GCP 클라우드 서비스 비교 및 선택

### 실습 후 달성할 수 있는 능력
- ✅ AWS ECS 태스크 정의 및 서비스 생성
- ✅ GCP Cloud Run 서버리스 컨테이너 배포
- ✅ 클라우드 로드 밸런서 연동
- ✅ 자동 스케일링 설정 및 관리
- ✅ 클라우드 모니터링 및 로깅 설정

### 예상 소요 시간
- **AWS ECS 실습**: 45분
- **GCP Cloud Run 실습**: 45분
- **통합 모니터링**: 30분

---

## 🛠️ 실습 환경 준비

### 📁 실습 코드 및 자동화
- **실습 샘플 코드**: `/cloud_intermediate/repo/practice/day1/cloud-container-services/`
- **자동화 스크립트**: `/cloud_intermediate/tools/cloud/aws-ecs-helper.sh`, `/cloud_intermediate/tools/cloud/gcp-cloudrun-helper.sh` (복사 후 사용)
- **클라우드 스크립트**: `/cloud_intermediate/tools/cloud/`

### 🔧 자동화 스크립트 사용법
```bash
# 자동화 스크립트를 실습 위치로 복사
cp ../../tools/cloud/aws-ecs-helper.sh ./
cp ../../tools/cloud/gcp-cloudrun-helper.sh ./
chmod +x aws-ecs-helper.sh gcp-cloudrun-helper.sh

# AWS ECS 실습
./aws-ecs-helper.sh --action create-cluster
./aws-ecs-helper.sh --action deploy-service

# GCP Cloud Run 실습
./gcp-cloudrun-helper.sh --action deploy-service
./gcp-cloudrun-helper.sh --action configure-traffic
```

<details>
<summary>🚀 실습 환경 준비</summary>

#### 필수 도구
- **AWS CLI**: AWS 서비스 관리
- **Google Cloud CLI**: GCP 서비스 관리
- **Docker**: 컨테이너 이미지 빌드
- **kubectl**: Kubernetes 클러스터 관리

#### 환경 설정
```bash
# AWS CLI 설정 확인
aws configure list
aws sts get-caller-identity

# Google Cloud CLI 설정 확인
gcloud auth list
gcloud config set project YOUR_PROJECT_ID

# Docker 설치 확인
docker --version

# kubectl 설치 확인
kubectl version --client
```

</details>

---

## 🔧 1단계: AWS ECS 실습

### 📋 Step 1-1: ECS 클러스터 생성

#### ECS 클러스터 생성
```bash
# ECS 클러스터 생성
aws ecs create-cluster --cluster-name cloud-intermediate-ecs --capacity-providers FARGATE

# 클러스터 상태 확인
aws ecs describe-clusters --clusters cloud-intermediate-ecs

# 클러스터 목록 확인
aws ecs list-clusters
```

#### 실습 디렉토리 생성
```bash
# 실습 디렉토리 생성
mkdir -p day1-cloud-container-services
cd day1-cloud-container-services

# ECS 실습 디렉토리 생성
mkdir -p aws-ecs
cd aws-ecs
```

### 📋 Step 1-2: 컨테이너 이미지 준비

#### Dockerfile 생성
```bash
# Dockerfile 생성
cat > Dockerfile << 'EOF'
FROM node:18-alpine

WORKDIR /app

# 패키지 파일 복사
COPY package*.json ./

# 의존성 설치
RUN npm ci --only=production

# 애플리케이션 코드 복사
COPY . .

# 포트 노출
EXPOSE 3000

# 헬스체크 추가
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:3000/health || exit 1

# 애플리케이션 실행
CMD ["node", "server.js"]
EOF
```

#### package.json 생성
```bash
# package.json 생성
cat > package.json << 'EOF'
{
  "name": "cloud-intermediate-app",
  "version": "1.0.0",
  "description": "Cloud Intermediate Application",
  "main": "server.js",
  "scripts": {
    "start": "node server.js",
    "dev": "nodemon server.js"
  },
  "dependencies": {
    "express": "^4.18.2",
    "cors": "^2.8.5",
    "helmet": "^7.0.0"
  },
  "engines": {
    "node": ">=18.0.0"
  }
}
EOF
```

#### 서버 코드 생성
```bash
# server.js 생성
cat > server.js << 'EOF'
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');

const app = express();
const PORT = process.env.PORT || 3000;

// 미들웨어 설정
app.use(helmet());
app.use(cors());
app.use(express.json());

// 헬스체크 엔드포인트
app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'healthy',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    environment: process.env.NODE_ENV || 'development'
  });
});

// 메인 엔드포인트
app.get('/', (req, res) => {
  res.json({
    message: 'Cloud Intermediate Application',
    version: '1.0.0',
    timestamp: new Date().toISOString(),
    environment: process.env.NODE_ENV || 'development'
  });
});

// API 엔드포인트
app.get('/api/status', (req, res) => {
  res.json({
    service: 'cloud-intermediate-app',
    status: 'running',
    version: '1.0.0',
    environment: process.env.NODE_ENV || 'development'
  });
});

// 서버 시작
app.listen(PORT, '0.0.0.0', () => {
  console.log(`Server is running on port ${PORT}`);
  console.log(`Environment: ${process.env.NODE_ENV || 'development'}`);
});
EOF
```

### 📋 Step 1-3: ECS 태스크 정의 생성

#### 태스크 정의 JSON 생성
```bash
# task-definition.json 생성
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
      "name": "cloud-intermediate-app",
      "image": "ACCOUNT_ID.dkr.ecr.ap-northeast-2.amazonaws.com/cloud-intermediate-app:latest",
      "portMappings": [
        {
          "containerPort": 3000,
          "protocol": "tcp"
        }
      ],
      "essential": true,
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
          "curl -f http://localhost:3000/health || exit 1"
        ],
        "interval": 30,
        "timeout": 5,
        "retries": 3,
        "startPeriod": 60
      },
      "environment": [
        {
          "name": "NODE_ENV",
          "value": "production"
        }
      ]
    }
  ]
}
EOF
```

#### ECR 리포지토리 생성
```bash
# ECR 리포지토리 생성
aws ecr create-repository --repository-name cloud-intermediate-app --region ap-northeast-2

# ECR 로그인
aws ecr get-login-password --region ap-northeast-2 | docker login --username AWS --password-stdin ACCOUNT_ID.dkr.ecr.ap-northeast-2.amazonaws.com

# 이미지 빌드
docker build -t cloud-intermediate-app .

# 이미지 태깅
docker tag cloud-intermediate-app:latest ACCOUNT_ID.dkr.ecr.ap-northeast-2.amazonaws.com/cloud-intermediate-app:latest

# 이미지 푸시
docker push ACCOUNT_ID.dkr.ecr.ap-northeast-2.amazonaws.com/cloud-intermediate-app:latest
```

### 📋 Step 1-4: ECS 서비스 생성

#### 로그 그룹 생성
```bash
# CloudWatch 로그 그룹 생성
aws logs create-log-group --log-group-name /ecs/cloud-intermediate-app --region ap-northeast-2
```

#### 태스크 정의 등록
```bash
# 태스크 정의 등록
aws ecs register-task-definition --cli-input-json file://task-definition.json

# 태스크 정의 확인
aws ecs describe-task-definition --task-definition cloud-intermediate-app
```

#### ECS 서비스 생성
```bash
# ECS 서비스 생성
aws ecs create-service \
  --cluster cloud-intermediate-ecs \
  --service-name cloud-intermediate-service \
  --task-definition cloud-intermediate-app \
  --desired-count 2 \
  --launch-type FARGATE \
  --network-configuration "awsvpcConfiguration={subnets=[subnet-xxxxxxxxx,subnet-yyyyyyyyy],securityGroups=[sg-xxxxxxxxx],assignPublicIp=ENABLED}" \
  --load-balancers "targetGroupArn=arn:aws:elasticloadbalancing:ap-northeast-2:ACCOUNT_ID:targetgroup/cloud-intermediate-tg/xxxxxxxxx,containerName=cloud-intermediate-app,containerPort=3000"

# 서비스 상태 확인
aws ecs describe-services --cluster cloud-intermediate-ecs --services cloud-intermediate-service
```

### 📋 Step 1-5: Application Load Balancer 설정

#### ALB 생성
```bash
# ALB 생성
aws elbv2 create-load-balancer \
  --name cloud-intermediate-alb \
  --subnets subnet-xxxxxxxxx subnet-yyyyyyyyy \
  --security-groups sg-xxxxxxxxx \
  --scheme internet-facing \
  --type application \
  --ip-address-type ipv4

# ALB 상태 확인
aws elbv2 describe-load-balancers --names cloud-intermediate-alb
```

#### 타겟 그룹 생성
```bash
# 타겟 그룹 생성
aws elbv2 create-target-group \
  --name cloud-intermediate-tg \
  --protocol HTTP \
  --port 3000 \
  --vpc-id vpc-xxxxxxxxx \
  --target-type ip \
  --health-check-path /health \
  --health-check-interval-seconds 30 \
  --health-check-timeout-seconds 5 \
  --healthy-threshold-count 2 \
  --unhealthy-threshold-count 3

# 타겟 그룹 확인
aws elbv2 describe-target-groups --names cloud-intermediate-tg
```

#### 리스너 생성
```bash
# ALB 리스너 생성
aws elbv2 create-listener \
  --load-balancer-arn arn:aws:elasticloadbalancing:ap-northeast-2:ACCOUNT_ID:loadbalancer/app/cloud-intermediate-alb/xxxxxxxxx \
  --protocol HTTP \
  --port 80 \
  --default-actions Type=forward,TargetGroupArn=arn:aws:elasticloadbalancing:ap-northeast-2:ACCOUNT_ID:targetgroup/cloud-intermediate-tg/xxxxxxxxx

# 리스너 확인
aws elbv2 describe-listeners --load-balancer-arn arn:aws:elasticloadbalancing:ap-northeast-2:ACCOUNT_ID:loadbalancer/app/cloud-intermediate-alb/xxxxxxxxx
```

### 📋 Step 1-6: ECS 서비스 테스트

#### 서비스 상태 확인
```bash
# ECS 서비스 상태 확인
aws ecs describe-services --cluster cloud-intermediate-ecs --services cloud-intermediate-service

# 태스크 상태 확인
aws ecs list-tasks --cluster cloud-intermediate-ecs --service-name cloud-intermediate-service

# 태스크 상세 정보 확인
aws ecs describe-tasks --cluster cloud-intermediate-ecs --tasks TASK_ARN
```

#### ALB 접근 테스트
```bash
# ALB DNS 이름 확인
ALB_DNS=$(aws elbv2 describe-load-balancers --names cloud-intermediate-alb --query 'LoadBalancers[0].DNSName' --output text)

# ALB 접근 테스트
curl -I http://$ALB_DNS
curl http://$ALB_DNS/health
curl http://$ALB_DNS/api/status
```

---

## 🔧 2단계: GCP Cloud Run 실습

### 📋 Step 2-1: Cloud Run 환경 준비

#### 실습 디렉토리 생성
```bash
# Cloud Run 실습 디렉토리 생성
cd ../gcp-cloud-run
mkdir -p gcp-cloud-run
cd gcp-cloud-run
```

#### Dockerfile 생성 (Cloud Run용)
```bash
# Dockerfile 생성
cat > Dockerfile << 'EOF'
FROM node:18-alpine

WORKDIR /app

# 패키지 파일 복사
COPY package*.json ./

# 의존성 설치
RUN npm ci --only=production

# 애플리케이션 코드 복사
COPY . .

# 포트 설정 (Cloud Run은 PORT 환경변수 사용)
ENV PORT=8080
EXPOSE $PORT

# 헬스체크 추가
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:$PORT/health || exit 1

# 애플리케이션 실행
CMD ["node", "server.js"]
EOF
```

#### package.json 생성
```bash
# package.json 생성
cat > package.json << 'EOF'
{
  "name": "cloud-intermediate-app-gcp",
  "version": "1.0.0",
  "description": "Cloud Intermediate Application for GCP",
  "main": "server.js",
  "scripts": {
    "start": "node server.js",
    "dev": "nodemon server.js"
  },
  "dependencies": {
    "express": "^4.18.2",
    "cors": "^2.8.5",
    "helmet": "^7.0.0"
  },
  "engines": {
    "node": ">=18.0.0"
  }
}
EOF
```

#### 서버 코드 생성 (Cloud Run용)
```bash
# server.js 생성
cat > server.js << 'EOF'
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');

const app = express();
const PORT = process.env.PORT || 8080;

// 미들웨어 설정
app.use(helmet());
app.use(cors());
app.use(express.json());

// 헬스체크 엔드포인트
app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'healthy',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    environment: process.env.NODE_ENV || 'production',
    platform: 'Google Cloud Run'
  });
});

// 메인 엔드포인트
app.get('/', (req, res) => {
  res.json({
    message: 'Cloud Intermediate Application (GCP)',
    version: '1.0.0',
    timestamp: new Date().toISOString(),
    environment: process.env.NODE_ENV || 'production',
    platform: 'Google Cloud Run'
  });
});

// API 엔드포인트
app.get('/api/status', (req, res) => {
  res.json({
    service: 'cloud-intermediate-app-gcp',
    status: 'running',
    version: '1.0.0',
    environment: process.env.NODE_ENV || 'production',
    platform: 'Google Cloud Run'
  });
});

// 서버 시작
app.listen(PORT, '0.0.0.0', () => {
  console.log(`Server is running on port ${PORT}`);
  console.log(`Environment: ${process.env.NODE_ENV || 'production'}`);
  console.log(`Platform: Google Cloud Run`);
});
EOF
```

### 📋 Step 2-2: Cloud Run 서비스 배포

#### 이미지 빌드 및 푸시
```bash
# Google Cloud 인증 확인
gcloud auth list
gcloud config set project YOUR_PROJECT_ID

# Artifact Registry 리포지토리 생성
gcloud artifacts repositories create cloud-intermediate-repo \
  --repository-format=docker \
  --location=asia-northeast1 \
  --description="Cloud Intermediate Application Repository"

# Docker 인증 설정
gcloud auth configure-docker asia-northeast1-docker.pkg.dev

# 이미지 빌드
docker build -t asia-northeast1-docker.pkg.dev/YOUR_PROJECT_ID/cloud-intermediate-repo/cloud-intermediate-app:latest .

# 이미지 푸시
docker push asia-northeast1-docker.pkg.dev/YOUR_PROJECT_ID/cloud-intermediate-repo/cloud-intermediate-app:latest
```

#### Cloud Run 서비스 배포
```bash
# Cloud Run 서비스 배포
gcloud run deploy cloud-intermediate-app \
  --image asia-northeast1-docker.pkg.dev/YOUR_PROJECT_ID/cloud-intermediate-repo/cloud-intermediate-app:latest \
  --platform managed \
  --region asia-northeast1 \
  --allow-unauthenticated \
  --port 8080 \
  --memory 512Mi \
  --cpu 1 \
  --min-instances 0 \
  --max-instances 10 \
  --concurrency 80 \
  --timeout 300 \
  --set-env-vars NODE_ENV=production

# 서비스 상태 확인
gcloud run services describe cloud-intermediate-app --region asia-northeast1
```

### 📋 Step 2-3: Cloud Run 서비스 테스트

#### 서비스 URL 확인
```bash
# 서비스 URL 확인
SERVICE_URL=$(gcloud run services describe cloud-intermediate-app --region asia-northeast1 --format 'value(status.url)')

# 서비스 접근 테스트
curl -I $SERVICE_URL
curl $SERVICE_URL/health
curl $SERVICE_URL/api/status
```

#### 자동 스케일링 테스트
```bash
# 부하 테스트 (간단한 방법)
for i in {1..10}; do
  curl $SERVICE_URL &
done
wait

# 서비스 로그 확인
gcloud run services logs read cloud-intermediate-app --region asia-northeast1 --limit 50
```

---

## 🔧 3단계: 통합 모니터링 설정

### 📋 Step 3-1: AWS CloudWatch 모니터링

#### CloudWatch 대시보드 생성
```bash
# CloudWatch 대시보드 생성
aws cloudwatch put-dashboard \
  --dashboard-name "CloudIntermediateECS" \
  --dashboard-body '{
    "widgets": [
      {
        "type": "metric",
        "properties": {
          "metrics": [
            [ "AWS/ECS", "CPUUtilization", "ServiceName", "cloud-intermediate-service", "ClusterName", "cloud-intermediate-ecs" ],
            [ ".", "MemoryUtilization", ".", ".", ".", "." ]
          ],
          "period": 300,
          "stat": "Average",
          "region": "ap-northeast-2",
          "title": "ECS Service Metrics"
        }
      }
    ]
  }'
```

#### CloudWatch 알람 설정
```bash
# CPU 사용률 알람 설정
aws cloudwatch put-metric-alarm \
  --alarm-name "ECS-High-CPU" \
  --alarm-description "ECS Service High CPU Usage" \
  --metric-name CPUUtilization \
  --namespace AWS/ECS \
  --statistic Average \
  --period 300 \
  --threshold 80.0 \
  --comparison-operator GreaterThanThreshold \
  --evaluation-periods 2 \
  --dimensions Name=ServiceName,Value=cloud-intermediate-service Name=ClusterName,Value=cloud-intermediate-ecs

# 메모리 사용률 알람 설정
aws cloudwatch put-metric-alarm \
  --alarm-name "ECS-High-Memory" \
  --alarm-description "ECS Service High Memory Usage" \
  --metric-name MemoryUtilization \
  --namespace AWS/ECS \
  --statistic Average \
  --period 300 \
  --threshold 80.0 \
  --comparison-operator GreaterThanThreshold \
  --evaluation-periods 2 \
  --dimensions Name=ServiceName,Value=cloud-intermediate-service Name=ClusterName,Value=cloud-intermediate-ecs
```

### 📋 Step 3-2: GCP Cloud Monitoring 설정

#### Cloud Monitoring 대시보드 생성
```bash
# Cloud Monitoring 대시보드 생성
gcloud monitoring dashboards create --config-from-file=monitoring-dashboard.json
```

#### monitoring-dashboard.json 생성
```bash
# monitoring-dashboard.json 생성
cat > monitoring-dashboard.json << 'EOF'
{
  "displayName": "Cloud Run Monitoring Dashboard",
  "mosaicLayout": {
    "tiles": [
      {
        "width": 6,
        "height": 4,
        "widget": {
          "title": "Request Count",
          "xyChart": {
            "dataSets": [
              {
                "timeSeriesQuery": {
                  "timeSeriesFilter": {
                    "filter": "resource.type=\"cloud_run_revision\" AND resource.labels.service_name=\"cloud-intermediate-app\"",
                    "aggregation": {
                      "alignmentPeriod": "60s",
                      "perSeriesAligner": "ALIGN_RATE",
                      "crossSeriesReducer": "REDUCE_SUM",
                      "groupByFields": []
                    }
                  }
                }
              }
            ]
          }
        }
      },
      {
        "width": 6,
        "height": 4,
        "widget": {
          "title": "Request Latency",
          "xyChart": {
            "dataSets": [
              {
                "timeSeriesQuery": {
                  "timeSeriesFilter": {
                    "filter": "resource.type=\"cloud_run_revision\" AND resource.labels.service_name=\"cloud-intermediate-app\"",
                    "aggregation": {
                      "alignmentPeriod": "60s",
                      "perSeriesAligner": "ALIGN_DELTA",
                      "crossSeriesReducer": "REDUCE_SUM",
                      "groupByFields": []
                    }
                  }
                }
              }
            ]
          }
        }
      }
    ]
  }
}
EOF
```

### 📋 Step 3-3: 통합 모니터링 대시보드

#### Prometheus 설정 (통합 모니터링)
```bash
# Prometheus 설정 파일 생성
cat > prometheus.yml << 'EOF'
global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: 'aws-ecs'
    static_configs:
      - targets: ['ALB_DNS:80']
    metrics_path: '/metrics'
    scrape_interval: 30s

  - job_name: 'gcp-cloud-run'
    static_configs:
      - targets: ['SERVICE_URL']
    metrics_path: '/metrics'
    scrape_interval: 30s

  - job_name: 'node-exporter'
    static_configs:
      - targets: ['localhost:9100']
EOF
```

#### Grafana 대시보드 설정
```bash
# Grafana 대시보드 JSON 생성
cat > grafana-dashboard.json << 'EOF'
{
  "dashboard": {
    "title": "Cloud Container Services Monitoring",
    "panels": [
      {
        "title": "AWS ECS CPU Usage",
        "type": "graph",
        "targets": [
          {
            "expr": "aws_ecs_cpu_utilization",
            "legendFormat": "ECS CPU"
          }
        ]
      },
      {
        "title": "GCP Cloud Run Request Count",
        "type": "graph",
        "targets": [
          {
            "expr": "gcp_cloud_run_request_count",
            "legendFormat": "Cloud Run Requests"
          }
        ]
      }
    ]
  }
}
EOF
```

---

## 📚 참고 자료

### 유용한 명령어
```bash
# AWS ECS 관리
aws ecs list-clusters
aws ecs describe-clusters --clusters CLUSTER_NAME
aws ecs list-services --cluster CLUSTER_NAME
aws ecs describe-services --cluster CLUSTER_NAME --services SERVICE_NAME

# GCP Cloud Run 관리
gcloud run services list --region asia-northeast1
gcloud run services describe SERVICE_NAME --region asia-northeast1
gcloud run services logs read SERVICE_NAME --region asia-northeast1

# 모니터링
aws cloudwatch get-metric-statistics --namespace AWS/ECS --metric-name CPUUtilization
gcloud monitoring metrics list --filter="resource.type=cloud_run_revision"
```

### 문제 해결
1. **ECS 서비스 시작 실패**
   - 태스크 정의 확인: `aws ecs describe-task-definition --task-definition TASK_DEFINITION`
   - 서비스 이벤트 확인: `aws ecs describe-services --cluster CLUSTER_NAME --services SERVICE_NAME`

2. **Cloud Run 배포 실패**
   - 이미지 빌드 로그 확인: `docker build -t IMAGE_NAME .`
   - 서비스 로그 확인: `gcloud run services logs read SERVICE_NAME --region REGION`

3. **로드 밸런서 연결 실패**
   - 보안 그룹 확인: `aws ec2 describe-security-groups --group-ids SG_ID`
   - 타겟 그룹 상태 확인: `aws elbv2 describe-target-health --target-group-arn TARGET_GROUP_ARN`

---

## 🧹 실습 정리

### 자동 정리
```bash
# Day1 클라우드 컨테이너 서비스 실습 자동 정리
cd /home/ec2-user/mcp-cloud-workspace/mcp_cloud/cloud_intermediate/repo/automation/day1
./day1-practice.sh
# 메뉴에서 "정리" 옵션 선택
```

### 수동 정리
```bash
# AWS ECS 리소스 정리
aws ecs update-service --cluster cloud-intermediate-ecs --service cloud-intermediate-service --desired-count 0
aws ecs delete-service --cluster cloud-intermediate-ecs --service cloud-intermediate-service
aws ecs delete-cluster --cluster cloud-intermediate-ecs

# GCP Cloud Run 리소스 정리
gcloud run services delete cloud-intermediate-app --region asia-northeast1

# ALB 정리
aws elbv2 delete-load-balancer --load-balancer-arn ALB_ARN
aws elbv2 delete-target-group --target-group-arn TARGET_GROUP_ARN
```

### 정리 확인
- [ ] ECS 클러스터 삭제 완료
- [ ] Cloud Run 서비스 삭제 완료
- [ ] ALB 및 타겟 그룹 삭제 완료
- [ ] 모니터링 리소스 정리 완료

---

## 🎯 학습 성과 확인

### 실습 완료 체크리스트
- [ ] AWS ECS 태스크 정의 및 서비스 생성 완료
- [ ] GCP Cloud Run 서버리스 컨테이너 배포 완료
- [ ] 클라우드 로드 밸런서 연동 완료
- [ ] 자동 스케일링 설정 완료
- [ ] 클라우드 모니터링 및 로깅 설정 완료

### 다음 단계
- **통합 모니터링 허브** 구축 실습으로 진행
- **Prometheus + Grafana** 기반 모니터링 시스템 구축
- **멀티 클라우드 모니터링** 전략 수립

---

**💡 클라우드 컨테이너 서비스 실습을 통해 AWS ECS와 GCP Cloud Run의 차이점을 이해하고, 각각의 장단점을 파악하세요!**  
**문제가 발생하거나 도움이 필요하시면 실시간으로 지원해드리겠습니다.**