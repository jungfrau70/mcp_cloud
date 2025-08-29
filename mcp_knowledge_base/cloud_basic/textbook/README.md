# 클라우드 기초 교육 교재

이 디렉토리에는 MentorAi 클라우드 기초 교육 과정의 교재 파일들이 포함되어 있습니다. 각 챕터는 클라우드 핵심 서비스(IAM, 스토리지, VM, 네트워크)에 대한 이론과 실습 가이드를 제공합니다.

## 교재 목록

*   [Chapter0_Overview.md](Chapter0_Overview.md): 실습 아키텍처 개요
*   [Chapter1_IAM.md](Chapter1_IAM.md): 클라우드 계정 및 IAM
*   [Chapter2_Storage.md](Chapter2_Storage.md): 스토리지 서비스
*   [Chapter3_VM.md](Chapter3_VM.md): 가상머신 서비스
*   [Chapter4_Network.md](Chapter4_Network.md): 네트워크 및 보안
*   [Chapter5_Practice.md](Chapter5_Practice.md): 통합 실습 시나리오
*   [Secnario.md](Secnario.md): 클라우드 기초 교육 시나리오 (나만의 블로그 만들기)

---

## 자동화 코드 실행 가이드

이 교육 과정에는 실습을 돕기 위한 자동화 스크립트(CLI 및 Terraform)가 포함되어 있습니다. 원활한 실습을 위해 다음 사항을 반드시 확인해 주세요.

### 1. 실행 환경 설정 (Windows 사용자 필수)

*   제공되는 모든 자동화 스크립트(`.sh` 파일)는 **Bash 쉘 스크립트**입니다.
*   **Windows 운영체제에서는 직접 실행되지 않습니다.**
*   Windows 사용자는 다음 환경 중 하나를 설정하여 스크립트를 실행해야 합니다.
    *   **WSL (Windows Subsystem for Linux)**: 가장 권장되는 방법입니다. Ubuntu, Debian 등 선호하는 Linux 배포판을 설치하여 사용하세요.
    *   **Git Bash**: Git 설치 시 함께 제공되는 Bash 환경입니다.
    *   **Cygwin**: Windows에서 Linux와 유사한 환경을 제공합니다.

### 2. 사전 요구사항 및 도구 설치

*   **클라우드 CLI 도구**: 실습할 클라우드(AWS, Azure, GCP)에 해당하는 CLI 도구를 설치하고 로그인해야 합니다.
    *   AWS CLI: `aws configure`
    *   Azure CLI: `az login`
    *   GCP gcloud CLI: `gcloud auth login`
*   **Terraform**: Terraform을 사용하여 인프라를 배포할 경우, Terraform CLI를 설치해야 합니다.
*   **권한**: 스크립트가 클라우드 리소스를 생성할 수 있도록, 사용 중인 클라우드 계정에 충분한 IAM 권한(예: `AdministratorAccess` 또는 `Contributor` 역할)이 부여되어 있어야 합니다.
*   **권장 도구 버전**: 특정 버전 문제가 발생할 경우, 교재 또는 각 클라우드 공식 문서에서 권장하는 최신 안정 버전을 사용해 주세요.

### 3. 리소스 이름 충돌 방지 (CLI 스크립트 사용 시)

*   CLI 스크립트는 리소스 이름이 고정되어 있어, 여러 번 실행하거나 다른 사용자와 동시에 실행할 경우 이름 충돌이 발생할 수 있습니다.
*   **해결책**: 스크립트 내에서 리소스 이름을 정의하는 부분(예: `VM_NAME="web-01"`, `SG_NAME="lab-web-sg-ha"`)을 찾아, 자신만의 고유한 접미사(예: `web-01-YOURNAME`, `lab-web-sg-ha-XYZ`)를 추가하여 사용하세요.

### 4. Terraform 사용 권장

*   **Terraform**은 인프라를 코드로 관리하는(IaC) 도구로, 리소스의 생성, 업데이트, 삭제를 훨씬 안정적으로 수행합니다.
*   Terraform은 **멱등성(Idempotency)**을 보장하여, 스크립트를 여러 번 실행해도 동일한 최종 상태를 유지하며 이름 충돌이나 중복 생성 문제를 자동으로 처리합니다.
*   각 챕터의 Terraform 예제는 CLI 스크립트보다 더 견고하고 실무적인 경험을 제공하므로, 가급적 Terraform을 사용하여 실습하는 것을 권장합니다.

### 5. 실습 후 리소스 정리 (비용 관리)

*   **매우 중요**: 클라우드 리소스는 사용한 만큼 비용이 발생합니다. 실습을 완료한 후에는 **반드시 생성했던 모든 리소스를 삭제**해야 합니다.
*   **Terraform 사용 시**: `terraform destroy` 명령어를 사용하여 생성했던 모든 리소스를 한 번에 쉽게 삭제할 수 있습니다.
*   **CLI 사용 시**: 각 클라우드 콘솔 또는 CLI 명령어를 통해 수동으로 리소스를 삭제해야 합니다.

이 가이드를 통해 모든 학습자가 자동화 코드를 안전하고 효율적으로 활용하여 클라우드 실습을 성공적으로 마칠 수 있기를 바랍니다.
