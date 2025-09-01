#!/usr/bin/env bash
set -euo pipefail

if [ -f "$(dirname "$0")/../../env/gcp.env" ]; then
  set -a; . "$(dirname "$0")/../../env/gcp.env"; set +a
fi
PROJECT_ID="${PROJECT_ID:-<PROJECT_ID>}"
USER_EMAIL="${USER_EMAIL:-<EMAIL>}"

gcloud config set project "$PROJECT_ID"

if [ "${ROLE:-it-admin}" = "cost-manager" ]; then
  echo "[DENY] cost-manager role is not allowed to manage IAM bindings." >&2
  exit 1
fi

gcloud projects add-iam-policy-binding "$PROJECT_ID" \
  --member="user:${USER_EMAIL}" --role="roles/viewer" --quiet

echo "GCP IAM: ${USER_EMAIL} -> roles/viewer bound on ${PROJECT_ID}"

