# Google Cloud CLI 설치 가이드

<div align="center">

[← 이전: Cloud Container 메인](/mcp_knowledge_base/cloud_master/README.md) | [📚 전체 커리큘럼](/mcp_knowledge_base/curriculum.md) | [🏠 학습 경로로 돌아가기](/mcp_knowledge_base/index.md) | [📋 학습 경로](/mcp_knowledge_base/cloud_master/learning-path.md)

</div>

Google Cloud CLI(gcloud)는 Google Cloud Platform 서비스와 상호작용하기 위한 명령줄 도구입니다. 이 가이드는 다양한 운영체제에서 Google Cloud CLI를 설치하는 방법을 설명합니다.

## 목차
- [Windows 설치](#windows-설치)
- [macOS 설치](#macos-설치)
- [Linux 설치](#linux-설치)
- [Docker를 사용한 설치](#docker를-사용한-설치)
- [설치 확인](#설치-확인)
- [기본 설정](#기본-설정)
- [문제 해결](#문제-해결)

## Windows 설치

### 방법 1: Google Cloud CLI 설치 프로그램 (권장)

1. **Google Cloud CLI 설치 프로그램 다운로드**
   ```bash
   # 최신 버전 다운로드
   https://dl.google.com/dl/cloudsdk/channels/rapid/GoogleCloudSDKInstaller.exe
   ```

2. **설치 실행**
   - 다운로드한 설치 프로그램을 더블클릭하여 실행
   - 설치 마법사의 지시를 따름
   - 기본 설치 경로: `C:\Program Files (x86)\Google\Cloud SDK\google-cloud-sdk\`

3. **PATH 확인**
   - 설치 후 자동으로 PATH에 추가됨
   - 새 명령 프롬프트 창을 열어 확인

### 방법 2: PowerShell을 사용한 설치

```powershell
# PowerShell을 관리자 권한으로 실행
(New-Object Net.WebClient).DownloadFile("https://dl.google.com/dl/cloudsdk/channels/rapid/GoogleCloudSDKInstaller.exe", "$env:Temp\GoogleCloudSDKInstaller.exe")
& "$env:Temp\GoogleCloudSDKInstaller.exe" /S
```

### 방법 3: Chocolatey 사용

```cmd
choco install gcloudsdk
```

### 방법 4: winget 사용

```cmd
winget install Google.CloudSDK
```

### 방법 5: 수동 설치

1. **ZIP 파일 다운로드**
   ```bash
   # Windows용 ZIP 파일
   https://dl.google.com/dl/cloudsdk/channels/rapid/google-cloud-cli-<version>-windows-x86_64.zip
   ```

2. **압축 해제 및 설치**
   ```cmd
   # C:\google-cloud-sdk에 압축 해제
   # 설치 스크립트 실행
   C:\google-cloud-sdk\install.bat
   ```

## macOS 설치

### 방법 1: Homebrew 사용 (권장)

1. **Homebrew 설치 확인**
   ```bash
   brew --version
   ```

2. **Google Cloud CLI 설치**
   ```bash
   brew install --cask google-cloud-sdk
   ```

### 방법 2: curl을 사용한 설치

1. **설치 스크립트 다운로드 및 실행**
   ```bash
   curl https://sdk.cloud.google.com | bash
   ```

2. **셸 재시작 또는 PATH 추가**
   ```bash
   # zsh 사용 시
   echo 'source ~/google-cloud-sdk/path.zsh.inc' >> ~/.zshrc
   echo 'source ~/google-cloud-sdk/completion.zsh.inc' >> ~/.zshrc
   source ~/.zshrc
   
   # bash 사용 시
   echo 'source ~/google-cloud-sdk/path.bash.inc' >> ~/.bash_profile
   echo 'source ~/google-cloud-sdk/completion.bash.inc' >> ~/.bash_profile
   source ~/.bash_profile
   ```

### 방법 3: pip 사용

1. **Python 확인**
   ```bash
   python3 --version
   ```

2. **Google Cloud CLI 설치**
   ```bash
   pip3 install google-cloud-cli
   ```

## Linux 설치

### Ubuntu/Debian

1. **패키지 업데이트**
   ```bash
   sudo apt update
   ```

2. **Google Cloud CLI 설치**
   ```bash
   # Google Cloud 공식 리포지토리 추가
   echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
   
   # Google Cloud 공개 키 추가
   curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
   
   # 패키지 업데이트 및 설치
   sudo apt update
   sudo apt install google-cloud-cli
   ```

### CentOS/RHEL/Fedora

1. **Google Cloud CLI 설치**
   ```bash
   # CentOS/RHEL 7
   sudo tee -a /etc/yum.repos.d/google-cloud-sdk.repo << EOM
   [google-cloud-sdk]
   name=Google Cloud SDK
   baseurl=https://packages.cloud.google.com/yum/repos/cloud-sdk-el7-x86_64
   enabled=1
   gpgcheck=1
   repo_gpgcheck=1
   gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg
          https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
   EOM
   
   sudo yum install google-cloud-cli
   
   # CentOS/RHEL 8+
   sudo dnf install google-cloud-cli
   
   # Fedora
   sudo dnf install google-cloud-cli
   ```

### openSUSE

```bash
sudo zypper addrepo https://packages.cloud.google.com/yum/repos/cloud-sdk-opensuse-leap-15.2-x86_64 google-cloud-sdk
sudo zypper install google-cloud-cli
```

### Arch Linux

```bash
sudo pacman -S google-cloud-cli
```

### curl을 사용한 설치 (모든 Linux 배포판)

```bash
# 설치 스크립트 다운로드 및 실행
curl https://sdk.cloud.google.com | bash

# 셸 재시작 또는 PATH 추가
echo 'source ~/google-cloud-sdk/path.bash.inc' >> ~/.bashrc
echo 'source ~/google-cloud-sdk/completion.bash.inc' >> ~/.bashrc
source ~/.bashrc
```

## Docker를 사용한 설치

### Docker 이미지 실행

```bash
# 최신 Google Cloud CLI 실행
docker run -it gcr.io/google.com/cloudsdktool/cloud-sdk:latest

# 특정 버전 실행
docker run -it gcr.io/google.com/cloudsdktool/cloud-sdk:430.0.0

# 볼륨 마운트로 설정 유지
docker run -it -v ~/.config/gcloud:/root/.config/gcloud gcr.io/google.com/cloudsdktool/cloud-sdk:latest
```

### Docker Compose 사용

```yaml
# docker-compose.yml
version: '3.8'
services:
  gcloud:
    image: gcr.io/google.com/cloudsdktool/cloud-sdk:latest
    volumes:
      - ~/.config/gcloud:/root/.config/gcloud
    stdin_open: true
    tty: true
```

## 설치 확인

설치가 완료된 후 다음 명령어로 확인할 수 있습니다:

```bash
gcloud --version
```

예상 출력:
```
Google Cloud SDK 430.0.0
bq 2.0.91
core 2023.10.20
gcloud-crc32c 1.0.0
gsutil 5.25
```

## 기본 설정

### 1. Google Cloud 로그인

```bash
# 대화형 로그인
gcloud auth login

# 서비스 계정으로 로그인
gcloud auth activate-service-account --key-file=path/to/service-account-key.json

# 애플리케이션 기본 자격 증명 설정
gcloud auth application-default login
```

### 2. 프로젝트 설정

```bash
# 프로젝트 목록 확인
gcloud projects list

# 기본 프로젝트 설정
gcloud config set project PROJECT_ID

# 현재 프로젝트 확인
gcloud config get-value project
```

### 3. 기본 설정 확인 및 변경

```bash
# 현재 설정 확인
gcloud config list

# 기본 리전 설정
gcloud config set compute/region asia-northeast3

# 기본 존 설정
gcloud config set compute/zone asia-northeast3-a

# 출력 형식 설정
gcloud config set format json
```

### 4. 구성 관리

```bash
# 새 구성 생성
gcloud config configurations create my-config

# 구성 전환
gcloud config configurations activate my-config

# 구성 목록
gcloud config configurations list

# 구성 삭제
gcloud config configurations delete my-config
```

## 컴포넌트 관리

### 컴포넌트 설치

```bash
# 특정 컴포넌트 설치
gcloud components install COMPONENT_ID

# 예시: kubectl 설치
gcloud components install kubectl

# 예시: App Engine 확장 설치
gcloud components install app-engine-python
```

### 컴포넌트 목록 및 업데이트

```bash
# 설치된 컴포넌트 목록
gcloud components list

# 모든 컴포넌트 업데이트
gcloud components update

# 특정 컴포넌트 업데이트
gcloud components update COMPONENT_ID
```

## 문제 해결

### 일반적인 문제들

1. **'gcloud' 명령을 찾을 수 없음**
   ```bash
   # PATH 확인
   echo $PATH
   
   # Google Cloud CLI 경로 확인
   which gcloud
   
   # 수동으로 PATH 추가
   export PATH=$PATH:~/google-cloud-sdk/bin
   ```

2. **로그인 오류**
   ```bash
   # 인증 정보 초기화
   gcloud auth revoke --all
   gcloud auth login
   
   # 애플리케이션 기본 자격 증명 재설정
   gcloud auth application-default revoke
   gcloud auth application-default login
   ```

3. **권한 오류**
   ```bash
   # 현재 계정 확인
   gcloud auth list
   
   # 프로젝트 권한 확인
   gcloud projects get-iam-policy PROJECT_ID
   ```

4. **프록시 설정**
   ```bash
   export HTTP_PROXY=http://proxy.company.com:8080
   export HTTPS_PROXY=http://proxy.company.com:8080
   
   # 또는 gcloud 설정으로
   gcloud config set proxy/type http
   gcloud config set proxy/address proxy.company.com
   gcloud config set proxy/port 8080
   ```

### 로그 및 디버깅

```bash
# 디버그 모드로 실행
gcloud <command> --verbosity=debug

# 로그 레벨 설정
gcloud config set core/verbosity debug

# 로그 파일 위치
# Windows: %APPDATA%\gcloud\logs\
# macOS/Linux: ~/.config/gcloud/logs/
```

### 성능 최적화

```bash
# 자동 완성 활성화
gcloud components install beta
gcloud beta interactive

# 캐시 클리어
gcloud info --clear-cache

# 원격 분석 비활성화
gcloud config set disable_usage_reporting true
```

## 추가 리소스

- [Google Cloud CLI 공식 문서](https://cloud.google.com/sdk/docs)
- [Google Cloud CLI 명령어 참조](https://cloud.google.com/sdk/gcloud/reference)
- [Google Cloud CLI 구성](https://cloud.google.com/sdk/docs/configurations)
- [Google Cloud CLI 컴포넌트](https://cloud.google.com/sdk/docs/components)

## 버전 관리

```bash
# 현재 버전 확인
gcloud --version

# 업데이트
gcloud components update

# 특정 버전으로 다운그레이드
gcloud components update --version=VERSION
```

## 보안 모범 사례

1. **서비스 계정 사용**: 개인 계정 대신 서비스 계정 사용
2. **최소 권한 원칙**: 필요한 권한만 부여
3. **키 로테이션**: 서비스 계정 키 주기적 변경
4. **조건부 액세스**: IAM 조건부 정책 사용
5. **감사 로그**: Cloud Audit Logs 활성화

```bash
# 서비스 계정 생성
gcloud iam service-accounts create my-service-account \
    --description="Service account for automation" \
    --display-name="My Service Account"

# 서비스 계정 키 생성
gcloud iam service-accounts keys create key.json \
    --iam-account=my-service-account@PROJECT_ID.iam.gserviceaccount.com

# 서비스 계정에 권한 부여
gcloud projects add-iam-policy-binding PROJECT_ID \
    --member="serviceAccount:my-service-account@PROJECT_ID.iam.gserviceaccount.com" \
    --role="roles/compute.instanceAdmin"
```

## 자동화 및 스크립팅

### Bash 스크립트 예시

```bash
#!/bin/bash
# Google Cloud VM 인스턴스 생성 스크립트

PROJECT_ID="my-project"
INSTANCE_NAME="my-instance"
ZONE="asia-northeast3-a"
MACHINE_TYPE="e2-micro"

# 프로젝트 설정
gcloud config set project $PROJECT_ID

# VM 인스턴스 생성
gcloud compute instances create $INSTANCE_NAME \
    --zone=$ZONE \
    --machine-type=$MACHINE_TYPE \
    --image-family=ubuntu-2004-lts \
    --image-project=ubuntu-os-cloud \
    --boot-disk-size=10GB \
    --boot-disk-type=pd-standard
```

### PowerShell 스크립트 예시

```powershell
# Google Cloud VM 인스턴스 생성 스크립트

$projectId = "my-project"
$instanceName = "my-instance"
$zone = "asia-northeast3-a"
$machineType = "e2-micro"

# 프로젝트 설정
gcloud config set project $projectId

# VM 인스턴스 생성
gcloud compute instances create $instanceName `
    --zone=$zone `
    --machine-type=$machineType `
    --image-family=ubuntu-2004-lts `
    --image-project=ubuntu-os-cloud `
    --boot-disk-size=10GB `
    --boot-disk-type=pd-standard
```

## 고급 기능

### Cloud Shell 사용

```bash
# Cloud Shell에서 gcloud는 이미 설치되어 있음
# 추가 컴포넌트 설치
gcloud components install kubectl

# Cloud Shell 환경 확인
gcloud info
```

### CI/CD 통합

```yaml
# GitHub Actions 예시
name: Deploy to Google Cloud
on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v2
    - uses: google-github-actions/setup-gcloud@v0
      with:
        service_account_key: ${{ secrets.GCP_SA_KEY }}
        project_id: ${{ secrets.GCP_PROJECT_ID }}
    - run: gcloud app deploy
```

### 환경 변수 설정

```bash
# 환경 변수로 설정
export GOOGLE_APPLICATION_CREDENTIALS="path/to/service-account-key.json"
export GOOGLE_CLOUD_PROJECT="my-project-id"

# 또는 gcloud 설정으로
gcloud config set project my-project-id
gcloud auth activate-service-account --key-file=path/to/service-account-key.json
```


---

<div align="center">

[🏠 홈](/mcp_knowledge_base/index.md) | [📚 전체 커리큘럼](/mcp_knowledge_base/curriculum.md) | [🔗 학습 경로](/mcp_knowledge_base/cloud_container/learning-path.md)

</div>