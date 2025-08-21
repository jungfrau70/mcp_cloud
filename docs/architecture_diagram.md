```mermaid
graph TD
    subgraph "User Interface"
        A[학생/튜터<br>(Web Browser)]
    end

    subgraph "Frontend (Nuxt 3)"
        B[MentorAi Web App]
        B_CLI[통합 터미널<br>(xterm.js)]
    end

    subgraph "Backend (FastAPI)"
        C[API Server]
        D[WebSocket Gateway]
    end

    subgraph "AI Mentor Layer"
        E[LLM<br>(Google Gemini)]
        F[RAG Service]
    end

    subgraph "Data Stores"
        G[PostgreSQL<br>(학습 콘텐츠, 사용자 데이터)]
        H[Vector DB (FAISS)<br>(RAG 인덱스)]
    end

    subgraph "Hands-on Lab"
        I[격리된 실행 환경<br>(Docker Container)]
    end

    A --> B
    
    B -- HTTP API<br>(학습자료 요청, AI 질문) --> C
    B -- WebSocket<br>(터미널 입출력) --> D
    
    C -- 로직 처리 --> G
    C -- AI 멘토링 요청 --> F

    F -- 컨텍스트 검색 --> H
    F -- 프롬프트 전달 --> E
    E -- 답변 생성 --> F
    F -- 답변 반환 --> C

    D -- 명령어 전달 --> I
    I -- 실행 결과 반환 --> D

    linkStyle 0 stroke-width:2px,fill:none,stroke:gray;
    linkStyle 1 stroke-width:2px,fill:none,stroke:blue;
    linkStyle 2 stroke-width:2px,fill:none,stroke:green;
    linkStyle 3 stroke-width:2px,fill:none,stroke:purple;
    linkStyle 4 stroke-width:2px,fill:none,stroke:purple;
    linkStyle 5 stroke-width:2px,fill:none,stroke:orange;
    linkStyle 6 stroke-width:2px,fill:none,stroke:orange;
    linkStyle 7 stroke-width:2px,fill:none,stroke:red;
    linkStyle 8 stroke-width:2px,fill:none,stroke:red;

```
