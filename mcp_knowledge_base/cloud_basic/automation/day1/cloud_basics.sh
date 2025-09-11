#!/bin/bash
# 클라우드 기초 실습 스크립트

set -e

echo "클라우드 기초 실습 시작..."

# AWS 계정 설정 확인
echo "AWS 계정 설정 확인 중..."
if ! aws sts get-caller-identity &> /dev/null; then
    echo "ERROR: AWS CLI가 설정되지 않았습니다."
    echo "다음 명령어로 AWS를 설정하세요:"
    echo "aws configure"
    exit 1
fi

# GCP 계정 설정 확인
echo "GCP 계정 설정 확인 중..."
if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" | head -n1 &> /dev/null; then
    echo "ERROR: GCP CLI가 설정되지 않았습니다."
    echo "다음 명령어로 GCP를 설정하세요:"
    echo "gcloud auth login"
    exit 1
fi

# AWS 계정 정보 확인
echo "AWS 계정 정보:"
aws sts get-caller-identity

# GCP 계정 정보 확인
echo "GCP 계정 정보:"
gcloud auth list

# AWS 리전 설정
echo "AWS 리전 설정 중..."
aws configure set default.region us-west-2

# GCP 프로젝트 설정
echo "GCP 프로젝트 설정 중..."
if [ -z "$PROJECT_ID" ]; then
    echo "ERROR: PROJECT_ID 환경 변수를 설정하세요."
    echo "export PROJECT_ID=your-project-id"
    exit 1
fi

gcloud config set project $PROJECT_ID

# AWS 서비스 목록 확인
echo "AWS 서비스 목록:"
aws ec2 describe-regions --query 'Regions[].RegionName' --output table

# GCP 서비스 목록 확인
echo "GCP 서비스 목록:"
gcloud services list --enabled

echo "클라우드 기초 실습 완료!"
