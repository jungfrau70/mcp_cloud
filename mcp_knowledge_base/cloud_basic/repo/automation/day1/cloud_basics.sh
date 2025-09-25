#!/bin/bash
# Cloud Basic 1일차: 클라우드 개념 및 계정 생성 실습 스크립트
# 교재: Cloud Basic - 1일차: AWS & GCP 기초 서비스 실습

set -e

# 색상 코드 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Cloud Basic 1일차: 클라우드 기초 실습${NC}"
echo -e "${BLUE}========================================${NC}"

# 1. 클라우드 개념 및 계정 생성 (30분)
echo -e "\n${YELLOW}1. 클라우드 개념 및 계정 생성 실습${NC}"
echo "=========================================="

# AWS 계정 설정 확인
echo -e "\n${BLUE}1.1 AWS 계정 설정 확인${NC}"
if ! aws sts get-caller-identity &> /dev/null; then
    echo -e "${RED}ERROR: AWS CLI가 설정되지 않았습니다.${NC}"
    echo -e "${YELLOW}다음 명령어로 AWS를 설정하세요:${NC}"
    echo "aws configure"
    echo "또는 AWS 계정 생성 가이드를 참조하세요:"
    echo "https://aws.amazon.com/free/"
    exit 1
fi

# GCP 계정 설정 확인
echo -e "\n${BLUE}1.2 GCP 계정 설정 확인${NC}"
if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" | head -n1 &> /dev/null; then
    echo -e "${RED}ERROR: GCP CLI가 설정되지 않았습니다.${NC}"
    echo -e "${YELLOW}다음 명령어로 GCP를 설정하세요:${NC}"
    echo "gcloud auth login"
    echo "또는 GCP 계정 생성 가이드를 참조하세요:"
    echo "https://cloud.google.com/free"
    exit 1
fi

# AWS 계정 정보 확인
echo -e "\n${GREEN}✅ AWS 계정 정보:${NC}"
aws sts get-caller-identity

# GCP 계정 정보 확인
echo -e "\n${GREEN}✅ GCP 계정 정보:${NC}"
gcloud auth list

# AWS 리전 설정
echo -e "\n${BLUE}1.3 AWS 리전 설정${NC}"
aws configure set default.region us-west-2
echo "AWS 기본 리전을 us-west-2로 설정했습니다."

# GCP 프로젝트 설정
echo -e "\n${BLUE}1.4 GCP 프로젝트 설정${NC}"
if [ -z "$PROJECT_ID" ]; then
    echo -e "${YELLOW}PROJECT_ID 환경 변수가 설정되지 않았습니다.${NC}"
    echo -e "${YELLOW}다음 명령어로 프로젝트 ID를 설정하세요:${NC}"
    echo "export PROJECT_ID=your-project-id"
    echo "또는 다음 명령어로 프로젝트를 설정하세요:"
    echo "gcloud config set project YOUR_PROJECT_ID"
    exit 1
fi

gcloud config set project $PROJECT_ID
echo "GCP 프로젝트를 $PROJECT_ID로 설정했습니다."

# AWS 서비스 목록 확인
echo -e "\n${BLUE}1.5 AWS 서비스 목록 확인${NC}"
echo "사용 가능한 AWS 리전:"
aws ec2 describe-regions --query 'Regions[].RegionName' --output table

# GCP 서비스 목록 확인
echo -e "\n${BLUE}1.6 GCP 서비스 목록 확인${NC}"
echo "활성화된 GCP 서비스:"
gcloud services list --enabled --limit=10

# 2. 클라우드 서비스 비교 분석
echo -e "\n${YELLOW}2. AWS vs GCP 서비스 비교 분석${NC}"
echo "=========================================="

echo -e "\n${BLUE}2.1 AWS 주요 서비스${NC}"
echo "- EC2: 가상머신 서비스"
echo "- S3: 객체 스토리지 서비스"
echo "- RDS: 관계형 데이터베이스 서비스"
echo "- VPC: 가상 네트워크 서비스"
echo "- IAM: 사용자 및 권한 관리 서비스"

echo -e "\n${BLUE}2.2 GCP 주요 서비스${NC}"
echo "- Compute Engine: 가상머신 서비스"
echo "- Cloud Storage: 객체 스토리지 서비스"
echo "- Cloud SQL: 관계형 데이터베이스 서비스"
echo "- VPC: 가상 네트워크 서비스"
echo "- IAM: 사용자 및 권한 관리 서비스"

# 3. 실습 결과 검증
echo -e "\n${YELLOW}3. 실습 결과 검증${NC}"
echo "=========================================="

# AWS 계정 상태 확인
echo -e "\n${BLUE}3.1 AWS 계정 상태 확인${NC}"
if aws sts get-caller-identity &> /dev/null; then
    echo -e "${GREEN}✅ AWS 계정이 정상적으로 설정되었습니다.${NC}"
    AWS_ACCOUNT=$(aws sts get-caller-identity --query 'Account' --output text)
    echo "AWS 계정 ID: $AWS_ACCOUNT"
else
    echo -e "${RED}❌ AWS 계정 설정에 문제가 있습니다.${NC}"
fi

# GCP 계정 상태 확인
echo -e "\n${BLUE}3.2 GCP 계정 상태 확인${NC}"
if gcloud auth list --filter=status:ACTIVE --format="value(account)" | head -n1 &> /dev/null; then
    echo -e "${GREEN}✅ GCP 계정이 정상적으로 설정되었습니다.${NC}"
    GCP_ACCOUNT=$(gcloud auth list --filter=status:ACTIVE --format="value(account)" | head -n1)
    echo "GCP 계정: $GCP_ACCOUNT"
else
    echo -e "${RED}❌ GCP 계정 설정에 문제가 있습니다.${NC}"
fi

# 4. 다음 단계 안내
echo -e "\n${YELLOW}4. 다음 단계 안내${NC}"
echo "=========================================="
echo -e "${GREEN}🎉 클라우드 기초 실습이 완료되었습니다!${NC}"
echo -e "\n${BLUE}다음 실습:${NC}"
echo "1. IAM 기초 실습 (iam_basics.sh)"
echo "2. 가상머신 서비스 기초 (vm_services.sh)"
echo "3. 스토리지 서비스 기초 (storage_services.sh)"

echo -e "\n${BLUE}실습 실행 방법:${NC}"
echo "chmod +x *.sh"
echo "./iam_basics.sh"

echo -e "\n${BLUE}교재 참조:${NC}"
echo "- [클라우드 계정 설정 가이드](/./textbook/Day1/aws-gcp-account-setup.md)"
echo "- [1일차 실습 가이드](/./textbook/Day1/README.md)"

echo -e "\n${GREEN}클라우드 기초 실습 완료! 🚀${NC}"
