# GCP 조직 계정 가입 및 관리 가이드

<div align="center">

[← 이전: Cloud Container 메인](../../README.md) | [📚 전체 커리큘럼](../../curriculum.md) | [🏠 학습 경로로 돌아가기](../../index.md) | [📋 학습 경로](../../learning-path.md)

</div>

## 📋 개요

이 문서는 Google Workspace 또는 Cloud Identity를 사용하여 GCP 조직 계정을 설정하고, 사용자 및 그룹 관리를 포함한 전체적인 조직 관리 과정을 단계별로 안내합니다.

### 🎯 목표
- **조직(Organization)** 생성 및 설정
- **사용자 및 그룹** 관리
- **IAM 정책** 및 **조직 정책** 설정
- **비용 관리** 및 **보안** 설정

---

## 1️⃣ 조직 계정 유형 선택

### 1.1 Google Workspace (권장)
**완전한 비즈니스 솔루션**
- G Suite + GCP 관리 통합
- 이메일, 캘린더, 드라이브 포함
- 사용자 관리 및 보안 정책 완전 지원

| 플랜 | 가격 | 사용자당/월 | GCP 통합 |
|------|------|-------------|----------|
| **Business Starter** | $6 | 30GB | ✅ |
| **Business Standard** | $12 | 2TB | ✅ |
| **Business Plus** | $18 | 5TB | ✅ |

### 1.2 Cloud Identity (무료)
**GCP 관리 전용**
- GCP 사용자 관리만 제공
- 이메일, 캘린더 등 G Suite 기능 없음
- 기본적인 사용자 관리 기능

| 기능 | Google Workspace | Cloud Identity |
|------|------------------|----------------|
| **사용자 관리** | ✅ 완전 지원 | ✅ 기본 지원 |
| **GCP 통합** | ✅ 완전 통합 | ✅ 완전 통합 |
| **이메일** | ✅ Gmail | ❌ 없음 |
| **비용** | 유료 | 무료 |

---

## 2️⃣ Google Workspace 설정

### 2.1 도메인 준비
1. **도메인 소유권** 확인 필요
2. **DNS 설정** 권한 필요
3. **도메인 등록** (예: `mycompany.com`)

### 2.2 Google Workspace 가입
1. [Google Workspace](https://workspace.google.com) 접속
2. **무료로 시작하기** 클릭
3. 도메인 입력: `mycompany.com`
4. 계정 정보 입력:
   - 이름: `홍길동`
   - 이메일: `admin@mycompany.com`
   - 비밀번호 설정
5. **다음** 클릭

### 2.3 도메인 소유권 확인
1. **DNS 설정** 방법 선택:
   - **TXT 레코드** 추가 (권장)
   - **HTML 파일** 업로드
2. DNS 관리자에서 설정 적용
3. **확인** 클릭

### 2.4 사용자 계정 생성
1. **사용자** → **사용자 추가**
2. 사용자 정보 입력:
   - 이름: `김개발`
   - 이메일: `kim.dev@mycompany.com`
   - 비밀번호: 임시 비밀번호 설정
3. **사용자 추가** 클릭

---

## 3️⃣ Cloud Identity 설정 (무료 옵션)

### 3.1 Cloud Identity 가입
1. [Cloud Identity](https://identity.google.com) 접속
2. **무료로 시작하기** 클릭
3. 도메인 입력: `mycompany.com`
4. 관리자 계정 생성:
   - 이메일: `admin@mycompany.com`
   - 비밀번호 설정
5. **다음** 클릭

### 3.2 도메인 소유권 확인
1. **TXT 레코드** 방법 선택
2. DNS에 TXT 레코드 추가
3. **확인** 클릭

### 3.3 사용자 초대
1. **사용자** → **사용자 초대**
2. 초대할 이메일 입력:
   - `user1@mycompany.com`
   - `user2@mycompany.com`
3. **초대 보내기** 클릭

---

## 4️⃣ GCP 조직 생성

### 4.1 조직 생성
1. [Google Cloud Console](https://console.cloud.google.com) 접속
2. **조직** → **조직 만들기**
3. 조직 정보 입력:
   - 조직 이름: `My Company`
   - 국가/지역: `대한민국`
4. **만들기** 클릭

### 4.2 폴더 구조 생성
1. **조직** → **폴더**
2. **폴더 만들기** 클릭
3. 폴더 구조 생성:
   ```
   My Company (조직)
   ├── Production (폴더)
   │   ├── Web Services (프로젝트)
   │   └── Database (프로젝트)
   ├── Staging (폴더)
   │   └── Test Environment (프로젝트)
   └── Development (폴더)
       └── Dev Environment (프로젝트)
   ```

---

## 5️⃣ 사용자 및 그룹 관리

### 5.1 사용자 추가
1. **IAM 및 관리자** → **사용자**
2. **사용자 추가** 클릭
3. 사용자 정보 입력:
   - 이메일: `developer@mycompany.com`
   - 이름: `개발자`
   - 부서: `개발팀`
4. **사용자 추가** 클릭

### 5.2 그룹 생성 및 관리
1. **IAM 및 관리자** → **그룹**
2. **그룹 만들기** 클릭
3. 그룹 정보 입력:
   - 그룹 이름: `developers@mycompany.com`
   - 설명: `개발팀 그룹`
4. **만들기** 클릭

### 5.3 그룹에 사용자 추가
1. 생성된 그룹 클릭
2. **멤버** 탭 선택
3. **멤버 추가** 클릭
4. 사용자 이메일 입력:
   - `developer1@mycompany.com`
   - `developer2@mycompany.com`
5. **추가** 클릭

---

## 6️⃣ IAM 정책 설정

### 6.1 조직 레벨 IAM 설정
1. **IAM 및 관리자** → **조직**
2. **IAM** 탭 선택
3. **+ 추가** 클릭
4. 멤버 및 역할 설정:

| 멤버 | 역할 | 설명 |
|------|------|------|
| `admin@mycompany.com` | **조직 관리자** | 조직 전체 관리 |
| `developers@mycompany.com` | **프로젝트 생성자** | 프로젝트 생성 권한 |
| `billing@mycompany.com` | **결제 계정 관리자** | 비용 관리 |

### 6.2 프로젝트 레벨 IAM 설정
1. **프로젝트 선택** → **IAM 및 관리자** → **IAM**
2. **+ 추가** 클릭
3. 멤버 및 역할 설정:

| 멤버 | 역할 | 설명 |
|------|------|------|
| `developers@mycompany.com` | **Editor** | 리소스 생성/수정 |
| `viewers@mycompany.com` | **Viewer** | 리소스 조회만 |
| `service-account@project.iam.gserviceaccount.com` | **Owner** | 서비스 계정 |

---

## 7️⃣ 조직 정책 설정

### 7.1 조직 정책 생성
1. **IAM 및 관리자** → **조직 정책**
2. **정책 만들기** 클릭
3. 정책 유형 선택:
   - **리소스 위치 제한**: 특정 리전만 사용
   - **서비스 사용 제한**: 특정 서비스만 사용
   - **비용 제한**: 프로젝트별 비용 한도

### 7.2 예시 정책 설정
```yaml
# 리소스 위치 제한 정책
constraint: constraints/gcp.resourceLocations
listPolicy:
  allowedValues:
    - in:asia-northeast3
    - in:asia-northeast1
  deniedValues:
    - in:us-central1
```

---

## 8️⃣ 비용 관리 설정

### 8.1 결제 계정 설정
1. **결제** → **결제 계정**
2. **결제 계정 만들기** 클릭
3. 결제 정보 입력:
   - 계정 이름: `My Company Billing`
   - 결제 방법: 신용카드 또는 계좌이체
   - 청구 주소: 회사 주소

### 8.2 예산 및 알림 설정
1. **결제** → **예산 및 알림**
2. **예산 만들기** 클릭
3. 예산 설정:
   - 예산 이름: `월간 예산`
   - 예산 금액: `$1,000`
   - 범위: 전체 조직 또는 특정 폴더
   - 알림: 50%, 90%, 100%

### 8.3 비용 할당 및 태깅
1. **결제** → **비용 할당**
2. **라벨** 기반 비용 할당 설정
3. **프로젝트** 기반 비용 할당 설정

---

## 9️⃣ 보안 설정

### 9.1 보안 정책 설정
1. **보안** → **보안 정책**
2. **정책 만들기** 클릭
3. 보안 정책 설정:
   - **암호 정책**: 복잡성 요구사항
   - **2단계 인증**: 필수 설정
   - **세션 관리**: 자동 로그아웃

### 9.2 감사 로그 설정
1. **IAM 및 관리자** → **감사 로그**
2. **감사 로그** 활성화
3. 로그 유형 선택:
   - **관리 활동**: 사용자 관리, 권한 변경
   - **데이터 액세스**: 리소스 접근 로그
   - **시스템 이벤트**: 시스템 변경 로그

### 9.3 VPC 서비스 제어
1. **보안** → **VPC 서비스 제어**
2. **서비스 경계** 생성
3. **액세스 정책** 설정

---

## 🔟 자동화 스크립트

### 10.1 조직 설정 자동화
```bash
# 1. 조직 ID 확인
gcloud organizations list

# 2. 폴더 생성
gcloud resource-manager folders create \
  --display-name="Production" \
  --parent="organizations/ORGANIZATION_ID"

# 3. 프로젝트 생성
gcloud projects create my-production-project \
  --folder="folders/FOLDER_ID"

# 4. 결제 계정 연결
gcloud billing projects link my-production-project \
  --billing-account=BILLING_ACCOUNT_ID
```

### 10.2 IAM 정책 자동화
```bash
# 1. 조직 레벨 IAM 설정
gcloud organizations add-iam-policy-binding ORGANIZATION_ID \
  --member="group:developers@mycompany.com" \
  --role="roles/resourcemanager.projectCreator"

# 2. 프로젝트 레벨 IAM 설정
gcloud projects add-iam-policy-binding PROJECT_ID \
  --member="group:developers@mycompany.com" \
  --role="roles/editor"

# 3. 서비스 계정 생성
gcloud iam service-accounts create my-service-account \
  --display-name="My Service Account" \
  --description="Service account for automation"
```

### 10.3 Terraform을 이용한 조직 관리
```hcl
# organization.tf
resource "google_organization" "org" {
  domain = "mycompany.com"
}

resource "google_folder" "production" {
  display_name = "Production"
  parent       = google_organization.org.name
}

resource "google_project" "production_project" {
  name       = "Production Project"
  project_id = "my-production-project"
  folder_id  = google_folder.production.name
}

resource "google_project_iam_member" "developers" {
  project = google_project.production_project.project_id
  role    = "roles/editor"
  member  = "group:developers@mycompany.com"
}
```

---

## 📚 FAQ - 자주 묻는 질문

### Q1: Google Workspace와 Cloud Identity 중 어떤 것을 선택해야 하나요?
**A**: 
- **Google Workspace**: 이메일, 캘린더 등 G Suite 기능이 필요한 경우
- **Cloud Identity**: GCP 관리만 필요한 경우 (무료)

### Q2: 조직 정책은 언제 적용되나요?
**A**: 조직 정책은 **상속**됩니다. 조직 레벨에서 설정하면 모든 하위 폴더와 프로젝트에 적용됩니다.

### Q3: 사용자 그룹을 어떻게 효율적으로 관리하나요?
**A**: 
- **부서별 그룹** 생성 (개발팀, 운영팀, 관리팀)
- **역할별 그룹** 생성 (개발자, 관리자, 뷰어)
- **프로젝트별 그룹** 생성 (프로덕션, 스테이징, 개발)

### Q4: 비용을 어떻게 효과적으로 관리하나요?
**A**: 
- **예산 알림** 설정으로 사전 경고
- **프로젝트별 예산** 설정
- **라벨**을 이용한 비용 할당
- **정기적인 비용 리뷰**

---

## 🔐 보안 권장사항

### 조직 보안
- **조직 관리자** 권한 최소화
- **정기적인 권한 리뷰**
- **감사 로그** 모니터링

### 사용자 보안
- **2단계 인증** 필수
- **강력한 비밀번호** 정책
- **정기적인 보안 교육**

### 리소스 보안
- **최소 권한** 원칙
- **네트워크 보안** 설정
- **데이터 암호화** 적용

---

## 🚀 다음 단계

### 고급 기능
- **Cloud Identity-Aware Proxy** 설정
- **Workload Identity** 구성
- **Binary Authorization** 설정

### 자동화 확장
- **Terraform**을 이용한 인프라 자동화
- **Cloud Build**를 이용한 CI/CD
- **Cloud Functions**를 이용한 이벤트 기반 자동화

### 모니터링 및 로깅
- **Cloud Monitoring** 설정
- **Cloud Logging** 구성
- **Security Command Center** 활용

---

## 📞 문제 해결

### 일반적인 오류
1. **권한 부족**: 조직 관리자 권한 확인
2. **도메인 확인 실패**: DNS 설정 확인
3. **정책 충돌**: 조직 정책 우선순위 확인

### 지원 채널
- [GCP 지원 센터](https://cloud.google.com/support/)
- [Google Workspace 지원](https://support.google.com/a/)
- [Cloud Identity 지원](https://support.google.com/cloudidentity/)
