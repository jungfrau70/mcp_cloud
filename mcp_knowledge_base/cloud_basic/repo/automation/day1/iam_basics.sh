#!/bin/bash
# Cloud Basic 1일차: IAM 기초 실습 스크립트
# 교재: Cloud Basic - 1일차: AWS & GCP 기초 서비스 실습

set -e

# 색상 코드 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Cloud Basic 1일차: IAM 기초 실습${NC}"
echo -e "${BLUE}========================================${NC}"

# 1. IAM 기초 실습 (45분)
echo -e "\n${YELLOW}1. IAM 기초 실습${NC}"
echo "=========================================="

# 환경 변수 설정
USER_NAME="basic-course-user-$(date +%s)"
GROUP_NAME="basic-course-group-$(date +%s)"
SERVICE_ACCOUNT_NAME="basic-course-sa-$(date +%s)"

echo -e "\n${BLUE}1.1 AWS IAM 사용자 및 권한 관리${NC}"

# AWS 계정 확인
if ! aws sts get-caller-identity &> /dev/null; then
    echo -e "${RED}ERROR: AWS CLI가 설정되지 않았습니다.${NC}"
    echo "먼저 cloud_basics.sh를 실행하세요."
    exit 1
fi

# IAM 그룹 생성
echo -e "\n${BLUE}1.1.1 IAM 그룹 생성${NC}"
if aws iam get-group --group-name $GROUP_NAME &> /dev/null; then
    echo -e "${YELLOW}그룹이 이미 존재합니다. 기존 그룹을 사용합니다.${NC}"
    GROUP_NAME="basic-course-group"
else
    aws iam create-group --group-name $GROUP_NAME
    echo -e "${GREEN}✅ IAM 그룹 '$GROUP_NAME'이 생성되었습니다.${NC}"
fi

# IAM 사용자 생성
echo -e "\n${BLUE}1.1.2 IAM 사용자 생성${NC}"
if aws iam get-user --user-name $USER_NAME &> /dev/null; then
    echo -e "${YELLOW}사용자가 이미 존재합니다. 기존 사용자를 사용합니다.${NC}"
    USER_NAME="basic-course-user"
else
    aws iam create-user --user-name $USER_NAME
    echo -e "${GREEN}✅ IAM 사용자 '$USER_NAME'이 생성되었습니다.${NC}"
fi

# 사용자를 그룹에 추가
echo -e "\n${BLUE}1.1.3 사용자를 그룹에 추가${NC}"
aws iam add-user-to-group --user-name $USER_NAME --group-name $GROUP_NAME || echo -e "${YELLOW}사용자가 이미 그룹에 속해 있습니다.${NC}"

# 정책 생성
echo -e "\n${BLUE}1.1.4 IAM 정책 생성${NC}"
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
                "s3:ListBucket",
                "s3:CreateBucket",
                "s3:DeleteBucket"
            ],
            "Resource": "*"
        }
    ]
}
EOF

# 정책 생성
POLICY_NAME="BasicCoursePolicy-$(date +%s)"
aws iam create-policy --policy-name $POLICY_NAME --policy-document file://basic-course-policy.json || echo -e "${YELLOW}정책이 이미 존재합니다.${NC}"

# 그룹에 정책 연결
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
aws iam attach-group-policy --group-name $GROUP_NAME --policy-arn arn:aws:iam::$ACCOUNT_ID:policy/$POLICY_NAME || echo -e "${YELLOW}정책이 이미 연결되어 있습니다.${NC}"

echo -e "\n${BLUE}1.2 GCP 서비스 계정 및 권한 관리${NC}"

# GCP 프로젝트 확인
if [ -z "$PROJECT_ID" ]; then
    echo -e "${RED}ERROR: PROJECT_ID 환경 변수가 설정되지 않았습니다.${NC}"
    echo "먼저 cloud_basics.sh를 실행하세요."
    exit 1
fi

SERVICE_ACCOUNT_EMAIL="$SERVICE_ACCOUNT_NAME@$PROJECT_ID.iam.gserviceaccount.com"

# 서비스 계정 생성
echo -e "\n${BLUE}1.2.1 GCP 서비스 계정 생성${NC}"
if gcloud iam service-accounts describe $SERVICE_ACCOUNT_EMAIL &> /dev/null; then
    echo -e "${YELLOW}서비스 계정이 이미 존재합니다. 기존 계정을 사용합니다.${NC}"
    SERVICE_ACCOUNT_NAME="basic-course-sa"
    SERVICE_ACCOUNT_EMAIL="$SERVICE_ACCOUNT_NAME@$PROJECT_ID.iam.gserviceaccount.com"
else
    gcloud iam service-accounts create $SERVICE_ACCOUNT_NAME --display-name="Basic Course Service Account"
    echo -e "${GREEN}✅ GCP 서비스 계정 '$SERVICE_ACCOUNT_EMAIL'이 생성되었습니다.${NC}"
fi

# 서비스 계정에 권한 부여
echo -e "\n${BLUE}1.2.2 서비스 계정에 권한 부여${NC}"
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:$SERVICE_ACCOUNT_EMAIL" \
    --role="roles/compute.instanceAdmin" || echo -e "${YELLOW}권한이 이미 부여되어 있습니다.${NC}"

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:$SERVICE_ACCOUNT_EMAIL" \
    --role="roles/storage.admin" || echo -e "${YELLOW}권한이 이미 부여되어 있습니다.${NC}"

# 서비스 계정 키 생성
echo -e "\n${BLUE}1.2.3 서비스 계정 키 생성${NC}"
gcloud iam service-accounts keys create basic-course-key.json \
    --iam-account=$SERVICE_ACCOUNT_EMAIL || echo -e "${YELLOW}키가 이미 존재합니다.${NC}"

# 2. IAM 개념 학습
echo -e "\n${YELLOW}2. IAM 개념 학습${NC}"
echo "=========================================="

echo -e "\n${BLUE}2.1 AWS IAM 개념${NC}"
echo "- 사용자(User): AWS 리소스에 접근하는 개인 또는 애플리케이션"
echo "- 그룹(Group): 사용자들의 집합으로 권한을 그룹 단위로 관리"
echo "- 역할(Role): AWS 서비스나 다른 AWS 계정이 사용할 수 있는 권한"
echo "- 정책(Policy): 권한을 정의하는 JSON 문서"

echo -e "\n${BLUE}2.2 GCP IAM 개념${NC}"
echo "- 서비스 계정(Service Account): 애플리케이션이 GCP 리소스에 접근할 때 사용"
echo "- 역할(Role): 권한의 집합으로 미리 정의된 역할 사용"
echo "- 정책(Policy): 누가 어떤 리소스에 대해 어떤 작업을 할 수 있는지 정의"

# 3. 실습 결과 검증
echo -e "\n${YELLOW}3. 실습 결과 검증${NC}"
echo "=========================================="

# AWS IAM 리소스 확인
echo -e "\n${BLUE}3.1 AWS IAM 리소스 확인${NC}"
echo "생성된 IAM 사용자:"
aws iam get-user --user-name $USER_NAME --query 'User.UserName' --output text

echo "생성된 IAM 그룹:"
aws iam get-group --group-name $GROUP_NAME --query 'Group.GroupName' --output text

echo "그룹에 연결된 정책:"
aws iam list-attached-group-policies --group-name $GROUP_NAME

# GCP IAM 리소스 확인
echo -e "\n${BLUE}3.2 GCP IAM 리소스 확인${NC}"
echo "생성된 서비스 계정:"
gcloud iam service-accounts list --filter="email:$SERVICE_ACCOUNT_EMAIL"

echo "서비스 계정 권한:"
gcloud projects get-iam-policy $PROJECT_ID --flatten="bindings[].members" --format="table(bindings.role)" --filter="bindings.members:$SERVICE_ACCOUNT_EMAIL"

# 4. 다음 단계 안내
echo -e "\n${YELLOW}4. 다음 단계 안내${NC}"
echo "=========================================="
echo -e "${GREEN}🎉 IAM 기초 실습이 완료되었습니다!${NC}"

echo -e "\n${BLUE}생성된 리소스:${NC}"
echo "- AWS IAM 사용자: $USER_NAME"
echo "- AWS IAM 그룹: $GROUP_NAME"
echo "- AWS IAM 정책: $POLICY_NAME"
echo "- GCP 서비스 계정: $SERVICE_ACCOUNT_EMAIL"
echo "- GCP 서비스 계정 키: basic-course-key.json"

echo -e "\n${BLUE}다음 실습:${NC}"
echo "1. 가상머신 서비스 기초 (vm_services.sh)"
echo "2. 스토리지 서비스 기초 (storage_services.sh)"

echo -e "\n${BLUE}실습 실행 방법:${NC}"
echo "chmod +x *.sh"
echo "./vm_services.sh"

echo -e "\n${BLUE}교재 참조:${NC}"
echo "- [IAM 기초 가이드](/./textbook/Day1/iam-basics-guide.md)"
echo "- [1일차 실습 가이드](/./textbook/Day1/README.md)"

# 정리
rm -f basic-course-policy.json

echo -e "\n${GREEN}IAM 기초 실습 완료! 🚀${NC}"
