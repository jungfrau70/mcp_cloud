#!/bin/bash
# IAM 기초 실습 스크립트

set -e

echo "IAM 기초 실습 시작..."

# AWS IAM 사용자 생성
echo "AWS IAM 사용자 생성 중..."
USER_NAME="basic-course-user"
GROUP_NAME="basic-course-group"

# IAM 그룹 생성
aws iam create-group --group-name $GROUP_NAME || echo "그룹이 이미 존재합니다."

# IAM 사용자 생성
aws iam create-user --user-name $USER_NAME || echo "사용자가 이미 존재합니다."

# 사용자를 그룹에 추가
aws iam add-user-to-group --user-name $USER_NAME --group-name $GROUP_NAME

# 정책 생성
cat > basic-course-policy.json << 'EOF'
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ec2:Describe*",
                "ec2:RunInstances",
                "ec2:TerminateInstances",
                "s3:GetObject",
                "s3:PutObject",
                "s3:ListBucket"
            ],
            "Resource": "*"
        }
    ]
}
EOF

# 정책 생성
aws iam create-policy --policy-name BasicCoursePolicy --policy-document file://basic-course-policy.json || echo "정책이 이미 존재합니다."

# 그룹에 정책 연결
aws iam attach-group-policy --group-name $GROUP_NAME --policy-arn arn:aws:iam::$(aws sts get-caller-identity --query Account --output text):policy/BasicCoursePolicy

# GCP 서비스 계정 생성
echo "GCP 서비스 계정 생성 중..."
SERVICE_ACCOUNT_NAME="basic-course-sa"
SERVICE_ACCOUNT_EMAIL="$SERVICE_ACCOUNT_NAME@$PROJECT_ID.iam.gserviceaccount.com"

# 서비스 계정 생성
gcloud iam service-accounts create $SERVICE_ACCOUNT_NAME --display-name="Basic Course Service Account" || echo "서비스 계정이 이미 존재합니다."

# 서비스 계정에 권한 부여
gcloud projects add-iam-policy-binding $PROJECT_ID     --member="serviceAccount:$SERVICE_ACCOUNT_EMAIL"     --role="roles/compute.instanceAdmin"

gcloud projects add-iam-policy-binding $PROJECT_ID     --member="serviceAccount:$SERVICE_ACCOUNT_EMAIL"     --role="roles/storage.admin"

# 서비스 계정 키 생성
gcloud iam service-accounts keys create basic-course-key.json     --iam-account=$SERVICE_ACCOUNT_EMAIL

echo "IAM 기초 실습 완료!"
echo "생성된 리소스:"
echo "- AWS IAM 사용자: $USER_NAME"
echo "- AWS IAM 그룹: $GROUP_NAME"
echo "- GCP 서비스 계정: $SERVICE_ACCOUNT_EMAIL"
echo "- GCP 서비스 계정 키: basic-course-key.json"
