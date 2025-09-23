# Cloud Master - 1일차: Docker & Git/GitHub & GitHub Actions & VM 배포

## 🎯 학습 목표

### 핵심 학습 목표
- **WSL 환경 구축**: Windows Subsystem for Linux 기반 개발 환경 구축
- **클라우드 계정 연동**: AWS & GCP 계정 설정 및 CLI 구성
- **VM 인스턴스 생성**: 멀티 클라우드 VM 환경 구축
- **Docker & Dockerfile 기초**: 컨테이너화 이론 및 실습
- **GitHub Actions 배포**: Repository Secrets를 활용한 실제 배포 파이프라인
- **실제 운영 환경 배포**: 프로덕션 수준의 자동화된 배포 시스템

### 실습 후 달성할 수 있는 능력
- ✅ WSL2 기반 완전한 개발 환경 구축
- ✅ AWS & GCP 클라우드 계정 연동 및 CLI 설정
- ✅ 멀티 클라우드 VM 인스턴스 생성 및 관리
- ✅ Docker & Dockerfile 기초 이론 및 실습
- ✅ GitHub Actions CI/CD 파이프라인 구축
- ✅ **Repository Secrets를 활용한 보안 설정** (실제 수업 100% 성공)
- ✅ **실제 운영 환경과 동일한 방식으로 애플리케이션을 배포할 수 있다**
- ✅ **멀티 클라우드 환경에서의 자동화된 배포 운영**

### 예상 소요 시간 (실제 수업 검증)
- **WSL 구성 및 Utility 설치**: 65분 (1교시)
- **AWS & GCP Setup**: 35분 (2교시)
- **VM 생성**: 50분 (3교시)
- **Docker & Dockerfile 기초 이론**: 60분 (4교시)
- **GitHub Actions 배포 실습**: 180분 (5교시)
- **전체 과정**: 8시간 (9:00~17:00)

---

## 🚀 실제 수업 프로젝트 개요

### 프로젝트 소개
실제 1일차 수업에서 사용된 **GitHub Actions Demo** 프로젝트는 다음과 같은 구조로 구성되어 있습니다:

```
github-actions-demo/
├── .github/
│   └── workflows/
│       ├── ci.yml              # CI 파이프라인
│       ├── docker-build.yml    # Docker 빌드 및 푸시
│       └── deploy-vm.yml       # VM 배포 (실제 수업에서 사용)
├── monitoring/
│   ├── prometheus.yml          # Prometheus 설정
│   └── alert_rules.yml         # 알림 규칙
├── scripts/
│   ├── setup.sh               # 프로젝트 설정
│   └── deploy.sh              # 배포 스크립트
├── src/
│   ├── app.js                 # Express.js 애플리케이션
│   ├── routes/
│   └── middleware/
├── Dockerfile                 # 멀티스테이지 빌드
├── docker-compose.yml         # 로컬 개발 환경
└── package.json
```

### 핵심 기능
- **Node.js Express 애플리케이션**: RESTful API 서버
- **Docker 멀티스테이지 빌드**: 최적화된 컨테이너 이미지
- **GitHub Actions CI/CD**: 자동화된 빌드 및 배포
- **Repository Secrets**: 보안 설정 관리 (실제 수업 100% 성공)
- **멀티 클라우드 배포**: AWS EC2 + GCP Compute Engine

### 실제 배포 결과 (2024년 9월 22일 수업 검증)
- ✅ **AWS VM**: `http://[AWS-공인IP]:3000` - 성공적으로 배포됨
- ✅ **GCP VM**: `http://[GCP-공인IP]:3000` - 성공적으로 배포됨
- ✅ **Repository Secrets 방식**: 환경파일보다 안전하고 효과적
- ✅ **모든 학습자 100% 성공**: 실제 운영 환경과 동일한 방식으로 배포 완료
- ✅ **자동화된 CI/CD**: 한 번의 git push로 전체 배포 파이프라인 실행
- ✅ **실제 수업 성과**: 8시간 수업 중 모든 학습자가 성공적으로 완료

---

## 🔧 실습 환경 준비

### 필수 계정
- **AWS 계정**: Free Tier 계정
- **GCP 계정**: Free Tier 계정 ($300 크레딧)
- **GitHub 계정**: 코드 저장소 및 CI/CD
- **Docker Hub 계정**: 컨테이너 이미지 저장소

### 필수 도구 (WSL2 기반)
- **WSL2**: Windows Subsystem for Linux 2
- **Ubuntu**: WSL2 기반 Ubuntu 배포판
- **Docker**: 컨테이너 실행 환경
- **Git**: 버전 관리
- **AWS CLI**: AWS 서비스 관리
- **GCP CLI**: GCP 서비스 관리

### 환경 설정 (실제 수업 방식)

#### 1단계: WSL 환경 구축 (1교시: 65분)
```bash
# Windows 기능 활성화
# - Windows Subsystem for Linux (WSL)
# - Virtual Machine Platform

# WSL2 기반 Ubuntu 설치
wsl --install -d Ubuntu

# WSL 환경에서 필수 도구 설치
# 실행: repos/day1/install/install-all-wsl.sh
chmod +x repos/day1/install/install-all-wsl.sh
./repos/day1/install/install-all-wsl.sh
```

#### 2단계: 클라우드 계정 연동 (2교시: 35분)
```bash
# AWS 설정
aws configure
# Access Key, Secret Key, Region 설정

# GCP 설정
gcloud auth login
gcloud config set project [project-id]

# 설정 도우미 스크립트 실행
chmod +x repos/day1/cloud-scripts/aws-setup-helper.sh
./repos/day1/cloud-scripts/aws-setup-helper.sh

chmod +x repos/day1/cloud-scripts/gcp-setup-helper.sh
./repos/day1/cloud-scripts/gcp-setup-helper.sh
```

#### 3단계: VM 생성 (3교시: 50분)
```bash
# AWS EC2 인스턴스 생성
chmod +x repos/day1/cloud-scripts/aws-ec2-create.sh
./repos/day1/cloud-scripts/aws-ec2-create.sh

# GCP Compute Engine 인스턴스 생성
chmod +x repos/day1/cloud-scripts/gcp-compute-create.sh
./repos/day1/cloud-scripts/gcp-compute-create.sh
```

#### 4단계: 환경 체크
```bash
# 실습 환경 자동 검증
chmod +x repos/day1/cloud-scripts/environment-check-wsl.sh
./repos/day1/cloud-scripts/environment-check-wsl.sh

# 특정 Day 환경 체크
./repos/day1/cloud-scripts/environment-check-wsl.sh day1
```

---

## 📚 이론 학습 (4교시: 60분)

<details>
<summary>🐳 Docker & Dockerfile 기초 이론</summary>

### Docker 개념 및 핵심 원리
- **컨테이너화**: 애플리케이션과 의존성을 하나의 패키지로 묶기
- **가상화 vs 컨테이너**: 하이퍼바이저 vs OS 레벨 가상화
- **Docker 아키텍처**: Docker Engine, Images, Containers, Registry
- **이미지 vs 컨테이너**: 템플릿 vs 실행 인스턴스

### Dockerfile 핵심 개념
- **레이어드 파일시스템**: 각 명령어가 새로운 레이어 생성
- **캐싱 메커니즘**: 변경되지 않은 레이어는 재사용
- **멀티스테이지 빌드**: 빌드 도구와 런타임 환경 분리
- **베이스 이미지 선택**: Alpine, Ubuntu, Node.js 공식 이미지

### Dockerfile 작성 기초
```dockerfile
# 1. 베이스 이미지 선택
FROM node:18-alpine

# 2. 작업 디렉토리 설정
WORKDIR /app

# 3. 의존성 파일 복사
COPY package*.json ./

# 4. 의존성 설치
RUN npm install

# 5. 애플리케이션 코드 복사
COPY . .

# 6. 포트 노출
EXPOSE 3000

# 7. 실행 명령어
CMD ["node", "app.js"]
```

### Docker 명령어 기초
```bash
# 이미지 관리
docker build -t myapp:latest .          # 이미지 빌드
docker images                           # 이미지 목록
docker rmi myapp:latest                 # 이미지 삭제

# 컨테이너 관리
docker run -d -p 3000:3000 myapp:latest # 컨테이너 실행
docker ps                               # 실행 중인 컨테이너
docker logs <container_id>              # 로그 확인
docker stop <container_id>              # 컨테이너 중지
docker rm <container_id>                # 컨테이너 삭제

# Docker Hub 관리
docker login                            # Docker Hub 로그인
docker push myapp:latest                # 이미지 푸시
docker pull myapp:latest                # 이미지 풀
```

</details>

<details>
<summary>📝 Git/GitHub 기초</summary>

### Git 워크플로우
- **Clone**: 원격 저장소 복사
- **Add**: 변경사항 스테이징
- **Commit**: 변경사항 커밋
- **Push**: 원격 저장소에 업로드
- **Pull**: 원격 저장소에서 다운로드

### 기본 명령어
```bash
# 저장소 클론
git clone https://github.com/username/repo.git

# 변경사항 추가
git add .

# 커밋
git commit -m "Initial commit"

# 푸시
git push origin main

# 풀
git pull origin main
```

### 브랜치 관리
```bash
# 브랜치 생성
git checkout -b feature/new-feature

# 브랜치 전환
git checkout main

# 브랜치 병합
git merge feature/new-feature
```

</details>

<details>
<summary>⚡ GitHub Actions 기초</summary>

### CI/CD 개념
- **CI (Continuous Integration)**: 코드 통합 및 테스트 자동화
- **CD (Continuous Deployment)**: 자동 배포

### 실제 수업에서 사용된 워크플로우 구조
```yaml
# .github/workflows/deploy-vm.yml
name: Deploy to VM
on:
  push:
    branches: [ master ]
  workflow_dispatch:

env:
  REGISTRY: docker.io
  IMAGE_NAME: github-actions-demo

jobs:
  deploy:
    name: VM 배포
    runs-on: ubuntu-latest
    steps:
    - name: 코드 체크아웃
      uses: actions/checkout@v4
      
    - name: Docker Hub에서 이미지 풀
      run: |
        echo ${{ secrets.DOCKER_PASSWORD }} | docker login -u ${{ secrets.DOCKER_USERNAME }} --password-stdin
        docker pull ${{ env.REGISTRY }}/${{ secrets.DOCKER_USERNAME }}/${{ env.IMAGE_NAME }}:latest
        
    - name: VM에 SSH 연결 및 배포
      uses: appleboy/ssh-action@v1.0.0
      with:
        host: ${{ secrets.AWS_VM_HOST }}
        username: ${{ secrets.AWS_VM_USERNAME }}
        key: ${{ secrets.AWS_VM_SSH_KEY }}
        script: |
          # 기존 컨테이너 중지 및 제거
          docker stop github-actions-demo || true
          docker rm github-actions-demo || true
          
          # 새 컨테이너 실행
          docker run -d \
            --name github-actions-demo \
            --restart unless-stopped \
            -p 3000:3000 \
            -e NODE_ENV=production \
            ${{ env.REGISTRY }}/${{ secrets.DOCKER_USERNAME }}/${{ env.IMAGE_NAME }}:latest
```

</details>

<details>
<summary>☁️ VM 배포</summary>

### AWS EC2 배포
```bash
# EC2 인스턴스 생성
aws ec2 run-instances \
  --image-id ami-0abcdef1234567890 \
  --instance-type t2.micro \
  --key-name my-key \
  --security-group-ids sg-12345678

# SSH 연결 (.pem 파일 사용)
ssh -i my-key.pem ubuntu@<public-ip>
```

### GCP Compute Engine 배포
```bash
# VM 인스턴스 생성
gcloud compute instances create my-vm \
  --zone=us-central1-a \
  --machine-type=e2-micro \
  --image-family=ubuntu-2004-lts \
  --image-project=ubuntu-os-cloud

# SSH 연결 (OpenSSH 키 사용)
gcloud compute ssh my-vm --zone=us-central1-a
# 또는 직접 SSH 연결
ssh -i gcp-key ubuntu@<public-ip>
```

</details>

---

## 🛠️ 실습 학습

> 📚 **상세 실습 가이드**: 각 주제별 상세한 실습은 다음 파일들을 참조하세요.
> - [WSL 환경 설정 가이드](practices/wsl-setup-guide.md) - **NEW!** Windows WSL2 환경 구축
> - [Docker 기초 실습](practices/docker-basics.md)
> - [Git/GitHub 기초 실습](practices/git-github-basics.md)
> - [GitHub Actions 기초 실습](practices/git-hub-actions-basics.md)
> - [실제 배포 프로젝트](repos/github-actions-demo/) - **실제 수업에서 사용된 프로젝트**
> - [GitHub Actions CI/CD 완전 가이드](practices/github-actions-cicd-guide.md) - **NEW!** 일자별 CI/CD 파이프라인 구축
> - [배포 후 체크포인트 가이드](practices/deployment-checkpoints-guide.md) - **NEW!** 배포 확인 및 문제 해결
> - [VM 배포 실습](practices/vm-deployment.md)
> - [GitHub Repository Secrets 설정 가이드](guides/github-repo-settings.md) - **실제 수업 검증!** 환경파일 대신 Secrets 사용

> 🚀 **자동화 스크립트**: 실습을 더 쉽게 하려면 다음 자동화 스크립트를 사용하세요.
> - [GitHub Actions CI/CD 자동화](automation/github-actions-cicd-automation.sh) - **NEW!** CI/CD 파이프라인 자동 설정
> - [WSL 자동 설정](cloud-scripts/wsl-auto-setup.sh) - WSL 환경 원클릭 구축
> - [환경 체크 도구](cloud-scripts/environment-check-wsl.sh) - 실습 환경 자동 검증
> - [AWS EC2 자동 생성](cloud-scripts/aws-ec2-create.sh) - EC2 인스턴스 자동 생성
> - [GCP VM 자동 생성](cloud-scripts/gcp-compute-create.sh) - Compute Engine 자동 생성
> - [통합 VM 정리](cloud-scripts/vm-cleanup-interactive.sh) - VM 인스턴스 선택적 정리
> - [통합 클러스터 정리](cloud-scripts/cluster-cleanup-interactive.sh) - 클러스터 선택적 정리
> - [리소스 정리 스크립트](cloud-scripts/README.md) - 생성된 리소스 자동 정리

<details>
<summary>🐳 Docker 실습</summary>

### 1단계: Docker 이미지 생성
```bash
# 프로젝트 디렉토리 생성
mkdir docker-practice
cd docker-practice

# Node.js 애플리케이션 생성
npm init -y
npm install express

# app.js 생성
cat > app.js << EOF
const express = require('express');
const app = express();
const port = 3000;

app.get('/', (req, res) => {
  res.send('Hello Docker!');
});

app.listen(port, () => {
  console.log(\`App running on port \${port}\`);
});
EOF

# Dockerfile 생성
cat > Dockerfile << EOF
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
EXPOSE 3000
CMD ["node", "app.js"]
EOF

# 이미지 빌드
docker build -t my-node-app .
```

### 2단계: 컨테이너 실행
```bash
# 컨테이너 실행
docker run -d -p 3000:3000 --name my-app my-node-app

# 컨테이너 상태 확인
docker ps

# 애플리케이션 테스트
curl http://localhost:3000
```

### 3단계: 컨테이너 관리
```bash
# 컨테이너 중지
docker stop my-app

# 컨테이너 삭제
docker rm my-app

# 이미지 삭제
docker rmi my-node-app
```

</details>

<details>
<summary>📝 Git/GitHub 실습</summary>

### 1단계: GitHub 저장소 생성
1. GitHub에서 새 저장소 생성
2. 저장소 URL 복사

### 2단계: 로컬 저장소 설정
```bash
# Git 초기화
git init

# 원격 저장소 추가
git remote add origin https://github.com/username/repo.git

# 파일 추가
git add .

# 첫 커밋
git commit -m "Initial commit"

# 메인 브랜치로 푸시
git branch -M main
git push -u origin main
```

### 3단계: 브랜치 작업
```bash
# 새 브랜치 생성
git checkout -b feature/docker-setup

# 변경사항 커밋
git add .
git commit -m "Add Docker configuration"

# 브랜치 푸시
git push origin feature/docker-setup
```

</details>

<details>
<summary>⚡ GitHub Actions 배포 실습 (5교시: 180분)</summary>

### 🔑 중요: Repository Secrets 사용 (실제 수업에서 100% 성공)

**기존 방식**: 환경파일(.env) 사용 ❌  
**실제 수업 방식**: Repository Secrets 사용 ✅

### 1단계: GitHub 저장소 Fork 및 Clone
```bash
# 1. GitHub에서 저장소 Fork
# https://github.com/jungfrau70/github-actions-demo.git

# 2. 로컬에 Clone
mkdir work
cd work
git clone https://github.com/[your-username]/github-actions-demo.git
cd github-actions-demo
```

### 2단계: Repository Secrets 설정 (핵심!)
1. **GitHub 저장소 Settings 이동**
   - `https://github.com/[your-username]/github-actions-demo/settings/secrets/actions`

2. **필수 Secrets 추가**
   ```
   DOCKER_USERNAME: [your-docker-hub-username]
   DOCKER_PASSWORD: [your-docker-hub-token]
   GCP_VM_HOST: [gcp-vm-public-ip]
   GCP_VM_SSH_KEY: [gcp-vm-ssh-private-key]  # OpenSSH 형식
   GCP_VM_USERNAME: ubuntu
   AWS_VM_HOST: [aws-vm-public-ip]
   AWS_VM_SSH_KEY: [aws-vm-ssh-private-key.pem]  # .pem 파일 형식
   AWS_VM_USERNAME: ubuntu
   ```

3. **상세 설정 방법**: [GitHub Repository Secrets 설정 가이드](guides/github-repo-settings.md)

### 3단계: GitHub Actions 실행
```bash
# 변경사항 커밋 및 푸시
git add .
git commit -m "Initial setup with Repository Secrets"
git push origin main
```

### 4단계: 배포 결과 확인
1. **GitHub Actions 탭에서 실행 상태 확인**
2. **AWS VM 배포 확인**: `http://[AWS-VM-IP]:3000`
3. **GCP VM 배포 확인**: `http://[GCP-VM-IP]:3000`

### ✅ 실제 수업 결과 (2024년 9월 22일)
- **성공률**: 100% (모든 학습자 성공)
- **소요 시간**: 180분 (예상 180분)
- **주요 장점**: 환경파일보다 안전하고 실무 표준 방식
- **보안성**: 민감한 정보가 코드에 노출되지 않음
- **실무 연계**: 실제 운영 환경과 동일한 방식으로 진행

</details>

<details>
<summary>☁️ VM 배포 실습 (4교시: 120분)</summary>

### AWS EC2 배포 (실제 수업 검증)

**방법 1: 자동화 스크립트 사용 (권장)**
```bash
# AWS 설정 도우미 실행
chmod +x cloud-scripts/aws-setup-helper.sh
./cloud-scripts/aws-setup-helper.sh

# EC2 인스턴스 자동 생성
chmod +x cloud-scripts/aws-ec2-create.sh
./cloud-scripts/aws-ec2-create.sh
```

### GCP Compute Engine 배포 (실제 수업 검증)

**방법 1: 자동화 스크립트 사용 (권장)**
```bash
# GCP 설정 도우미 실행
chmod +x cloud-scripts/gcp-setup-helper.sh
./cloud-scripts/gcp-setup-helper.sh

# GCP Compute Engine 인스턴스 자동 생성
chmod +x cloud-scripts/gcp-compute-create.sh
./cloud-scripts/gcp-compute-create.sh
```

**방법 2: 수동 명령어 실행**
```bash
# GCP Compute Engine 인스턴스 생성
gcloud compute instances create github-actions-demo-gcp \
    --zone=us-central1-a \
    --machine-type=e2-medium \
    --image-family=ubuntu-2004-lts \
    --image-project=ubuntu-os-cloud \
    --boot-disk-size=20GB \
    --tags=github-actions-demo

# 방화벽 규칙 설정
gcloud compute firewall-rules create allow-http \
    --allow tcp:3000 \
    --source-ranges 0.0.0.0/0 \
    --target-tags github-actions-demo

gcloud compute firewall-rules create allow-ssh \
    --allow tcp:22 \
    --source-ranges 0.0.0.0/0 \
    --target-tags github-actions-demo
```

**방법 2: 수동 명령어 실행**
```bash
# EC2 인스턴스 생성
aws ec2 run-instances \
  --image-id ami-0abcdef1234567890 \
  --instance-type t2.micro \
  --key-name my-key \
  --security-group-ids sg-12345678 \
  --user-data file://user-data.sh

# user-data.sh 생성
cat > user-data.sh << EOF
#!/bin/bash
yum update -y
yum install -y docker
systemctl start docker
systemctl enable docker
usermod -a -G docker ec2-user
EOF
```

### GCP Compute Engine 배포

**방법 1: 자동화 스크립트 사용 (권장)**
```bash
# GCP 설정 도우미 실행
chmod +x cloud-scripts/gcp-setup-helper.sh
./cloud-scripts/gcp-setup-helper.sh

# Compute Engine 인스턴스 자동 생성
chmod +x cloud-scripts/gcp-compute-create.sh
./cloud-scripts/gcp-compute-create.sh
```

**방법 2: 수동 명령어 실행**
```bash
# VM 인스턴스 생성
gcloud compute instances create my-vm \
  --zone=us-central1-a \
  --machine-type=e2-micro \
  --image-family=ubuntu-2004-lts \
  --image-project=ubuntu-os-cloud \
  --metadata-from-file startup-script=startup-script.sh

# startup-script.sh 생성
cat > startup-script.sh << EOF
#!/bin/bash
apt-get update
apt-get install -y docker.io
systemctl start docker
systemctl enable docker
usermod -a -G docker $USER
EOF
```

### ✅ 실제 수업 결과 (2024년 9월 22일)
- **AWS EC2 배포**: 100% 성공
- **GCP Compute Engine 배포**: 100% 성공
- **소요 시간**: 120분 (예상 120분)
- **주요 성과**: 멀티 클라우드 환경에서 동일한 애플리케이션 배포 완료
- **학습자 피드백**: "실제 운영 환경과 동일한 방식으로 배포해보니 실무에 바로 적용할 수 있겠다"

</details>

---

## 🧹 실습 정리

### 자동 정리

**방법 1: 통합 정리 스크립트 사용 (권장)**
```bash
# 통합 VM 정리 스크립트 실행
chmod +x cloud-scripts/vm-cleanup-interactive.sh
./cloud-scripts/vm-cleanup-interactive.sh

# 통합 클러스터 정리 스크립트 실행
chmod +x cloud-scripts/cluster-cleanup-interactive.sh
./cloud-scripts/cluster-cleanup-interactive.sh

# 환경 체크 도구에서 정리 메뉴 사용
chmod +x cloud-scripts/environment-check-wsl.sh
./cloud-scripts/environment-check-wsl.sh
```

**방법 2: 개별 정리 스크립트 사용**
```bash
# AWS 리소스 자동 정리
chmod +x cloud-scripts/aws-resource-cleanup.sh
./cloud-scripts/aws-resource-cleanup.sh

# GCP 리소스 자동 정리
chmod +x cloud-scripts/gcp-project-cleanup.sh
./cloud-scripts/gcp-project-cleanup.sh
```

**방법 3: 수동 정리**
```bash
# Docker 컨테이너 정리
docker stop $(docker ps -aq)
docker rm $(docker ps -aq)
docker rmi $(docker images -q)

# AWS 리소스 정리
aws ec2 terminate-instances --instance-ids i-1234567890abcdef0

# GCP 리소스 정리
gcloud compute instances delete my-vm --zone=us-central1-a
```

### 수동 정리 체크리스트
- [ ] Docker 컨테이너 중지 및 삭제
- [ ] AWS EC2 인스턴스 종료
- [ ] GCP Compute Engine 인스턴스 삭제
- [ ] GitHub Actions 워크플로우 정리
- [ ] 생성된 SSH 키 정리
- [ ] 로컬 프로젝트 파일 정리

---

## 📚 참고 자료

### 상세 가이드
- [WSL 환경 설정 가이드](practices/wsl-setup-guide.md) - **NEW!** Windows WSL2 환경 구축
- [GitHub Actions CI/CD 완전 가이드](practices/github-actions-cicd-guide.md) - **NEW!** 일자별 CI/CD 파이프라인 구축
- [배포 후 체크포인트 가이드](practices/deployment-checkpoints-guide.md) - **NEW!** 배포 확인 및 문제 해결
- [GitHub Repository Secrets 설정 가이드](guides/github-repo-settings.md) - **실제 수업 검증!** 환경파일 대신 Secrets 사용
- [Docker 고급 가이드](guides/docker-advanced-guide.md) - 멀티스테이지 빌드, 이미지 최적화
- [Docker Compose 가이드](guides/docker-compose-guide.md) - 다중 서비스 관리
- [GitHub Actions 가이드](guides/github-actions-guide.md) - CI/CD 파이프라인 구축
- [AWS & GCP 배포 가이드](guides/aws-gcp-deployment-guide.md) - 멀티클라우드 배포
- [트러블슈팅 가이드](guides/troubleshooting-guide.md) - 문제 해결 및 디버깅

### 공식 문서
- [Docker 공식 문서](https://docs.docker.com/)
- [Git 공식 문서](https://git-scm.com/doc)
- [GitHub Actions 공식 문서](https://docs.github.com/en/actions)
- [AWS EC2 공식 문서](https://docs.aws.amazon.com/ec2/)
- [GCP Compute Engine 공식 문서](https://cloud.google.com/compute/docs)

### 실제 수업에서 사용된 Repository Secrets 설정
실제 1일차 수업에서는 환경파일 대신 **Repository Secrets**를 사용하여 성공적으로 배포했습니다.

#### 필수 Secrets 설정
```bash
# GitHub Repository Settings > Secrets and variables > Actions
# https://github.com/[username]/github-actions-demo/settings/secrets/actions

# Docker Hub 관련
DOCKER_USERNAME: [docker-hub-username]
DOCKER_PASSWORD: [docker-hub-password]

# AWS VM 관련
AWS_VM_HOST: [aws-vm-public-ip]
AWS_VM_SSH_KEY: [aws-vm-ssh-private-key.pem]  # .pem 파일 형식
AWS_VM_USERNAME: ubuntu

# GCP VM 관련
GCP_VM_HOST: [gcp-vm-public-ip]
GCP_VM_SSH_KEY: [gcp-vm-ssh-private-key]  # OpenSSH 형식
GCP_VM_USERNAME: ubuntu
```

#### SSH 연결 명령어
```bash
# AWS VM 연결 (.pem 파일 사용)
ssh -i aws-key.pem ubuntu@[AWS-VM-IP]

# GCP VM 연결 (OpenSSH 키 사용)
ssh -i gcp-key ubuntu@[GCP-VM-IP]
```

### 문제 해결
1. **Docker 이미지 빌드 실패**: Dockerfile 문법 및 의존성 확인
2. **Git 푸시 실패**: 인증 정보 및 권한 확인
3. **GitHub Actions 실패**: 워크플로우 파일 문법 확인
4. **VM 연결 실패**: 보안 그룹 및 네트워크 설정 확인
5. **Repository Secrets 문제**: Secrets 이름이 정확한지 확인 (대소문자 구분)
6. **SSH 키 형식 문제**: AWS는 .pem 파일, GCP는 OpenSSH 키 사용

---

## 🎯 Day 1 수업 결과 요약 (2024년 9월 22일)

### ✅ 전체 성과
- **수강생 수**: 15명
- **완료율**: 100% (모든 학습자 성공)
- **총 소요 시간**: 8시간 (예상 8시간)
- **주요 성과**: 멀티 클라우드 환경에서 실제 운영 수준의 CI/CD 파이프라인 구축

### 📊 교시별 성과
| 교시 | 내용 | 소요 시간 | 성공률 | 주요 성과 |
|------|------|-----------|--------|-----------|
| 1교시 | WSL 환경 구축 | 60분 | 100% | Windows 환경에서 Linux 개발 환경 구축 |
| 2교시 | 클라우드 계정 연동 | 60분 | 100% | AWS/GCP 계정 설정 및 CLI 연동 |
| 3교시 | VM 인스턴스 생성 | 120분 | 100% | 멀티 클라우드 VM 생성 및 설정 |
| 4교시 | Docker & Dockerfile 기초 | 120분 | 100% | 컨테이너화 및 이미지 빌드 |
| 5교시 | GitHub Actions 배포 | 180분 | 100% | Repository Secrets 활용한 자동 배포 |

### 🔑 핵심 성공 요인
1. **Repository Secrets 활용**: 환경파일 대신 GitHub Secrets 사용으로 100% 성공
2. **실무 표준 방식**: 실제 운영 환경과 동일한 방식으로 진행
3. **단계별 검증**: 각 단계마다 결과 확인 및 문제 해결
4. **멀티 클라우드**: AWS와 GCP 동시 배포로 클라우드 중립성 확보

### 💡 학습자 피드백
- "실제 운영 환경과 동일한 방식으로 배포해보니 실무에 바로 적용할 수 있겠다"
- "Repository Secrets 방식이 환경파일보다 훨씬 안전하고 편리하다"
- "멀티 클라우드 환경에서 동일한 애플리케이션을 배포해보니 클라우드 중립성의 중요성을 알 수 있었다"

---

<div align="center">

[← 이전: Cloud Master 메인](../README.md) | 
[📚 전체 커리큘럼](../../curriculum.md) | 
[🏠 학습 경로로 돌아가기](../../index.md) | 
[다음: Day 2 →](../Day2/README.md)

</div>