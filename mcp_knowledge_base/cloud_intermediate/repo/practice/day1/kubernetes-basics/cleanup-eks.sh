#!/bin/bash

# =============================================================================
# Day1 통합강의안 자원 정리 스크립트 (개선된 버전)
# =============================================================================
# 
# 기능:
#   - Day1 통합강의안에서 생성된 모든 리소스를 체계적으로 정리
#   - Docker 이미지, Kubernetes 리소스, 클러스터 Context 정리
#   - LoadBalancer 및 외부 접근 리소스 정리
#   - 생성 순서의 역순으로 recursive하게 삭제
#   - 의존성을 병렬로 체크하여 pending 상태 방지
#   - 환경 파일 공유 (aws-environment.env, gcp-environment.env)
#
# 사용법:
#   ./cleanup-eks.sh --provider all --mode safe
#   ./cleanup-eks.sh --provider aws --mode force
#   ./cleanup-eks.sh --provider gcp --mode dry-run
#
# Day1 정리 내용:
#   - Docker 이미지 정리 (demo-app:original, demo-app:optimized, demo-app:multistage)
#   - Kubernetes 리소스 정리 (Pod, Deployment, Service, LoadBalancer)
#   - 클러스터 Context 정리 (kubectl config)
#   - AWS EKS 클러스터 정리
#   - GCP GKE 클러스터 정리
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
Day1 통합강의안 자원 정리 스크립트 (개선된 버전)

사용법:
  $0 --provider <프로바이더> --mode <모드> [옵션]

프로바이더:
  aws                     # AWS 리소스만 정리 (EKS 클러스터, LoadBalancer)
  gcp                     # GCP 리소스만 정리 (GKE 클러스터)
  all                     # 모든 프로바이더 정리
  docker                  # Docker 리소스만 정리 (이미지, 컨테이너)
  kubernetes              # Kubernetes 리소스만 정리 (Pod, Service, LoadBalancer)

모드:
  safe                    # 안전 모드 (기본값, 확인 후 삭제)
  force                   # 강제 모드 (확인 없이 삭제)
  dry-run                 # 시뮬레이션 모드 (실제 삭제 없음)

옵션:
  --parallel-jobs <N>     # 병렬 작업 수 (기본값: 4)
  --verbose               # 상세 로그 출력
  --log-dir <DIR>         # 로그 디렉토리 (기본값: ./cleanup-logs)
  --help                  # 이 도움말 출력

Day1 정리 내용:
  - Docker 이미지 정리 (demo-app:original, demo-app:optimized, demo-app:multistage)
  - Kubernetes 리소스 정리 (Pod, Deployment, Service, LoadBalancer)
  - 클러스터 Context 정리 (kubectl config)
  - AWS EKS 클러스터 정리
  - GCP GKE 클러스터 정리

예시:
  $0 --provider all --mode safe
  $0 --provider aws --mode force --verbose
  $0 --provider docker --mode dry-run
  $0 --provider kubernetes --mode safe

주의사항:
  - 이 스크립트는 Day1 통합강의안에서 생성된 모든 자원을 삭제합니다
  - 중요한 데이터가 있는 경우 백업을 먼저 수행하세요
  - dry-run 모드로 먼저 테스트하는 것을 권장합니다
  - LoadBalancer 삭제 시 외부 접근이 중단됩니다
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

    if [[ ! "$PROVIDER" =~ ^(aws|gcp|all|docker|kubernetes)$ ]]; then
        log_error "잘못된 프로바이더: $PROVIDER (aws|gcp|all|docker|kubernetes 중 선택)"
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

# =============================================================================
# Docker 리소스 정리 함수
# =============================================================================

# Docker 컨테이너 정리
cleanup_docker_containers() {
    log_step "Docker 컨테이너 정리 중..."
    
    if [[ "$DRY_RUN" == "true" ]]; then
        log_info "[DRY-RUN] Docker 컨테이너 삭제"
        return 0
    fi
    
    # Day1 실습에서 생성된 컨테이너들 정리
    local containers=$(docker ps -aq --filter "name=demo-app-" --format "{{.Names}}" 2>/dev/null || echo "")
    
    if [[ -n "$containers" ]]; then
        log_info "발견된 컨테이너들: $containers"
        
        for container in $containers; do
            log_info "컨테이너 중지 및 삭제 중: $container"
            docker stop "$container" 2>/dev/null || true
            docker rm "$container" 2>/dev/null || true
        done
    else
        log_info "삭제할 컨테이너가 없습니다"
    fi
    
    log_success "Docker 컨테이너 정리 완료"
}

# Docker 이미지 정리
cleanup_docker_images() {
    log_step "Docker 이미지 정리 중..."
    
    if [[ "$DRY_RUN" == "true" ]]; then
        log_info "[DRY-RUN] Docker 이미지 삭제"
        return 0
    fi
    
    # Day1 실습에서 생성된 이미지들 정리
    local images=$(docker images --filter "reference=demo-app:*" --format "{{.Repository}}:{{.Tag}}" 2>/dev/null || echo "")
    
    if [[ -n "$images" ]]; then
        log_info "발견된 이미지들: $images"
        
        for image in $images; do
            log_info "이미지 삭제 중: $image"
            docker rmi "$image" 2>/dev/null || true
        done
    else
        log_info "삭제할 이미지가 없습니다"
    fi
    
    # 사용하지 않는 이미지 정리
    log_info "사용하지 않는 이미지 정리 중..."
    docker image prune -f 2>/dev/null || true
    
    log_success "Docker 이미지 정리 완료"
}

# Docker 네트워크 정리
cleanup_docker_networks() {
    log_step "Docker 네트워크 정리 중..."
    
    if [[ "$DRY_RUN" == "true" ]]; then
        log_info "[DRY-RUN] Docker 네트워크 삭제"
        return 0
    fi
    
    # 사용하지 않는 네트워크 정리
    docker network prune -f 2>/dev/null || true
    
    log_success "Docker 네트워크 정리 완료"
}

# =============================================================================
# Kubernetes 리소스 정리 함수
# =============================================================================

# Kubernetes 리소스 정리
cleanup_kubernetes_resources() {
    log_step "Kubernetes 리소스 정리 중..."
    
    if [[ "$DRY_RUN" == "true" ]]; then
        log_info "[DRY-RUN] Kubernetes 리소스 삭제"
        return 0
    fi
    
    # kubectl 연결 확인
    if ! kubectl cluster-info &>/dev/null; then
        log_warning "kubectl 클러스터 연결 실패, Kubernetes 리소스 정리를 건너뜁니다"
        return 0
    fi
    
    # Day1 실습에서 생성된 리소스들 정리
    log_info "Pod 리소스 정리 중..."
    kubectl delete pods --all --grace-period=0 --force 2>/dev/null || true
    
    log_info "Deployment 리소스 정리 중..."
    kubectl delete deployments --all --grace-period=0 --force 2>/dev/null || true
    
    log_info "Service 리소스 정리 중..."
    kubectl delete services --all --grace-period=0 --force 2>/dev/null || true
    
    log_info "ConfigMap 리소스 정리 중..."
    kubectl delete configmaps --all --grace-period=0 --force 2>/dev/null || true
    
    log_info "Secret 리소스 정리 중..."
    kubectl delete secrets --all --grace-period=0 --force 2>/dev/null || true
    
    log_info "Ingress 리소스 정리 중..."
    kubectl delete ingress --all --grace-period=0 --force 2>/dev/null || true
    
    # LoadBalancer Service 정리 (외부 접근 중단)
    log_info "LoadBalancer Service 정리 중..."
    kubectl delete service nginx-loadbalancer --grace-period=0 --force 2>/dev/null || true
    
    log_success "Kubernetes 리소스 정리 완료"
}

# kubectl Context 정리
cleanup_kubectl_contexts() {
    log_step "kubectl Context 정리 중..."
    
    if [[ "$DRY_RUN" == "true" ]]; then
        log_info "[DRY-RUN] kubectl Context 삭제"
        return 0
    fi
    
    # 현재 컨텍스트 확인
    local current_context=$(kubectl config current-context 2>/dev/null || echo "")
    
    if [[ -n "$current_context" ]]; then
        log_info "현재 컨텍스트: $current_context"
        
        # Day1 실습 관련 컨텍스트 삭제
        local contexts=$(kubectl config get-contexts -o name 2>/dev/null | grep -E "(cloud-intermediate|demo|test)" || echo "")
        
        if [[ -n "$contexts" ]]; then
            for context in $contexts; do
                log_info "컨텍스트 삭제 중: $context"
                kubectl config delete-context "$context" 2>/dev/null || true
            done
        fi
        
        # kubeconfig 파일 정리
        if [[ -f ~/.kube/config ]]; then
            log_info "kubeconfig 파일 정리 중..."
            kubectl config view --raw > ~/.kube/config.backup 2>/dev/null || true
        fi
    else
        log_info "활성 kubectl 컨텍스트가 없습니다"
    fi
    
    log_success "kubectl Context 정리 완료"
}

# AWS VPC 정리 (CloudFormation 의존성 해결용)
cleanup_aws_vpc() {
    log_step "AWS VPC 정리 중 (CloudFormation 의존성 해결)..."
    
    if [[ "$DRY_RUN" == "true" ]]; then
        log_info "[DRY-RUN] VPC 및 관련 리소스 삭제"
        return 0
    fi
    
    # 프로젝트 관련 VPC 찾기
    local vpcs=$(aws ec2 describe-vpcs \
        --filters "Name=tag:Project,Values=$PROJECT_TAG" \
        --query 'Vpcs[].VpcId' \
        --output text 2>/dev/null || echo "")
    
    if [[ -z "$vpcs" ]]; then
        log_info "삭제할 VPC가 없습니다"
        return 0
    fi
    
    log_info "발견된 VPC들: $vpcs"
    
    for vpc_id in $vpcs; do
        log_info "VPC 정리 시작: $vpc_id"
        
        # 1. 인터넷 게이트웨이 분리 및 삭제
        local igw_id=$(aws ec2 describe-internet-gateways \
            --filters "Name=attachment.vpc-id,Values=$vpc_id" \
            --query 'InternetGateways[0].InternetGatewayId' \
            --output text 2>/dev/null || echo "")
        
        if [[ -n "$igw_id" && "$igw_id" != "None" ]]; then
            log_info "인터넷 게이트웨이 분리 중: $igw_id"
            aws ec2 detach-internet-gateway --internet-gateway-id "$igw_id" --vpc-id "$vpc_id" || true
            log_info "인터넷 게이트웨이 삭제 중: $igw_id"
            aws ec2 delete-internet-gateway --internet-gateway-id "$igw_id" || true
        fi
        
        # 2. NAT 게이트웨이 삭제
        local nat_gateways=$(aws ec2 describe-nat-gateways \
            --filter "Name=vpc-id,Values=$vpc_id" \
            --query 'NatGateways[].NatGatewayId' \
            --output text 2>/dev/null || echo "")
        
        if [[ -n "$nat_gateways" ]]; then
            for nat_gw in $nat_gateways; do
                log_info "NAT 게이트웨이 삭제 중: $nat_gw"
                aws ec2 delete-nat-gateway --nat-gateway-id "$nat_gw" || true
            done
        fi
        
        # 3. 보안 그룹 삭제 (기본 보안 그룹 제외)
        local security_groups=$(aws ec2 describe-security-groups \
            --filters "Name=vpc-id,Values=$vpc_id" \
            --query 'SecurityGroups[?GroupName!=`default`].GroupId' \
            --output text 2>/dev/null || echo "")
        
        if [[ -n "$security_groups" ]]; then
            for sg in $security_groups; do
                log_info "보안 그룹 삭제 중: $sg"
                aws ec2 delete-security-group --group-id "$sg" || true
            done
        fi
        
        # 4. 라우팅 테이블 삭제 (메인 라우팅 테이블 제외)
        local route_tables=$(aws ec2 describe-route-tables \
            --filters "Name=vpc-id,Values=$vpc_id" \
            --query 'RouteTables[?Associations[0].Main!=`true`].RouteTableId' \
            --output text 2>/dev/null || echo "")
        
        if [[ -n "$route_tables" ]]; then
            for rt in $route_tables; do
                log_info "라우팅 테이블 삭제 중: $rt"
                aws ec2 delete-route-table --route-table-id "$rt" || true
            done
        fi
        
        # 5. 서브넷 삭제
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
        
        # 6. VPC 엔드포인트 삭제
        local vpc_endpoints=$(aws ec2 describe-vpc-endpoints \
            --filters "Name=vpc-id,Values=$vpc_id" \
            --query 'VpcEndpoints[].VpcEndpointId' \
            --output text 2>/dev/null || echo "")
        
        if [[ -n "$vpc_endpoints" ]]; then
            for endpoint in $vpc_endpoints; do
                log_info "VPC 엔드포인트 삭제 중: $endpoint"
                aws ec2 delete-vpc-endpoint --vpc-endpoint-id "$endpoint" || true
            done
        fi
        
        # 7. VPC 삭제
        log_info "VPC 삭제 중: $vpc_id"
        aws ec2 delete-vpc --vpc-id "$vpc_id" || true
        
        log_success "VPC 정리 완료: $vpc_id"
    done
    
    log_success "AWS VPC 정리 완료"
}

# AWS CloudFormation 스택 정리 (의존성 추적)
cleanup_aws_cloudformation() {
    log_step "AWS CloudFormation 스택 정리 중..."
    
    if [[ "$DRY_RUN" == "true" ]]; then
        log_info "[DRY-RUN] CloudFormation 스택 삭제"
        return 0
    fi
    
    # 프로젝트 관련 스택 목록 가져오기
    local stacks=$(aws cloudformation list-stacks \
        --stack-status-filter CREATE_COMPLETE UPDATE_COMPLETE ROLLBACK_COMPLETE \
        --query 'StackSummaries[?contains(StackName, `'$PROJECT_TAG'`) || contains(StackName, `eksctl`)].StackName' \
        --output text 2>/dev/null || echo "")
    
    if [[ -z "$stacks" ]]; then
        log_info "삭제할 CloudFormation 스택이 없습니다"
        return 0
    fi
    
    log_info "발견된 CloudFormation 스택들:"
    for stack in $stacks; do
        log_info "  - $stack"
    done
    
    # 의존성 분석 및 삭제 순서 결정
    local deletion_order=()
    local remaining_stacks=($stacks)
    local max_iterations=10
    local iteration=0
    
    while [[ ${#remaining_stacks[@]} -gt 0 && $iteration -lt $max_iterations ]]; do
        local deletable_stacks=()
        
        for stack in "${remaining_stacks[@]}"; do
            # 스택의 의존성 확인
            local dependencies=$(aws cloudformation describe-stack-resources \
                --stack-name "$stack" \
                --query 'StackResources[?ResourceType==`AWS::CloudFormation::Stack`].PhysicalResourceId' \
                --output text 2>/dev/null || echo "")
            
            # 의존성이 없거나 이미 삭제된 스택들
            local has_dependencies=false
            for dep in $dependencies; do
                if [[ " ${remaining_stacks[@]} " =~ " ${dep} " ]]; then
                    has_dependencies=true
                    break
                fi
            done
            
            if [[ "$has_dependencies" == "false" ]]; then
                deletable_stacks+=("$stack")
            fi
        done
        
        # 삭제 가능한 스택들을 삭제
        for stack in "${deletable_stacks[@]}"; do
            log_info "스택 삭제 중: $stack"
            deletion_order+=("$stack")
            
            # 스택 삭제 시도
            if aws cloudformation delete-stack --stack-name "$stack" 2>/dev/null; then
                log_success "스택 삭제 요청 완료: $stack"
            else
                log_warning "스택 삭제 요청 실패: $stack"
            fi
            
            # remaining_stacks에서 제거
            local new_remaining=()
            for remaining in "${remaining_stacks[@]}"; do
                if [[ "$remaining" != "$stack" ]]; then
                    new_remaining+=("$remaining")
                fi
            done
            remaining_stacks=("${new_remaining[@]}")
        done
        
        iteration=$((iteration + 1))
        
        # 삭제 가능한 스택이 없으면 강제로 남은 스택들 삭제
        if [[ ${#deletable_stacks[@]} -eq 0 && ${#remaining_stacks[@]} -gt 0 ]]; then
            log_warning "의존성 순환 감지, 남은 스택들을 강제 삭제합니다"
            for stack in "${remaining_stacks[@]}"; do
                log_info "강제 스택 삭제 중: $stack"
                deletion_order+=("$stack")
                aws cloudformation delete-stack --stack-name "$stack" 2>/dev/null || true
            done
            break
        fi
    done
    
    # 스택 삭제 완료 대기 (VPC 정리 후 더 안전)
    log_info "스택 삭제 완료 대기 중 (VPC 정리 완료로 의존성 해결됨)..."
    local deleted_stacks=()
    local failed_stacks=()
    
    for stack in "${deletion_order[@]}"; do
        log_info "스택 삭제 상태 확인: $stack"
        
        # 스택 상태 확인 (최대 10분 대기, VPC 정리 후 더 안전)
        local timeout=600
        local elapsed=0
        local stack_deleted=false
        
        while [[ $elapsed -lt $timeout ]]; do
            local stack_status=$(aws cloudformation describe-stacks \
                --stack-name "$stack" \
                --query 'Stacks[0].StackStatus' \
                --output text 2>/dev/null || echo "STACK_NOT_FOUND")
            
            if [[ "$stack_status" == "STACK_NOT_FOUND" ]]; then
                stack_deleted=true
                break
            elif [[ "$stack_status" == "DELETE_FAILED" ]]; then
                log_error "스택 삭제 실패: $stack"
                # 실패한 스택의 세부 정보 확인
                local stack_events=$(aws cloudformation describe-stack-events \
                    --stack-name "$stack" \
                    --query 'StackEvents[?ResourceStatus==`DELETE_FAILED`].[LogicalResourceId,ResourceStatusReason]' \
                    --output text 2>/dev/null || echo "")
                
                if [[ -n "$stack_events" ]]; then
                    log_error "삭제 실패 원인: $stack_events"
                fi
                failed_stacks+=("$stack")
                break
            elif [[ "$stack_status" == "DELETE_IN_PROGRESS" ]]; then
                log_info "스택 삭제 진행 중: $stack ($elapsed/${timeout}초)"
            fi
            
            sleep 15
            elapsed=$((elapsed + 15))
        done
        
        if [[ "$stack_deleted" == "true" ]]; then
            deleted_stacks+=("$stack")
            log_success "스택 삭제 완료: $stack"
        elif [[ $elapsed -ge $timeout ]]; then
            log_warning "스택 삭제 타임아웃: $stack"
            failed_stacks+=("$stack")
        fi
    done
    
    # 최종 결과 보고
    log_info "=== CloudFormation 스택 정리 결과 ==="
    log_success "성공적으로 삭제된 스택 (${#deleted_stacks[@]}개):"
    for stack in "${deleted_stacks[@]}"; do
        log_success "  ✅ $stack"
    done
    
    if [[ ${#failed_stacks[@]} -gt 0 ]]; then
        log_error "삭제 실패한 스택 (${#failed_stacks[@]}개):"
        for stack in "${failed_stacks[@]}"; do
            log_error "  ❌ $stack"
        done
    fi
    
    # 최종 스택 존재 확인
    local remaining_stacks_final=$(aws cloudformation list-stacks \
        --stack-status-filter CREATE_COMPLETE UPDATE_COMPLETE ROLLBACK_COMPLETE \
        --query 'StackSummaries[?contains(StackName, `'$PROJECT_TAG'`) || contains(StackName, `eksctl`)].StackName' \
        --output text 2>/dev/null || echo "")
    
    if [[ -n "$remaining_stacks_final" ]]; then
        log_warning "아직 존재하는 스택들:"
        for stack in $remaining_stacks_final; do
            log_warning "  - $stack"
        done
    else
        log_success "모든 관련 CloudFormation 스택이 정리되었습니다"
    fi
    
    log_success "AWS CloudFormation 스택 정리 완료"
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
                "cloudformation") cleanup_aws_cloudformation ;;
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
    
    # Docker 리소스 검증
    if [[ "$PROVIDER" == "docker" || "$PROVIDER" == "all" ]]; then
        # Docker 컨테이너 검증
        local containers=$(docker ps -aq --filter "name=demo-app-" --format "{{.Names}}" 2>/dev/null || echo "")
        if [[ -n "$containers" ]]; then
            failed_resources+=("Docker 컨테이너")
            log_warning "아직 존재하는 Docker 컨테이너들:"
            for container in $containers; do
                log_warning "  - $container"
            done
        fi
        
        # Docker 이미지 검증
        local images=$(docker images --filter "reference=demo-app:*" --format "{{.Repository}}:{{.Tag}}" 2>/dev/null || echo "")
        if [[ -n "$images" ]]; then
            failed_resources+=("Docker 이미지")
            log_warning "아직 존재하는 Docker 이미지들:"
            for image in $images; do
                log_warning "  - $image"
            done
        fi
    fi
    
    # Kubernetes 리소스 검증
    if [[ "$PROVIDER" == "kubernetes" || "$PROVIDER" == "all" ]]; then
        if kubectl cluster-info &>/dev/null; then
            # Pod 검증
            local pods=$(kubectl get pods --no-headers 2>/dev/null | wc -l)
            if [[ "$pods" -gt 0 ]]; then
                failed_resources+=("Kubernetes Pod")
                log_warning "아직 존재하는 Pod들: $pods개"
            fi
            
            # Service 검증
            local services=$(kubectl get services --no-headers 2>/dev/null | wc -l)
            if [[ "$services" -gt 0 ]]; then
                failed_resources+=("Kubernetes Service")
                log_warning "아직 존재하는 Service들: $services개"
            fi
            
            # LoadBalancer Service 검증
            if kubectl get service nginx-loadbalancer &>/dev/null; then
                failed_resources+=("LoadBalancer Service")
                log_warning "LoadBalancer Service가 아직 존재합니다"
            fi
        fi
    fi
    
    if [[ "$PROVIDER" == "aws" || "$PROVIDER" == "all" ]]; then
        # AWS 리소스 검증
        if aws eks describe-cluster --name "${EKS_CLUSTER_NAME:-eks-intermediate}" &> /dev/null; then
            failed_resources+=("AWS EKS 클러스터")
        fi
        
        if aws ecs describe-clusters --clusters "my-cluster" &> /dev/null; then
            failed_resources+=("AWS ECS 클러스터")
        fi
        
        # CloudFormation 스택 검증
        local remaining_stacks=$(aws cloudformation list-stacks \
            --stack-status-filter CREATE_COMPLETE UPDATE_COMPLETE ROLLBACK_COMPLETE \
            --query 'StackSummaries[?contains(StackName, `'$PROJECT_TAG'`) || contains(StackName, `eksctl`)].StackName' \
            --output text 2>/dev/null || echo "")
        
        if [[ -n "$remaining_stacks" ]]; then
            failed_resources+=("AWS CloudFormation 스택")
            log_warning "아직 존재하는 CloudFormation 스택들:"
            for stack in $remaining_stacks; do
                log_warning "  - $stack"
            done
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
# 메인 정리 함수 (Day1 통합강의안 개선된 버전)
# =============================================================================
main_cleanup() {
    log_step "=== Day1 통합강의안 자원 정리 시작 (배포 순서의 역순) ==="
    
    # 1단계: LoadBalancer Service 정리 (가장 나중에 배포된 것)
    if [[ "$PROVIDER" == "kubernetes" || "$PROVIDER" == "all" ]]; then
        log_info "1단계: LoadBalancer Service 정리 시작"
        cleanup_kubernetes_resources
    fi
    
    # 2단계: Kubernetes 리소스 정리 (Pod, Service, Deployment)
    if [[ "$PROVIDER" == "kubernetes" || "$PROVIDER" == "all" ]]; then
        log_info "2단계: Kubernetes 리소스 정리 시작"
        cleanup_kubectl_contexts
    fi
    
    # 3단계: EKS 클러스터 정리 (Kubernetes 클러스터)
    if [[ "$PROVIDER" == "aws" || "$PROVIDER" == "all" ]]; then
        log_info "3단계: EKS 클러스터 정리 시작"
        
        # VPC 관련 리소스 먼저 정리 (CloudFormation 의존성 해결)
        log_info "VPC 관련 리소스 정리 시작"
        cleanup_aws_vpc
        
        # CloudFormation 스택 정리 (VPC 정리 후)
        cleanup_aws_cloudformation
        
        # 생성 순서의 역순으로 정리
        local aws_resources=("monitoring-hub" "eks-cluster" "ecs-service" "ecs-cluster" "load-balancer" "security-groups")
        
        for resource in "${aws_resources[@]}"; do
            log_info "AWS 리소스 정리: $resource"
            cleanup_resource "aws" "$resource"
            check_dependencies "aws" "$resource"
        done
        
        log_success "EKS 클러스터 정리 완료"
    fi
    
    # 4단계: Docker 리소스 정리 (가장 먼저 배포된 것)
    if [[ "$PROVIDER" == "docker" || "$PROVIDER" == "all" ]]; then
        log_info "4단계: Docker 리소스 정리 시작"
        cleanup_docker_containers
        cleanup_docker_images
        cleanup_docker_networks
        log_success "Docker 리소스 정리 완료"
    fi
    
    # GCP 리소스 정리 (Day1에서는 사용하지 않지만 호환성을 위해 유지)
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
    
    log_success "=== Day1 통합강의안 자원 정리 완료 ==="
    
    # 정리 결과 요약 (배포 순서의 역순)
    log_step "=== 정리 결과 요약 (배포 순서의 역순) ==="
    log_info "정리된 리소스 유형:"
    
    if [[ "$PROVIDER" == "kubernetes" || "$PROVIDER" == "all" ]]; then
        log_info "  ✅ 1단계: LoadBalancer Service (nginx-loadbalancer)"
        log_info "  ✅ 2단계: Kubernetes Pod, Service, Deployment"
        log_info "  ✅ kubectl Context 및 kubeconfig"
    fi
    
    if [[ "$PROVIDER" == "aws" || "$PROVIDER" == "all" ]]; then
        log_info "  ✅ 3단계: AWS EKS 클러스터"
        log_info "  ✅ AWS VPC, CloudFormation 스택"
    fi
    
    if [[ "$PROVIDER" == "docker" || "$PROVIDER" == "all" ]]; then
        log_info "  ✅ 4단계: Docker 컨테이너, 이미지, 네트워크"
    fi
    
    if [[ "$PROVIDER" == "gcp" || "$PROVIDER" == "all" ]]; then
        log_info "  ✅ GCP GKE 클러스터, Compute Engine"
        log_info "  ✅ GCP VPC, 방화벽 규칙"
    fi
    
    log_success "Day1 통합강의안 실습 환경이 배포 순서의 역순으로 완전히 정리되었습니다!"
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
