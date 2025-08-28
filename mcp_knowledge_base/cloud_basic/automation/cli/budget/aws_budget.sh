#!/usr/bin/env bash
set -euo pipefail

# Configurable via env vars
NAME="${NAME:-Monthly-Lab-Budget}"
LIMIT_AMOUNT="${LIMIT_AMOUNT:-10}"
# Comma-separated percent thresholds, e.g. "80,100"
THRESHOLDS="${THRESHOLDS:-80}"
# Comma-separated emails, e.g. "user1@example.com,user2@example.com"
SUBSCRIBERS="${SUBSCRIBERS:-}"

ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

# Build Subscribers JSON array
build_subscribers_json() {
  local emails="$1"
  local json="[]"
  IFS=',' read -r -a arr <<< "$emails"
  for email in "${arr[@]}"; do
    [ -z "$email" ] && continue
    if [ "$json" = "[]" ]; then
      json='[{"SubscriptionType":"EMAIL","Address":"'"$email"'"}]'
    else
      json=${json%]}', {"SubscriptionType":"EMAIL","Address":"'"$email"'"}]'
    fi
  done
  echo "$json"
}

SUBSCRIBERS_JSON=$(build_subscribers_json "$SUBSCRIBERS")

# Build NotificationsWithSubscribers
build_notifications_json() {
  local thresholds="$1"
  local subs_json="$2"
  local out="[]"
  IFS=',' read -r -a tarr <<< "$thresholds"
  for t in "${tarr[@]}"; do
    [ -z "$t" ] && continue
    local n='{'
    n+="\"Notification\":{\"NotificationType\":\"ACTUAL\",\"ComparisonOperator\":\"GREATER_THAN\",\"Threshold\":$t}"
    if [ -n "$SUBSCRIBERS" ]; then
      n+=",\"Subscribers\":$subs_json}"
    else
      n+="}"
    fi
    if [ "$out" = "[]" ]; then
      out="[$n]"
    else
      out=${out%]}',$n]'
    fi
  done
  echo "$out"
}

NOTIFS_JSON=$(build_notifications_json "$THRESHOLDS" "$SUBSCRIBERS_JSON")

cat > /tmp/budget.json <<EOF
{
  "Budget": {
    "BudgetName": "${NAME}",
    "BudgetLimit": {"Amount": "${LIMIT_AMOUNT}", "Unit": "USD"},
    "TimeUnit": "MONTHLY",
    "BudgetType": "COST"
  },
  "NotificationsWithSubscribers": ${NOTIFS_JSON}
}
EOF

aws budgets create-budget --account-id "$ACCOUNT_ID" --budget file:///tmp/budget.json
echo "AWS Budget created: ${NAME} USD ${LIMIT_AMOUNT} thresholds=${THRESHOLDS} subscribers=${SUBSCRIBERS}"

