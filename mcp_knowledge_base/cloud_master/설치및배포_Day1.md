

# 🚀 Cloud Master 설치 및 배포 Short-Path

## 📦 1. WSL 환경 및 도구 설치

### WSL 경로 설정
```bash
# Windows 경로를 WSL 경로로 변환
wslpath "C:\Users\JIH\githubs\mcp_cloud\mcp_knowledge_base\cloud_master\repos\install"

# 설치 디렉토리로 이동
cd /mnt/c/Users/JIH/githubs/mcp_cloud/mcp_knowledge_base/cloud_master/repos/install
```

### 전체 도구 설치
```bash
# 모든 도구 한 번에 설치
./install-all-wsl.sh

# Docker 시작
start-docker

# 환경 검증
./environment-check-wsl.sh
```

### 설치 확인
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

---

## ☁️ 2. Cloud 환경 구성

### AWS 설정
```bash
# AWS CLI 설정
aws configure

# AWS 환경 설정 도우미
./aws-setup-helper.sh
```

### GCP 설정
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

---

## 🖥️ 3. VM 리소스 배포

### AWS EC2 배포
```bash
# EC2 인스턴스 생성
./aws-ec2-create.sh
```

### GCP Compute Engine 배포
```bash
# GCP 환경 설정 후
./gcp-compute-create.sh
```

---

## ☸️ 4. Kubernetes 클러스터 배포

### 스크립트 디렉토리 이동
```bash
cd ~/mcp-cloud-workspace/mcp_knowledge_base/cloud_master/repos/cloud-scripts
```

### 로컬 Kubernetes 클러스터
```bash
# 로컬 K8s 클러스터 생성
./k8s-cluster-create.sh
```

### AWS EKS 클러스터
```bash
# EKS 클러스터 생성
./eks-cluster-create.sh
```

### GCP GKE 클러스터
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

---

## 🔧 5. 문제 해결

### 클러스터 연결 문제
```bash
# GKE 인증 문제 해결
./fix-gke-auth.sh

# 클러스터 연결 테스트
./test-cluster-connection.sh

# 클러스터 문제 해결
./fix-cluster-issues.sh
```

### 컨텍스트 관리
```bash
# kubectl 컨텍스트 확인
kubectl config get-contexts

# 현재 context 확인
kubectl config current-context

# 현재 context가 아닌 경우에만 삭제 가능
kubectl config delete-context <context-name>

# 특정 컨텍스트 사용
kubectl config use-context gke_cloud-deployment-471606_asia-northeast3-a_cloud-master-cluster
kubectl config use-context arn:aws:eks:ap-northeast-2:032068930526:cluster/cloud-master-eks-cluster

# 노드 상태 확인
kubectl get nodes
```

## ⚠️ 중요: WSL 환경에서의 GKE 인증 플러그인 설치

### 문제 상황
- WSL 환경에서 GKE 클러스터 연결 시 `gke-gcloud-auth-plugin` 오류 발생
- Windows에 설치된 Google Cloud SDK를 WSL에서 수정할 권한이 없음

### 해결 방법

#### 1. WSL 관리자 권한으로 실행
```bash
# WSL을 관리자 권한으로 실행
# Windows 시작 메뉴에서 "Ubuntu" 또는 "WSL" 검색 후 "관리자 권한으로 실행"

# Google Cloud SDK 업데이트
sudo gcloud components update

# GKE 인증 플러그인 설치
sudo gcloud components install gke-gcloud-auth-plugin
```

#### 2. 설치 확인
```bash
# 설치된 컴포넌트 확인
gcloud components list | grep -i gke

# 플러그인 실행 확인
gke-gcloud-auth-plugin --version
```

#### 3. 클러스터 연결 테스트
```bash
# GKE 클러스터 연결
gcloud container clusters get-credentials cloud-master-cluster --zone=asia-northeast3-a

# 연결 테스트
kubectl get nodes
```

### 주의사항
- **PC 재시작 필요**: WSL 환경에서 Google Cloud SDK 업데이트 후 PC 재시작 권장
- **관리자 권한 필수**: SDK 업데이트 및 플러그인 설치 시 반드시 WSL 관리자 권한 필요
- **환경 변수 확인**: 설치 후 PATH에 플러그인이 제대로 추가되었는지 확인
```

---

## 🧹 6. 정리 (CleanUp)

### 클러스터 정리
```bash
# 클러스터 대화형 정리
./cluster-cleanup-interactive.sh
```

### VM 정리
```bash
# VM 대화형 정리
./vm-cleanup-interactive.sh
```

---

## 📋 체크리스트

### ✅ 설치 완료 확인
- [ ] WSL 환경 설정
- [ ] 모든 도구 설치 (`./install-all-wsl.sh`)
- [ ] Docker 실행 (`start-docker`)
- [ ] 환경 검증 (`./environment-check-wsl.sh`)

### ✅ Cloud 설정 완료
- [ ] AWS CLI 설정 (`aws configure`)
- [ ] GCP 초기화 (`gcloud init`)
- [ ] AWS 환경 도우미 (`./aws-setup-helper.sh`)
- [ ] GCP 환경 도우미 (`./gcp-setup-helper.sh`)

### ✅ 리소스 배포 완료
- [ ] AWS EC2 배포 (`./aws-ec2-create.sh`)
- [ ] GCP Compute 배포 (`./gcp-compute-create.sh`)

### ✅ Kubernetes 배포 완료
- [ ] 로컬 K8s 클러스터 (`./k8s-cluster-create.sh`)
- [ ] AWS EKS 클러스터 (`./eks-cluster-create.sh`)
- [ ] GCP GKE 클러스터 (GCP Console 또는 gcloud 명령어)
- [ ] 클러스터 연결 확인 (`kubectl get nodes`)

---

## 🎯 빠른 시작 명령어

```bash
# 1. 환경 설정
cd /mnt/c/Users/JIH/githubs/mcp_cloud/mcp_knowledge_base/cloud_master/repos/install
./install-all-wsl.sh && start-docker

# 2. Cloud 설정
aws configure && gcloud init

# 3. VM 배포
./aws-ec2-create.sh && ./gcp-compute-create.sh

# 4. K8s 배포
cd ~/mcp-cloud-workspace/mcp_knowledge_base/cloud_master/repos/cloud-scripts
./k8s-cluster-create.sh && ./eks-cluster-create.sh

# 5. 확인
kubectl get nodes
```

