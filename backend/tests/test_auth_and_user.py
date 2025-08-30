# backend/tests/test_auth_and_user.py
import pytest
import os
from fastapi.testclient import TestClient
from sqlalchemy import create_engine, select
from sqlalchemy.orm import sessionmaker
from datetime import datetime, timedelta

# conftest.py sets up the path, so we can do top-level imports here
import models

# NOTE: DO NOT import app from backend.main at the top level.
# It needs to be imported *after* environment variables are patched.

@pytest.fixture(scope="function")
def client(monkeypatch, tmp_path):
    """
    A function-scoped fixture that provides a fully isolated test client
    for each test function, using a temporary SQLite database.
    """
    # 1. Set environment variables for the test
    monkeypatch.setenv("DATABASE_URL", f"sqlite:///{tmp_path / 'test_auth.db'}")
    monkeypatch.setenv("MCP_API_KEY", "test_api_key")
    monkeypatch.setenv("DISABLE_AUTH", "false") # Enable API key auth for these tests

    # 2. Import necessary modules for app creation
    from fastapi import FastAPI
    from fastapi.middleware.cors import CORSMiddleware
    from models import Base, User # User model is needed for tests
    from main import get_db # Only get_db is needed from main for overriding

    # Import all routers explicitly
    from app.api.routes.kb import router as kb_router
    from app.api.routes.knowledge import router as knowledge_router
    from app.api.routes.users import router as users_router
    # Add other routers as needed by the tests, or only those relevant to auth/user
    # For this test file, kb_router and users_router are essential.

    # 3. Create a fresh FastAPI app instance
    app = FastAPI(title="Test MCP Cloud API", version="1.0.0")
    app.add_middleware(
        CORSMiddleware,
        allow_origins=["*"], # Allow all for testing
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )

    # 4. Include routers with their dependencies
    app.include_router(kb_router)
    app.include_router(users_router)
    app.include_router(knowledge_router) # Include knowledge_router as well

    # 5. Create a fresh, in-memory SQLite database for this test
    engine = create_engine(
        f"sqlite:///{tmp_path / 'test_auth.db'}", connect_args={"check_same_thread": False}
    )
    TestingSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
    
    models.Base.metadata.create_all(bind=engine) # Create tables

    # 6. Override the `get_db` dependency to use the in-memory database
    def override_get_db():
        db = TestingSessionLocal()
        try:
            yield db
        finally:
            db.close()

    app.dependency_overrides[get_db] = override_get_db

    # 7. Yield the test client and the session maker for verification
    yield TestClient(app), TestingSessionLocal

    # Teardown: clear dependency overrides and drop tables
    app.dependency_overrides.clear()
    Base.metadata.drop_all(bind=engine)


def test_rbac_guard_admin_allowed(client):
    """Tests that an admin can access a protected knowledge base route."""
    test_client, _ = client
    # This endpoint is protected by the kb_admin_guard middleware.
    # We expect a 404 because the document doesn't exist, but not a 403.
    response = test_client.get(
        "/api/v1/knowledge-base/versions?path=some/doc.md",
        headers={"X-Forwarded-Groups": "admins"}
    )
    assert response.status_code != 403

def test_rbac_guard_student_forbidden(client):
    """Tests that a non-admin is blocked from protected knowledge base routes."""
    test_client, _ = client
    response = test_client.get(
        "/api/v1/knowledge-base/versions?path=some/doc.md",
        headers={"X-Forwarded-Groups": "student", "X-API-Key": "test_api_key"}
    )
    assert response.status_code == 403
    assert response.json() == {"detail": "Not authorized: Requires admin privileges"}

def test_jit_provisioning_new_user(client):
    """Tests that a new user is created in the DB upon first visit to /users/me."""
    test_client, SessionLocal = client
    
    # 1. Call the /users/me endpoint
    response = test_client.get(
        "/api/v1/users/me",
        headers={
            "X-Forwarded-Email": "new.user@example.com",
            "X-Forwarded-Groups": "student, anothergroup"
        }
    )
    assert response.status_code == 200
    data = response.json()
    assert data["email"] == "new.user@example.com"
    assert data["role"] == "student"

    # 2. Verify the user was created in the database
    db = SessionLocal()
    try:
        user_in_db = db.scalar(select(models.User).where(models.User.email == "new.user@example.com"))
        assert user_in_db is not None
        assert user_in_db.role == "student"
        assert (datetime.utcnow() - user_in_db.created_at) < timedelta(seconds=5)
    finally:
        db.close()

def test_jit_provisioning_update_existing_user(client):
    """Tests that an existing user's role and last_login_at are updated."""
    test_client, SessionLocal = client
    
    # 1. Manually create an existing user
    db = SessionLocal()
    try:
        initial_time = datetime.utcnow() - timedelta(minutes=10)
        existing_user = models.User(
            email="existing.user@example.com",
            role="student",
            last_login_at=initial_time
        )
        db.add(existing_user)
        db.commit()
        db.refresh(existing_user)
        initial_id = existing_user.id
    finally:
        db.close()

    # 2. Call /users/me with a different role
    response = test_client.get(
        "/api/v1/users/me",
        headers={
            "X-Forwarded-Email": "existing.user@example.com",
            "X-Forwarded-Groups": "admins,tutors",
            "X-API-Key": "test_api_key"
        }
    )
    assert response.status_code == 200
    assert response.json()["role"] == "admin" # Admins group takes precedence

    # 3. Verify the user was updated in the database
    db = SessionLocal()
    try:
        user_in_db = db.scalar(select(models.User).where(models.User.email == "existing.user@example.com"))
        assert user_in_db is not None
        assert user_in_db.id == initial_id
        assert user_in_db.role == "admin"
        assert user_in_db.last_login_at > initial_time
    finally:
        db.close()
