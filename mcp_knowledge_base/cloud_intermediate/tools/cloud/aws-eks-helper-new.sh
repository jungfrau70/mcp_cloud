#!/bin/bash

# AWS EKS Helper 모듈
# 역할: AWS EKS 클러스터 관련 작업 실행 (조회/수정/삭제/생성)
# 
# 사용법:
#   ./aws-eks-helper.sh --action <액션> --provider aws

# =============================================================================
# 환경 설정 로드
# =============================================================================
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 공통 환경 설정 로드
if [ -f "$SCRIPT_DIR/common-environment.env" ]; then
    source "$SCRIPT_DIR/common-environment.env"
else
    echo "ERROR: 공통 환경 설정 파일을 찾을 수 없습니다"
    exit 1
fi

# AWS 환경 설정 로드
if [ -f "$SCRIPT_DIR/aws-environment.env" ]; then
    source "$SCRIPT_DIR/aws-environment.env"
    log_info "AWS 환경 설정 로드 완료"
else
    log_error "AWS 환경 설정 파일을 찾을 수 없습니다"
    exit 1
fi

# =============================================================================
# 사용법 출력
# =============================================================================
usage() {
    cat << EOF
AWS EKS Helper 모듈

사용법:
  $0 --action <액션> [옵션]

액션:
  cluster-create          # EKS 클러스터 생성
  cluster-delete          # EKS 클러스터 삭제
  cluster-status          # EKS 클러스터 상태 확인
  kubeconfig-update       # kubeconfig 업데이트
  cleanup                 # 전체 정리
  cloud-services          # 통합 클라우드 서비스 실행

예시:
  $0 --action cluster-create
  $0 --action cluster-status
  $0 --action cleanup
EOF
}

# =============================================================================
# 환경 검증
# =============================================================================
validate_environment() {
    log_step "AWS 환경 검증 중..."
    
    if ! check_command "aws"; then
        log_error "AWS CLI가 설치되지 않았습니다."
        return 1
    fi
    
    if ! check_command "eksctl"; then
        log_error "eksctl이 설치되지 않았습니다."
        return 1
    fi
    
    if ! check_command "kubectl"; then
        log_error "kubectl이 설치되지 않았습니다."
        return 1
    fi
    
    if ! aws sts get-caller-identity &> /dev/null; then
        log_error "AWS 자격 증명이 설정되지 않았습니다."
        return 1
    fi
    
    log_success "AWS 환경 검증 완료"
    return 0
}

# =============================================================================
# 리소스 존재 확인
# =============================================================================
check_cluster_exists() {
    local cluster_name="${1:-$EKS_CLUSTER_NAME}"
    
    if aws eks describe-cluster --name "$cluster_name" --region "$AWS_REGION" &> /dev/null; then
        return 0
    else
        return 1
    fi
}

# =============================================================================
# EKS 클러스터 생성
# =============================================================================
create_cluster() {
    local cluster_name="${1:-$EKS_CLUSTER_NAME}"
    
    log_header "EKS 클러스터 생성: $cluster_name"
    
    # 클러스터 존재 확인
    if check_cluster_exists "$cluster_name"; then
        log_warning "클러스터가 이미 존재합니다: $cluster_name"
        log_info "기존 클러스터를 사용하여 다음 단계를 진행합니다."
        update_progress "cluster-check" "existing" "기존 클러스터 사용: $cluster_name"
        return 0
    fi
    
    log_info "새 EKS 클러스터 생성 시작: $cluster_name"
    update_progress "cluster-create" "started" "EKS 클러스터 생성 시작"
    
    # eksctl을 사용한 클러스터 생성
    eksctl create cluster \
        --name "$cluster_name" \
        --version "$EKS_VERSION" \
        --region "$AWS_REGION" \
        --nodegroup-name "$cluster_name-nodegroup" \
        --node-type "$EKS_NODE_TYPE" \
        --nodes "$EKS_NODE_COUNT" \
        --nodes-min "$EKS_MIN_NODES" \
        --nodes-max "$EKS_MAX_NODES" \
        --managed \
        --tags "Environment=$ENVIRONMENT_TAG,Project=$PROJECT_TAG,Owner=$OWNER_TAG"
    
    local exit_code=$?
    
    if [ $exit_code -eq 0 ]; then
        log_success "EKS 클러스터 생성 완료: $cluster_name"
        update_progress "cluster-create" "completed" "EKS 클러스터 생성 완료"
        
        # kubeconfig 업데이트
        update_kubeconfig "$cluster_name"
        
        return 0
    else
        log_error "EKS 클러스터 생성 실패: $cluster_name"
        update_progress "cluster-create" "failed" "EKS 클러스터 생성 실패"
        return 1
    fi
}

# =============================================================================
# EKS 클러스터 삭제
# =============================================================================
delete_cluster() {
    local cluster_name="${1:-$EKS_CLUSTER_NAME}"
    
    log_header "EKS 클러스터 삭제: $cluster_name"
    
    # 클러스터 존재 확인
    if ! check_cluster_exists "$cluster_name"; then
        log_warning "삭제할 클러스터가 존재하지 않습니다: $cluster_name"
        update_progress "cluster-delete" "skipped" "클러스터가 존재하지 않음"
        return 0
    fi
    
    log_info "EKS 클러스터 삭제 시작: $cluster_name"
    update_progress "cluster-delete" "started" "EKS 클러스터 삭제 시작"
    
    # eksctl을 사용한 클러스터 삭제
    eksctl delete cluster --name "$cluster_name" --region "$AWS_REGION"
    
    local exit_code=$?
    
    if [ $exit_code -eq 0 ]; then
        log_success "EKS 클러스터 삭제 완료: $cluster_name"
        update_progress "cluster-delete" "completed" "EKS 클러스터 삭제 완료"
        return 0
    else
        log_error "EKS 클러스터 삭제 실패: $cluster_name"
        update_progress "cluster-delete" "failed" "EKS 클러스터 삭제 실패"
        return 1
    fi
}

# =============================================================================
# EKS 클러스터 상태 확인
# =============================================================================
check_cluster_status() {
    local cluster_name="${1:-$EKS_CLUSTER_NAME}"
    
    log_header "EKS 클러스터 상태 확인: $cluster_name"
    
    if ! check_cluster_exists "$cluster_name"; then
        log_warning "클러스터가 존재하지 않습니다: $cluster_name"
        return 1
    fi
    
    # 클러스터 정보 조회
    log_info "클러스터 기본 정보:"
    aws eks describe-cluster --name "$cluster_name" --region "$AWS_REGION" --query 'cluster.{Name:name,Status:status,Version:version,Endpoint:endpoint}' --output table
    
    # kubectl을 통한 노드 상태 확인
    if kubectl get nodes &> /dev/null; then
        log_info "노드 상태:"
        kubectl get nodes -o wide
        
        log_info "파드 상태:"
        kubectl get pods --all-namespaces
    else
        log_warning "kubectl 연결이 설정되지 않았습니다."
    fi
    
    update_progress "cluster-status" "completed" "클러스터 상태 확인 완료"
    return 0
}

# =============================================================================
# kubeconfig 업데이트
# =============================================================================
update_kubeconfig() {
    local cluster_name="${1:-$EKS_CLUSTER_NAME}"
    
    log_info "kubeconfig 업데이트: $cluster_name"
    
    aws eks update-kubeconfig --name "$cluster_name" --region "$AWS_REGION"
    
    if [ $? -eq 0 ]; then
        log_success "kubeconfig 업데이트 완료"
        return 0
    else
        log_error "kubeconfig 업데이트 실패"
        return 1
    fi
}

# =============================================================================
# 전체 정리
# =============================================================================
cleanup_all() {
    log_header "EKS 환경 전체 정리"
    
    # 클러스터 삭제
    delete_cluster
    
    update_progress "cleanup" "completed" "전체 정리 완료"
}

# =============================================================================
# 메인 실행 로직
# =============================================================================
main() {
    local action=""
    local provider="aws"
    
    # 인수 파싱
    while [[ $# -gt 0 ]]; do
        case $1 in
            --action)
                action="$2"
                shift 2
                ;;
            --provider)
                provider="$2"
                shift 2
                ;;
            --help|-h)
                usage
                exit 0
                ;;
            *)
                log_error "알 수 없는 옵션: $1"
                usage
                exit 1
                ;;
        esac
    done
    
    # 액션이 지정되지 않은 경우
    if [ -z "$action" ]; then
        log_error "액션이 지정되지 않았습니다."
        usage
        exit 1
    fi
    
    # 환경 검증
    if ! validate_environment; then
        log_error "환경 검증 실패"
        exit 1
    fi
    
    # 액션 실행
    case "$action" in
        "cluster-create")
            create_cluster
            ;;
        "cluster-delete")
            delete_cluster
            ;;
        "cluster-status")
            check_cluster_status
            ;;
        "kubeconfig-update")
            update_kubeconfig
            ;;
        "cleanup")
            cleanup_all
            ;;
        "cloud-services")
            # 메뉴에서 호출되는 통합 액션
            create_cluster
            check_cluster_status
            ;;
        *)
            log_error "알 수 없는 액션: $action"
            usage
            exit 1
            ;;
    esac
    
    # 실행 요약 보고
    generate_summary
}

# =============================================================================
# 스크립트 실행
# =============================================================================
main "$@"
