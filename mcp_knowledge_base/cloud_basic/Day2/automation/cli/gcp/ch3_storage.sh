#!/usr/bin/env bash
set -euo pipefail

if [ -f "$(dirname "$0")/../../env/gcp.env" ]; then
  set -a; . "$(dirname "$0")/../../env/gcp.env"; set +a
fi
PROJECT_ID="${PROJECT_ID:-<PROJECT_ID>}"
LOCATION="${REGION:-ASIA-NORTHEAST3}"

if [ "${ROLE:-it-admin}" = "cost-manager" ]; then
  echo "[DENY] cost-manager role is not allowed to change storage configuration." >&2
  exit 1
fi
BUCKET="lab-static-$(date +%s)"
SITE_DIR="./site"

gcloud config set project "$PROJECT_ID"
gsutil mb -l "$LOCATION" "gs://${BUCKET}"
gsutil cp -r "$SITE_DIR"/* "gs://${BUCKET}"
gsutil web set -m index.html -e 404.html "gs://${BUCKET}"
gsutil iam ch allUsers:objectViewer "gs://${BUCKET}"

echo "GCS website (via storage hosting): https://storage.googleapis.com/${BUCKET}/index.html"

