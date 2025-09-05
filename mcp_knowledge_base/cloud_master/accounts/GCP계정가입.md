# GCP 계정 가입 및 권한 위임 가이드

## 📋 개요

이 문서는 개인 Google 계정으로 GCP에 가입한 후, 조직용 관리자 계정을 생성하고 권한을 위임하는 전체 과정을 단계별로 안내합니다.

### 🎯 목표
- **개인 Google 계정(GCP 가입 계정)** → **itadmin 계정 생성** → **IAM 및 GCP 리소스 전체 권한 위임**

---

## 1️⃣ 기본 개념 정리

### 계정 유형 구분
- **GCP 가입 계정**: `hong.gildong@<domain-name>.com` (Google 계정)
  - GCP에 처음 가입한 계정
  - 기본적으로 **프로젝트의 Owner** 역할 보유
- **itadmin 계정**: Google Workspace 또는 Cloud Identity에 새로 만든 조직 계정
  - 예: `itadmin@<domain>.com` 또는 `itadmin@<project-id>.iam.gserviceaccount.com`

### 권한 구조 이해
GCP에서는 **프로젝트 레벨**과 **조직 레벨** 권한을 구분하며, **IAM(Identity and Access Management)**을 통해 세밀한 권한 제어가 가능합니다.

---

## 2️⃣ itadmin 계정 생성

GCP에서는 조직(Organization) 단위에서 사용자 관리 기능이 활성화됩니다.
개인 계정(예: Gmail 계정)으로 만든 프로젝트는 조직이 없으므로, IAM에서 사용자 초대는 가능하지만 일부 UI 기능이 제한됩니다.
즉, Gmail 계정 프로젝트에서는 사용자 추가 버튼 대신 프로젝트 수준에서 직접 IAM 멤버를 추가해야 합니다.

### 방법 1: Google Workspace 사용 (권장)
1. `hong.gildong@<domain-name>.com` 계정으로 [Google Cloud Console](https://console.cloud.google.com) 로그인
2. **IAM 및 관리자(IAM & Admin)** → **사용자(Users)**
3. **사용자 추가(Add users)** 클릭
4. 계정 정보 입력:
   - 이메일: `itadmin@<domain>.com`
   - 역할: **기본 역할** 또는 **사용자 정의 역할** 선택

### 방법 2: Cloud Identity 사용
1. [Cloud Identity 관리 콘솔](https://admin.google.com) 접속
2. **사용자(Users)** → **사용자 추가(Add user)**
3. 계정 정보 입력:
   - 이름: `itadmin`
   - 이메일: `itadmin@<domain>.com`
   - 임시 비밀번호 설정

---

## 3️⃣ IAM 관리자 권한 부여

### Owner 역할 할당
1. **IAM 및 관리자(IAM & Admin)** → **IAM**
2. **+ 추가(Add)** 클릭
3. 새 멤버 추가:
   - 새 멤버: `itadmin@<domain>.com`
   - 역할: **기본 역할** → **Owner** 선택
4. **저장(Save)** 클릭

> ✅ 이렇게 하면 `itadmin`은 프로젝트 내 모든 리소스 관리 권한을 가집니다.

### 조직 레벨 권한 (조직이 있는 경우)
1. **IAM 및 관리자** → **조직(Organization)**
2. **IAM** 탭 선택
3. **+ 추가(Add)** 클릭
4. 새 멤버 추가:
   - 새 멤버: `itadmin@<domain>.com`
   - 역할: **조직 관리자(Organization Administrator)** 선택

---

## 4️⃣ 비용 관리 권한 부여

### Billing Account Administrator 역할 할당
비용 관리와 결제 정보 접근을 위해 추가 권한이 필요합니다.

#### 방법 1: Billing Account 레벨에서 권한 부여
1. **결제(Billing)** 메뉴 이동
2. **결제 계정(Billing Account)** 선택
3. **IAM 권한(IAM permissions)** 탭 선택
4. **+ 추가(Add)** 클릭
5. 새 멤버 추가:
   - 새 멤버: `itadmin@<domain>.com`
   - 역할: **결제 계정 관리자(Billing Account Administrator)** 선택

#### 방법 2: 프로젝트 레벨에서 Billing 권한 부여
1. **IAM 및 관리자** → **IAM**
2. **+ 추가(Add)** 클릭
3. 새 멤버 추가:
   - 새 멤버: `itadmin@<domain>.com`
   - 역할: **기본 역할** → **결제 계정 사용자(Billing Account User)** 선택

### 비용 관리 관련 역할 설명

| 역할 | 권한 범위 | 용도 |
|------|-----------|------|
| **Billing Account Administrator** | 결제 정보, 청구서, 결제 방법 관리 | 비용 관리자 |
| **Billing Account User** | 프로젝트를 결제 계정에 연결 | 프로젝트 관리자 |
| **Billing Account Viewer** | 결제 정보 조회만 가능 | 비용 모니터링 |
| **Cost Management Admin** | 비용 분석, 예산 설정, 알림 관리 | 비용 최적화 |

> 💡 **권장**: `itadmin` 계정에는 **Owner** + **Billing Account Administrator** + **Cost Management Admin** 역할을 모두 부여하여 완전한 관리 권한을 제공합니다.

---

## 5️⃣ 서비스 계정 생성 (선택사항)

### 서비스 계정 생성
API 호출이나 자동화를 위한 서비스 계정을 생성할 수 있습니다.

1. **IAM 및 관리자** → **서비스 계정(Service Accounts)**
2. **서비스 계정 만들기(Create Service Account)** 클릭
3. 서비스 계정 정보 입력:
   - 서비스 계정 이름: `itadmin-service`
   - 서비스 계정 ID: `itadmin-service`
   - 설명: `IT Admin Service Account`
4. **만들기(Create)** 클릭

### 서비스 계정 권한 부여
1. **역할 선택** 단계에서:
   - **기본 역할** → **Owner** 선택
   - 또는 **사용자 정의 역할** 생성
2. **완료(Done)** 클릭

### 서비스 계정 키 생성
1. 생성된 서비스 계정 클릭
2. **키(Keys)** 탭 선택
3. **키 추가(Add Key)** → **새 키 만들기(Create new key)**
4. **JSON** 형식 선택 → **만들기(Create)**
5. 키 파일 다운로드 및 안전하게 보관

---

## 6️⃣ 최종 점검

### 권한 확인 방법
`itadmin` 계정으로 로그인 후:

1. **프로젝트 권한 확인**:
   - **IAM 및 관리자** → **IAM**
   - `itadmin@<domain>.com` → **Owner** 역할 확인

2. **비용 관리 권한 확인**:
   - **결제** 메뉴 접근 가능 여부 확인
   - **결제 계정** → **IAM 권한**에서 **Billing Account Administrator** 확인

3. **서비스 접근 확인**:
   - Compute Engine, Cloud Storage, BigQuery 등 주요 서비스 접근 가능 여부 확인

---

## ✅ 최종 권한 구조

| 계정 | 역할 | 권한 범위 |
|------|------|-----------|
| `hong.gildong@<domain-name>.com` | 프로젝트 Owner | GCP 프로젝트 전체 관리, 결제 계정 관리 |
| `itadmin@<domain>.com` | Owner + Billing Account Administrator | GCP 서비스 + 비용 관리 전체 |

### 상세 권한 내역
- **Owner**: 프로젝트 내 모든 리소스 관리
- **Billing Account Administrator**: 결제 정보, 청구서, 결제 방법 관리
- **Cost Management Admin**: 비용 분석, 예산 설정, 알림 관리

> 💡 **결과**: `hong.gildong@<domain-name>.com`은 초기 가입 계정(백업 관리자)으로 두고, 실제 운영은 `itadmin`이 **GCP 서비스 + 비용 관리 풀 관리자** 권한으로 운영할 수 있습니다.

---

## 🔧 자동화 스크립트

### gcloud CLI를 이용한 권한 할당 자동화

```bash
# 1. 프로젝트 설정
export PROJECT_ID="your-project-id"
gcloud config set project $PROJECT_ID

# 2. itadmin 사용자에 Owner 역할 할당
gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="user:itadmin@<domain>.com" \
  --role="roles/owner"

# 3. 비용 관리 권한 추가
gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="user:itadmin@<domain>.com" \
  --role="roles/billing.user"

# 4. 서비스 계정 생성
gcloud iam service-accounts create itadmin-service \
  --display-name="IT Admin Service Account" \
  --description="Service account for IT admin operations"

# 5. 서비스 계정에 Owner 역할 할당
gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:itadmin-service@$PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/owner"

# 6. 서비스 계정 키 생성
gcloud iam service-accounts keys create itadmin-service-key.json \
  --iam-account=itadmin-service@$PROJECT_ID.iam.gserviceaccount.com
```

### Terraform을 이용한 권한 할당

```hcl
# main.tf
resource "google_project_iam_member" "itadmin_owner" {
  project = var.project_id
  role    = "roles/owner"
  member  = "user:itadmin@<domain>.com"
}

resource "google_project_iam_member" "itadmin_billing" {
  project = var.project_id
  role    = "roles/billing.user"
  member  = "user:itadmin@<domain>.com"
}

resource "google_service_account" "itadmin_service" {
  account_id   = "itadmin-service"
  display_name = "IT Admin Service Account"
  description  = "Service account for IT admin operations"
}

resource "google_project_iam_member" "service_account_owner" {
  project = var.project_id
  role    = "roles/owner"
  member  = "serviceAccount:${google_service_account.itadmin_service.email}"
}
```

---

## 📚 FAQ - 자주 묻는 질문

### Q1: 조직(Organization)이 없어도 관리자 권한을 부여할 수 있나요?

**A**: 네, 가능합니다. 프로젝트 레벨에서도 충분한 관리자 권한을 부여할 수 있습니다.

#### 프로젝트 레벨 관리:
- **Owner** 역할: 프로젝트 내 모든 리소스 관리
- **Editor** 역할: 리소스 생성/수정 (삭제 제외)
- **Viewer** 역할: 리소스 조회만 가능

### Q2: "권한이 부족합니다" 오류가 발생해요

**A**: 프로젝트 Owner 권한이 필요한 작업인지 확인하세요.

#### 해결 방법:
1. **프로젝트 선택** 확인 (올바른 프로젝트에 로그인했는지)
2. **IAM 권한** 확인 (Owner 또는 필요한 역할이 할당되었는지)
3. **조직 정책** 확인 (조직 레벨에서 제한이 있는지)

### Q3: Google Workspace와 Cloud Identity의 차이는?

**A**: 기능 범위와 비용이 다릅니다.

| 구분 | Google Workspace | Cloud Identity |
|------|------------------|----------------|
| **기능** | G Suite + GCP 관리 | GCP 관리 전용 |
| **비용** | 유료 | 무료 (제한적) |
| **사용자 관리** | 완전한 사용자 관리 | 기본적인 사용자 관리 |
| **GCP 통합** | 완전 통합 | GCP 중심 |

### Q4: 서비스 계정이 필요한가요?

**A**: API 호출이나 자동화가 필요한 경우에만 생성하면 됩니다.

#### 서비스 계정 사용 사례:
- **API 호출**: 프로그래밍 방식으로 GCP 서비스 사용
- **자동화**: CI/CD 파이프라인, 스크립트 실행
- **애플리케이션**: 서버리스 애플리케이션에서 GCP 서비스 사용

#### 서비스 계정 보안:
- **키 로테이션**: 정기적인 키 교체
- **최소 권한**: 필요한 최소한의 권한만 부여
- **키 보관**: 안전한 곳에 키 파일 보관

### Q5: 비용 관리 권한이 왜 필요한가요?

**A**: GCP 리소스 사용량과 비용을 모니터링하고 관리하기 위해 필요합니다.

#### 비용 관리 권한이 필요한 이유:
- **비용 모니터링**: 리소스별 사용량 및 비용 추적
- **예산 설정**: 월별/연별 예산 한도 설정 및 알림
- **비용 최적화**: 불필요한 리소스 식별 및 정리
- **청구서 관리**: 결제 정보 및 청구서 확인
- **비용 분석**: 서비스별/리전별 비용 분석

### Q6: Billing Account Administrator와 Billing Account User의 차이는?

**A**: 관리 범위와 권한이 다릅니다.

| 구분 | Billing Account Administrator | Billing Account User |
|------|------------------------------|---------------------|
| **결제 관리** | ✅ 결제 정보, 청구서, 결제 방법 관리 | ❌ 결제 정보 접근 불가 |
| **프로젝트 연결** | ✅ 프로젝트를 결제 계정에 연결/해제 | ✅ 프로젝트를 결제 계정에 연결 |
| **사용자 관리** | ✅ 결제 계정 사용자 추가/제거 | ❌ 사용자 관리 불가 |
| **비용 분석** | ✅ 비용 분석 조회 | ✅ 비용 분석 조회 |

---

## 🔐 보안 권장사항

### 계정 보안
- **2단계 인증**: 모든 계정에 2단계 인증 설정
- **강력한 비밀번호**: 복잡하고 고유한 비밀번호 사용
- **정기적인 비밀번호 변경**: 3-6개월마다 비밀번호 변경

### 서비스 계정 보안
- **키 로테이션**: 90일마다 서비스 계정 키 교체
- **최소 권한**: 필요한 최소한의 권한만 부여
- **키 보관**: 환경 변수나 비밀 관리 도구 사용

### 추가 보안 설정
- **Cloud Audit Logs**: 모든 API 호출 로깅
- **Security Command Center**: 보안 위협 탐지
- **VPC Service Controls**: 데이터 보호 경계 설정

---

## 🚀 다음 단계

### 추가 학습 자료
- [GCP IAM 공식 문서](https://cloud.google.com/iam/docs)
- [GCP 비용 관리 가이드](https://cloud.google.com/billing/docs)
- [gcloud CLI 사용법](https://cloud.google.com/sdk/docs)

### 자동화 확장
- Terraform을 이용한 IAM 정책 자동화
- Cloud Build를 이용한 CI/CD 파이프라인
- Cloud Functions를 이용한 이벤트 기반 자동화

---

## 📞 문제 해결

### 일반적인 오류 및 해결방법
1. **권한 부족 오류**: IAM 역할 권한 확인
2. **프로젝트 오류**: 올바른 프로젝트 선택 확인
3. **API 오류**: 필요한 API 활성화 확인

### 지원 채널
- [GCP 지원 센터](https://cloud.google.com/support/)
- [GCP 커뮤니티 포럼](https://cloud.google.com/community/)
- [GCP 기술 문서](https://cloud.google.com/docs/)
