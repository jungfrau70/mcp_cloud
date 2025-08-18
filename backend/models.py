# =================
# SQLAlchemy를 위한 데이터베이스 모델 정의
from sqlalchemy import Column, Integer, String, Text, DateTime, Enum, JSON
from sqlalchemy.ext.declarative import declarative_base
from datetime import datetime
import enum

Base = declarative_base()

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
    # Store enum using its value (lowercase strings) to match DB type 'deploymentstatus'
    status = Column(
        Enum(
            DeploymentStatus,
            name='deploymentstatus',
            values_callable=lambda enum_cls: [member.value for member in enum_cls],
            create_type=False,
            native_enum=True,
        ),
        default=DeploymentStatus.CREATED,
    )
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    terraform_plan_output = Column(Text, nullable=True)
    terraform_apply_log = Column(Text, nullable=True)
    gemini_review_summary = Column(Text, nullable=True)
    gemini_review_issues = Column(JSON, nullable=True)

class DataSource(Base):
    __tablename__ = "datasources"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, index=True, unique=True, nullable=False)
    provider = Column(String, nullable=False)
    data_type = Column(String, nullable=False)
    config = Column(JSON, nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)