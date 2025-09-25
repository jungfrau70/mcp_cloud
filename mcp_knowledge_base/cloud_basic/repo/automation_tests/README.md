# Basic 과정 자동화 시스템


## 📌 개요

Basic 과정 자동화 시스템은 AWS와 GCP의 기초 서비스를 학습하고 실습하는 교육 과정을 위한 자동화 도구입니다. 클라우드 입문자를 대상으로 한 2일 과정의 실습 스크립트를 자동으로 생성하고 관리합니다.

## 🎯 주요 기능

- **자동 스크립트 생성**: Day 1, Day 2 실습 스크립트 자동 생성
- **클라우드 서비스 실습**: AWS와 GCP 기초 서비스 실습
- **환경 설정 자동화**: 필요한 도구 및 환경 설정 자동화
- **테스트 시스템**: 단위 테스트 및 통합 테스트 제공

## 📚 과정 내용

### Day 1: AWS & GCP 기초 서비스 실습
- 클라우드 개념 및 계정 생성
- IAM 기초 실습
- 가상머신 서비스 기초
- 스토리지 서비스 기초

### Day 2: 네트워크, 보안 및 데이터베이스 실습
- 네트워킹 기초 실습
- 보안 그룹 및 방화벽 실습
- 데이터베이스 서비스 기초
- 종합 실습 및 비교 분석

## 🛠️ 필수 도구

- **AWS CLI**: AWS 서비스 관리
- **GCP CLI**: GCP 서비스 관리
- **Python 3.8+**: 자동화 스크립트 실행
- **Git**: 버전 관리

## 🚀 사용 방법

### 1. 환경 설정

```bash
# 필수 도구 설치 확인
aws --version
gcloud --version

# AWS 설정
aws configure

# GCP 설정
gcloud auth login
gcloud config set project YOUR_PROJECT_ID
```

### 2. 자동화 실행

```bash
# Basic 과정 자동화 실행
python basic_course_automation.py
```

### 3. 테스트 실행

```bash
# 단위 테스트 및 통합 테스트 실행
python run_basic_course_tests.py
```

## 📁 생성되는 파일 구조

```
./automation/
├── day1/                               # Day 1 실습 스크립트
│   ├── cloud_basics.sh                # 클라우드 기초 실습
│   ├── iam_basics.sh                  # IAM 기초 실습
│   ├── vm_services.sh                 # 가상머신 서비스 실습
│   └── storage_services.sh            # 스토리지 서비스 실습
├── day2/                               # Day 2 실습 스크립트
│   ├── networking_basics.sh           # 네트워킹 기초 실습
│   ├── security_basics.sh             # 보안 그룹 및 방화벽 실습
│   ├── database_services.sh           # 데이터베이스 서비스 실습
│   └── comprehensive_practice.sh      # 종합 실습
└── results/
    └── automation_results.json        # 자동화 결과
```

## 🔧 스크립트 실행 방법

### 개별 스크립트 실행

```bash
# Day 1 스크립트 실행
cd ./automation/day1
chmod +x *.sh
./cloud_basics.sh
./iam_basics.sh
./vm_services.sh
./storage_services.sh

# Day 2 스크립트 실행
cd ../day2
chmod +x *.sh
./networking_basics.sh
./security_basics.sh
./database_services.sh
./comprehensive_practice.sh
```

### 전체 과정 실행

```bash
# 모든 스크립트 순차 실행
for script in day1/*.sh day2/*.sh; do
    echo "실행 중: $script"
    bash "$script"
done
```

## ⚠️ 주의사항

1. **비용 관리**: AWS Free Tier와 GCP Free Tier 한도 내에서 실습
2. **리소스 정리**: 실습 완료 후 생성된 리소스 정리
3. **권한 설정**: 적절한 IAM 권한 설정
4. **보안**: 민감한 정보는 환경 변수로 관리

## 🐛 문제 해결

### 일반적인 문제

1. **AWS CLI 설정 오류**
   ```bash
   aws configure list
   aws configure
   ```

2. **GCP CLI 설정 오류**
   ```bash
   gcloud auth list
   gcloud auth login
   gcloud config set project YOUR_PROJECT_ID
   ```

3. **권한 오류**
   - AWS: IAM 사용자 권한 확인
   - GCP: 서비스 계정 권한 확인

### 로그 확인

```bash
# 자동화 로그 확인
tail -f basic_course_automation.log
```

## 📞 지원

- **문서**: [USER_GUIDE.md][USER_GUIDE.md]
- **이슈**: GitHub Issues
- **문의**: 프로젝트 관리자

## 📄 라이선스

이 프로젝트는 MIT 라이선스 하에 배포됩니다.


---


---



<div align="center">

["📚 전체 커리큘럼"][curriculum.md] | ["🏠 학습 경로로 돌아가기"][index.md] | ["📋 학습 경로"][learning-path.md]

</div>