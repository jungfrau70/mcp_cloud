# Cloud Master Day2 - Kubernetes & 고급 CI/CD 실습

## 🎯 실습 목표
- 멀티스테이지 빌드로 최적화된 Docker 이미지 생성
- Kubernetes 클러스터에서 애플리케이션 배포
- 고급 GitHub Actions 워크플로우 구축
- 완전 자동화된 VM 배포 파이프라인 구축

## 🚀 빠른 시작

### 1. 클라우드 환경 설정
```bash
# AWS 환경 설정
chmod +x ../../../repos/cloud-scripts/aws-setup-helper.sh
./../../../repos/cloud-scripts/aws-setup-helper.sh

# GCP 환경 설정
chmod +x ../../../repos/cloud-scripts/gcp-setup-helper.sh
./../../../repos/cloud-scripts/gcp-setup-helper.sh
```

### 2. Kubernetes 클러스터 생성
```bash
# Kubernetes 클러스터 자동 생성
chmod +x ../../../repos/cloud-scripts/k8s-cluster-create.sh
./../../../repos/cloud-scripts/k8s-cluster-create.sh
```

### 3. 애플리케이션 배포
```bash
# Kubernetes 애플리케이션 자동 배포
chmod +x ../../../repos/cloud-scripts/k8s-app-deploy.sh
./../../../repos/cloud-scripts/k8s-app-deploy.sh
```

## 📁 파일 구조
```
my-app/
├── README.md                    # 이 파일
├── app.js                      # Node.js 애플리케이션
├── package.json                # Node.js 의존성
├── Dockerfile                  # 멀티스테이지 Docker 이미지
├── docker-compose.yml          # Docker Compose 설정
├── backend/                    # 백엔드 서비스
│   ├── app.py
│   ├── Dockerfile
│   └── requirements.txt
├── frontend/                   # 프론트엔드 서비스
│   ├── src/
│   │   └── App.js
│   ├── Dockerfile
│   ├── nginx.conf
│   └── package.json
├── database/                   # 데이터베이스
│   └── init.sql
└── k8s/                        # Kubernetes 매니페스트
    └── deployment.yaml
```

## 🔧 실습 단계

### 1단계: 멀티스테이지 Docker 빌드
```bash
# 멀티스테이지 이미지 빌드
docker build -t my-app:latest .

# 이미지 크기 확인
docker images my-app

# 이미지 분석
docker history my-app:latest
```

### 2단계: Kubernetes 클러스터 설정
```bash
# 클러스터 정보 확인
kubectl cluster-info

# 노드 상태 확인
kubectl get nodes

# 네임스페이스 생성
kubectl create namespace my-app
```

### 3단계: 애플리케이션 배포
```bash
# Deployment 생성
kubectl apply -f k8s/deployment.yaml

# Service 생성
kubectl apply -f k8s/service.yaml

# 배포 상태 확인
kubectl get pods -n my-app
kubectl get services -n my-app
```

### 4단계: 고급 CI/CD 설정
```bash
# GitHub Actions 워크플로우 설정
cp .github/workflows/advanced-cicd.yml .github/workflows/

# 시크릿 설정 (GitHub 저장소에서)
# - AWS_ACCESS_KEY_ID
# - AWS_SECRET_ACCESS_KEY
# - GCP_SA_KEY
# - K8S_CLUSTER_CONFIG
```

## 🧹 정리
```bash
# Kubernetes 리소스 정리
kubectl delete namespace my-app

# Docker 리소스 정리
docker system prune -a

# AWS 리소스 정리
chmod +x ../../../repos/cloud-scripts/aws-resource-cleanup.sh
./../../../repos/cloud-scripts/aws-resource-cleanup.sh

# GCP 리소스 정리
chmod +x ../../../repos/cloud-scripts/gcp-project-cleanup.sh
./../../../repos/cloud-scripts/gcp-project-cleanup.sh
```

## 📚 참고 자료
- [Cloud Master Day2 가이드](cloud_master/textbook/Day2/README.md)
- [고급 Docker 실습](cloud_master/textbook/Day2/practices/docker-advanced.md)
- [Kubernetes 기초 실습](cloud_master/textbook/Day2/practices/kubernetes-basics.md)
- [cloud-scripts 가이드](cloud_master/repos/cloud-scripts/README.md)