#!/usr/bin/env bash
set -euo pipefail

if [ -f "$(dirname "$0")/../../env/aws.env" ]; then
  set -a; . "$(dirname "$0")/../../env/aws.env"; set +a
fi
AWS_REGION="${AWS_REGION:-ap-northeast-2}"
AWS_PROFILE="${AWS_PROFILE:-default}"
VPC_CIDR="10.0.0.0/16"
PUB_CIDR="10.0.1.0/24"
PRV_CIDR="10.0.2.0/24"

export AWS_REGION AWS_PROFILE

if [ "${ROLE:-it-admin}" = "cost-manager" ]; then
  echo "[DENY] cost-manager role is not allowed to modify network resources." >&2
  exit 1
fi

VPC_ID=$(aws ec2 create-vpc --cidr-block "$VPC_CIDR" --query 'Vpc.VpcId' --output text)
aws ec2 modify-vpc-attribute --vpc-id "$VPC_ID" --enable-dns-hostnames

IGW_ID=$(aws ec2 create-internet-gateway --query 'InternetGateway.InternetGatewayId' --output text)
aws ec2 attach-internet-gateway --internet-gateway-id "$IGW_ID" --vpc-id "$VPC_ID"

PUB_SUBNET=$(aws ec2 create-subnet --vpc-id "$VPC_ID" --cidr-block "$PUB_CIDR" --query 'Subnet.SubnetId' --output text)
PRV_SUBNET=$(aws ec2 create-subnet --vpc-id "$VPC_ID" --cidr-block "$PRV_CIDR" --query 'Subnet.SubnetId' --output text)

PUB_RT=$(aws ec2 create-route-table --vpc-id "$VPC_ID" --query 'RouteTable.RouteTableId' --output text)
aws ec2 create-route --route-table-id "$PUB_RT" --destination-cidr-block 0.0.0.0/0 --gateway-id "$IGW_ID"
aws ec2 associate-route-table --route-table-id "$PUB_RT" --subnet-id "$PUB_SUBNET"

echo "AWS VPC: $VPC_ID  PublicSubnet: $PUB_SUBNET  PrivateSubnet: $PRV_SUBNET"

