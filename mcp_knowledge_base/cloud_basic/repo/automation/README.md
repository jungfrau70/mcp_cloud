## 🎯 학습 목표

### 핵심 학습 목표
- **Cloud Basic 기초** 클라우드 서비스 이해 및 활용
- **Cloud Basic 실무** 실제 프로젝트 적용 능력 향상

### 실습 후 달성할 수 있는 능력
- ✅ 클라우드 서비스 기본 개념 이해
- ✅ 실제 환경에서 서비스 배포 및 관리
- ✅ 문제 해결 및 최적화 능력

### 예상 소요 시간
- **기초 학습**: 90-120분
- **실습 진행**: 60-90분
- **전체 과정**: 3-4시간

Basic 과정의 실습 코드

```bash
cd C:/Users/JIH/githubs/mcp_cloud/./automation_tests && python basic_course_automation.py
```
Basic 과정 자동화가 성공적으로 완료되었습니다! 이제 생성된 파일들을 확인해보겠습니다.

Ran tool
좋습니다! Basic 과정의 스크립트들이 생성되었습니다. 이제 Basic 과정의 테스트를 실행해보겠습니다.

```bash
cd C:/Users/JIH/githubs/mcp_cloud/./automation_tests && python run_basic_course_tests.py
```
🎉 **완벽합니다!** Basic 과정의 모든 테스트가 성공적으로 통과했습니다!

## Basic 과정 실습 코드 수행 및 테스트 결과


### ✅ 테스트 결과
- **총 12개 테스트 모두 통과** ✅
- **단위 테스트**: 10개 통과
- **통합 테스트**: 2개 통과

### 📊 테스트 세부 결과

**1. BasicCourseAutomation 테스트 ["10개"]**
- ✅ 설정 초기화 테스트
- ✅ 환경 변수 설정 테스트
- ✅ 일일 계획 생성 테스트
- ✅ 클라우드 기초 스크립트 생성 테스트
- ✅ IAM 실습 스크립트 생성 테스트
- ✅ 가상머신 서비스 스크립트 생성 테스트
- ✅ 스토리지 서비스 스크립트 생성 테스트
- ✅ Day 1 스크립트 생성 테스트
- ✅ Day 2 스크립트 생성 테스트
- ✅ 결과 저장 테스트

**2. 통합 테스트 ["2개"]**
- ✅ 전체 자동화 성공 테스트
- ✅ 누락된 도구가 있는 경우 테스트

### �� 생성된 Basic 과정 파일들

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

### 🔧 Basic 과정 자동화 시스템 특징

1. **완전한 테스트 커버리지**: 12개의 포괄적인 테스트
2. **견고한 오류 처리**: 누락된 도구[gcloud-cli]가 있어도 계속 진행
3. **모듈화된 구조**: Day별로 분리된 스크립트 생성
4. **입문자 중심**: AWS/GCP 기초 서비스, IAM, VM, 스토리지, 네트워킹, 보안, 데이터베이스 중심

### ⚠️ 주의사항

**누락된 도구:**
- `gcloud-cli` [GCP CLI]

하지만 자동화 시스템이 부분적으로라도 계속 진행하도록 설계되어 있어서 성공적으로 완료되었습니다.

### Basic 과정 실습 스크립트 실행 방법

이제 생성된 실습 스크립트들을 실행할 수 있습니다:

```bash
# Day 1 실습 스크립트 실행
cd ./automation/day1
chmod +x *.sh
./cloud_basics.sh
./iam_basics.sh
./vm_services.sh
./storage_services.sh

# Day 2 실습 스크립트 실행
cd ../day2
chmod +x *.sh
./networking_basics.sh
./security_basics.sh
./database_services.sh
./comprehensive_practice.sh
```

### �� Basic 과정 실습 내용

**Day 1: AWS & GCP 기초 서비스 실습**
- 클라우드 개념 및 계정 생성
- IAM 기초 실습 ["사용자, 그룹, 역할, 정책"]
- 가상머신 서비스 기초 [EC2, Compute Engine]
- 스토리지 서비스 기초 [S3, Cloud Storage]

**Day 2: 네트워크, 보안 및 데이터베이스 실습**
- 네트워킹 기초 실습 ["VPC, 서브넷, 라우팅"]
- 보안 그룹 및 방화벽 실습
- 데이터베이스 서비스 기초 [RDS, Cloud SQL]
- 종합 실습 및 비교 분석

**Basic 과정 실습 코드 수행 및 테스트가 성공적으로 완료되었습니다!** 🚀

---


---



<div align="center">

["📚 전체 커리큘럼"][curriculum.md] | ["🏠 학습 경로로 돌아가기"][index.md] | ["📋 학습 경로"][learning-path.md]

</div>