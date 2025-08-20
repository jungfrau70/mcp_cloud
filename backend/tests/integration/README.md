# Integration (Live) Tests

These tests hit a running backend service (Docker or local) on `http://localhost:8000`.

## Running

```bash
pytest -m live -q
```

## Environment Variables
- `LIVE_API_BASE` (default: http://localhost:8000)
- `MCP_API_KEY` API key matching running backend

## Markers
- `@pytest.mark.live` + `@pytest.mark.integration`

## Notes
- Ensure containers are up: `docker-compose up -d --build`
- Healthcheck may need ~30s for first vector store load.
