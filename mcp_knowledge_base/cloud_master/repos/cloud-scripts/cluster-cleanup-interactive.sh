#!/bin/bash

# =============================================================================
# Cloud Master Day2 - 통합 클러스터 정리 스크립트
# EKS와 GKE 클러스터를 선택적으로 정리할 수 있는 대화형 스크립트
# =============================================================================

set -e

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
log_header() { echo -e "${PURPLE}[HEADER]${NC} $1"; }

# 설정
AWS_REGION="ap-northeast-2"
GCP_PROJECT="cloud-deployment-471606"
GCP_ZONE="asia-northeast3-a"

# 체크포인트 파일
CHECKPOINT_FILE="cluster-cleanup-checkpoint.json"

# =============================================================================
# 유틸리티 함수
# =============================================================================

# 환경 체크
check_environment() {
    log_header "=== 환경 체크 ==="
    
    # AWS CLI 체크
    if command -v aws &> /dev/null; then
        log_success "AWS CLI 설치됨"
        aws --version
    else
        log_error "AWS CLI가 설치되지 않았습니다."
        return 1
    fi
    
    # eksctl 체크
    if command -v eksctl &> /dev/null; then
        log_success "eksctl 설치됨"
        eksctl version
    else
        log_error "eksctl이 설치되지 않았습니다."
        return 1
    fi
    
    # GCP CLI 체크
    if command -v gcloud &> /dev/null; then
        log_success "GCP CLI 설치됨"
        gcloud version 2>/dev/null | head -1 || echo "GCP CLI 버전 확인 실패"
    else
        log_warning "GCP CLI가 설치되지 않았습니다. GKE 정리 기능을 사용할 수 없습니다."
    fi
    
    # kubectl 체크
    if command -v kubectl &> /dev/null; then
        log_success "kubectl 설치됨"
        kubectl version --client 2>/dev/null | head -1 || echo "kubectl 버전 확인 실패"
    else
        log_warning "kubectl이 설치되지 않았습니다."
    fi
    
    echo ""
}

# AWS 계정 정보 확인
check_aws_credentials() {
    log_info "AWS 계정 정보 확인 중..."
    
    if aws sts get-caller-identity &> /dev/null; then
        local account_id=$(aws sts get-caller-identity --query Account --output text)
        local user_arn=$(aws sts get-caller-identity --query Arn --output text)
        log_success "AWS 계정 ID: $account_id"
        log_success "사용자: $user_arn"
        return 0
    else
        log_error "AWS 자격 증명이 설정되지 않았습니다."
        return 1
    fi
}

# GCP 계정 정보 확인
check_gcp_credentials() {
    log_info "GCP 계정 정보 확인 중..."
    
    if gcloud auth list --filter=status:ACTIVE --format="value(account)" &> /dev/null; then
        local account=$(gcloud auth list --filter=status:ACTIVE --format="value(account)")
        local project=$(gcloud config get-value project 2>/dev/null)
        log_success "GCP 계정: $account"
        log_success "프로젝트: $project"
        return 0
    else
        log_error "GCP 자격 증명이 설정되지 않았습니다."
        return 1
    fi
}

# =============================================================================
# EKS 클러스터 관리
# =============================================================================

# EKS 클러스터 목록 조회
list_eks_clusters() {
    log_info "EKS 클러스터 목록 조회 중..."
    
    local clusters=$(aws eks list-clusters --region "$AWS_REGION" --query 'clusters[]' --output text 2>/dev/null)
    
    if [ -z "$clusters" ]; then
        log_warning "EKS 클러스터가 없습니다."
        return 1
    fi
    
    echo ""
    log_info "=== EKS 클러스터 목록 ==="
    for cluster in $clusters; do
        local status=$(aws eks describe-cluster --name "$cluster" --region "$AWS_REGION" --query 'cluster.status' --output text 2>/dev/null)
        local version=$(aws eks describe-cluster --name "$cluster" --region "$AWS_REGION" --query 'cluster.version' --output text 2>/dev/null)
        local created=$(aws eks describe-cluster --name "$cluster" --region "$AWS_REGION" --query 'cluster.createdAt' --output text 2>/dev/null)
        
        echo "  📦 $cluster"
        echo "     상태: $status"
        echo "     버전: $version"
        echo "     생성일: $created"
        echo ""
    done
    
    return 0
}

# EKS 클러스터 삭제
delete_eks_cluster() {
    local cluster_name="$1"
    
    log_warning "EKS 클러스터 삭제: $cluster_name"
    echo -n "정말로 삭제하시겠습니까? (y/N): "
    read -r response
    
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        log_info "삭제가 취소되었습니다."
        return 0
    fi
    
    log_info "EKS 클러스터 삭제 중: $cluster_name"
    
    if eksctl delete cluster --name "$cluster_name" --region "$AWS_REGION" --wait; then
        log_success "EKS 클러스터 삭제 완료: $cluster_name"
        return 0
    else
        log_error "EKS 클러스터 삭제 실패: $cluster_name"
        return 1
    fi
}

# =============================================================================
# GKE 클러스터 관리
# =============================================================================

# GKE 클러스터 목록 조회
list_gke_clusters() {
    log_info "GKE 클러스터 목록 조회 중..."
    
    local clusters=$(gcloud container clusters list --format="value(name)" 2>/dev/null)
    
    if [ -z "$clusters" ]; then
        log_warning "GKE 클러스터가 없습니다."
        return 1
    fi
    
    echo ""
    log_info "=== GKE 클러스터 목록 ==="
    for cluster in $clusters; do
        local status=$(gcloud container clusters describe "$cluster" --zone="$GCP_ZONE" --format="value(status)" 2>/dev/null)
        local version=$(gcloud container clusters describe "$cluster" --zone="$GCP_ZONE" --format="value(currentMasterVersion)" 2>/dev/null)
        local node_count=$(gcloud container clusters describe "$cluster" --zone="$GCP_ZONE" --format="value(currentNodeCount)" 2>/dev/null)
        
        echo "  📦 $cluster"
        echo "     상태: $status"
        echo "     버전: $version"
        echo "     노드 수: $node_count"
        echo ""
    done
    
    return 0
}

# GKE 클러스터 삭제
delete_gke_cluster() {
    local cluster_name="$1"
    
    log_warning "GKE 클러스터 삭제: $cluster_name"
    echo -n "정말로 삭제하시겠습니까? (y/N): "
    read -r response
    
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        log_info "삭제가 취소되었습니다."
        return 0
    fi
    
    log_info "GKE 클러스터 삭제 중: $cluster_name"
    
    if gcloud container clusters delete "$cluster_name" --zone="$GCP_ZONE" --quiet; then
        log_success "GKE 클러스터 삭제 완료: $cluster_name"
        return 0
    else
        log_error "GKE 클러스터 삭제 실패: $cluster_name"
        return 1
    fi
}

# =============================================================================
# 메인 메뉴
# =============================================================================

# EKS 클러스터 메뉴
eks_menu() {
    while true; do
        echo ""
        log_header "=== EKS 클러스터 관리 ==="
        echo "1. EKS 클러스터 목록 보기"
        echo "2. EKS 클러스터 삭제"
        echo "3. 모든 EKS 클러스터 삭제"
        echo "4. 메인 메뉴로 돌아가기"
        echo ""
        echo -n "선택 (1-4): "
        read -r choice
        
        case $choice in
            1)
                list_eks_clusters
                ;;
            2)
                if list_eks_clusters; then
                    echo ""
                    echo -n "삭제할 클러스터 이름을 입력하세요: "
                    read -r cluster_name
                    if [ -n "$cluster_name" ]; then
                        delete_eks_cluster "$cluster_name"
                    fi
                fi
                ;;
            3)
                log_warning "모든 EKS 클러스터를 삭제합니다."
                echo -n "정말로 모든 EKS 클러스터를 삭제하시겠습니까? (y/N): "
                read -r response
                if [[ "$response" =~ ^[Yy]$ ]]; then
                    local clusters=$(aws eks list-clusters --region "$AWS_REGION" --query 'clusters[]' --output text 2>/dev/null)
                    for cluster in $clusters; do
                        delete_eks_cluster "$cluster"
                    done
                fi
                ;;
            4)
                break
                ;;
            *)
                log_error "잘못된 선택입니다."
                ;;
        esac
    done
}

# GKE 클러스터 메뉴
gke_menu() {
    while true; do
        echo ""
        log_header "=== GKE 클러스터 관리 ==="
        echo "1. GKE 클러스터 목록 보기"
        echo "2. GKE 클러스터 삭제"
        echo "3. 모든 GKE 클러스터 삭제"
        echo "4. 메인 메뉴로 돌아가기"
        echo ""
        echo -n "선택 (1-4): "
        read -r choice
        
        case $choice in
            1)
                list_gke_clusters
                ;;
            2)
                if list_gke_clusters; then
                    echo ""
                    echo -n "삭제할 클러스터 이름을 입력하세요: "
                    read -r cluster_name
                    if [ -n "$cluster_name" ]; then
                        delete_gke_cluster "$cluster_name"
                    fi
                fi
                ;;
            3)
                log_warning "모든 GKE 클러스터를 삭제합니다."
                echo -n "정말로 모든 GKE 클러스터를 삭제하시겠습니까? (y/N): "
                read -r response
                if [[ "$response" =~ ^[Yy]$ ]]; then
                    local clusters=$(gcloud container clusters list --format="value(name)" 2>/dev/null)
                    for cluster in $clusters; do
                        delete_gke_cluster "$cluster"
                    done
                fi
                ;;
            4)
                break
                ;;
            *)
                log_error "잘못된 선택입니다."
                ;;
        esac
    done
}

# 전체 정리 메뉴
full_cleanup_menu() {
    log_warning "전체 클러스터 정리를 시작합니다."
    echo "이 작업은 모든 EKS와 GKE 클러스터를 삭제합니다."
    echo -n "정말로 계속하시겠습니까? (y/N): "
    read -r response
    
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        log_info "전체 정리가 취소되었습니다."
        return 0
    fi
    
    # EKS 클러스터 정리
    log_info "EKS 클러스터 정리 시작..."
    local eks_clusters=$(aws eks list-clusters --region "$AWS_REGION" --query 'clusters[]' --output text 2>/dev/null)
    if [ -n "$eks_clusters" ]; then
        for cluster in $eks_clusters; do
            log_info "EKS 클러스터 삭제: $cluster"
            eksctl delete cluster --name "$cluster" --region "$AWS_REGION" --wait
        done
    else
        log_info "삭제할 EKS 클러스터가 없습니다."
    fi
    
    # GKE 클러스터 정리
    log_info "GKE 클러스터 정리 시작..."
    local gke_clusters=$(gcloud container clusters list --format="value(name)" 2>/dev/null)
    if [ -n "$gke_clusters" ]; then
        for cluster in $gke_clusters; do
            log_info "GKE 클러스터 삭제: $cluster"
            gcloud container clusters delete "$cluster" --zone="$GCP_ZONE" --quiet
        done
    else
        log_info "삭제할 GKE 클러스터가 없습니다."
    fi
    
    log_success "전체 클러스터 정리 완료!"
}

# 메인 메뉴
main_menu() {
    while true; do
        echo ""
        log_header "=== Cloud Master Day2 - 통합 클러스터 정리 ==="
        echo "1. EKS 클러스터 관리"
        echo "2. GKE 클러스터 관리"
        echo "3. 전체 클러스터 정리 (EKS + GKE)"
        echo "4. 환경 상태 확인"
        echo "5. 종료"
        echo ""
        echo -n "선택 (1-5): "
        read -r choice
        
        case $choice in
            1)
                eks_menu
                ;;
            2)
                gke_menu
                ;;
            3)
                full_cleanup_menu
                ;;
            4)
                check_environment
                ;;
            5)
                log_info "프로그램을 종료합니다."
                exit 0
                ;;
            *)
                log_error "잘못된 선택입니다."
                ;;
        esac
    done
}

# =============================================================================
# 메인 실행
# =============================================================================

main() {
    log_header "=== Cloud Master Day2 - 통합 클러스터 정리 스크립트 ==="
    log_info "EKS와 GKE 클러스터를 선택적으로 정리할 수 있습니다."
    echo ""
    
    # 환경 체크
    if ! check_environment; then
        log_error "환경 체크 실패. 필요한 도구를 설치하세요."
        exit 1
    fi
    
    # AWS 자격 증명 체크
    if ! check_aws_credentials; then
        log_warning "AWS 자격 증명이 설정되지 않았습니다. EKS 기능을 사용할 수 없습니다."
    fi
    
    # GCP 자격 증명 체크
    if ! check_gcp_credentials; then
        log_warning "GCP 자격 증명이 설정되지 않았습니다. GKE 기능을 사용할 수 없습니다."
    fi
    
    # 메인 메뉴 시작
    main_menu
}

# 스크립트 실행
main "$@"
