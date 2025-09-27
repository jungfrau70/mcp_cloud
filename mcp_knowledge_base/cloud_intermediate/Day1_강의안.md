# Cloud Intermediate - 1일차 강의안

> 📋 **강의 일시**: 2024년 10월 1일 ["수"] 9:00~17:00  
> 📋 **강의 방식**: 온라인 실습 중심  
> 📋 **선수 학습**: Cloud Basic 완료 ["AWS/GCP 기초 서비스"]  
> 📋 **실습 작업 환경 설정**: [_setup_/README.md](cloud_intermediate/_setup_/README.md)
> 📋 **실습 코드**: 
> - **Git Repository**: `git clone https://github.com/jungfrau70/cloud-intermediate.git cloud_intermediate`
> - **Golden Circle Platform**: https://app.goldencircle.us 에서 file 별 다운로드
> - **실습 자료**: 각 Day별 실습 코드와 자동화 스크립트 제공

---

## 🎯 1일차 학습 목표

### 핵심 목표
- **Docker 고급 활용**: 멀티스테이지 빌드, 최적화 기법
- **Kubernetes 기초**: Pod, Service, Deployment, ConfigMap, Secret
- **클라우드 컨테이너 서비스**: AWS ECS, GCP Cloud Run
- **실무 중심**: 프로덕션 환경에서 사용되는 패턴 학습
- **자동화**: 실습 자동화 스크립트를 통한 효율적 학습

## ⚠️ 실습 전 필수 준비사항

### 🚀 **Step 1: AWS EC2 VM 생성 및 설정**

#### **1-1. 실습 코드 다운로드**
```bash
# 방법 1: Git Repository 클론
git clone https://github.com/jungfrau70/cloud-intermediate.git cloud_intermediate
cd cloud_intermediate

# 방법 2: Golden Circle Platform에서 다운로드
# 1. https://app.goldencircle.us 접속
# 2. 로그인 후 "Cloud Intermediate" 과정 선택
# 3. Day1 실습 자료 다운로드
# 4. 압축 해제 후 실습 디렉토리로 이동

# 방법 3: 개별 파일 다운로드 (필요한 경우)
# - 실습 스크립트: cloud_intermediate/scripts/
# - 샘플 코드: cloud_intermediate/samples/day1/
# - 설정 파일: cloud_intermediate/_setup_/
```

#### **1-2. 로컬 PC 환경 준비 (WSL 기준)**치
```bash
# 1. 실습 디렉토리로 이동
cd ./_setup_

# 2. WSL 환경에서 AWS CLI 설치 
chmod +x install-aws-cli-wsl.sh
./install-aws-cli-wsl.sh

# 3. AWS CLI 설정
aws configure
# 설정할 정보:
# - AWS Access Key ID: [본인의 Access Key]
# - AWS Secret Access Key: [본인의 Secret Key]
# - Default region name: ap-northeast-2
# - Default output format: json

# 4. AWS 설정 확인
aws sts get-caller-identity

## 4-1. AWS 설정 도우미 스크립트 실행
chmod +x aws-setup-helper.sh
./aws-setup-helper.sh

# 5. GCP CLI 구성 및 설정
# GCP CLI 인증 설정
gcloud auth login
# 브라우저가 열리면 Google 계정으로 로그인

# GCP 프로젝트 설정
gcloud config set project [YOUR_PROJECT_ID]
# 예: gcloud config set project my-gcp-project-123

# 기본 리전 설정
gcloud config set compute/region asia-northeast3
gcloud config set compute/zone asia-northeast3-a

# 기본 출력 형식 설정
gcloud config set core/format json

# GCP 서비스 계정 키 설정 (선택사항)
# gcloud auth activate-service-account --key-file=path/to/service-account-key.json

# GCP 설정 확인
gcloud auth list
gcloud config list
gcloud info

# 5-1.GCP 설정 도우미 스크립트 실행
chmod +x gcp-setup-helper.sh
./gcp-setup-helper.sh


# 6. WSL 환경 확인 
echo "=== WSL 환경 확인 ==="
chmod +x environment-check-wsl.sh
./environment-check-wsl.sh

# 6-1. 클러스터 정리 기능 설명
# "클러스터 정리 기능을 사용하시겠습니까?" 질문에 대한 설명:
# 이 기능은 실습 중 생성된 클라우드 리소스를 정리하는 도구입니다.
# 
# 정리 가능한 리소스:
# - EKS 클러스터 목록 보기 및 정리
# - GKE 클러스터 목록 보기 및 정리  
# - GCP VM 인스턴스 목록 보기 및 정리
# - AWS EC2 인스턴스 목록 보기 및 정리
# - 통합 클러스터 정리 스크립트 실행
# - 통합 VM 정리 스크립트 실행
#
# 실습 완료 후 불필요한 리소스를 정리하여 비용을 절약할 수 있습니다.
# 처음 실습하는 경우 'N'을 선택하여 건너뛰어도 됩니다.
```

#### **1-3. AWS EC2 인스턴스 생성**
```bash
# 1. AWS 설정 도우미 스크립트 실행
chmod +x aws-setup-helper.sh
./aws-setup-helper.sh

# 2. AWS EC2 인스턴스 생성
chmod +x aws-ec2-create.sh
./aws-ec2-create.sh
```

#### **1-4. 생성된 VM 정보 확인**
```bash
# 생성된 인스턴스 정보 확인
echo "=== AWS EC2 인스턴스 정보 ==="
echo "인스턴스 ID: i-089c0d9f0e5a9b352"
echo "Elastic IP: 54.180.203.112"
echo "보안 그룹: sg-0c896c06c788efd8d"
echo "키 페어: cloud-deployment-key"
```

#### **1-5. 키 페어 확인 및 VM 접속**
```bash
# 1. 키 페어 파일 확인
ls -la cloud-deployment-key.pem

# 2. 키 파일 권한 설정 (필요한 경우)
chmod 400 cloud-deployment-key.pem

# 3. SSH로 VM 접속
ssh -i cloud-deployment-key.pem ec2-user@54.180.203.112

# 4. 시스템 정보 확인
echo "=== 시스템 정보 ==="
uname -a
lscpu | head -10
free -h
df -h
```

#### **1-6. AWS VM 환경 도구 설치 (Amazon Linux 기준)**
```bash
# VM 접속 후 다음 명령어들을 실행합니다:

# 1. 실습 디렉토리로 이동
cd /home/ec2-user/mcp_cloud/mcp_knowledge_base/cloud_intermediate/_setup_

# 2. AWS Amazon Linux 환경 전체 도구 설치
chmod +x install-all-on-aws-amzn.sh
./install-all-on-aws-amzn.sh

# 3. 설치된 도구들 확인
echo "=== 설치된 도구 확인 ==="
aws --version
gcloud --version
docker --version
docker-compose --version
kubectl version --client
python3 --version
git --version
jq --version

# 4. Docker 서비스 시작 및 활성화
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker ec2-user

# 5. 클라우드 환경 구성 및 설정
# AWS CLI 설정 확인 및 구성
aws configure list
aws sts get-caller-identity

# GCP CLI 설정 (VM에서)
gcloud auth login
gcloud config set project [YOUR_PROJECT_ID]
gcloud config set compute/region asia-northeast3

# Docker 환경 구성
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker ec2-user
newgrp docker

# 6. 설치 완료 확인
echo "=== 설치 완료 확인 ==="
docker ps
aws sts get-caller-identity
gcloud auth list

# 7. 설치된 모든 도구 확인
echo "=== 설치된 도구 목록 ==="
echo "AWS CLI: $(aws --version)"
echo "GCP CLI: $(gcloud --version | head -1)"
echo "Docker: $(docker --version)"
echo "Docker Compose: $(docker-compose --version)"
echo "kubectl: $(kubectl version --client)"
echo "Terraform: $(terraform --version | head -1)"
echo "Node.js: $(node --version)"
echo "Helm: $(helm version --short)"
echo "Python3: $(python3 --version)"
echo "Git: $(git --version)"
echo "jq: $(jq --version)"
```

#### **1-7. AWS VM 설치 도구 상세 정보**
```bash
# install-all-on-aws-amzn.sh 스크립트가 설치하는 도구들:

# 1. 시스템 패키지
# - curl, wget, git, unzip, jq, htop, vim, nano, tree
# - gcc, gcc-c++, make, openssl-devel, libffi-devel
# - python3, python3-pip, python3-devel

# 2. 클라우드 도구
# - AWS CLI v2 (최신 버전)
# - GCP CLI (Google Cloud SDK)
# - GKE 인증 플러그인

# 3. 컨테이너 도구
# - Docker CE (최신 버전)
# - Docker Compose Plugin
# - containerd.io

# 4. Kubernetes 도구
# - kubectl (최신 버전)
# - Helm (패키지 매니저)

# 5. 인프라 도구
# - Terraform (HashiCorp)
# - Node.js LTS (JavaScript 런타임)

# 6. 개발 도구
# - Python3 및 pip
# - Git 버전 관리
# - jq (JSON 처리)
```

#### **1-8. 키 페어 자동 생성 과정**
```bash
# aws-ec2-create.sh 스크립트가 자동으로 키 페어를 생성합니다:

# 1. 로컬 키 파일 확인
if [ -f "cloud-deployment-key.pem" ]; then
    echo "✅ 기존 키 파일 발견: cloud-deployment-key.pem"
    # 기존 키 파일 사용
else
    echo "❌ 로컬 키 파일이 없습니다. AWS에서 확인 후 생성합니다."
fi

# 2. AWS에서 키 페어 존재 여부 확인
aws ec2 describe-key-pairs --key-names cloud-deployment-key

# 3. 키 페어가 없으면 자동 생성
aws ec2 create-key-pair \
    --key-name cloud-deployment-key \
    --query 'KeyMaterial' \
    --output text > cloud-deployment-key.pem

# 4. 키 파일 권한 자동 설정 (400)
chmod 400 cloud-deployment-key.pem

# 5. 생성 완료 확인
echo "✅ 키 페어 생성 완료: cloud-deployment-key.pem"
echo "✅ 권한 설정 완료: 400 (소유자만 읽기 가능)"
```

#### **1-7. 키 페어 생성 실패 시 해결 방법**
```bash
# 키 페어 생성이 실패한 경우 수동으로 생성:

# 1. AWS CLI로 키 페어 생성
aws ec2 create-key-pair \
    --key-name cloud-deployment-key \
    --query 'KeyMaterial' \
    --output text > cloud-deployment-key.pem

# 2. 키 파일 권한 설정
chmod 400 cloud-deployment-key.pem

# 3. 키 파일 확인
ls -la cloud-deployment-key.pem
# 예상 결과: -r-------- 1 user user 1674 Dec 10 10:00 cloud-deployment-key.pem
```

### 🔧 **Step 2: 사전 요구사항 확인**
```bash
# 1. 필수 도구 설치 확인
echo "=== 필수 도구 확인 ==="
command -v aws && echo "✅ AWS CLI 설치됨" || echo "❌ AWS CLI 설치 필요"
command -v gcloud && echo "✅ GCP CLI 설치됨" || echo "❌ GCP CLI 설치 필요"
command -v docker && echo "✅ Docker 설치됨" || echo "❌ Docker 설치 필요"
command -v docker-compose && echo "✅ Docker Compose 설치됨" || echo "❌ Docker Compose 설치 필요"
command -v kubectl && echo "✅ kubectl 설치됨" || echo "❌ kubectl 설치 필요"
command -v jq && echo "✅ jq 설치됨" || echo "❌ jq 설치 필요"
command -v curl && echo "✅ curl 설치됨" || echo "❌ curl 설치 필요"

# 2. 클라우드 계정 설정 확인
echo "=== 클라우드 계정 설정 확인 ==="
aws sts get-caller-identity && echo "✅ AWS 계정 설정됨" || echo "❌ AWS 계정 설정 필요"
gcloud auth list && echo "✅ GCP 계정 설정됨" || echo "❌ GCP 계정 설정 필요"

# 3. Docker 서비스 상태 확인
echo "=== Docker 서비스 상태 확인 ==="
docker --version
docker-compose --version
docker ps
```

### 📋 **실습 전 체크리스트**

#### **자동 체크 ["권장"]**
```bash
# 환경 체크 스크립트 실행
cd ./cloud_intermediate/scripts
./cloud-intermediate-helper.sh check-environment
```

#### **수동 체크**
- [ ] **AWS CLI 설정**: `aws sts get-caller-identity` 성공
- [ ] **GCP CLI 설정**: `gcloud auth list` 성공  
- [ ] **Docker 실행**: `docker --version` 확인
- [ ] **kubectl 설치**: Kubernetes 클러스터 관리 준비
- [ ] **권한 확인**: AWS/GCP 리소스 생성 권한
- [ ] **네트워크 확인**: 인터넷 연결 및 방화벽 설정
- [ ] **Git Repository 준비**: 실습 코드 저장소 생성 및 설정



## 📁 **1일차 강의 자료 구조**

### **디렉토리 구조**
```
./cloud_intermediate/
├── samples/day1/
│   ├── docker-advanced/          # Docker 고급 실습
│   ├── kubernetes-basics/        # Kubernetes 기초 실습
│   ├── cloud-container-services/ # 클라우드 컨테이너 서비스
│   └── monitoring-hub/           # 통합 모니터링 허브 구축 실습
        ├── docker-compose.yml           # 모니터링 스택 구성
        ├── prometheus/
        │   └── prometheus.yml          # Prometheus 설정
        ├── alertmanager/
        │   └── alertmanager.yml        # AlertManager 설정
        └── grafana/
            ├── datasources.yml         # Grafana 데이터소스
            └── dashboards.yml          # Grafana 대시보드 설정
├── scripts/
│   ├── day1-practice.sh          # Day1 실습 자동화
│   └── cloud-intermediate-helper.sh # 통합 헬퍼
└── textbook/Day1/
    ├── README.md                     # Day1 개요
    └── practice/                     # 실습 가이드
        ├── docker-advanced.md
        ├── kubernetes-basics.md
        └── cloud-container-services.md
```

## 📅 **1일차 강의 일정**

### 🌅 **오전 ["4시간"] - 컨테이너 기초**

#### **1교시: Docker 고급 활용 ["90분"]**
- **목표**: 멀티스테이지 빌드와 최적화 기법 학습
- **실습**: 최적화된 Dockerfile 작성 및 이미지 빌드

### 🐳 **Step 3: Docker 고급 실습 상세 가이드**

#### **3-1. 실습 환경 준비 (10분)**
```bash
# 1. AWS VM에 SSH 접속
ssh -i cloud-deployment-key.pem ec2-user@54.180.203.112

# 2. 실습 디렉토리 생성
mkdir -p ~/cloud_intermediate/samples/day1/docker-advanced
cd ~/cloud_intermediate/samples/day1/docker-advanced

# 3. Docker 서비스 상태 확인
sudo systemctl status docker
sudo systemctl start docker
sudo systemctl enable docker

# 4. Docker 권한 설정
sudo usermod -aG docker ec2-user
newgrp docker
```

#### **3-2. 멀티스테이지 Dockerfile 작성 (30분)**
```bash
# 1. 기본 Dockerfile 생성
cat > Dockerfile << 'EOF'
# 멀티스테이지 빌드 - Stage 1: 빌드 환경
FROM node:18-alpine AS builder

WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

COPY . .
RUN npm run build

# Stage 2: 프로덕션 환경
FROM nginx:alpine AS production

# 보안 강화: non-root 사용자 생성
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nextjs -u 1001

# 앱 파일 복사
COPY --from=builder /app/dist /usr/share/nginx/html
COPY --from=builder /app/nginx.conf /etc/nginx/nginx.conf

# 포트 설정
EXPOSE 80

# 헬스체크 추가
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost/health || exit 1

# non-root 사용자로 실행
USER nextjs

CMD ["nginx", "-g", "daemon off;"]
EOF

# 2. package.json 생성
cat > package.json << 'EOF'
{
  "name": "docker-advanced-app",
  "version": "1.0.0",
  "description": "Docker 고급 실습용 앱",
  "main": "index.js",
  "scripts": {
    "start": "node index.js",
    "build": "echo 'Build completed'",
    "test": "echo 'Tests passed'"
  },
  "dependencies": {
    "express": "^4.18.2"
  }
}
EOF

# 3. nginx.conf 생성
cat > nginx.conf << 'EOF'
events {
    worker_connections 1024;
}

http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;
    
    server {
        listen 80;
        server_name localhost;
        
        location / {
            root   /usr/share/nginx/html;
            index  index.html index.htm;
        }
        
        location /health {
            access_log off;
            return 200 "healthy\n";
            add_header Content-Type text/plain;
        }
        
        location /metrics {
            access_log off;
            return 200 "# Prometheus metrics\n";
            add_header Content-Type text/plain;
        }
    }
}
EOF
```

#### **3-3. Docker 이미지 빌드 및 최적화 (25분)**
```bash
# 1. 기본 이미지 빌드 (최적화 전)
echo "=== 기본 이미지 빌드 ==="
docker build -t docker-advanced:basic .

# 2. 이미지 크기 확인
echo "=== 이미지 크기 비교 ==="
docker images docker-advanced:basic

# 3. 멀티스테이지 최적화 이미지 빌드
echo "=== 멀티스테이지 최적화 이미지 빌드 ==="
docker build -t docker-advanced:optimized .

# 4. 최적화된 이미지 크기 확인
docker images docker-advanced:optimized

# 5. 이미지 크기 비교
echo "=== 이미지 크기 비교 결과 ==="
docker images | grep docker-advanced
```

#### **3-4. 컨테이너 실행 및 테스트 (25분)**
```bash
# 1. 최적화된 컨테이너 실행
echo "=== 컨테이너 실행 ==="
docker run -d --name test-container -p 8080:80 docker-advanced:optimized

# 2. 컨테이너 상태 확인
echo "=== 컨테이너 상태 확인 ==="
docker ps
docker logs test-container

# 3. 헬스체크 테스트
echo "=== 헬스체크 테스트 ==="
curl http://localhost:8080/health

# 4. 메트릭 엔드포인트 테스트
echo "=== 메트릭 엔드포인트 테스트 ==="
curl http://localhost:8080/metrics

# 5. 컨테이너 리소스 사용량 확인
echo "=== 리소스 사용량 확인 ==="
docker stats test-container --no-stream

# 6. 정리
echo "=== 정리 ==="
docker stop test-container
docker rm test-container
```

**🎯 학습 결과**
- ✅ 멀티스테이지 빌드로 이미지 크기 최적화
- ✅ Prometheus 메트릭 엔드포인트 구현
- ✅ 보안 강화된 컨테이너 이미지 생성

#### **2교시: Kubernetes 기초 ["90분"]**
- **목표**: Pod, Service, Deployment 기본 개념 학습
- **실습**: Kubernetes 리소스 생성 및 관리

### ☸️ **Step 4: Kubernetes 기초 실습 상세 가이드**

#### **4-1. Kubernetes 환경 준비 (15분)**
```bash
# 1. AWS VM에 SSH 접속
ssh -i cloud-deployment-key.pem ec2-user@54.180.203.112

# 2. kubectl 설치
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/

# 3. minikube 설치 (로컬 테스트용)
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube

# 4. minikube 시작
minikube start --driver=docker

# 5. kubectl 설정 확인
kubectl config current-context
kubectl cluster-info
```

#### **4-2. 네임스페이스 및 기본 리소스 생성 (25분)**
```bash
# 1. 실습 디렉토리 생성
mkdir -p ~/cloud_intermediate/samples/day1/kubernetes-basics
cd ~/cloud_intermediate/samples/day1/kubernetes-basics

# 2. 네임스페이스 YAML 생성
cat > namespace.yaml << 'EOF'
apiVersion: v1
kind: Namespace
metadata:
  name: cloud-intermediate
  labels:
    name: cloud-intermediate
    environment: learning
---
apiVersion: v1
kind: ResourceQuota
metadata:
  name: compute-quota
  namespace: cloud-intermediate
spec:
  hard:
    requests.cpu: "2"
    requests.memory: 4Gi
    limits.cpu: "4"
    limits.memory: 8Gi
    pods: "10"
EOF

# 3. 네임스페이스 생성
kubectl apply -f namespace.yaml

# 4. 네임스페이스 확인
kubectl get namespaces
kubectl describe namespace cloud-intermediate
```

#### **4-3. Deployment 및 Service 생성 (30분)**
```bash
# 1. nginx-deployment.yaml 생성
cat > nginx-deployment.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  namespace: cloud-intermediate
  labels:
    app: nginx
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.21
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
---
apiVersion: v1
kind: Service
metadata:
  name: nginx-service
  namespace: cloud-intermediate
spec:
  selector:
    app: nginx
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
  type: ClusterIP
---
apiVersion: v1
kind: Service
metadata:
  name: nginx-service-nodeport
  namespace: cloud-intermediate
spec:
  selector:
    app: nginx
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
      nodePort: 30080
  type: NodePort
EOF

# 2. Deployment 및 Service 생성
kubectl apply -f nginx-deployment.yaml

# 3. 리소스 상태 확인
kubectl get all -n cloud-intermediate
kubectl describe deployment nginx-deployment -n cloud-intermediate
kubectl describe service nginx-service -n cloud-intermediate
```

#### **4-4. ConfigMap 및 Secret 실습 (20분)**
```bash
# 1. configmap-secret.yaml 생성
cat > configmap-secret.yaml << 'EOF'
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
  namespace: cloud-intermediate
data:
  database_url: "mysql://localhost:3306/mydb"
  app_name: "Cloud Intermediate App"
  environment: "learning"
  log_level: "info"
---
apiVersion: v1
kind: Secret
metadata:
  name: app-secret
  namespace: cloud-intermediate
type: Opaque
data:
  username: YWRtaW4=  # admin (base64 encoded)
  password: cGFzc3dvcmQ=  # password (base64 encoded)
  api_key: YWJjZGVmZ2hpams=  # abcdefghijk (base64 encoded)
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app-with-config
  namespace: cloud-intermediate
  labels:
    app: app-with-config
spec:
  replicas: 1
  selector:
    matchLabels:
      app: app-with-config
  template:
    metadata:
      labels:
        app: app-with-config
    spec:
      containers:
      - name: app
        image: nginx:1.21
        ports:
        - containerPort: 80
        env:
        - name: DATABASE_URL
          valueFrom:
            configMapKeyRef:
              name: app-config
              key: database_url
        - name: APP_NAME
          valueFrom:
            configMapKeyRef:
              name: app-config
              key: app_name
        - name: USERNAME
          valueFrom:
            secretKeyRef:
              name: app-secret
              key: username
        - name: PASSWORD
          valueFrom:
            secretKeyRef:
              name: app-secret
              key: password
        volumeMounts:
        - name: config-volume
          mountPath: /etc/config
        - name: secret-volume
          mountPath: /etc/secrets
      volumes:
      - name: config-volume
        configMap:
          name: app-config
      - name: secret-volume
        secret:
          secretName: app-secret
EOF

# 2. ConfigMap 및 Secret 생성
kubectl apply -f configmap-secret.yaml

# 3. ConfigMap 및 Secret 확인
kubectl get configmaps -n cloud-intermediate
kubectl get secrets -n cloud-intermediate
kubectl describe configmap app-config -n cloud-intermediate
kubectl describe secret app-secret -n cloud-intermediate

# 4. 환경 변수 확인
kubectl exec -n cloud-intermediate deployment/app-with-config -- env | grep -E "(DATABASE_URL|APP_NAME|USERNAME|PASSWORD)"
```

**🎯 학습 결과**
- ✅ Kubernetes 기본 리소스 이해
- ✅ ConfigMap과 Secret을 활용한 설정 관리
- ✅ 네임스페이스와 리소스 쿼터 관리

### 🌆 **오후 ["4시간"] - 클라우드 컨테이너 서비스 및 모니터링 기초**

#### **3교시: AWS ECS 기초 ["90분"]**
- **목표**: AWS ECS를 활용한 컨테이너 서비스 배포
- **실습**: ECS 클러스터 생성 및 태스크 정의

### ☁️ **Step 5: AWS ECS 기초 실습 상세 가이드**

#### **5-1. AWS ECS 환경 준비 (15분)**
```bash
# 1. AWS VM에 SSH 접속
ssh -i cloud-deployment-key.pem ec2-user@54.180.203.112

# 2. AWS CLI 설정 확인
aws sts get-caller-identity
aws configure list

# 3. 실습 디렉토리 생성
mkdir -p ~/cloud_intermediate/samples/day1/cloud-container-services
cd ~/cloud_intermediate/samples/day1/cloud-container-services

# 4. AWS 리전 설정
export AWS_DEFAULT_REGION=ap-northeast-2
echo "AWS 리전: $AWS_DEFAULT_REGION"
```

#### **5-2. ECS 클러스터 생성 (20분)**
```bash
# 1. ECS 클러스터 생성
echo "=== ECS 클러스터 생성 ==="
aws ecs create-cluster \
  --cluster-name cloud-intermediate-cluster \
  --tags key=Environment,value=Learning \
  --capacity-providers FARGATE FARGATE_SPOT \
  --default-capacity-provider-strategy capacityProvider=FARGATE,weight=1

# 2. 클러스터 상태 확인
echo "=== 클러스터 상태 확인 ==="
aws ecs describe-clusters --clusters cloud-intermediate-cluster

# 3. 클러스터 목록 확인
echo "=== 클러스터 목록 ==="
aws ecs list-clusters
```

#### **5-3. 태스크 정의 생성 및 등록 (30분)**
```bash
# 1. 태스크 정의 JSON 파일 생성
cat > aws-ecs-task-definition.json << 'EOF'
{
  "family": "cloud-intermediate-app",
  "networkMode": "awsvpc",
  "requiresCompatibilities": ["FARGATE"],
  "cpu": "256",
  "memory": "512",
  "executionRoleArn": "arn:aws:iam::YOUR_ACCOUNT_ID:role/ecsTaskExecutionRole",
  "containerDefinitions": [
    {
      "name": "nginx-container",
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
          "awslogs-group": "/ecs/cloud-intermediate-app",
          "awslogs-region": "ap-northeast-2",
          "awslogs-stream-prefix": "ecs"
        }
      },
      "healthCheck": {
        "command": ["CMD-SHELL", "curl -f http://localhost/ || exit 1"],
        "interval": 30,
        "timeout": 5,
        "retries": 3,
        "startPeriod": 60
      }
    }
  ]
}
EOF

# 2. CloudWatch 로그 그룹 생성
echo "=== CloudWatch 로그 그룹 생성 ==="
aws logs create-log-group \
  --log-group-name /ecs/cloud-intermediate-app \
  --region ap-northeast-2

# 3. 태스크 정의 등록
echo "=== 태스크 정의 등록 ==="
aws ecs register-task-definition \
  --cli-input-json file://aws-ecs-task-definition.json

# 4. 태스크 정의 확인
echo "=== 태스크 정의 확인 ==="
aws ecs list-task-definitions --family-prefix cloud-intermediate-app
aws ecs describe-task-definition --task-definition cloud-intermediate-app:1
```

#### **5-4. ECS 서비스 생성 및 실행 (25분)**
```bash
# 1. VPC 및 서브넷 정보 확인
echo "=== VPC 정보 확인 ==="
VPC_ID=$(aws ec2 describe-vpcs --filters "Name=is-default,Values=true" --query "Vpcs[0].VpcId" --output text)
SUBNET_ID=$(aws ec2 describe-subnets --filters "Name=vpc-id,Values=$VPC_ID" --query "Subnets[0].SubnetId" --output text)
SECURITY_GROUP_ID=$(aws ec2 describe-security-groups --filters "Name=vpc-id,Values=$VPC_ID" --query "SecurityGroups[0].GroupId" --output text)

echo "VPC ID: $VPC_ID"
echo "Subnet ID: $SUBNET_ID"
echo "Security Group ID: $SECURITY_GROUP_ID"

# 2. 보안 그룹 규칙 추가 (HTTP 트래픽 허용)
echo "=== 보안 그룹 규칙 추가 ==="
aws ec2 authorize-security-group-ingress \
  --group-id $SECURITY_GROUP_ID \
  --protocol tcp \
  --port 80 \
  --cidr 0.0.0.0/0

# 3. ECS 서비스 생성
echo "=== ECS 서비스 생성 ==="
aws ecs create-service \
  --cluster cloud-intermediate-cluster \
  --service-name cloud-intermediate-service \
  --task-definition cloud-intermediate-app:1 \
  --desired-count 2 \
  --launch-type FARGATE \
  --network-configuration "awsvpcConfiguration={subnets=[$SUBNET_ID],securityGroups=[$SECURITY_GROUP_ID],assignPublicIp=ENABLED}"

# 4. 서비스 상태 확인
echo "=== 서비스 상태 확인 ==="
aws ecs describe-services \
  --cluster cloud-intermediate-cluster \
  --services cloud-intermediate-service

# 5. 태스크 상태 확인
echo "=== 태스크 상태 확인 ==="
aws ecs list-tasks --cluster cloud-intermediate-cluster
```

**🎯 학습 결과**
- ✅ AWS ECS 클러스터 생성 및 관리
- ✅ Fargate를 활용한 서버리스 컨테이너 실행
- ✅ 태스크 정의를 통한 컨테이너 설정

#### **4교시: 통합 모니터링 허브 구축 ["90분"]**
- **목표**: 멀티 클라우드 환경을 위한 통합 모니터링 허브 구축
- **실습**: Phase 1 (AWS VM 기반 Global Prometheus + Grafana 설정)

### 📊 **Step 6: 통합 모니터링 허브 구축 상세 가이드**

#### **6-1. 모니터링 환경 준비 (15분)**

> **📋 실습 샘플**: `mcp_knowledge_base/cloud_intermediate/repo/samples/day1/monitoring-hub/`

```bash
# 1. AWS VM에 SSH 접속
ssh -i cloud-deployment-key.pem ec2-user@54.180.203.112

# 2. Docker 및 Docker Compose 설치 확인
sudo systemctl status docker
docker --version
docker-compose --version

# 3. 실습 디렉토리 생성 (실습 샘플과 동일한 구조)
mkdir -p ~/cloud_intermediate/samples/day1/monitoring-hub
cd ~/cloud_intermediate/samples/day1/monitoring-hub

# 4. 모니터링 디렉토리 구조 생성
mkdir -p monitoring/{prometheus,grafana,alertmanager,dashboards}
cd monitoring

# 5. 실습 샘플과 동일한 구성 확인
echo "=== 실습 샘플 디렉토리 구조 ==="
echo "실습 샘플: mcp_knowledge_base/cloud_intermediate/repo/samples/day1/monitoring-hub/"
echo "현재 디렉토리: $(pwd)"
echo "구성 파일: docker-compose.yml, prometheus.yml, alertmanager.yml"
```

#### **6-2. Global Prometheus 설정 (25분)**
```bash
# 1. Prometheus 설정 파일 생성
cat > prometheus/prometheus.yml << 'EOF'
global:
  scrape_interval: 15s
  external_labels:
    environment: 'production'
    region: 'global'

scrape_configs:
  # AWS VM 로컬 메트릭 수집
  - job_name: 'aws-vm-local'
    static_configs:
      - targets: ['node-exporter:9100']
    scrape_interval: 15s

  # Push Gateway 메트릭 수집
  - job_name: 'pushgateway'
    static_configs:
      - targets: ['pushgateway:9091']
    honor_labels: true
    scrape_interval: 5s

  # GCP 클러스터 메트릭 수집 (Federation) - 나중에 추가
  - job_name: 'gcp-cluster-federation'
    scrape_interval: 30s
    honor_labels: true
    metrics_path: /federate
    params:
      'match[]':
        - '{job=~"gcp-.*"}'
    static_configs:
      - targets: ['gcp-prometheus.example.com:9090']
    basic_auth:
      username: 'prometheus'
      password: 'secure-password'

  # AWS 클러스터 메트릭 수집 (Federation) - 나중에 추가
  - job_name: 'aws-cluster-federation'
    scrape_interval: 30s
    honor_labels: true
    metrics_path: /federate
    params:
      'match[]':
        - '{job=~"aws-.*"}'
    static_configs:
      - targets: ['aws-prometheus.example.com:9090']
    basic_auth:
      username: 'prometheus'
      password: 'secure-password'
EOF

# 2. Prometheus 설정 확인
echo "=== Prometheus 설정 확인 ==="
cat prometheus/prometheus.yml
```

#### **6-3. Grafana 설정 (20분)**
```bash
# 1. Grafana 데이터소스 설정 생성
cat > grafana/datasources.yml << 'EOF'
apiVersion: 1

datasources:
  - name: Prometheus
    type: prometheus
    access: proxy
    url: http://prometheus:9090
    isDefault: true
    editable: true
    jsonData:
      httpMethod: POST
      manageAlerts: true
      prometheusType: Prometheus
      prometheusVersion: 2.40.0
      cacheLevel: 'High'
      disableRecordingRules: false
      incrementalQueryOverlapWindow: 10m
      queryTimeout: 60s
      timeInterval: 15s
EOF

# 2. Grafana 대시보드 설정 생성
cat > grafana/dashboards.yml << 'EOF'
apiVersion: 1

providers:
  - name: 'default'
    orgId: 1
    folder: ''
    type: file
    disableDeletion: false
    updateIntervalSeconds: 10
    allowUiUpdates: true
    options:
      path: /var/lib/grafana/dashboards
EOF

# 3. 기본 대시보드 JSON 생성
cat > dashboards/aws-vm-dashboard.json << 'EOF'
{
  "dashboard": {
    "id": null,
    "title": "AWS VM 모니터링",
    "tags": ["aws", "vm", "monitoring"],
    "timezone": "browser",
    "panels": [
      {
        "id": 1,
        "title": "CPU 사용률",
        "type": "stat",
        "targets": [
          {
            "expr": "100 - (avg by (instance) (irate(node_cpu_seconds_total{mode=\"idle\"}[5m])) * 100)",
            "refId": "A"
          }
        ],
        "gridPos": {"h": 8, "w": 12, "x": 0, "y": 0}
      },
      {
        "id": 2,
        "title": "메모리 사용률",
        "type": "stat",
        "targets": [
          {
            "expr": "100 * (1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes))",
            "refId": "A"
          }
        ],
        "gridPos": {"h": 8, "w": 12, "x": 12, "y": 0}
      }
    ],
    "time": {
      "from": "now-1h",
      "to": "now"
    },
    "refresh": "30s"
  }
}
EOF
```

#### **6-4. Docker Compose 스택 실행 (30분)**

> **📋 참고**: 이 실습은 `mcp_knowledge_base/cloud_intermediate/repo/samples/day1/monitoring-hub/docker-compose.yml`과 동일한 구성입니다.

```bash
# 1. Docker Compose 파일 생성 (실습 샘플과 동일한 구성)
cat > docker-compose.yml << 'EOF'
version: '3.8'

services:
  # Global Prometheus
  prometheus:
    image: prom/prometheus:latest
    container_name: global-prometheus
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus/prometheus.yml:/etc/prometheus/prometheus.yml
      - prometheus_data:/prometheus
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
      - '--web.enable-lifecycle'
      - '--web.enable-admin-api'
    networks:
      - monitoring

  # Node Exporter
  node-exporter:
    image: prom/node-exporter:latest
    container_name: node-exporter
    ports:
      - "9100:9100"
    volumes:
      - /proc:/host/proc:ro
      - /sys:/host/sys:ro
      - /:/rootfs:ro
    command:
      - '--path.procfs=/host/proc'
      - '--path.rootfs=/rootfs'
      - '--path.sysfs=/host/sys'
    networks:
      - monitoring

  # Grafana
  grafana:
    image: grafana/grafana:latest
    container_name: global-grafana
    ports:
      - "3000:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin123
    volumes:
      - grafana_data:/var/lib/grafana
    networks:
      - monitoring

  # Push Gateway
  pushgateway:
    image: prom/pushgateway:latest
    container_name: pushgateway
    ports:
      - "9091:9091"
    networks:
      - monitoring

  # AlertManager
  alertmanager:
    image: prom/alertmanager:latest
    container_name: alertmanager
    ports:
      - "9093:9093"
    volumes:
      - ./alertmanager/alertmanager.yml:/etc/alertmanager/alertmanager.yml
    networks:
      - monitoring

volumes:
  prometheus_data:
  grafana_data:

networks:
  monitoring:
    driver: bridge
EOF

# 2. AlertManager 설정 생성
cat > alertmanager/alertmanager.yml << 'EOF'
global:
  smtp_smarthost: 'localhost:587'
  smtp_from: 'alerts@example.com'

route:
  group_by: ['alertname']
  group_wait: 10s
  group_interval: 10s
  repeat_interval: 1h
  receiver: 'web.hook'

receivers:
- name: 'web.hook'
  webhook_configs:
  - url: 'http://127.0.0.1:5001/'

- name: 'email'
  email_configs:
  - to: 'admin@example.com'
    subject: 'Alert: {{ .GroupLabels.alertname }}'
    body: |
      {{ range .Alerts }}
      Alert: {{ .Annotations.summary }}
      Description: {{ .Annotations.description }}
      {{ end }}
EOF

# 3. 모니터링 스택 실행
echo "=== 모니터링 스택 실행 ==="
docker-compose up -d

# 4. 서비스 상태 확인
echo "=== 서비스 상태 확인 ==="
sleep 10
docker-compose ps

# 5. 서비스 접근성 확인
echo "=== 서비스 접근성 확인 ==="
curl -s http://localhost:9090/api/v1/query?query=up | jq .
curl -s http://localhost:3000/api/health
curl -s http://localhost:9100/metrics | head -10
```

**🎯 학습 결과**
- ✅ AWS VM 기반 통합 모니터링 허브 구축
- ✅ Global Prometheus + Grafana 정상 동작
- ✅ Node Exporter를 통한 시스템 메트릭 수집
- ✅ 멀티 클라우드 모니터링 기반 환경 준비

### **실습 샘플과의 연결**
이 실습은 `mcp_knowledge_base/cloud_intermediate/repo/samples/day1/monitoring-hub/` 디렉토리의 샘플 코드와 동일한 구성을 사용합니다:

- **docker-compose.yml**: 모니터링 스택 구성 (Prometheus, Grafana, Node Exporter, Push Gateway, AlertManager)
- **prometheus/prometheus.yml**: Prometheus 설정 파일
- **alertmanager/alertmanager.yml**: AlertManager 설정 파일
- **grafana/**: Grafana 데이터소스 및 대시보드 설정

> **📋 참고**: 실습 샘플 디렉토리의 모든 파일이 강의안의 실습 과정과 정확히 일치합니다.

## 🛠️ **실습 자동화 도구**

### **통합 헬퍼 스크립트**
```bash
# 환경 체크
./cloud-intermediate-helper.sh check-environment

# Docker 실습
./cloud-intermediate-helper.sh docker-practice

# Kubernetes 실습
./cloud-intermediate-helper.sh kubernetes-practice

# 클라우드 서비스 실습
./cloud-intermediate-helper.sh cloud-services-practice
```

### **Day1 실습 자동화**
```bash
# 전체 Day1 실습 실행
./day1-practice.sh

# 개별 실습 실행
./day1-practice.sh docker-advanced
./day1-practice.sh kubernetes-basics
./day1-practice.sh cloud-container-services
./day1-practice.sh monitoring-hub
```

### **실습 샘플 디렉토리 활용**
```bash
# 실습 샘플 디렉토리로 이동
cd mcp_knowledge_base/cloud_intermediate/repo/samples/day1/monitoring-hub/

# 샘플 코드 확인
ls -la
cat docker-compose.yml
cat prometheus/prometheus.yml
cat alertmanager/alertmanager.yml

# 샘플 코드로 모니터링 스택 실행
docker-compose up -d
docker-compose ps
```

## 📊 **학습 성과 측정**

### **1교시 완료 확인**
- [ ] 멀티스테이지 Dockerfile 작성 완료
- [ ] Prometheus 메트릭 엔드포인트 구현
- [ ] 최적화된 Docker 이미지 빌드 성공
- [ ] 이미지 크기 50% 이상 감소 확인

### **1교시 테스트 과정**
```bash
# Docker 이미지 빌드 테스트
cd samples/day1/docker-advanced/
docker build -t test-optimized .

# 이미지 크기 확인
docker images test-optimized

# 컨테이너 실행 테스트
docker run -d --name test-container -p 8080:80 test-optimized

# 컨테이너 상태 확인
docker ps
docker logs test-container

# 정리
docker stop test-container
docker rm test-container
```

### **2교시 완료 확인**
- [ ] Kubernetes 네임스페이스 생성
- [ ] Deployment 및 Service 생성 성공
- [ ] ConfigMap과 Secret 설정 완료
- [ ] Pod 상태 정상 확인

### **2교시 테스트 과정**
```bash
# Kubernetes 리소스 상태 확인
kubectl get all --all-namespaces

# 네임스페이스 확인
kubectl get namespaces

# Pod 상태 확인
kubectl get pods -n default

# Service 확인
kubectl get services

# ConfigMap 확인
kubectl get configmaps

# Secret 확인
kubectl get secrets
```

### **3교시 완료 확인**
- [ ] AWS ECS 클러스터 생성 성공
- [ ] 태스크 정의 등록 완료
- [ ] ECS 서비스 실행 및 상태 확인
- [ ] Fargate 태스크 정상 동작

### **3교시 테스트 과정**
```bash
# AWS ECS 클러스터 상태 확인
aws ecs describe-clusters --clusters cloud-intermediate-cluster

# 태스크 정의 확인
aws ecs list-task-definitions

# ECS 서비스 상태 확인
aws ecs describe-services --cluster cloud-intermediate-cluster --services cloud-intermediate-service

# 태스크 상태 확인
aws ecs list-tasks --cluster cloud-intermediate-cluster
```

### **4교시 완료 확인**
- [ ] AWS VM 통합 모니터링 허브 구축 완료
- [ ] Global Prometheus + Grafana 정상 동작 확인
- [ ] Node Exporter 메트릭 수집 확인
- [ ] 멀티 클라우드 모니터링 기반 환경 준비 완료

### **4교시 테스트 과정**
```bash
# Phase 1 로컬 테스트 실행
cd cloud_intermediate/repo/
bash scripts/test-phase1-local.sh

# 테스트 결과 확인
cat test-results/phase1_*.log

# 모니터링 스택 상태 확인
bash scripts/monitoring-stack.sh status

# 서비스 접근성 확인
curl http://localhost:9090/api/v1/query?query=up
curl http://localhost:3000/api/health
```

### **실습 샘플 디렉토리 테스트**
```bash
# 실습 샘플 디렉토리로 이동
cd mcp_knowledge_base/cloud_intermediate/repo/samples/day1/monitoring-hub/

# 샘플 코드로 모니터링 스택 실행
docker-compose up -d

# 서비스 상태 확인
docker-compose ps

# 서비스 접근성 확인
curl http://localhost:9090/api/v1/query?query=up
curl http://localhost:3000/api/health
curl http://localhost:9100/metrics | head -10
```

## 🚨 **문제 해결 가이드**

### **Docker 관련 문제**
```bash
# Docker 서비스 재시작
sudo systemctl restart docker

# Docker 이미지 정리
docker system prune -a

# 권한 문제 해결
sudo usermod -aG docker $USER
```

### **Kubernetes 관련 문제**
```bash
# kubectl 설정 확인
kubectl config current-context

# 클러스터 연결 확인
kubectl cluster-info

# 리소스 상태 확인
kubectl get all --all-namespaces
```

### **클라우드 서비스 관련 문제**
```bash
# AWS 자격 증명 확인
aws sts get-caller-identity

# GCP 프로젝트 설정 확인
gcloud config get-value project

# 리소스 상태 확인
aws ecs list-clusters
gcloud run services list
```

### **실습 샘플 디렉토리 문제 해결**
```bash
# 실습 샘플 디렉토리로 이동
cd mcp_knowledge_base/cloud_intermediate/repo/samples/day1/monitoring-hub/

# 샘플 코드 확인
ls -la
cat docker-compose.yml

# 모니터링 스택 재시작
docker-compose down
docker-compose up -d

# 서비스 상태 확인
docker-compose ps
docker-compose logs
```

## 📚 **추가 학습 자료**

### **공식 문서**
- ["Docker 공식 문서"][https://docs.docker.com/]
- ["Kubernetes 공식 문서"][https://kubernetes.io/docs/]
- ["AWS ECS 공식 문서"][https://docs.aws.amazon.com/ecs/]
- ["GCP Cloud Run 공식 문서"][https://cloud.google.com/run/docs]

### **실습 코드 저장소**
- [GitHub Repository](https://github.com/jungfrau70/cloud-intermediate.git)
- ["실습 코드"](cloud_intermediate/samples/day1/)
- ["자동화 스크립트"](cloud_intermediate/scripts/)

### **실습 샘플 디렉토리**
- **모니터링 허브**: `mcp_knowledge_base/cloud_intermediate/repo/samples/day1/monitoring-hub/`
- **Docker 고급**: `mcp_knowledge_base/cloud_intermediate/repo/samples/day1/docker-advanced/`
- **Kubernetes 기초**: `mcp_knowledge_base/cloud_intermediate/repo/samples/day1/kubernetes-basics/`
- **클라우드 컨테이너**: `mcp_knowledge_base/cloud_intermediate/repo/samples/day1/cloud-container-services/`

## 🎯 **다음 단계 안내**

### **Day2 준비사항**
- [ ] Day1 실습 완료 확인
- [ ] GitHub Actions 워크플로우 준비
- [ ] CI/CD 파이프라인 설계
- [ ] 모니터링 스택 준비 [Prometheus + Grafana]

### **실무 적용 방안**
- [ ] 회사 프로젝트에 Docker 최적화 적용
- [ ] Kubernetes 클러스터 구축 계획 수립
- [ ] 클라우드 컨테이너 서비스 도입 검토
- [ ] 모니터링 및 로깅 시스템 구축

---

**💡 궁금한 점이 있으시면 언제든 문의해주세요!**  
**문제가 발생하거나 도움이 필요하시면 실시간으로 지원해드리겠습니다.**
