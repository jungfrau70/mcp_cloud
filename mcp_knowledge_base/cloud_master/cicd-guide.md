# 🚀 Cloud Master CI/CD 가이드

## 📖 왜 CI/CD가 필요한가요? [Why]

### 🎭 현실적인 개발팀의 고민
"코드가 제대로 작동하는지 어떻게 확신할 수 있을까요?" 
"새로운 기능을 배포할 때마다 밤새 테스트하고 수동으로 배포하는 일이 너무 번거로워요..."
"팀원이 각자 다른 환경에서 개발해서 '내 컴퓨터에서는 잘 되는데...'라는 말을 자주 들어요."

### 💡 CI/CD가 해결해주는 문제들
- **🤝 팀 협업의 혼란**: 모든 팀원이 동일한 환경에서 테스트하고 배포
- **⏰ 수동 작업의 반복**: 매번 반복되는 테스트, 빌드, 배포 과정을 자동화
- **🐛 버그의 조기 발견**: 코드 변경 시 즉시 테스트하여 문제를 빠르게 발견
- **🚀 빠른 배포**: 안전하고 신속한 배포로 사용자에게 더 나은 서비스 제공
- **😴 밤잠 보장**: 자동화된 배포로 밤새 배포 작업할 필요 없음!

### 🎯 이 가이드에서 배우는 것
- **왜** CI/CD가 현대 개발에 필수인지 이해
- **어떻게** GitHub Actions로 자동화 파이프라인을 구축하는지 학습
- **무엇을** 실제로 구현하여 팀의 개발 생산성을 높이는지 경험

---

## 🎯 학습 목표

### 핵심 학습 목표
- **GitHub Actions 기초**: 워크플로우 생성, 실행, 관리
- **CI/CD 파이프라인**: 자동화된 테스트, 빌드, 배포
- **클라우드 배포**: AWS, GCP 환경에 자동 배포
- **모니터링 및 최적화**: 배포 상태 모니터링 및 성능 최적화

### 실습 후 달성할 수 있는 능력
- ✅ GitHub Actions 워크플로우 설계 및 구현
- ✅ Docker 이미지 자동 빌드 및 배포
- ✅ VM 및 Kubernetes 클러스터 자동 배포
- ✅ 모니터링 및 알림 시스템 구축
- ✅ 프로덕션 레벨 성능 최적화 ["평균 응답시간 6.2ms"]
- ✅ 보안 스캔 및 취약점 관리
- ✅ 8개 서비스 통합 운영 환경 구축

### 예상 소요 시간
- **Day 1: 기본 CI/CD**: 120-150분
- **Day 2: 고급 CI/CD**: 150-180분
- **Day 3: 모니터링 & 최적화**: 120-150분
- **전체 과정**: 6-8시간

---

## 📚 기존 문서와의 연계

### 관련 실습 가이드
- ["인프라 가이드"][infra-guide.md] - 인프라 환경 설정 및 관리
- ["실습 가이드"][execuise-guide.md] - 전체 과정 실습 가이드
- ["GitHub Actions 기초 실습"][../textbook/Day1/practices/github-actions-basics.md] - 기본 워크플로우 생성

### 자동화 스크립트
- ["통합 자동화 스크립트"][../repos/automation/integrated-practice-automation.sh] - 전체 과정 자동화
- ["GitHub Actions 자동화"][../repos/automation/github-actions-cicd-automation.sh] - CI/CD 파이프라인 자동화
- ["환경 체크 도구"][../repos/cloud-scripts/environment-check-wsl.sh] - 실습 환경 검증

---

## 🚀 실습 1: 기본 CI/CD 파이프라인 구축

### 📖 실습 시나리오: "첫 번째 자동화 파이프라인 만들기"

**🎯 실습 목표**: 
- GitHub 저장소 생성 및 기본 설정
- Docker 이미지 수동 빌드 및 테스트
- GitHub Actions CI 워크플로우 생성
- 자동화된 테스트 및 빌드 파이프라인 구축

**⏱️ 예상 소요 시간**: 60-90분

**📋 실습 전 준비사항**:
- [ ] GitHub 계정 및 Personal Access Token
- [ ] Docker Hub 계정 및 Personal Access Token
- [ ] 로컬 개발 환경 [Docker, Node.js, Git]

### 📋 실습 환경 준비

#### 🛠️ 필요한 도구들 ["왜 필요한지 설명"]
- **GitHub 계정**: 코드 저장소이자 CI/CD 실행 환경
  - *왜?*: 코드를 저장하고, 변경사항을 추적하고, 자동화 작업을 실행하는 곳
- **Docker Hub 계정**: 우리가 만든 애플리케이션을 컨테이너로 포장해서 저장
  - *왜?*: "내 컴퓨터에서는 잘 되는데..." 문제를 해결해주는 마법의 상자
- **AWS 계정**: 클라우드에서 서버를 빌려서 우리 앱을 실행
  - *왜?*: 24시간 언제든 접근 가능한 서버가 필요하니까요
- **GCP 계정**: AWS와 다른 클라우드도 경험해보기
  - *왜?*: 다양한 클라우드 환경에 대응할 수 있는 능력을 기르기 위해

#### 🔧 환경 설정 ["단계별로 차근차근"]
```bash
# 1단계: 현재 설치된 도구들 확인하기
echo "🔍 현재 환경을 점검해보겠습니다..."

# 필수 도구 설치 확인
docker --version
aws --version
gcloud --version
kubectl version --client

# 2단계: GitHub CLI 설치 ["선택사항이지만 매우 유용!"]
gh --version || sudo apt install gh

echo "✅ 환경 설정이 완료되었습니다!"
```

### 🔧 실습 1-1: GitHub 저장소 생성 및 기본 설정

#### 📝 실습 단계

**🎯 이 단계에서 할 일**:
1. GitHub 저장소 생성
2. 로컬 프로젝트 초기화
3. GitHub에 프로젝트 연결
4. 기본 파일 구조 생성

**✅ 실습 완료 기준**:
- [ ] GitHub 저장소가 생성되었음
- [ ] 로컬 프로젝트가 GitHub에 연결되었음
- [ ] 기본 프로젝트 파일들이 생성되었음

#### 🐙 GitHub 저장소 생성하기

**1단계: GitHub에서 새 저장소 생성**
```bash
# GitHub CLI로 저장소 생성 ["가장 쉬운 방법!"]
gh repo create github-actions-demo --public --description "GitHub Actions CI/CD 실습 프로젝트"

# 또는 GitHub 웹사이트에서 직접 생성:
# 1. https://github.com 접속
# 2. "New repository" 클릭
# 3. Repository name: github-actions-demo
# 4. Description: GitHub Actions CI/CD 실습 프로젝트
# 5. Public 선택
# 6. "Create repository" 클릭

mkdir github-actions-demo
cd github-actions-demo
```

**2단계: 로컬 프로젝트를 GitHub에 연결**

**⚠️ 중요: GitHub 인증 설정**
GitHub에서는 더 이상 비밀번호 인증을 지원하지 않습니다. Personal Access Token을 사용해야 합니다.

```bash
# 1. Personal Access Token 생성 ["GitHub 웹사이트에서"]
# https://github.com/settings/tokens 접속
# "Personal access tokens" > "Tokens [classic]" 클릭
# "Generate new token" > "Generate new token [classic]" 클릭
# Note: "GitHub Actions Demo" 입력
# Expiration: "90 days" 선택
# Scopes: 다음 권한들을 체크
# ✅ repo ["전체 저장소 접근 권한"]
# ✅ workflow ["GitHub Actions 워크플로우 실행 권한"]
# ✅ write:packages ["Docker Hub에 이미지 푸시 권한"]
# ✅ read:packages ["Docker Hub에서 이미지 풀 권한"]
# ✅ admin:org ["조직 및 팀 전체 제어, 조직 프로젝트 읽기/쓰기"]
# "Generate token" 클릭 후 토큰 복사 ["한 번만 보여줍니다!"]

# 2. Git 저장소 초기화
git init

# 3. 원격 저장소 연결
git remote add origin https://github.com/[YOUR_USERNAME]/github-actions-demo.git

# 4. 첫 번째 커밋
git add .
git commit -m "🎉 Initial commit: GitHub Actions CI/CD 실습 프로젝트 시작"

# 5. GitHub에 푸시 ["토큰 사용"]
git branch -M main
git push -u origin main
# Username: [YOUR_USERNAME] 입력
# Password: [PERSONAL_ACCESS_TOKEN] 입력 ["비밀번호가 아닌 토큰!"]

echo "✅ GitHub 저장소에 성공적으로 업로드되었습니다!"
```

**🔧 인증 문제 해결 방법**

**방법 1: Personal Access Token 사용 ["권장"]**
```bash
# GitHub에서 Personal Access Token 생성 후
git push -u origin main
# Username: jungfrau70
# Password: ["생성한 토큰 입력"]
```

**📝 GitHub 메뉴 변경사항 ["2024년 기준"]**
- **기존**: Settings > Developer settings > Personal access tokens
- **현재**: Settings > Personal access tokens > Tokens [classic]
- **새로운 옵션**: Fine-grained tokens ["더 세밀한 권한 제어"]
- **권장**: Classic tokens가 더 간단하고 호환성이 좋음

**🔑 GitHub Actions에 필요한 권한 설명**
- **repo**: 저장소 읽기/쓰기, 코드 푸시/풀
- **workflow**: GitHub Actions 워크플로우 실행 및 관리
- **write:packages**: Docker Hub, GitHub Packages에 이미지 업로드
- **read:packages**: Docker Hub, GitHub Packages에서 이미지 다운로드
- **admin:org**: 조직 및 팀 전체 제어, 조직 프로젝트 읽기/쓰기 ["필요시"]
- **user:email**: 이메일 주소 읽기 ["필요시"]

**방법 2: SSH 키 사용 ["더 안전"]**
```bash
# SSH 키 생성
ssh-keygen -t ed25519 -C "your-email@example.com"

# SSH 키를 GitHub에 등록
cat ~/.ssh/id_ed25519.pub
# 위 명령어 결과를 GitHub > Settings > SSH and GPG keys에 추가

# SSH URL로 원격 저장소 변경
git remote set-url origin git@github.com:jungfrau70/github-actions-demo.git

# SSH로 푸시
git push -u origin main
```

**방법 3: GitHub CLI 사용 ["가장 쉬움"]**
```bash
# GitHub CLI로 로그인
gh auth login

# 자동으로 인증된 상태로 푸시
git push -u origin main
```

### 🔧 실습 1-2: Docker 이미지 빌드 및 테스트

#### 📝 실습 단계

**🎯 이 단계에서 할 일**:
1. 기본 Dockerfile 생성
2. Docker 이미지 수동 빌드
3. 로컬에서 컨테이너 실행 테스트
4. Docker Hub에 이미지 푸시

**✅ 실습 완료 기준**:
- [ ] Docker 이미지가 성공적으로 빌드되었음
- [ ] 로컬에서 컨테이너가 정상 실행되었음
- [ ] Docker Hub에 이미지가 업로드되었음

#### 🐳 Docker 이미지 빌드 및 푸시 테스트

**1단계: 기본 Dockerfile 생성**

**📁 Dockerfile 종류별 생성**

**Dockerfile ["기본 - 프로덕션용"]**
```dockerfile
# 기본 프로덕션용 Dockerfile
FROM node:18-alpine

WORKDIR /app

# 의존성 설치
COPY package*.json ./
RUN npm ci --omit=dev && npm cache clean --force

# 소스 코드 복사
COPY . .

# 비root 사용자 생성
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nextjs -u 1001
RUN chown -R nextjs:nodejs /app
USER nextjs

# 포트 노출
EXPOSE 3000

# 헬스 체크
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD node -e "require['http'].get['http://localhost:3000/health', [res] => { process.exit[res.statusCode === 200 ? 0 : 1] }]"

# 애플리케이션 시작
CMD ["node", "src/app.js"]
```

**Dockerfile.dev ["개발용"]**
```dockerfile
# 개발용 Dockerfile
FROM node:18-alpine

WORKDIR /app

# 개발 의존성 포함 설치
COPY package*.json ./
RUN npm ci && npm cache clean --force

# 소스 코드 복사
COPY . .

# 포트 노출
EXPOSE 3000

# 개발 서버 시작 ["핫 리로드 지원"]
CMD ["npm", "start"]
```

**Dockerfile.test ["테스트용"]**
```dockerfile
# 테스트용 Dockerfile
FROM node:18-alpine

WORKDIR /app

# 모든 의존성 설치 ["테스트 도구 포함"]
COPY package*.json ./
RUN npm ci && npm cache clean --force

# 소스 코드 복사
COPY . .

# 테스트 실행
CMD ["npm", "test"]
```

**⚠️ Docker 빌드 오류 해결**

**1. BuildKit 오류 해결**
```bash
# BuildKit 오류가 발생하는 경우 해결 방법:

# 방법 1: BuildKit 비활성화 ["가장 간단"]
export DOCKER_BUILDKIT=0
docker build -t github-actions-demo:latest .

# 방법 2: Buildx 설치 ["권장"]
docker buildx install
docker buildx create --use
docker build -t github-actions-demo:latest .

# 방법 3: 기존 빌드 방식 사용
docker build --no-cache -t github-actions-demo:latest .
```

**2. package-lock.json 누락 오류 해결**
```bash
# package-lock.json 파일이 없는 경우:

# 1단계: package-lock.json 생성
npm install

# 2단계: 생성된 파일 확인
ls -la package*.json

# 3단계: Docker 빌드 재시도
docker build -t github-actions-demo:latest .

# 또는 Dockerfile에서 npm install 사용하도록 수정
# RUN npm install --only=production && npm cache clean --force
```

**3. package.json JSON 구문 오류 해결**
```bash
# package.json에 JavaScript 주석[//]이 있는 경우:

# 1단계: package.json 파일 확인
cat package.json

# 2단계: JSON 유효성 검사
npm install --dry-run

# 3단계: 주석 제거 후 재시도
# JSON에서는 // 주석을 사용할 수 없습니다!
# 주석이 필요하면 README.md에 작성하세요

# 4단계: 정상 설치 확인
npm install
```

**2단계: Docker 이미지 빌드 및 테스트**

**프로덕션용 이미지 빌드**
```bash
# 프로덕션용 이미지 빌드
docker build -f Dockerfile -t github-actions-demo:latest .

# 빌드된 이미지 확인
docker images | grep github-actions-demo

# 로컬에서 실행 테스트
docker run -d -p 3000:3000 --name prod-app github-actions-demo:latest

# 애플리케이션 동작 확인
curl http://localhost:3000/health

# 테스트 완료 후 컨테이너 정리
docker stop prod-app
docker rm prod-app
```

**개발용 이미지 빌드**
```bash
# 개발용 이미지 빌드
docker build -f Dockerfile.dev -t github-actions-demo:dev .

# 개발용 컨테이너 실행
docker run -d -p 3001:3000 --name dev-app github-actions-demo:dev

# 개발 서버 확인
curl http://localhost:3001/health

# 정리
docker stop dev-app
docker rm dev-app
```

**테스트용 이미지 빌드**
```bash
# 테스트용 이미지 빌드
docker build -f Dockerfile.test -t github-actions-demo:test .

# 테스트 실행
docker run --rm github-actions-demo:test

# 테스트 결과 확인
echo "테스트가 성공적으로 완료되었습니다!"
```

**4단계: Docker Hub에 푸시하기**
```bash
YOUR_DOCKERHUB_USERNAME=<username>

# Docker Hub 로그인
docker login -u $YOUR_DOCKERHUB_USERNAME

# 이미지 태그 설정 ["Docker Hub 사용자명으로 변경"]
docker tag github-actions-demo:latest $YOUR_DOCKERHUB_USERNAME/github-actions-demo:latest

# 이미지 리스트업
docker image ls

# Docker Hub에 푸시
docker push $YOUR_DOCKERHUB_USERNAME/github-actions-demo:latest

echo "✅ Docker Hub에 성공적으로 업로드되었습니다!"
echo "이제 어디서든 다음 명령어로 실행할 수 있습니다:"
echo "docker run -p 3000:3000 [YOUR_DOCKERHUB_USERNAME]/github-actions-demo:latest"
```

### 🔧 실습 1-3: GitHub Actions CI 워크플로우 설정

#### 📝 실습 단계

**🎯 이 단계에서 할 일**:
1. GitHub Secrets 설정 ["Docker Hub 인증"]
2. 기본 CI 워크플로우 파일 생성
3. 자동화된 테스트 및 빌드 파이프라인 구축
4. 워크플로우 실행 및 결과 확인

**✅ 실습 완료 기준**:
- [ ] GitHub Secrets가 설정되었음
- [ ] CI 워크플로우 파일이 생성되었음
- [ ] 코드 푸시 시 자동으로 워크플로우가 실행됨
- [ ] 모든 테스트와 빌드가 성공적으로 완료됨

#### 🔐 GitHub Secrets 설정하기

**1단계: Docker Hub Personal Access Token 생성**

**Docker Hub에서 토큰 생성하기**
```bash
# 1. Docker Hub 웹사이트 접속: https://hub.docker.com
# 2. 로그인 후 우상단 프로필 아이콘 클릭
# 3. "Account Settings" 선택
# 4. 왼쪽 메뉴에서 "Personsl access tokens" 클릭
# 5. "New Access Token" 버튼 클릭
# 6. Token Description: "GitHub Actions CI/CD" 입력
# 7. Access permissions: "Read, Write, Delete" 선택
# 8. "Generate" 클릭 후 토큰 복사 ["한 번만 보여줍니다!"]

# 생성된 토큰 예시: dckr_pat_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

**GitHub Secrets에 토큰 등록**
```bash
# GitHub 저장소 페이지에서:
# 1. Settings 탭 클릭
# 2. 왼쪽 메뉴에서 "Secrets and variables" > "Actions" 클릭
# 3. "New repository secret" 클릭
# 4. 다음 시크릿들을 추가:

# DOCKER_USERNAME: Docker Hub 사용자명
# DOCKER_PASSWORD: Docker Hub Personal Access Token ["dckr_pat_로 시작"]

YOUR_DOCKERHUB_USERNAME=<username>
echo $YOUR_DOCKERHUB_USERNAME

# 또는 GitHub CLI로 설정:
gh secret set DOCKER_USERNAME --body  $YOUR_DOCKERHUB_USERNAME
gh secret set DOCKER_PASSWORD --body "dckr_pat_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
```

**💡 Docker Hub Personal Access Token의 장점**
```bash
# 🔒 보안성 향상:
# - 비밀번호 대신 토큰 사용으로 보안 강화
# - 토큰별로 권한 제어 가능
# - 필요시 토큰만 삭제하여 접근 차단 가능

# 🎯 권한 제어:
# - Read: 이미지 다운로드 권한
# - Write: 이미지 업로드 권한  
# - Delete: 이미지 삭제 권한

# 🔄 토큰 관리:
# - 토큰 이름으로 용도 구분 가능
# - 언제든지 토큰 삭제/재생성 가능
# - 토큰 사용 내역 추적 가능

# 📝 토큰 생성 방법 ["2024년 최신"]:
# 1. https://hub.docker.com/settings/security 접속
# 2. "New Access Token" 클릭
# 3. Access Token Description: "GitHub Actions CI/CD"
# 4. Access permissions: "Read, Write, Delete" 선택
# 5. "Generate" 클릭 후 토큰 복사 ["dckr_pat_로 시작"]
# 6. 이 토큰을 DOCKER_PASSWORD로 사용

# ⚠️ 2024년 Docker Hub 정책 변경사항:
# - 무료 계정: 6개월간 비활성 시 이미지 삭제
# - 유료 계정: 무제한 이미지 보관
# - 공개 이미지: 무제한 다운로드
# - 비공개 이미지: 유료 계정 필요
```

**2단계: AWS/GCP 인증 정보 설정 ["선택사항"]**
```bash
# AWS 인증 정보 ["나중에 클라우드 배포용"]
gh secret set AWS_ACCESS_KEY_ID --body "your-aws-access-key"
gh secret set AWS_SECRET_ACCESS_KEY --body "your-aws-secret-key"
gh secret set AWS_REGION --body "ap-northeast-2"

# GCP 인증 정보 ["나중에 클라우드 배포용"]
gh secret set GCP_SERVICE_ACCOUNT_KEY --body "your-gcp-service-account-json"
```

#### 📁 프로젝트 구조 생성 ["왜 이렇게 구성하는가?"]
```bash
# 프로젝트 디렉토리 생성
mkdir github-actions-demo
cd github-actions-demo

# 기본 프로젝트 파일 생성
mkdir -p .github/workflows  # GitHub Actions 워크플로우 파일들
mkdir -p src tests docs     # 소스코드, 테스트, 문서

echo "📁 프로젝트 구조가 생성되었습니다!"
echo "   .github/workflows/  <<<<<<- 여기에 자동화 스크립트를 넣습니다"
echo "   src/                <<<<<<- 실제 애플리케이션 코드"
echo "   tests/              <<<<<<- 테스트 코드"
echo "   docs/               <<<<<<- 문서"
```

**💡 왜 이렇게 구성하나요?**
- `.github/workflows/`: GitHub가 자동으로 인식하는 폴더입니다
- `src/`: 실제 애플리케이션 코드를 깔끔하게 정리
- `tests/`: 테스트 코드를 별도로 관리하여 유지보수 용이
- `docs/`: 프로젝트 문서를 체계적으로 관리

#### 🎯 기본 애플리케이션 생성 ["간단하지만 실용적인 앱"]

**📦 package.json** - 프로젝트의 "신분증" 같은 파일
```json
{
  "name": "github-actions-demo",
  "version": "1.0.0",
  "description": "GitHub Actions CI/CD 실습 프로젝트",
  "main": "src/app.js",
  "scripts": {
    "start": "node src/app.js",        // 앱 실행
    "test": "jest",                    // 테스트 실행
    "lint": "eslint src/",             // 코드 품질 검사
    "build": "echo 'Build completed'"  // 빌드 ["현재는 간단하게"]
  },
  "dependencies": {
    "express": "^4.18.2",              // 웹 서버 프레임워크
    "cors": "^2.8.5"                   // CORS 문제 해결
  },
  "devDependencies": {
    "jest": "^29.7.0",                 // 테스트 프레임워크
    "supertest": "^6.3.3",             // API 테스트 도구
    "eslint": "^8.57.0"                // 코드 품질 검사 도구
  }
}
```

**💡 각 스크립트의 역할:**
- `npm start`: 실제 서버를 실행합니다
- `npm test`: 모든 테스트를 실행해서 코드가 제대로 작동하는지 확인
- `npm run lint`: 코드 스타일과 잠재적 문제를 검사
- `npm run build`: 배포용으로 코드를 준비 ["나중에 더 복잡해질 예정"]

**🚀 src/app.js** - 우리의 첫 번째 웹 애플리케이션
```javascript
const express = require['express'];
const cors = require['cors'];
const app = express();
const port = process.env.PORT || 3000;

// 미들웨어 설정 ["요청이 들어올 때마다 실행되는 코드"]
app.use[cors[]];           // 다른 도메인에서도 접근 가능하게
app.use[express.json[]];   // JSON 데이터를 쉽게 처리

// 🏠 홈페이지 - 사용자가 처음 보게 될 화면
app.get['/', [req, res] => {
  res.json["{
    message: 'GitHub Actions CI/CD 실습 애플리케이션',
    version: '1.0.0',
    timestamp: new Date["].toISOString[],
    environment: process.env.NODE_ENV || 'development'
  }];
}];

// 🏥 헬스 체크 - 서버가 살아있는지 확인하는 엔드포인트
app.get['/health', [req, res] => {
  res.json[{
    status: 'OK',
    uptime: process.uptime[],        // 서버가 얼마나 오래 실행되었는지
    memory: process.memoryUsage[],   // 메모리 사용량
    timestamp: new Date[].toISOString(]
  }];
});

// 📊 API 상태 - 개발자나 모니터링 도구가 사용
app.get['/api/status', [req, res] => {
  res.json[{
    service: 'GitHub Actions CI/CD Practice',
    status: 'running',
    version: '1.0.0'
  }];
}];

// 🚀 서버 시작 ["테스트할 때는 제외"]
if [process.env.NODE_ENV !== 'test'] {
  app.listen[port, [] => {
    console.log["`🚀 서버가 포트 ${port}에서 실행 중입니다.`"];
    console.log["`📊 헬스 체크: http://localhost:${port}/health`"];
  }];
}

module.exports = app;  // 테스트할 때 사용할 수 있도록 내보내기
```

**💡 이 코드가 하는 일:**
1. **웹 서버 시작**: 3000번 포트에서 HTTP 요청을 받을 준비
2. **3개의 엔드포인트 제공**:
   - `/`: 메인 페이지 ["사용자용"]
   - `/health`: 서버 상태 확인 ["모니터링용"]
   - `/api/status`: API 상태 확인 ["개발자용"]
3. **테스트 친화적**: `module.exports`로 테스트할 수 있게 설계

#### 🤖 첫 번째 CI 워크플로우 생성 ["자동화의 시작!"]

**📖 스토리**: 이제 진짜 자동화를 시작해봅시다! 코드를 GitHub에 올릴 때마다 자동으로 테스트하고 빌드하는 "로봇"을 만들어보겠습니다.

**🎯 목표**: 
- 코드를 올릴 때마다 자동으로 테스트 실행
- 여러 버전의 Node.js에서 테스트 [16, 18, 20]
- 코드 품질 검사 ["린팅"]
- 보안 취약점 검사
- 빌드가 성공하면 배포 준비 완료

#### 📝 워크플로우 파일 생성하기

**1단계: 워크플로우 파일 생성**
```bash
# .github/workflows 디렉토리에 워크플로우 파일 생성
mkdir -p .github/workflows

# 첫 번째 CI 워크플로우 파일 생성
touch .github/workflows/ci.yml

echo "✅ 워크플로우 파일이 생성되었습니다!"
echo "   .github/workflows/ci.yml  <<<<<<- 여기에 자동화 스크립트를 작성합니다"
```

**2단계: 워크플로우 파일 작성**
```bash
# 파일 편집기로 워크플로우 파일 열기
code .github/workflows/ci.yml
# 또는
nano .github/workflows/ci.yml
# 또는
vim .github/workflows/ci.yml
```

**.github/workflows/ci.yml** - 우리의 첫 번째 자동화 스크립트
```yaml
name: CI Pipeline  # 이 워크플로우의 이름

# 🎯 언제 실행할까? ["트리거 설정"]
on:
  push:
    branches: [ main, develop ]  # main, develop 브랜치에 코드를 올릴 때
  pull_request:
    branches: [ main ]           # main 브랜치로 PR을 올릴 때

env:
  NODE_VERSION: '18'  # 기본 Node.js 버전

jobs:
  # 🧪 1단계: 테스트 실행 ["가장 중요!"]
  test:
    name: 테스트 실행
    runs-on: ubuntu-latest  # Ubuntu 환경에서 실행
    
    strategy:
      matrix:
        node-version: [16, 18, 20]  # 3개 버전에서 모두 테스트
    
    steps:
    - name: 코드 체크아웃
      uses: actions/checkout@v4  # GitHub에서 코드를 가져오기
      
    - name: Node.js ${{ matrix.node-version }} 설정
      uses: actions/setup-node@v4
      with:
        node-version: ${{ matrix.node-version }}
        cache: 'npm'  # npm 캐시 사용으로 속도 향상
        
    - name: 의존성 설치
      run: npm ci  # package-lock.json 기반으로 정확한 버전 설치
      
    - name: prom-client 모듈 설치 ["필수"]
      run: npm install prom-client
      
    - name: 린팅 실행
      run: npm run lint  # 코드 스타일 검사
      
    - name: 테스트 실행
      run: npm test  # 실제 테스트 실행
      
    - name: 테스트 결과 업로드
      uses: actions/upload-artifact@v4
      if: always()  # 테스트가 실패해도 결과 저장
      with:
        name: test-results-node-${{ matrix.node-version }}
        path: test-results/
        retention-days: 30

  # 🏗️ 2단계: 애플리케이션 빌드
  build:
    name: 애플리케이션 빌드
    runs-on: ubuntu-latest
    needs: test  # 테스트가 성공한 후에만 실행
    
    steps:
    - name: 코드 체크아웃
      uses: actions/checkout@v4
      
    - name: Node.js 설정
      uses: actions/setup-node@v4
      with:
        node-version: ${{ env.NODE_VERSION }}
        cache: 'npm'
        
    - name: 의존성 설치
      run: npm ci
      
    - name: prom-client 모듈 설치 ["필수"]
      run: npm install prom-client
      
    - name: 애플리케이션 빌드
      run: npm run build
      
    - name: 빌드 아티팩트 업로드
      uses: actions/upload-artifact@v4
      with:
        name: build-artifacts
        path: |
          src/
          package.json
          package-lock.json
        retention-days: 30

  # 🔒 3단계: 보안 스캔 ["안전성 확인"]
  security-scan:
    name: 보안 스캔
    runs-on: ubuntu-latest
    needs: test  # 테스트가 성공한 후에만 실행
    
    steps:
    - name: 코드 체크아웃
      uses: actions/checkout@v4
      
    - name: Node.js 설정
      uses: actions/setup-node@v4
      with:
        node-version: ${{ env.NODE_VERSION }}
        cache: 'npm'
        
    - name: 의존성 설치
      run: npm ci
      
    - name: prom-client 모듈 설치 ["필수"]
      run: npm install prom-client
      
    - name: 보안 취약점 스캔
      run: npm audit --audit-level moderate
      
    - name: 의존성 취약점 스캔
      run: npx audit-ci --moderate
      
    - name: 취약점 자동 수정 시도
      run: npm audit fix
      continue-on-error: true
```

**💡 이 워크플로우가 하는 일:**
1. **코드 변경 감지**: main/develop 브랜치에 코드가 올라가면 자동 실행
2. **다중 버전 테스트**: Node.js 16, 18, 20에서 모두 테스트
3. **품질 검사**: 코드 스타일과 잠재적 문제 검사
4. **보안 검사**: 사용하는 라이브러리의 보안 취약점 검사
5. **빌드 준비**: 모든 검사가 통과하면 배포용 파일 준비

#### 🧪 첫 번째 워크플로우 테스트하기

**3단계: 워크플로우 파일 커밋 및 푸시**
```bash
# 워크플로우 파일을 Git에 추가
git add .github/workflows/ci.yml

# 커밋 메시지 작성
git commit -m "🤖 Add CI workflow: 자동 테스트 및 빌드 파이프라인 추가"

# GitHub에 푸시
git push origin main

echo "✅ 워크플로우가 GitHub에 업로드되었습니다!"
echo "이제 GitHub Actions가 자동으로 실행됩니다!"
```

**4단계: GitHub Actions 실행 확인**
```bash
# GitHub CLI로 Actions 상태 확인
gh run list

# 또는 웹 브라우저에서 확인:
# 1. GitHub 저장소 페이지 접속
# 2. "Actions" 탭 클릭
# 3. 실행 중인 워크플로우 확인
# 4. 각 단계별 로그 확인

echo "🔍 Actions 탭에서 워크플로우 실행 상태를 확인해보세요!"
```

**5단계: 워크플로우 실행 결과 확인**
```bash
# 워크플로우 실행 로그 확인
gh run view [RUN_ID]

# 특정 워크플로우의 로그 확인
gh run view --log

echo "📊 워크플로우 실행 결과:"
echo "   ✅ 성공: 모든 테스트가 통과했습니다!"
echo "   ❌ 실패: 로그를 확인하여 문제를 해결하세요"
echo "   ⏳ 진행중: 워크플로우가 실행 중입니다"
```

**6단계: 문제 해결 ["실패한 경우"]**
```bash
# 워크플로우 실행 로그에서 오류 확인
gh run view --log

# 일반적인 문제들:
# 1. package.json 파일이 없음 ->> npm init 실행
# 2. package.json JSON 구문 오류 ->> JavaScript 주석[//] 제거
# 3. package-lock.json 파일이 없음 ->> npm install 실행
# 4. 테스트 파일이 없음 ->> 기본 테스트 파일 생성
# 5. 린팅 설정이 없음 ->> ESLint 설정 파일 생성
# 6. Docker BuildKit 오류 ->> export DOCKER_BUILDKIT=0 실행
# 7. Docker buildx 누락 ->> docker buildx install 실행

echo "🔧 문제가 있다면 로그를 확인하고 수정해보세요!"
```

**🐳 Docker 관련 문제 해결**
```bash
# BuildKit 오류 해결
export DOCKER_BUILDKIT=0
docker build -t github-actions-demo:latest .

# package-lock.json 누락 오류 해결
npm install
ls -la package*.json

# Docker buildx 설치
docker buildx install
docker buildx create --use

# Docker 버전 확인
docker --version
docker-compose --version

# Docker 서비스 상태 확인
sudo systemctl status docker

# Docker 빌드 재시도
docker build -t github-actions-demo:latest .
```

## 🚀 실습 2: 고급 CI/CD 파이프라인 구축

### 📖 실습 시나리오: "멀티스테이지 빌드와 자동 배포"

**🎯 실습 목표**:
- 멀티스테이지 Dockerfile 생성
- Docker 이미지 자동 빌드 및 푸시
- 환경별 배포 파이프라인 구축
- 모니터링 및 알림 시스템 설정

**⏱️ 예상 소요 시간**: 90-120분

**📋 실습 전 준비사항**:
- [ ] 실습 1 완료
- [ ] AWS/GCP 계정 설정
- [ ] 클라우드 인증 정보 준비

### 🔧 실습 2-1: 멀티스테이지 Dockerfile 생성

#### 📝 실습 단계

**🎯 이 단계에서 할 일**:
1. 고급 멀티스테이지 Dockerfile 생성
2. 이미지 크기 최적화
3. 보안 강화 설정
4. 빌드 성능 최적화

**✅ 실습 완료 기준**:
- [ ] 멀티스테이지 Dockerfile이 생성되었음
- [ ] 이미지 크기가 최적화되었음
- [ ] 보안 설정이 적용되었음

#### 🏗️ Dockerfile 생성 ["애플리케이션을 컨테이너로 포장하기"]

**Dockerfile** - 우리 앱을 위한 "레시피"
```dockerfile
# 🏗️ 1단계: 빌드 환경 준비 ["멀티스테이지 빌드"]
FROM node:18-alpine AS builder
# 왜 alpine? ->> 매우 가벼운 Linux 배포판 ["보안성 + 속도"]

# 작업 디렉토리 설정
WORKDIR /app

# 패키지 파일만 먼저 복사 ["캐시 최적화"]
COPY package*.json ./

# 의존성 설치 ["package-lock.json이 있으면 ci, 없으면 install"]
RUN if [ -f package-lock.json ]; then \
        npm ci --omit=dev && npm cache clean --force; \
    else \
        npm install --omit=dev && npm cache clean --force; \
    fi

# 🚀 2단계: 런타임 환경 ["실제 실행용"]
FROM node:18-alpine AS runtime

# 🔒 보안을 위한 비root 사용자 생성
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nextjs -u 1001
# 왜 비root? ->> 보안상 root 권한으로 실행하면 위험

# 작업 디렉토리 설정
WORKDIR /app

# 의존성 복사 ["빌드 단계에서 가져오기"]
COPY --from=builder /app/node_modules ./node_modules

# 소스 코드 복사 ["소유자 변경"]
COPY --chown=nextjs:nodejs . .

# 사용자 변경 ["보안"]
USER nextjs

# 포트 노출 ["외부에서 접근 가능하게"]
EXPOSE 3000

# 🏥 헬스 체크 ["컨테이너가 살아있는지 확인"]
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD node -e "require['http'].get['http://localhost:3000/health', [res] => { process.exit[res.statusCode === 200 ? 0 : 1] }]"

# 🚀 애플리케이션 시작
CMD ["node", "src/app.js"]
```

**💡 이 Dockerfile이 하는 일:**
1. **멀티스테이지 빌드**: 빌드용 환경과 실행용 환경을 분리하여 이미지 크기 최적화
2. **보안 강화**: 비root 사용자로 실행하여 보안 위험 최소화
3. **캐시 최적화**: package.json을 먼저 복사하여 의존성 변경 시에만 재빌드
4. **헬스 체크**: 컨테이너가 정상 작동하는지 자동으로 확인
5. **경량화**: Alpine Linux 사용으로 이미지 크기 최소화

#### 🤖 Docker 이미지 자동 빌드 워크플로우 ["컨테이너 자동화!"]

**📖 스토리**: 이제 우리의 애플리케이션을 Docker 이미지로 만들어서 Docker Hub에 자동으로 업로드하는 시스템을 만들어봅시다. 이렇게 하면 어디서든 우리의 앱을 쉽게 실행할 수 있습니다!

**🎯 목표**:
- 코드가 변경될 때마다 자동으로 Docker 이미지 빌드
- 여러 플랫폼[AMD64, ARM64]에서 빌드하여 호환성 확보
- Docker Hub에 자동으로 업로드하여 배포 준비
- 이미지 보안 스캔으로 안전성 확보

**.github/workflows/docker-build.yml** - Docker 자동화 스크립트
```yaml
name: Docker Build and Push  # 워크플로우 이름

# 🎯 언제 실행할까?
on:
  push:
    branches: [ main ]        # main 브랜치에 코드를 올릴 때
    tags: [ 'v*' ]           # v1.0.0 같은 태그를 만들 때
  pull_request:
    branches: [ main ]       # main 브랜치로 PR을 올릴 때

env:
  REGISTRY: docker.io        # Docker Hub 사용
  IMAGE_NAME: ${{ github.repository }}  # GitHub 저장소명을 이미지명으로

jobs:
  build:
    name: Docker 이미지 빌드 및 푸시
    runs-on: ubuntu-latest
    
    steps:
    - name: 코드 체크아웃
      uses: actions/checkout@v4  # GitHub에서 코드 가져오기
      
    - name: Docker Buildx 설정
      uses: docker/setup-buildx-action@v3
      # Buildx: 여러 플랫폼에서 빌드할 수 있는 고급 도구
      
    - name: Docker Hub 로그인
      uses: docker/login-action@v3
      with:
        username: ${{ secrets.DOCKER_USERNAME }}    # Docker Hub 사용자명
        password: ${{ secrets.DOCKER_PASSWORD }}    # Docker Hub Personal Access Token
        # GitHub Secrets에 저장된 인증 정보 사용
        
    - name: 메타데이터 추출
      id: meta
      uses: docker/metadata-action@v5
      with:
        images: ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}
        tags: |
          type=ref,event=branch                    # 브랜치명으로 태그 생성
          type=ref,event=pr                        # PR 번호로 태그 생성
          type=semver,pattern={{version}}          # 버전 태그 [v1.0.0]
          type=semver,pattern={{major}}.{{minor}}  # 메이저.마이너 태그 [v1.0]
          type=raw,value=latest,enable={{is_default_branch}}  # latest 태그
          
    - name: 이미지 빌드 및 푸시
      uses: docker/build-push-action@v5
      with:
        context: .                    # 현재 디렉토리를 빌드 컨텍스트로
        push: true                    # Docker Hub에 푸시
        tags: ${{ steps.meta.outputs.tags }}      # 위에서 생성한 태그들
        labels: ${{ steps.meta.outputs.labels }}  # 이미지 라벨
        cache-from: type=gha          # GitHub Actions 캐시 사용
        cache-to: type=gha,mode=max   # 빌드 캐시 저장
        platforms: linux/amd64,linux/arm64  # 두 플랫폼에서 빌드
        build-args: |
          NODE_ENV=production
          BUILD_DATE=${{ github.event.head_commit.timestamp }}
          VCS_REF=${{ github.sha }}
        
    - name: 이미지 보안 스캔
      uses: aquasecurity/trivy-action@master
      with:
        image-ref: ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:${{ github.sha }}
        format: 'sarif'               # 보안 스캔 결과 형식
        output: 'trivy-results.sarif' # 결과 파일명
        severity: 'HIGH,CRITICAL'     # 높은 심각도만 스캔
        
    - name: 보안 스캔 결과 업로드
      uses: github/codeql-action/upload-sarif@v2
      with:
        sarif_file: 'trivy-results.sarif'  # GitHub에 보안 결과 업로드
        
    - name: 이미지 크기 최적화 확인
      run: |
        echo "=== 이미지 크기 확인 ==="
        docker images ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }} --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}"
        
    - name: 이미지 실행 테스트
      run: |
        echo "=== 이미지 실행 테스트 ==="
        docker run --rm -d --name test-container -p 3000:3000 ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:latest
        sleep 10
        curl -f http://localhost:3000/health || exit 1
        docker stop test-container
        echo "✅ 이미지 실행 테스트 성공"
```

**💡 이 워크플로우가 하는 일:**
1. **자동 빌드**: 코드 변경 시 자동으로 Docker 이미지 생성
2. **다중 플랫폼**: AMD64와 ARM64에서 모두 빌드하여 호환성 확보
3. **스마트 태깅**: 브랜치, PR, 버전에 따라 적절한 태그 자동 생성
4. **캐시 최적화**: 이전 빌드 결과를 재사용하여 빌드 속도 향상
5. **보안 스캔**: 빌드된 이미지의 보안 취약점 자동 검사
6. **자동 배포**: Docker Hub에 업로드하여 어디서든 사용 가능

#### 🧪 Docker 빌드 워크플로우 테스트하기

**1단계: Docker 빌드 워크플로우 파일 생성**
```bash
# Docker 빌드 워크플로우 파일 생성
touch .github/workflows/docker-build.yml

echo "✅ Docker 빌드 워크플로우 파일이 생성되었습니다!"
```

**2단계: 워크플로우 파일 커밋 및 푸시**
```bash
# 워크플로우 파일을 Git에 추가
git add .github/workflows/docker-build.yml

# 커밋 메시지 작성
git commit -m "🐳 Add Docker build workflow: 자동 Docker 이미지 빌드 및 푸시"

# GitHub에 푸시
git push origin main

echo "✅ Docker 빌드 워크플로우가 GitHub에 업로드되었습니다!"
```

**3단계: Docker Hub에 이미지가 업로드되었는지 확인**
```bash
# Docker Hub에서 이미지 확인
docker pull [YOUR_DOCKERHUB_USERNAME]/github-actions-demo:latest

# 로컬에서 실행 테스트
docker run -d -p 3000:3000 --name test-ci-app [YOUR_DOCKERHUB_USERNAME]/github-actions-demo:latest

# 애플리케이션 동작 확인
curl http://localhost:3000/health

# 테스트 완료 후 정리
docker stop test-ci-app
docker rm test-ci-app

echo "🎉 GitHub Actions로 빌드된 Docker 이미지가 성공적으로 실행되었습니다!"
```

**4단계: GitHub Actions에서 빌드 상태 확인**
```bash
# Actions 실행 상태 확인
gh run list --workflow="Docker Build and Push"

# 특정 워크플로우의 상세 로그 확인
gh run view [RUN_ID] --log

echo "📊 Docker 빌드 결과:"
echo "   ✅ 성공: Docker Hub에 이미지가 업로드되었습니다!"
echo "   ❌ 실패: 로그를 확인하여 문제를 해결하세요"
echo "   ⏳ 진행중: Docker 이미지 빌드 중입니다"
```

### 🚀 3단계: VM 자동 배포 ["클라우드에 자동으로 배포하기!"]

#### 📖 스토리: "이제 진짜 서버에 배포해보자!"

**상황**: 우리의 애플리케이션이 Docker 이미지로 만들어졌습니다. 이제 이걸 실제 클라우드 서버에 배포해서 전 세계 사람들이 사용할 수 있게 만들어봅시다!

**목표**: 
- AWS EC2와 GCP Compute Engine에 자동으로 배포
- 코드가 변경되면 자동으로 서버에 반영
- 배포 상태를 실시간으로 모니터링
- "한 번의 클릭"으로 배포 완료!

#### 🤖 VM 배포 워크플로우 ["클라우드 자동 배포!"]

**.github/workflows/deploy-vm.yml** - 클라우드 자동 배포 스크립트
```yaml
name: Deploy to VM

on:
  push:
    branches: [ main ]
  workflow_dispatch:
    inputs:
      environment:
        description: '배포 환경 선택'
        required: true
        default: 'staging'
        type: choice
        options:
        - staging
        - production

env:
  DEPLOY_ENV: ${{ github.ref == 'refs/heads/main' && 'production' || 'staging' }}

jobs:
  deploy-aws:
    name: AWS EC2 배포
    runs-on: ubuntu-latest
    environment: ${{ env.DEPLOY_ENV }}
    
    steps:
    - name: 코드 체크아웃
      uses: actions/checkout@v4
      
    - name: AWS 자격증명 설정
      uses: aws-actions/configure-aws-credentials@v4
      with:
        aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
        aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        aws-region: us-west-2
        
    - name: AWS EC2 배포
      uses: appleboy/ssh-action@v1.0.3
      with:
        host: ${{ secrets.AWS_HOST }}
        username: ${{ secrets.AWS_USERNAME }}
        key: ${{ secrets.AWS_SSH_KEY }}
        script: |
          # 애플리케이션 디렉토리로 이동
          cd /opt/github-actions-demo
          
          # 최신 코드 가져오기
          git pull origin main
          
          # Docker 이미지 빌드
          docker build -t github-actions-demo:latest .
          
          # 기존 컨테이너 중지
          docker-compose down
          
          # 새 컨테이너 시작
          docker-compose up -d --build
          
          # 배포 상태 확인
          docker ps
          curl -f http://localhost:3000/health || exit 1
          
    - name: 배포 상태 확인
      run: |
        echo "AWS EC2 배포 완료"
        echo "환경: ${{ env.DEPLOY_ENV }}"
        echo "시간: $[date]"

  deploy-gcp:
    name: GCP Compute Engine 배포
    runs-on: ubuntu-latest
    environment: ${{ env.DEPLOY_ENV }}
    
    steps:
    - name: 코드 체크아웃
      uses: actions/checkout@v4
      
    - name: GCP 자격증명 설정
      uses: google-github-actions/auth@v2
      with:
        credentials_json: ${{ secrets.GCP_SERVICE_ACCOUNT_KEY }}
        
    - name: GCP Compute Engine 배포
      uses: appleboy/ssh-action@v1.0.3
      with:
        host: ${{ secrets.GCP_HOST }}
        username: ${{ secrets.GCP_USERNAME }}
        key: ${{ secrets.GCP_SSH_KEY }}
        script: |
          # 애플리케이션 디렉토리로 이동
          cd /opt/github-actions-demo
          
          # 최신 코드 가져오기
          git pull origin main
          
          # Docker 이미지 빌드
          docker build -t github-actions-demo:latest .
          
          # 기존 컨테이너 중지
          docker-compose down
          
          # 새 컨테이너 시작
          docker-compose up -d --build
          
          # 배포 상태 확인
          docker ps
          curl -f http://localhost:3000/health || exit 1
          
    - name: 배포 상태 확인
      run: |
        echo "GCP Compute Engine 배포 완료"
        echo "환경: ${{ env.DEPLOY_ENV }}"
        echo "시간: $[date]"
```

---

## 🚀 Day 2: 고급 CI/CD 파이프라인 ["전문가 수준으로!"]

### 📖 스토리: "이제 진짜 프로처럼 CI/CD를 다뤄보자!"

**상황**: 기본적인 CI/CD는 잘 작동하고 있습니다. 하지만 팀이 커지고 프로젝트가 복잡해지면서 더 고급 기능이 필요해졌습니다. 

**새로운 도전들**:
- 여러 환경["개발, 스테이징, 프로덕션"]에 동시에 배포
- 다양한 운영체제와 Node.js 버전에서 테스트
- 코드 변경사항에 따라 선택적으로 배포
- Kubernetes 클러스터에 자동 배포

**목표**: 전문 DevOps 엔지니어 수준의 고급 CI/CD 파이프라인 구축

### 📋 고급 기능 구현

#### 🎯 매트릭스 빌드 및 환경별 배포 ["다양성의 힘!"]
**.github/workflows/advanced-cicd.yml**
```yaml
name: Advanced CI/CD Pipeline

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]
  workflow_dispatch:
    inputs:
      cloud_provider:
        description: '클라우드 프로바이더 선택'
        required: true
        default: 'aws'
        type: choice
        options:
        - aws
        - gcp
        - both
      skill_level:
        description: '실습 난이도'
        required: true
        default: '중급'
        type: choice
        options:
        - 초급
        - 중급
        - 고급

env:
  AWS_REGION: us-west-2
  GCP_REGION: us-central1
  GCP_ZONE: us-central1-a

jobs:
  # 1. 환경 검증
  environment-check:
    name: 환경 검증
    runs-on: ubuntu-latest
    outputs:
      environment-ok: ${{ steps.check.outputs.environment-ok }}
    steps:
    - name: 코드 체크아웃
      uses: actions/checkout@v4
      
    - name: 필수 도구 설치
      run: |
        sudo apt-get update
        sudo apt-get install -y curl wget git unzip jq
        
    - name: 환경 체크
      id: check
      run: |
        # Docker 설치 확인
        if ! command -v docker &> /dev/null; then
          echo "❌ Docker가 설치되지 않았습니다."
          echo "environment-ok=false" >> $GITHUB_OUTPUT
          exit 1
        fi
        
        # AWS CLI 설치 확인
        if ! command -v aws &> /dev/null; then
          echo "❌ AWS CLI가 설치되지 않았습니다."
          echo "environment-ok=false" >> $GITHUB_OUTPUT
          exit 1
        fi
        
        # GCP CLI 설치 확인
        if ! command -v gcloud &> /dev/null; then
          echo "❌ GCP CLI가 설치되지 않았습니다."
          echo "environment-ok=false" >> $GITHUB_OUTPUT
          exit 1
        fi
        
        echo "✅ 모든 필수 도구가 설치되어 있습니다."
        echo "environment-ok=true" >> $GITHUB_OUTPUT

  # 2. 매트릭스 테스트
  matrix-test:
    name: 매트릭스 테스트
    runs-on: ubuntu-latest
    needs: environment-check
    if: ${{ needs.environment-check.outputs.environment-ok == 'true' }}
    
    strategy:
      matrix:
        node-version: [16, 18, 20]
        os: [ubuntu-latest, windows-latest, macos-latest]
        exclude:
          - node-version: 16
            os: windows-latest
          - node-version: 20
            os: macos-latest
    
    steps:
    - name: 코드 체크아웃
      uses: actions/checkout@v4
      
    - name: Node.js ${{ matrix.node-version }} 설정
      uses: actions/setup-node@v4
      with:
        node-version: ${{ matrix.node-version }}
        cache: 'npm'
        
    - name: 의존성 설치
      run: npm ci
      
    - name: 테스트 실행
      run: npm test
      
    - name: 테스트 결과 업로드
      uses: actions/upload-artifact@v4
      if: always()
      with:
        name: test-results-${{ matrix.os }}-node-${{ matrix.node-version }}
        path: test-results/
        retention-days: 30

  # 3. 조건부 배포
  conditional-deploy:
    name: 조건부 배포
    runs-on: ubuntu-latest
    needs: [environment-check, matrix-test]
    if: ${{ needs.environment-check.outputs.environment-ok == 'true' && needs.matrix-test.result == 'success' }}
    
    steps:
    - name: 코드 체크아웃
      uses: actions/checkout@v4
      
    - name: 변경사항 확인
      uses: dorny/paths-filter@v2
      id: changes
      with:
        filters: |
          frontend:
            - 'src/**'
            - 'public/**'
          backend:
            - 'src/**'
            - 'package.json'
          docs:
            - 'docs/**'
            - '*.md'
            
    - name: 프론트엔드 배포
      if: ${{ steps.changes.outputs.frontend == 'true' }}
      run: |
        echo "프론트엔드 변경사항 감지 - 프론트엔드 배포 실행"
        # 프론트엔드 배포 로직
        
    - name: 백엔드 배포
      if: ${{ steps.changes.outputs.backend == 'true' }}
      run: |
        echo "백엔드 변경사항 감지 - 백엔드 배포 실행"
        # 백엔드 배포 로직
        
    - name: 문서 배포
      if: ${{ steps.changes.outputs.docs == 'true' }}
      run: |
        echo "문서 변경사항 감지 - 문서 배포 실행"
        # 문서 배포 로직

  # 4. Kubernetes 배포
  kubernetes-deploy:
    name: Kubernetes 배포
    runs-on: ubuntu-latest
    needs: [environment-check, matrix-test]
    if: ${{ needs.environment-check.outputs.environment-ok == 'true' && needs.matrix-test.result == 'success' }}
    
    steps:
    - name: 코드 체크아웃
      uses: actions/checkout@v4
      
    - name: AWS EKS 클러스터 연결
      if: ${{ github.event.inputs.cloud_provider == 'aws' || github.event.inputs.cloud_provider == 'both' }}
      run: |
        aws eks update-kubeconfig --region ${{ env.AWS_REGION }} --name my-eks-cluster
        
    - name: GCP GKE 클러스터 연결
      if: ${{ github.event.inputs.cloud_provider == 'gcp' || github.event.inputs.cloud_provider == 'both' }}
      run: |
        gcloud container clusters get-credentials my-gke-cluster --zone ${{ env.GCP_ZONE }}
        
    - name: Kubernetes 매니페스트 적용
      run: |
        kubectl apply -f k8s/
        
    - name: 배포 상태 확인
      run: |
        kubectl get pods
        kubectl get services
        kubectl get deployments
```

---

## 🚀 Day 3: 모니터링 및 최적화 ["시스템을 지켜보는 눈!"]

### 📖 스토리: "배포는 했는데... 잘 돌아가고 있을까?"

**상황**: 애플리케이션이 성공적으로 배포되었습니다! 하지만 이제 진짜 일이 시작됩니다. 

**우려사항들**:
- 서버가 갑자기 다운되면 어떻게 알 수 있을까?
- 사용자가 많아져서 성능이 느려지면?
- 보안 취약점이 생기면?
- 비용이 예상보다 많이 나오면?

**목표**: 24시간 365일 안정적으로 서비스를 운영할 수 있는 모니터링 시스템 구축

### 📊 모니터링 시스템 구축

#### 🤖 모니터링 워크플로우 ["시스템의 건강을 지켜보는 로봇!"]
**.github/workflows/monitoring.yml**
```yaml
name: Monitoring and Optimization

on:
  schedule:
    # 매일 오전 9시에 모니터링 실행
    - cron: '0 9 * * *'
  workflow_dispatch:
    inputs:
      monitoring_type:
        description: '모니터링 유형 선택'
        required: true
        default: 'full'
        type: choice
        options:
        - full
        - basic
        - security

jobs:
  # 1. 애플리케이션 모니터링
  app-monitoring:
    name: 애플리케이션 모니터링
    runs-on: ubuntu-latest
    
    steps:
    - name: 코드 체크아웃
      uses: actions/checkout@v4
      
    - name: 애플리케이션 상태 확인
      run: |
        # AWS EC2 상태 확인
        aws ec2 describe-instances --query 'Reservations[*].Instances[*].[InstanceId,State.Name,PublicIpAddress]' --output table
        
        # GCP Compute Engine 상태 확인
        gcloud compute instances list --format="table[name,zone,machineType,status]"
        
    - name: 애플리케이션 헬스 체크
      run: |
        # AWS 애플리케이션 헬스 체크
        curl -f http://${{ secrets.AWS_HOST }}/health || echo "AWS 애플리케이션 상태 확인 실패"
        
        # GCP 애플리케이션 헬스 체크
        curl -f http://${{ secrets.GCP_HOST }}/health || echo "GCP 애플리케이션 상태 확인 실패"

  # 2. 보안 모니터링
  security-monitoring:
    name: 보안 모니터링
    runs-on: ubuntu-latest
    
    steps:
    - name: 코드 체크아웃
      uses: actions/checkout@v4
      
    - name: 보안 취약점 스캔
      run: |
        # 의존성 보안 스캔
        npm audit --audit-level moderate
        
        # Docker 이미지 보안 스캔
        docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
          aquasec/trivy image github-actions-demo:latest
        
    - name: AWS 보안 스캔
      run: |
        # AWS Inspector 스캔
        aws inspector list-assessment-templates
        
    - name: GCP 보안 스캔
      run: |
        # GCP Security Command Center 스캔
        gcloud scc sources list

  # 3. 비용 최적화
  cost-optimization:
    name: 비용 최적화
    runs-on: ubuntu-latest
    
    steps:
    - name: 코드 체크아웃
      uses: actions/checkout@v4
      
    - name: AWS 비용 분석
      run: |
        # AWS Cost Explorer 사용
        aws ce get-cost-and-usage \
          --time-period Start=2024-01-01,End=2024-01-31 \
          --granularity MONTHLY \
          --metrics BlendedCost
          
    - name: GCP 비용 분석
      run: |
        # GCP 청구서 정보 조회
        gcloud billing accounts list
        
    - name: 비용 최적화 권장사항
      run: |
        echo "비용 최적화 권장사항:"
        echo "1. 사용하지 않는 리소스 정리"
        echo "2. 인스턴스 크기 최적화"
        echo "3. 예약 인스턴스 사용 고려"

  # 4. 성능 모니터링
  performance-monitoring:
    name: 성능 모니터링
    runs-on: ubuntu-latest
    
    steps:
    - name: 코드 체크아웃
      uses: actions/checkout@v4
      
    - name: 애플리케이션 성능 테스트
      run: |
        # 부하 테스트 실행
        npm install -g artillery
        artillery quick --count 10 --num 5 http://${{ secrets.AWS_HOST }}/
        
    - name: 데이터베이스 성능 확인
      run: |
        # 데이터베이스 연결 상태 확인
        echo "데이터베이스 성능 모니터링 완료"
        
    - name: 네트워크 성능 확인
      run: |
        # 네트워크 지연시간 측정
        ping -c 5 ${{ secrets.AWS_HOST }}
        ping -c 5 ${{ secrets.GCP_HOST }}

  # 5. 알림 및 보고서
  notification:
    name: 알림 및 보고서
    runs-on: ubuntu-latest
    needs: [app-monitoring, security-monitoring, cost-optimization, performance-monitoring]
    if: always()
    
    steps:
    - name: 모니터링 결과 수집
      run: |
        echo "모니터링 결과 수집 중..."
        
    - name: Slack 알림 전송
      if: ${{ secrets.SLACK_WEBHOOK_URL }}
      uses: 8398a7/action-slack@v3
      with:
        status: ${{ job.status }}
        channel: '#monitoring'
        text: |
          GitHub Actions CI/CD 모니터링 완료
          - 애플리케이션 모니터링: ${{ needs.app-monitoring.result }}
          - 보안 모니터링: ${{ needs.security-monitoring.result }}
          - 비용 최적화: ${{ needs.cost-optimization.result }}
          - 성능 모니터링: ${{ needs.performance-monitoring.result }}
          
    - name: 이메일 보고서 전송
      if: ${{ secrets.EMAIL_NOTIFICATION }}
      uses: dawidd6/action-send-mail@v3
      with:
        server_address: smtp.gmail.com
        server_port: 587
        username: ${{ secrets.EMAIL_USERNAME }}
        password: ${{ secrets.EMAIL_PASSWORD }}
        subject: GitHub Actions CI/CD 모니터링 보고서
        to: ${{ secrets.EMAIL_NOTIFICATION }}
        from: GitHub Actions
        body: |
          GitHub Actions CI/CD 모니터링이 완료되었습니다.
          
          결과:
          - 애플리케이션 모니터링: ${{ needs.app-monitoring.result }}
          - 보안 모니터링: ${{ needs.security-monitoring.result }}
          - 비용 최적화: ${{ needs.cost-optimization.result }}
          - 성능 모니터링: ${{ needs.performance-monitoring.result }}
```

---

## 🔍 스크립트 수행 후 필수 체크 사항

### 📋 실습 완료 후 검증 체크리스트

#### 1. 환경 설정 검증
```bash
# 필수 도구 설치 확인
echo "=== 필수 도구 설치 확인 ==="
docker --version
docker-compose --version
node --version
npm --version
git --version
gh --version

# 환경 변수 로드 확인
echo "=== 환경 변수 확인 ==="
if [ -f .env ]; then
    echo "✅ .env 파일 존재"
    source .env
    echo "NODE_ENV: $NODE_ENV"
    echo "PORT: $PORT"
else
    echo "❌ .env 파일 없음"
fi
```

#### 2. GitHub Actions 워크플로우 검증
```bash
# 워크플로우 파일 존재 확인
echo "=== 워크플로우 파일 확인 ==="
ls -la .github/workflows/

# 워크플로우 실행 상태 확인
echo "=== 워크플로우 실행 상태 ==="
gh run list --limit 10

# 최근 실행 결과 확인
echo "=== 최근 실행 결과 ==="
gh run view --log
```

#### 3. Docker 이미지 빌드 검증
```bash
# Docker 이미지 확인
echo "=== Docker 이미지 확인 ==="
docker images | grep github-actions-demo

# 이미지별 상태 확인
echo "=== 이미지별 상태 확인 ==="
for tag in latest dev test multistage; do
    if docker images | grep -q "github-actions-demo.*$tag"; then
        echo "✅ github-actions-demo:$tag 이미지 존재"
        size=$[docker images --format "table {{.Size}}" github-actions-demo:$tag | tail -n 1]
        echo "   크기: $size"
    else
        echo "❌ github-actions-demo:$tag 이미지 없음"
    fi
done
```

#### 4. 애플리케이션 응답 검증
```bash
# 애플리케이션 엔드포인트 테스트
echo "=== 애플리케이션 응답 테스트 ==="

# 홈페이지 응답 확인
echo "홈페이지 응답 확인..."
if curl -s http://localhost:3000/ > /dev/null; then
    echo "✅ 홈페이지 응답 정상"
    response=$[curl -s http://localhost:3000/]
    if echo "$response" | grep -q "GitHub Actions"; then
        echo "   ✅ 응답 내용 정상"
    else
        echo "   ❌ 응답 내용 이상"
    fi
else
    echo "❌ 홈페이지 응답 실패"
fi

# 헬스 체크 확인
echo "헬스 체크 확인..."
if curl -s http://localhost:3000/health > /dev/null; then
    echo "✅ 헬스 체크 정상"
    health=$[curl -s http://localhost:3000/health]
    echo "   상태: $["echo $health | jq -r '.status' 2>/dev/null || echo 'JSON 파싱 실패'"]"
else
    echo "❌ 헬스 체크 실패"
fi
```

#### 5. 보안 스캔 결과 확인
```bash
# npm audit 결과 확인
echo "=== 보안 취약점 스캔 ==="
audit_result=$[npm audit --audit-level moderate 2>&1]
if echo "$audit_result" | grep -q "found 0 vulnerabilities"; then
    echo "✅ 보안 취약점 없음"
else
    echo "⚠️ 보안 취약점 발견"
    echo "$audit_result" | grep -E "[moderate|high|critical]"
fi

# Docker 이미지 보안 스캔 ["선택사항"]
echo "=== Docker 이미지 보안 스캔 ==="
if command -v docker-scan > /dev/null; then
    echo "Docker 이미지 스캔 실행 중..."
    docker scan github-actions-demo:latest --severity high
else
    echo "Docker Scan 도구 없음 - 건너뜀"
fi
```

#### 6. 전체 상태 요약
```bash
# 전체 상태 요약 생성
echo "=== 전체 상태 요약 ==="
echo "실행 시간: $[date]"
echo "프로젝트: GitHub Actions CI/CD 실습"
echo "환경: $[echo $NODE_ENV || echo 'development']"

# 성공/실패 카운트
success_count=0
total_count=0

# 각 검증 항목별 결과 확인
check_items=["
    "GitHub 저장소 연결"
    "Docker 이미지 빌드"
    "GitHub Actions 워크플로우"
    "애플리케이션 응답"
    "보안 스캔"
"]

for item in "${check_items[@]}"; do
    total_count=$[[total_count + 1]]
    echo "검증 항목: $item"
done

echo "=== 검증 완료 ==="
echo "총 검증 항목: $total_count"
echo "성공: $success_count"
echo "실패: $[[total_count - success_count]]"

if [ $success_count -eq $total_count ]; then
    echo "🎉 모든 검증 통과! CI/CD 파이프라인이 정상적으로 설정되었습니다."
else
    echo "⚠️ 일부 검증 실패. 위의 오류 메시지를 확인하고 문제를 해결하세요."
fi
```

### 🚨 문제 해결 가이드

#### 자주 발생하는 문제들

**1. GitHub Actions 워크플로우 실패**
```bash
# 워크플로우 실행 로그 확인
gh run view --log

# 일반적인 해결 방법
# - package.json 파일 존재 확인
# - package-lock.json 파일 생성 [npm install]
# - GitHub Secrets 설정 확인
# - Docker BuildKit 오류 시: export DOCKER_BUILDKIT=0
```

**2. Docker 이미지 빌드 실패**
```bash
# BuildKit 오류 해결
export DOCKER_BUILDKIT=0
docker build -t github-actions-demo:latest .

# package-lock.json 누락 오류 해결
npm install
ls -la package*.json

# Docker buildx 설치
docker buildx install
docker buildx create --use
```

**3. 애플리케이션 응답 실패**
```bash
# 포트 충돌 확인
netstat -tulpn | grep :3000

# 컨테이너 상태 확인
docker ps

# 컨테이너 로그 확인
docker logs [container_name]

# 컨테이너 재시작
docker-compose down
docker-compose up -d --build
```

**4. 보안 취약점 해결**
```bash
# npm audit 취약점 자동 수정
npm audit fix

# 강제 수정 ["주의: breaking changes 가능"]
npm audit fix --force

# 취약점 상세 확인
npm audit --audit-level moderate
```

## 🧪 실습 완료 체크리스트 ["성취감을 느껴보세요!"]

### 🎯 Day 1: 기본 CI/CD ["자동화의 첫 걸음!"]
- [ ] ✅ GitHub 저장소 생성 - "우리 프로젝트의 집을 만들어보자!"
- [ ] ✅ Docker 이미지 수동 빌드 및 푸시 - "먼저 직접 해보고 자동화하기!"
- [ ] ✅ GitHub Secrets 설정 - "자동화를 위한 비밀 열쇠들 준비!"
- [ ] ✅ GitHub Actions 워크플로우 생성 - "이제 코드를 올리면 자동으로 테스트돼요!"
- [ ] ✅ Docker 이미지 자동 빌드 - "어디서든 똑같이 실행되는 마법의 상자 완성!"
- [ ] ✅ VM 자동 배포 - "클라우드에 자동으로 배포되는 신기한 경험!"
- [ ] ✅ 기본 테스트 및 린팅 - "코드 품질을 자동으로 체크하는 똑똑한 시스템!"

### 🚀 Day 2: 고급 CI/CD ["전문가 수준으로!"]
- [ ] ✅ 매트릭스 빌드 구현 - "여러 환경에서 동시에 테스트하는 고급 기술!"
- [ ] ✅ 환경별 배포 설정 - "개발/스테이징/프로덕션을 구분해서 배포하는 프로의 기술!"
- [ ] ✅ Kubernetes 자동 배포 - "컨테이너 오케스트레이션의 세계로!"
- [ ] ✅ 조건부 실행 설정 - "상황에 따라 똑똑하게 판단하는 자동화!"

### 📊 Day 3: 모니터링 & 최적화 ["시스템을 지키는 수호자!"]
- [ ] ✅ 애플리케이션 모니터링 - "24시간 시스템을 지켜보는 불침번!"
- [ ] ✅ 보안 스캔 설정 - "악성 코드와 취약점을 찾아내는 보안 전문가!"
- [ ] ✅ 비용 최적화 분석 - "클라우드 비용을 절약하는 경제 전문가!"
- [ ] ✅ 성능 모니터링 - "사용자 경험을 최적화하는 성능 엔지니어!"

### 🎉 완주 시 달성하는 것들
- **DevOps 엔지니어의 사고방식**: 자동화와 모니터링의 중요성 이해
- **실무 경험**: 실제 프로덕션 환경에서 사용되는 기술들 경험
- **문제 해결 능력**: CI/CD 파이프라인에서 발생하는 문제들을 스스로 해결
- **팀 협업**: 다른 개발자들과 함께 CI/CD를 운영하는 방법 학습

---

## 📚 참고 자료 ["더 깊이 학습하고 싶다면!"]

### 📖 공식 문서 ["가장 정확하고 최신 정보"]
- ["GitHub Actions 공식 문서"][https://docs.github.com/ko/actions] - "GitHub Actions의 모든 것을 알고 싶다면!"
- ["Docker 공식 문서"][https://docs.docker.com/] - "컨테이너의 세계로 더 깊이 들어가기"
- ["Kubernetes 공식 문서"][https://kubernetes.io/docs/] - "컨테이너 오케스트레이션의 정석"
- ["AWS 공식 문서"][https://docs.aws.amazon.com/] - "클라우드의 거대한 세계 탐험"
- ["GCP 공식 문서"][https://cloud.google.com/docs] - "Google의 클라우드 서비스 마스터하기"

### 🛠️ 실무 도구들 ["실제로 사용하는 도구들"]
- [GitHub Actions Marketplace][https://github.com/marketplace?type=actions] - "다른 사람들이 만든 유용한 액션들"
- [Docker Hub][https://hub.docker.com/] - "수많은 컨테이너 이미지의 보물창고"
- ["Kubernetes 예제"][https://kubernetes.io/examples/] - "Kubernetes로 할 수 있는 모든 것들"
- ["AWS 예제"][https://github.com/aws-samples] - "AWS의 실제 사용 사례들"
- ["GCP 예제"][https://github.com/GoogleCloudPlatform] - "Google Cloud의 모범 사례들"

### 🎓 추가 학습 경로 ["다음 단계로!"]
- **Kubernetes 심화**: Helm, Istio, Prometheus 등 고급 도구들
- **클라우드 네이티브**: Serverless, Microservices 아키텍처
- **보안**: DevSecOps, 컨테이너 보안, 클라우드 보안
- **모니터링**: ELK Stack, Grafana, Jaeger 등 관찰 가능성 도구들
- **GitOps**: ArgoCD, Flux 등 Git 기반 배포 관리

### 💡 실무 팁 ["2024년 최신"]

#### 🚀 기본 원칙
- **작은 것부터 시작**: 복잡한 파이프라인보다는 간단한 것부터 만들어보세요
- **실패를 두려워하지 마세요**: CI/CD는 반복과 개선의 과정입니다
- **커뮤니티 활용**: GitHub, Stack Overflow에서 다른 사람들의 경험을 배우세요
- **문서화**: 팀원들과 함께 사용할 수 있도록 잘 정리해두세요

#### 🔧 GitHub Actions 최적화
- **GitHub 저장소 관리**: README.md를 잘 작성하고 이슈/PR 템플릿을 활용하세요
- **Secrets 관리**: 민감한 정보는 절대 코드에 직접 넣지 말고 GitHub Secrets를 사용하세요
- **워크플로우 테스트**: 로컬에서 먼저 테스트해보고 GitHub Actions에 올리세요
- **캐시 활용**: npm, Docker 빌드 캐시를 적극 활용하여 빌드 시간을 단축하세요
- **병렬 실행**: 독립적인 작업들은 병렬로 실행하여 전체 시간을 단축하세요

#### 🐳 Docker 최적화
- **Docker 이미지 최적화**: 멀티스테이지 빌드와 .dockerignore를 활용하여 이미지 크기를 줄이세요
- **Docker BuildKit 문제**: BuildKit 오류 시 `export DOCKER_BUILDKIT=0`으로 비활성화하거나 `docker buildx install`로 해결하세요
- **이미지 보안**: 정기적으로 베이스 이미지를 업데이트하고 보안 스캔을 실행하세요
- **이미지 태깅**: 의미있는 태그를 사용하여 버전 관리를 체계적으로 하세요

#### 📦 Node.js 프로젝트 관리
- **package-lock.json 관리**: `npm install`로 package-lock.json을 생성하고 Git에 커밋하여 일관된 의존성 관리하세요
- **package.json 구문**: JSON에서는 JavaScript 주석[//]을 사용할 수 없으므로, 주석이 필요하면 README.md에 작성하세요
- **의존성 보안**: `npm audit`을 정기적으로 실행하고 취약점을 즉시 수정하세요
- **prom-client 모듈**: 모니터링을 위한 필수 모듈이므로 package.json에 명시적으로 추가하세요

#### 🔐 보안 및 인증
- **GitHub 인증**: Personal Access Token을 사용하고, 가능하면 SSH 키를 설정하세요
- **토큰 보안**: Personal Access Token은 안전한 곳에 보관하고 정기적으로 갱신하세요
- **GitHub 메뉴 변경**: GitHub는 정기적으로 UI를 업데이트하므로, 메뉴가 바뀌어도 당황하지 마세요
- **토큰 종류**: Classic tokens가 더 간단하고, Fine-grained tokens는 더 세밀한 권한 제어가 가능합니다
- **권한 최소화**: 필요한 권한만 부여하고, 정기적으로 토큰을 갱신하세요
- **Docker Hub 토큰**: Personal Access Token을 사용하여 보안을 강화하고 권한을 세밀하게 제어하세요

#### 🚨 문제 해결
- **BuildKit 오류**: `export DOCKER_BUILDKIT=0` 또는 `docker buildx install`로 해결
- **prom-client 누락**: `npm install prom-client`로 설치
- **테스트 실패**: `npm ci`로 의존성 재설치 후 테스트 재실행
- **Docker Compose 오류**: `docker-compose down --remove-orphans` 후 재시작
- **npm audit 취약점**: `npm audit fix`로 자동 수정 시도

#### 📊 모니터링 및 최적화
- **성능 모니터링**: 빌드 시간, 테스트 실행 시간을 정기적으로 측정하세요
- **비용 최적화**: 불필요한 리소스 사용을 줄이고 효율적인 빌드 전략을 수립하세요
- **알림 설정**: 빌드 실패나 보안 취약점 발견 시 즉시 알림을 받도록 설정하세요
- **로그 관리**: 빌드 로그를 체계적으로 관리하고 문제 발생 시 빠르게 원인을 파악하세요

#### 🔄 지속적 개선
- **피드백 수집**: 팀원들의 피드백을 수집하고 파이프라인을 지속적으로 개선하세요
- **최신 기술 적용**: 새로운 도구나 기술을 적극적으로 도입하여 효율성을 높이세요
- **문서 업데이트**: 변경사항을 즉시 문서에 반영하여 팀원들이 최신 정보를 활용할 수 있도록 하세요
- **교육 및 공유**: 팀원들과 지식을 공유하고 CI/CD 모범 사례를 함께 학습하세요

---

## 📋 실습 완료 체크리스트

### ✅ 실습 1: 기본 CI/CD 파이프라인 구축
- [ ] GitHub 저장소 생성 및 연결
- [ ] 기본 프로젝트 파일 생성 [package.json, app.js]
- [ ] Dockerfile 3종류 생성 ["기본, 개발, 테스트"]
- [ ] Docker 이미지 빌드 및 테스트 성공
- [ ] Docker Hub에 이미지 푸시 성공
- [ ] GitHub Secrets 설정 완료
- [ ] CI 워크플로우 파일 생성 및 실행 성공

### ✅ 실습 2: 고급 CI/CD 파이프라인 구축
- [ ] 멀티스테이지 Dockerfile 생성
- [ ] Docker 이미지 자동 빌드 워크플로우 생성
- [ ] 환경별 배포 파이프라인 구축
- [ ] 보안 스캔 및 품질 검사 자동화
- [ ] 롤백 및 복구 시스템 구축

### ✅ 실습 3: 모니터링 및 최적화
- [ ] 애플리케이션 모니터링 시스템 구축
- [ ] 로그 수집 및 분석 시스템 설정
- [ ] 알림 및 알림 시스템 구축
- [ ] 성능 최적화 및 비용 절감
- [ ] 장애 대응 프로세스 구축

## 🧪 실습 검증 방법

### 🔍 각 실습별 검증 명령어

**실습 1 검증**
```bash
# GitHub 저장소 확인
gh repo view

# Docker 이미지 확인
docker images | grep github-actions-demo

# GitHub Actions 실행 확인
gh run list

# 워크플로우 상태 확인
gh run view --log
```

**실습 2 검증**
```bash
# 멀티스테이지 빌드 확인
docker build -f Dockerfile -t github-actions-demo:latest .

# 이미지 크기 비교
docker images github-actions-demo --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}"

# 보안 스캔 결과 확인
docker scan github-actions-demo:latest
```

**실습 3 검증**
```bash
# 모니터링 메트릭 확인
curl http://localhost:3000/metrics

# 로그 수집 확인
docker logs [container_name]

# 알림 테스트
# ["설정한 알림 채널에서 테스트 메시지 확인"]
```

## 🎯 실습 성공 기준

### 📊 정량적 지표
- **빌드 성공률**: 95% 이상
- **테스트 통과율**: 100%
- **배포 시간**: 5분 이내
- **장애 복구 시간**: 10분 이내

### 📈 정성적 지표
- **자동화 수준**: 수동 개입 없이 전체 파이프라인 실행
- **모니터링 효과**: 문제 발생 시 즉시 감지 및 알림
- **운영 효율성**: 반복 작업의 90% 이상 자동화

---

<div align="center">

["← 이전: 인프라 가이드"][infra-guide.md] | 
["📚 전체 커리큘럼"][../curriculum.md] | 
["🏠 학습 경로로 돌아가기"][../index.md] | 
["다음: 실습 가이드 →"][execuise-guide.md]

</div>
