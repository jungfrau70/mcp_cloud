#!/usr/bin/env python3
"""
Backend Development Server Runner
가상환경에서 백엔드 개발 서버를 실행하는 스크립트
"""

import os
import sys
import subprocess
import argparse
from pathlib import Path
from dotenv import load_dotenv

def setup_environment():
    """환경 변수 설정"""
    print("🔧 Setting up environment variables...")
    
    # 1. .env 파일 로드 (우선순위: 환경변수 > .env 파일 > 기본값)
    env_file_path = Path(__file__).parent / 'env' / '.env'
    if env_file_path.exists():
        load_dotenv(dotenv_path=env_file_path)
        print(f"✅ Loaded environment variables from: {env_file_path}")
    else:
        print(f"⚠️  Warning: .env file not found at {env_file_path}")
    
    # 2. 기본 환경 변수 설정 (환경변수나 .env 파일에 없을 때만 사용)
    default_env_vars = {
        'DATABASE_URL': 'postgresql://mcpuser:mcppassword@mcp_postgres:5432/postgres',
        'GEMINI_API_KEY': 'dummy_key',
        'MCP_API_KEY': 'dummy_key',
        'AWS_DEFAULT_REGION': 'ap-northeast-2',
        'ENVIRONMENT': 'development',
        'DEBUG': 'true',
        'LOG_LEVEL': 'INFO'
    }
    
    # 3. 환경 변수 설정 (기존 값이 없을 때만)
    print("\n📋 Environment variables status:")
    for key, value in default_env_vars.items():
        if key not in os.environ:
            os.environ[key] = value
            print(f"  🔄 Set default {key}={value}")
        else:
            print(f"  ✅ Using existing {key}={os.environ[key]}")
    
    # 4. GCP 자격 증명 파일 경로 설정
    gcp_key_path = Path(__file__).parent / 'env' / 'alpha-ktixap-43e9bf90eb00.json'
    if gcp_key_path.exists():
        os.environ['GOOGLE_APPLICATION_CREDENTIALS'] = str(gcp_key_path)
        os.environ['CLOUDSDK_AUTH_CREDENTIAL_FILE_OVERRIDE'] = str(gcp_key_path)
        print(f"  🔑 Set GCP credentials: {gcp_key_path}")
    
    # 5. AWS 자격 증명 설정
    aws_key_path = Path(__file__).parent / 'env' / 'rootkey.csv'
    if aws_key_path.exists():
        # CSV 파일에서 자격 증명 읽기
        try:
            with open(aws_key_path, 'r') as f:
                lines = f.readlines()
                if len(lines) >= 2:
                    access_key = lines[1].split(',')[0].strip()
                    secret_key = lines[1].split(',')[1].strip()
                    os.environ['AWS_ACCESS_KEY_ID'] = access_key
                    os.environ['AWS_SECRET_ACCESS_KEY'] = secret_key
                    print(f"  🔑 Set AWS credentials from {aws_key_path}")
        except Exception as e:
            print(f"  ⚠️  Warning: Could not read AWS credentials: {e}")

    # 6. GEMINI 자격 증명 확인
    print(f"  🔑 GEMINI_API_KEY: {os.environ['GEMINI_API_KEY']}")
    
    # 6. 환경 변수 확인
    print("\n📋 Environment variables status:")
    for key, value in os.environ.items():
        print(f"  ✅ {key}={value}")
    
    print("✅ Environment setup completed!\n")

def check_dependencies():
    """필요한 패키지 설치 확인"""
    required_packages = [
        'fastapi', 'uvicorn', 'sqlalchemy', 'alembic', 
        'psycopg2-binary', 'pydantic', 'pytest'
    ]
    
    missing_packages = []
    for package in required_packages:
        try:
            __import__(package.replace('-', '_'))
        except ImportError:
            missing_packages.append(package)
    
    if missing_packages:
        print(f"Missing packages: {', '.join(missing_packages)}")
        print("Please install them using:")
        print("pip install -r requirements.txt")
        return False
    
    return True

def run_server(host='0.0.0.0', port=8000, reload=True):
    """FastAPI 서버 실행"""
    try:
        import uvicorn
        print(f"Starting FastAPI server on {host}:{port}")
        print(f"API documentation: http://{host}:{port}/docs")
        print(f"Health check: http://{host}:{port}/health")
        print("Press Ctrl+C to stop the server")
        
        uvicorn.run(
            "main:app",
            host=host,
            port=port,
            reload=reload,
            log_level="info"
        )
    except KeyboardInterrupt:
        print("\nServer stopped by user")
    except Exception as e:
        print(f"Error starting server: {e}")
        sys.exit(1)

def run_tests():
    """테스트 실행"""
    try:
        print("Running tests...")
        result = subprocess.run([
            sys.executable, "-m", "pytest", "tests/", "-v"
        ], cwd=Path(__file__).parent)
        return result.returncode == 0
    except Exception as e:
        print(f"Error running tests: {e}")
        return False

def main():
    """메인 함수"""
    parser = argparse.ArgumentParser(description='Backend Development Server')
    parser.add_argument('--host', default='0.0.0.0', help='Host to bind to')
    parser.add_argument('--port', type=int, default=8000, help='Port to bind to')
    parser.add_argument('--no-reload', action='store_true', help='Disable auto-reload')
    parser.add_argument('--test', action='store_true', help='Run tests instead of server')
    
    args = parser.parse_args()
    
    # 환경 설정
    setup_environment()
    
    if args.test:
        # 테스트 실행
        success = run_tests()
        sys.exit(0 if success else 1)
    else:
        # 의존성 확인
        if not check_dependencies():
            print("Please install missing dependencies first")
            sys.exit(1)
        
        # 서버 실행
        run_server(
            host=args.host,
            port=args.port,
            reload=not args.no_reload
        )

if __name__ == '__main__':
    main()
