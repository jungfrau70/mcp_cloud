# ☁️ 클라우드 중급 과정 실습 자료 저장소

클라우드 중급 과정의 모든 실습 자료, 자동화 스크립트, 샘플 코드를 포함한 통합 저장소입니다.

## 📁 디렉토리 구조

```
repo/
├── README.md                    # 이 파일
├── setup/                       # 실습 환경 설정
│   ├── README.md               # 환경 설정 가이드
│   ├── QUICK_START.md          # 빠른 시작 가이드
│   ├── install-all-wsl.sh      # 전체 도구 설치
│   ├── environment-check-wsl.sh # 환경 체크
│   ├── aws-setup-helper.sh     # AWS 설정 도우미
│   ├── gcp-setup-helper.sh     # GCP 설정 도우미
│   ├── aws-ec2-create.sh       # AWS EC2 생성
│   └── gcp-compute-create.sh   # GCP Compute 생성
├── scripts/                     # 자동화 스크립트
│   ├── day1-practice.sh        # Day1 실습 자동화
│   ├── day2-practice.sh        # Day2 실습 자동화
│   ├── monitoring-stack.sh     # 모니터링 스택 자동화
│   ├── cloud-intermediate-helper.sh # 통합 헬퍼
│   └── cleanup-resources.sh    # 리소스 정리
├── samples/                     # 실습 샘플 코드
│   ├── day1/                   # Day1 실습 샘플
│   │   ├── docker-advanced/    # Docker 고급 실습
│   │   ├── kubernetes-basics/  # Kubernetes 기초
│   │   ├── cloud-container-services/ # 클라우드 컨테이너 서비스
│   │   └── monitoring-hub/     # 통합 모니터링 허브
│   └── day2/                   # Day2 실습 샘플
│       ├── cicd-pipeline/      # CI/CD 파이프라인
│       ├── cloud-deployment/   # 클라우드 배포
│       └── monitoring-basics/  # 멀티 클라우드 모니터링
├── git-push-on-linux.sh        # Git 푸시 스크립트
└── git-push-on-gitbash.sh      # Git Bash 푸시 스크립트
```

## 🚀 빠른 시작

### 1. 실습 환경 설정
```bash
# setup 디렉토리로 이동
cd repo/setup

# 전체 환경 설정 실행
./install-all-wsl.sh

# 환경 체크
./environment-check-wsl.sh
```

### 2. Day1 실습 시작
```bash
# scripts 디렉토리로 이동
cd ../scripts

# Day1 전체 실습 실행
./day1-practice.sh

# 개별 실습 실행
./day1-practice.sh docker-advanced
./day1-practice.sh kubernetes-basics
./day1-practice.sh cloud-container-services
./day1-practice.sh monitoring-hub
```

### 3. Day2 실습 시작
```bash
# Day2 전체 실습 실행
./day2-practice.sh

# 개별 실습 실행
./day2-practice.sh cicd-pipeline
./day2-practice.sh cloud-deployment
./day2-practice.sh monitoring-basics
```

## 📋 주요 스크립트

### 🔧 실습 자동화 스크립트

#### `day1-practice.sh` - Day1 실습 자동화
```bash
./day1-practice.sh
```
**기능:**
- Docker 고급 활용 실습
- Kubernetes 기초 실습
- 클라우드 컨테이너 서비스 실습
- 통합 모니터링 허브 구축

#### `day2-practice.sh` - Day2 실습 자동화
```bash
./day2-practice.sh
```
**기능:**
- CI/CD 파이프라인 구축
- 멀티 클라우드 통합 모니터링
- AWS Application 모니터링
- GCP 클러스터 통합 모니터링

### 🔍 모니터링 스크립트

#### `monitoring-stack.sh` - 모니터링 스택 자동화
```bash
./monitoring-stack.sh setup
./monitoring-stack.sh status
./monitoring-stack.sh test
./monitoring-stack.sh cleanup
```

#### `cloud-intermediate-helper.sh` - 통합 헬퍼
```bash
./cloud-intermediate-helper.sh check-environment
./cloud-intermediate-helper.sh cicd-practice
./cloud-intermediate-helper.sh monitoring-practice
./cloud-intermediate-helper.sh cloud-deployment-practice
```

### 🧹 정리 스크립트

#### `cleanup-resources.sh` - 리소스 정리
```bash
./cleanup-resources.sh --all
./cleanup-resources.sh --aws
./cleanup-resources.sh --gcp
./cleanup-resources.sh --local
```

## 📚 실습 샘플 코드

### Day1 실습 샘플
- **docker-advanced/**: Docker 멀티스테이지 빌드, 이미지 최적화
- **kubernetes-basics/**: Pod, Service, Deployment, ConfigMap, Secret
- **cloud-container-services/**: AWS ECS, GCP Cloud Run
- **monitoring-hub/**: Prometheus + Grafana 통합 모니터링 허브

### Day2 실습 샘플
- **cicd-pipeline/**: GitHub Actions CI/CD 파이프라인
- **cloud-deployment/**: AWS ECS 고급 배포, GCP Cloud Run 고급 배포
- **monitoring-basics/**: 멀티 클라우드 통합 모니터링 시스템

## 🔧 환경 설정

### 필수 도구
- **Docker**: 컨테이너 런타임
- **kubectl**: Kubernetes 클러스터 관리
- **AWS CLI**: AWS 서비스 관리
- **GCP CLI**: GCP 서비스 관리
- **GitHub CLI**: GitHub Actions 관리

### 환경 변수 설정
```bash
# AWS 설정
export AWS_ACCESS_KEY_ID="your-access-key"
export AWS_SECRET_ACCESS_KEY="your-secret-key"
export AWS_DEFAULT_REGION="us-west-2"

# GCP 설정
export GOOGLE_APPLICATION_CREDENTIALS="path/to/service-account.json"
export GCP_PROJECT_ID="your-project-id"
```

## 🧪 테스트 및 검증

### 전체 테스트 실행
```bash
# 전체 실습 시나리오 테스트
./test-lecture-scenario.sh

# 100% 커버리지 테스트
./test-100-percent-coverage.sh

# 모니터링 스택 테스트
./test-monitoring-stack.sh
```

### 개별 테스트
```bash
# Day1 실습 테스트
./test-phase1-local.sh

# Day2 실습 테스트
./test-phase2-4-cloud.sh

# 리소스 처리 테스트
./test-resource-handling.sh
```

## 📊 실습 진행 모니터링

### 실시간 모니터링
```bash
# 강의 진행 대시보드
./lecture-monitor.sh --dashboard

# 현재 상태 확인
./lecture-monitor.sh --status

# 자동화 스크립트 모니터링
./lecture-monitor.sh --monitor
```

### 성과 측정
```bash
# 학습 성과 리포트 생성
./lecture-monitor.sh --report

# 실습 완료율 확인
./lecture-monitor.sh --completion-rate
```

## 🚨 문제 해결

### 일반적인 문제들

#### 1. 환경 설정 오류
```bash
# 환경 체크 실행
./environment-check-wsl.sh

# 문제점 진단 및 해결
./error-recovery.sh
```

#### 2. 클라우드 연결 오류
```bash
# AWS 연결 확인
aws sts get-caller-identity

# GCP 연결 확인
gcloud auth list

# kubectl 연결 확인
kubectl config current-context
```

#### 3. 리소스 정리
```bash
# 전체 리소스 정리
./cleanup-resources.sh --all

# 특정 클라우드 리소스 정리
./cleanup-resources.sh --aws
./cleanup-resources.sh --gcp
```

## 📞 지원

### 문제 신고
- GitHub Issues를 통해 문제를 신고하세요
- 상세한 오류 메시지와 환경 정보를 포함하세요

### 커뮤니티
- Cloud Intermediate 과정 참여자들과 정보를 공유하세요
- 질문과 답변을 통해 함께 성장하세요

---

**클라우드 중급 과정 실습을 성공적으로 완료하세요! 🚀**
