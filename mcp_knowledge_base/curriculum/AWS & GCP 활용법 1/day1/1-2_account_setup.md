# 1-2. AWS/GCP 계정 생성 및 초기 설정

## 학습 목표
- AWS 계정 생성 및 보안 설정
- GCP 계정 생성 및 프로젝트 설정
- IAM 사용자 생성 및 권한 관리
- 비용 알림 및 예산 설정
- 무료 티어 제한사항 이해

---

## AWS 계정 생성 및 설정

### 1단계: AWS 계정 생성
1. **AWS 홈페이지 방문**: https://aws.amazon.com/ko/
2. **계정 생성** 버튼 클릭
3. **필수 정보 입력**:
   - 이메일 주소
   - 비밀번호
   - AWS 계정 이름

### 2단계: 연락처 정보 입력
- **개인 정보**: 이름, 전화번호, 주소
- **결제 정보**: 신용카드 또는 체크카드
- **신원 확인**: 전화 또는 SMS 인증

### 3단계: 계정 확인
- **AWS 계정 활성화** 확인
- **콘솔 로그인** 테스트
- **무료 티어 상태** 확인

---

## AWS 보안 설정

### Root 계정 보호
⚠️ **중요**: Root 계정은 절대 일상 업무에 사용하지 마세요!

1. **MFA 활성화**:
   - Google Authenticator 또는 Authy 앱 사용
   - 하드웨어 보안 키 (YubiKey) 권장

2. **액세스 키 비활성화**:
   - Root 계정의 액세스 키 삭제
   - IAM 사용자로 대체

3. **비밀번호 정책 설정**:
   - 최소 8자, 대문자, 소문자, 숫자, 특수문자 포함
   - 90일마다 변경

---

## AWS IAM 사용자 생성

### IAM 사용자 생성
1. **IAM 서비스** 접속
2. **사용자** → **사용자 추가**
3. **사용자 이름**: `admin-user` (예시)
4. **액세스 유형**: 프로그래밍 방식 액세스

### 권한 할당
**권장 정책**:
- `AdministratorAccess` (개발/학습용)
- `PowerUserAccess` (프로덕션 권장)
- `ReadOnlyAccess` (읽기 전용)

### 액세스 키 생성
- **액세스 키 ID** 저장
- **비밀 액세스 키** 안전하게 보관
- **CSV 다운로드** 권장

---

## GCP 계정 생성 및 설정

### 1단계: Google 계정으로 로그인
1. **GCP 홈페이지**: https://cloud.google.com/
2. **Google 계정**으로 로그인
3. **무료 평가판 시작** 클릭

### 2단계: 프로젝트 생성
1. **프로젝트 선택** → **새 프로젝트**
2. **프로젝트 이름**: `cloud-bootcamp` (예시)
3. **프로젝트 ID**: 자동 생성 또는 수동 입력
4. **조직**: 선택사항

### 3단계: 결제 계정 연결
- **신용카드 정보** 입력
- **무료 크레딧** 확인 ($300, 90일)
- **결제 계정** 활성화

---

## GCP IAM 및 서비스 계정

### IAM 사용자 관리
1. **IAM 및 관리** → **IAM**
2. **사용자 추가**:
   - 이메일 주소 입력
   - 역할 할당

### 기본 역할
- **소유자**: 모든 권한
- **편집자**: 리소스 생성/수정
- **뷰어**: 읽기 전용

### 서비스 계정 생성
1. **서비스 계정** → **서비스 계정 만들기**
2. **계정 이름**: `terraform-sa` (예시)
3. **역할**: `편집자` 또는 `소유자`
4. **키 생성**: JSON 형식 다운로드

---

## 비용 관리 및 알림 설정

### AWS 비용 관리
1. **비용 관리** → **예산**
2. **예산 생성**:
   - 월 예산: $50 (예시)
   - 알림 임계값: 80%, 100%
3. **비용 알림** 설정

### GCP 비용 관리
1. **결제** → **예산 및 알림**
2. **예산 만들기**:
   - 예산 금액: $50 (예시)
   - 알림 규칙: 50%, 90%, 100%

### 비용 모니터링 도구
- **AWS Cost Explorer**
- **GCP Cost Management**
- **CloudWatch** (AWS)
- **Cloud Monitoring** (GCP)

---

## 무료 티어 제한사항

### AWS 무료 티어 (12개월)
- **EC2**: t2.micro 750시간/월
- **S3**: 5GB 스토리지
- **RDS**: 750시간/월 (db.t2.micro)
- **Lambda**: 100만 요청/월
- **CloudFront**: 50GB 데이터 전송

### GCP 무료 티어 (영구)
- **Compute Engine**: f1-micro 1개/월
- **Cloud Storage**: 5GB
- **Cloud Functions**: 200만 요청/월
- **BigQuery**: 1TB 쿼리/월
- **Cloud Run**: 200만 요청/월

---

## 지역 및 가용영역 설정

### AWS 리전 선택
**권장 리전**:
- **아시아 태평양 (서울)**: `ap-northeast-2`
- **아시아 태평양 (도쿄)**: `ap-northeast-1`
- **미국 동부 (버지니아)**: `us-east-1`

### GCP 리전 선택
**권장 리전**:
- **asia-northeast3 (서울)**: `asia-northeast3`
- **asia-northeast1 (도쿄)**: `asia-northeast1`
- **us-central1 (아이오와)**: `us-central1`

---

## 실습 환경 구성

### 로컬 개발 환경
1. **AWS CLI** 설치
2. **gcloud CLI** 설치
3. **Terraform** 설치
4. **Docker** 설치

### IDE 설정
- **VS Code** 확장 프로그램
- **AWS Toolkit**
- **Cloud Code**
- **Terraform**

### 브라우저 확장 프로그램
- **AWS CloudFormation Designer**
- **GCP Cloud Console**

---

## 보안 체크리스트

### 계정 보안
- [ ] Root 계정 MFA 활성화
- [ ] IAM 사용자 생성 및 사용
- [ ] 액세스 키 안전 보관
- [ ] 정기적인 액세스 키 순환

### 비용 관리
- [ ] 예산 설정 및 알림
- [ ] 무료 티어 모니터링
- [ ] 사용하지 않는 리소스 정리
- [ ] 비용 할당 태그 사용

### 모니터링
- [ ] CloudWatch 알림 설정
- [ ] 로그 모니터링 활성화
- [ ] 보안 이벤트 추적
- [ ] 성능 메트릭 수집

---

## 다음 단계
- CLI 도구 설치 및 인증 설정
- 기본 서비스 탐색 및 사용법 학습
- 첫 번째 리소스 생성 실습

---

## 문제 해결

### 일반적인 문제
1. **계정 생성 실패**: 신용카드 정보 확인
2. **로그인 문제**: MFA 설정 확인
3. **권한 오류**: IAM 정책 확인
4. **비용 초과**: 예산 알림 설정 확인

### 지원 채널
- **AWS Support**: 기술 지원 요청
- **GCP Support**: 지원 케이스 생성
- **커뮤니티**: Stack Overflow, Reddit
- **공식 문서**: 각 플랫폼별 가이드

---

## 참고 자료
- [AWS 계정 생성 가이드](https://aws.amazon.com/ko/premiumsupport/knowledge-center/create-and-activate-aws-account/)
- [GCP 시작하기](https://cloud.google.com/docs/get-started)
- [AWS 보안 모범 사례](https://aws.amazon.com/ko/security/security-learning/)
- [GCP 보안 모범 사례](https://cloud.google.com/security/best-practices)
