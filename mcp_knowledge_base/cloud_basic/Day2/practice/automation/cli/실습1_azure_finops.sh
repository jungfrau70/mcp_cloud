#!/bin/bash

# Azure FinOps 실습 자동화 스크립트
# 실습1: Azure FinOps 실습 시나리오

set -e  # 오류 발생 시 스크립트 중단

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 로그 함수
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

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
    # 기본값 설정 (고유 식별자 추가)
    SUBSCRIPTION_NAME=$SUBSCRIPTION_NAME
    MANAGEMENT_GROUP_ID="MG-Company-$UNIQUE_SUFFIX"
    RESOURCE_GROUP_NAME="RG-FinOps-Demo-$UNIQUE_SUFFIX"
    STORAGE_ACCOUNT_NAME="finopsstorage$UNIQUE_SUFFIX"
    LOCATION="koreacentral"
fi

# Azure CLI 설치 확인
check_azure_cli() {
    log_info "Azure CLI 설치 상태를 확인합니다..."
    if ! command -v az &> /dev/null; then
        log_error "Azure CLI가 설치되지 않았습니다."
        log_info "설치 방법:"
        log_info "Windows: winget install Microsoft.AzureCLI"
        log_info "macOS: brew install azure-cli"
        log_info "Ubuntu: curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash"
        exit 1
    fi
    log_success "Azure CLI가 설치되어 있습니다."
}

# Azure 로그인 확인
check_azure_login() {
    log_info "Azure 로그인 상태를 확인합니다..."
    if ! az account show &> /dev/null; then
        log_error "Azure에 로그인되지 않았습니다."
        log_info "다음 명령어로 로그인하세요: az login"
        exit 1
    fi
    log_success "Azure에 로그인되어 있습니다."
}

# 1단계: Azure 환경 준비
setup_azure_environment() {
    log_info "=== 1단계: Azure 환경 준비 ==="
    
    # 구독 확인
    log_info "현재 구독을 확인합니다..."
    az account list --output table
    
    # 구독 설정
    log_info "구독을 설정합니다: $SUBSCRIPTION_NAME"
    az account set --subscription "$SUBSCRIPTION_NAME"
    
    # 관리 그룹 존재 여부 확인
    log_info "관리 그룹 존재 여부를 확인합니다: $MANAGEMENT_GROUP_ID"
    if az account management-group show --name "$MANAGEMENT_GROUP_ID" &> /dev/null; then
        log_warning "관리 그룹이 이미 존재합니다: $MANAGEMENT_GROUP_ID"
        log_info "기존 관리 그룹을 사용합니다."
    else
        # 관리 그룹 생성
        log_info "관리 그룹을 생성합니다: $MANAGEMENT_GROUP_ID"
        az account management-group create --name "$MANAGEMENT_GROUP_ID" --display-name "Company Management Group"
    fi
    
    # 구독이 관리 그룹에 연결되어 있는지 확인
    log_info "구독이 관리 그룹에 연결되어 있는지 확인합니다..."
    if az account management-group subscription show --name "$MANAGEMENT_GROUP_ID" --subscription "$SUBSCRIPTION_NAME" &> /dev/null; then
        log_warning "구독이 이미 관리 그룹에 연결되어 있습니다."
    else
        # 구독을 관리 그룹에 연결
        log_info "구독을 관리 그룹에 연결합니다..."
        az account management-group subscription add --name "$MANAGEMENT_GROUP_ID" --subscription "$SUBSCRIPTION_NAME"
    fi
    
    log_success "Azure 환경 준비가 완료되었습니다."
}

# 2단계: Entra ID 사용자 및 역할 생성
create_users_and_roles() {
    log_info "=== 2단계: Entra ID 사용자 및 역할 생성 ==="
    
    # Guest User 권한 체크
    CURRENT_USER=$(az account show --query user.name -o tsv)
    log_info "현재 사용자: $CURRENT_USER"
    
    # Guest User인지 확인 (외부 도메인 사용자)
    if [[ "$CURRENT_USER" == *"@gmail.com"* ]] || [[ "$CURRENT_USER" == *"@hotmail.com"* ]] || [[ "$CURRENT_USER" == *"@outlook.com"* ]]; then
        log_warning "Guest User로 감지되었습니다. 사용자 생성 및 역할 할당을 건너뜁니다."
        log_info "Guest User는 Azure AD에서 사용자 생성 및 역할 할당 권한이 제한됩니다."
        log_info "리소스 생성 단계로 진행합니다."
        return 0
    fi
    
    # 사용자 존재 여부 확인 및 생성
    log_info "재무팀 사용자 존재 여부를 확인합니다..."
    if az ad user show --id "finance_user_$UNIQUE_SUFFIX@$AZURE_DOMAIN" &> /dev/null; then
        log_warning "재무팀 사용자가 이미 존재합니다: finance_user_$UNIQUE_SUFFIX@$AZURE_DOMAIN"
    else
        log_info "재무팀 사용자를 생성합니다..."
        az ad user create \
            --display-name "Finance User" \
            --user-principal-name "finance_user_$UNIQUE_SUFFIX@$AZURE_DOMAIN" \
            --password "TempPass123!"
    fi
    
    log_info "IT 관리자 사용자 존재 여부를 확인합니다..."
    if az ad user show --id "itadmin_user_$UNIQUE_SUFFIX@$AZURE_DOMAIN" &> /dev/null; then
        log_warning "IT 관리자 사용자가 이미 존재합니다: itadmin_user_$UNIQUE_SUFFIX@$AZURE_DOMAIN"
    else
        log_info "IT 관리자 사용자를 생성합니다..."
        az ad user create \
            --display-name "IT Admin User" \
            --user-principal-name "itadmin_user_$UNIQUE_SUFFIX@$AZURE_DOMAIN" \
            --password "TempPass123!"
    fi
    
    log_info "IT 엔지니어 사용자 존재 여부를 확인합니다..."
    if az ad user show --id "engineer_user_$UNIQUE_SUFFIX@$AZURE_DOMAIN" &> /dev/null; then
        log_warning "IT 엔지니어 사용자가 이미 존재합니다: engineer_user_$UNIQUE_SUFFIX@$AZURE_DOMAIN"
    else
        log_info "IT 엔지니어 사용자를 생성합니다..."
        az ad user create \
            --display-name "IT Engineer User" \
            --user-principal-name "engineer_user_$UNIQUE_SUFFIX@$AZURE_DOMAIN" \
            --password "TempPass123!"
    fi
    
    # 구독 ID 확인 및 설정
    SUBSCRIPTION_ID=$(az account show --query id -o tsv)
    log_info "구독 ID: $SUBSCRIPTION_ID"
    
    # 역할 할당 (이미 할당되어 있는지 확인)
    log_info "재무팀 사용자 역할 할당을 확인합니다..."
    if az role assignment list --assignee "finance_user_$UNIQUE_SUFFIX@$AZURE_DOMAIN" --role "Cost Management Reader" --scope "/subscriptions/$SUBSCRIPTION_ID" --query "[].id" --output tsv | grep -q .; then
        log_warning "재무팀 사용자에게 이미 Cost Management Reader 역할이 할당되어 있습니다."
    else
        log_info "재무팀 사용자에게 Cost Management Reader 역할을 할당합니다..."
        az role assignment create \
            --assignee "finance_user_$UNIQUE_SUFFIX@$AZURE_DOMAIN" \
            --role "Cost Management Reader" \
            --scope "/subscriptions/$SUBSCRIPTION_ID"
    fi
    
    log_info "IT 관리자 역할 할당을 확인합니다..."
    if az role assignment list --assignee "itadmin_user_$UNIQUE_SUFFIX@$AZURE_DOMAIN" --role "Contributor" --scope "/subscriptions/$SUBSCRIPTION_ID" --query "[].id" --output tsv | grep -q .; then
        log_warning "IT 관리자에게 이미 Contributor 역할이 할당되어 있습니다."
    else
        log_info "IT 관리자에게 Contributor 역할을 할당합니다..."
        az role assignment create \
            --assignee "itadmin_user_$UNIQUE_SUFFIX@$AZURE_DOMAIN" \
            --role "Contributor" \
            --scope "/subscriptions/$SUBSCRIPTION_ID"
    fi
    
    log_success "사용자 및 역할 생성이 완료되었습니다."
}

# 3단계: 리소스 그룹 및 스토리지 생성
create_resources() {
    log_info "=== 3단계: 리소스 그룹 및 스토리지 생성 ==="
    
    # 리소스 그룹 존재 여부 확인
    log_info "리소스 그룹 존재 여부를 확인합니다: $RESOURCE_GROUP_NAME"
    if az group show --name "$RESOURCE_GROUP_NAME" &> /dev/null; then
        log_warning "리소스 그룹이 이미 존재합니다: $RESOURCE_GROUP_NAME"
        log_info "기존 리소스 그룹을 사용합니다."
    else
        # 리소스 그룹 생성
        log_info "리소스 그룹을 생성합니다: $RESOURCE_GROUP_NAME"
        az group create --name "$RESOURCE_GROUP_NAME" --location "$LOCATION"
    fi
    
    # 스토리지 계정 존재 여부 확인
    log_info "스토리지 계정 존재 여부를 확인합니다: $STORAGE_ACCOUNT_NAME"
    if az storage account show --name "$STORAGE_ACCOUNT_NAME" --resource-group "$RESOURCE_GROUP_NAME" &> /dev/null; then
        log_warning "스토리지 계정이 이미 존재합니다: $STORAGE_ACCOUNT_NAME"
        log_info "기존 스토리지 계정을 사용합니다."
    else
        # 스토리지 계정 생성
        log_info "스토리지 계정을 생성합니다: $STORAGE_ACCOUNT_NAME"
        az storage account create \
            --name "$STORAGE_ACCOUNT_NAME" \
            --resource-group "$RESOURCE_GROUP_NAME" \
            --location "$LOCATION" \
            --sku "Standard_LRS" \
            --kind "StorageV2"
    fi
    
    # Blob 컨테이너 존재 여부 확인
    log_info "Blob 컨테이너 존재 여부를 확인합니다..."
    if az storage container show --name "finops-data" --account-name "$STORAGE_ACCOUNT_NAME" &> /dev/null; then
        log_warning "Blob 컨테이너가 이미 존재합니다: finops-data"
    else
        # Blob 컨테이너 생성
        log_info "Blob 컨테이너를 생성합니다..."
        az storage container create \
            --name "finops-data" \
            --account-name "$STORAGE_ACCOUNT_NAME" \
            --auth-mode login
    fi
    
    # IT 엔지니어 역할 할당 확인 (Guest User인 경우 건너뛰기)
    CURRENT_USER=$(az account show --query user.name -o tsv)
    if [[ "$CURRENT_USER" == *"@gmail.com"* ]] || [[ "$CURRENT_USER" == *"@hotmail.com"* ]] || [[ "$CURRENT_USER" == *"@outlook.com"* ]]; then
        log_warning "Guest User로 감지되었습니다. 역할 할당을 건너뜁니다."
    else
        log_info "IT 엔지니어 Storage Blob Data Contributor 역할 할당을 확인합니다..."
        STORAGE_ACCOUNT_ID=$(az storage account show --name "$STORAGE_ACCOUNT_NAME" --resource-group "$RESOURCE_GROUP_NAME" --query id -o tsv)
        if az role assignment list --assignee "engineer_user_$UNIQUE_SUFFIX@$AZURE_DOMAIN" --role "Storage Blob Data Contributor" --scope "$STORAGE_ACCOUNT_ID" --query "[].id" --output tsv | grep -q .; then
            log_warning "IT 엔지니어에게 이미 Storage Blob Data Contributor 역할이 할당되어 있습니다."
        else
            log_info "IT 엔지니어에게 Storage Blob Data Contributor 역할을 할당합니다..."
            az role assignment create \
                --assignee "engineer_user_$UNIQUE_SUFFIX@$AZURE_DOMAIN" \
                --role "Storage Blob Data Contributor" \
                --scope "$STORAGE_ACCOUNT_ID"
        fi
    fi
    
    log_success "리소스 생성이 완료되었습니다."
}

# 4단계: 리소스 잠금 및 정책 설정
setup_governance() {
    log_info "=== 4단계: 리소스 잠금 및 정책 설정 ==="
    
    # 리소스 잠금 존재 여부 확인
    log_info "리소스 잠금 존재 여부를 확인합니다..."
    if az lock show --name "CanNotDelete" --resource-group "$RESOURCE_GROUP_NAME" &> /dev/null; then
        log_warning "리소스 잠금이 이미 존재합니다: CanNotDelete"
    else
        # 리소스 잠금 설정
        log_info "리소스 그룹에 삭제 잠금을 설정합니다..."
        az lock create \
            --name "CanNotDelete" \
            --resource-group "$RESOURCE_GROUP_NAME" \
            --lock-type "CanNotDelete"
    fi
    
    # 정책 정의 존재 여부 확인
    POLICY_NAME="AllowedLocations-$UNIQUE_SUFFIX"
    log_info "정책 정의 존재 여부를 확인합니다: $POLICY_NAME"
    if az policy definition show --name "$POLICY_NAME" &> /dev/null; then
        log_warning "정책 정의가 이미 존재합니다: $POLICY_NAME"
    else
        # 정책 정의 JSON 파일 생성
        log_info "지역 제한 정책을 생성합니다..."
        cat > allowed-locations-policy.json << 'EOF'
{
  "if": {
    "not": {
      "field": "location",
      "in": ["koreacentral", "koreasouth"]
    }
  },
  "then": {
    "effect": "deny"
  }
}
EOF
        
        # 정책 정의 생성 (고유 식별자 추가)
        az policy definition create \
            --name "$POLICY_NAME" \
            --display-name "Allowed Locations" \
            --description "한국 리전만 허용" \
            --rules allowed-locations-policy.json \
            --mode All
    fi
    
    # 정책 할당 존재 여부 확인
    ASSIGNMENT_NAME="AllowedLocationsAssignment-$UNIQUE_SUFFIX"
    SUBSCRIPTION_ID=$(az account show --query id -o tsv)
    log_info "정책 할당 존재 여부를 확인합니다: $ASSIGNMENT_NAME"
    log_info "구독 ID: $SUBSCRIPTION_ID"
    
    # Guest User인 경우 정책 할당 건너뛰기
    CURRENT_USER=$(az account show --query user.name -o tsv)
    if [[ "$CURRENT_USER" == *"@gmail.com"* ]] || [[ "$CURRENT_USER" == *"@hotmail.com"* ]] || [[ "$CURRENT_USER" == *"@outlook.com"* ]]; then
        log_warning "Guest User로 감지되었습니다. 정책 할당을 건너뜁니다."
        log_info "Guest User는 정책 할당 권한이 제한됩니다."
    else
        if az policy assignment show --name "$ASSIGNMENT_NAME" --scope "/subscriptions/$SUBSCRIPTION_ID" &> /dev/null; then
            log_warning "정책 할당이 이미 존재합니다: $ASSIGNMENT_NAME"
        else
            # 정책 할당
            log_info "정책을 구독에 할당합니다..."
            az policy assignment create \
                --name "$ASSIGNMENT_NAME" \
                --display-name "Allowed Locations Assignment" \
                --policy "$POLICY_NAME" \
                --scope "/subscriptions/$SUBSCRIPTION_ID"
        fi
    fi
    
    log_success "거버넌스 설정이 완료되었습니다."
}

# 5단계: FinOps 비용 관리
setup_cost_management() {
    log_info "=== 5단계: FinOps 비용 관리 ==="
    
    # Guest User인 경우 예산 생성 건너뛰기
    CURRENT_USER=$(az account show --query user.name -o tsv)
    if [[ "$CURRENT_USER" == *"@gmail.com"* ]] || [[ "$CURRENT_USER" == *"@hotmail.com"* ]] || [[ "$CURRENT_USER" == *"@outlook.com"* ]]; then
        log_warning "Guest User로 감지되었습니다. 예산 생성을 건너뜁니다."
        log_info "Azure Consumption Budget API는 preview 상태이며 Guest User 권한이 제한됩니다."
        log_info "비용 관리 설정을 건너뛰고 다음 단계로 진행합니다."
        return 0
    fi
    
    # 예산 존재 여부 확인
    BUDGET_NAME="MonthlyBudget-$UNIQUE_SUFFIX"
    log_info "예산 존재 여부를 확인합니다: $BUDGET_NAME"
    if az consumption budget show --budget-name "$BUDGET_NAME" --resource-group "$RESOURCE_GROUP_NAME" &> /dev/null; then
        log_warning "예산이 이미 존재합니다: $BUDGET_NAME"
    else
        # 예산 JSON 파일 생성
        log_info "예산을 설정합니다..."
        cat > budget.json << 'EOF'
{
  "amount": 100,
  "timeGrain": "Monthly",
  "timePeriod": {
    "startDate": "2024-01-01T00:00:00Z",
    "endDate": "2024-12-31T23:59:59Z"
  },
  "notifications": {
    "Actual_GreaterThan_80_Percent": {
      "enabled": true,
      "operator": "GreaterThan",
      "threshold": 80,
      "contactEmails": ["finance_user_EMAIL_PLACEHOLDER@contoso.onmicrosoft.com"]
    }
  }
}
EOF
        
        # 이메일 주소 치환
        sed -i "s/EMAIL_PLACEHOLDER/$UNIQUE_SUFFIX/g" budget.json
        
        # 예산 생성
        az consumption budget create \
            --budget-name "$BUDGET_NAME" \
            --resource-group "$RESOURCE_GROUP_NAME" \
            --amount 100 \
            --time-grain "Monthly" \
            --start-date "2024-01-01" \
            --end-date "2024-12-31" \
            --category "Cost" \
            --notifications "{\"Actual_GreaterThan_80_Percent\":{\"enabled\":true,\"operator\":\"GreaterThan\",\"threshold\":80,\"contactEmails\":[\"finance_user_$UNIQUE_SUFFIX@$AZURE_DOMAIN\"]}}"
    fi
    
    log_success "비용 관리 설정이 완료되었습니다."
}

# 6단계: 역할별 테스트
test_roles() {
    log_info "=== 6단계: 역할별 테스트 ==="
    
    # Guest User인 경우 역할 테스트 건너뛰기
    CURRENT_USER=$(az account show --query user.name -o tsv)
    if [[ "$CURRENT_USER" == *"@gmail.com"* ]] || [[ "$CURRENT_USER" == *"@hotmail.com"* ]] || [[ "$CURRENT_USER" == *"@outlook.com"* ]]; then
        log_warning "Guest User로 감지되었습니다. 역할별 테스트를 건너뜁니다."
        log_info "Guest User는 스토리지 Blob 데이터 접근 권한이 제한됩니다."
        log_info "스토리지 계정 및 컨테이너는 생성되었지만 데이터 접근 테스트는 건너뜁니다."
        
        # 리소스 그룹 삭제 시도 (실패해야 함) - 잠금 테스트만 진행
        log_info "리소스 그룹 삭제를 시도합니다 (실패해야 함)..."
        if az group delete --name "$RESOURCE_GROUP_NAME" --yes 2>&1 | grep -q "잠금"; then
            log_success "잠금이 정상적으로 작동합니다."
        else
            log_warning "잠금 테스트 결과를 확인하세요."
        fi
        
        log_success "역할별 테스트를 건너뛰었습니다."
        return 0
    fi
    
    # 테스트 파일 생성
    log_info "테스트 파일을 생성합니다..."
    echo "This is a test file for FinOps demo" > test-file.txt
    
    # IT 엔지니어 역할로 Blob 업로드 테스트
    log_info "IT 엔지니어 역할로 Blob 업로드를 테스트합니다..."
    az storage blob upload \
        --account-name "$STORAGE_ACCOUNT_NAME" \
        --container-name "finops-data" \
        --name "test-file.txt" \
        --file "test-file.txt" \
        --auth-mode login
    
    # 업로드된 파일 확인
    log_info "업로드된 파일을 확인합니다..."
    az storage blob list \
        --account-name "$STORAGE_ACCOUNT_NAME" \
        --container-name "finops-data" \
        --auth-mode login \
        --output table
    
    # 리소스 그룹 삭제 시도 (실패해야 함)
    log_info "리소스 그룹 삭제를 시도합니다 (실패해야 함)..."
    if az group delete --name "$RESOURCE_GROUP_NAME" --yes 2>&1 | grep -q "잠금"; then
        log_success "잠금이 정상적으로 작동합니다."
    else
        log_warning "잠금 테스트 결과를 확인하세요."
    fi
    
    log_success "역할별 테스트가 완료되었습니다."
}

# 7단계: 확장 아이디어
setup_extensions() {
    log_info "=== 7단계: 확장 아이디어 ==="
    
    # 리소스 그룹에 태그 추가
    log_info "리소스 그룹에 태그를 추가합니다..."
    az group update --name "$RESOURCE_GROUP_NAME" \
        --set tags.Department=Finance tags.Project=FinOps tags.Owner=ITTeam tags.UniqueID="$UNIQUE_SUFFIX"
    
    # 태그 확인
    log_info "태그를 확인합니다..."
    az group show --name "$RESOURCE_GROUP_NAME" --query tags
    
    log_success "확장 설정이 완료되었습니다."
}

# 메인 실행 함수
main() {
    log_info "Azure FinOps 실습 자동화를 시작합니다..."
    log_info "고유 식별자: $UNIQUE_SUFFIX"
    
    check_azure_cli
    check_azure_login
    
    setup_azure_environment
    create_users_and_roles
    create_resources
    setup_governance
    setup_cost_management
    test_roles
    setup_extensions
    
    log_success "Azure FinOps 실습 자동화가 완료되었습니다!"
    log_info "생성된 리소스 정보:"
    log_info "- 관리 그룹: $MANAGEMENT_GROUP_ID"
    log_info "- 리소스 그룹: $RESOURCE_GROUP_NAME"
    log_info "- 스토리지 계정: $STORAGE_ACCOUNT_NAME"
    log_info "- 고유 식별자: $UNIQUE_SUFFIX"
    log_info ""
    log_info "다음 단계:"
    log_info "1. Azure Portal에서 생성된 리소스 확인"
    log_info "2. 각 사용자로 로그인하여 권한 테스트"
    log_info "3. Cost Management에서 비용 분석 확인"
}

# 스크립트 실행
main "$@"
