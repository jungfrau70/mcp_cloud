# MentorAi 플랫폼 아키텍처

## 1. 개요

MentorAi는 학생, 튜터, AI 멘토 간의 원활한 상호작용을 지원하기 위해 모듈화된 아키텍처를 채택합니다. 본 문서는 각 컴포넌트의 역할과 데이터 흐름을 설명합니다.

## 2. 핵심 컴포넌트 (Core Components)

![MentorAi Architecture Diagram](architecture_diagram.svg)  
*(위 다이어그램은 `architecture_diagram.md`의 Mermaid 코드로 생성됩니다.)*

### 2.1. Frontend (Nuxt 3 / Vue.js)

- **사용자 인터페이스 (UI)**: 학생과 튜터가 플랫폼과 상호작용하는 웹 애플리케이션입니다.
- **주요 역할**:
    - **학생 대시보드**: 학습 콘텐츠 조회, AI 멘토와 대화, 통합 터미널을 통한 실습 진행.
    - **튜터 대시보드**: 학습 콘텐츠(커리큘럼) 관리, 학생 활동 모니터링.
    - **상태 관리**: 사용자의 로그인 상태, 현재 학습 중인 내용 등을 관리합니다.
    - **API 클라이언트**: 백엔드 API와 통신하여 데이터를 주고받습니다.

### 2.2. Backend (FastAPI / Python)

- **중앙 API 서버**: 플랫폼의 모든 비즈니스 로직을 처리하는 핵심 서버입니다.
- **주요 역할**:
    - **API 제공**: 프론트엔드의 요청에 따라 학습 콘텐츠, 사용자 정보 등을 제공합니다.
    - **인증/권한 관리**: 튜터와 학생의 역할을 구분하고 접근 권한을 제어합니다.
    - **AI 멘토 오케스트레이션**: 학생의 질문을 받아 AI 멘토 레이어에 전달하고, 그 결과를 다시 프론트엔드에 반환합니다.
    - **데이터베이스 관리**: PostgreSQL 및 Vector DB와의 모든 상호작용을 담당합니다.
    - **클라우드 커넥터**: 안전한 읽기 전용 CLI 화이트리스트를 통해 멀티클라우드(AWS, GCP, Azure) 리소스 조회를 지원합니다.

### 2.3. AI Mentor Layer

- **지능형 멘토링 엔진**: 플랫폼의 '뇌' 역할을 수행합니다.
- **주요 역할**:
    - **LLM (Google Gemini)**: 자연어 이해 및 생성을 담당합니다. 학생의 질문에 답변하고, 튜터를 위한 학습 자료 초안을 작성합니다.
    - **RAG (Retrieval-Augmented Generation)**: AI 멘토가 답변을 생성할 때, 플랫폼 내의 최신 학습 자료를 참고하여 더 정확하고 맥락에 맞는 답변을 제공하도록 돕습니다.

### 2.4. Data Stores

- **데이터 영속성 계층**: 플랫폼의 모든 데이터를 저장하고 관리합니다.
- **주요 역할**:
    - **PostgreSQL (RDBMS)**: 구조화된 데이터를 저장합니다. (예: 사용자 정보, 학습 모듈, 커리큘럼, 학생 진도 등)
    - **Vector DB (FAISS)**: RAG 시스템을 위한 임베딩 벡터를 저장합니다. 튜터가 학습 자료를 저장/수정할 때마다 업데이트되어 AI 멘토가 최신 정보를 참고할 수 있게 합니다.

### 2.5. Hands-on Lab (실습 환경)

- **격리된 실습 공간**: 학생들이 학습한 내용을 안전하게 실습할 수 있는 환경입니다.
- **주요 역할**:
    - **통합 터미널**: 프론트엔드에 내장된 웹 터미널(xterm.js)을 제공합니다.
    - **보안 컨테이너**: WebSocket을 통해 전달된 학생의 셸 명령어는 백엔드에서 격리된 Docker 컨테이너 환경에서 실행되어 시스템에 영향을 주지 않습니다.

### 2.6. Cloud Connectors (Multi-Cloud)

- **지원 플랫폼**: AWS, GCP, Azure
- **구성요소**:
    - AWS: `aws` CLI (읽기 전용 화이트리스트), AWS SDK
    - GCP: `gcloud` CLI, 서비스 계정 인증
    - Azure: `az` CLI, 서비스 프린시펄 인증 (Tenant/Client/Secret)
- **보안**: 백엔드는 명시된 읽기 전용 명령만 실행하며, 쓰기/삭제는 UI에서 별도 승인 워크플로 및 Terraform 적용 경로로만 수행합니다.

## 3. 데이터 및 상호작용 흐름 (Data & Interaction Flow)

1.  **학습 콘텐츠 조회**: 학생이 프론트엔드에서 특정 학습 모듈을 클릭합니다.
    - `Frontend` -> `Backend`: 학습 모듈 데이터 요청 (GET /api/modules/{id})
    - `Backend` -> `PostgreSQL`: 해당 ID의 콘텐츠 조회
    - `PostgreSQL` -> `Backend` -> `Frontend`: 콘텐츠 데이터 반환 및 화면에 렌더링.

2.  **AI 멘토에게 질문**: 학생이 학습 중 궁금한 점을 AI 멘토 채팅창에 입력합니다.
    - `Frontend` -> `Backend`: 질문 내용 전송 (POST /api/mentor/ask)
    - `Backend` -> `Vector DB`: 질문과 관련된 학습 자료 검색 (RAG)
    - `Backend` -> `AI Mentor Layer (LLM)`: 검색된 자료와 질문을 함께 전달하여 답변 생성 요청
    - `AI Mentor Layer` -> `Backend` -> `Frontend`: 생성된 답변을 학생에게 실시간으로 표시.

3.  **통합 터미널 실습**: 학생이 터미널에 `aws s3 ls`, `gcloud compute zones list`, `az group list`와 같은 명령어를 입력합니다.
    - `Frontend (xterm.js)` -> `Backend`: WebSocket을 통해 명령어 전송
    - `Backend` -> `Hands-on Lab (Docker)`: 격리된 컨테이너에서 명령어 실행
    - `Hands-on Lab` -> `Backend` -> `Frontend`: 실행 결과를 WebSocket을 통해 터미널에 실시간으로 출력.