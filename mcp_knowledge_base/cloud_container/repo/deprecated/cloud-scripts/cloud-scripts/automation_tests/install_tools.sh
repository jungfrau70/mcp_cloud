#!/bin/bash
# Container 과정 필수 도구 설치 스크립트 (Bash)

set -e

echo "==============================================="
echo "Container 과정 필수 도구 설치 시작"
echo "==============================================="

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 도구 설치 상태 확인 함수
check_tool() {
    local tool_name="$1"
    local command="$2"
    
    if command -v "$command" &> /dev/null; then
        echo -e "${GREEN}✓ $tool_name: 이미 설치됨${NC}"
        return 0
    else
        echo -e "${RED}✗ $tool_name: 설치되지 않음${NC}"
        return 1
    fi
}

# 설치된 도구들 확인
echo -e "\n${YELLOW}설치된 도구들 확인 중...${NC}"

check_tool "Docker" "docker"
check_tool "Git" "git"
check_tool "GitHub CLI" "gh"
check_tool "AWS CLI" "aws"
check_tool "Google Cloud CLI" "gcloud"
check_tool "kubectl" "kubectl"
check_tool "Helm" "helm"

# Helm 설치
echo -e "\n${YELLOW}Helm 설치 중...${NC}"
if ! command -v helm &> /dev/null; then
    echo "Helm 다운로드 중..."
    
    # Helm 최신 버전 다운로드
    HELM_VERSION="v3.12.0"
    HELM_URL="https://get.helm.sh/helm-${HELM_VERSION}-windows-amd64.zip"
    HELM_ZIP="helm.zip"
    HELM_DIR="C:/helm"
    
    # Helm 디렉토리 생성
    mkdir -p "$HELM_DIR"
    
    # Helm 다운로드
    curl -fsSL -o "$HELM_ZIP" "$HELM_URL"
    
    # 압축 해제
    unzip -q "$HELM_ZIP" -d "$HELM_DIR"
    rm "$HELM_ZIP"
    
    # PATH에 추가 (Windows 환경)
    echo "PATH에 Helm 추가 중..."
    export PATH="$PATH:$HELM_DIR/windows-amd64"
    
    # Windows 환경변수에 추가
    if command -v setx &> /dev/null; then
        setx PATH "%PATH%;$HELM_DIR\windows-amd64" /M
    fi
    
    echo -e "${GREEN}✓ Helm 설치 완료${NC}"
else
    echo -e "${GREEN}✓ Helm이 이미 설치되어 있습니다${NC}"
fi

# Google Cloud CLI 설치 (kubectl 포함)
echo -e "\n${YELLOW}Google Cloud CLI 설치 중...${NC}"
if ! command -v gcloud &> /dev/null; then
    echo "Google Cloud CLI 다운로드 중..."
    
    # Google Cloud CLI 설치 프로그램 다운로드
    GCLOUD_URL="https://dl.google.com/dl/cloudsdk/channels/rapid/GoogleCloudSDKInstaller.exe"
    GCLOUD_INSTALLER="GoogleCloudSDKInstaller.exe"
    
    curl -fsSL -o "$GCLOUD_INSTALLER" "$GCLOUD_URL"
    
    echo "Google Cloud CLI 설치 프로그램을 실행합니다..."
    echo "설치 마법사에서 'Next'를 클릭하여 설치를 완료하세요."
    
    # Windows에서 설치 프로그램 실행
    if command -v start &> /dev/null; then
        start "$GCLOUD_INSTALLER"
    else
        ./"$GCLOUD_INSTALLER"
    fi
    
    # 설치 완료 대기
    read -p "설치가 완료되면 Enter를 누르세요..."
    
    # 설치 프로그램 정리
    rm "$GCLOUD_INSTALLER"
    
    echo -e "${GREEN}✓ Google Cloud CLI 설치 완료${NC}"
else
    echo -e "${GREEN}✓ Google Cloud CLI가 이미 설치되어 있습니다${NC}"
fi

# kubectl 설치 (Google Cloud CLI에 포함되어 있지만 별도 설치)
echo -e "\n${YELLOW}kubectl 설치 중...${NC}"
if ! command -v kubectl &> /dev/null; then
    echo "kubectl 다운로드 중..."
    
    # kubectl 최신 버전 다운로드
    KUBECTL_VERSION="v1.28.0"
    KUBECTL_URL="https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/windows/amd64/kubectl.exe"
    KUBECTL_DIR="C:/kubectl"
    
    # kubectl 디렉토리 생성
    mkdir -p "$KUBECTL_DIR"
    
    # kubectl 다운로드
    curl -fsSL -o "$KUBECTL_DIR/kubectl.exe" "$KUBECTL_URL"
    
    # PATH에 추가
    export PATH="$PATH:$KUBECTL_DIR"
    
    # Windows 환경변수에 추가
    if command -v setx &> /dev/null; then
        setx PATH "%PATH%;$KUBECTL_DIR" /M
    fi
    
    echo -e "${GREEN}✓ kubectl 설치 완료${NC}"
else
    echo -e "${GREEN}✓ kubectl이 이미 설치되어 있습니다${NC}"
fi

# 최종 확인
echo -e "\n${CYAN}최종 확인:${NC}"
echo "=================="

check_tool "Docker" "docker"
check_tool "Git" "git"
check_tool "GitHub CLI" "gh"
check_tool "AWS CLI" "aws"
check_tool "Google Cloud CLI" "gcloud"
check_tool "kubectl" "kubectl"
check_tool "Helm" "helm"

echo -e "\n${CYAN}설치 완료!${NC}"
echo "새로운 명령 프롬프트를 열어서 도구들을 사용하세요."
echo "또는 다음 명령어로 PATH를 새로고침하세요:"
echo "refreshenv"
