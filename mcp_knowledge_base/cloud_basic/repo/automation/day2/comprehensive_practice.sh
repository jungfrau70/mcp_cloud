#!/bin/bash
# 종합 실습 스크립트

set -e

echo "종합 실습 시작..."

# 웹 애플리케이션 배포
echo "웹 애플리케이션 배포 중..."

# 간단한 웹 서버 배포
cat > index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Basic Course Web App</title>
</head>
<body>
    <h1>Welcome to Cloud Basic Course!</h1>
    <p>This is a simple web application deployed on cloud.</p>
</body>
</html>
EOF

# AWS에 웹 서버 배포
aws s3 cp index.html s3://$BUCKET_NAME/index.html
aws s3 website s3://$BUCKET_NAME --index-document index.html

# GCP에 웹 서버 배포
gsutil cp index.html gs://$GCP_BUCKET_NAME/index.html
gsutil web set -m index.html gs://$GCP_BUCKET_NAME

echo "종합 실습 완료!"
