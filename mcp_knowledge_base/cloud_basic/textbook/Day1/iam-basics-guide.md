# 2교시: IAM 사용자 및 권한 관리

<div align="center">

[← 이전: Cloud Basic 1일차 메인](/mcp_knowledge_base/cloud_master/README.md) | [📚 전체 커리큘럼](/mcp_knowledge_base/curriculum.md) | [🏠 학습 경로로 돌아가기](/mcp_knowledge_base/index.md) | [📋 학습 경로](/mcp_knowledge_base/cloud_master/learning-path.md)

</div>

<details>
<summary>📋 목차</summary>

1. [🎯 학습 목표](#학습-목표)
2. [🔐 AWS IAM 기초](#aws-iam-기초)
3. [🚀 GCP IAM 기초](#gcp-iam-기초)
4. [🚀 비교 분석](#비교-분석)
5. [🧪 실습 과제](#실습-과제)
6. [📚 문제 해결 및 참고 자료](#문제-해결-및-참고-자료)

</details>

---

## 🎯 학습 목표

### 핵심 학습 목표

[핵심 학습 목표](#핵심-학습-목표)
- **AWS IAM** 사용자, 그룹, 역할, 정책 개념 이해
- **GCP IAM** 서비스 계정, 역할, 권한 관리 이해
- **최소 권한 원칙** 적용 및 보안 모범 사례 학습
- **실무 환경**에서의 IAM 관리 방법 습득

### 실습 후 달성할 수 있는 능력

[실습 후 달성할 수 있는 능력](#실습-후-달성할-수-있는-능력)
- ✅ AWS IAM 사용자, 그룹, 역할, 정책 관리
- ✅ GCP 서비스 계정, 역할, 권한 관리
- ✅ 최소 권한 원칙 적용 및 보안 모범 사례
- ✅ 실무 환경에서의 IAM 관리 방법

### 예상 소요 시간

[예상 소요 시간](#예상-소요-시간)
- **AWS IAM 기초**: 60-90분
- **GCP IAM 기초**: 60-90분
- **비교 분석**: 30-45분
- **실습 과제**: 45-60분
- **전체 과정**: 3-4시간

---

## 🔐 AWS IAM 기초

<details>
<summary>📖 AWS IAM 개요</summary>

### IAM이란?

[IAM이란?](#iam이란)
- **Identity and Access Management**: AWS의 사용자 및 권한 관리 서비스
- **중앙 집중식 관리**: 모든 AWS 리소스에 대한 접근 제어
- **보안 강화**: 최소 권한 원칙을 통한 보안 강화

### 주요 구성 요소

[주요 구성 요소](#주요-구성-요소)
- **Users**: 개인 사용자 계정
- **Groups**: 사용자 그룹
- **Roles**: 임시 권한 역할
- **Policies**: 권한 정의 문서

</details>

### 1.1 IAM 핵심 개념

[1.1 IAM 핵심 개념](#11-iam-핵심-개념)

<details>
<summary>👤 사용자 (Users)</summary>

### 사용자 유형

[사용자 유형](#사용자-유형)
- **개인 사용자**: 실제 사람이 사용하는 계정
- **프로그래밍 방식 액세스**: API, CLI, SDK 사용
- **콘솔 액세스**: 웹 콘솔 사용

### 사용자 특징

[사용자 특징](#사용자-특징)
- **장기적 계정**: 지속적으로 사용하는 계정
- **개인 식별**: 고유한 사용자 이름과 ARN
- **자격 증명**: 액세스 키, 비밀 키, MFA 설정

</details>

<details>
<summary>👥 그룹 (Groups)</summary>

### 그룹의 역할

[그룹의 역할](#그룹의-역할)
- **권한 관리 단순화**: 여러 사용자에게 동일한 권한 부여
- **조직 구조 반영**: 부서별, 역할별 그룹 구성
- **중앙 집중식 관리**: 그룹 단위로 권한 관리

### 그룹 특징

[그룹 특징](#그룹-특징)
- **사용자 컨테이너**: 여러 사용자를 포함
- **정책 연결**: 그룹에 정책을 연결하여 권한 부여
- **상속**: 그룹의 권한을 사용자가 상속

</details>

<details>
<summary>🎭 역할 (Roles)</summary>

### 역할의 특징

[역할의 특징](#역할의-특징)
- **임시 권한**: 특정 작업을 위한 일시적 권한
- **서비스 간 접근**: AWS 서비스 간 권한 위임
- **외부 IDP 연동**: SAML, OIDC 연동

### 역할 사용 사례

[역할 사용 사례](#역할-사용-사례)
- **EC2 인스턴스**: EC2가 다른 AWS 서비스에 접근
- **Lambda 함수**: Lambda가 다른 서비스에 접근
- **외부 사용자**: SAML/OIDC를 통한 외부 사용자 인증

</details>

<details>
<summary>📋 정책 (Policies)</summary>

### 정책 형식

[정책 형식](#정책-형식)
- **JSON 형식**: 권한을 정의하는 문서
- **허용/거부**: 명시적 허용과 거부 규칙
- **조건부 권한**: 특정 조건에서만 권한 부여

### 정책 유형

[정책 유형](#정책-유형)
- **관리형 정책**: AWS에서 제공하는 정책
- **고객 관리형 정책**: 사용자가 생성한 정책
- **인라인 정책**: 특정 사용자/그룹에 직접 연결

</details>

### 1.2 AWS IAM 실습

[1.2 AWS IAM 실습](#12-aws-iam-실습)

<details>
<summary>👤 사용자 생성</summary>
```bash
# IAM 사용자 생성
aws iam create-user --user-name cloud-student

# 사용자 정보 확인
aws iam get-user --user-name cloud-student
```

</details>

<details>
<summary>👥 그룹 생성 및 사용자 추가</summary>
```bash
# IAM 그룹 생성
aws iam create-group --group-name CloudStudents

# 사용자를 그룹에 추가
aws iam add-user-to-group \
  --group-name CloudStudents \
  --user-name cloud-student
```

</details>

<details>
<summary>📋 정책 연결</summary>
```bash
# 기존 정책 연결
aws iam attach-group-policy \
  --group-name CloudStudents \
  --policy-arn arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess

# 커스텀 정책 생성
aws iam create-policy \
  --policy-name CloudStudentPolicy \
  --policy-document file://policy.json
```

</details>

---

## 🚀 GCP IAM 기초

<details>
<summary>📖 GCP IAM 개요</summary>

### IAM이란?

[IAM이란?](#iam이란)
- **Identity and Access Management**: Google Cloud의 사용자 및 권한 관리 서비스
- **프로젝트 기반**: 프로젝트 단위로 권한 관리
- **서비스 계정 중심**: 애플리케이션용 계정 중심

### 주요 구성 요소

[주요 구성 요소](#주요-구성-요소)
- **Users**: 개인 사용자 계정
- **Service Accounts**: 애플리케이션용 계정
- **Roles**: 권한 역할
- **Policies**: 권한 정의

</details>

### 2.1 IAM 핵심 개념

[2.1 IAM 핵심 개념](#21-iam-핵심-개념)

<details>
<summary>🔑 서비스 계정 (Service Accounts)</summary>

### 서비스 계정 특징

[서비스 계정 특징](#서비스-계정-특징)
- **애플리케이션용**: 서비스 간 인증에 사용
- **키 관리**: JSON 키 파일 또는 메타데이터 서버
- **권한 위임**: 다른 서비스에 권한 위임

### 서비스 계정 사용 사례

[서비스 계정 사용 사례](#서비스-계정-사용-사례)
- **Compute Engine**: VM이 다른 서비스에 접근
- **Cloud Functions**: 함수가 다른 서비스에 접근
- **Kubernetes**: Pod가 다른 서비스에 접근

</details>

<details>
<summary>🎭 역할 (Roles)</summary>

### 역할 유형

[역할 유형](#역할-유형)
- **기본 역할**: Owner, Editor, Viewer
- **사전 정의된 역할**: 특정 서비스에 대한 권한
- **커스텀 역할**: 조직에 맞는 맞춤형 권한

### 역할 특징

[역할 특징](#역할-특징)
- **세분화된 권한**: 특정 서비스에 대한 세밀한 권한
- **조합 가능**: 여러 역할을 조합하여 사용
- **조건부 권한**: 특정 조건에서만 권한 부여

</details>

<details>
<summary>📋 정책 (Policies)</summary>

### 정책 유형

[정책 유형](#정책-유형)
- **IAM 정책**: 사용자/서비스 계정에 권한 부여
- **조직 정책**: 조직 전체에 적용되는 정책
- **리소스 정책**: 특정 리소스에 대한 정책

### 정책 특징

[정책 특징](#정책-특징)
- **계층적 적용**: 조직 → 프로젝트 → 리소스 순으로 적용
- **상속**: 상위 레벨의 정책을 하위 레벨에서 상속
- **조건부 적용**: 특정 조건에서만 정책 적용

</details>

### 2.2 GCP IAM 실습

[2.2 GCP IAM 실습](#22-gcp-iam-실습)

<details>
<summary>🔑 서비스 계정 생성</summary>
```bash
# 서비스 계정 생성
gcloud iam service-accounts create cloud-student-sa \
  --display-name="Cloud Student Service Account"

# 서비스 계정 목록 확인
gcloud iam service-accounts list
```

</details>

<details>
<summary>🎭 역할 부여</summary>
```bash
# 프로젝트 레벨 역할 부여
gcloud projects add-iam-policy-binding PROJECT_ID \
  --member="serviceAccount:cloud-student-sa@PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/compute.instanceAdmin"

# 리소스 레벨 역할 부여
gcloud compute instances add-iam-policy-binding INSTANCE_NAME \
  --zone=ZONE \
  --member="serviceAccount:cloud-student-sa@PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/compute.instanceAdmin"
```

</details>

<details>
<summary>🔑 키 관리</summary>
```bash
# 서비스 계정 키 생성
gcloud iam service-accounts keys create key.json \
  --iam-account=cloud-student-sa@PROJECT_ID.iam.gserviceaccount.com

# 서비스 계정 인증
gcloud auth activate-service-account \
  --key-file=key.json
```

</details>

---

## 🚀 비교 분석

<details>
<summary>📊 AWS IAM vs GCP IAM 비교</summary>

| 구분 | AWS IAM | GCP IAM |
|------|---------|---------|
| **사용자 관리** | Users, Groups | Users, Groups |
| **서비스 계정** | IAM Roles | Service Accounts |
| **정책 형식** | JSON | JSON |
| **권한 모델** | Resource-based | Resource-based |
| **조직 관리** | Organizations | Organizations |
| **외부 연동** | SAML, OIDC | SAML, OIDC |

### 주요 차이점

[주요 차이점](#주요-차이점)
- **AWS**: 역할(Roles) 중심의 임시 권한 관리
- **GCP**: 서비스 계정(Service Accounts) 중심의 애플리케이션 권한 관리
- **정책**: 둘 다 JSON 형식이지만 구조가 다름

</details>

---

## 🧪 실습 과제

<details>
<summary>📖 실습 과제 개요</summary>

### 실습 목적

[실습 목적](#실습-목적)
- **AWS IAM**: 사용자, 그룹, 역할, 정책 관리
- **GCP IAM**: 서비스 계정, 역할, 권한 관리
- **비교 분석**: 두 플랫폼의 IAM 차이점 이해
- **보안 모범 사례**: 최소 권한 원칙 적용

### 실습 결과물

[실습 결과물](#실습-결과물)
- AWS IAM 사용자 및 그룹 구성
- GCP 서비스 계정 및 역할 설정
- 권한 테스트 및 검증
- 보안 모범 사례 적용

</details>

### 기본 과제

[기본 과제](#기본-과제)

<details>
<summary>📋 기본 과제 목록</summary>
1. **AWS IAM 사용자 생성**: 프로그래밍 방식 액세스 사용자 생성
2. **GCP 서비스 계정 생성**: 애플리케이션용 서비스 계정 생성
3. **권한 테스트**: 생성한 계정으로 리소스 접근 테스트
4. **정책 비교**: AWS와 GCP의 정책 구조 비교

</details>

### 고급 과제

[고급 과제](#고급-과제)

<details>
<summary>📋 고급 과제 목록</summary>
1. **최소 권한 원칙**: 필요한 최소한의 권한만 부여
2. **조건부 정책**: 특정 조건에서만 권한 부여하는 정책 작성
3. **권한 감사**: 현재 부여된 권한 검토 및 최적화
4. **자동화**: IAM 설정 자동화 스크립트 작성

</details>

---

## ✅ 체크리스트

[✅ 체크리스트](#체크리스트)

<details>
<summary>📋 학습 완료 체크리스트</summary>

### AWS IAM 설정

[AWS IAM 설정](#aws-iam-설정)
- [ ] AWS IAM 사용자 생성 완료
- [ ] IAM 그룹 생성 및 사용자 추가 완료
- [ ] 정책 연결 및 권한 부여 완료
- [ ] 권한 테스트 완료

### GCP IAM 설정

[GCP IAM 설정](#gcp-iam-설정)
- [ ] GCP 서비스 계정 생성 완료
- [ ] 역할 부여 및 권한 설정 완료
- [ ] 키 관리 및 인증 설정 완료
- [ ] 권한 테스트 완료

### 보안 및 모범 사례

[보안 및 모범 사례](#보안-및-모범-사례)
- [ ] 최소 권한 원칙 적용 완료
- [ ] 보안 모범 사례 적용 완료
- [ ] 권한 감사 및 최적화 완료

</details>

---

## 📚 문제 해결 및 참고 자료

<details>
<summary>🐛 자주 발생하는 문제</summary>

### AWS IAM 관련 문제

[AWS IAM 관련 문제](#aws-iam-관련-문제)
<details>
<summary>❌ IAM 사용자 생성 실패</summary>

**원인**:
- 사용자 이름 중복
- 권한 부족
- 정책 오류

**해결방법**:
```bash
# 1. 사용자 목록 확인
aws iam list-users

# 2. 권한 확인
aws sts get-caller-identity

# 3. 정책 확인
aws iam list-attached-user-policies --user-name USER_NAME
```

</details>

<details>
<summary>❌ 정책 연결 실패</summary>

**원인**:
- 정책 ARN 오류
- 권한 부족
- 정책 형식 오류

**해결방법**:
```bash
# 1. 정책 ARN 확인
aws iam list-policies --query 'Policies[?PolicyName==`POLICY_NAME`]'

# 2. 정책 내용 확인
aws iam get-policy --policy-arn POLICY_ARN

# 3. 정책 연결 확인
aws iam list-attached-group-policies --group-name GROUP_NAME
```

</details>

### GCP IAM 관련 문제

[GCP IAM 관련 문제](#gcp-iam-관련-문제)
<details>
<summary>❌ 서비스 계정 생성 실패</summary>

**원인**:
- 프로젝트 ID 오류
- 권한 부족
- 서비스 계정 ID 중복

**해결방법**:
```bash
# 1. 프로젝트 ID 확인
gcloud config get-value project

# 2. 권한 확인
gcloud auth list

# 3. 서비스 계정 목록 확인
gcloud iam service-accounts list
```

</details>

<details>
<summary>❌ 역할 부여 실패</summary>

**원인**:
- 역할 이름 오류
- 멤버 형식 오류
- 권한 부족

**해결방법**:
```bash
# 1. 사용 가능한 역할 확인
gcloud iam roles list

# 2. 멤버 형식 확인
gcloud projects get-iam-policy PROJECT_ID

# 3. 역할 부여 확인
gcloud projects get-iam-policy PROJECT_ID --flatten="bindings[].members"
```

</details>

</details>

<details>
<summary>📖 추가 학습 자료</summary>

### 공식 문서

[공식 문서](#공식-문서)
- [AWS IAM 공식 문서](https://docs.aws.amazon.com/iam/)
- [GCP IAM 공식 문서](https://cloud.google.com/iam/docs)
- [AWS IAM 정책 참조](https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies.html)
- [GCP IAM 역할 참조](https://cloud.google.com/iam/docs/understanding-roles)

### 유용한 리소스

[유용한 리소스](#유용한-리소스)
- [AWS IAM 모범 사례](https://docs.aws.amazon.com/IAM/latest/UserGuide/best-practices.html)
- [GCP IAM 모범 사례](https://cloud.google.com/iam/docs/using-iam-securely)
- [AWS IAM 정책 시뮬레이터](https://policysim.aws.amazon.com/)
- [GCP IAM 정책 시뮬레이터](https://cloud.google.com/iam/docs/testing-iam-policies)

### 관련 프로젝트

[관련 프로젝트](#관련-프로젝트)
- [AWS IAM 샘플 프로젝트](https://github.com/aws-samples/aws-iam-examples)
- [GCP IAM 샘플 프로젝트](https://github.com/GoogleCloudPlatform/iam-examples)

</details>

<details>
<summary>🚀 다음 단계</summary>

### 3교시 준비

[3교시 준비](#3교시-준비)
1. **가상머신 서비스**: AWS EC2, GCP Compute Engine
2. **인스턴스 관리**: 생성, 시작, 중지, 종료
3. **보안 그룹**: 네트워크 보안 설정

### 고급 기능

[고급 기능](#고급-기능)
1. **오토 스케일링**: 자동 확장/축소
2. **로드 밸런싱**: 트래픽 분산
3. **모니터링**: CloudWatch, Cloud Monitoring

</details>

---

## 🎉 완료!

[🎉 완료!](#완료)

축하합니다! IAM 사용자 및 권한 관리를 완료했습니다.

### 📚 학습 요약

[📚 학습 요약](#학습-요약)

이번 교시를 통해 다음을 배웠습니다:

1. **🔐 AWS IAM**: 사용자, 그룹, 역할, 정책 관리
2. **☁️ GCP IAM**: 서비스 계정, 역할, 권한 관리
3. **⚖️ 비교 분석**: 두 플랫폼의 IAM 차이점 이해
4. **🛡️ 보안 모범 사례**: 최소 권한 원칙 적용

### 🚀 다음 단계

[🚀 다음 단계](#다음-단계)

- **3교시 실습**: [가상머신 서비스 실습](/mcp_knowledge_base/cloud_basic/textbook/Day1/vm-services-guide.md)
- **실제 프로젝트 적용**: 자신의 프로젝트에 IAM 적용
- **고급 기능 학습**: 조직 관리, 외부 연동, 자동화

### 💡 추가 학습 자료

[💡 추가 학습 자료](#추가-학습-자료)

- [AWS IAM 공식 문서](https://docs.aws.amazon.com/iam/)
- [GCP IAM 공식 문서](https://cloud.google.com/iam/docs)
- [가상머신 서비스 실습](/mcp_knowledge_base/cloud_basic/textbook/Day1/vm-services-guide.md)

---

**🎯 이제 클라우드 보안의 기본기를 갖추었습니다! 3교시로 진행하세요.**


---

<div align="center">

[🏠 홈](/mcp_knowledge_base/index.md) | [📚 전체 커리큘럼](/mcp_knowledge_base/curriculum.md) | [🔗 학습 경로](/mcp_knowledge_base/cloud_basic/learning-path.md)

</div>

---

<div align="center">

[🏠 홈](/mcp_knowledge_base/index.md) | [📚 전체 커리큘럼](/mcp_knowledge_base/curriculum.md) | [🔗 학습 경로](/mcp_knowledge_base/cloud_basic/learning-path.md)

</div>
