<div align="center">

## 🏠 최상위 네비게이션
[🏠 홈](/mcp_knowledge_base/index.md) | [📚 전체 커리큘럼](/mcp_knowledge_base/curriculum.md) | [🔗 학습 경로](/mcp_knowledge_base/cloud_basic/learning-path.md)

## 📖 현재 위치
**Cloud Basic** > **1일차** > **1교시: AWS & GCP 계정 생성 및 설정**

## ⬅️ 이전/다음 네비게이션
[← 이전: Cloud Basic 메인](/mcp_knowledge_base/cloud_basic/README.md) | [다음: Cloud Basic 1일차 →](/mcp_knowledge_base/cloud_basic/textbook/Day1/README.md)

</div>

# 1교시: AWS & GCP 계정 생성 및 설정

<div align="center">

[← 이전: Cloud Basic 1일차 메인](/mcp_knowledge_base/cloud_master/README.md) | [📚 전체 커리큘럼](/mcp_knowledge_base/curriculum.md) | [🏠 학습 경로로 돌아가기](/mcp_knowledge_base/index.md) | [📋 학습 경로](/mcp_knowledge_base/cloud_master/learning-path.md)

</div>

<details>
<summary>📋 목차</summary>

1. [🎯 학습 목표](#학습-목표)
2. [🚀 AWS 계정 생성 및 설정](#aws-계정-생성-및-설정)
3. [🚀 GCP 계정 생성 및 설정](#gcp-계정-생성-및-설정)
4. [✅ 계정 설정 검증](#계정-설정-검증)
5. [💰 비용 관리 설정](#비용-관리-설정)
6. [🧪 실습 과제](#실습-과제)
7. [📚 문제 해결 및 참고 자료](#문제-해결-및-참고-자료)

</details>

---

## 🎯 학습 목표

### 핵심 학습 목표
- **AWS Free Tier 계정** 생성 및 기본 설정
- **GCP 계정** 생성 및 $300 크레딧 활성화
- **AWS CLI 및 gcloud CLI** 설치 및 설정
- **계정 보안** 설정 및 모범 사례 적용
- **비용 모니터링** 설정 및 예산 관리

### 실습 후 달성할 수 있는 능력
- ✅ AWS Free Tier 계정 생성 및 기본 설정
- ✅ GCP $300 크레딧 계정 생성 및 활성화
- ✅ AWS CLI와 gcloud CLI 설치 및 인증 설정
- ✅ IAM 사용자/서비스 계정 생성 및 권한 관리
- ✅ 비용 관리 및 예산 설정

### 예상 소요 시간
- **AWS 계정 생성**: 30-45분
- **GCP 계정 생성**: 30-45분
- **CLI 설정**: 30-45분
- **비용 관리**: 15-30분
- **전체 과정**: 2-3시간

---

## 🚀 AWS 계정 생성 및 설정

<details>
<summary>📖 AWS 계정 생성 개요</summary>

### AWS 계정 생성 방법
- **웹콘솔 방식**: AWS 홈페이지에서 직접 생성
- **CLI 방식**: AWS CLI를 통한 자동화
- **Free Tier**: 12개월간 무료 사용 가능

### 중요 사항
- **신용카드 정보 필수**: Free Tier 사용을 위해 필요
- **실제 비용 발생 가능**: Free Tier 한도 초과 시
- **계정 보안**: MFA(다단계 인증) 설정 권장

</details>

### 1.1 AWS 계정 생성

<details>
<summary>🌐 웹콘솔 방식</summary>
```markdown
1. [AWS 홈페이지](https://aws.amazon.com) 접속
2. "AWS 계정 생성" 클릭
3. 계정 정보 입력:
   - 이메일 주소
   - 비밀번호 (강력한 비밀번호 사용)
   - 계정 이름
4. 계정 유형: "개인" 선택
5. 연락처 정보 입력
6. 결제 정보 등록 (Free Tier 사용)
7. 전화번호 인증 완료
8. 지원 플랜: "기본 지원 - 무료" 선택
9. 계정 생성 완료
```

</details>

<details>
<summary>💻 CLI 방식</summary>

```bash
# AWS CLI를 통한 계정 설정 (기존 계정이 있는 경우)
aws configure

# 입력할 정보:
# AWS Access Key ID: [IAM에서 생성한 액세스 키]
# AWS Secret Access Key: [IAM에서 생성한 시크릿 키]
# Default region name: ap-northeast-2
# Default output format: json
```

</details>

### 1.2 AWS CLI 설치 및 설정

<details>
<summary>💻 CLI 설치</summary>
```bash
# Windows
winget install Amazon.AWSCLI

# macOS
brew install awscli

# Ubuntu/Debian
sudo apt update
sudo apt install awscli

# 설치 확인
aws --version
```

</details>

<details>
<summary>🔑 AWS 자격증명 설정</summary>
```bash
# AWS 자격증명 설정
aws configure

# 입력할 정보:
# AWS Access Key ID: [IAM에서 생성한 액세스 키]
# AWS Secret Access Key: [IAM에서 생성한 시크릿 키]
# Default region name: ap-northeast-2
# Default output format: json

# 설정 확인
aws sts get-caller-identity
```

</details>

### 1.3 IAM 사용자 생성

<details>
<summary>🌐 웹콘솔 방식</summary>
```markdown
1. AWS Console → "IAM" 검색
2. "사용자" → "사용자 추가" 클릭
3. 사용자 이름: "cloud-student"
4. 액세스 유형: "프로그래밍 방식 액세스" 선택
5. "다음: 권한" 클릭
6. "기존 정책 직접 연결" 선택
7. 권한 정책 선택:
   - AmazonEC2FullAccess
   - AmazonS3FullAccess
   - AmazonRDSFullAccess
   - IAMReadOnlyAccess
8. "다음: 태그" → "다음: 검토" → "사용자 만들기"
9. 액세스 키 ID와 비밀 액세스 키 저장
```

</details>

<details>
<summary>💻 CLI 방식</summary>
```bash
# IAM 사용자 생성
aws iam create-user --user-name cloud-student

# 사용자에게 정책 연결
aws iam attach-user-policy \
  --user-name cloud-student \
  --policy-arn arn:aws:iam::aws:policy/AmazonEC2FullAccess

aws iam attach-user-policy \
  --user-name cloud-student \
  --policy-arn arn:aws:iam::aws:policy/AmazonS3FullAccess

# 액세스 키 생성
aws iam create-access-key --user-name cloud-student

# 사용자 확인
aws iam list-users --output table
```

</details>

---

## 🚀 GCP 계정 생성 및 설정

<details>
<summary>📖 GCP 계정 생성 개요</summary>

### GCP 계정 생성 방법
- **웹콘솔 방식**: Google Cloud Platform에서 직접 생성
- **CLI 방식**: gcloud CLI를 통한 자동화
- **$300 크레딧**: 12개월간 사용 가능

### 중요 사항
- **$300 크레딧**: 12개월간 사용 가능
- **신용카드 정보 필수**: 크레딧 활성화를 위해 필요
- **프로젝트 기반**: 모든 리소스는 프로젝트 내에서 관리

</details>

### 2.1 GCP 계정 생성

<details>
<summary>🌐 웹콘솔 방식</summary>
```markdown
1. [Google Cloud Platform](https://cloud.google.com) 접속
2. "무료로 시작하기" 클릭
3. Google 계정으로 로그인
4. 계정 정보 입력:
   - 국가/지역: "대한민국" 선택
   - 계정 유형: "개인" 선택
5. 약관 동의 및 계정 생성
6. 결제 정보 등록 ($300 크레딧 활성화)
7. 프로젝트 생성: "cloud-student-project"
8. 계정 생성 완료
```

</details>

<details>
<summary>💻 CLI 방식</summary>

```bash
# gcloud CLI를 통한 계정 설정 (기존 계정이 있는 경우)
gcloud init

# 프로젝트 설정
gcloud config set project PROJECT_ID
```

</details>

### 2.2 Google Cloud SDK 설치 및 설정

<details>
<summary>💻 SDK 설치</summary>
```bash
# Windows
winget install Google.CloudSDK

# macOS
brew install google-cloud-sdk

# Ubuntu/Debian
curl https://sdk.cloud.google.com | bash
exec -l $SHELL

# 설치 확인
gcloud --version
```

</details>

<details>
<summary>🔑 GCP 인증 설정</summary>
```bash
# gcloud 초기화
gcloud init

# 프로젝트 설정
gcloud config set project cloud-student-project

# 인증 확인
gcloud auth list
gcloud config list
```

</details>

### 2.3 서비스 계정 생성

<details>
<summary>🌐 웹콘솔 방식</summary>
```markdown
1. GCP Console → "IAM 및 관리자" → "서비스 계정" 클릭
2. "서비스 계정 만들기" 클릭
3. 서비스 계정 정보:
   - 이름: "cloud-student-sa"
   - ID: "cloud-student-sa"
   - 설명: "Cloud Student Service Account"
4. "만들기 및 계속" 클릭
5. 역할 선택:
   - Compute Instance Admin
   - Storage Admin
   - Cloud SQL Admin
   - IAM Service Account User
6. "완료" 클릭
```

</details>

<details>
<summary>💻 CLI 방식</summary>
```bash
# 서비스 계정 생성
gcloud iam service-accounts create cloud-student-sa \
  --display-name="Cloud Student Service Account" \
  --description="Service account for cloud student practice"

# 서비스 계정에 역할 부여
gcloud projects add-iam-policy-binding cloud-student-project \
  --member="serviceAccount:cloud-student-sa@cloud-student-project.iam.gserviceaccount.com" \
  --role="roles/compute.instanceAdmin"

gcloud projects add-iam-policy-binding cloud-student-project \
  --member="serviceAccount:cloud-student-sa@cloud-student-project.iam.gserviceaccount.com" \
  --role="roles/storage.admin"

# 서비스 계정 키 생성
gcloud iam service-accounts keys create cloud-student-key.json \
  --iam-account=cloud-student-sa@cloud-student-project.iam.gserviceaccount.com

# 서비스 계정 인증
gcloud auth activate-service-account \
  --key-file=cloud-student-key.json
```

</details>

---

## ✅ 계정 설정 검증

<details>
<summary>📖 계정 설정 검증 개요</summary>

### 검증 항목
- **AWS 계정**: 자격증명 및 리전 설정 확인
- **GCP 계정**: 프로젝트 및 인증 설정 확인
- **CLI 도구**: AWS CLI와 gcloud CLI 정상 작동 확인

### 검증 방법
- **명령어 실행**: 각 CLI 도구의 기본 명령어 실행
- **리소스 접근**: 간단한 리소스 조회 명령어 실행
- **설정 확인**: 현재 설정된 계정 및 리전 정보 확인

</details>

### 3.1 AWS 계정 검증

<details>
<summary>🔍 AWS 계정 검증 방법</summary>

```bash
# AWS 계정 정보 확인
aws sts get-caller-identity

# 리전 설정 확인
aws configure get region

# 사용 가능한 리전 목록
aws ec2 describe-regions --output table

# 서울 리전 설정
aws configure set region ap-northeast-2
```

</details>

### 3.2 GCP 계정 검증

<details>
<summary>🔍 GCP 계정 검증 방법</summary>

```bash
# GCP 프로젝트 정보 확인
gcloud config get-value project

# 인증된 계정 확인
gcloud auth list

# 사용 가능한 리전 목록
gcloud compute regions list --filter="name:asia-northeast3"

# 리전 설정
gcloud config set compute/region asia-northeast3
gcloud config set compute/zone asia-northeast3-a
```

</details>

---

## 💰 비용 관리 설정

<details>
<summary>📖 비용 관리 개요</summary>

### 비용 관리 목적
- **예산 초과 방지**: 설정한 예산을 초과하지 않도록 관리
- **비용 모니터링**: 실시간 비용 사용량 추적
- **알림 설정**: 예산 초과 시 즉시 알림

### 관리 방법
- **예산 설정**: 월별 또는 일별 예산 설정
- **알림 임계값**: 80%, 100% 등 단계별 알림
- **비용 분석**: 서비스별 비용 분석 및 최적화

</details>

### 4.1 AWS 비용 관리

<details>
<summary>🌐 웹콘솔 방식</summary>
```markdown
1. AWS Console → "Billing and Cost Management" 검색
2. "Billing Dashboard" 클릭
3. "Budgets" → "Create budget" 클릭
4. 예산 설정:
   - 예산 이름: "Cloud Student Budget"
   - 예산 금액: $10
   - 기간: "월별"
   - 알림 조건: 80%, 100%
5. "Create budget" 클릭
```

</details>

<details>
<summary>💻 CLI 방식</summary>
```bash
# 비용 및 사용량 보고서 확인
aws ce get-cost-and-usage \
  --time-period Start=2024-01-01,End=2024-01-31 \
  --granularity MONTHLY \
  --metrics BlendedCost
```

</details>

### 4.2 GCP 비용 관리

<details>
<summary>🌐 웹콘솔 방식</summary>
```markdown
1. GCP Console → "Billing" 검색
2. "Budgets & alerts" 클릭
3. "CREATE BUDGET" 클릭
4. 예산 설정:
   - 예산 이름: "Cloud Student Budget"
   - 예산 금액: $10
   - 기간: "월별"
   - 알림 임계값: 80%, 100%
5. "CREATE" 클릭
```

</details>

<details>
<summary>💻 CLI 방식</summary>
```bash
# GCP 비용 정보 확인
gcloud billing accounts list
gcloud billing budgets list --billing-account=BILLING_ACCOUNT_ID
```

</details>

---

## 🧪 실습 과제

<details>
<summary>📖 실습 과제 개요</summary>

### 실습 목적
- **계정 생성**: AWS와 GCP 계정 생성 및 설정
- **CLI 설정**: AWS CLI와 gcloud CLI 설치 및 인증
- **비용 관리**: 예산 설정 및 모니터링
- **보안 설정**: IAM 사용자/서비스 계정 생성

### 실습 결과물
- AWS Free Tier 계정 및 IAM 사용자
- GCP $300 크레딧 계정 및 서비스 계정
- CLI 도구 설치 및 인증 설정
- 비용 관리 및 예산 설정

</details>

### 기본 과제

<details>
<summary>📋 기본 과제 목록</summary>
1. **AWS 계정 생성**: Free Tier 계정 생성 및 IAM 사용자 설정
2. **GCP 계정 생성**: $300 크레딧 계정 생성 및 서비스 계정 설정
3. **CLI 설정**: AWS CLI와 gcloud CLI 설치 및 인증 설정
4. **비용 관리**: 두 플랫폼 모두 예산 설정

</details>

### 고급 과제

<details>
<summary>📋 고급 과제 목록</summary>
1. **보안 강화**: MFA 설정 및 액세스 키 로테이션
2. **태깅 전략**: 리소스 태깅 정책 수립
3. **비용 최적화**: Free Tier 한도 모니터링 설정
4. **자동화**: 계정 설정 자동화 스크립트 작성

</details>

---

## ✅ 체크리스트

<details>
<summary>📋 학습 완료 체크리스트</summary>

### AWS 계정 설정
- [ ] AWS Free Tier 계정 생성 완료
- [ ] AWS CLI 설치 및 설정 완료
- [ ] IAM 사용자 생성 완료
- [ ] 비용 관리 설정 완료

### GCP 계정 설정
- [ ] GCP $300 크레딧 계정 생성 완료
- [ ] gcloud CLI 설치 및 설정 완료
- [ ] 서비스 계정 생성 완료
- [ ] 비용 관리 설정 완료

### 검증 및 테스트
- [ ] 계정 설정 검증 완료
- [ ] CLI 도구 정상 작동 확인
- [ ] 리소스 접근 테스트 완료

</details>

---

## 📚 문제 해결 및 참고 자료

<details>
<summary>🐛 자주 발생하는 문제</summary>

### 계정 생성 관련 문제
<details>
<summary>❌ AWS 계정 생성 실패</summary>

**원인**: 
- 이메일 주소 중복
- 신용카드 정보 오류
- 전화번호 인증 실패

**해결방법**:
1. 다른 이메일 주소 사용
2. 신용카드 정보 재확인
3. 전화번호 형식 확인

</details>

<details>
<summary>❌ GCP 크레딧 활성화 실패</summary>

**원인**:
- 결제 정보 미등록
- 지역 제한
- 계정 상태 문제

**해결방법**:
1. 결제 정보 등록 확인
2. 지원되는 지역에서 접속
3. 계정 상태 확인

</details>

### CLI 관련 문제
<details>
<summary>❌ AWS CLI 인증 실패</summary>

**원인**:
- Access Key ID/Secret Key 오류
- 권한 부족
- 리전 설정 오류

**해결방법**:
```bash
# 1. 자격 증명 재설정
aws configure

# 2. 권한 확인
aws sts get-caller-identity

# 3. 리전 확인
aws configure get region
```

</details>

<details>
<summary>❌ gcloud 인증 실패</summary>

**원인**:
- 서비스 계정 키 오류
- 프로젝트 ID 오류
- 권한 부족

**해결방법**:
```bash
# 1. 인증 재설정
gcloud auth login

# 2. 프로젝트 설정
gcloud config set project YOUR_PROJECT_ID

# 3. 서비스 계정 키 설정
gcloud auth activate-service-account --key-file=key.json
```

</details>

</details>

<details>
<summary>📖 추가 학습 자료</summary>

### 공식 문서
- [AWS 공식 문서](https://docs.aws.amazon.com/)
- [GCP 공식 문서](https://cloud.google.com/docs)
- [AWS CLI 공식 문서](https://docs.aws.amazon.com/cli/)
- [gcloud CLI 공식 문서](https://cloud.google.com/sdk/docs)

### 유용한 리소스
- [AWS Free Tier](https://aws.amazon.com/free/)
- [GCP Free Tier](https://cloud.google.com/free)
- [AWS 서비스 카탈로그](https://aws.amazon.com/products/)
- [GCP 서비스 카탈로그](https://cloud.google.com/products)

### 관련 프로젝트
- [AWS 샘플 프로젝트](https://github.com/aws-samples)
- [GCP 샘플 프로젝트](https://github.com/GoogleCloudPlatform)

</details>

<details>
<summary>🚀 다음 단계</summary>

### 2교시 준비
1. **IAM 사용자 및 권한 관리**: 사용자, 그룹, 역할, 정책 관리
2. **보안 모범 사례**: 최소 권한 원칙, MFA 설정
3. **실무 환경**: 실제 프로젝트에 적용할 수 있는 IAM 구성

### 고급 기능
1. **조직 관리**: AWS Organizations, GCP Organization
2. **외부 연동**: SAML, OIDC 연동
3. **자동화**: IAM 설정 자동화 스크립트

</details>

---

## 🎉 완료!

축하합니다! AWS & GCP 계정 생성 및 설정을 완료했습니다.

### 📚 학습 요약

이번 교시를 통해 다음을 배웠습니다:

1. **🏗️ AWS 계정**: Free Tier 계정 생성 및 IAM 사용자 설정
2. **☁️ GCP 계정**: $300 크레딧 계정 생성 및 서비스 계정 설정
3. **🔧 CLI 설정**: AWS CLI와 gcloud CLI 설치 및 인증
4. **💰 비용 관리**: 예산 설정 및 모니터링

### 🚀 다음 단계

- **2교시 실습**: [IAM 사용자 및 권한 관리](/mcp_knowledge_base/cloud_basic/textbook/Day1/iam-basics-guide.md)
- **실제 프로젝트 적용**: 자신의 프로젝트에 클라우드 서비스 적용
- **고급 기능 학습**: 조직 관리, 외부 연동, 자동화

### 💡 추가 학습 자료

- [AWS 공식 문서](https://docs.aws.amazon.com/)
- [GCP 공식 문서](https://cloud.google.com/docs)
- [IAM 사용자 및 권한 관리](/mcp_knowledge_base/cloud_basic/textbook/Day1/iam-basics-guide.md)

---

**🎯 이제 클라우드 계정 설정의 기본기를 갖추었습니다! 2교시로 진행하세요.**


---

<div align="center">

## 🔗 관련 과정 및 네비게이션
[🏠 홈](/mcp_knowledge_base/index.md) | [📚 전체 커리큘럼](/mcp_knowledge_base/curriculum.md) | [🔗 학습 경로](/mcp_knowledge_base/cloud_basic/learning-path.md)

## 📖 현재 위치
**Cloud Basic** > **1일차** > **1교시: AWS & GCP 계정 생성 및 설정**

## ⬅️ 이전/다음 네비게이션
[← 이전: Cloud Basic 메인](/mcp_knowledge_base/cloud_basic/README.md) | [다음: Cloud Basic 1일차 →](/mcp_knowledge_base/cloud_basic/textbook/Day1/README.md)

## 🔗 관련 과정
[Cloud Master 1일차](/mcp_knowledge_base/cloud_master/textbook/Day1/README.md) | [Cloud Container 1일차](/mcp_knowledge_base/cloud_container/textbook/Day1/README.md)

</div>