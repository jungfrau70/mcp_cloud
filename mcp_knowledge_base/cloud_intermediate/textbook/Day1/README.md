# 🐳 Day 1: 컨테이너 및 Kubernetes 기초

## 📚 학습 목표

### 핵심 학습 목표
- **Docker 고급 활용** Dockerfile 최적화, 멀티스테이지 빌드, 컨테이너 보안
- **Kubernetes 기초** Pod, Service, Deployment, ConfigMap, Secret 관리

### 실습 후 달성할 수 있는 능력
- ✅ Docker 고급 기능을 활용한 최적화된 컨테이너 이미지 생성
- ✅ Kubernetes 클러스터에서 애플리케이션 배포 및 관리
- ✅ 클라우드 Kubernetes 서비스 [EKS, GKE] 활용

### 예상 소요 시간
- **Docker 고급 활용**: 90-120분
- **Kubernetes 기초**: 120-150분
- **클라우드 컨테이너 서비스**: 90-120분
- **전체 과정**: 8시간

---

## 🛠️ 실습 학습

### 📁 실습 코드 및 자동화
- **실습 샘플 코드**: `/mcp_knowledge_base/cloud_intermediate/repo/samples/day1/`
- **자동화 스크립트**: `/mcp_knowledge_base/cloud_intermediate/repo/scripts/day1-practice.sh`
- **클라우드 스크립트**: `/mcp_knowledge_base/cloud_intermediate/repo/cloud-scripts/`

<details>
<summary>🚀 실습 환경 준비</summary>

#### 필수 도구
- **Docker Desktop**: 컨테이너 실행 환경
- **kubectl**: Kubernetes 클러스터 관리
- **AWS CLI**: AWS 서비스 관리
- **GCP CLI**: GCP 서비스 관리

#### 환경 설정
```bash
# Docker 설치 확인
docker --version
docker-compose --version

# kubectl 설치 확인
kubectl version --client

# AWS CLI 설정 확인
aws --version
aws configure list

# GCP CLI 설정 확인
gcloud --version
gcloud auth list
```

</details>

<details>
<summary>🔧 1단계: Docker 고급 활용</summary>

#### Dockerfile 최적화
```bash
# 최적화된 Dockerfile 작성
cat > Dockerfile << 'EOF'
# 멀티스테이지 빌드
FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

FROM node:18-alpine AS runtime
WORKDIR /app
COPY --from=builder /app/node_modules ./node_modules
COPY . .
EXPOSE 3000
CMD ["npm", "start"]
EOF

# 이미지 빌드
docker build -t myapp:optimized .

# 이미지 크기 확인
docker images myapp:optimized
```

#### 멀티스테이지 빌드
```bash
# 멀티스테이지 빌드 실행
docker build --target builder -t myapp:builder .
docker build --target runtime -t myapp:runtime .

# 빌드 캐시 활용
docker build --cache-from myapp:latest -t myapp:latest .
```

</details>

<details>
<summary>🔧 2단계: Kubernetes 기초</summary>

#### Pod 생성 및 관리
```bash
# Pod 생성
kubectl create -f - << 'EOF'
apiVersion: v1
kind: Pod
metadata:
  name: myapp-pod
spec:
  containers:
  - name: myapp
    image: nginx:1.21
    ports:
    - containerPort: 80
EOF

# Pod 상태 확인
kubectl get pods
kubectl describe pod myapp-pod

# Pod 로그 확인
kubectl logs myapp-pod
```

#### Service 및 Deployment
```bash
# Deployment 생성
kubectl create -f - << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp-deployment
spec:
  replicas: 3
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
        image: nginx:1.21
        ports:
        - containerPort: 80
EOF

# Service 생성
kubectl create -f - << 'EOF'
apiVersion: v1
kind: Service
metadata:
  name: myapp-service
spec:
  selector:
    app: myapp
  ports:
  - port: 80
    targetPort: 80
  type: LoadBalancer
EOF
```

</details>

<details>
<summary>🔧 3단계: 클라우드 컨테이너 서비스</summary>

#### AWS EKS 클러스터 생성
```bash
# EKS 클러스터 생성
eksctl create cluster \
  --name my-cluster \
  --region us-west-2 \
  --nodegroup-name workers \
  --node-type t3.medium \
  --nodes 2 \
  --nodes-min 1 \
  --nodes-max 3

# 클러스터 연결
aws eks update-kubeconfig --region us-west-2 --name my-cluster

# 클러스터 상태 확인
kubectl get nodes
```

#### GCP GKE 클러스터 생성
```bash
# GKE 클러스터 생성
gcloud container clusters create my-cluster \
  --zone us-central1-a \
  --num-nodes 2 \
  --machine-type e2-medium

# 클러스터 연결
gcloud container clusters get-credentials my-cluster --zone us-central1-a

# 클러스터 상태 확인
kubectl get nodes
```

</details>

---

## 📚 참고 자료

### 유용한 명령어
```bash
# Docker 명령어
docker system prune -a  # 사용하지 않는 이미지 정리
docker image ls --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}"

# Kubernetes 명령어
kubectl get all  # 모든 리소스 확인
kubectl describe <resource> <name>  # 리소스 상세 정보
kubectl logs -f <pod-name>  # 실시간 로그 확인
```

### 문제 해결
1. **Docker 이미지 빌드 실패**
   - Dockerfile 문법 확인
   - 베이스 이미지 존재 여부 확인
   - 네트워크 연결 상태 확인

2. **Kubernetes Pod 시작 실패**
   - 이미지 이름 및 태그 확인
   - 리소스 제한 확인
   - 노드 상태 확인

---

## 🧹 실습 정리

### 자동 정리
```bash
# Day1 실습 자동 정리
./mcp_knowledge_base/cloud_intermediate/repo/scripts/day1-practice.sh --cleanup
```

### 수동 정리
```bash
# Kubernetes 리소스 정리
kubectl delete deployment myapp-deployment
kubectl delete service myapp-service
kubectl delete pod myapp-pod

# Docker 이미지 정리
docker rmi myapp:optimized myapp:builder myapp:runtime

# EKS 클러스터 정리
eksctl delete cluster --name my-cluster --region us-west-2

# GKE 클러스터 정리
gcloud container clusters delete my-cluster --zone us-central1-a
```

### 정리 확인
- [ ] Kubernetes 리소스 삭제 완료
- [ ] Docker 이미지 정리 완료
- [ ] 클라우드 리소스 정리 완료
- [ ] 비용 발생 확인

---

## 🔗 관련 자료

### 📚 실습 가이드
- ["Docker 고급 활용"][practice/docker-advanced.md]
- ["Kubernetes 기초"][practice/kubernetes-basics.md]
- ["클라우드 컨테이너 서비스"][practice/cloud-container-services.md]

### 🛠️ 설치 가이드
- ["Docker Desktop 설치"][_setup_wsl/install-docker-wsl.sh]
- ["kubectl 설치"][_setup_wsl/install-kubectl-wsl.sh]
- ["AWS CLI 설정"][_setup_wsl/install-aws-cli-wsl.sh]
- ["GCP CLI 설정"][_setup_wsl/install-gcp-cli-wsl.sh]

### 🏠 네비게이션
<div align="center">

["← 이전: Cloud Basic 과정"][../cloud_basic/README.md] | 
["📚 전체 커리큘럼"][../../curriculum.md] | 
["🏠 학습 경로로 돌아가기"][../../index.md] | 
["다음: Day 2 →"][../Day2/README.md]

</div>
