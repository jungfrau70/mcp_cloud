#!/bin/bash

# 스택 삭제 순서 데모 스크립트
# 생성 시간 역순 삭제의 이점을 보여주는 예시

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }

CLUSTER_NAME="cloud-intermediate-eks"
REGION="ap-northeast-2"

# 스택 삭제 순서 시뮬레이션
simulate_stack_deletion_order() {
    log_info "=== EKS 클러스터 스택 삭제 순서 시뮬레이션 ==="
    
    # 1. 현재 스택 상태 확인
    log_info "1. 현재 스택 상태 확인"
    local stacks=$(aws cloudformation list-stacks --region $REGION --query 'StackSummaries[?contains(StackName, `'$CLUSTER_NAME'`) && StackStatus != `DELETE_COMPLETE`].[StackName,StackStatus,CreationTime]' --output text 2>/dev/null)
    
    if [ -z "$stacks" ]; then
        log_info "삭제할 스택이 없습니다."
        return 0
    fi
    
    # 2. 생성 시간 순으로 정렬하여 표시
    log_info "2. 스택 목록 (생성 시간 순):"
    echo "$stacks" | sort -k3 | while IFS=$'\t' read -r stack_name stack_status creation_time; do
        log_info "  📦 $stack_name"
        log_info "     상태: $stack_status"
        log_info "     생성: $creation_time"
        echo ""
    done
    
    # 3. 삭제 순서 (생성 시간 역순)
    log_info "3. 권장 삭제 순서 (생성 시간 역순):"
    echo "$stacks" | sort -k3 -r | while IFS=$'\t' read -r stack_name stack_status creation_time; do
        log_info "  🗑️  $stack_name (생성: $creation_time)"
    done
    
    # 4. 의존성 분석
    log_info "4. 의존성 분석:"
    echo "$stacks" | sort -k3 -r | while IFS=$'\t' read -r stack_name stack_status creation_time; do
        case "$stack_name" in
            *"addon"*)
                log_info "  🔧 $stack_name - 애드온 스택 (의존성 낮음)"
                ;;
            *"nodegroup"*)
                log_info "  👥 $stack_name - 노드그룹 스택 (클러스터 의존성)"
                ;;
            *"cluster"*)
                log_info "  🏗️  $stack_name - 메인 클러스터 스택 (최고 의존성)"
                ;;
            *)
                log_info "  📋 $stack_name - 기타 스택"
                ;;
        esac
    done
}

# 스택 삭제 이점 설명
explain_deletion_benefits() {
    log_info ""
    log_info "=== 개선된 삭제 순서의 이점 ==="
    
    log_info "✅ 1. 의존성 문제 최소화"
    log_info "   - 가장 나중에 생성된 스택부터 삭제"
    log_info "   - 의존성 체인을 역순으로 따라가며 삭제"
    
    log_info "✅ 2. VPC 삭제 지연 문제 해결"
    log_info "   - 애드온과 노드그룹을 먼저 삭제"
    log_info "   - VPC를 사용하는 리소스들을 먼저 정리"
    log_info "   - 메인 클러스터 스택을 마지막에 삭제"
    
    log_info "✅ 3. 자동화된 순서 결정"
    log_info "   - 생성 시간을 기준으로 자동 정렬"
    log_info "   - 하드코딩된 순서에 의존하지 않음"
    log_info "   - 새로운 스택 타입에도 자동 대응"
    
    log_info "✅ 4. 실패 시 복구 용이성"
    log_info "   - 각 스택별로 개별 삭제 시도"
    log_info "   - 실패한 스택만 재시도 가능"
    log_info "   - 부분 삭제 상태에서도 계속 진행"
}

# 메인 실행
main() {
    log_info "EKS 클러스터 스택 삭제 순서 최적화 데모"
    log_info "클러스터: $CLUSTER_NAME"
    log_info "리전: $REGION"
    echo ""
    
    simulate_stack_deletion_order
    explain_deletion_benefits
    
    log_success "데모 완료!"
}

# 스크립트 실행
main "$@"
