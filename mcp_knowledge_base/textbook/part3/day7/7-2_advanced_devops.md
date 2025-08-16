# 7-2. 클라우드 기반 DevOps(CI/CD) 심화 실습

이 챕터에서는 Day 5에서 배운 CI/CD 파이프라인 개념을 한 단계 발전시켜, 인프라 변경까지도 코드로 관리하고 자동화하는 GitOps(깃옵스) 워크플로우를 학습합니다. GitHub Actions와 Terraform을 연동하여, Pull Request 기반으로 인프라 변경을 안전하고 투명하게 관리하는 심화 실습을 진행합니다.

---

### GitOps란 무엇인가?

GitOps는 애플리케이션뿐만 아니라 인프라의 상태까지도 Git 레포지토리에서 관리하는 것을 원칙으로 하는 DevOps의 진화된 방법론입니다. Git을 "단일 진실 공급원(Single Source of Truth)"으로 삼고, Git에 변경사항이 머지(Merge)되면 자동화된 프로세스를 통해 실제 환경에 그 변경사항이 적용되도록 합니다.

**핵심 원칙:**
1.  모든 것은 코드로 선언되어야 한다 (Infrastructure as Code).
2.  Git은 시스템의 원하는 상태를 담은 유일한 진실 공급원이다.
3.  승인된 변경사항은 자동으로 시스템에 적용된다.

### 심화 실습: Pull Request 기반 Terraform 인프라 변경 자동화

이 실습에서는 다음과 같은 GitOps 워크플로우를 GitHub Actions로 구축합니다.

1.  **개발자가 인프라 변경 코드를 작성 (예: `main.tf` 파일 수정)**
2.  **새로운 브랜치를 만들고 코드를 Push한 뒤, `main` 브랜치로 Pull Request(PR)를 생성**
3.  **[자동화 1] PR 생성 시:**
    -   GitHub Actions가 자동으로 `terraform init`과 `terraform plan`을 실행합니다.
    -   `plan`의 실행 결과를 PR의 코멘트로 등록하여, 변경 사항을 모든 팀원이 쉽게 검토할 수 있게 합니다.
4.  **팀원들이 PR에서 실행 계획을 리뷰하고 승인(Approve)**
5.  **PR이 `main` 브랜치로 머지(Merge)**
6.  **[자동화 2] `main` 브랜치에 머지 시:**
    -   GitHub Actions가 다시 한번 `terraform init`과 `terraform plan`을 실행합니다.
    -   최종적으로 `terraform apply -auto-approve`를 실행하여 실제 인프라에 변경 사항을 적용합니다.

#### 예시: GitHub Actions 워크플로우 (`.github/workflows/terraform.yml`)

```yaml
name: 'Terraform CI/CD'

on:
  push:
    branches:
      - main
  pull_request:

jobs:
  terraform:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v3

      # AWS/GCP 인증 설정 (생략)

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v2

      - name: Terraform Init
        run: terraform init

      - name: Terraform Plan (for PR)
        if: github.event_name == 'pull_request'
        run: terraform plan -no-color

      - name: Terraform Apply (for main branch)
        if: github.ref == 'refs/heads/main' && github.event_name == 'push'
        run: terraform apply -auto-approve
```

---

### GitOps의 장점

- **향상된 생산성:** 개발자는 Git에 코드만 푸시하면 되므로, 배포 프로세스에 신경 쓸 필요 없이 개발에만 집중할 수 있습니다.
- **강화된 보안:** 인프라 변경이 Pull Request를 통해 이루어지므로, 동료 검토(Peer Review)가 강제되고 모든 변경 이력이 Git에 남습니다. 또한, 개발자에게 직접 클라우드 콘솔 권한을 부여할 필요가 없습니다.
- **높은 안정성:** 모든 변경사항은 Git을 통해 추적되므로, 문제가 발생했을 때 특정 커밋으로 롤백(Rollback)하는 것이 매우 용이합니다.
- **일관성 및 표준화:** 모든 인프라 변경이 동일한 자동화 파이프라인을 통해 이루어지므로, 사람의 실수로 인한 구성 오류를 방지하고 일관된 상태를 유지할 수 있습니다.
