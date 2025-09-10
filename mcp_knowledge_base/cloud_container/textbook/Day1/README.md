# Container 심화 과정 1일차: 컨테이너 기술 심화 및 CI/CD 파이프라인

## 📋 목차
1. [Master 과정과의 연계](#master-과정과의-연계)
2. [컨테이너 기술 심화](#컨테이너-기술-심화)
3. [고급 CI/CD 파이프라인](#고급-cicd-파이프라인)
4. [컨테이너 오케스트레이션 실습](#컨테이너-오케스트레이션-실습)
5. [실습 프로젝트](#실습-프로젝트)

---

## 🔗 Master 과정과의 연계

### Master 과정에서 학습한 내용
- ✅ **Docker 기초**: 컨테이너 이미지 빌드 및 실행
- ✅ **GitHub Actions**: CI/CD 파이프라인 구축
- ✅ **클라우드 배포 기초**: VM 기반 배포
- ✅ **자동 배포 파이프라인**: 테스트 → 빌드 → 배포 자동화

### Container 과정에서 확장하는 내용
- 🚀 **Docker 최적화**: 멀티스테이지 빌드, 보안 강화
- 🚀 **고급 CI/CD**: 환경별 배포, 롤백 전략
- 🚀 **컨테이너 오케스트레이션**: ECS, GKE 실제 배포
- 🚀 **운영 자동화**: 모니터링, 로깅, 알림

### 학습 경로
```
Master 과정 (기초) → Container 과정 (심화)
     ↓                    ↓
VM 기반 배포      →    컨테이너 오케스트레이션
기본 CI/CD       →    고급 배포 전략
단일 서비스      →    마이크로서비스 아키텍처
```

---

## 🐳 컨테이너 기술 심화

### 1. Dockerfile 최적화

#### 멀티스테이지 빌드
```dockerfile
# Build stage
FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

# Production stage
FROM node:18-alpine AS production
WORKDIR /app
COPY --from=builder /app/node_modules ./node_modules
COPY . .
RUN addgroup -g 1001 -S nodejs
RUN adduser -S nextjs -u 1001
USER nextjs
EXPOSE 3000
CMD ["npm", "start"]
```

#### 보안 강화
```dockerfile
# 비루트 사용자로 실행
RUN adduser -D -s /bin/sh appuser
USER appuser

# 최소 권한 원칙
COPY --chown=appuser:appuser . /app
```

### 2. Docker Compose 고급 활용

#### 다중 서비스 구성
```yaml
version: '3.8'
services:
  app:
    build: .
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=production
    depends_on:
      - redis
      - postgres
    networks:
      - app-network

  redis:
    image: redis:7-alpine
    volumes:
      - redis_data:/data
    networks:
      - app-network

  postgres:
    image: postgres:15-alpine
    environment:
      POSTGRES_DB: myapp
      POSTGRES_USER: user
      POSTGRES_PASSWORD: password
    volumes:
      - postgres_data:/var/lib/postgresql/data
    networks:
      - app-network

volumes:
  redis_data:
  postgres_data:

networks:
  app-network:
    driver: bridge
```

---

## 🔄 고급 CI/CD 파이프라인

### 1. 환경별 배포 전략

#### Staging → Production 파이프라인
```yaml
name: Advanced CI/CD Pipeline

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Run tests
        run: |
          npm ci
          npm run test
          npm run test:coverage

  build-and-push:
    needs: test
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main' || github.ref == 'refs/heads/develop'
    steps:
      - uses: actions/checkout@v4
      - name: Build and push Docker image
        run: |
          docker build -t ${{ secrets.DOCKER_HUB_USERNAME }}/myapp:${{ github.sha }} .
          echo ${{ secrets.DOCKER_HUB_PASSWORD }} | docker login -u ${{ secrets.DOCKER_HUB_USERNAME }} --password-stdin
          docker push ${{ secrets.DOCKER_HUB_USERNAME }}/myapp:${{ github.sha }}

  deploy-staging:
    needs: build-and-push
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/develop'
    steps:
      - name: Deploy to Staging
        run: |
          # ECS Staging 배포
          aws ecs update-service --cluster staging-cluster --service myapp-service --force-new-deployment

  deploy-production:
    needs: build-and-push
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    steps:
      - name: Deploy to Production
        run: |
          # ECS Production 배포
          aws ecs update-service --cluster production-cluster --service myapp-service --force-new-deployment
```

### 2. Blue-Green 배포

#### 롤백 전략 포함
```yaml
  blue-green-deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Blue-Green Deployment
        run: |
          # 현재 활성 환경 확인
          CURRENT_ENV=$(aws ecs describe-services --cluster myapp-cluster --services myapp-service --query 'services[0].deployments[0].status' --output text)
          
          if [ "$CURRENT_ENV" = "PRIMARY" ]; then
            # Green 환경으로 배포
            aws ecs update-service --cluster myapp-cluster --service myapp-service --task-definition myapp-green
            # 헬스체크 후 트래픽 전환
            aws elbv2 modify-target-group --target-group-arn $GREEN_TG_ARN --health-check-path /health
          else
            # Blue 환경으로 배포
            aws ecs update-service --cluster myapp-cluster --service myapp-service --task-definition myapp-blue
          fi
```

---

## ☸️ 컨테이너 오케스트레이션 실습

### 1. AWS ECS 고급 설정

#### Fargate 서비스 구성
```json
{
  "family": "myapp-task",
  "networkMode": "awsvpc",
  "requiresCompatibilities": ["FARGATE"],
  "cpu": "512",
  "memory": "1024",
  "executionRoleArn": "arn:aws:iam::ACCOUNT:role/ecsTaskExecutionRole",
  "taskRoleArn": "arn:aws:iam::ACCOUNT:role/ecsTaskRole",
  "containerDefinitions": [
    {
      "name": "myapp",
      "image": "myapp:latest",
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
        }
      ],
      "secrets": [
        {
          "name": "DATABASE_URL",
          "valueFrom": "arn:aws:ssm:region:account:parameter/myapp/database-url"
        }
      ],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/myapp",
          "awslogs-region": "us-west-1",
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
      }
    }
  ]
}
```

### 2. GCP GKE 고급 설정

#### Kubernetes 매니페스트
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp-deployment
  labels:
    app: myapp
spec:
  replicas: 3
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 1
  selector:
    matchLabels:
      app: myapp
  template:
    metadata:
      labels:
        app: myapp
    spec:
      containers:
      - name: myapp
        image: gcr.io/PROJECT_ID/myapp:latest
        ports:
        - containerPort: 3000
        env:
        - name: NODE_ENV
          value: "production"
        - name: DATABASE_URL
          valueFrom:
            secretKeyRef:
              name: myapp-secrets
              key: database-url
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "512Mi"
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
---
apiVersion: v1
kind: Service
metadata:
  name: myapp-service
spec:
  selector:
    app: myapp
  ports:
  - protocol: TCP
    port: 80
    targetPort: 3000
  type: LoadBalancer
---
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: myapp-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: myapp-deployment
  minReplicas: 1
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
```

---

## 🎯 실습 프로젝트

### Master 과정 연계 실습

#### 1. Master 과정 프로젝트 활용
```bash
# Master 과정에서 생성한 actions-demo 프로젝트 사용
git clone https://github.com/your-username/actions-demo.git
cd actions-demo

# Container 과정용 브랜치 생성
git checkout -b container-advanced
```

#### 2. Dockerfile 최적화
```dockerfile
# 기존 Dockerfile을 멀티스테이지 빌드로 최적화
FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

FROM node:18-alpine AS production
WORKDIR /app
COPY --from=builder /app/node_modules ./node_modules
COPY . .
RUN addgroup -g 1001 -S nodejs
RUN adduser -S nextjs -u 1001
USER nextjs
EXPOSE 3000
CMD ["npm", "start"]
```

#### 3. ECS/GKE 배포 스크립트
```bash
# ECS 배포
./scripts/deploy-ecs.sh

# GKE 배포
./scripts/deploy-gke.sh
```

---

## ✅ 실습 체크리스트

- [ ] Master 과정 프로젝트 복제 및 설정
- [ ] Dockerfile 멀티스테이지 빌드로 최적화
- [ ] Docker Compose 다중 서비스 구성
- [ ] GitHub Actions 고급 워크플로우 작성
- [ ] ECS Fargate 서비스 배포
- [ ] GKE 클러스터 배포
- [ ] Blue-Green 배포 전략 구현
- [ ] 헬스체크 및 모니터링 설정

---

## 📚 다음 단계

다음 단계: [2일차: 고가용성 아키텍처 설계 및 모니터링 실습](../Day2/README.md)
