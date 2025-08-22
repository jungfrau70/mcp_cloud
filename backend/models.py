# =================
# SQLAlchemy를 위한 데이터베이스 모델 정의
from sqlalchemy import Column, Integer, String, Text, DateTime, Enum, JSON
from sqlalchemy.orm import declarative_base
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

# ---------------------------------------------------------------------------
# Knowledge Base Models (P1)
# ---------------------------------------------------------------------------

class KbDocument(Base):
    __tablename__ = "kb_documents"

    id = Column(Integer, primary_key=True, index=True)
    path = Column(String, unique=True, index=True, nullable=False)  # normalized relative path
    title = Column(String, nullable=True)
    tags = Column(JSON, nullable=True)
    latest_version_id = Column(Integer, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)


class KbDocumentVersion(Base):
    __tablename__ = "kb_document_versions"

    id = Column(Integer, primary_key=True, index=True)
    document_id = Column(Integer, index=True, nullable=False)
    version_no = Column(Integer, index=True, nullable=False)
    content = Column(Text, nullable=False)
    message = Column(String, nullable=True)
    author = Column(String, default="system", nullable=False)
    size_bytes = Column(Integer, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)


class KbTask(Base):
    __tablename__ = "kb_tasks"

    id = Column(String, primary_key=True, index=True)  # uuid string
    type = Column(String, index=True)  # generation, indexing, etc.
    status = Column(String, index=True)  # pending, running, done, failed
    stage = Column(String, nullable=True)  # collect, extract ...
    progress = Column(Integer, nullable=True)  # 0-100 int percentage
    input = Column(JSON, nullable=True)
    output = Column(JSON, nullable=True)
    error = Column(Text, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

# ---------------------------------------------------------------------------
# User-managed trending categories
# ---------------------------------------------------------------------------

class TrendingCategory(Base):
    __tablename__ = "trending_categories"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, unique=True, index=True, nullable=False)
    query = Column(String, nullable=False)  # 검색/생성에 사용할 쿼리 텍스트
    enabled = Column(Integer, default=1)  # 1=true, 0=false (sqlite 호환)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)