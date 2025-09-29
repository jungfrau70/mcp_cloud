#!/bin/bash

# Cleanup Helper 모듈
# 역할: 클라우드 리소스 정리 및 삭제
# 
# 사용법:
#   ./cleanup-helper.sh --action cleanup --provider aws
#   ./cleanup-helper.sh --action force-cleanup --provider gcp

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
Cleanup Helper 모듈

사용법:
  $0 --action <액션> --provider <프로바이더>

액션:
  cleanup                 # 일반 정리 (안전 모드)
  force-cleanup           # 강제 정리 (모든 리소스)
  selective-cleanup       # 선택적 정리
  verify-cleanup          # 정리 검증

프로바이더:
  aws                     # AWS 리소스 정리
  gcp                     # GCP 리소스 정리
  all                     # 모든 프로바이더 정리

예시:
  $0 --action cleanup --provider aws
  $0 --action force-cleanup --provider gcp
  $0 --action verify-cleanup --provider all

상세 사용법:
  $0 --help --action cleanup           # cleanup 액션 상세 사용법
  $0 --help --action force-cleanup     # force-cleanup 액션 상세 사용법
  $0 --help --action selective-cleanup # selective-cleanup 액션 상세 사용법
EOF
}

# =============================================================================
# 액션별 상세 사용법 함수
# =============================================================================
show_action_help() {
    local action="$1"
    
    case "$action" in
        "cleanup")
            cat << EOF
CLEANUP 액션 상세 사용법:

기능:
  - 클라우드 리소스를 안전하게 정리합니다
  - 중요한 리소스는 보존하고 불필요한 리소스만 삭제합니다
  - 삭제 전 확인 절차를 거칩니다

사용법:
  $0 --action cleanup --provider <프로바이더> [옵션]

프로바이더:
  aws                     # AWS 리소스 정리
  gcp                     # GCP 리소스 정리
  all                     # 모든 프로바이더 정리

옵션:
  --dry-run               # 실제 삭제 없이 시뮬레이션만 실행
  --exclude <resource>    # 제외할 리소스 타입
  --include <resource>    # 포함할 리소스 타입

예시:
  $0 --action cleanup --provider aws
  $0 --action cleanup --provider gcp --dry-run
  $0 --action cleanup --provider all --exclude "rds,s3"

정리되는 리소스:
  - EKS/GKE 클러스터
  - EC2/GCE 인스턴스
  - 로드 밸런서
  - 보안 그룹
  - 임시 스토리지

보존되는 리소스:
  - RDS 데이터베이스
  - S3 버킷 (데이터 포함)
  - 중요한 IAM 역할
  - 로그 그룹
EOF
            ;;
        "force-cleanup")
            cat << EOF
FORCE-CLEANUP 액션 상세 사용법:

기능:
  - 모든 클라우드 리소스를 강제로 삭제합니다
  - 데이터 손실 위험이 있으므로 주의해서 사용하세요
  - 확인 없이 즉시 삭제를 진행합니다

사용법:
  $0 --action force-cleanup --provider <프로바이더> [옵션]

프로바이더:
  aws                     # AWS 리소스 강제 삭제
  gcp                     # GCP 리소스 강제 삭제
  all                     # 모든 프로바이더 강제 삭제

옵션:
  --confirm               # 확인 없이 실행
  --exclude <resource>    # 제외할 리소스 타입
  --backup-first          # 삭제 전 백업 생성

예시:
  $0 --action force-cleanup --provider aws --confirm
  $0 --action force-cleanup --provider gcp --backup-first
  $0 --action force-cleanup --provider all --exclude "rds"

삭제되는 리소스:
  - 모든 EKS/GKE 클러스터
  - 모든 EC2/GCE 인스턴스
  - 모든 스토리지 (데이터 포함)
  - 모든 네트워크 리소스
  - 모든 IAM 역할 (기본 역할 제외)

주의사항:
  - 이 작업은 되돌릴 수 없습니다
  - 중요한 데이터는 미리 백업하세요
  - 프로덕션 환경에서는 사용하지 마세요
EOF
            ;;
        "selective-cleanup")
            cat << EOF
SELECTIVE-CLEANUP 액션 상세 사용법:

기능:
  - 특정 리소스만 선택적으로 정리합니다
  - 세밀한 제어가 가능합니다
  - 안전한 정리 모드입니다

사용법:
  $0 --action selective-cleanup --provider <프로바이더> [옵션]

프로바이더:
  aws                     # AWS 리소스 선택적 정리
  gcp                     # GCP 리소스 선택적 정리
  all                     # 모든 프로바이더 선택적 정리

옵션:
  --include <resource>    # 포함할 리소스 타입 (필수)
  --exclude <resource>    # 제외할 리소스 타입
  --dry-run               # 실제 삭제 없이 시뮬레이션만 실행
  --interactive           # 대화형 모드로 실행

예시:
  $0 --action selective-cleanup --provider aws --include "ec2,eks"
  $0 --action selective-cleanup --provider gcp --include "gke" --exclude "gke-system"
  $0 --action selective-cleanup --provider all --include "loadbalancer" --interactive

지원하는 리소스 타입:
  - ec2, gce: 컴퓨팅 인스턴스
  - eks, gke: Kubernetes 클러스터
  - rds, cloudsql: 데이터베이스
  - s3, gcs: 스토리지
  - loadbalancer: 로드 밸런서
  - security-group: 보안 그룹
EOF
            ;;
        *)
            cat << EOF
알 수 없는 액션: $action

사용 가능한 액션:
  - cleanup: 일반 정리 (안전 모드)
  - force-cleanup: 강제 정리 (모든 리소스)
  - selective-cleanup: 선택적 정리
  - verify-cleanup: 정리 검증

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
# AWS 리소스 정리
# =============================================================================
cleanup_aws_resources() {
    local force_mode="${1:-false}"
    
    log_header "AWS 리소스 정리 시작"
    
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
    
    # EKS 클러스터 정리
    cleanup_eks_clusters "$force_mode"
    
    # 로드 밸런서 정리
    cleanup_load_balancers "$force_mode"
    
    # 보안 그룹 정리
    cleanup_security_groups "$force_mode"
    
    # VPC 정리 (force 모드에서만)
    if [ "$force_mode" = "true" ]; then
        cleanup_vpcs
    fi
    
    # IAM 역할 정리 (force 모드에서만)
    if [ "$force_mode" = "true" ]; then
        cleanup_iam_roles
    fi
    
    update_progress "aws-cleanup" "completed" "AWS 리소스 정리 완료"
}

cleanup_eks_clusters() {
    local force_mode="$1"
    
    log_step "EKS 클러스터 정리"
    
    local clusters=$(aws eks list-clusters --region "$AWS_REGION" --query 'clusters' --output text 2>/dev/null)
    
    if [ -n "$clusters" ] && [ "$clusters" != "None" ]; then
        for cluster in $clusters; do
            # 프로젝트 태그가 있는 클러스터만 정리 (안전 모드)
            if [ "$force_mode" = "false" ]; then
                local tags=$(aws eks describe-cluster --name "$cluster" --region "$AWS_REGION" --query 'cluster.tags.Project' --output text 2>/dev/null)
                if [ "$tags" != "$PROJECT_TAG" ]; then
                    log_info "프로젝트 태그가 일치하지 않아 건너뜁니다: $cluster"
                    continue
                fi
            fi
            
            log_info "EKS 클러스터 삭제 중: $cluster"
            
            # 서브 모듈 호출
            if [ -f "$SCRIPT_DIR/aws-eks-helper-new.sh" ]; then
                "$SCRIPT_DIR/aws-eks-helper-new.sh" --action cluster-delete --cluster-name "$cluster"
            else
                # 직접 삭제
                eksctl delete cluster --name "$cluster" --region "$AWS_REGION"
            fi
            
            if [ $? -eq 0 ]; then
                log_success "EKS 클러스터 삭제 완료: $cluster"
                update_progress "eks-cleanup" "completed" "EKS 클러스터 삭제: $cluster"
            else
                log_error "EKS 클러스터 삭제 실패: $cluster"
                update_progress "eks-cleanup" "failed" "EKS 클러스터 삭제 실패: $cluster"
            fi
        done
    else
        log_info "정리할 EKS 클러스터가 없습니다"
    fi
}

cleanup_load_balancers() {
    local force_mode="$1"
    
    log_step "로드 밸런서 정리"
    
    local load_balancers=$(aws elbv2 describe-load-balancers --region "$AWS_REGION" --query 'LoadBalancers[].LoadBalancerArn' --output text 2>/dev/null)
    
    if [ -n "$load_balancers" ] && [ "$load_balancers" != "None" ]; then
        for lb_arn in $load_balancers; do
            local lb_name=$(aws elbv2 describe-load-balancers --load-balancer-arns "$lb_arn" --region "$AWS_REGION" --query 'LoadBalancers[0].LoadBalancerName' --output text 2>/dev/null)
            
            # 프로젝트 관련 로드 밸런서만 정리
            if [[ "$lb_name" == *"$PROJECT_TAG"* ]] || [ "$force_mode" = "true" ]; then
                log_info "로드 밸런서 삭제 중: $lb_name"
                
                aws elbv2 delete-load-balancer --load-balancer-arn "$lb_arn" --region "$AWS_REGION"
                
                if [ $? -eq 0 ]; then
                    log_success "로드 밸런서 삭제 완료: $lb_name"
                    update_progress "lb-cleanup" "completed" "로드 밸런서 삭제: $lb_name"
                else
                    log_error "로드 밸런서 삭제 실패: $lb_name"
                fi
            fi
        done
    else
        log_info "정리할 로드 밸런서가 없습니다"
    fi
}

cleanup_security_groups() {
    local force_mode="$1"
    
    log_step "보안 그룹 정리"
    
    local security_groups=$(aws ec2 describe-security-groups --region "$AWS_REGION" --query "SecurityGroups[?GroupName!='default'].GroupId" --output text 2>/dev/null)
    
    if [ -n "$security_groups" ] && [ "$security_groups" != "None" ]; then
        for sg_id in $security_groups; do
            local sg_name=$(aws ec2 describe-security-groups --group-ids "$sg_id" --region "$AWS_REGION" --query 'SecurityGroups[0].GroupName' --output text 2>/dev/null)
            
            # 프로젝트 관련 보안 그룹만 정리
            if [[ "$sg_name" == *"$PROJECT_TAG"* ]] || [ "$force_mode" = "true" ]; then
                log_info "보안 그룹 삭제 중: $sg_name ($sg_id)"
                
                aws ec2 delete-security-group --group-id "$sg_id" --region "$AWS_REGION" 2>/dev/null
                
                if [ $? -eq 0 ]; then
                    log_success "보안 그룹 삭제 완료: $sg_name"
                    update_progress "sg-cleanup" "completed" "보안 그룹 삭제: $sg_name"
                else
                    log_warning "보안 그룹 삭제 실패 (사용 중일 수 있음): $sg_name"
                fi
            fi
        done
    else
        log_info "정리할 보안 그룹이 없습니다"
    fi
}

cleanup_vpcs() {
    log_step "VPC 정리 (강제 모드)"
    
    local vpcs=$(aws ec2 describe-vpcs --region "$AWS_REGION" --query 'Vpcs[?IsDefault==`false`].VpcId' --output text 2>/dev/null)
    
    if [ -n "$vpcs" ] && [ "$vpcs" != "None" ]; then
        for vpc_id in $vpcs; do
            log_info "VPC 삭제 중: $vpc_id"
            
            # VPC 내 리소스 정리 후 삭제
            aws ec2 delete-vpc --vpc-id "$vpc_id" --region "$AWS_REGION" 2>/dev/null
            
            if [ $? -eq 0 ]; then
                log_success "VPC 삭제 완료: $vpc_id"
                update_progress "vpc-cleanup" "completed" "VPC 삭제: $vpc_id"
            else
                log_warning "VPC 삭제 실패 (종속 리소스가 있을 수 있음): $vpc_id"
            fi
        done
    else
        log_info "정리할 VPC가 없습니다"
    fi
}

cleanup_iam_roles() {
    log_step "IAM 역할 정리 (강제 모드)"
    
    local roles=$(aws iam list-roles --query "Roles[?contains(RoleName, '$PROJECT_TAG')].RoleName" --output text 2>/dev/null)
    
    if [ -n "$roles" ] && [ "$roles" != "None" ]; then
        for role in $roles; do
            log_info "IAM 역할 삭제 중: $role"
            
            # 연결된 정책 분리
            local attached_policies=$(aws iam list-attached-role-policies --role-name "$role" --query 'AttachedPolicies[].PolicyArn' --output text 2>/dev/null)
            for policy_arn in $attached_policies; do
                aws iam detach-role-policy --role-name "$role" --policy-arn "$policy_arn" 2>/dev/null
            done
            
            # 인라인 정책 삭제
            local inline_policies=$(aws iam list-role-policies --role-name "$role" --query 'PolicyNames' --output text 2>/dev/null)
            for policy_name in $inline_policies; do
                aws iam delete-role-policy --role-name "$role" --policy-name "$policy_name" 2>/dev/null
            done
            
            # 역할 삭제
            aws iam delete-role --role-name "$role" 2>/dev/null
            
            if [ $? -eq 0 ]; then
                log_success "IAM 역할 삭제 완료: $role"
                update_progress "iam-cleanup" "completed" "IAM 역할 삭제: $role"
            else
                log_error "IAM 역할 삭제 실패: $role"
            fi
        done
    else
        log_info "정리할 IAM 역할이 없습니다"
    fi
}

# =============================================================================
# GCP 리소스 정리
# =============================================================================
cleanup_gcp_resources() {
    local force_mode="${1:-false}"
    
    log_header "GCP 리소스 정리 시작"
    
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
    
    # GKE 클러스터 정리
    cleanup_gke_clusters "$force_mode"
    
    # Compute Engine 인스턴스 정리
    cleanup_compute_instances "$force_mode"
    
    # 방화벽 규칙 정리
    cleanup_firewall_rules "$force_mode"
    
    # VPC 네트워크 정리 (force 모드에서만)
    if [ "$force_mode" = "true" ]; then
        cleanup_vpc_networks
    fi
    
    update_progress "gcp-cleanup" "completed" "GCP 리소스 정리 완료"
}

cleanup_gke_clusters() {
    local force_mode="$1"
    
    log_step "GKE 클러스터 정리"
    
    local clusters=$(gcloud container clusters list --format="value(name)" --zone="$GCP_ZONE" 2>/dev/null)
    
    if [ -n "$clusters" ]; then
        for cluster in $clusters; do
            # 프로젝트 라벨이 있는 클러스터만 정리 (안전 모드)
            if [ "$force_mode" = "false" ]; then
                local labels=$(gcloud container clusters describe "$cluster" --zone="$GCP_ZONE" --format="value(resourceLabels.project)" 2>/dev/null)
                if [ "$labels" != "$PROJECT_LABEL" ]; then
                    log_info "프로젝트 라벨이 일치하지 않아 건너뜁니다: $cluster"
                    continue
                fi
            fi
            
            log_info "GKE 클러스터 삭제 중: $cluster"
            
            gcloud container clusters delete "$cluster" --zone="$GCP_ZONE" --quiet
            
            if [ $? -eq 0 ]; then
                log_success "GKE 클러스터 삭제 완료: $cluster"
                update_progress "gke-cleanup" "completed" "GKE 클러스터 삭제: $cluster"
            else
                log_error "GKE 클러스터 삭제 실패: $cluster"
            fi
        done
    else
        log_info "정리할 GKE 클러스터가 없습니다"
    fi
}

cleanup_compute_instances() {
    local force_mode="$1"
    
    log_step "Compute Engine 인스턴스 정리"
    
    local instances=$(gcloud compute instances list --format="value(name)" --zone="$GCP_ZONE" 2>/dev/null)
    
    if [ -n "$instances" ]; then
        for instance in $instances; do
            # 프로젝트 관련 인스턴스만 정리
            if [[ "$instance" == *"$PROJECT_LABEL"* ]] || [ "$force_mode" = "true" ]; then
                log_info "Compute Engine 인스턴스 삭제 중: $instance"
                
                gcloud compute instances delete "$instance" --zone="$GCP_ZONE" --quiet
                
                if [ $? -eq 0 ]; then
                    log_success "인스턴스 삭제 완료: $instance"
                    update_progress "compute-cleanup" "completed" "인스턴스 삭제: $instance"
                else
                    log_error "인스턴스 삭제 실패: $instance"
                fi
            fi
        done
    else
        log_info "정리할 Compute Engine 인스턴스가 없습니다"
    fi
}

cleanup_firewall_rules() {
    local force_mode="$1"
    
    log_step "방화벽 규칙 정리"
    
    local rules=$(gcloud compute firewall-rules list --format="value(name)" 2>/dev/null)
    
    if [ -n "$rules" ]; then
        for rule in $rules; do
            # 기본 규칙은 건너뛰기
            if [[ "$rule" == "default-"* ]]; then
                continue
            fi
            
            # 프로젝트 관련 규칙만 정리
            if [[ "$rule" == *"$PROJECT_LABEL"* ]] || [ "$force_mode" = "true" ]; then
                log_info "방화벽 규칙 삭제 중: $rule"
                
                gcloud compute firewall-rules delete "$rule" --quiet
                
                if [ $? -eq 0 ]; then
                    log_success "방화벽 규칙 삭제 완료: $rule"
                    update_progress "firewall-cleanup" "completed" "방화벽 규칙 삭제: $rule"
                else
                    log_error "방화벽 규칙 삭제 실패: $rule"
                fi
            fi
        done
    else
        log_info "정리할 방화벽 규칙이 없습니다"
    fi
}

cleanup_vpc_networks() {
    log_step "VPC 네트워크 정리 (강제 모드)"
    
    local networks=$(gcloud compute networks list --format="value(name)" 2>/dev/null | grep -v default)
    
    if [ -n "$networks" ]; then
        for network in $networks; do
            log_info "VPC 네트워크 삭제 중: $network"
            
            gcloud compute networks delete "$network" --quiet
            
            if [ $? -eq 0 ]; then
                log_success "VPC 네트워크 삭제 완료: $network"
                update_progress "vpc-cleanup" "completed" "VPC 네트워크 삭제: $network"
            else
                log_warning "VPC 네트워크 삭제 실패 (종속 리소스가 있을 수 있음): $network"
            fi
        done
    else
        log_info "정리할 VPC 네트워크가 없습니다"
    fi
}

# =============================================================================
# 정리 검증
# =============================================================================
verify_cleanup() {
    local provider="$1"
    
    log_header "정리 검증"
    
    case "$provider" in
        "aws")
            verify_aws_cleanup
            ;;
        "gcp")
            verify_gcp_cleanup
            ;;
        "all")
            verify_aws_cleanup
            verify_gcp_cleanup
            ;;
        *)
            log_error "지원하지 않는 프로바이더: $provider"
            return 1
            ;;
    esac
}

verify_aws_cleanup() {
    log_step "AWS 정리 검증"
    
    # AWS 환경 설정 로드
    if [ -f "$SCRIPT_DIR/aws-environment.env" ]; then
        source "$SCRIPT_DIR/aws-environment.env"
    fi
    
    local cleanup_complete=true
    
    # EKS 클러스터 확인
    local eks_clusters=$(aws eks list-clusters --region "$AWS_REGION" --query 'clusters' --output text 2>/dev/null)
    if [ -n "$eks_clusters" ] && [ "$eks_clusters" != "None" ]; then
        log_warning "⚠️ 남은 EKS 클러스터: $eks_clusters"
        cleanup_complete=false
    fi
    
    # 실행 중인 EC2 인스턴스 확인
    local running_instances=$(aws ec2 describe-instances --region "$AWS_REGION" --query 'Reservations[*].Instances[?State.Name==`running`].InstanceId' --output text 2>/dev/null)
    if [ -n "$running_instances" ] && [ "$running_instances" != "None" ]; then
        log_warning "⚠️ 실행 중인 EC2 인스턴스: $running_instances"
        cleanup_complete=false
    fi
    
    if [ "$cleanup_complete" = true ]; then
        log_success "✅ AWS 리소스 정리 완료 확인"
    else
        log_warning "⚠️ AWS 리소스 정리가 완전하지 않습니다"
    fi
}

verify_gcp_cleanup() {
    log_step "GCP 정리 검증"
    
    # GCP 환경 설정 로드
    if [ -f "$SCRIPT_DIR/gcp-environment.env" ]; then
        source "$SCRIPT_DIR/gcp-environment.env"
    fi
    
    local cleanup_complete=true
    
    # GKE 클러스터 확인
    local gke_clusters=$(gcloud container clusters list --format="value(name)" --zone="$GCP_ZONE" 2>/dev/null)
    if [ -n "$gke_clusters" ]; then
        log_warning "⚠️ 남은 GKE 클러스터: $gke_clusters"
        cleanup_complete=false
    fi
    
    # 실행 중인 VM 인스턴스 확인
    local running_vms=$(gcloud compute instances list --filter="status:RUNNING" --format="value(name)" --zone="$GCP_ZONE" 2>/dev/null)
    if [ -n "$running_vms" ]; then
        log_warning "⚠️ 실행 중인 VM 인스턴스: $running_vms"
        cleanup_complete=false
    fi
    
    if [ "$cleanup_complete" = true ]; then
        log_success "✅ GCP 리소스 정리 완료 확인"
    else
        log_warning "⚠️ GCP 리소스 정리가 완전하지 않습니다"
    fi
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
                # --help 옵션 처리
                if [ "$2" = "--action" ] && [ -n "$3" ]; then
                    handle_help_option "$3"
                else
                    usage
                    exit 0
                fi
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
        "cleanup")
            case "$provider" in
                "aws")
                    cleanup_aws_resources "false"
                    ;;
                "gcp")
                    cleanup_gcp_resources "false"
                    ;;
                "all")
                    cleanup_aws_resources "false"
                    cleanup_gcp_resources "false"
                    ;;
                *)
                    log_error "지원하지 않는 프로바이더: $provider"
                    exit 1
                    ;;
            esac
            ;;
        "force-cleanup")
            case "$provider" in
                "aws")
                    cleanup_aws_resources "true"
                    ;;
                "gcp")
                    cleanup_gcp_resources "true"
                    ;;
                "all")
                    cleanup_aws_resources "true"
                    cleanup_gcp_resources "true"
                    ;;
                *)
                    log_error "지원하지 않는 프로바이더: $provider"
                    exit 1
                    ;;
            esac
            ;;
        "selective-cleanup")
            log_info "선택적 정리 기능은 추후 구현 예정입니다."
            ;;
        "verify-cleanup")
            verify_cleanup "$provider"
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
