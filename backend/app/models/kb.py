# backend/app/models/kb.py
from sqlalchemy import Column, Integer, String, Text, DateTime, JSON
from ..db.base import Base
from datetime import datetime


class KbDocument(Base):
    __tablename__ = "kb_documents"

    id = Column(Integer, primary_key=True, index=True)
    path = Column(String, unique=True, index=True, nullable=False)
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

    id = Column(String, primary_key=True, index=True)
    type = Column(String, index=True)
    status = Column(String, index=True)
    stage = Column(String, nullable=True)
    progress = Column(Integer, nullable=True)
    input = Column(JSON, nullable=True)
    output = Column(JSON, nullable=True)
    error = Column(Text, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)


class TrendingCategory(Base):
    __tablename__ = "trending_categories"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, unique=True, index=True, nullable=False)
    query = Column(String, nullable=False)
    enabled = Column(Integer, default=1)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)


__all__ = [
  'KbDocument', 'KbDocumentVersion', 'KbTask', 'TrendingCategory'
]


