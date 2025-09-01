#!/usr/bin/env bash
set -euo pipefail

if [ -f "$(dirname "$0")/../../env/azure.env" ]; then
  set -a; . "$(dirname "$0")/../../env/azure.env"; set +a
fi

az account set --subscription "$SUB_ID"
az costmanagement query -t ActualCost \
  --dataset-aggregation cost=sum \
  --timeframe MonthToDate \
  --scope "/subscriptions/${SUB_ID}" | jq '.'

