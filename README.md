# MCP Cloud Platform

AI 기반 멀티클라우드 관리 플랫폼

## 프로젝트 구조

```
mcp_cloud/
├── backend/                 # FastAPI 백엔드 (포트: 8000)
├── frontend/               # Nuxt.js 프론트엔드 (포트: 3000)
│   ├── Dockerfile.package  # 의존성 관리용 Dockerfile
│   ├── Dockerfile.app      # 애플리케이션 빌드용 Dockerfile
│   └── ...
├── terraform_modules/      # Terraform 모듈
├── database/               # 데이터베이스 스크립트
└── docker-compose.yml      # 프로덕션 환경
```

## Dockerfile 구조

### 멀티스테이지 빌드 구조

프론트엔드는 효율적인 멀티스테이지 빌드를 위해 다음과 같이 구성됩니다:

1. **Package Stage** (`package`): 의존성 관리
   - `package.json`과 `yarn.lock` 복사
   - 모든 의존성 설치 (개발 + 프로덕션)

2. **App Stage** (`builder`): 애플리케이션 빌드
   - 소스 코드 복사
   - Nuxt.js 애플리케이션 빌드

3. **Production Stage** (`production`): 런타임
   - 빌드된 애플리케이션만 복사
   - 최소한의 런타임 환경

### 사용 방법

```bash
# 프로덕션 빌드
docker build -t mcp-frontend:prod --target production .

# 개발 환경 (의존성만)
docker build -t mcp-frontend:dev --target package .

# 전체 빌드
docker build -t mcp-frontend:full .
```

## 빠른 시작

### 1. 환경 설정

```bash
# 환경 변수 설정
cp .env.example .env
# .env 파일을 편집하여 필요한 값들을 설정
```

### 2. Docker Compose로 실행

```bash
# 프로덕션 환경
docker-compose up -d

# 개발 환경
docker-compose -f docker-compose.dev.yml up -d
```

### 3. 개별 서비스 실행

```bash
# 백엔드만 실행
docker-compose up mcp_backend

# 프론트엔드만 실행
docker-compose up mcp_frontend
```

## 개발 환경

### 프론트엔드 개발

```bash
cd frontend

# 의존성 설치
yarn install

# 개발 서버 실행
yarn dev

# 빌드
yarn build

# 프로덕션 미리보기
yarn preview
```

### 백엔드 개발

```bash
cd backend

# 가상환경 활성화 (Windows)
venv\Scripts\activate

# 의존성 설치
pip install -r requirements.txt

# 개발 서버 실행
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

## 테스트

```bash
# 전체 테스트 실행
python run_tests.py

# 백엔드 테스트
cd backend && pytest

# 프론트엔드 테스트
cd frontend && yarn test
```

## 배포

### Docker 이미지 빌드

```bash
# 프론트엔드
cd frontend
docker build -t mcp-frontend:latest .

# 백엔드
cd backend
docker build -t mcp-backend:latest .
```

### Kubernetes 배포

```bash
# Terraform으로 인프라 프로비저닝
cd terraform_modules
terraform init
terraform plan
terraform apply
```

## 문제 해결

### 일반적인 문제들

1. **포트 충돌**: `docker-compose.yml`에서 포트 매핑 확인
2. **의존성 문제**: `docker-compose down` 후 `docker-compose build --no-cache`
3. **권한 문제**: Windows에서 Docker Desktop 권한 설정 확인

### 로그 확인

```bash
# 컨테이너 로그 확인
docker-compose logs mcp_frontend
docker-compose logs mcp_backend

# 실시간 로그 모니터링
docker-compose logs -f mcp_frontend
```

## 기여하기

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 라이선스

이 프로젝트는 MIT 라이선스 하에 배포됩니다. 자세한 내용은 `LICENSE` 파일을 참조하세요.
# mcp_cloud
