# MentorAi 빠른 시작 가이드 (Quickstart)

이 문서는 로컬 개발 환경에서 MentorAi 플랫폼을 실행하는 방법을 안내합니다.

## ✅ 사전 요구사항 (Prerequisites)

- [Docker](https://www.docker.com/get-started) 및 Docker Compose
- [Node.js](https://nodejs.org/) (v18 이상)
- [Python](https://www.python.org/downloads/) (v3.9 이상)
- [Yarn](https://classic.yarnpkg.com/en/docs/install) (NPM 대용)

## 🚀 실행 방법 (Step-by-Step)

### 1. 프로젝트 클론

```bash
git clone https://github.com/your-repo/mcp_cloud.git
cd mcp_cloud
```

### 2. 백엔드 설정

- **Google Gemini API 키 발급**: [Google AI Studio](https://aistudio.google.com/app/apikey)에서 API 키를 발급받으세요.
- **환경 변수 파일 생성**: `backend/env/.env` 파일을 생성하고 아래 내용을 추가하세요.

  ```
  # backend/env/.env
  # Gemini / API
  GEMINI_API_KEY="여기에_발급받은_API_키를_입력하세요"

  # (선택) AWS - 읽기 전용 테스트용 자격증명
  AWS_ACCESS_KEY_ID=
  AWS_SECRET_ACCESS_KEY=
  AWS_DEFAULT_REGION=ap-northeast-2

  # (선택) GCP - 서비스 계정 키는 docker-compose 볼륨으로 마운트됨
  # GOOGLE_APPLICATION_CREDENTIALS=/app/gcp-sa-key.json (compose에 설정됨)

  # (선택) Azure - 서비스 프린시펄 자격증명
  AZURE_TENANT_ID=
  AZURE_CLIENT_ID=
  AZURE_CLIENT_SECRET=
  AZURE_SUBSCRIPTION_ID=
  ```

- **Python 의존성 설치**:
  ```bash
  cd backend
  pip install -r requirements.txt
  cd ..
  ```

### 3. 프론트엔드 설정

- **Node.js 의존성 설치**:
  ```bash
  cd frontend
  yarn install
  cd ..
  ```

### 4. 플랫폼 실행 (Docker Compose 사용)

프로젝트 루트 디렉토리에서 아래 명령어를 실행하여 백엔드와 프론트엔드 서비스를 동시에 시작합니다.

```bash
docker compose up --build
```

- 빌드가 완료되고 서비스가 시작될 때까지 잠시 기다려주세요.

### 5. 플랫폼 접속

- 웹 브라우저를 열고 `http://localhost:3000` 주소로 접속합니다.
- MentorAi 학습 플랫폼의 로그인 화면이 나타나면 성공입니다!

## 🐛 문제 해결 (Troubleshooting)

- **Docker 실행 오류**: Docker 데몬이 실행 중인지 확인하세요.
- **포트 충돌**: `docker-compose.yml` 파일에 정의된 포트(예: 8000, 3000)가 다른 프로세스에서 사용 중인지 확인하세요.
- **API 키 오류**: 백엔드 로그에 API 키 관련 인증 오류가 표시되면 `.env` 파일의 키가 올바른지 다시 확인하세요.
- **클라우드 인증**:
  - AWS: `docker compose exec mcp_backend aws sts get-caller-identity`
  - GCP: `docker compose exec mcp_backend gcloud auth list`
  - Azure: `docker compose exec mcp_backend az account show`