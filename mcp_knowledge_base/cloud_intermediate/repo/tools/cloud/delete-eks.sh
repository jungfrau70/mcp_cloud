#!/bin/bash
set -euo pipefail

# Load environment file
ENV_FILE=$(basename "$0")
if [[ ! -f "$ENV_FILE" ]]; then
  echo "[ERROR] 환경 파일이 없습니다: $ENV_FILE"
  exit 1
fi

source "$ENV_FILE"

if [[ -z "${CLUSTER_NAME:-}" ]]; then
  echo "[ERROR] 환경 변수 CLUSTER_NAME 이 정의되지 않았습니다."
  exit 1
fi

echo "[INFO] 클러스터 이름 기반 모든 스택 삭제: $CLUSTER_NAME"

# Fetch related stacks sorted by creation time descending
STACKS=$(aws cloudformation describe-stacks \
  --query "Stacks[?contains(StackName, \`${CLUSTER_NAME}\`)].{Name: StackName, Time: CreationTime}" \
  --output json | jq -r '. | sort_by(.Time) | reverse | .[].Name')

if [[ -z "$STACKS" ]]; then
  echo "[INFO] 관련 스택 없음."
  exit 0
fi

declare -A STACK_PIDS

# Step 1: Delete or wait on each stack
for stack in $STACKS; do
  status=$(aws cloudformation describe-stacks --stack-name "$stack" \
           --query "Stacks[0].StackStatus" --output text)

  echo "[INFO] 스택 처리: $stack (상태: $status)"

  case "$status" in
    DELETE_COMPLETE)
      echo "✅ 이미 삭제됨: $stack"
      ;;

    DELETE_IN_PROGRESS)
      echo "🕒 삭제 진행 중 → 백그라운드 대기 시작: $stack"
      aws cloudformation wait stack-delete-complete --stack-name "$stack" &
      STACK_PIDS["$stack"]=$!
      ;;

    DELETE_FAILED)
      echo "❌ 삭제 실패 → 리소스 정리 후 재삭제 시도: $stack"
      handle_delete_failed_stack "$stack"
      ;;

    *)
      echo "🗑️  삭제 시도: $stack"
      aws cloudformation delete-stack --stack-name "$stack"
      echo "⌛ 삭제 완료 대기 중: $stack"
      aws cloudformation wait stack-delete-complete --stack-name "$stack" &
      STACK_PIDS["$stack"]=$!
      ;;
  esac
done

# Step 2: Wait on background deletions
echo "⌛ 병렬 삭제 대기 중인 스택들 기다리는 중..."
for stack in "${!STACK_PIDS[@]}"; do
  pid=${STACK_PIDS["$stack"]}
  echo "⏳ $stack 삭제 대기 (PID: $pid)"
  wait "$pid" && \
    echo "✅ $stack 삭제 완료" || \
    echo "❌ $stack 삭제 실패 (수동 확인 필요)"
done

# Step 3: Delete EKS cluster
echo "🗑️  EKS 클러스터 삭제: $CLUSTER_NAME"
aws eks delete-cluster --name "$CLUSTER_NAME"
aws eks wait cluster-deleted --name "$CLUSTER_NAME" && \
  echo "✅ 클러스터 삭제 완료: $CLUSTER_NAME" || \
  echo "❌ 클러스터 삭제 실패"

exit 0

############################################
# 함수 정의
############################################

handle_delete_failed_stack() {
  local stack_name=$1
  echo "🔍 [$stack_name] 삭제 실패 리소스 분석..."

  failed_resources=$(aws cloudformation describe-stack-events \
    --stack-name "$stack_name" \
    --query "StackEvents[?ResourceStatus=='DELETE_FAILED'].{LogicalId:LogicalResourceId, Type:ResourceType, StatusReason:ResourceStatusReason}" \
    --output json)

  echo "$failed_resources" | jq -r '.[] | "- \(.Type) (\(.LogicalId)): \(.StatusReason)"'

  for resource_id in $(echo "$failed_resources" | jq -r '.[].LogicalId'); do
    resource_type=$(echo "$failed_resources" | jq -r ".[] | select(.LogicalId==\"$resource_id\") | .Type")

    case "$resource_type" in
      "AWS::EC2::NetworkInterface")
        eni_id=$(aws cloudformation describe-stack-resource --stack-name "$stack_name" --logical-resource-id "$resource_id" \
          --query "StackResourceDetail.PhysicalResourceId" --output text)
        echo "🔌 ENI 삭제: $eni_id"
        aws ec2 delete-network-interface --network-interface-id "$eni_id" || true
        ;;
      "AWS::EC2::SecurityGroup")
        sg_id=$(aws cloudformation describe-stack-resource --stack-name "$stack_name" --logical-resource-id "$resource_id" \
          --query "StackResourceDetail.PhysicalResourceId" --output text)
        echo "🛡️  SG 삭제: $sg_id"
        aws ec2 delete-security-group --group-id "$sg_id" || true
        ;;
      "AWS::EC2::VPC")
        vpc_id=$(aws cloudformation describe-stack-resource --stack-name "$stack_name" --logical-resource-id "$resource_id" \
          --query "StackResourceDetail.PhysicalResourceId" --output text)
        echo "🌐 VPC 의존 리소스 정리 시도: $vpc_id"
        clean_vpc_dependencies "$vpc_id"
        ;;
      *)
        echo "⚠️  자동 삭제 미지원 리소스: $resource_type"
        ;;
    esac
  done

  echo "♻️  스택 재삭제 시도: $stack_name"
  aws cloudformation delete-stack --stack-name "$stack_name"
  aws cloudformation wait stack-delete-complete --stack-name "$stack_name" && \
    echo "✅ 재삭제 완료: $stack_name" || \
    echo "❌ 재삭제 실패: $stack_name"
}

clean_vpc_dependencies() {
  local vpc_id=$1
  echo "🧹 VPC 의존 리소스 제거: $vpc_id"

  for igw in $(aws ec2 describe-internet-gateways --filters "Name=attachment.vpc-id,Values=$vpc_id" \
                --query "InternetGateways[].InternetGatewayId" --output text); do
    echo "🔌 IGW 제거: $igw"
    aws ec2 detach-internet-gateway --internet-gateway-id "$igw" --vpc-id "$vpc_id" || true
    aws ec2 delete-internet-gateway --internet-gateway-id "$igw" || true
  done

  for subnet in $(aws ec2 describe-subnets --filters "Name=vpc-id,Values=$vpc_id" \
                   --query "Subnets[].SubnetId" --output text); do
    echo "🧯 Subnet 제거: $subnet"
    aws ec2 delete-subnet --subnet-id "$subnet" || true
  done

  for eni in $(aws ec2 describe-network-interfaces --filters "Name=vpc-id,Values=$vpc_id" \
                 --query "NetworkInterfaces[].NetworkInterfaceId" --output text); do
    echo "🛠️  ENI 제거: $eni"
    aws ec2 delete-network-interface --network-interface-id "$eni" || true
  done

  echo "✅ VPC 의존 리소스 정리 완료"
}
