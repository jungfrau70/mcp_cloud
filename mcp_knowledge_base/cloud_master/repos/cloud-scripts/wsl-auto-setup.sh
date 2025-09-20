#!/bin/bash

# =============================================================================
# WSL 자동 설정 스크립트
# Cloud Master 과정용 WSL 환경 자동 구축 도구
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
log_wsl() { echo -e "${CYAN}[WSL]${NC} $1"; }

# 설정
DISTRO_NAME="Ubuntu-22.04"
USER_NAME="clouduser"
WORKSPACE_DIR="$HOME/mcp-cloud-workspace"
PROJECT_DIR="$WORKSPACE_DIR/mcp_cloud"

# 체크포인트 파일
CHECKPOINT_FILE="wsl-setup-checkpoint.json"

# =============================================================================
# 유틸리티 함수
# =============================================================================

# 체크포인트 저장
save_checkpoint() {
    local step="$1"
    local status="$2"
    local details="$3"
    
    local checkpoint_data=$(cat <<EOF
{
    "step": "$step",
    "status": "$status",
    "details": "$details",
    "timestamp": "$(date -Iseconds)"
}
EOF
)
    
    echo "$checkpoint_data" > "$CHECKPOINT_FILE"
    log_info "체크포인트 저장: $step - $status"
}

# 체크포인트 로드
load_checkpoint() {
    if [ -f "$CHECKPOINT_FILE" ]; then
        log_warning "이전 체크포인트 파일이 발견되었습니다."
        log_info "체크포인트 파일 삭제 중..."
        rm -f "$CHECKPOINT_FILE"
        log_success "체크포인트 파일 삭제 완료"
    fi
}

# WSL 환경 감지
detect_wsl_environment() {
    log_header "=== WSL 환경 감지 ==="
    
    if [ -f /proc/version ]; then
        local wsl_version=$(grep -i microsoft /proc/version | wc -l)
        if [ "$wsl_version" -gt 0 ]; then
            log_success "✅ WSL 환경 감지됨"
            
            # WSL 버전 상세 정보
            local wsl_info=$(grep -i microsoft /proc/version)
            log_wsl "WSL 정보: $wsl_info"
            
            # WSL2 확인
            if echo "$wsl_info" | grep -q "WSL2"; then
                log_success "✅ WSL2 사용 중"
            else
                log_warning "⚠️ WSL1 사용 중 (WSL2 권장)"
            fi
            
            return 0
        else
            log_error "❌ WSL 환경이 아닙니다."
            return 1
        fi
    else
        log_error "❌ WSL 환경이 아닙니다."
        return 1
    fi
}

# 시스템 업데이트
update_system() {
    log_header "=== 시스템 업데이트 ==="
    
    log_info "패키지 목록 업데이트 중..."
    sudo apt update -y
    
    log_info "시스템 업그레이드 중..."
    sudo apt upgrade -y
    
    log_info "필수 패키지 설치 중..."
    sudo apt install -y curl wget git vim nano htop tree unzip jq software-properties-common apt-transport-https ca-certificates gnupg lsb-release
    
    log_success "시스템 업데이트 완료"
    save_checkpoint "system_update" "completed" "System packages updated"
}

# Node.js 설치
install_nodejs() {
    log_header "=== Node.js 설치 ==="
    
    log_info "NodeSource 저장소 추가 중..."
    curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
    
    log_info "Node.js 설치 중..."
    sudo apt install -y nodejs
    
    # 버전 확인
    local node_version=$(node --version)
    local npm_version=$(npm --version)
    
    log_success "Node.js 설치 완료: $node_version"
    log_success "npm 설치 완료: $npm_version"
    
    save_checkpoint "nodejs_install" "completed" "Node.js $node_version installed"
}

# Python 설치
install_python() {
    log_header "=== Python 설치 ==="
    
    log_info "Python 3 및 pip 설치 중..."
    sudo apt install -y python3 python3-pip python3-venv python3-dev
    
    # 버전 확인
    local python_version=$(python3 --version)
    local pip_version=$(pip3 --version | cut -d' ' -f2)
    
    log_success "Python 설치 완료: $python_version"
    log_success "pip 설치 완료: $pip_version"
    
    save_checkpoint "python_install" "completed" "Python $python_version installed"
}

# Docker 설치
install_docker() {
    log_header "=== Docker 설치 ==="
    
    log_info "Docker 공식 GPG 키 추가 중..."
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    
    log_info "Docker 저장소 추가 중..."
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    log_info "Docker 설치 중..."
    sudo apt update
    sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
    
    log_info "사용자를 docker 그룹에 추가 중..."
    sudo usermod -aG docker $USER
    
    log_info "Docker 서비스 시작 중..."
    sudo systemctl start docker
    sudo systemctl enable docker
    
    # Docker 버전 확인
    local docker_version=$(docker --version)
    log_success "Docker 설치 완료: $docker_version"
    
    save_checkpoint "docker_install" "completed" "Docker installed and configured"
}

# AWS CLI 설치
install_aws_cli() {
    log_header "=== AWS CLI 설치 ==="
    
    log_info "AWS CLI v2 다운로드 중..."
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    
    log_info "AWS CLI 설치 중..."
    unzip -q awscliv2.zip
    sudo ./aws/install
    
    # 정리
    rm -rf aws awscliv2.zip
    
    # 버전 확인
    local aws_version=$(aws --version)
    log_success "AWS CLI 설치 완료: $aws_version"
    
    save_checkpoint "aws_cli_install" "completed" "AWS CLI installed"
}

# GCP CLI 설치
install_gcp_cli() {
    log_header "=== GCP CLI 설치 ==="
    
    log_info "GCP CLI 설치 중..."
    curl https://sdk.cloud.google.com | bash -s -- --disable-prompts
    
    log_info "환경 변수 설정 중..."
    echo 'export PATH=$PATH:/home/$USER/google-cloud-sdk/bin' >> ~/.bashrc
    export PATH=$PATH:/home/$USER/google-cloud-sdk/bin
    
    # 버전 확인
    local gcp_version=$(gcloud --version | head -n1)
    log_success "GCP CLI 설치 완료: $gcp_version"
    
    save_checkpoint "gcp_cli_install" "completed" "GCP CLI installed"
}

# kubectl 설치
install_kubectl() {
    log_header "=== kubectl 설치 ==="
    
    log_info "kubectl 설치 중..."
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
    
    # 버전 확인
    local kubectl_version=$(kubectl version --client --short 2>/dev/null || kubectl version --client)
    log_success "kubectl 설치 완료: $kubectl_version"
    
    save_checkpoint "kubectl_install" "completed" "kubectl installed"
}

# eksctl 설치
install_eksctl() {
    log_header "=== eksctl 설치 ==="
    
    log_info "eksctl 설치 중..."
    curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
    sudo mv /tmp/eksctl /usr/local/bin
    
    # 버전 확인
    local eksctl_version=$(eksctl version)
    log_success "eksctl 설치 완료: $eksctl_version"
    
    save_checkpoint "eksctl_install" "completed" "eksctl installed"
}

# Helm 설치
install_helm() {
    log_header "=== Helm 설치 ==="
    
    log_info "Helm 설치 중..."
    curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
    
    # 버전 확인
    local helm_version=$(helm version --short)
    log_success "Helm 설치 완료: $helm_version"
    
    save_checkpoint "helm_install" "completed" "Helm installed"
}

# 프로젝트 환경 설정
setup_project_environment() {
    log_header "=== 프로젝트 환경 설정 ==="
    
    log_info "작업 디렉토리 생성 중..."
    mkdir -p "$WORKSPACE_DIR"
    cd "$WORKSPACE_DIR"
    
    log_info "환경 변수 설정 중..."
    cat >> ~/.bashrc << 'EOF'

# Cloud Master 환경 변수
export AWS_DEFAULT_REGION=ap-northeast-2
export GCP_PROJECT=cloud-deployment-471606
export EDITOR=nano
export LANG=ko_KR.UTF-8
export LC_ALL=ko_KR.UTF-8

# PATH 설정
export PATH=$PATH:/home/$USER/google-cloud-sdk/bin
export PATH=$PATH:/home/$USER/.local/bin
EOF
    
    log_info "SSH 키 생성 중..."
    if [ ! -f ~/.ssh/cloud-deployment-key ]; then
        ssh-keygen -t rsa -b 4096 -C "cloud-deployment-key" -f ~/.ssh/cloud-deployment-key -N ""
        log_success "SSH 키 생성 완료"
    else
        log_info "SSH 키가 이미 존재합니다."
    fi
    
    log_success "프로젝트 환경 설정 완료"
    save_checkpoint "project_setup" "completed" "Project environment configured"
}

# 환경 검증
verify_environment() {
    log_header "=== 환경 검증 ==="
    
    local tools=("node" "npm" "python3" "pip3" "docker" "aws" "gcloud" "kubectl" "eksctl" "helm")
    local all_installed=true
    
    for tool in "${tools[@]}"; do
        if command -v "$tool" &> /dev/null; then
            log_success "✅ $tool 설치됨"
        else
            log_error "❌ $tool 설치되지 않음"
            all_installed=false
        fi
    done
    
    if [ "$all_installed" = true ]; then
        log_success "🎉 모든 도구가 성공적으로 설치되었습니다!"
        return 0
    else
        log_error "❌ 일부 도구 설치에 실패했습니다."
        return 1
    fi
}

# 설치 요약
print_summary() {
    log_header "=== 설치 요약 ==="
    
    echo "📦 설치된 도구들:"
    echo "  - Node.js: $(node --version 2>/dev/null || echo 'N/A')"
    echo "  - Python: $(python3 --version 2>/dev/null || echo 'N/A')"
    echo "  - Docker: $(docker --version 2>/dev/null || echo 'N/A')"
    echo "  - AWS CLI: $(aws --version 2>/dev/null || echo 'N/A')"
    echo "  - GCP CLI: $(gcloud --version 2>/dev/null | head -n1 || echo 'N/A')"
    echo "  - kubectl: $(kubectl version --client --short 2>/dev/null || echo 'N/A')"
    echo "  - eksctl: $(eksctl version 2>/dev/null || echo 'N/A')"
    echo "  - Helm: $(helm version --short 2>/dev/null || echo 'N/A')"
    
    echo ""
    echo "📁 작업 디렉토리: $WORKSPACE_DIR"
    echo "🔑 SSH 키: ~/.ssh/cloud-deployment-key"
    echo "⚙️ 환경 설정: ~/.bashrc"
    
    echo ""
    log_success "WSL 환경 설정이 완료되었습니다!"
    log_info "다음 단계:"
    echo "  1. 터미널을 재시작하거나 'source ~/.bashrc' 실행"
    echo "  2. AWS 자격 증명 설정: aws configure"
    echo "  3. GCP 인증: gcloud auth login"
    echo "  4. 환경 체크 스크립트 실행: ./environment-check-wsl.sh"
}

# 메인 함수
main() {
    log_header "=== WSL 자동 설정 스크립트 ==="
    log_info "Cloud Master 과정용 WSL 환경을 자동으로 구축합니다."
    echo ""
    
    # 체크포인트 파일 정리
    load_checkpoint
    
    # WSL 환경 감지
    if ! detect_wsl_environment; then
        log_error "WSL 환경이 아닙니다. 이 스크립트는 WSL에서만 실행할 수 있습니다."
        exit 1
    fi
    
    # 설치 단계 실행
    update_system
    install_nodejs
    install_python
    install_docker
    install_aws_cli
    install_gcp_cli
    install_kubectl
    install_eksctl
    install_helm
    setup_project_environment
    
    # 환경 검증
    if verify_environment; then
        print_summary
        save_checkpoint "installation" "completed" "All tools installed successfully"
    else
        log_error "설치 검증에 실패했습니다. 수동으로 확인해주세요."
        exit 1
    fi
}

# 스크립트 실행
main "$@"
