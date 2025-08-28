#!/usr/bin/env bash
set -euo pipefail

PROJECT_ID="${PROJECT_ID:-<PROJECT_ID>}"
DISPLAY_NAME="Monthly Lab Budget"
AMOUNT="10"

gcloud beta billing budgets create \
  --billing-account="${BILLING_ACCOUNT:-<BILLING_ACCOUNT_ID>}" \
  --display-name="$DISPLAY_NAME" \
  --budget-amount="$AMOUNT" \
  --threshold-rule-percent=0.8 \
  --filter-projects="projects/${PROJECT_ID}"

echo "GCP Budget created: ${DISPLAY_NAME} ${AMOUNT}"

