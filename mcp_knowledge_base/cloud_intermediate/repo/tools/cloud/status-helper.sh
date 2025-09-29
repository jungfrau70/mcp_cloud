#!/bin/bash

# Status Helper 모듈
# 역할: 클라우드 리소스 상태 확인 및 모니터링
# 
# 사용법:
#   ./status-helper.sh --action status --provider aws
#   ./status-helper.sh --action remaining --provider gcp

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

# =============================================================================
# 사용법 출력
# =============================================================================
usage() {
    cat << EOF
Status Helper 모듈

사용법:
  $0 --action <액션> --provider <프로바이더>

액션:
  status                  # 현재 리소스 상태 확인
  remaining               # 정리 후 남은 리소스 확인
  health-check            # 시스템 건강 상태 확인
  resource-summary        # 리소스 요약 보고

프로바이더:
  aws                     # AWS 리소스 확인
  gcp                     # GCP 리소스 확인
  all                     # 모든 프로바이더 확인

예시:
  $0 --action status --provider aws
  $0 --action remaining --provider gcp
  $0 --action health-check --provider all

상세 사용법:
  $0 --help --action status           # status 액션 상세 사용법
  $0 --help --action remaining        # remaining 액션 상세 사용법
  $0 --help --action health-check     # health-check 액션 상세 사용법
EOF
}

# =============================================================================
# 액션별 상세 사용법 함수
# =============================================================================
show_action_help() {
    local action="$1"
    
    case "$action" in
        "status")
            cat << EOF
STATUS 액션 상세 사용법:

기능:
  - 클라우드 리소스의 현재 상태를 확인합니다
  - 실행 중인 리소스와 중지된 리소스를 구분하여 표시합니다
  - 리소스별 상세 정보를 제공합니다

사용법:
  $0 --action status --provider <프로바이더> [옵션]

프로바이더:
  aws                     # AWS 리소스 상태 확인
  gcp                     # GCP 리소스 상태 확인
  all                     # 모든 프로바이더 상태 확인

옵션:
  --format <format>       # 출력 형식 (table, json, yaml)
  --verbose               # 상세 정보 출력
  --filter <filter>       # 리소스 필터링

예시:
  $0 --action status --provider aws
  $0 --action status --provider gcp --format json
  $0 --action status --provider all --verbose --filter "running"

확인되는 리소스:
  - EKS/GKE 클러스터
  - EC2/GCE 인스턴스
  - 로드 밸런서
  - 데이터베이스
  - 스토리지
  - 네트워크 리소스

출력 정보:
  - 리소스 이름
  - 현재 상태
  - 생성 시간
  - 리전/존
  - 태그 정보
EOF
            ;;
        "remaining")
            cat << EOF
REMAINING 액션 상세 사용법:

기능:
  - 정리 작업 후 남은 리소스를 확인합니다
  - 정리되지 않은 리소스의 원인을 분석합니다
  - 추가 정리가 필요한 리소스를 식별합니다

사용법:
  $0 --action remaining --provider <프로바이더> [옵션]

프로바이더:
  aws                     # AWS 남은 리소스 확인
  gcp                     # GCP 남은 리소스 확인
  all                     # 모든 프로바이더 남은 리소스 확인

옵션:
  --format <format>       # 출력 형식 (table, json, yaml)
  --verbose               # 상세 정보 출력
  --analyze               # 남은 리소스 원인 분석

예시:
  $0 --action remaining --provider aws
  $0 --action remaining --provider gcp --analyze
  $0 --action remaining --provider all --format json

분석되는 리소스:
  - 정리되지 않은 클러스터
  - 종속성으로 인해 남은 리소스
  - 보호된 리소스
  - 오류로 인해 삭제되지 않은 리소스

제공되는 정보:
  - 리소스 이름
  - 남은 이유
  - 종속성 정보
  - 해결 방법 제안
EOF
            ;;
        "health-check")
            cat << EOF
HEALTH-CHECK 액션 상세 사용법:

기능:
  - 클라우드 환경의 전반적인 건강 상태를 확인합니다
  - 시스템 성능과 가용성을 모니터링합니다
  - 문제가 있는 리소스를 식별합니다

사용법:
  $0 --action health-check --provider <프로바이더> [옵션]

프로바이더:
  aws                     # AWS 환경 건강 상태 확인
  gcp                     # GCP 환경 건강 상태 확인
  all                     # 모든 프로바이더 건강 상태 확인

옵션:
  --format <format>       # 출력 형식 (table, json, yaml)
  --verbose               # 상세 정보 출력
  --check-metrics         # 메트릭 기반 건강 상태 확인

예시:
  $0 --action health-check --provider aws
  $0 --action health-check --provider gcp --check-metrics
  $0 --action health-check --provider all --verbose

확인되는 항목:
  - 클러스터 상태
  - 노드 상태
  - 서비스 상태
  - 네트워크 연결성
  - 스토리지 상태
  - 보안 설정

건강 상태 지표:
  - 가용성 (Availability)
  - 성능 (Performance)
  - 보안 (Security)
  - 비용 (Cost)
  - 준수 (Compliance)
EOF
            ;;
        *)
            cat << EOF
알 수 없는 액션: $action

사용 가능한 액션:
  - status: 현재 리소스 상태 확인
  - remaining: 정리 후 남은 리소스 확인
  - health-check: 시스템 건강 상태 확인
  - resource-summary: 리소스 요약 보고

각 액션의 상세 사용법을 보려면:
  $0 --help --action <액션명>
EOF
            ;;
    esac
}

# =============================================================================
# --help 옵션 처리 로직
# =============================================================================
handle_help_option() {
    local action="$1"
    
    if [ -n "$action" ]; then
        show_action_help "$action"
    else
        usage
    fi
    exit 0
}

# =============================================================================
# AWS 리소스 상태 확인
# =============================================================================
check_aws_resources() {
    log_header "AWS 리소스 상태 확인"
    
    # AWS 환경 설정 로드
    if [ -f "$SCRIPT_DIR/aws-environment.env" ]; then
        source "$SCRIPT_DIR/aws-environment.env"
    else
        log_error "AWS 환경 설정 파일을 찾을 수 없습니다"
        return 1
    fi
    
    # AWS CLI 확인
    if ! check_command "aws"; then
        log_error "AWS CLI가 설치되지 않았습니다"
        return 1
    fi
    
    # 자격 증명 확인
    if ! aws sts get-caller-identity &> /dev/null; then
        log_error "AWS 자격 증명이 설정되지 않았습니다"
        return 1
    fi
    
    log_info "📊 AWS 리소스 현황:"
    
    # EKS 클러스터 확인
    log_step "EKS 클러스터 확인"
    local eks_clusters=$(aws eks list-clusters --region "$AWS_REGION" --query 'clusters' --output text 2>/dev/null)
    if [ -n "$eks_clusters" ] && [ "$eks_clusters" != "None" ]; then
        log_info "  ✅ EKS 클러스터: $eks_clusters"
        for cluster in $eks_clusters; do
            local status=$(aws eks describe-cluster --name "$cluster" --region "$AWS_REGION" --query 'cluster.status' --output text 2>/dev/null)
            log_info "    - $cluster: $status"
        done
    else
        log_info "  ❌ EKS 클러스터: 없음"
    fi
    
    # EC2 인스턴스 확인
    log_step "EC2 인스턴스 확인"
    local ec2_count=$(aws ec2 describe-instances --region "$AWS_REGION" --query 'Reservations[*].Instances[?State.Name==`running`]' --output text | wc -l)
    if [ "$ec2_count" -gt 0 ]; then
        log_info "  ✅ 실행 중인 EC2 인스턴스: $ec2_count개"
        aws ec2 describe-instances --region "$AWS_REGION" --query 'Reservations[*].Instances[?State.Name==`running`].{ID:InstanceId,Type:InstanceType,State:State.Name}' --output table
    else
        log_info "  ❌ 실행 중인 EC2 인스턴스: 없음"
    fi
    
    # VPC 확인
    log_step "VPC 확인"
    local vpc_count=$(aws ec2 describe-vpcs --region "$AWS_REGION" --query 'Vpcs[?IsDefault==`false`]' --output text | wc -l)
    if [ "$vpc_count" -gt 0 ]; then
        log_info "  ✅ 사용자 정의 VPC: $vpc_count개"
        aws ec2 describe-vpcs --region "$AWS_REGION" --query 'Vpcs[?IsDefault==`false`].{VpcId:VpcId,CidrBlock:CidrBlock,State:State}' --output table
    else
        log_info "  ❌ 사용자 정의 VPC: 없음"
    fi
    
    # 로드 밸런서 확인
    log_step "로드 밸런서 확인"
    local elb_count=$(aws elbv2 describe-load-balancers --region "$AWS_REGION" --query 'LoadBalancers' --output text | wc -l)
    if [ "$elb_count" -gt 0 ]; then
        log_info "  ✅ 로드 밸런서: $elb_count개"
        aws elbv2 describe-load-balancers --region "$AWS_REGION" --query 'LoadBalancers[].{Name:LoadBalancerName,Type:Type,State:State.Code}' --output table
    else
        log_info "  ❌ 로드 밸런서: 없음"
    fi
    
    update_progress "aws-status-check" "completed" "AWS 리소스 상태 확인 완료"
}

# =============================================================================
# GCP 리소스 상태 확인
# =============================================================================
check_gcp_resources() {
    log_header "GCP 리소스 상태 확인"
    
    # GCP 환경 설정 로드
    if [ -f "$SCRIPT_DIR/gcp-environment.env" ]; then
        source "$SCRIPT_DIR/gcp-environment.env"
    else
        log_error "GCP 환경 설정 파일을 찾을 수 없습니다"
        return 1
    fi
    
    # gcloud CLI 확인
    if ! check_command "gcloud"; then
        log_error "gcloud CLI가 설치되지 않았습니다"
        return 1
    fi
    
    # 자격 증명 확인
    if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" | head -n1 &> /dev/null; then
        log_error "GCP 자격 증명이 설정되지 않았습니다"
        return 1
    fi
    
    log_info "📊 GCP 리소스 현황:"
    
    # GKE 클러스터 확인
    log_step "GKE 클러스터 확인"
    local gke_clusters=$(gcloud container clusters list --format="value(name)" --zone="$GCP_ZONE" 2>/dev/null)
    if [ -n "$gke_clusters" ]; then
        log_info "  ✅ GKE 클러스터: $gke_clusters"
        gcloud container clusters list --zone="$GCP_ZONE" --format="table(name,status,currentMasterVersion,currentNodeVersion,numNodes)"
    else
        log_info "  ❌ GKE 클러스터: 없음"
    fi
    
    # Compute Engine 인스턴스 확인
    log_step "Compute Engine 인스턴스 확인"
    local vm_count=$(gcloud compute instances list --filter="status:RUNNING" --format="value(name)" --zone="$GCP_ZONE" 2>/dev/null | wc -l)
    if [ "$vm_count" -gt 0 ]; then
        log_info "  ✅ 실행 중인 VM 인스턴스: $vm_count개"
        gcloud compute instances list --filter="status:RUNNING" --zone="$GCP_ZONE" --format="table(name,machineType.basename(),status,zone.basename())"
    else
        log_info "  ❌ 실행 중인 VM 인스턴스: 없음"
    fi
    
    # VPC 네트워크 확인
    log_step "VPC 네트워크 확인"
    local vpc_count=$(gcloud compute networks list --format="value(name)" 2>/dev/null | grep -v default | wc -l)
    if [ "$vpc_count" -gt 0 ]; then
        log_info "  ✅ 사용자 정의 VPC: $vpc_count개"
        gcloud compute networks list --format="table(name,subnet_mode,bgp_routing_mode)"
    else
        log_info "  ❌ 사용자 정의 VPC: 없음"
    fi
    
    update_progress "gcp-status-check" "completed" "GCP 리소스 상태 확인 완료"
}

# =============================================================================
# 남은 리소스 확인
# =============================================================================
check_remaining_resources() {
    local provider="$1"
    
    log_header "정리 후 남은 리소스 확인"
    
    case "$provider" in
        "aws")
            check_aws_remaining
            ;;
        "gcp")
            check_gcp_remaining
            ;;
        "all")
            check_aws_remaining
            check_gcp_remaining
            ;;
        *)
            log_error "지원하지 않는 프로바이더: $provider"
            return 1
            ;;
    esac
}

check_aws_remaining() {
    log_step "AWS 남은 리소스 확인"
    
    # AWS 환경 설정 로드
    if [ -f "$SCRIPT_DIR/aws-environment.env" ]; then
        source "$SCRIPT_DIR/aws-environment.env"
    fi
    
    local has_resources=false
    
    # CloudFormation 스택 확인
    local cf_stacks=$(aws cloudformation list-stacks --stack-status-filter CREATE_COMPLETE UPDATE_COMPLETE --query "StackSummaries[?contains(StackName, '$PROJECT_TAG')].StackName" --output text --region "$AWS_REGION" 2>/dev/null)
    if [ -n "$cf_stacks" ] && [ "$cf_stacks" != "None" ]; then
        log_warning "⚠️ 남은 CloudFormation 스택: $cf_stacks"
        has_resources=true
    fi
    
    # IAM 역할 확인
    local iam_roles=$(aws iam list-roles --query "Roles[?contains(RoleName, '$PROJECT_TAG')].RoleName" --output text 2>/dev/null)
    if [ -n "$iam_roles" ] && [ "$iam_roles" != "None" ]; then
        log_warning "⚠️ 남은 IAM 역할: $iam_roles"
        has_resources=true
    fi
    
    if [ "$has_resources" = false ]; then
        log_success "✅ AWS 리소스가 모두 정리되었습니다"
    fi
}

check_gcp_remaining() {
    log_step "GCP 남은 리소스 확인"
    
    # GCP 환경 설정 로드
    if [ -f "$SCRIPT_DIR/gcp-environment.env" ]; then
        source "$SCRIPT_DIR/gcp-environment.env"
    fi
    
    local has_resources=false
    
    # 서비스 계정 확인
    local service_accounts=$(gcloud iam service-accounts list --filter="email:*$PROJECT_LABEL*" --format="value(email)" 2>/dev/null)
    if [ -n "$service_accounts" ]; then
        log_warning "⚠️ 남은 서비스 계정: $service_accounts"
        has_resources=true
    fi
    
    # 방화벽 규칙 확인
    local firewall_rules=$(gcloud compute firewall-rules list --filter="name:*$PROJECT_LABEL*" --format="value(name)" 2>/dev/null)
    if [ -n "$firewall_rules" ]; then
        log_warning "⚠️ 남은 방화벽 규칙: $firewall_rules"
        has_resources=true
    fi
    
    if [ "$has_resources" = false ]; then
        log_success "✅ GCP 리소스가 모두 정리되었습니다"
    fi
}

# =============================================================================
# 시스템 건강 상태 확인
# =============================================================================
health_check() {
    local provider="$1"
    
    log_header "시스템 건강 상태 확인"
    
    # 기본 도구 확인
    log_step "기본 도구 확인"
    check_command "curl"
    check_command "jq"
    check_command "kubectl"
    
    case "$provider" in
        "aws"|"all")
            log_step "AWS 도구 확인"
            check_command "aws"
            check_command "eksctl"
            
            if check_command "aws"; then
                if aws sts get-caller-identity &> /dev/null; then
                    log_success "✅ AWS 자격 증명 정상"
                else
                    log_error "❌ AWS 자격 증명 문제"
                fi
            fi
            ;;
    esac
    
    case "$provider" in
        "gcp"|"all")
            log_step "GCP 도구 확인"
            check_command "gcloud"
            
            if check_command "gcloud"; then
                if gcloud auth list --filter=status:ACTIVE --format="value(account)" | head -n1 &> /dev/null; then
                    log_success "✅ GCP 자격 증명 정상"
                else
                    log_error "❌ GCP 자격 증명 문제"
                fi
            fi
            ;;
    esac
    
    update_progress "health-check" "completed" "시스템 건강 상태 확인 완료"
}

# =============================================================================
# 리소스 요약 보고
# =============================================================================
resource_summary() {
    local provider="$1"
    
    log_header "리소스 요약 보고"
    
    case "$provider" in
        "aws")
            check_aws_resources
            ;;
        "gcp")
            check_gcp_resources
            ;;
        "all")
            check_aws_resources
            echo ""
            check_gcp_resources
            ;;
        *)
            log_error "지원하지 않는 프로바이더: $provider"
            return 1
            ;;
    esac
    
    update_progress "resource-summary" "completed" "리소스 요약 보고 완료"
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
    
    # 액션 실행
    case "$action" in
        "status")
            resource_summary "$provider"
            ;;
        "remaining")
            check_remaining_resources "$provider"
            ;;
        "health-check")
            health_check "$provider"
            ;;
        "resource-summary")
            resource_summary "$provider"
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
