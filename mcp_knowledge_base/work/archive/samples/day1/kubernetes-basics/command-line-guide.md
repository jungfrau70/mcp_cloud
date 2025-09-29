# 🚀 Kubernetes 기초 실습 - 명령줄 단위 가이드

## 📋 실습 진행 순서

### 🔧 1단계: 클러스터 Context 구성

#### 1-1. AWS EKS 클러스터 연결
```bash
# AWS CLI 설정 확인
aws configure list
aws sts get-caller-identity

# EKS 클러스터 목록 확인
aws eks list-clusters --region ap-northeast-2

# EKS 클러스터 kubeconfig 업데이트
aws eks update-kubeconfig --region ap-northeast-2 --name cloud-intermediate-eks

# 현재 컨텍스트 확인
kubectl config current-context

# 클러스터 정보 확인
kubectl cluster-info
kubectl get nodes
```

#### 1-2. GCP GKE 클러스터 연결
```bash
# Google Cloud 인증 확인
gcloud auth list
gcloud config set project YOUR_PROJECT_ID

# GKE 클러스터 목록 확인
gcloud container clusters list --region asia-northeast1

# GKE 클러스터 kubeconfig 가져오기
gcloud container clusters get-credentials cloud-intermediate-gke --region asia-northeast1

# 현재 컨텍스트 확인
kubectl config current-context
kubectl cluster-info
kubectl get nodes
```

#### 1-3. 클러스터 전환
```bash
# 모든 컨텍스트 목록 확인
kubectl config get-contexts

# EKS로 전환
kubectl config use-context arn:aws:eks:ap-northeast-2:ACCOUNT:cluster/cloud-intermediate-eks

# GKE로 전환
kubectl config use-context gke_PROJECT_ID_REGION_cloud-intermediate-gke
```

### 🔧 2단계: Workload 배포

#### 2-1. 네임스페이스 생성
```bash
# 실습 디렉토리 생성
mkdir -p day1-kubernetes-basics
cd day1-kubernetes-basics

# 네임스페이스 YAML 생성
cat > namespace.yaml << 'EOF'
apiVersion: v1
kind: Namespace
metadata:
  name: day1-practice
  labels:
    name: day1-practice
    environment: learning
---
apiVersion: v1
kind: ResourceQuota
metadata:
  name: compute-quota
  namespace: day1-practice
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
kubectl describe namespace day1-practice
```

#### 2-2. Pod 생성
```bash
# Pod YAML 생성
cat > myapp-pod.yaml << 'EOF'
apiVersion: v1
kind: Pod
metadata:
  name: myapp-pod
  namespace: day1-practice
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
EOF

# Pod 생성
kubectl apply -f myapp-pod.yaml

# Pod 상태 확인
kubectl get pods -n day1-practice
kubectl describe pod myapp-pod -n day1-practice
kubectl logs myapp-pod -n day1-practice
```

#### 2-3. Deployment 생성
```bash
# Deployment YAML 생성
cat > myapp-deployment.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp-deployment
  namespace: day1-practice
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
EOF

# Deployment 생성
kubectl apply -f myapp-deployment.yaml

# Deployment 상태 확인
kubectl get deployment -n day1-practice
kubectl describe deployment myapp-deployment -n day1-practice
kubectl get pods -n day1-practice -l app=myapp
```

#### 2-4. Service 생성
```bash
# ClusterIP Service YAML 생성
cat > myapp-service.yaml << 'EOF'
apiVersion: v1
kind: Service
metadata:
  name: myapp-service
  namespace: day1-practice
  labels:
    app: myapp
spec:
  type: ClusterIP
  ports:
  - port: 80
    targetPort: 80
    protocol: TCP
  selector:
    app: myapp
EOF

# Service 생성
kubectl apply -f myapp-service.yaml

# Service 상태 확인
kubectl get service -n day1-practice
kubectl describe service myapp-service -n day1-practice
kubectl get endpoints -n day1-practice
```

#### 2-5. ConfigMap 및 Secret 생성
```bash
# ConfigMap YAML 생성
cat > myapp-configmap.yaml << 'EOF'
apiVersion: v1
kind: ConfigMap
metadata:
  name: myapp-config
  namespace: day1-practice
data:
  database_url: "mysql://localhost:3306/mydb"
  app_name: "Cloud Intermediate App"
  environment: "learning"
  log_level: "info"
EOF

# Secret YAML 생성
cat > myapp-secret.yaml << 'EOF'
apiVersion: v1
kind: Secret
metadata:
  name: myapp-secret
  namespace: day1-practice
type: Opaque
data:
  username: YWRtaW4=  # admin (base64 encoded)
  password: cGFzc3dvcmQ=  # password (base64 encoded)
  api_key: YWJjZGVmZ2hpams=  # abcdefghijk (base64 encoded)
EOF

# ConfigMap 및 Secret 생성
kubectl apply -f myapp-configmap.yaml
kubectl apply -f myapp-secret.yaml

# ConfigMap 및 Secret 확인
kubectl get configmaps -n day1-practice
kubectl get secrets -n day1-practice
kubectl describe configmap myapp-config -n day1-practice
kubectl describe secret myapp-secret -n day1-practice
```

### 🔧 3단계: 외부 접근 구성

#### 3-1. NodePort Service 생성
```bash
# NodePort Service YAML 생성
cat > myapp-service-nodeport.yaml << 'EOF'
apiVersion: v1
kind: Service
metadata:
  name: myapp-service-np
  namespace: day1-practice
  labels:
    app: myapp
spec:
  type: NodePort
  ports:
  - port: 80
    targetPort: 80
    nodePort: 30080
    protocol: TCP
  selector:
    app: myapp
EOF

# NodePort Service 생성
kubectl apply -f myapp-service-nodeport.yaml

# NodePort Service 상태 확인
kubectl get service myapp-service-np -n day1-practice

# 노드 IP 확인
kubectl get nodes -o wide

# NodePort 접근 테스트 (노드 IP:30080)
curl http://NODE_IP:30080
```

#### 3-2. EKS ALB LoadBalancer 생성
```bash
# EKS ALB LoadBalancer YAML 생성
cat > myapp-service-loadbalancer.yaml << 'EOF'
apiVersion: v1
kind: Service
metadata:
  name: myapp-service-lb
  namespace: day1-practice
  labels:
    app: myapp
spec:
  type: LoadBalancer
  ports:
  - port: 80
    targetPort: 80
    protocol: TCP
  selector:
    app: myapp
EOF

# LoadBalancer Service 생성
kubectl apply -f myapp-service-loadbalancer.yaml

# LoadBalancer 상태 확인
kubectl get service myapp-service-lb -n day1-practice

# External IP 할당 대기 (1-2분 소요)
kubectl get service myapp-service-lb -n day1-practice -w

# External IP 확인
EXTERNAL_IP=$(kubectl get service myapp-service-lb -n day1-practice -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')

# ALB 접근 테스트
curl -I http://$EXTERNAL_IP
```

#### 3-3. GKE GLB LoadBalancer 생성
```bash
# GKE GLB LoadBalancer YAML 생성
cat > myapp-service-gke-lb.yaml << 'EOF'
apiVersion: v1
kind: Service
metadata:
  name: myapp-service-gke-lb
  namespace: day1-practice
  labels:
    app: myapp
  annotations:
    cloud.google.com/load-balancer-type: "External"
spec:
  type: LoadBalancer
  ports:
  - port: 80
    targetPort: 80
    protocol: TCP
  selector:
    app: myapp
EOF

# GKE LoadBalancer Service 생성
kubectl apply -f myapp-service-gke-lb.yaml

# LoadBalancer 상태 확인
kubectl get service myapp-service-gke-lb -n day1-practice

# External IP 할당 대기 (1-2분 소요)
kubectl get service myapp-service-gke-lb -n day1-practice -w

# External IP 확인
EXTERNAL_IP=$(kubectl get service myapp-service-gke-lb -n day1-practice -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

# GLB 접근 테스트
curl -I http://$EXTERNAL_IP
```

#### 3-4. Ingress 설정 (EKS ALB)
```bash
# Ingress YAML 생성
cat > myapp-ingress.yaml << 'EOF'
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: myapp-ingress
  namespace: day1-practice
  annotations:
    kubernetes.io/ingress.class: "alb"
    alb.ingress.kubernetes.io/scheme: internet-facing
    alb.ingress.kubernetes.io/target-type: ip
    alb.ingress.kubernetes.io/listen-ports: '[{"HTTP": 80}]'
spec:
  rules:
  - host: myapp.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: myapp-service
            port:
              number: 80
EOF

# Ingress 생성
kubectl apply -f myapp-ingress.yaml

# Ingress 상태 확인
kubectl get ingress -n day1-practice
kubectl describe ingress myapp-ingress -n day1-practice
```

#### 3-5. 포트 포워딩 테스트
```bash
# 포트 포워딩 시작
kubectl port-forward service/myapp-service 8080:80 -n day1-practice

# 다른 터미널에서 접근 테스트
curl http://localhost:8080

# 포트 포워딩 중지: Ctrl+C
```

### 🔧 4단계: 문제 해결 및 최적화

#### 4-1. LoadBalancer 문제 진단
```bash
# 문제 해결 스크립트 실행
cd /home/ec2-user/mcp-cloud-workspace/mcp_cloud/cloud_intermediate/repo/automation/day1
./eks-lb-troubleshoot.sh diagnose

# 자동 문제 해결
./eks-lb-troubleshoot.sh fix

# 접근 테스트
./eks-lb-troubleshoot.sh test http://YOUR_ALB_URL
```

#### 4-2. 수동 문제 진단
```bash
# 1. Pod 상태 확인
kubectl get pods -n day1-practice
kubectl describe pods -n day1-practice

# 2. Service 상태 확인
kubectl get service -n day1-practice
kubectl describe service myapp-service-lb -n day1-practice

# 3. 엔드포인트 확인
kubectl get endpoints -n day1-practice

# 4. 보안 그룹 확인 (EKS)
aws eks describe-cluster --name cloud-intermediate-eks --query 'cluster.resourcesVpcConfig.securityGroupIds'
aws ec2 describe-security-groups --group-ids sg-xxxxxxxxx

# 5. 방화벽 규칙 추가 (필요시)
aws ec2 authorize-security-group-ingress --group-id sg-xxxxxxxxx --protocol tcp --port 80 --cidr 0.0.0.0/0
aws ec2 authorize-security-group-ingress --group-id sg-xxxxxxxxx --protocol tcp --port 443 --cidr 0.0.0.0/0
```

#### 4-3. 성능 최적화
```bash
# Pod 리소스 사용량 확인
kubectl top pods -n day1-practice

# 노드 리소스 사용량 확인
kubectl top nodes

# Deployment 스케일링
kubectl scale deployment myapp-deployment --replicas=5 -n day1-practice

# HPA (Horizontal Pod Autoscaler) 설정
kubectl autoscale deployment myapp-deployment --cpu-percent=50 --min=3 --max=10 -n day1-practice
```

### 🔧 5단계: 실습 정리

#### 5-1. 자동 정리
```bash
# Day1 Kubernetes 실습 자동 정리
cd /home/ec2-user/mcp-cloud-workspace/mcp_cloud/cloud_intermediate/repo/automation/day1
./day1-practice.sh
# 메뉴에서 "정리" 옵션 선택
```

#### 5-2. 수동 정리
```bash
# 네임스페이스 삭제 (모든 리소스 포함)
kubectl delete namespace day1-practice

# 개별 리소스 삭제
kubectl delete deployment myapp-deployment -n day1-practice
kubectl delete service myapp-service -n day1-practice
kubectl delete service myapp-service-lb -n day1-practice
kubectl delete configmap myapp-config -n day1-practice
kubectl delete secret myapp-secret -n day1-practice
```

## 🛠️ 자동화 도구 사용법

### 실습 스크립트 실행
```bash
# 메인 실습 스크립트 실행
cd /home/ec2-user/mcp-cloud-workspace/mcp_cloud/cloud_intermediate/repo/automation/day1
./day1-practice.sh

# 메뉴 선택:
# 1. Docker 고급 활용
# 2. Kubernetes 기초 실습
# 3. 클라우드 컨테이너 서비스
# 4. 통합 모니터링 허브
```

### Kubernetes 기초 실습 서브 메뉴
```bash
# Kubernetes 기초 실습 서브 메뉴
# 1. K8s 클러스터 컨텍스트 구성 및 체크
# 2. 클러스터 전환 (EKS ↔ GKE)
# 3. Pod 생성 및 관리
# 4. Deployment 생성 및 관리
# 5. Service 생성 및 관리
# 6. ConfigMap 및 Secret 관리
# 7. 전체 K8s 리소스 배포
# 8. LoadBalancer 서비스 배포 (EKS ALB / GKE GLB)
# 9. NodePort 서비스 배포
# 10. Ingress 설정
# 11. 포트 포워딩 테스트
# 12. 리소스 상태 확인
```

### 문제 해결 도구
```bash
# EKS LoadBalancer 문제 해결
./eks-lb-troubleshoot.sh diagnose    # 종합 진단
./eks-lb-troubleshoot.sh fix         # 문제 자동 해결
./eks-lb-troubleshoot.sh test <URL>  # 접근 테스트
```

## 📊 실습 진행 상황 체크리스트

### ✅ 1단계: 클러스터 Context 구성
- [ ] AWS EKS 클러스터 연결
- [ ] GCP GKE 클러스터 연결
- [ ] 클러스터 전환 테스트

### ✅ 2단계: Workload 배포
- [ ] 네임스페이스 생성
- [ ] Pod 생성 및 관리
- [ ] Deployment 생성 및 관리
- [ ] Service 생성 및 관리
- [ ] ConfigMap 및 Secret 관리

### ✅ 3단계: 외부 접근 구성
- [ ] NodePort Service 배포
- [ ] EKS ALB LoadBalancer 배포
- [ ] GKE GLB LoadBalancer 배포
- [ ] Ingress 설정
- [ ] 포트 포워딩 테스트

### ✅ 4단계: 문제 해결 및 최적화
- [ ] LoadBalancer 문제 진단
- [ ] 네트워크 연결 테스트
- [ ] 성능 최적화

### ✅ 5단계: 실습 정리
- [ ] 자동 정리 실행
- [ ] 수동 정리 확인
- [ ] 리소스 정리 완료

---

**💡 각 단계별로 명령어를 순서대로 실행하시면 됩니다!**  
**문제가 발생하면 자동화 도구를 활용하여 해결하세요.**
