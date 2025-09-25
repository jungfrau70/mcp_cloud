#!/bin/bash

# 모든 클러스터 통합 정리 스크립트
# Cloud Master Day2용 - GCP GKE + AWS EKS 클러스터 정리

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# 로그 함수
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# 설정 변수
GCP_PROJECT_ID=""
GCP_ZONE="asia-northeast3-a"
AWS_REGION="ap-northeast-2"
FORCE_DELETE=false
GCP_ONLY=false
AWS_ONLY=false

# 도움말 함수
show_help() {
    cat << EOF
사용법: $0 [옵션]

옵션:
    --gcp-only          GCP GKE 클러스터만 삭제
    --aws-only          AWS EKS 클러스터만 삭제
    --force             확인 없이 강제 삭제
    --project-id ID     GCP 프로젝트 ID 지정
    --zone ZONE         GCP 존 지정 (기본값: asia-northeast3-a)
    --region REGION     AWS 리전 지정 (기본값: ap-northeast-2)
    --help              이 도움말 표시

예시:
    $0                              # 모든 클러스터 삭제 (확인 필요)
    $0 --gcp-only                   # GCP 클러스터만 삭제
    $0 --aws-only                   # AWS 클러스터만 삭제
    $0 --force                      # 확인 없이 강제 삭제
    $0 --project-id my-project      # 특정 GCP 프로젝트의 클러스터 삭제
EOF
}

# 인수 파싱
parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --gcp-only)
                GCP_ONLY=true
                shift
                ;;
            --aws-only)
                AWS_ONLY=true
                shift
                ;;
            --force)
                FORCE_DELETE=true
                shift
                ;;
            --project-id)
                GCP_PROJECT_ID="$2"
                shift 2
                ;;
            --zone)
                GCP_ZONE="$2"
                shift 2
                ;;
            --region)
                AWS_REGION="$2"
                shift 2
                ;;
            --help)
                show_help
                exit 0
                ;;
            *)
                log_error "알 수 없는 옵션: $1"
                show_help
                exit 1
                ;;
        esac
    done
}

# 환경 체크
check_environment() {
    log_info "환경 체크 중..."
    
    # GCP 환경 체크
    if [ "$AWS_ONLY" = false ]; then
        if ! command -v gcloud &> /dev/null; then
            log_error "gcloud CLI가 설치되지 않았습니다."
            exit 1
        fi
        
        if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" | grep -q .; then
            log_error "GCP 인증이 필요합니다. 'gcloud auth login'을 실행하세요."
            exit 1
        fi
        
        if [ -n "$GCP_PROJECT_ID" ]; then
            gcloud config set project "$GCP_PROJECT_ID"
        fi
    fi
    
    # AWS 환경 체크
    if [ "$GCP_ONLY" = false ]; then
        if ! command -v aws &> /dev/null; then
            log_error "AWS CLI가 설치되지 않았습니다."
            exit 1
        fi
        
        if ! aws sts get-caller-identity &> /dev/null; then
            log_error "AWS 인증이 필요합니다. 'aws configure'를 실행하세요."
            exit 1
        fi
        
        if ! command -v eksctl &> /dev/null; then
            log_error "eksctl이 설치되지 않았습니다."
            exit 1
        fi
    fi
    
    log_success "환경 체크 완료"
}

# GCP GKE 클러스터 삭제
delete_gcp_clusters() {
    log_info "GCP GKE 클러스터 삭제 시작..."
    
    # 현재 프로젝트 확인
    local current_project=$(gcloud config get-value project)
    log_info "현재 GCP 프로젝트: $current_project"
    
    # 모든 클러스터 목록 가져오기
    local clusters=$(gcloud container clusters list --format="value(name,zone)" 2>/dev/null)
    
    if [ -z "$clusters" ]; then
        log_info "삭제할 GCP 클러스터가 없습니다."
        return 0
    fi
    
    log_info "발견된 GCP 클러스터:"
    echo "$clusters" | while read name zone; do
        log_info "  - $name ($zone)"
    done
    
    # 확인
    if [ "$FORCE_DELETE" = false ]; then
        echo -n "GCP 클러스터들을 삭제하시겠습니까? (y/N): "
        read -r response
        if [[ ! "$response" =~ ^[Yy]$ ]]; then
            log_info "GCP 클러스터 삭제를 취소했습니다."
            return 0
        fi
    fi
    
    # 클러스터 삭제
    echo "$clusters" | while read name zone; do
        log_info "클러스터 삭제 중: $name ($zone)"
        gcloud container clusters delete "$name" --zone="$zone" --quiet
        
        if [ $? -eq 0 ]; then
            log_success "✅ 클러스터 삭제 완료: $name"
        else
            log_error "❌ 클러스터 삭제 실패: $name"
        fi
    done
    
    log_success "GCP 클러스터 삭제 완료"
}

# AWS EKS 클러스터 삭제
delete_aws_clusters() {
    log_info "AWS EKS 클러스터 삭제 시작..."
    
    # 모든 클러스터 목록 가져오기 (더 안전한 방법)
    local cluster_json=$(eksctl get cluster --region "$AWS_REGION" --output json 2>/dev/null)
    
    # JSON이 유효한지 확인
    if ! echo "$cluster_json" | jq empty 2>/dev/null; then
        log_info "AWS EKS 클러스터 목록을 가져올 수 없습니다. (eksctl 오류 또는 클러스터 없음)"
        return 0
    fi
    
    # 클러스터 이름 추출
    local clusters=$(echo "$cluster_json" | jq -r '.[].name' 2>/dev/null)
    
    # null 값이나 빈 값 체크
    if [ -z "$clusters" ] || [ "$clusters" = "null" ]; then
        log_info "삭제할 AWS 클러스터가 없습니다."
        return 0
    fi
    
    log_info "발견된 AWS 클러스터:"
    echo "$clusters" | while read name; do
        # null 값이나 빈 값 건너뛰기
        if [ -n "$name" ] && [ "$name" != "null" ]; then
            log_info "  - $name"
        fi
    done
    
    # 확인
    if [ "$FORCE_DELETE" = false ]; then
        echo -n "AWS 클러스터들을 삭제하시겠습니까? (y/N): "
        read -r response
        if [[ ! "$response" =~ ^[Yy]$ ]]; then
            log_info "AWS 클러스터 삭제를 취소했습니다."
            return 0
        fi
    fi
    
    # 클러스터 삭제
    echo "$clusters" | while read name; do
        # null 값이나 빈 값 건너뛰기
        if [ -n "$name" ] && [ "$name" != "null" ]; then
            log_info "클러스터 삭제 중: $name"
            eksctl delete cluster --name "$name" --region "$AWS_REGION" --wait
            
            if [ $? -eq 0 ]; then
                log_success "✅ 클러스터 삭제 완료: $name"
            else
                log_error "❌ 클러스터 삭제 실패: $name"
            fi
        fi
    done
    
    log_success "AWS 클러스터 삭제 완료"
}

# 추가 리소스 정리
cleanup_additional_resources() {
    log_info "추가 리소스 정리 중..."
    
    # GCP 추가 리소스 정리
    if [ "$AWS_ONLY" = false ]; then
        log_info "GCP 추가 리소스 정리 중..."
        
        # 사용하지 않는 디스크 정리
        local unused_disks=$(gcloud compute disks list --filter="status:UNATTACHED" --format="value(name,zone)" 2>/dev/null)
        if [ -n "$unused_disks" ]; then
            log_info "사용하지 않는 디스크 발견:"
            echo "$unused_disks" | while read name zone; do
                log_info "  - $name ($zone)"
            done
            
            if [ "$FORCE_DELETE" = true ]; then
                echo "$unused_disks" | while read name zone; do
                    gcloud compute disks delete "$name" --zone="$zone" --quiet
                    log_success "디스크 삭제 완료: $name"
                done
            fi
        fi
        
        # 사용하지 않는 방화벽 규칙 정리
        local firewall_rules=$(gcloud compute firewall-rules list --filter="name~cloud-master" --format="value(name)" 2>/dev/null)
        if [ -n "$firewall_rules" ]; then
            log_info "Cloud Master 관련 방화벽 규칙 발견:"
            echo "$firewall_rules" | while read name; do
                log_info "  - $name"
            done
            
            if [ "$FORCE_DELETE" = true ]; then
                echo "$firewall_rules" | while read name; do
                    gcloud compute firewall-rules delete "$name" --quiet
                    log_success "방화벽 규칙 삭제 완료: $name"
                done
            fi
        fi
    fi
    
    # AWS 추가 리소스 정리
    if [ "$GCP_ONLY" = false ]; then
        log_info "AWS 추가 리소스 정리 중..."
        
        # Cloud Master 관련 VPC 정리
        local vpcs=$(aws ec2 describe-vpcs --filters "Name=tag:Name,Values=*cloud-master*" --query 'Vpcs[*].VpcId' --output text 2>/dev/null)
        if [ -n "$vpcs" ]; then
            log_info "Cloud Master 관련 VPC 발견:"
            echo "$vpcs" | while read vpc; do
                log_info "  - $vpc"
            done
            
            if [ "$FORCE_DELETE" = true ]; then
                echo "$vpcs" | while read vpc; do
                    aws ec2 delete-vpc --vpc-id "$vpc"
                    log_success "VPC 삭제 완료: $vpc"
                done
            fi
        fi
        
        # Cloud Master 관련 보안 그룹 정리
        local security_groups=$(aws ec2 describe-security-groups --filters "Name=group-name,Values=*cloud-master*" --query 'SecurityGroups[*].GroupId' --output text 2>/dev/null)
        if [ -n "$security_groups" ]; then
            log_info "Cloud Master 관련 보안 그룹 발견:"
            echo "$security_groups" | while read sg; do
                log_info "  - $sg"
            done
            
            if [ "$FORCE_DELETE" = true ]; then
                echo "$security_groups" | while read sg; do
                    aws ec2 delete-security-group --group-id "$sg"
                    log_success "보안 그룹 삭제 완료: $sg"
                done
            fi
        fi
    fi
    
    log_success "추가 리소스 정리 완료"
}

# 비용 확인
check_costs() {
    log_info "비용 확인 중..."
    
    # GCP 비용 확인
    if [ "$AWS_ONLY" = false ]; then
        log_info "GCP 비용 확인:"
        gcloud billing budgets list 2>/dev/null || log_warning "GCP 비용 정보를 가져올 수 없습니다."
    fi
    
    # AWS 비용 확인
    if [ "$GCP_ONLY" = false ]; then
        log_info "AWS 비용 확인:"
        aws ce get-cost-and-usage \
            --time-period Start=$(date -d '1 month ago' +%Y-%m-%d),End=$(date +%Y-%m-%d) \
            --granularity MONTHLY \
            --metrics BlendedCost \
            --query 'ResultsByTime[0].Total.BlendedCost.Amount' \
            --output text 2>/dev/null || log_warning "AWS 비용 정보를 가져올 수 없습니다."
    fi
}

# 메인 함수
main() {
    log_info "=== Cloud Master 클러스터 통합 정리 시작 ==="
    
    # 인수 파싱
    parse_arguments "$@"
    
    # 환경 체크
    check_environment
    
    # GCP 클러스터 삭제
    if [ "$AWS_ONLY" = false ]; then
        delete_gcp_clusters
    fi
    
    # AWS 클러스터 삭제
    if [ "$GCP_ONLY" = false ]; then
        delete_aws_clusters
    fi
    
    # 추가 리소스 정리
    cleanup_additional_resources
    
    # 비용 확인
    check_costs
    
    log_success "=== 클러스터 정리 완료 ==="
    log_info "정리된 리소스:"
    if [ "$AWS_ONLY" = false ]; then
        log_info "  - GCP GKE 클러스터"
    fi
    if [ "$GCP_ONLY" = false ]; then
        log_info "  - AWS EKS 클러스터"
    fi
    log_info "  - 관련 네트워크 리소스"
    log_info "  - 보안 그룹 및 방화벽 규칙"
    
    log_info "다음 단계:"
    log_info "1. 비용 대시보드에서 최종 비용 확인"
    log_info "2. 필요시 추가 리소스 수동 정리"
    log_info "3. 다음 실습을 위해 새 클러스터 생성"
}

# 스크립트 실행
if [ "${BASH_SOURCE[0]}" == "${0}" ]; then
    main "$@"
fi
