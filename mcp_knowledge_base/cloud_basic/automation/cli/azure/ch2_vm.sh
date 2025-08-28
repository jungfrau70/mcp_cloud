#!/usr/bin/env bash
set -euo pipefail

if [ -f "$(dirname "$0")/../../env/azure.env" ]; then
  set -a; . "$(dirname "$0")/../../env/azure.env"; set +a
fi
RG_NAME="${RG_NAME:-rg-cloud-basic}"
LOCATION="${LOCATION:-koreacentral}"

if [ "${ROLE:-it-admin}" = "cost-manager" ]; then
  echo "[DENY] cost-manager role is not allowed to provision compute resources." >&2
  exit 1
fi
VM_NAME="web-01"

az group create -n "$RG_NAME" -l "$LOCATION" 1>/dev/null
az vm create -g "$RG_NAME" -n "$VM_NAME" \
  --image Ubuntu2204 --size Standard_B1s --generate-ssh-keys \
  --public-ip-sku Basic
az vm open-port -g "$RG_NAME" -n "$VM_NAME" --port 80

IP=$(az vm list-ip-addresses -g "$RG_NAME" -n "$VM_NAME" --query "[0].virtualMachine.network.publicIpAddresses[0].ipAddress" -o tsv)
echo "Azure VM running: $VM_NAME PublicIP: $IP"

