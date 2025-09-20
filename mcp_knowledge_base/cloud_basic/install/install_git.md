# Git 설치 가이드


Git은 분산 버전 관리 시스템으로, 소스 코드의 변경사항을 추적하고 협업을 지원합니다. 이 가이드는 다양한 운영체제에서 Git을 설치하는 방법을 설명합니다.

## 목차
- [Windows 설치](#windows-설치)
- [macOS 설치](#macos-설치)
- [Linux 설치](#linux-설치)
- [설치 확인](#설치-확인)
- [기본 설정](#기본-설정)
- [문제 해결](#문제-해결)

## Windows 설치

### 방법 1: Git for Windows (권장)

1. **Git for Windows 다운로드**
   ```bash
   # 공식 웹사이트에서 다운로드
   https:///git-scm.com/download/win
   ```

2. **설치 실행**
   - 다운로드한 Git-2.42.0-64-bit.exe 실행
   - 설치 마법사의 지시를 따름
   - 기본 설정으로 설치 권장

3. **설치 옵션**
   - **Git Bash**: Unix 스타일 명령줄 도구
   - **Git GUI**: 그래픽 사용자 인터페이스
   - **Git LFS**: 대용량 파일 지원
   - **Windows Explorer 통합**: 컨텍스트 메뉴 추가

### 방법 2: Chocolatey 사용

```cmd
# Chocolatey 설치 (없는 경우)
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https:///community.chocolatey.org/install.ps1'))

# Git 설치
choco install git
```

### 방법 3: winget 사용

```cmd
winget install Git.Git
```

### 방법 4: Scoop 사용

```powershell
# Scoop 설치 (없는 경우)
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
irm get.scoop.sh | iex

# Git 설치
scoop install git
```

### 방법 5: GitHub Desktop

```bash
# GitHub Desktop 다운로드
https:///desktop.github.com/
```

## macOS 설치

### 방법 1: Xcode Command Line Tools (권장)

```bash
# Xcode Command Line Tools 설치
xcode-select --install

# 설치 확인
git --version
```

### 방법 2: Homebrew 사용

```bash
# Homebrew 설치 확인
brew --version

# Git 설치
brew install git

# 최신 버전으로 업데이트
brew upgrade git
```

### 방법 3: MacPorts 사용

```bash
# MacPorts 설치 확인
port version

# Git 설치
sudo port install git
```

### 방법 4: 공식 설치 프로그램

```bash
# Git for macOS 다운로드
https:///git-scm.com/download/mac
```

### 방법 5: GitHub Desktop

```bash
# GitHub Desktop 다운로드
https:///desktop.github.com/
```

## Linux 설치

### Ubuntu/Debian

#### 방법 1: APT 패키지 매니저 (권장)

```bash
# 패키지 업데이트
sudo apt update

# Git 설치
sudo apt install git

# 최신 버전 설치 (PPA 사용)
sudo add-apt-repository ppa:git-core/ppa
sudo apt update
sudo apt install git
```

#### 방법 2: 소스에서 컴파일

```bash
# 의존성 설치
sudo apt install -y make libssl-dev libghc-zlib-dev libcurl4-gnutls-dev libexpat1-dev gettext unzip

# Git 소스 다운로드
cd /tmp
wget https:///github.com/git/git/archive/v2.42.0.tar.gz
tar -xzf v2.42.0.tar.gz
cd git-2.42.0

# 컴파일 및 설치
make configure
./configure --prefix=/usr/local
make all
sudo make install
```

### CentOS/RHEL/Rocky Linux

#### 방법 1: YUM/DNF 패키지 매니저

```bash
# CentOS/RHEL 7
sudo yum install git

# CentOS/RHEL 8+ / Rocky Linux
sudo dnf install git

# 최신 버전 설치 (EPEL 리포지토리)
sudo yum install epel-release
sudo yum install git
```

#### 방법 2: 소스에서 컴파일

```bash
# 의존성 설치
sudo yum groupinstall "Development Tools"
sudo yum install gettext-devel openssl-devel perl-CPAN perl-devel zlib-devel curl-devel

# Git 소스 다운로드 및 컴파일
cd /tmp
wget https:///github.com/git/git/archive/v2.42.0.tar.gz
tar -xzf v2.42.0.tar.gz
cd git-2.42.0
make configure
./configure --prefix=/usr/local
make all
sudo make install
```

### Fedora

```bash
# dnf 사용
sudo dnf install git

# 최신 버전 설치
sudo dnf install git-core
```

### openSUSE

```bash
# zypper 사용
sudo zypper install git

# 최신 버전 설치
sudo zypper addrepo https:///download.opensuse.org/repositories/devel:tools:scm/openSUSE_Leap_15.4/devel:tools:scm.repo
sudo zypper refresh
sudo zypper install git
```

### Arch Linux

```bash
# pacman 사용
sudo pacman -S git

# AUR에서 최신 버전 설치
yay -S git-git
```

### Alpine Linux

```bash
# apk 사용
sudo apk add git
```

### Amazon Linux

```bash
# Amazon Linux 2023
sudo dnf install git

# Amazon Linux 2
sudo yum install git
```

## 설치 확인

설치가 완료된 후 다음 명령어로 확인할 수 있습니다:

```bash
# Git 버전 확인
git --version

# Git 설정 확인
git config --list

# Git 도움말
git --help
```

예상 출력:
```
git version 2.42.0
```

## 기본 설정

### 1. 사용자 정보 설정

```bash
# 전역 사용자 이름 설정
git config --global user.name "Your Name"

# 전역 ### 📧 연락처
- **이메일**: inhwan.jung@gmail.com
- **GitHub**: [프로젝트 저장소](https:///github.com/jungfrau70/aws_gcp.git)
### 6. 자격 증명 관리

```bash
# 자격 증명 저장 설정
git config --global credential.helper store

# Windows에서 자격 증명 관리자 사용
git config --global credential.helper manager-core

# macOS에서 키체인 사용
git config --global credential.helper osxkeychain
```

## 문제 해결

### 일반적인 문제들

1. **Git 명령을 찾을 수 없음**
   ```bash
   # PATH 확인
   echo $PATH
   
   # Git 경로 확인
   which git
   
   # Windows에서 PATH 추가
   # 시스템 환경 변수에서 PATH에 Git 설치 경로 추가
   ```

2. **권한 오류**
   ```bash
   # SSH 키 권한 설정
   chmod 700 ~/.ssh
   chmod 600 ~/.ssh/id_ed25519
   chmod 644 ~/.ssh/id_ed25519.pub
   ```

3. **SSL 인증서 오류**
   ```bash
   # SSL 검증 비활성화 (권장하지 않음)
   git config --global http.sslVerify false
   
   # 또는 인증서 파일 지정
   git config --global http.sslCAInfo /path/to/certificate.pem
   ```

4. **프록시 설정**
   ```bash
   # HTTP 프록시 설정
   git config --global http.proxy http://proxy.company.com:8080
   git config --global https.proxy https:///proxy.company.com:8080
   
   # 프록시 제거
   git config --global --unset http.proxy
   git config --global --unset https.proxy
   ```

### 로그 및 디버깅

```bash
# Git 명령어 추적
GIT_TRACE=1 git status

# 네트워크 추적
GIT_CURL_VERBOSE=1 git clone https:///github.com/user/repo.git

# SSH 디버깅
ssh -T git@github.com -v
```

### 성능 최적화

```bash
# 대용량 저장소 최적화
git config --global core.preloadindex true
git config --global core.fscache true
git config --global gc.auto 256

# 병렬 처리 설정
git config --global pack.threads 0
git config --global index.threads 0
```

## 추가 도구

### Git LFS (Large File Storage)

```bash
# Git LFS 설치
# Windows: Git for Windows에 포함
# macOS: brew install git-lfs
# Linux: sudo apt install git-lfs

# Git LFS 초기화
git lfs install

# 대용량 파일 추적
git lfs track "*.psd"
git lfs track "*.zip"
```

### Git GUI 도구

```bash
# GitKraken (크로스 플랫폼)
# https:///www.gitkraken.com/

# SourceTree (Windows/macOS)
# https:///www.sourcetreeapp.com/

# GitHub Desktop (Windows/macOS)
# https:///desktop.github.com/

# Git Cola (Linux)
sudo apt install git-cola
```

## 추가 리소스

- [Git 공식 문서](https:///git-scm.com/doc)
- [Pro Git 책](https:///git-scm.com/book)
- [GitHub Docs](https:///docs.github.com/)
- [GitLab Docs](https:///docs.gitlab.com/)
- [Atlassian Git 튜토리얼](https:///www.atlassian.com/git/tutorials)

## 버전 관리

```bash
# 현재 버전 확인
git --version

# 업데이트
# Windows: Git for Windows 재설치
# macOS: brew upgrade git
# Linux: 패키지 매니저를 통한 업데이트

# Ubuntu/Debian
sudo apt update && sudo apt upgrade git

# CentOS/RHEL
sudo yum update git
```

## 보안 모범 사례

1. **SSH 키 사용**: HTTPS 대신 SSH 사용 권장
2. **정기적 키 로테이션**: SSH 키 주기적 변경
3. **2FA 활성화**: GitHub/GitLab에서 2단계 인증 사용
4. **민감한 정보 제외**: .gitignore 파일 적절히 설정
5. **서명된 커밋**: GPG 서명 사용

```bash
# GPG 키 생성
gpg --full-generate-key

# GPG 키를 Git에 연결
git config --global user.signingkey YOUR_GPG_KEY_ID
git config --global commit.gpgsign true

# 서명된 커밋 생성
git commit -S -m "Signed commit message"
```

## 자동화 스크립트

### Ubuntu/Debian 자동 설치 스크립트

```bash
#!/bin/bash
set -e

echo "Git 설치 시작..."

# 패키지 업데이트
sudo apt update

# Git 설치
sudo apt install -y git

# Git LFS 설치
sudo apt install -y git-lfs

# 설치 확인
git --version
git lfs version

echo "Git 설치 완료!"

# 기본 설정 안내
echo ""
echo "💡 Git 기본 설정을 위해 다음 명령어를 실행하세요:"
echo "git config --global user.name /"Your Name/""
echo "git config --global user.email /"your.email@example.com/""
echo "git config --global init.defaultBranch main"
```

### CentOS/RHEL 자동 설치 스크립트

```bash
#!/bin/bash
set -e

echo "Git 설치 시작..."

# 패키지 매니저 확인
if command -v dnf &> /dev/null; then
    PACKAGE_MANAGER="dnf"
else
    PACKAGE_MANAGER="yum"
fi

# Git 설치
sudo $PACKAGE_MANAGER install -y git

# Git LFS 설치 (EPEL 필요)
sudo $PACKAGE_MANAGER install -y epel-release
sudo $PACKAGE_MANAGER install -y git-lfs

# 설치 확인
git --version
git lfs version

echo "Git 설치 완료!"

# 기본 설정 안내
echo ""
echo "💡 Git 기본 설정을 위해 다음 명령어를 실행하세요:"
echo "git config --global user.name /"Your Name/""
echo "git config --global user.email /"your.email@example.com/""
echo "git config --global init.defaultBranch main"
```

### 테스트 스크립트

```bash
#!/bin/bash
# Git 설치 테스트 스크립트

echo "Git 설치 테스트 시작..."

# Git 버전 확인
if git --version; then
    echo "✅ Git 설치 확인됨"
else
    echo "❌ Git 설치 실패"
    exit 1
fi

# Git 설정 테스트
echo "Git 설정 테스트..."

# 임시 설정
git config --global user.name "Test User"
git config --global user.email "test@example.com"

# 설정 확인
if git config --global user.name | grep -q "Test User"; then
    echo "✅ Git 설정 확인됨"
else
    echo "❌ Git 설정 실패"
    exit 1
fi

# 임시 저장소 테스트
echo "Git 저장소 테스트..."

# 임시 디렉토리 생성
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

# Git 저장소 초기화
if git init; then
    echo "✅ Git 저장소 초기화 성공"
else
    echo "❌ Git 저장소 초기화 실패"
    exit 1
fi

# 테스트 파일 생성 및 커밋
echo "test" > test.txt
git add test.txt
if git commit -m "Test commit"; then
    echo "✅ Git 커밋 성공"
else
    echo "❌ Git 커밋 실패"
    exit 1
fi

# 정리
cd /
rm -rf "$TEMP_DIR"

echo "✅ Git 설치 테스트 완료!"
```

## 고급 설정

### 1. Git Hooks

```bash
# 커밋 전 훅 설정
cat > .git/hooks/pre-commit << 'EOF'
#!/bin/bash
# 코드 스타일 검사
npm run lint
EOF

chmod +x .git/hooks/pre-commit
```

### 2. Git Aliases

```bash
# 유용한 별칭 설정
git config --global alias.st status
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.ci commit
git config --global alias.unstage 'reset HEAD --'
git config --global alias.last 'log -1 HEAD'
git config --global alias.visual '!gitk'
```

### 3. Git Attributes

```bash
# .gitattributes 파일 생성
cat > .gitattributes << 'EOF'
# 텍스트 파일
*.txt text
*.md text

# 바이너리 파일
*.png binary
*.jpg binary
*.zip binary

# 줄 바꿈 설정
*.sh text eol=lf
*.bat text eol=crlf
EOF
```


---


---



<div align="center">

[← 이전: Cloud Basic 메인](README.md) | [📚 전체 커리큘럼](curriculum.md) | [🏠 학습 경로로 돌아가기](index.md) | [📋 학습 경로](learning-path.md)

</div>