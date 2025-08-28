#!/usr/bin/env bash
set -euo pipefail

if [ -f "$(dirname "$0")/../../env/aws.env" ]; then
  set -a; . "$(dirname "$0")/../../env/aws.env"; set +a
fi

START=$(date -d "-7 days" +%Y-%m-%d)
END=$(date +%Y-%m-%d)

aws ce get-cost-and-usage \
  --time-period Start=${START},End=${END} \
  --granularity DAILY \
  --metrics UnblendedCost \
  --group-by Type=DIMENSION,Key=SERVICE | jq '.'

