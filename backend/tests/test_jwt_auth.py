import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
import os

import models


@pytest.fixture(scope="function")
def client(monkeypatch, tmp_path):
    monkeypatch.setenv("DATABASE_URL", f"sqlite:///{tmp_path / 'test_jwt.db'}")
    monkeypatch.setenv("MCP_API_KEY", "my_mcp_eagle_tiger")
    monkeypatch.setenv("DISABLE_AUTH", "false")
    monkeypatch.setenv("JWT_SECRET", "test_secret")

    from fastapi import FastAPI
    from fastapi.middleware.cors import CORSMiddleware
    from main import get_db
    from app.api.routes.auth import router as auth_router
    from app.api.routes.users import router as users_router

    app = FastAPI()
    app.add_middleware(
        CORSMiddleware,
        allow_origins=["*"],
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )
    app.include_router(auth_router)
    app.include_router(users_router)

    engine = create_engine(
        f"sqlite:///{tmp_path / 'test_jwt.db'}", connect_args={"check_same_thread": False}
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

    yield TestClient(app), TestingSessionLocal


def test_register_login_and_me(client):
    test_client, SessionLocal = client
    # Register
    r = test_client.post("/api/v1/auth/register", json={
        "email": "test@example.com",
        "password": "Password123!",
        "full_name": "Tester"
    })
    assert r.status_code == 200
    token = r.json()["access_token"]
    assert token

    # Login should fail before verification
    r2 = test_client.post("/api/v1/auth/login", json={
        "email": "test@example.com",
        "password": "Password123!"
    })
    assert r2.status_code == 403

    # Verify email token from DB
    from models import User
    db = SessionLocal()
    try:
        u = db.query(User).filter(User.email == "test@example.com").first()
        assert u and u.email_verification_token
        verify_token = u.email_verification_token
    finally:
        db.close()

    r_verify = test_client.post('/api/v1/auth/verify-email', json={ 'token': verify_token })
    assert r_verify.status_code == 200

    # Login should now succeed
    r3 = test_client.post("/api/v1/auth/login", json={
        "email": "test@example.com",
        "password": "Password123!"
    })
    assert r3.status_code == 200
    token2 = r3.json()["access_token"]
    assert token2

    # users/me via JWT requires X-API-Key because users router depends on it
    r4 = test_client.get(
        "/api/v1/users/me",
        headers={
            "Authorization": f"Bearer {token2}",
            "X-API-Key": "my_mcp_eagle_tiger"
        }
    )
    assert r4.status_code == 200
    body = r4.json()
    assert body["email"] == "test@example.com"
    assert body["role"] == "student"


