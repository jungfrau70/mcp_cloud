# WSL → Cloud VM 설정 가이드

## 🎯 개요

이 가이드는 Windows WSL 환경에서 Cloud VM으로 실습 환경을 구성하는 방법을 단계별로 안내합니다.

## 🔧 사전 준비

### WSL 환경 확인
```bash
# WSL 버전 확인
wsl --version

# Ubuntu 버전 확인
lsb_release -a

# 필수 도구 확인
command -v git && echo "✅ Git 설치됨" || echo "❌ Git 설치 필요"
command -v curl && echo "✅ curl 설치됨" || echo "❌ curl 설치 필요"
```

### Cloud VM 준비
- AWS EC2 또는 GCP Compute Engine 인스턴스 생성
- SSH 키 페어 생성 및 다운로드
- 보안 그룹/방화벽 규칙 설정 (SSH, HTTP, HTTPS 포트 개방)

## 🚀 설정 단계

### 1단계: WSL에서 Git Repository 생성

#### 자동화 스크립트 사용 (권장)
```bash
# 실습 코드 디렉토리로 이동
cd /mnt/c/Users/[사용자명]/mcp_cloud/mcp_knowledge_base/cloud_master/repos/day3/automation

# Git Repository 자동 생성
./create-git-repo.sh
```

#### 수동 설정
```bash
# 작업 디렉토리 생성
cd /mnt/c/Users/[사용자명]/Documents
mkdir cloud-master-day3-practice
cd cloud-master-day3-practice

# Git 초기화
git init
git config user.name "Cloud Master Student"
git config user.email "student@cloudmaster.com"

# 실습 코드 복사
cp -r /mnt/c/Users/[사용자명]/mcp_cloud/mcp_knowledge_base/cloud_master/repos/day3/automation/* .

# GitHub Repository 생성 및 Push
git add .
git commit -m "Initial commit: Day3 practice automation scripts"
git remote add origin https://github.com/[사용자명]/cloud-master-day3-practice.git
git branch -M main
git push -u origin main
```

### 2단계: Cloud VM 환경 설정

#### SSH 접속
```bash
# AWS EC2 접속
ssh -i ~/.ssh/cloud-master-key.pem ubuntu@[EC2_PUBLIC_IP]

# GCP Compute Engine 접속
ssh -i ~/.ssh/cloud-master-key.pem ubuntu@[GCP_EXTERNAL_IP]
```

#### VM 환경 자동 설정
```bash
# VM 설정 스크립트 다운로드 및 실행
curl -O https://raw.githubusercontent.com/[사용자명]/cloud-master-day3-practice/main/vm-setup.sh
chmod +x vm-setup.sh
./vm-setup.sh
```

#### 수동 설정 (필요시)
```bash
# 시스템 업데이트
sudo apt update && sudo apt upgrade -y

# 필수 도구 설치
sudo apt install -y git curl wget jq unzip htop tree vim nano

# Docker 설치
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER

# Docker Compose 설치
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# AWS CLI 설치
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# GCP CLI 설치
curl https://sdk.cloud.google.com | bash
exec -l $SHELL
```

### 3단계: 실습 코드 Clone

```bash
# Repository Clone
git clone https://github.com/[사용자명]/cloud-master-day3-practice.git
cd cloud-master-day3-practice

# 실행 권한 부여
chmod +x *.sh
```

## 🔄 동기화 방법

### Git을 통한 실시간 동기화
```bash
# WSL에서 코드 수정 후
git add .
git commit -m "Update monitoring configuration"
git push origin main

# VM에서 최신 코드 Pull
git pull origin main
```

### SCP를 통한 파일 동기화
```bash
# WSL에서 VM으로 파일 전송
scp -i ~/.ssh/cloud-master-key.pem *.sh ubuntu@[VM_IP]:~/cloud-master-day3-practice/

# VM에서 WSL로 결과 파일 수신
scp -i ~/.ssh/cloud-master-key.pem ubuntu@[VM_IP]:~/cloud-master-workspace/results/* ./
```

### VS Code Remote SSH 사용
```bash
# SSH 설정 파일에 VM 정보 추가
Host cloud-master-vm
    HostName [VM_IP]
    User ubuntu
    IdentityFile ~/.ssh/cloud-master-key.pem
    Port 22

# VS Code에서 Remote SSH로 VM에 직접 연결하여 작업
```

## 🧪 실습 실행

### 실습 순서
```bash
# 1. AWS 로드밸런싱
./01-aws-loadbalancing.sh setup
./01-aws-loadbalancing.sh status

# 2. GCP 로드밸런싱
./02-gcp-loadbalancing.sh setup
./02-gcp-loadbalancing.sh test

# 3. 모니터링 스택
./03-monitoring-stack.sh setup
./03-monitoring-stack.sh start

# 4. 자동 스케일링
./04-autoscaling.sh setup
./04-autoscaling.sh test

# 5. 비용 최적화
./05-cost-optimization.sh analyze
./05-cost-optimization.sh report

# 6. 통합 테스트
./06-integration-test.sh setup
./06-integration-test.sh test
```

## 🔍 확인 방법

### 시스템 상태 확인
```bash
# Docker 상태 확인
docker ps

# AWS CLI 설정 확인
aws sts get-caller-identity

# GCP CLI 설정 확인
gcloud auth list

# 모니터링 서비스 확인
curl http://localhost:9091  # Prometheus
curl http://localhost:3002  # Grafana
```

### 로그 확인
```bash
# 실습 로그 확인
tail -f ~/cloud-master-workspace/logs/*.log

# Docker 로그 확인
docker logs prometheus
docker logs grafana
```

## 🚨 문제 해결

### 일반적인 문제
1. **SSH 접속 실패**: 키 파일 권한 확인 (`chmod 600 ~/.ssh/cloud-master-key.pem`)
2. **Docker 권한 오류**: 사용자를 docker 그룹에 추가 (`sudo usermod -aG docker $USER`)
3. **포트 충돌**: Day2 모니터링 스택 중지 또는 포트 변경
4. **Git 인증 오류**: SSH 키 또는 Personal Access Token 설정

### 로그 확인
```bash
# 시스템 로그
sudo journalctl -u docker

# 실습 스크립트 로그
ls -la ~/cloud-master-workspace/logs/

# Docker 컨테이너 로그
docker logs [container_name]
```

## 📚 추가 자료

- [포트 충돌 해결 가이드](port-conflict-resolution.md)
- [문제 해결 가이드](troubleshooting.md)
- [Cloud Master 전체 과정](../../README.md)
