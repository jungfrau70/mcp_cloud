# backend/app/models/user.py
from sqlalchemy import Column, Integer, String, DateTime, LargeBinary, ForeignKey, Text, Boolean
from sqlalchemy.orm import relationship
from datetime import datetime
from ..db.base import Base


class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    email = Column(String, unique=True, index=True, nullable=False)
    full_name = Column(String, nullable=True)
    role = Column(String, nullable=False, default="student")
    picture_url = Column(String, nullable=True)
    password_hash = Column(String, nullable=True)
    is_active = Column(Boolean, nullable=False, default=False)
    email_verification_token = Column(String, nullable=True, index=True)
    email_verified_at = Column(DateTime, nullable=True)
    password_reset_token = Column(String, nullable=True, index=True)
    password_reset_expires = Column(DateTime, nullable=True)
    last_login_at = Column(DateTime, default=datetime.utcnow)
    gemini_api_key = Column(String, nullable=True)  # 사용자별 Gemini API 키
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    profile = relationship("UserProfile", back_populates="user", uselist=False)
    keys = relationship("UserKey", back_populates="user")
    certs = relationship("UserCert", back_populates="user")
    subscription = relationship("UserSubscription", back_populates="user", uselist=False)


class UserProfile(Base):
    __tablename__ = "user_profiles"
    id = Column(Integer, primary_key=True)
    user_id = Column(Integer, ForeignKey('users.id'), unique=True, nullable=False)
    user = relationship("User", back_populates="profile")


class UserKey(Base):
    __tablename__ = "user_keys"
    id = Column(Integer, primary_key=True)
    user_id = Column(Integer, ForeignKey('users.id'), nullable=False)
    user = relationship("User", back_populates="keys")
    name = Column(String, nullable=False)
    platform = Column(String, nullable=False)
    encrypted_value = Column(LargeBinary, nullable=False)
    fingerprint = Column(String, nullable=True)
    expires_at = Column(DateTime, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)


class UserCert(Base):
    __tablename__ = "user_certs"
    id = Column(Integer, primary_key=True)
    user_id = Column(Integer, ForeignKey('users.id'), nullable=False)
    user = relationship("User", back_populates="certs")
    name = Column(String, nullable=False)
    encrypted_value = Column(LargeBinary, nullable=False)
    fingerprint = Column(String, nullable=True)
    expires_at = Column(DateTime, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)


class UserSubscription(Base):
    __tablename__ = "user_subscriptions"
    id = Column(Integer, primary_key=True)
    user_id = Column(Integer, ForeignKey('users.id'), unique=True, nullable=False)
    user = relationship("User", back_populates="subscription")

    stripe_customer_id = Column(String, unique=True, index=True, nullable=True)
    stripe_subscription_id = Column(String, unique=True, index=True, nullable=True)

    plan_id = Column(String, nullable=True)
    status = Column(String, nullable=True)

    current_period_start = Column(DateTime, nullable=True)
    current_period_end = Column(DateTime, nullable=True)
    cancel_at_period_end = Column(Boolean, default=False)

    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)


__all__ = [
  'User', 'UserProfile', 'UserKey', 'UserCert', 'UserSubscription'
]


