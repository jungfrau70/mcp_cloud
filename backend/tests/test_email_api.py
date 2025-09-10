import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
import models


@pytest.fixture(scope="function")
def client(monkeypatch, tmp_path):
    monkeypatch.setenv("DATABASE_URL", f"sqlite:///{tmp_path / 'test_email.db'}")
    monkeypatch.setenv("MCP_API_KEY", "my_mcp_eagle_tiger")
    monkeypatch.setenv("DISABLE_AUTH", "false")

    from fastapi import FastAPI
    from fastapi.middleware.cors import CORSMiddleware
    from main import get_db
    from app.api.routes.email import router as email_router

    app = FastAPI()
    app.add_middleware(
        CORSMiddleware,
        allow_origins=["*"],
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )
    app.include_router(email_router)

    engine = create_engine(
        f"sqlite:///{tmp_path / 'test_email.db'}", connect_args={"check_same_thread": False}
    )
    TestingSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
    models.Base.metadata.create_all(bind=engine)

    def override_get_db():
        db = TestingSessionLocal()
        try:
            yield db
        finally:
            db.close()

    app.dependency_overrides[get_db] = override_get_db

    yield TestClient(app)


def test_email_send_dev_logs(client):
    # Without SMTP/SendGrid envs, endpoint should still return ok (logs only)
    r = client.post('/api/v1/email/send', json={
        'to': 'dev@example.com',
        'subject': 'Test',
        'body': 'Hello'
    }, headers={
        'X-API-Key': 'my_mcp_eagle_tiger',
        'X-Forwarded-Groups': 'admins'
    })
    assert r.status_code == 200
    assert r.json() == { 'ok': True }


