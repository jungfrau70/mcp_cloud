@echo off
chcp 65001 > nul
REM 운영 환경 실행 스크립트 (Docker Compose)
echo 🚀 운영 환경 시작 (Docker Compose)...

echo 📋 환경 설정:
echo   - ENV: production
echo   - API URL: https://api.goldencircle.us
echo   - Frontend URL: https://app.goldencircle.us
echo   - Database: PostgreSQL (공통 사용)

echo.
echo 🔧 공통 데이터베이스 서비스 시작...
docker-compose -f docker-compose.base.yml up -d

echo ⏳ 데이터베이스 서비스 시작 대기 중...
timeout /t 10 /nobreak > nul

echo.
echo 🏭 운영 환경 애플리케이션 시작...
docker-compose -f docker-compose.base.yml -f docker-compose.prod.yml up --build -d

echo.
echo 📊 서비스 상태 확인...
docker-compose -f docker-compose.base.yml -f docker-compose.prod.yml ps

echo.
echo 🛑 서비스 중지하려면 다음 명령어를 실행하세요:
echo    docker-compose -f docker-compose.base.yml -f docker-compose.prod.yml down

pause
