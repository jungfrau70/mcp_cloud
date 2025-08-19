
---
tags: [advanced, devops, ci-cd]
---
# 5-2. CI/CD 파이프라인 구축 (GitHub Actions, Docker)

이 챕터에서는 DevOps 문화를 이해하고, 클라우드 네이티브 CI/CD(지속적 통합/지속적 배포) 파이프라인을 구축하는 방법을 배웁니다. 애플리케이션 코드를 변경했을 때, 빌드, 테스트, 배포의 전 과정이 자동으로 이루어지는 파이프라인을 직접 만들어보며 개발 생산성을 극대화하는 방법을 체득합니다.

---

### 🎯 이 챕터의 목표

- [ ] **DevOps 문화 이해:** DevOps의 핵심 철학(CALMS: Culture, Automation, Lean, Measurement, Sharing)을 이해하고, 왜 클라우드 환경에서 DevOps가 중요한지 설명할 수 있습니다.
- [ ] **CI/CD 서비스:** AWS CodePipeline, CodeBuild, CodeDeploy와 GCP Cloud Build, Cloud Deploy의 역할을 이해하고, CI/CD 파이프라인의 각 단계를 설명할 수 있습니다.
- [ ] **S3 정적 웹사이트 자동 배포:** GitHub에 소스 코드를 푸시(Push)하면, 자동으로 S3 버킷에 새로운 버전의 정적 웹사이트가 배포되는 파이프라인을 AWS CodePipeline으로 구축할 수 있습니다.
- [ ] **컨테이너 이미지 자동 빌드:** 소스 코드가 변경되면, 자동으로 새로운 컨테이너 이미지를 빌드하여 ECR(Elastic Container Registry) 또는 Artifact Registry에 푸시하는 파이프라인을 GCP Cloud Build로 구축할 수 있습니다.
- [ ] **IaC와 CI/CD 연동:** Terraform 코드를 CI/CD 파이프라인에 통합하여, 인프라 변경사항을 자동으로 계획(`plan`)하고 적용(`apply`)하는 GitOps의 기본 개념을 이해할 수 있습니다.

---

### 🚀 관련 실습

- 이 챕터의 핵심은 직접 파이프라인을 구축하는 것입니다. 챕터 내의 상세 가이드를 따라 GitHub 레포지토리를 만들고, AWS 또는 GCP의 CI/CD 서비스와 연동하여 코드 변경이 자동으로 배포로 이어지는 마법을 경험해보세요.

---

### 💡 알아두면 좋은 점

- **CI/CD는 속도와 안정성, 두 마리 토끼를 잡는 기술:** CI/CD 파이프라인은 단순히 배포를 자동화하는 것을 넘어, 모든 변경사항이 테스트를 거치도록 강제하여 안정성을 높이고, 개발자들이 코드에만 집중할 수 있게 하여 개발 속도를 향상시키는 핵심 DevOps 기술입니다.
- **파이프라인도 코드다(Pipeline as Code):** Jenkinsfile, `buildspec.yml`(AWS), `cloudbuild.yaml`(GCP)과 같이 파이프라인의 정의 자체를 코드로 관리하는 것이 현대적인 방식입니다. 이를 통해 파이프라인의 변경 이력을 추적하고, 재사용하며, 일관성을 유지할 수 있습니다.
