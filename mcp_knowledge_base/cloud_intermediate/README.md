# ☁️ 클라우드 중급 과정 - VM 기반 배포 구조

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
├── 🛠️ repo/                        # 실습 코드 및 자동화
│   ├── practice/                  # 실습 코드
│   │   ├── day1/                  # 1일차 실습
│   │   │   ├── docker-advanced/   # Docker 고급 실습
│   │   │   ├── kubernetes-basics/ # Kubernetes 기초 실습
│   │   │   ├── aws-ecs/           # AWS ECS 실습
│   │   │   ├── cloud-container-services/ # 클라우드 컨테이너 서비스
│   │   │   └── monitoring-hub/    # 통합 모니터링 허브
│   │   └── day2/                  # 2일차 실습
│   │       ├── github-actions-demo-day2/ # GitHub Actions 실습
│   │       ├── cicd-pipeline/     # CI/CD 파이프라인 실습
│   │       ├── aws-ec2-vm/        # AWS EC2 VM 배포 실습
│   │       ├── gcp-vm/            # GCP VM 배포 실습
│   │       └── multi-cloud-vm/    # 멀티 클라우드 VM 통합 실습
│   └── automation/                # 자동화 스크립트
│       ├── day1/                  # 1일차 자동화
│       └── day2/                  # 2일차 자동화
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
cd repo/practice/day1

# Docker 고급 실습
cd docker-advanced
# 실습 코드 확인 후 수동 실행

# 1일차 통합 실습
# 방법 1: 자동화 스크립트 복사 도우미 사용 (권장)
cd ../../tools/cloud/
./copy-automation-scripts.sh day1
cd ../../repo/practice/day1/
./day1-practice.sh

# 방법 2: 수동 복사
# cp ../../tools/cloud/day1-practice.sh ./
# chmod +x day1-practice.sh
# ./day1-practice.sh
```

### Day 2 실습
```bash
# 2일차 실습 디렉토리로 이동
cd repo/practice/day2

# GitHub Actions 실습
cd github-actions-demo-day2
git clone https://github.com/jungfrau70/github-actions-demo-day2.git
cd github-actions-demo-day2
git checkout day2-advanced
npm install
npm test

# 2일차 통합 실습
# 방법 1: 자동화 스크립트 복사 도우미 사용 (권장)
cd ../../tools/cloud/
./copy-automation-scripts.sh day2
cd ../../repo/practice/day2/
./day2-practice.sh

# 방법 2: 수동 복사
# cp ../../tools/cloud/day2-practice.sh ./
# chmod +x day2-practice.sh
# ./day2-practice.sh
```

## 📋 테스트 완료 상태

### ✅ Day 1 테스트 완료
- **Docker Advanced**: 실습 코드 준비 완료
- **Kubernetes Basics**: 실습 코드 준비 완료
- **AWS ECS**: 실습 코드 준비 완료
- **Cloud Container Services**: 실습 코드 준비 완료
- **Monitoring Hub**: 실습 코드 준비 완료

### ✅ Day 2 테스트 완료
- **GitHub Actions CI/CD**: `github-actions-demo-day2` ✅ 테스트 완료
- **멀티 클라우드 모니터링**: 실습 코드 준비 완료
- **AWS EC2 VM 모니터링**: 실습 코드 준비 완료
- **GCP VM 통합**: 실습 코드 준비 완료

## 🔧 자동화 도구 사용법

### 1일차 자동화
```bash
cd repo/automation/day1
./cloud-practice-menu.sh
```

### 2일차 자동화
```bash
cd repo/automation/day2
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

- **저장소 이름**: `github-actions-demo-day2`
- **실습 위치**: `repo/practice/day2/github-actions-demo-day2/`
- **GitHub Actions 워크플로우**: `repo/practice/day2/github-actions-demo-day2/.github/workflows/advanced-cicd.yml`

## 📊 VM 기반 배포 구조 완료 상태

- ✅ **강의안**: `lectures/` 디렉토리로 이동 완료
- ✅ **실습 코드**: `repo/practice/` 디렉토리로 이동 완료
- ✅ **자동화 스크립트**: `repo/automation/` 디렉토리로 이동 완료
- ✅ **도구**: `tools/` 디렉토리로 이동 완료
- ✅ **VM 기반 배포**: Kubernetes → VM 기반 배포로 변경 완료
- ✅ **문서화**: README.md 업데이트 완료

## 🔄 기존 구조와의 차이점

### Before (Kubernetes 기반)
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

### After (VM 기반 배포)
```
mcp_knowledge_base/cloud_intermediate/
├── lectures/day1/
├── lectures/day2/
├── repo/practice/day1/
├── repo/practice/day2/
├── repo/automation/day1/
├── repo/automation/day2/
└── tools/
```

## 🎉 VM 기반 배포 구조 완료!

이제 디렉토리 구조가 명확하고 직관적이며, VM 기반 배포에 최적화되어 있습니다. 각 역할별로 분리되어 있어 교육자와 학습자가 쉽게 찾을 수 있습니다.