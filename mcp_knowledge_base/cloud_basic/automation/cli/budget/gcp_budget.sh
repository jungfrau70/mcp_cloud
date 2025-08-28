#!/usr/bin/env bash
set -euo pipefail

PROJECT_ID="${PROJECT_ID:-<PROJECT_ID>}"
BILLING_ACCOUNT="${BILLING_ACCOUNT:-<BILLING_ACCOUNT_ID>}"
DISPLAY_NAME="${DISPLAY_NAME:-Monthly Lab Budget}"
BUDGET_AMOUNT="${BUDGET_AMOUNT:-10}"
# Threshold percent as 0.xx or 80 (we normalize to 0.xx)
THRESHOLD_PERCENT="${THRESHOLD_PERCENT:-0.8}"

norm_threshold() {
  local v="$1"
  if [[ "$v" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
    if (( $(echo "$v > 1" | bc -l) )); then
      # assume 0-100 scale
      echo "$(echo "$v/100" | bc -l)"
    else
      echo "$v"
    fi
  else
    echo "0.8"
  fi
}

TP=$(norm_threshold "$THRESHOLD_PERCENT")

gcloud beta billing budgets create \
  --billing-account="$BILLING_ACCOUNT" \
  --display-name="$DISPLAY_NAME" \
  --budget-amount="$BUDGET_AMOUNT" \
  --threshold-rule-percent="$TP" \
  --filter-projects="projects/${PROJECT_ID}"

echo "GCP Budget created: ${DISPLAY_NAME} amount=${BUDGET_AMOUNT} threshold=${TP}"

