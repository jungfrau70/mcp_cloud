# Cloud Master - 2일차: Kubernetes 기초 실습

<details>
<summary>📋 목차</summary>

["📚 이론 학습"][#-]

["🛠️ 실습 학습"]["#실습-학습"]

["📚 참고 자료"]["#참고-자료"]

["📚 문제 해결 및 참고 자료"][#-]

</details>

---

## 🎯 학습 목표

### 핵심 학습 목표

- **Kubernetes 기초** 클러스터 개념 및 kubectl 명령어
- **Pod 관리** Pod 생성, 배포, 스케일링
- **Service 관리** 네트워킹 및 서비스 디스커버리
- **Deployment 관리** 애플리케이션 배포 및 업데이트

### 실습 후 달성할 수 있는 능력

- ✅ Kubernetes 클러스터 기본 명령어 사용
- ✅ Pod, Service, Deployment 리소스 관리
- ✅ 애플리케이션 배포 및 스케일링
- ✅ 기본적인 트러블슈팅

### 예상 소요 시간

- **Kubernetes 기초**: 90-120분
- **Pod 관리**: 60-90분
- **Service 관리**: 60-90분
- **Deployment 관리**: 90-120분
- **전체 과정**: 5-7시간

---

## 🛠️ 실습 학습

### 📁 실습 코드 및 자동화
- **실습 샘플 코드**: `/mcp_knowledge_base/cloud_master/repos/samples/day2/my-app/`
- **자동화 스크립트**: `/mcp_knowledge_base/cloud_master/repos/automation/day2/kubernetes-practice-automation.sh`
- **클라우드 스크립트**: `/mcp_knowledge_base/cloud_master/repos/cloud-scripts/`

<details>
<summary>🚀 실습 환경 준비</summary>

#### 필수 도구

- **kubectl**: Kubernetes 클러스터 관리 도구
- **minikube**: 로컬 Kubernetes 클러스터
- **Docker**: 컨테이너 실행 환경

#### 환경 설정

```bash
# kubectl 설치 확인
kubectl version --client

# minikube 설치 확인
minikube version

# 클러스터 시작
minikube start

# 클러스터 상태 확인
kubectl cluster-info
```

</details>

<details>
<summary>🐳 1단계: Pod 기초 실습</summary>

#### Pod 생성

```bash
# 기본 Pod 생성
kubectl run nginx-pod --image=nginx:latest

# Pod 상태 확인
kubectl get pods

# Pod 상세 정보 확인
kubectl describe pod nginx-pod

# Pod 로그 확인
kubectl logs nginx-pod
```

#### Pod 삭제

```bash
# Pod 삭제
kubectl delete pod nginx-pod
```

</details>

<details>
<summary>🌐 2단계: Service 실습</summary>

#### Service 생성

```bash
# Deployment 생성
kubectl create deployment nginx-deployment --image=nginx:latest --replicas=3

# Service 생성
kubectl expose deployment nginx-deployment --port=80 --type=NodePort

# Service 확인
kubectl get services

# Service 접근 테스트
minikube service nginx-deployment
```

#### Service 삭제

```bash
# Service 삭제
kubectl delete service nginx-deployment

# Deployment 삭제
kubectl delete deployment nginx-deployment
```

</details>

<details>
<summary>🚀 3단계: Deployment 실습</summary>

#### Deployment 생성

```yaml
# nginx-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
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
        image: nginx:latest
        ports:
        - containerPort: 80
```

```bash
# Deployment 적용
kubectl apply -f nginx-deployment.yaml

# Deployment 상태 확인
kubectl get deployments

# Pod 상태 확인
kubectl get pods -l app=nginx
```

#### 스케일링

```bash
# Replica 수 변경
kubectl scale deployment nginx-deployment --replicas=5

# 상태 확인
kubectl get pods -l app=nginx
```

</details>

<details>
<summary>🔧 4단계: 고급 실습</summary>

#### ConfigMap 사용

```bash
# ConfigMap 생성
kubectl create configmap nginx-config --from-literal=server_name=my-nginx

# ConfigMap 확인
kubectl get configmaps
kubectl describe configmap nginx-config
```

#### Secret 사용

```bash
# Secret 생성
kubectl create secret generic nginx-secret --from-literal=password=secret123

# Secret 확인
kubectl get secrets
kubectl describe secret nginx-secret
```

</details>

---

## 📚 참고 자료

### 유용한 명령어

```bash
# 리소스 목록 확인
kubectl get all

# 네임스페이스 생성
kubectl create namespace practice

# 네임스페이스 전환
kubectl config set-context --current --namespace=practice

# 리소스 삭제
kubectl delete all --all

# 네임스페이스 삭제
kubectl delete namespace practice
```

### 문제 해결

1. **Pod가 Pending 상태**
   - 리소스 부족 확인
   - 노드 상태 확인

2. **Service 접근 불가**
   - 포트 매핑 확인
   - 방화벽 설정 확인

3. **Deployment 업데이트 실패**
   - 이미지 태그 확인
   - 리소스 제한 확인

---

## 🧹 실습 정리

### 자동 정리

```bash
# 자동화 스크립트로 정리
./mcp_knowledge_base/cloud_master/repos/automation/day2/kubernetes-practice-automation.sh --cleanup
```

### 수동 정리

```bash
# 모든 리소스 삭제
kubectl delete all --all

# 네임스페이스 정리
kubectl delete namespace practice 2>/dev/null || true

# minikube 정리
minikube delete
```

### 정리 확인

- [ ] 모든 Pod 삭제
- [ ] 모든 Service 삭제
- [ ] 모든 Deployment 삭제
- [ ] 네임스페이스 정리
- [ ] 클러스터 정리
