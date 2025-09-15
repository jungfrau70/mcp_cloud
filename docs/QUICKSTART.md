# AI 활용 교육 교구 시스템 빠른 시작 가이드 (Quickstart)

이 문서는 로컬 개발 환경에서 AI 활용 교육 교구 시스템을 실행하는 방법을 안내합니다.

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

- **AI API 키 발급**: OpenAI API 또는 Anthropic Claude API 키를 발급받으세요.
- **환경 변수 파일 생성**: `backend/env/.env` 파일을 생성하고 아래 내용을 추가하세요.

  ```
  # backend/env/.env
  # AI API 설정
  OPENAI_API_KEY="여기에_발급받은_OpenAI_API_키를_입력하세요"
  ANTHROPIC_API_KEY="여기에_발급받은_Anthropic_API_키를_입력하세요"

  # 데이터베이스 설정
  DATABASE_URL="postgresql://user:password@localhost:5432/education_db"
  REDIS_URL="redis://localhost:6379"

  # 교육 자료 경로
  KNOWLEDGE_BASE_PATH="./mcp_knowledge_base"
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
- AI 활용 교육 교구 시스템의 로그인 화면이 나타나면 성공입니다!

## 🐛 문제 해결 (Troubleshooting)

- **Docker 실행 오류**: Docker 데몬이 실행 중인지 확인하세요.
- **포트 충돌**: `docker-compose.yml` 파일에 정의된 포트(예: 8000, 3000)가 다른 프로세스에서 사용 중인지 확인하세요.
- **API 키 오류**: 백엔드 로그에 API 키 관련 인증 오류가 표시되면 `.env` 파일의 키가 올바른지 다시 확인하세요.
- **데이터베이스 연결 오류**: PostgreSQL과 Redis가 정상적으로 실행되고 있는지 확인하세요.
- **교육 자료 경로 오류**: `mcp_knowledge_base` 디렉토리가 존재하고 올바른 경로에 있는지 확인하세요.