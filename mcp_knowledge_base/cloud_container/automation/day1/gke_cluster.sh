#!/bin/bash
# GKE 클러스터 생성 및 관리 스크립트

set -e

echo "GKE 클러스터 생성 및 관리 실습 시작..."

# GCP 프로젝트 설정
if [ -z "$PROJECT_ID" ]; then
    echo "ERROR: PROJECT_ID 환경 변수를 설정하세요."
    exit 1
fi

# gcloud 설정
gcloud config set project $PROJECT_ID

# GKE 클러스터 생성
echo "GKE 클러스터 생성 중..."
gcloud container clusters create container-course-cluster     --zone=us-central1-a     --num-nodes=3     --machine-type=e2-medium     --enable-autoscaling     --min-nodes=1     --max-nodes=5     --enable-autorepair     --enable-autoupgrade     --enable-ip-alias     --network=default     --subnetwork=default

# 클러스터 인증 정보 가져오기
gcloud container clusters get-credentials container-course-cluster     --zone=us-central1-a

# 클러스터 정보 확인
echo "GKE 클러스터 정보:"
kubectl cluster-info
kubectl get nodes

# 클러스터 자동 스케일링 설정
cat > cluster-autoscaler.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: cluster-autoscaler
  namespace: kube-system
  labels:
    app: cluster-autoscaler
spec:
  replicas: 1
  selector:
    matchLabels:
      app: cluster-autoscaler
  template:
    metadata:
      labels:
        app: cluster-autoscaler
    spec:
      serviceAccountName: cluster-autoscaler
      containers:
      - image: k8s.gcr.io/autoscaling/cluster-autoscaler:v1.21.0
        name: cluster-autoscaler
        resources:
          limits:
            cpu: 100m
            memory: 300Mi
          requests:
            cpu: 100m
            memory: 300Mi
        command:
        - ./cluster-autoscaler
        - --v=4
        - --stderrthreshold=info
        - --cloud-provider=gce
        - --skip-nodes-with-local-storage=false
        - --expander=least-waste
        - --node-group-auto-discovery=mig:name_prefix=container-course-cluster,min_nodes=1,max_nodes=5
        env:
        - name: GOOGLE_APPLICATION_CREDENTIALS
          value: /etc/ssl/certs/ca-certificates.crt
EOF

# 클러스터 자동 스케일러 배포
kubectl apply -f cluster-autoscaler.yaml

# 워크로드 배포 테스트
cat > workload-test.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: workload-test
  namespace: default
spec:
  replicas: 10
  selector:
    matchLabels:
      app: workload-test
  template:
    metadata:
      labels:
        app: workload-test
    spec:
      containers:
      - name: nginx
        image: nginx:1.21
        resources:
          requests:
            memory: "100Mi"
            cpu: "100m"
          limits:
            memory: "200Mi"
            cpu: "200m"
EOF

# 워크로드 배포
kubectl apply -f workload-test.yaml

# 스케일링 모니터링
echo "스케일링 모니터링 중..."
kubectl get pods -o wide
kubectl get nodes

# 클러스터 정리 (선택사항)
read -p "클러스터를 삭제하시겠습니까? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "GKE 클러스터 삭제 중..."
    gcloud container clusters delete container-course-cluster         --zone=us-central1-a         --quiet
fi

echo "GKE 클러스터 생성 및 관리 실습 완료!"
