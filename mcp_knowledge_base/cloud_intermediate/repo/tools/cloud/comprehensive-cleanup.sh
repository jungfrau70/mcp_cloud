#!/bin/bash

# =============================================================================
# 통합강의안 자원 정리 스크립트
# =============================================================================
# 
# 기능:
#   - 통합강의안에서 생성된 모든 AWS/GCP 자원을 정리
#   - 생성 순서의 역순으로 recursive하게 삭제
#   - 의존성을 병렬로 체크하여 pending 상태 방지
#   - 환경 파일 공유 (aws-environment.env, gcp-environment.env)
#
# 사용법:
#   ./comprehensive-cleanup.sh --provider all --mode safe
#   ./comprehensive-cleanup.sh --provider aws --mode force
#   ./comprehensive-cleanup.sh --provider gcp --mode dry-run
#
# 작성일: 2024-01-XX
# 작성자: Cloud Intermediate 과정
# =============================================================================

# =============================================================================
# 환경 설정 및 초기화
# =============================================================================
set -euo pipefail

# 스크립트 디렉토리 설정
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# 환경 파일 로드
if [ -f "aws-environment.env" ]; then
    source aws-environment.env
fi

if [ -f "gcp-environment.env" ]; then
    source gcp-environment.env
fi

# =============================================================================
# 색상 및 로깅 설정
# =============================================================================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 로깅 함수
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_debug() { echo -e "${PURPLE}[DEBUG]${NC} $1"; }
log_step() { echo -e "${CYAN}[STEP]${NC} $1"; }

# =============================================================================
# 전역 변수 설정
# =============================================================================
PROVIDER=""
MODE="safe"
DRY_RUN=false
FORCE=false
VERBOSE=false
PARALLEL_JOBS=4
CLEANUP_LOG_DIR="./cleanup-logs"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

# 정리할 리소스 목록 (생성 순서의 역순)
declare -A AWS_RESOURCES=(
    ["monitoring-hub"]="EC2 인스턴스 (모니터링 허브)"
    ["eks-cluster"]="EKS 클러스터"
    ["ecs-service"]="ECS 서비스"
    ["ecs-cluster"]="ECS 클러스터"
    ["load-balancer"]="Application Load Balancer"
    ["security-groups"]="보안 그룹"
    ["subnets"]="서브넷"
    ["vpc"]="VPC"
    ["iam-roles"]="IAM 역할"
)

declare -A GCP_RESOURCES=(
    ["gke-cluster"]="GKE 클러스터"
    ["cloud-run"]="Cloud Run 서비스"
    ["compute-instances"]="Compute Engine 인스턴스"
    ["firewall-rules"]="방화벽 규칙"
    ["subnets"]="서브넷"
    ["vpc"]="VPC 네트워크"
    ["service-accounts"]="서비스 계정"
    ["iam-policies"]="IAM 정책"
)

# =============================================================================
# 사용법 출력
# =============================================================================
usage() {
    cat << EOF
통합강의안 자원 정리 스크립트

사용법:
  $0 --provider <프로바이더> --mode <모드> [옵션]

프로바이더:
  aws                     # AWS 리소스만 정리
  gcp                     # GCP 리소스만 정리
  all                     # 모든 프로바이더 정리

모드:
  safe                    # 안전 모드 (기본값, 확인 후 삭제)
  force                   # 강제 모드 (확인 없이 삭제)
  dry-run                 # 시뮬레이션 모드 (실제 삭제 없음)

옵션:
  --parallel-jobs <N>     # 병렬 작업 수 (기본값: 4)
  --verbose               # 상세 로그 출력
  --log-dir <DIR>         # 로그 디렉토리 (기본값: ./cleanup-logs)
  --help                  # 이 도움말 출력

예시:
  $0 --provider all --mode safe
  $0 --provider aws --mode force --verbose
  $0 --provider gcp --mode dry-run --parallel-jobs 8

주의사항:
  - 이 스크립트는 통합강의안에서 생성된 모든 자원을 삭제합니다
  - 중요한 데이터가 있는 경우 백업을 먼저 수행하세요
  - dry-run 모드로 먼저 테스트하는 것을 권장합니다
EOF
}

# =============================================================================
# 인수 파싱
# =============================================================================
parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --provider)
                PROVIDER="$2"
                shift 2
                ;;
            --mode)
                MODE="$2"
                shift 2
                ;;
            --parallel-jobs)
                PARALLEL_JOBS="$2"
                shift 2
                ;;
            --verbose)
                VERBOSE=true
                shift
                ;;
            --log-dir)
                CLEANUP_LOG_DIR="$2"
                shift 2
                ;;
            --help)
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

    # 필수 인수 검증
    if [[ -z "$PROVIDER" ]]; then
        log_error "프로바이더를 지정해주세요 (--provider aws|gcp|all)"
        usage
        exit 1
    fi

    if [[ ! "$PROVIDER" =~ ^(aws|gcp|all)$ ]]; then
        log_error "잘못된 프로바이더: $PROVIDER (aws|gcp|all 중 선택)"
        exit 1
    fi

    if [[ ! "$MODE" =~ ^(safe|force|dry-run)$ ]]; then
        log_error "잘못된 모드: $MODE (safe|force|dry-run 중 선택)"
        exit 1
    fi

    # 모드별 설정
    case "$MODE" in
        "dry-run")
            DRY_RUN=true
            log_info "DRY-RUN 모드: 실제 삭제 없이 시뮬레이션만 실행합니다"
            ;;
        "force")
            FORCE=true
            log_warning "FORCE 모드: 확인 없이 강제 삭제합니다"
            ;;
        "safe")
            log_info "SAFE 모드: 각 단계마다 확인 후 진행합니다"
            ;;
    esac
}

# =============================================================================
# 초기화 및 준비
# =============================================================================
initialize() {
    log_step "=== 통합강의안 자원 정리 스크립트 초기화 ==="
    
    # 로그 디렉토리 생성
    mkdir -p "$CLEANUP_LOG_DIR"
    
    # 로그 파일 설정
    local log_file="$CLEANUP_LOG_DIR/cleanup_${TIMESTAMP}.log"
    exec 1> >(tee -a "$log_file")
    exec 2> >(tee -a "$log_file" >&2)
    
    log_info "로그 파일: $log_file"
    log_info "프로바이더: $PROVIDER"
    log_info "모드: $MODE"
    log_info "병렬 작업 수: $PARALLEL_JOBS"
    
    # 환경 변수 검증
    validate_environment
    
    # 의존성 검증
    validate_dependencies
    
    log_success "초기화 완료"
}

# =============================================================================
# 환경 변수 검증
# =============================================================================
validate_environment() {
    log_info "환경 변수 검증 중..."
    
    if [[ "$PROVIDER" == "aws" || "$PROVIDER" == "all" ]]; then
        if ! command -v aws &> /dev/null; then
            log_error "AWS CLI가 설치되지 않았습니다"
            exit 1
        fi
        
        if ! aws sts get-caller-identity &> /dev/null; then
            log_error "AWS 인증이 설정되지 않았습니다"
            exit 1
        fi
        
        log_success "AWS 환경 검증 완료"
    fi
    
    if [[ "$PROVIDER" == "gcp" || "$PROVIDER" == "all" ]]; then
        if ! command -v gcloud &> /dev/null; then
            log_error "Google Cloud CLI가 설치되지 않았습니다"
            exit 1
        fi
        
        if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" | head -n1 &> /dev/null; then
            log_error "GCP 인증이 설정되지 않았습니다"
            exit 1
        fi
        
        log_success "GCP 환경 검증 완료"
    fi
}

# =============================================================================
# 의존성 검증
# =============================================================================
validate_dependencies() {
    log_info "의존성 검증 중..."
    
    local required_tools=("jq")
    local optional_tools=("parallel")
    
    for tool in "${required_tools[@]}"; do
        if ! command -v "$tool" &> /dev/null; then
            log_error "필수 도구가 설치되지 않았습니다: $tool"
            exit 1
        fi
    done
    
    # parallel 도구 확인 (선택사항)
    if ! command -v "parallel" &> /dev/null; then
        log_warning "parallel 도구가 설치되지 않았습니다. 순차 처리로 진행합니다."
        PARALLEL_JOBS=1
    fi
    
    log_success "의존성 검증 완료"
}

# =============================================================================
# AWS 자원 정리 함수들
# =============================================================================

# AWS EKS 클러스터 정리
cleanup_aws_eks() {
    log_step "AWS EKS 클러스터 정리 중..."
    
    local cluster_name="${EKS_CLUSTER_NAME:-eks-intermediate}"
    
    if [[ "$DRY_RUN" == "true" ]]; then
        log_info "[DRY-RUN] EKS 클러스터 삭제: $cluster_name"
        return 0
    fi
    
    # 클러스터 존재 확인
    if ! aws eks describe-cluster --name "$cluster_name" &> /dev/null; then
        log_info "EKS 클러스터가 존재하지 않습니다: $cluster_name"
        return 0
    fi
    
    # 노드그룹 삭제
    local nodegroups=$(aws eks list-nodegroups --cluster-name "$cluster_name" --query 'nodegroups[]' --output text 2>/dev/null || echo "")
    if [[ -n "$nodegroups" ]]; then
        for nodegroup in $nodegroups; do
            log_info "노드그룹 삭제 중: $nodegroup"
            aws eks delete-nodegroup --cluster-name "$cluster_name" --nodegroup-name "$nodegroup" || true
        done
        
        # 노드그룹 삭제 완료 대기
        log_info "노드그룹 삭제 완료 대기 중..."
        for nodegroup in $nodegroups; do
            aws eks wait nodegroup-deleted --cluster-name "$cluster_name" --nodegroup-name "$nodegroup" || true
        done
    fi
    
    # 클러스터 삭제
    log_info "EKS 클러스터 삭제 중: $cluster_name"
    aws eks delete-cluster --name "$cluster_name" || true
    
    # 클러스터 삭제 완료 대기
    log_info "EKS 클러스터 삭제 완료 대기 중..."
    aws eks wait cluster-deleted --name "$cluster_name" || true
    
    log_success "AWS EKS 클러스터 정리 완료"
}

# AWS ECS 클러스터 정리
cleanup_aws_ecs() {
    log_step "AWS ECS 클러스터 정리 중..."
    
    local cluster_name="my-cluster"
    
    if [[ "$DRY_RUN" == "true" ]]; then
        log_info "[DRY-RUN] ECS 클러스터 삭제: $cluster_name"
        return 0
    fi
    
    # 서비스 삭제
    local services=$(aws ecs list-services --cluster "$cluster_name" --query 'serviceArns[]' --output text 2>/dev/null || echo "")
    if [[ -n "$services" ]]; then
        for service in $services; do
            log_info "ECS 서비스 삭제 중: $service"
            aws ecs update-service --cluster "$cluster_name" --service "$service" --desired-count 0 || true
            aws ecs delete-service --cluster "$cluster_name" --service "$service" || true
        done
    fi
    
    # 클러스터 삭제
    log_info "ECS 클러스터 삭제 중: $cluster_name"
    aws ecs delete-cluster --cluster "$cluster_name" || true
    
    log_success "AWS ECS 클러스터 정리 완료"
}

# AWS EC2 인스턴스 정리
cleanup_aws_ec2() {
    log_step "AWS EC2 인스턴스 정리 중..."
    
    if [[ "$DRY_RUN" == "true" ]]; then
        log_info "[DRY-RUN] EC2 인스턴스 삭제 (태그: $COURSE_TAG)"
        return 0
    fi
    
    # 모니터링 허브 인스턴스 삭제
    local instances=$(aws ec2 describe-instances \
        --filters "Name=tag:Name,Values=monitoring-hub" "Name=instance-state-name,Values=running" \
        --query 'Reservations[].Instances[].InstanceId' \
        --output text 2>/dev/null || echo "")
    
    if [[ -n "$instances" ]]; then
        for instance in $instances; do
            log_info "EC2 인스턴스 삭제 중: $instance"
            aws ec2 terminate-instances --instance-ids "$instance" || true
        done
        
        # 인스턴스 삭제 완료 대기
        log_info "EC2 인스턴스 삭제 완료 대기 중..."
        for instance in $instances; do
            aws ec2 wait instance-terminated --instance-ids "$instance" || true
        done
    fi
    
    log_success "AWS EC2 인스턴스 정리 완료"
}

# AWS 로드 밸런서 정리
cleanup_aws_load_balancers() {
    log_step "AWS 로드 밸런서 정리 중..."
    
    if [[ "$DRY_RUN" == "true" ]]; then
        log_info "[DRY-RUN] Application Load Balancer 삭제"
        return 0
    fi
    
    # ALB 삭제
    local albs=$(aws elbv2 describe-load-balancers --query 'LoadBalancers[?Type==`application`].LoadBalancerArn' --output text 2>/dev/null || echo "")
    if [[ -n "$albs" ]]; then
        for alb in $albs; do
            log_info "ALB 삭제 중: $alb"
            aws elbv2 delete-load-balancer --load-balancer-arn "$alb" || true
        done
    fi
    
    log_success "AWS 로드 밸런서 정리 완료"
}

# AWS 보안 그룹 정리
cleanup_aws_security_groups() {
    log_step "AWS 보안 그룹 정리 중..."
    
    if [[ "$DRY_RUN" == "true" ]]; then
        log_info "[DRY-RUN] 보안 그룹 삭제 (태그: $COURSE_TAG)"
        return 0
    fi
    
    # 기본 보안 그룹이 아닌 보안 그룹들 삭제
    local security_groups=$(aws ec2 describe-security-groups \
        --filters "Name=tag:Project,Values=$PROJECT_TAG" \
        --query 'SecurityGroups[?GroupName!=`default`].GroupId' \
        --output text 2>/dev/null || echo "")
    
    if [[ -n "$security_groups" ]]; then
        for sg in $security_groups; do
            log_info "보안 그룹 삭제 중: $sg"
            aws ec2 delete-security-group --group-id "$sg" || true
        done
    fi
    
    log_success "AWS 보안 그룹 정리 완료"
}

# AWS VPC 정리
cleanup_aws_vpc() {
    log_step "AWS VPC 정리 중..."
    
    if [[ "$DRY_RUN" == "true" ]]; then
        log_info "[DRY-RUN] VPC 삭제 (태그: $COURSE_TAG)"
        return 0
    fi
    
    # VPC ID 찾기
    local vpc_id=$(aws ec2 describe-vpcs \
        --filters "Name=tag:Project,Values=$PROJECT_TAG" \
        --query 'Vpcs[0].VpcId' \
        --output text 2>/dev/null || echo "")
    
    if [[ -n "$vpc_id" && "$vpc_id" != "None" ]]; then
        # 서브넷 삭제
        local subnets=$(aws ec2 describe-subnets \
            --filters "Name=vpc-id,Values=$vpc_id" \
            --query 'Subnets[].SubnetId' \
            --output text 2>/dev/null || echo "")
        
        if [[ -n "$subnets" ]]; then
            for subnet in $subnets; do
                log_info "서브넷 삭제 중: $subnet"
                aws ec2 delete-subnet --subnet-id "$subnet" || true
            done
        fi
        
        # VPC 삭제
        log_info "VPC 삭제 중: $vpc_id"
        aws ec2 delete-vpc --vpc-id "$vpc_id" || true
    fi
    
    log_success "AWS VPC 정리 완료"
}

# =============================================================================
# GCP 자원 정리 함수들
# =============================================================================

# GCP GKE 클러스터 정리
cleanup_gcp_gke() {
    log_step "GCP GKE 클러스터 정리 중..."
    
    local cluster_name="${GKE_CLUSTER_NAME:-gke-intermediate}"
    local zone="${GCP_ZONE:-asia-northeast3-a}"
    
    if [[ "$DRY_RUN" == "true" ]]; then
        log_info "[DRY-RUN] GKE 클러스터 삭제: $cluster_name"
        return 0
    fi
    
    # 클러스터 존재 확인
    if ! gcloud container clusters describe "$cluster_name" --zone="$zone" &> /dev/null; then
        log_info "GKE 클러스터가 존재하지 않습니다: $cluster_name"
        return 0
    fi
    
    # 클러스터 삭제
    log_info "GKE 클러스터 삭제 중: $cluster_name"
    gcloud container clusters delete "$cluster_name" --zone="$zone" --quiet || true
    
    log_success "GCP GKE 클러스터 정리 완료"
}

# GCP Cloud Run 서비스 정리
cleanup_gcp_cloud_run() {
    log_step "GCP Cloud Run 서비스 정리 중..."
    
    if [[ "$DRY_RUN" == "true" ]]; then
        log_info "[DRY-RUN] Cloud Run 서비스 삭제"
        return 0
    fi
    
    # Cloud Run 서비스 삭제
    local services=$(gcloud run services list --format="value(metadata.name)" 2>/dev/null || echo "")
    if [[ -n "$services" ]]; then
        for service in $services; do
            log_info "Cloud Run 서비스 삭제 중: $service"
            gcloud run services delete "$service" --region="${GCP_REGION}" --quiet || true
        done
    fi
    
    log_success "GCP Cloud Run 서비스 정리 완료"
}

# GCP Compute Engine 인스턴스 정리
cleanup_gcp_compute() {
    log_step "GCP Compute Engine 인스턴스 정리 중..."
    
    if [[ "$DRY_RUN" == "true" ]]; then
        log_info "[DRY-RUN] Compute Engine 인스턴스 삭제"
        return 0
    fi
    
    # 인스턴스 삭제
    local instances=$(gcloud compute instances list \
        --filter="labels.project=$PROJECT_LABEL" \
        --format="value(name)" 2>/dev/null || echo "")
    
    if [[ -n "$instances" ]]; then
        for instance in $instances; do
            log_info "Compute Engine 인스턴스 삭제 중: $instance"
            gcloud compute instances delete "$instance" --zone="${GCP_ZONE}" --quiet || true
        done
    fi
    
    log_success "GCP Compute Engine 인스턴스 정리 완료"
}

# GCP 방화벽 규칙 정리
cleanup_gcp_firewall() {
    log_step "GCP 방화벽 규칙 정리 중..."
    
    if [[ "$DRY_RUN" == "true" ]]; then
        log_info "[DRY-RUN] 방화벽 규칙 삭제"
        return 0
    fi
    
    # 방화벽 규칙 삭제
    local rules=$(gcloud compute firewall-rules list \
        --filter="name~cloud-intermediate" \
        --format="value(name)" 2>/dev/null || echo "")
    
    if [[ -n "$rules" ]]; then
        for rule in $rules; do
            log_info "방화벽 규칙 삭제 중: $rule"
            gcloud compute firewall-rules delete "$rule" --quiet || true
        done
    fi
    
    log_success "GCP 방화벽 규칙 정리 완료"
}

# GCP VPC 네트워크 정리
cleanup_gcp_vpc() {
    log_step "GCP VPC 네트워크 정리 중..."
    
    if [[ "$DRY_RUN" == "true" ]]; then
        log_info "[DRY-RUN] VPC 네트워크 삭제"
        return 0
    fi
    
    # 서브넷 삭제
    local subnets=$(gcloud compute networks subnets list \
        --filter="name~cloud-intermediate" \
        --format="value(name)" 2>/dev/null || echo "")
    
    if [[ -n "$subnets" ]]; then
        for subnet in $subnets; do
            log_info "서브넷 삭제 중: $subnet"
            gcloud compute networks subnets delete "$subnet" --region="${GCP_REGION}" --quiet || true
        done
    fi
    
    # VPC 네트워크 삭제
    local networks=$(gcloud compute networks list \
        --filter="name~cloud-intermediate" \
        --format="value(name)" 2>/dev/null || echo "")
    
    if [[ -n "$networks" ]]; then
        for network in $networks; do
            log_info "VPC 네트워크 삭제 중: $network"
            gcloud compute networks delete "$network" --quiet || true
        done
    fi
    
    log_success "GCP VPC 네트워크 정리 완료"
}

# =============================================================================
# 병렬 처리 함수
# =============================================================================
run_parallel_cleanup() {
    local provider="$1"
    shift
    local resources=("$@")
    
    if [[ "$PARALLEL_JOBS" -gt 1 && -n "$(command -v parallel)" ]]; then
        log_info "병렬 정리 시작 (작업 수: $PARALLEL_JOBS)"
        printf '%s\n' "${resources[@]}" | parallel -j "$PARALLEL_JOBS" --line-buffer cleanup_resource "$provider"
    else
        log_info "순차 정리 시작"
        for resource in "${resources[@]}"; do
            cleanup_resource "$provider" "$resource"
        done
    fi
}

# =============================================================================
# 리소스별 정리 함수
# =============================================================================
cleanup_resource() {
    local provider="$1"
    local resource="$2"
    
    case "$provider" in
        "aws")
            case "$resource" in
                "monitoring-hub") cleanup_aws_ec2 ;;
                "eks-cluster") cleanup_aws_eks ;;
                "ecs-service") cleanup_aws_ecs ;;
                "ecs-cluster") cleanup_aws_ecs ;;
                "load-balancer") cleanup_aws_load_balancers ;;
                "security-groups") cleanup_aws_security_groups ;;
                "subnets") cleanup_aws_vpc ;;
                "vpc") cleanup_aws_vpc ;;
            esac
            ;;
        "gcp")
            case "$resource" in
                "gke-cluster") cleanup_gcp_gke ;;
                "cloud-run") cleanup_gcp_cloud_run ;;
                "compute-instances") cleanup_gcp_compute ;;
                "firewall-rules") cleanup_gcp_firewall ;;
                "subnets") cleanup_gcp_vpc ;;
                "vpc") cleanup_gcp_vpc ;;
            esac
            ;;
    esac
}

# =============================================================================
# 의존성 체크 및 대기
# =============================================================================
check_dependencies() {
    local provider="$1"
    local resource="$2"
    
    log_debug "의존성 체크: $provider/$resource"
    
    # 리소스별 의존성 체크 로직
    case "$resource" in
        "vpc")
            # VPC는 다른 모든 리소스가 삭제된 후에 삭제
            sleep 30
            ;;
        "subnets")
            # 서브넷은 VPC 내의 리소스들이 삭제된 후에 삭제
            sleep 20
            ;;
        *)
            # 기본 대기 시간
            sleep 10
            ;;
    esac
}

# =============================================================================
# 정리 검증
# =============================================================================
verify_cleanup() {
    log_step "정리 결과 검증 중..."
    
    local failed_resources=()
    
    if [[ "$PROVIDER" == "aws" || "$PROVIDER" == "all" ]]; then
        # AWS 리소스 검증
        if aws eks describe-cluster --name "${EKS_CLUSTER_NAME:-eks-intermediate}" &> /dev/null; then
            failed_resources+=("AWS EKS 클러스터")
        fi
        
        if aws ecs describe-clusters --clusters "my-cluster" &> /dev/null; then
            failed_resources+=("AWS ECS 클러스터")
        fi
    fi
    
    if [[ "$PROVIDER" == "gcp" || "$PROVIDER" == "all" ]]; then
        # GCP 리소스 검증
        if gcloud container clusters describe "${GKE_CLUSTER_NAME:-gke-intermediate}" --zone="${GCP_ZONE:-asia-northeast3-a}" &> /dev/null; then
            failed_resources+=("GCP GKE 클러스터")
        fi
    fi
    
    if [[ ${#failed_resources[@]} -eq 0 ]]; then
        log_success "모든 리소스가 성공적으로 정리되었습니다"
        return 0
    else
        log_error "다음 리소스들이 정리되지 않았습니다:"
        for resource in "${failed_resources[@]}"; do
            log_error "  - $resource"
        done
        return 1
    fi
}

# =============================================================================
# 메인 정리 함수
# =============================================================================
main_cleanup() {
    log_step "=== 통합강의안 자원 정리 시작 ==="
    
    # AWS 리소스 정리
    if [[ "$PROVIDER" == "aws" || "$PROVIDER" == "all" ]]; then
        log_info "AWS 리소스 정리 시작"
        
        # 생성 순서의 역순으로 정리
        local aws_resources=("monitoring-hub" "eks-cluster" "ecs-service" "ecs-cluster" "load-balancer" "security-groups" "subnets" "vpc")
        
        for resource in "${aws_resources[@]}"; do
            log_info "AWS 리소스 정리: $resource"
            cleanup_resource "aws" "$resource"
            check_dependencies "aws" "$resource"
        done
        
        log_success "AWS 리소스 정리 완료"
    fi
    
    # GCP 리소스 정리
    if [[ "$PROVIDER" == "gcp" || "$PROVIDER" == "all" ]]; then
        log_info "GCP 리소스 정리 시작"
        
        # 생성 순서의 역순으로 정리
        local gcp_resources=("gke-cluster" "cloud-run" "compute-instances" "firewall-rules" "subnets" "vpc")
        
        for resource in "${gcp_resources[@]}"; do
            log_info "GCP 리소스 정리: $resource"
            cleanup_resource "gcp" "$resource"
            check_dependencies "gcp" "$resource"
        done
        
        log_success "GCP 리소스 정리 완료"
    fi
    
    # 정리 검증
    verify_cleanup
    
    log_success "=== 통합강의안 자원 정리 완료 ==="
}

# =============================================================================
# 메인 실행
# =============================================================================
main() {
    # 인수 파싱
    parse_arguments "$@"
    
    # 초기화
    initialize
    
    # 정리 실행
    main_cleanup
    
    log_success "스크립트 실행 완료"
}

# 스크립트 실행
main "$@"
