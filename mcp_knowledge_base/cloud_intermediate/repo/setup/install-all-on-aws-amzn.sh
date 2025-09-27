#!/bin/bash

# MCP Cloud Intermediate - AWS Amazon Linux 환경 전체 설치 스크립트
# 이 스크립트는 AWS Amazon Linux 환경에서 모든 필요한 도구를 설치합니다.

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

# 스크립트 디렉토리 확인
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
log_info "설치 스크립트 디렉토리: $SCRIPT_DIR"

# AWS Amazon Linux 환경 확인
if [[ -f /etc/os-release ]]; then
    . /etc/os-release
    if [[ "$ID" == "amzn" ]] || [[ "$ID" == "amazon" ]]; then
        log_success "Amazon Linux 환경 확인됨: $VERSION"
    else
        log_warning "Amazon Linux가 아닌 환경입니다: $ID"
        read -p "계속 진행하시겠습니까? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
else
    log_warning "OS 정보를 확인할 수 없습니다."
    read -p "계속 진행하시겠습니까? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

log_info "=== MCP Cloud Intermediate AWS 환경 설치 시작 ==="
log_info "설치 시간: $(date)"

# 1. 시스템 업데이트
log_info "시스템 패키지 업데이트 중..."
sudo yum update -y
log_success "시스템 업데이트 완료"

# 2. 필수 패키지 설치
log_info "필수 패키지 설치 중..."
sudo yum install -y \
    curl \
    wget \
    git \
    unzip \
    jq \
    htop \
    vim \
    nano \
    tree \
    gcc \
    gcc-c++ \
    make \
    openssl-devel \
    libffi-devel \
    zlib-devel \
    bzip2-devel \
    readline-devel \
    sqlite-devel \
    xz-devel \
    tk-devel \
    libyaml-devel \
    python3 \
    python3-pip \
    python3-devel

log_success "필수 패키지 설치 완료"

# 3. AWS CLI v2 설치
log_info "AWS CLI v2 설치 중..."
if ! command -v aws &> /dev/null; then
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    sudo ./aws/install
    rm -rf aws awscliv2.zip
    log_success "AWS CLI v2 설치 완료"
else
    log_info "AWS CLI가 이미 설치되어 있습니다: $(aws --version)"
fi

# 4. GCP CLI 설치 (Amazon Linux용)
log_info "GCP CLI 설치 중..."
if ! command -v gcloud &> /dev/null; then
    # Amazon Linux용 GCP CLI 설치
    curl https://sdk.cloud.google.com | bash
    source ~/.bashrc
    log_success "GCP CLI 설치 완료"
else
    log_info "GCP CLI가 이미 설치되어 있습니다: $(gcloud --version | head -1)"
fi

# 4-1. GKE 인증 플러그인 설치
log_info "GKE 인증 플러그인 설치 중..."
if gcloud components install gke-gcloud-auth-plugin --quiet 2>/dev/null; then
    log_success "GKE 인증 플러그인 설치 완료"
else
    log_warning "GKE 인증 플러그인 설치 실패 (권한 문제일 수 있음)"
fi

# 5. Docker 설치 (Amazon Linux용)
log_info "Docker 설치 중..."
if ! command -v docker &> /dev/null; then
    # 1. Docker 저장소 추가
    log_info "Docker 저장소 추가 중..."
    sudo yum install -y yum-utils
    sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
    
    # 2. Docker 설치
    log_info "Docker 설치 중..."
    sudo yum install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
    
    # 3. 사용자를 docker 그룹에 추가
    log_info "사용자를 docker 그룹에 추가 중..."
    sudo usermod -aG docker $USER
    
    # 4. Docker 서비스 시작 및 활성화
    log_info "Docker 서비스 시작 및 활성화 중..."
    sudo systemctl start docker
    sudo systemctl enable docker
    
    # 5. Docker 설치 확인
    log_info "Docker 설치 테스트 중..."
    if sudo docker --version > /dev/null 2>&1; then
        log_success "Docker 설치 완료: $(sudo docker --version)"
    else
        log_error "Docker 설치에 실패했습니다."
    fi
    
    log_success "Docker 설치 완료"
    log_warning "Docker 그룹 권한을 적용하려면 로그아웃 후 다시 로그인하거나 'newgrp docker'를 실행하세요."
else
    log_info "Docker가 이미 설치되어 있습니다: $(docker --version)"
fi

# 6. kubectl 설치 (최신 버전)
log_info "kubectl 최신 버전 설치 중..."
if ! command -v kubectl &> /dev/null; then
    # 최신 kubectl 버전 다운로드
    KUBECTL_VERSION=$(curl -L -s https://dl.k8s.io/release/stable.txt)
    log_info "kubectl 버전: $KUBECTL_VERSION"
    
    # kubectl 다운로드 및 설치
    curl -LO "https://dl.k8s.io/release/$KUBECTL_VERSION/bin/linux/amd64/kubectl"
    sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
    rm kubectl
    
    # 설치 확인
    if command -v kubectl &> /dev/null; then
        log_success "kubectl 설치 완료: $(kubectl version --client)"
    else
        log_error "kubectl 설치에 실패했습니다."
    fi
else
    log_info "kubectl이 이미 설치되어 있습니다: $(kubectl version --client)"
fi

# 7. Terraform 설치 (Amazon Linux용)
log_info "Terraform 설치 중..."
if ! command -v terraform &> /dev/null; then
    # HashiCorp GPG 키 추가
    sudo rpm --import https://packages.hashicorp.com/gpg
    # HashiCorp 저장소 추가
    sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
    # Terraform 설치
    sudo yum install -y terraform
    log_success "Terraform 설치 완료"
else
    log_info "Terraform이 이미 설치되어 있습니다: $(terraform --version | head -1)"
fi

# 8. Node.js 설치 (LTS 버전, Amazon Linux용)
log_info "Node.js LTS 설치 중..."
if ! command -v node &> /dev/null; then
    # NodeSource 저장소 추가
    curl -fsSL https://rpm.nodesource.com/setup_lts.x | sudo bash -
    # Node.js 설치
    sudo yum install -y nodejs
    log_success "Node.js 설치 완료"
else
    log_info "Node.js가 이미 설치되어 있습니다: $(node --version)"
fi

# 9. Helm 설치
log_info "Helm 설치 중..."
if ! command -v helm &> /dev/null; then
    curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
    log_success "Helm 설치 완료"
else
    log_info "Helm이 이미 설치되어 있습니다: $(helm version --short)"
fi

# 10. Git 설정 확인
log_info "Git 설정 확인 중..."
if [ -z "$(git config --global user.name)" ]; then
    log_warning "Git 사용자 이름이 설정되지 않았습니다."
    read -p "Git 사용자 이름을 입력하세요: " git_username
    git config --global user.name "$git_username"
fi

if [ -z "$(git config --global user.email)" ]; then
    log_warning "Git 이메일이 설정되지 않았습니다."
    read -p "Git 이메일을 입력하세요: " git_email
    git config --global user.email "$git_email"
fi

# 11. 작업 디렉토리 생성
log_info "작업 디렉토리 생성 중..."
mkdir -p ~/mcp-cloud-workspace
cd ~/mcp-cloud-workspace

# 12. 설치 완료 확인
log_info "=== 설치된 소프트웨어 버전 확인 ==="
echo "AWS CLI: $(aws --version 2>/dev/null || echo '설치되지 않음')"
echo "GCP CLI: $(gcloud --version 2>/dev/null | head -1 || echo '설치되지 않음')"

# GKE 인증 플러그인 확인
if command -v gke-gcloud-auth-plugin &> /dev/null; then
    echo "GKE Auth Plugin: $(gke-gcloud-auth-plugin --version 2>/dev/null || echo '설치됨 (버전 확인 불가)')"
else
    echo "GKE Auth Plugin: 설치되지 않음"
    log_warning "⚠️ GKE 인증 플러그인이 설치되지 않았습니다."
fi

# Docker 확인
if command -v docker &> /dev/null; then
    echo "Docker: $(docker --version)"
    # Docker 서비스 상태 확인
    if sudo systemctl is-active --quiet docker; then
        echo "Docker 서비스: 실행 중"
    else
        echo "Docker 서비스: 중지됨"
        log_warning "Docker 서비스가 실행되지 않았습니다. 'sudo systemctl start docker'를 실행하세요."
    fi
else
    echo "Docker: 설치되지 않음"
    log_warning "Docker가 설치되지 않았습니다."
fi

# Docker Compose 확인
if command -v docker-compose &> /dev/null; then
    echo "Docker Compose: $(docker-compose --version)"
else
    echo "Docker Compose: 설치되지 않음"
    log_warning "Docker Compose가 설치되지 않았습니다."
fi

# kubectl 확인
if command -v kubectl &> /dev/null; then
    echo "kubectl: $(kubectl version --client)"
else
    echo "kubectl: 설치되지 않음"
    log_warning "kubectl이 설치되지 않았습니다."
fi

echo "Terraform: $(terraform --version 2>/dev/null | head -1 || echo '설치되지 않음')"
echo "Node.js: $(node --version 2>/dev/null || echo '설치되지 않음')"
echo "Python: $(python3 --version 2>/dev/null || echo '설치되지 않음')"
echo "Helm: $(helm version --short 2>/dev/null || echo '설치되지 않음')"

# 13. 환경 설정 파일 생성
log_info "환경 설정 파일 생성 중..."
cat > ~/.mcp-cloud-env << EOF
# MCP Cloud Intermediate AWS Amazon Linux 환경 설정
# 생성 시간: $(date)

export MCP_CLOUD_HOME="$HOME/mcp-cloud-workspace"
export PATH="\$MCP_CLOUD_HOME/bin:\$PATH"

# AWS 설정
export AWS_DEFAULT_REGION="ap-northeast-2"

# GCP 설정
export GOOGLE_CLOUD_PROJECT=""

# Docker 설정
export DOCKER_BUILDKIT=1
export COMPOSE_DOCKER_CLI_BUILD=1

# Kubernetes 설정
export KUBECONFIG="\$HOME/.kube/config"

# Terraform 설정
export TF_VAR_region="ap-northeast-2"

# 작업 디렉토리로 이동
cd "\$MCP_CLOUD_HOME"
EOF

# 14. AWS용 Docker 시작 스크립트 생성
log_info "AWS용 Docker 시작 스크립트 생성 중..."
cat > ~/.local/bin/start-docker << 'EOF'
#!/bin/bash
# AWS Ubuntu에서 Docker 시작 스크립트

echo "🐳 AWS Ubuntu에서 Docker 시작 중..."

# Docker 서비스가 이미 실행 중인지 확인
if sudo systemctl is-active --quiet docker; then
    echo "✅ Docker 서비스가 이미 실행 중입니다."
    docker --version
    exit 0
fi

# Docker 서비스 시작
echo "🚀 Docker 서비스 시작 중..."
sudo systemctl start docker

# Docker 서비스가 시작될 때까지 대기
echo "⏳ Docker 서비스 시작 대기 중..."
for i in {1..30}; do
    if sudo systemctl is-active --quiet docker; then
        echo "✅ Docker 서비스가 시작되었습니다."
        docker --version
        echo "🎉 Docker 사용 준비 완료!"
        echo "💡 사용법: docker run hello-world"
        exit 0
    fi
    sleep 1
done

echo "❌ Docker 서비스 시작에 실패했습니다."
echo "🔧 수동으로 시작: sudo systemctl start docker"
exit 1
EOF

chmod +x ~/.local/bin/start-docker
log_success "Docker 시작 스크립트 생성 완료: ~/.local/bin/start-docker"

# 15. AWS 환경 체크 스크립트 생성
log_info "AWS 환경 체크 스크립트 생성 중..."
cat > ~/.local/bin/check-aws-env << 'EOF'
#!/bin/bash
# AWS Ubuntu 환경 체크 스크립트

echo "🔍 AWS Ubuntu 환경 체크 시작..."

# AWS CLI 체크
if command -v aws &> /dev/null; then
    echo "✅ AWS CLI: $(aws --version)"
    if aws sts get-caller-identity &> /dev/null; then
        echo "✅ AWS CLI 권한: 설정됨"
    else
        echo "❌ AWS CLI 권한: 설정 필요 (aws configure)"
    fi
else
    echo "❌ AWS CLI: 설치되지 않음"
fi

# GCP CLI 체크
if command -v gcloud &> /dev/null; then
    echo "✅ GCP CLI: $(gcloud --version | head -1)"
    if gcloud auth list --filter=status:ACTIVE --format="value(account)" &> /dev/null; then
        echo "✅ GCP CLI 권한: 설정됨"
    else
        echo "❌ GCP CLI 권한: 설정 필요 (gcloud auth login)"
    fi
else
    echo "❌ GCP CLI: 설치되지 않음"
fi

# Docker 체크
if command -v docker &> /dev/null; then
    echo "✅ Docker: $(docker --version)"
    if sudo systemctl is-active --quiet docker; then
        echo "✅ Docker 서비스: 실행 중"
    else
        echo "❌ Docker 서비스: 중지됨"
    fi
else
    echo "❌ Docker: 설치되지 않음"
fi

# kubectl 체크
if command -v kubectl &> /dev/null; then
    echo "✅ kubectl: $(kubectl version --client)"
else
    echo "❌ kubectl: 설치되지 않음"
fi

# Terraform 체크
if command -v terraform &> /dev/null; then
    echo "✅ Terraform: $(terraform --version | head -1)"
else
    echo "❌ Terraform: 설치되지 않음"
fi

# Node.js 체크
if command -v node &> /dev/null; then
    echo "✅ Node.js: $(node --version)"
else
    echo "❌ Node.js: 설치되지 않음"
fi

# Helm 체크
if command -v helm &> /dev/null; then
    echo "✅ Helm: $(helm version --short)"
else
    echo "❌ Helm: 설치되지 않음"
fi

echo "🎯 AWS Ubuntu 환경 체크 완료!"
EOF

chmod +x ~/.local/bin/check-aws-env
log_success "AWS 환경 체크 스크립트 생성 완료: ~/.local/bin/check-aws-env"

# 16. .bashrc에 환경 설정 추가
log_info ".bashrc에 환경 설정 추가 중..."
if ! grep -q "MCP_CLOUD_HOME" ~/.bashrc; then
    echo "" >> ~/.bashrc
    echo "# MCP Cloud Intermediate AWS Amazon Linux 환경 설정" >> ~/.bashrc
    echo "source ~/.mcp-cloud-env" >> ~/.bashrc
    log_success ".bashrc에 환경 설정 추가 완료"
else
    log_info ".bashrc에 이미 환경 설정이 추가되어 있습니다."
fi

# 17. 설치 완료 메시지
log_success "=== MCP Cloud Intermediate AWS 환경 설치 완료 ==="
log_info "설치 완료 시간: $(date)"
log_info "작업 디렉토리: ~/mcp-cloud-workspace"
log_info "환경 설정 파일: ~/.mcp-cloud-env"
log_info "Docker 시작 스크립트: ~/.local/bin/start-docker"
log_info "환경 체크 스크립트: ~/.local/bin/check-aws-env"

echo ""
log_info "=== 다음 단계 ==="
echo "1. 새 터미널을 열거나 'source ~/.bashrc'를 실행하세요."
echo "2. AWS CLI 설정: aws configure"
echo "3. GCP CLI 설정: gcloud auth login"
echo "4. Docker 그룹 권한 적용: newgrp docker"
echo "5. 환경 체크: check-aws-env"
echo ""

log_success "🎉 AWS Amazon Linux 환경 설치가 완료되었습니다!"
