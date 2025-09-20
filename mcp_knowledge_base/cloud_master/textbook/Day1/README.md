# Cloud Master - 1일차: Docker & Git/GitHub & GitHub Actions & VM 배포

## 🎯 학습 목표

### 핵심 학습 목표
- **Docker 컨테이너화**: 애플리케이션 컨테이너화 및 최적화
- **Git/GitHub 협업**: 버전 관리 및 협업 워크플로우
- **GitHub Actions CI/CD**: 자동화 파이프라인 구축
- **VM 배포**: AWS EC2, GCP Compute Engine을 활용한 애플리케이션 배포

### 실습 후 달성할 수 있는 능력
- ✅ Docker를 활용한 웹 애플리케이션 컨테이너화
- ✅ Git/GitHub을 통한 버전 관리 및 협업
- ✅ GitHub Actions로 기본 CI/CD 파이프라인 구축
- ✅ VM 기반 웹 애플리케이션 배포 및 기본 운영

### 예상 소요 시간
- **Docker 기초**: 90-120분
- **Git/GitHub 기초**: 60-90분
- **GitHub Actions 기초**: 90-120분
- **VM 배포**: 90-120분
- **전체 과정**: 6-8시간

---

## 🔧 실습 환경 준비

### 필수 계정
- **AWS 계정**: Free Tier 계정
- **GCP 계정**: Free Tier 계정 ($300 크레딧)
- **GitHub 계정**: 코드 저장소 및 CI/CD

### 필수 도구
- **Docker**: 컨테이너 실행 환경
- **Git**: 버전 관리
- **AWS CLI**: AWS 서비스 관리
- **GCP CLI**: GCP 서비스 관리

### 환경 설정
```bash
# Docker 설치 확인
docker --version

# Git 설치 확인
git --version

# AWS CLI 설치 확인
aws --version

# GCP CLI 설치 확인
gcloud --version
```

---

## 📚 이론 학습

<details>
<summary>🐳 Docker 기초</summary>

### Docker 개념
- **컨테이너**: 애플리케이션과 의존성을 패키징한 실행 단위
- **이미지**: 컨테이너를 생성하는 템플릿
- **Dockerfile**: 이미지를 빌드하기 위한 명령어 집합

### Docker 명령어
```bash
# 이미지 빌드
docker build -t my-app .

# 컨테이너 실행
docker run -d -p 3000:3000 my-app

# 컨테이너 목록 확인
docker ps

# 컨테이너 중지
docker stop <container_id>
```

### Dockerfile 예시
```dockerfile
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
EXPOSE 3000
CMD ["npm", "start"]
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

### 워크플로우 파일 구조
```yaml
name: CI/CD Pipeline
on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    - name: Setup Node.js
      uses: actions/setup-node@v3
      with:
        node-version: '18'
    - name: Install dependencies
      run: npm install
    - name: Run tests
      run: npm test
    - name: Build
      run: npm run build
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

# SSH 연결
ssh -i my-key.pem ec2-user@<public-ip>
```

### GCP Compute Engine 배포
```bash
# VM 인스턴스 생성
gcloud compute instances create my-vm \
  --zone=us-central1-a \
  --machine-type=e2-micro \
  --image-family=ubuntu-2004-lts \
  --image-project=ubuntu-os-cloud

# SSH 연결
gcloud compute ssh my-vm --zone=us-central1-a
```

</details>

---

## 🛠️ 실습 학습

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
<summary>⚡ GitHub Actions 실습</summary>

### 1단계: 워크플로우 파일 생성
```bash
# .github/workflows 디렉토리 생성
mkdir -p .github/workflows

# ci.yml 파일 생성
cat > .github/workflows/ci.yml << EOF
name: CI/CD Pipeline
on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    - name: Setup Node.js
      uses: actions/setup-node@v3
      with:
        node-version: '18'
    - name: Install dependencies
      run: npm install
    - name: Run tests
      run: npm test
    - name: Build
      run: npm run build
EOF
```

### 2단계: 워크플로우 테스트
```bash
# 변경사항 커밋 및 푸시
git add .
git commit -m "Add GitHub Actions workflow"
git push origin main
```

### 3단계: Actions 탭에서 실행 확인
1. GitHub 저장소의 Actions 탭 이동
2. 워크플로우 실행 상태 확인

</details>

<details>
<summary>☁️ VM 배포 실습</summary>

### AWS EC2 배포
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

</details>

---

## 🧹 실습 정리

### 자동 정리
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

### 수동 정리
- [ ] Docker 컨테이너 중지 및 삭제
- [ ] AWS EC2 인스턴스 종료
- [ ] GCP Compute Engine 인스턴스 삭제
- [ ] GitHub Actions 워크플로우 정리

---

## 📚 참고 자료

### 공식 문서
- [Docker 공식 문서](https://docs.docker.com/)
- [Git 공식 문서](https://git-scm.com/doc)
- [GitHub Actions 공식 문서](https://docs.github.com/en/actions)
- [AWS EC2 공식 문서](https://docs.aws.amazon.com/ec2/)
- [GCP Compute Engine 공식 문서](https://cloud.google.com/compute/docs)

### 문제 해결
1. **Docker 이미지 빌드 실패**: Dockerfile 문법 및 의존성 확인
2. **Git 푸시 실패**: 인증 정보 및 권한 확인
3. **GitHub Actions 실패**: 워크플로우 파일 문법 확인
4. **VM 연결 실패**: 보안 그룹 및 네트워크 설정 확인

---

<div align="center">

[← 이전: Cloud Master 메인](../README.md) | 
[📚 전체 커리큘럼](../../../curriculum.md) | 
[🏠 학습 경로로 돌아가기](../../../index.md) | 
[다음: Day 2 →](../Day2/README.md)

</div>