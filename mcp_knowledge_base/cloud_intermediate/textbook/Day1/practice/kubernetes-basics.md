# ☸️ Kubernetes 기초

## 🎯 학습 목표

### 핵심 학습 목표
- **Kubernetes 기본 개념** 클러스터 아키텍처, 핵심 구성 요소 이해
- **기본 리소스 관리** Pod, Service, Deployment, ConfigMap, Secret 관리

### 실습 후 달성할 수 있는 능력
- ✅ Kubernetes 클러스터에서 애플리케이션 배포 및 관리
- ✅ Pod, Service, Deployment를 활용한 기본적인 워크로드 관리
- ✅ ConfigMap과 Secret을 통한 설정 및 민감 정보 관리

### 예상 소요 시간
- **Kubernetes 기본 개념**: 60-90분
- **기본 리소스 관리**: 90-120분
- **전체 과정**: 2.5-3.5시간

---

## 🛠️ 실습 학습

### 📁 실습 코드 및 자동화
- **실습 샘플 코드**: `/mcp_knowledge_base/cloud_intermediate/repo/samples/day1/kubernetes-basics/`
- **자동화 스크립트**: `/mcp_knowledge_base/cloud_intermediate/repo/scripts/kubernetes-basics-practice.sh`
- **클라우드 스크립트**: `/mcp_knowledge_base/cloud_intermediate/repo/cloud-scripts/`

<details>
<summary>🚀 실습 환경 준비</summary>

#### 필수 도구
- **kubectl**: Kubernetes 클러스터 관리
- **minikube**: 로컬 Kubernetes 환경 ["선택사항"]
- **Docker Desktop**: Kubernetes 활성화 ["선택사항"]

#### 환경 설정
```bash
# kubectl 설치 확인
kubectl version --client

# Kubernetes 클러스터 연결 확인
kubectl cluster-info

# 노드 상태 확인
kubectl get nodes

# 네임스페이스 확인
kubectl get namespaces
```

</details>

<details>
<summary>🔧 1단계: Kubernetes 기본 개념</summary>

#### 클러스터 아키텍처 이해
```bash
# 클러스터 정보 확인
kubectl cluster-info

# 노드 상세 정보 확인
kubectl describe nodes

# 클러스터 구성 요소 확인
kubectl get pods -n kube-system

# API 서버 버전 확인
kubectl version
```

#### 기본 명령어 실습
```bash
# 리소스 목록 확인
kubectl get all
kubectl get pods
kubectl get services
kubectl get deployments

# 리소스 상세 정보 확인
kubectl describe pod <pod-name>
kubectl describe service <service-name>
kubectl describe deployment <deployment-name>

# 리소스 로그 확인
kubectl logs <pod-name>
kubectl logs -f <pod-name>  # 실시간 로그
```

</details>

<details>
<summary>🔧 2단계: Pod 관리</summary>

#### Pod 생성 및 관리
```yaml
# pod-basic.yaml
apiVersion: v1
kind: Pod
metadata:
  name: myapp-pod
  labels:
    app: myapp
    tier: frontend
spec:
  containers:
  - name: myapp
    image: nginx:1.21
    ports:
    - containerPort: 80
    env:
    - name: ENV
      value: "development"
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
```

#### Pod 실습
```bash
# Pod 생성
kubectl apply -f pod-basic.yaml

# Pod 상태 확인
kubectl get pods
kubectl describe pod myapp-pod

# Pod 로그 확인
kubectl logs myapp-pod

# Pod 내부 접속
kubectl exec -it myapp-pod -- /bin/bash

# Pod 삭제
kubectl delete pod myapp-pod
```

</details>

<details>
<summary>🔧 3단계: Service 및 Deployment</summary>

#### Deployment 생성
```yaml
# deployment-basic.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp-deployment
  labels:
    app: myapp
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
```

#### Service 생성
```yaml
# service-basic.yaml
apiVersion: v1
kind: Service
metadata:
  name: myapp-service
  labels:
    app: myapp
spec:
  selector:
    app: myapp
  ports:
  - port: 80
    targetPort: 80
    protocol: TCP
  type: ClusterIP
```

#### Service 및 Deployment 실습
```bash
# Deployment 생성
kubectl apply -f deployment-basic.yaml

# Service 생성
kubectl apply -f service-basic.yaml

# 상태 확인
kubectl get deployments
kubectl get services
kubectl get pods

# 스케일링
kubectl scale deployment myapp-deployment --replicas=5

# 롤링 업데이트
kubectl set image deployment/myapp-deployment myapp=nginx:1.22

# 롤백
kubectl rollout undo deployment/myapp-deployment

# 배포 상태 확인
kubectl rollout status deployment/myapp-deployment
```

</details>

<details>
<summary>🔧 4단계: ConfigMap 및 Secret</summary>

#### ConfigMap 생성
```yaml
# configmap-basic.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: myapp-config
data:
  database_url: "postgresql://localhost:5432/myapp"
  redis_url: "redis://localhost:6379"
  app_name: "My Application"
  environment: "development"
```

#### Secret 생성
```yaml
# secret-basic.yaml
apiVersion: v1
kind: Secret
metadata:
  name: myapp-secret
type: Opaque
data:
  username: YWRtaW4=  # base64 encoded "admin"
  password: cGFzc3dvcmQ=  # base64 encoded "password"
  api_key: YWJjZGVmZ2hpams=  # base64 encoded "abcdefghijk"
```

#### ConfigMap 및 Secret 사용
```yaml
# pod-with-config.yaml
apiVersion: v1
kind: Pod
metadata:
  name: myapp-pod-with-config
spec:
  containers:
  - name: myapp
    image: nginx:1.21
    env:
    - name: DATABASE_URL
      valueFrom:
        configMapKeyRef:
          name: myapp-config
          key: database_url
    - name: REDIS_URL
      valueFrom:
        configMapKeyRef:
          name: myapp-config
          key: redis_url
    - name: USERNAME
      valueFrom:
        secretKeyRef:
          name: myapp-secret
          key: username
    - name: PASSWORD
      valueFrom:
        secretKeyRef:
          name: myapp-secret
          key: password
    volumeMounts:
    - name: config-volume
      mountPath: /etc/config
    - name: secret-volume
      mountPath: /etc/secret
      readOnly: true
  volumes:
  - name: config-volume
    configMap:
      name: myapp-config
  - name: secret-volume
    secret:
      secretName: myapp-secret
```

#### ConfigMap 및 Secret 실습
```bash
# ConfigMap 생성
kubectl apply -f configmap-basic.yaml

# Secret 생성
kubectl apply -f secret-basic.yaml

# Pod 생성
kubectl apply -f pod-with-config.yaml

# 설정 확인
kubectl describe configmap myapp-config
kubectl describe secret myapp-secret

# Pod 내부에서 설정 확인
kubectl exec -it myapp-pod-with-config -- env | grep -E "[DATABASE_URL|REDIS_URL|USERNAME|PASSWORD]"

# 볼륨 마운트 확인
kubectl exec -it myapp-pod-with-config -- ls -la /etc/config
kubectl exec -it myapp-pod-with-config -- ls -la /etc/secret
```

</details>

---

## 📚 참고 자료

### 유용한 명령어
```bash
# Kubernetes 기본 명령어
kubectl get all  # 모든 리소스 확인
kubectl describe <resource> <name>  # 리소스 상세 정보
kubectl logs -f <pod-name>  # 실시간 로그 확인
kubectl exec -it <pod-name> -- /bin/bash  # Pod 내부 접속

# 리소스 관리
kubectl apply -f <file>  # 리소스 생성/업데이트
kubectl delete -f <file>  # 리소스 삭제
kubectl edit <resource> <name>  # 리소스 편집

# 디버깅
kubectl get events  # 이벤트 확인
kubectl top nodes  # 노드 리소스 사용량
kubectl top pods  # Pod 리소스 사용량
```

### 문제 해결
1. **Pod 시작 실패**
   - 이미지 이름 및 태그 확인
   - 리소스 제한 확인
   - 노드 상태 확인
   - 이벤트 로그 확인

2. **Service 연결 실패**
   - Selector 라벨 확인
   - 포트 설정 확인
   - 네트워크 정책 확인

3. **ConfigMap/Secret 접근 실패**
   - 리소스 존재 여부 확인
   - 키 이름 확인
   - 권한 설정 확인

---

## 🧹 실습 정리

### 자동 정리
```bash
# Kubernetes 기초 실습 자동 정리
./mcp_knowledge_base/cloud_intermediate/repo/scripts/kubernetes-basics-practice.sh --cleanup
```

### 수동 정리
```bash
# 리소스 삭제
kubectl delete -f pod-basic.yaml
kubectl delete -f deployment-basic.yaml
kubectl delete -f service-basic.yaml
kubectl delete -f configmap-basic.yaml
kubectl delete -f secret-basic.yaml
kubectl delete -f pod-with-config.yaml

# 모든 리소스 확인
kubectl get all
```

### 정리 확인
- [ ] Pod 삭제 완료
- [ ] Deployment 삭제 완료
- [ ] Service 삭제 완료
- [ ] ConfigMap 삭제 완료
- [ ] Secret 삭제 완료

---

## 🔗 관련 자료

### 📚 실습 가이드
- ["Docker 고급 활용"][docker-advanced.md]
- ["클라우드 컨테이너 서비스"][cloud-container-services.md]

### 🛠️ 설치 가이드
- ["kubectl 설치"][_setup_wsl/install-kubectl-wsl.sh]
- ["minikube 설치"][_setup_wsl/install-minikube-wsl.sh]

### 🏠 네비게이션
<div align="center">

["← 이전: Docker 고급 활용"][docker-advanced.md] | 
["📚 전체 커리큘럼"][../../../curriculum.md] | 
["🏠 학습 경로로 돌아가기"][../../../index.md] | 
["다음: 클라우드 컨테이너 서비스 →"][cloud-container-services.md]

</div>
