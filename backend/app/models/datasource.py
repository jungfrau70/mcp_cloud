# backend/app/models/datasource.py
from sqlalchemy import Column, Integer, String, DateTime, JSON
from datetime import datetime
from ..db.base import Base


class DataSource(Base):
    __tablename__ = "datasources"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, index=True, unique=True, nullable=False)
    provider = Column(String, nullable=False)
    data_type = Column(String, nullable=False)
    config = Column(JSON, nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)


__all__ = [
  'DataSource'
]


