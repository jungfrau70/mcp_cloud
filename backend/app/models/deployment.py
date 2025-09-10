# backend/app/models/deployment.py
from sqlalchemy import Column, Integer, String, Text, DateTime, Enum, JSON
from datetime import datetime
import enum
from ..db.base import Base


class DeploymentStatus(str, enum.Enum):
    CREATED = "created"
    PLANNED = "planned"
    AWAITING_APPROVAL = "awaiting_approval"
    APPLYING = "applying"
    APPLIED = "applied"
    FAILED = "failed"
    DESTROYING = "destroying"
    DESTROYED = "destroyed"


class Deployment(Base):
    __tablename__ = "deployments"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, index=True)
    cloud = Column(String)
    module = Column(String)
    vars = Column(JSON)
    status = Column(Enum(DeploymentStatus, name='deploymentstatus', create_type=False, native_enum=True), default=DeploymentStatus.CREATED)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    terraform_plan_output = Column(Text, nullable=True)
    terraform_apply_log = Column(Text, nullable=True)
    gemini_review_summary = Column(Text, nullable=True)
    gemini_review_issues = Column(JSON, nullable=True)


__all__ = [
  'Deployment', 'DeploymentStatus'
]


