# MCP Cloud Master - WSL 환경 설치 가이드

WSL(Windows Subsystem for Linux) 환경에서 MCP Cloud Master 교육 과정에 필요한 모든 도구를 설치하는 가이드입니다.

## 🎯 주요 특징

- **자동화된 설치**: 모든 도구를 한 번에 설치
- **Windows 최적화**: WSL 환경에 특화된 설정
- **키 파일 권한 관리**: SSH 키 파일 자동 권한 설정 (400)
- **환경 검증**: 설치 후 자동 환경 검증
- **오류 복구**: 설치 실패 시 자동 재시도

## 📋 설치 스크립트 목록

### 1. 전체 설치 (권장)
```bash
# 모든 도구를 한 번에 설치
chmod +x install-all-wsl.sh
./install-all-wsl.sh
```

### 2. 환경 검증
```bash
# 설치된 환경 검증
chmod +x check-environment.sh
./check-environment.sh
```

### 3. 개별 설치

#### AWS CLI 설치
```bash
chmod +x install-aws-cli-wsl.sh
./install-aws-cli-wsl.sh
```

#### GCP CLI 설치
```bash
chmod +x install-gcp-cli-wsl.sh
./install-gcp-cli-wsl.sh
```

#### Docker 설치
```bash
chmod +x install-docker-wsl.sh
./install-docker-wsl.sh
```

#### Kubernetes 도구 설치
```bash
chmod +x install-k8s-tools-wsl.sh
./install-k8s-tools-wsl.sh
```

#### 개발 도구 설치
```bash
chmod +x install-dev-tools-wsl.sh
./install-dev-tools-wsl.sh
```

#### Git 및 GCP 도구 설치
```bash
chmod +x install_git_gcp.sh
./install_git_gcp.sh
```

## 🛠️ 설치되는 도구들

### 클라우드 도구
- **AWS CLI v2**: AWS 서비스 관리
- **GCP CLI**: Google Cloud Platform 서비스 관리
- **Terraform**: Infrastructure as Code
- **AWS Vault**: AWS 자격 증명 관리

### 컨테이너 도구
- **Docker**: 컨테이너 플랫폼
- **Docker Compose**: 다중 컨테이너 애플리케이션 관리
- **Podman**: Docker 대안 컨테이너 도구

### Kubernetes 도구
- **kubectl**: Kubernetes 클러스터 관리
- **Helm**: Kubernetes 패키지 관리자
- **k9s**: Kubernetes 클러스터 대화형 관리
- **kustomize**: Kubernetes 설정 관리
- **stern**: Kubernetes 로그 도구
- **kubectx/kubens**: 컨텍스트 및 네임스페이스 전환
- **kubectl-neat**: Kubernetes YAML 정리 도구

### 개발 도구
- **Node.js LTS**: JavaScript 런타임
- **Python 3**: Python 프로그래밍 언어
- **Go**: Go 프로그래밍 언어
- **Rust**: Rust 프로그래밍 언어
- **Git**: 버전 관리 시스템
- **VS Code Server**: 웹 기반 코드 에디터 (선택사항)
- **GitHub CLI**: GitHub 명령줄 도구

### 시스템 도구
- **curl, wget**: 파일 다운로드
- **jq**: JSON 처리
- **htop**: 시스템 모니터링
- **vim, nano**: 텍스트 에디터
- **tree**: 디렉토리 구조 표시
- **bat**: cat 명령어 개선 버전
- **exa**: ls 명령어 개선 버전
- **fd**: find 명령어 개선 버전
- **ripgrep**: grep 명령어 개선 버전

### 보안 도구
- **SSH 키 관리**: 자동 권한 설정 (400)
- **GPG**: 암호화 및 서명
- **pass**: 비밀번호 관리자

## 🚀 설치 후 설정

### 1. 환경 설정 적용
```bash
# 새로운 터미널을 열거나
source ~/.bashrc

# 또는 환경 설정 파일을 직접 로드
source ~/.mcp-cloud-env

# 환경 검증 실행
./check-environment.sh
```

### 2. AWS 설정
```bash
# AWS CLI 설정
aws configure

# AWS Vault 설정 (선택사항)
aws-vault add default
```
설정할 정보:
- AWS Access Key ID
- AWS Secret Access Key
- Default region name (예: ap-northeast-2)
- Default output format (예: json)

### 3. GCP 설정
```bash
# GCP 초기화
gcloud init

# GCP 인증 확인
gcloud auth list
```
설정할 정보:
- GCP 계정 로그인
- 프로젝트 선택
- 기본 리전 설정 (예: asia-northeast3)
- 기본 존 설정 (예: asia-northeast3-a)

### 4. Docker 권한 설정
```bash
# Docker 그룹 권한 적용
newgrp docker

# 또는 로그아웃 후 다시 로그인

# Docker 서비스 시작 (WSL에서)
sudo service docker start
```

### 5. SSH 키 설정
```bash
# SSH 키 생성 (없는 경우)
ssh-keygen -t ed25519 -C "your-email@example.com"

# SSH 키 권한 자동 설정
chmod 400 ~/.ssh/id_ed25519*

# GitHub에 SSH 키 추가
gh auth login
gh ssh-key add ~/.ssh/id_ed25519.pub
```

## 📁 작업 디렉토리

설치 후 다음 디렉토리가 생성됩니다:
- `~/mcp-cloud-workspace/`: 메인 작업 디렉토리
- `~/mcp-cloud-workspace/projects/`: 프로젝트 파일
- `~/mcp-cloud-workspace/scripts/`: 스크립트 파일
- `~/mcp-cloud-workspace/configs/`: 설정 파일

## 🔧 문제 해결

### WSL 환경 확인
```bash
# WSL 버전 확인
wsl --list --verbose

# Linux 배포판 확인
cat /etc/os-release

# WSL 환경 검증
./check-environment.sh
```

### 권한 문제
```bash
# 스크립트 실행 권한 부여
chmod +x *.sh

# sudo 권한 확인
sudo -v

# SSH 키 권한 문제 해결
chmod 400 ~/.ssh/id_*
chmod 700 ~/.ssh
```

### 네트워크 문제
```bash
# DNS 설정 확인
cat /etc/resolv.conf

# 패키지 저장소 업데이트
sudo apt update

# 네트워크 연결 테스트
ping -c 3 google.com
```

### Docker 문제
```bash
# Docker 서비스 상태 확인
sudo systemctl status docker

# Docker 서비스 시작
sudo systemctl start docker

# WSL에서 Docker 서비스 시작
sudo service docker start

# Docker 권한 문제 해결
sudo usermod -aG docker $USER
newgrp docker
```

### SSH 키 권한 문제
```bash
# 키 파일 권한 자동 수정
find ~/.ssh -name "*.pem" -exec chmod 400 {} \;
find ~/.ssh -name "id_*" -exec chmod 400 {} \;

# SSH 디렉토리 권한 설정
chmod 700 ~/.ssh
chmod 644 ~/.ssh/authorized_keys 2>/dev/null || true
```

### 설치 실패 문제
```bash
# 설치 로그 확인
tail -f /tmp/mcp-cloud-install.log

# 부분 설치 정리 후 재시도
./install-all-wsl.sh --cleanup
./install-all-wsl.sh
```

## 📚 사용법

### AWS CLI 사용 예시
```bash
# EC2 인스턴스 목록
aws ec2 describe-instances

# S3 버킷 목록
aws s3 ls

# IAM 사용자 정보
aws sts get-caller-identity

# AWS Vault 사용 (보안 강화)
aws-vault exec default -- aws s3 ls
```

### GCP CLI 사용 예시
```bash
# Compute Engine 인스턴스 목록
gcloud compute instances list

# Storage 버킷 목록
gsutil ls

# 현재 프로젝트 확인
gcloud config get-value project

# GCP 인증 확인
gcloud auth list
```

### Docker 사용 예시
```bash
# Docker 이미지 빌드
docker build -t my-app .

# 컨테이너 실행
docker run -d -p 8080:80 my-app

# 컨테이너 목록
docker ps

# Docker Compose 사용
docker-compose up -d
```

### Kubernetes 사용 예시
```bash
# 클러스터 정보
kubectl cluster-info

# Pod 목록
kubectl get pods

# 서비스 목록
kubectl get services

# k9s 대화형 관리
k9s

# Helm 차트 설치
helm install my-app stable/nginx
```

### SSH 키 관리 예시
```bash
# SSH 키 생성
ssh-keygen -t ed25519 -C "your-email@example.com"

# SSH 키 권한 설정 (자동)
chmod 400 ~/.ssh/id_ed25519*

# EC2 인스턴스 연결
ssh -i ~/.ssh/your-key.pem ec2-user@your-instance-ip

# GitHub SSH 연결 테스트
ssh -T git@github.com
```

### 개발 도구 사용 예시
```bash
# Git 설정
git config --global user.name "Your Name"
git config --global user.email "your-email@example.com"

# GitHub CLI 사용
gh repo clone owner/repo
gh issue list
gh pr create

# 개선된 명령어 사용
bat README.md          # cat 대신
exa -la                 # ls 대신
fd "pattern"           # find 대신
rg "pattern"           # grep 대신
```

## 🎯 다음 단계

1. **환경 설정 완료**: AWS 및 GCP 인증 설정
2. **실습 시작**: Cloud Master 교육 과정 실습
3. **프로젝트 개발**: 실제 클라우드 프로젝트 개발
4. **보안 강화**: SSH 키 및 AWS Vault 설정

## 🔒 보안 모범 사례

### SSH 키 관리
- **키 파일 권한**: 항상 400 (소유자만 읽기)
- **SSH 디렉토리 권한**: 700 (소유자만 접근)
- **키 생성**: ED25519 알고리즘 사용 권장
- **키 백업**: 안전한 위치에 암호화하여 저장

### AWS 보안
- **AWS Vault 사용**: 자격 증명을 안전하게 관리
- **IAM 역할**: 최소 권한 원칙 적용
- **MFA 활성화**: 다중 인증 사용

### GCP 보안
- **서비스 계정**: 사용자 계정 대신 서비스 계정 사용
- **키 로테이션**: 정기적인 키 교체
- **감사 로그**: 모든 활동 모니터링

## 📞 지원

문제가 발생하면 다음을 확인하세요:
1. WSL 버전이 최신인지 확인
2. Linux 배포판이 Ubuntu 20.04 이상인지 확인
3. 네트워크 연결 상태 확인
4. 스크립트 실행 권한 확인
5. SSH 키 권한 설정 확인

### 로그 확인
```bash
# 설치 로그 확인
tail -f /tmp/mcp-cloud-install.log

# 환경 검증 실행
./check-environment.sh

# 특정 도구 버전 확인
aws --version
gcloud --version
docker --version
kubectl version --client
```

---

**참고**: 이 설치 스크립트는 WSL 환경에 최적화되어 있습니다. 다른 Linux 환경에서 사용할 경우 일부 명령어를 수정해야 할 수 있습니다.

**업데이트**: 2024년 9월 - SSH 키 권한 자동 관리, AWS Vault 지원, 개선된 도구들 추가
