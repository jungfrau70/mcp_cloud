#!/usr/bin/env bash
set -euo pipefail

NAME="Monthly-Lab-Budget"
LIMIT_AMOUNT="10"
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

cat > /tmp/budget.json <<EOF
{
  "Budget": {
    "BudgetName": "${NAME}",
    "BudgetLimit": {"Amount": "${LIMIT_AMOUNT}", "Unit": "USD"},
    "TimeUnit": "MONTHLY",
    "BudgetType": "COST"
  },
  "NotificationsWithSubscribers": []
}
EOF

aws budgets create-budget --account-id "$ACCOUNT_ID" --budget file:///tmp/budget.json
echo "AWS Budget created: ${NAME} USD ${LIMIT_AMOUNT}"

