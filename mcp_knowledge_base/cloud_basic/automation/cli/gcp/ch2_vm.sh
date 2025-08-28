#!/usr/bin/env bash
set -euo pipefail

if [ -f "$(dirname "$0")/../../env/gcp.env" ]; then
  set -a; . "$(dirname "$0")/../../env/gcp.env"; set +a
fi
PROJECT_ID="${PROJECT_ID:-<PROJECT_ID>}"
ZONE="${ZONE:-asia-northeast3-a}"

if [ "${ROLE:-it-admin}" = "cost-manager" ]; then
  echo "[DENY] cost-manager role is not allowed to provision compute resources." >&2
  exit 1
fi
NAME="web-01"

gcloud config set project "$PROJECT_ID"
gcloud compute instances create "$NAME" --zone="$ZONE" \
  --machine-type=e2-micro --image-family=ubuntu-2204-lts --image-project=ubuntu-os-cloud \
  --tags=http-server
gcloud compute firewall-rules create allow-http --allow=tcp:80 --target-tags=http-server --quiet || true

IP=$(gcloud compute instances describe "$NAME" --zone="$ZONE" --format='get(networkInterfaces[0].accessConfigs[0].natIP)')
echo "GCP VM running: $NAME PublicIP: $IP"

