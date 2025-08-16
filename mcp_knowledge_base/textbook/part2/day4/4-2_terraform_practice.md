# 4-2. Terraform으로 AWS/GCP 인프라 구축 실습

이 챕터에서는 `4-1`에서 배운 Terraform 기본 개념을 바탕으로, 실제로 AWS와 GCP에 간단한 인프라를 구축하는 핸즈온 실습을 진행합니다. 코드를 통해 클라우드 리소스가 생성되고 관리되는 과정을 직접 경험해보세요.

---

### 실습 목표

- **AWS:** Terraform을 사용하여 실습용 VPC, 서브넷, 보안 그룹, 그리고 EC2 인스턴스 한 대를 생성합니다.
- **GCP:** Terraform을 사용하여 실습용 VPC, 서브넷, 방화벽 규칙, 그리고 Compute Engine 인스턴스 한 대를 생성합니다.

### 실습 준비

- `1-2_account_setup.md` 와 `2-1_cli_setup.md` 챕터가 완료되어 있어야 합니다.
- 각 클라우드 CLI를 통해 인증이 완료된 상태여야 합니다.
- `인터랙티브 학습 도구`의 `환경 점검/스캐폴드`에서 제공하는 Terraform 템플릿(`main.tf`)을 실습할 폴더에 다운로드 받아 준비합니다.

---

### 실습 1: Terraform으로 AWS 인프라 구축하기

1.  **Provider 설정:** `main.tf` 파일에 AWS provider를 설정합니다.

    ```terraform
    terraform {
      required_providers {
        aws = {
          source  = "hashicorp/aws"
          version = "~> 5.0"
        }
      }
    }

    provider "aws" {
      region = "ap-northeast-2" # 서울 리전
    }
    ```

2.  **리소스 정의:** VPC, 서브넷, EC2 인스턴스 리소스를 `main.tf` 파일에 추가합니다.

3.  **인프라 생성:**
    -   `terraform init` 명령어로 초기화합니다.
    -   `terraform plan` 명령어로 실행 계획을 검토합니다.
    -   `terraform apply` 명령어로 실제로 인프라를 생성합니다.

4.  **상태 확인:** `terraform.tfstate` 파일이 생성되고, 내부에 생성된 리소스 정보가 JSON 형태로 기록된 것을 확인합니다. 이 파일을 통해 Terraform이 어떤 리소스를 관리하고 있는지 추적합니다.

5.  **리소스 정리:** `terraform destroy` 명령어로 생성했던 모든 리소스를 한 번에 삭제합니다.

### 실습 2: Terraform으로 GCP 인프라 구축하기

1.  **Provider 설정:** `main.tf` 파일에 GCP provider를 설정합니다.

    ```terraform
    terraform {
      required_providers {
        google = {
          source  = "hashicorp/google"
          version = "~> 5.0"
        }
      }
    }

    provider "google" {
      project = "your-gcp-project-id" # 본인의 GCP 프로젝트 ID
      region  = "asia-northeast3"   # 서울 리전
    }
    ```

2.  **리소스 정의:** VPC, 서브넷, Compute Engine 인스턴스 리소스를 `main.tf` 파일에 추가합니다.

3.  **인프라 생성 및 정리:** AWS 실습과 동일하게 `init` -> `plan` -> `apply` -> `destroy` 순서로 명령을 실행하며 각 단계의 변화를 관찰합니다.

---

### 🔬 관련 도구 및 실습 완료 검증

- **실습 완료 검증:** `appendix_practice_guide.md` 챕터의 `실습 완료 검증` 도구를 사용하여, 이 챕터의 Terraform 실습으로 생성한 S3 버킷이나 Cloud Storage 버킷이 실제로 잘 만들어졌는지 확인해보세요. (실습 내용에 버킷 생성을 추가해보세요!)
- **템플릿 다운로드:** `환경 점검/스캐폴드` 도구에서 제공하는 Terraform 템플릿은 이 챕터의 실습을 위한 훌륭한 시작점입니다.
