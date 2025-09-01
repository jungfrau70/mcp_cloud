#!/usr/bin/env bash
set -euo pipefail

# Environment setup
if [ -f "$(dirname "$0")/../../env/aws.env" ]; then
  set -a; . "$(dirname "$0")/../../env/aws.env"; set +a
fi
AWS_REGION="${AWS_REGION:-ap-northeast-2}"
AWS_PROFILE="${AWS_PROFILE:-default}"
KEY_NAME="lab-key"
AMI_ID="${AMI_ID:-ami-0e9bfdb247cc8de84}" # Ubuntu 22.04 in ap-northeast-2
INSTANCE_TYPE="t2.micro"

export AWS_REGION AWS_PROFILE

# Role check
if [ "${ROLE:-it-admin}" = "cost-manager" ]; then
  echo "[DENY] cost-manager role is not allowed to provision compute resources." >&2
  exit 1
fi

# 1. Network Setup (VPC, Subnets, SG)
VPC_ID=$(aws ec2 describe-vpcs --query 'Vpcs[?IsDefault].VpcId | [0]' --output text)
SUBNET_IDS=$(aws ec2 describe-subnets --filters "Name=vpc-id,Values=$VPC_ID" --query 'Subnets[*].SubnetId' --output text)
# Convert space-separated string to comma-separated for ASG
SUBNET_IDS_COMMA=$(echo $SUBNET_IDS | tr ' ' ',')

SG_NAME="lab-web-sg-ha"
SG_ID=$(aws ec2 create-security-group --group-name "$SG_NAME" --description "Web SG for HA" --vpc-id "$VPC_ID" --query 'GroupId' --output text 2>/dev/null || 
      aws ec2 describe-security-groups --filters "Name=group-name,Values=$SG_NAME" --query 'SecurityGroups[0].GroupId' --output text)
aws ec2 authorize-security-group-ingress --group-id "$SG_ID" --protocol tcp --port 80 --cidr 0.0.0.0/0 --no-cli-pager || true
aws ec2 authorize-security-group-ingress --group-id "$SG_ID" --protocol tcp --port 22 --cidr 0.0.0.0/0 --no-cli-pager || true # Note: In production, restrict SSH to your IP

# 2. Launch Template for Auto Scaling
LT_NAME="lab-launch-template"
USER_DATA_SCRIPT=$(cat <<EOF
#!/bin/bash
apt-get update
apt-get install -y nginx
systemctl start nginx
systemctl enable nginx
echo "<h1>Hello from $(hostname -f)</h1>" > /var/www/html/index.html
EOF
)

aws ec2 create-launch-template \
  --launch-template-name "$LT_NAME" \
  --version-description "InitialVersion" \
  --launch-template-data "{\"ImageId\":\"$AMI_ID\",\"InstanceType\":\"$INSTANCE_TYPE\",\"SecurityGroupIds\":[\"$SG_ID\"], \"UserData\":\"$(echo $USER_DATA_SCRIPT | base64 -w 0)\"}" \
  > /dev/null || echo "Launch template $LT_NAME already exists."

# 3. Application Load Balancer (ALB)
ALB_NAME="lab-alb"
TG_NAME="lab-tg"

ALB_ARN=$(aws elbv2 create-load-balancer --name "$ALB_NAME" --type application --subnets $SUBNET_IDS --security-groups "$SG_ID" --query 'LoadBalancers[0].LoadBalancerArn' --output text)
TG_ARN=$(aws elbv2 create-target-group --name "$TG_NAME" --protocol HTTP --port 80 --vpc-id "$VPC_ID" --health-check-path "/" --query 'TargetGroups[0].TargetGroupArn' --output text)
aws elbv2 create-listener --load-balancer-arn "$ALB_ARN" --protocol HTTP --port 80 --default-actions "Type=forward,TargetGroupArn=$TG_ARN" > /dev/null

# 4. Auto Scaling Group (ASG)
ASG_NAME="lab-asg"
aws autoscaling create-auto-scaling-group \
  --auto-scaling-group-name "$ASG_NAME" \
  --launch-template "LaunchTemplateName=$LT_NAME,Version=\\$Latest" \
  --min-size 2 \
  --max-size 4 \
  --desired-capacity 2 \
  --vpc-zone-identifier "$SUBNET_IDS_COMMA" \
  --target-group-arns "$TG_ARN" \
  --health-check-type ELB \
  --health-check-grace-period 300

ALB_DNS=$(aws elbv2 describe-load-balancers --load-balancer-arns "$ALB_ARN" --query 'LoadBalancers[0].DNSName' --output text)

echo "High Availability stack creation initiated."
echo "Auto Scaling Group: $ASG_NAME"
echo "Application Load Balancer DNS: http://$ALB_DNS"

