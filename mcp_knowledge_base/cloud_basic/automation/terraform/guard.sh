#!/usr/bin/env bash
set -euo pipefail

if [ "${ROLE:-it-admin}" = "cost-manager" ]; then
  echo "[DENY] cost-manager role is not allowed to run Terraform provisioning." >&2
  exit 1
fi

echo "[OK] ROLE=${ROLE:-it-admin} permitted to proceed."


