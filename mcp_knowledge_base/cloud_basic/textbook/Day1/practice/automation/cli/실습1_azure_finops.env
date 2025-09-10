#!/bin/bash

# Azure FinOps 실습 - 초기 환경 설정 스크립트
# 이 스크립트는 구독 수준의 높은 권한이 필요합니다.

set -e

# 색상 정의 및 로그 함수는 동일하다고 가정

# 랜덤 문자열 생성 함수
generate_random_string() {
    local length=${1:-8}
    cat /dev/urandom | tr -dc 'a-z0-9' | fold -w $length | head -n 1
}

# 고유 식별자 생성
UNIQUE_SUFFIX=$(generate_random_string 8)
log_info "고유 식별자 생성: $UNIQUE_SUFFIX"

# 환경 변수 로드
if [ -f "실습1_azure_finops.env" ]; then
    source 실습1_azure_finops.env
    log_info "환경 변수를 로드했습니다."
else
    log_warning ".env 파일이 없습니다. 기본값을 사용합니다."
    SUBSCRIPTION_NAME="Azure subscription 1"
    MANAGEMENT_GROUP_ID="MG-Company"
    AZURE_DOMAIN="yourtenant.onmicrosoft.com"
fi

# Azure CLI 및 로그인 확인 함수는 생략 (위에 있으므로)

# 1단계: Azure 환경 준비
setup_azure_environment() {
    log_info "=== 1단계: Azure 환경 준비 ==="
    log_info "현재 구독을 확인합니다..."
    az account list --output table
    
    log_info "구독을 설정합니다: $SUBSCRIPTION_NAME"
    az account set --subscription "$SUBSCRIPTION_NAME"
    
    log_info "관리 그룹 존재 여부를 확인합니다: $MANAGEMENT_GROUP_ID"
    if az account management-group show --name "$MANAGEMENT_GROUP_ID" &> /dev/null; then
        log_warning "관리 그룹이 이미 존재합니다: $MANAGEMENT_GROUP_ID"
    else
        log_info "관리 그룹을 생성합니다: $MANAGEMENT_GROUP_ID"
        az account management-group create --name "$MANAGEMENT_GROUP_ID" --display-name "Company Management Group"
    fi
    
    log_info "구독이 관리 그룹에 연결되어 있는지 확인합니다..."
    if az account management-group subscription show --name "$MANAGEMENT_GROUP_ID" --subscription "$SUBSCRIPTION_NAME" &> /dev/null; then
        log_warning "구독이 이미 관리 그룹에 연결되어 있습니다."
    else
        log_info "구독을 관리 그룹에 연결합니다..."
        az account management-group subscription add --name "$MANAGEMENT_GROUP_ID" --subscription "$SUBSCRIPTION_NAME"
    fi
    log_success "Azure 환경 준비가 완료되었습니다."
}

# 2단계: Entra ID 사용자 및 역할 생성
create_users_and_roles() {
    log_info "=== 2단계: Entra ID 사용자 및 역할 생성 ==="
    
    CURRENT_USER=$(az account show --query user.name -o tsv)
    log_info "현재 사용자: $CURRENT_USER"
    
    log_info "재무팀 사용자를 생성합니다..."
    az ad user create --display-name "Finance User" --user-principal-name "finance_user_$UNIQUE_SUFFIX@$AZURE_DOMAIN" --password "TempPass123!"
    
    log_info "IT 관리자 사용자를 생성합니다..."
    az ad user create --display-name "IT Admin User" --user-principal-name "itadmin_user_$UNIQUE_SUFFIX@$AZURE_DOMAIN" --password "TempPass123!"
    
    log_info "IT 엔지니어 사용자를 생성합니다..."
    az ad user create --display-name "IT Engineer User" --user-principal-name "engineer_user_$UNIQUE_SUFFIX@$AZURE_DOMAIN" --password "TempPass123!"
    
    SUBSCRIPTION_ID=$(az account show --query id -o tsv)
    log_info "구독 ID: $SUBSCRIPTION_ID"
    
    log_info "재무팀 사용자에게 Cost Management Reader 역할을 할당합니다..."
    az role assignment create --assignee "finance_user_$UNIQUE_SUFFIX@$AZURE_DOMAIN" --role "Cost Management Reader" --scope "/subscriptions/$SUBSCRIPTION_ID"
    
    log_info "IT 관리자에게 Contributor 역할을 할당합니다..."
    az role assignment create --assignee "itadmin_user_$UNIQUE_SUFFIX@$AZURE_DOMAIN" --role "Contributor" --scope "/subscriptions/$SUBSCRIPTION_ID"
    
    log_success "사용자 및 역할 생성이 완료되었습니다."
}

main() {
    log_info "Azure FinOps 초기 환경 설정을 시작합니다..."
    check_azure_cli
    check_azure_login
    setup_azure_environment
    create_users_and_roles
    log_success "초기 설정이 성공적으로 완료되었습니다!"
}

main "$@"