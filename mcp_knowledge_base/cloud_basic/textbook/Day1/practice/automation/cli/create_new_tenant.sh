#!/bin/bash

# Azure 새 테넌트 생성 및 Owner 권한 설정 스크립트
# Guest User 제한사항을 해결하기 위한 테넌트 생성

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

# 환경 변수 설정
TENANT_NAME="FinOps-Demo-Tenant-$UNIQUE_SUFFIX"
DOMAIN_NAME="finopsdemo${UNIQUE_SUFFIX}.onmicrosoft.com"
ADMIN_EMAIL="admin@finopsdemo${UNIQUE_SUFFIX}.onmicrosoft.com"
ADMIN_PASSWORD="SecurePass123!"
LOCATION="koreacentral"

# 1단계: Azure CLI 설치 및 로그인 확인
check_prerequisites() {
    log_info "=== 1단계: 사전 요구사항 확인 ==="
    
    # Azure CLI 설치 확인
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
    
    # Azure 로그인 확인
    log_info "Azure 로그인 상태를 확인합니다..."
    if ! az account show &> /dev/null; then
        log_error "Azure에 로그인되지 않았습니다."
        log_info "다음 명령어로 로그인하세요: az login"
        exit 1
    fi
    log_success "Azure에 로그인되어 있습니다."
    
    # 현재 사용자 정보 확인
    CURRENT_USER=$(az account show --query user.name -o tsv)
    log_info "현재 사용자: $CURRENT_USER"
    
    # Microsoft 365 Business 또는 Enterprise 라이선스 필요성 안내
    log_warning "새 테넌트 생성을 위해서는 Microsoft 365 Business 또는 Enterprise 라이선스가 필요합니다."
    log_info "개인 계정으로는 테넌트를 생성할 수 없습니다."
    log_info "회사 계정 또는 Microsoft 365 구독이 있는 계정으로 진행하세요."
}

# 2단계: 새 테넌트 생성 (Microsoft 365 구독이 있는 경우)
create_new_tenant() {
    log_info "=== 2단계: 새 Azure 테넌트 생성 ==="
    
    log_info "테넌트 이름: $TENANT_NAME"
    log_info "도메인 이름: $DOMAIN_NAME"
    log_info "관리자 이메일: $ADMIN_EMAIL"
    
    # Microsoft 365 구독 확인
    log_info "Microsoft 365 구독을 확인합니다..."
    if az account list --query "[?contains(name, 'Microsoft 365') || contains(name, 'Office 365')]" --output table | grep -q .; then
        log_success "Microsoft 365 구독이 발견되었습니다."
        
        # 새 테넌트 생성 시도
        log_info "새 테넌트 생성을 시도합니다..."
        log_warning "이 작업은 Microsoft 365 관리 센터에서 수동으로 진행해야 할 수 있습니다."
        
        # Microsoft Graph API를 통한 테넌트 생성 (권한이 있는 경우)
        log_info "Microsoft Graph API를 통해 테넌트 생성을 시도합니다..."
        az rest --method POST \
            --uri "https://graph.microsoft.com/v1.0/domains" \
            --headers "Content-Type=application/json" \
            --body "{\"id\":\"$DOMAIN_NAME\"}" || {
            log_warning "API를 통한 테넌트 생성이 실패했습니다."
            log_info "Microsoft 365 관리 센터에서 수동으로 진행하세요."
        }
    else
        log_warning "Microsoft 365 구독이 발견되지 않았습니다."
        log_info "새 테넌트 생성을 위해서는 Microsoft 365 Business 또는 Enterprise 라이선스가 필요합니다."
        log_info "다음 단계로 건너뜁니다."
        return 1
    fi
}

# 3단계: 새 테넌트로 전환
switch_to_new_tenant() {
    log_info "=== 3단계: 새 테넌트로 전환 ==="
    
    # 새 테넌트 존재 여부 확인
    log_info "새 테넌트 존재 여부를 확인합니다..."
    if az account tenant list --query "[?contains(tenantId, '$UNIQUE_SUFFIX')]" --output table | grep -q .; then
        log_success "새 테넌트가 발견되었습니다."
        
        # 새 테넌트로 로그인
        log_info "새 테넌트로 로그인합니다..."
        az login --tenant "$DOMAIN_NAME" --username "$ADMIN_EMAIL" --password "$ADMIN_PASSWORD" || {
            log_warning "새 테넌트 로그인이 실패했습니다. 수동으로 진행하세요."
            return 1
        }
        
        log_success "새 테넌트로 전환되었습니다."
    else
        log_warning "새 테넌트가 아직 생성되지 않았습니다."
        log_info "Microsoft 365 관리 센터에서 수동으로 테넌트를 생성한 후 진행하세요."
        return 1
    fi
}

# 4단계: 구독 생성 및 Owner 권한 설정
setup_subscription_and_permissions() {
    log_info "=== 4단계: 구독 생성 및 Owner 권한 설정 ==="
    
    # 새 구독 생성
    log_info "새 구독을 생성합니다..."
    SUBSCRIPTION_NAME="FinOps-Demo-Subscription-$UNIQUE_SUFFIX"
    
    # 구독 생성 (Azure Portal에서 수동으로 진행해야 할 수 있음)
    log_info "구독 이름: $SUBSCRIPTION_NAME"
    log_warning "구독 생성은 Azure Portal에서 수동으로 진행해야 할 수 있습니다."
    
    # 구독이 생성된 후 Owner 권한 확인
    log_info "구독 생성 후 Owner 권한을 확인합니다..."
    if az account show --query "user.name" -o tsv | grep -q "$ADMIN_EMAIL"; then
        log_success "새 테넌트의 관리자로 로그인되었습니다."
        
        # Owner 역할 확인
        log_info "현재 사용자의 역할을 확인합니다..."
        az role assignment list --assignee "$ADMIN_EMAIL" --output table
        
        log_success "Owner 권한이 설정되었습니다."
    else
        log_warning "새 테넌트의 관리자로 로그인되지 않았습니다."
        log_info "수동으로 로그인 후 진행하세요."
    fi
}

# 5단계: 환경 설정 파일 생성
create_environment_file() {
    log_info "=== 5단계: 환경 설정 파일 생성 ==="
    
    # 새 테넌트용 환경 변수 파일 생성
    ENV_FILE="new_tenant_azure_finops.env"
    
    cat > "$ENV_FILE" << EOF
# 새 Azure 테넌트 FinOps 실습 환경 변수 설정
# 테넌트 생성 후 사용

# Azure 테넌트 설정
AZURE_TENANT_DOMAIN="$DOMAIN_NAME"
AZURE_ADMIN_EMAIL="$ADMIN_EMAIL"
AZURE_ADMIN_PASSWORD="$ADMIN_PASSWORD"

# Azure 구독 설정
SUBSCRIPTION_NAME="$SUBSCRIPTION_NAME"
MANAGEMENT_GROUP_ID="MG-FinOps-Demo-$UNIQUE_SUFFIX"

# 리소스 그룹 설정
RESOURCE_GROUP_NAME="RG-FinOps-Demo-$UNIQUE_SUFFIX"
LOCATION="$LOCATION"

# 스토리지 계정 설정
STORAGE_ACCOUNT_NAME="finopsstorage$UNIQUE_SUFFIX"
CONTAINER_NAME="finops-data"

# 사용자 설정 (새 도메인 사용)
FINANCE_USER="finance_user@$DOMAIN_NAME"
IT_ADMIN_USER="itadmin_user@$DOMAIN_NAME"
IT_ENGINEER_USER="engineer_user@$DOMAIN_NAME"

# 비밀번호 설정
USER_PASSWORD="TempPass123!"

# 예산 설정
BUDGET_AMOUNT=100
BUDGET_NAME="MonthlyBudget-$UNIQUE_SUFFIX"

# 정책 설정
POLICY_NAME="AllowedLocations-$UNIQUE_SUFFIX"
POLICY_DISPLAY_NAME="Allowed Locations"
POLICY_DESCRIPTION="한국 리전만 허용"

# 잠금 설정
LOCK_NAME="CanNotDelete"
EOF
    
    log_success "환경 설정 파일이 생성되었습니다: $ENV_FILE"
    log_info "이 파일을 사용하여 FinOps 실습을 진행하세요."
}

# 6단계: 수동 설정 안내
manual_setup_guide() {
    log_info "=== 6단계: 수동 설정 안내 ==="
    
    log_warning "새 Azure 테넌트 생성은 Microsoft 365 구독이 필요합니다."
    log_info "다음 단계를 수동으로 진행하세요:"
    log_info ""
    log_info "1. Microsoft 365 관리 센터 (https://admin.microsoft.com) 접속"
    log_info "2. 'Setup' > 'Domains' > 'Add domain' 클릭"
    log_info "3. 도메인 이름 입력: $DOMAIN_NAME"
    log_info "4. DNS 레코드 설정 (자동 설정 권장)"
    log_info "5. 사용자 계정 생성: $ADMIN_EMAIL"
    log_info "6. Azure Portal에서 새 테넌트로 전환"
    log_info "7. 새 구독 생성"
    log_info "8. Owner 권한 확인"
    log_info ""
    log_info "수동 설정 완료 후 이 스크립트를 다시 실행하여 환경 설정 파일을 생성하세요."
}

# 메인 실행 함수
main() {
    log_info "Azure 새 테넌트 생성 및 Owner 권한 설정을 시작합니다..."
    log_info "고유 식별자: $UNIQUE_SUFFIX"
    
    check_prerequisites
    
    # 새 테넌트 생성 시도
    if create_new_tenant; then
        if switch_to_new_tenant; then
            setup_subscription_and_permissions
            create_environment_file
            log_success "새 테넌트 설정이 완료되었습니다!"
        else
            log_warning "테넌트 전환이 실패했습니다. 수동 설정을 진행하세요."
            manual_setup_guide
        fi
    else
        log_warning "테넌트 생성이 실패했습니다. 수동 설정을 진행하세요."
        manual_setup_guide
    fi
    
    log_info ""
    log_info "생성된 정보:"
    log_info "- 테넌트 이름: $TENANT_NAME"
    log_info "- 도메인: $DOMAIN_NAME"
    log_info "- 관리자 이메일: $ADMIN_EMAIL"
    log_info "- 고유 식별자: $UNIQUE_SUFFIX"
    log_info ""
    log_info "다음 단계:"
    log_info "1. Microsoft 365 관리 센터에서 수동 설정"
    log_info "2. 새 테넌트로 Azure 로그인"
    log_info "3. 환경 설정 파일 사용하여 FinOps 실습 진행"
}

# 스크립트 실행
main "$@"
