#!/usr/bin/env bash
set -euo pipefail

# Environment setup
if [ -f "$(dirname "$0")/../../env/azure.env" ]; then
  set -a; . "$(dirname "$0")/../../env/azure.env"; set +a
fi
RG_NAME="${RG_NAME:-rg-cloud-basic-ha}"
LOCATION="${LOCATION:-koreacentral}"
VMSS_NAME="lab-vmss"

# Role check
if [ "${ROLE:-it-admin}" = "cost-manager" ]; then
  echo "[DENY] cost-manager role is not allowed to provision compute resources." >&2
  exit 1
fi

# Create Resource Group
az group create -n "$RG_NAME" -l "$LOCATION" > /dev/null

# Create Virtual Machine Scale Set with a Load Balancer
echo "Creating VMSS and Load Balancer..."
az vmss create \
  --resource-group "$RG_NAME" \
  --name "$VMSS_NAME" \
  --image Ubuntu2204 \
  --vm-sku Standard_B1s \
  --instance-count 2 \
  --admin-username azureuser \
  --generate-ssh-keys \
  --lb-sku Standard \
  --public-ip-per-vm false

# Add a health probe to the load balancer
LB_NAME="${VMSS_NAME}LB"
LB_BACKEND_POOL_NAME="${VMSS_NAME}BEPool"
LB_PROBE_NAME="http-probe"

az network lb probe create \
  --resource-group "$RG_NAME" \
  --lb-name "$LB_NAME" \
  --name "$LB_PROBE_NAME" \
  --protocol Http \
  --port 80 \
  --path "/"

# Update the load balancing rule to use the health probe
LB_RULE_NAME="${VMSS_NAME}LBRule"
az network lb rule update \
  --resource-group "$RG_NAME" \
  --lb-name "$LB_NAME" \
  --name "$LB_RULE_NAME" \
  --probe-name "$LB_PROBE_NAME"

# Get Public IP of the Load Balancer
LB_PUBLIC_IP=$(az network public-ip show \
  --resource-group "$RG_NAME" \
  --name "${LB_NAME}-ip" \
  --query "ipAddress" -o tsv)

echo "Azure VMSS and Load Balancer are running."
echo "Load Balancer Public IP: http://$LB_PUBLIC_IP"

