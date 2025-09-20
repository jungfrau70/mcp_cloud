# Cloud Master - 2일차: 고급 CI/CD & VM 기반 컨테이너 배포

## 🎯 학습 목표

### 핵심 학습 목표
- **고급 Docker**: 멀티스테이지 빌드, 이미지 최적화, 보안 강화
- **고급 GitHub Actions**: 매트릭스 빌드, 환경별 배포, 시크릿 관리
- **Kubernetes 기초**: 클러스터 관리, Pod, Deployment, Service
- **자동화된 배포**: VM 기반 컨테이너 자동 배포 시스템

### 실습 후 달성할 수 있는 능력
- ✅ 멀티스테이지 빌드로 최적화된 Docker 이미지 생성
- ✅ 고급 GitHub Actions 워크플로우 구축
- ✅ Kubernetes 클러스터에서 애플리케이션 배포
- ✅ 완전 자동화된 VM 배포 파이프라인 구축

### 예상 소요 시간
- **고급 Docker**: 90-120분
- **고급 GitHub Actions**: 90-120분
- **Kubernetes 기초**: 120-150분
- **자동화된 배포**: 90-120분
- **전체 과정**: 6-8시간

---

## 🔧 실습 환경 준비

### 필수 계정
- **AWS 계정**: Free Tier 계정
- **GCP 계정**: Free Tier 계정 ($300 크레딧)
- **GitHub 계정**: 코드 저장소 및 CI/CD

### 필수 도구
- **Docker**: 컨테이너 실행 환경
- **kubectl**: Kubernetes 클러스터 관리
- **AWS CLI**: AWS 서비스 관리
- **GCP CLI**: GCP 서비스 관리

### 환경 설정
```bash
# Docker 설치 확인
docker --version

# kubectl 설치 확인
kubectl version --client

# AWS CLI 설치 확인
aws --version

# GCP CLI 설치 확인
gcloud --version
```

---

## 📚 이론 학습

<details>
<summary>🐳 고급 Docker</summary>

### 멀티스테이지 빌드
- **빌드 스테이지**: 의존성 설치 및 빌드
- **런타임 스테이지**: 최종 실행 이미지

### 멀티스테이지 Dockerfile 예시
```dockerfile
# 빌드 스테이지
FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

# 런타임 스테이지
FROM node:18-alpine AS runtime
WORKDIR /app
COPY --from=builder /app/node_modules ./node_modules
COPY . .
EXPOSE 3000
CMD ["node", "app.js"]
```

### 이미지 최적화
```dockerfile
# Alpine Linux 사용
FROM node:18-alpine

# 불필요한 패키지 제거
RUN apk del build-dependencies

# 레이어 최적화
COPY package*.json ./
RUN npm ci --only=production && npm cache clean --force
```

</details>

<details>
<summary>⚡ 고급 GitHub Actions</summary>

### 매트릭스 빌드
```yaml
strategy:
  matrix:
    node-version: [16, 18, 20]
    os: [ubuntu-latest, windows-latest, macos-latest]
```

### 환경별 배포
```yaml
jobs:
  deploy:
    runs-on: ubuntu-latest
    environment: ${{ github.ref == 'refs/heads/main' && 'production' || 'staging' }}
    steps:
    - name: Deploy to ${{ github.ref == 'refs/heads/main' && 'Production' || 'Staging' }}
      run: echo "Deploying to ${{ github.ref == 'refs/heads/main' && 'Production' || 'Staging' }}"
```

### 시크릿 관리
```yaml
- name: Deploy
  env:
    AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
    AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
  run: aws s3 sync ./dist s3://my-bucket
```

</details>

<details>
<summary>☸️ Kubernetes 기초</summary>

### 핵심 개념
- **Pod**: 가장 작은 배포 단위
- **Deployment**: Pod의 복제본 관리
- **Service**: Pod에 대한 네트워크 접근 제공
- **Namespace**: 리소스 격리

### 기본 명령어
```bash
# 클러스터 정보 확인
kubectl cluster-info

# 노드 목록 확인
kubectl get nodes

# Pod 목록 확인
kubectl get pods

# 서비스 목록 확인
kubectl get services
```

### Deployment 예시
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: my-app
  template:
    metadata:
      labels:
        app: my-app
    spec:
      containers:
      - name: my-app
        image: my-app:latest
        ports:
        - containerPort: 3000
```

</details>

<details>
<summary>🚀 자동화된 배포</summary>

### 배포 전략
- **Blue-Green**: 무중단 배포
- **Rolling**: 점진적 배포
- **Canary**: 점진적 트래픽 전환

### CI/CD 파이프라인
```yaml
name: Deploy to VM
on:
  push:
    branches: [ main ]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    - name: Deploy to VM
      uses: appleboy/ssh-action@v0.1.5
      with:
        host: ${{ secrets.VM_HOST }}
        username: ${{ secrets.VM_USERNAME }}
        key: ${{ secrets.VM_SSH_KEY }}
        script: |
          cd /opt/my-app
          git pull origin main
          docker-compose down
          docker-compose up -d --build
```

</details>

---

## 🛠️ 실습 학습

> 📚 **상세 실습 가이드**: 각 주제별 상세한 실습은 다음 파일들을 참조하세요.
> - [고급 Docker 실습](cloud_master/textbook/Day2/practices/docker-advanced.md)
> - [고급 CI/CD 실습](cloud_master/textbook/Day2/practices/cicd-advanced.md)
> - [Kubernetes 기초 실습](cloud_master/textbook/Day2/practices/kubernetes-basics.md)
> - [컨테이너 오케스트레이션 실습](cloud_master/textbook/Day2/practices/container-orchestration.md)

> 🚀 **자동화 스크립트**: 실습을 더 쉽게 하려면 다음 자동화 스크립트를 사용하세요.
> - [AWS 설정 도우미](cloud_master/repos/cloud-scripts/aws-setup-helper.sh) - AWS 환경 자동 설정
> - [GCP 설정 도우미](cloud_master/repos/cloud-scripts/gcp-setup-helper.sh) - GCP 환경 자동 설정
> - [Kubernetes 클러스터 자동 생성](cloud_master/repos/cloud-scripts/k8s-cluster-create.sh) - K8s 클러스터 자동 생성
> - [Kubernetes 애플리케이션 자동 배포](cloud_master/repos/cloud-scripts/k8s-app-deploy.sh) - K8s 앱 자동 배포
> - [리소스 정리 스크립트](cloud_master/repos/cloud-scripts/README.md) - 생성된 리소스 자동 정리

<details>
<summary>🐳 고급 Docker 실습</summary>

### 1단계: 멀티스테이지 빌드
```bash
# 프로젝트 디렉토리 생성
mkdir advanced-docker-practice
cd advanced-docker-practice

# 멀티스테이지 Dockerfile 생성
cat > Dockerfile << EOF
# 빌드 스테이지
FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

# 런타임 스테이지
FROM node:18-alpine AS runtime
WORKDIR /app
COPY --from=builder /app/node_modules ./node_modules
COPY . .
EXPOSE 3000
CMD ["node", "app.js"]
EOF

# 이미지 빌드
docker build -t my-optimized-app .
```

### 2단계: 이미지 최적화
```bash
# 이미지 크기 비교
docker images

# 이미지 분석
docker history my-optimized-app

# 보안 스캔
docker scan my-optimized-app
```

### 3단계: Docker Compose
```bash
# docker-compose.yml 생성
cat > docker-compose.yml << EOF
version: '3.8'
services:
  app:
    build: .
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=production
    restart: unless-stopped
EOF

# 서비스 실행
docker-compose up -d
```

</details>

<details>
<summary>⚡ 고급 GitHub Actions 실습</summary>

### 1단계: 매트릭스 빌드
```bash
# .github/workflows/matrix.yml 생성
cat > .github/workflows/matrix.yml << EOF
name: Matrix Build
on:
  push:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        node-version: [16, 18, 20]
    steps:
    - uses: actions/checkout@v3
    - name: Setup Node.js \${{ matrix.node-version }}
      uses: actions/setup-node@v3
      with:
        node-version: \${{ matrix.node-version }}
    - name: Install dependencies
      run: npm install
    - name: Run tests
      run: npm test
EOF
```

### 2단계: 환경별 배포
```bash
# .github/workflows/deploy.yml 생성
cat > .github/workflows/deploy.yml << EOF
name: Deploy
on:
  push:
    branches: [ main, develop ]

jobs:
  deploy:
    runs-on: ubuntu-latest
    environment: \${{ github.ref == 'refs/heads/main' && 'production' || 'staging' }}
    steps:
    - uses: actions/checkout@v3
    - name: Deploy to \${{ github.ref == 'refs/heads/main' && 'Production' || 'Staging' }}
      run: echo "Deploying to \${{ github.ref == 'refs/heads/main' && 'Production' || 'Staging' }}"
EOF
```

### 3단계: 시크릿 설정
1. GitHub 저장소의 Settings > Secrets and variables > Actions
2. 다음 시크릿 추가:
   - `AWS_ACCESS_KEY_ID`
   - `AWS_SECRET_ACCESS_KEY`
   - `VM_HOST`
   - `VM_USERNAME`
   - `VM_SSH_KEY`

</details>

<details>
<summary>☸️ Kubernetes 실습</summary>

### 1단계: 클러스터 설정

**방법 1: 자동화 스크립트 사용 (권장)**
```bash
# Kubernetes 클러스터 자동 생성
chmod +x cloud_master/repos/cloud-scripts/k8s-cluster-create.sh
./cloud_master/repos/cloud-scripts/k8s-cluster-create.sh
```

**방법 2: 수동 명령어 실행**
```bash
# GKE 클러스터 생성
gcloud container clusters create my-cluster \
  --zone=us-central1-a \
  --num-nodes=3 \
  --machine-type=e2-micro

# 클러스터 연결
gcloud container clusters get-credentials my-cluster --zone=us-central1-a
```

### 2단계: 애플리케이션 배포

**방법 1: 자동화 스크립트 사용 (권장)**
```bash
# Kubernetes 애플리케이션 자동 배포
chmod +x cloud_master/repos/cloud-scripts/k8s-app-deploy.sh
./cloud_master/repos/cloud-scripts/k8s-app-deploy.sh
```

**방법 2: 수동 명령어 실행**
```bash
# Deployment 생성
cat > deployment.yaml << EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: my-app
  template:
    metadata:
      labels:
        app: my-app
    spec:
      containers:
      - name: my-app
        image: my-app:latest
        ports:
        - containerPort: 3000
EOF

kubectl apply -f deployment.yaml
```

### 3단계: 서비스 생성
```bash
# Service 생성
cat > service.yaml << EOF
apiVersion: v1
kind: Service
metadata:
  name: my-app-service
spec:
  selector:
    app: my-app
  ports:
  - port: 80
    targetPort: 3000
  type: LoadBalancer
EOF

kubectl apply -f service.yaml
```

</details>

<details>
<summary>🚀 자동화된 배포 실습</summary>

### 1단계: VM 준비
```bash
# AWS EC2 인스턴스 생성
aws ec2 run-instances \
  --image-id ami-0abcdef1234567890 \
  --instance-type t2.micro \
  --key-name my-key \
  --security-group-ids sg-12345678

# GCP Compute Engine 인스턴스 생성
gcloud compute instances create my-vm \
  --zone=us-central1-a \
  --machine-type=e2-micro \
  --image-family=ubuntu-2004-lts \
  --image-project=ubuntu-os-cloud
```

### 2단계: 배포 스크립트 생성
```bash
# deploy.sh 생성
cat > deploy.sh << EOF
#!/bin/bash
set -e

echo "Starting deployment..."

# 애플리케이션 디렉토리로 이동
cd /opt/my-app

# 최신 코드 가져오기
git pull origin main

# Docker 이미지 빌드
docker build -t my-app:latest .

# 기존 컨테이너 중지
docker-compose down

# 새 컨테이너 시작
docker-compose up -d --build

echo "Deployment completed successfully!"
EOF

chmod +x deploy.sh
```

### 3단계: GitHub Actions 워크플로우
```bash
# .github/workflows/deploy-vm.yml 생성
cat > .github/workflows/deploy-vm.yml << EOF
name: Deploy to VM
on:
  push:
    branches: [ main ]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    - name: Deploy to VM
      uses: appleboy/ssh-action@v0.1.5
      with:
        host: \${{ secrets.VM_HOST }}
        username: \${{ secrets.VM_USERNAME }}
        key: \${{ secrets.VM_SSH_KEY }}
        script: |
          cd /opt/my-app
          ./deploy.sh
EOF
```

</details>

---

## 🧹 실습 정리

### 자동 정리
```bash
# Docker 리소스 정리
docker-compose down
docker system prune -a

# Kubernetes 리소스 정리
kubectl delete deployment my-app
kubectl delete service my-app-service

# AWS 리소스 정리
aws ec2 terminate-instances --instance-ids i-1234567890abcdef0

# GCP 리소스 정리
gcloud container clusters delete my-cluster --zone=us-central1-a
gcloud compute instances delete my-vm --zone=us-central1-a
```

### 수동 정리
- [ ] Docker 컨테이너 및 이미지 정리
- [ ] Kubernetes 클러스터 삭제
- [ ] AWS EC2 인스턴스 종료
- [ ] GCP Compute Engine 인스턴스 삭제
- [ ] GitHub Actions 워크플로우 정리

---

## 📚 참고 자료

### 상세 가이드
- [종합 실습 가이드](cloud_master/textbook/Day2/guides/comprehensive-practice-guide.md) - 전체 과정 통합 실습
- [모니터링 가이드](cloud_master/textbook/Day2/guides/monitoring-guide.md) - 클라우드 모니터링 설정
- [비용 최적화 가이드](cloud_master/textbook/Day2/guides/cost-optimization-guide.md) - 클라우드 비용 관리
- [트러블슈팅 가이드](cloud_master/textbook/Day2/guides/troubleshooting-guide.md) - 문제 해결 및 디버깅

### 공식 문서
- [Docker 멀티스테이지 빌드](https://docs.docker.com/develop/dev-best-practices/dockerfile_best-practices/#use-multi-stage-builds)
- [GitHub Actions 매트릭스](https://docs.github.com/en/actions/using-jobs/using-a-matrix-for-your-jobs)
- [Kubernetes 공식 문서](https://kubernetes.io/docs/)
- [AWS EKS 공식 문서](https://docs.aws.amazon.com/eks/)
- [GCP GKE 공식 문서](https://cloud.google.com/kubernetes-engine/docs)

### 문제 해결
1. **멀티스테이지 빌드 실패**: 의존성 및 빌드 순서 확인
2. **GitHub Actions 매트릭스 실패**: 매트릭스 설정 및 의존성 확인
3. **Kubernetes 배포 실패**: 매니페스트 파일 문법 및 리소스 확인
4. **자동 배포 실패**: SSH 키 및 권한 설정 확인

---

<div align="center">

[← 이전: Day 1](cloud_master/textbook/Day1/README.md) | 
[📚 전체 커리큘럼](curriculum.md) | 
[🏠 학습 경로로 돌아가기](index.md) | 
[다음: Day 3 →](cloud_master/textbook/Day3/README.md)

</div>