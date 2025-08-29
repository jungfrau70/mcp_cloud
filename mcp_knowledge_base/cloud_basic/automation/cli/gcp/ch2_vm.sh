#!/usr/bin/env bash
set -euo pipefail

# Environment setup
if [ -f "$(dirname "$0")/../../env/gcp.env" ]; then
  set -a; . "$(dirname "$0")/../../env/gcp.env"; set +a
fi
PROJECT_ID="${PROJECT_ID:-<PROJECT_ID>}"
REGION="${REGION:-asia-northeast3}"
ZONE="${ZONE:-asia-northeast3-a}"

# Role check
if [ "${ROLE:-it-admin}" = "cost-manager" ]; then
  echo "[DENY] cost-manager role is not allowed to provision compute resources." >&2
  exit 1
fi

# Configuration
TEMPLATE_NAME="lab-instance-template"
MIG_NAME="lab-mig"
HEALTH_CHECK_NAME="http-basic-check"
BACKEND_SERVICE_NAME="lab-backend-service"
URL_MAP_NAME="lab-url-map"
PROXY_NAME="lab-http-proxy"
FWD_RULE_NAME="lab-forwarding-rule"

gcloud config set project "$PROJECT_ID"

# 1. Create Instance Template
echo "Creating instance template..."
gcloud compute instance-templates create "$TEMPLATE_NAME" \
  --machine-type=e2-micro \
  --image-family=ubuntu-2204-lts \
  --image-project=ubuntu-os-cloud \
  --tags=http-server \
  --metadata=startup-script='#! /bin/bash
    apt-get update
    apt-get install -y nginx
    echo "<h1>Hello from $(hostname)</h1>" > /var/www/html/index.html'

# 2. Create Managed Instance Group (MIG)
echo "Creating managed instance group..."
gcloud compute instance-groups managed create "$MIG_NAME" \
  --base-instance-name lab-vm \
  --size=2 \
  --template="$TEMPLATE_NAME" \
  --zone="$ZONE"

# 3. Create Firewall rule for health checks and web traffic
gcloud compute firewall-rules create allow-health-check-and-web --allow tcp:80 \
  --source-ranges 130.211.0.0/22,35.191.0.0/16,0.0.0.0/0 --target-tags http-server --quiet || true

# 4. Create Health Check
echo "Creating health check..."
gcloud compute health-checks create http "$HEALTH_CHECK_NAME" --port 80

# 5. Create Backend Service and add MIG
echo "Creating backend service..."
gcloud compute backend-services create "$BACKEND_SERVICE_NAME" \
  --protocol=HTTP \
  --health-checks="$HEALTH_CHECK_NAME" \
  --global
gcloud compute backend-services add-backend "$BACKEND_SERVICE_NAME" \
  --instance-group="$MIG_NAME" \
  --instance-group-zone="$ZONE" \
  --global

# 6. Create URL Map and HTTP Proxy
echo "Creating URL map and proxy..."
gcloud compute url-maps create "$URL_MAP_NAME" --default-service "$BACKEND_SERVICE_NAME"
gcloud compute target-http-proxies create "$PROXY_NAME" --url-map="$URL_MAP_NAME"

# 7. Create Global Forwarding Rule (Load Balancer IP)
echo "Creating forwarding rule..."
gcloud compute forwarding-rules create "$FWD_RULE_NAME" \
  --address-name lab-lb-ip --global \
  --target-http-proxy="$PROXY_NAME" \
  --ports=80

LB_IP=$(gcloud compute addresses describe lab-lb-ip --global --format='get(address)')

echo "GCP Load Balancer and MIG are running."
echo "Load Balancer IP: http://$LB_IP"

