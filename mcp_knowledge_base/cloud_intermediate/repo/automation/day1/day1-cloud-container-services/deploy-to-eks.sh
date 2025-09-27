#!/bin/bash

# EKS 배포 스크립트
set -e

CLUSTER_NAME="my-eks-cluster"
REGION="us-west-2"
NAMESPACE="day1-practice"

echo "Deploying to EKS cluster: $CLUSTER_NAME"

# 1. 클러스터 연결 확인
if ! kubectl cluster-info &> /dev/null; then
    echo "Connecting to EKS cluster..."
    aws eks update-kubeconfig --name $CLUSTER_NAME --region $REGION
fi

# 2. 네임스페이스 생성
kubectl create namespace $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -

# 3. 애플리케이션 배포
kubectl apply -f eks-deployment.yaml

# 4. 배포 상태 확인
echo "Waiting for deployment to be ready..."
kubectl rollout status deployment/myapp-eks -n $NAMESPACE --timeout=300s

# 5. 서비스 상태 확인
kubectl get services -n $NAMESPACE
kubectl get pods -n $NAMESPACE

# 6. LoadBalancer 엔드포인트 확인
echo "Getting LoadBalancer endpoint..."
kubectl get service myapp-eks-service -n $NAMESPACE -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'

echo "Deployment completed successfully!"
