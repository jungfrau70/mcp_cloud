#!/usr/bin/env bash
set -euo pipefail

# Variables
if [ -f "$(dirname "$0")/../../env/aws.env" ]; then
  set -a; . "$(dirname "$0")/../../env/aws.env"; set +a
fi
AWS_REGION="${AWS_REGION:-ap-northeast-2}"
AWS_PROFILE="${AWS_PROFILE:-default}"
USER_NAME="dev-user"
GROUP_NAME="DevTeam"
POLICY_ARN="arn:aws:iam::aws:policy/ReadOnlyAccess"

export AWS_REGION AWS_PROFILE

if [ "${ROLE:-it-admin}" = "cost-manager" ]; then
  echo "[DENY] cost-manager role is not allowed to manage IAM resources." >&2
  exit 1
fi

aws iam create-group --group-name "$GROUP_NAME" || true
aws iam create-user --user-name "$USER_NAME" || true
aws iam add-user-to-group --user-name "$USER_NAME" --group-name "$GROUP_NAME" || true
aws iam attach-group-policy --group-name "$GROUP_NAME" --policy-arn "$POLICY_ARN" || true

echo "AWS IAM: user=$USER_NAME, group=$GROUP_NAME, policy=$POLICY_ARN configured"

