#!/bin/bash
# 보안 그룹 및 방화벽 실습 스크립트

set -e

echo "보안 그룹 및 방화벽 실습 시작..."

# AWS 보안 그룹 생성
echo "AWS 보안 그룹 생성 중..."
SECURITY_GROUP_ID=$(aws ec2 create-security-group --group-name basic-course-sg --description "Basic Course Security Group" --vpc-id $VPC_ID --query 'GroupId' --output text)

# 보안 그룹 규칙 설정
aws ec2 authorize-security-group-ingress --group-id $SECURITY_GROUP_ID --protocol tcp --port 22 --cidr 0.0.0.0/0
aws ec2 authorize-security-group-ingress --group-id $SECURITY_GROUP_ID --protocol tcp --port 80 --cidr 0.0.0.0/0
aws ec2 authorize-security-group-ingress --group-id $SECURITY_GROUP_ID --protocol tcp --port 443 --cidr 0.0.0.0/0

# GCP 방화벽 규칙 생성
echo "GCP 방화벽 규칙 생성 중..."
gcloud compute firewall-rules create allow-ssh-http-https     --network=basic-course-network     --allow tcp:22,tcp:80,tcp:443     --source-ranges 0.0.0.0/0     --target-tags basic-course

echo "보안 그룹 및 방화벽 실습 완료!"
