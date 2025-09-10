@echo off
REM Test Runner for Windows
REM 가상환경에서 pytest를 실행하는 배치 파일

echo ========================================
echo MCP Cloud Test Runner
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
echo Installing test dependencies...
pip install -r backend/requirements-pytest.txt

REM 테스트 실행
echo Running tests...
echo.

REM 명령행 인수 처리
set TEST_ARGS=%*
if "%TEST_ARGS%"=="" (
    echo Running all tests...
    cd backend
    python -m pytest tests/ -v
) else (
    echo Running tests with arguments: %TEST_ARGS%
    cd backend
    python -m pytest tests/ -v %TEST_ARGS%
)

REM 테스트 결과 확인
if errorlevel 1 (
    echo.
    echo Tests failed!
    echo.
    echo Common test commands:
    echo   run_tests.bat                    - Run all tests
    echo   run_tests.bat --cov=backend      - Run with coverage
    echo   run_tests.bat -k "test_name"     - Run specific test
    echo   run_tests.bat --lf               - Run only failed tests
    echo   run_tests.bat --tb=short         - Short traceback
) else (
    echo.
    echo All tests passed!
)

REM 가상환경 비활성화
call deactivate
echo.
echo Virtual environment deactivated.
pause
