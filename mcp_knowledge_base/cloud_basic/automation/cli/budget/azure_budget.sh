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

