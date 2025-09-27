# ☁️ 클라우드 중급 과정 실습 환경 구성 가이드

클라우드 중급 과정을 위한 실습 환경 구성 스크립트 모음입니다. Docker, Kubernetes, AWS ECS, GCP Cloud Run, CI/CD 파이프라인, 멀티 클라우드 모니터링 등 모든 실습을 위한 환경을 자동으로 구성합니다.

## 📁 스크립트 구조

```
repo/setup/
├── README.md                    # 이 파일
├── QUICK_START.md              # 빠른 시작 가이드
├── wsl-setup-guide.md          # WSL 설치 가이드
├── install-all-wsl.sh          # 전체 도구 설치 스크립트
├── environment-check-wsl.sh    # 환경 체크 스크립트
├── aws-setup-helper.sh         # AWS 설정 도우미
├── gcp-setup-helper.sh         # GCP 설정 도우미
├── aws-ec2-create.sh          # AWS EC2 인스턴스 생성
├── gcp-compute-create.sh       # GCP Compute 인스턴스 생성
├── install-aws-cli-wsl.sh      # AWS CLI 설치
├── install-gcp-cli-wsl.sh      # GCP CLI 설치
├── install-docker-wsl.sh       # Docker 설치
└── setup-wsl-environment.sh    # WSL 환경 설정
```

## 🚀 빠른 시작

### 1. 실습 환경 확인
```bash
# WSL 버전 확인
wsl --version

# WSL이 설치되지 않은 경우
wsl --install
```

### 2. 전체 환경 설정 (권장)
```bash
# 모든 도구를 한 번에 설치
./install-all-wsl.sh
```

### 3. 환경 체크
```bash
# 설치된 도구들 확인
./environment-check-wsl.sh
```

## 📋 개별 스크립트 사용법

### 🔧 도구 설치 스크립트

#### `install-all-wsl.sh` - 전체 도구 설치
```bash
./install-all-wsl.sh
```
**기능:**
- AWS CLI 설치 및 설정
- GCP CLI 설치 및 설정
- Docker 및 Docker Compose 설치
- kubectl 설치
- GitHub CLI 설치
- 필수 패키지 설치

#### `install-aws-cli-wsl.sh` - AWS CLI 설치
```bash
./install-aws-cli-wsl.sh
```
**기능:**
- AWS CLI v2 설치
- 자동 설정 가이드 제공
- AWS ECS, EKS 관련 도구 설치

#### `install-gcp-cli-wsl.sh` - GCP CLI 설치
```bash
./install-gcp-cli-wsl.sh
```
**기능:**
- Google Cloud SDK 설치
- 자동 설정 가이드 제공
- GCP Cloud Run, GKE 관련 도구 설치

#### `install-docker-wsl.sh` - Docker 설치
```bash
./install-docker-wsl.sh
```
**기능:**
- Docker Engine 설치
- Docker Compose 설치
- 사용자 권한 설정
- Docker Desktop 연동

### 🔍 환경 체크 스크립트

#### `environment-check-wsl.sh` - 환경 체크
```bash
./environment-check-wsl.sh
```
**기능:**
- 설치된 도구 버전 확인
- 계정 설정 상태 확인
- 권한 설정 확인
- 클라우드 연결 상태 확인

### ☁️ 클라우드 설정 도우미

#### `aws-setup-helper.sh` - AWS 설정 도우미
```bash
./aws-setup-helper.sh
```
**기능:**
- AWS 계정 설정
- IAM 사용자 생성 가이드
- ECS, EKS 권한 설정
- 환경 변수 설정
- 리전 설정

#### `gcp-setup-helper.sh` - GCP 설정 도우미
```bash
./gcp-setup-helper.sh
```
**기능:**
- GCP 프로젝트 설정
- 서비스 계정 생성 가이드
- Cloud Run, GKE 권한 설정
- 환경 변수 설정
- API 활성화

### 🖥️ 인스턴스 생성 스크립트

#### `aws-ec2-create.sh` - AWS EC2 인스턴스 생성
```bash
./aws-ec2-create.sh
```
**기능:**
- EC2 인스턴스 생성 (모니터링 허브용)
- 보안 그룹 설정
- 키 페어 생성
- 인스턴스 정보 출력

#### `gcp-compute-create.sh` - GCP Compute 인스턴스 생성
```bash
./gcp-compute-create.sh
```
**기능:**
- Compute Engine 인스턴스 생성
- 방화벽 규칙 설정
- SSH 키 설정
- 인스턴스 정보 출력

## 📖 상세 가이드

### 클라우드 중급 과정 실습 환경

#### 1단계: WSL 환경 준비
```bash
# WSL 업데이트
wsl --update

# Ubuntu 배포판 설치 (권장)
wsl --install -d Ubuntu
```

#### 2단계: 기본 도구 설치
```bash
# 패키지 업데이트
sudo apt update && sudo apt upgrade -y

# 필수 도구 설치
sudo apt install -y curl wget git jq unzip
```

#### 3단계: 클라우드 도구 설치
```bash
# AWS CLI 설치
./install-aws-cli-wsl.sh

# GCP CLI 설치
./install-gcp-cli-wsl.sh

# Docker 설치
./install-docker-wsl.sh
```

#### 4단계: 계정 설정
```bash
# AWS 계정 설정
./aws-setup-helper.sh

# GCP 계정 설정
./gcp-setup-helper.sh
```

#### 5단계: 환경 확인
```bash
# 전체 환경 체크
./environment-check-wsl.sh
```

## 🔧 문제 해결

### 일반적인 문제들

#### 1. WSL 설치 오류
```bash
# Windows 기능 활성화
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart

# 재부팅 후
wsl --install
```

#### 2. Docker 권한 오류
```bash
# 사용자를 docker 그룹에 추가
sudo usermod -aG docker $USER

# WSL 재시작
exit
# Windows에서 wsl --shutdown 후 다시 시작
```

#### 3. AWS CLI 설정 오류
```bash
# AWS CLI 재설치
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo aws/install
```

#### 4. GCP CLI 인증 오류
```bash
# GCP CLI 재인증
gcloud auth login
gcloud auth application-default login
```

#### 5. kubectl 연결 오류
```bash
# kubectl 설정 확인
kubectl config current-context

# AWS EKS 클러스터 연결
aws eks update-kubeconfig --name cluster-name --region region

# GCP GKE 클러스터 연결
gcloud container clusters get-credentials cluster-name --zone zone
```

## 📊 환경 요구사항

### 최소 요구사항
- **OS**: Windows 10 (버전 2004 이상) 또는 Windows 11
- **RAM**: 8GB 이상
- **저장공간**: 20GB 이상 여유 공간
- **네트워크**: 인터넷 연결 필요

### 권장 사양
- **OS**: Windows 11
- **RAM**: 16GB 이상
- **저장공간**: 50GB 이상 여유 공간
- **CPU**: 8코어 이상

## 🎯 실습 준비 체크리스트

### 설치 확인
- [ ] WSL 2 설치됨
- [ ] Ubuntu 배포판 설치됨
- [ ] AWS CLI 설치 및 설정됨
- [ ] GCP CLI 설치 및 설정됨
- [ ] Docker 설치 및 실행됨
- [ ] kubectl 설치 및 설정됨
- [ ] GitHub CLI 설치 및 설정됨

### 계정 설정
- [ ] AWS 계정 생성 및 IAM 사용자 설정
- [ ] GCP 프로젝트 생성 및 서비스 계정 설정
- [ ] GitHub 계정 설정
- [ ] Docker Hub 계정 설정 (선택사항)

### 환경 변수
- [ ] AWS_ACCESS_KEY_ID 설정
- [ ] AWS_SECRET_ACCESS_KEY 설정
- [ ] AWS_DEFAULT_REGION 설정
- [ ] GOOGLE_APPLICATION_CREDENTIALS 설정

## 🚨 주의사항

### 보안
- AWS/GCP 자격 증명을 안전하게 보관하세요
- 공개 저장소에 자격 증명을 업로드하지 마세요
- 정기적으로 액세스 키를 교체하세요

### 비용 관리
- AWS/GCP 무료 티어 한도를 확인하세요
- 실습 후 리소스를 정리하세요
- 비용 알림을 설정하세요

### 백업
- 중요한 설정 파일을 백업하세요
- SSH 키를 안전한 곳에 보관하세요

## 📞 지원

### 문제 신고
- GitHub Issues를 통해 문제를 신고하세요
- 상세한 오류 메시지와 환경 정보를 포함하세요

### 커뮤니티
- Cloud Intermediate 과정 참여자들과 정보를 공유하세요
- 질문과 답변을 통해 함께 성장하세요

---

**클라우드 중급 과정 실습 환경 구성을 성공적으로 완료하세요! 🚀**