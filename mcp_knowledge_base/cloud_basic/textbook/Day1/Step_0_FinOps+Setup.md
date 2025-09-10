**AWS, Azure, GCP를 모두 포함하는 Cloud 실무자 기초교육 커리큘럼**

---

# 📘 Step 0: FinOps / Setup

### 🎯 목표

* 각 클라우드의 계정 생성/구성 방법 이해
* 과금 체계와 비용 예산 설정 실습
* 기본 리소스 구성 (리전/리소스 그룹/프로젝트 등)

---

## 시나리오

**당신은 클라우드 실무자로서 사내 테스트 환경을 세팅해야 합니다. 첫 단계로, 각 클라우드의 계정을 만들고, 리소스를 실행할 기본 환경(리전, 리소스 그룹 등)을 설정한 뒤, 예산을 설정하여 무분별한 과금을 방지하려 합니다.**

---

## 사용자 가이드

### \[AWS]

1. **계정 생성 및 로그인**

   * [https://aws.amazon.com/](https://aws.amazon.com/) 에서 개인/회사 계정 생성
   * Free Tier 사용

2. **리전 설정**

   * 콘솔 우측 상단에서 `Asia Pacific (Seoul)` 선택

3. **Billing Dashboard 접속**

   * `Billing` > `Budgets` > `Create budget`
   * 월 예산: 10 USD 설정

4. **태그 기반 비용 관리**

   * `Cost Allocation Tags` 활성화
   * 예: `Environment=Training`

---

### \[Azure]

1. **Azure 계정 생성**

   * [https://azure.microsoft.com/](https://azure.microsoft.com/) 에서 무료 계정 생성
   * 크레딧 확인 (예: \$200)

2. **리소스 그룹 생성**

   * `리소스 그룹` > `+ 추가` > 이름: `TrainingRG`, 리전: `Korea Central`

3. **비용 분석 및 예산 설정**

   * `Cost Management + Billing` > `Budgets` > `+ Add`
   * 예산: 20,000 KRW

4. **경고 알림 설정**

   * 80%, 100% 도달 시 이메일 알림 설정

---

### \[GCP]

1. **Google Cloud 계정 생성**

   * [https://console.cloud.google.com/](https://console.cloud.google.com/) 에서 계정 생성 후 콘솔 접속
   * Free Tier + \$300 크레딧 확인

2. **프로젝트 생성**

   * `IAM & Admin` > `Create Project` > 이름: `training-project`

3. **Billing 및 예산 설정**

   * `Billing` > `Budgets & alerts` > `Create Budget`
   * 예산: 15 USD 설정

4. **알림 설정**

   * 예산의 50%, 90% 초과 시 이메일 알림

---

