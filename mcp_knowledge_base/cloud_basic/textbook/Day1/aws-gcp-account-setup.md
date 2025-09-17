# 1교시: AWS & GCP 계정 생성 및 설정


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

[🎯 학습 목표](#학습-목표)

### 핵심 학습 목표

[핵심 학습 목표](#핵심-학습-목표)
- **AWS Free Tier 계정** 생성 및 기본 설정
- **GCP 계정** 생성 및 $300 크레딧 활성화
- **AWS CLI 및 gcloud CLI** 설치 및 설정
- **계정 보안** 설정 및 모범 사례 적용
- **비용 모니터링** 설정 및 예산 관리

### 실습 후 달성할 수 있는 능력

[실습 후 달성할 수 있는 능력](#실습-후-달성할-수-있는-능력)
- ✅ AWS Free Tier 계정 생성 및 기본 설정
- ✅ GCP $300 크레딧 계정 생성 및 활성화
- ✅ AWS CLI와 gcloud CLI 설치 및 인증 설정
- ✅ IAM 사용자/서비스 계정 생성 및 권한 관리
- ✅ 비용 관리 및 예산 설정

### 예상 소요 시간

[예상 소요 시간](#예상-소요-시간)
- **AWS 계정 생성**: 30-45분
- **GCP 계정 생성**: 30-45분
- **CLI 설정**: 30-45분
- **비용 관리**: 15-30분
- **전체 과정**: 2-3시간

---

## 🚀 AWS 계정 생성 및 설정

[🚀 AWS 계정 생성 및 설정](#aws-계정-생성-및-설정)

<details>
<summary>📖 AWS 계정 생성 개요</summary>

### AWS 계정 생성 방법

[AWS 계정 생성 방법](#aws-계정-생성-방법)
- **웹콘솔 방식**: AWS 홈페이지에서 직접 생성
- **CLI 방식**: AWS CLI를 통한 자동화
- **Free Tier**: 12개월간 무료 사용 가능

### 중요 사항

[중요 사항](#중요-사항)
- **신용카드 정보 필수**: Free Tier 사용을 위해 필요
- **실제 비용 발생 가능**: Free Tier 한도 초과 시
- **계정 보안**: MFA(다단계 인증) 설정 권장

</details>

### 1.1 AWS 계정 생성

[1.1 AWS 계정 생성](#11-aws-계정-생성)

<details>
<summary>🌐 웹콘솔 방식</summary>

1. [AWS 홈페이지](https://aws.amazon.com) 접속
2. "AWS 계정 생성" 클릭
3. 계정 정보 입력:
   - 이메일 주소
   - 비밀번호 설정
   - 계정 이름 설정
4. 연락처 정보 입력
5. 결제 정보 입력 (신용카드)
6. 전화번호 인증
7. 지원 플랜 선택 (Basic Support)

</details>

### 1.2 AWS CLI 설정

[1.2 AWS CLI 설정](#12-aws-cli-설정)

```bash
# AWS CLI 설치 (macOS)
brew install awscli

# AWS CLI 설치 (Windows)
# https://aws.amazon.com/cli/

# 인증 설정
aws configure
# AWS Access Key ID: [입력]
# AWS Secret Access Key: [입력]
# Default region name: ap-northeast-2
# Default output format: json
```

---

## 🚀 GCP 계정 생성 및 설정

[🚀 GCP 계정 생성 및 설정](#gcp-계정-생성-및-설정)

<details>
<summary>📖 GCP 계정 생성 개요</summary>

### GCP 계정 생성 방법

[GCP 계정 생성 방법](#gcp-계정-생성-방법)
- **웹콘솔 방식**: GCP 홈페이지에서 직접 생성
- **CLI 방식**: gcloud CLI를 통한 자동화
- **Free Tier**: $300 크레딧 제공

### 중요 사항

[중요 사항](#중요-사항)
- **신용카드 정보 필수**: $300 크레딧 활성화를 위해 필요
- **실제 비용 발생 가능**: 크레딧 소진 시
- **계정 보안**: 2단계 인증 설정 권장

</details>

### 2.1 GCP 계정 생성

[2.1 GCP 계정 생성](#21-gcp-계정-생성)

<details>
<summary>🌐 웹콘솔 방식</summary>

1. [GCP 홈페이지](https://cloud.google.com) 접속
2. "무료로 시작하기" 클릭
3. 계정 정보 입력:
   - 이메일 주소
   - 비밀번호 설정
   - 국가/지역 선택
4. 결제 정보 입력 (신용카드)
5. $300 크레딧 활성화

</details>

### 2.2 GCP 프로젝트 생성

[2.2 GCP 프로젝트 생성](#22-gcp-프로젝트-생성)

1. **프로젝트 생성**:
   - 프로젝트 이름 설정
   - 조직 선택 (선택사항)
   - 위치 선택

2. **기본 설정**:
   - API 활성화
   - 서비스 계정 생성
   - 권한 설정

### 2.3 gcloud CLI 설정

[2.3 gcloud CLI 설정](#23-gcloud-cli-설정)

```bash
# gcloud CLI 설치 (macOS)
brew install google-cloud-sdk

# gcloud CLI 설치 (Windows)
# https://cloud.google.com/sdk/docs/install

# 인증 설정
gcloud auth login
gcloud config set project YOUR_PROJECT_ID
```

---

## ✅ 계정 설정 검증

[✅ 계정 설정 검증](#계정-설정-검증)

### AWS 계정 검증

[AWS 계정 검증](#aws-계정-검증)

```bash
# AWS CLI 버전 확인
aws --version

# AWS 계정 정보 확인
aws sts get-caller-identity

# AWS 서비스 목록 확인
aws ec2 describe-regions
```

### GCP 계정 검증

[GCP 계정 검증](#gcp-계정-검증)

```bash
# gcloud CLI 버전 확인
gcloud version

# GCP 계정 정보 확인
gcloud auth list

# GCP 프로젝트 목록 확인
gcloud projects list
```

---

## 💰 비용 관리 설정

[💰 비용 관리 설정](#비용-관리-설정)

### AWS 비용 관리

[AWS 비용 관리](#aws-비용-관리)

1. **AWS Billing Dashboard** 접속
2. **예산 설정**:
   - 월별 예산 설정
   - 알림 임계값 설정
   - 이메일 알림 설정

3. **비용 모니터링**:
   - Cost Explorer 활성화
   - 태그 기반 비용 추적
   - 예산 대비 실제 비용 모니터링

### GCP 비용 관리

[GCP 비용 관리](#gcp-비용-관리)

1. **GCP Billing Console** 접속
2. **예산 설정**:
   - 월별 예산 설정
   - 알림 임계값 설정
   - 이메일 알림 설정

3. **비용 모니터링**:
   - Billing Export 설정
   - 태그 기반 비용 추적
   - 예산 대비 실제 비용 모니터링

---

## 🧪 실습 과제

[🧪 실습 과제](#실습-과제)

### 과제 1: AWS 계정 설정

[과제 1: AWS 계정 설정](#과제-1-aws-계정-설정)

1. AWS Free Tier 계정 생성
2. IAM 사용자 생성 및 권한 설정
3. AWS CLI 설치 및 인증 설정
4. 비용 모니터링 설정

### 과제 2: GCP 계정 설정

[과제 2: GCP 계정 설정](#과제-2-gcp-계정-설정)

1. GCP 계정 생성 및 $300 크레딧 활성화
2. 프로젝트 생성 및 서비스 계정 설정
3. gcloud CLI 설치 및 인증 설정
4. 비용 모니터링 설정

### 과제 3: 통합 검증

[과제 3: 통합 검증](#과제-3-통합-검증)

1. 두 클라우드 계정 모두 정상 작동 확인
2. CLI 도구를 통한 기본 명령어 실행
3. 비용 모니터링 설정 확인

---

## 📚 문제 해결 및 참고 자료

[📚 문제 해결 및 참고 자료](#문제-해결-및-참고-자료)

### 일반적인 문제들

[일반적인 문제들](#일반적인-문제들)

#### 1. AWS 계정 생성 문제

[1. AWS 계정 생성 문제](#1-aws-계정-생성-문제)
- **신용카드 인증 실패**: 카드 정보 재확인
- **전화번호 인증 실패**: SMS 수신 확인
- **계정 생성 지연**: 24시간 후 재시도

#### 2. GCP 계정 생성 문제

[2. GCP 계정 생성 문제](#2-gcp-계정-생성-문제)
- **크레딧 활성화 실패**: 카드 정보 재확인
- **프로젝트 생성 실패**: 권한 확인
- **API 활성화 실패**: 결제 계정 확인

#### 3. CLI 설정 문제

[3. CLI 설정 문제](#3-cli-설정-문제)
- **인증 실패**: 토큰 갱신
- **권한 부족**: IAM 정책 확인
- **네트워크 오류**: 방화벽 설정 확인

### 참고 자료

[참고 자료](#참고-자료)

- [AWS 공식 문서](https://docs.aws.amazon.com/)
- [GCP 공식 문서](https://cloud.google.com/docs)
- [AWS CLI 사용법](https://docs.aws.amazon.com/cli/)
- [gcloud CLI 사용법](https://cloud.google.com/sdk/docs)

---

## 🎉 완료!

[🎉 완료!](#완료)

축하합니다! AWS & GCP 계정 생성 및 설정을 완료했습니다.

### 📚 학습 요약

[📚 학습 요약](#학습-요약)

이번 교시를 통해 다음을 배웠습니다:

1. **🏗️ AWS 계정**: Free Tier 계정 생성 및 IAM 사용자 설정
2. **☁️ GCP 계정**: $300 크레딧 계정 생성 및 서비스 계정 설정
3. **🔧 CLI 설정**: AWS CLI와 gcloud CLI 설치 및 인증
4. **💰 비용 관리**: 예산 설정 및 모니터링

### 🚀 다음 단계

[🚀 다음 단계](#다음-단계)

- **2교시 실습**: [IAM 사용자 및 권한 관리](/mcp_knowledge_base/cloud_basic/textbook/Day1/iam-basics-guide.md)
- **실제 프로젝트 적용**: 자신의 프로젝트에 클라우드 서비스 적용
- **고급 기능 학습**: 조직 관리, 외부 연동, 자동화

### 💡 추가 학습 자료

[💡 추가 학습 자료](#추가-학습-자료)

- [AWS 공식 문서](https://docs.aws.amazon.com/)
- [GCP 공식 문서](https://cloud.google.com/docs)
- [IAM 사용자 및 권한 관리](/mcp_knowledge_base/cloud_basic/textbook/Day1/iam-basics-guide.md)

---

**🎯 이제 클라우드 계정 설정의 기본기를 갖추었습니다! 2교시로 진행하세요.**

---

<div align="center">

[🏠 홈](/mcp_knowledge_base/index.md) | [📚 전체 커리큘럼](/mcp_knowledge_base/curriculum.md) | [🔗 학습 경로](/mcp_knowledge_base/cloud_basic/learning-path.md)

</div>