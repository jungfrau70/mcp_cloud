# Cloud Intermediate - 1일차: Docker, Git/GitHub, GitHub Actions 통합 실습

<details>
<summary>📋 목차</summary>

1. [🎯 학습 목표](#-학습-목표)
2. [📚 실습 가이드](#-실습-가이드)
3. [🔧 실습 환경 준비](#-실습-환경-준비)
4. [🐳 Docker 기초 및 컨테이너 기술](#-docker-기초-및-컨테이너-기술)
5. [📝 Git/GitHub 기초 및 협업](#-gitgithub-기초-및-협업)
6. [🚀 GitHub Actions CI/CD 파이프라인](#-github-actions-cicd-파이프라인)
7. [☁️ VM 기반 웹 애플리케이션 배포](#-vm-기반-웹-애플리케이션-배포)
8. [📚 문제 해결 및 참고 자료](#-문제-해결-및-참고-자료)

</details>

---

## 🎯 학습 목표

<details>
<summary>📖 이번 실습에서 배우게 될 내용</summary>

### 핵심 학습 목표
- **Docker 컨테이너 기술** 기본 개념 이해 및 활용
- **Git/GitHub** 버전 관리 및 협업 도구 사용법
- **GitHub Actions** CI/CD 파이프라인 구축
- **VM 기반 웹 애플리케이션** 배포 및 기본 운영

### 실습 후 달성할 수 있는 능력
- ✅ Docker를 활용한 웹 애플리케이션 컨테이너화
- ✅ Git/GitHub을 통한 버전 관리 및 협업
- ✅ GitHub Actions로 기본 CI/CD 파이프라인 구축
- ✅ VM 기반 웹 애플리케이션 배포 및 기본 운영

### 예상 소요 시간
- **Docker 기초**: 60-90분
- **Git/GitHub 기초**: 30-45분
- **GitHub Actions**: 90-120분
- **VM 배포**: 60-90분
- **전체 과정**: 4-5시간

</details>

---

## 📚 실습 가이드

<details>
<summary>📖 실습 가이드 개요</summary>

### 실습 구성
1. **Docker 기초 및 컨테이너 기술** (90분)
2. **Git/GitHub 기초 및 협업** (45분)
3. **GitHub Actions CI/CD 파이프라인** (120분)
4. **VM 기반 웹 애플리케이션 배포** (90분)

### 실습 방식
- **로컬 개발**: Docker, Git 로컬 환경 구축
- **클라우드 연동**: GitHub Actions를 통한 자동화
- **실제 배포**: AWS EC2, GCP Compute Engine 배포

### 실습 결과물
- Docker 컨테이너화된 웹 애플리케이션
- GitHub 저장소 및 협업 환경
- 자동화된 CI/CD 파이프라인
- VM에 배포된 웹 애플리케이션

</details>

<details>
<summary>🔗 관련 실습 가이드</summary>

### 📖 상세 실습 가이드
- 🔗 [Docker 기초 실습](./practice/docker-basics.md)
- 🔗 [GitHub Actions 기초 실습](./practice/github-actions-basics.md)
- 🔗 [VM 배포 실습](./practice/vm-deployment.md)

### 📚 개념 학습 가이드
- 🔗 [Docker 개념 가이드](./docker-concepts-guide.md)
- 🔗 [Git/GitHub 가이드](./git-github-guide.md)
- 🔗 [GitHub Actions 가이드](./github-actions-guide.md)

### 🛠️ 문제 해결 가이드
- 🔗 [Docker 트러블슈팅](./troubleshooting-docker.md)
- 🔗 [GitHub Actions 트러블슈팅](./troubleshooting-github-actions.md)

### 🔗 관련 과정 링크
- 🔗 [Cloud Basic 과정](../../../cloud_basic/textbook/Day1/README.md)
- 🔗 [Cloud Master 과정](../../../cloud_master/textbook/Day1/README.md)
- 🔗 [전체 커리큘럼](../../../curriculum.md)

</details>

---

## 🔧 실습 환경 준비

<details>
<summary>📋 필수 계정 및 도구</summary>

### 필수 계정
- **GitHub 계정**: 저장소 생성 및 Actions 사용
- **Docker Hub 계정**: Docker 이미지 저장소
- **AWS 계정**: EC2 인스턴스 배포용
- **GCP 계정**: Compute Engine 배포용

### 필수 도구
- **Docker**: 컨테이너 이미지 빌드 및 실행
- **Git**: 코드 버전 관리
- **Node.js**: 웹 애플리케이션 개발
- **VS Code**: 코드 편집 (권장)

</details>

<details>
<summary>🔧 Docker 환경 설정</summary>

### Docker 설치
```bash
# Windows
winget install Docker.DockerDesktop

# macOS
brew install --cask docker

# Ubuntu
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
```

### Docker 설치 확인
```bash
# Docker 버전 확인
docker --version
docker-compose --version

# Docker 서비스 상태 확인
docker info

# Hello World 실행
docker run hello-world
```

### Docker Hub 로그인
```bash
# Docker Hub에 로그인
docker login

# 로그인 확인
docker system info | grep Username
```

</details>

<details>
<summary>🔧 Git/GitHub 환경 설정</summary>

### Git 설치 및 설정
```bash
# Git 설치 확인
git --version

# 사용자 정보 설정
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"

# 설정 확인
git config --list
```

### GitHub SSH 키 설정
```bash
# SSH 키 생성
ssh-keygen -t rsa -b 4096 -C "your.email@example.com"

# SSH 키를 GitHub에 추가
cat ~/.ssh/id_rsa.pub
# GitHub → Settings → SSH and GPG keys → New SSH key

# SSH 연결 테스트
ssh -T git@github.com
```

</details>

---

## 🐳 Docker 기초 및 컨테이너 기술

<details>
<summary>📖 Docker 개념 이해</summary>

### Docker란?
- **정의**: 컨테이너 기반 가상화 플랫폼
- **특징**: 경량화, 이식성, 일관성, 확장성
- **구성 요소**: 이미지, 컨테이너, 레지스트리, Dockerfile

### Docker vs 가상머신
| 구분 | Docker | 가상머신 |
|------|--------|----------|
| **가상화 레벨** | OS 레벨 | 하드웨어 레벨 |
| **리소스 사용량** | 적음 | 많음 |
| **시작 시간** | 빠름 (초) | 느림 (분) |
| **이식성** | 높음 | 낮음 |

</details>

<details>
<summary>🔗 Docker 기본 명령어</summary>

### 이미지 관리
```bash
# 이미지 목록 확인
docker images

# 이미지 다운로드
docker pull nginx:alpine

# 이미지 삭제
docker rmi nginx:alpine

# 이미지 빌드
docker build -t my-app:latest .
```

### 컨테이너 관리
```bash
# 컨테이너 실행
docker run -d -p 3000:3000 --name my-app my-app:latest

# 실행 중인 컨테이너 확인
docker ps

# 컨테이너 중지
docker stop my-app

# 컨테이너 삭제
docker rm my-app

# 컨테이너 로그 확인
docker logs my-app
```

</details>

<details>
<summary>🔗 Dockerfile 작성</summary>

### 기본 Dockerfile
```dockerfile
# Node.js 애플리케이션용 Dockerfile
FROM node:18-alpine

# 작업 디렉토리 설정
WORKDIR /app

# package.json 복사
COPY package*.json ./

# 의존성 설치
RUN npm ci --only=production

# 소스 코드 복사
COPY . .

# 포트 노출
EXPOSE 3000

# 비루트 사용자로 실행
USER node

# 애플리케이션 실행
CMD ["npm", "start"]
```

### 멀티스테이지 빌드
```dockerfile
# 빌드 스테이지
FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

# 실행 스테이지
FROM node:18-alpine AS runtime
WORKDIR /app
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/package*.json ./
EXPOSE 3000
USER node
CMD ["npm", "start"]
```

</details>

<details>
<summary>🔗 Docker Compose</summary>

### docker-compose.yml
```yaml
version: '3.8'

services:
  web:
    build: .
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=production
    depends_on:
      - db
    restart: unless-stopped

  db:
    image: postgres:13-alpine
    environment:
      - POSTGRES_DB=myapp
      - POSTGRES_USER=user
      - POSTGRES_PASSWORD=password
    volumes:
      - postgres_data:/var/lib/postgresql/data
    restart: unless-stopped

  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf
    depends_on:
      - web
    restart: unless-stopped

volumes:
  postgres_data:
```

### Docker Compose 명령어
```bash
# 서비스 시작
docker-compose up -d

# 서비스 중지
docker-compose down

# 로그 확인
docker-compose logs

# 서비스 재시작
docker-compose restart
```

</details>

---

## 📝 Git/GitHub 기초 및 협업

<details>
<summary>📖 Git 개념 이해</summary>

### Git이란?
- **정의**: 분산 버전 관리 시스템
- **특징**: 분산, 빠름, 데이터 무결성, 브랜치 지원
- **작업 흐름**: Working Directory → Staging Area → Repository

### Git vs GitHub
| 구분 | Git | GitHub |
|------|-----|--------|
| **역할** | 버전 관리 도구 | Git 호스팅 서비스 |
| **위치** | 로컬 | 클라우드 |
| **기능** | 기본 Git 기능 | 협업, 이슈, PR, Actions |

</details>

<details>
<summary>🔗 Git 기본 명령어</summary>

### 기본 워크플로우
```bash
# 저장소 초기화
git init

# 파일 추가
git add .

# 커밋
git commit -m "Initial commit"

# 원격 저장소 연결
git remote add origin https://github.com/username/repo.git

# 푸시
git push -u origin main
```

### 브랜치 관리
```bash
# 브랜치 목록 확인
git branch

# 새 브랜치 생성
git checkout -b feature/new-feature

# 브랜치 전환
git checkout main

# 브랜치 병합
git merge feature/new-feature

# 브랜치 삭제
git branch -d feature/new-feature
```

</details>

<details>
<summary>🔗 GitHub 협업</summary>

### Pull Request 워크플로우
1. **브랜치 생성**: `git checkout -b feature/new-feature`
2. **코드 작성**: 기능 개발
3. **커밋 및 푸시**: `git commit -m "Add new feature"` → `git push origin feature/new-feature`
4. **Pull Request 생성**: GitHub에서 PR 생성
5. **코드 리뷰**: 팀원이 코드 검토
6. **병합**: 승인 후 main 브랜치에 병합

### 이슈 관리
- **버그 리포트**: 버그 발견 시 이슈 생성
- **기능 요청**: 새로운 기능 제안
- **문서화**: 프로젝트 문서 개선
- **라벨링**: 이슈 분류 및 우선순위 설정

</details>

---

## 🚀 GitHub Actions CI/CD 파이프라인

<details>
<summary>📖 GitHub Actions 개념</summary>

### GitHub Actions란?
- **정의**: GitHub에서 제공하는 CI/CD 플랫폼
- **특징**: 자동화, 통합, 확장성, 무료
- **구성 요소**: Workflow, Job, Step, Action

### CI/CD 파이프라인
- **CI (Continuous Integration)**: 코드 통합 및 테스트
- **CD (Continuous Deployment)**: 자동 배포
- **장점**: 품질 향상, 배포 자동화, 팀 협업

</details>

<details>
<summary>🔗 기본 워크플로우 작성</summary>

### .github/workflows/ci.yml
```yaml
name: CI Pipeline

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    
    steps:
    - name: Checkout code
      uses: actions/checkout@v4
      
    - name: Setup Node.js
      uses: actions/setup-node@v4
      with:
        node-version: '18'
        cache: 'npm'
        
    - name: Install dependencies
      run: npm ci
      
    - name: Run tests
      run: npm test
      
    - name: Run linting
      run: npm run lint
```

### .github/workflows/deploy.yml
```yaml
name: Deploy to Docker Hub

on:
  push:
    branches: [ main ]
  tags:
    - 'v*'

jobs:
  deploy:
    runs-on: ubuntu-latest
    
    steps:
    - name: Checkout code
      uses: actions/checkout@v4
      
    - name: Set up Docker Buildx
      uses: docker/setup-buildx-action@v3
      
    - name: Login to Docker Hub
      uses: docker/login-action@v3
      with:
        username: ${{ secrets.DOCKERHUB_USERNAME }}
        password: ${{ secrets.DOCKERHUB_TOKEN }}
        
    - name: Build and push
      uses: docker/build-push-action@v5
      with:
        context: .
        push: true
        tags: ${{ secrets.DOCKERHUB_USERNAME }}/my-app:latest
```

</details>

<details>
<summary>🔗 고급 워크플로우</summary>

### 환경별 배포
```yaml
name: Deploy to Environment

on:
  push:
    branches: [ main, develop ]

jobs:
  deploy:
    runs-on: ubuntu-latest
    environment: ${{ github.ref == 'refs/heads/main' && 'production' || 'staging' }}
    
    steps:
    - name: Deploy to Staging
      if: github.ref == 'refs/heads/develop'
      run: echo "Deploying to staging"
      
    - name: Deploy to Production
      if: github.ref == 'refs/heads/main'
      run: echo "Deploying to production"
```

### 매트릭스 빌드
```yaml
name: Matrix Build

on: [push]

jobs:
  build:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        node-version: [16, 18, 20]
        
    steps:
    - uses: actions/checkout@v4
    - name: Setup Node.js ${{ matrix.node-version }}
      uses: actions/setup-node@v4
      with:
        node-version: ${{ matrix.node-version }}
    - run: npm test
```

</details>

---

## ☁️ VM 기반 웹 애플리케이션 배포

<details>
<summary>📖 VM 배포 전략</summary>

### 배포 방식 비교
| 구분 | Docker | 직접 배포 |
|------|--------|-----------|
| **일관성** | 높음 | 낮음 |
| **이식성** | 높음 | 낮음 |
| **관리** | 쉬움 | 어려움 |
| **성능** | 약간 오버헤드 | 최적 |

### 배포 환경
- **AWS EC2**: Linux 인스턴스 + Docker
- **GCP Compute Engine**: Linux 인스턴스 + Docker
- **로드 밸런서**: 트래픽 분산
- **도메인**: 사용자 친화적 URL

</details>

<details>
<summary>🔗 AWS EC2 배포</summary>

### 1단계: EC2 인스턴스 생성
```bash
# EC2 인스턴스 생성
aws ec2 run-instances \
    --image-id ami-0ae2c887094315bed \
    --count 1 \
    --instance-type t3.micro \
    --key-name student-key \
    --security-group-ids sg-xxxxxxxx \
    --subnet-id subnet-xxxxxxxx \
    --user-data file://user-data.sh
```

### 2단계: Docker 설치 (user-data.sh)
```bash
#!/bin/bash
# Docker 설치
yum update -y
yum install -y docker
systemctl start docker
systemctl enable docker
usermod -a -G docker ec2-user

# Docker Compose 설치
curl -L "https://github.com/docker/compose/releases/download/v2.20.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
```

### 3단계: 애플리케이션 배포
```bash
# SSH 접속
ssh -i student-key.pem ec2-user@YOUR_EC2_IP

# Docker 이미지 풀
docker pull your-username/my-app:latest

# 컨테이너 실행
docker run -d -p 80:3000 --name my-app your-username/my-app:latest
```

</details>

<details>
<summary>🔗 GCP Compute Engine 배포</summary>

### 1단계: Compute Engine 인스턴스 생성
```bash
# 인스턴스 생성
gcloud compute instances create my-app-instance \
    --zone=asia-northeast3-a \
    --machine-type=e2-medium \
    --image-family=ubuntu-2004-lts \
    --image-project=ubuntu-os-cloud \
    --boot-disk-size=10GB \
    --metadata-from-file startup-script=startup-script.sh
```

### 2단계: Docker 설치 (startup-script.sh)
```bash
#!/bin/bash
# Docker 설치
apt-get update
apt-get install -y docker.io docker-compose
systemctl start docker
systemctl enable docker
usermod -a -G docker $USER
```

### 3단계: 애플리케이션 배포
```bash
# SSH 접속
gcloud compute ssh my-app-instance --zone=asia-northeast3-a

# Docker 이미지 풀
docker pull your-username/my-app:latest

# 컨테이너 실행
docker run -d -p 80:3000 --name my-app your-username/my-app:latest
```

</details>

<details>
<summary>🔗 자동화된 배포</summary>

### GitHub Actions를 통한 자동 배포
```yaml
name: Deploy to VM

on:
  push:
    branches: [ main ]

jobs:
  deploy:
    runs-on: ubuntu-latest
    
    steps:
    - name: Deploy to AWS EC2
      uses: appleboy/ssh-action@v1.0.0
      with:
        host: ${{ secrets.EC2_HOST }}
        username: ${{ secrets.EC2_USERNAME }}
        key: ${{ secrets.EC2_SSH_KEY }}
        script: |
          docker pull ${{ secrets.DOCKERHUB_USERNAME }}/my-app:latest
          docker stop my-app || true
          docker rm my-app || true
          docker run -d -p 80:3000 --name my-app ${{ secrets.DOCKERHUB_USERNAME }}/my-app:latest
```

</details>

---

## 📚 문제 해결 및 참고 자료

<details>
<summary>🐛 자주 발생하는 문제</summary>

### Docker 관련 문제
<details>
<summary>❌ Docker 이미지 빌드 실패</summary>

**원인**: 
- Dockerfile 문법 오류
- 의존성 설치 실패
- 권한 문제

**해결방법**:
```bash
# 1. Dockerfile 문법 검사
docker build --no-cache -t my-app .

# 2. 빌드 로그 확인
docker build --progress=plain -t my-app .

# 3. 권한 확인
docker run --rm -v $(pwd):/app -w /app node:18-alpine sh -c "ls -la"
```

</details>

<details>
<summary>❌ Docker 컨테이너 실행 실패</summary>

**원인**:
- 포트 충돌
- 환경 변수 누락
- 이미지 없음

**해결방법**:
```bash
# 1. 포트 확인
docker ps -a
netstat -tulpn | grep :3000

# 2. 환경 변수 확인
docker run -e NODE_ENV=production my-app

# 3. 이미지 확인
docker images | grep my-app
```

</details>

### Git/GitHub 관련 문제
<details>
<summary>❌ Git 푸시 실패</summary>

**원인**:
- 인증 실패
- 권한 부족
- 브랜치 충돌

**해결방법**:
```bash
# 1. 인증 확인
git remote -v
git config --list | grep user

# 2. SSH 키 확인
ssh -T git@github.com

# 3. 브랜치 동기화
git pull origin main
git push origin main
```

</details>

<details>
<summary>❌ GitHub Actions 실행 실패</summary>

**원인**:
- 시크릿 설정 누락
- YAML 문법 오류
- 권한 부족

**해결방법**:
1. GitHub Secrets 확인
2. YAML 문법 검사
3. 워크플로우 권한 확인

</details>

</details>

<details>
<summary>📖 추가 학습 자료</summary>

### 공식 문서
- [Docker 공식 문서](https://docs.docker.com/)
- [Git 공식 문서](https://git-scm.com/doc)
- [GitHub Actions 공식 문서](https://docs.github.com/en/actions)
- [AWS EC2 공식 문서](https://docs.aws.amazon.com/ec2/)
- [GCP Compute Engine 공식 문서](https://cloud.google.com/compute/docs)

### 유용한 리소스
- [Docker Hub](https://hub.docker.com/)
- [GitHub Marketplace](https://github.com/marketplace?type=actions)
- [Docker Compose 예제](https://docs.docker.com/compose/gettingstarted/)
- [GitHub Actions 예제](https://github.com/actions/starter-workflows)

### 관련 프로젝트
- [Docker 샘플 프로젝트](https://github.com/docker/awesome-compose)
- [GitHub Actions 샘플](https://github.com/actions/starter-workflows)

</details>

<details>
<summary>🚀 다음 단계</summary>

### Cloud Master 과정 준비
1. **고급 Docker**: 멀티스테이지 빌드, 최적화
2. **고급 GitHub Actions**: 매트릭스 빌드, 환경별 배포
3. **로드 밸런싱**: ELB, Cloud Load Balancing
4. **모니터링**: CloudWatch, Cloud Monitoring

### 실무 적용
1. **팀 프로젝트**: 실제 프로젝트에 CI/CD 적용
2. **자동화**: 배포 파이프라인 고도화
3. **보안**: 시크릿 관리, 권한 최적화
4. **성능**: 컨테이너 최적화, 리소스 관리

</details>

---

## 🎉 완료!

축하합니다! Cloud Intermediate 1일차 실습을 완료했습니다.

### 📚 학습 요약

이번 실습을 통해 다음을 배웠습니다:

1. **🐳 Docker 기초**: 컨테이너 기술 및 Dockerfile 작성
2. **📝 Git/GitHub**: 버전 관리 및 협업 도구 사용
3. **🚀 GitHub Actions**: CI/CD 파이프라인 구축
4. **☁️ VM 배포**: AWS EC2, GCP Compute Engine 배포

### 🚀 다음 단계

- **Cloud Master 과정**: 고급 CI/CD, 로드 밸런싱, 모니터링
- **실제 프로젝트 적용**: 자신의 프로젝트에 CI/CD 파이프라인 구축
- **고급 기능 학습**: 자동화, 보안, 성능 최적화

### 💡 추가 학습 자료

- [Docker 공식 문서](https://docs.docker.com/)
- [GitHub Actions 공식 문서](https://docs.github.com/en/actions)
- [Cloud Master 과정](../cloud_master/textbook/Day1/README.md)

---

**🎯 이제 Docker, Git/GitHub, GitHub Actions의 기본기를 갖추었습니다! Cloud Master 과정으로 진행하세요.**
