#!/usr/bin/env bash
set -euo pipefail

if [ -f "$(dirname "$0")/../../env/azure.env" ]; then
  set -a; . "$(dirname "$0")/../../env/azure.env"; set +a
fi
RG="${RG_NAME:-rg-cloud-basic}"
LOC="${LOCATION:-koreacentral}"

if [ "${ROLE:-it-admin}" = "cost-manager" ]; then
  echo "[DENY] cost-manager role is not allowed to modify network resources." >&2
  exit 1
fi
VNET="vnet-basic"
PUB="public-subnet"
PRV="private-subnet"

az group create -n "$RG" -l "$LOC" 1>/dev/null
az network vnet create -g "$RG" -n "$VNET" --address-prefix 10.1.0.0/16 \
  --subnet-name "$PUB" --subnet-prefix 10.1.1.0/24
az network vnet subnet create -g "$RG" --vnet-name "$VNET" -n "$PRV" --address-prefixes 10.1.2.0/24

echo "Azure VNet: $VNET  Subnets: $PUB, $PRV"

