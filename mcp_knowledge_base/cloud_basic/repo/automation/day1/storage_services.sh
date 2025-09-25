#!/bin/bash
# 스토리지 서비스 기초 실습 스크립트

set -e

echo "스토리지 서비스 기초 실습 시작..."

# AWS S3 버킷 생성
echo "AWS S3 버킷 생성 중..."
BUCKET_NAME="basic-course-bucket-$(date +%s)"
REGION="us-west-2"

# S3 버킷 생성
aws s3 mb s3://$BUCKET_NAME --region $REGION

# 버킷 정책 설정
cat > bucket-policy.json << EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "PublicReadGetObject",
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::$BUCKET_NAME/*"
        }
    ]
}
EOF

aws s3api put-bucket-policy --bucket $BUCKET_NAME --policy file://bucket-policy.json

# 테스트 파일 생성 및 업로드
echo "Hello from AWS S3!" > test-file.txt
aws s3 cp test-file.txt s3://$BUCKET_NAME/

# GCP Cloud Storage 버킷 생성
echo "GCP Cloud Storage 버킷 생성 중..."
GCP_BUCKET_NAME="basic-course-bucket-$(date +%s)"

# GCP 버킷 생성
gsutil mb gs://$GCP_BUCKET_NAME

# 테스트 파일 업로드
echo "Hello from GCP Cloud Storage!" > gcp-test-file.txt
gsutil cp gcp-test-file.txt gs://$GCP_BUCKET_NAME/

# 버킷 목록 확인
echo "AWS S3 버킷 목록:"
aws s3 ls

echo "GCP Cloud Storage 버킷 목록:"
gsutil ls

# 파일 다운로드 테스트
echo "파일 다운로드 테스트 중..."
aws s3 cp s3://$BUCKET_NAME/test-file.txt downloaded-aws-file.txt
gsutil cp gs://$GCP_BUCKET_NAME/gcp-test-file.txt downloaded-gcp-file.txt

echo "다운로드된 파일 내용:"
echo "AWS S3:"
cat downloaded-aws-file.txt
echo "GCP Cloud Storage:"
cat downloaded-gcp-file.txt

# 정리
rm -f test-file.txt gcp-test-file.txt downloaded-aws-file.txt downloaded-gcp-file.txt bucket-policy.json

echo "스토리지 서비스 기초 실습 완료!"
echo "생성된 리소스:"
echo "- AWS S3 버킷: $BUCKET_NAME"
echo "- GCP Cloud Storage 버킷: $GCP_BUCKET_NAME"
