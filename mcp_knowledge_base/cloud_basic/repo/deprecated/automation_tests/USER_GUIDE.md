# Basic 과정 자동화 - 빠른 시작 가이드


## 🚀 빠른 시작

### 1단계: 환경 준비

```bash
# AWS CLI 설치 및 설정
aws configure

# GCP CLI 설치 및 설정
gcloud auth login
gcloud config set project YOUR_PROJECT_ID
```

### 2단계: 자동화 실행

```bash
# Basic 과정 자동화 실행
python basic_course_automation.py
```

### 3단계: 실습 스크립트 실행

```bash
# Day 1 실습
cd ./automation/day1
chmod +x *.sh
./cloud_basics.sh
./iam_basics.sh
./vm_services.sh
./storage_services.sh

# Day 2 실습
cd ../day2
chmod +x *.sh
./networking_basics.sh
./security_basics.sh
./database_services.sh
./comprehensive_practice.sh
```

## 📋 체크리스트

- [ ] AWS CLI 설치 및 설정
- [ ] GCP CLI 설치 및 설정
- [ ] Python 3.8+ 설치
- [ ] 자동화 스크립트 실행
- [ ] Day 1 실습 완료
- [ ] Day 2 실습 완료
- [ ] 생성된 리소스 정리

## 🔧 필수 설정

### AWS 설정

```bash
# AWS 계정 정보 설정
aws configure
# AWS Access Key ID: YOUR_ACCESS_KEY
# AWS Secret Access Key: YOUR_SECRET_KEY
# Default region name: us-west-2
# Default output format: json
```

### GCP 설정

```bash
# GCP 프로젝트 설정
export PROJECT_ID=your-project-id
gcloud config set project $PROJECT_ID

# 서비스 계정 키 설정 ["선택사항"]
export GOOGLE_APPLICATION_CREDENTIALS=path/to/service-account-key.json
```

## ⚡ 빠른 명령어

```bash
# 전체 과정 자동화
python basic_course_automation.py

# 테스트 실행
python run_basic_course_tests.py

# 로그 확인
tail -f basic_course_automation.log

# 생성된 스크립트 확인
ls -la ./automation/day1/
ls -la ./automation/day2/
```

## 🆘 도움이 필요하신가요?

- **상세 문서**: (README.md)(README.md)
- **문제 해결**: 로그 파일 확인
- **지원 요청**: GitHub Issues


---


---



<div align="center">

["← 이전: Cloud Basic 메인"](README.md) | ["📚 전체 커리큘럼"](curriculum.md) | ["🏠 학습 경로로 돌아가기"](index.md) | ["📋 학습 경로"](learning-path.md)

</div>