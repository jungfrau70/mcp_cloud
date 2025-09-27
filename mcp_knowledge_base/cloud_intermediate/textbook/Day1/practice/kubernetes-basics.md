# ☸️ Kubernetes 기초 실습

> 📋 **실습 시간**: 90분  
> 📋 **난이도**: 중급  
> 📋 **선수 학습**: Docker 기초, 컨테이너 개념  
> 📋 **실습 환경**: minikube 또는 로컬 Kubernetes 클러스터

## 🎯 학습 목표

### 핵심 학습 목표
- **Kubernetes 기본 개념**: Pod, Service, Deployment 이해
- **리소스 관리**: ConfigMap, Secret을 활용한 설정 관리
- **네임스페이스**: 리소스 격리 및 쿼터 관리

### 실습 후 달성할 수 있는 능력
- ✅ Kubernetes 기본 리소스 생성 및 관리
- ✅ ConfigMap과 Secret을 활용한 설정 관리
- ✅ 네임스페이스와 리소스 쿼터 관리
- ✅ Pod 상태 모니터링 및 디버깅

### 예상 소요 시간
- **Kubernetes 환경 준비**: 15분
- **네임스페이스 및 기본 리소스**: 25분
- **Deployment 및 Service**: 30분
- **ConfigMap 및 Secret**: 20분

---

## 🛠️ 실습 환경 준비

### 📁 실습 코드 및 자동화
- **실습 샘플 코드**: `/mcp_knowledge_base/cloud_intermediate/repos/samples/day1/kubernetes-basics/`
- **자동화 스크립트**: `/mcp_knowledge_base/cloud_intermediate/repos/automation/day1/kubernetes-basics-practice-automation.sh`
- **클라우드 스크립트**: `/mcp_knowledge_base/cloud_intermediate/repos/cloud-scripts/`

<details>
<summary>🚀 실습 환경 준비</summary>

#### 필수 도구
- **kubectl**: Kubernetes 클러스터 관리
- **minikube**: 로컬 Kubernetes 클러스터
- **Docker**: 컨테이너 런타임

#### 환경 설정
```bash
# kubectl 설치
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/

# minikube 설치
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube

# minikube 시작
minikube start --driver=docker
```

</details>

<details>
<summary>🔧 1단계: Kubernetes 환경 준비</summary>

#### 실습 디렉토리 생성
```bash
# 실습 디렉토리 생성
mkdir -p ~/cloud_intermediate/samples/day1/kubernetes-basics
cd ~/cloud_intermediate/samples/day1/kubernetes-basics

# 실습 샘플 코드 복사 (있는 경우)
cp -r /mcp_knowledge_base/cloud_intermediate/repos/samples/day1/kubernetes-basics/* ./
```

#### Kubernetes 클러스터 확인
```bash
# kubectl 설정 확인
kubectl config current-context

# 클러스터 정보 확인
kubectl cluster-info

# 노드 상태 확인
kubectl get nodes

# 기본 리소스 확인
kubectl get all
```

#### 네임스페이스 생성
```bash
# 네임스페이스 YAML 생성
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

# 네임스페이스 생성
kubectl apply -f namespace.yaml

# 네임스페이스 확인
kubectl get namespaces
kubectl describe namespace cloud-intermediate
```

</details>

<details>
<summary>🔧 2단계: Deployment 및 Service 생성</summary>

#### nginx Deployment 생성
```bash
# nginx-deployment.yaml 생성
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

# Deployment 및 Service 생성
kubectl apply -f nginx-deployment.yaml

# 리소스 상태 확인
kubectl get all -n cloud-intermediate
kubectl describe deployment nginx-deployment -n cloud-intermediate
kubectl describe service nginx-service -n cloud-intermediate
```

#### Pod 상태 모니터링
```bash
# Pod 상태 확인
kubectl get pods -n cloud-intermediate

# Pod 상세 정보 확인
kubectl describe pod -l app=nginx -n cloud-intermediate

# Pod 로그 확인
kubectl logs -l app=nginx -n cloud-intermediate

# Pod 내부 접속
kubectl exec -it deployment/nginx-deployment -n cloud-intermediate -- /bin/bash
```

</details>

<details>
<summary>🔧 3단계: ConfigMap 및 Secret 실습</summary>

#### ConfigMap 및 Secret 생성
```bash
# configmap-secret.yaml 생성
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

# ConfigMap 및 Secret 생성
kubectl apply -f configmap-secret.yaml

# ConfigMap 및 Secret 확인
kubectl get configmaps -n cloud-intermediate
kubectl get secrets -n cloud-intermediate
kubectl describe configmap app-config -n cloud-intermediate
kubectl describe secret app-secret -n cloud-intermediate
```

#### 환경 변수 확인
```bash
# 환경 변수 확인
kubectl exec -n cloud-intermediate deployment/app-with-config -- env | grep -E "(DATABASE_URL|APP_NAME|USERNAME|PASSWORD)"

# ConfigMap 내용 확인
kubectl get configmap app-config -n cloud-intermediate -o yaml

# Secret 내용 확인 (base64 디코딩)
kubectl get secret app-secret -n cloud-intermediate -o jsonpath='{.data.username}' | base64 -d
kubectl get secret app-secret -n cloud-intermediate -o jsonpath='{.data.password}' | base64 -d
```

</details>

---

## 📚 참고 자료

### 유용한 명령어
```bash
# Kubernetes 리소스 관리
kubectl get all -n <namespace>
kubectl describe <resource> <name> -n <namespace>
kubectl logs <pod-name> -n <namespace>

# 디버깅
kubectl exec -it <pod-name> -n <namespace> -- /bin/bash
kubectl port-forward <pod-name> 8080:80 -n <namespace>
```

### 문제 해결
1. **Pod가 Pending 상태**
   - 리소스 부족 확인: `kubectl describe pod <pod-name>`
   - 노드 상태 확인: `kubectl get nodes`

2. **Service 연결 안됨**
   - Service selector 확인
   - Pod label 확인: `kubectl get pods --show-labels`

3. **ConfigMap/Secret 적용 안됨**
   - 환경 변수 확인: `kubectl exec <pod> -- env`
   - 볼륨 마운트 확인: `kubectl describe pod <pod>`

---

## 🧹 실습 정리

### 자동 정리
```bash
# Day1 Kubernetes 실습 자동 정리
./mcp_knowledge_base/cloud_intermediate/repos/automation/day1/kubernetes-basics-practice-automation.sh --cleanup
```

### 수동 정리
```bash
# 네임스페이스 삭제 (모든 리소스 포함)
kubectl delete namespace cloud-intermediate

# 개별 리소스 삭제
kubectl delete deployment nginx-deployment -n cloud-intermediate
kubectl delete service nginx-service -n cloud-intermediate
kubectl delete configmap app-config -n cloud-intermediate
kubectl delete secret app-secret -n cloud-intermediate
```

### 정리 확인
- [ ] 네임스페이스 삭제 완료
- [ ] 모든 Pod 정리 완료
- [ ] ConfigMap/Secret 정리 완료
- [ ] 리소스 쿼터 해제 확인

---

## 🎯 학습 성과 확인

### 실습 완료 체크리스트
- [ ] Kubernetes 네임스페이스 생성 완료
- [ ] Deployment 및 Service 생성 성공
- [ ] ConfigMap과 Secret 설정 완료
- [ ] Pod 상태 정상 확인
- [ ] 환경 변수 정상 주입 확인

### 다음 단계
- **클라우드 컨테이너 서비스** 실습으로 진행
- **통합 모니터링 허브** 구축 실습 준비
- **AWS ECS** 및 **GCP Cloud Run** 실습

---

**💡 궁금한 점이 있으시면 언제든 문의해주세요!**  
**문제가 발생하거나 도움이 필요하시면 실시간으로 지원해드리겠습니다.**
