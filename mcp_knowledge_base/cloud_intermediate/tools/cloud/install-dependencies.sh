#!/bin/bash

# =============================================================================
# Cloud Intermediate 의존성 자동 설치 스크립트
# =============================================================================
# 
# 기능:
#   - 모든 실습에 필요한 의존성 자동 설치
#   - 환경별 맞춤 설치
#   - 설치 검증 및 문제 해결
#
# 사용법:
#   ./install-dependencies.sh                    # 전체 설치
#   ./install-dependencies.sh --env development  # 개발 환경만
#   ./install-dependencies.sh --verify          # 설치 검증만
#
# 작성일: 2024-12-19
# 작성자: Cloud Intermediate 과정
# =============================================================================

set -euo pipefail

# =============================================================================
# 환경 설정
# =============================================================================
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$(dirname "$(dirname "$SCRIPT_DIR")")")"

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

# =============================================================================
# 사용법 출력
# =============================================================================
usage() {
    cat << EOF
Cloud Intermediate 의존성 자동 설치 스크립트

사용법:
  $0 [옵션]

옵션:
  --env <environment>    환경 설정 (development, staging, production)
  --verify              설치 검증만 수행
  --force               강제 재설치
  --help, -h            도움말 표시

예시:
  $0                                    # 전체 설치
  $0 --env development                  # 개발 환경만
  $0 --verify                          # 설치 검증만
  $0 --force                           # 강제 재설치

EOF
}

# =============================================================================
# 시스템 정보 확인
# =============================================================================
check_system_info() {
    log_header "시스템 정보 확인"
    
    # OS 정보
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        log_info "OS: $NAME $VERSION"
    else
        log_warning "OS 정보를 확인할 수 없습니다"
    fi
    
    # 아키텍처 정보
    ARCH=$(uname -m)
    log_info "아키텍처: $ARCH"
    
    # 메모리 정보
    MEMORY=$(free -h | awk '/^Mem:/ {print $2}')
    log_info "메모리: $MEMORY"
    
    # 디스크 정보
    DISK=$(df -h / | awk 'NR==2 {print $4}')
    log_info "사용 가능한 디스크: $DISK"
}

# =============================================================================
# 필수 도구 설치
# =============================================================================
install_essential_tools() {
    log_header "필수 도구 설치"
    
    # 시스템 패키지 업데이트
    log_info "시스템 패키지 업데이트 중..."
    apt-get update
    
    # 필수 도구 설치
    local tools=("curl" "wget" "git" "jq" "build-essential" "python3" "python3-pip")
    
    for tool in "${tools[@]}"; do
        log_info "$tool 설치 중..."
        apt-get install -y "$tool"
        log_success "$tool 설치 완료"
    done
    
    # yq 설치 (snap 사용)
    log_info "yq 설치 중..."
    snap install yq
    log_success "yq 설치 완료"
}

# =============================================================================
# Node.js 설치
# =============================================================================
install_nodejs() {
    log_header "Node.js 설치"
    
    # Node.js 18.x 설치
    log_info "Node.js 18.x 설치 중..."
    curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
    apt-get install -y nodejs
    
    # 버전 확인
    NODE_VERSION=$(node --version)
    NPM_VERSION=$(npm --version)
    log_success "Node.js $NODE_VERSION, npm $NPM_VERSION 설치 완료"
}

# =============================================================================
# AWS CLI 설치
# =============================================================================
install_aws_cli() {
    log_header "AWS CLI 설치"
    
    # AWS CLI v2 설치
    log_info "AWS CLI v2 설치 중..."
    curl 'https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip' -o 'awscliv2.zip'
    unzip awscliv2.zip
    ./aws/install
    
    # 정리
    rm -rf awscliv2.zip aws/
    
    # 버전 확인
    AWS_VERSION=$(aws --version)
    log_success "AWS CLI 설치 완료: $AWS_VERSION"
}

# =============================================================================
# Google Cloud CLI 설치
# =============================================================================
install_gcloud_cli() {
    log_header "Google Cloud CLI 설치"
    
    # Google Cloud SDK 설치
    log_info "Google Cloud SDK 설치 중..."
    curl https://sdk.cloud.google.com | bash
    
    # PATH에 추가
    echo 'export PATH="$HOME/google-cloud-sdk/bin:$PATH"' >> ~/.bashrc
    source ~/.bashrc
    
    # 버전 확인
    GCLOUD_VERSION=$(gcloud --version | head -n1)
    log_success "Google Cloud CLI 설치 완료: $GCLOUD_VERSION"
}

# =============================================================================
# kubectl 설치
# =============================================================================
install_kubectl() {
    log_header "kubectl 설치"
    
    # kubectl 설치
    log_info "kubectl 설치 중..."
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    chmod +x kubectl
    mv kubectl /usr/local/bin/
    
    # 버전 확인
    KUBECTL_VERSION=$(kubectl version --client --short 2>&1 | cut -d' ' -f3)
    log_success "kubectl 설치 완료: $KUBECTL_VERSION"
}

# =============================================================================
# Docker 설치
# =============================================================================
install_docker() {
    log_header "Docker 설치"
    
    # Docker 설치
    log_info "Docker 설치 중..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    
    # 사용자를 docker 그룹에 추가
    usermod -aG docker $USER
    
    # Docker Compose 설치
    log_info "Docker Compose 설치 중..."
    curl -L "https://github.com/docker/compose/releases/download/v2.20.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
    
    # 버전 확인
    DOCKER_VERSION=$(docker --version)
    COMPOSE_VERSION=$(docker-compose --version)
    log_success "Docker 설치 완료: $DOCKER_VERSION, $COMPOSE_VERSION"
}

# =============================================================================
# Helm 설치
# =============================================================================
install_helm() {
    log_header "Helm 설치"
    
    # Helm 설치
    log_info "Helm 설치 중..."
    curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
    
    # 버전 확인
    HELM_VERSION=$(helm version --short)
    log_success "Helm 설치 완료: $HELM_VERSION"
}

# =============================================================================
# 설치 검증
# =============================================================================
verify_installation() {
    log_header "설치 검증"
    
    local all_good=true
    
    # 필수 도구 검증
    local tools=("curl" "wget" "git" "jq" "yq" "node" "npm" "aws" "gcloud" "kubectl" "docker" "docker-compose" "helm")
    
    for tool in "${tools[@]}"; do
        if command -v "$tool" &> /dev/null; then
            log_success "$tool 설치됨"
        else
            log_error "$tool이 설치되지 않았습니다"
            all_good=false
        fi
    done
    
    # Docker 데몬 확인
    if docker info &> /dev/null; then
        log_success "Docker 데몬 실행 중"
    else
        log_warning "Docker 데몬이 실행되지 않음"
        all_good=false
    fi
    
    # AWS 인증 확인
    if aws sts get-caller-identity &> /dev/null; then
        log_success "AWS 인증됨"
    else
        log_warning "AWS 인증 필요"
    fi
    
    # GCP 인증 확인
    if gcloud auth list --filter=status:ACTIVE --format="value(account)" | grep -q .; then
        log_success "GCP 인증됨"
    else
        log_warning "GCP 인증 필요"
    fi
    
    if [ "$all_good" = true ]; then
        log_success "모든 의존성이 정상적으로 설치되었습니다!"
        return 0
    else
        log_error "일부 의존성 설치에 문제가 있습니다"
        return 1
    fi
}

# =============================================================================
# 환경별 설치
# =============================================================================
install_development() {
    log_header "개발 환경 의존성 설치"
    
    check_system_info
    install_essential_tools
    install_nodejs
    install_aws_cli
    install_gcloud_cli
    install_kubectl
    install_docker
    install_helm
    
    log_success "개발 환경 의존성 설치 완료"
}

install_staging() {
    log_header "스테이징 환경 의존성 설치"
    
    check_system_info
    install_essential_tools
    install_aws_cli
    install_gcloud_cli
    install_kubectl
    install_docker
    install_helm
    
    log_success "스테이징 환경 의존성 설치 완료"
}

install_production() {
    log_header "프로덕션 환경 의존성 설치"
    
    check_system_info
    install_essential_tools
    install_aws_cli
    install_gcloud_cli
    install_kubectl
    install_docker
    install_helm
    
    log_success "프로덕션 환경 의존성 설치 완료"
}

# =============================================================================
# 메인 실행 로직
# =============================================================================
main() {
    local environment="development"
    local verify_only=false
    local force=false
    
    # 명령행 인수 처리
    while [[ $# -gt 0 ]]; do
        case $1 in
            --env)
                environment="$2"
                shift 2
                ;;
            --verify)
                verify_only=true
                shift
                ;;
            --force)
                force=true
                shift
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
    
    # 검증만 수행
    if [ "$verify_only" = true ]; then
        verify_installation
        exit $?
    fi
    
    # 환경별 설치
    case "$environment" in
        development)
            install_development
            ;;
        staging)
            install_staging
            ;;
        production)
            install_production
            ;;
        *)
            log_error "알 수 없는 환경: $environment"
            exit 1
            ;;
    esac
    
    # 설치 검증
    verify_installation
}

# =============================================================================
# 스크립트 실행
# =============================================================================
main "$@"
