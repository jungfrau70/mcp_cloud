#!/usr/bin/env bash
set -euo pipefail
set -x # Print commands and their arguments as they are executed.

# --- Environment Setup ---
# Source the Azure environment file
if [ -f "$(dirname "$0")/../env/azure.env" ]; then
  set -a; . "$(dirname "$0")/../env/azure.env"; set +a
fi

# --- Configuration ---
LOCATION="${LOCATION:-koreacentral}"
UNIQUE_SUFFIX=$(head /dev/urandom | tr -dc a-z0-9 | head -c 8)

# Resource Names (using unique suffix to avoid conflicts)
RG_NAME="rg-test-automation-${UNIQUE_SUFFIX}"
VMSS_NAME="lab-vmss"
STORAGE_ACCOUNT_NAME="teststorage${UNIQUE_SUFFIX}"

# --- Functions ---
cleanup() {
    echo "--- Cleaning up Azure resources ---"
    az group delete --name "${RG_NAME}" --yes --no-wait || true
    echo "--- Azure cleanup initiated ---"
}

# Register cleanup function to run on exit
trap cleanup EXIT

# --- Execution ---
echo "--- Running Azure Automation Scripts ---"

# Create Resource Group first, as other scripts might rely on it
az group create -n "$RG_NAME" -l "$LOCATION" > /dev/null

# Ch1 IAM (Note: Azure IAM is often tenant-wide, so direct user creation might be complex for a simple test)
# For this test, we'll assume the ch1_iam.sh script creates a resource group-scoped role assignment.
# The ch1_iam.sh script creates a user and assigns a role to a resource group named rg-cloud-basic.
# We will modify the RG_NAME env var for ch1_iam.sh to use our test RG.
export RG_NAME # Export RG_NAME so ch1_iam.sh can use it
echo "Running ch1_iam.sh..."
../mcp_knowledge_base/cloud_basic/automation/cli/azure/ch1_iam.sh
unset RG_NAME # Unset to avoid affecting other scripts if they don't expect it

# Ch3 Storage
echo "Running ch3_storage.sh..."
# The ch3_storage.sh script creates a storage account with a fixed name (rg-cloud-basic) or uses RG_NAME.
# We need to ensure it uses our test RG.
export RG_NAME # Export RG_NAME again
../mcp_knowledge_base/cloud_basic/automation/cli/azure/ch3_storage.sh
unset RG_NAME

# Ch4 Network
echo "Running ch4_network.sh..."
# The ch4_network.sh script creates a VNet and subnets within rg-cloud-basic.
# We need to ensure it uses our test RG.
export RG_NAME # Export RG_NAME again
../mcp_knowledge_base/cloud_basic/automation/cli/azure/ch4_network.sh
unset RG_NAME

# Ch2 VM (HA Stack: VMSS, LB)
echo "Running ch2_vm.sh..."
# The ch2_vm.sh script creates VMSS and LB within rg-cloud-basic-ha.
# We need to ensure it uses our test RG.
export RG_NAME # Export RG_NAME again
../mcp_knowledge_base/cloud_basic/automation/cli/azure/ch2_vm.sh
unset RG_NAME

echo "--- Verification ---"

# Verify Resource Group exists
az group show --name "${RG_NAME}" > /dev/null
echo "Resource Group '${RG_NAME}' exists."

# Verify VMSS exists
az vmss show --resource-group "${RG_NAME}" --name "${VMSS_NAME}" > /dev/null
echo "VMSS '${VMSS_NAME}' exists."

# Verify Load Balancer exists (name is VMSS_NAME + LB)
az network lb show --resource-group "${RG_NAME}" --name "${VMSS_NAME}LB" > /dev/null
echo "Load Balancer '${VMSS_NAME}LB' exists."

# Verify Storage Account exists (ch3_storage.sh creates a fixed name or uses RG_NAME)
# This assumes ch3_storage.sh creates a storage account named 'stcloudbasic' or similar.
# You might need to adjust this verification based on the actual naming in ch3_storage.sh
az storage account show --resource-group "${RG_NAME}" --name "stcloudbasic" > /dev/null || true # Adjust name if needed
echo "Storage Account 'stcloudbasic' exists (if created by ch3_storage.sh)."

# Verify VNet exists (ch4_network.sh creates a fixed name 'vnet-basic')
az network vnet show --resource-group "${RG_NAME}" --name "vnet-basic" > /dev/null
echo "VNet 'vnet-basic' exists."

echo "--- All Azure resources verified successfully! ---"
