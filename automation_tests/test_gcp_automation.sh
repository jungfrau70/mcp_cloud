#!/usr/bin/env bash
set -euo pipefail
set -x # Print commands and their arguments as they are executed.

# --- Environment Setup ---
# Source the GCP environment file
if [ -f "$(dirname "$0")/../env/gcp.env" ]; then
  set -a; . "$(dirname "$0")/../env/gcp.env"; set +a
fi

# --- Configuration ---
PROJECT_ID="${PROJECT_ID:-<YOUR_GCP_PROJECT_ID>}" # IMPORTANT: Replace with your GCP Project ID
REGION="${REGION:-asia-northeast3}"
ZONE="${ZONE:-asia-northeast3-a}"
UNIQUE_SUFFIX=$(head /dev/urandom | tr -dc a-z0-9 | head -c 8)

# Resource Names (using unique suffix to avoid conflicts)
STORAGE_BUCKET_NAME="test-gcp-bucket-${UNIQUE_SUFFIX}"
VPC_NAME="vpc-basic"
MIG_NAME="lab-mig"

# --- Functions ---
cleanup() {
    echo "--- Cleaning up GCP resources ---"
    # Delete MIG
    gcloud compute instance-groups managed delete "${MIG_NAME}" --zone="${ZONE}" --quiet || true
    # Delete Instance Template
    gcloud compute instance-templates delete "lab-instance-template" --quiet || true
    # Delete Load Balancer components
    gcloud compute forwarding-rules delete "lab-forwarding-rule" --global --quiet || true
    gcloud compute target-http-proxies delete "lab-http-proxy" --quiet || true
    gcloud compute url-maps delete "lab-url-map" --quiet || true
    gcloud compute backend-services delete "lab-backend-service" --global --quiet || true
    gcloud compute health-checks delete "http-basic-check" --quiet || true
    gcloud compute addresses delete "lab-lb-ip" --global --quiet || true
    # Delete Firewall rules
    gcloud compute firewall-rules delete "allow-health-check-and-web" --quiet || true
    gcloud compute firewall-rules delete "allow-http" --quiet || true # From ch2_vm.sh
    # Delete Cloud NAT and Router
    gcloud compute routers nats delete "lab-nat" --router="lab-router" --region="${REGION}" --quiet || true
    gcloud compute routers delete "lab-router" --region="${REGION}" --quiet || true
    # Delete Subnets
    gcloud compute networks subnets delete "public-subnet" --region="${REGION}" --quiet || true
    gcloud compute networks subnets delete "private-subnet" --region="${REGION}" --quiet || true
    # Delete VPC
    gcloud compute networks delete "${VPC_NAME}" --quiet || true
    # Delete Storage Bucket
    gsutil rm -r "gs://${STORAGE_BUCKET_NAME}" || true
    # Note: IAM user/role cleanup is complex and often manual for simple tests.
    # For this test, we assume the IAM changes are project-level and will be cleaned up with project deletion if needed.
    echo "--- GCP cleanup complete ---"
}

# Register cleanup function to run on exit
trap cleanup EXIT

# --- Execution ---
echo "--- Running GCP Automation Scripts ---"

gcloud config set project "$PROJECT_ID"

# Ch1 IAM
echo "Running ch1_iam.sh..."
# Note: ch1_iam.sh creates fixed names, so we check for them in verification.
../mcp_knowledge_base/cloud_basic/automation/cli/gcp/ch1_iam.sh

# Ch3 Storage
echo "Running ch3_storage.sh..."
# The ch3_storage.sh script creates a bucket with a random suffix.
# We need to capture the name it creates for cleanup.
STORAGE_BUCKET_NAME_CREATED=$(../mcp_knowledge_base/cloud_basic/automation/cli/gcp/ch3_storage.sh | grep "Bucket created" | awk '{print $NF}')
if [ -z "$STORAGE_BUCKET_NAME_CREATED" ]; then
    echo "Error: Could not determine GCP Storage bucket name from ch3_storage.sh output."
    exit 1
fi
STORAGE_BUCKET_NAME="$STORAGE_BUCKET_NAME_CREATED" # Update for cleanup

# Ch4 Network
echo "Running ch4_network.sh..."
../mcp_knowledge_base/cloud_basic/automation/cli/gcp/ch4_network.sh

# Ch2 VM (HA Stack: MIG, LB)
echo "Running ch2_vm.sh..."
../mcp_knowledge_base/cloud_basic/automation/cli/gcp/ch2_vm.sh

echo "--- Verification ---"

# Verify IAM (ch1_iam.sh creates fixed names)
gcloud projects get-iam-policy "$PROJECT_ID" --format=json | grep -q "roles/viewer"
echo "IAM Viewer role exists for test user."

# Verify Storage Bucket
gsutil ls "gs://${STORAGE_BUCKET_NAME}" > /dev/null
echo "GCP Storage Bucket '${STORAGE_BUCKET_NAME}' exists."

# Verify Network (ch4_network.sh creates fixed names)
gcloud compute networks describe "${VPC_NAME}" > /dev/null
echo "VPC '${VPC_NAME}' exists."
gcloud compute networks subnets describe "public-subnet" --region="${REGION}" > /dev/null
echo "Public Subnet exists."
gcloud compute networks subnets describe "private-subnet" --region="${REGION}" > /dev/null
echo "Private Subnet exists."
gcloud compute routers describe "lab-router" --region="${REGION}" > /dev/null
echo "Cloud Router exists."
gcloud compute routers nats describe "lab-nat" --router="lab-router" --region="${REGION}" > /dev/null
echo "Cloud NAT exists."

# Verify MIG and Load Balancer (ch2_vm.sh creates fixed names)
gcloud compute instance-groups managed describe "${MIG_NAME}" --zone="${ZONE}" > /dev/null
echo "MIG '${MIG_NAME}' exists."
gcloud compute forwarding-rules describe "lab-forwarding-rule" --global > /dev/null
echo "Load Balancer Forwarding Rule exists."

echo "--- All GCP resources verified successfully! ---"
