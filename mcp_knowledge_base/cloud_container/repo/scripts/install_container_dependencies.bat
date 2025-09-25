@echo off
echo Cloud Container 과정 의존성 설치 스크립트
echo ==========================================

echo Python 패키지 설치 중...
pip install -r requirements.txt

echo.
echo CLI 도구 설치 확인...
echo.
echo 1. Docker Desktop 설치:
echo    https://www.docker.com/products/docker-desktop
echo.
echo 2. GCP CLI 설치:
echo    https://cloud.google.com/sdk/docs/install
echo.
echo 3. kubectl 설치:
echo    https://kubernetes.io/docs/tasks/tools/install-kubectl-windows/
echo.
echo 4. Helm 설치:
echo    https://github.com/helm/helm/releases
echo.
echo 설치 완료 후 다음 명령어로 확인하세요:
echo docker --version
echo gcloud version
echo kubectl version --client
echo helm version
echo.
pause
