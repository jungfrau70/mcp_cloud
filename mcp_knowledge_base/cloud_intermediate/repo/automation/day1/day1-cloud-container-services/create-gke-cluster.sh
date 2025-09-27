#!/bin/bash

# GKE 클러스터 생성 스크립트 (참고용)
set -e

CLUSTER_NAME="my-gke-cluster"
ZONE="us-central1-a"
NODE_COUNT=2
MACHINE_TYPE="e2-medium"

echo "Creating GKE cluster: $CLUSTER_NAME"

# 1. GKE 클러스터 생성
gcloud container clusters create $CLUSTER_NAME \
  --zone $ZONE \
  --num-nodes $NODE_COUNT \
  --machine-type $MACHINE_TYPE \
  --enable-autoscaling \
  --min-nodes 1 \
  --max-nodes 3

# 2. 클러스터 연결
gcloud container clusters get-credentials $CLUSTER_NAME --zone $ZONE

echo "GKE cluster created successfully!"
kubectl get nodes
