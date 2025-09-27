# Cloud Intermediate - 1일차 강의안

> 📋 **강의 일시**: 2024년 10월 1일 ["수"] 9:00~17:00  
> 📋 **강의 방식**: 온라인 실습 중심  
> 📋 **선수 학습**: Cloud Basic 완료 ["AWS/GCP 기초 서비스"]  
> 📋 **WSL 환경설정**: [./cloud_intermediate/_setup_wsl/README.md](coud_intermediate/_setup_wsl/README.md)
> 📋 **실습 코드**: `git clone https://github.com/jungfrau70/cloud-intermediate.git cloud_intermediate`

---

## 🎯 1일차 학습 목표

### 핵심 목표
- **Docker 고급 활용**: 멀티스테이지 빌드, 최적화 기법
- **Kubernetes 기초**: Pod, Service, Deployment, ConfigMap, Secret
- **클라우드 컨테이너 서비스**: AWS ECS, GCP Cloud Run
- **실무 중심**: 프로덕션 환경에서 사용되는 패턴 학습
- **자동화**: 실습 자동화 스크립트를 통한 효율적 학습

## ⚠️ 실습 전 필수 준비사항

### 🔧 **사전 요구사항 확인**
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

### **새로운 디렉토리 구조**
```
./cloud_intermediate/
├── samples/day1/
│   ├── docker-advanced/          # Docker 고급 실습
│   ├── kubernetes-basics/        # Kubernetes 기초 실습
│   ├── cloud-container-services/ # 클라우드 컨테이너 서비스
│   └── monitoring-hub/           # 통합 모니터링 허브 구축 실습
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

**🔍 실습 코드 위치**
- **샘플 코드**: `cloud_intermediate/samples/day1/docker-advanced/`
- **자동화 스크립트**: `cloud_intermediate/scripts/day1-practice.sh`

**📋 실습 단계**
```bash
# 1. 실습 환경 준비
cd ./cloud_intermediate/scripts
./day1-practice.sh

# 2. Docker 고급 실습 선택
# 메뉴에서 "1. Docker 고급 실습" 선택

# 3. 실습 결과 확인
# - 멀티스테이지 빌드된 이미지
# - Prometheus 메트릭 엔드포인트
# - 최적화된 이미지 크기
```

**🎯 학습 결과**
- ✅ 멀티스테이지 빌드로 이미지 크기 최적화
- ✅ Prometheus 메트릭 엔드포인트 구현
- ✅ 보안 강화된 컨테이너 이미지 생성

#### **2교시: Kubernetes 기초 ["90분"]**
- **목표**: Pod, Service, Deployment 기본 개념 학습
- **실습**: Kubernetes 리소스 생성 및 관리

**🔍 실습 코드 위치**
- **샘플 코드**: `cloud_intermediate/samples/day1/kubernetes-basics/`
- **YAML 파일**: nginx-deployment.yaml, configmap-secret.yaml, namespace.yaml

**📋 실습 단계**
```bash
# 1. Kubernetes 실습 선택
# 메뉴에서 "2. Kubernetes 기초 실습" 선택

# 2. 네임스페이스 생성
kubectl apply -f cloud_intermediate/samples/day1/kubernetes-basics/namespace.yaml

# 3. Deployment 및 Service 생성
kubectl apply -f cloud_intermediate/samples/day1/kubernetes-basics/nginx-deployment.yaml

# 4. ConfigMap 및 Secret 실습
kubectl apply -f cloud_intermediate/samples/day1/kubernetes-basics/configmap-secret.yaml
```

**🎯 학습 결과**
- ✅ Kubernetes 기본 리소스 이해
- ✅ ConfigMap과 Secret을 활용한 설정 관리
- ✅ 네임스페이스와 리소스 쿼터 관리

### 🌆 **오후 ["4시간"] - 클라우드 컨테이너 서비스 및 모니터링 기초**

#### **3교시: AWS ECS 기초 ["90분"]**
- **목표**: AWS ECS를 활용한 컨테이너 서비스 배포
- **실습**: ECS 클러스터 생성 및 태스크 정의

**🔍 실습 코드 위치**
- **샘플 코드**: `cloud_intermediate/samples/day1/cloud-container-services/aws-ecs-task-definition.json`

**📋 실습 단계**
```bash
# 1. AWS ECS 실습 선택
# 메뉴에서 "3. 클라우드 컨테이너 서비스 실습" 선택

# 2. ECS 클러스터 생성
aws ecs create-cluster --cluster-name cloud-intermediate-cluster

# 3. 태스크 정의 등록
aws ecs register-task-definition \
  --cli-input-json file://cloud_intermediate/samples/day1/cloud-container-services/aws-ecs-task-definition.json

# 4. 서비스 생성 및 실행
aws ecs create-service \
  --cluster cloud-intermediate-cluster \
  --service-name cloud-intermediate-service \
  --task-definition cloud-intermediate-app:1 \
  --desired-count 2 \
  --launch-type FARGATE
```

**🎯 학습 결과**
- ✅ AWS ECS 클러스터 생성 및 관리
- ✅ Fargate를 활용한 서버리스 컨테이너 실행
- ✅ 태스크 정의를 통한 컨테이너 설정

#### **4교시: 통합 모니터링 허브 구축 ["90분"]**
- **목표**: 멀티 클라우드 환경을 위한 통합 모니터링 허브 구축
- **실습**: Phase 1 (AWS VM 기반 Global Prometheus + Grafana 설정)

**🔍 실습 코드 위치**
- **통합 시나리오**: `cloud_intermediate/통합모니터링시나리오.md`
- **실습 코드**: `cloud_intermediate/samples/day1/monitoring-hub/`
- **자동화 스크립트**: `cloud_intermediate/scripts/monitoring-stack.sh`

**📋 실습 단계**
```bash
# 1. 통합 모니터링 시나리오 확인
cat cloud_intermediate/통합모니터링시나리오.md

# 2. Phase 1: 통합 모니터링 허브 구축
# AWS EC2 인스턴스 생성 및 Elastic IP 할당

# 3. Global Prometheus + Grafana 설정
# Docker Compose를 활용한 모니터링 스택 구축

# 4. 모니터링 스택 실행 및 확인
# Prometheus, Grafana, Node Exporter 정상 동작 확인
```

**🎯 학습 결과**
- ✅ AWS VM 기반 통합 모니터링 허브 구축
- ✅ Global Prometheus + Grafana 정상 동작
- ✅ Node Exporter를 통한 시스템 메트릭 수집
- ✅ 멀티 클라우드 모니터링 기반 환경 준비

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

## 📚 **추가 학습 자료**

### **공식 문서**
- ["Docker 공식 문서"][https://docs.docker.com/]
- ["Kubernetes 공식 문서"][https://kubernetes.io/docs/]
- ["AWS ECS 공식 문서"][https://docs.aws.amazon.com/ecs/]
- ["GCP Cloud Run 공식 문서"][https://cloud.google.com/run/docs]

### **실습 코드 저장소**
- [GitHub Repository][https://github.com/jungfrau70/cloud-intermediate.git]
- ["실습 코드"][./cloud_intermediate/samples/day1/]
- ["자동화 스크립트"][./cloud_intermediate/scripts/]

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
