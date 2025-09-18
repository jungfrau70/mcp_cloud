# My App - 고급 Docker 및 Kubernetes 애플리케이션

## 🎯 프로젝트 개요

이 프로젝트는 Day2에서 학습하는 고급 Docker 기법과 Kubernetes를 활용한 웹 애플리케이션입니다.

### 주요 기능
- **멀티스테이지 빌드**: 최적화된 Docker 이미지 생성
- **Kubernetes 배포**: Pod, Service, Deployment 관리
- **고급 CI/CD**: GitHub Actions를 통한 자동화
- **모니터링**: Prometheus, Grafana 통합

## 🏗️ 아키텍처

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Frontend      │    │   Backend       │    │   Database      │
│   (React)       │◄──►│   (Node.js)     │◄──►│   (PostgreSQL)  │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Nginx         │    │   Kubernetes    │    │   Monitoring    │
│   (Load Balancer)│    │   (Orchestration)│    │   (Prometheus)  │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## 🚀 시작하기

### 필수 요구사항
- Docker 20.10+
- Docker Compose 2.0+
- Kubernetes 1.20+
- kubectl 1.20+

### 설치 및 실행

#### 1. 프로젝트 클론
```bash
git clone <repository-url>
cd my-app
```

#### 2. Docker Compose로 로컬 실행
```bash
# 개발 환경 실행
docker-compose -f docker-compose.dev.yml up -d

# 프로덕션 환경 실행
docker-compose -f docker-compose.prod.yml up -d
```

#### 3. Kubernetes로 배포
```bash
# 네임스페이스 생성
kubectl create namespace my-app

# 애플리케이션 배포
kubectl apply -f k8s/ -n my-app

# 상태 확인
kubectl get all -n my-app
```

## 📁 프로젝트 구조

```
my-app/
├── frontend/                 # React 프론트엔드
│   ├── src/
│   ├── public/
│   ├── Dockerfile
│   └── package.json
├── backend/                  # Node.js 백엔드
│   ├── src/
│   ├── Dockerfile
│   └── package.json
├── database/                 # PostgreSQL 데이터베이스
│   ├── init.sql
│   └── Dockerfile
├── k8s/                      # Kubernetes 매니페스트
│   ├── namespace.yaml
│   ├── configmap.yaml
│   ├── secret.yaml
│   ├── deployment.yaml
│   ├── service.yaml
│   └── ingress.yaml
├── monitoring/               # 모니터링 설정
│   ├── prometheus.yml
│   ├── grafana/
│   └── alertmanager.yml
├── docker-compose.dev.yml    # 개발 환경
├── docker-compose.prod.yml   # 프로덕션 환경
└── README.md
```

## 🔧 고급 Docker 기법

### 멀티스테이지 빌드
```dockerfile
# backend/Dockerfile
# Build stage
FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

# Production stage
FROM node:18-alpine AS production
WORKDIR /app
COPY --from=builder /app/node_modules ./node_modules
COPY src/ ./src/
EXPOSE 3000
CMD ["node", "src/index.js"]
```

### 이미지 최적화
```dockerfile
# frontend/Dockerfile
FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

FROM nginx:alpine AS production
COPY --from=builder /app/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/nginx.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

## ☸️ Kubernetes 배포

### Deployment
```yaml
# k8s/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app-backend
  namespace: my-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: my-app-backend
  template:
    metadata:
      labels:
        app: my-app-backend
    spec:
      containers:
      - name: backend
        image: my-app-backend:latest
        ports:
        - containerPort: 3000
        env:
        - name: DATABASE_URL
          valueFrom:
            secretKeyRef:
              name: my-app-secret
              key: database-url
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "512Mi"
            cpu: "500m"
```

### Service
```yaml
# k8s/service.yaml
apiVersion: v1
kind: Service
metadata:
  name: my-app-backend-service
  namespace: my-app
spec:
  selector:
    app: my-app-backend
  ports:
  - port: 80
    targetPort: 3000
  type: ClusterIP
```

## 📊 모니터링 설정

### Prometheus 설정
```yaml
# monitoring/prometheus.yml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'my-app-backend'
    static_configs:
      - targets: ['my-app-backend-service:80']
    metrics_path: /metrics
    scrape_interval: 5s
```

### Grafana 대시보드
```json
{
  "dashboard": {
    "title": "My App Dashboard",
    "panels": [
      {
        "title": "Request Rate",
        "type": "graph",
        "targets": [
          {
            "expr": "rate(http_requests_total[5m])",
            "legendFormat": "{{instance}}"
          }
        ]
      }
    ]
  }
}
```

## 🚀 CI/CD 파이프라인

### GitHub Actions 워크플로우
```yaml
# .github/workflows/deploy.yml
name: Deploy to Kubernetes

on:
  push:
    branches: [main]

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    
    - name: Build Docker images
      run: |
        docker build -t my-app-backend:latest ./backend
        docker build -t my-app-frontend:latest ./frontend
    
    - name: Deploy to Kubernetes
      run: |
        kubectl apply -f k8s/ -n my-app
        kubectl rollout restart deployment/my-app-backend -n my-app
```

## 🧪 테스트

### 단위 테스트
```bash
# 백엔드 테스트
cd backend
npm test

# 프론트엔드 테스트
cd frontend
npm test
```

### 통합 테스트
```bash
# Docker Compose 테스트
docker-compose -f docker-compose.test.yml up --abort-on-container-exit

# Kubernetes 테스트
kubectl run test-pod --image=busybox --rm -it --restart=Never -- wget -qO- http://my-app-backend-service
```

## 📚 학습 목표 달성

이 프로젝트를 통해 다음을 학습할 수 있습니다:

1. **Docker 고급 기법**
   - 멀티스테이지 빌드
   - 이미지 최적화
   - 보안 강화

2. **Kubernetes 기초**
   - Pod, Service, Deployment 관리
   - ConfigMap, Secret 사용
   - 리소스 제한 및 요청

3. **고급 CI/CD**
   - GitHub Actions 워크플로우
   - 자동 배포 파이프라인
   - 환경별 배포 전략

4. **모니터링 및 로깅**
   - Prometheus 메트릭 수집
   - Grafana 대시보드 구성
   - 중앙화된 로그 관리

## 🔗 관련 자료

- [Docker 공식 문서](https://docs.docker.com/)
- [Kubernetes 공식 문서](https://kubernetes.io/docs/)
- [Prometheus 공식 문서](https://prometheus.io/docs/)
- [Grafana 공식 문서](https://grafana.com/docs/)
