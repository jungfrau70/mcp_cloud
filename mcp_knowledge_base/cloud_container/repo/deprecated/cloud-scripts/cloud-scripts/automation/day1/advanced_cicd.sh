#!/bin/bash
# 고급 CI/CD 파이프라인 실습 스크립트

set -e

echo "고급 CI/CD 파이프라인 실습 시작..."

# GitHub Actions 워크플로우 생성
mkdir -p .github/workflows

# Multi-stage 배포 파이프라인
cat > .github/workflows/advanced-cicd.yml << 'EOF'
name: Advanced CI/CD Pipeline

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
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup Node.js
      uses: actions/setup-node@v3
      with:
        node-version: '18'
        cache: 'npm'
    
    - name: Install dependencies
      run: npm ci
    
    - name: Run tests
      run: npm test
    
    - name: Run linting
      run: npm run lint
    
    - name: Run security scan
      run: npm audit --audit-level moderate

  build:
    needs: test
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    
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
      uses: docker/build-push-action@v4
      with:
        context: .
        platforms: linux/amd64,linux/arm64
        push: true
        tags: ${{ steps.meta.outputs.tags }}
        labels: ${{ steps.meta.outputs.labels }}
        cache-from: type=gha
        cache-to: type=gha,mode=max

  deploy-dev:
    needs: build
    runs-on: ubuntu-latest
    environment: development
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Deploy to Development
      run: |
        echo "Deploying to development environment..."
        # GKE 배포
        gcloud container clusters get-credentials dev-cluster --zone=us-central1-a
        kubectl set image deployment/app-deployment app=${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:develop
        kubectl rollout status deployment/app-deployment
    
    - name: Run smoke tests
      run: |
        echo "Running smoke tests..."
        # 스모크 테스트 실행
        curl -f http://dev.example.com/health || exit 1

  deploy-staging:
    needs: deploy-dev
    runs-on: ubuntu-latest
    environment: staging
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Deploy to Staging
      run: |
        echo "Deploying to staging environment..."
        # ECS 배포
        aws ecs update-service           --cluster staging-cluster           --service app-service           --force-new-deployment
    
    - name: Run integration tests
      run: |
        echo "Running integration tests..."
        # 통합 테스트 실행
        npm run test:integration

  deploy-production:
    needs: deploy-staging
    runs-on: ubuntu-latest
    environment: production
    if: github.ref == 'refs/heads/main'
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Deploy to Production
      run: |
        echo "Deploying to production environment..."
        # Blue-Green 배포
        kubectl apply -f k8s/production/
        kubectl rollout status deployment/app-deployment
    
    - name: Run production tests
      run: |
        echo "Running production tests..."
        # 프로덕션 테스트 실행
        npm run test:production
    
    - name: Notify deployment
      uses: 8398a7/action-slack@v3
      with:
        status: ${{ job.status }}
        channel: '#deployments'
        webhook_url: ${{ secrets.SLACK_WEBHOOK }}
EOF

# GitOps 설정
cat > argocd-app.yaml << 'EOF'
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: container-course-app
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/your-org/container-course
    targetRevision: HEAD
    path: k8s
  destination:
    server: https://kubernetes.default.svc
    namespace: container-course
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
    - CreateNamespace=true
EOF

# Helm 차트 생성
mkdir -p helm-chart/templates

cat > helm-chart/Chart.yaml << 'EOF'
apiVersion: v2
name: container-course
description: Container Course Application
type: application
version: 0.1.0
appVersion: "1.0.0"
EOF

cat > helm-chart/values.yaml << 'EOF'
replicaCount: 3

image:
  repository: nginx
  tag: "1.21"
  pullPolicy: IfNotPresent

service:
  type: LoadBalancer
  port: 80

ingress:
  enabled: true
  className: "nginx"
  annotations: {}
  hosts:
    - host: container-course.local
      paths:
        - path: /
          pathType: Prefix
  tls: []

resources:
  limits:
    cpu: 500m
    memory: 512Mi
  requests:
    cpu: 250m
    memory: 256Mi

autoscaling:
  enabled: true
  minReplicas: 3
  maxReplicas: 10
  targetCPUUtilizationPercentage: 80
  targetMemoryUtilizationPercentage: 80
EOF

cat > helm-chart/templates/deployment.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "container-course.fullname" . }}
  labels:
    {{- include "container-course.labels" . | nindent 4 }}
spec:
  replicas: {{ .Values.replicaCount }}
  selector:
    matchLabels:
      {{- include "container-course.selectorLabels" . | nindent 6 }}
  template:
    metadata:
      labels:
        {{- include "container-course.selectorLabels" . | nindent 8 }}
    spec:
      containers:
        - name: {{ .Chart.Name }}
          image: "{{ .Values.image.repository }}:{{ .Values.image.tag | default .Chart.AppVersion }}"
          imagePullPolicy: {{ .Values.image.pullPolicy }}
          ports:
            - name: http
              containerPort: 80
              protocol: TCP
          livenessProbe:
            httpGet:
              path: /
              port: http
          readinessProbe:
            httpGet:
              path: /
              port: http
          resources:
            {{- toYaml .Values.resources | nindent 12 }}
EOF

# Dockerfile 생성
cat > Dockerfile << 'EOF'
# Multi-stage build
FROM node:18-alpine AS builder

WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

FROM nginx:1.21-alpine AS production

COPY --from=builder /app /usr/share/nginx/html
COPY nginx.conf /etc/nginx/nginx.conf

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
EOF

# nginx 설정
cat > nginx.conf << 'EOF'
events {
    worker_connections 1024;
}

http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;
    
    upstream backend {
        server app:3000;
    }
    
    server {
        listen 80;
        server_name localhost;
        
        location / {
            proxy_pass http://backend;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
        }
        
        location /health {
            access_log off;
            return 200 "healthy\n";
            add_header Content-Type text/plain;
        }
    }
}
EOF

echo "고급 CI/CD 파이프라인 실습 완료!"
