
## 🛤️ 학습 순서

이 과정은 다음과 같은 순서로 진행됩니다:

### 1단계: 환경 준비 ["30분"]
- AWS 계정 생성 및 설정
- GCP 계정 생성 및 설정
- 기본 도구 설치 및 설정

### 2단계: Day1 - 기초 서비스 학습 ["4시간"]
- IAM 기초 및 사용자 관리
- 스토리지 서비스 이해 및 실습
- VM 서비스 기초 및 실습
- 문제해결 및 정리

### 3단계: Day2 - 서비스 비교 및 분석 ["3시간"]
- 컴퓨팅 서비스 비교 분석
- 데이터베이스 서비스 비교 분석
- 네트워킹 서비스 비교 분석
- 스토리지 서비스 비교 분석
- 종합 정리 및 다음 단계 준비

**💡 팁**: 각 단계를 순서대로 진행하시면 더 효과적으로 학습할 수 있습니다!

# Cloud Basic - 클라우드 기초 학습 경로

> 📋 **전체 개요**: (README.md)(../README.md) | ["통합 커리큘럼"](../curriculum.md) | ["통합 인덱스"](../index.md)에서 전체 과정 구조를 확인하세요.

<div align="center">
</div>

---

## 🎯 학습 목표

이 문서는 **Cloud Basic 과정**의 모든 문서를 **누락 없이** 체계적으로 정리한 완전한 학습 경로입니다. 클라우드 입문자를 위한 기초 서비스부터 네트워크, 보안, 데이터베이스까지 단계별로 학습할 수 있도록 구성되어 있습니다.

## 📚 과정 개요

### Cloud Basic - 클라우드 기초 ["2일"]
- **교육명**: 클라우드 실무력 강화! AWS & GCP 활용법["기초"]
- **교육일정**: 9/2["수"] ~ 9/3["목"]
- **교육시간**: 9:00 ~ 17:00 ["7시간/일"]
- **교육방식**: 오프라인
- **실습 환경**: AWS Free Tier + GCP Free Tier ["$300 크레딧"]

### 과정 상세 정보
- ["과정명 상세"]["과정명.md"]
- ["과정 상세 정보"]["과정상세.md"]

### 학습 목표
- 클라우드 컴퓨팅의 기본 개념 이해
- AWS와 GCP 계정 생성 및 기본 설정 수행
- IAM을 통한 사용자 및 권한 관리 기초 습득
- 가상머신, 스토리지, 네트워크, 데이터베이스 서비스의 기본 활용
- 클라우드 보안의 기초 개념 이해
- 간단한 웹 애플리케이션을 배포할 수 있는 기초 능력 확보

---

## 📅 1일차: AWS & GCP 기초 서비스 이론 및 실습

### 📚 이론 학습 ["90분"]

#### 1. 클라우드 개념 및 계정 생성 이론 ["30분"]

**📖 이론 학습 자료**
- ["클라우드 개념 및 계정 생성 가이드"](textbook/Day1/aws-gcp-account-setup.md)
- ["AWS 계정 가입 가이드"]["_accounts/AWS계정가입.md"]
- ["Azure 계정 가입 가이드"]["_accounts/Azure계정가입.md"]
- ["GCP 개인계정 가입 가이드"]["_accounts/GCP_개인계정가입.md"]
- ["GCP 조직계정 가입 가이드"]["_accounts/GCP_조직계정가입.md"]
- ["GCP 계정유형비교"]["_accounts/GCP_계정유형비교.md"]
- ["클라우드계정관리비교"]["_accounts/클라우드계정관리비교.md"]

**🎯 이론 학습 내용**
- 클라우드 컴퓨팅 개요와 장점
- AWS와 GCP 서비스 개요 및 비교
- 클라우드 계정 유형 및 관리 방법
- Free Tier 및 크레딧 정책 이해

#### 2. IAM 기초 이론 ["30분"]

**📖 이론 학습 자료**
- ["IAM 기초 가이드"](textbook/Day1/iam-basics-guide.md)

**🎯 이론 학습 내용**
- AWS IAM: 사용자, 그룹, 역할, 정책 개념
- GCP IAM: 서비스 계정, 역할, 권한 관리
- 클라우드 보안의 기본 원칙
- 권한 관리 모범 사례

#### 3. 가상머신 서비스 기초 이론 ["30분"]

**📖 이론 학습 자료**
- ["VM 서비스 가이드"](textbook/Day1/vm-services-guide.md)
- ["AWS EC2 vs GCP Compute Engine 비교"](textbook/Day2/compute_comparison.md)

**🎯 이론 학습 내용**
- AWS EC2 vs GCP Compute Engine 비교
- 인스턴스 타입, 이미지, 리전 개념
- 가상머신 생성 및 관리 방법
- 네트워킹 및 보안 설정

### 🛠️ 실습 학습 ["90분"]

#### 1. 클라우드 계정 생성 실습 ["30분"]

**🔧 실습 가이드**
- ["1일차 실습 가이드"](README.md)
- ["AWS 기초 실습"](textbook/Day1/practice/aws_basic_practice.md)
- ["GCP 기초 실습"](textbook/Day1/practice/gcp_basic_practice.md)

**🎯 실습 내용**
- AWS Free Tier 계정 생성 및 콘솔 탐색
- GCP 계정 생성 및 $300 크레딧 활성화
- 클라우드 콘솔 기본 사용법 학습

#### 2. IAM 기초 실습 ["30분"]

**🔧 실습 가이드**
- ["1일차 실습 가이드"](README.md)

**🎯 실습 내용**
- AWS IAM 사용자 생성 및 권한 부여
- GCP 서비스 계정 생성 및 키 관리
- IAM 정책 테스트 및 검증

#### 3. 가상머신 서비스 실습 ["30분"]

**🔧 실습 가이드**
- ["1일차 실습 가이드"](README.md)

**🎯 실습 내용**
- AWS EC2 인스턴스 생성 및 SSH 접속
- GCP Compute Engine 인스턴스 생성 및 접속
- 인스턴스 상태 모니터링 및 관리

### 📦 스토리지 서비스 이론 및 실습 ["90분"]

#### 📚 이론 학습 ["30분"]

**📖 이론 학습 자료**
- ["스토리지 서비스 가이드"](textbook/Day1/storage-services-guide.md)
- ["AWS S3 vs GCP Cloud Storage 비교"](textbook/Day2/storage_comparison.md)

**🎯 이론 학습 내용**
- AWS S3 vs GCP Cloud Storage 비교
- 객체 스토리지 개념과 활용 사례
- 스토리지 클래스 및 비용 최적화
- 데이터 보안 및 암호화

#### 🛠️ 실습 학습 ["60분"]

**🔧 실습 가이드**
- ["1일차 실습 가이드"](README.md)

**🎯 실습 내용**
- AWS S3 버킷 생성 및 파일 업로드/다운로드
- GCP Cloud Storage 버킷 생성 및 파일 관리
- 스토리지 정책 및 권한 설정

### 📚 1일차 실습 자료

#### 실습 가이드
- ["1일차 실습 가이드"](README.md)
- ["AWS 기본 실습"](textbook/Day1/practice/aws_basic_practice.md)
- ["GCP 기본 실습"](textbook/Day1/practice/gcp_basic_practice.md)
- ["실습1 AWS GCP"]["textbook/Day1/practice/실습1_aws_gcp.md"]

#### 핵심 가이드 문서
- ["IAM 기초 가이드"](textbook/Day1/iam-basics-guide.md)
- ["스토리지 서비스 가이드"](textbook/Day1/storage-services-guide.md)
- ["VM 서비스 가이드"](textbook/Day1/vm-services-guide.md)
- ["문제 해결 가이드"](textbook/Day1/troubleshooting-guide.md)

#### 자동화 스크립트
- ["AWS GCP 설정 스크립트"][textbook/Day1/guides/aws-gcp-setup.sh]
- ["AWS 설정 도우미"][textbook/Day1/guides/aws-setup-helper.sh]
- ["GCP 설정 도우미"][textbook/Day1/guides/gcp-setup-helper.sh]

#### 문제 해결
- ["문제 해결 가이드"](textbook/Day1/troubleshooting-guide.md)

---

## 📅 2일차: 네트워크, 보안 및 데이터베이스 이론 및 실습

### 📚 이론 학습 ["90분"]

#### 1. 네트워킹 기초 이론 ["30분"]

**📖 이론 학습 자료**
- ["네트워킹 기본 개념"](README.md)
- ["AWS VPC vs GCP VPC 비교"](textbook/Day2/network_comparison.md)

**🎯 이론 학습 내용**
- AWS VPC vs GCP VPC 개념 및 비교
- 서브넷, 라우팅, 게이트웨이, NAT 게이트웨이
- 클라우드 네트워킹 아키텍처 이해
- 네트워크 보안 및 격리 개념

#### 2. 보안 그룹 및 방화벽 이론 ["30분"]

**📖 이론 학습 자료**
- ["보안 그룹 및 방화벽 설정"](README.md)

**🎯 이론 학습 내용**
- AWS Security Groups vs GCP Firewall Rules
- 인바운드/아웃바운드 규칙 설정 및 모범 사례
- 클라우드 보안 모델 이해
- 방화벽 정책 설계 원칙

#### 3. 데이터베이스 서비스 기초 이론 ["30분"]

**📖 이론 학습 자료**
- ["AWS RDS vs GCP Cloud SQL 비교"](textbook/Day2/database_comparison.md)

**🎯 이론 학습 내용**
- AWS RDS vs GCP Cloud SQL 비교
- 관계형 데이터베이스 관리 및 백업
- 클라우드 데이터베이스 서비스 특징
- 데이터 보안 및 암호화

### 🛠️ 실습 학습 ["180분"]

#### 1. 네트워킹 기초 실습 ["60분"]

**🔧 실습 가이드**
- ["2일차 실습 가이드"](README.md)
- ["2일차 계정 설정 가이드"](textbook/Day1/aws-gcp-account-setup.md)

**🎯 실습 내용**
- AWS VPC 및 서브넷 구성
- GCP VPC 네트워크 및 서브넷 생성
- 라우팅 테이블 및 게이트웨이 설정
- 네트워크 연결성 테스트

#### 2. 보안 그룹 및 방화벽 실습 ["45분"]

**🔧 실습 가이드**
- ["2일차 실습 가이드"](README.md)

**🎯 실습 내용**
- AWS Security Groups 생성 및 규칙 설정
- GCP Firewall Rules 생성 및 테스트
- 보안 정책 검증 및 테스트
- 네트워크 보안 모니터링

#### 3. 데이터베이스 서비스 실습 ["45분"]

**🔧 실습 가이드**
- ["2일차 실습 가이드"](README.md)

**🎯 실습 내용**
- AWS RDS MySQL 인스턴스 생성 및 연결
- GCP Cloud SQL MySQL 인스턴스 생성 및 접속
- 데이터베이스 백업 및 복원 테스트
- 데이터베이스 성능 모니터링

#### 4. 종합 실습 및 비교 분석 ["30분"]

**🔧 실습 가이드**
- ["웹 서버 + 데이터베이스 구성 종합 실습"](README.md)
- ["Basic to Master 연계 가이드"](textbook/Day2/practice/basic-to-master-bridge.md)

**🎯 실습 내용**
- 간단한 웹 애플리케이션을 AWS와 GCP에 각각 배포
- AWS vs GCP 서비스별 비용 및 성능 비교
- 리소스 정리 및 비용 모니터링
- 다음 과정[Cloud Master] 준비

### 📚 2일차 실습 자료

#### 실습 가이드
- ["2일차 실습 가이드"](README.md)

#### 비교 분석 문서
- ["컴퓨팅 서비스 비교"](textbook/Day2/compute_comparison.md)
- ["데이터베이스 서비스 비교"](textbook/Day2/database_comparison.md)
- ["네트워킹 서비스 비교"](textbook/Day2/network_comparison.md)
- ["스토리지 서비스 비교"](textbook/Day2/storage_comparison.md)
- ["Basic to Master 연계 가이드"](textbook/Day2/practice/basic-to-master-bridge.md)

#### 자동화 스크립트
- ["AWS 설정 도우미"][textbook/Day1/guides/aws-setup-helper.sh]
- ["GCP 설정 도우미"][textbook/Day1/guides/gcp-setup-helper.sh]

---

## 🛠️ 설치 및 도구 가이드

### 필수 도구 설치
- ["AWS CLI 설치"](textbook/Day1/guides/install_aws_cli.md)
- ["Azure CLI 설치"](textbook/Day1/guides/install_azure_cli.md)
- ["GCP CLI 설치"](textbook/Day1/guides/install_glcoud_cli.md)
- ["Docker 설치"](textbook/Day1/guides/install_docker.md)
- ["Docker Compose 설치"](textbook/Day1/guides/install_docker_compose.md)
- ["Git 설치"](textbook/Day1/guides/install_git.md)
- ["GitHub Actions 완전 가이드"](textbook/Day1/guides/github-actions-complete-guide.md)

### 클라우드별 설치 스크립트
- ["AWS Docker Compose 설치"][textbook/Day1/guides/install_docker_compose_aws.sh]
- ["Azure Docker Compose 설치"][textbook/Day1/guides/install_docker_compose_azure.sh]
- ["GCP Docker Compose 설치"][textbook/Day1/guides/install_docker_compose_gcp.sh]
- ["AWS Git 설치"][textbook/Day1/guides/install_git_aws.sh]
- ["Azure Git 설치"][textbook/Day1/guides/install_git_azure.sh]
- ["GCP Git 설치"][textbook/Day1/guides/install_git_gcp.sh]

---

## 🤖 자동화 및 테스트

### 자동화 가이드
- ["자동화 README"](README.md)
- ["자동화 테스트 README"](README.md)

### 자동화 스크립트
- ["1일차 자동화 스크립트"][automation/day1/cloud_basics.sh]
- ["2일차 자동화 스크립트"][automation_tests/basic_course_day2_scripts.py]
- ["자동화 결과"][automation/results/automation_results.json]

### 자동화 테스트
- ["기본 과정 자동화"][automation_tests/cloud_basic_course_automation.py]
- ["2일차 스크립트 자동화"][automation_tests/basic_course_day2_scripts.py]
- ["자동화 테스트 실행"][automation_tests/run_basic_course_tests.py]
- ["자동화 테스트 검증"][automation_tests/test_basic_course_automation.py]
- ["사용자 가이드"](USER_GUIDE.md)

---

## 📊 프레젠테이션 자료

### 프레젠테이션 가이드
- ["프레젠테이션 README"](README.md)

### PDF 교재
- [클라우드실무력강화_활용법["기초"]_교재.pdf)_교재](README.md)_교재.pdf)_교재.pdf)
- [클라우드실무력강화_활용법["기초"]_교재.pdf)_실습](README.md)_교재.pdf)_실습.pdf)
- [클라우드실무력강화_활용법["기초"]_교재.pdf)_이론](README.md)_교재.pdf)_이론.pdf)

### PowerPoint 자료
- [클라우드실무력강화_활용법["기초"]_교재.pdf).pptx](README.md)_교재.pdf).pptx)

---

## 🎯 학습 체크리스트

### Cloud Basic 필수 체크리스트
- [ ] AWS 계정 생성 및 기본 설정
- [ ] GCP 계정 생성 및 기본 설정
- [ ] IAM 사용자 및 권한 관리
- [ ] EC2/Compute Engine 인스턴스 생성
- [ ] S3/Cloud Storage 버킷 생성 및 관리
- [ ] 네트워킹 기본 개념 이해
- [ ] 보안 그룹 및 방화벽 설정
- [ ] RDS/Cloud SQL 데이터베이스 생성 및 연결
- [ ] 웹 애플리케이션 배포 실습
- [ ] 리소스 정리 및 비용 모니터링

### 실습 완료 확인
- [ ] AWS EC2 인스턴스 생성 및 SSH 접속
- [ ] GCP Compute Engine 인스턴스 생성 및 접속
- [ ] AWS S3 버킷 생성 및 파일 업로드/다운로드
- [ ] GCP Cloud Storage 버킷 생성 및 파일 관리
- [ ] AWS VPC 및 서브넷 구성
- [ ] GCP VPC 네트워크 및 서브넷 생성
- [ ] AWS Security Groups 생성 및 규칙 설정
- [ ] GCP Firewall Rules 생성 및 테스트
- [ ] AWS RDS MySQL 인스턴스 생성 및 연결
- [ ] GCP Cloud SQL MySQL 인스턴스 생성 및 접속

---

## 🚀 다음 단계

### Cloud Master 과정 준비
- ["Cloud Master 과정 상세"]["cloud_master/과정상세.md"]
- ["Cloud Master 1일차 실습 가이드"](README.md)
- ["Basic to Master 연계 가이드"](textbook/Day2/practice/basic-to-master-bridge.md)

### 통합 학습 경로
- ["전체 커리큘럼"](curriculum.md)
- ["통합 인덱스"](index.md)
- ["통합 자동화 시스템"](README.md)

---

## 💡 추가 학습 자료

### 공식 문서
- ["AWS 공식 문서"][https:///docs.aws.amazon.com/]
- ["GCP 공식 문서"][https:///cloud.google.com/docs]
- ["AWS CLI 공식 문서"][https:///docs.aws.amazon.com/cli/]
- ["gcloud CLI 공식 문서"][https:///cloud.google.com/sdk/docs]

### 유용한 리소스
- [AWS Free Tier][https:///aws.amazon.com/free/]
- [GCP Free Tier][https:///cloud.google.com/free]
- [AWS CLI][https:///aws.amazon.com/cli/]
- [gcloud CLI][https:///cloud.google.com/sdk/docs]

---

## 🆘 문제 해결

### 자주 발생하는 문제
1. **계정 생성 문제**: 각 클라우드 제공업체의 계정 생성 가이드 참조
2. **권한 설정 문제**: IAM 가이드에서 권한 설정 방법 확인
3. **네트워크 연결 문제**: VPC 및 보안 그룹 설정 확인
4. **비용 초과 문제**: Free Tier 한도 확인 및 리소스 정리

### 지원 및 ### 📧 연락처
- **이메일**: inhwan.jung@gmail.com
- **GitHub**: ["프로젝트 저장소"][https:///github.com/jungfrau70/aws_gcp.git]
## 🔗 관련 과정 및 네비게이션

<div align="center">

["← 이전: Cloud Basic 메인"](README.md) | 
["📚 전체 커리큘럼"](curriculum.md) | 
["🏠 학습 경로로 돌아가기"](index.md) | 
["다음: Cloud Basic 1일차 →"](README.md)

</div>

## 🔗 관련 과정
["Cloud Master 1일차"](README.md) | ["Cloud Container 1일차"](README.md)

</div>

---

<div align="center">

["🏠 홈"](index.md) | ["📚 전체 커리큘럼"](curriculum.md) | 🔗 학습 경로

</div>
