#!/usr/bin/env bash
set -euo pipefail

# Requires: az CLI logged in and correct subscription context
# Configurable via env vars
SUB_ID="${SUB_ID:-<SUBSCRIPTION_ID>}"
NAME="${NAME:-Monthly-Lab-Budget}"
AMOUNT="${BUDGET_AMOUNT:-10}"
THRESHOLD_PERCENT="${THRESHOLD_PERCENT:-80}"
# Comma-separated emails; Azure uses contact-emails on budget notifications
CONTACT_EMAILS="${CONTACT_EMAILS:-}"
# Dates YYYY-MM-DD; provide explicitly for portability
START_DATE="${START_DATE:-2025-01-01}"
END_DATE="${END_DATE:-2025-12-31}"

if [ "${ROLE:-it-admin}" = "cost-manager" ]; then
  echo "[DENY] cost-manager role is not allowed to manage budgets." >&2
  exit 1
fi

az account set --subscription "$SUB_ID"

# Create/Update subscription-scope budget
az consumption budget create \
  --subscription "$SUB_ID" \
  --amount "$AMOUNT" \
  --category cost \
  --name "$NAME" \
  --time-grain monthly \
  --start-date "$START_DATE" \
  --end-date "$END_DATE" \
  --notification-key Actual_GreaterThan_${THRESHOLD_PERCENT} \
  --threshold "$THRESHOLD_PERCENT" \
  --operator GreaterThan \
  ${CONTACT_EMAILS:+--contact-emails "$CONTACT_EMAILS"}

echo "Azure Budget created: ${NAME} amount=${AMOUNT} threshold=${THRESHOLD_PERCENT}%"

#!/usr/bin/env bash
set -euo pipefail

SUB_ID="${SUB_ID:-<SUBSCRIPTION_ID>}"
NAME="Monthly-Lab-Budget"
AMOUNT="10"

az account set --subscription "$SUB_ID"
az consumption budget create -g "rg-cloud-basic" -n "$NAME" \
  --amount "$AMOUNT" --time-grain monthly --category cost \
  --start-date "$(date +%Y-%m-01)" --end-date "$(date -d "+1 year" +%Y-%m-%d)" \
  --notifications "Actual_GreaterThan_80_Percent={'enabled':true,'operator':'GreaterThan','threshold':80,'contactEmails':['you@example.com']}"

echo "Azure Budget created: ${NAME} ${AMOUNT}"

