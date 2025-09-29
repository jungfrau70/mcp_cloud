#!/bin/bash

# =============================================================================
# GCP Compute Engine Helper 모듈
# =============================================================================
# 
# 기능:
#   - GCP Compute Engine 인스턴스 생성 및 관리
#   - 방화벽 규칙 설정
#   - SSH 키 관리
#   - 인스턴스 상태 모니터링
#   - 서브실행모듈을 통한 클라우드 작업 실행
#
# 사용법:
#   ./gcp-compute-helper.sh --action <액션> [옵션]
#   ./gcp-compute-helper.sh --help
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
log_debug() { echo -e "${PURPLE}[DEBUG]${NC} $1"; }
log_step() { echo -e "${CYAN}[STEP]${NC} $1"; }

# =============================================================================
# 환경 설정 로드
# =============================================================================
load_environment() {
    log_info "환경 설정 로드 중..."
    
    # GCP 환경 설정 로드
    if [ -f "gcp-environment.env" ]; then
        source "gcp-environment.env"
        log_success "GCP 환경 설정 로드 완료"
        log_info "로드된 설정:"
        echo "  - 프로젝트: ${GCP_PROJECT:-'설정되지 않음'}"
        echo "  - 리전: ${GCP_REGION:-'설정되지 않음'}"
        echo "  - 존: ${GCP_ZONE:-'설정되지 않음'}"
        echo "  - 서비스 계정: ${GCP_SERVICE_ACCOUNT:-'설정되지 않음'}"
    else
        log_warning "GCP 환경 설정 파일을 찾을 수 없습니다: gcp-environment.env"
        log_info "gcp-setup-helper.sh를 먼저 실행하세요."
    fi
}

# =============================================================================
# 사용법 출력
# =============================================================================
usage() {
    cat << EOF
GCP Compute Engine Helper 모듈

사용법:
  $0 --action <액션> [옵션]

액션:
  create-instance        # Compute Engine 인스턴스 생성
  create-firewall        # 방화벽 규칙 생성
  create-ssh-key         # SSH 키 생성
  start-instance         # 인스턴스 시작
  stop-instance          # 인스턴스 중지
  delete-instance        # 인스턴스 삭제
  list-instances         # 인스턴스 목록 조회
  instance-status        # 인스턴스 상태 확인
  cleanup                # Compute Engine 리소스 정리
  status                 # Compute Engine 상태 확인

옵션:
  --instance-name <name> # 인스턴스 이름 (기본값: mcp-cloud-instance)
  --machine-type <type>  # 머신 타입 (기본값: e2-medium)
  --zone <zone>          # 존 (기본값: 환경변수)
  --project <project>    # 프로젝트 ID (기본값: 환경변수)
  --region <region>      # 리전 (기본값: 환경변수)
  --help, -h             # 도움말 표시

예시:
  $0 --action create-instance
  $0 --action create-instance --instance-name my-instance --machine-type e2-standard-2
  $0 --action create-firewall
  $0 --action list-instances
  $0 --action cleanup
EOF
}

# =============================================================================
# Compute Engine 인스턴스 생성
# =============================================================================
create_instance() {
    local instance_name="${1:-mcp-cloud-instance}"
    local machine_type="${2:-e2-medium}"
    local zone="${3:-${GCP_ZONE:-asia-northeast3-a}}"
    local project="${4:-${GCP_PROJECT:-}}"
    local region="${5:-${GCP_REGION:-asia-northeast3}}"
    
    log_step "Compute Engine 인스턴스 생성 시작"
    log_info "인스턴스 이름: $instance_name"
    log_info "머신 타입: $machine_type"
    log_info "존: $zone"
    log_info "프로젝트: $project"
    
    if [ -z "$project" ]; then
        log_error "프로젝트 ID가 설정되지 않았습니다."
        return 1
    fi
    
    # 인스턴스 생성
    log_info "인스턴스 생성 중..."
    gcloud compute instances create "$instance_name" \
        --project="$project" \
        --zone="$zone" \
        --machine-type="$machine_type" \
        --image-family="ubuntu-2004-lts" \
        --image-project="ubuntu-os-cloud" \
        --boot-disk-size="20GB" \
        --boot-disk-type="pd-standard" \
        --tags="mcp-cloud" \
        --metadata="startup-script=#!/bin/bash
apt-get update
apt-get install -y docker.io
systemctl start docker
systemctl enable docker
usermod -aG docker \$(whoami)" \
        --scopes="https://www.googleapis.com/auth/cloud-platform"
    
    if [ $? -eq 0 ]; then
        log_success "인스턴스가 생성되었습니다: $instance_name"
        
        # 인스턴스 정보 조회
        local external_ip
        external_ip=$(gcloud compute instances describe "$instance_name" \
            --project="$project" \
            --zone="$zone" \
            --format="get(networkInterfaces[0].accessConfigs[0].natIP)")
        
        log_info "외부 IP: $external_ip"
        log_info "SSH 접속: gcloud compute ssh $instance_name --zone=$zone --project=$project"
    else
        log_error "인스턴스 생성에 실패했습니다."
        return 1
    fi
    
    return 0
}

# =============================================================================
# 방화벽 규칙 생성
# =============================================================================
create_firewall() {
    local project="${1:-${GCP_PROJECT:-}}"
    local region="${2:-${GCP_REGION:-asia-northeast3}}"
    
    log_step "방화벽 규칙 생성 시작"
    log_info "프로젝트: $project"
    log_info "리전: $region"
    
    if [ -z "$project" ]; then
        log_error "프로젝트 ID가 설정되지 않았습니다."
        return 1
    fi
    
    # SSH 방화벽 규칙
    log_info "SSH 방화벽 규칙 생성 중..."
    gcloud compute firewall-rules create "mcp-cloud-ssh" \
        --project="$project" \
        --direction="INGRESS" \
        --priority="1000" \
        --network="default" \
        --action="ALLOW" \
        --rules="tcp:22" \
        --source-ranges="0.0.0.0/0" \
        --target-tags="mcp-cloud" \
        --description="Allow SSH access to MCP Cloud instances"
    
    # HTTP 방화벽 규칙
    log_info "HTTP 방화벽 규칙 생성 중..."
    gcloud compute firewall-rules create "mcp-cloud-http" \
        --project="$project" \
        --direction="INGRESS" \
        --priority="1000" \
        --network="default" \
        --action="ALLOW" \
        --rules="tcp:80" \
        --source-ranges="0.0.0.0/0" \
        --target-tags="mcp-cloud" \
        --description="Allow HTTP access to MCP Cloud instances"
    
    # HTTPS 방화벽 규칙
    log_info "HTTPS 방화벽 규칙 생성 중..."
    gcloud compute firewall-rules create "mcp-cloud-https" \
        --project="$project" \
        --direction="INGRESS" \
        --priority="1000" \
        --network="default" \
        --action="ALLOW" \
        --rules="tcp:443" \
        --source-ranges="0.0.0.0/0" \
        --target-tags="mcp-cloud" \
        --description="Allow HTTPS access to MCP Cloud instances"
    
    # 커스텀 포트 방화벽 규칙
    log_info "커스텀 포트 방화벽 규칙 생성 중..."
    gcloud compute firewall-rules create "mcp-cloud-custom" \
        --project="$project" \
        --direction="INGRESS" \
        --priority="1000" \
        --network="default" \
        --action="ALLOW" \
        --rules="tcp:3000-9000" \
        --source-ranges="0.0.0.0/0" \
        --target-tags="mcp-cloud" \
        --description="Allow custom ports to MCP Cloud instances"
    
    log_success "방화벽 규칙이 생성되었습니다"
}

# =============================================================================
# SSH 키 생성
# =============================================================================
create_ssh_key() {
    local key_name="${1:-mcp-cloud-key}"
    local project="${2:-${GCP_PROJECT:-}}"
    
    log_step "SSH 키 생성 시작"
    log_info "키 이름: $key_name"
    log_info "프로젝트: $project"
    
    if [ -z "$project" ]; then
        log_error "프로젝트 ID가 설정되지 않았습니다."
        return 1
    fi
    
    # SSH 키 생성
    log_info "SSH 키 생성 중..."
    ssh-keygen -t rsa -b 4096 -f "${key_name}" -C "mcp-cloud-key" -N ""
    
    if [ $? -eq 0 ]; then
        chmod 400 "${key_name}"
        chmod 644 "${key_name}.pub"
        log_success "SSH 키가 생성되었습니다: ${key_name}"
        log_info "개인키 파일: $(pwd)/${key_name}"
        log_info "공개키 파일: $(pwd)/${key_name}.pub"
        
        # 공개키를 GCP 프로젝트에 추가
        log_info "공개키를 GCP 프로젝트에 추가 중..."
        gcloud compute os-login ssh-keys add \
            --project="$project" \
            --key-file="${key_name}.pub"
        
        log_success "SSH 키가 GCP 프로젝트에 추가되었습니다"
    else
        log_error "SSH 키 생성에 실패했습니다."
        return 1
    fi
    
    return 0
}

# =============================================================================
# 인스턴스 목록 조회
# =============================================================================
list_instances() {
    local project="${1:-${GCP_PROJECT:-}}"
    local zone="${2:-${GCP_ZONE:-asia-northeast3-a}}"
    
    if [ -z "$project" ]; then
        log_error "프로젝트 ID가 설정되지 않았습니다."
        return 1
    fi
    
    log_step "Compute Engine 인스턴스 목록 조회"
    log_info "프로젝트: $project"
    log_info "존: $zone"
    
    gcloud compute instances list \
        --project="$project" \
        --zones="$zone" \
        --format="table(name,zone,machineType,status,externalIP)"
}

# =============================================================================
# 인스턴스 상태 확인
# =============================================================================
instance_status() {
    local instance_name="${1:-}"
    local project="${2:-${GCP_PROJECT:-}}"
    local zone="${3:-${GCP_ZONE:-asia-northeast3-a}}"
    
    if [ -z "$instance_name" ]; then
        log_error "인스턴스 이름을 지정해주세요."
        return 1
    fi
    
    if [ -z "$project" ]; then
        log_error "프로젝트 ID가 설정되지 않았습니다."
        return 1
    fi
    
    log_step "인스턴스 상태 확인"
    log_info "인스턴스 이름: $instance_name"
    log_info "프로젝트: $project"
    log_info "존: $zone"
    
    gcloud compute instances describe "$instance_name" \
        --project="$project" \
        --zone="$zone" \
        --format="table(name,zone,machineType,status,externalIP,internalIP,creationTimestamp)"
}

# =============================================================================
# 인스턴스 시작
# =============================================================================
start_instance() {
    local instance_name="${1:-}"
    local project="${2:-${GCP_PROJECT:-}}"
    local zone="${3:-${GCP_ZONE:-asia-northeast3-a}}"
    
    if [ -z "$instance_name" ]; then
        log_error "인스턴스 이름을 지정해주세요."
        return 1
    fi
    
    if [ -z "$project" ]; then
        log_error "프로젝트 ID가 설정되지 않았습니다."
        return 1
    fi
    
    log_step "인스턴스 시작"
    log_info "인스턴스 이름: $instance_name"
    
    gcloud compute instances start "$instance_name" \
        --project="$project" \
        --zone="$zone"
    
    if [ $? -eq 0 ]; then
        log_success "인스턴스 시작 요청이 완료되었습니다"
    else
        log_error "인스턴스 시작에 실패했습니다."
        return 1
    fi
}

# =============================================================================
# 인스턴스 중지
# =============================================================================
stop_instance() {
    local instance_name="${1:-}"
    local project="${2:-${GCP_PROJECT:-}}"
    local zone="${3:-${GCP_ZONE:-asia-northeast3-a}}"
    
    if [ -z "$instance_name" ]; then
        log_error "인스턴스 이름을 지정해주세요."
        return 1
    fi
    
    if [ -z "$project" ]; then
        log_error "프로젝트 ID가 설정되지 않았습니다."
        return 1
    fi
    
    log_step "인스턴스 중지"
    log_info "인스턴스 이름: $instance_name"
    
    gcloud compute instances stop "$instance_name" \
        --project="$project" \
        --zone="$zone"
    
    if [ $? -eq 0 ]; then
        log_success "인스턴스 중지 요청이 완료되었습니다"
    else
        log_error "인스턴스 중지에 실패했습니다."
        return 1
    fi
}

# =============================================================================
# 인스턴스 삭제
# =============================================================================
delete_instance() {
    local instance_name="${1:-}"
    local project="${2:-${GCP_PROJECT:-}}"
    local zone="${3:-${GCP_ZONE:-asia-northeast3-a}}"
    
    if [ -z "$instance_name" ]; then
        log_error "인스턴스 이름을 지정해주세요."
        return 1
    fi
    
    if [ -z "$project" ]; then
        log_error "프로젝트 ID가 설정되지 않았습니다."
        return 1
    fi
    
    log_step "인스턴스 삭제"
    log_info "인스턴스 이름: $instance_name"
    
    gcloud compute instances delete "$instance_name" \
        --project="$project" \
        --zone="$zone" \
        --quiet
    
    if [ $? -eq 0 ]; then
        log_success "인스턴스 삭제 요청이 완료되었습니다"
    else
        log_error "인스턴스 삭제에 실패했습니다."
        return 1
    fi
}

# =============================================================================
# Compute Engine 리소스 정리
# =============================================================================
cleanup() {
    local project="${1:-${GCP_PROJECT:-}}"
    local region="${2:-${GCP_REGION:-asia-northeast3}}"
    
    if [ -z "$project" ]; then
        log_error "프로젝트 ID가 설정되지 않았습니다."
        return 1
    fi
    
    log_step "Compute Engine 리소스 정리 시작"
    log_info "프로젝트: $project"
    log_info "리전: $region"
    
    # MCP Cloud 태그가 있는 인스턴스 삭제
    log_info "MCP Cloud 인스턴스 삭제 중..."
    local instances
    instances=$(gcloud compute instances list \
        --project="$project" \
        --filter="tags.items:mcp-cloud" \
        --format="value(name,zone)" 2>/dev/null || echo "")
    
    if [ -n "$instances" ]; then
        echo "$instances" | while read -r instance_name zone; do
            if [ -n "$instance_name" ] && [ -n "$zone" ]; then
                log_info "인스턴스 삭제: $instance_name (존: $zone)"
                gcloud compute instances delete "$instance_name" \
                    --project="$project" \
                    --zone="$zone" \
                    --quiet >/dev/null 2>&1 || true
            fi
        done
    fi
    
    # MCP Cloud 방화벽 규칙 삭제
    log_info "MCP Cloud 방화벽 규칙 삭제 중..."
    local firewall_rules
    firewall_rules=$(gcloud compute firewall-rules list \
        --project="$project" \
        --filter="name:mcp-cloud-*" \
        --format="value(name)" 2>/dev/null || echo "")
    
    if [ -n "$firewall_rules" ]; then
        echo "$firewall_rules" | while read -r rule_name; do
            if [ -n "$rule_name" ]; then
                log_info "방화벽 규칙 삭제: $rule_name"
                gcloud compute firewall-rules delete "$rule_name" \
                    --project="$project" \
                    --quiet >/dev/null 2>&1 || true
            fi
        done
    fi
    
    # 로컬 SSH 키 파일 삭제
    rm -f mcp-cloud-key mcp-cloud-key.pub
    
    log_success "Compute Engine 리소스 정리가 완료되었습니다"
}

# =============================================================================
# Compute Engine 상태 확인
# =============================================================================
status() {
    local project="${1:-${GCP_PROJECT:-}}"
    local region="${2:-${GCP_REGION:-asia-northeast3}}"
    
    if [ -z "$project" ]; then
        log_error "프로젝트 ID가 설정되지 않았습니다."
        return 1
    fi
    
    log_step "Compute Engine 상태 확인"
    log_info "프로젝트: $project"
    log_info "리전: $region"
    
    # 인스턴스 상태
    log_info "=== 인스턴스 상태 ==="
    gcloud compute instances list \
        --project="$project" \
        --format="table(name,zone,machineType,status,externalIP)" 2>/dev/null || echo "인스턴스가 없습니다."
    
    # 방화벽 규칙 상태
    log_info "=== 방화벽 규칙 상태 ==="
    gcloud compute firewall-rules list \
        --project="$project" \
        --filter="name:mcp-cloud-*" \
        --format="table(name,direction,priority,sourceRanges.list():label=SRC_RANGES,allowed[].map().firewall_rule().list():label=ALLOW)" 2>/dev/null || echo "방화벽 규칙이 없습니다."
    
    # SSH 키 상태
    log_info "=== SSH 키 상태 ==="
    gcloud compute os-login ssh-keys list \
        --project="$project" \
        --format="table(fingerprint,expireTime)" 2>/dev/null || echo "SSH 키가 없습니다."
}

# =============================================================================
# 메인 실행 로직
# =============================================================================
main() {
    # 환경 설정 로드
    load_environment
    
    # 인수 파싱
    local action=""
    local instance_name="mcp-cloud-instance"
    local machine_type="e2-medium"
    local zone="${GCP_ZONE:-asia-northeast3-a}"
    local project="${GCP_PROJECT:-}"
    local region="${GCP_REGION:-asia-northeast3}"
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --help|-h)
                usage
                exit 0
                ;;
            --action)
                action="$2"
                shift 2
                ;;
            --instance-name)
                instance_name="$2"
                shift 2
                ;;
            --machine-type)
                machine_type="$2"
                shift 2
                ;;
            --zone)
                zone="$2"
                shift 2
                ;;
            --project)
                project="$2"
                shift 2
                ;;
            --region)
                region="$2"
                shift 2
                ;;
            *)
                log_error "알 수 없는 옵션: $1"
                usage
                exit 1
                ;;
        esac
    done
    
    if [ -z "$action" ]; then
        log_error "액션을 지정해주세요."
        usage
        exit 1
    fi
    
    # 액션 실행
    case "$action" in
        "create-instance")
            create_instance "$instance_name" "$machine_type" "$zone" "$project" "$region"
            ;;
        "create-firewall")
            create_firewall "$project" "$region"
            ;;
        "create-ssh-key")
            create_ssh_key "mcp-cloud-key" "$project"
            ;;
        "start-instance")
            start_instance "$instance_name" "$project" "$zone"
            ;;
        "stop-instance")
            stop_instance "$instance_name" "$project" "$zone"
            ;;
        "delete-instance")
            delete_instance "$instance_name" "$project" "$zone"
            ;;
        "list-instances")
            list_instances "$project" "$zone"
            ;;
        "instance-status")
            instance_status "$instance_name" "$project" "$zone"
            ;;
        "cleanup")
            cleanup "$project" "$region"
            ;;
        "status")
            status "$project" "$region"
            ;;
        *)
            log_error "알 수 없는 액션: $action"
            usage
            exit 1
            ;;
    esac
}

# =============================================================================
# 스크립트 실행
# =============================================================================
main "$@"
