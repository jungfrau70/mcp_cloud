#!/bin/bash

# MCP Cloud Master - WSL 환경 체크 스크립트
# Cloud Master 과정용 WSL 환경 검증 도구
# install-all-wsl.sh와 동기화된 최신 버전

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

# 체크 결과 저장
CHECKS_PASSED=0
CHECKS_FAILED=0
TOTAL_CHECKS=0

# WSL 환경 감지
detect_wsl_environment() {
    log_header "=== WSL 환경 감지 ==="
    
    # WSL 버전 확인
    if [ -f /proc/version ]; then
        local wsl_version=$(grep -i microsoft /proc/version | wc -l)
        if [ "$wsl_version" -gt 0 ]; then
            log_success "✅ WSL 환경 감지됨"
            CHECKS_PASSED=$((CHECKS_PASSED + 1))
            
            # WSL 버전 상세 정보
            local wsl_info=$(grep -i microsoft /proc/version)
            log_wsl "WSL 정보: $wsl_info"
            
            # WSL2 확인
            if echo "$wsl_info" | grep -q "WSL2"; then
                log_success "✅ WSL2 사용 중"
                CHECKS_PASSED=$((CHECKS_PASSED + 1))
            else
                log_warning "⚠️ WSL1 사용 중 (WSL2 권장)"
                CHECKS_FAILED=$((CHECKS_FAILED + 1))
            fi
            TOTAL_CHECKS=$((TOTAL_CHECKS + 2))
        else
            log_error "❌ WSL 환경이 아닙니다"
            CHECKS_FAILED=$((CHECKS_FAILED + 1))
            TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
        fi
    else
        log_error "❌ WSL 환경을 확인할 수 없습니다"
        CHECKS_FAILED=$((CHECKS_FAILED + 1))
        TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    fi
}

# 체크 함수 - 실행 응답으로 판별
check_command() {
    local command_name="$1"
    local command="$2"
    local expected_output="$3"
    local timeout_seconds="${4:-10}"  # 기본 타임아웃 10초
    
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    
    log_info "체크 중: $command_name"
    
    # PATH에 ~/.local/bin 추가 (WSL 환경에서 사용자 bin 확인)
    export PATH="$HOME/.local/bin:$PATH"
    
    local command_found=false
    local command_type=""
    local actual_command=""
    
    # Linux 바이너리 실행 테스트
    if command -v "$command" &> /dev/null; then
        actual_command="$command"
        command_type="Linux"
        
        # 타임아웃을 사용하여 명령어 실행 테스트 (다양한 버전 확인 방법 시도)
        # 각 명령어를 개별적으로 테스트하여 더 정확한 판별
        if (timeout "$timeout_seconds" "$command" --version 2>/dev/null | head -1 >/dev/null) || \
           (timeout "$timeout_seconds" "$command" --help 2>/dev/null | head -1 >/dev/null) || \
           (timeout "$timeout_seconds" "$command" version 2>/dev/null | head -1 >/dev/null) || \
           (timeout "$timeout_seconds" "$command" -v 2>/dev/null | head -1 >/dev/null) || \
           (timeout "$timeout_seconds" "$command" -V 2>/dev/null | head -1 >/dev/null) || \
           (timeout "$timeout_seconds" "$command" 2>/dev/null | head -1 >/dev/null); then
            command_found=true
        fi
    # Windows 바이너리 실행 테스트
    elif command -v "${command}.exe" &> /dev/null; then
        actual_command="${command}.exe"
        command_type="Windows"
        
        # 타임아웃을 사용하여 명령어 실행 테스트 (다양한 버전 확인 방법 시도)
        if timeout "$timeout_seconds" "${command}.exe" --version &> /dev/null || \
           timeout "$timeout_seconds" "${command}.exe" --help &> /dev/null || \
           timeout "$timeout_seconds" "${command}.exe" version &> /dev/null || \
           timeout "$timeout_seconds" "${command}.exe" -v &> /dev/null || \
           timeout "$timeout_seconds" "${command}.exe" -V &> /dev/null; then
            command_found=true
        fi
    fi
    
    if [ "$command_found" = true ]; then
        # 예상 출력이 있는 경우 추가 검증
        if [ -n "$expected_output" ]; then
            if timeout "$timeout_seconds" $actual_command --version 2>/dev/null | grep -q "$expected_output" || \
               timeout "$timeout_seconds" $actual_command version 2>/dev/null | grep -q "$expected_output"; then
                log_success "✅ $command_name: 정상 ($command_type)"
                CHECKS_PASSED=$((CHECKS_PASSED + 1))
            else
                log_warning "⚠️ $command_name: 실행 가능하지만 예상 출력과 다름 ($command_type)"
                log_info "  실제 출력: $(timeout 5 $actual_command --version 2>/dev/null | head -1 || echo '출력 없음')"
                CHECKS_PASSED=$((CHECKS_PASSED + 1))
            fi
        else
            log_success "✅ $command_name: 실행 가능 ($command_type)"
            CHECKS_PASSED=$((CHECKS_PASSED + 1))
        fi
        
        # 명령어 버전 정보 출력 (다양한 방법 시도)
        local version_info=$(timeout 5 $actual_command --version 2>/dev/null | head -1 || \
                            timeout 5 $actual_command version 2>/dev/null | head -1 || \
                            timeout 5 $actual_command -v 2>/dev/null | head -1 || \
                            timeout 5 $actual_command -V 2>/dev/null | head -1 || \
                            echo "버전 정보 없음")
        log_info "  버전: $version_info"
    else
        log_error "❌ $command_name: 실행 불가능 또는 설치되지 않음"
        CHECKS_FAILED=$((CHECKS_FAILED + 1))
    fi
}

# WSL 네트워킹 체크
check_wsl_networking() {
    log_header "=== WSL 네트워킹 체크 ==="
    
    # 인터넷 연결 확인
    if ping -c 1 8.8.8.8 &> /dev/null; then
        log_success "✅ 인터넷 연결: 정상"
        CHECKS_PASSED=$((CHECKS_PASSED + 1))
    else
        log_error "❌ 인터넷 연결: 실패"
        CHECKS_FAILED=$((CHECKS_FAILED + 1))
    fi
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    
    # DNS 확인
    if nslookup google.com &> /dev/null; then
        log_success "✅ DNS 해석: 정상"
        CHECKS_PASSED=$((CHECKS_PASSED + 1))
    else
        log_error "❌ DNS 해석: 실패"
        CHECKS_FAILED=$((CHECKS_FAILED + 1))
    fi
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    
    # Windows 호스트 접근 확인
    if ping -c 1 $(hostname -I | awk '{print $1}') &> /dev/null; then
        log_success "✅ Windows 호스트 접근: 가능"
        CHECKS_PASSED=$((CHECKS_PASSED + 1))
    else
        log_warning "⚠️ Windows 호스트 접근: 제한적"
        CHECKS_FAILED=$((CHECKS_FAILED + 1))
    fi
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
}

# Windows 바이너리 실행 확인
check_windows_binaries() {
    log_header "=== Windows 바이너리 실행 확인 ==="
    
    # Windows PowerShell 실행 확인
    if command -v powershell.exe &> /dev/null; then
        log_success "✅ PowerShell: 실행 가능"
        CHECKS_PASSED=$((CHECKS_PASSED + 1))
    else
        log_warning "⚠️ PowerShell: 실행 불가"
        CHECKS_FAILED=$((CHECKS_FAILED + 1))
    fi
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    
    # Windows 명령어 실행 확인
    if command -v cmd.exe &> /dev/null; then
        log_success "✅ CMD: 실행 가능"
        CHECKS_PASSED=$((CHECKS_PASSED + 1))
    else
        log_warning "⚠️ CMD: 실행 불가"
        CHECKS_FAILED=$((CHECKS_FAILED + 1))
    fi
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
}

# AWS CLI 체크 (WSL 특화) - 실행 응답으로 판별
check_aws_cli() {
    log_header "=== AWS CLI 환경 체크 (WSL) ==="
    
    # AWS CLI 실행 테스트
    local aws_cmd=""
    local aws_type=""
    
    if command -v aws &> /dev/null && timeout 10 aws --version &> /dev/null; then
        aws_cmd="aws"
        aws_type="Linux"
        log_success "✅ AWS CLI: 실행 가능 ($aws_type)"
        CHECKS_PASSED=$((CHECKS_PASSED + 1))
    elif command -v aws.exe &> /dev/null && timeout 10 aws.exe --version &> /dev/null; then
        aws_cmd="aws.exe"
        aws_type="Windows"
        log_success "✅ AWS CLI: 실행 가능 ($aws_type)"
        CHECKS_PASSED=$((CHECKS_PASSED + 1))
    else
        log_error "❌ AWS CLI: 실행 불가능 또는 설치되지 않음"
        CHECKS_FAILED=$((CHECKS_FAILED + 1))
    fi
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    
    if [ -n "$aws_cmd" ]; then
        # AWS CLI 버전 정보 출력
        local aws_version=$(timeout 5 $aws_cmd --version 2>/dev/null | head -1)
        log_info "  버전: $aws_version"
        
        # AWS 자격증명 확인
        log_info "AWS 자격증명 확인 중..."
        if timeout 15 $aws_cmd sts get-caller-identity &> /dev/null; then
            log_success "✅ AWS 자격증명: 설정됨"
            CHECKS_PASSED=$((CHECKS_PASSED + 1))
        else
            log_error "❌ AWS 자격증명: 설정되지 않음"
            log_warning "다음 명령어로 설정하세요: $aws_cmd configure"
            CHECKS_FAILED=$((CHECKS_FAILED + 1))
        fi
        TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
        
        # AWS CLI 설정 파일 위치 확인
        local aws_config_dir="$HOME/.aws"
        if [ -d "$aws_config_dir" ]; then
            log_success "✅ AWS 설정 디렉토리: $aws_config_dir"
            CHECKS_PASSED=$((CHECKS_PASSED + 1))
        else
            log_warning "⚠️ AWS 설정 디렉토리: 없음"
            CHECKS_FAILED=$((CHECKS_FAILED + 1))
        fi
        TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    fi
}

# GCP CLI 체크 (WSL 특화) - 실행 응답으로 판별
check_gcp_cli() {
    log_header "=== GCP CLI 환경 체크 (WSL) ==="
    
    # GCP CLI 실행 테스트
    local gcloud_cmd=""
    local gcloud_type=""
    
    # GCP CLI 실행 테스트 (다양한 경로에서 확인)
    if command -v gcloud &> /dev/null && timeout 10 gcloud --version &> /dev/null; then
        gcloud_cmd="gcloud"
        gcloud_type="Linux"
        log_success "✅ GCP CLI: 실행 가능 ($gcloud_type)"
        CHECKS_PASSED=$((CHECKS_PASSED + 1))
    elif command -v gcloud.exe &> /dev/null && timeout 10 gcloud.exe --version &> /dev/null; then
        gcloud_cmd="gcloud.exe"
        gcloud_type="Windows"
        log_success "✅ GCP CLI: 실행 가능 ($gcloud_type)"
        CHECKS_PASSED=$((CHECKS_PASSED + 1))
    elif [ -f "/mnt/c/Program Files (x86)/Google/Cloud SDK/google-cloud-sdk/bin/gcloud.cmd" ] && timeout 10 "/mnt/c/Program Files (x86)/Google/Cloud SDK/google-cloud-sdk/bin/gcloud.cmd" --version &> /dev/null; then
        gcloud_cmd="/mnt/c/Program Files (x86)/Google/Cloud SDK/google-cloud-sdk/bin/gcloud.cmd"
        gcloud_type="Windows (cmd)"
        log_success "✅ GCP CLI: 실행 가능 ($gcloud_type)"
        CHECKS_PASSED=$((CHECKS_PASSED + 1))
    elif [ -f "/mnt/c/Users/JIH/AppData/Local/Google/Cloud SDK/google-cloud-sdk/bin/gcloud.cmd" ] && timeout 10 "/mnt/c/Users/JIH/AppData/Local/Google/Cloud SDK/google-cloud-sdk/bin/gcloud.cmd" --version &> /dev/null; then
        gcloud_cmd="/mnt/c/Users/JIH/AppData/Local/Google/Cloud SDK/google-cloud-sdk/bin/gcloud.cmd"
        gcloud_type="Windows (user)"
        log_success "✅ GCP CLI: 실행 가능 ($gcloud_type)"
        CHECKS_PASSED=$((CHECKS_PASSED + 1))
    else
        log_error "❌ GCP CLI: 실행 불가능 또는 설치되지 않음"
        CHECKS_FAILED=$((CHECKS_FAILED + 1))
    fi
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    
    if [ -n "$gcloud_cmd" ]; then
        # GCP CLI 버전 정보 출력
        local gcloud_version=$(timeout 5 $gcloud_cmd --version 2>/dev/null | head -1)
        log_info "  버전: $gcloud_version"
        
        # GCP 인증 확인
        log_info "GCP 인증 확인 중..."
        if timeout 15 $gcloud_cmd auth list --filter=status:ACTIVE --format="value(account)" 2>/dev/null | grep -q .; then
            log_success "✅ GCP 인증: 설정됨"
            CHECKS_PASSED=$((CHECKS_PASSED + 1))
        else
            log_error "❌ GCP 인증: 설정되지 않음"
            log_warning "다음 명령어로 설정하세요: $gcloud_cmd auth login"
            CHECKS_FAILED=$((CHECKS_FAILED + 1))
        fi
        TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
        
        # GCP 설정 확인
        local gcp_config_dir="$HOME/.config/gcloud"
        if [ -d "$gcp_config_dir" ]; then
            log_success "✅ GCP 설정 디렉토리: $gcp_config_dir"
            CHECKS_PASSED=$((CHECKS_PASSED + 1))
        else
            log_warning "⚠️ GCP 설정 디렉토리: 없음"
            CHECKS_FAILED=$((CHECKS_FAILED + 1))
        fi
        TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    fi
}

# Docker 체크 (WSL 특화) - 실행 응답으로 판별
check_docker() {
    log_header "=== Docker 환경 체크 (WSL) ==="
    
    # Docker 명령어 실행 테스트
    local docker_cmd=""
    local docker_type=""
    
    if command -v docker &> /dev/null && timeout 10 docker --version &> /dev/null; then
        docker_cmd="docker"
        docker_type="Linux"
        log_success "✅ Docker: 실행 가능 ($docker_type)"
        CHECKS_PASSED=$((CHECKS_PASSED + 1))
    elif command -v docker.exe &> /dev/null && timeout 10 docker.exe --version &> /dev/null; then
        docker_cmd="docker.exe"
        docker_type="Windows"
        log_success "✅ Docker: 실행 가능 ($docker_type)"
        CHECKS_PASSED=$((CHECKS_PASSED + 1))
    else
        log_error "❌ Docker: 실행 불가능 또는 설치되지 않음"
        CHECKS_FAILED=$((CHECKS_FAILED + 1))
    fi
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    
    # Docker Compose 명령어 실행 테스트
    local compose_cmd=""
    local compose_type=""
    
    if command -v docker-compose &> /dev/null && timeout 10 docker-compose --version &> /dev/null; then
        compose_cmd="docker-compose"
        compose_type="Linux"
        log_success "✅ Docker Compose: 실행 가능 ($compose_type)"
        CHECKS_PASSED=$((CHECKS_PASSED + 1))
    elif command -v docker-compose.exe &> /dev/null && timeout 10 docker-compose.exe --version &> /dev/null; then
        compose_cmd="docker-compose.exe"
        compose_type="Windows"
        log_success "✅ Docker Compose: 실행 가능 ($compose_type)"
        CHECKS_PASSED=$((CHECKS_PASSED + 1))
    else
        log_warning "⚠️ Docker Compose: 실행 불가능 또는 설치되지 않음"
        CHECKS_FAILED=$((CHECKS_FAILED + 1))
    fi
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    
    # Docker 서비스 상태 확인 (실행 응답으로 판별)
    if [ -n "$docker_cmd" ]; then
        log_info "Docker 서비스 상태 확인 중..."
        
                # WSL Docker Engine 확인 (Docker Desktop 사용 안 함)
                log_info "WSL Docker Engine 확인 중..."

                # docker info 명령어로 실제 연결 상태 확인
                if timeout 15 $docker_cmd info &> /dev/null; then
                    log_success "✅ Docker Engine: 실행 중"
                    CHECKS_PASSED=$((CHECKS_PASSED + 1))
                else
                    log_warning "⚠️ Docker Engine: 실행되지 않음"
                    log_warning "다음 명령어로 시작하세요:"
                    log_warning "  start-docker  # 자동 시작 스크립트 사용"
                    log_warning "  # 또는 수동으로: sudo dockerd &"
                    CHECKS_FAILED=$((CHECKS_FAILED + 1))
                fi
        TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
        
        # Docker 컨테이너 실행 테스트 (실제 컨테이너 실행으로 확인)
        log_info "Docker 컨테이너 실행 테스트 중..."
        if timeout 30 $docker_cmd run --rm hello-world &> /dev/null; then
            log_success "✅ Docker 컨테이너: 실행 가능"
            CHECKS_PASSED=$((CHECKS_PASSED + 1))
        else
            log_error "❌ Docker 컨테이너: 실행 실패"
            log_warning "Docker 권한 문제일 수 있습니다. 다음을 확인하세요:"
            log_warning "  - 사용자가 docker 그룹에 속해 있는지 확인"
            log_warning "  - 'newgrp docker' 실행 후 재시도"
            log_warning "  - WSL 재시작: wsl --shutdown && wsl"
            CHECKS_FAILED=$((CHECKS_FAILED + 1))
        fi
        TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
        
        # Docker Compose 사용자 bin 실행 테스트
        if [ -f "$HOME/.local/bin/docker-compose" ] && timeout 10 "$HOME/.local/bin/docker-compose" --version &> /dev/null; then
            log_success "✅ Docker Compose (사용자 bin): 실행 가능"
            CHECKS_PASSED=$((CHECKS_PASSED + 1))
        else
            log_warning "⚠️ Docker Compose (사용자 bin): 없음 또는 실행 불가"
            log_warning "Docker Compose가 사용자 bin에 설치되지 않았습니다."
            CHECKS_FAILED=$((CHECKS_FAILED + 1))
        fi
        TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    fi
}

# Git 체크 (WSL 특화) - 실행 응답으로 판별
check_git() {
    log_header "=== Git 환경 체크 (WSL) ==="
    
    # Git 실행 테스트
    local git_cmd=""
    local git_type=""
    
    if command -v git &> /dev/null && timeout 10 git --version &> /dev/null; then
        git_cmd="git"
        git_type="Linux"
        log_success "✅ Git: 실행 가능 ($git_type)"
        CHECKS_PASSED=$((CHECKS_PASSED + 1))
    else
        log_error "❌ Git: 실행 불가능 또는 설치되지 않음"
        CHECKS_FAILED=$((CHECKS_FAILED + 1))
    fi
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    
    if [ -n "$git_cmd" ]; then
        # Git 버전 정보 출력
        local git_version=$(timeout 5 $git_cmd --version 2>/dev/null)
        log_info "  Git 버전: $git_version"
        
        # Git 설정 확인
        log_info "Git 설정 확인 중..."
        if timeout 5 $git_cmd config --global user.name &> /dev/null && timeout 5 $git_cmd config --global user.email &> /dev/null; then
            log_success "✅ Git 설정: 완료됨"
            log_info "  사용자명: $(timeout 5 $git_cmd config --global user.name 2>/dev/null)"
            log_info "  이메일: $(timeout 5 $git_cmd config --global user.email 2>/dev/null)"
            CHECKS_PASSED=$((CHECKS_PASSED + 1))
        else
            log_warning "⚠️ Git 설정: 사용자 정보가 설정되지 않음"
            log_warning "다음 명령어로 설정하세요:"
            log_warning "  git config --global user.name 'Your Name'"
            log_warning "  git config --global user.email 'your.email@example.com'"
            CHECKS_FAILED=$((CHECKS_FAILED + 1))
        fi
        TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
        
        # Git SSH 키 확인
        local ssh_key="$HOME/.ssh/id_rsa.pub"
        if [ -f "$ssh_key" ]; then
            log_success "✅ SSH 키: 존재함 ($ssh_key)"
            CHECKS_PASSED=$((CHECKS_PASSED + 1))
        else
            log_warning "⚠️ SSH 키: 없음"
            log_warning "다음 명령어로 생성하세요: ssh-keygen -t rsa -b 4096 -C 'your.email@example.com'"
            CHECKS_FAILED=$((CHECKS_FAILED + 1))
        fi
        TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    fi
}

# Kubernetes 체크 (WSL 특화)
check_kubernetes() {
    log_header "=== Kubernetes 환경 체크 (WSL) ==="
    
    check_command "kubectl" "kubectl version --client" "Client Version"
    
    if command -v kubectl &> /dev/null; then
        log_info "Kubernetes 클러스터 연결 확인 중..."
        if kubectl cluster-info &> /dev/null; then
            log_success "✅ Kubernetes 클러스터: 연결됨"
            CHECKS_PASSED=$((CHECKS_PASSED + 1))
        else
            log_warning "⚠️ Kubernetes 클러스터: 연결되지 않음"
            log_warning "다음 중 하나를 실행하세요:"
            log_warning "  - minikube start"
            log_warning "  - kind create cluster"
            log_warning "  - Docker Desktop Kubernetes 활성화"
            CHECKS_FAILED=$((CHECKS_FAILED + 1))
        fi
        TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    fi
}

# Terraform 체크 (WSL 특화) - 실행 응답으로 판별
check_terraform() {
    log_header "=== Terraform 환경 체크 (WSL) ==="
    
    # Terraform 실행 테스트 (--version 대신 version 서브커맨드 사용)
    local terraform_cmd=""
    local terraform_type=""
    
    if command -v terraform &> /dev/null && timeout 10 terraform version &> /dev/null; then
        terraform_cmd="terraform"
        terraform_type="Linux"
        log_success "✅ Terraform: 실행 가능 ($terraform_type)"
        CHECKS_PASSED=$((CHECKS_PASSED + 1))
    else
        log_error "❌ Terraform: 실행 불가능 또는 설치되지 않음"
        CHECKS_FAILED=$((CHECKS_FAILED + 1))
    fi
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    
    if [ -n "$terraform_cmd" ]; then
        # Terraform 버전 정보 출력
        local terraform_version=$(timeout 5 $terraform_cmd version 2>/dev/null | head -1)
        log_info "  버전: $terraform_version"
        
        # Terraform 작업 디렉토리 확인
        if [ -d "$HOME/.terraform.d" ]; then
            log_success "✅ Terraform 설정 디렉토리: $HOME/.terraform.d"
            CHECKS_PASSED=$((CHECKS_PASSED + 1))
        else
            log_warning "⚠️ Terraform 설정 디렉토리: 없음"
            CHECKS_FAILED=$((CHECKS_FAILED + 1))
        fi
        TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    fi
}

# Node.js 체크 (WSL 특화) - 실행 응답으로 판별
check_nodejs() {
    log_header "=== Node.js 환경 체크 (WSL) ==="
    
    # Node.js 실행 테스트
    local node_cmd=""
    local node_type=""
    
    if command -v node &> /dev/null && timeout 10 node --version &> /dev/null; then
        node_cmd="node"
        node_type="Linux"
        log_success "✅ Node.js: 실행 가능 ($node_type)"
        CHECKS_PASSED=$((CHECKS_PASSED + 1))
    else
        log_error "❌ Node.js: 실행 불가능 또는 설치되지 않음"
        CHECKS_FAILED=$((CHECKS_FAILED + 1))
    fi
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    
    # npm 실행 테스트
    local npm_cmd=""
    if command -v npm &> /dev/null && timeout 10 npm --version &> /dev/null; then
        npm_cmd="npm"
        log_success "✅ npm: 실행 가능"
        CHECKS_PASSED=$((CHECKS_PASSED + 1))
    else
        log_warning "⚠️ npm: 실행 불가능 또는 설치되지 않음"
        CHECKS_FAILED=$((CHECKS_FAILED + 1))
    fi
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    
    if [ -n "$node_cmd" ]; then
        # Node.js 버전 정보 출력
        local node_version=$(timeout 5 $node_cmd --version 2>/dev/null)
        log_info "  Node.js 버전: $node_version"
        
        # npm 버전 정보 출력
        if [ -n "$npm_cmd" ]; then
            local npm_version=$(timeout 5 $npm_cmd --version 2>/dev/null)
            log_info "  npm 버전: $npm_version"
            
            # npm 글로벌 패키지 확인
            log_info "npm 글로벌 패키지 확인 중..."
            if timeout 15 $npm_cmd list -g --depth=0 &> /dev/null; then
                log_success "✅ npm 글로벌 패키지: 정상"
                CHECKS_PASSED=$((CHECKS_PASSED + 1))
            else
                log_warning "⚠️ npm 글로벌 패키지: 확인 실패"
                CHECKS_FAILED=$((CHECKS_FAILED + 1))
            fi
            TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
        fi
    fi
}

# Python 체크 (WSL 특화) - 실행 응답으로 판별
check_python() {
    log_header "=== Python 환경 체크 (WSL) ==="
    
    # Python3 실행 테스트
    local python_cmd=""
    local python_type=""
    
    if command -v python3 &> /dev/null && timeout 10 python3 --version &> /dev/null; then
        python_cmd="python3"
        python_type="Linux"
        log_success "✅ Python3: 실행 가능 ($python_type)"
        CHECKS_PASSED=$((CHECKS_PASSED + 1))
    elif command -v python &> /dev/null && timeout 10 python --version &> /dev/null; then
        python_cmd="python"
        python_type="Linux"
        log_success "✅ Python: 실행 가능 ($python_type)"
        CHECKS_PASSED=$((CHECKS_PASSED + 1))
    else
        log_error "❌ Python: 실행 불가능 또는 설치되지 않음"
        CHECKS_FAILED=$((CHECKS_FAILED + 1))
    fi
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    
    # pip 실행 테스트
    local pip_cmd=""
    if command -v pip3 &> /dev/null && timeout 10 pip3 --version &> /dev/null; then
        pip_cmd="pip3"
        log_success "✅ pip3: 실행 가능"
        CHECKS_PASSED=$((CHECKS_PASSED + 1))
    elif command -v pip &> /dev/null && timeout 10 pip --version &> /dev/null; then
        pip_cmd="pip"
        log_success "✅ pip: 실행 가능"
        CHECKS_PASSED=$((CHECKS_PASSED + 1))
    else
        log_warning "⚠️ pip: 실행 불가능 또는 설치되지 않음"
        log_warning "다음 명령어로 설치하세요: sudo apt install python3-pip"
        CHECKS_FAILED=$((CHECKS_FAILED + 1))
    fi
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    
    if [ -n "$python_cmd" ]; then
        # Python 버전 정보 출력
        local python_version=$(timeout 5 $python_cmd --version 2>/dev/null)
        log_info "  Python 버전: $python_version"
        
        # pip 버전 정보 출력
        if [ -n "$pip_cmd" ]; then
            local pip_version=$(timeout 5 $pip_cmd --version 2>/dev/null | head -1)
            log_info "  pip 버전: $pip_version"
        fi
        
        # Python 가상환경 확인
        log_info "Python 가상환경 확인 중..."
        if timeout 10 $python_cmd -m venv --help &> /dev/null; then
            log_success "✅ Python 가상환경: 지원됨"
            CHECKS_PASSED=$((CHECKS_PASSED + 1))
        else
            log_warning "⚠️ Python 가상환경: 지원되지 않음"
            CHECKS_FAILED=$((CHECKS_FAILED + 1))
        fi
        TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    fi
}

# Helm 체크 (WSL 특화) - 실행 응답으로 판별
check_helm() {
    log_header "=== Helm 환경 체크 (WSL) ==="
    
    # Helm 명령어 실행 테스트 (--version 대신 version 사용)
    if command -v helm &> /dev/null && timeout 10 helm version &> /dev/null; then
        log_success "✅ Helm: 실행 가능"
        CHECKS_PASSED=$((CHECKS_PASSED + 1))
        
        # Helm 버전 정보 출력
        local helm_version=$(timeout 5 helm version --short 2>/dev/null || timeout 5 helm version 2>/dev/null | head -1)
        log_info "  버전: $helm_version"
        
        # Helm 저장소 확인 (실행 응답으로 판별)
        log_info "Helm 저장소 확인 중..."
        if timeout 10 helm repo list &> /dev/null; then
            log_success "✅ Helm 저장소: 정상"
            CHECKS_PASSED=$((CHECKS_PASSED + 1))
        else
            log_warning "⚠️ Helm 저장소: 확인 실패"
            CHECKS_FAILED=$((CHECKS_FAILED + 1))
        fi
        TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    else
        log_error "❌ Helm: 실행 불가능 또는 설치되지 않음"
        CHECKS_FAILED=$((CHECKS_FAILED + 1))
    fi
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
}

# WSL 파일 시스템 체크
check_wsl_filesystem() {
    log_header "=== WSL 파일 시스템 체크 ==="
    
    # WSL 파일 시스템 마운트 확인
    if mount | grep -q "9p"; then
        log_success "✅ WSL 파일 시스템: 마운트됨"
        CHECKS_PASSED=$((CHECKS_PASSED + 1))
    else
        log_warning "⚠️ WSL 파일 시스템: 9p 마운트 없음"
        CHECKS_FAILED=$((CHECKS_FAILED + 1))
    fi
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    
    # Windows 드라이브 접근 확인
    if [ -d "/mnt/c" ]; then
        log_success "✅ Windows C 드라이브: 접근 가능"
        CHECKS_PASSED=$((CHECKS_PASSED + 1))
    else
        log_warning "⚠️ Windows C 드라이브: 접근 불가"
        CHECKS_FAILED=$((CHECKS_FAILED + 1))
    fi
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    
    # 홈 디렉토리 확인
    if [ -d "$HOME" ] && [ -w "$HOME" ]; then
        log_success "✅ 홈 디렉토리: 접근 가능 ($HOME)"
        CHECKS_PASSED=$((CHECKS_PASSED + 1))
    else
        log_error "❌ 홈 디렉토리: 접근 불가 ($HOME)"
        CHECKS_FAILED=$((CHECKS_FAILED + 1))
    fi
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
}

# 시스템 리소스 체크 (WSL 특화)
check_system_resources() {
    log_header "=== 시스템 리소스 체크 (WSL) ==="
    
    # 메모리 체크
    if command -v free &> /dev/null; then
        local available_memory=$(free -m | awk 'NR==2{printf "%.0f", $7}')
        if [ "$available_memory" -gt 2048 ]; then
            log_success "✅ 사용 가능한 메모리: ${available_memory}MB"
            CHECKS_PASSED=$((CHECKS_PASSED + 1))
        else
            log_warning "⚠️ 사용 가능한 메모리: ${available_memory}MB (권장: 2GB 이상)"
            log_warning "Docker Desktop에서 WSL2 메모리 할당을 늘려보세요"
            CHECKS_FAILED=$((CHECKS_FAILED + 1))
        fi
        TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    fi
    
    # 디스크 공간 체크
    local available_space=$(df -BG . | awk 'NR==2{print $4}' | sed 's/G//')
    if [ "$available_space" -gt 10 ]; then
        log_success "✅ 사용 가능한 디스크 공간: ${available_space}GB"
        CHECKS_PASSED=$((CHECKS_PASSED + 1))
    else
        log_warning "⚠️ 사용 가능한 디스크 공간: ${available_space}GB (권장: 10GB 이상)"
        log_warning "WSL2 디스크 공간을 늘리거나 정리하세요"
        CHECKS_FAILED=$((CHECKS_FAILED + 1))
    fi
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    
    # CPU 코어 수 확인
    local cpu_cores=$(nproc)
    if [ "$cpu_cores" -ge 2 ]; then
        log_success "✅ CPU 코어 수: ${cpu_cores}개"
        CHECKS_PASSED=$((CHECKS_PASSED + 1))
    else
        log_warning "⚠️ CPU 코어 수: ${cpu_cores}개 (권장: 2개 이상)"
        CHECKS_FAILED=$((CHECKS_FAILED + 1))
    fi
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
}

# WSL 특화 권장사항
print_wsl_recommendations() {
    log_header "=== WSL 최적화 권장사항 ==="
    
    echo ""
    log_wsl "🔧 WSL2 최적화 설정:"
    log_wsl "  1. .wslconfig 파일 생성 (Windows 사용자 홈 디렉토리):"
    log_wsl "     [wsl2]"
    log_wsl "     memory=8GB"
    log_wsl "     processors=4"
    log_wsl "     swap=2GB"
    log_wsl "     localhostForwarding=true"
    log_wsl ""
    log_wsl "  2. Docker Engine 설정 (WSL):"
    log_wsl "     - WSL2에서 Docker Engine 직접 실행"
    log_wsl "     - sudo dockerd & 명령어로 Docker 데몬 시작"
    log_wsl "     - 사용자를 docker 그룹에 추가: sudo usermod -aG docker \$USER"
    log_wsl ""
    log_wsl "  3. Windows Terminal 사용 권장:"
    log_wsl "     - Microsoft Store에서 Windows Terminal 설치"
    log_wsl "     - WSL2 프로필 설정"
    log_wsl "     - PowerShell 7 설치 권장"
    log_wsl ""
    log_wsl "  4. 파일 시스템 성능 최적화:"
    log_wsl "     - WSL2 파일 시스템 사용 (Linux 파일 시스템)"
    log_wsl "     - Windows 파일 시스템 접근 최소화"
    log_wsl "     - 작업 디렉토리를 WSL 파일 시스템에 생성"
    log_wsl ""
    log_wsl "  5. 환경 변수 최적화:"
    log_wsl "     - ~/.bashrc에 MCP Cloud Master 환경 설정 추가"
    log_wsl "     - PATH에 ~/.local/bin 추가"
    log_wsl "     - Docker 및 kubectl 사용자 bin 경로 설정"
    log_wsl ""
    log_wsl "  6. 네트워킹 최적화:"
    log_wsl "     - Windows 방화벽에서 WSL2 허용"
    log_wsl "     - localhostForwarding=true 설정"
    log_wsl "     - DNS 설정 최적화"
}

# 결과 요약
print_summary() {
    log_header "=== WSL 환경 체크 결과 요약 ==="
    
    echo ""
    echo "📊 체크 결과:"
    echo "  ✅ 통과: $CHECKS_PASSED"
    echo "  ❌ 실패: $CHECKS_FAILED"
    echo "  📋 전체: $TOTAL_CHECKS"
    echo ""
    
    local success_rate=$((CHECKS_PASSED * 100 / TOTAL_CHECKS))
    
    if [ "$success_rate" -ge 90 ]; then
        log_success "🎉 WSL 환경 체크 통과! (${success_rate}%)"
        echo ""
        log_info "실습을 시작할 준비가 완료되었습니다!"
        log_wsl "WSL2 환경에서 최적의 성능을 위해 권장사항을 확인하세요."
    elif [ "$success_rate" -ge 70 ]; then
        log_warning "⚠️ WSL 환경 체크 부분 통과 (${success_rate}%)"
        echo ""
        log_warning "일부 실습에 제한이 있을 수 있습니다."
        log_warning "실패한 항목을 수정한 후 다시 실행하세요."
    else
        log_error "❌ WSL 환경 체크 실패 (${success_rate}%)"
        echo ""
        log_error "실습을 시작하기 전에 실패한 항목을 수정해야 합니다."
        log_error "WSL 설정을 확인하고 필요한 도구를 설치하세요."
    fi
    
    echo ""
    log_info "📚 MCP Cloud Master 설치 가이드:"
    log_info "  - 전체 설치: ~/mcp_knowledge_base/cloud_master/repos/install/install-all-wsl.sh"
    log_info "  - Docker WSL2: ~/mcp_knowledge_base/cloud_master/repos/install/docker-user-guide-on-wsl.md"
    log_info "  - AWS CLI: ~/mcp_knowledge_base/cloud_master/textbook/Day1/guides/install_aws_cli.md"
    log_info "  - GCP CLI: ~/mcp_knowledge_base/cloud_master/textbook/Day1/guides/install_gcp_cli.md"
    log_info "  - 환경 체크: ~/mcp_knowledge_base/cloud_master/repos/cloud-scripts/environment-check-wsl.sh"
    
    echo ""
    log_info "🔧 문제 해결 가이드:"
    log_info "  - Docker 문제: start-docker 명령어 사용"
    log_info "  - 권한 문제: newgrp docker 실행"
    log_info "  - WSL 재시작: wsl --shutdown && wsl"
    log_info "  - 환경 설정: source ~/.bashrc"
    
    # WSL 특화 권장사항 출력
    print_wsl_recommendations
}

# 메인 실행
main() {
    log_header "🚀 MCP Cloud Master WSL 환경 체크 시작"
    echo ""
    log_info "체크 시간: $(date)"
    log_info "WSL 배포판: $(lsb_release -d 2>/dev/null | cut -f2 || echo '알 수 없음')"
    
    # PATH 설정 (WSL 환경에서 사용자 bin 경로 추가)
    export PATH="$HOME/.local/bin:$PATH"
    
    # Windows PATH에서 도구들 확인 및 추가
    # 실제 PATH에서 확인된 경로들을 추가
    export PATH="$PATH:/mnt/c/Program Files/Amazon/AWSCLIV2"
    export PATH="$PATH:/mnt/c/Program Files (x86)/Google/Cloud SDK/google-cloud-sdk/bin"
    export PATH="$PATH:/mnt/c/Users/JIH/AppData/Local/Google/Cloud SDK/google-cloud-sdk/bin"
    export PATH="$PATH:/mnt/c/Program Files/Docker/Docker/resources/bin"
    export PATH="$PATH:/mnt/c/Users/JIH/AppData/Local/Microsoft/WinGet/Packages/Kubernetes.kubectl_Microsoft.Winget.Source_8wekyb3d8bbwe/windows-amd64"
    export PATH="$PATH:/mnt/c/Users/JIH/AppData/Local/Microsoft/WinGet/Packages/Helm.Helm_Microsoft.Winget.Source_8wekyb3d8bbwe/windows-amd64"
    
    log_info "PATH 설정: $PATH"
    echo ""
    
    # WSL 환경 감지
    detect_wsl_environment
    
    # WSL 특화 체크
    check_wsl_networking
    check_windows_binaries
    check_wsl_filesystem
    
    # 기본 도구 체크
    check_docker
    check_git
    check_aws_cli
    check_gcp_cli
    
    # 개발 도구 체크
    check_terraform
    check_nodejs
    check_python
    check_helm
    
    # Day별 추가 체크
    if [ "$1" = "day2" ] || [ "$1" = "day3" ]; then
        check_kubernetes
    fi
    
    # 시스템 리소스 체크
    check_system_resources
    
    # 결과 요약
    print_summary
}

# 스크립트 실행
main "$@"
