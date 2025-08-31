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

    yield TestClient(app)


def test_register_login_and_me(client):
    # Register
    r = client.post("/api/v1/auth/register", json={
        "email": "test@example.com",
        "password": "Password123!",
        "full_name": "Tester"
    })
    assert r.status_code == 200
    token = r.json()["access_token"]
    assert token

    # Login should fail before verification
    r2 = client.post("/api/v1/auth/login", json={
        "email": "test@example.com",
        "password": "Password123!"
    })
    assert r2.status_code == 403

    # users/me via JWT requires X-API-Key because users router depends on it
    # Verify email: extract token from DB
    from sqlalchemy import select
    from models import User
    from main import get_db
    # Build a quick session
    # Reuse same sqlite path
    # Query user
    # NOTE: Using the same test app's override session is tricky here; simply call verify endpoint using token
    # Fetch token via private knowledge - simulate by re-registering isn't possible; instead, rely on development log or query directly in a new engine
    # For simplicity in this test, hit verify endpoint with a known token by reading DB through a new engine
    # Create engine mirror
    # However we don't have variable to engine path here; skip direct DB access: call login should still fail; we will create a second user flow below

        "/api/v1/users/me",
        headers={
            "Authorization": f"Bearer {token2}",
            "X-API-Key": "my_mcp_eagle_tiger"
        }
    )
    assert r3.status_code == 200
    body = r3.json()
    assert body["email"] == "test@example.com"
    assert body["role"] == "student"


