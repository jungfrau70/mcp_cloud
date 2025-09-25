# ☁️ 클라우드 컨테이너 서비스

## 🎯 학습 목표

### 핵심 학습 목표
- **AWS EKS** Elastic Kubernetes Service를 활용한 클라우드 Kubernetes 관리
- **GCP GKE** Google Kubernetes Engine을 활용한 클라우드 Kubernetes 관리

### 실습 후 달성할 수 있는 능력
- ✅ AWS EKS 클러스터 생성 및 관리
- ✅ GCP GKE 클러스터 생성 및 관리
- ✅ 클라우드 Kubernetes 서비스 비교 및 선택

### 예상 소요 시간
- **AWS EKS**: 90-120분
- **GCP GKE**: 90-120분
- **전체 과정**: 3-4시간

---

## 🛠️ 실습 학습

### 📁 실습 코드 및 자동화
- **실습 샘플 코드**: `/mcp_knowledge_base/cloud_intermediate/repo/samples/day1/cloud-container-services/`
- **자동화 스크립트**: `/mcp_knowledge_base/cloud_intermediate/repo/scripts/cloud-container-services-practice.sh`
- **클라우드 스크립트**: `/mcp_knowledge_base/cloud_intermediate/repo/cloud-scripts/`

<details>
<summary>🚀 실습 환경 준비</summary>

#### 필수 도구
- **AWS CLI**: AWS 서비스 관리
- **GCP CLI**: GCP 서비스 관리
- **kubectl**: Kubernetes 클러스터 관리
- **eksctl**: EKS 클러스터 관리 ["선택사항"]

#### 환경 설정
```bash
# AWS CLI 설정 확인
aws --version
aws configure list

# GCP CLI 설정 확인
gcloud --version
gcloud auth list

# kubectl 설치 확인
kubectl version --client

# eksctl 설치 확인 ["선택사항"]
eksctl version
```

</details>

<details>
<summary>🔧 1단계: AWS EKS 클러스터 생성</summary>

#### EKS 클러스터 생성 ["eksctl 사용"]
```bash
# EKS 클러스터 생성
eksctl create cluster \
  --name my-eks-cluster \
  --region us-west-2 \
  --nodegroup-name workers \
  --node-type t3.medium \
  --nodes 2 \
  --nodes-min 1 \
  --nodes-max 3 \
  --managed

# 클러스터 상태 확인
eksctl get cluster --name my-eks-cluster --region us-west-2

# 노드 그룹 확인
eksctl get nodegroup --cluster my-eks-cluster --region us-west-2
```

#### EKS 클러스터 생성 ["AWS CLI 사용"]
```bash
# EKS 클러스터 생성
aws eks create-cluster \
  --name my-eks-cluster \
  --role-arn arn:aws:iam::123456789012:role/eksServiceRole \
  --resources-vpc-config subnetIds=subnet-12345,subnet-67890,securityGroupIds=sg-12345 \
  --region us-west-2

# 클러스터 상태 확인
aws eks describe-cluster --name my-eks-cluster --region us-west-2

# 노드 그룹 생성
aws eks create-nodegroup \
  --cluster-name my-eks-cluster \
  --nodegroup-name workers \
  --node-role arn:aws:iam::123456789012:role/eksNodeRole \
  --subnets subnet-12345 subnet-67890 \
  --instance-types t3.medium \
  --scaling-config minSize=1,maxSize=3,desiredSize=2 \
  --region us-west-2
```

#### EKS 클러스터 연결
```bash
# kubeconfig 업데이트
aws eks update-kubeconfig --region us-west-2 --name my-eks-cluster

# 클러스터 연결 확인
kubectl cluster-info
kubectl get nodes

# 클러스터 인증 확인
kubectl auth can-i get pods
```

</details>

<details>
<summary>🔧 2단계: GCP GKE 클러스터 생성</summary>

#### GKE 클러스터 생성
```bash
# GKE 클러스터 생성
gcloud container clusters create my-gke-cluster \
  --zone us-central1-a \
  --num-nodes 2 \
  --machine-type e2-medium \
  --enable-autoscaling \
  --min-nodes 1 \
  --max-nodes 3 \
  --enable-autorepair \
  --enable-autoupgrade

# 클러스터 상태 확인
gcloud container clusters describe my-gke-cluster --zone us-central1-a

# 노드 풀 확인
gcloud container node-pools list --cluster my-gke-cluster --zone us-central1-a
```

#### GKE 클러스터 연결
```bash
# 클러스터 인증 정보 가져오기
gcloud container clusters get-credentials my-gke-cluster --zone us-central1-a

# 클러스터 연결 확인
kubectl cluster-info
kubectl get nodes

# 클러스터 인증 확인
kubectl auth can-i get pods
```

</details>

<details>
<summary>🔧 3단계: 클라우드 Kubernetes 서비스 비교</summary>

#### AWS EKS vs GCP GKE 비교
```bash
# AWS EKS 클러스터 정보
aws eks describe-cluster --name my-eks-cluster --region us-west-2

# GCP GKE 클러스터 정보
gcloud container clusters describe my-gke-cluster --zone us-central1-a

# 비용 비교 ["예시"]
echo "AWS EKS 비용:"
echo "- 클러스터: $0.10/시간"
echo "- 노드: t3.medium $0.0416/시간"
echo "- 총 예상 비용: $0.1832/시간"

echo "GCP GKE 비용:"
echo "- 클러스터: $0.10/시간"
echo "- 노드: e2-medium $0.033512/시간"
echo "- 총 예상 비용: $0.167024/시간"
```

#### 기능 비교
```bash
# AWS EKS 기능
echo "AWS EKS 주요 기능:"
echo "- AWS Load Balancer Controller"
echo "- AWS EBS CSI Driver"
echo "- AWS EFS CSI Driver"
echo "- AWS IAM Authenticator"
echo "- AWS CloudWatch 통합"

# GCP GKE 기능
echo "GCP GKE 주요 기능:"
echo "- Google Cloud Load Balancer"
echo "- Google Cloud Persistent Disk"
echo "- Google Cloud Filestore"
echo "- Google Cloud IAM 통합"
echo "- Google Cloud Monitoring 통합"
```

</details>

<details>
<summary>🔧 4단계: 애플리케이션 배포</summary>

#### AWS EKS에 애플리케이션 배포
```yaml
# deployment-eks.yaml
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
        resources:
          requests:
            memory: "64Mi"
            cpu: "250m"
          limits:
            memory: "128Mi"
            cpu: "500m"
---
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
```

#### GCP GKE에 애플리케이션 배포
```yaml
# deployment-gke.yaml
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
        resources:
          requests:
            memory: "64Mi"
            cpu: "250m"
          limits:
            memory: "128Mi"
            cpu: "500m"
---
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
```

#### 배포 실습
```bash
# AWS EKS에 배포
kubectl apply -f deployment-eks.yaml

# GCP GKE에 배포
kubectl apply -f deployment-gke.yaml

# 배포 상태 확인
kubectl get deployments
kubectl get services
kubectl get pods

# 로드 밸런서 확인
kubectl get services myapp-service
```

</details>

---

## 📚 참고 자료

### 유용한 명령어
```bash
# AWS EKS 명령어
eksctl get cluster  # 클러스터 목록
eksctl get nodegroup --cluster <cluster-name>  # 노드 그룹 목록
eksctl delete cluster --name <cluster-name>  # 클러스터 삭제

# GCP GKE 명령어
gcloud container clusters list  # 클러스터 목록
gcloud container node-pools list --cluster <cluster-name>  # 노드 풀 목록
gcloud container clusters delete <cluster-name>  # 클러스터 삭제

# Kubernetes 명령어
kubectl cluster-info  # 클러스터 정보
kubectl get nodes  # 노드 목록
kubectl top nodes  # 노드 리소스 사용량
```

### 문제 해결
1. **EKS 클러스터 생성 실패**
   - IAM 역할 확인
   - 서브넷 및 보안 그룹 확인
   - 리전 및 가용 영역 확인

2. **GKE 클러스터 생성 실패**
   - 프로젝트 권한 확인
   - API 활성화 확인
   - 리소스 할당량 확인

3. **클러스터 연결 실패**
   - kubeconfig 설정 확인
   - 네트워크 연결 확인
   - 인증 정보 확인

---

## 🧹 실습 정리

### 자동 정리
```bash
# 클라우드 컨테이너 서비스 실습 자동 정리
./mcp_knowledge_base/cloud_intermediate/repo/scripts/cloud-container-services-practice.sh --cleanup
```

### 수동 정리
```bash
# AWS EKS 리소스 정리
kubectl delete -f deployment-eks.yaml
eksctl delete cluster --name my-eks-cluster --region us-west-2

# GCP GKE 리소스 정리
kubectl delete -f deployment-gke.yaml
gcloud container clusters delete my-gke-cluster --zone us-central1-a

# kubeconfig 정리
kubectl config delete-context <context-name>
```

### 정리 확인
- [ ] AWS EKS 클러스터 삭제 완료
- [ ] GCP GKE 클러스터 삭제 완료
- [ ] 애플리케이션 배포 정리 완료
- [ ] 비용 발생 확인

---

## 🔗 관련 자료

### 📚 실습 가이드
- ["Docker 고급 활용"][docker-advanced.md]
- ["Kubernetes 기초"][kubernetes-basics.md]

### 🛠️ 설치 가이드
- ["AWS CLI 설정"][_setup_wsl/install-aws-cli-wsl.sh]
- ["GCP CLI 설정"][_setup_wsl/install-gcp-cli-wsl.sh]
- ["kubectl 설치"][_setup_wsl/install-kubectl-wsl.sh]
- ["eksctl 설치"][_setup_wsl/install-eksctl-wsl.sh]

### 🏠 네비게이션
<div align="center">

["← 이전: Kubernetes 기초"][kubernetes-basics.md] | 
["📚 전체 커리큘럼"][../../../curriculum.md] | 
["🏠 학습 경로로 돌아가기"][../../../index.md] | 
["다음: Day 2 →"][../../Day2/README.md]

</div>
