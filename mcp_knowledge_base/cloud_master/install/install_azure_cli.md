# Azure CLI 설치 가이드

<div align="center">

[← 이전: Cloud Master 메인](../../README.md) | [📚 전체 커리큘럼](../../../curriculum.md) | [🏠 학습 경로로 돌아가기](../../../index.md) | [📋 학습 경로](../../../learning-path.md)

</div>

Azure CLI는 Microsoft Azure 클라우드 서비스와 상호작용하기 위한 명령줄 도구입니다. 이 가이드는 다양한 운영체제에서 Azure CLI를 설치하는 방법을 설명합니다.

## 목차
- [Windows 설치](#windows-설치)
- [macOS 설치](#macos-설치)
- [Linux 설치](#linux-설치)
- [Docker를 사용한 설치](#docker를-사용한-설치)
- [설치 확인](#설치-확인)
- [기본 설정](#기본-설정)
- [문제 해결](#문제-해결)

## Windows 설치

### 방법 1: MSI 설치 프로그램 (권장)

1. **Azure CLI MSI 설치 프로그램 다운로드**
   ```bash
   # 최신 버전 다운로드
   https://aka.ms/installazurecliwindows
   ```

2. **설치 실행**
   - 다운로드한 MSI 파일을 더블클릭하여 실행
   - 설치 마법사의 지시를 따름
   - 기본 설치 경로: `C:\Program Files (x86)\Microsoft SDKs\Azure\CLI2\`

3. **PATH 확인**
   - 설치 후 자동으로 PATH에 추가됨
   - 새 명령 프롬프트 창을 열어 확인

### 방법 2: PowerShell을 사용한 설치

```powershell
# PowerShell을 관리자 권한으로 실행
Invoke-WebRequest -Uri https://aka.ms/installazurecliwindows -OutFile .\AzureCLI.msi
Start-Process msiexec.exe -Wait -ArgumentList '/I AzureCLI.msi /quiet'
```

### 방법 3: Chocolatey 사용

```cmd
choco install azure-cli
```

### 방법 4: winget 사용

```cmd
winget install Microsoft.AzureCLI
```

## macOS 설치

### 방법 1: Homebrew 사용 (권장)

1. **Homebrew 설치 확인**
   ```bash
   brew --version
   ```

2. **Azure CLI 설치**
   ```bash
   brew install azure-cli
   ```

### 방법 2: pip 사용

1. **Python 확인**
   ```bash
   python3 --version
   ```

2. **Azure CLI 설치**
   ```bash
   pip3 install azure-cli
   ```

3. **PATH 추가**
   ```bash
   echo 'export PATH=$PATH:~/.local/bin' >> ~/.zshrc
   source ~/.zshrc
   ```

### 방법 3: curl을 사용한 설치

```bash
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
```

## Linux 설치

### Ubuntu/Debian

1. **패키지 업데이트**
   ```bash
   sudo apt update
   ```

2. **Azure CLI 설치**
   ```bash
   # Microsoft의 공식 리포지토리 추가
   curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
   
   # 또는 직접 설치
   sudo apt install azure-cli
   ```

### CentOS/RHEL/Fedora

1. **Microsoft 리포지토리 추가**
   ```bash
   # CentOS/RHEL 7
   sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
   sudo sh -c 'echo -e "[azure-cli]\nname=Azure CLI\nbaseurl=https://packages.microsoft.com/yumrepos/azure-cli\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/azure-cli.repo'
   
   # CentOS/RHEL 8+
   sudo dnf install -y https://packages.microsoft.com/config/rhel/8/packages-microsoft-prod.rpm
   ```

2. **Azure CLI 설치**
   ```bash
   # CentOS/RHEL
   sudo yum install azure-cli
   
   # Fedora
   sudo dnf install azure-cli
   ```

### openSUSE

```bash
sudo zypper install azure-cli
```

### Arch Linux

```bash
sudo pacman -S azure-cli
```

### pip를 사용한 설치 (모든 Linux 배포판)

1. **pip 설치**
   ```bash
   # Ubuntu/Debian
   sudo apt install python3-pip
   
   # CentOS/RHEL
   sudo yum install python3-pip
   ```

2. **Azure CLI 설치**
   ```bash
   pip3 install azure-cli
   ```

## Docker를 사용한 설치

### Docker 이미지 실행

```bash
# 최신 Azure CLI 실행
docker run -it mcr.microsoft.com/azure-cli:latest

# 특정 버전 실행
docker run -it mcr.microsoft.com/azure-cli:2.50.0

# 볼륨 마운트로 설정 유지
docker run -it -v ~/.azure:/root/.azure mcr.microsoft.com/azure-cli:latest
```

### Docker Compose 사용

```yaml
# docker-compose.yml
version: '3.8'
services:
  azure-cli:
    image: mcr.microsoft.com/azure-cli:latest
    volumes:
      - ~/.azure:/root/.azure
    stdin_open: true
    tty: true
```

## 설치 확인

설치가 완료된 후 다음 명령어로 확인할 수 있습니다:

```bash
az --version
```

예상 출력:
```
azure-cli                         2.50.0

core                              2.50.0
telemetry                          1.0.8

Extensions:
azure-devops                      0.25.0

Python location '/opt/az/bin/python3'
Extensions directory '/home/user/.azure/cliextensions'

Python (Linux) 3.10.12 (main, Nov 20 2023, 15:14:05) [GCC 9.4.0]
```

## 기본 설정

### 1. Azure 로그인

```bash
# 대화형 로그인
az login

# 서비스 주체로 로그인
az login --service-principal --username <app-id> --password <password> --tenant <tenant-id>

# 관리 ID로 로그인 (Azure VM에서)
az login --identity
```

### 2. 구독 설정

```bash
# 구독 목록 확인
az account list --output table

# 기본 구독 설정
az account set --subscription "My Subscription Name"

# 현재 구독 확인
az account show
```

### 3. 출력 형식 설정

```bash
# 기본 출력 형식 설정
az configure --defaults output=table

# 사용 가능한 출력 형식: json, jsonc, table, tsv, yaml, yamlc
```

### 4. 지역 설정

```bash
# 기본 지역 설정
az configure --defaults location=koreacentral
```

## 확장 관리

### 확장 설치

```bash
# 특정 확장 설치
az extension add --name <extension-name>

# 예시: Azure DevOps 확장
az extension add --name azure-devops
```

### 확장 목록 및 업데이트

```bash
# 설치된 확장 목록
az extension list --output table

# 확장 업데이트
az extension update --name <extension-name>

# 확장 제거
az extension remove --name <extension-name>
```

## 문제 해결

### 일반적인 문제들

1. **'az' 명령을 찾을 수 없음**
   ```bash
   # PATH 확인
   echo $PATH
   
   # Azure CLI 경로 확인
   which az
   ```

2. **로그인 오류**
   ```bash
   # 로그아웃 후 재로그인
   az logout
   az login
   
   # 브라우저 캐시 클리어
   az login --use-device-code
   ```

3. **권한 오류**
   ```bash
   # 구독 권한 확인
   az account show
   
   # 역할 확인
   az role assignment list --assignee <your-email>
   ```

4. **프록시 설정**
   ```bash
   export HTTP_PROXY=http://proxy.company.com:8080
   export HTTPS_PROXY=http://proxy.company.com:8080
   ```

### 로그 및 디버깅

```bash
# 디버그 모드로 실행
az <command> --debug

# 상세 로그 활성화
az configure --defaults log_level=debug

# 로그 파일 위치
# Windows: %USERPROFILE%\.azure\logs\
# macOS/Linux: ~/.azure/logs/
```

### 성능 최적화

```bash
# 자동 완성 활성화
az --help

# 캐시 클리어
az cache purge

# 원격 분석 비활성화
az configure --defaults collect_telemetry=false
```

## 추가 리소스

- [Azure CLI 공식 문서](https://docs.microsoft.com/en-us/cli/azure/)
- [Azure CLI 명령어 참조](https://docs.microsoft.com/en-us/cli/azure/reference-index)
- [Azure CLI 확장](https://docs.microsoft.com/en-us/cli/azure/azure-cli-extensions-overview)
- [Azure CLI 구성](https://docs.microsoft.com/en-us/cli/azure/azure-cli-configuration)

## 버전 관리

```bash
# 현재 버전 확인
az --version

# 업데이트 (대부분의 설치 방법에서 자동)
# 수동 업데이트가 필요한 경우:
# Windows: MSI 재설치
# macOS: brew upgrade azure-cli
# Linux: 패키지 매니저 업데이트
```

## 보안 모범 사례

1. **서비스 주체 사용**: 개인 계정 대신 서비스 주체 사용
2. **최소 권한 원칙**: 필요한 권한만 부여
3. **MFA 활성화**: 다중 인증 사용
4. **정기적 인증서 갱신**: 서비스 주체 인증서 주기적 변경
5. **조건부 액세스**: IP 제한 및 기타 조건 설정

```bash
# 서비스 주체 생성
az ad sp create-for-rbac --name "myApp" --role contributor --scopes /subscriptions/{subscription-id}/resourceGroups/{resource-group}

# 관리 ID 사용 (권장)
az login --identity
```

## 자동화 및 스크립팅

### Bash 스크립트 예시

```bash
#!/bin/bash
# Azure 리소스 그룹 생성 스크립트

RESOURCE_GROUP="myResourceGroup"
LOCATION="koreacentral"

# 리소스 그룹 생성
az group create --name $RESOURCE_GROUP --location $LOCATION

# VM 생성
az vm create \
  --resource-group $RESOURCE_GROUP \
  --name myVM \
  --image UbuntuLTS \
  --admin-username azureuser \
  --generate-ssh-keys
```

### PowerShell 스크립트 예시

```powershell
# Azure 리소스 그룹 생성 스크립트

$resourceGroup = "myResourceGroup"
$location = "koreacentral"

# 리소스 그룹 생성
az group create --name $resourceGroup --location $location

# VM 생성
az vm create `
  --resource-group $resourceGroup `
  --name myVM `
  --image UbuntuLTS `
  --admin-username azureuser `
  --generate-ssh-keys
```
