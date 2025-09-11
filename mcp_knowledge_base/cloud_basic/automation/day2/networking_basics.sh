#!/bin/bash
# 네트워킹 기초 실습 스크립트

set -e

echo "네트워킹 기초 실습 시작..."

# AWS VPC 생성
echo "AWS VPC 생성 중..."
VPC_ID=$(aws ec2 create-vpc --cidr-block 10.0.0.0/16 --query 'Vpc.VpcId' --output text)
aws ec2 create-tags --resources $VPC_ID --tags Key=Name,Value=basic-course-vpc

# 인터넷 게이트웨이 생성
IGW_ID=$(aws ec2 create-internet-gateway --query 'InternetGateway.InternetGatewayId' --output text)
aws ec2 attach-internet-gateway --vpc-id $VPC_ID --internet-gateway-id $IGW_ID

# 서브넷 생성
SUBNET_ID=$(aws ec2 create-subnet --vpc-id $VPC_ID --cidr-block 10.0.1.0/24 --availability-zone us-west-2a --query 'Subnet.SubnetId' --output text)

# 라우트 테이블 생성
ROUTE_TABLE_ID=$(aws ec2 create-route-table --vpc-id $VPC_ID --query 'RouteTable.RouteTableId' --output text)

# 기본 라우트 추가
aws ec2 create-route --route-table-id $ROUTE_TABLE_ID --destination-cidr-block 0.0.0.0/0 --gateway-id $IGW_ID

# 서브넷과 라우트 테이블 연결
aws ec2 associate-route-table --subnet-id $SUBNET_ID --route-table-id $ROUTE_TABLE_ID

# GCP VPC 네트워크 생성
echo "GCP VPC 네트워크 생성 중..."
gcloud compute networks create basic-course-network --subnet-mode custom

# GCP 서브넷 생성
gcloud compute networks subnets create basic-course-subnet     --network=basic-course-network     --range=10.1.0.0/24     --region=us-central1

echo "네트워킹 기초 실습 완료!"
