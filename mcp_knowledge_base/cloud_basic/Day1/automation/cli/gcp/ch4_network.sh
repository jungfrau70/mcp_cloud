#!/usr/bin/env bash
set -euo pipefail

if [ -f "$(dirname "$0")/../../env/gcp.env" ]; then
  set -a; . "$(dirname "$0")/../../env/gcp.env"; set +a
fi
PROJECT_ID="${PROJECT_ID:-<PROJECT_ID>}"
REGION="${REGION:-asia-northeast3}"

if [ "${ROLE:-it-admin}" = "cost-manager" ]; then
  echo "[DENY] cost-manager role is not allowed to modify network resources." >&2
  exit 1
fi

gcloud config set project "$PROJECT_ID"
gcloud compute networks create vpc-basic --subnet-mode=custom || true
gcloud compute networks subnets create public-subnet --network=vpc-basic --region="$REGION" --range=10.2.1.0/24 || true
gcloud compute firewall-rules create allow-ssh --allow=tcp:22 --network=vpc-basic --quiet || true

echo "GCP VPC: vpc-basic with subnet public-subnet created"

