#!/bin/bash

# 고도화된 EKS 클러스터 삭제 스크립트
# 기능: 클러스터 삭제 → 잔여 스택 삭제 → 의존성 리소스 분석 및 강제 삭제 → 진행 로그

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 로그 함수
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_debug() { echo -e "${CYAN}[DEBUG]${NC} $1"; }

# 환경 변수 로드
if [ $# -eq 0 ]; then
    log_error "사용법: $0 <환경파일>"
    log_info "예시: $0 dev.env"
    exit 1
fi

ENV_FILE="$1"
if [ ! -f "$ENV_FILE" ]; then
    log_error "환경 파일을 찾을 수 없습니다: $ENV_FILE"
    exit 1
fi

# 환경 변수 로드
source "$ENV_FILE"

if [[ -z "$CLUSTER_NAME" ]]; then
    log_error "환경 파일에 CLUSTER_NAME이 정의되어 있지 않습니다."
    exit 1
fi

# 리전 설정 (기본값: ap-northeast-2)
REGION="${AWS_REGION:-ap-northeast-2}"

log_info "=== 고도화된 EKS 클러스터 삭제 시작 ==="
log_info "클러스터: $CLUSTER_NAME"
log_info "리전: $REGION"

# 1. EKS 클러스터 삭제
log_info "1단계: EKS 클러스터 삭제"
if aws eks describe-cluster --name "$CLUSTER_NAME" --region "$REGION" &> /dev/null; then
    log_info "클러스터 $CLUSTER_NAME 삭제 중..."
    if aws eks delete-cluster --name "$CLUSTER_NAME" --region "$REGION"; then
        log_success "클러스터 삭제 명령 실행 완료"
    else
        log_error "클러스터 삭제 명령 실행 실패"
        exit 1
    fi
else
    log_warning "클러스터 $CLUSTER_NAME이 존재하지 않습니다."
fi

# 2. 클러스터 삭제 대기 (Stuck 감지 포함)
log_info "2단계: 클러스터 삭제 완료 대기"
wait_for_cluster_deletion() {
    local timeout=600  # 10분
    local stuck_threshold=15  # 15초
    local start_time=$(date +%s)
    local last_status=""
    local last_change_time=$(date +%s)
    local stuck_count=0
    
    while [ $(($(date +%s) - start_time)) -lt $timeout ]; do
        if ! aws eks describe-cluster --name "$CLUSTER_NAME" --region "$REGION" &> /dev/null; then
            log_success "클러스터 $CLUSTER_NAME 삭제 완료"
            return 0
        fi
        
        local current_status=$(aws eks describe-cluster --name "$CLUSTER_NAME" --region "$REGION" --query 'cluster.status' --output text 2>/dev/null)
        local current_time=$(date +%s)
        local elapsed=$(($current_time - $start_time))
        
        if [ "$current_status" != "$last_status" ]; then
            last_status="$current_status"
            last_change_time=$current_time
            stuck_count=0
            log_info "클러스터 삭제 대기 중... (${elapsed}초 경과, 상태: $current_status)"
        else
            local time_since_change=$(($current_time - $last_change_time))
            if [ $time_since_change -ge $stuck_threshold ]; then
                stuck_count=$((stuck_count + 1))
                log_warning "클러스터가 ${stuck_threshold}초 동안 변화 없음 (stuck 의심 #$stuck_count)"
                
                if [ $stuck_count -ge 3 ]; then
                    log_error "클러스터가 3번 연속 stuck 상태입니다. 강제 진행합니다."
                    break
                fi
            fi
        fi
        
        sleep 5
    done
    
    if [ $(($(date +%s) - start_time)) -ge $timeout ]; then
        log_warning "클러스터 삭제 대기 타임아웃 (${timeout}초)"
    fi
}

wait_for_cluster_deletion

# 3. 고도화된 CloudFormation 스택 삭제
log_info "3단계: 고도화된 CloudFormation 스택 삭제"
cleanup_remaining_stacks() {
    log_info "클러스터 이름 기반 스택 검색: $CLUSTER_NAME"
    
    # 클러스터 이름이 포함된 모든 스택 찾기
    local related_stacks=$(aws cloudformation list-stacks --region "$REGION" --query 'StackSummaries[?contains(StackName, `'$CLUSTER_NAME'`) && StackStatus != `DELETE_COMPLETE`].[StackName,StackStatus,CreationTime]' --output text 2>/dev/null)
    
    if [ -z "$related_stacks" ]; then
        log_info "삭제할 관련 스택이 없습니다."
        return 0
    fi
    
    log_info "발견된 관련 스택들:"
    echo "$related_stacks" | while IFS=$'\t' read -r stack_name stack_status creation_time; do
        log_info "  - $stack_name ($stack_status) - 생성: $creation_time"
    done
    
    # 생성 시간 역순으로 삭제 (가장 나중에 생성된 것부터)
    echo "$related_stacks" | sort -k3 -r | while IFS=$'\t' read -r stack_name stack_status creation_time; do
        if [ -n "$stack_name" ]; then
            log_info "스택 처리: $stack_name (현재 상태: $stack_status)"
            
            case "$stack_status" in
                DELETE_IN_PROGRESS)
                    log_warning "스택 $stack_name이 이미 삭제 진행 중입니다. 타임아웃 기반 대기..."
                    wait_for_stack_deletion_with_timeout "$stack_name"
                    ;;
                DELETE_FAILED)
                    log_warning "스택 $stack_name 삭제 실패 상태입니다. 의존성 리소스 분석 및 강제 삭제 시도..."
                    handle_delete_failed_stack "$stack_name"
                    ;;
                *)
                    log_info "스택 삭제 시작: $stack_name"
                    aws cloudformation delete-stack --stack-name "$stack_name" --region "$REGION"
                    wait_for_stack_deletion_with_timeout "$stack_name"
                    ;;
            esac
        fi
    done
}

# 타임아웃 기반 스택 삭제 대기 (DELETE_IN_PROGRESS 처리 포함)
wait_for_stack_deletion_with_timeout() {
    local stack_name="$1"
    local timeout=600   # 10분
    local interval=15   # 15초 간격
    local elapsed=0
    
    log_info "⏳ 스택 삭제 대기 중: $stack_name (최대 ${timeout}초)"
    
    while [ $elapsed -lt $timeout ]; do
        local status=$(aws cloudformation describe-stacks --stack-name "$stack_name" --region "$REGION" --query "Stacks[0].StackStatus" --output text 2>/dev/null)
        
        if [[ "$status" == "DELETE_COMPLETE" ]]; then
            log_success "✅ 스택 삭제 완료: $stack_name"
            return 0
        elif [[ "$status" == "DELETE_FAILED" ]]; then
            log_error "❌ 스택 삭제 실패 감지: $stack_name"
            handle_delete_failed_stack "$stack_name"
            return $?
        elif [[ "$status" == "DELETE_IN_PROGRESS" ]]; then
            log_info "⌛ 삭제 진행 중... (${elapsed}초 경과)"
            sleep $interval
            elapsed=$((elapsed + interval))
        else
            log_warning "⚠️ 예기치 않은 상태: $status → 스택 이름 확인 필요"
            return 1
        fi
    done
    
    log_warning "⏰ 삭제 타임아웃 초과 (${timeout}초): $stack_name"
    log_info "🔍 스택 강제 리소스 분석 시작..."
    handle_delete_failed_stack "$stack_name"
}

# 삭제 실패 스택 처리 (의존성 리소스 분석 및 강제 삭제)
handle_delete_failed_stack() {
    local stack_name="$1"
    
    log_warning "🔍 스택 $stack_name 의존성 리소스 분석 중..."
    
    # 1. 스택 이벤트 분석
    analyze_stack_events "$stack_name"
    
    # 2. 의존성 리소스 확인 및 강제 삭제
    cleanup_dependent_resources "$stack_name"
    
    # 3. 스택 재삭제 시도
    log_info "🔄 스택 $stack_name 재삭제 시도..."
    aws cloudformation delete-stack --stack-name "$stack_name" --region "$REGION"
    
    # 4. 재삭제 결과 대기
    wait_for_stack_deletion_with_timeout "$stack_name"
}

# 스택 이벤트 분석
analyze_stack_events() {
    local stack_name="$1"
    
    log_debug "📊 스택 $stack_name 이벤트 분석 중..."
    
    # 최근 10개 이벤트 조회
    aws cloudformation describe-stack-events --stack-name "$stack_name" --region "$REGION" \
        --query 'StackEvents[0:10].[Timestamp,ResourceStatus,ResourceStatusReason,LogicalResourceId,PhysicalResourceId]' \
        --output table 2>/dev/null
    
    # DELETE_FAILED 이벤트만 필터링
    local failed_events=$(aws cloudformation describe-stack-events --stack-name "$stack_name" --region "$REGION" \
        --query 'StackEvents[?ResourceStatus==`DELETE_FAILED`].[LogicalResourceId,ResourceStatusReason]' \
        --output text 2>/dev/null)
    
    if [ -n "$failed_events" ]; then
        log_warning "❌ 삭제 실패 리소스들:"
        echo "$failed_events" | while IFS=$'\t' read -r logical_id reason; do
            log_warning "  - $logical_id: $reason"
        done
    fi
}

# 의존성 리소스 정리
cleanup_dependent_resources() {
    local stack_name="$1"
    
    log_info "🧹 의존성 리소스 정리 중: $stack_name"
    
    # 스택 리소스 조회
    local stack_resources=$(aws cloudformation describe-stack-resources --stack-name "$stack_name" --region "$REGION" \
        --query 'StackResources[?ResourceStatus!=`DELETE_COMPLETE`].[LogicalResourceId,ResourceType,PhysicalResourceId]' \
        --output text 2>/dev/null)
    
    if [ -n "$stack_resources" ]; then
        log_warning "🔍 삭제되지 않은 리소스들:"
        echo "$stack_resources" | while IFS=$'\t' read -r logical_id resource_type physical_id; do
            log_warning "  - $logical_id ($resource_type): $physical_id"
            
            # 리소스 타입별 강제 삭제 시도
            case "$resource_type" in
                "AWS::EC2::SecurityGroup")
                    cleanup_security_group "$physical_id"
                    ;;
                "AWS::EC2::NetworkInterface")
                    cleanup_network_interface "$physical_id"
                    ;;
                "AWS::EC2::Volume")
                    cleanup_ebs_volume "$physical_id"
                    ;;
                "AWS::EC2::VPC")
                    cleanup_vpc "$physical_id"
                    ;;
                "AWS::EC2::Subnet")
                    cleanup_subnet "$physical_id"
                    ;;
                "AWS::EC2::InternetGateway")
                    cleanup_internet_gateway "$physical_id"
                    ;;
                "AWS::EC2::NatGateway")
                    cleanup_nat_gateway "$physical_id"
                    ;;
                *)
                    log_debug "알 수 없는 리소스 타입: $resource_type"
                    ;;
            esac
        done
    fi
}

# Security Group 정리
cleanup_security_group() {
    local sg_id="$1"
    if [ -n "$sg_id" ] && [ "$sg_id" != "None" ]; then
        log_info "🔒 Security Group 정리: $sg_id"
        
        # 보안 그룹 규칙 삭제
        aws ec2 describe-security-groups --group-ids "$sg_id" --region "$REGION" \
            --query 'SecurityGroups[0].IpPermissions' --output json 2>/dev/null | \
            jq -r '.[] | select(.IpProtocol != "-1") | "\(.IpProtocol) \(.FromPort) \(.ToPort) \(.IpRanges[0].CidrIp // "0.0.0.0/0")"' | \
            while read protocol from_port to_port cidr; do
                if [ "$protocol" != "null" ]; then
                    aws ec2 revoke-security-group-ingress --group-id "$sg_id" --protocol "$protocol" --port "$from_port-$to_port" --cidr "$cidr" --region "$REGION" 2>/dev/null
                fi
            done
        
        # 보안 그룹 삭제
        aws ec2 delete-security-group --group-id "$sg_id" --region "$REGION" 2>/dev/null
    fi
}

# Network Interface 정리
cleanup_network_interface() {
    local eni_id="$1"
    if [ -n "$eni_id" ] && [ "$eni_id" != "None" ]; then
        log_info "🌐 Network Interface 정리: $eni_id"
        
        # ENI 분리 및 삭제
        aws ec2 detach-network-interface --attachment-id "$eni_id" --region "$REGION" 2>/dev/null
        aws ec2 delete-network-interface --network-interface-id "$eni_id" --region "$REGION" 2>/dev/null
    fi
}

# EBS Volume 정리
cleanup_ebs_volume() {
    local volume_id="$1"
    if [ -n "$volume_id" ] && [ "$volume_id" != "None" ]; then
        log_info "💾 EBS Volume 정리: $volume_id"
        
        # 볼륨 분리 및 삭제
        aws ec2 detach-volume --volume-id "$volume_id" --region "$REGION" 2>/dev/null
        aws ec2 delete-volume --volume-id "$volume_id" --region "$REGION" 2>/dev/null
    fi
}

# VPC 정리
cleanup_vpc() {
    local vpc_id="$1"
    if [ -n "$vpc_id" ] && [ "$vpc_id" != "None" ]; then
        log_info "🏗️ VPC 정리: $vpc_id"
        
        # VPC 내 리소스 정리
        cleanup_vpc_resources "$vpc_id"
        
        # VPC 삭제
        aws ec2 delete-vpc --vpc-id "$vpc_id" --region "$REGION" 2>/dev/null
    fi
}

# VPC 내 리소스 정리
cleanup_vpc_resources() {
    local vpc_id="$1"
    
    # 서브넷 삭제
    aws ec2 describe-subnets --filters "Name=vpc-id,Values=$vpc_id" --region "$REGION" \
        --query 'Subnets[].SubnetId' --output text | \
        while read subnet_id; do
            if [ -n "$subnet_id" ]; then
                aws ec2 delete-subnet --subnet-id "$subnet_id" --region "$REGION" 2>/dev/null
            fi
        done
    
    # Internet Gateway 분리 및 삭제
    aws ec2 describe-internet-gateways --filters "Name=attachment.vpc-id,Values=$vpc_id" --region "$REGION" \
        --query 'InternetGateways[].InternetGatewayId' --output text | \
        while read igw_id; do
            if [ -n "$igw_id" ]; then
                aws ec2 detach-internet-gateway --internet-gateway-id "$igw_id" --vpc-id "$vpc_id" --region "$REGION" 2>/dev/null
                aws ec2 delete-internet-gateway --internet-gateway-id "$igw_id" --region "$REGION" 2>/dev/null
            fi
        done
    
    # NAT Gateway 삭제
    aws ec2 describe-nat-gateways --filter "Name=vpc-id,Values=$vpc_id" --region "$REGION" \
        --query 'NatGateways[].NatGatewayId' --output text | \
        while read nat_gateway_id; do
            if [ -n "$nat_gateway_id" ]; then
                aws ec2 delete-nat-gateway --nat-gateway-id "$nat_gateway_id" --region "$REGION" 2>/dev/null
            fi
        done
}

# Subnet 정리
cleanup_subnet() {
    local subnet_id="$1"
    if [ -n "$subnet_id" ] && [ "$subnet_id" != "None" ]; then
        log_info "🌐 Subnet 정리: $subnet_id"
        aws ec2 delete-subnet --subnet-id "$subnet_id" --region "$REGION" 2>/dev/null
    fi
}

# Internet Gateway 정리
cleanup_internet_gateway() {
    local igw_id="$1"
    if [ -n "$igw_id" ] && [ "$igw_id" != "None" ]; then
        log_info "🌍 Internet Gateway 정리: $igw_id"
        
        # VPC에서 분리
        aws ec2 describe-internet-gateways --internet-gateway-ids "$igw_id" --region "$REGION" \
            --query 'InternetGateways[0].Attachments[0].VpcId' --output text | \
            while read vpc_id; do
                if [ -n "$vpc_id" ] && [ "$vpc_id" != "None" ]; then
                    aws ec2 detach-internet-gateway --internet-gateway-id "$igw_id" --vpc-id "$vpc_id" --region "$REGION" 2>/dev/null
                fi
            done
        
        # Internet Gateway 삭제
        aws ec2 delete-internet-gateway --internet-gateway-id "$igw_id" --region "$REGION" 2>/dev/null
    fi
}

# NAT Gateway 정리
cleanup_nat_gateway() {
    local nat_gateway_id="$1"
    if [ -n "$nat_gateway_id" ] && [ "$nat_gateway_id" != "None" ]; then
        log_info "🌐 NAT Gateway 정리: $nat_gateway_id"
        aws ec2 delete-nat-gateway --nat-gateway-id "$nat_gateway_id" --region "$REGION" 2>/dev/null
    fi
}

cleanup_remaining_stacks

# 4. 최종 확인
log_info "4단계: 최종 확인"
log_info "남은 CloudFormation 스택 확인..."
aws cloudformation list-stacks --region "$REGION" --query 'StackSummaries[?contains(StackName, `'$CLUSTER_NAME'`) && StackStatus != `DELETE_COMPLETE`].[StackName,StackStatus]' --output table 2>/dev/null

log_info "EKS 클러스터 확인..."
if aws eks describe-cluster --name "$CLUSTER_NAME" --region "$REGION" &> /dev/null; then
    log_warning "클러스터 $CLUSTER_NAME이 아직 존재합니다."
else
    log_success "클러스터 $CLUSTER_NAME이 완전히 삭제되었습니다."
fi

log_success "=== 고도화된 EKS 클러스터 삭제 프로세스 완료 ==="
