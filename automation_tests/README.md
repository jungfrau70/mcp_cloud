# 자동화 테스트 스크립트 가이드

이 디렉토리에는 MentorAi 클라우드 기초 교육 과정의 자동화 스크립트(`mcp_knowledge_base/cloud_basic/automation/cli/`에 위치)가 교재에서 언급된 내용을 올바르게 구현하는지 빠르게 검증하기 위한 테스트 스크립트가 포함되어 있습니다.

각 플랫폼별 스크립트는 해당 플랫폼의 주요 리소스(IAM, 스토리지, 네트워크, VM 고가용성 스택)를 생성하고 검증한 후 정리합니다.

## 스크립트 목록

*   `test_aws_automation.sh`: AWS CLI 자동화 스크립트 검증
*   `test_azure_automation.sh`: Azure CLI 자동화 스크립트 검증
*   `test_gcp_automation.sh`: GCP CLI 자동화 스크립트 검증

## 스크립트 기능

각 테스트 스크립트는 다음 단계를 수행합니다:

1.  **환경 변수 로드**: `env/` 디렉토리의 해당 플랫폼 환경 파일(`aws.env`, `azure.env`, `gcp.env`)에서 설정값을 읽어옵니다.
2.  **자동화 스크립트 실행**: `mcp_knowledge_base/cloud_basic/automation/cli/` 경로에 있는 각 챕터별 CLI 자동화 스크립트(예: `ch1_iam.sh`, `ch2_vm.sh`, `ch3_storage.sh`, `ch4_network.sh`)를 순차적으로 실행합니다.
3.  **리소스 검증**: 플랫폼별 CLI 명령어를 사용하여 생성된 주요 리소스(예: IAM 사용자/그룹, S3 버킷, VPC, VMSS, 로드 밸런서 등)의 존재 여부를 확인합니다.
4.  **리소스 정리**: 테스트 완료 또는 스크립트 실패 시, 생성된 모든 리소스를 자동으로 삭제하여 환경을 깨끗하게 유지하고 불필요한 비용 발생을 방지합니다.

## 실행 방법

1.  **환경 파일 설정**: `env/` 디렉토리 내의 해당 플랫폼 환경 파일(`aws.env`, `azure.env`, `gcp.env`)을 열어 필요한 변수(예: `AWS_REGION`, `LOCATION`, `PROJECT_ID` 등)를 설정합니다. 특히 GCP의 경우 `PROJECT_ID`를 반드시 실제 값으로 변경해야 합니다.
2.  **실행 권한 부여**: 테스트 스크립트에 실행 권한을 부여합니다.
    ```bash
    chmod +x automation_tests/*.sh
    ```
3.  **스크립트 실행**: 원하는 플랫폼의 테스트 스크립트를 실행합니다.
    ```bash
    ./automation_tests/test_aws_automation.sh
    ./automation_tests/test_azure_automation.sh
    ./automation_tests/test_gcp_automation.sh
    ```

## 중요 안내사항

*   **사전 준비**: 각 클라우드 CLI 도구(AWS CLI, Azure CLI, gcloud CLI)가 설치되어 있고, 테스트를 수행할 계정으로 로그인되어 있어야 합니다. 또한, 스크립트가 리소스를 생성하고 삭제할 수 있는 충분한 IAM 권한이 부여되어 있어야 합니다.
*   **Windows 사용자**: `.sh` 스크립트는 Windows에서 직접 실행되지 않습니다. **WSL(Windows Subsystem for Linux)** 또는 **Git Bash**와 같은 Bash 호환 환경에서 실행해야 합니다.
*   **리소스 이름 충돌**: 자동화 스크립트(`mcp_knowledge_base/cloud_basic/automation/cli/`) 내의 일부 리소스 이름은 고정되어 있습니다. 테스트 스크립트는 고유 접미사를 사용하여 이름 충돌을 최소화하지만, 극히 드물게 충돌이 발생할 수 있습니다.
*   **정리 기능**: 스크립트의 `cleanup` 함수는 `trap EXIT`를 통해 스크립트 종료 시 항상 실행되도록 설정되어 있습니다. 하지만 네트워크 문제 등으로 인해 클라우드 API 호출이 완전히 실패하여 리소스가 제대로 삭제되지 않을 수도 있습니다. 스크립트 실행 후에는 해당 클라우드 콘솔에서 리소스가 완전히 정리되었는지 **수동으로 확인**하는 것을 권장합니다.
