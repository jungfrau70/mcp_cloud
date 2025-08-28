#!/usr/bin/env bash
set -euo pipefail

if [ -f "$(dirname "$0")/../../env/aws.env" ]; then
  set -a; . "$(dirname "$0")/../../env/aws.env"; set +a
fi
AWS_REGION="${AWS_REGION:-ap-northeast-2}"
AWS_PROFILE="${AWS_PROFILE:-default}"
KEY_NAME="lab-key"
AMI_ID="${AMI_ID:-ami-0e9bfdb247cc8de84}" # Ubuntu 22.04 in ap-northeast-2 (example)
INSTANCE_TYPE="t2.micro"
SEC_GRP_NAME="lab-web-sg"

export AWS_REGION AWS_PROFILE

if [ "${ROLE:-it-admin}" = "cost-manager" ]; then
  echo "[DENY] cost-manager role is not allowed to provision compute resources." >&2
  exit 1
fi

VPC_ID=$(aws ec2 describe-vpcs --query 'Vpcs[0].VpcId' --output text)
SUBNET_ID=$(aws ec2 describe-subnets --filters Name=vpc-id,Values=$VPC_ID --query 'Subnets[0].SubnetId' --output text)

aws ec2 create-key-pair --key-name "$KEY_NAME" --query 'KeyMaterial' --output text > "${KEY_NAME}.pem" || true
chmod 600 "${KEY_NAME}.pem"

SG_ID=$(aws ec2 create-security-group --group-name "$SEC_GRP_NAME" --description "Web SG" --vpc-id "$VPC_ID" --query 'GroupId' --output text 2>/dev/null || true)
if [ -n "${SG_ID:-}" ]; then
  aws ec2 authorize-security-group-ingress --group-id "$SG_ID" --protocol tcp --port 22 --cidr 0.0.0.0/0 || true
  aws ec2 authorize-security-group-ingress --group-id "$SG_ID" --protocol tcp --port 80 --cidr 0.0.0.0/0 || true
else
  SG_ID=$(aws ec2 describe-security-groups --filters Name=group-name,Values=$SEC_GRP_NAME --query 'SecurityGroups[0].GroupId' --output text)
fi

INSTANCE_ID=$(aws ec2 run-instances --image-id "$AMI_ID" --instance-type "$INSTANCE_TYPE" \
  --key-name "$KEY_NAME" --subnet-id "$SUBNET_ID" --security-group-ids "$SG_ID" \
  --query 'Instances[0].InstanceId' --output text)

aws ec2 wait instance-running --instance-ids "$INSTANCE_ID"
PUBLIC_IP=$(aws ec2 describe-instances --instance-ids "$INSTANCE_ID" --query 'Reservations[0].Instances[0].PublicIpAddress' --output text)

echo "EC2 running: $INSTANCE_ID  PublicIP: $PUBLIC_IP"
echo "SSH: ssh -i ${KEY_NAME}.pem ubuntu@${PUBLIC_IP}"

