# ☸️ Kubernetes 기초 실습 (현행화)

> 📋 **실습 시간**: 120분  
> 📋 **난이도**: 중급  
> 📋 **선수 학습**: Docker 기초, 컨테이너 개념  
> 📋 **실습 환경**: AWS EKS, GCP GKE, 로컬 Kubernetes 클러스터

## 🎯 학습 목표

### 핵심 학습 목표
- **Kubernetes 클러스터 Context 구성**: EKS, GKE 클러스터 연결 및 전환
- **Workload 배포**: Pod, Deployment, Service 생성 및 관리
- **외부 접근 구성**: LoadBalancer, NodePort, Ingress 설정
- **문제 해결**: 방화벽, 보안 그룹, 네트워크 문제 진단 및 해결

### 실습 후 달성할 수 있는 능력
- ✅ Kubernetes 클러스터 Context 구성 및 전환
- ✅ Pod, Deployment, Service, ConfigMap, Secret 관리
- ✅ LoadBalancer 외부 접근 구성 (EKS ALB, GKE GLB)
- ✅ 네트워크 문제 진단 및 해결
- ✅ 클라우드별 LoadBalancer 최적화 설정

### 예상 소요 시간
- **클러스터 Context 구성**: 20분
- **Workload 배포**: 40분
- **외부 접근 구성**: 40분
- **문제 해결 및 최적화**: 20분

---

## 🛠️ 실습 환경 준비

### 📁 실습 코드 및 자동화
- **실습 샘플 코드**: `/cloud_intermediate/repo/samples/day1/`
- **자동화 스크립트**: `/cloud_intermediate/repo/automation/day1/day1-practice.sh`
- **문제 해결 도구**: `/cloud_intermediate/repo/automation/day1/eks-lb-troubleshoot.sh`

<details>
<summary>🚀 실습 환경 준비</summary>

#### 필수 도구
- **kubectl**: Kubernetes 클러스터 관리
- **AWS CLI**: AWS EKS 클러스터 관리
- **Google Cloud CLI**: GCP GKE 클러스터 관리
- **Docker**: 컨테이너 런타임

#### 환경 설정
```bash
# kubectl 설치 확인
kubectl version --client

# AWS CLI 설치 확인
aws --version
aws configure list

# Google Cloud CLI 설치 확인
gcloud --version
gcloud auth list

# Docker 설치 확인
docker --version
```

</details>

---

## 🔧 1단계: Kubernetes 클러스터 Context 구성

### 📋 Step 1-1: AWS EKS 클러스터 연결

#### AWS CLI 설정 확인
```bash
# AWS CLI 설정 확인
aws configure list

# AWS 자격 증명 확인
aws sts get-caller-identity

# EKS 클러스터 목록 확인
aws eks list-clusters --region ap-northeast-2
```

#### EKS 클러스터 연결
```bash
# EKS 클러스터 kubeconfig 업데이트
aws eks update-kubeconfig --region ap-northeast-2 --name cloud-intermediate-eks

# 현재 컨텍스트 확인
kubectl config current-context

# 클러스터 정보 확인
kubectl cluster-info

# 노드 상태 확인
kubectl get nodes
```

### 📋 Step 1-2: GCP GKE 클러스터 연결

#### Google Cloud CLI 설정
```bash
# Google Cloud 인증 확인
gcloud auth list

# 프로젝트 설정
gcloud config set project YOUR_PROJECT_ID

# GKE 클러스터 목록 확인
gcloud container clusters list --region asia-northeast1
```

#### GKE 클러스터 연결
```bash
# GKE 클러스터 kubeconfig 가져오기
gcloud container clusters get-credentials cloud-intermediate-gke --region asia-northeast1

# 현재 컨텍스트 확인
kubectl config current-context

# 클러스터 정보 확인
kubectl cluster-info

# 노드 상태 확인
kubectl get nodes
```

### 📋 Step 1-3: 클러스터 전환

#### 사용 가능한 컨텍스트 확인
```bash
# 모든 컨텍스트 목록 확인
kubectl config get-contexts

# 현재 컨텍스트 확인
kubectl config current-context

# 컨텍스트 전환
kubectl config use-context arn:aws:eks:ap-northeast-2:ACCOUNT:cluster/cloud-intermediate-eks
kubectl config use-context gke_PROJECT_ID_REGION_cloud-intermediate-gke
```

#### 자동화 스크립트 사용
```bash
# 실습 스크립트 실행
cd /home/ec2-user/mcp-cloud-workspace/mcp_cloud/cloud_intermediate/repo/automation/day1
./day1-practice.sh

# 메뉴에서 "2. 클러스터 전환 (EKS ↔ GKE)" 선택
```

---

## 🔧 2단계: Workload 배포

### 📋 Step 2-1: 네임스페이스 생성

#### 네임스페이스 YAML 생성
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

### 📋 Step 2-2: Pod 생성 및 관리

#### 단일 Pod 생성
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

# Pod 로그 확인
kubectl logs myapp-pod -n day1-practice

# Pod 내부 접속
kubectl exec -it myapp-pod -n day1-practice -- /bin/bash
```

### 📋 Step 2-3: Deployment 생성 및 관리

#### Deployment YAML 생성
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

# Pod 상태 확인
kubectl get pods -n day1-practice -l app=myapp
```

### 📋 Step 2-4: Service 생성 및 관리

#### ClusterIP Service 생성
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

# Service 엔드포인트 확인
kubectl get endpoints -n day1-practice
```

### 📋 Step 2-5: ConfigMap 및 Secret 관리

#### ConfigMap 및 Secret 생성
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

---

## 🔧 3단계: 외부 접근 구성

### 📋 Step 3-1: NodePort Service 배포

#### NodePort Service 생성
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

# NodePort 접근 테스트
kubectl get nodes -o wide
# 노드의 External IP로 접근: http://NODE_IP:30080
```

### 📋 Step 3-2: LoadBalancer Service 배포 (EKS ALB)

#### EKS ALB LoadBalancer 생성
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
```

#### EKS ALB 접근 테스트
```bash
# External IP 확인
EXTERNAL_IP=$(kubectl get service myapp-service-lb -n day1-practice -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')

# ALB 접근 테스트
curl -I http://$EXTERNAL_IP

# 브라우저에서 접근: http://$EXTERNAL_IP
```

### 📋 Step 3-3: LoadBalancer Service 배포 (GKE GLB)

#### GKE GLB LoadBalancer 생성
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
```

#### GKE GLB 접근 테스트
```bash
# External IP 확인
EXTERNAL_IP=$(kubectl get service myapp-service-gke-lb -n day1-practice -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

# GLB 접근 테스트
curl -I http://$EXTERNAL_IP

# 브라우저에서 접근: http://$EXTERNAL_IP
```

### 📋 Step 3-4: Ingress 설정 (EKS ALB)

#### Ingress YAML 생성
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

### 📋 Step 3-5: 포트 포워딩 테스트

#### 포트 포워딩 설정
```bash
# 포트 포워딩 시작
kubectl port-forward service/myapp-service 8080:80 -n day1-practice

# 다른 터미널에서 접근 테스트
curl http://localhost:8080

# 포트 포워딩 중지: Ctrl+C
```

---

## 🔧 4단계: 문제 해결 및 최적화

### 📋 Step 4-1: LoadBalancer 문제 진단

#### EKS LoadBalancer 문제 해결
```bash
# 문제 해결 스크립트 실행
cd /home/ec2-user/mcp-cloud-workspace/mcp_cloud/cloud_intermediate/repo/automation/day1
./eks-lb-troubleshoot.sh diagnose

# 자동 문제 해결
./eks-lb-troubleshoot.sh fix

# 접근 테스트
./eks-lb-troubleshoot.sh test http://YOUR_ALB_URL
```

#### 수동 문제 진단
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

### 📋 Step 4-2: 네트워크 연결 테스트

#### Pod 내부에서 테스트
```bash
# Pod 내부 접속
kubectl exec -it deployment/myapp-deployment -n day1-practice -- /bin/bash

# Pod 내부에서 서비스 테스트
curl http://myapp-service.day1-practice.svc.cluster.local
curl http://myapp-service-lb.day1-practice.svc.cluster.local

# Pod 내부에서 외부 접근 테스트
curl -I http://httpbin.org/status/200
```

#### 외부에서 LoadBalancer 테스트
```bash
# External IP 확인
kubectl get service myapp-service-lb -n day1-practice -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'

# 외부 접근 테스트
curl -I http://YOUR_ALB_URL
curl -v http://YOUR_ALB_URL

# 응답 시간 측정
curl -w "@curl-format.txt" -o /dev/null -s http://YOUR_ALB_URL
```

### 📋 Step 4-3: 성능 최적화

#### 리소스 모니터링
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

#### LoadBalancer 최적화
```bash
# EKS ALB 최적화
kubectl annotate service myapp-service-lb -n day1-practice \
  service.beta.kubernetes.io/aws-load-balancer-type=nlb

# GKE GLB 최적화
kubectl annotate service myapp-service-gke-lb -n day1-practice \
  cloud.google.com/load-balancer-type=External \
  cloud.google.com/neg='{"ingress": true}'
```

---

## 📚 참고 자료

### 유용한 명령어
```bash
# Kubernetes 리소스 관리
kubectl get all -n day1-practice
kubectl describe <resource> <name> -n day1-practice
kubectl logs <pod-name> -n day1-practice

# 디버깅
kubectl exec -it <pod-name> -n day1-practice -- /bin/bash
kubectl port-forward <pod-name> 8080:80 -n day1-practice

# 클러스터 정보
kubectl cluster-info
kubectl config current-context
kubectl config get-contexts
```

### 문제 해결 가이드
1. **Pod가 Pending 상태**
   - 리소스 부족 확인: `kubectl describe pod <pod-name>`
   - 노드 상태 확인: `kubectl get nodes`

2. **Service 연결 안됨**
   - Service selector 확인
   - Pod label 확인: `kubectl get pods --show-labels`

3. **LoadBalancer External IP 할당 안됨**
   - 보안 그룹 확인 (EKS)
   - 방화벽 규칙 확인 (GKE)
   - 클러스터 상태 확인

4. **외부 접근 안됨**
   - 방화벽 규칙 확인
   - 보안 그룹 설정 확인
   - DNS 전파 대기 (2-3분)

---

## 🧹 실습 정리

### 자동 정리
```bash
# Day1 Kubernetes 실습 자동 정리
cd /home/ec2-user/mcp-cloud-workspace/mcp_cloud/cloud_intermediate/repo/automation/day1
./day1-practice.sh
# 메뉴에서 "정리" 옵션 선택
```

### 수동 정리
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

### 정리 확인
- [ ] 네임스페이스 삭제 완료
- [ ] 모든 Pod 정리 완료
- [ ] LoadBalancer 삭제 완료
- [ ] ConfigMap/Secret 정리 완료
- [ ] 리소스 쿼터 해제 확인

---

## 🎯 학습 성과 확인

### 실습 완료 체크리스트
- [ ] Kubernetes 클러스터 Context 구성 완료
- [ ] Pod, Deployment, Service 생성 성공
- [ ] ConfigMap과 Secret 설정 완료
- [ ] LoadBalancer 외부 접근 구성 완료
- [ ] 문제 해결 및 최적화 완료

### 다음 단계
- **클라우드 컨테이너 서비스** 실습으로 진행
- **통합 모니터링 허브** 구축 실습 준비
- **AWS ECS** 및 **GCP Cloud Run** 실습

---

**💡 궁금한 점이 있으시면 언제든 문의해주세요!**  
**문제가 발생하거나 도움이 필요하시면 실시간으로 지원해드리겠습니다.**
