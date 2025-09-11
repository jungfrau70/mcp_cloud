#!/bin/bash
# 가상머신 서비스 기초 실습 스크립트

set -e

echo "가상머신 서비스 기초 실습 시작..."

# AWS EC2 인스턴스 생성
echo "AWS EC2 인스턴스 생성 중..."
INSTANCE_NAME="basic-course-instance"
KEY_NAME="basic-course-key"
SECURITY_GROUP_NAME="basic-course-sg"

# 키 페어 생성
aws ec2 create-key-pair --key-name $KEY_NAME --query 'KeyMaterial' --output text > $KEY_NAME.pem
chmod 400 $KEY_NAME.pem

# 보안 그룹 생성
aws ec2 create-security-group --group-name $SECURITY_GROUP_NAME --description "Basic Course Security Group" || echo "보안 그룹이 이미 존재합니다."

# 보안 그룹 규칙 설정
aws ec2 authorize-security-group-ingress --group-name $SECURITY_GROUP_NAME --protocol tcp --port 22 --cidr 0.0.0.0/0
aws ec2 authorize-security-group-ingress --group-name $SECURITY_GROUP_NAME --protocol tcp --port 80 --cidr 0.0.0.0/0

# EC2 인스턴스 생성
aws ec2 run-instances     --image-id ami-0c02fb55956c7d316     --count 1     --instance-type t2.micro     --key-name $KEY_NAME     --security-groups $SECURITY_GROUP_NAME     --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value='$INSTANCE_NAME'}]'

# GCP Compute Engine 인스턴스 생성
echo "GCP Compute Engine 인스턴스 생성 중..."
GCP_INSTANCE_NAME="basic-course-instance"
ZONE="us-central1-a"

# GCP 인스턴스 생성
gcloud compute instances create $GCP_INSTANCE_NAME     --zone=$ZONE     --machine-type=e2-micro     --image-family=ubuntu-2004-lts     --image-project=ubuntu-os-cloud     --boot-disk-size=10GB     --boot-disk-type=pd-standard     --tags=basic-course

# 방화벽 규칙 생성
gcloud compute firewall-rules create allow-ssh-http     --allow tcp:22,tcp:80     --source-ranges 0.0.0.0/0     --target-tags basic-course

# 인스턴스 상태 확인
echo "AWS EC2 인스턴스 상태:"
aws ec2 describe-instances --filters "Name=tag:Name,Values=$INSTANCE_NAME" --query 'Reservations[].Instances[].State.Name' --output table

echo "GCP Compute Engine 인스턴스 상태:"
gcloud compute instances list --filter="name=$GCP_INSTANCE_NAME"

echo "가상머신 서비스 기초 실습 완료!"
echo "생성된 리소스:"
echo "- AWS EC2 인스턴스: $INSTANCE_NAME"
echo "- GCP Compute Engine 인스턴스: $GCP_INSTANCE_NAME"
