# Cloud Basic 개선된 스크립트 모음

Cloud Basic 과정의 통합된 실습 스크립트들입니다.

## 📁 스크립트 구조

```
scripts/
├── cloud-basic-helper.sh           # 기본 Helper 스크립트
├── cloud-basic-advanced.sh         # 고도화된 Helper 스크립트
└── README.md                       # 이 파일
```

## 🚀 주요 기능

### 1. Interactive 사용자 인터페이스
- 메뉴 기반 선택 시스템
- 진행 상태 표시
- 색상 구분된 로그 메시지
- 사용자 친화적 오류 메시지

### 2. 종합 환경 체크
- AWS CLI 설치 및 계정 설정 확인
- GCP CLI 설치 및 계정 설정 확인
- Python 설치 확인
- 상세한 환경 상태 보고

### 3. Day별 실습 자동화
- Day 1: 클라우드 기초, IAM, VM, 스토리지 서비스
- Day 2: 네트워킹, 보안, 데이터베이스, 종합 실습
- 각 실습별 독립적인 스크립트 실행

### 4. 자동화 테스트 시스템
- Dry-run 테스트 실행
- Basic 과정 테스트 실행
- 자동화 스크립트 생성

### 5. 리소스 관리
- AWS/GCP 리소스 정리
- 안전한 리소스 삭제 확인

## 📋 스크립트별 상세 설명

### 1. cloud-basic-helper.sh
**기본 Helper 스크립트**

```bash
./cloud-basic-helper.sh
```

**주요 기능:**
- 종합 환경 체크 [AWS, GCP, Python]
- Day 1 실습 자동화 ["4개 실습"]
- Day 2 실습 자동화 ["4개 실습"]
- 자동화 테스트 실행
- 자동화 스크립트 생성
- 리소스 정리 및 관리

**사용 예시:**
```bash
# 기본 Helper 스크립트 실행
./cloud-basic-helper.sh

# 메뉴에서 선택하여 실행
1. 🔍 종합 환경 체크
2. 🚀 Day 1: 클라우드 기초 실습
3. 🚀 Day 1: IAM 기초 실습
4. 🚀 Day 1: VM 서비스 실습
5. 🚀 Day 1: 스토리지 서비스 실습
6. 🚀 Day 2: 네트워킹 기초 실습
7. 🚀 Day 2: 보안 기초 실습
8. 🚀 Day 2: 데이터베이스 서비스 실습
9. 🚀 Day 2: 종합 실습
10. 🧪 자동화 테스트 실행
11. 🔧 자동화 스크립트 생성
12. 🧹 AWS 리소스 정리
13. 🧹 GCP 리소스 정리
```

### 2. cloud-basic-advanced.sh
**고도화된 Helper 스크립트**

```bash
./cloud-basic-advanced.sh
```

**주요 기능:**
- 종합 환경 체크 [AWS, GCP, Python]
- AWS/GCP 리소스 현황 모니터링
- AWS/GCP 비용 분석 및 최적화 제안
- Day 1/Day 2 실습 자동 실행
- 자동화 테스트 실행 및 스크립트 생성
- AWS/GCP 리소스 정리 ["안전 모드"]
- 상세한 로깅 및 진행 상황 추적

**고급 기능:**
- 사용하지 않는 리소스 자동 감지
- 비용 최적화 제안
- 자동화 테스트 통합
- 안전한 리소스 정리 ["확인 단계 포함"]

**사용 예시:**
```bash
# 고도화된 스크립트 실행
./cloud-basic-advanced.sh

# 메뉴에서 선택하여 실행
1. 🔍 종합 환경 체크
2. 📊 AWS 리소스 현황
3. 📊 GCP 리소스 현황
4. 💰 AWS 비용 분석
5. 💰 GCP 비용 분석
6. 🚀 Day 1 실습 실행 ["전체"]
7. 🚀 Day 2 실습 실행 ["전체"]
8. 🧪 자동화 테스트 실행
9. 🔧 자동화 스크립트 생성
10. 🧹 AWS 리소스 정리
11. 🧹 GCP 리소스 정리
12. 📋 로그 보기
```

## 🔧 사용 전 준비사항

### 1. 필수 도구 설치
```bash
# AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# GCP CLI
curl https://sdk.cloud.google.com | bash

# Python 3
sudo apt update && sudo apt install python3 python3-pip
```

### 2. 계정 설정
```bash
# AWS 계정 설정
aws configure

# GCP 계정 설정
gcloud auth login
gcloud config set project YOUR_PROJECT_ID
```

### 3. 환경 변수 설정
```bash
# AWS 환경 변수
export AWS_DEFAULT_REGION="ap-northeast-2"
export AWS_PROFILE="default"

# GCP 환경 변수
export GOOGLE_CLOUD_PROJECT="your-project-id"
export GOOGLE_APPLICATION_CREDENTIALS="path/to/service-account.json"
```

## 🧪 테스트 방법

### 1. 환경 체크
```bash
# 환경 체크만 실행
./cloud-basic-helper.sh
# 메뉴에서 "1. 종합 환경 체크" 선택
```

### 2. Dry-run 테스트
```bash
# 자동화 테스트 실행
./cloud-basic-helper.sh
# 메뉴에서 "10. 자동화 테스트 실행" 선택
```

### 3. 실제 실습
```bash
# Day 1 실습 실행
./cloud-basic-helper.sh
# 메뉴에서 "2-5. Day 1 실습" 선택

# Day 2 실습 실행
./cloud-basic-helper.sh
# 메뉴에서 "6-9. Day 2 실습" 선택
```

## 🚨 주의사항

### 1. 비용 관리
- AWS/GCP 인스턴스 생성 시 비용이 발생합니다
- 실습 완료 후 반드시 리소스를 정리하세요
- Helper 스크립트의 "리소스 정리" 기능을 활용하세요

### 2. 권한 설정
- AWS IAM 사용자에게 EC2, S3, IAM 권한이 필요합니다
- GCP 프로젝트에서 Compute Engine, Cloud Storage API가 활성화되어야 합니다

### 3. 네트워크 설정
- 보안 그룹에서 SSH/HTTP 트래픽을 허용해야 합니다
- 방화벽 규칙에서 필요한 포트를 열어야 합니다

## 📊 개선 효과

### Before ["기존 방식"]
- ❌ 개별 스크립트 분산 실행
- ❌ 환경 체크 수동 확인
- ❌ 오류 처리 부족
- ❌ 진행 상태 불명확

### After ["개선된 방식"]
- ✅ 통합된 Helper 스크립트
- ✅ 자동 환경 체크
- ✅ Interactive 메뉴 시스템
- ✅ 단계별 검증 및 복구
- ✅ 상세한 진행 상태 표시
- ✅ 사용자 친화적 오류 메시지
- ✅ 자동화 테스트 시스템 통합

## 🔄 업데이트 이력

- **2025-01-25**: 통합 Helper 스크립트 생성
- **2025-01-25**: Interactive 메뉴 시스템 도입
- **2025-01-25**: 자동화 테스트 시스템 통합
- **2025-01-25**: 리소스 관리 기능 추가
- **2025-01-25**: 환경 체크 및 검증 로직 강화
- **2025-01-26**: 고도화된 Advanced Helper 스크립트 추가
- **2025-01-26**: 비용 분석 및 최적화 기능 추가
- **2025-01-26**: 리소스 모니터링 기능 강화

## 📞 지원

문제가 발생하거나 개선 사항이 있으면 이슈를 등록해 주세요.

---

**Cloud Basic 실습을 즐겁게 진행하세요! 🚀**
