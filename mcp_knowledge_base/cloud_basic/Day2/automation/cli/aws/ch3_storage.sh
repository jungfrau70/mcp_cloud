#!/usr/bin/env bash
set -euo pipefail

if [ -f "$(dirname "$0")/../../env/aws.env" ]; then
  set -a; . "$(dirname "$0")/../../env/aws.env"; set +a
fi
AWS_REGION="${AWS_REGION:-ap-northeast-2}"
AWS_PROFILE="${AWS_PROFILE:-default}"
BUCKET="lab-static-$(date +%s)"
SITE_DIR="./site"

export AWS_REGION AWS_PROFILE

if [ "${ROLE:-it-admin}" = "cost-manager" ]; then
  echo "[DENY] cost-manager role is not allowed to change storage configuration." >&2
  exit 1
fi

aws s3 mb "s3://${BUCKET}"

# Enable static website hosting via website configuration (S3 website endpoint)
aws s3 website "s3://${BUCKET}" --index-document index.html --error-document 404.html

# Public read policy (for demo)
cat > /tmp/bucket-policy.json <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "PublicReadGetObject",
      "Effect": "Allow",
      "Principal": "*",
      "Action": ["s3:GetObject"],
      "Resource": "arn:aws:s3:::${BUCKET}/*"
    }
  ]
}
EOF

aws s3api put-bucket-policy --bucket "$BUCKET" --policy file:///tmp/bucket-policy.json

aws s3 sync "$SITE_DIR" "s3://${BUCKET}"
echo "S3 website: http://${BUCKET}.s3-website-${AWS_REGION}.amazonaws.com"

