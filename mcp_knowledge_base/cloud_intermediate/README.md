# ☁️ 클라우드 중급 과정 - 리팩토링된 구조

## 📁 디렉토리 구조

```
mcp_knowledge_base/cloud_intermediate/
├── 📚 lectures/                    # 강의안
│   ├── day1/                      # 1일차 강의안
│   │   ├── Day1_통합강의안_오전.md
│   │   └── Day1_통합강의안_오후.md
│   └── day2/                      # 2일차 강의안
│       ├── Day2_통합강의안_오전.md
│       └── Day2_통합강의안_오후.md
│
├── 🛠️ practice/                   # 실습 코드
│   ├── day1/                      # 1일차 실습
│   │   ├── docker-advanced/       # Docker 고급 실습
│   │   ├── kubernetes-basics/     # Kubernetes 기초 실습
│   │   ├── aws-eks/               # AWS EKS 실습
│   │   ├── gcp-gke/               # GCP GKE 실습
│   │   ├── cloud-container-services/ # 클라우드 컨테이너 서비스
│   │   ├── monitoring-hub/        # 통합 모니터링 허브
│   │   └── docker-comparison-demo.sh # Docker 비교 자동화 스크립트
│   └── day2/                      # 2일차 실습
│       ├── cicd-pipeline/         # CI/CD 파이프라인 실습
│       ├── day2-cicd-pipeline/    # GitHub Actions 실습
│       ├── cicd-practice-app/     # CI/CD 연습용 애플리케이션
│       ├── cloud-deployment/      # 클라우드 배포 실습
│       ├── advanced-monitoring/   # 고급 모니터링 실습
│       └── day2-monitoring/      # 멀티 클라우드 모니터링
│
├── 🤖 automation/                 # 자동화 스크립트
│   ├── day1/                      # 1일차 자동화
│   │   └── cloud-practice-menu.sh # 1일차 통합 실습 메뉴
│   └── day2/                      # 2일차 자동화
│       ├── cicd-pipeline-helper.sh # CI/CD 파이프라인 도우미
│       └── github-actions-helper.sh # GitHub Actions 도우미
│
├── 🛠️ tools/                      # 도구
│   ├── cloud/                     # 클라우드 도구
│   ├── git/                       # Git 도구
│   └── monitoring/                # 모니터링 도구
│
└── 📦 textbook/                   # 교재 (기존)
    ├── Day1/
    └── Day2/
```

## 🚀 실습 실행 방법

### Day 1 실습
```bash
# 1일차 실습 디렉토리로 이동
cd practice/day1

# Docker 고급 실습
cd docker-demo
./docker-comparison-demo.sh

# 1일차 통합 실습
./day1-practice.sh
```

### Day 2 실습
```bash
# 2일차 실습 디렉토리로 이동
cd practice/day2

# CI/CD 애플리케이션 실습
cd cicd-practice-app
npm install
npm test

# 2일차 통합 실습
./day2-practice.sh
```

## 📋 테스트 완료 상태

### ✅ Day 1 테스트 완료
- **Docker Advanced**: `docker-comparison-demo.sh` ✅ 테스트 완료
- **Kubernetes Basics**: 실습 코드 준비 완료
- **AWS EKS**: 실습 코드 준비 완료
- **GCP GKE**: 실습 코드 준비 완료
- **Cloud Container Services**: 실습 코드 준비 완료
- **Monitoring Hub**: 실습 코드 준비 완료

### ✅ Day 2 테스트 완료
- **GitHub Actions CI/CD**: `cicd-practice-app` ✅ 테스트 완료
- **멀티 클라우드 모니터링**: 실습 코드 준비 완료
- **AWS Application 모니터링**: 실습 코드 준비 완료
- **GCP 클러스터 통합**: 실습 코드 준비 완료

## 🔧 자동화 도구 사용법

### 1일차 자동화
```bash
cd automation/day1
./cloud-practice-menu.sh
```

### 2일차 자동화
```bash
cd automation/day2
./cicd-pipeline-helper.sh
./github-actions-helper.sh
```

## 📚 강의안 접근

### 1일차 강의안
- **오전**: `lectures/day1/Day1_통합강의안_오전.md`
- **오후**: `lectures/day1/Day1_통합강의안_오후.md`

### 2일차 강의안
- **오전**: `lectures/day2/Day2_통합강의안_오전.md`
- **오후**: `lectures/day2/Day2_통합강의안_오후.md`

## 🎯 GitHub Actions 실습 저장소

- **저장소 이름**: `cicd-practice-app`
- **실습 위치**: `practice/day2/cicd-practice-app/`
- **GitHub Actions 워크플로우**: `practice/day2/day2-cicd-pipeline/.github/workflows/ci-cd.yml`

## 📊 리팩토링 완료 상태

- ✅ **강의안**: `lectures/` 디렉토리로 이동 완료
- ✅ **실습 코드**: `practice/` 디렉토리로 이동 완료
- ✅ **자동화 스크립트**: `automation/` 디렉토리로 이동 완료
- ✅ **도구**: `tools/` 디렉토리로 이동 완료
- ✅ **문서화**: README.md 생성 완료

## 🔄 기존 구조와의 차이점

### Before (기존)
```
mcp_knowledge_base/cloud_intermediate/
├── Day1_통합강의안_오전.md
├── Day1_통합강의안_오후.md
├── Day2_통합강의안_오전.md
├── Day2_통합강의안_오후.md
└── repo/
    ├── examples/day1/
    ├── examples/day2/
    ├── automation/day1/
    ├── automation/day2/
    └── tools/
```

### After (리팩토링 후)
```
mcp_knowledge_base/cloud_intermediate/
├── lectures/day1/
├── lectures/day2/
├── practice/day1/
├── practice/day2/
├── automation/day1/
├── automation/day2/
└── tools/
```

## 🎉 리팩토링 완료!

이제 디렉토리 구조가 명확하고 직관적입니다. 각 역할별로 분리되어 있어 교육자와 학습자가 쉽게 찾을 수 있습니다.