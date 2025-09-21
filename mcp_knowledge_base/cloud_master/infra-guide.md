# 🏗️ Cloud Master 인프라 가이드

## 🎯 학습 목표

### 핵심 학습 목표
- **인프라 기초**: WSL 환경 설정, 클라우드 계정 구성
- **VM 관리**: AWS EC2, GCP Compute Engine 인스턴스 생성 및 관리
- **Kubernetes 클러스터**: 로컬, AWS EKS, GCP GKE 클러스터 구축
- **모니터링**: 인프라 리소스 모니터링 및 최적화

### 실습 후 달성할 수 있는 능력
- ✅ WSL 환경에서 완전한 클라우드 개발 환경 구축
- ✅ 멀티 클라우드 VM 인스턴스 자동 배포
- ✅ Kubernetes 클러스터 설계 및 구축
- ✅ 인프라 모니터링 및 성능 최적화

### 예상 소요 시간
- **환경 설정**: 60-90분
- **VM 배포**: 90-120분
- **Kubernetes 클러스터**: 120-150분
- **모니터링 설정**: 60-90분
- **전체 과정**: 5-7시간

---

## 📚 기존 문서와의 연계

### 관련 실습 가이드
- [CI/CD 파이프라인 가이드](cicd-guide.md) - 자동화된 배포 및 모니터링
- [실습 가이드](execuise-guide.md) - 전체 과정 실습 가이드
- [Day별 실습](../textbook/Day1/README.md) - 단계별 실습 진행

### 자동화 스크립트
- [통합 자동화 스크립트](../repos/automation/integrated-practice-automation.sh) - 전체 과정 자동화
- [환경 체크 도구](../repos/cloud-scripts/environment-check-wsl.sh) - 실습 환경 검증
- [클러스터 생성 스크립트](../repos/cloud-scripts/k8s-cluster-create.sh) - Kubernetes 클러스터 자동 생성

---

## 🛠️ 1. 환경 설정

### 1.1 WSL 환경 구성

#### WSL 설치 및 설정
```bash
# WSL 2를 기본 버전으로 설정
wsl --set-default-version 2

# Ubuntu 설치
wsl --install -d Ubuntu

# WSL 환경 확인
wsl --list --verbose
```

#### 필수 도구 설치
```bash
# 설치 디렉토리로 이동
cd /mnt/c/Users/JIH/githubs/mcp_cloud/mcp_knowledge_base/cloud_master/repos/install

# 모든 도구 한 번에 설치
./install-all-wsl.sh

# Docker 시작
start-docker

# 환경 검증
./environment-check-wsl.sh
```

#### 설치 확인
```bash
# 주요 도구 버전 확인
docker --version
docker-compose --version
git --version
aws --version
gcloud --version
helm version
node --version
python3 --version
```

### 1.2 클라우드 계정 설정

#### AWS 계정 설정
```bash
# AWS CLI 설정
aws configure

# AWS 환경 설정 도우미
./aws-setup-helper.sh

# AWS 연결 확인
aws sts get-caller-identity
```

**설정 단계:**
1. AWS 계정 생성 (Free Tier 권장)
2. IAM 사용자 생성 및 권한 설정
3. AWS CLI 설정
4. 리전 및 가용 영역 확인

#### GCP 계정 설정
```bash
# GCP 초기화
gcloud init

# GCP 인증 확인
gcloud auth list
gcloud auth login

# GCP 환경 설정 도우미
./gcp-setup-helper.sh

# 환경 변수 확인
cat gcp-environment.env
```

**설정 단계:**
1. GCP 계정 생성 ($300 크레딧 제공)
2. 프로젝트 생성 및 설정
3. GCP CLI 설정
4. 서비스 계정 및 키 생성

---

## 🖥️ 2. VM 인프라 배포

### 2.1 AWS EC2 배포

#### EC2 인스턴스 생성
```bash
# EC2 인스턴스 생성
./aws-ec2-create.sh

# 인스턴스 상태 확인
aws ec2 describe-instances --query 'Reservations[*].Instances[*].[InstanceId,State.Name,PublicIpAddress]' --output table
```

#### EC2 인스턴스 관리
```bash
# 인스턴스 시작
aws ec2 start-instances --instance-ids i-1234567890abcdef0

# 인스턴스 중지
aws ec2 stop-instances --instance-ids i-1234567890abcdef0

# 인스턴스 종료
aws ec2 terminate-instances --instance-ids i-1234567890abcdef0
```

### 2.2 GCP Compute Engine 배포

#### Compute Engine 인스턴스 생성
```bash
# GCP 환경 설정 후
./gcp-compute-create.sh

# 인스턴스 목록 확인
gcloud compute instances list --format="table(name,zone,machineType,status)"
```

#### Compute Engine 인스턴스 관리
```bash
# 인스턴스 시작
gcloud compute instances start INSTANCE_NAME --zone=ZONE

# 인스턴스 중지
gcloud compute instances stop INSTANCE_NAME --zone=ZONE

# 인스턴스 삭제
gcloud compute instances delete INSTANCE_NAME --zone=ZONE
```

---

## ☸️ 3. Kubernetes 클러스터 구축

### 3.1 로컬 Kubernetes 클러스터

#### 스크립트 디렉토리 이동
```bash
cd ~/mcp-cloud-workspace/mcp_knowledge_base/cloud_master/repos/cloud-scripts
```

#### 로컬 K8s 클러스터 생성
```bash
# 로컬 K8s 클러스터 생성
./k8s-cluster-create.sh

# 클러스터 상태 확인
kubectl get nodes
kubectl get pods --all-namespaces
```

### 3.2 AWS EKS 클러스터

#### EKS 클러스터 생성
```bash
# EKS 클러스터 생성
./eks-cluster-create.sh

# 클러스터 연결
aws eks update-kubeconfig --region us-west-2 --name my-eks-cluster

# 클러스터 상태 확인
kubectl get nodes
```

### 3.3 GCP GKE 클러스터

#### GKE 클러스터 생성 및 연결
```bash
# GKE 클러스터 목록 확인
gcloud container clusters list

# kubectl 컨텍스트 전환
./context-switch.sh
./context-switch.sh list

# 클러스터 연결 확인
kubectl get nodes
kubectl get pods
```

#### GKE 인증 문제 해결
```bash
# WSL 관리자 권한으로 실행
sudo gcloud components update
sudo gcloud components install gke-gcloud-auth-plugin

# 설치 확인
gcloud components list | grep -i gke
gke-gcloud-auth-plugin --version

# 클러스터 연결 테스트
gcloud container clusters get-credentials cloud-master-cluster --zone=asia-northeast3-a
kubectl get nodes
```

---

## 📊 4. 인프라 모니터링

### 4.1 리소스 모니터링

#### AWS 리소스 모니터링
```bash
# EC2 인스턴스 상태 확인
aws ec2 describe-instances --query 'Reservations[*].Instances[*].[InstanceId,State.Name,PublicIpAddress]' --output table

# EKS 클러스터 상태 확인
aws eks describe-cluster --name my-eks-cluster --region us-west-2

# 비용 확인
aws ce get-cost-and-usage --time-period Start=2024-01-01,End=2024-01-31
```

#### GCP 리소스 모니터링
```bash
# Compute Engine 인스턴스 상태 확인
gcloud compute instances list --format="table(name,zone,machineType,status)"

# GKE 클러스터 상태 확인
gcloud container clusters list

# 비용 확인
gcloud billing accounts list
```

### 4.2 Kubernetes 클러스터 모니터링

#### 클러스터 상태 확인
```bash
# 노드 상태 확인
kubectl get nodes

# 파드 상태 확인
kubectl get pods --all-namespaces

# 서비스 상태 확인
kubectl get services --all-namespaces

# 배포 상태 확인
kubectl get deployments --all-namespaces
```

#### 클러스터 성능 모니터링
```bash
# 노드 리소스 사용량 확인
kubectl top nodes

# 파드 리소스 사용량 확인
kubectl top pods --all-namespaces

# 클러스터 이벤트 확인
kubectl get events --sort-by=.metadata.creationTimestamp
```

---

## 🔧 5. 문제 해결

### 5.1 WSL 관련 문제

#### WSL 서비스 재시작
```bash
# WSL 서비스 재시작
wsl --shutdown
wsl

# WSL 버전 확인
wsl --list --verbose
```

#### Docker 관련 문제
```bash
# Docker 서비스 재시작
sudo systemctl restart docker

# Docker 상태 확인
docker system info

# Docker 컨테이너 정리
docker system prune -a
```

### 5.2 클라우드 연결 문제

#### AWS 연결 문제
```bash
# AWS 연결 확인
aws sts get-caller-identity

# AWS 자격증명 재설정
aws configure

# AWS 리전 확인
aws configure get region
```

#### GCP 연결 문제
```bash
# GCP 연결 확인
gcloud auth list

# GCP 재인증
gcloud auth login

# GCP 프로젝트 확인
gcloud config get-value project
```

### 5.3 Kubernetes 클러스터 문제

#### 클러스터 연결 문제
```bash
# kubectl 컨텍스트 확인
kubectl config get-contexts

# 현재 context 확인
kubectl config current-context

# 컨텍스트 전환
kubectl config use-context CONTEXT_NAME

# 클러스터 연결 테스트
kubectl cluster-info
```

#### 클러스터 문제 해결
```bash
# GKE 인증 문제 해결
./fix-gke-auth.sh

# 클러스터 연결 테스트
./test-cluster-connection.sh

# 클러스터 문제 해결
./fix-cluster-issues.sh
```

---

## 🧹 6. 리소스 정리

### 6.1 클러스터 정리
```bash
# 클러스터 대화형 정리
./cluster-cleanup-interactive.sh

# 특정 클러스터 정리
kubectl delete cluster --all
```

### 6.2 VM 정리
```bash
# VM 대화형 정리
./vm-cleanup-interactive.sh

# AWS 리소스 정리
./cleanup-aws-resources.sh

# GCP 리소스 정리
./cleanup-gcp-resources.sh
```

### 6.3 전체 환경 정리
```bash
# 전체 환경 정리
./cleanup-all-resources.sh

# Docker 정리
docker system prune -a --volumes

# 불필요한 이미지 정리
docker image prune -a
```

---

## 📋 실습 체크리스트

### ✅ 환경 설정 완료
- [ ] WSL 환경 설정
- [ ] 모든 도구 설치 (`./install-all-wsl.sh`)
- [ ] Docker 실행 (`start-docker`)
- [ ] 환경 검증 (`./environment-check-wsl.sh`)

### ✅ 클라우드 설정 완료
- [ ] AWS CLI 설정 (`aws configure`)
- [ ] GCP 초기화 (`gcloud init`)
- [ ] AWS 환경 도우미 (`./aws-setup-helper.sh`)
- [ ] GCP 환경 도우미 (`./gcp-setup-helper.sh`)

### ✅ VM 배포 완료
- [ ] AWS EC2 배포 (`./aws-ec2-create.sh`)
- [ ] GCP Compute 배포 (`./gcp-compute-create.sh`)
- [ ] VM 상태 확인

### ✅ Kubernetes 배포 완료
- [ ] 로컬 K8s 클러스터 (`./k8s-cluster-create.sh`)
- [ ] AWS EKS 클러스터 (`./eks-cluster-create.sh`)
- [ ] GCP GKE 클러스터 (GCP Console 또는 gcloud 명령어)
- [ ] 클러스터 연결 확인 (`kubectl get nodes`)

### ✅ 모니터링 설정 완료
- [ ] 리소스 모니터링 설정
- [ ] 클러스터 모니터링 설정
- [ ] 비용 모니터링 설정

---

## 🎯 빠른 시작 명령어

```bash
# 1. 환경 설정
cd /mnt/c/Users/JIH/githubs/mcp_cloud/mcp_knowledge_base/cloud_master/repos/install
./install-all-wsl.sh && start-docker

# 2. 클라우드 설정
aws configure && gcloud init

# 3. VM 배포
./aws-ec2-create.sh && ./gcp-compute-create.sh

# 4. K8s 배포
cd ~/mcp-cloud-workspace/mcp_knowledge_base/cloud_master/repos/cloud-scripts
./k8s-cluster-create.sh && ./eks-cluster-create.sh

# 5. 확인
kubectl get nodes
```

---

## 📚 참고 자료

### 공식 문서
- [WSL 공식 문서](https://docs.microsoft.com/ko-kr/windows/wsl/)
- [Docker 공식 문서](https://docs.docker.com/)
- [Kubernetes 공식 문서](https://kubernetes.io/docs/)
- [AWS 공식 문서](https://docs.aws.amazon.com/)
- [GCP 공식 문서](https://cloud.google.com/docs)

### 추가 학습 자료
- [AWS 예제](https://github.com/aws-samples)
- [GCP 예제](https://github.com/GoogleCloudPlatform)
- [Kubernetes 예제](https://kubernetes.io/examples/)

---

<div align="center">

[← 이전: CI/CD 파이프라인 가이드](cicd-guide.md) | 
[📚 전체 커리큘럼](../curriculum.md) | 
[🏠 학습 경로로 돌아가기](../index.md) | 
[다음: 실습 가이드 →](execuise-guide.md)

</div>
