#!/bin/bash

# Cloud Master WSL 환경 통합 설정 스크립트
# 모든 WSL 환경 설정을 한 번에 실행하는 통합 스크립트

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# 로그 함수들
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_header() { echo -e "${PURPLE}=== $1 ===${NC}"; }

# 진행 상태 표시
show_progress() {
    local current=$1
    local total=$2
    local description=$3
    local percent=$((current * 100 / total))
    printf "\r${CYAN}[%d/%d] %s... %d%%${NC}" "$current" "$total" "$description" "$percent"
}

# WSL 환경 체크
check_wsl_environment() {
    log_header "WSL 환경 체크"
    
    # WSL 버전 확인
    log_info "WSL 버전 확인 중..."
    if command -v wsl &> /dev/null; then
        WSL_VERSION=$(wsl --version 2>/dev/null | head -1)
        log_success "WSL 설치됨: $WSL_VERSION"
    else
        log_error "WSL이 설치되지 않았습니다"
        log_info "설치 방법: wsl --install"
        return 1
    fi
    
    # 현재 배포판 확인
    log_info "현재 배포판 확인 중..."
    DISTRO=$(cat /etc/os-release | grep "^NAME=" | cut -d'"' -f2)
    log_success "배포판: $DISTRO"
    
    # 사용자 확인
    log_info "현재 사용자: $(whoami)"
    
    # 디렉토리 확인
    log_info "현재 디렉토리: $(pwd)"
    
    return 0
}

# 기본 패키지 업데이트
update_system() {
    log_header "시스템 업데이트"
    
    log_info "패키지 목록 업데이트 중..."
    sudo apt update -y
    
    log_info "시스템 업그레이드 중..."
    sudo apt upgrade -y
    
    log_info "필수 패키지 설치 중..."
    sudo apt install -y curl wget git jq unzip vim nano htop tree
    
    log_success "시스템 업데이트 완료"
}

# AWS CLI 설치
install_aws_cli() {
    log_header "AWS CLI 설치"
    
    if command -v aws &> /dev/null; then
        log_info "AWS CLI가 이미 설치되어 있습니다"
        aws --version
        return 0
    fi
    
    log_info "AWS CLI v2 설치 중..."
    
    # AWS CLI 다운로드 및 설치
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    sudo ./aws/install
    
    # 정리
    rm -rf aws awscliv2.zip
    
    if command -v aws &> /dev/null; then
        log_success "AWS CLI 설치 완료"
        aws --version
    else
        log_error "AWS CLI 설치 실패"
        return 1
    fi
}

# GCP CLI 설치
install_gcp_cli() {
    log_header "GCP CLI 설치"
    
    if command -v gcloud &> /dev/null; then
        log_info "GCP CLI가 이미 설치되어 있습니다"
        gcloud --version
        return 0
    fi
    
    log_info "Google Cloud SDK 설치 중..."
    
    # GCP CLI 설치
    curl https://sdk.cloud.google.com | bash
    
    # PATH에 추가
    echo 'export PATH="$HOME/google-cloud-sdk/bin:$PATH"' >> ~/.bashrc
    source ~/.bashrc
    
    if command -v gcloud &> /dev/null; then
        log_success "GCP CLI 설치 완료"
        gcloud --version
    else
        log_error "GCP CLI 설치 실패"
        return 1
    fi
}

# Docker 설치
install_docker() {
    log_header "Docker 설치"
    
    if command -v docker &> /dev/null; then
        log_info "Docker가 이미 설치되어 있습니다"
        docker --version
        return 0
    fi
    
    log_info "Docker 설치 중..."
    
    # Docker 설치
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    
    # 사용자를 docker 그룹에 추가
    sudo usermod -aG docker $USER
    
    # Docker Compose 설치
    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    
    # 정리
    rm get-docker.sh
    
    if command -v docker &> /dev/null; then
        log_success "Docker 설치 완료"
        docker --version
        docker-compose --version
    else
        log_error "Docker 설치 실패"
        return 1
    fi
}

# Git 설정
setup_git() {
    log_header "Git 설정"
    
    if command -v git &> /dev/null; then
        log_info "Git이 이미 설치되어 있습니다"
        git --version
    else
        log_info "Git 설치 중..."
        sudo apt install -y git
    fi
    
    # Git 설정 확인
    if [ -z "$(git config --global user.name)" ]; then
        log_warning "Git 사용자 이름이 설정되지 않았습니다"
        read -p "Git 사용자 이름을 입력하세요: " git_username
        git config --global user.name "$git_username"
    fi
    
    if [ -z "$(git config --global user.email)" ]; then
        log_warning "Git 이메일이 설정되지 않았습니다"
        read -p "Git 이메일을 입력하세요: " git_email
        git config --global user.email "$git_email"
    fi
    
    log_success "Git 설정 완료"
    git config --global --list | grep user
}

# 환경 변수 설정
setup_environment_variables() {
    log_header "환경 변수 설정"
    
    # .bashrc에 유용한 별칭 추가
    cat >> ~/.bashrc << 'EOF'

# Cloud Master 환경 변수
export EDITOR=vim
export AWS_DEFAULT_REGION=ap-northeast-2
export AWS_DEFAULT_OUTPUT=json

# 유용한 별칭
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# Cloud Master 별칭
alias aws-list-instances='aws ec2 describe-instances --query "Reservations[*].Instances[*].[InstanceId,State.Name,PublicIpAddress,Tags[?Key==\`Name\`].Value|[0]]" --output table'
alias gcp-list-instances='gcloud compute instances list --format="table(name,zone,status,EXTERNAL_IP,INTERNAL_IP)"'
alias docker-clean='docker system prune -f && docker volume prune -f'
EOF
    
    log_success "환경 변수 설정 완료"
    log_info "새 터미널을 열거나 'source ~/.bashrc'를 실행하세요"
}

# 최종 환경 체크
final_environment_check() {
    log_header "최종 환경 체크"
    
    local checks=0
    local total_checks=6
    
    # AWS CLI 체크
    show_progress 1 $total_checks "AWS CLI 체크"
    if command -v aws &> /dev/null; then
        log_success "✅ AWS CLI 설치됨"
    else
        log_error "❌ AWS CLI 설치 실패"
    fi
    ((checks++))
    
    # GCP CLI 체크
    show_progress 2 $total_checks "GCP CLI 체크"
    if command -v gcloud &> /dev/null; then
        log_success "✅ GCP CLI 설치됨"
    else
        log_error "❌ GCP CLI 설치 실패"
    fi
    ((checks++))
    
    # Docker 체크
    show_progress 3 $total_checks "Docker 체크"
    if command -v docker &> /dev/null; then
        log_success "✅ Docker 설치됨"
    else
        log_error "❌ Docker 설치 실패"
    fi
    ((checks++))
    
    # Git 체크
    show_progress 4 $total_checks "Git 체크"
    if command -v git &> /dev/null; then
        log_success "✅ Git 설치됨"
    else
        log_error "❌ Git 설치 실패"
    fi
    ((checks++))
    
    # jq 체크
    show_progress 5 $total_checks "jq 체크"
    if command -v jq &> /dev/null; then
        log_success "✅ jq 설치됨"
    else
        log_error "❌ jq 설치 실패"
    fi
    ((checks++))
    
    # curl 체크
    show_progress 6 $total_checks "curl 체크"
    if command -v curl &> /dev/null; then
        log_success "✅ curl 설치됨"
    else
        log_error "❌ curl 설치 실패"
    fi
    
    echo ""
    log_success "환경 체크 완료"
}

# 메뉴 표시
show_menu() {
    clear
    log_header "Cloud Master WSL 환경 설정"
    echo "1. 전체 환경 설정 (권장)"
    echo "2. WSL 환경 체크"
    echo "3. 시스템 업데이트"
    echo "4. AWS CLI 설치"
    echo "5. GCP CLI 설치"
    echo "6. Docker 설치"
    echo "7. Git 설정"
    echo "8. 환경 변수 설정"
    echo "9. 최종 환경 체크"
    echo "10. 종료"
    echo ""
}

# 전체 환경 설정
setup_all() {
    log_header "전체 WSL 환경 설정 시작"
    
    check_wsl_environment || return 1
    update_system
    install_aws_cli
    install_gcp_cli
    install_docker
    setup_git
    setup_environment_variables
    final_environment_check
    
    log_success "전체 WSL 환경 설정 완료!"
    log_info "새 터미널을 열어서 환경 변수를 적용하세요"
    log_info "또는 'source ~/.bashrc' 명령을 실행하세요"
}

# 메인 실행 함수
main() {
    while true; do
        show_menu
        read -p "선택하세요 (1-10): " choice
        
        case $choice in
            1)
                setup_all
                read -p "계속하려면 Enter를 누르세요..."
                ;;
            2)
                check_wsl_environment
                read -p "계속하려면 Enter를 누르세요..."
                ;;
            3)
                update_system
                read -p "계속하려면 Enter를 누르세요..."
                ;;
            4)
                install_aws_cli
                read -p "계속하려면 Enter를 누르세요..."
                ;;
            5)
                install_gcp_cli
                read -p "계속하려면 Enter를 누르세요..."
                ;;
            6)
                install_docker
                read -p "계속하려면 Enter를 누르세요..."
                ;;
            7)
                setup_git
                read -p "계속하려면 Enter를 누르세요..."
                ;;
            8)
                setup_environment_variables
                read -p "계속하려면 Enter를 누르세요..."
                ;;
            9)
                final_environment_check
                read -p "계속하려면 Enter를 누르세요..."
                ;;
            10)
                log_info "WSL 환경 설정을 종료합니다."
                exit 0
                ;;
            *)
                log_error "잘못된 선택입니다. 1-10 중에서 선택하세요."
                sleep 2
                ;;
        esac
    done
}

# 스크립트 실행
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
