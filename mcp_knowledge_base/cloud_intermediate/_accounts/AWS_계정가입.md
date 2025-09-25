# AWS 계정 가입 및 권한 위임 가이드


## 📋 개요

이 문서는 개인 이메일로 AWS에 가입한 후, 조직용 관리자 계정을 생성하고 권한을 위임하는 전체 과정을 단계별로 안내합니다.

### 🎯 목표
- **개인 이메일["AWS 계정 가입"]** → **itadmin 계정 생성** → **IAM 및 AWS 리소스 전체 권한 위임**

---

## 1️⃣ 기본 개념 정리

### 계정 유형 구분
- **AWS 계정 가입 계정**: `hong.gildong@<domain-name>.com` ["Root 계정"]
  - AWS에 처음 가입한 계정
  - 기본적으로 **Root 사용자** 권한 보유
- **itadmin 계정**: IAM에 새로 만든 조직 계정
  - 예: `itadmin@<account-id>.aws` 또는 `itadmin`

### 권한 구조 이해
AWS에서는 **Root 계정**과 **IAM 사용자**를 구분하며, 보안상 Root 계정은 최소한으로 사용하고 IAM 사용자로 모든 작업을 수행하는 것이 권장됩니다.

---

## 2️⃣ itadmin 계정 생성

### 단계별 진행
1. `hong.gildong@<domain-name>.com` 계정으로 [AWS Management Console][https:///console.aws.amazon.com] 로그인
2. **IAM [Identity and Access Management]** 서비스 이동
3. **사용자[Users]** → **사용자 생성[Create user]** 클릭
4. 계정 정보 입력:
   - 사용자 이름: `itadmin`
   - 액세스 유형: **프로그래밍 방식 액세스** + **AWS Management Console 액세스** 모두 선택
   - 콘솔 암호: **사용자 지정 암호** 선택 → 안전한 암호 설정

---

## 3️⃣ IAM 관리자 권한 부여

### AdministratorAccess 정책 연결
1. **권한 설정[Permissions]** 단계에서
2. **기존 정책 직접 연결[Attach existing policies directly]** 선택
3. **AdministratorAccess** 정책 검색 후 선택
4. **다음: 태그[Next: Tags]** → **다음: 검토[Next: Review]** → **사용자 생성[Create user]**

> ✅ 이렇게 하면 `itadmin`은 AWS 서비스 전체 관리 권한을 가집니다.

> **중요** IAM 사용자에게 Billing 권한 허용 필요

기본적으로 AWS 계정 root 외 IAM 사용자는 Billing 콘솔 접근 불가

**해결 방법:**
1. **루트 계정으로 로그인**
2. **계정 설정[Account Settings]** → **IAM 사용자 및 역할에 결제 정보 접근 허용[Activate IAM Access for Billing]** 체크
3. **화면 위치**: https:///console.aws.amazon.com/billing/home?#/account → "IAM 사용자 및 역할이 결제 정보에 접근할 수 있도록 활성화"
4. **활성화 후** IAM 사용자에 Billing 관련 정책 할당

---

## 4️⃣ 비용 관리 권한 부여

### Billing 권한 추가
비용 관리와 결제 정보 접근을 위해 추가 권한이 필요합니다.

> **⚠️ 사전 요구사항**: Root 계정에서 IAM 사용자의 Billing 접근을 먼저 활성화해야 합니다.

#### 1단계: Root 계정에서 IAM Billing 접근 활성화
1. **Root 계정으로 로그인** [hong.gildong@<domain-name>.com]
2. **Billing 콘솔** 이동: https:///console.aws.amazon.com/billing/home
3. **계정 설정[Account Settings]** 클릭
4. **"IAM 사용자 및 역할이 결제 정보에 접근할 수 있도록 활성화"** 체크박스 선택
5. **업데이트** 클릭

#### 2단계: IAM 사용자에 Billing 권한 추가
1. **IAM** → **사용자[Users]** → `itadmin` 선택
2. **권한[Permissions]** 탭 → **권한 추가[Add permissions]**
3. **기존 정책 직접 연결** 선택
4. 다음 정책들 검색 후 선택:
   - **Billing** ["청구서 및 결제 정보 관리"]
   - **CostExplorerServiceFullAccess** ["비용 분석 도구 접근"]

#### 3단계: 사용자 정의 정책 생성 ["선택사항"]
```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "aws-portal:*",
                "billing:*",
                "ce:*",
                "cur:*",
                "pricing:*"
            ],
            "Resource": "*"
        }
    ]
}
```

### 비용 관리 관련 권한 설명

| 권한 | 범위 | 용도 |
|------|------|------|
| **Billing** | 청구서, 결제 방법, 크레딧 관리 | 비용 관리자 |
| **CostExplorerServiceFullAccess** | 비용 분석, 예산 설정, 알림 관리 | 비용 최적화 |
| **CostAndUsageReportFullAccess** | 상세 사용량 보고서 생성 | 비용 보고서 |
| **PricingFullAccess** | AWS 서비스 가격 정보 조회 | 비용 예측 |

> 💡 **권장**: `itadmin` 계정에는 **AdministratorAccess** + **Billing** + **CostExplorerServiceFullAccess** 권한을 모두 부여하여 완전한 관리 권한을 제공합니다.

---

## 5️⃣ MFA["다중 인증"] 설정

### 가상 MFA 디바이스 설정
1. **IAM** → **사용자[Users]** → `itadmin` 선택
2. **보안 자격 증명[Security credentials]** 탭
3. **MFA 디바이스 할당[Assign MFA device]** 클릭
4. **가상 MFA 디바이스[Virtual MFA device]** 선택
5. QR 코드를 스캔하여 Google Authenticator 등에 등록
6. 연속된 두 개의 MFA 코드 입력

> ✅ **보안 강화**: 높은 권한을 가진 계정에는 반드시 MFA 설정을 권장합니다.

---

## 6️⃣ 최종 점검

### 권한 확인 방법
`itadmin` 계정으로 로그인 후:

1. **IAM 권한 확인**:
   - IAM → 사용자 → `itadmin` → **권한[Permissions]**
   - **AdministratorAccess** 표시 확인

2. **비용 관리 권한 확인**:
   - **비용 및 사용량[Cost and Usage]** 메뉴 접근 가능 여부 확인
   - **비용 탐색기[Cost Explorer]** 접근 가능 여부 확인

3. **서비스 접근 확인**:
   - EC2, S3, RDS 등 주요 서비스 접근 가능 여부 확인

---

## ✅ 최종 권한 구조

| 계정 | 역할 | 권한 범위 |
|------|------|-----------|
| `hong.gildong@<domain-name>.com` | Root 사용자 | AWS 계정 전체 관리, 결제 계정 관리 |
| `itadmin` | AdministratorAccess + Billing | AWS 서비스 + 비용 관리 전체 |

### 상세 권한 내역
- **AdministratorAccess**: 모든 AWS 서비스 및 리소스 관리
- **Billing**: 청구서, 결제 정보, 크레딧 관리
- **CostExplorerServiceFullAccess**: 비용 분석, 예산 설정, 알림 관리

> 💡 **결과**: `hong.gildong@<domain-name>.com`은 Root 계정["백업 관리자"]으로 두고, 실제 운영은 `itadmin`이 **AWS 서비스 + 비용 관리 풀 관리자** 권한으로 운영할 수 있습니다.

---

## 🔧 자동화 스크립트

### AWS CLI를 이용한 권한 할당 자동화

```bash
# 1. itadmin 사용자 생성
aws iam create-user --user-name itadmin

# 2. AdministratorAccess 정책 연결
aws iam attach-user-policy /
  --user-name itadmin /
  --policy-arn arn:aws:iam::aws:policy/AdministratorAccess

# 3. 비용 관리 권한 추가
aws iam attach-user-policy /
  --user-name itadmin /
  --policy-arn arn:aws:iam::aws:policy/Billing

aws iam attach-user-policy /
  --user-name itadmin /
  --policy-arn arn:aws:iam::aws:policy/CostExplorerServiceFullAccess

# 4. 콘솔 로그인 프로필 생성
aws iam create-login-profile /
  --user-name itadmin /
  --password 'YourSecurePassword123!' /
  --password-reset-required

# 5. 액세스 키 생성 ["선택사항"]
aws iam create-access-key --user-name itadmin
```

### PowerShell을 이용한 권한 할당

```powershell
# AWS PowerShell 모듈 설치
Install-Module -Name AWS.Tools.Common -Force

# 1. itadmin 사용자 생성
New-IAMUser -UserName itadmin

# 2. AdministratorAccess 정책 연결
Register-IAMUserPolicy -UserName itadmin -PolicyArn "arn:aws:iam::aws:policy/AdministratorAccess"

# 3. 비용 관리 권한 추가
Register-IAMUserPolicy -UserName itadmin -PolicyArn "arn:aws:iam::aws:policy/Billing"
Register-IAMUserPolicy -UserName itadmin -PolicyArn "arn:aws:iam::aws:policy/CostExplorerServiceFullAccess"
```

---

## 📚 FAQ - 자주 묻는 질문

### Q1: 그룹에 AdministratorAccess 권한을 할당할 수 있나요?

**A**: 네, 가능합니다. AWS IAM에서는 그룹 기반 권한 관리가 기본적으로 지원됩니다.

#### 그룹 기반 권한 할당 방법:
1. **IAM → 그룹[Groups]** → **그룹 생성[Create group]**
   - 그룹 이름: `Administrators`
2. **IAM → 그룹 → Administrators → 권한[Permissions]**
   - **권한 추가[Add permissions]** 클릭
   - **AdministratorAccess** 정책 선택
3. **IAM → 그룹 → Administrators → 사용자[Users]**
   - **사용자 추가[Add users]** → `itadmin` 선택

### Q2: "액세스가 거부되었습니다" 오류가 발생해요

**A**: Root 계정이 아닌 IAM 사용자로 작업 중일 가능성이 높습니다.

#### 해결 방법:
1. **Root 계정으로 로그인** 확인
2. **IAM 정책 권한** 확인
3. **리전[Region] 설정** 확인 ["일부 서비스는 특정 리전에서만 동작"]

### Q3: Root 계정과 IAM 사용자의 차이는?

**A**: 권한 범위와 보안 수준이 다릅니다.

| 구분 | Root 계정 | IAM 사용자 |
|------|-----------|------------|
| **권한 범위** | AWS 계정 전체 ["제한 불가"] | 정책으로 제한 가능 |
| **보안** | MFA만 가능 | MFA + 임시 자격 증명 |
| **사용 권장** | 최소한으로 사용 | 일상적인 작업용 |
| **계정 설정** | 결제 정보, 계정 설정 | 불가능 |

### Q4: 비용 관리 권한이 왜 필요한가요?

**A**: AWS 리소스 사용량과 비용을 모니터링하고 관리하기 위해 필요합니다.

#### 비용 관리 권한이 필요한 이유:
- **비용 모니터링**: 리소스별 사용량 및 비용 추적
- **예산 설정**: 월별/연별 예산 한도 설정 및 알림
- **비용 최적화**: 불필요한 리소스 식별 및 정리
- **청구서 관리**: 결제 정보 및 청구서 확인
- **비용 분석**: 서비스별/리전별 비용 분석

### Q5: MFA 설정이 필수인가요?

**A**: 보안상 강력히 권장됩니다.

#### MFA 설정 이유:
- **보안 강화**: 계정 탈취 위험 감소
- **규정 준수**: 많은 기업 정책에서 MFA 필수
- **AWS 권장사항**: 높은 권한을 가진 계정의 MFA 설정 권장

---

## 🔐 보안 권장사항

### Root 계정 보안
- **Root 계정 사용 최소화**: 일상적인 작업은 IAM 사용자 사용
- **MFA 필수 설정**: Root 계정에 반드시 MFA 활성화
- **액세스 키 생성 금지**: Root 계정에는 액세스 키 생성하지 않기

### IAM 사용자 보안
- **최소 권한 원칙**: 필요한 최소한의 권한만 부여
- **정기적인 권한 검토**: 사용하지 않는 권한 제거
- **액세스 키 로테이션**: 정기적인 액세스 키 교체

### 추가 보안 설정
- **CloudTrail 활성화**: 모든 API 호출 로깅
- **Config 활성화**: 리소스 변경 사항 추적
- **GuardDuty 활성화**: 위협 탐지 및 대응

---

## 🚀 다음 단계

### 추가 학습 자료
- ["AWS IAM 공식 문서"][https:///docs.aws.amazon.com/iam/]
- ["AWS 비용 관리 가이드"][https:///docs.aws.amazon.com/cost-management/]
- ["AWS CLI 사용법"][https:///docs.aws.amazon.com/cli/latest/userguide/]

### 자동화 확장
- CloudFormation을 이용한 IAM 정책 자동화
- AWS Organizations를 이용한 다중 계정 관리
- AWS Config를 이용한 보안 정책 자동화

---

## 📞 문제 해결

### 일반적인 오류 및 해결방법
1. **권한 부족 오류**: IAM 정책 권한 확인
2. **액세스 키 오류**: 액세스 키 권한 및 만료일 확인
3. **리전 오류**: 서비스가 지원하는 리전 확인

### 지원 채널
- ["AWS 지원 센터"][https:///console.aws.amazon.com/support/]
- ["AWS 커뮤니티 포럼"][https:///forums.aws.amazon.com/]
- ["AWS 기술 문서"][https:///docs.aws.amazon.com/]


---


### 📧 연락처
- **이메일**: inhwan.jung@gmail.com
- **GitHub**: ["프로젝트 저장소"][https:///github.com/jungfrau70/aws_gcp.git]

---



<div align="center">

["← 이전: Cloud Master 메인"][README.md] | ["📚 전체 커리큘럼"][curriculum.md] | ["🏠 학습 경로로 돌아가기"][index.md] | ["📋 학습 경로"][learning-path.md]

</div>