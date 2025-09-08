#!/bin/bash

# Azure FinOps 실습 - 워크플로우 스크립트
# 이 스크립트는 구독에 대한 Contributor 권한이 필요합니다.

set -e

# 색상 정의 및 로그 함수는 동일하다고 가정

# 환경 변수 로드
if [ -f "실습1_azure_finops.env" ]; then
    source 실습1_azure_finops.env
    log_info "환경 변수를 로드했습니다."
else
    log_warning ".env 파일이 없습니다. 기본값을 사용합니다."
    RESOURCE_GROUP_NAME="RG-FinOps-Demo-tborzu5x" # 고유 식별자는 이전 스크립트 실행 시 생성된 값으로 변경해야 함
    STORAGE_ACCOUNT_NAME="finopsstoragey98d9h8t" # 고유 식별자는 이전 스크립트 실행 시 생성된 값으로 변경해야 함
    LOCATION="koreacentral"
    AZURE_DOMAIN="yourtenant.onmicrosoft.com"
fi

# 3단계: 리소스 그룹 및 스토리지 생성
create_resources() {
    # 이전과 동일한 코드
}

# 4단계: 리소스 잠금 및 정책 설정
setup_governance() {
    # 이전과 동일한 코드
}

# 5단계: FinOps 비용 관리
setup_cost_management() {
    # 이전과 동일한 코드
}

# 6단계: 역할별 테스트
test_roles() {
    # 이전과 동일한 코드
}

# 7단계: 확장 아이디어
setup_extensions() {
    # 이전과 동일한 코드
}

# 메인 실행 함수
main() {
    log_info "Azure FinOps 워크플로우를 시작합니다..."
    check_azure_cli
    check_azure_login
    
    create_resources
    setup_governance
    setup_cost_management
    test_roles
    setup_extensions
    
    log_success "Azure FinOps 워크플로우가 완료되었습니다!"
}

# 스크립트 실행
main "$@"