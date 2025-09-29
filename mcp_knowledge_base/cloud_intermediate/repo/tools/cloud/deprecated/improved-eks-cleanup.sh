#!/bin/bash

# 개선된 EKS 클러스터 정리 스크립트
# CloudFormation 스택 의존성 문제 해결

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 로그 함수
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# 설정
CLUSTER_NAME="cloud-intermediate-eks"
REGION="ap-northeast-2"
MAX_RETRY=3
RETRY_DELAY=30

# 1. 의존성 순서대로 리소스 정리
cleanup_eks_resources() {
    log_info "=== EKS 리소스 의존성 순서 정리 ==="
    
    # 1단계: 애드온 삭제 (가장 먼저)
    log_info "1단계: EKS 애드온 삭제"
    cleanup_eks_addons
    
    # 2단계: 노드그룹 삭제
    log_info "2단계: EKS 노드그룹 삭제"
    cleanup_eks_nodegroups
    
    # 3단계: 클러스터 삭제
    log_info "3단계: EKS 클러스터 삭제"
    cleanup_eks_cluster
    
    # 4단계: CloudFormation 스택 강제 정리
    log_info "4단계: CloudFormation 스택 강제 정리"
    cleanup_cloudformation_stacks
}

# EKS 애드온 삭제
cleanup_eks_addons() {
    log_info "EKS 애드온 삭제 중..."
    
    # 설치된 애드온 목록 확인
    local addons=$(aws eks list-addons --cluster-name $CLUSTER_NAME --region $REGION --query 'addons[]' --output text 2>/dev/null)
    
    if [ -n "$addons" ]; then
        echo "$addons" | while read addon; do
            log_info "애드온 삭제: $addon"
            aws eks delete-addon --cluster-name $CLUSTER_NAME --addon-name $addon --region $REGION 2>/dev/null || true
        done
        
        # 애드온 삭제 완료 대기
        log_info "애드온 삭제 완료 대기 중..."
        sleep 30
    else
        log_info "삭제할 애드온이 없습니다."
    fi
}

# EKS 노드그룹 삭제
cleanup_eks_nodegroups() {
    log_info "EKS 노드그룹 삭제 중..."
    
    # 노드그룹 목록 확인
    local nodegroups=$(eksctl get nodegroup --cluster $CLUSTER_NAME --region $REGION --output json 2>/dev/null | jq -r '.[].Name' 2>/dev/null)
    
    if [ -n "$nodegroups" ]; then
        echo "$nodegroups" | while read nodegroup; do
            log_info "노드그룹 삭제: $nodegroup"
            eksctl delete nodegroup --cluster $CLUSTER_NAME --name $nodegroup --region $REGION --force 2>/dev/null || true
        done
        
        # 노드그룹 삭제 완료 대기
        log_info "노드그룹 삭제 완료 대기 중..."
        sleep 60
    else
        log_info "삭제할 노드그룹이 없습니다."
    fi
}

# EKS 클러스터 삭제
cleanup_eks_cluster() {
    log_info "EKS 클러스터 삭제 중..."
    
    # 클러스터 존재 확인
    if ! eksctl get cluster --name $CLUSTER_NAME --region $REGION &> /dev/null; then
        log_warning "클러스터 $CLUSTER_NAME이 존재하지 않습니다."
        return 0
    fi
    
    # 클러스터 삭제 시도
    local delete_result=$(eksctl delete cluster --name $CLUSTER_NAME --region $REGION --force 2>&1)
    local exit_code=$?
    
    if [ $exit_code -eq 0 ]; then
        log_success "EKS 클러스터 삭제 완료"
    else
        log_warning "EKS 클러스터 삭제 실패, 강제 정리 진행"
        log_info "삭제 출력: $delete_result"
    fi
}

# CloudFormation 스택 강제 정리 (클러스터 이름 기반)
cleanup_cloudformation_stacks() {
    log_info "CloudFormation 스택 강제 정리 중 (클러스터 이름: $CLUSTER_NAME)..."
    
    # 클러스터 이름이 포함된 모든 스택 찾기 (생성 시간 순으로 정렬)
    local related_stacks=$(aws cloudformation list-stacks --region $REGION --query 'StackSummaries[?contains(StackName, `'$CLUSTER_NAME'`) && StackStatus != `DELETE_COMPLETE`].[StackName,StackStatus,CreationTime]' --output text 2>/dev/null)
    
    if [ -z "$related_stacks" ]; then
        log_info "삭제할 관련 스택이 없습니다."
        return 0
    fi
    
    log_info "발견된 관련 스택들 (생성 시간 순):"
    echo "$related_stacks" | sort -k3 -r | while IFS=$'\t' read -r stack_name stack_status creation_time; do
        log_info "  - $stack_name ($stack_status) - 생성: $creation_time"
    done
    
    # 생성 시간 역순으로 삭제 (가장 나중에 생성된 것부터)
    echo "$related_stacks" | sort -k3 -r | while IFS=$'\t' read -r stack_name stack_status creation_time; do
        if [ -n "$stack_name" ]; then
            log_info "스택 삭제: $stack_name (현재 상태: $stack_status, 생성: $creation_time)"
            
            # 이미 삭제 중인 스택은 대기
            if [ "$stack_status" = "DELETE_IN_PROGRESS" ]; then
                log_info "스택 $stack_name이 이미 삭제 진행 중입니다. 완료 대기..."
                wait_for_stack_deletion "$stack_name"
            else
                # 스택 삭제 시도
                aws cloudformation delete-stack --stack-name "$stack_name" --region $REGION
                wait_for_stack_deletion "$stack_name"
            fi
        fi
    done
}

# 스택 삭제 완료 대기
wait_for_stack_deletion() {
    local stack_name="$1"
    local timeout=600  # 10분으로 증가
    local elapsed=0
    
    log_info "스택 $stack_name 삭제 완료 대기 중..."
    
    local start_time=$(date +%s)
    local last_status=""
    local last_change_time=$(date +%s)
    local stuck_count=0
    local stuck_threshold=15  # 15초 동안 변화 없으면 stuck 의심
    
    while [ $(($(date +%s) - start_time)) -lt $timeout ]; do
        if ! aws cloudformation describe-stacks --stack-name "$stack_name" --region $REGION &> /dev/null; then
            log_success "스택 $stack_name 삭제 완료"
            return 0
        fi
        
        # 현재 스택 상태 확인
        local current_status=$(aws cloudformation describe-stacks --stack-name "$stack_name" --region $REGION --query 'Stacks[0].StackStatus' --output text 2>/dev/null)
        local current_time=$(date +%s)
        local elapsed=$(($current_time - $start_time))
        
        if [ "$current_status" = "DELETE_FAILED" ]; then
            log_warning "스택 $stack_name 삭제 실패, 강제 정리 시도"
            force_cleanup_stack "$stack_name"
            return 1
        fi
        
        # 상태 변화 감지
        if [ "$current_status" != "$last_status" ]; then
            last_status="$current_status"
            last_change_time=$current_time
            stuck_count=0
            log_info "스택 $stack_name 삭제 대기 중... (${elapsed}초 경과, 상태: $current_status)"
        else
            # 상태 변화 없음
            local time_since_change=$(($current_time - $last_change_time))
            if [ $time_since_change -ge $stuck_threshold ]; then
                stuck_count=$((stuck_count + 1))
                log_warning "스택 $stack_name이 ${stuck_threshold}초 동안 변화 없음 (stuck 의심 #$stuck_count)"
                
                # Stuck 상태 해결 시도
                if [ $stuck_count -eq 1 ]; then
                    log_info "Stuck 상태 해결 시도 중..."
                    handle_stuck_stack "$stack_name"
                elif [ $stuck_count -ge 3 ]; then
                    log_error "스택 $stack_name이 3번 연속 stuck 상태입니다. 강제 정리 시도"
                    force_cleanup_stack "$stack_name"
                    return 1
                fi
            fi
        fi
        
        sleep 5
    done
    
    # 타임아웃 시 강제 정리
    log_warning "스택 $stack_name 삭제 타임아웃, 강제 정리 시도"
    force_cleanup_stack "$stack_name"
}

# Stuck 상태 해결 함수
handle_stuck_stack() {
    local stack_name="$1"
    
    log_info "Stuck 상태 해결 시도: $stack_name"
    
    # 1. 스택 상태 재확인
    local current_status=$(aws cloudformation describe-stacks --stack-name "$stack_name" --region $REGION --query 'Stacks[0].StackStatus' --output text 2>/dev/null)
    log_info "현재 상태: $current_status"
    
    # 2. 스택 이벤트 확인
    log_info "스택 이벤트 확인 중..."
    aws cloudformation describe-stack-events --stack-name "$stack_name" --region $REGION --query 'StackEvents[0:3].[Timestamp,ResourceStatus,ResourceStatusReason]' --output table 2>/dev/null
    
    # 3. 의존성 리소스 확인
    check_stack_dependencies "$stack_name"
    
    # 4. 강제 새로고침 시도
    log_info "스택 상태 강제 새로고침 시도..."
    aws cloudformation describe-stacks --stack-name "$stack_name" --region $REGION >/dev/null 2>&1
    
    # 5. AWS CLI 캐시 클리어
    aws configure set cli_cache_path /tmp/aws-cli-cache-$(date +%s)
}

# 스택 의존성 확인
check_stack_dependencies() {
    local stack_name="$1"
    
    log_info "스택 의존성 확인 중..."
    
    # EKS 클러스터 스택의 경우
    if [[ "$stack_name" == *"eks"* ]]; then
        # 노드그룹 상태 확인
        local nodegroups=$(aws eks list-nodegroups --cluster-name cloud-intermediate-eks --region ap-northeast-2 --query 'nodegroups[]' --output text 2>/dev/null)
        if [ -n "$nodegroups" ]; then
            log_warning "노드그룹이 아직 존재합니다: $nodegroups"
        fi
        
        # 애드온 상태 확인
        local addons=$(aws eks list-addons --cluster-name cloud-intermediate-eks --region ap-northeast-2 --query 'addons[]' --output text 2>/dev/null)
        if [ -n "$addons" ]; then
            log_warning "애드온이 아직 존재합니다: $addons"
        fi
        
        # VPC 관련 리소스 확인
        log_info "VPC 관련 리소스 확인 중..."
        local vpc_id=$(aws ec2 describe-vpcs --region ap-northeast-2 --filters "Name=tag:Name,Values=*cloud-intermediate-eks*" --query 'Vpcs[0].VpcId' --output text 2>/dev/null)
        if [ -n "$vpc_id" ] && [ "$vpc_id" != "None" ]; then
            log_warning "VPC가 아직 존재합니다: $vpc_id"
        fi
    fi
}

# 스택 강제 정리
force_cleanup_stack() {
    local stack_name="$1"
    log_info "스택 $stack_name 강제 정리 중..."
    
    # 1. 스택 이벤트 확인
    local failed_events=$(aws cloudformation describe-stack-events --stack-name "$stack_name" --region $REGION --query 'StackEvents[?ResourceStatus==`DELETE_FAILED`].[LogicalResourceId,ResourceStatusReason]' --output text 2>/dev/null)
    
    if [ -n "$failed_events" ]; then
        log_warning "삭제 실패한 리소스들:"
        echo "$failed_events"
        
        # 실패한 리소스별 수동 정리
        echo "$failed_events" | while IFS=$'\t' read -r resource_id reason; do
            log_info "리소스 $resource_id 수동 정리: $reason"
            manual_cleanup_resource "$resource_id" "$reason"
        done
    fi
    
    # 2. 스택 재삭제 시도
    log_info "스택 $stack_name 재삭제 시도..."
    aws cloudformation delete-stack --stack-name "$stack_name" --region $REGION
    
    # 3. 최종 확인
    sleep 30
    if ! aws cloudformation describe-stacks --stack-name "$stack_name" --region $REGION &> /dev/null; then
        log_success "스택 $stack_name 강제 정리 완료"
    else
        log_error "스택 $stack_name 강제 정리 실패"
        log_info "수동 삭제 명령어:"
        echo "aws cloudformation delete-stack --stack-name $stack_name --region $REGION"
    fi
}

# 리소스별 수동 정리
manual_cleanup_resource() {
    local resource_id="$1"
    local reason="$2"
    
    case "$resource_id" in
        *"SecurityGroup"*)
            log_info "보안 그룹 $resource_id 수동 삭제 시도..."
            aws ec2 delete-security-group --group-id "$resource_id" 2>/dev/null || true
            ;;
        *"Subnet"*)
            log_info "서브넷 $resource_id 수동 삭제 시도..."
            aws ec2 delete-subnet --subnet-id "$resource_id" 2>/dev/null || true
            ;;
        *"VPC"*)
            log_info "VPC $resource_id 수동 삭제 시도..."
            aws ec2 delete-vpc --vpc-id "$resource_id" 2>/dev/null || true
            ;;
        *"NATGateway"*)
            log_info "NAT Gateway $resource_id 수동 삭제 시도..."
            aws ec2 delete-nat-gateway --nat-gateway-id "$resource_id" 2>/dev/null || true
            ;;
        *)
            log_info "리소스 $resource_id 수동 정리 방법을 확인하세요."
            ;;
    esac
}

# 메인 실행
main() {
    log_info "=== 개선된 EKS 클러스터 정리 시작 ==="
    log_info "클러스터: $CLUSTER_NAME"
    log_info "리전: $REGION"
    
    # 의존성 순서대로 정리
    cleanup_eks_resources
    
    # 최종 확인
    log_info "=== 최종 정리 확인 ==="
    
    # 남은 CloudFormation 스택 확인
    local remaining_stacks=$(aws cloudformation list-stacks --region $REGION --query 'StackSummaries[?contains(StackName, `eksctl-'$CLUSTER_NAME'`) && StackStatus != `DELETE_COMPLETE`].[StackName,StackStatus]' --output table 2>/dev/null)
    
    if [ -n "$remaining_stacks" ]; then
        log_warning "아직 남은 스택들:"
        echo "$remaining_stacks"
    else
        log_success "모든 CloudFormation 스택이 정리되었습니다."
    fi
    
    log_success "EKS 클러스터 정리 완료!"
}

# 스크립트 실행
main "$@"
