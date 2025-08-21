# MentorAi MVP 스캐폴드

이 문서는 MentorAi 플랫폼의 **최소 기능 제품(MVP)**을 구성하는 핵심 요소와 그 구현 방향을 제시합니다. MVP는 학생들이 학습 자료를 조회하고 AI 멘토에게 질문할 수 있으며, 튜터가 학습 자료를 업로드할 수 있는 기능을 중심으로 합니다.

## 1. MVP 목표

-   **학생**: 로그인 후 학습 자료를 조회하고, AI 멘토에게 학습 내용에 대한 질문을 할 수 있다.
-   **튜터**: 로그인 후 학습 자료(마크다운 파일)를 업로드하고, 업로드된 자료를 조회할 수 있다.

## 2. 핵심 컴포넌트 및 기술 스택

### 2.1. Backend (FastAPI)

-   **사용자 관리**: 학생/튜터 역할 구분 및 로그인/로그아웃 API.
-   **학습 자료 관리**: 마크다운 형식의 학습 자료를 저장하고 조회하는 API (CRUD).
-   **AI 멘토 Q&A**: 학생의 질문을 받아 RAG(Retrieval-Augmented Generation)를 통해 답변을 생성하는 API.
-   **데이터베이스**: PostgreSQL (사용자 정보, 학습 자료 메타데이터).

### 2.2. Frontend (Nuxt 3)

-   **인증 UI**: 로그인/회원가입 페이지.
-   **학생 대시보드**: 업로드된 학습 자료 목록을 보여주고, 선택 시 내용을 표시하는 뷰어.
-   **AI 멘토 채팅 UI**: 학생이 AI 멘토에게 질문을 입력하고 답변을 볼 수 있는 인터페이스.
-   **튜터 대시보드**: 학습 자료 업로드 폼 및 업로드된 자료 목록.

### 2.3. Infrastructure (Docker Compose)

-   `docker-compose.yml` 파일을 통해 `backend`, `frontend`, `postgres` 서비스를 로컬 환경에서 쉽게 실행할 수 있도록 구성.

## 3. MVP 구현 스캐폴드 (예시)

```
mcp_cloud/
├── backend/
│   ├── app/
│   │   ├── main.py (FastAPI 앱 진입점)
│   │   ├── api/ (API 라우터)
│   │   │   ├── auth.py (인증 관련 API)
│   │   │   ├── learning_materials.py (학습 자료 API)
│   │   │   └── ai_mentor.py (AI 멘토 Q&A API)
│   │   ├── models.py (SQLModel 정의)
│   │   ├── db.py (DB 연결 및 세션 관리)
│   │   └── requirements.txt
│   ├── Dockerfile
│   └── .env (API 키 등 환경 변수)
├── frontend/
│   ├── pages/
│   │   ├── index.vue (로그인/메인)
│   │   ├── student/ (학생 대시보드)
│   │   │   └── index.vue
│   │   ├── tutor/ (튜터 대시보드)
│   │   │   └── index.vue
│   │   ├── learning-material/[id].vue (학습 자료 뷰어)
│   │   └── ai-chat.vue (AI 멘토 채팅)
│   ├── components/
│   │   ├── LearningMaterialViewer.vue
│   │   ├── AIMentorChat.vue
│   │   └── ...
│   ├── nuxt.config.ts
│   ├── package.json
│   └── Dockerfile
├── docker-compose.yml
└── README.md
```

## 4. MVP 실행 흐름

1.  사용자(학생/튜터)가 웹 브라우저를 통해 MentorAi 플랫폼에 접속.
2.  로그인 후, 역할에 맞는 대시보드로 이동.
3.  **학생**: 학습 자료 목록을 탐색하고, 원하는 자료를 클릭하여 내용을 조회. 학습 중 궁금한 점은 AI 멘토 채팅창을 통해 질문.
4.  **튜터**: 학습 자료 업로드 페이지에서 마크다운 파일을 업로드. 업로드된 자료는 학생 대시보드에 즉시 반영.
