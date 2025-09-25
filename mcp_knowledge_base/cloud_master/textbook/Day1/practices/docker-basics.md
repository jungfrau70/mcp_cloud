# Cloud Master - 1일차: Docker, Git/GitHub, GitHub Actions 이론 및 실습

<details>
<summary>📋 목차</summary>

["📚 이론 학습"]["#이론-학습"]

["🛠️ 실습 학습"]["#실습-학습"]

["📚 참고 자료"][#-]

["📚 문제 해결 및 참고 자료"]["#문제-해결-및-참고-자료"]


</details>

---

## 🎯 학습 목표

### 핵심 학습 목표

- **Docker 기초** 컨테이너 개념 및 Dockerfile 작성
- **Git/GitHub 기초** 버전 관리 및 협업 도구 사용법
- **GitHub Actions 기초** CI/CD 파이프라인 구축
- **VM 배포** AWS EC2, GCP Compute Engine 웹 애플리케이션 배포

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

## 📚 이론 학습

<details>
<summary>🐳 Docker 기초 및 컨테이너 기술</summary>

#### Docker란?

Docker는 애플리케이션을 컨테이너라는 경량화된, 이식 가능한 패키지로 패키징하여 어디서나 일관된 환경에서 실행할 수 있게 해주는 플랫폼입니다.

#### 컨테이너 기술의 역사와 발전

- **LXC [Linux Containers]**: 2008년 처음 등장한 리눅스 컨테이너 기술
- **Docker의 등장**: 2013년 컨테이너 기술을 대중화시킨 플랫폼
- **Kubernetes**: 2014년 구글이 개발한 컨테이너 오케스트레이션 도구
- **현재**: 클라우드 네이티브 애플리케이션의 표준 기술

#### 컨테이너 vs 가상머신

| 특징 | 컨테이너 | 가상머신 |
|------|----------|----------|
| **오버헤드** | 낮음 | 높음 |
| **시작 시간** | 빠름 ["초 단위"] | 느림 ["분 단위"] |
| **리소스 사용량** | 적음 | 많음 |
| **격리 수준** | 프로세스 레벨 | 하드웨어 레벨 |
| **이식성** | 높음 | 중간 |

- **가상머신**: 하이퍼바이저 + 게스트 OS + 애플리케이션
- **컨테이너**: 컨테이너 엔진 + 애플리케이션 ["OS 커널 공유"]
- **리소스 효율성**: 컨테이너가 VM보다 3-5배 가볍고 빠름
- **격리 수준**: VM이 더 강하지만 컨테이너도 충분한 격리 제공

#### Docker 핵심 개념

- **이미지 [Image]**: 애플리케이션과 실행 환경을 포함한 읽기 전용 템플릿
- **컨테이너 [Container]**: 이미지를 실행한 인스턴스
- **Dockerfile**: 이미지를 빌드하기 위한 명령어 집합
- **레지스트리 [Registry]**: Docker 이미지를 저장하고 공유하는 서비스

#### Docker 아키텍처의 핵심 구성요소

- **Docker Engine**: 컨테이너를 실행하는 런타임
- **Docker Daemon**: 백그라운드에서 실행되는 서비스
- **Docker Client**: 사용자와 데몬 간의 인터페이스
- **Docker Registry**: 이미지 저장소 [Docker Hub, AWS ECR, GCP GCR]

#### Docker 모범 사례

- **멀티스테이지 빌드**: 최종 이미지 크기 최적화
- **레이어 캐싱**: 빌드 속도 향상을 위한 의존성 우선 설치
- **보안**: root 사용자 사용 금지, 최소 권한 원칙
- **이미지 최적화**: 불필요한 파일 제거, .dockerignore 사용

#### Docker 네트워킹

- **Bridge 네트워크**: 기본 네트워크, 컨테이너 간 통신
- **Host 네트워크**: 호스트 네트워크 직접 사용
- **Overlay 네트워크**: 여러 호스트 간 컨테이너 통신
- **Custom 네트워크**: 사용자 정의 네트워크 생성

#### Docker 볼륨 관리

- **Named Volume**: Docker가 관리하는 영구 스토리지
- **Bind Mount**: 호스트 디렉토리를 컨테이너에 마운트
- **tmpfs Mount**: 메모리 기반 임시 파일시스템
- **Volume Driver**: 외부 스토리지 시스템 연동


</details>

<details>
<summary>📝 Git/GitHub 기초 및 협업</summary>

#### Git이란?

Git은 분산 버전 관리 시스템으로, 소스 코드의 변경사항을 추적하고 관리하는 도구입니다.

#### Git 핵심 개념

- **저장소 [Repository]**: 프로젝트의 모든 파일과 변경 이력이 저장되는 공간
- **커밋 [Commit]**: 특정 시점의 파일 상태를 저장하는 스냅샷
- **브랜치 [Branch]**: 독립적인 개발 라인
- **머지 [Merge]**: 브랜치를 다른 브랜치와 합치는 작업

#### GitHub이란?

GitHub은 Git 저장소를 호스팅하고 협업을 지원하는 웹 기반 플랫폼입니다.

#### GitHub 핵심 기능

- **Pull Request**: 코드 리뷰 및 협업
- **Issues**: 버그 추적 및 기능 요청
- **Actions**: CI/CD 자동화
- **Wiki**: 프로젝트 문서화

#### Git 워크플로우

1. **Feature Branch**: 새로운 기능 개발을 위한 브랜치 생성
2. **Commit**: 변경사항을 로컬에 커밋
3. **Push**: 원격 저장소에 변경사항 업로드
4. **Pull Request**: 코드 리뷰 요청
5. **Merge**: 승인 후 메인 브랜치에 병합

</details>

<details>
<summary>🚀 GitHub Actions CI/CD 이론</summary>

#### CI/CD란?

- **CI [Continuous Integration]**: 지속적 통합 - 코드 변경사항을 자주 통합하고 테스트
- **CD [Continuous Deployment]**: 지속적 배포 - 자동화된 배포 파이프라인

#### GitHub Actions란?

["GitHub Actions란?"]["#github-actions란"]
GitHub Actions는 GitHub 저장소에서 직접 CI/CD 워크플로우를 구축할 수 있는 자동화 플랫폼입니다.

#### GitHub Actions 핵심 개념

- **워크플로우 [Workflow]**: 자동화된 프로세스 정의
- **이벤트 [Event]**: 워크플로우를 트리거하는 활동
- **작업 [Job]**: 워크플로우 내의 실행 단위
- **스텝 [Step]**: 작업 내의 개별 작업 단위
- **액션 [Action]**: 재사용 가능한 작업 단위

#### CI/CD 파이프라인 단계

["CI/CD 파이프라인 단계"]["#cicd-파이프라인-단계"]
1. **코드 빌드**: 소스 코드 컴파일 및 패키징
2. **테스트 실행**: 단위 테스트, 통합 테스트, E2E 테스트
3. **코드 품질 검사**: 정적 분석, 보안 스캔
4. **이미지 빌드**: Docker 이미지 생성
5. **배포**: 스테이징/프로덕션 환경에 배포

#### GitHub Actions 장점

- **무료**: 퍼블릭 저장소는 무료 사용
- **통합성**: GitHub과 완벽 통합
- **확장성**: 다양한 액션과 커뮤니티 지원
- **유연성**: 복잡한 워크플로우 구성 가능

</details>

<details>
<summary>🚀 VM 기반 웹 애플리케이션 배포 이론</summary>

#### VM 배포란?

가상머신[VM]에 웹 애플리케이션을 배포하여 인터넷을 통해 접근 가능하게 하는 과정입니다.

#### AWS EC2 배포

- **인스턴스 생성**: 적절한 인스턴스 타입 선택
- **보안 그룹 설정**: 네트워크 접근 제어
- **키 페어 설정**: SSH 접근을 위한 키 관리
- **사용자 데이터**: 인스턴스 시작 시 실행할 스크립트

#### GCP Compute Engine 배포

- **VM 인스턴스 생성**: 머신 타입 및 이미지 선택
- **방화벽 규칙 설정**: 네트워크 트래픽 제어
- **SSH 키 설정**: 인스턴스 접근을 위한 키 관리
- **시작 스크립트**: VM 시작 시 실행할 명령어

#### 배포 전략

- **Blue-Green 배포**: 두 환경을 번갈아가며 배포
- **Rolling 배포**: 점진적으로 인스턴스 교체
- **Canary 배포**: 소규모 트래픽으로 테스트 후 전체 배포

#### 모니터링 및 로깅

- **CloudWatch [AWS]**: 메트릭, 로그, 알람
- **Cloud Monitoring [GCP]**: 성능 모니터링, 로그 분석
- **헬스 체크**: 애플리케이션 상태 모니터링
- **자동 스케일링**: 트래픽에 따른 인스턴스 자동 조정

</details>

---

## 🛠️ 실습 학습

### 📁 실습 코드 및 자동화
- **실습 샘플 코드**: `/mcp_knowledge_base/cloud_master/repos/samples/day1/my-app/`
- **자동화 스크립트**: `/mcp_knowledge_base/cloud_master/repos/automation/day1/docker-practice-automation.sh`
- **클라우드 스크립트**: `/mcp_knowledge_base/cloud_master/repos/cloud-scripts/`

<details>
<summary>🚀 실습 환경 준비</summary>

#### 필수 계정

- **AWS 계정**: Free Tier 계정 ["Cloud Basic에서 생성"]
- **GCP 계정**: $300 크레딧 계정 ["Cloud Basic에서 생성"]
- **GitHub 계정**: 코드 저장소 및 Actions 사용
- **Docker Hub 계정**: 컨테이너 이미지 저장소 ["선택사항"]

#### 필수 도구

- **Docker Desktop**: 컨테이너 실행 환경
- **Git**: 버전 관리 도구
- **VS Code**: 코드 편집기 ["권장"]
- **AWS CLI**: AWS 서비스 관리 ["Cloud Basic에서 설치"]
- **gcloud CLI**: Google Cloud 서비스 관리 ["Cloud Basic에서 설치"]


#### 필수 완료 사항

- [ ] AWS Free Tier 계정 생성 및 설정
- [ ] GCP $300 크레딧 계정 생성 및 설정
- [ ] AWS CLI 및 gcloud CLI 설치 및 인증
- [ ] IAM 사용자/서비스 계정 생성
- [ ] EC2/Compute Engine 인스턴스 생성 경험
- [ ] S3/Cloud Storage 버킷 생성 경험

### 실습 환경 확인

```bash
# AWS CLI 설정 확인
aws sts get-caller-identity

# gcloud 설정 확인
gcloud auth list

# Docker 설치 확인
docker --version
docker-compose --version

# Git 설치 확인
git --version
```

</details>

<details>
<summary>🔗 실습 가이드</summary>

### 실습 구성

1. **Docker 기초 및 컨테이너 기술** ["120분"]
2. **Git/GitHub 기초 및 협업** ["90분"]
3. **GitHub Actions CI/CD 파이프라인** ["120분"]
4. **VM 기반 웹 애플리케이션 배포** ["120분"]

### 실습 방식

- **Docker 기초**: 컨테이너 개념, Dockerfile 작성, Docker Compose
- **Git/GitHub 기초**: 버전 관리, 브랜치 전략, Pull Request
- **GitHub Actions 기초**: 워크플로우 작성, 자동 빌드/배포
- **VM 배포**: AWS EC2, GCP Compute Engine 웹 애플리케이션 배포

### 실습 결과물

- 컨테이너화된 웹 애플리케이션
- Git/GitHub 저장소 및 협업 환경
- GitHub Actions CI/CD 파이프라인
- VM에 배포된 웹 애플리케이션

### 📖 상세 실습 가이드

- 🔗 ["Docker 기초 실습"][docker-basics.md] - Docker 기본 개념 및 실습
- 🔗 ["Git/GitHub 기초 실습"][git-github-basics.md] - 버전 관리 및 협업
- 🔗 ["GitHub Actions 기초 실습"][github-actions-basics.md] - CI/CD 파이프라인 구축
- 🔗 ["VM 배포 실습"][vm-deployment.md] - AWS EC2, GCP Compute Engine 배포

### 📚 개념 학습 가이드

- 🔗 ["Docker 고급 가이드"][cloud_master/textbook/Day1/guides/docker-advanced-guide.md] - 멀티스테이지 빌드, 이미지 최적화
- 🔗 ["Docker Compose 가이드"][cloud_master/textbook/Day1/guides/docker-compose-guide.md] - 다중 서비스 관리
- 🔗 ["GitHub Actions 가이드"][cloud_master/textbook/Day1/guides/github-actions-guide.md] - CI/CD 파이프라인 구축
- 🔗 ["AWS & GCP 배포 가이드"][cloud_master/textbook/Day1/guides/aws-gcp-deployment-guide.md] - 멀티클라우드 배포

### 🛠️ 문제 해결 가이드

- 🔗 ["종합 트러블슈팅 가이드"][cloud_basic/textbook/Day1/troubleshooting-guide.md] - Docker, GitHub Actions, AWS/GCP 문제 해결
- 🔗 ["AWS & GCP 권한 설정"][aws-gcp-permissions-setup.md] - IAM, 서비스 계정 설정
- 🔗 ["CI/CD 파이프라인 가이드"][cloud_master/textbook/Day1/guides/cicd-pipeline-guide.md] - 전체 자동 배포 파이프라인
- 🔗 ["클라우드 배포 가이드"][cloud_master/textbook/Day1/guides/cloud-deployment-guide.md] - VM 기반 웹 애플리케이션 배포

### 🔗 관련 과정 링크

- 🔗 ["Cloud Basic 과정"][cloud_basic/README.md] - AWS/GCP 기초 과정
- 🔗 ["Cloud Container 과정"][cloud_container/README.md] - Kubernetes 고급 과정
- 🔗 ["전체 커리큘럼"][curriculum.md] - 전체 과정 구조 및 학습 경로
- 🔗 ["통합 인덱스"][index.md] - 전체 과정 인덱스
- 🔗 ["학습 경로로 돌아가기"][learning-path.md] - Cloud Master 학습 경로

</details>

<details>
<summary>🚀 Docker 기초 실습</summary>

<details>
<summary>🚀 Docker 설치 확인</summary>


```bash
# Docker 버전 확인
docker --version
docker-compose --version

# Docker 실행 상태 확인
docker info
```

### 기본 명령어 실습

```bash
# Hello World 컨테이너 실행
docker run hello-world

# 실행 중인 컨테이너 확인
docker ps

# 모든 컨테이너 확인 ["중지된 것 포함"]
docker ps -a

# 이미지 목록 확인
docker images

# 컨테이너 중지
docker stop <container_id>

# 컨테이너 삭제
docker rm <container_id>

# 이미지 삭제
docker rmi <image_id>
```

## 🔗 Dockerfile 작성 실습</summary>

### 간단한 Node.js 애플리케이션 Dockerfile

```dockerfile
# Node.js 18 버전을 베이스 이미지로 사용
FROM node:18

# 작업 디렉토리 설정
WORKDIR /app

# 패키지 파일 복사 ["캐시 최적화를 위해 의존성 설치를 먼저"]
COPY package*.json ./

# 의존성 설치
RUN npm install

# 소스 코드 복사
COPY . .

# 포트 3000 노출
EXPOSE 3000

# 애플리케이션 시작
CMD ["npm", "start"]
```

### Dockerfile 빌드 및 실행

```bash
# 이미지 빌드
docker build -t my-node-app .

# 컨테이너 실행
docker run -p 3000:3000 my-node-app

# 백그라운드 실행
docker run -d -p 3000:3000 --name my-app my-node-app

# 컨테이너 로그 확인
docker logs my-app

# 컨테이너 내부 접속
docker exec -it my-app /bin/bash
```

</details>

<details>
<summary>📖 Docker 기본 명령어</summary>

```bash
# 이미지 관리
docker pull <image>          # 이미지 다운로드
docker images               # 이미지 목록 확인
docker rmi <image>          # 이미지 삭제

# 컨테이너 관리
docker run <image>          # 컨테이너 실행
docker ps                   # 실행 중인 컨테이너 확인
docker stop <container>     # 컨테이너 중지
docker rm <container>       # 컨테이너 삭제

# 빌드 및 실행
docker build -t <name> .    # Dockerfile로 이미지 빌드
docker exec -it <container> /bin/bash  # 컨테이너 내부 접속
```
</details>

<details>
<summary>🚀 Dockerfile 기본 구조</summary>

```dockerfile
# 베이스 이미지
FROM node:18-alpine

# 작업 디렉토리 설정
WORKDIR /app

# 의존성 파일 복사
COPY package*.json ./

# 의존성 설치
RUN npm install

# 애플리케이션 코드 복사
COPY . .

# 포트 노출
EXPOSE 3000

# 애플리케이션 실행
CMD ["npm", "start"]
```
</details>

<details>
<summary>🚀 Docker Compose 기본 구조</summary>

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
  
  db:
    image: postgres:13
    environment:
      - POSTGRES_DB=myapp
      - POSTGRES_PASSWORD=password
    volumes:
      - postgres_data:/var/lib/postgresql/data

volumes:
  postgres_data:
```

</details>

<details>
<summary>🔗 Docker Compose 실습</summary>

### docker-compose.yml 작성

```yaml
version: '3.8'

services:
  # 웹 애플리케이션 서비스
  web:
    build: .
    ports:
      - "3000:3000"
    volumes:
      - ./:/app
      - /app/node_modules
    environment:
      - NODE_ENV=development
    depends_on:
      - db
    restart: unless-stopped

  # MongoDB 데이터베이스 서비스
  db:
    image: mongo:6.0
    ports:
      - "27017:27017"
    environment:
      - MONGO_INITDB_ROOT_USERNAME=admin
      - MONGO_INITDB_ROOT_PASSWORD=secret
    volumes:
      - mongodb_data:/data/db
    restart: unless-stopped

# 볼륨 정의
volumes:
  mongodb_data:
```

### Docker Compose 명령어

```bash
# 서비스 시작
docker-compose up

# 백그라운드에서 시작
docker-compose up -d

# 서비스 중지
docker-compose down

# 볼륨까지 삭제
docker-compose down -v

# 로그 확인
docker-compose logs

# 특정 서비스 로그 확인
docker-compose logs web
```

</details>
</details>

<details>
<summary>🚀 Git/GitHub 기초 및 협업</summary>

<details>
<summary>📖 Git 개념 이해</summary>

### Git이란?

- **정의**: 분산 버전 관리 시스템
- **장점**: 오프라인 작업 가능, 브랜치 관리 용이, 협업 효율성
- **핵심 개념**: 커밋, 브랜치, 머지, 리모트 저장소

### Git 워크플로우

1. **Working Directory**: 작업 중인 파일들
2. **Staging Area**: 커밋할 준비가 된 파일들
3. **Repository**: 커밋된 파일들의 히스토리

</details>

<details>
<summary>🔗 Git 기본 명령어 실습</summary>

### Git 설정

```bash
# 사용자 정보 설정
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"

# 설정 확인
git config --list
```

### 기본 워크플로우

```bash
# 저장소 초기화
git init

# 파일 상태 확인
git status

# 파일 추가 ["Staging Area에"]
git add filename.txt
git add .  # 모든 파일 추가

# 커밋 생성
git commit -m "Initial commit"

# 커밋 히스토리 확인
git log
git log --oneline  # 한 줄로 표시
```

### 브랜치 관리

```bash
# 브랜치 목록 확인
git branch

# 새 브랜치 생성 및 이동
git checkout -b feature/new-feature
git switch -c feature/new-feature  # Git 2.23+

# 브랜치 이동
git checkout main
git switch main

# 브랜치 머지
git checkout main
git merge feature/new-feature

# 브랜치 삭제
git branch -d feature/new-feature
```

</details>

<details>
<summary>🔗 GitHub 협업 실습</summary>

### GitHub 저장소 생성 및 연결

["GitHub 저장소 생성 및 연결"]["#github-저장소-생성-및-연결"]
```bash
# 원격 저장소 추가
git remote add origin https:///github.com/[username]/[repository_name].git

# 원격 저장소 확인
git remote -v

# 첫 푸시
git push -u origin main

# 이후 푸시
git push
```

### Pull Request 워크플로우

```bash
# 1. 새 브랜치에서 작업
git checkout -b feature/awesome-feature

# 2. 변경사항 커밋
git add .
git commit -m "Add awesome feature"

# 3. 브랜치 푸시
git push origin feature/awesome-feature

# 4. GitHub에서 Pull Request 생성
# 5. 리뷰 후 머지
# 6. 로컬에서 브랜치 정리
git checkout main
git pull origin main
git branch -d feature/awesome-feature
```

### 협업 시나리오

```bash
# 다른 사람의 변경사항 가져오기
git fetch origin
git merge origin/main

# 또는 한 번에
git pull origin main

# 충돌 해결 후
git add .
git commit -m "Resolve merge conflict"
git push
```

</details>
</details>

<details>
<summary>🚀 GitHub Actions CI/CD 파이프라인</summary>

<details>
<summary>📖 GitHub Actions 개념</summary>

### GitHub Actions란?

- **정의**: GitHub에서 제공하는 CI/CD 플랫폼
- **장점**: GitHub과 완벽 통합, 무료 사용량 제공, 다양한 액션 활용
- **핵심 개념**: Workflow, Job, Step, Action

### CI/CD 파이프라인

- **CI [Continuous Integration]**: 코드 변경사항을 자동으로 빌드하고 테스트
- **CD [Continuous Deployment]**: 테스트 통과한 코드를 자동으로 배포

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
      uses: actions/checkout@v3
      
    - name: Setup Node.js
      uses: actions/setup-node@v3
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
name: Deploy to VM

on:
  push:
    branches: [ main ]

jobs:
  deploy:
    runs-on: ubuntu-latest
    
    steps:
    - name: Checkout code
      uses: actions/checkout@v3
      
    - name: Setup Node.js
      uses: actions/setup-node@v3
      with:
        node-version: '18'
        
    - name: Install dependencies
      run: npm ci
      
    - name: Build application
      run: npm run build
      
    - name: Deploy to VM
      uses: appleboy/ssh-action@v0.1.5
      with:
        host: ${{ secrets.AWS_VM_HOST }}
        username: ${{ secrets.AWS_VM_USERNAME }}
        key: ${{ secrets.AWS_VM_SSH_KEY }}
        script: |
          cd /home/ubuntu/app
          git pull origin main
          docker-compose down
          docker-compose up -d --build
```

</details>

<details>
<summary>🔗 Docker 이미지 자동 빌드</summary>

### Docker 이미지 빌드 워크플로우

```yaml
name: Build and Push Docker Image

on:
  push:
    branches: [ main ]
    tags: [ 'v*' ]

jobs:
  build:
    runs-on: ubuntu-latest
    
    steps:
    - name: Checkout code
      uses: actions/checkout@v3
      
    - name: Set up Docker Buildx
      uses: docker/setup-buildx-action@v2
      
    - name: Login to Docker Hub
      uses: docker/login-action@v2
      with:
        username: ${{ secrets.DOCKER_USERNAME }}
        password: ${{ secrets.DOCKER_PASSWORD }}
        
    - name: Extract metadata
      id: meta
      uses: docker/metadata-action@v4
      with:
        images: ${{ secrets.DOCKER_USERNAME }}/my-app
        tags: |
          type=ref,event=branch
          type=ref,event=pr
          type=semver,pattern={{version}}
          type=semver,pattern={{major}}.{{minor}}
          
    - name: Build and push
      uses: docker/build-push-action@v4
      with:
        context: .
        push: true
        tags: ${{ steps.meta.outputs.tags }}
        labels: ${{ steps.meta.outputs.labels }}
```

</details>

</details>

---

<details>
<summary>🚀 VM 기반 웹 애플리케이션 배포</summary>

<details>
<summary>📖 VM 배포 개념</summary>

### VM 배포의 장점

- **간단함**: 복잡한 오케스트레이션 없이 직접 배포
- **제어**: 완전한 서버 제어권
- **비용**: 소규모 애플리케이션에 경제적
- **학습**: 클라우드 기본 개념 이해에 유용

### 배포 전략

- **Blue-Green**: 무중단 배포
- **Rolling**: 점진적 배포
- **Canary**: 일부 트래픽으로 테스트

</details>

<details>
<summary>🔗 AWS EC2 배포 실습</summary>

### EC2 인스턴스 생성

```bash
# AWS CLI로 EC2 인스턴스 생성
aws ec2 run-instances /
  --image-id ami-0ae2c887094315bed /
  --count 1 /
  --instance-type t3.micro /
  --key-name my-key /
  --security-group-ids sg-12345678 /
  --subnet-id subnet-12345678 /
  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=my-web-app}]'
```

### 애플리케이션 배포

```bash
# SSH로 인스턴스 접속
ssh -i my-key.pem ec2-user@<public-ip>

# Docker 설치
sudo yum update -y
sudo yum install -y docker
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -a -G docker ec2-user

# 애플리케이션 클론
git clone https:///github.com/[username]/my-app.git
cd my-app

# Docker Compose로 실행
docker-compose up -d
```

</details>

<details>
<summary>🔗 GCP Compute Engine 배포 실습</summary>

### Compute Engine 인스턴스 생성

```bash
# gcloud CLI로 인스턴스 생성
gcloud compute instances create my-web-app /
  --zone=asia-northeast3-a /
  --machine-type=e2-micro /
  --image-family=ubuntu-2004-lts /
  --image-project=ubuntu-os-cloud /
  --tags=http-server,https-server /
  --metadata-from-file startup-script=startup-script.sh
```

### 방화벽 규칙 설정

["방화벽 규칙 설정"]["#방화벽-규칙-설정"]
```bash
# HTTP 트래픽 허용
gcloud compute firewall-rules create allow-http /
  --allow tcp:80 /
  --source-ranges 0.0.0.0/0 /
  --target-tags http-server

# HTTPS 트래픽 허용
gcloud compute firewall-rules create allow-https /
  --allow tcp:443 /
  --source-ranges 0.0.0.0/0 /
  --target-tags https-server
```

</details>

<details>
<summary>🔗 자동화된 배포 파이프라인</summary>

### 완전 자동화된 배포

```yaml
name: Deploy to VM

on:
  push:
    branches: [ main ]

jobs:
  deploy:
    runs-on: ubuntu-latest
    
    steps:
    - name: Checkout code
      uses: actions/checkout@v3
      
    - name: Deploy to AWS EC2
      uses: appleboy/ssh-action@v0.1.5
      with:
        host: ${{ secrets.AWS_HOST }}
        username: ${{ secrets.AWS_USERNAME }}
        key: ${{ secrets.AWS_SSH_KEY }}
        script: |
          cd /home/ec2-user/my-app
          git pull origin main
          docker-compose down
          docker-compose up -d --build
          
    - name: Deploy to GCP Compute Engine
      uses: appleboy/ssh-action@v0.1.5
      with:
        host: ${{ secrets.GCP_HOST }}
        username: ${{ secrets.GCP_USERNAME }}
        key: ${{ secrets.GCP_SSH_KEY }}
        script: |
          cd /home/ubuntu/my-app
          git pull origin main
          docker-compose down
          docker-compose up -d --build
```

</details>
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
- 컨텍스트 경로 문제

**해결방법**:
```bash
# 1. Dockerfile 문법 확인
docker build --no-cache -t my-app .

# 2. 빌드 로그 자세히 보기
docker build --progress=plain -t my-app .

# 3. 중간 단계에서 디버깅
docker run -it <intermediate_image_id> /bin/bash
```

</details>

<details>
<summary>❌ 컨테이너 실행 실패</summary>

**원인**:
- 포트 충돌
- 볼륨 마운트 실패
- 환경변수 설정 오류

**해결방법**:
```bash
# 1. 포트 사용 확인
netstat -tulpn | grep :3000

# 2. 컨테이너 로그 확인
docker logs <container_id>

# 3. 컨테이너 내부 접속
docker exec -it <container_id> /bin/bash
```

</details>

### Git/GitHub 관련 문제

<details>
<summary>❌ Push 실패</summary>

**원인**:
- 인증 문제
- 권한 부족
- 원격 저장소 URL 오류

**해결방법**:
```bash
# 1. 원격 저장소 URL 확인
git remote -v

# 2. 인증 정보 확인
git config --list | grep credential

# 3. SSH 키 확인
ssh -T git@github.com
```

</details>

### GitHub Actions 관련 문제

<details>
<summary>❌ 워크플로우 실행 실패</summary>

**원인**:
- YAML 문법 오류
- 시크릿 설정 누락
- 권한 부족

**해결방법**:
```bash
# 1. YAML 문법 검사
# 온라인 YAML 검사기 사용

# 2. 시크릿 확인
# GitHub 저장소 > Settings > Secrets and variables > Actions

# 3. 워크플로우 로그 확인
# Actions 탭에서 상세 로그 확인
```

</details>

</details>

<details>
<summary>📖 추가 학습 자료</summary>

### 공식 문서

- ["Docker 공식 문서"][https:///docs.docker.com/]
- ["Git 공식 문서"][https:///git-scm.com/doc]
- ["GitHub Actions 공식 문서"][https:///docs.github.com/en/actions]
- ["AWS EC2 공식 문서"][https:///docs.aws.amazon.com/ec2/]
- ["GCP Compute Engine 공식 문서"][https:///cloud.google.com/compute/docs]

### 유용한 리소스

- [Docker Hub][https:///hub.docker.com/]
- [GitHub Learning Lab][https:///lab.github.com/]
- [AWS Free Tier][https:///aws.amazon.com/free/]
- [GCP Free Tier][https:///cloud.google.com/free]

### 관련 프로젝트

- ["Docker 샘플 프로젝트"][https:///github.com/docker/awesome-compose]
- ["GitHub Actions 샘플"][https:///github.com/actions/starter-workflows]
- ["AWS 샘플 프로젝트"][https:///github.com/aws-samples]
- ["GCP 샘플 프로젝트"][https:///github.com/GoogleCloudPlatform]

</details>

<details>
<summary>🚀 다음 단계</summary>

### Cloud Master 2일차 준비

1. **Docker 고급 기법**: 멀티스테이지 빌드, 최적화
2. **GitHub Actions 고급**: 매트릭스 빌드, 환경별 배포
3. **VM 기반 컨테이너 배포**: 고가용성 구성
4. **완전 자동화**: CI/CD 파이프라인 고도화

### 실무 적용

1. **실제 프로젝트**: 자신의 프로젝트에 Docker 적용
2. **협업 환경**: 팀과 Git/GitHub 협업 워크플로우 구축
3. **자동화**: GitHub Actions로 배포 자동화
4. **모니터링**: 기본적인 로그 및 모니터링 설정

</details>

---

## 🎉 완료!

축하합니다! Cloud Master 1일차 실습을 완료했습니다.

### 📚 학습 요약

이번 실습을 통해 다음을 배웠습니다:

1. **🐳 Docker**: 컨테이너 개념, Dockerfile 작성, Docker Compose
2. **📝 Git/GitHub**: 버전 관리, 브랜치 전략, 협업 워크플로우
3. **🚀 GitHub Actions**: CI/CD 파이프라인 구축, 자동 배포
4. **☁️ VM 배포**: AWS EC2, GCP Compute Engine 웹 애플리케이션 배포

### 📝 학습 피드백 수집

#### 실습 완료 체크리스트

- [ ] Docker 컨테이너 생성 및 실행 완료
- [ ] Dockerfile 작성 및 이미지 빌드 완료
- [ ] Git 저장소 생성 및 기본 명령어 실습 완료
- [ ] GitHub Actions 워크플로우 작성 및 실행 완료
- [ ] VM에 웹 애플리케이션 배포 완료

#### 학습 난이도 평가

- **매우 쉬움** ⭐
- **쉬움** ⭐⭐
- **보통** ⭐⭐⭐
- **어려움** ⭐⭐⭐⭐
- **매우 어려움** ⭐⭐⭐⭐⭐

#### 개선 제안

["개선 제안"]["#개선-제안"]
- 실습 중 어려웠던 부분: ________________
- 추가로 배우고 싶은 내용: ________________
- 실습 시간이 충분했는지: □ 충분함 □ 부족함 □ 과도함

### 🚀 다음 단계

- **Cloud Master 2일차**: Docker 고급 기법, GitHub Actions 고급 워크플로우
- **실제 프로젝트 적용**: 자신의 프로젝트에 학습한 기술 적용
- **고급 기능 학습**: 모니터링, 로드 밸런싱, 자동 스케일링

### 💡 추가 학습 자료

- ["Docker 공식 문서"][https:///docs.docker.com/]
- ["Git 공식 문서"][https:///git-scm.com/doc]
- ["GitHub Actions 공식 문서"][https:///docs.github.com/en/actions]
- ["피드백 제출"][https:///forms.gle/example]

---

*🎯 이제 Docker, Git/GitHub, GitHub Actions의 기본기를 갖추었습니다! Cloud Master 2일차로 진행하세요.**


## 🧭 네비게이션









<div align="center">

["🏠 홈으로 돌아가기"][index.md] | ["📚 전체 커리큘럼"][curriculum.md] | ["🔗 학습 경로"][learning-path.md]

</div>