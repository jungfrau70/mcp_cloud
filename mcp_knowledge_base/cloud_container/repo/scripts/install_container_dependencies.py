#!/usr/bin/env python3
"""
Cloud Container 과정 의존성 설치 스크립트
Container 과정에 필요한 Python 패키지들을 자동으로 설치합니다.
"""

import os
import sys
import subprocess
import logging
from pathlib import Path
from typing import Dict, Any, List

# 로깅 설정
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('install_container_dependencies.log', mode='w'),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)

class ContainerDependencyInstaller:
    """Container 과정 의존성 설치 클래스"""
    
    def __init__(self):
        self.required_packages = {
            "kubernetes": "Kubernetes Python 클라이언트",
            "docker": "Docker Python SDK",
            "google-cloud-container": "GCP Container Python 클라이언트",
            "google-cloud-storage": "GCP Storage Python 클라이언트",
            "pyyaml": "YAML 파일 처리",
            "requests": "HTTP 요청 처리",
            "jinja2": "템플릿 엔진"
        }
        
        self.optional_packages = {
            "helm": "Helm 차트 관리 (CLI 도구)",
            "kubectl": "Kubernetes CLI (CLI 도구)",
            "docker": "Docker CLI (CLI 도구)",
            "gcloud": "GCP CLI (CLI 도구)"
        }
        
        self.installation_results = {
            "python_packages": {},
            "cli_tools": {},
            "overall_status": "not_started"
        }
    
    def check_python_package(self, package_name: str) -> bool:
        """Python 패키지 설치 여부 확인"""
        try:
            __import__(package_name)
            return True
        except ImportError:
            return False
    
    def check_cli_tool(self, tool_name: str) -> bool:
        """CLI 도구 설치 여부 확인"""
        try:
            result = subprocess.run(
                [tool_name, "--version"], 
                capture_output=True, 
                text=True, 
                timeout=10
            )
            return result.returncode == 0
        except (subprocess.TimeoutExpired, FileNotFoundError):
            return False
    
    def install_python_package(self, package_name: str, description: str = "") -> Dict[str, Any]:
        """Python 패키지 설치"""
        result = {
            "package": package_name,
            "description": description,
            "installed": False,
            "error": None
        }
        
        try:
            logger.info(f"📦 Python 패키지 설치 중: {package_name}")
            
            # pip install 실행
            process = subprocess.run(
                [sys.executable, "-m", "pip", "install", package_name],
                capture_output=True,
                text=True,
                timeout=300  # 5분 타임아웃
            )
            
            if process.returncode == 0:
                result["installed"] = True
                logger.info(f"✅ {package_name} 설치 완료")
            else:
                result["error"] = process.stderr
                logger.error(f"❌ {package_name} 설치 실패: {process.stderr}")
                
        except subprocess.TimeoutExpired:
            result["error"] = "설치 시간 초과"
            logger.error(f"❌ {package_name} 설치 시간 초과")
        except Exception as e:
            result["error"] = str(e)
            logger.error(f"❌ {package_name} 설치 중 오류: {e}")
        
        return result
    
    def install_cli_tool_guide(self, tool_name: str, description: str = "") -> Dict[str, Any]:
        """CLI 도구 설치 가이드 제공"""
        result = {
            "tool": tool_name,
            "description": description,
            "installed": False,
            "install_guide": ""
        }
        
        if self.check_cli_tool(tool_name):
            result["installed"] = True
            logger.info(f"✅ {tool_name} 이미 설치됨")
        else:
            # 설치 가이드 생성
            install_guides = {
                "helm": """
# Helm 설치 (Windows)
# 1. Chocolatey 사용
choco install kubernetes-helm

# 2. 직접 다운로드
# https://github.com/helm/helm/releases 에서 최신 버전 다운로드
# 압축 해제 후 PATH에 추가

# 3. 설치 확인
helm version
                """,
                "kubectl": """
# kubectl 설치 (Windows)
# 1. Chocolatey 사용
choco install kubernetes-cli

# 2. 직접 다운로드
# https://kubernetes.io/docs/tasks/tools/install-kubectl-windows/
# kubectl.exe를 PATH에 추가

# 3. 설치 확인
kubectl version --client
                """,
                "docker": """
# Docker Desktop 설치 (Windows)
# 1. Docker Desktop 다운로드
# https://www.docker.com/products/docker-desktop

# 2. 설치 후 재시작
# 3. 설치 확인
docker --version
                """,
                "gcloud": """
# GCP CLI 설치 (Windows)
# 1. Google Cloud SDK 다운로드
# https://cloud.google.com/sdk/docs/install

# 2. 설치 후 초기화
gcloud init

# 3. 설치 확인
gcloud version
                """
            }
            
            result["install_guide"] = install_guides.get(tool_name, "설치 가이드를 찾을 수 없습니다.")
            logger.warning(f"⚠️ {tool_name} 설치 필요 - 가이드 제공")
        
        return result
    
    def create_requirements_txt(self) -> bool:
        """requirements.txt 파일 생성"""
        try:
            requirements_path = Path("requirements.txt")
            
            with open(requirements_path, 'w', encoding='utf-8') as f:
                f.write("# Cloud Container 과정 필수 Python 패키지\n")
                f.write("# 생성일: 2024-09-25\n\n")
                
                for package, description in self.required_packages.items():
                    f.write(f"# {description}\n")
                    f.write(f"{package}\n\n")
            
            logger.info(f"✅ requirements.txt 파일 생성 완료: {requirements_path}")
            return True
            
        except Exception as e:
            logger.error(f"❌ requirements.txt 파일 생성 실패: {e}")
            return False
    
    def create_install_script(self) -> bool:
        """설치 스크립트 생성"""
        try:
            # Windows용 설치 스크립트
            install_script_windows = """@echo off
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
"""
            
            with open("install_container_dependencies.bat", 'w', encoding='utf-8') as f:
                f.write(install_script_windows)
            
            # Linux/Mac용 설치 스크립트
            install_script_unix = """#!/bin/bash
echo "Cloud Container 과정 의존성 설치 스크립트"
echo "=========================================="

echo "Python 패키지 설치 중..."
pip install -r requirements.txt

echo ""
echo "CLI 도구 설치 확인..."
echo ""
echo "1. Docker 설치:"
echo "   curl -fsSL https://get.docker.com -o get-docker.sh"
echo "   sudo sh get-docker.sh"
echo ""
echo "2. GCP CLI 설치:"
echo "   curl https://sdk.cloud.google.com | bash"
echo "   exec -l $SHELL"
echo ""
echo "3. kubectl 설치:"
echo "   curl -LO https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
echo "   sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl"
echo ""
echo "4. Helm 설치:"
echo "   curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash"
echo ""
echo "설치 완료 후 다음 명령어로 확인하세요:"
echo "docker --version"
echo "gcloud version"
echo "kubectl version --client"
echo "helm version"
"""
            
            with open("install_container_dependencies.sh", 'w', encoding='utf-8') as f:
                f.write(install_script_unix)
            
            # 실행 권한 부여 (Unix 시스템에서)
            try:
                os.chmod("install_container_dependencies.sh", 0o755)
            except:
                pass  # Windows에서는 무시
            
            logger.info("✅ 설치 스크립트 생성 완료")
            return True
            
        except Exception as e:
            logger.error(f"❌ 설치 스크립트 생성 실패: {e}")
            return False
    
    def run_installation(self) -> Dict[str, Any]:
        """전체 설치 프로세스 실행"""
        logger.info("🚀 Cloud Container 과정 의존성 설치 시작")
        
        # 1. Python 패키지 설치
        logger.info("\n📦 1. Python 패키지 설치")
        for package, description in self.required_packages.items():
            if not self.check_python_package(package):
                result = self.install_python_package(package, description)
                self.installation_results["python_packages"][package] = result
            else:
                logger.info(f"✅ {package} 이미 설치됨")
                self.installation_results["python_packages"][package] = {
                    "package": package,
                    "description": description,
                    "installed": True,
                    "error": None
                }
        
        # 2. CLI 도구 확인 및 가이드 제공
        logger.info("\n🔧 2. CLI 도구 확인")
        for tool, description in self.optional_packages.items():
            result = self.install_cli_tool_guide(tool, description)
            self.installation_results["cli_tools"][tool] = result
        
        # 3. requirements.txt 생성
        logger.info("\n📄 3. requirements.txt 파일 생성")
        self.create_requirements_txt()
        
        # 4. 설치 스크립트 생성
        logger.info("\n📜 4. 설치 스크립트 생성")
        self.create_install_script()
        
        # 5. 결과 요약
        self.installation_results["overall_status"] = "completed"
        
        # 결과 저장
        import json
        with open('container_dependency_installation_results.json', 'w', encoding='utf-8') as f:
            json.dump(self.installation_results, f, ensure_ascii=False, indent=2)
        
        logger.info("\n🎉 Container 과정 의존성 설치 완료!")
        logger.info("결과가 container_dependency_installation_results.json에 저장되었습니다.")
        
        return self.installation_results

def main():
    """메인 함수"""
    installer = ContainerDependencyInstaller()
    results = installer.run_installation()
    
    # 결과 요약 출력
    print("\n" + "="*60)
    print("CLOUD CONTAINER 과정 의존성 설치 결과 요약")
    print("="*60)
    
    # Python 패키지 결과
    python_installed = sum(1 for r in results["python_packages"].values() if r["installed"])
    python_total = len(results["python_packages"])
    print(f"Python 패키지: {python_installed}/{python_total} 설치 완료")
    
    # CLI 도구 결과
    cli_installed = sum(1 for r in results["cli_tools"].values() if r["installed"])
    cli_total = len(results["cli_tools"])
    print(f"CLI 도구: {cli_installed}/{cli_total} 설치 완료")
    
    print("="*60)
    print("Container 과정 의존성 설치 완료! 🐳")
    
    # 설치되지 않은 항목 안내
    print("\n📋 설치되지 않은 항목:")
    for package, result in results["python_packages"].items():
        if not result["installed"]:
            print(f"❌ Python 패키지: {package}")
    
    for tool, result in results["cli_tools"].items():
        if not result["installed"]:
            print(f"❌ CLI 도구: {tool}")
    
    print("\n📜 생성된 파일:")
    print("- requirements.txt")
    print("- install_container_dependencies.bat (Windows)")
    print("- install_container_dependencies.sh (Linux/Mac)")
    print("- container_dependency_installation_results.json")

if __name__ == "__main__":
    main()
