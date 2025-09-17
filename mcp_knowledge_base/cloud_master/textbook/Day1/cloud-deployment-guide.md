<div align="center">

[← 이전: Cloud Master 1일차 메인](/mcp_knowledge_base/cloud_master/README.md) | [📚 전체 커리큘럼](/mcp_knowledge_base/curriculum.md) | [🏠 학습 경로로 돌아가기](/mcp_knowledge_base/index.md) | [📋 학습 경로](/mcp_knowledge_base/cloud_master/learning-path.md) | [← 이전: GitHub Actions 가이드](/mcp_knowledge_base/cloud_master/textbook/Day1/github-actions-guide.md) | [다음: AWS & GCP 배포 가이드 →](/mcp_knowledge_base/cloud_master/textbook/Day1/aws-gcp-deployment-guide.md)

</div>

# 3교시: GitHub Actions를 통한 가상머신 배포 실습



<details>
<summary>📋 목차 </summary>

1. [🎯 학습 목표](#학습-목표)
2. [📦 actions-demo 프로젝트 소개](#actionsdemo-프로젝트-소개)
3. [🚀 실습 환경 준비](#실습-환경-준비)
4. [⚖️ 가상머신 배포 실습](#가상머신-배포-실습)
5. [🔧 GitHub Actions 워크플로우 설정](#github-actions-워크플로우-설정)
6. [📚 문제 해결 및 참고 자료](#문제-해결-및-참고-자료)

</details>

---

## 🎯 학습 목표

<details>
<summary>📖 이번 실습에서 배우게 될 내용 </summary>

### 핵심 학습 목표
- **GitHub Actions CI/CD 파이프라인** 구축 및 이해
- **가상머신에 Node.js 애플리케이션** 자동 배포
- **Docker 컨테이너**를 활용한 배포 방식 학습
- **AWS EC2와 GCP Compute Engine** 두 플랫폼에서의 실습

### 실습 후 달성할 수 있는 능력
- ✅ GitHub Actions 워크플로우 작성 및 관리
- ✅ 가상머신 인프라 자동 생성 및 설정
- ✅ Docker를 활용한 애플리케이션 배포
- ✅ CI/CD 파이프라인 구축 및 모니터링

### 예상 소요 시간
- **기본 실습**: 45-60분
- **고급 실습**: 90-120분
- **전체 과정**: 2-3시간

</details>

---

## 📦 actions-demo 프로젝트 소개

<details>
<summary>🎯 프로젝트 개요 </summary>

### 프로젝트 정보
- **저장소**: [https://github.com/jungfrau70/actions-demo.git](https://github.com/jungfrau70/actions-demo.git)
- **언어**: JavaScript (76.2%), Dockerfile (23.8%)
- **목적**: GitHub Actions를 사용한 CI/CD 파이프라인 학습용 데모 프로젝트

### 프로젝트 구조
```
actions-demo/
├── .github/workflows/     # GitHub Actions 워크플로우
├── tests/                 # 테스트 파일
├── app.js                 # Node.js 애플리케이션
├── package.json           # 의존성 관리
├── Dockerfile             # Docker 이미지 빌드
└── README.md              # 프로젝트 문서
```

</details>

<details>
<summary>🚀 애플리케이션 특징 </summary>

### Node.js Express 애플리케이션
- **프레임워크**: Express.js
- **포트**: 3000 (기본)
- **기능**: 간단한 웹 서버 및 API 엔드포인트
- **테스트**: Jest를 사용한 단위 테스트

### Docker 지원
- **멀티스테이지 빌드**: 최적화된 이미지 크기
- **보안**: 비루트 사용자로 실행
- **포트**: 3000번 포트 노출

### GitHub Actions 워크플로우
- **CI Pipeline**: 코드 품질 검사, 테스트, 빌드
- **Docker Hub 배포**: Docker 이미지 빌드 및 푸시
- **가상머신 배포**: AWS EC2, GCP Compute Engine 지원

</details>

<details>
<summary>🔧 현재 활성화된 워크플로우 </summary>

### ✅ 기본 워크플로우 (활성화됨)

1. **CI Pipeline** (`ci.yml`)
   - 트리거: `push` (main, develop), `pull_request` (main)
   - 기능: 코드 품질 검사, 테스트, 빌드
   - 소요 시간: 약 2-3분

2. **Docker Hub 배포** (`deploy.yml`)
   - 트리거: `push` (main), `tags` (v*)
   - 기능: Docker 이미지 빌드 및 Docker Hub 푸시
   - 소요 시간: 약 3-5분

</details>

---

## 🚀 실습 환경 준비

<details>
<summary>📋 필수 계정 및 도구 </summary>

### 필수 계정
- **GitHub 계정**: 저장소 포크 및 Actions 사용
- **Docker Hub 계정**: Docker 이미지 저장소
- **AWS 계정**: EC2 인스턴스 배포용
- **GCP 계정**: Compute Engine 배포용

### 필수 도구
- **Git**: 코드 버전 관리
- **Docker**: 컨테이너 이미지 빌드 및 실행
- **Node.js**: 로컬 개발 및 테스트

</details>

<details>
<summary>🔧 GitHub 저장소 설정 </summary>

### 1단계: 저장소 포크
1. [actions-demo 저장소](https://github.com/jungfrau70/actions-demo.git) 방문
2. "Fork" 버튼 클릭하여 자신의 계정으로 포크
3. 포크된 저장소를 로컬로 클론

```bash
git clone https://github.com/YOUR_USERNAME/actions-demo.git
cd actions-demo
```

### 2단계: GitHub Secrets 설정
저장소 → Settings → Secrets and variables → Actions

<details>
<summary>🔑 Docker Hub 설정</summary>

**DOCKERHUB_TOKEN** 추가:
1. Docker Hub → Account Settings → Security
2. "New Access Token" 클릭
3. 토큰 이름 입력 후 생성
4. 생성된 토큰을 GitHub Secrets에 추가

</details>

<details>
<summary>🔑 AWS 설정 </summary>

**AWS_ACCESS_KEY_ID** 및 **AWS_SECRET_ACCESS_KEY** 추가:
1. AWS IAM → Users → Create user
2. Programmatic access 선택
3. EC2FullAccess, VPCFullAccess 권한 부여
4. Access Key ID와 Secret Access Key를 GitHub Secrets에 추가

</details>

<details>
<summary>🔑 GCP 설정 </summary>

**GCP_SA_KEY** 추가:
1. GCP Console → IAM & Admin → Service Accounts
2. Service Account 생성
3. Compute Instance Admin 역할 부여
4. JSON 키 파일 다운로드
5. JSON 내용을 GitHub Secrets에 추가

</details>

</details>

<details>
<summary>🐳 Docker 환경 설정 </summary>

### Docker 설치 확인
```bash
# Docker 버전 확인
docker --version
docker-compose --version

# Docker 서비스 상태 확인
docker info
```

### Docker Hub 로그인
```bash
# Docker Hub에 로그인
docker login

# 로그인 확인
docker system info | grep Username
```

</details>

---

## ⚖️ 가상머신 배포 실습

<details>
<summary>🖥️ AWS EC2 가상머신 배포 </summary>

### 🚀 GitHub Actions를 통한 자동 배포

<details>
<summary>⚡ 1단계: VM Docker 배포 워크플로우 활성화</summary>

```bash
# 1. 저장소 클론
git clone https://github.com/YOUR_USERNAME/actions-demo.git
cd actions-demo

# 2. VM Docker 배포 워크플로우 활성화
mv .github/workflows/vm-docker-deploy.yml.disabled .github/workflows/vm-docker-deploy.yml

# 3. 변경사항 커밋 및 푸시
git add .
git commit -m "Enable VM Docker deployment workflow"
git push origin main
```

</details>

<details>
<summary>⚡ 2단계: GitHub Actions 워크플로우 확인</summary>

### 워크플로우 실행 확인
1. GitHub 저장소 → Actions 탭
2. "VM Docker Deploy" 워크플로우 실행 확인
3. 각 단계별 로그 확인

### 배포 과정
1. **코드 체크아웃**: 저장소 코드 다운로드
2. **Docker 이미지 빌드**: 애플리케이션을 Docker 이미지로 빌드
3. **Docker Hub 푸시**: 빌드된 이미지를 Docker Hub에 업로드
4. **EC2 인스턴스 생성**: AWS에서 가상머신 자동 생성
5. **Docker 컨테이너 배포**: EC2에 애플리케이션 배포
6. **헬스 체크**: 배포된 애플리케이션 상태 확인

</details>

<details>
<summary>⚡ 3단계: 배포 결과 확인</summary>

### 배포 성공 확인
- **GitHub Actions**: 모든 단계가 성공적으로 완료
- **Docker Hub**: 이미지가 정상적으로 업로드됨
- **AWS EC2**: 인스턴스가 실행 중이고 애플리케이션 접근 가능

### 접속 정보 확인
```bash
# EC2 인스턴스 정보 조회
aws ec2 describe-instances \
    --filters "Name=tag:Name,Values=actions-demo" \
    --query 'Reservations[*].Instances[*].[InstanceId,State.Name,PublicIpAddress]'

# 애플리케이션 접속 테스트
curl http://YOUR_EC2_PUBLIC_IP:3000
```

</details>

</details>

<details>
<summary>☁️ GCP Compute Engine 가상머신 배포 </summary>

### 🚀 GitHub Actions를 통한 자동 배포

<details>
<summary>⚡ 1단계: GCP 배포 워크플로우 활성화</summary>

```bash
# 1. GCP 배포 워크플로우 활성화
mv .github/workflows/gcp-deploy.yml.disabled .github/workflows/gcp-deploy.yml

# 2. 변경사항 커밋 및 푸시
git add .
git commit -m "Enable GCP deployment workflow"
git push origin main
```

</details>

<details>
<summary>⚡ 2단계: GCP 배포 과정 확인</summary>

### 배포 과정
1. **코드 체크아웃**: 저장소 코드 다운로드
2. **Docker 이미지 빌드**: 애플리케이션을 Docker 이미지로 빌드
3. **Docker Hub 푸시**: 빌드된 이미지를 Docker Hub에 업로드
4. **GCE 인스턴스 생성**: GCP에서 가상머신 자동 생성
5. **Docker 컨테이너 배포**: GCE에 애플리케이션 배포
6. **헬스 체크**: 배포된 애플리케이션 상태 확인

</details>

<details>
<summary>⚡ 3단계: GCP 배포 결과 확인</summary>

### 배포 성공 확인
- **GitHub Actions**: 모든 단계가 성공적으로 완료
- **Docker Hub**: 이미지가 정상적으로 업로드됨
- **GCP Compute Engine**: 인스턴스가 실행 중이고 애플리케이션 접근 가능

### 접속 정보 확인
```bash
# GCE 인스턴스 정보 조회
gcloud compute instances list --filter="name:actions-demo"

# 애플리케이션 접속 테스트
curl http://YOUR_GCE_EXTERNAL_IP:3000
```

</details>

</details>

---

## 🔧 GitHub Actions 워크플로우 설정

<details>
<summary>📝 워크플로우 파일 구조 </summary>

### 기본 워크플로우 파일들

<details>
<summary>🔧 CI Pipeline (ci.yml)</summary>

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
    - uses: actions/checkout@v4
    
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

</details>

<details>
<summary>🐳 Docker Hub 배포 (deploy.yml)</summary>

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
    - uses: actions/checkout@v4
    
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
        tags: ${{ secrets.DOCKERHUB_USERNAME }}/actions-demo:latest
```

</details>

<details>
<summary>🖥️ VM Docker 배포 (vm-docker-deploy.yml)</summary>

```yaml
name: Deploy to VM with Docker

on:
  push:
    branches: [ main ]
  workflow_dispatch:

jobs:
  deploy:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v4
    
    - name: Deploy to AWS EC2
      if: ${{ secrets.AWS_ACCESS_KEY_ID }}
      uses: appleboy/ssh-action@v1.0.3
      with:
        host: ${{ secrets.EC2_HOST }}
        username: ${{ secrets.EC2_USERNAME }}
        key: ${{ secrets.EC2_SSH_KEY }}
        script: |
          docker pull ${{ secrets.DOCKERHUB_USERNAME }}/actions-demo:latest
          docker stop actions-demo || true
          docker rm actions-demo || true
          docker run -d -p 3000:3000 --name actions-demo ${{ secrets.DOCKERHUB_USERNAME }}/actions-demo:latest
```

</details>

</details>

<details>
<summary>⚙️ 워크플로우 커스터마이징 </summary>

### 환경별 배포 설정

<details>
<summary>🌍 환경 변수 설정</summary>

```yaml
env:
  NODE_ENV: production
  PORT: 3000
  DOCKER_IMAGE: ${{ secrets.DOCKERHUB_USERNAME }}/actions-demo
  DOCKER_TAG: ${{ github.sha }}
```

</details>

<details>
<summary>🔄 조건부 배포</summary>

```yaml
- name: Deploy to Production
  if: github.ref == 'refs/heads/main'
  run: echo "Deploying to production"

- name: Deploy to Staging
  if: github.ref == 'refs/heads/develop'
  run: echo "Deploying to staging"
```

</details>

<details>
<summary>📊 배포 상태 알림</summary>

```yaml
- name: Notify Deployment Success
  if: success()
  run: |
    echo "✅ Deployment successful!"
    echo "🌐 Application URL: http://${{ secrets.EC2_HOST }}:3000"

- name: Notify Deployment Failure
  if: failure()
  run: |
    echo "❌ Deployment failed!"
    echo "🔍 Check the logs for details"
```

</details>

</details>

---

## 📚 문제 해결 및 참고 자료

<details>
<summary>🐛 자주 발생하는 문제 </summary>

### GitHub Actions 관련 문제

<details>
<summary>❌ 워크플로우가 실행되지 않음</summary>

**원인**: 
- 파일명에 `.disabled`가 있음
- YAML 문법 오류
- 권한 부족

**해결방법**:
```bash
# 1. 워크플로우 파일 활성화
mv .github/workflows/vm-docker-deploy.yml.disabled .github/workflows/vm-docker-deploy.yml

# 2. YAML 문법 검사
yamllint .github/workflows/*.yml

# 3. 권한 확인
# GitHub Secrets에 필요한 토큰들이 모두 설정되어 있는지 확인
```

</details>

<details>
<summary>❌ Docker Hub 푸시 실패</summary>

**원인**:
- `DOCKERHUB_TOKEN` 시크릿이 설정되지 않음
- Docker Hub 계정 권한 부족

**해결방법**:
1. Docker Hub → Account Settings → Security
2. Personal Access Token 생성
3. GitHub Secrets에 `DOCKERHUB_TOKEN` 추가

</details>

<details>
<summary>❌ AWS EC2 연결 실패</summary>

**원인**:
- SSH 키 설정 오류
- 보안 그룹 설정 문제
- 인스턴스가 아직 시작되지 않음

**해결방법**:
```bash
# 1. SSH 키 확인
ssh-keygen -l -f ~/.ssh/id_rsa.pub

# 2. 보안 그룹 확인
aws ec2 describe-security-groups --group-ids sg-xxxxxxxx

# 3. 인스턴스 상태 확인
aws ec2 describe-instances --instance-ids i-xxxxxxxx
```

</details>

</details>

<details>
<summary>📖 추가 학습 자료 </summary>

### 공식 문서
- [GitHub Actions 공식 문서](https://docs.github.com/en/actions)
- [Docker 공식 문서](https://docs.docker.com/)
- [AWS EC2 공식 문서](https://docs.aws.amazon.com/ec2/)
- [GCP Compute Engine 공식 문서](https://cloud.google.com/compute/docs)

### 유용한 리소스
- [GitHub Actions Marketplace](https://github.com/marketplace?type=actions)
- [Docker Hub](https://hub.docker.com/)
- [AWS Free Tier](https://aws.amazon.com/free/)
- [GCP Free Tier](https://cloud.google.com/free)

### 관련 프로젝트
- [actions-demo 저장소](https://github.com/jungfrau70/actions-demo.git)
- [GitHub Actions 예제 모음](https://github.com/actions/starter-workflows)

</details>

<details>
<summary>🚀 다음 단계 </summary>

### 고급 기능 구현
1. **멀티클라우드 배포**: AWS와 GCP 동시 배포
2. **자동 스케일링**: 트래픽에 따른 인스턴스 자동 확장
3. **모니터링**: CloudWatch, Stackdriver 연동
4. **보안 강화**: SSL/TLS 인증서, WAF 설정

### CI/CD 파이프라인 고도화
1. **테스트 자동화**: 단위 테스트, 통합 테스트, E2E 테스트
2. **코드 품질**: SonarQube, CodeClimate 연동
3. **보안 스캔**: Snyk, OWASP ZAP 연동
4. **성능 테스트**: JMeter, K6 연동

</details>

---

## 🎉 완료!

축하합니다! GitHub Actions를 통한 가상머신 배포 실습을 완료했습니다.

### 📚 학습 요약

이번 실습을 통해 다음을 배웠습니다:

1. **📦 actions-demo 프로젝트**: Node.js Express 애플리케이션 구조 이해
2. **🚀 실습 환경 준비**: GitHub, Docker Hub, AWS/GCP 계정 설정
3. **⚖️ 가상머신 배포**: AWS EC2와 GCP Compute Engine 자동 배포
4. **🔧 GitHub Actions**: CI/CD 파이프라인 구축 및 관리
5. **📚 문제 해결**: 일반적인 문제와 해결 방법

### 🚀 다음 단계

- **실제 프로젝트 적용**: 자신의 프로젝트에 CI/CD 파이프라인 구축
- **고급 기능 구현**: 모니터링, 자동 스케일링, 보안 강화
- **다른 플랫폼 탐색**: Azure, DigitalOcean 등 다른 클라우드 플랫폼

### 💡 추가 학습 자료

- [GitHub Actions 공식 문서](https://docs.github.com/en/actions)
- [Docker 공식 문서](https://docs.docker.com/)
- [AWS EC2 공식 문서](https://docs.aws.amazon.com/ec2/)
- [GCP Compute Engine 공식 문서](https://cloud.google.com/compute/docs)

---

**🎯 이제 GitHub Actions를 활용한 자동 배포의 기본기를 갖추었습니다! 실제 프로젝트에 적용해보세요.**

---



---

<div align="center">

[🏠 홈](/mcp_knowledge_base/index.md) | [📚 전체 커리큘럼](/mcp_knowledge_base/curriculum.md) | [🔗 학습 경로](/mcp_knowledge_base/cloud_master/learning-path.md)

</div>