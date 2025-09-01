#!/usr/bin/env bash
set -euo pipefail

if [ -f "$(dirname "$0")/../../env/azure.env" ]; then
  set -a; . "$(dirname "$0")/../../env/azure.env"; set +a
fi
RG="${RG_NAME:-rg-cloud-basic}"
LOC="${LOCATION:-koreacentral}"

if [ "${ROLE:-it-admin}" = "cost-manager" ]; then
  echo "[DENY] cost-manager role is not allowed to change storage configuration." >&2
  exit 1
fi
ACCT="stor$(date +%s)"
SITE_DIR="./site"

az group create -n "$RG" -l "$LOC" 1>/dev/null
az storage account create -n "$ACCT" -g "$RG" -l "$LOC" --sku Standard_LRS
az storage blob service-properties update --account-name "$ACCT" --static-website \
  --index-document index.html --404-document 404.html
az storage blob upload-batch -s "$SITE_DIR" -d '$web' --account-name "$ACCT"

echo "Azure Static website: https://${ACCT}.z13.web.core.windows.net"

