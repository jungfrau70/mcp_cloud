# backend/tests/test_profile_and_billing.py
import pytest
import os
import stripe
from fastapi.testclient import TestClient
from sqlalchemy import create_engine, select
from sqlalchemy.orm import sessionmaker
from datetime import datetime

from models import User, UserKey, UserSubscription

# Fixture to set up a clean test environment for each test function
@pytest.fixture(scope="function")
def client(monkeypatch, tmp_path):
    monkeypatch.setenv("DATABASE_URL", f"sqlite:///{tmp_path / 'test_billing.db'}")
    monkeypatch.setenv("CREDENTIAL_ENCRYPTION_KEY", "test_key_must_be_32_bytes_long!")
    monkeypatch.setenv("STRIPE_API_KEY", "sk_test_mock")
    monkeypatch.setenv("STRIPE_WEBHOOK_SECRET", "whsec_mock")

    from main import app, get_db
    from models import Base

    engine = create_engine(f"sqlite:///{tmp_path / 'test_billing.db'}", connect_args={"check_same_thread": False})
    TestingSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
    Base.metadata.create_all(bind=engine)

    def override_get_db():
        db = TestingSessionLocal()
        try:
            yield db
        finally:
            db.close()

    app.dependency_overrides[get_db] = override_get_db
    yield TestClient(app), TestingSessionLocal
    app.dependency_overrides.clear()
    Base.metadata.drop_all(bind=engine)

# Helper to create a user directly in the DB for tests
@pytest.fixture
def create_user(client):
    _, SessionLocal = client
    def _create_user(email: str, role: str = "student"):
        db = SessionLocal()
        try:
            new_user = User(email=email, role=role)
            db.add(new_user)
            db.commit()
            db.refresh(new_user)
            return new_user
        finally:
            db.close()
    return _create_user

# --- Phase 3: Profile/Key Management Tests ---

def test_create_and_list_api_keys(client, create_user):
    test_client, SessionLocal = client
    user = create_user("keyuser@example.com")

    # 1. Create a key
    response = test_client.post(
        "/api/v1/profile/keys",
        headers={"x-forwarded-email": user.email},
        json={"name": "My Test Key", "platform": "aws", "secret_value": "12345"}
    )
    assert response.status_code == 200
    data = response.json()
    assert data["name"] == "My Test Key"
    assert data["platform"] == "aws"

    # 2. Verify in DB
    db = SessionLocal()
    key_in_db = db.scalar(select(UserKey).where(UserKey.id == data["id"]))
    assert key_in_db is not None
    assert key_in_db.user_id == user.id
    # Check that value is encrypted
    from routers.profile import decrypt_value
    assert decrypt_value(key_in_db.encrypted_value) == "12345"
    db.close()

    # 3. List keys
    response = test_client.get("/api/v1/profile/keys", headers={"x-forwarded-email": user.email})
    assert response.status_code == 200
    assert len(response.json()) == 1
    assert response.json()[0]["name"] == "My Test Key"

def test_delete_api_key(client, create_user):
    test_client, SessionLocal = client
    user = create_user("deleteuser@example.com")

    # 1. Create a key
    create_response = test_client.post(
        "/api/v1/profile/keys",
        headers={"x-forwarded-email": user.email},
        json={"name": "Key to Delete", "platform": "gcp", "secret_value": "abcde"}
    )
    key_id = create_response.json()["id"]

    # 2. Delete the key
    delete_response = test_client.delete(f"/api/v1/profile/keys/{key_id}", headers={"x-forwarded-email": user.email})
    assert delete_response.status_code == 204

    # 3. Verify it's gone
    db = SessionLocal()
    key_in_db = db.scalar(select(UserKey).where(UserKey.id == key_id))
    assert key_in_db is None
    db.close()

# --- Phase 4: Billing/Stripe Tests ---

@pytest.fixture
def mock_stripe(monkeypatch):
    # Mock Checkout Session
    mock_checkout = {"id": "cs_test_123", "url": "https://checkout.stripe.com/mock_url"}
    monkeypatch.setattr(stripe.checkout.Session, "create", lambda **kwargs: mock_checkout)

    # Mock Portal Session
    mock_portal = {"id": "pts_test_123", "url": "https://billing.stripe.com/mock_portal"}
    monkeypatch.setattr(stripe.billing_portal.Session, "create", lambda **kwargs: mock_portal)

    # Mock Webhook Event
    def mock_construct_event(*args, **kwargs):
        return {
            "type": "checkout.session.completed",
            "data": {
                "object": {
                    "customer": "cus_test_123",
                    "subscription": "sub_test_123",
                    "customer_details": {"email": "stripeuser@example.com"}
                }
            }
        }
    monkeypatch.setattr(stripe.Webhook, "construct_event", mock_construct_event)

    # Mock Subscription Retrieve
    def mock_retrieve_sub(*args, **kwargs):
        return {
            "id": "sub_test_123",
            "items": {"data": [{"price": {"id": "price_pro_plan"}}]}, # Mocked price ID
            "status": "active",
            "current_period_start": datetime.utcnow(),
            "current_period_end": datetime.utcnow(),
            "cancel_at_period_end": False
        }
    monkeypatch.setattr(stripe.Subscription, "retrieve", mock_retrieve_sub)


def test_create_checkout_session(client, create_user, mock_stripe):
    test_client, _ = client
    user = create_user("checkout@example.com")

    response = test_client.post("/api/v1/billing/checkout-session", headers={"x-forwarded-email": user.email})
    assert response.status_code == 200
    assert response.json()["url"] == "https://checkout.stripe.com/mock_url"

def test_create_portal_session(client, create_user, mock_stripe):
    test_client, SessionLocal = client
    user = create_user("portaluser@example.com")
    
    # User needs a subscription first
    db = SessionLocal()
    sub = UserSubscription(user_id=user.id, stripe_customer_id="cus_test_123")
    db.add(sub)
    db.commit()
    db.close()

    response = test_client.post("/api/v1/billing/portal-session", headers={"x-forwarded-email": user.email})
    assert response.status_code == 200
    assert response.json()["url"] == "https://billing.stripe.com/mock_portal"

def test_stripe_webhook_updates_db(client, create_user, mock_stripe):
    test_client, SessionLocal = client
    user = create_user("stripeuser@example.com") # Email must match the one in mock_construct_event

    response = test_client.post("/api/v1/billing/webhook", content="mock_payload", headers={"stripe-signature": "mock_sig"})
    assert response.status_code == 200

    # Verify DB was updated
    db = SessionLocal()
    sub = db.scalar(select(UserSubscription).where(UserSubscription.user_id == user.id))
    assert sub is not None
    assert sub.status == "active"
    assert sub.stripe_subscription_id == "sub_test_123"
    db.close()

def test_get_subscription_status(client, create_user):
    test_client, SessionLocal = client
    user = create_user("substatus@example.com")

    # 1. Test user with no subscription record (should be free)
    response = test_client.get("/api/v1/profile/me/subscription", headers={"x-forwarded-email": user.email})
    assert response.status_code == 200
    assert response.json()["plan_id"] == "free"

    # 2. Add a subscription record and test again
    db = SessionLocal()
    sub = UserSubscription(user_id=user.id, plan_id="pro", status="active")
    db.add(sub)
    db.commit()
    db.close()

    response = test_client.get("/api/v1/profile/me/subscription", headers={"x-forwarded-email": user.email})
    assert response.status_code == 200
    assert response.json()["plan_id"] == "pro"
    assert response.json()["status"] == "active"
