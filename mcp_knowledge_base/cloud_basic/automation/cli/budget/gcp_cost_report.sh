#!/usr/bin/env bash
set -euo pipefail

if [ -f "$(dirname "$0")/../../env/gcp.env" ]; then
  set -a; . "$(dirname "$0")/../../env/gcp.env"; set +a
fi

gcloud beta billing accounts budgets list --billing-account "$BILLING_ACCOUNT" || true
echo "For detailed cost, export billing to BigQuery and query (out-of-scope for quick script)."

