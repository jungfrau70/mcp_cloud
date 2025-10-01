# GCP 개인 계정 가입 및 관리 가이드


## 📋 개요

이 문서는 개인 Google 계정을 사용하여 GCP[Google Cloud Platform]에 가입하고 기본적인 프로젝트 관리를 하는 과정을 단계별로 안내합니다.

### 🎯 목표
- **개인 Google 계정**으로 GCP 가입
- **프로젝트 생성** 및 기본 설정
- **결제 계정** 설정 및 관리
- **기본 IAM 권한** 설정

---

## 1️⃣ GCP 개인 계정 가입

### 1.1 Google 계정 준비
- 개인 Gmail 계정 또는 Google 계정 필요
- 2단계 인증 설정 권장
- 신용카드 또는 결제 수단 준비

### 1.2 GCP 가입 과정
1. [Google Cloud Console][https:///console.cloud.google.com] 접속
2. **무료로 시작하기** 클릭
3. Google 계정으로 로그인
4. 약관 동의 및 개인정보 처리방침 확인
5. **계속하기** 클릭

---

## 2️⃣ 결제 계정 설정

### 2.1 결제 정보 입력
1. **결제 계정** 생성
2. 계정 유형 선택:
   - **개인**: 개인 사용자
   - **비즈니스**: 소규모 사업자
3. 결제 정보 입력:
   - 신용카드 정보
   - 청구 주소
   - 연락처 정보

### 2.2 무료 크레딧 확인
- **$300 무료 크레딧** 제공 ["12개월간"]
- **Always Free** 서비스 확인
- 크레딧 사용량 모니터링 설정

---

## 3️⃣ 첫 번째 프로젝트 생성

### 3.1 프로젝트 생성
1. **프로젝트 선택** 드롭다운 클릭
2. **새 프로젝트** 클릭
3. 프로젝트 정보 입력:
   - 프로젝트 이름: `my-first-project`
   - 프로젝트 ID: 자동 생성 또는 사용자 지정
   - 조직: 없음 ["개인 계정"]
4. **만들기** 클릭

### 3.2 프로젝트 설정
1. **프로젝트 선택** 확인
2. **API 및 서비스** → **라이브러리**에서 필요한 API 활성화
3. **결제** → **결제 계정 연결** 확인

---

## 4️⃣ 기본 IAM 권한 설정

### 4.1 개인 계정의 기본 권한
개인 Google 계정으로 생성한 프로젝트는 자동으로 **Owner** 권한을 가집니다.

| 권한 | 설명 |
|------|------|
| **Owner** | 프로젝트 내 모든 리소스 관리 |
| **Billing Account User** | 결제 계정 사용 권한 |
| **Project Creator** | 새 프로젝트 생성 권한 |

### 4.2 추가 사용자 초대 ["선택사항"]
1. **IAM 및 관리자** → **IAM**
2. **+ 추가** 클릭
3. 새 멤버 추가:
   - 이메일: `friend@gmail.com`
   - 역할: **Editor** 또는 **Viewer** 선택
4. **저장** 클릭

---

## 5️⃣ 서비스 계정 생성

### 5.1 서비스 계정 생성
API 호출이나 자동화를 위한 서비스 계정을 생성합니다.

1. **IAM 및 관리자** → **서비스 계정**
2. **서비스 계정 만들기** 클릭
3. 서비스 계정 정보 입력:
   - 서비스 계정 이름: `my-service-account`
   - 서비스 계정 ID: `my-service-account`
   - 설명: `Personal service account for automation`
4. **만들기** 클릭

### 5.2 서비스 계정 권한 부여
1. **역할 선택** 단계에서:
   - **기본 역할** → **Editor** 선택
   - 또는 필요한 최소 권한만 선택
2. **완료** 클릭

### 5.3 서비스 계정 키 생성
1. 생성된 서비스 계정 클릭
2. **키** 탭 선택
3. **키 추가** → **새 키 만들기**
4. **JSON** 형식 선택 → **만들기**
5. 키 파일 다운로드 및 안전하게 보관

---

## 6️⃣ 비용 관리 설정

### 6.1 예산 및 알림 설정
1. **결제** → **예산 및 알림**
2. **예산 만들기** 클릭
3. 예산 정보 입력:
   - 예산 이름: `Monthly Budget`
   - 예산 금액: `$50` ["예시"]
   - 알림 임계값: `50%`, `90%`, `100%`
4. **예산 만들기** 클릭

### 6.2 비용 모니터링
1. **결제** → **비용 분석**
2. 일별/월별 비용 추이 확인
3. 서비스별 비용 분석
4. 리전별 비용 분석

---

## 7️⃣ 보안 설정

### 7.1 2단계 인증 설정
1. Google 계정 설정으로 이동
2. **보안** → **2단계 인증**
3. **시작하기** 클릭
4. 전화번호 또는 인증 앱 설정

### 7.2 API 키 보안
1. **API 및 서비스** → **사용자 인증 정보**
2. **API 키** 생성 시 제한사항 설정:
   - **애플리케이션 제한사항**: HTTP 리퍼러
   - **API 제한사항**: 필요한 API만 선택
3. **사용자 인증 정보** → **서비스 계정**에서 키 관리

---

## 8️⃣ 자동화 스크립트

### 8.1 gcloud CLI 설정
```bash
# 1. gcloud CLI 설치 [Windows]
# https:///cloud.google.com/sdk/docs/install

# 2. 인증 설정
gcloud auth login

# 3. 프로젝트 설정
gcloud config set project YOUR_PROJECT_ID

# 4. 기본 리전 설정
gcloud config set compute/region asia-northeast3
```

### 8.2 기본 리소스 생성 스크립트
```bash
# 1. Compute Engine 인스턴스 생성
gcloud compute instances create my-instance /
  --zone=asia-northeast3-a /
  --machine-type=e2-micro /
  --image-family=ubuntu-2004-lts /
  --image-project=ubuntu-os-cloud

# 2. Cloud Storage 버킷 생성
gsutil mb gs://my-bucket-$[date +%s]

# 3. 서비스 계정 생성
gcloud iam service-accounts create my-service-account /
  --display-name="My Service Account" /
  --description="Personal service account"
```

---

## 9️⃣ FAQ - 자주 묻는 질문

### Q1: 무료 크레딧이 언제 소진되나요?
**A**: 12개월 후 또는 $300 크레딧을 모두 사용하면 소진됩니다. Always Free 서비스는 계속 무료로 사용 가능합니다.

### Q2: 개인 계정으로도 조직 기능을 사용할 수 있나요?
**A**: 아니요. 조직 기능은 Google Workspace 또는 Cloud Identity가 필요합니다. 개인 계정은 프로젝트 레벨에서만 관리 가능합니다.

### Q3: 서비스 계정 키를 어떻게 안전하게 보관하나요?
**A**: 
- 환경 변수로 설정
- 비밀 관리 도구 사용 ["AWS Secrets Manager, Azure Key Vault 등"]
- 정기적인 키 로테이션 ["90일마다"]

### Q4: 비용이 예상보다 많이 나왔어요
**A**: 
1. **비용 분석**에서 상세 내역 확인
2. **예산 알림** 설정으로 사전 경고
3. **Always Free** 서비스 우선 사용
4. 불필요한 리소스 정리

---

## 🔐 보안 권장사항

### 계정 보안
- **2단계 인증** 필수 설정
- **강력한 비밀번호** 사용
- **정기적인 로그인 확인**

### 리소스 보안
- **방화벽 규칙** 설정
- **IAM 최소 권한** 원칙
- **서비스 계정 키** 안전한 보관

### 모니터링
- **Cloud Audit Logs** 활성화
- **Security Command Center** 사용
- **비용 알림** 설정

---

## 🚀 다음 단계

### 추가 학습
- ["GCP 개인 사용자 가이드"][https:///cloud.google.com/docs/overview]
- ["gcloud CLI 참조"][https:///cloud.google.com/sdk/docs]
- ["GCP 무료 서비스"][https:///cloud.google.com/free]

### 고급 기능
- **Terraform**을 이용한 인프라 자동화
- **Cloud Functions**를 이용한 서버리스 개발
- **Cloud Run**을 이용한 컨테이너 배포

---

## 📞 문제 해결

### 일반적인 오류
1. **권한 부족**: IAM 역할 확인
2. **API 비활성화**: 필요한 API 활성화
3. **할당량 초과**: 할당량 증가 요청

### 지원 채널
- ["GCP 지원 센터"][https:///cloud.google.com/support/]
- ["GCP 커뮤니티"][https:///cloud.google.com/community/]
- [Stack Overflow][https:///stackoverflow.com/questions/tagged/google-cloud-platform]


---


---



<div align="center">

["← 이전: Cloud Intermediate 메인"](cloud_intermediate/README.md) | ["📚 전체 커리큘럼"](cloud_intermediate/curriculum.md) | ["🏠 학습 경로로 돌아가기"](cloud_intermediate/index.md) | ["📋 학습 경로"](cloud_intermediate/learning-path.md)

</div>