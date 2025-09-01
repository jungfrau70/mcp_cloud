#!/usr/bin/env bash
set -euo pipefail

if [ -f "$(dirname "$0")/../../env/azure.env" ]; then
  set -a; . "$(dirname "$0")/../../env/azure.env"; set +a
fi
SUB_ID="${SUB_ID:-<SUBSCRIPTION_ID>}"
RG_NAME="${RG_NAME:-rg-cloud-basic}"
LOCATION="${LOCATION:-koreacentral}"
GROUP_NAME="DevTeam"
ASSIGNEE_OBJECT_ID="<USER_OR_GROUP_OBJECT_ID>"

az account set --subscription "$SUB_ID"
az group create -n "$RG_NAME" -l "$LOCATION" 1>/dev/null

if [ "${ROLE:-it-admin}" = "cost-manager" ]; then
  echo "[DENY] cost-manager role is not allowed to manage IAM assignments." >&2
  exit 1
fi

az ad group create --display-name "$GROUP_NAME" --mail-nickname devteam || true
az role assignment create \
  --assignee-object-id "$ASSIGNEE_OBJECT_ID" \
  --role "Reader" \
  --scope "/subscriptions/${SUB_ID}/resourceGroups/${RG_NAME}" || true

echo "Azure IAM: group=$GROUP_NAME, Reader assigned on RG=$RG_NAME"

