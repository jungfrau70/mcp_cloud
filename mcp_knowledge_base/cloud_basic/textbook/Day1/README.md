# 📅 Day 1: AWS & GCP 기초 서비스 실습

## 🎯 학습 목표

[🎯 학습 목표](#학습-목표)

오늘은 클라우드 컴퓨팅의 기본 개념을 이해하고, AWS와 GCP의 핵심 서비스를 직접 실습해보겠습니다. 
이 과정을 완료하면 클라우드 서비스의 기본 사용법을 익히고, 실제 프로젝트에서 바로 활용할 수 있는 기초 역량을 갖추게 됩니다.

### 📋 구체적인 학습 목표

[📋 구체적인 학습 목표](#구체적인-학습-목표)
- **클라우드 기본 개념 이해**: 클라우드 컴퓨팅의 핵심 개념과 장점을 설명할 수 있습니다
- **AWS 계정 생성 및 설정**: AWS 계정을 생성하고 기본 보안 설정을 완료할 수 있습니다
- **GCP 계정 생성 및 설정**: GCP 계정을 생성하고 프로젝트를 설정할 수 있습니다
- **EC2 인스턴스 관리**: EC2 인스턴스를 생성, 연결, 관리할 수 있습니다
- **S3 스토리지 활용**: S3 버킷을 생성하고 파일을 업로드/다운로드할 수 있습니다
- **Compute Engine 사용**: GCP Compute Engine 인스턴스를 생성하고 관리할 수 있습니다
- **Cloud Storage 활용**: GCP Cloud Storage를 사용하여 파일을 저장하고 관리할 수 있습니다

## ⏱️ 예상 소요시간

[⏱️ 예상 소요시간](#예상-소요시간)

- **이론 학습**: 2시간 (클라우드 개념, 서비스 소개)
- **실습**: 5시간 (계정 생성, 서비스 실습)
- **정리 및 문제해결**: 1시간
- **총 소요시간**: 8시간

## 📚 학습 순서

[📚 학습 순서](#학습-순서)

### 🌅 오전 (4시간)

[🌅 오전 (4시간)](#오전-4시간)

#### 1단계: 클라우드 기본 개념 이해 (1시간)

- [클라우드 컴퓨팅 개념](/mcp_knowledge_base/cloud_basic/textbook/Day1/aws-gcp-account-setup.md)
- [AWS 서비스 개요](/mcp_knowledge_base/cloud_basic/textbook/Day1/aws-gcp-account-setup.md)
- [GCP 서비스 개요](/mcp_knowledge_base/cloud_basic/textbook/Day1/aws-gcp-account-setup.md)

#### 2단계: AWS 계정 생성 및 설정 (1시간)

- [AWS 계정 생성](/mcp_knowledge_base/cloud_basic/accounts/AWS계정가입.md)
- [AWS CLI 설치 및 설정](/mcp_knowledge_base/cloud_basic/textbook/Day1/guides/install_aws_cli.md)
- [기본 보안 설정](/mcp_knowledge_base/cloud_basic/textbook/Day1/iam-basics-guide.md)

#### 3단계: GCP 계정 생성 및 설정 (1시간)

- [GCP 계정 생성](/mcp_knowledge_base/cloud_basic/accounts/GCP_개인계정가입.md)
- [GCP CLI 설치 및 설정](/mcp_knowledge_base/cloud_basic/textbook/Day1/guides/install_glcoud_cli.md)
- [프로젝트 설정](/mcp_knowledge_base/cloud_basic/textbook/Day1/aws-gcp-account-setup.md)

#### 4단계: 기본 실습 환경 확인 (1시간)

- [환경 설정 확인](/mcp_knowledge_base/cloud_basic/textbook/Day1/aws-gcp-account-setup.md)
- [연결 테스트](/mcp_knowledge_base/cloud_basic/textbook/Day1/aws-gcp-account-setup.md)

### 🌆 오후 (4시간)

[🌆 오후 (4시간)](#오후-4시간)

#### 5단계: AWS EC2 실습 (1시간)

- [EC2 인스턴스 생성](/mcp_knowledge_base/cloud_basic/textbook/Day1/vm-services-guide.md)
- [SSH 연결](/mcp_knowledge_base/cloud_basic/textbook/Day1/vm-services-guide.md)
- [기본 명령어 실행](/mcp_knowledge_base/cloud_basic/textbook/Day1/vm-services-guide.md)

#### 6단계: AWS S3 실습 (1시간)

- [S3 버킷 생성](/mcp_knowledge_base/cloud_basic/textbook/Day1/storage-services-guide.md)
- [파일 업로드/다운로드](/mcp_knowledge_base/cloud_basic/textbook/Day1/storage-services-guide.md)
- [권한 설정](/mcp_knowledge_base/cloud_basic/textbook/Day1/storage-services-guide.md)

#### 7단계: GCP Compute Engine 실습 (1시간)

- [Compute Engine 인스턴스 생성](/mcp_knowledge_base/cloud_basic/textbook/Day1/vm-services-guide.md)
- [SSH 연결](/mcp_knowledge_base/cloud_basic/textbook/Day1/vm-services-guide.md)
- [기본 명령어 실행](/mcp_knowledge_base/cloud_basic/textbook/Day1/vm-services-guide.md)

#### 8단계: GCP Cloud Storage 실습 (1시간)

- [Cloud Storage 버킷 생성](/mcp_knowledge_base/cloud_basic/textbook/Day1/storage-services-guide.md)
- [파일 업로드/다운로드](/mcp_knowledge_base/cloud_basic/textbook/Day1/storage-services-guide.md)
- [권한 설정](/mcp_knowledge_base/cloud_basic/textbook/Day1/storage-services-guide.md)

## 💻 실습 가이드

[💻 실습 가이드](#실습-가이드)

### 🔧 필수 도구 설치

[🔧 필수 도구 설치](#필수-도구-설치)
실습을 시작하기 전에 다음 도구들을 설치해주세요:

1. **AWS CLI 설치**
   ```bash
   # Windows
   # https:///aws.amazon.com/cli/ 에서 다운로드
   
   # 설치 확인
   aws --version
   ```

2. **GCP CLI 설치**
   ```bash
   # Windows
   # https:///cloud.google.com/sdk/docs/install 에서 다운로드
   
   # 설치 확인
   gcloud --version
   ```

3. **SSH 클라이언트**
   - Windows: PuTTY 또는 Windows Terminal
   - Mac: 기본 터미널
   - Linux: 기본 터미널

### 📝 실습 체크리스트

[📝 실습 체크리스트](#실습-체크리스트)

#### AWS 실습 체크리스트

- [ ] AWS 계정 생성 완료
- [ ] AWS CLI 설치 및 설정 완료
- [ ] EC2 인스턴스 생성 성공
- [ ] SSH 연결 성공
- [ ] S3 버킷 생성 성공
- [ ] 파일 업로드/다운로드 성공

#### GCP 실습 체크리스트

- [ ] GCP 계정 생성 완료
- [ ] GCP CLI 설치 및 설정 완료
- [ ] Compute Engine 인스턴스 생성 성공
- [ ] SSH 연결 성공
- [ ] Cloud Storage 버킷 생성 성공
- [ ] 파일 업로드/다운로드 성공

## ✅ 완료 확인

[✅ 완료 확인](#완료-확인)

### 🎯 학습 목표 달성 확인

[🎯 학습 목표 달성 확인](#학습-목표-달성-확인)
다음 질문들에 답할 수 있다면 학습 목표를 달성한 것입니다:

1. **클라우드 기본 개념**
   - 클라우드 컴퓨팅이 무엇인지 설명할 수 있나요?
   - AWS와 GCP의 주요 차이점을 설명할 수 있나요?

2. **계정 관리**
   - AWS 계정을 생성하고 기본 설정을 완료했나요?
   - GCP 계정을 생성하고 프로젝트를 설정했나요?

3. **서비스 사용**
   - EC2 인스턴스를 생성하고 연결할 수 있나요?
   - S3 버킷을 생성하고 파일을 업로드할 수 있나요?
   - Compute Engine 인스턴스를 생성하고 연결할 수 있나요?
   - Cloud Storage 버킷을 생성하고 파일을 업로드할 수 있나요?

### 📊 실습 결과 확인

[📊 실습 결과 확인](#실습-결과-확인)
- **AWS 실습**: 모든 체크리스트 항목 완료
- **GCP 실습**: 모든 체크리스트 항목 완료
- **문제해결**: 발생한 문제를 스스로 해결했나요?

## 🔧 문제해결

[🔧 문제해결](#문제해결)

### 자주 발생하는 문제들

[자주 발생하는 문제들](#자주-발생하는-문제들)

#### 1. AWS 계정 생성 문제

**문제**: 신용카드 정보 입력 시 오류 발생
**해결**: 
- 카드 정보를 정확히 입력했는지 확인
- 카드가 해외 결제가 가능한지 확인
- AWS 지원팀에 문의

#### 2. SSH 연결 실패

**문제**: EC2 인스턴스에 SSH 연결이 안됨
**해결**:
- 보안 그룹에서 SSH(22번 포트) 허용 확인
- 키 페어 파일 권한 확인 (Windows: 600, Mac/Linux: chmod 400)
- 인스턴스 상태 확인 (running 상태여야 함)

#### 3. GCP 프로젝트 설정 문제

**문제**: GCP 프로젝트 생성 후 CLI에서 인식하지 못함
**해결**:
- `gcloud auth login` 실행
- `gcloud config set project [PROJECT_ID]` 실행
- 프로젝트 ID 확인

#### 4. 권한 오류

**문제**: S3 버킷에 파일 업로드 시 권한 오류
**해결**:
- IAM 사용자 권한 확인
- 버킷 정책 확인
- AWS CLI 자격 증명 확인

### 📞 추가 도움

[📞 추가 도움](#추가-도움)
- [종합 문제해결 가이드](/mcp_knowledge_base/cloud_basic/textbook/Day1/troubleshooting-guide.md)
- [AWS 공식 문서](https:///docs.aws.amazon.com/)
- [GCP 공식 문서](https:///cloud.google.com/docs)

## ➡️ 다음 단계

[➡️ 다음 단계](#다음-단계)

### 📅 Day 2 준비

[📅 Day 2 준비](#day-2-준비)
Day 1을 성공적으로 완료했다면, 다음 단계인 Day 2로 진행할 수 있습니다:

- Day 2: 서비스 비교 및 최적화

### 🔗 관련 자료

[🔗 관련 자료](#관련-자료)
- Cloud Basic 과정 전체
- [학습 경로](/mcp_knowledge_base/learning-path.md)
- [전체 커리큘럼](/mcp_knowledge_base/curriculum.md)

### 🎯 다음 단계 학습 목표

[🎯 다음 단계 학습 목표](#다음-단계-학습-목표)
Day 2에서는 다음 내용을 학습하게 됩니다:
- AWS와 GCP 서비스 비교 분석
- 비용 최적화 전략
- 보안 및 모니터링 기초
- 종합 프로젝트

---

<div align="center">

## 🎉 Day 1 실습을 시작하세요!

[🎉 Day 1 실습을 시작하세요!](#day-1-실습을-시작하세요)

[🚀 실습 시작하기](/mcp_knowledge_base/cloud_basic/textbook/Day1/aws-gcp-account-setup.md) | 
📚 Cloud Basic 과정 전체 |
[🏠 홈으로 돌아가기](/mcp_knowledge_base/index.md)

</div>

---

## 🧭 네비게이션

[🧭 네비게이션](#네비게이션)

<div align="center">

[🏠 홈으로 돌아가기](/mcp_knowledge_base/index.md) | 
[📚 전체 커리큘럼](/mcp_knowledge_base/curriculum.md) | 
[🔗 학습 경로](/mcp_knowledge_base/learning-path.md)

[📅 Day1 시작하기](/mcp_knowledge_base/README.md)

</div>
