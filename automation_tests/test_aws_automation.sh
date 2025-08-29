#!/usr/bin/env bash
set -euo pipefail
set -x # Print commands and their arguments as they are executed.

# --- Environment Setup ---
# Source the AWS environment file
if [ -f "$(dirname "$0")/../env/aws.env" ]; then
  set -a; . "$(dirname "$0")/../env/aws.env"; set +a
fi

# --- Configuration ---
AWS_REGION="${AWS_REGION:-ap-northeast-2}"
AWS_PROFILE="${AWS_PROFILE:-default}"
UNIQUE_SUFFIX=$(head /dev/urandom | tr -dc a-z0-9 | head -c 8)

# Resource Names (using unique suffix to avoid conflicts)
IAM_USER_NAME="test-iam-user-${UNIQUE_SUFFIX}"
IAM_GROUP_NAME="test-iam-group-${UNIQUE_SUFFIX}"
S3_BUCKET_NAME="test-s3-bucket-${UNIQUE_SUFFIX}"
VPC_NAME="test-vpc-${UNIQUE_SUFFIX}"
ALB_NAME="test-alb-${UNIQUE_SUFFIX}"
ASG_NAME="test-asg-${UNIQUE_SUFFIX}"

# --- Functions ---
cleanup() {
    echo "--- Cleaning up AWS resources ---"
    # Delete ASG
    aws autoscaling delete-auto-scaling-group --auto-scaling-group-name "${ASG_NAME}" --force-delete || true
    # Delete ALB and Target Group
    ALB_ARN=$(aws elbv2 describe-load-balancers --names "${ALB_NAME}" --query 'LoadBalancers[0].LoadBalancerArn' --output text || true)
    if [ -n "$ALB_ARN" ]; then
        aws elbv2 delete-load-balancer --load-balancer-arn "$ALB_ARN" || true
    fi
    TG_ARN=$(aws elbv2 describe-target-groups --names "test-tg-${UNIQUE_SUFFIX}" --query 'TargetGroups[0].TargetGroupArn' --output text || true)
    if [ -n "$TG_ARN" ]; then
        aws elbv2 delete-target-group --target-group-arn "$TG_ARN" || true
    fi
    # Delete Launch Template
    aws ec2 delete-launch-template --launch-template-name "lab-launch-template" || true # LT name is hardcoded in ch2_vm.sh
    # Delete NAT Gateway, EIP, VPC, Subnets
    NAT_GW_ID=$(aws ec2 describe-nat-gateways --filter "Name=tag:Name,Values=lab-nat-gw" --query 'NatGateways[0].NatGatewayId' --output text || true)
    if [ -n "$NAT_GW_ID" ]; then
        aws ec2 delete-nat-gateway --nat-gateway-id "$NAT_GW_ID" || true
        aws ec2 wait nat-gateway-deleted --nat-gateway-ids "$NAT_GW_ID" || true
    fi
    EIP_ALLOC_ID=$(aws ec2 describe-addresses --filter "Name=tag:Name,Values=lab-nat-gw" --query 'Addresses[0].AllocationId' --output text || true)
    if [ -n "$EIP_ALLOC_ID" ]; then
        aws ec2 release-address --allocation-id "$EIP_ALLOC_ID" || true
    fi
    VPC_ID=$(aws ec2 describe-vpcs --filter "Name=tag:Name,Values=lab-vpc" --query 'Vpcs[0].VpcId' --output text || true)
    if [ -n "$VPC_ID" ]; then
        aws ec2 delete-vpc --vpc-id "$VPC_ID" || true
    fi
    # Delete S3 Bucket
    aws s3 rb "s3://${S3_BUCKET_NAME}" --force || true
    # Delete IAM User and Group
    aws iam remove-user-from-group --user-name "${IAM_USER_NAME}" --group-name "${IAM_GROUP_NAME}" || true
    aws iam delete-group --group-name "${IAM_GROUP_NAME}" || true
    aws iam delete-user --user-name "${IAM_USER_NAME}" || true
    echo "--- AWS cleanup complete ---"
}

# Register cleanup function to run on exit
trap cleanup EXIT

# --- Execution ---
echo "--- Running AWS Automation Scripts ---"

# Ch1 IAM
echo "Running ch1_iam.sh..."
# Note: ch1_iam.sh creates fixed names, so we need to modify it or ensure cleanup
# For this test, we'll assume it creates a user/group that we can then delete.
# The script itself doesn't take dynamic names easily, so this is a limitation for testing.
# For a robust test, ch1_iam.sh would need to be modified to accept dynamic names.
# For now, we'll just run it and check for a generic user/group.
../mcp_knowledge_base/cloud_basic/automation/cli/aws/ch1_iam.sh

# Ch3 Storage (S3 Bucket)
echo "Running ch3_storage.sh..."
# This script creates a bucket with a random suffix, which is good.
# We need to capture the name it creates for cleanup.
S3_BUCKET_NAME_CREATED=$(../mcp_knowledge_base/cloud_basic/automation/cli/aws/ch3_storage.sh | grep "Bucket created" | awk '{print $NF}')
if [ -z "$S3_BUCKET_NAME_CREATED" ]; then
    echo "Error: Could not determine S3 bucket name from ch3_storage.sh output."
    exit 1
fi
S3_BUCKET_NAME="$S3_BUCKET_NAME_CREATED" # Update for cleanup

# Ch4 Network (VPC, Subnets, NAT Gateway)
echo "Running ch4_network.sh..."
../mcp_knowledge_base/cloud_basic/automation/cli/aws/ch4_network.sh

# Ch2 VM (HA Stack: ALB, ASG)
echo "Running ch2_vm.sh..."
../mcp_knowledge_base/cloud_basic/automation/cli/aws/ch2_vm.sh

echo "--- Verification ---"

# Verify IAM User/Group (ch1_iam.sh creates fixed names, so we check for them)
aws iam get-user --user-name "dev-user" > /dev/null
echo "IAM User 'dev-user' exists."
aws iam get-group --group-name "DevTeam" > /dev/null
echo "IAM Group 'DevTeam' exists."

# Verify S3 Bucket
aws s3api head-bucket --bucket "${S3_BUCKET_NAME}" > /dev/null
echo "S3 Bucket '${S3_BUCKET_NAME}' exists."

# Verify VPC and Subnets (ch4_network.sh creates fixed names)
VPC_ID_VERIFY=$(aws ec2 describe-vpcs --filter "Name=tag:Name,Values=lab-vpc" --query 'Vpcs[0].VpcId' --output text)
if [ -z "$VPC_ID_VERIFY" ]; then echo "VPC 'lab-vpc' not found."; exit 1; fi
echo "VPC 'lab-vpc' exists."
aws ec2 describe-subnets --filter "Name=vpc-id,Values=${VPC_ID_VERIFY}" "Name=tag:Name,Values=public-subnet" --query 'Subnets[0].SubnetId' --output text | grep -q .
echo "Public Subnet exists."
aws ec2 describe-subnets --filter "Name=vpc-id,Values=${VPC_ID_VERIFY}" "Name=tag:Name,Values=private-subnet" --query 'Subnets[0].SubnetId' --output text | grep -q .
echo "Private Subnet exists."
aws ec2 describe-nat-gateways --filter "Name=vpc-id,Values=${VPC_ID_VERIFY}" "Name=tag:Name,Values=lab-nat-gw" --query 'NatGateways[0].NatGatewayId' --output text | grep -q .
echo "NAT Gateway exists."

# Verify ALB and ASG (ch2_vm.sh creates fixed names)
aws elbv2 describe-load-balancers --names "lab-alb" > /dev/null
echo "ALB 'lab-alb' exists."
aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names "lab-asg" > /dev/null
echo "ASG 'lab-asg' exists."

echo "--- All AWS resources verified successfully! ---"
