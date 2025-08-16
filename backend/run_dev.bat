@echo off
REM Backend Development Server Runner for Windows
REM 가상환경에서 백엔드 개발 서버를 실행하는 배치 파일

echo ========================================
echo MCP Cloud Backend Development Server
echo ========================================

REM 현재 디렉토리를 프로젝트 루트로 변경
cd /d "%~dp0.."

REM 가상환경 활성화
echo Activating virtual environment...
call venv\Scripts\activate.bat

if errorlevel 1 (
    echo Error: Failed to activate virtual environment
    echo Please make sure virtual environment exists at venv\
    echo You can create it using: python -m venv venv
    pause
    exit /b 1
)

echo Virtual environment activated successfully!

REM 의존성 설치 확인
echo Checking dependencies...
pip install -r backend/requirements.txt

REM 백엔드 디렉토리로 이동
cd backend

REM 개발 서버 실행
echo Starting development server...
echo Server will be available at: http://localhost:7000
echo API documentation: http://localhost:7000/docs
echo Health check: http://localhost:7000/health
echo.
echo Press Ctrl+C to stop the server
echo.

python run_dev.py

REM 서버 종료 후 가상환경 비활성화
call deactivate
echo.
echo Server stopped. Virtual environment deactivated.
pause
