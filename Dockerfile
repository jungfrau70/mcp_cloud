# backend/Dockerfile
# =================
# MCP 백엔드와 마이그레이션 서비스에 사용되는 도커파일
FROM python:3.11-slim

WORKDIR /app

# 파이썬 의존성 설치
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Alembic 설정 및 애플리케이션 코드 복사
COPY alembic.ini .
COPY alembic /app/alembic
COPY models.py .
COPY main.py .
```text