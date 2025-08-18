```mermaid
graph TD
    subgraph "MCP Control Plane (핵심 서버)"
        A[API 서버<br>(FastAPI/Nest.js)] --> B(작업 엔진<br>(Celery/RQ/K8s Jobs))
        B --> C(상태 저장<br>(Postgres, S3/GCS, Terraform Backend))
        A --> D(인증/권한<br>(OIDC/SSO, RBAC))
        A --> E(Secret Management<br>(Vault/Cloud KMS))
        A --> F(Audit & Alerting<br>(ELK/Cloud Logging/Grafana))
    end

    subgraph "AI Agent Layer"
        G[LLM(s)<br>(Llama/Anthropic/OpenAI/Gemini)] --> H(Retrieval/Context<br>(RAG, Vector DB))
        G --> I(Tooling Connectors<br>(IaC Generator, Cost Estimator, Security Scanner, Test Runner))
    end

    subgraph "Cloud Connectors (플러그형)"
        J[AWS Connector<br>(IAM/STS, S3, CodePipeline, EKS)]
        K[GCP Connector<br>(Service Account, GCS, Cloud Build, GKE)]
    end

    subgraph "CI/CD & Test"
        L[GitOps<br>(GitHub/GitLab Integration)] --> M(Test Infra<br>(Terratest/kitchen-terraform/pytest))
        L --> N(Deployment Strategies<br>(Canary/Blue-Green))
    end

    subgraph "Observability & Ops"
        O[Metrics<br>(Prometheus/Grafana/Cloud Monitoring)]
        P[Logs<br>(ELK/Cloud Logging)]
        Q[Tracing<br>(Jaeger/Tempo)]
        R[Cost<br>(Cloud Billing APIs)]
    end

    G -- "자연어 명령" --> A
    A -- "작업 요청" --> B
    B -- "인프라 프로비저닝" --> J
    B -- "인프라 프로비저닝" --> K
    I -- "IaC 제안/수정" --> A
    A -- "GitOps 연동" --> L
    L -- "테스트 실행" --> M
    L -- "배포" --> N
    J -- "모니터링 데이터" --> O
    K -- "모니터링 데이터" --> O
    J -- "로그 데이터" --> P
    K -- "로그 데이터" --> P
    J -- "추적 데이터" --> Q
    K -- "추적 데이터" --> Q
    J -- "비용 데이터" --> R
    K -- "비용 데이터" --> R
```