@echo off
chcp 65001 > nul
REM 환경 설정 검증 스크립트
echo 🔍 환경 설정 검증 중...

echo.
echo 📋 현재 환경 변수:
echo   - ENV: %ENV%
echo   - NODE_ENV: %NODE_ENV%
echo   - NUXT_PUBLIC_API_BASE_URL: %NUXT_PUBLIC_API_BASE_URL%
echo   - NUXT_PUBLIC_ENV: %NUXT_PUBLIC_ENV%
echo   - NUXT_PUBLIC_DEBUG: %NUXT_PUBLIC_DEBUG%
echo   - DEBUG: %DEBUG%

echo.
echo 🔧 백엔드 설정 확인:
cd backend
python -c "from config import ENV, DEBUG, DATABASE_URL, ALLOWED_ORIGINS; print(f'  - ENV: {ENV}'); print(f'  - DEBUG: {DEBUG}'); print(f'  - DATABASE_URL: {DATABASE_URL}'); print(f'  - ALLOWED_ORIGINS: {ALLOWED_ORIGINS}')"
cd ..

echo.
echo 🎨 프론트엔드 설정 확인:
cd frontend
node -e "console.log('  - NODE_ENV:', process.env.NODE_ENV); console.log('  - NUXT_PUBLIC_API_BASE_URL:', process.env.NUXT_PUBLIC_API_BASE_URL); console.log('  - NUXT_PUBLIC_ENV:', process.env.NUXT_PUBLIC_ENV); console.log('  - NUXT_PUBLIC_DEBUG:', process.env.NUXT_PUBLIC_DEBUG);"
cd ..

echo.
echo ✅ 환경 설정 검증 완료!
pause
