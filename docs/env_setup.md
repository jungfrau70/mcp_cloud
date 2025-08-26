### Environment setup for docker-compose

1) Create the directory if it does not exist
- Windows PowerShell:
  - `New-Item -ItemType Directory -Force backend/env`
- Bash:
  - `mkdir -p backend/env`

2) Copy the example and edit values
- `copy docs\env.example backend\env\.env` (Windows)
- `cp docs/env.example backend/env/.env` (macOS/Linux)

3) Required keys (minimum)
- PostgreSQL: `POSTGRES_DB`, `POSTGRES_USER`, `POSTGRES_PASSWORD`, `DATABASE_URL`
- Neo4j: `NEO4J_USER`, `NEO4J_PASSWORD`, `NEO4J_AUTH`
- Backend (optional): `REDIS_URL`, embedding related keys
- Cloud/LLM keys are optional locally; in prod use secret stores

4) Run
- `docker compose up -d`
- Check health:
  - `docker compose ps`
  - Neo4j: `http://localhost:7474`

Note
- `backend/env/.env` is git-ignored already. Do not commit real secrets.
