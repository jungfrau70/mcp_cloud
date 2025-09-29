#!/bin/bash

# Cloud Intermediate Day 2 실습 스크립트
# CI/CD 파이프라인, 클라우드 배포, 모니터링 기초

# 오류 처리 설정
set -e
set -u
set -o pipefail

# 사용법 출력
usage() {
    echo "Cloud Intermediate Day 2 실습 스크립트"
    echo ""
    echo "사용법:"
    echo "  $0 [옵션]                    # Interactive 모드"
    echo "  $0 --action <액션> [파라미터] # Parameter 모드"
    echo ""
    echo "Interactive 모드 옵션:"
    echo "  --interactive, -i           # Interactive 모드 (기본값)"
    echo "  --help, -h                   # 도움말 표시"
    echo ""
    echo "Parameter 모드 액션:"
    echo "  --action cicd-pipeline      # CI/CD 파이프라인 실습"
    echo "  --action cloud-deployment   # 클라우드 배포 실습"
    echo "  --action monitoring-basics  # 모니터링 기초 실습"
    echo "  --action all                # 전체 실습 실행"
    echo ""
    echo "예시:"
    echo "  $0                          # Interactive 모드"
    echo "  $0 --action cicd-pipeline   # CI/CD 파이프라인만 실행"
    echo "  $0 --action all             # 전체 실습 실행"
}

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

# 로그 함수들
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_header() { echo -e "${PURPLE}=== $1 ===${NC}"; }

# CI/CD 파이프라인 실습
cicd_pipeline_practice() {
    log_header "CI/CD 파이프라인 실습"
    
    local practice_dir="day2-cicd-pipeline"
    mkdir -p "$practice_dir"
    cd "$practice_dir"
    
    # 1. GitHub Actions 워크플로우 생성
    log_info "1. GitHub Actions 워크플로우 생성"
    mkdir -p .github/workflows
    
    cat > .github/workflows/ci-cd.yml << 'EOF'
name: CI/CD Pipeline

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

env:
  REGISTRY: ghcr.io
  IMAGE_NAME: ${{ github.repository }}

jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        node-version: [16, 18, 20]
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup Node.js ${{ matrix.node-version }}
      uses: actions/setup-node@v3
      with:
        node-version: ${{ matrix.node-version }}
        cache: 'npm'
    
    - name: Install dependencies
      run: npm ci
    
    - name: Run tests
      run: npm test
    
    - name: Run linting
      run: npm run lint
    
    - name: Run security audit
      run: npm audit --audit-level moderate

  build:
    needs: test
    runs-on: ubuntu-latest
    outputs:
      image: ${{ steps.image.outputs.image }}
      digest: ${{ steps.build.outputs.digest }}
    steps:
    - uses: actions/checkout@v3
    
    - name: Set up Docker Buildx
      uses: docker/setup-buildx-action@v2
    
    - name: Log in to Container Registry
      uses: docker/login-action@v2
      with:
        registry: ${{ env.REGISTRY }}
        username: ${{ github.actor }}
        password: ${{ secrets.GITHUB_TOKEN }}
    
    - name: Extract metadata
      id: meta
      uses: docker/metadata-action@v4
      with:
        images: ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}
        tags: |
          type=ref,event=branch
          type=ref,event=pr
          type=sha,prefix={{branch}}-
          type=raw,value=latest,enable={{is_default_branch}}
    
    - name: Build and push Docker image
      id: build
      uses: docker/build-push-action@v4
      with:
        context: .
        push: true
        tags: ${{ steps.meta.outputs.tags }}
        labels: ${{ steps.meta.outputs.labels }}
        cache-from: type=gha
        cache-to: type=gha,mode=max
    
    - name: Output image
      id: image
      run: echo "image=${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:${{ github.sha }}" >> $GITHUB_OUTPUT

  security-scan:
    needs: build
    runs-on: ubuntu-latest
    steps:
    - name: Run Trivy vulnerability scanner
      uses: aquasecurity/trivy-action@master
      with:
        image-ref: ${{ needs.build.outputs.image }}
        format: 'sarif'
        output: 'trivy-results.sarif'
    
    - name: Upload Trivy scan results to GitHub Security tab
      uses: github/codeql-action/upload-sarif@v2
      with:
        sarif_file: 'trivy-results.sarif'

  deploy-staging:
    needs: [build, security-scan]
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/develop'
    environment: staging
    steps:
    - name: Deploy to Staging
      run: |
        echo "Deploying to staging environment"
        # Add your staging deployment commands here

  deploy-production:
    needs: [build, security-scan]
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    environment: production
    steps:
    - name: Deploy to Production
      run: |
        echo "Deploying to production environment"
        # Add your production deployment commands here
EOF

    # 2. Dockerfile 생성
    cat > Dockerfile << 'EOF'
FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production && npm cache clean --force
COPY . .

FROM node:18-alpine AS runtime
WORKDIR /app
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nextjs -u 1001
COPY --from=builder --chown=nextjs:nodejs /app/node_modules ./node_modules
COPY --from=builder --chown=nextjs:nodejs /app ./
USER nextjs
EXPOSE 3000
CMD ["npm", "start"]
EOF

    # 3. package.json 생성
    cat > package.json << 'EOF'
{
  "name": "cicd-practice-app",
  "version": "1.0.0",
  "description": "CI/CD Practice Application",
  "main": "index.js",
  "scripts": {
    "start": "node index.js",
    "test": "jest",
    "lint": "eslint ."
  },
  "dependencies": {
    "express": "^4.18.2"
  },
  "devDependencies": {
    "jest": "^29.0.0",
    "eslint": "^8.0.0",
    "supertest": "^6.0.0"
  }
}
EOF

    # 4. 간단한 Express 앱 생성
    cat > index.js << 'EOF'
const express = require('express');
const app = express();
const port = process.env.PORT || 3000;

app.use(express.json());

app.get('/', (req, res) => {
  res.json({ 
    message: 'Hello from CI/CD pipeline!',
    timestamp: new Date().toISOString(),
    version: process.env.npm_package_version || '1.0.0'
  });
});

app.get('/health', (req, res) => {
  res.json({ 
    status: 'healthy', 
    timestamp: new Date().toISOString(),
    uptime: process.uptime()
  });
});

app.get('/info', (req, res) => {
  res.json({
    nodeVersion: process.version,
    platform: process.platform,
    memory: process.memoryUsage(),
    env: process.env.NODE_ENV || 'development'
  });
});

app.listen(port, '0.0.0.0', () => {
  console.log(`App listening at http://0.0.0.0:${port}`);
});

module.exports = app;
EOF

    # 5. 테스트 파일 생성
    cat > index.test.js << 'EOF'
const request = require('supertest');
const app = require('./index');

describe('App', () => {
  test('GET / should return hello message', async () => {
    const response = await request(app).get('/');
    expect(response.status).toBe(200);
    expect(response.body.message).toBe('Hello from CI/CD pipeline!');
  });

  test('GET /health should return health status', async () => {
    const response = await request(app).get('/health');
    expect(response.status).toBe(200);
    expect(response.body.status).toBe('healthy');
  });

  test('GET /info should return app info', async () => {
    const response = await request(app).get('/info');
    expect(response.status).toBe(200);
    expect(response.body.nodeVersion).toBeDefined();
  });
});
EOF

    # 6. ESLint 설정
    cat > .eslintrc.js << 'EOF'
module.exports = {
  env: {
    node: true,
    es2021: true,
    jest: true,
  },
  extends: ['eslint:recommended'],
  parserOptions: {
    ecmaVersion: 12,
    sourceType: 'module',
  },
  rules: {
    'no-console': 'warn',
    'no-unused-vars': 'error',
    'no-undef': 'error',
  },
};
EOF

    # 7. Jest 설정
    cat > jest.config.js << 'EOF'
module.exports = {
  testEnvironment: 'node',
  testMatch: ['**/*.test.js'],
  collectCoverage: true,
  coverageDirectory: 'coverage',
  coverageReporters: ['text', 'lcov'],
  coverageThreshold: {
    global: {
      branches: 80,
      functions: 80,
      lines: 80,
      statements: 80,
    },
  },
};
EOF

    # 8. 로컬 테스트 실행
    log_info "2. 로컬 테스트 실행"
    npm install
    npm test
    npm run lint
    
    # 9. Docker 이미지 빌드 테스트
    log_info "3. Docker 이미지 빌드 테스트"
    docker build -t cicd-practice-app:latest .
    
    # 10. 이미지 실행 테스트
    log_info "4. 이미지 실행 테스트"
    docker run -d -p 3001:3000 --name cicd-test cicd-practice-app:latest
    sleep 5
    curl -f http://localhost:3001/health || log_warning "헬스 체크 실패"
    docker stop cicd-test
    docker rm cicd-test
    
    log_info "5. GitHub 저장소에 푸시하여 워크플로우를 실행하세요"
    log_success "CI/CD 파이프라인 실습 완료"
    cd ..
}

# 클라우드 배포 실습
cloud_deployment_practice() {
    log_header "클라우드 배포 실습"
    
    local practice_dir="day2-cloud-deployment"
    mkdir -p "$practice_dir"
    cd "$practice_dir"
    
    # AWS ECS 배포 실습
    log_info "1. AWS ECS 배포 실습"
    if command -v aws &> /dev/null; then
        # ECS 클러스터 생성 (시뮬레이션)
        log_info "ECS 클러스터 생성 (시뮬레이션)"
        cat > task-definition.json << 'EOF'
{
  "family": "myapp-task",
  "networkMode": "awsvpc",
  "requiresCompatibilities": ["FARGATE"],
  "cpu": "256",
  "memory": "512",
  "executionRoleArn": "arn:aws:iam::123456789012:role/ecsTaskExecutionRole",
  "taskRoleArn": "arn:aws:iam::123456789012:role/ecsTaskRole",
  "containerDefinitions": [
    {
      "name": "myapp",
      "image": "nginx:1.21",
      "portMappings": [
        {
          "containerPort": 80,
          "protocol": "tcp"
        }
      ],
      "essential": true,
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/myapp",
          "awslogs-region": "us-west-2",
          "awslogs-stream-prefix": "ecs"
        }
      },
      "healthCheck": {
        "command": ["CMD-SHELL", "curl -f http://localhost:80/ || exit 1"],
        "interval": 30,
        "timeout": 5,
        "retries": 3
      }
    }
  ]
}
EOF
        
        # ECS 서비스 생성 스크립트
        cat > create-ecs-service.sh << 'EOF'
#!/bin/bash

# ECS 클러스터 생성
aws ecs create-cluster \
  --cluster-name my-ecs-cluster \
  --capacity-providers FARGATE \
  --default-capacity-provider-strategy capacityProvider=FARGATE,weight=1

# 태스크 정의 등록
aws ecs register-task-definition --cli-input-json file://task-definition.json

# 서비스 생성
aws ecs create-service \
  --cluster my-ecs-cluster \
  --service-name myapp-service \
  --task-definition myapp-task:1 \
  --desired-count 2 \
  --launch-type FARGATE \
  --network-configuration "awsvpcConfiguration={subnets=[subnet-12345,subnet-67890],securityGroups=[sg-12345],assignPublicIp=ENABLED}" \
  --load-balancers "targetGroupArn=arn:aws:elasticloadbalancing:us-west-2:123456789012:targetgroup/myapp-tg/1234567890123456,containerName=myapp,containerPort=80"
EOF
        
        chmod +x create-ecs-service.sh
        
        # Application Load Balancer 설정
        cat > create-alb.sh << 'EOF'
#!/bin/bash

# ALB 생성
aws elbv2 create-load-balancer \
  --name myapp-alb \
  --subnets subnet-12345 subnet-67890 \
  --security-groups sg-12345

# 타겟 그룹 생성
aws elbv2 create-target-group \
  --name myapp-tg \
  --protocol HTTP \
  --port 80 \
  --vpc-id vpc-12345 \
  --target-type ip \
  --health-check-path / \
  --health-check-interval-seconds 30 \
  --health-check-timeout-seconds 5 \
  --healthy-threshold-count 2 \
  --unhealthy-threshold-count 3

# 리스너 생성
aws elbv2 create-listener \
  --load-balancer-arn arn:aws:elasticloadbalancing:us-west-2:123456789012:loadbalancer/app/myapp-alb/1234567890123456 \
  --protocol HTTP \
  --port 80 \
  --default-actions Type=forward,TargetGroupArn=arn:aws:elasticloadbalancing:us-west-2:123456789012:targetgroup/myapp-tg/1234567890123456
EOF
        
        chmod +x create-alb.sh
        
        log_info "ECS 배포 스크립트 생성 완료"
    else
        log_warning "AWS CLI가 설치되지 않음"
    fi
    
    # GCP Cloud Run 배포 실습
    log_info "2. GCP Cloud Run 배포 실습"
    if command -v gcloud &> /dev/null; then
        # Cloud Run 서비스 배포 스크립트
        cat > deploy-cloud-run.sh << 'EOF'
#!/bin/bash

# Cloud Run 서비스 배포
gcloud run deploy myapp \
  --image gcr.io/my-project/myapp:latest \
  --platform managed \
  --region us-central1 \
  --allow-unauthenticated \
  --port 3000 \
  --memory 512Mi \
  --cpu 1 \
  --min-instances 0 \
  --max-instances 10 \
  --concurrency 80 \
  --timeout 300 \
  --set-env-vars NODE_ENV=production

# 도메인 매핑
gcloud run domain-mappings create \
  --service myapp \
  --domain myapp.example.com \
  --region us-central1

# SSL 인증서 생성
gcloud compute ssl-certificates create myapp-ssl \
  --domains myapp.example.com \
  --global
EOF
        
        chmod +x deploy-cloud-run.sh
        
        # Cloud Run 서비스 설정 파일
        cat > cloud-run-service.yaml << 'EOF'
apiVersion: serving.knative.dev/v1
kind: Service
metadata:
  name: myapp
  annotations:
    run.googleapis.com/ingress: all
    run.googleapis.com/execution-environment: gen2
spec:
  template:
    metadata:
      annotations:
        autoscaling.knative.dev/maxScale: "10"
        autoscaling.knative.dev/minScale: "0"
        run.googleapis.com/cpu-throttling: "true"
        run.googleapis.com/execution-environment: gen2
    spec:
      containerConcurrency: 80
      timeoutSeconds: 300
      containers:
      - image: gcr.io/my-project/myapp:latest
        ports:
        - containerPort: 3000
        env:
        - name: NODE_ENV
          value: production
        - name: PORT
          value: "3000"
        resources:
          limits:
            cpu: "1"
            memory: "512Mi"
          requests:
            cpu: "0.5"
            memory: "256Mi"
        livenessProbe:
          httpGet:
            path: /health
            port: 3000
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /ready
            port: 3000
          initialDelaySeconds: 5
          periodSeconds: 5
EOF
        
        log_info "Cloud Run 배포 스크립트 생성 완료"
    else
        log_warning "GCP CLI가 설치되지 않음"
    fi
    
    # 배포 자동화 스크립트
    log_info "3. 배포 자동화 스크립트 생성"
    cat > auto-deploy.sh << 'EOF'
#!/bin/bash

# 배포 자동화 스크립트
set -e

echo "Starting automated deployment..."

# 1. Docker 이미지 빌드
echo "Building Docker image..."
docker build -t myapp:$GITHUB_SHA .
docker tag myapp:$GITHUB_SHA myapp:latest

# 2. 이미지 푸시
echo "Pushing to registry..."
docker push myapp:$GITHUB_SHA
docker push myapp:latest

# 3. AWS ECS 배포
if [ "$DEPLOY_TO_AWS" = "true" ]; then
    echo "Deploying to AWS ECS..."
    aws ecs update-service \
      --cluster my-ecs-cluster \
      --service myapp-service \
      --force-new-deployment
fi

# 4. GCP Cloud Run 배포
if [ "$DEPLOY_TO_GCP" = "true" ]; then
    echo "Deploying to GCP Cloud Run..."
    gcloud run deploy myapp \
      --image gcr.io/my-project/myapp:$GITHUB_SHA \
      --region us-central1
fi

echo "Deployment completed successfully!"
EOF
    
    chmod +x auto-deploy.sh
    
    log_success "클라우드 배포 실습 완료"
    cd ..
}

# 모니터링 실습
monitoring_practice() {
    log_header "모니터링 실습"
    
    local practice_dir="day2-monitoring"
    mkdir -p "$practice_dir"
    cd "$practice_dir"
    
    # Prometheus + Grafana 스택 실습
    log_info "1. Prometheus + Grafana 모니터링 스택 실습"
    if [ -f "../scripts/monitoring-stack.sh" ]; then
        log_info "모니터링 스택 설정 중..."
        ../scripts/monitoring-stack.sh setup
        
        # 모니터링 스택 상태 확인
        log_info "모니터링 스택 상태 확인 중..."
        ../scripts/monitoring-stack.sh status
        
        # Prometheus 타겟 확인
        log_info "Prometheus 타겟 상태 확인 중..."
        ../scripts/monitoring-stack.sh targets
        
        # 메트릭 쿼리 테스트
        log_info "메트릭 쿼리 테스트 중..."
        ../scripts/monitoring-stack.sh test
        
        log_success "Prometheus + Grafana 스택 실습 완료"
        log_info "접속 정보:"
        log_info "  Prometheus: http://localhost:9090"
        log_info "  Grafana: http://localhost:3000 [admin/admin]"
        log_info "  Sample App: http://localhost:3001"
    else
        log_warning "monitoring-stack.sh 스크립트를 찾을 수 없습니다."
    fi
    
    # AWS CloudWatch 모니터링
    log_info "2. AWS CloudWatch 모니터링 설정"
    if command -v aws &> /dev/null; then
        # 로그 그룹 생성 스크립트
        cat > setup-cloudwatch.sh << 'EOF'
#!/bin/bash

# CloudWatch 로그 그룹 생성
aws logs create-log-group \
  --log-group-name /aws/ecs/myapp \
  --retention-in-days 30

# 로그 스트림 생성
aws logs create-log-stream \
  --log-group-name /aws/ecs/myapp \
  --log-stream-name myapp-stream

# 커스텀 메트릭 전송
aws cloudwatch put-metric-data \
  --namespace "MyApp/Performance" \
  --metric-data MetricName=ResponseTime,Value=150,Unit=Milliseconds

# 알람 생성
aws cloudwatch put-metric-alarm \
  --alarm-name "High CPU Usage" \
  --alarm-description "Alarm when CPU exceeds 80%" \
  --metric-name CPUUtilization \
  --namespace AWS/ECS \
  --statistic Average \
  --period 300 \
  --threshold 80 \
  --comparison-operator GreaterThanThreshold \
  --evaluation-periods 2 \
  --alarm-actions arn:aws:sns:us-west-2:123456789012:myapp-alerts

# SNS 토픽 생성
aws sns create-topic --name myapp-alerts

# SNS 구독 생성
aws sns subscribe \
  --topic-arn arn:aws:sns:us-west-2:123456789012:myapp-alerts \
  --protocol email \
  --notification-endpoint admin@example.com
EOF
        
        chmod +x setup-cloudwatch.sh
        
        # CloudWatch 대시보드 설정
        cat > cloudwatch-dashboard.json << 'EOF'
{
  "widgets": [
    {
      "type": "metric",
      "x": 0,
      "y": 0,
      "width": 12,
      "height": 6,
      "properties": {
        "metrics": [
          ["AWS/ECS", "CPUUtilization", "ServiceName", "myapp-service", "ClusterName", "my-ecs-cluster"],
          [".", "MemoryUtilization", ".", ".", ".", "."]
        ],
        "view": "timeSeries",
        "stacked": false,
        "region": "us-west-2",
        "title": "ECS Service Metrics",
        "period": 300
      }
    },
    {
      "type": "log",
      "x": 0,
      "y": 6,
      "width": 12,
      "height": 6,
      "properties": {
        "query": "SOURCE '/aws/ecs/myapp' | fields @timestamp, @message\n| filter @message like /ERROR/\n| sort @timestamp desc\n| limit 20",
        "region": "us-west-2",
        "title": "Error Logs",
        "view": "table"
      }
    }
  ]
}
EOF
        
        # 대시보드 생성 스크립트
        cat > create-dashboard.sh << 'EOF'
#!/bin/bash

# CloudWatch 대시보드 생성
aws cloudwatch put-dashboard \
  --dashboard-name "MyApp Dashboard" \
  --dashboard-body file://cloudwatch-dashboard.json

# 대시보드 확인
aws cloudwatch get-dashboard --dashboard-name "MyApp Dashboard"
EOF
        
        chmod +x create-dashboard.sh
        
        log_info "CloudWatch 모니터링 설정 완료"
    else
        log_warning "AWS CLI가 설치되지 않음"
    fi
    
    # GCP Cloud Monitoring 설정
    log_info "3. GCP Cloud Monitoring 설정"
    if command -v gcloud &> /dev/null; then
        # 알림 정책 설정
        cat > alert-policy.yaml << 'EOF'
displayName: "High Error Rate"
conditions:
  - displayName: "Error rate > 5%"
    conditionThreshold:
      filter: "metric.type=\"custom.googleapis.com/error_rate\""
      comparison: COMPARISON_GREATER_THAN
      thresholdValue: 0.05
      duration: "300s"
notificationChannels:
  - "projects/my-project/notificationChannels/1234567890123456789"
EOF
        
        # 알림 정책 생성 스크립트
        cat > setup-gcp-monitoring.sh << 'EOF'
#!/bin/bash

# 커스텀 메트릭 생성
gcloud monitoring metrics-descriptors create \
  --config-from-file=metric-descriptor.yaml

# 메트릭 데이터 전송
gcloud monitoring time-series create \
  --config-from-file=time-series.yaml

# 알림 정책 생성
gcloud alpha monitoring policies create \
  --policy-from-file=alert-policy.yaml
EOF
        
        chmod +x setup-gcp-monitoring.sh
        
        # GCP 대시보드 설정
        cat > gcp-dashboard.json << 'EOF'
{
  "displayName": "MyApp Dashboard",
  "mosaicLayout": {
    "tiles": [
      {
        "width": 6,
        "height": 4,
        "widget": {
          "title": "CPU Usage",
          "xyChart": {
            "dataSets": [
              {
                "timeSeriesQuery": {
                  "timeSeriesFilter": {
                    "filter": "metric.type=\"compute.googleapis.com/instance/cpu/utilization\"",
                    "aggregation": {
                      "alignmentPeriod": "60s",
                      "perSeriesAligner": "ALIGN_MEAN"
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
          "title": "Memory Usage",
          "xyChart": {
            "dataSets": [
              {
                "timeSeriesQuery": {
                  "timeSeriesFilter": {
                    "filter": "metric.type=\"compute.googleapis.com/instance/memory/utilization\"",
                    "aggregation": {
                      "alignmentPeriod": "60s",
                      "perSeriesAligner": "ALIGN_MEAN"
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
        
        # 대시보드 생성 스크립트
        cat > create-gcp-dashboard.sh << 'EOF'
#!/bin/bash

# Cloud Monitoring 대시보드 생성
gcloud monitoring dashboards create \
  --config-from-file=gcp-dashboard.json

# 대시보드 목록 확인
gcloud monitoring dashboards list
EOF
        
        chmod +x create-gcp-dashboard.sh
        
        # 로그 기반 메트릭 설정
        cat > setup-log-metrics.sh << 'EOF'
#!/bin/bash

# 로그 기반 메트릭 생성
gcloud logging metrics create myapp_errors \
  --description="Count of error logs" \
  --log-filter="severity>=ERROR"

# 로그 기반 알림 정책 생성
gcloud alpha monitoring policies create \
  --policy-from-file=log-based-alert-policy.yaml
EOF
        
        chmod +x setup-log-metrics.sh
        
        log_info "Cloud Monitoring 설정 완료"
    else
        log_warning "GCP CLI가 설치되지 않음"
    fi
    
    # 통합 모니터링 스크립트
    log_info "4. 통합 모니터링 스크립트 생성"
    cat > monitoring-check.sh << 'EOF'
#!/bin/bash

# 통합 모니터링 체크 스크립트
echo "=== Monitoring Status Check ==="

# AWS CloudWatch 메트릭 수집
if command -v aws &> /dev/null; then
    echo "AWS CloudWatch Metrics:"
    aws cloudwatch get-metric-statistics \
      --namespace AWS/ECS \
      --metric-name CPUUtilization \
      --dimensions Name=ServiceName,Value=myapp-service \
      --start-time $(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%S) \
      --end-time $(date -u +%Y-%m-%dT%H:%M:%S) \
      --period 300 \
      --statistics Average
fi

# GCP Cloud Monitoring 메트릭 수집
if command -v gcloud &> /dev/null; then
    echo "GCP Cloud Monitoring Metrics:"
    gcloud monitoring time-series list \
      --filter="metric.type=\"compute.googleapis.com/instance/cpu/utilization\"" \
      --interval="1h"
fi

# 알림 상태 확인
echo "Alert Status:"
if command -v aws &> /dev/null; then
    aws cloudwatch describe-alarms --state-value ALARM
fi

if command -v gcloud &> /dev/null; then
    gcloud alpha monitoring policies list --filter="enabled=true"
fi
EOF
    
    chmod +x monitoring-check.sh
    
    log_success "모니터링 실습 완료"
    cd ..
}

# 정리 함수
cleanup_day2() {
    log_header "Day 2 실습 정리"
    
    # 모니터링 스택 정리
    log_info "모니터링 스택 정리"
    if [ -f "scripts/monitoring-stack.sh" ]; then
        scripts/monitoring-stack.sh cleanup
    fi
    
    # Docker 리소스 정리
    log_info "Docker 리소스 정리"
    docker rmi cicd-practice-app:latest 2>/dev/null || true
    
    # 실습 디렉토리 정리
    log_info "실습 디렉토리 정리"
    rm -rf day2-cicd-pipeline
    rm -rf day2-cloud-deployment
    rm -rf day2-monitoring
    
    log_success "Day 2 정리 완료"
}

# 메인 메뉴
show_menu() {
    echo ""
    log_header "Cloud Intermediate Day 2 실습 메뉴"
    echo "1. CI/CD 파이프라인 실습"
    echo "2. 클라우드 배포 실습"
    echo "3. 모니터링 실습"
    echo "4. 전체 Day 2 실습 실행"
    echo "5. 정리"
    echo "6. 종료"
    echo ""
}

# 메인 함수
main() {
    log_header "Cloud Intermediate Day 2 실습 스크립트"
    log_info "CI/CD 파이프라인, 클라우드 배포, 모니터링 기초 실습"
    
    while true; do
        show_menu
        read -p "선택하세요 (1-6): " choice
        
        case $choice in
            1)
                cicd_pipeline_practice
                ;;
            2)
                cloud_deployment_practice
                ;;
            3)
                monitoring_practice
                ;;
            4)
                log_info "전체 Day 2 실습 실행"
                cicd_pipeline_practice
                cloud_deployment_practice
                monitoring_practice
                log_success "전체 Day 2 실습 완료!"
                ;;
            5)
                cleanup_day2
                ;;
            6)
                log_info "프로그램을 종료합니다"
                exit 0
                ;;
            *)
                log_error "잘못된 선택입니다. 1-6 중에서 선택하세요."
                ;;
        esac
        
        echo ""
        read -p "계속하려면 Enter를 누르세요..."
    done
}

# Interactive 모드 메뉴
show_interactive_menu() {
    echo ""
    log_header "Cloud Intermediate Day 2 실습 메뉴"
    echo "1. CI/CD 파이프라인 실습"
    echo "2. 클라우드 배포 실습"
    echo "3. 모니터링 기초 실습"
    echo "4. 전체 Day 2 실습 실행"
    echo "5. 실습 환경 정리"
    echo "6. 종료"
    echo ""
}

# Interactive 모드 실행
run_interactive_mode() {
    log_header "Cloud Intermediate Day 2 실습"
    while true; do
        show_interactive_menu
        read -p "선택하세요 (1-6): " choice
        
        case $choice in
            1)
                cicd_pipeline_practice
                ;;
            2)
                cloud_deployment_practice
                ;;
            3)
                monitoring_practice
                ;;
            4)
                log_info "전체 Day 2 실습 실행"
                cicd_pipeline_practice
                cloud_deployment_practice
                monitoring_practice
                log_success "전체 Day 2 실습 완료!"
                ;;
            5)
                cleanup_day2
                ;;
            6)
                log_info "프로그램을 종료합니다"
                exit 0
                ;;
            *)
                log_error "잘못된 선택입니다. 1-6 중에서 선택하세요."
                ;;
        esac
        
        echo ""
        read -p "계속하려면 Enter를 누르세요..."
    done
}

# Parameter 모드 실행
run_parameter_mode() {
    local action=$1
    shift
    
    case "$action" in
        "cicd-pipeline")
            log_info "CI/CD 파이프라인 실습 실행"
            cicd_pipeline_practice
            ;;
        "cloud-deployment")
            log_info "클라우드 배포 실습 실행"
            cloud_deployment_practice
            ;;
        "monitoring-basics")
            log_info "모니터링 기초 실습 실행"
            monitoring_practice
            ;;
        "all")
            log_info "전체 Day 2 실습 실행"
            cicd_pipeline_practice
            cloud_deployment_practice
            monitoring_practice
            log_success "전체 Day 2 실습 완료!"
            ;;
        *)
            log_error "알 수 없는 액션: $action"
            usage
            exit 1
            ;;
    esac
}

# 메인 함수
main() {
    case "${1:-}" in
        "--help"|"-h")
            usage
            exit 0
            ;;
        "--interactive"|"-i"|"")
            run_interactive_mode
            ;;
        "--action")
            if [ -z "${2:-}" ]; then
                log_error "액션을 지정해주세요."
                usage
                exit 1
            fi
            run_parameter_mode "$2" "$3"
            ;;
        *)
            log_error "알 수 없는 옵션: $1"
            usage
            exit 1
            ;;
    esac
}

# 스크립트 실행
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
