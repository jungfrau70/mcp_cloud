#!/bin/bash

# EKS 클러스터 생성 스크립트
set -e

CLUSTER_NAME="my-eks-cluster"
REGION="us-west-2"
NODE_GROUP_NAME="my-node-group"
NODE_TYPE="t3.medium"
NODE_COUNT=2

echo "Creating EKS cluster: $CLUSTER_NAME"

# 1. EKS 클러스터 생성
aws eks create-cluster \
  --name $CLUSTER_NAME \
  --version "1.28" \
  --role-arn arn:aws:iam::ACCOUNT:role/eksServiceRole \
  --resources-vpc-config subnetIds=subnet-12345,subnet-67890,securityGroupIds=sg-12345 \
  --region $REGION

echo "Waiting for cluster to be active..."
aws eks wait cluster-active --name $CLUSTER_NAME --region $REGION

# 2. Node Group 생성
aws eks create-nodegroup \
  --cluster-name $CLUSTER_NAME \
  --nodegroup-name $NODE_GROUP_NAME \
  --scaling-config minSize=1,maxSize=3,desiredSize=$NODE_COUNT \
  --instance-types $NODE_TYPE \
  --node-role arn:aws:iam::ACCOUNT:role/eksNodeRole \
  --subnets subnet-12345 subnet-67890 \
  --region $REGION

echo "Waiting for node group to be active..."
aws eks wait nodegroup-active --cluster-name $CLUSTER_NAME --nodegroup-name $NODE_GROUP_NAME --region $REGION

# 3. kubeconfig 업데이트
aws eks update-kubeconfig --name $CLUSTER_NAME --region $REGION

echo "EKS cluster created successfully!"
kubectl get nodes
