#!/bin/bash
# Cloud Container 1일차: Kubernetes 고급 아키텍처 실습 스크립트
# 교재: Cloud Container - 1일차: Kubernetes 및 GKE 고급 오케스트레이션

set -e

# 색상 코드 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Cloud Container 1일차: Kubernetes 고급 실습${NC}"
echo -e "${BLUE}========================================${NC}"

# 1. Kubernetes 고급 아키텍처 (150분)
echo -e "\n${YELLOW}1. Kubernetes 고급 아키텍처 실습${NC}"
echo "=========================================="

# kubectl 설치 확인
echo -e "\n${BLUE}1.1 kubectl 설치 확인${NC}"
if ! command -v kubectl &> /dev/null; then
    echo -e "${RED}ERROR: kubectl이 설치되지 않았습니다.${NC}"
    echo -e "${YELLOW}kubectl 설치 가이드를 참조하세요:${NC}"
    echo "https://kubernetes.io/docs/tasks/tools/"
    exit 1
fi

# Kubernetes 클러스터 정보 확인
echo -e "\n${BLUE}1.2 Kubernetes 클러스터 정보 확인${NC}"
echo "Kubernetes 클러스터 정보:"
kubectl cluster-info

# 클러스터 노드 확인
echo -e "\n${BLUE}1.3 클러스터 노드 확인${NC}"
echo "클러스터 노드:"
kubectl get nodes -o wide

# 네임스페이스 생성
echo -e "\n${BLUE}1.4 네임스페이스 생성${NC}"
echo "네임스페이스 생성 중..."
kubectl create namespace container-course --dry-run=client -o yaml | kubectl apply -f -

# Deployment 생성
cat > nginx-deployment.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  namespace: container-course
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
EOF

# Service 생성
cat > nginx-service.yaml << 'EOF'
apiVersion: v1
kind: Service
metadata:
  name: nginx-service
  namespace: container-course
spec:
  selector:
    app: nginx
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
  type: LoadBalancer
EOF

# ConfigMap 생성
cat > nginx-configmap.yaml << 'EOF'
apiVersion: v1
kind: ConfigMap
metadata:
  name: nginx-config
  namespace: container-course
data:
  nginx.conf: |
    events {
        worker_connections 1024;
    }
    http {
        upstream backend {
            server nginx-service:80;
        }
        server {
            listen 80;
            location / {
                proxy_pass http://backend;
            }
        }
    }
EOF

# Secret 생성
cat > nginx-secret.yaml << 'EOF'
apiVersion: v1
kind: Secret
metadata:
  name: nginx-secret
  namespace: container-course
type: Opaque
data:
  username: YWRtaW4=  # admin
  password: cGFzc3dvcmQ=  # password
EOF

# PersistentVolume 생성
cat > nginx-pv.yaml << 'EOF'
apiVersion: v1
kind: PersistentVolume
metadata:
  name: nginx-pv
spec:
  capacity:
    storage: 1Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: /tmp/nginx-data
EOF

# PersistentVolumeClaim 생성
cat > nginx-pvc.yaml << 'EOF'
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: nginx-pvc
  namespace: container-course
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
EOF

# Ingress 생성
cat > nginx-ingress.yaml << 'EOF'
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: nginx-ingress
  namespace: container-course
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  rules:
  - host: nginx.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: nginx-service
            port:
              number: 80
EOF

# 리소스 배포
echo "Kubernetes 리소스 배포 중..."
kubectl apply -f nginx-deployment.yaml
kubectl apply -f nginx-service.yaml
kubectl apply -f nginx-configmap.yaml
kubectl apply -f nginx-secret.yaml
kubectl apply -f nginx-pv.yaml
kubectl apply -f nginx-pvc.yaml
kubectl apply -f nginx-ingress.yaml

# 배포 상태 확인
echo "배포 상태 확인 중..."
kubectl get all -n container-course

# Pod 로그 확인
echo "Pod 로그 확인:"
kubectl logs -n container-course -l app=nginx --tail=10

# 서비스 엔드포인트 확인
echo "서비스 엔드포인트:"
kubectl get svc -n container-course

# 스케일링 테스트
echo "스케일링 테스트 중..."
kubectl scale deployment nginx-deployment --replicas=5 -n container-course
kubectl get pods -n container-course

# 롤백 테스트
echo "롤백 테스트 중..."
kubectl rollout undo deployment/nginx-deployment -n container-course
kubectl rollout status deployment/nginx-deployment -n container-course

echo "Kubernetes 고급 아키텍처 실습 완료!"
