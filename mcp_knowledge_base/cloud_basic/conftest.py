# -*- coding: utf-8 -*-
import os
import sys
import pytest
from pathlib import Path
from typing import Generator
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, Session
from core.celery_app import celery_app

from core.config import get_settings
from core.database import Base, init_db, get_database_url
from core.redis_config import redis_client, get_redis_url
from models.system_settings import SystemSetting
from core.seed import create_initial_system_settings_sync
from core.logging import logger

# 상위 디렉토리 추가하여 app 모듈 import 가능하게 설정
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

# 테스트 환경 설정
os.environ["ENVIRONMENT"] = "test"
os.environ["TESTING"] = "true"

# 테스트용 Alpha Vantage API 키
TEST_ALPHA_VANTAGE_API_KEY = "test_api_key_12345"

@pytest.fixture(scope="session")
def settings():
    """테스트 환경 설정을 제공하는 fixture"""
    test_settings = get_settings()
    test_settings.ENVIRONMENT = "test"
    # PostgreSQL 테스트 데이터베이스 URL 설정
    test_settings.SQLALCHEMY_DATABASE_URL = get_database_url()
    logger.info(f"Test database URL: {test_settings.SQLALCHEMY_DATABASE_URL}")
    return test_settings

@pytest.fixture(scope="session")
def db_engine(settings):
    """테스트를 위한 데이터베이스 엔진"""
    logger.info("Creating test database engine")
    engine = create_engine(
        settings.SQLALCHEMY_DATABASE_URL,
        pool_pre_ping=True,
        pool_size=5,
        max_overflow=10,
        pool_recycle=3600
    )
    
    # 데이터베이스 초기화
    Base.metadata.drop_all(bind=engine)  # 기존 테이블 삭제
    Base.metadata.create_all(bind=engine)  # 새로운 테이블 생성
    
    # 시스템 설정 초기화
    SessionLocal = sessionmaker(bind=engine)
    session = SessionLocal()
    
    try:
        # Alpha Vantage API 키 설정 추가
        alpha_vantage_setting = SystemSetting(
            key="alpha_vantage_api_key",
            value=TEST_ALPHA_VANTAGE_API_KEY,
            description="Alpha Vantage API 키 (테스트용)"
        )
        session.add(alpha_vantage_setting)
        session.commit()
        logger.info("Test system settings initialized")
    except Exception as e:
        logger.error(f"Error initializing test system settings: {str(e)}")
        session.rollback()
    finally:
        session.close()
    
    logger.info("Test database initialized")
    
    yield engine
    
    # 테스트 종료 후 정리
    Base.metadata.drop_all(bind=engine)
    logger.info("Test database cleaned up")

# 테스트용 세션 팩토리 생성
SessionLocal = sessionmaker(autocommit=False, autoflush=False)

@pytest.fixture(scope="function")
def db(db_engine):
    """테스트 함수마다 독립적인 데이터베이스 세션 제공"""
    logger.info("Creating new test database session")
    connection = db_engine.connect()
    transaction = connection.begin()
    session = SessionLocal(bind=connection)
    
    yield session
    
    session.close()
    transaction.rollback()
    connection.close()
    logger.info("Test database session closed")

@pytest.fixture(scope="session")
def celery_config(settings):
    """Celery 설정"""
    return {
        'broker_url': settings.CELERY_BROKER_URL,
        'result_backend': settings.CELERY_RESULT_BACKEND,
        'task_always_eager': True,
        'task_eager_propagates': True,
    }

@pytest.fixture(scope="session")
def redis_config(settings):
    """Redis 설정"""
    return {
        'host': settings.REDIS_HOST,
        'port': settings.REDIS_PORT,
        'db': settings.REDIS_DB,
        'decode_responses': True
    }

@pytest.fixture(scope="session")
def test_data_dir():
    """테스트 데이터 디렉토리 경로"""
    data_dir = Path(__file__).parent / "data"
    data_dir.mkdir(exist_ok=True)
    return data_dir

# Celery 앱 재설정
celery_app.conf.broker_url = get_redis_url()
celery_app.conf.result_backend = get_redis_url()

# 테스트를 위한 Celery 설정 업데이트
celery_app.conf.update(
    task_always_eager=True,
    task_eager_propagates=True,
)