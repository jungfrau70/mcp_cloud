```mermaid
graph TD
    subgraph "User Interface"
        A[교육 커리큘럼 작성자/교육자/수강자<br>(Web Browser)]
    end

    subgraph "Frontend (Nuxt 3)"
        B[AI 활용 교육 교구 시스템<br>Web App]
        B_EDITOR[코드 에디터<br>(실습 환경)]
    end

    subgraph "Backend (FastAPI)"
        C[API Server]
        D[교육 자료 관리]
    end

    subgraph "AI 에이전트 레이어"
        E[LLM<br>(OpenAI/Anthropic)]
        F[교육 자료 생성 AI]
        G[실습 가이드 생성 AI]
        H[평가 문항 생성 AI]
    end

    subgraph "Data Stores"
        I[PostgreSQL<br>(교육 자료, 사용자 데이터)]
        J[Redis<br>(캐시)]
        K[로컬 파일 시스템<br>(마크다운 교육 자료)]
    end

    subgraph "실습 환경"
        L[격리된 실행 환경<br>(Docker Container)]
    end

    A --> B
    
    B -- HTTP API<br>(교육자료 요청, AI 질문) --> C
    B -- 실습 요청 --> B_EDITOR
    
    C -- 로직 처리 --> I
    C -- 교육 자료 관리 --> D
    C -- AI 요청 --> F
    C -- AI 요청 --> G
    C -- AI 요청 --> H

    D -- 교육 자료 저장/조회 --> K
    D -- 캐시 관리 --> J

    F -- 교육 자료 생성 --> E
    G -- 실습 가이드 생성 --> E
    H -- 평가 문항 생성 --> E
    E -- AI 응답 --> C

    B_EDITOR -- 코드 실행 요청 --> L
    L -- 실행 결과 반환 --> B_EDITOR

    linkStyle 0 stroke-width:2px,fill:none,stroke:gray;
    linkStyle 1 stroke-width:2px,fill:none,stroke:blue;
    linkStyle 2 stroke-width:2px,fill:none,stroke:green;
    linkStyle 3 stroke-width:2px,fill:none,stroke:purple;
    linkStyle 4 stroke-width:2px,fill:none,stroke:purple;
    linkStyle 5 stroke-width:2px,fill:none,stroke:orange;
    linkStyle 6 stroke-width:2px,fill:none,stroke:orange;
    linkStyle 7 stroke-width:2px,fill:none,stroke:teal;
    linkStyle 8 stroke-width:2px,fill:none,stroke:teal;
    linkStyle 9 stroke-width:2px,fill:none,stroke:teal;

```
