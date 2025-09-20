@echo off
chcp 65001 > nul
REM 개발 환경 실행 스크립트 (Docker Compose)
echo 🚀 개발 환경 시작 (Docker Compose)...

echo 📋 환경 설정:
echo   - ENV: development
echo   - API URL: http://localhost:8000
echo   - Frontend URL: http://localhost:3000
echo   - Database: PostgreSQL (공통 사용)

echo.
echo 🔧 공통 데이터베이스 서비스 시작...
docker-compose -f docker-compose.base.yml up -d

echo ⏳ 데이터베이스 서비스 시작 대기 중...
timeout /t 10 /nobreak > nul

echo.
echo 🎨 개발 환경 애플리케이션 시작...
docker-compose -f docker-compose.base.yml -f docker-compose.dev.yml up --build

echo.
echo 🛑 서비스 중지...
docker-compose -f docker-compose.base.yml -f docker-compose.dev.yml down

pause
