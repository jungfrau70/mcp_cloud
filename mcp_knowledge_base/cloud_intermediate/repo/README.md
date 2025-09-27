# 📁 클라우드 중급 과정 통합 저장소 (Repository)

이 디렉토리는 클라우드 중급 과정의 모든 실습 코드, 자동화 스크립트 및 환경 설정 파일을 포함하는 통합 저장소입니다. 체계적인 구조를 통해 학습자들이 효율적으로 실습을 진행하고, 필요한 자료를 쉽게 찾을 수 있도록 구성되었습니다.

## 🎯 저장소 구조

```
repo/
├── README.md              # 이 파일
├── setup/                 # 실습 환경 설정 스크립트 및 가이드
│   ├── README.md          # 환경 설정 상세 가이드
│   ├── QUICK_START.md     # 빠른 시작 가이드
│   ├── install-all-wsl.sh # WSL 환경 전체 도구 설치
│   ├── environment-check-wsl.sh # 환경 체크 스크립트
│   └── ...                # 기타 환경 설정 스크립트
├── automation/            # 실습 자동화 및 통합 관리 스크립트
│   ├── day1/              # Day1 실습 자동화
│   │   └── day1-practice.sh
│   ├── day2/              # Day2 실습 자동화
│   │   └── day2-practice.sh
│   ├── monitoring/        # 모니터링 스택 관리
│   │   └── monitoring-stack.sh
│   ├── testing/           # 테스트 자동화
│   │   ├── test-*.sh
│   │   └── run-all-tests.sh
│   ├── cloud-intermediate-helper.sh    # 통합 헬퍼
│   └── cloud-intermediate-advanced.sh  # 고급 헬퍼
├── tools/                 # 특정 기능별 헬퍼 도구
│   ├── git/               # Git 관련 도구
│   │   ├── git-push-on-linux.sh
│   │   └── git-push-on-gitbash.sh
│   ├── cloud/             # 클라우드 리소스 관리 도구
│   │   ├── aws-*.sh
│   │   ├── gcp-*.sh
│   │   └── *.env
│   └── monitoring/        # 모니터링 관리 도구
│       ├── lecture-monitor.sh
│       ├── resource-manager.sh
│       ├── cleanup-resources.sh
│       └── error-recovery.sh
├── examples/              # 실습용 샘플 코드 및 매니페스트
│   ├── day1/              # Day1 실습 예제
│   │   ├── docker-advanced/
│   │   ├── kubernetes-basics/
│   │   └── cloud-container-services/
│   ├── day2/              # Day2 실습 예제
│   │   ├── cicd-pipeline/
│   │   ├── cloud-deployment/
│   │   └── monitoring-basics/
│   └── monitoring/        # 모니터링 예제
└── archive/              # 레거시 코드 보관
    └── monitoring-stack/ # 사용하지 않는 모니터링 스택
```

## 🚀 주요 디렉토리 설명

### 1. `setup/` - 환경 설정
- **목적**: 클라우드 중급 과정 실습을 위한 개발 환경 (WSL, AWS, GCP CLI, Docker 등)을 설정하는 스크립트와 가이드를 제공합니다.
- **주요 파일**:
  - `README.md`: 환경 설정에 대한 상세한 설명과 단계별 가이드
  - `QUICK_START.md`: 빠르고 간편하게 환경을 설정할 수 있는 요약 가이드
  - `install-all-wsl.sh`: WSL 환경에서 필요한 모든 도구를 한 번에 설치하는 스크립트
  - `environment-check-wsl.sh`: 환경 설정이 올바르게 되었는지 확인하는 스크립트

### 2. `automation/` - 자동화 스크립트
- **목적**: Day1 및 Day2 실습을 자동화하고, 클라우드 리소스 관리 및 모니터링 스택을 제어하는 통합 관리 스크립트들을 포함합니다.
- **주요 스크립트**:
  - `day1/day1-practice.sh`: Day1의 모든 실습 또는 개별 실습을 자동화하여 실행합니다.
  - `day2/day2-practice.sh`: Day2의 모든 실습 또는 개별 실습을 자동화하여 실행합니다.
  - `monitoring/monitoring-stack.sh`: Prometheus, Grafana 등 모니터링 스택의 설정, 상태 확인, 정리 등을 자동화합니다.
  - `testing/`: 모든 테스트를 자동화하여 실행하고 결과를 분석합니다.
  - `cloud-intermediate-helper.sh`: 통합 환경 체크 및 특정 실습을 위한 헬퍼 기능 제공
  - `cloud-intermediate-advanced.sh`: 고급 사용자를 위한 고급 기능 제공

### 3. `tools/` - 유틸리티 도구
- **목적**: 특정 기능별로 분류된 헬퍼 도구들을 제공합니다.
- **주요 도구**:
  - `git/`: Git 관련 작업을 자동화하는 도구 (Linux, GitBash 지원)
  - `cloud/`: AWS, GCP 클라우드 리소스 관리 및 설정 도구
  - `monitoring/`: 모니터링 시스템 관리, 리소스 정리, 오류 복구 도구

### 4. `examples/` - 실습 예제
- **목적**: 각 실습 주제별로 필요한 애플리케이션 코드, Dockerfile, Kubernetes 매니페스트, CI/CD 워크플로우 파일 등 샘플 코드를 제공합니다.
- **구조**: `day1/`, `day2/`, `monitoring/` 하위에 각 교시별 실습 디렉토리가 구성되어 있습니다.
  - `day1/docker-advanced/`: Docker 고급 활용 실습 코드
  - `day1/kubernetes-basics/`: Kubernetes 기초 실습 매니페스트
  - `day1/cloud-container-services/`: AWS ECS 및 GCP Cloud Run 배포 샘플
  - `day2/cicd-pipeline/`: GitHub Actions CI/CD 워크플로우 및 애플리케이션 코드
  - `day2/cloud-deployment/`: AWS ECS 및 GCP Cloud Run 고급 배포 샘플
  - `day2/monitoring-basics/`: 멀티 클라우드 모니터링 설정 파일 및 애플리케이션

### 5. `archive/` - 아카이브
- **목적**: 더 이상 사용하지 않는 레거시 코드나 deprecated된 기능들을 보관합니다.
- **내용**: 이전 버전의 모니터링 스택, 사용하지 않는 스크립트 등

## 💡 활용 가이드

### 🎯 사용자별 접근 경로

#### **초보자 (환경 설정 → 실습 → 자동화)**
1. **환경 설정**: `setup/` 디렉토리의 `QUICK_START.md` 또는 `README.md`를 참조하여 실습 환경을 설정합니다.
2. **실습 진행**: `examples/` 디렉토리에서 각 실습에 필요한 코드를 확인하고 수동으로 실습을 진행합니다.
3. **자동화 활용**: 기본기를 익힌 후 `automation/` 디렉토리의 스크립트를 사용하여 자동화된 실습을 진행합니다.

#### **중급자 (자동화 → 도구 → 예제)**
1. **자동화 실행**: `automation/` 디렉토리의 `day1-practice.sh` 또는 `day2-practice.sh` 스크립트를 사용하여 각 실습을 자동화하여 진행합니다.
2. **도구 활용**: `tools/` 디렉토리의 개별 도구들을 사용하여 특정 작업을 효율적으로 수행합니다.
3. **예제 참조**: `examples/` 디렉토리에서 고급 예제를 참조하여 심화 학습을 진행합니다.

#### **고급자 (도구 → 자동화 → 아카이브)**
1. **도구 활용**: `tools/` 디렉토리의 고급 도구들을 사용하여 복잡한 작업을 수행합니다.
2. **자동화 커스터마이징**: `automation/` 디렉토리의 스크립트를 수정하여 자신만의 자동화 프로세스를 구축합니다.
3. **레거시 참조**: `archive/` 디렉토리에서 이전 버전의 구현을 참조하여 호환성 문제를 해결합니다.

### 🔄 실습 진행 워크플로우

#### **1단계: 환경 설정**
```bash
# 환경 설정
cd setup/
./install-all-wsl.sh
./environment-check-wsl.sh
```

#### **2단계: 실습 진행**
```bash
# Day1 실습 (자동화)
cd automation/day1/
./day1-practice.sh

# Day2 실습 (자동화)
cd automation/day2/
./day2-practice.sh
```

#### **3단계: 모니터링 설정**
```bash
# 모니터링 스택 설정
cd automation/monitoring/
./monitoring-stack.sh
```

#### **4단계: 정리**
```bash
# 리소스 정리
cd tools/monitoring/
./cleanup-resources.sh
```

## 🛠️ 주요 스크립트 사용법

### **환경 설정 스크립트**
```bash
# 전체 환경 설정 (WSL)
cd setup/
./install-all-wsl.sh

# 환경 체크
./environment-check-wsl.sh
```

### **실습 자동화 스크립트**
```bash
# Day1 전체 실습
cd automation/day1/
./day1-practice.sh

# Day2 전체 실습
cd automation/day2/
./day2-practice.sh

# 모니터링 스택 관리
cd automation/monitoring/
./monitoring-stack.sh
```

### **개별 도구 사용**
```bash
# Git 도구
cd tools/git/
./git-push-on-linux.sh

# 클라우드 도구
cd tools/cloud/
./aws-setup-helper.sh
./gcp-setup-helper.sh

# 모니터링 도구
cd tools/monitoring/
./lecture-monitor.sh
```

## 📊 디렉토리별 성격 요약

| 디렉토리 | 성격 | 주요 기능 | 대상 사용자 |
|---------|------|-----------|------------|
| `setup/` | 환경 설정 | 도구 설치, 환경 구성 | 모든 사용자 |
| `automation/` | 자동화 | 실습 자동화, 통합 관리 | 교육자, 고급 학습자 |
| `tools/` | 유틸리티 | 특정 기능 도구 | 개발자, 시스템 관리자 |
| `examples/` | 실습 자료 | 샘플 코드, 매니페스트 | 모든 학습자 |
| `archive/` | 레거시 보관 | 사용하지 않는 코드 | 참고용 |

## 🚨 주의사항

### **보안**
- AWS/GCP 자격 증명을 안전하게 보관하세요
- 공개 저장소에 자격 증명을 업로드하지 마세요
- 정기적으로 액세스 키를 교체하세요

### **비용 관리**
- AWS/GCP 무료 티어 한도를 확인하세요
- 실습 후 리소스를 정리하세요
- 비용 알림을 설정하세요

### **백업**
- 중요한 설정 파일을 백업하세요
- SSH 키를 안전한 곳에 보관하세요

## 📞 지원

### **문제 신고**
- GitHub Issues를 통해 문제를 신고하세요
- 상세한 오류 메시지와 환경 정보를 포함하세요

### **커뮤니티**
- Cloud Intermediate 과정 참여자들과 정보를 공유하세요
- 질문과 답변을 통해 함께 성장하세요

---

**Cloud Intermediate 과정을 통해 현대적인 클라우드 네이티브 개발 역량을 완성하세요! 🚀**